/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// File: contracts/dependencies/openzeppelin/contracts/IERC20.sol


pragma solidity 0.7.6;

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
  function allowance(address owner, address spender) external view returns (uint256);

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

// File: contracts/dependencies/openzeppelin/contracts/SafeMath.sol


pragma solidity 0.7.6;

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
    require(c >= a, 'SafeMath: addition overflow');

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
    return sub(a, b, 'SafeMath: subtraction overflow');
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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
    return div(a, b, 'SafeMath: division by zero');
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    return mod(a, b, 'SafeMath: modulo by zero');
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/dependencies/openzeppelin/contracts/Address.sol


pragma solidity 0.7.6;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

// File: contracts/dependencies/openzeppelin/contracts/SafeERC20.sol



pragma solidity 0.7.6;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

// File: contracts/interfaces/IMultiFeeDistribution.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IMultiFeeDistribution {

    function addReward(address rewardsToken) external;
    function mint(address user, uint256 amount, bool withPenalty) external;
    function mintLock(uint256 amount) external;
    function exit() external;
    function withdrawExpiredLocks() external;
    function getReward() external;

}

// File: contracts/dependencies/openzeppelin/contracts/Context.sol


pragma solidity 0.7.6;

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
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: contracts/dependencies/openzeppelin/contracts/Ownable.sol



