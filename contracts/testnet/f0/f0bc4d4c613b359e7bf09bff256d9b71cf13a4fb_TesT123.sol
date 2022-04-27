/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.7;
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

    uint256 internal rewardPerHour = 1000;

    /**
    * @notice Constructor since this contract is not ment to be used without inheritance
    * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
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
        // This claimable field is used to tell how big of a reward is currently available
        uint256 claimable;
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
        uint256 total_amount;
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
     event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

    
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
    function _stake(uint256 _amount) internal{
        // Simple check so that user does not stake 0 
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

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, 0));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    /**
      * @notice
      * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
      * and the duration the stake has been active
     */
      function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
          // First calculate how long the stake has been active
          // Use current seconds since epoch - the seconds since epoch the stake was made
          // The output will be duration in SECONDS ,
          // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
          // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
          // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
          // we then multiply each token by the hours staked , then divide by the rewardPerHour rate 
          return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
      }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to transfer into the acount
     * Will also calculateStakeReward and reset timer
    */
     function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
         // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

         // Calculate available Reward first before we start modifying data
         uint256 reward = calculateStakeReward(current_stake);
         // Remove by subtracting the money unstaked 
         current_stake.amount = current_stake.amount - amount;
         // If stake is empty, 0, then remove it from the array of stakes
         if(current_stake.amount == 0){
             delete stakeholders[user_index].address_stakes[index];
         }else {
             // If not empty then replace the value of it
             stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
             // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
         }

         return amount+reward;

     }

}


