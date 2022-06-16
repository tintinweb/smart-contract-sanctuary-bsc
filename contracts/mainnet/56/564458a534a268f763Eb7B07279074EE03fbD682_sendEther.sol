/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract sendEther{

    mapping (address => uint256) private _balances;

    function sendViaTransfer(address payable _to) external payable{
        _to.transfer(msg.value);
    }

    function balanceOf() external view  returns (uint256){
        return address(this).balance;
    }
}