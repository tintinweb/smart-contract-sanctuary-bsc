// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ClaimHolder.sol";

contract Identity is ClaimHolder {

    constructor(address owner) ClaimHolder(owner) {}

    function addMultiple(
        uint256[] memory _claimType,
        uint256[] memory _scheme,
        address[] memory _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri,
        uint256[] memory _sigSizes,
        uint256[] memory dataSizes,
        uint256[] memory uriSizes
    ) external {
        bytes32 claimId;
        uint offset = 0;
        uint uoffset = 0;
        uint doffset = 0;

        for (uint i = 0; i < _claimType.length; i++) {

            claimId = keccak256(abi.encodePacked(_issuer[i], _claimType[i]));

            claims[claimId] = Claim(
                _claimType[i],
                _scheme[i],
                _issuer[i],
                getBytes(_signature, offset, _sigSizes[i]),
                getBytes(_data, doffset, dataSizes[i]),
                getString(_uri, uoffset, uriSizes[i])
            );

            offset += _sigSizes[i];
            uoffset += uriSizes[i];
            doffset += dataSizes[i];

            emit ClaimAdded(
                claimId,
                claims[claimId].claimType,
                claims[claimId].scheme,
                claims[claimId].issuer,
                claims[claimId].signature,
                claims[claimId].data,
                claims[claimId].uri
            );
        }
    }

    function getBytes(bytes memory _data, uint256 _offset, uint256 _length) internal pure returns (bytes memory) {
        bytes memory data = new bytes(_length);
        uint256 j = 0;
        for (uint256 k = _offset; k < _offset + _length; k++) {
          data[j] = _data[k];
          j++;
        }
        return data;
    }

    function getString(string memory _str, uint256 _offset, uint256 _length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory str = new bytes(_length);
        uint256 j = 0;
        for (uint256 k = _offset; k < _offset + _length; k++) {
          str[j] = strBytes[k];
          j++;
        }
        return string(str);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../core/interfaces/IERC735.sol";
import "./KeyHolder.sol";

contract ClaimHolder is IERC735, KeyHolder {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping (bytes32 => Claim) claims;
    mapping (uint256 => EnumerableSet.Bytes32Set) claimsByType;

    constructor(address owner) KeyHolder(owner) {}

    function getClaim(bytes32 _claimId)
        external
        view
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {
        Claim memory foundedClaim = claims[_claimId];
        return (
            foundedClaim.claimType,
            foundedClaim.scheme,
            foundedClaim.issuer,
            foundedClaim.signature,
            foundedClaim.data,
            foundedClaim.uri
        );
    }

    function getClaimIdsByType(uint256 _claimType)
        external
        view
        returns(bytes32[] memory claimIds)
    {
        return claimsByType[_claimType].values();
    }


    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string calldata _uri
    )
        external
        returns (bytes32 claimRequestId)
    {
        bytes32 claimId = keccak256(abi.encodePacked(_issuer, _claimType));

        if (_msgSender() != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.CLAIM_SIGNER_KEY)), "Sender does not have claim signer key");
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByType[_claimType].add(claimId);
        }

        claims[claimId].claimType = _claimType;
        claims[claimId].scheme = _scheme;
        claims[claimId].issuer = _issuer;
        claims[claimId].signature = _signature;
        claims[claimId].data = _data;
        claims[claimId].uri = _uri;

        emit ClaimAdded(
            claimId,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

    function removeClaim(bytes32 _claimId) external returns (bool success) {
        if (_msgSender() != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.CLAIM_SIGNER_KEY)), "Sender does not have claim signer key");
        }

        Claim memory foundedClaim = claims[_claimId];

        emit ClaimRemoved(
            _claimId,
            foundedClaim.claimType,
            foundedClaim.scheme,
            foundedClaim.issuer,
            foundedClaim.signature,
            foundedClaim.data,
            foundedClaim.uri
        );

        claimsByType[foundedClaim.claimType].remove(_claimId);
        delete claims[_claimId];
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../core/interfaces/IERC725.sol";

