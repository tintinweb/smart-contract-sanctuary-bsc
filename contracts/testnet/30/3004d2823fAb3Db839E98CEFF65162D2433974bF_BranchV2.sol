// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interface/IMain.sol";
import "./interface/IFuel.sol";
import "./interface/IFuelDeposit.sol";
import "./interface/DoubleEndedQueueAddress.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract BranchV2 is ReentrancyGuard, AccessControlEnumerable {
    using SafeERC20 for IERC20;
    using DoubleEndedQueue for DoubleEndedQueue.AddressDeque;

    // 基础配置
    uint32[] versionTimestamps;
    uint32 versionTimes;
    // uint32 dayInterval = 24 * 60 * 60;
    uint32 dayInterval = 60;
    address main = 0xa81aA4a563648acC16d70FDc1dc6af0e1af8E973;
    address usdt = 0xbd1E08E4d1B8290892c14cF2caA70D63d00b8d71;
    address fuel = 0x97a8642Db64dc5aD2bA6F68dF7eD070Bb14B665B;
    address daos = 0x2388F6591A9Dc6b778e5fFffe1cBb46744aB600F;
    address fuelRescue = 0x75249d181eba08cA66E4B4F6430112f9Eed96Af1;
    // 管理员配置
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    //  存款资产 79.5%
    uint256 public depositBalance; // 分行存款总金额
    uint256 public waitingFinalPayBalance; // 已交定金未交尾款的总金额
    uint256 public waitingWithdrawBalance; // 待取款总金额

    // 用户/经纪人模块配置 19%--------------------------------------
    uint8[] public levelUpFollowCount = [0, 2, 2, 2, 2, 2]; // 代理人升级条件
    uint8[] public brokerBonusPercent = [0, 7, 10, 13, 15, 18]; // 各级代理人从直接下级抽取的佣金比例
    uint8 public topBrokerBonusPercent = 1; // 顶级代理人同级抽拥比例
    uint8 public baseRatePercent = 15; // 基础利率

    uint256[] public brokerMaxDepositAmountEach = [1000e18, 1000e18, 3000e18, 5000e18, 7000e18, 10000e18]; //各级代理人最大的存款额度
    uint32[] public depositInterval = [7 * dayInterval, 7 * dayInterval, 5 * dayInterval, 3 * dayInterval, 2 * dayInterval, 1 * dayInterval]; // 各级代理人存款时间间隔
    uint256 public depositTotalMin = 1000e18; // 普通用户(M0)升级到M1代理人最低累计存储金额

    // 用户/经纪人模块数据
    struct Account {
        address parent; // 上级地址
        address[] follows; //下级地址
        uint8 level; //等级
        uint256 id;
    }
    struct Broker {
        uint32 currentVersionTimestamp;
        uint256 depositTotal; // 总的存款额度
        uint256 depositCurrent; // 正在进行的额度
        uint256 brokerBonusCalc; // 代理人累计收益(可大于最大可获得收益,但超出部分无法领取)
        uint256 brokerBonusMax; // 代理人还剩下最大可获得收益
        uint256 brokerBonusWithdrawed; // 代理人已经领取的奖励之和
        uint256 punishTimes; // 惩罚次数
        int256 profitAmount; // 盈利
    }
    mapping(address => Account) public accounts;
    mapping(address => Broker) public brokers;

    // 存款配置
    mapping(uint32 => uint256) public depositAmountDays; // 每日存款额度
    uint8[] public finalPayRandom = [0, 3, 4, 5, 6, 7, 10, 15, 20, 30, 40, 50, 60, 70, 80, 100, 140, 160, 200]; // 触发缴纳尾款的概率(千分)
    uint8[][] public withdrawRandom = [
        [0, 0, 0, 0, 0, 0, 23, 20, 17, 15, 25], //
        [0, 0, 0, 0, 0, 23, 20, 17, 15, 25, 0], //
        [0, 0, 0, 0, 32, 25, 15, 16, 12, 0, 0], //
        [0, 0, 0, 45, 23, 17, 5, 0, 0, 0, 0], //
        [0, 0, 0, 65, 30, 5, 0, 0, 0, 0, 0]
    ];

    struct Deposit {
        uint256 amount; // 存款金额
        uint256 preAmount;
        uint256 finalAmount;
        uint256 withdrawAmount;
        uint8 ratePercent; // 利率
        uint32 createTimestamp;
        uint32 startFinalPayTimestamp; // 开始支付尾款时间
        uint32 endFinalPayTimestamp; // 结束支付尾款时间
        uint32 drawableTimestamp; // 申请提取尾款时间
        uint8 status; // 0:初始化状态;10:交定金=>等待付尾款(等时间戳到);20:已付尾款,等待取款;30:已完成;40:超时交尾款;50:已经触发重启
    }

    mapping(address => Deposit[]) public deposits; //   正在进行的所有订单

    constructor() {
        _setupRole(OPERATOR_ROLE, _msgSender());
        versionTimestamps.push(uint32(block.timestamp));
        versionTimes = 0;
        // dev stage
        // fuel = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        // usdt = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
        // main = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;
        // fuelRescue = 0x7228AAe2BA96E881c12AbF524db3392c905052e6;
        // dayInterval = 60;
        // todo:将控盘方法独立为一个单独的合约,并且不进行代码验证,以保证控盘细节不泄露!!!
    }

    // test用
    function testEditLevel(address addr, uint8 level) external {
        accounts[addr].level = level;
    }

    function testEditBaseBalance(
        uint256 _depositBalance,
        uint256 _waitingFinalPayBalance,
        uint256 _waitingWithdrawBalance
    ) external {
        depositBalance = _depositBalance;
        waitingFinalPayBalance = _waitingFinalPayBalance;
        waitingWithdrawBalance = _waitingWithdrawBalance;
    }

    // 基础配置模块
    function setDepositInterval(uint8 _index, uint32 interval) external onlyRole(OPERATOR_ROLE) {
        depositInterval[_index] = interval;
    }

    function setBrokerMaxDepositAmountEach(uint8 _index, uint256 amount) external onlyRole(OPERATOR_ROLE) {
        brokerMaxDepositAmountEach[_index] = amount;
    }

    function setLevelUpFollowCount(uint8 _index, uint8 count) external onlyRole(OPERATOR_ROLE) {
        levelUpFollowCount[_index] = count;
    }

    function versionTimeList() external view returns (uint32[] memory) {
        return versionTimestamps;
    }

    // 用户管理模块
    function active(uint32 branchId, address parent) external {
        bool result = IMain(main).accountActive(msg.sender, branchId, parent);
        if (result) {
            IERC20(fuel).safeTransferFrom(msg.sender, address(this), 1e18);
            if (parent != address(0)) {
                accounts[msg.sender].parent = parent;
            }
            brokers[msg.sender].currentVersionTimestamp = versionTimestamps[versionTimes];
            accounts[msg.sender].id = createId(msg.sender);
            accounts[parent].follows.push(msg.sender);
        }
    }

    function invite(uint32 branchId, address addr) external {
        bool result = IMain(main).accountActive(addr, branchId, msg.sender);
        if (result) {
            IERC20(fuel).safeTransferFrom(msg.sender, address(this), 1e18);
            accounts[addr].parent = msg.sender;
            accounts[addr].id = createId(addr);
            brokers[addr].currentVersionTimestamp = versionTimestamps[versionTimes];
            accounts[msg.sender].follows.push(addr);
        }
    }

    function levelUp(uint8 target) external {
        require(target > accounts[msg.sender].level, "Already higher level.");
        if (target == 1) {
            if (brokers[msg.sender].depositTotal >= depositTotalMin) {
                accounts[msg.sender].level = target;
                return;
            }
        } else {
            uint256 count = 0;
            address[] storage follows = accounts[msg.sender].follows;
            for (uint256 i = 0; i < follows.length; i++) {
                if (accounts[follows[i]].level >= (target - 1)) {
                    count += 1;
                    if (count >= levelUpFollowCount[target]) {
                        accounts[msg.sender].level = target;
                        return;
                    }
                }
            }
        }
        revert("Upgrade conditions not met.");
    }

    function followList(address addr) external view returns (address[] memory addrs, uint256[] memory levels) {
        addrs = accounts[addr].follows;
        levels = new uint256[](addrs.length);
        for (uint256 i = 0; i < addrs.length; i++) {
            levels[i] = accounts[addrs[i]].level;
        }
    }

    function setLevelUpFollows(uint256 level, uint8 cnt) external onlyRole(OPERATOR_ROLE) {
        levelUpFollowCount[level] = cnt;
    }

    // ---------存取款模块----------
    // 用户预付款
    function userPreDeposit(uint256 amount, bool useCommentReward) external nonReentrant {
        require(amount >= 100e18, "amount must bigger than 100");
        require(amount % 1e18 == 0, "amount can't be divided by 1");
        require(depositRemainToday() > 0, "insufficient remain today");
        require(!useCommentReward || commentRewardTimes[msg.sender] > 0, "You have not commentReward");
        require(accounts[msg.sender].id != 0, "account have not actived.");
        require(amount <= brokerMaxDepositAmountEach[accounts[msg.sender].level], "amount limit of your level");
        require(deposits[msg.sender].length == 0 || block.timestamp - deposits[msg.sender][deposits[msg.sender].length - 1].createTimestamp >= depositInterval[accounts[msg.sender].level], "deposit interval limit of your level.");
        require(!userCheckBlacklist(msg.sender), "You are in blacklist");
        _lossCompensationClaim(msg.sender);

        uint256 preAmount = amount / 10;
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), preAmount);
        Deposit storage deposit = deposits[msg.sender].push();
        deposit.amount = amount;
        deposit.preAmount = preAmount;
        deposit.finalAmount = amount - preAmount;
        deposit.ratePercent = baseRatePercent;
        if (useCommentReward) {
            commentRewardTimes[msg.sender] -= 1;
            deposit.ratePercent += commentRewardRate;
        }
        deposit.withdrawAmount = amount + (amount * deposit.ratePercent) / 100;
        deposit.createTimestamp = uint32(block.timestamp);
        uint256 days_ = randomStartFinalPay(msg.sender);
        deposit.startFinalPayTimestamp = uint32(block.timestamp + days_ * dayInterval);
        deposit.endFinalPayTimestamp = uint32(block.timestamp + (days_ + 10) * dayInterval); // todo:正式需将10改为2
        deposit.status = 10;

        waitingFinalPayBalance += deposit.finalAmount;
        brokers[msg.sender].depositTotal += preAmount;
        brokers[msg.sender].depositCurrent += preAmount;
        brokers[msg.sender].brokerBonusMax += preAmount * 3;
        brokers[msg.sender].profitAmount -= int256(preAmount);
        depositAmountDays[today()] += preAmount;
        allocAmount(preAmount);
    }

    // 用户支付尾款
    function userFinalDeposit(uint256 _index) external nonReentrant {
        Deposit storage deposit = deposits[msg.sender][_index];
        require(deposit.status == 10, "deposit status error.");
        require(block.timestamp >= deposit.startFinalPayTimestamp, "deposit not allow final pay.");
        require(block.timestamp < deposit.endFinalPayTimestamp, "deposit is over time.");
        // require(!userCheckBlacklist(msg.sender), "You are in blacklist");
        _lossCompensationClaim(msg.sender);
        uint256 finalAmount = deposit.finalAmount;
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), finalAmount);
        deposit.status = 20;

        uint256 days_ = randomStartWithdrawDays(msg.sender);
        deposit.drawableTimestamp = uint32(block.timestamp + days_ * dayInterval);
        waitingFinalPayBalance -= finalAmount;
        waitingWithdrawBalance += deposit.withdrawAmount;
        brokers[msg.sender].depositTotal += finalAmount;
        brokers[msg.sender].depositCurrent += finalAmount;
        brokers[msg.sender].brokerBonusMax += finalAmount * 3;
        brokers[msg.sender].profitAmount -= int256(finalAmount);
        depositAmountDays[today()] += finalAmount;
        allocAmount(finalAmount);
    }

    function userWithdraw(uint256 _index) external nonReentrant {
        require(!userCheckBlacklist(msg.sender), "You are in blacklist");
        Deposit memory deposit = deposits[msg.sender][_index];
        require(deposit.status == 20 || deposit.status == 50, "Deposit can`t withdraw");
        require(deposit.drawableTimestamp <= block.timestamp, "Deposit time have not yet.");
        _lossCompensationClaim(msg.sender);
        uint256 fuelAmount = deposit.withdrawAmount / 100;
        waitingWithdrawBalance -= deposit.withdrawAmount;
        depositBalance -= deposit.withdrawAmount;
        brokers[msg.sender].depositCurrent -= deposit.amount;
        brokers[msg.sender].profitAmount += int256(deposit.withdrawAmount);
        deposits[msg.sender][_index].status = 30;
        commentRewardSubmitTimes[msg.sender] += 1;
        IFuel(fuel).burnFrom(msg.sender, fuelAmount);
        IERC20(usdt).safeTransfer(msg.sender, deposit.withdrawAmount);
    }

    function allocAmount(uint256 amount) private {
        uint256 brokerAmount = (amount * 19) / 100;
        sprintBalance += (amount * 4) / 1000;
        fomoBalance += (amount * 1) / 1000;
        restartBalance += (amount * 5) / 1000;
        fuelRescueBalance += (amount * 5) / 1000;
        depositBalance += (amount * 795) / 1000;
        processBrokerBonus(msg.sender, brokerAmount); // 处理经纪人分红
        processFomoReward(msg.sender); // 处理fomo奖
        processSprintReward(msg.sender); // 处理特殊参与奖
        IERC20(usdt).safeApprove(fuelRescue, (amount * 5) / 1000); // 处理援助池
        IFuelDeposit(fuelRescue).fuelRescue((amount * 5) / 1000); //
    }

    // 处理经纪人分红
    function processBrokerBonus(address addr, uint256 amount) private {
        uint8 level = 0;
        uint256 _amount = amount;
        for (uint256 i = 0; i < 30; i++) {
            address parent = accounts[addr].parent;
            if (parent == address(0)) {
                break;
            }
            uint8 parentLevel = accounts[parent].level;
            if (parentLevel == level && level == 5) {
                uint256 bonus = (_amount * topBrokerBonusPercent) / 19;
                bonus = verifyBrokerBonus(parent, bonus);
                amount -= bonus;
                break;
            } else if (brokerBonusPercent[parentLevel] > brokerBonusPercent[level]) {
                uint8 diffPercent = brokerBonusPercent[parentLevel] - brokerBonusPercent[level];
                uint256 bonus = (_amount * diffPercent) / 19;
                bonus = verifyBrokerBonus(parent, bonus);
                amount -= bonus;
            }
            level = parentLevel;
            addr = parent;
        }
        if (amount > 0) {
            depositBalance += amount;
        }
    }

    function verifyBrokerBonus(address addr, uint256 amount) private returns (uint256) {
        if (brokers[addr].depositCurrent < amount) {
            amount = brokers[addr].depositCurrent;
        }
        brokers[addr].brokerBonusCalc += amount;
        return amount;
    }

    function brokerBonusWithdraw() external nonReentrant {
        require(brokers[msg.sender].depositCurrent > 0, "you current deposit is empty.");
        if (brokers[msg.sender].brokerBonusMax > 0 && brokers[msg.sender].brokerBonusCalc > brokers[msg.sender].brokerBonusWithdrawed) {
            uint256 amount = brokers[msg.sender].brokerBonusCalc - brokers[msg.sender].brokerBonusWithdrawed;
            if (amount > brokers[msg.sender].brokerBonusMax) {
                amount = brokers[msg.sender].brokerBonusMax;
            }
            brokers[msg.sender].brokerBonusMax -= amount;
            brokers[msg.sender].brokerBonusWithdrawed += amount;
            brokers[msg.sender].profitAmount += int256(amount);
            IFuel(fuel).burnFrom(msg.sender, amount);
            IERC20(usdt).safeTransfer(msg.sender, amount);
        }
    }

    function userCheckBlacklist(address addr) public view returns (bool result) {
        Deposit[] storage deposits_ = deposits[addr];
        for (uint256 i = 0; i < deposits_.length; i++) {
            if (deposits_[i].status == 10 && block.timestamp > deposits_[i].endFinalPayTimestamp) {
                return true;
            }
        }
    }

    function userDealBlacklist(uint256 index) external nonReentrant {
        Deposit storage deposit = deposits[msg.sender][index];
        require(deposit.status == 10, "deposit status error.");
        require(block.timestamp > deposit.endFinalPayTimestamp, "deposit have no overtime");
        brokers[msg.sender].punishTimes += 1;
        require(block.timestamp >= deposit.endFinalPayTimestamp + 7 * dayInterval * brokers[msg.sender].punishTimes, "deposit in punish time");
        deposit.status = 40;
        IERC20(fuel).transferFrom(msg.sender, address(this), 100e18 * brokers[msg.sender].punishTimes);
    }

    function userDepositList(address addr) external view returns (Deposit[] memory) {
        return deposits[addr];
    }

    // 处理待付尾款
    function randomStartFinalPay(address addr) private view returns (uint256 days_) {
        uint256 k;
        if (brokers[addr].depositTotal == 0) {
            k = 400;
        } else {
            k = depositWithdrawRatePercent();
        }
        if (k <= 400) {
            days_ = randomFinalPayDays(11);
        } else if (k <= 2000) {
            days_ = randomFinalPayDays(15);
        } else {
            days_ = randomFinalPayDays(18);
        }
    }

    // 处理待取款
    function randomStartWithdrawDays(address addr) private view returns (uint256 days_) {
        uint256 k = depositWithdrawRatePercent();
        if (k < 150) {
            days_ = randomWithdrawDays(0);
        } else if (k < 500) {
            days_ = randomWithdrawDays(1);
        } else if (k < 1000) {
            days_ = randomWithdrawDays(2);
        } else if (k < 1500) {
            days_ = randomWithdrawDays(3);
        } else {
            days_ = randomWithdrawDays(4);
        }
        uint8 level = accounts[addr].level;
        if (level > 1) {
            days_ += level - 1;
        }
        if (days_ > 10) {
            days_ = 10;
        }
    }

    // 每小时计算一次(暂时用实时计算)
    function depositWithdrawRatePercent() private view returns (uint256) {
        if (waitingWithdrawBalance != 0) {
            return ((depositBalance + waitingFinalPayBalance) * 100) / waitingWithdrawBalance;
        } else {
            return 1000000;
        }
    }

    function randomFinalPayDays(uint256 end) private view returns (uint256 days_) {
        uint256 randomSum;
        for (uint256 i = 0; i < end; i++) {
            randomSum += finalPayRandom[i];
        }
        uint256 random = createRandom(randomSum);
        randomSum = 0;
        for (uint256 i = 0; i < end; i++) {
            randomSum += finalPayRandom[i];
            if (random < randomSum) {
                days_ = i;
                break;
            }
        }
    }

    function randomWithdrawDays(uint256 x) private view returns (uint256 days_) {
        uint256 randomSum;
        for (uint256 i = 0; i < 10; i++) {
            randomSum += withdrawRandom[x][i];
        }
        uint256 random = createRandom(randomSum);
        randomSum = 0;
        for (uint256 i = 0; i < 10; i++) {
            randomSum += withdrawRandom[x][i];
            if (random < randomSum) {
                days_ = i;
                break;
            }
        }
    }

    // fomo模块 0.1% --------------------------------------------------
    uint256 public fomoBalance;
    uint256 public fomoStartMinBalance;
    uint256 public fomoCalcMinAmount; // 用户累计最小存款额度
    uint256 public fomoWaitingSeconds;
    address public fomoCurrentAccount;
    uint256 public fomoEndTimestamp; // fomo结束时间戳
    mapping(address => uint256) public fomoRewardDrawables;

    function fomoInit(
        uint256 startMinBalance,
        uint256 calcMinAmount,
        uint256 waitingSeconds
    ) external onlyRole(OPERATOR_ROLE) {
        fomoStartMinBalance = startMinBalance;
        fomoCalcMinAmount = calcMinAmount;
        fomoWaitingSeconds = waitingSeconds;
    }

    function processFomoReward(address addr) private {
        if (fomoBalance >= fomoStartMinBalance && block.timestamp >= fomoEndTimestamp) {
            fomoRewardDrawables[fomoCurrentAccount] += fomoBalance;
            fomoBalance = 0;
        }
        if (brokers[addr].depositTotal >= fomoCalcMinAmount) {
            fomoCurrentAccount = addr;
            fomoEndTimestamp = block.timestamp + fomoWaitingSeconds;
        }
    }

    function fomoRewardWithdraw() external nonReentrant {
        require(!userCheckBlacklist(msg.sender), "You are in blacklist");
        require(fomoRewardDrawables[msg.sender] > 0, "Insufficient of fomoRewardDrawable");
        IFuel(fuel).burnFrom(msg.sender, fomoRewardDrawables[msg.sender] / 100);
        IERC20(usdt).safeTransfer(msg.sender, fomoRewardDrawables[msg.sender]);
        brokers[msg.sender].profitAmount += int256(fomoRewardDrawables[msg.sender]);
        fomoRewardDrawables[msg.sender] = 0;
    }

    // 特殊参与奖/冲刺奖模块 0.4%------------------------------
    uint256 public sprintBalance;
    uint256 public sprintMin;
    DoubleEndedQueue.AddressDeque private last100Accounts;
    mapping(address => bool) private isLast100Accounts;
    mapping(address => uint256) public sprintRewardDrawables;

    function last100AccountList() external view returns (address[] memory) {
        address[] memory last100AccountList_ = new address[](last100Accounts.length());
        for (uint256 i = 0; i < last100Accounts.length(); i++) {
            last100AccountList_[i] = last100Accounts.at(i);
        }
        return last100AccountList_;
    }

    function sprintInit(uint256 _sprintMin) external onlyRole(OPERATOR_ROLE) {
        sprintMin = _sprintMin;
    }

    function processSprintReward(address addr) private {
        if (brokers[addr].depositTotal >= sprintMin) {
            if (!isLast100Accounts[addr]) {
                last100Accounts.pushBack(addr);
                isLast100Accounts[addr] = true;
            }
            if (last100Accounts.length() > 100) {
                delete isLast100Accounts[last100Accounts.popFront()];
            }
        }
    }

    function activeSprintReward() private {
        require(true, "This is not restart time");
        uint256 sprintBalanceEach = sprintBalance / last100Accounts.length();
        for (uint256 i = 0; i < last100Accounts.length(); i++) {
            sprintRewardDrawables[last100Accounts.at(i)] += sprintBalanceEach;
        }
        sprintBalance = 0;
        last100Accounts.clear();
    }

    function sprintRewardWithdraw() external nonReentrant {
        require(!userCheckBlacklist(msg.sender), "You are in blacklist");
        require(sprintRewardDrawables[msg.sender] > 0, "Insufficient of sprintRewardDrawable");
        IFuel(fuel).burnFrom(msg.sender, sprintRewardDrawables[msg.sender] / 100);
        IERC20(usdt).safeTransfer(msg.sender, sprintRewardDrawables[msg.sender]);
        brokers[msg.sender].profitAmount += int256(sprintRewardDrawables[msg.sender]);
        sprintRewardDrawables[msg.sender] = 0;
    }

    // 援助池 0.5% -------------------------
    uint256 public fuelRescueBalance; // 直接将对应金额发给对应的地址

    // ---------感恩墙模块------------------------------
    uint8 commentRewardRate = 3; //评论额外收益(百分比)
    mapping(address => uint256) public commentRewardSubmitTimes; //下次可额外奖励用户
    mapping(address => uint256) public commentRewardTimes;
    string[] comments;

    function commentSubmit(string calldata comment) external {
        require(commentRewardSubmitTimes[msg.sender] > 0, "You can`t commit.");
        comments.push(comment);
        commentRewardSubmitTimes[msg.sender] -= 1;
        commentRewardTimes[msg.sender] += 1;
    }

    function commentList(uint32 offset, uint32 size) external view returns (string[] memory results, uint256 total) {
        total = comments.length;
        if (offset + size <= total) {
            results = new string[](size);
            for (uint256 i = 0; i < size; i++) {
                results[i] = comments[i + offset];
            }
        }
    }

    // 重启模块 0.5%
    uint256 public restartBalance;
    uint256 public restartTimes = 0; // 重启次数
    bool public restartStatus; // false:正常状态;true:重启补偿期;
    uint256 public restartSubmitTimes;
    uint256 public restartUntil; // 重启时间到
    struct LossCompensation {
        uint256 amount;
        uint32 withdrawEndTimestamp;
        uint32 lastWithdrawTimestamp;
    }
    mapping(address => mapping(uint32 => LossCompensation)) public lossCompensations;

    function restart(uint256 depositIndex) external {
        require(deposits[msg.sender][depositIndex].status == 20, "deposit status error");
        require(block.timestamp > deposits[msg.sender][depositIndex].createTimestamp + 29 * dayInterval, "You deposit not satisfy to restart");
        require(waitingWithdrawBalance / depositBalance > 10, "bank not need restart");
        restartSubmitTimes += 1;
        if (restartTimes > 3) {
            restartStatus = true;
            restartUntil = block.timestamp + 2 * dayInterval;
        }
        deposits[msg.sender][depositIndex].status = 50;
        activeSprintReward();
    }

    function start() external {
        require(restartStatus, "not in restart time");
        require(block.timestamp > restartUntil, "in restart time");
        restartStatus = false;
        versionTimestamps.push(uint32(block.timestamp));
        versionTimes += 1;
        delete depositBalance;
        delete waitingFinalPayBalance;
        delete waitingWithdrawBalance;

        delete fomoBalance;
    }

    function lossCompensationClaim() external {
        _lossCompensationClaim(msg.sender);
    }

    function _lossCompensationClaim(address addr) private {
        if (versionTimestamps[versionTimes] != brokers[addr].currentVersionTimestamp) {
            if (brokers[addr].profitAmount < 0) {
                LossCompensation storage lossCompensation = lossCompensations[addr][brokers[addr].currentVersionTimestamp];
                lossCompensation.withdrawEndTimestamp = uint32(block.timestamp + 2000 * dayInterval);
                lossCompensation.lastWithdrawTimestamp = uint32(block.timestamp);
                lossCompensation.amount = uint256(-brokers[addr].profitAmount);
            }
            brokers[addr].currentVersionTimestamp = versionTimestamps[versionTimes];
            delete brokers[addr];
            delete deposits[addr];
        }
    }

    function lossCompensationWithdraw(uint32 _versionTimestamp) external nonReentrant {
        uint256 drawable = lossCompensationPending(msg.sender, _versionTimestamp);
        require(drawable > 0, "Insufficient of lossCompensation");
        IFuel(fuel).mint(msg.sender, drawable);
        lossCompensations[msg.sender][_versionTimestamp].lastWithdrawTimestamp = uint32(block.timestamp + (block.timestamp % dayInterval));
    }

    function lossCompensationPending(address addr, uint32 _versionTimestamp) public view returns (uint256 drawable) {
        LossCompensation storage lossCompensation = lossCompensations[addr][_versionTimestamp];
        if (lossCompensation.amount != 0) {
            uint256 remainSecond = block.timestamp - lossCompensation.lastWithdrawTimestamp;
            if (lossCompensation.withdrawEndTimestamp < block.timestamp) {
                remainSecond = lossCompensation.withdrawEndTimestamp - lossCompensation.lastWithdrawTimestamp;
            }
            uint256 remainDays = remainSecond / dayInterval;
            drawable = (remainDays * lossCompensation.amount) / 2000;
        }
    }

    // ---------------------------------------------------------
    function depositRemainToday() public view returns (uint256) {
        uint32 days_ = ((uint32(block.timestamp) - versionTimestamps[versionTimes])) / (24 * 60 * 60);
        return (20_0000e18 * 141**days_) / (100**days_) - depositAmountDays[today()];
    }

    function today() public view returns (uint32) {
        return uint32(block.timestamp - (block.timestamp % (24 * 60 * 60)));
    }

    // 生成{0-max}的随机数
    function createRandom(uint256 max) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase, gasleft()))) % max;
    }

    function createId(address addr) public view returns (uint256) {
        return (uint160(addr) % (2**20)) + block.timestamp * (2**20);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IMain {
    function accountActive(
        address addr,
        uint32 branchId,
        address parent
    ) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFuel {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFuelDeposit {
    function fuelRescue(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `AddressDeque`. Other types can be cast to and from `address`. This data structure can only be
 * used in storage, and not in memory.
 * ```
 * DoubleEndedQueue.AddressDeque queue;
 * ```
 *
 * _Available since v4.6._
 */
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error Empty();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error OutOfBounds();

    /**
     * @dev Indices are signed integers because the queue can grow in any direction. They are 128 bits so begin and end
     * are packed in a single storage slot for efficient access. Since the items are added one at a time we can safely
     * assume that these 128-bit indices will not overflow, and use unchecked arithmetic.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * Indices are in the range [begin, end) which means the first item is at data[begin] and the last item is at
     * data[end - 1].
     */
    struct AddressDeque {
        int128 _begin;
        int128 _end;
        mapping(int128 => address) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     */
    function pushBack(AddressDeque storage deque, address value) internal {
        int128 backIndex = deque._end;
        deque._data[backIndex] = value;
        unchecked {
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popBack(AddressDeque storage deque) internal returns (address value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        value = deque._data[backIndex];
        delete deque._data[backIndex];
        deque._end = backIndex;
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     */
    function pushFront(AddressDeque storage deque, address value) internal {
        int128 frontIndex;
        unchecked {
            frontIndex = deque._begin - 1;
        }
        deque._data[frontIndex] = value;
        deque._begin = frontIndex;
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popFront(AddressDeque storage deque) internal returns (address value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        value = deque._data[frontIndex];
        delete deque._data[frontIndex];
        unchecked {
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function front(AddressDeque storage deque) internal view returns (address value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        return deque._data[frontIndex];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function back(AddressDeque storage deque) internal view returns (address value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        return deque._data[backIndex];
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `OutOfBounds` if the index is out of bounds.
     */
    function at(AddressDeque storage deque, uint256 index) internal view returns (address value) {
        // int256(deque._begin) is a safe upcast
        int128 idx = SafeCast.toInt128(int256(deque._begin) + SafeCast.toInt256(index));
        if (idx >= deque._end) revert OutOfBounds();
        return deque._data[idx];
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(AddressDeque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(AddressDeque storage deque) internal view returns (uint256) {
        // The interface preserves the invariant that begin <= end so we assume this will not overflow.
        // We also assume there are at most int256.max items in the queue.
        unchecked {
            return uint256(int256(deque._end) - int256(deque._begin));
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(AddressDeque storage deque) internal view returns (bool) {
        return deque._end <= deque._begin;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}