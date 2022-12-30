// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MockEmitter {
    event IncreasePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee
    );
    event DecreasePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee
    );

    event Swap(
        address account,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 amountOutAfterFees,
        uint256 feeBasisPoints
    );

    event CreateIncreasePosition(
        address indexed account,
        address[] path,
        address indexToken,
        uint256 amountIn,
        uint256 minOut,
        uint256 sizeDelta,
        bool isLong,
        uint256 acceptablePrice,
        uint256 executionFee,
        uint256 index,
        uint256 queueIndex,
        uint256 blockNumber,
        uint256 blockTime,
        uint256 gasPrice
    );

    event CreateDecreasePosition(
        address indexed account,
        address[] path,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        address receiver,
        uint256 acceptablePrice,
        uint256 minOut,
        uint256 executionFee,
        uint256 index,
        uint256 queueIndex,
        uint256 blockNumber,
        uint256 blockTime
    );

    event CreateIncreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address purchaseToken,
        uint256 purchaseTokenAmount,
        address collateralToken,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee
    );
    event CancelIncreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address purchaseToken,
        uint256 purchaseTokenAmount,
        address collateralToken,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee
    );
    event ExecuteIncreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address purchaseToken,
        uint256 purchaseTokenAmount,
        address collateralToken,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee,
        uint256 executionPrice
    );
    event UpdateIncreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address collateralToken,
        address indexToken,
        bool isLong,
        uint256 sizeDelta,
        uint256 triggerPrice,
        bool triggerAboveThreshold
    );
    event CreateDecreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address collateralToken,
        uint256 collateralDelta,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee
    );
    event CancelDecreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address collateralToken,
        uint256 collateralDelta,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee
    );
    event ExecuteDecreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address collateralToken,
        uint256 collateralDelta,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold,
        uint256 executionFee,
        uint256 executionPrice
    );
    event UpdateDecreaseOrder(
        address indexed account,
        uint256 orderIndex,
        address collateralToken,
        uint256 collateralDelta,
        address indexToken,
        uint256 sizeDelta,
        bool isLong,
        uint256 triggerPrice,
        bool triggerAboveThreshold
    );

    event BuyUSDG(
        address account,
        address token,
        uint256 tokenAmount,
        uint256 usdgAmount,
        uint256 feeBasisPoints
    );
    event SellUSDG(
        address account,
        address token,
        uint256 usdgAmount,
        uint256 tokenAmount,
        uint256 feeBasisPoints
    );

    event CancelIncreasePosition(
        address indexed account,
        address[] path,
        address indexToken,
        uint256 amountIn,
        uint256 minOut,
        uint256 sizeDelta,
        bool isLong,
        uint256 acceptablePrice,
        uint256 executionFee,
        uint256 blockGap,
        uint256 timeGap
    );

    event CancelDecreasePosition(
        address indexed account,
        address[] path,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        address receiver,
        uint256 acceptablePrice,
        uint256 minOut,
        uint256 executionFee,
        uint256 blockGap,
        uint256 timeGap
    );

    event LiquidatePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        bool isLong,
        uint256 size,
        uint256 collateral,
        uint256 reserveAmount,
        int256 realisedPnl,
        uint256 markPrice
    );

    event CreateSwapOrder(
        address indexed account,
        uint256 orderIndex,
        address[] path,
        uint256 amountIn,
        uint256 minOut,
        uint256 triggerRatio,
        bool triggerAboveThreshold,
        bool shouldUnwrap,
        uint256 executionFee
    );
    event CancelSwapOrder(
        address indexed account,
        uint256 orderIndex,
        address[] path,
        uint256 amountIn,
        uint256 minOut,
        uint256 triggerRatio,
        bool triggerAboveThreshold,
        bool shouldUnwrap,
        uint256 executionFee
    );
    event UpdateSwapOrder(
        address indexed account,
        uint256 ordexIndex,
        address[] path,
        uint256 amountIn,
        uint256 minOut,
        uint256 triggerRatio,
        bool triggerAboveThreshold,
        bool shouldUnwrap,
        uint256 executionFee
    );
    event ExecuteSwapOrder(
        address indexed account,
        uint256 orderIndex,
        address[] path,
        uint256 amountIn,
        uint256 minOut,
        uint256 amountOut,
        uint256 triggerRatio,
        bool triggerAboveThreshold,
        bool shouldUnwrap,
        uint256 executionFee
    );

    function Emit1() public {
        address[] memory path = new address[](2);
        path[0] = address(0);
        path[1] = address(0);

        emit IncreasePosition(
            bytes32("abc"),
            address(0),
            address(0),
            address(0),
            0,
            0,
            false,
            0,
            0
        );
        emit DecreasePosition(
            bytes32("abc"),
            address(0),
            address(0),
            address(0),
            0,
            0,
            false,
            0,
            0
        );
        emit Swap(address(0), address(0), address(0), 0, 0, 0, 0);

        emit CreateIncreasePosition(
            msg.sender,
            path,
            address(1),
            0,
            0,
            0,
            false,
            0,
            0,
            0,
            0,
            0,
            0,
            tx.gasprice
        );
        emit CreateDecreasePosition(
            address(0),
            path,
            address(0),
            0,
            0,
            false,
            address(0),
            0,
            0,
            0,
            0,
            0,
            0,
            0
        );
    }

    //emit all events in contract
    function Emit2() public {
        address[] memory path = new address[](2);
        path[0] = address(0);
        path[1] = address(0);

        emit CreateIncreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            address(0),
            0,
            false,
            0,
            false,
            0
        );
        emit CancelIncreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            address(0),
            0,
            false,
            0,
            false,
            0
        );
        emit ExecuteIncreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            address(0),
            0,
            false,
            0,
            false,
            0,
            0
        );
        emit UpdateIncreaseOrder(
            address(0),
            0,
            address(0),
            address(0),
            false,
            0,
            0,
            false
        );
        emit CreateDecreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            0,
            false,
            0,
            false,
            0
        );
        emit CancelDecreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            0,
            false,
            0,
            false,
            0
        );
        emit ExecuteDecreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            0,
            false,
            0,
            false,
            0,
            0
        );
        emit UpdateDecreaseOrder(
            address(0),
            0,
            address(0),
            0,
            address(0),
            0,
            false,
            0,
            false
        );

        emit BuyUSDG(address(0), address(0), 0, 0, 0);

        emit SellUSDG(address(0), address(0), 0, 0, 0);

        emit CancelIncreasePosition(
            address(0),
            path,
            address(0),
            0,
            0,
            0,
            false,
            0,
            0,
            0,
            0
        );

        emit CancelDecreasePosition(
            address(0),
            path,
            address(0),
            0,
            0,
            false,
            address(0),
            0,
            0,
            0,
            0,
            0
        );

        emit LiquidatePosition(
            bytes32("abc"),
            address(0),
            address(0),
            address(0),
            false,
            0,
            0,
            0,
            0,
            0
        );

        emit CreateSwapOrder(address(0), 0, path, 0, 0, 0, false, false, 0);

        emit CancelSwapOrder(address(0), 0, path, 0, 0, 0, false, false, 0);

        emit UpdateSwapOrder(address(0), 0, path, 0, 0, 0, false, false, 0);

        emit ExecuteSwapOrder(address(0), 0, path, 0, 0, 0, 0, false, false, 0);
    }
}