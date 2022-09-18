/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

//SPDX-License-Identifier: UNLICENSED                                                                                                                                     

pragma solidity ^0.8;

interface IFilterManager {
    function factoryAddress() external view returns (address);
    function wethAddress() external view returns (address);
    function imposeLiquidityLock(address, address, uint) external;
}

interface IFilterFactory {
    function getPair(address, address) external view returns (address);
    function createPair(address, address) external returns (address);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address, uint) external returns (bool);
    function withdraw(uint) external;
}

interface IFilterPair {
    function transferFrom(address, address, uint) external returns (bool);
    function permit(address, address, uint, uint, uint8, bytes32, bytes32) external;
    function getReserves() external view returns (uint112, uint112, uint32);
    function mint(address) external returns (uint);
    function burn(address) external returns (uint, uint);
    function swap(uint, uint, address, bytes calldata) external;
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        require(IERC20(token).transfer(to, value), "FilterRouter: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        require(IERC20(token).transferFrom(from, to, value), "FilterRouter: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        payable(to).transfer(value);
    }
}

library FilterLibrary {
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "FilterLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "FilterLibrary: ZERO_ADDRESS");
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex"ff",
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex"41cc402d98b8fdf9e30b1a571b899f923bd800690b6b879e9c5a57482f1924cd"
        )))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IFilterPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "FilterLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, "FilterLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 998;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "FilterLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * 998;
        amountIn = (numerator / denominator) + 1;
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "FilterLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;

        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "FilterLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;

        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract FilterRouter {
    address public managerAddress;
    IFilterManager filterManager;

    address public wethAddress;

    // **** CONSTRUCTOR, FALLBACK & MODIFIER FUNCTIONS ****

    constructor(address _managerAddress) {
        managerAddress = _managerAddress;
        filterManager = IFilterManager(managerAddress);
        wethAddress = filterManager.wethAddress();
    }

    receive() external payable {
        assert(msg.sender == wethAddress);
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "FilterRouter: EXPIRED"); 
        _;
    }

    // **** ADD LIQUIDITY FUNCTIONS ****

    function processAddLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin) internal returns (uint amountA, uint amountB) {
        if (IFilterFactory(filterManager.factoryAddress()).getPair(tokenA, tokenB) == address(0)) IFilterFactory(filterManager.factoryAddress()).createPair(tokenA, tokenB);

        (uint reserveA, uint reserveB) = FilterLibrary.getReserves(filterManager.factoryAddress(), tokenA, tokenB);

        if (reserveA == 0 && reserveB == 0) (amountA, amountB) = (amountADesired, amountBDesired);
        
        else {
            uint amountBOptimal = FilterLibrary.quote(amountADesired, reserveA, reserveB);

            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } 
            
            else {
                uint amountAOptimal = FilterLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline, uint liquidityLockTime) external ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = processAddLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IFilterPair(pair).mint(to);
        filterManager.imposeLiquidityLock(to, pair, liquidityLockTime);
    }

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline, uint liquidityLockTime) external payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = processAddLiquidity(token, wethAddress, amountTokenDesired, msg.value, amountTokenMin, amountETHMin);
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, wethAddress);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(wethAddress).deposit{value: amountETH}();
        assert(IWETH(wethAddress).transfer(pair, amountETH));
        liquidity = IFilterPair(pair).mint(to);
        filterManager.imposeLiquidityLock(to, pair, liquidityLockTime);

        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY FUNCTIONS ****

    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) public ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        IFilterPair(pair).transferFrom(msg.sender, pair, liquidity);
        (uint amount0, uint amount1) = IFilterPair(pair).burn(to);
        (address token0, ) = FilterLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(token, wethAddress, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(wethAddress).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, wethAddress);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public ensure(deadline) returns (uint amountETH) {
        uint amountToken;
        (amountToken, amountETH) = removeLiquidity(token, wethAddress, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(wethAddress).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, wethAddress);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** SWAP FUNCTIONS ****

    function swap(uint[] memory amounts, address[] memory path, address _to) internal {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FilterLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(filterManager.factoryAddress(), output, path[i + 2]) : _to;
            IFilterPair(FilterLibrary.pairFor(filterManager.factoryAddress(), input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, to);
    }

    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == wethAddress, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(wethAddress).deposit{value: amounts[0]}();
        assert(IWETH(wethAddress).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]));
        swap(amounts, path, to);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == wethAddress, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, address(this));
        IWETH(wethAddress).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == wethAddress, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, address(this));
        IWETH(wethAddress).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == wethAddress, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= msg.value, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        IWETH(wethAddress).deposit{value: amounts[0]}();
        assert(IWETH(wethAddress).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]));
        swap(amounts, path, to);

        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    function swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FilterLibrary.sortTokens(input, output);
            IFilterPair pair = IFilterPair(FilterLibrary.pairFor(filterManager.factoryAddress(), input, output));
            uint amountInput;
            uint amountOutput;

            {
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
                amountOutput = FilterLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }

            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(filterManager.factoryAddress(), output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) {
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        swapSupportingFeeOnTransferTokens(path, to);
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore;
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable ensure(deadline) {
        require(path[0] == wethAddress, "FilterRouter: INVALID_PATH");
        uint amountIn = msg.value;
        IWETH(wethAddress).deposit{value: amountIn}();
        assert(IWETH(wethAddress).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        swapSupportingFeeOnTransferTokens(path, to);
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore;
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) {
        require(path[path.length - 1] == wethAddress, "FilterRouter: INVALID_PATH");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(wethAddress).balanceOf(address(this));
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(wethAddress).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** BONUS FUNCTIONS ****

    function removeAllLiquidity(address tokenA, address tokenB, uint amountAMin, uint amountBMin, address to, uint deadline) public ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        uint liquidityBalance = IERC20(pair).balanceOf(msg.sender);
        IFilterPair(pair).transferFrom(msg.sender, pair, liquidityBalance);
        (uint amount0, uint amount1) = IFilterPair(pair).burn(to);
        (address token0, ) = FilterLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
    }

    function removeAllLiquidityETH(address token, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeAllLiquidity(token, wethAddress, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(wethAddress).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function swapAllTokensForETH(uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == wethAddress, "FilterRouter: INVALID_PATH");
        uint amountIn = IERC20(path[0]).balanceOf(msg.sender);
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, address(this));
        IWETH(wethAddress).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapAllTokensForETHSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) {
        require(path[path.length - 1] == wethAddress, "FilterRouter: INVALID_PATH");
        uint amountIn = IERC20(path[0]).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(wethAddress).balanceOf(address(this));
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(wethAddress).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    function swapAllTokensForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) returns (uint[] memory amounts) {
        uint amountIn = IERC20(path[0]).balanceOf(msg.sender);
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, to);
    }

    function swapAllTokensForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external ensure(deadline) {
        uint amountIn = IERC20(path[0]).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        swapSupportingFeeOnTransferTokens(path, to);
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore;
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    }

    // **** LIBRARY FUNCTIONS ****

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB) {
        return FilterLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut) {
        return FilterLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn) {
        return FilterLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts) {
        return FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts) {
        return FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
    }
}