pragma solidity 0.7.6;

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
  constructor() {
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
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts/dependencies/openzeppelin/contracts/ReentrancyGuard.sol



pragma solidity 0.7.6;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
 abstract contract ReentrancyGuard {
     // Booleans are more expensive than uint256 or any type that takes up a full
     // word because each write operation emits an extra SLOAD to first read the
     // slot's contents, replace the bits taken up by the boolean, and then write
     // back. This is the compiler's defense against contract upgrades and
     // pointer aliasing, and it cannot be disabled.

     // The values being non-zero value makes deployment a bit more expensive,
     // but in exchange the refund on every call to nonReentrant will be lower in
     // amount. Since refunds are capped to a percentage of the total
     // transaction's gas, it is best to keep them low in cases like this one, to
     // increase the likelihood of the full refund coming into effect.
     uint256 private constant _NOT_ENTERED = 1;
     uint256 private constant _ENTERED = 2;

     uint256 private _status;

     constructor () internal {
         _status = _NOT_ENTERED;
     }

     /**
      * @dev Prevents a contract from calling itself, directly or indirectly.
      * Calling a `nonReentrant` function from another `nonReentrant`
      * function is not supported. It is possible to prevent this from happening
      * by making the `nonReentrant` function external, and make it call a
      * `private` function that does the actual work.
      */
     modifier nonReentrant() {
         // On the first call to nonReentrant, _notEntered will be true
         require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         // Any calls to nonReentrant after this point will fail
         _status = _ENTERED;

         _;

         // By storing the original value once again, a refund is triggered (see
         // https://eips.ethereum.org/EIPS/eip-2200)
         _status = _NOT_ENTERED;
     }
 }

// File: contracts/staking/SculptorLockDrop.sol

pragma solidity 0.7.6;






contract SculptorLockDrop is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 balances;
        uint256 unlockTime;
        uint256 rewardPaid;
    }

    struct LockInfo {
        uint256 multiplier;
        uint256 duration;
        uint256 totalBalances;
    }

    address public immutable rewardToken;
    address public immutable stakedToken;

    uint256 public startTime;
    bool public lockedStatus;
    LockInfo[] public lockInfo;
    mapping(address => UserInfo[]) public userInfo;

    uint256 public totalSupply;
    uint256 public totalRewardPaid;
    uint256 public maxRewardSupply;

    mapping(address => bool) private userRewardPaid;
    mapping(address => uint256) private userBalances;

    constructor(
        address _rewardToken,
        address _stakedToken,
        uint256[] memory _duration,
        uint256[] memory _multiplier
    ) {
        require(_duration.length == _multiplier.length);
        rewardToken = _rewardToken;
        stakedToken = _stakedToken;
        for (uint i; i < _duration.length; i++) {
            lockInfo.push(LockInfo({
                multiplier: _multiplier[i],
                duration: _duration[i],
                totalBalances: 0
            }));
        }
    }

    /* ========== VIEW FUNCTION ========== */

    function lockInfoLength() public view returns (uint256)  {
        uint256 length = lockInfo.length;
        return length;
    }

    /* ========== SETTING ========== */

    function start() external onlyOwner {
        require(startTime == 0);
        startTime = block.timestamp;
    }

    function end() external onlyOwner {
        lockedStatus = true;
    }

    function startRewardPaid(uint256 _amount) external onlyOwner {
        require(startTime > 0, "Not starting yet.");
        require(maxRewardSupply == 0);
        require(lockedStatus, "Start reward after end deposited.");
        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        maxRewardSupply = _amount;
    }

    function userRewardWeight(address _user) internal view returns (uint256) {
        uint256 reward = _userRewardWeight(_user);
        return reward;
    }

    /* ========== MUTATIVE FUNCTION ========== */

    function deposit(uint256 _amount, uint256 _lockIndex) external nonReentrant {
        LockInfo storage lock = lockInfo[_lockIndex];
        require(_amount > 0, "Cannot be zero.");
        require(startTime > 0, "Not starting yet.");
        require(!lockedStatus, "Already ended period.");
        require(lock.duration > 0);
        // update balance and unlockTime
        userInfo[msg.sender][_lockIndex].balances = userInfo[msg.sender][_lockIndex].balances.add(_amount);
        userInfo[msg.sender][_lockIndex].unlockTime = block.timestamp.add(lock.duration);
        userBalances[msg.sender] = userBalances[msg.sender].add(_amount);
        totalSupply = totalSupply.add(_amount);
        lock.totalBalances = lock.totalBalances.add(_amount);
        IERC20(stakedToken).safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposited(msg.sender, _amount);
    }

    function getReward(uint256 _amount) external nonReentrant {
        require(!userRewardPaid[msg.sender], "User already got reward.");
        require(startTime > 0, "Not starting");
        require(lockedStatus, "Must ended lock period");
        uint256 totalWeight = _totalSupplyWeight();
        uint256 totalRemainReward = IERC20(rewardToken).balanceOf(address(this));
        require(totalRemainReward > 0, "No reward!");
        uint256 reward = _userRewardWeight(msg.sender);
        if(reward > 0){
            userRewardPaid[msg.sender] = true;
            totalRewardPaid = totalRewardPaid.add(reward);
            IERC20(rewardToken).safeTransfer(msg.sender, reward);
        }

        emit RewardPaid(msg.sender, reward);
    }

    function withdraw() external nonReentrant {
        uint256 withdrawAmount;
        uint256 length = userInfo[msg.sender].length;
        for (uint i; i < length; i++) {
            if(userInfo[msg.sender][i].unlockTime <= block.timestamp) {
                withdrawAmount = withdrawAmount.add(userInfo[msg.sender][i].balances);
                userInfo[msg.sender][i].balances = 0;
                userInfo[msg.sender][i].unlockTime = 0;
            }
        }
        require(userBalances[msg.sender] >= withdrawAmount, "Not enough token!");
        userBalances[msg.sender] = userBalances[msg.sender].sub(withdrawAmount);
        IERC20(stakedToken).safeTransfer(msg.sender, withdrawAmount);
        emit Withdrawn(msg.sender, withdrawAmount);
    }

    /* ========== INTERNAL FUNCTION ========== */

    function _totalSupplyWeight() internal view returns (uint256) {
        uint256 total;
        for (uint i; i < lockInfo.length; i++) {
            LockInfo storage lock = lockInfo[i];
            uint256 weight = lock.totalBalances.mul(lock.multiplier);
            total = total.add(weight);
        }
        return total;
    }

    function _userRewardWeight(address _user) internal view returns (uint256) {
        uint256 totalPending;
        uint256 totalSupplyWeight = _totalSupplyWeight();
        for (uint i; i < lockInfo.length; i++) {
            uint256 weightBalance = userInfo[msg.sender][i].balances.add(lockInfo[i].multiplier);
            uint256 pending = weightBalance.mul(maxRewardSupply).div(totalSupplyWeight);
            totalPending = totalPending.add(pending);
        }
        return totalPending;
    }


    /* ========== EVENTS ========== */

    event Deposited(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    // event Deposited(address indexed user, uint256 amount);
}