// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

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
        _checkRole(role);
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
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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
                        Strings.toHexString(account),
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
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
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/CaraProduct.sol";
import "./lib/CaraSupportDepositWithdraw.sol";
import "./lib/CaraSupportVRF.sol";

contract CRFRaffle is CaraProduct, CaraSupportDepositWithdraw, CaraSupportVRF, ReentrancyGuard {
    using CaraSupportPayable for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using CaraSet for EnumerableSet.AddressSet;
    using CaraSet for EnumerableSet.UintSet;

    enum RaffleStatus {
        INACTIVE, ACTIVE, FINALIZING_STARTED, FINALIZED, CANCELLED
    }

    struct RaffleAsset {
        address asset; uint[] tokensOrAmount; AssetType assetType;
    }

    struct Raffle {
        uint raffleId; uint totalSupply; uint maxSupply; uint price; uint totalPayment; uint startedOn; uint expiresOn;
        uint createdOn; uint finalizeStartedOn; uint finalizedOn; uint cancelledOn; uint winningsClaimedOn;
        uint paymentClaimedOn; uint winningReceiptId; uint winningTicketNumber; uint vrfRequestId; address payment;
        address creator; address winner; RaffleStatus status;
    }

    struct RaffleDetail {
        uint currentReceiptId; Raffle raffle; RaffleAsset[] assets;
    }

    struct Receipt {
        uint receiptId; uint ticketStart; uint ticketEnd; address account;
    }

    struct Status {
        uint currentId; ProductData product;
    }

    uint public RAFFLE_ID;
    mapping(uint => Raffle) private RAFFLES;
    mapping(RaffleStatus => EnumerableSet.UintSet) private RAFFLE_STATUS;
    mapping(uint => mapping(address => RaffleAsset)) private RAFFLE_ASSETS;
    mapping(uint => EnumerableSet.AddressSet) private RAFFLE_UNIQUE_ASSETS;
    mapping(address => EnumerableSet.UintSet) private ACCOUNT_RAFFLES;

    mapping(uint => uint) private RECEIPT_ID;
    mapping(uint => mapping(uint => Receipt)) private RECEIPTS;
    mapping(uint => mapping(address => EnumerableSet.UintSet)) private ACCOUNT_RECEIPTS;

    mapping(address => EnumerableSet.UintSet) private WINNINGS;
    mapping(address => EnumerableSet.UintSet) private WINNINGS_CLAIMED;

    event Created(uint indexed raffleId, address indexed creator, uint timestamp);
    event Updated(uint indexed raffleId, address indexed raffleOnwer, uint timestamp);
    event Activated(uint indexed raffleId, address indexed raffleOwner, uint timestamp);
    event Purchased(uint indexed raffleId, address indexed buyer, uint amount, uint receiptId, uint ticketStart, uint ticketEnd, uint timestamp);
    event Cancelled(uint indexed raffleId, address indexed raffleOwner, uint timestamp);
    event Finalized(uint indexed raffleId, address indexed winner, uint timestamp);
    event FinalizeStarted(uint indexed raffleId, uint timestamp);
    event PaymentsClaimed(uint indexed raffleId, address indexed raffleOwner, uint timestamp);
    event WinningsClaimed(uint indexed raffleId, address indexed winner, uint timestamp);

    constructor() CaraProduct(0, 0.005 ether, 500) {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(ADMIN, owner());
        _grantRole(OPERATOR, owner());
    }

    //===[ modifiers ]===//
    modifier onlyRaffleOwner(uint raffleId, address account) {
        require(RAFFLES[raffleId].creator == account, "Not owner");
        _;
    }

    //===[ utils ]===//
    function _setRaffleStatus(uint raffleId, RaffleStatus raffleStatus) internal {
        RaffleStatus _currentStatus = RAFFLES[raffleId].status;

        if (_currentStatus != raffleStatus) {
            RAFFLES[raffleId].status = raffleStatus;
            RAFFLE_STATUS[_currentStatus].remove(raffleId);
            RAFFLE_STATUS[raffleStatus].add(raffleId);

            if (raffleStatus == RaffleStatus.ACTIVE) {
                RAFFLES[RAFFLE_ID].startedOn = block.timestamp;
            } else if (raffleStatus == RaffleStatus.CANCELLED) {
                RAFFLES[raffleId].cancelledOn = block.timestamp;
            } else if (raffleStatus == RaffleStatus.FINALIZING_STARTED) {
                RAFFLES[raffleId].finalizeStartedOn = block.timestamp;
            } else if (raffleStatus == RaffleStatus.FINALIZED) {
                RAFFLES[raffleId].finalizedOn = block.timestamp;
            }
        }
    }

    function _getRaffleAssets(uint raffleId) internal view returns (RaffleAsset[] memory) {
        uint _count = RAFFLE_UNIQUE_ASSETS[raffleId].length();
        RaffleAsset[] memory _assets = new RaffleAsset[](_count);

        for (uint _idx = 0; _idx < _count; _idx++) {
            _assets[_idx] = RAFFLE_ASSETS[raffleId][RAFFLE_UNIQUE_ASSETS[raffleId].at(_idx)];
        }

        return _assets;
    }

    function _startFinalizingRaffle(uint raffleId, uint32 gasLimit) internal {
        require(RAFFLES[raffleId].status == RaffleStatus.ACTIVE, "Raffle is not active or already started finalizing");
        require(RECEIPT_ID[raffleId] > 0, "Raffle has no purchases. Use cancel");

        _setRaffleStatus(raffleId, RaffleStatus.FINALIZING_STARTED);
        RAFFLES[raffleId].vrfRequestId = VRF.requestRandomWords(raffleId, 1, 1, RAFFLES[raffleId].totalSupply, gasLimit);

        emit FinalizeStarted(raffleId, block.timestamp);
    }

    //===[ onlyOperator ]===//
    function setRaffleStatus(uint raffleId, RaffleStatus raffleStatus) external onlyRole(OPERATOR) {
        _setRaffleStatus(raffleId, raffleStatus);
    }

    function finalizeWinner(uint raffleId, address winner, uint receiptId, uint ticketNumber) external onlyRole(OPERATOR) {
        require(RAFFLES[raffleId].status == RaffleStatus.FINALIZING_STARTED, "Raffle finalization not started");

        RAFFLES[raffleId].winner = winner;
        RAFFLES[raffleId].winningReceiptId = receiptId;
        RAFFLES[raffleId].winningTicketNumber = ticketNumber;
        WINNINGS[winner].add(raffleId);
        _setRaffleStatus(raffleId, RaffleStatus.FINALIZED);

        emit Finalized(raffleId, winner, block.timestamp);
    }

    //===[ writes ]===//
    function startFinalizing(uint raffleId, uint32 gasLimit) external onlyRaffleOwner(raffleId, _msgSender()) nonReentrant {
        _startFinalizingRaffle(raffleId, gasLimit);
    }

    function startFinalizingExpiredRaffle(uint raffleId, uint32 gasLimit) external nonReentrant {
        require(RAFFLES[raffleId].expiresOn < block.timestamp, "Raffle not expired yet");
        _startFinalizingRaffle(raffleId, gasLimit);
    }

    function claimWinnings(uint raffleId) external nonReentrant {
        require(RAFFLES[raffleId].status == RaffleStatus.FINALIZED, "Raffle not finalized");
        require(RAFFLES[raffleId].winningsClaimedOn == 0, "Already claimed");
        address _account = _msgSender();
        require(
            RAFFLES[raffleId].winner == _account && RECEIPTS[raffleId][RAFFLES[raffleId].winningReceiptId].account == _account,
            "Not winner"
        );

        RAFFLES[raffleId].winningsClaimedOn = block.timestamp;
        RaffleAsset[] memory _raffleAssets = _getRaffleAssets(raffleId);
        for (uint _idx = 0; _idx < _raffleAssets.length; _idx++) {
            CaraSupportDepositWithdraw._withdraw(_account, _raffleAssets[_idx].asset, _raffleAssets[_idx].tokensOrAmount, _raffleAssets[_idx].assetType);
        }

        emit WinningsClaimed(raffleId, _account, block.timestamp);
    }

    function claimPayments(uint raffleId) external onlyRaffleOwner(raffleId, _msgSender()) nonReentrant {
        require(RAFFLES[raffleId].status == RaffleStatus.FINALIZED, "Raffle not yet finalized");
        require(RAFFLES[raffleId].paymentClaimedOn == 0, "Payments already claimed");
        address _account = _msgSender();

        uint _exitFee = (RAFFLES[raffleId].totalPayment * CaraProduct.getDiscountedFees(_account, FEES.exit)) / 1e4;
        uint _payment = RAFFLES[raffleId].totalPayment - _exitFee;
        RAFFLES[raffleId].paymentClaimedOn = block.timestamp;
        CaraSupportFee._addExitFees(_exitFee, RAFFLES[raffleId].payment);
        require(_account._payout(_payment, RAFFLES[raffleId].payment), "Payment claiming failed");

        emit PaymentsClaimed(raffleId, _account, block.timestamp);
    }

    function createRaffle(
        address payment, uint price, uint maxSupply, uint duration, bool active,
        AssetType assetType, address asset, uint[] memory tokensOrAmount
    ) public {
        require(CaraSupportAsset.assetSupported(asset), "Asset not supported");

        if (payment != address(0)) {
            require(CaraSupportPayment.paymentSupported(payment), "Payment not supported");
        }

        address _account = _msgSender();
        RAFFLE_ID += 1;

        CaraSupportDepositWithdraw._deposit(_account, asset, tokensOrAmount, assetType);
        RAFFLE_ASSETS[RAFFLE_ID][asset] = RaffleAsset({asset: asset, tokensOrAmount: tokensOrAmount, assetType: assetType});
        RAFFLE_UNIQUE_ASSETS[RAFFLE_ID].add(asset);

        RAFFLES[RAFFLE_ID].raffleId = RAFFLE_ID;
        RAFFLES[RAFFLE_ID].creator = _account;
        RAFFLES[RAFFLE_ID].price = price;
        RAFFLES[RAFFLE_ID].maxSupply = maxSupply;
        RAFFLES[RAFFLE_ID].expiresOn = block.timestamp + duration;
        RAFFLES[RAFFLE_ID].createdOn = block.timestamp;
        if (payment != address(0)) {
            RAFFLES[RAFFLE_ID].payment = payment;
        }
        ACCOUNT_RAFFLES[_account].add(RAFFLE_ID);

        if (active) {
            _setRaffleStatus(RAFFLE_ID, RaffleStatus.ACTIVE);
            emit Activated(RAFFLE_ID, _msgSender(), block.timestamp);
        } else {
            RAFFLE_STATUS[RaffleStatus.INACTIVE].add(RAFFLE_ID);
        }

        emit Created(RAFFLE_ID, _account, block.timestamp);
    }

    function createRaffle(
        uint price, uint maxSupply, uint duration, bool active,
        AssetType assetType, address asset, uint[] memory tokensOrAmount
    ) external {
        createRaffle(address(0), price, maxSupply, duration, active, assetType, asset, tokensOrAmount);
    }

    function addRaffleAssets(
        uint raffleId, AssetType assetType, address asset, uint[] memory tokensOrAmount
    ) external onlyRaffleOwner(raffleId, _msgSender()) {
        require(RAFFLES[raffleId].status == RaffleStatus.INACTIVE, "Raffle already active");

        CaraSupportDepositWithdraw._deposit(_msgSender(), asset, tokensOrAmount, assetType);
        if (RAFFLE_UNIQUE_ASSETS[RAFFLE_ID].contains(asset)) {
            if (RAFFLE_ASSETS[RAFFLE_ID][asset].assetType == AssetType.NFT) {
                uint _idx;
                uint _currentCount = RAFFLE_ASSETS[RAFFLE_ID][asset].tokensOrAmount.length;
                uint[] memory _tokensOrAmount = new uint[](_currentCount + tokensOrAmount.length);

                for (_idx = 0; _idx < _currentCount; _idx++) {
                    _tokensOrAmount[_idx] = RAFFLE_ASSETS[RAFFLE_ID][asset].tokensOrAmount[_idx];
                }

                for (_idx = 0; _idx < tokensOrAmount.length; _idx++) {
                    _tokensOrAmount[_currentCount + _idx] = tokensOrAmount[_idx];
                }

                RAFFLE_ASSETS[RAFFLE_ID][asset].tokensOrAmount = _tokensOrAmount;
            } else {
                RAFFLE_ASSETS[RAFFLE_ID][asset].tokensOrAmount[0] += tokensOrAmount[0];
            }
        } else {
            RAFFLE_ASSETS[RAFFLE_ID][asset] = RaffleAsset({asset: asset, tokensOrAmount: tokensOrAmount, assetType: assetType});
            RAFFLE_UNIQUE_ASSETS[RAFFLE_ID].add(asset);
        }

        emit Updated(RAFFLE_ID, _msgSender(), block.timestamp);
    }

    function cancelRaffle(uint raffleId) external payable onlyRaffleOwner(raffleId, _msgSender()) nonReentrant {
        require(
            RAFFLES[raffleId].status == RaffleStatus.INACTIVE || RAFFLES[raffleId].status == RaffleStatus.ACTIVE,
            "Cannot cancel with current raffle status"
        );
        require(RAFFLES[raffleId].totalSupply == 0, "Raffle has purchases, cannot cancel");
        require(msg.value >= CaraProduct.getDiscountedFees(_msgSender(), FEES.cancel), "Insufficient cancel fees");

        _setRaffleStatus(raffleId, RaffleStatus.CANCELLED);
        CaraSupportFee._addCancelFees(msg.value);

        RaffleAsset[] memory _raffleAssets = _getRaffleAssets(raffleId);
        for (uint _idx = 0; _idx < _raffleAssets.length; _idx++) {
            CaraSupportDepositWithdraw._withdraw(
                _msgSender(), _raffleAssets[_idx].asset, _raffleAssets[_idx].tokensOrAmount, _raffleAssets[_idx].assetType
            );
            delete RAFFLE_ASSETS[raffleId][_raffleAssets[_idx].asset];
            RAFFLE_UNIQUE_ASSETS[RAFFLE_ID].remove(_raffleAssets[_idx].asset);
        }

        emit Cancelled(raffleId, _msgSender(), block.timestamp);
    }

    function activateRaffle(uint raffleId) external onlyRaffleOwner(raffleId, _msgSender()) {
        _setRaffleStatus(raffleId, RaffleStatus.ACTIVE);

        emit Activated(raffleId, _msgSender(), block.timestamp);
    }

    //===[ writes ]===//
    function buyRaffle(uint raffleId, uint amount) external payable {
        require(RAFFLES[raffleId].status == RaffleStatus.ACTIVE, "Raffle not active");
        require(RAFFLES[raffleId].expiresOn >= block.timestamp, "Raffle expired");
        require((RAFFLES[raffleId].totalSupply + amount) <= RAFFLES[raffleId].maxSupply,"Sold out or buying more than max supply");
        address _buyer = _msgSender();
        address _paymentToken = RAFFLES[raffleId].payment;
        uint _payment = amount * RAFFLES[raffleId].price;

        // payment
        if (_paymentToken != address(0)) {
            require(IERC20(_paymentToken).balanceOf(_buyer) >= _payment, "Insufficient balance");
            require(IERC20(_paymentToken).transferFrom(_buyer, address(this), _payment), "Unable to transfer payment");
        } else {
            require(msg.value >= _payment, "Insufficient payment");
            _payment = msg.value;
        }

        // receipt
        uint _receiptId = RECEIPT_ID[raffleId] + 1;
        uint _ticketStart = RAFFLES[raffleId].totalSupply + 1;
        uint _ticketEnd = RAFFLES[raffleId].totalSupply + amount;

        RECEIPT_ID[raffleId] = _receiptId;
        RECEIPTS[raffleId][RECEIPT_ID[raffleId]] = Receipt({
            receiptId: RECEIPT_ID[raffleId], ticketStart: _ticketStart, ticketEnd: _ticketEnd, account: _buyer
        });
        ACCOUNT_RECEIPTS[raffleId][_buyer].add(_receiptId);

        RAFFLES[raffleId].totalPayment += _payment;
        RAFFLES[raffleId].totalSupply += amount;

        emit Purchased(raffleId, _buyer, amount, _receiptId, _ticketStart, _ticketEnd, block.timestamp);
    }

    //===[ views ]===//
    function getRaffles(uint[] memory raffleIds) public view returns (Raffle[] memory) {
        Raffle[] memory _raffles = new Raffle[](raffleIds.length);

        for (uint _idx = 0; _idx < raffleIds.length; _idx++) {
            _raffles[_idx] = RAFFLES[raffleIds[_idx]];
        }

        return _raffles;
    }

    function getRaffleDetails(uint[] memory raffleIds) public view returns (RaffleDetail[] memory) {
        RaffleDetail[] memory _raffles = new RaffleDetail[](raffleIds.length);

        for (uint _idx = 0; _idx < raffleIds.length; _idx++) {
            _raffles[_idx].currentReceiptId = RECEIPT_ID[raffleIds[_idx]];
            _raffles[_idx].raffle = RAFFLES[raffleIds[_idx]];
            _raffles[_idx].assets = _getRaffleAssets(raffleIds[_idx]);
        }

        return _raffles;
    }

    function getRafflesByStatus(RaffleStatus raffleStatus, uint startIndex, uint batchSize) external view returns (RaffleDetail[] memory) {
        return getRaffleDetails(RAFFLE_STATUS[raffleStatus].batchValues(startIndex, batchSize));
    }

    function getRafflesByStatus(RaffleStatus raffleStatus) external view returns (RaffleDetail[] memory) {
        return getRaffleDetails(RAFFLE_STATUS[raffleStatus].values());
    }

    function accountRaffles(address account, uint startIndex, uint batchSize) external view returns (uint[] memory) {
        return ACCOUNT_RAFFLES[account].batchValues(startIndex, batchSize);
    }

    function accountRaffles(address account) external view returns (uint[] memory) {
        return ACCOUNT_RAFFLES[account].values();
    }

    function getReceipts(uint raffleId, uint[] calldata receiptIds) external view returns (Receipt[] memory) {
        Receipt[] memory _receipts = new Receipt[](receiptIds.length);

        for (uint _idx = 0; _idx < receiptIds.length; _idx++) {
            _receipts[_idx] = RECEIPTS[raffleId][receiptIds[_idx]];
        }

        return _receipts;
    }

    function accountReceipts(address account, uint raffleId, uint startIndex, uint batchSize) public view returns (Receipt[] memory) {
        uint[] memory _receiptIds = ACCOUNT_RECEIPTS[raffleId][account].batchValues(startIndex, batchSize);
        Receipt[] memory _receipts = new Receipt[](_receiptIds.length);

        for (uint _idx; _idx < _receiptIds.length; _idx++) {
            _receipts[_idx] = RECEIPTS[raffleId][_receiptIds[_idx]];
        }

        return _receipts;
    }

    function accountReceipts(address account, uint raffleId) external view returns (Receipt[] memory) {
        return accountReceipts(account, raffleId, 0, 0);
    }

    function status() external view returns (Status memory) {
        return Status({currentId: RAFFLE_ID, product: CaraProduct.productData()});
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./CaraTypes.sol";
import "./CaraSupportAsset.sol";
import "./CaraSupportFee.sol";
import "./CaraSupportPayment.sol";
import "./CaraSupportPayable.sol";

contract CaraProduct is Ownable, Pausable, CaraSupportAsset, CaraSupportPayment, CaraSupportFee {
    using CaraSupportPayable for address;
    bool public EMERGENCY_WITHDRAW_DISABLED;
    address public DiscounterAddress;
    IDiscounter DISCOUNTER;

    event EmergencyWithdraw(address account, uint amount, address token, uint timestamp);
    event EmergencyWithdrawDisabled(uint timestamp);
    event FundsDirectlyDeposited(address sender, uint amount, uint timestamp);
    event FundsReceived(address sender, uint amount, uint timestamp);

    constructor(uint create, uint cancel, uint exit) CaraSupportFee(create, cancel, exit) {}

    //===[ fallbacks ]===//
    receive() external payable {
        emit FundsReceived(_msgSender(), msg.value, block.timestamp);
    }

    //===[ onlyRole(ADMIN) ]===//
    function disableEmergencyWithdraw() external onlyRole(ADMIN) {
        require(!EMERGENCY_WITHDRAW_DISABLED, "Emergency withdraw is disabled");

        EMERGENCY_WITHDRAW_DISABLED = true;
        emit EmergencyWithdrawDisabled(block.timestamp);
    }

    function emergencyWithdraw(uint amount, address token) external onlyRole(ADMIN) {
        require(!EMERGENCY_WITHDRAW_DISABLED, "Emergency withdraw is disabled");

        uint _amount;
        if (token == address(0)) {
            _amount = amount > 0 ? amount : address(this).balance;
        } else {
            _amount = amount > 0 ? amount : IERC20(token).balanceOf(address(this));
        }
        require((owner())._payout(_amount, token), "Withdrawal failed");

        emit EmergencyWithdraw(_msgSender(), _amount, token, block.timestamp);
    }

    function pause() external onlyRole(ADMIN) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN) {
        _unpause();
    }

    function setDiscounter(address discounter) external onlyRole(ADMIN) {
        DiscounterAddress = discounter;
        DISCOUNTER = IDiscounter(discounter);
    }

    //===[ views ]===//
    function getDiscountedFees(address account, uint fees) public view returns (uint) {
        uint _rates = DiscounterAddress == address(0) ? 0 : DISCOUNTER.discountRates(address(this), account);
        return (fees * (1e4 - _rates)) / 1e4;
    }

    function productData() public view returns (ProductData memory) {
        return ProductData({
            Discounter: DiscounterAddress, fees: FEES,
            supportedAssets: CaraSupportAsset.supportedAssets(),
            supportedPayments: CaraSupportPayment.supportedPayments()
        });
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library CaraSet {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    function _batchValues(bytes32[] memory allValues, uint startIndex, uint batchSize) internal pure returns (bytes32[] memory) {
        uint _count = allValues.length;
        if (startIndex > _count) {
            return new bytes32[](0);
        }

        if (_count == 0 || (startIndex == 0 && batchSize == 0)) {
            return allValues;
        }

        uint _endIndex = batchSize == 0 ? _count : startIndex + batchSize;
        if (_endIndex > _count) {
            _endIndex = _count;
        }

        bytes32[] memory _allValues = new bytes32[](_endIndex - startIndex);
        uint _vIdx;
        for (uint _idx = startIndex; _idx < _endIndex; _idx++) {
            _allValues[_vIdx] = allValues[_idx];
            _vIdx += 1;
        }

        return _allValues;
    }

    function batchValues(EnumerableSet.Bytes32Set storage set, uint startIndex, uint batchSize) internal view returns (bytes32[] memory) {
        return _batchValues(set._inner._values, startIndex, batchSize);
    }

    function batchValues(EnumerableSet.Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return batchValues(set, 0, 0);
    }

    function batchValues(EnumerableSet.AddressSet storage set, uint startIndex, uint batchSize) internal view returns (address[] memory) {
        bytes32[] memory _allValues = _batchValues(set._inner._values, startIndex, batchSize);
        address[] memory _results;
        assembly {
            _results := _allValues
        }

        return _results;
    }

    function batchValues(EnumerableSet.AddressSet storage set) internal view returns (address[] memory) {
        return batchValues(set, 0, 0);
    }

    function batchValues(EnumerableSet.UintSet storage set, uint startIndex, uint batchSize) internal view returns (uint[] memory) {
        bytes32[] memory _allValues = _batchValues(set._inner._values, startIndex, batchSize);
        uint[] memory _results;
        assembly {
            _results := _allValues
        }

        return _results;
    }

    function batchValues(EnumerableSet.UintSet storage set) internal view returns (uint[] memory) {
        return batchValues(set, 0, 0);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./CaraSet.sol";
import "./CaraTypes.sol";

contract CaraSupportAsset is Ownable, AccessControlEnumerable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using CaraSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet SUPPORTED_ASSETS;

    //===[ onlyRole(OPERATOR) ]===//
    function addAsset(address asset) public onlyRole(OPERATOR) {
        SUPPORTED_ASSETS.add(asset);
    }

    function removeAsset(address asset) public onlyRole(OPERATOR) {
        SUPPORTED_ASSETS.remove(asset);
    }

    //===[ checks ]===//
    function assetSupported(address asset) public view returns (bool) {
        return SUPPORTED_ASSETS.contains(asset);
    }

    function assetsSupported(address[] calldata assets) public view returns (bool, bool[] memory) {
        bool _allSupported = true;
        bool[] memory _supportedChecks = new bool[](assets.length);

        bool _supported;
        for (uint _idx = 0; _idx < assets.length; _idx++) {
            _supported = assetSupported(assets[_idx]);
            _supportedChecks[_idx] = _supported;
            if (!_supported) {
                _allSupported = false;
            }
        }

        return (_allSupported, _supportedChecks);
    }

    //===[ views ]===//
    function supportedAssets(uint startIndex, uint batchSize) public view returns (address[] memory) {
        return SUPPORTED_ASSETS.batchValues(startIndex, batchSize);
    }

    function supportedAssets() public view returns (address[] memory) {
        return SUPPORTED_ASSETS.values();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./CaraTypes.sol";
import "./CaraSupportPayable.sol";

contract CaraSupportDepositWithdraw is IERC721Receiver {
    using CaraSupportPayable for address;

    //===[ overrides ]===//
    function onERC721Received(address, address, uint256, bytes memory) public pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    //===[ writes ]===//
    function _deposit(address account, address asset, uint[] memory tokensOrAmount, AssetType assetType) internal {
        if (assetType == AssetType.NFT) {
            for (uint _idx = 0; _idx < tokensOrAmount.length; _idx++) {
                IERC721(asset).safeTransferFrom(account, address(this), tokensOrAmount[_idx]);
            }
        } else {
            IERC20(asset).transferFrom(account, address(this), tokensOrAmount[0]);
        }
    }

    function _withdraw(address account, address asset, uint[] memory tokensOrAmount, AssetType assetType) internal {
        if (assetType == AssetType.NFT) {
            for (uint _idx = 0; _idx < tokensOrAmount.length; _idx++) {
                IERC721(asset).safeTransferFrom(address(this), account, tokensOrAmount[_idx]);
            }
        } else {
            account._payout(tokensOrAmount[0], asset);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./CaraSet.sol";
import "./CaraTypes.sol";
import "./CaraSupportPayable.sol";

contract CaraSupportFee is Ownable, AccessControlEnumerable {
    using CaraSupportPayable for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using CaraSet for EnumerableSet.AddressSet;

    struct TokenExitFees {
        address token; uint lifetime; uint total; uint claimed;
    }

    struct FeesData {
        address wallet; Fees native; TokenExitFees[] tokens;
    }

    Fees public FEES;
    mapping(address => TokenExitFees) TOKEN_EXIT_FEES;
    EnumerableSet.AddressSet FEES_TOKENS;
    address public FEES_WALLET;

    event FeesClaimed(address account, uint amount, uint timestamp);
    constructor(uint create, uint cancel, uint exit) {
        _setPlatformFees(create, cancel, exit);
        FEES_WALLET = owner();
    }

    //===[ utils ]===//
    function _getTokenExitFees(address[] memory tokens) internal view returns (TokenExitFees[] memory) {
        uint _count = tokens.length;
        TokenExitFees[] memory _allTokenFees = new TokenExitFees[](_count);

        for (uint _idx = 0; _idx < _count; _idx++) {
            _allTokenFees[_idx] = TOKEN_EXIT_FEES[tokens[_idx]];
        }

        return _allTokenFees;
    }

    function _setPlatformFees(uint create, uint cancel, uint exit) internal {
        if (create > 0 && create != FEES.create) {
            FEES.create = create;
        }

        if (cancel > 0 && cancel != FEES.cancel) {
            FEES.cancel = cancel;
        }

        if (exit > 0 && exit != FEES.exit) {
            FEES.exit = exit;
        }
    }

    function _addCreateFees(uint create) internal {
        FEES.lifetime += create; FEES.lifetimeCreate += create; FEES.total += create;
    }

    function _addCancelFees(uint cancel) internal {
        FEES.lifetime += cancel; FEES.lifetimeCancel += cancel; FEES.total += cancel;
    }

    function _addExitFees(uint exit, address payment) internal {
        if (payment != address(0)) {
            TOKEN_EXIT_FEES[payment].total += exit;
            TOKEN_EXIT_FEES[payment].lifetime += exit;
            if (!FEES_TOKENS.contains(payment)) {
                TOKEN_EXIT_FEES[payment].token = payment;
                FEES_TOKENS.add(payment);
            }
        } else {
            FEES.lifetime += exit; FEES.lifetimeExit += exit; FEES.total += exit;
        }
    }

    //===[ onlyRole(OPERATOR) ]===//
    function setFeesWallet(address feesWallet) external onlyRole(OPERATOR) {
        require(feesWallet != address(0) && feesWallet != FEES_WALLET, "Invalid wallet");
        FEES_WALLET = feesWallet;
    }

    function setPlatformFees(uint create, uint cancel, uint exit) external onlyRole(OPERATOR) {
        _setPlatformFees(create, cancel, exit);
    }

    function claimPlatformFees(uint amount, address payment) external onlyRole(OPERATOR) {
        bool _tokenPayment = payment != address(0);
        uint _balance = _tokenPayment ? TOKEN_EXIT_FEES[payment].total : FEES.total;
        require(_balance > 0 && _balance >= amount, "Insufficient balance");

        uint _amount = amount > 0 ? amount : _balance;
        if (_tokenPayment) {
            TOKEN_EXIT_FEES[payment].total = _balance - _amount;
            TOKEN_EXIT_FEES[payment].claimed += _amount;
        } else {
            FEES.total = _balance - _amount;
            FEES.claimed += _amount;
        }
        require(FEES_WALLET._payout(_amount, payment), "Platform fees claiming failed");

        emit FeesClaimed(_msgSender(), _amount, block.timestamp);
    }

    //===[ views ]===//
    function feesData(uint startIndex, uint batchSize) public view returns (FeesData memory) {
        return FeesData({
            wallet: FEES_WALLET, native: FEES,
            tokens: _getTokenExitFees(FEES_TOKENS.batchValues(startIndex, batchSize))
        });
    }

    function feesData() public view returns (FeesData memory) {
        return feesData(0, 0);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library CaraSupportPayable {
    function _payout(address recipient, uint amount, address payment) internal returns (bool) {
        require(recipient != address(0), "Recipient cannot be null address");

        if (amount == 0) {
            return true;
        }

        bool _paid;
        if (payment == address(0)) {
            (_paid, ) = payable(recipient).call{value: amount}("");
        } else {
            _paid = IERC20(payment).transfer(recipient, amount);
        }

        return _paid;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./CaraSet.sol";
import "./CaraTypes.sol";

contract CaraSupportPayment is AccessControlEnumerable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using CaraSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet SUPPORTED_PAYMENTS;

    //===[ onlyRole(OPERATOR) ]===//
    function addPayment(address payment) external onlyRole(OPERATOR) {
        SUPPORTED_PAYMENTS.add(payment);
    }

    function removePayment(address payment) external onlyRole(OPERATOR) {
        SUPPORTED_PAYMENTS.remove(payment);
    }

    //===[ checks ]===//
    function paymentSupported(address payment) public view returns (bool) {
        return SUPPORTED_PAYMENTS.contains(payment);
    }

    function paymentsSupported(address[] calldata payments) public view returns (bool, bool[] memory) {
        bool _allSupported = true;
        bool[] memory _supportedChecks = new bool[](payments.length);

        bool _supported;
        for (uint _idx = 0; _idx < payments.length; _idx++) {
            _supported = paymentSupported(payments[_idx]);
            _supportedChecks[_idx] = _supported;
            if (!_supported) {
                _allSupported = false;
            }
        }

        return (_allSupported, _supportedChecks);
    }

    //===[ views ]===//
    function supportedPayments(uint startIndex, uint batchSize) public view returns (address[] memory) {
        return SUPPORTED_PAYMENTS.batchValues(startIndex, batchSize);
    }

    function supportedPayments() public view returns (address[] memory) {
        return SUPPORTED_PAYMENTS.values();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./CaraTypes.sol";

interface IVRF {
    function requestRandomWords(uint externalId, uint32 numWords, uint min, uint max, uint32 gasLimit) external returns (uint);
    function getResultByExternalId(address consumer, uint externalId) external view returns (uint[] memory);
}

contract CaraSupportVRF is AccessControlEnumerable {
    address public VRFAddress;
    IVRF VRF;

    //===[ onlyRole(ADMIN) ]===/
    function setVRF(address vrf) external onlyRole(ADMIN) {
        VRFAddress = vrf;
        VRF = IVRF(vrf);
    }

    //===[ views ]===/
    function getVRFResult(uint itemId) external view returns (uint[] memory) {
        return VRF.getResultByExternalId(address(this), itemId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICaraNFT is IERC721 {
    function accountTokens(address account) external view returns (uint[] memory);
    function batchBurn(uint[] calldata tokens) external;
    function batchTransfer(address recipient, uint[] calldata tokens) external;
    function mint(address account, uint amount) external;
}

interface ICaraStaking {
    function accountTokens(address account, address asset) external view returns (uint[] memory);
    function balanceOf(address account, address asset) external view returns (uint);
}

interface IDiscounter {
    function discountRates(address product, address account) external view returns (uint16);
}

struct ProductData {
    address Discounter; Fees fees; address[] supportedAssets; address[] supportedPayments;
}

struct Fees {
    uint create; uint cancel; uint exit; uint total; uint claimed;
    uint lifetime; uint lifetimeCreate; uint lifetimeCancel; uint lifetimeExit;
}

struct RoyaltiesSplit {
    uint highest; address[] collections;
}

enum CultistLevel {
    INITIATE, APPRENTICE, ADVENTURER, MASTER
}

enum AssetType {
    NFT, FUNGIBLE
}

struct Cultist {
    uint tokenId; uint accrued; bool staked; address delegated; CultistLevel certified; CultistLevel level;
}

bytes32 constant ADMIN = keccak256("ADMIN");
bytes32 constant OPERATOR = keccak256("OPERATOR");