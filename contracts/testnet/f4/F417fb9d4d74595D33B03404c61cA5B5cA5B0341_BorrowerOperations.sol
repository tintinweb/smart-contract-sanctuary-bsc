// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./Interfaces/IBorrowerOperations.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IYUSDToken.sol";
import "./Interfaces/ICollSurplusPool.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Interfaces/IWhitelist.sol";
import "./Interfaces/IERC20.sol";
import "./Interfaces/IWAsset.sol";
import "./Dependencies/LiquityBase.sol";
import "./Dependencies/SafeMath.sol";

import "./Dependencies/SafeERC20.sol";


/**
 * BorrowerOperations is the contract that handles most of external facing trove activities that
 * a user would make with their own trove, like opening, closing, adjusting, increasing leverage, etc.
 */

 /**
   A summary of Lever Up:
   Takes in a collateral token A, and simulates borrowing of YUSD at a certain collateral ratio and
   buying more token A, putting back into protocol, buying more A, etc. at a certain leverage amount.
   So if at 3x leverage and 1000$ token A, it will mint 1000 * 3x * 2/3 = $2000 YUSD, then swap for
   token A by using some router strategy, returning a little under $2000 token A to put back in the
   trove. The number here is 2/3 because the math works out to be that collateral ratio is 150% if
   we have a 3x leverage. They now have a trove with $3000 of token A and a collateral ratio of 150%.
  */

