// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./PyramidRelation.sol";
import "./ACMClaim.sol";
import "./ACMIDODelegateCall.sol";

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

    address idoDelegateCall;

    constructor (address acmClaimAddr, address relationAddr, address U, address T, address _delegatecall) {
        acmClaim = ACMClaim(acmClaimAddr);
        relation = PyramidRelation(relationAddr);
        USD = U;
        TCD = T;
        idoDelegateCall = _delegatecall;
    }

    // 推荐人
    function addRelationEx(address origRecommer, address recommer, uint layout, uint idx) external nonReentrant {
        (bool _success, ) = idoDelegateCall.delegatecall(
            abi.encodeWithSelector(ACMIDODelegateCall.addRelationEx.selector, origRecommer, recommer, layout, idx)
        );
        require(_success);
    }

    // 升级
    function levelUp() external nonReentrant {
        (bool _success, ) = idoDelegateCall.delegatecall(
            abi.encodeWithSelector(ACMIDODelegateCall.levelUp.selector)
        );
        require(_success);
    }

    // 新增仓位
    function addPosition(uint startAmount) external onlyOwner {
        (bool _success, ) = idoDelegateCall.delegatecall(
            abi.encodeWithSelector(ACMIDODelegateCall.addPosition.selector, startAmount)
        );
        require(_success);
    }

    // 哈希
    function hash(uint pidx, uint eidx, address addr) public pure returns (bytes32 h) {
        h = keccak256(abi.encodePacked(pidx, 'x', eidx, 'x', addr));
    }

    // 新增期数
    function addEpoch(uint idx) public nonReentrant {
        (bool _success, ) = idoDelegateCall.delegatecall(
            abi.encodeWithSelector(ACMIDODelegateCall.addEpoch.selector, idx)
        );
        require(_success);
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
        (bool _success, ) = idoDelegateCall.delegatecall(
            abi.encodeWithSelector(ACMIDODelegateCall.crowdfunding.selector, idx, amount, tokenContract)
        );
        require(_success);
    }

    function full(address addr, uint pidx, uint eidx) external view returns (bool) {
        return isItFull(pidx, eidx) && acmClaim.getCurrentFund(hash(pidx, eidx, addr)).uAmount > 0;
    }

    function liquidation(address addr, uint pidx, uint eidx) external view returns (bool) {
        return whetherToLiquidate(pidx, eidx) && acmClaim.getLiquidationCurrentFund(hash(pidx, eidx, addr)).uAmount > 0;
    }

    function finished(address addr, uint pidx, uint eidx) external view returns (bool) {
        return isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getCompleteFund(hash(pidx, eidx, addr)).uAmount > 0;
    }

    function reorganization(address addr, uint pidx, uint eidx) external view returns (bool) {
        return isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getReorganizationFund(hash(pidx, eidx, addr)).participatedAmount > 0;
    }

    function getCrowdfundingStat(address addr, uint pidx, uint eidx) public view returns (uint types) {
        bytes32 h = hash(pidx, eidx, addr);
        if (isItFull(pidx, eidx) && acmClaim.getCurrentFund(h).uAmount > 0) {
            types = 1;
        } else if (whetherToLiquidate(pidx, eidx) && acmClaim.getLiquidationCurrentFund(h).uAmount > 0) {
            types = 2;
        } else if (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getCompleteFund(h).uAmount > 0) {
            types = 3;
        } else if(isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && acmClaim.getReorganizationFund(h).participatedAmount > 0) {
            types = 4;
        } else {
            types = 0;
        }
    }

    function listCrowdfundingStat(address addr, uint pidx, uint stat) external view returns (CrowdfundingStat[] memory stats) {
        uint[] memory time = participatedTime[addr][pidx];
        stats = new CrowdfundingStat[](time.length);
        for (uint i = 0; i < time.length; i++) {
            uint amount = acmClaim.getReorganizationFund(hash(pidx, time[i], addr)).participatedAmount;
            if (stat == 0 || stat == getCrowdfundingStat(addr, pidx, time[i])) {
                stats[i] = CrowdfundingStat(pidx, time[i], amount, getCrowdfundingStat(addr, pidx, time[i]));
            }
        }
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(uint pidx, uint eidx) external nonReentrant returns (bool) {
        require (isItFull(pidx, eidx), "Wrong conditions");
        acmClaim.receiveCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
        return true;
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(uint pidx, uint eidx) external nonReentrant returns (bool) {
        require (whetherToLiquidate(pidx, eidx), "Wrong conditions");
        acmClaim.receiveLiquidationCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
        return true;
    }

    // 领取第五期筹满或爆仓资金
    function receiveCompleteFunds(uint pidx, uint eidx) external nonReentrant returns (bool) {
        require (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Wrong conditions");
        acmClaim.receiveLiquidationCurrentFunds(hash(pidx, eidx, msg.sender), msg.sender);
        return true;
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
        return acmClaim.getReorganizationFund(hash(pidx, eidx, addr)).participatedAmount * a / b;
    } 

    function receiveLiquidationFunds(uint pidx, uint eidx) external nonReentrant returns (bool) {
        require (isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Wrong conditions");
        (uint subStageAmount, uint totalAmount) = getLiquidation(pidx, eidx);
        acmClaim.receiveLiquidationFunds(hash(pidx, eidx, msg.sender), msg.sender, subStageAmount, totalAmount);
        return true;
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

    function setAcmClaimAndRelation(address acmClaimAddr, address relationAddr, address idoDelegateCallAddress) external onlyOwner {
        acmClaim = ACMClaim(acmClaimAddr);
        relation = PyramidRelation(relationAddr);
        idoDelegateCall = idoDelegateCallAddress;
    }

    function getParticipatedTime(address addr, uint pidx) external view returns (uint[] memory) {
        return participatedTime[addr][pidx];
    }
}