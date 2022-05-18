/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT

// File: contracts/IPremiumTier.sol

pragma solidity ^0.8.0;

interface IPremiumTier {
    enum SubscriptionInterval {
        NULL,
        WEEK,
        MONTH,
        YEAR
    }

    struct SubscriptionRate {
        SubscriptionInterval interval;
        uint256 price;
    }

    struct SubscriptionTier {
        string name;
        SubscriptionRate[] rates;
    }

    struct TrialEligibility {
        SubscriptionInterval interval;
        uint256 amount;
    }

    struct Subscription {
        address user;
        uint256 tierId;
        SubscriptionInterval billingInterval;
        uint256 createdAt;
        uint256 creditRemaining;
        uint256 expiresAt;
        TrialEligibility trialEligibility;
    }

    struct SubscriptionInput {
        uint256 tierId;
        SubscriptionInterval billingInterval;
        uint256 creditRemaining;
        TrialEligibility trialEligibility;
    }

    // Read
    function subscriptionRate() external view returns (uint256);

    function unsubscribeFee() external view returns (uint256);

    function subscription(address user)
        external
        view
        returns (bool, Subscription memory);

    function subscriptionTiers()
        external
        view
        returns (SubscriptionTier[] memory);

    function trialEligibilityDefault()
        external
        view
        returns (TrialEligibility memory);

    // Write
    function startFreeTrial() external returns (bool);

    function subscribe(
        uint256 tierId,
        SubscriptionInterval interval,
        uint256 amount
    ) external returns (bool);

    function unsubscribe(uint256 amount) external returns (uint256);

    // Read (Admin Only)
    function subscribersTotal() external view returns (uint256);

    function getAllSubscribers(uint256[] calldata userIds)
        external
        view
        returns (Subscription[] memory);

    // Write (Admin Only)
    function collect(uint256[] calldata userIds)
        external
        returns (uint256 outputAmount);

    function setSubscription(
        address user,
        SubscriptionInput calldata subscriptionInput
    ) external returns (bool);

    function addSubscriptionTier(SubscriptionTier calldata subscriptionTier)
        external
        returns (uint256 tierId);

    function removeSubscriptionTier(uint256 tierId) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
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
}

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: contracts/PremiumTier.sol

pragma solidity ^0.8.0;







