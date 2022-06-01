/**
 *Submitted for verification at BscScan.com on 2022-06-01
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

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Stakeable {
  
  /*-------- Staking algorithm percentages --------*/
  uint256 public _firstTypePartFromBalance  = 10000;
  uint256 public _secondTypePartFromBalance = 30000;
  uint256 public _thirdTypePartFromBalance  = 60000;

  uint256 public _firstTypeAssumption   = 6000;
  uint256 public _secondTypeAssumption  = 3000;
  uint256 public _thirdTypeAssumption   = 1000;  

  /*-------- Durations of staking in days --------*/
  uint16 public _firstStakeTypeDuration   = 7;
  uint16 public _secondtStakeTypeDuration = 28;
  uint16 public _thirdStakeTypeDuration   = 168;

  /*-------- Stake Types are used to map all information --------*/
  mapping (uint256 => uint256) public stakeAssumption;
  mapping (uint256 => uint256) public stakePart;
  mapping (uint256 => uint256) public minimumAssumption;
  mapping (uint256 => uint256) public cumulatedStakings;

  uint32 dayInSeconds = 5;

    constructor() {
      stakeholders.push();

      stakeAssumption[1] = _firstTypeAssumption;
      stakeAssumption[2] = _secondTypeAssumption;
      stakeAssumption[3] = _thirdTypeAssumption;

      stakePart[1] = _firstTypePartFromBalance;
      stakePart[2] = _secondTypePartFromBalance;
      stakePart[3] = _thirdTypePartFromBalance;

      minimumAssumption[1] = _firstTypeAssumption;
      minimumAssumption[2] = _secondTypeAssumption;
      minimumAssumption[3] = _thirdTypeAssumption;
    }
    
    /**
      * @notice
      * The way we store stakes is represented by a stake struct.
      *
      * @param user           Stakeholder's address
      * @param amount         Amount staked by the user
      * @param since          When the staking started, this is the timestamp
      * @param milliPercent   In millipercents, how much is staker awarded
      * @param stakeType      The user decides which stake to use
      * @param mustClaim      The total number of tokens that must be claimed
      */
      struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 milliPercent;
        uint8   stakeType;
        uint256 mustClaim;
    }

    /**
      * @notice A stakeholder who has active stakes is referred to as a stakeholder.
      *
      * @param user               Stakeholder's address
      * @param address_stakes     All stakes are placed under this address
      */
      struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    /**
      * @notice
      * StakingSummary is a struct that is used to contain all stakes performed by a certain account
      *
      * @param total_amount       Total staked amount by a certain user.
      * @param total_count        How many stakes user have.
      * @param total_reward       How many rewards user must have.
      * @param claimable_amount   How many BNN is already claimable by user.
      * @param stakes             All stake informations under this address, taken from Struct @param Stake
      */ 
      struct StakingSummary{
        uint256 total_amount;   
        uint256 total_count;    
        uint256 total_reward;   
        uint256 claimable_amount;
        Stake[] stakes;
    }

    /**
      * @notice 
      * This is an array where we keep track of all the stakes that are made on the Contract.
      * Each address's stakes are stored in a specific index, which may be retrieved using the stakes mapping.
      *
      */
    Stakeholder[] internal stakeholders;

    /**
      * @notice 
      * In the stakes array, stakes is utilized to keep track of the INDEX for the stakers.
      */
    mapping(address => uint256) internal stakes;
    
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp, uint256 milliPercent, uint256 mustClaim);

    
    /**
      * @notice This function adds a stakeholder to the stakeholders array.
      *
      * @param staker       Stakeholder's address
      *
      * @return userIndex   This stake's index in the stakeholders array
      */
      function _addStakeholder(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
      * @notice
      * This function generates a stake with dynamically changing percentages for the recipient.
      * It will deduct the staked amount from the staker's account and deposit the staked tokens in a stake container (stakebale contract).
      * 
      * @param _amount            The amount of a token that the sender wishes to stake.
      * @param collectedReward    Total reward amount accumulated in contract.
      * @param stakeType          Stake type
      * @param ccSupply           The total number of tokens that can possibly be staked in the contract.
      * @param usedReward         The total number of tokens accumulated in the contract, which must be used for each past stake.
      * @param to                 The user's address for whom the sender is staking tokens.
      *
      * @return mustClaim         The total number of tokens that must be awarded to the recipient.
      */
      function _stake(uint256 _amount, uint256 collectedReward, uint8 stakeType, uint256 ccSupply, uint256 usedReward, address to) internal returns (uint256) {
        require(stakeType >= 1 && stakeType <=3, "Wrong type for staking");
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[to];
        uint256 timestamp = block.timestamp;

        if(index == 0){
            index = _addStakeholder(to);
        }

        uint256 milliPercentOfUser;
        uint256 mustClaim;
        uint256 temporraryAssumption;
        bool    limitReached;

        if (ccSupply * stakeAssumption[stakeType] / 100000 < (cumulatedStakings[stakeType] + _amount)) {
          temporraryAssumption =  (cumulatedStakings[stakeType] + _amount) * 100000 / ccSupply;
          limitReached = thresholdStakeAssumptions(stakeType, temporraryAssumption);
          if (!limitReached){
            stakeAssumption[stakeType] =  (cumulatedStakings[stakeType] + _amount) * 100000 / ccSupply;
          }
        }
        milliPercentOfUser = ((collectedReward - usedReward) * stakePart[stakeType]) * 100000 / (ccSupply * stakeAssumption[stakeType]);
        mustClaim = _amount * milliPercentOfUser / 100000;

        stakeholders[index].address_stakes.push(Stake(to, _amount, timestamp, milliPercentOfUser, stakeType, mustClaim));
     
        emit Staked(to, _amount, index, timestamp, milliPercentOfUser, mustClaim);

        return mustClaim;
    }

    /**
      * @notice
      * For each stake type, this validation function checks the temporary assumption limits. 
      * When the limit is reached, all assumptions are reset to fixed values.
      * 
      * @param stakeType              Stake type
      * @param temporraryAssumption   Represents the percentage of the requested amount for staking supply.
      *
      * @return limitReached          If the limit has been reached or not, a boolean indicator will be returned.
      */
      function thresholdStakeAssumptions(uint256 stakeType, uint256 temporraryAssumption) internal returns (bool) {
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

    /**
      * @notice
      * This is an internal function that adjusts the stake assumptions.
      * 
      * @param first    Assumption related the first stake type
      * @param second   Assumption related the second stake type
      * @param third    Assumption related the third stake type
      */
      function saveAssumptions(uint64 first, uint64 second, uint64 third) internal {
        stakeAssumption[1] = first;
        stakeAssumption[2] = second;
        stakeAssumption[3] = third;
    }

    /**
      * @notice
      * This function determines how much a user can claim for their stakes already.
      * 
      * @param _current_stake    Array of user's stake
      *
      * @return claimableReward  Total number of tokens that can be claimed for a certain stake
      */
      function calculateClaimableReward(Stake memory _current_stake) internal view returns(uint256){
        uint256 claimableReward;
        uint256 daysPassed = (block.timestamp - _current_stake.since) / dayInSeconds;

        if (_current_stake.stakeType == 1 && daysPassed < _firstStakeTypeDuration) return 0;
        if (_current_stake.stakeType == 2 && daysPassed < _secondtStakeTypeDuration) return 0;
        if (_current_stake.stakeType == 3 && daysPassed < _thirdStakeTypeDuration) return 0;
  
        claimableReward = _current_stake.amount * _current_stake.milliPercent / 100000;
        return claimableReward;
    }

    /**
      * @notice
      * After claiming the award, this function deletes a specific stake.
      * 
      * @param index    Index of the stake
      */
      function deleteStakeholdersStake(uint256 index) internal {
        uint256 user_index = stakes[msg.sender];
        delete stakeholders[user_index].address_stakes[index];
    }

    /**
      * @notice
      * For each form of stake, this function sets the percentage dividends.
      * 
      * @param first    Divident for first stake type
      * @param second   Divident for second stake type
      * @param third    Divident for third stake type
      *
      * @return bool  After a successful process, it returns true.
      */
      function _setPartsForStakeTypes(uint32 first, uint32 second, uint32 third) internal returns(bool) {
        stakePart[1] = first;
        stakePart[2] = second;
        stakePart[3] = third;
        return true;
    }

    /**
      * @notice
      * With specific threshold validations, this function modifies stake assumptions.
      * 
      * @param stakeType    Type of the stake
      * @param newPercent   New assumption percentage
      */
      function updateStakingMillipercent(uint256 stakeType, uint256 newPercent) internal {
        if (minimumAssumption[stakeType] > newPercent) {
          stakeAssumption[stakeType] = minimumAssumption[stakeType];
        }else stakeAssumption[stakeType] = newPercent;
    }

    /**
      * @notice
      * This function raises the total stakes for each kind.
      * 
      * @param stakeType    Type of the stake
      * @param amount       The amount that has to be added.
      */
      function increaseCumulatedStakings(uint256 stakeType, uint256 amount) internal {
        cumulatedStakings[stakeType] += amount;
    }

    /**
      * @notice
      * This function decreases the total stakes for each kind.
      * 
      * @param stakeType    Type of the stake
      * @param amount       The amount that has to be substracted.
      */
      function decreaseCumulatedStakings(uint256 stakeType, uint256 amount) internal {
        cumulatedStakings[stakeType] -= amount;
    }
}


contract TesT123 is Context, IERC20, Ownable, Stakeable {
  using SafeMath for uint256;

  mapping (address => uint256)  private _balances;
  mapping (address => bool)     public _noFeeFrom;
  mapping (address => bool)     public _noFeeTo;
  mapping (address => uint256)  public _privateSaleAmount;
  mapping (address => bool)     public _preSaleMember;
  mapping (address => uint256)  public _addressFrozenAmount;

  mapping (address => mapping (address => uint256)) private _allowances;

  bool public _tradingOpen;
  bool public _privateSaleEnded;
  bool public _deploymentOwnershipTransfered;
  bool public _feeManipulation;
  
  uint256 public privateSaleEndTime;
  uint256 public tradingOpenTime;

  uint256 public _totalFrozenAmount;
  uint256 public _totalStakedAmount;
  uint256 public _applicableContractRewardAmount;
  
  uint256 private _totalSupply;
  uint8   private _decimals;
  string  private _symbol;
  string  private _name;

  address public _developmentFundsAddress;
  uint256 public _liquidityPairQuantity = 0;

  uint256 public _rewardMillipercent = 4000;
  uint256 public _developmentMillipercent = 6000;

  uint256 public _totalStakedForFirst;
  uint256 public _totalStakedForSecond;
  uint256 public _totalStakedForThird;

  mapping (uint256 => uint256) public totalStakings;
  mapping (uint256 => address) public liquidityPairs;
  mapping (address => uint256) public lastStakeTime;
  

  constructor() {
    _name = "TesT123";
    _symbol = "TST";
    _decimals = 9;
    _totalSupply = 10**9 * 10**9;
    _balances[msg.sender] = _totalSupply;
    _developmentFundsAddress = msg.sender;

    _tradingOpen = false;
    _privateSaleEnded = false;
    _deploymentOwnershipTransfered = false;
    _feeManipulation = true;

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

  function transferOwnership(address newOwner) public onlyOwner {
    _deploymentOwnershipTransfered = true;
    _transferOwnership(newOwner);
  }

  /**
    * @notice
    * This is an internal function that serves only one purpose. To restore previously burned tokens for the user during stake.
    */ 
    function _mint(address account, uint256 amount) internal {
      require(account != address(0), "mint to the zero address");
      _balances[account] = _balances[account].add(amount);
      _totalSupply += amount;
      
      emit Transfer(address(0), account, amount);
  }
  
  /**
    * @notice
    * Checks if a private presale member hasn't over the maximum amount that can be transferred, based on the year's quarters.
    *
    * @param sender     The sender's address   
    * @param amount     The amount of tokens that the sender wishes to send.
    * 
    * @return boolean   If the amount chosen is transferrable
    */ 
    function checkIfBalanceNotFrozen(address sender, uint256 amount, uint256 timestamp) private view returns(bool) {
      if (_privateSaleAmount[sender] > 0) {
        uint256 quarter = (timestamp - tradingOpenTime) / 1800; // 90 days
        if (quarter < 3) {
          uint frozen = _privateSaleAmount[sender] * (3 - quarter) / 4;
          return (balanceOf(sender) - frozen >=  amount);
        }
      }
      return true;
  }

  /**
    * @notice
    * Checks the amount of tokens that has been frozen at a specific address.
    *
    * @param sender     The sender's address   
    * 
    * @return frozen    If the amount chosen is transferrable
    */ 
    function addressFrozenAmount(address sender) public view returns(uint256){
      if (_privateSaleAmount[sender] > 0) {
        uint256 quarter = (block.timestamp - tradingOpenTime) / 1800;
        if (quarter < 3) {
          uint256 frozen = _privateSaleAmount[sender] * (3 - quarter) / 4;
          return frozen;
        }
      }
      return 0;
  }

  /**
    * @notice
    * Calculates total amount of frozen tokens.
    * 
    * @return frozen    Total amount of frozen tokens.
    */ 
    function totalFrozenAmount() public view returns (uint256){
      if (_tradingOpen) {
        uint256 quarter = (block.timestamp - tradingOpenTime) / 1800; // 90 days
        if (quarter < 3) {
          uint256 frozen = _totalFrozenAmount * (3 - quarter) / 4;
          return frozen;
        }
        return 0;
      }
      return 0;
  }

  /**
    * @notice
    * After the following conditions are met, a transfer function between two addresses is performed:
    * 1. If the sender or recipient is not the owner, trading must be open.
    * 2. For private presale members, the transferable amount must not be frozen.
    *
    * All transactions are initiated as private presale transfers until private presale ends, 
    * which means that 3/4 of the transferred money will be locked. Every quarter of the year, a new 1/4 of amount will unlock.
    *
    * @param sender     Address of amount sender.  
    * @param recipient  Address of amount reciever.
    * @param amount     Amount of token which sender wants to transfer. 
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
      require(sender != address(0), "transfer from the zero address");
      require(recipient != address(0), "transfer to the zero address");
      require(amount > 0, "transfer amount must be greater than zero");
      require(_tradingOpen || sender == owner() || recipient == owner());
      require(checkIfBalanceNotFrozen(sender, amount, block.timestamp));
      // totalFrozenAmount();
      
      if (!_noFeeFrom[sender] && !_noFeeTo[recipient]) {
        uint256 deductTotal = 0;
        deductTotal = deductTotal.add(_deductDevelopmentFund(sender, amount));
        deductTotal = deductTotal.add(_deductReward(sender, amount));
        amount = amount.sub(deductTotal);
      }

      _balances[recipient] = _balances[recipient].add(amount);
      _balances[sender] = _balances[sender].sub(amount);
      emit Transfer(sender, recipient, amount);

      if (sender == owner() && !_privateSaleEnded && _deploymentOwnershipTransfered) {
          _privateSaleAmount[recipient] = _privateSaleAmount[recipient].add(amount);
          _addressFrozenAmount[recipient] = _addressFrozenAmount[recipient].add(amount * 3 / 4);
          _totalFrozenAmount = _totalFrozenAmount.add(amount);
          _preSaleMember[recipient] = true;
      }

      if (_preSaleMember[sender] && (balanceOf(sender) - _addressFrozenAmount[sender]) < amount){
        // _totalFrozenAmount = _totalFrozenAmount - (amount - (balanceOf(sender) - _addressFrozenAmount[sender]));
        _addressFrozenAmount[sender] = _addressFrozenAmount[sender] - (amount - (balanceOf(sender) - _addressFrozenAmount[sender]));
      }
  }

  /**
    * @notice
    * Calculates amount which must be transfered to development address.
    *
    * @param amount Transaction token amount.
    * 
    * @return deductAmount Amount for development address.
    */ 
    function _deductDevelopmentFund(address sender, uint256 amount) private returns(uint256) {
      uint256 deductAmount = amount.mul(_developmentMillipercent).div(100000);
      _balances[_developmentFundsAddress] = _balances[_developmentFundsAddress].add(deductAmount);
      _balances[sender] = _balances[sender].sub(deductAmount);
      emit Transfer(sender, _developmentFundsAddress, deductAmount);
      return deductAmount;
  }
  
  /**
    * @notice
    * Calculates amount which must be transfered to contract for staking rewards.
    *
    * @param amount Transaction token amount.
    * 
    * @return deductAmount Amount for holder rewards.
    */ 
    function _deductReward(address sender, uint256 amount) private returns(uint256) {
      uint256 deductAmount = amount.mul(_rewardMillipercent).div(100000);
      _balances[address(this)] = _balances[address(this)].add(deductAmount);
      _balances[sender] = _balances[sender].sub(deductAmount);
      emit Transfer(sender, address(this), deductAmount);
      return deductAmount;
  }
  
  /**
    * @notice
    * Interface to set address for development funds.
    *
    * @param account Address for collecting development funds
    * 
    * @return boolean.
    */
    function setDevelopmentFundsAddress(address account) external onlyOwner returns (bool) {
      require(!_tradingOpen, "Trading already started");
      _developmentFundsAddress = account;
      return true;
  }

  /**
    * @notice
    * Sets the liquidity pair addresses for calculating the amount of tokens in liquidity.
    *
    * @param account Liquidity pair address
    * 
    * @return boolean.
    */
    function addLiquidityPairAddress(address account) external onlyOwner returns (bool) {
      for (uint256 i = 1; i <= _liquidityPairQuantity; i += 1){
        if (liquidityPairs[i] == account) return false;
      }
      liquidityPairs[_liquidityPairQuantity + 1] = account;
      _liquidityPairQuantity += 1;
      
      return true;
  }

  /**
    * @notice
    * Function to calculate total amount of tokens circulating in liquidity.
    *
    * @return totalTokens Total amount of tokens circulating in liquidity.
    */
    function totalLiquidityTokens() private view returns (uint256) {
      uint256 totalTokens;
      for (uint256 i = 1; i <= _liquidityPairQuantity; i += 1){
        totalTokens += balanceOf(liquidityPairs[i]);
      } 
      return totalTokens;
  }


  /**
    * @notice
    * Function for checking fee threshold. 
    * Summary of all fees must not exceed 10%.
    * 
    * @return boolean
    */
    function checkFeeThreshold() private view returns(bool) {
      if (_rewardMillipercent + _developmentMillipercent > 10000) {
        return false;
      }
      return true;
  }

  /**
    * @notice
    * Interface to set fee percentage for staking rewards.
    * 
    * @param value Percentage in millipercents.
    * 
    * @return boolean
    */
    function setRewardMilipercent(uint256 value) external onlyOwner returns (bool) {
      _rewardMillipercent = value;
      require(checkFeeThreshold());
      return true;
  }

  /**
    * @notice
    * Interface to set fee percentage for development funds.
    * 
    * @param value Percentage in millipercents.
    * 
    * @return boolean
    */
    function setDevelopmentMilipercent(uint256 value) external onlyOwner returns (bool) {
      _developmentMillipercent = value;
      require(checkFeeThreshold());
      return true; 
  }

  /**
    * @notice
    * Interface for excluding address from fee when sending.
    * 
    * @param account Address of sender.
    * @param value Boolean.
    * 
    * @return boolean
    */
    function excludeIncludeFeeFrom(address account, bool value) external onlyOwner returns (bool) {
      if (_feeManipulation) {
        _noFeeFrom[account] = value;
        return true;
      }else {
        if (_noFeeFrom[account] && value == false){
          _noFeeFrom[account] = value;
          return true;
        }
        else return false;
      }
  }

  /**
    * @notice
    * Interface for excluding the address from the fee during receipt.
    * 
    * @param account Address of recipient.
    * @param value Boolean.
    * 
    * @return boolean
    */
    function excludeIncludeFeeTo(address account, bool value) external onlyOwner returns (bool) {
      if (_feeManipulation) {
        _noFeeTo[account] = value;
        return true;
      }else {
        if (_noFeeTo[account] && value == false){
          _noFeeTo[account] = value;
          return true;
        }
        else return false;
      }
  }

  /**
    * @notice
    * Function to stop functions excludeIncludeFeeFrom() and excludeIncludeFeeTo().
    * 
    * @return boolean
    */
    function removeFeeManipulation() external onlyOwner returns (bool){
      _feeManipulation = false;
      return true;
  }

  /** 
    * @notice
    * After the following conditions are met, the user can stake a certain amount of tokens:
    * 1. Trading must be allowed.
    * 2. The amount cannot be frozen.
    * 3. A minimum of 100 tokens must be staked.
    * 4. User can stake once in every 10 minutes.
    *
    * After the user stakes, the specified amount will be burned from the user's address.
    *
    * @param _amount      The amount the user wishes to stake.
    * @param to           Address of the user who will own this stake.
    * @param stakeType    Type of stake. 
    */
    function stake(uint256 _amount, address to, uint8 stakeType) public {
      require(_tradingOpen, "Staking isn't started yet");
      require(_amount < _balances[msg.sender], "Cannot stake more than you own");
      require(_amount > 100 * 10**_decimals, "Minimum amount for staking is 100 BNN");
      require(block.timestamp - lastStakeTime[msg.sender] > 60, "You can stake once in every 10 minutes");
      uint256 totalFrozen = totalFrozenAmount();
      
      if (_preSaleMember[msg.sender]){
        uint256 frozen = addressFrozenAmount(msg.sender);
        require(_amount < _balances[msg.sender] - frozen, "Cannot stake frozen amount");
      }

      uint256 collectedReward = balanceOf(address(this));
      uint256 liquidityTokens = totalLiquidityTokens();
      uint256 ccSupply = _totalSupply + _totalStakedAmount - totalFrozen - liquidityTokens - collectedReward;

      uint256 mustClaim = _stake(_amount, collectedReward, stakeType, ccSupply, _applicableContractRewardAmount, to);
      _applicableContractRewardAmount += mustClaim;
      _totalStakedAmount += _amount;
      totalStakings[stakeType] += _amount;
      increaseCumulatedStakings(stakeType, _amount);
      lastStakeTime[msg.sender] = block.timestamp;

      _burn(msg.sender, _amount);
  }

  /** 
    * @notice
    * After the following conditions are met, the user can witdraw all claimable tokens:
    * 1. Trading must be allowed.
    * 2. Claimable amount must be higher then 0.
    *
    * When the conditions are met, already burned tokens during stake function will be minted.
    * Claimable tokens will be transfered from contract address.
    * All used stake will be deleted and percentage assumptions for each stake type will be fixed.
    *
    */
    function withdrawAll() public {
      require(_tradingOpen, "Staking isn't started yet");

      uint256 totalStakeAmount; 
      uint256 availableReward;
      uint256 stakeReward;

      StakingSummary memory withdrawable = StakingSummary(0, 0, 0, 0, stakeholders[stakes[msg.sender]].address_stakes);
      for (uint256 i = 0; i < withdrawable.stakes.length; i += 1){
        stakeReward = calculateClaimableReward(withdrawable.stakes[i]);
        availableReward += stakeReward;
        if (stakeReward > 0){
          totalStakeAmount = totalStakeAmount + withdrawable.stakes[i].amount;

          totalStakings[withdrawable.stakes[i].stakeType] -= withdrawable.stakes[i].amount;
          decreaseCumulatedStakings(withdrawable.stakes[i].stakeType, withdrawable.stakes[i].amount);
          _totalStakedAmount -= withdrawable.stakes[i].amount;
          _applicableContractRewardAmount -= stakeReward;

          deleteStakeholdersStake(i);
        }
      }

      _transfer(address(this), msg.sender, availableReward);
      _mint(msg.sender, totalStakeAmount);
      
      uint256 totalFrozen = totalFrozenAmount();
      uint256 collectedReward = balanceOf(address(this));
      uint256 liquidityTokens =  totalLiquidityTokens();
      uint256 afterccSupply = _totalSupply + _totalStakedAmount - totalFrozen - liquidityTokens - collectedReward;
      for (uint256 j = 1; j < 4; j += 1){
        uint256 newPercent = totalStakings[j] * 100000 / afterccSupply;
        updateStakingMillipercent(j, newPercent);
      }
  }

  /**
    * @notice
    * This function is used to determine whether or not an account has stakes, as well as the total amount and all individual stakes.
    *
    * @param _staker Address of staker
    *
    * @return summary All information about address stakes.
    */
    function hasStake(address _staker) public view returns(StakingSummary memory){
        uint256 totalStakeAmount; 
        uint256 availableReward;
        uint256 totalReward;

        StakingSummary memory summary = StakingSummary(0, 0, 0, 0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 i = 0; i < summary.stakes.length; i += 1){
           availableReward = calculateClaimableReward(summary.stakes[i]);
           totalReward = summary.stakes[i].amount + summary.stakes[i].mustClaim;
           summary.total_count += 1;                                        // Increment stake quantity
           summary.claimable_amount += availableReward;                     // Total Claimable reward for staker
           summary.total_reward += totalReward;                             // Total cumulated reward for staker
           totalStakeAmount = totalStakeAmount + summary.stakes[i].amount;  // Total stake amount user made
        }

        summary.total_amount = totalStakeAmount;
      return summary;
  }

  /**
    * @notice
    * This function ends private presale, which means the transferred funds in future are no longer frozen.
    */
    function endPrivateSale() public onlyOwner returns (bool){
      _privateSaleEnded = true;
      privateSaleEndTime = block.timestamp;
      return true;
  }

  /**
    * @notice
    * This function opens trading.
    */
    function startTrading() public onlyOwner returns (bool){
      _tradingOpen = true;
      tradingOpenTime = block.timestamp;
      return true;
  }

  /**
    * @notice
    * For Each stake type an interface to set their parts from a stakable supply.
    */
    function setPartsForStakeTypes(uint32 first, uint32 second, uint32 third) public onlyOwner returns (bool){
      require (first + second + third <= 100000);
      bool set = _setPartsForStakeTypes(first, second, third);
      return set;
  }

  /**
    * @notice
    * Function which provides real circulating supply. Without frozen tokens.
    */
    function circulatingSupply() public view returns(uint256){
      uint256 totalFrozen = totalFrozenAmount();
      uint256 ccSupply = _totalSupply - totalFrozen;
      return ccSupply;
  }    
}