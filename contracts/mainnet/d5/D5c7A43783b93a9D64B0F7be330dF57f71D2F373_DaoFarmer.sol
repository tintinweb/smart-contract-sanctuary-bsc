/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




contract Governable is Initializable {
    // bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    address public governor;

    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);

    /**
     * @dev Contract initializer.
     * called once by the factory at time of deployment
     */
    function __Governable_init_unchained(address governor_) virtual public initializer {
        governor = governor_;
        emit GovernorshipTransferred(address(0), governor);
    }

    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }
    
    modifier governance() {
        require(msg.sender == governor || msg.sender == _admin());
        _;
    }

    /**
     * @dev Allows the current governor to relinquish control of the contract.
     * @notice Renouncing to governorship will leave the contract without an governor.
     * It will not be possible to call the functions with the `governance`
     * modifier anymore.
     */
    function renounceGovernorship() public governance {
        emit GovernorshipTransferred(governor, address(0));
        governor = address(0);
    }

    /**
     * @dev Allows the current governor to transfer control of the contract to a newGovernor.
     * @param newGovernor The address to transfer governorship to.
     */
    function transferGovernorship(address newGovernor) public governance {
        _transferGovernorship(newGovernor);
    }

    /**
     * @dev Transfers control of the contract to a newGovernor.
     * @param newGovernor The address to transfer governorship to.
     */
    function _transferGovernorship(address newGovernor) internal {
        require(newGovernor != address(0));
        emit GovernorshipTransferred(governor, newGovernor);
        governor = newGovernor;
    }
}

contract Configurable is Governable {

    mapping (bytes32 => uint) internal config;
    
    function getConfig(bytes32 key) public view returns (uint) {
        return config[key];
    }
    function getConfig(bytes32 key, uint index) public view returns (uint) {
        return config[bytes32(uint(key) ^ index)];
    }
    function getConfig(bytes32 key, address addr) public view returns (uint) {
        return config[bytes32(uint(key) ^ uint(uint160(addr)))];
        
    }

    function _setConfig(bytes32 key, uint value) internal {
        if(config[key] != value)
            config[key] = value;
    }
    function _setConfig(bytes32 key, uint index, uint value) internal {
        _setConfig(bytes32(uint(key) ^ index), value);
    }
    function _setConfig(bytes32 key, address addr, uint value) internal {
        _setConfig(bytes32(uint(key) ^ uint(uint160(addr))), value);
    }
    
    function setConfig(bytes32 key, uint value) external governance {
        _setConfig(key, value);
    }
    function setConfig(bytes32 key, uint index, uint value) external governance {
        _setConfig(bytes32(uint(key) ^ index), value);
    }
    function setConfig(bytes32 key, address addr, uint value) public governance {
        _setConfig(bytes32(uint(key) ^ uint(uint160(addr))), value);
    }
}



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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}





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
library EnumerableSetUpgradeable {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}



/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}



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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}



/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    uint256[44] private __gap;
}

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal initializer {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return base;//super.tokenURI(tokenId); //tmp
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    uint256[46] private __gap;
}

//////////////////////////////////////////////////////////////////////////

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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


/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
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
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}


/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
    uint256[49] private __gap;
}

//////////////////////////////////////////////////////////////////////////


//contract FarmNFT is Initializable, ContextUpgradeSafe, ERC165UpgradeSafe, IERC721, IERC721Metadata, IERC721Enumerable, ERC721UpgradeSafe,Governable {
contract EquipNFT is ERC721URIStorageUpgradeable,ERC721EnumerableUpgradeable,Governable {
    
    uint256 public maxId;
    mapping (address => bool) public admins;
    string private _baseTokenURI;
    
    struct Item{
        uint itemType;
        uint value; 
    }
    
    struct Property {
        Item item1;
        Item item2;
        Item output;
        uint rare;
        uint totalDurability;
        uint costDurability;
        uint costPower;
        uint coolDown;
    }
    struct CurProperty {
        uint curDurability;
        uint lastTime;
    }
    
    Property public property;
    mapping (uint => CurProperty) public curPropertys;  //token id >curProperty
 /*   uint private constant DAOF = 0;
    uint private constant FOOD = 1;
    uint private constant WOOD = 2;
    uint private constant GOLD = 3;
    
    uint private constant STICK = 0;
    uint private constant ARROW = 1;
    uint private constant GUN = 2;
    uint private constant AXE = 3;
    uint private constant SAW = 4;
    uint private constant ESAW = 5;
    uint private constant PICK = 6;
    uint private constant RIG = 7;*/



    
    function __EquipNFT_init(address governor_,string memory name_, string memory symbol_,string memory baseURI_) external initializer {
		__Governable_init_unchained(governor_);
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
        __ERC721Enumerable_init_unchained();
        __EquipNFT_init_unchained(name_, symbol_,baseURI_);
        maxId=0;
    }


    function __EquipNFT_init_unchained(string memory name_, string memory symbol_,string memory baseURI_)  public governance {
        __ERC721_init_unchained(name_,symbol_);
        _baseTokenURI = baseURI_;
    }
    
 
      
    function setProperty(uint[3] calldata type_,uint[3] calldata value, uint rare,uint totalDurability,uint costDurability,uint costPower,uint coolDown)  public governance {
            property.item1.itemType = type_[0];
            property.item2.itemType = type_[1];
            property.output.itemType = type_[2];
            property.item1.value = value[0];
            property.item2.value = value[1];
            property.output.value = value[2];       
            property.rare = rare;
            property.totalDurability = totalDurability;
            property.costDurability = costDurability;    
            property.costPower = costPower; 
            property.coolDown = coolDown; 
    }
    
    
      
    
    function setAdmin(address admin_,bool isAdmin_)  public governance {
            admins[admin_] = isAdmin_;
    }
    
    function baseURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory){
        return _baseTokenURI;
    } 

    function setBaseURI(string memory baseURI_) public governance  {
        _baseTokenURI = baseURI_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
     function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //require(curPropertys[tokenId].curDurability >= property.totalDurability||admins[to],"Must full durability");
        super.transferFrom(from,to,tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //require(curPropertys[tokenId].curDurability >= property.totalDurability||admins[to],"Must full durability");
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        //require(curPropertys[tokenId].curDurability >= property.totalDurability|| admins[to],"Must full durability");
        super.safeTransferFrom(from, to, tokenId, _data);
    }
    
    
        /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || admins[spender] || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    
    
    function mint(address to,string memory uri) public returns (uint256 tokenId) {
        require((msg.sender == governor||admins[msg.sender]),"You do not have permission");
        maxId++;
        tokenId = maxId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId,uri);
        curPropertys[tokenId].curDurability = property.totalDurability;
    }

   function setDur(uint tokenId,uint curDur,bool updateLastTime) public {
       require((msg.sender == governor||admins[msg.sender]),"You do not have permission");
       curPropertys[tokenId].curDurability = curDur;
       if (updateLastTime)
            curPropertys[tokenId].lastTime = block.timestamp;
   }

   function addDur(uint tokenId,uint addDur_,bool updateLastTime) public {
       require((msg.sender == governor||admins[msg.sender]),"You do not have permission");
       curPropertys[tokenId].curDurability += addDur_;
       if (updateLastTime)
            curPropertys[tokenId].lastTime = block.timestamp;
   }    

    function costDur(uint tokenId,bool updateLastTime) public {
        require((msg.sender == governor||admins[msg.sender]),"You do not have permission");
        curPropertys[tokenId].curDurability -= property.costDurability;
        if (updateLastTime)
            curPropertys[tokenId].lastTime = block.timestamp;
    }

    function setDur(uint id,uint dur) public  {
         require((msg.sender == governor||admins[msg.sender]),"You do not have permission");
         curPropertys[id].curDurability = dur;
    }    

    
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721 Burn: caller is not owner nor approved");
        _burn(tokenId);
    }

  
    
    uint256[50] private __gap;    
}

