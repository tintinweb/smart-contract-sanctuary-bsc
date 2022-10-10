/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Wallet {

    address public owner;
    address public commissionAddress;
    uint256 public commission;

    mapping(address => uint256) public wallets;

    event Deposit(address indexed _address, uint256 _amount);
    event Withdraw(address indexed _address, uint256 _amount);
    event OwnerChanged(address indexed _owner);

    constructor(address _commissionAddress, uint256 _commission) {
        
        owner = msg.sender;
        commissionAddress = _commissionAddress;
        commission = _commission;

    }

    function deposit() public payable {
        wallets[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        require(wallets[msg.sender] >= _amount, "Not enough to withdraw");
        payable(address(msg.sender)).transfer(_amount);
        wallets[msg.sender] -= _amount;
        emit Withdraw(msg.sender, _amount);
    }

    function changeOwner(address _owner) public isOwner {
        owner = _owner;
        emit OwnerChanged(owner);
    }

    function changeCommission(uint256 _commission) public isOwner {
        commission = _commission;
    }

    function changeCommissionAddress(address _address) public isOwner {
        commissionAddress = _address;
    }

    function bank() public view returns(uint256) {
        return address(this).balance;
    }

    modifier isOwner() {
        require(address(msg.sender) == owner, "Not allowed");
        _;
    }

}