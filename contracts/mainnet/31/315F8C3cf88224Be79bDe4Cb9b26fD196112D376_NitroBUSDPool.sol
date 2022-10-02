/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

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

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

// File: contracts/NitroBUSD.sol


// Nitro BUSD Pool by XOXO
// https://xoxobusd.com/dapp/nitrobusdpool.html

pragma solidity ^0.8.16;




contract NitroBUSDPool is Ownable {

    using SafeERC20 for IERC20;
    IERC20 public XTO;
    IERC20 public BUSD;
    uint256 private MAX_INT = 2**256 - 1;
    uint256 public timeLimit = 24 hours;

    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private leaderboardSet;

    /* CONSTANTS */
    uint256 public slotPrice = 48 * 10 ** 18;
    uint256 public payAmount = 30 * 10 ** 18;
    uint256[] public sponsorEarnAmount = [1, 2, 3, 1];
    uint256 public devSupportAmount = 1 * 10 ** 18;
    uint256 public poolSupportAmount = 2 * 10 ** 18;
    uint256 public vaultTokenAmount = 5 * 10 ** 18;
    uint256 public marketingAmount = 2 * 10 ** 18;
    uint256 public leaderboardAmount = 1 * 10 ** 18;
    uint256[10] public leaderboardPlaces = [250, 200, 150, 120, 100, 50, 50, 30, 25, 25];

    address public busdAddress = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public xtoAddress = address(0x2E3f065a6D59BE9d3aC26FEedE491d8478F83124);

    /* WALLETS */
    address public poolSupportWallet = address(0xD04edE1a1695523C39c175219e66046bC9BFdd05);
    address public dev0SupportWallet = address(0xC7D7A3B7d31343d8895CC8fd5D78958F3Bb4D839);
    address public dev1SupportWallet = address(0x262fdEa00a103126118DD6073CcD08179AF9aade);
    address public vaultWallet = address(0x7120F799B63a9f2F1F9E847479a1653841967C2F);
    address public leaderboardWallet = address(0x524656957c547F79C3C18E8884f1EDE885f41E50);
    address public marketingWallet = address(0x4236B5DEeb3382F2392883e9dD25457d274d7be1);

    struct Users {
        uint id;
        address invitedBy;
        uint referrals;
        uint slots;
        uint paid;
        uint claimed;
        uint refPaid;
        uint[] slotIds;
        mapping(uint => uint) roundToSlots;
        mapping(uint => uint) roundToClaimed;
        mapping(uint => uint) roundToReferrals;
        mapping(uint => uint) roundToClaimedBUSD;
    }

    struct Slots {
        address user;
        uint paidCount;
        uint createdAt;
    }

    /* SUMMARY STAT */
    uint256 public totalDeposited;
    uint256 public totalPaid;
    uint256 public totalBought;

    /* COUNTERS */
    uint256 public activeSlot;
    uint256 public totalSlots;
    uint256 public totalUsers;
    uint256 public nitroVault;
    uint256 public leaderboardVault;
    uint256 public tokenBySlots;
    uint256 public currentRound;

    /* VARIABLES */
    bool public allowRegister;
    bool public allowBuy;
    bool public allowClaim;
    bool public allowClaimBUSD;

    /* MAPPINGS */
    mapping(uint => address) public idToAddress;
    mapping(address => uint) public addressToId;
    mapping(address => Users) public User;
    mapping(uint => Slots) public Slot;
    mapping(uint => uint) public roundToVault;
    mapping(uint => uint) public roundToLeaderboardVault;
    mapping(uint => uint) public roundToAllSlots;

    /* EVENTS */
    event addUser(address user, address sponsor);
    event addSlot(address user, uint slotId);
    event claimReward(address user, uint claimedAmount, uint claimedRound);
    event payRef(address from, address to, uint amount, uint level);
    event paySlot(address from, address to, uint amount, uint fromSlot, uint toSlot);
    event finishRound(uint currentRound, uint allslots, uint amount, uint tokenBySlot);

    constructor() {    

        allowRegister = true;
        allowBuy = false;
        allowClaim = false;
        allowClaimBUSD = false;
        totalUsers = 1;
        totalSlots = 1;
        currentRound = 1;

        idToAddress[totalUsers] = msg.sender;
        addressToId[msg.sender] = totalUsers;

        Users storage u = User[msg.sender];
        u.id = totalUsers;
        u.invitedBy = msg.sender;
        u.slots++;
        u.roundToSlots[currentRound]++;
        roundToAllSlots[currentRound]++;

        u.slotIds.push(totalSlots);

        Slots storage newSlot = Slot[totalSlots];
        newSlot.user = msg.sender;
        newSlot.paidCount = 0;

        XTO = IERC20(xtoAddress);
        XTO.approve(address(this), MAX_INT);

        BUSD = IERC20(busdAddress);
        BUSD.approve(address(this), MAX_INT);

    }

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "Not EOA");
        _;
    }

    function Register(address sponsorWallet) public onlyEOA {

        address wallet = msg.sender;
        require(allowRegister == true, "Register disabled");
        require(addressToId[wallet] == 0, "Already Registered");        
        require(sponsorWallet != wallet, "Wrong sponsor");

        Users storage sponsor = User[sponsorWallet];
        require(sponsor.id > 0, "Sponsor not registered");
        sponsor.referrals++;
        sponsor.roundToReferrals[currentRound]++;

        totalUsers++;   
        Users storage u = User[wallet];
        idToAddress[totalUsers] = wallet;
        addressToId[wallet] = totalUsers;
        
        u.id = totalUsers;
        u.invitedBy = sponsorWallet;     

        emit addUser(wallet, sponsorWallet);
    }

    function checkBoughtSlots(address wallet) internal view returns (uint refPayLevel)  {
        uint _refPayLevel = 0;
        Users storage u = User[wallet];
        if (u.slotIds.length == 0) return _refPayLevel;
        for ( uint i = u.slotIds.length; i > 0; i-- ) {
            Slots storage slotToCheck = Slot[u.slotIds[i-1]];
            if ((block.timestamp - slotToCheck.createdAt) <= timeLimit) {
                _refPayLevel++;
                if (_refPayLevel >=2) break;
            }
        }
        return _refPayLevel;
    }

    function BuySlot() public {

        require(allowBuy == true, "Buying disabled");

        // INIT
        address _buyer = msg.sender;
        uint _slotToPay = activeSlot;
        Users storage u = User[_buyer];
        address _sponsor = u.invitedBy;
        require(u.id > 0, "Not Registered");
        BUSD.safeTransferFrom(_buyer, address(this), slotPrice);

        // REFPAYMENTS
        for (uint8 i = 0; i < sponsorEarnAmount.length; i++) {            
            uint _transferamount = sponsorEarnAmount[i] * 10 ** 18; // [1, 2, 3, 1]
            Users storage innerSponsor = User[_sponsor];
            uint _levelPaid = checkBoughtSlots(_sponsor);
            if ((i == 0) || (i == 1)) {
                if (_levelPaid >= 1) {
                    innerSponsor.refPaid += _transferamount;
                    BUSD.safeTransferFrom(address(this), _sponsor, _transferamount);
                    emit payRef(msg.sender, _sponsor, _transferamount, (i+1));
                } else {
                    BUSD.safeTransferFrom(address(this), owner(), _transferamount);
                    emit payRef(msg.sender, owner(), _transferamount, (i+1));
                }
            }
            if ((i == 2) || (i == 3)) {
                if (_levelPaid >= 2) {
                    innerSponsor.refPaid += _transferamount;
                    BUSD.safeTransferFrom(address(this), _sponsor, _transferamount);
                    emit payRef(msg.sender, _sponsor, _transferamount, (i+1));
                } else {
                    BUSD.safeTransferFrom(address(this), owner(), _transferamount);
                    emit payRef(msg.sender, owner(), _transferamount, (i+1));
                }
            }            
            _sponsor = User[_sponsor].invitedBy;
        }

        // ADD SLOT 
        totalSlots++;
        Slots storage newSlot = Slot[totalSlots];
        newSlot.user = _buyer;
        u.slots++;
        emit addSlot(_buyer, totalSlots);

        // UPDATE ROUND DATA
        u.roundToSlots[currentRound]++;
        roundToAllSlots[currentRound]++;

        // PAY TO ACTIVE SLOT
        Slots storage slotToPay = Slot[_slotToPay];
        slotToPay.paidCount++;
        u.paid += payAmount;
        BUSD.safeTransferFrom(address(this), _sponsor, payAmount);
        emit paySlot(msg.sender, slotToPay.user, payAmount, totalSlots, _slotToPay);
        if (slotToPay.paidCount == 1) {
            activeSlot++;
        }

        // DISTRIBUTE OTHER PAYMENTS
        BUSD.safeTransferFrom(address(this), poolSupportWallet, poolSupportAmount);  // 2
        BUSD.safeTransferFrom(address(this), marketingWallet, marketingAmount); // 2
        BUSD.safeTransferFrom(address(this), dev0SupportWallet, devSupportAmount / 2); // 0.5
        BUSD.safeTransferFrom(address(this), dev1SupportWallet, devSupportAmount / 2); // 0.5
        BUSD.safeTransferFrom(address(this), vaultWallet, vaultTokenAmount); // 5
        BUSD.safeTransferFrom(address(this), leaderboardWallet, leaderboardAmount); // 1

        totalDeposited += slotPrice;
    }

    function collectLeaderBoard() public onlyOwner returns(address[10] memory leaderboard) {
        address[10] memory collected;
        for (uint l = 0; l < 10; l++) {
            uint maxAmount = 0;
            address foundWallet = address(0x0);
            for(uint i = 1; i <= totalUsers; i++) {
                address checkUser = idToAddress[i];
                Users storage u = User[checkUser];
                if (EnumerableSet.contains(leaderboardSet, checkUser) != true) {
                    if (u.roundToReferrals[currentRound] > maxAmount) {
                        maxAmount = u.roundToReferrals[currentRound];
                        foundWallet = checkUser;
                    }
                }
            }
            if (EnumerableSet.contains(leaderboardSet, foundWallet) != true) {
                EnumerableSet.add(leaderboardSet, foundWallet);
            }
            collected[l] = foundWallet;
        }
        return collected;
    }

    function cleanLeaderboard() public onlyOwner {
        address[] memory leaderboard = EnumerableSet.values(leaderboardSet);
        for (uint i = 0; i < leaderboard.length; i++) {
            EnumerableSet.remove(leaderboardSet, leaderboard[i]);
        }
    }

    function manualLeaderboard(address[] memory leaderboard) public onlyOwner {
        require(leaderboard.length == 10, "Wrong count");
        require(EnumerableSet.length(leaderboardSet) == 0, "Leaderboard filled");
        for (uint i = 0; i < leaderboard.length; i++) {
            EnumerableSet.add(leaderboardSet, leaderboard[i]);
        }
    }

    function claimToken() public {

        require(allowClaim == true, "Claim disabled");

        address _buyer = msg.sender;
        Users storage u = User[_buyer];
        uint256 _prevRound = currentRound - 1;

        require(u.id > 0, "Not Registered"); // Require User Registered
        require(u.roundToSlots[_prevRound] > 0, "No Slots"); // Require Slots count
        require(u.roundToClaimed[_prevRound] == 0, "Already Claimed"); // Claim allowed once per round

        uint256 claimAmount = (u.roundToSlots[_prevRound] * tokenBySlots / 10 ** 24);
        require((XTO.balanceOf(address(this)) >= claimAmount), "Insufficient balance");

        XTO.safeTransferFrom(address(this), _buyer, claimAmount);
        u.claimed += claimAmount;
        u.roundToClaimed[_prevRound] = claimAmount;

        emit claimReward(_buyer, claimAmount, _prevRound);

    }

    function claimLeaderBonus() public {

        address _user = msg.sender;
        uint256 _prevRound = currentRound - 1;
        Users storage u = User[_user];

        require(allowClaimBUSD == true, "Claim disabled");
        require (EnumerableSet.contains(leaderboardSet, _user) == true, "Not allowed");
        require(u.roundToClaimedBUSD[_prevRound] == 0, "Already claimed");

        address[] memory leaderBoard = EnumerableSet.values(leaderboardSet);
        uint userPlace = 0;
        for(uint i=0; i < leaderBoard.length; i++) {
            if (leaderBoard[i] == _user) userPlace = i;
        }

        uint _claimAmount = roundToLeaderboardVault[_prevRound] * leaderboardPlaces[userPlace] / 1000;
        u.roundToClaimedBUSD[_prevRound] = _claimAmount;

        BUSD.safeTransferFrom(address(this), _user, _claimAmount);

    }

    function addTokenToVault(uint256 _amount) public onlyOwner {
        nitroVault = 0;
        address _sender = msg.sender;
        require((XTO.balanceOf(_sender) >= _amount), "Insufficient balance");
        uint256 allowance = XTO.allowance(_sender, address(this));
        require(allowance >= _amount, "Not enough allowance");
        XTO.safeTransferFrom(_sender, address(this), _amount);
        nitroVault = _amount;
        roundToVault[currentRound] = nitroVault;
        tokenBySlots = roundToVault[currentRound] * 10 ** 24 / roundToAllSlots[currentRound];
        emit finishRound(currentRound, roundToAllSlots[currentRound], nitroVault, tokenBySlots);
        currentRound++;        
    }

    function addBUSDToVault(uint256 _amount, uint256 _round) public onlyOwner {
        require(roundToLeaderboardVault[_round] == 0, "Already set");
        leaderboardVault = 0;
        address _sender = msg.sender;
        require((BUSD.balanceOf(_sender) >= _amount), "Insufficient balance");
        uint256 allowance = BUSD.allowance(_sender, address(this));
        require(allowance >= _amount, "Not enough allowance");
        BUSD.safeTransferFrom(_sender, address(this), _amount);
        leaderboardVault = _amount;
        roundToLeaderboardVault[_round] = leaderboardVault;
    }

    function setRegisterStatus(bool _status) public onlyOwner {
        require(allowRegister != _status, "No action");
        allowRegister = _status;
    }

    function setBuyStatus(bool _status) public onlyOwner {
        require(allowBuy != _status, "No action");
        allowBuy = _status;
    }

    function setClaimStatus(bool _status) public onlyOwner {
        require(allowClaim != _status, "No action");
        allowClaim = _status;
    }

    function setClaimBUSDStatus(bool _status) public onlyOwner {
        require(allowClaimBUSD != _status, "No action");
        allowClaimBUSD = _status;
    }

    function setTimeLimit(uint _timeLimit) public onlyOwner {
        require(timeLimit != _timeLimit, "No action");
        require(_timeLimit >= 0, "Wrong data");
        timeLimit = _timeLimit;
    }

    function getSlotsByRound(address _user, uint _round) public view returns (uint256) {
        Users storage u = User[_user];
        return u.roundToSlots[_round];
    }

    function getClaimAmount(address _user) public view returns (uint256) {
        Users storage u = User[_user];
        uint256 _prevRound = currentRound - 1;
        uint256 claimAmount = (u.roundToSlots[_prevRound] * tokenBySlots / 10 ** 24) - u.roundToClaimed[_prevRound];
        return claimAmount;
    }

    function getClaimAmountByRound(address _user, uint _round) public view returns (uint256) {
        Users storage u = User[_user];
        uint256 claimAmount = (u.roundToSlots[_round] * tokenBySlots / 10 ** 24) - u.roundToClaimed[_round];
        return claimAmount;
    }

    function getClaimedByRound(address _user, uint _round) public view returns (uint256) {
        Users storage u = User[_user];
        return u.roundToClaimed[_round];
    }

    function getClaimedBUSDByRound(address _user, uint _round) public view returns (uint256) {
        Users storage u = User[_user];
        return u.roundToClaimedBUSD[_round];
    }

    function getClaimBUSDAmount(address _user) public view returns (uint256) {
        if (EnumerableSet.contains(leaderboardSet, _user) == false) return 0;
        uint256 _prevRound = currentRound - 1;
        address[] memory leaderBoard = EnumerableSet.values(leaderboardSet);
        uint userPlace = 0;
        for(uint i=0; i < leaderBoard.length; i++) {
            if (leaderBoard[i] == _user) userPlace = i;
        }
        uint _claimAmount = roundToLeaderboardVault[_prevRound] * leaderboardPlaces[userPlace] / 1000;
        return _claimAmount;
    }

    function getReferralsByRound(address _user, uint _round) public view returns(uint refCount) {
        Users storage u = User[_user];
        return u.roundToReferrals[_round];
    }

    function recoveryToken(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        uint tokenBalance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, tokenBalance);
    }
    function recoveryFunds() public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }

    receive() external payable {}


}