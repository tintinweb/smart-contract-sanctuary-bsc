/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;



contract Bank {
    address public owner;
    string public name;

    mapping(address => uint256) customerBalance;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have permission");
        _;
    }

    function deposit() public payable {
        require(msg.value != 0, "You need some amount of money!");
        customerBalance[msg.sender] += msg.value;
    }

    function withdraw(address payable _to, uint256 _amount) public {
        require(_amount <= customerBalance[msg.sender], "You don't have enough funds to withdraw");
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Withdraw is failed");
    }

    function setBankName(string memory _name) external onlyOwner {
        name = _name;
    }

    function getCustomerBalance() external view returns (uint256) {
        return customerBalance[msg.sender];
    }

    function getBankBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}