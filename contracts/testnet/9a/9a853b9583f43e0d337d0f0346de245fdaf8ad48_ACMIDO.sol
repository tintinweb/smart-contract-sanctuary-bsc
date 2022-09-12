// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IPancakeRouter02.sol";
import "./PyramidRelation.sol";

contract ACMIDO is Ownable, ReentrancyGuard {

    struct Position {
        uint startAmount;
        uint startTime;
    }

    struct Epoch {
        uint startTime;
        uint endTime;
        uint amount;
        uint fundraised;
        uint uAmount;
        uint acmAmount;
        uint tcdAmount;
        uint previousAmounts;
    }

    struct Funds {
        uint uAmount;
        uint acmAmount;
        uint tcdAmount;
        uint lpAmount;
    }

    Position[] public positions;
    mapping (uint => Epoch[]) public epochs;
    // 每个地址参与资金
    mapping (bytes32 => uint) public participatedFunds;
    // 当期筹满时每个地址可领取资金
    mapping (bytes32 => Funds) public currentFunds;
    // 当期爆仓清算金额
    mapping (bytes32 => Funds) public liquidationCurrentFunds;
    // 第五期完成时每个地址可领取资金
    mapping (bytes32 => Funds) public completeFunds;
    PyramidRelation public  relation;
    IERC20 public USD;
    IERC20 public ACM;
    IERC20 public TCD;
    address public deathAddress = address(0);
    address public devAddress;
    IPancakeRouter02 public swapRouter;

    // constructor() {
    //     uint startTime = 0;

    //     startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
    //             DateTime.getMonth(block.timestamp),
    //             DateTime.getDay(block.timestamp),
    //             uint8(6));
    //     if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
    //         startTime += 86400;
    //     }
    //     // 新增仓位
    //     positions.push(Position(1000 * 10**18, startTime));
    //     // 初始化第一期
    //     epochs[positions.length - 1].push(Epoch(startTime, startTime + 3 * 60 * 60, 100 * 10**18, 0, 0, 0, 0, 0));
    //     // 初始化第二期
    //     epochs[positions.length - 1].push(Epoch(startTime + 6 * 60 * 60, startTime + 9 * 60 * 60, 100 * 10**18, 0, 0, 0, 0, 0));
    // }

    constructor(IERC20 U, IERC20 A, IERC20 T, address devAddr, address router, address relat) {
        USD = U;
        ACM = A;
        TCD = T;
        devAddress = devAddr;
        swapRouter = IPancakeRouter02(router);
        relation = PyramidRelation(relat);
    }

    // 推荐人
    function addRelationEx(address recommer) external nonReentrant {
        require(relation.info(msg.sender).level == 0 && relation.info(recommer).level > 0, "Wrong");
        (bool stat, address father) = relation.addRelationEx(recommer);
        if (stat) {
            USD.transfer(father, 10 * 10**18);
            relation.addReward(father, 10 * 10**18, 0);
        }
    }

    // 升级
    function levelUp() external nonReentrant {
        require (relation.info(msg.sender).level > 0 && relation.info(msg.sender).level < 10, "Wrong");
        (bool stat, address father) = relation.levelUp(msg.sender);
        if (stat) {
            USD.transfer(father, 10 * 10**18);
            relation.addReward(father, 10 * 10**18, 0);
        }
    }

    // 新增仓位
    function addPosition(uint startAmount) external onlyOwner {
        require (startAmount >= 100 && startAmount % 10 == 0, "Wrong");
        uint startTime = 0;
        startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
                DateTime.getMonth(block.timestamp),
                DateTime.getDay(block.timestamp),
                uint8(6));
        if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
            startTime += 86400;
        }
        // 新增仓位
        positions.push(Position(startAmount * 10**18, startTime));
        // 初始化第一期
        epochs[positions.length - 1].push(Epoch(startTime, startTime + 3 * 60 * 60, startAmount * 10**18, 0, 0, 0, 0, 0));
        // 初始化第二期
        epochs[positions.length - 1].push(Epoch(startTime + 6 * 60 * 60, startTime + 9 * 60 * 60, startAmount * 10**18, 0, 0, 0, 0, 0));
    }

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
                    uint8(6));
                if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
                    startTime += 86400;
                }
            } else {
                startTime = startTime + (epochs[idx].length % 2 == 1 ? 6 * 60 * 60 : 18 * 60 * 60);
            }
            epochs[idx].push(Epoch(startTime, startTime + 3 * 60 * 60, p.startAmount, 0, 0, 0, 0, 0));
        }
    }

    function listEpochs(uint idx) public view returns (Epoch[] memory ret) {
        ret = epochs[idx];
    }

    function listPositions() public view returns (Position[] memory ret) {
        ret = positions;
    }

    // 参与，只要当前期进行中就新增一期，状态初始化，筹满更改该期金额，如果新一期完全没人参与导致停滞，需要人工干预
    function acmCrowdfunding(uint idx, uint amount) external {
        amount = amount * 10**18;
        addEpoch(idx);
        Epoch[] memory es = epochs[idx];
        Epoch memory e = es[es.length - 2];
        bytes32 h = hash(idx, es.length - 2, msg.sender);
        // 激活才能参加
        require (relation.info(msg.sender).level == 1, "Should addRelationEx");
        // 当期是否开始
        require (block.timestamp >= e.startTime, "Not yet started");
        require (block.timestamp <= e.endTime, "This round of crowdfunding has ended");
        require (e.fundraised + amount <= e.amount, "Insufficient quota");
        require (participatedFunds[h] + amount <= e.amount / 100, "Insufficient supply");

        // 计算当期满应返及应销毁代币
        Funds storage currentFund = currentFunds[h];
        currentFund.uAmount += amount * 7 / 10;
        currentFund.acmAmount += amount * 3 / 100;
        // 计算当期爆仓
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        liquidationCurrentFund.uAmount += amount * 97 / 100;
        liquidationCurrentFund.acmAmount += amount * 6 / 100;

        // 计算第五期满或爆仓应返资金
        Funds storage completeFund = completeFunds[h];
        completeFund.uAmount += amount * 35 / 100;
        completeFund.lpAmount += amount * 5 / 100;
        e.previousAmounts += amount * 4 / 10;
        address[] memory fathers = relation.getFathers(msg.sender);
        if (fathers.length > 0 && fathers[0] != address(0)) { // 直推
            completeFunds[hash(idx, es.length - 2, fathers[0])].uAmount += (amount * 5 / 100);
            e.previousAmounts += amount * 5 / 100;
        }
        uint tAmount = amount * 5 / 1000;
        for (uint i = 0; i < fathers.length; i++) { // 团队，levelOK才可以拿团队奖
            address f = fathers[i];
            if (f != address(0) && relation.info(fathers[i]).level > i) {
                bytes32 b = hash(idx, es.length - 2, f);
                completeFunds[b].uAmount += tAmount;
                e.previousAmounts += tAmount;
                relation.addReward(f, 0, tAmount);
            }
        }
        participatedFunds[h] += amount; // 增加该地址参与额度

        // 转移用户代币
        uint aAmount = amount * 3 / 100;
        ACM.transferFrom(msg.sender, address(this), aAmount);

        // 转移用户U
        uint bAmount = amount - aAmount;
        USD.transferFrom(msg.sender, address(this), bAmount);

        if (e.amount == e.fundraised) { // 筹满的话
            es[es.length - 1].amount = e.amount / 10**18 * 12 / 10 * 10**18;
        }
    }

    function crowdfundingStat(address addr, uint pidx, uint eidx) external view returns (uint types) {
        bytes32 h = hash(pidx, eidx, addr);
        if (isItFull(pidx, eidx) && currentFunds[h].uAmount > 0) {
            types = 1;
        } else if (whetherToLiquidate(pidx, eidx) && completeFunds[h].uAmount > 0) {
            types = 2;
        } else if (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && completeFunds[h].uAmount > 0) {
            types = 3;
        } else if(isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx) && participatedFunds[h] > 0) {
            types = 4;
        } else {
            types = 0;
        }
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (isItFull(pidx, eidx), "Conditions do not allow");
        Funds storage currentFund = currentFunds[h];
        require (currentFund.uAmount > 0, "No quantity available");
        uint uAmount = currentFund.uAmount;
        uint acmAmount = currentFund.acmAmount;
        uint tcdAmount = currentFund.tcdAmount;
        currentFund.uAmount = 0;
        currentFund.acmAmount = 0;
        currentFund.tcdAmount = 0;
        // 销毁代币
        if (acmAmount > 0) {
            ACM.transfer(deathAddress, acmAmount);
        }
        if (tcdAmount > 0) {
            TCD.transfer(deathAddress, tcdAmount);
        }

        // 返还U
        if (uAmount > 0) {
            USD.transfer(msg.sender, uAmount);
        }
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (whetherToLiquidate(pidx, eidx), "Conditions do not allow");
        Funds memory liquidationCurrentFund = liquidationCurrentFunds[h];
        require (liquidationCurrentFund.uAmount > 0, "No quantity available");
        uint uAmount = liquidationCurrentFund.uAmount;
        uint acmAmount = liquidationCurrentFund.acmAmount;
        uint tcdAmount = liquidationCurrentFund.tcdAmount;
        liquidationCurrentFund.uAmount = 0;
        liquidationCurrentFund.acmAmount = 0;
        liquidationCurrentFund.tcdAmount = 0;
        // 返还代币和U
        if (acmAmount > 0) {
            ACM.transfer(msg.sender, acmAmount);
        }
        if (tcdAmount > 0) {
            TCD.transfer(msg.sender, tcdAmount);
        }
        if (uAmount > 0) {
            USD.transfer(msg.sender, uAmount);
        }
    }

    // 领取第五期筹满或爆仓资金
    function receiveCompleteFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (isCompleted(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Conditions do not allow");
        Funds memory completeFund = completeFunds[h];
        require (completeFund.uAmount > 0, "No quantity available");
        uint uAmount = completeFund.uAmount;
        uint lpAmount = completeFund.lpAmount;
        completeFund.uAmount = 0;
        completeFund.lpAmount = 0;
        // 组LP
        if (lpAmount > 0) {
            _swapAndLiquify(lpAmount, devAddress);
        }
        // 返U
        if (uAmount > 0) {
            USD.transfer(msg.sender, uAmount);
        }
    }

    // 领取爆仓的LP
    function receiveLiquidationFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (isLiquidateNextThreeStage(pidx, eidx) && !whetherToLiquidate(pidx, eidx), "Conditions do not allow");
        require (participatedFunds[h] > 0, "No quantity available");
        // 找到未来哪期爆仓
        uint liquidateIdx = whoLiquidate(pidx, eidx);
        uint totalAmount = 0; // 总量
        uint subStageAmount = 0;// 减去支出给第一期的量后的总量
        uint totalStageNum = 0;
        uint currentStageNum = 0;
        for (uint i = liquidateIdx - 1; i > 0; i--) {
            Epoch memory e = epochs[pidx][i];
            if (!isItFull(pidx, i) || totalStageNum >= 3) {
                break;
            } else {
                totalAmount += e.fundraised;
                totalStageNum += 1;
                currentStageNum = i;
            }
        }
        if (totalStageNum >= 3 && currentStageNum > 1) {
            subStageAmount = totalAmount - epochs[pidx][currentStageNum - 1].previousAmounts;
        }
        // 能组LP的额度
        uint lpAmount = subStageAmount * participatedFunds[h] / totalAmount;
        // 组LP
        _swapAndLiquify(lpAmount, msg.sender);
    } 

    // 是否爆仓
    function whetherToLiquidate(uint pidx, uint eidx) internal view returns (bool isLiquidated) {
        Epoch memory e = epochs[pidx][eidx];
        isLiquidated = e.endTime > block.timestamp && e.fundraised < e.amount;
    }

    // 是否筹满
    function isItFull(uint pidx, uint eidx) internal view returns (bool isFull) {
        Epoch memory e = epochs[pidx][eidx];
        isFull = e.amount == e.fundraised;
    }

    // 判断往后三期是否都筹满且往前第四期是否结束
    function isCompleted(uint pidx, uint eidx) internal view returns (bool completed) {
        Epoch memory e = epochs[pidx][eidx + 4];
        completed = !isLiquidateNextThreeStage(pidx, eidx) && block.timestamp > e.endTime;
    }

    // 判断往后三期是否爆仓
    function isLiquidateNextThreeStage(uint pidx, uint eidx) internal view returns (bool done) {
        bool w1 = whetherToLiquidate(pidx, eidx + 1);
        bool w2 = whetherToLiquidate(pidx, eidx + 2);
        bool w3 = whetherToLiquidate(pidx, eidx + 3);
        done = w1 || w2 || w3;
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

    // 交换代币同时增加流动性
    function _swapAndLiquify(uint256 amount, address to) private nonReentrant {
        uint256 half = amount / 2;
        uint256 otherHalf = amount - half;
        uint256 initialBalance = ACM.balanceOf(address(this));

        // swap tokens for BNB
        _swapUForToken(half);

        // how much BNB did we just swap into?
        uint256 newBalance = ACM.balanceOf(address(this)) - initialBalance;

        // add liquidity to uniswap
        _addLiquidity(otherHalf, newBalance, to);
    }

    // swap代币
    function _swapUForToken(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(USD);
        path[1] = address(ACM);

        USD.approve(address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // 增加流动性
    function _addLiquidity(uint256 tokenAmount, uint256 uAmount, address to) private {
        // approve token transfer to cover all possible scenarios
        ACM.approve(address(swapRouter), tokenAmount);
        USD.approve(address(swapRouter), uAmount);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        swapRouter.addLiquidity(
            address(this),
            address(USD),
            tokenAmount,
            uAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            to,
            block.timestamp
        );
    }


    function changeUSD(IERC20 U) external onlyOwner {
        USD = U;
    }

    function changeACM(IERC20 A) external onlyOwner {
        ACM = A;
    }

    function changeTCD(IERC20 T) external onlyOwner {
        TCD = T;
    }

    function changeDEV(address dev) external onlyOwner {
        devAddress = dev;
    }

    function changeRouter(address addr) external onlyOwner {
        swapRouter = IPancakeRouter02(addr);
    }
}