/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/*    SPDX-License-Identifier: MIT    */
pragma solidity 0.8.17;

contract StakeUpFarm {
    mapping(address=>uint256) public balance;
    function stakeSUF(uint256 amount) public {
        balance[msg.sender]+=amount;
    }
}