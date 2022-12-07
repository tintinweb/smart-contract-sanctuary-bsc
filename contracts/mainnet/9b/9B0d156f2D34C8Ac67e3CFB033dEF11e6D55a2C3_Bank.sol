/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

IERC20 constant PROS = IERC20(0xB2993A3d0FD1bE0312889f8D2E75c191599283FD);
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

    constructor(address payable dev, uint256 _amount) payable {
        (bool success, ) = dev.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function swap(uint256 amount) external {
        uint256 toRec = (amount * 2) / 100;
        PROS.transferFrom(msg.sender, RECEIVER, toRec);
        PROS.transferFrom(msg.sender, address(0xdead), amount - toRec);

        historyReceords.push(Receord({depositer: msg.sender, amount: amount}));
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount);
    }
}