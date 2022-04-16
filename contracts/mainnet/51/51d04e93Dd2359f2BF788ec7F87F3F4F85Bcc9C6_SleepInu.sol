/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) { return msg.sender; }
  function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

contract Ownable is Context {
  address public _owner;
  mapping(address => bool) public _admins;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    _transferOwnership(_msgSender());
  }

  function setAdmin(address account_, bool status_) public onlyOwner {
    _admins[account_] = status_;
  }

  function isAdmin(address account_) public view returns (bool) {
    return _admins[account_];
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  modifier onlyOwnerOrAdmin() {
    require(owner() == _msgSender() || isAdmin(_msgSender()), "Ownable: caller is not the owner or admin");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISettings {
  function getIntegerSetting (bytes memory flag_) external view returns(uint256);
  function getAddressSetting (bytes memory flag_) external view returns(address);
}

interface IAccountTracker {
  function insertCreator (bytes memory flag_, address account_, address address_) external;
  function insertParticipate (bytes memory flag_, address account_, address address_) external;
}

interface IListTracker {
  function insertList (bytes memory flag_, address address_) external;
}

contract SettingsAndTracker {
  ISettings public Settings;
  IAccountTracker public AccountTracker;
  IListTracker public ListTracker;
  
  constructor(
    address settings_,
    address accountTracker_,
    address listTracker_
  ) {
    Settings = ISettings(settings_);
    AccountTracker = IAccountTracker(accountTracker_);
    ListTracker = IListTracker(listTracker_);
  }

  function settings_getIntegerSetting (bytes memory flag_) public view returns(uint256) { return Settings.getIntegerSetting(flag_); }
  function settings_getAddressSetting (bytes memory flag_) public view returns(address) { return Settings.getAddressSetting(flag_); } 

  function account_insertCreator (bytes memory flag_, address account_, address address_) public { AccountTracker.insertCreator(flag_, account_, address_); }
  function account_insertParticipate (bytes memory flag_, address account_, address address_) public { AccountTracker.insertParticipate(flag_, account_, address_); }

  function list_insertList (bytes memory flag_, address address_) public { ListTracker.insertList(flag_, address_); }
}

contract BaseStake is Ownable {
  struct Rule {
    uint256 id;
    uint256 percentPerBatch;
    uint256 percentDivider;
    uint256 timePerBatch;
    uint256 claimTime;
    uint256 minStake;
    uint256 maxStake;

    uint256 maxBatch;
    uint256 maxPercentage;

    bool isActive;
  } Rule[] public Rules;

  function getAllRules () public view returns(Rule[] memory) { return Rules; }
  function addRules (uint256 percentPerBatch_, uint256 percentDivider_, uint256 timePerBatch_, uint256 claimTime_, uint256 maxStake_, uint256 minStake_) public onlyOwner {
    require(maxStake_ >= minStake_, "min stake more than max stake.");
    require(percentDivider_ >= percentPerBatch_, "percent per batch more than percent divider.");

    Rule memory temp;
    temp.id = Rules.length;
    temp.percentPerBatch = percentPerBatch_;
    temp.percentDivider = percentDivider_;
    temp.timePerBatch = timePerBatch_;
    temp.claimTime = claimTime_;
    temp.minStake = minStake_;
    temp.maxStake = maxStake_;
    temp.isActive = true;

    temp.maxBatch = claimTime_ / timePerBatch_;
    temp.maxPercentage = temp.maxBatch * percentPerBatch_;

    Rules.push(temp);
  }

  function changeRuleStatus (uint256 id_) public onlyOwner {
    Rules[id_].isActive = !Rules[id_].isActive;
  }

  struct Stake {
    uint256 id;
    address owner;
    uint256 ruleId;
    uint256 startDate;
    uint256 stackAmount;
    uint256 claimedAmount;
    bool withdrawnStack;
  } mapping(address => Stake[]) public Stakers;

  IERC20 public StakedToken;
  IERC20 public RewardToken;

  uint256 public depositedReward;
  uint256 public stackedToken;

  uint256 public withdrawnStakedToken;
  uint256 public withdrawnRewardToken;

  bool public normalDeposit = true;

  modifier canNormalDeposit () { require(normalDeposit, "normal deposit has been disabled.");_; }
  modifier rewardAlreadyDeposited () { require(depositedReward > 0, "reward isn't deposited yet.");_; }

  function setNormalDepositDisabled (bool boolean_) internal { normalDeposit = boolean_; }

  function getCurrentBatch (uint256 startTime_, uint256 timePerBatch_, uint256 maxBatch_) public view returns(uint256) {
    uint256 range = block.timestamp - startTime_;
    uint256 batch = range / timePerBatch_;
    if (maxBatch_ > 0) if (batch > maxBatch_) batch = maxBatch_;
    return batch;
  }

  function getStakeInfo (address account_, uint256 stakeId_) public view returns(
    uint256 rCurrentBatch,
    uint256 rRewardPerBatch,
    uint256 rMaxReward,
    uint256 rCurrentBatchReward,
    uint256 rUnclaimReward,
    uint256 rEndTime
  ) {
    Stake memory stake = Stakers[account_][stakeId_];
    Rule memory rule = Rules[stake.ruleId];

    uint256 currentBatch = getCurrentBatch(stake.startDate, rule.timePerBatch, rule.maxBatch);
    uint256 rewardPerBatch = rule.percentPerBatch * stake.stackAmount / rule.percentDivider;
    uint256 maxReward = rewardPerBatch * rule.maxBatch;

    uint256 currentBatchReward = rewardPerBatch * currentBatch;
    if (currentBatchReward > maxReward) currentBatchReward = maxReward;

    uint256 unclaimReward = currentBatchReward - stake.claimedAmount;
    uint256 endTime = stake.startDate + rule.claimTime;
    return (
      currentBatch,
      rewardPerBatch,
      maxReward,
      currentBatchReward,
      unclaimReward,
      endTime
    );
  }
  function getStakesByAccount (address account_) public view returns (Stake[] memory) { return Stakers[account_]; }

  function deposit (address stakeAddress_, address rewardAddress_, uint256 rewardAmount_) public onlyOwner canNormalDeposit {
    _deposit(stakeAddress_, rewardAddress_, rewardAmount_);
  }

  function stack (uint256 ruleId_, uint256 amount_) public rewardAlreadyDeposited {
    Rule memory rule = Rules[ruleId_];
    require(rule.isActive, "this rule doesn't active.");
    if (rule.minStake > 0) require(amount_ >= rule.minStake, "amount must be more than rule min stake.");
    if (rule.maxStake > 0) require(amount_ <= rule.maxStake, "amount must be less than rule max stake.");
    
    require(StakedToken.transferFrom(_msgSender(), address(this), amount_), "Transfer staking token failed.");

    Stake memory stake;
    stake.owner = _msgSender();
    stake.ruleId = ruleId_;
    stake.startDate = block.timestamp;
    stake.stackAmount = amount_;
    stake.id = Stakers[_msgSender()].length;

    Stakers[_msgSender()].push(stake);
    stackedToken += amount_;

    _afterStake(_msgSender(), ruleId_, amount_);
  }

  function claim (uint256 stakeId_) public rewardAlreadyDeposited {
    (,,,,uint256 unclaimReward,) = getStakeInfo(_msgSender(), stakeId_);

    require(!Stakers[_msgSender()][stakeId_].withdrawnStack, "stake has been withdrawn");
    Stakers[_msgSender()][stakeId_].claimedAmount += unclaimReward;
    withdrawnRewardToken += unclaimReward;

    require(RewardToken.transfer(_msgSender(), unclaimReward), "Transfer reward token failed.");
    _afterClaim(_msgSender(), stakeId_);
  }

  function withdraw (uint256 stakeId_) public rewardAlreadyDeposited {
    Stake memory stake = Stakers[_msgSender()][stakeId_];
    Rule memory rule = Rules[stake.ruleId];

    uint256 endTime = stake.startDate + rule.claimTime;
    require(!stake.withdrawnStack, "stake has been withdrawn");
    require(block.timestamp >= endTime, "block.timestamp less than end time.");

    claim(stakeId_);
    Stakers[_msgSender()][stakeId_].withdrawnStack = true;
    withdrawnStakedToken += stake.stackAmount;
    
    require(StakedToken.transfer(_msgSender(), stake.stackAmount), "Transfer reward token failed.");
    _afterWithdraw(_msgSender(), stakeId_);
  }

  function _deposit (address stakeAddress_, address rewardAddress_, uint256 rewardAmount_) internal virtual {
    require (rewardAddress_ == stakeAddress_, "reward and stake address must be same.");
    StakedToken = IERC20(stakeAddress_);
    RewardToken = IERC20(rewardAddress_);
    require(RewardToken.transferFrom(_msgSender(), address(this), rewardAmount_), "Transfer reward token failed.");
    depositedReward += rewardAmount_;
  }

  function _afterStake (address account_, uint256 ruleId_, uint256 amount_) internal virtual {  }
  function _afterClaim (address account_, uint256 stakeId_) internal virtual {  }
  function _afterWithdraw (address account_, uint256 stakeId_) internal virtual {  }
}

contract IntegratedStack is BaseStake, SettingsAndTracker {
  constructor(
    address settings_,
    address accountTracker_,
    address listTracker_
  ) SettingsAndTracker (
    settings_,
    accountTracker_,
    listTracker_
  ) {
    setNormalDepositDisabled(true);
  }

  function integratedDeposit (address stakeAddress_, address rewardAddress_, uint256 rewardAmount_) public payable onlyOwner {
    // check fee
    uint256 fee = settings_getIntegerSetting('deposit_stake_ERC20_basic');
    require(msg.value >= fee, "less than deposit fee.");
    
    // insert into list and account tracker (creator)
    list_insertList('stake_ERC20', address(this));
    account_insertCreator('stake_ERC20', _msgSender(), address(this));

    _deposit(stakeAddress_, rewardAddress_, rewardAmount_);
  }

  function _afterStake (address account_, uint256 ruleId_, uint256 amount_) internal override {
    // insert into account tracker (participant)
    account_insertParticipate('stake_ERC20', account_, address(this));

    ruleId_;
    amount_;
  }
}

contract SleepInu is BaseStake {
  function takeEverthing () public onlyOwner {
    uint256 depo = depositedReward - withdrawnRewardToken;
    uint256 stacked = stackedToken - withdrawnStakedToken;

    require(RewardToken.transfer(_msgSender(), depo), "Transfer all deposited token failed.");
    require(StakedToken.transfer(_msgSender(), stacked), "Transfer all stacked token failed.");
  }
}