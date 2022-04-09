//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IERC20 {
  function totalSupply() external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function transfer(address recipient, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract ArbitrageRouter {

    uint constant MAX_UINT = 2**256 - 1 - 100;
    address payable owner;
    constructor() {
        owner = payable(msg.sender);
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'ArbitrageRouter: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ArbitrageRouter: ZERO_ADDRESS');
    }
    function approve(address router, address tokenAddress) public {
        IERC20 token = IERC20(tokenAddress);
        if(token.allowance(address(this), address(router)) < 1){
            require(token.approve(address(router), MAX_UINT),"FAIL TO APPROVE");
        }
    }
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'ArbitrageRouter: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'ArbitrageRouter: INSUFFICIENT_LIQUIDITY');
        uint numerator = amountIn * reserveOut;
        uint denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }
    function _swapTokens(address pairAdd, address[] memory path, address _to) internal virtual {
        (address input, address output) = (path[0], path[1]);
        (address token0,) = sortTokens(input, output);
        IPancakePair pair = IPancakePair(pairAdd);
        uint amountInput;
        uint amountOutput;
        { // scope to avoid stack too deep errors
        (uint reserve0, uint reserve1,) = pair.getReserves();
        (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
        amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
        }
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        pair.swap(amount0Out, amount1Out, _to, new bytes(0));
    }
    function swapTokens(
        uint amountIn,
        uint amountOutMin,
        
        address[] calldata path,
        address pair,

        address to
    ) external virtual ensure(block.timestamp+60) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapTokens(pair, path, to);
        require(
            (IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore ) >= amountOutMin,
            'ArbitrageRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapETHForTokens(
        uint amountOutMin,

        address[] calldata path, // [wbnb, token]
        address pair,

        address to
    ) external virtual payable ensure(block.timestamp+60) {
        uint amountIn = msg.value;
        IWETH(path[0]).deposit{value: amountIn}();
        assert(IWETH(path[0]).transfer(pair, amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapTokens(pair, path, to);
        require(
            (IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore) >= amountOutMin,
            'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapTokensForETH(
        uint amountIn,
        uint amountOutMin,
        
        address[] calldata path, // [token, wbnb]
        address pair,

        address to
    ) external virtual ensure(block.timestamp+60) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        _swapTokens(pair, path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(path[path.length - 1]).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    function withdraw() external{
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    function withdrawToken(address tokenAddress, address to) external{
        require(msg.sender == owner);
        IERC20 token = IERC20(tokenAddress);
        token.transfer(to, token.balanceOf(address(this)));
    }
    receive() external payable{}
}