// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";
import "./IWETH.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./TransferHelper.sol";

contract TaxlessArbitrage is Ownable, ReentrancyGuard {
  mapping(address => bool) public approvedSwappers;
  address public immutable WETH;

  modifier onlyApproved() {
      require(approvedSwappers[_msgSender()], "Access denied");
      _;
  }

  modifier ensure(uint deadline) {
      require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
      _;
  }

  constructor (address _weth) {
      WETH = _weth;
  }

  function taxlessSell (
    address dex, 
    address token, 
    uint256 amount, 
    uint256 amountOutMin,
    address to
  ) external onlyApproved {
      // liquidity pool
      IUniswapV2Pair pair = IUniswapV2Pair(
        IUniswapV2Factory(
          IUniswapV2Router02(dex).factory()
        ).getPair(token, WETH)
      );
      TransferHelper.safeTransferFrom(
          token, _msgSender(), address(pair), amount
      );
      // handle swap logic
      (address input, address output) = (token, WETH);
      (address token0,) = sortTokens(input, output);
      uint amountInput;
      uint amountOutput;
      { // scope to avoid stack too deep errors
      (uint reserve0, uint reserve1,) = pair.getReserves();
      (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
      amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
      amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
      }
      
      (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));

      // make the swap
      pair.swap(amount0Out, amount1Out, address(this), new bytes(0));

      // check output amount
      uint amountOut = IERC20(WETH).balanceOf(address(this));
      require(amountOut >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
      IWETH(WETH).withdraw(amountOut);
      TransferHelper.safeTransferETH(to, amountOut);
  }

  // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
      require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
      require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
      uint amountInWithFee = amountIn * 9970;
      uint numerator = amountInWithFee * reserveOut;
      uint denominator = reserveIn * 10000 + amountInWithFee;
      amountOut = numerator / denominator;
  }

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
      require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
      (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
  }

  // Owner functions
  function setApprovedSwapper (address _swapper, bool canSwap) external onlyOwner {
      require(approvedSwappers[_swapper] != canSwap, "Swapper already set to this value");
      approvedSwappers[_swapper] = canSwap;
  }

  function withdrawEthToOwner (uint256 _amount) external onlyOwner {
      TransferHelper.safeTransferETH(_msgSender(), _amount);
  }

  function withdrawTokenToOwner(address tokenAddress, uint256 amount) external onlyOwner {
      uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
      require(balance >= amount, "Insufficient token balance");
      TransferHelper.safeTransfer(tokenAddress, _msgSender(), amount);
  }

  // receive eth
  receive() external payable {}
}