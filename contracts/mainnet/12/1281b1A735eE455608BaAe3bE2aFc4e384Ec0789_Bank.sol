/**
 *Submitted for verification at BscScan.com on 2022-11-23
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

    function inviter(address account) external view returns (address);
}

contract Bank {
    struct Receord {
        address depositer;
        uint256 amount;
        uint256 timestamp;
    }
    Receord[] public historyReceords;

    mapping(address => uint256[]) indexs;
    event Deposit(address indexed sender, uint256 amount);

    function deposit(uint256 amount) external {
        address inviter = PROS.inviter(msg.sender);
        uint256 toInviterAmount = (amount * 2) / 100;
        PROS.transferFrom(msg.sender, inviter, toInviterAmount);
        PROS.transferFrom(msg.sender, RECEIVER, toInviterAmount);
        PROS.transferFrom(
            msg.sender,
            address(0xdead),
            amount - toInviterAmount - toInviterAmount
        );

        historyReceords.push(
            Receord({
                depositer: msg.sender,
                amount: amount,
                timestamp: block.timestamp
            })
        );
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount);
    }

    function getIndex(address user) external view returns (uint256[] memory) {
        return indexs[user];
    }

    function getRecords(address user) external view returns (Receord[] memory) {
        uint256[] storage linshi = indexs[user];
        Receord[] memory nitem = new Receord[](linshi.length);
        for (uint256 i = 0; i < linshi.length - 1; i++) {
            nitem[i] = historyReceords[linshi[i]];
        }
        return nitem;
    }
}