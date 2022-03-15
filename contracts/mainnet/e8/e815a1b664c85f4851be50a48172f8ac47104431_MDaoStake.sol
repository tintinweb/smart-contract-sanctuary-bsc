/**
 *Submitted for verification at BscScan.com on 2022-03-15
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IMProToken {
    function mint(address, uint256) external;
}

contract MDaoStake is Ownable, ReentrancyGuard {

    //Info of each user
    struct UserInfo {
        uint256 lastHarvestTimestamp;
        uint256 stakedTimestamp;
        uint256 stakedAmount;
        uint256 boost; 
    }
    
    // Info of each pool.
    struct PoolInfo {
        uint256 rate; 
        uint256 totalStaked;
        bool paused;
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    IERC20 public mdaoToken;
    IMProToken public mproToken;

    event Staked(address indexed account, uint256 pid, uint256 startTime, uint256 amount);
    event Harvested(address indexed account, uint256 pid, uint256 value);
    event Unstaked(address indexed account, uint256 pid, uint256 amount);
    event RegisterPool(uint256 rate);
    event UpdatePool(uint256 rate, bool paused);

    constructor(address _mdaoToken, address _mproToken) {
        owner = msg.sender;

        mdaoToken = IERC20(_mdaoToken);
        mproToken = IMProToken(_mproToken);

        // staking pool
        poolInfo.push(PoolInfo({
            rate : 1000,
            totalStaked : 0,
            paused: false
        }));
    }

    // register a pool. Can only be called by the owner.
    function registerPool(uint256 _rate) public onlyOwner {

        poolInfo.push(PoolInfo({
            rate : _rate,
            totalStaked : 0,
            paused: false
        }));
        
        emit RegisterPool(_rate);
    }

    // Update the pool detail, given pid of the pool. Can only be called by the owner.
    function updatePool(uint256 _pid, uint256 _rate, bool _paused) public onlyOwner {
        
        PoolInfo storage _poolInfo = poolInfo[_pid];
        _poolInfo.rate = _rate;
        _poolInfo.paused = _paused;

        emit UpdatePool(_rate, _paused);
    }

    function stake(uint256 _pid, uint256 _amount) external {  

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "Contract paused, please try again later");
        require(_amount > 0, "Stake amount must be greater then zero");
        require(mdaoToken.balanceOf(msg.sender) >= _amount, "Insufficient MDAO token");
        
        // If user is already staking, harvest rewards first before stake
        if(_userInfo.stakedAmount > 0)
            harvest(_pid);
  
        _userInfo.lastHarvestTimestamp = block.timestamp;
        _userInfo.stakedTimestamp = block.timestamp;
        _userInfo.stakedAmount = _userInfo.stakedAmount + _amount;
        _userInfo.boost = 1;    //Default boost is 1x 

        _poolInfo.totalStaked += _amount;

        mdaoToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _pid, block.timestamp, _amount);
    }

    function unstake(uint256 _pid) external {

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "Contract paused, please try again later");
        require(_userInfo.stakedTimestamp > 0, "You dont have stake");

        harvest(_pid);
        
        uint256 _amount = _userInfo.stakedAmount;
        require(mdaoToken.balanceOf(address(this)) >= _amount, 'Contract doesnt have enough MDAO');
        
        _userInfo.stakedTimestamp = 0;
        _userInfo.stakedAmount = 0;

        _poolInfo.totalStaked -= _amount;
        mdaoToken.transfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) public returns (uint256 value) {

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "Contract paused, please try again later");
        require(_userInfo.stakedAmount > 0, "You dont have stake");

        uint256 _value = getStakeRewards(_pid);
        require(_value > 0, "You do not have any pending rewards");

        _userInfo.lastHarvestTimestamp = block.timestamp;
        mintMPro(msg.sender, _value);

        emit Harvested(msg.sender, _pid, _value);
        return _value;
    }

    function getStakeRewards(uint256 _pid) public view returns (uint256) {
       
        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        if (_userInfo.stakedAmount == 0) return (0);

        uint256 _timePassed = block.timestamp - _userInfo.lastHarvestTimestamp;
        uint256 _reward = (_timePassed * (_poolInfo.rate * 10**18)) / 86400;    //Rewards divided by 1 day, 86400 seconds
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