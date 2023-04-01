// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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
    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

// SPDX-License-Identifier: MIT

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Pausable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract SyyberShare is Ownable, Pausable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;

    struct Account {
        uint id;
        uint activeLevel;
        address sponsor;
        address binarySponsor;
        uint nextLevelSponsor;
        uint256 lastPay;
        address[] children;
    }

    struct Position {
        uint depth;
        address sponsor;
    }

    struct Level {
        uint cost;
        uint commission;
        uint fee;
        uint binaryCommission;
    }

    mapping(address => Account) public members;
    mapping(uint => address) public idToMember;
    mapping(uint => Level) public levelCost;
    mapping(uint256 => uint256) public bonusTokens;
    mapping(address => mapping(uint256 => bool)) public userClaimBonus;
    mapping(address => mapping(uint256 => uint256)) public levelPending;

    uint internal reentryStatus;
    uint public lastId;
    uint public orderId;
    uint public topLevel;
    address internal feeSystem;
    uint internal REENTRY_REQ;
    IERC20 public payToken;
    IERC20 public rewardToken;
    uint256 public START_TIME_BONUS;
    uint256 public END_TIME_BONUS;
    uint256 public TOTAL_PENDING;

    event Registration(
        address member,
        uint memberId,
        address sponsor,
        address binarySponsor,
        uint orderId
    );
    event Upgrade(address member, address sponsor, uint level, uint orderId);

    event FundsPayout(
        address indexed member,
        address payoutFrom,
        uint level,
        uint orderId
    );
    event FundsPassup(
        address indexed member,
        address passupFrom,
        uint level,
        uint orderId
    );
    event Placement(
        address member,
        address sponsor,
        uint level,
        uint depth,
        uint orderId
    );
    event FundsPayoutUL(
        address indexed member,
        address payoutFrom,
        uint level,
        uint tier,
        uint orderId
    );
    event FundsPassupUL(
        address indexed member,
        address passupFrom,
        uint level,
        uint orderId
    );
    event FundsBonus(address indexed member, uint level, uint256 amount);

    modifier isMember(address _addr) {
        require(members[_addr].id > 0, "Register Account First!");
        _;
    }

    constructor(
        address _payToken,
        address _rewardToken,
        address _topHolder,
        address _feeHolder
    ) public {
        levelCost[1] = Level({
            cost: 20 ether,
            commission: 5 ether,
            fee: 3 ether,
            binaryCommission: 15 ether
        });
        
        topLevel = 1;
        REENTRY_REQ = 2;
        lastId++;
        payToken = IERC20(_payToken);
        rewardToken = IERC20(_rewardToken);
        feeSystem = _feeHolder;

        createAccount(lastId, _topHolder, _topHolder, _topHolder, true);

        bonusTokens[15] = 120000 ether;
        bonusTokens[30] = 240000 ether;
        bonusTokens[45] = 360000 ether;
        bonusTokens[60] = 480000 ether;
        bonusTokens[75] = 600000 ether;
        START_TIME_BONUS = block.timestamp;
        END_TIME_BONUS = block.timestamp.add(30 days);
    }

    function registration(
        address _sponsor,
        address _binarySponsor
    ) external payable nonReentrant whenNotPaused {
        preRegistration(msg.sender, _sponsor, _binarySponsor);
    }

    function preRegistration(
        address _addr,
        address _sponsor,
        address _binarySponsor
    ) internal {
        require(
            payToken.allowance(msg.sender, address(this)) >=
                levelCost[1].cost.add(levelCost[1].fee),
            "Token allowance too low"
        );

        lastId++;

        createAccount(lastId, _addr, _sponsor, _binarySponsor, false);
        handlePayout(_addr, 1, true);
        if (levelCost[1].fee > 0) {
            processPayout(msg.sender, feeSystem, levelCost[1].fee);
        }
        Account storage account = members[_addr];
        handlePayoutUL(msg.sender, _sponsor, 1, 0, true);
        account.nextLevelSponsor = 1;
        
    }

    function createAccount(
        uint _memberId,
        address _addr,
        address _sponsor,
        address _binarySponsor,
        bool _initial
    ) internal {
        require(members[_addr].id == 0, "Already a member!");

        if (_initial == false) {
            require(members[_sponsor].id > 0, "Sponsor dont exist!");
            require(
                members[_binarySponsor].children.length <= 2,
                "Already a full children!"
            );
            require(members[_binarySponsor].id > 0, "Sponsor dont exist!");
        }

        orderId++;
        Account storage account = members[_addr];
        account.id = _memberId;
        account.sponsor = _sponsor;
        account.binarySponsor = _binarySponsor;
        account.activeLevel = 1;
        account.lastPay = block.timestamp;
        Account storage accountBin = members[_binarySponsor];
        accountBin.children.push(_binarySponsor);
        idToMember[_memberId] = _addr;
        
        emit Registration(_addr, _memberId, _sponsor, _binarySponsor, orderId);
    }

    function payIt() external isMember(msg.sender) nonReentrant whenNotPaused {
        uint activeLevel = members[msg.sender].activeLevel;
        uint lastPay = members[msg.sender].lastPay;
        require(lastPay.add(1 minutes) <= block.timestamp, "Invalid time pay");
        require(activeLevel.add(1) <= 75, "Invalid level");
        require(
            payToken.allowance(msg.sender, address(this)) >=
                levelCost[activeLevel.add(1)].cost.add(
                    levelCost[activeLevel.add(1)].fee
                ),
            "Token allowance too low"
        );

        orderId++;

        handleLevel(activeLevel.add(1));
    }

    function handleLevel(uint _level) internal {
        address sponsor = members[msg.sender].sponsor;
        uint nextLevel = members[msg.sender].nextLevelSponsor;
        address activeSponsor = members[msg.sender].sponsor;
        address activeSponsorULF = findActiveSponsorUL(
            msg.sender,
            sponsor,
            _level,
            nextLevel,
            true
        );

        emit Upgrade(msg.sender, activeSponsor, _level, orderId);

        handlePayout(msg.sender, _level, true);
        Account storage account = members[msg.sender];
        account.lastPay = block.timestamp;
        account.activeLevel = _level;
        if (idToMember[1] != activeSponsorULF) {
            account.nextLevelSponsor = nextLevel + 1;
            if (account.nextLevelSponsor == 16) {
                account.nextLevelSponsor = 0;
            }
            handlePayoutUL(
                msg.sender,
                activeSponsorULF,
                _level,
                nextLevel + 1,
                true
            );
        }
        if (idToMember[1] == activeSponsorULF) {
            handlePayoutUL(
                msg.sender,
                activeSponsorULF,
                _level,
                nextLevel,
                true
            );
        }

        if (levelCost[_level].fee > 0) {
            processPayout(msg.sender, feeSystem, levelCost[_level].fee);
        }
        uint256 amountPend = levelPending[msg.sender][_level];
        if (amountPend > 0) {
            levelPending[msg.sender][_level] = 0;
            TOTAL_PENDING = TOTAL_PENDING.sub(amountPend);
            processPayoutPending(msg.sender, amountPend);
        }
    }

    function findActiveSponsorUL(
        address _addr,
        address _sponsor,
        uint _level,
        uint _tier,
        bool _emit
    ) internal returns (address sponsorAddress) {
        sponsorAddress = _sponsor;
        for (uint256 index = 0; index < _tier; index++) {
            sponsorAddress = members[sponsorAddress].sponsor;
        }
        if (members[sponsorAddress].activeLevel >= _level) {
            return sponsorAddress;
        } else {
            levelPending[sponsorAddress][_level] = levelPending[sponsorAddress][
                _level
            ].add(levelCost[_level].binaryCommission);
            TOTAL_PENDING = TOTAL_PENDING.add(
                levelCost[_level].binaryCommission
            );
            sponsorAddress = address(this);
        }

        if (_emit == true) {
            emit FundsPassupUL(sponsorAddress, _addr, _level, orderId);
        }
        return sponsorAddress;
    }

    function findActiveSponsor(
        address _addr,
        address _sponsor,
        uint _level,
        bool _emit
    ) internal returns (address sponsorAddress) {
        sponsorAddress = _sponsor;
        if (_emit == true) {
            emit FundsPassup(sponsorAddress, _addr, _level, orderId);
        }
    }

    function findPayoutReceiver(
        address _addr
    ) internal returns (address receiver) {
        receiver = members[_addr].sponsor;
    }

    function handlePayout(
        address _addr,
        uint _level,
        bool _transferPayout
    ) internal {
        address receiver = findPayoutReceiver(_addr);

        emit FundsPayout(receiver, _addr, _level, orderId);

        if (_transferPayout == true) {
            processPayout(_addr, receiver, levelCost[_level].commission);
        }
    }

    function handlePayoutUL(
        address _addr,
        address _sponsor,
        uint _level,
        uint _levelTier,
        bool _transferPayout
    ) internal {
        address receiver = _sponsor;
        uint commission = levelCost[_level].binaryCommission;
        if (commission > 0) {
            emit FundsPayoutUL(
                receiver,
                _addr,
                _level,
                _levelTier + 1,
                orderId
            );

            if (_transferPayout == true) {
                processPayout(_addr, receiver, commission);
            }
        }
    }

    function processPayout(
        address _addrSender,
        address _addrReceived,
        uint _amount
    ) internal {
        bool success = payToken.transferFrom(
            _addrSender,
            _addrReceived,
            _amount
        );
        if (success == false) {
            //Failsafe to prevent malicious contracts from blocking matrix
            success = payToken.transferFrom(
                _addrSender,
                address(uint160(idToMember[1])),
                _amount
            );
            require(success, "Transfer Failed");
        }
    }

    function claimBonus()
        external
        isMember(msg.sender)
        nonReentrant
        whenNotPaused
    {
        require(START_TIME_BONUS <= block.timestamp, "Claim bonus not started");
        require(END_TIME_BONUS >= block.timestamp, "Claim bonus was ended");
        uint activeLevel = members[msg.sender].activeLevel;
        require(activeLevel > 15, "Claim bonus level not valid");
        uint256 levelAmount;
        if (activeLevel >= 15 && activeLevel < 30) {
            levelAmount = 15;
        }
        if (activeLevel >= 30 && activeLevel < 45) {
            levelAmount = 30;
        }
        if (activeLevel >= 45 && activeLevel < 60) {
            levelAmount = 45;
        }
        if (activeLevel >= 60 && activeLevel < 75) {
            levelAmount = 60;
        }
        if (activeLevel >= 75) {
            levelAmount = 75;
        }
        uint256 amount = bonusTokens[levelAmount];
        if (!userClaimBonus[msg.sender][15] && levelAmount == 30) {
            amount = amount.add(bonusTokens[15]);
            userClaimBonus[msg.sender][15] = true;
        }
        if (
            !userClaimBonus[msg.sender][15] &&
            !userClaimBonus[msg.sender][30] &&
            levelAmount == 45
        ) {
            amount = bonusTokens[15].add(bonusTokens[30]).add(amount);
            userClaimBonus[msg.sender][15] = true;
            userClaimBonus[msg.sender][30] = true;
        }
        if (
            !userClaimBonus[msg.sender][15] &&
            !userClaimBonus[msg.sender][30] &&
            !userClaimBonus[msg.sender][45] &&
            levelAmount == 60
        ) {
            amount = bonusTokens[15]
                .add(bonusTokens[30])
                .add(bonusTokens[45])
                .add(amount);
            userClaimBonus[msg.sender][15] = true;
            userClaimBonus[msg.sender][30] = true;
            userClaimBonus[msg.sender][45] = true;
        }
        if (
            !userClaimBonus[msg.sender][15] &&
            !userClaimBonus[msg.sender][30] &&
            !userClaimBonus[msg.sender][45] &&
            !userClaimBonus[msg.sender][75] &&
            levelAmount == 75
        ) {
            amount = bonusTokens[15]
                .add(bonusTokens[30])
                .add(bonusTokens[45])
                .add(bonusTokens[60])
                .add(amount);
            userClaimBonus[msg.sender][15] = true;
            userClaimBonus[msg.sender][30] = true;
            userClaimBonus[msg.sender][45] = true;
            userClaimBonus[msg.sender][60] = true;
        }
        userClaimBonus[msg.sender][levelAmount] = true;
        if (amount > 0) {
            processPayoutReward(msg.sender, amount);
            emit FundsBonus(msg.sender, activeLevel, amount);
        }
    }

    function processPayoutReward(address _addrReceived, uint _amount) internal {
        rewardToken.transfer(_addrReceived, _amount);
    }

    function processPayoutPending(
        address _addrReceived,
        uint _amount
    ) internal {
        payToken.transfer(_addrReceived, _amount);
    }

    function getAffiliateId(address userAddress) external view returns (uint) {
        return members[userAddress].id;
    }

    function getCurrentLevel(address userAddress) external view returns (uint) {
        return members[userAddress].activeLevel;
    }

    function getNextPayit(address userAddress) external view returns (uint) {
        return members[userAddress].lastPay.add(1 minutes);
    }

    function getSponsor(address userAddress) external view returns (address) {
        return members[userAddress].sponsor;
    }

    function getBinSponsor(
        address userAddress
    ) external view returns (address) {
        return members[userAddress].binarySponsor;
    }

    function getBinaryChildren(
        address userAddress
    ) external view returns (address[] memory) {
        return members[userAddress].children;
    }

    function getAffiliateWallet(
        uint32 memberId
    ) external view returns (address) {
        return idToMember[memberId];
    }

    function getAmountBonus(
        address userAddress
    ) external view returns (uint256 amount) {
        uint activeLevel = members[userAddress].activeLevel;
        uint256 levelAmount;
        if (activeLevel >= 15 && activeLevel < 30) {
            levelAmount = 15;
        }
        if (activeLevel >= 30 && activeLevel < 45) {
            levelAmount = 30;
        }
        if (activeLevel >= 45 && activeLevel < 60) {
            levelAmount = 45;
        }
        if (activeLevel >= 60 && activeLevel < 75) {
            levelAmount = 60;
        }
        if (activeLevel >= 75) {
            levelAmount = 75;
        }
        amount = bonusTokens[levelAmount];
        if (!userClaimBonus[userAddress][15] && levelAmount == 30) {
            amount = amount.add(bonusTokens[15]);
        }
        if (
            !userClaimBonus[userAddress][15] &&
            !userClaimBonus[userAddress][30] &&
            levelAmount == 45
        ) {
            amount = bonusTokens[15].add(bonusTokens[30]).add(amount);
        }
        if (
            !userClaimBonus[userAddress][15] &&
            !userClaimBonus[userAddress][30] &&
            !userClaimBonus[userAddress][45] &&
            levelAmount == 60
        ) {
            amount = bonusTokens[15]
                .add(bonusTokens[30])
                .add(bonusTokens[45])
                .add(amount);
        }
        if (
            !userClaimBonus[userAddress][15] &&
            !userClaimBonus[userAddress][30] &&
            !userClaimBonus[userAddress][45] &&
            !userClaimBonus[userAddress][75] &&
            levelAmount == 75
        ) {
            amount = bonusTokens[15]
                .add(bonusTokens[30])
                .add(bonusTokens[45])
                .add(bonusTokens[60])
                .add(amount);
        }
        return amount;
    }

    function addLevel(
        uint _levelPrice,
        uint _levelCommission,
        uint _levelFee,
        uint _levelBinCommission
    ) external onlyOwner {
        require(
            (_levelCommission + _levelBinCommission) == _levelPrice,
            "Check price point!"
        );

        topLevel++;

        levelCost[topLevel] = Level({
            cost: _levelPrice,
            commission: _levelCommission,
            fee: _levelFee,
            binaryCommission: _levelBinCommission
        });
    }

    function updateLevelCost(
        uint _level,
        uint _levelPrice,
        uint _levelCommission,
        uint _levelFee,
        uint _levelBinCommission
    ) external onlyOwner {
        require((_level > 0 && _level <= topLevel), "Invalid matrix level.");
        require((_levelPrice > 0), "Check price point!");
        require(
            (_levelCommission + _levelBinCommission) == _levelPrice,
            "Check price point!"
        );

        levelCost[_level] = Level({
            cost: _levelPrice,
            commission: _levelCommission,
            fee: _levelFee,
            binaryCommission: _levelBinCommission
        });
    }

    function setFeeSystem(address _addr) external onlyOwner {
        feeSystem = _addr;
    }

    function setStartEndBonus(uint256 _start, uint256 _end) external onlyOwner {
        START_TIME_BONUS = _start;
        END_TIME_BONUS = _end;
    }

    function setToken(address _reward, address _pay) external onlyOwner {
        payToken = IERC20(_pay);
        rewardToken = IERC20(_reward);
    }

    function bytesToAddress(
        bytes memory _source
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(_source, 20))
        }
    }

    /// @notice Withdraw the fund in contract
    /// @dev Callable by the super admin
    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) external onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }
}