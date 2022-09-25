/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

contract Betting{

    address public owner;

    constructor(){
        owner = msg.sender;
    }
    mapping(address=>uint256) public claimableAmount;
    function BuyBNB() public payable {
        claimableAmount[msg.sender]=msg.value;

    }
    function claimBNB(uint256 _amount) public {
        payable(msg.sender).transfer(_amount);
    }

    function CheckBalance() public view returns(uint256){
        return address(this).balance;
    }

}