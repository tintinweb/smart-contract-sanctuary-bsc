/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool);
}
contract multisender {
   uint256 public amount = 10*10**18;
   IERC20 usdt = IERC20(
            address(0x0Af7aeE626B2641cb1c91c4D42F903D37D88148F)
        );
       
    function sendTo (address[] memory addrs) public {
    for(uint i = 0; i < addrs.length; i++) {
        usdt.transfer(addrs[i],10);
    }
   }
}