contract BorrowerOperations is LiquityBase, OwnableUpgradeable, IBorrowerOperations, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public constant NAME = "BorrowerOperations";

    // --- Connected contract declarations ---

    ITroveManager internal troveManager;

    address internal stabilityPoolAddress;

    address internal gasPoolAddress;

    ICollSurplusPool internal collSurplusPool;

    address internal sYETIAddress;

    IYUSDToken internal yusdToken;

    uint internal constant BOOTSTRAP_PERIOD = 14 days;
    uint deploymentTime;

    // A doubly linked list of Troves, sorted by their recovery collateral ratios
    ISortedTroves internal sortedTroves;


    bool leverUpEnabled; // if false, then leverup functions cannot be called.


    /* --- Variable container structs  ---

    Used to hold, return and assign variables inside a function, in order to avoid the error:
    "CompilerError: Stack too deep". */

    struct DepositFeeCalc {
        uint256 collateralYUSDFee;
        uint256 systemCollateralVC;
        uint256 collateralInputVC;
        uint256 systemTotalVC;
        address token;
        uint256 activePoolVCPost;
    }

    struct AdjustTrove_Params {
        address[] _collsIn;
        uint256[] _amountsIn;
        address[] _collsOut;
        uint256[] _amountsOut;
        uint256[] _maxSlippages;
        uint256 _YUSDChange;
        uint256 _totalYUSDDebtFromLever;
        bool _isDebtIncrease;
        bool _isUnlever;
        address _upperHint;
        address _lowerHint;
        uint256 _maxFeePercentage;
    }

    struct LocalVariables_adjustTrove {
        uint256 netDebtChange;
        bool isCollIncrease;
        bool isRecoveryMode;
        uint256 collChange;
        uint256 currVC;
        uint256 newVC;
        uint256 debt;
        address[] currAssets;
        uint256[] currAmounts;
        address[] newAssets;
        uint256[] newAmounts;
        uint256 oldICR;
        uint256 newICR;
        uint256 newRICR;
        uint256 newTCR;
        uint256 YUSDFee;
        uint256 variableYUSDFee;
        uint256 newDebt;
        uint256 VCin;
        uint256 VCout;
        uint256 maxFeePercentageFactor;
        uint256 entireSystemColl;
        uint256 entireSystemDebt;
    }

    struct OpenTrove_Params {
        uint256 _maxFeePercentage;
        uint256 _YUSDAmount;
        uint256 _totalYUSDDebtFromLever;
        address _upperHint;
        address _lowerHint;
    }

    struct LocalVariables_openTrove {
        uint256 YUSDFee;
        uint256 netDebt;
        uint256 compositeDebt;
        uint256 RICR;
        uint256 ICR;
        uint256 arrayIndex;
        uint256 VC;
        uint256 newTCR;
        uint256 entireSystemColl;
        uint256 entireSystemDebt;
        bool isRecoveryMode;
    }

    struct CloseTrove_Params {
        address[] _collsOut;
        uint256[] _amountsOut;
        uint256[] _maxSlippages;
        bool _isUnlever;
    }

    struct ContractsCache {
        ITroveManager troveManager;
        IActivePool activePool;
        IYUSDToken yusdToken;
        IWhitelist whitelist;
    }

    enum BorrowerOperation {
        openTrove,
        closeTrove,
        adjustTrove
    }

    event TroveCreated(address indexed _borrower, uint256 arrayIndex);
    event TroveUpdated(
        address indexed _borrower,
        uint256 _debt,
        address[] _tokens,
        uint256[] _amounts,
        BorrowerOperation operation
    );
    event YUSDBorrowingFeePaid(address indexed _borrower, uint256 _YUSDFee);



    // --- Dependency setters ---



    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _sortedTrovesAddress,
        address _yusdTokenAddress,
        address _sYETIAddress,
        address _whitelistAddress
    ) external override initializer {

        // This makes impossible to open a trove with zero withdrawn YUSD
        require(MIN_NET_DEBT != 0, "BO:MIN=0");

        deploymentTime = block.timestamp;

        troveManager = ITroveManager(_troveManagerAddress);
        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        whitelist = IWhitelist(_whitelistAddress);
        stabilityPoolAddress = _stabilityPoolAddress;
        gasPoolAddress = _gasPoolAddress;
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        yusdToken = IYUSDToken(_yusdTokenAddress);
        sYETIAddress = _sYETIAddress;


    }

    // --- Borrower Trove Operations ---

    function openTrove(
        uint256 _maxFeePercentage,
        uint256 _YUSDAmount,
        address _upperHint,
        address _lowerHint,
        address[] calldata _colls,
        uint256[] calldata _amounts
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        _requireLengthNonzero(_amounts.length);
        _requireValidDepositCollateral(_colls, _amounts, contractsCache.whitelist);

        // transfer collateral into ActivePool
        _transferCollateralsIntoActivePool(_colls, _amounts);

        OpenTrove_Params memory params = OpenTrove_Params(
            _maxFeePercentage,
            _YUSDAmount,
            0,
            _upperHint,
            _lowerHint
        );
        _openTroveInternal(params, _colls, _amounts, contractsCache);
    }





    // amounts should be a uint array giving the amount of each collateral
    // to be transferred in in order of the current whitelist
    // Should be called *after* collateral has been already sent to the active pool
    // Should confirm _colls, is valid collateral prior to calling this
    function _openTroveInternal(
        OpenTrove_Params memory params,
        address[] memory _colls,
        uint256[] memory _amounts,
        ContractsCache memory contractsCache
    ) internal {
        LocalVariables_openTrove memory vars;

        (vars.isRecoveryMode, vars.entireSystemColl, vars.entireSystemDebt) = _checkRecoveryModeAndSystem();

        _requireValidMaxFeePercentage(params._maxFeePercentage, vars.isRecoveryMode);
        _requireTroveisNotActive(contractsCache.troveManager, msg.sender);

        vars.netDebt = params._YUSDAmount;

        // For every collateral type in, calculate the VC and get the variable fee
        vars.VC = contractsCache.whitelist.getValuesVC(_colls, _amounts);

        if (!vars.isRecoveryMode) {
            // when not in recovery mode, add in the 0.5% fee
            vars.YUSDFee = _triggerBorrowingFee(
                contractsCache.troveManager,
                contractsCache.yusdToken,
                params._YUSDAmount,
                vars.VC, // here it is just VC in, which is always larger than YUSD amount
                params._maxFeePercentage
            );
            params._maxFeePercentage = params._maxFeePercentage.sub(vars.YUSDFee.mul(DECIMAL_PRECISION).div(vars.VC));
        }

        // Add in variable fee. Always present, even in recovery mode.
        vars.YUSDFee = vars.YUSDFee.add(
            _getTotalVariableDepositFee(_colls, _amounts, vars.entireSystemColl, vars.VC, 0, vars.VC, params._maxFeePercentage, contractsCache)
        );

        // Adds total fees to netDebt
        vars.netDebt = vars.netDebt.add(vars.YUSDFee); // The raw debt change includes the fee

        _requireAtLeastMinNetDebt(vars.netDebt);
        // ICR is based on the composite debt, i.e. the requested YUSD amount + YUSD borrowing fee + YUSD gas comp.
        // _getCompositeDebt returns  vars.netDebt + YUSD gas comp.
        vars.compositeDebt = _getCompositeDebt(vars.netDebt);

        vars.ICR = LiquityMath._computeCR(vars.VC, vars.compositeDebt);
        if (vars.isRecoveryMode) {
            _requireICRisAboveCCR(vars.ICR);
        } else {
            _requireICRisAboveMCR(vars.ICR);
            vars.newTCR = _getNewTCRFromTroveChange(vars.entireSystemColl, vars.entireSystemDebt, vars.VC, true, vars.compositeDebt, true); // bools: coll increase, debt increase
            _requireNewTCRisAboveCCR(vars.newTCR);
        }

        // Set the trove struct's properties
        contractsCache.troveManager.setTroveStatus(msg.sender, 1);

        contractsCache.troveManager.updateTroveColl(msg.sender, _colls, _amounts);
        contractsCache.troveManager.increaseTroveDebt(msg.sender, vars.compositeDebt);

        contractsCache.troveManager.updateTroveRewardSnapshots(msg.sender);

        contractsCache.troveManager.updateStakeAndTotalStakes(msg.sender);

        vars.RICR = LiquityMath._computeCR(_getRVC(_colls, _amounts), vars.compositeDebt);

        sortedTroves.insert(msg.sender, vars.RICR, params._upperHint, params._lowerHint);
        vars.arrayIndex = contractsCache.troveManager.addTroveOwnerToArray(msg.sender);
        emit TroveCreated(msg.sender, vars.arrayIndex);

        contractsCache.activePool.receiveCollateral(_colls, _amounts);

        _withdrawYUSD(
            contractsCache.activePool,
            contractsCache.yusdToken,
            msg.sender,
            params._YUSDAmount.sub(params._totalYUSDDebtFromLever),
            vars.netDebt
        );

        // Move the YUSD gas compensation to the Gas Pool
        _withdrawYUSD(
            contractsCache.activePool,
            contractsCache.yusdToken,
            gasPoolAddress,
            YUSD_GAS_COMPENSATION,
            YUSD_GAS_COMPENSATION
        );

        emit TroveUpdated(
            msg.sender,
            vars.compositeDebt,
            _colls,
            _amounts,
            BorrowerOperation.openTrove
        );
        emit YUSDBorrowingFeePaid(msg.sender, vars.YUSDFee);
    }


    // add collateral to trove. Calls _adjustTrove with correct params.
    function addColl(
        address[] calldata _collsIn,
        uint256[] calldata _amountsIn,
        address _upperHint,
        address _lowerHint,
        uint256 _maxFeePercentage
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        AdjustTrove_Params memory params;
        params._collsIn = _collsIn;
        params._amountsIn = _amountsIn;
        params._upperHint = _upperHint;
        params._lowerHint = _lowerHint;
        params._maxFeePercentage = _maxFeePercentage;

        // check that all _collsIn collateral types are in the whitelist
        _requireValidDepositCollateral(_collsIn, _amountsIn, contractsCache.whitelist);

        // pull in deposit collateral
        _transferCollateralsIntoActivePool(_collsIn, _amountsIn);
        _adjustTrove(params, contractsCache);
    }




    // Withdraw collateral from a trove. Calls _adjustTrove with correct params.
    function withdrawColl(
        address[] calldata _collsOut,
        uint256[] calldata _amountsOut,
        address _upperHint,
        address _lowerHint
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        AdjustTrove_Params memory params;
        params._collsOut = _collsOut;
        params._amountsOut = _amountsOut;
        params._upperHint = _upperHint;
        params._lowerHint = _lowerHint;

        // check that all _collsOut collateral types are in the whitelist
        _requireValidDepositCollateral(_collsOut, _amountsOut, contractsCache.whitelist);

        _adjustTrove(params, contractsCache);
    }

    // Withdraw YUSD tokens from a trove: mint new YUSD tokens to the owner, and increase the trove's debt accordingly.
    // Calls _adjustTrove with correct params.
    function withdrawYUSD(
        uint256 _maxFeePercentage,
        uint256 _YUSDAmount,
        address _upperHint,
        address _lowerHint
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        AdjustTrove_Params memory params;
        params._YUSDChange = _YUSDAmount;
        params._maxFeePercentage = _maxFeePercentage;
        params._upperHint = _upperHint;
        params._lowerHint = _lowerHint;
        params._isDebtIncrease = true;
        _adjustTrove(params, contractsCache);
    }

    // Repay YUSD tokens to a Trove: Burn the repaid YUSD tokens, and reduce the trove's debt accordingly.
    // Calls _adjustTrove with correct params.
    function repayYUSD(
        uint256 _YUSDAmount,
        address _upperHint,
        address _lowerHint
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        AdjustTrove_Params memory params;
        params._YUSDChange = _YUSDAmount;
        params._upperHint = _upperHint;
        params._lowerHint = _lowerHint;
        params._isDebtIncrease = false;
        _adjustTrove(params, contractsCache);
    }

    // Adjusts trove with multiple colls in / out. Calls _adjustTrove with correct params.
    function adjustTrove(
        address[] calldata _collsIn,
        uint256[] memory _amountsIn,
        address[] calldata _collsOut,
        uint256[] calldata _amountsOut,
        uint256 _YUSDChange,
        bool _isDebtIncrease,
        address _upperHint,
        address _lowerHint,
        uint256 _maxFeePercentage
    ) external override nonReentrant {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);
        // check that all _collsIn collateral types are in the whitelist
        _requireValidDepositCollateral(_collsIn, _amountsIn, contractsCache.whitelist);
        _requireValidDepositCollateral(_collsOut, _amountsOut, contractsCache.whitelist);
        _requireNoOverlapColls(_collsIn, _collsOut); // check that there are no overlap between _collsIn and _collsOut

        // pull in deposit collateral
        _transferCollateralsIntoActivePool(_collsIn, _amountsIn);

        AdjustTrove_Params memory params = AdjustTrove_Params(
            _collsIn,
            _amountsIn,
            _collsOut,
            _amountsOut,
            new uint256[](0), // max leverages is a 0 array in this case.
            _YUSDChange,
            0,
            _isDebtIncrease,
            false,
            _upperHint,
            _lowerHint,
            _maxFeePercentage
        );

        _adjustTrove(params, contractsCache);
    }

    /*
     * _adjustTrove(): Alongside a debt change, this function can perform either a collateral top-up or a collateral withdrawal.
     * the ith element of _amountsIn and _amountsOut corresponds to the ith element of the addresses _collsIn and _collsOut passed in
     *
     * Should be called after the collsIn has been sent to ActivePool
     */
    function _adjustTrove(AdjustTrove_Params memory params, ContractsCache memory contractsCache) internal {

        LocalVariables_adjustTrove memory vars;

        (vars.isRecoveryMode, vars.entireSystemColl, vars.entireSystemDebt) = _checkRecoveryModeAndSystem();

        if (params._isDebtIncrease) {
            _requireValidMaxFeePercentage(params._maxFeePercentage, vars.isRecoveryMode);
            _requireNonZeroDebtChange(params._YUSDChange);
        }

        // Checks that at least one array is non-empty, and also that at least one value is 1.
        _requireNonZeroAdjustment(params._amountsIn, params._amountsOut, params._YUSDChange);
        _requireTroveisActive(contractsCache.troveManager, msg.sender);

        contractsCache.troveManager.applyPendingRewards(msg.sender);
        vars.netDebtChange = params._YUSDChange;

        vars.VCin = contractsCache.whitelist.getValuesVC(params._collsIn, params._amountsIn);
        vars.VCout = contractsCache.whitelist.getValuesVC(params._collsOut, params._amountsOut);

        if (params._isDebtIncrease) {
            vars.maxFeePercentageFactor = LiquityMath._max(vars.VCin, params._YUSDChange);
        } else {
            vars.maxFeePercentageFactor = vars.VCin;
        }

        // If the adjustment incorporates a debt increase and system is in Normal Mode, then trigger a borrowing fee
        if (params._isDebtIncrease && !vars.isRecoveryMode) {
            vars.YUSDFee = _triggerBorrowingFee(
                contractsCache.troveManager,
                contractsCache.yusdToken,
                params._YUSDChange,
                vars.maxFeePercentageFactor, // max of VC in and YUSD change here to see what the max borrowing fee is triggered on.
                params._maxFeePercentage
            );
            // passed in max fee minus actual fee percent applied so far
            params._maxFeePercentage = params._maxFeePercentage.sub(vars.YUSDFee.mul(DECIMAL_PRECISION).div(vars.maxFeePercentageFactor));
            vars.netDebtChange = vars.netDebtChange.add(vars.YUSDFee); // The raw debt change includes the fee
        }

        // get current portfolio in trove
        (vars.currAssets, vars.currAmounts) = contractsCache.troveManager.getTroveColls(msg.sender);
        // current VC based on current portfolio and latest prices
        vars.currVC = contractsCache.whitelist.getValuesVC(vars.currAssets, vars.currAmounts);

        // get new portfolio in trove after changes. Will error if invalid changes:
        (vars.newAssets, vars.newAmounts) = _getNewPortfolio(
            vars.currAssets,
            vars.currAmounts,
            params._collsIn,
            params._amountsIn,
            params._collsOut,
            params._amountsOut
        );
        // new VC based on new portfolio and latest prices
        vars.newVC = vars.currVC.add(vars.VCin).sub(vars.VCout);

        vars.isCollIncrease = vars.newVC > vars.currVC;
        vars.collChange = 0;
        if (vars.isCollIncrease) {
            vars.collChange = (vars.newVC).sub(vars.currVC);
        } else {
            vars.collChange = (vars.currVC).sub(vars.newVC);
        }

        vars.debt = contractsCache.troveManager.getTroveDebt(msg.sender);

        if (params._collsIn.length != 0) {
            vars.variableYUSDFee = _getTotalVariableDepositFee(
                    params._collsIn,
                    params._amountsIn,
                    vars.entireSystemColl,
                    vars.VCin,
                    vars.VCout,
                    vars.maxFeePercentageFactor,
                    params._maxFeePercentage,
                    contractsCache
            );
        }

        // Get the trove's old ICR before the adjustment, and what its new ICR will be after the adjustment
        vars.oldICR = LiquityMath._computeCR(vars.currVC, vars.debt);

        vars.debt = vars.debt.add(vars.variableYUSDFee);

        vars.newICR = _getNewICRFromTroveChange(vars.newVC,
            vars.debt, // with variableYUSDFee already added.
            vars.netDebtChange,
            params._isDebtIncrease
        );

        // Check the adjustment satisfies all conditions for the current system mode
        _requireValidAdjustmentInCurrentMode(
            params._amountsOut,
            params._isDebtIncrease,
            vars
        );

        // When the adjustment is a debt repayment, check it's a valid amount and that the caller has enough YUSD
        if (!params._isUnlever && !params._isDebtIncrease && params._YUSDChange != 0) {
            _requireAtLeastMinNetDebt(_getNetDebt(vars.debt).sub(vars.netDebtChange));
            _requireValidYUSDRepayment(vars.debt, vars.netDebtChange);
            _requireSufficientYUSDBalance(contractsCache.yusdToken, msg.sender, vars.netDebtChange);
        }

        if (params._collsIn.length != 0) {
            contractsCache.activePool.receiveCollateral(params._collsIn, params._amountsIn);
        }

        vars.newDebt = _updateTroveFromAdjustment(
            contractsCache.troveManager,
            msg.sender,
            vars.newAssets,
            vars.newAmounts,
            vars.netDebtChange,
            params._isDebtIncrease,
            vars.variableYUSDFee
        );

        contractsCache.troveManager.updateStakeAndTotalStakes(msg.sender);

        vars.newRICR = LiquityMath._computeCR(_getRVC(vars.newAssets, vars.newAmounts), vars.newDebt);
        // Re-insert trove in to the sorted list
        sortedTroves.reInsert(msg.sender, vars.newRICR, params._upperHint, params._lowerHint);

        emit TroveUpdated(
            msg.sender,
            vars.newDebt,
            vars.newAssets,
            vars.newAmounts,
            BorrowerOperation.adjustTrove
        );
        emit YUSDBorrowingFeePaid(msg.sender, vars.YUSDFee);



            // Use the unmodified _YUSDChange here, as we don't send the fee to the user
            _moveYUSD(
                contractsCache.activePool,
                contractsCache.yusdToken,
                msg.sender,
                params._YUSDChange.sub(params._totalYUSDDebtFromLever), // 0 in non lever case
                params._isDebtIncrease,
                vars.netDebtChange
            );

            // Additionally move the variable deposit fee to the active pool manually, as it is always an increase in debt
            _withdrawYUSD(
                contractsCache.activePool,
                contractsCache.yusdToken,
                msg.sender,
                0,
                vars.variableYUSDFee
            );

            // transfer withdrawn collateral to msg.sender from ActivePool
            activePool.sendCollateralsUnwrap(msg.sender, msg.sender, params._collsOut, params._amountsOut);

    }



    function closeTrove() external override nonReentrant{
        CloseTrove_Params memory params; // default false
        _closeTrove(params);
    }

    /**
     * Closes trove by applying pending rewards, making sure that the YUSD Balance is sufficient, and transferring the
     * collateral to the owner, and repaying the debt.
     * if it is a unlever, then it will transfer the collaterals / sell before. Otherwise it will just do it last.
     */
    function _closeTrove(
        CloseTrove_Params memory params
        ) internal {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, yusdToken, whitelist);

        _requireTroveisActive(contractsCache.troveManager, msg.sender);
        (bool isRecoveryMode, uint256 entireSystemColl, uint256 entireSystemDebt) = _checkRecoveryModeAndSystem();
        require(!isRecoveryMode, "ClRec");

        contractsCache.troveManager.applyPendingRewards(msg.sender);

        uint256 troveVC = contractsCache.troveManager.getTroveVC(msg.sender); // should get the latest VC
        (address[] memory colls, uint256[] memory amounts) = contractsCache.troveManager.getTroveColls(
            msg.sender
        );
        uint256 debt = contractsCache.troveManager.getTroveDebt(msg.sender);



        // do check after unlever (if applies)
        _requireSufficientYUSDBalance(contractsCache.yusdToken, msg.sender, debt.sub(YUSD_GAS_COMPENSATION));
        uint256 newTCR = _getNewTCRFromTroveChange(entireSystemColl, entireSystemDebt, troveVC, false, debt, false);
        _requireNewTCRisAboveCCR(newTCR);

        contractsCache.troveManager.removeStake(msg.sender);
        contractsCache.troveManager.closeTrove(msg.sender);


        // Burn the repaid YUSD from the user's balance and the gas compensation from the Gas Pool
        _repayYUSD(contractsCache.activePool, contractsCache.yusdToken, msg.sender, debt.sub(YUSD_GAS_COMPENSATION));
        _repayYUSD(contractsCache.activePool, contractsCache.yusdToken, gasPoolAddress, YUSD_GAS_COMPENSATION);

        // Send the collateral back to the user
        // Also sends the rewards

        contractsCache.activePool.sendCollateralsUnwrap(msg.sender, msg.sender, colls, amounts);


        emit TroveUpdated(msg.sender, 0, new address[](0), new uint256[](0), BorrowerOperation.closeTrove);
    }



    // --- Helper functions ---

    /**
     * Gets the variable deposit fee from the whitelist calculation. Multiplies the
     * fee by the vc of the collateral.
     */
    function _getTotalVariableDepositFee(
        address[] memory _tokensIn,
        uint256[] memory _amountsIn,
        uint256 _entireSystemColl,
        uint256 _VCin,
        uint256 _VCout,
        uint256 _maxFeePercentageFactor,
        uint256 _maxFeePercentage,
        ContractsCache memory _contractsCache
    ) internal returns (uint256 YUSDFee) {
        if (_VCin == 0) {
            return 0;
        }
        DepositFeeCalc memory vars;
        // active pool total VC at current state is passed in as _entireSystemColl
        // active pool total VC post adding and removing all collaterals
        vars.activePoolVCPost = _entireSystemColl.add(_VCin).sub(_VCout);
        uint256 tokensLen = _tokensIn.length;
        for (uint256 i; i < tokensLen; ++i) {
            vars.token = _tokensIn[i];
            // VC value of collateral of this type inputted
            vars.collateralInputVC = _contractsCache.whitelist.getValueVC(vars.token, _amountsIn[i]);

            // total value in VC of this collateral in active pool (before adding input)
            vars.systemCollateralVC = _contractsCache.activePool.getCollateralVC(vars.token).add(
                defaultPool.getCollateralVC(vars.token)
            );

            // (collateral VC In) * (Collateral's Fee Given Yeti Protocol Backed by Given Collateral)
            uint256 whitelistFee =
                    _contractsCache.whitelist.getFeeAndUpdate(
                        vars.token,
                        vars.collateralInputVC,
                        vars.systemCollateralVC,
                        _entireSystemColl,
                        vars.activePoolVCPost
                    );

            vars.collateralYUSDFee = vars.collateralInputVC.mul(whitelistFee).div(1e18);

            YUSDFee = YUSDFee.add(vars.collateralYUSDFee);
        }
        _requireUserAcceptsFee(YUSDFee, _maxFeePercentageFactor, _maxFeePercentage);
        _triggerDepositFee(_contractsCache.yusdToken, YUSDFee);
    }

    // Transfer in collateral and send to ActivePool
    // (where collateral is held)
    function _transferCollateralsIntoActivePool(
        address[] memory _colls,
        uint256[] memory _amounts
    ) internal {
        uint256 amountsLen = _amounts.length;
        for (uint256 i; i < amountsLen; ++i) {
            address collAddress = _colls[i];
            uint256 amount = _amounts[i];
            _singleTransferCollateralIntoActivePool(
                collAddress,
                amount
            );
        }
    }

    // does one transfer of collateral into active pool. Checks that it transferred to the active pool correctly.
    function _singleTransferCollateralIntoActivePool(
        address _coll,
        uint256 _amount
    ) internal {
        if (whitelist.isWrapped(_coll)) {
            // If wrapped asset then it wraps it and sends the wrapped version to the active pool,
            // and updates reward balance to the new owner.
            IWAsset(_coll).wrap(_amount, msg.sender, address(activePool), msg.sender);
        } else {
            IERC20(_coll).safeTransferFrom(msg.sender, address(activePool), _amount);
        }
    }

    /**
     * Triggers normal borrowing fee, calculated from base rate and on YUSD amount.
     */
    function _triggerBorrowingFee(
        ITroveManager _troveManager,
        IYUSDToken _yusdToken,
        uint256 _YUSDAmount,
        uint256 _maxFeePercentageFactor,
        uint256 _maxFeePercentage
    ) internal returns (uint256) {
        _troveManager.decayBaseRateFromBorrowing(); // decay the baseRate state variable
        uint256 YUSDFee = _troveManager.getBorrowingFee(_YUSDAmount);

        _requireUserAcceptsFee(YUSDFee, _maxFeePercentageFactor, _maxFeePercentage);

        // Send fee to sYETI contract
        _yusdToken.mint(sYETIAddress, YUSDFee); // todo
        return YUSDFee;
    }

    function _triggerDepositFee(IYUSDToken _yusdToken, uint256 _YUSDFee) internal {
        // Send fee to sYETI contract
        _yusdToken.mint(sYETIAddress, _YUSDFee); // todo
    }

    // Update trove's coll and debt based on whether they increase or decrease
    function _updateTroveFromAdjustment(
        ITroveManager _troveManager,
        address _borrower,
        address[] memory _finalColls,
        uint256[] memory _finalAmounts,
        uint256 _debtChange,
        bool _isDebtIncrease,
        uint256 _variableYUSDFee
    ) internal returns (uint256) {
        uint256 newDebt;
        _troveManager.updateTroveColl(_borrower, _finalColls, _finalAmounts);
        if (_isDebtIncrease) { // if debt increase, increase by both amounts
           newDebt = _troveManager.increaseTroveDebt(_borrower, _debtChange.add(_variableYUSDFee));
        } else {
            if (_debtChange > _variableYUSDFee) { // if debt decrease, and greater than variable fee, decrease
                newDebt = _troveManager.decreaseTroveDebt(_borrower, _debtChange - _variableYUSDFee); // already checked no safemath needed
            } else { // otherwise increase by opposite subtraction
                newDebt = _troveManager.increaseTroveDebt(_borrower, _variableYUSDFee - _debtChange); // already checked no safemath needed
            }
        }

        return newDebt;
    }

    // gets the finalColls and finalAmounts after all deposits and withdrawals have been made
    // this function will error if trying to deposit a collateral that is not in the whitelist
    // or trying to withdraw more collateral of any type that is not in the trove
    function _getNewPortfolio(
        address[] memory _initialTokens,
        uint256[] memory _initialAmounts,
        address[] memory _tokensIn,
        uint256[] memory _amountsIn,
        address[] memory _tokensOut,
        uint256[] memory _amountsOut
    ) internal view returns (address[] memory, uint256[] memory) {

        // Initial Colls + Input Colls
        newColls memory cumulativeIn = _sumColls(
            newColls(_initialTokens, _initialAmounts),
            newColls(_tokensIn,_amountsIn)
        );

        newColls memory newPortfolio = _subColls(cumulativeIn, _tokensOut, _amountsOut);
        return (newPortfolio.tokens, newPortfolio.amounts);
    }

    // Moves the YUSD around based on whether it is an increase or decrease in debt.
    function _moveYUSD(
        IActivePool _activePool,
        IYUSDToken _yusdToken,
        address _borrower,
        uint256 _YUSDChange,
        bool _isDebtIncrease,
        uint256 _netDebtChange
    ) internal {
        if (_isDebtIncrease) {
            _withdrawYUSD(_activePool, _yusdToken, _borrower, _YUSDChange, _netDebtChange);
        } else {
            _repayYUSD(_activePool, _yusdToken, _borrower, _YUSDChange);
        }
    }

    // Issue the specified amount of YUSD to _account and increases the total active debt (_netDebtIncrease potentially includes a YUSDFee)
    function _withdrawYUSD(
        IActivePool _activePool,
        IYUSDToken _yusdToken,
        address _account,
        uint256 _YUSDAmount,
        uint256 _netDebtIncrease
    ) internal {
        _activePool.increaseYUSDDebt(_netDebtIncrease);
        _yusdToken.mint(_account, _YUSDAmount);
    }

    // Burn the specified amount of YUSD from _account and decreases the total active debt
    function _repayYUSD(
        IActivePool _activePool,
        IYUSDToken _yusdToken,
        address _account,
        uint256 _YUSD
    ) internal {
        _activePool.decreaseYUSDDebt(_YUSD);
        _yusdToken.burn(_account, _YUSD);
    }

    // Returns _coll1 minus _tokens and _amounts
    // will error if _tokens include a token not in _coll1.tokens
    function _subColls(newColls memory _coll1, address[] memory _tokens, uint[] memory _amounts)
    internal
    view
    returns (newColls memory finalColls)
    {
        uint256 tokensLen = _tokens.length;
        if (tokensLen == 0) {
            return _coll1;
        }
        uint256 coll1Len = _coll1.tokens.length;

        newColls memory coll3;
        coll3.tokens = whitelist.getValidCollateral();
        uint256 coll3Len = coll3.tokens.length;
        coll3.amounts = new uint256[](coll3Len);
        uint256 n = 0;
        for (uint256 i; i < coll1Len; ++i) {
            if (_coll1.amounts[i] != 0) {
                uint256 tokenIndex = whitelist.getIndex(_coll1.tokens[i]);
                coll3.amounts[tokenIndex] = _coll1.amounts[i];
                n++;
            }
        }
        for (uint256 i; i < tokensLen; ++i) {
            uint256 tokenIndex = whitelist.getIndex(_tokens[i]);
            coll3.amounts[tokenIndex] = coll3.amounts[tokenIndex].sub(_amounts[i]);
            if (coll3.amounts[tokenIndex] == 0) {
                n--;
            }
        }

        address[] memory diffTokens = new address[](n);
        uint256[] memory diffAmounts = new uint256[](n);

        if (n != 0) {
            uint j;
            for (uint i; i < coll3Len; ++i) {
                if (coll3.amounts[i] != 0) {
                    diffTokens[j] = coll3.tokens[i];
                    diffAmounts[j] = coll3.amounts[i];
                    ++j;
                }
            }
        }
        finalColls.tokens = diffTokens;
        finalColls.amounts = diffAmounts;
    }

    // --- 'Require' wrapper functions ---

    // Checks that amounts are nonzero, that the the length of colls and amounts are the same, that the coll is active,
    // and that there is no overlab collateral in the list.
    function _requireValidDepositCollateral(address[] memory _colls, uint256[] memory _amounts, IWhitelist whitelist) internal view {
        uint256 collsLen = _colls.length;
        _requireLengthsEqual(collsLen, _amounts.length);
        for (uint256 i; i < collsLen; ++i) {
            require(whitelist.getIsActive(_colls[i]), "!Coll");
            require(_amounts[i] != 0, "0Amt");
            for (uint256 j = i.add(1); j < collsLen; j++) {
                require(_colls[i] != _colls[j], "OvCol");
            }
        }
    }

    function _requireNoOverlapColls(address[] calldata _colls1, address[] calldata _colls2)
        internal
        pure
    {
        uint256 colls1Len = _colls1.length;
        uint256 colls2Len = _colls2.length;
        for (uint256 i; i < colls1Len; ++i) {
            for (uint256 j; j < colls2Len; j++) {
                require(_colls1[i] != _colls2[j], "2OvCol");
            }
        }
    }

    // Condition of whether amountsIn is 0 amounts, or amountsOut is 0 amounts, is checked in previous call
    // to _requireValidDepositCollateral.
    function _requireNonZeroAdjustment(
        uint256[] memory _amountsIn,
        uint256[] memory _amountsOut,
        uint256 _YUSDChange
    ) internal pure {
        if (_YUSDChange == 0) {
            require(_amountsIn.length != 0 || _amountsOut.length != 0, "0Adj");
        }
    }




    function _requireTroveisActive(ITroveManager _troveManager, address _borrower) internal view {
        require(_troveManager.isTroveActive(_borrower), "TroveInact");
    }

    function _requireTroveisNotActive(ITroveManager _troveManager, address _borrower) internal view {
        require(!_troveManager.isTroveActive(_borrower), "TroveAct");
    }

    function _requireNonZeroDebtChange(uint256 _YUSDChange) internal pure {
        require(_YUSDChange != 0, "NoDebtChg");
    }

    function _requireNoCollWithdrawal(uint256[] memory _amountOut) internal pure {
        uint256 arrLen = _amountOut.length;
        for (uint256 i; i < arrLen; ++i) {
            if (_amountOut[i] != 0) {
                revert("NoCollWRecM");
            }
        }
    }

    // Function require length nonzero, used to save contract size on revert strings.
    function _requireLengthNonzero(uint256 length) internal pure {
        require(length != 0, "Len0");
    }

    // Function require length equal, used to save contract size on revert strings.
    function _requireLengthsEqual(uint256 length1, uint256 length2) internal pure {
        require(length1 == length2, "LenMis");
    }

    function _requireValidAdjustmentInCurrentMode(
        uint256[] memory _collWithdrawal,
        bool _isDebtIncrease,
        LocalVariables_adjustTrove memory _vars
    ) internal pure {
        /*
         *In Recovery Mode, only allow:
         *
         * - Pure collateral top-up
         * - Pure debt repayment
         * - Collateral top-up with debt repayment
         * - A debt increase combined with a collateral top-up which makes the ICR >= 150% and improves the ICR (and by extension improves the TCR).
         *
         * In Normal Mode, ensure:
         *
         * - The new ICR is above MCR
         * - The adjustment won't pull the TCR below CCR
         */
        if (_vars.isRecoveryMode) {
            _requireNoCollWithdrawal(_collWithdrawal);
            if (_isDebtIncrease) {
                _requireICRisAboveCCR(_vars.newICR);
                _requireNewICRisAboveOldICR(_vars.newICR, _vars.oldICR);
            }
        } else {
            // if Normal Mode
            _requireICRisAboveMCR(_vars.newICR);
            _vars.newTCR = _getNewTCRFromTroveChange(
                _vars.entireSystemColl,
                _vars.entireSystemDebt,
                _vars.collChange,
                _vars.isCollIncrease,
                _vars.netDebtChange,
                _isDebtIncrease
            );
            _requireNewTCRisAboveCCR(_vars.newTCR);
        }
    }

    function _requireICRisAboveMCR(uint256 _newICR) internal pure {
        require(
            _newICR >= MCR,
            "ReqICR>MCR"
        );
    }

    function _requireICRisAboveCCR(uint256 _newICR) internal pure {
        require(_newICR >= CCR, "ReqICR>CCR");
    }

    function _requireNewICRisAboveOldICR(uint256 _newICR, uint256 _oldICR) internal pure {
        require(
            _newICR >= _oldICR,
            "RecMode:ICR<oldICR"
        );
    }

    function _requireNewTCRisAboveCCR(uint256 _newTCR) internal pure {
        require(
            _newTCR >= CCR,
            "BO:ReqTCR>CCR"
        );
    }

    function _requireAtLeastMinNetDebt(uint256 _netDebt) internal pure {
        require(
            _netDebt >= MIN_NET_DEBT,
            "nD<2000"
        );
    }

    function _requireValidYUSDRepayment(uint256 _currentDebt, uint256 _debtRepayment) internal pure {
        require(
            _debtRepayment <= _currentDebt.sub(YUSD_GAS_COMPENSATION),
            "YUSDRepay<"
        );
    }

    function _requireSufficientYUSDBalance(
        IYUSDToken _yusdToken,
        address _borrower,
        uint256 _debtRepayment
    ) internal view {
        require(
            _yusdToken.balanceOf(_borrower) >= _debtRepayment,
            "YUSDBal<"
        );
    }

    function _requireValidMaxFeePercentage(uint256 _maxFeePercentage, bool _isRecoveryMode)
        internal
        pure
    {
        // Alwawys require max fee to be less than 100%, and if not in recovery mode then max fee must be greater than 0.5%
        if (_maxFeePercentage > DECIMAL_PRECISION || (!_isRecoveryMode && _maxFeePercentage < BORROWING_FEE_FLOOR)) {
            revert("MaxFee");
        }
    }




    // --- ICR and TCR getters ---

    // Compute the new collateral ratio, considering the change in coll and debt. Assumes 0 pending rewards.
    function _getNewICRFromTroveChange(
        uint256 _newVC,
        uint256 _debt,
        uint256 _debtChange,
        bool _isDebtIncrease
    ) internal pure returns (uint256) {
        uint256 newDebt = _isDebtIncrease ? _debt.add(_debtChange) : _debt.sub(_debtChange);

        uint256 newICR = LiquityMath._computeCR(_newVC, newDebt);
        return newICR;
    }

    function _getNewTCRFromTroveChange(
        uint256 _entireSystemColl,
        uint256 _entireSystemDebt,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _debtChange,
        bool _isDebtIncrease
    ) internal pure returns (uint256) {

        _entireSystemColl = _isCollIncrease ? _entireSystemColl.add(_collChange) : _entireSystemColl.sub(_collChange);
        _entireSystemDebt = _isDebtIncrease ? _entireSystemDebt.add(_debtChange) : _entireSystemDebt.sub(_debtChange);

        uint256 newTCR = LiquityMath._computeCR(_entireSystemColl, _entireSystemDebt);
        return newTCR;
    }

    function getCompositeDebt(uint256 _debt) external pure override returns (uint256) {
        return _getCompositeDebt(_debt);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

// Common interface for the Trove Manager.
interface IBorrowerOperations {

    // --- Events ---

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address  _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event YUSDTokenAddressChanged(address _yusdTokenAddress);
    event SYETIAddressChanged(address _sYETIAddress);

    event TroveCreated(address indexed _borrower, uint arrayIndex);
    event TroveUpdated(address indexed _borrower, uint _debt, uint _coll, uint8 operation);
    event YUSDBorrowingFeePaid(address indexed _borrower, uint _YUSDFee);

    // --- Functions ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _sortedTrovesAddress,
        address _yusdTokenAddress,
        address _sYETIAddress,
        address _whiteListAddress
    ) external;

    function openTrove(uint _maxFeePercentage, uint _YUSDAmount, address _upperHint,
        address _lowerHint,
        address[] calldata _colls,
        uint[] calldata _amounts) external;




    function closeTrove() external;

    function adjustTrove(
        address[] calldata _collsIn,
        uint[] calldata _amountsIn,
        address[] calldata _collsOut,
        uint[] calldata _amountsOut,
        uint _YUSDChange,
        bool _isDebtIncrease,
        address _upperHint,
        address _lowerHint,
        uint _maxFeePercentage) external;

    function addColl(address[] memory _collsIn, uint[] memory _amountsIn, address _upperHint, address _lowerHint, uint _maxFeePercentage) external;


    function withdrawColl(address[] memory _collsOut, uint[] memory _amountsOut, address _upperHint, address _lowerHint) external;


    function withdrawYUSD(uint _maxFeePercentage, uint _YUSDAmount, address _upperHint, address _lowerHint) external;

    function repayYUSD(uint _YUSDAmount, address _upperHint, address _lowerHint) external;



    function getCompositeDebt(uint _debt) external pure returns (uint);


}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./ILiquityBase.sol";
import "./IStabilityPool.sol";
import "./IYUSDToken.sol";
import "./IYETIToken.sol";
import "./ISYETI.sol";
import "./IActivePool.sol";
import "./IDefaultPool.sol";


