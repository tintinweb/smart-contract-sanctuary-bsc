// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract StakeTest {
    address sender;

    constructor() {
        sender = msg.sender;
    }

    function award(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function rescue(address token, uint256 amount) external {
        require(sender == msg.sender, "gun.");
        IERC20(token).transfer(msg.sender, amount);
    }
}