contract GlobalInfo is Governable{
    
    mapping (address => bool) public admins;
    mapping(address => uint) public wlBuy; // white list buy  //address>buyValue
    mapping(address => mapping(uint => uint)) public openBuy; //address>itemType>buyValue
    
   
    
    function __GlobalInfo_init(address governor_) external initializer {
		__Governable_init_unchained(governor_);
	}
    
    modifier onlyAdmin(address who) {
        require(admins[who], "Not permission");
        _;
    }
    
    function setAdmin(address admin_,bool isAdmin_)  public governance {
            admins[admin_] = isAdmin_;
    }
    function setWlBuy(address who)  public onlyAdmin(msg.sender) {
            require(wlBuy[who]==0,"already bought");
            wlBuy[who] = 1;
    }

    function canWLBuy(address who)  public view returns (bool) {
            return wlBuy[who]==0;
    }
    
    function setOpenBuy(address who,uint item)  public onlyAdmin(msg.sender) {
            require(openBuy[who][item]==0,"already bought");
            openBuy[who][item] = 1;
    }

    function canOpenBuy(address who,uint item)  public view returns (bool) {
            return openBuy[who][item] == 0;
    }
        
    
}


interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);    
}

interface IUniswapV2Router02 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract AllowListNftPool is Governable{

    mapping(address => bool) public allowList;
    mapping(address => bool) public withdrawList;
    address public nftAddr;
    uint public nftTypeId; //NFT type ID, total 8 kind    
    address public currency;
    address public globalInfo;
    uint public begin;
    uint public span;
    uint public price;
    string public uri;
    uint public maxNftCount;
    uint public curNftCount;

    function __AllowListNftPool_init(address governor_, uint nftTypeId_, address nftToken_, uint maxNftCount_,uint begin_,uint span_,string memory  uri_,uint price_,address currency_, address globalInfo_) external initializer {
		__Governable_init_unchained(governor_);
		__AllowListNftPool_init_unchained(nftTypeId_,nftToken_, maxNftCount_,begin_,span_,uri_,price_,currency_,globalInfo_);
	}
	
    function __AllowListNftPool_init_unchained( uint nftTypeId_, address nftToken_,uint maxNftCount_,uint begin_,uint span_,string memory  uri_,uint price_,address currency_,address globalInfo_) public governance {
        nftTypeId = nftTypeId_;
        nftAddr = nftToken_;
        currency = currency_;
        begin = begin_;
        span = span_;
        uri = uri_;
        price = price_;
        maxNftCount= maxNftCount_;
        globalInfo = globalInfo_ ;
    }    


    function setNftToken(address token_,string memory  uri_) external governance{
        nftAddr = token_;
        uri = uri_;
    }
    
    function setCurrency(address currency_) external governance{
        currency = currency_;
    }

    function setPrice(uint price_) external governance{
        price = price_;
    }


    function setGlobalInfo(address globalInfo_) external governance{
        globalInfo = globalInfo_;
    }

    function setmaxNftCount(uint maxNftCount_) external governance{
        maxNftCount= maxNftCount_;
    }
    
    function setTime(uint begin_,uint span_) external governance{
        begin = begin_;
        span = span_;
    }

    function addAllowList(address [] calldata dsts) external governance {
        for(uint i=0; i<dsts.length; i++)
            allowList[dsts[i]] = true;
    }
    
  

    function buy() external payable  {
        require(block.timestamp >=begin,'Not begin');
        require(block.timestamp <=begin+span,'end');
        require(allowList[msg.sender],"Not allow");
        require(!withdrawList[msg.sender],"already withdraw!");
        //require(msg.value>=price,"less BNB");
        require(GlobalInfo(globalInfo).canWLBuy(msg.sender),"already buy");
        curNftCount += 1;
        require(curNftCount<=maxNftCount,"no NFT");
        TransferHelper.safeTransferFrom(currency, msg.sender, address(this), price);
        EquipNFT(nftAddr).mint(msg.sender,uri);
        withdrawList[msg.sender] = true;
        GlobalInfo(globalInfo).setWlBuy(msg.sender);
        emit Buy(msg.sender, nftAddr,block.timestamp);
        
    }
    
    
    event Buy(address indexed to, address nftAddr, uint256 time);
    
    function withdrawETH(address payable _dst) external governance {
        _dst.transfer(address(this).balance);
    }

    function rescueTokens(address _token, address _dst) public governance {
        uint balance = IERC20(_token).balanceOf(address(this));
        TransferHelper.safeTransferFrom(_token,address(this),_dst,balance);
    }
    
    function withdrawToken(address _dst) external governance {
        rescueTokens(address(currency), _dst);
    }

    function withdrawToken() external governance {
        rescueTokens(address(currency), msg.sender);
    }

}

contract NftPool is Governable{

    mapping(address => bool) public withdrawList;
    address public nftAddr;   //NFT address
    uint public nftTypeId; //NFT type ID, total 8 kind
    address public currency;    
    address public globalInfo;
    uint public begin;
    uint public span;
    uint public price;
    string public uri;
    uint public maxNftCount;
    uint public curNftCount;
    function __NftPool_init(address governor_, uint nftTypeId_,address nftToken_, uint maxNftCount_,uint begin_, uint span_, string memory  uri_,uint price_,address currency_,address globalInfo_) external initializer {
		__Governable_init_unchained(governor_);
		__NftPool_init_unchained(nftTypeId_,nftToken_,maxNftCount_, begin_, span_, uri_,price_,currency_,globalInfo_);
	}
	
    function __NftPool_init_unchained(uint nftTypeId_,address nftToken_, uint maxNftCount_,uint begin_,uint span_, string memory  uri_,uint price_,address currency_,address globalInfo_) public governance {
        nftTypeId = nftTypeId_;
        nftAddr = nftToken_;
        currency = currency_;
        begin = begin_;
        span =span_;
        uri = uri_;
        price = price_;
        maxNftCount = maxNftCount_;
        globalInfo = globalInfo_ ;
    }    


    function setNftToken(address token_,string memory  uri_) external governance{
        nftAddr = token_;
        uri = uri_;
    }

    function setCurrency(address currency_) external governance{
        currency = currency_;
    }

    function setPrice(uint price_) external governance{
        price = price_;
    }
   
    
    function setGlobalInfo(address globalInfo_) external governance{
        globalInfo = globalInfo_;
    }
    
     function setmaxNftCount(uint maxNftCount_) external governance{
        maxNftCount= maxNftCount_;
    }

    function setTime(uint begin_,uint span_) external governance{
        begin = begin_;
        span = span_;
    }

    function buy() external payable  {
        require(block.timestamp >=begin,'Not begin');
        require(block.timestamp <=begin+span,'end');
        require(!withdrawList[msg.sender],"already withdraw!");
        //require(msg.value>=price,"less BNB");
        require(GlobalInfo(globalInfo).canOpenBuy(msg.sender,nftTypeId),"already buy");
        curNftCount += 1;
        require(curNftCount<=maxNftCount,"no NFT");
        TransferHelper.safeTransferFrom(currency, msg.sender, address(this), price);
        EquipNFT(nftAddr).mint(msg.sender,uri);
        withdrawList[msg.sender] = true;
        GlobalInfo(globalInfo).setOpenBuy(msg.sender,nftTypeId);
        emit Buy(msg.sender,nftAddr,block.timestamp);
        
    }

    
    
    event Buy(address indexed to,address nftAddr, uint256 time);
    
    function withdrawETH(address payable _dst) external governance {
        _dst.transfer(address(this).balance);
    }

    function rescueTokens(address _token, address _dst) public governance {
        uint balance = IERC20(_token).balanceOf(address(this));
        TransferHelper.safeTransferFrom(_token,address(this),_dst,balance);
    }
    
    function withdrawToken(address _dst) external governance {
        rescueTokens(address(currency), _dst);
    }

    function withdrawToken() external governance {
        rescueTokens(address(currency), msg.sender);
    }

}


