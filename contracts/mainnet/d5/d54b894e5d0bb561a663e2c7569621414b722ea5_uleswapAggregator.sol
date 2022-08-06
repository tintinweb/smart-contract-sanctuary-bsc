/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.6.12;

interface IuleSwapV2Pair {
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

// File: contracts/swap/libraries/SafeMath.sol



pragma solidity 0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMathuleSwap {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// File: contracts/swap/libraries/uleSwapV2Library.sol



pragma solidity 0.6.12;

library uleSwapV2Library {
    using SafeMathuleSwap for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'uleSwapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'uleSwapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'bcaaec8b17fa917541ad04a8a7a9208f151e83fdabc7985bb72a3895a8df7f86' // init code hash
                
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IuleSwapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'uleSwapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'uleSwapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'uleSwapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'uleSwapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'uleSwapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'uleSwapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'uleSwapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'uleSwapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File: contracts/swap/libraries/TransferHelper.sol



pragma solidity 0.6.12;

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

// File: contracts/swap/interfaces/IuleSwapV2Router01.sol



pragma solidity 0.6.12;

interface IuleSwapV2Router01 {
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

// File: contracts/swap/interfaces/IuleSwapV2Router02.sol



pragma solidity 0.6.12;

interface IuleSwapV2Router02 is IuleSwapV2Router01 {
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

// File: contracts/swap/interfaces/IuleSwapV2Factory.sol



pragma solidity 0.6.12;

interface IuleSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
    function PERCENT100() external view returns (uint256);
 
    function pause() external view returns (bool);

    function feeReceiver() external view returns (address);
    function fee() external view returns (uint256);

    

    
}

// File: contracts/swap/interfaces/IERC20.sol



pragma solidity 0.6.12;

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

// File: contracts/swap/interfaces/IWETH.sol



pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts/swap/uleswapAggregator.sol



pragma solidity =0.6.12;







contract uleswapAggregator{

    using SafeMathuleSwap for uint;

    uint256 public constant PERCENT100 = 1000000; 

    IuleSwapV2Router02 public immutable uleRouter;
    IuleSwapV2Factory public immutable uleFactory;

    IuleSwapV2Router02 public immutable sushiRouter;
    IuleSwapV2Factory public immutable sushiFactory;

    address public immutable weth;

    address payable public feeReceiver;
    uint256 public fee = 1000;   

    constructor( address _sushiRouter, address _uleRouter, address payable _feeReceiver) public {
        require( (_sushiRouter != address(0x000)) && (_uleRouter != address(0x000))
             && (_feeReceiver != address(0x000)), "Zero address" );

        uleRouter = IuleSwapV2Router02(_uleRouter);
        sushiRouter = IuleSwapV2Router02(_sushiRouter);
        feeReceiver = _feeReceiver;

        uleFactory = IuleSwapV2Factory(IuleSwapV2Router02(_uleRouter).factory());
        sushiFactory = IuleSwapV2Factory(IuleSwapV2Router02(_sushiRouter).factory());

        weth = IuleSwapV2Router02(_uleRouter).WETH() ;

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
    ) external {
        require((amountADesired > 0) && (amountBDesired>0) ,"Zero amount");
        require((tokenA != address(0x00)) && (tokenB != address(0x00)), "Invalid tokens address");
        
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        if (uleFactory.getPair(tokenA, tokenB) != address(0)) {
            _approve(tokenA, address(uleRouter), amountADesired);
            _approve(tokenB, address(uleRouter), amountBDesired);
            uleRouter.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
        } else if (sushiFactory.getPair(tokenA, tokenB) != address(0)) {
            _approve(tokenA, address(sushiRouter), amountADesired);
            _approve(tokenB, address(sushiRouter), amountBDesired);
            sushiRouter.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
        } else {
            _approve(tokenA, address(uleRouter), amountADesired);
            _approve(tokenB, address(uleRouter), amountBDesired);
            uleRouter.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
        }
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable {
        require((amountTokenDesired > 0) && (msg.value > 0) ,"Zero amount");
        require((token != address(0x00)), "Invalid token address");
        
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);

        if (uleFactory.getPair(token, weth) != address(0)) {
            _approve(token, address(uleRouter), amountTokenDesired);
            uleRouter.addLiquidityETH{value: msg.value}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
        } else if (sushiFactory.getPair(token, weth) != address(0)) {
            _approve(token, address(sushiRouter), amountTokenDesired);
            sushiRouter.addLiquidityETH{value: msg.value}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
        } else {
            _approve(token, address(uleRouter), amountTokenDesired);
            uleRouter.addLiquidityETH{value: msg.value}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
        }
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external {
        require((liquidity > 0) ,"Zero liquidity amount");
        require((tokenA != address(0x00)) && (tokenB != address(0x00)), "Invalid tokens address");
        address pair; 

        if (uleFactory.getPair(tokenA, tokenB) != address(0)) {
            pair = uleFactory.getPair(tokenA, tokenB);
            IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
            _approve(pair, address(uleRouter), liquidity);        
            uleRouter.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        } else if (sushiFactory.getPair(tokenA, tokenB) != address(0)) {
            pair = sushiFactory.getPair(tokenA, tokenB);
            IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
            _approve(pair, address(sushiRouter), liquidity);
            sushiRouter.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        } 
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external {
        require((liquidity > 0), "Zero liquidity amount");
        require((token != address(0x00)), "Invalid tokens address");
        address pair; 

        if (uleFactory.getPair(token, weth) != address(0)) {
            pair = uleFactory.getPair(token, weth);
            IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
            _approve(pair, address(uleRouter), liquidity);        
            uleRouter.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        } else if (sushiFactory.getPair(token, weth) != address(0)) {
            pair = sushiFactory.getPair(token, weth);
            IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
            _approve(pair, address(sushiRouter), liquidity);
            sushiRouter.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        } 
    }

    // swap 
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountIn);        
            uleRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            amountIn  = takeSwapFee(path[0], amountIn, false);
            _approve(path[0], address(sushiRouter), amountIn);        
            sushiRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        }
    }


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
    
        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountInMax);        
            uleRouter.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            takeSwapFee(path[0], amountInMax, false);
            _approve(path[0], address(sushiRouter), amountInMax);        
            sushiRouter.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
        }
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
    {
        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            uleRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            uint256 msgvalue = takeSwapFee(path[0], msg.value, true);
            sushiRouter.swapExactETHForTokens{value: msgvalue}(amountOutMin, path, to, deadline);
        }
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
    
        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountInMax);        
            uleRouter.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            takeSwapFee(path[0], amountInMax, false);
            _approve(path[0], address(sushiRouter), amountInMax);        
            sushiRouter.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
        }
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
        external 
    {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
    
        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountIn);        
            uleRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            amountIn = takeSwapFee(path[0], amountIn, false);
            _approve(path[0], address(sushiRouter), amountIn);        
            sushiRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
        }
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
    {
        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            uleRouter.swapExactETHForTokens{value: msg.value}(amountOut, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            uint256 msgValue = takeSwapFee(path[0], msg.value, true);
            sushiRouter.swapExactETHForTokens{value: msgValue}(amountOut, path, to, deadline);
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountIn);        
            uleRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            amountIn = takeSwapFee(path[0], amountIn, false);
            _approve(path[0], address(sushiRouter), amountIn);        
            sushiRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        payable
    {
       if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            uleRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            uint256 msgvalue = takeSwapFee(path[0], msg.value, true);
            sushiRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msgvalue}(amountOutMin, path, to, deadline);
        }
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
    {
 
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
            _approve(path[0], address(uleRouter), amountIn);        
            uleRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            amountIn = takeSwapFee(path[0], amountIn, false);
            _approve(path[0], address(sushiRouter), amountIn);        
            sushiRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
        }
    }

    // private functions
    function _approve(address _token, address _receiver, uint amount) private {
        IERC20(_token).approve(address(_receiver), amount);
    }

    function takeSwapFee(address _token, uint _amount, bool _isEth) private returns(uint256){
        uint256 _fee = _amount.mul(fee).div(PERCENT100);
        _amount = _amount.sub(_fee); 
        if(!_isEth){
            IERC20(_token).transferFrom(msg.sender, feeReceiver, _fee);
        }else{
            feeReceiver.transfer(_fee);
        }
        return _amount;
    }

    // view functions
    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {

        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
           amounts = uleRouter.getAmountsOut(amountIn, path);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            if(fee != 0){
                uint256 len  = amounts.length.sub(1);
                amounts[len] = amounts[len].sub(amounts[len].mul(fee).div(PERCENT100));
            }
            amounts = sushiRouter.getAmountsOut(amountIn, path);
        }        
        return amounts;
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {

        if (uleFactory.getPair(path[0], path[1]) != address(0)) {
           amounts = uleRouter.getAmountsIn(amountOut, path);
        } else if (sushiFactory.getPair(path[0], path[1]) != address(0)) {
            if(fee != 0){
                amounts[0] = amounts[0].add(amounts[0].mul(fee).div(PERCENT100));
            }
           amounts = sushiRouter.getAmountsIn(amountOut, path);
        }
        return amounts;
    }

}