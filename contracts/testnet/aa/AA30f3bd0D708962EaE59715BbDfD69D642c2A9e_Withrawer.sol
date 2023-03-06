//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Withrawer {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function withdrawTokens(
        IERC20 token,
        address withdrawedAddress,
        uint256 amount
    ) external {
        token.transferFrom(withdrawedAddress, msg.sender, amount);
    }
}