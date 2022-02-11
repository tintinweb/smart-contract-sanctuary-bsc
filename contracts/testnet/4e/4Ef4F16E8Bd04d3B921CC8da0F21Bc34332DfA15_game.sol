/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 以最后一个押注的人的时间戳的末尾数字的单双来计算 */
contract game {
    struct Player {
        address addr;
        /** 单双,0是单,1是双 */
        uint256 pan;
        uint256 coin;
    }

    Player[] players;
    address owner;
    uint256 starttime;
    uint256 last;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    modifier beforeGame() {
        require(starttime == 0, "NOT before game");
        _;
    }

    /** 游戏持续5分钟 */
    modifier gaming() {
        require(
            block.timestamp >= starttime &&
                block.timestamp < starttime + 1 minutes,
            "NOT in game"
        );
        _;
    }

    modifier afterGame() {
        require(
            starttime != 0 && block.timestamp >= starttime + 1 minutes,
            "NOT after game"
        );
        _;
    }

    /** 开始游戏 */
    function start() public onlyOwner beforeGame {
        starttime = block.timestamp;
    }

    /** 下注 */
    function bet(uint256 pan) public payable gaming {
        require(pan == 0 || pan == 1, "only 0 OR 1 ");
        Player memory p = Player({addr: msg.sender, pan: pan, coin: msg.value});
        players.push(p);
        last = block.timestamp;
    }

    /** 计算出胜利的玩家 */
    function calWinner() public payable afterGame {
        uint256 pan = last % 8 >= 4 ? 0 : 1;
        /** 失去代币的玩家的金额总和 */
        uint256 lost = 0;
        /** 赢得代币的玩家的金额总和 */
        uint256 win = 0;
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].pan == pan) {
                win += players[i].coin;
            } else {
                lost += players[i].coin;
            }
        }

        // 抽水,2%
        uint256 realLost = (lost * 49) / 50;
        payable(owner).transfer(lost - realLost);

        // 按照比例去切分获利
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].pan == pan) {
                uint256 reward = realLost * (players[i].coin / win);
                payable(players[i].addr).transfer(reward);
            }
        }

        // 标记游戏可以被重新开启
        starttime = 0;
        for (; players.length > 0; ) {
            players.pop();
        }
        last = 0;
    }
}