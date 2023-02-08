pragma solidity 0.8.15;

interface IOrderManagerForOrderLens {
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

    function orders(uint256) external view returns (Order memory);
    function requests(uint256) external view returns (Request memory);
}

interface IPoolForOrderLens {
    struct Position {
        /// @dev contract size is evaluated in dollar
        uint256 size;
        /// @dev collateral value in dollar
        uint256 collateralValue;
        /// @dev contract size in indexToken
        uint256 reserveAmount;
        /// @dev average entry price
        uint256 entryPrice;
        /// @dev last cumulative interest rate
        uint256 borrowIndex;
    }

    function positions(bytes32 id) external view returns (Position memory);
}

contract OrderLens {
    function canExecuteOrders(IOrderManagerForOrderLens _orders, IPoolForOrderLens _pool, uint256[] calldata _orderIds)
        external
        view
        returns (bool[] memory)
    {
        uint256 count = _orderIds.length;
        bool[] memory rejected = new bool[](count);
        for (uint256 i = 0; i < count; i++) {
            uint256 orderId = _orderIds[i];
            IOrderManagerForOrderLens.Order memory order = _orders.orders(orderId);
            IOrderManagerForOrderLens.Request memory request = _orders.requests(orderId);
            IPoolForOrderLens.Position memory position =
                _pool.positions(_getPositionKey(order.owner, order.indexToken, order.collateralToken, request.side));
            if (order.owner == address(0)) {
                rejected[i] = true;
                continue;
            }

            if (request.updateType == 1 && position.size == 0) {
                //decrease
                rejected[i] = true;
                continue;
            }
        }

        return rejected;
    }

    function _getPositionKey(address _owner, address _indexToken, address _collateralToken, uint8 _side)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_owner, _indexToken, _collateralToken, _side));
    }
}