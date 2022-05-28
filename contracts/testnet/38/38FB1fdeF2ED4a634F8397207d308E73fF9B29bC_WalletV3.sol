// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.10;

contract WalletV3 {
    uint public val;

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
        // nothing else to do!
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    } 
}