contract NftStore is Governable{   //buy with BUSD
    address public currency;    
    uint public begin;
    uint public span;
    address daoFarmer;
    address routerAddr; // = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // pancake BSC 
    
    uint[4] public itemPricesEmas;
    uint public lastUpdateEmaTime;
    uint public maxNft;
    uint public curNft;
    uint public emaPeriod;

    
    mapping(uint => uint) public maxNfts; //Nft index=>maxNfts
    mapping(uint => uint) public curNfts; //Nft index=>curNfts
    
    mapping(address => bool) public admAddrs;

    mapping(uint => uint) public nftRewardDaofs; //Nft index=>reward daof vol
    uint public discount; //?%
    
    function __NftStore_init(address governor_, address daoFarmer_,uint begin_, uint span_,address currency_,address routerAddr_) external initializer {
		__Governable_init_unchained(governor_);
        emaPeriod = 86400;
		__NftStore_init_unchained(daoFarmer_, begin_, span_, currency_,routerAddr_);
	}
	
    function __NftStore_init_unchained(address daoFarmer_,uint begin_, uint span_,address currency_,address routerAddr_) public governance {
        daoFarmer = daoFarmer_; 
        currency = currency_;
        begin = begin_;
        span =span_;
        routerAddr = routerAddr_;
    }

    function setadm(address adm_,bool isAdm) public governance {
         admAddrs[adm_] = isAdm;
    }

    function setDiscount(uint discount_) public governance {
         discount = discount_;
    }


    function setMaxNft(uint maxNft_,uint[] calldata maxNfts_) public  {
         require(admAddrs[msg.sender]||governor==msg.sender,"No permission");
         maxNft = maxNft_;
         uint len = maxNfts_.length;
         for (uint i=0;i<len;i++){
            maxNfts[i] = maxNfts_[i];
         }
    }

    function setNftRewardDaofs(uint[] calldata nftIndex,uint[] calldata nftDaofs) public  {
         require(admAddrs[msg.sender]||governor==msg.sender,"No permission");
         uint len = nftIndex.length;
         require(len==nftDaofs.length,"nft num != reward dao  num"); 
         for (uint i=0;i<len;i++){
            nftRewardDaofs[nftIndex[i]] = nftDaofs[i];
         }
    }


    
    function setEmaPeriod(uint emaPeriod_) public  {
         require(admAddrs[msg.sender]||governor==msg.sender,"No permission");
         emaPeriod = emaPeriod_;
    }
    
    function calcEma(uint256 emaPre, uint256 value, uint256 timeSpan, uint256 period) public pure returns(uint256) {
        if (timeSpan == 0)
            return emaPre;
        if(timeSpan > period/2)
            timeSpan = period/2;
        return (emaPre*(period-timeSpan)+value*timeSpan)/period;
    }


    function updateItemEmaPrices() private {
        if (lastUpdateEmaTime>=block.timestamp)
            return;
        /*uint[4] memory prices = getItemPrices();
        for (uint i=0;i<4;i++){
            itemPricesEmas[i] = calcEma(itemPricesEmas[i],prices[i],block.timestamp-lastUpdateEmaTime,3emaPeriod600);
        }*/
        itemPricesEmas = getItemEmaPrices();
        lastUpdateEmaTime = block.timestamp;
    }

    function getItemEmaPrices() public view returns(uint[4] memory){ //four item ema price
        if (lastUpdateEmaTime == block.timestamp){
            return itemPricesEmas;
        }
        uint[4] memory emas;
        uint[4] memory prices = getItemPrices();
        for (uint i=0;i<4;i++){
            emas[i] = calcEma(itemPricesEmas[i],prices[i],block.timestamp-lastUpdateEmaTime,emaPeriod);
        }
        return emas;
    }


    function getItemPrices() public view returns(uint[4] memory){  //four item price
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddr);
        DaoFarmer df = DaoFarmer(daoFarmer);
        uint[4] memory prices;
        address[] memory  path = new address[](2);
        path[1] = currency;
        for (uint i=0;i<4;i++){
            path[0] = df.ercList(i);
            prices[i] = router.getAmountsOut(1 ether, path)[path.length-1];
        }
        return prices;
    }


    function getPropPrice(uint propID) public view returns(uint){  //prop price 
        DaoFarmer df = DaoFarmer(daoFarmer);
        EquipNFT prop = EquipNFT(df.nftList(propID));
        EquipNFT.Item memory item1;
        EquipNFT.Item memory item2;
        uint totalDurability;
        (item1,item2,,,totalDurability,,,)=prop.property();
        uint value1 = item1.value;
        uint value2 = item2.value;
        uint[4] memory prices = getItemPrices();
        uint[4] memory emas = getItemEmaPrices();
        uint price1 = prices[item1.itemType]>emas[item1.itemType]?prices[item1.itemType]:emas[item1.itemType];
        uint price2 = prices[item2.itemType]>emas[item2.itemType]?prices[item2.itemType]:emas[item2.itemType];
        return (price1*value1/(1 ether) + price2*value2/(1 ether))*discount/100;
    }

    function getPrice(address[] memory path) public view returns(uint amt){
        require(path.length > 1, "path >=2");
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddr);
        amt = router.getAmountsOut(1 ether, path)[path.length-1];
    }

    function buy(uint propID) external  returns(uint tokenId) {
        require(block.timestamp >=begin,'Not begin');
        require(block.timestamp <=begin+span,'end');
        curNft++;
        require(curNft<=maxNft,'total sold out!');
        curNfts[propID]++;
        require(curNfts[propID]<=maxNfts[propID],'sold out!');
        DaoFarmer df = DaoFarmer(daoFarmer);
        EquipNFT prop = EquipNFT(df.nftList(propID));
        uint amt = getPropPrice(propID);
        updateItemEmaPrices();
        TransferHelper.safeTransferFrom(currency, msg.sender, df.eco(), amt*6/100);
        TransferHelper.safeTransferFrom(currency, msg.sender, df.vault(), amt*94/100);
        tokenId = prop.mint(msg.sender,"");
        df.addPowerByNewEquip(msg.sender,propID);
        //reward daof
        if (nftRewardDaofs[propID]>0)
            TransferHelper.safeTransferFrom(df.ercList(0), df.mine(),msg.sender,nftRewardDaofs[propID]);
        emit Buy(msg.sender,df.nftList(propID),tokenId,block.timestamp);
    }
    
    event Buy(address indexed to,address nftAddr,uint tokenId, uint256 time);


    
    function withdrawETH(address payable _dst) external governance {
        _dst.transfer(address(this).balance);
    }

    function rescueTokens(address _token, address _dst) public governance {
        uint balance = IERC20(_token).balanceOf(address(this));
        TransferHelper.safeTransferFrom(_token,address(this),_dst,balance);
    }
    
    function withdrawToken(address _dst) external governance {
        rescueTokens(address(currency), _dst);
    }

    function withdrawToken() external governance {
        rescueTokens(address(currency), msg.sender);
    }

}



