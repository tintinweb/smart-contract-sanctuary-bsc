/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


library Address {
   
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }


    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector,spender,newAllowance));
    }
}

interface IPlanetFactory {
    
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IPlanetPair {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function approve(address spender, uint value) external returns (bool);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IStableSwap {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, address receiver) external returns(uint256 stablesReceived);
    function get_coins(uint256 coin_index) external view returns (address coin_address);

}

interface ISolidlyRouter{
    struct Routes {
        address from;
        address to;
        bool stable;
    }
}

interface ISolidlyRouter2 is ISolidlyRouter{
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        Routes[] calldata routes, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn, 
        Routes[] memory routes
    ) external view returns (uint[] memory amounts);
}

contract PlanetRouter is ISolidlyRouter{

    address public immutable factory;
    address public immutable WBNB;
    uint public swapFeeFactor = 9990;
    uint public constant swapFeeFactorMin = 9900;
    address public admin;
    address[] public bnbToGammaPath;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PlanetRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _WBNB) {
        factory = _factory;
        WBNB = _WBNB;
        admin = msg.sender;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IPlanetFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IPlanetFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = getReserves(tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'PlanetRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'PlanetRouter: INSUFFICIENT_A_AMOUNT');
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
    ) external virtual ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = pairFor(tokenA, tokenB);
        TransferHelper.safeTransferFrom(IERC20(tokenA), msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(IERC20(tokenB), msg.sender, pair, amountB);
        liquidity = IPlanetPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WBNB,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = pairFor(token, WBNB);
        TransferHelper.safeTransferFrom(IERC20(token), msg.sender, pair, amountToken);
        IWBNB(WBNB).deposit{value: amountETH}();
        assert(IWBNB(WBNB).transfer(pair, amountETH));
        liquidity = IPlanetPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
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
    ) public virtual ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = pairFor(tokenA, tokenB);
        require(IPlanetPair(pair).transferFrom(msg.sender, pair, liquidity), "transferFrom failed"); // send liquidity to pair
        (uint amount0, uint amount1) = IPlanetPair(pair).burn(to);
        (address token0,) = sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'PlanetRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'PlanetRouter: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(IERC20(token), to, amountToken);
        IWBNB(WBNB).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
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
    ) external virtual returns (uint amountA, uint amountB) {
        address pair = pairFor(tokenA, tokenB);
        uint value = approveMax ? type(uint256).max : liquidity;
        IPlanetPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
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
    ) external virtual returns (uint amountToken, uint amountETH) {
        address pair = pairFor(token, WBNB);
        uint value = approveMax ? type(uint256).max : liquidity;
        IPlanetPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
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
    ) public virtual ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(IERC20(token), to, IERC20(token).balanceOf(address(this)));
        IWBNB(WBNB).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual returns (uint amountETH) {
        address pair = pairFor(token, WBNB);
        uint value = approveMax ? type(uint256).max : liquidity;
        IPlanetPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i = 0; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pairFor(output, path[i + 2]) : _to;
            IPlanetPair(pairFor(input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactTokensForTokensThenStableSwap(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path, 
        uint[] calldata stableSwapPoolData,
        address stableSwapPool,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint256 stablesReceived) {
        uint[] memory amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        uint beforeSwapBalance = IPlanetPair(path[path.length - 1]).balanceOf(address(this));

        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        
        uint lastIndex = path.length - 1;

        _swap(amounts, path, address(this)); 

        uint tokensReceived = IPlanetPair(path[lastIndex]).balanceOf(address(this)) - beforeSwapBalance;

        _approveTokenIfNeeded(path[lastIndex], stableSwapPool);
        stablesReceived = IStableSwap(stableSwapPool).exchange(stableSwapPoolData[0], stableSwapPoolData[1], tokensReceived, stableSwapPoolData[2], to);

    }

    function stableSwapExactTokensThenSwapTokensForTokens(
        uint amountIn,
        uint[] calldata stableSwapPoolData,
        address stableSwapPool,
        address[] calldata path, 
        uint amountOutMin,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {

        _approveTokenIfNeeded(IStableSwap(stableSwapPool).get_coins(stableSwapPoolData[0]), stableSwapPool);
        uint256 stablesReceived = IStableSwap(stableSwapPool).exchange(stableSwapPoolData[0], stableSwapPoolData[1], amountIn, stableSwapPoolData[2], address(this));

        amounts = getAmountsOut(stablesReceived, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        
        _swap(amounts, path, to);
    }


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'PlanetRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
 
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WBNB, 'PlanetRouter: INVALID_PATH');
        amounts = getAmountsOut(msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(pairFor(path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapExactETHForTokensThenStableSwap(uint amountOutMin, address[] calldata path,  uint[] calldata stableSwapPoolData,
        address stableSwapPool, address to, uint deadline)
        external
        virtual
        payable
        ensure(deadline)
        returns (uint256 stableReceived)
    {
        require(path[0] == WBNB, 'PlanetRouter: INVALID_PATH');
        uint[] memory amounts = getAmountsOut(msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(pairFor(path[0], path[1]), amounts[0]));
        
        uint lastIndex = path.length - 1;
        uint beforeSwapBalance = IPlanetPair(path[lastIndex]).balanceOf(address(this));
        _swap(amounts, path, address(this));

        uint tokensReceived = IPlanetPair(path[lastIndex]).balanceOf(address(this)) - beforeSwapBalance;

        _approveTokenIfNeeded(path[lastIndex], stableSwapPool);
        stableReceived = IStableSwap(stableSwapPool).exchange(stableSwapPoolData[0], stableSwapPoolData[1], tokensReceived, stableSwapPoolData[2], to);
    }

    function stableSwapExactTokensThenSwapTokensForETH(
        uint amountIn,
        uint[] calldata stableSwapPoolData,
        address stableSwapPool,
        address[] calldata path, 
        uint amountOutMin,
        address to,
        uint deadline)
        external virtual ensure(deadline) returns (uint256 stablesReceived)
    {
        _approveTokenIfNeeded(IStableSwap(stableSwapPool).get_coins(stableSwapPoolData[0]), stableSwapPool);
        stablesReceived = IStableSwap(stableSwapPool).exchange(stableSwapPoolData[0], stableSwapPoolData[1], amountIn, stableSwapPoolData[2], address(this));

        uint[] memory amounts = getAmountsOut(stablesReceived, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        
        // _swap(amounts, path, to);

        _swap(amounts, path, address(this));
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WBNB, 'PlanetRouter: INVALID_PATH');
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'PlanetRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WBNB, 'PlanetRouter: INVALID_PATH');
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WBNB, 'PlanetRouter: INVALID_PATH');
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= msg.value, 'PlanetRouter: EXCESSIVE_INPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(pairFor(path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = sortTokens(input, output);
            IPlanetPair pair = IPlanetPair(pairFor(input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
            amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? pairFor(output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) {
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT'
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
        require(path[0] == WBNB, 'PlanetRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWBNB(WBNB).deposit{value: amountIn}();
        assert(IWBNB(WBNB).transfer(pairFor(path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT'
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
        require(path[path.length - 1] == WBNB, 'PlanetRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            IERC20(path[0]), msg.sender, pairFor(path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WBNB).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

     // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PlanetLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PlanetLibrary: ZERO_ADDRESS');
    }

    function pairFor(address tokenA, address tokenB) internal view returns (address pair) {
        pair = IPlanetFactory(factory).getPair(tokenA, tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address tokenA, address tokenB) public view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPlanetPair(pairFor(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
        require(amountA > 0, 'PlanetLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PlanetLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA * reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal view returns (uint amountOut) {
        require(amountIn > 0, 'PlanetLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PlanetLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn*swapFeeFactor;
        uint numerator = amountInWithFee*reserveOut;
        uint denominator = (reserveIn*10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal view returns (uint amountIn) {
        require(amountOut > 0, 'PlanetLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PlanetLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn*amountOut*10000;
        uint denominator = (reserveOut - amountOut)*swapFeeFactor;
        amountIn = (numerator / denominator) + 1;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PlanetLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i = 0; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn( uint amountOut, address[] memory path) public view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PlanetLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
 
    function _approveTokenIfNeeded(address token, address stablePoolAddress) private {
        if (IERC20(token).allowance(address(this), stablePoolAddress) == 0) {
            IERC20(token).approve(stablePoolAddress, type(uint256).max);
        }
    }
    
    function updateSwapFeeFactor(uint _swapFeeFactor) external {
        require(msg.sender == admin, "only owner");
        require(swapFeeFactorMin <= _swapFeeFactor);
        swapFeeFactor = _swapFeeFactor;
    }

    function changeAdmin(address _newAdmin) external {
        require(msg.sender == admin, "only owner");
        require(_newAdmin != address(0), "can't be 0 address");
        admin = _newAdmin;
    }

    function changeBnbToGammaPath(address[] memory _bnbToGammaPath) external {
        require(msg.sender == admin, "only owner");
        bnbToGammaPath = _bnbToGammaPath;
    }
    

    function swapSolidlyToGamma(
        uint amountIn,
        uint amountOutMin,
        Routes[] calldata route,
        address to,
        uint deadline,
        address solidlyRouterAddress
    ) external virtual ensure(deadline) returns (uint[] memory amounts){
	address fromToken = route[0].from;        
        TransferHelper.safeTransferFrom(
            IERC20(fromToken), msg.sender, address(this), amountIn
        );
        uint len = route.length-1;
        amounts = ISolidlyRouter2(solidlyRouterAddress).getAmountsOut(amountIn, route);


	TransferHelper.safeIncreaseAllowance(
	    IERC20(fromToken),
            solidlyRouterAddress,
            amountIn
        );

        uint balBefore = IERC20(route[len].to).balanceOf(address(this));
        ISolidlyRouter2(solidlyRouterAddress).swapExactTokensForTokens(amountIn, amounts[amounts.length-1], route, address(this), block.timestamp + 300);
        
        uint balAfter =  IERC20(route[len].to).balanceOf(address(this)) - balBefore;
        address[] memory path = bnbToGammaPath;
        amounts = getAmountsOut(balAfter, path);

        require(amounts[amounts.length-1] >= amountOutMin, 'PlanetRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(
            IERC20(path[0]), address(this), pairFor(path[0], path[1]), amounts[0]
        );

        _swap(amounts, path, to);
    }

    function getAmountsOutSolidlyToGamma(uint _amountIn, Routes[] memory _route, address _solidlyRouterAddress) public view returns (uint[] memory amounts){
        
        amounts =  ISolidlyRouter2(_solidlyRouterAddress).getAmountsOut(_amountIn, _route);
        
        _amountIn = amounts[amounts.length - 1];
        amounts = getAmountsOut(_amountIn, bnbToGammaPath);
    }

}