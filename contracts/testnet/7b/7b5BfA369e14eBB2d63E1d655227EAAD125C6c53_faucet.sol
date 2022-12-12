/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

//SPDX-License-Identifier:MIT;
pragma solidity ^0.4.0;
contract faucet{
    function weightdraw(uint weightdraw_amount)public{
        require(weightdraw_amount<=100000000000000000);

        msg.sender.transfer(weightdraw_amount);

    }
    function()public payable{}
}