contract NftExchangeNftOrERC20 is Governable,ContextUpgradeable,IERC721ReceiverUpgradeable {    // src NFT exchange des NFT  or des  erc20 only one NFT

    address internal constant BurnAddress   = 0x000000000000000000000000000000000000dEaD;
    uint public begin;
    uint public end;
    address public mine;
    mapping(address => mapping(uint256 => uint256)) public NftSrcId2PackIds;//NFTtoken address => token id =>PackId
    //uint[] public allNftId2TypeId;  //token id =>typeId
    //TypeID
    //1.Stick    Nft 0
    //2.Axe      Nft 3   
    //3.Mattock  Nft 6
    //4.Meat Resource Package  erc 1
    //5.Wood Resource Package  erc 2
    //6.Gold Resource Package  erc 3
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    mapping(uint => EnumerableSetUpgradeable.UintSet) private packId2ItemIds;  //PackId =>item id set
    /*
    type ID        items
    1              1
    2              2
    3              3
    4              5 6
    5              4 7
    6              4 8
    */

    struct SToken {
        uint tokenType; //0 None 1 erc20  2 erc721 NFT
        address token;
        uint  volume;
    }
    mapping(uint => SToken) public items; //itemId=>item
    //items:
    //1. NFT   stickAddr 1    // 1.Stick    Nft 0
    //2. NFT   AxeAddr   1    // 2.Axe      Nft 3   
    //3. NFT   PICKAddr  1    // 3.Mattock  Nft 6
    //4. ERC20 DAOFAddr  2  
    //5. ERC20 DAOFAddr  3  
    //6. ERC20 DFMAddr   1000  
    //7. ERC20 DFWAddr   500  
    //8. ERC20 DFGAddr   500  
    
    
    //4.Meat Resource Package  erc 1
    //5.Wood Resource Package  erc 2
    //6.Gold Resource Package  erc 3
    //meat:3DAOF+1000DFM
    //wood:2DAOF+500DFW
    //gold:2DAOF+500DFG

   function __NftExchangeNftOrERC20_init(address governor_) external initializer {
		__Governable_init_unchained(governor_);
        __Context_init_unchained();
    }

    function __NftExchangeNftOrERC20_init_unchained()  public governance{
    }
    
/*    function supportsInterface(bytes4 interfaceId) external pure override  returns (bool){

            //return interfaceId == IERC1155ReceiverUpgradeable.onERC1155Received.selector;
            return super.supportsInterface(interfaceId);
            //interfaceId == type(IERC1155Upgradeable).interfaceId ||
            //interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            //super.supportsInterface(interfaceId);
            //return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 
    }*/
 
    function setMine(address mine_)  public governance{
        mine = mine_;
    }

    function setNftSrcId2PackIds(address NftSrc_,uint[] calldata tokenId,uint[] calldata packId)  public governance{
        uint len = tokenId.length;
        require(len==packId.length,"tokenId num != typeId num");
        for (uint i=0;i<len;i++){
            NftSrcId2PackIds[NftSrc_][tokenId[i]] = packId[i];
        }
    }

    function setItems(uint[] calldata itemIds_,SToken[] calldata items_)  public governance{
        uint len = itemIds_.length;
        require(len==items_.length,"itemid num != item num");
        for (uint i=0;i<len;i++){
            items[itemIds_[i]] = items_[i];    
        }
    }

    function setPackId2ItemIds(uint packId_,uint[] memory items_)  public governance{
        uint len = items_.length;
        for (uint i=0;i<len;i++){
            packId2ItemIds[packId_].add(items_[i]);
        }
    }


 
    function setTime(uint begin_,uint end_) public governance{
        begin = begin_;
        end = end_;
    }

    function getNftTokenIds(address NFT_,address account) public view returns(uint[] memory ids){
        uint n = EquipNFT(NFT_).balanceOf(account);
        ids = new uint[](n);
        for (uint i=0;i<n;i++){
            ids[i] = EquipNFT(NFT_).tokenOfOwnerByIndex(account,i);
        }
    } 

    function nftExchange(address nft) public{
        require(block.timestamp>=begin,"Not start");
        require(block.timestamp<=end,"exchange end");
        uint[] memory ids =  getNftTokenIds(nft,msg.sender);
        uint idCount = ids.length;
        for (uint i = 0;i<idCount;i++){
            uint packId = NftSrcId2PackIds[nft][ids[i]];
            uint itemCount = packId2ItemIds[packId].length();
            if (packId==0)
                continue;
            EquipNFT(nft).safeTransferFrom(msg.sender,BurnAddress,ids[i]);
            for (uint j=0;j<itemCount;j++){
                uint itemId = packId2ItemIds[packId].at(j);
                SToken memory st = items[itemId];
                if (st.tokenType == 1){ // erc20
                    TransferHelper.safeTransferFrom(st.token,mine,msg.sender,st.volume);
                }
                else if(st.tokenType == 2){ //NFT
                    uint vol = st.volume;
                    for (uint k=0;k<vol;k++){
                        EquipNFT(st.token).mint(msg.sender,"");
                    }
                }

            }
        }
        emit NftExchange(nft,ids,msg.sender);
    }
    event  NftExchange(address nft,uint[] tokenIds,address account);

    
    function withdrawTokens(address _token, address _dst) public governance {
        uint balance = IERC20(_token).balanceOf(address(this));
        TransferHelper.safeTransfer(_token,_dst,balance);
    }
    
    
    function withdrawETH(address payable _dst) external governance {
        _dst.transfer(address(this).balance);
    }
    

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}


