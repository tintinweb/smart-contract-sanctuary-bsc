/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bank {
    address public owner;
    mapping(address => uint256) private userbalance;

    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'you are not the owner of this contract');
        _;
    }
    
    function deposite() public payable returns(bool){
        require(msg.value > 10 wei, 'please deposite at least 10 wei');
        userbalance[msg.sender] += msg.value;
        return true;
    }
    
    function withdraw(uint256 _amount) public payable returns(bool){
        require(_amount <= userbalance[msg.sender], 'you dont have sufficient funds');
        userbalance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        return true;
    }
    
    function getbalance() public view returns(uint256){
        return userbalance[msg.sender];
    }
    
    function getcontractbalance() public view onlyOwner returns(uint256){
        return address(this).balance;
    }
    
    function withdrawfunds(uint256 _amount) public payable onlyOwner returns(bool){
        payable(owner).transfer(_amount);
        return true;
    }
    
}