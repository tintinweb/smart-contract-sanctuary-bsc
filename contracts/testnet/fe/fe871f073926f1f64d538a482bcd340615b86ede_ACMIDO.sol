// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IPancakeRouter02.sol";
import "./PyramidRelation.sol";

contract ACMIDO is Ownable, ReentrancyGuard {

    struct Stage {
        uint startTime;
        uint endTime;
        uint amount;
        uint fundraised;
        uint uAmount;
        uint acmAmount;
        uint tcdAmount;
    }

    struct Funds {
        uint uAmount;
        uint acmAmount;
        uint tcdAmount;
        uint lpAmount;
    }

    Stage[] public stages;
    // 每个地址参与资金
    mapping (uint => mapping (address => uint)) public participatedFunds;
    // 当期筹满时每个地址可领取资金
    mapping (uint => mapping (address => Funds)) internal currentFunds;
    // 当期爆仓清算金额
    mapping (uint => mapping (address => Funds)) internal liquidationCurrentFunds;
    // 第五期完成时每个地址可领取资金
    mapping (uint => mapping (address => Funds)) internal completeFunds;
    // 每期返上期数量
    uint[] internal previousAmounts;
    PyramidRelation public  relation;
    IERC20 public USD;
    IERC20 public ACM;
    IERC20 public TCD;
    address public deathAddress = address(0);
    address public devAddress;
    IPancakeRouter02 public swapRouter;

    constructor(IERC20 U, IERC20 A, IERC20 T, address devAddr, address router) {
        USD = U;
        ACM = A;
        TCD = T;
        devAddress = devAddr;
        swapRouter = IPancakeRouter02(router);
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
    function addStage (uint amount, uint startTime, uint endTime) external onlyOwner {
        Stage memory stage = stages[stages.length - 1];
        require (startTime < endTime && endTime > stage.endTime, "Wrong time");
        require (stage.amount != stage.fundraised || amount > stage.amount * 12 / 10, "Wrong amount");
        stages.push(Stage(startTime, endTime, amount, 0, 0, 0, 0));
    }

    // 参与
    function crowdfunding(uint amount) external nonReentrant {
        require (relation.info(msg.sender).level == 1, "Should addRelationEx");
        require (stages.length > 0, "Not yet started");
        Stage memory stage = stages[stages.length - 1];
        // 当期是否开始
        require (block.timestamp >= stage.startTime, "Not yet started");
        require (block.timestamp <= stage.endTime, "This round of crowdfunding has ended");
        // 是否在时间段内
        uint8 hour = DateTime.getHour(block.timestamp);
        require (hour >= 14 && hour <= 16 || hour >= 19 && hour <= 23, "Not during the active time period");
        require (stage.fundraised + amount <= stage.amount, "Insufficient quota");
        require (amount <= stage.amount / 100, "Insufficient supply");

        // 计算当期满应返及应销毁代币
        Funds storage currentFund = currentFunds[stages.length - 1][msg.sender];
        currentFund.uAmount += amount * 7 / 10;
        currentFund.acmAmount += amount * 3 / 100;
        // 计算当期爆仓
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[stages.length - 1][msg.sender];
        liquidationCurrentFund.uAmount += amount * 97 / 100;
        liquidationCurrentFund.acmAmount += amount * 6 / 100;

        // 计算第五期满或爆仓应返资金
        Funds storage completeFund = completeFunds[stages.length - 1][msg.sender];
        completeFund.uAmount += amount * 35 / 100;
        completeFund.lpAmount += amount * 5 / 100;
        previousAmounts[stages.length - 1] += amount * 4 / 10;
        address[] memory fathers = relation.getFathers(msg.sender);
        address dirPushAddr = fathers[0];
        if (dirPushAddr != address(0)) { // 直推
            completeFunds[stages.length - 1][dirPushAddr].uAmount += amount * 5 / 100;
            previousAmounts[stages.length - 1] += amount * 5 / 100;
        }
        for (uint i = 0; i < fathers.length; i++) { // 团队，levelOK才可以拿团队奖
            if (fathers[i] != address(0) && relation.info(fathers[i]).level > i) {
                completeFunds[stages.length - 1][fathers[i]].uAmount += amount * 5 / 1000;
                previousAmounts[stages.length - 1] += amount * 5 / 100;
                relation.addReward(fathers[i], 0, amount * 5 / 100);
            }
        }
        participatedFunds[stages.length - 1][msg.sender] += amount; // 增加该地址参与额度

        // 转移用户代币
        ACM.transferFrom(msg.sender, address(this), amount * 3 / 100);

        // 转移用户U
        USD.transferFrom(msg.sender, address(this), amount * 97 / 100);
    }

    function crowdfundingStat(address addr, uint idx) external view returns (uint types) {
        if (isItFull(idx) && currentFunds[idx][addr].uAmount > 0) {
            types = 1;
        } else if (whetherToLiquidate(idx) && completeFunds[idx][msg.sender].uAmount > 0) {
            types = 2;
        } else if (isCompleted(idx) && !whetherToLiquidate(idx) && completeFunds[idx][msg.sender].uAmount > 0) {
            types = 3;
        } else if(isLiquidateNextThreeStage(idx) && !whetherToLiquidate(idx) && participatedFunds[idx][msg.sender] > 0) {
            types = 4;
        } else {
            types = 0;
        }
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(uint idx) external nonReentrant {
        require (isItFull(idx), "Conditions do not allow");
        Funds storage currentFund = currentFunds[idx][msg.sender];
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
    function receiveLiquidationCurrentFunds(uint idx) external nonReentrant {
        require (whetherToLiquidate(idx), "Conditions do not allow");
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[idx][msg.sender];
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
    function receiveCompleteFunds(uint idx) external nonReentrant {
        require (isCompleted(idx) && !whetherToLiquidate(idx), "Conditions do not allow");
        Funds storage completeFund = completeFunds[idx][msg.sender];
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
    function receiveLiquidationFunds(uint idx) external nonReentrant {
        require (isLiquidateNextThreeStage(idx) && !whetherToLiquidate(idx), "Conditions do not allow");
        require (participatedFunds[idx][msg.sender] > 0, "No quantity available");
        // 找到未来哪期爆仓
        uint liquidateIdx = whoLiquidate(idx);
        uint totalAmount = 0; // 总量
        uint subStageAmount = 0;// 减去支出给第一期的量后的总量
        uint totalStageNum = 0;
        uint currentStageNum = 0;
        for (uint i = liquidateIdx - 1; i > 0; i--) {
            Stage memory stage = stages[i];
            if (!isItFull(i) || totalStageNum >= 3) {
                break;
            } else {
                totalAmount += stage.fundraised;
                totalStageNum += 1;
                currentStageNum = i;
            }
        }
        if (totalStageNum >= 3 && currentStageNum > 1) {
            subStageAmount = totalAmount - previousAmounts[currentStageNum - 1];
        }
        // 能组LP的额度
        uint lpAmount = subStageAmount * participatedFunds[idx][msg.sender] / totalAmount;
        // 组LP
        _swapAndLiquify(lpAmount, msg.sender);
    } 

    // 是否爆仓
    function whetherToLiquidate(uint idx) internal view returns (bool isLiquidated) {
        Stage memory stage = stages[idx];
        isLiquidated = stage.endTime > block.timestamp && stage.fundraised < stage.amount;
    }

    // 是否筹满
    function isItFull(uint idx) internal view returns (bool isFull) {
        Stage memory stage = stages[idx];
        isFull = stage.amount == stage.fundraised;
    }

    // 判断往后三期是否都筹满且往前第四期是否结束
    function isCompleted(uint idx) internal view returns (bool completed) {
        Stage memory stage = stages[idx + 4];
        completed = !isLiquidateNextThreeStage(idx) && block.timestamp > stage.endTime;
    }

    // 判断往后三期是否爆仓
    function isLiquidateNextThreeStage(uint idx) internal view returns (bool done) {
        bool w1 = whetherToLiquidate(idx + 1);
        bool w2 = whetherToLiquidate(idx + 2);
        bool w3 = whetherToLiquidate(idx + 3);
        done = w1 || w2 || w3;
    }

    // 到底是哪一期爆仓
    function whoLiquidate(uint idx) internal view returns (uint who) {
        for (uint i = idx + 1; i <= idx + 3; i++) {
            if (whetherToLiquidate(i)) {
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

    // 展示所有仓位
    function listStages() external view returns (Stage[] memory ret) {
        ret = stages;
    }
}