/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPancakeFactory {
    function getPair(address token1, address token2) external returns (address);
}

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
}

contract PancakeSell {
    bool private constant testnet = true;
    IPancakeFactory private constant pancakeFactory = IPancakeFactory(testnet ? 
        0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc :
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address private WBNB = testnet ? 
        0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F :
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function sell(address token) external {
        IERC20 tokenContract = IERC20(token);
        uint amount = tokenContract.balanceOf(address(this));

        IPancakePair pair = IPancakePair(pancakeFactory.getPair(token, WBNB));
        PancakeLibrary.safeTransfer(token, address(pair), amount);
        
        (address input, address output) = (token, WBNB);
        (address token0,) = PancakeLibrary.sortTokens(input, output);
        uint amountOutput;
        { // scope to avoid stack too deep errors
        (uint reserve0, uint reserve1,) = pair.getReserves();
        (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
        amountOutput = PancakeLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
        }
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        pair.swap(amount0Out, amount1Out, msg.sender, new bytes(0));
    }
}