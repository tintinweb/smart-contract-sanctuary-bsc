// SPDX-License-Identifier: MIT

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

// File: AdminContractQF.sol



pragma solidity ^0.8.4;






contract AdminContractQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDataContractQF public iDataContractQF;

    constructor(address _accessContract) {
        iDataContractQF = IDataContractQF(_accessContract);
    }

    struct AdjustThresoldForLevelUpdateStruct{
        QueueFinanceLib.Threshold[] currentThresholds;
        uint256 level;
        uint256 iGap;
        bool isIncrease;
        QueueFinanceLib.DepositsBySequence[] depositInfo;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        uint256 totalLevels;
        uint256 _pid;
    }

    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }

    // Add a new farm to the pool. Can only be called by the owner.
    
    function add(
        address _depositToken,
        address _rewardToken,
        uint256 _maximumStakingAllowed,
        uint256 _poolStartTime,
        uint256 _poolEndTime,
        uint256 _levelStakingLimit,
        uint256 _rate,
        address _treasury,
        uint256 _pid,
        bool _isPrivate
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        require(iDataContractQF.getPoolInfoLength() == _pid, "PID wrong");

        uint256[] memory _taxRates = new uint256[](10);

        //push required
        QueueFinanceLib.PoolInfo memory poolInfo =  QueueFinanceLib.PoolInfo({
                totalStaked: 0,
                eInvestCoinValue: 1000000000000000000,
                depositToken: IERC20(_depositToken),
                rewardToken: IERC20(_rewardToken),
                isStarted: true,
                maximumStakingAllowed: _maximumStakingAllowed,
                currentSequence: 0,
                poolStartTime: _poolStartTime,
                poolEndTime: _poolEndTime,
                rewardsBalance: 0,
                levels: 1,
                lastActiveSequence: 0,
                taxRates: _taxRates
            });

        QueueFinanceLib.LevelInfo memory levelInfo = QueueFinanceLib.LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });

          QueueFinanceLib.RateInfoStruct memory rateInfo =  QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: _poolStartTime});

        QueueFinanceLib.DepositInfo memory depositInfo = QueueFinanceLib.DepositInfo({
            wallet: address(0),
            depositDateTime: _poolStartTime, // UTC
            initialStakedAmount: 0,
            iCoinValue: (1 * 10) ^ 18,
            stakedAmount: 0,
            accuredCoin: 0,
            claimedCoin: 0,
            lastUpdated: _poolStartTime,
            nextSequenceID: 0,
            previousSequenceID: 0,
            inactive: 0
        });
        QueueFinanceLib.Threshold memory threshold = QueueFinanceLib.Threshold({sequence: 0, amount: 0});
        iDataContractQF.addPool(poolInfo);
        iDataContractQF.setDepositInfo(_pid, 0, depositInfo);
        iDataContractQF.setLevelsInfo(_pid, 0, levelInfo);
        iDataContractQF.pushWholeRateInfoStruct(rateInfo);
        iDataContractQF.setCurrentThresholds(_pid, 0, threshold);
        iDataContractQF.setLastUpdatedLevelForDeposits(_pid, 0, 0, 0);
        iDataContractQF.setTreasury(_pid, _treasury);
        iDataContractQF.setPoolIsPrivate(_pid, _isPrivate);
    }


    function setCurrentThresholds(
        uint256 _pid,
        uint256 _level,
        uint256 _sequence,
        uint256 _amount
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setCurrentThresholds(
            _pid,
            _level,
            QueueFinanceLib.Threshold({sequence: _sequence, amount: _amount})
        );
    }

    function addLevelsInfo(
        uint256 _poolID,
        uint256 _rate,
        uint256 _levelStakingLimit,
        uint8 _level
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        QueueFinanceLib.PoolInfo memory poolInfo = iDataContractQF.getPoolInfo(_poolID);
        require(_level == poolInfo.levels, "Level mismatch");

        QueueFinanceLib.LevelInfo memory levelsInfo  = QueueFinanceLib.LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });

        QueueFinanceLib.RateInfoStruct memory rateInfo =  QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: poolInfo.poolStartTime});


        QueueFinanceLib.Threshold memory threholdInfo  = QueueFinanceLib.Threshold({
            sequence: 0,
            amount: 0
        });

        QueueFinanceLib.AddLevelData memory _addLevelData = QueueFinanceLib.AddLevelData({
              poolId: _poolID,
         levelId: _level,
         levelInfo: levelsInfo,
         rateInfo: rateInfo,
         threshold: threholdInfo
        });

        // iDataContractQF.addLevelData(_addLevelData);
        iDataContractQF.incrementPoolInfoLevels(_addLevelData.poolId);
        iDataContractQF.setLevelInfo(_addLevelData.poolId, _addLevelData.levelId, _addLevelData.levelInfo);
        iDataContractQF.pushRateInfoStruct(_addLevelData.poolId, _addLevelData.rateInfo);
        iDataContractQF.setCurrentThresholds(_addLevelData.poolId, _addLevelData.levelId, _addLevelData.threshold);

    }

    function getUpdateLevelRequiredData(uint256 _poolId) internal view returns (QueueFinanceLib.FetchUpdateLevelData memory) {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        return QueueFinanceLib.FetchUpdateLevelData({
             levelsInfo:iDataContractQF.getAllLevelInfo(_poolId),
             thresholds:iDataContractQF.getAllThresholds(_poolId),
             depositsInfo: iDataContractQF.fetchDepositsBasedonSequences(_poolId, iDataContractQF.getSequenceIdsFromCurrentThreshold(_poolId))
        });
    }


    function updateLevelInfoGlobal(
        uint256 _poolID,
        uint256 _levelID,
        // uint256 _levelStaked,
        uint256 _levelStakingLimit
    ) public view{
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        QueueFinanceLib.FetchUpdateLevelData memory fetchUpdateLevelData = getUpdateLevelRequiredData(_poolID);
        QueueFinanceLib.LevelInfo[] memory  levelsInfo  = fetchUpdateLevelData.levelsInfo;
        QueueFinanceLib.Threshold[] memory  currentThresholds  = fetchUpdateLevelData.thresholds;
        QueueFinanceLib.DepositsBySequence[] memory  depositsInfo  = fetchUpdateLevelData.depositsInfo;
        uint256 totalLevels = iDataContractQF.getPoolInfo(_poolID).levels;

        bool isIncrease = false;
        uint256 gap = 0;

        if (
            levelsInfo[_levelID].levelStakingLimit < _levelStakingLimit
        ) {
            isIncrease = true;
            gap = _levelStakingLimit.sub(
                levelsInfo[_levelID].levelStakingLimit
            );
        } else {
            gap = levelsInfo[_levelID].levelStakingLimit.sub(
                _levelStakingLimit
            );
        }

        levelsInfo[_levelID].levelStakingLimit = _levelStakingLimit;
        // create gap and progress.

        uint256[] memory levelUpdateAmounts = new uint256[](
            totalLevels
        );
        levelUpdateAmounts[_levelID] = gap;
        (levelsInfo) = updateLevelForBlockRemoval(levelsInfo, levelUpdateAmounts, true, totalLevels);
        //set 1 for global limit increase

        for (uint256 i = _levelID; i < totalLevels; i++) {
            //No blocks available for moving
            if (levelsInfo[i].levelStaked == 0) {
                currentThresholds[i].amount = 0;
                currentThresholds[i].sequence = 0;
                break;
            }


            adjustThresholdForLevelUpdate(AdjustThresoldForLevelUpdateStruct({
                  currentThresholds:currentThresholds,
         level:i,
         iGap:gap,
         isIncrease:isIncrease,
        depositInfo:depositsInfo,
     levelsInfo:levelsInfo,
         totalLevels:totalLevels,
         _pid:_poolID
            }));
        }
    }

    function adjustThresholdForLevelUpdate(
       AdjustThresoldForLevelUpdateStruct memory _adjustThresholdForLevelUpdateParams
    ) internal view {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        if (_adjustThresholdForLevelUpdateParams.isIncrease) {
            QueueFinanceLib.Threshold memory ths = _adjustThresholdForLevelUpdateParams.currentThresholds[_adjustThresholdForLevelUpdateParams.level];
            uint256 _thresholdConsumedTillLastLevel = thresholdConsumedTillLastLevel(
                 _adjustThresholdForLevelUpdateParams.currentThresholds,
                    ths.sequence,
                    _adjustThresholdForLevelUpdateParams.level
                );
            uint256 _total = QueueFinanceLib.pickDepositBySequenceId(_adjustThresholdForLevelUpdateParams.depositInfo, ths.sequence).initialStakedAmount;
            // calculate how much can be moved in the same block
          uint256 _levelStakingLimit =  _adjustThresholdForLevelUpdateParams.levelsInfo[_adjustThresholdForLevelUpdateParams.level].levelStakingLimit;

            uint256 _toAdjust = thresholdMoveInSameBlock(
                ths.amount,
                _thresholdConsumedTillLastLevel,
                _total,
                _adjustThresholdForLevelUpdateParams.iGap,
                _levelStakingLimit
            );
           _adjustThresholdForLevelUpdateParams.currentThresholds[_adjustThresholdForLevelUpdateParams.level].amount = _toAdjust;
            // calculate remaining gap
            _adjustThresholdForLevelUpdateParams.iGap = calculateRemainingGap(
                _thresholdConsumedTillLastLevel,
                ths.amount,
                _total,
                _levelStakingLimit,
                _adjustThresholdForLevelUpdateParams.iGap,
                _toAdjust
            );
            _adjustThresholdForLevelUpdateParams.currentThresholds = moveThresholdInALoop(_adjustThresholdForLevelUpdateParams.currentThresholds,_adjustThresholdForLevelUpdateParams.depositInfo, _adjustThresholdForLevelUpdateParams.level, _adjustThresholdForLevelUpdateParams.iGap,_adjustThresholdForLevelUpdateParams.totalLevels,_adjustThresholdForLevelUpdateParams._pid);
        }
        //isIncrease == NO
    }

    function moveThresholdInALoop(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        QueueFinanceLib.DepositsBySequence[] memory depositInfo,
        uint256 level,
        uint256 iGap,
        uint256 totalLevels,
        uint256 _pid
    ) public view returns (QueueFinanceLib.Threshold[] memory) {
        QueueFinanceLib.DepositInfo memory currentSeqDeposit = QueueFinanceLib.pickDepositBySequenceId(
            depositInfo,
            currentThresholds[level].sequence
        );
        uint256 nextSeq = currentSeqDeposit.nextSequenceID;
        while ((iGap > 0) && (nextSeq > 0)) {
           QueueFinanceLib.DepositInfo memory nextSeqDeposit = iDataContractQF.getDepositBySequenceId(_pid, nextSeq);
            if (nextSeqDeposit.initialStakedAmount < iGap) {
                iGap -= nextSeqDeposit.initialStakedAmount;
                uint256 nextSeq1 = nextSeqDeposit.nextSequenceID;

                if (nextSeq1 == 0) {
                    currentThresholds[level].sequence = nextSeq;
                    currentThresholds[level].amount = getThresholdInfo(
                        currentThresholds,
                        nextSeqDeposit.initialStakedAmount,
                        totalLevels,
                        nextSeq
                    )[level];
                    break;
                }
                nextSeq = nextSeq1;
                continue;
            } else if (nextSeqDeposit.initialStakedAmount == iGap) {
                currentThresholds[level].sequence = nextSeq;
                currentThresholds[level].amount = currentSeqDeposit
                    .initialStakedAmount;
                iGap = 0;
                break;
            } else if (nextSeqDeposit.initialStakedAmount > iGap) {
                currentThresholds[level].sequence = nextSeq;
                currentThresholds[level].amount = iGap;
                iGap = 0;
                break;
            }
        }

        return currentThresholds;
    }




    function setInterestRate(
        uint256 _pid,
        uint256 _levelID,
        uint256 _date,
        uint256 _rate
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        require(
            _date >= iDataContractQF.getPoolStartTime(_pid),
            "Interest date is earlier"
        );
        require(
            iDataContractQF.getLatestRateInfo(_pid, _levelID)
                .timestamp < _date,
            "Date should be greater than last "
        );

        iDataContractQF.pushRateInfo(_pid, _levelID, QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: _date}));

    }

    // Update maxStaking. Can only be called by the owner.
    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setMaximumStakingAllowed(_pid, _maximumStakingAllowed);
    }

    //      Ensure to set the dates in ascending order
    function setInterestRatePosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        uint256 _date,
        uint256 _rate
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        uint256 rateInfoLength = iDataContractQF.getRateInfoLength(_pid,_levelID);

            QueueFinanceLib.RateInfoStruct memory nextPositionRateInfo;
            QueueFinanceLib.RateInfoStruct memory previousPositionRateInfo;
        if(_position != 0){
            nextPositionRateInfo =  iDataContractQF.getLatestRateInfoByPosition(_pid, _levelID, _position + 1);
            previousPositionRateInfo =  iDataContractQF.getLatestRateInfoByPosition(_pid, _levelID, _position - 1);
        }

        //        assert if date is less than pool start time.
        require(
            _date >= iDataContractQF.getPoolStartTime(_pid),
            "Interest date is early"
        );
        // If position is zero just update
        // first record
        if ((rateInfoLength > 1) && (_position == 0)) {
            require(
                _date <= nextPositionRateInfo.timestamp,
                "The date not in asc order"
            );
        }
        // middle records
        if (
            (_position > 0) && (_position + 1 < rateInfoLength)
        ) {
            require(
                (_date >= previousPositionRateInfo.timestamp &&
                    _date <= nextPositionRateInfo.timestamp),
                "The date not in asc"
            );
        } else if (
            (_position + 1 == rateInfoLength) &&
            (_position > 0)
        ) {
            require(
                _date >= previousPositionRateInfo.timestamp,
                "The date should be in asc order"
            );
        }

        iDataContractQF.setRateInfoByPosition(_pid, _levelID, _position, QueueFinanceLib.RateInfoStruct({
            timestamp:_date,
            rate:_rate
        }));
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setPoolEndTime(_poolID, _pool_end_time);
    }

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external
    {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setPoolStartTime(_poolID, _pool_start_time);

    }

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external
    {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
            iDataContractQF.setEInvestValue(_poolID, _eInvestCoinValue);
    }

    // @notice imp. only use this function to replenish rewards
    function replenishReward(uint256 _poolID, uint256 _value) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.addReplenishReward(_poolID,_value);
        IERC20(iDataContractQF.getRewardToken(_poolID)).safeTransferFrom(
            msg.sender,
            address(iDataContractQF),
            _value
        );
    }

    // @notice can only transfer out the rewards balance and not user fund.
    function transferOutECoin(
        uint256 _poolID,
        address _to,
        uint256 _value
    ) external {
        // onlyTransferOutOperator
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));


        IERC20(iDataContractQF.getRewardToken(_poolID)).safeTransfer(_to, _value);
    }

    //modify treasury address
    function setTreasury(uint256 _pId, address _treasury) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        iDataContractQF.setTreasury(_pId, _treasury);
    }

    function setWithdrawTime(uint256 _timeSpan) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
    iDataContractQF.setWithdrawTime(_timeSpan);
    }

    function updateTaxRates(
        uint256 _poolID,
        uint256 _depositDev,
        uint256 _depositProtocal,
        uint256 _depositIntroducer,
        uint256 _depositNetwork,
        uint256 _depositRefferel,
        uint256 _withdrawDev,
        uint256 _withdrawProtocal,
        uint256 _withdrawIntroducer,
        uint256 _withdrawNetwork,
        uint256 _withdrawRefferel
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        uint256[] memory _taxRates = new uint256[](10);
        _taxRates[0] = _depositDev;
        _taxRates[1] = _depositProtocal;
        _taxRates[2] = _depositIntroducer;
        _taxRates[3] = _depositNetwork;
        _taxRates[4] = _depositRefferel;
        _taxRates[5] = _withdrawDev;
        _taxRates[6] = _withdrawProtocal;
        _taxRates[7] = _withdrawIntroducer;
        _taxRates[8] = _withdrawNetwork;
        _taxRates[9] = _withdrawRefferel;
        iDataContractQF.setTaxRates(_poolID, _taxRates);
    }

    function updateTaxAddress(
        uint256 _poolId,
        address _devTaxAddress,
        address _protocalTaxAddress,
        address _introducerTaxAddress,
        address _networkTaxAddress
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setTaxAddress(_poolId, _devTaxAddress, _protocalTaxAddress, _introducerTaxAddress, _networkTaxAddress);
    }

    function addPreApprovedUser(address[] memory userAddress) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

       iDataContractQF.addPreApprovedUser(userAddress);
    }



    function calculateRemainingGap(
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _currentThreshold,
        uint256 _total,
        uint256 _levelStakingLimit,
        uint256 iGap,
        uint256 _toAdjust
    ) public pure returns (uint256) {
        if (_currentThreshold == 0) {
            return iGap;
        }

        if (_thresholdConsumedTillLastLevel - _currentThreshold == 0) {
            if (_currentThreshold + iGap <= _total) {
                iGap = 0;
            } else {
                iGap = _currentThreshold + iGap - _total;
            }
        } else {
            iGap = _levelStakingLimit - _toAdjust;
        }
        return iGap;
    }

      function updateLevelForBlockRemoval(
        QueueFinanceLib.LevelInfo[] memory levelsInfo,
        uint256[] memory _ths,
        bool addFlag,
        uint256 _totalLevels
    ) public pure returns (QueueFinanceLib.LevelInfo[] memory) {
        // uint256 amountToMove;
        bool iStarted = false;
        uint256 iStart = 0;
        uint256 iSum = 0;

        for (uint256 i = 0; i < _ths.length; i++) {
            // exclude this condition if addFlag is 1
            if (
                _ths[i] > 0 &&
                iStarted == false &&
                ((levelsInfo[i].levelStaked >= _ths[i]) || addFlag)
            ) {
                iStarted = true;
                iStart = i;
                iSum = levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            } else if (levelsInfo[i].levelStaked >= _ths[i]) {
                iSum += levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            }
        }
        for (
            uint256 i = iStart;
            i < _totalLevels;
            i++ // iEnd  upto all levels
        ) {
            levelsInfo[i].levelStaked = QueueFinanceLib.min(
                iSum,
                levelsInfo[i].levelStakingLimit
            );
            iSum = iSum.sub(levelsInfo[i].levelStaked);
        }

        return levelsInfo;
    }


    function thresholdConsumedTillLastLevel(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 _sequence,
        uint256 _level
    ) public pure returns (uint256) {
        uint256 thresholdConsumedValue = 0;

        for (uint256 level = _level; level >= 0; level--) {
            if (_sequence == currentThresholds[level].sequence) {
                thresholdConsumedValue += currentThresholds[level].amount;
            } else {
                break;
            }
            if (level == 0) {
                break;
            }
        }

        return thresholdConsumedValue;
    }
    

    function thresholdMoveInSameBlock(
        uint256 _currentThreshold,
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _total,
        uint256 iGap,
        uint256 _levelStakingLimit
    ) public pure returns (uint256) {
        uint256 _toAdjust = 0;
        if (_currentThreshold != 0) {
            if (_total >= _thresholdConsumedTillLastLevel) {
                if (_total - _thresholdConsumedTillLastLevel >= iGap) {
                    _toAdjust = iGap + _currentThreshold;
                } else {
                    _toAdjust =
                        _currentThreshold +
                        _total -
                        _thresholdConsumedTillLastLevel;
                }
            } else {
                _toAdjust =
                    _currentThreshold +
                    _total -
                    _thresholdConsumedTillLastLevel;
            }
            _toAdjust = QueueFinanceLib.min(_toAdjust, _levelStakingLimit);
        }
        return _toAdjust;
    }


    function getThresholdInfo(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 depositStakeAmount,
        uint256 totalLevels,
        uint256 _sequenceID
    ) public pure returns (uint256[] memory) {
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
}



// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
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
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: DataContractQF.sol



pragma solidity ^0.8.0;






contract DataContractQF is AccessControl {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    // address public operator;
    // address public transferOutOperator;
    //poolID => seqID => list of levels
    mapping(uint256 => mapping(uint256 => mapping(uint8 => uint256)))
        public lastUpdatedLevelForDeposits;
    //pool-> seq -> DepositInfo
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.DepositInfo))
        public depositInfo;
    // wallet -> poolId
    mapping(address => mapping(uint256 => QueueFinanceLib.UserInfo))
        public userInfo;
    // poolID -> LevelID-> Rate
    QueueFinanceLib.RateInfoStruct[][][] public rateInfo;
    //Pool -> levels
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.LevelInfo))
        public levelsInfo;
    // // Info of each pool.
    QueueFinanceLib.PoolInfo[] public poolInfo;

    mapping(uint256 => bool) poolIsPrivate;

    mapping(address => bool) preApprovedUsers;

    mapping(uint256 => Counters.Counter) public currentSequenceIncrement;
    // // Info of each pool.
    mapping(uint256 => address) public treasury;
    // pool ->levels -> Threshold
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.Threshold))
        public currentThresholds;
    uint256 public withdrawTime = 86400; // 24 hours
    mapping(address => mapping(uint256 => QueueFinanceLib.RequestedClaimInfo[]))
        public requestedClaimInfo;
    Counters.Counter requestedClaimIdIncrementer;
    mapping(uint256 => uint256[]) public taxRates;

    mapping(uint256 => uint256) public poolBalance;

    // address[] public taxAddress;
    bool public initialized;
    mapping(uint256 => address[]) public taxAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ACCESS_ROLE = keccak256("ACCESS_ROLE");

    // Initialize
    function initialize(address _owner) public {
        require(!initialized, "Already Initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(ADMIN_ROLE, _owner);
        _setupRole(ACCESS_ROLE, _owner);
        initialized = true;
    }

    //=========================Roles=======================================
    function checkRole(address account, bytes32 role) public view {
        require(hasRole(role, account), "Role Does Not Exist");
    }

    function checkEitherACCESSorADMIN(address account) public view {
        require(
            (hasRole(ADMIN_ROLE, account) ||
                hasRole(ACCESS_ROLE, account) ||
                hasRole(DEFAULT_ADMIN_ROLE, account)),
            "Neither ADMIN nor ACCESS"
        );
    }

    function giveRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        grantRole(_role, wallet);
    }

    function revokeRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        revokeRole(_role, wallet);
    }

    function transferRole(
        address wallet,
        address oldWallet,
        uint256 _roleId
    ) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        grantRole(_role, wallet);
        revokeRole(_role, oldWallet);
    }

    function renounceOwnership() public {
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getPoolInfo(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.PoolInfo memory)
    {
        return poolInfo[_poolId];
    }

    function addPool(QueueFinanceLib.PoolInfo memory poolData) public {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo.push(poolData);
    }

    function getPoolInfoLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function setLastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint8 _levelID,
        uint256 _amount
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        lastUpdatedLevelForDeposits[_poolID][_seqID][_levelID] = _amount;
    }

    // function setPoolIsPrivate(uint256 _poolID, bool _isPrivate) public {
    //     checkRole(msg.sender, ADMIN_ROLE);
    //     poolIsPrivate[_poolID] = _isPrivate;
    // }

    function setLastUpdatedLevelsForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint256[] memory _lastUpdatedLevelAmounts
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint8 i = 0; i < poolInfo[_poolID].levels; i++) {
            lastUpdatedLevelForDeposits[_poolID][_seqID][
                i
            ] = _lastUpdatedLevelAmounts[i];
        }
    }

    function setLastUpdatedLevelsForSequences(uint256 _poolID, QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory _lastUpdatedLevels, QueueFinanceLib.LastUpdatedLevelsPendings[] memory _lastUpdatedLevelsPendings) external {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < _lastUpdatedLevels.length; i++) {
            setLastUpdatedLevelsForDeposits(_poolID, _lastUpdatedLevels[i].sequenceId, _lastUpdatedLevels[i].lastUpdatedLevelsForDeposits);
        }
        for (uint256 i = 0; i < _lastUpdatedLevelsPendings.length; i++) {
            depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].accuredCoin = depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].accuredCoin.add(_lastUpdatedLevelsPendings[i].accruedCoin);
            depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].lastUpdated = block.timestamp;
        }
    }

    function setDepositInfo(
        uint256 _poolID,
        uint256 _seqID,
        QueueFinanceLib.DepositInfo memory _depositInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        depositInfo[_poolID][_seqID] = _depositInfo;
    }

    function getUserInfo(address _sender, uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.UserInfo memory)
    {
        return userInfo[_sender][_poolId];
    }

    function setUserInfoForDeposit(
        address _sender,
        uint256 _poolID,
        uint256 _newSeqId,
        QueueFinanceLib.UserInfo memory _userInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        userInfo[_sender][_poolID] = _userInfo;
        userInfo[_sender][_poolID].depositSequences.push(_newSeqId);
    }

    function setRateInfoStruct(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_poolID][_levelID].push(_rateInfoStruct);
    }

    function pushWholeRateInfoStruct(
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkRole(msg.sender, ADMIN_ROLE);
        rateInfo.push().push().push(_rateInfoStruct);
    }

    function pushRateInfoStruct(
        uint256 _poolID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_poolID].push().push(_rateInfoStruct);
    }

    function incrementPoolInfoLevels(uint256 _poolId) external {
        checkEitherACCESSorADMIN(msg.sender);
        poolInfo[_poolId].levels++;
    }

    function getRateInfoByPoolID(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct[][] memory _rateInfo)
    {
        return rateInfo[_poolId];
    }

    function setLevelsInfo(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.LevelInfo memory _levelsInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        levelsInfo[_poolID][_levelID] = _levelsInfo;
    }

    function setLevelInfo(
        uint256 _pid,
        uint8 _levelId,
        QueueFinanceLib.LevelInfo memory _levelInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        levelsInfo[_pid][_levelId] = _levelInfo;
    }

    function setCurrentThresholdsForTxn(
        uint256 _poolId,
        QueueFinanceLib.Threshold[] memory _threshold
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            currentThresholds[_poolId][i] = _threshold[i];
        }
    }

    function getAllLevelInfo(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.LevelInfo[] memory)
    {
        QueueFinanceLib.LevelInfo[]
            memory levelInfoArr = new QueueFinanceLib.LevelInfo[](
                poolInfo[_poolId].levels
            );
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            levelInfoArr[i] = levelsInfo[_poolId][i];
        }
        return levelInfoArr;
    }

    function getAllThresholds(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.Threshold[] memory)
    {
        QueueFinanceLib.Threshold[]
            memory thresholdInfoArr = new QueueFinanceLib.Threshold[](
                poolInfo[_poolId].levels
            );
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            thresholdInfoArr[i] = currentThresholds[_poolId][i];
        }
        return thresholdInfoArr;
    }

    function setPoolInfo(
        uint256 _poolID,
        QueueFinanceLib.PoolInfo memory _poolInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        poolInfo[_poolID] = _poolInfo;
    }

    function doCurrentSequenceIncrement(uint256 _poolID)
        public
        returns (uint256)
    {
        checkEitherACCESSorADMIN(msg.sender);
        currentSequenceIncrement[_poolID].increment();
        return currentSequenceIncrement[_poolID].current();
    }

    function updatePoolBalance(
        uint256 _poolID,
        uint256 _amount,
        bool isIncrease
    ) public {
        checkRole(msg.sender, ACCESS_ROLE);
        if (isIncrease) {
            poolBalance[_poolID] = poolBalance[_poolID].add(_amount);
        } else {
            poolBalance[_poolID] = poolBalance[_poolID].sub(_amount);
        }
    }

    function setCurrentThresholds(
        uint256 _poolID,
        uint256 _levelID,
        QueueFinanceLib.Threshold memory _threshold
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        currentThresholds[_poolID][_levelID] = _threshold;
    }

    function setTaxAddress(
        uint256 _poolId,
        address _devTaxAddress,
        address _protocalTaxAddress,
        address _introducerAddress,
        address _networkAddress
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        address[] memory _taxAddress = new address[](4);
        _taxAddress[0] = _devTaxAddress;
        _taxAddress[1] = _protocalTaxAddress;
        _taxAddress[2] = _introducerAddress;
        _taxAddress[3] = _networkAddress;
        taxAddress[_poolId] = _taxAddress;
    }

    function getTaxAddress(uint256 _poolId) public view returns (address[] memory) {
        checkEitherACCESSorADMIN(msg.sender);
        return taxAddress[_poolId];
    }
    function getSequenceIdsFromCurrentThreshold(uint256 _poolId)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory sequenceIds = new uint256[](poolInfo[_poolId].levels);
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            sequenceIds[i] = currentThresholds[_poolId][i].sequence;
        }
        return sequenceIds;
    }

    function fetchDepositsBasedonSequences(
        uint256 _poolId,
        uint256[] memory _sequenceIds
    ) public view returns (QueueFinanceLib.DepositsBySequence[] memory) {
        QueueFinanceLib.DepositsBySequence[]
            memory depositsInfo = new QueueFinanceLib.DepositsBySequence[](
                _sequenceIds.length
            );

        for (uint256 i = 0; i < _sequenceIds.length; i++) {
            depositsInfo[i] = QueueFinanceLib.DepositsBySequence({
                sequenceId: _sequenceIds[i],
                depositInfo: depositInfo[_poolId][_sequenceIds[i]]
            });
        }

        return depositsInfo;
    }

    function getPoolStartTime(uint256 _poolId) external view returns (uint256) {
        return poolInfo[_poolId].poolStartTime;
    }

    function getLatestRateInfo(uint256 _pid, uint256 _levelID)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct memory)
    {
        return rateInfo[_pid][_levelID][rateInfo[_pid][_levelID].length - 1];
    }

    function getRateInfoLength(uint256 _pid, uint256 _levelID)
        external
        view
        returns (uint256)
    {
        return rateInfo[_pid][_levelID].length;
    }

    function getLatestRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position
    ) external view returns (QueueFinanceLib.RateInfoStruct memory) {
        return rateInfo[_pid][_levelID][_position];
    }

    function pushRateInfo(
        uint256 _pid,
        uint256 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_pid][_levelID].push(_rateInfo);
    }

    function setRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_pid][_levelID][_position].timestamp = _rateInfo.timestamp;
        rateInfo[_pid][_levelID][_position].rate = _rateInfo.rate;
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].poolEndTime = _pool_end_time;
    }

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external
    {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].poolStartTime = _pool_start_time;
    }

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external
    {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].eInvestCoinValue = _eInvestCoinValue;
    }

    function addReplenishReward(uint256 _poolID, uint256 _value) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].rewardsBalance += _value;
    }

    function getRewardToken(uint256 _poolId) external view returns (IERC20) {
        return poolInfo[_poolId].rewardToken;
    }

    // // @notice sets a pool's isStarted to true and increments total allocated points
    // function startPool(uint256 _pid) public {
    //     checkRole(msg.sender, ADMIN_ROLE);
    //     if (!poolInfo[_pid].isStarted) {
    //         poolInfo[_pid].isStarted = true;
    //     }
    // }

    function setTreasury(uint256 _pId, address _treasury) external {
        checkRole(msg.sender, ADMIN_ROLE);
        treasury[_pId] = _treasury;
    }

    function setWithdrawTime(uint256 _timeSpan) external {
        checkRole(msg.sender, ADMIN_ROLE);
        withdrawTime = _timeSpan;
    }

    function getWithdrawTime() external view returns (uint256) {
        return withdrawTime;
    }

    function setTaxRates(uint256 _poolID, uint256[] memory _taxRates) external {
        checkEitherACCESSorADMIN(msg.sender);
        taxRates[_poolID] = _taxRates;
    }

    function getTaxRates(uint256 _poolID)
        external
        view
        returns (uint256[] memory)
    {
        return taxRates[_poolID];
    }

    function addPreApprovedUser(address[] memory userAddress) external {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < userAddress.length; i++) {
            if (!preApprovedUsers[userAddress[i]]) {
                preApprovedUsers[userAddress[i]] = true;
            }
        }
    }

    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_pid].maximumStakingAllowed = _maximumStakingAllowed;
    }

    function returnDepositSeqList(uint256 _poodID, address _sender)
        external
        view
        returns (uint256[] memory)
    {
        return userInfo[_sender][_poodID].depositSequences;
    }

    function fetchLastUpdatatedLevelsBySequenceIds(
        uint256 _poolID,
        uint256[] memory sequenceIds
    )
        external
        view
        returns (QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory)
    {
        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory LULD = new QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[](
                sequenceIds.length
            );
        for (uint256 i = 0; i < sequenceIds.length; i++) {
            uint256[] memory lastUpdatedLevels = new uint256[](
                poolInfo[_poolID].levels
            );
            for (uint8 j = 0; j < poolInfo[_poolID].levels; j++) {
                lastUpdatedLevels[j] = lastUpdatedLevelForDeposits[_poolID][
                    sequenceIds[i]
                ][j];
            }
            LULD[i] = QueueFinanceLib.FetchLastUpdatedLevelsForDeposits({
                sequenceId: sequenceIds[i],
                lastUpdatedLevelsForDeposits: lastUpdatedLevels
            });
        }
        return LULD;
    }

    function pushRequestedClaimInfo(
        address _sender,
        uint256 _poolId,
        QueueFinanceLib.RequestedClaimInfo memory _requestedClaimInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        requestedClaimInfo[_sender][_poolId].push(_requestedClaimInfo);
        requestedClaimIdIncrementer.increment();
    }

    function getRequestedClaimInfoIncrementer()
        external
        view
        returns (uint256)
    {
        checkEitherACCESSorADMIN(msg.sender);
        return requestedClaimIdIncrementer.current();
    }

    function getPoolIsPrivateForUser(uint256 _pid, address _user) public view returns (bool, bool){
        checkEitherACCESSorADMIN(msg.sender);
        return (poolIsPrivate[_pid], preApprovedUsers[_user]);
    }

    function getDepositBySequenceId(uint256 _poolId, uint256 _seqId)
        external
        view
        returns (QueueFinanceLib.DepositInfo memory)
    {
        return depositInfo[_poolId][_seqId];
    }

    function removeSeqAndUpdateUserInfo(
        uint256 _poolId,
        uint256 _seqId,
        address _sender,
        uint256 _amount,
        uint256 _interest
    ) internal {
        (uint256 removeIndexForSequences, bool isThere) = QueueFinanceLib
            .getRemoveIndex(
                _seqId,
                userInfo[_sender][_poolId].depositSequences
            );
        if (isThere) {
            // swapping with last element and then pop
            userInfo[_sender][_poolId].depositSequences[
                removeIndexForSequences
            ] = userInfo[_sender][_poolId].depositSequences[
                userInfo[_sender][_poolId].depositSequences.length - 1
            ];
            userInfo[_sender][_poolId].depositSequences.pop();
        }

        userInfo[_sender][_poolId].initialStakedAmount = userInfo[_sender][
            _poolId
        ].initialStakedAmount.sub(_amount);
        userInfo[_sender][_poolId].totalAmount = userInfo[_sender][_poolId]
            .totalAmount
            .sub(_amount);
        userInfo[_sender][_poolId].totalAccrued = userInfo[_sender][_poolId]
            .totalAccrued
            .add(_interest);
        userInfo[_sender][_poolId].totalClaimedCoin = userInfo[_sender][_poolId]
            .totalAccrued;
        userInfo[_sender][_poolId].lastAccrued = block.timestamp;
    }

    function updateAddressOnUserInfo(
        uint256 _pid,
        address _sender,
        address _referral
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        
        if (userInfo[_sender][_pid].referral == address(0)) {
            if (_referral == address(0)) {
                _referral = taxAddress[_pid][3];
            }
            userInfo[_sender][_pid].referral = _referral;
        }
    }

    function getWithdrawRequestedClaimInfo(address _sender, uint256 _pid)
        external
        view
        returns (QueueFinanceLib.RequestedClaimInfo[] memory)
    {
        return requestedClaimInfo[_sender][_pid];
    }

    function fetchWithdrawLength(uint256 _pid, address user)
        external
        view
        returns (uint256)
    {
        return requestedClaimInfo[user][_pid].length;
    }

    function swapAndPopForWithdrawal(
        uint256 _pid,
        address user,
        uint256 clearIndex
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        //  swapping with last element and then pop
        requestedClaimInfo[user][_pid][clearIndex] = requestedClaimInfo[user][
            _pid
        ][requestedClaimInfo[user][_pid].length - 1];
        requestedClaimInfo[user][_pid].pop();
    }

    function doTransfer(
        uint256 amount,
        address to,
        IERC20 depositToken
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        IERC20(depositToken).safeTransfer(to, amount);
    }
    function addDepositDetailsToDataContract(
        QueueFinanceLib.AddDepositModule memory _addDepositData
    ) public {
        checkRole(msg.sender, ACCESS_ROLE);
        poolInfo[_addDepositData.addDepositData.poolId]
            .totalStaked = _addDepositData.addDepositData.poolTotalStaked;

        poolInfo[_addDepositData.addDepositData.poolId]
            .lastActiveSequence = _addDepositData
            .addDepositData
            .poolLastActiveSequence;
        poolInfo[_addDepositData.addDepositData.poolId]
            .currentSequence = _addDepositData.addDepositData.seqId;

        depositInfo[_addDepositData.addDepositData.poolId][
            _addDepositData.addDepositData1.updateDepositInfo.sequenceId
        ] = _addDepositData.addDepositData1.updateDepositInfo.depositInfo;
        
        depositInfo[_addDepositData.addDepositData.poolId][
            _addDepositData.addDepositData.prevSeqId
        ].nextSequenceID = _addDepositData.addDepositData.seqId;

        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].initialStakedAmount = userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].initialStakedAmount.add(
                _addDepositData
                    .addDepositData1
                    .updateDepositInfo
                    .depositInfo
                    .stakedAmount
            );
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].totalAmount = userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].totalAmount.add(
                _addDepositData
                    .addDepositData1
                    .updateDepositInfo
                    .depositInfo
                    .stakedAmount
            );
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].lastAccrued = _addDepositData.addDepositData.blockTime;
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].depositSequences.push(_addDepositData.addDepositData.seqId);
        
        for (
            uint8 i = 0;
            i < _addDepositData.addDepositData1.levelsAffected.length;
            i++
        ) {
            lastUpdatedLevelForDeposits[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData.seqId
            ][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.updatedLevelsForDeposit[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];

            currentThresholds[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.threshold[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
            levelsInfo[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.levelsInfo[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
            currentThresholds[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.threshold[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
        }
    }

    function updateWithDrawDetails(
        QueueFinanceLib.UpdateWithdrawDataInALoop memory _withdrawData
    ) external {
        checkRole(msg.sender, ACCESS_ROLE);
         QueueFinanceLib.DepositInfo memory _currentDeposit = depositInfo[
            _withdrawData.poolId
        ][_withdrawData.currSeqId];


         removeSeqAndUpdateUserInfo(
            _withdrawData.poolId,
            _withdrawData.currSeqId,
            _withdrawData.user,
            _currentDeposit.stakedAmount,
            _withdrawData.interest
        );

        depositInfo[_withdrawData.poolId][_withdrawData.curDepositPrevSeqId]
            .nextSequenceID = _withdrawData.depositPreviousNextSequenceID;

       
        if (_currentDeposit.nextSequenceID > _withdrawData.currSeqId) {
            depositInfo[_withdrawData.poolId][_withdrawData.curDepositNextSeqId]
                .previousSequenceID = _withdrawData
                .depositNextPreviousSequenceID;
        }

        _currentDeposit.accuredCoin += _withdrawData.interest;
        _currentDeposit.claimedCoin = _currentDeposit.accuredCoin;
        _currentDeposit.lastUpdated = block.timestamp;

        poolInfo[_withdrawData.poolId].totalStaked = poolInfo[
            _withdrawData.poolId
        ].totalStaked.sub(_currentDeposit.stakedAmount);

        if (
            _withdrawData.currSeqId ==
            poolInfo[_withdrawData.poolId].lastActiveSequence
        ) {
            poolInfo[_withdrawData.poolId].lastActiveSequence = _currentDeposit
                .previousSequenceID;
        }

        _currentDeposit.nextSequenceID = 0;
        _currentDeposit.previousSequenceID = 0;
        _currentDeposit.inactive = 1;

        depositInfo[_withdrawData.poolId][
            _withdrawData.currSeqId
        ] = _currentDeposit;

        for (uint256 i = 0; i < poolInfo[_withdrawData.poolId].levels; i++) {
            currentThresholds[_withdrawData.poolId][i] = _withdrawData.thresholds[i];
            levelsInfo[_withdrawData.poolId][i] = _withdrawData.levelsInfo[i];
        }

       
    }
}

pragma solidity ^0.8.0;


contract DepositContractQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    IDataContractQF public iDataContractQF;

    uint8[] levelsAffected;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    constructor(address _accessContract) {
        iDataContractQF = IDataContractQF(_accessContract);
    }

    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referral
    ) external {
         iDataContractQF.updateAddressOnUserInfo(
                _pid,
                msg.sender,
                _referral
            );

        (bool poolIsPrivate, bool isUserThere) = iDataContractQF.getPoolIsPrivateForUser(_pid, msg.sender);
        if (poolIsPrivate) {
             require(
                isUserThere,
                "User does not have pre-approval"
            );
            depositInternal(_pid, _amount, false, msg.sender);
        } else {
            depositInternal(_pid, _amount, false, msg.sender);
        }


           
    }

    function depositFromWithdraw(
        uint256 _pid,
        uint256 _amount,
        bool isInternal,
        address _sender
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ACCESS_ROLE"));
        depositInternal(_pid, _amount, isInternal, _sender);
    }

    function depositInternal(
        uint256 _pid,
        uint256 _amount,
        bool isInternal,
        address _sender
    ) internal {
        QueueFinanceLib.AllDepositData memory _allDepositData = getDepositData(_pid, _sender);

        require(
            block.timestamp >= _allDepositData.poolInfo.poolStartTime,
            "Pool has not started yet!"
        );

        require(
            block.timestamp < _allDepositData.poolInfo.poolEndTime,
            "Pool has ended already!"
        );

        require(
            _allDepositData.userInfo.totalAmount + _amount <=
                _allDepositData.poolInfo.maximumStakingAllowed,
            "Maximum staking limit reached"
        );


        // Financial transaction
        // 1. Transfer Deposit token to treasury from the user
        if (!isInternal) {
            IERC20(_allDepositData.poolInfo.depositToken).safeTransferFrom(
                _sender,
                address(iDataContractQF),
                _amount
            );
            _amount = getTaxedAmount(
                _pid,
                _allDepositData.poolInfo.depositToken,
                _amount,
                _allDepositData.userInfo.referral
            );

            iDataContractQF.doTransfer(
                _amount,
                iDataContractQF.treasury(_pid),
                _allDepositData.poolInfo.depositToken
            );
        }

        //1. Blindly add to depositInfo after creating sequence
        QueueFinanceLib.AddDepositInfo memory _updatedForLevelDeposits;
        (
            _allDepositData.poolInfo,
            _updatedForLevelDeposits
        ) = addDepositInfoAndUpdateChain(
            _pid,
            _allDepositData.poolInfo,
            _sender,
            _amount
        );

        //2. Calculate amountsplit
        uint256[] memory depositSplit = calculateAmountSplitAcrossLevels(
            _allDepositData.poolInfo,
            _allDepositData.levelInfo,
            _amount
        );


        for (uint8 i = 0; i < depositSplit.length; i++) {
            if (depositSplit[i] != 0) {
                levelsAffected.push(i);
            }
        }

        iDataContractQF.addDepositDetailsToDataContract(
            QueueFinanceLib.AddDepositModule({
                addDepositData: QueueFinanceLib.AddDepositData({
                    poolId: _pid,
                    seqId: _allDepositData.poolInfo.currentSequence,
                    sender: _sender,
                    prevSeqId: _updatedForLevelDeposits.depositInfo.previousSequenceID,
                    poolTotalStaked: _allDepositData.poolInfo.totalStaked,
                    poolLastActiveSequence: _allDepositData.poolInfo.lastActiveSequence,
                    blockTime: block.timestamp
                }),
                addDepositData1: QueueFinanceLib.AddDepositData1({
                    levelsAffected: levelsAffected,
                    updateDepositInfo: _updatedForLevelDeposits,
                    updatedLevelsForDeposit: updateLevelsForDeposit(
                        _allDepositData.poolInfo,
                        depositSplit
                    ),
                    levelsInfo: updateLevelInfo(
                        _allDepositData.levelInfo,
                        depositSplit
                    ),
                    threshold: updateThresholdsForDeposit(
                        _allDepositData.poolInfo,
                        _allDepositData.thresholdInfo,
                        depositSplit
                    )
                })
            })
        );

        uint8[] memory clear;
        levelsAffected = clear;

        emit Deposit(msg.sender, _pid, _pid);
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

        for (uint256 i = 0; i < 5; i++) {
            uint256 tax = 0;
            if (_taxRates[i] == 0) {
                continue;
            }

            tax = ((SafeMath.mul(_amount, _taxRates[i])).div(100)).div(
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

    function addDepositInfoAndUpdateChain(
        uint256 _pid,
        QueueFinanceLib.PoolInfo memory _pool,
        address _sender,
        uint256 _amount
    )
        internal
        returns (
            QueueFinanceLib.PoolInfo memory,
            QueueFinanceLib.AddDepositInfo memory updatedDepositList
        )
    {
        // new entry for current deposit
        uint256 _currentSequenceIncrement = iDataContractQF
            .doCurrentSequenceIncrement(_pid);
        _pool.currentSequence = _currentSequenceIncrement;
        updatedDepositList.sequenceId = _pool.currentSequence;
        updatedDepositList.depositInfo = QueueFinanceLib.DepositInfo({
            wallet: _sender,
            depositDateTime: block.timestamp, // UTC
            initialStakedAmount: _amount,
            iCoinValue: _pool.eInvestCoinValue,
            stakedAmount: _amount,
            lastUpdated: block.timestamp,
            nextSequenceID: 0,
            previousSequenceID: _pool.lastActiveSequence,
            accuredCoin: 0,
            claimedCoin: 0,
            inactive: 0
        });

        // update the lastActiveSequence and basically pool data
        
        _pool.lastActiveSequence = _pool.currentSequence;
        _pool.totalStaked = _pool.totalStaked.add(_amount);

        return (_pool, updatedDepositList);
    }

    function updateThresholdsForDeposit(
        QueueFinanceLib.PoolInfo memory _poolInfoByPoolID,
        QueueFinanceLib.Threshold[] memory _currentThreshold,
        uint256[] memory depositSplit
    ) internal pure returns (QueueFinanceLib.Threshold[] memory) {
        //     There will be n-1 currentThresholds
        //     elements are added already; n - no of levels
        //     process seperately for n = 1; 0 -> poolInfo.lastActiveSequence with 100% amount
        if (_poolInfoByPoolID.levels == 1) {
            _currentThreshold[0] = QueueFinanceLib.Threshold({
                sequence: _poolInfoByPoolID.lastActiveSequence,
                amount: depositSplit[0]
            });
        }

        //In a loop i from 0 to n-2
        for (uint256 i = 0; i <= depositSplit.length - 1; i++) {
            //        Case 1: 100% amount is in ith level  => move threshold to current block
            if (depositSplit[i] != 0) {
                _currentThreshold[i] = QueueFinanceLib.Threshold({
                    sequence: _poolInfoByPoolID.lastActiveSequence,
                    amount: depositSplit[i]
                });
            }
        }

        return _currentThreshold;
    }

    function calculateAmountSplitAcrossLevels(
        QueueFinanceLib.PoolInfo memory _pool,
        QueueFinanceLib.LevelInfo[] memory _levelsInfo,
        uint256 _amount
    ) internal pure returns (uint256[] memory) {
        uint256[] memory _levels = new uint256[](_pool.levels);
        uint256 next_level_transaction_amount = _amount;
        uint256 current_level_availability;

        for (uint256 i = 0; i < _pool.levels; i++) {
            current_level_availability = SafeMath.sub(
                _levelsInfo[i].levelStakingLimit,
                _levelsInfo[i].levelStaked
            );
            if (next_level_transaction_amount <= current_level_availability) {
                // push only if greater than zero
                if (next_level_transaction_amount > 0) {
                    _levels[i] = next_level_transaction_amount;
                }
                break;
            }
            if (i == _pool.levels - 1) {
                require(
                    next_level_transaction_amount <= current_level_availability,
                    "Could not deposit complete amount"
                );
            }
            // push only if greater than zero
            if (current_level_availability > 0) {
                _levels[i] = current_level_availability;
            }
            next_level_transaction_amount = SafeMath.sub(
                next_level_transaction_amount,
                current_level_availability
            );
        }

        return _levels;
    }

    function updateLevelsForDeposit(
        QueueFinanceLib.PoolInfo memory _pool,
        uint256[] memory _depositSplit
    ) internal pure returns (uint256[] memory) {
        uint256[] memory _lastUpdatedLevelsForDeposit = new uint256[](
            _pool.levels
        );
        for (uint8 i = 0; i < _depositSplit.length; i++) {
            _lastUpdatedLevelsForDeposit[i] = _depositSplit[i];
        }
        return _lastUpdatedLevelsForDeposit;
    }

    function updateLevelInfo(
        QueueFinanceLib.LevelInfo[] memory _levelsInfo,
        uint256[] memory depositSplit
    ) internal pure returns (QueueFinanceLib.LevelInfo[] memory) {
        for (uint256 i = 0; i < depositSplit.length; i++) {
            _levelsInfo[i].levelStaked = _levelsInfo[i].levelStaked.add(
                depositSplit[i]
            );
        }
        return _levelsInfo;
    }

    function getDepositData(uint256 _poolId, address _sender)
        internal
        view
        returns (QueueFinanceLib.AllDepositData memory)
    {
        QueueFinanceLib.PoolInfo memory _pool = iDataContractQF.getPoolInfo(
            _poolId
        );

        QueueFinanceLib.AddDepositInfo
            memory addDepositInfoData = QueueFinanceLib.AddDepositInfo({
                sequenceId: _pool.lastActiveSequence,
                depositInfo: iDataContractQF.getDepositBySequenceId(_poolId, _pool.lastActiveSequence)
            });

        return (
            QueueFinanceLib.AllDepositData({
                poolInfo: _pool,
                sequenceId: 0,
                depositInfo: addDepositInfoData,
                levelInfo: iDataContractQF.getAllLevelInfo(_poolId),
                userInfo: iDataContractQF.getUserInfo(_sender, _poolId),
                thresholdInfo: iDataContractQF.getAllThresholds(_poolId)
            })
        );
    }
}

pragma solidity ^0.8.0;

contract DepositMigrationQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    IDataContractQF public iDataContractQF;

    uint8[] levelsAffected;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(address _dataContract) {
        iDataContractQF = IDataContractQF(_dataContract);
    }

    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }

    function migrateDeposit(
        uint256 _pid,
        uint256 _amount,
        address _sender,
        uint256 _blockTime
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        QueueFinanceLib.AllDepositData memory _allDepositData = getDepositData(
            _pid,
            _sender
        );

        //1. Blindly add to depositInfo after creating sequence
        QueueFinanceLib.AddDepositInfo memory _updatedForLevelDeposits;
        (
            _allDepositData.poolInfo,
            _updatedForLevelDeposits
        ) = addDepositInfoAndUpdateChain(
            _pid,
            _allDepositData.poolInfo,
            // _allDepositData.depositInfo,
            _sender,
            _amount,
            _blockTime
        );
        //2. Calculate amountsplit
        uint256[] memory depositSplit = calculateAmountSplitAcrossLevels(
            _allDepositData.poolInfo,
            _allDepositData.levelInfo,
            _amount
        );
        for (uint8 i = 0; i < depositSplit.length; i++) {
            if (depositSplit[i] != 0) {
                levelsAffected.push(i);
            }
        }

       iDataContractQF.addDepositDetailsToDataContract(
            QueueFinanceLib.AddDepositModule({
                addDepositData: QueueFinanceLib.AddDepositData({
                    poolId: _pid,
                    seqId: _allDepositData.poolInfo.currentSequence,
                    sender: _sender,
                    prevSeqId: _updatedForLevelDeposits.depositInfo.previousSequenceID,
                    poolTotalStaked: _allDepositData.poolInfo.totalStaked,
                    poolLastActiveSequence: _allDepositData.poolInfo.lastActiveSequence,
                    blockTime: _blockTime
                }),
                addDepositData1: QueueFinanceLib.AddDepositData1({
                    levelsAffected: levelsAffected,
                    updateDepositInfo: _updatedForLevelDeposits,
                    updatedLevelsForDeposit: updateLevelsForDeposit(
                        _allDepositData.poolInfo,
                        depositSplit
                    ),
                    levelsInfo: updateLevelInfo(
                        _allDepositData.levelInfo,
                        depositSplit
                    ),
                    threshold: updateThresholdsForDeposit(
                        _allDepositData.poolInfo,
                        _allDepositData.thresholdInfo,
                        depositSplit
                    )
                })
            })
        );

        uint8[] memory clear;
        levelsAffected = clear;
    }

    function addDepositInfoAndUpdateChain(
        uint256 _pid,
        QueueFinanceLib.PoolInfo memory _pool,
        address _sender,
        uint256 _amount,
        uint256 _blockTime
    )
        internal
        returns (
            QueueFinanceLib.PoolInfo memory,
            QueueFinanceLib.AddDepositInfo memory updatedDepositList
        )
    {
        // new entry for current deposit
        uint256 _currentSequenceIncrement = iDataContractQF
            .doCurrentSequenceIncrement(_pid);
        _pool.currentSequence = _currentSequenceIncrement;
        updatedDepositList.sequenceId = _pool.currentSequence;
        updatedDepositList.depositInfo = QueueFinanceLib.DepositInfo({
            wallet: _sender,
            depositDateTime: _blockTime, // UTC
            initialStakedAmount: _amount,
            iCoinValue: _pool.eInvestCoinValue,
            stakedAmount: _amount,
            lastUpdated: _blockTime,
            nextSequenceID: 0,
            previousSequenceID: _pool.lastActiveSequence,
            accuredCoin: 0,
            claimedCoin: 0,
            inactive: 0
        });

        // // update the linkedList to include the current chain
        // update the lastActiveSequence and basically pool data
        _pool.lastActiveSequence = _pool.currentSequence;
        _pool.totalStaked = _pool.totalStaked.add(_amount);

        return (_pool, updatedDepositList);
    }
    function updateThresholdsForDeposit(
        QueueFinanceLib.PoolInfo memory _poolInfoByPoolID,
        QueueFinanceLib.Threshold[] memory _currentThreshold,
        uint256[] memory depositSplit
    ) internal pure returns (QueueFinanceLib.Threshold[] memory) {
        //     There will be n-1 currentThresholds
        //     elements are added already; n - no of levels
        //     process seperately for n = 1; 0 -> poolInfo.lastActiveSequence with 100% amount
        if (_poolInfoByPoolID.levels == 1) {
            _currentThreshold[0] = QueueFinanceLib.Threshold({
                sequence: _poolInfoByPoolID.lastActiveSequence,
                amount: depositSplit[0]
            });
        }

        //In a loop i from 0 to n-2
        for (uint256 i = 0; i <= depositSplit.length - 1; i++) {
            //        Case 1: 100% amount is in ith level  => move threshold to current block
            if (depositSplit[i] != 0) {
                _currentThreshold[i] = QueueFinanceLib.Threshold({
                    sequence: _poolInfoByPoolID.lastActiveSequence,
                    amount: depositSplit[i]
                });
            }
        }

        return _currentThreshold;
    }

    function calculateAmountSplitAcrossLevels(
        QueueFinanceLib.PoolInfo memory _pool,
        QueueFinanceLib.LevelInfo[] memory _levelsInfo,
        uint256 _amount
    ) internal pure returns (uint256[] memory) {
        uint256[] memory _levels = new uint256[](_pool.levels);
        uint256 next_level_transaction_amount = _amount;
        uint256 current_level_availability;

        for (uint256 i = 0; i < _pool.levels; i++) {
            current_level_availability = SafeMath.sub(
                _levelsInfo[i].levelStakingLimit,
                _levelsInfo[i].levelStaked
            );
            if (next_level_transaction_amount <= current_level_availability) {
                // push only if greater than zero
                if (next_level_transaction_amount > 0) {
                    _levels[i] = next_level_transaction_amount;
                }
                break;
            }
            if (i == _pool.levels - 1) {
                require(
                    next_level_transaction_amount <= current_level_availability,
                    "Could not deposit complete amount"
                );
            }
            // push only if greater than zero
            if (current_level_availability > 0) {
                _levels[i] = current_level_availability;
            }
            next_level_transaction_amount = SafeMath.sub(
                next_level_transaction_amount,
                current_level_availability
            );
        }

        return _levels;
    }

    function updateLevelsForDeposit(
        QueueFinanceLib.PoolInfo memory _pool,
        uint256[] memory _depositSplit
    ) internal pure returns (uint256[] memory) {
        uint256[] memory _lastUpdatedLevelsForDeposit = new uint256[](
            _pool.levels
        );
        for (uint8 i = 0; i < _depositSplit.length; i++) {
            _lastUpdatedLevelsForDeposit[i] = _depositSplit[i];
        }
        return _lastUpdatedLevelsForDeposit;
    }

    function updateLevelInfo(
        QueueFinanceLib.LevelInfo[] memory _levelsInfo,
        uint256[] memory depositSplit
    ) internal pure returns (QueueFinanceLib.LevelInfo[] memory) {
        for (uint256 i = 0; i < depositSplit.length; i++) {
            _levelsInfo[i].levelStaked = _levelsInfo[i].levelStaked.add(
                depositSplit[i]
            );
        }
        return _levelsInfo;
    }

    function getDepositData(uint256 _poolId, address _sender)
        internal
        view
        returns (QueueFinanceLib.AllDepositData memory)
    {
        QueueFinanceLib.PoolInfo memory _pool = iDataContractQF.getPoolInfo(
            _poolId
        );

        QueueFinanceLib.AddDepositInfo
            memory addDepositInfoData = QueueFinanceLib.AddDepositInfo({
                sequenceId: _pool.lastActiveSequence,
                depositInfo: iDataContractQF.getDepositBySequenceId(
                    _poolId,
                    _pool.lastActiveSequence
                )
            });

        return (
            QueueFinanceLib.AllDepositData({
                poolInfo: _pool,
                sequenceId: 0,
                depositInfo: addDepositInfoData,
                levelInfo: iDataContractQF.getAllLevelInfo(_poolId),
                userInfo: iDataContractQF.getUserInfo(_sender, _poolId),
                thresholdInfo: iDataContractQF.getAllThresholds(_poolId)
            })
        );
    }
}
pragma solidity ^0.8.0;
contract RequestedWithdrawQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDataContractQF public iDataContractQF;

    uint256 public test;

    event RewardPaid(address indexed user, uint256 amount);
    constructor(address _accessContract) {
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
    ) public pure returns (uint256) {
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
    ) public pure returns (uint256[] memory) {
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
pragma solidity ^0.8.0;
contract WithdrawContractQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    IDataContractQF public iDataContractQF;
    IDepositContractQF public iDepositContractQF;

    uint256[] _depositedSequenceIds;
    struct MoveThesholdParams{
        QueueFinanceLib.Threshold[] currentThresholds;
        uint256 _seqId;
        uint256 level;
        uint256 iGap;
        uint256 totalLevels;
        uint256 _pid;
    }
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    constructor(address _accessContract, address _depositContract) {
        iDataContractQF = IDataContractQF(_accessContract);
        iDepositContractQF = IDepositContractQF(_depositContract);
    }
    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }
    function setDepositContractAddress(address _depositContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDepositContractQF = IDepositContractQF(_depositContract);
    }
    function withdraw(uint256 _pid, uint256 _amount) external {
        QueueFinanceLib.DepositsBySequence[]
            memory _depositsInfo = iDataContractQF.fetchDepositsBasedonSequences(
                    _pid,
                    iDataContractQF.returnDepositSeqList(_pid, msg.sender)
                );
        uint256 remainingAmount = _amount;
        uint256 _claimAmount = 0;
        uint256 _exactAmount = 0;
        uint256 _pending = 0; 

        for (uint256 i = (_depositsInfo.length - 1); i >= 0; i--) {
            QueueFinanceLib.DepositInfo memory _deposit = _depositsInfo[i]
                .depositInfo;
            uint256 processAmount = 0;

            if (remainingAmount > _deposit.stakedAmount) {
                processAmount = _deposit.stakedAmount;
                remainingAmount = remainingAmount.sub(processAmount);
            } else {
                processAmount = remainingAmount;
                remainingAmount = 0;
            }

            (
                uint256 pendingForSequence,
                uint256 exactAmountForSequence,
                uint256 claimAmountForSequence
            ) = withdrawBySequence(
                    _pid,
                    _depositsInfo[i].sequenceId,
                    processAmount,
                    true
                );

            _depositedSequenceIds.push(_depositsInfo[i].sequenceId);

            _pending = _pending.add(pendingForSequence);
            _exactAmount = _exactAmount.add(exactAmountForSequence);
            _claimAmount = _claimAmount.add(claimAmountForSequence);

            if (remainingAmount == 0 || i == 0) {
                break;
            }
        }

        uint256 withdrawTime = iDataContractQF.getWithdrawTime();
        uint256 requestedClaimInfoIncrementer = iDataContractQF
            .getRequestedClaimInfoIncrementer();

        iDataContractQF.pushRequestedClaimInfo(
            msg.sender,
            _pid,
            QueueFinanceLib.RequestedClaimInfo({
                claimId: requestedClaimInfoIncrementer,
                claimTime: block.timestamp + withdrawTime,
                depositAmount: _exactAmount,
                claimAmount: _claimAmount,
                claimInterest: _pending,
                sequenceIds: _depositedSequenceIds
            })
        );


        uint256[] memory clear ;
        _depositedSequenceIds = clear;

        emit Withdraw(msg.sender, _pid, _claimAmount.add(_pending));
    }

    function withdrawBySequencePublic(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _amount
    ) public {
        withdrawBySequence(_pid, _sequenceID, _amount, false);
    }


    function withdrawBySequence(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _amount,
        bool isInternal
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        QueueFinanceLib.DepositInfo memory _deposit = iDataContractQF.getDepositBySequenceId(_pid, _sequenceID);
        QueueFinanceLib.FetchWithdrawData
            memory fetchWithdrawData = getWithdrawData(
                _pid,
                msg.sender
            );

        
        uint256[]
            memory _lastUpdatedLevelsForDepositBasedOnSequenceId = QueueFinanceLib
                .pickLastUpdatedLevelsBySequenceId(
                    fetchWithdrawData.lastUpdatedLevelsForDeposit,
                    _sequenceID
                );

        require(_deposit.stakedAmount >= _amount, "Withdrawal: Invalid");
        require(_deposit.inactive == 0, "Deposit has been withdrawn already");

        //        set data:
        //        1. calculate interest
        uint256 _pending = getGeneratedRewardForSequence(
            fetchWithdrawData.poolInfo,
            _deposit,
            // _deposit.lastUpdated,
            block.timestamp,
            _lastUpdatedLevelsForDepositBasedOnSequenceId,
            fetchWithdrawData.rateInfo
        );

        _pending = _pending.add(_deposit.accuredCoin);
        // 1b  Get current threshold info
        // QueueFinanceLib.DepositsBySequence[]
        //     memory thresholdDeposits = iDataContractQF
        //         .getDepositBasedOnThresholdId(_pid);
        uint256[] memory sequenceLevels = getThresholdInfo(
            fetchWithdrawData.threshold,
            _deposit.initialStakedAmount,
            fetchWithdrawData.poolInfo.levels,
            _sequenceID
        );
        //2. remove the block
        QueueFinanceLib.UpdateWithdrawDataInALoop memory updatedDepositData = removeDepositBlockAndUpdatePool(
            _pid,
            _sequenceID,
            _pending,
            _deposit,
            fetchWithdrawData.poolInfo.levels,
            fetchWithdrawData.threshold,
            fetchWithdrawData.levelInfo
        );

        // 2b. Update levelinfo

        updatedDepositData.levelsInfo = updateLevelForBlockRemoval(
            updatedDepositData.levelsInfo,
            sequenceLevels,
            false,
            fetchWithdrawData.poolInfo.levels
        );
        
        iDataContractQF.updateWithDrawDetails(updatedDepositData);

        if (_amount > 0) {
            updatedDepositData.thresholds = adjustThreshold(
                _pid,
                _sequenceID,
                sequenceLevels,
                fetchWithdrawData.poolInfo.levels,
                updatedDepositData.thresholds,
                updatedDepositData.levelsInfo
            );
            iDataContractQF.setCurrentThresholdsForTxn(_pid, updatedDepositData.thresholds);
        }


        if (_deposit.stakedAmount - _amount > 0) {
            uint256 depositAmount = _deposit.stakedAmount.sub(_amount);
            iDepositContractQF.depositFromWithdraw(
                _pid,
                (
                    (depositAmount).mul(
                        fetchWithdrawData.poolInfo.eInvestCoinValue
                    )
                ).div(_deposit.iCoinValue),
                true,
                msg.sender
            );
        }


        uint256 investCoinValueAmount = (_amount.mul(
            fetchWithdrawData.poolInfo.eInvestCoinValue
        ));

        if (!isInternal) {
            _depositedSequenceIds.push(_sequenceID);
            putRequestedWithdrawData(
                _pid,
                investCoinValueAmount.div(_deposit.iCoinValue),
                _amount,
                _pending
            );
            uint256[] memory clear ;
            _depositedSequenceIds = clear;
        }

        iDataContractQF.updatePoolBalance(_pid, (investCoinValueAmount.div(_deposit.iCoinValue)).add(_pending), true);

        // emit Withdraw(_sender, _pid, _amount);
        if (isInternal) {
            return (
                _pending,
                _amount,
                investCoinValueAmount.div(_deposit.iCoinValue)
            );
        } else {
            return (0, 0, 0);
        }
    }

    function putRequestedWithdrawData(
        uint256 _pid,
        uint256 _claimAmount,
        uint256 _amount,
        uint256 _pending
    ) internal {
        // Making withdraw request entry
        uint256 withdrawTime = iDataContractQF.getWithdrawTime();
        uint256 requestedClaimIdIncrementer = iDataContractQF
            .getRequestedClaimInfoIncrementer();
        iDataContractQF.pushRequestedClaimInfo(
            msg.sender,
            _pid,
            QueueFinanceLib.RequestedClaimInfo({
                claimId: requestedClaimIdIncrementer,
                claimTime: block.timestamp + withdrawTime,
                claimAmount: _claimAmount,
                depositAmount: _amount,
                claimInterest: _pending,
                sequenceIds: _depositedSequenceIds
            })
        );
    }

    // Return accumulate rewards over the given _from to _to block.
    function getGeneratedRewardForSequence(
        QueueFinanceLib.PoolInfo memory pool,
        QueueFinanceLib.DepositInfo memory _deposit,
        uint256 _toTime,
        uint256[] memory _lastUpdatedLevelsForDepositBasedOnSequenceId,
        QueueFinanceLib.RateInfoStruct[][] memory _rateInfo
    ) public pure returns (uint256) {
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

    function removeDepositBlockAndUpdatePool(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _interest,
        QueueFinanceLib.DepositInfo memory _deposit,
        uint256 levels,
        QueueFinanceLib.Threshold[] memory currentThresholds,
        QueueFinanceLib.LevelInfo[] memory levelsInfo
    ) internal view returns (QueueFinanceLib.UpdateWithdrawDataInALoop memory){
        uint256 _depositPreviousNextSequenceID = _deposit.nextSequenceID;
        uint256 _depositNextPreviousSequenceID = _deposit.previousSequenceID;

        for (uint256 i = 0; i < levels; i++) {
            if (currentThresholds[i].sequence == _sequenceID) {
                if (_deposit.previousSequenceID != 0) {
                    currentThresholds[i].amount = getThresholdInfo(
                            currentThresholds,
                            (iDataContractQF.getDepositBySequenceId(_pid, _deposit.previousSequenceID)).initialStakedAmount,
                            levels,
                            _deposit.previousSequenceID
                        )[i];
                    currentThresholds[i].sequence = _deposit.previousSequenceID;
                } else if (_deposit.previousSequenceID == 0) {
                    currentThresholds[i].amount = 0;
                    currentThresholds[i].sequence = _deposit.previousSequenceID;
                }
            }
        }
        return  QueueFinanceLib.UpdateWithdrawDataInALoop({
            poolId:_pid,
            currSeqId: _sequenceID,
            depositPreviousNextSequenceID: _depositPreviousNextSequenceID,
            depositNextPreviousSequenceID: _depositNextPreviousSequenceID,
            curDepositPrevSeqId:_deposit.previousSequenceID,
            curDepositNextSeqId:_deposit.nextSequenceID,
            interest: _interest,
            thresholds: currentThresholds,
            levelsInfo: levelsInfo,
            user: msg.sender
        });
    }
    function adjustThreshold(
        uint256 _pid,
        uint256 _seqId,
        uint256[] memory _sequenceLevels,
        uint256 _poolLevels,
        QueueFinanceLib.Threshold[] memory currentThreshold,
        QueueFinanceLib.LevelInfo[] memory levelsInfo
    ) internal view returns (QueueFinanceLib.Threshold[] memory) {
        uint256 iGap = 0;
        for (uint256 level = 0; level < (_poolLevels); level++) {
            if (levelsInfo[level].levelStaked == 0) {
                currentThreshold[level].amount = 0;
                currentThreshold[level].sequence = 0;
                continue;
            }
            iGap = _sequenceLevels[level];
            // if there no gap, move on
            if (iGap == 0) {
                continue;
            }
            //casecade the gap to the next level by default
            if (level < (_poolLevels) - 1) {
                _sequenceLevels[level + 1] += _sequenceLevels[level];
            }
            uint256 _total = iDataContractQF.getDepositBySequenceId(_pid, currentThreshold[level].sequence).initialStakedAmount;
       


            uint256 _thresholdConsumedTillLastLevel = thresholdConsumedTillLastLevel(
                    currentThreshold,
                    currentThreshold[level].sequence,
                    level
                );


            uint256 _toAdjust;
            //if the element is removed now, move on to the net block, else may need to adjust the current block
            uint256 _levelStakingLimit = levelsInfo[level].levelStakingLimit;
            if (currentThreshold[level].amount != 0) {

                _toAdjust = thresholdMoveInSameBlock(
                    currentThreshold[level].amount,
                    _thresholdConsumedTillLastLevel,
                    _total,
                    iGap,
                    _levelStakingLimit
                );

                //calculate iGap
                iGap = calculateRemainingGap(
                    _thresholdConsumedTillLastLevel,
                    currentThreshold[level].amount,
                    _total,
                    _levelStakingLimit,
                    iGap,
                    _toAdjust
                );


                currentThreshold[level].amount = _toAdjust;

                if (_toAdjust == levelsInfo[level].levelStakingLimit) {
                    continue;
                }
            }
            currentThreshold = moveThresholdInALoop(
                MoveThesholdParams({
                     currentThresholds: currentThreshold,
                        _seqId: _seqId,
                        level: level,
                        iGap: iGap,
                        totalLevels: _poolLevels,
                        _pid: _pid
                })
            );
        }

        return currentThreshold;
    }

    function updateLevelForBlockRemoval(
        QueueFinanceLib.LevelInfo[] memory levelsInfo,
        uint256[] memory _ths,
        bool addFlag,
        uint256 _totalLevels
    ) public pure returns (QueueFinanceLib.LevelInfo[] memory) {
        bool iStarted = false;
        uint256 iStart = 0;
        uint256 iSum = 0;

        for (uint256 i = 0; i < _ths.length; i++) {
            // exclude this condition if addFlag is 1
            if (
                _ths[i] > 0 &&
                iStarted == false &&
                ((levelsInfo[i].levelStaked >= _ths[i]) || addFlag)
            ) {
                iStarted = true;
                iStart = i;
                iSum = levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            } else if (levelsInfo[i].levelStaked >= _ths[i]) {
                iSum += levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            }
        }
        for (
            uint256 i = iStart;
            i < _totalLevels;
            i++ // iEnd  upto all levels
        ) {
            levelsInfo[i].levelStaked = QueueFinanceLib.min(
                iSum,
                levelsInfo[i].levelStakingLimit
            );
            iSum = iSum.sub(levelsInfo[i].levelStaked);
        }

        return levelsInfo;
    }

    function getThresholdInfo(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256  depositStakeAmount,
        uint256 totalLevels,
        uint256 _sequenceID
    ) public pure returns (uint256[] memory) {
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

    function moveThresholdInALoop(
        MoveThesholdParams memory moveThesholdParams
    ) public view returns (QueueFinanceLib.Threshold[] memory) {

        QueueFinanceLib.DepositInfo memory currentSeqDeposit = iDataContractQF.getDepositBySequenceId(moveThesholdParams._pid, moveThesholdParams.currentThresholds[moveThesholdParams.level].sequence);
        
        uint256 nextSeq = currentSeqDeposit.nextSequenceID;
        while ((moveThesholdParams.iGap > 0) && (nextSeq > 0)) {
            QueueFinanceLib.DepositInfo memory nextSeqDeposit = iDataContractQF.getDepositBySequenceId(moveThesholdParams._pid, nextSeq);
            if (nextSeqDeposit.initialStakedAmount < moveThesholdParams.iGap) {
                moveThesholdParams.iGap -= nextSeqDeposit.initialStakedAmount;
                uint256 nextSeq1 = nextSeqDeposit.nextSequenceID;
                if (nextSeq1 == 0) {
                    moveThesholdParams.currentThresholds[moveThesholdParams.level].sequence = nextSeq;
                    moveThesholdParams.currentThresholds[moveThesholdParams.level].amount = getThresholdInfo(
                        moveThesholdParams.currentThresholds,
                        nextSeqDeposit.initialStakedAmount,
                        moveThesholdParams.totalLevels,
                        nextSeq
                    )[moveThesholdParams.level];
                    break;
                }
                nextSeq = nextSeq1;
                continue;
            } else if (nextSeqDeposit.initialStakedAmount == moveThesholdParams.iGap) {
                moveThesholdParams.currentThresholds[moveThesholdParams.level].sequence = nextSeq;
                moveThesholdParams.currentThresholds[moveThesholdParams.level].amount = currentSeqDeposit
                    .initialStakedAmount;
                moveThesholdParams.iGap = 0;
                break;
            } else if (nextSeqDeposit.initialStakedAmount > moveThesholdParams.iGap) {
                moveThesholdParams.currentThresholds[moveThesholdParams.level].sequence = nextSeq;
                moveThesholdParams.currentThresholds[moveThesholdParams.level].amount = moveThesholdParams.iGap;
                moveThesholdParams.iGap = 0;
                break;
            }
        }
        return moveThesholdParams.currentThresholds;
    }

     function thresholdMoveInSameBlock(
        uint256 _currentThreshold,
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _total,
        uint256 iGap,
        uint256 _levelStakingLimit
    ) public pure returns (uint256) {
        uint256 _toAdjust = 0;
        if (_currentThreshold != 0) {
            if (_total >= _thresholdConsumedTillLastLevel) {
                if (_total - _thresholdConsumedTillLastLevel >= iGap) {
                    _toAdjust = iGap + _currentThreshold;
                } else {
                    _toAdjust =
                        _currentThreshold +
                        _total -
                        _thresholdConsumedTillLastLevel;
                }
            } else {
                _toAdjust =
                    _currentThreshold +
                    _total -
                    _thresholdConsumedTillLastLevel;
            }
            _toAdjust = QueueFinanceLib.min(_toAdjust, _levelStakingLimit);
        }
        return _toAdjust;
    }

    function calculateRemainingGap(
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _currentThreshold,
        uint256 _total,
        uint256 _levelStakingLimit,
        uint256 iGap,
        uint256 _toAdjust
    ) public pure returns (uint256) {
        if (_currentThreshold == 0) {
            return iGap;
        }

        if (_thresholdConsumedTillLastLevel - _currentThreshold == 0) {
            if (_currentThreshold + iGap <= _total) {
                iGap = 0;
            } else {
                iGap = _currentThreshold + iGap - _total;
            }
        } else {
            iGap = _levelStakingLimit - _toAdjust;
        }

              

        return iGap;
    }

    function thresholdConsumedTillLastLevel(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 _sequence,
        uint256 _level
    ) public pure returns (uint256) {
        uint256 thresholdConsumedValue = 0;

        for (uint256 level = _level; level >= 0; level--) {
            if (_sequence == currentThresholds[level].sequence) {
                thresholdConsumedValue += currentThresholds[level].amount;
            } else {
                break;
            }
            if (level == 0) {
                break;
            }
        }

        return thresholdConsumedValue;
    }

     function getWithdrawData(uint256 _poolId, address _sender)
        internal
        view
        returns (QueueFinanceLib.FetchWithdrawData memory)
    {
        uint256[] memory sequenceIds = iDataContractQF.returnDepositSeqList(
            _poolId,
            _sender
        );
        QueueFinanceLib.FetchWithdrawData
            memory fetchWithdrawData = QueueFinanceLib.FetchWithdrawData({
                poolInfo: iDataContractQF.getPoolInfo(_poolId),
                depositsInfo: iDataContractQF.fetchDepositsBasedonSequences(
                    _poolId,
                    iDataContractQF.returnDepositSeqList(_poolId, _sender)
                ),
                lastUpdatedLevelsForDeposit: iDataContractQF
                    .fetchLastUpdatatedLevelsBySequenceIds(
                        _poolId,
                        sequenceIds
                    ),
                rateInfo: iDataContractQF.getRateInfoByPoolID(_poolId),
                threshold: iDataContractQF.getAllThresholds(_poolId),
                withdrawTime: iDataContractQF.getWithdrawTime(),
                requestedClaimInfoIncrementer: iDataContractQF.getRequestedClaimInfoIncrementer(),
                levelInfo: iDataContractQF.getAllLevelInfo(_poolId)
            });

        return fetchWithdrawData;
    }

}

pragma solidity ^0.8.0;

interface IDepositContractQF {
    function deposit(uint256 _pid, uint256 _amount) external ;
    function depositFromWithdraw(uint256 _pid, uint256 _amount,bool isInternal, address  _sender) external ;
    function updateAddressOnUserInfo(uint256 _pid,address _sender, address _referrel) external ;
}