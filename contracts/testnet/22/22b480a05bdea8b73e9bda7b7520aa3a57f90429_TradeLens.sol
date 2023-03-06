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
    bool expired;
    bool isMarket;
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
    function getLeverageOrderIds(IOrderManagerForTradeLens _orderbook, address _owner)
        public
        view
        returns (uint256[] memory, uint256)
    {
        (, uint256 totalOrder) = _orderbook.getOrders(_owner, 0, 0);
        uint256[] memory orderIds = new uint256[](totalOrder);
        uint256 totalPending = 0;
        for (uint256 i = totalOrder; i > 0; i--) {
            uint256 orderId = _orderbook.userOrders(_owner, i - 1);
            IOrderManagerForTradeLens.Order memory order = _orderbook.orders(orderId);
            if (order.owner == address(0)) {
                continue;
            }
            orderIds[totalPending++] = orderId;
        }
        return (orderIds, totalPending);
    }

    function getLeverageOrders(
        IOrderManagerForTradeLens _orderbook,
        address _owner,
        uint256 _skip,
        uint256 _take
    ) external view returns (LeverageOrderForLens[] memory, uint256) {
        (uint256[] memory orderIds, uint256 totalOrder) = getLeverageOrderIds(_orderbook, _owner);
        _skip = _skip < totalOrder ? _skip : totalOrder;
        _take = _skip + _take > totalOrder ? totalOrder - _skip : _take;
        LeverageOrderForLens[] memory pendingOrders = new LeverageOrderForLens[](_take);
        for (uint256 i = 0; i < _take; i++) {
            pendingOrders[i] = _parseLeverageOrder(_orderbook, orderIds[_skip + i]);
        }
        return (pendingOrders, totalOrder);
    }

    function getAllLeverageOrders(IOrderManagerForTradeLens _orderbook, address _owner)
        external
        view
        returns (LeverageOrderForLens[] memory, uint256)
    {
        (uint256[] memory orderIds, uint256 totalOrder) = getLeverageOrderIds(_orderbook, _owner);
        LeverageOrderForLens[] memory pendingOrders = new LeverageOrderForLens[](totalOrder);
        for (uint256 i = 0; i < totalOrder; i++) {
            pendingOrders[i] = _parseLeverageOrder(_orderbook, orderIds[i]);
        }
        return (pendingOrders, totalOrder);
    }

    function getSwapOrderIds(IOrderManagerForTradeLens _orderbook, address _owner)
        public
        view
        returns (uint256[] memory, uint256)
    {
        (, uint256 totalOrder) = _orderbook.getSwapOrders(_owner, 0, 0);

        uint256[] memory orderIds = new uint256[](totalOrder);
        uint256 totalPending = 0;
        for (uint256 i = totalOrder; i > 0; i--) {
            uint256 orderId = _orderbook.userSwapOrders(_owner, i - 1);
            IOrderManagerForTradeLens.SwapOrder memory order = _orderbook.swapOrders(orderId);
            if (order.owner == address(0)) {
                continue;
            }
            orderIds[totalPending++] = orderId;
        }
        return (orderIds, totalPending);
    }

    function getSwapOrders(IOrderManagerForTradeLens _orderbook, address _owner, uint256 _skip, uint256 _take)
        external
        view
        returns (SwapOrderForLens[] memory, uint256)
    {
        (uint256[] memory orderIds, uint256 totalOrder) = getSwapOrderIds(_orderbook, _owner);
        _skip = _skip < totalOrder ? _skip : totalOrder;
        _take = _skip + _take > totalOrder ? totalOrder - _skip : _take;
        SwapOrderForLens[] memory pendingOrders = new SwapOrderForLens[](_take);
        for (uint256 i = 0; i < _take; i++) {
            pendingOrders[i] = _parseSwapOrder(_orderbook, orderIds[_skip + i]);
        }
        return (pendingOrders, totalOrder);
    }

    function getAllSwapOrders(IOrderManagerForTradeLens _orderbook, address _owner)
        external
        view
        returns (SwapOrderForLens[] memory, uint256)
    {
        (uint256[] memory orderIds, uint256 totalOrder) = getSwapOrderIds(_orderbook, _owner);
        SwapOrderForLens[] memory pendingOrders = new SwapOrderForLens[](totalOrder);
        for (uint256 i = 0; i < totalOrder; i++) {
            pendingOrders[i] = _parseSwapOrder(_orderbook, orderIds[i]);
        }
        return (pendingOrders, totalOrder);
    }

    function _parseLeverageOrder(IOrderManagerForTradeLens _orderbook, uint256 _id)
        private
        view
        returns (LeverageOrderForLens memory)
    {
        IOrderManagerForTradeLens.Order memory order = _orderbook.orders(_id);
        IOrderManagerForTradeLens.Request memory request = _orderbook.requests(_id);

        LeverageOrderForLens memory leverageOrder;
        leverageOrder.id = _id;
        leverageOrder.indexToken = order.indexToken;
        leverageOrder.collateralToken = order.collateralToken;
        leverageOrder.triggerPrice = order.price;
        leverageOrder.triggerAboveThreshold = order.triggerAboveThreshold;
        leverageOrder.isMarket = order.expiresAt != 0;
        leverageOrder.expired = leverageOrder.isMarket && order.expiresAt < block.timestamp;

        leverageOrder.side = request.side;
        leverageOrder.updateType = request.updateType;
        leverageOrder.size = request.sizeChange;
        leverageOrder.collateral = request.collateral;

        return leverageOrder;
    }

    function _parseSwapOrder(IOrderManagerForTradeLens _orderbook, uint256 _id)
        private
        view
        returns (SwapOrderForLens memory)
    {
        IOrderManagerForTradeLens.SwapOrder memory order = _orderbook.swapOrders(_id);

        SwapOrderForLens memory swapOrder;
        swapOrder.id = _id;
        swapOrder.tokenIn = order.tokenIn;
        swapOrder.tokenOut = order.tokenOut;
        swapOrder.amountIn = order.amountIn;
        swapOrder.minAmountOut = order.minAmountOut;
        swapOrder.price = order.price;

        return swapOrder;
    }
}