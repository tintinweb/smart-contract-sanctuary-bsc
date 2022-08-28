/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/*
1. 10% deposit fee
2. Min deposit 0.01 BNB Max deposit 100 BNB
3. Max 200% rewards payout
4. 5% daily rewards max (%1 base + %2 hold bonus + %2 balance bonus)
5. Hold bonus increases every day +0.1% for a max of +2% (20 days). Bonus resets to zero after a withdrawal
6. Balance bonus +0.01% for every 100 BNB in the contract. Max +2% (20000 bnb)
7. +10% reinvest bonus. Does not reset hold bonus. No reinvest fee.
8. 4 level referrals 10% (1st level 5%, 2nd level 2.5%, 3rd level 1.5%, 4th level 1%)
9. Withdraw or reinvest anytime with no fees.
10. User must invest over 0.5 BNB to get referral rewards.
*/

contract BNBMegalodonTest1 {
    uint256 private constant PERCENT_DIVIDER = 10000;

    uint256 private constant MIN_REF = 0.5 ether; //min amount of investment needed to be a ref
    uint256 private constant MIN_INVEST = 0.01 ether;
    uint256 private constant MAX_INVEST = 100 ether;
    uint256 private constant MAX_REWARDS_PERCENT = 20000; //200% max rewards including reinvestments
    uint256 private constant DAILY_DIV = 100; //1%

    uint256 private constant HOLD_TIMESTEP = 86400; //1 day
    uint256 private constant HOLD_PERCENT_STEP = 10; //+0.1% per day (2% max)
    uint256 private constant HOLD_MAX_DAYS = 20; //max number of days for hold bonus
    uint256 private constant HOLD_BONUS_MAX = HOLD_MAX_DAYS * HOLD_PERCENT_STEP; //200 (2%)

    uint256 private constant BALANCE_PERCENT_STEP = 1; //+0.01% per balance step (1% max)
    uint256 private constant BALANCE_STEP = 100 ether;

    uint256 private constant REINVEST_BONUS = 1000; //10%
    uint256 private constant DEPOSIT_FEE = 1000; //10% (5% developer %5 marketing)
    uint256[] private REF_PERCENTS = [500, 250, 150, 100];

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
    }

    function invest(address ref) external payable {
        address addr = msg.sender;
        uint256 amount = msg.value;
        require(amount >= MIN_INVEST && amount <= MAX_INVEST);
        if (!launched && dev == addr) {
            launched = true;
            launchTime = block.timestamp;
        }
        require(launched && !isContract(addr) && !isContract(ref));

        User storage user = users[addr];
        uint8 refInc = 0;
        //new user?
        if (user.invested == 0) {
            user.upline = users[ref].invested >= MIN_REF ? ref : dev;
            user.holdBonusStart = block.timestamp;
            user.firstInvestTime = block.timestamp; //info
            userCount++;
            refInc = 1;
        }
        address up = user.upline;
        for (uint8 i = 0; i < REF_PERCENTS.length; i++) {
            if (up == address(0)) break;
            uint256 rew = (amount * REF_PERCENTS[i]) / PERCENT_DIVIDER;
            users[up].refWithdrawable += rew;
            users[up].refTotal += rew;
            totalRefRewards += rew;
            //increase refCounts of uplines for new users
            users[up].refCounts[i] += refInc;
            up = users[up].upline;
        }
        //user.checkpoint is set in _invest (_payout)
        _invest(addr, amount);

        dev.transfer((amount * DEPOSIT_FEE) / PERCENT_DIVIDER);
    }

    function withdrawRef(uint256 amount) external {
        address addr = msg.sender;
        require(launched && !isContract(addr));
        User storage user = users[addr];
        if (amount == 0 || amount > user.refWithdrawable) {
            amount = user.refWithdrawable;
        }
        user.lastRefWithdrawnAt = block.timestamp;
        if (amount > 0) {
            user.refWithdrawable -= amount;
            user.refWithdrawn += amount;
            withdrawn += amount;
            payable(addr).transfer(amount);
        }
    }

    function withdraw() external {
        address addr = msg.sender;
        require(launched && !isContract(addr));
        _withdraw(addr);
        users[addr].holdBonusStart = block.timestamp;
    }

    function reinvest() external {
        address addr = msg.sender;
        require(launched && !isContract(addr));
        uint256 amount = _withdraw(addr);
        if (amount > 0) {
            amount += (amount * REINVEST_BONUS) / PERCENT_DIVIDER;
            //user.checkpoint is set in _invest (_payout)
            _invest(addr, amount);
            users[addr].reinvested += amount;
            reinvested += amount;
        }
    }

    //PRIVATE METHODS
    function _invest(address addr, uint256 amount) private {
        _payout(addr);
        users[addr].invested += amount;
        invested += amount;
        deposits[addr].push(
            DWStruct({amount: amount, timestamp: block.timestamp})
        );
    }

    function _withdraw(address addr) private returns (uint256) {
        _payout(addr);
        uint256 balance = getBalance();
        uint256 amount = (users[addr].withdrawable < balance)
            ? users[addr].withdrawable
            : balance;

        users[addr].lastWithdrawnAt = block.timestamp;
        if (amount == 0) {
            return 0;
        }
        users[addr].withdrawable -= amount;
        users[addr].withdrawn += amount;
        withdrawn += amount;

        withdrawals[addr].push(
            DWStruct({amount: amount, timestamp: block.timestamp})
        );
        payable(addr).transfer(amount);
        return amount;
    }

    //payout rewards and set checkpoint
    function _payout(address addr) private {
        uint256 rew = _getReward(addr);
        users[addr].withdrawable += rew;
        users[addr].claimedTotal += rew;
        //calculations are done since the checkpoint. set it to now for the next
        users[addr].checkpoint = block.timestamp;
    }

    function _getReward(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        User storage user = users[addr];

        if (user.invested == 0 || maxReward <= user.claimedTotal) {
            return 0;
        }

        uint256 tsNow = block.timestamp;
        uint256 perc = _getBasePercentage() + _getBalanceBonusPercentage();
        uint256 rew = perc * (tsNow - user.checkpoint); //dont need the loop for calculating base and balance bonus rewards

        uint256 start = user.checkpoint;
        uint256 diff = (start - user.holdBonusStart) % HOLD_TIMESTEP;
        uint256 end = start + HOLD_TIMESTEP - diff;
        //loop to calculate hold bonus rewards seperately for each day
        uint256 holdBonus = _getHoldBonusPercentageFor(addr, start);
        while (true) {
            //max 20 loops
            if (end > tsNow || holdBonus == HOLD_BONUS_MAX) {
                end = tsNow; //stop loop if it reaches HOLD_BONUS_MAX. calculate from start to now as the last step
            }
            rew += holdBonus * (end - start);
            if (end == tsNow) break;

            start = end;
            end += HOLD_TIMESTEP;
            holdBonus += HOLD_PERCENT_STEP;
        }

        rew = (rew * user.invested) / (HOLD_TIMESTEP * PERCENT_DIVIDER);
        return
            maxReward < rew + user.claimedTotal
                ? maxReward - user.claimedTotal
                : rew;
    }

    //return users hold bonus percentage for the date
    function _getHoldBonusPercentageFor(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        if (users[addr].holdBonusStart == 0) {
            return 0;
        }
        uint256 i = (timestamp - users[addr].holdBonusStart) / HOLD_TIMESTEP;
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
        return users[addr].withdrawable + _getReward(addr);
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
        user.withdrawable = getWithdrawable(addr); //user is in memory we are not altering storage
    }
}