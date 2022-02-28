/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Referral is Ownable {
  using SafeMath for uint;

  /**
   * @dev Max referral level depth
   */
  uint8 constant MAX_REFER_DEPTH = 3;

  /**
   * @dev Max referee amount to bonus rate depth
   */
  uint8 constant MAX_REFEREE_BONUS_LEVEL = 3;


  /**
   * @dev The struct of account information
   * @param referrer The referrer addresss
   * @param reward The total referral reward of an address
   * @param referredCount The total referral amount of an address
   * @param lastActiveTimestamp The last active timestamp of an address
   */
  struct Account {
    address payable referrer;
    uint reward;
    uint referredCount;
    uint lastActiveTimestamp;
  }

  /**
   * @dev The struct of referee amount to bonus rate
   * @param lowerBound The minial referee amount
   * @param rate The bonus rate for each referee amount
   */
  struct RefereeBonusRate {
    uint lowerBound;
    uint rate;
  }

  event RegisteredReferer(address referee, address referrer);
  event RegisteredRefererFailed(address referee, address referrer, string reason);
  event PaidReferral(address from, address to, uint amount, uint level);
  event UpdatedUserLastActiveTime(address user, uint timestamp);

  mapping(address => Account) public accounts;

  uint256[] levelRate;
  uint256 referralBonus;
  uint256 decimals;
  uint256 secondsUntilInactive;
  bool onlyRewardActiveReferrers;
  RefereeBonusRate[] refereeBonusRateMap;

  /**
   * @param _decimals The base decimals for float calc, for example 1000
   * @param _referralBonus The total referral bonus rate, which will divide by decimals. For example, If you will like to set as 5%, it can set as 50 when decimals is 1000.
   * @param _secondsUntilInactive The seconds that a user does not update will be seen as inactive.
   * @param _onlyRewardActiveReferrers The flag to enable not paying to inactive uplines.
   * @param _levelRate The bonus rate for each level, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
   * @param _refereeBonusRateMap The bonus rate mapping to each referree amount, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
   * The map should be pass as [<lower amount>, <rate>, ....]. For example, you should pass [1, 250, 5, 500, 10, 1000] when decimals is 1000 for the following case.
   *
   *  25%     50%     100%
   *   | ----- | ----- |----->
   *  1ppl    5ppl    10ppl
   *
   * @notice refereeBonusRateMap's lower amount should be ascending
   */
  constructor(
    uint _decimals,
    uint _referralBonus,
    uint _secondsUntilInactive,
    bool _onlyRewardActiveReferrers,
    uint256[] memory _levelRate,
    uint256[] memory _refereeBonusRateMap
  ) public

  {
    require(_levelRate.length > 0, "Referral level should be at least one");
    require(_levelRate.length <= MAX_REFER_DEPTH, "Exceeded max referral level depth");
    require(_refereeBonusRateMap.length % 2 == 0, "Referee Bonus Rate Map should be pass as [<lower amount>, <rate>, ....]");
    require(_refereeBonusRateMap.length / 2 <= MAX_REFEREE_BONUS_LEVEL, "Exceeded max referree bonus level depth");
    require(_referralBonus <= _decimals, "Referral bonus exceeds 100%");
    require(sum(_levelRate) <= _decimals, "Total level rate exceeds 100%");

    decimals = _decimals;
    referralBonus = _referralBonus;
    secondsUntilInactive = _secondsUntilInactive;
    onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
    levelRate = _levelRate;

    // Set default referee amount rate as 1ppl -> 100% if rate map is empty.
    if (_refereeBonusRateMap.length == 0) {
      refereeBonusRateMap.push(RefereeBonusRate(1, decimals));
      return;
    }

    for (uint i; i < _refereeBonusRateMap.length; i += 2) {
      if (_refereeBonusRateMap[i+1] > decimals) {
        revert("One of referee bonus rate exceeds 100%");
      }
      // Cause we can't pass struct or nested array without enabling experimental ABIEncoderV2, use array to simulate it
      refereeBonusRateMap.push(RefereeBonusRate(_refereeBonusRateMap[i], _refereeBonusRateMap[i+1]));
    }
  }

  function sum(uint[] memory data) public pure returns (uint) {
    uint S;
    for(uint i;i < data.length;i++) {
      S += data[i];
    }
    return S;
  }


  /**
   * @dev Utils function for check whether an address has the referrer
   */
  function hasReferrer(address addr) public view returns(bool){
    return accounts[addr].referrer != address(0);
  }

  /**
   * @dev Get block timestamp with function for testing mock
   */
  function getTime() public view returns(uint256) {
    return block.timestamp; // solium-disable-line security/no-block-members
  }

  /**
   * @dev Given a user amount to calc in which rate period
   * @param amount The number of referrees
   */
  function getRefereeBonusRate(uint256 amount) public view returns(uint256) {
    uint rate = refereeBonusRateMap[0].rate;
    for(uint i = 1; i < refereeBonusRateMap.length; i++) {
      if (amount < refereeBonusRateMap[i].lowerBound) {
        break;
      }
      rate = refereeBonusRateMap[i].rate;
    }
    return rate;
  }

  function isCircularReference(address referrer, address referee) internal view returns(bool){
    address parent = referrer;

    for (uint i; i < levelRate.length; i++) {
      if (parent == address(0)) {
        break;
      }

      if (parent == referee) {
        return true;
      }

      parent = accounts[parent].referrer;
    }

    return false;
  }

  /**
   * @dev Add an address as referrer
   * @param referrer The address would set as referrer of msg.sender
   * @return whether success to add upline
   */
  function addReferrer(address payable referrer) internal returns(bool){
    if (referrer == address(0)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Referrer cannot be 0x0 address");
      return false;
    } else if (isCircularReference(referrer, msg.sender)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Referee cannot be one of referrer uplines");
      return false;
    } else if (accounts[msg.sender].referrer != address(0)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Address have been registered upline");
      return false;
    }

    Account storage userAccount = accounts[msg.sender];
    Account storage parentAccount = accounts[referrer];

    userAccount.referrer = referrer;
    userAccount.lastActiveTimestamp = getTime();
    parentAccount.referredCount = parentAccount.referredCount.add(1);

    emit RegisteredReferer(msg.sender, referrer);
    return true;
  }

  /**
   * @dev This will calc and pay referral to uplines instantly
   * @param value The number tokens will be calculated in referral process
   * @return the total referral bonus paid
   */
  function payReferral(address payable receiver, uint256 value) internal returns(uint256){
    Account memory userAccount = accounts[msg.sender];
    uint totalReferal;

    for (uint i; i < levelRate.length; i++) {
      address payable parent = userAccount.referrer;
      Account storage parentAccount = accounts[userAccount.referrer];

      if (parent == address(0)) {
        break;
      }

      if(onlyRewardActiveReferrers && parentAccount.lastActiveTimestamp.add(secondsUntilInactive) >= getTime() || !onlyRewardActiveReferrers) {
        uint c = value.mul(referralBonus).div(decimals);
        c = c.mul(levelRate[i]).div(decimals);
        c = c.mul(getRefereeBonusRate(parentAccount.referredCount)).div(decimals);

        totalReferal = totalReferal.add(c);

        parentAccount.reward = parentAccount.reward.add(c);
        parent.transfer(c);
        emit PaidReferral(msg.sender, parent, c, i + 1);
      }

      userAccount = parentAccount;
    }
    receiver.transfer(value - totalReferal);

    updateActiveTimestamp(msg.sender);
    return totalReferal;
  }

  /**
   * @dev Developers should define what kind of actions are seens active. By default, payReferral will active msg.sender.
   * @param user The address would like to update active time
   */
  function updateActiveTimestamp(address user) internal {
    uint timestamp = getTime();
    accounts[user].lastActiveTimestamp = timestamp;
    emit UpdatedUserLastActiveTime(user, timestamp);
  }

  function setSecondsUntilInactive(uint _secondsUntilInactive) public onlyOwner {
    secondsUntilInactive = _secondsUntilInactive;
  }

  function setOnlyRewardAActiveReferrers(bool _onlyRewardActiveReferrers) public onlyOwner {
    onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
  }
}


