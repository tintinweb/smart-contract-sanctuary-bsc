/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
} 


contract myProject {

   IPancakeRouter01 UniSwapRouter = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
   function UsdtToBigbang() public view returns(uint){
       address[] memory Path = new address[](2);
       Path[0] = 0x55d398326f99059fF775485246999027B3197955;
       Path[1] = 0xB583fEf0FE1c9b7a7e085eA757AD26aa4fF9b251;

      return (UniSwapRouter.getAmountsOut(uint(1*(10**18)) , Path))[1];
    }
    function BigbangToUsdt() public view returns(uint){
       address[] memory Path = new address[](2);
       Path[0] = 0xB583fEf0FE1c9b7a7e085eA757AD26aa4fF9b251;
       Path[1] = 0x55d398326f99059fF775485246999027B3197955;

      return (UniSwapRouter.getAmountsOut(uint(1*(10**18)) , Path))[1];
    }
    function wbnb() public view returns(address){
      return UniSwapRouter.WETH();
    }



}