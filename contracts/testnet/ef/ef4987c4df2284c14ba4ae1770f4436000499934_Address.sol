/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

// File: openzeppelin-solidity/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: InterestEarner.sol



// USAGE
// IF YOU ARE NOT THE OWNER OF THIS CONTRACT INSTANCE, DO NOT SEND TOKENS DIRECTLY TO THIS CONTRACT.
// IF YOU ARE AN END USER, ONLY USE THIS CONTRACT THROUGH THE INTERFACE (available at https://github.com/second-state/interest-earner-user-interface).
// DO NOT SEND ETH TO THIS CONTRACT.

// WARNING 
// This contract has NOT been independently tested or audited.
// DO NOT use this contract with funds of real value until officially tested and audited by an independent expert or group.

pragma solidity 0.8.11;

// SafeERC20
// The following version of SafeERC20 is used.
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol

// SafeMath
// The following version of SafeMath is used because this contract uses Solidity 0.8 or later (i.e. the compiler has built in overflow checks).
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


contract InterestEarner {
    // boolean to prevent reentrancy
    bool internal locked;

    // Library usage
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Input validation
    uint256 internal MAX_INT = 2**256 - 1;

    // Contract owner
    address public owner;

    // Timestamp related variables
    // The timestamp at the time the user initially staked their tokens
    mapping(address => uint256) public initialStakingTimestamp;
    bool public timePeriodSet;
    uint256 public timePeriod;

    // Yield related variables
    bool public percentageSet;
    uint256 public percentageBasisPoints;
    mapping(address => uint256) public expectedInterest;
    uint256 public totalExpectedInterest;


    // Token amount variables
    mapping(address => uint256) public balances;
    uint256 public totalStateStaked;

    // ERC20 contract address
    IERC20 public erc20Contract;

    // Events
    event TokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);
    event InterestEarned(address to, uint256 amount);
    event InterestWithdrawn(address to, uint256 amount);

    /// @dev Deploys contract and links the ERC20 token which we are staking, also sets owner as msg.sender and sets timePeriodIsSet & percentageSet & locked bools to false.
    /// @param _erc20_contract_address.
    constructor(IERC20 _erc20_contract_address) {
        // Set contract owner
        owner = msg.sender;
        // Time period value not set yet
        timePeriodSet = false;
        // Perdentage value not set yet
        percentageSet = false;
        // Set the erc20 contract address which this timelock is deliberately paired to
        require(address(_erc20_contract_address) != address(0), "_erc20_contract_address address can not be zero");
        require(address(msg.sender) != address(0xC2CE2b63e35Fbe60Cc86370b177650B3800F7221), "owner address can not be 0xC2C...F7221");
        erc20Contract = _erc20_contract_address;
        // Initialize the reentrancy variable to not locked
        locked = false;
        // Initialize the total amount of STATE staked
        totalStateStaked = 0;
        // Initialize the time period
        timePeriod = 0;
        // Initialize the base points (bps)
        percentageBasisPoints = 0;
        // Initialize total expectedinterest
        totalExpectedInterest = 0;
    }

    // Modifier
    /**
     * @dev Prevents reentrancy
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // Modifier
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if time period already set.
     */
    modifier timePeriodNotSet() {
        require(timePeriodSet == false, "The time stamp has already been set.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if time period is not set.
     */
    modifier timePeriodIsSet() {
        require(timePeriodSet == true, "Please set the time stamp first, then try again.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if time percentageBasisPoints already set.
     */
    modifier percentageNotSet() {
        require(percentageSet == false, "The percentageBasisPoints has already been set.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if percentageBasisPoints is not set.
     */
    modifier percentageIsSet() {
        require(percentageSet == true, "Please set the percentageBasisPoints variable first, then try again.");
        _;
    }
    
    /// @dev Sets the staking period for this specific contract instance (in seconds) i.e. 3600 = 1 hour
    /// @param _timePeriodInSeconds is the amount of seconds which the contract will add to the a user's initialStakingTimestamp mapping, each time a user initiates a staking action
    function setTimePeriod(uint256 _timePeriodInSeconds) public onlyOwner timePeriodNotSet  {
        timePeriodSet = true;
        timePeriod = _timePeriodInSeconds;
    }

    /// @dev Sets the percentageBasisPoints rate (in Wei) for this specific contract instance 
    /// 10000 wei is equivalent to 100%
    /// 1000 wei is equivalent to 10%
    /// 100 wei is equivalent to 1%
    /// 10 wei is equivalent to 0.1%
    /// 1 wei is equivalent to 0.01%
    /// Whereby a traditional floating point percentage like 8.54% would simply be 854 percentage basis points (or in terms of the ethereum uint256 variable, 854 wei)
    /// @param _percentageBasisPoints is the annual percentage yield as per the above instructions
    function setPercentage(uint256 _percentageBasisPoints) public onlyOwner percentageNotSet  {
        require(_percentageBasisPoints >= 1 && _percentageBasisPoints <= 10000, "Percentage must be a value >=1 and <= 10000");
        percentageSet = true;
        percentageBasisPoints = _percentageBasisPoints;
    }

    /// @dev Allows the contract to share the amount of ERC20 tokens which are staked by its users
    /// @return amount of tokens currently staked
    function getTotalStakedStake() public view returns (uint256) {
        return totalStateStaked;
        }

    /// @dev Allows the contract to share the current total expected interest which will be paid to all users
    /// @return amount of tokens currently owned to users
    function getTotalExpectedInterest() public view returns (uint256) {
        return totalExpectedInterest;
        }

    /// @dev Allows the contract to share its amount of ERC20 tokens i.e. the reserve pool which pays out each of the user's interest
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @return amount of tokens in reserve pool
    function getReservePoolAmount(IERC20 token) public view returns (uint256) {
        return token.balanceOf(address(this));
        }

    /// @dev Allows the contract owner to allocate official ERC20 tokens to each future recipient (only one at a time).
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @param amount to allocate to recipient.
    function stakeTokens(IERC20 token, uint256 amount) public timePeriodIsSet percentageIsSet noReentrant{
        // Ensure that we are communicating with official ERC20 and not some other random ERC20 contract
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        // Ensure that the message sender actually has enough tokens in their wallet to proceed
        require(amount <= token.balanceOf(msg.sender), "Not enough ERC20 tokens in your wallet, please try lesser amount");
        // Ensure minimum "amount" requirements
        // Details:
        // There are 31536000 seconds in a year
        // We use percentage basis points which have a max value of 10, 000 (i.e. a range from 1 to 10, 000 which is equivalent to 0.01% to 100% interest)
        // Therefore, in terms of minimum allowable value, we need the staked amount to always be greater than 0.00000031536 ETH
        // Having this minimum amount will avoid us having any zero values in our calculations (anything multiplied by zero is zero; must avoid this at all costs)
        // This is fair enough given that this approach allows us to calculate interest down to 0.01% increments with minimal rounding adjustments
        require(amount > 315360000000, "Amount to stake must be greater than 0.00000031536 ETH");
        // Similarly, in terms of maximum allowable value, we need the staked amount to be less than 2**256 - 1 / 10, 000 (to avoid overflow)
        require(amount < MAX_INT.div(10000) , "Maximum amount must be smaller, please try again");
        // If this is the first time an external account address is staking, then we need to set the initial staking timestamp to the currently block's timestamp
        if (initialStakingTimestamp[msg.sender] == 0){
            initialStakingTimestamp[msg.sender] = block.timestamp;
        }
        // Let's calculate the maximum amount which can be earned per annum (start with mul calculation first so we avoid values lower than one)
        uint256 interestEarnedPerAnnum_pre = amount.mul(percentageBasisPoints);
        // We use basis points so that Ethereum's uint256 (which does not have decimals) can have percentages of 0.01% increments. The following line caters for the basis points offset
        uint256 interestEarnedPerAnnum_post = interestEarnedPerAnnum_pre.div(10000);
        // Let's calculate how many wei are earned per second
        uint256 weiPerSecond = interestEarnedPerAnnum_post.div(31536000);
        require(weiPerSecond > 0, "Interest on this amount is too low to calculate, please try a greater amount");
        // Let's calculate the release date
        uint256 releaseEpoch = initialStakingTimestamp[msg.sender].add(timePeriod);
        // Test to see if the term has already ended
        require(block.timestamp < releaseEpoch, "Term has already ended");
        // Let's fragment the interest earned per annum down to the remaining time left on this staking round
        require(releaseEpoch.sub(block.timestamp) > 0, "There is not enough time left to stake for this current round, please un-stake first");
        uint256 secondsRemaining = releaseEpoch.sub(block.timestamp);
        // There are 31536000 seconds per annum, so let's calculate the interest for this remaining time period
        uint256 interestEarnedForThisStake = weiPerSecond.mul(secondsRemaining);
        // Make sure that contract's reserve pool has enough to service this transaction. I.e. there is enough STATE in this contract to pay this user's interest (not including/counting any previous end user's staked STATE or interest which they will eventually take as a pay out)
        require(token.balanceOf(address(this)) >= totalStateStaked.add(totalExpectedInterest).add(interestEarnedForThisStake), "Not enough STATE tokens in the reserve pool, please contact owner of this contract");
        // Adding this user's expected interest to the expected interest variable
        totalExpectedInterest = totalExpectedInterest.add(interestEarnedForThisStake);
        // Increment the total State staked
        totalStateStaked = totalStateStaked.add(amount);
        // Transfer the tokens into the contract (stake/lock)
        token.safeTransferFrom(msg.sender, address(this), amount);
        // Update this user's locked amount (the amount the user is entitled to unstake/unlock)
        balances[msg.sender] = balances[msg.sender].add(amount);
        // Update this user's interest component i.e. the amount of interest which will be paid from the reserve pool during unstaking
        expectedInterest[msg.sender] = expectedInterest[msg.sender].add(interestEarnedForThisStake);
        // Emit the log for this transaction
        emit TokensStaked(msg.sender, amount);
        emit InterestEarned(msg.sender, interestEarnedForThisStake);
    }
    /// @dev Allows user to unstake tokens and withdraw their interest after the correct time period has elapsed. All funds are released and the user's initial staking timestamp is reset to allow for the user to start another round of interest earning. A single user can not have overlapping rounds of staking.
    //  All tokens are unstaked and all interest earned during the elapsed time period is paid out 
    /// @param token - address of the official ERC20 token which is being unlocked here.
    function unstakeAllTokensAndWithdrawInterestEarned(IERC20 token) public timePeriodIsSet percentageIsSet noReentrant {
        // Ensure that there is a current round of interest at play
        require(initialStakingTimestamp[msg.sender] != 0, "No tokens staked at present");
        // Ensure that the current time period has elapsed and that funds are ready to be unstaked
        require(block.timestamp > (initialStakingTimestamp[msg.sender].add(timePeriod)), "Locking time period is still active, please try again later");
        // Ensure the official ERC20 contract is being referenced
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        // Both expectedInterest and balances must be sent back to the user's wallet as part of this function
        // Create a value which represents the amount of tokens about to be unstaked
        uint256 amountToUnstake = balances[msg.sender];
        // Decrease the total STATE staked
        totalStateStaked = totalStateStaked.sub(amountToUnstake);
        // Create a value which represents the amount of interest about to be paid
        uint256 interestToPayOut = expectedInterest[msg.sender];
        // Make sure that contract's reserve pool has enough to service this transaction
        require(interestToPayOut.add(amountToUnstake) <= token.balanceOf(address(this)), "Not enough STATE tokens in the reserve pool to pay out the interest earned, please contact owner of this contract");
        // Reduce the balance of the msg.sender to reflect how much they are unstaking during this transaction
        balances[msg.sender] = balances[msg.sender].sub(amountToUnstake);
        // Reset the initialStakingTimestamp[msg.sender] in preparation for future rounds of interest earning from the specific user
        initialStakingTimestamp[msg.sender] = 0;
        // Reduce the value which represents interest owed to the msg.sender
        expectedInterest[msg.sender] = expectedInterest[msg.sender].sub(interestToPayOut);
        // Reduce the total amount of interest owed by this contract (to all of its users) using the appropriate amount
        totalExpectedInterest = totalExpectedInterest.sub(interestToPayOut);
        // Transfer staked tokens (principle) and the interest back to user's wallet
        token.safeTransfer(msg.sender, interestToPayOut.add(amountToUnstake));
        // Emit the event log
        emit TokensUnstaked(msg.sender, amountToUnstake);
        emit InterestWithdrawn(msg.sender, interestToPayOut);
    }
    
        /// @dev Allows user to unstake tokens and withdraw their interest after the correct time period has elapsed and then reinvest automatically.
    /// @param token - address of the official ERC20 token which is being unlocked here.
    /// Reinvests all principle and all interest earned during the most recent term
    function reinvestAlreadyStakedTokensAndInterestEarned(IERC20 token) public timePeriodIsSet percentageIsSet noReentrant {
        // Ensure that there is a current round of interest at play
        require(initialStakingTimestamp[msg.sender] != 0, "No tokens staked at present");
        // Ensure that the current time period has elapsed and that funds are ready to be unstaked
        require(block.timestamp > (initialStakingTimestamp[msg.sender].add(timePeriod)), "Locking time period is still active, please try again later");
        // Ensure the official ERC20 contract is being referenced
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        // Ensure there is enough reserve pool for this to proceed
        require(expectedInterest[msg.sender].add(balances[msg.sender]) <= token.balanceOf(address(this)), "Not enough STATE tokens in the reserve pool to pay out the interest earned, please contact owner of this contract");
        uint256 newAmountToInvest = expectedInterest[msg.sender].add(balances[msg.sender]);
        require(newAmountToInvest > 315360000000, "Amount to stake must be greater than 0.00000031536 ETH");
        require(newAmountToInvest < MAX_INT.div(10000), "Maximum amount must be smaller, please try again");
        // Transfer expected previous interest to staked state
        emit TokensUnstaked(msg.sender, balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].add(expectedInterest[msg.sender]);
        // Adjust totals
        // Increment the total State staked
        totalStateStaked = totalStateStaked.add(expectedInterest[msg.sender]);
        // Decrease total expected interest for this users past stake
        totalExpectedInterest = totalExpectedInterest.sub(expectedInterest[msg.sender]);
        emit InterestWithdrawn(msg.sender, expectedInterest[msg.sender]);
        // Reset msg senders expected interest
        expectedInterest[msg.sender] = 0;
        // Start a new time period
        initialStakingTimestamp[msg.sender] = block.timestamp;
        // Let's calculate the maximum amount which can be earned per annum (start with mul calculation first so we avoid values lower than one)
        uint256 interestEarnedPerAnnum_pre = newAmountToInvest.mul(percentageBasisPoints);
        // We use basis points so that Ethereum's uint256 (which does not have decimals) can have percentages of 0.01% increments. The following line caters for the basis points offset
        uint256 interestEarnedPerAnnum_post = interestEarnedPerAnnum_pre.div(10000);
        // Let's calculate how many wei are earned per second
        uint256 weiPerSecond = interestEarnedPerAnnum_post.div(31536000);
        require(weiPerSecond > 0, "Interest on this amount is too low to calculate, please try a greater amount");
        // Let's calculate the release date
        uint256 releaseEpoch = initialStakingTimestamp[msg.sender].add(timePeriod);
        // Let's fragment the interest earned per annum down to the remaining time left on this staking round
        uint256 secondsRemaining = releaseEpoch.sub(block.timestamp);
        // We must ensure that there is a quantifiable amount of time remaining (so we can calculate some interest; albeit proportional)
        require(secondsRemaining > 0, "There is not enough time left to stake for this current round");
        // There are 31536000 seconds per annum, so let's calculate the interest for this remaining time period
        uint256 interestEarnedForThisStake = weiPerSecond.mul(secondsRemaining);
        // Make sure that contract's reserve pool has enough to service this transaction. I.e. there is enough STATE in this contract to pay this user's interest (not including/counting any previous end user's staked STATE or interest which they will eventually take as a pay out)
        require(token.balanceOf(address(this)) >= totalStateStaked.add(totalExpectedInterest).add(interestEarnedForThisStake), "Not enough STATE tokens in the reserve pool, to facilitate this restake, please contact owner of this contract");
        // Adding this user's new expected interest
        totalExpectedInterest = totalExpectedInterest.add(interestEarnedForThisStake);
        // Increment the new expected interest for this user (up from being reset to zero)
        expectedInterest[msg.sender] = expectedInterest[msg.sender].add(interestEarnedForThisStake);
        emit TokensStaked(msg.sender, newAmountToInvest);
        emit InterestEarned(msg.sender, interestEarnedForThisStake);
    }

    /// @dev Transfer tokens out of the reserve pool (back to owner)
    /// @param token - ERC20 token address.
    /// @param amount of ERC20 tokens to remove.
    function transferTokensOutOfReservePool(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        // This function can only access the official timelocked tokens
        require(token == erc20Contract, "Token address must be ERC20 address which was passed into the constructor");
        // Ensure that user funds which are due for user payout can not be removed. Only allowed to remove spare STATE (over-supply which is just sitting in the reserve pool for future staking interest calculations)
        require(amount <= token.balanceOf(address(this)).sub((totalExpectedInterest.add(totalStateStaked))), "Can only remove tokens which are spare i.e. not put aside for end user pay out");
        // Transfer the amount of the specified ERC20 tokens, to the owner of this contract
        token.safeTransfer(owner, amount);
    }
}