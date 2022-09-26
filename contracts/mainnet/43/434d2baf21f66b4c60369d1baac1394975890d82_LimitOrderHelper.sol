// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.15;

import "../interfaces/DexAggregatorInterface.sol";
import "../interfaces/OpenLevInterface.sol";
import "../IOPLimitOrder.sol";

contract LimitOrderHelper {
    constructor ()
    {
    }
    enum OrderStatus{
        HEALTHY, // Do nothing
        UPDATING_PRICE, // Need update price
        WAITING, // Waiting for 1 min before filling
        FILL, // Can fill
        NOP// No position
    }

    struct PriceVars {
        uint256 price;
        uint8 decimal;
    }

    struct OrderStatVars {
        uint256 remaining;
        uint256 lastUpdateTime;
        uint256 price0;
        uint8 decimal;
        OrderStatus status;
    }


    function getPrices(ILimitOrder limitOrder, address[] calldata token0s, address[] calldata token1s, bytes[] calldata dexDatas) external view returns (PriceVars[] memory results){
        DexAggregatorInterface dexAgg = limitOrder.dexAgg();
        results = new PriceVars[](token0s.length);
        for (uint i = 0; i < token0s.length; i++) {
            PriceVars memory item;
            (item.price, item.decimal) = dexAgg.getPrice(token0s[i], token1s[i], dexDatas[i]);
            results[i] = item;
        }
        return results;
    }

    function getOrderStat(ILimitOrder limitOrder, bytes32 orderId, uint16 marketId, bool longToken, bool isOpen, bool isStopLoss, uint256 price0, bytes memory dexData) external returns (OrderStatVars memory){
        OrderStatVars memory result;
        result.remaining = limitOrder.remainingRaw(orderId);
        result.status = OrderStatus.HEALTHY;
        if (result.remaining == 1) {
            result.status = OrderStatus.NOP;
            return result;
        }
        DexAggregatorInterface dexAgg = limitOrder.dexAgg();
        OpenLevInterface openLev = limitOrder.openLev();
        OpenLevInterface.Market memory market = openLev.markets(marketId);
        (
        result.price0,,,result.decimal, result.lastUpdateTime) = dexAgg.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, 60, dexData);
        if (isOpen) {
            if ((!longToken && result.price0 <= price0) || (longToken && result.price0 >= price0)) {
                result.status = OrderStatus.FILL;
            }
            return result;
        }
        if (!isStopLoss) {
            if ((!longToken && result.price0 >= price0) || (longToken && result.price0 <= price0)) {
                result.status = OrderStatus.FILL;
            }
            return result;
        }
        // stop loss
        if ((!longToken && result.price0 <= price0) || (longToken && result.price0 >= price0)) {
            openLev.updatePrice(marketId, dexData);
            (,uint cAvgPrice,uint hAvgPrice,,) = dexAgg.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, 60, dexData);
            if ((!longToken && cAvgPrice <= price0 && (hAvgPrice <= price0 || block.timestamp >= result.lastUpdateTime + 60)) || (longToken && cAvgPrice >= price0 && (hAvgPrice >= price0 || block.timestamp >= result.lastUpdateTime + 60))) {
                result.status = OrderStatus.FILL;
                return result;
            }
            if ((!longToken && (cAvgPrice >= price0 && block.timestamp >= result.lastUpdateTime + 60)) || (longToken && (cAvgPrice <= price0 && block.timestamp >= result.lastUpdateTime + 60))) {
                if (toDex(dexData) != 2) {
                    result.status = OrderStatus.UPDATING_PRICE;
                }
                // uni v3
                else {
                    result.status = OrderStatus.WAITING;
                }
                return result;
            }
            result.status = OrderStatus.WAITING;
            return result;
        }
        return result;
    }

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= 1, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, 0))))
        }
        return temp;
    }
}

interface ILimitOrder {
    function dexAgg() external view returns (DexAggregatorInterface);

    function openLev() external view returns (OpenLevInterface);

    function remainingRaw(bytes32 _orderId) external view returns (uint256);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >0.7.6;

pragma experimental ABIEncoderV2;

/**
 * @title OpenLevInterface
 * @author OpenLeverage
 */
interface OpenLevInterface {
    struct Market {
        // Market info
        address pool0; // Lending Pool 0
        address pool1; // Lending Pool 1
        address token0; // Lending Token 0
        address token1; // Lending Token 1
        uint16 marginLimit; // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate; // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint256 pool0Insurance; // Insurance balance for token 0
        uint256 pool1Insurance; // Insurance balance for token 1
    }

    struct Trade {
        // Trade storage
        uint256 deposited; // Balance of deposit token
        uint256 held; // Balance of held position
        bool depositToken; // Indicate if the deposit token is token 0 or token 1
        uint128 lastBlockNum; // Block number when the trade was touched last time, to prevent more than one operation within same block
    }

    function markets(uint16 marketId) external view returns (Market memory market);

    function activeTrades(
        address trader,
        uint16 marketId,
        bool longToken
    ) external view returns (Trade memory trade);

    function updatePrice(uint16 marketId, bytes memory dexData) external;

