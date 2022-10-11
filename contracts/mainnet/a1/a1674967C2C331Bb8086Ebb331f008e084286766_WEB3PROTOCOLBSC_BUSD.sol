/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

pragma solidity 0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract WEB3PROTOCOLBSC_BUSD {
    using SafeMath for uint256;
    IERC20 public token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //** Main
    uint256 public startDate;
    uint256 public constant INVEST_MIN_AMOUNT = 5e18;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant CONTRACT_BALANCE_STEP = 50000 ether;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public constant BASE_PERCENT = 10; // 1%
    uint256 public constant MARKETING_FEE = 40; // 4%
    uint256 public constant PROJECT_FEE = 40; // 4%
    uint256 public constant FUND_FEE = 40; // 4%
    uint256[] public REFERRAL_PERCENTS = [50, 20, 5]; // 5%, 2%, 0.5%

    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;

    address payable public projectAddress;
    address payable public marketingAddress;
    address payable public fundAddress;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
    }

    mapping(address => User) private _users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    // -----------------------------------------
    // CONSTRUCTOR
    // -----------------------------------------

    constructor(
        address payable marketingAddr,
        address payable fundAddr,
        uint256 startTime
    ) public {
        require(
            !isContract(marketingAddr) &&
                !isContract(msg.sender) &&
                !isContract(fundAddr)
        );

        projectAddress = msg.sender;
        marketingAddress = marketingAddr;
        fundAddress = fundAddr;

        if (startTime > 0) {
            startDate = startTime;
        } else {
            startDate = block.timestamp;
        }
    }

    // -----------------------------------------
    // SETTERS
    // -----------------------------------------

    function feePayout(uint256 msgValue) internal {
        uint256 pFee = msgValue.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 mFee = msgValue.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint256 fFee = msgValue.mul(FUND_FEE).div(PERCENTS_DIVIDER);

        token.transfer(projectAddress, pFee);
        token.transfer(marketingAddress, mFee);
        token.transfer(fundAddress, fFee);

        emit FeePayed(msg.sender, fFee.add(pFee).add(mFee));
    }

    function invest(address referrer, uint256 amounts) public {
        require(block.timestamp > startDate, "contract does not launch yet");
        require(amounts >= INVEST_MIN_AMOUNT);
        token.transferFrom(msg.sender, address(this), amounts);

        feePayout(amounts);

        User storage user = _users[msg.sender];

        if (
            user.referrer == address(0) &&
            _users[referrer].deposits.length > 0 &&
            referrer != msg.sender
        ) {
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;

            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    uint256 amount = amounts.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    _users[upline].bonus = _users[upline].bonus.add(amount);
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = _users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers += 1;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(amounts, 0, block.timestamp));
        totalInvested = totalInvested.add(amounts);
        totalDeposits += 1;

        emit NewDeposit(msg.sender, amounts);
    }

    function withdraw() external {
        User storage user = _users[msg.sender];

        uint256 dividends;
        uint256 totalAmount;
        uint256 userPercentRate = getUserPercentRate(msg.sender);

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(userPercentRate).div(
                            PERCENTS_DIVIDER
                        )
                    ).mul(block.timestamp.sub(user.deposits[i].start)).div(
                            TIME_STEP
                        );
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(userPercentRate).div(
                            PERCENTS_DIVIDER
                        )
                    ).mul(block.timestamp.sub(user.checkpoint)).div(TIME_STEP);
                }

                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(2)
                ) {
                    dividends = (user.deposits[i].amount.mul(2)).sub(
                        user.deposits[i].withdrawn
                    );
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(
                    dividends
                );
                totalAmount = totalAmount.add(dividends);
            }
        }

        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            totalAmount = totalAmount.add(referralBonus);
            user.bonus = 0;
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = token.balanceOf(address(this));

        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        token.transfer(msg.sender, totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function UpdateStartDate(uint256 _startDate) public {
        require(
            msg.sender == projectAddress,
            "Only developer can update start date"
        );
        require(block.timestamp < startDate, "Start date must be in future");
        startDate = _startDate;
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getContractBalancePercent() external view returns (uint256) {
        uint256 contractBalance = token.balanceOf(address(this));
        uint256 contractBalancePercent = contractBalance.div(
            CONTRACT_BALANCE_STEP
        );

        return contractBalancePercent;
    }

    function getUserHoldPercent(address userAddress)
        external
        view
        returns (uint256)
    {
        if (isActive(userAddress)) {
            User storage user = _users[userAddress];
            uint256 timeMultiplier = (block.timestamp.sub(user.checkpoint)).div(
                TIME_STEP
            );
            return timeMultiplier;
        } else {
            return 0;
        }
    }

    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalance = token.balanceOf(address(this));
        uint256 contractBalancePercent = contractBalance.div(
            CONTRACT_BALANCE_STEP
        );

        return BASE_PERCENT.add(contractBalancePercent);
    }

    function getUserPercentRate(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = _users[userAddress];
        uint256 contractBalanceRate = getContractBalanceRate();

        if (isActive(userAddress)) {
            uint256 timeMultiplier = (block.timestamp.sub(user.checkpoint)).div(
                TIME_STEP
            );
            return contractBalanceRate.add(timeMultiplier);
        } else {
            return contractBalanceRate;
        }
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = _users[userAddress];

        uint256 dividends;
        uint256 totalDividends;
        uint256 userPercentRate = getUserPercentRate(userAddress);

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(userPercentRate).div(
                            PERCENTS_DIVIDER
                        )
                    ).mul(block.timestamp.sub(user.deposits[i].start)).div(
                            TIME_STEP
                        );
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(userPercentRate).div(
                            PERCENTS_DIVIDER
                        )
                    ).mul(block.timestamp.sub(user.checkpoint)).div(TIME_STEP);
                }

                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(2)
                ) {
                    dividends = (user.deposits[i].amount.mul(2)).sub(
                        user.deposits[i].withdrawn
                    );
                }

                totalDividends = totalDividends.add(dividends);
            }
        }

        return totalDividends;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return _users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return _users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return _users[userAddress].bonus;
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

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        User storage user = _users[userAddress];

        return (
            user.deposits[index].amount,
            user.deposits[index].withdrawn,
            user.deposits[index].start
        );
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return _users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = _users[userAddress];
        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = _users[userAddress];
        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].withdrawn);
        }

        return amount;
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = _users[userAddress];

        if (user.deposits.length > 0) {
            if (
                user.deposits[user.deposits.length - 1].withdrawn <
                user.deposits[user.deposits.length - 1].amount.mul(2)
            ) {
                return true;
            }
        }
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