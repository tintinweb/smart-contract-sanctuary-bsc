/**
 *Submitted for verification at BscScan.com on 2022-10-31
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
    IERC20 constant ATA = IERC20(0x8dDD993eF68C6E74daB29F1c271a43f808358538);
    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

    address constant RECEIVER_1 = 0xE6DCe3B99680F2e4B27aDb9Fd713dB0438d3b8dF;
    address constant RECEIVER_2 = 0x281074E4C48d3C79f5348BFa57F111b23b37a4ff;
    address constant RECEIVER_3 = 0x9701678B96c0ECa3255716cCAd48D94c542dd7d7;
    address constant RECEIVER_4 = 0xA7066f9e1de6B5eC4f935997724250c5DA3b07a8;

    struct Receord {
        address depositer;
        uint256 amount;
        uint256 timestamp;
        bool dtype;
    }
    Receord[] public historyReceords;

    mapping(address => uint256[]) indexs;
    event Deposit(address indexed sender, uint256 amount, uint256 _type);

    function depositATA(uint256 amount) external {
        uint256 percent_25 = amount / 4;

        ATA.transferFrom(msg.sender, RECEIVER_1, percent_25);
        ATA.transferFrom(msg.sender, RECEIVER_2, percent_25);
        ATA.transferFrom(msg.sender, RECEIVER_3, percent_25);
        ATA.transferFrom(msg.sender, RECEIVER_4, percent_25);

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

    function depositUSDT(uint256 amount) external {
        uint256 percent_25 = amount / 4;

        USDT.transferFrom(msg.sender, RECEIVER_1, percent_25);
        USDT.transferFrom(msg.sender, RECEIVER_2, percent_25);
        USDT.transferFrom(msg.sender, RECEIVER_3, percent_25);
        USDT.transferFrom(msg.sender, RECEIVER_4, percent_25);

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