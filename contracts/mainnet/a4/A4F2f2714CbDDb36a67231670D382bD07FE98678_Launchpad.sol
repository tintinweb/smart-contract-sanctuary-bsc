/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// File: contracts/Structs.sol



pragma solidity 0.8.9;

/**
 * @dev Launchpad explanation
 *  - startTime: start time of launchpad
 *  - endTime: endTime of launchpad
 *  - refundDuration: period of time that user can refund after they registered
 *  - entryDates, numberOfTickets,ticketPrices, minAllocations, maxAllocations: lists of times when user can register and corresponding number of tickets, min allocations, max allocations(we call the index of these 3 lists: level)
 *  - ticketSolds: corresspoding tickets sold at level
 *  - ticketNumbers: correspoding tickets number at level
 *  - depositTime: Time when user can deposit
 *  - initalPrice: price of reward token compare to stable coins (*10^18)
 *  - depositFundAddress: address that recieve user's deposit
 *  - rewardTokenAddress: address of reward token
 */

struct Project {
    uint256 startTime;
    uint256 endTime;
    uint256 refundDuration; 
    uint256[] entryDates;
    uint256[] numberOfTickets;
    uint256[] ticketPrices;
    uint256[] minAllocations;
    uint256[] maxAllocations;
    uint256[] ticketSolds;
    uint256[] ticketNumbers;
    uint256 depositTime;
    uint256 initialPrice;
    address depositFundAddress;
    address rewardTokenAddress;
    uint256 hardcap;
    uint256 totalDeposited;
}

/**
 * @dev Register Explanation: information of registered user 
 *  - enterTime: time when user register
 *  - enterLevel: register level (corresspnding to the index of entryDates, numberOfTickets, ticketSolds of the launchpad)
 *  - ticketNumber: correspoding ticket number 
 *  - depositedTime: time when user deposited 
 *  - depositedAmount: amount of token that user deposited
 *  - claimableAmount: Amount of reward token that user can claim
 */
struct Register {
    uint256 enterTime;
    uint256 enterLevel;
    uint256 ticketNumber;
    uint256 depositedTime;
    uint256 depositedAmount;
    uint256 claimableAmount;
}

/**
 * @dev Grant explanation
 * - recipient: account to recieve vesting
 * - amount: total amount the user can receive
 * - claimDates: (unix time): the time the user can receive tokens
 * - claimPercents: mapping to claims date: Percentage of total amount that the user can receive
 * - totalClaimed: the amount of token that the user claimed
 */
struct Grant {
    uint256 amount;
    uint256[] claimDates;
    uint256[] claimPercents;
    uint256 totalClaimed;
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

// File: contracts/IBurnable.sol



pragma solidity 0.8.9;

interface IBurnable{
    function burn(uint256 amount) external;
    
    function burnFrom(address account, uint256 amount) external;
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

// File: contracts/IBEP20.sol



pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// File: contracts/SafeBEP20.sol



pragma solidity 0.8.9;




/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/Controller.sol



pragma solidity 0.8.9;


contract Controller is Ownable {
    mapping(address => bool) public adminList;

    function setAdmin(address user_, bool status_) public onlyOwner {
        adminList[user_] = status_;
    }

    modifier onlyAdmin(){
        require(adminList[msg.sender], "Controller: Msg sender is not the admin");
        _;
    }
}
// File: contracts/Launchpad.sol



pragma solidity 0.8.9;







contract Launchpad is Controller, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    /**
     * @dev this mangifying factor is used to handle initial price. When providing input for launchpad, initial price will be multiply by this mangifying factor
     */
    uint256 public magnifying_factor = 1e18;
    
    /**      
     * @dev User pay staking token to register, pay USDT and BUSD to deposit to a launchpad 
     */
    address public stakingToken;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955; //USDT address BSC mainnet
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUST address BSC mainnet

    /**
     * @dev Explain mappings
     * - launchpadExisted: either launchpad existed or not
     * - projectToRegisterUser: project -> address -> Register (information of user)
     * - projectToLaunchpad: project => Launchpad 
     * - projectToAddressAtLevel: project => level => addresses[]: return list of user at a level of a launchpad
     */
    
    string[] public allProjects;
    mapping(string => bool) public launchPadExisted;
    mapping(string => Project) public projectToLaunchpads;
    mapping(string => mapping(address => Register))
        public projectToRegisterUser;

    mapping(string => mapping(uint256 => address[]))
        private projectToAddressAtLevel;

    /**
     * @dev Modifier that checks whether a launchpad is still running 
     */
    modifier onlyRunningLaunchpad(string memory launchpad_){
        require(block.timestamp >= projectToLaunchpads[launchpad_].startTime && block.timestamp <= projectToLaunchpads[launchpad_].endTime, "Launchpad: not in running time");
        _;
    }

