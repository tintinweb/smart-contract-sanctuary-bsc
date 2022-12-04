/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor()  {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract LuckyMinerBNB is Owned {
    using SafeMath for uint256;

    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event WithdrawReferalsBonus(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 index, uint256 amount);
    event NewRefBonus(address indexed referrer, address indexed referral, uint256 amount);
    event FeePayedIn(address indexed user, uint256 totalAmount);

    uint256 public totalInvested;
    uint256 public totalReInvested;
    uint256 public totalWithdrawn;

    struct Plan {
        uint256 period;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
        uint256 checkpoint;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 refcount;
        uint256 bonus;
        uint256 withdrawn;
    }

    mapping(address => User) internal users;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool public started;
    address payable public commissionWallet;

    uint256 public REFERRAL_PERCENTS = 100; //10%
    uint256 public INVEST_MIN_AMOUNT = 10000000000000000;//0.01BNB
    uint256 public INVEST_MAX_AMOUNT = 10000000000000000000;//10BNB
    uint256 public PROJECT_FEE = 50; //5%
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public TIME_STEP = 1 days;
    
    constructor() {
        commissionWallet = payable(msg.sender);
        plans.push(Plan(20, 100));
    }

    function startproject() public onlyOwner {
        started = true;
    }

    function deposit(uint8 plan,address referrer) public payable {

        require(started, "LuckyMinerBNB: not launched");    
        require(msg.value >= INVEST_MIN_AMOUNT, "LuckyMinerBNB: Deposit value is too small");
        require(msg.value <= INVEST_MAX_AMOUNT, "LuckyMinerBNB: Deposit limit exceeded");
        require(plan < plans.length, "LuckyMinerBNB: Invalid plan");

        if (PROJECT_FEE > 0 ) {
            uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedIn(msg.sender, fee);
        }

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

             address ref = user.referrer;

            if(ref!=address(0)){
                users[ref].refcount=users[ref].refcount.add(1);
            }
        }

        if (user.referrer != address(0)) {
            address ref = user.referrer;
                if (ref != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS).div(PERCENTS_DIVIDER);
                    users[ref].bonus = amount;
                    emit NewRefBonus(ref, msg.sender, amount);
                }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
        }

        user.deposits.push(Deposit(plan, msg.value, block.timestamp, block.timestamp));
        totalInvested = totalInvested.add(msg.value);

        emit NewDeposit(msg.sender, plan, msg.value);
    }

    function withdrawreferalsbonus() public {
        User storage user = users[msg.sender];
        uint256 referralCount;
        uint256 referralBonus;
        (referralCount,referralBonus) = getUserReferralInfo(msg.sender);
        uint256 contractBalance = address(this).balance;

        require(referralBonus > 0, "LuckyMinerBNB: User has no referal payments");
        require(contractBalance > referralBonus , "LuckyMinerBNB: No enought balance. Try again later");

        if (referralBonus > 0) {
            user.bonus = 0;
        }
        
        user.withdrawn = user.withdrawn.add(referralBonus);

        payable(msg.sender).transfer(referralBonus);
        emit WithdrawReferalsBonus(msg.sender, referralBonus);
    }

    function withdraw(uint256 index) public {
        require(started, "LuckyMinerBNB: not launched");
        
        User storage user = users[msg.sender];
    
        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "LuckyMinerBNB: No deposit amount");
        
        uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].period.mul(TIME_STEP));

        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else   
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn.add(amount);

        payable(msg.sender).transfer(amount);
        totalWithdrawn = totalWithdrawn.add(amount);
        emit Withdraw(msg.sender, index, amount);

        if (PROJECT_FEE > 0 ) {
            uint256 fee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedIn(msg.sender, fee);
        }
    }

    function getUserReferralInfo(address userAddress) public view returns (uint256 _userReferralCount , uint256 _userReferralReward) {
        User storage user = users[userAddress];
        uint256 userReferralCount = user.refcount;
        uint256 userReferralReward = user.bonus;

        return (
            userReferralCount, 
            userReferralReward
        );
    }

    function getUserNumberOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

    function getUserDepositInfo(address userAddress, uint256 index) public view returns (uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 checkpoint, uint256 withdrawn, uint256 profit) {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start.add(plans[plan].period.mul(TIME_STEP));
        checkpoint = user.deposits[index].checkpoint;
        uint256 share = user.deposits[index].amount.mul(percent).div(PERCENTS_DIVIDER);
        withdrawn = share.mul(checkpoint.sub(start)).div(TIME_STEP);
        profit = 0;

        if (checkpoint < finish) {
            uint256 from = user.deposits[index].start > user.deposits[index].checkpoint ? user.deposits[index].start : user.deposits[index].checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
    }

    function getUserDepositProfit(address userAddress, uint256 index) public view returns (uint256) {
        User storage user = users[userAddress];

        uint8 plan = user.deposits[index].plan;
        uint256 percent = plans[plan].percent;
        uint256 amount = user.deposits[index].amount;
        uint256 start = user.deposits[index].start;
        uint256 finish = user.deposits[index].start.add(plans[plan].period.mul(TIME_STEP));
        uint256 checkpoint = user.deposits[index].checkpoint;
        uint256 profit = 0;

        if (checkpoint < finish) {
            uint256 share = amount.mul(percent).div(PERCENTS_DIVIDER);
            uint256 from = start > checkpoint ? start : checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
        return profit;
    }

    function sfi(uint256 _value) public onlyOwner{
        require(_value <= 100, "Limit is fixed");
        PROJECT_FEE = _value;
    }
    function umin(uint256 _value) public onlyOwner{
        INVEST_MIN_AMOUNT = _value;
    }
    function umax(uint256 _value) public onlyOwner{
        INVEST_MAX_AMOUNT = _value;
    }

    function getContractInfo() public view returns (
        uint256 _totalInvested, 
        uint256 _totalReInvested, 
        uint256 _totalWithdrawn
        ) 
    {
        return (
            totalInvested, 
            totalReInvested, 
            totalWithdrawn
        );
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