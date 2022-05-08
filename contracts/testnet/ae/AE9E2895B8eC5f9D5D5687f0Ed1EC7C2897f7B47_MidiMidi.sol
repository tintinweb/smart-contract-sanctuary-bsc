/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity ^0.8.11;
//SPDX-License-Identifier: UNLICENSED

interface IERC20 {

  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
  constructor () { }
  
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }
  
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
  
}

library SafeMath {
    
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Stakeable {

  // Percentage is provided in MilliPercents
  uint256 public _firstTypePartFromBalance = 10000;
  uint256 public _secondTypePartFromBalance = 30000;
  uint256 public _thirdTypePartFromBalance = 60000;

  uint256 public _firstTypeAssumption = 6000;
  uint256 public _secondTypeAssumption = 3000;
  uint256 public _thirdTypeAssumption = 1000;  

  // Duration in days
  uint16 public _firstStackTypeDuration = 7;
  uint16 public _secondtStackTypeDuration = 28;
  uint16 public _thirdStackTypeDuration = 84;

  mapping (uint256 => uint256) private stakeAssumption;
  mapping (uint256 => uint256) private stakePart;

  uint32 dayInSeconds = 60;

    /**
    * @notice Constructor since this contract is not ment to be used without inheritance
    * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
        stakeAssumption[1] = _firstTypeAssumption;
        stakeAssumption[2] = _secondTypeAssumption;
        stakeAssumption[3] = _thirdTypeAssumption;

        stakePart[1] = _firstTypePartFromBalance;
        stakePart[2] = _secondTypePartFromBalance;
        stakePart[3] = _thirdTypePartFromBalance;
    }
    
    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 milliPercent;
        uint8 stakeType;
        uint256 mustClaim;
    }
    /**
    * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
        
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
    struct StakingSummary{
        uint256 total_amount;  // Total staked amount
        uint256 total_count;   // How many stakes user have
        uint256 total_reward;   // How many rewards does user have
        uint256 claimable_amount; // How many tokens can claim user
        Stake[] stakes;
    }

    /**
    * @notice 
    *   This is a array where we store all Stakes that are performed on the Contract
    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
    */
    Stakeholder[] internal stakeholders;
    /**
    * @notice 
    * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
    * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
     event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp, uint256 milliPercent, uint256 mustClaim);

    
    /**
    * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256){
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
    * @notice
    * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
    * StakeID 
    */
    function _stake(uint256 _amount, uint256 collectedReward, uint8 stakeType, uint256 ccSupply, uint256 usedReward, uint256 cumulatedStakePerType) internal returns (uint256){
        // Simple check so that user does not stake 0 
        require(stakeType >= 1 && stakeType <=3, "Wrong type for stacking");
        require(_amount > 0, "Cannot stake nothing");

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }
        // Calculate percent by total colected reward
        uint256 milliPercentOfUser;
        uint256 mustClaim;
        uint256 temporraryAssumption;
        bool limitReached;

        if (ccSupply * stakeAssumption[stakeType] / 100000 < (cumulatedStakePerType + _amount)) {
          temporraryAssumption =  (cumulatedStakePerType + _amount) * 100000 / ccSupply;
          limitReached = thresholdStakeAssumptions(stakeType, temporraryAssumption);
          if (!limitReached){
            stakeAssumption[stakeType] =  (cumulatedStakePerType + _amount) * 100000 / ccSupply;
          }
        }

        milliPercentOfUser = ((collectedReward - usedReward) * stakePart[stakeType]) * 100000 / (ccSupply * stakeAssumption[stakeType]);
        mustClaim = _amount * milliPercentOfUser / 100000;


        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, milliPercentOfUser, stakeType, mustClaim));
     
        emit Staked(msg.sender, _amount, index, timestamp, stakeType, mustClaim);

        return mustClaim;
    }

    function thresholdStakeAssumptions(uint256 stakeType, uint256 temporraryAssumption) internal returns (bool){
      bool limitReached = false;
      if (stakeType == 1 && temporraryAssumption > 96000){
        saveAssumptions(96000, 3000, 1000);
        limitReached = true;
      } 
      else if (stakeType == 2 && temporraryAssumption > 93000) {
        saveAssumptions(6000, 93000, 1000);
        limitReached = true;
      }
      else if (stakeType == 3 && temporraryAssumption > 91000) {
        saveAssumptions(6000, 3000, 91000);
        limitReached = true;
      }
      
      return limitReached;
    }

    function saveAssumptions(uint64 first, uint64 second, uint64 third) internal{
          stakeAssumption[1] = first;
          stakeAssumption[2] = second;
          stakeAssumption[3] = third;
    }

    /**
      * @notice
      * calculateClaimableReward is used to calculate how much a user can already claim for their stakes
      * and the duration the stake has been active
     */
      function calculateClaimableReward(Stake memory _current_stake) internal view returns(uint256){
          uint256 claimableReward;
          uint256 daysPassed = (block.timestamp - _current_stake.since) / dayInSeconds;

          if (_current_stake.stakeType == 1 && daysPassed < _firstStackTypeDuration * dayInSeconds) return 0;
          if (_current_stake.stakeType == 2 && daysPassed < _secondtStackTypeDuration * dayInSeconds) return 0;
          if (_current_stake.stakeType == 3 && daysPassed < _thirdStackTypeDuration * dayInSeconds) return 0;
    
          claimableReward = _current_stake.amount * _current_stake.milliPercent / 100000;
          return claimableReward;
      }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to transfer into the acount
     * Will also calculateStakeReward and reset timer
    */
     function _withdrawStake(uint256 index) internal returns(uint256){
         // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        uint256 claim;
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];

        uint256 daysPassed = timestamp - current_stake.since;
        
        if (current_stake.stakeType == 1) {
          uint256 mustPassTime = _firstStackTypeDuration * dayInSeconds;
          require(daysPassed < mustPassTime, "Staking: You can't withdraw yet");
        }
        else if (current_stake.stakeType == 2) {
          uint256 mustPassTime = _secondtStackTypeDuration * dayInSeconds;
          require(daysPassed < mustPassTime, "Staking: You can't withdraw yet");
        }
        else if (current_stake.stakeType == 3) {
          uint256 mustPassTime = _thirdStackTypeDuration * dayInSeconds;
          require(daysPassed < mustPassTime, "Staking: You can't withdraw yet");
        }
        claim = current_stake.mustClaim;

        delete stakeholders[user_index].address_stakes[index];
        return claim;
     }

    function _rootAmount(uint256 index) internal view returns(uint256){
      uint256 user_index = stakes[msg.sender];
      Stake memory current_stake = stakeholders[user_index].address_stakes[index];
      uint256 rootAmount = current_stake.amount;
      return rootAmount;
    }

    function stakeTypeByIndex(uint256 index) internal view returns(uint256){
      uint256 user_index = stakes[msg.sender];
      Stake memory current_stake = stakeholders[user_index].address_stakes[index];
      uint256 stakeType = current_stake.stakeType;
      return stakeType;
    }

     function _setPartsForStackTypes(uint32 first, uint32 second, uint32 third) internal returns(bool){
      stakePart[1] = first;
      stakePart[2] = second;
      stakePart[3] = third;
      return true;
     }

}


