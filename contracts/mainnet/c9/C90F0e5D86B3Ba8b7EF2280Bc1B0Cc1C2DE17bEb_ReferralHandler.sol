// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IETF {

    function rebase(uint256 epoch, uint256 supplyDelta, bool positive) external;
    function mint(address to, uint256 amount) external;
    function getPriorBalance(address account, uint blockNumber) external view returns (uint256);
    function mintForReferral(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferForRewards(address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

interface IMembershipNFT {
    function ownerOf(uint256) external view returns (address);
    function belongsTo(address) external view returns (uint256);
    function tier(uint256) external view returns(uint256);
    function issueNFT(address, string memory) external returns (uint256);
    function changeURI(uint256, string memory) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

interface INFTFactory {
    function isHandler(address) external view returns (bool);
    function getHandler(uint256) external view returns (address);
    function getEpoch(address) external view returns (uint256);
    function alertLevel(uint256, uint256) external;
    function alertSelfTaxClaimed(uint256, uint256) external;
    function alertReferralClaimed(uint256, uint256) external;
    function alertDepositClaimed(uint256, uint256) external;
    function registerUserEpoch(address) external;
    function updateUserEpoch(address, uint256) external;
    function getTierManager() external view returns(address);
    function getTaxManager() external view returns(address);
    function getRebaser() external view returns(address);
    function getRewarder() external view returns(address);
    function getAdmin() external view returns(address);
    function getHandlerForUser(address) external view returns (address);
    function getDepositBox(uint256) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IPoolEscrow {
  function notifySecondaryTokens(uint256 number) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IRebaser {

  function getPositiveEpochCount() external view returns (uint256);
  function getBlockForPositiveEpoch(uint256) external view returns (uint256);
  function getDeltaForPositiveEpoch(uint256) external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IReferralHandler {
    function initialize(address, address, address, uint256) external;
    function setTier(uint256 _tier) external;
    function setDepositBox(address) external;
    function checkExistence(uint256, address) external view returns (address);
    function coupledNFT() external view returns (address);
    function referredBy() external view returns (address);
    function ownedBy() external view returns (address);
    function getTier() external view returns (uint256);
    function getTransferLimit() external view returns(uint256);
    function remainingClaims() external view returns (uint256);
    function updateReferralTree(uint256 depth, uint256 NFTtier) external;
    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) external;
    function mintForRewarder(address recipient, uint256 amount ) external;
    function alertFactory(uint256 reward, uint256 timestamp) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IRewarder {
    function handleReward(uint256 claimedEpoch, address factory, address token) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ITaxManager {
    function getSelfTaxPool() external returns (address);
    function getRightUpTaxPool() external view returns (address);
    function getMaintenancePool() external view returns (address);
    function getDevPool() external view returns (address);
    function getRewardAllocationPool() external view returns (address);
    function getPerpetualPool() external view returns (address);
    function getTierPool() external view returns (address);
    function getMarketingPool() external view returns (address);
    function getRevenuePool() external view returns (address);

    function getSelfTaxRate() external view returns (uint256);
    function getRightUpTaxRate() external view returns (uint256);
    function getMaintenanceTaxRate() external view returns (uint256);
    function getProtocolTaxRate() external view returns (uint256);
    function getTotalTaxAtMint() external view returns (uint256);
    function getPerpetualPoolTaxRate() external view returns (uint256);
    function getTaxBaseDivisor() external view returns (uint256);
    function getReferralRate(uint256, uint256) external view returns (uint256);
    function getTierPoolRate() external view returns (uint256);
    // function getDevPoolRate() external view returns (uint256);
    function getMarketingTaxRate() external view returns (uint256);
    function getRewardPoolRate() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ITierManager {
    function checkTierUpgrade(uint256[5] memory) external returns (bool);
    function getTransferLimit(uint256) external view returns (uint256);
    function getTokenURI(uint256) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./interfaces/IMembershipNFT.sol";
import "./interfaces/IReferralHandler.sol";
import "./interfaces/ITierManager.sol";
import "./interfaces/IRebaserNew.sol";
import "./interfaces/IETFNew.sol";
import "./interfaces/ITaxManager.sol";
import "./interfaces/INFTFactory.sol";
import "./interfaces/IPoolEscrowNew.sol";
import "./interfaces/IRewarder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ReferralHandler {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address public factory;
    IMembershipNFT public NFTContract;
    IETF public token;
    uint256 public nftID;
    uint256 public mintTime;
    address public referredBy; // NFT address of the referrer's ID
    address[] public referrals;
    address public depositBox;
    uint256 private tier;
    bool private canLevel;
    // NFT addresses of those referred by this NFT and its subordinates
    address[] public firstLevelAddress;
    address[] public secondLevelAddress;
    address[] public thirdLevelAddress;
    address[] public fourthLevelAddress;
    bool public initialized = false;
    // Mapping of the above Address list and their corresponding NFT tiers
    mapping (address => uint256) public first_level;
    mapping (address => uint256) public second_level;
    mapping (address => uint256) public third_level;
    mapping (address => uint256) public fourth_level;

    modifier onlyAdmin() {
        require(msg.sender == INFTFactory(factory).getAdmin(), "only admin");
        _;
    }

    modifier onlyProtocol() {
        require(msg.sender == INFTFactory(factory).getAdmin() || msg.sender == factory, "only admin or factory");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == ownedBy(), "only owner");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "only factory");
        _;
    }

    modifier onlyRewarder() {
        require(msg.sender == INFTFactory(factory).getRewarder());
        _;
    }

    function initialize(
        address _token,
        address _referredBy,
        address _nftAddress,
        uint256 _nftId
    ) public {
        require(!initialized, "Already initialized");
        initialized = true;
        token = IETF(_token);
        factory = msg.sender;
        referredBy = _referredBy;
        NFTContract = IMembershipNFT(_nftAddress);
        nftID = _nftId;
        mintTime = block.timestamp;
        tier = 1; // Default tier is 1 instead of 0, since solidity 0 can also mean non-existant, all tiers on contract are + 1
        canLevel = true;
    }

    function setFactory(address account) public onlyAdmin {
        factory = account;
    }

    function ownedBy() public view returns (address) { // Returns the Owner of the NFT coupled with this handler
        return NFTContract.ownerOf(nftID);
    }

    function coupledNFT() public view returns (uint256) { // Returns the address of the NFT coupled with this handler
        return nftID;
    }

    function getTier() public view returns (uint256) {
        return tier.sub(1);
    }

    function getRebaser() public view returns (IRebaser) {
        address rebaser = INFTFactory(factory).getRebaser() ;
        return IRebaser(rebaser);
    }

    function getTierManager() public view returns (ITierManager) {
        address tierManager = INFTFactory(factory).getTierManager() ;
        return ITierManager(tierManager);
    }

    function getTaxManager() public view returns (ITaxManager) {
        address taxManager = INFTFactory(factory).getTaxManager() ;
        return ITaxManager(taxManager);
    }

    function changeEligibility(bool status) public onlyAdmin {
        canLevel = status;
    }

    function remainingClaims() public view returns (uint256) {
        uint256 currentEpoch = getRebaser().getPositiveEpochCount();
        uint256 claimedEpoch = INFTFactory(factory).getEpoch(ownedBy());
        return currentEpoch.sub(claimedEpoch);
    }

    function getTransferLimit() public view returns(uint256)
    {
        return getTierManager().getTransferLimit(getTier());
    }

    function getDepositBox() public view returns (address) {
        return depositBox;
    }

    function setDepositBox(address _depositBox) external onlyFactory {
        depositBox = _depositBox;
    }

    function checkExistenceAndLevel(uint256 depth, address referred) view public returns (uint256) {
        // Checks for existence for the given address in the given depth of the tree
        // Returns 0 if it does not exist, else returns the NFT tier
        require(depth <= 4 && depth >= 1, "Invalid depth");
        require(referred != address(0), "Invalid referred address");
        if (depth == 1) {
            return first_level[referred];
        } else if (depth == 2) {
            return second_level[referred];
        } else if (depth == 3) {
            return third_level[referred];
        } else if (depth == 4) {
            return fourth_level[referred];
        }
        return 0;
    }

    function updateReferrersAbove(uint256 _tier) internal {
        address _handler = address(this);
        address first_ref = IReferralHandler(_handler).referredBy();
        if(first_ref != address(0)) {
            IReferralHandler(first_ref).updateReferralTree(1, _tier);
            address second_ref = IReferralHandler(first_ref).referredBy();
            if(second_ref != address(0)) {
                IReferralHandler(second_ref).updateReferralTree(2, _tier);
                address third_ref = IReferralHandler(second_ref).referredBy();
                if(third_ref != address(0)) {
                    IReferralHandler(third_ref).updateReferralTree(3, _tier);
                    address fourth_ref = IReferralHandler(third_ref).referredBy();
                    if(fourth_ref != address(0))
                        IReferralHandler(fourth_ref).updateReferralTree(4, _tier);
                }
            }
        }
    }

    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) public onlyFactory { // _referral address is address of the NFT handler not the new user
        require(depth <= 4, "Invalid depth");
        require(referred != address(0), "Invalid referred address");
        if (depth == 1) {
            firstLevelAddress.push(referred);
            first_level[referred] = NFTtier;
        } else if (depth == 2) {
            secondLevelAddress.push(referred);
            second_level[referred] = NFTtier;
        } else if (depth == 3) {
            thirdLevelAddress.push(referred);
            third_level[referred] = NFTtier;
        } else if (depth == 4) {
            fourthLevelAddress.push(referred);
            fourth_level[referred] = NFTtier;
        }
    }

    function updateReferralTree(uint256 depth, uint256 NFTtier) external {
        require(depth <= 4 && depth >= 1, "Invalid depth");
        require(msg.sender != address(0), "Invalid referred address");
        if (depth == 1) {
            require(first_level[msg.sender]!= 0, "Cannot update non-existant entry");
            first_level[msg.sender] = NFTtier;
        } else if (depth == 2) {
            require(second_level[msg.sender]!= 0, "Cannot update non-existant entry");
            second_level[msg.sender] = NFTtier;
        } else if (depth == 3) {
            require(third_level[msg.sender]!= 0, "Cannot update non-existant entry");
            third_level[msg.sender] = NFTtier;
        } else if (depth == 4) {
            require(fourth_level[msg.sender]!= 0, "Cannot update non-existant entry");
            fourth_level[msg.sender] = NFTtier;
        }
    }

    function getTierCounts() public view returns (uint256[5] memory) { // returns count of Tiers 0 to 5 under the user
        uint256[5] memory tierCounts; // Tiers can be 0 to 4 (Stored 1 to 5 in Handlers)
        for (uint256 index = 0; index < firstLevelAddress.length; index++) {
            address referral = firstLevelAddress[index];
            uint256 NFTtier = first_level[referral].sub(1); // Subtrating one to offset the default +1 due to solidity limitations
            tierCounts[NFTtier]++;
        }
        for (uint256 index = 0; index < secondLevelAddress.length; index++) {
            address referral = secondLevelAddress[index];
            uint256 NFTtier = second_level[referral].sub(1);
            tierCounts[NFTtier]++;
        }
        for (uint256 index = 0; index < thirdLevelAddress.length; index++) {
            address referral = thirdLevelAddress[index];
            uint256 NFTtier = third_level[referral].sub(1);
            tierCounts[NFTtier]++;
        }
        for (uint256 index = 0; index < fourthLevelAddress.length; index++) {
            address referral = fourthLevelAddress[index];
            uint256 NFTtier = fourth_level[referral].sub(1);
            tierCounts[NFTtier]++;
        }
        return tierCounts;
    }

    function setTier(uint256 _tier) public onlyProtocol {
        require( _tier >= 0 && _tier < 5, "Invalid depth");
        uint256 oldTier = getTier(); // For events
        tier = _tier.add(1); // Adding the default +1 offset stored in handlers
        updateReferrersAbove(tier);
        string memory tokenURI = getTierManager().getTokenURI(getTier());
        NFTContract.changeURI(nftID, tokenURI);
        INFTFactory(factory).alertLevel(oldTier, getTier());
    }

    function levelUp() public returns (bool) {
        if(getTier() < 4 &&  canLevel == true && getTierManager().checkTierUpgrade(getTierCounts()) == true)
        {
            uint256 oldTier = getTier(); // For events
            updateReferrersAbove(tier.add(1));
            tier = tier.add(1);
            string memory tokenURI = getTierManager().getTokenURI(getTier());
            NFTContract.changeURI(nftID, tokenURI);
            INFTFactory(factory).alertLevel(oldTier, getTier());
            return true;
        }
        return false;
    }

    function claimReward() public { // Can be called by anyone but rewards always goes to owner of NFT
        // This function mints the tokens that were deducted at rebase and disperses them
        // This also calls the claim function if there referral rewards from below available to claim
        address owner = ownedBy();
        ITaxManager taxManager =  getTaxManager();
        uint256 currentEpoch = getRebaser().getPositiveEpochCount();
        uint256 protocolTaxRate = taxManager.getProtocolTaxRate();
        uint256 taxDivisor = taxManager.getTaxBaseDivisor();
        uint256 claimedEpoch = INFTFactory(factory).getEpoch(ownedBy());
        if (claimedEpoch < currentEpoch) {
            claimedEpoch++;
            IRewarder rewarder = IRewarder(INFTFactory(factory).getRewarder());
            rewarder.handleReward(claimedEpoch, factory, address(token));
        }
        uint256 currentClaimable = token.balanceOf(address(this));
        if(currentClaimable > 0)
            handleClaimTaxAndDistribution(owner, currentClaimable, protocolTaxRate, taxDivisor);
        levelUp();
    }

    function mintForRewarder(address recipient, uint256 amount ) external onlyRewarder {
        token.mintForReferral(recipient, amount);
    }

    function alertFactory(uint256 reward, uint256 timestamp) external onlyRewarder {
        INFTFactory(factory).alertSelfTaxClaimed(reward, timestamp);
    }

    function handleClaimTaxAndDistribution(address owner, uint256 currentClaimable, uint256 protocolTaxRate, uint256 taxDivisor) internal {
        ITaxManager taxManager =  getTaxManager();
        uint256 leftOverTaxRate = protocolTaxRate;
        address _handler = address(this);
        address [5] memory referral; // Used to store above referrals, saving variable space
        // User Distribution
        // Block Scoping to reduce local Variables spillage
        {
        uint256 taxedAmount = currentClaimable.mul(protocolTaxRate).div(taxDivisor);
        uint256 userReward = currentClaimable.sub(taxedAmount);
        token.transferForRewards(owner, userReward);
        INFTFactory(factory).alertReferralClaimed(userReward, block.timestamp);
        }
        {
        uint256 perpetualTaxRate = taxManager.getPerpetualPoolTaxRate();
        uint256 perpetualAmount = currentClaimable.mul(perpetualTaxRate).div(taxDivisor);
        address perpetualPool = taxManager.getPerpetualPool();
        IERC20(address(token)).safeApprove(perpetualPool, 0);
        IERC20(address(token)).safeApprove(perpetualPool, perpetualAmount);
        IPoolEscrow(perpetualPool).notifySecondaryTokens(perpetualAmount);
        leftOverTaxRate = leftOverTaxRate.sub(perpetualTaxRate);
        }
        // Block Scoping to reduce local Variables spillage
        {
        uint256 protocolMaintenanceRate = taxManager.getMaintenanceTaxRate();
        uint256 protocolMaintenanceAmount = currentClaimable.mul(protocolMaintenanceRate).div(taxDivisor);
        address maintenancePool = taxManager.getMaintenancePool();
        token.transferForRewards(maintenancePool, protocolMaintenanceAmount);
        leftOverTaxRate = leftOverTaxRate.sub(protocolMaintenanceRate); // Minted above
        }
        referral[1]  = IReferralHandler(_handler).referredBy();
        if(referral[1] != address(0)) {
            // Block Scoping to reduce local Variables spillage
            {
            // Rightup Reward
            uint256 rightUpRate = taxManager.getRightUpTaxRate();
            uint256 rightUpAmount = currentClaimable.mul(rightUpRate).div(taxDivisor);
            token.transferForRewards(referral[1], rightUpAmount);
            leftOverTaxRate = leftOverTaxRate.sub(rightUpRate);
            // Normal Referral Reward
            uint256 firstTier = IReferralHandler(referral[1]).getTier();
            uint256 firstRewardRate = taxManager.getReferralRate(1, firstTier);
            uint256 firstReward = currentClaimable.mul(firstRewardRate).div(taxDivisor);
            token.transferForRewards(referral[1], firstReward);
            leftOverTaxRate = leftOverTaxRate.sub(firstRewardRate);
            }
            referral[2] = IReferralHandler(referral[1]).referredBy();
            if(referral[2] != address(0)) {
                // Block Scoping to reduce local Variables spillage
                {
                uint256 secondTier = IReferralHandler(referral[2]).getTier();
                uint256 secondRewardRate = taxManager.getReferralRate(2, secondTier);
                uint256 secondReward = currentClaimable.mul(secondRewardRate).div(taxDivisor);
                token.transferForRewards(referral[2], secondReward);
                leftOverTaxRate = leftOverTaxRate.sub(secondRewardRate);
                }
                referral[3] = IReferralHandler(referral[2]).referredBy();
                if(referral[3] != address(0)) {
                // Block Scoping to reduce local Variables spillage
                    {
                    uint256 thirdTier = IReferralHandler(referral[3]).getTier();
                    uint256 thirdRewardRate = taxManager.getReferralRate(3, thirdTier);
                    uint256 thirdReward = currentClaimable.mul(thirdRewardRate).div(taxDivisor);
                    token.transferForRewards(referral[3], thirdReward);
                    leftOverTaxRate = leftOverTaxRate.sub(thirdRewardRate);
                    }
                    referral[4] = IReferralHandler(referral[3]).referredBy();
                    if(referral[4] != address(0)) {
                        // Block Scoping to reduce local Variables spillage
                        {
                        uint256 fourthTier = IReferralHandler(referral[4]).getTier();
                        uint256 fourthRewardRate = taxManager.getReferralRate(4, fourthTier);
                        uint256 fourthReward = currentClaimable.mul(fourthRewardRate).div(taxDivisor);
                        token.transferForRewards(referral[4], fourthReward);
                        leftOverTaxRate = leftOverTaxRate.sub(fourthRewardRate);
                        }
                    }
                }
            }
        }
        // Reward Allocation
        {
        uint256 rewardTaxRate = taxManager.getRewardPoolRate();
        uint256 rewardPoolAmount = currentClaimable.mul(rewardTaxRate).div(taxDivisor);
        address rewardPool = taxManager.getRewardAllocationPool();
        token.transferForRewards(rewardPool, rewardPoolAmount);
        leftOverTaxRate = leftOverTaxRate.sub(rewardTaxRate);
        }
        // Dev Allocation & // Revenue Allocation
        {
        uint256 leftOverTax = currentClaimable.mul(leftOverTaxRate).div(taxDivisor);
        address devPool = taxManager.getDevPool();
        address revenuePool = taxManager.getRevenuePool();
        token.transferForRewards(devPool, leftOverTax.div(2));
        token.transferForRewards(revenuePool, leftOverTax.div(2));
        }
    }
}