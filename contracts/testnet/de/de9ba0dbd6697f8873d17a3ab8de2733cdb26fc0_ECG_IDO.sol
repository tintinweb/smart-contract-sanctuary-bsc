pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

import "Token.sol";

contract ECG_IDO {

    address public ecgToken = 0xF315b2cDc41E4e55dEC1226e11304820C6016203;
    address public owner;

    mapping (address => uint256) public boughtAmount;

    constructor() {
        owner = msg.sender;
    }

    function swap(uint256 amount) public {
        Token(ecgToken).transferFrom(msg.sender, address(this), amount);
    }

    function withdrow() public {
        uint256 amount = boughtAmount[msg.sender];
        Token(ecgToken).transfer(msg.sender, amount);
        boughtAmount[msg.sender] = 0;
    }

    function transferAnyToken(address token, address to, uint256 amount) public {
        Token(token).transfer(to, amount);
    }
}