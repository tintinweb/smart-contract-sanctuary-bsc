// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./DateTime.sol";
import "./PyramidRelation.sol";
import "./ACMClaim.sol";

contract ACMIDO is Ownable, ReentrancyGuard {

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

    constructor (address acmClaimAddr, address relationAddr, address U, address T) {
        acmClaim = ACMClaim(acmClaimAddr);
        relation = PyramidRelation(relationAddr);
        USD = U;
        TCD = T;
    }

    // 推荐人
    function addRelationEx(address origRecommer, address recommer, uint layout, uint idx) external nonReentrant {
        require(relation.info(msg.sender).level == 0 && relation.info(recommer).level > 0, "Wrong");
        (bool stat, address father) = relation.addRelationEx(origRecommer, recommer, msg.sender, layout, idx);
        if (stat) {
            IERC20(USD).transferFrom(msg.sender, father, 1 * 10**18);
            IERC20(TCD).transferFrom(msg.sender, destory, 1 * 10**18);
            relation.addReward(father, 1 * 10**18, 0);
        }
    }

    // 升级
    function levelUp() external nonReentrant {
        require (relation.info(msg.sender).level > 0 && relation.info(msg.sender).level < 10, "Wrong");
        (bool stat, address father) = relation.levelUp(msg.sender);
        if (stat) {
            IERC20(USD).transferFrom(msg.sender, father, 1 * 10**18);
            IERC20(TCD).transferFrom(msg.sender, destory, 1 * 10**18);
            relation.addReward(father, 1 * 10**18, 0);
        }
    }

    // 新增仓位
    function addPosition(uint startAmount) external onlyOwner {
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
        epochs[pl].push(Epoch(startTime, startTime + 1 * 60 * 60, startAmount * 10**18, 0, 0, 0, pl, 0));
        // 初始化第二期
        epochs[pl].push(Epoch(startTime + 1 * 60 * 60, startTime + 2 * 60 * 60, startAmount * 10**18, 0, 0, 0, pl, 1));
    }

    // 哈希
    function hash(uint pidx, uint eidx, address addr) public pure returns (bytes32 h) {
        h = keccak256(abi.encodePacked(pidx, 'x', eidx, 'x', addr));
    }

    // 新增期数
    function addEpoch(uint idx) public nonReentrant {
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
            epochs[idx].push(Epoch(startTime, startTime + 1 * 60 * 60, p.startAmount, 0, 0, 0, idx, epochs[idx].length));
        }
    }

    // 列出该仓位下的期
    function listEpochs(uint idx) public view returns (Epoch[] memory ret) {
        ret = epochs[idx];
    }

    // 列出所有仓位
    function listPositions() public view returns (Position[] memory ret) {
        ret = positions;
    }

    // 参与，只要当前期进行中就新增一期，状态初始化，筹满更改该期金额，如果新一期完全没人参与导致停滞，需要人工干预
    function crowdfunding(uint idx, uint amount, address tokenContract) external {
        require (acmClaim.getTokenContractToRouter(tokenContract) != address(0), "This token is not supported");
        uint participatedAmount = amount * 10**18;
        addEpoch(idx);
        Epoch[] memory es = listEpochs(idx);
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
        require (acmClaim.getFixedParticipatedFund(h) == 0 && participatedAmount <= e.amount / 10, "Insufficient supply");

        IERC20 token = IERC20(tokenContract);
        e.fundraised += participatedAmount;
        // 计算当期满应返及应销毁代币
        acmClaim.setCurrentFund(h, participatedAmount * 7 / 10, amount * 10**token.decimals() * 3 / 100, tokenContract);
        // 计算当期爆仓
        acmClaim.setLiquidationCurrentFund(h, participatedAmount * 97 / 100, amount * 10**token.decimals() * 3 / 100, tokenContract);
        // 计算第五期满或爆仓应返资金
        acmClaim.setCompleteFund(h, participatedAmount * 35 / 100, participatedAmount * 5 / 100);
        e.previousAmounts += participatedAmount / 10;
        address[] memory fathers = relation.getFathers(msg.sender);
        if (fathers.length > 0 && fathers[0] != address(0)) { // 直推
            acmClaim.setCompleteFund(hash(idx, es.length - 2, fathers[0]), participatedAmount * 5 / 100, 0);
            e.previousAmounts += participatedAmount * 5 / 100;
        }
        uint tAmount = participatedAmount * 5 / 1000;
        e.previousAmounts += addTeamReward(fathers, idx, es.length - 2, tAmount);
        acmClaim.setParticipatedFund(h, participatedAmount);
        acmClaim.setFixedParticipatedFund(h, participatedAmount);

        // 转移用户代币
        uint aAmount = amount * 10**token.decimals() * 3 / 100;
        token.transferFrom(msg.sender, address(acmClaim), aAmount);

        // 转移用户U
        uint bAmount = participatedAmount * 97 / 100;
        e.uAmount += bAmount;
        IERC20(USD).transferFrom(msg.sender, address(acmClaim), bAmount);

        if (e.amount == e.fundraised) { // 筹满的话
            e2.amount = e.amount / 10**18 * 12 / 10 * 10**18;
        }
        // 记录参加场次
        participatedTime[msg.sender][idx].push(es.length - 2);
    }

    function addTeamReward(address[] memory fathers, uint pidx, uint eidx, uint tAmount) private returns (uint) {
        uint total = 0;
        for (uint i = 0; i < fathers.length; i++) { // 团队，levelOK才可以拿团队奖
            address f = fathers[i];
            if (f != address(0) && relation.info(fathers[i]).level > i) {
                acmClaim.setCompleteFund(hash(pidx, eidx, f), tAmount, 0);
                relation.addReward(f, 0, tAmount);
                total += tAmount;
            }
        }
        return total;
    }

    function getCrowdfundingStat(address addr, uint pidx, uint eidx) private view returns (uint types) {
        bytes32 h = hash(pidx, eidx, addr);
        if (isItFull(pidx, eidx) && acmClaim.getCurrentFund(h).uAmount > 0) {
            types = 1;
        } else if (whetherToLiquidate(pidx, eidx) && acmClaim.getLiquidationCurrentFund(h).uAmount > 0) {
            types = 2;
        } else if (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getCompleteFund(h).uAmount > 0) {
            types = 3;
        } else if(isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getParticipatedFund(h) > 0) {
            types = 4;
        } else {
            types = 0;
        }
    }

    function listCrowdfundingStat(address addr, uint pidx, uint stat) external view returns (CrowdfundingStat[] memory stats) {
        uint[] memory time = participatedTime[addr][pidx];
        stats = new CrowdfundingStat[](time.length);
        for (uint i = 0; i < time.length; i++) {
            uint amount = acmClaim.getFixedParticipatedFund(hash(pidx, time[i], addr));
            if (stat == 0 || stat == getCrowdfundingStat(addr, pidx, time[i])) {
                stats[i] = CrowdfundingStat(pidx, time[i], amount, getCrowdfundingStat(addr, pidx, time[i]));
            }
        }
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        require (isItFull(pidx, eidx), "Wrong conditions");
        acmClaim.receiveCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        require (whetherToLiquidate(pidx, eidx), "Wrong conditions");
        acmClaim.receiveLiquidationCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
    }

    // 领取第五期筹满或爆仓资金
    function receiveCompleteFunds(uint pidx, uint eidx) external nonReentrant {
        require (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Wrong conditions");
        acmClaim.receiveLiquidationCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
    }

    function getLiquidation(uint pidx, uint eidx) public view returns (uint subStageAmount, uint totalAmount) {
        if (!(isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx))) {
            return (0, 1);
        }
        // 找到未来哪期爆仓
        uint liquidateIdx = whoLiquidate(pidx, eidx);
        uint totalStageNum = 0;
        uint currentStageNum = 0;
        Epoch[] memory es = listEpochs(pidx);
        for (uint i = liquidateIdx - 1; i > 0; i--) {
            Epoch memory e = es[i];
            if (!isItFull(pidx, i) || totalStageNum >= 3) {
                break;
            } else {
                totalAmount += e.fundraised;
                totalStageNum += 1;
                currentStageNum = i;
            }
        }
        if (totalStageNum >= 3 && currentStageNum > 1) {
            subStageAmount = totalAmount - es[currentStageNum - 1].previousAmounts;
        }
    }

    // 领取爆仓的LP
    function getLiquidationFunds(uint pidx, uint eidx, address addr) external view returns (uint) {
        (uint a, uint b) = getLiquidation(pidx, eidx);
        return acmClaim.getParticipatedFund(hash(pidx, eidx, addr)) * a / b;
    } 

    function receiveLiquidationFunds(uint pidx, uint eidx) external nonReentrant {
        require (isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Wrong conditions");
        (uint subStageAmount, uint totalAmount) = getLiquidation(pidx, eidx);
        acmClaim.receiveLiquidationFunds(hash(pidx, eidx, msg.sender), msg.sender, subStageAmount, totalAmount);
    } 

    // 是否爆仓
    function whetherToLiquidate(uint pidx, uint eidx) internal view returns (bool isLiquidated) {
        Epoch memory e = epochs[pidx][eidx];
        isLiquidated = e.endTime < block.timestamp && e.fundraised < e.amount;
    }

    // 是否筹满
    function isItFull(uint pidx, uint eidx) internal view returns (bool isFull) {
        Epoch memory e = epochs[pidx][eidx];
        isFull = e.amount == e.fundraised;
    }

    // 判断往后三期是否都筹满且往前第四期是否结束
    function isCompleted(uint pidx, uint eidx) internal view returns (bool completed) {
        if (epochs[pidx].length >= eidx + 4) {
            Epoch memory e = epochs[pidx][eidx + 4];
            completed = !isLiquidateNextThreeStage(pidx, eidx) && block.timestamp > e.endTime;
        }
    }

    // 判断往后三期是否爆仓
    function isLiquidateNextThreeStage(uint pidx, uint eidx) internal view returns (bool done) {
        if (epochs[pidx].length >= eidx + 3) {
            bool w1 = whetherToLiquidate(pidx, eidx + 1);
            bool w2 = whetherToLiquidate(pidx, eidx + 2);
            bool w3 = whetherToLiquidate(pidx, eidx + 3);
            done = w1 || w2 || w3;
        }
    }

    // 到底是哪一期爆仓
    function whoLiquidate(uint pidx, uint eidx) internal view returns (uint who) {
        for (uint i = eidx + 1; i <= eidx + 3; i++) {
            if (whetherToLiquidate(pidx, i)) {
                who = i;
                break;
            }
        }
    }

    // // 列出所有支持的token
    // function listSupportedToken() external view returns (address[] memory supportedToken) {
    //     supportedToken = acmClaim.listSupportedToken();
    // }

    function setAcmClaimAndRelation(address acmClaimAddr, address relationAddr) external onlyOwner {
        acmClaim = ACMClaim(acmClaimAddr);
        relation = PyramidRelation(relationAddr);
    }
}