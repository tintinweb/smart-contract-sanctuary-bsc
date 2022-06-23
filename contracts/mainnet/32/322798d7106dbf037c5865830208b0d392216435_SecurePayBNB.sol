/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SecurePayBNB {
    bool public aggrement;
    bytes32 private password;
    address payable public freelancer;
    address payable public buyer;

    receive() external payable {}

    fallback() external {}

    constructor(address payable _frelancer, bytes32 _password) payable {
        freelancer = _frelancer;
        password = _password;

        buyer = payable(msg.sender);
        aggrement = false;
    }

    function getPayment(bytes32 _word) public {
        require(msg.sender == freelancer, "Caller not freelancer");

        if (_word == password) {
            freelancer.transfer(address(this).balance);
        }
    }

    function setAgrement() public {
        require(freelancer == msg.sender, "You can set aggrement");
        aggrement = true;
    }

    function cancel() public {
        require(aggrement == true, "You can't cancel");
        buyer.transfer(address(this).balance);
    }
}