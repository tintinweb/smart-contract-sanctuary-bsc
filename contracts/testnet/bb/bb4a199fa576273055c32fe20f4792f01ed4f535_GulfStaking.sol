/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity 0.5.16;

library ExtendedMath {
    /**
     * @return The given number raised to the power of 2
     */
    function pow2(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * a;
        require(c / a == a, "ExtendedMath: squaring overflow");
        return c;
    }

    /**
     * @return The square root of the given number
     */
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


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
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Sacrifice {
    constructor(address payable _recipient) public payable {
        selfdestruct(_recipient);
    }
}



interface IERC20Mintable {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function mint(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}







/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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

    uint256[50] private ______gap;
}







/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





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
 */
contract ReentrancyGuard is Initializable {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    function initialize() public initializer {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}








library Sigmoid {
    using SafeMath for uint256;
    using ExtendedMath for uint256;

    // The period after which the new value of the parameter is set
    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    struct Params {
        uint256 a;
        int256 b;
        uint256 c;
    }

    struct State {
        Params oldParams;
        Params newParams;
        uint256 timestamp;
    }

    /**
     * @dev Sets sigmoid parameters
     * @param _a Sigmoid parameter A.
     * @param _b Sigmoid parameter B.
     * @param _c Sigmoid parameter C.
     */
    function setParameters(State storage self, uint256 _a, int256 _b, uint256 _c) internal {
        require(_c != 0, "should be greater than 0"); // prevent division by zero
        uint256 currentTimestamp = _now();
        if (self.timestamp == 0) {
            self.oldParams = Params(_a, _b, _c);
        } else if (currentTimestamp > self.timestamp.add(PARAM_UPDATE_DELAY)) {
            self.oldParams = self.newParams;
        }
        self.newParams = Params(_a, _b, _c);
        self.timestamp = currentTimestamp;
    }

    /**
     * @return Sigmoid parameters
     */
    function getParameters(State storage self) internal view returns (uint256, int256, uint256) {
        bool isUpdated = _now() > self.timestamp.add(PARAM_UPDATE_DELAY);
        return isUpdated ?
            (self.newParams.a, self.newParams.b, self.newParams.c) :
            (self.oldParams.a, self.oldParams.b, self.oldParams.c);
    }

    /**
     * @return The corresponding Y value for a given X value
     */
    function calculate(State storage self, int256 _x) internal view returns (uint256) {
        (uint256 a, int256 b, uint256 c) = getParameters(self);
        int256 k = _x - b;
        if (k < 0) return 0;
        uint256 uk = uint256(k);
        return a.mul(uk).div(uk.pow2().add(c).sqrt());
    }

    /**
     * @return Returns current timestamp.
     */
    function _now() internal view returns (uint256) {
        // Note that the timestamp can have a 900-second error:
        // https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
        return now; // solium-disable-line security/no-block-members
    }
}


/**
 * @title GulfStaking
 * @author 0x2f7662cD8E784750E116E44a536278d2b429167E
 *
 * Note: all percentage values are between 0 (0%) and 1 (100%)
 * and represented as fixed point numbers containing 18 decimals like with Ether
 * 100% == 1 ether
 */
contract GulfStaking is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Sigmoid for Sigmoid.State;

    /**
     * @dev Emitted when a user deposits tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param amount The amount of deposited tokens.
     * @param balance Current user balance.
     * @param accruedEmission User's accrued emission.
     * @param prevDepositDuration Duration of the previous deposit in seconds.
     */
    event Deposited(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 balance,
        uint256 accruedEmission,
        uint256 prevDepositDuration
    );

    /**
     * @dev Emitted when a user requests withdrawal.
     * @param sender User address.
     * @param id User's unique deposit ID.
     */
    event WithdrawalRequested(address indexed sender, uint256 indexed id);

    /**
     * @dev Emitted when a user withdraws tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param amount The amount of withdrawn tokens.
     * @param fee The withdrawal fee.
     * @param balance Current user balance.
     * @param accruedEmission User's accrued emission.
     * @param lastDepositDuration Duration of the last deposit in seconds.
     */
    event Withdrawn(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 fee,
        uint256 balance,
        uint256 accruedEmission,
        uint256 lastDepositDuration
    );

    /**
     * @dev Emitted when a new fee value is set.
     * @param value A new fee value.
     * @param sender The owner address at the moment of fee changing.
     */
    event FeeSet(uint256 value, address sender);

    /**
     * @dev Emitted when a new withdrawal lock duration value is set.
     * @param value A new withdrawal lock duration value.
     * @param sender The owner address at the moment of value changing.
     */
    event WithdrawalLockDurationSet(uint256 value, address sender);

    /**
     * @dev Emitted when a new withdrawal unlock duration value is set.
     * @param value A new withdrawal unlock duration value.
     * @param sender The owner address at the moment of value changing.
     */
    event WithdrawalUnlockDurationSet(uint256 value, address sender);

    /**
     * @dev Emitted when a new total supply factor value is set.
     * @param value A new total supply factor value.
     * @param sender The owner address at the moment of value changing.
     */
    event TotalSupplyFactorSet(uint256 value, address sender);

    /**
     * @dev Emitted when new sigmoid parameters values are set.
     * @param a A new parameter A value.
     * @param b A new parameter B value.
     * @param c A new parameter C value.
     * @param sender The owner address at the moment of value changing.
     */
    event SigmoidParametersSet(uint256 a, int256 b, uint256 c, address sender);

    /**
     * @dev Emitted when a new Liquidity Providers Reward address value is set.
     * @param value A new address value.
     * @param sender The owner address at the moment of address changing.
     */
    event LiquidityProvidersRewardAddressSet(address value, address sender);

    uint256 private constant YEAR = 365 days;
    // The maximum emission rate (in percentage)
    uint256 public constant MAX_EMISSION_RATE = 150 finney; // 15%, 0.15 ether
    // The period after which the new value of the parameter is set
    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    // STAKE token
    IERC20Mintable public token;

    struct UintParam {
        uint256 oldValue;
        uint256 newValue;
        uint256 timestamp;
    }

    struct AddressParam {
        address oldValue;
        address newValue;
        uint256 timestamp;
    }

    // The address for the Liquidity Providers reward
    AddressParam public liquidityProvidersRewardAddressParam;
    // The fee of the forced withdrawal (in percentage)
    UintParam public feeParam;
    // The time from the request after which the withdrawal will be available (in seconds)
    UintParam public withdrawalLockDurationParam;
    // The time during which the withdrawal will be available from the moment of unlocking (in seconds)
    UintParam public withdrawalUnlockDurationParam;
    // Total supply factor for calculating emission rate (in percentage)
    UintParam public totalSupplyFactorParam;

    // The deposit balances of users
    mapping (address => mapping (uint256 => uint256)) public balances;
    // The dates of users' deposits
    mapping (address => mapping (uint256 => uint256)) public depositDates;
    // The dates of users' withdrawal requests
    mapping (address => mapping (uint256 => uint256)) public withdrawalRequestsDates;
    // The last deposit id
    mapping (address => uint256) public lastDepositIds;
    // The total staked amount
    uint256 public totalStaked;

    // Variable that prevents _deposit method from being called 2 times
    bool private locked;
    // The library that is used to calculate user's current emission rate
    Sigmoid.State private sigmoid;

    /**
     * @dev Initializes the contract.
     * @param _owner The owner of the contract.
     * @param _tokenAddress The address of the STAKE token contract.
     * @param _liquidityProvidersRewardAddress The address for the Liquidity Providers reward.
     * @param _fee The fee of the forced withdrawal (in percentage).
     * @param _withdrawalLockDuration The time from the request after which the withdrawal will be available (in seconds).
     * @param _withdrawalUnlockDuration The time during which the withdrawal will be available from the moment of unlocking (in seconds).
     * @param _totalSupplyFactor Total supply factor for calculating emission rate (in percentage).
     * @param _sigmoidParamA Sigmoid parameter A.
     * @param _sigmoidParamB Sigmoid parameter B.
     * @param _sigmoidParamC Sigmoid parameter C.
     */
    function initialize(
        address _owner,
        address _tokenAddress,
        address _liquidityProvidersRewardAddress,
        uint256 _fee,
        uint256 _withdrawalLockDuration,
        uint256 _withdrawalUnlockDuration,
        uint256 _totalSupplyFactor,
        uint256 _sigmoidParamA,
        int256 _sigmoidParamB,
        uint256 _sigmoidParamC
    ) external initializer {
        require(_owner != address(0), "zero address");
        require(_tokenAddress.isContract(), "not a contract address");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        token = IERC20Mintable(_tokenAddress);
        setFee(_fee);
        setWithdrawalLockDuration(_withdrawalLockDuration);
        setWithdrawalUnlockDuration(_withdrawalUnlockDuration);
        setTotalSupplyFactor(_totalSupplyFactor);
        setSigmoidParameters(_sigmoidParamA, _sigmoidParamB, _sigmoidParamC);
        setLiquidityProvidersRewardAddress(_liquidityProvidersRewardAddress);
        Ownable.transferOwnership(_owner);
    }

    /**
     * @dev This method is used to deposit tokens to a new deposit.
     * It generates a new deposit ID and calls another public "deposit" method. See its description.
     * @param _amount The amount to deposit.
     */
    function deposit(uint256 _amount) external {
        deposit(++lastDepositIds[msg.sender], _amount);
    }

    /**
     * @dev This method is used to deposit tokens to the deposit opened before.
     * It calls the internal "_deposit" method and transfers tokens from sender to contract.
     * Sender must approve tokens first.
     *
     * Instead this, user can use the simple "transfer" method of STAKE token contract to make a deposit.
     * Sender's approval is not needed in this case.
     *
     * Note: each call updates the deposit date so be careful if you want to make a long staking.
     *
     * @param _depositId User's unique deposit ID.
     * @param _amount The amount to deposit.
     */
    function deposit(uint256 _depositId, uint256 _amount) public {
        require(_depositId > 0 && _depositId <= lastDepositIds[msg.sender], "wrong deposit id");
        _deposit(msg.sender, _depositId, _amount);
        _setLocked(true);
        require(token.transferFrom(msg.sender, address(this), _amount), "transfer failed");
        _setLocked(false);
    }

    /**
     * @dev This method is called when STAKE tokens are transferred to this contract.
     * using "transfer", "transferFrom", or "transferAndCall" method of STAKE token contract.
     * It generates a new deposit ID and calls the internal "_deposit" method.
     * @param _sender The sender of tokens.
     * @param _amount The transferred amount.
     * @return true if successful
     */
    function onTokenTransfer(address _sender, uint256 _amount, bytes calldata) external returns (bool) {
        require(msg.sender == address(token), "only token contract is allowed");
        if (!locked) {
            _deposit(_sender, ++lastDepositIds[_sender], _amount);
        }
        return true;
    }

    /**
     * @dev This method is used to make a forced withdrawal with a fee.
     * It calls the internal "_withdraw" method.
     * @param _depositId User's unique deposit ID.
     * @param _amount The amount to withdraw (0 - to withdraw all).
     */
    function makeForcedWithdrawal(uint256 _depositId, uint256 _amount) external {
        _withdraw(msg.sender, _depositId, _amount, true);
    }

    /**
     * @dev This method is used to request a withdrawal without a fee.
     * It sets the date of the request.
     *
     * Note: each call updates the date of the request so don't call this method twice during the lock.
     *
     * @param _depositId User's unique deposit ID.
     */
    function requestWithdrawal(uint256 _depositId) external {
        require(_depositId > 0 && _depositId <= lastDepositIds[msg.sender], "wrong deposit id");
        withdrawalRequestsDates[msg.sender][_depositId] = _now();
        emit WithdrawalRequested(msg.sender, _depositId);
    }

    /**
     * @dev This method is used to make a requested withdrawal.
     * It calls the internal "_withdraw" method and resets the date of the request.
     *
     * If sender didn't call this method during the unlock period (if timestamp >= lockEnd + withdrawalUnlockDuration)
     * they have to call "requestWithdrawal" one more time.
     *
     * @param _depositId User's unique deposit ID.
     * @param _amount The amount to withdraw (0 - to withdraw all).
     */
    function makeRequestedWithdrawal(uint256 _depositId, uint256 _amount) external {
        uint256 requestDate = withdrawalRequestsDates[msg.sender][_depositId];
        require(requestDate > 0, "withdrawal wasn't requested");
        uint256 timestamp = _now();
        uint256 lockEnd = requestDate.add(withdrawalLockDuration());
        require(timestamp >= lockEnd, "too early");
        require(timestamp < lockEnd.add(withdrawalUnlockDuration()), "too late");
        withdrawalRequestsDates[msg.sender][_depositId] = 0;
        _withdraw(msg.sender, _depositId, _amount, false);
    }

    /**
     * @dev This method is used to claim unsupported tokens accidentally sent to the contract.
     * It can only be called by the owner.
     * @param _token The address of the token contract (zero address for claiming native coins).
     * @param _to The address of the tokens/coins receiver.
     * @param _amount Amount to claim.
     */
    function claimTokens(address _token, address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0) && _to != address(this), "not a valid recipient");
        require(_amount > 0, "amount should be greater than 0");
        if (_token == address(0)) {
            if (!_to.send(_amount)) { // solium-disable-line security/no-send
                (new Sacrifice).value(_amount)(_to);
            }
        } else if (_token == address(token)) {
            uint256 availableAmount = token.balanceOf(address(this)).sub(totalStaked);
            require(availableAmount >= _amount, "insufficient funds");
            require(token.transfer(_to, _amount), "transfer failed");
        } else {
            IERC20 customToken = IERC20(_token);
            customToken.safeTransfer(_to, _amount);
        }
    }

    /**
     * @dev Sets the fee for forced withdrawals. Can only be called by owner.
     * @param _value The new fee value (in percentage).
     */
    function setFee(uint256 _value) public onlyOwner {
        require(_value <= 1 ether, "should be less than or equal to 1 ether");
        _updateUintParam(feeParam, _value);
        emit FeeSet(_value, msg.sender);
    }

    /**
     * @dev Sets the time from the request after which the withdrawal will be available.
     * Can only be called by owner.
     * @param _value The new duration value (in seconds).
     */
    function setWithdrawalLockDuration(uint256 _value) public onlyOwner {
        require(_value <= 30 days, "shouldn't be greater than 30 days");
        _updateUintParam(withdrawalLockDurationParam, _value);
        emit WithdrawalLockDurationSet(_value, msg.sender);
    }

    /**
     * @dev Sets the time during which the withdrawal will be available from the moment of unlocking.
     * Can only be called by owner.
     * @param _value The new duration value (in seconds).
     */
    function setWithdrawalUnlockDuration(uint256 _value) public onlyOwner {
        require(_value >= 1 hours, "shouldn't be less than 1 hour");
        _updateUintParam(withdrawalUnlockDurationParam, _value);
        emit WithdrawalUnlockDurationSet(_value, msg.sender);
    }

    /**
     * @dev Sets total supply factor for calculating emission rate.
     * Can only be called by owner.
     * @param _value The new factor value (in percentage).
     */
    function setTotalSupplyFactor(uint256 _value) public onlyOwner {
        require(_value <= 1 ether, "should be less than or equal to 1 ether");
        _updateUintParam(totalSupplyFactorParam, _value);
        emit TotalSupplyFactorSet(_value, msg.sender);
    }

    /**
     * @dev Sets parameters of the sigmoid that is used to calculate the user's current emission rate.
     * Can only be called by owner.
     * @param _a Sigmoid parameter A. Unsigned integer.
     * @param _b Sigmoid parameter B. Signed integer.
     * @param _c Sigmoid parameter C. Unsigned integer. Cannot be zero.
     */
    function setSigmoidParameters(uint256 _a, int256 _b, uint256 _c) public onlyOwner {
        require(_a <= MAX_EMISSION_RATE.div(2), "should be less than or equal to a half of the maximum emission rate");
        sigmoid.setParameters(_a, _b, _c);
        emit SigmoidParametersSet(_a, _b, _c, msg.sender);
    }

    /**
     * @dev Sets the address for the Liquidity Providers reward.
     * Can only be called by owner.
     * @param _address The new address.
     */
    function setLiquidityProvidersRewardAddress(address _address) public onlyOwner {
        require(_address != address(0), "zero address");
        require(_address != address(this), "wrong address");
        AddressParam memory param = liquidityProvidersRewardAddressParam;
        if (param.timestamp == 0) {
            param.oldValue = _address;
        } else if (_paramUpdateDelayElapsed(param.timestamp)) {
            param.oldValue = param.newValue;
        }
        param.newValue = _address;
        param.timestamp = _now();
        liquidityProvidersRewardAddressParam = param;
        emit LiquidityProvidersRewardAddressSet(_address, msg.sender);
    }

    /**
     * @return Returns current fee.
     */
    function fee() public view returns (uint256) {
        return _getUintParamValue(feeParam);
    }

    /**
     * @return Returns current withdrawal lock duration.
     */
    function withdrawalLockDuration() public view returns (uint256) {
        return _getUintParamValue(withdrawalLockDurationParam);
    }

    /**
     * @return Returns current withdrawal unlock duration.
     */
    function withdrawalUnlockDuration() public view returns (uint256) {
        return _getUintParamValue(withdrawalUnlockDurationParam);
    }

    /**
     * @return Returns current total supply factor.
     */
    function totalSupplyFactor() public view returns (uint256) {
        return _getUintParamValue(totalSupplyFactorParam);
    }

    /**
     * @return Returns current liquidity providers reward address.
     */
    function liquidityProvidersRewardAddress() public view returns (address) {
        AddressParam memory param = liquidityProvidersRewardAddressParam;
        return _paramUpdateDelayElapsed(param.timestamp) ? param.newValue : param.oldValue;
    }

    /**
     * @return Emission rate based on the ratio of total staked to total supply.
     */
    function getSupplyBasedEmissionRate() public view returns (uint256) {
        uint256 totalSupply = token.totalSupply();
        uint256 factor = totalSupplyFactor();
        if (factor == 0) return 0;
        uint256 target = totalSupply.mul(factor).div(1 ether);
        uint256 maxSupplyBasedEmissionRate = MAX_EMISSION_RATE.div(2); // 7.5%
        if (totalStaked >= target) {
            return maxSupplyBasedEmissionRate;
        }
        return maxSupplyBasedEmissionRate.mul(totalStaked).div(target);
    }

    /**
     * @param _depositDate Deposit date.
     * @param _amount Amount based on which emission is calculated and accrued.
     * @return Total accrued emission (for the user and Liquidity Providers), user share, and seconds passed since the previous deposit started.
     */
    function getAccruedEmission(
        uint256 _depositDate,
        uint256 _amount
    ) public view returns (uint256 total, uint256 userShare, uint256 timePassed) {
        if (_amount == 0 || _depositDate == 0) return (0, 0, 0);
        timePassed = _now().sub(_depositDate);
        if (timePassed == 0) return (0, 0, 0);
        uint256 userEmissionRate = sigmoid.calculate(int256(timePassed));
        userEmissionRate = userEmissionRate.add(getSupplyBasedEmissionRate());
        if (userEmissionRate == 0) return (0, 0, timePassed);
        assert(userEmissionRate <= MAX_EMISSION_RATE);
        total = _amount.mul(MAX_EMISSION_RATE).mul(timePassed).div(YEAR * 1 ether);
        userShare = _amount.mul(userEmissionRate).mul(timePassed).div(YEAR * 1 ether);
    }

    /**
     * @return Sigmoid parameters.
     */
    function getSigmoidParameters() public view returns (uint256 a, int256 b, uint256 c) {
        return sigmoid.getParameters();
    }

    /**
     * @dev Calls internal "_mint" method, increases the user balance, and updates the deposit date.
     * @param _sender The address of the sender.
     * @param _id User's unique deposit ID.
     * @param _amount The amount to deposit.
     */
    function _deposit(address _sender, uint256 _id, uint256 _amount) internal nonReentrant {
        require(_amount > 0, "deposit amount should be more than 0");
        (uint256 sigmoidParamA,,) = getSigmoidParameters();
        if (sigmoidParamA == 0 && totalSupplyFactor() == 0) revert("emission stopped");
        (uint256 userShare, uint256 timePassed) = _mint(_sender, _id, 0);
        uint256 newBalance = balances[_sender][_id].add(_amount);
        balances[_sender][_id] = newBalance;
        totalStaked = totalStaked.add(_amount);
        depositDates[_sender][_id] = _now();
        emit Deposited(_sender, _id, _amount, newBalance, userShare, timePassed);
    }

    /**
     * @dev Calls internal "_mint" method and then transfers tokens to the sender.
     * @param _sender The address of the sender.
     * @param _id User's unique deposit ID.
     * @param _amount The amount to withdraw (0 - to withdraw all).
     * @param _forced Defines whether to apply fee (true), or not (false).
     */
    function _withdraw(address _sender, uint256 _id, uint256 _amount, bool _forced) internal nonReentrant {
        require(_id > 0 && _id <= lastDepositIds[_sender], "wrong deposit id");
        require(balances[_sender][_id] > 0 && balances[_sender][_id] >= _amount, "insufficient funds");
        (uint256 accruedEmission, uint256 timePassed) = _mint(_sender, _id, _amount);
        uint256 amount = _amount == 0 ? balances[_sender][_id] : _amount.add(accruedEmission);
        balances[_sender][_id] = balances[_sender][_id].sub(amount);
        totalStaked = totalStaked.sub(amount);
        if (balances[_sender][_id] == 0) {
            depositDates[_sender][_id] = 0;
        }
        uint256 feeValue = 0;
        if (_forced) {
            feeValue = amount.mul(fee()).div(1 ether);
            amount = amount.sub(feeValue);
            require(token.transfer(liquidityProvidersRewardAddress(), feeValue), "transfer failed");
        }
        require(token.transfer(_sender, amount), "transfer failed");
        emit Withdrawn(_sender, _id, amount, feeValue, balances[_sender][_id], accruedEmission, timePassed);
    }

    /**
     * @dev Mints MAX_EMISSION_RATE per annum and distributes the emission between the user and Liquidity Providers in proportion.
     * @param _user User's address.
     * @param _id User's unique deposit ID.
     * @param _amount Amount based on which emission is calculated and accrued. When 0, current deposit balance is used.
     */
    function _mint(address _user, uint256 _id, uint256 _amount) internal returns (uint256, uint256) {
        uint256 currentBalance = balances[_user][_id];
        uint256 amount = _amount == 0 ? currentBalance : _amount;
        (uint256 total, uint256 userShare, uint256 timePassed) = getAccruedEmission(depositDates[_user][_id], amount);
        if (total > 0) {
            require(token.mint(address(this), total), "minting failed");
            balances[_user][_id] = currentBalance.add(userShare);
            totalStaked = totalStaked.add(userShare);
            require(token.transfer(liquidityProvidersRewardAddress(), total.sub(userShare)), "transfer failed");
        }
        return (userShare, timePassed);
    }

    /**
     * @dev Sets the next value of the parameter and the timestamp of this setting.
     */
    function _updateUintParam(UintParam storage _param, uint256 _newValue) internal {
        if (_param.timestamp == 0) {
            _param.oldValue = _newValue;
        } else if (_paramUpdateDelayElapsed(_param.timestamp)) {
            _param.oldValue = _param.newValue;
        }
        _param.newValue = _newValue;
        _param.timestamp = _now();
    }

    /**
     * @return Returns the current value of the parameter.
     */
    function _getUintParamValue(UintParam memory _param) internal view returns (uint256) {
        return _paramUpdateDelayElapsed(_param.timestamp) ? _param.newValue : _param.oldValue;
    }

    /**
     * @return Returns true if param update delay elapsed.
     */
    function _paramUpdateDelayElapsed(uint256 _paramTimestamp) internal view returns (bool) {
        return _now() > _paramTimestamp.add(PARAM_UPDATE_DELAY);
    }

    /**
     * @dev Sets lock to prevent reentrance.
     */
    function _setLocked(bool _locked) internal {
        locked = _locked;
    }

    /**
     * @return Returns current timestamp.
     */
    function _now() internal view returns (uint256) {
        // Note that the timestamp can have a 900-second error:
        // https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
        return now; // solium-disable-line security/no-block-members
    }
}