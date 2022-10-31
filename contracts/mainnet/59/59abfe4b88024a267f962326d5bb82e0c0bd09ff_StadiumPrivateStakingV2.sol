/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

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


// File @openzeppelin/contracts/utils/math/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File contracts/NFT11/Scouting/INFT11Stadium.sol

pragma solidity ^0.8.4;

interface INFT11Stadium is IERC721Enumerable {
    function getSid(uint256 _tokenId) external view returns (uint256);
}


// File contracts/NFT11/Scouting/IMoveCardMintingStation.sol

pragma solidity ^0.8.4;

interface IMoveCardMintingStation {
    function mint(address _tokenReceiver) external returns (uint256);
}


// File contracts/NFT11/RegularPlayer/INFT11RegularMintingStation.sol

pragma solidity ^0.8.4;

interface INFT11RegularMintingStation {
    function mint(address _to) external returns (uint256);
}


// File contracts/NFT11/Scouting/StadiumPrivateStakingV2.sol

pragma solidity ^0.8.4;










contract StadiumPrivateStakingV2 is Ownable, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 constant SECONDS_48_HOURS = 48 * 60 * 60;

    struct LeaseInfo {
        address seatOwner;
        uint256 seatTokenId;
        uint256 seatSid;
        uint256 leaseTime;
        uint256 seatStakingPrice;
        // uint256 emissions;
        uint256 timeToMint; // in seconds
        uint256 currentBonusLevel;
        uint256 moveCardChance;
        uint256 moveCardTimes;
        uint256 signatureCardChance;
        bool staked;
        address playerOwner;
        uint256 playerTokenId;
        uint256 stakingTime;
        uint256 stakingEndTime;
        uint256 stakedBonusLevel;
    }

    struct StakingBaseConfig {
        uint256 emissionsWithStaking;
        uint256 emissionsWithoutStaking;
        uint256 timeToMint;
    }

    struct StakingBonusConfig {
        uint256 stakingPrice;
        uint256 speedForScouting;
        uint256 moveCardChance;
        uint256 moveCardTimes;
        uint256 emissionsIncrease;
        uint256 signatureCardChance;
    }

    struct LeasedStat {
        uint256 amount;
        uint256 bonusLevel;
    }

    struct LeasePoolSet {
        LeaseInfo[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    struct PlayerStakingSet {
        uint256 playerTokenId;
        uint256 indexAtPool;
    }

    LeasePoolSet private _poolSet;

    mapping(address => EnumerableSet.UintSet) private _userLeasedSet;
    mapping(address => mapping(uint256 => LeasedStat)) private _userLeasedStats;

    mapping(uint256 => uint256) private _playersCooldown;
    mapping(address => uint256) private _userRandNonces;

    mapping(address => PlayerStakingSet[]) private _userStakedMap;

    IERC20 public nft11Token;
    INFT11Stadium public stadiumContract;
    IERC721Enumerable public playerContract;
    INFT11RegularMintingStation public regularMintingStation;
    IMoveCardMintingStation public moveCardMintingStation;

    uint256 public scoutEndTime;

    mapping(uint256 => StakingBaseConfig) public stakingBaseConfig;
    mapping(uint256 => mapping(uint256 => StakingBonusConfig))
        public stakingBonusConfig;

    event RegularPlayerMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed legendTokenId,
        uint256 seatTokenId,
        uint256 seatSid,
        uint256 bonusLevel
    );

    constructor(
        IERC20 _nft11Token,
        INFT11Stadium _stadiumContract,
        IERC721Enumerable _playerContract,
        INFT11RegularMintingStation _regularMintingStation,
        IMoveCardMintingStation _moveCardMintingStation,
        uint256 _scoutEndTime
    ) {
        nft11Token = _nft11Token;
        stadiumContract = _stadiumContract;
        playerContract = _playerContract;
        regularMintingStation = _regularMintingStation;
        moveCardMintingStation = _moveCardMintingStation;
        scoutEndTime = _scoutEndTime;
    }

    function _poolTagByOwnerTokenId(address owner, uint256 tokenId)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(uint256(uint160(owner)), tokenId));
    }

    function _poolTagByLeaseInfo(LeaseInfo memory value)
        private
        pure
        returns (bytes32)
    {
        return _poolTagByOwnerTokenId(value.seatOwner, value.seatTokenId);
    }

    function _poolAdd(LeaseInfo memory value) private returns (bool) {
        bytes32 _tag = _poolTagByLeaseInfo(value);
        if (!_poolContains(_tag)) {
            _poolSet._values.push(value);
            _poolSet._indexes[_tag] = _poolSet._values.length;
            _userLeasedSet[value.seatOwner].add(value.seatTokenId);
            return true;
        } else {
            return false;
        }
    }

    function _poolRemove(LeaseInfo memory value) private returns (bool) {
        bytes32 _tag = _poolTagByLeaseInfo(value);
        uint256 valueIndex = _poolSet._indexes[_tag];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = _poolSet._values.length - 1;
            LeaseInfo memory lastvalue = _poolSet._values[lastIndex];

            _poolSet._values[toDeleteIndex] = lastvalue;
            _poolSet._indexes[_poolTagByLeaseInfo(lastvalue)] =
                toDeleteIndex +
                1;

            _poolSet._values.pop();
            delete _poolSet._indexes[_tag];

            _userLeasedSet[value.seatOwner].remove(value.seatTokenId);
            return true;
        } else {
            return false;
        }
    }

    function _poolContains(bytes32 _tag) private view returns (bool) {
        return _poolSet._indexes[_tag] != 0;
    }

    function poolLength() public view returns (uint256) {
        return _poolSet._values.length;
    }

    function poolIndexBySeat(address _owner, uint256 _seatTokenId)
        public
        view
        returns (bool _exist, uint256 _poolIndex)
    {
        uint256 index = _poolSet._indexes[
            _poolTagByOwnerTokenId(_owner, _seatTokenId)
        ];
        if (index > 0) {
            _exist = true;
            _poolIndex = index.sub(1);
        }
    }

    function leaseInfoByPoolIndex(uint256 _index)
        public
        view
        returns (LeaseInfo memory)
    {
        require(_poolSet._values.length > _index, "index out of bounds");
        return _poolSet._values[_index];
    }

    function leaseInfoBySeat(address _owner, uint256 _seatTokenId)
        public
        view
        returns (LeaseInfo memory)
    {
        uint256 index = _poolSet._indexes[
            _poolTagByOwnerTokenId(_owner, _seatTokenId)
        ];
        require(index != 0, "invalid index");
        return _poolSet._values[index - 1];
    }

    function leasedLength(address _userAddress) public view returns (uint256) {
        require(_userAddress != address(0), "Invalid `_userAddress` address");
        return _userLeasedSet[_userAddress].length();
    }

    function leaseInfoByLeasedIndex(address _userAddress, uint256 _index)
        public
        view
        returns (LeaseInfo memory)
    {
        return
            leaseInfoBySeat(
                _userAddress,
                _userLeasedSet[_userAddress].at(_index)
            );
    }

    function leasedStatBySid(address _userAddress, uint256 _sid)
        public
        view
        returns (uint256 amount, uint256 bonusLevel)
    {
        amount = _userLeasedStats[_userAddress][_sid].amount;
        bonusLevel = _userLeasedStats[_userAddress][_sid].bonusLevel;
    }

    function userStakedListLength(address _userAddress)
        public
        view
        returns (uint256)
    {
        return _userStakedMap[_userAddress].length;
    }

    function userStakedInfoByIndex(address _userAddress, uint256 _index)
        public
        view
        returns (uint256 _playerTokenId, LeaseInfo memory _leaseInfo)
    {
        _playerTokenId = _userStakedMap[_userAddress][_index].playerTokenId;
        _leaseInfo = leaseInfoByPoolIndex(
            _userStakedMap[_userAddress][_index].indexAtPool
        );
    }

    function playerCoolingDown(uint256 _playerTokenId)
        public
        view
        returns (bool, uint256)
    {
        if (_playersCooldown[_playerTokenId] > 0) {
            return (
                block.timestamp <= _playersCooldown[_playerTokenId],
                _playersCooldown[_playerTokenId]
            );
        }
        return (false, _playersCooldown[_playerTokenId]);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _bonusLevelByAmount(uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        if (_amount >= 20) return 3;
        if (_amount >= 10) return 2;
        if (_amount >= 5) return 1;
        return 0;
    }

    function _lease(address _userAddress, uint256 seatTokenId) private {
        uint256 sid = stadiumContract.getSid(seatTokenId);
        stadiumContract.safeTransferFrom(
            _userAddress,
            address(this),
            seatTokenId
        );

        uint256 nowTimestamp = block.timestamp;
        LeasedStat memory stats = _userLeasedStats[_userAddress][sid];
        uint256 currentBonusLevel = stats.bonusLevel;
        uint256 newAmount = stats.amount.add(1);
        (
            uint256 timeToMint,
            uint256 newBonusLevel,
            StakingBonusConfig memory bonusConfig
        ) = _updateAllSeatsBonusSettingsIfNeeded(
                UpdateSettingSlotInfo(
                    _userAddress,
                    sid,
                    currentBonusLevel,
                    newAmount
                )
            );

        LeaseInfo memory leaseInfo;
        leaseInfo.seatOwner = _userAddress;
        leaseInfo.seatTokenId = seatTokenId;
        leaseInfo.seatSid = sid;
        leaseInfo.leaseTime = nowTimestamp;
        leaseInfo.seatStakingPrice = bonusConfig.stakingPrice;
        leaseInfo.timeToMint = timeToMint;
        leaseInfo.currentBonusLevel = newBonusLevel;
        leaseInfo.moveCardChance = bonusConfig.moveCardChance;
        leaseInfo.moveCardTimes = bonusConfig.moveCardTimes;
        leaseInfo.signatureCardChance = bonusConfig.signatureCardChance;

        require(_poolAdd(leaseInfo), "Lease error");
    }

    function lease(uint256 _seatTokenId) external {
        require(block.timestamp < scoutEndTime, "The current scout has ended");
        address senderAddress = _msgSender();
        _lease(senderAddress, _seatTokenId);
    }

    struct StakingSlotInfo {
        uint256 nowTimestamp;
        uint256 seatBonusLevel;
        uint256 timeToMint;
        uint256 stakingEndTime;
    }

    function staking(uint256 _playerTokenId, uint256 _seatTokenId) external {
        require(block.timestamp < scoutEndTime, "The current scout has ended");
        StakingSlotInfo memory _slotInfo;
        _slotInfo.nowTimestamp = block.timestamp;

        if (_playersCooldown[_playerTokenId] > 0) {
            require(
                _slotInfo.nowTimestamp > _playersCooldown[_playerTokenId],
                "Player has not finished cooling down"
            );
        }

        address senderAddress = _msgSender();
        (bool _exist, uint256 _indexAtPool) = poolIndexBySeat(
            senderAddress,
            _seatTokenId
        );

        require(_exist, "Invalid pool index");
        LeaseInfo memory leaseInfo = _poolSet._values[_indexAtPool];

        if (leaseInfo.staked) {
            require(
                _slotInfo.nowTimestamp >= leaseInfo.stakingEndTime,
                "Staking not done"
            );
            _scout(_indexAtPool);
        }

        _slotInfo.seatBonusLevel = _userLeasedStats[leaseInfo.seatOwner][
            leaseInfo.seatSid
        ].bonusLevel;

        StakingBaseConfig memory baseConfig = stakingBaseConfig[
            leaseInfo.seatSid
        ];
        StakingBonusConfig memory bonusConfig = stakingBonusConfig[
            leaseInfo.seatSid
        ][_slotInfo.seatBonusLevel];

        _slotInfo.timeToMint = baseConfig.timeToMint;
        if (bonusConfig.speedForScouting > 0) {
            _slotInfo.timeToMint = _slotInfo.timeToMint.sub(
                bonusConfig.speedForScouting
            );
        }

        _slotInfo.stakingEndTime = _slotInfo.nowTimestamp.add(
            _slotInfo.timeToMint
        );

        nft11Token.safeTransferFrom(
            senderAddress,
            address(this),
            bonusConfig.stakingPrice.div(2)
        );

        playerContract.safeTransferFrom(
            senderAddress,
            address(this),
            _playerTokenId
        );

        _userStakedMap[senderAddress].push(
            PlayerStakingSet(_playerTokenId, _indexAtPool)
        );

        _playersCooldown[_playerTokenId] = _slotInfo.stakingEndTime.add(
            SECONDS_48_HOURS
        );

        _poolSet._values[_indexAtPool].seatStakingPrice = bonusConfig
            .stakingPrice
            .div(2);
        _poolSet._values[_indexAtPool].timeToMint = _slotInfo.timeToMint;
        _poolSet._values[_indexAtPool].currentBonusLevel = _slotInfo
            .seatBonusLevel;
        _poolSet._values[_indexAtPool].moveCardChance = bonusConfig
            .moveCardChance;
        _poolSet._values[_indexAtPool].moveCardTimes = bonusConfig
            .moveCardTimes;
        _poolSet._values[_indexAtPool].signatureCardChance = bonusConfig
            .signatureCardChance;
        _poolSet._values[_indexAtPool].staked = true;
        _poolSet._values[_indexAtPool].playerOwner = senderAddress;
        _poolSet._values[_indexAtPool].playerTokenId = _playerTokenId;
        _poolSet._values[_indexAtPool].stakingTime = _slotInfo.nowTimestamp;
        _poolSet._values[_indexAtPool].stakingEndTime = _slotInfo
            .stakingEndTime;
        _poolSet._values[_indexAtPool].stakedBonusLevel = _slotInfo
            .seatBonusLevel;
    }

    function _scout(uint256 indexAtPool) private {
        LeaseInfo memory leaseInfo = _poolSet._values[indexAtPool];

        uint256 regularTokenId = regularMintingStation.mint(
            leaseInfo.playerOwner
        );

        emit RegularPlayerMinted(
            leaseInfo.playerOwner,
            regularTokenId,
            leaseInfo.playerTokenId,
            leaseInfo.seatTokenId,
            leaseInfo.seatSid,
            leaseInfo.stakedBonusLevel
        );

        uint256 _moveCardProbability = leaseInfo.moveCardChance;
        for (uint256 i = 0; i < leaseInfo.moveCardTimes; i++) {
            if (_luckyDraw(leaseInfo.playerOwner, _moveCardProbability)) {
                moveCardMintingStation.mint(leaseInfo.playerOwner);
                _moveCardProbability = leaseInfo.moveCardChance;
            } else {
                _moveCardProbability = _moveCardProbability.add(
                    leaseInfo.moveCardChance
                );
            }
        }

        // if (_luckyDraw(leaseInfo.playerOwner, leaseInfo.signatureCardChance)) {
        //     skillCardsFactory.mintSignatureCard(leaseInfo.playerOwner);
        // }

        playerContract.safeTransferFrom(
            address(this),
            leaseInfo.playerOwner,
            leaseInfo.playerTokenId
        );

        PlayerStakingSet[] memory _stakedList = _userStakedMap[
            leaseInfo.playerOwner
        ];
        for (uint256 i = 0; i < _stakedList.length; i++) {
            if (_stakedList[i].playerTokenId == leaseInfo.playerTokenId) {
                _userStakedMap[leaseInfo.playerOwner][i] = _userStakedMap[
                    leaseInfo.playerOwner
                ][_stakedList.length - 1];
                _userStakedMap[leaseInfo.playerOwner].pop();
                break;
            }
        }
    }

    function _luckyDraw(address _userAddress, uint256 _probability)
        private
        returns (bool)
    {
        if (_probability == 0) return false;
        if (_probability >= 100) return true;
        _userRandNonces[_userAddress] = _userRandNonces[_userAddress].add(1);
        uint256 _randNonce = _userRandNonces[_userAddress];
        uint256 _random = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    _userAddress,
                    _randNonce
                )
            )
        ) % 100;
        return (_random >= 100 - _probability);
    }

    function scout(uint256 indexAtPool) external {
        require(indexAtPool < poolLength(), "Invalid pool index");

        uint256 nowTimestamp = block.timestamp;
        LeaseInfo memory leaseInfo = _poolSet._values[indexAtPool];
        address senderAddress = _msgSender();

        require(senderAddress == leaseInfo.seatOwner, "Not the seat owner");
        require(leaseInfo.staked, "Nothing to scout");
        require(nowTimestamp >= leaseInfo.stakingEndTime, "Staking not done");

        _scout(indexAtPool);

        uint256 seatBonusLevel = _userLeasedStats[leaseInfo.seatOwner][
            leaseInfo.seatSid
        ].bonusLevel;
        StakingBonusConfig memory bonusConfig = stakingBonusConfig[
            leaseInfo.seatSid
        ][seatBonusLevel];

        _poolSet._values[indexAtPool].seatStakingPrice = bonusConfig
            .stakingPrice;
        _poolSet._values[indexAtPool].moveCardChance = bonusConfig
            .moveCardChance;
        _poolSet._values[indexAtPool].moveCardTimes = bonusConfig.moveCardTimes;
        _poolSet._values[indexAtPool].signatureCardChance = bonusConfig
            .signatureCardChance;
        _poolSet._values[indexAtPool].staked = false;
        _poolSet._values[indexAtPool].playerOwner = address(0);
        _poolSet._values[indexAtPool].playerTokenId = 0;
        _poolSet._values[indexAtPool].stakingTime = 0;
        _poolSet._values[indexAtPool].stakingEndTime = 0;
        _poolSet._values[indexAtPool].stakedBonusLevel = 0;
    }

    function unlease(uint256 _seatTokenId) external {
        address senderAddress = _msgSender();
        (bool exist, uint256 indexAtPool) = poolIndexBySeat(
            senderAddress,
            _seatTokenId
        );
        require(exist, "Invalid pool index");

        LeaseInfo memory leaseInfo = _poolSet._values[indexAtPool];
        require(senderAddress == leaseInfo.seatOwner, "Not the seat owner");

        uint256 nowTimestamp = block.timestamp;
        if (leaseInfo.staked) {
            require(
                leaseInfo.stakingEndTime <= nowTimestamp,
                "Staking not completed"
            );
            _scout(indexAtPool);
        }

        _unlease(leaseInfo);
    }

    function _unlease(LeaseInfo memory _leaseInfo) private {
        stadiumContract.safeTransferFrom(
            address(this),
            _leaseInfo.seatOwner,
            _leaseInfo.seatTokenId
        );

        uint256 sid = _leaseInfo.seatSid;
        LeasedStat memory stats = _userLeasedStats[_leaseInfo.seatOwner][sid];
        uint256 currentBonusLevel = stats.bonusLevel;
        uint256 newAmount = stats.amount.sub(1);
        _updateAllSeatsBonusSettingsIfNeeded(
            UpdateSettingSlotInfo(
                _leaseInfo.seatOwner,
                sid,
                currentBonusLevel,
                newAmount
            )
        );
        require(_poolRemove(_leaseInfo), "Unlease error");
    }

    struct UpdateSettingSlotInfo {
        address senderAddress;
        uint256 sid;
        uint256 currentBonusLevel;
        uint256 newAmount;
    }

    function _updateAllSeatsBonusSettingsIfNeeded(
        UpdateSettingSlotInfo memory _slotInfo
    )
        private
        returns (
            uint256 timeToMint,
            uint256 newBonusLevel,
            StakingBonusConfig memory bonusConfig
        )
    {
        newBonusLevel = _bonusLevelByAmount(_slotInfo.newAmount);
        _userLeasedStats[_slotInfo.senderAddress][_slotInfo.sid]
            .amount = _slotInfo.newAmount;

        StakingBaseConfig memory baseConfig = stakingBaseConfig[_slotInfo.sid];
        bonusConfig = stakingBonusConfig[_slotInfo.sid][newBonusLevel];

        timeToMint = baseConfig.timeToMint;
        if (bonusConfig.speedForScouting > 0) {
            timeToMint = timeToMint.sub(bonusConfig.speedForScouting);
        }

        if (_slotInfo.currentBonusLevel != newBonusLevel) {
            _userLeasedStats[_slotInfo.senderAddress][_slotInfo.sid]
                .bonusLevel = newBonusLevel;
            for (
                uint256 i = 0;
                i < _userLeasedSet[_slotInfo.senderAddress].length();
                i++
            ) {
                uint256 tokenId = _userLeasedSet[_slotInfo.senderAddress].at(i);
                uint256 index = _poolSet
                    ._indexes[
                        _poolTagByOwnerTokenId(_slotInfo.senderAddress, tokenId)
                    ]
                    .sub(1);

                LeaseInfo memory _info = _poolSet._values[index];

                if (_info.seatSid == _slotInfo.sid) {
                    _poolSet._values[index].timeToMint = timeToMint;
                    _poolSet._values[index].currentBonusLevel = newBonusLevel;
                    if (!_info.staked) {
                        _poolSet._values[index].moveCardChance = bonusConfig
                            .moveCardChance;
                        _poolSet._values[index].moveCardTimes = bonusConfig
                            .moveCardTimes;
                        _poolSet
                            ._values[index]
                            .signatureCardChance = bonusConfig
                            .signatureCardChance;
                    }
                }
            }
        }
    }

    function setStakingBaseConfig(uint256[][] calldata _configs)
        external
        onlyOwner
    {
        require(
            _configs.length > 0,
            "The length of _configs must be greater than 0"
        );
        for (uint256 i = 0; i < _configs.length; i++) {
            uint256[] memory _config = _configs[i];
            stakingBaseConfig[_config[0]] = StakingBaseConfig(
                _config[1],
                _config[2],
                _config[3]
            );
        }
    }

    function setStakingBonusConfig(uint256[][] calldata _configs)
        external
        onlyOwner
    {
        require(
            _configs.length > 0,
            "The length of _configs must be greater than 0"
        );
        for (uint256 i = 0; i < _configs.length; i++) {
            uint256[] memory _config = _configs[i];
            stakingBonusConfig[_config[0]][_config[1]] = StakingBonusConfig(
                _config[2],
                _config[3],
                _config[4],
                _config[5],
                _config[6],
                _config[7]
            );
        }
    }

    function platformClaim(uint256 _amount) external onlyOwner {
        nft11Token.safeTransfer(_msgSender(), _amount);
    }

    function setMoveCardMintingStation(IMoveCardMintingStation _mintingStation)
        external
        onlyOwner
    {
        moveCardMintingStation = _mintingStation;
    }

    function setScoutEndTime(uint256 _scoutEndTime) external onlyOwner {
        scoutEndTime = _scoutEndTime;
    }
}