/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol


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
interface IERC20PermitUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
        IERC20PermitUpgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// File: @openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol


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
library SafeMathUpgradeable {
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

// File: dc-v-proposal/proposal.sol


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;





interface ITimelock {
  function delay() external view returns (uint256);
  function GRACE_PERIOD() external view returns (uint256);
  function acceptAdmin() external;
  function queuedTransactions(bytes32 hash) external view returns (bool);
  function queueTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external returns (bytes32);
  function cancelTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external;
  function executeTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external payable returns (bytes memory);
}

contract Proposal {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  string public constant name = "Dogechain Governance";
  uint256 public constant MIN_QUORUM_VOTES = 500000000e18;
  uint256 public constant MIN_VOTING_PERIOD = 30 * 60 * 24; // About 24 hours, 2 secs per block
  uint256 public constant MAX_VOTING_PERIOD = 30 * 60 * 24 * 14;
  uint256 public constant MIN_VOTING_DELAY = 30;
  uint256 public constant MAX_VOTING_DELAY = 30 * 60 * 24 * 7;
  bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
  bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

  enum ProposalState {
    Pending,
    Active,
    Canceled,
    Defeated,
    Succeeded,
    Queued,
    Expired,
    Executed
  }

  struct Receipt {
    bool hasVoted;
    uint8 support; // 0=against, 1=for, 2=abstain
    uint256 votes;
    bool hasClaimed;
  }

  struct ProposalInfo {
    uint256 id;
    address proposer;
    uint256 eta;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    uint256 startBlock;
    uint256 endBlock;
    uint256 forVotes;
    uint256 againstVotes;
    uint256 abstainVotes;
    bool canceled;
    bool executed;
    mapping (address => Receipt) receipts;
  }

  address public admin;
  address public pendingAdmin;
  uint256 public votingDelay;
  uint256 public votingPeriod;
  uint256 public proposalCount;
  uint256 public quorumVotes;
  ITimelock public timelock;
  IERC20Upgradeable public DC;
  mapping (uint256 => ProposalInfo) public proposals;
  mapping (address => uint256) public latestProposalIds;
  uint256 public proposalMaxOperations;
  address public guardian;

  event ProposalCreated(uint256 id, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 startBlock, uint256 endBlock, string description);
  event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 votes, string reason);
  event ProposalCanceled(uint256 id);
  event ProposalQueued(uint256 id, uint256 eta);
  event ProposalExecuted(uint256 id);
  event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);
  event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
  event NewAdmin(address oldAdmin, address newAdmin);
  event NewGuardian(address oldGuardian, address newGuardian);
  event ProposalMaxOperationsUpdated(uint256 oldMaxOperations, uint256 newMaxOperations);
  event Withdrawal(address indexed to, uint256 indexed amount);

  function initialize(address timelock_, address dc_, uint256 votingPeriod_, uint256 votingDelay_, uint256 quorumVotes_, address guardian_) public {
    require(address(timelock) == address(0), "Can only initialize once");
    require(timelock_ != address(0), "Invalid timelock address");
    require(dc_ != address(0), "Invalid vote address");
    require(votingPeriod_ >= MIN_VOTING_PERIOD && votingPeriod_ <= MAX_VOTING_PERIOD, "Invalid voting period");
    require(votingDelay_ >= MIN_VOTING_DELAY && votingDelay_ <= MAX_VOTING_DELAY, "Invalid voting delay");
    require(quorumVotes_ >= MIN_QUORUM_VOTES, "Invalid quorum votes");
    require(guardian_ != address(0), "Invalid guardian");

    timelock = ITimelock(timelock_);
    DC = IERC20Upgradeable(dc_);
    votingPeriod = votingPeriod_;
    votingDelay = votingDelay_;
    quorumVotes = quorumVotes_;
    proposalMaxOperations = 10;
    guardian = guardian_;
    admin = msg.sender;
  }

  function propose(address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) public returns (uint256) {
    require(msg.sender == admin, "Admin only");
    require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "Proposal function information arity mismatch");
    require(targets.length != 0, "Must provide actions");
    require(targets.length <= proposalMaxOperations, "Too many actions");

    uint256 latestProposalId = latestProposalIds[msg.sender];
    if (latestProposalId != 0) {
      ProposalState proposalState = state(latestProposalId);
      require(proposalState != ProposalState.Active, "Already active proposal");
      require(proposalState != ProposalState.Pending, "Already pending proposal");
    }

    uint256 startBlock = block.number.add(votingDelay);
    uint256 endBlock = startBlock.add(votingPeriod);

    proposalCount++;
    proposals[proposalCount].id = proposalCount;
    proposals[proposalCount].proposer = msg.sender;
    proposals[proposalCount].targets = targets;
    proposals[proposalCount].values = values;
    proposals[proposalCount].signatures = signatures;
    proposals[proposalCount].calldatas = calldatas;
    proposals[proposalCount].startBlock = startBlock;
    proposals[proposalCount].endBlock = endBlock;
    latestProposalIds[msg.sender] = proposalCount;

    emit ProposalCreated(proposalCount, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
    return proposalCount;
  }

  function queue(uint256 proposalId) external {
    require(state(proposalId) == ProposalState.Succeeded, "Proposal can only be queued if it is succeeded");
    ProposalInfo storage p = proposals[proposalId];
    uint256 eta = block.timestamp.add(timelock.delay());
    for (uint256 i = 0; i < p.targets.length; i++) {
      queueOrRevertInternal(p.targets[i], p.values[i], p.signatures[i], p.calldatas[i], eta);
    }
    p.eta = eta;
    emit ProposalQueued(proposalId, eta);
  }

  function queueOrRevertInternal(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) internal {
    require(!timelock.queuedTransactions(keccak256(abi.encode(target, value, signature, data, eta))), "Identical proposal action already queued at eta");
    timelock.queueTransaction(target, value, signature, data, eta);
  }

  function execute(uint256 proposalId) external payable {
    require(state(proposalId) == ProposalState.Queued, "Proposal can only be executed if it is queued");
    ProposalInfo storage p = proposals[proposalId];
    p.executed = true;
    for (uint256 i = 0; i < p.targets.length; i++) {
      timelock.executeTransaction{value:p.values[i]}(p.targets[i], p.values[i], p.signatures[i], p.calldatas[i], p.eta);
    }
    emit ProposalExecuted(proposalId);
  }

  function cancel(uint256 proposalId) external {
    require(state(proposalId) != ProposalState.Executed, "Cannot cancel executed proposal");

    ProposalInfo storage p = proposals[proposalId];
    require(!p.canceled, "Already canceled");
    require(msg.sender == guardian || msg.sender == p.proposer, "Proposer above threshold");

    p.canceled = true;
    for (uint256 i = 0; i < p.targets.length; i++) {
      timelock.cancelTransaction(p.targets[i], p.values[i], p.signatures[i], p.calldatas[i], p.eta);
    }

    emit ProposalCanceled(proposalId);
  }

  function claim(uint256 proposalId) external {
    require(state(proposalId) != ProposalState.Active, "Withdraw can only be used when inactive");
    ProposalInfo storage p = proposals[proposalId];
    Receipt storage receipt = p.receipts[msg.sender];
    require(receipt.votes > 0, "Forbid");
    require(!receipt.hasClaimed, "Already claimed");
    receipt.hasClaimed = true;
    DC.safeTransfer(msg.sender, receipt.votes);
    emit Withdrawal(msg.sender, receipt.votes);
  }

  function getActions(uint256 proposalId) external view returns (address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas) {
    ProposalInfo storage p = proposals[proposalId];
    return (p.targets, p.values, p.signatures, p.calldatas);
  }

  function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory) {
    return proposals[proposalId].receipts[voter];
  }

  function state(uint256 proposalId) public view returns (ProposalState) {
    require(proposalCount >= proposalId, "Invalid proposal id");
    ProposalInfo storage p = proposals[proposalId];
    if (p.canceled) {
      return ProposalState.Canceled;
    } else if (block.number <= p.startBlock) {
      return ProposalState.Pending;
    } else if (block.number <= p.endBlock) {
      return ProposalState.Active;
    } else if (p.forVotes <= p.againstVotes || p.forVotes < quorumVotes) {
      return ProposalState.Defeated;
    } else if (p.eta == 0) {
      return ProposalState.Succeeded;
    } else if (p.executed) {
      return ProposalState.Executed;
    } else if (block.timestamp >= p.eta.add(timelock.GRACE_PERIOD())) {
      return ProposalState.Expired;
    } else {
      return ProposalState.Queued;
    }
  }

  function castVote(uint256 proposalId, uint8 support, uint256 votes) external {
    emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support, votes), "");
  }

  function castVoteWithReason(uint256 proposalId, uint8 support, uint256 votes, string calldata reason) external {
    emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support, votes), reason);
  }

  function castVoteBySig(uint256 proposalId, uint8 support, uint256 votes, uint8 v, bytes32 r, bytes32 s) external {
    bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
    bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "Invalid signature");
    emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support, votes), "");
  }

  function castVoteInternal(address voter, uint256 proposalId, uint8 support, uint256 votes) internal returns (uint256) {
    require(state(proposalId) == ProposalState.Active, "Voting is closed");
    require(support <= 2, "Invalid vote type");
    ProposalInfo storage p = proposals[proposalId];
    Receipt storage receipt = p.receipts[voter];
    DC.safeTransferFrom(msg.sender, address(this), votes);

    if (receipt.hasVoted) {
      require(receipt.support == support, "Cannot perform multiple voting");
    } else {
      receipt.hasVoted = true;
      receipt.support = support;
    }
    receipt.votes = receipt.votes.add(votes);

    if (support == 0) {
      p.againstVotes = p.againstVotes.add(votes);
    } else if (support == 1) {
      p.forVotes = p.forVotes.add(votes);
    } else if (support == 2) {
      p.abstainVotes = p.abstainVotes.add(votes);
    }

    return votes;
  }

  function setGuardian(address newGuardian) external {
    require(msg.sender == guardian || msg.sender == admin, "Admin or guardian only");
    require(newGuardian != address(0), "Cannot live without a guardian");
    address oldGuardian = guardian;
    guardian = newGuardian;
    emit NewGuardian(oldGuardian, newGuardian);
  }

  function setVotingDelay(uint256 newVotingDelay) external {
    require(msg.sender == admin, "Admin only");
    require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "Invalid voting delay");
    uint256 oldVotingDelay = votingDelay;
    votingDelay = newVotingDelay;
    emit VotingDelaySet(oldVotingDelay, votingDelay);
  }

  function setVotingPeriod(uint256 newVotingPeriod) external {
    require(msg.sender == admin, "Admin only");
    require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "Invalid voting period");
    uint256 oldVotingPeriod = votingPeriod;
    votingPeriod = newVotingPeriod;
    emit VotingPeriodSet(oldVotingPeriod, votingPeriod);
  }

  function setProposalMaxOperations(uint256 newProposalMaxOperations) external {
    require(msg.sender == admin, "Admin only");
    uint256 oldProposalMaxOperations = proposalMaxOperations;
    proposalMaxOperations = newProposalMaxOperations;
    emit ProposalMaxOperationsUpdated(oldProposalMaxOperations, newProposalMaxOperations);
  }

  function setPendingAdmin(address newPendingAdmin) external {
    require(msg.sender == admin, "Admin only");
    address oldPendingAdmin = pendingAdmin;
    pendingAdmin = newPendingAdmin;
    emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
  }

  function acceptAdmin() external {
    require(msg.sender == pendingAdmin, "pendingAdmin only");
    address oldAdmin = admin;
    address oldPendingAdmin = pendingAdmin;
    admin = pendingAdmin;
    pendingAdmin = address(0);
    emit NewAdmin(oldAdmin, admin);
    emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
  }

  function getChainId() internal view returns (uint256) {
    uint256 chainId;
    assembly { chainId := chainid() }
    return chainId;
  }

  function getBlockNumber() external view returns (uint256) {
    return block.number;
  }
}