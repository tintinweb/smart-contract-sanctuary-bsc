// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../access/ManagedByNFTKEY.sol";
import "../collection-admin/ICollectionAdminCheck.sol";
import "./ICollectionRoyaltyRegistry.sol";

contract CollectionRoyaltyRegistry is
    ICollectionRoyaltyRegistry,
    ManagedByNFTKEY,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(
        address _nftkeyAccessControl,
        bytes32 royaltyAdminRole_,
        address collectionAdminRegistry_,
        uint8 maxReceiverAddresses_,
        uint256 maxRoyaltyFraction_
    ) ManagedByNFTKEY(_nftkeyAccessControl, royaltyAdminRole_) {
        _collectionAdminRegistry = ICollectionAdminCheck(
            collectionAdminRegistry_
        );
        _maxReceiverAddresses = maxReceiverAddresses_;
        _maxRoyaltyFraction = maxRoyaltyFraction_;
    }

    ICollectionAdminCheck private _collectionAdminRegistry;

    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public constant INITIATE_RECEIVER_AMOUNT = 1000; // A minimal amount to test account payable
    uint8 private _maxReceiverAddresses;
    uint256 private _maxRoyaltyFraction;

    mapping(address => CollectionRoyaltyInfo) private _collectionRoyalty;

    modifier onlyAdmins(address collectionAddress) {
        require(
            _collectionAdminRegistry.isCollectionAdmin(
                collectionAddress,
                _msgSender()
            ) || hasAdminRole(_msgSender()),
            "sender is not admin"
        );
        _;
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-collectionAdminRegistry}.
     */
    function collectionAdminRegistry() external view returns (address) {
        return address(_collectionAdminRegistry);
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-maxReceiverAddresses}.
     */
    function maxReceiverAddresses() external view returns (uint8) {
        return _maxReceiverAddresses;
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-maxRoyaltyFraction}.
     */
    function maxRoyaltyFraction() external view returns (uint256) {
        return _maxRoyaltyFraction;
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-royaltyInfo}.
     */
    function royaltyInfo(
        address collectionAddress,
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (RoyaltyAmount[] memory royalties) {
        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();

        // If there's royalty registry: use registed share info
        if (registedReceiversCount != 0) {
            royalties = new RoyaltyAmount[](registedReceiversCount);
            for (uint256 i = 0; i < registedReceiversCount; i++) {
                address receiver = _collectionRoyalty[collectionAddress]
                    .accounts
                    .at(i);
                CollectionRoyaltyShare memory share = _collectionRoyalty[
                    collectionAddress
                ].royaltyShare[receiver];
                uint256 royaltyAmount = (salePrice * share.fraction) /
                    FEE_DENOMINATOR;
                royalties[i] = RoyaltyAmount(receiver, royaltyAmount);
            }
        } else {
            // Else if there's 2981, use 2981 settings
            (address receiver, uint256 royaltyAmount) = _royaltyInfoERC2981(
                collectionAddress,
                tokenId,
                salePrice
            );

            if (receiver != address(0) && royaltyAmount != 0) {
                royalties = new RoyaltyAmount[](1);
                royalties[0] = RoyaltyAmount(receiver, royaltyAmount);
            }
        }
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-collectionRoyaltyShares}.
     */
    function collectionRoyaltyShares(address collectionAddress)
        external
        view
        returns (CollectionRoyaltyShare[] memory royaltyShares)
    {
        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();

        if (registedReceiversCount != 0) {
            royaltyShares = new CollectionRoyaltyShare[](
                registedReceiversCount
            );
            for (uint256 i = 0; i < registedReceiversCount; i++) {
                address receiver = _collectionRoyalty[collectionAddress]
                    .accounts
                    .at(i);

                royaltyShares[i] = _collectionRoyalty[collectionAddress]
                    .royaltyShare[receiver];
            }
        }
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-collectionRoyaltySharesOfAccount}.
     */
    function collectionRoyaltySharesOfAccount(
        address collectionAddress,
        address account
    ) public view returns (CollectionRoyaltyShare memory royaltyShare) {
        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();

        if (registedReceiversCount != 0) {
            royaltyShare = _collectionRoyalty[collectionAddress].royaltyShare[
                account
            ];
        }
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-addRoyaltyReceiver}.
     */
    function addRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) external payable onlyAdmins(collectionAddress) {
        require(account != address(0), "receiver cannot be 0 address");
        require(fraction > 0, "fraction cannot be 0");
        require(
            !_collectionRoyalty[collectionAddress].accounts.contains(account),
            "receiver already exist"
        );
        require(
            _collectionRoyalty[collectionAddress].accounts.length() <
                _maxReceiverAddresses,
            "number of receivers reached limit"
        );

        // require max fraction lower than or equal to limit
        uint256 totalFraction;
        totalFraction += fraction;

        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();
        if (registedReceiversCount > 0) {
            for (uint256 i = 0; i < registedReceiversCount; i++) {
                address receiver = _collectionRoyalty[collectionAddress]
                    .accounts
                    .at(i);
                totalFraction += _collectionRoyalty[collectionAddress]
                    .royaltyShare[receiver]
                    .fraction;
            }
        }

        require(
            totalFraction <= _maxRoyaltyFraction,
            "total fraction exceeded limit"
        );

        _addRoyaltyReceiver(collectionAddress, account, fraction);
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-updateRoyaltyReceiver}.
     */
    function updateRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) external onlyAdmins(collectionAddress) {
        require(fraction > 0, "fraction cannot be 0");
        require(
            _collectionRoyalty[collectionAddress].accounts.contains(account),
            "account is not an existing receiver"
        );

        require(
            _collectionRoyalty[collectionAddress]
                .royaltyShare[account]
                .fraction != fraction,
            "fraction is unchanged"
        );

        // require max fraction lower than or equal to limit
        uint256 totalFraction = 0;

        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();
        if (registedReceiversCount > 0) {
            for (uint256 i = 0; i < registedReceiversCount; i++) {
                address receiver = _collectionRoyalty[collectionAddress]
                    .accounts
                    .at(i);
                if (receiver != account) {
                    totalFraction += _collectionRoyalty[collectionAddress]
                        .royaltyShare[receiver]
                        .fraction;
                } else {
                    totalFraction += fraction;
                }
            }
        }

        require(
            totalFraction <= _maxRoyaltyFraction,
            "total fraction exceeded limit"
        );

        _updateRoyaltyReceiver(collectionAddress, account, fraction);
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-removeRoyaltyReceiver}.
     */
    function removeRoyaltyReceiver(address collectionAddress, address account)
        external
        onlyAdmins(collectionAddress)
    {
        require(
            _collectionRoyalty[collectionAddress].accounts.contains(account),
            "account is not an existing receiver"
        );

        _removeRoyaltyReceiver(collectionAddress, account);
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-setRoyaltyReceivers}.
     */
    function setRoyaltyReceivers(
        address collectionAddress,
        address[] calldata receivers,
        uint256[] calldata fractions
    ) external payable onlyAdmins(collectionAddress) {
        require(
            receivers.length == fractions.length,
            "number of receivers and fractions not the same"
        );
        require(
            receivers.length <= _maxReceiverAddresses,
            "number of receivers exceeded limit"
        );

        uint256 totalFraction = 0;
        for (uint256 i = 0; i < receivers.length; i++) {
            require(receivers[i] != address(0), "receiver cannot be 0 address");
            require(fractions[i] > 0, "fraction cannot be 0");

            totalFraction += fractions[i];
            require(
                totalFraction <= _maxRoyaltyFraction,
                "total fraction exceeded limit"
            );
            for (uint256 j = i + 1; j < receivers.length; j++) {
                require(
                    receivers[i] != receivers[j],
                    "duplicated receiver addresses"
                );
            }
        }

        // 1 Go through existing list, delete
        uint256 registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();

        address[] memory accountsToRemove = new address[](
            registedReceiversCount
        );

        for (uint256 i = 0; i < registedReceiversCount; i++) {
            bool found = false;
            address existingAccount = _collectionRoyalty[collectionAddress]
                .accounts
                .at(i);

            for (uint256 j = 0; j < receivers.length; j++) {
                if (existingAccount == receivers[j]) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                accountsToRemove[i] = existingAccount;
            }
        }

        for (uint256 i = 0; i < registedReceiversCount; i++) {
            if (accountsToRemove[i] != address(0)) {
                _removeRoyaltyReceiver(collectionAddress, accountsToRemove[i]);
            }
        }

        // 2 Go through new list add or update
        registedReceiversCount = _collectionRoyalty[collectionAddress]
            .accounts
            .length();

        for (uint256 i = 0; i < receivers.length; i++) {
            bool found = false;
            for (uint256 j = 0; j < registedReceiversCount; j++) {
                if (
                    receivers[i] ==
                    _collectionRoyalty[collectionAddress].accounts.at(j)
                ) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                _addRoyaltyReceiver(
                    collectionAddress,
                    receivers[i],
                    fractions[i]
                );
            } else {
                uint256 currentFraction = _collectionRoyalty[collectionAddress]
                    .royaltyShare[receivers[i]]
                    .fraction;
                if (fractions[i] != currentFraction) {
                    _updateRoyaltyReceiver(
                        collectionAddress,
                        receivers[i],
                        fractions[i]
                    );
                }
            }
        }
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-updateMaxReceiverAddresses}.
     */
    function updateMaxReceiverAddresses(uint8 newMaxReceiverAddresses)
        external
        onlyOwner
    {
        require(
            newMaxReceiverAddresses >= 1,
            "should allow at least one receiver"
        );

        uint8 oldMaxReceiverAddresses = _maxReceiverAddresses;
        _maxReceiverAddresses = newMaxReceiverAddresses;

        emit MaxReceiverAddressesChanged(
            oldMaxReceiverAddresses,
            newMaxReceiverAddresses
        );
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-updateCollectionAdminRegistry}.
     */
    function updateCollectionAdminRegistry(address newCollectionAdminRegistry)
        external
        onlyOwner
    {
        address oldCollectionAdminRegistry = address(_collectionAdminRegistry);
        _collectionAdminRegistry = ICollectionAdminCheck(
            newCollectionAdminRegistry
        );

        emit CollectionAdminRegistryChanged(
            oldCollectionAdminRegistry,
            newCollectionAdminRegistry
        );
    }

    /**
     * @dev See {ICollectionRoyaltyRegistry-updateMaxRoyaltyFraction}.
     */
    function updateMaxRoyaltyFraction(uint256 newMaxRoyaltyFraction)
        external
        onlyOwner
    {
        require(
            newMaxRoyaltyFraction <= FEE_DENOMINATOR,
            "max fraction exceeded denominator"
        );

        uint256 oldMaxRoyaltyFraction = _maxRoyaltyFraction;
        _maxRoyaltyFraction = newMaxRoyaltyFraction;

        emit MaxRoyaltyFractionChanged(
            oldMaxRoyaltyFraction,
            newMaxRoyaltyFraction
        );
    }

    // To receive fund for setting receivers
    receive() external payable {
        emit Received(_msgSender(), msg.value);
    }

    // To withdraw fund if received unreasonable amount
    function withdraw() external onlyOwner {
        uint256 value = address(this).balance;
        Address.sendValue(payable(_msgSender()), value);
        emit Withdrew(_msgSender(), value);
    }

    function _royaltyInfoERC2981(
        address collectionAddress,
        uint256 tokenId,
        uint256 salePrice
    ) private view returns (address receiver, uint256 royaltyAmount) {
        try
            IERC2981(collectionAddress).royaltyInfo(tokenId, salePrice)
        returns (address _receiver, uint256 _royaltyAmount) {
            receiver = _receiver;
            royaltyAmount = _royaltyAmount;

            uint256 maxRoyaltyAmount = (salePrice * _maxRoyaltyFraction) /
                FEE_DENOMINATOR;

            if (royaltyAmount > maxRoyaltyAmount) {
                royaltyAmount = maxRoyaltyAmount;
            }
        } catch {}
    }

    function _addRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) private nonReentrant {
        require(
            address(this).balance >= INITIATE_RECEIVER_AMOUNT,
            "not enough fund to validate receive"
        );

        // This is to make sure this address can receive fund
        Address.sendValue(payable(account), INITIATE_RECEIVER_AMOUNT);

        _collectionRoyalty[collectionAddress].accounts.add(account);
        _collectionRoyalty[collectionAddress].royaltyShare[
                account
            ] = CollectionRoyaltyShare(account, fraction, _msgSender());

        emit RoyaltyReceiverAdded(
            collectionAddress,
            account,
            _msgSender(),
            fraction
        );
    }

    function _updateRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) private {
        CollectionRoyaltyShare memory existingShareInfo = _collectionRoyalty[
            collectionAddress
        ].royaltyShare[account];

        _collectionRoyalty[collectionAddress].royaltyShare[
                account
            ] = CollectionRoyaltyShare(account, fraction, _msgSender());

        emit RoyaltyReceiverUpdated(
            collectionAddress,
            account,
            _msgSender(),
            existingShareInfo.fraction,
            fraction
        );
    }

    function _removeRoyaltyReceiver(address collectionAddress, address account)
        private
    {
        uint256 currentFraction = _collectionRoyalty[collectionAddress]
            .royaltyShare[account]
            .fraction;

        _collectionRoyalty[collectionAddress].accounts.remove(account);
        delete _collectionRoyalty[collectionAddress].royaltyShare[account];

        emit RoyaltyReceiverRemoved(
            collectionAddress,
            account,
            _msgSender(),
            currentFraction
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ICollectionRoyaltyReader.sol";

interface ICollectionRoyaltyRegistry is ICollectionRoyaltyReader {
    struct CollectionRoyaltyShare {
        address receiver;
        uint256 fraction;
        address sender;
    }

    struct CollectionRoyaltyInfo {
        EnumerableSet.AddressSet accounts;
        mapping(address => CollectionRoyaltyShare) royaltyShare;
    }

    event RoyaltyReceiverAdded(
        address indexed collectionAddress,
        address account,
        address sender,
        uint256 fraction
    );

    event RoyaltyReceiverUpdated(
        address indexed collectionAddress,
        address account,
        address sender,
        uint256 oldFraction,
        uint256 newFraction
    );

    event RoyaltyReceiverRemoved(
        address indexed collectionAddress,
        address account,
        address sender,
        uint256 fraction
    );

    event MaxReceiverAddressesChanged(
        uint8 previousMaxReceiverAddresses,
        uint8 newMaxReceiverAddresses
    );

    event CollectionAdminRegistryChanged(
        address previousCollectionAdminRegistry,
        address newCollectionAdminRegistry
    );

    event DefaultRoyaltyFractionChanged(
        uint256 previousDefaultRoyaltyFraction,
        uint256 newDefaultRoyaltyFraction
    );

    event MaxRoyaltyFractionChanged(
        uint256 previousMaxRoyaltyFraction,
        uint256 newMaxRoyaltyFraction
    );

    event Received(address from, uint256 value);
    event Withdrew(address to, uint256 value);

    /**
     * @dev Get collection admin registry contract address
     */
    function collectionAdminRegistry() external view returns (address);

    /**
     * @dev Get max allowed receiver addresses count
     */
    function maxReceiverAddresses() external view returns (uint8);

    /**
     * @dev Get max royalty fraction
     */
    function maxRoyaltyFraction() external view returns (uint256);

    /**
     * @dev Reading collections royalty fraction settings
     * @param collectionAddress to read
     */
    function collectionRoyaltyShares(address collectionAddress)
        external
        view
        returns (CollectionRoyaltyShare[] memory);

    /**
     * @dev Reading collections royalty fraction setting of an address
     * @param collectionAddress to read
     * @param account to read
     */
    function collectionRoyaltySharesOfAccount(
        address collectionAddress,
        address account
    ) external view returns (CollectionRoyaltyShare memory);

    /**
     * @dev Add royalty receiver
     * @param collectionAddress to add royalty receiver to
     * @param account address
     * @param fraction a fraction of shares out of 10000
     */
    function addRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) external payable;

    /**
     * @dev update receiver share
     * @param collectionAddress to add royalty receiver to
     * @param account address
     * @param fraction a fraction of shares out of 10000
     */
    function updateRoyaltyReceiver(
        address collectionAddress,
        address account,
        uint256 fraction
    ) external;

    /**
     * @dev set new list of receivers
     * @param collectionAddress to add royalty receiver to
     * @param receivers addresses
     * @param fractions of each receiver
     */
    function setRoyaltyReceivers(
        address collectionAddress,
        address[] calldata receivers,
        uint256[] calldata fractions
    ) external payable;

    /**
     * @dev Remove royalty receiver
     * @param collectionAddress to remove royalty receiver from
     * @param account address
     */
    function removeRoyaltyReceiver(address collectionAddress, address account)
        external;

    /**
     * @dev Update max allowed receiver addresses
     * @param newMaxReceiverAddresses new max limit
     */
    function updateMaxReceiverAddresses(uint8 newMaxReceiverAddresses) external;

    /**
     * @dev Update collection admin registry address
     * @param newCollectionAdminRegistry new collection admin registry contract
     */
    function updateCollectionAdminRegistry(address newCollectionAdminRegistry)
        external;

    /**
     * @dev Update max royalty fraction
     * @param newMaxRoyaltyFraction new max fraction
     */
    function updateMaxRoyaltyFraction(uint256 newMaxRoyaltyFraction) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface ICollectionRoyaltyReader {
    struct RoyaltyAmount {
        address receiver;
        uint256 royaltyAmount;
    }

    /**
     * @dev Get collection royalty receiver list
     * @param collectionAddress to read royalty receiver
     * @return list of royalty receivers and their shares
     */
    function royaltyInfo(
        address collectionAddress,
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (RoyaltyAmount[] memory);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

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