// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICrowdAccount.sol";

interface ICrowdFundAlloc {
    function allocUsdt(uint256 amount) external;

    function swapToken(uint256 usdtAmount, uint8 flag) external returns (uint256 tokenAmount);

    function getTotalAllocRate() external view returns (uint16 totalRate);
}

contract MetaCrowdV2 is Ownable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    uint16 public constant RESTART_TIME_GAP = 2 * 3600;
    address public constant USDT = 0xdA0B47eD306F2bF6b128e5a84389b1f270932Cb6;
    address public token = 0x05316EcaED7a2828e80041f7ae8383F3D81A9a01;
    address public fee = 0x221A126E0F2B4A6c5848689145589f9A229dc3aa;
    address public crowdAccount = 0xF99a13bB999482B68a9D4AC95EAa36467d458f62;
    address public fundAlloc = 0xaAAE9398A81617155C330bA379f82ADDb5022FDe;
    uint16[] public bonus = [0, 20, 30, 40, 50, 60, 70];
    /**0:前第几期开始返回本金, 1单笔最大投资比例,2:单次最大参与额度(单位1e18),3:最大预约期数,4:最大预约比例,5:亏损保障池补偿比例, 6:抢购时间(分钟)*/
    uint16[] public defaultParams = [2, 10, 100, 5, 10, 600, 500];
    /**公共参数：0:静态奖比例，1:代币分红池比例，2:失败前三期返还本金比例，3:提现手续费比例 ,4:奖励锁定需点灯解锁比例，5:收益平级奖比例，6:亏损返优先积分比例，7:失败返优先积分比例
    8:冷区时间，9:1point解锁u数量, 10:启用杠杆等级*/
    uint16[] public crowdParams = [110, 30, 700, 10, 200, 100, 3000, 1000, 100, 3, 50, 3];

    struct Region {
        uint32 currentRound;
        uint16 multiplier;
        uint256 initAmount;
        uint256 period;
        uint256 startTime;
        uint256 protectAmount; //保障池
        uint16[] params;
    }

    Region[] public regions;
    mapping(uint256 => Project[]) projects;

    struct Project {
        uint16 state;
        uint16 version;
        uint256 startTime;
        uint256 targetAmount;
        uint256 currentAmount;
        uint256 reserveAmount;
        uint256 refundAmount;
        uint256 brokerReward;
        uint256 refundToken;
    }

    struct ProjectFund {
        uint16 version;
        uint256 fund;
        uint256 refund;
        uint256 reserve;
        uint256 reserveFund;
        uint256 reserveRefund;
        uint256 priorityRefund;
    }

    struct BrokerReward {
        uint16 version;
        uint256 amount;
    }

    mapping(address => mapping(uint256 => mapping(uint256 => ProjectFund))) projectFunds;
    mapping(address => mapping(uint256 => mapping(uint256 => BrokerReward))) brokerRewards;
    mapping(address => mapping(uint256 => EnumerableSet.UintSet)) harvestableIds;
    mapping(address => mapping(uint256 => EnumerableSet.UintSet)) brokerRewardIds;
    mapping(address => uint256) peerRewards;
    mapping(address => uint256) lastFundTime;
    mapping(address => bool) public leverageMap;
    mapping(address => bool) daoMap;
    mapping(address => bool) operators;

    error ProjectStateError();

    constructor() {
        // _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        // LP = 0xdA0B47eD306F2bF6b128e5a84389b1f270932Cb6;
        // STAKE = 0x2507012E0728Fb774325FEaD19fD106944dBa0E9;
        // DONATE = 0x810C2dd185dFd08b8d5656175f4f335a0ea61C78;
        // fee = 0x221A126E0F2B4A6c5848689145589f9A229dc3aa;
        // dao = 0x221A126E0F2B4A6c5848689145589f9A229dc3aa;
        // crowdAccount = 0xF99a13bB999482B68a9D4AC95EAa36467d458f62;
    }

    modifier onlyOperator() {
        // require(operators[msg.sender], "access limited");
        _;
    }

    function setOperator(address addr, bool flag) external onlyOwner {
        operators[addr] = flag;
    }

    function setLeverage(bool flag) external {
        require(
            ICrowdAccount(crowdAccount).accountMetaVip(msg.sender) >= crowdParams[10] || ICrowdAccount(crowdAccount).accountVips(msg.sender) >= crowdParams[10],
            "level limited"
        );
        for (uint256 i = 0; i < regions.length; i++) {
            if (harvestableIds[msg.sender][i].length() > 0) revert("fund limited");
        }
        leverageMap[msg.sender] = flag;
    }

    function setDaoFlag(address addr, bool flag) external onlyOperator {
        daoMap[addr] = flag;
    }

    function setBonus(uint256 _index, uint16 _bonus) external onlyOperator {
        bonus[_index] = _bonus;
    }

    function setAddresses(
        address _crowdAccount,
        address _fundAlloc,
        address _token,
        address _fee
    ) external onlyOperator {
        crowdAccount = _crowdAccount;
        fundAlloc = _fundAlloc;
        token = _token;
        fee = _fee;
    }

    function setRegionParams(
        uint256 regionIndex,
        uint16 paramIndex,
        uint16 value
    ) external onlyOperator {
        regions[regionIndex].params[paramIndex] = value;
    }

    function setCrowdParams(uint16 paramIndex, uint16 value) external onlyOperator {
        crowdParams[paramIndex] = value;
    }

    function getRegionParams(uint256 regionIndex) external view returns (uint16[] memory) {
        return regions[regionIndex].params;
    }

    function setRegionInitParams(
        uint256 regionIndex,
        uint256 period,
        uint256 initAmount,
        uint16 multiplier
    ) external onlyOperator {
        regions[regionIndex].period = period;
        regions[regionIndex].initAmount = initAmount;
        regions[regionIndex].multiplier = multiplier;
    }

    function setProjectParams(
        uint256 regionIndex,
        uint256 round,
        uint256 startTime,
        uint256 targetAmount
    ) external onlyOperator {
        projects[regionIndex][round].startTime = startTime;
        projects[regionIndex][round].targetAmount = targetAmount;
    }

    function addRegion(
        uint256 period,
        uint256 initAmount,
        uint16 multiplier,
        uint256 startTime
    ) external onlyOperator {
        regions.push(
            Region({
                period: period,
                initAmount: initAmount,
                multiplier: multiplier,
                startTime: startTime,
                currentRound: 0,
                protectAmount: 0,
                params: defaultParams
            })
        );
        _addProject(regions.length - 1);
    }

    function addProject(uint256 regionIndex) external onlyOperator {
        require(regions[regionIndex].initAmount > 0, "region not exists");
        require(projects[regionIndex].length - regions[regionIndex].currentRound < regions[regionIndex].params[3]);
        _addProject(regionIndex);
    }

    function _addProject(uint256 regionIndex) internal {
        Project storage p = projects[regionIndex].push();
        uint256 pl = projects[regionIndex].length;
        p.state = 1;
        if (pl == 1) {
            p.targetAmount = regions[regionIndex].initAmount;
            p.startTime = regions[regionIndex].startTime;
        } else {
            if (projects[regionIndex][pl - 2].state == 4) {
                p.targetAmount = regions[regionIndex].initAmount;
            } else {
                p.targetAmount = roundup((projects[regionIndex][pl - 2].targetAmount * regions[regionIndex].multiplier) / 1000, 1e18);
            }
            p.startTime = projects[regionIndex][pl - 2].startTime + regions[regionIndex].period;
        }
    }

    function fund(uint256 regionIndex, uint256 amount) external {
        require(ICrowdAccount(crowdAccount).registered(msg.sender), "not registered");
        require(amount > 0, "zero amount error");
        require(lastFundTime[msg.sender] + crowdParams[8] < block.timestamp || daoMap[msg.sender] == true, "funding time limited");
        uint32 round = regions[regionIndex].currentRound;
        Project storage p = projects[regionIndex][round];
        if (block.timestamp > p.startTime + regions[regionIndex].period) {
            finishProject(regionIndex);
            round++;
            p = projects[regionIndex][round];
        }
        require(amount <= getMaxAmountPerTime(regionIndex, p.targetAmount), "max amount limited");
        require(
            block.timestamp > p.startTime && block.timestamp < p.startTime + min(regions[regionIndex].period, uint256(regions[regionIndex].params[6]) * 60),
            "funding time limited"
        );
        if (p.state > 2) revert ProjectStateError();
        if (p.state < 2) p.state = 2;
        uint256 amountLeft = p.targetAmount - p.currentAmount;
        require(amountLeft > 0, "no fund amount left");
        uint16 version = p.version;
        ProjectFund storage pf = projectFunds[msg.sender][regionIndex][round];
        processRefund(pf, version);
        pf.version = version;
        uint256 fundAmount = min(amount, amountLeft);
        processFund(pf, fundAmount);
        processBrokerReward(msg.sender, regionIndex, round, version, fundAmount);
        harvestableIds[msg.sender][regionIndex].add(round);
        p.currentAmount += fundAmount;
        lastFundTime[msg.sender] = block.timestamp;
        if (amount >= amountLeft) finishProject(regionIndex);
    }

    function reserve(
        uint256 regionIndex,
        uint256 round,
        uint256 amount
    ) external {
        require(ICrowdAccount(crowdAccount).registered(msg.sender), "not registered");
        require(amount > 0, "zero amount error");
        require(lastFundTime[msg.sender] + crowdParams[8] < block.timestamp || daoMap[msg.sender] == true, "reserve time limited");
        Project storage p = projects[regionIndex][round];
        uint256 targetAmount = p.targetAmount;
        require(amount <= getMaxAmountPerTime(regionIndex, targetAmount), "max amount limited");
        require((amount + p.reserveAmount) <= (targetAmount * regions[regionIndex].params[4]) / 1000, "no reserve amount left");
        uint256 priorityFundAmount = ICrowdAccount(crowdAccount).priorityFundAmount(msg.sender);
        require(amount <= priorityFundAmount, "priority amount not enough");
        uint32 currentRound = regions[regionIndex].currentRound;
        uint256 maxRound = min(projects[regionIndex].length, currentRound + regions[regionIndex].params[3]);
        if (p.state > 1 || round >= maxRound) revert ProjectStateError();
        require(block.timestamp < p.startTime, "funding time limited");
        uint16 version = p.version;
        ProjectFund storage pf = projectFunds[msg.sender][regionIndex][round];
        processRefund(pf, version);
        pf.version = version;
        pf.reserve += amount;
        p.reserveAmount += amount;
        ICrowdAccount(crowdAccount).setPriorityFundAmount(msg.sender, priorityFundAmount - amount);
        lastFundTime[msg.sender] = block.timestamp;
        harvestableIds[msg.sender][regionIndex].add(round);
    }

    function processRefund(ProjectFund storage pf, uint16 version) internal {
        if (pf.version < version) {
            uint256 fundAmount = pf.fund;
            uint256 reserveAmount = pf.reserve;
            if (reserveAmount > 0) {
                pf.priorityRefund += reserveAmount;
                pf.reserve = 0;
            }
            if (fundAmount > 0) {
                pf.reserveRefund += fundAmount;
                pf.fund = 0;
                pf.reserveFund = 0;
                pf.refund = 0;
            }
        }
    }

    function processFund(ProjectFund storage pf, uint256 amount) internal {
        uint256 leverageAmount = getLeverageAmount(msg.sender, amount);
        if (leverageAmount < amount) {
            IERC20(USDT).safeTransferFrom(msg.sender, address(this), leverageAmount);
            pf.refund += (amount - leverageAmount);
        } else {
            IERC20(USDT).safeTransferFrom(msg.sender, address(this), amount);
        }
        pf.fund += amount;
    }

    function finishReserve(uint256 regionIndex, uint256 round) external {
        Project storage p = projects[regionIndex][round];
        require(block.timestamp < p.startTime, "payment time passed");
        uint16 version = p.version;
        ProjectFund storage pf = projectFunds[msg.sender][regionIndex][round];
        uint256 reserveAmount = pf.reserve;
        uint256 fundAmount = pf.fund;
        require(pf.version == version && reserveAmount > 0, "not reserved");
        require(reserveAmount > fundAmount, "already paid");
        uint256 amount = reserveAmount - fundAmount;
        processFund(pf, amount);
        pf.reserveFund += amount;
        p.currentAmount += amount;
        processBrokerReward(msg.sender, regionIndex, round, version, amount);
    }

    function pendingForFinish(
        address account,
        uint256 regionIndex,
        uint256 round
    ) external view returns (uint256 reserveAmount, uint256 reserveFundAmount) {
        ProjectFund storage pf = projectFunds[account][regionIndex][round];
        if (pf.version == projects[regionIndex][round].version) {
            reserveAmount = pf.reserve;
            reserveFundAmount = pf.reserveFund;
        }
    }

    function finishProject(uint256 regionIndex) public {
        uint32 round = regions[regionIndex].currentRound;
        Project storage p = projects[regionIndex][round];
        require(
            p.targetAmount == p.currentAmount || block.timestamp > p.startTime + min(regions[regionIndex].period, uint256(regions[regionIndex].params[6]) * 60),
            "finish condition limited"
        );
        if (p.state > 2) revert ProjectStateError();
        uint256 currentAmount = p.currentAmount;
        if (currentAmount == p.targetAmount) {
            p.state = 3;
            uint256 amountLeft = (currentAmount * (1000 - crowdParams[2])) / 1000;
            {
                //n-2期提取本金
                uint16 backRound = regions[regionIndex].params[0];
                if (round >= backRound && projects[regionIndex][round - backRound].state == 3) {
                    Project storage p2 = projects[regionIndex][round - backRound];
                    uint256 refundAmount = (p2.targetAmount * crowdParams[2]) / 1000;
                    p2.refundAmount = refundAmount;
                }
            }
            if (round >= 3 && projects[regionIndex][round - 3].state == 3) {
                Project storage p3 = projects[regionIndex][round - 3];
                p3.state = 5;
                //n-3期成功出场
                uint256 targetAmount = p3.targetAmount;
                //0:静态奖比例,1:代币分红池比例,2:失败前三期返还本金比例,3:dao,4:原点保障池比例,5:质押池比例，6:捐赠比例
                uint256 allocAmount = allocAmounts(targetAmount);
                uint256 rewardAmount = (targetAmount * crowdParams[1]) / 1000;
                uint256 refundAmount = (targetAmount * (1000 - crowdParams[2] + crowdParams[0])) / 1000 + p3.brokerReward;
                p3.refundAmount += refundAmount;
                uint256 outAmount = (refundAmount + rewardAmount + allocAmount);
                amountLeft -= outAmount;
                uint256 rewardToken = swapToken(rewardAmount, 2);
                projects[regionIndex][round - 3].refundToken = rewardToken;
            }
            uint256 protectToken = swapToken(amountLeft, 1);
            regions[regionIndex].protectAmount += protectToken;
        } else {
            p.state = 4;
            uint256 start = round >= 3 ? round - 3 : 0;
            uint16 backRound = regions[regionIndex].params[0];
            //前三期总额
            uint256 totalAmount = 0;
            uint256[] memory roundIds = new uint256[](3);
            uint8 size = 0;
            for (uint256 i = start; i < round; i++) {
                Project storage pi = projects[regionIndex][i];
                if (pi.state == 3) {
                    pi.state = 6;
                    totalAmount += pi.targetAmount;
                    roundIds[size] = i;
                    ++size;
                    if (i + backRound >= round) {
                        //返回本金
                        uint256 refundAmount = (pi.targetAmount * (crowdParams[2])) / 1000;
                        pi.refundAmount = refundAmount;
                    }
                }
            }
            if (totalAmount > 0) {
                //补偿平台币
                uint256 protectAmount = regions[regionIndex].protectAmount;
                uint256 refundToken = (protectAmount * regions[regionIndex].params[5]) / 1000;
                regions[regionIndex].protectAmount = protectAmount - refundToken;
                for (uint256 i = 0; i < size; i++) {
                    Project storage pi = projects[regionIndex][roundIds[i]];
                    pi.refundToken = (refundToken * pi.targetAmount) / totalAmount;
                }
            }
            if (currentAmount > 0) {
                p.refundAmount = currentAmount;
            }
            resetProjects(regionIndex, round);
        }
        _addProject(regionIndex);
        regions[regionIndex].currentRound++;
    }

    //处理铸币 1:保障池，2:成功出场, 3:提取收益
    function swapToken(uint256 amount, uint8 flag) internal returns (uint256 tokenAmount) {
        IERC20(USDT).safeTransfer(fundAlloc, amount);
        tokenAmount = ICrowdFundAlloc(fundAlloc).swapToken(amount, flag);
    }

    function resetProjects(uint256 regionIndex, uint256 round) internal {
        uint256 length = projects[regionIndex].length;
        uint16 multiplier = regions[regionIndex].multiplier;
        uint256 period = regions[regionIndex].period;
        bool resetTime = block.timestamp > projects[regionIndex][round].startTime + period + min(RESTART_TIME_GAP, period);
        uint256 _targetAmount;
        uint256 _startTime;
        for (uint256 i = round + 1; i < length; i++) {
            Project storage p = projects[regionIndex][i];
            if (i == round + 1) {
                _targetAmount = regions[regionIndex].initAmount;
                if (resetTime) {
                    _startTime = block.timestamp;
                    p.startTime = _startTime;
                }
            } else {
                _targetAmount = roundup((_targetAmount * multiplier) / 1000, 1e18);
                if (resetTime) {
                    _startTime += period;
                    p.startTime = _startTime;
                }
            }
            p.targetAmount = _targetAmount;
            if (p.reserveAmount > 0) {
                ++p.version;
                p.reserveAmount = 0;
                p.currentAmount = 0;
                p.brokerReward = 0;
            }
        }
    }

    function pending(
        address account,
        uint256 regionIndex,
        uint256 round
    )
        public
        view
        returns (
            uint256[] memory amounts, //查询收益 0:投入本金,1:返回本金,2:静态收益,3:免费提现额度,4:优先额度,5:已返回本金,6:平台token数量
            uint16 state, //1:预约, 2:众筹中, 3:成功, 4:失败补偿, 5:盈利退款, 6:亏损退款
            uint16 version,
            bool restart
        )
    {
        amounts = new uint256[](7);
        Project storage p = projects[regionIndex][round];
        ProjectFund storage pf = projectFunds[account][regionIndex][round];
        uint256 fundAmount = pf.fund;
        amounts[5] = pf.refund;
        amounts[0] = fundAmount;
        state = p.state;
        version = p.version;
        if (pf.version == projects[regionIndex][round].version) {
            if (state == 3 && p.refundAmount > 0) {
                amounts[1] = (fundAmount * crowdParams[2]) / 1000 - amounts[5];
            } else if (state == 4) {
                amounts[1] = fundAmount - amounts[5];
                amounts[4] = (fundAmount * crowdParams[7]) / 1000;
            } else if (state == 5) {
                amounts[1] = fundAmount - amounts[5];
                amounts[2] = (fundAmount * crowdParams[0]) / 1000;
                amounts[6] = (fundAmount * p.refundToken) / p.targetAmount;
            } else if (state == 6) {
                amounts[1] = (fundAmount * crowdParams[2]) / 1000 - amounts[5];
                amounts[3] = (fundAmount * (1000 - crowdParams[2])) / crowdParams[3];
                amounts[4] = (fundAmount * crowdParams[6]) / 1000;
                amounts[6] = (fundAmount * p.refundToken) / p.targetAmount;
            }
            uint256 refund = getLeverageAmount(account, pf.reserveRefund);
            amounts[1] += refund;
            amounts[3] += refund;
            amounts[4] += pf.priorityRefund;
        } else {
            restart = true;
            uint256 refund = getLeverageAmount(account, pf.reserveFund + pf.reserveRefund);
            amounts[1] = refund;
            amounts[3] = refund;
            amounts[4] = (pf.reserve + pf.priorityRefund);
        }
    }

    function _harvest(
        uint256 refundAmount,
        uint256 rewardAmount,
        uint256 freeWithdrawAmount,
        uint256 priorityFundAmount,
        uint256 refundToken
    ) internal {
        uint256 lockedAmount = (rewardAmount * crowdParams[4]) / 1000;
        uint256 peerReward = (rewardAmount * crowdParams[5]) / 1000;
        (uint256 _priorityAmount, uint256 _freeWithdrawAmount, uint256 _lockedWithdrawAmount, uint256 _unlockedAmount) = ICrowdAccount(crowdAccount)
            .accountAmounts(msg.sender);
        if (lockedAmount > 0) {
            _lockedWithdrawAmount += lockedAmount;
        }
        if (priorityFundAmount > 0) {
            _priorityAmount += priorityFundAmount;
        }
        if (freeWithdrawAmount > 0) {
            _freeWithdrawAmount += freeWithdrawAmount;
        }
        if (peerReward > 0) {
            processPeerReward(msg.sender, peerReward);
        }
        //平台币
        if (refundToken > 0) {
            IERC20(token).safeTransfer(msg.sender, refundToken);
        }
        uint256 amount = refundAmount + rewardAmount - lockedAmount - peerReward;
        if (amount > 0) {
            if (_freeWithdrawAmount >= amount) {
                _freeWithdrawAmount -= amount;
                IERC20(USDT).safeTransfer(msg.sender, amount);
            } else {
                uint256 _feeAmount = ((amount - _freeWithdrawAmount) * crowdParams[7]) / 1000;
                _freeWithdrawAmount = 0;
                IERC20(USDT).safeTransfer(msg.sender, amount - _feeAmount);
                IERC20(USDT).safeTransfer(fee, _feeAmount);
            }
        }
        ICrowdAccount(crowdAccount).setAccountAmounts(msg.sender, _priorityAmount, _freeWithdrawAmount, _lockedWithdrawAmount, _unlockedAmount);
    }

    function processPeerReward(address addr, uint256 amount) internal {
        ICrowdAccount(crowdAccount).processPeerReward(addr, amount);
    }

    function pendingForPeerReward(address addr) public view returns (uint256) {
        return ICrowdAccount(crowdAccount).peerRewardAmount(addr);
    }

    function withdrawPeerReward() external {
        uint256 peerReward = pendingForPeerReward(msg.sender);
        require(peerReward > 0, "no peer reward");
        IERC20(USDT).safeTransfer(msg.sender, peerReward);
        ICrowdAccount(crowdAccount).setPeerRewardAmount(msg.sender, 0);
    }

    function _processBrokerReward(
        address addr,
        uint256 regionIndex,
        uint256 round,
        uint16 version,
        uint256 amount
    ) internal {
        BrokerReward storage br = brokerRewards[addr][regionIndex][round];
        brokerRewardIds[addr][regionIndex].add(round);
        if (br.version == version) {
            br.amount += amount;
        } else {
            br.version = version;
            br.amount = amount;
        }
    }

    function processBrokerReward(
        address addr,
        uint256 regionIndex,
        uint256 round,
        uint16 version,
        uint256 fundAmount
    ) internal {
        uint16 used = 0;
        uint16 level = 0;
        for (uint256 i = 0; i < 45; i++) {
            (uint8 parentLevel, address head) = ICrowdAccount(crowdAccount).accountVipsHead(addr);
            if (bonus[parentLevel] > bonus[level]) {
                uint16 diff = bonus[parentLevel] - bonus[level];
                uint256 _amount = (fundAmount * diff) / 1000;
                used += diff;
                _processBrokerReward(addr, regionIndex, round, version, _amount);
                if (parentLevel == 6) break;
                level = parentLevel;
            }
            if (head == address(0)) {
                break;
            }
            addr = head;
        }
        projects[regionIndex][round].brokerReward += (fundAmount * used) / 1000;
    }

    //成功出场资金分配
    function allocAmounts(uint256 targetAmount) internal returns (uint256 allocAmount) {
        uint16 allocRate = ICrowdFundAlloc(fundAlloc).getTotalAllocRate();
        allocAmount = (targetAmount * allocRate) / 1000;
        IERC20(USDT).safeApprove(fundAlloc, allocAmount);
        ICrowdFundAlloc(fundAlloc).allocUsdt(allocAmount);
    }

    function harvestAll(uint256 regionIndex, uint256[] calldata roundIds) external {
        uint256[] memory harvestAmounts = new uint256[](5);
        for (uint256 i = 0; i < roundIds.length; i++) {
            if (harvestableIds[msg.sender][regionIndex].contains(roundIds[i])) {
                (uint256[] memory amounts, uint16 state, uint16 version, bool restart) = pending(msg.sender, regionIndex, roundIds[i]);
                harvestAmounts[0] += amounts[1];
                harvestAmounts[1] += amounts[2];
                harvestAmounts[2] += amounts[3];
                harvestAmounts[3] += amounts[4];
                harvestAmounts[4] += amounts[6];
                if (state > 3) {
                    harvestableIds[msg.sender][regionIndex].remove(roundIds[i]);
                } else {
                    ProjectFund storage pf = projectFunds[msg.sender][regionIndex][roundIds[i]];
                    uint256 refund = amounts[1] - getLeverageAmount(msg.sender, pf.reserveRefund);
                    pf.reserveRefund = 0;
                    pf.priorityRefund = 0;
                    if (restart == true) {
                        pf.version = version;
                        pf.fund = 0;
                        pf.refund = 0;
                        pf.reserve = 0;
                        pf.reserveFund = 0;
                    } else {
                        pf.refund += refund;
                    }
                }
            }
        }
        if (harvestAmounts[0] > 0 || harvestAmounts[3] > 0)
            _harvest(harvestAmounts[0], harvestAmounts[1], harvestAmounts[2], harvestAmounts[3], harvestAmounts[4]);
    }

    function pendingForUnlock(address account) public view returns (uint256 lockedAmount, uint256 unlockAmount) {
        (uint256 lockedWithdrawAmount, uint256 unlockedAmount, uint40 initPoint, uint40 newPoint) = ICrowdAccount(crowdAccount).lockAmounts(account);
        lockedAmount = lockedWithdrawAmount - unlockedAmount;
        if (initPoint > 0 && newPoint > initPoint) {
            uint256 _unlockAmount = uint256(newPoint - initPoint) * crowdParams[9] * 1e18;
            unlockAmount = _unlockAmount > unlockedAmount ? _unlockAmount - unlockedAmount : 0;
        }
    }

    function unlockWithdraw() external {
        (uint256 lockedAmount, uint256 unlockAmount) = pendingForUnlock(msg.sender);
        require(lockedAmount > 0, "no amount for unlock");
        require(unlockAmount > 0, "no point for unlock");
        uint256 amount = min(lockedAmount, unlockAmount);
        ICrowdAccount(crowdAccount).addUnlockedAmount(msg.sender, amount);
        uint256 tokenAmount = swapToken(amount, 3);
        IERC20(token).safeTransfer(msg.sender, tokenAmount);
    }

    function pendingForBrokerReward(
        address account,
        uint256 regionIndex,
        uint256[] calldata roundIds
    ) public view returns (uint256 amount, uint16[] memory states) {
        states = new uint16[](roundIds.length);
        for (uint256 i = 0; i < roundIds.length; i++) {
            uint256 round = roundIds[i];
            uint16 version = projects[regionIndex][round].version;
            uint16 state = projects[regionIndex][round].state;
            states[i] = state;
            if (state == 5 && brokerRewards[account][regionIndex][round].version == version) {
                amount += brokerRewards[account][regionIndex][round].amount;
            }
        }
    }

    function withdrawBrokerReward(uint256 regionIndex, uint256[] calldata roundIds) external {
        (uint256 amount, uint16[] memory states) = pendingForBrokerReward(msg.sender, regionIndex, roundIds);
        for (uint256 i = 0; i < roundIds.length; i++) {
            if (states[i] > 3) brokerRewardIds[msg.sender][regionIndex].remove(roundIds[i]);
        }
        if (amount > 0) _harvest(0, amount, 0, 0, 0);
    }

    function getRegionCount() external view returns (uint256) {
        return regions.length;
    }

    function getProjectCount(uint256 _regionIndex) external view returns (uint256) {
        return projects[_regionIndex].length;
    }

    function getProjects(
        uint256 regionIndex,
        uint256 offset,
        uint256 size
    ) external view returns (Project[] memory projectList) {
        uint256 length = projects[regionIndex].length;
        require(offset + size <= length, "out of bound");
        projectList = new Project[](size);
        for (uint256 i = 0; i < size; i++) {
            projectList[i] = projects[regionIndex][offset + i];
        }
    }

    function getHarvestableIds(address account, uint256 regionIndex) external view returns (uint256[] memory) {
        return harvestableIds[account][regionIndex].values();
    }

    function getBrokerRewardIds(address account, uint256 regionIndex) external view returns (uint256[] memory) {
        return brokerRewardIds[account][regionIndex].values();
    }

    function getMaxAmountPerTime(uint256 regionIndex, uint256 targetAmount) public view returns (uint256) {
        uint256 max = (targetAmount * regions[regionIndex].params[1]) / 1000;
        uint256 maxFundAmount = uint256(regions[regionIndex].params[2]) * 1e18;
        return max > maxFundAmount ? max : maxFundAmount;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function roundup(uint256 a, uint256 m) internal pure returns (uint256) {
        return ((a + m - 1) / m) * m;
    }

    function getLeverageAmount(address addr, uint256 amount) internal view returns (uint256) {
        return leverageMap[addr] == true ? amount - (amount * crowdParams[2]) / 1000 : amount;
    }

    // function setTestAddresses(
    //     address _lp,
    //     address _stake,
    //     address _crowdAccount,
    //     address _token
    // ) public {
    //     LP = _lp;
    //     crowdAccount = _crowdAccount;
    //     token = _token;
    // }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ICrowdAccount {
    function upgrade(address addr, uint8 vips) external;

    function accountVips(address addr) external returns (uint8 vips);

    function accountMetaVip(address addr) external view returns (uint8);

    function accountVipsHead(address addr) external view returns (uint8 vips, address head);

    function registered(address addr) external view returns (bool);

    function priorityFundAmount(address addr) external view returns (uint256);

    function setPriorityFundAmount(address addr, uint256 amount) external;

    function addUnlockedAmount(address addr, uint256 amount) external;

    function processPeerReward(address addr, uint256 amount) external;

    function peerRewardAmount(address addr) external view returns (uint256);

    function setPeerRewardAmount(address addr, uint256 amount) external;

    function accountAmounts(address addr)
        external
        view
        returns (
            uint256 priorityAmount,
            uint256 freeWithdrawAmount,
            uint256 lockedWithdrawAmount,
            uint256 unlockedAmount
        );

    function setAccountAmounts(
        address addr,
        uint256 priorityAmount,
        uint256 freeWithdrawAmount,
        uint256 lockedWithdrawAmount,
        uint256 unlockedAmount
    ) external;

    function lockAmounts(address addr)
        external
        view
        returns (
            uint256 lockedWithdrawAmount,
            uint256 unlockedAmount,
            uint40 initPoint,
            uint40 newPoint
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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