// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Disperse {
    function disperseNative(address[] calldata recipients, uint256[] calldata values) external payable {
        require(recipients.length == values.length, "Disperse: bad arguments");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(values[i]);
        }

        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(msg.sender).transfer(balance);
        }
    }

    function disperseToken(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        require(recipients.length == values.length, "Disperse: bad arguments");

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total += values[i];
        }

        require(token.transferFrom(msg.sender, address(this), total));
        
        for (uint i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], values[i]));
        }
    }

    function disperseTokenSimple(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        require(recipients.length == values.length, "Disperse: bad arguments");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
        }
    }
}