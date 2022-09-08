/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Bank {
    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 constant ECB = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address constant RECEIVER = 0x1298f11D3A0E671262c1D04d6FfBc02C822168f7;

    struct Receord {
        address depositer;
        uint256 amount;
        uint256 timestamp;
        bool dtype;
    }
    Receord[] public historyReceords;

    mapping(address => uint256[]) indexs;
    event Deposit(address indexed sender, uint256 amount, uint256 _type);

    function depositUSD(uint256 amount) external {
        USDT.transferFrom(msg.sender, RECEIVER, amount);

        historyReceords.push(
            Receord({
                depositer: msg.sender,
                amount: amount,
                timestamp: block.timestamp,
                dtype: true
            })
        );
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount, 1);
    }

    function depositECB(uint256 amount) external {
        ECB.transferFrom(msg.sender, RECEIVER, amount);

        historyReceords.push(
            Receord({
                depositer: msg.sender,
                amount: amount,
                timestamp: block.timestamp,
                dtype: false
            })
        );
        uint256 counter = historyReceords.length - 1;
        indexs[msg.sender].push(counter);

        emit Deposit(msg.sender, amount, 2);
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