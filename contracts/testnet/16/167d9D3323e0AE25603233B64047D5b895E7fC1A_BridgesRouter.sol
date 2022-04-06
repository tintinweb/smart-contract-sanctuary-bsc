pragma solidity =0.6.6;

import './libraries/utils/TransferHelper.sol';
import './interfaces/IBridgesRouter.sol';
import './libraries/BridgesLibrary.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';

contract BridgesRouter is IBridgesRouter{
    using SafeMath for uint;
    address public immutable override factory;
    address public immutable override factoryPCS;
    address public immutable override WETH;
    address public override dividendTracker;
    uint public tradingFee;
    address public feeSetter;
    address public ref;
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }
    constructor(address _factory, address _factoryPCS, address _WETH, address _dividendTracker, address _feeSetter) public {
        factory = _factory;
        factoryPCS = _factoryPCS;
        WETH = _WETH;
        dividendTracker = _dividendTracker;
        tradingFee = 30;
        feeSetter = _feeSetter;

    }
    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function setF(uint _fee) public{
        require(msg.sender == feeSetter && _fee<=50);
        tradingFee = _fee;
    }
    function setFS(address _feeSetter) public{
        require(msg.sender == feeSetter);
        feeSetter = _feeSetter;
    }
    function setR(address _ref) public{
        require(msg.sender == feeSetter);
        ref = _ref;
    }
  
    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address token0,) = BridgesLibrary.sortTokens(path[i], path[i + 1]);
            address dst = i < path.length - 2 ? (gP(path[i + 1], path[i + 2]) != address(0)?gP(path[i + 1], path[i + 2]) : gPP(path[i + 1], path[i + 2])) : _to;
            address isBr = gP(path[i], path[i + 1]);
            (uint amount0Out, uint amount1Out) = path[i] == token0 ? (uint(0), amounts[i + 1]) : (amounts[i + 1], uint(0));
            if (path[i + 1] == WETH && (_f(path[0], msg.sender) && _f(path[path.length - 1], msg.sender)) && path.length > 2){
                isBr!=address(0) ? IBridgesPair(isBr).swap(amount0Out, amount1Out, address(this), new bytes(0)) : IPancakePair(gPP(path[i], path[i + 1])).swap(amount0Out, amount1Out, address(this), new bytes(0));
                assert(IWETH(WETH).transfer(dst, amounts[i+1].mul(1000-tradingFee).div(1000)));
                for (uint j = i+1; j < path.length; j++ ){
                    amounts[j] = amounts[j].mul(1000-tradingFee).div(1000);
                } 
            }else{
                isBr!=address(0) ? IBridgesPair(isBr).swap(amount0Out, amount1Out, dst, new bytes(0)) : IPancakePair(gPP(path[i], path[i + 1])).swap(amount0Out, amount1Out, dst, new bytes(0));           
            }                    
        }
    }
      
   function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'OUTPUT_AMOUNT');
        _t1(path, amounts[0]);
        _swap(amounts, path, to);       
        uint bal = IERC20(WETH).balanceOf(address(this));
        if (bal>0){
            IBridgesRef(ref).distribute(msg.sender, bal);
            IWETH(WETH).withdraw(bal);
            TransferHelper.safeTransferBNB(dividendTracker,bal);
        }
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'INPUT_AMOUNT');
        _t1(path, amounts[0]);
        _swap(amounts, path, to);
        uint bal = IERC20(WETH).balanceOf(address(this));
        if (bal>0){
            IBridgesRef(ref).distribute(msg.sender, bal);
            IWETH(WETH).withdraw(bal);
            TransferHelper.safeTransferBNB(dividendTracker,bal);
        }
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {   
        require(path[0] == WETH, 'PATH');
        uint amountIn = msg.value;
        if (_f(path[1], msg.sender)) {
            TransferHelper.safeTransferBNB(dividendTracker, amountIn.mul(tradingFee).div(1000));
            amountIn = amountIn.mul(1000 - tradingFee).div(1000);
            IBridgesRef(ref).distribute(msg.sender, amountIn.mul(tradingFee).div(1000));
        }
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(gP(path[0], path[1]) != address(0) ? gP(path[0], path[1]) : gPP(path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {     
        require(path[path.length - 1] == WETH, 'PATH');
        amounts = getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, 'AMOUNT');
        _t1(path, amounts[0]);
        _swap(amounts, path, address(this));
        uint _out = amounts[amounts.length - 1];
        IWETH(WETH).withdraw(_out);
        if (_f(path[0], msg.sender)) {
            TransferHelper.safeTransferBNB(dividendTracker, _out.mul(tradingFee).div(1000));
            _out = _out.mul(1000 - tradingFee).div(1000);
            IBridgesRef(ref).distribute(msg.sender, _out.mul(tradingFee).div(1000));

        }
        TransferHelper.safeTransferBNB(to, _out);

    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'PATH');
        amounts = getAmountsOut(amountIn, path);
        uint _out = amounts[amounts.length - 1];
        require(_out >= amountOutMin, 'OUTPUT_AMOUNT');
        _t1(path, amounts[0]);
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(_out);

        if (_f(path[0], msg.sender)){
            _out = _out.mul(1000 - tradingFee).div(1000);
            TransferHelper.safeTransferBNB(dividendTracker, _out.mul(tradingFee).div(1000));
            IBridgesRef(ref).distribute(msg.sender, _out.mul(tradingFee).div(1000));
        }
        TransferHelper.safeTransferBNB(to, _out);
    }
      
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {   
        require(path[0] == WETH, 'PATH');
        if (_f(path[1], msg.sender)) {
            TransferHelper.safeTransferBNB(dividendTracker, msg.value.mul(tradingFee).div(1000));
            amountOut= amountOut.mul(1000-tradingFee).div(1000);
            IBridgesRef(ref).distribute(msg.sender, amountOut.mul(tradingFee).div(1000));
        }
        amounts = getAmountsIn( amountOut, path);
        //require(amounts[0] <= msg.value, 'BridgesRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(gP(path[0], path[1]) != address(0) ? gP(path[0], path[1]) : gPP(path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);    
    }
// **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {        
        for (uint i; i < path.length - 1; i++) {
            (address token0,) = BridgesLibrary.sortTokens(path[i], path[i + 1]);
            address dst = i < path.length - 2 ? (gP(path[i + 1], path[i + 2]) != address(0)?gP(path[i + 1], path[i + 2]) : gPP(path[i + 1], path[i + 2])) : _to;
            address isBr = gP(path[i], path[i + 1]);
            IBridgesPair pair = IBridgesPair(gP(path[i], path[i + 1]));
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = isBr!=address(0) ? IBridgesPair(isBr).getReserves() : IPancakePair(gPP(path[i], path[i + 1])).getReserves();
            (uint reserveInput, uint reserveOutput) = path[i] == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountOutput = getAmountOut(IERC20(path[i]).balanceOf(address(pair)).sub(reserveInput), reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = path[i] == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            if (path[i + 1] == WETH && (_f(path[0], msg.sender) && _f(path[path.length - 1], msg.sender)) && path.length > 2){
                isBr!=address(0) ? IBridgesPair(isBr).swap(amount0Out, amount1Out, address(this), new bytes(0)) : IPancakePair(gPP(path[i], path[i + 1])).swap(amount0Out, amount1Out, address(this), new bytes(0));
                assert(IWETH(WETH).transfer(dst, IERC20(WETH).balanceOf(address(this)).mul(1000-tradingFee).div(1000)));
            }else{            
                isBr!=address(0) ? IBridgesPair(isBr).swap(amount0Out, amount1Out, dst, new bytes(0)) : IPancakePair(gPP(path[i], path[i + 1])).swap(amount0Out, amount1Out, dst, new bytes(0));
            }                       
        }
    }
    

function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        _t1(path, amountIn);
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'OUTPUT_AMOUNT'
        );
        uint bal = IERC20(WETH).balanceOf(address(this));
        if (bal>0){
            IWETH(WETH).withdraw(bal);
            TransferHelper.safeTransferBNB(dividendTracker,bal);
            IBridgesRef(ref).distribute(msg.sender, bal);        
        }
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
        require(path[0] == WETH, 'PATH');
        uint amountIn = msg.value;
        if (_f(path[1], msg.sender)) {
            TransferHelper.safeTransferBNB(dividendTracker, amountIn.mul(tradingFee).div(1000));
            amountIn = amountIn.mul(1000 - tradingFee).div(1000);
            IBridgesRef(ref).distribute(msg.sender, amountIn.mul(tradingFee).div(1000));        
        }
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(gP(path[0], path[1]) != address(0) ? gP(path[0], path[1]) : gPP(path[0], path[1]), amountIn));     
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'OUTPUT_AMOUNT'
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
        override
        ensure(deadline)
    {   
        require(path[path.length - 1] == WETH, 'INVALID_PATH');
        _t1(path, amountIn);
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        if (_f(path[0], msg.sender)){
            amountOut = amountOut.mul(1000 - tradingFee).div(1000);
            TransferHelper.safeTransferBNB(dividendTracker, amountOut.mul(tradingFee).div(1000));
            IBridgesRef(ref).distribute(msg.sender, amountOut.mul(tradingFee).div(1000));        
        }
        TransferHelper.safeTransferBNB(to, amountOut);
    }
 // **** ADD LIQUIDITY ****
    function _a(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (gP(tokenA, tokenB) == address(0)) {
            IBridgesFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = BridgesLibrary.getReservesLiq(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'A_AMOUNT');
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
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _a(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = gP(tokenA,tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IBridgesPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _a(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = gP(token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IBridgesPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferBNB(msg.sender, msg.value - amountETH);
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
        IBridgesPair(gP(tokenA, tokenB)).transferFrom(msg.sender, gP(tokenA, tokenB), liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IBridgesPair(gP(tokenA, tokenB)).burn(to);
        (address token0,) = BridgesLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'A_AMOUNT');
        require(amountB >= amountBMin, 'B_AMOUNT');
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
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferBNB(to, amountETH);
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
        uint value = approveMax ? uint(-1) : liquidity;
        IBridgesPair(gP(tokenA, tokenB)).permit(msg.sender, address(this), value, deadline, v, r, s);
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
    ) external virtual override returns (uint amountToken, uint amountETH) {
        uint value = approveMax ? uint(-1) : liquidity;
        IBridgesPair(gP(token, WETH)).permit(msg.sender, address(this), value, deadline, v, r, s);
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
    ) public virtual override ensure(deadline) returns (uint amountETH) {
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
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferBNB(to, amountETH);
    }
        function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
            address t,
            uint l,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint d,
            bool a, uint8 v, bytes32 r, bytes32 s
        ) external virtual override returns (uint amountETH) {
            uint value = a ? uint(-1) : l;
            IBridgesPair(gP(t, WETH)).permit(msg.sender, address(this), value, d, v, r, s);
            amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
                t, l, amountTokenMin, amountETHMin, to, d
            );
        }
    function gP(address beg, address end) internal view virtual returns(address){
        return IBridgesFactory(factory).getPair(beg,end);
    }
    function gPP(address beg, address end) internal view virtual returns(address){
        return IPancakeFactory(factoryPCS).getPair(beg,end);
    }
    function quote(uint a, uint rA, uint rB) public pure virtual override returns (uint amountB) {
        return BridgesLibrary.quote(a, rA, rB);
    }

    function getAmountOut(uint a, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return BridgesLibrary.getAmountOut(a, reserveIn, reserveOut);
    }

    function getAmountIn(uint a, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return BridgesLibrary.getAmountIn(a, reserveIn, reserveOut);
    }

    function getAmountsOut(uint a, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BridgesLibrary.getAmountsOut(factory, factoryPCS, a, path);
    }

    function getAmountsIn(uint a, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BridgesLibrary.getAmountsOut(factory, factoryPCS, a, path);
    }
    function _f(address token, address sender) internal view returns(bool fee){
        fee = IBridgesRef(ref).feeOn(token, sender);
    }
    function _t1(address[] memory path, uint amount) internal {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, gP(path[0], path[1]) != address(0) ? gP(path[0], path[1]) : gPP(path[0], path[1]), amount
        );
    }

}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

pragma solidity >=0.6.2;
interface IBridgesRouter {
    function factory() external pure returns (address);
    function factoryPCS() external pure returns (address);
    function WETH() external pure returns (address);
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
    )external payable;
   function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
    function dividendTracker() external pure returns(address);
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
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);   
}

