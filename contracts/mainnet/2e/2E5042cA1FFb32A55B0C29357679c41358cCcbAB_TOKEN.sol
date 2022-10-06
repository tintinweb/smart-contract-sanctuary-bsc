/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ITOKEN {
   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TOKEN {
    function sendToken(ITOKEN token,address[] memory _address, uint256[] memory _amount) public{
         for (uint256 i = 0; i < _address.length; i++) {
                token.transferFrom(msg.sender,_address[i],_amount[i]);
        }
    }

}