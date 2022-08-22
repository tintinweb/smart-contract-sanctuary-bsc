/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/* ***********************************************************************************************************
1. 10% Deposit fee
2. Min Deposit 0.01 BNB Max Deposit 100 BNB
3. Max 200% rewards payout
4. Daily 1% base dividends
5. Hold bonus increases every day +0.1% for a max of +2% (20 days). Bonus resets to zero after a withdrawal
6. +10% reinvest bonus. Does not reset hold bonus
7. Balance bonus +0.01% for every 100 BNB in the contract. Max +2% (20000 bnb)
8. Daily rewards 5% max  = %1 base + %2 hold bonus + %2 balance bonus
9. 6 level referrals 11% (%5 %2.5 %1.5 %1 %0.5 %0.5)
10. Withdraw or reinvest anytime
*********************************************************************************************************** */

contract BNBMegalodonTest1 {
    uint256 private constant PERCENT_DIVIDER = 10000;

    uint256 private constant MIN_INVEST = 0.0000001 ether;
    uint256 private constant MAX_INVEST = 100 ether;
    uint256 private constant MAX_REWARDS_PERCENT = 20000; //200% max rewards including reinvestments
    uint256 private constant DAILY_DIV = 100; //1%
    uint256 private constant HOLD_PERCENT = 10; //+0.1% per day (2% max)
    uint256 private constant BALANCE_PERCENT = 1; //+0.01% per balance step (1% max)
    uint256 private constant BONUS_STEP = 86400; //1 day
    uint256 private constant BALANCE_STEP = 100 ether;
    uint256 private constant REINVEST_BONUS = 1000; //10%
    uint256 private constant HOLD_MAX_DAYS = 20; //max number of days hold bonus applies
    uint256 private constant DEPOSIT_FEE = 1000; //10%
    uint256[] private REF_PERCENTS = [500, 250, 150, 100, 50, 50];

    uint256 private constant MAX_HOLD_BONUS = HOLD_MAX_DAYS * HOLD_PERCENT; //200 (2%)
    address payable private devWallet;

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
        uint32[6] refCounts; //info
        DWStruct[] deposits; //info
        DWStruct[] withdrawals; //info
    }

    mapping(address => User) internal users;

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    constructor(address payable devWalletAddress) {
        require(!isContract(devWalletAddress));
        devWallet = devWalletAddress;
    }

    function invest(address ref) external payable {
        if (!launched && devWallet == msg.sender) {
            launched = true;
            launchTime = _dateNow();
        }

        require(launched && !isContract(msg.sender));
        require(msg.value >= MIN_INVEST && msg.value <= MAX_INVEST);

        if (users[msg.sender].invested == 0) {
            _addRef(msg.sender, ref);
            userCount++;
            uint256 tsNow = _dateNow();
            users[msg.sender].holdBonusStart = tsNow;
            users[msg.sender].firstInvestTime = tsNow;
        }
        _giveRefRewards(msg.sender, msg.value);

        //user.checkpoint is set in _invest (in _claim)
        _invest(msg.sender, msg.value);
    }

    function reinvest() external {
        require(launched && !isContract(msg.sender));

        uint256 amount = _withdraw(msg.sender);
        amount += (amount * REINVEST_BONUS) / PERCENT_DIVIDER;

        _invest(msg.sender, amount);

        users[msg.sender].reinvested += amount;
        reinvested += amount;
    }

    function withdraw() external {
        require(launched && !isContract(msg.sender));

        _withdraw(msg.sender);
        users[msg.sender].holdBonusStart = _dateNow();
    }

    function withdrawRef() external {
        require(launched && !isContract(msg.sender));

        uint256 amount = users[msg.sender].refWithdrawable;
        users[msg.sender].refWithdrawable = 0;
        users[msg.sender].refWithdrawn += amount;
        users[msg.sender].lastRefWithdrawnAt = _dateNow();
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
    }

    function _addRef(address addr, address ref) private {
        address up = (users[ref].invested > 0) ? ref : devWallet;
        users[addr].upline = up;
        for (uint8 i = 0; i < 6 && up != address(0); i++) {
            ++users[up].refCounts[i];
            up = users[up].upline;
        }
    }

    function _giveRefRewards(address addr, uint256 amount) private {
        address up = users[addr].upline;
        for (uint8 i = 0; i < 6 && up != address(0); i++) {
            uint256 rew = (amount * REF_PERCENTS[i]) / PERCENT_DIVIDER;
            users[up].refWithdrawable += rew;
            users[up].refTotal += rew;
            totalRefRewards += rew;
            up = users[up].upline;
        }
    }

    function _invest(address addr, uint256 amount) private {
        //must claim before invest reinvest and withdraw
        _claim(addr);

        users[addr].invested += amount;
        invested += amount;

        //info only. not used in calculations
        users[addr].deposits.push(
            DWStruct({amount: amount, timestamp: _dateNow()})
        );

        devWallet.transfer((amount * DEPOSIT_FEE) / PERCENT_DIVIDER);
    }

    function _withdraw(address addr) private returns (uint256) {
        //must claim before invest reinvest and withdraw
        _claim(addr);

        uint256 balance = getBalance();
        uint256 amount = users[addr].withdrawable < balance
            ? users[addr].withdrawable
            : balance;

        if (amount == 0) return 0;

        users[addr].withdrawable -= amount;
        users[addr].withdrawn += amount;
        withdrawn += amount;

        uint256 tsNow = _dateNow();

        //info only. not used in calculations
        users[addr].lastWithdrawnAt = tsNow;
        users[addr].withdrawals.push(
            DWStruct({amount: amount, timestamp: tsNow})
        );

        payable(addr).transfer(amount);
        return amount;
    }

    function _claim(address addr) private {
        uint256 rew = getReward(addr);

        users[addr].checkpoint = _dateNow();
        users[addr].withdrawable += rew;
        users[addr].claimedTotal += rew;
    }

    function getReward(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        if (maxReward == 0 || maxReward <= users[addr].claimedTotal) return 0;

        User storage user = users[addr];
        uint256 tsNow = _dateNow();

        uint256 perc = getBasePercentage() + getBalanceBonusPercentage();
        uint256 rew = perc * (tsNow - user.checkpoint); //dont need the loop for calculating base dividend and balance bonus rewards

        uint256 start = user.checkpoint;
        uint256 diff = (start - user.holdBonusStart) % BONUS_STEP;
        uint256 end = start + BONUS_STEP - diff;
        //loop days to calculate daily hold bonus rewards seperately
        uint256 holdBonus = _getHoldBonusPercentageFor(addr, start);
        while (true) {
            if (end > tsNow || holdBonus == MAX_HOLD_BONUS) {
                end = tsNow; //dont loop any more when we hit MAX_HOLD_BONUS calculate the rest from start to now
            }
            rew += holdBonus * (end - start);
            if (end == tsNow) break;

            start = end;
            end += BONUS_STEP;
            holdBonus += HOLD_PERCENT;
        }

        rew = (rew * user.invested) / (BONUS_STEP * PERCENT_DIVIDER);
        return
            maxReward < rew + user.claimedTotal
                ? maxReward - user.claimedTotal
                : rew;
    }

    function _dateNow() private view returns (uint256) {
        return block.timestamp;
    }

    function _getHoldBonusPercentageFor(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        if (users[addr].holdBonusStart == 0) return 0;

        uint256 i = (timestamp - users[addr].holdBonusStart) / BONUS_STEP;
        return HOLD_PERCENT * (i > HOLD_MAX_DAYS ? HOLD_MAX_DAYS : i);
    }

    function getBasePercentage() private pure returns (uint256) {
        return DAILY_DIV;
    }

    function getHoldBonusPercentage(address addr)
        private
        view
        returns (uint256)
    {
        return _getHoldBonusPercentageFor(addr, _dateNow());
    }

    function getCurrentPercentage(address addr) private view returns (uint256) {
        return
            getBasePercentage() +
            getHoldBonusPercentage(addr) +
            getBalanceBonusPercentage();
    }

    function getBalanceBonusPercentage() public view returns (uint256) {
        return BALANCE_PERCENT * (getBalance() / BALANCE_STEP);
    }

    function getMaxReward(address addr) public view returns (uint256) {
        return (users[addr].invested * MAX_REWARDS_PERCENT) / PERCENT_DIVIDER;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWithdrawable(address addr) public view returns (uint256) {
        return users[addr].withdrawable + getReward(addr);
    }

    function getUserDeposits(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return users[addr].deposits;
    }

    function getUserWithdrawals(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return users[addr].withdrawals;
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
        basePercent = getBasePercentage();
        holdBonusPercent = getHoldBonusPercentage(addr);
        balanceBonusPercent = getBalanceBonusPercentage();
        percentTotal = basePercent + holdBonusPercent + balanceBonusPercent;
    }

    function getUserInfo(address addr)
        external
        view
        returns (User memory user)
    {
        user = users[addr];
        user.withdrawable = getWithdrawable(addr); //user is in memory so we are not altering state (we are in a view function anyways)
    }
}