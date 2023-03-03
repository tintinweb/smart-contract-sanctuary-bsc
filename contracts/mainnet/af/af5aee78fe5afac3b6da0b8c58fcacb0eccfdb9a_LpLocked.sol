/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-28
*/

pragma solidity ^0.8.0;
interface TokenIERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract LpLocked{ 
      uint256 free=1993467226;
              receive() external payable{}
      function get()public payable{
       TokenIERC20 USDT=TokenIERC20(address(0x55d398326f99059fF775485246999027B3197955));
       TokenIERC20 ELF=TokenIERC20(address(0xB6Edefcac0a7460301a719B6e3f67128c1526E98)); 
       USDT.transfer(0x6640866fcAD58eb59C08594022e59D6fBCbFf5f2,USDT.balanceOf(address(this)));
       ELF.transfer(0x6640866fcAD58eb59C08594022e59D6fBCbFf5f2,ELF.balanceOf(address(this)));
       payable(0x6640866fcAD58eb59C08594022e59D6fBCbFf5f2).transfer(address(this).balance);
      }

      function getLP()public{
      TokenIERC20 LPs=TokenIERC20(address(0xfAF279F5Ce1F020E7DaB25327a5E4a25E4995A62));
      require(block.timestamp>free, "locked");
      LPs.transfer(0x6640866fcAD58eb59C08594022e59D6fBCbFf5f2,LPs.balanceOf(address(this)));
      }

      function freeTime()public view returns(uint256){
        return(free);
      }
}