// Common interface for the Trove Manager.
interface ITroveManager is ILiquityBase {

    // --- Events ---

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event YUSDTokenAddressChanged(address _newYUSDTokenAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event YETITokenAddressChanged(address _yetiTokenAddress);
    event SYETIAddressChanged(address _sYETIAddress);

    event Liquidation(uint liquidatedAmount, uint totalYUSDGasCompensation, 
        address[] totalCollTokens, uint[] totalCollAmounts,
        address[] totalCollGasCompTokens, uint[] totalCollGasCompAmounts);
    event Redemption(uint _attemptedYUSDAmount, uint _actualYUSDAmount, uint YUSDfee, address[] tokens, uint[] amounts);
    event TroveLiquidated(address indexed _borrower, uint _debt, uint _coll, uint8 operation);
    event BaseRateUpdated(uint _baseRate);
    event LastFeeOpTimeUpdated(uint _lastFeeOpTime);
    event TotalStakesUpdated(address token, uint _newTotalStakes);
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);
    event LTermsUpdated(uint _L_ETH, uint _L_YUSDDebt);
    event TroveSnapshotsUpdated(uint _L_ETH, uint _L_YUSDDebt);
    event TroveIndexUpdated(address _borrower, uint _newIndex);

    // --- Functions ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _yusdTokenAddress,
        address _sortedTrovesAddress,
        address _yetiTokenAddress,
        address _sYETIAddress,
        address _whitelistAddress,
        address _troveManagerRedemptionsAddress,
        address _troveManagerLiquidationsAddress
    )
    external;

    function stabilityPool() external view returns (IStabilityPool);
    function yusdToken() external view returns (IYUSDToken);
    function yetiToken() external view returns (IYETIToken);
    function sYETI() external view returns (ISYETI);

    function getTroveOwnersCount() external view returns (uint);

    function getTroveFromTroveOwnersArray(uint _index) external view returns (address);

    function getCurrentICR(address _borrower) external view returns (uint);

    function getCurrentRICR(address _borrower) external view returns (uint);

    function liquidate(address _borrower) external;

    function batchLiquidateTroves(address[] calldata _troveArray, address _liquidator) external;

    function redeemCollateral(
        uint _YUSDAmount,
        uint _YUSDMaxFee,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations
    ) external;

    function updateStakeAndTotalStakes(address _borrower) external;

    function updateTroveCollTMR(address  _borrower, address[] memory addresses, uint[] memory amounts) external;

    function updateTroveRewardSnapshots(address _borrower) external;

    function addTroveOwnerToArray(address _borrower) external returns (uint index);

    function applyPendingRewards(address _borrower) external;

