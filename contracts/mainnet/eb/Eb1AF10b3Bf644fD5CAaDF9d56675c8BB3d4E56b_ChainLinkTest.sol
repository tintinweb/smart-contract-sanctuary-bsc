// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract ChainLinkTest {
    address creator;
    uint32[] public versionList;

    bool public restartStatus = true;

    constructor() {
        creator = msg.sender;
        versionList.push(1);
    }

    function withdraw(IERC20 token, uint256 amount) external {
        require(msg.sender == creator, "Forbidden.");
        token.transfer(msg.sender, amount);
    }
}