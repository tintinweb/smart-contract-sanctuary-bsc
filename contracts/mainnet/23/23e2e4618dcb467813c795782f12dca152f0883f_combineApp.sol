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
            require(denominator > prod1, "Math: mulDiv overflow");

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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
   
uint constant MAX_INT = type(uint).max;
uint constant DEPOSIT_HOLD = 15; // 600;
address constant WBNB_ADDR = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

struct stData {
    address lpContract;
    address token0;
    address token1;

    uint poolId;
    uint dust;        
    uint poolTotal;
    uint unitsTotal;
    uint depositTotal;
    uint withdrawTotal;
    uint lastProcess;
    uint lastDiscount;
    bool paused;
}

struct sHolders {
    uint amount;
    uint holdback;
    uint depositDate;
    uint discount;
    uint discountValidTo;        
    uint _pos;
}

struct transHolders {
    uint amount;
    uint timestamp;
    address account;
}

struct stHolders{
    mapping (address=>sHolders) iHolders;
    address[] iQueue;

    transHolders[] dHolders;        
    mapping(address=>uint[]) dQueue;
    
    transHolders[] wHolders;        
    mapping(address=>uint[]) wQueue;
}

interface iMasterChef{
     function pendingCake(uint256 _pid, address _user) external view returns (uint256);
     function poolInfo(uint _poolId) external view returns (address, uint,uint,uint);
     function userInfo(uint _poolId, address _user) external view returns (uint,uint);
     function deposit(uint poolId, uint amount) external;
     function withdraw(uint poolId, uint amount) external;
     function cakePerBlock() external view returns (uint);
     function updatePool(uint poolId) external;
}

interface iMasterChefv2{
    function poolInfo(uint _poolId) external view returns (uint, uint,uint,uint,bool);
    function lpToken(uint _poolId) external view returns (address);
}


interface iRouter { 
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);    
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function addLiquidityETH(address token,uint amountTokenDesired ,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(address tokenA,address tokenB, uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
}

interface iLPToken{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);    
}

interface iBeacon {
    struct sExchangeInfo {
        address chefContract;
        address routerContract;
        address rewardToken;
        address intermediateToken;
        address baseToken;
        string pendingCall;
        string contractType_solo;
        string contractType_pooled;
        bool psV2;
    }

    function getExchangeInfo(string memory _name) external view returns(sExchangeInfo memory);
    function getFee(string memory _exchange, string memory _type, address _user) external returns(uint,uint);
    function getFee(string memory _exchange, string memory _type) external returns(uint,uint);
    function getDiscount(address _user) external view returns(uint,uint);
    function getConst(string memory _exchange, string memory _type) external returns(uint64);
    function getExchange(string memory _exchange) external view returns(address);
    function getAddress(string memory _key) external view returns(address _value);
    function getDataUint(string memory _key) external view returns(uint _value);
}

interface iWBNB {
    function withdraw(uint wad) external;
}

interface iSimpleDefiSolo {
    function deposit(uint64 _poolId, string memory _exchangeName) external payable;  
}

//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./utils/slots.sol";

contract Storage {
    uint64 public holdBack;
    uint256 public lastGas;
    address public logic_contract;
    address internal feeCollector;
    address public beaconContract;
    
    iBeacon.sExchangeInfo public exchangeInfo;


    bool internal _locked;
    bool internal _initialized;
    bool internal _shared;

    bytes32 public constant HARVESTER = keccak256("HARVESTER");

    string public exchange;    
    //New Variables after this only

    slotsLib.slotStorage[] public slots;
    uint public SwapFee;
    uint public revision;
}

//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
import "./Interfaces.sol";
import "./Storage.sol";

