/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/*
3. 10% Deposit fee. No withdraw fee.
4. Min Deposit 0.01 BNB Max Deposit 100 BNB
9. Cant withdraw more than 200% of investment
1. Daily 1% base earnings
5. Daily +0.1% hold bonus. Max 2% (20 days) 
6. Balance bonus +0.1% for every 100 BNB in the contract. Max 2%
7. +10% reinvest bonus. Reinvesting doesnt reset hold bonus bonus
8. Daily rewards 5% total max  = %1 + hold bonus + balance bonus
9. 6 level referrals 11% (%5 %2.5 %1.5 %1 %0.5 %0.5)
*/

contract BNBMegalodonTest1 {
    uint256 private constant MIN_INVEST = 0.0000001 ether;
    uint256 private constant MAX_INVEST = 100 ether;
    uint256 private constant MAX_REWARDS_PERCENT = 20000; //200% max rewards (200% of investments including reinvestments)
    uint256 private constant DAILY_DIV = 100; //1%
    uint256 private constant HOLD_PERCENT = 10; //+0.1% per day
    uint256 private constant BALANCE_PERCENT = 1; //+0.01% per balance step (100 ether)
    uint256 private constant BONUS_STEP = 86400; //1 day
    uint256 private constant BALANCE_STEP = 100 ether;
    uint256 private constant REINVEST_BONUS = 1000; //10%
    uint256 private constant HOLD_MAX_DAYS = 20; //max number of days hold bonus applies
    uint256 private constant DEPOSIT_FEE = 1000; //10%
    uint256[] private REF_PERCENTS = [500, 250, 150, 100, 50, 50];
    uint256 private constant MAX_HOLD_BONUS = HOLD_MAX_DAYS * HOLD_PERCENT;
    uint256 private constant PERCENT_DIVIDER = 10000;
    address payable private devWallet;
    address private owner;
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
        uint256 lastWithdrawnAt;
        uint256 claimedTotal;
        uint256 checkpoint;
        uint256 refWithdrawable;
        uint256 refWithdrawn;
        uint256 refTotal;
        address upline;
        uint256 firstInvestTime;
        uint256 holdBonusStart;
        uint32[6] refCounts;
        DWStruct[] deposits; //for informational purposes
        DWStruct[] withdrawals; //for informational purposes
    }

    mapping(address => User) internal users;

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    constructor(address payable devWalletAddress) {
        require(!isContract(devWalletAddress));
        devWallet = devWalletAddress;
        owner = msg.sender;
    }

    function launch() external {
        require(!launched && owner == msg.sender);

        launched = true;
        launchTime = _dateNow();
    }

    function invest(address ref) external payable {
        require(launched && !isContract(msg.sender));
        require(msg.value >= MIN_INVEST && msg.value <= MAX_INVEST);

        if (users[msg.sender].invested == 0) {
            userCount++;
            uint256 tsNow = _dateNow();
            users[msg.sender].holdBonusStart = tsNow;
            users[msg.sender].firstInvestTime = tsNow;
            _addRef(msg.sender, ref);
        }
        _giveRefRewards(msg.sender, msg.value);
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
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
    }

    function _addRef(address addr, address ref) private {
        users[addr].upline = users[ref].invested > 0 ? ref : devWallet;
        address up = users[addr].upline;
        for (uint8 i = 0; i < 6 && up != address(0); i++) {
            users[up].refCounts[i] += 1;
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
        _claim(addr);

        users[addr].invested += amount;
        invested += amount;

        users[addr].deposits.push(
            DWStruct({amount: amount, timestamp: _dateNow()})
        );

        devWallet.transfer((amount * DEPOSIT_FEE) / PERCENT_DIVIDER);
    }

    function _withdraw(address addr) private returns (uint256) {
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
        users[addr].lastWithdrawnAt = tsNow;
        users[addr].withdrawals.push(
            DWStruct({amount: amount, timestamp: tsNow})
        );

        payable(addr).transfer(amount);
        return amount;
    }

    function _claim(address addr) private {
        uint256 rew = getReward(addr);

        users[addr].withdrawable += rew;
        users[addr].claimedTotal += rew;
        users[addr].checkpoint = _dateNow();
    }

    function _dateNow() private view returns (uint256) {
        return block.timestamp;
    }

    function getReward(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        if (users[addr].invested == 0 || users[addr].claimedTotal >= maxReward)
            return 0;

        uint256 rew = 0;
        uint256 start = users[addr].checkpoint;
        uint256 end = start;
        uint256 tsNow = _dateNow();
        uint256 perc = getBasePercentage() + getBalanceBonusPercentage();
        //loop days to calculate daily divs seperately
        //loop exits if MAX_HOLD_BONUS is reached (loops 20 times max)
        while (true) {
            uint256 holdPerc = _getHoldBonusPercentageFor(addr, start);
            if (holdPerc >= MAX_HOLD_BONUS) {
                holdPerc = MAX_HOLD_BONUS;
                //dont loop any more when we hit MAX_HOLD_BONUS
                //will calculate the rest from start to now
                end = tsNow;
            } else {
                end += BONUS_STEP;
                if (end > tsNow) end = tsNow;
            }
            rew += (perc + holdPerc) * (end - start);

            if (end >= tsNow) break;
            start = end;
        }

        rew = (rew * users[addr].invested) / (BONUS_STEP * PERCENT_DIVIDER);
        return
            maxReward < rew + users[addr].claimedTotal
                ? maxReward - users[addr].claimedTotal
                : rew;
    }

    function _getHoldBonusPercentageFor(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        uint256 i = (timestamp - users[addr].holdBonusStart) / BONUS_STEP;
        return HOLD_PERCENT * (i > HOLD_MAX_DAYS ? HOLD_MAX_DAYS : i);
    }

    function getBasePercentage() public pure returns (uint256) {
        return DAILY_DIV;
    }

    function getHoldBonusPercentage(address addr)
        public
        view
        returns (uint256)
    {
        return _getHoldBonusPercentageFor(addr, _dateNow());
    }

    function getBalanceBonusPercentage() public view returns (uint256) {
        return BALANCE_PERCENT * (getBalance() / BALANCE_STEP);
    }

    function getCurrentPercentage(address addr) public view returns (uint256) {
        return
            getBasePercentage() +
            getHoldBonusPercentage(addr) +
            getBalanceBonusPercentage();
    }

    function getMaxReward(address addr) public view returns (uint256) {
        return (users[addr].invested * MAX_REWARDS_PERCENT) / PERCENT_DIVIDER;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWithdrawable(address addr) external view returns (uint256) {
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

    function getUserInfo(address addr) external view returns (User memory) {
        return (users[addr]);
    }
}