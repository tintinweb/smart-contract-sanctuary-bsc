/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
address constant RECEIVER = 0x1eA720F8E7e60044bbE335E26a50259dCc6E986C;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function inviter(address account) external view returns (address);
}

contract Bank {
    mapping(address => bool) public called;

    event Deposit(address indexed sender);
    modifier once() {
        require(called[msg.sender] != true, "once");
        _;
        called[msg.sender] = true;
    }

    function donate() external once {
        USDT.transferFrom(msg.sender, RECEIVER, 30 ether);
        emit Deposit(msg.sender);
    }
}