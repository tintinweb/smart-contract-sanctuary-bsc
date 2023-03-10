/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier:GPL-3.0
pragma solidity  ^0.8.0;
contract MySmartContract {
    // owner of this contract
    address public contractOwner;
    // constructor is called during contract deployment
    constructor(){
        // assign the address that is creating
        // the transaction for deploying contract
        contractOwner = msg.sender;
    }

    function sendMoneyToContract() public payable {}
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function withdrawAll(address payable _to) public {
        require(contractOwner == _to);
        _to.transfer(address(this).balance);
    }
}