// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

library MySafeMath {
    using SafeMath for uint256;

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = a.div(b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}

library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(d), 10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(10**18), d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {
        return MySafeMath.divCeil(uint256(10**36), target);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/DecimalMath.sol";

contract vBABYToken is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage(ERC20) ============

    string public name = "vBABY Membership Token";
    string public symbol = "vBABY";
    uint8 public decimals = 18;

    mapping(address => mapping(address => uint256)) internal _allowed;

    // ============ Storage ============

    address public _babyToken;
    address public _babyTeam;
    address public _babyReserve;
    address public _babyTreasury;
    bool public _canTransfer;
    address public constant hole = 0x000000000000000000000000000000000000dEaD;

    // staking reward parameters
    uint256 public _babyPerBlock;
    uint256 public constant _superiorRatio = 10**17; // 0.1
    uint256 public constant _babyRatio = 100; // 100
    uint256 public _babyFeeBurnRatio = 30 * 10**16; //30%
    uint256 public _babyFeeReserveRatio = 20 * 10**16; //20%
    uint256 public _feeRatio = 0;//10 * 10**16; //10%;
    // accounting
    uint112 public alpha = 10**18; // 1
    uint112 public _totalBlockDistribution;
    uint32 public _lastRewardBlock;

    uint256 public _totalBlockReward;
    uint256 public _totalStakingPower;
    mapping(address => UserInfo) public userInfo;

    uint256 public _superiorMinBABY = 100e18; //The superior must obtain the min BABY that should be pledged for invitation rewards

    struct UserInfo {
        uint128 stakingPower;
        uint128 superiorSP;
        address superior;
        uint256 credit;
        uint256 creditDebt;
    }

    // ============ Events ============

    event MintVBABY(
        address user,
        address superior,
        uint256 mintBABY,
        uint256 totalStakingPower
    );
    event RedeemVBABY(
        address user,
        uint256 receiveBABY,
        uint256 burnBABY,
        uint256 feeBABY,
        uint256 reserveBABY,
        uint256 totalStakingPower
    );
    event DonateBABY(address user, uint256 donateBABY);
    event SetCanTransfer(bool allowed);

    event PreDeposit(uint256 babyAmount);
    event ChangePerReward(uint256 babyPerBlock);
    event UpdateBABYFeeBurnRatio(uint256 babyFeeBurnRatio);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    // ============ Modifiers ============

    modifier canTransfer() {
        require(_canTransfer, "vBABYToken: not the allowed transfer");
        _;
    }

    modifier balanceEnough(address account, uint256 amount) {
        require(
            availableBalanceOf(account) >= amount,
            "vBABYToken: available amount not enough"
        );
        _;
    }

    event TokenInfo(uint256 babyTokenSupply, uint256 babyBalanceInVBaby);
    event CurrentUserInfo(
        address user,
        uint128 stakingPower,
        uint128 superiorSP,
        address superior,
        uint256 credit,
        uint256 creditDebt
    );

    function logTokenInfo(IERC20 token) internal {
        emit TokenInfo(token.totalSupply(), token.balanceOf(address(this)));
    }

    function logCurrentUserInfo(address user) internal {
        UserInfo storage currentUser = userInfo[user];
        emit CurrentUserInfo(
            user,
            currentUser.stakingPower,
            currentUser.superiorSP,
            currentUser.superior,
            currentUser.credit,
            currentUser.creditDebt
        );
    }

    // ============ Constructor ============

    constructor(
        address babyToken,
        address babyTeam,
        address babyReserve,
        address babyTreasury
    ) {
        _babyToken = babyToken;
        _babyTeam = babyTeam;
        _babyReserve = babyReserve;
        _babyTreasury = babyTreasury;
        changePerReward(2 * 10**18);
    }

    // ============ Ownable Functions ============`

    function setCanTransfer(bool allowed) public onlyOwner {
        _canTransfer = allowed;
        emit SetCanTransfer(allowed);
    }

    function changePerReward(uint256 babyPerBlock) public onlyOwner {
        _updateAlpha();
        _babyPerBlock = babyPerBlock;
        logTokenInfo(IERC20(_babyToken));
        emit ChangePerReward(babyPerBlock);
    }

    function updateBABYFeeBurnRatio(uint256 babyFeeBurnRatio) public onlyOwner {
        _babyFeeBurnRatio = babyFeeBurnRatio;
        emit UpdateBABYFeeBurnRatio(_babyFeeBurnRatio);
    }

    function updateBABYFeeReserveRatio(uint256 babyFeeReserve)
        public
        onlyOwner
    {
        _babyFeeReserveRatio = babyFeeReserve;
    }

    function updateTeamAddress(address team) public onlyOwner {
        _babyTeam = team;
    }

    function updateTreasuryAddress(address treasury) public onlyOwner {
        _babyTreasury = treasury;
    }

    function updateReserveAddress(address newAddress) public onlyOwner {
        _babyReserve = newAddress;
    }

    function setSuperiorMinBABY(uint256 val) public onlyOwner {
        _superiorMinBABY = val;
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 babyBalance = IERC20(_babyToken).balanceOf(address(this));
        IERC20(_babyToken).safeTransfer(owner(), babyBalance);
    }

    // ============ Mint & Redeem & Donate ============

    function mint(uint256 babyAmount, address superiorAddress) public {
        require(
            superiorAddress != address(0) && superiorAddress != msg.sender,
            "vBABYToken: Superior INVALID"
        );
        require(babyAmount >= 1e18, "vBABYToken: must mint greater than 1");

        UserInfo storage user = userInfo[msg.sender];

        if (user.superior == address(0)) {
            require(
                superiorAddress == _babyTeam ||
                    userInfo[superiorAddress].superior != address(0),
                "vBABYToken: INVALID_SUPERIOR_ADDRESS"
            );
            user.superior = superiorAddress;
        }

        if (_superiorMinBABY > 0) {
            uint256 curBABY = babyBalanceOf(user.superior);
            if (curBABY < _superiorMinBABY) {
                user.superior = _babyTeam;
            }
        }

        _updateAlpha();

        IERC20(_babyToken).safeTransferFrom(
            msg.sender,
            address(this),
            babyAmount
        );

        uint256 newStakingPower = DecimalMath.divFloor(babyAmount, alpha);

        _mint(user, newStakingPower);

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(msg.sender);
        logCurrentUserInfo(user.superior);
        emit MintVBABY(
            msg.sender,
            superiorAddress,
            babyAmount,
            _totalStakingPower
        );
    }

    function redeem(uint256 vBabyAmount, bool all)
        public
        balanceEnough(msg.sender, vBabyAmount)
    {
        _updateAlpha();
        UserInfo storage user = userInfo[msg.sender];

        uint256 babyAmount;
        uint256 stakingPower;

        if (all) {
            stakingPower = uint256(user.stakingPower).sub(
                DecimalMath.divFloor(user.credit, alpha)
            );
            babyAmount = DecimalMath.mulFloor(stakingPower, alpha);
        } else {
            babyAmount = vBabyAmount.mul(_babyRatio);
            stakingPower = DecimalMath.divFloor(babyAmount, alpha);
        }

        _redeem(user, stakingPower);

        (
            uint256 babyReceive,
            uint256 burnBabyAmount,
            uint256 withdrawFeeAmount,
            uint256 reserveAmount
        ) = getWithdrawResult(babyAmount);

        IERC20(_babyToken).safeTransfer(msg.sender, babyReceive);

        if (burnBabyAmount > 0) {
            IERC20(_babyToken).safeTransfer(hole, burnBabyAmount);
        }
        if (reserveAmount > 0) {
            IERC20(_babyToken).safeTransfer(_babyReserve, reserveAmount);
        }

        if (withdrawFeeAmount > 0) {
            alpha = uint112(
                uint256(alpha).add(
                    DecimalMath.divFloor(withdrawFeeAmount, _totalStakingPower)
                )
            );
        }

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(msg.sender);
        logCurrentUserInfo(user.superior);
        emit RedeemVBABY(
            msg.sender,
            babyReceive,
            burnBabyAmount,
            withdrawFeeAmount,
            reserveAmount,
            _totalStakingPower
        );
    }

    function donate(uint256 babyAmount) public {
        IERC20(_babyToken).safeTransferFrom(
            msg.sender,
            address(this),
            babyAmount
        );

        alpha = uint112(
            uint256(alpha).add(
                DecimalMath.divFloor(babyAmount, _totalStakingPower)
            )
        );
        logTokenInfo(IERC20(_babyToken));
        emit DonateBABY(msg.sender, babyAmount);
    }

    function totalSupply() public view returns (uint256 vBabySupply) {
        uint256 totalBaby = IERC20(_babyToken).balanceOf(address(this));
        (, uint256 curDistribution) = getLatestAlpha();

        uint256 actualBaby = totalBaby.add(curDistribution);
        vBabySupply = actualBaby / _babyRatio;
    }

    function balanceOf(address account)
        public
        view
        returns (uint256 vBabyAmount)
    {
        vBabyAmount = babyBalanceOf(account) / _babyRatio;
    }

    function transfer(address to, uint256 vBabyAmount) public returns (bool) {
        _updateAlpha();
        _transfer(msg.sender, to, vBabyAmount);
        return true;
    }

    function approve(address spender, uint256 vBabyAmount)
        public
        canTransfer
        returns (bool)
    {
        _allowed[msg.sender][spender] = vBabyAmount;
        emit Approval(msg.sender, spender, vBabyAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 vBabyAmount
    ) public returns (bool) {
        require(
            vBabyAmount <= _allowed[from][msg.sender],
            "ALLOWANCE_NOT_ENOUGH"
        );
        _updateAlpha();
        _transfer(from, to, vBabyAmount);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(
            vBabyAmount
        );
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    // ============ Helper Functions ============

    function getLatestAlpha()
        public
        view
        returns (uint256 newAlpha, uint256 curDistribution)
    {
        if (_lastRewardBlock == 0) {
            curDistribution = 0;
        } else {
            curDistribution = _babyPerBlock * (block.number - _lastRewardBlock);
        }
        if (_totalStakingPower > 0) {
            newAlpha = uint256(alpha).add(
                DecimalMath.divFloor(curDistribution, _totalStakingPower)
            );
        } else {
            newAlpha = alpha;
        }
    }

    function availableBalanceOf(address account)
        public
        view
        returns (uint256 vBabyAmount)
    {
        vBabyAmount = balanceOf(account);
    }

    function babyBalanceOf(address account)
        public
        view
        returns (uint256 babyAmount)
    {
        UserInfo memory user = userInfo[account];
        (uint256 newAlpha, ) = getLatestAlpha();
        uint256 nominalBaby = DecimalMath.mulFloor(
            uint256(user.stakingPower),
            newAlpha
        );
        if (nominalBaby > user.credit) {
            babyAmount = nominalBaby - user.credit;
        } else {
            babyAmount = 0;
        }
    }

    function getWithdrawResult(uint256 babyAmount)
        public
        view
        returns (
            uint256 babyReceive,
            uint256 burnBabyAmount,
            uint256 withdrawFeeBabyAmount,
            uint256 reserveBabyAmount
        )
    {
        uint256 feeRatio = _feeRatio;

        withdrawFeeBabyAmount = DecimalMath.mulFloor(babyAmount, feeRatio);
        babyReceive = babyAmount.sub(withdrawFeeBabyAmount);

        burnBabyAmount = DecimalMath.mulFloor(
            withdrawFeeBabyAmount,
            _babyFeeBurnRatio
        );
        reserveBabyAmount = DecimalMath.mulFloor(
            withdrawFeeBabyAmount,
            _babyFeeReserveRatio
        );

        withdrawFeeBabyAmount = withdrawFeeBabyAmount.sub(burnBabyAmount);
        withdrawFeeBabyAmount = withdrawFeeBabyAmount.sub(reserveBabyAmount);
    }

    function setRatioValue(uint256 ratioFee) public onlyOwner {
        _feeRatio = ratioFee;
    }

    function getSuperior(address account)
        public
        view
        returns (address superior)
    {
        return userInfo[account].superior;
    }

    // ============ Internal Functions ============

    function _updateAlpha() internal {
        (uint256 newAlpha, uint256 curDistribution) = getLatestAlpha();
        uint256 newTotalDistribution = curDistribution.add(
            _totalBlockDistribution
        );
        require(
            newAlpha <= uint112(-1) && newTotalDistribution <= uint112(-1),
            "OVERFLOW"
        );
        alpha = uint112(newAlpha);
        _totalBlockDistribution = uint112(newTotalDistribution);
        _lastRewardBlock = uint32(block.number);

        if (curDistribution > 0) {
            IERC20(_babyToken).safeTransferFrom(
                _babyTreasury,
                address(this),
                curDistribution
            );

            _totalBlockReward = _totalBlockReward.add(curDistribution);
            logTokenInfo(IERC20(_babyToken));
            emit PreDeposit(curDistribution);
        }
    }

    function _mint(UserInfo storage to, uint256 stakingPower) internal {
        require(stakingPower <= uint128(-1), "OVERFLOW");
        UserInfo storage superior = userInfo[to.superior];
        uint256 superiorIncreSP = DecimalMath.mulFloor(
            stakingPower,
            _superiorRatio
        );
        uint256 superiorIncreCredit = DecimalMath.mulFloor(
            superiorIncreSP,
            alpha
        );

        to.stakingPower = uint128(uint256(to.stakingPower).add(stakingPower));
        to.superiorSP = uint128(uint256(to.superiorSP).add(superiorIncreSP));

        superior.stakingPower = uint128(
            uint256(superior.stakingPower).add(superiorIncreSP)
        );
        superior.credit = uint128(
            uint256(superior.credit).add(superiorIncreCredit)
        );

        _totalStakingPower = _totalStakingPower.add(stakingPower).add(
            superiorIncreSP
        );
    }

    function _redeem(UserInfo storage from, uint256 stakingPower) internal {
        from.stakingPower = uint128(
            uint256(from.stakingPower).sub(stakingPower)
        );

        uint256 userCreditSP = DecimalMath.divFloor(from.credit, alpha);
        if (from.stakingPower > userCreditSP) {
            from.stakingPower = uint128(
                uint256(from.stakingPower).sub(userCreditSP)
            );
        } else {
            userCreditSP = from.stakingPower;
            from.stakingPower = 0;
        }
        from.creditDebt = from.creditDebt.add(from.credit);
        from.credit = 0;

        // superior decrease sp = min(stakingPower*0.1, from.superiorSP)
        uint256 superiorDecreSP = DecimalMath.mulFloor(
            stakingPower,
            _superiorRatio
        );
        superiorDecreSP = from.superiorSP <= superiorDecreSP
            ? from.superiorSP
            : superiorDecreSP;
        from.superiorSP = uint128(
            uint256(from.superiorSP).sub(superiorDecreSP)
        );
        uint256 superiorDecreCredit = DecimalMath.mulFloor(
            superiorDecreSP,
            alpha
        );

        UserInfo storage superior = userInfo[from.superior];
        if (superiorDecreCredit > superior.creditDebt) {
            uint256 dec = DecimalMath.divFloor(superior.creditDebt, alpha);
            superiorDecreSP = dec >= superiorDecreSP
                ? 0
                : superiorDecreSP.sub(dec);
            superiorDecreCredit = superiorDecreCredit.sub(superior.creditDebt);
            superior.creditDebt = 0;
        } else {
            superior.creditDebt = superior.creditDebt.sub(superiorDecreCredit);
            superiorDecreCredit = 0;
            superiorDecreSP = 0;
        }
        uint256 creditSP = DecimalMath.divFloor(superior.credit, alpha);

        if (superiorDecreSP >= creditSP) {
            superior.credit = 0;
            superior.stakingPower = uint128(
                uint256(superior.stakingPower).sub(creditSP)
            );
        } else {
            superior.credit = uint128(
                uint256(superior.credit).sub(superiorDecreCredit)
            );
            superior.stakingPower = uint128(
                uint256(superior.stakingPower).sub(superiorDecreSP)
            );
        }

        _totalStakingPower = _totalStakingPower
            .sub(stakingPower)
            .sub(superiorDecreSP)
            .sub(userCreditSP);
    }

    function _transfer(
        address from,
        address to,
        uint256 vBabyAmount
    ) internal canTransfer balanceEnough(from, vBabyAmount) {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(from != to, "transfer from same with to");

        uint256 stakingPower = DecimalMath.divFloor(
            vBabyAmount * _babyRatio,
            alpha
        );

        UserInfo storage fromUser = userInfo[from];
        UserInfo storage toUser = userInfo[to];

        _redeem(fromUser, stakingPower);
        _mint(toUser, stakingPower);

        logTokenInfo(IERC20(_babyToken));
        logCurrentUserInfo(from);
        logCurrentUserInfo(fromUser.superior);
        logCurrentUserInfo(to);
        logCurrentUserInfo(toUser.superior);
        emit Transfer(from, to, vBabyAmount);
    }
}