// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: library/QueueFinanceLib.sol


pragma solidity ^0.8.4;



library QueueFinanceLib {
    using SafeMath for uint256;

    struct Level {
        uint256 amount;
        uint256 level; // 0 is the highest level; n is the lowest level
    }

    struct DepositInfo {
        address wallet;
        uint256 depositDateTime; // UTC
        uint256 initialStakedAmount;
        uint256 iCoinValue;
        uint256 stakedAmount;
        uint256 accuredCoin;
        uint256 claimedCoin;
        uint256 lastUpdated;
        uint256 nextSequenceID;
        uint256 previousSequenceID;
        uint256 inactive;
    }

    struct UserInfo {
        uint256 initialStakedAmount;
        uint256 totalAmount; // How many  tokens the user has provided.
        uint256 totalAccrued; // Interest accrued till date.
        uint256 totalClaimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256[] depositSequences;
        address referral;
    }

    struct RateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }

    struct LevelInfo {
        uint256 levelStakingLimit;
        uint256 levelStaked;
    }

    struct PoolInfo {
        // bytes32 name; //Pool name
        uint256 totalStaked; //
        uint256 eInvestCoinValue;
        IERC20 depositToken; // Address of investment token contract.
        IERC20 rewardToken; // Address of reward token contract.
        bool isStarted;
        uint256 maximumStakingAllowed;
        uint256 currentSequence;
        // The time when miner mining starts.
        uint256 poolStartTime;
        // // The time when miner mining ends.
        uint256 poolEndTime;
        uint256 rewardsBalance; // = 0;
        uint256 levels;
        uint256 lastActiveSequence;
        uint256[] taxRates;
    }

    struct Threshold {
        uint256 sequence;
        uint256 amount;
    }

    struct RequestedClaimInfo {
        uint256 claimId;
        uint256 claimTime;
        uint256 claimAmount;
        uint256 depositAmount;
        uint256 claimInterest;
        uint256[] sequenceIds;
    }

    //===========================Structures for Deposits===========================
    struct AddDepositInfo {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct AllDepositData {
        PoolInfo poolInfo;
        uint256 sequenceId;
        AddDepositInfo depositInfo;
        LevelInfo[] levelInfo;
        UserInfo userInfo;
        Threshold[] thresholdInfo;
    }

    struct AddDepositData {
        uint256 poolId;
        uint256 seqId;
        address sender;
        uint256 prevSeqId;
        uint256 poolTotalStaked;
        uint256 poolLastActiveSequence;
        uint256 blockTime;
    }

    struct AddDepositData1 {
        uint8[] levelsAffected;
        QueueFinanceLib.AddDepositInfo updateDepositInfo;
        uint256[] updatedLevelsForDeposit;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        QueueFinanceLib.Threshold[] threshold;
    }

    struct AddDepositModule {
        AddDepositData addDepositData;
        AddDepositData1 addDepositData1;
    }

    //===========================*Ended for Deposits*===========================

    //===========================Structures for Admin===========================

    struct AddLevelData {
        uint256 poolId;
        uint8 levelId;
        LevelInfo levelInfo;
        RateInfoStruct rateInfo;
        Threshold threshold;
    }

    struct DepositsBySequence {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct FetchUpdateLevelData {
        LevelInfo[] levelsInfo;
        Threshold[] thresholds;
        DepositsBySequence[] depositsInfo;
    }

    struct DepositDetailsForUser{
        DepositInfo depositInfo;
        uint256[] lastUpdateLevelsForDeposit;
        uint256 seqId;
    }
    //===========================*Ended for Admin*===========================

    //===========================*Structures for withdraw*===========================
    struct FetchLastUpdatedLevelsForDeposits {
        uint256 sequenceId;
        uint256[] lastUpdatedLevelsForDeposits;
    }

    struct LastUpdatedLevelsPendings {
        uint256 sequenceId;
        uint256 accruedCoin;
    }

    struct FetchWithdrawData {
        // DepositsBySequence[] depositsByThresholdId;
        DepositsBySequence[] depositsInfo;
        PoolInfo poolInfo;
        FetchLastUpdatedLevelsForDeposits[] lastUpdatedLevelsForDeposit;
        RateInfoStruct[][] rateInfo;
        Threshold[] threshold;
        uint256 withdrawTime;
        uint256 requestedClaimInfoIncrementer;
        LevelInfo[] levelInfo;
        // UserInfo userInfo;
    }


    struct UpdateWithdrawDataInALoop {
        uint256 poolId;
        uint256 currSeqId;
        uint256 depositPreviousNextSequenceID;
        uint256 depositNextPreviousSequenceID;
        uint256 curDepositPrevSeqId;
        uint256 curDepositNextSeqId;
        uint256 interest;
        QueueFinanceLib.Threshold[] thresholds;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        address user;
    }

    //===========================*Ended for withdraw*================================

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a : b;
    }

    function pickDepositBySequenceId(
        DepositsBySequence[] memory deposits,
        uint256 _seqId
    ) public pure returns (DepositInfo memory) {
        for (uint256 i = 0; i < deposits.length; i++) {
            if (deposits[i].sequenceId == _seqId) {
                return deposits[i].depositInfo;
            }
        }
        revert("Invalid Deposit value");
    }

    function pickLastUpdatedLevelsBySequenceId(
        FetchLastUpdatedLevelsForDeposits[] memory _arrData,
        uint256 _seqId
    ) public pure returns (uint256[] memory) {
        for (uint256 i = 0; i < _arrData.length; i++) {
            if (_arrData[i].sequenceId == _seqId) {
                return _arrData[i].lastUpdatedLevelsForDeposits;
            }
        }
        revert("Invalid Data");
    }

    function getRemoveIndex(
        uint256 _sequenceID,
        uint256[] memory depositSequences
    ) internal pure returns (uint256, bool) {
        for (uint256 i = 0; i < depositSequences.length; i++) {
            if (_sequenceID == depositSequences[i]) {
                return (i, true);
            }
        }
        return (0, false);
    }
}

