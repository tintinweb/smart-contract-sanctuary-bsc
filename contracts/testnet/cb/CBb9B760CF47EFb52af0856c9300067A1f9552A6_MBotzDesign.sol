// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MBotzDesign is AccessControl {
    /// @dev Create the community role, with `root` as a member.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @dev Restricted to members of the community.
    modifier onlyMember() {
        require(isMember(msg.sender), "Restricted to members.");
        _;
    }

    /// @dev Return `true` if the `account` belongs to the community.
    function isMember(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Add a member of the community.
    function addMember(address account) public virtual onlyMember {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Remove oneself as a member of the community.
    function leaveCommunity() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    //Merging Cost per Level and rarity
    uint256 public MERGE_COST_COMMON_LVL2 = 1 ether;
    uint256 public MERGE_COST_RARE_LVL2 = 2 ether;
    uint256 public MERGE_COST_EPIC_LVL2 = 2 ether;
    uint256 public MERGE_COST_LEGENDARY_LVL2 = 3 ether;
    uint256 public MERGE_COST_DIVINE_LVL2 = 7 ether;
    uint256 public MERGE_COST_IMMORTAL_LVL2 = 9 ether;

    uint256 public MERGE_COST_COMMON_LVL3 = 2 ether;
    uint256 public MERGE_COST_RARE_LVL3 = 4 ether;
    uint256 public MERGE_COST_EPIC_LVL3 = 4 ether;
    uint256 public MERGE_COST_LEGENDARY_LVL3 = 7 ether;
    uint256 public MERGE_COST_DIVINE_LVL3 = 18 ether;
    uint256 public MERGE_COST_IMMORTAL_LVL3 = 25 ether;

    uint256 public MERGE_COST_COMMON_LVL4 = 4 ether;
    uint256 public MERGE_COST_RARE_LVL4 = 5 ether;
    uint256 public MERGE_COST_EPIC_LVL4 = 5 ether;
    uint256 public MERGE_COST_LEGENDARY_LVL4 = 11 ether;
    uint256 public MERGE_COST_DIVINE_LVL4 = 40 ether;
    uint256 public MERGE_COST_IMMORTAL_LVL4 = 56 ether;

    uint256 public MERGE_COST_COMMON_LVL5 = 7 ether;
    uint256 public MERGE_COST_RARE_LVL5 = 9 ether;
    uint256 public MERGE_COST_EPIC_LVL5 = 10 ether;
    uint256 public MERGE_COST_LEGENDARY_LVL5 = 22 ether;
    uint256 public MERGE_COST_DIVINE_LVL5 = 146 ether;
    uint256 public MERGE_COST_IMMORTAL_LVL5 = 199 ether;

    uint256 public accountBotLimit = 101;
    uint256 public accountBotLevelLimit = 6;

    function getMergingCost(uint256 _rarity, uint256 _level)
        external
        view
        returns (uint256)
    {
        uint256 cost;
        if (_level == 1) {
            if (_rarity == 1) {
                cost = MERGE_COST_COMMON_LVL2;
            } else if (_rarity == 2) {
                cost = MERGE_COST_RARE_LVL2;
            } else if (_rarity == 3) {
                cost = MERGE_COST_EPIC_LVL2;
            } else if (_rarity == 4) {
                cost = MERGE_COST_LEGENDARY_LVL2;
            } else if (_rarity == 5) {
                cost = MERGE_COST_DIVINE_LVL2;
            } else {
                cost = MERGE_COST_IMMORTAL_LVL2;
            }
        } else if (_level == 2) {
            if (_rarity == 1) {
                cost = MERGE_COST_COMMON_LVL3;
            } else if (_rarity == 2) {
                cost = MERGE_COST_RARE_LVL3;
            } else if (_rarity == 3) {
                cost = MERGE_COST_EPIC_LVL3;
            } else if (_rarity == 4) {
                cost = MERGE_COST_LEGENDARY_LVL3;
            } else if (_rarity == 5) {
                cost = MERGE_COST_DIVINE_LVL3;
            } else {
                cost = MERGE_COST_IMMORTAL_LVL3;
            }
        } else if (_level == 3) {
            if (_rarity == 1) {
                cost = MERGE_COST_COMMON_LVL4;
            } else if (_rarity == 2) {
                cost = MERGE_COST_RARE_LVL4;
            } else if (_rarity == 3) {
                cost = MERGE_COST_EPIC_LVL4;
            } else if (_rarity == 4) {
                cost = MERGE_COST_LEGENDARY_LVL4;
            } else if (_rarity == 5) {
                cost = MERGE_COST_DIVINE_LVL4;
            } else {
                cost = MERGE_COST_IMMORTAL_LVL4;
            }
        } else {
            if (_rarity == 1) {
                cost = MERGE_COST_COMMON_LVL5;
            } else if (_rarity == 2) {
                cost = MERGE_COST_RARE_LVL5;
            } else if (_rarity == 3) {
                cost = MERGE_COST_EPIC_LVL5;
            } else if (_rarity == 4) {
                cost = MERGE_COST_LEGENDARY_LVL5;
            } else if (_rarity == 5) {
                cost = MERGE_COST_DIVINE_LVL5;
            } else {
                cost = MERGE_COST_IMMORTAL_LVL5;
            }
        }
        return cost;
    }


    function rand() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp + block.difficulty)))%10001;
    }

    function createRandomRarity() external view returns (uint256 raritys) {
        uint256 chance = rand();
        uint256 rarity = 0;

        if(chance > 3100){ //mint common 70%
            rarity = 1;
        }else if(chance>1100 && chance<=3100){ //mint Rare 20% //3100 = 1100 + 2000
            rarity=2;
        }else if(chance>600 && chance<=1100){  //mint Epic 5% //1100 = 600 + 500
            rarity=3;
        }else if(chance>300 && chance<=600){ //mint Legendary 3% //600 = 300 + 300
            rarity=4;
        }else if(chance>100 && chance<=300){  //mint divine 2% //300 = 100 + 200
            rarity=5;
        }else{  //mint immortal 1%
            rarity=6;
        }
        return (rarity);
    }

    function createRandomRarity2() external view returns (uint256 raritys) {
        uint256 chance = rand();
        uint256 rarity = 0;

        if(chance > 1714){ //mint common 82%
            rarity = 1;
        }else if(chance>678 && chance<=1714){ //mint Rare 10.36% //678 = 678 + 1036
            rarity=2;
        }else if(chance>160 && chance<=678){ //mint Epic 5.18% //678 = 160 + 518
            rarity=3;
        }else if(chance>56 && chance<=160){ //mint Legendary 1.04% //160 = 56 + 104
            rarity=4;
        }else if(chance>4 && chance<=56){ //mint divine 0.52% //56 = 52 + 4
            rarity=5;
        }else{ //mint immortal 0.04%
            rarity=6;
        }
        return (rarity);
    }

    function createRandomAttributes(uint256 _rarity) external view returns ( uint256 _power, uint256 _energy, uint256 _speed )
    {
        uint256 power = 0;
        uint256 energy = 0;
        uint256 speed = 0;
        if (_rarity == 1) {
            (_power, _energy, _speed) = _createRandomNum(3);
            power = 1 + _power;
            energy = 1 + _energy;
            speed = 1 + _speed;
        } else if (_rarity == 2) {
            (_power, _energy, _speed) = _createRandomNum(4);
            power = 3 + _power;
            energy = 3 + _energy;
            speed = 3 + _speed;
        } else if (_rarity == 3) {
            (_power, _energy, _speed) = _createRandomNum(4);
            power = 6 + _power;
            energy = 6 + _energy;
            speed = 6 + _speed;
        } else if (_rarity == 4) {
            (_power, _energy, _speed) = _createRandomNum(4);
            power = 9 + _power;
            energy = 9 + _energy;
            speed = 9 + _speed;
        } else if (_rarity == 5) {
            (_power, _energy, _speed) = _createRandomNum(4);
            power = 12 + _power;
            energy = 12 + _energy;
            speed = 12 + _speed;
        } else if (_rarity == 6) {
            (_power, _energy, _speed) = _createRandomNum(4);
            power = 15 + _power;
            energy = 15 + _energy;
            speed = 15 + _speed;
        } else {
            power = 0;
            energy = 0;
            speed = 0;
        }
        return (power, energy, speed);
    }

    function _createRandomNum(uint256 _mod) internal view returns (  uint256, uint256, uint256 )
    {
        uint256 randNonce = 0;
        uint256 randomBase = uint256( keccak256(abi.encodePacked(block.timestamp + block.difficulty, msg.sender, randNonce))  );
        uint256 random = randomBase % _mod;
        randNonce++;
        uint256 random2 = (randomBase / _mod) % _mod;
        randNonce++;
        uint256 random3 = (randomBase / _mod / _mod) % _mod;
        randNonce++;
        return (random, random2, random3);
    }

    // Set Merging Cost
    function setMergingCost(
        uint256 _rarity,
        uint256 _level,
        uint256 newCost
    ) external returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );

        if (_level == 1) {
            if (_rarity == 1) {
                MERGE_COST_COMMON_LVL2 = newCost;
            } else if (_rarity == 2) {
                MERGE_COST_RARE_LVL2 = newCost;
            } else if (_rarity == 3) {
                MERGE_COST_EPIC_LVL2 = newCost;
            } else if (_rarity == 4) {
                MERGE_COST_LEGENDARY_LVL2 = newCost;
            } else if (_rarity == 5) {
                MERGE_COST_DIVINE_LVL2 = newCost;
            } else {
                MERGE_COST_IMMORTAL_LVL2 = newCost;
            }
        } else if (_level == 2) {
            if (_rarity == 1) {
                MERGE_COST_COMMON_LVL3 = newCost;
            } else if (_rarity == 2) {
                MERGE_COST_RARE_LVL3 = newCost;
            } else if (_rarity == 3) {
                MERGE_COST_EPIC_LVL3 = newCost;
            } else if (_rarity == 4) {
                MERGE_COST_LEGENDARY_LVL3 = newCost;
            } else if (_rarity == 5) {
                MERGE_COST_DIVINE_LVL3 = newCost;
            } else {
                MERGE_COST_IMMORTAL_LVL3 = newCost;
            }
        } else if (_level == 3) {
            if (_rarity == 1) {
                MERGE_COST_COMMON_LVL4 = newCost;
            } else if (_rarity == 2) {
                MERGE_COST_RARE_LVL4 = newCost;
            } else if (_rarity == 3) {
                MERGE_COST_EPIC_LVL4 = newCost;
            } else if (_rarity == 4) {
                MERGE_COST_LEGENDARY_LVL4 = newCost;
            } else if (_rarity == 5) {
                MERGE_COST_DIVINE_LVL4 = newCost;
            } else {
                MERGE_COST_IMMORTAL_LVL4 = newCost;
            }
        } else {
            if (_rarity == 1) {
                MERGE_COST_COMMON_LVL5 = newCost;
            } else if (_rarity == 2) {
                MERGE_COST_RARE_LVL5 = newCost;
            } else if (_rarity == 3) {
                MERGE_COST_EPIC_LVL5 = newCost;
            } else if (_rarity == 4) {
                MERGE_COST_LEGENDARY_LVL5 = newCost;
            } else if (_rarity == 5) {
                MERGE_COST_DIVINE_LVL5 = newCost;
            } else {
                MERGE_COST_IMMORTAL_LVL5 = newCost;
            }
        }
        return true;
    }

    function getAccountBotLimit() external view returns (uint256) {
        return accountBotLimit;
    }

    function getAccountBotLevelLimit() external view returns (uint256) {
        return accountBotLevelLimit;
    }

    function setAccountBotLimit(uint256 newLimit) external returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        accountBotLimit = newLimit;
        return true;
    }

    function setAccountBotLevelLimit(uint256 newLevelLimit)
        external
        returns (bool)
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        accountBotLevelLimit = newLevelLimit;
        return true;
    }

    function setRandomAttribues(uint256 _level) external pure returns (uint256) {
        uint256 stat = 0;
        if (_level == 1) {
            stat = 0;
        } else if (_level == 2) {
            stat = 1;
        } else if (_level == 3) {
            stat = 2;
        } else if (_level == 4) {
            stat = 3;
        } else {
            stat = 5;
        }
        return stat;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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