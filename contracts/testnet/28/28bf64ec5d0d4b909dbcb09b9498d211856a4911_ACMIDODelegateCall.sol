// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./DateTime.sol";
import "./PyramidRelation.sol";
import "./ACMClaim.sol";

contract ACMIDODelegateCall {
    // 仓位
    struct Position {
        uint startAmount; // 开始金额
        uint startTime; // 开始时间
        uint pidx;
    }

    // 参与状态
    struct CrowdfundingStat {
        uint pidx; // 仓位下标
        uint eidx; // 期下标
        uint amount; // 参与金额
        uint stat; // 当前状态 0:未参与 1:筹满领70% 2:当期爆仓 3:第五期结束领30% 4:未来3期内爆仓领LP
    }

    // 仓位的期
    struct Epoch {
        uint startTime; // 开始时间
        uint endTime; // 结束时间
        uint amount; // 总筹目标金额
        uint fundraised; // 已筹集金额
        uint uAmount; // 该期总共筹集U
        uint previousAmounts; // 本期需要消耗上一期的费用
        uint pidx;
        uint eidx;
        uint epochNum;
    }

    // 仓位列表
    Position[] public positions;
    // 每个仓位对应的期列表
    mapping (uint => Epoch[]) public epochs;
    // 推荐关系
    PyramidRelation public  relation;
    ACMClaim public acmClaim;
    // U代币
    address public USD;
    address public TCD;
    // address public destory = 0x000000000000000000000000000000000000dEaD;
    address public destory = 0xa4A0cD398b2092E516a4695096419635b1E0a003;
    // 参加场次
    mapping (address => mapping(uint =>uint[])) public participatedTime;

    // 推荐人
    function addRelationEx(address origRecommer, address recommer, uint layout, uint idx) external {
        require(relation.info(msg.sender).level == 0 && relation.info(recommer).level > 0, "Wrong");
        (bool stat, address father) = relation.addRelationEx(origRecommer, recommer, msg.sender, layout, idx);
        if (stat) {
            IERC20(USD).transferFrom(msg.sender, father, 1 * 10**18);
            IERC20(TCD).transferFrom(msg.sender, destory, acmClaim.getTokenPrice(10**18, TCD));
        }
    }

    function levelUp() external {
        require (relation.info(msg.sender).level > 0 && relation.info(msg.sender).level < 10, "Wrong");
        (bool stat, address father) = relation.levelUp(msg.sender);
        if (stat) {
            IERC20(USD).transferFrom(msg.sender, father, 1 * 10**18);
            IERC20(TCD).transferFrom(msg.sender, destory, acmClaim.getTokenPrice(10**18, TCD));
        }
    }

    // 新增仓位
    function addPosition(uint startAmount) external {
        require (startAmount >= 10 && startAmount % 10 == 0, "Wrong");
        uint startTime = 0;
        startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
                DateTime.getMonth(block.timestamp),
                DateTime.getDay(block.timestamp),
                DateTime.getHour(block.timestamp));
        // if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
        //     startTime += 86400;
        // }
        uint pl = positions.length;
        // 新增仓位
        positions.push(Position(startAmount * 10**18, startTime, pl));
        // 初始化第一期
        epochs[pl].push(Epoch(startTime, startTime + 1 * 60 * 60, startAmount * 10**18, 0, 0, 0, pl, 0, 1));
        // 初始化第二期
        epochs[pl].push(Epoch(startTime + 1 * 60 * 60, startTime + 2 * 60 * 60, startAmount * 10**18, 0, 0, 0, pl, 1, 1));
    }

    // 新增期数
    function addEpoch(uint idx) public {
        Position memory p = positions[idx];
        Epoch memory e = epochs[idx][epochs[idx].length - 1];
        if (e.startTime < block.timestamp) {
            uint startTime = e.startTime;
            if (e.endTime < block.timestamp) { // 存在一期完全无人参与的情况，从头开始
                startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
                    DateTime.getMonth(block.timestamp),
                    DateTime.getDay(block.timestamp),
                    // (epochs[idx].length % 2 == 1 ? 6 : 12)
                    DateTime.getHour(block.timestamp));
                // if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
                //     startTime += 86400;
                // }
            } else {
                // startTime = startTime + (epochs[idx].length % 2 == 1 ? 12 * 60 * 60 : 12 * 60 * 60);
                startTime = startTime + 1 * 60 * 60;
            }
            uint epochNum = 1;
            if (e.fundraised == e.amount) {
                epochNum = e.epochNum + 1;
            }
            epochs[idx].push(Epoch(startTime, startTime + 1 * 60 * 60, p.startAmount, 0, 0, 0, idx, epochs[idx].length, epochNum));
        }
    }

    function crowdfunding(uint idx, uint amount, address tokenContract) external {
        require (acmClaim.getTokenContractToRouter(tokenContract) != address(0), "This token is not supported");
        uint participatedAmount = amount * 10**18;
        uint tokenAmount = acmClaim.getTokenPrice(10**IERC20(tokenContract).decimals() * 3 / 100, tokenContract);
        addEpoch(idx);
        Epoch[] memory es = epochs[idx];
        // Epoch memory e = es[es.length - 2];
        Epoch storage e = epochs[idx][es.length - 2];
        Epoch storage e2 = epochs[idx][es.length - 1];
        bytes32 h = hash(idx, es.length - 2, msg.sender);
        // 激活才能参加
        require (relation.info(msg.sender).level >= 1, "Should addRelationEx");
        // 当期是否开始
        require (block.timestamp >= e.startTime && block.timestamp <= e.endTime, "Not yet started");
        // require (block.timestamp <= e.endTime, "This round of crowdfunding has ended");
        require (e.fundraised + participatedAmount <= e.amount, "Insufficient quota");
        require (acmClaim.getReorganizationFund(h).participatedAmount == 0 && participatedAmount <= e.amount / 10, "Insufficient supply");

        e.fundraised += participatedAmount;
        // 计算当期满应返及应销毁代币
        acmClaim.setCurrentFund(h, participatedAmount, participatedAmount * 7 / 10, tokenAmount, tokenContract, e.pidx, e.eidx, e.epochNum);
        // 计算当期爆仓
        acmClaim.setLiquidationCurrentFund(h, participatedAmount, participatedAmount * 97 / 100, tokenAmount, tokenContract, e.pidx, e.eidx, e.epochNum);
        // 计算第五期满或爆仓应返资金
        acmClaim.setCompleteFund(h, participatedAmount, participatedAmount * 35 / 100, participatedAmount * 5 / 100, e.pidx, e.eidx, e.epochNum);
        // 设置重组资金
        acmClaim.setReorganizationFund(h, participatedAmount, e.pidx, e.eidx, e.epochNum);
        e.previousAmounts += participatedAmount / 10;
        address[] memory fathers = relation.getFathers(msg.sender);
        if (fathers.length > 0 && fathers[0] != address(0)) { // 直推
            acmClaim.setCompleteFund(hash(idx, es.length - 2, fathers[0]), 0, participatedAmount * 5 / 100, 0, e.pidx, e.eidx, e.epochNum);
            e.previousAmounts += participatedAmount * 5 / 100;
            addElement(fathers[0], e.pidx, e.eidx);
        }
        uint tAmount = participatedAmount * 5 / 1000;
        e.previousAmounts += addTeamReward(fathers, idx, es.length - 2, e.epochNum, tAmount, participatedAmount);

        // 转移用户代币
        IERC20(tokenContract).transferFrom(msg.sender, address(acmClaim), tokenAmount);

        // 转移用户U
        uint bAmount = participatedAmount * 97 / 100;
        e.uAmount += bAmount;
        IERC20(USD).transferFrom(msg.sender, address(acmClaim), bAmount);

        if (e.amount == e.fundraised) { // 筹满的话
            e2.amount = (e.amount / 10**18 * 12 + 9) / 10 * 10**18;
            e2.epochNum = e.epochNum + 1;
        }
        // 记录参加场次
        participatedTime[msg.sender][idx].push(es.length - 2);
    }

    function addElement(address addr, uint pidx, uint eidx) private {
        uint[] storage p = participatedTime[addr][pidx];
        if (p[p.length - 1] != eidx) {
            p.push(eidx);
        }
    }

    function addTeamReward(address[] memory fathers, uint pidx, uint eidx, uint epochNum, uint tAmount, uint participatedAmount) private returns (uint) {
        uint total = 0;
        for (uint i = 0; i < fathers.length; i++) { // 团队，levelOK才可以拿团队奖
            address f = fathers[i];
            if (f != address(0) && relation.info(fathers[i]).level > i) {
                acmClaim.setCompleteFund(hash(pidx, eidx, f), 0, tAmount, 0, eidx, pidx, epochNum);
                if (i == 0) {
                    relation.addReward(f, participatedAmount, participatedAmount);
                } else {
                    relation.addReward(f, 0, participatedAmount);
                }
                addElement(fathers[i], pidx, eidx);
                total += tAmount;
            }
        }
        return total;
    }

    // 哈希
    function hash(uint pidx, uint eidx, address addr) public pure returns (bytes32 h) {
        h = keccak256(abi.encodePacked(pidx, 'x', eidx, 'x', addr));
    }

   
}