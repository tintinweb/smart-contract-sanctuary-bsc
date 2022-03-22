// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
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

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./libraries/DiggerDetails.sol";
import "./interfaces/IDiggerDesign.sol";
import "./extensions/Utils.sol";

contract DiggerDesign is AccessControlUpgradeable, IDiggerDesign {
    struct StatsRange {
        uint256 min;
        uint256 max;
    }

    struct Stats {
        StatsRange stamina;
        StatsRange farmSpeed;
        StatsRange power;
        StatsRange walkSpeed;
    }

    using DiggerDetails for DiggerDetails.Details;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");

    uint256 private constant SKIN_COUNT = 8;

    // Mapping from rarity to stats.
    mapping(uint256 => Stats) private rarityStats;

    uint256 private tokenLimit;
    uint256[] private dropRate;
    uint256 private mintCost;
    uint256 private maxLevel;
    uint256 private upgradePowerDiggerCost;
    uint256[][] private upgradeCosts;

    function initialize() public initializer {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);
        _setupRole(DESIGNER_ROLE, msg.sender);

        rarityStats[0] = Stats(
            StatsRange(1, 3),
            StatsRange(1, 3),
            StatsRange(1, 3),
            StatsRange(1, 3)
        );
        rarityStats[1] = Stats(
            StatsRange(3, 6),
            StatsRange(3, 6),
            StatsRange(3, 6),
            StatsRange(3, 6)
        );
        rarityStats[2] = Stats(
            StatsRange(6, 9),
            StatsRange(6, 9),
            StatsRange(6, 9),
            StatsRange(6, 9)
        );
        rarityStats[3] = Stats(
            StatsRange(9, 12),
            StatsRange(9, 12),
            StatsRange(9, 12),
            StatsRange(9, 12)
        );
        rarityStats[4] = Stats(
            StatsRange(12, 15),
            StatsRange(12, 15),
            StatsRange(12, 15),
            StatsRange(12, 15)
        );
        rarityStats[5] = Stats(
            StatsRange(15, 18),
            StatsRange(15, 18),
            StatsRange(15, 18),
            StatsRange(15, 18)
        );
        tokenLimit = 500;
        dropRate = [7287, 2036, 518, 104, 52, 4];
        mintCost = 10 ether;
        upgradePowerDiggerCost = 2 ether;
        maxLevel = 5;
        upgradeCosts.push([1 ether, 2 ether, 4 ether, 7 ether]);
        upgradeCosts.push([2 ether, 4 ether, 5 ether, 9 ether]);
        upgradeCosts.push([2 ether, 4 ether, 5 ether, 10 ether]);
        upgradeCosts.push([3 ether, 7 ether, 11 ether, 22 ether]);
        upgradeCosts.push([7 ether, 18 ether, 40 ether, 146 ether]);
        upgradeCosts.push([9 ether, 25 ether, 56 ether, 199 ether]);
    }

    /** Sets the rarity stats. */
    function setRarityStats(uint256 rarity, Stats memory stats)
        external
        onlyRole(DESIGNER_ROLE)
    {
        rarityStats[rarity] = stats;
    }

    /** Sets the token limit. */
    function setTokenLimit(uint256 value) external onlyRole(DESIGNER_ROLE) {
        tokenLimit = value;
    }

    /** Sets the drop rate. */
    function setDropRate(uint256[] memory value)
        external
        onlyRole(DESIGNER_ROLE)
    {
        dropRate = value;
    }

    /** Sets the minting fee. */
    function setMintCost(uint256 value) external onlyRole(DESIGNER_ROLE) {
        mintCost = value;
    }

    /** Sets max upgrade level. */
    function setMaxLevel(uint256 value) external onlyRole(DESIGNER_ROLE) {
        maxLevel = value;
    }

    /** Sets the current upgrade cost. */
    function setUpgradeCosts(uint256[][] memory value)
        external
        onlyRole(DESIGNER_ROLE)
    {
        upgradeCosts = value;
    }

    function setUpgradePowerDiggerCost(uint256 value)
        external
        onlyRole(DESIGNER_ROLE)
    {
        upgradePowerDiggerCost = value;
    }

    function getRarityStats() external view returns (Stats[] memory) {
        uint256 size = dropRate.length;
        Stats[] memory result = new Stats[](size);
        for (uint256 i = 0; i < size; ++i) {
            result[i] = rarityStats[i];
        }
        return result;
    }

    function getTokenLimit() external view override returns (uint256) {
        return tokenLimit;
    }

    function getDropRate() external view returns (uint256[] memory) {
        return dropRate;
    }

    function getMintCost() external view override returns (uint256) {
        return mintCost;
    }

    function getMaxLevel() external view override returns (uint256) {
        return maxLevel;
    }

    function getUpgradeCost(uint256 rarity, uint256 level)
        external
        view
        override
        returns (uint256)
    {
        return upgradeCosts[rarity][level];
    }

    function getUpgradeCosts() external view returns (uint256[][] memory) {
        return upgradeCosts;
    }

    function getUpgradePowerDiggerCost()
        external
        view
        override
        returns (uint256)
    {
        return upgradePowerDiggerCost;
    }

    function createRandomToken(
        uint256 seed,
        uint256 id,
        uint256 rarity
    )
        external
        view
        override
        returns (uint256 nextSeed, uint256 encodedDetails)
    {
        DiggerDetails.Details memory details;
        details.id = id;

        if (rarity == DiggerDetails.ALL_RARITY) {
            // Random rarity.
            (seed, details.rarity) = Utils.weightedRandom(seed, dropRate);
        } else {
            // Specified rarity.
            details.rarity = rarity - 1;
        }
        details.level = 1;

        Stats storage stats = rarityStats[details.rarity];

        (seed, details.skin) = Utils.randomRangeInclusive(seed, 1, SKIN_COUNT);
        (seed, details.stamina) = Utils.randomRangeInclusive(
            seed,
            stats.stamina.min,
            stats.stamina.max
        );
        (seed, details.farmSpeed) = Utils.randomRangeInclusive(
            seed,
            stats.farmSpeed.min,
            stats.farmSpeed.max
        );
        (seed, details.walkSpeed) = Utils.randomRangeInclusive(
            seed,
            stats.walkSpeed.min,
            stats.walkSpeed.max
        );
        (seed, details.power) = Utils.randomRangeInclusive(
            seed,
            stats.power.min,
            stats.power.max
        );
        details.blockNumber = block.number;

        nextSeed = seed;
        encodedDetails = details.encode();
    }

    function createToken(
        uint256 id,
        uint256 rarity,
        uint256 level,
        uint256 walkSpeed,
        uint256 skin,
        uint256 stamina,
        uint256 farmSpeed,
        uint256 power,
        uint256 blockNumber
    ) external view override returns (uint256 encodedDetails) {
        DiggerDetails.Details memory details;
        details.id = id;
        details.rarity = rarity;
        details.level = level;
        details.walkSpeed = walkSpeed;
        details.skin = skin;
        details.stamina = stamina;
        details.farmSpeed = farmSpeed;
        details.power = power;
        details.blockNumber = blockNumber;
        encodedDetails = details.encode();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
  function randomSeed(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), block.difficulty, seed)));
  }

  /// Random [0, modulus)
  function random(uint256 seed, uint256 modulus) internal view returns (uint256 nextSeed, uint256 result) {
    nextSeed = randomSeed(seed);
    result = nextSeed % modulus;
  }

  /// Random [from, to)
  function randomRange(
    uint256 seed,
    uint256 from,
    uint256 to
  ) internal view returns (uint256 nextSeed, uint256 result) {
    require(from < to, "Invalid random range");
    (nextSeed, result) = random(seed, to - from);
    result += from;
  }

  /// Random [from, to]
  function randomRangeInclusive(
    uint256 seed,
    uint256 from,
    uint256 to
  ) internal view returns (uint256 nextSeed, uint256 result) {
    return randomRange(seed, from, to + 1);
  }

  /// Weighted random.
  function weightedRandom(uint256 seed, uint256[] memory weights)
    internal
    view
    returns (uint256 nextSeed, uint256 index)
  {
    require(weights.length > 0, "Array must not empty");
    uint256 totalWeight;
    for (uint256 i = 0; i < weights.length; ++i) {
      totalWeight += weights[i];
    }
    uint256 randMod;
    (seed, randMod) = randomRange(seed, 0, totalWeight);
    uint256 total;
    for (uint256 i = 0; i < weights.length; i++) {
      total += weights[i];
      if (randMod < total) {
        return (seed, i);
      }
    }
    return (seed, 0);
  }

  /// Reservoir sampling.
  function randomSampling(
    uint256 seed,
    uint256[] storage arr,
    uint256 size
  ) internal view returns (uint256 nextSeed, uint256[] memory result) {
    require(arr.length >= size, "Invalid sampling size");
    result = new uint256[](size);
    for (uint256 i = 0; i < size; ++i) {
      result[i] = arr[i];
    }
    uint256 j;
    for (uint256 i = size; i < arr.length; ++i) {
      (seed, j) = randomRangeInclusive(seed, 0, i);
      if (j < size) {
        result[j] = arr[i];
      }
    }
    nextSeed = seed;
  }

  function weightedRandomSampling(
    uint256 seed,
    uint256[] storage arr,
    uint256[] memory weights,
    uint256 size
  ) internal view returns (uint256 nextSeed, uint256[] memory result) {
    require(arr.length >= size, "Invalid sampling size");
    result = new uint256[](size);
    uint256 index;
    for (uint256 i = 0; i < size; ++i) {
      (seed, index) = weightedRandom(seed, weights);
      weights[index] = 0;
      result[i] = arr[index];
    }
    nextSeed = seed;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface IDiggerDesign {
    function getTokenLimit() external view returns (uint256);

    function getMintCost() external view returns (uint256);

    function getMaxLevel() external view returns (uint256);

    function getUpgradeCost(uint256 rarity, uint256 level)
        external
        view
        returns (uint256);

    function getUpgradePowerDiggerCost() external view returns (uint256);

    function createRandomToken(
        uint256 seed,
        uint256 id,
        uint256 rarity
    ) external view returns (uint256 nextSeed, uint256 encodedDetails);

    function createToken(
        uint256 id,
        uint256 rarity,
        uint256 level,
        uint256 walkSpeed,
        uint256 skin,
        uint256 stamina,
        uint256 farmSpeed,
        uint256 power,
        uint256 blockNumber
    ) external view returns (uint256 encodedDetails);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library DiggerDetails {
  uint256 public constant ALL_RARITY = 0;

  struct Details {
    uint256 id;
    uint256 index;
    uint256 rarity;
    uint256 level;
    uint256 skin;
    uint256 stamina;
    uint256 farmSpeed;
    uint256 power;
    uint256 walkSpeed;
    uint256 blockNumber;
  }

  function encode(Details memory details) internal pure returns (uint256) {
    uint256 value;
    value |= details.id;
    value |= details.index << 30;
    value |= details.rarity << 40;
    value |= details.level << 45;
    value |= details.skin << 50;
    value |= details.stamina << 55;
    value |= details.farmSpeed << 60;
    value |= details.power << 65;
    value |= details.walkSpeed << 70;
    value |= details.blockNumber << 75;
    return value;
  }

  function decode(uint256 details) internal pure returns (Details memory result) {
    result.id = decodeId(details);
    result.index = decodeIndex(details);
    result.rarity = decodeRarity(details);
    result.level = decodeLevel(details);
    result.skin = (details >> 50) & 31;
    result.stamina = (details >> 55) & 31;
    result.farmSpeed = (details >> 60) & 31;
    result.power = (details >> 65) & 31;
    result.walkSpeed = (details >> 70) & 31;
    result.blockNumber = decodeBlockNumber(details);
  }

  function decodeId(uint256 details) internal pure returns (uint256) {
    return details & ((1 << 30) - 1);
  }

  function decodeIndex(uint256 details) internal pure returns (uint256) {
    return (details >> 30) & ((1 << 10) - 1);
  }

  function decodeRarity(uint256 details) internal pure returns (uint256) {
    return (details >> 40) & 31;
  }

  function decodeLevel(uint256 details) internal pure returns (uint256) {
    return (details >> 45) & 31;
  }

  function decodeBlockNumber(uint256 details) internal pure returns (uint256) {
    uint256 value = (details >> 80) & ((1 << 30) - 1);
    return value > 0 ? value : 15323374; /* Testnet */
  }

  function increaseLevel(uint256 details) internal pure returns (uint256) {
    uint256 level = decodeLevel(details);
    details &= ~(uint256(31) << 45);
    details |= (level + 1) << 45;
    return details;
  }

  function setIndex(uint256 details, uint256 index) internal pure returns (uint256) {
    details &= ~(uint256(1023) << 30);
    details |= index << 30;
    return details;
  }
}