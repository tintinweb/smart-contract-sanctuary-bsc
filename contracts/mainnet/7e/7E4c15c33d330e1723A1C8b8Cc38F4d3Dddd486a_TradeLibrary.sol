// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./../../Interfaces/IExchange.sol";
import {IUniswapV2Router02} from "./../../Interfaces/IUniswapV2Router.sol";
import "./../../Interfaces/ITokenConversionStorage.sol";
import "./../../Interfaces/IUniswapV2Pair.sol";

library TradeLibrary {
    function estimateInvestment(
        address lpPool,
        uint256 lpAmount,
        IExchange.LiquidityTrade memory trade,
        address[] memory rewards,
        address toToken,
        ITokenConversionStorage tokenConvestionStorage
    ) external view returns (uint256 estimatedLiquidity, uint256 estimatedRewards) {
        estimatedLiquidity = estimateLiquidityTrade(lpPool, lpAmount, trade);

        for (uint256 i = 0; i < rewards.length; i++) {
            uint256 amount = IERC20(rewards[i]).balanceOf(address(this));
            estimatedRewards += estimateDirectTokenTrade(
                tokenConvestionStorage,
                amount,
                rewards[i],
                toToken
            );
        }
    }

    function estimateLiquidityTrade(
        address lpPool,
        uint256 lpAmount,
        IExchange.LiquidityTrade memory trade
    ) public view returns (uint256 amountOut) {
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(lpPool)
            .getReserves();
        uint256 _totalSupply = IUniswapV2Pair(lpPool).totalSupply();
        uint256 amount0 = (lpAmount * _reserve0) / _totalSupply;
        uint256 amount1 = (lpAmount * _reserve1) / _totalSupply;

        amountOut =
            estimateTokenTrade(amount0, trade.token0) +
            estimateTokenTrade(amount1, trade.token1);
    }

    function estimateTokenTrade(
        uint256 amountIn,
        IExchange.TokenTrade memory tokenTrade
    ) public view returns (uint256 amountOut) {
        for (uint256 i = 0; i < tokenTrade.routers.length; i++) {
            uint256[] memory amounts = IUniswapV2Router02(tokenTrade.routers[i])
                .getAmountsOut(amountIn, tokenTrade.paths[i]);
            amountIn = amounts[amounts.length - 1];
        }

        amountOut = amountIn;
    }

    function estimateDirectTokenTrade(
        ITokenConversionStorage tokenConvestionStorage,
        uint256 amount,
        address fromToken,
        address toToken
    ) public view returns (uint256 amountOut) {
        address router = tokenConvestionStorage.getRouter(fromToken, toToken);
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(
            amount,
            path
        );
        return amounts[amounts.length - 1];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
      address indexed sender,
      uint amount0In,
      uint amount1In,
      uint amount0Out,
      uint amount1Out,
      address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface ITokenConversionStorage {
    function exchangesInfo(uint256 index)
        external
        returns (
            string memory name,
            address router,
            address factory
        );

    function getRouter(address fromToken, address toToken)
        external view
        returns (address router);
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface IExchange {
  struct TokenTrade {
		address[] routers;
		address[][] paths;
  }

  struct LiquidityTrade {
    TokenTrade token0;
    TokenTrade token1;
  }

  struct AddLiquidityTrade {
    LiquidityTrade liquidityTrade;
    uint256 token0Amount;
    uint256 token1Amount;
  }

  function addLiquidity(
    address _toWhomToIssue,
    address _fromTokenAddress,
    address _toPairAddress,
    address _poolRouter,
    address _poolFactory,
    uint256 _amount,
    uint256 _minPoolTokens,
    AddLiquidityTrade calldata _trade
  ) external returns(uint256);

  function addLiquidityDefaultPath(
    address _toWhomToIssue,
    address _FromTokenContractAddress,
    address _ToUnipoolToken0,
    address _ToUnipoolToken1,
    address _poolRouter,
    address _poolFactory,
    uint256 _amount,
    uint256 _minPoolTokens
  ) external returns(uint256);

  function removeLiquidity(
    address _toWhomToIssue,
    address _toToken,
    address _poolAddress,
    address _poolRouter,
    uint256 _amount,
    uint256 _minTokensRec,
    LiquidityTrade calldata _trade
  ) external returns(uint256);
}