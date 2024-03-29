// SPDX-License-Identifier: MIT



pragma solidity >=0.4.22 <0.9.0;

// Main Contract
contract AVAXFortune {
    using SafeMath for uint256;
    address payable public PLATFORM_WALLET;
    address payable public DEPLOYER;

    uint256 public constant MIN_AMOUNT = 0.1 ether;
    uint256[3] public REF_DEP_PERCENTS = [5_00, 3_00, 1_00];
    uint256[3] public REF_WID_PERCENTS = [1_50, 50, 10];
    uint256 public constant DEPOSIT_FEE = 10_00; // 10% deposit fee
    uint256 public constant WITHDRAW_FEE = 6_00; // 6% withdraw fee
    uint256 public constant P_WITHDRAW_FEE = 62_50; // 6% withdraw fee for owner
    uint256 public constant I_WITHDRAW_FEE = 37_50; // 4% withdraw fee for insurance
    uint256 public constant PERCENT_STEP = 20; // 0.2% daily increment
    uint256 public constant WITHDRAW_TAX_PERCENT = 35_00; // emergency withdraw tax 35%
    uint256 public constant P_WITHDRAW_TAX_PERCENT = 10_00; // emergency withdraw tax 10% for owner
    uint256 public constant I_WITHDRAW_TAX_PERCENT = 10_00; // emergency withdraw tax 10% for insurance
    uint256 public constant MAX_HOLD_PERCENT = 2_00; // 2% hold bonus
    uint256 public constant PERCENTS_DIVIDER = 100_00;
    uint256 public TIME_STEP = 1 minutes;

    uint256 public startTime;
    uint256 public totalStaked;
    uint256 public totalWithdrawn;
    uint256 public totalRefBonus;
    uint256 public insuranceTriggerBalance;
    uint256 public totalUsers;

    bool public launched;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 profit;
        uint256 start;
        uint256 finish;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 holdBonusCheckpoint;
        address referrer;
        uint256[3] levels;
        uint256 bonus;
        uint256 debt;
        uint256 totalBonus;
        uint256 totalWithdrawn;
    }

    mapping(address => User) internal users;
    mapping(uint256 => uint256) public INSURANCE_MAXBALANCE;

    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "NOT AN OWNER");
        _;
    }

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 profit,
        uint256 start,
        uint256 finish
    );
    event Withdrawn(address indexed user, uint256 amount);
    event REINVEST(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        // address payable _platform,
        // address payable _insurance,
        // uint256 _time
    ) {
        startTime = block.timestamp;
        DEPLOYER = payable(msg.sender);
        PLATFORM_WALLET = payable(msg.sender);
        PLATFORM_WALLET = payable(msg.sender);

        plans.push(Plan(16, 8_50));
        plans.push(Plan(28, 10_00));
        plans.push(Plan(0, 7_00));
        plans.push(Plan(16, 16_50));
        plans.push(Plan(28, 13_00));
    }

    receive() external payable {}

    function invest(address referrer, uint8 plan) public payable {
        require(launched, "wait for the launch");
        require(!isContract(msg.sender));
        require(msg.value >= MIN_AMOUNT, "less than min Limit");
        deposit(msg.sender, referrer, plan, msg.value);
    }

    function deposit(
        address userAddress,
        address referrer,
        uint8 plan,
        uint256 amount
    ) internal {
        require(plan < 5, "Invalid plan");
        User storage user = users[userAddress];

        uint256 fee = amount.mul(DEPOSIT_FEE).div(PERCENTS_DIVIDER);
        PLATFORM_WALLET.transfer(fee);
        emit FeePayed(userAddress, fee);

        if (user.referrer == address(0)) {
            if (
                (users[referrer].deposits.length == 0 ||
                    referrer == userAddress)
            ) {
                referrer = DEPLOYER;
            }

            user.referrer = referrer;

            address upline = user.referrer;
            for (uint256 i = 0; i < REF_DEP_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REF_DEP_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 refAmount = amount.mul(REF_DEP_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(refAmount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        refAmount
                    );
                    totalRefBonus = totalRefBonus.add(refAmount);
                    emit RefBonus(upline, userAddress, i, refAmount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            totalUsers = totalUsers.add(1);
            user.checkpoint = block.timestamp;
            user.holdBonusCheckpoint = block.timestamp;
            emit Newbie(userAddress);
        }

        (uint256 percent, uint256 profit, uint256 finish) = getResult(
            plan,
            amount
        );
        user.deposits.push(
            Deposit(plan, percent, amount, profit, block.timestamp, finish)
        );

        totalStaked = totalStaked.add(amount);
        emit NewDeposit(
            userAddress,
            plan,
            percent,
            amount,
            profit,
            block.timestamp,
            finish
        );
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(
            block.timestamp >= user.checkpoint.add(TIME_STEP),
            "wait for next withdraw"
        );

        uint256 totalAmount = getUserDividends(msg.sender);
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }
        if (user.debt > 0) {
            totalAmount = totalAmount.add(user.debt);
            user.debt = 0;
        }
        require(totalAmount > 0, "User has no dividends");
        uint256 fee = totalAmount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
        PLATFORM_WALLET.transfer(fee.mul(P_WITHDRAW_FEE).div(PERCENTS_DIVIDER));
        PLATFORM_WALLET.transfer(
            fee.mul(I_WITHDRAW_FEE).div(PERCENTS_DIVIDER)
        );
        totalAmount = totalAmount.sub(fee);

        uint256 contractBalance = address(this).balance;
        if (totalAmount > contractBalance) {
            user.debt = user.debt.add(totalAmount.sub(contractBalance));
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        user.holdBonusCheckpoint = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);

        payable(msg.sender).transfer(totalAmount);

        if (user.referrer != address(0) && contractBalance >= totalAmount.div(20)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REF_WID_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 refAmount = totalAmount
                        .mul(REF_WID_PERCENTS[i])
                        .div(PERCENTS_DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(refAmount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        refAmount
                    );
                    totalRefBonus = totalRefBonus.add(refAmount);
                    emit RefBonus(upline, msg.sender, i, refAmount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        emit Withdrawn(msg.sender, totalAmount);
    }

    function launch() external onlyDeployer {
        require(!launched, "Already launched");
        launched = true;
        startTime = block.timestamp;
    }

    function changeDeployer(address payable _new) external onlyDeployer {
        require(!isContract(_new), "Can't be a contract");
        DEPLOYER = _new;
    }

    function changePlatform(address payable _new) external onlyDeployer {
        require(!isContract(_new), "Can't be a contract");
        PLATFORM_WALLET = _new;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent)
    {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function getPercent(uint8 plan) public view returns (uint256) {
        if (block.timestamp > startTime) {
            return
                plans[plan].percent.add(
                    PERCENT_STEP.mul(block.timestamp.sub(startTime)).div(
                        TIME_STEP
                    )
                );
        } else {
            return plans[plan].percent;
        }
    }

    function getResult(uint8 plan, uint256 amount)
        public
        view
        returns (
            uint256 percent,
            uint256 profit,
            uint256 finish
        )
    {
        percent = getPercent(plan);

        if (plan < 3) {
            profit = amount.mul(percent).mul(plans[plan].time).div(100);
        } else if (plan < 5) {
            profit = amount.mul(percent);
            for (uint256 i = 1; i < plans[plan].time; i++) {
                uint256 newProfit = profit.mul(percent).div(PERCENTS_DIVIDER);
                profit = profit.add(newProfit);
            }
            profit = profit.div(100);
        }

        finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;
        uint256 holdBonus = getUserHoldBonusPercent(userAddress);

        for (uint256 i = 0; i < user.deposits.length; i++) {
            
            if (user.checkpoint < user.deposits[i].finish || user.deposits[i].finish == user.deposits[i].start) {
                if(user.deposits[i].plan == 2){

                    totalAmount = totalAmount.add(
                        user.deposits[i].amount.mul(
                            user.deposits[i].percent.add(holdBonus)
                        ).div(PERCENTS_DIVIDER)
                    );
                } else if (user.deposits[i].plan < 2) {
                    uint256 share = user
                        .deposits[i]
                        .amount
                        .mul(user.deposits[i].percent.add(holdBonus))
                        .div(PERCENTS_DIVIDER);
                    uint256 from = user.deposits[i].start > user.checkpoint
                        ? user.deposits[i].start
                        : user.checkpoint;
                    uint256 to = user.deposits[i].finish < block.timestamp
                        ? user.deposits[i].finish
                        : block.timestamp;
                    if (from < to) {
                        totalAmount = totalAmount.add(
                            share.mul(to.sub(from)).div(TIME_STEP)
                        );
                    }
                } else if (block.timestamp > user.deposits[i].finish ) {
                    totalAmount = totalAmount.add(
                        user.deposits[i].profit.div(100)
                    );
                }
            }
        }

        return totalAmount;
    }

    function getUserHoldBonusPercent(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 timeMultiplier = block
            .timestamp
            .sub(user.holdBonusCheckpoint)
            .div(TIME_STEP);
        timeMultiplier = timeMultiplier.mul(20); // +0.2% per day
        if (timeMultiplier > MAX_HOLD_PERCENT) {
            timeMultiplier = MAX_HOLD_PERCENT;
        }
        return timeMultiplier;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserHoldBonusCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].holdBonusCheckpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (
            uint256 level1,
            uint256 level2,
            uint256 level3
        )
    {
        level1 = users[userAddress].levels[0];
        level2 = users[userAddress].levels[1];
        level3 = users[userAddress].levels[2];
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserDebt(address userAddress) public view returns (uint256) {
        return users[userAddress].debt;
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            getUserReferralBonus(userAddress)
                .add(getUserDividends(userAddress))
                .add(getUserDebt(userAddress));
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 profit,
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalWithdrawn;
    }

    function isDepositActive(address userAddress, uint256 index)
        public
        view
        returns (bool)
    {
        User storage user = users[userAddress];

        return (user.deposits[index].finish > block.timestamp);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}