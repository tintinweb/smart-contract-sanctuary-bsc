// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../intf/IDealer.sol";
import "../intf/IPerpetual.sol";
import "../utils/SignedDecimalMath.sol";

contract Perpetual is Ownable, IPerpetual {
    using SignedDecimalMath for int256;

    // ========== storage ==========

    /*
        We use int128 to store paper and reduced credit, 
        so that we could store balance in a single slot.
        This trick can help us saving gas.

        int128 can support size of 1.7E38, which is enough 
        for most transactions. But other than storing paper 
        and reduced credit values, we use int256 to achieve 
        higher accuracy of calculation.

        Normally, paper amount will be a 1e18 based decimal.
    */
    struct balance {
        int128 paper;
        int128 reducedCredit;
    }
    mapping(address => balance) balanceMap;
    int256 fundingRate;

    // ========== events ==========

    event BalanceChange(
        address indexed trader,
        int256 paperChange,
        int256 creditChange
    );

    event UpdateFundingRate(int256 oldFundingRate, int256 newFundingRate);

    // ========== constructor ==========

    constructor(address _owner) Ownable() {
        transferOwnership(_owner);
    }

    // ========== balance related ==========

    /*
        We store "reducedCredit" instead of credit itself.
        So that after funding rate is updated, the credit values will be
        updated without any extra storage write.
        
        credit = (paper * fundingRate) + reducedCredit

        FundingRate here is a little different from what it means at CEX.
        FundingRate is a cumulative value. Its absolute value doesn't mean 
        anything and only the changes (due to funding updates) matter.

        e.g. If the fundingRate increases by 5 at a certain update, 
        then you will receive 5 credit for every paper you long.
        And you will be charged 5 credit for every paper you short.
    */

    /// @inheritdoc IPerpetual
    function balanceOf(address trader)
        external
        view
        returns (int256 paper, int256 credit)
    {
        paper = int256(balanceMap[trader].paper);
        credit =
            paper.decimalMul(fundingRate) +
            int256(balanceMap[trader].reducedCredit);
    }

    function updateFundingRate(int256 newFundingRate) external onlyOwner {
        int256 oldFundingRate = fundingRate;
        fundingRate = newFundingRate;
        emit UpdateFundingRate(oldFundingRate, newFundingRate);
    }

    function getFundingRate() external view returns (int256) {
        return fundingRate;
    }

    // ========== trade ==========

    /// @inheritdoc IPerpetual
    function trade(bytes calldata tradeData) external {
        (
            address[] memory traderList,
            int256[] memory paperChangeList,
            int256[] memory creditChangeList
        ) = IDealer(owner()).approveTrade(msg.sender, tradeData);

        for (uint256 i = 0; i < traderList.length; ) {
            _settle(traderList[i], paperChangeList[i], creditChangeList[i]);
            unchecked {
                ++i;
            }
        }

        require(IDealer(owner()).isAllSafe(traderList), "TRADER_NOT_SAFE");
    }

    // ========== liquidation ==========

    /// @inheritdoc IPerpetual
    function liquidate(
        address liquidatedTrader,
        int256 requestPaper,
        int256 expectCredit
    ) external returns (int256 liqtorPaperChange, int256 liqtorCreditChange) {
        // liqed => liquidated trader, who faces the risk of liquidation.
        // liqtor => liquidator, who takes over the trader's position.
        int256 liqedPaperChange;
        int256 liqedCreditChange;
        (
            liqtorPaperChange,
            liqtorCreditChange,
            liqedPaperChange,
            liqedCreditChange
        ) = IDealer(owner()).requestLiquidation(
            msg.sender,
            liquidatedTrader,
            requestPaper
        );

        // expected price = expectCredit/requestPaper * -1
        // execute price = liqtorCreditChange/liqtorPaperChange * -1
        if (liqtorPaperChange < 0) {
            // open short, execute price >= expected price
            // liqtorCreditChange/liqtorPaperChange * -1 >= expectCredit/requestPaper * -1
            // liqtorCreditChange/liqtorPaperChange <= expectCredit/requestPaper
            // liqtorCreditChange*requestPaper <= expectCredit*liqtorPaperChange
            require(
                liqtorCreditChange * requestPaper <=
                    expectCredit * liqtorPaperChange,
                "LIQUIDATION_PRICE_PROTECTION"
            );
        } else {
            // open long, execute price <= expected price
            // liqtorCreditChange/liqtorPaperChange * -1 <= expectCredit/requestPaper * -1
            // liqtorCreditChange/liqtorPaperChange >= expectCredit/requestPaper
            // liqtorCreditChange*requestPaper >= expectCredit*liqtorPaperChange
            require(
                liqtorCreditChange * requestPaper >=
                    expectCredit * liqtorPaperChange,
                "LIQUIDATION_PRICE_PROTECTION"
            );
        }

        _settle(liquidatedTrader, liqedPaperChange, liqedCreditChange);
        _settle(msg.sender, liqtorPaperChange, liqtorCreditChange);
        require(IDealer(owner()).isSafe(msg.sender), "LIQUIDATOR_NOT_SAFE");
        if (balanceMap[liquidatedTrader].paper == 0) {
            IDealer(owner()).handleBadDebt(liquidatedTrader);
        }
    }

    // ========== settlement ==========

    /*
        Remember the fomula?
        credit = (paper * fundingRate) + reducedCredit

        So we have...
        reducedCredit = credit - (paper * fundingRate)

        When you update the balance, you need to first calculate the credit, 
        and then calculate and store the reducedCredit.
    */

    function _settle(
        address trader,
        int256 paperChange,
        int256 creditChange
    ) internal {
        bool isNewPosition = balanceMap[trader].paper == 0;
        int256 rate = fundingRate; // gas saving
        int256 credit = int256(balanceMap[trader].paper).decimalMul(rate) +
            int256(balanceMap[trader].reducedCredit) +
            creditChange;
        int128 newPaper = balanceMap[trader].paper + int128(paperChange);
        int128 newReducedCredit = int128(
            credit - int256(newPaper).decimalMul(rate)
        );
        balanceMap[trader].paper = newPaper;
        balanceMap[trader].reducedCredit = newReducedCredit;
        emit BalanceChange(trader, paperChange, creditChange);
        if (isNewPosition) {
            IDealer(owner()).openPosition(trader);
        }
        if (balanceMap[trader].paper == 0) {
            // realize PNL
            IDealer(owner()).realizePnl(
                trader,
                balanceMap[trader].reducedCredit
            );
            balanceMap[trader].reducedCredit = 0;
        }
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

import "../lib/Types.sol";

interface IDealer {
    /// @notice Deposit fund to get credit for trading
    /// @param primaryAmount is the amount of primary asset you want to deposit.
    /// @param secondaryAmount is the amount of secondary asset you want to deposit.
    /// @param to is the account you want to deposit to.
    function deposit(
        uint256 primaryAmount,
        uint256 secondaryAmount,
        address to
    ) external;

    /// @notice Submit withdrawal request, which can be executed after
    /// the timelock. The main purpose of this function is to avoid the
    /// failure of counterparty caused by withdrawal.
    /// @param primaryAmount is the amount of primary asset you want to withdraw.
    /// @param secondaryAmount is the amount of secondary asset you want to withdraw.
    function requestWithdraw(uint256 primaryAmount, uint256 secondaryAmount)
        external;

    /// @notice Execute the withdrawal request.
    /// @param to is the address receiving assets.
    /// @param isInternal Only internal credit transfers will be made,
    /// and ERC20 transfers will not happen.
    function executeWithdraw(address to, bool isInternal) external;

    /// @notice Help perpetual contract parse tradeData and return
    /// the balance changes of each trader.
    /// @dev only perpetual contract can call this function
    /// @param orderSender is the one who submit tradeData.
    /// @param tradeData contains orders, signatures and match info.
    function approveTrade(address orderSender, bytes calldata tradeData)
        external
        returns (
            address[] memory traderList,
            int256[] memory paperChangeList,
            int256[] memory creditChangeList
        );

    /// @notice Check if the trader's margin is enough (>= maintenance margin).
    /// If so, the trader is "safe".
    /// The trader's positions under all markets will be liquidated if he is
    /// not safe.
    function isSafe(address trader) external view returns (bool);

    /// @notice Check if a list of traders are safe.
    /// @dev This function is more gas effective than isSafe, by caching
    /// mark prices.
    function isAllSafe(address[] calldata traderList)
        external
        view
        returns (bool);

    /// @notice Get funding rate of a perpetual market.
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate(address perp) external view returns (int256);

    /// @notice Update multiple funding rate at once.
    /// Can only be called by funding rate keeper.
    function updateFundingRate(
        address[] calldata perpList,
        int256[] calldata rateList
    ) external;

    /// @notice Calculate the paper and credit change of liquidator and
    /// liquidated trader.
    /// @dev Only perpetual contract can call this function.
    /// liqtor is short for liquidator, liqed is short for liquidated trader.
    /// @param liquidator is the one who will take over positions.
    /// @param liquidatedTrader is the one who is being liquidated.
    /// @param requestPaperAmount is the size that the liquidator wants to take.
    /// Positive if the position is long, negative if the position is short.
    function requestLiquidation(
        address liquidator,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        returns (
            int256 liqtorPaperChange,
            int256 liqtorCreditChange,
            int256 liqedPaperChange,
            int256 liqedCreditChange
        );

    /// @notice Transfer all bad debt to insurance account,
    /// including primary and secondary balances.
    function handleBadDebt(address liquidatedTrader) external;

    /// @notice Register the trader's position into dealer.
    /// @dev Only perpetual contract can call this function when
    /// someone's position is opened.
    function openPosition(address trader) external;

    /// @notice Accrual realized pnl and remove the trader's position from dealer.
    /// @dev Only perpetual contract can call this function when
    /// someone's position is closed.
    function realizePnl(address trader, int256 pnl) external;

    /// @notice Register operator.
    /// The operator can sign order on your behalf.
    function setOperator(address operator, bool isValid) external;

    /// @param perp the address of perpetual contract market
    function getRiskParams(address perp)
        external
        view
        returns (Types.RiskParams memory params);

    /// @notice Return all registered perpetual contract market.
    function getAllRegisteredPerps() external view returns (address[] memory);

    /// @notice Return mark price of a perpetual market.
    /// price is a 1e18 based decimal.
    function getMarkPrice(address perp) external view returns (uint256);

    /// @notice Get all open positions of the trader.
    function getPositions(address trader)
        external
        view
        returns (address[] memory);

    /// @notice Return the credit details of the trader.
    /// You cannot use credit as net value or net margin of a trader.
    /// The net value of positions would also be included.
    function getCreditOf(address trader)
        external
        view
        returns (
            int256 primaryCredit,
            uint256 secondaryCredit,
            uint256 pendingPrimaryWithdraw,
            uint256 pendingSecondaryWithdraw,
            uint256 executionTimestamp
        );

    /// @notice Get the risk profile data of a trader.
    /// @return netValue net value of trader including credit amount
    /// @return exposure open position value of the trader across all markets
    function getTraderRisk(address trader)
        external
        view
        returns (
            int256 netValue,
            uint256 exposure,
            uint256 maintenanceMargin
        );

    /// @notice Get liquidation price of a position
    /// @dev This function is for directional use. The margin of error is typically
    /// within 10 wei.
    /// @return liquidationPrice equals 0 if there is no liquidation price.
    function getLiquidationPrice(address trader, address perp)
        external
        view
        returns (uint256 liquidationPrice);

    /// @notice a view version of requestLiquidation, liquidators can use
    /// this function to check how much you have to pay in advance.
    function getLiquidationCost(
        address perp,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        view
        returns (int256 liqtorPaperChange, int256 liqtorCreditChange);

    /// @notice Get filled paper amount of an order to avoid double matching.
    /// @return filledAmount includes paper amount
    function getOrderFilledAmount(bytes32 orderHash)
        external
        view
        returns (uint256 filledAmount);

    /// @notice check if order sender is valid
    function isOrderSenderValid(address orderSender)
        external
        view
        returns (bool);

    /// @notice check if operator is valid
    function isOperatorValid(address client, address operator)
        external
        view
        returns (bool);
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

interface IPerpetual {
    /// @notice Return the paper amount and credit amount of a certain trader.
    /// @return paper is positive when the trader holds a long position and
    /// negative when the trader holds a short position.
    /// @return credit is not related to position direction or entry price,
    /// only used to calculate risk ratio and net value.
    function balanceOf(address trader)
        external
        view
        returns (int256 paper, int256 credit);

    /// @notice Match and settle orders.
    /// @dev tradeData will be forwarded to the Dealer contract and waiting
    /// for matching result. Then the Perpetual contract will execute the result.
    function trade(bytes calldata tradeData) external;

    /// @notice Liquidate a position with customized paper amount and price protection.
    /// @dev Because the liquidation is open to public, there is no guarantee that
    /// your request will be executed.
    /// It will not be executed or partially executed if:
    /// 1) someone else submitted a liquidation request before you, or
    /// 2) the trader deposited enough margin in time, or
    /// 3) the mark price moved beyond your price protection.
    /// Your liquidation will be limited to the position size. For example, if the
    /// position remains 10ETH and you're requesting a 15ETH liquidation. Only 10ETH
    /// will be executed. And the other 5ETH request will be cancelled.
    /// @param  liquidatedTrader is the trader you want to liquidate.
    /// @param  requestPaper is the size of position you want to take .
    /// requestPaper is positive when you want to liquidate a long position, negative when short.
    /// @param expectCredit is the amount of credit you want to pay (when liquidating a short position)
    /// or receive (when liquidating a long position)
    /// @return liqtorPaperChange is the final executed change of liquidator's paper amount
    /// @return liqtorCreditChange is the final executed change of liquidator's credit amount
    function liquidate(
        address liquidatedTrader,
        int256 requestPaper,
        int256 expectCredit
    ) external returns (int256 liqtorPaperChange, int256 liqtorCreditChange);

    /// @notice Get funding rate of this perpetual market.
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate() external view returns (int256);

    /// @notice Update funding rate, owner only function.
    function updateFundingRate(int256 newFundingRate) external;
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

library Types {
    /// @notice data structure of dealer
    struct State {
        // primary asset, ERC20
        address primaryAsset;
        // secondary asset, ERC20
        address secondaryAsset;
        // credit, gained by deposit assets
        mapping(address => int256) primaryCredit;
        mapping(address => uint256) secondaryCredit;
        // withdrawal request time lock
        uint256 withdrawTimeLock;
        // pending primary asset withdrawal amount
        mapping(address => uint256) pendingPrimaryWithdraw;
        // pending secondary asset withdrawal amount
        mapping(address => uint256) pendingSecondaryWithdraw;
        // withdrawal request executable timestamp
        mapping(address => uint256) withdrawExecutionTimestamp;
        // perpetual contract risk parameters
        mapping(address => Types.RiskParams) perpRiskParams;
        // perpetual contract registry, for view
        address[] registeredPerp;
        // all open positions of a trader
        mapping(address => address[]) openPositions;
        // To quickly search if a trader has open position:
        // trader => perpetual contract address => hasPosition
        mapping(address => mapping(address => bool)) hasPosition;
        // For offchain pnl calculation, serial number +1 whenever 
        // position is fully closed.
        // trader => perpetual contract address => current serial Num
        mapping(address => mapping(address => uint256)) positionSerialNum;
        // filled amount of orders
        mapping(bytes32 => uint256) orderFilledPaperAmount;
        // valid order sender registry
        mapping(address => bool) validOrderSender;
        // operator registry
        // client => operator => isValid
        mapping(address => mapping(address => bool)) operatorRegistry;
        // insurance account
        address insurance;
        // funding rate keeper, normally an EOA account
        address fundingRateKeeper;
    }

    struct Order {
        // address of perpetual market
        address perp;
        /*
            Signer is trader, the identity of trading behavior,
            whose balance will be changed.
            Normally it should be an EOA account and the 
            order is valid only if the signer signed it.
            If the signer is a contract, it must implement
            isValidPerpetualOperator(address) returns(bool).
            The order is valid only if one of the valid operators
            is an EOA account and signed the order.
        */
        address signer;
        // positive(negative) if you want to open long(short) position
        int128 paperAmount;
        // negative(positive) if you want to open short(long) position
        int128 creditAmount;
        /*
            ╔═══════════════════╤═════════╗
            ║ info component    │ type    ║
            ╟───────────────────┼─────────╢
            ║ makerFeeRate      │ int64   ║
            ║ takerFeeRate      │ int64   ║
            ║ expiration        │ uint64  ║
            ║ nonce             │ uint64  ║
            ╚═══════════════════╧═════════╝
        */
        bytes32 info;
    }

    // EIP712 component
    bytes32 public constant ORDER_TYPEHASH =
        keccak256(
            "Order(address perp,address signer,int128 paperAmount,int128 creditAmount,bytes32 info)"
        );

    /// @notice risk params of a perpetual market
    struct RiskParams {
        /*
            Liquidation will happen when
            netValue < exposure * liquidationThreshold
            The lower liquidationThreshold, the higher leverage.
            1E18 based decimal.
        */
        uint256 liquidationThreshold;
        /*
            The discount rate for the liquidation.
            markPrice * (1 - liquidationPriceOff) when liquidate long position
            markPrice * (1 + liquidationPriceOff) when liquidate short position
            1e18 based decimal.
        */
        uint256 liquidationPriceOff;
        // The insurance fee rate charged from liquidation. 
        // 1E18 based decimal.
        uint256 insuranceFeeRate;
        // price source of mark price
        address markPriceSource;
        // perpetual market name
        string name;
        // if the market is activited
        bool isRegistered;
    }

    /// @notice Match result obtained by parsing and validating tradeData.
    /// Contains arrays of balance change.
    struct MatchResult {
        address[] traderList;
        int256[] paperChangeList;
        int256[] creditChangeList;
        int256 orderSenderFee;
    }

    uint256 constant ONE = 10**18;
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

/// @notice Decimal math for int256. Round down.
library SignedDecimalMath {
    int256 constant SignedONE = 10**18;

    function decimalMul(int256 a, int256 b) internal pure returns (int256) {
        return (a * b) / SignedONE;
    }

    function decimalDiv(int256 a, int256 b) internal pure returns (int256) {
        return (a * SignedONE) / b;
    }

    function abs(int256 a) internal pure returns (uint256) {
        return a < 0 ? uint256(a * -1) : uint256(a);
    }
}