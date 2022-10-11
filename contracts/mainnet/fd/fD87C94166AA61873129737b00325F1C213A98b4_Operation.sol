/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "./Types.sol";
import "../utils/Errors.sol";
import "../intf/IPerpetual.sol";
import "../intf/IDecimalERC20.sol";

library Operation {
    // ========== events ==========

    event SetFundingRateKeeper(address oldKeeper, address newKeeper);

    event SetInsurance(address oldInsurance, address newInsurance);

    event SetWithdrawTimeLock(
        uint256 oldWithdrawTimeLock,
        uint256 newWithdrawTimeLock
    );

    event SetOrderSender(address orderSender, bool isValid);

    event SetOperator(
        address indexed client,
        address indexed operator,
        bool isValid
    );

    event SetSecondaryAsset(address secondaryAsset);

    event UpdatePerpRiskParams(address indexed perp, Types.RiskParams param);

    event UpdateFundingRate(
        address indexed perp,
        int256 oldRate,
        int256 newRate
    );

    // ========== functions ==========

    function setPerpRiskParams(
        Types.State storage state,
        address perp,
        Types.RiskParams calldata param
    ) external {
        if (state.perpRiskParams[perp].isRegistered && !param.isRegistered) {
            // remove perp
            for (uint256 i; i < state.registeredPerp.length; i++) {
                if (state.registeredPerp[i] == perp) {
                    state.registeredPerp[i] = state.registeredPerp[
                        state.registeredPerp.length - 1
                    ];
                    state.registeredPerp.pop();
                }
            }
        }
        if (!state.perpRiskParams[perp].isRegistered && param.isRegistered) {
            // new perp
            state.registeredPerp.push(perp);
        }
        require(
            param.liquidationPriceOff + param.insuranceFeeRate <=
                param.liquidationThreshold,
            Errors.INVALID_RISK_PARAM
        );
        state.perpRiskParams[perp] = param;
        emit UpdatePerpRiskParams(perp, param);
    }

    function updateFundingRate(
        address[] calldata perpList,
        int256[] calldata rateList
    ) external {
        require(
            perpList.length == rateList.length,
            Errors.ARRAY_LENGTH_NOT_SAME
        );
        for (uint256 i = 0; i < perpList.length; i++) {
            int256 oldRate = IPerpetual(perpList[i]).getFundingRate();
            IPerpetual(perpList[i]).updateFundingRate(rateList[i]);
            emit UpdateFundingRate(perpList[i], oldRate, rateList[i]);
        }
    }

    function setFundingRateKeeper(Types.State storage state, address newKeeper)
        external
    {
        address oldKeeper = state.fundingRateKeeper;
        state.fundingRateKeeper = newKeeper;
        emit SetFundingRateKeeper(oldKeeper, newKeeper);
    }

    function setInsurance(Types.State storage state, address newInsurance)
        external
    {
        address oldInsurance = state.insurance;
        state.insurance = newInsurance;
        emit SetInsurance(oldInsurance, newInsurance);
    }

    function setWithdrawTimeLock(
        Types.State storage state,
        uint256 newWithdrawTimeLock
    ) external {
        uint256 oldWithdrawTimeLock = state.withdrawTimeLock;
        state.withdrawTimeLock = newWithdrawTimeLock;
        emit SetWithdrawTimeLock(oldWithdrawTimeLock, newWithdrawTimeLock);
    }

    function setOrderSender(
        Types.State storage state,
        address orderSender,
        bool isValid
    ) external {
        state.validOrderSender[orderSender] = isValid;
        emit SetOrderSender(orderSender, isValid);
    }

    function setOperator(
        Types.State storage state,
        address client,
        address operator,
        bool isValid
    ) external {
        state.operatorRegistry[client][operator] = isValid;
        emit SetOperator(client, operator, isValid);
    }

    function setSecondaryAsset(
        Types.State storage state,
        address _secondaryAsset
    ) external {
        require(
            state.secondaryAsset == address(0),
            Errors.SECONDARY_ASSET_ALREADY_EXIST
        );
        require(
            IDecimalERC20(_secondaryAsset).decimals() ==
                IDecimalERC20(state.primaryAsset).decimals(),
            Errors.SECONDARY_ASSET_DECIMAL_WRONG
        );
        state.secondaryAsset = _secondaryAsset;
        emit SetSecondaryAsset(_secondaryAsset);
    }
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

/// @notice Error messages
library Errors {
    string constant PERP_MISMATCH = "JOJO_PERP_MISMATCH";
    string constant PERP_NOT_REGISTERED = "JOJO_PERP_NOT_REGISTERED";
    string constant PERP_ALREADY_REGISTERED = "JOJO_PERP_ALREADY_REGISTERED";
    string constant INVALID_RISK_PARAM = "JOJO_INVALID_RISK_PARAM";
    string constant INVALID_ORDER_SENDER = "JOJO_INVALID_ORDER_SENDER";
    string constant INVALID_ORDER_SIGNATURE = "JOJO_INVALID_ORDER_SIGNATURE";
    string constant INVALID_TRADER_NUMBER = "JOJO_AT_LEAST_TWO_TRADERS";
    string constant INVALID_FUNDING_RATE_KEEPER = "JOJO_INVALID_FUNDING_RATE_KEEPER";
    string constant ORDER_FILLED_OVERFLOW = "JOJO_ORDER_FILLED_OVERFLOW";
    string constant ORDER_PRICE_NOT_MATCH = "JOJO_ORDER_PRICE_NOT_MATCH";
    string constant ORDER_PRICE_NEGATIVE = "JOJO_ORDER_PRICE_NEGATIVE";
    string constant ORDER_SENDER_NOT_SAFE = "JOJO_ORDER_SENDER_NOT_SAFE";
    string constant ORDER_EXPIRED = "JOJO_ORDER_EXPIRED";
    string constant ORDER_WRONG_SORTING = "JOJO_ORDER_WRONG_SORTING";
    string constant ORDER_SELF_MATCH = "JOJO_ORDER_SELF_MATCH";
    string constant ACCOUNT_NOT_SAFE = "JOJO_ACCOUNT_NOT_SAFE";
    string constant ACCOUNT_IS_SAFE = "JOJO_ACCOUNT_IS_SAFE";
    string constant TAKER_TRADE_AMOUNT_WRONG = "JOJO_TAKER_TRADE_AMOUNT_WRONG";
    string constant TRADER_HAS_NO_POSITION = "JOJO_TRADER_HAS_NO_POSITION";
    string constant WITHDRAW_PENDING = "JOJO_WITHDRAW_PENDING";
    string constant LIQUIDATION_REQUEST_AMOUNT_WRONG = "JOJO_LIQUIDATION_REQUEST_AMOUNT_WRONG";
    string constant SELF_LIQUIDATION_NOT_ALLOWED = "JOJO_SELF_LIQUIDATION_NOT_ALLOWED";
    string constant SECONDARY_ASSET_ALREADY_EXIST = "JOJO_SECONDARY_ASSET_ALREADY_EXIST";
    string constant SECONDARY_ASSET_DECIMAL_WRONG = "JOJO_SECONDARY_ASSET_DECIMAL_WRONG";
    string constant ARRAY_LENGTH_NOT_SAME = "JOJO_ARRAY_LENGTH_NOT_SAME";
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

interface IDecimalERC20 {
    function decimals() external returns (uint8);
}