contract combineApp is Storage, Ownable, AccessControl {
    event sdDeposit(uint amount);
    event sdHoldBack(uint amount, uint total);
    event sdFeeSent(address _user, bytes16 _type, uint amount,uint total);
    event sdNewPool(uint64 oldPool, string oldExchange, uint newPool, string newExchange, uint amount);
    event sdLiquidityProvided(uint256 farmIn, uint256 wethIn, uint256 lpOut);
    event sdInitialized(uint64 poolId, address lpContract);
    event sdInitialize(uint64 _poolId, address _beacon, string _exchangeName, address _owner);
    // event sdHarvesterAdd(address _harvester);
    // event sdHarvesterRemove(address _harvester);
    event sdRescueToken(address _token,uint _amount);
    event sdLiquidated(uint _amount);
    event sdSetHoldback(uint _holdback);
    event sdRemoved(uint _removed);
    error sdLocked();
    error sdInitializedError();
    error sdInsufficentBalance();
    error sdRequiredParameter(string param);
    error sdInsufficentFunds();

    modifier lockFunction() {
        if (_locked) revert sdLocked();
        _locked = true;
        _;
        _locked = false;
    }
     
    modifier allowAdmin() {
        if (!(hasRole(HARVESTER,msg.sender) || owner() == msg.sender)) revert sdLocked();
        _;
    }
    ///@notice Initialize the proxy contract
    ///@param _poolId the id of the pool
    ///@param _beacon the address of the beacon contract
    ///@param _exchangeName name of the exchange to lookup on beacon
    ///@param _owner the address of the owner
    function initialize(uint64 _poolId, address _beacon, string memory _exchangeName, address _owner) public onlyOwner payable {
        if (_initialized) revert sdInitializedError();
        _initialized = true;
        beaconContract = _beacon;

        address harvester = iBeacon(beaconContract).getAddress("HARVESTER");
        feeCollector = iBeacon(beaconContract).getAddress("FEECOLLECTOR");
        (SwapFee,) = iBeacon(beaconContract).getFee(_exchangeName,"SWAPFEE",address(0)); //SWAP FEE is 1e8

        _setupRole(HARVESTER, harvester);
        _setupRole(DEFAULT_ADMIN_ROLE,owner());

        holdBack = 0; 
        
        setup(_poolId, _exchangeName);
        transferOwnership(_owner);
        revision = 1;
        
        emit sdInitialize(_poolId, _beacon,_exchangeName,_owner);
    }

    // ///@notice Add harvester permission to contract
    // ///@param _address address of user to add as harvester
    // function addHarvester(address _address) external onlyOwner {
    //     _setupRole(HARVESTER,_address);
    //     emit sdHarvesterAdd(_address);
    // }

    // ///@notice Remove user as harvester
    // ///@param _address address of user to remove as harvester
    // function removeHarvester(address _address) external onlyOwner{
    //     revokeRole(HARVESTER,_address);
    //     emit sdHarvesterRemove(_address);
    // }

    ///@notice create slot for new pool
    ///@param _poolId id of new pool
    ///@param _exchangeName name of exchange to lookup on beacon
    function setup(uint64 _poolId, string memory _exchangeName) private  {
        slotsLib.sSlots memory _slot = slotsLib.updateSlot(uint64(slotsLib.MAX_SLOTS+1),_poolId,_exchangeName, slots, beaconContract);

        if (msg.value > 0) {
            addFunds(_slot, msg.value,true);
            emit sdDeposit(msg.value);
        }
        emit sdInitialized(_poolId,_slot.lpContract);
    }
    
    ///@notice default receive function
    receive() external payable {}


    //@notice Add funds to specified pool and exhange
    ///@param _poolId id of pool to add funds to
    ///@param _exchangeName name of exchange to lookup on beacon
    function deposit(uint64 _poolId, string memory _exchangeName) external payable  {
        slotsLib.sSlots memory _slot = slotsLib.getDepositSlot(_poolId, _exchangeName,slots, beaconContract);
        uint deposit_amount = msg.value;
        uint pendingReward_val =  pendingReward(_slot);
        if (pendingReward_val > 0) {
            deposit_amount = deposit_amount + do_harvest(_slot, 0);
        }
        addFunds(_slot, deposit_amount,true);
        emit sdDeposit(deposit_amount);
    }

    ///@notice Swap funds from one pool/exchnage to another pool/exchange
    ///@param _fromPoolId id of pool to swap from
    ///@param _fromExchangeName name of exchange to lookup in slots
    ///@param _toPoolId id of pool to swap to
    ///@param _toExchangeName name of exchange to lookup in slots
    function swapPool(uint64 _fromPoolId, string memory _fromExchangeName, uint64 _toPoolId, string memory _toExchangeName) public allowAdmin {
        if(_fromPoolId == _toPoolId && keccak256(bytes(_fromExchangeName)) == keccak256(bytes(_toExchangeName))) revert sdRequiredParameter("New pool required");
        (uint _bal, slotsLib.sSlots memory _slot) = doSwap(_fromPoolId, _fromExchangeName);
        
        _slot = slotsLib.swapSlot(_fromPoolId, _fromExchangeName,_toPoolId, _toExchangeName,slots, beaconContract);
        addFunds(_slot,_bal,false);
        emit sdNewPool(_fromPoolId,_fromExchangeName, _toPoolId,_toExchangeName, _bal);
    }

    ///@notice Swap funds from one pool/exchnage to another pool/exchange in a different contract
    ///@param _toContract the address of the contract to swap to
    ///@param _fromPoolId id of pool to swap from
    ///@param _fromExchangeName name of exchange to lookup in slots
    ///@param _toPoolId id of pool to swap to
    ///@param _toExchangeName name of exchange to lookup in slots
    function swapContractPool(uint64 _fromPoolId, string memory _fromExchangeName, address _toContract, uint64 _toPoolId, string memory _toExchangeName) external allowAdmin {
        //liquidate current user and do not send funds
        if(_fromPoolId == _toPoolId && keccak256(bytes(_fromExchangeName)) == keccak256(bytes(_toExchangeName))) revert sdRequiredParameter("New pool required");

        (uint _bal, ) = doSwap(_fromPoolId, _fromExchangeName);

        iSimpleDefiSolo(payable(_toContract)).deposit{value: _bal}(_toPoolId,_toExchangeName);
    }

    ///@notice Performs common swap function
    ///@param _fromPoolId id of pool to swap from
    ///@param _fromExchangeName name of exchange to lookup in slots
    ///@return _bal the amount of funds to send to the new pool
    ///@return _slot the new slot

    function doSwap(uint64 _fromPoolId, string memory _fromExchangeName) private returns (uint, slotsLib.sSlots memory) {
        slotsLib.sSlots memory _slot = getSlot(_fromPoolId, _fromExchangeName);
                
        removeLiquidity(_slot);
        revertBalance(_slot);
        
        uint _bal = address(this).balance;
        if (_bal==0) revert sdInsufficentBalance();
        return (_bal, _slot);
    }


    ///@notice get pending rewards on a specific pool/exchange
    ///@param _poolId id of pool to get pending rewards on
    ///@param _exchangeName name of exchange to lookup in slots
    ///@return pending rewards 
    function pendingReward(uint64 _poolId, string memory _exchangeName) public view returns (uint) {        
        slotsLib.sSlots memory _slot = getSlot(_poolId, _exchangeName);
        if (_slot.poolId == slotsLib.MAX_SLOTS + 1) return 0;
        return pendingReward(_slot);
    }

    ///@notice get pending rewards on a specific slot id
    ///@param _slot slot to get pending rewards on
    ///@return pending rewards 
    function pendingReward(slotsLib.sSlots memory _slot) private view returns (uint) {
        (, bytes memory data) = _slot.chefContract.staticcall(abi.encodeWithSignature(_slot.pendingCall, _slot.poolId,address(this)));
        uint pendingReward_val = data.length==0?0:abi.decode(data,(uint256));
        if (pendingReward_val == 0) {
            pendingReward_val += ERC20(_slot.rewardToken).balanceOf(address(this));
        }
        return pendingReward_val;
    }

    ///@notice liquidate funds on a specific pool/exchange
    ///@param _poolId id of pool to liquidate
    ///@param _exchangeName name of exchange to lookup in slots    
    function liquidate(uint64 _poolId, string memory _exchangeName) public onlyOwner lockFunction {
        slotsLib.sSlots memory _slot = getSlot(_poolId, _exchangeName);
        do_harvest(_slot, 0);
        removeLiquidity(_slot);
        revertBalance(_slot);        
        uint _total = address(this).balance;
        slotsLib.removeSlot(_slot.poolId, _slot.exchangeName,slots);

        _total = sendFee("SOLOLIQUIDATE",_total,0);

        payable(owner()).transfer(_total);
        emit sdLiquidated(_total);
    }
    
    ///@notice set holdback on rewards to be sent back to user
    ///@param _holdback amount of rewards to hold back
    function setHoldBack(uint64 _holdback) external onlyOwner {
        holdBack = _holdback;
        emit sdSetHoldback(_holdback);
    }
    
    ///@notice send holdback funds to user (BNB Balance)
    function sendHoldBack() external onlyOwner lockFunction{
        uint bal = address(this).balance;
        if (bal == 0) revert sdInsufficentBalance();
        payable(owner()).transfer(bal);
        emit sdHoldBack(bal,bal);
    }
    
    ///@notice Manually perform a harvest on a specific pool/exchange
    ///@param _poolId id of pool to harvest on
    ///@param _exchangeName name of exchange to lookup in slots
    function harvest(uint64  _poolId, string memory _exchangeName) public lockFunction allowAdmin {
        slotsLib.sSlots memory _slot = getSlot(_poolId, _exchangeName);
        uint64 _offset = iBeacon(beaconContract).getConst('DEFAULT','HARVESTSOLOGAS');
        uint startGas = gasleft() + 21000 + _offset;
        uint split = do_harvest(_slot, 1);
        
        addFunds(_slot, split,false);
        if (msg.sender != owner()) {
            lastGas = startGas - gasleft();
        }
    }
    
    ///@notice helper function to return balance of 2 tokens in a pool
    ///@param _slot slot to get balance of
    ///@return _bal0 of tokens of token0 from pool
    ///@return _bal1 of tokens of token1 from pool
    function tokenBalance(slotsLib.sSlots memory _slot) private view returns (uint _bal0,uint _bal1) {
        _bal0 = ERC20(_slot.token0).balanceOf(address(this));
        _bal1 = ERC20(_slot.token1).balanceOf(address(this));
    }    
    
    ///@notice helper function to return balance of specified token from contract to the user
    ///@param token address of token to recover
    function rescueToken(address token) external onlyOwner{
        uint _bal = ERC20(token).balanceOf(address(this));
        ERC20(token).transfer(owner(),_bal);
        emit sdRescueToken(token,_bal);
    }

    ///@notice Internal funciton to add funds to a specified slot
    ///@param _slot slot to add funds to
    ///@param inValue amount of funds to add
    function addFunds(slotsLib.sSlots memory _slot, uint inValue, bool _depositFee) private  {
        if (inValue==0) revert sdInsufficentBalance();
        if (_depositFee) {
            inValue = sendFee("DEPOSIT",inValue,0);
        }

        uint amount0;
        uint amount1;
        uint split;

        if (_slot.token0 == WBNB_ADDR || _slot.token1 == WBNB_ADDR) {
            split = (inValue*50)/100;        
            amount0 = (_slot.token0 != WBNB_ADDR) ? swap(_slot,split,WBNB_ADDR,_slot.token0) : split;    
            amount1 = (_slot.token1 != WBNB_ADDR) ? swap(_slot,split,WBNB_ADDR, _slot.token1) : split;
        }
        else {
            amount0 = swap(_slot, inValue,WBNB_ADDR,_slot.token0);    
            split = (amount0*50)/100;  
            split = split - ((split*SwapFee)/1e10); 
            amount1 = swap(_slot, split,_slot.token0,_slot.token1);
        }

        addLiquidity(_slot,amount0,amount1);
    }

    ///@notice Internal function to add liquidity to a pool
    ///@dev amount0 and amount1 should be the same value (converted to/from BNB)
    ///@param _slot slot to add liquidity to
    ///@param amount0 amount of liquidity to add of token0
    ///@param amount1 amount of liquidity to add of token1
    function addLiquidity(slotsLib.sSlots memory _slot, uint amount0, uint amount1) private {
        uint amountA;
        uint amountB;
        uint liquidity;
                

        if (_slot.token1 == WBNB_ADDR || _slot.token0 == WBNB_ADDR) {
            (amount0,amount1) = _slot.token0 == WBNB_ADDR?(amount0,amount1):(amount1,amount0);
            address token = _slot.token0 == WBNB_ADDR?_slot.token1:_slot.token0;
            (amountA, amountB, liquidity) = iRouter(_slot.routerContract).addLiquidityETH{value: amount0}(token, amount1, 0,0, address(this), block.timestamp);
        }
        else {
            ( amountA,  amountB, liquidity) = iRouter(_slot.routerContract).addLiquidity(_slot.token0, _slot.token1, amount0, amount1, 0, 0, address(this), block.timestamp);
        }

        iMasterChef(_slot.chefContract).deposit(_slot.poolId,liquidity);
        emit sdLiquidityProvided(amountA, amountB, liquidity);
    }
    
    ///@notice Internal function to swap 2 tokens
    ///@param _slot slot to swap tokens on
    ///@param amountIn amount of tokens to swap
    ///@param _token0 address of tokens to swap
    ///@param _token1 address of tokens to swap
    ///@return amountOut amount of tokens swapped
    function swap(slotsLib.sSlots memory _slot, uint amountIn, address _token0, address _token1) private returns (uint){
        if (amountIn == 0) revert sdInsufficentBalance();

        uint pathLength = (_slot.intermediateToken != address(0) && _token0 != _slot.intermediateToken && _token1 != _slot.intermediateToken) ? 3 : 2;
        address[] memory swapPath = new address[](pathLength);
        
        swapPath[0] = _token0;
        swapPath[pathLength-1] = _token1;
        if (pathLength == 3) {
            swapPath[1] = _slot.intermediateToken;
        }

        uint _cBalance = address(this).balance;
        if (swapPath[0] == WBNB_ADDR && swapPath[pathLength-1] == WBNB_ADDR) {
            if (ERC20(WBNB_ADDR).balanceOf(address(this)) >= amountIn) {
                iWBNB(WBNB_ADDR).withdraw(amountIn);
                _cBalance = address(this).balance;
            }
            if (amountIn > address(this).balance) revert sdInsufficentFunds();
            return amountIn;
        }

        uint[] memory amounts;

        uint deadline = block.timestamp + 600;

        if (swapPath[0] == WBNB_ADDR && ERC20(WBNB_ADDR).balanceOf(address(this)) >= amountIn) {
            iWBNB(WBNB_ADDR).withdraw(amountIn);
            _cBalance = address(this).balance;
        }

        if (swapPath[pathLength - 1] == WBNB_ADDR) {
            amounts = iRouter(_slot.routerContract).swapExactTokensForETH(amountIn, 0,  swapPath, address(this), deadline);
        } else if (swapPath[0] == WBNB_ADDR && _cBalance >= amountIn) {
            amounts = iRouter(_slot.routerContract).swapExactETHForTokens{value: amountIn}(0,swapPath,address(this),deadline);
        }
        else {
            amounts = iRouter(_slot.routerContract).swapExactTokensForTokens(amountIn, 0,swapPath,address(this),deadline);
        }
        return amounts[pathLength-1];
    }
    

    ///@notice Internal function to harvest spool
    ///@param _slot slot to harvest
    ///@param revert_trans (0 - return 0 on failure, 1 - revert on failure)
    ///@return finalReward  Final amount of reward returned.
    function do_harvest(slotsLib.sSlots memory _slot,uint revert_trans) private returns (uint) {
        uint pendingCake = 0;
        pendingCake = pendingReward(_slot);
        if (pendingCake == 0) {
            if (revert_trans == 1) {
                revert sdInsufficentBalance();
            }
            else {
                    return 0;
            }
        }
        
        iMasterChef(_slot.chefContract).deposit(_slot.poolId,0);
        pendingCake = ERC20(_slot.rewardToken).balanceOf(address(this));

        pendingCake = swap(_slot, pendingCake,_slot.rewardToken, WBNB_ADDR);
        
        uint finalReward = sendFee('HARVEST',pendingCake, ((lastGas * tx.gasprice))); // lastGas is here in case 3rd party harvester is used, should normally be 0
        
        if (holdBack > 0) {
            uint holdbackAmount = (finalReward * holdBack)/1e20;
            finalReward = finalReward - holdbackAmount;
            payable(owner()).transfer(holdbackAmount);
            emit sdHoldBack(holdbackAmount,finalReward);

        }
        return finalReward;
    }
    
    ///@notice Internal function to remove liquididty from pool
    ///@param _slot slot to remove liquidity from
    function removeLiquidity(slotsLib.sSlots memory _slot) private {
        uint amountTokenA;
        uint amountTokenB;
        uint deadline = block.timestamp + 600;

        (uint _lpBal,) = iMasterChef(_slot.chefContract).userInfo(_slot.poolId,address(this));
        iMasterChef(_slot.chefContract).withdraw(_slot.poolId,_lpBal);
        
        uint _removed = ERC20(_slot.lpContract).balanceOf(address(this));
        emit sdRemoved(_removed);
        
        (address token0,address token1) = _slot.token0==WBNB_ADDR?(_slot.token1,_slot.token0):(_slot.token0,_slot.token1);

        if (token1 == WBNB_ADDR)
            (amountTokenA, amountTokenB) = iRouter(_slot.routerContract).removeLiquidityETH(token0,_removed,0,0,address(this), deadline);
        else
            (amountTokenA, amountTokenB) = iRouter(_slot.routerContract).removeLiquidity(token0,token1,_removed,0,0,address(this), deadline);
    }

    ///@notice Internal function to convert token0/token1 to BNB/Base Token
    ///@param _slot slot to convert
    function revertBalance(slotsLib.sSlots memory _slot) private {
        uint amount0 = 0;

        uint _rewards = ERC20(_slot.rewardToken).balanceOf(address (this));
        if (_rewards > 0 ){
            amount0 = swap(_slot, _rewards, _slot.rewardToken, WBNB_ADDR);
        }

        (uint _bal0, uint _bal1) = tokenBalance(_slot);
        
        if (_bal0 > 0) {
            amount0 += swap(_slot, _bal0, _slot.token0, WBNB_ADDR);
        }
        
        if (_bal1 > 0) {
            amount0 += swap(_slot, _bal1, _slot.token1, WBNB_ADDR);
        }
    }
    
    ///@notice returns status of pool on specific pool/exchange
    ///@param _poolId pool to get info from
    ///@param _exchangeName name of exchange to lookup in slots
    ///@return masterchef balance 0
    ///@return masterchef balance 1
    ///@return token0 balance
    ///@return token1 balance
    ///@return contract balance of rewward token
    ///@return total of BNB
    function userInfo(uint64  _poolId, string memory _exchangeName) public view allowAdmin returns (uint,uint,uint,uint,uint,uint) {
        slotsLib.sSlots memory _slot = getSlot(_poolId, _exchangeName);
        // bitflip = !bitflip;
        if (_slot.lpContract == address(0))  return (0,0,0,0,0,0);
        
        (uint a, uint b) = iMasterChef(_slot.chefContract).userInfo(_slot.poolId,address(this));
        (uint c, uint d) = tokenBalance(_slot);
        uint e = ERC20(_slot.rewardToken).balanceOf(address(this));
        uint f = address(this).balance;
        return (a,b,c,d,e,f);
    }

    ///@notice Internal function to handle fees for specific type
    ///@param _type type of fee
    ///@param _total amount of fee
    ///@param  _extra fee to add (such as gas fee)
    ///@return _total amount of fee sent
    function sendFee(string memory _type, uint _total, uint _extra) private returns (uint){
        (uint feeAmt,) = iBeacon(beaconContract).getFee('DEFAULT',_type,owner());
        uint feeAmount = ((_total * feeAmt)/100e18) + _extra;
        if (feeAmount > _total) feeAmount = _total; // required to recover fee
        uint _bal = address(this).balance;

        if(feeAmount > 0 && _bal > feeAmount) {
            if (feeAmount > _total) {
                feeAmount = _total;
                _total = 0;
            }
            else {
                _total = _total - feeAmount;
            }
            payable(address(feeCollector)).transfer(feeAmount);
            bytes memory _t = bytes(_type);
            emit sdFeeSent(owner(), bytes16(_t), feeAmount,_total);
        }
        return _total;
    }

    ///@notice Public function to get slot for pool/exchange
    ///@param _poolId pool to get info from
    ///@param _exchangeName name of exchange to lookup in slots
    ///@return slot info
    function getSlot(uint64 _poolId, string memory _exchangeName) public view returns (slotsLib.sSlots memory) {
        return slotsLib.getSlot(_poolId, _exchangeName, slots, beaconContract);
    }
}

