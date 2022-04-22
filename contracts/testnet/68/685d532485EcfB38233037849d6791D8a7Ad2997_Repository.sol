/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// File: libraries/ExternalNft.sol

pragma solidity ^0.8.0;

library ExternalNft {
    struct Nft {
        uint256 tokenId;
        string metadataUri;
        bool isUsed;
    }
}

// File: interfaces/IAllowance.sol


pragma solidity ^0.8.0;

abstract contract IAllowance {
    mapping(address => bool) public allowedOperators;

    modifier allowedOperator() {
        require(allowedOperators[msg.sender] == true, 'Caller is not allowed');
        _;
    }

    /**
     * @dev Adds address to a specific list and allows to call methods with
     * allowedOperator modifier
     */
    function setAllowance(address operator) external virtual;

    /**
     * @dev Removes address from storage and forbids calling methods with
     * allowedOperator modifier
     */
    function removeAllowance(address operator) external virtual;

    function _setAllowance(address _operator) internal {
        require(_operator != address(0), 'Address should not be empty');
        allowedOperators[_operator] = true;
    }

    function _removeAllowance(address _operator) internal {
        require(_operator != address(0), 'Address should not be empty');
        allowedOperators[_operator] = false;
    }
}

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

// File: interfaces/IExternalNftRepository.sol

pragma solidity ^0.8.0;




