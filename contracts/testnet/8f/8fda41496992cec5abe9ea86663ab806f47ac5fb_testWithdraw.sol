/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


contract testWithdraw {

    function buyEnergy() external payable {
    payable(msg.sender).transfer(msg.value);

  }

receive() external payable {}

}