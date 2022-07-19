/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity ^0.8.0 ;

interface IDEXRouter {
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Contract_path{
    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public btcb = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function getPath(uint256 n,address token1,address token2,address token3) private pure returns(address[] memory path){
        require(n <= 3 && n >=2 );
        path =new address[](n);
        path[0]=token1;
        path[1]=token2;
        if(n == 3){
            path[2] = token3;
        }
    }

    function getPath4(address token1,address token2,address token3,address token4) private pure returns(address[] memory path){
   
        path =new address[](4);
        path[0]=token1;
        path[1]=token2;
        path[2]=token3;
        path[3]=token4;
    }

    function getMaxOutPath(uint256 amountIn,address token1,address token2) public view returns(address[] memory pathOut,uint256 max){
        require(token1 != token2);
      
        address[] memory path ;
        uint256 amountOut;

        address[] memory zlb =new address[](5);
        zlb[0] = wbnb; zlb[1]=usdt ; zlb[2] = busd ; zlb[3]=btcb ; zlb[4] = eth ; zlb[5] = token1;
        for(uint256 i=0;i<zlb.length;i++){
            ( path , amountOut) = getOutPath(amountIn,token1,token2,zlb[i]);
            if(amountOut > max){
                max = amountOut;
                pathOut = path;
            }
        }
        (pathOut,max) = get4pathout( max, amountIn,  token1, token2);
    }
    function get4pathout(uint256 _max,uint256 amountIn, address token1,address token2)public view returns(address[] memory pathOut,uint256 maxOut) {
        
        address[] memory path1 = getPath4(token1,wbnb,usdt,token2);
        address[] memory path2 = getPath4(token1,wbnb,busd,token2);
        address[] memory path3 = getPath4(token1,usdt,wbnb,token2);
        address[] memory path4 = getPath4(token1,busd,wbnb,token2);

        uint256 out1 = getOut(amountIn,path1);
        uint256 out2 = getOut(amountIn,path2);
        uint256 out3 = getOut(amountIn,path3);
        uint256 out4 = getOut(amountIn,path4);

        if(out1 > _max){
            _max = out1;
            pathOut = path1;
        }
        if(out2 > _max){
            _max = out2;
            pathOut = path2;
        }
        if(out3 > _max){
            _max = out3;
            pathOut = path3;
        }
        if(out4 > _max){
            _max = out4;
            pathOut = path4;
        }
        
        maxOut=_max;
    }
    function getOutPath(uint256 amountIn,address token1,address token2,address _token) public view returns(address[] memory path ,uint256 amountOut){
        require(token1 != token2);
     
        if(token1 == _token || token2 == _token){
            path = getPath(2,token1,token2,address(0));
        }else{
            path = getPath(3,token1,_token,token2);
        }

        amountOut = getOut(amountIn,path);
    }

    function getOut(uint256 amountIn,address[] memory path) public view returns(uint256 amountOut){
        try router.getAmountsOut(amountIn,path) returns (uint256[] memory out){ amountOut = out[out.length-1]; } catch {}  
    }

}