contract DaoFarmer is Configurable,IERC721ReceiverUpgradeable,AccessControlEnumerableUpgradeable {
    uint private constant DAOF = 0;
    uint private constant FOOD = 1;
    uint private constant WOOD = 2;
    uint private constant GOLD = 3;
    
    uint private constant STICK = 0;
    uint private constant ARROW = 1;
    uint private constant GUN = 2;
    uint private constant AXE = 3;
    uint private constant SAW = 4;
    uint private constant ESAW = 5;
    uint private constant PICK = 6;
    uint private constant RIG = 7;
     
    address public constant BurnAddress   = 0x000000000000000000000000000000000000dEaD;
    bytes32 public constant POWER_ROLE = keccak256("POWER_ROLE");
    
    
    uint public maxPower;
    mapping(address => uint) private powers;   //address>power
    
    address[4] public ercList;   //ERCs address
    address[8] public nftList;   //NFTs address
    
    uint public begin;
    uint public span;
    
    address public vault;
    address public eco;
    address public mine;

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(address => EnumerableSetUpgradeable.UintSet) private stakeEquip; 
    mapping (uint =>mapping(address =>uint)) public poolStakes;//poolID=>address=>value stakeDAOF
    uint public stakeDAOFvol;

    //auto farm
    struct NftAuto {
        uint    startTime;
        uint    lastClaimTime;
        uint    totalReward;
    }

/*    struct NftInfo{
        uint costPower;
        uint coolDown;
        uint costDurability;
        uint curDurability;
        uint lastTime;
        uint times;
        address erc1;
        uint fee;
        uint realValue;
        uint tecFee;
        address recomm;
    }*/

    struct RecommInfo{
        uint invitedNum;       //invited num
        uint[4] inviteRewardAmt;  //total reward DAOF
    }


    mapping(address => EnumerableSetUpgradeable.UintSet) private stakeEquipAuto; 
    uint public medalDAOFvol;
    mapping(address => uint) public medalDAOFs; //account =>daofVol   medal
    mapping(address => address) public recommenders; //account =>Recommenders    account's recommender
    mapping(address => RecommInfo) public recommInfos; //recommender =>recommInfo
    mapping(uint =>mapping(uint =>NftAuto)) public nftAutos; //Nft propId =>Nft tokenID =>NftAuto  
    address public tecSev;
    mapping (uint =>mapping(address =>uint)) public poolStakeEndTime; //poolID=>address=>takeDAOFendTime;
    mapping(address => uint) public farmAutoNum;  //autoFarm times

 
    function recommInfo(address account) public view returns(uint invitedNum,uint[4] memory inviteRewardAmt){
        RecommInfo memory ri = recommInfos[account];
        invitedNum = ri.invitedNum;
        inviteRewardAmt = ri.inviteRewardAmt;
    }


    function medal() public  {
        uint medalDaofV = medalDAOFs[msg.sender];
        require(medalDaofV<medalDAOFvol,"exist medal");
        uint realV =  medalDAOFvol - medalDaofV;
        address erc1 = ercList[DAOF];
        TransferHelper.safeTransferFrom(erc1, msg.sender,BurnAddress,realV);
        medalDAOFs[msg.sender] = medalDAOFvol;
    }

    function setRecommender(address recomm) public {
        require(recommenders[msg.sender]==address(0),"exist recommender");
        require(medalDAOFs[recomm]>=medalDAOFvol,"no medal");
        require(recommenders[recomm]!=msg.sender,"loop recommender");
        recommenders[msg.sender] = recomm;
        recommInfos[recomm].invitedNum +=1;
    }



    function farmAuto(uint propId,uint tokenId) public  {
        DaoFarmerLib.farmAuto(nftAutos,recommInfos,poolStakeEndTime,propId,tokenId);
        farmAutoNum[msg.sender] += 1;
/*        EquipNFT prop = EquipNFT(nftList[propId]);
        EquipNFT.Item memory item1;
        NftInfo memory nftInfo;
        farmAutoNum[msg.sender] += 1;
        (,,item1,,,nftInfo.costDurability,nftInfo.costPower,nftInfo.coolDown)=prop.property();
        (nftInfo.curDurability,nftInfo.lastTime) = prop.curPropertys(tokenId);
        require(block.timestamp-nftInfo.lastTime >nftInfo.coolDown,"cooling down");
        nftInfo.times = 48*60*60/nftInfo.coolDown;
        prop.costDur(tokenId,true);
        prop.setDur(tokenId,nftInfo.curDurability - nftInfo.costDurability*nftInfo.times);
        uint meatVol = nftInfo.costPower*nftInfo.times*1e18/5;
        TransferHelper.safeTransferFrom(ercList[FOOD], msg.sender, BurnAddress, meatVol);


        nftInfo.erc1 = ercList[item1.itemType];
        uint value1 = item1.value*nftInfo.times;
        if (poolStakes[item1.itemType][msg.sender]>=stakeDAOFvol){ //stake
            poolStakeEndTime[item1.itemType][msg.sender] = block.timestamp+48*60*60;
            value1 = value1*106/100;
        }
        nftInfo.fee =value1*4/100;
        nftInfo.realValue = value1 - 2*nftInfo.fee;  //92%


        TransferHelper.safeTransferFrom(nftInfo.erc1, mine, vault, nftInfo.fee);
        TransferHelper.safeTransferFrom(nftInfo.erc1, mine, eco, nftInfo.fee);

        //no recommender 6.5% tecsev
        //recommender 4% ,  1% tecsev
        nftInfo.recomm = recommenders[msg.sender];
        if (nftInfo.recomm == address(0)){
            nftInfo.tecFee = nftInfo.realValue*65/1000;
            TransferHelper.safeTransferFrom(nftInfo.erc1, mine, tecSev, nftInfo.tecFee);
            nftInfo.realValue = nftInfo.realValue - nftInfo.tecFee;
            nftAutos[propId][tokenId] = NftAuto(block.timestamp,block.timestamp,nftInfo.realValue);
        }
        else{
            nftInfo.tecFee = nftInfo.realValue*10/1000;
            TransferHelper.safeTransferFrom(nftInfo.erc1, mine, tecSev, nftInfo.tecFee);
            recommInfos[nftInfo.recomm].inviteRewardAmt[item1.itemType] += nftInfo.tecFee*4;
            TransferHelper.safeTransferFrom(nftInfo.erc1, mine, nftInfo.recomm, nftInfo.tecFee*4);
            nftInfo.realValue = nftInfo.realValue - nftInfo.tecFee*5;
            nftAutos[propId][tokenId] = NftAuto(block.timestamp,block.timestamp,nftInfo.realValue);
        }
        if (!EquipisAccountStakeAuto(msg.sender,propId,tokenId)){
            require(getStakeAutoCount(msg.sender)<6,"overflow 6 stake equip");
            prop.safeTransferFrom(msg.sender,address(this),tokenId);
            addStakeAuto(msg.sender,propId,tokenId);
        }
        emit FarmAuto(msg.sender,nftList[propId],tokenId,nftInfo.erc1,nftInfo.realValue,block.timestamp);  */
    }
    //event FarmAuto(address account,address nft,uint id,address erc20,uint value,uint time);

    function earnAuto(address account,uint propId,uint tokenId) public view returns(uint ercIndex,uint earn,uint enableClaim){
        require(EquipisAccountStakeAuto(account,propId,tokenId),"You not stake the equip");
        EquipNFT prop = EquipNFT(nftList[propId]);
        EquipNFT.Item memory item1;
        (,,item1,,,,,)=prop.property();
        ercIndex = item1.itemType;
        NftAuto memory nftAuto = nftAutos[propId][tokenId];
        if (nftAuto.lastClaimTime<nftAuto.startTime+48*60*60){
            earn = nftAuto.totalReward*(nftAuto.startTime+48*60*60-nftAuto.lastClaimTime)/(48*60*60);
            if (block.timestamp>nftAuto.startTime+48*60*60){
                enableClaim = earn;
            }else{
                enableClaim = nftAuto.totalReward*(block.timestamp-nftAuto.lastClaimTime)/(48*60*60);
            }
        }else{
            earn = 0;
            enableClaim = 0;
        }
    }

    function claimFarmAuto(uint propId,uint tokenId) public{
        (uint ercIndex,,uint enableClaim) = earnAuto(msg.sender,propId,tokenId);
        address erc1 = ercList[ercIndex];
        TransferHelper.safeTransferFrom(erc1, mine, msg.sender, enableClaim);
        nftAutos[propId][tokenId].lastClaimTime = block.timestamp;
        emit ClaimFarmAuto(propId,tokenId,enableClaim);
    }
    event ClaimFarmAuto(uint propId,uint tokenId,uint vol);


    function claimFarmAutoAllAType(uint ercIndex) external {  //claim meat 1, or wood
        DaoFarmerLib.claimFarmAutoAllAType(nftAutos, ercIndex);
        //(uint[] memory propTypes,uint[] memory ids) =  getAllStakeAuto(msg.sender);
        //uint n = propTypes.length;
        //uint[] memory vols =new uint[](n);
        //uint totalVol = 0;
        //uint realN=0;
        //for (uint i=0;i<n;i++){
        //    if (propTypeIsOutErc(propTypes[i],ercIndex)){
        //        (,,uint enableClaim) = earnAuto(msg.sender,propTypes[i],ids[i]);
        //        if (enableClaim>0){
        //            vols[i] = enableClaim;
        //            totalVol += enableClaim;
        //            realN++;
        //            nftAutos[propTypes[i]][ids[i]].lastClaimTime = block.timestamp;
        //        }
        //    }
        //}
        //uint[] memory propIdsRet = new uint[](realN);
        //uint[] memory idsRet = new uint[](realN);
        //uint[] memory volsRet =new uint[](realN);
        //uint index=0;
        //for (uint i=0;i<n;i++){
        //    if (vols[i]>0){
        //        propIdsRet[index] = propTypes[i];
        //        idsRet[index] = ids[i];
        //        volsRet[index] = vols[i];
        //        index++;
        //    }
        //}
        //address erc1 = ercList[ercIndex];
        //TransferHelper.safeTransferFrom(erc1, mine, msg.sender, totalVol);
        //emit ClaimFarmAutoAllAType(ercIndex,totalVol,propIdsRet,idsRet,volsRet);
    }
    //event ClaimFarmAutoAllAType(uint ercIndex,uint totalVol,uint[] propIds,uint[] tokenIds,uint[] vols);

    function propTypeIsOutErc(uint propType,uint ercIndex) public pure returns(bool) {
        if (ercIndex==FOOD) {
            if (propType<=GUN)
                return true;
            else
                return false;
        }else if (ercIndex==WOOD) {
            if ((propType>=AXE)&&(propType<=ESAW))
                return true;
            else
                return false;
        }else if (ercIndex==GOLD) {
            if ((propType>=PICK)&&(propType<=RIG))
                return true;
            else
                return false;
        }else
        return false;

    }


    function withdrawPropAuto(uint propId,uint tokenId) public  {
        require(EquipisAccountStakeAuto(msg.sender,propId,tokenId),"You not stake the equip");
        claimFarmAuto(propId,tokenId);
        EquipNFT prop = EquipNFT(nftList[propId]);
        uint coolDown;
        uint lastTime;
        uint totalDurability;
        uint curDurability;
        (,,,,totalDurability,,,coolDown)=prop.property();
        (curDurability,lastTime) = prop.curPropertys(tokenId);

        NftAuto memory nftAuto = nftAutos[propId][tokenId];
        require(block.timestamp-nftAuto.startTime > (48*60*60),"cooling down");
        require(totalDurability<=curDurability,"Durability is not full");
        removeStakeAuto(msg.sender,propId,tokenId);
        prop.safeTransferFrom(address(this),msg.sender,tokenId);
        emit WithdrawPropAuto(msg.sender,nftList[propId],tokenId,block.timestamp);  
    }
    event WithdrawPropAuto(address account,address nft,uint id,uint time);

    function addStakeAuto(address account,uint propType,uint id) public {
           require(msg.sender == address(this),"No auth") ;
           stakeEquipAuto[account].add(hl2u(propType,id));
    }

    function removeStakeAuto(address account,uint propType,uint id) internal {
           stakeEquipAuto[account].remove(hl2u(propType,id));
    }

    function EquipisAccountStakeAuto(address account,uint propType,uint id) public view returns(bool){
        uint typeAndId = hl2u(propType,id);
        return stakeEquipAuto[account].contains(typeAndId);
    }

    function getStakeAutoCount(address account) public view returns(uint){
        return stakeEquipAuto[account].length();
    }
 
     function getStakeAutoByIndex(address account,uint index) public view returns(uint propType,uint id){
        (propType,id) = u2hl(stakeEquipAuto[account].at(index));
    }

    function getAllStakeAuto(address account) public view returns(uint[] memory propType,uint[] memory id){
        uint n = stakeEquipAuto[account].length();
        propType = new uint[](n);
        id = new uint[](n);
        for (uint i=0;i<n;i++){
            (propType[i],id[i]) = u2hl(stakeEquipAuto[account].at(i));
        }
    }

    function getAllStakeAutoAndCurInfo(address account) public view returns(uint[] memory propType,uint[] memory id,uint[] memory currDurabilitys,uint[] memory lastTimes){
        uint n = stakeEquipAuto[account].length();
        propType = new uint[](n);
        id = new uint[](n);
        currDurabilitys = new uint[](n);
        lastTimes = new uint[](n);        
        for (uint i=0;i<n;i++){
            (propType[i],id[i]) = u2hl(stakeEquipAuto[account].at(i));
            EquipNFT prop = EquipNFT(nftList[propType[i]]);    
            (currDurabilitys[i],) = prop.curPropertys(id[i]);
            lastTimes[i] = nftAutos[propType[i]][id[i]].startTime;
        }
    }



//autofarm
    
    function __DaoFarmer_init(address governor_, address vault_,address eco_,address mine_,uint begin_, uint span_,address tecSev_) external initializer {
		__Governable_init_unchained(governor_);
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
		__DaoFarmer_init_unchained( vault_,eco_,mine_,begin_, span_,tecSev_);
        _setupRole(DEFAULT_ADMIN_ROLE, governor_);
        _setupRole(POWER_ROLE, governor_);
		maxPower = 8000;
        stakeDAOFvol = 50 ether;
        medalDAOFvol = 25 ether;
	}
	
    function __DaoFarmer_init_unchained(address vault_,address eco_,address mine_,uint begin_,uint span_,address tecSev_) public governance {
        vault = vault_;
        eco = eco_;
        mine = mine_;
        begin = begin_;
        span =span_;
        tecSev = tecSev_;
    }   
    function setTecSev(address tecSev_) public governance {
        tecSev = tecSev_;
    }  

    function setupRole(bytes32 role, address account) public onlyRole(DEFAULT_ADMIN_ROLE){
        _setupRole(role, account);
    }


    function setNftTokens(address[8] calldata tokens_) public governance{
        for (uint i=0;i<8;i++){
            nftList[i] = tokens_[i];
        }
    }
    
    function setERCTokens(address[4] calldata tokens_) public governance{
        for (uint i=0;i<4;i++){
            ercList[i] = tokens_[i];
        }
    }
    
    function setstakeDAOFvol(uint vol) public governance{
        stakeDAOFvol = vol;
    }

    function getPower(address who) public view returns (uint){
            return powers[who];
    }

    function getAllItemValues(address who) public view returns(uint[] memory) {
        IERC20 erc;
        EquipNFT prop;
        uint[] memory values = new uint[](12);
        for (uint i = 0; i < 4; i++) {
            erc = IERC20(ercList[i]);
            values[i] = erc.balanceOf(who);
        }
        for (uint i = 0; i < 8; i++) {
            prop = EquipNFT(nftList[i]);
            values[4+i] = prop.balanceOf(who);
        }
        return values;
    }

    function getInfo(address who) public view returns(EquipNFT.Property[] memory propertys,uint[] memory itemValues) {
        itemValues = getAllItemValues(who);
        propertys = new EquipNFT.Property[](8);
        EquipNFT prop;
        for (uint i=0;i<8;i++){
            prop = EquipNFT(nftList[i]);
            (propertys[i].item1,propertys[i].item2,propertys[i].output,,,,,) = prop.property();
            (,,,propertys[i].rare,propertys[i].totalDurability,propertys[i].costDurability,propertys[i].costPower,propertys[i].coolDown) = prop.property();
        }
    }

    
    function getPropIdsAndCurInfo(address who,uint propType) public view returns(uint[] memory tokenIds,uint[] memory currDurabilitys,uint[] memory lastTimes) {
        EquipNFT prop = EquipNFT(nftList[propType]);
        uint len = prop.balanceOf(who);
        tokenIds = new uint[](len);
        currDurabilitys = new uint[](len);
        lastTimes = new uint[](len);        
        for (uint i = 0; i < len; i++) {
            tokenIds[i] = prop.tokenOfOwnerByIndex(who, i);
            (currDurabilitys[i],lastTimes[i]) = prop.curPropertys(tokenIds[i]);
        }
    }

    function getPropIds(address who,uint propType) public view returns(uint[] memory) {
        EquipNFT prop = EquipNFT(nftList[propType]);
        uint len = prop.balanceOf(who);
        uint[] memory ids = new uint[](len);
        for (uint i = 0; i < len; i++) {
            ids[i] = prop.tokenOfOwnerByIndex(who, i);
        }
        return ids;
    }


    
    function forge(uint propId) public returns (uint tokenId) {
        EquipNFT prop = EquipNFT(nftList[propId]);
        EquipNFT.Item memory item1;
        EquipNFT.Item memory item2;
        uint totalDurability;
        (item1,item2,,,totalDurability,,,)=prop.property();

        address erc1 = ercList[item1.itemType];
        address erc2 = ercList[item2.itemType];

        uint value1 = item1.value;
        uint value2 = item2.value;
        
        TransferHelper.safeTransferFrom(erc1, msg.sender, BurnAddress, value1);
        TransferHelper.safeTransferFrom(erc2, msg.sender, BurnAddress, value2);

        tokenId = prop.mint(msg.sender,"");
        _addPowerByNewEquip(msg.sender,propId);
        emit Forge(nftList[propId],tokenId,msg.sender,block.timestamp);
    }
    event Forge(address nft,uint id,address to,uint time);
    
    function farm(uint propId,uint tokenId) public  {
        EquipNFT prop = EquipNFT(nftList[propId]);
        EquipNFT.Item memory item1;
        uint costPower;
        uint coolDown;
        uint costDurability;
        uint lastTime;
        (,,item1,,,costDurability,costPower,coolDown)=prop.property();
        //require(block.timestamp-curPropertys[tokenId].lastTime>coolDown,"cooling down");
        (,lastTime) = prop.curPropertys(tokenId);
        require(block.timestamp-lastTime >coolDown,"cooling down");
        prop.costDur(tokenId,true);
        powers[msg.sender] -= costPower;
        address erc1 = ercList[item1.itemType];
        
        uint value1 = item1.value;
        if (poolStakes[item1.itemType][msg.sender]>=stakeDAOFvol) //stake
            value1 = value1*106/100;
        uint fee =value1*4/100;
        uint realValue = value1 - 2*fee;  //92%
        TransferHelper.safeTransferFrom(erc1, mine, vault, fee);
        TransferHelper.safeTransferFrom(erc1, mine, eco, fee);
        TransferHelper.safeTransferFrom(erc1, mine, msg.sender, realValue);
        //address owner = prop.ownerOf(tokenId);
        //require(owner == msg.sender ||  prop.isApprovedForAll(owner, msg.sender) ||prop.getApproved(tokenId) ==msg.sender,"have not tokenId's NFT");
        if (!EquipisAccountStake(msg.sender,propId,tokenId)){
            require(getTypeStakeCount(msg.sender,propId)<3,"overflow 3 stake equip");
            prop.safeTransferFrom(msg.sender,address(this),tokenId);
            addStake(msg.sender,propId,tokenId);
        }
        emit Farm(msg.sender,nftList[propId],tokenId,erc1,realValue,block.timestamp);  
    }
    event Farm(address account,address nft,uint id,address erc20,uint value,uint time);


    function withdrawProp(uint propId,uint tokenId) public  {
        require(EquipisAccountStake(msg.sender,propId,tokenId),"You not stake the equip");
        EquipNFT prop = EquipNFT(nftList[propId]);
        uint coolDown;
        uint lastTime;
        uint totalDurability;
        uint curDurability;
        (,,,,totalDurability,,,coolDown)=prop.property();
        (curDurability,lastTime) = prop.curPropertys(tokenId);
        require(block.timestamp-lastTime >coolDown,"cooling down");
        require(totalDurability==curDurability,"Durability is not full");
        removeStake(msg.sender,propId,tokenId);
        prop.safeTransferFrom(address(this),msg.sender,tokenId);
        emit WithdrawProp(msg.sender,nftList[propId],tokenId,block.timestamp);  
    }
    event WithdrawProp(address account,address nft,uint id,uint time);

    
    
    function costFoodForFull(address who) public view returns(uint foodValue) {
        foodValue = (maxPower-getPower(who))*1e18/5;        
    }    
    
    function addPower_(address account,uint power) private {
      uint realPower = powers[account] + power;
      if (realPower > maxPower)
          realPower = maxPower;
      powers[account] = realPower;
    }

    function addPower(address account,uint power) public onlyRole(POWER_ROLE){
        addPower_(account,power);
    }

    function addPowerByNewEquip(address account,uint propId) public onlyRole(POWER_ROLE){
        _addPowerByNewEquip(account,propId);
    }

    function _addPowerByNewEquip(address account,uint propId) private {
        EquipNFT prop = EquipNFT(nftList[propId]);
        uint costPower;
        (,,,,,,costPower,)=prop.property();
        addPower_(account,costPower); 
    }

    function addPowerByNewEquips(address[] memory account,uint[] memory propId) public onlyRole(POWER_ROLE){
        uint len = account.length;
        EquipNFT prop;
        uint[8] memory costPowers;
        for (uint i=0;i<8;i++){
            prop = EquipNFT(nftList[i]);
            (,,,,,,costPowers[i],)=prop.property();
        }
        for (uint i=0;i<len;i++){
            addPower_(account[i],costPowers[propId[i]]); 
        }
    }
       
    function eat(uint foodValue) public{
        uint realFoodValue = costFoodForFull(msg.sender);
        if (foodValue<realFoodValue)
             realFoodValue = foodValue;
        address erc1 = ercList[FOOD];
        TransferHelper.safeTransferFrom(erc1, msg.sender,BurnAddress,realFoodValue);
        powers[msg.sender] += realFoodValue*5/1e18;
    }
    
    function eatFull() public {
        uint realFoodValue = costFoodForFull(msg.sender);
        eat(realFoodValue);
    }    
    
    function costGoldForRepairFull(uint propId,uint tokenId) public view returns (uint goldValue){
        EquipNFT prop = EquipNFT(nftList[propId]);
        uint totalDurability;
        uint curDur;
        (,,,,totalDurability, , , )=prop.property();
        (curDur,) = prop.curPropertys(tokenId);
        goldValue =(totalDurability - curDur)*1e18/5;
    }
    
    function repair(uint propId,uint tokenId,uint goldValue) public {
        uint realGoldValue = costGoldForRepairFull(propId,tokenId);
        if (goldValue<realGoldValue)
            realGoldValue = goldValue;
        address erc1 = ercList[GOLD];

        EquipNFT prop = EquipNFT(nftList[propId]);
        //address owner = prop.ownerOf(tokenId);
        //require(owner == msg.sender ||  prop.isApprovedForAll(owner, msg.sender) ||prop.getApproved(tokenId) ==msg.sender,"have not tokenId's NFT");

        TransferHelper.safeTransferFrom(erc1, msg.sender,BurnAddress,realGoldValue);
        prop.addDur(tokenId,realGoldValue*5/1e18,false);
    }
    
    function repairFull(uint propId,uint tokenId) public {
        uint realGoldValue = costGoldForRepairFull(propId,tokenId);
        repair(propId,tokenId,realGoldValue);
    }

    function stakeDAOF(uint poolID) public{   //raise FOOD = 1; WOOD = 2; GOLD = 3;
        require(poolID>=FOOD && poolID<=GOLD,"No the pool");
        require(poolStakes[poolID][msg.sender]<stakeDAOFvol,"already stake the pool");
        address erc1 = ercList[DAOF];
        TransferHelper.safeTransferFrom(erc1, msg.sender,address(this),stakeDAOFvol);
        poolStakes[poolID][msg.sender] = stakeDAOFvol;

        emit StakeDAOF(poolID,stakeDAOFvol,block.timestamp);
    }
    
    event StakeDAOF(uint poolID,uint value,uint timestamp);

    function unStakeDAOF(uint poolID) public{   //raise FOOD = 1; WOOD = 2; GOLD = 3;
        require(poolID>=FOOD && poolID<=GOLD,"No the pool");
        require(poolStakes[poolID][msg.sender]>0,"no stake the pool");
        require(poolStakeEndTime[poolID][msg.sender]<=block.timestamp,"autoFarm cooling down...");
        address erc1 = ercList[DAOF];
        uint vol = poolStakes[poolID][msg.sender];
        TransferHelper.safeTransfer(erc1, msg.sender,vol);
        poolStakes[poolID][msg.sender] = 0;
        emit UnStakeDAOF(poolID,vol,block.timestamp);
    }
    
    event UnStakeDAOF(uint poolID,uint value, uint timestamp);




    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) public override pure returns (bytes4){
        operator;
        from;
        tokenId;
        data;
        return this.onERC721Received.selector;
    }

    function hl2u(uint hi,uint lo) public pure returns (uint){
        return hi*2**128+lo;
    }

    function u2hl(uint v) public pure returns (uint hi,uint lo){
        hi = v/2**128;
        lo = v%2**128;
    }

    function addStake(address account,uint propType,uint id) private {
           stakeEquip[account].add(hl2u(propType,id));
    }

    function removeStake(address account,uint propType,uint id) private {
           stakeEquip[account].remove(hl2u(propType,id));
    }

    function EquipisAccountStake(address account,uint propType,uint id) public view returns(bool){
        uint typeAndId = hl2u(propType,id);
        return stakeEquip[account].contains(typeAndId);
    }

    function getStakeCount(address account) public view returns(uint){
        return stakeEquip[account].length();
    }

    function getTypeStakeCount(address account,uint propType) public view returns(uint){
        require(propType<8,"invalid prop type");
        uint len = stakeEquip[account].length();
        uint minType;
        uint maxType;
        if (propType<3){
        minType = 0;
        maxType = 2;
        }
        else if(propType<6){
            minType = 3;
            maxType = 5;
        }
        else{
            minType = 6;
            maxType = 7;
        }
        uint[] memory pTypes;
        uint count = 0;
        (pTypes,) = getAllStakeEquip(account);
        for (uint i=0;i<len;i++){
            if (pTypes[i]>=minType &&pTypes[i]<=maxType)
                count++;
        }
        return count;
    }


    function getStakeEquipByIndex(address account,uint index) public view returns(uint propType,uint id){
        (propType,id) = u2hl(stakeEquip[account].at(index));
    }

    function getAllStakeEquip(address account) public view returns(uint[] memory propType,uint[] memory id){
        uint n = stakeEquip[account].length();
        propType = new uint[](n);
        id = new uint[](n);
        for (uint i=0;i<n;i++){
            (propType[i],id[i]) = u2hl(stakeEquip[account].at(i));
        }
    }


    function getAllStakeEquipAndCurInfo(address account) public view returns(uint[] memory propType,uint[] memory id,uint[] memory currDurabilitys,uint[] memory lastTimes){
        uint n = stakeEquip[account].length();
        propType = new uint[](n);
        id = new uint[](n);
        currDurabilitys = new uint[](n);
        lastTimes = new uint[](n);        
        for (uint i=0;i<n;i++){
            (propType[i],id[i]) = u2hl(stakeEquip[account].at(i));
            EquipNFT prop = EquipNFT(nftList[propType[i]]);    
            (currDurabilitys[i],lastTimes[i]) = prop.curPropertys(id[i]);
        }
    }

    //0 DAOF:200, 1 DFM:10000, 2 DFW:150000, 3 DFG:150000  WUSD:50000锛?
    /*function getTestToken() public {
        for (uint i = 0; i < 4; i++) {
            address erc1 = ercList[i];
            if (i==0)
                TransferHelper.safeTransfer(erc1, msg.sender,200 ether);
            else if (i==1)
                TransferHelper.safeTransfer(erc1, msg.sender,10000 ether);
            else if (i==2)
                TransferHelper.safeTransfer(erc1, msg.sender,150000 ether);                                
            else
                TransferHelper.safeTransfer(erc1, msg.sender,150000 ether);
        }
        TransferHelper.safeTransfer(0x51EB4F461339764Ec6FAa67104116e4A92C86612, msg.sender,50000 ether);
        
    }*/
 
}


