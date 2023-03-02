/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-16
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
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
    IERC20 public token;
    address public owner;
    uint256 public aprPlanPercentage = 24*1e13;
    uint256 public lockedPercentage = 48 * 1e13;
    uint256 public stakingPeriod = 365 days;
    uint256 public lockDuration = 365 days;
    uint256 public minDepositAmount = 100;
    uint256 public percentPerIntervalFlexible = 7610350;
    uint256 public percentPerIntervalLocked = 15220700;
    uint256 public penaltyPercent = 20 * 1e13;
    uint256 public percentDivider = 100 * 1e13;
    uint256 public baseWithdrawInterval = 1 days;
    uint256 public totalWithdraw;
    uint256 public totalStaked;
    uint256 public totalUsers;

    struct userStakeData {
        uint256 amount;
        uint256 totalAprAmount;
        uint256 claimedAprAmount;
        uint256 remainingAprAmount;
        uint256 startTime;
        uint256 lastWithdrawTime;
        bool isActive;
        bool locked;
    }

    struct User {
        bool isExists;
        userStakeData[] stakes;
        uint256 totalStaked;
        uint256 totalWithdrawn;
        uint256 stakingCount;
    }

    mapping(address => User) public users;

    constructor() {
        token = IERC20(0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not Owner");
        _;
    }

    function stake(uint256 _amount, bool _locked) external returns (bool) {
        User storage user = users[msg.sender];
        uint256 fractions = 10**token.decimals();
        require(
            _amount >= minDepositAmount * fractions,
            "You cannot stake less than minimum amount of this plan "
        );

        token.transferFrom(msg.sender, address(this), _amount);

        if (!user.isExists) {
            totalUsers++;
            user.isExists = true;
        }

        uint256 rewardAmount;
        if (_locked) {
            rewardAmount = (_amount * lockedPercentage) / percentDivider;
        } else {
            rewardAmount = (_amount * aprPlanPercentage) / percentDivider;
        }

        user.stakes.push(
            userStakeData(
                _amount,
                rewardAmount,
                0,
                rewardAmount,
                block.timestamp,
                block.timestamp,
                true,
                _locked
            )
        );

        user.totalStaked += _amount;
        user.stakingCount++;
        totalStaked += _amount;
        return true;
    }

    function claimApr(uint256 _index) external returns (bool) {
        User storage user = users[msg.sender];

        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");
        require(
            block.timestamp - user.stakes[_index].lastWithdrawTime >
                baseWithdrawInterval,
            "Time is not enough to claim"
        );

        uint256 currentDivident = ((user.stakes[_index].amount *
            (block.timestamp - user.stakes[_index].lastWithdrawTime) *
            (
                (user.stakes[_index].locked)
                    ? percentPerIntervalLocked
                    : percentPerIntervalFlexible
            )) / percentDivider);

        if (currentDivident >= user.stakes[_index].remainingAprAmount) {
            currentDivident = user.stakes[_index].remainingAprAmount;
            user.stakes[_index].isActive = false;
        }

        token.transfer(msg.sender, currentDivident);

        user.stakes[_index].lastWithdrawTime = block.timestamp;
        user.stakes[_index].claimedAprAmount += currentDivident;
        user.stakes[_index].remainingAprAmount -= currentDivident;
        user.totalWithdrawn += currentDivident;
        totalWithdraw += currentDivident;
        return true;
    }

    function unstake(uint256 _index) external {
        User storage user = users[msg.sender];

        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");

        uint256 currentDivident;
        (user.stakes[_index].locked &&
            block.timestamp < user.stakes[_index].startTime + lockDuration)
            ? (currentDivident =
                user.stakes[_index].amount -
                ((user.stakes[_index].amount * penaltyPercent) / percentDivider))
            : (currentDivident = user.stakes[_index].amount);

        token.transfer(msg.sender, currentDivident);
        user.stakes[_index].isActive = false;
        user.stakes[_index].remainingAprAmount = 0;
        totalWithdraw += currentDivident;
    }

    function getCurrentClaimableAmount(address _user, uint256 _index)
        external
        view
        returns (uint256 withdrawableAmount)
    {
        User storage user = users[_user];

        withdrawableAmount = (user.stakes[_index].amount *
            (block.timestamp - user.stakes[_index].lastWithdrawTime) *
            (
                (user.stakes[_index].locked)
                    ? percentPerIntervalLocked
                    : percentPerIntervalFlexible)
            ) / percentDivider;

        return (
            (withdrawableAmount > user.stakes[_index].remainingAprAmount)
                ? user.stakes[_index].remainingAprAmount
                : withdrawableAmount
        );
    }

    function viewStaking(uint256 _index, address _user)
        public
        view
        returns (
            uint256 amount,
            uint256 totalAprAmount,
            uint256 claimedAprAmount,
            uint256 remainingAprAmount,
            uint256 startTime,
            uint256 lastWithdrawTime,
            bool isActive,
            bool locked
        )
    {
        User storage user = users[_user];
        amount = user.stakes[_index].amount;
        totalAprAmount = user.stakes[_index].totalAprAmount;
        claimedAprAmount = user.stakes[_index].claimedAprAmount;
        remainingAprAmount = user.stakes[_index].remainingAprAmount;
        startTime = user.stakes[_index].startTime;
        lastWithdrawTime = user.stakes[_index].lastWithdrawTime;
        isActive = user.stakes[_index].isActive;
        locked = user.stakes[_index].locked;
    }

    function changeToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function changeIntervalLimit(uint256 _limit) external onlyOwner {
        baseWithdrawInterval = _limit;
    }

    function changePlan(
        uint256 _totalAprPercent,
        uint256 _percentPerIntervalFlexible,
        uint256 _percentPerIntervalLocked,
        uint256 _totalStakingPeriod,
        uint256 _minDepositAmount
    ) external onlyOwner {
        aprPlanPercentage = _totalAprPercent;
        percentPerIntervalFlexible = _percentPerIntervalFlexible;
        percentPerIntervalLocked = _percentPerIntervalLocked;
        stakingPeriod = _totalStakingPeriod;
        minDepositAmount = _minDepositAmount;
    }

    function changeLockCrieteria(uint256 _duration, uint256 _percent)
        external
        onlyOwner
    {
        lockDuration = _duration;
        lockedPercentage = _percent;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function withdrawTokens(uint256 _amount, IERC20 _token) external onlyOwner {
        _token.transfer(owner, _amount);
    }

    function withdrawBNB() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function changePercentDivider(uint256 _percentDivider) external onlyOwner {
        percentDivider = _percentDivider;
    }
}