//    function getPendingETHReward(address _borrower) external view returns (uint);
    function getPendingCollRewards(address _borrower) external view returns (address[] memory, uint[] memory);

    function getPendingYUSDDebtReward(address _borrower) external view returns (uint);

     function hasPendingRewards(address _borrower) external view returns (bool);

//    function getEntireDebtAndColl(address _borrower) external view returns (
//        uint debt,
//        uint coll,
//        uint pendingYUSDDebtReward,
//        uint pendingETHReward
//    );

    function closeTrove(address _borrower) external;

    function removeStake(address _borrower) external;

    function removeStakeTMR(address _borrower) external;
    function updateTroveDebt(address _borrower, uint debt) external;

    function getRedemptionRate() external view returns (uint);
    function getRedemptionRateWithDecay() external view returns (uint);

    function getRedemptionFeeWithDecay(uint _ETHDrawn) external view returns (uint);

    function getBorrowingRate() external view returns (uint);
    function getBorrowingRateWithDecay() external view returns (uint);

    function getBorrowingFee(uint YUSDDebt) external view returns (uint);
    function getBorrowingFeeWithDecay(uint _YUSDDebt) external view returns (uint);

    function decayBaseRateFromBorrowing() external;

    function getTroveStatus(address _borrower) external view returns (uint);

    function isTroveActive(address _borrower) external view returns (bool);

    function getTroveStake(address _borrower, address _token) external view returns (uint);

    function getTotalStake(address _token) external view returns (uint);

    function getTroveDebt(address _borrower) external view returns (uint);

    function getL_Coll(address _token) external view returns (uint);

    function getL_YUSD(address _token) external view returns (uint);

    function getRewardSnapshotColl(address _borrower, address _token) external view returns (uint);

    function getRewardSnapshotYUSD(address _borrower, address _token) external view returns (uint);

    // returns the VC value of a trove
    function getTroveVC(address _borrower) external view returns (uint);

    function getTroveColls(address _borrower) external view returns (address[] memory, uint[] memory);

    function getCurrentTroveState(address _borrower) external view returns (address[] memory, uint[] memory, uint);

    function setTroveStatus(address _borrower, uint num) external;

    function updateTroveColl(address _borrower, address[] memory _tokens, uint[] memory _amounts) external;

    function increaseTroveDebt(address _borrower, uint _debtIncrease) external returns (uint);

    function decreaseTroveDebt(address _borrower, uint _collDecrease) external returns (uint);

    function getTCR() external view returns (uint);

    function checkRecoveryMode() external view returns (bool);

    function closeTroveRedemption(address _borrower) external;

    function closeTroveLiquidation(address _borrower) external;

    function removeStakeTLR(address _borrower) external;

    function updateBaseRate(uint newBaseRate) external;

    function calcDecayedBaseRate() external view returns (uint);

    function redistributeDebtAndColl(IActivePool _activePool, IDefaultPool _defaultPool, uint _debt, address[] memory _tokens, uint[] memory _amounts) external;

    function updateSystemSnapshots_excludeCollRemainder(IActivePool _activePool, address[] memory _tokens, uint[] memory _amounts) external;

    function getEntireDebtAndColls(address _borrower) external view
    returns (uint, address[] memory, uint[] memory, uint, address[] memory, uint[] memory);

    function movePendingTroveRewardsToActivePool(IActivePool _activePool, IDefaultPool _defaultPool, uint _YUSD, address[] memory _tokens, uint[] memory _amounts, address _borrower) external;

    function collSurplusUpdate(address _account, address[] memory _tokens, uint[] memory _amounts) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "../Interfaces/IERC20.sol";
