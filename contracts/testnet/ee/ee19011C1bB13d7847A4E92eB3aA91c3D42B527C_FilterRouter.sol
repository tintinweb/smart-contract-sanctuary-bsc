/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/*
███████╗██╗██╗     ████████╗███████╗██████╗ ███████╗██╗    ██╗ █████╗ ██████╗     ██████╗  ██████╗ ██╗   ██╗████████╗███████╗██████╗ 
██╔════╝██║██║     ╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║    ██║██╔══██╗██╔══██╗    ██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝██╔════╝██╔══██╗
█████╗  ██║██║        ██║   █████╗  ██████╔╝███████╗██║ █╗ ██║███████║██████╔╝    ██████╔╝██║   ██║██║   ██║   ██║   █████╗  ██████╔╝
██╔══╝  ██║██║        ██║   ██╔══╝  ██╔══██╗╚════██║██║███╗██║██╔══██║██╔═══╝     ██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝  ██╔══██╗
██║     ██║███████╗   ██║   ███████╗██║  ██║███████║╚███╔███╔╝██║  ██║██║         ██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗██║  ██║
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝         ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝

SPDX-License-Identifier: UNLICENSED                                                                                                                                     
*/

pragma solidity ^0.8;


interface IFilterFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function balanceOf(address owner) external view returns (uint);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IFilterRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        uint liquidityLockTime
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint liquidityLockTime
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

interface IFilterPair {
    function transferFrom(address from, address to, uint value) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

library FilterLibrary {
    using SafeMath for uint;

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
            hex"a55494cf9cf7a10fdd4956f0b28f1576fad247feb286958b3d1b3a4b7a8b41bc" // init code hash
        )))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IFilterPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "FilterLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, "FilterLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "FilterLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FilterLibrary: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
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

