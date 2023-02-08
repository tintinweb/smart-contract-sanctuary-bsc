// SPDX-License-Identifier: MIT

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File: contracts/Copy_stakingtst4.sol

pragma solidity 0.8.2;

contract StakingBitscrow {
    // Library usage
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Contract owner
    address private owner;

    // Timestamp related variables
    uint256 private timePeriod;
    mapping(address => uint256) private timestart;

    // Token amount variables
    mapping(address => uint256) private alreadyWithdrawnRewards;
    mapping(address => uint256) private balances;
    uint256 private _tokenaavailableforrewards = 0;
    uint256 private _TotalStakedTokens = 0;
    uint256 private _willWithdraw;
    uint256 private _seatsLeft;

    // stakers variable
    address[] _stakers;
    mapping(address => uint256) index;

    //rewards
    uint256 private rewardsrate;
    uint256 private minPeriodBetweenWithdraws = 7 days;
    uint256 private countdownEnd;
    mapping(address => uint256) private PersonalRewards;
    uint256 private Cost = 50000 * 10**18;
    uint256 private apy;
    uint256 private restakeBonus;

    /**
     * @dev allows the owner to achange the cost of the entry
     */
    function changeCost(uint256 newCost) external onlyOwner {
        Cost = newCost;
        _adjustSeats();
    }

    /**
     * @dev allows the owner to change the apy (in thousends)
     */
    function changeApy(uint256 newApy) external onlyOwner {
        apy = newApy;
    }

    // ERC20 contract address
    IERC20 private token;

    // Events
    event tokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);
    event TokensLocked(uint256 amount);
    event TokensWithdraw(uint256 amount);

    /// @dev Deploys contract and links the ERC20 token which we are staking, also sets owner as msg.sender.
    /// @param _erc20_contract_address the contact address of an erc20 token
    /// @param _apy Annualised Percentage Yield
    constructor(IERC20 _erc20_contract_address, uint256 _apy) {
        // Set contract owner
        owner = msg.sender;
        // Set staking period
        timePeriod = 30 days;
        // Set the erc20 contract address which this timelock is deliberately paired to
        require(
            address(_erc20_contract_address) != address(0),
            "_erc20_contract_address address can not be zero"
        );
        token = _erc20_contract_address;

        // occupy the index 0 of the array with the address 0
        _stakers.push(address(0));

        //apy (thousands)
        apy = _apy;

        rewardsrate = apy / 12;
    }

    // Modifier
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Message sender must be the contract's owner."
        );
        _;
    }

    /**
     * @dev Throws if the correct time period hasn't elapsed.
     */
    modifier checkPeriod() {
        require(timestart[msg.sender] != 0, "timestart cannot be zero");
        require(
            block.timestamp >= timestart[msg.sender] + timePeriod,
            "Tokens are only available after correct time period has elapsed"
        );
        _;
    }

    /**
     * @dev allows the user to unstake their tokens afte the correct period of time has passed,
     * this will send the tokens orignally staked plus the rewards to the user
     */

    function stakeTokens() external {
        uint256 amount = Cost;
        PersonalRewards[msg.sender] = (amount * rewardsrate) / 1000;
        require(
            _tokenaavailableforrewards >= PersonalRewards[msg.sender],
            "not enough BTCSCRW in fromrewards"
        );
        require(
            amount <= token.balanceOf(msg.sender),
            "Not enough BTCSCRW tokens in your wallet, please try lesser amount"
        );
        require(_seatsLeft > 0, "no seats left");
        require(
            balances[msg.sender] == 0,
            "you already have tokens in staking"
        );
        timestart[msg.sender] = block.timestamp;
        balances[msg.sender] += amount;
        _tokenaavailableforrewards -= PersonalRewards[msg.sender];
        _TotalStakedTokens += amount;
        emit tokensStaked(msg.sender, amount);
        _seatsLeft -= 1;
        if (index[msg.sender] == 0) {
            addStaker(msg.sender);
        } else {
            reAddStaker(msg.sender);
        }
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev allows the user to unstake their tokens afte the correct period of time has passed,
     * this will send the tokens orignally staked plus the rewards to the user
     */
    function unstakeTokens() external checkPeriod {
        uint256 _amount = balances[msg.sender];
        uint256 rewards = PersonalRewards[msg.sender];
        PersonalRewards[msg.sender] = 0;
        alreadyWithdrawnRewards[msg.sender] += rewards;
        balances[msg.sender] -= _amount;
        _TotalStakedTokens -= _amount;
        removestaker(msg.sender);
        emit TokensUnstaked(msg.sender, _amount);
        token.safeTransfer(msg.sender, rewards);
        token.safeTransfer(msg.sender, _amount);
    }

    /**
     * @dev allows the user to restake their tokens after the correct period of time has passed,
     * this will restake the tokens orignally staked and send the rewards to the user, the apy will
     * be higher if the tokens are restaked
     */
    function restakeTokens() external checkPeriod {
        uint256 _amount = balances[msg.sender];
        require(balances[msg.sender] > 0, "your balance is too low");
        require(_seatsLeft > 0, "no seats left");
        uint256 rewards = PersonalRewards[msg.sender];
        alreadyWithdrawnRewards[msg.sender] += rewards;
        PersonalRewards[msg.sender] =
            (_amount * (rewardsrate + restakeBonus)) /
            1000;
        require(
            _tokenaavailableforrewards >= PersonalRewards[msg.sender],
            "not enough BTCSCRW in fromrewards"
        );
        timestart[msg.sender] = block.timestamp;
        _tokenaavailableforrewards -= PersonalRewards[msg.sender];
        _seatsLeft -= 1;
        if (restakeBonus > 0) {
            _adjustSeats();
        }
        emit TokensUnstaked(msg.sender, _amount);
        emit tokensStaked(msg.sender, _amount);
        token.safeTransfer(msg.sender, rewards);
    }

    /**
     * @dev allows the user to unstake their tokens even if  the corrrect period of time has not passed,
     * this will send the only the tokens orignally stake to the user, resulting in the user losing his rewards
     */
    function emergencyUnstake() external {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] -= amount;
        _TotalStakedTokens -= amount;
        _tokenaavailableforrewards += PersonalRewards[msg.sender];
        PersonalRewards[msg.sender] = 0;
        removestaker(msg.sender);
        _seatsLeft += 1;
        emit TokensUnstaked(msg.sender, amount);
        token.safeTransfer(msg.sender, amount);
    }

    /**
     * @dev allows owner of the contract to set the restakebonus
     */
    function changeBonus(uint256 newBounus) external onlyOwner {
        restakeBonus = newBounus;
    }

    /**
     * @dev allows the ownert to withdraw the locked funds, note that can e used only if
     * the corect time has passed sice the beginning the countdown for the withdraw, note that even
     * if all the funds in ('_tokenaavailableforrewards') are withdrawn the contract would still retain
     * enough  funds too pay back all the tokens that are currently staked and their respective rewards
     */

    function withdrawlockedfunds() external onlyOwner returns (bool success) {
        require(countdownEnd != 0, "countdoownEnd cannot be zero");
        require(block.timestamp >= countdownEnd, "cannot withdraw yet");
        emit TokensWithdraw(_willWithdraw);
        countdownEnd = 0;
        _willWithdraw = 0;
        token.safeTransfer(msg.sender, _willWithdraw);
        return true;
    }

    /**
     * @dev allows the owner wallet to initiate the countdown for the withdrawal pocedure
     */
    /// @param amount amount of tokens that will be withdrawn
    function initiateCountdownForWithdraaw(uint256 amount)
        external
        onlyOwner
        returns (bool success)
    {
        require(
            amount <= _tokenaavailableforrewards,
            "not enough funds in contract"
        );
        countdownEnd = block.timestamp + minPeriodBetweenWithdraws;
        _tokenaavailableforrewards -= amount;
        _willWithdraw = amount;
        _adjustSeats();
        return true;
    }

    /**
     * @dev allows the owner to lock the tokens in order for themm to be used to pay the rewards
     */
    /// @param amount amount of tokens to be locked
    function lockTokens(uint256 amount) external onlyOwner {
        require(
            amount <= token.balanceOf(msg.sender),
            "Not enough BTSCRW tokens in your wallet"
        );
        _tokenaavailableforrewards += amount;
        emit TokensLocked(amount);
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev allows the owner to add or remove seats in the staking pool
     */
    function changeSeats(uint256 amount) external onlyOwner {
        require(
            (_tokenaavailableforrewards * 1000) / rewardsrate / Cost >= amount,
            "not enough funds"
        );
        _seatsLeft = amount;
    }

    function adjustSeats() external onlyOwner {
        _adjustSeats();
    }

    //see

    function namePool() external pure returns (string memory) {
        return "Gold";
    }

    function timeLeftTillUnstake(address user) public view returns (uint256) {
        if (
            block.timestamp >= timestart[user] + timePeriod ||
            balances[user] == 0
        ) {
            return 0;
        } else {
            return (timePeriod + timestart[user]) - block.timestamp;
        }
    }

    function stakingperiod() external view returns (uint256) {
        return timePeriod;
    }

    function seeCost() external view returns (uint256) {
        return Cost;
    }

    function tokenaavailableforrewards() external view returns (uint256) {
        return _tokenaavailableforrewards;
    }

    function seatsLeft() external view returns (uint256) {
        return _seatsLeft;
    }

    function TotalStakedTokens() external view returns (uint256) {
        return _TotalStakedTokens;
    }

    function personalRewards(address user) external view returns (uint256) {
        return PersonalRewards[user];
    }

    function seeAlreadyWithdrawnRewards(address user)
        public
        view
        returns (uint256)
    {
        return alreadyWithdrawnRewards[user];
    }

    function seeRewardsRate() external view returns (uint256) {
        return rewardsrate;
    }

    function balanceof(address user) external view returns (uint256) {
        return balances[user];
    }

    function seeapy() external view returns (uint256) {
        return apy / 10;
    }

    function seeCountdownEnd() external view returns (uint256) {
        return countdownEnd;
    }

    function stakers() public view returns (address[] memory) {
        return _stakers;
    }

    function contractBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function contractInfo()
        external
        view
        returns (
            uint256 cost,
            uint256 seats,
            uint256 Stakingperiod,
            uint256 Apy
        )
    {
        return (Cost, _seatsLeft, timePeriod, apy / 10);
    }

    function userInfo(address user)
        external
        view
        returns (
            uint256 Rewards,
            uint256 balance,
            uint256 timeleft,
            uint256 allowance
        )
    {
        return (
            PersonalRewards[user],
            balances[user],
            timeLeftTillUnstake(user),
            token.allowance(user, address(this))
        );
    }

    function _adjustSeats() private {
        if (
            (_tokenaavailableforrewards * 1000) / rewardsrate / Cost <
            _seatsLeft
        ) {
            _seatsLeft =
                (_tokenaavailableforrewards * 1000) /
                rewardsrate /
                Cost;
        }
    }

    /// @dev saves add the address to the array and saves the index in a mapping
    function addStaker(address stk) private {
        _stakers.push(stk);
        index[stk] = _stakers.length - 1;
    }

    function reAddStaker(address stk) private {
        _stakers[index[stk]] = stk;
    }

    /// @dev deletes the stakers from the array (sets its address to the address 0)
    function removestaker(address stk) private {
        delete _stakers[index[stk]];
    }
}
// File: contracts/Escrow.sol

