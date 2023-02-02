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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IRDNRegistry} from "../RDN/interfaces/IRDNRegistry.sol";
import {IAMPERProject} from "./interfaces/IAMPERProject.sol";
import {IAMPEREstimator} from "./interfaces/IAMPEREstimator.sol";

contract AMPEREstimatorV1 is IAMPEREstimator, AccessControlEnumerable {

    IRDNRegistry public immutable registry;
    IAMPERProject public immutable amper;
    uint public startPrice;
    uint public priceMoveStep;
    uint public priceMoveThreshold;

    uint[2][10] public promoBonusConfig = [
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0],
        [0, 0]
    ];
    bool public promoBonusActive = false;

    uint public onceBonusBase;
    mapping(uint => uint) public onceBonusValues;
    uint[] public onceBonusTakers;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");

    constructor (
        address _registry, 
        address _amper, 
        address _admin, 
        uint _startPrice,
        uint _priceMoveStep,
        uint _priceMoveThreshld,
        uint _onceBonusBase) 
    {
        registry = IRDNRegistry(_registry);
        amper = IAMPERProject(_amper);

        startPrice = _startPrice;
        priceMoveStep = _priceMoveStep;
        priceMoveThreshold = _priceMoveThreshld;

        onceBonusBase = _onceBonusBase;

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(CONFIG_ROLE, _admin);
    }

    function estimateAmountOut(uint _userId, uint _amountIn) public view returns(uint, uint) {
        uint _startPrice = startPrice;
        uint _step = priceMoveStep;
        uint _threshold = priceMoveThreshold;
        uint _distributed = amper.distributed();
        uint remained = _amountIn;
        uint amountOut = 0;
        while (remained > 0) {
            uint currentStage = _distributed / _threshold;
            uint currentPrice = _startPrice + currentStage * _step;
            uint currentPriceAmount = _threshold - _distributed % _threshold;
            uint currentPriceCost = (currentPrice * currentPriceAmount) / (10**18);
            uint spent = (currentPriceCost <= remained) ? currentPriceCost : remained;
            uint bought = (currentPriceCost <= remained) ? currentPriceAmount: ((remained * 10**18)/ currentPrice);
            remained -= spent;
            amountOut += bought;
            _distributed += bought;
        }
        uint bonus = estimatePromoBonus(amountOut) + estimateOnceBonus(_userId, amountOut);
        return (amountOut, bonus);
    }

    function giveOnceBonus(uint _userId, uint _amountOut) public returns(uint) {
        require(msg.sender == address(amper), "Access denied");
        uint bonus = estimateOnceBonus(_userId, _amountOut);
        if (bonus > 0) {
            onceBonusTakers.push(_userId);
            onceBonusValues[_userId] = bonus;
        }
        return bonus;
    }

    function estimateOnceBonus(uint _userId, uint _amountOut) public view returns(uint) {
        uint bonus;
        if (onceBonusValues[_userId] > 0) return 0;
        bonus = (_amountOut * onceBonusBase * registry.getTariff(_userId)) / 10**4;
        return bonus;
    }

    function estimatePromoBonus(uint _amountOut) public view returns(uint) {
        if (promoBonusActive == false) return 0;
        uint bonus;
        uint[2][10] memory _promoBonusConfig = promoBonusConfig;
        for (uint i=0; i < _promoBonusConfig.length; i++) {
            if (_amountOut >= _promoBonusConfig[i][0]) {
                bonus = _promoBonusConfig[i][1];
            }
        }
        return (bonus * _amountOut)/10**4;
    }

    // admin functions

    function configPromoBonus(uint[2][10] memory _promoBonusConfig) public onlyRole(CONFIG_ROLE) {
        promoBonusConfig = _promoBonusConfig;
    }

    function configDistribution(
        uint _startPrice,
        uint _priceMoveStep,
        uint _priceMoveThreshold,
        uint _onceBonusBase,
        bool _promoBonusActive)
        public onlyRole(CONFIG_ROLE) 
    {
        startPrice = _startPrice;
        priceMoveStep = _priceMoveStep;
        priceMoveThreshold = _priceMoveThreshold;
        onceBonusBase = _onceBonusBase;
        promoBonusActive = _promoBonusActive;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {WithdrawAnyERC20Token} from "../Utils/WithdrawAnyERC20Token.sol";
import {IRDNRegistry} from "../RDN/interfaces/IRDNRegistry.sol";
import {IRDNDistributor} from "../RDN/interfaces/IRDNDistributor.sol";
import {IAMPEREstimator} from "./interfaces/IAMPEREstimator.sol";
import {IAMPERStaking} from "./interfaces/IAMPERStaking.sol";



contract AMPERProject is AccessControlEnumerable, WithdrawAnyERC20Token {

    IRDNRegistry public immutable registry;
    IAMPEREstimator public estimator;
    IAMPERStaking public staking;
    IERC20 public token;
    uint public distributed;
    uint public distributionLimit;
    uint public reward;

    event Turnover(
        uint indexed userId,
        address indexed token,
        uint turnoverAmount,
        uint normalizedTurnover
    );

    event Participation(
        uint indexed userId,
        address indexed tokensIn,
        uint amountIn,
        uint amountOutTotal,
        uint bonus
    );

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");

    constructor (address _registry, address _admin) WithdrawAnyERC20Token(_admin, false) {
        registry = IRDNRegistry(_registry);

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(CONFIG_ROLE, _admin);
        
    }

    function estimateAmountOut(uint _userId, uint _amountIn) public view returns(uint, uint) {
        return _estimateAmountOut(_userId, _amountIn);
    }

    function _estimateAmountOut(uint _userId, uint _amountIn) private view returns(uint, uint) {
        require(registry.isRegistered(_userId), "Not registered in RDN");
        (uint amountOut, uint bonus) = estimator.estimateAmountOut(_userId, _amountIn);
        require(amountOut <= (distributionLimit - distributed), "Distribution Limit");
        return (amountOut, bonus);
    }

    function participate(uint _amountIn, uint _amountOutMin) public {
        uint userId = registry.getUserIdByAddress(msg.sender);
        require(userId > 0, "Not registered in RDN");
        
        (uint amountOut, uint bonus) = estimator.estimateAmountOut(userId, _amountIn);
        uint onceBonus = estimator.estimateOnceBonus(userId, _amountIn);
        uint amountOutTotal = amountOut + bonus;
        require(amountOutTotal <= (distributionLimit - distributed), "Distribution limit overflow");
        require(amountOutTotal >= _amountOutMin, "amountOut lt amountOutMin");

        token.transferFrom(msg.sender, address(this), _amountIn);
        uint toReward = (_amountIn * reward) / 10**4;
        if (toReward > 0) {
            IRDNDistributor distributor = IRDNDistributor(registry.getDistributor(address(token)));
            token.approve(address(distributor), toReward);
            distributor.distribute(msg.sender, toReward);
        }

        if (onceBonus > 0) {
            estimator.giveOnceBonus(userId, amountOut);
        }

        distributed += amountOutTotal;

        staking.deposit(userId, amountOutTotal, 0);

        emit Turnover(userId, address(token), _amountIn, _amountIn / 10);
        emit Participation(userId, address(token), _amountIn, amountOutTotal, bonus);
        
    }

    function config(address _staking, address _estimator, uint _distributionLimit, address _token, uint _reward) public onlyRole(CONFIG_ROLE) {
        estimator = IAMPEREstimator(_estimator);
        staking = IAMPERStaking(_staking);
        distributionLimit = _distributionLimit;
        token = IERC20(_token);
        reward = _reward;
    }

    function setDistributed(uint _distributed) public onlyRole(CONFIG_ROLE) {
        distributed = _distributed;
    }

    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {WithdrawAnyERC20Token} from "../Utils/WithdrawAnyERC20Token.sol";
import {IRDNRegistry} from "../RDN/interfaces/IRDNRegistry.sol";


contract AMPERStaking is AccessControlEnumerable, WithdrawAnyERC20Token {
    
    IRDNRegistry public immutable registry;
    IERC20 public token;
    bool public withdrawalEnabled;

    struct Deposit {
        uint created;
        uint amount;
    }

    struct Member {
        uint stakedTotalAmount;
        uint outOfStakingAmount;
        Deposit[] deposits;
    }

    mapping (uint => Member) public members;
    uint[] public membersArr;

    struct Config {
        uint created;
        uint[2][10] rules;
    }
    Config[] public configs;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");
    bytes32 public constant DEPOSIT_ROLE = keccak256("DEPOSIT_ROLE");


    constructor (address _registry, address _admin) WithdrawAnyERC20Token(_admin, false) {
        registry = IRDNRegistry(_registry);

        uint[2][10] memory _rules = [
            [uint(0), uint(0)],
            [uint(0), uint(0)],
            [uint(0), uint(0)],
            [uint(2200 ether), uint(12 ether / 100)],
            [uint(3500 ether), uint(15 ether / 100)],
            [uint(5000 ether), uint(18 ether / 100)],
            [uint(7500 ether), uint(22 ether / 100)],
            [uint(11000 ether), uint(25 ether / 100)],
            [uint(16000 ether), uint(30 ether / 100)],
            [uint(25000 ether), uint(45 ether / 100)]
        ];
        Config memory _config = Config(block.timestamp, _rules);
        configs.push(_config);


        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(CONFIG_ROLE, _admin);
        _setupRole(DEPOSIT_ROLE, _admin);
    }

    function deposit(uint _userId, uint _amount, uint _outOfStakingAmount) public onlyRole(DEPOSIT_ROLE) {
        require(registry.isValidUser(_userId), "Not registered in RDN");
        require(_amount > 0, "Nothing to deposit");
        Deposit memory _deposit = Deposit(block.timestamp, _amount);
        if (members[_userId].stakedTotalAmount == 0 && members[_userId].outOfStakingAmount == 0) {
            membersArr.push(_userId);
        }
        members[_userId].stakedTotalAmount += _amount;
        members[_userId].deposits.push(_deposit);
        members[_userId].outOfStakingAmount += _outOfStakingAmount;
    }

    function income(uint _userId) public view returns(uint) {
        uint _configsCount = configs.length;
        uint _staked;
        uint _nextBreak;
        uint _income;
        uint _lastIncome;
        Member memory _member = members[_userId];
        Config memory _conf = configs[0];

        for (uint i; i < _configsCount; i++) {
            _conf = configs[i];
            if (i == (_configsCount - 1)) {
                _nextBreak = block.timestamp;
            } else {
                _nextBreak = configs[i+1].created;
            }
            if (i > 0) {
                _income += ((_conf.created - _lastIncome) * _staked * _rule(configs[i-1], _staked)) / (365 days * 10**18);
            }
            _lastIncome = _conf.created;
            for (uint j; j < _member.deposits.length; j++) {
                if ((_member.deposits[j].created > _conf.created) && (_member.deposits[j].created <= _nextBreak)) {
                    _income += ((_member.deposits[j].created - _lastIncome) * _staked * _rule(_conf, _staked)) / (365 days * 10**18);
                    _staked += _member.deposits[j].amount;
                    _lastIncome = _member.deposits[j].created;
                }
            }
        }
        _income += ((block.timestamp - _lastIncome) * _staked * _rule(_conf, _staked)) / (365 days * 10**18);
        return _income;
    }

    function rule(uint _amount) public view returns(uint) {
        return _rule(configs[configs.length - 1], _amount);
    }

    function _rule(Config memory _conf, uint _amount) pure private returns (uint) {
        uint _val;
        for (uint i; i < _conf.rules.length; i++) {
            if (_amount >= _conf.rules[i][0]) {
                _val = _conf.rules[i][1];
            } else {
                break;
            }
        }
        return _val;
    }

    function balanceSummary(uint _userId) public view returns(uint, uint, uint) {
        uint _staked = members[_userId].stakedTotalAmount;
        uint _outStaking = members[_userId].outOfStakingAmount;
        uint _income = income(_userId);
        return (_staked, _outStaking, _income);
    }

    function staked(uint _userId) public view returns(uint) {
        return members[_userId].stakedTotalAmount;
    }

    function outStaking(uint _userId) public view returns(uint) {
        return members[_userId].outOfStakingAmount;
    }

    function configRules(uint[2][10] memory _rules) public {
        Config memory _conf = Config(block.timestamp, _rules);
        configs.push(_conf);
    }

    function configStaking(address _token, bool _withdrawalEnabled) public onlyRole(CONFIG_ROLE) {
        token = IERC20(_token);
        withdrawalEnabled = _withdrawalEnabled;
    }

    function getAllMembers() public view returns(uint[] memory) {
        return membersArr;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IAMPEREstimator {
    
    function estimateAmountOut(uint _userId, uint _amountIn) external view returns(uint, uint);

    function estimateOnceBonus(uint _userId, uint _amountIn) external view returns(uint);

    function giveOnceBonus(uint _userId, uint _amountOut) external returns(uint);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IAMPERProject {
    
    function distributed() external view returns(uint);
    
    function estimateAmountOut(uint _userId, uint _amountIn) external view returns(uint, uint);
    
    function estimateAmountIn(uint _userId, uint _amountOut) external view returns(uint, uint);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IAMPERStaking {
    
    function deposit(uint _userId, uint _amount, uint _outOfStakingAmount) external;
    
    function income(uint _userId) external view returns(uint);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
   */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20ext {
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

    function mint(address to, uint256 amount) external;

    function transferOwnership(address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "../interfaces/IBEP20.sol";

interface IMasterChefv2 {

    struct PoolInfo {
        uint256 accCakePerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        bool isRegular;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }

    function init(IBEP20 dummyToken) external;

    function poolLength() external view returns (uint256 pools);

    function add(uint256 _allocPoint, IBEP20 _lpToken, bool _isRegular, bool _withUpdate) external;

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function massUpdatePools() external;

    function cakePerBlock(bool _isRegular) external view returns (uint256 amount);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function lptoken(uint256 _pid) external returns(IBEP20);

    function poolInfo(uint256 _pid) external returns (PoolInfo memory);

    function userInfo(uint256 _pid, address _userAddress) external returns (UserInfo memory);

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function tPair(address factory, address tokenA, address tokenB) external view returns(address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts

// ERC20 Token Contract based on OpenZeppelin
//
// ## Minting:
// Mintable. Mint can be stopped forever by stopMint().
//
// ## AccessControl:
// DEFAULT_ADMIN_ROLE can grantRole to any other address.
// MINTER_ROLE - can mint
// PAUSER_ROLE - can pause transfers
// MINTSTOPPER_ROLE - can stop minting FOREVER
// Any role can be revoked from any address by DEFAULT_ADMIN_ROLE
// All role members can be listed anytime by getRoleMemberCount and getRoleMember
//
// ## Burning:
// tokens can be burnt by tokens holder
//
// ## Pausing:
// All transfers can be paused and unpaused anytime by PAUSER_ROLE
//
// ## Allowance and Approve:
// Default ERC20 allowance, approve, transferFrom 


pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract MOSTToken is Context, AccessControlEnumerable, ERC20, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTSTOPPER_ROLE = keccak256("MINTSTOPPER_ROLE");

    // Mint is Stoppable
    bool public mintStopped = false;

    constructor(string memory name, string memory symbol, uint256 _initialSupply, address _initialHolder, address _admin) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(MINTER_ROLE, _admin);
        _setupRole(PAUSER_ROLE, _admin);
        _setupRole(MINTSTOPPER_ROLE, _admin);

        _mint(_initialHolder, _initialSupply);
    }

    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        require(mintStopped != true, "Mint stopped");
        _mint(to, amount);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function stopMint() public onlyRole(MINTSTOPPER_ROLE) {
        mintStopped = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}

pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IRDNRegistry} from "./RDN/interfaces/IRDNRegistry.sol";
import {IRDNDistributor} from "./RDN/interfaces/IRDNDistributor.sol";
import {WithdrawAnyERC20Token} from "./Utils/WithdrawAnyERC20Token.sol";

contract Payments is AccessControlEnumerable, WithdrawAnyERC20Token {
    IRDNRegistry immutable public REGISTRY;
    uint public fee;

    struct Order {
        address currency;
        uint amount;
    }

    struct POS {
        address[] currencies;
        uint ownerId;
        uint rewards;
        bool paused;
        bool rdnOnly;
        uint activeTill;
        uint maxPaidAmount;
        uint maxOrdersCount;
        uint paidAmount;
    }

    mapping(uint => uint[]) public usersPOS;
    POS[] public POSRegistry;

    mapping(uint => mapping(uint => Order)) public orders;
    uint[][] public posPaidOrders;

    bytes32 public constant SETFEE_ROLE = keccak256("SETFEE_ROLE");

    event Payment(
        uint indexed posId,
        uint indexed orderId,
        address indexed currency,
        uint amount,
        uint totalOrderAmount,
        uint rewardsAmount,
        uint feeAmount
    );

    constructor(address _registry, address _admin) WithdrawAnyERC20Token(_admin, false) {
        REGISTRY = IRDNRegistry(_registry);
        fee = 1000;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(SETFEE_ROLE, _admin);
    }

    function pay(uint _posId, uint _orderId, address _currency, uint _amount) public{
        POS memory pos = POSRegistry[_posId]; // gas savings
        require(inArray(pos.currencies, _currency), 'Invalid _currency or _posId');
        require(isActive(_posId), "POS not active");
        if (pos.rdnOnly) {
            require(REGISTRY.isRegisteredByAddress(msg.sender), 'Not registered in RDN');
        }
        require(_amount > 0, '_amount should be positive');
        IERC20 token = IERC20(_currency);
        token.transferFrom(msg.sender, address(this), _amount);
        uint remainedAmount = _amount;
        uint feeAmount = _amount * fee / 10000;
        remainedAmount -= feeAmount;
        uint rewardsAmount = 0;
        if (pos.rewards > 0 && REGISTRY.isRegisteredByAddress(msg.sender)) { // if msg.sender is out of RDN, rewards forwards to POS owner
            rewardsAmount = remainedAmount * pos.rewards / 10000;
            remainedAmount -= rewardsAmount;
            IRDNDistributor distributor = IRDNDistributor(REGISTRY.getDistributor(_currency));
            token.approve(address(distributor), rewardsAmount);
            distributor.distribute(msg.sender, rewardsAmount);
        }

        if (remainedAmount > 0) {
            token.transfer(REGISTRY.getUserAddress(pos.ownerId), remainedAmount);
        }

        if (pos.maxPaidAmount > 0) {
            POSRegistry[_posId].paidAmount += _amount;
        }

        if (orders[_posId][_orderId].amount > 0) {
            require(orders[_posId][_orderId].currency == _currency, "Order must be paid by same tokens");
            orders[_posId][_orderId].amount += _amount;
        } else {
            Order memory newOrder = Order(_currency, _amount);
            orders[_posId][_orderId] = newOrder;
            posPaidOrders[_posId].push(_orderId);
        }
        
        emit Payment(_posId, _orderId, _currency, _amount, orders[_posId][_orderId].amount, rewardsAmount, feeAmount);
        
    }

    function inArray(address[] memory _haystack, address _needl) internal pure returns(bool) {
        for (uint i=0; i < _haystack.length; i++) {
            if (_haystack[i] == _needl) {
                return true;
            }
        }
        return false;
    }

    function createPOS(address[] calldata _currencies, uint _rewards, bool _rdnOnly, uint _activeTill, uint _maxOrdersCount, uint _maxPaidAmount) public {
        uint ownerId = REGISTRY.getUserIdByAddress(msg.sender);
        require(ownerId > 0, "Not registered in RDN");
        if (_maxPaidAmount > 0) {
            require(_currencies.length == 1, "_maxPaidAmount can't be positive for multiple currencies");
        }
        POS storage newPOS = POSRegistry.push();
        posPaidOrders.push();
        newPOS.ownerId = ownerId;
        newPOS.currencies = _currencies;
        newPOS.rewards = _rewards;
        newPOS.rdnOnly = _rdnOnly;
        newPOS.maxPaidAmount = _maxPaidAmount;
        newPOS.maxOrdersCount = _maxOrdersCount;
        newPOS.activeTill = _activeTill;
        uint posId = POSRegistry.length - 1;
        usersPOS[ownerId].push(posId);
    }


    function setFee(uint _fee) public onlyRole(SETFEE_ROLE) {
        fee = _fee;
    }

    function pause(uint _posId) public {
        uint ownerId = REGISTRY.getUserIdByAddress(msg.sender);
        require(POSRegistry[_posId].ownerId == ownerId, "Access denied");
        POSRegistry[_posId].paused = true;
    }

    function unPause(uint _posId) public {
        uint ownerId = REGISTRY.getUserIdByAddress(msg.sender);
        require(POSRegistry[_posId].ownerId == ownerId, "Access denied");
        POSRegistry[_posId].paused = false;
    }

    function isActive(uint _posId) public view returns(bool) {
        if (isPaused(_posId) || isStopped(_posId)) {
            return false;
        }
        return true;
    }

    function isPaused(uint _posId) public view returns(bool) {
        return POSRegistry[_posId].paused;
    }

    function isStopped(uint _posId) public view returns(bool) {
        POS memory pos = POSRegistry[_posId]; // gas savings
        if (pos.activeTill > 0 && pos.activeTill < block.timestamp) {
            return true;
        }
        if (pos.maxPaidAmount > 0 && pos.paidAmount >= pos.maxPaidAmount) {
            return true;
        }
        if (pos.maxOrdersCount > 0 && posPaidOrders[_posId].length >= pos.maxOrdersCount) {
            return true;
        }
        return false;
    }

    function getAllPOS() public view returns(POS[] memory) {
        return POSRegistry;
    }

    function getPOS(uint _posId) public view returns(POS memory) {
        return POSRegistry[_posId];
    }

    function getAllPOSOrders(uint _posId) public view returns(uint[] memory) {
        return posPaidOrders[_posId];
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


interface IRDNDistributor {
    
    function distribute(address _initAddress, uint _amount) external;

    function getToken() external view returns(address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IRDNRegistry} from "./IRDNRegistry.sol";

interface IRDNFactors {

    function getFactor(IRDNRegistry.User memory user) external view returns(uint);

    function calc(IRDNRegistry.User memory user) external pure returns(uint);

    function getDecimals() external view returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IRDNRegistry {
    
    struct User {
        uint level;
        address userAddress;
        uint parentId;
        uint tariff;
        uint activeUntill;
        uint created;
    }

    function getUser(uint) external view returns(User memory);

    function getUserIdByAddress(address _userAddress) external view returns(uint);

    function usersCount() external view returns(uint);
    
    function getChildren(uint _userId) external view returns(uint[] memory);

    function isRegistered(uint _userId) external view returns(bool);
    
    function isValidUser(uint _userId) external view returns(bool);
    
    function isRegisteredByAddress(address _userAddress) external view returns(bool);

    function isActive(uint _userId) external view returns(bool);

    function factorsAddress() external view returns(address);

    function getParentId(uint _userId) external view returns(uint);

    function getLevel(uint _userId) external view returns(uint);

    function getTariff(uint _userId) external view returns(uint);

    function getActiveUntill(uint _userId) external view returns(uint);

    function getUserAddress(uint _userId) external view returns(address);

    function getDistributor(address _token) external view returns(address);

    function setTariff(uint _userId, uint _tariff) external;
    
    function setActiveUntill(uint _userId, uint _activeUntill) external;

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract RDNAccountLinking {
    event AccountLinked (
        address indexed addr,
        uint256 indexed code
    );

    function linkAccount(uint256 _code) public {
        emit AccountLinked(msg.sender, _code);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract RDNAdjustments is AccessControlEnumerable {
    bytes32 public constant ADJUST_ROLE = keccak256("ADJUSTSTRUCTINC_ROLE");

    struct Adjustment {
        uint structPointsInc;
        uint ownPointsInc;
        uint structPointsMin;
        uint ownPointsMin;
        uint levelMin;
        uint dirLevelMin;
    }

    mapping (uint => Adjustment) public adjustments;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADJUST_ROLE, _admin);
    }

    function adjustUser(uint _userId, uint _structPointsInc, uint _ownPointsInc, uint _structPointsMin, uint _ownPointsMin, uint _levelMin, uint _dirLevelMin) public onlyRole(ADJUST_ROLE) {
        Adjustment memory adjustment = Adjustment(_structPointsInc, _ownPointsInc, _structPointsMin, _ownPointsMin, _levelMin, _dirLevelMin);
        adjustments[_userId] = adjustment;
    }

    function getAdjustment(uint _userId) public view returns(Adjustment memory) {
        return adjustments[_userId];
    }

}

pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";

interface IRDNDepositary {
    
    event TokensLocked(address indexed userAddress, uint indexed userId, uint amount, uint unlockAfter);

    event TokensUnlocked(address indexed userADDRESS, uint indexed userId, uint amount);

    function getLockedAmount(uint _userId) external view returns(uint);

    function getTotalLockedAmount() external view returns(uint);

}

contract RDNDepositary is Context, AccessControlEnumerable {
    bytes32 public constant WITHDRAW_OVERAGE_ROLE = keccak256("WITHDRAW_OVERAGE_ROLE");
    bytes32 public constant PAUSE_LOCKING_ROLE = keccak256("PAUSE_LOCKING_ROLE");
    bytes32 public constant LOCK_PERIOD_ROLE = keccak256("LOCK_PERIOD_ROLE");
    
    mapping (uint => uint) balances;
    mapping (uint => uint) unlockAfter;
    uint public totalLocked;
    uint public lockPeriod;
    bool public lockingPaused;

    IERC20 public token;
    IRDNRegistry registry;

    event TokensLocked(address indexed userAddress, uint indexed userId, uint amount, uint unlockAfter);

    event TokensUnlocked(address indexed userADDRESS, uint indexed userId, uint amount);

    constructor (address _tokenAddress, address _registryAddress, uint _lockPeriod) {
        token = IERC20(_tokenAddress);
        registry = IRDNRegistry(_registryAddress);
        lockPeriod = _lockPeriod;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(WITHDRAW_OVERAGE_ROLE, _msgSender());
        _setupRole(PAUSE_LOCKING_ROLE, _msgSender());
    }
    
    function lockTokens(uint _amount) public {
        require(lockingPaused == false, "Locking is paused");
        uint userId = registry.getUserIdByAddress(_msgSender());
        require(userId > 0, "Sender address is not registered");
        token.transferFrom(_msgSender(), address(this), _amount);
        balances[userId] += _amount;
        totalLocked += _amount;
        unlockAfter[userId] = block.timestamp + lockPeriod;
        emit TokensLocked(_msgSender(), userId, _amount, unlockAfter[userId]);
    }
    
    function unlockTokens() public {
        uint userId = registry.getUserIdByAddress(_msgSender());
        uint balance = balances[userId];
        require(userId > 0, "Sender address is not registered");
        require(balance > 0, "Balance is empty");
        require(unlockAfter[userId] < block.timestamp);
        token.transfer(_msgSender(), balance);
        balances[userId]  = 0;
        totalLocked -= balance;
        emit TokensUnlocked(_msgSender(), userId, balance);
    }

    function withdrawOverage(address _recipient) public onlyRole(WITHDRAW_OVERAGE_ROLE) {
        uint realBalance = token.balanceOf(address(this));
        uint overage = realBalance - totalLocked;
        require(overage > 0, "Nothing to withdraw");
        token.transfer(_recipient, overage);
    }

    function pauseLocking() public onlyRole(PAUSE_LOCKING_ROLE) {
        require(lockingPaused == false, "Locking is already paused");
        lockingPaused = true;
    }

    function unpauseLocking() public  onlyRole(PAUSE_LOCKING_ROLE){
        require(lockingPaused == true, "Locking is not paused");
        lockingPaused = false;
    }

    function setupLockPeriod(uint _lockPeriod) public onlyRole(LOCK_PERIOD_ROLE) {
        lockPeriod = _lockPeriod;
    }

    function getLockedAmount(uint _userId) public view returns(uint) {
        return balances[_userId];
    }

    function getTotalLockedAmount() public view returns(uint) {
        return totalLocked;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";
import {IRDNFactors} from "./interfaces/IRDNFactors.sol";
import {WithdrawAnyERC20Token} from "../Utils/WithdrawAnyERC20Token.sol";

contract RDNDistributor is AccessControlEnumerable, WithdrawAnyERC20Token {

    IERC20 public immutable token;
    IRDNRegistry public immutable registry;

    event Distributed(uint indexed userId, address indexed userAddress, address indexed tokenAddress, uint initUserId, address initAddress, uint amount);

    constructor(address _token, address _registry, address _admin) WithdrawAnyERC20Token(_admin, true) {
        token = IERC20(_token);
        registry = IRDNRegistry(_registry);
    }

    function distribute(address _initAddress, uint _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        uint userId = registry.getUserIdByAddress(_initAddress);
        uint initUserId = userId;
        IRDNFactors factors = IRDNFactors(registry.factorsAddress());
        uint8 count;
        uint factor;
        uint maxFactor;
        uint bonus;
        uint amountRemained = _amount;
        IRDNRegistry.User memory user = registry.getUser(userId);
        while (user.parentId > 0 && count < 12) {
            count += 1;
            userId = user.parentId;
            user = registry.getUser(userId);
            factor = factors.getFactor(user);
            if (factor > maxFactor) {
                bonus = (_amount * (factor - maxFactor))/ (10 ** factors.getDecimals());
                maxFactor = factor;
                amountRemained -= bonus;
                if (user.activeUntill > block.timestamp) {
                    token.transfer(user.userAddress, bonus);
                    emit Distributed(userId, user.userAddress, address(token), initUserId, _initAddress, bonus);
                }
            }
        }
    }

    function getToken() public view returns(address) {
        return address(token);
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";

contract RDNFactors {

    IRDNRegistry public registry;

    uint public decimals = 4;

    uint[7][12] public factors = [
        [1500, 1956, 2413, 2869, 3326, 3782, 4239 ],
        [4239, 4467, 4695, 4924, 5152, 5380, 5608 ],
        [5608, 5760, 5913, 6065, 6217, 6369, 6521 ],
        [6521, 6635, 6750, 6864, 6978, 7092, 7206 ],
        [7206, 7297, 7389, 7480, 7571, 7663, 7754 ],
        [7754, 7830, 7906, 7982, 8058, 8134, 8210 ],
        [8210, 8276, 8341, 8406, 8471, 8536, 8602 ],
        [8602, 8659, 8716, 8773, 8830, 8887, 8944 ],
        [8944, 8995, 9045, 9096, 9147, 9198, 9248 ],
        [9248, 9294, 9340, 9385, 9431, 9477, 9522 ],
        [9522, 9564, 9605, 9647, 9688, 9730, 9771 ],
        [9771, 9809, 9847, 9885, 9923, 9961, 10000 ]
    ];

    constructor (address _registry) {
        registry = IRDNRegistry(_registry);
    }
    
    function getFactor(IRDNRegistry.User memory user) public view returns(uint) {
        if (user.level == 0 || user.tariff == 0) return 0;
        user.level = (user.level >= 12)?11:(user.level-1);
        user.tariff = (user.tariff >= 7)?6:(user.tariff-1);
        return factors[user.level][user.tariff];
    }

    function calc(IRDNRegistry.User memory user) public pure returns(uint) {
        uint tariffsCount = 7;
        uint maxFactor = 1 ether;

        // return _level*(maxFactor/12)/(10**14);

        uint min = (user.level >= 12 && user.tariff >= 7)?maxFactor:(maxFactor - calcStep(user.level, 12));
        uint max = (user.level >= 12 && user.tariff >= 7)?maxFactor:(maxFactor - calcStep(user.level+1, 12));
        uint tariffStep = (max - min)/(tariffsCount-1);
        uint factor = min + tariffStep * (user.tariff - 1);
        return factor/(10**14);
    }

    function test(uint x) public pure returns(uint) {
        return x*2;
    }

    function calcStep(uint _level, uint _levelMax) pure private returns(uint) {
        uint base = 0.2739 ether;
        if (_level > _levelMax) {
            return 0;
        } else {
            return (base/_levelMax + calcStep(_level, _levelMax-1));
        }
    }

    function getDecimals() public view returns(uint) {
        return decimals;
    }

    function getAllFactors() public view returns(uint[7][12] memory) {
        return factors;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {WithdrawAnyERC20Token} from "../Utils/WithdrawAnyERC20Token.sol";
import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";

// Parent 0 address restricted
// Default level 1

contract RDNRegistry is IRDNRegistry, AccessControlEnumerable, WithdrawAnyERC20Token {

    // admin role for userlevel change (setLevel function)
    bytes32 public constant SETLEVEL_ROLE = keccak256("SETLEVEL_ROLE");
    // admin role for userlevel change (levelUp function)
    bytes32 public constant LEVELUP_ROLE = keccak256("LEVELUP_ROLE");
    // admin role for changing factors contract address
    bytes32 public constant FACTORSADDRESS_ROLE = keccak256("FACTORSADDRESS_ROLE");
    // admin role for RDNPOS contract
    bytes32 public constant TARIFFUPDATE_ROLE = keccak256("TARIFFUPDATE_ROLE");
    // admin role for RDNPOS contract 
    bytes32 public constant ACTIVEUNTILLUPDATE_ROLE = keccak256("ACTIVEUNTILLUPDATE_ROLE");
    // admin role fore points rate updating
    bytes32 public constant POINTSRATEUPDATE_ROLE = keccak256("POINTSRATEUPDATE_ROLE");
    // admin role for RDNDistributors configuration
    bytes32 public constant SETDISTRIBUTOR_ROLE = keccak256("SETDISTRIBUTOR_ROLE");
    // admin role for adding custom users
    bytes32 public constant ADDUSERBYADMIN_ROLE = keccak256("ADDUSERBYADMIN_ROLE");

    // actual userAddress => userId
    mapping (address => uint) public userId;
    // users registry
    User[] public users;
    // gas saving counter
    uint public usersCount;
    mapping(uint => uint[]) public children;

    // addresses granted to change userAddress for userId;
    mapping(uint => mapping(address => bool)) public changeAddressAccess;
    mapping(uint => address[]) public changeAddressAddresses;

    // actual factors contract
    address public factorsAddress;

    // token => rate (rate is 1/USDprice for token, based in token.decimals)
    mapping (address => uint) public pointsRate;

    // actual RDNDistributors registry. token => RDNDistributor
    mapping (address => address) public distributors;

    // when new user created
    event UserAdded(uint indexed userId, uint indexed parentId, address indexed userAddress);
    // when users level updated
    event UserLevelUpdated(uint indexed userId, uint levelBefore, uint levelAfter);
    // when users tariff updated
    event UserTariffUpdated(uint indexed userId, uint tariffBefore, uint tariffAfter);
    // when users activeUntill updated
    event UserActiveUntillUpdated(uint indexed userId, uint activeUntill);
    // when tokens points rate value updated
    event PointsRateUpdated(address indexed token, uint rate);
    // when userAddress changed
    event UserAddressChanged(uint indexed userId, address indexed userAddress, address indexed sender, address oldAddress);
    // when granted change user address
    event GrantedUserAddressChange(uint indexed userId, address indexed grantedAddress);
    // when revoked access to change user address
    event RevokedUserAddressChange(uint indexed userId, address indexed revokedAddress);

    /*
     * @notice Constructor
     * @param _root: userAdrress for userId = 1
     * @param _admin: default admin
    */
    constructor (address _root, address _admin) WithdrawAnyERC20Token(_admin, false) {
        // add 0 user. No one user can reference 0 in parentId, excluding user 1.
        User memory _zeroUser = User(0, address(0), 0, 0, 0, block.timestamp);
        users.push(_zeroUser);
        userId[address(0)] = 0;
        
        //add root user (userId 1), referencing parantId=0.
        User memory _rootUser = User(12, _root, 0, 7, block.timestamp + 36500 days, block.timestamp);
        users.push(_rootUser);
        userId[_root] = 1;
        children[0].push(1);

        usersCount = 2;

        // default roles setup
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(SETLEVEL_ROLE, _admin);
        _setupRole(LEVELUP_ROLE, _admin);
        _setupRole(FACTORSADDRESS_ROLE, _admin);
        _setupRole(TARIFFUPDATE_ROLE, _admin);
        _setupRole(ACTIVEUNTILLUPDATE_ROLE, _admin);
        _setupRole(POINTSRATEUPDATE_ROLE, _admin);
        _setupRole(SETDISTRIBUTOR_ROLE, _admin);
        _setupRole(ADDUSERBYADMIN_ROLE, _admin);
    }

    ///////////////////////////////////////
    // public user functions
    ///////////////////////////////////////
    
    /* 
     * @notice user registration
     * @param _parentId: registered user with tariff > 0
    */
    function register(uint _parentId) external {
        _addUser(msg.sender, _parentId);
    }

    /*
     * @notice user or granted addresses can change userAddress
    */
    function changeAddress(uint _userId, address _newAddress) public hasChangeAddressAccess(_userId) {
        require(!isRegisteredByAddress(_newAddress), "user already registered");
        emit UserAddressChanged(_userId, _newAddress, msg.sender, users[_userId].userAddress);
        userId[users[_userId].userAddress] = 0;
        userId[_newAddress] = _userId;
        users[_userId].userAddress = _newAddress;
    }

    /*
     * @notice user can grant other addresses to change userAddress
    */
    function grantChangeAddressAccess(address _grantedAddress) public onlyRegisteredByAddress(msg.sender) {
        uint _userId = userId[msg.sender];
        changeAddressAddresses[_userId].push(_grantedAddress);
        changeAddressAccess[_userId][_grantedAddress] = true;
        emit GrantedUserAddressChange(_userId, _grantedAddress);
    }

    /*
    * @notice user can revoke changeAddressAccess. Granted address can revoke its own access
    */
    function revokeChangeAddressAccess(uint _userId, address _grantedAddress) public {
        require(users[_userId].userAddress == msg.sender || _grantedAddress == msg.sender, "Access denied");
        changeAddressAccess[_userId][_grantedAddress] = false;
        emit RevokedUserAddressChange(_userId, _grantedAddress);
    }

    //////////////////////////////////////
    // admin functions
    //////////////////////////////////////

    function levelUp(uint _userId, uint _level) public onlyRole(LEVELUP_ROLE) onlyValidUser(_userId) {
        require(_level > users[_userId].level, "_level must be greater");
        emit UserLevelUpdated(_userId, users[_userId].level, _level);
        users[_userId].level = _level;
    }

    function setLevel(uint _userId, uint _level) public onlyRole(SETLEVEL_ROLE) onlyValidUser(_userId) {
        emit UserLevelUpdated(_userId, users[_userId].level, _level);
        users[_userId].level = _level;
    }

    function setFactorsAddress(address _factorsAddress) public onlyRole(FACTORSADDRESS_ROLE) {
        factorsAddress = _factorsAddress;
    }

    function setTariff(uint _userId, uint _tariff) public onlyRole(TARIFFUPDATE_ROLE) onlyValidUser(_userId) {
        emit UserTariffUpdated(_userId, users[_userId].tariff, _tariff);
        users[_userId].tariff = _tariff;
    }

    function setActiveUntill(uint _userId, uint _activeUntill) public onlyRole(ACTIVEUNTILLUPDATE_ROLE) onlyValidUser(_userId) {
        users[_userId].activeUntill = _activeUntill;
        emit UserActiveUntillUpdated(_userId, _activeUntill);
    }

    function setPointsRate(address _token, uint _rate) public onlyRole(POINTSRATEUPDATE_ROLE) {
        pointsRate[_token] = _rate;
        emit PointsRateUpdated(_token, _rate);
    }

    function setDistributor(address _token, address _distributor) public onlyRole(SETDISTRIBUTOR_ROLE) {
        distributors[_token] = _distributor;
    }

    function grantCompleteAdmin(address _admin) public {
        grantRole(DEFAULT_ADMIN_ROLE, _admin);
        grantRole(SETLEVEL_ROLE, _admin);
        grantRole(LEVELUP_ROLE, _admin);
        grantRole(FACTORSADDRESS_ROLE, _admin);
        grantRole(TARIFFUPDATE_ROLE, _admin);
        grantRole(ACTIVEUNTILLUPDATE_ROLE, _admin);
        grantRole(POINTSRATEUPDATE_ROLE, _admin);
        grantRole(SETDISTRIBUTOR_ROLE, _admin);
        grantRole(ADDUSERBYADMIN_ROLE, _admin);
    }

    function revokeCompleteAdmin(address _admin) public {
        revokeRole(SETLEVEL_ROLE, _admin);
        revokeRole(LEVELUP_ROLE, _admin);
        revokeRole(FACTORSADDRESS_ROLE, _admin);
        revokeRole(TARIFFUPDATE_ROLE, _admin);
        revokeRole(ACTIVEUNTILLUPDATE_ROLE, _admin);
        revokeRole(POINTSRATEUPDATE_ROLE, _admin);
        revokeRole(SETDISTRIBUTOR_ROLE, _admin);
        revokeRole(ADDUSERBYADMIN_ROLE, _admin);
        revokeRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /*
     * @notice sender must have 3 roles
    */
    function addUserByAdmin(uint _parentId, address _userAddress, uint _tariff, uint _activeUntill, uint _level) public onlyRole(ADDUSERBYADMIN_ROLE) {
        (uint _userId) = _addUser(_userAddress, _parentId);
        setTariff(_userId, _tariff);
        setActiveUntill(_userId, _activeUntill);
        setLevel(_userId, _level);
    }

    //////////////////////////////////////
    // private functions
    //////////////////////////////////////

    function _addUser(address _userAddress, uint _parentId) private returns(uint) {
        require(!isRegisteredByAddress(_userAddress), "user already registered");
        require(isRegistered(_parentId), "_parentId not found");
        require(users[_parentId].tariff > 0, "_parentId can not be parent");
        User memory _user = User(1, _userAddress, _parentId, 0, 0, block.timestamp);
        users.push(_user);
        usersCount += 1;
        userId[_userAddress] = usersCount - 1;
        children[_parentId].push(usersCount - 1);
        emit UserAdded(usersCount - 1, _parentId, _userAddress);
        return (usersCount - 1);
    }


    //////////////////////////////////////
    // modifiers
    //////////////////////////////////////


    modifier onlyRegisteredByAddress(address _userAddress) {
        require(isRegisteredByAddress(_userAddress), "user not registered");
        _;
    }

    modifier onlyRegistered(uint _userId) {
        require(isRegistered(_userId), "user not registered");
        _;
    }

    modifier onlyValidUser(uint _userId) {
        require(isValidUser(_userId), "invalid userId");
        _;
    }

    modifier hasChangeAddressAccess(uint _userId) {
        require(isValidUser(_userId), "UserId not valid");
        require(users[_userId].userAddress == msg.sender || changeAddressAccess[_userId][msg.sender], "Access denied");
        _;
    }


    //////////////////////////////////////
    // public getters and checkers
    //////////////////////////////////////

    /*
     * @notice 0 user is also registered
    */
    function isRegistered(uint _userId) public view returns(bool) {
        if (_userId < usersCount) {
            return true;
        }
        return false;
    }

    /*
     * @notice 0 user is not valid
    */
    function isValidUser(uint _userId) public view returns(bool) {
        if ((_userId > 0) && (_userId < usersCount)) {
            return true;
        }
        return false;
    }

    function isRegisteredByAddress(address _userAddress) public view returns(bool) {
        if (userId[_userAddress] != 0 || _userAddress == address(0)) {
            return true;
        }
        return false;
    }

    function isActive(uint _userId) public view returns(bool) {
        return (users[_userId].activeUntill > block.timestamp);
    }

    function getParentId(uint _userId) public view returns(uint) {
        return users[_userId].parentId;
    }

    function getLevel(uint _userId) public view returns(uint) {
        return users[_userId].level;
    }

    function getTariff(uint _userId) public view returns(uint) {
        return users[_userId].tariff;
    }

    function getActiveUntill(uint _userId) public view returns(uint) {
        return users[_userId].activeUntill;
    }

    function getUserAddress(uint _userId) public view returns(address) {
        return users[_userId].userAddress;
    }

    function getAllUsers() public view returns(User[] memory) {
        return users;
    }

    function getUser(uint _userId) public view returns(User memory) {
        return users[_userId];
    }

    function getUserIdByAddress(address _userAddress) public view returns(uint) {
        return userId[_userAddress];
    }

    function getUsersCount() public view returns(uint) {
        return usersCount;
    }

    function getChildren(uint _userId) public view returns(uint[] memory) {
        return children[_userId];
    }

    function getPointsRate(address _token) public view returns(uint) {
        return pointsRate[_token];
    }

    function getDistributor(address _token) public view returns(address) {
        require (distributors[_token] != address(0), "Distributor not found");
        return distributors[_token];
    }

    function isHasChangeAddressAccess(uint _userId, address _grantedAddress) public view returns(bool) {
        return (users[_userId].userAddress == _grantedAddress || changeAddressAccess[_userId][_grantedAddress]);
    }

    function getGrantedChangeAddress(uint _userId) public view returns(address[] memory) {
        return changeAddressAddresses[_userId];
    }


}

pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";
import {IRDNDistributor} from "./interfaces/IRDNDistributor.sol";
import {WithdrawAnyERC20Token} from "../Utils/WithdrawAnyERC20Token.sol";

contract RDNTariffPos is
    Context,
    AccessControlEnumerable,
    WithdrawAnyERC20Token
{

    event Turnover(
        uint indexed userId,
        address indexed token,
        uint turnoverAmount,
        uint normalizedTurnover
    );

    event RDNSubscriptionBonus(
        uint indexed userId,
        address indexed userAddress,
        uint bonusAmount
    );

    IERC20 public immutable token1;
    IERC20 public immutable token2;
    IRDNRegistry public immutable registry;

    mapping(uint => uint[2]) public tariffPrices;
    mapping(uint => mapping(uint => uint)) public subscriptionPackagePrices;
    uint public defaultSubscriptionPeriod = 30 * 24 * 60 * 60;
    uint public reward = 4800;
    mapping(uint => uint[2]) public usersPaid;

    mapping(uint => uint) public bonusCounter;
    mapping (uint => uint) public bonusAmountPerTariff;
    mapping (uint => bool) public bonusCandidatesExcluded;
    uint public bonusCandidatesCounter;
    uint public bonusCandidatesLimit;
    uint public bonusCandidatesLimitRDN;
    uint public bonusRequirement;

    bool public token2Points;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");

    constructor(
        address _token1,
        address _token2,
        address _registry,
        address _admin
    ) WithdrawAnyERC20Token(_admin, false) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        registry = IRDNRegistry(_registry);

        token2Points = false;

        tariffPrices[1] = [150 ether, 0];
        tariffPrices[2] = [300 ether, 3 ether];
        tariffPrices[3] = [600 ether, 6 ether];
        tariffPrices[4] = [900 ether, 12 ether];
        tariffPrices[5] = [1200 ether, 15 ether];
        tariffPrices[6] = [1500 ether, 21 ether];
        tariffPrices[7] = [1800 ether, 24 ether];

        subscriptionPackagePrices[1][30] = 24 ether;
        subscriptionPackagePrices[1][90] = 72 ether;
        subscriptionPackagePrices[1][180] = 144 ether;
        subscriptionPackagePrices[1][360] = 288 ether;

        subscriptionPackagePrices[2][30] = 42 ether;
        subscriptionPackagePrices[2][90] = 126 ether;
        subscriptionPackagePrices[2][180] = 252 ether;
        subscriptionPackagePrices[2][360] = 504 ether;

        subscriptionPackagePrices[3][30] = 42 ether;
        subscriptionPackagePrices[3][90] = 126 ether;
        subscriptionPackagePrices[3][180] = 252 ether;
        subscriptionPackagePrices[3][360] = 504 ether;

        subscriptionPackagePrices[4][30] = 42 ether;
        subscriptionPackagePrices[4][90] = 126 ether;
        subscriptionPackagePrices[4][180] = 252 ether;
        subscriptionPackagePrices[4][360] = 504 ether;

        subscriptionPackagePrices[5][30] = 42 ether;
        subscriptionPackagePrices[5][90] = 126 ether;
        subscriptionPackagePrices[5][180] = 252 ether;
        subscriptionPackagePrices[5][360] = 504 ether;

        subscriptionPackagePrices[6][30] = 42 ether;
        subscriptionPackagePrices[6][90] = 126 ether;
        subscriptionPackagePrices[6][180] = 252 ether;
        subscriptionPackagePrices[6][360] = 504 ether;

        subscriptionPackagePrices[7][30] = 42 ether;
        subscriptionPackagePrices[7][90] = 126 ether;
        subscriptionPackagePrices[7][180] = 252 ether;
        subscriptionPackagePrices[7][360] = 504 ether;

        bonusAmountPerTariff[1] = 12 ether;
        bonusAmountPerTariff[2] = 30 ether;
        bonusAmountPerTariff[3] = 30 ether;
        bonusAmountPerTariff[4] = 30 ether;
        bonusAmountPerTariff[5] = 30 ether;
        bonusAmountPerTariff[6] = 30 ether;
        bonusAmountPerTariff[7] = 30 ether;

        bonusCandidatesLimit = 10000;
        bonusCandidatesLimitRDN = 3000;
        bonusRequirement = 360;

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(CONFIG_ROLE, _admin);
    }

    // todo Добавлять в каунтер если новый тариф и лимит не исчерпан и больше RDNLimit

    function activateTariff(uint _tariff) public {
        uint userId = registry.getUserIdByAddress(_msgSender());
        require(userId > 0, "Not registered in RDN");
        IRDNRegistry.User memory user = registry.getUser(userId);
        require(
            tariffPrices[_tariff][0] > 0 || tariffPrices[_tariff][1] > 0,
            "Invalid tariff"
        );
        require(_tariff > user.tariff, "New tariff is lower than current");

        // bonus counters
        if ((user.tariff == 0) && (userId > bonusCandidatesLimitRDN) && (bonusCandidatesCounter < bonusCandidatesLimit)) {
            bonusCandidatesCounter += 1;
            bonusCounter[userId] = 30;
        }

        uint[2] memory amountReq = calcActivationPrice(
            userId,
            user.tariff,
            _tariff
        );

        if (amountReq[0] > 0) {
            token1.transferFrom(_msgSender(), address(this), amountReq[0]);
            usersPaid[userId][0] += amountReq[0];
            IRDNDistributor distributor1 = IRDNDistributor(
                registry.getDistributor(address(token1))
            );
            uint rewardsAmount1 = (amountReq[0] * reward) / 10000;
            token1.approve(address(distributor1), rewardsAmount1);
            distributor1.distribute(_msgSender(), rewardsAmount1);
            emit Turnover(
                userId,
                address(token1),
                amountReq[0],
                amountReq[0] / 10
            );
        }
        if (amountReq[1] > 0) {
            token2.transferFrom(_msgSender(), address(this), amountReq[1]);
            usersPaid[userId][1] += amountReq[1];
            IRDNDistributor distributor2 = IRDNDistributor(
                registry.getDistributor(address(token2))
            );
            uint rewardsAmount2 = (amountReq[1] * reward) / 10000;
            token2.approve(address(distributor2), rewardsAmount2);
            distributor2.distribute(_msgSender(), rewardsAmount2);
            if (token2Points) {
                emit Turnover(
                    userId,
                    address(token2),
                    amountReq[1],
                    amountReq[1] / 10
                );
            }
        }
        if (user.tariff == 0) {
            registry.setActiveUntill(
                userId,
                block.timestamp + defaultSubscriptionPeriod
            );
        }
        registry.setTariff(userId, _tariff);
    }

    function prolongSubscription(uint _package) public {
        uint userId = registry.getUserIdByAddress(_msgSender());
        require(userId > 0, "Not registered in RDN");
        IRDNRegistry.User memory user = registry.getUser(userId);
        uint amount = _calcProlongPrice(user, _package); // gas savings
        require(amount > 0, "Package is not available");
        require(user.tariff > 0, "User tariff is 0");

        // bonus excluding
        if (
            ((userId <= bonusCandidatesLimitRDN) || (bonusCounter[userId] > 0)) &&
            user.activeUntill < block.timestamp
        ) {
            bonusCandidatesExcluded[userId] = true;
        }

        if (user.activeUntill == 0) {
            registry.setActiveUntill(
                userId,
                block.timestamp + _package * 60 * 60 * 24
            );
        } else {
            registry.setActiveUntill(
                userId,
                user.activeUntill + _package * 60 * 60 * 24
            );
        }

        token1.transferFrom(_msgSender(), address(this), amount);

        uint rewardsAmount = (amount * reward) / 10000;
        IRDNDistributor distributor1 = IRDNDistributor(
            registry.getDistributor(address(token1))
        );
        token1.approve(address(distributor1), rewardsAmount);
        distributor1.distribute(_msgSender(), rewardsAmount);

        emit Turnover(userId, address(token1), amount, amount / 10);

        // bonus counter / execution
        (, uint bonusAmount) = estimateBonus(userId);
        // if ((reqBefore > 0) && (reqBefore < bonusRequirement)) {
        if (bonusAmount > 0) {
            bonusCounter[userId] += _package;
            if (bonusCounter[userId] >= bonusRequirement) {
                token2.transfer(user.userAddress, bonusAmount);
                emit RDNSubscriptionBonus(userId, user.userAddress, bonusAmount);
            }
        }
    }

    function calcActivationPrice(
        uint _userId,
        uint _tariffFrom,
        uint _tariffTo
    ) public view returns (uint[2] memory) {
        uint[2] memory price;
        // gas savings
        uint[2] memory _usersPaid = usersPaid[_userId];
        uint[2] memory _tariffPrices = tariffPrices[_tariffTo];

        if (_usersPaid[0] > 0 || _usersPaid[1] > 0) {
            if (_tariffPrices[0] > _usersPaid[0]) {
                price[0] = _tariffPrices[0] - _usersPaid[0];
            } else {
                price[0] = 0;
            }
            if (_tariffPrices[1] > _usersPaid[1]) {
                price[1] = _tariffPrices[1] - _usersPaid[1];
            } else {
                price[1] = 0;
            }
        } else {
            price[0] = _tariffPrices[0] - tariffPrices[_tariffFrom][0];
            price[1] = _tariffPrices[1] - tariffPrices[_tariffFrom][1];
        }

        if (
            _tariffFrom > 0 &&
            (subscriptionPackagePrices[_tariffTo][30] >
                subscriptionPackagePrices[_tariffFrom][30]) &&
            registry.isActive(_userId)
        ) {
            uint remaindSeconds = registry.getActiveUntill(_userId) - block.timestamp;
            uint diffSecondPrice = 
                (
                    subscriptionPackagePrices[_tariffTo][30] - 
                    subscriptionPackagePrices[_tariffFrom][30]
                ) /
                (30 * 24 * 60 * 60);
            price[0] += remaindSeconds * diffSecondPrice;
        }

        return price;
    }

    function calcProlongPrice(uint _userId, uint _package)
        public
        view
        returns (uint)
    {
        IRDNRegistry.User memory user = registry.getUser(_userId);
        return _calcProlongPrice(user, _package);
    }

    function _calcProlongPrice(IRDNRegistry.User memory _user, uint _package)
        private
        view
        returns (uint)
    {
        uint remaindSeconds = (block.timestamp < _user.activeUntill)
            ? (_user.activeUntill - block.timestamp)
            : 0;
        // should remain not more than 13 months after prolongation
        if ((_package * 24 * 60 * 60 + remaindSeconds) > (390 * 24 * 60 * 60)) {
            return 0;
        }
        return subscriptionPackagePrices[_user.tariff][_package];
    }

    function estimateBonus(uint _userId) public view returns(uint requirement, uint bonusAmount) {
        uint counter = bonusCounter[_userId];
        uint req = bonusRequirement;

        if (_userId <= bonusCandidatesLimitRDN) {
            counter += 30;
        }

        if (
            !registry.isActive(_userId) ||
            bonusCandidatesExcluded[_userId] || 
            (counter == 0) ||
            (counter >= req)
        ) {
            return (0, 0);
        }

        uint tariff = registry.getTariff(_userId);

        return ((req - counter), bonusAmountPerTariff[tariff]);
    }

    function getTariffPrice(uint _tariff)
        public
        view
        returns (uint[2] memory)
    {
        return tariffPrices[_tariff];
    }

    function getSubscriptionPackagePrice(uint _tariff, uint _package)
        public
        view
        returns (uint) 
    {
        return subscriptionPackagePrices[_tariff][_package];
    }

    function setReward(uint _reward) public onlyRole(CONFIG_ROLE) {
        reward = _reward;
    }

    function setTariffPrice(
        uint _tariff,
        uint _price1,
        uint _price2
    ) public onlyRole(CONFIG_ROLE) {
        tariffPrices[_tariff] = [_price1, _price2];
    }

    function setDefaultSupscriptionPeriod(uint _value) public onlyRole(CONFIG_ROLE)
    {
        defaultSubscriptionPeriod = _value;
    }

    function setBonusAmount(uint _tariff, uint _bonus) public onlyRole(CONFIG_ROLE) 
    {
        bonusAmountPerTariff[_tariff] = _bonus;
    }

    function setBonusCandidatesLimit(uint _limit) public onlyRole(CONFIG_ROLE)
    {
        bonusCandidatesLimit = _limit;
    }

    function setBonusCandidatesLimitRDN(uint _limit) public onlyRole(CONFIG_ROLE) 
    {
        bonusCandidatesLimitRDN = _limit;
    }

    function setBonusRequirement(uint _req) public onlyRole(CONFIG_ROLE) 
    {
        require(_req > bonusRequirement, "Must be greater");
        bonusRequirement = _req;
    }

    function setToken2Pioints(bool _token2Points) public onlyRole(CONFIG_ROLE) 
    {
        token2Points = _token2Points;
    }

    function setBonusCounter(uint _userId, uint _counter) public onlyRole(CONFIG_ROLE) {
        if ((bonusCounter[_userId] == 0) && (_counter > 0) && (_userId > bonusCandidatesLimitRDN)) {
            bonusCandidatesCounter += 1;
        }
        bonusCounter[_userId] = _counter;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// transfer/withdraw locked Tokens
// unlock tokens
// destroy contract / close addUser

contract RDNWaitlist is AccessControlEnumerable {
    // bytes32 public constant USERADD_ROLE = keccak256("USERADD_ROLE");

    uint[] public tokens;

    mapping (uint => address) public addressByToken;
    mapping (address => uint) public tokenByAddress;

    constructor (address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function register(uint _token) public {
        require(addressByToken[_token] == address(0), "Token already registered");
        require(tokenByAddress[msg.sender] == 0, "Address already registered") ;
        addressByToken[_token] = msg.sender;
        tokenByAddress[msg.sender] = _token;
        tokens.push(_token);
    }

    function getAddressByToken(uint _token) public view returns(address) {
        return addressByToken[_token];
    }

    function getTokenByAddress(address _userAddress) public view returns(uint) {
        return tokenByAddress[_userAddress];
    }

    function getAllTokens() public view returns(uint[] memory) {
        return tokens;
    }

}

pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// interface IWithdrawAnyERC20Token {
    
//     function withdrawAnyERC20Token(address _token, address _target, uint _amount) external;

// }

contract WithdrawAnyERC20Token is AccessControlEnumerable {
    bytes32 public constant WITHDRAWANY_ROLE = keccak256("WITHDRAWANY_ROLE");

    constructor (address _admin, bool _isDefaultAdminRole) {
        if (_isDefaultAdminRole) {
            _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        }
        _setupRole(WITHDRAWANY_ROLE, _admin);
    }

    function withdrawAnyERC20Token(address _token, address _target, uint _amount) public onlyRole(WITHDRAWANY_ROLE) {
        IERC20(_token).transfer(_target, _amount);
    }

}