contract FilterRouter is IFilterRouter {
    using SafeMath for uint;

    address public factoryAddr;
    address public deployerAddr;
    address public strainerAddr;
    address public wethAddr;

    address public adminAddr;


    //-------- FILTERSWAP MODS ----------------------

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;

    mapping(address => bool) public isVerifiedSafe;

    uint public minLiquidityLockTime = 1800;

    //----------- END OF CODE -----------------------


    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "FilterRouter: EXPIRED"); _;
    }

    constructor(address _factoryAddr, address _wethAddr, address _adminAddr) {
        factoryAddr = _factoryAddr;
        wethAddr = _wethAddr;
        adminAddr = _adminAddr;
    }

    receive() external payable {
        assert(msg.sender == wethAddr); // only accept ETH via fallback from the WETH contract
    }

    //--------------FILTERSWAP MODS--------------------------

    function getLiquidityUnlockTime(address liquidityProviderAddr, address pairAddr) public view returns (uint) {
        return liquidityUnlockTimes[liquidityProviderAddr][pairAddr];
    }

    function isLiquidityLocked(address liquidityProviderAddr, address pairAddr) public view returns (bool) {
        return block.timestamp < liquidityUnlockTimes[liquidityProviderAddr][pairAddr] ? true : false;
    }

    function imposeLiquidityLock(address userAddr, address pairAddr, uint _liquidityLockTime) internal {
        if (_liquidityLockTime == 0) {
            liquidityUnlockTimes[userAddr][pairAddr] = type(uint).max; //if liquidityLockTime is 0, lock forever
        }

        else if ((block.timestamp + _liquidityLockTime) < liquidityUnlockTimes[userAddr][pairAddr]) {
            revert("FilterRouter: LONGER_LOCKTIME_REQUIRED");
        }

        else {
            require(_liquidityLockTime >= minLiquidityLockTime, "FilterRouter: LOCKTIME_TOO_SHORT");
            liquidityUnlockTimes[userAddr][pairAddr] = block.timestamp + _liquidityLockTime;
        }
    }

    //function getPriceImpact(uint amountOut, uint token1Reserve, uint token2Reserve) private view returns (uint) {
        //do this in future
    //}

    function setVerifiedSafe(address tokenAddr) public {
        require(msg.sender == adminAddr || msg.sender == deployerAddr, "FilterRouter: FORBIDDEN");
        isVerifiedSafe[tokenAddr] = true;
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
        // create the pair if it doesn"t exist yet
        if (IFilterFactory(factoryAddr).getPair(tokenA, tokenB) == address(0)) {
            IFilterFactory(factoryAddr).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = FilterLibrary.getReserves(factoryAddr, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = FilterLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = FilterLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
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
        uint deadline,
        uint liquidityLockTime
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = FilterLibrary.pairFor(factoryAddr, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IFilterPair(pair).mint(to);
        imposeLiquidityLock(to, pair, liquidityLockTime);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint liquidityLockTime
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            wethAddr,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = FilterLibrary.pairFor(factoryAddr, token, wethAddr);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(wethAddr).deposit{value: amountETH}();
        assert(IWETH(wethAddr).transfer(pair, amountETH));
        liquidity = IFilterPair(pair).mint(to);
        imposeLiquidityLock(to, pair, liquidityLockTime);
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
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(factoryAddr, tokenA, tokenB);
        IFilterPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IFilterPair(pair).burn(to);
        (address token0,) = FilterLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            wethAddr,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(wethAddr).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
        require(!isLiquidityLocked(msg.sender, IFilterFactory(factoryAddr).getPair(wethAddr, token)), "FilterRouter: LIQUIDITY_LOCKED");
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
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(factoryAddr, tokenA, tokenB);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = FilterLibrary.pairFor(factoryAddr, token, wethAddr);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            wethAddr,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(wethAddr).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
        require(!isLiquidityLocked(msg.sender, IFilterFactory(factoryAddr).getPair(wethAddr, token)), "FilterRouter: LIQUIDITY_LOCKED");
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = FilterLibrary.pairFor(factoryAddr, token, wethAddr);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = FilterLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(factoryAddr, output, path[i + 2]) : _to;
            IFilterPair(FilterLibrary.pairFor(factoryAddr, input, output)).swap(
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
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsOut(factoryAddr, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsIn(factoryAddr, amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == wethAddr, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(factoryAddr, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(wethAddr).deposit{value: amounts[0]}();
        assert(IWETH(wethAddr).transfer(FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == wethAddr, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(factoryAddr, amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(wethAddr).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == wethAddr, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(factoryAddr, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(wethAddr).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == wethAddr, "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(factoryAddr, amountOut, path);
        require(amounts[0] <= msg.value, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        IWETH(wethAddr).deposit{value: amounts[0]}();
        assert(IWETH(wethAddr).transfer(FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }
    
    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = FilterLibrary.sortTokens(input, output);
            IFilterPair pair = IFilterPair(FilterLibrary.pairFor(factoryAddr, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = FilterLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(factoryAddr, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amountIn);
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,"FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == wethAddr, "FilterRouter: INVALID_PATH");
        uint amountIn = msg.value;
        IWETH(wethAddr).deposit{value: amountIn}();
        assert(IWETH(wethAddr).transfer(FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,"FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
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
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == wethAddr, "FilterRouter: INVALID_PATH");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FilterLibrary.pairFor(factoryAddr, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(wethAddr).balanceOf(address(this));
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(wethAddr).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return FilterLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return FilterLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return FilterLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return FilterLibrary.getAmountsOut(factoryAddr, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return FilterLibrary.getAmountsIn(factoryAddr, amountOut, path);
    }

    // **** ADMIN ONLY FUNCTIONS ****

    function setDeployer(address _deployerAddr) public {
        require(msg.sender == adminAddr, "FilterRouter: FORBIDDEN");
        deployerAddr = _deployerAddr;
    }

    function setStrainer(address _strainerAddr) public {
        require(msg.sender == adminAddr, "FilterRouter: FORBIDDEN");
        strainerAddr = _strainerAddr;
    }
}