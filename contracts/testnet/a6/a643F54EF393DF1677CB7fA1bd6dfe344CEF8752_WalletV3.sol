// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.10;

contract WalletV3 {
    uint public val;

    event Deposit(address indexed _from, uint _value);

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable public {
        emit Deposit(msg.sender, msg.value);       
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    } 
}