/*
    Trusted Node - Premium Tier Smart Contract
*/
contract PremiumTier is IPremiumTier, Context, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bool public initializing;

    IERC20 public token;
    address public feeCollector;

    bool private _billableUnitRoundUp; // true

    uint256 private _tierIdDefault; // 0
    SubscriptionInterval private _subscriptionIntervalDefault; // non-null

    bool private _includeUnsubscribeFeeForSubscriptionRate; // false

    uint256 private _unsubscribeFee;
    TrialEligibility private _trialEligibilityDefault; // WEEK, 1

    // State
    SubscriptionTier[] private _allSubscriptionTiers;

    mapping(uint256 => address) private _subscribers;
    uint256 private _subscribersTotal;

    mapping(address => Subscription) private _userSubscriptions;

    constructor(
        IERC20 token_,
        address feeCollector_,
        bool billableUnitRoundUp_,
        uint256 tierIdDefault_,
        SubscriptionInterval subscriptionIntervalDefault_,
        bool includeUnsubscribeFeeForSubscriptionRate_,
        uint256 unsubscribeFee_
    ) {
        require(
            Address.isContract(address(token_)),
            "token_ is not a contract"
        );
        require(feeCollector_ != address(0), "feeCollector_ is NULL");
        require(
            subscriptionIntervalDefault_ != SubscriptionInterval.NULL,
            "subscriptionIntervalDefault_ is NULL"
        );

        token = token_;
        feeCollector = feeCollector_;

        _billableUnitRoundUp = billableUnitRoundUp_;

        _tierIdDefault = tierIdDefault_;
        _subscriptionIntervalDefault = subscriptionIntervalDefault_;

        _includeUnsubscribeFeeForSubscriptionRate = includeUnsubscribeFeeForSubscriptionRate_;

        _unsubscribeFee = unsubscribeFee_;

        initializing = true;
    }

    function initialize(
        TrialEligibility calldata trialEligibilityDefault_,
        SubscriptionTier[] calldata allSubscriptionTiers_
    ) external onlyOwner {
        require(initializing, "already initialized");
        initializing = false;

        _trialEligibilityDefault = trialEligibilityDefault_;

        uint256 allSubscriptionTiersLength = allSubscriptionTiers_.length;
        for (uint256 i = 0; i < allSubscriptionTiersLength; i++) {
            _allSubscriptionTiers.push(allSubscriptionTiers_[i]);
        }
    }

    modifier isInitialized() {
        require(!initializing, "not initialized");
        _;
    }

    // ----- Math
    function subscriptionIntervalToSeconds(
        SubscriptionInterval subscriptionInterval
    ) private pure returns (uint256 s) {
        if (subscriptionInterval == SubscriptionInterval.NULL) {
            s = 0;
        } else if (subscriptionInterval == SubscriptionInterval.WEEK) {
            s = 604800;
        } else if (subscriptionInterval == SubscriptionInterval.MONTH) {
            s = 2629800;
        } else if (subscriptionInterval == SubscriptionInterval.YEAR) {
            s = 31557600;
        } else {
            s = 0;
        }
        return s;
    }

    function expiresAtNonTrial(
        uint256 createdAt,
        uint256 creditRemaining,
        SubscriptionRate memory rate
    ) private pure returns (uint256 expiresAt) {
        if (rate.price == 0) {
            return ~uint256(0);
        }

        expiresAt =
            createdAt +
            (creditRemaining / rate.price) *
            subscriptionIntervalToSeconds(rate.interval);
        return expiresAt;
    }

    // ----- Utils Views (Common)
    function getSubscriptionRate(
        uint256 tierId,
        SubscriptionInterval billingInterval
    ) private view returns (uint256) {
        if (billingInterval == SubscriptionInterval.NULL) {
            return 0;
        }

        SubscriptionRate[] memory rates = _allSubscriptionTiers[tierId].rates;
        uint256 ratesLength = rates.length;
        for (uint256 i = 0; i < ratesLength; i++) {
            SubscriptionRate memory rate = rates[i];
            if (rate.interval == billingInterval) {
                return rate.price;
            }
        }

        // shouldn't happen when rates are correctly configured
        return ~uint256(0);
    }

    function billableUnit(SubscriptionInterval billingInterval, uint256 elapsed)
        private
        view
        returns (uint256 unit)
    {
        uint256 subscriptionIntervalSeconds = subscriptionIntervalToSeconds(
            billingInterval
        );
        if (subscriptionIntervalSeconds == 0) {
            return 0;
        }

        unit = elapsed / subscriptionIntervalSeconds;
        if (_billableUnitRoundUp && elapsed % subscriptionIntervalSeconds > 0) {
            unit++;
        }

        return unit;
    }

    function billableAmount(
        SubscriptionRate memory rate,
        uint256 elapsed,
        bool useUnsubscribeFee
    ) private view returns (uint256 amount) {
        amount = billableUnit(rate.interval, elapsed) * rate.price;
        return
            // exempt not subscribed / trial
            useUnsubscribeFee && rate.interval != SubscriptionInterval.NULL
                ? amount + _unsubscribeFee
                : amount;
    }

    // ----- Utils Views (User)
    function isUserExists(address user) private view returns (bool) {
        return _userSubscriptions[user].user == user;
    }

    function userSubscriptionRate(address user) private view returns (uint256) {
        Subscription memory userSubscription = _userSubscriptions[user];
        return
            getSubscriptionRate(
                userSubscription.tierId,
                userSubscription.billingInterval
            );
    }

    function userBillableAmount(address user, bool useUnsubscribeFee)
        private
        view
        returns (uint256)
    {
        Subscription memory userSubscription = _userSubscriptions[user];
        return
            billableAmount(
                SubscriptionRate(
                    userSubscription.billingInterval,
                    userSubscriptionRate(user)
                ),
                Math.min(block.timestamp, userSubscription.expiresAt) -
                    userSubscription.createdAt,
                useUnsubscribeFee
            );
    }

    function isUserSubscriptionValid(address user) private view returns (bool) {
        Subscription memory userSubscription = _userSubscriptions[user];
        return
            userSubscription.createdAt != 0 &&
            userSubscription.expiresAt > block.timestamp &&
            userSubscription.creditRemaining >= userBillableAmount(user, false);
    }

    // ----- Utils Mutative (User)
    function addUserIfNotExists(address user) private {
        if (!isUserExists(user)) {
            _subscribers[_subscribersTotal] = user;
            _subscribersTotal++;

            _userSubscriptions[user].user = user;
        }
    }

    function deleteUserIfExists(address user) private {
        if (isUserExists(user)) {
            TrialEligibility memory trialEligibility = _userSubscriptions[user]
                .trialEligibility;

            delete _userSubscriptions[user];

            _userSubscriptions[user].user = user;
            _userSubscriptions[user].trialEligibility = trialEligibility;
        }
    }

    function _unsubscribe(
        address user,
        uint256 amount,
        bool useUnsubscribeFee,
        bool manualCollection
    ) private returns (uint256) {
        // require ---
        require(
            isUserExists(user),
            "PremiumTier::_unsubscribe() - unregistered"
        );

        // state ---
        Subscription storage userSubscription = _userSubscriptions[user];

        // optimistically deduct billable amount
        uint256 precollect = userSubscription.creditRemaining;
        (, userSubscription.creditRemaining) = SafeMath.trySub(
            userSubscription.creditRemaining,
            userBillableAmount(user, useUnsubscribeFee)
        );
        uint256 postcollect = userSubscription.creditRemaining;
        // amount should be less than or equal to credit remaining
        amount = Math.min(amount, userSubscription.creditRemaining);

        userSubscription.createdAt = block.timestamp;
        userSubscription.creditRemaining -= amount;
        userSubscription.expiresAt = expiresAtNonTrial(
            userSubscription.createdAt,
            userSubscription.creditRemaining,
            SubscriptionRate(
                userSubscription.billingInterval,
                userSubscriptionRate(user)
            )
        );

        // delete invalid subscription ---
        if (userSubscription.creditRemaining == 0) {
            deleteUserIfExists(user);
        }

        // send ---
        if (!manualCollection) {
            token.safeTransfer(feeCollector, precollect - postcollect);
        }
        if (amount > 0) {
            token.safeTransfer(user, amount);
        }

        return userSubscription.creditRemaining;
    }

    // ----- Read
    function subscriptionRate() external view returns (uint256) {
        return
            billableAmount(
                SubscriptionRate(
                    _subscriptionIntervalDefault,
                    getSubscriptionRate(
                        _tierIdDefault,
                        _subscriptionIntervalDefault
                    )
                ),
                subscriptionIntervalToSeconds(_subscriptionIntervalDefault),
                _includeUnsubscribeFeeForSubscriptionRate
            );
    }

    function unsubscribeFee() external view returns (uint256) {
        return _unsubscribeFee;
    }

    function subscription(address user)
        external
        view
        returns (bool, Subscription memory)
    {
        Subscription memory userSubscription = _userSubscriptions[user];
        (, userSubscription.creditRemaining) = SafeMath.trySub(
            userSubscription.creditRemaining,
            userBillableAmount(user, false)
        );
        return (isUserSubscriptionValid(user), userSubscription);
    }

    function subscriptionTiers()
        external
        view
        returns (SubscriptionTier[] memory)
    {
        return _allSubscriptionTiers;
    }

    function trialEligibilityDefault()
        external
        view
        returns (TrialEligibility memory)
    {
        return _trialEligibilityDefault;
    }

    // ----- Write
    function startFreeTrial()
        external
        nonReentrant
        isInitialized
        returns (bool)
    {
        // require ---
        if (!isUserExists(_msgSender())) {
            require(
                _trialEligibilityDefault.interval !=
                    SubscriptionInterval.NULL &&
                    _trialEligibilityDefault.amount > 0,
                "PremiumTier::startFreeTrial() - free trial unavailable"
            );
        } else {
            require(
                _userSubscriptions[_msgSender()].trialEligibility.interval !=
                    SubscriptionInterval.NULL &&
                    _userSubscriptions[_msgSender()].trialEligibility.amount >
                    0,
                "PremiumTier::startFreeTrial() - free trial unavailable"
            );
            require(
                !isUserSubscriptionValid(_msgSender()),
                "PremiumTier::startFreeTrial() - valid subscription in use"
            );
        }

        // add user & user trial eligibility | unsubscribe ---
        if (!isUserExists(_msgSender())) {
            addUserIfNotExists(_msgSender());
            _userSubscriptions[_msgSender()]
                .trialEligibility = _trialEligibilityDefault;
        } else {
            (, uint256 creditRemaining) = SafeMath.trySub(
                _userSubscriptions[_msgSender()].creditRemaining,
                userBillableAmount(_msgSender(), false)
            );
            if (creditRemaining > 0) {
                _unsubscribe(_msgSender(), creditRemaining, false, false);
            }
        }

        // state ---
        Subscription storage userSubscription = _userSubscriptions[
            _msgSender()
        ];

        userSubscription.tierId = _tierIdDefault;
        userSubscription.billingInterval = SubscriptionInterval.NULL;
        userSubscription.createdAt = block.timestamp;
        userSubscription.creditRemaining = 0;
        userSubscription.expiresAt =
            userSubscription.createdAt +
            userSubscription.trialEligibility.amount *
            subscriptionIntervalToSeconds(
                userSubscription.trialEligibility.interval
            );

        // revoke user trial eligibility ---
        delete userSubscription.trialEligibility;

        return true;
    }

    function subscribe(
        uint256 tierId,
        SubscriptionInterval interval,
        uint256 amount
    ) external nonReentrant isInitialized returns (bool) {
        // require ---
        require(
            tierId < _allSubscriptionTiers.length,
            "PremiumTier::subscribe() - invalid tierId"
        );
        require(
            interval != SubscriptionInterval.NULL,
            "PremiumTier::subscribe() - invalid interval"
        );

        // add user & user trial eligibility | unsubscribe & carry over ---
        if (!isUserExists(_msgSender())) {
            addUserIfNotExists(_msgSender());
            _userSubscriptions[_msgSender()]
                .trialEligibility = _trialEligibilityDefault;
        } else {
            (, uint256 creditRemaining) = SafeMath.trySub(
                _userSubscriptions[_msgSender()].creditRemaining,
                userBillableAmount(_msgSender(), false)
            );
            if (creditRemaining > 0) {
                _unsubscribe(_msgSender(), creditRemaining, false, false);
            }

            // carry over
            amount += creditRemaining;
        }

        // receive ---
        token.safeTransferFrom(_msgSender(), address(this), amount);

        // state ---
        Subscription storage userSubscription = _userSubscriptions[
            _msgSender()
        ];

        userSubscription.tierId = tierId;
        userSubscription.billingInterval = interval;
        userSubscription.createdAt = block.timestamp;
        userSubscription.creditRemaining = amount;
        userSubscription.expiresAt = expiresAtNonTrial(
            userSubscription.createdAt,
            userSubscription.creditRemaining,
            SubscriptionRate(
                userSubscription.billingInterval,
                userSubscriptionRate(_msgSender())
            )
        );

        return true;
    }

    function unsubscribe(uint256 amount)
        external
        nonReentrant
        isInitialized
        returns (uint256)
    {
        return _unsubscribe(_msgSender(), amount, true, false);
    }

    // ----- Read (Administrative)
    function subscribersTotal() external view onlyOwner returns (uint256) {
        return _subscribersTotal;
    }

    function getAllSubscribers(uint256[] calldata userIds)
        external
        view
        onlyOwner
        returns (Subscription[] memory)
    {
        Subscription[] memory allSubscribers = new Subscription[](
            userIds.length
        );

        uint256 userIdsLength = userIds.length;
        for (uint256 i = 0; i < userIdsLength; i++) {
            uint256 userId = userIds[i];
            require(
                userId < _subscribersTotal,
                "PremiumTier::getAllSubscribers() - userId out of range"
            );
            address user = _subscribers[userId];
            Subscription memory userSubscription = _userSubscriptions[user];
            (, userSubscription.creditRemaining) = SafeMath.trySub(
                userSubscription.creditRemaining,
                userBillableAmount(user, false)
            );
            allSubscribers[i] = userSubscription;
        }

        return allSubscribers;
    }

    // ----- Write (Administrative)
    function collect(uint256[] calldata userIds)
        external
        onlyOwner
        returns (uint256 outputAmount)
    {
        uint256 userIdsLength = userIds.length;
        for (uint256 i = 0; i < userIdsLength; i++) {
            uint256 userId = userIds[i];
            require(
                userId < _subscribersTotal,
                "PremiumTier::collect() - userId out of range"
            );
            address user = _subscribers[userId];
            uint256 creditRemaining = _userSubscriptions[user].creditRemaining;
            outputAmount +=
                creditRemaining -
                _unsubscribe(user, 0, false, true);
        }

        // send ---
        token.safeTransfer(feeCollector, outputAmount);

        return outputAmount;
    }

    function setSubscription(
        address user,
        SubscriptionInput calldata subscriptionInput
    ) external onlyOwner returns (bool) {
        if (subscriptionInput.billingInterval == SubscriptionInterval.NULL) {
            deleteUserIfExists(user);
            delete _userSubscriptions[user].trialEligibility;
        } else {
            addUserIfNotExists(user);

            Subscription storage userSubscription = _userSubscriptions[user];
            userSubscription.tierId = subscriptionInput.tierId;
            userSubscription.billingInterval = subscriptionInput
                .billingInterval;
            userSubscription.creditRemaining = subscriptionInput
                .creditRemaining;
            userSubscription.trialEligibility = subscriptionInput
                .trialEligibility;
        }

        return true;
    }

    function addSubscriptionTier(SubscriptionTier calldata subscriptionTier)
        external
        onlyOwner
        returns (uint256 tierId)
    {
        _allSubscriptionTiers.push(subscriptionTier);
        return _allSubscriptionTiers.length - 1;
    }

    function removeSubscriptionTier(uint256 tierId)
        external
        onlyOwner
        returns (bool)
    {
        uint256 allSubscriptionTiersLength = _allSubscriptionTiers.length;
        for (uint256 i = tierId; i < allSubscriptionTiersLength - 1; i++) {
            _allSubscriptionTiers[i] = _allSubscriptionTiers[i + 1];
        }
        _allSubscriptionTiers.pop();

        return true;
    }
}