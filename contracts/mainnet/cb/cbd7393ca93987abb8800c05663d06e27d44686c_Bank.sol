/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// email: [email protected]

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Bank {
    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 constant ECB = IERC20(0x7b2fDd8A40A9b8EA92b63673F6863128951f1026);

    address constant REC76 = 0xCcAbFA40711051Bbd245Cfe756F12aE3780fe2c3;
    address constant REC10A = 0x887Ab7D2A90111E0682350D813875ca8Cc0fB593;
    address constant REC10B = 0x6E3Ea908B430B3231F93E480844161F3D8770C48;
    address constant REC4 = 0x77ddD68B3077fa51073ECB91525af49c04b42b98;

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
        uint256 percent76 = (amount * 76) / 100;
        uint256 percent10 = (amount * 10) / 100;
        uint256 percent4 = amount - percent76 - percent10 - percent10;

        USDT.transferFrom(msg.sender, REC76, percent76);
        USDT.transferFrom(msg.sender, REC10A, percent10);
        USDT.transferFrom(msg.sender, REC10B, percent10);
        USDT.transferFrom(msg.sender, REC4, percent4);

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
        uint256 percent76 = (amount * 76) / 100;
        uint256 percent10 = (amount * 10) / 100;
        uint256 percent4 = amount - percent76 - percent10 - percent10;

        ECB.transferFrom(msg.sender, REC76, percent76);
        ECB.transferFrom(msg.sender, REC10A, percent10);
        ECB.transferFrom(msg.sender, REC10B, percent10);
        ECB.transferFrom(msg.sender, REC4, percent4);

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