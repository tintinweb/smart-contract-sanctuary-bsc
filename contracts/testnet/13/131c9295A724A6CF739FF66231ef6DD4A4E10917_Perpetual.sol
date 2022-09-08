// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../lib/LibOrder.sol";
import "../lib/LibTypes.sol";
import "../lib/LibMath.sol";

import "./MarginAccount.sol";

contract Perpetual is MarginAccount, ReentrancyGuard {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using LibOrder for LibTypes.Side;

    uint256 public totalAccounts;
    address[] public accountList;
    mapping(address => bool) private accountCreated;

    event CreatePerpetual();
    event Paused(address indexed caller);
    event Unpaused(address indexed caller);
    event DisableWithdraw(address indexed caller);
    event EnableWithdraw(address indexed caller);
    event CreateAccount(uint256 indexed id, address indexed trader);
    event Trade(address indexed trader, LibTypes.Side side, uint256 price, uint256 amount);
    event Liquidate(address indexed keeper, address indexed trader, uint256 price, uint256 amount);
    event EnterEmergencyStatus(uint256 price);
    event EnterSettledStatus(uint256 price);

    constructor(
        address _globalConfig,
        // address _devAddress,
        address _collateral,
        uint256 _collateralDecimals
    ) MarginAccount(_globalConfig, _collateral, _collateralDecimals) {
        // devAddress = _devAddress;
        emit CreatePerpetual();
    }

    // disable fallback
    fallback() external payable {
        revert("fallback function disabled");
    }

    /**
     * @dev Called by a pauseControllers, put whole system into paused state.
     */
    function pause() external {
        require(globalConfig.pauseControllers(msg.sender) || globalConfig.owner() == msg.sender, "unauthorized caller");
        require(!paused, "already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauseControllers, put whole system back to normal.
     */
    function unpause() external {
        require(globalConfig.pauseControllers(msg.sender) || globalConfig.owner() == msg.sender, "unauthorized caller");
        require(paused, "not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Called by a withdrawControllers disable withdraw function.
     */
    function disableWithdraw() external {
        require(
            globalConfig.withdrawControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(!withdrawDisabled, "already disabled");
        withdrawDisabled = true;
        emit DisableWithdraw(msg.sender);
    }

    /**
     * @dev Called by a withdrawControllers, enable withdraw function again.
     */
    function enableWithdraw() external {
        require(
            globalConfig.withdrawControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(withdrawDisabled, "not disabled");
        withdrawDisabled = false;
        emit EnableWithdraw(msg.sender);
    }

    /**
     * @notice Force to set cash balance of margin account. Called by administrator to
     *      fix unexpected cash balance.
     *
     * @param trader Address of account owner.
     * @param amount Absolute cash balance value to be set.
     */
    function increaseCashBalance(address trader, uint256 amount) external onlyOwner {
        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        updateCashBalance(trader, amount.toInt256());
    }

    /**
     * @notice Force to set cash balance of margin account. Called by administrator to
     *      fix unexpected cash balance.
     *
     * @param trader Address of account owner.
     * @param amount Absolute cash balance value to be set.
     */
    function decreaseCashBalance(address trader, uint256 amount) external onlyOwner {
        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        updateCashBalance(trader, amount.toInt256().neg());
    }

    /**
     * @notice Set perpetual status to 'emergency'. It can be called multiple times to set price.
     *      In emergency mode, main function like trading / withdrawing is disabled to prevent unexpected loss.
     *
     * @param price Price used as mark price in emergency mode.
     */
    function beginGlobalSettlement(uint256 price) external onlyOwner {
        require(status != LibTypes.Status.SETTLED, "wrong perpetual status");
        status = LibTypes.Status.EMERGENCY;

        settlementPrice = price;
        emit EnterEmergencyStatus(price);
    }

    /**
     * @notice Set perpetual status to 'settled'. It can be call only once in 'emergency' mode.
     *         In settled mode, user is expected to closed positions and withdraw all the collateral.
     */
    function endGlobalSettlement() external onlyOwner {
        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        status = LibTypes.Status.SETTLED;

        emit EnterSettledStatus(settlementPrice);
    }

    /**
     * @notice Deposit collateral to insurance fund to recover social loss. Note that depositing to
     *         insurance fund *DOES NOT* profit to depositor and only administrator can withdraw from the fund.
     *
     * @param rawAmount Amount to deposit.
     */
    function depositToInsuranceFund(uint256 rawAmount) external payable nonReentrant {
        checkDepositingParameter(rawAmount);

        require(rawAmount > 0, "amount must be greater than 0");
        int256 wadAmount = pullCollateral(msg.sender, rawAmount);
        insuranceFundBalance = insuranceFundBalance.add(wadAmount);
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
    }

    /**
     * @notice Withdraw collateral from insurance fund. Only administrator can withdraw from it.
     *
     * @param rawAmount Amount to withdraw.
     */
    function withdrawFromInsuranceFund(uint256 rawAmount) external onlyOwner nonReentrant {
        require(rawAmount > 0, "amount must be greater than 0");
        require(insuranceFundBalance > 0, "insufficient funds");

        int256 wadAmount = toWad(rawAmount);
        require(wadAmount <= insuranceFundBalance, "insufficient funds");
        insuranceFundBalance = insuranceFundBalance.sub(wadAmount);
        pushCollateral(msg.sender, rawAmount);
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
    }

    // End Admin functions

    // Deposit && Withdraw
    /**
     * @notice Deposit collateral to sender's margin account.
     *         When depositing ether rawAmount must strictly equal to
     *
     * @dev    Need approval
     *
     * @param rawAmount Amount to deposit.
     */
    function deposit(uint256 rawAmount) external payable {
        depositImplementation(msg.sender, rawAmount);
    }

    /**
     * @notice Withdraw collateral from sender's margin account. only available in normal state.
     *
     * @param rawAmount Amount to withdraw.
     */
    function withdraw(uint256 rawAmount) external {
        withdrawImplementation(msg.sender, rawAmount);
    }

    /**
     * @notice Close all position and withdraw all collateral remaining in sender's margin account.
     *         Settle is only available in settled state and can be called multiple times.
     */
    function settle() external nonReentrant {
        address payable trader = msg.sender;
        settleImplementation(trader);
        int256 wadAmount = marginAccounts[trader].cashBalance;
        if (wadAmount <= 0) {
            return;
        }
        uint256 rawAmount = toCollateral(wadAmount);
        Collateral.withdraw(trader, rawAmount);
    }

    // Deposit && Withdraw - Whitelisted Only
    /**
     * @notice Deposit collateral for trader into the trader's margin account. The collateral will be transfer
     *         from the trader's ethereum address.
     *         depositFor is only available to administrator.
     *
     * @dev    Need approval
     *
     * @param trader    Address of margin account to deposit into.
     * @param rawAmount Amount of collateral to deposit.
     */
    function depositFor(address trader, uint256 rawAmount) external payable onlyAuthorized {
        depositImplementation(trader, rawAmount);
    }

    /**
     * @notice Withdraw collateral for trader from the trader's margin account. The collateral will be transfer
     *         to the trader's ethereum address.
     *         withdrawFor is only available to administrator.
     *
     * @param trader    Address of margin account to deposit into.
     * @param rawAmount Amount of collateral to deposit.
     */
    function withdrawFor(address payable trader, uint256 rawAmount) external onlyAuthorized {
        withdrawImplementation(trader, rawAmount);
    }

    // Method for public properties
    /**
     * @notice Price to calculate all price-depended properties of margin account.
     *
     * @dev decimals == 18
     *
     * @return Mark price.
     */
    function markPrice() public returns (uint256) {
        return status == LibTypes.Status.NORMAL ? fundingModule.currentMarkPrice() : settlementPrice;
    }

    /**
     * @notice (initial) Margin value of margin account according to mark price.
     *                   See marginWithPrice in MarginAccount.sol.
     *
     * @param trader Address of account owner.
     * @return Initial margin of margin account.
     */
    function positionMargin(address trader) public returns (uint256) {
        return MarginAccount.marginWithPrice(trader, markPrice());
    }

    /**
     * @notice (maintenance) Margin value of margin account according to mark price.
     *         See maintenanceMarginWithPrice in MarginAccount.sol.
     *
     * @param trader Address of account owner.
     * @return Maintanence margin of margin account.
     */
    function maintenanceMargin(address trader) public returns (uint256) {
        return MarginAccount.maintenanceMarginWithPrice(trader, markPrice());
    }

    /**
     * @notice Margin balance of margin account according to mark price.
     *         See marginBalanceWithPrice in MarginAccount.sol.
     *
     * @param trader Address of account owner.
     * @return Margin balance of margin account.
     */
    function marginBalance(address trader) public returns (int256) {
        return MarginAccount.marginBalanceWithPrice(trader, markPrice());
    }

    /**
     * @notice Profit and loss of margin account according to mark price.
     *         See pnlWithPrice in MarginAccount.sol.
     *
     * @param trader Address of account owner.
     * @return Margin balance of margin account.
     */
    function pnl(address trader) public returns (int256) {
        return MarginAccount.pnlWithPrice(trader, markPrice());
    }

    /**
     * @notice Available margin of margin account according to mark price.
     *         See marginBalanceWithPrice in MarginAccount.sol.
     *
     * @param trader Address of account owner.
     * @return Margin balance of margin account.
     */
    function availableMargin(address trader) public returns (int256) {
        return MarginAccount.availableMarginWithPrice(trader, markPrice());
    }

    /**
     * @notice Test if a margin account is safe, using maintenance margin rate.
     *         A unsafe margin account will loss position through liqudating initiated by any other trader,
               to make the whole system safe.
     *
     * @param trader Address of account owner.
     * @return True if give trader is safe.
     */
    function isSafe(address trader) public returns (bool) {
        uint256 currentMarkPrice = markPrice();
        return isSafeWithPrice(trader, currentMarkPrice);
    }

    /**
     * @notice Test if a margin account is safe, using maintenance margin rate according to given price.
     *
     * @param trader           Address of account owner.
     * @param currentMarkPrice Mark price.
     * @return True if give trader is safe.
     */
    function isSafeWithPrice(address trader, uint256 currentMarkPrice) public returns (bool) {
        return
            MarginAccount.marginBalanceWithPrice(trader, currentMarkPrice) >=
            MarginAccount.maintenanceMarginWithPrice(trader, currentMarkPrice).toInt256();
    }

    /**
     * @notice Test if a margin account is bankrupt. Bankrupt is a status indicates the margin account
     *         is completely out of collateral.
     *
     * @param trader           Address of account owner.
     * @return True if give trader is safe.
     */
    function isBankrupt(address trader) public returns (bool) {
        return marginBalanceWithPrice(trader, markPrice()) < 0;
    }

    /**
     * @notice Test if a margin account is safe, using initial margin rate instead of maintenance margin rate.
     *
     * @param trader Address of account owner.
     * @return True if give trader is safe with initial margin rate.
     */
    function isIMSafe(address trader) public returns (bool) {
        uint256 currentMarkPrice = markPrice();
        return isIMSafeWithPrice(trader, currentMarkPrice);
    }

    /**
     * @notice Test if a margin account is safe according to given mark price.
     *
     * @param trader Address of account owner.
     * @param currentMarkPrice Mark price.
     * @return True if give trader is safe with initial margin rate.
     */
    function isIMSafeWithPrice(address trader, uint256 currentMarkPrice) public returns (bool) {
        return availableMarginWithPrice(trader, currentMarkPrice) >= 0;
    }

    /**
     * @notice Test if a margin account is safe according to given mark price.
     *
     * @param trader    Address of account owner.
     * @param maxAmount Mark price.
     * @return True if give trader is safe with initial margin rate.
     */
    function liquidate(address trader, uint256 maxAmount) public onlyNotPaused returns (uint256, uint256) {
        require(msg.sender != trader, "self liquidate");
        require(isValidLotSize(maxAmount), "amount must be divisible by lotSize");
        require(status != LibTypes.Status.SETTLED, "wrong perpetual status");
        require(!isSafe(trader), "safe account");

        uint256 liquidationPrice = markPrice();
        require(liquidationPrice > 0, "price must be greater than 0");

        uint256 liquidationAmount = calculateLiquidateAmount(trader, liquidationPrice);
        uint256 totalPositionSize = marginAccounts[trader].size;
        uint256 liquidatableAmount = totalPositionSize.sub(totalPositionSize.mod(governance.lotSize));
        liquidationAmount = liquidationAmount.ceil(governance.lotSize).min(maxAmount).min(liquidatableAmount);
        require(liquidationAmount > 0, "nothing to liquidate");

        uint256 opened = MarginAccount.liquidate(msg.sender, trader, liquidationPrice, liquidationAmount);
        if (opened > 0) {
            require(availableMarginWithPrice(msg.sender, liquidationPrice) >= 0, "liquidator margin");
        } else {
            require(isSafe(msg.sender), "liquidator unsafe");
        }
        emit Liquidate(msg.sender, trader, liquidationPrice, liquidationAmount);
        return (liquidationPrice, liquidationAmount);
    }

    function tradePosition(
        address taker,
        address maker,
        LibTypes.Side side,
        uint256 price,
        uint256 amount
    ) public onlyNotPaused onlyAuthorized returns (uint256 takerOpened, uint256 makerOpened) {
        require(status != LibTypes.Status.EMERGENCY, "wrong perpetual status");
        require(side == LibTypes.Side.LONG || side == LibTypes.Side.SHORT, "side must be long or short");
        require(isValidLotSize(amount), "amount must be divisible by lotSize");

        takerOpened = MarginAccount.trade(taker, side, price, amount);
        makerOpened = MarginAccount.trade(maker, LibTypes.counterSide(side), price, amount);
        require(totalSize(LibTypes.Side.LONG) == totalSize(LibTypes.Side.SHORT), "imbalanced total size");

        emit Trade(taker, side, price, amount);
        emit Trade(maker, LibTypes.counterSide(side), price, amount);
    }

    function transferCashBalance(
        address from,
        address to,
        uint256 amount
    ) public onlyNotPaused onlyAuthorized {
        require(status != LibTypes.Status.EMERGENCY, "wrong perpetual status");
        MarginAccount.transferBalance(from, to, amount.toInt256());
    }

    function registerNewTrader(address trader) internal {
        emit CreateAccount(totalAccounts, trader);
        accountList.push(trader);
        totalAccounts++;
        accountCreated[trader] = true;
    }

    /**
     * @notice Check type of collateral. If ether, rawAmount must strictly match msg.value.
     *
     * @param rawAmount Amount to deposit
     */
    function checkDepositingParameter(uint256 rawAmount) internal view {
        bool isToken = isTokenizedCollateral();
        require((isToken && msg.value == 0) || (!isToken && msg.value == rawAmount), "incorrect sent value");
    }

    /**
     * @notice Implementation as underlaying of deposit and depositFor.
     *
     * @param trader    Address the collateral will be transferred from.
     * @param rawAmount Amount to deposit.
     */
    function depositImplementation(address trader, uint256 rawAmount) internal onlyNotPaused nonReentrant {
        checkDepositingParameter(rawAmount);
        require(rawAmount > 0, "amount must be greater than 0");
        require(trader != address(0), "cannot deposit to 0 address");

        Collateral.deposit(trader, rawAmount);
        // append to the account list. make the account trackable
        if (!accountCreated[trader]) {
            registerNewTrader(trader);
        }
    }

    /**
     * @notice Implementation as underlaying of withdraw and withdrawFor.
     *
     * @param trader    Address the collateral will be transferred to.
     * @param rawAmount Amount to withdraw.
     */
    function withdrawImplementation(address payable trader, uint256 rawAmount) internal onlyNotPaused nonReentrant {
        require(!withdrawDisabled, "withdraw disabled");
        require(status == LibTypes.Status.NORMAL, "wrong perpetual status");
        require(rawAmount > 0, "amount must be greater than 0");
        require(trader != address(0), "cannot withdraw to 0 address");

        uint256 currentMarkPrice = markPrice();
        require(isSafeWithPrice(trader, currentMarkPrice), "unsafe before withdraw");

        remargin(trader, currentMarkPrice);
        Collateral.withdraw(trader, rawAmount);

        require(isSafeWithPrice(trader, currentMarkPrice), "unsafe after withdraw");
        require(availableMarginWithPrice(trader, currentMarkPrice) >= 0, "withdraw margin");
    }

    /**
     * @notice Implementation as underlaying of settle.
     *
     * @param trader    Address the collateral will be transferred to.
     */
    function settleImplementation(address trader) internal onlyNotPaused {
        require(status == LibTypes.Status.SETTLED, "wrong perpetual status");
        uint256 currentMarkPrice = markPrice();
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        if (account.size == 0) {
            return;
        }
        LibTypes.Side originalSide = account.side;
        close(account, currentMarkPrice, account.size);
        marginAccounts[trader] = account;
        emit UpdatePositionAccount(trader, account, totalSize(originalSide), currentMarkPrice);
    }

    function setFairPrice(uint256 price) public onlyAuthorized {
        fundingModule.setFairPrice(price);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "./LibEIP712.sol";
import "./LibSignature.sol";
import "./LibMath.sol";
import "./LibTypes.sol";


library LibOrder {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;

    bytes32 public constant EIP712_ORDER_TYPE = keccak256(
        abi.encodePacked(
            "Order(address trader,address broker,address perpetual,uint256 amount,uint256 price,bytes32 data)"
        )
    );

    int256 public constant FEE_RATE_BASE = 10 ** 6;

    struct Order {
        address trader;
        address broker;
        address perpetual;
        uint256 amount;
        uint256 price;
        /***
         * Data contains the following values packed into 32 bytes
         * ╔════════════════════╤═══════════════════════════════════════════════════════════╗
         * ║                    │ length(bytes)   desc                                      ║
         * ╟────────────────────┼───────────────────────────────────────────────────────────╢
         * ║ version            │ 1               order version                             ║
         * ║ side               │ 1               0: buy (long), 1: sell (short)            ║
         * ║ isMarketOrder      │ 1               0: limitOrder, 1: marketOrder             ║
         * ║ expiredAt          │ 5               order expiration time in seconds          ║
         * ║ asMakerFeeRate     │ 2               maker fee rate (base 100,000)             ║
         * ║ asTakerFeeRate     │ 2               taker fee rate (base 100,000)             ║
         * ║ salt               │ 8               salt                                      ║
         * ║ isMakerOnly        │ 1               is maker only                             ║
         * ║ isInversed         │ 1               is inversed contract                      ║
         * ║ chainId            │ 8               chain id                                  ║
         * ╚════════════════════╧═══════════════════════════════════════════════════════════╝
         */
        bytes32 data;
    }

    struct OrderParam {
        address trader;
        uint256 amount;
        uint256 price;
        bytes32 data;
        LibSignature.OrderSignature signature;
    }

    /**
     * @dev Get order hash from parameters of order. Rebuild order and hash it.
     *
     * @param orderParam Order parameters.
     * @param perpetual  Address of perpetual contract.
     * @return orderHash Hash of the order.
     */
    function getOrderHash(
        OrderParam memory orderParam,
        address perpetual
    ) internal pure returns (bytes32 orderHash) {
        Order memory order = getOrder(orderParam, perpetual);
        orderHash = LibEIP712.hashEIP712Message(hashOrder(order));
    }

    /**
     * @dev Get order hash from order.
     *
     * @param order Order to hash.
     * @return orderHash Hash of the order.
     */
    function getOrderHash(Order memory order) internal pure returns (bytes32 orderHash) {
        orderHash = LibEIP712.hashEIP712Message(hashOrder(order));
    }

    /**
     * @dev Get order from parameters.
     *
     * @param orderParam Order parameters.
     * @param perpetual  Address of perpetual contract.
     * @return order Order data structure.
     */
    function getOrder(
        OrderParam memory orderParam,
        address perpetual
    ) internal pure returns (LibOrder.Order memory order) {
        order.trader = orderParam.trader;
        order.perpetual = perpetual;
        order.amount = orderParam.amount;
        order.price = orderParam.price;
        order.data = orderParam.data;
    }

    /**
     * @dev Hash fields in order to generate a hash as identifier.
     *
     * @param order Order to hash.
     * @return result Hash of the order.
     */
    function hashOrder(Order memory order) internal pure returns (bytes32 result) {
        bytes32 orderType = EIP712_ORDER_TYPE;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            // "Order(address trader,address broker,address perpetual,uint256 amount,uint256 price,bytes32 data)"
            // hash these 6 field to get a hash
            // address will be extended to 32 bytes.
            let start := sub(order, 32)
            let tmp := mload(start)
            mstore(start, orderType)
            // [0...32)   bytes: EIP712_ORDER_TYPE, len 32
            // [32...224) bytes: order, len 6 * 32
            // 224 = 32 + 192
            result := keccak256(start, 224)
            mstore(start, tmp)
        }
    }

    // extract order parameters.

    function orderVersion(OrderParam memory orderParam) internal pure returns (uint256) {
        return uint256(uint8(bytes1(orderParam.data)));
    }

    function expiredAt(OrderParam memory orderParam) internal pure returns (uint256) {
        return uint256(uint40(bytes5(orderParam.data << (8 * 3))));
    }

    function isSell(OrderParam memory orderParam) internal pure returns (bool) {
        bool sell = uint8(orderParam.data[1]) == 1;
        return isInversed(orderParam) ? !sell : sell;
    }

    function getPrice(OrderParam memory orderParam) internal pure returns (uint256) {
        return isInversed(orderParam) ? LibMathUnsigned.WAD().wdiv(orderParam.price) : orderParam.price;
    }

    function isMarketOrder(OrderParam memory orderParam) internal pure returns (bool) {
        return uint8(orderParam.data[2]) > 0;
    }

    function isMarketBuy(OrderParam memory orderParam) internal pure returns (bool) {
        return !isSell(orderParam) && isMarketOrder(orderParam);
    }

    function isMakerOnly(OrderParam memory orderParam) internal pure returns (bool) {
        return uint8(orderParam.data[22]) > 0;
    }

    function isInversed(OrderParam memory orderParam) internal pure returns (bool) {
        return uint8(orderParam.data[23]) > 0;
    }

    function side(OrderParam memory orderParam) internal pure returns (LibTypes.Side) {
        return isSell(orderParam) ? LibTypes.Side.SHORT : LibTypes.Side.LONG;
    }

    function makerFeeRate(OrderParam memory orderParam) internal pure returns (int256) {
        return int256(int16(bytes2(orderParam.data << (8 * 8)))).mul(LibMathSigned.WAD()).div(FEE_RATE_BASE);
    }

    function takerFeeRate(OrderParam memory orderParam) internal pure returns (int256) {
        return int256(int16(bytes2(orderParam.data << (8 * 10)))).mul(LibMathSigned.WAD()).div(FEE_RATE_BASE);
    }

    function chainId(OrderParam memory orderParam) internal pure returns (uint256) {
        return uint256(uint64(bytes8(orderParam.data << (8 * 24))));
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import  "../lib/LibMath.sol";
import "../lib/LibTypes.sol";
import "./Collateral.sol";

contract MarginAccount is Collateral {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using LibTypes for LibTypes.Side;

    event UpdatePositionAccount(
        address indexed trader,
        LibTypes.MarginAccount account,
        uint256 perpetualTotalSize,
        uint256 price
    );
    event UpdateInsuranceFund(int256 newVal);
    event Transfer(address indexed from, address indexed to, int256 wadAmount, int256 balanceFrom, int256 balanceTo);
    event InternalUpdateBalance(address indexed trader, int256 wadAmount, int256 balance);

    constructor(address _globalConfig, address _collateral, uint256 _collateralDecimals)
        Collateral(_globalConfig, _collateral, _collateralDecimals)
    {}

    /**
      * @dev Calculate max amount can be liquidated to trader's acccount.
      *
      * @param trader           Address of account owner.
      * @param liquidationPrice Markprice used in calculation.
      * @return Max liquidatable amount, note this amount is not aligned to lotSize.
      */
    function calculateLiquidateAmount(address trader, uint256 liquidationPrice) public returns (uint256) {
        if (marginAccounts[trader].size == 0) {
            return 0;
        }
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        int256 liquidationAmount = account.cashBalance.add(account.entrySocialLoss);
        liquidationAmount = liquidationAmount
            .sub(marginWithPrice(trader, liquidationPrice).toInt256())
            .sub(socialLossPerContract(account.side).wmul(account.size.toInt256()));
        int256 tmp = account.entryValue.toInt256()
            .sub(account.entryFundingLoss)
            .add(fundingModule.currentAccumulatedFundingPerContract().wmul(account.size.toInt256()))
            .sub(account.size.wmul(liquidationPrice).toInt256());
        if (account.side == LibTypes.Side.LONG) {
            liquidationAmount = liquidationAmount.sub(tmp);
        } else if (account.side == LibTypes.Side.SHORT) {
            liquidationAmount = liquidationAmount.add(tmp);
        } else {
            return 0;
        }
        int256 denominator = governance.liquidationPenaltyRate
            .add(governance.penaltyFundRate).toInt256()
            .sub(governance.initialMarginRate.toInt256())
            .wmul(liquidationPrice.toInt256());
        liquidationAmount = liquidationAmount.wdiv(denominator);
        liquidationAmount = liquidationAmount.max(0);
        liquidationAmount = liquidationAmount.min(account.size.toInt256());
        return liquidationAmount.toUint256();
    }

    /**
      * @dev Calculate pnl of an margin account at trade price for given amount.
      *
      * @param account    Account of account owner.
      * @param tradePrice Price used in calculation.
      * @param amount     Amount used in calculation.
      * @return PNL of given account.
      */
    function calculatePnl(LibTypes.MarginAccount memory account, uint256 tradePrice, uint256 amount)
        internal
        returns (int256)
    {
        if (account.size == 0) {
            return 0;
        }
        int256 p1 = tradePrice.wmul(amount).toInt256();
        int256 p2;
        if (amount == account.size) {
            p2 = account.entryValue.toInt256();
        } else {
            // p2 = account.entryValue.wmul(amount).wdiv(account.size).toInt256();
            p2 = account.entryValue.wfrac(amount, account.size).toInt256();
        }
        int256 profit = account.side == LibTypes.Side.LONG ? p1.sub(p2) : p2.sub(p1);
        // prec error
        if (profit != 0) {
            profit = profit.sub(1);
        }
        int256 loss1 = socialLossWithAmount(account, amount);
        int256 loss2 = fundingLossWithAmount(account, amount);
        return profit.sub(loss1).sub(loss2);
    }

    /**
      * @dev Calculate margin balance at given mark price:
      *         margin balance = cash balance + pnl
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      * @return Value of margin balance.
      */
    function marginBalanceWithPrice(address trader, uint256 markPrice) internal returns (int256) {
        return marginAccounts[trader].cashBalance.add(pnlWithPrice(trader, markPrice));
    }

    /**
      * @dev Calculate (initial) margin value with initial margin rate at given mark price:
      *         margin taken by positon = value of positon * initial margin rate.
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      * @return Value of margin.
      */
    function marginWithPrice(address trader, uint256 markPrice) internal view returns (uint256) {
        return marginAccounts[trader].size.wmul(markPrice).wmul(governance.initialMarginRate);
    }

    /**
      * @dev Calculate maintenance margin value with maintenance margin rate at given mark price:
      *         maintenance margin taken by positon = value of positon * maintenance margin rate.
      *         maintenance margin must be lower than (initial) margin (see above)
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      * @return Value of margin.
      */
    function maintenanceMarginWithPrice(address trader, uint256 markPrice) internal view returns (uint256) {
        return marginAccounts[trader].size.wmul(markPrice).wmul(governance.maintenanceMarginRate);
    }

    /**
      * @dev Calculate available margin balance, which can be used to open new positions, at given mark price:
      *      An available margin could be negative:
      *         avaiable margin balance = margin balance - margin taken by position
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      * @return Value of available margin balance.
      */
    function availableMarginWithPrice(address trader, uint256 markPrice) internal returns (int256) {
        int256 marginBalance = marginBalanceWithPrice(trader, markPrice);
        int256 margin = marginWithPrice(trader, markPrice).toInt256();
        return marginBalance.sub(margin);
    }


    /**
      * @dev Calculate pnl (profit and loss) of a margin account at given mark price.
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      * @return Value of available margin balance.
      */
    function pnlWithPrice(address trader, uint256 markPrice) internal returns (int256) {
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        return calculatePnl(account, markPrice, account.size);
    }

    // Internal functions
    function increaseTotalSize(LibTypes.Side side, uint256 amount) internal {
        totalSizes[uint256(side)] = totalSizes[uint256(side)].add(amount);
    }

    function decreaseTotalSize(LibTypes.Side side, uint256 amount) internal {
        totalSizes[uint256(side)] = totalSizes[uint256(side)].sub(amount);
    }

    function socialLoss(LibTypes.MarginAccount memory account) internal view returns (int256) {
        return socialLossWithAmount(account, account.size);
    }

    function socialLossWithAmount(LibTypes.MarginAccount memory account, uint256 amount)
        internal
        view
        returns (int256)
    {
        if (amount == 0) {
            return 0;
        }
        int256 loss = socialLossPerContract(account.side).wmul(amount.toInt256());
        if (amount == account.size) {
            loss = loss.sub(account.entrySocialLoss);
        } else {
            // loss = loss.sub(account.entrySocialLoss.wmul(amount).wdiv(account.size));
            loss = loss.sub(account.entrySocialLoss.wfrac(amount.toInt256(), account.size.toInt256()));
            // prec error
            if (loss != 0) {
                loss = loss.add(1);
            }
        }
        return loss;
    }

    function fundingLoss(LibTypes.MarginAccount memory account) internal returns (int256) {
        return fundingLossWithAmount(account, account.size);
    }

    function fundingLossWithAmount(LibTypes.MarginAccount memory account, uint256 amount) internal returns (int256) {
        if (amount == 0) {
            return 0;
        }
        int256 loss = fundingModule.currentAccumulatedFundingPerContract().wmul(amount.toInt256());
        if (amount == account.size) {
            loss = loss.sub(account.entryFundingLoss);
        } else {
            // loss = loss.sub(account.entryFundingLoss.wmul(amount.toInt256()).wdiv(account.size.toInt256()));
            loss = loss.sub(account.entryFundingLoss.wfrac(amount.toInt256(), account.size.toInt256()));
        }
        if (account.side == LibTypes.Side.SHORT) {
            loss = loss.neg();
        }
        if (loss != 0 && amount != account.size) {
            loss = loss.add(1);
        }
        return loss;
    }

    /**
      * @dev Recalculate cash balance of a margin account and update the storage.
      *
      * @param trader    Address of account owner.
      * @param markPrice Price used in calculation.
      */
    function remargin(address trader, uint256 markPrice) internal {
        LibTypes.MarginAccount storage account = marginAccounts[trader];
        if (account.size == 0) {
            return;
        }
        int256 rpnl = calculatePnl(account, markPrice, account.size);
        account.cashBalance = account.cashBalance.add(rpnl);
        account.entryValue = markPrice.wmul(account.size);
        account.entrySocialLoss = socialLossPerContract(account.side).wmul(account.size.toInt256());
        account.entryFundingLoss = fundingModule.currentAccumulatedFundingPerContract().wmul(account.size.toInt256());
        emit UpdatePositionAccount(trader, account, totalSize(account.side), markPrice);
    }

    /**
      * @dev Open new position for a margin account.
      *
      * @param account Account of account owner.
      * @param side    Side of position to open.
      * @param price   Price of position to open.
      * @param amount  Amount of position to open.
      */
    function open(LibTypes.MarginAccount memory account, LibTypes.Side side, uint256 price, uint256 amount) internal {
        require(amount > 0, "open: invald amount");
        if (account.size == 0) {
            account.side = side;
        }
        account.size = account.size.add(amount);
        account.entryValue = account.entryValue.add(price.wmul(amount));
        account.entrySocialLoss = account.entrySocialLoss.add(socialLossPerContract(side).wmul(amount.toInt256()));
        account.entryFundingLoss = account.entryFundingLoss.add(
            fundingModule.currentAccumulatedFundingPerContract().wmul(amount.toInt256())
        );
        increaseTotalSize(side, amount);
    }

    /**
      * @dev CLose position for a margin account, get collateral back.
      *
      * @param account Account of account owner.
      * @param price   Price of position to close.
      * @param amount  Amount of position to close.
      */
    function close(LibTypes.MarginAccount memory account, uint256 price, uint256 amount) internal returns (int256) {
        int256 rpnl = calculatePnl(account, price, amount);
        account.cashBalance = account.cashBalance.add(rpnl);
        account.entrySocialLoss = account.entrySocialLoss.wmul(account.size.sub(amount).toInt256()).wdiv(
            account.size.toInt256()
        );
        account.entryFundingLoss = account.entryFundingLoss.wmul(account.size.sub(amount).toInt256()).wdiv(
            account.size.toInt256()
        );
        account.entryValue = account.entryValue.wmul(account.size.sub(amount)).wdiv(account.size);
        account.size = account.size.sub(amount);
        decreaseTotalSize(account.side, amount);
        if (account.size == 0) {
            account.side = LibTypes.Side.FLAT;
        }
        return rpnl;
    }

    function trade(address trader, LibTypes.Side side, uint256 price, uint256 amount) internal returns (uint256) {
        // int256 rpnl;
        uint256 opened = amount;
        uint256 closed;
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        LibTypes.Side originalSide = account.side;
        if (account.size > 0 && account.side != side) {
            closed = account.size.min(amount);
            close(account, price, closed);
            opened = opened.sub(closed);
        }
        if (opened > 0) {
            open(account, side, price, opened);
        }
        marginAccounts[trader] = account;
        emit UpdatePositionAccount(trader, account, totalSize(originalSide), price);
        return opened;
    }

    /**
     * @dev Liqudate a bankrupt margin account (cash balance cannot cover negative pnl), force to sell its postion
     *      at mark price to the liquidator. The liquidated margin account will suffer a penalty.
     *      The liquidating process must be initiated from a margin account with enough margin balance.
     *      Any loss caused by liquidated account is firstly be recovered by insurance fund, then uncovered part
     *      will become socialloss and applied to the side of its couterparty.
     *
     * @param liquidator        Address who initiate the liquidating process.
     * @param trader            Address who is liquidated.
     * @param liquidationPrice  Price to liquidate.
     * @param liquidationAmount Max amount to liquidate.
     * @return Opened position amount for liquidate.
     */
    function liquidate(address liquidator, address trader, uint256 liquidationPrice, uint256 liquidationAmount)
        internal
        returns (uint256)
    {
        // liquidiated trader
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        require(liquidationAmount <= account.size, "exceeded liquidation amount");

        LibTypes.Side liquidationSide = account.side;
        uint256 liquidationValue = liquidationPrice.wmul(liquidationAmount);
        int256 penaltyToLiquidator = governance.liquidationPenaltyRate.wmul(liquidationValue).toInt256();
        int256 penaltyToFund = governance.penaltyFundRate.wmul(liquidationValue).toInt256();

        // position: trader => liquidator
        trade(trader, LibTypes.counterSide(liquidationSide), liquidationPrice, liquidationAmount);
        uint256 opened = trade(liquidator, liquidationSide, liquidationPrice, liquidationAmount);

        // penalty: trader => liquidator, trader => insuranceFundBalance
        updateCashBalance(trader, penaltyToLiquidator.add(penaltyToFund).neg());
        updateCashBalance(liquidator, penaltyToLiquidator);
        insuranceFundBalance = insuranceFundBalance.add(penaltyToFund);

        // loss
        int256 liquidationLoss = ensurePositiveBalance(trader).toInt256();
        // fund, fund penalty - possible social loss
        if (insuranceFundBalance >= liquidationLoss) {
            // insurance covers the loss
            insuranceFundBalance = insuranceFundBalance.sub(liquidationLoss);
        } else {
            // insurance cannot covers the loss, overflow part become socialloss of counter side.
            int256 newSocialLoss = liquidationLoss.sub(insuranceFundBalance);
            insuranceFundBalance = 0;
            handleSocialLoss(LibTypes.counterSide(liquidationSide), newSocialLoss);
        }
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
        return opened;
    }

    /**
     * @dev Increase social loss per contract on given side.
     *
     * @param side Side of position.
     * @param loss Amount of loss to handle.
     */
    function handleSocialLoss(LibTypes.Side side, int256 loss) internal {
        require(side != LibTypes.Side.FLAT, "side can't be flat");
        require(totalSize(side) > 0, "size cannot be 0");
        require(loss >= 0, "loss must be positive");

        int256 newSocialLoss = loss.wdiv(totalSize(side).toInt256());
        int256 newLossPerContract = socialLossPerContracts[uint256(side)].add(newSocialLoss);
        socialLossPerContracts[uint256(side)] = newLossPerContract;

        emit SocialLoss(side, newLossPerContract);
    }

     /**
     * @dev Update the cash balance of a collateral account. Depends on the signed of given amount,
     *      it could be increasing (for positive amount) or decreasing (for negative amount).
     *
     * @param trader    Address of account owner.
     * @param wadAmount Amount of balance to be update. Both positive and negative are avaiable.
     */
    function updateCashBalance(address trader, int256 wadAmount) internal {
        if (wadAmount == 0) {
            return;
        }
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.add(wadAmount);
        emit InternalUpdateBalance(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    /**
     * @dev Check a trader's cash balance, return the negative part and set the cash balance to 0
     *      if possible.
     *
     * @param trader    Address of account owner.
     * @return loss A loss equals to the negative part of trader's cash balance before operating.
     */
    function ensurePositiveBalance(address trader) internal returns (uint256 loss) {
        if (marginAccounts[trader].cashBalance < 0) {
            loss = marginAccounts[trader].cashBalance.neg().toUint256();
            marginAccounts[trader].cashBalance = 0;
        }
    }

    /**
     * @dev Like erc20's 'transferFrom', transfer internal balance from one account to another.
     *
     * @param from      Address of the cash balance transferred from.
     * @param to        Address of the cash balance transferred to.
     * @param wadAmount Amount of the balance to be transferred.
     */
    function transferBalance(address from, address to, int256 wadAmount) internal {
        if (wadAmount == 0) {
            return;
        }
        require(wadAmount > 0, "amount must be greater than 0");
        marginAccounts[from].cashBalance = marginAccounts[from].cashBalance.sub(wadAmount); // may be negative balance
        marginAccounts[to].cashBalance = marginAccounts[to].cashBalance.add(wadAmount);
        emit Transfer(from, to, wadAmount, marginAccounts[from].cashBalance, marginAccounts[to].cashBalance);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

library LibTypes {
    enum Side {FLAT, SHORT, LONG}

    enum Status {NORMAL, EMERGENCY, SETTLED}

    function counterSide(Side side) internal pure returns (Side) {
        if (side == Side.LONG) {
            return Side.SHORT;
        } else if (side == Side.SHORT) {
            return Side.LONG;
        }
        return side;
    }

    //////////////////////////////////////////////////////////////////////////
    // Perpetual
    //////////////////////////////////////////////////////////////////////////
    struct PerpGovernanceConfig {
        uint256 initialMarginRate;
        uint256 maintenanceMarginRate;
        uint256 liquidationPenaltyRate;
        uint256 penaltyFundRate;
        int256 takerDevFeeRate;
        int256 makerDevFeeRate;
        uint256 lotSize;
        uint256 tradingLotSize;
        int256 referrerBonusRate;
        int256 referreeFeeDiscount;
    }

    struct MarginAccount {
        LibTypes.Side side;
        uint256 size;
        uint256 entryValue;
        int256 entrySocialLoss;
        int256 entryFundingLoss;
        int256 cashBalance;
    }

    //////////////////////////////////////////////////////////////////////////
    // Funding module
    //////////////////////////////////////////////////////////////////////////
    struct FundingGovernanceConfig {
        int256 emaAlpha;
        uint256 updatePremiumPrize;
        int256 markPremiumLimit;
        int256 fundingDampener;
    }

    struct FundingState {
        uint256 lastFundingTime;
        int256 lastPremium;
        int256 lastEMAPremium;
        uint256 lastIndexPrice;
        int256 accumulatedFundingPerContract;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;


library LibMathSigned {
    int256 private constant _WAD = 10 ** 18;
    int256 private constant _INT256_MIN = -2 ** 255;

    uint8 private constant FIXED_DIGITS = 18;
    int256 private constant FIXED_1 = 10 ** 18;
    int256 private constant FIXED_E = 2718281828459045235;
    uint8 private constant LONGER_DIGITS = 36;
    int256 private constant LONGER_FIXED_LOG_E_1_5 = 405465108108164381978013115464349137;
    int256 private constant LONGER_FIXED_1 = 10 ** 36;
    int256 private constant LONGER_FIXED_LOG_E_10 = 2302585092994045684017991454684364208;


    function WAD() internal pure returns (int256) {
        return _WAD;
    }

    // additive inverse
    function neg(int256 a) internal pure returns (int256) {
        return sub(int256(0), a);
    }

    /**
     * @dev Multiplies two signed integers, reverts on overflow
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SignedSafeMath.sol#L13
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        require(!(a == -1 && b == _INT256_MIN), "wmultiplication overflow");

        int256 c = a * b;
        require(c / a == b, "wmultiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SignedSafeMath.sol#L32
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "wdivision by zero");
        require(!(b == -1 && a == _INT256_MIN), "wdivision overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Subtracts two signed integers, reverts on overflow.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SignedSafeMath.sol#L44
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "subtraction overflow");

        return c;
    }

    /**
     * @dev Adds two signed integers, reverts on overflow.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SignedSafeMath.sol#L54
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "addition overflow");

        return c;
    }

    function wmul(int256 x, int256 y) internal pure returns (int256 z) {
        z = roundHalfUp(mul(x, y), _WAD) / _WAD;
    }

    // solium-disable-next-line security/no-assign-params
    function wdiv(int256 x, int256 y) internal pure returns (int256 z) {
        if (y < 0) {
            y = -y;
            x = -x;
        }
        z = roundHalfUp(mul(x, _WAD), y) / y;
    }

    // solium-disable-next-line security/no-assign-params
    function wfrac(int256 x, int256 y, int256 z) internal pure returns (int256 r) {
        int256 t = mul(x, y);
        if (z < 0) {
            z = neg(z);
            t = neg(t);
        }
        r = roundHalfUp(t, z) / z;
    }

    function min(int256 x, int256 y) internal pure returns (int256) {
        return x <= y ? x : y;
    }

    function max(int256 x, int256 y) internal pure returns (int256) {
        return x >= y ? x : y;
    }

    // see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/utils/SafeCast.sol#L103
    function toUint256(int256 x) internal pure returns (uint256) {
        require(x >= 0, "int overflow");
        return uint256(x);
    }

    // x ^ n
    // NOTE: n is a normal integer, do not shift 18 decimals
    // solium-disable-next-line security/no-assign-params
    function wpowi(int256 x, int256 n) internal pure returns (int256 z) {
        require(n >= 0, "wpowi only supports n >= 0");
        z = n % 2 != 0 ? x : _WAD;

        for (n /= 2; n != 0; n /= 2) {
            x = wmul(x, x);

            if (n % 2 != 0) {
                z = wmul(z, x);
            }
        }
    }

    // ROUND_HALF_UP rule helper. You have to call roundHalfUp(x, y) / y to finish the rounding operation
    // 0.5 ≈ 1, 0.4 ≈ 0, -0.5 ≈ -1, -0.4 ≈ 0
    function roundHalfUp(int256 x, int256 y) internal pure returns (int256) {
        require(y > 0, "roundHalfUp only supports y > 0");
        if (x >= 0) {
            return add(x, y / 2);
        }
        return sub(x, y / 2);
    }

    // solium-disable-next-line security/no-assign-params
    function wln(int256 x) internal pure returns (int256) {
        require(x > 0, "logE of negative number");
        require(x <= 10000000000000000000000000000000000000000, "logE only accepts v <= 1e22 * 1e18"); // in order to prevent using safe-math
        int256 r = 0;
        uint8 extraDigits = LONGER_DIGITS - FIXED_DIGITS;
        int256 t = int256(uint256(10)**uint256(extraDigits));

        while (x <= FIXED_1 / 10) {
            x = x * 10;
            r -= LONGER_FIXED_LOG_E_10;
        }
        while (x >= 10 * FIXED_1) {
            x = x / 10;
            r += LONGER_FIXED_LOG_E_10;
        }
        while (x < FIXED_1) {
            x = wmul(x, FIXED_E);
            r -= LONGER_FIXED_1;
        }
        while (x > FIXED_E) {
            x = wdiv(x, FIXED_E);
            r += LONGER_FIXED_1;
        }
        if (x == FIXED_1) {
            return roundHalfUp(r, t) / t;
        }
        if (x == FIXED_E) {
            return FIXED_1 + roundHalfUp(r, t) / t;
        }
        x *= t;

        //               x^2   x^3   x^4
        // Ln(1+x) = x - --- + --- - --- + ...
        //                2     3     4
        // when -1 < x < 1, O(x^n) < ε => when n = 36, 0 < x < 0.316
        //
        //                    2    x           2    x          2    x
        // Ln(a+x) = Ln(a) + ---(------)^1  + ---(------)^3 + ---(------)^5 + ...
        //                    1   2a+x         3   2a+x        5   2a+x
        //
        // Let x = v - a
        //                  2   v-a         2   v-a        2   v-a
        // Ln(v) = Ln(a) + ---(-----)^1  + ---(-----)^3 + ---(-----)^5 + ...
        //                  1   v+a         3   v+a        5   v+a
        // when n = 36, 1 < v < 3.423
        r = r + LONGER_FIXED_LOG_E_1_5;
        int256 a1_5 = (3 * LONGER_FIXED_1) / 2;
        int256 m = (LONGER_FIXED_1 * (x - a1_5)) / (x + a1_5);
        r = r + 2 * m;
        int256 m2 = (m * m) / LONGER_FIXED_1;
        uint8 i = 3;
        while (true) {
            m = (m * m2) / LONGER_FIXED_1;
            r = r + (2 * m) / int256(i);
            i += 2;
            if (i >= 3 + 2 * FIXED_DIGITS) {
                break;
            }
        }
        return roundHalfUp(r, t) / t;
    }

    // Log(b, x)
    function logBase(int256 base, int256 x) internal pure returns (int256) {
        return wdiv(wln(x), wln(base));
    }

    function ceil(int256 x, int256 m) internal pure returns (int256) {
        require(x >= 0, "ceil need x >= 0");
        require(m > 0, "ceil need m > 0");
        return (sub(add(x, m), 1) / m) * m;
    }
}


library LibMathUnsigned {
    uint256 private constant _WAD = 10**18;
    uint256 private constant _POSITIVE_INT256_MAX = 2**255 - 1;

    function WAD() internal pure returns (uint256) {
        return _WAD;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SafeMath.sol#L26
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Unaddition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SafeMath.sol#L55
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Unsubtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SafeMath.sol#L71
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Unmultiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SafeMath.sol#L111
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "Undivision by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), _WAD / 2) / _WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, _WAD), y / 2) / y;
    }

    function wfrac(uint256 x, uint256 y, uint256 z) internal pure returns (uint256 r) {
        r = mul(x, y) / z;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }

    function toInt256(uint256 x) internal pure returns (int256) {
        require(x <= _POSITIVE_INT256_MAX, "uint256 overflow");
        return int256(x);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.1/contracts/math/SafeMath.sol#L146
     */
    function mod(uint256 x, uint256 m) internal pure returns (uint256) {
        require(m != 0, "mod by zero");
        return x % m;
    }

    function ceil(uint256 x, uint256 m) internal pure returns (uint256) {
        require(m > 0, "ceil need m > 0");
        return (sub(add(x, m), 1) / m) * m;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
abstract contract ReentrancyGuard {
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

    constructor () {
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
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;


library LibEIP712 {
    string internal constant DOMAIN_NAME = "Meke Protocol";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked("EIP712Domain(string name)"));

    bytes32 private constant DOMAIN_SEPARATOR = keccak256(
        abi.encodePacked(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(DOMAIN_NAME)))
    );

    /**
     * Calculates EIP712 encoding for a hash struct in this EIP712 Domain.
     *
     * @param eip712hash The EIP712 hash struct.
     * @return EIP712 hash applied to this EIP712 Domain.
     */
    function hashEIP712Message(bytes32 eip712hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, eip712hash));
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

library LibSignature {
    enum SignatureMethod {ETH_SIGN, EIP712}

    struct OrderSignature {
        bytes32 config;
        bytes32 r;
        bytes32 s;
    }

    /**
     * Validate a signature given a hash calculated from the order data, the signer, and the
     * signature data passed in with the order.
     *
     * This function will revert the transaction if the signature method is invalid.
     *
     * @param signature The signature data passed along with the order to validate against
     * @param hash Hash bytes calculated by taking the hash of the passed order data
     * @param signerAddress The address of the signer
     * @return True if the calculated signature matches the order signature data, false otherwise.
     */
    function isValidSignature(OrderSignature memory signature, bytes32 hash, address signerAddress)
        internal
        pure
        returns (bool)
    {
        uint8 method = uint8(signature.config[1]);
        address recovered;
        uint8 v = uint8(signature.config[0]);

        if (method == uint8(SignatureMethod.ETH_SIGN)) {
            recovered = recover(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
                v,
                signature.r,
                signature.s
            );
        } else if (method == uint8(SignatureMethod.EIP712)) {
            recovered = recover(hash, v, signature.r, signature.s);
        } else {
            revert("invalid sign method");
        }

        return signerAddress == recovered;
    }

    // see "@openzeppelin/contracts/cryptography/ECDSA.sol"
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../lib/LibMath.sol";
import "../lib/LibTypes.sol";
import "./PerpetualGovernance.sol";

/**
 *  Contract Collateral handles operations of underlaying collateral.
 *  Supplies methods to manipulate cash balance.
 */
contract Collateral is PerpetualGovernance {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using SafeERC20 for IERC20;

    // Available decimals should be within [0, 18]
    uint256 private constant MAX_DECIMALS = 18;

    event Deposit(address indexed trader, int256 wadAmount, int256 balance);
    event Withdraw(address indexed trader, int256 wadAmount, int256 balance);

    /**
     * @dev Constructor of Collateral contract. Initialize collateral type and decimals.
     * @param _collateral   Address of collateral token. 0x0 means using ether instead of erc20 token.
     * @param _decimals     Decimals of collateral token. The value should be within range [0, 18].
     */
    constructor(address _globalConfig, address _collateral, uint256 _decimals)
        PerpetualGovernance(_globalConfig)
    {
        require(_decimals <= MAX_DECIMALS, "decimals out of range");
        require(_collateral != address(0) || _decimals == 18, "invalid decimals");

        collateral = IERC20(_collateral);
        // This statement will cause a 'InternalCompilerError: Assembly exception for bytecode'
        // scaler = (_decimals == MAX_DECIMALS ? 1 : 10**(MAX_DECIMALS.sub(_decimals))).toInt256();
        // But this will not.
        scaler = int256(10**(MAX_DECIMALS - _decimals));
    }

    // ** All interface call from upper layer use the decimals of the collateral, called 'rawAmount'.

    /**
     * @dev Indicates that whether current collateral is an erc20 token.
     * @return True if current collateral is an erc20 token.
     */
    function isTokenizedCollateral() internal view returns (bool) {
        return address(collateral) != address(0);
    }

    /**
     * @dev Deposit collateral into trader's colleteral account. Decimals of collateral will be converted into internal
     *      decimals (18) then.
     *      For example:
     *          For a USDT-ETH contract, depositing 10 ** 6 USDT will increase the cash balance by 10 ** 18.
     *          But for a DAI-ETH contract, the depositing amount should be 10 ** 18 to get the same cash balance.
     *
     * @param trader    Address of account owner.
     * @param rawAmount Amount of collateral to be deposited in its original decimals.
     */
    function deposit(address trader, uint256 rawAmount) internal {
        int256 wadAmount = pullCollateral(trader, rawAmount);
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.add(wadAmount);
        emit Deposit(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    /**
     * @dev Withdraw collaterals from trader's margin account to his ethereum address.
     *      The amount to withdraw is in its original decimals.
     *
     * @param trader    Address of account owner.
     * @param rawAmount Amount of collateral to be deposited in its original decimals.
     */
    function withdraw(address payable trader, uint256 rawAmount) internal {
        require(rawAmount > 0, "amount must be greater than 0");
        int256 wadAmount = toWad(rawAmount);
        require(wadAmount <= marginAccounts[trader].cashBalance, "insufficient balance");
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.sub(wadAmount);
        pushCollateral(trader, rawAmount);

        emit Withdraw(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    /**
     * @dev Transfer collateral from user if collateral is erc20 token.
     *
     * @param trader    Address of account owner.
     * @param rawAmount Amount of collateral to be transferred into contract.
     * @return wadAmount Internal representation of the raw amount.
     */
    function pullCollateral(address trader, uint256 rawAmount) internal returns (int256 wadAmount) {
        require(rawAmount > 0, "amount must be greater than 0");
        if (isTokenizedCollateral()) {
            collateral.safeTransferFrom(trader, address(this), rawAmount);
        }
        wadAmount = toWad(rawAmount);
    }

    /**
     * @dev Transfer collateral to user no matter erc20 token or ether.
     *
     * @param trader    Address of account owner.
     * @param rawAmount Amount of collateral to be transferred to user.
     * @return wadAmount Internal representation of the raw amount.
     */
    function pushCollateral(address payable trader, uint256 rawAmount) internal returns (int256 wadAmount) {
        if (isTokenizedCollateral()) {
            collateral.safeTransfer(trader, rawAmount);
        } else {
            Address.sendValue(trader, rawAmount);
        }
        return toWad(rawAmount);
    }

    /**
     * @dev Convert the represention of amount from raw to internal.
     *
     * @param rawAmount Amount with decimals of collateral.
     * @return amount Amount with internal decimals.
     */
    function toWad(uint256 rawAmount) internal view returns (int256) {
        return rawAmount.toInt256().mul(scaler);
    }

    /**
     * @dev Convert the represention of amount from internal to raw.
     *
     * @param amount Amount with internal decimals.
     * @return amount Amount with decimals of collateral.
     */
    function toCollateral(int256 amount) internal view returns (uint256) {
        return amount.div(scaler).toUint256();
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../lib/LibMath.sol";
import "../lib/LibTypes.sol";
import "./PerpetualStorage.sol";
import "../interface/IGlobalConfig.sol";

contract PerpetualGovernance is PerpetualStorage {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;

    event UpdateGovernanceParameter(bytes32 indexed key, int256 value);
    event UpdateGovernanceAddress(bytes32 indexed key, address value);

    constructor(address _globalConfig) {
        require(_globalConfig != address(0), "invalid global config");
        globalConfig = IGlobalConfig(_globalConfig);
    }

    // Check if sender is owner.
    modifier onlyOwner() {
        require(globalConfig.owner() == msg.sender, "not owner");
        _;
    }

    // Check if sender is authorized to call some critical functions.
    modifier onlyAuthorized() {
        require(globalConfig.isComponent(msg.sender), "unauthorized caller");
        _;
    }

    // Check if system is current paused. 
    modifier onlyNotPaused () {
        require(!paused, "system paused");
        _;
    }

    /**
     * @dev Set governance parameters.
     *
     * @param key   Name of parameter.
     * @param value Value of parameter.
     */
    function setGovernanceParameter(bytes32 key, int256 value) public onlyOwner {
        if (key == "initialMarginRate") {
            governance.initialMarginRate = value.toUint256();
            require(governance.initialMarginRate > 0, "require im > 0");
            require(governance.initialMarginRate < 10**18, "require im < 1");
            require(governance.maintenanceMarginRate < governance.initialMarginRate, "require mm < im");
        } else if (key == "maintenanceMarginRate") {
            governance.maintenanceMarginRate = value.toUint256();
            require(governance.maintenanceMarginRate > 0, "require mm > 0");
            require(governance.maintenanceMarginRate < governance.initialMarginRate, "require mm < im");
            require(governance.liquidationPenaltyRate < governance.maintenanceMarginRate, "require lpr < mm");
            require(governance.penaltyFundRate < governance.maintenanceMarginRate, "require pfr < mm");
        } else if (key == "liquidationPenaltyRate") {
            governance.liquidationPenaltyRate = value.toUint256();
            require(governance.liquidationPenaltyRate < governance.maintenanceMarginRate, "require lpr < mm");
        } else if (key == "penaltyFundRate") {
            governance.penaltyFundRate = value.toUint256();
            require(governance.penaltyFundRate < governance.maintenanceMarginRate, "require pfr < mm");
        } else if (key == "takerDevFeeRate") {
            governance.takerDevFeeRate = value;
        } else if (key == "makerDevFeeRate") {
            governance.makerDevFeeRate = value;
        } else if (key == "lotSize") {
            require(
                governance.tradingLotSize == 0 || governance.tradingLotSize.mod(value.toUint256()) == 0,
                "require tls % ls == 0"
            );
            governance.lotSize = value.toUint256();
        } else if (key == "tradingLotSize") {
            require(governance.lotSize == 0 || value.toUint256().mod(governance.lotSize) == 0, "require tls % ls == 0");
            governance.tradingLotSize = value.toUint256();
        } else if (key == "longSocialLossPerContracts") {
            require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
            socialLossPerContracts[uint256(LibTypes.Side.LONG)] = value;
        } else if (key == "shortSocialLossPerContracts") {
            require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
            socialLossPerContracts[uint256(LibTypes.Side.SHORT)] = value;
        } else if (key == "referrerBonusRate") {
            governance.referrerBonusRate = value;
            require(governance.referrerBonusRate > 0 && governance.referrerBonusRate <= 10 ** 18, "referrerBonusRate > 0 && referrerBonusRate <= 1");
        } else if (key == "referreeFeeDiscount") {
            governance.referreeFeeDiscount = value;
            require(governance.referreeFeeDiscount > 0 && governance.referreeFeeDiscount <= 10 ** 18, "referreeFeeDiscount > 0 && referreeFeeDiscount <= 1");
        } else {
            revert("key not exists");
        }
        emit UpdateGovernanceParameter(key, value);
    }

    /**
     * @dev Set governance address. like set governance parameter.
     *
     * @param key   Name of parameter.
     * @param value Address to set.
     */
    function setGovernanceAddress(bytes32 key, address value) public onlyOwner {
        require(value != address(0), "invalid address");
        if (key == "dev") {
            devAddress = value;
        } else if (key == "fundingModule") {
            fundingModule = IFunding(value);
        } else if (key == "globalConfig") {
            globalConfig = IGlobalConfig(value);
        } else {
            revert("key not exists");
        }
        emit UpdateGovernanceAddress(key, value);
    }

    /** 
     * @dev Check amount with lot size. Amount must be integral multiple of lot size.
     */
    function isValidLotSize(uint256 amount) public view returns (bool) {
        return amount > 0 && amount.mod(governance.lotSize) == 0;
    }

    /**
     * @dev Check amount with trading lot size. Amount must be integral multiple of trading lot size.
     *      This is useful in trading to control minimal trading position size.
     */
    function isValidTradingLotSize(uint256 amount) public view returns (bool) {
        return amount > 0 && amount.mod(governance.tradingLotSize) == 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../lib/LibMath.sol";
import "../lib/LibTypes.sol";

import "../interface/IFunding.sol";
import "../interface/IGlobalConfig.sol";


contract PerpetualStorage {
    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;

    bool public paused = false;
    bool public withdrawDisabled = false;

    // Global configuation instance address
    IGlobalConfig public globalConfig;
    // funding module address
    IFunding public fundingModule;
    // Address of collateral;
    IERC20 public collateral;
    // DEV address
    address public devAddress;
    // Status of perpetual
    LibTypes.Status public status;
    // Settment price replacing index price in settled status
    uint256 public settlementPrice;
    // Governance parameters
    LibTypes.PerpGovernanceConfig internal governance;
    // Insurance balance
    int256 public insuranceFundBalance;
    // Total size
    uint256[3] internal totalSizes;
    // Socialloss
    int256[3] internal socialLossPerContracts;
    // Scaler helps to convert decimals
    int256 internal scaler;
    // Mapping from owner to its margin account
    mapping (address => LibTypes.MarginAccount) internal marginAccounts;

    // TODO: Should be UpdateSocialLoss but to compatible off-chain part
    event SocialLoss(LibTypes.Side side, int256 newVal);

    /**
     * @dev Helper to access social loss per contract.
     *      FLAT is always 0.
     *
     * @param side Side of position.
     * @return Total opened position size of given side.
     */
    function socialLossPerContract(LibTypes.Side side) public view returns (int256) {
        return socialLossPerContracts[uint256(side)];
    }

    /**
     * @dev Help to get total opend position size of every side.
     *      FLAT is always 0 and LONG should always equal to SHORT.
     *
     * @param side Side of position.
     * @return Total opened position size of given side.
     */
    function totalSize(LibTypes.Side side) public view returns (uint256) {
        return totalSizes[uint256(side)];
    }

    /**
     * @dev Return data structure of current governance parameters.
     *
     * @return Data structure of current governance parameters.
     */
    function getGovernance() public view returns (LibTypes.PerpGovernanceConfig memory) {
        return governance;
    }

    /**
     * @dev Get underlaying data structure of a margin account.
     *
     * @param trader   Address of the account owner.
     * @return Margin account data.
     */
    function getMarginAccount(address trader) public view returns (LibTypes.MarginAccount memory) {
        return marginAccounts[trader];
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

interface IGlobalConfig {

    function owner() external view returns (address);

    function isOwner() external view returns (bool);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function brokers(address broker) external view returns (bool);
    
    function pauseControllers(address broker) external view returns (bool);

    function withdrawControllers(address broker) external view returns (bool);

    function addBroker() external;

    function removeBroker() external;

    function isComponent(address component) external view returns (bool);

    function addComponent(address perpetual, address component) external;

    function removeComponent(address perpetual, address component) external;

    function addPauseController(address controller) external;

    function removePauseController(address controller) external;

    function addWithdrawController(address controller) external;

    function removeWithdrawControllers(address controller) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../lib/LibTypes.sol";
import "../interface/IPerpetual.sol";


interface IFunding {
    function indexPrice() external view returns (uint256 price, uint256 timestamp);

    function lastFundingState() external view returns (LibTypes.FundingState memory);

    function currentFundingRate() external returns (int256);

    function currentFundingState() external returns (LibTypes.FundingState memory);

    function lastFundingRate() external view returns (int256);

    function getGovernance() external view returns (LibTypes.FundingGovernanceConfig memory);

    function perpetualProxy() external view returns (IPerpetual);

    function currentMarkPrice() external returns (uint256);

    function currentPremiumRate() external returns (int256);

    function currentFairPrice() external returns (uint256);

    function currentPremium() external returns (int256);

    function currentAccumulatedFundingPerContract() external returns (int256);

    function setFairPrice(uint256 price) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;
pragma abicoder v2;

import "../interface/IFunding.sol";

import "../lib/LibTypes.sol";


interface IPerpetual {
    function devAddress() external view returns (address);

    function getMarginAccount(address trader) external view returns (LibTypes.MarginAccount memory);

    function getGovernance() external view returns (LibTypes.PerpGovernanceConfig memory);

    function status() external view returns (LibTypes.Status);

    function paused() external view returns (bool);

    function withdrawDisabled() external view returns (bool);

    function settlementPrice() external view returns (uint256);

    function globalConfig() external view returns (address);

    function collateral() external view returns (address);

    function fundingModule() external view returns (IFunding);

    function totalSize(LibTypes.Side side) external view returns (uint256);

    function totalAccounts() external view returns (uint256);

    function accountList(uint256 num) external view returns (address);

    function markPrice() external returns (uint256);

    function socialLossPerContract(LibTypes.Side side) external view returns (int256);

    function availableMargin(address trader) external returns (int256);

    function positionMargin(address trader) external view returns (uint256);

    function maintenanceMargin(address trader) external view returns (uint256);

    function isSafe(address trader) external returns (bool);

    function isSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);

    function isIMSafe(address trader) external returns (bool);

    function isIMSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);

    function marginBalance(address trader) external returns (int256);

    function tradePosition(
        address taker,
        address maker,
        LibTypes.Side side,
        uint256 price,
        uint256 amount
    ) external returns (uint256, uint256);

    function transferCashBalance(
        address from,
        address to,
        uint256 amount
    ) external;

    function depositFor(address trader, uint256 amount) external payable;

    function withdrawFor(address payable trader, uint256 amount) external;

    function liquidate(address trader, uint256 amount) external returns (uint256, uint256);

    function insuranceFundBalance() external view returns (int256);

    function beginGlobalSettlement(uint256 price) external;

    function endGlobalSettlement() external;

    function isValidLotSize(uint256 amount) external view returns (bool);

    function isValidTradingLotSize(uint256 amount) external view returns (bool);

    function setFairPrice(uint256 price) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}