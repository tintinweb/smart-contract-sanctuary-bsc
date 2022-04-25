/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIXED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

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

struct OrderedReserves {
    uint112 a1; // base asset
    uint112 b1;
    uint112 a2;
    uint112 b2;
}

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
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

contract arbbot {
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    address public immutable WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public owner;

    uint256 public DecimalFix = 10**18;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function setting(
        uint256 fix
        ) public{
            DecimalFix = fix;
    }

    function withdraw(address baseToken) public onlyOwner{
        TransferHelper.safeTransfer(
            baseToken, msg.sender, IERC20(baseToken).balanceOf(address(this))
        );
    }

    function withdrawBNB(uint256 amount) public onlyOwner{
        (bool success,) = msg.sender.call{value:amount}(new bytes(0));
        require(success,"fail");
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
                IERC20(baseToken).balanceOf(to).sub(profit) >= balanceBefore,
                'Router: INSUFFICIENT_OUTPUT_AMOUNT'
            );
        }
    } 

    function swapTokenx2(
        address baseToken,
        uint256 amountIn,
        uint256 baseBig,
        address p0,
        address p1,
        uint256 f0,
        uint256 f1) public onlyOwner{  
        (uint out0,uint out1) = preTest(amountIn,baseBig,p0,p1,f0,f1);    
        require(out1>amountIn,"fail0");
        uint256 balanceBefore = IERC20(baseToken).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(
            baseToken, msg.sender, p0, amountIn
        );
        //IUniswapV2Pair(p0).swap(baseBig==1?out0:0, baseBig==1?0:out0, p1, new bytes(0));
        //IUniswapV2Pair(p1).swap(baseBig==1?0:out1, baseBig==1?out1:0, msg.sender, new bytes(0));

        safeSwap(p0,baseBig==1?out0:0,baseBig==1?0:out0,p1);
        safeSwap(p1,baseBig==1?0:out1,baseBig==1?out1:0,msg.sender);
        require(
                IERC20(baseToken).balanceOf(msg.sender) > balanceBefore,
                "fail1"
        );
    } 

    function swapBnbx3(
        uint256 amountIn,
        uint256 baseBig,
        address p0,
        address p1,
        uint256 f0,
        uint256 f1) public onlyOwner{    
        (uint out0,uint out1) = preTest(amountIn,baseBig,p0,p1,f0,f1);    
        require(out1>amountIn,"fail0");
        uint256 balanceBefore = IERC20(WBNB).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(
            WBNB, msg.sender, p0, amountIn
        );
        //IUniswapV2Pair(p0).swap(baseBig==1?out0:0, baseBig==1?0:out0, p1, new bytes(0));
        //IUniswapV2Pair(p1).swap(baseBig==1?0:out1, baseBig==1?out1:0, msg.sender, new bytes(0));

        safeSwap(p0,baseBig==1?out0:0,baseBig==1?0:out0,p1);
        safeSwap(p1,baseBig==1?0:out1,baseBig==1?out1:0,msg.sender);
        require(
                IERC20(WBNB).balanceOf(msg.sender) > balanceBefore,
                "fail1"
        );
    } 

    function testPair(
        address baseToken,
        uint256 amountIn,
        address[] calldata pairs,
        uint32[] calldata fees) public onlyOwner{

        (uint256 maxOut,address quoteToken) = testMaxOut(baseToken,amountIn,pairs[0]);
        uint256 balanceBefore = IERC20(quoteToken).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(
            baseToken, msg.sender, pairs[0], amountIn
        );
         _swapSupportingFeeOnTransferTokens(baseToken,pairs,fees, msg.sender);
        require(
                IERC20(quoteToken).balanceOf(msg.sender).sub(balanceBefore) >= maxOut*fees[1]/10000,
                'Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
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

    function preTest(uint amountIn, uint baseBig,address p0,address p1,uint f0,uint f1) public view returns(uint256 out0,uint256 out1){
        (uint r00, uint r01,) = IUniswapV2Pair(p0).getReserves();
        (uint r10, uint r11,) = IUniswapV2Pair(p1).getReserves();
        out0 = getAmountOut2(amountIn,baseBig==1?r01:r00, baseBig==1?r00:r01,f0);
        out1 = getAmountOut2(out0,baseBig==1?r10:r11, baseBig==1?r11:r10,f1);
    }

    function safeSwap(address pair, uint amount0, uint amount1,address to) internal virtual{
        try IUniswapV2Pair(pair).swap(amount0, amount1, to, new bytes(0)){

        }catch{
                IUniswapV1Pair(pair).swap(amount0,amount1,to);
        }
    }

    function testMaxOut(address baseToken,
        uint256 amountIn,
        address pair) public view returns(uint256 maxOut,address quoteToken){
        
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        uint reserveInput;uint reserveOutput;
        if(baseToken==token0){
            reserveInput=reserve0;
            reserveOutput=reserve1;
            quoteToken=token1;
        }else{
            reserveInput=reserve1;
            reserveOutput=reserve0;
            quoteToken=token0;
        }
        maxOut = getAmountOut2(amountIn, reserveInput, reserveOutput,10000);
    }

    function calProfit(address baseToken,
        uint64 precision,
        address p0,
        address p1) public view returns(uint256 borrowAmount,uint256 amountIn,uint256 profit,uint32 loopCnt){
        (,,OrderedReserves memory orderedReserves) = parsePair(baseToken,p0,p1);
        (uint256 bAmount,uint32 lc) = calBorrowAmount(precision,orderedReserves.a1,orderedReserves.b1,orderedReserves.a2,orderedReserves.b2);
        borrowAmount=bAmount;
        loopCnt=lc;
        amountIn = getAmountIn(borrowAmount,orderedReserves.a1,orderedReserves.b1);
        uint256 tmpQuote = getAmountOut(amountIn,orderedReserves.a1,orderedReserves.b1);
        uint256 amountOut = getAmountOut(tmpQuote,orderedReserves.b2,orderedReserves.a2);
        profit = amountOut<amountIn?0:amountOut-amountIn;
    }

    function calBorrowAmount(uint64 precision,uint112 a1,uint112 b1,uint112 a2,uint112 b2) public view returns(uint256 amount,uint32 loopCnt){
           uint256 maxX=b1>b2?b2:b1;
           uint256 minX=0;
           uint256 x=maxX/2;
           while(true){
               if( (uint256(a2).mul(DecimalFix).mul(uint256(b2)))/((b2+x)**2) > (uint256(a1).mul(DecimalFix).mul(uint256(b1)))/((b1-x)**2) ){
                   minX=x;
                   x=(maxX+x)/2;
               }else{
                   maxX=x;
                   x=(minX+x)/2;
               }
               if(maxX-minX<precision){
                   break;
               }
               loopCnt+=1;
           }
           amount=x;
    }

    function parsePair(
        address baseToken,
        address p0,
        address p1) public view returns(address plow,address phigh, OrderedReserves memory orderedReserves){
            (uint112 r00, uint112 r01,) = IUniswapV2Pair(p0).getReserves();
            (uint112 r10, uint112 r11,) = IUniswapV2Pair(p1).getReserves();
            uint224 price0 = UQ112x112.encode(r00).uqdiv(r01);
            uint224 price1 = UQ112x112.encode(r10).uqdiv(r11);

            if(IUniswapV2Pair(p0).token0()==baseToken){
                if(price0>price1){
                    phigh=p0;
                    plow=p1;
                    orderedReserves.a1=r10;orderedReserves.b1=r11;orderedReserves.a2=r00;orderedReserves.b2=r01;
                }else{
                    phigh=p1;
                    plow=p0;
                    orderedReserves.a1=r00;orderedReserves.b1=r01;orderedReserves.a2=r10;orderedReserves.b2=r11;
                }
            }else if(IUniswapV2Pair(p0).token1()==baseToken){
                if(price0>price1){
                    phigh=p1;
                    plow=p0;
                    orderedReserves.a1=r01;orderedReserves.b1=r00;orderedReserves.a2=r11;orderedReserves.b2=r10;
                }else{
                    phigh=p0;
                    plow=p1;
                    orderedReserves.a1=r11;orderedReserves.b1=r10;orderedReserves.a2=r01;orderedReserves.b2=r00;
                }
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
    function getAmountOut2(uint amountIn, uint reserveIn, uint reserveOut,uint fee) public pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * fee;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn*10000+amountInWithFee;
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
    function getAmountIn2(uint amountOut, uint reserveIn, uint reserveOut,uint fee) public pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn*amountOut*10000;
        uint denominator = (reserveOut-amountOut)*fee;
        amountIn = (numerator / denominator)+1;
    }

}