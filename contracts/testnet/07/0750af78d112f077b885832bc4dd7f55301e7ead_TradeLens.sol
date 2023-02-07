// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

struct LeverageOrderForLens {
    uint256 id;
    address indexToken;
    address collateralToken;
    uint8 side;
    uint8 updateType;
    uint256 triggerPrice;
    uint256 size;
    uint256 collateral;
    bool triggerAboveThreshold;
}

struct SwapOrderForLens {
    uint256 id;
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint256 minAmountOut;
    uint256 price;
}

interface IOrderManagerForTradeLens {
    struct Order {
        address pool;
        address owner;
        address indexToken;
        address collateralToken;
        address payToken;
        uint256 expiresAt;
        uint256 submissionBlock;
        uint256 price;
        uint256 executionFee;
        bool triggerAboveThreshold;
    }

    struct Request {
        uint8 side;
        uint256 sizeChange;
        uint256 collateral;
        uint8 updateType;
    }

    struct SwapOrder {
        address pool;
        address owner;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 price;
        uint256 executionFee;
    }

    function getOrders(address user, uint256 skip, uint256 take)
        external
        view
        returns (uint256[] memory orderIds, uint256 total);
    function getSwapOrders(address user, uint256 skip, uint256 take)
        external
        view
        returns (uint256[] memory orderIds, uint256 total);
    function userOrders(address, uint256) external view returns (uint256);
    function userSwapOrders(address, uint256) external view returns (uint256);
    function orders(uint256) external view returns (Order memory);
    function requests(uint256) external view returns (Request memory);
    function swapOrders(uint256) external view returns (SwapOrder memory);
}

contract TradeLens {
    function getLeverageOrders(address _orderbook, address _owner, bool _isMarket, uint256 _skip, uint256 _take)
        external
        view
        returns (LeverageOrderForLens[] memory, uint256)
    {
        IOrderManagerForTradeLens orderManager = IOrderManagerForTradeLens(_orderbook);
        (, uint256 totalOrder) = orderManager.getOrders(_owner, 0, 0);

        uint256[] memory orderIds = new uint256[](totalOrder);
        uint256 totalPending = 0;
        uint256 totalTaken = 0;
        for (uint256 i = 0; i < totalOrder; i++) {
            uint256 orderId = orderManager.userOrders(_owner, i);
            IOrderManagerForTradeLens.Order memory order = orderManager.orders(orderId);
            if (order.owner == address(0)) {
                continue;
            }
            bool validType = _isMarket ? order.expiresAt > block.timestamp : order.expiresAt == 0;
            if (!validType) {
                continue;
            }
            totalPending++;
            if (_skip >= totalPending || _skip + _take < totalPending) {
                continue;
            }
            orderIds[totalTaken++] = orderId;
        }

        LeverageOrderForLens[] memory pendingOrders = new LeverageOrderForLens[](totalTaken);
        for (uint256 i = 0; i < totalTaken; i++) {
            uint256 id = orderIds[i];
            IOrderManagerForTradeLens.Order memory order = orderManager.orders(id);
            IOrderManagerForTradeLens.Request memory request = orderManager.requests(id);

            LeverageOrderForLens memory leverageOrder;
            leverageOrder.id = id;
            leverageOrder.indexToken = order.indexToken;
            leverageOrder.collateralToken = order.collateralToken;
            leverageOrder.triggerPrice = order.price;
            leverageOrder.triggerAboveThreshold = order.triggerAboveThreshold;

            leverageOrder.side = request.side;
            leverageOrder.updateType = request.updateType;
            leverageOrder.size = request.sizeChange;
            leverageOrder.collateral = request.collateral;
            pendingOrders[i] = leverageOrder;
        }
        return (pendingOrders, totalPending);
    }

    function getSwapOrders(address _orderbook, address _owner, uint256 _skip, uint256 _take)
        external
        view
        returns (SwapOrderForLens[] memory, uint256)
    {
        IOrderManagerForTradeLens orderManager = IOrderManagerForTradeLens(_orderbook);
        (, uint256 totalOrder) = orderManager.getSwapOrders(_owner, 0, 0);

        uint256[] memory orderIds = new uint256[](totalOrder);
        uint256 totalPending = 0;
        uint256 totalTaken = 0;
        for (uint256 i = 0; i < totalOrder; i++) {
            uint256 orderId = orderManager.userSwapOrders(_owner, i);
            IOrderManagerForTradeLens.SwapOrder memory order = orderManager.swapOrders(orderId);
            if (order.owner == address(0)) {
                continue;
            }
            totalPending++;
            if (_skip >= totalPending || _skip + _take < totalPending) {
                continue;
            }
            orderIds[totalTaken++] = orderId;
        }

        SwapOrderForLens[] memory pendingOrders = new SwapOrderForLens[](totalTaken);
        for (uint256 i = 0; i < totalTaken; i++) {
            uint256 id = orderIds[i];
            IOrderManagerForTradeLens.SwapOrder memory order = orderManager.swapOrders(id);

            SwapOrderForLens memory swapOrder;
            swapOrder.id = id;
            swapOrder.tokenIn = order.tokenIn;
            swapOrder.tokenOut = order.tokenOut;
            swapOrder.amountIn = order.amountIn;
            swapOrder.minAmountOut = order.minAmountOut;
            swapOrder.price = order.price;
            pendingOrders[i] = swapOrder;
        }
        return (pendingOrders, totalPending);
    }
}