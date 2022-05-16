/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed currentOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Ownable : Function called by unauthorized user."
        );
        _;
    }

    function owner() external view returns (address ownerAddress) {
        ownerAddress = _owner;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
        returns (bool success)
    {
        require(newOwner != address(0), "Ownable/transferOwnership : cannot transfer ownership to zero address");
        success = _transferOwnership(newOwner);
    }

    function renounceOwnership() external onlyOwner returns (bool success) {
        success = _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal returns (bool success) {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        success = true;
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
interface IERC721Metadata is IERC721 {

    /**
     * @dev  Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev  Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev  Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721Enumerable is IERC721 {
   
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

abstract contract ERC165 is IERC165 {
   
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


library SafeMath {
    /**
     * @dev  Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev  Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev  Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev  Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev  Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev  Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev  Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev  Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev  Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev  Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev  Returns the subtraction of two unsigned integers, reverting with custom message on
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev  Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev  Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
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
        require(b > 0, errorMessage);
        return a % b;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev  Add a value to a set. O(1).
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
     * @dev  Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
     * @dev  Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev  Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev  Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev  Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev  Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev  Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev  Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev  Returns the value stored at position `index` in the set. O(1).
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

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev  Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev  Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev  Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev  Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev  Returns the value stored at position `index` in the set. O(1).
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


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev  Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev  Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev  Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev  Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev  Returns the value stored at position `index` in the set. O(1).
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
}
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev  Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev  Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev  Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev  Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev  Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev  Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    /**
     * @dev  Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    /**
     * @dev  Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev  Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev  Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev  Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev  Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev  Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev  Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev  Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev  Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}
library Strings {
    /**
     * @dev  Converts a `uint256` to its ASCII `string` representation.
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

abstract contract ERC721Pausable is  Context,Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }


    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }


    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    
    function pause() onlyOwner whenNotPaused public {
        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() onlyOwner whenPaused public {
        _paused = false;
        emit Unpaused(_msgSender());
    }
   
}
abstract contract ERC721Fees is  Context,Ownable {
    event FeePaused();
   event FeeUnPaused();
   
   event CancelFeePaused();
   event CancelFeeUnPaused();
   
   event SetFee(uint feeRate);
   event SetCancelFee(uint feeRate);

    uint private _feeRate;
    uint private _cancelFeeRate;
   
    bool private _feePaused;
    bool private _cancelFeePaused;

    constructor (uint feeRate_,uint cancelFeeRate_) {
      _feeRate         = feeRate_;
      _cancelFeeRate   = cancelFeeRate_;
      
        _feePaused       = false;
        _cancelFeePaused = false;
    }
   
    function feeRate() public view virtual returns (uint) {
      if(feePaused() == true){
         return 0;
      }
      
        return _feeRate;
    }   
   
    function cancelFeeRate() public view virtual returns (uint) {
      if(cancelFeePaused() == true){
         return 0;
      }
      
        return _cancelFeeRate;
    }   
   
    function feePaused() public view virtual returns (bool) {
        return _feePaused;
    }   
   
    function cancelFeePaused() public view virtual returns (bool) {
        return _cancelFeePaused;
    }
   
    modifier whenNotFeePaused() {
        require(!feePaused(), "Pausable: paused");
        _;
    }

    modifier whenFeePaused() {
        require(feePaused(), "Pausable: not paused");
        _;
    }   
   
    modifier whenNotCancelFeePaused() {
        require(!cancelFeePaused(), "Pausable: paused");
        _;
    }

    modifier whenCancelFeePaused() {
        require(cancelFeePaused(), "Pausable: not paused");
        _;
    }
   
    function feePause() onlyOwner whenNotFeePaused public {
        _feePaused = true;
        emit FeePaused();
    }

    function feeUnPause() onlyOwner whenFeePaused public {
        _feePaused = false;
        emit FeeUnPaused();
    }   
   
    function cancelFeePause() onlyOwner whenNotCancelFeePaused public {
        _cancelFeePaused = true;
        emit CancelFeePaused();
    }

    function cancelFeeUnPause() onlyOwner whenCancelFeePaused public {
        _cancelFeePaused = false;
        emit CancelFeeUnPaused();
    }
   
      
    function setFee(uint feeRate_) onlyOwner public {
      require(feeRate_ <= 100, "Up to 100 commission");
      
        _feeRate = feeRate_;
        emit SetFee(feeRate_);
    }   
   
    function setCancelFee(uint feeRate_) onlyOwner public {
      require(feeRate_ <= 100, "Up to 100 commission");
      
        _cancelFeeRate = feeRate_;
        emit SetCancelFee(feeRate_);
    }   
}

/*interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}*/

abstract contract BEP20Basic {   
    uint public _totalSupply; 
    function totalSupply() public virtual returns (uint);
    function balanceOf(address who) public view virtual returns (uint);
    function transfer(address to, uint value) public virtual ;    
}

abstract contract BEP20 is BEP20Basic {
    function allowance(address owner, address spender) public virtual returns (uint);
    function transferFrom(address from, address to, uint value) public virtual;
    function approve(address spender, uint value) public virtual;
}

abstract contract BasicToken is Ownable, BEP20Basic {
    using SafeMath for uint;

    mapping(address => uint) public balances;

    // additional variables for use if transaction fees ever became necessary
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }
    
    function transfer(address _to, uint _value) public virtual override onlyPayloadSize(2 * 32) {
           
    }
    
    function balanceOf(address _owner) public view virtual override returns (uint balance) {
        return balances[_owner];
    }

}

abstract contract StandardToken is BasicToken, BEP20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;
    
    function transferFrom(address _from, address _to, uint _value) public virtual override onlyPayloadSize(3 * 32) {     
        
    }
    
    function approve(address _spender, uint _value) public virtual  override onlyPayloadSize(2 * 32) {

    }
    
    function allowance(address _owner, address _spender) public virtual override returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

abstract contract UpgradedStandardToken is StandardToken{
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function transferByLegacy(address from, address to, uint value) public virtual;
    function transferFromByLegacy(address sender, address from, address spender, uint value) public virtual;
    function approveByLegacy(address from, address spender, uint value) public virtual;
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract BITMIC is Pausable, StandardToken {

    string public name;
    string public symbol;
    uint public decimals;
    address public upgradedAddress;
    bool public deprecated;
       
    constructor(){}
    
    function transfer(address _to, uint _value) public override whenNotPaused {
       
    }

    function transferFrom(address _from, address _to, uint _value) public override whenNotPaused {
        
    }

    function balanceOf(address who) public view override returns (uint) {
       
    }

    function approve(address _spender, uint _value) public override onlyPayloadSize(2 * 32) {
        
    }

    function allowance(address _owner, address _spender) public override returns (uint remaining) {
        return super.allowance(_owner, _spender);
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    
}

   
abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable 
,ERC721Pausable
,ERC721Fees
{
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;
   using EnumerableMap for EnumerableMap.UintToAddressMap;
   
   EnumerableMap.UintToAddressMap internal _tokenOwners;
   
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) internal _holderTokens;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) internal _operatorApprovals;

    mapping (uint256 => string) internal _tokenURIs;

    string internal _baseURI;
   
    string private _name;

    string private _symbol;
   
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;   

    BITMIC public _PayToken;
    
   constructor (string memory name_, string memory symbol_) 
    
   ERC721Fees(10,1)
      {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }
   
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _tokenOwners.get(tokenId);
    }
   
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId));
        address owner = _ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || _operatorApprovals[owner][spender]);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data));
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0));
        require(!_exists(tokenId));

        _beforeTokenTransfer();

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = _ownerOf(tokenId); // internal owner

        _beforeTokenTransfer();

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(_ownerOf(tokenId) == from);
        require(to != address(0));

        _beforeTokenTransfer();

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId); // internal owner
    }

         function _beforeTokenTransfer() internal virtual {
         require(!paused());
      }
       
   
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId));

        return _tokenApprovals[tokenId];
    }   
   
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0));
        return _holderTokens[owner].length();
    }
   
    function setBaseURI(string memory baseURI_) onlyOwner public virtual {
        _setBaseURI(baseURI_);
    }   
   
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId));

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tokenOwners.length();
    }
   

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }
   
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }
   
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _ownerOf(tokenId);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner);

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()));

        _approve(to, tokenId);
    }

    /**
     * @dev  See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender());

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev  See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
   
      struct Offer {
        bool isForSale;
        address seller;
        uint256 minValue; 
        bool isTokenSell;
      uint endTime;
    }

    struct Bid {
        bool hasBid;
        address bidder;
        uint256 value;
    }

   
   // NFT 경매 등록 목록
    mapping (uint256 => Offer) public offers;

    // NFT 입찰 목록
    mapping (uint256 => Bid) public bids;
   

    //리빌 목록;
    mapping (uint256 => bool) public reveal;

    
   
   event CreateAuction(address indexed owner,uint256 _tokenId, uint256 _minValue,uint _endTime);
   event CancelAuction(uint256 _tokenId);
   event EndAuction(uint256 _tokenId,uint256 price);
   
   event Bidding(uint256 _tokenId,uint256 value);
   event CancelBid(uint256 _tokenId);
   
   event Bidding_token(uint256 _tokenId,uint256 value);
   
   //경매등록
   function _createAuction(uint256 _tokenId, uint256 _minValue,uint _auctionTime, bool isTokenSell) internal virtual {
      require(_ownerOf(_tokenId) == msg.sender);//토큰 소유자인지 확인
      
      Offer storage offer =  offers[_tokenId];
      require(offer.isForSale != true);//현재 판매중인지 확인

      //offer.isTokenSell = isTokenSell; // 토큰 판매 방식 여부;
      
        offers[_tokenId] = Offer(true, msg.sender, _minValue, isTokenSell ,block.timestamp + _auctionTime);
      emit CreateAuction(msg.sender, _tokenId, _minValue,block.timestamp + _auctionTime);
   }
   
   //경매취소
    function _cancelAuction(uint256 _tokenId) internal virtual {
       require(_ownerOf(_tokenId) == msg.sender);//토큰 소유자인지 체크
      
      Offer storage offer =  offers[_tokenId];
      require(offer.isForSale == true);//현재 경매중인지 체크
      
      Bid storage bid = bids[_tokenId];
      require(bid.hasBid != true);//입찰자가 있을경우 경매 취소 불가능

      offers[_tokenId] = Offer(false, msg.sender, 0 , false ,0);
      
      emit CancelAuction(_tokenId);
    }

    function _cancelAuction_admin(uint256 _tokenId) internal virtual {
      
      Offer storage offer =  offers[_tokenId];
      require(offer.isForSale == true);//현재 경매중인지 체크
      
      Bid storage bid = bids[_tokenId];
      if(bid.hasBid == true){
          if(offer.isTokenSell == true) // 토큰 판매 방식;
          {
            _PayToken.transfer(bid.bidder, bid.value);
          }else{ // 코인 판매 방식;
            address payable bidder = payable(bid.bidder);
            bidder.transfer(bid.value);
          }            
      }

      _resetAuction(_tokenId);
      
      emit CancelAuction(_tokenId);
    }

    function _bid_token(uint256 _tokenId, uint256 _amount) internal virtual {
        require(_ownerOf(_tokenId) != msg.sender);//토큰 보유자
      
        Offer storage offer =  offers[_tokenId];
        require(block.timestamp < offer.endTime);//경매가 종료되었을 경우

        require(_PayToken.balanceOf(msg.sender) >= _amount , "Not enough BITMIC quantity.");

        require(_amount >= offer.minValue);

        Bid storage existing = bids[_tokenId];
        require(_amount > existing.value);//입찰금액이 이전 입찰금액보다 적을경우 트랜잭션 취소

        if (existing.value > 0) {
         //이전 입찰자에게 토큰을 돌려줌         
          _PayToken.transfer(existing.bidder, existing.value);
        }

        //컨트랙트에 토큰을 보냄;
       _PayToken.transferFrom(msg.sender, address(this), _amount);

        bids[_tokenId] = Bid(true, msg.sender, _amount);
      
        emit Bidding_token(_tokenId,_amount);
    }
   
   //입찰하기
    function _bid(uint256 _tokenId) internal virtual {
      require(_ownerOf(_tokenId) != msg.sender);//토큰 보유자
      
      Offer storage offer =  offers[_tokenId];
      require(block.timestamp < offer.endTime);//경매가 종료되었을 경우

      require(msg.value >= offer.minValue);//입찰 금액이 최소 입찰액보다 작은지 체크
      
        Bid storage existing = bids[_tokenId];
        require(msg.value > existing.value);//입찰금액이 이전 입찰금액보다 적을경우 트랜잭션 취소
      
        if (existing.value > 0) {
         //이전 입찰자에게 이더리움을 돌려줌
         address payable bidder = payable(existing.bidder);
         bidder.transfer(existing.value);
        }
      
        bids[_tokenId] = Bid(true, msg.sender, msg.value);
      
      emit Bidding(_tokenId,msg.value);      
    }   
   
   //입찰취소
    function _cancelBid(uint256 _tokenId) internal virtual {
      Offer storage offer =  offers[_tokenId];
      require(offer.isForSale == true, "No isForSale");//경매가 진행중인지 체크
      require(block.timestamp < offer.endTime , "auction end");//경매가 종료되었을 경우

        Bid storage bid = bids[_tokenId];
      require(bid.hasBid == true);
      require(bid.bidder == msg.sender);//입찰자가 본인인 경우
      
      uint256 cancelFee = bid.value * cancelFeeRate() / 1000;
      if(offer.isTokenSell == true)
      {
        _PayToken.transfer(bid.bidder, bid.value - cancelFee);
        if(cancelFee > 0)
        {
            _PayToken.transfer(offer.seller, cancelFee);
        }
        
      }else{
        address payable bidder = payable(bid.bidder);
        address payable seller = payable(offer.seller);
                    
        bidder.transfer(bid.value - cancelFee);
        if(cancelFee > 0)
        {
            seller.transfer(cancelFee);  
        }
        
      }
      bids[_tokenId] = Bid(false, address(0), 0);
      emit CancelBid(_tokenId);
      
    }

    function isTokenSell_Auction(uint256 _tokenId) public view returns(bool) {
        Offer storage offer =  offers[_tokenId];
        return offer.isTokenSell;
    }
   
   //경매종료
    function _endAuction(uint256 _tokenId) internal virtual {
        Offer storage offer =  offers[_tokenId];
      require(block.timestamp >= offer.endTime , "No auction end time.");//경매 종료 시간이 아닐경우 오류
      require(offer.isForSale == true, "No isForSale");//경매가 이미 종료된 경우
      
      address payable seller = payable(_ownerOf(_tokenId));
      
      Bid storage bid = bids[_tokenId];

      _transfer(offer.seller, bid.bidder, _tokenId);

            // 수수료
      uint256 _commissionValue = bid.value * feeRate() / 1000;
      uint256 _sellerValue = bid.value - _commissionValue;

      if(offer.isTokenSell == true)
      {
         _PayToken.transfer(offer.seller, _sellerValue);
         if(_commissionValue > 0)
         {
            _PayToken.transfer(_owner, _commissionValue);
         }
      }else{
        seller.transfer(_sellerValue);//판매자에게 판매대금 지급         
        address payable contractOwner = payable(_owner);
        if(_commissionValue > 0)
        {
             contractOwner.transfer(_commissionValue);//발행자에게 수수료 지급
        }        
      }  
            
      emit EndAuction(_tokenId,bid.value);
      _resetAuction(_tokenId);
   }   
   
   
   function _resetAuction(uint256 _tokenId) internal virtual {
        offers[_tokenId] = Offer(false, address(0), 0, false ,0);
        bids[_tokenId] = Bid(false, address(0), 0);
   }
   
   
   function hasAuction(uint256 _tokenId) public view virtual returns (bool){
      Offer storage offer =  offers[_tokenId];
      if(offer.isForSale != true){
         return false;
      }
      
      return true;
   }

   function _set_PayTokenAddress(BITMIC _token) internal {
       _PayToken = _token;
   }
  
   function SendPayToken(uint256 _amount) public onlyOwner {
       require(_PayToken.balanceOf(msg.sender) >= _amount , "Not enough BITMIC quantity.");
       _PayToken.transferFrom(msg.sender, address(this), _amount);
   }

   function balanceOf_PayToken() public view returns(uint256)
   {
       return _PayToken.balanceOf(address(this));
   }

}


abstract contract ERC721Burnable is ERC721
{
   
    function burn(uint256 _tokenId) external payable{
        require(_isApprovedOrOwner(_msgSender(), _tokenId) || _owner == _msgSender(), "ERC721Burnable: caller is not owner nor approved");
      
            Offer storage offer =  offers[_tokenId];
      if(offer.isForSale == true){
         
         Bid storage bid = bids[_tokenId];
         if(bid.hasBid == true){
            if(offer.isTokenSell == true)
            {
                _PayToken.transfer(bid.bidder, bid.value);
            }else
            {
                address payable bidder = payable(bid.bidder);
                bidder.transfer(bid.value);
            }            
         }         
         _resetAuction(_tokenId);
      }
            
        _burn(_tokenId);
    }

    function burn_admin(uint256 _tokenId) external payable onlyOwner {
        require(hasAuction(_tokenId) == false);
      
         _resetAuction(_tokenId);
        _burn(_tokenId);
    }

}
abstract
contract Market is
 ERC721Burnable
{
    address payable public _contractOwner;

    mapping (uint256 => uint256) public price;
    mapping (uint256 => bool) public listedMap;
    mapping (uint256 => bool) public tokenSell;
    mapping (uint256 => bool) public cashSell;

    uint256 public _TotalTokenId = 0;

    event Purchase(address indexed previousOwner, address indexed newOwner, uint256 price, uint256 nftID, string uri);

    event Purchase_Token(address indexed previousOwner, address indexed newOwner, uint256 price, uint256 nftID, string uri);

    event Minted(address indexed minter, uint256 price, uint256 nftID, string uri);

    event PriceUpdate(address indexed owner, uint256 oldPrice, uint256 newPrice, uint256 nftID);

    event NftListStatus(address indexed owner, uint256 nftID, bool isListed);

    function isTokenSell_Immediately(uint256 _tokenId) public view returns(bool) {        
        return tokenSell[_tokenId];
    }

    //마지막 토큰 ID
    function LastTokenID() external view returns (uint256) {
        return _TotalTokenId;
    }
   
    function buy(uint256 _id, bool _present, address _to) external payable {
        if(_present)
        {
            require(_to != address(0) , "recever address empty!");
            require(_to != ownerOf(_id) , "recever address is owner!");
        }

        _validate(_id);

        address _previousOwner = ownerOf(_id);
        address _newOwner = msg.sender;

        _trade(_id, _present, _to);

        emit Purchase(_previousOwner, _newOwner, price[_id], _id, tokenURI(_id));
    }

    function buy_Cash(uint256 _id, address _to) external payable onlyOwner {
        require(_to != address(0) , "recever address empty!");
        require(_to != ownerOf(_id) , "recever address is owner!");

        bool isItemListed = listedMap[_id];
        bool isCashSell = cashSell[_id];
        require(_exists(_id));
        require(isItemListed);
        require(isCashSell);

        address payable _owner = payable(ownerOf(_id));

        _transfer(_owner, _to, _id);

        listedMap[_id] = false;
        cashSell[_id] = false;
    }

    function _validate(uint256 _id) internal {
        bool isItemListed = listedMap[_id];
        require(_exists(_id));
        require(isItemListed);
        require(msg.value >= price[_id]);
        require(msg.sender != ownerOf(_id));
    }

    function _trade(uint256 _id, bool _present, address _to) internal {
        address payable contractOwner = payable(_owner);
        address payable _buyer = payable(msg.sender);
        address payable _owner = payable(ownerOf(_id));

        if(_present)
        {
            _transfer(_owner, _to, _id);
        }else{
            _transfer(_owner, _buyer, _id);
        }

         uint256 _commissionValue = price[_id] * feeRate() / 1000;
         uint256 _sellerValue = price[_id] - _commissionValue;

         _owner.transfer(_sellerValue);
         if(_commissionValue > 0)
         {
            contractOwner.transfer(_commissionValue);
         }         
      
        // If buyer sent more than price, we send them back their rest of funds
        if (msg.value > price[_id]) {
            _buyer.transfer(msg.value - price[_id]);
        }

        listedMap[_id] = false;
    }

    function buy_token(uint256 _id, bool _present, address _to) external {
        if(_present)
        {
            require(_to != address(0) , "recever address empty!");
            require(_to != ownerOf(_id) , "recever address is owner!");
        }

        _validate_token(_id);

        address _previousOwner = ownerOf(_id);
        address _newOwner = msg.sender;

        _trade_token(_id, _present, _to);

        emit Purchase_Token(_previousOwner, _newOwner, price[_id], _id, tokenURI(_id));
    }

    function _validate_token(uint256 _id) internal {
        bool isItemListed = listedMap[_id];
        require(_exists(_id) , "exists id");
        require(isItemListed , "isItemListed false");
        require(_PayToken.balanceOf(msg.sender) >= price[_id] , "Not enough BITMIC quantity.");        
        require(msg.sender != ownerOf(_id), "msg.sender is ownerOf(_id)");
    }

    function _trade_token(uint256 _id, bool _present, address _to) internal {             
        address payable _buyer = payable(msg.sender);
        address payable _owner_NFT = payable(ownerOf(_id));

          
        if(_present)
        {
            _transfer(_owner_NFT, _to, _id);  
        }else{
            _transfer(_owner_NFT, _buyer, _id);  
        }  

         uint256 _commissionValue = price[_id] * feeRate() / 1000;
         uint256 _sellerValue = price[_id] - _commissionValue;

         _PayToken.transferFrom(msg.sender, ownerOf(_id), _sellerValue);
         if(_commissionValue > 0)
         {
            _PayToken.transferFrom(msg.sender, _owner, _commissionValue);
         }
         
     
        listedMap[_id] = false;
    }
   
    function updatePrice(uint256 _tokenId, uint256 _price) public returns (bool) {
            require(hasAuction(_tokenId) == false);
              uint256 oldPrice = price[_tokenId];
        require(msg.sender == ownerOf(_tokenId));
        price[_tokenId] = _price;

        emit PriceUpdate(msg.sender, oldPrice, _price, _tokenId);
        return true;
    }
   
    function updateListingStatus(uint256 _tokenId, bool shouldBeListed) public returns (bool) {
        require(msg.sender == ownerOf(_tokenId));
              require(hasAuction(_tokenId) == false);
      
        listedMap[_tokenId] = shouldBeListed;      
        if(!shouldBeListed) cashSell[_tokenId] = false;  
        emit NftListStatus(msg.sender, _tokenId, shouldBeListed);

        return true;
    }   

     function cancel_ImmediateSale(uint256 _tokenId) public onlyOwner {
        require(listedMap[_tokenId] == true);
        listedMap[_tokenId] = false; 
        if(cashSell[_tokenId]) cashSell[_tokenId] = false;       
        emit NftListStatus(msg.sender, _tokenId, false);
     }
   
    function updateSale(uint256 _tokenId, uint256 _price) public returns (bool) {
            require(hasAuction(_tokenId) == false);
              uint256 oldPrice = price[_tokenId];
        require(msg.sender == ownerOf(_tokenId));
      
        price[_tokenId] = _price;
      emit NftListStatus(msg.sender, _tokenId, true);
      
      if (listedMap[_tokenId] != true) {
         listedMap[_tokenId] = true;
         emit PriceUpdate(msg.sender, oldPrice, _price, _tokenId);
      }
        return true;
    }

    /**
     * @dev  See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        require(hasAuction(tokenId) == false);
        require(listedMap[tokenId] == false); 
      
        _transfer(from, to, tokenId);
    }

    /**
     * @dev  See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev  See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        require(hasAuction(tokenId) == false);
        require(listedMap[tokenId] == false); 
            
        _safeTransfer(from, to, tokenId, _data);
    }   
   
}

contract BITMIC_NFT is Market {

    uint256 public _BOX_Open_Price = 0.01 ether; // 오픈박스 금액;

    address payable public _OpenBoxOwner; // 오픈박스 NFT 케릭터 주소 및 오픈박스시 지불 주소; 
    address payable public _Administrator ; // NFT 민트 및 리빌 가능한 주소;

    event Mint_Single(address indexed owner, uint256 nftID, string uri);
    event Mint_Multi(address indexed owner, uint256 nftID, string uri);
    event ImmediatelySell_Auction(address indexed owner, uint256 price, uint256 nftID, bool isTokenSell);
    event ImmediatelySell_Cash_Auction(address indexed owner, uint256 nftID);

    event Open_Box(address indexed owner, uint256 nftID, string uri);
    event Set_Reveal(address indexed owner, uint256 nftID, string uri);

    constructor() ERC721("BITMIC", "BMIC") {
        _OpenBoxOwner = payable(msg.sender);
        _Administrator = payable(msg.sender);
    }

    function mInt_Single(address _toAddress, string memory _tokenURI, bool _isReveal) public returns (uint256) {
        require(msg.sender == _Administrator || msg.sender == _owner);  
        uint256 _tokenId = _TotalTokenId + 1;        
        _safeMint( _toAddress, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        if(_isReveal)
        {
            reveal[_tokenId] = true; 
        }

        _TotalTokenId = _tokenId;
        emit Mint_Single(_toAddress, _tokenId, _tokenURI);
        
        return _tokenId;
    }

    function mInt_Multi(address _toAddress, string[] memory _tokenURI, bool _isReveal) public returns (uint256[] memory){   
        require(msg.sender == _Administrator || msg.sender == _owner);     
        uint256 _Count = _tokenURI.length;  

        uint256[] memory _listTokenIds = new uint256[](_Count); //NFT 배열;

        for(uint256 i; i < _Count; i++){
            uint256 _tokenId = _TotalTokenId + 1;            
            _safeMint( _toAddress, _tokenId);
            _setTokenURI(_tokenId, _tokenURI[i]);

            if(_isReveal)
            {
                reveal[_tokenId] = true; 
            }

            _TotalTokenId = _tokenId;
            _listTokenIds[i] = _tokenId;
            emit Mint_Multi(_toAddress, _tokenId, _tokenURI[i]);
        }  

        return  _listTokenIds;   
    }      
   
   //경매생성
    function createAuction(uint256 _tokenId, uint256 _minValue,uint _auctionTime, bool isTokenSell)  public virtual {
      require(_ownerOf(_tokenId) == msg.sender);//토큰 소유자인지 확인
      require(hasAuction(_tokenId) == false);
      require(listedMap[_tokenId] == false); // 즉시판매 진행중
      price[_tokenId] = _minValue;
      _createAuction(_tokenId,_minValue,_auctionTime, isTokenSell);
    }

    //즉시 판매 경매 생성
    function immediatelySell_Auction(uint256 _tokenId, uint256 _price, bool isTokenSell) public  {     
        require(_ownerOf(_tokenId) == msg.sender);//토큰 소유자인지 확인
        require(hasAuction(_tokenId) == false);
        require(listedMap[_tokenId] == false); // 즉시판매 진행중   
        price[_tokenId] = _price;
        listedMap[_tokenId] = true; 
        tokenSell[_tokenId] = isTokenSell; 
        emit ImmediatelySell_Auction(msg.sender, _price, _tokenId, isTokenSell);  
    }

    //즉시 판매 경매 생성 - 현금
    function immediatelySell_Cash_Auction(uint256 _tokenId) public  {     
        require(_ownerOf(_tokenId) == msg.sender);//토큰 소유자인지 확인
        require(hasAuction(_tokenId) == false);
        require(listedMap[_tokenId] == false); // 즉시판매 진행중          
        listedMap[_tokenId] = true; 
        cashSell[_tokenId] = true; 
        emit ImmediatelySell_Cash_Auction(msg.sender, _tokenId);  
    }
   
   //경매취소
   function cancelAuction(uint256 _tokenId)  public virtual {
      
      _cancelAuction(_tokenId);
   }   
   
   function cancelAuction_admin(uint256 _tokenId) external payable onlyOwner {
       _cancelAuction_admin(_tokenId);
   }

   //입찰
   function bid(uint256 _tokenId) external payable {
      _bid(_tokenId);
   }

   //토큰입찰;
   function bid_Token(uint256 _tokenId, uint256 _amount) external {
       _bid_token(_tokenId, _amount);
   }
   
      //입찰취소
   function cancelBid(uint256 _tokenId) external payable {
      
      _cancelBid(_tokenId);
   }   
      
   //경매종료
   function endAuction(uint256 _tokenId) external payable {
      
      _endAuction(_tokenId);
   }
   
   //리빌 설정;
   function SetReveal(uint256 _tokenId , string memory _tokenURI) external {    
       require(msg.sender == _Administrator || msg.sender == _owner);  
       require(reveal[_tokenId] == false,  "Already reveal....." ); // 리빌이 안된것만;
       reveal[_tokenId] = true;  
       _setTokenURI(_tokenId, _tokenURI);   
   }

   //여러개 리빌 설정;
   function SetReveal_Multi(uint256[] memory _tokenId, string[] memory _tokenURI) external {
       require(msg.sender == _Administrator || msg.sender == _owner);    
       uint256 _Count = _tokenId.length;    
        for(uint256 i=0; i < _Count; i++){
           uint256 tokenId = _tokenId[i];            
           reveal[tokenId] = true;   
           _setTokenURI(tokenId, _tokenURI[i]);                     
        }  
    }

   //리빌 여부 확인;
   function isReveal(uint256 _tokenId) public view returns (bool) {
       return reveal[_tokenId];
   }

   // 경매 및 즉시판매 중인지 확인;
   function isAuction(uint256 _tokenId) public view returns (bool) {
       bool bAuction = false;
       if(hasAuction(_tokenId) || listedMap[_tokenId])
       {
           bAuction = true;
       }
       return bAuction;
   }

   // 현금 판매인지 확인;
   function isCashImmediately(uint256 _tokenId) public view returns (bool) {
       bool bAuction = false;
       if(listedMap[_tokenId] && cashSell[_tokenId])
       {
           bAuction = true;
       }
       return bAuction;
   }

   function GetOpenBoxCount() public view returns (uint256){
       //NFT 케릭터 오너 계정에서 NFT 수량 가져옴;
       uint256 _nCount = balanceOf(_OpenBoxOwner);
    
       //가져온 수량 중에 판매가 가능한것만 수량체크;
       uint256 _ableCount = 0;
       for(uint256 i=0 ; i<_nCount ; i++)
       {
           uint256 _tokenId = tokenOfOwnerByIndex(_OpenBoxOwner, i);
           if(!isAuction(_tokenId) && isReveal(_tokenId))
           {
               _ableCount++;
           }
       }

       return _ableCount;
   }

   //랜덤 박스 오픈;
   function OpenBox()  external payable returns (uint256){   
       require(_OpenBoxOwner != address(0));       
       require( msg.value == _BOX_Open_Price,  "Klay sent is not correct." );

       //NFT 케릭터 오너 계정에서 NFT 수량 가져옴;
       uint256 _nCount = balanceOf(_OpenBoxOwner);

       require(_nCount > 0, "Not enough quantity."); // 판매할 수량이 있어야함;
    
       //가져온 수량 중에 판매가 가능한것만 수량체크;
       uint256 _ableCount = 0;
       for(uint256 i=0 ; i<_nCount ; i++)
       {
           uint256 _tokenId = tokenOfOwnerByIndex(_OpenBoxOwner, i);
           if(!isAuction(_tokenId) && isReveal(_tokenId))
           {
               _ableCount++;
           }
       }

       uint256[] memory _listTokenIds = new uint256[](_ableCount); //NFT 배열;

       //가져온 수량의 NFT ID를 배열에 담음;
       uint256 _count = 0; 
       for(uint256 i=0 ; i<_nCount ; i++)
       {
           uint256 _tokenId = tokenOfOwnerByIndex(_OpenBoxOwner, i);
           if(!isAuction(_tokenId) && isReveal(_tokenId))
           {
               _listTokenIds[_count] = _tokenId;
               _count++;
           }
       }
       
       //랜덤하게 하나 선정해서 전송;
       uint256 _nSelectID = 0;

       uint total = _listTokenIds.length;

       require(total > 0, "no NFT left");

       uint rand = random(total);

       _nSelectID = _listTokenIds[rand];

       require(_OpenBoxOwner == _ownerOf(_nSelectID));            

       // transfer NFT
       _transfer(_OpenBoxOwner, msg.sender, _nSelectID);
               
       //박스 판매금액 전송;      
       _OpenBoxOwner.transfer(msg.value);
    
       string memory _TokenURI = tokenURI(_nSelectID);

       emit Open_Box(msg.sender, _nSelectID, _TokenURI);

       return _nSelectID;
   }

   //랜덤함수;
   function random(uint number) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
   }  
   
   // 오픈박스 금액 설정;
   function setBoxOpenPrice(uint256 _price) public {
       require(msg.sender == _Administrator || msg.sender == _owner);
       _BOX_Open_Price = _price;
   }

   // 오픈박스 판매 및 금액 전송 지갑 설정;
   function setOpenBoxOwner(address payable _newAddress) public onlyOwner {
       require(_newAddress != address(0));
       require(_newAddress != _OpenBoxOwner);
       _OpenBoxOwner = _newAddress;
   }

   // 관리자 지갑 주소 설정;
   function setAdministrator(address payable _newAddress) public onlyOwner {
       require(_newAddress != address(0));
       require(_newAddress != _Administrator);
       _Administrator = _newAddress;
   }

   function GetAdministrator() public view returns(address){
       return _Administrator;
   }

   function GetOpenBoxOwner() public view returns(address){
       return _OpenBoxOwner;
   }

   function Set_PayTokenAddress(BITMIC _token) public onlyOwner {
       _set_PayTokenAddress(_token);
   }   
}