// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../access/ManagedByNFTKEY.sol";
import "../library/CollectionReader.sol";
import "./ICollectionAdmin.sol";

contract CollectionAdmin is ICollectionAdmin, ManagedByNFTKEY {
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(
        address _nftkeyAccessControl,
        bytes32 collectionAdminRole_,
        uint8 maxAdminAddresses_
    ) ManagedByNFTKEY(_nftkeyAccessControl, collectionAdminRole_) {
        _maxAdminAddresses = maxAdminAddresses_;
    }

    uint8 private _maxAdminAddresses;
    mapping(address => CollectionAdminInfo) private _collectionAdminInfo;

    modifier onlyAdmins(address collectionAddress) {
        require(
            isCollectionAdmin(collectionAddress, _msgSender()) ||
                hasAdminRole(_msgSender()),
            "sender not collection admin"
        );
        _;
    }

    /**
     * @dev See {ICollectionAdmin-maxAdminAddresses}.
     */
    function maxAdminAddresses() external view returns (uint8) {
        return _maxAdminAddresses;
    }

    /**
     * @dev See {ICollectionAdmin-collectionAdmins}.
     */
    function collectionAdmins(address collectionAddress)
        public
        view
        returns (AdminInfo[] memory accounts)
    {
        uint256 storedAdminsCount = _collectionAdminInfo[collectionAddress]
            .accounts
            .length();
        if (storedAdminsCount != 0) {
            accounts = new AdminInfo[](storedAdminsCount);

            for (uint256 i = 0; i < storedAdminsCount; i++) {
                address account = _collectionAdminInfo[collectionAddress]
                    .accounts
                    .at(i);
                accounts[i] = _collectionAdminInfo[collectionAddress].adminInfo[
                    account
                ];
            }
        } else {
            address collectionOwner = CollectionReader.collectionOwner(
                collectionAddress
            );
            if (collectionOwner != address(0)) {
                accounts = new AdminInfo[](1);
                accounts[0] = AdminInfo({
                    account: collectionOwner,
                    sender: address(0),
                    note: "Collection Owner"
                });
            }
        }
    }

    /**
     * @dev See {ICollectionAdmin-isCollectionAdmin}.
     */
    function isCollectionAdmin(address collectionAddress, address account)
        public
        view
        returns (bool isAdmin)
    {
        isAdmin = false;

        uint256 storedAdminsCount = _collectionAdminInfo[collectionAddress]
            .accounts
            .length();

        if (storedAdminsCount != 0) {
            isAdmin = _collectionAdminInfo[collectionAddress].accounts.contains(
                    account
                );
        } else {
            address collectionOwner = CollectionReader.collectionOwner(
                collectionAddress
            );
            if (collectionOwner == account) {
                isAdmin = true;
            }
        }
    }

    /**
     * @dev See {ICollectionAdmin-addCollectionAdmin}.
     */
    function addCollectionAdmin(
        address collectionAddress,
        address account,
        string memory note
    ) public onlyAdmins(collectionAddress) {
        uint256 storedAdminsCount = _collectionAdminInfo[collectionAddress]
            .accounts
            .length();

        require(
            storedAdminsCount < _maxAdminAddresses,
            "number of admins have reached limit"
        );

        require(
            !isCollectionAdmin(collectionAddress, account),
            "admin address already exist"
        );

        if (storedAdminsCount == 0) {
            address collectionOwner = CollectionReader.collectionOwner(
                collectionAddress
            );
            if (collectionOwner != address(0)) {
                _collectionAdminInfo[collectionAddress].accounts.add(
                    collectionOwner
                );
                _collectionAdminInfo[collectionAddress].adminInfo[
                    collectionOwner
                ] = AdminInfo({
                    account: collectionOwner,
                    note: "collection Owner",
                    sender: address(0)
                });
            }
        }

        AdminInfo memory newAdmin = AdminInfo({
            account: account,
            sender: _msgSender(),
            note: note
        });

        _collectionAdminInfo[collectionAddress].accounts.add(account);
        _collectionAdminInfo[collectionAddress].adminInfo[account] = newAdmin;

        emit CollectionAdminAdded(
            collectionAddress,
            account,
            _msgSender(),
            note
        );
    }

    /**
     * @dev See {ICollectionAdmin-removeCollectionAdmin}.
     */
    function removeCollectionAdmin(address collectionAddress, address account)
        external
        onlyAdmins(collectionAddress)
    {
        require(
            collectionAdmins(collectionAddress).length > 1,
            "collection should have at least one admin"
        );

        require(
            isCollectionAdmin(collectionAddress, account),
            "admin address doesn't exist"
        );

        _collectionAdminInfo[collectionAddress].accounts.remove(account);
        delete _collectionAdminInfo[collectionAddress].adminInfo[account];

        emit CollectionAdminRemoved(collectionAddress, account, _msgSender());
    }

    /**
     * @dev Set initial admin
     * this function is used only if NFTKEY is requested to set admin address
     * due to unexpected issue related to reading contract owner
     */
    function setCollectionAdmin(
        address collectionAddress,
        address account,
        string memory note
    ) public {
        require(hasAdminRole(_msgSender()), "sender is not admin");

        uint256 storedAdminsCount = _collectionAdminInfo[collectionAddress]
            .accounts
            .length();

        require(storedAdminsCount == 0, "admin already set");

        AdminInfo memory newAdmin = AdminInfo({
            account: account,
            sender: _msgSender(),
            note: note
        });

        _collectionAdminInfo[collectionAddress].accounts.add(account);
        _collectionAdminInfo[collectionAddress].adminInfo[account] = newAdmin;

        emit CollectionAdminAdded(
            collectionAddress,
            account,
            _msgSender(),
            note
        );
    }

    /**
     * @dev See {ICollectionAdmin-updateAccessControlAddress}.
     */
    function updateMaxAdminAddresses(uint8 newMaxAdminAddresses)
        external
        onlyOwner
    {
        require(
            newMaxAdminAddresses >= 1,
            "collection should have at least one admin"
        );

        uint8 oldMaxAdminAddresses = _maxAdminAddresses;
        _maxAdminAddresses = newMaxAdminAddresses;

        emit MaxAdminAddressesChanged(
            oldMaxAdminAddresses,
            newMaxAdminAddresses
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

library CollectionReader {
    function collectionOwner(address collectionAddress)
        internal
        view
        returns (address owner)
    {
        try Ownable(collectionAddress).owner() returns (address _owner) {
            owner = _owner;
        } catch {}
    }

    function tokenOwner(address erc721Address, uint256 tokenId)
        internal
        view
        returns (address owner)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.ownerOf(tokenId) returns (address _owner) {
            owner = _owner;
        } catch {}
    }

    /**
     * @dev check if this contract has approved to transfer this erc721 token
     */
    function isTokenApproved(address erc721Address, uint256 tokenId)
        internal
        view
        returns (bool isApproved)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            if (tokenOperator == address(this)) {
                isApproved = true;
            }
        } catch {}
    }

    /**
     * @dev check if this contract has approved to all of this owner's erc721 tokens
     */
    function isAllTokenApproved(
        address erc721Address,
        address owner,
        address operator
    ) internal view returns (bool isApproved) {
        IERC721 _erc721 = IERC721(erc721Address);

        try _erc721.isApprovedForAll(owner, operator) returns (
            bool _isApproved
        ) {
            isApproved = _isApproved;
        } catch {}
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface ICollectionAdminCheck {
    /**
     * @dev Check if an address is one of the collection admins
     * @param collectionAddress to read admin
     * @param account address to check
     */
    function isCollectionAdmin(address collectionAddress, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ICollectionAdminCheck.sol";

interface ICollectionAdmin is ICollectionAdminCheck {
    struct AdminInfo {
        address account;
        address sender;
        string note;
    }

    struct CollectionAdminInfo {
        EnumerableSet.AddressSet accounts;
        mapping(address => AdminInfo) adminInfo;
    }

    event CollectionAdminAdded(
        address indexed collectionAddress,
        address account,
        address sender,
        string note
    );

    event CollectionAdminRemoved(
        address indexed collectionAddress,
        address account,
        address sender
    );

    event MaxAdminAddressesChanged(
        uint8 previousMaxAdminAddresses,
        uint8 newMaxAdminAddresses
    );

    /**
     * @dev Get max allowed admin addresses count
     */
    function maxAdminAddresses() external view returns (uint8);

    /**
     * @dev Get collection admin list
     * @param collectionAddress to read admin
     * @return list of collection admins
     */
    function collectionAdmins(address collectionAddress)
        external
        view
        returns (AdminInfo[] memory);

    /**
     * @dev Check if an address is one of the collection admins
     * @param collectionAddress to read admin
     * @param account address to check
     */
    function isCollectionAdmin(address collectionAddress, address account)
        external
        view
        returns (bool);

    /**
     * @dev Add admin address
     * @param collectionAddress to add admin address to
     * @param account address
     * @param note a public note admin address
     */
    function addCollectionAdmin(
        address collectionAddress,
        address account,
        string memory note
    ) external;

    /**
     * @dev Remove admin address
     * @param collectionAddress to remove admin address from
     * @param account address to remove
     */
    function removeCollectionAdmin(address collectionAddress, address account)
        external;

    /**
     * @dev Update max allowed admin addresses
     * @param newMaxAdminAddresses new max limit
     */
    function updateMaxAdminAddresses(uint8 newMaxAdminAddresses) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./IManagedByNFTKEY.sol";

abstract contract ManagedByNFTKEY is IManagedByNFTKEY, Ownable {
    constructor(address _nftkeyAccessControl, bytes32 adminRole_) {
        _accessControl = IAccessControl(_nftkeyAccessControl);
        _adminRole = adminRole_;
    }

    IAccessControl private _accessControl;
    bytes32 private _adminRole;

    modifier onlyAdmin() {
        require(hasAdminRole(_msgSender()), "sender is not admin");
        _;
    }

    /**
     * @dev See {IManagedByNFTKEY-hasAdminRole}.
     */
    function hasAdminRole(address account) public view returns (bool hasRole) {
        hasRole = _accessControl.hasRole(_adminRole, account);
    }

    /**
     * @dev See {IManagedByNFTKEY-updateAccessControlAddress}.
     */
    function updateAccessControlAddress(address newAccessControlAddress)
        external
        onlyOwner
    {
        address oldAccessControlAddress = address(_accessControl);
        _accessControl = IAccessControl(newAccessControlAddress);

        emit AccessControlAddressChanged(
            oldAccessControlAddress,
            newAccessControlAddress
        );
    }

    /**
     * @dev See {IManagedByNFTKEY-updateAdminRole}.
     */
    function updateAdminRole(bytes32 newAdminRole) external onlyOwner {
        bytes32 oldAdminRole = _adminRole;
        _adminRole = newAdminRole;

        emit AdminRoleChanged(oldAdminRole, newAdminRole);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IManagedByNFTKEY {
    event AccessControlAddressChanged(
        address previousAccessControlAddress,
        address newAccessControlAddress
    );

    event AdminRoleChanged(bytes32 previousAdminRole, bytes32 newAdminRole);

    /**
     * @dev Check if an address has admins ROLE access
     * @param account address to check
     */
    function hasAdminRole(address account) external view returns (bool);

    /**
     * @dev Update AccessControl Address
     * @param newAccessControlAddress new access control contract address
     */
    function updateAccessControlAddress(address newAccessControlAddress)
        external;

    /**
     * @dev Update ROLE name for admin AccessControl
     * @param newAdminRole new ROLE name for admin AccessControl
     */
    function updateAdminRole(bytes32 newAdminRole) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
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