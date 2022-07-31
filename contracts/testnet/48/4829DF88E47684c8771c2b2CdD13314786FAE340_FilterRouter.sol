/**
 *Submitted for verification at BscScan.com on 2022-07-30
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

interface IFilterManager {
    function factoryAddress() external view returns (address);
    function strainerAddress() external view returns (address);
    function wethAddress() external view returns (address);
    function getLiquidityUnlockTime(address, address) external view returns (uint);
    function setLiquidityUnlockTime(address, address, uint) external;
    function isVerifiedSafe(address) external view returns (bool);
    function isFlaggedAsScam() external view returns (bool);
    function setFlaggedAsScam(address) external;
    function minLiquidityLockTime() external view returns (uint);
}

interface IFilterFactory {
    function getPair(address, address) external view returns (address pair);
    function createPair(address, address) external returns (address pair);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address, uint) external returns (bool);
    function withdraw(uint) external;
}

interface IFilterRouter {
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint, uint) external returns (uint, uint, uint);
    function addLiquidityETH(address, uint, uint, uint, address, uint, uint) external payable returns (uint, uint, uint);
    function removeLiquidity(address, address, uint, uint, uint, address, uint) external returns (uint, uint);
    function removeLiquidityETH(address, uint, uint, uint, address, uint) external returns (uint, uint);
    function removeLiquidityWithPermit(address, address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external returns (uint, uint);
    function removeLiquidityETHWithPermit(address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external returns (uint, uint);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address, uint, uint, uint, address, uint) external returns (uint);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external returns (uint);
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function swapTokensForExactTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
    function swapTokensForExactETH(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function swapExactTokensForETH(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function swapETHForExactTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint, uint, address[] calldata, address, uint) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint, address[] calldata, address, uint) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint, uint, address[] calldata, address, uint) external;  
    function quote(uint, uint, uint) external pure returns (uint);
    function getAmountOut(uint, uint, uint) external pure returns (uint);
    function getAmountIn(uint, uint, uint) external pure returns (uint);
    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory);
    function getAmountsIn(uint, address[] calldata) external view returns (uint[] memory);
}

interface IFilterPair {
    function transferFrom(address, address, uint) external returns (bool);
    function permit(address, address, uint, uint, uint8, bytes32, bytes32) external;
    function getReserves() external view returns (uint112, uint112, uint32);
    function mint(address) external returns (uint);
    function burn(address) external returns (uint, uint);
    function swap(uint, uint, address, bytes calldata) external;
}

interface IFilterStrainer {
    function isFlaggedAsScam(address) external view returns (bool);
    function registerAddLiquidity(address, uint) external;
    function registerRemoveLiquidity(address, uint) external;
    function registerBuy(address, address, uint) external;
    function registerSell(address, address, uint) external;
    function pairBaseToken(address) external view returns (address);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        require(IERC20(token).approve(to, value), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        require(IERC20(token).transfer(to, value), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        require(IERC20(token).transferFrom(from, to, value), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        payable(to).transfer(value);
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
            hex"e8029d8287754727c5f63ed35703f84e53c2323846b6d2e3e8cf478114408343"
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

    IFilterManager filterManager;

    // **** CONSTRUCTOR, FALLBACK & MODIFIER FUNCTIONS ****

    constructor(address _managerAddress) {
        filterManager = IFilterManager(_managerAddress);
    }

    receive() external payable {
        assert(msg.sender == filterManager.wethAddress());
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "FilterRouter: EXPIRED"); 
        _;
    }

    // **** LIQUIDITY LOCK FUNCTIONS ****

    function isLiquidityLocked(address _liquidityProviderAddress, address _pairAddress) public view returns (bool) {
        return block.timestamp < filterManager.getLiquidityUnlockTime(_liquidityProviderAddress, _pairAddress) ? true : false;
    }

    function isVerifiedSafe(address _tokenAddress) public view returns (bool) {
        return filterManager.isVerifiedSafe(_tokenAddress);
    }

    function imposeLiquidityLock(address _userAddress, address _pairAddress, uint _liquidityLockTime) internal {
        require(_liquidityLockTime >= filterManager.minLiquidityLockTime(), "FilterRouter: LOCKTIME_TOO_SHORT");

        if (filterManager.getLiquidityUnlockTime(_userAddress, _pairAddress) == 0) { //never set before
            filterManager.setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }

        else if (filterManager.getLiquidityUnlockTime(_userAddress, _pairAddress) < block.timestamp) { //was set long ago but expired
            filterManager.setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }

        //else {} //active lockTime already set, do nothing
    }

    // **** STRAINER FUNCTIONS ****

    function registerAddLiquidity(address _tokenA, address _tokenB, uint _amountA, uint _amountB, address _pair) internal {
        if(!isVerifiedSafe(_tokenA) || !isVerifiedSafe(_tokenB)) {    
            uint tokenAmount = isVerifiedSafe(_tokenA) ? _amountA : _amountB;
            IFilterStrainer(filterManager.strainerAddress()).registerAddLiquidity(_pair, tokenAmount);
        }
    }

    function registerAddLiquidityETH(address _token, uint _amountToken) internal {
        if(!isVerifiedSafe(_token)) {
            address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), _token, filterManager.wethAddress());
            IFilterStrainer(filterManager.strainerAddress()).registerAddLiquidity(pair, _amountToken);
        }
    }

    function registerRemoveLiquidity(address _tokenA, address _tokenB, uint _amountA, uint _amountB, address _pair) internal {
        if(!isVerifiedSafe(_tokenA) || !isVerifiedSafe(_tokenB)) {    
            uint tokenAmount = isVerifiedSafe(_tokenA) ? _amountA : _amountB;
            IFilterStrainer(filterManager.strainerAddress()).registerRemoveLiquidity(_pair, tokenAmount);
        }
    }

    function registerRemoveLiquidityETH(address _token, uint _amountToken) internal {
        if(!isVerifiedSafe(_token)) {
            address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), _token, filterManager.wethAddress());
            IFilterStrainer(filterManager.strainerAddress()).registerRemoveLiquidity(pair, _amountToken);
        }
    }

    function registerSwap(address[] calldata _path, uint[] memory _amountsOut) internal {

        // firstToken -> lastToken
        // but what about firstToken -> ETH -> lastToken? ie. firstToken / lastToken pair doesnt exist
        for(uint i = 0; i < _path.length - 1; i++) {
            address token0 = _path[i];
            address token1 = _path[i + 1];

            address tokenPair = FilterLibrary.pairFor(filterManager.factoryAddress(), token0, token1);

            address baseToken = IFilterStrainer(filterManager.strainerAddress()).pairBaseToken(tokenPair);

            if (!isVerifiedSafe(_path[i])) {
                if (baseToken == token0) { //buy
                    IFilterStrainer(filterManager.strainerAddress()).registerBuy(msg.sender, tokenPair, _amountsOut[i]);
                }

                else { //sell
                    IFilterStrainer(filterManager.strainerAddress()).registerSell(msg.sender, tokenPair, _amountsOut[i]);
                }
            }
        }

        

    }

    // **** ADD LIQUIDITY FUNCTIONS ****

    function _addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin) internal virtual returns (uint amountA, uint amountB) {
        if (IFilterFactory(filterManager.factoryAddress()).getPair(tokenA, tokenB) == address(0)) {
            IFilterFactory(filterManager.factoryAddress()).createPair(tokenA, tokenB);
        }

        (uint reserveA, uint reserveB) = FilterLibrary.getReserves(filterManager.factoryAddress(), tokenA, tokenB);

        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } 
        
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

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline, uint liquidityLockTime) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        require(isVerifiedSafe(tokenA) || isVerifiedSafe(tokenB), "FilterRouter: UNVERIFIED_BASE_TOKEN");
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IFilterPair(pair).mint(to);
        imposeLiquidityLock(to, pair, liquidityLockTime);

        if(!isVerifiedSafe(tokenA) || !isVerifiedSafe(tokenB)) {
            uint tokenAmount = isVerifiedSafe(tokenA) ? amountA : amountB;
            IFilterStrainer(filterManager.strainerAddress()).registerAddLiquidity(pair, tokenAmount);
        }
    }

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline, uint liquidityLockTime) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(token, filterManager.wethAddress(), amountTokenDesired, msg.value, amountTokenMin, amountETHMin);
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, filterManager.wethAddress());
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(filterManager.wethAddress()).deposit{value: amountETH}();
        assert(IWETH(filterManager.wethAddress()).transfer(pair, amountETH));
        liquidity = IFilterPair(pair).mint(to);
        imposeLiquidityLock(to, pair, liquidityLockTime);

        if (msg.value > amountETH) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        }

        registerAddLiquidityETH(token, amountToken);
    }

    // **** REMOVE LIQUIDITY FUNCTIONS ****

    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) 
        public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        IFilterPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IFilterPair(pair).burn(to);
        (address token0, ) = FilterLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "FilterRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "FilterRouter: INSUFFICIENT_B_AMOUNT");
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
        registerRemoveLiquidity(tokenA, tokenB, amountA, amountB, pair);
    }

    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(token, filterManager.wethAddress(), liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(filterManager.wethAddress()).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);

        require(!isLiquidityLocked(msg.sender, IFilterFactory(filterManager.factoryAddress()).getPair(filterManager.wethAddress(), token)), "FilterRouter: LIQUIDITY_LOCKED");
        registerRemoveLiquidityETH(token, amountToken);
    }

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external virtual override returns (uint amountA, uint amountB) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), tokenA, tokenB);
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
        registerRemoveLiquidity(tokenA, tokenB, amountA, amountB, pair);    
    }

    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, filterManager.wethAddress());
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
        require(!isLiquidityLocked(msg.sender, pair), "FilterRouter: LIQUIDITY_LOCKED");
        registerRemoveLiquidityETH(token, amountToken);
    }

    // **** REMOVE LIQUIDITY FUNCTIONS (supporting fee-on-transfer tokens) ****

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) public virtual override ensure(deadline) returns (uint amountETH) {
        uint amountToken;
        (amountToken, amountETH) = removeLiquidity(token, filterManager.wethAddress(), liquidity, amountTokenMin, amountETHMin, address(this), deadline);

        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(filterManager.wethAddress()).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);

        require(!isLiquidityLocked(msg.sender, IFilterFactory(filterManager.factoryAddress()).getPair(filterManager.wethAddress(), token)), "FilterRouter: LIQUIDITY_LOCKED");
        registerRemoveLiquidityETH(token, amountToken);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external virtual override returns (uint amountETH) {
        address pair = FilterLibrary.pairFor(filterManager.factoryAddress(), token, filterManager.wethAddress());
        uint value = approveMax ? type(uint).max : liquidity;
        IFilterPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** SWAP FUNCTIONS ****

    function swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FilterLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(filterManager.factoryAddress(), output, path[i + 2]) : _to;
            IFilterPair(FilterLibrary.pairFor(filterManager.factoryAddress(), input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, to);
        registerSwap(path, amounts);
    }

    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, to);
        registerSwap(path, amounts);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(filterManager.wethAddress()).deposit{value: amounts[0]}();
        assert(IWETH(filterManager.wethAddress()).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]));
        swap(amounts, path, to);
        registerSwap(path, amounts);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= amountInMax, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, address(this));
        IWETH(filterManager.wethAddress()).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        registerSwap(path, amounts);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]);
        swap(amounts, path, address(this));
        IWETH(filterManager.wethAddress()).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        registerSwap(path, amounts);
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        amounts = FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
        require(amounts[0] <= msg.value, "FilterRouter: EXCESSIVE_INPUT_AMOUNT");
        IWETH(filterManager.wethAddress()).deposit{value: amounts[0]}();
        assert(IWETH(filterManager.wethAddress()).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amounts[0]));
        swap(amounts, path, to);

        if (msg.value > amounts[0]) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
        }

        registerSwap(path, amounts);
    }
    
    // **** SWAP FUNCTIONS (supporting fee-on-transfer tokens) ****

    function swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual returns (uint[] memory amounts) {
        amounts = new uint[](path.length - 1);
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = FilterLibrary.sortTokens(input, output);
            IFilterPair pair = IFilterPair(FilterLibrary.pairFor(filterManager.factoryAddress(), input, output));
            uint amountInput;
            uint amountOutput;
            {
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = FilterLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }

            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? FilterLibrary.pairFor(filterManager.factoryAddress(), output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
            amounts[i] = amountOutput;
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        uint[] memory amounts = swapSupportingFeeOnTransferTokens(path, to);
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore);
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        registerSwap(path, amounts);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override payable ensure(deadline) {
        require(path[0] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        uint amountIn = msg.value;
        IWETH(filterManager.wethAddress()).deposit{value: amountIn}();
        assert(IWETH(filterManager.wethAddress()).transfer(FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        uint[] memory amounts = swapSupportingFeeOnTransferTokens(path, to);
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore);
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        registerSwap(path, amounts);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) {
        require(path[path.length - 1] == filterManager.wethAddress(), "FilterRouter: INVALID_PATH");
        TransferHelper.safeTransferFrom(path[0], msg.sender, FilterLibrary.pairFor(filterManager.factoryAddress(), path[0], path[1]), amountIn);
        uint[] memory amounts = swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(filterManager.wethAddress()).balanceOf(address(this));
        require(amountOut >= amountOutMin, "FilterRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(filterManager.wethAddress()).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
        registerSwap(path, amounts);
    }

    // **** LIBRARY FUNCTIONS ****

    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return FilterLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure virtual override returns (uint amountOut) {
        return FilterLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public pure virtual override returns (uint amountIn) {
        return FilterLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view virtual override returns (uint[] memory amounts) {
        return FilterLibrary.getAmountsOut(filterManager.factoryAddress(), amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view virtual override returns (uint[] memory amounts) {
        return FilterLibrary.getAmountsIn(filterManager.factoryAddress(), amountOut, path);
    }
}