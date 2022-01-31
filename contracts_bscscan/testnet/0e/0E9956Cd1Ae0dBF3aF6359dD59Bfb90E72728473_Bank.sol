/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Bank {
    //declare state variables at contract level
    address public bankOwner;
    string public bankName;
    mapping(address => uint256) public customerBalance;
    //constructor will only run once, when the contract is deployed
    constructor() {
        //we're setting the bank owner to the Ethereum address that deploys the contract
        //msg.sender is a global variable that stores the address of the account that initiates a transaction
        bankOwner = msg.sender; // initialize state variable
    }

    function depositMoney() public payable {
        require(msg.value != 0, "You need to deposit some amount of money!");
        customerBalance[msg.sender] += msg.value;
    }

    function setBankName(string memory _name) external {
        require(
            msg.sender == bankOwner,
            "You must be the owner to set the name of the bank!"
        );
        bankName = _name;
    }

    function withdrawMoney(address payable _to, uint256 _total) public {
        require(
            _total <= customerBalance[msg.sender],
            "You have insufficient funds to withdraw"
        );
        customerBalance[msg.sender] -= _total;
        _to.transfer(_total);
    }

    function getCustomerBalance() external view returns (uint256) {
        return customerBalance[msg.sender];
    }

    function getBankBalance() public view returns (uint256) {
        require(
            msg.sender == bankOwner,
            "You must be the owner of the bank the see all balances"
        );
        return address(this).balance;
    }
}