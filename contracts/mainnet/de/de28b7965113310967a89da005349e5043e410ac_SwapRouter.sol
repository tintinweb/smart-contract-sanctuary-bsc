/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface ISwapPair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract SwapRouter {

    address private pair = 0x22Bd6eE41debC3CDd2a75f9B5F0F396087a9669F;
    address private pfid = 0x1780CE9bA71E115bb36781a22B858b54fC0d93CE;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;

    // constructor(address _pair, address _pfid, address _usdt) {
    //     pair = _pair;
    //     pfid = _pfid;
    //     usdt = _usdt;
    // }

    function getAmountOut(uint amountIn) public view returns(uint amountOut) {
        (uint reserveIn, uint reserveOut,) = ISwapPair(pair).getReserves();
        amountOut = _getAmountOut(amountIn, reserveIn, reserveOut);
    }
    
    function swap(uint amountIn, uint amountOutMin) public {
        uint amountOut = getAmountOut(amountIn);
        require(amountOut >= amountOutMin, 'SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        safeTransferFrom(pfid, msg.sender, pair, amountIn);
        ISwapPair(pair).swap(0, amountOut, msg.sender, new bytes(0));
    }
    
    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'SwapRouter: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SwapRouter: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}