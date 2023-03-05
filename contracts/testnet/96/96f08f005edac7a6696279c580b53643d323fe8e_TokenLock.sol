/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenLock {
    address public owner;
    bool public isLocked;
    
    event Locked(address indexed user, bool isLocked);
    event ContractDestroyed(address indexed owner, uint balance);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier notLocked() {
        require(!isLocked, "Transactions are currently blocked");
        _;
    }
    
    function lockTransactions(bool _lock) public {
        isLocked = _lock;
        emit Locked(msg.sender, isLocked);
    }
    
    function destroyContract() public onlyOwner {
        emit ContractDestroyed(owner, address(this).balance);
        selfdestruct(payable(owner));
    }
    
    function transfer(address _to, uint256 _value) public notLocked returns (bool success) {
        // block all transactions
        revert("Transactions are currently blocked");
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public notLocked returns (bool success) {
        // block all transactions
        revert("Transactions are currently blocked");
    }
}