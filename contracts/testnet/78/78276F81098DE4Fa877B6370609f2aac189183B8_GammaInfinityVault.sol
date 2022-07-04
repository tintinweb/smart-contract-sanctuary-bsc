/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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
        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.8.0;

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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/Pausable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IPlanetFinance {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingGAMMA(uint256 _pid, address _user) external view returns (uint256);
    
    function stakedWantTokens(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

interface Gtoken {
    
    function underlying() external view returns(address);

    function mint(uint mintAmount) external returns (uint);

}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface GammaTroller {
    function claimGamma(address[] memory holders,address[] memory gTokens,bool borrowers,bool suppliers) external;
    function updateFactor(address _user, uint256 _newiGammaBalance) external;

}

contract GammaInfinityVault is Pausable,Ownable,ERC20 {

    using SafeERC20 for IERC20;

    uint256 public pid;

    uint256 public constant initialExchangeRate = 1e8;

    uint256 public feeRewards = 0;

    uint256 public feeRewardsAccruedPerWeek;
    uint256 public feeRewardsAccrued;

   /*
    * Fee Variables:- 
    */

    uint256 public depositFee = 10; // 0.1%;

    uint256 public instantWithdrawFee = 500; // 5%;

    uint256 public normalWithdrawFee = 100; // 1%;

    uint256 public performanceFee = 1000; //10%

   /*
    * Fee Variables Max Values:- 
    */

    uint256 public immutable depositFeeMax = 20; //0.2%

    uint256 public immutable instantWithdrawFeeMax = 1000; //10%

    uint256 public immutable normalWithdrawFeeMax = 200; //2%

    uint256 public immutable performanceFeeMax = 2500; //25%

   /*
    * Min Withdraw Time:- 
    */
    
    uint256 public minTimeToWithdraw = 21 days;

   /*
    * Min Withdraw Time Max Value:- 
    */
    

    uint256 public minTimeToWithdrawUL = 365 days;

   /*
    * Addresses where the fee will go:- 
    */

    address public depositFeeAddress;

    address public withdrawFeeAddress;

    address public performanceFeeAddress;

    address public feeRewardsUpdater;

    address public gamma;

    IERC20 public gToken;
    
    IPlanetFinance public immutable planetFinance;

    GammaTroller public gammaTroller;

    struct UserInfo {
        uint256 iTokenToBeUnstaked; // keep track how much amount of iToken user has to redeem for gToken
        uint256 unstakeStartTime;  //keep track of timestamp at which unstake function is clicked
        uint256 minTimeToWithdraw; //keep track of minTimeToWithdraw at which unstake function is clicked
        uint256 gTokenToBeUnstaked; //store gToken amount user has given for unstaking
    }

    mapping(address => UserInfo) public userInfo;

    //addresses of infinity vault(aqua),farm vaults
    mapping(address => bool) public authorized;

    event Deposit(address indexed sender, uint256 amount, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount);
    event StartUnstake(address indexed sender,uint amount);
    event StopUnstake(address indexed sender);
    event minTimeToWithdrawChanged(uint256 oldMinTimeToWithdraw,uint256 newMinTimeToWithdraw);
    event SetSettings(uint256 normalWithdrawFee,uint256 instantWithdrawFee,uint256 performanceFee,uint depositFee);
    event DepositFeeAddressChanged(address oldDepositFeeAddress,address newDepositFeeAddress);
    event WithdrawFeeAddressChanged(address oldWithdrawFeeAddress,address newWithdrawFeeAddress);
    event PerformanceFeeAddressChanged(address oldPerformanceFeeAddress,address newPerformanceFeeAddress);
    event AuthorizationToggled(address _vault,bool prev,bool curr);
    event Harvest(address indexed sender, uint256 performanceFee);
    event Fail();
    event Pause();
    event Unpause();

    constructor(string memory name,
                string memory symbol,
                address _gToken,
                address _depositFeeAddress,
                address _withdrawFeeAddress,
                address _performanceFeeAddress,
                address _gamma,
                address _planetFinance,
                uint256 _pid,
                GammaTroller _gammaTroller) ERC20(name,symbol) {
        
        gToken = IERC20(_gToken);
        depositFeeAddress = _depositFeeAddress;
        withdrawFeeAddress = _withdrawFeeAddress;
        performanceFeeAddress = _performanceFeeAddress;
        planetFinance = IPlanetFinance(_planetFinance);
        gamma = _gamma;
        pid = _pid;
        gammaTroller =_gammaTroller;

        address underlying = Gtoken(_gToken).underlying();
        IERC20(underlying).safeApprove(_gToken,type(uint256).max);

        gToken.safeApprove(_planetFinance, type(uint256).max);

        emit DepositFeeAddressChanged(address(0),depositFeeAddress);
        emit WithdrawFeeAddressChanged(address(0),withdrawFeeAddress);
        emit PerformanceFeeAddressChanged(address(0), performanceFeeAddress);
    }

    function check_unstaking_bal_when_transfer(address senderAddress,uint256 amount) internal {

        UserInfo storage user = userInfo[senderAddress];
        
        if(user.iTokenToBeUnstaked > 0 && balanceOf(senderAddress) >= user.iTokenToBeUnstaked) {
            
            //if user has some iToken in unstaking process 
            uint256 amount_user_can_transfer = balanceOf(senderAddress) - user.iTokenToBeUnstaked;
            
            if(amount > amount_user_can_transfer){
                stopUnstakeProcessInternal(senderAddress);
            }

        }
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        //Transfer given iToken Amount from sender to recipient wallet
        check_unstaking_bal_when_transfer(_msgSender(),amount);
        _transfer(_msgSender(), recipient, amount);
        gammaTroller.updateFactor(_msgSender(),balanceOf(_msgSender()));
        gammaTroller.updateFactor(recipient,balanceOf(recipient));
        return true;
    }
    
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        
        uint256 currentAllowance = allowance(sender,_msgSender());
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        //Transfer given iToken Amount from sender to recipient wallet
        check_unstaking_bal_when_transfer(sender,amount);
        _transfer(sender, recipient, amount);
        gammaTroller.updateFactor(sender,balanceOf(sender));
        gammaTroller.updateFactor(recipient,balanceOf(recipient));
        return true;
    }

   /**
    * @notice this will toggle vault authorized status 
    *         in the contract it is called by owner address only
    */
    function updateAuthorizedAddress(address _vault) external onlyOwner {
        require(_vault != address(0),"_vault should no be zero address");
        bool prev = authorized[_vault];
        authorized[_vault] = !prev;
        emit AuthorizationToggled(_vault, prev, !prev);
    }

   /**
    * @notice this will change fee rewards updater address
    *         in the contract it is called by owner address only
    */
    function changeFeeRewardsUpdater(address _newFeeRewardsUpdater) external onlyOwner {
        feeRewardsUpdater = _newFeeRewardsUpdater;
    }

   /**
    * @notice this will update feeRewardsAccruedPerWeek value
    *         in the contract it is called by feeRewardsUpdater address only
    */
    function updateFeeRewards() external {
        require(msg.sender == feeRewardsUpdater,"Caller is not fee rewards updater");
        if(feeRewardsAccrued > 0){
            feeRewardsAccruedPerWeek = feeRewardsAccrued;
            feeRewardsAccrued = 0;
        }
    }

   /**
    * @notice this will change deposit fee address
    *         in the contract it is called by owner address only
    */
    function changeDepositFeeAddress(address _newDepositFeeAddress) external onlyOwner {
        require(_newDepositFeeAddress != address(0),"_newDepositFeeAddress should no be zero address");
        emit DepositFeeAddressChanged(depositFeeAddress,_newDepositFeeAddress);
        depositFeeAddress = _newDepositFeeAddress;
    }

   /**
    * @notice this will change withdraw fee address
    *         in the contract it is called by owner address only
    */
    function changeWithdrawFeeAddress(address _newWithdrawFeeAddress) external onlyOwner {
        require(_newWithdrawFeeAddress != address(0),"_newWithdrawFeeAddress should no be zero address");
        emit WithdrawFeeAddressChanged(withdrawFeeAddress,_newWithdrawFeeAddress);
        withdrawFeeAddress = _newWithdrawFeeAddress;
    }

    /**
    * @notice this will change performance fee address
    *         in the contract it is called by owner address only
    */
    function changePerformanceFeeAddress(address _newPerformanceFeeAddress) external onlyOwner {
        require(_newPerformanceFeeAddress != address(0),"_newPerformanceFeeAddress should no be zero address");
        emit PerformanceFeeAddressChanged(performanceFeeAddress,_newPerformanceFeeAddress);
        performanceFeeAddress = _newPerformanceFeeAddress;
    }

   /**
    * @notice this will change normal withdraw,instant withdraw,performance and deposit fee values
    *         in the contract it is called by owner address only
    */
    function setSettings(uint256 _normalWithdrawFee,uint256 _instantWithdrawFee,uint256 _performanceFee,uint256 _depositFee) external onlyOwner {
        require(
            _normalWithdrawFee <= normalWithdrawFeeMax,
            "_normalWithdrawFee too high"
        );
        require(
            _instantWithdrawFee <= instantWithdrawFeeMax,
            "_instantWithdrawFee too high"
        );
        require(
            _performanceFee <= performanceFeeMax,
            "_performanceFee too high"
        );
        require(
            _depositFee <= depositFeeMax,
            "_deposit fee too high"
        );

        normalWithdrawFee = _normalWithdrawFee;
        instantWithdrawFee = _instantWithdrawFee;
        performanceFee = _performanceFee;
        depositFee = _depositFee;

        emit SetSettings(_normalWithdrawFee,_instantWithdrawFee,_performanceFee,_depositFee);
    }
   
   /**
    * @notice this will change min time to withdraw value
    *         in the contract it is called by owner address only
    */
    function setMinTimeToWithdraw(uint256 newMinTimeToWithdraw) external onlyOwner{
        require(newMinTimeToWithdraw <= minTimeToWithdrawUL, "too high");
        emit minTimeToWithdrawChanged(minTimeToWithdraw, newMinTimeToWithdraw);
        minTimeToWithdraw = newMinTimeToWithdraw;
    }

   /**
    * @notice Checks if the _msgSender() is a contract or a proxy
    */
    modifier notContract() {
        require(!_isContract(_msgSender()), "contract not allowed");
        require(_msgSender() == tx.origin, "proxy contract not allowed");
        _;
    }

       /**
    * @notice Checks if the _msgSender() is authorized or not
    */
    modifier onlyAuthorized() {
        require(authorized[_msgSender()] == true, "only authorized vault is allowed");
        _;
    }

   /**
    * @notice this will return availaible gToken balance in this contract
    * @return (calculated gTokens balance held by the contract scaled by gToken decimals)
    */
    function available() public view returns (uint256) {
        return gToken.balanceOf(address(this));
    }

   /**
    * @notice Calculates the total gTokens
    * @dev It includes tokens held by the contract and held in Main Farm
    * @return (calculated gTokens balance held by the contract and held in Main Farm scaled by gToken decimals)
    */
    function balanceOfGtoken() public view returns (uint256) {
        (uint256 amount) = IPlanetFinance(planetFinance).stakedWantTokens(pid, address(this));
        return gToken.balanceOf(address(this)) + (amount);
    }

   /**
    * @notice Calculates the exchange rate from the gToken to the iToken
    * @return (calculated exchange rate scaled by 1e18)
    */
    function iTokenExchangeRate() public view returns (uint) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
           /**
            * If there are no iTokens minted:
            *  exchangeRate = initialExchangeRate
            */
            return (initialExchangeRate); //1e8
        } else {
           /*
            * Otherwise:
            *  exchangeRate = (gToken Locked * 1e18) / totalSupply of iTokens
            */
            uint totalgToken = balanceOfGtoken();
            uint exchangeRate = (totalgToken * 1e18) / _totalSupply;
            return exchangeRate;
        }
    }

   
   /**
    * @notice Claim Pending GAMMA rewards from green planet
    */
    function _updateGammaTrollerRewards() external {

        address[] memory holders = new address[](1);
        holders[0] = address(this);

        address[] memory gTokens = new address[](1);
        gTokens[0] = address(gToken);
        
        gammaTroller.claimGamma(holders,gTokens, false, true);

    }

   /**
    * @notice Deposits funds into the this contract
    * @dev Only possible when contract not paused.
    * @param _amount: number of tokens to deposit (in gToken)
    */
    function deposit(uint256 _amount) external whenNotPaused notContract {

       /**
        * 1.check given amount should be greater than 0
        * 2.get initial exchange rate
        * 3.transfer given amount of tokens from user address to this contract
        * 4.calculate deposit fee , transfer it to deposit fee address and update 
        *   the given amount variable by subtracting fee amount from it
        * 5.calculate number of itokens to be minted.
        * 6.mint calculated number of itokens
        */
        
        require(_amount > 0, "Nothing to deposit");

        uint initial_exchange = iTokenExchangeRate();

        gToken.safeTransferFrom(_msgSender(), address(this), _amount);
        uint gTokenFee = (_amount * depositFee) / 10000;
        gToken.safeTransfer(depositFeeAddress,gTokenFee);
        _amount = _amount - gTokenFee;

        uint256 mintAmount = (_amount * 1e18) / initial_exchange;
        _mint(_msgSender(),mintAmount);
        gammaTroller.updateFactor(_msgSender(),balanceOf(_msgSender()));


        _earn();

        emit Deposit(_msgSender(), _amount, block.timestamp);
    }

    /**
     * @notice Only authorized addresses or contracts can Deposit funds into the this contract
     * @dev Only possible when contract not paused.
     * @param userAddress: address of the user who is transferring their rewards into this contract
     * @param _amount: number of tokens to deposit (in gamma token scaled by 1e18)
     */
    function depositAuthorized(address userAddress,uint256 _amount) external whenNotPaused onlyAuthorized {

       /**
        * 1.check given amount should be greater than 0
        * 2.transfer given amount of gamma tokens from sender to this contract
        * 3.call mint function of gamma market and mint gTokens according to given amount of GAMMA tokens
        * 4.calculate number of gTokens we get by calling mint
        * 5.calculate number of itokens to be minted.
        * 6.mint calculated number of itokens to the given user address
        * 7.deposit those tokens back in the farm pool
        */
        
        require(_amount > 0, "Nothing to deposit");

        address underlying = Gtoken(address(gToken)).underlying();

        IERC20(underlying).safeTransferFrom(_msgSender(), address(this), _amount);

        uint256 gTokenBalBefore = gToken.balanceOf(address(this));

        Gtoken(address(gToken)).mint(_amount);

        uint256 gTokenBalAfter = gToken.balanceOf(address(this));

        _amount = gTokenBalAfter - gTokenBalBefore; 

        uint256 mintAmount = (_amount * 1e18) / iTokenExchangeRate();
        _mint(userAddress,mintAmount);
        gammaTroller.updateFactor(userAddress,balanceOf(userAddress));


        _earn();

        emit Deposit(userAddress, _amount, block.timestamp);
    }

    /**
     * @notice Deposits tokens into Planet Finance gToken pool on farm to earn staking rewards
     */
    function _earn() internal {

       /*
        * It deposits gTokens present in this contract to farm pool
        */
        uint256 bal = available();
        if (bal > 0) {
            IPlanetFinance(planetFinance).deposit(pid, bal);
        }
    }

    /**
     * @notice Reinvests GAMMA tokens into PlanetFinance
     * @dev Only possible when contract not paused.
     */
    function harvest() external notContract whenNotPaused {

       /**
        * claim pending rewards from farm in form of GAMMA
        * then give entire GAMMA balance in mint function
        * transfer the performance fee from the gToken balance
        * then deposits entire gToken balance into the farm pool
        */
        IPlanetFinance(planetFinance).deposit(pid, 0);

        uint256 bal = IERC20(gamma).balanceOf(address(this));

        uint fee;

        //invest GAMMA into gTOKEN
        if (bal > 0) {
            uint gTokenBalBefore = gToken.balanceOf(address(this));
            Gtoken(address(gToken)).mint(bal);
            uint gTokenBalAfter = gToken.balanceOf(address(this));
            uint gTokenBal = gTokenBalAfter - gTokenBalBefore;
            fee = (gTokenBal * performanceFee) / 10000;
            gToken.safeTransfer(performanceFeeAddress,fee);
        }

        _earn();

        emit Harvest(_msgSender(), fee);
    }

    /**
     * @notice Withdraws from PlanetFinance Farm to Vault without caring about rewards.
     * @dev EMERGENCY ONLY. Only callable by the contract owner.
     */
    function emergencyWithdraw() external onlyOwner {
        IPlanetFinance(planetFinance).emergencyWithdraw(pid);
    }

    
    /**
     * @notice Unstake Your given gToken Instantly
     * @param unstakegTokenAmount: number of gToken call want to unstake instantly
     */
    function unstakeInstantly(uint256 unstakegTokenAmount) external notContract{

       /*
        * check given amount is greater than 0
        * if require gtoken balance is less than contract's
        * availaible gtoken balance then we withdraw left out amount from farm
        * calculate itokens amount according to this gtokenamount
        * burn these amounts of itokens
        * decrement the fees and transfer the amount to user
        */
        
        UserInfo storage user = userInfo[_msgSender()];
        uint useriTokenBalance = balanceOf(_msgSender());
        
        require(unstakegTokenAmount > 0,"Unstake Amount should be greater than 0");

        uint256 bal = available();
        if (bal < unstakegTokenAmount) {
            uint256 balWithdraw = unstakegTokenAmount - bal;
            IPlanetFinance(planetFinance).withdraw(pid, balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
                unstakegTokenAmount = bal + diff;
            }
        }

        uint256 iTokenToUnstake = (unstakegTokenAmount * 1e18) / iTokenExchangeRate();
        require(useriTokenBalance - user.iTokenToBeUnstaked >= iTokenToUnstake,
        "Unstake Amount should be greater than user can unstake more");

        _burn(_msgSender(),iTokenToUnstake);
        gammaTroller.updateFactor(_msgSender(),balanceOf(_msgSender()));


        uint gTokenFee = (unstakegTokenAmount * instantWithdrawFee) / 10000;

        //transfer 50% gtokenfee to fee address
        uint actualFee = gTokenFee / 2;
        gToken.safeTransfer(withdrawFeeAddress,actualFee);

        feeRewards += actualFee;
        feeRewardsAccrued += actualFee;

        unstakegTokenAmount -= gTokenFee;        

        gToken.safeTransfer(_msgSender(),unstakegTokenAmount);
        emit Withdraw(_msgSender(), unstakegTokenAmount);

    }

    /**
     * @notice Starts unstaking phase for caller for specific iToken of user
     * @param unstakegTokenAmount: number of gToken given for unstake phase
     */
    function startUnstakeProcess(uint256 unstakegTokenAmount) external notContract{

       /*
        * calculate itokens amount to be burned according to given amount of 
        * gtokenamount
        */

        UserInfo storage user = userInfo[_msgSender()];

        uint useriTokenBalance = balanceOf(_msgSender());

        uint256 unstakeItokenAmount = (unstakegTokenAmount * 1e18) / iTokenExchangeRate();
                 
        require(unstakeItokenAmount > 0,"!!Unstake iToken Amount should be greater than zero");
        
        //iTokens user has already given for unstake
        uint256 iTokenAlreadyGivenForUnstake = user.iTokenToBeUnstaked; 

        require(useriTokenBalance > iTokenAlreadyGivenForUnstake,
        "User iToken balance should be greater than iTokens amount already given for unstake");

        //amount of gToken user can unstake more
        uint256 iTokenUserCanUnstakeMore = useriTokenBalance - iTokenAlreadyGivenForUnstake;

        require(unstakeItokenAmount <= iTokenUserCanUnstakeMore,
        "unstakeItokenAmount should be less than or equal to iTokens user can unstake more");
    
        //Do the main work

        user.iTokenToBeUnstaked += unstakeItokenAmount;
        user.unstakeStartTime = block.timestamp;
        user.minTimeToWithdraw = minTimeToWithdraw;
        user.gTokenToBeUnstaked += unstakegTokenAmount;
        
        emit StartUnstake(_msgSender(),user.iTokenToBeUnstaked);
    }

    /**
     * @notice stops unstaking phase for caller if unstake phase is already started
     */
    function stopUnstakeProcess() external notContract {

       /*
        * Stop ongoing unstake process if present for caller 
        */
        stopUnstakeProcessInternal(_msgSender());
    }

    function stopUnstakeProcessInternal(address userAddress) internal {

       /*
        * Stop ongoing unstake process if present for caller 
        */
        UserInfo storage user = userInfo[userAddress];
        require(user.iTokenToBeUnstaked > 0 , "No itokens are given for unstaking process yet !!");
        user.iTokenToBeUnstaked = 0;
        user.unstakeStartTime = 0;
        user.minTimeToWithdraw = 0;
        user.gTokenToBeUnstaked = 0;
        emit StopUnstake(userAddress);
    }

    function unstakeAfterMinWithdrawTime() external notContract{
        
        UserInfo storage user = userInfo[_msgSender()];
        uint itokens = user.iTokenToBeUnstaked;

        uint useriTokenBalance = balanceOf(_msgSender());
        
        require(itokens > 0,"Unstake Amount should be greater than zero");
        require(user.unstakeStartTime + user.minTimeToWithdraw < block.timestamp,
        "too early");

        uint256 currentAmount = user.gTokenToBeUnstaked;

        uint256 temp_exchange_rate  = (currentAmount * 1e18) / itokens;

        uint256 bal = available();
        if (bal < currentAmount) {
            uint256 balWithdraw = currentAmount - bal;
            IPlanetFinance(planetFinance).withdraw(pid, balWithdraw);
            uint256 balAfter = available();
            uint256 diff = balAfter - bal;
            if (diff < balWithdraw) {
                currentAmount = bal + diff;
            }
        }

        itokens = (currentAmount * 1e18) / temp_exchange_rate;

        require(itokens <= useriTokenBalance,"Withdraw amount exceeds balance");

        _burn(_msgSender(),itokens);
        gammaTroller.updateFactor(_msgSender(),balanceOf(_msgSender()));

        if(user.gTokenToBeUnstaked > currentAmount && user.iTokenToBeUnstaked > itokens){
       	   user.gTokenToBeUnstaked -= currentAmount;
           user.iTokenToBeUnstaked -= itokens;
	    }
        else{
       	   user.gTokenToBeUnstaked = 0;
           user.iTokenToBeUnstaked = 0;
       	   user.unstakeStartTime = 0;
       	   user.minTimeToWithdraw = 0;
        }

        uint gTokenFee = (currentAmount * normalWithdrawFee) / 10000;

        //transfer gtokenfee to fee address
        //transfer 50% gtokenfee to fee address
        uint actualFee = gTokenFee / 2;
        gToken.safeTransfer(withdrawFeeAddress,actualFee);

        feeRewards += actualFee;
        feeRewardsAccrued += actualFee;

        currentAmount -= gTokenFee;        

        gToken.safeTransfer(_msgSender(),currentAmount);
        emit Withdraw(_msgSender(), currentAmount);
    }

    /**
    * @notice Returns given user gToken balance
    * @param user: address of user for which gToken needs to be calculated
    */
    function getUserGtokenBal(address user) external view returns(uint256 gTokenBal) {
        
        uint useriTokenBalance = balanceOf(user);
        gTokenBal = (useriTokenBalance * iTokenExchangeRate()) / 1e18;
 
    }

    function getUserStakingGtokenBal(address userAddress) external view returns(uint256 gTokenBal) {
        
        UserInfo storage user = userInfo[userAddress];
        uint userStakingiTokenBalance = balanceOf(userAddress) - user.iTokenToBeUnstaked;
        gTokenBal = (userStakingiTokenBalance * iTokenExchangeRate()) / 1e18;
 
    }

    function getUserGtokenBalGivenForUnstaking(address user) external view returns(uint256 gTokenBal) {
        
        UserInfo memory _user = userInfo[user];
        gTokenBal = _user.gTokenToBeUnstaked;

    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(gToken), "Token cannot be same as deposit token");
        require(_token != gamma, "Token cannot be same as gamma token");
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_msgSender(), amount);
    }

   /**
    * @notice Triggers stopped state
    * @dev Only possible when contract not paused.
    */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Pause();
    }

   /**
    * @notice Returns to normal state
    * @dev Only possible when contract is paused.
    */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpause();
    }


    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}