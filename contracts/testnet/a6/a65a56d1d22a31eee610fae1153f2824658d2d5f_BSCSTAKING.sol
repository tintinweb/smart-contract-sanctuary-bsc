/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

contract BSCSTAKING {
    IBEP20 public token;
    address public owner;
    uint256[5] public referralPercentages = [4_00, 3_00, 2_00, 1_00, 50];

    uint256[5] public percentPerInterval = [5_00, 5_20, 5_50, 1_50, 2_50];
    uint256[5] public stakingPeriods = [
        24 minutes,
        24 minutes,
        24 minutes,
        170 minutes,
        120 minutes
    ];
    uint256[5] public stakingIntervalLimits = [
        1 minutes,
        1 minutes,
        1 minutes,
        2 minutes,
        2 minutes
    ];

    uint256[5] public minDepositAmounts = [
        20 ,
        100 ,
        1000 ,
        5000 ,
        50000 
    ];

    uint256[5] public maxDepositAmounts = [
        100 ,
        1000 ,
        5000 ,
        50000 ,
        300000 
    ];

    uint256 percentDivider = 100_00;
    uint256 public baseWithdrawInterval = 1 minutes;
    uint256 public totalWithdraw;
    uint256 public totalStaked;
    uint256 public totalUsers;

    mapping(address => bool) public blackListed;
    bool public stopParticipation;

    struct userStakeData {
        uint256 amount;
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 startTime;
        uint256 endTime;
        uint256 lastWithdrawTime;
        uint256 plan;
        uint256 percentPerInterval;
        uint256 intervalLimit;
        uint256 intervalTime;
        bool isActive;
    }

    struct User {
        bool isExists;
        address direct;
        userStakeData[] stakes;
        uint256 totalStaked;
        uint256 totalWithdrawn;
        uint256[5] referalAmounts;
        uint256[5] referalCounts;
        uint256 stakingCount;
        uint256 teamTurnOver;
    }
    struct Deposit {
        address _user;
        uint depositAmount;
        uint depositTime;
    }
    struct Withdraw {
        address _user;
        uint withdrawAmount;
        uint withdrawTime;
    }

    mapping(address => User) public users;
    mapping(uint256 => Deposit) public depositHistory;
    mapping(uint256 => Withdraw) public withdawHistory;

    uint256 public depositCount;
    uint256 public withdrawCount;

    constructor(IBEP20 _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not Owner");
        _;
    }

    function stake(
        uint256 _amount,
        address _referrer,
        uint256 _plan
    ) external returns (bool) {
        User storage user = users[msg.sender];
        if (!user.isExists) {
            require(
                !stopParticipation,
                "New Paricipation has been stopped by Owner"
            );
        }

        require(msg.sender != _referrer, "You cannot reffer yourself!");
        require(
            !blackListed[msg.sender],
            "Cannot Stake Funds! You are blacklisted !"
        );

        require(_plan < stakingPeriods.length, "Invalid Plan!");

        uint decimals = 10**token.decimals();

        require(
            _amount >= minDepositAmounts[_plan] * decimals,
            "You cannot stake less than minimum amount of this plan "
        );
        require(
            _amount <= maxDepositAmounts[_plan] * decimals,
            "You cannot stake greater than max amount of this plan "
        );

        if (msg.sender == owner) {
            user.direct = address(0);
        }
        if (_referrer == address(0)) {
            user.direct = owner;
        }
        if (!users[_referrer].isExists && msg.sender != owner) {
            user.direct = owner;
        }
        if (
            user.direct == address(0) &&
            msg.sender != owner &&
            users[_referrer].isExists
        ) {
            user.direct = _referrer;
            setRefferalChain(_referrer);
        }

        token.transferFrom(msg.sender, address(this), _amount);

        if (!user.isExists) {
            totalUsers++;
            user.isExists = true;
            distributeReferalRewardAmount(_amount);
        }

        uint256 rewardAmount = (_amount *
            percentPerInterval[_plan] *
            (stakingPeriods[_plan] / baseWithdrawInterval)) / percentDivider;

        user.stakes.push(
            userStakeData(
                _amount,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + stakingPeriods[_plan],
                block.timestamp,
                _plan,
                percentPerInterval[_plan],
                stakingIntervalLimits[_plan],
                baseWithdrawInterval,
                true
            )
        );

        depositHistory[depositCount] =  Deposit(
        msg.sender,
        _amount,
        block.timestamp
        );

        depositCount++;
        user.totalStaked += _amount;
        user.stakingCount++;
        totalStaked += _amount;
        return true;
    }

    function withdraw(uint256 _index) public {
        User storage user = users[msg.sender];

        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");
        require(
            block.timestamp - user.stakes[_index].lastWithdrawTime >=
                user.stakes[_index].intervalLimit,
            "You cannot withdaw right now. wait for turn!"
        );
        require(
            !blackListed[msg.sender],
            "Cannot withdraw Funds! You are blacklisted !"
        );

        uint256 duration = (block.timestamp -
            user.stakes[_index].lastWithdrawTime) /
            user.stakes[_index].intervalTime;
        uint256 currentDividend = (user.stakes[_index].amount *
            user.stakes[_index].percentPerInterval *
            duration) / percentDivider;

        if (currentDividend >= user.stakes[_index].remainingAmount) {
            currentDividend = user.stakes[_index].remainingAmount;
            user.stakes[_index].isActive = false;
        }

        token.transfer(msg.sender, currentDividend);

        if (block.timestamp >= user.stakes[_index].endTime) {
            user.stakes[_index].lastWithdrawTime = user.stakes[_index].endTime;
        } else {
            user.stakes[_index].lastWithdrawTime += (duration *
                user.stakes[_index].intervalTime);
        }

        withdawHistory[withdrawCount] =  Withdraw(
        msg.sender,
        currentDividend,
        block.timestamp
        );

        withdrawCount++;

        user.stakes[_index].remainingAmount -= currentDividend;
        user.totalWithdrawn += currentDividend;
        totalWithdraw += currentDividend;
    }

    function reinvest(uint256 _index, uint256 _plan) public {
        User storage user = users[msg.sender];
        require(_index < user.stakes.length, "Invalid Index");
        require(_plan < stakingPeriods.length, "Invalid Plan");
        require(user.stakes[_index].isActive, "Stake is not Active");
        require(
            !blackListed[msg.sender],
            "Cannot reinvest Funds! You are blacklisted !"
        );

        require(
            block.timestamp - user.stakes[_index].lastWithdrawTime >=
                user.stakes[_index].intervalLimit,
            "You cannot restake right now. wait for turn!"
        );

        uint256 duration = (block.timestamp -
            user.stakes[_index].lastWithdrawTime) /
            user.stakes[_index].intervalTime;

        uint256 currentDividend = ((user.stakes[_index].amount *
            user.stakes[_index].percentPerInterval) * duration) /
            percentDivider;

        if (currentDividend >= user.stakes[_index].remainingAmount) {
            currentDividend = user.stakes[_index].remainingAmount;
            user.stakes[_index].isActive = false;
        }

        uint decimals = 10**token.decimals();
        require(
            currentDividend >= minDepositAmounts[_plan] * decimals,
            "You cannot stake less than minimum amount of this plan "
        );
        require(
            currentDividend <= maxDepositAmounts[_plan] * decimals,
            "You cannot stake greater than max amount of this plan "
        );

        uint256 rewardAmount = (currentDividend *
            percentPerInterval[_plan] *
            (stakingPeriods[_plan] / baseWithdrawInterval)) / percentDivider;

        user.stakes[_index].remainingAmount -= currentDividend;

        user.stakes[_index].lastWithdrawTime += (duration *
            user.stakes[_index].intervalTime);

        user.stakes.push(
            userStakeData(
                currentDividend,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + stakingPeriods[user.stakes[_index].plan],
                block.timestamp,
                _plan,
                percentPerInterval[_plan],
                stakingIntervalLimits[_plan],
                baseWithdrawInterval,
                true
            )
        );

        depositHistory[depositCount] =  Deposit(
        msg.sender,
        currentDividend,
        block.timestamp
        );

        depositCount++;

        user.totalWithdrawn += currentDividend;
        user.totalStaked += currentDividend;
        user.stakingCount++;
        totalStaked += currentDividend;
        totalWithdraw += currentDividend;
    }

    function setRefferalChain(address _referrer) internal {
        address referal = _referrer;

        for (uint256 i; i < referralPercentages.length; i++) {
            User storage user = users[referal];
            if (referal == address(0)) {
                break;
            }
            user.referalCounts[i]++;
            referal = users[referal].direct;
        }
    }

    function distributeReferalRewardAmount(uint256 _amount) internal {
        address referal = users[msg.sender].direct;

        for (uint256 i; i < referralPercentages.length; i++) {
            if (referal == address(0)) {
                break;
            }

            User storage user = users[referal];

            user.teamTurnOver += _amount;

            user.referalAmounts[i] +=
                (_amount * referralPercentages[i]) /
                percentDivider;
            token.transfer(
                referal,
                (_amount * referralPercentages[i]) / percentDivider
            );

            referal = users[referal].direct;
        }
    }

    function getCurrentClaimableAmount(address _user, uint256 _index)
        external
        view
        returns (uint256 withdrawableAmount)
    {
        User storage user = users[_user];

        uint256 duration = (block.timestamp -
            user.stakes[_index].lastWithdrawTime) /
            user.stakes[_index].intervalTime;

        withdrawableAmount =
            (user.stakes[_index].amount *
                user.stakes[_index].percentPerInterval *
                duration) /
            percentDivider;

        if (withdrawableAmount >= user.stakes[_index].remainingAmount) {
            withdrawableAmount = user.stakes[_index].remainingAmount;
        }

        return withdrawableAmount;
    }

    function viewStaking(uint256 _index, address _user)
        public
        view
        returns (
            uint256 amount,
            uint256 totalAmount,
            uint256 remainingAmount,
            uint256 startTime,
            uint256 lastWithdrawTime,
            uint256 plan,
            uint256 percentPerIntervall,
            uint256 intervalLimit,
            uint256 intervalTime,
            bool isActive
        )
    {
        User storage user = users[_user];
        amount = user.stakes[_index].amount;
        totalAmount = user.stakes[_index].totalAmount;
        remainingAmount = user.stakes[_index].remainingAmount;
        startTime = user.stakes[_index].startTime;
        lastWithdrawTime = user.stakes[_index].lastWithdrawTime;
        plan = user.stakes[_index].plan;
        percentPerIntervall = user.stakes[_index].percentPerInterval;
        intervalLimit = user.stakes[_index].intervalLimit;
        intervalTime = user.stakes[_index].intervalTime;
        isActive = user.stakes[_index].isActive;
    }

    function calculatePlanReward(uint256 _amount, uint256 _plan)
        external
        view
        returns (uint256)
    {

       uint256 rewardAmount = (_amount *
            percentPerInterval[_plan] *
            (stakingPeriods[_plan] / baseWithdrawInterval)) / percentDivider;
        return rewardAmount;
    }
    


    function changeToken(IBEP20 _token) external onlyOwner returns (bool) {
        token = _token;
        return true;
    }

    function changeIntervalLimit(uint256 _limit) external onlyOwner {
        baseWithdrawInterval = _limit;
    }

    function changePlan(
        uint256 _plan,
        uint256 _percentPerInterval,
        uint256 _withdrawIntervalTime,
        uint256 _totalStakingPeriod,
        uint256 _minDepositAmount,
        uint256 _maxDepositAmount
    ) external onlyOwner returns (bool) {
        require(_plan < stakingPeriods.length, "Invalid Plan");
        percentPerInterval[_plan] = _percentPerInterval;
        stakingPeriods[_plan] = _totalStakingPeriod;
        stakingIntervalLimits[_plan] = _withdrawIntervalTime;
        minDepositAmounts[_plan] = _minDepositAmount;
        maxDepositAmounts[_plan] = _maxDepositAmount;
        return true;
    }

    function changeReferalRewardPercentage(
        uint256[5] memory _referralPercentages
    ) external onlyOwner {
        referralPercentages = _referralPercentages;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function withdrawTokens(uint256 _amount, IBEP20 _token) external onlyOwner {
        _token.transfer(owner, _amount);
    }

    function withdrawBNB() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function banOrUnbanWallets(address _user, bool _ban) external onlyOwner {
        blackListed[_user] = _ban;
    }

    function enableOrDisableNewParticipations(bool _disable)
        external
        onlyOwner
    {
        stopParticipation = _disable;
    }

    function changePercentDivider(uint256 _percentDivider) external onlyOwner {
        percentDivider = _percentDivider;
    }
}