contract MidiMidi is Context, IERC20, Ownable, Stakeable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _noFeeFrom;
  mapping (address => bool) private _noFeeTo;
  mapping (address => uint256) private _privateSaleAmount;
  mapping (address => bool) private _preSaleMember;

  mapping (address => mapping (address => uint256)) private _allowances;

  bool public _tradingOpen;
  bool public _privateSaleEnded;
  uint256 public privateSaleEndTime;
  uint256 public airdropEndTime;

  uint256 public _totalFrozenAmount;
  uint256 public _totalStakedAmount;
  uint256 public _applicableContractRewardAmount;
  
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address public _developmentFundsAddress;
  address public _liquidityPoolAddress;

  uint256 public _privateSaleStartTime;
  // uint256 public _preSaleStartTime;
  // uint256 public _publicStartTime;

  uint256 public _rewardMilipercent = 3000;
  uint256 public _developmentMilipercent = 3000;
  uint256 public _fundRaisingMilipercent = 1000;
  uint256 public _liquidityMilipercent = 3000;

  uint256 public _totalStakedForFirst;
  uint256 public _totalStakedForSecond;
  uint256 public _totalStakedForThird;

  mapping (uint256 => uint256) private totalStackings;
  

  constructor() {
    _name = "midimidi";
    _symbol = "mdd";
    _decimals = 9;
    _totalSupply = 10**9 * 10**9;
    _balances[msg.sender] = _totalSupply;
    _developmentFundsAddress = msg.sender;
    _liquidityPoolAddress = msg.sender;
    _privateSaleStartTime = block.timestamp;
    _tradingOpen = false;
    _privateSaleEnded = false;
    _totalFrozenAmount = 0;
    _totalStakedAmount = 0;
    _applicableContractRewardAmount = 0;

    _totalStakedForFirst = 0;
    _totalStakedForSecond = 0;
    _totalStakedForThird = 0;

    _noFeeFrom[address(this)] = true;
    _noFeeFrom[address(0)] = true;
    _noFeeTo[address(this)] = true;
    _noFeeTo[address(0)] = true;
  
    // _noReward[address(0)] = true;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  function name() external override view returns (string memory) {
    return _name;
  }

  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public override view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function burn(uint256 amount) external returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function mint(uint256 amount) external returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "decreased allowance below zero"));
    return true;
  }
  
  /**
    * Checks if private presale member dont extended limit of possible amount transfer, 
    * depending on yearly quarters.
    *
    * @param sender Address of amount sender.  
    * @param amount Amount of token which sender wants to transfer.
    * 
    * @return boolean If selected amount is transferable
    */ 
  function checkIfBalanceNotFrozen(address sender, uint256 amount, uint256 timestamp) private view returns(bool) {
    if (_privateSaleAmount[sender] > 0) {
      uint256 quarter = (timestamp - airdropEndTime) / 7776000; // 90 days
      if (quarter < 3) {
        uint frozen = _privateSaleAmount[sender] * (3 - quarter) / 4;
        return (balanceOf(sender) - frozen >=  amount);
      }
    }
    return true;
  }

  /**
    * Amount transfer function between 2 addresses after the conditions are met.
    * Conditions: 
    *   1) Sender must not be burn address.
    *   2) Recipient must not be burn address.
    *   3) Amount must be higher then 0.
    *   4) Contract must be in live or sender must be owner or recipient must be the owner.
    *   5) Checks if private presale member dont extended limit of possible amount transfer, 
    *     depending on yearly quarters.
    *   6) Transfer amount must not exceed total balanse of sender.
    *
    * Additionaly only owner can transfer amount before public start date.
    * Fee is separated depending on imposed percentages in addresses 
    * (Development, Fundraising, Liquidity) and goes as reward for holders.
    *
    * @param sender Address of amount sender.  
    * @param recipient Address of amount reciever.
    * @param amount Amount of token which sender wants to transfer. 
    */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "transfer from the zero address");
    require(recipient != address(0), "transfer to the zero address");
    require(amount > 0, "transfer amount must be greater than zero");
    require(_tradingOpen || sender == owner() || recipient == owner());
    require(checkIfBalanceNotFrozen(sender, amount, block.timestamp)); // private sale
    
    if (!_noFeeFrom[sender] && !_noFeeTo[recipient]) {
      uint256 deductTotal = 0;
      deductTotal = deductTotal.add(_deductDevelopmentFund(sender, amount));
      deductTotal = deductTotal.add(_deductLiquidityPool(sender, amount));
      deductTotal = deductTotal.add(_deductReward(sender, amount));
      amount = amount.sub(deductTotal);
    }

    // amount = _addBalanceExcReward(recipient, amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);

    if (sender == owner()) {
      if (!_privateSaleEnded) {
        _privateSaleAmount[recipient] = _privateSaleAmount[recipient].add(amount);
        _totalFrozenAmount = _totalFrozenAmount.add(amount);
        _preSaleMember[recipient] = true;
      } 
    }

    if (_preSaleMember[sender] && (balanceOf(sender) - _privateSaleAmount[sender]) < amount){
      _totalFrozenAmount = _totalFrozenAmount - (amount - (balanceOf(sender) - _privateSaleAmount[sender]));
    }
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "approve from the zero address");
    require(spender != address(0), "approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "burn from the zero address");
    _balances[account] = _balances[account].sub(amount);
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "mint to the zero address");
    _balances[account] += _balances[account].sub(amount);
    _totalSupply += amount;
    
    emit Transfer(address(0), account, amount);
  }

  /**
    * Calculates amount which must be transfered to development address.
    *
    * @param amount Transaction token amount.
    * 
    * @return deductAmount Amount for development address.
    */ 
  function _deductDevelopmentFund(address sender, uint256 amount) private returns(uint256) {
    uint256 deductAmount = amount.mul(_developmentMilipercent).div(100000);
    _balances[_developmentFundsAddress] = _balances[_developmentFundsAddress].add(deductAmount);
    emit Transfer(sender, _developmentFundsAddress, deductAmount);
    return deductAmount;
  }

  /**
    * Calculates amount which must be transfered to liquidity.
    *
    * @param amount Transaction token amount.
    * 
    * @return deductAmount Amount for liquidity.
    */ 
  function _deductLiquidityPool(address sender, uint256 amount) private returns(uint256) {
    uint256 deductAmount = amount.mul(_liquidityMilipercent).div(100000);
    _balances[_liquidityPoolAddress] = _balances[_liquidityPoolAddress].add(deductAmount);
    emit Transfer(sender, _liquidityPoolAddress, deductAmount);
    return deductAmount;
  }
  
  /**
    * Calculates amount which must be transfered to holder rewards.
    *
    * @param amount Transaction token amount.
    * 
    * @return deductAmount Amount for holder rewards.
    */ 
  function _deductReward(address sender, uint256 amount) private returns(uint256) {
    uint256 deductAmount = amount.mul(_rewardMilipercent).div(100000);
    _balances[address(this)] = _balances[address(this)].add(deductAmount);
    emit Transfer(sender, address(this), deductAmount);
    return deductAmount;
  }
  
  /**
    * Interface to set address for development funds.
    *
    * @param account Address for collecting development funds.
    * 
    * @return boolean.
    */
  function setDevelopmentFundsAddress(address account) external onlyOwner returns (bool) {
    _developmentFundsAddress = account;
    return true;
  }

  /**
    * Interface to set address for liquidity pool tokens.
    *
    * @param account Address for collecting liquidity pool tokens.
    * 
    * @return boolean.
    */
  function setLiquidityPoolAddress(address account) external onlyOwner returns (bool) {
    _liquidityPoolAddress = account;
    return true;
  }

  /**
    * Function for checking fee threshold. 
    *  1) Summary of all fees must not exceed 10%.
    *  2) Fee for development funds must not exceed 5%.
    * 
    * @return boolean
    */
  function checkFeeThreshold() private view returns(bool) {
    if (_rewardMilipercent + _developmentMilipercent + _fundRaisingMilipercent + _liquidityMilipercent > 10000) {
      return false;
    }
    if (_developmentMilipercent > 5000) {
      return false;
    }
    return true;
  }

  /**
    * Interface to set fee percentage for rewards.
    * 
    * @param value Percentage in milipercents.
    * 
    * @return boolean
    */
  function setRewardMilipercent(uint256 value) external onlyOwner returns (bool) {
    _rewardMilipercent = value;
    require(checkFeeThreshold());
    return true;
  }

  /**
    * Interface to set fee percentage for development funds.
    * 
    * @param value Percentage in milipercents.
    * 
    * @return boolean
    */
  function setDevelopmentMilipercent(uint256 value) external onlyOwner returns (bool) {
    _developmentMilipercent = value;
    require(checkFeeThreshold());
    return true; 
  }

  /**
    * Interface to set fee percentage for fundraising.
    * 
    * @param value Percentage in milipercents.
    * 
    * @return boolean
    */
  function setFundRaisingMilipercent(uint256 value) external onlyOwner returns (bool) {
    _fundRaisingMilipercent = value;
    require(checkFeeThreshold());
    return true;   
  }

  /**
    * Interface to set fee percentage for liquidity pool.
    * 
    * @param value Percentage in milipercents.
    * 
    * @return boolean
    */
  function setLiquidityMilipercent(uint256 value) external onlyOwner returns (bool) {
    _liquidityMilipercent = value;
    require(checkFeeThreshold());
    return true;
  }


  /**
    * Interface to exclude address from fee during transfer.
    * 
    * @param account Address of sender.
    * @param value Boolean.
    * 
    * @return boolean
    */
  function excludeIncludeFeeFrom(address account, bool value) external onlyOwner returns (bool) {
    _noFeeFrom[account] = value;
    return true;
  }

  /**
    * Interface to exclude address from fee during recieve.
    * 
    * @param account Address of recipient.
    * @param value Boolean.
    * 
    * @return boolean
    */
  function excludeIncludeFeeTo(address account, bool value) external onlyOwner returns (bool) {
    _noFeeTo[account] = value;
    return true;
  }

  /**
    * Add functionality like burn to the _stake afunction
    *
     */
    function stake(uint256 _amount, uint8 stakeType) public {
      // Make sure staker actually is good for it
      require(_amount < _balances[msg.sender], "Cannot stake more than you own");
        uint256 collectedReward = balanceOf(address(this));
        uint256 ccSupply = _totalSupply - _totalFrozenAmount + _totalStakedAmount; //დაგროვილი რევარდი უნდა შედიოდეს?

        uint256 mustClaim = _stake(_amount, collectedReward, stakeType, ccSupply, _applicableContractRewardAmount, totalStackings[stakeType]);
        _applicableContractRewardAmount += mustClaim;
        _totalStakedAmount += _amount;
        totalStackings[stakeType] += _amount;
                // Burn the amount of tokens on the sender
        _burn(msg.sender, _amount);
    }

  
  /**
    * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 stake_index)  public {

      uint256 rootAmount = _rootAmount(stake_index);
      uint256 claimed = _withdrawStake(stake_index);
      uint256 stakeType = stakeTypeByIndex(stake_index);

      totalStackings[stakeType] -= rootAmount;
      _totalStakedAmount -= claimed;
      _applicableContractRewardAmount -= claimed;

      _transfer(address(this), msg.sender, claimed);
      _mint(msg.sender, rootAmount);
    }

  /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        uint256 availableReward;
        uint256 totalReward;
        // Keep a summary in memory since we need to calculate this
        // stakeholders[stakes[_staker]].address_stakes
        StakingSummary memory summary = StakingSummary(0, 0, 0, 0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 i = 0; i < summary.stakes.length; i += 1){
           availableReward = calculateClaimableReward(summary.stakes[i]);
           totalReward = summary.stakes[i].amount + summary.stakes[i].mustClaim;
           summary.total_count += 1;  // Increment stake quantity
           summary.claimable_amount += availableReward;  // Total Claimable reward for staker
           summary.total_reward += totalReward;  // Total cumulated reward for staker
           totalStakeAmount = totalStakeAmount + summary.stakes[i].amount;  // Total stake amount user made
       }
       // Assign calculate amount to summary
       summary.total_amount = totalStakeAmount;
      return summary;
    }


  function endPrivateSale() public onlyOwner returns (bool){
    _privateSaleEnded = true;
    privateSaleEndTime = block.timestamp;
    return true;
  }

  function endAirdrop() public onlyOwner returns (bool){
    _tradingOpen = true;
    airdropEndTime = block.timestamp;
    return true;
  }

  function setPartsForStackTypes(uint32 first, uint32 second, uint32 third) public onlyOwner returns (bool){
    require (first + second + third <= 100000);
    bool set = _setPartsForStackTypes(first, second, third);
    return set;
  }

  function circulatingSupply() public view returns(uint256){
    uint256 ccSupply = _totalSupply - _totalFrozenAmount;
    return ccSupply;
  }
    
}