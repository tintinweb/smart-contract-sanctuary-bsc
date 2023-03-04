pragma solidity >= 0.8.0;

interface ILevelOracle {
    function getPrice(address token, bool max) external view returns (uint256);
    function getMultiplePrices(address[] calldata tokens, bool max) external view returns (uint256[] memory);
}

pragma solidity 0.8.15;

import "src/interfaces/ILevelOracle.sol";

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

    function orders(uint256) external view returns (Order memory);
    function requests(uint256) external view returns (Request memory);
    function swapOrders(uint256) external view returns (SwapOrder memory);
    function oracle() external view returns (ILevelOracle);
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
    function calcSwapOutput(address _tokenIn, address _tokenOut, uint256 _amountIn)
        external
        view
        returns (uint256 amountOut, uint256 feeAmount);
    function fee()
        external
        view
        returns (
            uint256 positionFee,
            uint256 liquidationFee,
            uint256 baseSwapFee,
            uint256 taxBasisPoint,
            uint256 stableCoinBaseSwapFee,
            uint256 stableCoinTaxBasisPoint,
            uint256 daoFee
        );
}

contract OrderLens {
    function canExecuteOrders(IOrderManagerForOrderLens _orders, IPoolForOrderLens _pool, uint256[] calldata _orderIds)
        external
        view
        returns (bool[] memory)
    {
        uint256 count = _orderIds.length;
        bool[] memory rejected = new bool[](count);
        (uint256 positionFee, uint256 liquidationFee,,,,,) = _pool.fee();
        for (uint256 i = 0; i < count; i++) {
            uint256 orderId = _orderIds[i];
            IOrderManagerForOrderLens.Order memory order = _orders.orders(orderId);
            IOrderManagerForOrderLens.Request memory request = _orders.requests(orderId);
            IPoolForOrderLens.Position memory position =
                _pool.positions(_getPositionKey(order.owner, order.indexToken, order.collateralToken, request.side));
            if (order.expiresAt != 0 && order.expiresAt < block.timestamp) {
                continue;
            }
            if (order.owner == address(0)) {
                rejected[i] = true;
                continue;
            }

            if (request.updateType == 1) {
                //decrease
                if (position.size == 0) {
                    rejected[i] = true;
                    continue;
                }

                if (position.size > request.sizeChange) {
                    if (position.collateralValue < request.collateral) {
                        rejected[i] = true;
                        continue;
                    }
                    uint256 newSize = position.size - request.sizeChange;
                    uint256 fee = positionFee * request.sizeChange / 1e10;
                    uint256 newCollateral = position.collateralValue - request.collateral;
                    newCollateral = newCollateral > fee ? newCollateral - fee : 0;
                    rejected[i] =
                        newCollateral < liquidationFee || newCollateral * 35 < newSize || newCollateral > newSize; // leverage
                    continue;
                }
            }
        }

        return rejected;
    }

    function canExecuteSwapOrders(
        IOrderManagerForOrderLens _orders,
        IPoolForOrderLens _pool,
        uint256[] calldata _orderIds
    ) external view returns (bool[] memory rejected) {
        uint256 count = _orderIds.length;
        rejected = new bool[](count);

        for (uint256 i = 0; i < count; ++i) {
            uint256 orderId = _orderIds[i];
            IOrderManagerForOrderLens.SwapOrder memory order = _orders.swapOrders(orderId);
            if (order.owner == address(0)) {
                rejected[i] = true;
                continue;
            }

            (uint256 amountOut,) = _pool.calcSwapOutput(order.tokenIn, order.tokenOut, order.amountIn);
            rejected[i] = amountOut < order.minAmountOut;
        }
    }

    function _getPositionKey(address _owner, address _indexToken, address _collateralToken, uint8 _side)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_owner, _indexToken, _collateralToken, _side));
    }
}