contract TesT123 is Context, IERC20, Ownable, Stakeable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  // mapping (address => bool) private _noReward;
  mapping (address => bool) private _noFeeFrom;
  mapping (address => bool) private _noFeeTo;
  mapping (address => uint256) private _privateSaleAmount;
  mapping (address => bool) private _preSaleMamber;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _totalReward;
  uint256 private _totalNoReward;
  uint256 private _rewardCumulation;
  // uint256 private _rewardCumulationTime;
  uint256 private _lastRewardCumulationTime;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address public _developmentFundsAddress;
  address public _fundRaisingAddress;
  address public _liquidityPoolAddress;

  uint256 public _privateSaleStartTime;
  uint256 public _preSaleStartTime;
  uint256 public _publicStartTime;

  uint256 public _rewardMilipercent = 3000;
  uint256 public _developmentMilipercent = 3000;
  uint256 public _fundRaisingMilipercent = 1000;
  uint256 public _liquidityMilipercent = 3000;

  //Stacking Parameters
 

  uint256 public _firstTypeStackingMiliPercent = 1000;
  uint256 public _secondTypeStackingMiliPercent = 2000;
  uint256 public _thirdTypeStackingMiliPercent = 5000;

  constructor() {
    _name = "TesT123";
    _symbol = "ASA";
    _decimals = 9;
    _totalSupply = 10**15 * 10**9;
    _totalReward = 0;
    _totalNoReward = 0;
    _rewardCumulation = 0;
    // _rewardCumulationTime = 0;
    _lastRewardCumulationTime = block.timestamp;
    _balances[msg.sender] = _totalSupply;
    _developmentFundsAddress = msg.sender;
    _fundRaisingAddress = msg.sender;
    _liquidityPoolAddress = msg.sender;
    _privateSaleStartTime = block.timestamp;
    _preSaleStartTime = _privateSaleStartTime + 30 * 86400;
    _publicStartTime = _preSaleStartTime + 30 * 86400;
  
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
    * Calculates fee depending on public sale start time for presale members.
    *
    * @param sender Address of amount sender.   
    * 
    * @return Calculated fee for presale member.
    */ 
  function totalFeeMultiplierForSender(address sender, uint256 timestamp) private view returns(uint256) {
    if (_preSaleMamber[sender]) {
      uint256 publicSaleFeeEnds = _publicStartTime + 20 * 86400; // 20 days
      if (timestamp < publicSaleFeeEnds) {
        return 10 + (publicSaleFeeEnds - timestamp) / 86400; // 10 + ramaining days %
      }
    }
    return 10;
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
      uint256 quarter = (timestamp - _publicStartTime) / 7776000; // 90 days
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
    require(block.timestamp >= _publicStartTime || sender == owner() || recipient == owner());
    require(checkIfBalanceNotFrozen(sender, amount, block.timestamp)); // private sale
    
    if (!_noFeeFrom[sender] && !_noFeeTo[recipient]) {
      uint256 deductTotal = 0;
      uint256 totalFeeMultiplier = totalFeeMultiplierForSender(sender, block.timestamp); // presale
      deductTotal = deductTotal.add(_deductDevelopmentFund(sender, amount, totalFeeMultiplier));
      deductTotal = deductTotal.add(_deductFundRaising(sender, amount, totalFeeMultiplier));
      deductTotal = deductTotal.add(_deductLiquidityPool(sender, amount, totalFeeMultiplier));
      deductTotal = deductTotal.add(_deductReward(sender, amount, totalFeeMultiplier));
      amount = amount.sub(deductTotal);
    }

    // amount = _addBalanceExcReward(recipient, amount);
    emit Transfer(sender, recipient, amount);

    if (sender == owner() && block.timestamp < _publicStartTime) {
      if (block.timestamp < _preSaleStartTime) {
         _privateSaleAmount[recipient] = _privateSaleAmount[recipient].add(amount);
      } else {
        _preSaleMamber[recipient] = true;
      }
    }
    
    // if (_lastRewardCumulationTime + _rewardCumulationTime <= block.timestamp) {
    //   _lastRewardCumulationTime = _lastRewardCumulationTime + _rewardCumulationTime;
      _totalReward = _totalReward + _rewardCumulation;
      _rewardCumulation = 0;   
    // } 
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "approve from the zero address");
    require(spender != address(0), "approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "burn from the zero address");

    // amount = _addBalanceExcReward(address(0), _deductBalanceIncReward(account, amount));

    emit Transfer(account, address(0), amount);
  }

  /**
    * Calculates amount which must be transfered to development address.
    *
    * @param amount Transaction token amount.
    * @param totalFeeMultiplier Coefficient for adjusting presale fee. 
    * 
    * @return deductAmount Amount for development address.
    */ 
  function _deductDevelopmentFund(address sender, uint256 amount, uint256 totalFeeMultiplier) private returns(uint256) {
    uint256 deductAmount = amount.mul(_developmentMilipercent).mul(totalFeeMultiplier).div(1000000);
    emit Transfer(sender, _developmentFundsAddress, deductAmount);
    return deductAmount;
  }

  /**
    * Calculates amount which must be transfered to fundraising address.
    *
    * @param amount Transaction token amount.
    * @param totalFeeMultiplier Coefficient for adjusting presale fee. 
    * 
    * @return deductAmount Amount for fundraising address.
    */ 
  function _deductFundRaising(address sender, uint256 amount, uint256 totalFeeMultiplier) private returns(uint256) {
    uint256 deductAmount = amount.mul(_fundRaisingMilipercent).mul(totalFeeMultiplier).div(1000000);
    emit Transfer(sender, _fundRaisingAddress, deductAmount);
    return deductAmount;
  }

  /**
    * Calculates amount which must be transfered to liquidity.
    *
    * @param amount Transaction token amount.
    * @param totalFeeMultiplier Coefficient for adjusting presale fee. 
    * 
    * @return deductAmount Amount for liquidity.
    */ 
  function _deductLiquidityPool(address sender, uint256 amount, uint256 totalFeeMultiplier) private returns(uint256) {
    uint256 deductAmount = amount.mul(_liquidityMilipercent).mul(totalFeeMultiplier).div(1000000);
    emit Transfer(sender, _liquidityPoolAddress, deductAmount);
    return deductAmount;
  }
  
  /**
    * Calculates amount which must be transfered to holder rewards.
    *
    * @param amount Transaction token amount.
    * @param totalFeeMultiplier Coefficient for adjusting presale fee. 
    * 
    * @return deductAmount Amount for holder rewards.
    */ 
  function _deductReward(address sender, uint256 amount, uint256 totalFeeMultiplier) private returns(uint256) {
    uint256 deductAmount = amount.mul(_rewardMilipercent).mul(totalFeeMultiplier).div(1000000);
    _rewardCumulation = _rewardCumulation.add(deductAmount);
    emit Transfer(sender, address(this), deductAmount);
    return deductAmount;
  }
  
  /**
    * Inteface to add reward to balance.
    *
    * @param amount Balance without reward.
    * 
    * @return Balance amount including reward.
    */ 
  // function _incReward(uint256 amount) private view returns(uint256) {
  //    return amount * (_totalSupply - _totalNoReward) / (_totalSupply - _totalNoReward - _totalReward);
  // }


  /**
    * Inteface to deduct reward from balance.
    *
    * @param amount Balance including reward.
    * 
    * @return Balance amount excluding reward.
    */ 
  // function _excReward(uint256 amount) private view returns(uint256) {
  //    return amount * (_totalSupply - _totalNoReward - _totalReward) / (_totalSupply - _totalNoReward);
  // }

  /**
    * Interface to get balance amount including reward.
    *
    * @param account Address of user.
    * 
    * @return Balance amount including reward.
    */ 
  // function _getBalanceIncReward(address account) private view returns(uint256) {
  //   if (!_noReward[account]) {
  //     return _incReward(_balances[account]);
  //   }
  //   return _balances[account];
  // }
  
  /**
    * Interface to deduct amount from address considering reward.
    *
    * @param account Address of user.
    * @param amount Amount of tokens including reward.
    * 
    * @return Deducted tokens excluding reward.
    */
  // function _deductBalanceIncReward(address account, uint256 amount) private returns(uint256) {
  //   if (!_noReward[account]) {
  //     amount = _excReward(amount);
  //     _balances[account] = _balances[account].sub(amount, "transfer amount exceeds balance");
  //     return amount;
  //   } else {
  //     _balances[account] = _balances[account].sub(amount, "transfer amount exceeds balance");
  //     _totalReward = _totalReward + amount * _totalReward / (_totalSupply - _totalNoReward);
  //     _totalNoReward = _totalNoReward.sub(amount);
  //     return _excReward(amount);
  //   }
  // }
  
  /**
    * Interface to add amount to address excluding reward.
    *
    * @param account Address of user.
    * @param amount Amount of tokens excluding rewards.
    * 
    * @return Add tokens including reward.
    */
  // function _addBalanceExcReward(address account, uint256 amount) private returns(uint256) {
  //   if (!_noReward[account]) {
  //     _balances[account] = _balances[account].add(amount);
  //     amount = _incReward(amount);
  //   } else {
  //     amount = _incReward(amount);
  //     _totalReward = _totalReward.sub(amount * _totalReward / (_totalSupply - _totalNoReward));
  //     _totalNoReward = _totalNoReward + amount;
  //     _balances[account] = _balances[account].add(amount);
  //   }
  //   return amount;
  // }

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
    * Interface to set address for fundraising tokens.
    *
    * @param account Address for collecting fundraising tokens.
    * 
    * @return boolean.
    */
  function setFundRaisingAddress(address account) external onlyOwner returns (bool) {
    _fundRaisingAddress = account;
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
    * Interface to set reward cumulation time interval.
    * 
    * @param value Time interval.
    * 
    * @return boolean
    */
  // function setRewardCumulationTime(uint256 value) external onlyOwner returns (bool) {
  //   _rewardCumulationTime = value;
  //   return true;
  // }

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
    * Interface to exclude address from rewards.
    * 
    * @param account Address.
    *
    * @return boolean
    */
  // function excludeFromReward(address account) external onlyOwner returns (bool) {
  //   require(!_noReward[account]);
  //   _noReward[account] = true;
  //   uint256 balance = _incReward(_balances[account]);
  //   _totalReward = _totalReward.sub(balance - _balances[account]);
  //   _totalNoReward = _totalNoReward + balance;
  //   _balances[account] = balance;
  //   return true;
  // }

  /**
    * Interface to set private pre sale duration in hours.
    * 
    * @param hr Hours.
    *
    * @return boolean
    */
  function setPrivateSaleHours(uint256 hr) external onlyOwner returns (bool) {
    require(block.timestamp < _preSaleStartTime);
    uint256 preSaleLength = _publicStartTime - _preSaleStartTime;
    _preSaleStartTime = _privateSaleStartTime + hr * 3600; 
    _publicStartTime = _preSaleStartTime + preSaleLength;
    return true;
  }

  /**
    * Interface to set public pre sale duration in hours.
    * 
    * @param hr Hours.
    *
    * @return boolean
    */
  function setPreSaleHours(uint256 hr) external onlyOwner returns (bool) {
    require(block.timestamp < _publicStartTime);
    _publicStartTime = _preSaleStartTime + hr * 3600;
    return true;
  }

  /**
    * Add functionality like burn to the _stake afunction
    *
     */
    function stake(uint256 _amount) public {
      // Make sure staker actually is good for it
      require(_amount < _balances[msg.sender], "DevToken: Cannot stake more than you own");

        _stake(_amount);
                // Burn the amount of tokens on the sender
        // _burn(msg.sender, _amount);
    }

  
  /**
    * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(IERC20 token, uint256 amount, uint256 stake_index)  public {

      uint256 amount_to_transfer = _withdrawStake(amount, stake_index);
      // Return staked tokens to user
      token.transfer(msg.sender, amount_to_transfer);
    }

  /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
           uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
       }
       // Assign calculate amount to summary
       summary.total_amount = totalStakeAmount;
      return summary;
    }
    
}