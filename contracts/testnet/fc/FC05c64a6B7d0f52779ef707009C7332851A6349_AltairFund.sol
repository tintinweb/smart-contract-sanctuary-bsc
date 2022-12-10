// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./libs/AltairLib.sol";
import "./libs/TransferHelper.sol";
import "./interfaces/IAltairFund.sol";
import "./interfaces/IAltairMaster.sol";
import "./interfaces/IAltairFactory.sol";
import "./interfaces/IAltairSwap.sol";

contract AltairFund is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using AddressUpgradeable for address payable;

    // info
    string public name;
    string public symbol;

    string public BaseTokenName;

    // chain
    address public WETH;
    address public BaseToken;

    // version
    uint256 public version;

    // dca
    bool public dca;

    // community
    bool public community;

    // manager
    address public managerOwner;
    uint256 public managerMonthlyFee;
    uint256 public managerSetMonthlyFeeTimestamp;
    uint256 public managerMonthlyTimestamp;
    uint256 public managerMaxMonthlyFee;

    // copytrading
    bool public copytrading;
    address public managerToCopy;
    IAltairFund public fundToCopy;

    // fund options
    uint256 public rebalanceCycle; // will change back to 876000 in mainnet;
    uint256 public nextRebalance;
    bool public pause;

    // Utils
    bytes internal EMPTY_DATA;

    // mappings
    mapping(address => bool) internal nonBMNamesMapping;
    mapping(address => uint256) public TargetWeight;
    mapping(address => bool) public authorized;

    // targetNames
    address[] public targetNamesAddress;

    // Non Balance Manager Names.
    address[] public nonBMNamesAddress;

    // interfaces
    IAltairMaster internal fundMaster;
    IAltairFactory internal factory;

    // events
    event Received(address, uint256);

    event RebalanceCycleUpdate(
        uint256 fromCycle,
        uint256 toCycle,
        uint256 txnTime
    );

    event SubscribeComplete(
        uint256 totalValueB4,
        uint256 totalValue,
        address investorAddress,
        uint256 mintQty
    );

    event RedeemComplete(
        uint256 totalValueB4,
        uint256 totalValue,
        address investorAddress,
        uint256 burnQty
    );

    event CreateTargetNamesComplete(
        uint256 totalValueB4,
        uint256 totalValue,
        address[] targetNames,
        uint256[] weights
    );

    event EmergencyRedeemComplete(
        uint256 totalValueB4,
        uint256 totalValue,
        bool success
    );

    event RebalanceComplete(uint256 totalValueB4, uint256 totalValue);

    event ManagerMonthlyFeePayed(
        uint256 fee,
        uint256 amount,
        uint256 redeemRatio,
        address manager,
        uint256 timestamp
    );

    event ManagerMonthlyFeeSet(uint256 fee, address manager, uint256 timestamp);

    event ManagerSetCopyTrading(
        address fundToCopy,
        address managerToCopy,
        address fund
    );

    function onlyManager() internal view {
        require(msg.sender == managerOwner || authorized[msg.sender] == true);
    }

    function onlyFactory() internal view {
        require(msg.sender == address(factory), "OnlyFactory");
    }

    // initialize
    function initialize(
        string memory nameCtx,
        string memory symbolCtx,
        address managerOwnerCtx,
        address factoryOwnerCtx,
        bool communityCtx,
        uint256 versionCtx
    ) public initializer {
        require(managerOwnerCtx != address(0), "ManagerOwner");
        require(factoryOwnerCtx != address(0), "FactoryOwner");
        managerOwner = managerOwnerCtx;
        fundMaster = IAltairMaster(
            IAltairFactory(factoryOwnerCtx).fundMaster()
        );
        factory = IAltairFactory(factoryOwnerCtx);
        nextRebalance = block.number.add(rebalanceCycle);
        rebalanceCycle = 3600;
        BaseToken = address(0x0000000000000000000000000000000000000000);
        BaseTokenName = "BNB";
        WETH = address(IAltairFactory(factoryOwnerCtx).NATIVE()); //testnet
        pause = false;
        community = communityCtx;
        version = versionCtx;
        copytrading = false;
        dca = false;
        managerMaxMonthlyFee = 500;

        name = nameCtx;
        symbol = symbolCtx;

        __Ownable_init();
        __Ownable_init_unchained();
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /*----GETTERS--------------------------------------*/

    /// @dev return transfer Amount on reedemt
    function getTransferAmt(address underyingAdd, uint256 redeemratio)
        public
        view
        returns (AltairLib.transferData memory transData)
    {
        return _getTransferAmt(underyingAdd, redeemratio);
    }

    /// @dev return Non Balance Manager lenght
    function getNonBMLength() external view returns (uint256) {
        return _getNonBMLength();
    }

    /// @dev return Non Balance Manager Values
    function getNonBMValues() public view returns (uint256) {
        uint256 totalValue = 0;
        for (uint256 i; i < nonBMNamesAddress.length; i++) {
            if (nonBMNamesMapping[nonBMNamesAddress[i]] == true) {
                totalValue = totalValue.add(
                    _getTokenValues(nonBMNamesAddress[i])
                );
            }
        }
        return totalValue;
    }

    /// @dev return target address
    function getTargetNamesAddress()
        external
        view
        returns (address[] memory _targetNamesAddress)
    {
        return targetNamesAddress;
    }

    /// @dev return weight of each token in the fund
    function getTargetWeightsAddress()
        external
        view
        returns (uint256[] memory targetWeightsAddress)
    {
        targetWeightsAddress = new uint256[](targetNamesAddress.length);
        for (uint256 i; i < targetNamesAddress.length; i++) {
            targetWeightsAddress[i] = getTargetWeight(targetNamesAddress[i]);
        }
        return targetWeightsAddress;
    }

    /// @dev Get token balance
    function getBalance(address fromAdd) external view returns (uint256) {
        return _getBalance(fromAdd);
    }

    function getBalanceInUSD(address fromAdd) external view returns (uint256) {
        return _getBalanceInUSD(fromAdd);
    }

    /// @dev return weight of each token in the fund
    function getTargetWeight(address addr) public view returns (uint256) {
        return TargetWeight[addr];
    }

    /// @dev return unit price
    function getUnitPrice() external view returns (uint256) {
        return _getUnitPrice();
    }

    /// @dev return unit price in USDT
    function getUnitPriceInUSD() external view returns (uint256) {
        return _getUnitPriceInUSD();
    }

    /// @dev returns the last price from token.
    function getLatestPrice(address targetAdd) external view returns (uint256) {
        return _getLatestPrice(targetAdd);
    }

    /// @dev return fund total value in BNB
    function getFundValues() external view returns (uint256) {
        return _getFundValues();
    }

    /// @dev return token value in the vault in BNB
    function getTokenValues(address tokenaddress)
        external
        view
        returns (uint256)
    {
        return _getTokenValues(tokenaddress);
    }

    /// @dev Get All the fund data needed for client
    function getFundDataAll()
        external
        view
        returns (AltairLib.FundInfo memory)
    {
        return
            AltairLib.FundInfo({
                fund: address(this),
                fundName: name,
                fundSymbol: symbol,
                token: address(this),
                count: _getNonBMLength(),
                totalValue: _getFundValues(),
                unitPrice: _getUnitPrice(),
                unitPriceInUSD: _getUnitPriceInUSD(),
                totalSupply: totalSupply(),
                manager: managerOwner,
                version: version,
                community: community,
                dca: dca,
                copytrading: copytrading
            });
    }

    /// @dev return total supply of naliAltair for id
    function totalSupply() public view returns (uint256) {
        return factory.totalSupply(address(this));
    }

    /*----FEES--------------------------------------*/

    /// @dev transfer fee on Subscribe().
    function _handleFeeTransferSubscribe(uint256 swapOutput)
        internal
        returns (uint256 finalSwapOutput)
    {
        uint256 platformFee = IAltairFactory(factory).subscribeFee();
        uint256 platformUnit = swapOutput.mul(platformFee).div(10000);
        address platformWallet = IAltairFactory(factory).treasury();

        if (platformUnit > 0) {
            TransferHelper.safeTransferBNB(platformWallet, platformUnit);
        }

        uint256 managerFeeBps = IAltairFactory(factory).managerFee();

        require(managerFeeBps + platformFee <= 10000, "Sum of fees > 100%");

        uint256 managerUnit = swapOutput.mul(managerFeeBps).div(10000);

        if (managerUnit > 0 && copytrading == true) {
            TransferHelper.safeTransferBNB(managerToCopy, managerUnit);
        } else if (managerUnit > 0 && copytrading == false) {
            TransferHelper.safeTransferBNB(managerOwner, managerUnit);
        }

        finalSwapOutput = swapOutput.sub(platformUnit).sub(managerUnit);
        return (finalSwapOutput);
    }

    /// @dev transfer fee on Redeem().
    function _handleFeeTransferRedeem(uint256 swapOutput)
        internal
        returns (uint256 finalSwapOutput)
    {
        uint256 platformFee = IAltairFactory(factory).redeemFee();
        uint256 platformUnit = swapOutput.mul(platformFee).div(10000);
        address platformWallet = IAltairFactory(factory).treasury();

        if (platformUnit > 0) {
            TransferHelper.safeTransferBNB(platformWallet, platformUnit);
        }

        uint256 managerFeeBps = IAltairFactory(factory).managerFee();
        uint256 managerUnit = swapOutput.mul(managerFeeBps).div(10000);

        if (managerUnit > 0 && copytrading == true) {
            TransferHelper.safeTransferBNB(managerToCopy, managerUnit);
        } else if (managerUnit > 0 && copytrading == false) {
            TransferHelper.safeTransferBNB(managerOwner, managerUnit);
        }

        finalSwapOutput = swapOutput.sub(platformUnit).sub(managerUnit);
        return (finalSwapOutput);
    }

    /*----COPY TRADING--------------------------------------*/

    /// @dev factory refresh copytrading.
    function updateCopyTrading() public returns (bool) {
        require(
            msg.sender == address(factory) ||
                msg.sender == address(managerOwner),
            "Not Auth"
        );

        address[] memory _toAddresses = new address[](
            fundToCopy.getTargetNamesAddress().length
        );

        uint256[] memory _targetWeight = new uint256[](
            fundToCopy.getTargetWeightsAddress().length
        );

        _toAddresses = fundToCopy.getTargetNamesAddress();

        _targetWeight = fundToCopy.getTargetWeightsAddress();

        uint256 totalValueB4 = _getFundValues();
        _createTargetNames(_toAddresses, _targetWeight);
        uint256 totalValue = _getFundValues();

        emit CreateTargetNamesComplete(
            totalValueB4,
            totalValue,
            _toAddresses,
            _targetWeight
        );
        return true;
    }

    /// @dev user start CopyTrading
    function setCopyTrading(bool isCopy, address fund) public returns (bool) {
        onlyManager();
        if (isCopy == false) {
            copytrading = isCopy;
        } else {
            fundToCopy = IAltairFund(fund);

            managerToCopy = fundToCopy.managerOwner();

            rebalanceCycle = fundToCopy.rebalanceCycle();

            copytrading = isCopy;

            address[] memory _toAddresses = new address[](
                fundToCopy.getTargetNamesAddress().length
            );

            uint256[] memory _targetWeight = new uint256[](
                fundToCopy.getTargetWeightsAddress().length
            );

            _toAddresses = fundToCopy.getTargetNamesAddress();

            _targetWeight = fundToCopy.getTargetWeightsAddress();

            _createTargetNames(_toAddresses, _targetWeight);
        }

        emit ManagerSetCopyTrading(
            address(fundToCopy),
            address(managerToCopy),
            address(this)
        );

        return true;
    }

    /*----DCA/AUTO-BUY--------------------------------------*/

    function setDCA(bool dca) public returns (bool) {
        onlyManager();
        dca = dca;
        return true;
    }

    /*----MANAGER OPS--------------------------------------*/

    function setManagerMonthlyFee(uint256 fee) external returns (bool) {
        onlyManager();
        require(fee <= managerMaxMonthlyFee, "FeeTooHigh");

        managerMonthlyFee = fee;

        managerSetMonthlyFeeTimestamp = block.timestamp + 30 days;

        //managerSetMonthlyFeeTimestamp = block.timestamp + 1 minutes;

        managerMonthlyTimestamp = block.timestamp + 30 days;

        emit ManagerMonthlyFeeSet(
            managerMonthlyFee,
            managerOwner,
            block.timestamp
        );

        return true;
    }

    function redeemManagerMonthlyFees() external returns (bool) {
        onlyManager();

        require(checkSubscription(), "Sub Not Pay");

        require(block.timestamp > managerMonthlyTimestamp, "Wait30DForReward");

        require(
            block.timestamp > managerSetMonthlyFeeTimestamp,
            "Wait30DFromSet"
        );

        uint256 fakeBurnAmount = managerMonthlyFee.mul(totalSupply()).div(
            10000
        );

        AltairLib.TradeParams memory tp;

        tp.amount = fakeBurnAmount;
        tp.priceImpactTolerance = 10;
        tp.deadline = block.timestamp;
        tp.returnInBase = true;

        uint256 redeemratio = tp.amount.mul(1e18).div(totalSupply());

        require(redeemratio > 0, "MustBeZero");

        uint256 totalBaseBal = address(this).balance;
        uint256 entitledBNB = redeemratio.mul(totalBaseBal).div(1e18);
        uint256 remainedBNB = totalBaseBal.sub(entitledBNB);

        uint256 priceImpactTollerance = tp.priceImpactTolerance;
        uint256 deadline = tp.deadline;

        //start to transfer back to investor based on the targets
        for (uint256 i; i < targetNamesAddress.length; i++) {
            AltairLib.transferData memory _transferData = _getTransferAmt(
                targetNamesAddress[i],
                redeemratio
            );
            if (_transferData.totalTrfAmt > 0) {
                TransferHelper.safeApprove(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    uint256(int256(-1))
                );

                TransferHelper.safeTransfer(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    _transferData.totalTrfAmt
                );

                IAltairSwap(payable(address(factory.altairSwap())))
                    .swapTokenToBNB{value: 0}(
                    targetNamesAddress[i],
                    _transferData.totalTrfAmt,
                    deadline,
                    address(this),
                    priceImpactTollerance
                );
            }
        }

        uint256 newTotalBaseBal = address(this).balance;
        uint256 totalOutput = newTotalBaseBal.sub(remainedBNB);
        uint256 finalSwapOutput = _handleFeeTransferRedeem(totalOutput);
        TransferHelper.safeTransferBNB(managerOwner, finalSwapOutput);
        _transferNonBM(redeemratio, managerOwner);
        managerMonthlyTimestamp = block.timestamp + 5 minutes; // time for testnet test.

        emit ManagerMonthlyFeePayed(
            managerMonthlyFee,
            fakeBurnAmount,
            redeemratio,
            managerOwner,
            block.timestamp
        );

        return true;
    }

    /// @dev pause fund
    function setPause(bool _pause) public {
        onlyManager();

        pause = _pause;
    }

    /// @dev return number of target names
    function createTargetNames(
        address[] memory _toAddresses,
        uint256[] memory _targetWeight
    ) public payable {
        onlyManager();
        require(checkSubscription(), "SubNotPay");
        require(copytrading == false, "CopyActive");
        require((targetNamesAddress.length == 0), "TargetNames0");

        uint256 totalValueB4 = _getFundValues();
        _createTargetNames(_toAddresses, _targetWeight);
        uint256 totalValues = _getFundValues();

        emit CreateTargetNamesComplete(
            totalValueB4,
            totalValues,
            _toAddresses,
            _targetWeight
        );
    }

    /// @dev update rebalanceCycle
    function updateRebalancePeriod(uint256 newCycle) external {
        onlyManager();

        rebalanceCycle = newCycle;
        emit RebalanceCycleUpdate(rebalanceCycle, newCycle, block.timestamp);
    }

    /// @dev update manager fee and wallet
    function updateManagerProperty(address newManager, bool _community)
        external
        payable
    {
        onlyManager();
        managerOwner = newManager;
        community = community;
    }

    /// @dev update Non Balance Manager Names
    function updateNonBMNames(
        address[] calldata nonBMaddress,
        bool[] calldata nonBM
    ) public {
        onlyManager();

        if (nonBMNamesAddress.length > 0) {
            for (uint256 i; i < nonBMNamesAddress.length; i++) {
                nonBMNamesMapping[nonBMNamesAddress[i]] = false;
            }
            delete nonBMNamesAddress;
        }

        for (uint256 i; i < nonBMaddress.length; i++) {
            //make sure it is not in bm target
            require(TargetWeight[nonBMaddress[i]] == 0, "InBalanceManager");
            nonBMNamesMapping[nonBMaddress[i]] = nonBM[i];
            nonBMNamesAddress.push(nonBMaddress[i]);
        }
    }

    /// @dev perform rebalance with new weight and reset next rebalance period
    function rebalance(
        address[] memory toAddresses,
        uint256[] memory targetWeight,
        uint256 _deadline,
        uint256 _priceImpactTolerance
    ) public payable returns (uint256 baseccyBal) {
        onlyManager();

        require(checkSubscription(), "SubNotPay");

        uint256 totalValueB4 = _getFundValues();

        if (copytrading) {
            toAddresses = fundToCopy.getTargetNamesAddress();

            targetWeight = fundToCopy.getTargetWeightsAddress();
        }

        //get delete names
        AltairLib.DeletedNames[] memory deletedNames = _getDeleteNames(
            toAddresses
        );

        // move to base balance
        for (uint256 x = 0; x < deletedNames.length; x++) {
            if (deletedNames[x].token != address(0)) {
                _moveNonIndexNameToBase(
                    deletedNames[x].token,
                    _deadline,
                    _priceImpactTolerance
                );
            }
        }

        // update new target
        _createTargetNames(toAddresses, targetWeight);

        //rebalance
        baseccyBal = _rebalance(_deadline, _priceImpactTolerance);

        uint256 totalValue = _getFundValues();

        emit RebalanceComplete(totalValueB4, totalValue);

        return baseccyBal;
    }

    /// @dev fund owner move any name back to BNB

    function moveNonIndexNameToBase(
        address tokenaddress,
        uint256 deadline,
        uint256 priceImpactTolerance
    ) external payable returns (uint256 balanceToken, uint256 swapOutput) {
        onlyManager();

        (balanceToken, swapOutput) = _moveNonIndexNameToBase(
            tokenaddress,
            deadline,
            priceImpactTolerance
        );
        return (balanceToken, swapOutput);
    }

    /*----USER OPS--------------------------------------*/

    /// @dev perform subscription based on ratio setup

    function subscribe(AltairLib.TradeParams memory tradeParams)
        external
        payable
        nonReentrant
        returns (uint256)
    {
        require(pause == false, "Pause");
        require(targetNamesAddress.length > 0, "NoTarget");

        uint256 totalValueB4 = _getFundValues().sub(msg.value);

        uint256 finalSwapOutput = _handleFeeTransferSubscribe(
            tradeParams.amount
        );

        tradeParams.amount = finalSwapOutput;

        (uint256 mintQty, uint256 fundvalue) = _getMintQty(finalSwapOutput);

        factory.mint(address(this), msg.sender, mintQty, EMPTY_DATA);

        uint256 priceImpactTollerance = tradeParams.priceImpactTolerance;
        uint256 deadline = tradeParams.deadline;

        // if hit rebalance period, do rebalance after minting qty

        if (dca == false) {
            if (nextRebalance < block.number) {
                _rebalance(
                    tradeParams.deadline,
                    tradeParams.priceImpactTolerance
                );
            } else {
                uint256 totalSubs = address(this).balance;

                if (!_isSmallSubs(fundvalue, totalSubs)) {
                    for (uint256 i; i < targetNamesAddress.length; i++) {
                        uint256 proposalQty = _getTargetWeightQty(
                            targetNamesAddress[i],
                            totalSubs
                        );

                        if (proposalQty > 0) {
                            IAltairSwap(address(factory.altairSwap()))
                                .swapBNBToTokens{value: proposalQty}(
                                targetNamesAddress[i],
                                proposalQty,
                                deadline,
                                address(this),
                                priceImpactTollerance
                            );
                        }
                    }
                }
            }
        }

        uint256 totalValue = _getFundValues();

        emit SubscribeComplete(totalValueB4, totalValue, msg.sender, mintQty);

        return mintQty;
    }

    /// @dev perform redemption based on unit redeem

    function redeem(AltairLib.TradeParams memory tradeParams)
        public
        payable
        nonReentrant
        returns (uint256)
    {
        uint256 totalValueB4 = _getFundValues();

        uint256 redeemratio = tradeParams.amount.mul(1e18).div(totalSupply());

        require(redeemratio > 0, "MustBeZero");

        if (msg.sender != address(this)) {
            factory.burn(address(this), msg.sender, tradeParams.amount);
        }

        uint256 totalBaseBal = address(this).balance;
        uint256 entitledBNB = redeemratio.mul(totalBaseBal).div(1e18);
        uint256 remainedBNB = totalBaseBal.sub(entitledBNB);

        uint256 priceImpactTollerance = tradeParams.priceImpactTolerance;
        uint256 amount = tradeParams.amount;
        uint256 deadline = tradeParams.deadline;

        //start to transfer back to investor based on the targets
        for (uint256 i; i < targetNamesAddress.length; i++) {
            AltairLib.transferData memory _transferData = _getTransferAmt(
                targetNamesAddress[i],
                redeemratio
            );
            if (_transferData.totalTrfAmt > 0) {
                TransferHelper.safeApprove(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    uint256(int256(-1))
                );

                TransferHelper.safeTransfer(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    _transferData.totalTrfAmt
                );

                IAltairSwap(payable(address(factory.altairSwap())))
                    .swapTokenToBNB{value: 0}(
                    targetNamesAddress[i],
                    _transferData.totalTrfAmt,
                    deadline,
                    address(this),
                    priceImpactTollerance
                );
            }
        }

        uint256 newTotalBaseBal = address(this).balance;
        uint256 totalOutput = newTotalBaseBal.sub(remainedBNB);
        uint256 finalSwapOutput = _handleFeeTransferRedeem(totalOutput);
        TransferHelper.safeTransferBNB(msg.sender, finalSwapOutput);
        _transferNonBM(redeemratio, msg.sender);
        uint256 totalValue = _getFundValues();
        address investor = msg.sender;

        emit RedeemComplete(totalValueB4, totalValue, investor, amount);

        return redeemratio;
    }

    /// @dev get the proportional token without swapping it in emergency case
    function emergencyRedeem(uint256 redeemUnit, address investorAddress)
        external
        payable
    {
        uint256 totalValueB4 = _getFundValues();

        uint256 redeemratio = redeemUnit.mul(1e18).div(totalSupply());
        require(redeemratio > 0, "MustBeZero");
        factory.burn(address(this), msg.sender, redeemUnit);
        uint256 totalBaseBal = address(this).balance;
        uint256 totalOutput = redeemratio.mul(totalBaseBal).div(1e18);
        TransferHelper.safeTransferBNB(investorAddress, totalOutput);

        for (uint256 i; i < targetNamesAddress.length; i++) {
            AltairLib.transferData memory _transferData = _getTransferAmt(
                targetNamesAddress[i],
                redeemratio
            );
            if (_transferData.totalTrfAmt > 0) {
                TransferHelper.safeTransfer(
                    targetNamesAddress[i],
                    investorAddress,
                    _transferData.totalTrfAmt
                );
            }
        }

        uint256 totalValue = _getFundValues();

        emit EmergencyRedeemComplete(totalValueB4, totalValue, true);
    }

    /*----FACTORY OPS--------------------------------------*/

    /// @dev check factory subscription
    function checkSubscription() public view returns (bool) {
        if (
            IAltairFactory(factory).monthlyCost() > 0 &&
            IAltairFactory(factory).subscriptions(address(this)) <
            block.timestamp
        ) {
            return false;
        }

        return true;
    }

    /// @dev update  master contract
    function updatePlatformAddresses() external {
        onlyFactory();
        fundMaster = IAltairMaster(IAltairFactory(factory).fundMaster());
        WETH = address(IAltairFactory(factory).NATIVE());
    }

    function updateManagerMaxMonthlyFee(uint256 fee) external {
        require(fee <= 10000, "FeeTooHigh");
        onlyFactory();
        managerMaxMonthlyFee = fee;
    }

    /*----INTERNAL FUNCTIONS--------------------------------------*/

    /// @dev return Non Balance Manager lenght
    function _getNonBMLength() internal view returns (uint256) {
        return nonBMNamesAddress.length;
    }

    /// @dev return target amount based on weight of each token in the fund
    function _getTargetWeightQty(address targetAdd, uint256 srcQty)
        internal
        view
        returns (uint256)
    {
        return TargetWeight[targetAdd].mul(srcQty).div(10000);
    }

    function _getDeleteNames(address[] memory toAddresses)
        internal
        view
        returns (AltairLib.DeletedNames[] memory deletedNames)
    {
        deletedNames = new AltairLib.DeletedNames[](targetNamesAddress.length);

        // identitfy deleted name
        for (uint256 i; i < targetNamesAddress.length; i++) {
            uint256 matchtotal = 1;
            for (uint256 x; x < toAddresses.length; x++) {
                if (targetNamesAddress[i] == toAddresses[x]) {
                    break;
                } else if (
                    targetNamesAddress[i] != toAddresses[x] &&
                    toAddresses.length == matchtotal
                ) {
                    deletedNames[i].token = targetNamesAddress[i];
                }
                matchtotal++;
            }
        }
        return deletedNames;
    }

    function _getNewFundUnits(
        uint256 totalFundB4,
        uint256 totalValueAfter,
        uint256 totalSupply
    ) internal pure returns (uint256) {
        if (totalValueAfter == 0) return 0;
        if (totalFundB4 == 0) return totalValueAfter;

        uint256 totalUnitAfter = totalValueAfter.mul(totalSupply).div(
            totalFundB4
        );

        require(
            totalSupply < totalUnitAfter,
            "Total Supply Must Be Less TotalUnitAfter"
        );

        uint256 mintUnit = totalUnitAfter.sub(totalSupply);

        return mintUnit;
    }

    function _getBalance(address fromAdd) internal view returns (uint256) {
        if (IERC20Upgradeable(fromAdd) == IERC20Upgradeable(BaseToken))
            return address(this).balance;
        return IERC20Upgradeable(fromAdd).balanceOf(address(this));
    }

    function _getBalanceInUSD(address fromAdd) internal view returns (uint256) {
        uint256 unit = _getUnitPriceInUSD();
        if (IERC20Upgradeable(fromAdd) == IERC20Upgradeable(BaseToken))
            return address(this).balance.mul(unit).div(1e18);
        return
            IERC20Upgradeable(fromAdd).balanceOf(address(this)).mul(unit).div(
                1e18
            );
    }

    function _getUnitPriceInUSD() internal view returns (uint256) {
        uint256 totalValue = _getUnitPrice();

        // Band Protocol Oracle
        uint256 toBasePrice = fundMaster.getPriceFromBand(
            BaseTokenName,
            "USDT"
        );

        return totalValue.mul(toBasePrice).div(1e18);
    }

    function _isSmallSubs(uint256 fundvalue, uint256 subsAmt)
        internal
        pure
        returns (bool)
    {
        if (fundvalue == 0) return false;
        uint256 percentage = subsAmt.mul(10000).div(fundvalue);

        //if more than 0.1% to the fund, consider not small
        if (percentage > 100) return false;

        return true;
    }

    function _getUnitPrice() internal view returns (uint256) {
        uint256 totalValueB4 = _getFundValues();
        if (totalValueB4 == 0) return 0;
        uint256 totalUnitB4 = totalSupply();
        if (totalUnitB4 == 0) return 0;
        return totalValueB4.mul(1e18).div(totalUnitB4);
    }

    function _getFundValues() internal view returns (uint256) {
        //get BNB value first if any
        uint256 totalValue = address(this).balance;
        for (uint256 i; i < targetNamesAddress.length; i++) {
            totalValue = totalValue.add(_getTokenValues(targetNamesAddress[i]));
        }

        for (uint256 i; i < nonBMNamesAddress.length; i++) {
            if (nonBMNamesMapping[nonBMNamesAddress[i]] == true) {
                totalValue = totalValue.add(
                    _getTokenValues(nonBMNamesAddress[i])
                );
            }
        }

        return totalValue;
    }

    function _getTokenValues(address tokenaddress)
        internal
        view
        returns (uint256)
    {
        uint256 tokenBalance = _getBalance(tokenaddress);
        uint256 price = _getLatestPrice(tokenaddress); //price from token to BNB
        return tokenBalance.mul(uint256(price)).div(1e18);
    }

    function _getLatestPrice(address targetAdd)
        internal
        view
        returns (uint256)
    {
        if (targetAdd == WETH) return 1e18;

        return fundMaster.getPriceByAddress(targetAdd, BaseTokenName);
    }

    /// @dev Calc return balance during redemption
    function _getTransferAmt(address underyingAdd, uint256 redeemratio)
        internal
        view
        returns (AltairLib.transferData memory transData)
    {
        AltairLib.transferData memory _transferData;
        _transferData.totalUnderlying = _getBalance(underyingAdd);
        uint256 qtyToTrf = redeemratio.mul(_transferData.totalUnderlying).div(
            1e18
        );
        _transferData.totalTrfAmt = qtyToTrf;
        return _transferData;
    }

    /// @dev Calc qty to issue during subscription
    function _getMintQty(uint256 srcQty)
        internal
        view
        returns (uint256 mintQty, uint256 totalFundB4)
    {
        uint256 totalFundAfter = _getFundValues();
        totalFundB4 = totalFundAfter.sub(srcQty);
        mintQty = _getNewFundUnits(totalFundB4, totalFundAfter, totalSupply());
        return (mintQty, totalFundB4);
    }

    /// @dev Get active overweight assets to sell.
    function _getActiveOverWeight(address destAddress, uint256 totalfundvalue)
        internal
        view
        returns (
            uint256 destRebQty,
            uint256 destActiveWeight,
            bool overweight,
            uint256 fundWeight
        )
    {
        destRebQty = 0;
        uint256 destTargetWeight = TargetWeight[destAddress];
        uint256 destValue = _getTokenValues(destAddress);
        fundWeight = destValue.mul(10000).div(totalfundvalue);
        overweight = fundWeight > destTargetWeight;
        destActiveWeight = overweight
            ? fundWeight.sub(destTargetWeight)
            : destTargetWeight.sub(fundWeight);
        if (overweight) {
            uint256 price = _getLatestPrice(destAddress);
            destRebQty = destActiveWeight
                .mul(totalfundvalue)
                .mul(1e18)
                .div(price)
                .div(10000);
        }
        return (destRebQty, destActiveWeight, overweight, fundWeight);
    }

    function _rebalance(uint256 deadline, uint256 priceImpactTolerance)
        internal
        returns (uint256 baseccyBal)
    {
        //sell overweight names first
        (
            AltairLib.UnderWeightData[] memory underweightNames,
            uint256 totalunderActiveweight
        ) = _sellOverWeightNames(deadline, priceImpactTolerance);
        //get total proceeds in BNB after seling overweight names and buy underweight names
        baseccyBal = _buyUnderWeightNames(
            deadline,
            priceImpactTolerance,
            underweightNames,
            totalunderActiveweight
        );
        nextRebalance = block.number.add(rebalanceCycle);
        return baseccyBal;
    }

    function _sellOverWeightNames(
        uint256 deadline,
        uint256 priceImpactTolerance
    )
        internal
        returns (
            AltairLib.UnderWeightData[] memory underweightNames,
            uint256 totalunderActiveweight
        )
    {
        uint256 totalfundvaluebefore = _getFundValues();

        totalunderActiveweight = 0;

        underweightNames = new AltairLib.UnderWeightData[](
            targetNamesAddress.length
        );

        //get overweight name
        for (uint256 i; i < targetNamesAddress.length; i++) {
            (
                uint256 rebalQty,
                uint256 destActiveWeight,
                bool overweight,
                uint256 fundWeight
            ) = _getActiveOverWeight(
                    targetNamesAddress[i],
                    totalfundvaluebefore
                );
            if (overweight) //sell token to BNB
            {
                TransferHelper.safeApprove(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    rebalQty
                );

                TransferHelper.safeTransfer(
                    targetNamesAddress[i],
                    address(factory.altairSwap()),
                    rebalQty
                );

                IAltairSwap(payable(address(factory.altairSwap())))
                    .swapTokenToBNB{value: 0}(
                    targetNamesAddress[i],
                    rebalQty,
                    deadline,
                    payable(address(this)),
                    priceImpactTolerance
                );
            } else {
                //collect the total fund weight for underweight names
                if (destActiveWeight > 0) {
                    AltairLib.UnderWeightData memory _underWeightData;
                    _underWeightData.token = targetNamesAddress[i];
                    _underWeightData.fundWeight = fundWeight;
                    _underWeightData.activeWeight = destActiveWeight;
                    _underWeightData.overweight = false;
                    underweightNames[i] = _underWeightData;

                    totalunderActiveweight = totalunderActiveweight.add(
                        destActiveWeight
                    );
                }
            }
        }

        return (underweightNames, totalunderActiveweight);
    }

    /// @dev Get active underweight assets to buy.
    function _buyUnderWeightNames(
        uint256 deadline,
        uint256 priceImpactTolerance,
        AltairLib.UnderWeightData[] memory underweightNames,
        uint256 totalunderActiveweight
    ) internal returns (uint256 baseccyBal) {
        //get total proceeds in BNB after seling overweight names
        baseccyBal = address(this).balance;
        for (uint256 i; i < underweightNames.length; i++) {
            if (underweightNames[i].token != address(0)) {
                uint256 rebaseActiveWgt = underweightNames[i]
                    .activeWeight
                    .mul(10000)
                    .div(totalunderActiveweight);
                uint256 rebBuyQty = rebaseActiveWgt.mul(baseccyBal).div(10000);
                if (rebBuyQty > 0 && rebBuyQty <= address(this).balance) {
                    IAltairSwap(address(factory.altairSwap())).swapBNBToTokens{
                        value: rebBuyQty
                    }(
                        underweightNames[i].token,
                        rebBuyQty,
                        deadline,
                        address(this),
                        priceImpactTolerance
                    );
                }
            }
        }
        return baseccyBal;
    }

    /// @dev Swap Non Index Token to Native.
    function _moveNonIndexNameToBase(
        address tokenaddress,
        uint256 deadline,
        uint256 priceImpactTolerance
    ) internal returns (uint256 balanceToken, uint256 swapOutput) {
        balanceToken = _getBalance(tokenaddress);

        TransferHelper.safeApprove(
            tokenaddress,
            address(factory.altairSwap()),
            balanceToken
        );

        TransferHelper.safeTransfer(
            tokenaddress,
            address(factory.altairSwap()),
            balanceToken
        );

        IAltairSwap(payable(address(factory.altairSwap()))).swapTokenToBNB{
            value: 0
        }(
            tokenaddress,
            balanceToken,
            deadline,
            payable(address(this)),
            priceImpactTolerance
        );

        return (balanceToken, 0);
    }

    function _createTargetNames(
        address[] memory toAddresses,
        uint256[] memory targetWeight
    ) internal {
        uint256 totalWeight;
        for (uint256 i; i < targetWeight.length; i++) {
            totalWeight += i;
        }
        require(totalWeight == 10000, "Total weight should be 10000");

        if (targetNamesAddress.length > 0) {
            for (uint256 i; i < targetNamesAddress.length; i++) {
                TargetWeight[targetNamesAddress[i]] = 0;
            }
            delete targetNamesAddress;
        }

        for (uint256 i; i < toAddresses.length; i++) {
            TargetWeight[toAddresses[i]] = targetWeight[i];
            targetNamesAddress.push(toAddresses[i]);

            //reset nonBM mapping if it is bm target name
            nonBMNamesMapping[toAddresses[i]] = false;
        }
    }

    function _transferNonBM(uint256 redeemratio, address investorAddress)
        internal
    {
        if (nonBMNamesAddress.length == 0) return;

        for (uint256 i; i < nonBMNamesAddress.length; i++) {
            //make sure it is not in bm target
            if (TargetWeight[nonBMNamesAddress[i]] == 0) {
                uint256 tokenBalance = _getBalance(nonBMNamesAddress[i]);
                uint256 trfOutput = redeemratio.mul(tokenBalance).div(1e18);
                if (trfOutput > 0) {
                    TransferHelper.safeTransfer(
                        nonBMNamesAddress[i],
                        investorAddress,
                        trfOutput
                    );
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

pragma solidity 0.8.14;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

library AltairLib {
    struct ExecutedPermitted {
        address target;
        bytes data;
        uint256 value;
        uint256 executionTimestamp;
        address executor;
    }

    struct FundInfo {
        address fund;
        string fundName;
        string fundSymbol;
        address token;
        uint256 count;
        uint256 totalValue;
        uint256 unitPrice;
        uint256 unitPriceInUSD;
        uint256 totalSupply;
        address manager;
        uint256 version;
        bool community;
        bool dca;
        bool copytrading;
    }

    struct FeeTokens {
        address tokenAddress;
        bool hadFee;
    }

    // Info of each pool.
    struct TradeParams {
        uint256 amount;
        uint256 priceImpactTolerance;
        uint256 deadline;
        bool returnInBase;
    }

    struct transferData {
        address[] targetNamesAddress;
        uint256 totalTrfAmt;
        uint256 totalUnderlying;
        uint256 qtyToTrfAToken;
    }

    struct UnderWeightData {
        uint256 activeWeight;
        uint256 fundWeight;
        bool overweight;
        address token;
    }

    struct DeletedNames {
        address token;
        uint256 targetWeight;
    }

    struct PancakePriceToken {
        string tokenname;
        address addressToken;
    }
}

pragma solidity 0.8.14;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, bytes memory data) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../libs/AltairLib.sol";

interface IAltairFund {

    function executeAuthorized(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external returns (bool);

    function setAuthorized(address _addr, bool _bool) external returns (bool);

    function setDCA(bool _dca) external returns (bool);

    function updateManagerMaxMonthlyFee(uint256 _fee) external ;
    
    function version() external view returns (uint256);

    function authorized(address _target) external view returns (bool);

    function community() external view returns (bool);

    function dca() external view returns (bool);

    function copytrading() external view returns (bool);

    function sltp() external view returns (address);

    function executeCustomTx(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external returns (bool);

    function transferWETH(address _target, uint256 _value)
        external
        payable
        returns (bool);

    function managerMonthlyTimestamp() external view returns (uint256);

    function getTargetWeight(address addr) external view returns (uint256);

    function managerOwner() external view returns (address managerOwner);

    function getTargetWeightQty(address targetAdd, uint256 srcQty)
        external
        view
        returns (uint256);

    function getBalance(address fromAdd)
        external
        view
        returns (uint256);

    function totalSupply() external view returns (uint256);
    
    function getUnitPrice() external view returns (uint256);

    function getUnitPriceInUSD() external view returns (uint256);

    function getFundDataAll() external view returns (AltairLib.FundInfo memory);

    function getFundValues() external view returns (uint256);

    function getNonBMLength() external view returns (uint256);

    function updateManagerProperty(address managerAdd) external payable;

    function updateManagerFee(uint256 newFeebps) external payable;

    function updateRebalancePeriod(uint256 newCycle) external payable;

    function redeem(
        AltairLib.TradeParams memory _tradeParams,
        address _investorAddress
    ) external payable returns (uint256);

    function rebalance(
        address[] calldata _toAddresses,
        uint256[] calldata _targetWeight,
        uint256 deadline,
        uint256 priceImpactTolerance
    ) external payable returns (uint256 baseccyBal);

    function subscribe(
        AltairLib.TradeParams memory _tradeParams,
        address _investorAddress
    ) external payable returns (uint256);

    function moveNonIndexNameToBase(
        address _tokenaddress,
        uint256 deadline,
        uint256 priceImpactTolerance
    ) external returns (uint256 balanceToken, uint256 swapOutput);

    function createTargetNames(
        address[] memory _toAddresses,
        uint256[] memory _targetWeight
    ) external payable;

    function emergencyRedeem(uint256 redeemUnit, address _investorAddress)
        external
        payable;

    function getTargetNamesAddress()
        external
        view
        returns (address[] memory _targetNamesAddress);

    function getTargetWeightsAddress()
        external
        view
        returns (uint256[] memory _targetWeights);

    function updatePlatformAddresses() external;

    function name() external view returns (string memory);

    function fund() external view returns (address);

    function symbol() external view returns (string memory);

    function updateCopyTrading() external returns (bool);

    function rebalanceCycle() external view returns (uint256);

    function getTransferAmt(address underyingAdd, uint256 redeemratio)
        external
        view
        returns (AltairLib.transferData calldata transData);

    function nonBMNamesMapping(address _address) external view returns (bool);

    function nonBMNamesAddress() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;


interface IAltairMaster {

    function useChainlinkOracle() external view returns (int256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function getLpPrice(address tokenA, address tokenB) external view returns (uint256 price);

    function getTokenName(address _tokenaddress)
        external
        view
        returns (string memory tokenname);

    function getPriceByAddress(address _targetAdd, string memory _toTokenName)
        external
        view
        returns (uint256);

    function getPancakePrice(address _fromAddr, address _toAddr)
        external
        view
        returns (uint256);

    function getPriceFromBand(string memory _fromToken, string memory _toToken)
        external
        view
        returns (uint256);

    function getRouterAddress() external view returns (address);

    function getUseSupportingFeeOnTransferTokens(address _token)
        external
        view
        returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "../interfaces/IRoles.sol";
import "../libs/AltairLib.sol";
import "./IProxyCall.sol";

interface IAltairFactory {
    function altairSwap() external view returns (address);

    function governor() external view returns (address);

    function getFunds() external view returns (address[] memory);

    function shop() external view returns (address);

    function feeManager() external view returns (address);

    function totalSupply(address _fund) external view returns (uint256);

    function naliAltair() external view returns (address);

    function monthlyCost() external view returns (uint256);

    function subscriptions(address _fund) external view returns (uint256);

    function containsFund(address _fund) external view returns (bool);

    function getFee() external returns (uint256);

    function getManagerFee() external returns (uint256);

    function treasury() external view returns (address);

    function fundMaster() external view returns (address);

    function NATIVE() external view returns (address);

    function fee() external view returns (uint256);

    function subscribeFee() external view returns (uint256);

    function redeemFee() external view returns (uint256);

    function managerFee() external view returns (uint256);

    function rolesContract() external returns (IRoles);

    function proxyCallContract() external returns (IProxyCall);

    function swapContract() external view returns (address);

    function managerOwner() external view returns (address);

    function getFundId(address _address) external view returns (uint256);

    function naliToken() external view returns (address);

    function useSwapInfo() external view returns (bool);

    function mint(
        address _fund,
        address _account,
        uint256 _amount,
        bytes memory _data
    ) external returns (bool);

    function burn(
        address _fund,
        address _account,
        uint256 _amount
    ) external returns (bool);

    function fundsId(address _fund) external returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

interface IAltairSwap {
    function swapBNBToTokens(
        address toDest,
        uint256 amountIn,
        uint256 deadline,
        address destAddress,
        uint256 priceImpactTolerance
    ) external payable;

    function swapTokenToBNB(
        address token,
        uint256 amountIn,
        uint256 deadline,
        address destAddress,
        uint256 priceImpactTolerance
    ) external payable;

    function addLiquidity(
        address _tokenA,
        uint256 _amount,
        address _fund
    ) external payable;

    function removeLiquidity(
        address _pair,
        uint256 _amount,
        address _destAddress
    ) external ;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
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
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity 0.8.14;

/**
 * @notice Interface for a contract which implements admin roles.
 */
interface IRoles {
  function isAdmin(address account) external view returns (bool);

  function isOperator(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity 0.8.14;

interface IProxyCall {
    function proxyCallAndReturnAddress(
        address externalContract,
        bytes memory callData
    ) external returns (address payable result);
}