contract DoubleOrNothing is Ownable, Referral {
  event BetSettled(address player, uint256 winnings);

  constructor(
    uint _decimals,
    uint _referralBonus,
    uint _secondsUntilInactive,
    bool _onlyRewardActiveReferrers,
    uint256[] memory _levelRate,
    uint256[] memory _refereeBonusRateMap
  ) Referral(
      _decimals,
      _referralBonus,
      _secondsUntilInactive,
      _onlyRewardActiveReferrers,
      _levelRate,
      _refereeBonusRateMap
  ) public

  // solium-disable-next-line no-empty-blocks
  {}



  function bet(address payable receiver, address payable _referrer) external payable {
    if(!hasReferrer(msg.sender)) {
      addReferrer(_referrer);
    }
    bet(receiver);
  }

  function bet(address payable receiver) public payable {
    // msg.value is added to the balance to begin with so you need to double it
    //require(msg.value * 2 <= address(this).balance, "Balance too low!");
    
    //uint256 winnings = 0;
    /*
    // DO NOT USE THIS IN PRODUCTION, IT IS INSECURE
    if(uint256(blockhash(block.number - 1)) % 2 == 0) {
      // 3% is deducted to cover the referral bonus
      winnings = msg.value * 197/100;
      address(msg.sender).transfer(winnings);
    }
    */
    payReferral(receiver, msg.value);
    //emit BetSettled(msg.sender, winnings);
  }
  /*
  function withdraw(uint256 _amount) external onlyOwner {
    require(_amount <= address(this).balance, "Balance too low!");
    address(msg.sender).transfer(_amount);
  }
  */
}