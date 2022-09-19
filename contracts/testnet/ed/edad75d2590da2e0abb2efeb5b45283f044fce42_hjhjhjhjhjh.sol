/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract hjhjhjhjhjh {

    uint256 public constant PERC_DIVIDER = 10000;
    uint256 public constant DAY_SECONDS = 86400;

    uint256 public constant DEPOSIT_FEE = 1000; //10%
    uint256 public constant MAX_REWARD = 20000; //200% max reward including compounds
    uint256 public constant DAILY_DIV = 100; //1%
    uint256 public constant REINVEST_BONUS = 1000; //10%
    uint256[] public REF_PERCENTS = [400, 200, 100, 100];

    uint256 public constant HOLD_PERCENT_STEP = 10; //+0.1% per day (2% max)
    uint256 public constant HOLD_MAX_DAYS = 20; //max number of days for hold bonus
    uint256 public constant HOLD_BONUS_MAX = HOLD_MAX_DAYS * HOLD_PERCENT_STEP; //200 (2%)

    uint256 public MIN_REF = 0.000000005 ether; //min amount of stake needed to withdraw ref rewards
    uint256 public MIN_INVEST = 0.00000001 ether;
    uint256 public MAX_INVEST = 10 ether;
    uint256 public BALANCE_STEP = 10 ether;

    uint256 public constant BALANCE_PERCENT_STEP = 1; //+0.01% bonus per balance step (2% max)
    uint256 public constant BALANCE_BONUS_MAX = 200; //%2

    address payable private dev;
    address payable private mrk;

    uint256 private invested;
    uint256 private reinvested;
    uint256 private withdrawn;
    uint256 private totalRefRewards;
    uint256 private userCount;

    struct DWStruct {
        uint256 amount;
        uint256 timestamp;
    }

    struct User {
        uint256 invested;
        uint256 reinvested;
        uint256 withdrawable;
        uint256 withdrawn;
        uint256 lastWithdrawnAt; //info
        uint256 claimedTotal;
        uint256 checkpoint;
        uint256 refWithdrawable;
        uint256 refWithdrawn;
        uint256 refTotal;
        address upline;
        uint256 firstInvestTime; //info
        uint256 holdBonusStart;
        uint256 lastRefWithdrawnAt; //info
        uint32[4] refCounts; //info
    }

    mapping(address => User) internal users;
    mapping(address => DWStruct[]) internal deposits; //info
    mapping(address => DWStruct[]) internal withdrawals; //info

    event Invested(address indexed addr, uint256 amount, uint256 time);
    event Withdrawn(address indexed addr, uint256 amount, uint256 time);
    event Reinvested(address indexed addr, uint256 amount, uint256 time);

    constructor(
        address payable _dev,
        address payable _mrk
    ) {
        dev = _dev;
        mrk = _mrk;
    }

    function invest(address ref, uint256 _amount)
        external
        payable
    {
        address addr = msg.sender;
        uint256 amount = msg.value;

        require(amount >= MIN_INVEST && amount <= MAX_INVEST);

        User storage user = users[addr];
        uint8 refInc = 0;
        if (user.invested == 0) {
            refInc = 1;
            ++userCount;
            user.firstInvestTime = block.timestamp; //info
            user.holdBonusStart = user.firstInvestTime;
            user.upline = ref != addr && ref != address(0) ? ref : dev;
        }

        address up = user.upline;
        for (uint8 i = 0; i < REF_PERCENTS.length && up != address(0); i++) {
            users[up].refCounts[i] += refInc;
            uint256 rew = (amount * REF_PERCENTS[i]) / PERC_DIVIDER;
            users[up].refWithdrawable += rew;
            users[up].refTotal += rew;
            totalRefRewards += rew;
            up = users[up].upline;
        }

        _claimReward(addr);
        _invest(addr, amount);

        uint256 halfFee = (amount * DEPOSIT_FEE) / (PERC_DIVIDER * 2);
        _transferTo(mrk, halfFee);
        _transferTo(dev, halfFee);
        emit Invested(addr, amount, block.timestamp);
    }

    function withdraw() external {
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "Amount is 0");

        _transferTo(addr, amount);
        emit Withdrawn(addr, amount, block.timestamp);
    }

    function reinvest() external {
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "Amount is 0");

        amount += (amount * REINVEST_BONUS) / PERC_DIVIDER;
        _invest(addr, amount);

        users[addr].reinvested += amount;
        reinvested += amount;
        emit Reinvested(addr, amount, block.timestamp);
    }

    function withdrawRef(uint256 amount) external {
        address addr = msg.sender;
        User storage user = users[addr];
        require(user.invested >= MIN_REF, "More investment required");

        if (amount == 0 || amount > user.refWithdrawable) {
            amount = user.refWithdrawable;
        }
        require(amount > 0, "Amount is 0");

        user.refWithdrawable -= amount;
        user.refWithdrawn += amount;
        user.lastRefWithdrawnAt = block.timestamp;
        withdrawn += amount;

        _transferTo(addr, amount);
    }

    function _transferTo(address addr, uint256 amount) private {
            payable(addr).transfer(amount);
    }

    //claim and set checkpoint
    function _claimReward(address addr) private {
        uint256 rew = _calcReward(addr);
        //calc is done since the checkpoint
        users[addr].checkpoint = block.timestamp;

        users[addr].withdrawable += rew;
        users[addr].claimedTotal += rew;
    }

    function _invest(address addr, uint256 amount) private {
        users[addr].invested += amount;
        invested += amount;
        deposits[addr].push(
            DWStruct({amount: amount, timestamp: block.timestamp})
        );
    }

    function _withdraw(address addr) private returns (uint256) {
        uint256 balance = getBalance();
        User storage user = users[addr];

        uint256 amount = user.withdrawable < balance
            ? user.withdrawable
            : balance;

        if (amount == 0) return 0;

        user.withdrawable -= amount;
        user.withdrawn += amount;
        withdrawn += amount;

        uint256 tsNow = block.timestamp;
        user.lastWithdrawnAt = tsNow;
        users[addr].holdBonusStart = tsNow;

        withdrawals[addr].push(DWStruct({amount: amount, timestamp: tsNow}));
        return amount;
    }

    function _calcReward(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        User memory user = users[addr];
        if (user.invested == 0 || maxReward <= user.claimedTotal) return 0;

        uint256 start = user.checkpoint;
        uint256 diff = (start - user.holdBonusStart) % DAY_SECONDS;
        uint256 end = start + DAY_SECONDS - diff;

        uint256 tsNow = block.timestamp;
        //balance bonus retroactive
        uint256 rew = (_getBasePerc() + _getBalancePerc()) * (tsNow - start);
        uint256 holdBonus = _getHoldBonusPercAt(addr, start);
        while (true) {
            if (end > tsNow || holdBonus == HOLD_BONUS_MAX) {
                end = tsNow; //calculate from start to now as the last step
            }
            rew += holdBonus * (end - start);
            if (end == tsNow) break;

            start = end;
            end += DAY_SECONDS;
            holdBonus += HOLD_PERCENT_STEP; //hold bonus not retroactive
        }

        rew = (rew * user.invested) / (DAY_SECONDS * PERC_DIVIDER);
        return
            maxReward > rew + user.claimedTotal
                ? rew
                : maxReward - user.claimedTotal;
    }

    function _getHoldBonusPercAt(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        if (users[addr].invested == 0) return 0;

        uint256 i = (timestamp - users[addr].holdBonusStart) / DAY_SECONDS;
        return HOLD_PERCENT_STEP * (i < HOLD_MAX_DAYS ? i : HOLD_MAX_DAYS);
    }

    function _getBasePerc() private pure returns (uint256) {
        return DAILY_DIV;
    }

    function _getHoldBonusPerc(address addr) private view returns (uint256) {
        return _getHoldBonusPercAt(addr, block.timestamp);
    }

    function _getBalancePerc() private view returns (uint256) {
        // division before multiplication is used intentionally. x/y == math.floor(x/y) in solidity
        uint256 i = BALANCE_PERCENT_STEP * (getBalance() / BALANCE_STEP);
        return i < BALANCE_BONUS_MAX ? i : BALANCE_BONUS_MAX;
    }

    function getMaxReward(address addr) public view returns (uint256) {
        return (users[addr].invested * MAX_REWARD) / PERC_DIVIDER;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWithdrawable(address addr) public view returns (uint256) {
        return users[addr].withdrawable + _calcReward(addr);
    }

    function getUserDeposits(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return deposits[addr];
    }

    function getUserWithdrawals(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return withdrawals[addr];
    }

    function getContractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _reinvested,
            uint256 _withdrawn,
            uint256 _totalRefRewards,
            uint256 _userCount
        )
    {
        return (invested, reinvested, withdrawn, totalRefRewards, userCount);
    }

    function getCurrentUserPercentages(address addr)
        external
        view
        returns (
            uint256 percentTotal,
            uint256 basePercent,
            uint256 holdBonusPercent,
            uint256 balanceBonusPercent
        )
    {
        basePercent = _getBasePerc();
        holdBonusPercent = _getHoldBonusPerc(addr);
        balanceBonusPercent = _getBalancePerc();
        percentTotal = basePercent + holdBonusPercent + balanceBonusPercent;
    }

    function getUserInfo(address addr)
        external
        view
        returns (User memory user)
    {
        user = users[addr];
        user.withdrawable += _calcReward(addr);
    }
}