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
    mapping(address=>uint256) private claimableAmount;

    function BuyBNB() public payable {
        require(msg.value >0,"low balance!");
        claimableAmount[msg.sender]=msg.value;

    }
    function claimBNB(uint256 _amount) public {
        require(_amount<=claimableAmount[msg.sender],"you don't have enough balance!");
        payable(msg.sender).transfer(_amount);
    }

    function CheckBalance(address _user) public view returns(uint256){
        return claimableAmount[_user];
    }

}