/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-03
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
    uint256[3] public referralPercentages = [8_00, 3_00, 2_00];
    uint256 public devWalletFee = 5_00;
    uint256 public projectWalletFee = 2_00;
    uint256 public percentDivider = 100_00;
    uint256 public stakingTime = 18 minutes;
    uint256 public withdrawLimitTime = 1 minutes;
    uint256 public aprPercent = 30_00;
    uint256 public totalWithdraw;
    uint256 public totalStaked;
    uint256 public totalUsers;

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
        uint256 totalWithdrawan;
        uint256[3] referalAmounts;
        uint256[3] referalAmountsPending;
        uint256[3] referalAmountsWithDrawn;
        uint256[3] referalCounts;
        uint256 stakingCount;
        uint256 teamTurnOver;
    }

    mapping(address => User) public users;

    constructor(IBEP20 _token) {
        token = _token;
    }

    function stake(uint256 _amount, address _referal) external returns (bool) {
        User storage user = users[msg.sender];
        require(msg.sender != _referal, "You cannot reffer yourself!");

        if (msg.sender == owner()) {
            user.direct = address(0);
        }
        if (_referal == address(0)) {
            user.direct = owner();
        }
        if (!users[_referal].isExists && msg.sender != owner()) {
            user.direct = owner();
        }
        if (
            user.direct == address(0) &&
            msg.sender != owner() &&
            users[_referal].isExists
        ) {
            user.direct = _referal;
            setRefferalChain(_referal);
        }
        if (!user.isExists) {
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
            user.stakes[_index].lastWithdrawTime = user
                .stakes[_index]
                .lastWithdrawTime;
        } else {
            user.stakes[_index].lastWithdrawTime += (slots * withdrawLimitTime);
        }

        user.stakes[_index].remainingAmount -= currentDivident;
        user.totalWithdrawan += currentDivident;
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
        user.stakes[_index].lastWithdrawTime = block.timestamp;

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

        user.totalStaked += currentDivident;
        user.stakingCount++;
        totalStaked += currentDivident;
        return true;
    }

    function setRefferalChain(address _referal) internal {

        address referal = _referal;

        for (uint256 i; i < referralPercentages.length; i++) {
            User storage user = users[referal];
            if (referal == address(0)) {
                break;
            }
            user.referalCounts[i]++;
            referal = users[referal].direct;
        }
    }

    function distributeStakingRewards(uint256 _amount) internal {
        token.transfer(devWallet, (_amount * devWalletFee) / percentDivider);

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

            user.referalAmountsPending[i] +=
                (_amount * referralPercentages[i]) /
                percentDivider;
                
            referal = users[referal].direct;
        }
    }


    function claimReferalReward() external {
        uint256 totalAmount;
        User storage user = users[msg.sender];

        for (uint256 i; i < referralPercentages.length; i++) {
            totalAmount += user.referalAmountsPending[i];
            user.referalAmountsWithDrawn[i] += user.referalAmountsPending[i];
            user.referalAmountsPending[i] = 0;
        }

        require(totalAmount > 0, "You don't have Pending Referal Reward Amount");
        token.transfer(msg.sender, totalAmount);
    }
    

    function referralCounts(address _user) external view returns(uint[3] memory){
        User storage user = users[_user];
        return user.referalCounts;
        
    }

    function referralRewardPending(address _user) external view returns(uint[3] memory){
        User storage user = users[_user];
        return user.referalAmountsPending;
    }
    
    function referralRewardAmounts(address _user) external view returns(uint[3] memory){
        User storage user = users[_user];
        return user.referalAmounts;
    }

    function referralRewardWithdrawn(address _user) external view returns(uint[3] memory){
        User storage user = users[_user];
        return user.referalAmountsWithDrawn;
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

    function changeToken(IBEP20 _token) external onlyOwner returns (bool) {
        token = _token;
        return true;
    }

    function changeWithdrawTimeLimit(uint256 _limit)
        external
        onlyOwner
        returns (bool)
    {
        withdrawLimitTime = _limit;
        return true;
    }

    function changeAprPercent(uint256 _aprPercent)
        external
        onlyOwner
        returns (bool)
    {
        aprPercent = _aprPercent;
        return true;
    }

    function changeReferalRewardPercentage(
        uint256[3] memory _referralPercentages
    ) external onlyOwner returns (bool) {
        referralPercentages = _referralPercentages;
        return true;
    }

    function changeProjectWallet(address _projectWallet)
        external
        onlyOwner
        returns (bool)
    {
        projectWallet = _projectWallet;
        return true;
    }

    function changeDevWallet(address _devWallet)
        external
        onlyOwner
        returns (bool)
    {
        devWallet = _devWallet;
        return true;
    }

    function changeDevWalletFee(uint256 _fee)
        external
        onlyOwner
        returns (bool)
    {
        devWalletFee = _fee;
        return true;
    }

    function changeProjectWalletFee(uint256 _fee)
        external
        onlyOwner
        returns (bool)
    {
        projectWalletFee = _fee;
        return true;
    }

    function ChangeRewardPercentage(uint256 _rewardPercent)
        external
        onlyOwner
        returns (bool)
    {
        rewardPercentage = _rewardPercent;
        return true;
    }

    function changeStakingTime(uint256 _time)
        external
        onlyOwner
        returns (bool)
    {
        stakingTime = _time;
        return true;
    }
}