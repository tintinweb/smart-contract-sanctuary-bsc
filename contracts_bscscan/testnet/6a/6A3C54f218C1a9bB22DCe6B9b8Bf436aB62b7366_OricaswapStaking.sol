/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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


// File contracts/libraries/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;

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
   * @dev Returns the addition of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  /**
   * @dev Returns the substraction of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
   *
   * _Available since v3.4._
   */
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  /**
   * @dev Returns the division of two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
   *
   * _Available since v3.4._
   */
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
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
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   *
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {trySub}.
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  /**
   * @dev Returns the integer division of two unsigned integers, reverting with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryDiv}.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * reverting with custom message when dividing by zero.
   *
   * CAUTION: This function is deprecated because it requires allocating memory for the error
   * message unnecessarily. For custom revert reasons use {tryMod}.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

pragma solidity ^0.7.6;

contract OricaswapStaking is  Ownable {

  // Using SafeMath library for mathematical operations over uint256
  using SafeMath for uint256;

  // Representing stake structure
  struct Stake {
    uint256 amountStaked;
    uint256 stakingTime;
    uint256 unlockingTime;
    uint256 userReward;
    uint256 withdrawReward;
  }
  

  
  // Token being staked
  IERC20 public token;
  
    // Token being rewarded
  IERC20 public rewardToken;

  // Mapping user to his stakes
  mapping(address => Stake) public userToHisStakeIds;

  // Total amount staked at the moment
  uint256 public totalStaked;
  
  // Total amount staked at the moment
  uint256 public APY = 12;
  
  uint public userStaked;
  
  uint256 public oneYear = 365;
  
  uint public oneDay = 1 days;

  // Minimal time to stake in order to get eligible to participate in private sales
  uint256 public minimalTimeToStake;

  // Minimal amount staked
  uint256 public minimalAmountToStake;


    // Initially set token address and admin wallet address
    constructor(address _token, address _rewardToken) {
        token = IERC20(_token);
        rewardToken = IERC20(_rewardToken);
    }
    
 
  
  
    // Function to deposit tokens (create stake)
    function depositTokens(uint256 _amount) public {
    // Require that user is meeting requirement for minimal stake amount
    require(_amount >= minimalAmountToStake,"amount less than min limit");
    
    // Allow only direct calls from EOA (Externally owner wallets - flashloan prevention)
    require(msg.sender == tx.origin);
    Stake storage user= userToHisStakeIds[msg.sender];
    // uint256 pendingReward = calculateReward(msg.sender);
    claimReward();
    user.stakingTime = block.timestamp;
    user.unlockingTime = block.timestamp.add(minimalTimeToStake);
    user.amountStaked = user.amountStaked.add(_amount);
    user.withdrawReward = 0;
    

    // Take tokens from the user
    token.transferFrom(msg.sender, address(this), _amount);
    
    // Increase how much is staked in total
    totalStaked = totalStaked.add(_amount);
    userStaked++;
  }
  
    //function for calculating total reward
  function calculateReward(address _user) public view returns (uint256) {
    require(userToHisStakeIds[msg.sender].amountStaked >= 0, "No stake found");
        Stake memory s = userToHisStakeIds[_user];
        uint256 stakingDays =  (block.timestamp-s.stakingTime).div(oneDay);
        uint256 rewardPerDay = ((s.amountStaked.mul(APY)).div(oneYear)).div(100);
        uint256 rewardAmount = ((rewardPerDay.mul(stakingDays)).sub(s.withdrawReward));
    return rewardAmount;
  }
  
  function getTotalRewardEarned() public view returns(uint){
        Stake memory s = userToHisStakeIds[msg.sender];
    return s.userReward;
  }
    

  function claimReward() public {
      uint256 amountToWithdraw = calculateReward(msg.sender);
      if(amountToWithdraw > 0){
       rewardToken.transfer(msg.sender, amountToWithdraw);
      Stake storage s = userToHisStakeIds[msg.sender];
      s.withdrawReward = s.withdrawReward.add(amountToWithdraw);
      s.userReward = s.userReward.add(amountToWithdraw);
      }
  }

    function withdrawStake() public {
    Stake storage user = userToHisStakeIds[msg.sender];
    require(user.amountStaked > 0 , "No amount available to withdraw");
    require(block.timestamp > user.unlockingTime , "Unlocktime not reached");
    claimReward();
    token.transfer(msg.sender, user.amountStaked);
    totalStaked= totalStaked.sub(user.amountStaked);
    user.amountStaked=user.amountStaked.sub(user.amountStaked);
    user.withdrawReward = 0;
    userStaked--;
    }

    function emergencyWithdraw() public {
      Stake storage user = userToHisStakeIds[msg.sender];
      token.transfer(msg.sender, user.amountStaked);
      totalStaked= totalStaked.sub(user.amountStaked);
      userStaked--;
      user.withdrawReward=0;
      user.amountStaked=0;
    }


    function getRewardTokenBalance() public view returns(uint){
      uint256 balance = rewardToken.balanceOf(address(this)); 
      if(address(rewardToken) == address(token)){
        balance = balance.sub(totalStaked);
      }
      return balance;
    }
  
    function withdrawRewardToken() public onlyOwner returns(bool){
      return (rewardToken.transfer(msg.sender, getRewardTokenBalance()));
    }

    function updateAPY(uint _APY) public onlyOwner {
      APY = _APY;
    }

     // Function which can be called only by admin
    function setStakingRules(uint256 _minimalTimeToStake,uint256 _minimalAmountToStake)
        onlyOwner public {
    // Set minimal time to stake
        minimalTimeToStake = _minimalTimeToStake;
    // Set minimal amount to stake
        minimalAmountToStake = _minimalAmountToStake;
    }
    
  
}