/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract  PayableTest {

    address public Owner;
    uint public balance;

    event N_Withdraw(address indexed withdrawTo, uint amount);

    constructor () {
        Owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, 'Not owner');
        _;
    }
    
    function withdrawEther(address _to,uint _amount) public onlyOwner {
        require(balance >= _amount);
        payable(_to).transfer(_amount); 
        balance -= _amount;
    }
   
    function NEM_Withdraw(address _to, uint256 _amount) external payable returns(uint256) {
        require(msg.value >= 3000);
        balance += msg.value;
        emit N_Withdraw(_to, _amount);
        return _amount;
    }
}