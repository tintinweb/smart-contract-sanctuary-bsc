/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CryptoLine {
    
    event PaymentDone(
        address from,
        address to,
        uint256 amount
    );

    function helloWorld() external view returns (string memory) {
        return "Hola Mundo";
    }

    function execute(address to, uint amount) public {
        require(amount != 1234, "Error validation");
        emit PaymentDone(msg.sender, to, amount);
    }
}