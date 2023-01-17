/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT
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

// File: contracts/_Stake.sol


pragma solidity 0.8.11;



contract StakeNetc {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public owner;
    IERC20 public erc20Contract;
    uint256 public contractBalance;
    address[] public invertsAddresses;
    
    struct User {
        bool isInvestor;
		uint256 inverted;
        uint256 available;
        uint256 timestamp;
	}

    mapping (address => User) public users;
    event emitStake(address from, uint256 amount);
    event emitWithdraw(address to, uint256 amount);
    
    constructor(IERC20 _erc20_contract_address) {
        require(address(_erc20_contract_address) != address(0), "_erc20_contract_address address can not be zero");
        
        owner = msg.sender;
        erc20Contract = IERC20(_erc20_contract_address);

        invertsAddresses = [
            0x5D1742Cd60689af22F220959a10a5716AFA51227,
            0x99327711e8b6a6721ff7B4b0c7A40B373DbDd580,	
            0xf8d5326eD9Caa4416B843263091bf3C963D1e7D0,	
            0x4f5B25AdB17E7BD4c48fbEDd7Bda4444072a14bd,	
            0x489E4543f71D3C80F93c551A7ad3c99C7dF86D1f,	
            0xA91d001b043256e7B595108bEf0c267450AAeAb3,	
            0xE63c0b92112b4f376A6fF1B8082c17D8Ab692f1d,	
            0x4FB7C25a230E43c9A11736702670D5c9655E9e1B,	
            0x3Bb7EE0ef2a6280012f688Cf17Cd923adc7E27d7,	
            0x1744E896274bcF9a805bCb0284877c2976AB12C3,	
            0xd491a48845d67D244433b8d33d25e6fc9b6cC8e5,	
            0x5b31CA48A64312Ba547F61f6F6be744394aAc12b,	
            0x38053D9C5CF449aA427c079cC4eD0e65380244a9,	
            0xa4dE059161151f5F62f06f93c94544f8A68DEB7E,	
            0x75e7E68ee22Dda719688488a97dfFEc05884EB21,	
            0x04366aD174c649f50DD5994900de30d27B67Fd51,	
            0x68680a3AD562424cCec875daCB64763ec15bbcb5,	
            0xA96dD1846e68b2a4DE36f7a2c64992C7c4683cEB,	
            0x2Bc1fDd43db6a3a5027D117CB2e57a20f89cf972,	
            0x3fc262b4C7E4937232921E2efd24c6a7F6A296F3,	
            0xEEA9BF6143661D5D0a6aCdEcbe93A12E10bD42Cd,	
            0xF77dE3B0EF78823D97990415c919f13c4D85Fbdd,	
            0x858FC1EF899D5d27ca2bB5AEe7b5331475e35B9e,	
            0x3c95344D578bb27265C472Ddfe7a68b85e7d792F,	
            0xE861C6167cE4396FFC05f8af72B6059838498F70,	
            0xdb4F276Bd900282887E941A705566516dDfFd9D4,	
            0xEE31BcA38C991F0D46b20f1B0552c1019Bc32B30,	
            0x97933af3AAE2cC0dE4Ef64e32d595CDD58594863,	
            0x938493FD292fFA365DDaaA3676b82D5Bd9947722,	
            0x11ac26EE5147036ce736aE34c54A2C67155E5f3a,	
            0x3AD911A8AF78A6712740ABF2aF18610D061C85d5,	
            0x776e1aC6A6Fd7c9769C8FB09be758707d701Ee5D,	
            0xA0672C44394B4186939f487888205482ECdED83d,	
            0x92D7C2fd683b951e184C20E227F752E28689Ba31,	
            0x72e2016386947A361b9b1F97ee41A11Bc597580b,	
            0xF122A8F30207403321709C3f99D8ABfe7E271d83,	
            0x47deDf68Cf9a01Fa3FA7Ec3cD288e503785FA2Ae,	
            0x08473e420E67f1C307D37F2b9c2DbcF8f6c58ec7,	
            0x7C823E09570CEeBb32774B173B46f523978B3706,	
            0x67B619a426eE137B599C6959312FF064CB82f4b4,	
            0xBbAE101B782B29658a7Abef9a0306CC4e6A8CF91,	
            0xE83dc055587109bc1957A83af9A467958B698036,	
            0x1956765F6C43F6EFa248Eba4a7e1fD3f87bD9E56,	
            0x86b9039c3015FCcCCA8adF19443108423f4b7718,	
            0x5A150988beBC20618077Fe445bD71e4d4ec442FC,	
            0x1411b4CA3A3c5b8Fd6dccBd36787f07b3427ef26,	
            0x8FF0B33D8D3Eaa9d7303406ed33D84A43c8FAc2A,	
            0xDCfebFB1c8227109CC7543a92C9daCA1c6915720,	
            0x449124a8B21F334a3D46d24bA3db788345263854,	
            0x9989141bc6CfAA1F00b645E4795A6E6f46A98459,	
            0x46f75c5C29f1EBFA94D9a8CA50ea8ac483bb7a3B,	
            0x74299138164B441F85175DcC8a604b05B0e91B1c,	
            0x395D6e9fB92990397095c7939d5f8e28FD84b559,	
            0x8C352732CA91357D2709Ecf48c19C2B3dCf2c184,	
            0x65C5D8a4AA5b9cf4671BE2843a909079604B952F,	
            0xB98196690ED862E2740e9Db1378FEA4756A4A3F3,	
            0x85a6620BeE3d122079F162E4fE8819154892B833,	
            0x3fF57D5f265F8776A3C031D689975675ac363575,	
            0xF2cB736004CC4A24A986c69eC557f655Dda706C6,	
            0xc3C230c979501e943FFBE4B0eF3baf6511B196F2,	
            0x948661D584D043D1C6Be4ab9b074fAC851E4C6C9,	
            0x336fc2a322B38f76DE5ED19DaBba3f7cc5De2B10,	
            0xb14e783B12ED8985Fb6A727811D7919853f07645,	
            0xc1661255273dC3F280269ed68aF7b5d2Df4F669a,	
            0xC25e659bE4549636f51a619896A83B093AE15A70,	
            0xbc66760fcAe3842c415A0b30A2CCE28Cc1da3DC2,	
            0x93Cac1f9BE419e2f1B9FA6e9054a4b8dBBeF82b6,	
            0x3BaD180C9a15d169C9fD073348af255E58d95c39,	
            0xB30C5F5C8E7b906a63f2fBb6405E7eD2BE9bc914,	
            0x0bC3036657Cc1735326b782d0673A2112eBFdA24,	
            0x17d8CcF370520366597D2C9D7FB54c1F643b8a36,	
            0xE67381B333976c85Ff6aDb011249c926835D4777,	
            0xae05F7d3576686083C334b00B46BbF88df0dE92A,	
            0x80b20adbA104AD54281d69ba6c314177e6f8Ee56,	
            0xe4ae310A12558CEbcFCadf62364956E1438d6Dfd,	
            0xf096b9739041D3A36eef054d37e0d74D8296F20C,	
            0x55bD6187889453200601EA09d7a1C3D8a74Cb030,	
            0xfFF6F8E7F8C0C46836445345d676aE3658A2Ac65,	
            0x1DbdCdB37DB643860286cd9D5B89B359162788Ca,	
            0x395bcBeeE25FfFA81EE5d32fd7F87Ab3a17CFf3E,	
            0x10aD6283c680dca61643b8caF4BeDdA639067ee2,	
            0xb722d8242dF562573e76934a2ceBA27422DA5142,	
            0x5d4F089c9811Fc8cf8F897191A80Edf908a5996A,	
            0xe9E77E62A62DD095Fd594B0B4F08DA3BcCE2DbFd,	
            0xdF8F65204f76A5d4E4B36ff75D7A51A702075D2f,	
            0x51d48D63E3bb84a9Ea3C2DC99128825ff00c3c98,	
            0x9fBb77Be00b8a655a3d3D350dBa9b9412f04A0Cb,	
            0xbf49E81060228A3fE3c1E67F65A7EfACcb713AF5,	
            0x9a30E6b368FfEcEDE94A729b28a998a28b1afB33,	
            0x68c800666541129B75487b792669AA266A64C8a8,	
            0xef0F0DD3252AA2B98075c64165E23f79d8EAec0e,	
            0xf29B22796F8Ad4d55E6C940923FE8A0ADD6c0A8B,	
            0x63fB612cfd13FF3096c4239e780D23B2A776824a,	
            0x72dc7Cbc72cF8315557788802fb58160c6AEd38C,	
            0x668Cc4F4870CC21B347BE97A708Ce4E21409c1a2,	
            0x398680E40f6dE8665DF033A36c6f78D69E4136Ea,	
            0x65e1405B9F0b0beeEf0c12b0E592c692ea4a9D80,	
            0x4C3F08bB3234357566057C002eC7Ce05cb76F83d,	
            0x029617Df60532D44451d2df621A2479E78C57129,	
            0x260aA7fc2ab6a25c41CE7405C39a1767b0A1C460,	
            0x4af29736b7Ab88BDB04d4268f16eE3DB4B13989a,	
            0xf6984e3bcb0FF03d35Ec3F67062feA863BE7F673,	
            0x1b4f29BCf4206E3D0e697648ece02304a0dbE511,	
            0x85CB5492BDE870257D70f4ccDA844e726F9a2A4D,	
            0x0E718752d2f94BEc55dcDf8De4D66A0607ad0eFc,	
            0x264BcB2c9A9Cb30Ba6DbF14C59a5dED964B12cB0,	
            0x5db53Bb4fdC299581160f3720Be4064A769b4efD,	
            0x1a1fc27dDc8B0Ab841Bb187017581CAE8f2a2D2D,	
            0x20fD8Db43098c522173dAAE3171A10CDD0a858F6,	
            0xDa209B078B8c8004f2bbECd24a665C0B8aE275D7,	
            0x4ce21dbb89A53cCE7970734F9A13A646486F611b,	
            0x4a80EdE4D8223dF22b965a9C9c09F605aef8130F,	
            0x1194c7155968Dea0E843b347CEDaB58F4A03F36a,	
            0xf3642E5F8Ee699e6A6697f639488c8A99c0A126D,	
            0xaD378d96443459181DB172E1d9e149cA271E8414,	
            0x2f3870a170FD3Da9bA6114d072ECeD71F451528F,	
            0x59AFe543d04bF68ECdB4DC95BC7c1Ec67e31623B,	
            0xA3E0Dd545129B6437AE240C2f8e17c85a09302aF,	
            0x44B0ca58B6F6BAa47a378582432d1C3a079cf785,	
            0x21b2C5ca042F50A246d9b73eE9A2D7024Caf08b9,	
            0x1473A4369DBdAc7eb27280B2FfD12a5166021103,	
            0xBc7ffc4CaEB0dE8278b8b669C6b56a0fe79f0ff4,	
            0xA6c7D37BE9c3bdaEEd2948D9974F3d89759a8cdB,	
            0x4DCb17847f1ead7f3E8B3b9FF4A86C0c1FFc9AF5,	
            0x4D80AB6f330DBb8Fb83C4A7f1D7647006B4952BB,	
            0x84CD9753137a05f2C490103eD88C5F975d347DD3,	
            0x4013105845e53b831256651f5a34Bc67E6c7c48f,	
            0x91384ca3Dc44c52Fa352ea97A0bb2e1981fAFE4A,	
            0xF99574719416d8D65fbb12E116087A2321D59D46,	
            0x61E1E9C7A4dEEE00BeBDB6873a918Eb200Dc8059,	
            0x183AA9D0C5AA28104a42Ac8947Cd580dCF6E0Ce8,	
            0xCA1B0C3e7bC19E1E552B58f5039108258C11D9B5,	
            0x23f45e140eb918E6893e0D0e72b8909D368bBb5d,	
            0xFac23CbdC8786b8C1d62162c1bF0d44F9DC31519,	
            0xe05f720a6719bA93Aa2B31aEDaC713508bA43171,	
            0xCb6C25fb7f0549E767C75fB160f2eA607D97873a,	
            0xC90AF8ae3BafAB82052726318Aa58f53A3272415,	
            0x9dF8831376D98EEBf84f4b8A014738801c4f8116,	
            0xCA63375Cf371CAe5E843aBB39644d07C8Ef044A6,	
            0x4C454f5283CD50fb96ac1580d19744eBc13e3750,	
            0x13F427156448cF2aa1a2d3A6Dd90571E3EAa1658,	
            0x37DfDD12A1B2d04107dcCBB23A20153f29458f59,	
            0x49b842C9B901E044F3eE890d1E6BD840138eb02b,	
            0xB9635DB324655Bc4854E3358440B8597312DeAE7,	
            0x3E08AF752De65888787F1eA9CC29b9bF20B67B51,	
            0xFd70879B74ee3b678d8bf41feE4a994f0FdD317f,	
            0xC6773bAe84eFd15662E50D4542F62b917CBBa739,	
            0xB15aecCB106b8e74343122D979e0c452A57401Ac,	
            0x490F18ba7952003125B8bbfd68F75567618b2A37,	
            0x48d5D09B50B13004a5c9E3ED3100aFfc4bdB33a4,	
            0x27607AA5066025456AD68ABC856d2F69837C5128,	
            0x502aB15EaBE76d7D2d6637FA36470766885EbD15,	
            0x8E49a8b4354aE016BA72b71d5d1674F1C55377ab,	
            0x4D2416c742F29f94782C674846784BfD9425F163,	
            0xe4C0F3a55147bbbC2f33898A4Ffb1CD3735952B0,	
            0x4a46d27828daE07c255841428CCDf3e2c9D1cE6C,	
            0x35c48a9E5fa32ddE5d72B81308d31db4a807c45D,	
            0x63747d4cB098038e0C75B56B9B56A0C9e6D4CaE2,	
            0x7e326910fd81dA87c7D03aE880A548435437f347,	
            0x6dcbeAbA4D5EB28198004eDcb8e2772D1A83cb7c,	
            0x58A9237FF09098C55447d49fCC847bAa92519BE5,	
            0xB0e16a64F31fF8Ed77EFbc29d1ad33350185ac0d,	
            0x87bd95f4B200a1B90D239a28a6e3e25d2e2BC799,	
            0xD190925944764EcD74FA30927e01dBEA65B116E3,	
            0x86d19e9582aFbC51a091e5d0d2566C4610EFCdeB,	
            0xe984De0f2F7eD827428B5a119ce47eaFbB180106,	
            0x363893b1e9df1ac0eFAe03a780C354e4bDD84597,	
            0x7FAeE6c5DC3Cb3a3e5cCADf77F34E13eeFb9e48e,	
            0xA1D860aD2B31Aacd75FAdB79a7B09d047A8c7496,	
            0xd1b38C0cE64f5a8ff7f9D9E5E9db39825442432a,	
            0x12F38E4C1f68a8FeB6640861E79Dc5Af9d711696,	
            0xD7428c831fa17f401ba61E2b99Ccb08202448eF7,	
            0x5845d049fe2bC7DBAc18Ba844499671aCA489Adb,	
            0xaE087B1aDB5120F6BB459EC8984FFcD5a9C15d0B,	
            0xf48C2A6E1669db616759906E89aa18d0b011Fe0C,	
            0xB8557a2d63955832ae0A33E4221b238805BcB556,	
            0x4039cB52F14241b40fbb2b72F97CF0569136AaCb,	
            0x6051b5f4bf9ace18C3c1D25d03d87966BC0BF3Ca,	
            0xB6e32a58d4c58a3B00d68B89Bcf9C5039695B6c8,	
            0x9E3C04d95C367252332eE360dFBf890A86336fB1,	
            0xB08D34546a895cB277751050F68598267AdB305d,	
            0xf74BCE2459A9d33F8283848A1085b1455dc3A75f,	
            0x02F301595021a2cF31dD47e2Db7E05e5395041DF,	
            0x07aC00F4A6eE287a97F02aa8Be0769EE4b47Ee5c,	
            0xa7fFc04778826c7A85Ab8dcC4D308ba28c686880,	
            0x95e8C406B7aD5577f70AA5eBa75d6eCfc29C9550,	
            0xAF6AC48FF48814beE5C894e49Bf02E45C312115E,	
            0x92cDfc5a11e7D9338EDDefd082F6c7fdc099a4B6,	
            0xE070c528D6D8C92aA773e4c2fBF4135a99C36F46,	
            0x597f102e4Fc5A8D6275F0aEAaEdc492654554e56,	
            0xC57a7006e241d3e0fb441ec5724A6b12FF83F8a7,	
            0x51aE93056B472660F50C7cB34E1845135247E864,	
            0x0eb024490eE061C43398C927c95035C86B7d1B66,	
            0x40EE0C3cB25FE1BC972ECF499A91ADc2F2De94Aa,	
            0x7f3e29D9A881c26A5ce3a69044ae1C382Cc4A5E3,	
            0x9b871Ee4feEBdfddE84e3f386DE40b41cb967465,	
            0xA80Ac57bCd89d0557476E6d17F336BB3437a37D2,	
            0xCc4EdbAEEA4849d5b708B876C05d22229381A3BE,	
            0xE7ab6a977C77590F4FEcfac71Aa79402Fc3A3833,	
            0xb6F65201f0b98bf3B4645f26c381Ead5237b9B28,	
            0xde6934887532E39D68d4853B03f428Be6D6f6cc1,	
            0x47225fb8be97Ab3E4b3bfc7BA6d767c7f1D6a7CF,	
            0x911e4fb2424457b94B9051810fD6E1ee33e9A5F0,	
            0xfe74fB22012285621Ee2e6d590c6E3cA79124E22,	
            0x68E94A010edfbA991577f351BBB65978D9A16DB7,	
            0xD9C4b69a18A533fFEdc1b2D44a655F18e872E627,	
            0xcd6ED55B36E0C870b1A39A2fA87e8B4BA21e434A,	
            0x49e45EA40995363fEd3D6cbb69FB5b94e4f7baB1,	
            0x31C6F758fbbEEaab7491538042f767b16222e775,	
            0x6D30AaA0bF0812E36E4EB29ed175Ff94CC3F6D32,	
            0x4AA341E7Fd41d05d1b53c152cB0f6ad71cA8cd62,	
            0xD271990208fBC253ae2D340cF212B04a2957171E,
            0x5c442C55D165b49477787289249Fbe29Fef7866f,
            0xF1304A6Cd65d5EaacC7E27EeC1741B8561c56926,
            0x2f9F804aB78ADc49d6E30Df60b380B4cb5e7A931,	
            0x43d61301455EB65Ce81f35c1A4e934E09Ce83639,	
            0x3e8d4Aa9488A650A58486B65c2328542e8493E9a,	
            0xc1AC92f582DC2D0d494dd38dCB2F5c02b554d278,	
            0xDe21a3b0fd2EDfA090c6c6831A5f987597e9AFE3,	
            0xF69a215E6479F0ca3b98D869Fe2235bE8a0BB2d4,	
            0x2691b2F644a8092E66a4E7F143e2556e9255A888,	
            0xfc9177eE34f1e8e321cA886beB4e9462FA4a288B,	
            0x3cbb18C70C6e1D18e436202Ef0C1c572e8a67705,	
            0xB29DB6fBa44BD598ef4906809e5f7B436954cC55,	
            0xb14B7Af04c750603873CF9151Df9aAab7B7AaDc5,	
            0xC80f0644683Aad1cF6b407e155f69fC12B77495b,	
            0xC72834E3242712f2363B92209c28E845C0d21012,	
            0x9130A94AAF1D2B8868Cbe60C3Dc6fCF1Af2E271e,
            0xcF1d3c06e224fdF3c84034BBD7BF731DfD40a14c,	
            0xDaaD71BC6541f69bF1b4400666001215308a7056,	
            0xFd432EddC7173fB7331f60c77ec35cFe68667b9B,	
            0xEe67cA55f492632e4B19625DEb3729fbcBa0A187,	
            0x336Fe6F4616505657b841D640216DF54885d3731,	
            0x7D1133e5EA058c36bd4cb347854cEa0DA426186a,	
            0xC13F699ebc968a3eDb2650fcd70d49525C6E4dea,	
            0x8966248E5Ca83Ed77FfeDCB82B53aE81549e4Dd7,	
            0xd4eAF22699FcA910DDF57D4Db36081e507089487,
            0x4faB7063116b177BFc6643482fb7efd941dC321E,	
            0xaE3dB099D035325eBfE0a2f7544fe3eA333274ff,	
            0xD293A63670a0af5e2556d9fF7625e747b86019Db,	
            0xCF67a855551B507504d7bD874fD9aE1f8103A1b0,	
            0x4348bFB30E8527742d2BF0ad661BD726706715f6,	
            0x89F2fb8c1585235320249D5088402d08fA72C884,	
            0x7824306a7669D1CB468b7D47E41670672BA45B3b,	
            0x7d67A1BDF638DA91c12d55756A802AA67cbC891c,	
            0xc2Cf8d72c2B36B80586484f51CDC15c4d6805d12,	
            0x0d223a9CD81DE1A00DD93C0CF6e8011Cf0C0C251,	
            0xEa8f71c9662705ECC5736434697034e0c98f2233,	
            0x98aA20681557c46F5Ae6A2595a8c593252889028,	
            0x3Ac1FC497F7db165e32A68BAbB2FA1aB3c06054a,	
            0x0cA8f9E6Be6A09067076950575088D2e3F67161A,	
            0x8C906455731db677bd91d2f33a4B97a6A2a0e895,	
            0x7c9b1b7f72A5961afE4dfc293c104D058571A509,	
            0xa34B036996628e1Ad533466Af770aF910308F576,	
            0xA9a4e28Ae6a49908CDE972681B7e82e8a5DD8247,	
            0x9E0F6cA51E26D537AF8892874E405b883c5F36EC,	
            0x74d9043C2126c0C870fBa433fcA5498D9A84018D,	
            0x29A037325D081F77F2766A2DBa1709ff51888888,	
            0x167BD158b28a47E00C852006bBc39F2654AC6D15,	
            0x08df7FEA38d44f100398DC9EF7D02207Fe9D0812,	
            0x62f7Fb8b2f0F522A4592DcA2265cA13149b80674,	
            0x082A3E23bf522972B3E67c1faF2AF1A72c489A24,	
            0x6c428B4a5f1478278399481AC9f1d4F0Fa0d7404,	
            0x05355ece7f3915cC8A1f1fbd058Ee0d76925cc56,	
            0xBa07b32CD60B6b3969Bb2f71f05586983dB7fE3a,	
            0x88963F32278A03b7F1aB4FE2Cd4fC1db8AB24B19,	
            0xa9F10b8fd83025Beb750a9778e64ad214C6877bB,	
            0x84F06E1227DAe87c04B3cEE2efA2b0d179837893,	
            0xF376C94dAc799C6EDEE11EF2c20eB5064Fe9822e,	
            0xf5d4C1E8835d97d4e5098ACcC61cC7f65ffCffaC,	
            0x16001dC857EC2a4820EAEe963A0f131b66473930,	
            0x4A94B70A0BBDaA5e7Bf1ACdB034249Be6345dac9,	
            0x37a9caa906a07F9836dAfab2a650B0a0e5e4e0c0,	
            0x35b2a6683541d2C404D895ba66c6Da9e03935E07,	
            0xb8294b0Be54d0668Ee71ae7cFdbb20374816F4b3,	
            0x96A6fb65321C66c83402De290620a23402EaBb29,	
            0x713EF8e0107A4CCFd4f29685CE828EEb1c92CF54,	
            0x55eB307Db35Fa3688EfDfB2F0cC825c2B893a141,	
            0xDcF9DfFEF43863F58371190Ec4d6B47Bef26cDB2,	
            0xA1B3067a4E261f8949093D795d537aa621483cF7,	
            0x8176daeab6157e91764FB73e135ff5f268a1D4F4,	
            0x4f4eEee58F4Dd725A50DDeB91378e06669201c60,	
            0x3391b714e5A30887e8687f13152B2098BDbAc4e6,	
            0x6b505b5d71717840DBBfc35Fc19De2f75B2D79c9,	
            0x449B6849F576DA2a5C3F3f041d6F39E7A066273f,	
            0xd01b4a52B0411c441a580Ea9969E5537fC6deeF0,	
            0x34C717Fb4d677B66DC996Dc95020ce185A2A9109,	
            0x10645DABb2C21BFAc1De2E9D3ce863A41E3eBEA2,	
            0x2CB7cE1CFF91aF2bb4807fe6984166a17CD489Bc,	
            0x73B988c9AA1b13260f2b3b30400799ecafFe503D,	
            0xF2738AFf580778a0967998B7ca3c74f9d3a0B4B3,	
            0x553a8547068f117BEdC4832263D5fB224bB63A2F,	
            0x92e41fABF502420dC858b3EbA0e6609aee586586,	
            0x6cCD98F25880a19bC6D0558680C0A15248387F27,	
            0x0B01975093eC4EC8E5984CbF709E0EBb877468e9,	
            0xd21669C4DCd7F1295454764D6FC6Ea6a59E34beC,	
            0x1835fD517cB848d59EB68b37371C3bF9bda483cC,	
            0x23EaEA1017Fb23876e28351B94bdbe409D481D00,	
            0xBa000eb2Cf871F344895d3d492915F887Dc43aac,	
            0x51524dA042E4EB78Aa9296b82d81963bF087a656,	
            0x968FB8A3d6d76e1E01Ab9816CC4EEAaDB6E629a0,	
            0xeFE01b2B007b73C24D37c0180582Dc54A54a5a41,	
            0x20d9e7Eb94C8bB5d26E4745F7b75Fd83BE69251c,	
            0xd5dbF66480844b7AaB2b09030Aebc6cecF33E5b2
        ];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    modifier validAddress() {
        require(msg.sender != address(0), "Invalid address");
        _;
    }

    function getUserStaked() public view validAddress returns (uint256) {
        return users[msg.sender].inverted;
    }

    function getUserStakedTime() public view validAddress returns (uint256) {
        return users[msg.sender].timestamp;
    }

    function getUserRewards() public view validAddress returns (uint256) {
        uint256 timeElapsed = ((block.timestamp - users[msg.sender].timestamp) / 86400);
        if(users[msg.sender].isInvestor)
            return (users[msg.sender].inverted * 932 * timeElapsed) / 10000;
        else
            return (users[msg.sender].inverted * 532 * timeElapsed) / 10000;
    }

    function supplyPool(uint256 _amount) public payable validAddress onlyOwner {
        require(erc20Contract.balanceOf(msg.sender) >= _amount, "Not enough NETC tokens in your wallet, please try lesser amount");
        require(erc20Contract.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance, please try lesser amount");

        contractBalance += _amount;
        erc20Contract.transferFrom(msg.sender, address(this), _amount);
    }

    function stake(uint256 _amount) public payable validAddress {

        require(erc20Contract.balanceOf(msg.sender) >= _amount, "Not enough NETC tokens in your wallet, please try lesser amount");
        require(erc20Contract.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance, please try lesser amount");
        require(users[msg.sender].inverted == 0, "You must withdraw everything before staking again");
        
        contractBalance += _amount;
        users[msg.sender].inverted += _amount;
        users[msg.sender].timestamp = block.timestamp;
        erc20Contract.transferFrom(msg.sender, address(this), _amount);
        
        if(IsInvestor(msg.sender)) users[msg.sender].isInvestor = true;
        else users[msg.sender].isInvestor = false;

        emit emitStake(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {
        users[msg.sender].available = users[msg.sender].inverted + getUserRewards();

        require(_amount <= users[msg.sender].available, "You don't have enough staked tokens");
        contractBalance -= _amount > users[msg.sender].inverted ? users[msg.sender].inverted : _amount;
        users[msg.sender].inverted -= _amount > users[msg.sender].inverted ? users[msg.sender].inverted : _amount;
        

        users[msg.sender].available = 0;
        users[msg.sender].timestamp = block.timestamp;
        erc20Contract.transfer(msg.sender, _amount);

        emit emitWithdraw(msg.sender, _amount);
    }

    function IsInvestor(address _staker) internal view returns (bool) {
        for (uint i = 0; i < invertsAddresses.length; i++) {
            if (invertsAddresses[i] == _staker) {
                return true;
            }
        }
        return false;
    }
}