contract Mine is Governable {
    //using SafeERC20 for IERC20;

    address public reward;

    function __Mine_init(address governor, address reward_) public initializer {
        __Governable_init_unchained(governor);
        __Mine_init_unchained(reward_);
    }
    
    function __Mine_init_unchained(address reward_) public governance {
        reward = reward_;
    }
    
    function approvePool(address pool, uint amount) public governance {
        //IERC20(reward).approve(pool, amount);
        TransferHelper.safeApprove(reward,pool,amount);
    }
    
    function approveToken(address token, address pool, uint amount) public governance {
        //IERC20(token).approve(pool, amount);
        TransferHelper.safeApprove(token,pool,amount);
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0)); //(bool success,) = to.call.value(value)(new bytes(0));           
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

struct NftInfo{
        uint costPower;
        uint coolDown;
        uint costDurability;
        uint curDurability;
        uint lastTime;
        uint times;
        address erc1;
        uint fee;
        uint realValue;
        uint tecFee;
        address recomm;
}

library DaoFarmerLib {
    function farmAuto(mapping(uint =>mapping(uint =>DaoFarmer.NftAuto)) storage nftAutos, mapping(address =>DaoFarmer.RecommInfo) storage recommInfos,mapping (uint =>mapping(address =>uint)) storage poolStakeEndTime, uint propId,uint tokenId) public  {
        DaoFarmer df = DaoFarmer(address(this));
        EquipNFT prop = EquipNFT(df.nftList(propId));
        EquipNFT.Item memory item1;
        NftInfo memory nftInfo;
       // df.farmAutoNum[msg.sender] += 1;
        (,,item1,,,nftInfo.costDurability,nftInfo.costPower,nftInfo.coolDown)=prop.property();
        (nftInfo.curDurability,nftInfo.lastTime) = prop.curPropertys(tokenId);
        require(block.timestamp-nftInfo.lastTime >nftInfo.coolDown,"cooling down");
        nftInfo.times = 48*60*60/nftInfo.coolDown;
        prop.costDur(tokenId,true);
        prop.setDur(tokenId,nftInfo.curDurability - nftInfo.costDurability*nftInfo.times);
        uint meatVol = nftInfo.costPower*nftInfo.times*1e18/5;
        TransferHelper.safeTransferFrom(df.ercList(1), msg.sender, df.BurnAddress(), meatVol);


        nftInfo.erc1 = df.ercList(item1.itemType);
        uint value1 = item1.value*nftInfo.times;
        if (df.poolStakes(item1.itemType,msg.sender)>=df.stakeDAOFvol()){ //stake
            poolStakeEndTime[item1.itemType][msg.sender] = block.timestamp+48*60*60;
            value1 = value1*106/100;
        }
        nftInfo.fee =value1*4/100;
        nftInfo.realValue = value1 - 2*nftInfo.fee;  //92%


        TransferHelper.safeTransferFrom(nftInfo.erc1, df.mine(), df.vault(), nftInfo.fee);
        TransferHelper.safeTransferFrom(nftInfo.erc1, df.mine(), df.eco(), nftInfo.fee);

        //no recommender 6.5% tecsev
        //recommender 4% ,  1% tecsev
        nftInfo.recomm = df.recommenders(msg.sender);
        if (nftInfo.recomm == address(0)){
            nftInfo.tecFee = nftInfo.realValue*65/1000;
            TransferHelper.safeTransferFrom(nftInfo.erc1, df.mine(), df.tecSev(), nftInfo.tecFee);
            nftInfo.realValue = nftInfo.realValue - nftInfo.tecFee;
            nftAutos[propId][tokenId] = DaoFarmer.NftAuto(block.timestamp,block.timestamp,nftInfo.realValue);
        }
        else{
            nftInfo.tecFee = nftInfo.realValue*10/1000;
            TransferHelper.safeTransferFrom(nftInfo.erc1, df.mine(), df.tecSev(), nftInfo.tecFee);
            recommInfos[nftInfo.recomm].inviteRewardAmt[item1.itemType] += nftInfo.tecFee*4;
            TransferHelper.safeTransferFrom(nftInfo.erc1, df.mine(), nftInfo.recomm, nftInfo.tecFee*4);
            nftInfo.realValue = nftInfo.realValue - nftInfo.tecFee*5;
            nftAutos[propId][tokenId] = DaoFarmer.NftAuto(block.timestamp,block.timestamp,nftInfo.realValue);
        }
        if (!df.EquipisAccountStakeAuto(msg.sender,propId,tokenId)){
            require(df.getStakeAutoCount(msg.sender)<6,"overflow 6 stake equip");
            prop.safeTransferFrom(msg.sender,address(this),tokenId);
            df.addStakeAuto(msg.sender,propId,tokenId);
          
        }
        emit FarmAuto(msg.sender,df.nftList(propId),tokenId,nftInfo.erc1,nftInfo.realValue,block.timestamp);  
    }
    event FarmAuto(address account,address nft,uint id,address erc20,uint value,uint time);


    function claimFarmAutoAllAType(mapping(uint =>mapping(uint =>DaoFarmer.NftAuto)) storage nftAutos, uint ercIndex) external {
        DaoFarmer df = DaoFarmer(address(this));
        (uint[] memory propTypes,uint[] memory ids) =  df.getAllStakeAuto(msg.sender);
        uint n = propTypes.length;
        uint[] memory vols =new uint[](n);
        uint totalVol = 0;
        uint realN=0;
        for (uint i=0;i<n;i++){
            if (df.propTypeIsOutErc(propTypes[i],ercIndex)){
                (,,uint enableClaim) = df.earnAuto(msg.sender,propTypes[i],ids[i]);
                if (enableClaim>0){
                    vols[i] = enableClaim;
                    totalVol += enableClaim;
                    realN++;
                    nftAutos[propTypes[i]][ids[i]].lastClaimTime = block.timestamp;
                }
            }
        }
        uint[] memory propIdsRet = new uint[](realN);
        uint[] memory idsRet = new uint[](realN);
        uint[] memory volsRet =new uint[](realN);
        uint index=0;
        for (uint i=0;i<n;i++){
            if (vols[i]>0){
                propIdsRet[index] = propTypes[i];
                idsRet[index] = ids[i];
                volsRet[index] = vols[i];
                index++;
            }
        }
        address erc1 = df.ercList(ercIndex);
        TransferHelper.safeTransferFrom(erc1, df.mine(), msg.sender, totalVol);
        emit ClaimFarmAutoAllAType(ercIndex,totalVol,propIdsRet,idsRet,volsRet);
    }
    event ClaimFarmAutoAllAType(uint ercIndex,uint totalVol,uint[] propIds,uint[] tokenIds,uint[] vols);
}