// File: interfaces/IDataContractQF.sol


pragma solidity ^0.8.4;




interface IDataContractQF {
    //poolID => seqID => list of levels
    function lastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 seqID,
        uint8 levelID
    ) external view returns (uint256);

    //pool-> seq -> DepositInfo
    function depositInfo(uint256 _poolID, uint256 seqID)
        external
        view
        returns (QueueFinanceLib.DepositInfo memory _depositInfo);

    // wallet -> poolId
    function getUserInfo(address _sender, uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.UserInfo memory);


    function getRateInfoByPoolID(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct[][] memory _rateInfo)
    ;

    //Pool -> levels
    function levelsInfo(uint256 poolID, uint8 levelID)
        external
        view
        returns (QueueFinanceLib.LevelInfo memory);

    // Info of each pool.
    function getPoolInfo(uint256 _poolID)
        external
        view
        returns (QueueFinanceLib.PoolInfo memory);

    function currentSequenceIncrement(uint256 _poolID)
        external
        view
        returns (Counters.Counter memory);

    // Info of each pool.
    function treasury(uint256 _poolId) external view returns (address);

    // pool ->levels -> Threshold
    function currentThresholds(uint256 poolID, uint8 levelID)
        external
        view
        returns (QueueFinanceLib.Threshold memory);

    function requestedClaimInfo(address _sender, uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RequestedClaimInfo[] memory);

    function setOperator(address _operator, address _sender) external;

    function operator() external view returns (address);

    function setTransferOutOperator(address _operator, address _sender)
        external;

    function transferOutOperator() external view returns (address);

    function setLastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint8 _levelID,
        uint256 _amount
    ) external;

    function setDepositInfo(
        uint256 _poolID,
        uint256 _seqID,
        QueueFinanceLib.DepositInfo memory _depositInfo
    ) external;

    function setUserInfoForDeposit(
        address _sender,
        uint256 _poolID,
        uint256 _newSeqId,
        QueueFinanceLib.UserInfo memory _userInfo
    ) external;

    function setRateInfoStruct(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external;

    function setLevelsInfo(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.LevelInfo memory _levelsInfo
    ) external;

    function setPoolInfo(
        uint256 _poolID,
        QueueFinanceLib.PoolInfo memory _poolInfo
    ) external;

    // function s

    function setCurrentSequenceIncrement(
        uint256 _poolID,
        Counters.Counter memory _index
    ) external;

    function setTreasury(uint256 _poolID, address _treasury) external;

    function setCurrentThresholds(
        uint256 _poolID,
        uint256 _levelID,
        QueueFinanceLib.Threshold memory _threshold
    ) external;

    function setWithdrawTime(uint256 _withdrawTime) external;

    function setTaxAddress(uint256 _poolId, address _devTaxAddress, address _protocalTaxAddress, address _introducerAddress, address _networkAddress)
        external;

    function getTaxAddress(uint256 _poolId) external view returns (address[] memory);

    function getAllLevelInfo(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.LevelInfo[] memory);

    function getLastUpdatedLevelForEachDeposit(uint256 _poolId, uint256 _seqID)
        external
        view
        returns (uint256[] memory);

    function getAllThresholds(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.Threshold[] memory);

    function doCurrentSequenceIncrement(uint256 _poolID)
        external
        returns (uint256);

    function setLastUpdatedLevelsForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint256[] memory _lastUpdatedLevelAmounts
    ) external;

    function setCurrentThresholdsForTxn(
        uint256 _poolId,
        QueueFinanceLib.Threshold[] memory _threshold
    ) external ;

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external;

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external;

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external;

    function checkRole(address account, bytes32 role) external view;

    function getPoolInfoLength() external view returns (uint256);

    function addPool(QueueFinanceLib.PoolInfo memory poolData) external;

    function setPoolIsPrivate(uint256 _poolID, bool _isPrivate) external;

    function getPoolIsPrivateForUser(uint256 _pid, address _user) external view returns (bool, bool);

    function setLevelInfo(
        uint256 _pid,
        uint8 _levelId,
        QueueFinanceLib.LevelInfo memory _levelInfo
    ) external;

    function pushRateInfoStruct(
        uint256 _poolID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external;

    function incrementPoolInfoLevels(uint256 _poolId) external;

    function addLevelData(QueueFinanceLib.AddLevelData memory _addLevelData)
        external;

    // function fetchPoolTotalLevel(uint256 _poolId)
    //     external
    //     view
    //     returns (uint256);

    function fetchDepositsBasedonSequences(uint256 _poolId, uint256[] memory _sequenceIds)
        external
        view
        returns (QueueFinanceLib.DepositsBySequence[] memory)
    ;

    function getPoolStartTime(uint256 _poolId) external view returns (uint256);

    function getLatestRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position
    ) external view returns (QueueFinanceLib.RateInfoStruct memory);

    function getLatestRateInfo(uint256 _pid, uint256 _levelID)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct memory);

    function pushRateInfo(
        uint256 _pid,
        uint256 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external;

    function setRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external;

    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external;

    function getRateInfoLength(uint256 _pid, uint256 _levelID)
        external
        view
        returns (uint256);

        function addReplenishReward(uint256 _poolID, uint256 _value) external ;

    function getRewardToken(uint256 _poolId) external view returns (IERC20);

       // @notice sets a pool's isStarted to true and increments total allocated points
    function startPool(uint256 _pid) external;

    function setTaxRates(
        uint256 _poolID,
        uint256[] memory _taxRates
    ) external ;

    function addPreApprovedUser(address[] memory userAddress) external ;

     function pushWholeRateInfoStruct(
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external ;

    function returnDepositSeqList(uint256 _poodID, address _sender)
        external
        view
        returns (uint256[] memory)
    ;

     function getSequenceIdsFromCurrentThreshold(uint256 _poolId) external view returns (uint256[] memory);

      function fetchLastUpdatatedLevelsBySequenceIds(
        uint256 _poolID,
        uint256[] memory sequenceIds
    )
        external view 
        returns (QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory)
    ;

    function pushRequestedClaimInfo(address _sender, uint256 _poolId, QueueFinanceLib.RequestedClaimInfo memory _requestedClaimInfo) external ;
    function getWithdrawTime() external view returns (uint256) ;

    function getRequestedClaimInfoIncrementer() external view returns (uint256);

    function getDepositBySequenceId(uint256 _poolId, uint256 _seqId) external view returns (QueueFinanceLib.DepositInfo memory);
       function setUserInfoForWithdraw(
        address _sender,
        uint256 _poolID,
        QueueFinanceLib.UserInfo memory _userInfo
    ) external ;

    function removeSeqAndUpdateUserInfo(uint256 _poolId, uint256 _seqId, address _sender,   uint256  _amount,
        uint256  _interest) external ;
    function updateAddressOnUserInfo(uint256 _pid,address _sender, address _referrel) external ;
    function getWithdrawRequestedClaimInfo(address _sender, uint256 _pid) external view returns (QueueFinanceLib.RequestedClaimInfo[] memory);
    function fetchWithdrawLength(uint256 _pid, address user)
        external
        view
        returns (uint256)
    ;
     function swapAndPopForWithdrawal(
        uint256 _pid,
        address user,
        uint256 clearIndex
    ) external ;

    function getTaxRates(uint256 _poolID)
        external
        view
        returns (uint256[] memory)
    ;

    function doTransfer(uint256 amount, address to, IERC20 depositToken) external ;

     function updatePoolBalance(uint256 _poolID, uint256 _amount, bool isIncrease)
        external
    ;

    function setDepositInfoForAddDeposit(
        uint256 _poolID,
        QueueFinanceLib.AddDepositInfo[] memory _addDepositInfo
    ) external ;

       function addDepositDetailsToDataContract(QueueFinanceLib.AddDepositModule memory _addDepositData)
        external ;

        function getDepositData(uint256 _poolId, address _sender)
        external
        view
        returns (QueueFinanceLib.AllDepositData memory)
    ;


    function setDepositsForDeposit(
        uint256 _pid,
        QueueFinanceLib.AddDepositInfo[] memory _deposits
    ) external ;
    function setLastUpdatedLevelsForSequences(uint256 _poolID, QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory _lastUpdatedLevels, 
        QueueFinanceLib.LastUpdatedLevelsPendings[] memory _lastUpdatedLevelsPendings) external ;
    function updateWithDrawDetails(QueueFinanceLib.UpdateWithdrawDataInALoop memory _withdrawData) external;
}

// File: RequestedWithdrawQF.sol



pragma solidity ^0.8.4;






contract RequestedWithdrawQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDataContractQF public iDataContractQF;

    // uint256 public test;

    event RewardPaid(address indexed user, uint256 amount);
    constructor(address _accessContract)public {
        iDataContractQF = IDataContractQF(_accessContract);
    }

    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }

    function claimRequestedWithdrawal(uint256 _pid, uint256 _withdrawalId)
        external
    {
        uint256[] memory seqIds;
        QueueFinanceLib.RequestedClaimInfo
            memory requestedWithdrawInfo = QueueFinanceLib.RequestedClaimInfo({
                claimId: 0,
                claimTime: 0,
                depositAmount: 0,
                claimAmount: 0,
                claimInterest: 0,
                sequenceIds: seqIds
            });

        QueueFinanceLib.RequestedClaimInfo[]
            memory requestedWithdraws = iDataContractQF
                .getWithdrawRequestedClaimInfo(msg.sender, _pid);
        QueueFinanceLib.PoolInfo memory pool = iDataContractQF.getPoolInfo(
            _pid
        );

        QueueFinanceLib.UserInfo memory userInfo = iDataContractQF.getUserInfo(
            msg.sender,
            _pid
        );
        //Fetching Clear the entry from the requestedClaimInfo
        bool isThere = false;
        uint256 clearIndex = 0;
        for (uint256 i = 0; i < requestedWithdraws.length; i++) {
            if (_withdrawalId == requestedWithdraws[i].claimId) {
                isThere = true;
                clearIndex = i;
                requestedWithdrawInfo = requestedWithdraws[i];
                break;
            }
        }

        require(isThere, "Withdrawal is invalid");

        require(
            requestedWithdrawInfo.claimTime <= block.timestamp,
            "Withdrawal not yet available"
        );

        require(
            pool.rewardsBalance >=
                requestedWithdrawInfo.claimAmount.add(
                    requestedWithdrawInfo.claimInterest
                ),
            "Insufficient Balance"
        );

        if (isThere) {
            // swapping with last element and then pop
            pool.rewardsBalance = pool.rewardsBalance.sub(
                requestedWithdrawInfo.claimAmount.add(
                    requestedWithdrawInfo.claimInterest
                )
            );
            uint256 taxedReductedAmount = getTaxedAmount(
                _pid,
                pool.depositToken,
                (requestedWithdrawInfo.claimInterest),
                userInfo.referral
            );
            iDataContractQF.doTransfer(
                requestedWithdrawInfo.claimAmount.add(taxedReductedAmount),
                msg.sender,
                pool.depositToken
            );
            iDataContractQF.updatePoolBalance(
                _pid,
                requestedWithdrawInfo.claimAmount.add(taxedReductedAmount),
                false
            );
            iDataContractQF.swapAndPopForWithdrawal(
                _pid,
                msg.sender,
                clearIndex
            );
            iDataContractQF.setPoolInfo(_pid, pool);

            emit RewardPaid(msg.sender, requestedWithdrawInfo.claimAmount.add(taxedReductedAmount));
        }
    }

    function getTaxedAmount(
        uint256 _pid,
        IERC20 depositToken,
        uint256 _amount,
        address _referral
    ) internal returns (uint256) {
        uint256[] memory _taxRates = iDataContractQF.getTaxRates(_pid);
        address[] memory taxAddress = iDataContractQF.getTaxAddress(_pid);
        uint256 _calculatedAmount = 0;

        uint256[] memory taxRatesWithdraw = new uint256[](5);
        uint256 counter = 0;
        for (uint256 i = 5; i < _taxRates.length; i++) {
            taxRatesWithdraw[counter] = _taxRates[i];
            counter++;
        }

        for (uint256 i = 0; i < 5; i++) {
            uint256 tax = 0;
            if (taxRatesWithdraw[i] == 0) {
                continue;
            }
            tax = ((SafeMath.mul(_amount, taxRatesWithdraw[i])).div(100)).div(
                1000000000000000000
            );
            _calculatedAmount = _calculatedAmount.add(tax);
            if (i == 4) {
                iDataContractQF.doTransfer(tax, _referral, depositToken);
            } else {
                iDataContractQF.doTransfer(tax, taxAddress[i], depositToken);
            }
            tax = 0;
        }

        _calculatedAmount = SafeMath.sub(_amount, _calculatedAmount);

        return _calculatedAmount;
    }

    function updateLastUpdatedLevelForDeposits(uint256 _poolID, address _user)
        external
    {
        QueueFinanceLib.DepositsBySequence[] memory deposits = iDataContractQF
            .fetchDepositsBasedonSequences(
                _poolID,
                iDataContractQF.returnDepositSeqList(_poolID, _user)
            );
        QueueFinanceLib.Threshold[] memory thresholds = iDataContractQF
            .getAllThresholds(_poolID);

        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory lastUpdatedDepositsByUser = fetchLastUpdatatedLevelsBySequenceIds(
                _poolID,
                _user
            );
        QueueFinanceLib.RateInfoStruct[][] memory rateInfo = iDataContractQF
            .getRateInfoByPoolID(_poolID);

        QueueFinanceLib.PoolInfo memory pool = iDataContractQF.getPoolInfo(
            _poolID
        );

        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory finalLastUpdatedLevelForDeposits = new QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[](
                deposits.length
            );

        QueueFinanceLib.LastUpdatedLevelsPendings[]
            memory _lastUpdatedLevelsPendings = new QueueFinanceLib.LastUpdatedLevelsPendings[](
                deposits.length
            );

        for (uint256 i = 0; i < deposits.length; i++) {
            uint256 sequenceID = deposits[i].sequenceId;
            _lastUpdatedLevelsPendings[i].sequenceId = sequenceID;

            uint256[]
                memory _lastUpdatedLevelsForDepositBasedOnSequenceId = QueueFinanceLib
                    .pickLastUpdatedLevelsBySequenceId(
                        lastUpdatedDepositsByUser,
                        deposits[i].sequenceId
                    );

            _lastUpdatedLevelsPendings[i]
                .accruedCoin = getGeneratedRewardForSequence(
                pool,
                deposits[i].depositInfo,
                block.timestamp,
                _lastUpdatedLevelsForDepositBasedOnSequenceId,
                rateInfo
            );
            uint256[] memory lastUpdatedLevelForDeposits = new uint256[](
                pool.levels
            );
            // QueueFinanceLib.pickDepositBySequenceId(deposits, sequenceID);
            uint256 currentDepositAmount = deposits[i].depositInfo.stakedAmount;
            for (uint8 level = 0; level < pool.levels; level++) {
                //Cleaning the available data
                lastUpdatedLevelForDeposits[level] = 0;
                if (thresholds[level].sequence > sequenceID) {
                    lastUpdatedLevelForDeposits[level] = currentDepositAmount;
                    currentDepositAmount = 0;
                    continue;
                } else if (thresholds[level].sequence == sequenceID) {
                    lastUpdatedLevelForDeposits[level] = thresholds[level]
                        .amount;
                    if (currentDepositAmount <= thresholds[level].amount) {
                        currentDepositAmount = 0;
                        continue;
                    } else {
                        currentDepositAmount = SafeMath.sub(
                            currentDepositAmount,
                            thresholds[level].amount
                        );
                        continue;
                    }
                } else if (thresholds[level].sequence < sequenceID) {
                    lastUpdatedLevelForDeposits[level] = 0;
                    continue;
                }
            }

            finalLastUpdatedLevelForDeposits[i] = QueueFinanceLib
                .FetchLastUpdatedLevelsForDeposits({
                    sequenceId: sequenceID,
                    lastUpdatedLevelsForDeposits: lastUpdatedLevelForDeposits
                });
        }

        iDataContractQF.setLastUpdatedLevelsForSequences(
            _poolID,
            finalLastUpdatedLevelForDeposits,
            _lastUpdatedLevelsPendings
        );
    }

    function pendingShare(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        QueueFinanceLib.DepositsBySequence[] memory deposits = iDataContractQF
            .fetchDepositsBasedonSequences(
                _pid,
                iDataContractQF.returnDepositSeqList(_pid, _user)
            );
        QueueFinanceLib.PoolInfo memory pool = iDataContractQF.getPoolInfo(
            _pid
        );

        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory lastUpdatedDepositsByUser = fetchLastUpdatatedLevelsBySequenceIds(
                _pid,
                _user
            );
        QueueFinanceLib.RateInfoStruct[][] memory rateInfo = iDataContractQF
            .getRateInfoByPoolID(_pid);

        uint256 _pendings = 0;
        for (uint256 i = 0; i < deposits.length; i++) {
            uint256[]
                memory _lastUpdatedLevelsForDepositBasedOnSequenceId = QueueFinanceLib
                    .pickLastUpdatedLevelsBySequenceId(
                        lastUpdatedDepositsByUser,
                        deposits[i].sequenceId
                    );
            _pendings = _pendings.add(deposits[i].depositInfo.accuredCoin);
            _pendings = _pendings.add(
                getGeneratedRewardForSequence(
                    pool,
                    deposits[i].depositInfo,
                    block.timestamp,
                    _lastUpdatedLevelsForDepositBasedOnSequenceId,
                    rateInfo
                )
            );
        }
        return _pendings;
    }

    function fetchLastUpdatatedLevelsBySequenceIds(
        uint256 _poolId,
        address _sender
    )
        public
        view
        returns (QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory)
    {
        uint256[] memory sequenceIds = iDataContractQF.returnDepositSeqList(
            _poolId,
            _sender
        );

        return
            iDataContractQF.fetchLastUpdatatedLevelsBySequenceIds(
                _poolId,
                sequenceIds
            );
    }

    function getGeneratedRewardForSequence(
        QueueFinanceLib.PoolInfo memory pool,
        QueueFinanceLib.DepositInfo memory _deposit,
        uint256 _toTime,
        uint256[] memory _lastUpdatedLevelsForDepositBasedOnSequenceId,
        QueueFinanceLib.RateInfoStruct[][] memory _rateInfo
    ) internal pure returns (uint256) {
        uint256 _amount = _deposit.stakedAmount;
        uint256 _fromTime = _deposit.lastUpdated;

        uint256 reward = 0;
        // invalid cases
        if (
            (_fromTime >= _toTime) ||
            (_fromTime >= pool.poolEndTime) ||
            (_toTime <= pool.poolStartTime)
        ) {
            return 0;
        }
        // if from time < pool start then from time = pool start time
        if (_fromTime < pool.poolStartTime) {
            _fromTime = pool.poolStartTime;
        }
        //  if to time > pool end then to time = pool end time
        if (_toTime > pool.poolEndTime) {
            _toTime = pool.poolEndTime;
        }
        uint256 rateSums = 0;
        uint256 iFromTime;
        uint256 iToTime;
        uint256 iAmount = 0;
        uint256 iAmountCalc = _amount;
        // for each levels in levelForDeposit
        for (uint8 iLevel = 0; iLevel < pool.levels; iLevel++) {
            iAmount = _lastUpdatedLevelsForDepositBasedOnSequenceId[iLevel];

            if (iAmount <= 0) continue;

            if (iAmountCalc == 0) {
                break;
            }

            if (iAmountCalc > iAmount) {
                iAmountCalc = iAmountCalc.sub(iAmount);
            } else {
                iAmount = iAmountCalc;
                iAmountCalc = 0;
            }

            rateSums = 0;
            iFromTime = _fromTime;
            iToTime = _toTime;

            if (_rateInfo[iLevel].length == 1) {
                iFromTime = QueueFinanceLib.max(
                    _fromTime,
                    _rateInfo[iLevel][0].timestamp
                );
                // avoid any negative numbers
                iToTime = QueueFinanceLib.max(_toTime, iFromTime);
                rateSums = (iToTime - iFromTime) * _rateInfo[iLevel][0].rate;
            } else {
                // the loop start from 1 and not from zero; ith record and i-1 record are considered for processing.
                for (uint256 i = 1; i < _rateInfo[iLevel].length; i++) {
                    if (
                        _rateInfo[iLevel][i - 1].timestamp <= _toTime &&
                        _rateInfo[iLevel][i].timestamp >= _fromTime
                    ) {
                        if (_rateInfo[iLevel][i - 1].timestamp <= _fromTime) {
                            iFromTime = _fromTime;
                        } else {
                            iFromTime = _rateInfo[iLevel][i - 1].timestamp;
                        }
                        if (_rateInfo[iLevel][i].timestamp >= _toTime) {
                            iToTime = _toTime;
                        } else {
                            iToTime = _rateInfo[iLevel][i].timestamp;
                        }
                        rateSums +=
                            (iToTime - iFromTime) *
                            _rateInfo[iLevel][i - 1].rate;
                    }

                    // Process last block
                    if (i == (_rateInfo[iLevel].length - 1)) {
                        if (_rateInfo[iLevel][i].timestamp <= _fromTime) {
                            iFromTime = _fromTime;
                        } else {
                            iFromTime = _rateInfo[iLevel][i].timestamp;
                        }
                        if (_rateInfo[iLevel][i].timestamp >= _toTime) {
                            iToTime = _rateInfo[iLevel][i].timestamp;
                        } else {
                            iToTime = _toTime;
                        }

                        rateSums +=
                            (iToTime - iFromTime) *
                            _rateInfo[iLevel][i].rate;
                    }
                }
            }

            reward = reward + ((rateSums * iAmount) / (1000000000000000000));
        }
        return reward;
    }

    function getPoolLevelsAndRateInfo(uint256 _poolId)
        public
        view
        returns (
            QueueFinanceLib.LevelInfo[] memory,
            QueueFinanceLib.RateInfoStruct[] memory
        )
    {
        uint256 totalLevels = iDataContractQF.getPoolInfo(_poolId).levels;
        QueueFinanceLib.LevelInfo[] memory levelsInfo = iDataContractQF
            .getAllLevelInfo(_poolId);
        QueueFinanceLib.RateInfoStruct[]
            memory rateInfo = new QueueFinanceLib.RateInfoStruct[](
                totalLevels
            );
        for (
            uint256 i = 0;
            i < totalLevels;
            i++
        ) {
            rateInfo[i] = iDataContractQF.getLatestRateInfo(_poolId, i);
        }
        return (levelsInfo, rateInfo);
    }

    function getDepositDetailsForUser(uint256 _poolId, address _user)
        public
        view
        returns (
            QueueFinanceLib.DepositDetailsForUser[] memory,
            QueueFinanceLib.RateInfoStruct[] memory
        )
    {
        uint256 totalLevels = iDataContractQF.getPoolInfo(_poolId).levels;

        QueueFinanceLib.DepositsBySequence[] memory deposits = iDataContractQF
            .fetchDepositsBasedonSequences(
                _poolId,
                iDataContractQF.returnDepositSeqList(_poolId, _user)
            );
        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory lastUpdatedDepositsByUser = fetchLastUpdatatedLevelsBySequenceIds(
                _poolId,
                _user
            );

        QueueFinanceLib.RateInfoStruct[]
            memory rateInfo = new QueueFinanceLib.RateInfoStruct[](
                totalLevels
            );
        for (
            uint256 i = 0;
            i < totalLevels;
            i++
        ) {
            rateInfo[i] = iDataContractQF.getLatestRateInfo(_poolId, i);
        }

        QueueFinanceLib.DepositDetailsForUser[]
            memory _depositDetailsForUser = new QueueFinanceLib.DepositDetailsForUser[](
                deposits.length
            );

        for (uint256 i = 0; i < deposits.length; i++) {
            _depositDetailsForUser[i].depositInfo = deposits[i].depositInfo;
            _depositDetailsForUser[i]
                .lastUpdateLevelsForDeposit = lastUpdatedDepositsByUser[i]
                .lastUpdatedLevelsForDeposits;
            _depositDetailsForUser[i].seqId = deposits[i].sequenceId;
        }

        return (_depositDetailsForUser, rateInfo);
    }

    function getWithdrawDetailsForUser(uint256 _poolId, address _user)
        public
        view
        returns (QueueFinanceLib.RequestedClaimInfo[] memory)
    {
        return iDataContractQF.getWithdrawRequestedClaimInfo(_user, _poolId);
    }

    function fetchUserLevelStatus(uint256 _pid, address _user)
        external
        view
        returns (uint256[] memory)
    {
        // UserInfo storage userData = userInfo[_user][_pid];
        uint256 totalLevels = iDataContractQF.getPoolInfo(_pid).levels;

        QueueFinanceLib.DepositsBySequence[] memory deposits = iDataContractQF
            .fetchDepositsBasedonSequences(
                _pid,
                iDataContractQF.returnDepositSeqList(_pid, _user)
            );
        uint256[] memory finalLevelUpdateList = new uint256[](
            deposits.length
        );


        QueueFinanceLib.Threshold[] memory thresholds = iDataContractQF
            .getAllThresholds(_pid);

        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory lastUpdatedDepositsByUser = fetchLastUpdatatedLevelsBySequenceIds(
                _pid,
                _user
            );

        uint8 counter = 0;

        for (uint256 i = 0; i < deposits.length; i++) {
            uint256[] memory currentLevelUpdatedArr = new uint256[](totalLevels);
            uint256 sequenceID = deposits[i].sequenceId;

            uint256[] memory pickLastUpdateDeposit = QueueFinanceLib.pickLastUpdatedLevelsBySequenceId(lastUpdatedDepositsByUser, sequenceID);

            currentLevelUpdatedArr = getThresholdInfo(thresholds,deposits[i].depositInfo.stakedAmount, totalLevels, sequenceID);
            for (uint8 k = 0; k < currentLevelUpdatedArr.length; k++) {
                if(currentLevelUpdatedArr[k] != pickLastUpdateDeposit[k]){
                    finalLevelUpdateList[counter] = sequenceID;
                    counter++;
                    break;
                }
            }
        }
        return finalLevelUpdateList;
    }

    function getThresholdInfo(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 depositStakeAmount,
        uint256 totalLevels,
        uint256 _sequenceID
    ) internal pure returns (uint256[] memory) {
        uint256 iStakedAmount = depositStakeAmount;
        uint256[] memory ths = new uint256[](totalLevels);
        QueueFinanceLib.Threshold memory th;
        uint256 pos = 0;

        for (uint256 i = 0; i < totalLevels; i++) {
            if (iStakedAmount <= 0) break;

            th = currentThresholds[i];
            if (th.sequence < _sequenceID) {
                ths[i] = 0;
                continue;
            } else if (th.sequence > _sequenceID) {
                ths[i] = iStakedAmount;
                pos++;
                break;
            } else if (th.sequence == _sequenceID) {
                ths[i] = th.amount;
                pos++;
                if (iStakedAmount >= th.amount) {
                    iStakedAmount = iStakedAmount.sub(th.amount);
                } else {
                    iStakedAmount = 0;
                }
                continue;
            }
        }
        return ths;
    }

    function getFirstAvailableUserRefferal(address _user) external view returns (address){
        for (uint256 i = 0; i < iDataContractQF.getPoolInfoLength(); i++) {
            QueueFinanceLib.UserInfo memory _userInfo = iDataContractQF.getUserInfo(_user, i);
            if(_userInfo.referral != address(0)){
                return _userInfo.referral;
            }
        }
        return address(0);
    }

    function getRequestedWithdrawSequenceIds(address _user, uint256 _pid, uint256 _index) external view returns (uint256[] memory){
        return iDataContractQF.getWithdrawRequestedClaimInfo(_user, _pid)[_index].sequenceIds;
    }
}