abstract contract IExternalNftRepository {
    using Counters for Counters.Counter;

    mapping(address => mapping(uint256 => ExternalNft.Nft)) public nft_addressToMap;
    mapping(uint256 => uint256) private nft_idToIndex;
    EnumerableSet.UintSet private nftIndexSet;
    Counters.Counter private nftLatestId;
    Counters.Counter private nftLatestIndex;
    mapping(address => uint256[]) private nft_indexesArray;

    /**
     * @dev Add NFT metadata uri to storage
     */
    function addNft(string memory _metadataUri, address _owner) external virtual;

    /**
     * @dev Returns token info by it's id for particular user
     */
    function getNft(uint256 _nftId, address _owner)
        external
        view
        virtual
        returns (ExternalNft.Nft memory);

    function _addNft(string memory _metadataUri, address _owner) internal {
        nftLatestId.increment();
        uint256 newNftId = nftLatestId.current();

        ExternalNft.Nft memory newNft = ExternalNft.Nft(newNftId, _metadataUri, false);

        EnumerableSet.add(nftIndexSet, newNftId);

        nft_addressToMap[_owner][newNftId] = newNft;

        nft_indexesArray[_owner].push(newNftId);
    }

    function _getNft(uint256 _nftId, address _owner)
        internal
        view
        returns (ExternalNft.Nft memory)
    {
        ExternalNft.Nft memory nft;

        if (!EnumerableSet.contains(nftIndexSet, _nftId)) {
            nft.tokenId = type(uint256).max;
            return nft;
        }

        nft = nft_addressToMap[_owner][_nftId];
        return nft;
    }

    /**
     * @dev Marks tokenId as already used.
     * protects of re-using the same tokenId in future for any user
     */
    function markNftAsUsed(uint256 _nftId, address _owner) external virtual;

    function _markNftAsUsed(uint256 _nftId, address _owner) internal {
        nft_addressToMap[_owner][_nftId].isUsed = true;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/utils/Multicall.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract Multicall {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// File: libraries/ScientistData.sol


pragma solidity ^0.8.0;

library ScientistData {
    struct Scientist {
        uint256 tokenId;
        address user;
        uint256 level;
        string tokenUri;
        bool onSale;
        uint256 price;
    }
}

// File: libraries/Enhancer.sol


pragma solidity ^0.8.0;

/**
 * @title Representation of enhancer options
 */
library CellEnhancer {
    /**
     * @dev Enhancer
     * @param id - enhancer id
     * @param typeId - enhancer type id
     * @param probability - chance of successful enhancement
     * @param basePrice - default price
     * @param baseCurrency - default currency
     * @param enhancersAmount - amount of existing enhancers
     */
    struct Enhancer {
        uint256 id;
        uint8 typeId;
        uint256 probability;
        uint256 basePrice;
        string name;
        address tokenAddress;
    }

    enum EnhancerType {
        UNKNOWN_ENHANCER,
        STAGE_ENHANCER,
        SPLIT_ENHANCER
    }

    function convertEnhancer(uint8 enhancerType) internal pure returns (EnhancerType) {
        if (enhancerType == 1) {
            return EnhancerType.STAGE_ENHANCER;
        } else if (enhancerType == 2) {
            return EnhancerType.SPLIT_ENHANCER;
        }

        return EnhancerType.UNKNOWN_ENHANCER;
    }
}

// File: interfaces/IEnhancerRepository.sol


pragma solidity ^0.8.0;



/**
 * @title Interface for interaction with particular cell
 */
abstract contract IEnhancerRepository {
    using SafeMath for uint256;
    CellEnhancer.Enhancer[] private availableEnhancers;

    struct enhancer {
        uint256 id;
        uint256 amount;
    }
    mapping(address => enhancer[]) internal ownedEnhancers;

    /**
     * @dev Adds available enhancers to storage
     */
    function addAvailableEnhancers(CellEnhancer.Enhancer memory _enhancer) external virtual;

    function _addAvailableEnhancers(CellEnhancer.Enhancer memory _enhancer) internal {
        uint256 _index = findEnhancerById(_enhancer.id);
        if (_index == type(uint256).max) {
            availableEnhancers.push(_enhancer);
        } else {
            availableEnhancers[_index] = _enhancer;
        }
    }

    /**
     * @dev Returns enhancer info by it's id
     */
    function getEnhancerInfo(uint256 _id) external view returns (CellEnhancer.Enhancer memory) {
        uint256 _index = findEnhancerById(_id);
        if (_index == type(uint256).max) {
            CellEnhancer.Enhancer memory _enhancer;
            _enhancer.id = type(uint256).max;
            return _enhancer;
        }
        return availableEnhancers[_index];
    }

    /**
     * @dev Increases amount of enhancers of particular user
     */
    function increaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external virtual;

    function _increaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) internal {
        for (uint256 i = 0; i < ownedEnhancers[_owner].length; i++) {
            if (ownedEnhancers[_owner][i].id == _id) {
                ownedEnhancers[_owner][i].amount = ownedEnhancers[_owner][i].amount.add(_amount);
                return;
            }
        }

        enhancer memory _enhancer = enhancer(_id, _amount);
        ownedEnhancers[_owner].push(_enhancer);
    }

    /**
     * @dev Decreases available user enhancers
     */
    function decreaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external virtual;

    function _decreaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) internal {
        uint256 index = type(uint256).max;
        for (uint256 i = 0; i < ownedEnhancers[_owner].length; i++) {
            if (ownedEnhancers[_owner][i].id == _id) {
                ownedEnhancers[_owner][i].amount = ownedEnhancers[_owner][i].amount.sub(_amount);
                index = i;
                break;
            }
        }

        if (index != type(uint256).max && ownedEnhancers[_owner][index].amount == 0) {
            ownedEnhancers[_owner][index] = ownedEnhancers[_owner][
                ownedEnhancers[_owner].length - 1
            ];
            ownedEnhancers[_owner].pop();
        }
    }

    /**
     * @dev Returns ids of all available enhancers for particular user
     */
    function getUserEnhancers(address _owner) external view returns (uint256[] memory) {
        uint256[] memory _ids = new uint256[](ownedEnhancers[_owner].length);
        for (uint256 i = 0; i < ownedEnhancers[_owner].length; i++) {
            _ids[i] = ownedEnhancers[_owner][i].id;
        }
        return _ids;
    }

    /**
     * @dev Returns types of all enhancers that are stored
     */
    function getEnhancerTypes() external view returns (uint8[] memory) {
        uint8[] memory _types = new uint8[](availableEnhancers.length);

        for (uint256 index = 0; index < availableEnhancers.length; index++) {
            _types[index] = availableEnhancers[index].typeId;
        }

        return _types;
    }

    /**
     * @dev Returns amount of enhancers by it's id
     * for particular user
     */
    function getEnhancersAmount(address _owner, uint256 id) external view returns (uint256) {
        for (uint256 index = 0; index < ownedEnhancers[_owner].length; index++) {
            if (ownedEnhancers[_owner][index].id == id) {
                return ownedEnhancers[_owner][index].amount;
            }
        }
        return 0;
    }

    function findEnhancerById(uint256 _id) private view returns (uint256) {
        for (uint256 index = 0; index < availableEnhancers.length; index++) {
            if (_id == availableEnhancers[index].id) {
                return index;
            }
        }
        return type(uint256).max;
    }

    /**
     * @dev Returns all stored enhancer
     * that are available
     */
    function getAllEnhancers() external view returns (CellEnhancer.Enhancer[] memory) {
        return availableEnhancers;
    }
}

// File: libraries/CellData.sol


pragma solidity ^0.8.0;

/**
 * @title Representation of cell with it fields
 */
library CellData {
    /**
     *  Represents the standart roles
     *  on which cell can be divided
     */
    enum Class {
        INIT,
        COMMON,
        SPLITTABLE_NANO,
        SPLITTABLE_MAD,
        FINISHED
    }

    function isSplittable(Class _class) internal pure returns (bool) {
        return _class == Class.SPLITTABLE_NANO || _class == Class.SPLITTABLE_MAD;
    }

    /**
     *  Represents the basic parameters that describes cell
     */
    struct Cell {
        uint256 tokenId;
        address user;
        Class class;
        uint256 stage;
        uint256 variant;
        uint256 nextEvolutionBlock;
        string tokenUri;
        bool onSale;
        uint256 price;
    }
}

// File: interfaces/ICellRepository.sol


pragma solidity ^0.8.0;








/**
 * @title Interface for interaction with particular cell
 */
abstract contract ICellRepository is Multicall {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // m_ are meta cells
    mapping(address => mapping(uint256 => CellData.Cell)) public m_addressToMap;

    // s_ are scientists
    mapping(address => mapping(uint256 => ScientistData.Scientist)) public s_addressToMap;

    mapping(uint256 => uint256) private m_idToIndex;
    mapping(uint256 => uint256) private s_idToIndex;

    EnumerableSet.UintSet private m_indexSet;
    EnumerableSet.UintSet private s_indexSet;

    Counters.Counter private m_latestIndex;
    Counters.Counter private s_latestIndex;

    mapping(address => uint256[]) private m_userIndexesArray;

    mapping(address => uint256[]) private s_userIndexesArray;

    /**
     * @dev Adds new cell to storage
     */
    function addMetaCell(CellData.Cell memory cell) external virtual;

    /**
     * @dev Adds new scientist to storage
     */
    function addScientist(ScientistData.Scientist memory _scientist) external virtual;

    function _addScientist(ScientistData.Scientist memory _scientist) internal {
        require(
            _getScientist(_scientist.user, _scientist.tokenId).user == address(0),
            'Token already exists'
        );

        s_latestIndex.increment();
        uint256 newIndex = s_latestIndex.current();

        EnumerableSet.add(s_indexSet, newIndex);
        s_idToIndex[_scientist.tokenId] = newIndex;
        s_addressToMap[_scientist.user][newIndex] = _scientist;

        s_userIndexesArray[_scientist.user].push(newIndex);
    }

    function _addMetaCell(CellData.Cell memory _cell) internal {
        require(_getMetaCell(_cell.user, _cell.tokenId).user == address(0), 'Token already exists');

        m_latestIndex.increment();
        uint256 newIndex = m_latestIndex.current();

        EnumerableSet.add(m_indexSet, newIndex);
        m_idToIndex[_cell.tokenId] = newIndex;
        m_addressToMap[_cell.user][newIndex] = _cell;

        m_userIndexesArray[_cell.user].push(newIndex);
    }

    /**
     * @dev Removes cell from storage
     * possible to call only for owner of cell
     */
    function removeMetaCell(uint256 _tokenId, address _owner) external virtual;

    function _removeMetaCell(address _user, uint256 _tokenId) internal {
        uint256 index = m_idToIndex[_tokenId];
        require(_getMetaCell(_user, _tokenId).user != address(0), 'Token not exists');

        require(m_addressToMap[_user][index].user == _user, 'User is no the owner');
        EnumerableSet.remove(m_indexSet, index);

        uint256 indexInArray = _getIndexInCellsArray(_user, index);
        require(indexInArray != type(uint256).max, 'No such index');
        m_userIndexesArray[_user][indexInArray] = m_userIndexesArray[_user][
            m_userIndexesArray[_user].length - 1
        ];
        m_userIndexesArray[_user].pop();
    }

    /**
     * @dev Removes scientist from storage
     * possible to call only for owner of scientist
     */
    function removeScientist(uint256 _tokenId, address _owner) external virtual;

    function _removeScientist(address _user, uint256 _tokenId) internal {
        uint256 index = s_idToIndex[_tokenId];
        require(_getScientist(_user, _tokenId).user != address(0), 'Token not exists');

        require(s_addressToMap[_user][index].user == _user, 'User is no the owner');
        EnumerableSet.remove(s_indexSet, index);

        // swap indexes in array
        uint256 indexInArray = _getIndexInScientistsArray(_user, index);
        require(indexInArray != type(uint256).max, 'No such index');
        s_userIndexesArray[_user][indexInArray] = s_userIndexesArray[_user][
            s_userIndexesArray[_user].length - 1
        ];
        s_userIndexesArray[_user].pop();
    }

    function _getIndexInCellsArray(address _user, uint256 _value) internal view returns (uint256) {
        for (uint256 i = 0; i < m_userIndexesArray[_user].length; i++) {
            if (m_userIndexesArray[_user][i] == _value) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function _getIndexInScientistsArray(address _user, uint256 _value)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < s_userIndexesArray[_user].length; i++) {
            if (s_userIndexesArray[_user][i] == _value) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @dev Returns meta cell id's for particular user
     */
    function getUserMetaCellsIndexes(address _user) external view returns (uint256[] memory) {
        return m_userIndexesArray[_user];
    }

    /**
     * @dev Returns scientists id's for particular user
     */
    function getUserScientistsIndexes(address _user) external view returns (uint256[] memory) {
        return s_userIndexesArray[_user];
    }

    /**
     * @dev Update existing scientist info
     * possible to call only for owner of scientist
     */
    function updateScientist(ScientistData.Scientist memory _scientist, address owner)
        external
        virtual;

    function _updateScientist(ScientistData.Scientist memory _scientist, address _owner) internal {
        ScientistData.Scientist memory scientist = _getScientist(_owner, _scientist.tokenId);
        require(scientist.user != address(0), 'Token not exists');

        scientist = _scientist;

        uint256 index = s_idToIndex[scientist.tokenId];
        s_addressToMap[_owner][index] = scientist;
    }

    /**
     * @dev Update existing cell
     * possible to call only for owner of cell
     */
    function updateMetaCell(CellData.Cell memory cell, address owner) external virtual;

    function _updateMetaCell(CellData.Cell memory _cell, address _owner) internal {
        CellData.Cell memory cell = _getMetaCell(_owner, _cell.tokenId);
        require(cell.user != address(0), 'Token not exists');

        cell = _cell;

        uint256 index = m_idToIndex[cell.tokenId];
        m_addressToMap[_owner][index] = cell;
    }

    /**
     * @dev Returns scientist by it's id for given address
     * will return address(0) if actual and given addresses do not match
     */
    function getScientist(uint256 _tokenId, address _owner)
        external
        view
        returns (ScientistData.Scientist memory)
    {
        return _getScientist(_owner, _tokenId);
    }

    /**
     * @dev Returns cell by it's id for given address
     * will return address(0) if actual and given addresses do not match
     */
    function getMetaCell(uint256 _tokenId, address _owner)
        external
        view
        returns (CellData.Cell memory)
    {
        return _getMetaCell(_owner, _tokenId);
    }

    function _getMetaCell(address _owner, uint256 _tokenId)
        internal
        view
        returns (CellData.Cell memory)
    {
        uint256 index = m_idToIndex[_tokenId];

        CellData.Cell memory cell;

        if (!EnumerableSet.contains(m_indexSet, index)) {
            cell.user = address(0);
            return cell;
        }

        require(m_addressToMap[_owner][index].user == _owner, 'User is not the owner');

        cell = m_addressToMap[_owner][index];
        return cell;
    }

    function _getScientist(address _owner, uint256 _tokenId)
        internal
        view
        returns (ScientistData.Scientist memory)
    {
        uint256 index = s_idToIndex[_tokenId];

        ScientistData.Scientist memory scientist;

        if (!EnumerableSet.contains(s_indexSet, index)) {
            scientist.user = address(0);
            return scientist;
        }

        require(s_addressToMap[_owner][index].user == _owner, 'User is not the owner');

        scientist = s_addressToMap[_owner][index];
        return scientist;
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

// File: Repository.sol


pragma solidity ^0.8.0;






contract Repository is
    ICellRepository,
    IEnhancerRepository,
    IExternalNftRepository,
    IAllowance,
    Ownable
{
    constructor(address owner) {
        require(owner != address(0), 'Address should not be empty');
        transferOwnership(owner);
        super._setAllowance(owner);
    }

    function addAvailableEnhancers(CellEnhancer.Enhancer memory _enhancer)
        external
        override
        allowedOperator
    {
        super._addAvailableEnhancers(_enhancer);
    }

    function setAllowance(address operator) external override allowedOperator {
        super._setAllowance(operator);
    }

    function removeAllowance(address operator) external override allowedOperator {
        super._removeAllowance(operator);
    }

    function addMetaCell(CellData.Cell memory _cell) external override allowedOperator {
        require(_cell.tokenId >= 0, 'Incorrect tokenId');
        super._addMetaCell(_cell);
    }

    function addScientist(ScientistData.Scientist memory _scientist)
        external
        override
        allowedOperator
    {
        require(_scientist.tokenId >= 0, 'Incorrect tokenId');
        super._addScientist(_scientist);
    }

    function addNft(string memory _metadataUri, address _owner) external override allowedOperator {
        super._addNft(_metadataUri, _owner);
    }

    function getNft(uint256 _nftId, address _owner)
        external
        view
        override
        returns (ExternalNft.Nft memory)
    {
        ExternalNft.Nft memory nft = super._getNft(_nftId, _owner);

        require(nft.tokenId != type(uint256).max, 'Nft not exists');

        return nft;
    }

    function markNftAsUsed(uint256 _nftId, address _owner) external override {
        super._markNftAsUsed(_nftId, _owner);
    }

    function removeMetaCell(uint256 _tokenId, address _owner) external override allowedOperator {
        require(_tokenId >= 0, 'Incorrect tokenId');
        super._removeMetaCell(_owner, _tokenId);
    }

    function removeScientist(uint256 _tokenId, address _owner) external override allowedOperator {
        require(_tokenId >= 0, 'Incorrect tokenId');
        super._removeScientist(_owner, _tokenId);
    }

    function updateMetaCell(CellData.Cell memory _cell, address _owner)
        external
        override
        allowedOperator
    {
        require(_cell.tokenId >= 0, 'Incorrect tokenId');
        super._updateMetaCell(_cell, _owner);
    }

    function updateScientist(ScientistData.Scientist memory _scientist, address _owner)
        external
        override
        allowedOperator
    {
        require(_scientist.tokenId >= 0, 'Incorrect tokenId');
        super._updateScientist(_scientist, _owner);
    }

    function increaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external override allowedOperator {
        super._increaseEnhancersAmount(_owner, _id, _amount);
    }

    function decreaseEnhancersAmount(
        address _owner,
        uint256 _id,
        uint256 _amount
    ) external override allowedOperator {
        super._decreaseEnhancersAmount(_owner, _id, _amount);
    }
}