pragma solidity >=0.6.6;

import '.././interfaces/IUniswapV2Pair.sol';
import '.././interfaces/IUniswapV2Factory.sol';
import '../../library/TransferHelper.sol';

import '../../library/SafeMath.sol';
import '../../ERC/IERC20.sol';
import '.././interfaces/IWETH.sol';
import './CustomSwapRouterStorage.sol';
import './WethHandler.sol';

contract CustomSwapRouter is CustomSwapRouterStorage {
    using SafeMath for uint;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'GameXChangeSwapV2Router: EXPIRED');
        _;
    }

    function init(address _factory, address _WETH, bytes memory _INIT_CODE_HASH) external onlyCommander() {
        require(WETH == address(0) && factory == address(0));
        factory = _factory;
        WETH = _WETH;
        INIT_CODE_HASH = _INIT_CODE_HASH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function setFee(uint8 _fee) external onlyOwner() {
        fee = _fee;
    }

    function setTax(uint _tax) external onlyOwner() {
        tax = _tax;
    }

    function setFeeTo(address _feeTo) external onlyOwner() {
        feeTo = _feeTo;
    }

    function setCodeHash(bytes memory _INIT_CODE_HASH) external onlyOwner() {
        INIT_CODE_HASH = _INIT_CODE_HASH;
    }

    function _pairFor(address tokenA, address tokenB) internal returns (address pair) {
        pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            // create the pair if it doesn't exist yet
            pair = IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
    }

    function _addUserPair(address to, address tokenA, address tokenB, address pair) internal {
      if(hasPairs[to].length == 0){
        pairIndexes[to][pair] = hasPairs[to].length;
        hasPairs[to].push(Pair(tokenA, tokenB));
      } else if(hasPairs[to][0].tokenA != tokenA && hasPairs[to][0].tokenB != tokenB) {
        pairIndexes[to][pair] = hasPairs[to].length;
        hasPairs[to].push(Pair(tokenA, tokenB));
      }
    }

    function _removeUserPair(address to, address tokenA, address tokenB, address pair) internal {
      Pair memory lastpair = hasPairs[to][hasPairs[to].length - 1];
      uint index = pairIndexes[to][pair];
      Pair memory curPair = hasPairs[to][index];
      // handle the default of 0 by checking if we have the right pair
      if(curPair.tokenA == tokenA && curPair.tokenB == tokenB) {
        // if not last element in the array, replace removed item with last element
        if(index != hasPairs[to].length - 1) {
          // overwrite currrent pair with last pair in array
          hasPairs[to][index] = lastpair;
          // update pairIndexes for last pair in array
          pairIndexes[to][_pairFor(lastpair.tokenA, lastpair.tokenB)] = index;
        }
        // remove pair
        hasPairs[to].pop();
        // remove index for removed pair
        pairIndexes[to][pair] = 0;
      }
    }

    function _checkUserPair(address to, address tokenA, address tokenB) internal {
      address pair = _pairFor(tokenA, tokenB);
      if(IUniswapV2Pair(pair).balanceOf(to) > 0){
        if(hasPairs[to].length == 0){
          if(tokenA > tokenB){
            _addUserPair(to, tokenB, tokenA, pair);
          } else {
            _addUserPair(to, tokenA, tokenB, pair);
          }
        } else if(pairIndexes[to][pair] == 0){
          if(tokenA > tokenB){
            _addUserPair(to, tokenB, tokenA, pair);
          } else {
            _addUserPair(to, tokenA, tokenB, pair);
          }
        }
      } else {
        if(hasPairs[to].length > 0){
          if(tokenA > tokenB){
            _removeUserPair(to, tokenB, tokenA, pair);
          } else {
            _removeUserPair(to, tokenA, tokenB, pair);
          }
        }
      }
    }

    function getUserPairs(address user, uint offset, uint limit) external view returns (Pair[] memory pairs, uint nextOffset, uint total) {
        total = hasPairs[user].length;
        if(limit == 0) {
            limit = 1;
        }
        if (limit > total- offset) {
            limit = total - offset;
        }

        Pair[] memory results = new Pair[] (limit);
        for (uint i = 0; i < limit; i++) {
            results[i] = hasPairs[user][offset + i];
        }
        return (results, offset + limit, total);
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB, address pair) {
        pair = _pairFor(tokenA, tokenB);
        (uint reserveA, uint reserveB) = getReserves(tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'GameXChangeSwapV2Router: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'GameXChangeSwapV2Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        if(tax > 0){
          require(msg.value >= tax, 'GameXChangeSwapV2Router: INSUFFICIENT_FEE');
          TransferHelper.safeTransferETH(feeTo, tax);
        }
        address pair;
        (amountA, amountB, pair) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(to);
        _checkUserPair(to, tokenA, tokenB);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        if(tax > 0){
          require(msg.value >= tax, 'GameXChangeSwapV2Router: INSUFFICIENT_FEE');
          TransferHelper.safeTransferETH(feeTo, tax);
        }
        uint amountEthSent = msg.value - tax;
        address pair;
        (amountToken, amountETH, pair) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            amountEthSent,
            amountTokenMin,
            amountETHMin
        );
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IUniswapV2Pair(pair).mint(to);
        _checkUserPair(msg.sender, token, WETH);
        // refund dust eth, if any
        if (amountEthSent > amountETH) TransferHelper.safeTransferETH(msg.sender, amountEthSent - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public payable virtual ensure(deadline) returns (uint amountA, uint amountB) {
        if(tax > 0){
          require(msg.value >= tax, 'GameXChangeSwapV2Router: INSUFFICIENT_FEE');
          TransferHelper.safeTransferETH(feeTo, tax);
        }
        address pair = _pairFor(tokenA, tokenB);
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
        (address token0,) = sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'GameXChangeSwapV2Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'GameXChangeSwapV2Router: INSUFFICIENT_B_AMOUNT');
        _checkUserPair(msg.sender, tokenA, tokenB);
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual payable ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).transfer(wethHandler, amountETH);
        WethHandler(wethHandler).unpackTokens(to, amountETH);

        _checkUserPair(msg.sender, token, WETH);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual payable returns (uint amountA, uint amountB) {
        address pair = _pairFor(tokenA, tokenB);
        uint value = approveMax ? ~uint(0) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual payable returns (uint amountToken, uint amountETH) {
        address pair = _pairFor(token, WETH);
        uint value = approveMax ? ~uint(0) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual payable ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));

        IWETH(WETH).transfer(wethHandler, amountETH);
        WethHandler(wethHandler).unpackTokens(to, amountETH);
        
        _checkUserPair(msg.sender, token, WETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual payable returns (uint amountETH) {
        address pair = _pairFor(token, WETH);
        uint value = approveMax ? ~uint(0) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
        _checkUserPair(to, token, WETH);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(_pairFor(input, output));
            uint[2] memory amounts;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amounts[0] = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amounts[1] = getAmountOut(amounts[0], reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
            if(i < path.length - 2){
              pair.swap(amount0Out, amount1Out, _pairFor(output, path[i + 2]), new bytes(0));
            // Final swap, take fee.
            } else {
              _finalSwap(_to, pair, amount0Out, amount1Out);
            }
        }
    }

    function _finalSwap(address _to, IUniswapV2Pair _pair, uint amount0Out, uint amount1Out) internal {
      if(feeTo == address(0)) {
        _pair.swap(amount0Out, amount1Out, _to, new bytes(0));
      } else {
        IERC20 token0 = IERC20(_pair.token0());
        IERC20 token1 = IERC20(_pair.token1());
        uint before0 = token0.balanceOf(address(this));
        uint before1 = token1.balanceOf(address(this));
        _pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
        uint after0 = token0.balanceOf(address(this));
        uint after1 = token1.balanceOf(address(this));

        if(after0.sub(before0) > 0){
          uint fee0 = (after0.sub(before0) * fee) / 10000;
          token0.transfer(_to, (after0.sub(before0)) - fee0);
          if(fee0 > 0){
            token0.transfer(feeTo, fee0);
          }
        }
        if(after1.sub(before1) > 0){
          uint fee1 = (after1.sub(before1) * fee) / 10000;
          token1.transfer(_to, (after1.sub(before1)) - fee1);
          if(fee1 > 0){
            token1.transfer(feeTo, fee1);
          }
        }
      }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) 
      external
      payable
      virtual
      ensure(deadline)
    {
        if(tax > 0){
          require(msg.value == tax, 'GameXChangeSwapV2Router: INSUFFICIENT_FEE');
          TransferHelper.safeTransferETH(feeTo, tax);
        }
        if(feeTo == address(0)) {
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, _pairFor(path[0], path[1]), amountIn
          );
        } else {
          uint _fee = (amountIn * fee) / 10000;
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, _pairFor(path[0], path[1]), amountIn - _fee
          );
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, feeTo, _fee
          );
        }
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'GameXChangeSwapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'GameXChangeSwapV2Router: INVALID_PATH');
        if(tax > 0){
          TransferHelper.safeTransferETH(feeTo, tax);
        }
        uint amountIn = msg.value - tax;
        uint _fee = (amountIn * fee) / 10000;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(_pairFor(path[0], path[1]), amountIn - _fee));
        assert(IWETH(WETH).transfer(feeTo, _fee));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'GameXChangeSwapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'GameXChangeSwapV2Router: INVALID_PATH');
        if(feeTo == address(0)) {
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, _pairFor(path[0], path[1]), amountIn
          );
        } else {
          uint _fee = (amountIn * fee) / 10000;
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, _pairFor(path[0], path[1]), amountIn - _fee
          );
          TransferHelper.safeTransferFrom(
              path[0], msg.sender, feeTo, _fee
          );
        }
        uint amountBefore = IERC20(WETH).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this)) - amountBefore;
        require(amountOut >= amountOutMin, 'GameXChangeSwapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        require(amountOut >= tax, 'GameXChangeSwapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).transfer(wethHandler, amountOut);
        WethHandler(wethHandler).unpackTokens(to, amountOut - tax);
        if(tax > 0){
          WethHandler(wethHandler).unpackTokens(feeTo, tax);
        }
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address tokenA, address tokenB) public view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                INIT_CODE_HASH // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(uint amountOut, address[] memory path) public view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function setWethHandler(address payable _wethHandler) external onlyOwner {
      wethHandler = _wethHandler;
    }

}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: UNLICENSED
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT
import "./Context.sol";

