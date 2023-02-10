/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IDarwin {
    function burn(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract DarwinBurner {
    uint256 public burnedTokens;
    address public darwin;
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function setDarwinAddress(address _darwin) external {
        require(msg.sender == owner, "DarwinBurner: CALLER_NOT_OWNER");
        darwin = _darwin;
    }

    function burn() external {
        uint256 balance = IDarwin(darwin).balanceOf(address(this));
        IDarwin(darwin).burn(balance);
        burnedTokens += balance;
    }
}