    event LaunchpadCreated(string indexed launchpad);
    event Registered(
        string indexed launchpad,
        address indexed user,
        uint256 indexed level
    );
    event Deposited(
        address indexed user,
        string indexed launchpad,
        uint256 indexed amount
    );

    constructor(address stakingToken_) {
        stakingToken = stakingToken_;
        adminList[msg.sender] = true;
    }

    /**
     * @dev Staking token is the token that user use to register to the launchpad
     */
    function setStakingToken(address stakingToken_) external onlyAdmin {
        require(stakingToken_ != address(0), "Pads: Invalid staking token");
        stakingToken = stakingToken_;
    }

    /**
     * @dev Set the address of the stable coin USDT token - for depositing 
     */
    function setUSDTAddress(address USDTAddress_) external onlyAdmin {
        USDT = USDTAddress_;
    }

    /**
     * @dev Set the address of the stable coin BUSD token - for depositing 
     */
    function setBUSDAddress(address BUSDAddress_) external onlyAdmin {
        BUSD = BUSDAddress_;
    }

    /**
     * @dev function: Set magnifying factor
     */
    function setMagnifyingFactor(uint256 value_) external onlyAdmin{
        magnifying_factor = value_;
    }


    /**
     * @dev Create the launchpad. The launchpad allows user to register using VPK, deposit using stable coins in order for reward token of the launchpad 
     * @param launchpad_ string id of the launchpad/project 
     * @param times_  times[0]: opening time of the launchpad, times[1]: ending time of the launchpad, times[2]: refund duration in hours (period of time that user can redeem the VPK token after registered)
     * @param entryDates_ @param numberOfTickets_ @param minAllocations_ @param maxAllocations_ arrays of corresponding to register times, number of tickets, minAllocations and maxAllocations when user register to a launchpad/project      
     * @param entryData_ an array of entry data: entryData[0]: deposit time, entryData[1]: initialPrice
     * @param depositFundAddress_ Address the receive deposit of user 
     * @param rewardTokenAddress_ Address of reward token 
     */
    function createLaunchPad(
        string memory launchpad_,
        uint256[] memory times_, // 0: start time, 1: end time, 2: refunduration: in seconds
        uint256[] memory entryDates_,
        uint256[] memory numberOfTickets_,
        uint256[] memory ticketPrices_,
        uint256[] memory minAllocations_,
        uint256[] memory maxAllocations_,
        uint256[] memory entryData_, //0: deposit time, 1: initial price
        address depositFundAddress_,
        address rewardTokenAddress_,
        uint256 hardcap_
    ) external onlyAdmin {
        require(!launchPadExisted[launchpad_], "createLaunchpad: launchpad is already existed");
        require(
            times_[1] > block.timestamp,
            "createLaunchpad: Endtime is smaller than current time"
        );
       
        for(uint256 i = 0; i < maxAllocations_.length;i++ ){
            require(hardcap_ >= maxAllocations_[i],"hard cap must be greater than or equal all max caps");
        }
        require(times_.length == 3, "createLaunchpad: times length should be 3");
        require(entryData_.length == 2, "createLaunchpad: Entry data length should be 2");
        require(
            entryDates_.length == numberOfTickets_.length &&
            entryDates_.length == ticketPrices_.length &&
            entryDates_.length == minAllocations_.length &&
            entryDates_.length == maxAllocations_.length,
            "Invalid length of array input"
        );

        require(times_[0] < times_[1], "createLaunchpad: start time must be smaller than endtime");
        require(times_[0] <= entryDates_[0], "createLaunchpad: invalid start time");
        require(entryDates_[entryDates_.length -1] <= times_[1], "createlaunchpad: invalid endtime");

        for (uint256 i =0;i< entryDates_.length; i++){
            require(minAllocations_[i] <= maxAllocations_[i], "createlaunchpad: invalid allocations");

            if (i !=0){
                require(entryDates_[i-1] < entryDates_[i], "createlaunchpad: invalid entryDates");
            }
        }

        uint256[] memory ticketSolds_ = new uint256[](entryDates_.length);
        uint256[] memory ticketNumbers_ = new uint256[](entryDates_.length);

        Project memory launchpad = Project({
            startTime: times_[0],
            endTime: times_[1],
            refundDuration: times_[2],
            entryDates: entryDates_,
            numberOfTickets: numberOfTickets_,
            ticketPrices: ticketPrices_,
            minAllocations: minAllocations_,
            maxAllocations: maxAllocations_,
            ticketSolds: ticketSolds_,
            ticketNumbers: ticketNumbers_,
            depositTime: entryData_[0],
            initialPrice: entryData_[1],
            depositFundAddress: depositFundAddress_,
            rewardTokenAddress: rewardTokenAddress_,
            hardcap: hardcap_,
            totalDeposited:0
        });
        projectToLaunchpads[launchpad_] = launchpad;
        launchPadExisted[launchpad_] = true;

        allProjects.push(launchpad_);
        emit LaunchpadCreated(launchpad_);
    }

