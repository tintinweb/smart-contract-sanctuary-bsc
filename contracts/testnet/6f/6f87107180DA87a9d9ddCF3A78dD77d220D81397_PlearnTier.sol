// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IMasterchef.sol";
import "./interfaces/ILockPool.sol";
import "./interfaces/IFoundingInvestorPool.sol";
import "./interfaces/IPlearnTier.sol";
import "./libraries/StringExtension.sol";
import "./libraries/BytesExtension.sol";
import "./Tier.sol";

contract PlearnTier is IPlearnTier, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using StringExtension for string;
    using BytesExtension for bytes32;

    EnumerableSet.AddressSet private lockPools;
    EnumerableSet.AddressSet private foundingInvestorPools;
    Tier[] public tiers;
    IMasterchef public masterchef;

    event NewTier(string id, string name, uint256 minimumAmount);
    event TierUpdate(string id, string name, uint256 minimumAmount);
    event TierRemove(string id);

    //Owner functions

    function setMasterchef(address masterchefAddress) external onlyOwner {
        masterchef = IMasterchef(masterchefAddress);
    }

    function addLockPool(address[] memory pools) external onlyOwner {
        for (uint256 i = 0; i < pools.length; i++) {
            address pool = pools[i];
            if (_poolNotExists(pool)) {
                EnumerableSet.add(lockPools, pool);
            }
        }
    }

    function removeLockPool(address[] memory pools) external onlyOwner {
        for (uint256 i = 0; i < pools.length; i++) {
            EnumerableSet.remove(lockPools, pools[i]);
        }
    }

    function addFoundingInvestorPool(address[] memory pools)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < pools.length; i++) {
            address pool = pools[i];
            if (_poolNotExists(pool)) {
                EnumerableSet.add(foundingInvestorPools, pool);
            }
        }
    }

    function removeFoundingInvestorPool(address[] memory pools)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < pools.length; i++) {
            EnumerableSet.remove(foundingInvestorPools, pools[i]);
        }
    }

    function addTier(
        string memory id,
        string memory name,
        uint256 minimumAmount
    ) external onlyOwner {
        require(id.isNotEmpty(), "PlearnTier: Id is empty");
        require(name.isNotEmpty(), "PlearnTier: Name is empty");
        require(_getTierIndex(id) < 0, "PlearnTier: Tier already exists");
        tiers.push(Tier({id: id, name: name, minimumAmount: minimumAmount}));
        emit NewTier(id, name, minimumAmount);
    }

    function updateTier(
        string memory id,
        string memory name,
        uint256 minimumAmount
    ) external onlyOwner {
        require(id.isNotEmpty(), "PlearnTier: Id is empty");
        require(name.isNotEmpty(), "PlearnTier: Name is empty");
        int256 index = _getTierIndex(id);
        require(index >= 0, "PlearnTier: Tier not exists");
        tiers[uint256(index)] = Tier({
            id: id,
            name: name,
            minimumAmount: minimumAmount
        });
        emit TierUpdate(id, name, minimumAmount);
    }

    function removeTier(string memory id) external onlyOwner {
        int256 index = _getTierIndex(id);
        require(index >= 0, "PlearnTier: Tier not exists");
        _removeTier(uint256(index));
        emit TierRemove(id);
    }

    //Public functions

    function getLockPools(uint256 cursor, uint256 size)
        public
        view
        returns (address[] memory)
    {
        uint256 length = size;
        if (cursor < _lockPoolLength()) {
            length = _lockPoolLength() - cursor;
        } else {
            length = 0;
        }

        address[] memory pools = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            pools[i] = EnumerableSet.at(lockPools, cursor + i);
        }
        return pools;
    }

    function getFoundingInvestorPools(uint256 cursor, uint256 size)
        public
        view
        returns (address[] memory)
    {
        uint256 length = size;
        if (cursor < _foundingInvestorPoolLength()) {
            length = _foundingInvestorPoolLength() - cursor;
        } else {
            length = 0;
        }

        address[] memory pools = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            pools[i] = EnumerableSet.at(foundingInvestorPools, cursor + i);
        }
        return pools;
    }

    function getBanlanceOfStandardPool(address user)
        public
        view
        returns (uint256)
    {
        (uint256 amount, ) = masterchef.userInfo(0, user);
        return amount;
    }

    function getBanlanceOfLockPool(ILockPool pool, address user)
        public
        view
        returns (uint256)
    {
        (uint256 amount, ) = pool.userInfo(user);
        return amount;
    }

    function getBanlanceOfFoundingInvestorPool(
        IFoundingInvestorPool pool,
        address user
    ) public view returns (uint256) {
        (, uint256 amount, ) = pool.userInfo(user);
        return amount;
    }

    function getTotalStake(address user) public view returns (uint256) {
        uint256 totalStake = 0;
        //Standard pool
        totalStake += getBanlanceOfStandardPool(user);
        //Locked pools
        for (uint256 i = 0; i < _lockPoolLength(); i++) {
            address pool = EnumerableSet.at(lockPools, i);
            if (pool != address(0)) {
                totalStake += getBanlanceOfLockPool(ILockPool(pool), user);
            }
        }
        //Founding Investor pools
        for (uint256 i = 0; i < _foundingInvestorPoolLength(); i++) {
            address pool = EnumerableSet.at(foundingInvestorPools, i);
            totalStake += getBanlanceOfFoundingInvestorPool(
                IFoundingInvestorPool(pool),
                user
            );
        }
        return totalStake;
    }

    function getTierOf(address user)
        external
        view
        override
        returns (Tier memory)
    {
        uint256 totalStake = getTotalStake(user);
        Tier memory currentTier;
        for (uint256 i = 0; i < tiers.length; i++) {
            Tier memory tier = tiers[i];
            if (
                totalStake >= tier.minimumAmount &&
                tier.minimumAmount > currentTier.minimumAmount
            ) {
                currentTier = tier;
            }
        }
        return currentTier;
    }

    function isFoundingInvestor(address user) public view returns (bool) {
        bool isInvestor = false;
        for (uint256 i = 0; i < _foundingInvestorPoolLength(); i++) {
            address pool = EnumerableSet.at(foundingInvestorPools, i);
            isInvestor = IFoundingInvestorPool(pool).isInvestor(user);
            if (isInvestor) {
                break;
            }
        }
        return isInvestor;
    }

    function isInTier(string memory id, address user)
        external
        view
        override
        returns (bool)
    {
        int256 index = _getTierIndex(id);
        require(index >= 0, "PlearnTier: Tier not exists");
        uint256 totalStake = getTotalStake(user);
        Tier memory tier = tiers[uint256(index)];
        return totalStake >= tier.minimumAmount;
    }

    function tierLength() public view returns (uint256) {
        return tiers.length;
    }

    function tierIsExists(string memory id)
        external
        view
        override
        returns (bool)
    {
        return _getTierIndex(id) >= 0;
    }

    //Internal Functions

    function _removeTier(uint256 index) internal {
        //Ship element in array
        for (uint256 i = index; i < tiers.length - 1; i++) {
            tiers[i] = tiers[i + 1];
        }
        tiers.pop();
    }

    function _getTierIndex(string memory id) internal view returns (int256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (id.equal(tiers[i].id)) {
                return int256(i);
            }
        }
        return -1;
    }

    function _poolNotExists(address pool) internal view returns (bool) {
        require(
            !EnumerableSet.contains(lockPools, pool) &&
                !EnumerableSet.contains(foundingInvestorPools, pool),
            string(
                abi.encodePacked(
                    "PlearnTier: Pool ",
                    Strings.toHexString(uint160(pool), 20),
                    " already exists"
                )
            )
        );
        return true;
    }

    function _lockPoolLength() internal view returns (uint256) {
        return EnumerableSet.length(lockPools);
    }

    function _foundingInvestorPoolLength() public view returns (uint256) {
        return EnumerableSet.length(foundingInvestorPools);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMasterchef {
    function userInfo(uint256 pId, address user)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILockPool {
    function userInfo(address user)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFoundingInvestorPool {
    function userInfo(address user)
        external
        view
        returns (
            uint256 initialAmount,
            uint256 amount,
            uint256 rewardDebt
        );

    function isInvestor(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Tier.sol";

interface IPlearnTier {
    function getTierOf(address user) external view returns (Tier memory);

    function isInTier(string memory id, address user) external view returns (bool);

    function tierIsExists(string memory id) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

library StringExtension {
    using Strings for string;

    function equal(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return
                keccak256(abi.encodePacked(a)) ==
                keccak256(abi.encodePacked(b));
        }
    }

    function isEmpty(string memory source) internal pure returns (bool) {
        return bytes(source).length == 0;
    }

    function isNotEmpty(string memory source) internal pure returns (bool) {
        return bytes(source).length > 0;
    }

    function toBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory stringBytes = bytes(source);
        if (stringBytes.length == 0) {
            return 0x0;
        }
        // https://ethereum.stackexchange.com/questions/9603/understanding-mload-assembly-function
        // http://solidity.readthedocs.io/en/latest/assembly.html
        assembly {
            result := mload(add(source, 32))
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library BytesExtension {
    function toString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Tier {
    string id;
    string name;
    uint256 minimumAmount;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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