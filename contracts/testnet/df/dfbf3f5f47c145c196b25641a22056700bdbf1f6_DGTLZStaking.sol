/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

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
     * @dev Moves `amount` tokens from the caller"s account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller"s tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender"s allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller"s
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b >= 0, errorMessage);
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]
pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DGTLZStaking is Ownable {
  using SafeMath for uint256;
  
  IERC20 constant BUSD = IERC20(0x9A3a08544d50A60bB89526f52C1D4788e3DD9292);
  uint256 private totalStakeAmount;
  uint256 private totalRewardAmount;
  uint256 private totalAmount_;
  uint256 private unStakableAmount;
  uint256 currentTime;
  uint256 private level;
  uint256 private decimals = 10 ** 18;
  uint256 private _maxWETHToSpend;
  uint256 private _perTxBuyAmount;
  address private _tokenToSell;
  address private _tokenToBuy;
  uint256 private _perTxWethAmount;
  mapping(address => bool) internal stakeholders;

  struct StakeHolder{
    uint256 stakingBalance;
    uint256 stakingDate;
    uint256 stakingDuration;
    uint256 claimDate;
    uint256 expireDate;
    uint256 rewardAmount;
    uint256 level;
    bool claimStatus;
    bool isStaker;
  }


  mapping(address => mapping(uint => StakeHolder)) public stakeHolders;

  uint internal _amountLevel;
  uint[] internal stakePeriod = [30 seconds, 90 seconds, 180 seconds, 365 seconds];
  uint[12] internal rate = [0, 10, 20, 20, 40, 55, 55, 85, 115, 130, 210, 250];

  function staking(uint _amount, uint _duration) external {
    require(_amount <= BUSD.balanceOf(msg.sender), "Not enough BUSD token to stake");
    require(_amount >= 500 , "Insufficient Stake Amount");
    require(_duration < 4, "Duration not match");

    if(_amount >= 500 && _amount < 2000) _amountLevel = 1;
    else if(_amount >= 2000&& _amount <= 5000) _amountLevel = 2;
    else _amountLevel = 3;

    StakeHolder storage s = stakeHolders[msg.sender][_duration];
    s.stakingBalance = _amount;
    s.stakingDate = block.timestamp;
    s.claimDate = block.timestamp;
    s.stakingDuration = stakePeriod[_duration];
    s.expireDate = s.stakingDate + s.stakingDuration;
    s.isStaker = true;

    if(_duration == 1 && _amountLevel == 1) s.level = 0;
    if(_duration == 1 && _amountLevel == 2) s.level = 1; 
    if(_duration == 1 && _amountLevel == 3) s.level = 2;
    if(_duration == 3 && _amountLevel == 1) s.level = 3;
    if(_duration == 3 && _amountLevel == 2) s.level = 4;
    if(_duration == 3 && _amountLevel == 3) s.level = 5;
    if(_duration == 6 && _amountLevel == 1) s.level = 6;
    if(_duration == 6 && _amountLevel == 2) s.level = 7;
    if(_duration == 6 && _amountLevel == 3) s.level = 8;
    if(_duration == 12 && _amountLevel == 1) s.level = 9;
    if(_duration == 12 && _amountLevel == 2) s.level = 10;
    if(_duration == 12 && _amountLevel == 3) s.level = 11;

    BUSD.transferFrom(msg.sender, address(this), _amount * decimals);
 
    totalStakeAmount += _amount;
  }

  function _calcReward(uint256 _duration) public returns(uint256 reward) {
    StakeHolder storage s = stakeHolders[msg.sender][_duration];
    if(block.timestamp >= s.expireDate) currentTime = s.expireDate;
    else currentTime = block.timestamp;
    uint256 _pastTime = currentTime - s.claimDate;
    bool status = (block.timestamp-s.claimDate) > 7 seconds;
    reward = _pastTime.mul(s.stakingBalance).mul(rate[s.level]).div(1000).div(s.stakingDuration);
    s.claimStatus = status;
  }

  function claim(uint256 _duration) public {
    StakeHolder storage s = stakeHolders[msg.sender][_duration];
    require(s.isStaker == true, "You did not any stake in this contract");
    uint256 rewardAmount = _calcReward(_duration);
    require(s.claimStatus == true, "Invalid Claim Date");
    BUSD.transfer(msg.sender, rewardAmount * decimals);
    s.claimDate = block.timestamp;
  }

  function getTotalBalance() public view onlyOwner returns(uint256) {
    return BUSD.balanceOf(address(this));
  }
}