    /**
     * @dev Disable the launchpad incase of creating launchpad with the wrong inputs
     */
    function disableLaunchpad(string memory launchpad_) external onlyAdmin{
        projectToLaunchpads[launchpad_].startTime = 0;
        projectToLaunchpads[launchpad_].endTime = 0;
    }

    /**
     * @dev User register for a launchpad
     * @param launchpad_ string id of the launchpad
     * @notice user has approve for contract to take the token before registering 
     */
    function register(string memory launchpad_) private {
        bool registerable;
        uint256 level;

        (registerable, level) = calculateEntryLevel(launchpad_);

        require(stakingToken != address(0), "Pads: Invalid staking token");

        require(registerable, "Pads: No entries are available!");
        require(
            !isUserRegistered(launchpad_, msg.sender),
            "Pads: You'are already registered"
        );

        Project storage project = projectToLaunchpads[launchpad_];

        if (project.ticketPrices[level] > 0) {
            IBEP20(stakingToken).safeTransferFrom(
                msg.sender,
                address(this),
                project.ticketPrices[level]
            );
        }
        

        //Add register user
        Register memory registerUser = Register({
            enterTime: block.timestamp,
            enterLevel: level,
            ticketNumber: project.ticketNumbers[level],
            depositedTime: 0,
            depositedAmount: 0,
            claimableAmount: 0
        });

        projectToRegisterUser[launchpad_][msg.sender] = registerUser;
        projectToAddressAtLevel[launchpad_][level].push(msg.sender);

        //user is registred
        project.ticketSolds[level] += 1;
        project.ticketNumbers[level] += 1;

        emit Registered(launchpad_, msg.sender, level);
    }

    /**
     * @dev Calculate what level it is to enter the launchpad. Level correspoding to the index of entryDates_, numberOfTickets_ and ticketPrices_
     * @param launchPad_ string id of the launchpad
     * @return bool: registerable or not, uint256: level
     */
    function calculateEntryLevel(string memory launchPad_)
        public
        view
        returns (bool, uint256)
    {
        Project storage project = projectToLaunchpads[launchPad_];

        uint256 totalLength = project.entryDates.length;

        if (block.timestamp > project.entryDates[totalLength - 1] || block.timestamp < project.startTime) {
            return (false, 0);
        }

        if (
            block.timestamp >= project.startTime &&
            block.timestamp < project.entryDates[0]
        ) {
            if (project.ticketSolds[0] < project.numberOfTickets[0]) {
                return (true, 0);
            } else {
                for (uint256 k = 1; k < totalLength; k++) {
                    if (
                        project.ticketSolds[k] < project.numberOfTickets[k]
                    ) {
                        return (true, k);
                    }
                }
                return (false, 0);
            }
        }

        for (uint256 i = 1; i < totalLength; i++) {
            if (
                block.timestamp > project.entryDates[i - 1] &&
                block.timestamp < project.entryDates[i]
            ) {
                // if ticket are avail at level i
                if (project.ticketSolds[i] < project.numberOfTickets[i]) {
                    return (true, i);
                } else {
                    //if tickets are not avail at level i ==> get ticket at the next level
                    for (uint256 j = i + 1; j < totalLength; j++) {
                        if (
                            project.ticketSolds[j] <
                            project.numberOfTickets[j]
                        ) {
                            return (true, j);
                        }
                    }
                    return (false, 0);
                }
            }
        }

        return (false, 0);
    }


    /**
     * @dev User deposit money to the deposit fund of the launchpad
     * @param stableCoinAddress_ the address of the stable coin (USDT or BUSD)
     * @param amount_ amount of stable coins that user deposit to the launchpad
     */
    function deposit(
        string memory launchpad_,
        address stableCoinAddress_,
        uint256 amount_
    ) external onlyRunningLaunchpad(launchpad_) nonReentrant{
        require(
            stableCoinAddress_ == USDT || stableCoinAddress_ == BUSD,
            "Stable coin not supported"
        );
        if(!isUserRegistered(launchpad_, msg.sender)){
            register(launchpad_);
            // register before deposit if not registered already
        }

        require(
            isUserRegistered(launchpad_, msg.sender),
            "user has not registered yet"
        );

        (uint256 minA, uint256 maxA) = calculateDepositableAmount(
            launchpad_,
            msg.sender
        );

        require(maxA > 0, "You are not authorized to deposit");
        require(amount_ >= minA && amount_ <= maxA, "Deposit amount not valid");

        //note: transfer amount_ of token to deposit fund address
        IBEP20(stableCoinAddress_).safeTransferFrom(
            msg.sender,
            projectToLaunchpads[launchpad_].depositFundAddress,
            amount_
        );

        Register storage registerUser = projectToRegisterUser[launchpad_][
            msg.sender
        ];
        projectToLaunchpads[launchpad_].totalDeposited += amount_;
        registerUser.depositedAmount += amount_;
        registerUser.depositedTime = block.timestamp;

        uint256 initialPrice = projectToLaunchpads[launchpad_].initialPrice;

        //note When creating launchpad, We multiply initial price by 10 ^ 18 to handle decimal case. 
        registerUser.claimableAmount = ((registerUser.depositedAmount *
            magnifying_factor) / initialPrice);

        emit Deposited(msg.sender, launchpad_, amount_);
    }