//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
import "../Interfaces.sol";

library slotsLib {
    struct slotStorage {
        uint poolId;
        string exchangeName;
        address lpContract;
        address token0;
        address token1;
    }

    struct sSlots {
        uint64 poolId;
        string exchangeName;
        address lpContract;
        address token0;
        address token1;
        address chefContract;
        address routerContract;
        address rewardToken;
        string pendingCall;
        address intermediateToken;
        
    }

    uint64 constant MAX_SLOTS = 100;

    error RequiredParameter(string param);
    error InactivePool(uint _poolID);
    error MaxSlots();
    error SlotOutOfBounds();
    event SlotsUpdated();
    event SlotsNew(uint _pid, string _exchange);


    ///@notice Add a new exchange/pool to slot pool
    ///@param _poolId The pool ID
    ///@param _exchangeName Exchange name
    ///@param slots current pool of slots
    ///@param beaconContract Address of the beacon contract
    ///@return new position in slot pool    
    function addSlot(uint64 _poolId, string memory _exchangeName, slotStorage[] storage slots,address beaconContract) internal returns (uint64) {
        uint64 _slotId = find_slot(_poolId, _exchangeName, slots);
        if (_slotId != MAX_SLOTS+1) return _slotId;

        if (slots.length+1 >= MAX_SLOTS) revert MaxSlots();
        updateSlot(MAX_SLOTS+1,_poolId,_exchangeName,slots,beaconContract);
        emit SlotsNew(_poolId,_exchangeName);
        return uint64(slots.length - 1);
    }

    ///@notice switch slots between two pools
    ///@param _fromPoolId The from pool ID
    ///@param _fromExchangeName The from exchange name
    ///@param _toPoolId The to pool ID
    ///@param _toExchangeName The to exchange name
    ///@param slots current pool of slots
    ///@param beaconContract Address of the beacon contract
    ///@return Current slots Pool
    function swapSlot(uint _fromPoolId, string memory _fromExchangeName, uint _toPoolId, string memory _toExchangeName, slotStorage[] storage slots, address beaconContract) internal returns (sSlots memory) {
        uint64 _fromSlotId = find_slot(_fromPoolId, _fromExchangeName, slots);
        if (_fromSlotId == MAX_SLOTS) revert InactivePool(_fromPoolId);
        return updateSlot(_fromSlotId, _toPoolId, _toExchangeName, slots, beaconContract);
    }


    ///@notice update slotid with new pool and exchange
    ///@param _slotId The slot ID
    ///@param _poolId The pool ID
    ///@param _exchangeName The exchange name
    ///@param slots current pool of slots
    ///@param beaconContract Address of the beacon contract
    ///@return Current slots Pool
    function updateSlot(uint64 _slotId, uint _poolId, string memory _exchangeName, slotStorage[] storage slots, address beaconContract) internal returns (sSlots memory) {
        
        if (_slotId != MAX_SLOTS+1 && keccak256(bytes(slots[_slotId].exchangeName)) != keccak256(bytes(_exchangeName))) {
            bool _found;
            for(uint i = 0; i < slots.length; i++) {
                if (keccak256(bytes(slots[i].exchangeName)) == keccak256(bytes(_exchangeName)) && i != _poolId) {
                    _found = true;
                    break;
                }
            }
            if (!_found) {
                iBeacon.sExchangeInfo memory old_exchangeInfo = iBeacon(beaconContract).getExchangeInfo(_exchangeName);
                address _oldLpContract;
                if (old_exchangeInfo.psV2){
                    _oldLpContract = iMasterChefv2(old_exchangeInfo.chefContract).lpToken(_poolId);
                }
                else {
                    (_oldLpContract,,,) = iMasterChef(old_exchangeInfo.chefContract).poolInfo(_poolId);
                }
                ERC20(old_exchangeInfo.rewardToken).approve(old_exchangeInfo.routerContract,0);

                ERC20(slots[_slotId].token0).approve(old_exchangeInfo.routerContract,0);
                ERC20(slots[_slotId].token1).approve(old_exchangeInfo.routerContract,0);
                iLPToken(_oldLpContract).approve(old_exchangeInfo.chefContract,0);        
                iLPToken(_oldLpContract).approve(old_exchangeInfo.routerContract,0);                            
            }
        }

        iBeacon.sExchangeInfo memory exchangeInfo = iBeacon(beaconContract).getExchangeInfo(_exchangeName);
        address _lpContract;
        uint _alloc;

        if (exchangeInfo.psV2) {
            _lpContract = iMasterChefv2(exchangeInfo.chefContract).lpToken(_poolId);
            (,,_alloc,,) = iMasterChefv2(exchangeInfo.chefContract).poolInfo(_poolId);
        }
        else {
            (_lpContract, _alloc,,) = iMasterChef(exchangeInfo.chefContract).poolInfo(_poolId);
        }

        if (_lpContract == address(0)) revert RequiredParameter("_lpContract");
        if (_alloc == 0) revert InactivePool(_poolId);

        if (_slotId == MAX_SLOTS+1) {
            slots.push(slotStorage(_poolId,_exchangeName,_lpContract, iLPToken(_lpContract).token0(),iLPToken(_lpContract).token1()));
            _slotId = uint64(slots.length - 1);
        } else {
            if (_slotId >= slots.length) revert SlotOutOfBounds();
            slots[_slotId] = slotStorage(_poolId,_exchangeName,_lpContract, iLPToken(_lpContract).token0(),iLPToken(_lpContract).token1());
        }     

        
        if (ERC20(exchangeInfo.rewardToken).allowance(address(this), exchangeInfo.routerContract) == 0) {
            ERC20(exchangeInfo.rewardToken).approve(exchangeInfo.routerContract,MAX_INT);
        }

        ERC20(slots[_slotId].token0).approve(exchangeInfo.routerContract,MAX_INT);
        ERC20(slots[_slotId].token1).approve(exchangeInfo.routerContract,MAX_INT);
        iLPToken(_lpContract).approve(exchangeInfo.chefContract,MAX_INT);        
        iLPToken(_lpContract).approve(exchangeInfo.routerContract,MAX_INT);                            

        emit SlotsUpdated();
        return sSlots(uint64(slots[_slotId].poolId),slots[_slotId].exchangeName,slots[_slotId].lpContract, slots[_slotId].token0,slots[_slotId].token1,exchangeInfo.chefContract,exchangeInfo.routerContract,exchangeInfo.rewardToken,exchangeInfo.pendingCall,exchangeInfo.intermediateToken);
    }

    ///@notice Remove slot from pool
    ///@param _poolId The pool ID
    ///@param _exchangeName The exchange name
    ///@param slots current pool of slots
    ///@return New length of the slots pool
    function removeSlot(uint _poolId, string memory _exchangeName, slotStorage[] storage slots) internal returns (uint) {
        uint _slotId = find_slot(_poolId,_exchangeName,slots);
        if (_slotId >= slots.length) revert SlotOutOfBounds();
        if (slots.length>1) {
            slots[_slotId] = slots[slots.length-1];
        }
        
        slots.pop();

        emit SlotsUpdated();
        return slots.length;
    }

    ///@notice locate slotid using name and exchange
    ///@param _poolId The pool ID
    ///@param _exchangeName The exchange name
    ///@param slots current pool of slots
    ///@return slotid from slot pool
    function find_slot(uint _poolId, string memory _exchangeName, slotStorage[] storage slots) private view returns (uint64){
        for(uint64 i = 0;i<slots.length;i++) {
            if (slots[i].poolId == _poolId && keccak256(bytes(slots[i].exchangeName)) == keccak256(bytes(_exchangeName))) { //this is to get around storage type differences...
                return i;
            }
        }
        return MAX_SLOTS+1;
    }

    ///@notice return slot information baesd on poolid and exchange
    ///@param _poolId The pool ID
    ///@param _exchangeName The exchange name
    ///@param slots current pool of slots
    ///@return slot sturcture
    function getSlot(uint _poolId, string memory _exchangeName, slotStorage[] storage slots, address beaconContract) internal view returns (sSlots memory) {
        uint64 _slotId = find_slot(_poolId,_exchangeName,slots);
        if (_slotId == MAX_SLOTS+1) return (sSlots(_slotId,"",address(0),address(0),address(0),address(0),address(0),address(0),"",address(0)));
        iBeacon.sExchangeInfo memory exchangeInfo = iBeacon(beaconContract).getExchangeInfo(slots[_slotId].exchangeName);

        return sSlots(uint64(slots[_slotId].poolId),slots[_slotId].exchangeName,slots[_slotId].lpContract, slots[_slotId].token0,slots[_slotId].token1,exchangeInfo.chefContract,exchangeInfo.routerContract,exchangeInfo.rewardToken,exchangeInfo.pendingCall,exchangeInfo.intermediateToken);
    }    

    ///@notice when depositing, check if new slot needs to be created before updating
    ///@param _poolId The pool ID
    ///@param _exchangeName The exchange name
    ///@param slots current pool of slots
    ///@param beaconContract Address of the beacon contract
    ///@return slot structure
    function getDepositSlot(uint64 _poolId, string memory _exchangeName, slotStorage[] storage slots, address beaconContract) internal returns (sSlots memory) {
        uint64 _slotId = find_slot(_poolId,_exchangeName,slots);
        if (_slotId == MAX_SLOTS+1) {
            emit SlotsNew(_poolId, _exchangeName);
            return updateSlot(uint64(slotsLib.MAX_SLOTS+1), _poolId, _exchangeName, slots, beaconContract);
        }
        else {
            iBeacon.sExchangeInfo memory exchangeInfo = iBeacon(beaconContract).getExchangeInfo(_exchangeName);
            return sSlots(uint64(slots[_slotId].poolId),slots[_slotId].exchangeName,slots[_slotId].lpContract, slots[_slotId].token0,slots[_slotId].token1,exchangeInfo .chefContract,exchangeInfo.routerContract,exchangeInfo.rewardToken,exchangeInfo.pendingCall,exchangeInfo.intermediateToken);
        }
    }    
}