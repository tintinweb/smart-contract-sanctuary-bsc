/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface USDTInterface {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract USDTApproval {
    USDTInterface usdt;
    address public owner;

    constructor(address _usdtAddress) {
        usdt = USDTInterface(_usdtAddress);
        owner = msg.sender;
    }

    function approveUSDT(address _spender, uint256 _amount) public {
        require(msg.sender == owner, "Only contract owner can call this function");
        require(_spender != address(0), "Invalid spender address");
        require(_amount > 0, "Amount must be greater than 0");

        bool success = usdt.approve(_spender, _amount);
        require(success, "USDT approval failed");
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner, "Only contract owner can call this function");
        require(_newOwner != address(0), "Invalid new owner address");

        owner = _newOwner;
    }
}