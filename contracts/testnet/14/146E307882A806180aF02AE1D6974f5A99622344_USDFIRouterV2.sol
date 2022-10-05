// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./Math.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./IWETH.sol";
import "./IPair.sol";
import "./IFactory.sol";

contract USDFIRouterV2 {
  using SafeERC20 for IERC20;

  struct Route {
    address from;
    address to;
    bool stable;
  }

  address public immutable factory;
  IWETH public immutable weth;
  uint internal constant MINIMUM_LIQUIDITY = 10 ** 3;
  bytes32 immutable pairCodeHash;

  modifier ensure(uint deadline) {
    require(deadline >= block.timestamp, 'DystRouter: EXPIRED');
    _;
  }

  constructor(address _factory, address _weth) {
    factory = _factory;
    pairCodeHash = IFactory(_factory).pairCodeHash();
    weth = IWETH(_weth);
  }

  receive() external payable {
    // only accept ETH via fallback from the WETH contract
    require(msg.sender == address(weth), "DystRouter: NOT_WETH");
  }

  function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1) {
    return _sortTokens(tokenA, tokenB);
  }

  function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
    require(tokenA != tokenB, 'DystRouter: IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'DystRouter: ZERO_ADDRESS');
  }

  function pairFor(address tokenA, address tokenB, bool stable) external view returns (address pair) {
    return _pairFor(tokenA, tokenB, stable);
  }

  /// @dev Calculates the CREATE2 address for a pair without making any external calls.
  function _pairFor(address tokenA, address tokenB, bool stable) internal view returns (address pair) {
    (address token0, address token1) = _sortTokens(tokenA, tokenB);
    pair = address(uint160(uint(keccak256(abi.encodePacked(
        hex'ff',
        factory,
        keccak256(abi.encodePacked(token0, token1, stable)),
        pairCodeHash // init code hash
      )))));
  }

  function quoteLiquidity(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB) {
    return _quoteLiquidity(amountA, reserveA, reserveB);
  }

  /// @dev Given some amount of an asset and pair reserves, returns an equivalent amount of the other asset.
  function _quoteLiquidity(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
    require(amountA > 0, 'DystRouter: INSUFFICIENT_AMOUNT');
    require(reserveA > 0 && reserveB > 0, 'DystRouter: INSUFFICIENT_LIQUIDITY');
    amountB = amountA * reserveB / reserveA;
  }

  function getReserves(address tokenA, address tokenB, bool stable) external view returns (uint reserveA, uint reserveB) {
    return _getReserves(tokenA, tokenB, stable);
  }

  /// @dev Fetches and sorts the reserves for a pair.
  function _getReserves(address tokenA, address tokenB, bool stable) internal view returns (uint reserveA, uint reserveB) {
    (address token0,) = _sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1,) = IPair(_pairFor(tokenA, tokenB, stable)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  /// @dev Performs chained getAmountOut calculations on any number of pairs.
  function getAmountOut(uint amountIn, address tokenIn, address tokenOut) external view returns (uint amount, bool stable) {
    address pair = _pairFor(tokenIn, tokenOut, true);
    uint amountStable;
    uint amountVolatile;
    if (IFactory(factory).isPair(pair)) {
      amountStable = IPair(pair).getAmountOut(amountIn, tokenIn);
    }
    pair = _pairFor(tokenIn, tokenOut, false);
    if (IFactory(factory).isPair(pair)) {
      amountVolatile = IPair(pair).getAmountOut(amountIn, tokenIn);
    }
    return amountStable > amountVolatile ? (amountStable, true) : (amountVolatile, false);
  }

  function getExactAmountOut(uint amountIn, address tokenIn, address tokenOut, bool stable) external view returns (uint) {
    address pair = _pairFor(tokenIn, tokenOut, stable);
    if (IFactory(factory).isPair(pair)) {
      return IPair(pair).getAmountOut(amountIn, tokenIn);
    }
    return 0;
  }

  /// @dev Performs chained getAmountOut calculations on any number of pairs.
  function getAmountsOut(uint amountIn, Route[] memory routes) external view returns (uint[] memory amounts) {
    return _getAmountsOut(amountIn, routes);
  }

  function _getAmountsOut(uint amountIn, Route[] memory routes) internal view returns (uint[] memory amounts) {
    require(routes.length >= 1, 'DystRouter: INVALID_PATH');
    amounts = new uint[](routes.length + 1);
    amounts[0] = amountIn;
    for (uint i = 0; i < routes.length; i++) {
      address pair = _pairFor(routes[i].from, routes[i].to, routes[i].stable);
      if (IFactory(factory).isPair(pair)) {
        amounts[i + 1] = IPair(pair).getAmountOut(amounts[i], routes[i].from);
      }
    }
  }

  function isPair(address pair) external view returns (bool) {
    return IFactory(factory).isPair(pair);
  }

  function quoteAddLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint amountADesired,
    uint amountBDesired
  ) external view returns (uint amountA, uint amountB, uint liquidity) {
    // create the pair if it doesn't exist yet
    address _pair = IFactory(factory).getPair(tokenA, tokenB, stable);
    (uint reserveA, uint reserveB) = (0, 0);
    uint _totalSupply = 0;
    if (_pair != address(0)) {
      _totalSupply = IERC20(_pair).totalSupply();
      (reserveA, reserveB) = _getReserves(tokenA, tokenB, stable);
    }
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
      liquidity = Math.sqrt(amountA * amountB) - MINIMUM_LIQUIDITY;
    } else {

      uint amountBOptimal = _quoteLiquidity(amountADesired, reserveA, reserveB);
      if (amountBOptimal <= amountBDesired) {
        (amountA, amountB) = (amountADesired, amountBOptimal);
        liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
      } else {
        uint amountAOptimal = _quoteLiquidity(amountBDesired, reserveB, reserveA);
        (amountA, amountB) = (amountAOptimal, amountBDesired);
        liquidity = Math.min(amountA * _totalSupply / reserveA, amountB * _totalSupply / reserveB);
      }
    }
  }

  function quoteRemoveLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint liquidity
  ) external view returns (uint amountA, uint amountB) {
    // create the pair if it doesn't exist yet
    address _pair = IFactory(factory).getPair(tokenA, tokenB, stable);

    if (_pair == address(0)) {
      return (0, 0);
    }

    (uint reserveA, uint reserveB) = _getReserves(tokenA, tokenB, stable);
    uint _totalSupply = IERC20(_pair).totalSupply();
    // using balances ensures pro-rata distribution
    amountA = liquidity * reserveA / _totalSupply;
    // using balances ensures pro-rata distribution
    amountB = liquidity * reserveB / _totalSupply;

  }

  function _addLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin
  ) internal returns (uint amountA, uint amountB) {
    require(amountADesired >= amountAMin, "DystRouter: DESIRED_A_AMOUNT");
    require(amountBDesired >= amountBMin, "DystRouter: DESIRED_B_AMOUNT");
    // create the pair if it doesn't exist yet
    address _pair = IFactory(factory).getPair(tokenA, tokenB, stable);
    if (_pair == address(0)) {
      _pair = IFactory(factory).createPair(tokenA, tokenB, stable);
    }
    (uint reserveA, uint reserveB) = _getReserves(tokenA, tokenB, stable);
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } else {
      uint amountBOptimal = _quoteLiquidity(amountADesired, reserveA, reserveB);
      if (amountBOptimal <= amountBDesired) {
        require(amountBOptimal >= amountBMin, 'DystRouter: INSUFFICIENT_B_AMOUNT');
        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint amountAOptimal = _quoteLiquidity(amountBDesired, reserveB, reserveA);
        assert(amountAOptimal <= amountADesired);
        require(amountAOptimal >= amountAMin, 'DystRouter: INSUFFICIENT_A_AMOUNT');
        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }

  function addLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
    (amountA, amountB) = _addLiquidity(
      tokenA,
      tokenB,
      stable,
      amountADesired,
      amountBDesired,
      amountAMin,
      amountBMin
    );
    address pair = _pairFor(tokenA, tokenB, stable);
    SafeERC20.safeTransferFrom(IERC20(tokenA), msg.sender, pair, amountA);
    SafeERC20.safeTransferFrom(IERC20(tokenB), msg.sender, pair, amountB);
    liquidity = IPair(pair).mint(to);
  }

  function addLiquidityETH(
    address token,
    bool stable,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
    (amountToken, amountETH) = _addLiquidity(
      token,
      address(weth),
      stable,
      amountTokenDesired,
      msg.value,
      amountTokenMin,
      amountETHMin
    );
    address pair = _pairFor(token, address(weth), stable);
    IERC20(token).safeTransferFrom(msg.sender, pair, amountToken);
    weth.deposit{value : amountETH}();
    assert(weth.transfer(pair, amountETH));
    liquidity = IPair(pair).mint(to);
    // refund dust eth, if any
    if (msg.value > amountETH) _safeTransferETH(msg.sender, msg.value - amountETH);
  }

  // **** REMOVE LIQUIDITY ****

  function removeLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB) {
    return _removeLiquidity(
      tokenA,
      tokenB,
      stable,
      liquidity,
      amountAMin,
      amountBMin,
      to,
      deadline
    );
  }

  function _removeLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) internal ensure(deadline) returns (uint amountA, uint amountB) {
    address pair = _pairFor(tokenA, tokenB, stable);
    IERC20(pair).safeTransferFrom(msg.sender, pair, liquidity);
    // send liquidity to pair
    (uint amount0, uint amount1) = IPair(pair).burn(to);
    (address token0,) = _sortTokens(tokenA, tokenB);
    (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
    require(amountA >= amountAMin, 'DystRouter: INSUFFICIENT_A_AMOUNT');
    require(amountB >= amountBMin, 'DystRouter: INSUFFICIENT_B_AMOUNT');
  }

  function removeLiquidityETH(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH) {
    return _removeLiquidityETH(
      token,
      stable,
      liquidity,
      amountTokenMin,
      amountETHMin,
      to,
      deadline
    );
  }

  function _removeLiquidityETH(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) internal ensure(deadline) returns (uint amountToken, uint amountETH) {
    (amountToken, amountETH) = _removeLiquidity(
      token,
      address(weth),
      stable,
      liquidity,
      amountTokenMin,
      amountETHMin,
      address(this),
      deadline
    );
    IERC20(token).safeTransfer(to, amountToken);
    weth.withdraw(amountETH);
    _safeTransferETH(to, amountETH);
  }

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    bool stable,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB) {
    address pair = _pairFor(tokenA, tokenB, stable);
    {
      uint value = approveMax ? type(uint).max : liquidity;
      IPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    (amountA, amountB) = _removeLiquidity(tokenA, tokenB, stable, liquidity, amountAMin, amountBMin, to, deadline);
  }

  function removeLiquidityETHWithPermit(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH) {
    address pair = _pairFor(token, address(weth), stable);
    uint value = approveMax ? type(uint).max : liquidity;
    IPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
    (amountToken, amountETH) = _removeLiquidityETH(token, stable, liquidity, amountTokenMin, amountETHMin, to, deadline);
  }

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountFTMMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountFTM) {
    return _removeLiquidityETHSupportingFeeOnTransferTokens(
      token,
      stable,
      liquidity,
      amountTokenMin,
      amountFTMMin,
      to,
      deadline
    );
  }

  function _removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountFTMMin,
    address to,
    uint deadline
  ) internal ensure(deadline) returns (uint amountToken, uint amountFTM) {
    (amountToken, amountFTM) = _removeLiquidity(
      token,
      address(weth),
      stable,
      liquidity,
      amountTokenMin,
      amountFTMMin,
      address(this),
      deadline
    );
    IERC20(token).safeTransfer(to, IERC20(token).balanceOf(address(this)));
    weth.withdraw(amountFTM);
    _safeTransferETH(to, amountFTM);
  }

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    bool stable,
    uint liquidity,
    uint amountTokenMin,
    uint amountFTMMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountFTM) {
    address pair = _pairFor(token, address(weth), stable);
    uint value = approveMax ? type(uint).max : liquidity;
    IPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
    (amountToken, amountFTM) = _removeLiquidityETHSupportingFeeOnTransferTokens(
      token, stable, liquidity, amountTokenMin, amountFTMMin, to, deadline
    );
  }

  // **** SWAP ****
  // requires the initial amount to have already been sent to the first pair
  function _swap(uint[] memory amounts, Route[] memory routes, address _to) internal virtual {
    for (uint i = 0; i < routes.length; i++) {
      (address token0,) = _sortTokens(routes[i].from, routes[i].to);
      uint amountOut = amounts[i + 1];
      (uint amount0Out, uint amount1Out) = routes[i].from == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
      address to = i < routes.length - 1 ? _pairFor(routes[i + 1].from, routes[i + 1].to, routes[i + 1].stable) : _to;
      IPair(_pairFor(routes[i].from, routes[i].to, routes[i].stable)).swap(
        amount0Out, amount1Out, to, new bytes(0)
      );
    }
  }

  function _swapSupportingFeeOnTransferTokens(Route[] memory routes, address _to) internal virtual {
    for (uint i; i < routes.length; i++) {
      (address input, address output) = (routes[i].from, routes[i].to);
      (address token0,) = _sortTokens(input, output);
      IPair pair = IPair(_pairFor(routes[i].from, routes[i].to, routes[i].stable));
      uint amountInput;
      uint amountOutput;
      {// scope to avoid stack too deep errors
        (uint reserve0, uint reserve1,) = pair.getReserves();
        uint reserveInput = input == token0 ? reserve0 : reserve1;
        amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
        //(amountOutput,) = getAmountOut(amountInput, input, output, stable);
        amountOutput = pair.getAmountOut(amountInput, input);
      }
      (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
      address to = i < routes.length - 1 ? _pairFor(routes[i + 1].from, routes[i + 1].to, routes[i + 1].stable) : _to;
      pair.swap(amount0Out, amount1Out, to, new bytes(0));
    }
  }

  function swapExactTokensForTokensSimple(
    uint amountIn,
    uint amountOutMin,
    address tokenFrom,
    address tokenTo,
    bool stable,
    address to,
    uint deadline
  ) external ensure(deadline) returns (uint[] memory amounts) {
    Route[] memory routes = new Route[](1);
    routes[0].from = tokenFrom;
    routes[0].to = tokenTo;
    routes[0].stable = stable;
    amounts = _getAmountsOut(amountIn, routes);
    require(amounts[amounts.length - 1] >= amountOutMin, 'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    IERC20(routes[0].from).safeTransferFrom(
      msg.sender, _pairFor(routes[0].from, routes[0].to, routes[0].stable), amounts[0]
    );
    _swap(amounts, routes, to);
  }

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    Route[] calldata routes,
    address to,
    uint deadline
  ) external ensure(deadline) returns (uint[] memory amounts) {
    amounts = _getAmountsOut(amountIn, routes);
    require(amounts[amounts.length - 1] >= amountOutMin, 'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    IERC20(routes[0].from).safeTransferFrom(
      msg.sender, _pairFor(routes[0].from, routes[0].to, routes[0].stable), amounts[0]
    );
    _swap(amounts, routes, to);
  }

  function swapExactETHForTokens(uint amountOutMin, Route[] calldata routes, address to, uint deadline)
  external
  payable
  ensure(deadline)
  returns (uint[] memory amounts)
  {
    require(routes[0].from == address(weth), 'DystRouter: INVALID_PATH');
    amounts = _getAmountsOut(msg.value, routes);
    require(amounts[amounts.length - 1] >= amountOutMin, 'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    weth.deposit{value : amounts[0]}();
    assert(weth.transfer(_pairFor(routes[0].from, routes[0].to, routes[0].stable), amounts[0]));
    _swap(amounts, routes, to);
  }

  function swapExactTokensForETH(uint amountIn, uint amountOutMin, Route[] calldata routes, address to, uint deadline)
  external
  ensure(deadline)
  returns (uint[] memory amounts)
  {
    require(routes[routes.length - 1].to == address(weth), 'DystRouter: INVALID_PATH');
    amounts = _getAmountsOut(amountIn, routes);
    require(amounts[amounts.length - 1] >= amountOutMin, 'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    IERC20(routes[0].from).safeTransferFrom(
      msg.sender, _pairFor(routes[0].from, routes[0].to, routes[0].stable), amounts[0]
    );
    _swap(amounts, routes, address(this));
    weth.withdraw(amounts[amounts.length - 1]);
    _safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    Route[] calldata routes,
    address to,
    uint deadline
  ) external ensure(deadline) {
    IERC20(routes[0].from).safeTransferFrom(
      msg.sender,
      _pairFor(routes[0].from, routes[0].to, routes[0].stable),
      amountIn
    );
    uint balanceBefore = IERC20(routes[routes.length - 1].to).balanceOf(to);
    _swapSupportingFeeOnTransferTokens(routes, to);
    require(
      IERC20(routes[routes.length - 1].to).balanceOf(to) - balanceBefore >= amountOutMin,
      'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT'
    );
  }

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    Route[] calldata routes,
    address to,
    uint deadline
  )
  external
  payable
  ensure(deadline)
  {
    require(routes[0].from == address(weth), 'DystRouter: INVALID_PATH');
    uint amountIn = msg.value;
    weth.deposit{value : amountIn}();
    assert(weth.transfer(_pairFor(routes[0].from, routes[0].to, routes[0].stable), amountIn));
    uint balanceBefore = IERC20(routes[routes.length - 1].to).balanceOf(to);
    _swapSupportingFeeOnTransferTokens(routes, to);
    require(
      IERC20(routes[routes.length - 1].to).balanceOf(to) - balanceBefore >= amountOutMin,
      'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT'
    );
  }

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    Route[] calldata routes,
    address to,
    uint deadline
  )
  external
  ensure(deadline)
  {
    require(routes[routes.length - 1].to == address(weth), 'DystRouter: INVALID_PATH');
    IERC20(routes[0].from).safeTransferFrom(
      msg.sender, _pairFor(routes[0].from, routes[0].to, routes[0].stable), amountIn
    );
    _swapSupportingFeeOnTransferTokens(routes, address(this));
    uint amountOut = IERC20(address(weth)).balanceOf(address(this));
    require(amountOut >= amountOutMin, 'DystRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    weth.withdraw(amountOut);
    _safeTransferETH(to, amountOut);
  }

  function UNSAFE_swapExactTokensForTokens(
    uint[] memory amounts,
    Route[] calldata routes,
    address to,
    uint deadline
  ) external ensure(deadline) returns (uint[] memory) {
    IERC20(routes[0].from).safeTransferFrom(msg.sender, _pairFor(routes[0].from, routes[0].to, routes[0].stable), amounts[0]);
    _swap(amounts, routes, to);
    return amounts;
  }

  function _safeTransferETH(address to, uint value) internal {
    (bool success,) = to.call{value : value}(new bytes(0));
    require(success, 'DystRouter: ETH_TRANSFER_FAILED');
  }
}