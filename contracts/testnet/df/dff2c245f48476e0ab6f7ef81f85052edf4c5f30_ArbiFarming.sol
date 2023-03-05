/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IArbiStaking {
    function getCapturedFee() external view returns (uint256 _value);
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

interface IPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

contract ArbiFarming is Ownable {
    address payable public distributor;
    IPair public pair = IPair(0x81a20fDE704E21F24E09a2489545f5C3Ccb5fA47);
    IERC20 public token = IERC20(0xe746Be7fd6D4AAa2bb879161B87D25CdC3Ecd3F4);
    IArbiStaking public arbiStaking =
        IArbiStaking(0xAD036A4E618599653e7b7a556aF2b4A4ef38FA68);

    uint256 public totalStaked;
    uint256 public totalDistributedReward;
    uint256 public totalWithdrawan;
    uint256 public uniqueStakers;
    uint256 public currentStakedAmount;
    uint256 public feePrecentage;
    uint256 public duration = 1 days;

    function setFeePercentage(uint256 _feePercentage) public onlyOwner {
        feePrecentage = _feePercentage;
    }

    uint256 public minDeposit = 100;
    uint256 public percentDivider = 100_00;

    struct StakeData {
        uint256 planIndex;
        uint256 lpAmount;
        uint256 reward;
        uint256 startTime;
        uint256 Capturefee;
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

    event STAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    constructor(address payable _owner, address payable _distributor)
        Ownable(_owner)
    {
        distributor = _distributor;
    }

    function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }

    function setDistributor(address payable _distributor) external onlyOwner {
        distributor = _distributor;
    }

    function stake(uint256 _amount) public {
        require(_amount >= minDeposit, "stake more than min amount");
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[user.stakeCount];
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }

        pair.transferFrom(msg.sender, address(this), _amount);
        userStake.lpAmount = _amount;
        userStake.startTime = block.timestamp;
        userStake.Capturefee = arbiStaking.getCapturedFee();
        user.stakeCount++;
        user.totalStaked += _amount;
        totalStaked += _amount;
        currentStakedAmount += _amount;

        emit STAKE(msg.sender, _amount);
    }

    function withdraw(uint256 _index) public {
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[_index];
        require(_index < user.stakeCount, "Invalid index");
        require(!userStake.isWithdrawn, "Already withdrawn");
        pair.transfer(msg.sender, userStake.lpAmount);
        userStake.reward = calculateReward(msg.sender, _index);
        token.transferFrom(distributor, msg.sender, userStake.reward);
        userStake.isWithdrawn = true;
        user.totalDistributedReward += userStake.reward;
        totalDistributedReward += userStake.reward;
        user.totalWithdrawan += userStake.lpAmount;
        totalWithdrawan += userStake.lpAmount;
        currentStakedAmount -= userStake.lpAmount;
        userStake.endTime = block.timestamp;

        emit WITHDRAW(msg.sender, userStake.lpAmount);
        emit WITHDRAW(msg.sender, userStake.reward);
    }

    function calculateReward(address _userAdress, uint256 _index)
        public
        view
        returns (uint256 _reward)
    {
        UserData storage user = users[_userAdress];
        StakeData storage userStake = user.stakeRecord[_index];
        uint256 userShare = (userStake.lpAmount * percentDivider) /
            currentStakedAmount;
        uint256 totalFee = arbiStaking.getCapturedFee() - userStake.Capturefee;
        uint256 rewardPool = (totalFee * feePrecentage) / percentDivider;
        _reward = (rewardPool * userShare) / percentDivider;
    }

    function harvest(uint256 _index) public {
        UserData storage user = users[msg.sender];
        StakeData storage userStake = user.stakeRecord[_index];
        require(
            block.timestamp > userStake.harvestTime + duration,
            "wait for duration to harvest"
        );
        require(_index < user.stakeCount, "Invalid index");
        require(!userStake.isWithdrawn, "Amount withdrawn");
        userStake.reward = calculateReward(msg.sender, _index);
        token.transferFrom(distributor, msg.sender, userStake.reward);
        user.totalDistributedReward += userStake.reward;
        totalDistributedReward += userStake.reward;
        userStake.Capturefee = arbiStaking.getCapturedFee();
        userStake.harvestTime = block.timestamp;
    }

    function setTokenStakingInstance(address _address) public onlyOwner {
        arbiStaking = IArbiStaking(_address);
    }

    function getTotalDistributedReward() public view returns (uint256 _value) {
        _value = totalDistributedReward;
    }

    function getCapturedFee() public view returns (uint256 fee) {
        fee = arbiStaking.getCapturedFee();
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
            uint256 _lpAmount,
            uint256 _capturedFee,
            uint256 _startTime,
            uint256 _endTime,
            uint256 _reward,
            uint256 _harvestTime,
            bool _isWithdrawn
        )
    {
        StakeData storage userStake = users[_user].stakeRecord[_index];
        _lpAmount = userStake.lpAmount;
        _capturedFee = userStake.Capturefee;
        _startTime = userStake.startTime;
        _endTime = userStake.endTime;
        _reward = userStake.reward;
        _isWithdrawn = userStake.isWithdrawn;
        _harvestTime = userStake.harvestTime;
    }

    function SetMinAmount(uint256 _amount) external onlyOwner {
        minDeposit = _amount;
    }
}