pragma solidity >=0.5.0;

import '../interfaces/IBridgesPair.sol';
import '../interfaces/IPancakePair.sol';
import '../interfaces/IBridgesFactory.sol';
import '../interfaces/IPancakeFactory.sol';
import '../interfaces/IBridgesRef.sol';
import "./SafeMath.sol";

library BridgesLibrary {
    using SafeMath for uint;
    
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, '  EXPIRED');
        _;
    }
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'BridgesLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'BridgesLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'a6c986da60c79faa6894f8bff479b079b847440de4b86249d8f99d9ef675b2ed' // init code hash
            ))));
    }
    function pairForPCS(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address factoryPCS,  address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair = IBridgesFactory(factory).getPair(tokenA, tokenB);
        uint reserve0;
        uint reserve1;
        if (pair != address(0)){
            (reserve0, reserve1,) = IBridgesPair(pairFor(factory, tokenA, tokenB)).getReserves();
        }else{
            (reserve0, reserve1,) = IPancakePair(pairForPCS(factoryPCS, tokenA, tokenB)).getReserves();
        }
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    function getReservesLiq(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        uint reserve0;
        uint reserve1;
        (reserve0, reserve1,) = IBridgesPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BridgesLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BridgesLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BridgesLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, address factoryPCS, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BridgesLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, factoryPCS, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, address factoryPCS, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BridgesLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, factoryPCS, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

}

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint x, uint y) internal pure returns (uint z) {
        assert(y > 0); // Solidity automatically throws when dividing by 0
        z = x / y;
        assert(x == y * z + x % y); // There is no case in which this doesn't hold
    }
}

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity >=0.5.0;

interface IBridgesPair {
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
    function initialize(address, address, uint) external;
    function distributeDividends(uint) external payable;
    function withdraw() external;
    function availableRewards() external view returns(uint, uint);
}

pragma solidity >=0.5.0;

interface IPancakePair {
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

interface IBridgesFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function tradingStart() external view returns(uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setTradingStart(uint) external;
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IPancakeFactory {
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

pragma solidity >=0.6.2;
interface IBridgesRef {
    function feeOn(address, address) external view returns (bool fee);
    function withelistToken(address, bool) external;
    function withelistUser(address, bool) external;
    function withelistUsers(address[] calldata, bool) external;
    function setFeeToSetter(address) external;
    function distribute(address, uint) external;

}