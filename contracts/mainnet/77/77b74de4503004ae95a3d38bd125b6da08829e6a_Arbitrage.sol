/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface Exchange{

     function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
interface ERC20{
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
}
contract Arbitrage{

uint256 slippage = 900;

function exchange (address _exchange1, address _exchange2, address _token0,address _token1, uint256 _amountIn,uint256 _amountOut,address _owner) public returns (uint256){

/////////////////////////////////////////////////////////////////////
uint256 startBalance = ERC20(_token0).balanceOf(_owner);
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount = ERC20(_token0).allowance(_owner, _exchange1);
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
/////////////////////////////////////////////////////////////////////
Exchange(_exchange1).swapTokensForExactTokens(_amountOut, _amountIn, path, address(this), block.number+100);
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount2 = ERC20(_token1).allowance(_owner, _exchange2);
uint256 availBalance = ERC20(_token1).balanceOf(address(this));
if(approvedAmount2<availBalance){
    ERC20(_token0).approve(_exchange1, availBalance*10);
}
//////////////////////////////////////////////////////////////////////
Exchange(_exchange2).swapTokensForExactTokens(_amountOut, _amountIn, path2, _owner, block.number+100);
uint256 endBalance = ERC20(_token0).balanceOf(_owner);
if(endBalance>startBalance){
    return (endBalance-startBalance);
}
else{
    return 0;
}

}


}