contract KeyHolder is IERC725, Context {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint256 private executionNonce;

    mapping (bytes32 => Key) private keys;
    mapping (uint8 => EnumerableSet.Bytes32Set) private keysByPurpose;
    mapping (uint256 => Execution) private executions;

    constructor(address owner) {
        bytes32 _key = keccak256(abi.encodePacked(owner));
        keys[_key].key = _key;
        keys[_key].purpose = uint8(KeyPurpose.MANAGEMENT_KEY);
        keys[_key].keyType = uint8(KeyType.ECDSA_TYPE);

        keysByPurpose[uint8(KeyPurpose.MANAGEMENT_KEY)].add(_key);

        emit KeyAdded(_key, keys[_key].purpose, keys[_key].keyType);
    }

    function getKey(bytes32 _key)
        external
        view
        override
        returns(uint8 purpose, uint8 keyType, bytes32 key)
    {
        Key memory foundKey = keys[_key];
        return (foundKey.purpose, foundKey.keyType, foundKey.key);
    }

    function getKeyPurpose(bytes32 _key)
        public
        view
        override
        returns(uint8 purpose)
    {
        return (keys[_key].purpose);
    }

    function getKeysByPurpose(uint8 _purpose)
        public
        view
        override
        returns(bytes32[] memory _keys)
    {
        return keysByPurpose[_purpose].values();
    }

    function keyHasPurpose(bytes32 _key, uint8 _purpose)
        public
        view
        returns(bool result)
    {
        bool isThere;
        Key memory foundKey = keys[_key];

        if (foundKey.key == 0) return false;
        isThere = foundKey.purpose <= _purpose;
        return isThere;
    }

    function addKey(bytes32 _key, uint8 _purpose, uint8 _type)
        external
        override
        returns (bool success)
    {
        require(keys[_key].key != _key, "Key already exists"); // Key should not already exist
        if (_msgSender() != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.MANAGEMENT_KEY)), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        keys[_key].key = _key;
        keys[_key].purpose = _purpose;
        keys[_key].keyType = _type;

        keysByPurpose[_purpose].add(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }

    function removeKey(bytes32 _key)
        external
        override
        returns (bool success)
    {
        Key memory foundKey = keys[_key];
        require(foundKey.key == _key, "No such key");
        if (_msgSender() != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.MANAGEMENT_KEY)), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }
        emit KeyRemoved(foundKey.key, foundKey.purpose, foundKey.keyType);

        keysByPurpose[foundKey.purpose].remove(_key);
        delete keys[_key];

        return true;
    }

    function execute(address _to, uint256 _value, bytes calldata _data)
        external
        override
        returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.ACTION_KEY))) 
        {
            _safeApprove(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }

    function approve(uint256 _id, bool _approve) 
        external
        override 
    returns (bool success) {
        require(keyHasPurpose(keccak256(abi.encodePacked(_msgSender())), uint8(KeyPurpose.ACTION_KEY)), "Sender does not have action key");

        return _safeApprove(_id, _approve);
    }

    function _safeApprove(uint256 _id, bool _approve)
        internal
        returns (bool success)
    {
        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;
            (success,) = executions[_id].to.call{value: executions[_id].value}(executions[_id].data);
            if (success) {
                executions[_id].executed = true;
                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return false;
            }
        } else {
            executions[_id].approved = false;
        }

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC735 {

    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);    
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + claimType + data
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) external view returns(uint256 claimType, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);
    function getClaimIdsByType(uint256 _claimType) external view returns(bytes32[] memory claimIds);
    function addClaim(uint256 _claimType, uint256 _scheme, address issuer, bytes calldata _signature, bytes calldata _data, string calldata _uri) external returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) external returns (bool success);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC725 {
    event KeyAdded(bytes32 indexed key, uint8 indexed purpose, uint8 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint8 indexed purpose, uint8 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);

    enum KeyPurpose {
        MANAGEMENT_KEY,
        ACTION_KEY,
        CLAIM_SIGNER_KEY,
        ENCRYPTION_KEY
    }
    enum KeyType {
        ECDSA_TYPE,
        RSA_TYPE
    }

    struct Key {
        uint8 purpose; //e.g., MANAGEMENT_KEY = 1, ACTION_KEY = 2, etc.
        uint8 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc.
        bytes32 key;
    }
    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    function getKey(bytes32 _key) external returns(uint8 purpose, uint8 keyType, bytes32 key);
    function getKeyPurpose(bytes32 _key) external returns(uint8 purpose);
    function getKeysByPurpose(uint8 _purpose) external returns(bytes32[] memory keys);
    function addKey(bytes32 _key, uint8 _purpose, uint8 _keyType) external returns (bool success);
    function removeKey(bytes32 _key) external returns (bool success);
    function execute(address _to, uint256 _value, bytes memory _data) external returns (uint256 executionId);
    function approve(uint256 _id, bool _approve) external returns (bool success);
}

// SPDX-License-Identifier: MIT
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