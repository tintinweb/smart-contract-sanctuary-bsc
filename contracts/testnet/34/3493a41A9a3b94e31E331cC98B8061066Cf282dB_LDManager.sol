/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

interface IMint {
  function mint(address to, uint256 amount) external;
}
interface IUniswapV2Router02 {
  function WETH() external pure returns (address);

  function addLiquidity(
      address tokenA,
      address tokenB,
      uint amountADesired,
      uint amountBDesired,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);

  function addLiquidityETH(
      address token,
      uint amountTokenDesired,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract LDManager {
  IUniswapV2Router02 public Router;
  address public token;
  address public tokenMinter;
  address public treasury;

  constructor(
    address _Router,
    address _token,
    address _tokenMinter,
    address _treasury
  )
   public
  {
     Router = IUniswapV2Router02(_Router);
     token = _token;
     tokenMinter = _tokenMinter;
     treasury = _treasury;
  }

  function addLiquidity() external payable {
     //get price
     uint256 tokenAmount = getTokenPrice(msg.value);
     // mint tokens
     IMint(tokenMinter).mint(address(this), tokenAmount);
     // approve token transfer to cover all possible scenarios
     IERC20(token).approve(address(Router), tokenAmount);
     // add the liquidity
     Router.addLiquidityETH{value: msg.value}(
       token,
       tokenAmount,
       0, // slippage is unavoidable
       0, // slippage is unavoidable
       treasury,
       block.timestamp + 15 minutes
     );
  }


  function getTokenPrice(uint256 _ethAmount) public view returns(uint256) {
      address[] memory path = new address[](2);
      path[0] = Router.WETH();
      path[1] = address(token);
      uint256[] memory res = Router.getAmountsOut(_ethAmount, path);
      return res[1];
  }

  receive() external payable {}
}