    function marginTradeFor(
        address trader,
        uint16 marketId,
        bool longToken,
        bool depositToken,
        uint256 deposit,
        uint256 borrow,
        uint256 minBuyAmount,
        bytes memory dexData
    ) external payable returns (uint256 newHeld);

    function closeTradeFor(
        address trader,
        uint16 marketId,
        bool longToken,
        uint256 closeHeld,
        uint256 minOrMaxAmount,
        bytes memory dexData
    ) external returns (uint256 depositReturn);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >0.7.6;
pragma experimental ABIEncoderV2;

interface DexAggregatorInterface {
    function getPrice(
        address desToken,
        address quoteToken,
        bytes memory data
    ) external view returns (uint256 price, uint8 decimals);

    function getPriceCAvgPriceHAvgPrice(
        address desToken,
        address quoteToken,
        uint32 secondsAgo,
        bytes memory dexData
    )
        external
        view
        returns (
            uint256 price,
            uint256 cAvgPrice,
            uint256 hAvgPrice,
            uint8 decimals,
            uint256 timestamp
        );

    function updatePriceOracle(
        address desToken,
        address quoteToken,
        uint32 timeWindow,
        bytes memory data
    ) external returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.15;

import "./interfaces/DexAggregatorInterface.sol";
import "./interfaces/OpenLevInterface.sol";
import "./IOPLimitOrder.sol";

abstract contract OPLimitOrderStorage {
    event OrderCanceled(address indexed trader, bytes32 orderId, uint256 remaining);

    event OrderFilled(address indexed trader, bytes32 orderId, uint256 commission, uint256 remaining, uint256 filling);

    struct Order {
        uint256 salt;
        address owner;
        uint32 deadline;
        uint16 marketId;
        bool longToken;
        bool depositToken;
        address commissionToken;
        uint256 commission;
        uint256 price0; // tokanA-tokenB pair, the price of tokenA relative to tokenB, scale 10**24.
    }

    struct OpenOrder {
        uint256 salt;
        address owner;
        uint32 deadline; // in seconds
        uint16 marketId;
        bool longToken;
        bool depositToken;
        address commissionToken;
        uint256 commission;
        uint256 price0;
        uint256 deposit; // the deposit amount for margin trade.
        uint256 borrow; // the borrow amount for margin trade.
        uint256 expectHeld; // the minimum position held after the order gets fully filled.
    }

    struct CloseOrder {
        uint256 salt;
        address owner;
        uint32 deadline;
        uint16 marketId;
        bool longToken;
        bool depositToken;
        address commissionToken;
        uint256 commission;
        uint256 price0;
        bool isStopLoss; // true = stopLoss, false = takeProfit.
        uint256 closeHeld; // how many position will be closed.
        uint256 expectReturn; // the minimum deposit returns after gets filled.
    }

    bytes32 public constant ORDER_TYPEHASH =
        keccak256(
            "Order(uint256 salt,address owner,uint32 deadline,uint16 marketId,bool longToken,bool depositToken,address commissionToken,uint256 commission,uint256 price0)"
        );
    bytes32 public constant OPEN_ORDER_TYPEHASH =
        keccak256(
            "OpenOrder(uint256 salt,address owner,uint32 deadline,uint16 marketId,bool longToken,bool depositToken,address commissionToken,uint256 commission,uint256 price0,uint256 deposit,uint256 borrow,uint256 expectHeld)"
        );
    bytes32 public constant CLOSE_ORDER_TYPEHASH =
        keccak256(
            "CloseOrder(uint256 salt,address owner,uint32 deadline,uint16 marketId,bool longToken,bool depositToken,address commissionToken,uint256 commission,uint256 price0,bool isStopLoss,uint256 closeHeld,uint256 expectReturn)"
        );

    OpenLevInterface public openLev;
    DexAggregatorInterface public dexAgg;
}

interface IOPLimitOrder {
    function fillOpenOrder(
        OPLimitOrderStorage.OpenOrder memory order,
        bytes calldata signature,
        uint256 fillingDeposit,
        bytes memory dexData
    ) external;

    function fillCloseOrder(
        OPLimitOrderStorage.CloseOrder memory order,
        bytes calldata signature,
        uint256 fillingHeld,
        bytes memory dexData
    ) external;

    function closeTradeAndCancel(
        uint16 marketId,
        bool longToken,
        uint256 closeHeld,
        uint256 minOrMaxAmount,
        bytes memory dexData,
        OPLimitOrderStorage.Order[] memory orders
    ) external;

    function cancelOrder(OPLimitOrderStorage.Order memory order) external;

    function cancelOrders(OPLimitOrderStorage.Order[] calldata orders) external;

    function remaining(bytes32 _orderId) external view returns (uint256);

    function remainingRaw(bytes32 _orderId) external view returns (uint256);

    function getOrderId(OPLimitOrderStorage.Order memory order) external view returns (bytes32);

    function hashOpenOrder(OPLimitOrderStorage.OpenOrder memory order) external view returns (bytes32);

    function hashCloseOrder(OPLimitOrderStorage.CloseOrder memory order) external view returns (bytes32);
}