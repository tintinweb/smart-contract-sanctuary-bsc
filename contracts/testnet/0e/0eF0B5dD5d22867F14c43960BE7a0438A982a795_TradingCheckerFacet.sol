// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IVault.sol";
import "../interfaces/ILimitOrder.sol";
import "../interfaces/IPriceFacade.sol";
import "../interfaces/ITradingCore.sol";
import "../interfaces/IPairsManager.sol";
import "../interfaces/ITradingConfig.sol";
import "../interfaces/ITradingChecker.sol";
import {ZERO, ONE, UC, uc, into} from "unchecked-counter/src/UC.sol";

contract TradingCheckerFacet is ITradingChecker {

    function checkTp(
        bool isLong, uint takeProfit, uint entryPrice, uint leverage_10000, uint maxTakeProfitP
    ) public pure returns (bool) {
        if (isLong) {
            // The takeProfit price must be set and the percentage of profit must not exceed the maximum allowed
            return takeProfit > entryPrice && (takeProfit - entryPrice) * leverage_10000 <= maxTakeProfitP * entryPrice;
        } else {
            // The takeProfit price must be set and the percentage of profit must not exceed the maximum allowed
            return takeProfit > 0 && takeProfit < entryPrice && (entryPrice - takeProfit) * leverage_10000 <= maxTakeProfitP * takeProfit;
        }
    }

    function checkSl(bool isLong, uint stopLoss, uint entryPrice) public pure returns (bool) {
        if (isLong) {
            // stopLoss price below the liquidation price is meaningless
            // But no check is done here and is intercepted by the front-end.
            // (entryPrice - stopLoss) * qty < marginUsd * liqLostP / Constants.1e4
            return stopLoss == 0 || stopLoss < entryPrice;
        } else {
            // stopLoss price below the liquidation price is meaningless
            // But no check is done here and is intercepted by the front-end.
            // (stopLoss - entryPrice) * qty * 1e4 < marginUsd * liqLostP
            return stopLoss == 0 || stopLoss > entryPrice;
        }
    }

    function checkLimitOrderTp(ILimitOrder.LimitOrder memory order) external view override {
        IVault.MarginToken memory token = IVault(address(this)).getTokenForTrading(order.tokenIn);

        // notionalUsd = price * qty
        uint notionalUsd = order.limitPrice * order.qty;

        // openFeeUsd = notionalUsd * openFeeP
        uint openFeeUsd = notionalUsd * IPairsManager(address(this)).getPairFeeConfig(order.pairBase).openFeeP / 1e4;

        // marginUsd = amountInUsd - openFeeUsd - executionFeeUsd
        uint marginUsd = order.amountIn * token.price * 1e10 / (10 ** token.decimals) - openFeeUsd - ITradingConfig(address(this)).getTradingConfig().executionFeeUsd;

        // leverage_10000 = notionalUsd * 10000 / marginUsd
        uint leverage_10000 = notionalUsd * 1e4 / marginUsd;

        require(
            checkTp(order.isLong, order.takeProfit, order.limitPrice, leverage_10000, ITradingConfig(address(this)).getTradingConfig().maxTakeProfitP),
            "TradingCheckerFacet: takeProfit is not in the valid range"
        );
    }

    function _checkParameters(IBook.OpenDataInput calldata data) private pure {
        require(
            data.qty > 0 && data.price > 0
            && data.amountIn > 0 && data.takeProfit > 0
            && data.pairBase != address(0) && data.tokenIn != address(0),
            "TradingCheckerFacet: Invalid parameters"
        );
    }

    function openLimitOrderCheck(IBook.OpenDataInput calldata data) external view override {
        _checkParameters(data);

        IVault.MarginToken memory token = IVault(address(this)).getTokenForTrading(data.tokenIn);
        require(token.token != address(0) && token.asMargin, "TradingCheckerFacet: This token is not supported as margin");

        IPairsManager.TradingPair memory pair = IPairsManager(address(this)).getPairForTrading(data.pairBase);
        require(pair.base != address(0), "TradingCheckerFacet: Trading for this pair are not supported");
        require(pair.status == IPairsManager.PairStatus.AVAILABLE, "LimitBookFacet: The pair is temporarily unavailable for trading");

        ITradingConfig.TradingConfig memory tc = ITradingConfig(address(this)).getTradingConfig();
        require(tc.limitOrder, "TradingCheckerFacet: This feature is temporarily disabled");

        (uint marketPrice,) = IPriceFacade(address(this)).getPriceFromCacheOrOracle(data.pairBase);
        require(marketPrice > 0, "TradingCheckerFacet: No access to current market effective prices");

        uint triggerPrice = ITradingCore(address(this)).slippagePrice(data.pairBase, data.price, data.qty, !data.isLong);
        require(
            (data.isLong && triggerPrice < marketPrice) || (!data.isLong && triggerPrice > marketPrice),
            "TradingCheckerFacet: This price will open a position immediately"
        );

        // price * qty * 10^18 / 10^(8+10) = price * qty
        uint notionalUsd = data.price * data.qty;
        // The notional value must be greater than or equal to the minimum notional value allowed
        require(notionalUsd >= tc.minNotionalUsd, "TradingCheckerFacet: Position is too small");

        IPairsManager.LeverageMargin[] memory lms = pair.leverageMargins;
        // The notional value of the position must be less than or equal to the maximum notional value allowed by pair
        require(notionalUsd <= lms[lms.length - 1].notionalUsd, "TradingCheckerFacet: Position is too large");

        IPairsManager.LeverageMargin memory lm;
        for (UC i = ZERO; i < uc(lms.length); i = i + ONE) {
            if (notionalUsd <= lms[i.into()].notionalUsd) {
                lm = lms[i.into()];
                break;
            }
        }
        uint openFeeUsd = notionalUsd * pair.feeConfig.openFeeP / 1e4;
        uint amountInUsd = data.amountIn * token.price * 1e10 / (10 ** token.decimals);
        require(amountInUsd > openFeeUsd + tc.executionFeeUsd, "TradingCheckerFacet: The amount is too small");

        // marginUsd = amountInUsd - openFeeUsd - executionFeeUsd
        uint marginUsd = amountInUsd - openFeeUsd - tc.executionFeeUsd;
        // leverage = notionalUsd / marginUsd
        uint leverage_10000 = notionalUsd * 1e4 / marginUsd;
        require(
            leverage_10000 <= 1e4 * lm.maxLeverage,
            "TradingCheckerFacet: Exceeds the maximum leverage allowed for the position"
        );
        require(
            checkTp(data.isLong, data.takeProfit, data.price, leverage_10000, tc.maxTakeProfitP),
            "TradingCheckerFacet: takeProfit is not in the valid range"
        );
        require(
            checkSl(data.isLong, data.stopLoss, data.price),
            "TradingCheckerFacet: stopLoss is not in the valid range"
        );
    }

    struct ExecuteLimitOrderCheckTuple {
        IPairsManager.TradingPair pair;
        ITradingConfig.TradingConfig tc;
        IVault.MarginToken token;
        ITradingCore.PairQty pairQty;
        uint notionalUsd;
        uint slippagePrice;
    }

    function _buildExecuteLimitOrderCheckTuple(
        ILimitOrder.LimitOrder memory order
    ) private view returns (ExecuteLimitOrderCheckTuple memory) {
        IPairsManager.TradingPair memory pair = IPairsManager(address(this)).getPairForTrading(order.pairBase);
        ITradingCore.PairQty memory pairQty = ITradingReader(address(this)).getPairQty(order.pairBase);
        return ExecuteLimitOrderCheckTuple(
            pair,
            ITradingConfig(address(this)).getTradingConfig(),
            IVault(address(this)).getTokenForTrading(order.tokenIn),
            pairQty,
            order.limitPrice * order.qty,
            ITradingCore(address(this)).slippagePrice(pairQty, pair.slippageConfig, order.limitPrice, order.qty, !order.isLong)
        );
    }

    function executeLimitOrderCheck(
        ILimitOrder.LimitOrder memory order,
        uint256 marketPrice
    ) external view override returns (bool result, Refund refund) {
        ExecuteLimitOrderCheckTuple memory tuple = _buildExecuteLimitOrderCheckTuple(order);
        if (tuple.pair.base == address(0) || tuple.pair.status != IPairsManager.PairStatus.AVAILABLE) {
            return (false, Refund.PAIR_STATUS);
        }

        if (tuple.notionalUsd < tuple.tc.minNotionalUsd) {
            return (false, Refund.MIN_NOTIONAL_USD);
        }

        IPairsManager.LeverageMargin[] memory lms = tuple.pair.leverageMargins;
        if (tuple.notionalUsd > lms[lms.length - 1].notionalUsd) {
            return (false, Refund.MAX_NOTIONAL_USD);
        }

        IPairsManager.LeverageMargin memory lm;
        for (UC i = ZERO; i < uc(lms.length); i = i + ONE) {
            if (tuple.notionalUsd <= lms[i.into()].notionalUsd) {
                lm = lms[i.into()];
                break;
            }
        }
        uint openFeeUsd = tuple.notionalUsd * tuple.pair.feeConfig.openFeeP / 1e4;
        uint amountInUsd = order.amountIn * tuple.token.price * 1e10 / (10 ** tuple.token.decimals);
        if (amountInUsd > openFeeUsd + tuple.tc.executionFeeUsd) {
            return (false, Refund.AMOUNT_IN);
        }

        // marginUsd = amountInUsd - openFeeUsd - executionFeeUsd
        uint marginUsd = amountInUsd - openFeeUsd - tuple.tc.executionFeeUsd;
        // leverage_10000 = notionalUsd * 10000 / marginUsd
        uint leverage_10000 = tuple.notionalUsd * 1e4 / marginUsd;
        if (leverage_10000 > 1e4 * lm.maxLeverage) {
            return (false, Refund.MAX_LEVERAGE);
        }

        if (order.isLong) {
            if (marketPrice > tuple.slippagePrice) {
                return (false, Refund.USER_PRICE);
            }
            // Whether the Stop Loss will be triggered immediately at the current price
            if (marketPrice <= order.stopLoss) {
                return (false, Refund.SL);
            }
            // pair OI check
            if (tuple.notionalUsd + tuple.pairQty.longQty * marketPrice > tuple.pair.pairConfig.maxLongOiUsd) {
                return (false, Refund.PAIR_OI);
            }
            // open lost check
            if ((order.limitPrice - marketPrice) * order.qty * 1e4 >= marginUsd * lm.initialLostP) {
                return (false, Refund.OPEN_LOST);
            }
        } else {
            // Comparison of the values of price and limitPrice + slippege
            if (marketPrice < tuple.slippagePrice) {
                return (false, Refund.USER_PRICE);
            }
            // 4. Whether the Stop Loss will be triggered immediately at the current price
            if (marketPrice >= order.stopLoss) {
                return (false, Refund.SL);
            }
            // pair OI check
            if (tuple.notionalUsd + tuple.pairQty.shortQty * marketPrice > tuple.pair.pairConfig.maxShortOiUsd) {
                return (false, Refund.PAIR_OI);
            }
            // open lost check
            if ((marketPrice - order.limitPrice) * order.qty * 1e4 >= marginUsd * lm.initialLostP) {
                return (false, Refund.OPEN_LOST);
            }
        }
        return (true, Refund.NO);
    }

    function checkMarketTradeTp(ITrading.OpenTrade memory ot) external view {
        IVault.MarginToken memory token = IVault(address(this)).getTokenForTrading(ot.tokenIn);

        // notionalUsd = price * qty
        uint notionalUsd = ot.entryPrice * ot.qty;

        // marginUsd = margin * token.price
        uint marginUsd = ot.margin * token.price * 1e10 / (10 ** token.decimals);

        // leverage_10000 = notionalUsd * 10000 / marginUsd
        uint leverage_10000 = notionalUsd * 1e4 / marginUsd;

        require(
            checkTp(ot.isLong, ot.takeProfit, ot.entryPrice, leverage_10000, ITradingConfig(address(this)).getTradingConfig().maxTakeProfitP),
            "TradingCheckerFacet: takeProfit is not in the valid range"
        );
    }

    function openMarketTradeCheck(IBook.OpenDataInput calldata data) external view override {
        _checkParameters(data);

        IVault.MarginToken memory token = IVault(address(this)).getTokenForTrading(data.tokenIn);
        require(token.token != address(0) && token.asMargin, "TradingCheckerFacet: This token is not supported as margin");

        IPairsManager.TradingPair memory pair = IPairsManager(address(this)).getPairForTrading(data.pairBase);
        require(pair.base != address(0), "TradingCheckerFacet: Trading for this pair are not supported");
        require(pair.status == IPairsManager.PairStatus.AVAILABLE, "LimitBookFacet: The pair is temporarily unavailable for trading");

        ITradingConfig.TradingConfig memory tc = ITradingConfig(address(this)).getTradingConfig();
        require(tc.marketTrading, "TradingCheckerFacet: This feature is temporarily disabled");

        (uint marketPrice,) = IPriceFacade(address(this)).getPriceFromCacheOrOracle(data.pairBase);
        require(marketPrice > 0, "TradingCheckerFacet: No access to current market effective prices");

        ITradingCore.PairQty memory pairQty = ITradingReader(address(this)).getPairQty(data.pairBase);
        uint trialPrice = ITradingCore(address(this)).slippagePrice(pairQty, pair.slippageConfig, marketPrice, data.qty, data.isLong);
        require(
            (data.isLong && trialPrice <= data.price) || (!data.isLong && trialPrice >= data.price),
            "LibTrading: Unable to trading at a price acceptable to the user"
        );

        // price * qty * 10^18 / 10^(8+10) = price * qty
        uint notionalUsd = trialPrice * data.qty;
        // The notional value must be greater than or equal to the minimum notional value allowed
        require(notionalUsd >= tc.minNotionalUsd, "TradingCheckerFacet: Position is too small");

        IPairsManager.LeverageMargin[] memory lms = pair.leverageMargins;
        // The notional value of the position must be less than or equal to the maximum notional value allowed by pair
        require(notionalUsd <= lms[lms.length - 1].notionalUsd, "TradingCheckerFacet: Position is too large");

        IPairsManager.LeverageMargin memory lm;
        for (UC i = ZERO; i < uc(lms.length); i = i + ONE) {
            if (notionalUsd <= lms[i.into()].notionalUsd) {
                lm = lms[i.into()];
                break;
            }
        }
        uint openFee = notionalUsd * pair.feeConfig.openFeeP * (10 ** token.decimals) / (1e4 * 1e10 * token.price);
        require(data.amountIn > openFee, "TradingCheckerFacet: The amount is too small");

        // marginUsd = (amountIn - openFee) / token.price
        uint marginUsd = (data.amountIn - openFee) * 1e26 / (token.price * (10 ** token.decimals));
        // leverage = notionalUsd / marginUsd
        uint leverage_10000 = notionalUsd * 1e4 / marginUsd;
        require(
            leverage_10000 <= 1e4 * lm.maxLeverage,
            "LibTrading: Exceeds the maximum leverage allowed for the position"
        );
        require(
            checkTp(data.isLong, data.takeProfit, trialPrice, leverage_10000, tc.maxTakeProfitP),
            "TradingCheckerFacet: takeProfit is not in the valid range"
        );
        require(
            checkSl(data.isLong, data.stopLoss, trialPrice),
            "TradingCheckerFacet: stopLoss is not in the valid range"
        );

        if (data.isLong) {
            // It is prohibited to open positions with excessive losses. Avoid opening positions that are liquidated
            require(
                (trialPrice - marketPrice) * data.qty * 1e4 < marginUsd * lm.initialLostP,
                "LibTrading: Too much initial loss"
            );
            // The total position must be less than or equal to the maximum position allowed for the trading pair
            require(notionalUsd + pairQty.longQty * trialPrice <= pair.pairConfig.maxLongOiUsd, "LibTrading: Long positions have exceeded the maximum allowed");
        } else {
            // It is prohibited to open positions with excessive losses. Avoid opening positions that are liquidated
            require(
                (marketPrice - trialPrice) * data.qty * 1e4 < marginUsd * lm.initialLostP,
                "LibTrading: Too much initial loss"
            );
            // The total position must be less than or equal to the maximum position allowed for the trading pair
            require(notionalUsd + pairQty.shortQty * trialPrice <= pair.pairConfig.maxShortOiUsd, "LibTrading: Short positions have exceeded the maximum allowed");
        }
    }

    struct MarketTradeCallbackCheckTuple {
        IPairsManager.TradingPair pair;
        ITradingConfig.TradingConfig tc;
        IVault.MarginToken token;
        ITradingCore.PairQty pairQty;
        uint notionalUsd;
        uint entryPrice;
    }

    function _buildMarketTradeCallbackCheckTuple(
        ITradingReader.PendingTrade memory pt, uint256 marketPrice
    ) private view returns (MarketTradeCallbackCheckTuple memory) {
        IPairsManager.TradingPair memory pair = IPairsManager(address(this)).getPairForTrading(pt.pairBase);
        ITradingCore.PairQty memory pairQty = ITradingReader(address(this)).getPairQty(pt.pairBase);
        uint entryPrice = ITradingCore(address(this)).slippagePrice(pairQty, pair.slippageConfig, marketPrice, pt.qty, pt.isLong);
        return MarketTradeCallbackCheckTuple(
            pair,
            ITradingConfig(address(this)).getTradingConfig(),
            IVault(address(this)).getTokenForTrading(pt.tokenIn),
            pairQty,
            entryPrice * pt.qty,
            entryPrice
        );
    }

    function marketTradeCallbackCheck(
        ITradingReader.PendingTrade memory pt, uint256 marketPrice
    ) external view returns (bool result, uint256 entryPrice, Refund refund) {
        MarketTradeCallbackCheckTuple memory tuple = _buildMarketTradeCallbackCheckTuple(pt, marketPrice);
        if ((pt.isLong && tuple.entryPrice > pt.price) || (!pt.isLong && tuple.entryPrice < pt.price)) {
            return (false, tuple.entryPrice, Refund.USER_PRICE);
        }

        if (tuple.notionalUsd < tuple.tc.minNotionalUsd) {
            return (false, tuple.entryPrice, Refund.MIN_NOTIONAL_USD);
        }

        IPairsManager.LeverageMargin[] memory lms = tuple.pair.leverageMargins;
        if (tuple.notionalUsd > lms[lms.length - 1].notionalUsd) {
            return (false, tuple.entryPrice, Refund.MAX_NOTIONAL_USD);
        }

        IPairsManager.LeverageMargin memory lm;
        for (UC i = ZERO; i < uc(lms.length); i = i + ONE) {
            if (tuple.notionalUsd <= lms[i.into()].notionalUsd) {
                lm = lms[i.into()];
                break;
            }
        }
        uint openFeeUsd = tuple.notionalUsd * tuple.pair.feeConfig.openFeeP / 1e4;
        uint amountInUsd = pt.amountIn * tuple.token.price * 1e10 / (10 ** tuple.token.decimals);
        if (amountInUsd > openFeeUsd) {
            return (false, tuple.entryPrice, Refund.AMOUNT_IN);
        }

        // marginUsd = amountInUsd - openFeeUsd
        uint marginUsd = amountInUsd - openFeeUsd;
        // leverage_10000 = notionalUsd * 10000 / marginUsd
        uint leverage_10000 = tuple.notionalUsd * 1e4 / marginUsd;
        if (leverage_10000 > 1e4 * lm.maxLeverage) {
            return (false, tuple.entryPrice, Refund.MAX_LEVERAGE);
        }

        if (!checkTp(pt.isLong, pt.takeProfit, tuple.entryPrice, leverage_10000, tuple.tc.maxTakeProfitP)) {
            return (false, entryPrice, Refund.TP);
        }

        if (!checkSl(pt.isLong, pt.stopLoss, tuple.entryPrice)) {
            return (false, tuple.entryPrice, Refund.SL);
        }

        if (pt.isLong) {
            // pair OI check
            if (tuple.notionalUsd + tuple.pairQty.longQty * tuple.entryPrice > tuple.pair.pairConfig.maxLongOiUsd) {
                return (false, tuple.entryPrice, Refund.PAIR_OI);
            }
            // open lost check
            if ((tuple.entryPrice - marketPrice) * pt.qty * 1e4 >= marginUsd * lm.initialLostP) {
                return (false, tuple.entryPrice, Refund.OPEN_LOST);
            }
        } else {
            // pair OI check
            if (tuple.notionalUsd + tuple.pairQty.shortQty * tuple.entryPrice > tuple.pair.pairConfig.maxShortOiUsd) {
                return (false, tuple.entryPrice, Refund.PAIR_OI);
            }
            // open lost check
            if ((marketPrice - tuple.entryPrice) * pt.qty * 1e4 >= marginUsd * lm.initialLostP) {
                return (false, tuple.entryPrice, Refund.OPEN_LOST);
            }
        }
        return (true, tuple.entryPrice, Refund.NO);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*//////////////////////////////////////////////////////////////////////////
                                TYPE DEFINITION
//////////////////////////////////////////////////////////////////////////*/

/// @notice Counter type that bypasses checked arithmetic, designed to be used in for loops.
/// @dev Here's an example:
///
/// ```
/// for (UC i = ZERO; i < uc(100); i = i + ONE) {
///   i.into(); // or `i.unwrap()`
/// }
/// ```
type UC is uint256;

/*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

// Exports 1 as a typed constant.
UC constant ONE = UC.wrap(1);

// Exports 0 as a typed constant.
UC constant ZERO = UC.wrap(0);

/*//////////////////////////////////////////////////////////////////////////
                                LOGIC FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using { add as +, lt as <, lte as <= } for UC global;

/// @notice Sums up `x` and `y` without checked arithmetic.
function add(UC x, UC y) pure returns (UC) {
    unchecked {
        return UC.wrap(UC.unwrap(x) + UC.unwrap(y));
    }
}

/// @notice Checks if `x` is lower than `y`.
function lt(UC x, UC y) pure returns (bool) {
    return UC.unwrap(x) < UC.unwrap(y);
}

/// @notice Checks if `x` is lower than or equal to `y`.
function lte(UC x, UC y) pure returns (bool) {
    return UC.unwrap(x) <= UC.unwrap(y);
}

/*//////////////////////////////////////////////////////////////////////////
                                CASTING FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using { into, unwrap } for UC global;

/// @notice Alias for the `UC.unwrap` function.
function into(UC x) pure returns (uint256 result) {
    result = UC.unwrap(x);
}

/// @notice Alias for the `UC.wrap` function.
function uc(uint256 x) pure returns (UC result) {
    result = UC.wrap(x);
}

/// @notice Alias for the `UC.unwrap` function.
function unwrap(UC x) pure returns (uint256 result) {
    result = UC.unwrap(x);
}

/// @notice Alias for the `UC.wrap` function.
function wrap(uint256 x) pure returns (UC result) {
    result = UC.wrap(x);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

type Price8 is uint64;
type Qty10 is uint80;
type Usd18 is uint96;

library Constants {

    /*-------------------------------- Role --------------------------------*/
    // 0x0000000000000000000000000000000000000000000000000000000000000000
    bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;
    // 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775
    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // 0xfc425f2263d0df187444b70e47283d622c70181c5baebb1306a01edba1ce184c
    bytes32 constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    // 0x62150a51582c26f4255242a3c4ca35fb04250e7315069523d650676aed01a56a
    bytes32 constant TOKEN_OPERATOR_ROLE = keccak256("TOKEN_OPERATOR_ROLE");
    // 0xbcf34dca9375a29f1b0549eee19900a8183308a2d43e0192eb541bc5ddd4501e
    bytes32 constant STAKE_OPERATOR_ROLE = keccak256("STAKE_OPERATOR");
    // 0xc24d2c87036c9189cc45e221d5dff8eaffb4966ee49ea36b4ffc88a2d85bf890
    bytes32 constant PRICE_FEED_OPERATOR_ROLE = keccak256("PRICE_FEED_OPERATOR_ROLE");
    // 0x04fcf77d802b9769438bfcbfc6eae4865484c9853501897657f1d28c3f3c603e
    bytes32 constant PAIR_OPERATOR_ROLE = keccak256("PAIR_OPERATOR_ROLE");
    // 0xfc8737ab85eb45125971625a9ebdb75cc78e01d5c1fa80c4c6e5203f47bc4fab
    bytes32 constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
    // 0x7d867aa9d791a9a4be418f90a2f248aa2c5f1348317792a6f6412f94df9819f7
    bytes32 constant PRICE_FEEDER_ROLE = keccak256("PRICE_FEEDER_ROLE");
    // 0x71df8753cacd2715e2a4666031956fa6a98952cb7bd14175b5923de54ec4ea8f
    bytes32 constant SELF_ROLE = keccak256("SELF_ROLE");

    /*-------------------------------- Decimals --------------------------------*/
    uint8 constant public PRICE_DECIMALS = 8;
    uint8 constant public QTY_DECIMALS = 10;
    uint8 constant public USD_DECIMALS = 18;

    uint16 constant public BASIS_POINTS_DIVISOR = 1e4;
    uint16 constant public MAX_LEVERAGE = 1e3;
    int256 constant public FUNDING_FEE_RATE_DIVISOR = 1e18;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../utils/Constants.sol";
import "../interfaces/IVault.sol";
import "../interfaces/ITrading.sol";
import "../../dependencies/IWBNB.sol";
import "./LibPriceFacade.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ZERO, ONE, UC, uc, into} from "unchecked-counter/src/UC.sol";

library LibVault {

    using Address for address payable;
    using SafeERC20 for IERC20;

    bytes32 constant VAULT_POSITION = keccak256("apollox.vault.storage");

    struct AvailableToken {
        address tokenAddress;
        uint32 tokenAddressPosition;
        uint16 weight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        uint8 decimals;
        bool stable;
        bool dynamicFee;
        bool asMargin;
    }

    struct VaultStorage {
        mapping(address => AvailableToken) tokens;
        address[] tokenAddresses;
        // tokenAddress => amount
        mapping(address => uint256) treasury;
        address wbnb;
        address exchangeTreasury;
    }

    function vaultStorage() internal pure returns (VaultStorage storage vs) {
        bytes32 position = VAULT_POSITION;
        assembly {
            vs.slot := position
        }
    }

    event AddToken(
        address indexed token, uint16 weight, uint16 feeBasisPoints,
        uint16 taxBasisPoints, bool stable, bool dynamicFee, bool asMargin
    );
    event RemoveToken(address indexed token);
    event UpdateToken(
        address indexed token,
        uint16 oldFeeBasisPoints, uint16 oldTaxBasisPoints, bool oldDynamicFee,
        uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee
    );
    event SupportTokenAsMargin(address indexed tokenAddress, bool supported);
    event ChangeWeight(address[] tokenAddress, uint16[] oldWeights, uint16[] newWeights);
    event CloseTradeRemoveLiquidity(address indexed token, uint256 amount);

    function initialize(address wbnb, address exchangeTreasury_) internal {
        VaultStorage storage vs = vaultStorage();
        require(vs.wbnb == address(0) && vs.exchangeTreasury == address(0), "LibAlpManager: Already initialized");
        vs.wbnb = wbnb;
        vs.exchangeTreasury = exchangeTreasury_;
    }

    function WBNB() internal view returns (address) {
        return vaultStorage().wbnb;
    }

    function exchangeTreasury() internal view returns (address) {
        return vaultStorage().exchangeTreasury;
    }

    function addToken(
        address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool stable,
        bool dynamicFee, bool asMargin, uint16[] memory weights
    ) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight == 0, "LibVault: Can't add token that already exists");
        if (dynamicFee && taxBasisPoints <= feeBasisPoints) {
            revert("LibVault: TaxBasisPoints must be greater than feeBasisPoints at dynamic rates");
        }
        at.tokenAddress = tokenAddress;
        at.tokenAddressPosition = uint32(vs.tokenAddresses.length);
        at.feeBasisPoints = feeBasisPoints;
        at.taxBasisPoints = taxBasisPoints;
        at.decimals = IERC20Metadata(tokenAddress).decimals();
        at.stable = stable;
        at.dynamicFee = dynamicFee;
        at.asMargin = asMargin;

        vs.tokenAddresses.push(tokenAddress);
        emit AddToken(at.tokenAddress, weights[weights.length - 1], at.feeBasisPoints, at.taxBasisPoints, at.stable, at.dynamicFee, at.asMargin);
        changeWeight(weights);
    }

    function removeToken(address tokenAddress, uint16[] memory weights) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight > 0, "LibVault: Token does not exist");

        changeWeight(weights);
        uint256 lastPosition = vs.tokenAddresses.length - 1;
        uint256 tokenAddressPosition = at.tokenAddressPosition;
        if (tokenAddressPosition != lastPosition) {
            address lastTokenAddress = vs.tokenAddresses[lastPosition];
            vs.tokenAddresses[tokenAddressPosition] = lastTokenAddress;
            vs.tokens[lastTokenAddress].tokenAddressPosition = uint32(tokenAddressPosition);
        }
        require(at.weight == 0, "LibVault: The weight of the removed Token must be 0.");
        vs.tokenAddresses.pop();
        delete vs.tokens[tokenAddress];
        emit RemoveToken(tokenAddress);
    }

    function updateToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight > 0, "LibVault: Token does not exist");
        if (dynamicFee && taxBasisPoints <= feeBasisPoints) {
            revert("LibVault: TaxBasisPoints must be greater than feeBasisPoints at dynamic rates");
        }
        (uint16 oldFeePoints, uint16 oldTaxPoints, bool oldDynamicFee) = (at.feeBasisPoints, at.taxBasisPoints, at.dynamicFee);
        at.feeBasisPoints = feeBasisPoints;
        at.taxBasisPoints = taxBasisPoints;
        at.dynamicFee = dynamicFee;
        emit UpdateToken(tokenAddress, oldFeePoints, oldTaxPoints, oldDynamicFee, feeBasisPoints, taxBasisPoints, dynamicFee);
    }

    function updateAsMagin(address tokenAddress, bool asMagin) internal {
        AvailableToken storage at = vaultStorage().tokens[tokenAddress];
        require(at.weight > 0, "LibVault: Token does not exist");
        require(at.asMargin != asMagin, "LibVault: No modification required");
        at.asMargin = asMagin;
        emit SupportTokenAsMargin(tokenAddress, asMagin);
    }

    function changeWeight(uint16[] memory weights) internal {
        VaultStorage storage vs = vaultStorage();
        require(weights.length == vs.tokenAddresses.length, "LibVault: Invalid weights");
        uint16 totalWeight;
        uint16[] memory oldWeights = new uint16[](weights.length);
        for (UC i = ZERO; i < uc(weights.length); i = i + ONE) {
            totalWeight += weights[i.into()];
            address tokenAddress = vs.tokenAddresses[i.into()];
            uint16 oldWeight = vs.tokens[tokenAddress].weight;
            oldWeights[i.into()] = oldWeight;
            vs.tokens[tokenAddress].weight = weights[i.into()];
        }
        require(totalWeight == Constants.BASIS_POINTS_DIVISOR, "LibVault: The sum of the weights is not equal to 10000");
        emit ChangeWeight(vs.tokenAddresses, oldWeights, weights);
    }

    function deposit(address token, uint256 amount) internal {
        deposit(token, amount, address(0), true);
    }

    // The caller checks whether the token exists and the amount>0
    // in order to return quickly in case of an error
    function deposit(address token, uint256 amount, address from, bool transferred) internal {
        if (!transferred) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
        }
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        vs.treasury[token] += amount;
    }

    function depositBNB(uint256 amount) internal {
        IWBNB(WBNB()).deposit{value : amount}();
        deposit(WBNB(), amount);
    }

    function decreaseByCloseTrade(address token, uint256 amount) internal returns (ITrading.CloseSettleToken[] memory settleTokens) {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        uint8 token_0_decimals = vs.tokens[token].decimals;
        ITrading.CloseSettleToken memory cst = ITrading.CloseSettleToken(
            token,
            vs.treasury[token] >= amount ? amount : vs.treasury[token],
            token_0_decimals
        );
        if (vs.treasury[token] >= amount) {
            vs.treasury[token] -= amount;
            settleTokens = new ITrading.CloseSettleToken[](1);
            settleTokens[0] = cst;
            emit CloseTradeRemoveLiquidity(token, amount);
            return settleTokens;
        } else {
            uint256 otherTokenAmountUsd = (amount - vs.treasury[token]) * LibPriceFacade.getPrice(token) * 1e10 / (10 ** token_0_decimals);
            address[] memory allTokens = vs.tokenAddresses;
            ITrading.MarginBalance[] memory balances = new ITrading.MarginBalance[](allTokens.length - 1);
            uint256 totalBalanceUsd;
            UC index = ZERO;
            for (UC i = ZERO; i < uc(allTokens.length); i = i + ONE) {
                address tokenAddress = allTokens[i.into()];
                AvailableToken memory at = vs.tokens[tokenAddress];
                if (at.asMargin && tokenAddress != token && vs.treasury[tokenAddress] > 0) {
                    uint256 balanceUsd = vs.treasury[tokenAddress] * LibPriceFacade.getPrice(tokenAddress) * 1e10 / (10 ** at.decimals);
                    balances[index.into()] = ITrading.MarginBalance(tokenAddress, LibPriceFacade.getPrice(tokenAddress), at.decimals, balanceUsd);
                    totalBalanceUsd += balanceUsd;
                    index = index + ONE;
                }
            }
            require(index.into() > 0 && otherTokenAmountUsd < totalBalanceUsd, "LibVault: Insufficient funds in the treasury");
            settleTokens = new ITrading.CloseSettleToken[]((index + ONE).into());
            settleTokens[0] = cst;
            vs.treasury[token] = 0;
            emit CloseTradeRemoveLiquidity(token, settleTokens[0].amount);

            uint points = Constants.BASIS_POINTS_DIVISOR;
            for (UC i = ONE; i < index; i = i + ONE) {
                ITrading.MarginBalance memory mb = balances[i.into()];
                uint256 share = mb.balanceUsd * 1e4 / totalBalanceUsd;
                settleTokens[i.into()] = ITrading.CloseSettleToken(mb.token, otherTokenAmountUsd * share * (10 ** mb.decimals) / (1e4 * 1e10 * mb.price), mb.decimals);
                vs.treasury[mb.token] -= settleTokens[i.into()].amount;
                emit CloseTradeRemoveLiquidity(mb.token, settleTokens[i.into()].amount);
                points -= share;
            }
            ITrading.MarginBalance memory b = balances[0];
            settleTokens[index.into()] = ITrading.CloseSettleToken(b.token, otherTokenAmountUsd * points * (10 ** b.decimals) / (1e4 * 1e10 * b.price), b.decimals);
            vs.treasury[b.token] -= settleTokens[index.into()].amount;
            emit CloseTradeRemoveLiquidity(b.token, settleTokens[index.into()].amount);
            return settleTokens;
        }
    }

    // The caller checks whether the token exists and the amount>0
    // in order to return quickly in case of an error
    function withdraw(address receiver, address token, uint256 amount) internal {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        require(vs.treasury[token] >= amount, "LibVault: Treasury insufficient balance");
        vs.treasury[token] -= amount;
        IERC20(token).safeTransfer(receiver, amount);
    }

    // The entry for calling this method needs to prevent reentry
    // use "../security/RentalGuard.sol"
    function withdrawBNB(address payable receiver, uint256 amount) internal {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        require(vs.treasury[WBNB()] >= amount, "LibVault: Treasury insufficient balance");
        IWBNB(WBNB()).withdraw(amount);
        vs.treasury[WBNB()] -= amount;
        receiver.sendValue(amount);
    }

    function getTotalValueUsd() internal view returns (uint256) {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        uint256 numTokens = vs.tokenAddresses.length;
        int256 totalValueUsd;
        for (UC i = ZERO; i < uc(numTokens); i + i + ONE) {
            address tokenAddress = vs.tokenAddresses[i.into()];
            LibVault.AvailableToken storage at = vs.tokens[tokenAddress];
            int256 price = int256(LibPriceFacade.getPrice(at.tokenAddress));
            int256 balance = int256(vs.treasury[at.tokenAddress]);
            int256 valueUsd = price * balance * int256((10 ** Constants.USD_DECIMALS)) / int256(10 ** (Constants.PRICE_DECIMALS + at.decimals));
            totalValueUsd += valueUsd;
        }
        return uint256(totalValueUsd);
    }

    function getTokenByAddress(address tokenAddress) internal view returns (AvailableToken memory) {
        return LibVault.vaultStorage().tokens[tokenAddress];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IVault.sol";
import "../interfaces/IPriceFacade.sol";
import "../interfaces/ITrading.sol";
import "../interfaces/ITradingPortal.sol";
import "../interfaces/ITradingCore.sol";
import "../interfaces/IPairsManager.sol";
import "../interfaces/ITradingReader.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ZERO, ONE, UC, uc, into} from "unchecked-counter/src/UC.sol";

library LibTrading {

    using SafeERC20 for IERC20;
    using SignedMath for int256;

    // todo: 后面改回 apollox.trading.storage
    bytes32 constant TRADING_POSITION = keccak256("apollox.trading.storage.20230306");

    struct TradingStorage {
        uint256 salt;
        //--------------- pending ---------------
        // tradeHash =>
        mapping(bytes32 => ITradingReader.PendingTrade) pendingTrades;
        // margin.tokenIn => total amount of all pending trades
        mapping(address => uint256) pendingTradeAmountIns;
        //--------------- open ---------------
        // tradeHash =>
        mapping(bytes32 => ITrading.OpenTrade) openTrades;
        // user => tradeHash[]
        mapping(address => bytes32[]) userOpenTradeHashes;
        // tokenIn =>
        mapping(address => uint256) openTradeAmountIns;
        // tokenIn[]
        address[] openTradeTokenIns;
    }

    function tradingStorage() internal pure returns (TradingStorage storage ts) {
        bytes32 position = TRADING_POSITION;
        assembly {
            ts.slot := position
        }
    }

    event FundingFeeAddLiquidity(address indexed token, uint256 amount);
    event CloseTradeReceived(address indexed user, bytes32 indexed tradeHash, address indexed token, uint256 amount);
    event CloseTradeAddLiquidity(address indexed token, uint256 amount);


    function check(ITrading.OpenTrade memory ot) internal view {
        require(ot.margin > 0, "LibTrading: Trade information does not exist");
        require(ot.user == msg.sender, "LibTrading: Can only be updated by yourself");
    }

    function increaseOpenTradeAmount(TradingStorage storage ts, address tokenIn, uint256 amountIn) internal {
        address[] storage tokenIns = ts.openTradeTokenIns;
        bool exists;
        for (UC i = ZERO; i < uc(tokenIns.length); i = i + ONE) {
            if (tokenIns[i.into()] == tokenIn) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            tokenIns.push(tokenIn);
        }
        ts.openTradeAmountIns[tokenIn] += amountIn;
    }

    function transferFundingFeeToVault(
        TradingStorage storage ts,
        ITrading.MarginBalance memory mb,
        uint256 lpReceiveFundingFeeUsd,
        uint256 share
    ) internal {
        uint lpFundingFee = lpReceiveFundingFeeUsd * share * (10 ** mb.decimals) / (1e4 * 1e10 * mb.price);
        ts.openTradeAmountIns[mb.token] -= lpFundingFee;
        IVault(address(this)).increaseByCloseTrade(mb.token, lpFundingFee);
        emit FundingFeeAddLiquidity(mb.token, lpFundingFee);
    }

    function calcFundingFee(
        ITrading.OpenTrade memory ot,
        IVault.MarginToken memory mt,
        uint256 marketPrice
    ) internal view returns (int256 fundingFee) {
        int256 longAccFundingFeePerShare = ITradingCore(address(this)).lastLongAccFundingFeePerShare(ot.pairBase);
        return calcFundingFee(ot, mt, marketPrice, longAccFundingFeePerShare);
    }

    function calcFundingFee(
        ITrading.OpenTrade memory ot,
        IVault.MarginToken memory mt,
        uint256 marketPrice,
        int256 longAccFundingFeePerShare
    ) internal pure returns (int256 fundingFee) {
        int256 fundingFeeUsd;
        if (ot.isLong) {
            fundingFeeUsd = int256(ot.qty * marketPrice) * (longAccFundingFeePerShare - ot.longAccFundingFeePerShare) / 1e18;
        } else {
            fundingFeeUsd = int256(ot.qty * marketPrice) * (longAccFundingFeePerShare - ot.longAccFundingFeePerShare) * (- 1) / 1e18;
        }
        fundingFee = fundingFeeUsd * int256((10 ** mt.decimals) / (1e10 * mt.price));
        return fundingFee;
    }

    struct SettleAssetTuple {
        ITrading.OpenTrade ot;
        bytes32 tradeHash;
        int256 openTradeReceive;
        uint256 closeFee;
        uint256 userReceive;
        int256 lpReceive;
    }

    function settleForCloseTrade(
        TradingStorage storage ts, ITrading.OpenTrade memory ot,
        bytes32 tradeHash, uint256 marketPrice, int256 longAccFundingFeePerShare
    ) internal {
        IVault.MarginToken memory mt = IVault(address(this)).getTokenForTrading(ot.tokenIn);
        IPairsManager.FeeConfig memory feeConfig = IPairsManager(address(this)).getPairFeeConfig(ot.pairBase);

        uint256 closeNotionalUsd = ITradingCore(address(this)).slippagePrice(ot.pairBase, marketPrice, ot.qty, !ot.isLong) * ot.qty;
        int256 pnl = int256(ot.isLong ? closeNotionalUsd - ot.entryPrice * ot.qty : ot.entryPrice * ot.qty - closeNotionalUsd)
        * int256(10 ** mt.decimals) / int256(1e18 * mt.price);

        // openTradeReceive + closeFee + userReceive + lpReceive == 0
        // closeFee >= 0 && userReceive >= 0
        int256 openTradeReceive = - (int256(uint256(ot.margin)) + calcFundingFee(ot, mt, marketPrice, longAccFundingFeePerShare));
        uint256 closeFee = closeNotionalUsd * feeConfig.closeFeeP * (10 ** mt.decimals) / (1e4 * 1e10 * mt.price);
        uint256 userReceive;
        int256 lpReceive;
        if (- openTradeReceive + pnl >= int256(closeFee)) {
            userReceive = uint256(- openTradeReceive + pnl) - closeFee;
            lpReceive = - pnl;
        } else if (- openTradeReceive + pnl > 0 && - openTradeReceive + pnl < int256(closeFee)) {
            closeFee = uint256(- openTradeReceive + pnl);
            lpReceive = - pnl;
        } else {
            lpReceive = - openTradeReceive;
        }
        _settleAsset(ts, SettleAssetTuple(ot, tradeHash, openTradeReceive, closeFee, userReceive, lpReceive));
    }

    function _settleAsset(TradingStorage storage ts, SettleAssetTuple memory tuple) private {
        if (tuple.openTradeReceive < 0) {
            ITrading.CloseSettleToken[] memory openTradeSettleTokens = _decreaseByCloseTrade(ts, tuple.ot.tokenIn, tuple.openTradeReceive.abs());
            if (tuple.lpReceive < 0) {// |openTradeReceive + lpReceive| = userReceive + closeFee
                ITrading.CloseSettleToken[] memory lpSettleTokens = IVault(address(this)).decreaseByCloseTrade(tuple.ot.tokenIn, tuple.lpReceive.abs());
                require(openTradeSettleTokens[0].amount + lpSettleTokens[0].amount >= tuple.closeFee, "LibTrading: Target token insufficient funds");
                if (tuple.closeFee > 0) {
                    // todo: 手续费的处理
                }

                lpSettleTokens[0].amount = lpSettleTokens[0].amount + openTradeSettleTokens[0].amount - tuple.closeFee;
                _transferToUserForClose(tuple.tradeHash, tuple.ot.user, lpSettleTokens);

                openTradeSettleTokens[0].amount = 0;
                _transferToUserForClose(tuple.tradeHash, tuple.ot.user, openTradeSettleTokens);
            } else if (tuple.lpReceive == 0) {// |openTradeReceive| = userReceive + closeFee
                require(openTradeSettleTokens[0].amount >= tuple.closeFee, "LibTrading: Target token insufficient funds");
                if (tuple.closeFee > 0) {
                    // todo: 手续费的处理
                }

                openTradeSettleTokens[0].amount -= tuple.closeFee;
                _transferToUserForClose(tuple.tradeHash, tuple.ot.user, openTradeSettleTokens);
            } else {// |openTradeReceive| = userReceive + closeFee + lpReceive
                require(openTradeSettleTokens[0].amount >= tuple.closeFee, "LibTrading: Target token insufficient funds");
                if (tuple.closeFee > 0) {
                    // todo: 手续费的处理
                }

                openTradeSettleTokens[0].amount -= tuple.closeFee;
                _transferToUserForClose(ts, tuple.tradeHash, tuple.ot.user, openTradeSettleTokens, tuple.userReceive, true);
            }
        } else if (tuple.openTradeReceive == 0) {
            if (tuple.lpReceive < 0) {// |lpReceive| = userReceive + closeFee
                ITrading.CloseSettleToken[] memory lpSettleTokens = IVault(address(this)).decreaseByCloseTrade(tuple.ot.tokenIn, tuple.lpReceive.abs());
                require(lpSettleTokens[0].amount >= tuple.closeFee, "LibTrading: Target token insufficient funds");
                if (tuple.closeFee > 0) {
                    // todo: 手续费的处理
                }

                lpSettleTokens[0].amount -= tuple.closeFee;
                _transferToUserForClose(tuple.tradeHash, tuple.ot.user, lpSettleTokens);
            }
        } else {
            if (tuple.lpReceive < 0) {// |lpReceive| = userReceive + closeFee + openTradeReceive
                ITrading.CloseSettleToken[] memory lpSettleTokens = IVault(address(this)).decreaseByCloseTrade(tuple.ot.tokenIn, tuple.lpReceive.abs());
                require(lpSettleTokens[0].amount >= tuple.closeFee, "LibTrading: Target token insufficient funds");
                if (tuple.closeFee > 0) {
                    // todo: 手续费的处理
                }

                lpSettleTokens[0].amount -= tuple.closeFee;
                _transferToUserForClose(ts, tuple.tradeHash, tuple.ot.user, lpSettleTokens, tuple.userReceive, false);
            }
        }
    }

    function _decreaseByCloseTrade(
        TradingStorage storage ts, address token, uint256 amount
    ) private returns (ITrading.CloseSettleToken[] memory settleTokens) {
        IVault.MarginToken memory mt_0 = IVault(address(this)).getTokenForTrading(token);
        ITrading.CloseSettleToken memory cst = ITrading.CloseSettleToken(
            token,
            ts.openTradeAmountIns[token] >= amount ? amount : ts.openTradeAmountIns[token],
            mt_0.decimals
        );
        if (ts.openTradeAmountIns[token] >= amount) {
            ts.openTradeAmountIns[token] -= amount;
            settleTokens = new ITrading.CloseSettleToken[](1);
            settleTokens[0] = cst;
            return settleTokens;
        } else {
            require(ts.openTradeTokenIns.length > 1, "LibTrading: Insufficient funds in the openTrade");
            uint256 otherTokenAmountUsd = (amount - ts.openTradeAmountIns[token]) * mt_0.price * 1e10 / (10 ** mt_0.decimals);

            ITrading.MarginBalance[] memory balances = new ITrading.MarginBalance[](ts.openTradeTokenIns.length - 1);
            uint256 totalBalanceUsd;
            UC index = ZERO;
            for (UC i = ZERO; i < uc(ts.openTradeTokenIns.length); i = i + ONE) {
                address tokenIn = ts.openTradeTokenIns[i.into()];
                if (tokenIn != token && ts.openTradeAmountIns[tokenIn] > 0) {
                    IVault.MarginToken memory mt = IVault(address(this)).getTokenForTrading(tokenIn);
                    uint balanceUsd = mt.price * ts.openTradeAmountIns[tokenIn] * 1e10 / (10 ** mt.decimals);
                    balances[index.into()] = ITrading.MarginBalance(tokenIn, mt.price, mt.decimals, balanceUsd);
                    totalBalanceUsd += balanceUsd;
                    index = index + ONE;
                }
            }
            require(otherTokenAmountUsd < totalBalanceUsd, "LibTrading: Insufficient funds in the openTrade");
            settleTokens = new ITrading.CloseSettleToken[]((index + ONE).into());
            settleTokens[0] = cst;
            ts.openTradeAmountIns[token] = 0;
            if (index.into() > 0) {
                uint points = 1e4;
                for (UC i = ONE; i < index; i = i + ONE) {
                    ITrading.MarginBalance memory mb = balances[i.into()];
                    uint256 share = mb.balanceUsd * 1e4 / totalBalanceUsd;
                    settleTokens[i.into()] = ITrading.CloseSettleToken(mb.token, otherTokenAmountUsd * share * (10 ** mb.decimals) / (1e4 * 1e10 * mb.price), mb.decimals);
                    ts.openTradeAmountIns[mb.token] -= settleTokens[i.into()].amount;
                    points -= share;
                }
                ITrading.MarginBalance memory b = balances[0];
                settleTokens[index.into()] = ITrading.CloseSettleToken(b.token, otherTokenAmountUsd * points * (10 ** b.decimals) / (1e4 * 1e10 * b.price), b.decimals);
                ts.openTradeAmountIns[b.token] -= settleTokens[index.into()].amount;
            }
            return settleTokens;
        }
    }


    function _closeTradeReceived(bytes32 tradeHash, address to, address token, uint256 amount) private {
        IERC20(token).safeTransfer(to, amount);
        emit CloseTradeReceived(to, tradeHash, token, amount);
    }

    function _transferToUserForClose(bytes32 tradeHash, address to, ITrading.CloseSettleToken[] memory settleTokens) private {
        for (UC i = ZERO; i < uc(settleTokens.length); i = i + ONE) {
            if (settleTokens[i.into()].amount > 0) {
                _closeTradeReceived(tradeHash, to, settleTokens[i.into()].token, settleTokens[i.into()].amount);
            }
        }
    }

    function _transferToUserForClose(
        TradingStorage storage ts, bytes32 tradeHash, address to,
        ITrading.CloseSettleToken[] memory settleTokens,
        uint256 userReceive, bool toLp
    ) private {
        if (settleTokens[0].amount >= userReceive) {
            if (userReceive > 0) {
                _closeTradeReceived(tradeHash, to, settleTokens[0].token, userReceive);
            }
            settleTokens[0].amount -= userReceive;
            for (UC i = ZERO; i < uc(settleTokens.length); i = i + ONE) {
                if (settleTokens[i.into()].amount > 0) {
                    if (toLp) {
                        IVault(address(this)).increaseByCloseTrade(settleTokens[i.into()].token, settleTokens[i.into()].amount);
                        emit CloseTradeAddLiquidity(settleTokens[i.into()].token, settleTokens[i.into()].amount);
                    } else {
                        increaseOpenTradeAmount(ts, settleTokens[i.into()].token, settleTokens[i.into()].amount);
                    }
                }
            }
        } else {
            if (settleTokens[0].amount > 0) {
                _closeTradeReceived(tradeHash, to, settleTokens[0].token, settleTokens[0].amount);
            }
            uint256 userReceiveUsd = (userReceive - settleTokens[0].amount) * IPriceFacade(address(this)).getPrice(settleTokens[0].token) * 1e10 / (10 ** settleTokens[0].decimals);
            for (UC i = ONE; i < uc(settleTokens.length); i = i + ONE) {
                if (settleTokens[i.into()].amount > 0) {
                    uint256 price = IPriceFacade(address(this)).getPrice(settleTokens[i.into()].token);
                    uint256 valueUsd = settleTokens[i.into()].amount * price * 1e10 / (10 ** settleTokens[i.into()].decimals);
                    if (userReceiveUsd >= valueUsd) {
                        _closeTradeReceived(tradeHash, to, settleTokens[i.into()].token, settleTokens[i.into()].amount);
                        userReceiveUsd -= valueUsd;
                    } else if (userReceiveUsd > 0 && userReceiveUsd < valueUsd) {
                        userReceive = userReceiveUsd * (10 ** settleTokens[i.into()].decimals) / (price * 1e10);
                        _closeTradeReceived(tradeHash, to, settleTokens[i.into()].token, userReceive);
                        if (toLp) {
                            IVault(address(this)).increaseByCloseTrade(settleTokens[i.into()].token, settleTokens[i.into()].amount - userReceive);
                            emit CloseTradeAddLiquidity(settleTokens[i.into()].token, settleTokens[i.into()].amount - userReceive);
                        } else {
                            increaseOpenTradeAmount(ts, settleTokens[i.into()].token, settleTokens[i.into()].amount - userReceive);
                        }
                        userReceiveUsd = 0;
                    } else {
                        if (toLp) {
                            IVault(address(this)).increaseByCloseTrade(settleTokens[i.into()].token, settleTokens[i.into()].amount);
                            emit CloseTradeAddLiquidity(settleTokens[i.into()].token, settleTokens[i.into()].amount);
                        } else {
                            increaseOpenTradeAmount(ts, settleTokens[i.into()].token, settleTokens[i.into()].amount);
                        }
                    }
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/ITradingTrigger.sol";
import "./LibChainlinkPrice.sol";
import {ZERO, ONE, UC, uc, into} from "unchecked-counter/src/UC.sol";

library LibPriceFacade {

    // todo: 后面改回 apollox.price.facade.storage
    bytes32 constant PRICE_FACADE_POSITION = keccak256("apollox.price.facade.storage.20230306");

    struct LatestCallbackPrice {
        uint64 price;
        uint40 timestamp;
    }

    struct OpenOrClose {
        bytes32 id;
        bool isOpen;
    }

    struct PendingPrice {
        uint256 blockNumber;
        address token;
        OpenOrClose[] ids;
    }

    struct PriceFacadeStorage {
        // BTC/ETH/BNB/.../ =>
        mapping(address => LatestCallbackPrice) callbackPrices;
        // keccak256(token, block.number) =>
        mapping(bytes32 => PendingPrice) pendingPrices;
        uint16 lowPriceGapP;   // %
        uint16 highPriceGapP;  // %
        uint16 maxPriceDelay;
    }

    function priceFacadeStorage() internal pure returns (PriceFacadeStorage storage pfs) {
        bytes32 position = PRICE_FACADE_POSITION;
        assembly {
            pfs.slot := position
        }
    }

    event SetLowPriceGapP(uint16 indexed oldLowPriceGapP, uint16 indexed lowPriceGapP);
    event SetHighPriceGapP(uint16 indexed oldHighPriceGapP, uint16 indexed highPriceGapP);
    event SetMaxPriceDelay(uint16 indexed oldMaxPriceDelay, uint16 indexed maxPriceDelay);
    event RequestPrice(bytes32 indexed requestId, address indexed token);
    event PriceRejected(
        address indexed feeder, bytes32 indexed requestId, address indexed token,
        uint64 price, uint64 beforePrice, uint40 updatedAt
    );
    event PriceUpdated(
        address indexed feeder, bytes32 indexed requestId,
        address indexed token, uint64 price
    );

    function initialize(uint16 lowPriceGapP, uint16 highPriceGapP, uint16 maxPriceDelay) internal {
        PriceFacadeStorage storage pfs = priceFacadeStorage();
        require(pfs.lowPriceGapP == 0 && pfs.highPriceGapP == 0 && pfs.maxPriceDelay == 0, "LibPriceFacade: Already initialized");
        _setLowPriceGapP(pfs, lowPriceGapP);
        _setHighPriceGapP(pfs, highPriceGapP);
        setMaxPriceDelay(maxPriceDelay);
    }

    function _setLowPriceGapP(PriceFacadeStorage storage pfs, uint16 lowPriceGapP) private {
        uint16 old = pfs.lowPriceGapP;
        pfs.lowPriceGapP = lowPriceGapP;
        emit SetLowPriceGapP(old, lowPriceGapP);
    }

    function _setHighPriceGapP(PriceFacadeStorage storage pfs, uint16 highPriceGapP) private {
        uint16 old = pfs.highPriceGapP;
        pfs.highPriceGapP = highPriceGapP;
        emit SetHighPriceGapP(old, highPriceGapP);
    }

    function setLowAndHighPriceGapP(uint16 lowPriceGapP, uint16 highPriceGapP) internal {
        PriceFacadeStorage storage pfs = priceFacadeStorage();
        if (lowPriceGapP > 0 && highPriceGapP > 0) {
            require(highPriceGapP > lowPriceGapP, "LibPriceFacade: highPriceGapP must be greater than lowPriceGapP");
            _setLowPriceGapP(pfs, lowPriceGapP);
            _setHighPriceGapP(pfs, highPriceGapP);
        } else if (lowPriceGapP > 0) {
            require(pfs.highPriceGapP > lowPriceGapP, "LibPriceFacade: highPriceGapP must be greater than lowPriceGapP");
            _setLowPriceGapP(pfs, lowPriceGapP);
        } else {
            require(highPriceGapP > pfs.lowPriceGapP, "LibPriceFacade: highPriceGapP must be greater than lowPriceGapP");
            _setHighPriceGapP(pfs, highPriceGapP);
        }
    }

    function setMaxPriceDelay(uint16 maxPriceDelay) internal {
        PriceFacadeStorage storage pfs = priceFacadeStorage();
        uint16 old = pfs.maxPriceDelay;
        pfs.maxPriceDelay = maxPriceDelay;
        emit SetMaxPriceDelay(old, maxPriceDelay);
    }

    function getPrice(address token) internal view returns (uint256) {
        (uint256 price, uint8 decimals,) = LibChainlinkPrice.getPriceFromChainlink(token);
        return decimals == 8 ? price : price * 1e8 / (10 ** decimals);
    }

    function requestPrice(bytes32 id, address token, bool isOpen) internal {
        PriceFacadeStorage storage pfs = priceFacadeStorage();
        bytes32 requestId = keccak256(abi.encode(token, block.number));
        PendingPrice storage pendingPrice = pfs.pendingPrices[requestId];
        pendingPrice.ids.push(OpenOrClose(id, isOpen));
        if (pendingPrice.blockNumber != block.number) {
            pendingPrice.token = token;
            pendingPrice.blockNumber = block.number;
            emit RequestPrice(requestId, token);
        }
    }

    function requestPriceCallback(bytes32 requestId, uint64 price) internal {
        PriceFacadeStorage storage pfs = priceFacadeStorage();
        PendingPrice memory pendingPrice = pfs.pendingPrices[requestId];
        OpenOrClose[] memory ids = pendingPrice.ids;
        require(pendingPrice.blockNumber > 0 && ids.length > 0, "LibPriceFacade: requestId does not exist");

        (uint64 beforePrice, uint40 updatedAt) = getPriceFromCacheOrOracle(pendingPrice.token);
        uint64 priceGap = price > beforePrice ? price - beforePrice : beforePrice - price;
        uint gapPercentage = priceGap * 1e4 / beforePrice;
        // Excessive price difference. Reject this price
        if (gapPercentage > pfs.highPriceGapP) {
            emit PriceRejected(msg.sender, requestId, pendingPrice.token, price, beforePrice, updatedAt);
            return;
        }
        LatestCallbackPrice storage cachePrice = pfs.callbackPrices[pendingPrice.token];
        cachePrice.timestamp = uint40(block.timestamp);
        cachePrice.price = price;
        // The time interval is too long.
        // receive the current price but not use it
        // and wait for the next price to be feed.
        if (block.timestamp > updatedAt + pfs.maxPriceDelay) {
            emit PriceRejected(msg.sender, requestId, pendingPrice.token, price, beforePrice, updatedAt);
            return;
        }
        uint64 upperPrice = price;
        uint64 lowerPrice = price;
        if (gapPercentage > pfs.lowPriceGapP) {
            (upperPrice, lowerPrice) = price > beforePrice ? (price, beforePrice) : (beforePrice, price);
        }
        for (UC i = ZERO; i < uc(ids.length); i = i + ONE) {
            OpenOrClose memory openOrClose = ids[i.into()];
            if (openOrClose.isOpen) {
                ITradingTrigger(address(this)).marketTradeCallback(openOrClose.id, upperPrice, lowerPrice);
            } else {
                ITradingTrigger(address(this)).closeTradeCallback(openOrClose.id, upperPrice, lowerPrice);
            }
        }
        // Deleting data can save a little gas
        emit PriceUpdated(msg.sender, requestId, pendingPrice.token, price);
        delete pfs.pendingPrices[requestId];
    }

    function getPriceFromCacheOrOracle(address token) internal view returns (uint64, uint40) {
        LatestCallbackPrice memory cachePrice = priceFacadeStorage().callbackPrices[token];
        (uint256 price, uint8 decimals,uint256 startedAt) = LibChainlinkPrice.getPriceFromChainlink(token);
        uint40 updatedAt = cachePrice.timestamp >= startedAt ? cachePrice.timestamp : uint40(startedAt);
        // Take the newer price
        uint64 tokenPrice = cachePrice.timestamp >= startedAt ? cachePrice.price :
        (decimals == 8 ? uint64(price) : uint64(price * 1e8 / (10 ** decimals)));
        return (tokenPrice, updatedAt);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./LibFeeManager.sol";
import "./LibPriceFacade.sol";
import "../interfaces/IPairsManager.sol";
import {ZERO, ONE, UC, uc, into} from "unchecked-counter/src/UC.sol";

library LibPairsManager {

    // todo: 后面改回 apollox.pairs.manager.storage
    bytes32 constant PAIRS_MANAGER_STORAGE_POSITION = keccak256("apollox.pairs.manager.storage.20230306");

    /*
       tier    notionalUsd     maxLeverage      initialLostP        liqLostP
        1      (0 ~ 10,000]        20              95%                97.5%
        2    (10,000 ~ 50,000]     10              90%                 95%
        3    (50,000 ~ 100,000]     5              80%                 90%
        4    (100,000 ~ 200,000]    3              75%                 85%
        5    (200,000 ~ 500,000]    2              60%                 75%
        6    (500,000 ~ 800,000]    1              40%                 50%
    */
    struct LeverageMargin {
        uint256 notionalUsd;
        uint16 tier;
        uint16 maxLeverage;
        uint16 initialLostP; // %
        uint16 liqLostP;     // %
    }

    struct SlippageConfig {
        string name;
        uint256 onePercentDepthAboveUsd;
        uint256 onePercentDepthBelowUsd;
        uint16 slippageLongP;       // %
        uint16 slippageShortP;      // %
        uint16 index;
        IPairsManager.SlippageType slippageType;
        bool enable;
    }

    struct Pair {
        // BTC/USD
        string name;
        // BTC address
        address base;
        uint16 basePosition;
        IPairsManager.PairType pairType;
        IPairsManager.PairStatus status;

        uint16 slippageConfigIndex;
        uint16 slippagePosition;

        uint16 feeConfigIndex;
        uint16 feePosition;

        uint256 maxLongOiUsd;
        uint256 maxShortOiUsd;
        uint256 fundingFeePerBlockP;  // 1e18
        uint256 minFundingFeeR;       // 1e18
        uint256 maxFundingFeeR;       // 1e18
        // tier => LeverageMargin
        mapping(uint16 => LeverageMargin) leverageMargins;
        uint16 maxTier;
    }

    struct PairsManagerStorage {
        // 0/1/2/3/.../ => SlippageConfig
        mapping(uint16 => SlippageConfig) slippageConfigs;
        // SlippageConfig index => pairs.base[]
        mapping(uint16 => address[]) slippageConfigPairs;
        mapping(address => Pair) pairs;
        address[] pairBases;
    }

    function pairsManagerStorage() internal pure returns (PairsManagerStorage storage pms) {
        bytes32 position = PAIRS_MANAGER_STORAGE_POSITION;
        assembly {
            pms.slot := position
        }
    }

    event AddSlippageConfig(
        uint16 indexed index, IPairsManager.SlippageType indexed slippageType,
        uint256 onePercentDepthAboveUsd, uint256 onePercentDepthBelowUsd,
        uint16 slippageLongP, uint16 slippageShortP, string name
    );
    event RemoveSlippageConfig(uint16 indexed index);
    event UpdateSlippageConfig(
        uint16 indexed index,
        SlippageConfig oldConfig, SlippageConfig config
    );
    event AddPair(
        address indexed base,
        IPairsManager.PairType indexed pairType,
        uint16 slippageConfigIndex, uint16 feeConfigIndex,
        string name, LeverageMargin[] leverageMargins
    );
    event UpdatePairMaxOi(
        address indexed base,
        uint256 OldMaxLongOiUsd, uint256 oldMaxShortOiUsd,
        uint256 maxLongOiUsd, uint256 maxShortOiUsd
    );
    event UpdatePairFundingFeeConfig(
        address indexed base,
        uint256 oldFundingFeePerBlockP, uint256 oldMinFundingFeeR, uint256 oldMaxFundingFeeR,
        uint256 fundingFeePerBlockP, uint256 minFundingFeeR, uint256 maxFundingFeeR
    );
    event RemovePair(address indexed base);
    event UpdatePairStatus(
        address indexed base,
        IPairsManager.PairStatus indexed oldStatus,
        IPairsManager.PairStatus indexed status
    );
    event UpdatePairSlippage(address indexed base, uint16 indexed oldSlippageConfigIndexed, uint16 indexed slippageConfigIndex);
    event UpdatePairFee(address indexed base, uint16 indexed oldfeeConfigIndex, uint16 indexed feeConfigIndex);
    event UpdatePairLeverageMargin(
        address indexed base,
        LeverageMargin[] oldLeverageMargins,
        LeverageMargin[] leverageMargins
    );

    function addSlippageConfig(
        uint16 index, string calldata name, IPairsManager.SlippageType slippageType,
        uint256 onePercentDepthAboveUsd, uint256 onePercentDepthBelowUsd,
        uint16 slippageLongP, uint16 slippageShortP
    ) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        SlippageConfig storage config = pms.slippageConfigs[index];
        require(!config.enable, "LibPairsManager: Configuration already exists");
        config.index = index;
        config.name = name;
        config.enable = true;
        config.slippageType = slippageType;
        config.onePercentDepthAboveUsd = onePercentDepthAboveUsd;
        config.onePercentDepthBelowUsd = onePercentDepthBelowUsd;
        config.slippageLongP = slippageLongP;
        config.slippageShortP = slippageShortP;
        emit AddSlippageConfig(index, slippageType, onePercentDepthAboveUsd,
            onePercentDepthBelowUsd, slippageLongP, slippageShortP, name);
    }

    function removeSlippageConfig(uint16 index) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        SlippageConfig storage config = pms.slippageConfigs[index];
        require(config.enable, "LibPairsManager: Configuration not enabled");
        require(pms.slippageConfigPairs[index].length == 0, "LibPairsManager: Cannot remove a configuration that is still in use");
        delete pms.slippageConfigs[index];
        emit RemoveSlippageConfig(index);
    }

    function updateSlippageConfig(SlippageConfig memory sc) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        SlippageConfig storage config = pms.slippageConfigs[sc.index];
        require(config.enable, "LibPairsManager: Configuration not enabled");

        config.slippageType = sc.slippageType;
        config.onePercentDepthAboveUsd = sc.onePercentDepthAboveUsd;
        config.onePercentDepthBelowUsd = sc.onePercentDepthBelowUsd;
        config.slippageLongP = sc.slippageLongP;
        config.slippageShortP = sc.slippageShortP;
        sc.name = config.name;
        emit UpdateSlippageConfig(sc.index, sc, config);
    }

    function addPair(
        IPairsManager.PairSimple memory ps,
        uint16 slippageConfigIndex, uint16 feeConfigIndex,
        LeverageMargin[] memory leverageMargins
    ) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        require(pms.pairBases.length < 70, "LibPairsManager: Exceed the maximum number");
        Pair storage pair = pms.pairs[ps.base];
        require(pair.base == address(0), "LibPairsManager: Pair already exists");
        require(LibPriceFacade.getPrice(ps.base) > 0, "LibPairsManager: No price feed has been configured for the pair");
        {
            SlippageConfig memory slippageConfig = pms.slippageConfigs[slippageConfigIndex];
            require(slippageConfig.enable, "LibPairsManager: Slippage configuration is not available");
            (LibFeeManager.FeeConfig memory feeConfig, address[] storage feePairs) = LibFeeManager.getFeeConfigByIndex(feeConfigIndex);
            require(feeConfig.enable, "LibPairsManager: Fee configuration is not available");

            pair.slippageConfigIndex = slippageConfigIndex;
            address[] storage slippagePairs = pms.slippageConfigPairs[slippageConfigIndex];
            pair.slippagePosition = uint16(slippagePairs.length);
            slippagePairs.push(ps.base);

            pair.feeConfigIndex = feeConfigIndex;
            pair.feePosition = uint16(feePairs.length);
            feePairs.push(ps.base);
        }
        pair.name = ps.name;
        pair.base = ps.base;
        pair.basePosition = uint16(pms.pairBases.length);
        pms.pairBases.push(ps.base);
        pair.pairType = ps.pairType;
        pair.status = ps.status;
        pair.maxTier = uint16(leverageMargins.length);
        for (UC i = ONE; i <= uc(leverageMargins.length); i = i + ONE) {
            pair.leverageMargins[uint16(i.into())] = leverageMargins[uint16(i.into() - 1)];
        }
        emit AddPair(ps.base, ps.pairType, slippageConfigIndex, feeConfigIndex, ps.name, leverageMargins);
    }

    function updatePairMaxOi(address base, uint256 maxLongOiUsd, uint256 maxShortOiUsd) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");

        uint256 oldMaxLongOiUsd = pair.maxLongOiUsd;
        uint256 oldMaxShortOiUsd = pair.maxShortOiUsd;
        pair.maxLongOiUsd = maxLongOiUsd;
        pair.maxShortOiUsd = maxShortOiUsd;
        emit UpdatePairMaxOi(base, oldMaxLongOiUsd, oldMaxShortOiUsd, maxLongOiUsd, maxShortOiUsd);
    }

    function updatePairFundingFeeConfig(address base, uint256 fundingFeePerBlockP, uint256 minFundingFeeR, uint256 maxFundingFeeR) internal {
        require(maxFundingFeeR > minFundingFeeR, "LibPairsManager: fundingFee parameter is invalid");
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");

        uint256 oldFundingFeePerBlockP = pair.fundingFeePerBlockP;
        uint256 oldMinFundingFeeR = pair.minFundingFeeR;
        uint256 oldMaxFundingFeeR = pair.maxFundingFeeR;
        pair.fundingFeePerBlockP = fundingFeePerBlockP;
        pair.minFundingFeeR = minFundingFeeR;
        pair.maxFundingFeeR = maxFundingFeeR;
        emit UpdatePairFundingFeeConfig(
            base, oldFundingFeePerBlockP, oldMinFundingFeeR, oldMaxFundingFeeR,
            fundingFeePerBlockP, minFundingFeeR, maxFundingFeeR
        );
    }

    function removePair(address base) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");

        address[] storage slippagePairs = pms.slippageConfigPairs[pair.slippageConfigIndex];
        uint lastPositionSlippage = slippagePairs.length - 1;
        uint slippagePosition = pair.slippagePosition;
        if (slippagePosition != lastPositionSlippage) {
            address lastBase = slippagePairs[lastPositionSlippage];
            slippagePairs[slippagePosition] = lastBase;
            pms.pairs[lastBase].slippagePosition = uint16(slippagePosition);
        }
        slippagePairs.pop();

        (, address[] storage feePairs) = LibFeeManager.getFeeConfigByIndex(pair.feeConfigIndex);
        uint lastPositionFee = feePairs.length - 1;
        uint feePosition = pair.feePosition;
        if (feePosition != lastPositionFee) {
            address lastBase = feePairs[lastPositionFee];
            feePairs[feePosition] = lastBase;
            pms.pairs[lastBase].feePosition = uint16(feePosition);
        }
        feePairs.pop();

        address[] storage pairBases = pms.pairBases;
        uint lastPositionBase = pairBases.length - 1;
        uint basePosition = pair.basePosition;
        if (basePosition != lastPositionBase) {
            address lastBase = pairBases[lastPositionBase];
            pairBases[basePosition] = lastBase;
            pms.pairs[lastBase].basePosition = uint16(basePosition);
        }
        pairBases.pop();
        delete pms.pairs[base];
        emit RemovePair(base);
    }

    function updatePairStatus(address base, IPairsManager.PairStatus status) internal {
        Pair storage pair = pairsManagerStorage().pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");
        require(pair.status != status, "LibPairsManager: No change in status, no modification required");
        IPairsManager.PairStatus oldStatus = pair.status;
        pair.status = status;
        emit UpdatePairStatus(base, oldStatus, status);
    }

    function updatePairSlippage(address base, uint16 slippageConfigIndex) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");
        SlippageConfig memory config = pms.slippageConfigs[slippageConfigIndex];
        require(config.enable, "LibPairsManager: Slippage configuration is not available");

        uint16 oldSlippageConfigIndex = pair.slippageConfigIndex;
        address[] storage oldSlippagePairs = pms.slippageConfigPairs[oldSlippageConfigIndex];
        uint lastPositionSlippage = oldSlippagePairs.length - 1;
        uint oldSlippagePosition = pair.slippagePosition;
        if (oldSlippagePosition != lastPositionSlippage) {
            oldSlippagePairs[oldSlippagePosition] = oldSlippagePairs[lastPositionSlippage];
        }
        oldSlippagePairs.pop();

        pair.slippageConfigIndex = slippageConfigIndex;
        address[] storage slippagePairs = pms.slippageConfigPairs[slippageConfigIndex];
        pair.slippagePosition = uint16(slippagePairs.length);
        slippagePairs.push(base);
        emit UpdatePairSlippage(base, oldSlippageConfigIndex, slippageConfigIndex);
    }

    function updatePairFee(address base, uint16 feeConfigIndex) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");
        (LibFeeManager.FeeConfig memory feeConfig, address[] storage feePairs) = LibFeeManager.getFeeConfigByIndex(feeConfigIndex);
        require(feeConfig.enable, "LibPairsManager: Fee configuration is not available");

        uint16 oldFeeConfigIndex = pair.feeConfigIndex;
        (, address[] storage oldFeePairs) = LibFeeManager.getFeeConfigByIndex(oldFeeConfigIndex);
        uint lastPositionFee = oldFeePairs.length - 1;
        uint oldFeePosition = pair.feePosition;
        if (oldFeePosition != lastPositionFee) {
            oldFeePairs[oldFeePosition] = oldFeePairs[lastPositionFee];
        }
        oldFeePairs.pop();

        pair.feeConfigIndex = feeConfigIndex;
        pair.feePosition = uint16(feePairs.length);
        feePairs.push(base);
        emit UpdatePairFee(base, oldFeeConfigIndex, feeConfigIndex);
    }

    function updatePairLeverageMargin(address base, LeverageMargin[] memory leverageMargins) internal {
        PairsManagerStorage storage pms = pairsManagerStorage();
        Pair storage pair = pms.pairs[base];
        require(pair.base != address(0), "LibPairsManager: Pair does not exist");

        LeverageMargin[] memory oldLeverageMargins = new LeverageMargin[](pair.maxTier);
        uint maxTier = pair.maxTier > leverageMargins.length ? pair.maxTier : leverageMargins.length;
        for (UC i = ONE; i <= uc(maxTier); i = i + ONE) {
            if (i <= uc(pair.maxTier)) {
                oldLeverageMargins[uint16(i.into() - 1)] = pair.leverageMargins[uint16(i.into())];
            }
            if (i <= uc(leverageMargins.length)) {
                pair.leverageMargins[uint16(i.into())] = leverageMargins[uint16(i.into() - 1)];
            } else {
                delete pair.leverageMargins[uint16(i.into())];
            }
        }
        pair.maxTier = uint16(leverageMargins.length);
        emit UpdatePairLeverageMargin(base, oldLeverageMargins, leverageMargins);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./LibVault.sol";
import "../../utils/Constants.sol";
import "../interfaces/IFeeManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library LibFeeManager {

    using SafeERC20 for IERC20;

    // todo: 后面改回 apollox.fee.manager.storage
    bytes32 constant FEE_MANAGER_STORAGE_POSITION = keccak256("apollox.fee.manager.storage.20230306");

    struct FeeConfig {
        string name;
        uint16 index;
        uint16 openFeeP;     //  %
        uint16 closeFeeP;    //  %
        bool enable;
    }

    struct FeeSummary {
        // total accumulated fees, include DAO/referral fee
        uint256 total;
        // accumulated DAO repurchase funds
        uint256 totalDao;
    }

    struct FeeManagerStorage {
        // 0/1/2/3/.../ => FeeConfig
        mapping(uint16 => FeeConfig) feeConfigs;
        // feeConfig index => pair.base[]
        mapping(uint16 => address[]) feeConfigPairs;
        // USDT/BUSD/.../ => FeeSummary
        mapping(address => FeeSummary) feeSummaries;
        address daoRepurchase;
        uint16 daoShareP;       // %
    }

    function feeManagerStorage() internal pure returns (FeeManagerStorage storage fms) {
        bytes32 position = FEE_MANAGER_STORAGE_POSITION;
        assembly {
            fms.slot := position
        }
    }

    event AddFeeConfig(uint16 indexed index, uint16 openFeeP, uint16 closeFeeP, string name);
    event RemoveFeeConfig(uint16 indexed index);
    event UpdateFeeConfig(uint16 indexed index,
        uint16 oldOpenFeeP, uint16 oldCloseFeeP,
        uint16 openFeeP, uint16 closeFeeP
    );
    event SetDaoRepurchase(address indexed oldDaoRepurchase, address daoRepurchase);
    event SetDaoShareP(uint16 oldDaoShareP, uint16 daoShareP);
    event ChargeOpenTradeFee(
        address indexed user, bytes32 indexed tradeHash,
        address indexed token, uint256 openFee, uint256 daoRepurchase
    );
    event OpenTradeAddLiquidity(
        address indexed user, bytes32 indexed tradeHash,
        address indexed token, uint256 amount
    );

    function initialize(address daoRepurchase, uint16 daoShareP) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        require(fms.daoRepurchase == address(0), "LibFeeManager: Already initialized");
        setDaoRepurchase(daoRepurchase);
        setDaoShareP(daoShareP);
        // default fee config
        fms.feeConfigs[0] = FeeConfig("Default Fee Rate", 0, 8, 8, true);
        emit AddFeeConfig(0, 8, 8, "Default Fee Rate");
    }

    function addFeeConfig(uint16 index, string calldata name, uint16 openFeeP, uint16 closeFeeP) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        FeeConfig storage config = fms.feeConfigs[index];
        require(!config.enable, "LibFeeManager: Configuration already exists");
        config.index = index;
        config.name = name;
        config.openFeeP = openFeeP;
        config.closeFeeP = closeFeeP;
        config.enable = true;
        emit AddFeeConfig(index, openFeeP, closeFeeP, name);
    }

    function removeFeeConfig(uint16 index) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        FeeConfig storage config = fms.feeConfigs[index];
        require(config.enable, "LibFeeManager: Configuration not enabled");
        require(fms.feeConfigPairs[index].length == 0, "LibFeeManager: Cannot remove a configuration that is still in use");
        delete fms.feeConfigs[index];
        emit RemoveFeeConfig(index);
    }

    function updateFeeConfig(uint16 index, uint16 openFeeP, uint16 closeFeeP) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        FeeConfig storage config = fms.feeConfigs[index];
        require(config.enable, "LibFeeManager: Configuration not enabled");
        (uint16 oldOpenFeeP, uint16 oldCloseFeeP) = (config.openFeeP, config.closeFeeP);
        config.openFeeP = openFeeP;
        config.closeFeeP = closeFeeP;
        emit UpdateFeeConfig(index, oldOpenFeeP, oldCloseFeeP, openFeeP, closeFeeP);
    }

    function getFeeConfigByIndex(uint16 index) internal view returns (FeeConfig memory, address[] storage) {
        FeeManagerStorage storage fms = feeManagerStorage();
        return (fms.feeConfigs[index], fms.feeConfigPairs[index]);
    }

    function setDaoRepurchase(address daoRepurchase) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        address oldDaoRepurchase = fms.daoRepurchase;
        fms.daoRepurchase = daoRepurchase;
        emit SetDaoRepurchase(oldDaoRepurchase, daoRepurchase);
    }

    function setDaoShareP(uint16 daoShareP) internal {
        FeeManagerStorage storage fms = feeManagerStorage();
        require(daoShareP <= Constants.BASIS_POINTS_DIVISOR, "LibFeeManager: Invalid allocation ratio");
        uint16 oldDaoShareP = fms.daoShareP;
        fms.daoShareP = daoShareP;
        emit SetDaoShareP(oldDaoShareP, daoShareP);
    }

    function chargeOpenTradeFee(
        address user, bytes32 tradeHash, uint96 notionalUsd, address token,
        uint256 tokenPrice, FeeConfig memory feeConfig
    ) internal returns (uint96 openFee) {
        uint256 openFeeUsd = notionalUsd * feeConfig.openFeeP / Constants.BASIS_POINTS_DIVISOR;
        uint8 tokenDecimals = LibVault.vaultStorage().tokens[token].decimals;
        openFee = uint96(openFeeUsd * (10 ** tokenDecimals) / (tokenPrice * (10 ** (Constants.USD_DECIMALS - Constants.PRICE_DECIMALS))));
        if (openFee == 0) {
            return openFee;
        }
        FeeManagerStorage storage fms = feeManagerStorage();
        uint256 daoRepurchase = openFee * fms.daoShareP / Constants.BASIS_POINTS_DIVISOR;
        IERC20(token).safeTransfer(fms.daoRepurchase, daoRepurchase);
        FeeSummary storage feeSummary = fms.feeSummaries[token];
        feeSummary.total += openFee;
        feeSummary.totalDao += daoRepurchase;
        emit ChargeOpenTradeFee(user, tradeHash, token, openFee, daoRepurchase);

        LibVault.deposit(token, openFee - daoRepurchase);
        emit OpenTradeAddLiquidity(user, tradeHash, token, openFee - daoRepurchase);
        return openFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library LibChainlinkPrice {

    bytes32 constant CHAINLINK_PRICE_POSITION = keccak256("apollox.chainlink.price.storage");

    struct PriceFeed {
        address tokenAddress;
        address feedAddress;
        uint32 tokenAddressPosition;
    }

    struct ChainlinkPriceStorage {
        mapping(address => PriceFeed) priceFeeds;
        address[] tokenAddresses;
    }

    function chainlinkPriceStorage() internal pure returns (ChainlinkPriceStorage storage cps) {
        bytes32 position = CHAINLINK_PRICE_POSITION;
        assembly {
            cps.slot := position
        }
    }

    event SupportChainlinkPriceFeed(address indexed token, address indexed priceFeed, bool supported);

    function addChainlinkPriceFeed(address tokenAddress, address priceFeed) internal {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        PriceFeed storage pf = cps.priceFeeds[tokenAddress];
        require(pf.feedAddress == address(0), "LibChainlinkPrice: Can't add price feed that already exists");
        pf.tokenAddress = tokenAddress;
        pf.feedAddress = priceFeed;
        pf.tokenAddressPosition = uint32(cps.tokenAddresses.length);

        cps.tokenAddresses.push(tokenAddress);
        emit SupportChainlinkPriceFeed(tokenAddress, priceFeed, true);
    }

    function removeChainlinkPriceFeed(address tokenAddress) internal {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        PriceFeed storage pf = cps.priceFeeds[tokenAddress];
        address priceFeed = pf.feedAddress;
        require(pf.feedAddress != address(0), "LibChainlinkPrice: Price feed does not exist");

        uint256 lastPosition = cps.tokenAddresses.length - 1;
        uint256 tokenAddressPosition = pf.tokenAddressPosition;
        if (tokenAddressPosition != lastPosition) {
            address lastTokenAddress = cps.tokenAddresses[lastPosition];
            cps.tokenAddresses[tokenAddressPosition] = lastTokenAddress;
            cps.priceFeeds[lastTokenAddress].tokenAddressPosition = uint32(tokenAddressPosition);
        }
        cps.tokenAddresses.pop();
        delete cps.priceFeeds[tokenAddress];
        emit SupportChainlinkPriceFeed(tokenAddress, priceFeed, false);
    }

    function getPriceFromChainlink(address token) internal view returns (uint256 price, uint8 decimals, uint256 startedAt) {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        address priceFeed = cps.priceFeeds[token].feedAddress;
        require(priceFeed != address(0), "LibChainlinkPrice: Price feed does not exist");
        AggregatorV3Interface oracle = AggregatorV3Interface(priceFeed);
        (, int256 price_, uint256 startedAt_,,) = oracle.latestRoundData();
        price = uint256(price_);
        decimals = oracle.decimals();
        return (price, decimals, startedAt_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ITradingPortal.sol";

interface IVault {

    event CloseTradeRemoveLiquidity(address indexed token, uint256 amount);

    struct Token {
        address tokenAddress;
        uint16 weight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        bool stable;
        bool dynamicFee;
        bool asMargin;
    }

    struct LpItem {
        address tokenAddress;
        int256 value;
        uint8 decimals;
        int256 valueUsd; // decimals = 18
        uint16 targetWeight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        bool dynamicFee;
    }

    struct MarginToken {
        address token;
        bool asMargin;
        uint8 decimals;
        uint256 price;
    }

    function addToken(
        address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints,
        bool stable, bool dynamicFee, bool asMargin, uint16[] memory weights
    ) external;

    function removeToken(address tokenAddress, uint16[] memory weights) external;

    function updateToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee) external;

    function updateAsMagin(address tokenAddress, bool asMagin) external;

    function changeWeight(uint16[] memory weights) external;

    function tokensV2() external view returns (Token[] memory);

    function getTokenByAddress(address tokenAddress) external view returns (Token memory);

    function getTokenForTrading(address tokenAddress) external view returns (MarginToken memory);

    function itemValue(address token) external view returns (LpItem memory lpItem);

    function totalValue() external view returns (LpItem[] memory lpItems);

    function increaseByCloseTrade(address tokens, uint256 amounts) external;

    function decreaseByCloseTrade(address token, uint256 amount) external returns (ITrading.CloseSettleToken[] memory);

    //    function transferToExchangeTreasury(address[] calldata tokens, uint256[] calldata amounts) external;
    //
    //    function transferToExchangeTreasuryBNB(uint256 amount) external;
    //
    //    function receiveFromExchangeTreasury(bytes[] calldata messages, bytes[] calldata signatures) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ITrading.sol";
import "./ITradingChecker.sol";

interface ITradingTrigger is ITrading {

    event PendingTradeRefund(address indexed user, bytes32 indexed tradeHash, ITradingChecker.Refund refund);
    event OpenMarketTrade(address indexed user, bytes32 indexed tradeHash, OpenTrade ot);
    event CloseTradeSuccessful(address indexed user, bytes32 indexed tradeHash);

    struct LimitOrder {
        bytes32 orderHash;
        address user;
        uint64 entryPrice;
        address pairBase;
        address tokenIn;
        uint96 margin;
        uint64 stopLoss;
        uint64 takeProfit;
        uint24 broker;
        bool isLong;
        uint96 openFee;
        uint96 executionFee;
        uint80 qty;
    }

    enum ExecutionType {TP_SL, LIQ}
    struct TpSlOrLiq {
        bytes32 tradeHash;
        uint64 price;
        ExecutionType executionType;
    }

    function limitOrderDeal(LimitOrder memory) external;

    function marketTradeCallback(bytes32 tradeHash, uint upperPrice, uint lowerPrice) external;

    function closeTradeCallback(bytes32 tradeHash, uint upperPrice, uint lowerPrice) external;

    function executeTpSlOrLiq(TpSlOrLiq[] memory) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBook.sol";
import "./ITradingCore.sol";
import "../libraries/LibTrading.sol";

interface ITradingReader is IBook {

    struct MarketInfo {
        address pairBase;
        uint256 longQty;              // 1e10
        uint256 shortQty;             // 1e10
        uint64 lpAveragePrice;        // 1e8
        int256 fundingFeeRate;        // 1e18
    }

    struct PendingTrade {
        address user;
        uint24 broker;
        bool isLong;
        uint64 price;      // 1e8
        address pairBase;
        uint96 amountIn;   // tokenIn decimals
        address tokenIn;
        uint80 qty;        // 1e10
        uint64 stopLoss;   // 1e8
        uint64 takeProfit; // 1e8
    }

    struct Position {
        bytes32 positionHash;
        // BTC/USD
        string pair;
        // pair.base
        address pairBase;
        address marginToken;
        bool isLong;
        uint96 margin;       // marginToken decimals
        uint80 qty;          // 1e10
        uint64 entryPrice;   // 1e8
        uint64 stopLoss;     // 1e8
        uint64 takeProfit;   // 1e8
        uint96 openFee;      // marginToken decimals
        uint96 executionFee; // marginToken decimals
        int256 fundingFee;   // marginToken decimals
        uint40 timestamp;
    }
    enum AssetPurpose {
        LIMIT, PENDING, POSITION
    }
    struct TraderAsset {
        AssetPurpose purpose;
        address token;
        uint256 value;
    }

    function getPairQty(address pairBase) external view returns (ITradingCore.PairQty memory);

    function getMarketInfo(address pairBase) external view returns (MarketInfo memory);

    function getMarketInfos(address[] calldata pairBases) external view returns (MarketInfo[] memory);

    function getPendingTrade(bytes32 tradeHash) external view returns (PendingTrade memory);

    function getPositionByHash(bytes32 tradeHash) external view returns (Position memory);

    function getPositions(address user, address pairBase) external view returns (Position[] memory);

    function traderAssets(address[] memory tokens) external view returns (TraderAsset[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBook.sol";
import "./ITradingChecker.sol";
import "./ITradingPortal.sol";
import "./ITrading.sol";

interface ITradingPortal is ITrading, IBook {

    event FundingFeeAddLiquidity(address indexed token, uint256 amount);
    event MarketPendingTrade(address indexed user, bytes32 indexed tradeHash, IBook.OpenDataInput trade);
    event UpdateTradeTp(address indexed user, bytes32 indexed tradeHash, uint256 oldTp, uint256 tp);
    event UpdateTradeSl(address indexed user, bytes32 indexed tradeHash, uint256 oldSl, uint256 sl);
    event CloseTradeReceived(address indexed user, bytes32 indexed tradeHash, address indexed token, uint256 amount);
    event CloseTradeAddLiquidity(address indexed token, uint256 amount);

    function openMarketTrade(OpenDataInput calldata openData) external;

    function updateTradeTp(bytes32 tradeHash, uint64 takeProfit) external;

    function updateTradeSl(bytes32 tradeHash, uint64 stopLoss) external;

    // stopLoss is allowed to be equal to 0, which means the sl setting is removed.
    // takeProfit must be greater than 0
    function updateTradeTpAndSl(bytes32 tradeHash, uint64 takeProfit, uint64 stopLoss) external;

    function settleLpFundingFee(uint256 lpReceiveFundingFeeUsd) external;

    function closeTrade(bytes32 tradeHash) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IPairsManager.sol";

interface ITradingCore {

    event FundingFeeAddLiquidity(address indexed token, uint256 amount);

    struct PairQty {
        uint256 longQty;
        uint256 shortQty;
    }

    struct PairPositionInfo {
        uint256 lastFundingFeeBlock;
        uint256 longQty;                // 1e10
        uint256 shortQty;               // 1e10
        // shortAcc = longAcc * -1
        int256 longAccFundingFeePerShare;  // 1e18
        uint64 lpAveragePrice;          // 1e8
    }

    function slippagePrice(address pairBase, uint marketPrice, uint qty, bool isLong) external view returns (uint);

    function slippagePrice(
        PairQty memory pairQty,
        IPairsManager.SlippageConfig memory sc,
        uint marketPrice, uint qty, bool isLong
    ) external pure returns (uint);

    function lastLongAccFundingFeePerShare(address pairBase) external view returns (int256);

    function updatePairPositionInfo(
        address pairBase, uint marketPrice, uint qty, bool isLong, bool isOpen
    ) external returns (int256 longAccFundingFeePerShare);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITradingConfig {
    /*
    |-----------> 8 bit <-----------|
    |---|---|---|---|---|---|---|---|
    |   |   | 5 | 4 | 3 | 2 | 1 | 0 |
    |---|---|---|---|---|---|---|---|
    */
    enum TradingSwitch {
        LIMIT_ORDER,
        EXECUTE_LIMIT_ORDER,
        MARKET_TRADING,
        USER_CLOSE_TRADING,
        TP_SL_CLOSE_TRADING,
        LIQUIDATE_TRADING
    }

    struct TradingConfig {
        uint256 executionFeeUsd;
        uint256 minNotionalUsd;
        uint24 maxTakeProfitP;
        bool limitOrder;
        bool executeLimitOrder;
        bool marketTrading;
        bool userCloseTrading;
        bool tpSlCloseTrading;
        bool liquidateTrading;
    }

    function getTradingConfig() external view returns (TradingConfig memory);

    function setTradingSwitches(
        bool limitOrder, bool executeLimitOrder, bool marketTrade,
        bool userCloseTrade, bool tpSlCloseTrade, bool liquidateTrade
    ) external;

    function setExecutionFeeUsd(uint256 executionFeeUsd) external;

    function setMinNotionalUsd(uint256 minNotionalUsd) external;

    function setMaxTakeProfitP(uint24 maxTakeProfitP) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBook.sol";
import "./IPairsManager.sol";
import "./ILimitOrder.sol";
import "./ITradingReader.sol";

interface ITradingChecker {

    enum Refund {
        NO, PAIR_STATUS, AMOUNT_IN, USER_PRICE, MIN_NOTIONAL_USD, MAX_NOTIONAL_USD,
        MAX_LEVERAGE, TP, SL, PAIR_OI, OPEN_LOST
    }

    function checkTp(
        bool isLong, uint takeProfit, uint entryPrice, uint leverage_10000, uint maxTakeProfitP
    ) external pure returns (bool);

    function checkSl(bool isLong, uint stopLoss, uint entryPrice) external pure returns (bool);

    function checkLimitOrderTp(ILimitOrder.LimitOrder memory order) external view;

    function openLimitOrderCheck(IBook.OpenDataInput calldata data) external view;

    function executeLimitOrderCheck(
        ILimitOrder.LimitOrder memory order, uint256 marketPrice
    ) external view returns (bool result, Refund refund);

    function checkMarketTradeTp(ITrading.OpenTrade memory) external view;

    function openMarketTradeCheck(IBook.OpenDataInput calldata data) external view;

    function marketTradeCallbackCheck(
        ITradingReader.PendingTrade memory pt, uint256 marketPrice
    ) external view returns (bool result, uint256 entryPrice, Refund refund);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITrading {

    struct OpenTrade {
        address user;
        uint32 userOpenTradeIndex;
        uint64 entryPrice;     // 1e8
        address pairBase;
        address tokenIn;
        uint96 margin;         // tokenIn decimals
        uint64 stopLoss;       // 1e8
        uint64 takeProfit;     // 1e8
        uint24 broker;
        bool isLong;
        uint96 openFee;        // tokenIn decimals
        int256 longAccFundingFeePerShare; // 1e18
        uint96 executionFee;   // tokenIn decimals
        uint40 timestamp;
        uint80 qty;            // 1e10
    }

    struct MarginBalance {
        address token;
        uint256 price;
        uint8 decimals;
        uint256 balanceUsd;
    }

    struct CloseSettleToken {
        address token;
        uint256 amount;
        uint8 decimals;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPriceFacade {

    struct Config {
        uint16 lowPriceGapP;
        uint16 highPriceGapP;
        uint16 maxPriceDelay;
    }

    function setLowAndHighPriceGapP(uint16 lowPriceGapP, uint16 highPriceGapP) external;

    function setMaxPriceDelay(uint16 maxPriceDelay) external;

    function getPriceFacadeConfig() external view returns (Config memory);

    function getPrice(address token) external view returns (uint256);

    function getPriceFromCacheOrOracle(address token) external view returns (uint64 price, uint40 updatedAt);

    function requestPrice(bytes32 tradeHash, address token, bool isOpen) external;

    function requestPriceCallback(bytes32 requestId, uint64 price) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IFeeManager.sol";
import "../libraries/LibPairsManager.sol";

interface IPairsManager {
    enum PairType{CRYPTO, STOCKS, FOREX, INDICES}
    enum PairStatus{AVAILABLE, REDUCE_ONLY, CLOSE}
    enum SlippageType{FIXED, ONE_PERCENT_DEPTH}

    struct PairSimple {
        // BTC/USD
        string name;
        // BTC address
        address base;
        PairType pairType;
        PairStatus status;
    }

    struct PairView {
        // BTC/USD
        string name;
        // BTC address
        address base;
        uint16 basePosition;
        PairType pairType;
        PairStatus status;
        uint256 maxLongOiUsd;
        uint256 maxShortOiUsd;
        uint256 fundingFeePerBlockP;  // 1e18
        uint256 minFundingFeeR;       // 1e18
        uint256 maxFundingFeeR;       // 1e18

        LibPairsManager.LeverageMargin[] leverageMargins;

        uint16 slippageConfigIndex;
        uint16 slippagePosition;
        LibPairsManager.SlippageConfig slippageConfig;

        uint16 feeConfigIndex;
        uint16 feePosition;
        LibFeeManager.FeeConfig feeConfig;
    }

    struct PairMaxOiAndFundingFeeConfig {
        uint256 maxLongOiUsd;
        uint256 maxShortOiUsd;
        uint256 fundingFeePerBlockP;
        uint256 minFundingFeeR;
        uint256 maxFundingFeeR;
    }

    struct LeverageMargin {
        uint256 notionalUsd;
        uint16 maxLeverage;
        uint16 initialLostP; // %
        uint16 liqLostP;     // %
    }

    struct SlippageConfig {
        uint256 onePercentDepthAboveUsd;
        uint256 onePercentDepthBelowUsd;
        uint16 slippageLongP;       // %
        uint16 slippageShortP;      // %
        SlippageType slippageType;
    }

    struct FeeConfig {
        uint16 openFeeP;     //  %
        uint16 closeFeeP;    //  %
    }

    struct TradingPair {
        // BTC address
        address base;
        string name;
        PairType pairType;
        PairStatus status;
        PairMaxOiAndFundingFeeConfig pairConfig;
        LeverageMargin[] leverageMargins;
        SlippageConfig slippageConfig;
        FeeConfig feeConfig;
    }

    function addSlippageConfig(
        string calldata name, uint16 index, SlippageType slippageType,
        uint256 onePercentDepthAboveUsd, uint256 onePercentDepthBelowUsd,
        uint16 slippageLongP, uint16 slippageShortP
    ) external;

    function removeSlippageConfig(uint16 index) external;

    function updateSlippageConfig(
        uint16 index, SlippageType slippageType,
        uint256 onePercentDepthAboveUsd, uint256 onePercentDepthBelowUsd,
        uint16 slippageLongP, uint16 slippageShortP
    ) external;

    function getSlippageConfigByIndex(uint16 index) external view returns (LibPairsManager.SlippageConfig memory, PairSimple[] memory);

    function addPair(
        address base, string calldata name,
        PairType pairType, PairStatus status,
        PairMaxOiAndFundingFeeConfig memory pairConfig,
        uint16 slippageConfigIndex, uint16 feeConfigIndex,
        LibPairsManager.LeverageMargin[] memory leverageMargins
    ) external;

    function updatePairMaxOi(address base, uint256 maxLongOiUsd, uint256 maxShortOiUsd) external;

    function updatePairFundingFeeConfig(
        address base, uint256 fundingFeePerBlockP, uint256 minFundingFeeR, uint256 maxFundingFeeR
    ) external;

    function removePair(address base) external;

    function updatePairStatus(address base, PairStatus status) external;

    function updatePairSlippage(address base, uint16 slippageConfigIndex) external;

    function updatePairFee(address base, uint16 feeConfigIndex) external;

    function updatePairLeverageMargin(address base, LibPairsManager.LeverageMargin[] memory leverageMargins) external;

    function pairs() external view returns (PairView[] memory);

    function getPairByBase(address base) external view returns (PairView memory);

    function getPairForTrading(address base) external view returns (TradingPair memory);

    function getPairConfig(address base) external view returns (PairMaxOiAndFundingFeeConfig memory);

    function getPairFeeConfig(address base) external view returns (FeeConfig memory);

    function getPairSlippageConfig(address base) external view returns (SlippageConfig memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBook.sol";
import "./ITradingChecker.sol";

interface ILimitOrder is IBook {

    event OpenLimitOrder(address indexed user, bytes32 indexed orderHash, OpenDataInput data);
    event UpdateOrderTp(address indexed user, bytes32 indexed tradeHash, uint256 oldTp, uint256 tp);
    event UpdateOrderSl(address indexed user, bytes32 indexed tradeHash, uint256 oldSl, uint256 sl);
    event ExecuteLimitOrderRejected(address indexed user, bytes32 indexed tradeHash, ITradingChecker.Refund refund);
    event LimitOrderRefund(address indexed user, bytes32 indexed tradeHash, ITradingChecker.Refund refund);
    event CancelLimitOrder(address indexed user, bytes32 indexed orderHash);

    struct LimitOrderView {
        bytes32 orderHash;
        string pair;
        address pairBase;
        bool isLong;
        address tokenIn;
        uint96 amountIn;    // tokenIn decimals
        uint80 qty;         // 1e10
        uint64 limitPrice;  // 1e8
        uint64 stopLoss;    // 1e8
        uint64 takeProfit;  // 1e8
        uint24 broker;
        uint40 timestamp;
    }

    struct LimitOrder {
        address user;
        uint32 userOpenOrderIndex;
        uint64 limitPrice;   // 1e8
        // pair.base
        address pairBase;
        uint96 amountIn;     // tokenIn decimals
        address tokenIn;
        bool isLong;
        uint24 broker;
        uint64 stopLoss;     // 1e8
        uint80 qty;          // 1e10
        uint64 takeProfit;   // 1e8
        uint40 timestamp;
    }

    function openLimitOrder(OpenDataInput calldata openData) external;

    function updateOrderTp(bytes32 orderHash, uint64 takeProfit) external;

    function updateOrderSl(bytes32 orderHash, uint64 stopLoss) external;

    // stopLoss is allowed to be equal to 0, which means the sl setting is removed.
    // takeProfit must be greater than 0
    function updateOrderTpAndSl(bytes32 orderHash, uint64 takeProfit, uint64 stopLoss) external;

    function executeLimitOrder(KeeperExecution[] memory) external;

    function cancelLimitOrder(bytes32 orderHash) external;

    function getLimitOrderByHash(bytes32 orderHash) external view returns (LimitOrderView memory);

    function getLimitOrders(address user, address pairBase) external view returns (LimitOrderView[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/LibFeeManager.sol";
import "./IPairsManager.sol";

interface IFeeManager {

    struct FeeSummaryView {
        address token;
        // total accumulated fees
        uint256 total;
        // accumulated DAO repurchase funds
        uint256 totalDao;
    }

    struct FeeAllocationInfo {
        address daoRepurchase;
        uint16 daoShareP;       // %
    }

    function addFeeConfig(uint16 index, string calldata name, uint16 openFeeP, uint16 closeFeeP) external;

    function removeFeeConfig(uint16 index) external;

    function updateFeeConfig(uint16 index, uint16 openFeeP, uint16 closeFeeP) external;

    function getFeeConfigByIndex(uint16 index) external view returns (LibFeeManager.FeeConfig memory, IPairsManager.PairSimple[] memory);

    function feeSummary(address token) external view returns (FeeSummaryView memory);

    function feeAllocationInfo() external view returns (FeeAllocationInfo memory);

    function setDaoRepurchase(address daoRepurchase) external;

    function setDaoShareP(uint16 daoShareP) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IBook {

    struct OpenDataInput {
        // Pair.base
        address pairBase;
        bool isLong;
        // BUSD/USDT address
        address tokenIn;
        uint96 amountIn;   // tokenIn decimals
        uint80 qty;        // 1e10
        // Limit Order: limit price
        // Market Trade: worst price acceptable
        uint64 price;      // 1e8
        uint64 stopLoss;   // 1e8
        uint64 takeProfit; // 1e8
        uint24 broker;
    }

    struct KeeperExecution {
        bytes32 hash;
        uint64 price;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IWBNB {
    function deposit() external payable;

    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
interface IERC20Permit {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}