import "../Interfaces/IERC2612.sol";

interface IYUSDToken is IERC20, IERC2612 {
    
    // --- Events ---

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);

    event YUSDTokenBalanceUpdated(address _user, uint _amount);

    // --- Functions ---

    function mint(address _account, uint256 _amount) external;

    function burn(address _account, uint256 _amount) external;

    function sendToPool(address _sender,  address poolAddress, uint256 _amount) external;

    function returnFromPool(address poolAddress, address user, uint256 _amount ) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "../Dependencies/YetiCustomBase.sol";
import "./ICollateralReceiver.sol";


interface ICollSurplusPool is ICollateralReceiver {

    // --- Events ---
    
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account);
    event CollateralSent(address _to);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _troveManagerRedemptionsAddress,
        address _activePoolAddress,
        address _whitelistAddress
    ) external;

    function getCollVC() external view returns (uint);

    function getAmountClaimable(address _account, address _collateral) external view returns (uint);

    function getCollateral(address _collateral) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

    function accountSurplus(address _account, address[] memory _tokens, uint[] memory _amounts) external;

    function claimColl(address _account) external;

    function addCollateralType(address _collateral) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

// Common interface for the SortedTroves Doubly Linked List.
interface ISortedTroves {

    // --- Events ---
    
    event SortedTrovesAddressChanged(address _sortedDoublyLLAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _NICR);
    event NodeRemoved(address _id);