    /**
     * @dev Calculate how many stable coin a registered user can deposit
     * @return uint256, uint256: minimum - maximum amount of stable coins a user can deposit  
     */
    function calculateDepositableAmount(string memory launchpad_, address user_)
        public
        view
        returns (uint256, uint256)
    {
        Project storage project = projectToLaunchpads[launchpad_];

        if (
            block.timestamp < project.depositTime ||
            block.timestamp > project.endTime
        ) {
            return (0, 0);
        }
        uint256 hardcap = projectToLaunchpads[launchpad_].hardcap;
        uint256 totalDeposited = projectToLaunchpads[launchpad_].totalDeposited;
        if(totalDeposited >= hardcap){
            return (0,0); // hardcap reached 
        }
        uint256 depositedAmount = projectToRegisterUser[launchpad_][user_]
            .depositedAmount;
        
        uint256 enterLevel = projectToRegisterUser[launchpad_][user_].enterLevel;

        uint256 minA;
        uint256 maxA;
        
        if (depositedAmount >= project.minAllocations[enterLevel]) {
            minA = 1;
            maxA = project.maxAllocations[enterLevel] - depositedAmount;
        } else {
            minA = project.minAllocations[enterLevel];
            maxA = project.maxAllocations[enterLevel];
        }
        uint256 availableDepositAmounts = hardcap - totalDeposited;
        if(maxA >= availableDepositAmounts ){
            maxA = availableDepositAmounts;
        }
        return (minA, maxA);
    }

    /**
     * @dev Owner can withdraw all staking tokens 
     */
    function withdrawAll() external onlyOwner {
        uint256 totalBalance = IBEP20(stakingToken).balanceOf(
            address(this)
        );
        IBEP20(stakingToken).safeTransfer(owner(), totalBalance);
    }

    /**
     * @dev Get data of tickets of launchpad_ at level_
     * @param level_ level of launchpad
     * @return uint256 uin256 uint256 uint256 uint256: Ticket solds, total number of ticket, ticket price, min allocation max allocation (at level_ of launchpad_)
     */
    function getTicketsAtLevel(string memory launchpad_, uint256 level_)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Project storage project = projectToLaunchpads[launchpad_];

        return (
            project.ticketSolds[level_],
            project.numberOfTickets[level_],
            project.ticketPrices[level_],
            project.minAllocations[level_],
            project.maxAllocations[level_]
        );
    }

    /**
     * @dev Return list of registered user at level (address0 for user who refunded)
     */
    function getAddressesAtLevel(string memory launchPad_, uint256 level_)
        external
        view
        returns (address[] memory)
    {
        return projectToAddressAtLevel[launchPad_][level_];
    }

    /**
     * @dev check whether a user has registered or not
     */
    function isUserRegistered(string memory launchpad_, address user_)
        public
        view
        returns (bool)
    {
        return projectToRegisterUser[launchpad_][user_].enterTime != 0;
    }

    /**
     * @dev Get how many level a launchpad have
     * @return uint256: number of level a launchpad has 
     */
    function getNumberOfLevel(string memory launchpad_)
        external
        view
        returns (uint256)
    {
        return projectToLaunchpads[launchpad_].entryDates.length;
    }

    /**
     * @dev Get total amount of VPK token this contract holds
     */
    function getTotalVPKAmount() external view returns (uint256) {
        return IBEP20(stakingToken).balanceOf(address(this));
    }

    /**
     * @dev burn percent of total amount of vpk of token this contract holds 
     * @notice only admin can burn token, and vpk token must have the correspoding interface (import above)
     */
    function burnVPK(uint256 percent_) external onlyAdmin {
        require(percent_ <= 100, "VPK: Cannot burn more than 100%");

        uint256 burnAmount = (IBEP20(stakingToken).balanceOf(
            address(this)
        ) * percent_) / 100;

        IBurnable(stakingToken).burn(burnAmount);
    }
}