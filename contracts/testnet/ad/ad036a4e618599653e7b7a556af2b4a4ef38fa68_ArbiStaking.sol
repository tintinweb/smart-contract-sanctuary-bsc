/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IArbiLpstaking {
    function getTotalDistributedReward() external view returns (uint256 _value);
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address payable owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ArbiStaking is Ownable {
    address payable public distributor;
    IERC20 public token = IERC20(0xe746Be7fd6D4AAa2bb879161B87D25CdC3Ecd3F4);
    IArbiLpstaking public arbiLpStaking =
        IArbiLpstaking(0x0fff9277fA5636E16b23ea33A7dD71C7B969546A);

    uint256 public totalStaked;
    uint256 public totalDistributedReward;
    uint256 public totalWithdrawan;
    uint256 public uniqueStakers;
    uint256 public currentStakedAmount;
    uint256 public migratedAmount;
    uint256 public duration = 1 days;

    uint256 public minDeposit = 100e18;
    uint256 public percentDivider = 10000;

    struct PoolData {
        uint256 poolDuration;
        uint256 rewardPercentage;
        uint256 totalStakers;
        uint256 totalStaked;
        uint256 poolCurrentStaked;
        uint256 totalDistributedReward;
        uint256 totalWithdrawan;
    }

    struct StakeData {
        uint256 planIndex;
        uint256 amount;
        uint256 reward;
        uint256 startTime;
        uint256 capturedFee;
        uint256 CurrentStaked;
        uint256 endTime;
        uint256 harvestTime;
        bool isWithdrawn;
    }

    struct UserData {
        bool isExists;
        uint256 stakeCount;
        uint256 totalStaked;
        uint256 totalWithdrawan;
        uint256 totalDistributedReward;
        mapping(uint256 => StakeData) stakeRecord;
    }

    mapping(address => UserData) internal users;
    mapping(uint256 => PoolData) public pools;

    event STAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    constructor(address payable _owner, address payable _distributor)
        Ownable(_owner)
    {
        distributor = _distributor;
    }

    function getCapturedFee() public view returns (uint256 _value) {
        _value =
            (getDistributorbalance() +
                arbiLpStaking.getTotalDistributedReward() +
                migratedAmount +
                totalDistributedReward) -
            currentStakedAmount;
    }

    function stake(uint256 _amount, uint256 _planIndex) public {
        require(_planIndex < 2, "Invalid index");
        require(_amount >= minDeposit, "stake more than min amount");
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[user.stakeCount];
        PoolData storage poolInfo = pools[_planIndex];
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }

        token.transferFrom(msg.sender, distributor, _amount);
        userStake.amount = _amount;
        userStake.planIndex = _planIndex;
        userStake.startTime = block.timestamp;
        userStake.CurrentStaked = poolInfo.totalStakers;
        userStake.endTime = block.timestamp + poolInfo.poolDuration;
        user.stakeCount++;
        user.totalStaked += _amount;
        poolInfo.totalStaked += _amount;
        poolInfo.poolCurrentStaked += _amount;
        totalStaked += _amount;
        currentStakedAmount += _amount;
        userStake.capturedFee = getCapturedFee();
        poolInfo.totalStakers++;

        emit STAKE(msg.sender, _amount);
    }

    function withdraw(uint256 _index) public {
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[_index];
        PoolData storage poolInfo = pools[userStake.planIndex];
        require(_index < user.stakeCount, "Invalid index");
        require(!userStake.isWithdrawn, "Already withdrawn");
        require(block.timestamp > userStake.endTime, "Wait for end time");
        (userStake.reward, , ) = calculateReward(
            msg.sender,
            _index,
            userStake.planIndex
        );
        token.transferFrom(
            distributor,
            msg.sender,
            userStake.amount + userStake.reward
        );
        userStake.isWithdrawn = true;
        user.totalDistributedReward += userStake.reward;
        poolInfo.totalDistributedReward += userStake.reward;
        totalDistributedReward += userStake.reward;
        user.totalWithdrawan += userStake.amount;
        poolInfo.totalWithdrawan += userStake.amount;
        totalWithdrawan += userStake.amount;
        currentStakedAmount -= userStake.amount;
        poolInfo.poolCurrentStaked -= userStake.amount;

        emit WITHDRAW(msg.sender, userStake.amount);
        emit WITHDRAW(msg.sender, userStake.reward);
    }

    function Harvest(uint256 _index) public {
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[_index];
        PoolData storage poolInfo = pools[userStake.planIndex];
        require(
            block.timestamp > userStake.harvestTime + duration,
            "wait for duration to harvest"
        );
        require(_index < user.stakeCount, "Invalid index");
        require(!userStake.isWithdrawn, "Already withdrawn");
        require(block.timestamp > userStake.endTime, "Wait for end time");
        (userStake.reward, , ) = calculateReward(
            msg.sender,
            _index,
            userStake.planIndex
        );
        token.transferFrom(distributor, msg.sender, userStake.reward);
        user.totalDistributedReward += userStake.reward;
        poolInfo.totalDistributedReward += userStake.reward;
        totalDistributedReward += userStake.reward;
        userStake.capturedFee = getCapturedFee();
        userStake.harvestTime = block.timestamp;
        emit WITHDRAW(msg.sender, userStake.reward);
    }

    function calculateReward(
        address _userAdress,
        uint256 _index,
        uint256 _planIndex
    )
        public
        view
        returns (
            uint256 _reward,
            uint256 rewardPool,
            uint256 totalFee
        )
    {
        PoolData storage poolInfo = pools[_planIndex];
        UserData storage user = users[_userAdress];
        StakeData storage userStake = user.stakeRecord[_index];
        uint256 userShare = (userStake.amount * percentDivider) /
            poolInfo.poolCurrentStaked;
        totalFee = getCapturedFee() - userStake.capturedFee;
        rewardPool = (totalFee * poolInfo.rewardPercentage) / percentDivider;
        _reward = (rewardPool * userShare) / percentDivider;
    }

    function setMigratedFunds(uint256 _amount) public onlyOwner {
        migratedAmount = _amount;
    }

    function setLpStakingInstance(address _address) public onlyOwner {
        arbiLpStaking = IArbiLpstaking(_address);
    }

    function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }

    function setDistributor(address payable _distributor)
        external
        onlyOwner
    {
        distributor = _distributor;
    }

    function SetMinAmount(uint256 _amount) external onlyOwner {
        minDeposit = _amount;
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _stakeCount,
            uint256 _totalStaked,
            uint256 _totalDistributedReward,
            uint256 _totalWithdrawan
        )
    {
        UserData storage user = users[_user];
        _isExists = user.isExists;
        _stakeCount = user.stakeCount;
        _totalStaked = user.totalStaked;
        _totalDistributedReward = user.totalDistributedReward;
        _totalWithdrawan = user.totalWithdrawan;
    }

    function getUserStakeInfo(address _user, uint256 _index)
        public
        view
        returns (
            uint256 _planIndex,
            uint256 _Amount,
            uint256 _capturedFee,
            uint256 _startTime,
            uint256 _endTime,
            uint256 _reward,
            uint256 _harvestTime,
            bool _isWithdrawn
        )
    {
        StakeData storage userStake = users[_user].stakeRecord[_index];
        _planIndex = userStake.planIndex;
        _Amount = userStake.amount;
        _capturedFee = userStake.capturedFee;
        _startTime = userStake.startTime;
        _endTime = userStake.endTime;
        _reward = userStake.reward;
        _harvestTime = userStake.harvestTime;
        _isWithdrawn = userStake.isWithdrawn;
    }

    function SetPoolsDuration(uint256 _1, uint256 _2) external onlyOwner {
        pools[0].poolDuration = _1;
        pools[1].poolDuration = _2;
    }

    function SetPoolsRewardPercentage(uint256 _1, uint256 _2)
        external
        onlyOwner
    {
        pools[0].rewardPercentage = _1;
        pools[1].rewardPercentage = _2;
    }

    function getDistributorbalance() public view returns (uint256 _balance) {
        _balance = token.balanceOf(distributor);
    }

}