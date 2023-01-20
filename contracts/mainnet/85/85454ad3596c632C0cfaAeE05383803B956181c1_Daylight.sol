/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol


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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol


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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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

// File: daylight.sol


pragma solidity ^0.8.0;



contract ReentrancyGuard {
    bool private guardLocked;

    modifier noReentry() {
        require(!guardLocked, "Prevented Reentrancy");
        guardLocked = true;
        _;
        guardLocked = false;
    }
}

contract Daylight is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // ERC20 token contract
    IERC20 public token;

    // Staking parameters for each plan
    struct StakingParams {
        uint256 minStake; // minimum amount of tokens required to stake
        uint256 maxWithdrawal; // maximum amount of tokens that can be withdrawn per day
        uint256 rewardPercentage; // daily reward percentage
        uint256 referralCount; // number of referrals required to unlock this plan
        uint256 withdrawFee; // withdraw fee of this plan
    }

    // Staking parameters for each plan
    StakingParams[7] public stakingParams;

    struct StakedAmountsStruct {
        uint256 amount;
        uint256 lockUpPlan;
        uint256 lastClaimTime; // timestamp of the last time the user claimed a reward
        uint256 referralCount;
        address referee;
        uint256 totalWithdrawn;
        uint256 startStake;
        uint256 initialDeposit;
        bool active;
    }
    
    // Maps user addresses to their staked Plan and data
    mapping(address => StakedAmountsStruct) public stakedAmounts;

    uint256 public totalStakedAmount = 0;
    uint256 public numberOfUsers = 0;

    address treasuryWallet;
    address devWallet;

    // Events
    event Staked(address indexed user, uint256 amount, uint256 lockUpPlan);
    event ClaimedReward(address indexed user, uint256 amount);
    event CompoundedReward(address indexed user, uint256 amount);

    uint256 maxWithdrawlRatio = 365;
    uint256 timeBetweenLadder = 1 weeks;
    uint256  withdrawFeeLadder1 = 90;
    uint256  withdrawFeeLadder2 = 80;
    uint256  withdrawFeeLadder3 = 70;
    uint256  withdrawFeeLadder4 = 60;
    uint256  withdrawFeeLadder5 = 50;
    uint256  withdrawFeeLadder6 = 40;
    uint256  withdrawFeeLadder7 = 30;
    uint256  withdrawFeeLadder8 = 20;
    uint256  withdrawFeeLadder9 = 10;

    // Constructor
    constructor(IERC20 _token) {
        token = _token;

        // Set staking parameters for each lock-up period
        stakingParams[0].minStake = 100 * (10 ** 18);
        stakingParams[0].rewardPercentage = 100;
        stakingParams[0].referralCount = 0;

        stakingParams[1].minStake = 200 * (10 ** 18); 
        stakingParams[1].rewardPercentage = 125;
        stakingParams[1].referralCount = 10;

        stakingParams[2].minStake = 500 * (10 ** 18); 
        stakingParams[2].rewardPercentage = 150;
        stakingParams[2].referralCount = 25;

        stakingParams[3].minStake = 1000 * (10 ** 18);
        stakingParams[3].rewardPercentage = 175;
        stakingParams[3].referralCount = 50;

        stakingParams[4].minStake = 2000 * (10 ** 18);
        stakingParams[4].rewardPercentage = 200;
        stakingParams[4].referralCount = 100;

        stakingParams[5].minStake = 5000 * (10 ** 18);
        stakingParams[5].rewardPercentage = 225;
        stakingParams[5].referralCount = 150;

        stakingParams[6].minStake = 10000 * (10 ** 18);
        stakingParams[6].rewardPercentage = 250;
        stakingParams[6].referralCount = 250;

        treasuryWallet = 0x4A3Be597418a12411F31C94cc7bCAD136Af2E242;
        devWallet = 0xFF96f3Be084178F1E2b27dbaA8F849326b6F6C4E;
    }

    // Stake tokens
    function stake(uint256 amount, address referralAddress) public noReentry {
        require(amount > 0, "Amount must be greater than 0"); // Integer underflow protection
        require(token.balanceOf(msg.sender) >= amount, "Insufficient tokens");
        require(amount.add(stakedAmounts[msg.sender].amount) > stakedAmounts[msg.sender].amount, "Integer overflow detected"); // Integer overflow protection

        if (!stakedAmounts[msg.sender].active) {
            stakedAmounts[msg.sender].active = true;
            numberOfUsers++;
        }
        

        // Approve and transfer tokens from the staker to the contract
        token.safeTransferFrom(msg.sender, address(this), amount);

        // Update staked amount and referral count for the user
        stakedAmounts[msg.sender].amount += amount.div(10).mul(9); // 90% goes to the staker
        stakedAmounts[msg.sender].lastClaimTime = block.timestamp; // Set the last claim time to the current block timestamp
        stakedAmounts[msg.sender].startStake = block.timestamp; // Set the first start date for withdraw fees
        stakedAmounts[msg.sender].initialDeposit += amount; 
        
        if (referralAddress != address(0) && referralAddress != msg.sender && stakedAmounts[msg.sender].referee == address(0) && stakedAmounts[referralAddress].referee != msg.sender) {
            stakedAmounts[referralAddress].referralCount++;
            stakedAmounts[msg.sender].referee = referralAddress;
            stakedAmounts[referralAddress].amount += amount.div(100).mul(5); // 5% goes to the refferal
            token.safeTransfer(treasuryWallet, amount.div(100).mul(5)); // 5% goes to the treasury
        } else {
            token.safeTransfer(treasuryWallet, amount.div(100).mul(10)); // 10% goes to the treasury
        }

        totalStakedAmount += amount;
        
        updatePlanStatus();

        emit Staked(msg.sender, amount, stakedAmounts[msg.sender].lockUpPlan); // Emit event
    }

    function updatePlanStatus() internal {
        // Check if the user has enough referrals to unlock a higher lock-up period
        for (uint256 i = stakedAmounts[msg.sender].lockUpPlan + 1; i < 5; i++) {
             if (checkPlanEligibility(i, msg.sender)) {
                stakedAmounts[msg.sender].lockUpPlan = i;
            }
        }
    }

    // Claim reward
    function claimReward() public noReentry {
        require(stakedAmounts[msg.sender].active, "Have not deposited yet!");
    
        updatePlanStatus();

        // Calculate reward based on staked amount and reward percentage for the user's lock-up period
        uint256 reward = displayEstimatedReward(msg.sender);
        require(reward > 0, "Nothing to claim");

        // Check if the user has already claimed a reward today
        uint256 currentTime = block.timestamp;
        if (currentTime - stakedAmounts[msg.sender].lastClaimTime < 1 days) {
            reward = 0;
            return;
        }

        if (reward > token.balanceOf(address(this))) {
            reward = token.balanceOf(address(this));
        }

        // Transfer reward to the staker
        uint256 withdrawFee = withdrawFeeLadder9;
        if (currentTime - stakedAmounts[msg.sender].startStake < 1 * timeBetweenLadder) {
            withdrawFee = withdrawFeeLadder1;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 2 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder2;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 3 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder3;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 4 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder4;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 5 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder5;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 6 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder6;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 7 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder7;
        } else if (currentTime - stakedAmounts[msg.sender].startStake < 8 * timeBetweenLadder) { 
            withdrawFee = withdrawFeeLadder8;
        }

        uint256 rewardFee = reward.div(100).mul(withdrawFee);
        uint256 rewardUser = reward.sub(rewardFee);
        token.safeTransfer(msg.sender, rewardUser);
        token.safeTransfer(treasuryWallet, rewardFee);

        // Update last claim time for the user
        stakedAmounts[msg.sender].lastClaimTime = currentTime;
 
        // Update total withdrawn for the user
        stakedAmounts[msg.sender].totalWithdrawn += reward;
 
        // Emit event
        emit ClaimedReward(msg.sender, reward);
    }

    // Compound reward
    function compound() public noReentry {
        require(stakedAmounts[msg.sender].active, "Have not deposited yet!");

        updatePlanStatus();

        // Calculate reward based on staked amount and reward percentage for the user's lock-up period
        uint256 reward = displayEstimatedReward(msg.sender);
        require(reward > 0, "Nothing to compound");

        // Check if the user has already claimed a reward today
        uint256 currentTime = block.timestamp;
        if (currentTime - stakedAmounts[msg.sender].lastClaimTime < 1 days) {
            reward = 0;
            return;
        }

        // Add reward to staked amount
        stakedAmounts[msg.sender].amount += reward.div(100).mul(85);

        token.safeTransfer(treasuryWallet, reward.div(100).mul(15));

        // Update last claim time for the user
        stakedAmounts[msg.sender].lastClaimTime = currentTime;

        // Emit event
        emit CompoundedReward(msg.sender, reward);
    }

    // Owner Functions

    // Update the staked amount struct
    function updateStakedAmounts(uint256 plan, uint256 _minStake, uint256 _rewardPercentage, uint256 _referralCount) public {
        require(msg.sender == devWallet, "Not the owner");
        stakingParams[plan].minStake = _minStake;
        stakingParams[plan].rewardPercentage = _rewardPercentage;
        stakingParams[plan].referralCount = _referralCount;
    }

    // Update the withdrawl fees ladder
    function updateWithdrawFeeLadder(uint256 _timeBetweenLadder, 
            uint256 _withdrawFeeLadder1, 
            uint256 _withdrawFeeLadder2,
            uint256 _withdrawFeeLadder3,
            uint256 _withdrawFeeLadder4,
            uint256 _withdrawFeeLadder5,
            uint256 _withdrawFeeLadder6,
            uint256 _withdrawFeeLadder7,
            uint256 _withdrawFeeLadder8,
            uint256 _withdrawFeeLadder9) public{
        require(msg.sender == devWallet, "Not the owner");
        timeBetweenLadder = _timeBetweenLadder;
        withdrawFeeLadder1 = _withdrawFeeLadder1;
        withdrawFeeLadder2 = _withdrawFeeLadder2;
        withdrawFeeLadder3 = _withdrawFeeLadder3;
        withdrawFeeLadder4 = _withdrawFeeLadder4;
        withdrawFeeLadder5 = _withdrawFeeLadder5;
        withdrawFeeLadder6 = _withdrawFeeLadder6;
        withdrawFeeLadder7 = _withdrawFeeLadder7;
        withdrawFeeLadder8 = _withdrawFeeLadder8;
        withdrawFeeLadder9 = _withdrawFeeLadder9;
    }

    function updateMaxWithdrawlRatio(uint256 _maxWithdrawlRatio) public {
        require(msg.sender == devWallet, "Not the owner");
        maxWithdrawlRatio = _maxWithdrawlRatio;
    }

    // Transfer Dev Wallet
    function transferDevWallet(address _devWallet) public {
        require(msg.sender == devWallet, "Not the owner");
        devWallet = _devWallet;
    }

    // Visual Functions
    
    function displayWithdrawFee(address user) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 withdrawFee = 10;
        if (currentTime - stakedAmounts[user].startStake < 1 weeks) {
            withdrawFee = 90;
        } else if (currentTime - stakedAmounts[user].startStake < 2 weeks) { 
            withdrawFee = 80;
        } else if (currentTime - stakedAmounts[user].startStake < 3 weeks) { 
            withdrawFee = 70;
        } else if (currentTime - stakedAmounts[user].startStake < 4 weeks) { 
            withdrawFee = 60;
        } else if (currentTime - stakedAmounts[user].startStake < 5 weeks) { 
            withdrawFee = 50;
        } else if (currentTime - stakedAmounts[user].startStake < 6 weeks) { 
            withdrawFee = 40;
        } else if (currentTime - stakedAmounts[user].startStake < 7 weeks) { 
            withdrawFee = 30;
        } else if (currentTime - stakedAmounts[user].startStake < 8 weeks) { 
            withdrawFee = 20;
        }
        return withdrawFee;
    }
    
    // Display estimated reward for user
    function displayEstimatedReward(address user) public view returns (uint256) {
        // Get the staked amount and lock-up period for the user
        uint256 stakedAmount = stakedAmounts[user].amount;
        uint256 lockUpPlan = stakedAmounts[user].lockUpPlan;

        // Calculate the estimated reward
        uint256 rewardPercentage = stakingParams[lockUpPlan].rewardPercentage;
        uint256 dailyReward = stakedAmount.mul(rewardPercentage).div(10000);

        // Check if the user has reached the maximum withdrawal amount
        uint256 maxWithdrawal = stakedAmounts[msg.sender].initialDeposit.div(100).mul(maxWithdrawlRatio);
        uint256 totalWithdrawn = stakedAmounts[msg.sender].totalWithdrawn;
        if (totalWithdrawn.add(dailyReward) >= maxWithdrawal) {
            dailyReward = 0;
        }

        return dailyReward;
    }

    // Display if user is eligible for plan
    function checkPlanEligibility(uint planID, address user) public view returns (bool) {
        return (stakedAmounts[user].amount >= stakingParams[planID].minStake && stakedAmounts[user].referralCount >= stakingParams[planID].referralCount);
    }

}