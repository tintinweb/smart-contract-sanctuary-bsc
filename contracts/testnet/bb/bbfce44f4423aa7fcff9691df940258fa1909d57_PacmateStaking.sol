/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.11;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract Authorisable is Context, Ownable {
    mapping(address => bool) private authorised;

    event Authorised(address indexed user, bool indexed isAuthorised);
    function setAuthorised(address _user, bool _isUserAuthorised) public onlyOwner {
      require(authorised[_user] != _isUserAuthorised, authorised[_user] ? "User is already a manager" : "User doesn't have manager rights");
      authorised[_user] = _isUserAuthorised;
      emit Authorised(_user, _isUserAuthorised);
    }

    function isAuthorised(address _user) public view returns (bool) {
      return authorised[_user];
    }

    constructor() {
      setAuthorised(_msgSender(), true);
    }
}

contract PacmateStaking is Pausable, Ownable, Authorisable {
    
    uint256 constant public PERCENTS_DIVIDER = 10_000;

    struct PoolInfo {
        string name;
        /* Staking Token */
        address stakingTokenAddress;
        /* Reward Token */
        address rewardTokenAddress;

        // Staking Period
        uint256 stakingPeriod;   

        /* Staking Reward ratio */
        uint256 rewardPercent;

        uint256 stakingAmount;

        /* How many tokens we have successfully staked */
        uint256 totalStaked;
        /* How many tokens maximum can be staked */
        uint256 maxStakedAmount;

        // if pool is ended
        bool isEnded;

        bool requiresWhitelist;

    }
    
    struct UserInfo {
        uint256 balance;
        uint256 stakedAt;
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(uint256 => mapping (address => bool)) private whitelist;


    function addToWhitelist(uint256 pid, address wallet) public 
    {
      require(isAuthorised(msg.sender), "not authorised");
      whitelist[pid][wallet] = true;
    }

    function isWhitelisted(uint256 pid, address wallet) public view returns (bool)
    {
      return whitelist[pid][wallet];
    }

    // Total Staked balance for every staking token
    mapping(address => uint256) public stakedBalance;

    

    event Staked(uint256 pid, address indexed account, uint256 amount);
    event Withdrawn(uint256 pid, address indexed account, uint256 amount);
    event StakingAddressUpdated(uint256 pid, address stakingToken);
    event RewardAddressUpdated(uint256 pid, address rewardToken);
    event RewardPercentUpdated(uint256 pid, uint256 rewardPercent);
    event StakingPeriodUpdated(uint256 pid, uint256 stakingPeriod);
    event StakingAmountUpdated(uint256 pid, uint256 stakingAmount);
    event MaxStakedAmount(uint256 pid, uint256 maxStakedAmount);
    event StakingEnded(uint256 pid, bool isEnded);
    event StakingRequiresWhitelistChanged(uint256 pid, bool isEnded);

    constructor(address _defaultTokenAddress) {
        addPool("WL", _defaultTokenAddress, _defaultTokenAddress, 40  * 86400, 5479, 100_000 * 10**18, 10_000_000 * 10**18, true);
        addPool("Public", _defaultTokenAddress, _defaultTokenAddress, 60 * 86400, 3280, 300_000 * 10**18, 10_000_000 * 10**18, false);

        _pause();
    }

    /**
     * @dev all new pool
     * @param _staking: Staking token address of Pool
     * @param _reward: Rewards token address of Pool
     * @param _period: Staking Period of Pool
     * @param _percent: Rewards Percent of Pool  Rewards amount = Staking Amount * ( 100 + Percent) / 100
     * @param _amount: Staking Amount of Pool
     */
    function addPool(
        string memory _name,
        address _staking, 
        address _reward, 
        uint256 _period, 
        uint256 _percent,
        uint256 _amount,
        uint256 _maxStakedAmount,
        bool _requiresWhitelist
        ) public onlyOwner {
        
        poolInfo.push(PoolInfo({
            stakingTokenAddress: _staking,
            rewardTokenAddress: _reward,
            stakingPeriod: _period,
            rewardPercent: _percent,
            stakingAmount: _amount,
            maxStakedAmount: _maxStakedAmount,
            totalStaked: 0,
            isEnded: false,
            requiresWhitelist: _requiresWhitelist,
            name: _name
        }));
    }

    function fetchPools() public view returns (PoolInfo[] memory)
    {
      return poolInfo;
    }


    /**
     * @dev Set Staking Token Contract Address
     */
    function setStakingTokenAddress(uint256 _pid, address _address) external onlyOwner {
        require(_address != address(0x0), "invalid address");
        poolInfo[_pid].stakingTokenAddress = _address;

        emit StakingAddressUpdated(_pid, _address);
    }

    /**
     * @dev Set Rewards Token Contract Address
     */
    function setRewardTokenAddress(uint256 _pid, address _address) external onlyOwner {
        require(_address != address(0x0), "invalid address");
        poolInfo[_pid].rewardTokenAddress = _address;

        emit RewardAddressUpdated(_pid, _address);
    }

    /**
     * @dev Set Rewards Percent
     */
    function setRewardPercent(uint256 _pid, uint256 _percent) external onlyOwner {
        poolInfo[_pid].rewardPercent = _percent;

        emit RewardPercentUpdated(_pid, _percent);
    }

    /**
     * @dev Set Staking  Period (Seconds)
     */
    function setStakingPeriod(uint256 _pid, uint256 _period) external onlyOwner {
        require(_period > 0, "invalid period");
        poolInfo[_pid].stakingPeriod = _period;

        emit StakingPeriodUpdated(_pid, _period);
    }
    
    /**
     * @dev Set Staking Amount (ie: 200 * 1e18)
     */
    function setMaxStakedAmount(uint256 _pid, uint256 _maxStakedAmount) external onlyOwner {
        require(_maxStakedAmount > 0, "Invalid Max amount");

        poolInfo[_pid].maxStakedAmount = _maxStakedAmount;

        emit MaxStakedAmount(_pid, _maxStakedAmount);
    }

    /**
     * @dev Set Staking Amount (ie: 200 * 1e18)
     */
    function setStakingAmount(uint256 _pid, uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid Max amount");

        poolInfo[_pid].stakingAmount = _amount;

        emit StakingAmountUpdated(_pid, _amount);
    }

    /**
     * @dev Set Staking Amount (ie: 200 * 1e18)
     */
    function setIsEnded(uint256 _pid, bool _isEnded) external onlyOwner {
        poolInfo[_pid].isEnded = _isEnded;

        emit StakingEnded(_pid, _isEnded);
    }


    function setWhitelistRequired(uint256 _pid, bool _requiresWhitelist) external onlyOwner {
        poolInfo[_pid].requiresWhitelist = _requiresWhitelist;

        emit StakingRequiresWhitelistChanged(_pid, _requiresWhitelist);
    }


    /**
     * @dev Staked Amount for account and Pool
     */
    function balanceOf(uint256 _pid, address account) public view returns (uint256) {
        return userInfo[_pid][account].balance;
    }

    /**
     * @dev Pools count
     */
    function poolsCount() public view returns (uint256) {
        return poolInfo.length;
    }


    /**
     * @dev Remain Seconds till staking ends for POOL and Account
     *      User should wait to withdraw rewards
     */
    function remainSeconds(uint256 _pid, address account) public view returns(uint256) {
        uint256 stakedAt = userInfo[_pid][account].stakedAt;
        if(stakedAt != 0 && userInfo[_pid][account].balance > 0) {
            uint256 passed = block.timestamp - stakedAt;
            return  passed >= poolInfo[_pid].stakingPeriod ? 0 : (poolInfo[_pid].stakingPeriod - passed);
        }

        return 0;
    }
    

    /**
     * @dev Stake Staking Token to get rewards
     * @param _pid: POOL Id to stake
     */
    function stake(uint256 _pid) public whenNotPaused {
        UserInfo storage uInfo = userInfo[_pid][_msgSender()];
        PoolInfo storage pInfo = poolInfo[_pid];

        require(uInfo.balance == 0, "already staked");
        require(!pInfo.isEnded, "pool ended");
        require(!pInfo.requiresWhitelist || (pInfo.requiresWhitelist && whitelist[_pid][msg.sender]), "user not whitelisted :(");

        uint256 stakingAmount = pInfo.stakingAmount;
        
        /* if total amount is bigger than maximum staked amount */
        require(pInfo.totalStaked + stakingAmount <= pInfo.maxStakedAmount, "Maximum number of staked amount exceeded");

        require(IERC20(pInfo.stakingTokenAddress).transferFrom(_msgSender(), address(this), stakingAmount), "tranfer failed");
        uInfo.balance = stakingAmount;
        uInfo.stakedAt = block.timestamp;
        pInfo.totalStaked += stakingAmount;

        stakedBalance[pInfo.stakingTokenAddress] += stakingAmount;

        whitelist[_pid][msg.sender] = false;

        emit Staked(_pid, _msgSender(), stakingAmount);
    }


    /**
     * @dev Withdraw Staking Token and Rewards token. End Staking
     * @param _pid: POOL Id to withdraw
     */
    function withdraw(uint256 _pid) public {
        UserInfo storage uInfo = userInfo[_pid][_msgSender()];
        PoolInfo storage pInfo = poolInfo[_pid];
        
        require(uInfo.balance > 0, "not staked");
        
        uint256 passed = block.timestamp - uInfo.stakedAt;
        uint256 stakingAmount = pInfo.stakingAmount;
        
        require(passed >= pInfo.stakingPeriod, "need to wait now");

        if(passed >= pInfo.stakingPeriod) {
            // only passed staking period
            uint256 rewards = stakingAmount * pInfo.rewardPercent / PERCENTS_DIVIDER;
            if(rewards > 0) {
                require(IERC20(pInfo.rewardTokenAddress).transfer(_msgSender(), rewards), "Transfer rewards failed");
            }
        }

        require(IERC20(pInfo.stakingTokenAddress).transfer(_msgSender(), stakingAmount), "Transfer failed");
        uInfo.balance = 0;
        uInfo.stakedAt = 0;
        pInfo.totalStaked -= stakingAmount;

        stakedBalance[pInfo.stakingTokenAddress] -= stakingAmount;

        emit Withdrawn(_pid, _msgSender(), stakingAmount);
    }

    
    /**
     * @dev onlyAdmin Withdraw Rewards token from contract
     * @param _rewardsToken  Rewards token address
     * @param _amount  Amount to withdraw
     */
    function withdrawRewards(address _rewardsToken, uint256 _amount) public onlyOwner {
        require(_amount > 0, "invalid amount to withdraw");

        uint256 balance = IERC20(_rewardsToken).balanceOf(address(this));
        if(balance > stakedBalance[_rewardsToken]) {
            uint256 available = balance - stakedBalance[_rewardsToken];
            IERC20(_rewardsToken).transfer(_msgSender(), _amount > available ? available : _amount);
        }
    }

    function switchPause() public onlyOwner {
      if (paused()) {
        _unpause();
      } else {
        _pause();
      }
    }

    function transferOtherToken(address _token, address _to, uint256 _amount)
        external
        onlyOwner
        returns (bool _sent)
    {
        require(_token != address(0), "_token address cannot be 0");
        require(_to != address(0), "_to address cannot be 0");
        //uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _amount);
    }
}