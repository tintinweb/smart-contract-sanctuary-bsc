/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

contract UltraRichStaking is Ownable {
    IBEP20 public token;
    uint256 public rewardPercentage = 180_00;
    uint256[3] public referralPercentages = [8_00, 2_00, 2_00];
    uint256 public devWalletFee = 5_00;
    uint256 public projectWalletFee = 2_00;
    uint256 public percentDivider = 100_00;
    uint256 public stakingTime = 18 minutes;
    uint256 public withdrawLimitTime = 3 minutes;
    uint256 public aprPercent = 30_00;
    uint256 public totalWithdraw;
    uint256 public totalStaked;
    uint256 public totalUsers;
    uint256 public referrerLevelCounter = 10;

    address public devWallet = 0xf638B71a52f8e2edFDdb8824F1e09AAb0b6cD695;
    address public projectWallet = 0xf638B71a52f8e2edFDdb8824F1e09AAb0b6cD695;

    struct userStakeData {
        uint256 amount;
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 startTime;
        uint256 endTime;
        uint256 lastWithdrawTime;
        bool isActive;
    }

    struct User {
        bool isExists;
        address direct;
        userStakeData[] stakes;
        uint256 totalStaked;
        uint256 totalWithdrawn;
        uint256[3] referrerAmounts;
        uint256[3] referrerAmountsPending;
        uint256[3] referrerAmountsWithDrawn;
        uint256[100] referrerCounts;
        uint256 stakingCount;
        uint256 teamTurnOver;
    }

    mapping(address => User) public users;

    constructor(IBEP20 _token) {
        token = _token;
    }

    function stake(uint256 _amount, address _referrer) external returns (bool) {
        User storage user = users[msg.sender];
        require(msg.sender != _referrer, "You cannot reffer yourself!");

        if (msg.sender == owner()) {
            user.direct = address(0);
        }
        if (_referrer == address(0)) {
            user.direct = owner();
        }
        if (!users[_referrer].isExists && msg.sender != owner()) {
            user.direct = owner();
        }
        if (
            user.direct == address(0) &&
            msg.sender != owner() &&
            users[_referrer].isExists
        ) {
            user.direct = _referrer;
        }
        if (!user.isExists) {
            setRefferalChain(user.direct);
            totalUsers++;
            user.isExists = true;
        }

        token.transferFrom(msg.sender, address(this), _amount);
        uint256 rewardAmount = (_amount * rewardPercentage) / percentDivider;

        user.stakes.push(
            userStakeData(
                _amount,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + stakingTime,
                block.timestamp,
                true
            )
        );

        user.totalStaked += _amount;
        user.stakingCount++;
        totalStaked += _amount;
        distributeStakingRewards(_amount);
        return true;
    }

    function withdraw(uint256 _index) external returns (bool) {
        User storage user = users[msg.sender];

        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");
        require(
            block.timestamp - user.stakes[_index].lastWithdrawTime >=
                withdrawLimitTime,
            "You cannot withdaw right now. wait for turn!"
        );
        uint256 slots = (block.timestamp -
            user.stakes[_index].lastWithdrawTime) / withdrawLimitTime;
        uint256 currentDivident = ((user.stakes[_index].amount * aprPercent) /
            percentDivider) * slots;

        if (currentDivident >= user.stakes[_index].remainingAmount) {
            currentDivident = user.stakes[_index].remainingAmount;
        }
        uint256 devWalletAmount = (currentDivident * devWalletFee) /
            percentDivider;
        uint256 projectWalletAmount = (currentDivident * projectWalletFee) /
            percentDivider;

        uint256 amountToSend = currentDivident - devWalletAmount;

        token.transfer(msg.sender, amountToSend);
        token.transfer(devWallet, devWalletAmount);
        token.transfer(projectWallet, projectWalletAmount);

        if (block.timestamp >= user.stakes[_index].endTime) {
            user.stakes[_index].lastWithdrawTime = user.stakes[_index].endTime;
        } else {
            user.stakes[_index].lastWithdrawTime += (slots * withdrawLimitTime);
        }

        user.stakes[_index].remainingAmount -= currentDivident;
        user.totalWithdrawn += currentDivident;
        totalWithdraw += currentDivident;

        if (user.stakes[_index].remainingAmount == 0) {
            user.stakes[_index].isActive = false;
        }

        return true;
    }

    function compound(uint256 _index) external returns (bool) {
        User storage user = users[msg.sender];
        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");
        uint256 percentage = (((block.timestamp -
            user.stakes[_index].lastWithdrawTime) * percentDivider) /
            stakingTime);
        uint256 currentDivident = ((user.stakes[_index].totalAmount *
            percentage) / percentDivider);

        if (currentDivident >= user.stakes[_index].remainingAmount) {
            currentDivident = user.stakes[_index].remainingAmount;
        }

        uint256 rewardAmount = (currentDivident * rewardPercentage) /
            percentDivider;
        user.stakes[_index].remainingAmount -= currentDivident;

        if (block.timestamp >= user.stakes[_index].endTime) {
            user.stakes[_index].lastWithdrawTime = user.stakes[_index].endTime;
        } else {
            user.stakes[_index].lastWithdrawTime = block.timestamp;
        }

        if (user.stakes[_index].remainingAmount == 0) {
            user.stakes[_index].isActive = false;
        }

        user.stakes.push(
            userStakeData(
                currentDivident,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + stakingTime,
                block.timestamp,
                true
            )
        );

        user.totalWithdrawn += currentDivident;
        user.totalStaked += currentDivident;
        user.stakingCount++;
        totalStaked += currentDivident;
        totalWithdraw += currentDivident;
        return true;
    }

    function setRefferalChain(address _referrer) internal {
        address referrer = _referrer;

        for (uint256 i; i < referrerLevelCounter; i++) {
            User storage user = users[referrer];
            if (referrer == address(0)) {
                break;
            }
            user.referrerCounts[i]++;
            referrer = users[referrer].direct;
        }
    }

    function distributeStakingRewards(uint256 _amount) internal {
        token.transfer(devWallet, (_amount * devWalletFee) / percentDivider);

        address referrer = users[msg.sender].direct;

        for (uint256 i; i < referrerLevelCounter; i++) {
            if (referrer == address(0)) {
                break;
            }

            User storage user = users[referrer];

            user.teamTurnOver += _amount;
            if (i < 3) {
                user.referrerAmounts[i] +=
                    (_amount * referralPercentages[i]) /
                    percentDivider;

                user.referrerAmountsPending[i] +=
                    (_amount * referralPercentages[i]) /
                    percentDivider;
            }

            referrer = users[referrer].direct;
        }
    }

    function claimreferrerReward() external {
        uint256 totalAmount;
        User storage user = users[msg.sender];

        for (uint256 i; i < referralPercentages.length; i++) {
            totalAmount += user.referrerAmountsPending[i];
            user.referrerAmountsWithDrawn[i] += user.referrerAmountsPending[i];
            user.referrerAmountsPending[i] = 0;
        }

        require(
            totalAmount > 0,
            "You don't have Pending referrer Reward Amount"
        );
        token.transfer(msg.sender, totalAmount);
    }

    function referralCounts(address _user, uint256 _index)
        external
        view
        returns (uint256)
    {
        User storage user = users[_user];
        return user.referrerCounts[_index];
    }

    function referralRewardPending(address _user)
        external
        view
        returns (uint256[3] memory)
    {
        User storage user = users[_user];
        return user.referrerAmountsPending;
    }

    function referralRewardAmounts(address _user)
        external
        view
        returns (uint256[3] memory)
    {
        User storage user = users[_user];
        return user.referrerAmounts;
    }

    function referralRewardWithdrawn(address _user)
        external
        view
        returns (uint256[3] memory)
    {
        User storage user = users[_user];
        return user.referrerAmountsWithDrawn;
    }

    function getCurrentClaimableAmount(address _user, uint256 _index)
        external
        view
        returns (uint256 currentDivident, uint256 withdrawableAmount)
    {
        User storage user = users[_user];

        uint256 slots = (block.timestamp -
            user.stakes[_index].lastWithdrawTime) / withdrawLimitTime;
        withdrawableAmount =
            ((user.stakes[_index].amount * aprPercent) / percentDivider) *
            slots;

        uint256 percentage = (((block.timestamp -
            user.stakes[_index].lastWithdrawTime) * percentDivider) /
            stakingTime);

        currentDivident =
            ((user.stakes[_index].totalAmount * percentage) / percentDivider) -
            withdrawableAmount;

        if (withdrawableAmount >= user.stakes[_index].remainingAmount) {
            withdrawableAmount = user.stakes[_index].remainingAmount;
            currentDivident = 0;
        }

        return (currentDivident, withdrawableAmount);
    }

    function viewStaking(uint256 _index, address _user)
        public
        view
        returns (
            uint256 amount,
            uint256 totalAmount,
            uint256 remainingAmount,
            uint256 startTime,
            uint256 endTime,
            uint256 lastWithdrawTime,
            bool isActive
        )
    {
        User storage user = users[_user];
        amount = user.stakes[_index].amount;
        totalAmount = user.stakes[_index].totalAmount;
        remainingAmount = user.stakes[_index].remainingAmount;
        startTime = user.stakes[_index].startTime;
        endTime = user.stakes[_index].endTime;
        lastWithdrawTime = user.stakes[_index].lastWithdrawTime;
        isActive = user.stakes[_index].isActive;
    }

    function changeToken(IBEP20 _token) external onlyOwner {
        token = _token;
    }

    function changeWithdrawTimeLimit(uint256 _limit) external onlyOwner {
        withdrawLimitTime = _limit;
    }

    function changeReferrerLevelCounter(uint256 _referrerLevelCounter)
        external
        onlyOwner
    {
        require(_referrerLevelCounter <= 100, "Max referrer Counter is 100");
        referrerLevelCounter = _referrerLevelCounter;
    }

    function changeAprPercent(uint256 _aprPercent) external onlyOwner {
        aprPercent = _aprPercent;
    }

    function changeReferrerRewardPercentage(
        uint256[3] memory _referralPercentages
    ) external onlyOwner {
        referralPercentages = _referralPercentages;
    }

    function changeProjectWallet(address _projectWallet) external onlyOwner {
        projectWallet = _projectWallet;
    }

    function changeDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    function changeProjectWalletFee(uint256 _fee) external onlyOwner {
        projectWalletFee = _fee;
    }

    function ChangeRewardPercentage(uint256 _rewardPercent) external onlyOwner {
        rewardPercentage = _rewardPercent;
    }

    function changeStakingTime(uint256 _time) external onlyOwner {
        stakingTime = _time;
    }
}