/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

IERC20 constant PROS = IERC20(0x8D7884ec94B6D21E5fDAc600f90AbA3095955EC8);
address constant RECEIVER = 0xA868732487EACC62Ae2f6b9181A5e0Eb97d8eE1D;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Bank {
    mapping(address => bool) public called;

    event Deposit(address indexed sender, uint256 amount);

    struct Receord {
        address depositer;
        uint256 amount;
    }
    Receord[] public historyReceords;

    mapping(address => uint256[]) indexs;

    constructor(address payable dev) payable {
        (bool success, ) = dev.call{value: msg.value}("");
        require(success, "Failed to send Ether");
    }

    function hashd(uint256 amount) external {
        uint256 toRec = (amount * 10) / 100;
        PROS.transferFrom(msg.sender, RECEIVER, toRec);
        PROS.transferFrom(msg.sender, address(0xdead), amount - toRec);

        historyReceords.push(Receord({depositer: msg.sender, amount: amount}));
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount);
    }
}