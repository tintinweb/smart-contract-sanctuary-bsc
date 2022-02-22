/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// SPDX-License-Identifier: MIXED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IUniswapV1Pair {
    function swap(uint amount0Out, uint amount1Out, address to) external;
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

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
}

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

contract pairhelp {
    using SafeMath for uint256;
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getProfit(uint amountIn, address baseToken,address pair0,address pair1) external view returns (uint amountOut) {
        address token00 = IUniswapV2Pair(pair0).token0();
        address token01 = IUniswapV2Pair(pair0).token1();
        (uint256 reserve00,uint256 reserve01,) = IUniswapV2Pair(pair0).getReserves();
        address token10 = IUniswapV2Pair(pair1).token0();
        address token11 = IUniswapV2Pair(pair1).token1();
        (uint256 reserve10,uint256 reserve11,) = IUniswapV2Pair(pair1).getReserves();
        address quoteToken;
        uint256 quoteOut;
        if(baseToken==token00){
            quoteToken = token01;
            quoteOut=getAmountOut(amountIn,reserve00,reserve01);
        }else if(baseToken==token01){
            quoteToken = token00;
            quoteOut=getAmountOut(amountIn,reserve01,reserve00);
        }else{
            revert("xx0");
        }
        if(quoteToken==token10 && baseToken == token11){
            amountOut = getAmountOut(quoteOut,reserve10,reserve11);
        }else if(quoteToken==token11 && baseToken == token10){
            amountOut = getAmountOut(quoteOut,reserve11,reserve10);
        }else{
            revert("xx1");
        }
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 9970;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn*10000+amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountOut2(uint amountIn, uint reserveIn, uint reserveOut,uint32 fee) public pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * fee;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn*100000+amountInWithFee;
        amountOut = numerator / denominator;
    }    

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn*amountOut*10000;
        uint denominator = (reserveOut-amountOut)*9970;
        amountIn = (numerator / denominator)+1;
    }

    function getAmountIn2(uint amountOut, uint reserveIn, uint reserveOut,uint32 fee) public pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn*amountOut*10000;
        uint denominator = (reserveOut-amountOut)*fee;
        amountIn = (numerator / denominator)+1;
    }

    function getFactoryPairInfo3(address factory,uint256 inx) external view returns(address pair,uint32 size,  address token0,address token1, int256 balance0,int256 balance1, int256 reserve0, int256 reserve1){
        pair = IPancakeFactory(factory).allPairs(inx);
        size = uint32(IPancakeFactory(factory).allPairsLength());
        token0 = IUniswapV2Pair(pair).token0();
        token1 = IUniswapV2Pair(pair).token1();
        balance0 = -1;
        balance1 = -1;
        reserve0 = -1;
        reserve1 = -1;
    }

    function getFactoryPairInfo2(address factory,uint256 inx) external view returns(address pair,uint32 size,  address token0,address token1, int256 balance0,int256 balance1, uint112 reserve0, uint112 reserve1){
        pair = IPancakeFactory(factory).allPairs(inx);
        size = uint32(IPancakeFactory(factory).allPairsLength());
        token0 = IUniswapV2Pair(pair).token0();
        token1 = IUniswapV2Pair(pair).token1();
        balance0 = -1;
        balance1 = -1;
        (reserve0,reserve1,) = IUniswapV2Pair(pair).getReserves();
    }

    function getFactoryPairInfo(address factory,uint256 inx) external view returns(address pair,uint32 size,  address token0,address token1, uint256 balance0,uint256 balance1, uint112 reserve0, uint112 reserve1){
        pair = IPancakeFactory(factory).allPairs(inx);
        size = uint32(IPancakeFactory(factory).allPairsLength());
        token0 = IUniswapV2Pair(pair).token0();
        token1 = IUniswapV2Pair(pair).token1();
        balance0 = IERC20(token0).balanceOf(pair);
        balance1 = IERC20(token1).balanceOf(pair);
        (reserve0,reserve1,) = IUniswapV2Pair(pair).getReserves();
    }

    function getPairInfo(address pair) external view returns(uint256 balance0,uint256 balance1, uint112 reserve0, uint112 reserve1){
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        balance0 = IERC20(token0).balanceOf(pair);
        balance1 = IERC20(token1).balanceOf(pair);
        (reserve0,reserve1,) = IUniswapV2Pair(pair).getReserves();
    }

    function pairReserves(address[] calldata pairs) public view returns(uint256[] memory reserves) {
        reserves = new uint[](2*pairs.length);
        for(uint i=0;i<pairs.length;i++){
            (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pairs[i]).getReserves();
            reserves[2*i]=reserve0;
            reserves[2*i+1]=reserve1;
        }
    }

    function pathReserves(
        address router,
        address[] calldata path) public view returns(address[] memory pairs,uint[] memory reserves){
        pairs = new address[](path.length-1);    
        reserves = new uint[](2*pairs.length);
        for(uint i = 0;i<path.length-1;i++){
            address a0=path[i];
            address a1=path[i+1];
            pairs[i] = IPancakeFactory(IUniswapV2Pair(router).factory()).getPair(a0,a1);
            (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pairs[i]).getReserves();
            reserves[2*i]=reserve0;
            reserves[2*i+1]=reserve1;
        }
    }

    function swapExactIn(
        address router,
        uint amountIn,
        address[] calldata path) public view returns(address[] memory pairs,uint[] memory reserves){
        pairs = new address[](path.length-1);    
        reserves = new uint[](2*pairs.length);
        uint tmpAmtIn=amountIn;
        for(uint i = 0;i<path.length-1;i++){
            address a0=path[i];
            address a1=path[i+1];
            pairs[i] = IPancakeFactory(IUniswapV2Pair(router).factory()).getPair(a0,a1);
            (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairs[i]).getReserves();
            address token0 = IUniswapV2Pair(pairs[i]).token0();
            //address token1 = IUniswapV2Pair(pairs[i]).token1();
            if(a0==token0){
                uint tmpAmtOut = getAmountOut(tmpAmtIn, reserve0, reserve1);
                reserve0 = reserve0.add(tmpAmtIn);
                reserve1 = reserve1.sub(tmpAmtOut);
                tmpAmtIn = tmpAmtOut;
            }else{
                uint tmpAmtOut = getAmountOut(tmpAmtIn, reserve1, reserve0);
                reserve0 = reserve0-tmpAmtOut;
                reserve1 = reserve1+tmpAmtIn;
                tmpAmtIn = tmpAmtOut;
            }
            reserves[2*i]=reserve0;
            reserves[2*i+1]=reserve1;
        }
    }    

    function swapExactOut(
        address router,
        uint amountOut,
        address[] calldata path) public view returns(address[] memory pairs,uint[] memory reserves){
        pairs = new address[](path.length-1);    
        reserves = new uint[](2*pairs.length);
        uint tmpAmtOut=amountOut;
        for(uint j = 0;j<path.length-1;j++){
            uint i=path.length-2-j;
            address a0=path[i];
            address a1=path[i+1];
            pairs[i] = IPancakeFactory(IUniswapV2Pair(router).factory()).getPair(a0,a1);
            (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairs[i]).getReserves();
            address token0 = IUniswapV2Pair(pairs[i]).token0();
            //address token1 = IUniswapV2Pair(pairs[i]).token1();
            if(a0==token0){
                uint tmpAmtIn = getAmountIn(tmpAmtOut, reserve0, reserve1);
                reserve0 = reserve0+tmpAmtIn;
                reserve1 = reserve1-tmpAmtOut;
                tmpAmtOut = tmpAmtIn;
            }else{
                uint tmpAmtIn = getAmountOut(tmpAmtOut, reserve1, reserve0);
                reserve0 = reserve0-tmpAmtOut;
                reserve1 = reserve1+tmpAmtIn;
                tmpAmtOut = tmpAmtIn;
            }
            reserves[2*i]=reserve0;
            reserves[2*i+1]=reserve1;
        }
    }    

    function swap(
        address baseToken,
        uint256 amountIn,
        uint256 profit,
        address[] calldata pairs,
        uint32[] calldata fees,
        address to) public onlyOwner{
        uint256 balanceBefore = IERC20(baseToken).balanceOf(to);
        TransferHelper.safeTransferFrom(
            baseToken, msg.sender, pairs[0], amountIn
        );
         _swapSupportingFeeOnTransferTokens(baseToken,pairs,fees, to);
        if(profit>0){
            require(
                IERC20(baseToken).balanceOf(to).sub(balanceBefore) >= profit,
                'Router: INSUFFICIENT_OUTPUT_AMOUNT'
            );
        }
    } 

    function _swapSupportingFeeOnTransferTokens(address input, address[] memory pairs,uint32[] memory fees,  address _to) internal virtual {
        for (uint i; i < pairs.length; i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(pairs[i]);
            address output;
            address token0 = pair.token0();
            if(pair.token0()==input){
                output=pair.token1();
            }else if(pair.token1()==input){
                output=pair.token0();
            }else{
                return;
            }

            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = getAmountOut2(amountInput, reserveInput, reserveOutput,fees[i]);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < pairs.length-1 ? pairs[i+1] : _to;

            try pair.swap(amount0Out, amount1Out, to, new bytes(0)){

            }catch{
                IUniswapV1Pair(pairs[i]).swap(amount0Out,amount1Out,to);
            }
            input = output;
        }
    }
}