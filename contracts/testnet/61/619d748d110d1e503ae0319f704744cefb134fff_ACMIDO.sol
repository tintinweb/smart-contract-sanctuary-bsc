// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IPancakeRouter02.sol";
import "./PyramidRelation.sol";
import "./ACMPosition.sol";

contract ACMIDO is Ownable, ReentrancyGuard {

    // 仓位
    // struct Position {
    //     uint startAmount; // 开始金额
    //     uint startTime; // 开始时间
    //     uint pidx;
    // }

    // 参与状态
    struct CrowdfundingStat {
        uint pidx; // 仓位下标
        uint eidx; // 期下标
        uint amount; // 参与金额
        uint stat; // 当前状态 0:未参与 1:筹满领70% 2:当期爆仓 3:第五期结束领30% 4:未来3期内爆仓领LP
    }

    // // 仓位的期
    // struct Epoch {
    //     uint startTime; // 开始时间
    //     uint endTime; // 结束时间
    //     uint amount; // 总筹目标金额
    //     uint fundraised; // 已筹集金额
    //     uint uAmount; // 该期总共筹集U
    //     uint previousAmounts; // 本期需要消耗上一期的费用
    //     uint pidx;
    //     uint eidx;
    // }

    struct Funds {
        uint uAmount; // u数量
        uint tokenAmount; // 代币数量
        address tokenContract; // 合约地址
        uint lpAmount; // lp数量
        
    }

    // 仓位列表
    // Position[] public positions;
    // 合约地址到交易路由的映射
    mapping (address => address) private tokenContractToRouter;
    address[] supportedTokenContract;
    // 每个仓位对应的期列表
    // mapping (uint => Epoch[]) public epochs;
    mapping (bytes32 => uint) public fixedParticipatedFunds;
    // 每个地址参与资金
    mapping (bytes32 => uint) public participatedFunds;
    // 当期筹满时每个地址可领取资金
    mapping (bytes32 => Funds) public currentFunds;
    // 当期爆仓清算金额
    mapping (bytes32 => Funds) public liquidationCurrentFunds;
    // 第五期完成时每个地址可领取资金
    mapping (bytes32 => Funds) public completeFunds;
    // 推荐关系
    PyramidRelation public  relation;
    ACMPosition public acmPosition;
    // U代币
    IERC20 public USD;
    // TCD代币
    IERC20 public TCD;
    // ACM 代币
    IERC20 public ACM;
    // 销毁地址
    address public deathAddress = address(0);
    // 管理员地址
    address public devAddress;
    uint remainingACMSupply = 1540000000000000000000000;

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
    //     epochs[positions.length - 1].push(Epoch(startTime, startTime + 3 * 60 * 60, 100 * 10**18, 0, 0, 0));
    //     // 初始化第二期
    //     epochs[positions.length - 1].push(Epoch(startTime + 6 * 60 * 60, startTime + 9 * 60 * 60, 100 * 10**18, 0, 0, 0));
    // }

    // constructor(IERC20 U, IERC20 A, IERC20 T, address devAddr, address relat) {
    //     USD = U;
    //     TCD = T;
    //     devAddress = devAddr;
    //     relation = PyramidRelation(relat);
    // }

    // 推荐人
    function addRelationEx(address recommer) external nonReentrant {
        require(relation.info(msg.sender).level == 0 && relation.info(recommer).level > 0, "Wrong");
        relation.addRelationEx(recommer);
        // (bool stat, address father) = relation.addRelationEx(recommer);
        // if (stat) {
        //     USD.transfer(father, 10 * 10**18);
        //     relation.addReward(father, 10 * 10**18, 0);
        // }
    }

    // 升级
    function levelUp() external nonReentrant {
        require (relation.info(msg.sender).level > 0 && relation.info(msg.sender).level < 10, "Wrong");
        relation.levelUp(msg.sender);
        // (bool stat, address father) = relation.levelUp(msg.sender);
        // if (stat) {
        //     USD.transfer(father, 10 * 10**18);
        //     relation.addReward(father, 10 * 10**18, 0);
        // }
    }

    // 新增仓位
    function addPosition(uint startAmount) external onlyOwner {
        acmPosition.addPosition(startAmount);
        // require (startAmount >= 100 && startAmount % 10 == 0, "Wrong");
        // uint startTime = 0;
        // startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
        //         DateTime.getMonth(block.timestamp),
        //         DateTime.getDay(block.timestamp),
        //         uint8(6));
        // if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
        //     startTime += 86400;
        // }
        // // 新增仓位
        // positions.push(Position(startAmount * 10**18, startTime, positions.length - 1));
        // // 初始化第一期
        // epochs[positions.length - 1].push(Epoch(startTime, startTime + 3 * 60 * 60, startAmount * 10**18, 0, 0, 0, positions.length - 1, epochs[positions.length  - 1].length - 1));
        // // 初始化第二期
        // epochs[positions.length - 1].push(Epoch(startTime + 6 * 60 * 60, startTime + 9 * 60 * 60, startAmount * 10**18, 0, 0, 0, positions.length - 1, epochs[positions.length  - 1].length - 1));
    }

    // 哈希
    function hash(uint pidx, uint eidx, address addr) public pure returns (bytes32 h) {
        h = keccak256(abi.encodePacked(pidx, 'x', eidx, 'x', addr));
    }

    // 新增期数
    function addEpoch(uint idx) public nonReentrant {
        acmPosition.addEpoch(idx);
        // Position memory p = positions[idx];
        // Epoch memory e = epochs[idx][epochs[idx].length - 1];
        // if (e.startTime < block.timestamp) {
        //     uint startTime = e.startTime;
        //     if (e.endTime < block.timestamp) { // 存在一期完全无人参与的情况，从头开始
        //         startTime = DateTime.toTimestamp(DateTime.getYear(block.timestamp),
        //             DateTime.getMonth(block.timestamp),
        //             DateTime.getDay(block.timestamp),
        //             (epochs[idx].length % 2 == 1 ? 6 : 12));
        //         if (startTime < block.timestamp) { // 如果时间已过，只能从明天开始，规则规定，每仓都必须从早上开始
        //             startTime += 86400;
        //         }
        //     } else {
        //         startTime = startTime + (epochs[idx].length % 2 == 1 ? 6 * 60 * 60 : 18 * 60 * 60);
        //     }
        //     epochs[idx].push(Epoch(startTime, startTime + 3 * 60 * 60, p.startAmount, 0, 0, 0, idx, epochs[idx].length - 1));
        // }
    }

    // 列出该仓位下的期
    function listEpochs(uint idx) public view returns (ACMPosition.Epoch[] memory ret) {
        // ret = epochs[idx];
        ret = acmPosition.listEpochs(idx);
    }

    // 列出所有仓位
    function listPositions() public view returns (ACMPosition.Position[] memory ret) {
        // ret = positions;
        ret = acmPosition.listPositions();
    }

    // 参与，只要当前期进行中就新增一期，状态初始化，筹满更改该期金额，如果新一期完全没人参与导致停滞，需要人工干预
    function crowdfunding(uint idx, uint amount, address tokenContract) external {
        require (tokenContractToRouter[tokenContract] != address(0), "This token is not supported");
        uint participatedAmount = amount * 10**18;
        addEpoch(idx);
        ACMPosition.Epoch[] memory es = acmPosition.listEpochs(idx);
        ACMPosition.Epoch memory e = es[es.length - 2];
        bytes32 h = hash(idx, es.length - 2, msg.sender);
        // 激活才能参加
        require (relation.info(msg.sender).level == 1, "Should addRelationEx");
        // 当期是否开始
        require (block.timestamp >= e.startTime, "Not yet started");
        require (block.timestamp <= e.endTime, "This round of crowdfunding has ended");
        require (e.fundraised + participatedAmount <= e.amount, "Insufficient quota");
        require (fixedParticipatedFunds[h] == 0 && participatedAmount <= e.amount / 100, "Insufficient supply");

        IERC20 token = IERC20(tokenContract);

        // 计算当期满应返及应销毁代币
        Funds storage currentFund = currentFunds[h];
        currentFund.uAmount += participatedAmount * 7 / 10;
        currentFund.tokenAmount += amount * 10**token.decimals() * 3 / 100;
        currentFund.tokenContract = tokenContract;
        // 计算当期爆仓
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        liquidationCurrentFund.uAmount += participatedAmount * 97 / 100;
        liquidationCurrentFund.tokenAmount += amount * 10**token.decimals() * 3 / 100;
        liquidationCurrentFund.tokenContract = tokenContract;

        // 计算第五期满或爆仓应返资金
        Funds storage completeFund = completeFunds[h];
        completeFund.uAmount += participatedAmount * 35 / 100;
        completeFund.lpAmount += participatedAmount * 5 / 100;
        e.previousAmounts += participatedAmount / 10;
        address[] memory fathers = relation.getFathers(msg.sender);
        if (fathers.length > 0 && fathers[0] != address(0)) { // 直推
            completeFunds[hash(idx, es.length - 2, fathers[0])].uAmount += (participatedAmount * 5 / 100);
            e.previousAmounts += participatedAmount * 5 / 100;
        }
        uint tAmount = participatedAmount * 5 / 1000;
        addTeamReward(fathers, idx, es.length - 2, tAmount);
        e.previousAmounts += tAmount;
        participatedFunds[h] += participatedAmount; // 增加该地址参与额度
        fixedParticipatedFunds[h] += participatedAmount; // 增加参与额度

        // 转移用户代币
        uint aAmount = amount * 10**token.decimals() * 3 / 100;
        token.transferFrom(msg.sender, address(this), aAmount);

        // 转移用户U
        uint bAmount = participatedAmount * 97 / 100;
        USD.transferFrom(msg.sender, address(this), bAmount);

        if (e.amount == e.fundraised) { // 筹满的话
            es[es.length - 1].amount = e.amount / 10**18 * 12 / 10 * 10**18;
        }
    }

    function addTeamReward(address[] memory fathers, uint pidx, uint eidx, uint tAmount) private {
        for (uint i = 0; i < fathers.length; i++) { // 团队，levelOK才可以拿团队奖
            address f = fathers[i];
            if (f != address(0) && relation.info(fathers[i]).level > i) {
                bytes32 b = hash(pidx, eidx, f);
                completeFunds[b].uAmount += tAmount;
                relation.addReward(f, 0, tAmount);
            }
        }
    }

    function getCrowdfundingStat(address addr, uint pidx, uint eidx) private view returns (uint types) {
        bytes32 h = hash(pidx, eidx, addr);
        if (acmPosition.isItFull(pidx, eidx) && currentFunds[h].uAmount > 0) {
            types = 1;
        } else if (acmPosition.whetherToLiquidate(pidx, eidx) && liquidationCurrentFunds[h].uAmount > 0) {
            types = 2;
        } else if (acmPosition.isCompleted(pidx, eidx) && !acmPosition.whetherToLiquidate(pidx, eidx) && completeFunds[h].uAmount > 0) {
            types = 3;
        } else if(acmPosition.isLiquidateNextThreeStage(pidx, eidx) && !acmPosition.whetherToLiquidate(pidx, eidx) && participatedFunds[h] > 0) {
            types = 4;
        } else {
            types = 0;
        }
    }

    function listCrowdfundingStat(address addr, uint pidx) external view returns (CrowdfundingStat[] memory stats) {
        ACMPosition.Epoch[] memory es = acmPosition.listEpochs(pidx);
        uint l = 0;
        for (uint i = 0; i< es.length; i++) {
            uint amount = fixedParticipatedFunds[hash(pidx, i, addr)];
            if (amount > 0) {
                l++;
            }
        }
        stats = new CrowdfundingStat[](l);
        uint j = 0;
        for (uint i = 0; i< es.length; i++) {
            uint amount = fixedParticipatedFunds[hash(pidx, i, addr)];
            if (amount > 0) {
                stats[j] = CrowdfundingStat(pidx, i, amount, getCrowdfundingStat(addr, pidx, i));
                j++;
            }
        }
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (acmPosition.isItFull(pidx, eidx), "Conditions do not allow");
        Funds storage currentFund = currentFunds[h];
        require (currentFund.uAmount > 0, "No quantity available");
        uint uAmount = currentFund.uAmount;
        uint tokenAmount = currentFund.tokenAmount;
        currentFund.uAmount = 0;
        currentFund.tokenAmount = 0;
        // 只有代币为ACM才会销毁，否则不销毁
        if ( tokenAmount > 0 && currentFund.tokenContract == address(ACM)) {
            ACM.transfer(deathAddress, tokenAmount);
        }

        // 返还U
        if (uAmount > 0) {
            USD.transfer(msg.sender, uAmount);
        }
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (acmPosition.whetherToLiquidate(pidx, eidx), "Conditions do not allow");
        Funds memory liquidationCurrentFund = liquidationCurrentFunds[h];
        require (liquidationCurrentFund.uAmount > 0, "No quantity available");
        uint uAmount = liquidationCurrentFund.uAmount;
        uint tokenAmount = liquidationCurrentFund.tokenAmount;
        liquidationCurrentFund.uAmount = 0;
        liquidationCurrentFund.tokenAmount = 0;
        IERC20 token = IERC20(liquidationCurrentFund.tokenContract);
        // 返还代币和U ACM总量145万，ACM总量没反完之前会一直反双倍，否则没有双倍
        if (tokenAmount > 0) {
            if (liquidationCurrentFund.tokenContract == address(ACM) && remainingACMSupply >= tokenAmount * 2) {
                remainingACMSupply -= tokenAmount * 2;
                ACM.transfer(msg.sender, tokenAmount * 2);
            } else{
                token.transfer(msg.sender, tokenAmount);
            }
        }
        if (uAmount > 0) {
            USD.transfer(msg.sender, uAmount);
        }
    }

    // 领取第五期筹满或爆仓资金
    function receiveCompleteFunds(uint pidx, uint eidx) external nonReentrant {
        bytes32 h = hash(pidx, eidx, msg.sender);
        require (acmPosition.isCompleted(pidx, eidx) && !acmPosition.whetherToLiquidate(pidx, eidx), "Conditions do not allow");
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
        require (acmPosition.isLiquidateNextThreeStage(pidx, eidx) && !acmPosition.whetherToLiquidate(pidx, eidx), "Conditions do not allow");
        require (participatedFunds[h] > 0, "No quantity available");
        // 找到未来哪期爆仓
        uint liquidateIdx = acmPosition.whoLiquidate(pidx, eidx);
        uint totalAmount = 0; // 总量
        uint subStageAmount = 0;// 减去支出给第一期的量后的总量
        uint totalStageNum = 0;
        uint currentStageNum = 0;
        ACMPosition.Epoch[] memory es = acmPosition.listEpochs(pidx);
        for (uint i = liquidateIdx - 1; i > 0; i--) {
            ACMPosition.Epoch memory e = es[i];
            if (!acmPosition.isItFull(pidx, i) || totalStageNum >= 3) {
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
        // 能组LP的额度
        uint lpAmount = subStageAmount * participatedFunds[h] / totalAmount;
        participatedFunds[h] = 0;
        // 组LP
        _swapAndLiquify(lpAmount, msg.sender);
    } 

    // // 是否爆仓
    // function whetherToLiquidate(uint pidx, uint eidx) internal view returns (bool isLiquidated) {
    //     Epoch memory e = epochs[pidx][eidx];
    //     isLiquidated = e.endTime > block.timestamp && e.fundraised < e.amount;
    // }

    // // 是否筹满
    // function isItFull(uint pidx, uint eidx) internal view returns (bool isFull) {
    //     Epoch memory e = epochs[pidx][eidx];
    //     isFull = e.amount == e.fundraised;
    // }

    // // 判断往后三期是否都筹满且往前第四期是否结束
    // function isCompleted(uint pidx, uint eidx) internal view returns (bool completed) {
    //     Epoch memory e = epochs[pidx][eidx + 4];
    //     completed = !isLiquidateNextThreeStage(pidx, eidx) && block.timestamp > e.endTime;
    // }

    // // 判断往后三期是否爆仓
    // function isLiquidateNextThreeStage(uint pidx, uint eidx) internal view returns (bool done) {
    //     bool w1 = whetherToLiquidate(pidx, eidx + 1);
    //     bool w2 = whetherToLiquidate(pidx, eidx + 2);
    //     bool w3 = whetherToLiquidate(pidx, eidx + 3);
    //     done = w1 || w2 || w3;
    // }

    // // 到底是哪一期爆仓
    // function whoLiquidate(uint pidx, uint eidx) internal view returns (uint who) {
    //     for (uint i = eidx + 1; i <= eidx + 3; i++) {
    //         if (whetherToLiquidate(pidx, i)) {
    //             who = i;
    //             break;
    //         }
    //     }
    // }

    // 交换代币同时增加流动性
    function _swapAndLiquify(uint256 amount, address to) private nonReentrant {
        // uint256 half = amount / 2;
        // uint256 otherHalf = amount - half;
        // uint256 initialBalance = ACM.balanceOf(address(this));

        // // swap tokens for BNB
        // _swapUForToken(half);

        // // how much BNB did we just swap into?
        // uint256 newBalance = ACM.balanceOf(address(this)) - initialBalance;

        // // add liquidity to uniswap
        // _addLiquidity(otherHalf, newBalance, to);
    }

    // swap代币
    // function _swapUForToken(uint256 tokenAmount) private {
    //     // generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(USD);
    //     path[1] = address(TCD);

    //     USD.approve(tokenContractToRouter[address(TCD)], tokenAmount);

    //     // make the swap
    //     IPancakeRouter02(tokenContractToRouter[address(TCD)]).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // accept any amount of ETH
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }

    // // 增加流动性
    // function _addLiquidity(uint256 tokenAmount, uint256 uAmount, address to) private {
    //     // approve token transfer to cover all possible scenarios
    //     IPancakeRouter02 router = IPancakeRouter02(tokenContractToRouter[address(TCD)]);
    //     TCD.approve(address(router), tokenAmount);
    //     USD.approve(address(router), uAmount);

    //     // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
    //     router.addLiquidity(
    //         address(TCD),
    //         address(USD),
    //         tokenAmount,
    //         uAmount,
    //         0, // slippage is unavoidable
    //         0, // slippage is unavoidable
    //         to,
    //         block.timestamp
    //     );
    // }

    function change(IERC20 U, IERC20 A, IERC20 T, address relat, address acmPosi, address dev) external onlyOwner {
        USD = U;
        TCD = T;
        ACM = A;
        devAddress = dev;
        acmPosition = ACMPosition(acmPosi);
        relation = PyramidRelation(relat);
    }

    // 增加支持的代币
    function addTokenContract(address tokenContract, address tokenRouter) external onlyOwner {
        tokenContractToRouter[tokenContract] = tokenRouter;
        if (tokenRouter == address(0)) { // 删除代币
            for (uint i = 0; i < supportedTokenContract.length; i++) {
                if (supportedTokenContract[i] == tokenContract) {
                    supportedTokenContract[i] = supportedTokenContract[supportedTokenContract.length - 1];
                    supportedTokenContract.pop();
                }
            }
        } else {
            supportedTokenContract.push(tokenContract);
        }
    }

    // 列出所有支持的token
    function listSupportedToken() external view returns (address[] memory supportedToken) {
        supportedToken = supportedTokenContract;
    }

    // 获取代币价格
    function getTokenPrice(address tokenContract, uint amount) private view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenContract;
        path[1] = address(USD);
        uint[] memory amounts = IPancakeRouter02(tokenContractToRouter[tokenContract]).getAmountsOut(amount, path);
        return amounts[1];
    }
}