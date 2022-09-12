/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint256);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract States {
   bool public isStakeActive = true;
   bool public isUnStakeActive = true;

   bool public earlyUstake;


    bool public apyEnabled = true;
    // uint256 tiers;
    uint256 public lockPeriod = 30 seconds;


    bool public isBNBStaking = true;
    bool public isBNBReward = true;

    struct User {
        // uint256 tier;
        uint256 lockPeriod;
        uint256 stakedAmount;
        uint256 totalAmount;
        uint256 depositTime;
        uint256 lastClaimTime;
        uint256 reward;
    }

    mapping(address => User) public deposit;

    uint256 public totalStaked;
    address internal rewardingTokenWallet;
    uint256 internal earlyUstakeFee;
    uint256 internal earlyRewardUstakeFee;
    uint256 internal timeUntilExpiry = block.timestamp + 3650 days; //ten years

    event Stake(address indexed staker, uint256 _amount, uint256 _lockPeriod);
    event Unstake(address indexed unstaker, uint256 unstakeTime);
    event Withdraw(address indexed withdrawer);
    event WithdrawToken(address indexed withdrawer, uint256 amount);
    event Claim(address staker, uint256 reward);
}

contract StakePoolBNBForBNB is States, Ownable {
    using SafeMath for uint256;

    constructor (){
      
    }

    function flipApyEnabled() public onlyOwner {
        apyEnabled = !apyEnabled;
    }
    

    function setEarlyUnstakeFee(uint256 _fee) public onlyOwner {
        earlyUstakeFee = _fee;
    }
    


    function setTokens(uint256 _earlyUstakeFee, uint256 _lockPeriod, uint256 _earlyRewardUstakeFee, bool _earlyUstake) public onlyOwner {
        lockPeriod = _lockPeriod;
        earlyUstakeFee = _earlyUstakeFee;
        earlyRewardUstakeFee = _earlyRewardUstakeFee;
        earlyUstake = _earlyUstake;
    }

    function setData(uint256 _days, uint256 _earlyUstakeFee, uint256 _earlyRewardUstakeFee) public onlyOwner {
        lockPeriod = _days;
        earlyUstakeFee = _earlyUstakeFee;
        earlyRewardUstakeFee = _earlyRewardUstakeFee;
    }


    function setRewardingWallet(address _address) public onlyOwner {
        rewardingTokenWallet = _address;
    }

    receive() external payable{
    }

    function flipStakeState() public onlyOwner {
       isStakeActive = !isStakeActive;
    }

    function flipUnStakeState() public onlyOwner {
       isUnStakeActive = !isUnStakeActive;
    }

    function stake(uint256 _amount) payable public {
        require(msg.value == _amount, "can't proceed deposits");
        require(isStakeActive, "staking is pause");
        _stakeBNB(_amount);
    } 
     
    function _stakeBNB(uint256 _amount) internal {
        
        User memory wUser = deposit[_msgSender()];
        require(wUser.stakedAmount == 0, "Already Staked");
        
        deposit[_msgSender()] = User(block.timestamp + lockPeriod, _amount, _amount, block.timestamp, block.timestamp, 0);

        totalStaked+=_amount;

        emit Stake(_msgSender(), _amount, lockPeriod);
    }

    function UnstakeTokens() public {
      require(isUnStakeActive, "staking is pause");
      _unstakeBNB();
    }

    function EmergencyUnstake() public {
      User memory wUser = deposit[_msgSender()];

        require(wUser.stakedAmount > 0, "deposit first");
        require(block.timestamp > wUser.lockPeriod, "Token locked");

        _msgSender().transfer(wUser.stakedAmount);

        totalStaked-=wUser.stakedAmount;
        deposit[_msgSender()] = User(0 , 0, 0, 0, 0, 0);

        emit Unstake(_msgSender(), block.timestamp);
    }

    function _unstakeBNB() internal {
        User memory wUser = deposit[_msgSender()];

        require(wUser.stakedAmount > 0, "deposit first");
        require(block.timestamp > wUser.lockPeriod, "Token locked");

        _msgSender().transfer(wUser.stakedAmount);

        if(apyEnabled){
                _claimBNB(_msgSender());
        }

        totalStaked-=wUser.stakedAmount;
        deposit[_msgSender()] = User( 0 , 0, 0, 0, 0, 0);

        emit Unstake(_msgSender(), block.timestamp);
    }

    function claim() public {
        User memory info = deposit[_msgSender()];
        require(info.stakedAmount > 0, "Not Staked");
        require(apyEnabled, "No reward");
          _claimBNB(_msgSender());
    }

    function _claimBNB(address _address) internal {
        User storage info = deposit[_address];
        uint256 claimcurrentReward = checkReward(_address);

        if(claimcurrentReward <= address(this).balance){
          // transfer BNB
          payable(_address).transfer(info.reward);
        }
        else{
            require(false, "Pending Rewards Not Allocated");
        }
        
        if(block.timestamp > info.lockPeriod){
          
        info.lastClaimTime = info.lockPeriod;

        }else{
          info.lastClaimTime = block.timestamp;
        }
        
        emit Claim(_address , info.reward);
    }

    function EarlyUnstake() public {
      require(earlyUstake, "early unstake not allowed");
          EarlyUnstakeBNB();
    }

    function EarlyUnstakeBNB() internal {
        User memory wUser = deposit[_msgSender()];

        require(wUser.stakedAmount > 0, "deposit first");
        require(block.timestamp < wUser.lockPeriod, "Try Standard Unstake");
        
        uint256 _fee = wUser.stakedAmount.mul(earlyUstakeFee).div(100);

        _msgSender().transfer(wUser.stakedAmount.sub(_fee));
        payable(rewardingTokenWallet).transfer(_fee);

        _earlyClaim(_msgSender());

        totalStaked-=wUser.stakedAmount;
        deposit[_msgSender()] = User(0 , 0, 0, block.timestamp, block.timestamp, 0);

        emit Unstake(_msgSender(), block.timestamp);
    }

    function _earlyClaim(address _address) internal {
        User storage info = deposit[_address];

        uint256 currentReward = checkReward(_address);
        uint256 _rewardFee = currentReward.mul(earlyRewardUstakeFee).div(100);
  
        
        if(currentReward > 0 && currentReward <= address(this).balance){
             payable(_address).transfer(currentReward.sub(_rewardFee));
        } else{
            require(false, "Pending Rewards for early Unstake Not Allocated");
        }
        
        if(block.timestamp > info.lockPeriod){
          
        info.lastClaimTime = info.lockPeriod;

        }else{
          info.lastClaimTime = block.timestamp;
        }

        emit Claim(_address , currentReward);
    } 

    function withdrawAnyTokens(address _token, address recipient, uint256 amount) public onlyOwner{
        IBEP20 anyToken = IBEP20(_token);
        anyToken.transfer(recipient, amount);
        emit WithdrawToken(recipient, amount);
    }

    function withdrawFunds() public onlyOwner{
       _msgSender().transfer(address(this).balance);
       emit Withdraw(_msgSender());
    }

    function contractbalance() public view returns (uint256) {
      return address(this).balance;
    }

    function calculateApy() public view returns (uint256){
        return address(this).balance.sub(totalStaked).mul(10**18).div(totalStaked);
    }
    
    //. check user reward
    function checkReward(address _address) public view returns (uint256){

      uint256 apyTier = calculateApy();
 
      User memory cUser = deposit[_address];
      require(block.timestamp + 1 seconds > cUser.lastClaimTime, "Time");

      if(block.timestamp >= cUser.lockPeriod){
 
        uint256 stakedtime = (cUser.lockPeriod).sub(cUser.lastClaimTime);
        if(stakedtime == 0){
            return 0;
        }
        stakedtime = stakedtime / 1 seconds;
        
        return apyTier.mul(stakedtime).mul(cUser.totalAmount).div(100).div(10**18).div(365);

      }else{
   
        uint256 stakedtime = (block.timestamp) - (cUser.lastClaimTime);
        stakedtime = stakedtime / 1 seconds;

        return apyTier.mul(stakedtime).mul(cUser.totalAmount).div(100).div(10**18).div(365);     
      }
    }
}

contract FactoryStakingPool{
    
    mapping(uint256 => address) public contractAddress;
    uint256 public contractIndex = 0;

    event newCollection(address indexed owner, address indexed contractAddress);

    constructor() {
    }
    
    function createBNBForBNB(address ownerAddress,uint256 _earlyUnstakeFee, uint256 _lockPeriod, uint256 _earlyRewardUstakeFee, bool _earlyUstake) public returns (address)
    {
        StakePoolBNBForBNB toDeploy = new StakePoolBNBForBNB();
        toDeploy.setTokens(_earlyUnstakeFee, _lockPeriod, _earlyRewardUstakeFee, _earlyUstake);
        toDeploy.transferOwnership(ownerAddress);
        contractAddress[contractIndex] = address(toDeploy);
        contractIndex++;

        emit newCollection(ownerAddress, address(toDeploy));
        return address(toDeploy);
    }
}