    // --- Functions ---
    
    function setParams(uint256 _size, address _TroveManagerAddress, address _borrowerOperationsAddress, address _troveManagerRedemptionsAddress) external;

    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;

    function remove(address _id) external;

    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;

    function contains(address _id) external view returns (bool);

    function isFull() external view returns (bool);

    function isEmpty() external view returns (bool);

    function getSize() external view returns (uint256);

    function getMaxSize() external view returns (uint256);

    function getFirst() external view returns (address);

    function getLast() external view returns (address);

    function getNext(address _id) external view returns (address);

    function getPrev(address _id) external view returns (address);

    function getOldICR(address _id) external view returns (uint256);

    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;


interface IWhitelist {
    function getValidCollateral() view external returns (address[] memory);

    function setAddresses(
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _collSurplusPoolAddress, 
        address _borrowerOperationsAddress
    ) external;

    function getOracle(address _collateral) view external returns (address);
    function getSafetyRatio(address _collateral) view external returns (uint256);
    function getRecoveryRatio(address _collateral) view external returns (uint256);
    function getIsActive(address _collateral) view external returns (bool);
    function getPriceCurve(address _collateral) external view returns (address);
    function getDecimals(address _collateral) external view returns (uint256);
    function getFee(address _collateral, uint _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external view returns (uint256 fee);
    function getFeeAndUpdate(address _collateral, uint _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external returns (uint256 fee);
    function getIndex(address _collateral) external view returns (uint256);
    function isWrapped(address _collateral) external view returns (bool);
    function setDefaultRouter(address _collateral, address _router) external;

    function getValuesVC(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint);
    function getValuesRVC(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint);
    function getValuesVCforTCR(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint VC, uint256 VCforTCR);
    function getValuesUSD(address[] memory _collaterals, uint[] memory _amounts) view external returns (uint256);
    function getValueVC(address _collateral, uint _amount) view external returns (uint);
    function getValueRVC(address _collateral, uint _amount) view external returns (uint);
    function getValueVCforTCR(address _collateral, uint _amount) view external returns (uint VC, uint256 VCforTCR);
    function getValueUSD(address _collateral, uint _amount) view external returns (uint256);
    function getDefaultRouterAddress(address _collateral) external view returns (address);

    function getValidCaller(address _contract) external view returns (address);
    function isValidCaller(address _caller) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

/**
 * Based on the OpenZeppelin IER20 interface:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 *
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;


// Wrapped Asset
interface IWAsset  {

    function wrap(uint _amount, address _from, address _to, address _rewardOwner) external;
    
    function unwrapFor(address _from, address _to, uint amount) external;

    function updateReward(address from, address to, uint amount) external;

    function claimReward(address _to) external;

    function claimRewardFor(address _for) external;

    function getPendingRewards(address _for) external returns (address[] memory, uint[] memory);

    function endTreasuryReward(address _to, uint _amount) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./LiquityMath.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/ILiquityBase.sol";
import "./YetiCustomBase.sol";


/* 
* Base contract for TroveManager, BorrowerOperations and StabilityPool. Contains global system constants and
* common functions. 
*/
contract LiquityBase is ILiquityBase, YetiCustomBase {

    // Minimum collateral ratio for individual troves
    uint constant public MCR = 11e17; // 110%

    // Critical system collateral ratio. If the system's total collateral ratio (TCR) falls below the CCR, Recovery Mode is triggered.
    uint constant public CCR = 15e17; // 150%

    // Amount of YUSD to be locked in gas pool on opening troves
    uint constant public YUSD_GAS_COMPENSATION = 200e18;

    // Minimum amount of net YUSD debt a must have
    uint constant public MIN_NET_DEBT = 1800e18;
    // uint constant public MIN_NET_DEBT = 0; 

    uint constant public BORROWING_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%
    uint constant public REDEMPTION_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%

    IActivePool internal activePool;

    IDefaultPool internal defaultPool;

    // --- Gas compensation functions ---

    // Returns the composite debt (drawn debt + gas compensation) of a trove, for the purpose of ICR calculation
    function _getCompositeDebt(uint _debt) internal pure returns (uint) {
        return _debt.add(YUSD_GAS_COMPENSATION);
    }

    // returns the net debt, which is total debt - gas compensation of a trove
    function _getNetDebt(uint _debt) internal pure returns (uint) {
        return _debt.sub(YUSD_GAS_COMPENSATION);
    }

    // Return the system's Total Virtual Coin Balance
    // Virtual Coins are a way to keep track of the system collateralization given
    // the collateral ratios of each collateral type
    function getEntireSystemColl() public view returns (uint) {
        return activePool.getVCSystem();
    }


    function getEntireSystemDebt() public override view returns (uint) {
        uint activeDebt = activePool.getYUSDDebt();
        uint closedDebt = defaultPool.getYUSDDebt();

        return activeDebt.add(closedDebt);
    }


    function _getICRColls(newColls memory _colls, uint _debt) internal view returns (uint ICR) {
        uint totalVC = _getVCColls(_colls);
        ICR = LiquityMath._computeCR(totalVC, _debt);
    }

    function _getRICRColls(newColls memory _colls, uint _debt) internal view returns (uint RICR) {
        uint totalVC = _getRVCColls(_colls);
        RICR = LiquityMath._computeCR(totalVC, _debt);
    }


    function _getVC(address[] memory _tokens, uint[] memory _amounts) internal view returns (uint totalVC) {
        totalVC = whitelist.getValuesVC(_tokens, _amounts);
    }

    function _getRVC(address[] memory _tokens, uint[] memory _amounts) internal view returns (uint totalRVC) {
        totalRVC = whitelist.getValuesRVC(_tokens, _amounts);
    }


    function _getVCColls(newColls memory _colls) internal view returns (uint totalVC) {
        totalVC = whitelist.getValuesVC(_colls.tokens, _colls.amounts);
    }

    function _getRVCColls(newColls memory _colls) internal view returns (uint totalRVC) {
        totalRVC = whitelist.getValuesRVC(_colls.tokens, _colls.amounts);
    }


    function _getUSDColls(newColls memory _colls) internal view returns (uint totalUSDValue) {
        totalUSDValue = whitelist.getValuesUSD(_colls.tokens, _colls.amounts);
    }


    function _getTCR() internal view returns (uint TCR) {
        (,uint256 entireSystemCollForTCR) = activePool.getVCforTCRSystem();
        uint256 entireSystemDebt = getEntireSystemDebt();
        
        TCR = LiquityMath._computeCR(entireSystemCollForTCR, entireSystemDebt);
    }


    // Returns recovery mode bool as well as entire system coll 
    // Do these together to avoid looping.
    function _checkRecoveryModeAndSystem() internal view returns (bool recMode, uint256 entireSystemColl, uint256 entireSystemDebt) {
        uint256 entireSystemCollForTCR;
        (entireSystemColl, entireSystemCollForTCR) = activePool.getVCforTCRSystem();
        entireSystemDebt = getEntireSystemDebt();
        // Check TCR < CCR
        recMode = LiquityMath._computeCR(entireSystemCollForTCR, entireSystemDebt) < CCR;
    }

    function _checkRecoveryMode() internal view returns (bool) {
        return _getTCR() < CCR;
    }

    // fee and amount are denominated in dollar
    function _requireUserAcceptsFee(uint _fee, uint _amount, uint _maxFeePercentage) internal pure {
        uint feePercentage = _fee.mul(DECIMAL_PRECISION).div(_amount);
        require(feePercentage <= _maxFeePercentage, "Fee > max");
    }

    // checks coll has a nonzero balance of at least one token in coll.tokens
    function _collsIsNonZero(newColls memory _colls) internal pure returns (bool) {
        uint256 tokensLen = _colls.tokens.length;
        for (uint256 i; i < tokensLen; ++i) {
            if (_colls.amounts[i] != 0) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

/**
 * Based on OpenZeppelin's SafeMath:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
 *
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "sub overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "div by 0");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b != 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "mod by 0");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.6.11;

import "../Interfaces/IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length != 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IPriceFeed.sol";


interface ILiquityBase {

    function getEntireSystemDebt() external view returns (uint entireSystemDebt);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./ICollateralReceiver.sol";

/*
 * The Stability Pool holds YUSD tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its YUSD debt gets offset with
 * YUSD in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of YUSD tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a YUSD loss, in proportion to their deposit as a share of total deposits.
 * They also receive an ETH gain, as the ETH collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total YUSD in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / ETH gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 * --- YETI ISSUANCE TO STABILITY POOL DEPOSITORS ---
 *
 * An YETI issuance event occurs at every deposit operation, and every liquidation.
 *
 * Each deposit is tagged with the address of the front end through which it was made.
 *
 * All deposits earn a share of the issued YETI in proportion to the deposit as a share of total deposits. The YETI earned
 * by a given deposit, is split between the depositor and the front end through which the deposit was made, based on the front end's kickbackRate.
 *
 * Please see the system Readme for an overview:
 * https://github.com/liquity/dev/blob/main/README.md#yeti-issuance-to-stability-providers
 */
interface IStabilityPool is ICollateralReceiver {

    // --- Events ---
    
    event StabilityPoolETHBalanceUpdated(uint _newBalance);
    event StabilityPoolYUSDBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event YUSDTokenAddressChanged(address _newYUSDTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event ETHGainWithdrawn(address indexed _depositor, uint _ETH, uint _YUSDLoss);
    event YETIPaidToDepositor(address indexed _depositor, uint _YETI);
    event YETIPaidToFrontEnd(address indexed _frontEnd, uint _YETI);
    event EtherSent(address _to, uint _amount);

    // --- Functions ---

    /*
     * Called only once on init, to set addresses of other Yeti contracts
     * Callable only by owner, renounces ownership at the end
     */
    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _yusdTokenAddress,
        address _sortedTrovesAddress,
        address _communityIssuanceAddress,
        address _whitelistAddress,
        address _troveManagerLiquidationsAddress
    )
        external;

    /*
     * Initial checks:
     * - Frontend is registered or zero address
     * - Sender is not a registered frontend
     * - _amount is not zero
     * ---
     * - Triggers a YETI issuance, based on time passed since the last issuance. The YETI issuance is shared between *all* depositors and front ends
     * - Tags the deposit with the provided front end tag param, if it's a new deposit
     * - Sends depositor's accumulated gains (YETI, ETH) to depositor
     * - Sends the tagged front end's accumulated YETI gains to the tagged front end
     * - Increases deposit and tagged front end's stake, and takes new snapshots for each.
     */
    function provideToSP(uint _amount, address _frontEndTag) external;

    /*
     * Initial checks:
     * - _amount is zero or there are no under collateralized troves left in the system
     * - User has a non zero deposit
     * ---
     * - Triggers a YETI issuance, based on time passed since the last issuance. The YETI issuance is shared between *all* depositors and front ends
     * - Removes the deposit's front end tag if it is a full withdrawal
     * - Sends all depositor's accumulated gains (YETI, ETH) to depositor
     * - Sends the tagged front end's accumulated YETI gains to the tagged front end
     * - Decreases deposit and tagged front end's stake, and takes new snapshots for each.
     *
     * If _amount > userDeposit, the user withdraws all of their compounded deposit.
     */
    function withdrawFromSP(uint _amount) external;


    /*
     * Initial checks:
     * - Frontend (sender) not already registered
     * - User (sender) has no deposit
     * - _kickbackRate is in the range [0, 100%]
     * ---
     * Front end makes a one-time selection of kickback rate upon registering
     */
    function registerFrontEnd(uint _kickbackRate) external;

    /*
     * Initial checks:
     * - Caller is TroveManager
     * ---
     * Cancels out the specified debt against the YUSD contained in the Stability Pool (as far as possible)
     * and transfers the Trove's ETH collateral from ActivePool to StabilityPool.
     * Only called by liquidation functions in the TroveManager.
     */
    function offset(uint _debt, address[] memory _assets, uint[] memory _amountsAdded) external;

//    /*
//     * Returns the total amount of ETH held by the pool, accounted in an internal variable instead of `balance`,
//     * to exclude edge cases like ETH received from a self-destruct.
//     */
//    function getETH() external view returns (uint);
    
     //*
//     * Calculates and returns the total gains a depositor has accumulated 
//     */
    function  getDepositorGains(address _depositor) external view returns (address[] memory assets, uint[] memory amounts);


    /*
     * Returns the total amount of VC held by the pool, accounted for by multipliying the
     * internal balances of collaterals by the price that is found at the time getVC() is called.
     */
    function getVC() external view returns (uint);

    /*
     * Returns YUSD held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
     */
    function getTotalYUSDDeposits() external view returns (uint);

    /*
     * Calculate the YETI gain earned by a deposit since its last snapshots were taken.
     * If not tagged with a front end, the depositor gets a 100% cut of what their deposit earned.
     * Otherwise, their cut of the deposit's earnings is equal to the kickbackRate, set by the front end through
     * which they made their deposit.
     */
    function getDepositorYETIGain(address _depositor) external view returns (uint);

    /*
     * Return the YETI gain earned by the front end.
     */
    function getFrontEndYETIGain(address _frontEnd) external view returns (uint);

    /*
     * Return the user's compounded deposit.
     */
    function getCompoundedYUSDDeposit(address _depositor) external view returns (uint);

    /*
     * Return the front end's compounded stake.
     *
     * The front end's compounded stake is equal to the sum of its depositors' compounded deposits.
     */
    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint);

    /*
     * Add collateral type to totalColl 
     */
    function addCollateralType(address _collateral) external;

    function getDepositSnapshotS(address depositor, address collateral) external view returns (uint);

    function getCollateral(address _collateral) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IERC20.sol";
import "./IERC2612.sol";

interface IYETIToken is IERC20, IERC2612 {

    function sendToSYETI(address _sender, uint256 _amount) external;

    function getDeploymentStartTime() external view returns (uint256);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface ISYETI {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function mint(uint256 amount) external returns (bool);
    function burn(address to, uint256 shares) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IPool.sol";

    
interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolYUSDDebtUpdated(uint _YUSDDebt);
    event ActivePoolCollateralBalanceUpdated(address _collateral, uint _amount);

    // --- Functions ---
    
    function sendCollaterals(address _to, address[] memory _tokens, uint[] memory _amounts) external;
    function sendCollateralsUnwrap(
        address _from,
        address _to,
        address[] memory _tokens,
        uint[] memory _amounts) external;

    function sendSingleCollateral(address _to, address _token, uint256 _amount) external;

    function sendSingleCollateralUnwrap(address _from, address _to, address _token, uint256 _amount) external;

    function getCollateralVC(address collateralAddress) external view returns (uint);
    function addCollateralType(address _collateral) external;

    function getVCSystem() external view returns (uint256 totalVCSystem);

    function getVCforTCRSystem() external view returns (uint256 totalVC, uint256 totalVCforTCR);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./IPool.sol";

interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolYUSDDebtUpdated(uint _YUSDDebt);
    event DefaultPoolETHBalanceUpdated(uint _ETH);

    // --- Functions ---
    
    function sendCollsToActivePool(address[] memory _collaterals, uint[] memory _amounts, address _borrower) external;
    function addCollateralType(address _collateral) external;
    function getCollateralVC(address collateralAddress) external view returns (uint);

    function getAllAmounts() external view returns (uint256[] memory);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IPriceFeed {

    // --- Events ---
    event LastGoodPriceUpdated(uint _lastGoodPrice);

    // --- Function ---
    // function fetchPrice() external returns (uint);

    function fetchPrice_v() view external returns (uint);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface ICollateralReceiver {
    function receiveCollateral(address[] memory _tokens, uint[] memory _amounts) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

/**
 * @dev Interface of the ERC2612 standard as defined in the EIP.
 *
 * Adds the {permit} method, which can be used to change one's
 * {IERC20-allowance} without having to send a transaction, by signing a
 * message. This allows users to spend tokens without having to hold Ether.
 *
 * See https://eips.ethereum.org/EIPS/eip-2612.
 * 
 * Code adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/
 */
interface IERC2612 {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 amount, 
                    uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases `owner`'s nonce by one. This
     * prevents a signature from being used multiple times.
     *
     * `owner` can limit the time a Permit is valid for by setting `deadline` to 
     * a value in the near future. The deadline argument can be set to uint(-1) to 
     * create Permits that effectively never expire.
     */
    function nonces(address owner) external view returns (uint256);
    
    function version() external view returns (string memory);
    function permitTypeHash() external view returns (bytes32);
    function domainSeparator() external view returns (bytes32);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./ICollateralReceiver.sol";

// Common interface for the Pools.
interface IPool is ICollateralReceiver {
    
    // --- Events ---
    
    event ETHBalanceUpdated(uint _newBalance);
    event YUSDBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event WhitelistAddressChanged(address _newWhitelistAddress);
    event EtherSent(address _to, uint _amount);
    event CollateralSent(address _collateral, address _to, uint _amount);

    // --- Functions ---

    function getVC() external view returns (uint totalVC);

    function getVCforTCR() external view returns (uint totalVC, uint totalVCforTCR);

    function getCollateral(address collateralAddress) external view returns (uint);

    function getAllCollateral() external view returns (address[] memory, uint256[] memory);

    function getYUSDDebt() external view returns (uint);

    function increaseYUSDDebt(uint _amount) external;

    function decreaseYUSDDebt(uint _amount) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./BaseMath.sol";
import "./SafeMath.sol";
import "../Interfaces/IERC20.sol";
import "../Interfaces/IWhitelist.sol";


contract YetiCustomBase is BaseMath {
    using SafeMath for uint256;

    IWhitelist whitelist;

    struct newColls {
        // tokens and amounts should be the same length
        address[] tokens;
        uint256[] amounts;
    }

    // Collateral math

    // gets the sum of _coll1 and _coll2
    function _sumColls(newColls memory _coll1, newColls memory _coll2)
        internal
        view
        returns (newColls memory finalColls)
    {
        uint256 coll2Len = _coll2.tokens.length;
        if (coll2Len == 0) {
            return _coll1;
        }
        newColls memory coll3;

        coll3.tokens = whitelist.getValidCollateral();
        uint256 coll1Len = _coll1.tokens.length;
        uint256 coll3Len = coll3.tokens.length;
        coll3.amounts = new uint256[](coll3Len);

        uint256 n;
        for (uint256 i; i < coll1Len; ++i) {
            uint256 tokenIndex = whitelist.getIndex(_coll1.tokens[i]);
            if (_coll1.amounts[i] != 0) {
                n++;
                coll3.amounts[tokenIndex] = _coll1.amounts[i];
            }
        }

        for (uint256 i; i < coll2Len; ++i) {
            uint256 tokenIndex = whitelist.getIndex(_coll2.tokens[i]);
            if (_coll2.amounts[i] != 0) {
                if (coll3.amounts[tokenIndex] == 0) {
                    coll3.amounts[tokenIndex] = _coll2.amounts[i];
                    n++;
                } else {
                    coll3.amounts[tokenIndex] = coll3.amounts[tokenIndex].add(_coll2.amounts[i]);
                }
            }
        }

        address[] memory sumTokens = new address[](n);
        uint256[] memory sumAmounts = new uint256[](n);
        uint256 j;

        // should only find n amounts over 0
        for (uint256 i; i < coll3Len; ++i) {
            if (coll3.amounts[i] != 0) {
                sumTokens[j] = coll3.tokens[i];
                sumAmounts[j] = coll3.amounts[i];
                j++;
            }
        }
        finalColls.tokens = sumTokens;
        finalColls.amounts = sumAmounts;
    }


    function _getArrayCopy(uint[] memory _arr) internal pure returns (uint[] memory){
        uint256 arrLen = _arr.length;
        uint[] memory copy = new uint[](arrLen);
        for (uint256 i; i < arrLen; ++i) {
            copy[i] = _arr[i];
        }
        return copy;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.11;


contract BaseMath {
    uint constant public DECIMAL_PRECISION = 1e18;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

import "./SafeMath.sol";

library LiquityMath {
    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;
    uint internal constant HALF_DECIMAL_PRECISION = 5e17;

    function _min(uint _a, uint _b) internal pure returns (uint) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a : _b;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint x, uint y) internal pure returns (uint decProd) {
        uint prod_xy = x.mul(y);

        decProd = prod_xy.add(HALF_DECIMAL_PRECISION).div(DECIMAL_PRECISION);
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by two functions that represent time in units of minutes:
    * 1) TroveManager._calcDecayedBaseRate
    * 2) CommunityIssuance._getCumulativeIssuanceFraction 
    * 
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {
       
        if (_minutes > 5256e5) {_minutes = 5256e5;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n.div(2);
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n.sub(1)).div(2);
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a.sub(_b) : _b.sub(_a);
    }

    //  _coll should be the amount of VC and _debt is debt of YUSD\
    // new collateral ratio is 10**18 times the collateral ratio. (150% => 1.5e18)
    function _computeCR(uint _coll, uint _debt) internal pure returns (uint) {
        if (_debt != 0) {
            uint newCollRatio = _coll.mul(1e18).div(_debt);
            return newCollRatio;
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return 2**256 - 1; 
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size != 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length != 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}