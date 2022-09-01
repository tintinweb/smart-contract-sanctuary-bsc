/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/*
1. 12% deposit fee
2. Min deposit 0.01 BNB Max deposit 100 BNB
3. Max 200% rewards payout
4. 5% daily rewards max (%1 base + %2 hold bonus + %2 balance bonus)
5. Hold bonus increases every day +0.1% (max +2% for 20 days). Hold bonus resets after a withdrawal
6. Balance bonus +0.01% for every 100 BNB in the contract. Max +2%
7. +10% reinvest bonus. Reinvesting doesnt reset hold bonus. No reinvest fee
8. Withdraw or reinvest anytime
9. 4 level referrals 10% (1st level 5%, 2nd level 2.5%, 3rd level 1.5%, 4th level 1%)
10. Must invest at least 0.5 BNB to be able to withdraw ref rewards
*/

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract BNBMegalodonTest1 is ReentrancyGuard {
    uint256 private constant PERCENT_DIVIDER = 10000;
    uint256 private constant DAY_SECONDS = 24*60*60; //1 day

    uint256 private constant MIN_REF = 0.5 ether; //min amount of investment needed to withdraw ref rewards
    uint256 private constant MIN_INVEST = 0.01 ether;
    uint256 private constant MAX_INVEST = 100 ether;
    uint256 private constant MAX_REWARDS_PERCENT = 20000; //200% max rewards including reinvestments
    //uint256 private constant DAILY_DIV = 100; //1%
    uint256 private constant DAILY_DIV = 1000*24*60; //10% per minute (DEBUG)

    uint256 private constant HOLD_PERCENT_STEP = 10; //+0.1% per day (2% max)
    uint256 private constant HOLD_MAX_DAYS = 20; //max number of days for hold bonus
    uint256 private constant HOLD_BONUS_MAX = HOLD_MAX_DAYS * HOLD_PERCENT_STEP; //200 (2%)

    uint256 private constant BALANCE_PERCENT_STEP = 1; //+0.01% per balance step (1% max)
    uint256 private constant BALANCE_STEP = 100 ether;

    uint256 private constant REINVEST_BONUS = 1000; //10%
    uint256 private constant DEPOSIT_FEE = 1200; //12%
    uint256[] private REF_PERCENTS = [500, 250, 150, 100];

    address public owner;
    address payable private dev;

    uint256 private invested;
    uint256 private reinvested;
    uint256 private withdrawn;
    uint256 private totalRefRewards;
    uint256 private userCount;

    uint256 public launchTime;
    bool public launched = false;

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

    function isContract(address addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    constructor(address payable _dev) {
        require(!isContract(_dev));
        dev = _dev;
        owner = msg.sender;
    }

    function launch() external {
        require(!launched && msg.sender == owner);
        launched = true;
        launchTime = block.timestamp;
    }

    function invest(address ref) external payable nonReentrant {
        require(launched, "Not launched");
        uint256 amount = msg.value;
        require(amount >= MIN_INVEST && amount <= MAX_INVEST);

        address addr = msg.sender;
        User storage user = users[addr];
        uint8 refInc = 0;

        if (user.invested == 0) {
            user.upline = ref != addr && ref != address(0) ? ref : dev;
            user.firstInvestTime = block.timestamp; //info
            user.holdBonusStart = user.firstInvestTime;
            userCount++;
            refInc = 1;
        }

        address up = user.upline;
        for (uint8 i = 0; i < REF_PERCENTS.length && up != address(0); i++) {
            uint256 rew = (amount * REF_PERCENTS[i]) / PERCENT_DIVIDER;
            users[up].refWithdrawable += rew;
            users[up].refTotal += rew;
            totalRefRewards += rew;
            users[up].refCounts[i] += refInc;
            up = users[up].upline;
        }

        _claimReward(addr);
        _invest(addr, amount);

        dev.transfer((amount * DEPOSIT_FEE) / PERCENT_DIVIDER);
    }

    function withdrawRef(uint256 amount) external nonReentrant {
        require(launched, "Not launched");
        address addr = msg.sender;
        User storage user = users[addr];
        require(user.invested >= MIN_REF);

        if (amount == 0 || amount > user.refWithdrawable) {
            amount = user.refWithdrawable;
        }
        require(amount > 0, "No referral rewards to withdraw");

        user.refWithdrawable -= amount;
        user.refWithdrawn += amount;
        user.lastRefWithdrawnAt = block.timestamp;
        withdrawn += amount;

        payable(addr).transfer(amount);
    }

    function withdraw() external nonReentrant {
        require(launched, "Not launched");
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "No dividends");

        users[addr].holdBonusStart = block.timestamp;

        payable(addr).transfer(amount);
    }

    function reinvest() external nonReentrant {
        require(launched, "Not launched");
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "No dividends");

        amount += (amount * REINVEST_BONUS) / PERCENT_DIVIDER;
        _invest(addr, amount);

        users[addr].reinvested += amount;
        reinvested += amount;
    }

    //PRIVATE METHODS

    //claim reward and set checkpoint
    function _claimReward(address addr) private {
        uint256 rew = _getRewardOf(addr);
        //calc is done since the checkpoint. set it to now for the next
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
        user.lastWithdrawnAt = block.timestamp;
        withdrawn += amount;

        withdrawals[addr].push(
            DWStruct({amount: amount, timestamp: block.timestamp})
        );
        return amount;
    }

    function _getRewardOf(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        User storage user = users[addr];
        if (user.invested == 0 || maxReward <= user.claimedTotal) {
            return 0;
        }

        uint256 tsNow = block.timestamp;
        uint256 perc = _getBasePercentage() + _getBalanceBonusPercentage();
        uint256 rew = perc * (tsNow - user.checkpoint);

        uint256 start = user.checkpoint;
        uint256 diff = (start - user.holdBonusStart) % DAY_SECONDS;
        uint256 end = start + DAY_SECONDS - diff;
        uint256 holdBonus = _getHoldBonusPercentageFor(addr, start);
        //hold bonus calculated seperately for each day
        while (true) {
            if (end > tsNow || holdBonus == HOLD_BONUS_MAX) {
                end = tsNow; //calculate from start to now as the last step
            }
            rew += holdBonus * (end - start);
            if (end == tsNow) break;

            start = end;
            end += DAY_SECONDS;
            holdBonus += HOLD_PERCENT_STEP;
        }

        rew = (rew * user.invested) / (DAY_SECONDS * PERCENT_DIVIDER);
        return
            maxReward < rew + user.claimedTotal
                ? maxReward - user.claimedTotal
                : rew;
    }

    //return user hold bonus percentage for the date
    function _getHoldBonusPercentageFor(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        if (users[addr].holdBonusStart == 0) {
            return 0;
        }
        uint256 i = (timestamp - users[addr].holdBonusStart) / DAY_SECONDS;
        return HOLD_PERCENT_STEP * (i > HOLD_MAX_DAYS ? HOLD_MAX_DAYS : i);
    }

    function _getBasePercentage() private pure returns (uint256) {
        return DAILY_DIV;
    }

    function _getHoldBonusPercentage(address addr)
        private
        view
        returns (uint256)
    {
        return _getHoldBonusPercentageFor(addr, block.timestamp);
    }

    function _getCurrentPercentage(address addr)
        private
        view
        returns (uint256)
    {
        return
            _getBasePercentage() +
            _getHoldBonusPercentage(addr) +
            _getBalanceBonusPercentage();
    }

    function _getBalanceBonusPercentage() private view returns (uint256) {
        return BALANCE_PERCENT_STEP * (getBalance() / BALANCE_STEP);
    }

    //PUBLIC VIEW METHODS

    function getMaxReward(address addr) public view returns (uint256) {
        return (users[addr].invested * MAX_REWARDS_PERCENT) / PERCENT_DIVIDER;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWithdrawable(address addr) public view returns (uint256) {
        return users[addr].withdrawable + _getRewardOf(addr);
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
        basePercent = _getBasePercentage();
        holdBonusPercent = _getHoldBonusPercentage(addr);
        balanceBonusPercent = _getBalanceBonusPercentage();
        percentTotal = basePercent + holdBonusPercent + balanceBonusPercent;
    }

    function getUserInfo(address addr)
        external
        view
        returns (User memory user)
    {
        user = users[addr];
        user.withdrawable = getWithdrawable(addr);
    }
}