contract BigOwnable is Context {
    address private _commander;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CommandTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        _commander = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function commander() public view returns (address) {
        return _commander;
    }
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyCommander() {
        require(_commander == _msgSender(), "Ownable: caller is not the commander");
        _;
    }

    function renounceOwnership() external virtual onlyCommander {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external virtual onlyCommander {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferCommand(address newCommander) external virtual onlyCommander {
        require(newCommander != address(0), "Ownable: new owner is the zero address");
        emit CommandTransferred(_commander, newCommander);
        _commander = newCommander;
    }

    function renounceCommand() external virtual onlyCommander {
        emit CommandTransferred(_commander, address(0));
        _commander = address(0);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '.././interfaces/IWETH.sol';

contract WethHandler {

    address admin;
    IWETH weth;

    constructor(address _admin, address _weth) {
        admin =  _admin;
        weth = IWETH(_weth);
    }

    receive() external payable {

    }
    
    function unpackTokens(address to, uint256 amount) external {
      require(msg.sender == admin, "must be owner");
      weth.withdraw(amount);
      payable(to).transfer(amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../library/BigOwnable.sol";

contract CustomSwapRouterStorage is BigOwnable {
    address public logic_contract;

    address public factory;
    address public WETH;
    bytes public INIT_CODE_HASH;

    // 0.04% fee on currencies going in and out for a total of 0.8%
    address public feeTo;
    uint8 public fee = 40;
    // Added "30 cent" fee to each swap
    uint public tax = 780000000000000;
    
    struct Pair {
        address tokenA;
        address tokenB;
    }
    // user > toPairs
    mapping(address => Pair[]) public hasPairs;
    // user > pairAddress => index
    mapping(address => mapping(address => uint)) public pairIndexes;

    address payable public wethHandler;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}