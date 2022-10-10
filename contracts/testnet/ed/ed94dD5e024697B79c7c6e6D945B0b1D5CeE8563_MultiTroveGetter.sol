// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./TroveManager.sol";
import "./SortedTroves.sol";
import "./Dependencies/Whitelist.sol";

/*  Helper contract for grabbing Trove data for the front end. Not part of the core Liquity system. */
contract MultiTroveGetter {
    struct CombinedTroveData {
        address owner;

        uint debt;
        address[] colls;
        uint[] amounts;

        address[] allColls;
        uint[] stakeAmounts;
        uint[] snapshotAmounts;
        uint[] snapshotYUSDDebts;
    }

    TroveManager public troveManager; // XXX Troves missing from ITroveManager?
    ISortedTroves public sortedTroves;
    IWhitelist public whitelist;

    constructor(TroveManager _troveManager, ISortedTroves _sortedTroves, IWhitelist _whitelist) public {
        troveManager = _troveManager;
        sortedTroves = _sortedTroves;
        whitelist = _whitelist;
    }

    function getMultipleSortedTroves(int _startIdx, uint _count)
        external view returns (CombinedTroveData[] memory _troves)
    {
        uint startIdx;
        bool descend;

        if (_startIdx >= 0) {
            startIdx = uint(_startIdx);
            descend = true;
        } else {
            startIdx = uint(-(_startIdx + 1));
            descend = false;
        }

        uint sortedTrovesSize = sortedTroves.getSize();

        if (startIdx >= sortedTrovesSize) {
            _troves = new CombinedTroveData[](0);
        } else {
            uint maxCount = sortedTrovesSize - startIdx;

            if (_count > maxCount) {
                _count = maxCount;
            }

            if (descend) {
                _troves = _getMultipleSortedTrovesFromHead(startIdx, _count);
            } else {
                _troves = _getMultipleSortedTrovesFromTail(startIdx, _count);
            }
        }
    }

    function _getMultipleSortedTrovesFromHead(uint _startIdx, uint _count)
        internal view returns (CombinedTroveData[] memory _troves)
    {
        address currentTroveowner = sortedTroves.getFirst();

        for (uint idx = 0; idx < _startIdx; ++idx) {
            currentTroveowner = sortedTroves.getNext(currentTroveowner);
        }

        _troves = new CombinedTroveData[](_count);

        for (uint idx = 0; idx < _count; ++idx) {
            _troves[idx] = _getCombinedTroveData(currentTroveowner);
            currentTroveowner = sortedTroves.getNext(currentTroveowner);
        }
    }

    function _getMultipleSortedTrovesFromTail(uint _startIdx, uint _count)
        internal view returns (CombinedTroveData[] memory _troves)
    {
        address currentTroveowner = sortedTroves.getLast();

        for (uint idx = 0; idx < _startIdx; ++idx) {
            currentTroveowner = sortedTroves.getPrev(currentTroveowner);
        }

        _troves = new CombinedTroveData[](_count);

        for (uint idx = 0; idx < _count; ++idx) {
            _troves[idx] = _getCombinedTroveData(currentTroveowner);
            currentTroveowner = sortedTroves.getPrev(currentTroveowner);
        }
    }

    function _getCombinedTroveData(address _troveOwner) internal view returns (CombinedTroveData memory data) {
        data.owner = _troveOwner;
        data.debt = troveManager.getTroveDebt(_troveOwner);
        (data.colls, data.amounts) = troveManager.getTroveColls(_troveOwner);

        data.allColls = whitelist.getValidCollateral();
        data.stakeAmounts = new uint[](data.allColls.length);
        data.snapshotAmounts = new uint[](data.allColls.length);
        uint256 collsLen = data.allColls.length;
        for (uint256 i; i < collsLen; ++i) {
            address token = data.allColls[i];

            data.stakeAmounts[i] = troveManager.getTroveStake(_troveOwner, token);
            data.snapshotAmounts[i] = troveManager.getRewardSnapshotColl(_troveOwner, token);
            data.snapshotYUSDDebts[i] = troveManager.getRewardSnapshotYUSD(_troveOwner, token);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IStabilityPool.sol";
import "./Interfaces/ICollSurplusPool.sol";
import "./Interfaces/IYUSDToken.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Interfaces/IYETIToken.sol";
import "./Interfaces/ISYETI.sol";
import "./Interfaces/IWhitelist.sol";
import "./Interfaces/ITroveManagerLiquidations.sol";
import "./Interfaces/ITroveManagerRedemptions.sol";
import "./Interfaces/IERC20.sol";
import "./Dependencies/TroveManagerBase.sol";


/** 
 * Trove Manager is the contract which deals with the state of a user's trove. It has all the 
 * external functions for liquidations, redemptions, as well as functions called by 
 * BorrowerOperations function calls. 
 */

contract TroveManager is TroveManagerBase, ITroveManager, ReentrancyGuardUpgradeable {
    
    address internal borrowerOperationsAddress;

    IStabilityPool internal stabilityPoolContract;

    ITroveManager internal troveManager;

    IYUSDToken internal yusdTokenContract;

    IYETIToken internal yetiTokenContract;

    ISYETI internal sYETIContract;

    ITroveManagerRedemptions internal troveManagerRedemptions;

    ITroveManagerLiquidations internal troveManagerLiquidations;

    address internal gasPoolAddress;
    address internal troveManagerRedemptionsAddress;
    address internal troveManagerLiquidationsAddress;

    ISortedTroves internal sortedTroves;

    ICollSurplusPool internal collSurplusPool;

    bytes32 constant public NAME = "TroveManager";

    // --- Data structures ---

    uint constant internal SECONDS_IN_ONE_MINUTE = 60;

    /*
     * Half-life of 12h. 12h = 720 min
     * (1/2) = d^720 => d = (1/2)^(1/720)
     */
    uint constant public MINUTE_DECAY_FACTOR = 999037758833783000;
    uint constant public MAX_BORROWING_FEE = DECIMAL_PRECISION / 100 * 5; // 5%

    // During bootsrap period redemptions are not allowed
    uint constant public BOOTSTRAP_PERIOD = 14 days;

    uint public baseRate;

    // The timestamp of the latest fee operation (redemption or new YUSD issuance)
    uint public lastFeeOperationTime;

    mapping (address => Trove) Troves;

    // uint public totalStakes;
    mapping (address => uint) public totalStakes;

    // Snapshot of the value of totalStakes, taken immediately after the latest liquidation
    mapping (address => uint) public totalStakesSnapshot;

    // Snapshot of the total collateral across the ActivePool and DefaultPool, immediately after the latest liquidation.
    mapping (address => uint) public totalCollateralSnapshot;

    /*
    * L_Coll and L_YUSDDebt track the sums of accumulated liquidation rewards per unit staked. Each collateral type has 
    * its own L_Coll and L_YUSDDebt.
    * During its lifetime, each stake earns:
    *
    * A Collateral gain of ( stake * [L_Coll[coll] - L_Coll[coll](0)] )
    * A YUSDDebt increase  of ( stake * [L_YUSDDebt - L_YUSDDebt(0)] )
    *
    * Where L_Coll[coll](0) and L_YUSDDebt(0) are snapshots of L_Coll[coll] and L_YUSDDebt for the active Trove taken at the instant the stake was made
    */
    mapping (address => uint) private L_Coll;
    mapping (address => uint) public L_YUSDDebt;

    // Map addresses with active troves to their RewardSnapshot
    mapping (address => RewardSnapshot) rewardSnapshots;

    // Object containing the reward snapshots for a given active trove
    struct RewardSnapshot {
        mapping(address => uint) CollRewards;
        mapping(address => uint) YUSDDebts;
    }

    // Array of all active trove addresses - used to to compute an approximate hint off-chain, for the sorted list insertion
    address[] private TroveOwners;

    // Error trackers for the trove redistribution calculation
    mapping (address => uint) public lastCollError_Redistribution;
    mapping (address => uint) public lastYUSDDebtError_Redistribution;

    /*
    * --- Variable container structs for liquidations ---
    *
    * These structs are used to hold, return and assign variables inside the liquidation functions,
    * in order to avoid the error: "CompilerError: Stack too deep".
    **/

    // --- Events ---

    event BaseRateUpdated(uint _baseRate);
    event LastFeeOpTimeUpdated(uint _lastFeeOpTime);
    event TotalStakesUpdated(address token, uint _newTotalStakes);
    event SystemSnapshotsUpdated(uint _unix);

    event Liquidation(uint liquidatedAmount, uint totalYUSDGasCompensation, 
        address[] totalCollTokens, uint[] totalCollAmounts,
        address[] totalCollGasCompTokens, uint[] totalCollGasCompAmounts);

    event LTermsUpdated(address _Coll_Address, uint _L_Coll, uint _L_YUSDDebt);
    event TroveSnapshotsUpdated(uint _unix);
    event TroveIndexUpdated(address _borrower, uint _newIndex);
    event TroveUpdated(address indexed _borrower, uint _debt, address[] _tokens, uint[] _amounts, TroveManagerOperation operation);

    function setUp() external {
		__Ownable_init();
	}

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
    external
    override
    onlyOwner
    {

        borrowerOperationsAddress = _borrowerOperationsAddress;
        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        stabilityPoolContract = IStabilityPool(_stabilityPoolAddress);
        whitelist = IWhitelist(_whitelistAddress);
        gasPoolAddress = _gasPoolAddress;
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        yusdTokenContract = IYUSDToken(_yusdTokenAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        yetiTokenContract = IYETIToken(_yetiTokenAddress);
        sYETIContract = ISYETI(_sYETIAddress);

        troveManagerRedemptionsAddress = _troveManagerRedemptionsAddress;
        troveManagerLiquidationsAddress = _troveManagerLiquidationsAddress;
        troveManagerRedemptions = ITroveManagerRedemptions(_troveManagerRedemptionsAddress);
        troveManagerLiquidations = ITroveManagerLiquidations(_troveManagerLiquidationsAddress);
        renounceOwnership();
    }

    // --- Getters ---

    function getTroveOwnersCount() external view override returns (uint) {
        return TroveOwners.length;
    }

    function getTroveFromTroveOwnersArray(uint _index) external view override returns (address) {
        return TroveOwners[_index];
    }

    // --- Trove Liquidation functions ---

    // Single liquidation function. Closes the trove if its ICR is lower than the minimum collateral ratio.
    function liquidate(address _borrower) external override nonReentrant {
        _requireTroveIsActive(_borrower);

        address[] memory borrowers = new address[](1);
        borrowers[0] = _borrower;
        troveManagerLiquidations.batchLiquidateTroves(borrowers, msg.sender);
    }

    /*
    * Attempt to liquidate a custom list of troves provided by the caller.
    */
    function batchLiquidateTroves(address[] memory _troveArray, address _liquidator) external override nonReentrant {
        troveManagerLiquidations.batchLiquidateTroves(_troveArray, _liquidator);
    }

    // --- Liquidation helper functions ---

    /*
    * This function is called only by TroveManagerLiquidations.sol during a liquidation in recovery mode where
    * the trove has TCR > ICR >= MCR. In this case, the liquidation occurs. 110% of the debt in
    * collateral is sent to the stability pool and any surplus is sent to the collateral surplus pool
    */
    function collSurplusUpdate(address _account, address[] memory _tokens, uint[] memory _amounts) external override {
        _requireCallerIsTML();
        collSurplusPool.accountSurplus(_account, _tokens, _amounts);
    }

    // Move a Trove's pending debt and collateral rewards from distributions, from the Default Pool to the Active Pool
    function movePendingTroveRewardsToActivePool(IActivePool _activePool, IDefaultPool _defaultPool, uint _YUSD, address[] memory _tokens, uint[] memory _amounts, address _borrower) external override {
        _requireCallerIsTML();
        _movePendingTroveRewardsToActivePool(_activePool, _defaultPool, _YUSD, _tokens, _amounts, _borrower);
    }

    function _movePendingTroveRewardsToActivePool(IActivePool _activePool, IDefaultPool _defaultPool, uint _YUSD, address[] memory _tokens, uint[] memory _amounts, address _borrower) internal {
        _defaultPool.decreaseYUSDDebt(_YUSD);
        _activePool.increaseYUSDDebt(_YUSD);
        _defaultPool.sendCollsToActivePool(_tokens, _amounts, _borrower);
    }

    // Update position of given trove
    function _updateTrove(address _borrower, address _lowerHint, address _upperHint) internal {
        (uint debt, address[] memory tokens, uint[] memory amounts, , , ) = getEntireDebtAndColls(_borrower);

        newColls memory troveColl;
        troveColl.tokens = tokens;
        troveColl.amounts = amounts;

        uint RICR = _getRICRColls(troveColl, debt);
        sortedTroves.reInsert(_borrower, RICR, _lowerHint, _upperHint); 
    }

    // Update position for a set of troves using latest price data. This can be called by anyone.
    // Yeti Finance will also be running a bot to assist with keeping the list from becoming
    // too stale.
    function updateTroves(address[] calldata _borrowers, address[] calldata _lowerHints, address[] calldata _upperHints) external {
        uint lowerHintsLen = _lowerHints.length;
        require(_borrowers.length == lowerHintsLen, "TM: borrowers length mismatch");
        require(lowerHintsLen == _upperHints.length, "TM: hints length mismatch");

        for (uint256 i; i < lowerHintsLen; ++i) {
            _updateTrove(_borrowers[i], _lowerHints[i], _upperHints[i]);
        }
    }

    /* Send _YUSDamount YUSD to the system and redeem the corresponding amount of collateral from as many Troves as are needed to fill the redemption
    * request.  Applies pending rewards to a Trove before reducing its debt and coll.
    *
    * Note that if _amount is very large, this function can run out of gas, specially if traversed troves are small. This can be easily avoided by
    * splitting the total _amount in appropriate chunks and calling the function multiple times.
    *
    * Param `_maxIterations` can also be provided, so the loop through Troves is capped (if it’s zero, it will be ignored).This makes it easier to
    * avoid OOG for the frontend, as only knowing approximately the average cost of an iteration is enough, without needing to know the “topology”
    * of the trove list. It also avoids the need to set the cap in stone in the contract, nor doing gas calculations, as both gas price and opcode
    * costs can vary.
    *
    * All Troves that are redeemed from -- with the likely exception of the last one -- will end up with no debt left, therefore they will be closed.
    * If the last Trove does have some remaining debt, it has a finite ICR, and the reinsertion could be anywhere in the list, therefore it requires a hint.
    * A frontend should use getRedemptionHints() to calculate what the ICR of this Trove will be after redemption, and pass a hint for its position
    * in the sortedTroves list along with the ICR value that the hint was found for.
    *
    * If another transaction modifies the list between calling getRedemptionHints() and passing the hints to redeemCollateral(), it
    * is very likely that the last (partially) redeemed Trove would end up with a different ICR than what the hint is for. In this case the
    * redemption will stop after the last completely redeemed Trove and the sender will keep the remaining YUSD amount, which they can attempt
    * to redeem later.
    */
    function redeemCollateral(
        uint _YUSDamount,
        uint _YUSDMaxFee,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintICR,
        uint _maxIterations
    )
    external
    override
    nonReentrant
    {
        troveManagerRedemptions.redeemCollateral(
            _YUSDamount,
            _YUSDMaxFee,
            _firstRedemptionHint,
            _upperPartialRedemptionHint,
            _lowerPartialRedemptionHint,
            _partialRedemptionHintICR,
            _maxIterations,
            msg.sender);
    }

    // --- Helper functions ---

    // Return the current individual collateral ratio (ICR) of a given Trove.
    // Takes a trove's pending coll and debt rewards from redistributions into account.
    function getCurrentICR(address _borrower) external view override returns (uint ICR) {
        (newColls memory colls, uint currentYUSDDebt) = _getCurrentTroveState(_borrower);

        ICR = _getICRColls(colls, currentYUSDDebt);
    }

    // Return the current recovery individual collateral ratio (ICR) of a given Trove.
    // Takes a trove's pending coll and debt rewards from redistributions into account.
    function getCurrentRICR(address _borrower) external view override returns (uint RICR) {
        (newColls memory colls, uint currentYUSDDebt) = _getCurrentTroveState(_borrower);

        RICR = _getRICRColls(colls, currentYUSDDebt);
    }

    // Gets current trove state as colls and debt. 
    function _getCurrentTroveState(address _borrower) internal view
    returns (newColls memory colls, uint YUSDdebt) {
        newColls memory pendingCollReward = _getPendingCollRewards(_borrower);
        uint pendingYUSDDebtReward = getPendingYUSDDebtReward(_borrower);
        
        YUSDdebt = Troves[_borrower].debt.add(pendingYUSDDebtReward);
        colls = _sumColls(Troves[_borrower].colls, pendingCollReward);
    }

    // Add the borrowers's coll and debt rewards earned from redistributions, to their Trove
    function applyPendingRewards(address _borrower) external override {
        _requireCallerIsBOorTMR();
        return _applyPendingRewards(activePool, defaultPool, _borrower);
    }

    // Add the borrowers's coll and debt rewards earned from redistributions, to their Trove
    function _applyPendingRewards(IActivePool _activePool, IDefaultPool _defaultPool, address _borrower) internal {
        if (hasPendingRewards(_borrower)) {
            _requireTroveIsActive(_borrower);

            // Compute pending collateral rewards
            newColls memory pendingCollReward = _getPendingCollRewards(_borrower);
            uint pendingYUSDDebtReward = getPendingYUSDDebtReward(_borrower);

            // Apply pending rewards to trove's state
            Troves[_borrower].colls = _sumColls(Troves[_borrower].colls, pendingCollReward);
            Troves[_borrower].debt = Troves[_borrower].debt.add(pendingYUSDDebtReward);

            _updateTroveRewardSnapshots(_borrower);

            // Transfer from DefaultPool to ActivePool
            _movePendingTroveRewardsToActivePool(_activePool, _defaultPool, pendingYUSDDebtReward, pendingCollReward.tokens, pendingCollReward.amounts, _borrower);

            emit TroveUpdated(
                _borrower,
                Troves[_borrower].debt,
                Troves[_borrower].colls.tokens,
                Troves[_borrower].colls.amounts,
                TroveManagerOperation.applyPendingRewards
            );
        }
    }

    // Update borrower's snapshots of L_Coll and L_YUSDDebt to reflect the current values
    function updateTroveRewardSnapshots(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        _updateTroveRewardSnapshots(_borrower);
    }

    function _updateTroveRewardSnapshots(address _borrower) internal {
        address[] memory allColls = Troves[_borrower].colls.tokens;
        uint256 allCollsLen = allColls.length;
        for (uint256 i; i < allCollsLen; ++i) {
            address asset = allColls[i];
            rewardSnapshots[_borrower].CollRewards[asset] = L_Coll[asset];
            rewardSnapshots[_borrower].YUSDDebts[asset] = L_YUSDDebt[asset];
        }
        emit TroveSnapshotsUpdated(block.timestamp);
    }

    // Get the borrower's pending accumulated Coll rewards, earned by their stake
    // Returned tokens and amounts are the length of whitelist.getValidCollateral();;
    function getPendingCollRewards(address _borrower) override external view returns (address[] memory, uint[] memory) {
        newColls memory pendingCollRewards = _getPendingCollRewards(_borrower);
        return (pendingCollRewards.tokens, pendingCollRewards.amounts);
    }

    // Get the borrower's pending accumulated Coll rewards, earned by their stake
    function _getPendingCollRewards(address _borrower) internal view returns (newColls memory pendingCollRewards) {
        if (Troves[_borrower].status != Status.active) {
            newColls memory emptyColls;
            return emptyColls;
        }

        address[] memory allColls = Troves[_borrower].colls.tokens;
        pendingCollRewards.amounts = new uint[](allColls.length);
        pendingCollRewards.tokens = allColls;
        uint256 allCollsLen = allColls.length;
        for (uint256 i; i < allCollsLen; ++i) {
            address coll = allColls[i];
            uint snapshotCollReward = rewardSnapshots[_borrower].CollRewards[coll];
            uint rewardPerUnitStaked = L_Coll[coll].sub(snapshotCollReward);
            if ( rewardPerUnitStaked == 0) {
                pendingCollRewards.amounts[i] = 0;
                continue; }

            uint stake = Troves[_borrower].stakes[coll];
            uint dec = IERC20(coll).decimals();
            uint assetCollReward = stake.mul(rewardPerUnitStaked).div(10 ** dec);
            pendingCollRewards.amounts[i] = assetCollReward; // i is correct index here
        }
    }

    // Get the borrower's pending accumulated YUSD reward, earned by their stake
    function getPendingYUSDDebtReward(address _borrower) public view override returns (uint pendingYUSDDebtReward) {
        if (Troves[_borrower].status != Status.active) {
            return 0;
        }
        address[] memory allColls = Troves[_borrower].colls.tokens;

        uint256 allCollsLen = allColls.length;
        for (uint256 i; i < allCollsLen; ++i) {
            address coll = allColls[i];
            uint snapshotYUSDDebt = rewardSnapshots[_borrower].YUSDDebts[coll];
            uint rewardPerUnitStaked = L_YUSDDebt[allColls[i]].sub(snapshotYUSDDebt);
            if ( rewardPerUnitStaked == 0) { continue; }

            uint stake =  Troves[_borrower].stakes[coll];

            uint assetYUSDDebtReward = stake.mul(rewardPerUnitStaked).div(DECIMAL_PRECISION);
            pendingYUSDDebtReward = pendingYUSDDebtReward.add(assetYUSDDebtReward);
        }
    }

    function hasPendingRewards(address _borrower) public view override returns (bool) {
        /*
        * A Trove has pending rewards if its snapshot is less than the current rewards per-unit-staked sum:
        * this indicates that rewards have occured since the snapshot was made, and the user therefore has
        * pending rewards
        */
        if (Troves[_borrower].status != Status.active) {return false;}
        address[] memory assets =  Troves[_borrower].colls.tokens;
        uint256 assetsLen = assets.length;
        for (uint256 i; i < assetsLen; ++i) {
            address token = assets[i];
            if (rewardSnapshots[_borrower].CollRewards[token] < L_Coll[token]) {
                return true;
            }
        }
        return false;
    }

    // Returns debt, collsTokens, collsAmounts, pendingYUSDDebtReward, pendingRewardTokens, pendingRewardAmouns
    function getEntireDebtAndColls(
        address _borrower
    )
    public
    view override
    returns (uint, address[] memory, uint[] memory, uint, address[] memory, uint[] memory)
    {
        uint debt = Troves[_borrower].debt;
        newColls memory colls = Troves[_borrower].colls;

        uint pendingYUSDDebtReward = getPendingYUSDDebtReward(_borrower);
        newColls memory pendingCollReward = _getPendingCollRewards(_borrower);

        debt = debt.add(pendingYUSDDebtReward);

        // add in pending rewards to colls
        colls = _sumColls(colls, pendingCollReward);

        return (debt, colls.tokens, colls.amounts, pendingYUSDDebtReward, pendingCollReward.tokens, pendingCollReward.amounts);
    }

    // Borrower operations remove stake sum. 
    function removeStake(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _removeStake(_borrower);
    }

    // Remove borrower's stake from the totalStakes sum, and set their stake to 0
    function _removeStake(address _borrower) internal {
        address[] memory borrowerColls = Troves[_borrower].colls.tokens;
        uint256 borrowerCollsLen = borrowerColls.length;
        for (uint256 i; i < borrowerCollsLen; ++i) {
            address coll = borrowerColls[i];
            uint stake = Troves[_borrower].stakes[coll];
            totalStakes[coll] = totalStakes[coll].sub(stake);
            Troves[_borrower].stakes[coll] = 0;
        }
    }

    // Update borrower's stake based on their latest collateral value
    // computed at time function is called based on current price of collateral
    function updateStakeAndTotalStakes(address _borrower) external override {
        _requireCallerIsBOorTMR();
        _updateStakeAndTotalStakes(_borrower);
    }

    function _updateStakeAndTotalStakes(address _borrower) internal {
        uint256 troveOwnerLen = Troves[_borrower].colls.tokens.length;
        for (uint256 i; i < troveOwnerLen; ++i) {
            address token = Troves[_borrower].colls.tokens[i];
            uint amount = Troves[_borrower].colls.amounts[i];

            uint newStake = _computeNewStake(token, amount);
            uint oldStake = Troves[_borrower].stakes[token];

            Troves[_borrower].stakes[token] = newStake;
            totalStakes[token] = totalStakes[token].sub(oldStake).add(newStake);

            emit TotalStakesUpdated(token, totalStakes[token]);
        }
    }

    // Calculate a new stake based on the snapshots of the totalStakes and totalCollateral taken at the last liquidation
    function _computeNewStake(address token, uint _coll) internal view returns (uint) {
        uint stake;
        if (totalCollateralSnapshot[token] == 0) {
            stake = _coll;
        } else {
            /*
            * The following assert() holds true because:
            * - The system always contains >= 1 trove
            * - When we close or liquidate a trove, we redistribute the pending rewards, so if all troves were closed/liquidated,
            * rewards would’ve been emptied and totalCollateralSnapshot would be zero too.
            */
            require(totalStakesSnapshot[token] != 0, "TM: stake !> 0");
            stake = _coll.mul(totalStakesSnapshot[token]).div(totalCollateralSnapshot[token]);
        }
        return stake;
    }

    function redistributeDebtAndColl(IActivePool _activePool, IDefaultPool _defaultPool, uint _debt, address[] memory _tokens, uint[] memory _amounts) external override {
        _requireCallerIsTML();
        uint256 tokensLen = _tokens.length;
        require(tokensLen == _amounts.length, "TM: len");
        if (_debt == 0) { return; }
        /*
        * Add distributed coll and debt rewards-per-unit-staked to the running totals. Division uses a "feedback"
        * error correction, to keep the cumulative error low in the running totals L_Coll and L_YUSDDebt:
        *
        * 1) Form numerators which compensate for the floor division errors that occurred the last time this
        * function was called.
        * 2) Calculate "per-unit-staked" ratios.
        * 3) Multiply each ratio back by its denominator, to reveal the current floor division error.
        * 4) Store these errors for use in the next correction when this function is called.
        * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
        */
        uint totalCollateralVC = _getVC(_tokens, _amounts); // total collateral value in VC terms

        for (uint256 i; i < tokensLen; ++i) {
            address token = _tokens[i];
            uint amount = _amounts[i];
            // Prorate debt per collateral by dividing each collateral value by cumulative collateral value and multiply by outstanding debt
            uint collateralVC = whitelist.getValueVC(token, amount);
            uint proratedDebtForCollateral = collateralVC.mul(_debt).div(totalCollateralVC);
            uint dec = IERC20(token).decimals();
            uint CollNumerator = amount.mul(10 ** dec).add(lastCollError_Redistribution[token]);
            uint YUSDDebtNumerator = proratedDebtForCollateral.mul(DECIMAL_PRECISION).add(lastYUSDDebtError_Redistribution[token]);
            if (totalStakes[token] != 0) {
                // Get the per-unit-staked terms
                uint256 thisTotalStakes = totalStakes[token];
                uint CollRewardPerUnitStaked = CollNumerator.div(thisTotalStakes);
                uint YUSDDebtRewardPerUnitStaked = YUSDDebtNumerator.div(thisTotalStakes.mul(10 ** (18 - dec)));

                lastCollError_Redistribution[token] = CollNumerator.sub(CollRewardPerUnitStaked.mul(thisTotalStakes));
                lastYUSDDebtError_Redistribution[token] = YUSDDebtNumerator.sub(YUSDDebtRewardPerUnitStaked.mul(thisTotalStakes.mul(10 ** (18 - dec))));

                // Add per-unit-staked terms to the running totals
                L_Coll[token] = L_Coll[token].add(CollRewardPerUnitStaked);
                L_YUSDDebt[token] = L_YUSDDebt[token].add(YUSDDebtRewardPerUnitStaked);
                emit LTermsUpdated(token, L_Coll[token], L_YUSDDebt[token]);
            }
        }

        // Transfer coll and debt from ActivePool to DefaultPool
        _activePool.decreaseYUSDDebt(_debt);
        _defaultPool.increaseYUSDDebt(_debt);
        _activePool.sendCollaterals(address(_defaultPool), _tokens, _amounts);
    }

    function closeTrove(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _closeTrove(_borrower, Status.closedByOwner);
    }

    function closeTroveLiquidation(address _borrower) external override {
        _requireCallerIsTML();
        return _closeTrove(_borrower, Status.closedByLiquidation);
    }

    function closeTroveRedemption(address _borrower) external override {
        _requireCallerIsTMR();
        return _closeTrove(_borrower, Status.closedByRedemption);
    }

    function _closeTrove(address _borrower, Status closedStatus) internal {
        require(closedStatus != Status.nonExistent && closedStatus != Status.active, "Status !active|!exists");

        uint TroveOwnersArrayLength = TroveOwners.length;
        _requireMoreThanOneTroveInSystem(TroveOwnersArrayLength);
        newColls memory emptyColls;


        address[] memory allColls = Troves[_borrower].colls.tokens;        
        uint allCollsLen = allColls.length;
        for (uint256 i; i < allCollsLen; ++i) {
            address thisAllColls = allColls[i];
            rewardSnapshots[_borrower].CollRewards[thisAllColls] = 0;
            rewardSnapshots[_borrower].YUSDDebts[thisAllColls] = 0;
        }

        Troves[_borrower].status = closedStatus;
        Troves[_borrower].colls = emptyColls;
        Troves[_borrower].debt = 0;

        _removeTroveOwner(_borrower, TroveOwnersArrayLength);
        sortedTroves.remove(_borrower);
    }

    /*
    * Updates snapshots of system total stakes and total collateral, excluding a given collateral remainder from the calculation.
    * Used in a liquidation sequence.
    *
    * The calculation excludes a portion of collateral that is in the ActivePool:
    *
    * the total Coll gas compensation from the liquidation sequence
    *
    * The Coll as compensation must be excluded as it is always sent out at the very end of the liquidation sequence.
    */
    function updateSystemSnapshots_excludeCollRemainder(IActivePool _activePool, address[] memory _tokens, uint[] memory _amounts) external override {
        _requireCallerIsTML();
        uint256 tokensLen = _tokens.length;
        for (uint256 i; i < tokensLen; ++i) {
            address token = _tokens[i];
            totalStakesSnapshot[token] = totalStakes[token];

            uint _tokenRemainder = _amounts[i];
            uint activeColl = _activePool.getCollateral(token);
            uint liquidatedColl = defaultPool.getCollateral(token);
            totalCollateralSnapshot[token] = activeColl.sub(_tokenRemainder).add(liquidatedColl);
        }
        emit SystemSnapshotsUpdated(block.timestamp);
    }

    // Push the owner's address to the Trove owners list, and record the corresponding array index on the Trove struct
    function addTroveOwnerToArray(address _borrower) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        return _addTroveOwnerToArray(_borrower);
    }

    function _addTroveOwnerToArray(address _borrower) internal returns (uint128 index) {
        /* Max array size is 2**128 - 1, i.e. ~3e30 troves. No risk of overflow, since troves have minimum YUSD
        debt of liquidation reserve plus MIN_NET_DEBT. 3e30 YUSD dwarfs the value of all wealth in the world ( which is < 1e15 USD). */
        // Push the Troveowner to the array
        TroveOwners.push(_borrower);

        // Record the index of the new Troveowner on their Trove struct
        index = uint128(TroveOwners.length.sub(1));
        Troves[_borrower].arrayIndex = index;
    }

    /*
    * Remove a Trove owner from the TroveOwners array, not preserving array order. Removing owner 'B' does the following:
    * [A B C D E] => [A E C D], and updates E's Trove struct to point to its new array index.
    */
    function _removeTroveOwner(address _borrower, uint TroveOwnersArrayLength) internal {
        Status troveStatus = Troves[_borrower].status;
        // It’s set in caller function `_closeTrove`
        require(troveStatus != Status.nonExistent && troveStatus != Status.active, "TM: trove !ext|!act");

        uint128 index = Troves[_borrower].arrayIndex;
        uint length = TroveOwnersArrayLength;
        uint idxLast = length.sub(1);

        require(index <= idxLast, "TM: index!>lst ind");

        address addressToMove = TroveOwners[idxLast];

        TroveOwners[index] = addressToMove;
        Troves[addressToMove].arrayIndex = index;
        emit TroveIndexUpdated(addressToMove, index);

        TroveOwners.pop();
    }

    // --- Recovery Mode and TCR functions ---

    function getTCR() external view override returns (uint) {
        return _getTCR();
    }

    function checkRecoveryMode() external view override returns (bool) {
        return _checkRecoveryMode();
    }


    // --- Redemption fee functions ---

    function updateBaseRate(uint newBaseRate) external override {
        _requireCallerIsTMR();
        require(newBaseRate != 0, "TM: newBR!>0");
        baseRate = newBaseRate;
        emit BaseRateUpdated(newBaseRate);
        _updateLastFeeOpTime();
    }

    function getRedemptionRate() public view override returns (uint) {
        return _calcRedemptionRate(baseRate);
    }

    function getRedemptionRateWithDecay() public view override returns (uint) {
        return _calcRedemptionRate(calcDecayedBaseRate());
    }

    function _calcRedemptionRate(uint _baseRate) internal pure returns (uint) {
        return LiquityMath._min(
            REDEMPTION_FEE_FLOOR.add(_baseRate),
            DECIMAL_PRECISION // cap at a maximum of 100%
        );
    }

    function _getRedemptionFee(uint _YUSDRedeemed) internal view returns (uint) {
        return _calcRedemptionFee(getRedemptionRate(), _YUSDRedeemed);
    }

    function getRedemptionFeeWithDecay(uint _YUSDRedeemed) external view override returns (uint) {
        return _calcRedemptionFee(getRedemptionRateWithDecay(), _YUSDRedeemed);
    }

    function _calcRedemptionFee(uint _redemptionRate, uint _YUSDRedeemed) internal pure returns (uint) {
        uint redemptionFee = _redemptionRate.mul(_YUSDRedeemed).div(DECIMAL_PRECISION);
        require(redemptionFee < _YUSDRedeemed, "TM:Fee>ret colls");
        return redemptionFee;
    }


    // --- Borrowing fee functions ---

    function getBorrowingRate() public view override returns (uint) {
        return _calcBorrowingRate(baseRate);
    }

    function getBorrowingRateWithDecay() public view override returns (uint) {
        return _calcBorrowingRate(calcDecayedBaseRate());
    }

    function _calcBorrowingRate(uint _baseRate) internal pure returns (uint) {
        return LiquityMath._min(
            BORROWING_FEE_FLOOR.add(_baseRate),
            MAX_BORROWING_FEE
        );
    }

    function getBorrowingFee(uint _YUSDDebt) external view override returns (uint) {
        return _calcBorrowingFee(getBorrowingRate(), _YUSDDebt);
    }

    function getBorrowingFeeWithDecay(uint _YUSDDebt) external view override returns (uint) {
        return _calcBorrowingFee(getBorrowingRateWithDecay(), _YUSDDebt);
    }

    function _calcBorrowingFee(uint _borrowingRate, uint _YUSDDebt) internal pure returns (uint) {
        return _borrowingRate.mul(_YUSDDebt).div(DECIMAL_PRECISION);
    }


    // Updates the baseRate state variable based on time elapsed since the last redemption or YUSD borrowing operation.
    function decayBaseRateFromBorrowing() external override {
        _requireCallerIsBorrowerOperations();

        uint decayedBaseRate = calcDecayedBaseRate();
        require(decayedBaseRate <= DECIMAL_PRECISION, "TM: decBR<");  // The baseRate can decay to 0

        baseRate = decayedBaseRate;
        emit BaseRateUpdated(decayedBaseRate);

        _updateLastFeeOpTime();
    }


    // --- Internal fee functions ---

    // Update the last fee operation time only if time passed >= decay interval. This prevents base rate griefing.
    function _updateLastFeeOpTime() internal {
        uint timePassed = block.timestamp.sub(lastFeeOperationTime);

        if (timePassed >= SECONDS_IN_ONE_MINUTE) {
            lastFeeOperationTime = block.timestamp;
            emit LastFeeOpTimeUpdated(block.timestamp);
        }
    }

    function calcDecayedBaseRate() public view override returns (uint) {
        uint minutesPassed = _minutesPassedSinceLastFeeOp();
        uint decayFactor = LiquityMath._decPow(MINUTE_DECAY_FACTOR, minutesPassed);

        return baseRate.mul(decayFactor).div(DECIMAL_PRECISION);
    }

    function _minutesPassedSinceLastFeeOp() internal view returns (uint) {
        return (block.timestamp.sub(lastFeeOperationTime)).div(SECONDS_IN_ONE_MINUTE);
    }

    // --- 'require' wrapper functions ---

    function _requireCallerIsBorrowerOperations() internal view {
        if (msg.sender != borrowerOperationsAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _requireCallerIsBOorTMR() internal view {
        if (msg.sender != borrowerOperationsAddress && msg.sender != troveManagerRedemptionsAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _requireCallerIsTMR() internal view {
        if (msg.sender != troveManagerRedemptionsAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _requireCallerIsTML() internal view {
        if (msg.sender != troveManagerLiquidationsAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _revertWrongFuncCaller() internal pure {
        revert("TM: Ext.call");
    }

    function _requireTroveIsActive(address _borrower) internal view {
        require(Troves[_borrower].status == Status.active, "TM: tmust exist");
    }

    function _requireMoreThanOneTroveInSystem(uint TroveOwnersArrayLength) internal view {
        require (TroveOwnersArrayLength > 1 && sortedTroves.getSize() > 1, "TM: last trove");
    }

    // --- Trove property getters ---

    function getTroveStatus(address _borrower) external view override returns (uint) {
        return uint(Troves[_borrower].status);
    }

    function isTroveActive(address _borrower) external view override returns (bool) {
        return Troves[_borrower].status == Status.active;
    }

    function getTroveStake(address _borrower, address _token) external view override returns (uint) {
        return Troves[_borrower].stakes[_token];
    }

    function getTroveDebt(address _borrower) external view override returns (uint) {
        return Troves[_borrower].debt;
    }

    // -- Trove Manager State Variable Getters -- 

    function getTotalStake(address _token) external view override returns (uint) {
        return totalStakes[_token];
    }

    function getL_Coll(address _token) external view override returns (uint) {
        return L_Coll[_token];
    }

    function getL_YUSD(address _token) external view override returns (uint) {
        return L_YUSDDebt[_token];
    }

    function getRewardSnapshotColl(address _borrower, address _token) external view override returns (uint) {
        return rewardSnapshots[_borrower].CollRewards[_token];
    }

    function getRewardSnapshotYUSD(address _borrower, address _token) external view override returns (uint) {
        return rewardSnapshots[_borrower].YUSDDebts[_token];
    }

    // recomputes VC given current prices and returns it
    function getTroveVC(address _borrower) external view override returns (uint) {
        return _getVCColls(Troves[_borrower].colls);
    }

    function getTroveColls(address _borrower) external view override returns (address[] memory, uint[] memory) {
        return (Troves[_borrower].colls.tokens, Troves[_borrower].colls.amounts);
    }

    function getCurrentTroveState(address _borrower) external override view returns (address[] memory, uint[] memory, uint) {
        (newColls memory colls, uint currentYUSDDebt) = _getCurrentTroveState(_borrower);
        return (colls.tokens, colls.amounts, currentYUSDDebt);
    }

    // --- Called by TroveManagerRedemptions Only ---


    function updateTroveDebt(address _borrower, uint debt) external override {
        _requireCallerIsTMR();
        Troves[_borrower].debt = debt;
    }

    function updateTroveCollTMR(address  _borrower, address[] memory addresses, uint[] memory amounts) external override {
        _requireCallerIsTMR();
        (Troves[_borrower].colls.tokens, Troves[_borrower].colls.amounts) = (addresses, amounts);
    }

    function removeStakeTMR(address _borrower) external override {
        _requireCallerIsTMR();
        _removeStake(_borrower);
    }

    // --- Called by TroverManagerLiquidations Only ---

    function removeStakeTLR(address _borrower) external override {
        _requireCallerIsTML();
        _removeStake(_borrower);
    }

    // --- Trove property setters, called by BorrowerOperations ---

    function setTroveStatus(address _borrower, uint _num) external override {
        _requireCallerIsBorrowerOperations();
        Troves[_borrower].status = Status(_num);
    }

    function updateTroveColl(address _borrower, address[] memory _tokens, uint[] memory _amounts) external override {
        _requireCallerIsBorrowerOperations();
        require(_tokens.length == _amounts.length, "TM: len mismatch");
        Troves[_borrower].colls.tokens = _tokens;
        Troves[_borrower].colls.amounts = _amounts;
    }

    function increaseTroveDebt(address _borrower, uint _debtIncrease) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newDebt = Troves[_borrower].debt.add(_debtIncrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }

    function decreaseTroveDebt(address _borrower, uint _debtDecrease) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newDebt = Troves[_borrower].debt.sub(_debtDecrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }

    // --- contract getters ---

    function stabilityPool() external view override returns (IStabilityPool) {
        return stabilityPoolContract;
    }

    function yusdToken() external view override returns (IYUSDToken) {
        return yusdTokenContract;
    }

    function yetiToken() external view override returns (IYETIToken) {
        return yetiTokenContract;
    }

    function sYETI() external view override returns (ISYETI) {
        return sYETIContract;
    }
 }

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Interfaces/ISortedTroves.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/CheckContract.sol";

/*
* A sorted doubly linked list with nodes sorted in descending order.
*
* Nodes map to active Troves in the system - the ID property is the address of a Trove owner.
* Nodes are ordered according to their current individual collateral ratio (ICR),
*
* The list optionally accepts insert position hints.
*
* The list relies on the fact that liquidation events preserve ordering: a liquidation decreases the ICRs of all active Troves,
* but maintains their order. A node inserted based on current ICR will maintain the correct position,
* relative to it's peers, as rewards accumulate, as long as it's raw collateral and debt have not changed.
* Thus, Nodes remain sorted by current ICR.
*
* Nodes need only be re-inserted upon a Trove operation - when the owner adds or removes collateral or debt
* to their position.
*
* The list is a modification of the following audited SortedDoublyLinkedList:
* https://github.com/livepeer/protocol/blob/master/contracts/libraries/SortedDoublyLL.sol
*
*
* Changes made in the Liquity implementation:
*
* - Keys have been removed from nodes
*
* - Ordering checks for insertion are performed by comparing an ICR argument to the current ICR, calculated at runtime.
*   The list relies on the property that ordering by ICR is maintained as the Coll:USD price varies.
*
* - Public functions with parameters have been made internal to save gas, and given an external wrapper function for external access
* 
* Changes made in Yeti Finance implementation: 
* Since the nodes are no longer just reliant on the nominal ICR which is just amount of ETH / debt, we now have to use the ICR based 
* on the VC value of the node. This changes with any price change, as the composition of any trove does not stay constant. Therefore 
* the list can easily become stale. This is a compromise that we had to make due to it being too expensive gas wise to keep the list 
* actually sorted by current ICR, as this can change each block. Instead, we keep it ordered by oldICR, and it is instead updated through
* an external function in TroveManager.sol, updateTroves(), and can be called by anyone. This will essentially just update the oldICR and re=insert it 
* into the list. It always remains sorted by oldICR. To then perform redemptions properly, we just allow redemptions to occur for any 
* trove in order of the stale list. However, the redemption amount is in dollar terms so people will always still keep their value, just 
* will lose exposure to the asset. 
* 
*/
contract SortedTroves is OwnableUpgradeable, CheckContract, ISortedTroves {
    using SafeMath for uint256;

    bytes32 constant public NAME = "SortedTroves";

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event TroveManagerRedemptionsAddressChanged(address _troveManagerRedemptionsAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _ICR);
    event NodeRemoved(address _id);

    address internal borrowerOperationsAddress;
    address internal troveManagerRedemptionsAddress;
    address internal troveManagerAddress;

    // Information for a node in the list
    struct Node {
        bool exists;
        address nextId;                  // Id of next node (smaller ICR) in the list
        address prevId;                  // Id of previous node (larger ICR) in the list
        uint oldICR;                     // ICR of the node last time it was updated. List is always in order 
                                         // in terms of oldICR . 
    }

    // Information for the list
    struct Data {
        address head;                        // Head of the list. Also the node in the list with the largest ICR
        address tail;                        // Tail of the list. Also the node in the list with the smallest ICR
        uint256 maxSize;                     // Maximum size of the list
        uint256 size;                        // Current size of the list
        mapping (address => Node) nodes;     // Track the corresponding ids for each node in the list
    }

    Data public data;

    // --- Dependency setters ---
    function setUp() external {
		__Ownable_init();
	}

    function setParams(uint256 _size, 
        address _troveManagerAddress, 
        address _borrowerOperationsAddress,
        address _troveManagerRedemptionsAddress) 
        external override onlyOwner {
        require(_size != 0, "SortedTroves: Size can’t be zero");
        checkContract(_troveManagerAddress);
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerRedemptionsAddress);

        data.maxSize = _size;

        troveManagerAddress = _troveManagerAddress;
        borrowerOperationsAddress = _borrowerOperationsAddress;
        troveManagerRedemptionsAddress = _troveManagerRedemptionsAddress;

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerRedemptionsAddressChanged(_troveManagerRedemptionsAddress);

        renounceOwnership();
    }

    /*
     * @dev Add a node to the list
     * @param _id Node's id
     * @param _ICR Node's _ICR at time of inserting
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */

    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external override {
        _requireCallerIsBOorTroveM();
        _insert(_id, _ICR, _prevId, _nextId);
    }

    function _insert(address _id, uint256 _ICR, address _prevId, address _nextId) internal {
        // List must not be full
        require(!isFull(), "SortedTroves: List is full");
        // List must not already contain node
        require(!contains(_id), "SortedTroves: duplicate node");
        // Node id must not be null
        require(_id != address(0), "SortedTroves: Id cannot be zero");
        // ICR must be non-zero
        require(_ICR != 0, "SortedTroves: ICR must be (+)");
        address prevId = _prevId;
        address nextId = _nextId;
        if (!_validInsertPosition(_ICR, prevId, nextId)) {
            // Sender's hint was not a valid insert position
            // Use sender's hint to find a valid insert position
            (prevId, nextId) = _findInsertPosition(_ICR, prevId, nextId);
        }

         data.nodes[_id].exists = true;
        if (prevId == address(0) && nextId == address(0)) {
            // Insert as head and tail
            data.head = _id;
            data.tail = _id;
        } else if (prevId == address(0)) {
            // Insert before `prevId` as the head
            data.nodes[_id].nextId = data.head;
            data.nodes[data.head].prevId = _id;
            data.head = _id;
        } else if (nextId == address(0)) {
            // Insert after `nextId` as the tail
            data.nodes[_id].prevId = data.tail;
            data.nodes[data.tail].nextId = _id;
            data.tail = _id;
        } else {
            // Insert at insert position between `prevId` and `nextId`
            data.nodes[_id].nextId = nextId;
            data.nodes[_id].prevId = prevId;
            data.nodes[prevId].nextId = _id;
            data.nodes[nextId].prevId = _id;
        }

        // Update node's ICR
        data.nodes[_id].oldICR = _ICR;

        data.size = data.size.add(1);
        emit NodeAdded(_id, _ICR);
    }

    function remove(address _id) external override {
        _requireCallerIsTroveManager();
        _remove(_id);
    }

    /*
     * @dev Remove a node from the list
     * @param _id Node's id
     */
    function _remove(address _id) internal {
        // List must contain the node
        require(contains(_id), "SortedTroves: Id not found");

        if (data.size > 1) {
            // List contains more than a single node
            if (_id == data.head) {
                // The removed node is the head
                // Set head to next node
                data.head = data.nodes[_id].nextId;
                // Set prev pointer of new head to null
                data.nodes[data.head].prevId = address(0);
            } else if (_id == data.tail) {
                // The removed node is the tail
                // Set tail to previous node
                data.tail = data.nodes[_id].prevId;
                // Set next pointer of new tail to null
                data.nodes[data.tail].nextId = address(0);
            } else {
                // The removed node is neither the head nor the tail
                // Set next pointer of previous node to the next node
                data.nodes[data.nodes[_id].prevId].nextId = data.nodes[_id].nextId;
                // Set prev pointer of next node to the previous node
                data.nodes[data.nodes[_id].nextId].prevId = data.nodes[_id].prevId;
            }
        } else {
            // List contains a single node
            // Set the head and tail to null
            data.head = address(0);
            data.tail = address(0);
        }

        data.nodes[_id].oldICR = 0;

        delete data.nodes[_id];
        data.size = data.size.sub(1);
        emit NodeRemoved(_id);
    }

    /*
     * @dev Re-insert the node at a new position, based on its new ICR
     * @param _id Node's id
     * @param _newICR Node's new ICR
     * @param _prevId Id of previous node for the new insert position
     * @param _nextId Id of next node for the new insert position
     */
    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external override {
        _requireCallerIsBOorTroveM();
        // List must contain the node
        require(contains(_id), "SortedTroves: Id not found");
        // ICR must be non-zero
        require(_newICR != 0, "SortedTroves: ICR must be (+)");

        // Remove node from the list
        _remove(_id);

        _insert(_id, _newICR, _prevId, _nextId);
    }

    /*
     * @dev Checks if the list contains a node
     */
    function contains(address _id) public view override returns (bool) {
        return data.nodes[_id].exists;
    }

    /*
     * @dev Checks if the list is full
     */
    function isFull() public view override returns (bool) {
        return data.size == data.maxSize;
    }

    /*
     * @dev Checks if the list is empty
     */
    function isEmpty() public view override returns (bool) {
        return data.size == 0;
    }

    /*
     * @dev Returns the current size of the list
     */
    function getSize() external view override returns (uint256) {
        return data.size;
    }

    /*
     * @dev Returns the maximum size of the list
     */
    function getMaxSize() external view override returns (uint256) {
        return data.maxSize;
    }

    /*
     * @dev Returns the first node in the list (node with the largest ICR)
     */
    function getFirst() external view override returns (address) {
        return data.head;
    }

    /*
     * @dev Returns the last node in the list (node with the smallest ICR)
     */
    function getLast() external view override returns (address) {
        return data.tail;
    }

    /*
     * @dev Returns the next node (with a smaller ICR) in the list for a given node
     * @param _id Node's id
     */
    function getNext(address _id) external view override returns (address) {
        return data.nodes[_id].nextId;
    }

    /*
     * @dev Returns the previous node (with a larger ICR) in the list for a given node
     * @param _id Node's id
     */
    function getPrev(address _id) external view override returns (address) {
        return data.nodes[_id].prevId;
    }

    /*
     * @dev get the old ICR of a node
     */
    function getOldICR(address _id) external view override returns (uint256) {
        return data.nodes[_id].oldICR;
    }

    /*
     * @dev Check if a pair of nodes is a valid insertion point for a new node with the given ICR
     * @param _ICR Node's ICR
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */
    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view override returns (bool) {
        return _validInsertPosition(_ICR, _prevId, _nextId);
    }

    // Instead of calculating current ICR using trove manager, we use oldICR values. 
    function _validInsertPosition(uint256 _ICR, address _prevId, address _nextId) internal view returns (bool) {
        if (_prevId == address(0) && _nextId == address(0)) {
            // `(null, null)` is a valid insert position if the list is empty
            return isEmpty();
        } else if (_prevId == address(0)) {
            // `(null, _nextId)` is a valid insert position if `_nextId` is the head of the list
            return data.head == _nextId && _ICR >= data.nodes[_nextId].oldICR;
        } else if (_nextId == address(0)) {
            // `(_prevId, null)` is a valid insert position if `_prevId` is the tail of the list
            return data.tail == _prevId && _ICR <= data.nodes[_prevId].oldICR;
        } else {
            // `(_prevId, _nextId)` is a valid insert position if they are adjacent nodes and `_ICR` falls between the two nodes' ICRs
            return data.nodes[_prevId].nextId == _nextId &&
                   data.nodes[_prevId].oldICR >= _ICR &&
                    _ICR >= data.nodes[_nextId].oldICR;
        }
    }

    /*
     * @dev Descend the list (larger ICRs to smaller ICRs) to find a valid insert position
     * @param _ICR Node's ICR
     * @param _startId Id of node to start descending the list from
     */
    function _descendList(uint256 _ICR, address _startId) internal view returns (address, address) {
        // If `_startId` is the head, check if the insert position is before the head
        if (data.head == _startId && _ICR >= data.nodes[_startId].oldICR) {
            return (address(0), _startId);
        }

        address prevId = _startId;
        address nextId = data.nodes[prevId].nextId;

        // Descend the list until we reach the end or until we find a valid insert position
        while (prevId != address(0) && !_validInsertPosition(_ICR, prevId, nextId)) {
            prevId = data.nodes[prevId].nextId;
            nextId = data.nodes[prevId].nextId;
        }

        return (prevId, nextId);
    }

    /*
     * @dev Ascend the list (smaller ICRs to larger ICRs) to find a valid insert position
     * @param _ICR Node's ICR
     * @param _startId Id of node to start ascending the list from
     */
    function _ascendList(uint256 _ICR, address _startId) internal view returns (address, address) {
        // If `_startId` is the tail, check if the insert position is after the tail
        if (data.tail == _startId && _ICR <= data.nodes[_startId].oldICR) {
            return (_startId, address(0));
        }

        address nextId = _startId;
        address prevId = data.nodes[nextId].prevId;

        // Ascend the list until we reach the end or until we find a valid insertion point
        while (nextId != address(0) && !_validInsertPosition(_ICR, prevId, nextId)) {
            nextId = data.nodes[nextId].prevId;
            prevId = data.nodes[nextId].prevId;
        }

        return (prevId, nextId);
    }

   


    /*
     * @dev Find the insert position for a new node with the given ICR
     * @param _ICR Node's ICR
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */
    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view override returns (address, address) {
        return _findInsertPosition(_ICR, _prevId, _nextId);
    }

    function _findInsertPosition(uint256 _ICR, address _prevId, address _nextId) internal view returns (address, address) {
        address prevId = _prevId;
        address nextId = _nextId;

        if (prevId != address(0)) {
            if (!contains(prevId) || _ICR > data.nodes[prevId].oldICR) {
                // `prevId` does not exist anymore or now has a smaller ICR than the given ICR
                prevId = address(0);
            }
        }

        if (nextId != address(0)) {
            if (!contains(nextId) || _ICR < data.nodes[nextId].oldICR) {
                // `nextId` does not exist anymore or now has a larger ICR than the given ICR
                nextId = address(0);
            }
        }

        if (prevId == address(0) && nextId == address(0)) {
            // No hint - descend list starting from head
            return _descendList(_ICR, data.head);
        } else if (prevId == address(0)) {
            // No `prevId` for hint - ascend list starting from `nextId`
            return _ascendList(_ICR, nextId);
        } else if (nextId == address(0)) {
            // No `nextId` for hint - descend list starting from `prevId`
            return _descendList(_ICR, prevId);
        } else {
            // Descend list starting from `prevId`
            return _descendList(_ICR, prevId);
        }
    }

    // --- 'require' functions ---

    function _requireCallerIsTroveManager() internal view {
        if (msg.sender != troveManagerAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _requireCallerIsBOorTroveM() internal view {
        if (msg.sender != borrowerOperationsAddress && msg.sender != troveManagerAddress
                && msg.sender != troveManagerRedemptionsAddress) {
            _revertWrongFuncCaller();
        }
    }

    function _revertWrongFuncCaller() internal pure {
        revert("ST: External caller not allowed");
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../Interfaces/IBaseOracle.sol";
import "../Interfaces/IWhitelist.sol";
import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/IPriceCurve.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/IStabilityPool.sol";
import "../Interfaces/ICollSurplusPool.sol";
import "../Interfaces/IERC20.sol";
import "./LiquityMath.sol";
import "./CheckContract.sol";


/**
 * Whitelist is the contract that keeps track of all the assets that the system takes as collateral.
 * It has onlyOwner functions to add or deprecate collaterals from the whitelist, change the price
 * curve, price feed, safety ratio, etc.
 */

contract Whitelist is OwnableUpgradeable, IWhitelist, IBaseOracle, CheckContract {
    using SafeMath for uint256;

    struct CollateralParams {
        // Safety ratio
        uint256 safetyRatio; // 10**18 * the ratio. i.e. ratio = .95 * 10**18 for 95%. More risky collateral has a lower ratio
        uint256 recoveryRatio;
        address oracle;
        uint256 decimals;
        address priceCurve;
        uint256 index;
        address defaultRouter;
        bool active;
        bool isWrapped;
    }

    IActivePool activePool;
    IDefaultPool defaultPool;
    IStabilityPool stabilityPool;
    ICollSurplusPool collSurplusPool;
    address borrowerOperationsAddress;
    bool private addressesSet;

    mapping(address => address) validCallers;
    mapping(address => bool) pendingLockCallers;
    mapping(address => bool) cannotUpdateValidCaller;

    mapping(address => CollateralParams) public collateralParams;
    // list of all collateral types in collateralParams (active and deprecated)
    // Addresses for easy access
    address[] public validCollateral; // index maps to token address.

    uint256 maxCollsInTrove; // TODO: update to a reasonable number

    event CollateralAdded(address _collateral);
    event CollateralDeprecated(address _collateral);
    event CollateralUndeprecated(address _collateral);
    event OracleChanged(address _collateral, address _newOracle);
    event PriceCurveChanged(address _collateral, address _newPriceCurve);
    event SafetyRatioChanged(address _collateral, uint256 _newSafetyRatio);
    event RecoveryRatioChanged(address _collateral, uint256 _newRecoveryRatio);

    // Require that the collateral exists in the whitelist. If it is not the 0th index, and the
    // index is still 0 then it does not exist in the mapping.
    // no require here for valid collateral 0 index because that means it exists. 
    modifier exists(address _collateral) {
        _exists(_collateral);
        _;
    }

    // Calling from here makes it not inline, reducing contract size significantly. 
    function _exists(address _collateral) internal view {
        if (validCollateral[0] != _collateral) {
            require(collateralParams[_collateral].index != 0, "collateral does not exist");
        }
    }

    // ----------Only Owner Setter Functions----------

    function setUp() external {
		__Ownable_init();
	}

    function setAddresses(
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _collSurplusPoolAddress,
        address _borrowerOperationsAddress
    ) external override onlyOwner {
        require(!addressesSet, "addresses already set");
        checkContract(_activePoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_collSurplusPoolAddress);
        checkContract(_borrowerOperationsAddress);

        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        stabilityPool = IStabilityPool(_stabilityPoolAddress);
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        borrowerOperationsAddress = _borrowerOperationsAddress;
        addressesSet = true;
        maxCollsInTrove = 50;
    }

    function addCollateral(
        address _collateral,
        uint256 _safetyRatio,
        uint256 _recoveryRatio,
        address _oracle,
        uint256 _decimals,
        address _priceCurve, 
        bool _isWrapped, 
        address _routerAddress
    ) external onlyOwner {
        checkContract(_collateral);
        checkContract(_oracle);
        checkContract(_priceCurve);
        checkContract(_routerAddress);
        // If collateral list is not 0, and if the 0th index is not equal to this collateral,
        // then if index is 0 that means it is not set yet.
        require(_safetyRatio < 11e17, "ratio must be less than 1.10"); //=> greater than 1.1 would mean taking out more YUSD than collateral VC

        if (validCollateral.length != 0) {
            require(validCollateral[0] != _collateral && collateralParams[_collateral].index == 0, "collateral   exists");
        }

        validCollateral.push(_collateral);
        collateralParams[_collateral] = CollateralParams(
            _safetyRatio,
            _recoveryRatio,
            _oracle,
            _decimals,
            _priceCurve,
            validCollateral.length - 1, 
            _routerAddress,
            true,
            _isWrapped
        );

        activePool.addCollateralType(_collateral);
        defaultPool.addCollateralType(_collateral);
        stabilityPool.addCollateralType(_collateral);
        collSurplusPool.addCollateralType(_collateral);

        // throw event
        emit CollateralAdded(_collateral);
        emit SafetyRatioChanged(_collateral, _safetyRatio);
        emit RecoveryRatioChanged(_collateral, _recoveryRatio);
    }

    /**
     * Deprecate collateral by not allowing any more collateral to be added of this type.
     * Still can interact with it via validCollateral and CollateralParams
     */
    function deprecateCollateral(address _collateral) external exists(_collateral) onlyOwner {
        checkContract(_collateral);

        require(collateralParams[_collateral].active, "collateral already deprecated");

        collateralParams[_collateral].active = false;

        // throw event
        emit CollateralDeprecated(_collateral);
    }

    /**
     * Undeprecate collateral by allowing more collateral to be added of this type.
     * Still can interact with it via validCollateral and CollateralParams
     */
    function undeprecateCollateral(address _collateral) external exists(_collateral) onlyOwner {
        checkContract(_collateral);

        require(!collateralParams[_collateral].active, "collateral is already active");

        collateralParams[_collateral].active = true;

        // throw event
        emit CollateralUndeprecated(_collateral);
    }

    /**
     * Function to change oracles
     */
    function changeOracle(address _collateral, address _oracle)
        external
        exists(_collateral)
        onlyOwner
    {
        checkContract(_collateral);
        checkContract(_oracle);
        collateralParams[_collateral].oracle = _oracle;

        // throw event
        emit OracleChanged(_collateral, _oracle);
    }

    /**
     * Function to change price curve
     */
    function changePriceCurve(address _collateral, address _priceCurve)
        external
        exists(_collateral)
        onlyOwner
    {
        checkContract(_collateral);
        checkContract(_priceCurve);

        (uint256 lastFeePercent, uint256 lastFeeTime) = IPriceCurve(collateralParams[_collateral].priceCurve).getFeeCapAndTime();
        IPriceCurve(_priceCurve).setFeeCapAndTime(lastFeePercent, lastFeeTime);
        collateralParams[_collateral].priceCurve = _priceCurve;

        // throw event
        emit PriceCurveChanged(_collateral, _priceCurve);
    }

    /**
     * Function to change Safety ratio.
     */
    function changeSafetyRatio(address _collateral, uint256 _newSafetyRatio)
        external
        exists(_collateral)
        onlyOwner
    {
        require(_newSafetyRatio < 11e17, "ratio must be less than 1.10"); //=> greater than 1.1 would mean taking out more YUSD than collateral VC
        require(collateralParams[_collateral].safetyRatio < _newSafetyRatio, "New SR must be greater than previous SR");
        collateralParams[_collateral].safetyRatio = _newSafetyRatio;

        // throw event
        emit SafetyRatioChanged(_collateral, _newSafetyRatio);
    }

    /**
     * Function to change Stable Adjusted Safety ratio. 
     */
    function changeRecoveryRatio(address _collateral, uint256 _newRecoveryRatio)
        external
        exists(_collateral)
        onlyOwner
    {
        collateralParams[_collateral].recoveryRatio = _newRecoveryRatio;

        // throw event
        emit RecoveryRatioChanged(_collateral, _newRecoveryRatio);
    }

    // -----------Routers--------------

    function setDefaultRouter(address _collateral, address _router) external override onlyOwner exists(_collateral) {
        checkContract(_router);
        collateralParams[_collateral].defaultRouter = _router;
    }

    function getDefaultRouterAddress(address _collateral) external view override exists(_collateral) returns (address) {
        return collateralParams[_collateral].defaultRouter;
    }


    // ---------- View Functions -----------

    function isWrapped(address _collateral) external view override returns (bool) {
        return collateralParams[_collateral].isWrapped;
    }

    function getValidCollateral() external view override returns (address[] memory) {
        return validCollateral;
    }

    // Get safety ratio used in VC Calculation
    function getSafetyRatio(address _collateral)
        external
        view
        override
        returns (uint256)
    {
        return collateralParams[_collateral].safetyRatio;
    }

    // Get safety ratio used in TCR calculation, as well as for redemptions. 
    // Often similar to Safety Ratio except for stables.
    function getRecoveryRatio(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return collateralParams[_collateral].recoveryRatio;
    }

    function getOracle(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (address)
    {
        return collateralParams[_collateral].oracle;
    }

    function getPriceCurve(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (address)
    {
        return collateralParams[_collateral].priceCurve;
    }

    function getIsActive(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (bool)
    {
        return collateralParams[_collateral].active;
    }

    function getDecimals(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return collateralParams[_collateral].decimals;
    }

    function getIndex(address _collateral)
        external
        view
        override
        exists(_collateral)
        returns (uint256)
    {
        return (collateralParams[_collateral].index);
    }

    // Returned as fee percentage * 10**18. View function for external callers.
    function getFee(
        address _collateral,
        uint256 _collateralVCInput,
        uint256 _collateralVCSystemBalance,
        uint256 _totalVCBalancePre,
        uint256 _totalVCBalancePost
    ) external view override exists(_collateral) returns (uint256 fee) {
        IPriceCurve priceCurve = IPriceCurve(collateralParams[_collateral].priceCurve);
        return priceCurve.getFee(_collateralVCInput, _collateralVCSystemBalance, _totalVCBalancePre, _totalVCBalancePost);
    }

    // Returned as fee percentage * 10**18. Non view function for just borrower operations to call.
    function getFeeAndUpdate(
        address _collateral,
        uint256 _collateralVCInput,
        uint256 _collateralVCSystemBalance,
        uint256 _totalVCBalancePre,
        uint256 _totalVCBalancePost
    ) external override exists(_collateral) returns (uint256 fee) {
        require(
            msg.sender == borrowerOperationsAddress,
            "caller must be BO"
        );
        IPriceCurve priceCurve = IPriceCurve(collateralParams[_collateral].priceCurve);
        return
            priceCurve.getFeeAndUpdate(
                _collateralVCInput,
                _collateralVCSystemBalance,
                _totalVCBalancePre,
                _totalVCBalancePost
            );
    }

    // should return 10**18 times the price in USD of 1 of the given _collateral
    function getPrice(address _collateral)
        public
        view
        override
        returns (uint256)
    {
        IPriceFeed collateral_priceFeed = IPriceFeed(collateralParams[_collateral].oracle);
        return collateral_priceFeed.fetchPrice_v();
    }

    // Gets the value of that collateral type, of that amount, in USD terms.
    function getValueUSD(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueUSD(_collateral, _amount);
    }

    // Aggregates all usd values of passed in collateral / amounts
    function getValuesUSD(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 USDValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            USDValue = USDValue.add(_getValueUSD(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueUSD(address _collateral, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        uint256 decimals = collateralParams[_collateral].decimals;
        uint256 price = getPrice(_collateral);
        return price.mul(_amount).div(10**decimals);
    }

    // Gets the value of that collateral type, of that amount, in VC terms.
    function getValueVC(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueVC(_collateral, _amount);
    }

    function getValuesVC(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 VCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            VCValue = VCValue.add(_getValueVC(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueVC(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256) {
        // Multiply price by amount and safety ratio to get in VC terms, as well as dividing by amount of decimals to normalize. 
        return ((getPrice(_collateral)).mul(_amount).mul(collateralParams[_collateral].safetyRatio).div(10**(18 + collateralParams[_collateral].decimals)));
    }

    // Gets the value of that collateral type, of that amount, in Recovery VC terms.
    function getValueRVC(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256)
    {
        return _getValueRVC(_collateral, _amount);
    }

    function getValuesRVC(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 RVCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            RVCValue = RVCValue.add(_getValueRVC(_collaterals[i], _amounts[i]));
        }
    }

    function _getValueRVC(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256) {
        // Multiply price by amount and recovery ratio to get in Recovery VC terms, as well as dividing by amount of decimals to normalize. 
        return ((getPrice(_collateral)).mul(_amount).mul(collateralParams[_collateral].recoveryRatio).div(10**(18 + collateralParams[_collateral].decimals)));
    }

    // Gets the TCR value of that collateral type, of that amount, in TCR VC terms. Also returns the regular Value VC. 
    // Used in the active pool and default pool VC calculations. 
    function getValueVCforTCR(address _collateral, uint256 _amount)
        external
        view
        override
        returns (uint256, uint256)
    {
        return _getValueVCforTCR(_collateral, _amount);
    }

    function getValuesVCforTCR(address[] memory _collaterals, uint256[] memory _amounts)
        external
        view
        override
        returns (uint256 VCValue, uint256 RVCValue)
    {
        uint256 tokensLen = _collaterals.length;
        for (uint i; i < tokensLen; ++i) {
            (uint256 tempVCValue, uint256 tempRVCValue) = _getValueVCforTCR(_collaterals[i], _amounts[i]);
            VCValue = VCValue.add(tempVCValue);
            RVCValue = RVCValue.add(tempRVCValue);
        }
    }

    function _getValueVCforTCR(address _collateral, uint256 _amount) 
        internal 
        view 
        returns (uint256 VC, uint256 VCforTCR) {
        uint256 price = getPrice(_collateral);
        uint256 decimals = collateralParams[_collateral].decimals;
        uint256 safetyRatio = collateralParams[_collateral].safetyRatio;
        uint256 recoveryRatio = collateralParams[_collateral].recoveryRatio;
        VC = price.mul(_amount).mul(safetyRatio).div(10**(18 + decimals));
        VCforTCR = price.mul(_amount).mul(recoveryRatio).div(10**(18 + decimals));
    }


    // ===== Contract Callers ======

    /* msg.sender is the Yeti contract calling this function
     * _caller is the caller of that contract on the Yeti contract
     * this function confirms whether the caller of the Yeti Contract is
     * allowed to call that function
     */
    function isValidCaller(address _caller) external override view returns (bool) {
        return (validCallers[msg.sender] == _caller);
    }


    function getValidCaller(address _contract) external override view returns (address) {
        return validCallers[_contract];
    }

    // Changing/Locking Contract Callers:

    function updateValidCaller(address _contract, address _caller) onlyOwner external {
        require(!cannotUpdateValidCaller[_contract], "cannot update valid caller of this contract");
        validCallers[_contract] = _caller;
    }


    function updatePendingLockCaller(address _contract, bool _lock) onlyOwner external {
        pendingLockCallers[_contract] = _lock;
    }


    function lockCaller(address _contract) onlyOwner external {
        cannotUpdateValidCaller[_contract] = pendingLockCallers[_contract];
    }

    // Max Colls in Trove Functions

    function updateMaxCollsInTrove(uint _newMax) onlyOwner external {
        maxCollsInTrove = _newMax;
    }
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


interface ITroveManagerLiquidations {
    function batchLiquidateTroves(address[] memory _troveArray, address _liquidator) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface ITroveManagerRedemptions {
    function redeemCollateral(
        uint _YUSDamount,
        uint _YUSDMaxFee,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        // uint _maxFeePercentage,
        address _redeemSender
    )
    external;
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

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../Interfaces/ITroveManager.sol";
import "../Interfaces/IStabilityPool.sol";
import "../Interfaces/ICollSurplusPool.sol";
import "../Interfaces/IYUSDToken.sol";
import "../Interfaces/ISortedTroves.sol";
import "../Interfaces/IYETIToken.sol";
import "../Interfaces/ISYETI.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/ITroveManagerLiquidations.sol";
import "../Interfaces/ITroveManagerRedemptions.sol";
import "./LiquityBase.sol";


/** 
 * Contains shared functionality of TroveManagerLiquidations, TroveManagerRedemptions, and TroveManager. 
 * Keeps addresses to cache, events, structs, status, etc. Also keeps Trove struct. 
 */

contract TroveManagerBase is LiquityBase, OwnableUpgradeable {

    // --- Connected contract declarations ---

    // A doubly linked list of Troves, sorted by their sorted by their individual collateral ratios

    struct ContractsCache {
        IActivePool activePool;
        IDefaultPool defaultPool;
        IYUSDToken yusdToken;
        address sYETI;
        ISortedTroves sortedTroves;
        ICollSurplusPool collSurplusPool;
        address gasPoolAddress;
    }

    struct SingleRedemptionValues {
        uint YUSDLot;
        newColls CollLot;
        bool cancelledPartial;
    }

    enum Status {
        nonExistent,
        active,
        closedByOwner,
        closedByLiquidation,
        closedByRedemption
    }

    enum TroveManagerOperation {
        applyPendingRewards,
        liquidateInNormalMode,
        liquidateInRecoveryMode,
        redeemCollateral
    }

    // Store the necessary data for a trove
    struct Trove {
        newColls colls;
        uint debt;
        mapping(address => uint) stakes;
        Status status;
        uint128 arrayIndex;
    }


    event TroveUpdated(address indexed _borrower, uint _debt, address[] _tokens, uint[] _amounts, TroveManagerOperation operation);
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;


contract CheckContract {
    /**
     * Check that the account is an already deployed non-destroyed contract.
     * See: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol#L12
     */
    function checkContract(address _account) internal view {
        require(_account != address(0), "Account cannot be zero address");

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(_account) }
        require(size != 0, "Account code size cannot be zero");
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IBaseOracle {
  /// @dev Return the value of the given input as USD per unit.
  /// @param token The ERC-20 token to check the value.
  function getPrice(address token) external view returns (uint);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

interface IPriceCurve {
    function setAddresses(address _whitelistAddress) external;

    function setDecayTime(uint _decayTime) external;

    function setDollarCap(uint _dollarCap) external;

    /** 
     * Returns fee based on inputted collateral VC balance and total VC balance of system. 
     * fee is in terms of percentage * 1e18. 
     * If the fee were 1%, this would be 0.01 * 1e18 = 1e16
     */
    function getFee(uint256 _collateralVCInput, uint256 _collateralVCBalancePost, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external view returns (uint256 fee);

    // Same function, updates the fee as well. Called only by whitelist. 
    function getFeeAndUpdate(uint256 _collateralVCInput, uint256 _totalCollateralVCBalance, uint256 _totalVCBalancePre, uint256 _totalVCBalancePost) external returns (uint256 fee);

    // Function for setting the old price curve's last fee cap / value to the new fee cap / value. 
    // Called only by whitelist. 
    function setFeeCapAndTime(uint256 _lastFeePercent, uint256 _lastFeeTime) external;

    // Gets the fee cap and time currently. Used for setting new values for next price curve. 
    // returns lastFeePercent, lastFeeTime
    function getFeeCapAndTime() external view returns (uint256 _lastFeePercent, uint256 _lastFeeTime);

    /** 
     * Returns fee based on decay since last fee calculation, which we take to be 
     * a reasonable fee amount. If it has decayed a certain amount since then, we let
     * the new fee amount slide. 
     */
    function calculateDecayedFee() external view returns (uint256 fee);
}