pragma solidity 0.8.2;

contract bitscrowEscrowAlpha {
    // service related
    mapping(uint256 => bool) private isIdUsed;
    mapping(uint256 => Service) private _relativeService;
    mapping(address => Buyer) private buyers;
    mapping(address => Seller) private sellers;
    mapping(address => Validator) private validators;
    uint256 private _totalServices;
    // taxes related
    uint256 private _levelInfluence = 1;
    uint256 private _universalTax = 1000;
    uint256 private _disputeTax = 3000;
    uint256 private _scale = 100000;
    uint256 private _taxToValidator = 50;
    uint256 private timeAvailableToValidators = 3 days;
    uint256 private _maxDiscount = 50;
    int256 private _banLevel = -10;
    int256 private btscrwToUSD;
    // validators requirement
    uint256 private validatingAmountGold;
    uint256 private validatingAmountSilver;

    // token related
    IERC20 private btscrw;
    IERC20 private nulll;
    // staking realated
    StakingBitscrow private goldPool;
    StakingBitscrow private silverPool;
    StakingBitscrow private bronzePool;
    // management related
    mapping(address => bool) private admin;
    address private owner;
    bool private escrowPaused;
    // service struct
    struct Service {
        address _seller;
        address _buyer;
        uint256 _amountDue;
        uint256 _timeToDeliver;
        address _validator;
        uint256 _disputeStartDate;
        bool _judgedV;
        /* _state: 4 = Paid/escrowStarted, 6 = sent/sent
        7 = Recieved, 9 = dispute, 10 = disputeManagement, 
         12 = closed */
        uint256 _state;
        address _winner;
        uint256 taxes;
        uint256 _inspectionTime;
        uint256 _inspectionTimeStart;
        bool _spedition;
        IERC20 _currency;
    }

    // _seller struct
    struct Seller {
        uint256[] _services;
        int256 level;
    }

    // _buyer struct
    struct Buyer {
        uint256[] _services;
        int256 level;
    }

    // _validator struct
    struct Validator {
        bool isActive;
        int256 level;
    }

    // events
    event escrowStarted(uint256 escrowNumber);
    event adminAdded(address indexed _admin, bool added);
    event btscrwValueUpdated(int256 newValue);
    event sent(uint256 escrowNumber);
    event recieved(uint256 escrowNumber);
    event deliveryAccepted(uint256 escrowNumber);
    event automaticallyFilled(uint256 escrowNumber);
    event disputeOpened(uint256 escrowNumber);
    event validatorSet(uint256 escrowNumber, address indexed _validator);
    event validatedByValidator(uint256 escrowNumber, address indexed winner);
    event velidatedByAdmin(uint256 escrowNumber, address indexed winner);
    event confirmedOrDenied(uint256 escrowNumber, bool confirmed);

    // modifiers

    modifier isBuyer(uint256 escrowNumber) {
        require(
            msg.sender == _relativeService[escrowNumber]._buyer,
            "you are not the _buyer of this proposal"
        );
        _;
    }

    modifier isSeller(uint256 escrowNumber) {
        require(
            msg.sender == _relativeService[escrowNumber]._seller,
            "you are not the _seller of this proposal"
        );
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "you are not the owner");
        _;
    }

    modifier isAdmin() {
        require(admin[msg.sender] == true, "you are not an admin");
        _;
    }

    modifier isEscrowActive() {
        require(escrowPaused == false, "currently paused");
        _;
    }

    //constructor

    /**
     * @param bitscrowToken The address of BTSCRW
     * @param poolGold The address of the current BTSCRW gold staking pool
     * @param poolSilver The address of the current BTSCRW silver staking pool
     * @param poolBronze The address of the current BTSCRW bronze staking pool
     */
    constructor(
        IERC20 bitscrowToken,
        StakingBitscrow poolGold,
        StakingBitscrow poolSilver,
        StakingBitscrow poolBronze
    ) {
        btscrw = bitscrowToken;
        goldPool = poolGold;
        silverPool = poolSilver;
        bronzePool = poolBronze;
        admin[msg.sender] = true;
        owner = msg.sender;
    }

    // escrow public function

    /**
     * @dev starts the escrow sending funds to the contract and saving the parameters.
     * @param _seller The _seller of the service/product.
     * @param _amountDue The amount agreed (expressed in Wei of the chosen _currency).
     * @param _prepTime The time needed for the _seller to prepare the service.
     * @param _currency The _currency agreed (use null address for bnb).
     * @param _inspectionTime The time needed for the _buyer to inspect the product/ service.
     * @param _spedition True if the service requires spedition.
     */
    function StartEscrow(
        address _seller,
        uint256 _amountDue,
        uint256 _prepTime,
        IERC20 _currency,
        uint256 _inspectionTime,
        bool _spedition,
        uint256 _id
    ) external payable isEscrowActive returns (uint256 escrowNumber) {
        // check that _seller isn't banned
        require(sellers[_seller].level > _banLevel, "this _seller is banned");
        // check that the _currency is implemented
        require(
            priceFeeds[_currency] != nulladdress || _currency == btscrw,
            "this _currency hasn't been implemented yet"
        );
        // check that _id isnt already in use
        require(isIdUsed[_id] == false, "this id is already in use");
        // increment totalServices by 1
        _totalServices += 1;

        uint256 _escrowNumber = _id;

        // set parameters
        _relativeService[_escrowNumber]._seller = _seller;
        _relativeService[_escrowNumber]._buyer = msg.sender;
        _relativeService[_escrowNumber]._amountDue = _amountDue;
        _relativeService[_escrowNumber]._timeToDeliver =
            block.timestamp +
            _prepTime;
        _relativeService[_escrowNumber]._currency = _currency;
        _relativeService[_escrowNumber]._inspectionTime = _inspectionTime;
        _relativeService[_escrowNumber]._spedition = _spedition;

        // check if the currency is bnb or tokens and send funds
        if (_currency == nulll) {
            payWithBNB(_escrowNumber);
        } else {
            payWithToken(_escrowNumber);
        }

        return _totalServices;
    }

    /// @dev lets the seller declare that he has sent the product/service
    function send(uint256 escrowNumber) external isSeller(escrowNumber) {
        // require that the escrow has started
        require(
            _relativeService[escrowNumber]._state == 4,
            "this escrow hasn't started yet"
        );
        if (_relativeService[escrowNumber]._spedition == false) {
            _relativeService[escrowNumber]._inspectionTimeStart = block
                .timestamp;
        }
        // set _state to sent/sent
        _relativeService[escrowNumber]._state = 6;
        emit sent(escrowNumber);
    }

    /// @dev lets the seller or the buyer declare that the product has arrived(only for escrow where spedition is required
    function recieve(uint256 escrowNumber) external {
        require(
            msg.sender == _relativeService[escrowNumber]._buyer ||
                msg.sender == _relativeService[escrowNumber]._seller,
            "you are not the _buyer nor the seller of this escrow"
        );
        require(
            _relativeService[escrowNumber]._spedition == true,
            "the spedition wasn't required in this escrow"
        );
        require(
            _relativeService[escrowNumber]._state == 6,
            "this product hasn't been sent yet"
        );
        // set _state to recieved
        _relativeService[escrowNumber]._state = 7;
        // start inspectionTime
        _relativeService[escrowNumber]._inspectionTimeStart = block.timestamp;
        emit recieved(escrowNumber);
    }

    ///@dev lets the buyer release the funds to the seller and ends the escrow
    function releaseFundsAsBuyer(uint256 escrowNumber)
        external
        isBuyer(escrowNumber)
    {
        require(
            _relativeService[escrowNumber]._state == 6 ||
                _relativeService[escrowNumber]._state == 7,
            "the service hasn't been sent yet"
        );
        // increase levels
        int256 valueToAdd = getValueToAdd(escrowNumber);
        sellers[_relativeService[escrowNumber]._seller].level += valueToAdd;
        buyers[_relativeService[escrowNumber]._buyer].level += valueToAdd;
        emit deliveryAccepted(escrowNumber);
        // end service
        endService(escrowNumber, _relativeService[escrowNumber]._seller);
    }

    /// @dev lets buyer open a dispute
    function openDispute(uint256 escrowNumber) external isBuyer(escrowNumber) {
        require(
            block.timestamp >= _relativeService[escrowNumber]._timeToDeliver ||
                _relativeService[escrowNumber]._state == 6 ||
                _relativeService[escrowNumber]._state == 7,
            "the time required to send hasn't elapsed"
        );
        // set proposal to disputed
        _relativeService[escrowNumber]._state = 9;
        // recalculateTax
        _relativeService[escrowNumber].taxes =
            (_relativeService[escrowNumber]._amountDue * _disputeTax) /
            _scale;
        // emit event
        emit disputeOpened(escrowNumber);
    }

    // dispute management

    /**
     * @dev lets validators choose a dispute to validate, it converts the currency in dollars to decide from which pools the validators can validate
     */
    function BeValidator(uint256 escrowNumber) public {
        require(
            _relativeService[escrowNumber]._validator == address(0),
            "valiator already set"
        );
        require(
            validators[msg.sender].isActive == false,
            "this _validator is already active"
        );
        require(
            _relativeService[escrowNumber]._state == 9,
            "this service isn't disputed"
        );

        if (
            getConversion(
                _relativeService[escrowNumber]._currency,
                int256(_relativeService[escrowNumber]._amountDue)
            ) >= int256(validatingAmountGold)
        ) {
            require(
                goldPool.balanceof(msg.sender) > 0,
                "you haven't enough btscrw staked "
            );
        } else if (
            getConversion(
                _relativeService[escrowNumber]._currency,
                int256(_relativeService[escrowNumber]._amountDue)
            ) >= int256(validatingAmountSilver)
        ) {
            require(
                silverPool.balanceof(msg.sender) +
                    goldPool.balanceof(msg.sender) >
                    0,
                "you haven't enough btscrw staked "
            );
        } else {
            require(
                goldPool.balanceof(msg.sender) +
                    silverPool.balanceof(msg.sender) +
                    bronzePool.balanceof(msg.sender) >
                    0,
                "you haven't enough btscrw staked "
            );
        }
        _relativeService[escrowNumber]._validator = msg.sender;
        validators[msg.sender].isActive = true;
        emit validatorSet(escrowNumber, msg.sender);
    }

    /* @dev lets the _validator choose a winner of the dispute
     * @param winner, The address of the winner of the dispute according to the _validator
     */
    function validateAsValidator(uint256 escrowNumber, address winner)
        external
    {
        require(
            _relativeService[escrowNumber]._validator == msg.sender,
            "you are not the _validator of this transaction"
        );
        require(
            _relativeService[escrowNumber]._state == 9,
            "this service isn't disputed"
        );
        // set the winner of the dispute
        _relativeService[escrowNumber]._winner = winner;
        // set _state to validated
        _relativeService[escrowNumber]._state = 10;
        // emit event
        emit validatedByValidator(escrowNumber, winner);
    }

    /*@dev lets the bitscrow Team confirm or deny the decision of the _validator
     *@param confirm , true if Bitscrow team agrees with the _validator
     */
    function confirmOrDeny(uint256 escrowNumber, bool confirm) public isAdmin {
        require(
            _relativeService[escrowNumber]._state == 10,
            "not yet validated"
        );
        int256 valueToAdd = getValueToAdd(escrowNumber);
        if (confirm) {
            validators[_relativeService[escrowNumber]._validator]
                .level += valueToAdd;
            _relativeService[escrowNumber]._judgedV = true;
            endService(escrowNumber, _relativeService[escrowNumber]._winner);
        } else {
            if (
                _relativeService[escrowNumber]._winner ==
                _relativeService[escrowNumber]._seller
            ) {
                _relativeService[escrowNumber]._winner = _relativeService[
                    escrowNumber
                ]._buyer;
            } else {
                _relativeService[escrowNumber]._winner = _relativeService[
                    escrowNumber
                ]._seller;
            }
            validators[_relativeService[escrowNumber]._validator]
                .level -= valueToAdd;
            endService(escrowNumber, _relativeService[escrowNumber]._winner);
        }
        addLevels(escrowNumber);
        emit confirmedOrDenied(escrowNumber, confirm);
    }

    /*
     * @dev lets the admin validate the transaction in case the _validator is taking too long
     */
    function ValidateAsAdmin(uint256 escrowNumber, address winner)
        external
        isAdmin
    {
        // check that the time has passed
        require(
            block.timestamp >
                _relativeService[escrowNumber]._disputeStartDate +
                    timeAvailableToValidators,
            "you cannot validate yet"
        );
        // set the winner of the dispute
        _relativeService[escrowNumber]._winner = winner;
        // confirm
        confirmOrDeny(escrowNumber, true);
        // emit event
        emit velidatedByAdmin(escrowNumber, winner);
    }

    /*
     * @dev lets the seller release the funds in case the inspection time available to the buyer has elapsed
     */
    function releaseFundsAsSeller(uint256 escrowNumber) external {
        require(
            _relativeService[escrowNumber]._inspectionTimeStart != 0,
            "inspection time hasn't started yet"
        );
        require(
            _relativeService[escrowNumber]._state != 9,
            "this service is on a dispute"
        );
        require(
            _relativeService[escrowNumber]._inspectionTimeStart +
                _relativeService[escrowNumber]._inspectionTime <=
                block.timestamp,
            "_buyer is still in time"
        );
        int256 valueToAdd = getValueToAdd(escrowNumber);
        sellers[_relativeService[escrowNumber]._seller].level += valueToAdd;
        buyers[_relativeService[escrowNumber]._buyer].level -= valueToAdd;
        endService(escrowNumber, _relativeService[escrowNumber]._seller);
        emit automaticallyFilled(escrowNumber);
    }

    // change variables

    function changeValidatingAmounts(
        uint256 amountGold,
        uint256 amountSilver,
        uint256 _newTime
    ) external isOwner {
        timeAvailableToValidators = _newTime;
        validatingAmountGold = amountGold;
        validatingAmountSilver = amountSilver;
    }

    function pauseEscrow(bool pause) external isOwner {
        escrowPaused = pause;
    }

    function updateBtscrwValue(int256 newValue) external isAdmin {
        btscrwToUSD = newValue;
        emit btscrwValueUpdated(newValue);
    }

    function transferOwnership(address newOwner) external isOwner {
        owner = newOwner;
    }

    function addOrRemoveAdmin(address _admin, bool add) external isOwner {
        admin[_admin] = add;
        emit adminAdded(_admin, add);
    }

    function changeTaxes(
        uint256 newLevelInfluence,
        uint256 newUniversalTax,
        uint256 newDisputeTax,
        uint256 newScale,
        uint256 newTaxToValidator,
        uint256 newMaxDiscount,
        int256 newBanLevel
    ) external isOwner {
        _levelInfluence = newLevelInfluence;
        _universalTax = newUniversalTax;
        _disputeTax = newDisputeTax;
        _scale = newScale;
        _taxToValidator = newTaxToValidator;
        _maxDiscount = newMaxDiscount;
        _banLevel = newBanLevel;
    }

    function implementNewToken(
        IERC20 tokenAddress,
        AggregatorV3Interface priceFeedAddress
    ) external isOwner {
        priceFeeds[tokenAddress] = priceFeedAddress;
    }

    function changePools(
        StakingBitscrow gold,
        StakingBitscrow silver,
        StakingBitscrow bronze
    ) external isOwner {
        goldPool = gold;
        silverPool = silver;
        bronzePool = bronze;
    }

    // See

    function seeTotalServices() external view returns (uint256 totalServices) {
        return _totalServices;
    }

    function seeValidatorPools()
        external
        view
        returns (
            StakingBitscrow goldStakingPool,
            StakingBitscrow silverStakingPool,
            StakingBitscrow bronzeStakingPool
        )
    {
        return (goldPool, silverPool, bronzePool);
    }

    function seeTaxes()
        external
        view
        returns (
            uint256 levelOfInfluence,
            uint256 universalTax,
            uint256 disputeTax,
            uint256 scale,
            uint256 taxToValidator,
            uint256 maxDiscount,
            int256 banLevel
        )
    {
        return (
            _levelInfluence,
            _universalTax,
            _disputeTax,
            _scale,
            _taxToValidator,
            _maxDiscount,
            _banLevel
        );
    }

    function seeServiceFixed(uint256 escrowNumber)
        external
        view
        returns (
            address seller,
            address buyer,
            uint256 amountDue,
            uint256 timeToDeliver,
            uint256 InspectionTime,
            IERC20 currency
        )
    {
        return (
            _relativeService[escrowNumber]._seller,
            _relativeService[escrowNumber]._buyer,
            _relativeService[escrowNumber]._amountDue,
            _relativeService[escrowNumber]._timeToDeliver,
            _relativeService[escrowNumber]._inspectionTime,
            _relativeService[escrowNumber]._currency
        );
    }

    function seeService(uint256 escrowNumber)
        external
        view
        returns (
            address validator,
            bool judgedV,
            uint256 endtime,
            uint256 deliveryTime,
            uint256 state,
            address winner,
            uint256 inspectionTimeStart
        )
    {
        return (
            _relativeService[escrowNumber]._validator,
            _relativeService[escrowNumber]._judgedV,
            _relativeService[escrowNumber]._timeToDeliver,
            _relativeService[escrowNumber]._disputeStartDate,
            _relativeService[escrowNumber]._state,
            _relativeService[escrowNumber]._winner,
            _relativeService[escrowNumber]._inspectionTimeStart
        );
    }

    function seeSeller(address _seller)
        external
        view
        returns (uint256[] memory services, int256 level)
    {
        return (sellers[_seller]._services, sellers[_seller].level);
    }

    function seeBuyer(address _buyer)
        external
        view
        returns (uint256[] memory services, int256 level)
    {
        return (buyers[_buyer]._services, buyers[_buyer].level);
    }

    function seeIfIdIsUsed(uint256 _id) external view returns (bool) {
        return isIdUsed[_id];
    }

    function seeValidator(address _validator)
        external
        view
        returns (bool isActive, int256 level)
    {
        return (validators[_validator].isActive, validators[_validator].level);
    }

    function seeUser(address _user)
        external
        view
        returns (
            uint256[] memory servicesAsSeller,
            int256 levelAsSeller,
            uint256[] memory servicesAsBuyer,
            int256 levelAsBuyer,
            bool isActive,
            int256 levelAsValidator
        )
    {
        return (
            sellers[_user]._services,
            sellers[_user].level,
            buyers[_user]._services,
            buyers[_user].level,
            validators[_user].isActive,
            validators[_user].level
        );
    }

    function BTSCRWcontractBalance() external view returns (uint256 balance) {
        return btscrw.balanceOf(address(this));
    }

    function isPaused() external view returns (bool) {
        return escrowPaused;
    }

    function seeOwner() external view returns (address) {
        return owner;
    }

    function seeIfAdmin(address _address) external view returns (bool) {
        return admin[_address];
    }

    function seeValueBTSCRW() external view returns (int256) {
        return btscrwToUSD;
    }

    function validatingAmounts()
        external
        view
        returns (uint256 amountGold, uint256 amountSilver)
    {
        return (validatingAmountGold, validatingAmountSilver);
    }

    // private

    /**
     * @dev sends BNBs from the buyer to the contract
     * @param escrowNumber The unique id of the escrow
     */
    function payWithBNB(uint256 escrowNumber) private {
        require(
            msg.value == _relativeService[escrowNumber]._amountDue,
            "not enough bnb"
        );
        // set _state to Paid
        _relativeService[escrowNumber]._state = 4;
        // add service to active services
        sellers[_relativeService[escrowNumber]._seller]._services.push(
            escrowNumber
        );
        buyers[_relativeService[escrowNumber]._buyer]._services.push(
            escrowNumber
        );
        // calculate tax
        calculateTaxes(escrowNumber);
        // emit
        emit escrowStarted(escrowNumber);
    }

    function payWithToken(uint256 escrowNumber) private {
        // set the endtime
        _relativeService[escrowNumber]._timeToDeliver =
            block.timestamp +
            _relativeService[escrowNumber]._timeToDeliver;
        // set _state to Paid
        _relativeService[escrowNumber]._state = 4;
        // add service to active services
        sellers[_relativeService[escrowNumber]._seller]._services.push(
            escrowNumber
        );
        buyers[_relativeService[escrowNumber]._buyer]._services.push(
            escrowNumber
        );
        // calculate tax
        calculateTaxes(escrowNumber);
        // send tokens to the contract
        _relativeService[escrowNumber]._currency.transferFrom(
            msg.sender,
            address(this),
            _relativeService[escrowNumber]._amountDue
        );
        // emit
        emit escrowStarted(escrowNumber);
    }

    function getValueToAdd(uint256 escrowNumber) private view returns (int256) {
        int256 _amnt;
        _amnt = getConversion(
            _relativeService[escrowNumber]._currency,
            int256(_relativeService[escrowNumber]._amountDue)
        );

        int256 valueToAdd = (_amnt / 100) / 10**18;
        return valueToAdd;
    }

    function addLevels(uint256 escrowNumber) private {
        int256 valueToAdd = getValueToAdd(escrowNumber);
        if (
            _relativeService[escrowNumber]._winner ==
            _relativeService[escrowNumber]._seller
        ) {
            sellers[_relativeService[escrowNumber]._seller].level += valueToAdd;
            buyers[_relativeService[escrowNumber]._buyer].level -= valueToAdd;
        } else {
            sellers[_relativeService[escrowNumber]._seller].level -= valueToAdd;
            buyers[_relativeService[escrowNumber]._buyer].level += valueToAdd;
        }
    }

    function endService(uint256 escrowNumber, address reciever) private {
        // set _state to ended
        _relativeService[escrowNumber]._state = 12;
        // set Validator to inactive
        validators[_relativeService[escrowNumber]._validator].isActive = false;
        // transferFunds
        transferRightCurrency(
            reciever,
            (_relativeService[escrowNumber]._amountDue -
                _relativeService[escrowNumber].taxes),
            escrowNumber
        );
        if (_relativeService[escrowNumber]._validator != address(0)) {
            if (_relativeService[escrowNumber]._judgedV == true) {
                transferRightCurrency(
                    _relativeService[escrowNumber]._validator,
                    _relativeService[escrowNumber].taxes,
                    escrowNumber
                );
            } else {
                transferRightCurrency(
                    _relativeService[escrowNumber]._validator,
                    (_relativeService[escrowNumber].taxes * _taxToValidator) /
                        100,
                    escrowNumber
                );
                transferRightCurrency(
                    owner,
                    _relativeService[escrowNumber].taxes -
                        ((_relativeService[escrowNumber].taxes *
                            _taxToValidator) / 100),
                    escrowNumber
                );
            }
        } else {
            transferRightCurrency(
                owner,
                _relativeService[escrowNumber].taxes,
                escrowNumber
            );
        }
    }

    function transferRightCurrency(
        address to,
        uint256 amount,
        uint256 escrowNumber
    ) private {
        if (_relativeService[escrowNumber]._currency == nulll) {
            payable(to).transfer(amount);
        } else {
            _relativeService[escrowNumber]._currency.transfer(to, amount);
        }
    }

    function calculateTaxes(uint256 escrowNumber) private {
        if (sellers[_relativeService[escrowNumber]._seller].level > 0) {
            if (
                _universalTax -
                    (uint256(
                        sellers[_relativeService[escrowNumber]._seller].level
                    ) * _levelInfluence) <=
                _universalTax - _maxDiscount
            ) {
                _relativeService[escrowNumber].taxes =
                    (_relativeService[escrowNumber]._amountDue *
                        (_universalTax - _maxDiscount)) /
                    _scale;
            } else {
                _relativeService[escrowNumber].taxes =
                    (_relativeService[escrowNumber]._amountDue *
                        (_universalTax -
                            (uint256(
                                sellers[_relativeService[escrowNumber]._seller]
                                    .level
                            ) * _levelInfluence))) /
                    _scale;
            }
        } else {
            _relativeService[escrowNumber].taxes =
                (_relativeService[escrowNumber]._amountDue * _universalTax) /
                _scale;
        }
    }

    //aggregator
    mapping(IERC20 => AggregatorV3Interface) internal priceFeeds;

    AggregatorV3Interface internal nulladdress;

    /**
     * Returns the latest price
     */
    function getLatestPrice(IERC20 tokenAddress) public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeeds[tokenAddress].latestRoundData();
        return price;
    }

    function getConversion(IERC20 tokenAddress, int256 amount)
        public
        view
        returns (int256)
    {
        if (tokenAddress == btscrw) {
            return (btscrwToUSD * amount);
        } else {
            return (getLatestPrice(tokenAddress) * amount);
        }
    }
}