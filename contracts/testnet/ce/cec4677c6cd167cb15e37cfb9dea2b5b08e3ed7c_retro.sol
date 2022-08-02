/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract retro {
    fallback() external payable {   }
    receive() external payable {    }

    address public owner;
    address public addrCont =address(this);
    uint balance;

        constructor() payable {
            owner = msg.sender;
            balance = msg.value;
        }

    function ownerBalance() public view returns(uint) {
        return owner.balance;
    }

    function contrBalance() public view returns(uint) {
        return addrCont.balance;
    }

    function payCoin() public payable {

    }

    function withdrawAll() public {
        address payable _to = payable(owner);
        _to.transfer(addrCont.balance);
    }
    
 
}