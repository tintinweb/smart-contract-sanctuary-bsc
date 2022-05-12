/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at FtmScan.com on 2021-10-06
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.7.6;
pragma abicoder v2;



// Part: Address

// Part: Address

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

// Part: Context

// Part: Context

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

// Part: IERC20

// Part: IERC20

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

// Part: IMultiFeeDistribution

// Part: IMultiFeeDistribution

interface IMultiFeeDistribution {

    function addReward(address rewardsToken) external;
    // function mint(address user, uint256 amount, bool withPenalty) external;

}

// Part: ReentrancyGuard

// Part: ReentrancyGuard

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

    constructor ()  {
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

// Part: SafeMath

// Part: SafeMath

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

// Part: IMintableToken

// Part: IMintableToken

// interface IMintableToken is IERC20 {
//     function mint(address _receiver, uint256 _amount) external returns (bool);
//     function setMinter(address _minter) external returns (bool);
// }

// Part: Ownable

// Part: Ownable

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

// Part: SafeERC20

// Part: SafeERC20

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

// File: <stdin>.sol

// File: MultiFeeDistribution.sol

// Based on Ellipsis EPS Staker
// https://github.com/ellipsis-finance/ellipsis/blob/master/contracts/EpsStaker.sol
contract MultiFeeDistribution is IMultiFeeDistribution, ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // using SafeERC20 for IMintableToken;

    /* ========== STATE VARIABLES ========== */

    string private constant _name = "Kittens";
    string private constant _symbol = "Kittens";
    uint8 private constant _decimals = 18;


    struct Reward {
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        // tracks already-added balances to handle accrued interest in aToken rewards
        // for the stakingToken this value is unused and will always be 0
        uint256 balance;
    }
    struct Balances {
        uint256 veBal;
        uint256 locked;
    }
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
        uint256 lockDuration;
        uint256 minted;
    }
    struct RewardData {
        address token;
        uint256 amount;
    }

    IERC20 public immutable stakingToken;
    address[] public rewardTokens;
    mapping(address => Reward) public rewardData;

    // Duration that rewards are streamed over
    uint256 public constant rewardsDuration = 86400 * 7;

    // Duration of lock/earned penalty period
    // uint256 public constant lockDuration = rewardsDuration * 13;

    // Addresses approved to call mint
    mapping(address => bool) public minters;
    bool public mintersAreSet;

    // user -> reward token -> amount
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) public rewards;

    uint256 public totalSupply;
    uint256 public lockedSupply;

    // Private mappings for balance data
    // *************were private************88888
    mapping(address => Balances) public balances;
    mapping(address => LockedBalance[]) public userLocks;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _stakingToken) Ownable() {
        stakingToken = IERC20(_stakingToken);
        // First reward MUST be the staking token or things will break
        // related to the 75% penalty and distribution to locked balances
        rewardTokens.push(_stakingToken);
        rewardData[_stakingToken].lastUpdateTime = block.timestamp;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    /* ========== ADMIN CONFIGURATION ========== */


    // Add a new reward token to be distributed to stakers
    function addReward(address _rewardsToken) external override onlyOwner {
        require(rewardData[_rewardsToken].lastUpdateTime == 0);
        rewardTokens.push(_rewardsToken);
        rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
        rewardData[_rewardsToken].periodFinish = block.timestamp;
    }

    /* ========== VIEWS ========== */

    function _rewardPerToken(address _rewardsToken, uint256 _supply) internal view returns (uint256) {
        if (_supply == 0) {
            return rewardData[_rewardsToken].rewardPerTokenStored;
        }
        return
            rewardData[_rewardsToken].rewardPerTokenStored.add(
                lastTimeRewardApplicable(_rewardsToken).sub(
                    rewardData[_rewardsToken].lastUpdateTime).mul(
                        rewardData[_rewardsToken].rewardRate).mul(1e18).div(_supply)
            );
    }

    function _earned(
        address _user,
        address _rewardsToken,
        uint256 _balance,
        uint256 supply
    ) internal view returns (uint256) {
        return _balance.mul(
            _rewardPerToken(_rewardsToken, supply).sub(userRewardPerTokenPaid[_user][_rewardsToken])
        ).div(1e18).add(rewards[_user][_rewardsToken]);
    }

    function lastTimeRewardApplicable(address _rewardsToken) public view returns (uint256) {
        uint periodFinish = rewardData[_rewardsToken].periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken(address _rewardsToken) external view returns (uint256) {
        uint256 supply = totalSupply;
        return _rewardPerToken(_rewardsToken, supply);

    }

    function getRewardForDuration(address _rewardsToken) external view returns (uint256) {
        return rewardData[_rewardsToken].rewardRate.mul(rewardsDuration);
    }

    // Address and claimable amount of all reward tokens for the given account
    function claimableRewards(address account) external view returns (RewardData[] memory rewardsData) {
        rewardsData = new RewardData[](rewardTokens.length);
        for (uint256 i = 0; i < rewardsData.length; i++) {
            // If i == 0 this is the stakingReward, distribution is based on locked balances
            uint256 balance =  balances[account].veBal;
            uint256 supply = totalSupply;
            rewardsData[i].token = rewardTokens[i];
            rewardsData[i].amount = _earned(account, rewardsData[i].token, balance, supply);
        }
        return rewardsData;
    }

    // Total balance of an account, including unlocked, locked and earned tokens
    function balanceOf(address user) view external returns (uint256 amount) {
        return balances[user].veBal;
    }

    // Total withdrawable balance for an account to which no penalty is applied
    function unlockedBalance(address user) view external returns (uint256 amount) {
        LockedBalance[] storage locks = userLocks[user];
        for (uint i = 0; i < locks.length; i++) {
            if (locks[i].unlockTime > block.timestamp) {
                continue;
            }
            amount = amount.add(locks[i].amount);
        }
        return amount;
    }


    // Information on a user's locked balances
    function lockedBalances(
        address user
    ) view external returns (
        uint256 total,
        uint256 unlockable,
        uint256 locked,
        LockedBalance[] memory lockData
    ) {
        LockedBalance[] storage locks = userLocks[user];
        uint256 idx;
        for (uint i = 0; i < locks.length; i++) {
            if (locks[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    lockData = new LockedBalance[](locks.length - i);
                }
                lockData[idx] = locks[i];
                idx++;
                locked = locked.add(locks[i].amount);
            } else {
                unlockable = unlockable.add(locks[i].amount);
            }
        }
        return (balances[user].locked, unlockable, locked, lockData);
    }

    // Final balance received and penalty balance paid by user upon calling exit
    function withdrawableBalance(
        address user
    ) view public returns (
        uint256 amount,
        uint256 penaltyAmount
    ) {
        Balances storage bal = balances[user];
        if (bal.locked > 0) {
            uint256 amountWithoutPenalty;
            uint256 length = userLocks[user].length;
            for (uint i = 0; i < length; i++) {
                uint256 lockedAmount = userLocks[user][i].amount;
                if (lockedAmount == 0) continue;
                if (userLocks[user][i].unlockTime > block.timestamp) {
                    // break;
                    continue;
                }
                // uint256 mintedAmount = userLocks[user][i].minted;
                amountWithoutPenalty = amountWithoutPenalty.add(lockedAmount);
            }

            penaltyAmount = bal.locked.sub(amountWithoutPenalty).mul(3).div(4); // 75% penalty
        }
        amount = bal.locked.sub(penaltyAmount);
        return (amount, penaltyAmount);
    }

    function getVeYieldAmount(uint256 amount, uint256 lockDuration) public pure returns (uint256) {
        return  amount.mul(lockDuration).mul(((lockDuration.sub(1)).mul(25)).add(725)).div(24).div(1000);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    // Stake tokens to receive rewards
    // Locked tokens cannot be withdrawn for lockDuration and are eligible to receive stakingReward rewards
    // lockedDuration is in number of months
    function stake(uint256 amount, uint256 lockDuration) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(lockDuration > 0 && lockDuration <= 24 , "Incorrect locking duration");
        uint256 veYieldBal = getVeYieldAmount(amount,lockDuration);
        totalSupply = totalSupply.add(veYieldBal);
        Balances storage bal = balances[msg.sender];
        bal.veBal = bal.veBal.add(veYieldBal);
        lockedSupply = lockedSupply.add(amount);
        bal.locked = bal.locked.add(amount);
        uint256 lockDurationInSec = lockDuration.mul(2592000); // 1 month(30 days) = 2,592,000 sec
        uint256 unlockTime = block.timestamp.add(lockDurationInSec);

        userLocks[msg.sender].push(LockedBalance({amount: amount, unlockTime: unlockTime, minted : veYieldBal, lockDuration: lockDuration}));

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, lockDuration, veYieldBal);
    }

    function extendLockDuration(uint256 lockedIdx) external {
        LockedBalance storage lock = userLocks[msg.sender][lockedIdx];
        uint256 lockedAmount = lock.amount;
        uint256 lockedDuration = lock.lockDuration;
        require(lockedAmount > 0 , "no locked Amount");
        require(lockedDuration < 24, "Already locked for Maximum time");
        uint256 veYieldBalOld = getVeYieldAmount(lockedAmount,lockedDuration);
        uint256 veYieldBalNew = getVeYieldAmount(lockedAmount,lockedDuration.add(1));
        Balances storage bal = balances[msg.sender];
        bal.veBal = bal.veBal.add(veYieldBalNew).sub(veYieldBalOld);
        lock.minted = lock.minted.add((veYieldBalNew).sub(veYieldBalOld));
        lock.lockDuration = lock.lockDuration.add(1);
        lock.unlockTime = lock.unlockTime.add(2592000);
        totalSupply = totalSupply.add((veYieldBalNew).sub(veYieldBalOld));
        emit LockExtended(msg.sender, lockedIdx, veYieldBalNew.sub(veYieldBalOld));

    }


    // Withdraw staked tokens
    // lockedIdx is the locking id.
    // incurs a 75% penalty which is distributed based on locked balances.
    function withdraw(uint256 lockedIdx) public updateReward(msg.sender) {
        LockedBalance storage lock = userLocks[msg.sender][lockedIdx];
        uint256 lockedAmount = lock.amount;
        require(lockedAmount > 0 , "Cannot withdraw 0");
        Balances storage bal = balances[msg.sender];
        uint256 penaltyAmount;


        bal.locked = bal.locked.sub(lockedAmount);
        if(lock.unlockTime > block.timestamp) {
            penaltyAmount = lockedAmount.mul(3).div(4); // 75% penalty for withdrawing before locking period is over
        }


        uint256 receievingAmount = lockedAmount.sub(penaltyAmount);
        bal.veBal = bal.veBal.sub(lock.minted);
        lockedSupply = lockedSupply.sub(lockedAmount);
        totalSupply = totalSupply.sub(lock.minted);

        delete userLocks[msg.sender][lockedIdx];

        stakingToken.safeTransfer(msg.sender, receievingAmount);
        if (penaltyAmount > 0) {
            _notifyReward(address(stakingToken), penaltyAmount);
        }
        emit Withdrawn(msg.sender, receievingAmount);

        getReward();

        
    }

    // Claim all pending staking rewards
    function getReward() public nonReentrant updateReward(msg.sender) {
        for (uint i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            if (token == address(0)) continue;
            uint256 reward = rewards[msg.sender][token];
            if (i > 0) {
                // for rewards other than stakingToken, every 24 hours we check if new
                // rewards were sent to the contract 
                uint256 balance = rewardData[token].balance;
                if (rewardData[token].periodFinish < block.timestamp.add(rewardsDuration - 86400)) {
                    uint256 unseen = IERC20(token).balanceOf(address(this)).sub(balance);
                    if (unseen > 0) {
                        _notifyReward(token, unseen);
                        balance = balance.add(unseen);
                    }
                }
                rewardData[token].balance = balance.sub(reward);
            }
            if (reward == 0) continue;
            rewards[msg.sender][token] = 0;
            IERC20(token).safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, token, reward);
        }
    }

    //added for testing
    function updateRewardRate() external {
      for (uint i =1; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            if (token == address(0)) continue;
            // for rewards other than stakingToken, we check if new
            // rewards were sent to the contract
            uint256 balance = rewardData[token].balance;
            // if (rewardData[token].periodFinish < block.timestamp.add(rewardsDuration - 86400)) {
            if (rewardData[token].periodFinish < block.timestamp.add(rewardsDuration )) {
                uint256 unseen = IERC20(token).balanceOf(address(this)).sub(balance);
                if (unseen > 0) {
                    _notifyReward(token, unseen);
                    balance = balance.add(unseen);
                }
            }
            rewardData[token].balance = balance;
        }
    }
    // Withdraw full unlocked and locked(with Penalty) balance and claim pending rewards
    function exit() external updateReward(msg.sender) {
        (uint256 amount, uint256 penaltyAmount) = withdrawableBalance(msg.sender);
        delete userLocks[msg.sender];
        Balances storage bal = balances[msg.sender];
        totalSupply = totalSupply.sub(bal.veBal);
        bal.locked = 0;
        bal.veBal = 0;

        stakingToken.safeTransfer(msg.sender, amount);
        if (penaltyAmount > 0) {
            _notifyReward(address(stakingToken), penaltyAmount);
        }
        getReward();
    }

    // Withdraw all currently locked tokens where the unlock time has passed
    function withdrawExpiredLocks() external updateReward(msg.sender) {
        LockedBalance[] storage locks = userLocks[msg.sender];
        Balances storage bal = balances[msg.sender];
        uint256 amount;
        uint256 veYieldAmount;
        uint256 length = locks.length;
        
        for (uint i = 0; i < length; i++) {
            if (locks[i].unlockTime > block.timestamp) continue;
            amount = amount.add(locks[i].amount);
            veYieldAmount = veYieldAmount.add(locks[i].minted);
            delete locks[i];
        }
        
        bal.locked = bal.locked.sub(amount);
        bal.veBal = bal.veBal.sub(veYieldAmount);
        totalSupply = totalSupply.sub(veYieldAmount);
        lockedSupply = lockedSupply.sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function _notifyReward(address _rewardsToken, uint256 reward) internal {
        if (block.timestamp >= rewardData[_rewardsToken].periodFinish) {
            rewardData[_rewardsToken].rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = rewardData[_rewardsToken].periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardData[_rewardsToken].rewardRate);
            rewardData[_rewardsToken].rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
        rewardData[_rewardsToken].periodFinish = block.timestamp.add(rewardsDuration);

    }

    // Added to support recovering tokens sent to the contract by mistake
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(stakingToken), "Cannot withdraw staking token");
        require(rewardData[tokenAddress].lastUpdateTime == 0, "Cannot withdraw reward token");
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        address token = address(stakingToken);
        uint256 balance;
        uint256 supply = lockedSupply;
        rewardData[token].rewardPerTokenStored = _rewardPerToken(token, supply);
        rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
        if (account != address(0)) {
            // Special case, use the locked balances and supply for stakingReward rewards
            rewards[account][token] = _earned(account, token, balances[account].veBal, supply);
            userRewardPerTokenPaid[account][token] = rewardData[token].rewardPerTokenStored;
            balance = balances[account].veBal;
        }

        supply = totalSupply;
        for (uint i = 1; i < rewardTokens.length; i++) {
            token = rewardTokens[i];
            rewardData[token].rewardPerTokenStored = _rewardPerToken(token, supply);
            rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
            if (account != address(0)) {
                rewards[account][token] = _earned(account, token, balance, supply);
                userRewardPerTokenPaid[account][token] = rewardData[token].rewardPerTokenStored;
            }
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 lockDuration, uint256 veYieldMinted);
    event LockExtended(address indexed user, uint256 lockedIdx, uint256 veYieldMinted);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed rewardsToken, uint256 reward);
    event RewardsDurationUpdated(address token, uint256 newDuration);
    event Recovered(address token, uint256 amount);
}