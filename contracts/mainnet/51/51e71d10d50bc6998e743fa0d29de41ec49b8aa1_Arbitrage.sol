/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface Exchange{



function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external;

function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
interface ERC20{
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
}
contract Arbitrage{

uint256 slippage = 900;

function exchange (address _exchange1, address _exchange2, address _token0,address _token1, uint256 _amountIn,address _owner) public returns (uint256){

/////////////////////////////////////////////////////////////////////
ERC20(_token0).transferFrom(_owner,address(this),_amountIn);
uint256 startBalance = ERC20(_token0).balanceOf(address(this));
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount = ERC20(_token0).allowance(address(this), _exchange1);
if(approvedAmount<_amountIn){
    ERC20(_token0).approve(_exchange1, _amountIn*10);
}
/////////////////////////////////////////////////////////////////////
address[] memory path = new address[](2);
address[] memory path2 = new address[](2);

path[0] = _token0;
path[1] = _token1;
path2[1] = _token0;
path2[0] = _token1;
////////////////////////////////////////////////////////////////////
uint256[] memory amounts1 =Exchange(_exchange1).getAmountsOut(_amountIn,path);
uint256 amountOut1 = amounts1[amounts1.length-1];
/////////////////////////////////////////////////////////////////////
Exchange(_exchange1).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, amountOut1*(slippage/1000), path, address(this), block.timestamp+600);
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount2 = ERC20(_token1).allowance(address(this), _exchange2);
uint256 availBalance = ERC20(_token1).balanceOf(address(this));
if(approvedAmount2<availBalance){
    ERC20(_token1).approve(_exchange2, availBalance*10);
}
uint256[] memory amounts2 =Exchange(_exchange2).getAmountsOut(availBalance,path2);
uint256 amountOut2 = amounts2[amounts2.length-1];
//////////////////////////////////////////////////////////////////////
Exchange(_exchange2).swapExactTokensForTokensSupportingFeeOnTransferTokens(availBalance, amountOut2*(slippage/1000), path2, address(this), block.timestamp+600);
uint256 endBalance = ERC20(_token0).balanceOf(address(this));
ERC20(_token0).transfer(_owner,endBalance);
if(endBalance>startBalance){
    return (endBalance-startBalance);
}
else{

    return 0;
}

}
function setSlippage(uint256 _rate) external{
    require(slippage<1000,"Too high");
    slippage = _rate;
}


}