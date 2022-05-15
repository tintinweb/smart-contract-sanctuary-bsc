/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 invested)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 invested) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 invested
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PearlFaucetPoolContract {
    using SafeMath for uint256;
    AggregatorV3Interface public priceFeedbnb;

    address public owner;
    IBEP20 public token;

    uint256 public minInvest = 1 ether;
    uint256 public dailyPercent = 6;
    uint256 public maxPercent = 3650;
    uint256 public refPercent = 100;
    uint256[6] public limits = [1e18, 100e18, 1000e18, 2000e18, 30000e18, 4000e18];

    uint256 public slippage = 100;
    uint256 public constant percentDivider = 1000;
    uint256 public timeStep = 1 days;
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalNumberOfDeposits;
    uint256 public totalReinvested;

    struct Deposit {
        uint256 invested;
        uint256 withdrawn;
        uint256 startTime;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 activeBonus;
        uint256 withdrawnBonus;
        uint256 reinvested;
        uint256[6] downline;
        uint256[6] downlineIncome;
    }

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => bool)) public uplineInitialize;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 invested);
    event Withdrawn(address indexed user, uint256 invested);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 invested
    );
    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner, IBEP20 _token) {
        owner = _owner;
        token = IBEP20(_token);
        priceFeedbnb = AggregatorV3Interface(
           // 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
           0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
    }

    function invest(uint256 _tokenAmount) public {
        require(_tokenAmount >= minInvest, "amount is less than min amount");
        User storage user = users[msg.sender];
        require(user.referrer != address(0), "don't have referrer");

        token.transferFrom(msg.sender, address(this), _tokenAmount);
        _tokenAmount = _tokenAmount.sub(
            _tokenAmount.mul(slippage).div(percentDivider)
        );

        address upline = user.referrer;
        for (uint256 i = 0; i < limits.length; i++) {
            if (upline != address(0)) {
                uint256 refBonusAmount = 0;
                if (getUserAmountOfDeposit(upline) >= limits[i]) {
                    refBonusAmount = _tokenAmount.mul(refPercent).div(
                        percentDivider
                    );
                    users[upline].activeBonus = users[upline].activeBonus.add(
                        refBonusAmount
                    );
                    users[upline].downlineIncome[i] = users[upline]
                        .downlineIncome[i]
                        .add(refBonusAmount);
                    if (!uplineInitialize[msg.sender][i]) {
                        users[upline].downline[i]++;
                        uplineInitialize[msg.sender][i] = true;
                    }
                }

                emit RefBonus(upline, msg.sender, i, refBonusAmount);

                upline = users[upline].referrer;
            } else break;
        }

        if (user.deposits.length == 0) {
            totalUsers = totalUsers.add(1);
        }

        user.deposits.push(Deposit(_tokenAmount, 0, block.timestamp));
        totalInvested = totalInvested.add(_tokenAmount);
        totalNumberOfDeposits = totalNumberOfDeposits.add(1);

        emit NewDeposit(msg.sender, _tokenAmount);
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 base = dailyPercent;
        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].invested.mul(maxPercent).div(percentDivider)
            ) {
                dividends = (
                    user.deposits[i].invested.mul(base).div(percentDivider)
                ).mul(block.timestamp.sub(user.deposits[i].startTime)).div(
                        timeStep
                    );
                user.deposits[i].startTime = block.timestamp;
                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].invested.mul(maxPercent).div(
                        percentDivider
                    )
                ) {
                    dividends = (
                        user.deposits[i].invested.mul(maxPercent).div(
                            percentDivider
                        )
                    ).sub(user.deposits[i].withdrawn);
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(
                    dividends
                ); /// changing of storage data
                totalAmount = totalAmount.add(dividends);
            }
        }
        uint256 referralBonus = getUserActiveReferralBonus(msg.sender);
        if (referralBonus > 0) {
            totalAmount = totalAmount.add(referralBonus);
            users[msg.sender].withdrawnBonus = users[msg.sender]
                .withdrawnBonus
                .add(referralBonus);
            users[msg.sender].activeBonus = 0;
        }
        totalAmount = totalAmount.sub(
            totalAmount.mul(slippage).div(percentDivider)
        );
        uint256 contractBalance = getContractTokenBalance();
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        user.checkpoint = block.timestamp;
        token.transfer(msg.sender, totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function reinvest(uint256 _value) internal {
        uint256 referralBonus = getUserActiveReferralBonus(msg.sender);
        if (referralBonus > 0) {
            _value = _value.add(referralBonus);
            users[msg.sender].withdrawnBonus = users[msg.sender]
                .withdrawnBonus
                .add(referralBonus);
            users[msg.sender].activeBonus = 0;
        }

        User storage user = users[msg.sender];
        user.deposits.push(Deposit(_value, 0, block.timestamp));
        user.reinvested = user.reinvested.add(_value);
        totalInvested = totalInvested.add(_value);
        totalNumberOfDeposits = totalNumberOfDeposits.add(1);
        totalReinvested = totalReinvested.add(_value);
        emit NewDeposit(msg.sender, _value);
    }

    function reinvestStake() public returns (bool) {
        User storage user = users[msg.sender];
        uint256 base = dailyPercent;
        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].invested.mul(maxPercent).div(100)
            ) {
                dividends = (
                    user.deposits[i].invested.mul(base).div(percentDivider)
                ).mul(block.timestamp.sub(user.deposits[i].startTime)).div(
                        timeStep
                    );

                user.deposits[i].startTime = block.timestamp;

                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].invested.mul(maxPercent).div(
                        percentDivider
                    )
                ) {
                    dividends = (
                        user.deposits[i].invested.mul(maxPercent).div(
                            percentDivider
                        )
                    ).sub(user.deposits[i].withdrawn);
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(
                    dividends
                ); /// changing of storage data
                totalAmount = totalAmount.add(dividends);
            }
        }

        uint256 contractBalance = getContractTokenBalance();

        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        totalAmount = totalAmount.sub(
            totalAmount.mul(slippage.div(2)).div(percentDivider)
        );
        reinvest(totalAmount);

        return true;
    }

    function getUserDividendsWithdrawable(address userAddress)
        public
        view
        returns (uint256 _totalDividends)
    {
        User storage user = users[userAddress];
        uint256 base = dailyPercent;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].invested.mul(maxPercent).div(percentDivider)
            ) {
                dividends = (
                    user.deposits[i].invested.mul(base).div(percentDivider)
                ).mul(block.timestamp.sub(user.deposits[i].startTime)).div(
                        timeStep
                    );
                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].invested.mul(maxPercent).div(
                        percentDivider
                    )
                ) {
                    dividends = (
                        user.deposits[i].invested.mul(maxPercent).div(
                            percentDivider
                        )
                    ).sub(user.deposits[i].withdrawn);
                }

                _totalDividends = _totalDividends.add(dividends);
            }
        }
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address _referrer)
    {
        _referrer = users[userAddress].referrer;
    }

    function getUserDownlineIncome(address userAddress)
        public
        view
        returns (
            uint256 level1,
            uint256 level2,
            uint256 level3,
            uint256 level4,
            uint256 level5,
            uint256 level6
        )
    {
        level1 = users[userAddress].downlineIncome[0];
        level2 = users[userAddress].downlineIncome[1];
        level3 = users[userAddress].downlineIncome[2];
        level4 = users[userAddress].downlineIncome[3];
        level5 = users[userAddress].downlineIncome[4];
        level6 = users[userAddress].downlineIncome[5];
    }

    function getUserActiveReferralBonus(address userAddress)
        public
        view
        returns (uint256 _amount)
    {
        _amount = users[userAddress].activeBonus;
    }

    function getUserReferralBonusWithdrawn(address userAddress)
        public
        view
        returns (uint256 _amount)
    {
        _amount = users[userAddress].withdrawnBonus;
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint256 _invested,
            uint256 _withdrawn,
            uint256 _startTime
        )
    {
        User storage user = users[userAddress];

        _invested = user.deposits[index].invested;
        _withdrawn = user.deposits[index].withdrawn;
        _startTime = user.deposits[index].startTime;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (
            uint256 _downline1,
            uint256 _downline2,
            uint256 _downline3,
            uint256 _downline4,
            uint256 _downline5,
            uint256 _downline6
        )
    {
        _downline1 = users[userAddress].downline[0];
        _downline2 = users[userAddress].downline[1];
        _downline3 = users[userAddress].downline[2];
        _downline4 = users[userAddress].downline[3];
        _downline5 = users[userAddress].downline[4];
        _downline6 = users[userAddress].downline[5];
    }

    function getUserNumberOfDeposits(address userAddress)
        public
        view
        returns (uint256 _depositsCount)
    {
        _depositsCount = users[userAddress].deposits.length;
    }

    function getUserAmountOfDeposit(address userAddress)
        public
        view
        returns (uint256 _amount)
    {
        User storage user = users[userAddress];

        for (uint256 i = 0; i < user.deposits.length; i++) {
            _amount = _amount.add(user.deposits[i].invested);
        }
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256 _amount)
    {
        User storage user = users[userAddress];

        for (uint256 i = 0; i < user.deposits.length; i++) {
            _amount = _amount.add(user.deposits[i].withdrawn);
        }
    }

    function getUserTotalReinvested(address userAddress)
        public
        view
        returns (uint256 _amount)
    {
        _amount = users[userAddress].reinvested;
    }

    function isActive(address userAddress, uint256 index)
        public
        view
        returns (bool _state)
    {
        User storage user = users[userAddress];

        if (user.deposits.length > 0) {
            if (
                user.deposits[index].withdrawn <
                user.deposits[index].invested.mul(maxPercent).div(
                    percentDivider
                )
            ) {
                _state = true;
            } else {
                _state = false;
            }
        }
    }

    function getContractBalance() public view returns (uint256 _tokenBalance) {
        _tokenBalance = address(this).balance;
    }

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price).div(1e8);
    }

    function setSlippage(uint256 _percent) external {
        require(msg.sender == owner, "not an owner");
        slippage = _percent;
    }

    function getContractTokenBalance()
        public
        view
        returns (uint256 _bnbBalance)
    {
        _bnbBalance = token.balanceOf(address(this));
    }

    function removeStuckBnb() public {
        payable(owner).transfer(getContractBalance());
    }

    function updateRefPercent(uint256 percent) public onlyowner {
        refPercent = percent;
    }

    function updateLimits(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f
    ) public onlyowner {
        limits[0] = a;
        limits[1] = b;
        limits[2] = c;
        limits[3] = d;
        limits[4] = e;
        limits[5] = f;
    }

    function updateMinInvest(uint256 _amount) public onlyowner {
        minInvest = _amount;
    }

    function updateDailyPercent(uint256 _percent) public onlyowner {
        dailyPercent = _percent;
    }

    function updateMaxPercent(uint256 _percent) public onlyowner {
        maxPercent = _percent;
    }

    function updateOwner(address _owner) public onlyowner {
        owner = _owner;
    }

    function updateToken(IBEP20 _token) public onlyowner {
        token = _token;
    }

    function setTime(uint256 _duration) public onlyowner {
        timeStep = _duration;
    }

    function lastActivity(address _user) public view returns (uint256 _time) {
        if (users[_user].deposits.length != 0) {
            uint256 index = users[_user].deposits.length.sub(1);
            _time = users[_user].deposits[index].startTime;
        } else _time = 0;
    }

    function updateReferrer(address _newReferrer) public {
        require(_newReferrer != msg.sender, "can't refer yourself");
        require(
            users[msg.sender].referrer == address(0),
            "already have referrer"
        );
        users[msg.sender].referrer = _newReferrer;
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