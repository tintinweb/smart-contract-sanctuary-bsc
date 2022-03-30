/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

struct Player {
    /** 单双,1是单,2是双 */
    uint256 pan;
    /** 押注金额 */
    uint256 coin;
    bool isValid;
}

contract game {
    /** 合约拥有者 */
    address owner;

    /** 游戏开始时间 */
    uint256 public starttime;
    /** 游戏结束时间 */
    uint256 public endtime;
    /** 最后一次押注时间 */
    uint256 public lasttime;
    /** 本场比赛的玩家 */
    mapping(address => Player) public players;
    /** 本场比赛的玩家address,为了方便遍历 */
    address[] public addrs;

    /** 一场游戏的时间 */
    uint256 duration = 10 minutes;
    /** 官方抽水百分比 */
    uint8 percent = 2;

    constructor() {
        owner = msg.sender;
    }

    /** 合约所有者检测 */
    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    /** 游戏开始前检测 */
    modifier beforeGame() {
        require(starttime == 0, "NOT before game");
        _;
    }

    /** 
        游戏中检测
        游戏持续$duration分钟 
    */
    modifier gaming() {
        require(
            block.timestamp >= starttime && block.timestamp < endtime,
            "NOT in game"
        );
        _;
    }

    /**
    游戏结束检测
    */
    modifier afterGame() {
        require(starttime != 0 && block.timestamp >= endtime, "NOT after game");
        _;
    }

    modifier validPan(uint256 pan) {
        require(pan == 1 || pan == 2, "only 1 OR 2 ");
        _;
    }

    /** 开始游戏 
    1 只有合约所有者可以发起
    2 只有在游戏开始前可以发起(上一场已经结束的游戏)
    */
    function start() public onlyOwner beforeGame {
        starttime = block.timestamp;
        endtime = starttime + duration;
    }

    /** 下注 */
    function bet(uint256 pan) public payable gaming validPan(pan) {
        address addr = msg.sender;
        uint256 coin = msg.value;

        require(coin != 0, "bet must large than 0");

        require(
            players[addr].isValid == false || players[addr].pan == pan,
            "must bet on the SAME pan"
        );

        if (players[addr].isValid == false) {
            addrs.push(addr);
        }

        players[addr] = Player({
            pan: pan,
            coin: coin + players[addr].coin,
            isValid: true
        });
        lasttime = block.timestamp;
    }

    /** 结束游戏 计算出胜利的玩家 */
    function endGame() public payable afterGame {
        uint256 pan = lasttime % 2;
        /** 失去代币的玩家的金额总和 */
        uint256 lost = 0;
        /** 赢得代币的玩家的金额总和 */
        uint256 win = 0;

        (win, lost) = getCoin();

        /** 如果在结束的时候,有一方是押注为0,就会延长这个游戏的比赛时间 */
        if (win == 0 || lost == 0) {
            endtime = block.timestamp + duration;
            return;
        }

        // 计算胜负
        uint256 winBack;
        uint256 lostBack;
        uint256 water;

        // 如果失败方输掉的钱不会超过胜利方押注的钱
        if (win >= lost) {
            winBack = lost;
            lostBack = 0;
        } else {
            winBack = win;
            lostBack = lost - win;
        }

        // 官方抽水之后,给胜利方分的钱
        uint256 winBackReal = (lost * (100 - percent)) / 100;
        // 抽水
        water = winBack - winBackReal;
        if (water > 0) {
            payable(owner).transfer(water);
        }

        // 按照比例去切分获利

        for (uint256 i = 0; i < addrs.length; i++) {
            Player memory p = players[addrs[i]];
            uint256 back;
            /** 胜利方按照押注比例赢取 */
            if (p.pan == pan) {
                back = p.coin + winBackReal * (p.coin / win);
            }
            /** 失败方按照押注比例退回 */
            else {
                back = lostBack * (p.coin / lost);
            }
            if (back > 0) {
                payable(addrs[i]).transfer(back);
            }
        }

        refresh();
    }

    function refresh() private {
        // 标记游戏可以被重新开启
        starttime = 0;
        endtime = 0;
        lasttime = 0;

        for (uint256 i = 0; i < addrs.length; i++) {
            delete players[addrs[i]];
        }

        delete addrs;
    }

    /** 获取当前比赛中输赢双方的押注总额 */
    function getCoin() public view returns (uint256, uint256) {
        uint256 pan = lasttime % 2;
        /** 失去代币的玩家的金额总和 */
        uint256 lost = 0;
        /** 赢得代币的玩家的金额总和 */
        uint256 win = 0;

        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            Player memory p = players[addr];
            if (p.pan == pan) {
                win += p.coin;
            } else {
                lost += p.coin;
            }
        }

        return (win, lost);
    }

    function len() public view returns (uint256) {
        return addrs.length;
    }
}