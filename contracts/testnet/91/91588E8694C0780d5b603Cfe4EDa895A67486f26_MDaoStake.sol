/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: NONE
pragma solidity 0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256 balance);
    function transfer(address to, uint256 value) external returns (bool trans1);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool trans);
}


contract Ownable{

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can call this function');
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), 'You cant transfer ownerships to address 0x0');
        require(newOwner != owner, 'You cant transfer ownerships to yourself');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface IMProToken {
    function mint(address, uint256) external;
}

contract MDaoStake is Ownable {

    //Info of each user
    struct UserInfo {
        uint256 lastHarvestTimestamp;   // User last harvest timestamp
        uint256 stakedTimestamp;        // User staking timestamp
        uint256 stakedAmount;           // User staked amount in the pool
        uint256 boost;                  // User boost, default is 1
    }
    
    // Info of each pool.
    struct PoolInfo {
        uint256 rate;           // Fixed rewards rate
        uint256 stakeLimit;     // Fixed staking amount 
        uint256 totalStaked;    // Total staked tokens in the pool
        bool paused;            // Pause or unpause the pool, failover plan
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    IERC20 public mdaoToken;
    IMProToken public mproToken;
    uint256 public rewardPeriod;    //daily 86400, monthly 2592000

    event Staked(address indexed account, uint256 pid, uint256 startTime, uint256 amount);
    event Harvested(address indexed account, uint256 pid, uint256 value);
    event Unstaked(address indexed account, uint256 pid, uint256 amount);
    event RegisterPool(uint256 rate, uint256 stakeLimit);
    event UpdatePool(uint256 rate, bool paused);

    constructor(address _mdaoToken, address _mproToken) {
        owner = msg.sender;

        mdaoToken = IERC20(_mdaoToken);
        mproToken = IMProToken(_mproToken);

        // staking pool
        poolInfo.push(PoolInfo({
            rate : 1000,
            stakeLimit : 10 * (10**18),
            totalStaked : 0,
            paused: false
        }));

        // Reward period, to calculate against the rate
        rewardPeriod = 86400;   
    }

    // register a pool. Can only be called by the owner.
    function registerPool(uint256 _rate, uint256 _stakeLimit) public onlyOwner {

        poolInfo.push(PoolInfo({
            rate : _rate,
            stakeLimit : _stakeLimit,
            totalStaked : 0,
            paused: false
        }));
        
        emit RegisterPool(_rate, _stakeLimit);
    }

    // Update the pool detail, given pid of the pool. Can only be called by the owner.
    function updatePool(uint256 _pid, uint256 _rate, uint256 _stakeLimit, bool _paused) public onlyOwner {
        
        PoolInfo storage _poolInfo = poolInfo[_pid];
        _poolInfo.rate = _rate;
        _poolInfo.stakeLimit = _stakeLimit;
        _poolInfo.paused = _paused;

        emit UpdatePool(_rate, _paused);
    }

    function stake(uint256 _pid, uint256 _amount) external {  

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "stake : Contract paused, please try again later");
        require(_poolInfo.stakeLimit == _amount, "stake : Incorrect staking amount");
        require(_userInfo.stakedAmount == 0, "stake : Already staking in this pool");
        require(mdaoToken.balanceOf(msg.sender) >= _amount, "stake : Insufficient MDAO token");
        
        // Update user staking info
        _userInfo.lastHarvestTimestamp = block.timestamp;
        _userInfo.stakedTimestamp = block.timestamp;
        _userInfo.stakedAmount = _amount;
        _userInfo.boost = 1;  

        // Update pool info
        _poolInfo.totalStaked += _amount;

        mdaoToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _pid, block.timestamp, _amount);
    }

    function unstake(uint256 _pid) external {

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "unstake : Contract paused, please try again later");
        require(_userInfo.stakedAmount > 0, "unstake : You dont have stake");
        require(mdaoToken.balanceOf(address(this)) >= _userInfo.stakedAmount, "unstake : Contract doesnt have enough MDAO, please contact admin");

        // Update userinfo
        _userInfo.stakedTimestamp = 0;
        _userInfo.stakedAmount = 0;

        harvest(_pid);  // Harvest before unstake
        
        _poolInfo.totalStaked -= _userInfo.stakedAmount;    // Update pool total stake token
        mdaoToken.transfer(msg.sender, _userInfo.stakedAmount); // Transfer MDao token back to the owner

        emit Unstaked(msg.sender, _pid, _userInfo.stakedAmount);
    }

    function harvest(uint256 _pid) public {

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "harvest : Contract paused, please try again later");
        require(_userInfo.stakedAmount > 0, "harvest : You dont have stake");

        uint256 _value = getStakeRewards(_pid);
        require(_value > 0, "harvest : You do not have any pending rewards");

        _userInfo.lastHarvestTimestamp = block.timestamp;   // Update user last harvest timestampe
        mintMPro(msg.sender, _value);   // Mint MPro rewards to user

        emit Harvested(msg.sender, _pid, _value);
    }

    function getStakeRewards(uint256 _pid) public view returns (uint256) {
       
        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        if (_userInfo.stakedAmount == 0) return (0);

        uint256 _timePassed = block.timestamp - _userInfo.lastHarvestTimestamp;
        uint256 _reward = (_timePassed * (_poolInfo.rate * 10**18)) / rewardPeriod;    //Rewards divided by 1 day, 86400 seconds
        uint256 _rewardAfterBoost = _reward * _userInfo.boost;

        return _rewardAfterBoost;
    }

    function mintMPro(address _to, uint256 _amount) internal {
        mproToken.mint(_to, _amount);
    }

    function setMDaoToken(address _mdaoToken) external onlyOwner {
        mdaoToken = IERC20(_mdaoToken);
    }

    function setMProToken(address _mproToken) external onlyOwner {
        mproToken = IMProToken(_mproToken);
    }

    function setRewardPeriod(uint256 _rewardPeriod) external onlyOwner {
        rewardPeriod = _rewardPeriod;
    }

    function setBoost(address _account, uint _boost) external onlyOwner {
        require(_boost > 1, "Boost value must be larger than 1");

        for(uint256 i=0; i<poolInfo.length; i++) {
            UserInfo storage _userInfo = userInfo[i][_account];
            _userInfo.boost = _boost;
        }  
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function rescueToken(address _token, address _to) external onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

	function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}