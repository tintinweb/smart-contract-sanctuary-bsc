/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
contract LionsCrypto {
    using SafeMath for uint256;

    uint256 public constant INVEST_MIN_AMOUNT = 0.20 ether; // 0.05 bnb
    uint256 public constant Plan_ONE_90 = 90 ether; // 0.05 bnb
    uint256 public constant Plan_ONE_45 = 45 ether;

    uint256[] public REFERRAL_PERCENTS = [30, 30, 30, 30, 30];
    uint256 public constant TOTAL_REF = 30;
      

    // uint256 constant public PROJECT_FEE = 5;
    // uint256 constant public DEV_FEE = 2;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 days;

    uint256 public totalInvested;

    struct Plan {
        uint256 time;
        uint256 percent;
        // uint256 start_amount;
        // uint256 end_amount;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 profit;
        address referrer;
        uint256[5] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
    }

    mapping(address => User) internal users;

    uint256 public startDate;
        bool private initialized = false;


    address payable public ceoWallet1;
    address payable public ceoWallet2;
    address payable public devWallet;

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 amount,
        uint256 time
    );
    event Withdrawn(address indexed user, uint256 amount);
	event Reinvest(address indexed user,uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        // address payable ceoAddr1,
        // address payable ceoAddr2,
        address payable devAddr,
        uint256 start
    ) public {
        require(
            // !isContract(ceoAddr1) &&
            //     !isContract(ceoAddr2) &&
                !isContract(devAddr)
        );
        // ceoWallet1 = ceoAddr1;
        // ceoWallet2 = ceoAddr2;
        devWallet = devAddr;

        if (start > 0) {
            startDate = start;
        } else {
            startDate = block.timestamp;
        }

        plans.push(Plan(100, 20));
        plans.push(Plan(200, 10));
        plans.push(Plan(400, 5));
    }

    function Plan1(address referrer, uint8 plan) public payable {
        require(block.timestamp > startDate, "contract does not launch yet");
        require(
            msg.value >= INVEST_MIN_AMOUNT,
            "Should Have 1 BNB to Investment"
        );
        require(plan < 3, "Invalid plan");
        
        // uint256 pFee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER).div(2);
        // uint256 dFee = msg.value.mul(DEV_FEE).div(PERCENTS_DIVIDER);
        // ceoWallet1.transfer(pFee);
        // ceoWallet2.transfer(pFee);
        // devWallet.transfer(dFee);
        // emit FeePayed(msg.sender, pFee.add(dFee.mul(2)));

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        amount
                    );
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    // devWallet.transfer(amount);
                }
            }
        } else {
           
               uint256 amount = msg.value.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
        
            
            // devWallet.transfer(amount);
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(plan, msg.value, block.timestamp));
        totalInvested = totalInvested.add(msg.value);
        emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
        reinvest(referrer,plan);
    }

	function reinvest(address referrer,uint8 plan) public payable  {
         

         
        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    // uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(
                    //     PERCENTS_DIVIDER
                    // );
                    // users[upline].bonus = users[upline].bonus.add(amount);
                    // users[upline].totalBonus = users[upline].totalBonus.add(
                    //     amount
                    // );
                    // emit RefBonus(upline, msg.sender, i, amount);
                    // upline = users[upline].referrer;
                } else {
                    // uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(
                    //     PERCENTS_DIVIDER
                    // );
                    // devWallet.transfer(amount);
                }
            }
        } else {
           
               uint256 amount = msg.value.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
        
            
            // devWallet.transfer(amount);
        }

         uint256 totalAmount = getUserDividends(msg.sender);
          user.deposits.push(Deposit(plan, totalAmount, block.timestamp));
        totalInvested = totalInvested.add(totalAmount);
         uint256 contractBalance = address(this).balance;
       
        contractBalance.add(totalAmount);
        emit NewDeposit(msg.sender, plan, totalAmount, block.timestamp);
      
	}

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserDividends(msg.sender);

        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            user.bonus = totalAmount.sub(contractBalance);
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);

        msg.sender.transfer(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
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

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start.add(
                plans[user.deposits[i].plan].time.mul(TIME_STEP)
            );
            if (user.checkpoint < finish) {
                uint256 share = user.deposits[i].amount
                    .mul(plans[user.deposits[i].plan].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = finish < block.timestamp
                    ? finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }
            }
        }

        return totalAmount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
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
        returns (uint256[5] memory referrals)
    {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            users[userAddress].levels[0] +
            users[userAddress].levels[1] +
            users[userAddress].levels[2] +
            users[userAddress].levels[3] +
            users[userAddress].levels[4];
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

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            getUserReferralBonus(userAddress).add(
                getUserDividends(userAddress)
            );
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
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;

        finish = user.deposits[index].start.add(
            plans[user.deposits[index].plan].time.mul(TIME_STEP)
        );
    }

    function getSiteInfo()
        public
        view
        returns (uint256 _totalInvested)
    {
        return (
            totalInvested
        );
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            uint256 totalDeposit,
            uint256 totalWithdrawn,
            uint256 totalReferrals
        )
    {
        return (
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress),
            getUserTotalReferrals(userAddress)
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    function withdrawForce() external  payable  {
    	require(msg.sender == devWallet, "only owner");
    	msg.sender.transfer(address(this).balance);
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