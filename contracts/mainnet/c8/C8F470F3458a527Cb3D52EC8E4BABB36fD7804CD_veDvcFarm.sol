// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (metatx/ERC2771Context.sol)

pragma solidity ^0.8.9;

import "../utils/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private  _trustedForwarder;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _setTrustedForwarder(address forwarder) internal virtual {
        _trustedForwarder = forwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, values);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
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
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";
import "./IActivityStruct.sol";

interface IDVCC1155 {
  function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
}

interface IVeDvcFarm is ActivityStruct {
  function getStakeOrder(uint actId, address owner) external view returns (StakeOrder memory);

  function payBoxFee(uint actId, uint amount, address owner) external;
}

/// @title BoxApply - Dubai Verse Horse Mystery Box
/// @notice - DVCC Technology
/// @dev - Module will be updated to more decentralized structure adding more functionalities after some product iterations
contract BoxApply is ActivityStruct, Pausable, AccessControl, ERC2771Context {
  using Counters for Counters.Counter;

  struct BoxOrder {
    uint256 actId;
    uint64[] id;
    uint64 boxType;
    uint64 boxApplied;
    uint64 boxReceived;
    uint256 dvccReturned;
    bool completed;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  /// @dev external smart contracts
  address _dvcToken;
  IDVCC1155 _dvc1155;
  IVeDvcFarm _vedvcFarm;

  Counters.Counter private _actIdCounter;
  mapping(uint256 => Activity) private activityById;
  mapping(address => mapping(uint256 => BoxOrder)) private userBoxOrder;
  mapping(address => mapping(uint256 => uint256)) private userDvcBalance;
  uint32 private constant RD = 0x2710;

  /// @custom:log events
  event NewActivity(uint256 actId, uint64 boxType, uint64 boxNum, uint256 price, uint256 startTime, uint256 endTime);
  event ExtendActivity(uint256 actId, uint256 endTime);
  event OrderBox(address indexed owner, uint64 boxType, uint64 boxNum, uint256 applyTime);
  event ReceiveBox(address indexed owner, uint256 actId, uint64 boxType, uint64 boxNum, uint256 receiveTime);
  event BalanceReturn(address indexed owner, uint256 actId, uint256 amount, uint256 receiveTime);

  /// @custom:log errors
  /// Round `actId` is invalid, either not opened yet or closed.
  error InvalidApplyRound(uint256 actId);
  /// Box apply amount `invalid` is invalid, maximum `valid` boxs can apply.
  error InvalidApplyAmount(uint256 valid, uint256 invalid);
  /// Activity with actId `actId` is not closed, time now `now`, close time `matureTime`.
  error RoundNotClosed(uint256 actId, uint256 now, uint256 closeTime);
  /// You don't have any box applied on activity with actId `actId`.
  error EmptyBoxOrder(uint256 actId);
  /// Box order `actId` already claimed.
  error RepeteClaimBox(uint256 actId);
  /// You don't have any unused DVCC on activity with actId `actId`.
  error NoBalanceToClaim(uint256 actId);

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint256 totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(DVCCForwarder forwarder) ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
    _grantRole(PAUSER_ROLE, _msgSender());
  }

  /// @custom:gameplay - apply box
  function applyForBox(uint256 actId, uint64 boxNum) external whenNotPaused convertGasfee("applyForBox") {
    Activity storage _activity = activityById[actId];
    StakeOrder memory _stakeOrder = _vedvcFarm.getStakeOrder(actId, _msgSender());
    if (_activity.endTime < block.timestamp) {
      revert InvalidApplyRound(actId);
    }
    BoxOrder storage _boxOrder = userBoxOrder[_msgSender()][actId];
    uint64 alreadyApplied = _boxOrder.boxApplied;
    uint256 multiplier = _activity.price * _activity.stakeRatio;
    uint256 boxRemained = ((_stakeOrder.amount + alreadyApplied * _activity.price) / multiplier) - alreadyApplied;
    if (boxNum <= 0 || boxNum > boxRemained) {
      revert InvalidApplyAmount(boxRemained, boxNum);
    }

    _boxOrder.actId = actId;
    for (uint64 i = 1; i <= boxNum; i++) {
      _boxOrder.id.push(_activity.boxApplied + i);
    }
    _boxOrder.boxType = _activity.boxType;
    _boxOrder.boxApplied += boxNum;
    _activity.boxApplied += boxNum;

    uint256 expense = boxNum * _activity.price;
    userDvcBalance[_msgSender()][actId] += expense;
    _vedvcFarm.payBoxFee(actId, expense, _msgSender());

    emit OrderBox(_msgSender(), _activity.boxType, boxNum, block.timestamp);
  }

  /// @custom:gameplay - claim box
  function claimBox(uint256 actId) external whenNotPaused convertGasfee("claimBox") {
    Activity memory _activity = activityById[actId];
    BoxOrder memory _boxOrder = userBoxOrder[_msgSender()][actId];

    if (block.timestamp < _activity.endTime) {
      revert RoundNotClosed(actId, block.timestamp, _activity.endTime);
    }
    if (_boxOrder.boxApplied <= 0) {
      revert EmptyBoxOrder(actId);
    }
    if (_boxOrder.completed) {
      revert RepeteClaimBox(actId);
    }

    // uint64 idStart = _boxOrder.id;
    uint64 _totalDemand = _activity.boxApplied;
    uint64 _supply = _activity.boxNum;
    uint64 winNumber = (_supply * RD) / _totalDemand;
    uint256 seed = uint256(keccak256(abi.encodePacked(_totalDemand, _supply, actId)));

    for (uint64 j = 0; j < _boxOrder.id.length; j++) {
      uint256 resNumber = uint256(keccak256(abi.encode(_boxOrder.id[j], seed))) % RD;
      if (resNumber < winNumber) {
        _boxOrder.boxReceived++;
        userDvcBalance[_msgSender()][actId] -= _activity.price;
      }
    }

    _boxOrder.completed = true;
    userBoxOrder[_msgSender()][actId] = _boxOrder;
    if (_boxOrder.boxReceived > 0) {
      _dvc1155.mint(_msgSender(), _activity.boxType, _boxOrder.boxReceived, "0x");
    }

    emit ReceiveBox(_msgSender(), actId, _activity.boxType, _boxOrder.boxReceived, block.timestamp);
  }

  /// @custom:gameplay - claim unused balance
  function claimBalance(uint256 actId) external whenNotPaused convertGasfee("claimBalance") {
    uint256 _balance = userDvcBalance[_msgSender()][actId];
    if (_balance <= 0) {
      revert NoBalanceToClaim(actId);
    }
    BoxOrder storage _boxOrder = userBoxOrder[_msgSender()][actId];
    if (!_boxOrder.completed) {
      revert NoBalanceToClaim(actId);
    }
    userDvcBalance[_msgSender()][actId] = 0;
    _boxOrder.dvccReturned = _balance;
    TransferHelper.safeTransfer(address(_dvcToken), _msgSender(), _balance);
    emit BalanceReturn(_msgSender(), actId, _balance, block.timestamp);
  }

  function getActiveRounds() external view returns (uint64[] memory) {
    uint256 totalActs = _actIdCounter.current();
    uint64[] memory activeRounds = new uint64[](totalActs);
    uint64 valid = 0;
    for (uint32 i = 1; i < totalActs + 1; i++) {
      Activity memory _activity = activityById[i];
      if (_activity.endTime > block.timestamp) {
        activeRounds[i - 1] = i;
        valid++;
      }
    }

    uint64[] memory _formatted = new uint64[](valid);
    uint64 count = 0;
    for (uint64 j = 0; j < activeRounds.length; j++) {
      if (activeRounds[j] != 0) {
        _formatted[count] = activeRounds[j];
        count++;
      }
    }

    return _formatted;
  }

  function getUserClaimableBoxRounds() external view returns (uint64[] memory) {
    uint256 totalActs = _actIdCounter.current();
    uint64[] memory claimableRounds = new uint64[](totalActs);
    uint64 valid = 0;
    for (uint64 i = 1; i < totalActs + 1; i++) {
      BoxOrder memory _boxOrder = userBoxOrder[_msgSender()][i];
      Activity memory _activity = activityById[i];
      if (_boxOrder.boxApplied > 0 && !_boxOrder.completed && block.timestamp > _activity.endTime) {
        claimableRounds[i - 1] = i;
        valid++;
      }
    }

    uint64[] memory _formatted = new uint64[](valid);
    uint64 count = 0;
    for (uint64 j = 0; j < claimableRounds.length; j++) {
      if (claimableRounds[j] != 0) {
        _formatted[count] = claimableRounds[j];
        count++;
      }
    }

    return _formatted;
  }

  function getUserClaimableBalanceRounds() external view returns (uint64[] memory) {
    uint256 totalActs = _actIdCounter.current();
    uint64[] memory claimableRounds = new uint64[](totalActs);
    uint64 valid = 0;
    for (uint64 i = 1; i < totalActs + 1; i++) {
      BoxOrder memory _boxOrder = userBoxOrder[_msgSender()][i];
      if (_boxOrder.boxApplied > _boxOrder.boxReceived && _boxOrder.completed && _boxOrder.dvccReturned == 0) {
        claimableRounds[i - 1] = i;
        valid++;
      }
    }

    uint64[] memory _formatted = new uint64[](valid);
    uint64 count = 0;
    for (uint64 j = 0; j < claimableRounds.length; j++) {
      if (claimableRounds[j] != 0) {
        _formatted[count] = claimableRounds[j];
        count++;
      }
    }

    return _formatted;
  }

  function roundIsValid(uint256 actId) public view returns (bool) {
    Activity memory _activity = activityById[actId];
    if (_activity.endTime > block.timestamp) {
      return true;
    }
    return false;
  }

  function getBoxApplyNumber(uint256 actId) public view returns (uint256) {
    Activity memory _activity = activityById[actId];
    StakeOrder memory _stakeOrder = _vedvcFarm.getStakeOrder(actId, _msgSender());
    BoxOrder memory _boxOrder = userBoxOrder[_msgSender()][actId];
    uint64 alreadyApplied = _boxOrder.boxApplied;
    uint256 multiplier = _activity.price * _activity.stakeRatio;
    uint256 boxRemained = (_stakeOrder.amount + alreadyApplied * _activity.price) / multiplier - alreadyApplied;
    return boxRemained;
  }

  function getActivityById(uint256 actId) external view returns (Activity memory) {
    return activityById[actId];
  }

  function getUserBoxOrder(uint256 actId) external view returns (BoxOrder memory) {
    BoxOrder memory _boxOrder = userBoxOrder[_msgSender()][actId];
    if (_boxOrder.boxApplied == 0) {
      revert EmptyBoxOrder(actId);
    }
    return _boxOrder;
  }

  function getUserDvcBalance(uint256 actId) external view returns (uint256) {
    return userDvcBalance[_msgSender()][actId];
  }

  function getCurrentActivityId() external view returns (uint) {
    return _actIdCounter.current();
  }

  /// @custom:note - GM functions
  function initializeServices(address vedvcFarm, address dvcToken, address dvc1155) external onlyRole(MANAGER_ROLE) {
    _vedvcFarm = IVeDvcFarm(vedvcFarm);
    _dvcToken = dvcToken;
    _dvc1155 = IDVCC1155(dvc1155);
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function newApplyRound(
    uint64 duration,
    uint64 boxType,
    uint64 boxNum,
    uint64 stakeRatio,
    uint256 price
  ) external onlyRole(MANAGER_ROLE) {
    _actIdCounter.increment();
    uint256 actId = _actIdCounter.current();
    uint256 startTime = block.timestamp;
    uint256 endTime = startTime + duration;
    Activity memory _newActivity = Activity(actId, boxType, boxNum, 0, stakeRatio, price, startTime, endTime);

    activityById[actId] = _newActivity;
    emit NewActivity(actId, boxType, boxNum, price, startTime, endTime);
  }

  function extendRoundDuration(uint256 actId, uint64 duration) external onlyRole(MANAGER_ROLE) {
    Activity storage _activity = activityById[actId];
    uint256 _oldEndTime = _activity.endTime;
    // unexisted activity or past activity can't be extended
    if (_oldEndTime == 0 || _oldEndTime < block.timestamp) {
      revert InvalidApplyRound(actId);
    }
    uint256 _newEndTime = _oldEndTime + duration;
    _activity.endTime = _newEndTime;
    emit ExtendActivity(actId, _newEndTime);
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";

interface IHorseGamePlay {
  function SSR_Build(address to, uint64 boxType) external;
}

/// @title DVCC1155 - Dubai Verse Mystery Box Asset
/// @notice - DVCC Technology
contract DVCC1155 is ERC1155, Pausable, AccessControl, ERC1155Burnable, ERC2771Context {
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  /// @dev external contracts
  address _dvcToken;
  IHorseGamePlay _horseGamePlay;

  mapping(address => mapping(uint64 => uint64)) private userBoxOpened;
  mapping(address => uint256) private userTotalBoxOpened;
  mapping(uint64 => uint256) private totalBoxOpened;

  /// @custom:log events
  event BoxOpened(address indexed owner, uint64 boxType, uint256 boxId, uint256 timestamp);

  /// @custom:log errors
  /// No box with boxType `boxType` left.
  error InsufficientBox(uint64 boxType);
  /// Insufficient DVCC allowance for Gas free service. Needed `required` but only `available` available.
  error InsufficientDVCCAllowance(uint256 available, uint256 required);
  /// Insufficient DVCC balance for Gas free service. Needed `required` but only `available` available.
  error InsufficientDVCCBalance(uint256 available, uint256 required);

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint256 totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(DVCCForwarder forwarder) ERC2771Context(address(forwarder)) ERC1155("") {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(URI_SETTER_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
    _grantRole(MINTER_ROLE, _msgSender());
    _grantRole(PAUSER_ROLE, _msgSender());
  }

  function getUserOpenedBox(address user, uint64 boxType) external view returns (uint256) {
    return userBoxOpened[user][boxType];
  }

  /// @custom:gameplay - open mystery box
  function openMysteryBox(uint64 boxType) external whenNotPaused convertGasfee("openMysteryBox") {
    if (balanceOf(_msgSender(), boxType) == 0) {
      revert InsufficientBox(boxType);
    }

    /// @dev consume box, get horse
    burn(_msgSender(), boxType, 1);

    userTotalBoxOpened[_msgSender()] += 1;
    userBoxOpened[_msgSender()][boxType] += 1;
    totalBoxOpened[boxType] += 1;
    emit BoxOpened(_msgSender(), boxType, totalBoxOpened[boxType], block.timestamp);

    _horseGamePlay.SSR_Build(_msgSender(), boxType);
  }

  /// @custom:gameplay - gasless approve
  function setApprovalForAll(
    address operator,
    bool approved
  ) public virtual override whenNotPaused convertGasfee("setApprovalForAll") {
    _setApprovalForAll(_msgSender(), operator, approved);
  }

  /// @custom:note - GM functions
  function initializeServices(address dvcToken, address horseGamePlay) external onlyRole(MANAGER_ROLE) {
    _dvcToken = dvcToken;
    _horseGamePlay = IHorseGamePlay(horseGamePlay);
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
    _setURI(newuri);
  }

  function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
    _mint(account, id, amount, data);
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public onlyRole(MINTER_ROLE) {
    _mintBatch(to, ids, amounts, data);
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }

  // The following functions are overrides required by Solidity.
  function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Revision: 2023-1-13
// version 1.0.0

interface ActivityStruct {
  struct Activity {
    uint256 actId;
    uint64 boxType;
    uint64 boxNum;
    uint64 boxApplied;
    uint64 stakeRatio;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
  }

  struct StakeOrder {
    address owner;
    uint8 option;
    uint256 amount;
    uint256 withdrawed;
    bool completed;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";

/// @title DVCCSwap - Swapping approved ERC20 token to DVCC
/// @notice - DVCC Technology
/// @dev - Module will be depreciated and replaced by other swaps after some product iterations
contract DVCCSwap is AccessControl {
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  IERC20 public _dvcToken;
  IERC20 public _swapToken;

  /// @notice - The exchange rate between DVCC and swapToken
  uint public _rate;

  /// @custom:log errors
  event Swap(address indexed user, uint amount, uint swapedAmount);
  /// Swap amount `amount` doesn't meet the minimum requirement: 1 dvcc
  error MinimumSwapAmount(uint amount);
  /// Insufficient allowance of swapToken `allowance`, required: `required`
  error InsufficientAllowance(uint allowance, uint required);

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:gameplay - Swap
  function swap(uint dvccAmount) external {
    if (dvccAmount < 1) {
      revert MinimumSwapAmount(dvccAmount);
    }

    uint swapedAmount = dvccAmount * _rate;
    uint allowance = _swapToken.allowance(_msgSender(), address(this));
    if (allowance < swapedAmount) {
      revert InsufficientAllowance(allowance, swapedAmount);
    }

    emit Swap(_msgSender(), dvccAmount, swapedAmount);
    TransferHelper.safeTransferFrom(address(_swapToken), _msgSender(), address(this), swapedAmount);
    TransferHelper.safeTransfer(address(_dvcToken), _msgSender(), dvccAmount);
  }

  /// @custom:note - GM functions
  function initializeServices(address dvcToken, address swapToken, uint256 rate) external onlyRole(MANAGER_ROLE) {
    _dvcToken = IERC20(dvcToken);
    _swapToken = IERC20(swapToken);
    _rate = rate;
  }

  function adjustRate(uint rate) external onlyRole(MANAGER_ROLE) {
    _rate = rate;
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../PriceConsumerV3.sol";

/// @title DVCCToken - Dubai Verse Core Currency
/// @notice - DVCC Technology
contract DVCCToken is ERC20, ERC20Burnable, Pausable, AccessControl, ERC2771Context {
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant GAS_ROLE = keccak256("GAS_ROLE");
  bytes32 public constant ACTIVITY_ROLE = keccak256("ACTIVITY_ROLE");

  /// @dev external contracts
  PriceConsumerV3 public _priceFeed;

  uint256 public _serviceFee;

  /// @custom:log events
  event DVCCGas(address indexed caller, string action, uint256 gasUsed, uint256 dvccExpense);

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(address spender, string memory action) {
    uint256 totalGas = gasleft();

    _;

    if (spender != address(this)) {
      /// @dev pay gas fee with dvcc
      if (isTrustedForwarder(msg.sender)) {
        gasFeeClaim(totalGas, _msgSender(), action);
      }
    }
  }

  constructor(DVCCForwarder forwarder) ERC20("DVCCToken", "DVCC") ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MANAGER_ROLE, msg.sender);
    _grantRole(PAUSER_ROLE, msg.sender);
    _mint(msg.sender, 2000000000 * 10 ** decimals());
  }

  /// @custom:gameplay - gasless approve dvcc
  function approve(
    address spender,
    uint256 amount
  ) public override convertGasfee(spender, "approve") whenNotPaused returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);

    return true;
  }

  /// Gas fee routing cost
  function gasFeeClaim(
    uint256 totalGas,
    address payer,
    string memory action
  ) public whenNotPaused onlyRole(GAS_ROLE) returns (bool) {
    uint256 gasUsed = totalGas - gasleft();
    uint256 dvccExpense = (gasUsed + _serviceFee) * uint256(_priceFeed.getLatestPrice()) * 100;

    emit DVCCGas(_msgSender(), action, gasUsed, dvccExpense);
    return this.transferFrom(payer, address(this), dvccExpense);
  }

  /// Activity cost
  function activityClaim(
    uint256 amount,
    address payer,
    address receiver
  ) public whenNotPaused onlyRole(ACTIVITY_ROLE) returns (bool) {
    return this.transferFrom(payer, receiver, amount);
  }

  /// @custom:note - GM functions
  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function setPriceFeed(address priceFeed, uint256 serviceFee) external onlyRole(MANAGER_ROLE) {
    _priceFeed = PriceConsumerV3(priceFeed);
    _serviceFee = serviceFee;
  }

  function burn(uint256 amount) public override onlyRole(MANAGER_ROLE) {
    _burn(_msgSender(), amount);
  }

  function burnFrom(address account, uint256 amount) public override onlyRole(MANAGER_ROLE) {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  function safeTransferToken(address to, uint value) external onlyRole(MANAGER_ROLE) returns (bool) {
    return this.transfer(to, value);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
    super._beforeTokenTransfer(from, to, amount);
  }

  /// @notice Forwarder Override
  function _msgSender() internal view override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev dependencies
import "./IHorseStruct.sol";

/// @title HorseAncestry - Managing horse ancestry
/// @notice - DVCC Technology
contract HorseAncestry is AccessControl, HorseStruct {
  struct AncestryRate {
    uint32 appearType;
    uint32 qualityLimit;
    uint32 appearWeight;
  }

  struct AncestryConf {
    uint32 inheritChance;
    uint32 speedGear;
    uint32 enduranceGear;
    uint32 burstGear;
    uint32 stableGear;
    uint32 maintainCost;
  }

  struct BaseAttrTLevelRates {
    uint32[] speedGear;
    uint32[] enduranceGear;
    uint32[] burstGear;
    uint32[] stableGear;
  }

  struct ExtendAttrTLevelRates {
    uint32[] speedGear;
    uint32[] enduranceGear;
    uint32[] burstGear;
    uint32[] stableGear;
  }

  struct RandomBonus {
    uint32 min;
    uint32 max;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  mapping(uint32 => AncestryRate) ancestryRateMapping;
  mapping(uint32 => AncestryConf) ancestryConfMapping;
  mapping(uint32 => BaseAttrTLevelRates) baseAttrRatesMapping;
  mapping(uint32 => ExtendAttrTLevelRates) extendAttrRatesMapping;
  mapping(uint32 => mapping(uint32 => mapping(uint32 => RandomBonus))) baseBonusMapping;
  mapping(uint32 => mapping(uint32 => mapping(uint32 => RandomBonus))) extendBonusMapping;
  mapping(uint32 => HorseAttribute) baseAttributes;
  uint32 totalAncestryLength;
  uint32 private constant RD = 0x2710;
  uint8 private tCoef = 2;

  /// @custom:log errors
  error InternalError();

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:base - view horse data sources
  // get each ancestry's base/extend T level rates
  function getAncestryAttrByAncestryId(
    uint32 id
  ) external view returns (BaseAttrTLevelRates memory, ExtendAttrTLevelRates memory) {
    return (baseAttrRatesMapping[id], extendAttrRatesMapping[id]);
  }

  // get each ancestry's rate and T level upper limit
  function getAncestryByAncestryId(uint32 id) external view returns (AncestryRate memory, AncestryConf memory) {
    return (ancestryRateMapping[id], ancestryConfMapping[id]);
  }

  // get each quality's base attrs
  function getBaseAttributes(uint32 quality) external view returns (HorseAttribute memory) {
    return baseAttributes[quality];
  }

  // get each quality's specific gear's specific tLevel's min/max bonus
  function getBonusMinMax(
    uint32 id,
    uint32 attrType,
    uint8 tLevel
  ) external view returns (RandomBonus memory, RandomBonus memory) {
    return (baseBonusMapping[id][attrType][tLevel - 1], extendBonusMapping[id][attrType][tLevel - 1]);
  }

  /// @custom:note - GM functions
  function addAncestryBonus(
    uint32 id,
    uint32 attrType,
    uint32[] memory bMins,
    uint32[] memory bMaxs,
    uint32[] memory eMins,
    uint32[] memory eMaxs
  ) public onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < bMins.length; i++) {
      RandomBonus memory _bBonus = RandomBonus(bMins[i], bMaxs[i]);
      RandomBonus memory _eBonus = RandomBonus(eMins[i], eMaxs[i]);
      baseBonusMapping[id][attrType][i] = _bBonus;
      extendBonusMapping[id][attrType][i] = _eBonus;
    }
  }

  function addAncestryBonusBatch(
    uint32[] memory ids,
    uint32[] memory attrTypes,
    uint32[][][] memory bMinsMatrix,
    uint32[][][] memory bMaxsMatrix,
    uint32[][][] memory eMinsMatrix,
    uint32[][][] memory eMaxsMatrix
  ) external onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < ids.length; i++) {
      for (uint32 j = 0; j < 4; j++) {
        addAncestryBonus(
          ids[i],
          attrTypes[j],
          bMinsMatrix[i][j],
          bMaxsMatrix[i][j],
          eMinsMatrix[i][j],
          eMaxsMatrix[i][j]
        );
      }
    }
  }

  function addAncestryAttr(
    uint32 id,
    uint32[] memory speedGear,
    uint32[] memory enduranceGear,
    uint32[] memory burstGear,
    uint32[] memory stableGear,
    uint32[] memory eSpeedGear,
    uint32[] memory eEnduranceGear,
    uint32[] memory eBurstGear,
    uint32[] memory eStableGear
  ) public onlyRole(MANAGER_ROLE) {
    BaseAttrTLevelRates memory _bATRate = BaseAttrTLevelRates(speedGear, enduranceGear, burstGear, stableGear);
    ExtendAttrTLevelRates memory _eATRate = ExtendAttrTLevelRates(eSpeedGear, eEnduranceGear, eBurstGear, eStableGear);
    baseAttrRatesMapping[id] = _bATRate;
    extendAttrRatesMapping[id] = _eATRate;
  }

  function addAncestryAttrBatch(
    uint32[] memory ids,
    BaseAttrTLevelRates[] memory bATRates,
    ExtendAttrTLevelRates[] memory eATRates
  ) external onlyRole(MANAGER_ROLE) {
    for (uint i = 0; i < bATRates.length; i++) {
      BaseAttrTLevelRates memory bRate = bATRates[i];
      ExtendAttrTLevelRates memory eRate = eATRates[i];
      addAncestryAttr(
        ids[i],
        bRate.speedGear,
        bRate.enduranceGear,
        bRate.burstGear,
        bRate.stableGear,
        eRate.speedGear,
        eRate.enduranceGear,
        eRate.burstGear,
        eRate.stableGear
      );
    }
  }

  function addAncestry(
    uint32 id,
    uint32 appearType,
    uint32 appearWeight,
    uint32 inheritChance,
    uint32 speedGear,
    uint32 enduranceGear,
    uint32 burstGear,
    uint32 stableGear,
    uint32 maintainCost,
    uint32 qualityLimit
  ) public onlyRole(MANAGER_ROLE) {
    AncestryRate memory _ancestryRate = AncestryRate(appearType, qualityLimit, appearWeight);
    AncestryConf memory _ancestryConf = AncestryConf(
      inheritChance,
      speedGear,
      enduranceGear,
      burstGear,
      stableGear,
      maintainCost
    );
    if (ancestryRateMapping[id].appearWeight == 0 && ancestryConfMapping[id].speedGear == 0) {
      totalAncestryLength += 1;
    }
    ancestryRateMapping[id] = _ancestryRate;
    ancestryConfMapping[id] = _ancestryConf;
  }

  function addAncestryBatch(
    uint32[] memory ids,
    AncestryRate[] memory ancestryRates,
    AncestryConf[] memory ancestryConfs
  ) external onlyRole(MANAGER_ROLE) {
    for (uint i = 0; i < ancestryConfs.length; i++) {
      AncestryRate memory rate = ancestryRates[i];
      AncestryConf memory conf = ancestryConfs[i];
      addAncestry(
        ids[i],
        rate.appearType,
        rate.appearWeight,
        conf.inheritChance,
        conf.speedGear,
        conf.enduranceGear,
        conf.burstGear,
        conf.stableGear,
        conf.maintainCost,
        rate.qualityLimit
      );
    }
  }

  function addBaseAttributes(
    uint32 quality,
    uint32 speed,
    uint32 endurance,
    uint32 burst,
    uint32 stable
  ) external onlyRole(MANAGER_ROLE) {
    HorseAttribute memory _attr = HorseAttribute(speed, endurance, burst, stable);
    baseAttributes[quality] = _attr;
  }

  function setTCoef(uint8 tCoef_) external onlyRole(MANAGER_ROLE) {
    tCoef = tCoef_;
  }

  /// @custom:gameplay - random generating horse ancestry
  function randomAncestry(
    uint randomNumber,
    uint32 qualityLimit,
    uint8[] memory appearTypes
  ) public view returns (uint32) {
    uint totalWeight;
    uint32[] memory weights = new uint32[](totalAncestryLength);
    uint32 BASE = 400000;
    for (uint32 index = BASE + 1; index <= totalAncestryLength + BASE; index++) {
      AncestryRate memory _ancestryRate = ancestryRateMapping[index];
      if (qualityLimit > _ancestryRate.qualityLimit) {
        for (uint8 k = 0; k < appearTypes.length; k++) {
          if (appearTypes[k] == _ancestryRate.appearType) {
            totalWeight += _ancestryRate.appearWeight;
            weights[index - BASE - 1] = _ancestryRate.appearWeight;
            break;
          }
        }
      }
    }

    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 start = 0;
    uint32 ancestry;
    for (uint32 index = 0; index < weights.length; index++) {
      uint32 ancestryRate = weights[index];
      uint32 end = start + ancestryRate;
      if (number >= start && number < end) {
        ancestry = index + BASE + 1;
        return ancestry;
      }
      start = end;
    }
    return ancestry;
  }

  /// @custom:gameplay - generating ancestries through inheritance
  function inheritAncestry(
    uint randomNumber,
    uint32 quality,
    uint32 attrType,
    uint32[] memory ancestryList
  ) public view returns (uint32) {
    uint32[] memory inheritedAncestries = new uint32[](ancestryList.length);
    uint32[] memory weights = new uint32[](ancestryList.length);
    uint32 totalWeight;

    for (uint32 i = 0; i < ancestryList.length; i++) {
      uint32 _ancestry = ancestryList[i];
      AncestryConf memory _conf = ancestryConfMapping[_ancestry];
      uint32 inheritChance = _conf.inheritChance;
      randomNumber = nextRandom(i + 1, randomNumber);
      uint32 inheritNumber = uint32(randomNumber % RD);
      if (inheritNumber > inheritChance && quality > ancestryRateMapping[_ancestry].qualityLimit) {
        continue;
      }

      inheritedAncestries[i] = _ancestry;

      uint32 gearWeight;
      uint32 _gear;
      if (attrType == 1) {
        _gear = _conf.speedGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 2) {
        _gear = _conf.enduranceGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 3) {
        _gear = _conf.burstGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 4) {
        _gear = _conf.stableGear;
        gearWeight = RD / _gear ** tCoef;
      } else {
        revert InternalError();
      }
      totalWeight = totalWeight + gearWeight;
      weights[i] = gearWeight;
    }

    if (inheritedAncestries[0] == 0) {
      uint8[] memory appearTypes = new uint8[](2);
      appearTypes[0] = 2;
      appearTypes[1] = 3;
      return randomAncestry(nextRandom(uint32(ancestryList.length) + 1, randomNumber), quality, appearTypes);
    }

    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 start = 0;
    uint32 ancestry;
    for (uint32 index = 0; index < inheritedAncestries.length; index++) {
      uint32 ancestryRate = weights[index];
      uint32 end = start + ancestryRate;
      if (number >= start && number < end) {
        return inheritedAncestries[index];
      }
      start = end;
    }
    return ancestry;
  }

  /// @custom:gameplay - generating horse attributes cooresponding to ancestry
  function randomAncestryAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) public view returns (HorseAttribute memory, HorseAttribute memory, uint) {
    HorseAttribute memory _baseAttr = randomAncestryBaseAttr(randomNumber, randomNonce, ancestry, quality);
    HorseAttribute memory _extendAttr = randomAncestryExtendAttr(randomNumber, randomNonce, ancestry, quality);

    uint hashRate;
    hashRate += ((_baseAttr.speed + _extendAttr.speed) * 1000) / 1020;
    hashRate += ((_baseAttr.endurance + _extendAttr.endurance) * 1000) / 1100;
    hashRate += ((_baseAttr.burst + _extendAttr.burst) * 1000) / 1112;
    hashRate += ((_baseAttr.stable + _extendAttr.stable) * 1000) / 972;

    return (_baseAttr, _extendAttr, hashRate);
  }

  /// @custom:gameplay - generating horse attributes cooresponding to ancestry during breeding
  function inheritAncestryAttr(
    uint randomNumber,
    uint randomNonce,
    uint32[] memory ancestryList,
    uint32 quality
  ) external view returns (HorseAttribute memory, HorseAttribute memory, uint32[] memory, uint) {
    uint32[] memory ancestries = new uint32[](4);
    ancestries[0] = inheritAncestry(randomNumber, quality, 1, ancestryList);
    randomNumber = nextRandom(randomNonce + 1, randomNumber);
    ancestries[1] = inheritAncestry(randomNumber, quality, 2, ancestryList);
    randomNumber = nextRandom(randomNonce + 2, randomNumber);
    ancestries[2] = inheritAncestry(randomNumber, quality, 3, ancestryList);
    randomNumber = nextRandom(randomNonce + 3, randomNumber);
    ancestries[3] = inheritAncestry(randomNumber, quality, 4, ancestryList);
    randomNumber = nextRandom(randomNonce + 4, randomNumber);

    (HorseAttribute memory _baseAttr1, HorseAttribute memory _extendAttr1, uint hashRate1) = randomAncestryAttr(
      randomNumber,
      randomNonce + 5,
      ancestries[0],
      quality
    );
    randomNumber = nextRandom(randomNonce + 6, randomNumber);
    (HorseAttribute memory _baseAttr2, HorseAttribute memory _extendAttr2, uint hashRate2) = randomAncestryAttr(
      randomNumber,
      randomNonce + 7,
      ancestries[1],
      quality
    );
    randomNumber = nextRandom(randomNonce + 8, randomNumber);
    (HorseAttribute memory _baseAttr3, HorseAttribute memory _extendAttr3, uint hashRate3) = randomAncestryAttr(
      randomNumber,
      randomNonce + 9,
      ancestries[2],
      quality
    );
    randomNonce = nextRandom(randomNonce + 10, randomNumber);
    (HorseAttribute memory _baseAttr4, HorseAttribute memory _extendAttr4, uint hashRate4) = randomAncestryAttr(
      randomNonce,
      randomNonce + 11,
      ancestries[3],
      quality
    );

    HorseAttribute memory _baseAttr = HorseAttribute(
      (_baseAttr1.speed + _baseAttr2.speed + _baseAttr3.speed + _baseAttr4.speed) / 4,
      (_baseAttr1.endurance + _baseAttr2.endurance + _baseAttr3.endurance + _baseAttr4.endurance) / 4,
      (_baseAttr1.burst + _baseAttr2.burst + _baseAttr3.burst + _baseAttr4.burst) / 4,
      (_baseAttr1.stable + _baseAttr2.stable + _baseAttr3.stable + _baseAttr4.stable) / 4
    );
    HorseAttribute memory _extendAttr = HorseAttribute(
      (_extendAttr1.speed + _extendAttr2.speed + _extendAttr3.speed + _extendAttr4.speed) / 4,
      (_extendAttr1.endurance + _extendAttr2.endurance + _extendAttr3.endurance + _extendAttr4.endurance) / 4,
      (_extendAttr1.burst + _extendAttr2.burst + _extendAttr3.burst + _extendAttr4.burst) / 4,
      (_extendAttr1.stable + _extendAttr2.stable + _extendAttr3.stable + _extendAttr4.stable) / 4
    );
    uint hashRate = (hashRate1 + hashRate2 + hashRate3 + hashRate4) / 4;

    uint32 valid = 4;
    if (ancestries[0] == ancestries[1] || ancestries[0] == ancestries[2] || ancestries[0] == ancestries[3]) {
      ancestries[0] = 0;
      valid--;
    }
    if (ancestries[1] == ancestries[2] || ancestries[1] == ancestries[3]) {
      ancestries[1] = 0;
      valid--;
    }
    if (ancestries[2] == ancestries[3]) {
      ancestries[2] = 0;
      valid--;
    }
    uint32[] memory finalAncestries = new uint32[](valid);
    uint32 count = 0;
    for (uint i = 0; i < 4; i++) {
      if (ancestries[i] != 0) {
        finalAncestries[count] = ancestries[i];
        count++;
      }
    }

    return (_baseAttr, _extendAttr, finalAncestries, hashRate);
  }

  function randomAncestryExtendAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) internal view returns (HorseAttribute memory) {
    HorseAttribute memory _extendAttr = baseAttributes[quality];
    ExtendAttrTLevelRates memory _eATRate = extendAttrRatesMapping[ancestry];

    // extendSpeed
    uint32[] memory speedGearsubset = _eATRate.speedGear;
    RandomBonus memory _speedRange = extendBonusMapping[ancestry][1][randomTLevel(speedGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 5, randomNumber);
    _extendAttr.speed = (_extendAttr.speed * randBetween(_speedRange.min, _speedRange.max, randomNumber)) / RD;

    // extendEndurance
    uint32[] memory enduranceGearsubset = _eATRate.enduranceGear;
    randomNumber = nextRandom(_extendAttr.speed, randomNumber);
    RandomBonus memory _enduranceRange = extendBonusMapping[ancestry][2][
      randomTLevel(enduranceGearsubset, RD, randomNumber)
    ];
    randomNumber = nextRandom(randomNonce + 6, randomNumber);
    _extendAttr.endurance =
      (_extendAttr.endurance * randBetween(_enduranceRange.min, _enduranceRange.max, randomNumber)) /
      RD;

    // extendBurst
    uint32[] memory burstGearsubset = _eATRate.burstGear;
    randomNumber = nextRandom(_extendAttr.endurance, randomNumber);
    RandomBonus memory _burstRange = extendBonusMapping[ancestry][3][randomTLevel(burstGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 7, randomNumber);
    _extendAttr.burst = (_extendAttr.burst * randBetween(_burstRange.min, _burstRange.max, randomNumber)) / RD;

    // extendStable
    uint32[] memory stableGearsubset = _eATRate.stableGear;
    randomNumber = nextRandom(_extendAttr.burst, randomNumber);
    RandomBonus memory _stableRange = extendBonusMapping[ancestry][4][randomTLevel(stableGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 8, randomNumber);
    _extendAttr.stable = (_extendAttr.stable * randBetween(_stableRange.min, _stableRange.max, randomNumber)) / RD;

    return _extendAttr;
  }

  function randomAncestryBaseAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) internal view returns (HorseAttribute memory) {
    HorseAttribute memory _baseAttr = baseAttributes[quality];
    BaseAttrTLevelRates memory _bATRate = baseAttrRatesMapping[ancestry];

    // baseSpeed
    uint32[] memory speedGearsubset = _bATRate.speedGear;
    RandomBonus memory _speedRange = baseBonusMapping[ancestry][1][randomTLevel(speedGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 1, randomNumber);
    _baseAttr.speed =
      _baseAttr.speed +
      (_baseAttr.speed * randBetween(_speedRange.min, _speedRange.max, randomNumber)) /
      RD;

    // baseEndurance
    uint32[] memory enduranceGearsubset = _bATRate.enduranceGear;
    randomNumber = nextRandom(_baseAttr.speed, randomNumber);
    RandomBonus memory _enduranceRange = baseBonusMapping[ancestry][2][
      randomTLevel(enduranceGearsubset, RD, randomNumber)
    ];
    randomNumber = nextRandom(randomNonce + 2, randomNumber);
    _baseAttr.endurance =
      _baseAttr.endurance +
      (_baseAttr.endurance * randBetween(_enduranceRange.min, _enduranceRange.max, randomNumber)) /
      RD;

    // baseBurst
    uint32[] memory burstGearsubset = _bATRate.burstGear;
    randomNumber = nextRandom(_baseAttr.endurance, randomNumber);
    RandomBonus memory _burstRange = baseBonusMapping[ancestry][3][randomTLevel(burstGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 3, randomNumber);
    _baseAttr.burst =
      _baseAttr.burst +
      (_baseAttr.burst * randBetween(_burstRange.min, _burstRange.max, randomNumber)) /
      RD;

    uint32[] memory stableGearsubset = _bATRate.stableGear;
    randomNumber = nextRandom(_baseAttr.burst, randomNumber);
    RandomBonus memory _stableRange = baseBonusMapping[ancestry][4][randomTLevel(stableGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 4, randomNumber);
    _baseAttr.stable =
      _baseAttr.stable +
      (_baseAttr.stable * randBetween(_stableRange.min, _stableRange.max, randomNumber)) /
      RD;

    return _baseAttr;
  }

  function randomTLevel(uint32[] memory rates, uint totalWeight, uint randomNumber) internal pure returns (uint32) {
    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 tLevel;
    uint32 start = 0;
    for (uint32 index = 0; index < rates.length; index++) {
      uint32 tRate = rates[index];
      uint32 end = start + tRate;
      if (number >= start && number < end) {
        tLevel = index;
        return tLevel;
      }
      start = end;
    }
    return tLevel;
  }

  function randBetween(uint32 min, uint32 max, uint256 r) internal pure returns (uint32) {
    if (min >= max) {
      return min;
    }

    uint256 rang = (max + 1) - min;
    uint32 rand = uint32(min + (r % rang));
    return rand;
  }

  function nextRandom(uint256 index, uint256 number) internal view returns (uint256) {
    uint256 n1 = number % (block.number + block.timestamp + index);
    uint256 h1 = uint256(blockhash(n1));
    return uint256(keccak256(abi.encodePacked(n1, h1, index)));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev dependencies
import "./IHorseStruct.sol";

/// @title HorseAppearance - Managing horse appearance
/// @notice - DVCC Technology
contract HorseAppearance is AccessControl, HorseStruct {
  struct AppearanceRate {
    uint32[] qualityLimit;
    uint32[] skinWeight;
  }

  struct ColorRate {
    uint32[] color;
    uint32[] colorWeight;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  mapping(uint32 => AppearanceRate) headRateById;
  mapping(uint32 => AppearanceRate) bodyRateById;
  mapping(uint32 => AppearanceRate) legRateById;
  mapping(uint32 => AppearanceRate) footRateById;
  mapping(uint32 => AppearanceRate) hairRateById;
  mapping(uint32 => AppearanceRate) tailRateById;
  mapping(uint32 => AppearanceRate) headDeatailRateById;
  mapping(uint32 => AppearanceRate) bodyDetailRateById;
  mapping(uint32 => AppearanceRate) legDetailRateById;
  mapping(uint32 => AppearanceRate) baseRateById;
  mapping(uint32 => ColorRate) partColorRateById;
  uint private constant RD = 0x2710;

  /// @custom:log errors
  /// unkown partId, 1:head, 2:body, 3:leg, 4:foot, 5:hair, 6:tail, 7:head detail, 8:body detail, 9:leg detail, 10:base
  error UnknownPartId();

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:base - view horse data sources
  // get appearance each part's texture rate
  function getAppearancePartRate(uint32 partId) external view returns (AppearanceRate memory) {
    if (partId == 1) {
      return headRateById[partId];
    } else if (partId == 2) {
      return bodyRateById[partId];
    } else if (partId == 3) {
      return legRateById[partId];
    } else if (partId == 4) {
      return footRateById[partId];
    } else if (partId == 5) {
      return hairRateById[partId];
    } else if (partId == 6) {
      return tailRateById[partId];
    } else if (partId == 7) {
      return headDeatailRateById[partId];
    } else if (partId == 8) {
      return bodyDetailRateById[partId];
    } else if (partId == 9) {
      return legDetailRateById[partId];
    } else if (partId == 10) {
      return baseRateById[partId];
    } else {
      revert UnknownPartId();
    }
  }

  // get appearance each part's color rate
  function getColorRate(uint32 skinId) external view returns (ColorRate memory) {
    return partColorRateById[skinId];
  }

  /// @custom:note - GM functions
  function addColor(uint32 skinId, uint32[] memory color, uint32[] memory colorWeight) public onlyRole(MANAGER_ROLE) {
    ColorRate memory _colorRate = ColorRate(color, colorWeight);
    partColorRateById[skinId] = _colorRate;
  }

  function addColorBatch(
    uint32[] memory skinIds,
    uint32[][] memory colors,
    uint32[][] memory colorWeights
  ) external onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < skinIds.length; i++) {
      addColor(skinIds[i], colors[i], colorWeights[i]);
    }
  }

  function addAppearancePart(
    uint32 partId,
    uint32[] memory qualityLimit,
    uint32[] memory skinWeight
  ) public onlyRole(MANAGER_ROLE) {
    AppearanceRate memory _appearanceRate = AppearanceRate(qualityLimit, skinWeight);
    if (partId == 1) {
      headRateById[partId] = _appearanceRate;
    } else if (partId == 2) {
      bodyRateById[partId] = _appearanceRate;
    } else if (partId == 3) {
      legRateById[partId] = _appearanceRate;
    } else if (partId == 4) {
      footRateById[partId] = _appearanceRate;
    } else if (partId == 5) {
      hairRateById[partId] = _appearanceRate;
    } else if (partId == 6) {
      tailRateById[partId] = _appearanceRate;
    } else if (partId == 7) {
      headDeatailRateById[partId] = _appearanceRate;
    } else if (partId == 8) {
      bodyDetailRateById[partId] = _appearanceRate;
    } else if (partId == 9) {
      legDetailRateById[partId] = _appearanceRate;
    } else if (partId == 10) {
      baseRateById[partId] = _appearanceRate;
    } else {
      revert UnknownPartId();
    }
  }

  function addAppearancePartBatch(
    uint32[] memory partIds,
    uint32[][] memory qualityLimits,
    uint32[][] memory skinWeights
  ) external onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < partIds.length; i++) {
      addAppearancePart(partIds[i], qualityLimits[i], skinWeights[i]);
    }
  }

  /// @custom:gameplay - random generating horse appearances
  function randomAppearance(
    uint randomNumber,
    uint randomNonce,
    uint32 quality
  ) external view returns (HorseAppearances memory) {
    uint32[] memory detailIds = new uint32[](3);
    uint32[] memory detailColors;
    detailIds[0] = randomPart(randomNumber, 7, quality);
    randomNumber = nextRandom(randomNonce + 1, randomNumber);
    detailIds[1] = randomPart(randomNumber, 8, quality);
    randomNumber = nextRandom(randomNonce + 2, randomNumber);
    detailIds[2] = randomPart(randomNumber, 9, quality);
    randomNumber = nextRandom(randomNonce + 3, randomNumber);
    bool unified;
    uint32 randNumber = uint32(randomNumber % RD);
    if (randNumber < 5000) {
      unified = true;
      detailColors = new uint32[](1);
      detailColors[0] = randomColor(nextRandom(randomNonce, randomNumber), detailIds[2]);
    } else {
      unified = false;
      detailColors = new uint32[](3);
      randomNumber = nextRandom(randomNonce + 4, randomNumber);
      detailColors[0] = randomColor(randomNumber, detailIds[0]);
      randomNumber = nextRandom(randomNonce + 5, randomNumber);
      detailColors[1] = randomColor(randomNumber, detailIds[1]);
      randomNumber = nextRandom(randomNonce + 6, randomNumber);
      detailColors[2] = randomColor(randomNumber, detailIds[2]);
    }

    uint32[] memory partIds = new uint32[](7);
    uint32[] memory partsColors = new uint32[](7);
    randomNumber = nextRandom(randomNonce + 7, randomNumber);
    partIds[0] = randomPart(randomNumber, 1, quality);
    randomNumber = nextRandom(randomNonce + 8, randomNumber);
    partIds[1] = randomPart(randomNumber, 2, quality);
    randomNumber = nextRandom(randomNonce + 9, randomNumber);
    partIds[2] = randomPart(randomNumber, 3, quality);
    randomNumber = nextRandom(randomNonce + 10, randomNumber);
    partIds[3] = randomPart(randomNumber, 4, quality);
    randomNumber = nextRandom(randomNonce + 11, randomNumber);
    partIds[4] = randomPart(randomNumber, 5, quality);
    randomNumber = nextRandom(randomNonce + 12, randomNumber);
    partIds[5] = randomPart(randomNumber, 6, quality);
    randomNumber = nextRandom(randomNonce + 13, randomNumber);
    partIds[6] = randomPart(randomNumber, 10, quality);
    randomNumber = nextRandom(randomNonce + 14, randomNumber);
    partsColors[0] = randomColor(randomNumber, partIds[0]);
    randomNumber = nextRandom(randomNonce + 15, randomNumber);
    partsColors[1] = randomColor(randomNumber, partIds[1]);
    randomNumber = nextRandom(randomNonce + 16, randomNumber);
    partsColors[2] = randomColor(randomNumber, partIds[2]);
    randomNumber = nextRandom(randomNonce + 17, randomNumber);
    partsColors[3] = randomColor(randomNumber, partIds[3]);
    randomNumber = nextRandom(randomNonce + 18, randomNumber);
    partsColors[4] = randomColor(randomNumber, partIds[4]);
    randomNumber = nextRandom(randomNonce + 19, randomNumber);
    partsColors[5] = randomColor(randomNumber, partIds[5]);
    randomNumber = nextRandom(randomNonce + 20, randomNumber);
    partsColors[6] = randomColor(randomNumber, partIds[6]);

    HorseAppearances memory _horseAppearances = HorseAppearances(
      partIds,
      partsColors,
      detailIds,
      detailColors,
      unified
    );
    return _horseAppearances;
  }

  // Random part texture
  function randomColor(uint randomNumber, uint32 skinId) internal view returns (uint32) {
    ColorRate memory _colorRate = partColorRateById[skinId];
    uint32[] memory _color = _colorRate.color;
    uint32[] memory _colorWeight = _colorRate.colorWeight;
    uint32 totalWeight = 0;
    for (uint32 i = 0; i < _colorWeight.length; i++) {
      totalWeight += _colorWeight[i];
    }
    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 color;
    uint32 start = 0;
    for (uint32 index = 0; index < _colorWeight.length; index++) {
      uint32 colorWeight = _colorWeight[index];
      uint32 end = start + colorWeight;
      if (number >= start && number < end) {
        color = _color[index];
        return color;
      }
      start = end;
    }
    return color;
  }

  // Random part color
  function randomPart(uint randomNumber, uint32 partId, uint32 quality) internal view returns (uint32) {
    AppearanceRate memory _appearanceRate;
    uint32 BASE;
    if (partId == 1) {
      _appearanceRate = headRateById[partId];
      BASE = 600000;
    } else if (partId == 2) {
      _appearanceRate = bodyRateById[partId];
      BASE = 620000;
    } else if (partId == 3) {
      _appearanceRate = legRateById[partId];
      BASE = 640000;
    } else if (partId == 4) {
      _appearanceRate = footRateById[partId];
      BASE = 660000;
    } else if (partId == 5) {
      _appearanceRate = hairRateById[partId];
      BASE = 670000;
    } else if (partId == 6) {
      _appearanceRate = tailRateById[partId];
      BASE = 680000;
    } else if (partId == 7) {
      _appearanceRate = headDeatailRateById[partId];
      BASE = 610000;
    } else if (partId == 8) {
      _appearanceRate = bodyDetailRateById[partId];
      BASE = 630000;
    } else if (partId == 9) {
      _appearanceRate = legDetailRateById[partId];
      BASE = 650000;
    } else if (partId == 10) {
      _appearanceRate = baseRateById[partId];
      BASE = 500000;
    } else {
      revert UnknownPartId();
    }
    uint32[] memory _qualityLimit = _appearanceRate.qualityLimit;
    uint32[] memory _skinWeight = _appearanceRate.skinWeight;
    uint32 totalWeight = 0;

    for (uint32 i = 0; i < _skinWeight.length; i++) {
      if (quality > _qualityLimit[i]) {
        totalWeight += _skinWeight[i];
      }
    }
    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 skin;
    uint32 start = 0;
    for (uint32 index = 0; index < _skinWeight.length; index++) {
      if (quality > _qualityLimit[index]) {
        uint32 skinWeight = _skinWeight[index];
        uint32 end = start + skinWeight;
        if (number >= start && number < end) {
          skin = index + BASE;
          return skin;
        }
        start = end;
      }
    }
    return skin;
  }

  function nextRandom(uint256 index, uint256 number) internal view returns (uint256) {
    uint256 n1 = number % (block.number + block.timestamp + index);
    uint256 h1 = uint256(blockhash(n1));
    return uint256(keccak256(abi.encodePacked(n1, h1, index)));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";
import "./IHorseStruct.sol";

/// @title HorseData - Dubai Verse Horse Core Database
/// @notice - DVCC Technology
/// @dev - Module will be updated to more decentralized structure after some product iterations
contract HorseData is AccessControl, HorseStruct {
  bytes32 public constant ACTIVITY_ROLE = keccak256("ACTIVITY_ROLE");

  mapping(uint256 => HorseData) private _horseData;

  /// @custom:log events
  event FullfillHorseData(address indexed caller, uint256[] tokenIds, string purpose);
  event AttachHorsePlate(address indexed operator, uint256 tokenId, uint32 numberPlate);
  event AttachHorseSkills(address indexed operator, uint256 tokenId, uint32[] skillList);

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(ACTIVITY_ROLE, _msgSender());
  }

  /// @custom:gameplay - retrieve horse data
  function getHorseData(uint256 tokenId) external view returns (HorseData memory) {
    return _horseData[tokenId];
  }

  /// @custom:note - GM functions
  function addHorseData(
    uint32 name,
    uint32 numberPlate,
    uint8 sex,
    uint32 quality,
    bool apprisal,
    uint8 bornType,
    uint32 load,
    uint32 skillMax,
    uint32[] memory skillList,
    uint32 maintainCost,
    uint32[] memory ancestryList,
    HorseAttribute memory baseAttr,
    HorseAttribute memory extendAttr,
    HorseAppearances memory appearances,
    uint256 hashRate,
    uint256 tokenId
  ) public onlyRole(ACTIVITY_ROLE) {
    HorseData memory horseData = HorseData({
      name: name,
      numberPlate: numberPlate,
      sex: sex,
      quality: quality,
      appraisal: apprisal,
      bornType: bornType,
      birthNumber: 0,
      load: load,
      skillMax: skillMax,
      skillList: skillList,
      maintainCost: maintainCost,
      ancestryList: ancestryList,
      baseAttr: baseAttr,
      extendAttr: extendAttr,
      appearances: appearances,
      hashRate: hashRate
    });
    _horseData[tokenId] = horseData;
  }

  function adjustHorseData(uint8 adjustType, uint256 tokenId) external onlyRole(ACTIVITY_ROLE) {
    if (adjustType == 1) {
      _horseData[tokenId].appraisal = true;
    } else if (adjustType == 2) {
      _horseData[tokenId].birthNumber++;
    }
  }

  function increaseBirthAllowance(uint256 tokenId) external onlyRole(ACTIVITY_ROLE) {
    _horseData[tokenId].birthNumber--;
  }

  function attachHorseNumberPlate(uint256 tokenId, uint32 numberPlate) external onlyRole(ACTIVITY_ROLE) {
    _horseData[tokenId].numberPlate = numberPlate;
    emit AttachHorsePlate(_msgSender(), tokenId, numberPlate);
  }

  function attachHorseSkills(uint256 tokenId, uint32[] memory skillList) external onlyRole(ACTIVITY_ROLE) {
    _horseData[tokenId].skillList = skillList;
    emit AttachHorseSkills(_msgSender(), tokenId, skillList);
  }

  function fullfillHorseDataBatch(
    uint32[] memory names,
    uint32[] memory numberPlates,
    uint8[] memory sexList,
    uint32[] memory qualities,
    bool[] memory apprisals,
    uint8[] memory bornTypes,
    uint32[] memory loads,
    uint32[] memory skillMaxs,
    uint32[][] memory skillLists,
    uint32[] memory maintainCosts,
    uint32[][] memory ancestryLists,
    HorseAttribute[] memory baseAttrs,
    HorseAttribute[] memory extendAttrs,
    HorseAppearances[] memory appearancesList,
    uint256[] memory hashRates,
    uint256[] memory tokenIdList,
    string memory purpose
  ) external onlyRole(ACTIVITY_ROLE) {
    for (uint256 i = 0; i < tokenIdList.length; i++) {
      addHorseData(
        names[i],
        numberPlates[i],
        sexList[i],
        qualities[i],
        apprisals[i],
        bornTypes[i],
        loads[i],
        skillMaxs[i],
        skillLists[i],
        maintainCosts[i],
        ancestryLists[i],
        baseAttrs[i],
        extendAttrs[i],
        appearancesList[i],
        hashRates[i],
        tokenIdList[i]
      );
    }
    emit FullfillHorseData(_msgSender(), tokenIdList, purpose);
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(ACTIVITY_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";
import "./IHorseStruct.sol";

interface IHorseAncestry is HorseStruct {
  function randomAncestry(uint256 randomNumber, uint32 quality, uint8[] memory appearTypes) external returns (uint32);

  function randomAncestryAttr(
    uint256 randomNumber,
    uint256 randomNonce,
    uint32 ancestry,
    uint32 quality
  ) external view returns (HorseAttribute memory, HorseAttribute memory, uint);

  function inheritAncestryAttr(
    uint256 randomNumber,
    uint256 randomNonce,
    uint32[] memory ancestryList,
    uint32 quality
  ) external view returns (HorseAttribute memory, HorseAttribute memory, uint32[] memory, uint);
}

interface IHorseAppearance is HorseStruct {
  function randomAppearance(
    uint256 randomNumber,
    uint256 randomNonce,
    uint32 quality
  ) external returns (HorseAppearances memory);
}

interface IHorseQuality {
  function randomQuality(uint randomNumber, uint32 qualityLimit) external returns (uint32);

  function getQualityConf(uint32 quality) external view returns (uint32, uint32, uint32);
}

interface IHorseGenericAttr {
  function randomGenericAttr(uint256 random, uint256 randomNonce) external returns (uint32, uint8);
}

interface IHorseData is HorseStruct {
  function addHorseData(
    uint32 name,
    uint32 numberPlate,
    uint8 sex,
    uint32 quality,
    bool apprisal,
    uint8 bornType,
    uint32 load,
    uint32 skillMax,
    uint32[] memory skillList,
    uint32 maintainCost,
    uint32[] memory ancestryList,
    HorseAttribute memory baseAttr,
    HorseAttribute memory extendAttr,
    HorseAppearances memory appearances,
    uint256 hashRate,
    uint256 tokenId
  ) external;

  function adjustHorseData(uint8 adjustType, uint256 tokenId) external;

  function attachHorseNumberPlate(uint256 tokenId, uint32 numberPlate) external;

  function getHorseData(uint256 tokenId) external returns (HorseData memory);
}

interface IHorse {
  function setTokenURI(uint tokenId, string memory _tokenURI) external;

  function safeMint(address to) external returns (uint256);

  function ownerOf(uint256 tokenId) external returns (address);
}

/// @title HorseGamePlay - Dubai Verse Horse Gameplay
/// @notice - DVCC Technology
/// @dev - Module will be updated to more decentralized structure and adding more functionalities after some product iterations
contract HorseGamePlay is Pausable, AccessControl, ERC2771Context, HorseStruct {
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant ACTIVITY_ROLE = keccak256("ACTIVITY_ROLE");

  /// @dev external contracts
  IHorseQuality _horseQuality;
  IHorseAppearance _horseAppearance;
  IHorseAncestry _horseAncestry;
  IHorseGenericAttr _horseGenericAttr;
  IHorseData _horseData;
  IHorse _nftHorse;
  address _dvcToken;
  uint256 private randomNonce;

  /// @notice - direct sale horse price & appraisement price & max birth number
  uint256 _horsePrice;
  uint256 _appraisePrice;
  uint32 _birthNum;

  /// @custom:log errors
  /// Only specifc contract can access; accesser: 'user' instead.
  error IlegalAccess(address user);
  /// Not your nfts
  error NotHorseOwner();
  /// Birth time of NFT `birthTime` exceeds max amount
  error ExceeedMaxBirth(uint tokenId);
  /// can not have same sex
  error IlegalSex();
  /// horse already appraised
  error RepetedAppraisal();
  /// horse need to be appraised to participate gameplay
  error NotAppraised();

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint256 totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(DVCCForwarder forwarder) ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
    _grantRole(MINTER_ROLE, _msgSender());

    _horsePrice = 20 * 10 ** 18;
    _appraisePrice = 10 * 10 ** 18;
    _birthNum = 5;
  }

  /// @custom:gameplay - get direct sale horse price
  function getUnitHorsePrice() external view returns (uint256, uint256) {
    return (_horsePrice, _appraisePrice);
  }

  /// @custom:gameplay - appraise new born horse
  function appraise(uint tokenId) external whenNotPaused convertGasfee("appraise") {
    if (_nftHorse.ownerOf(tokenId) != _msgSender()) {
      revert NotHorseOwner();
    }
    if (_horseData.getHorseData(tokenId).appraisal) {
      revert RepetedAppraisal();
    } else {
      randomNonce++;
      TransferHelper.safeActivityFeeClaim(_dvcToken, _appraisePrice, _msgSender(), address(this));
      _horseData.adjustHorseData(1, tokenId);
    }
  }

  /// @custom:gameplay - direct sale horse
  function buyHorse(address to) external whenNotPaused convertGasfee("buyHorse") {
    randomNonce++;
    TransferHelper.safeActivityFeeClaim(_dvcToken, _horsePrice, _msgSender(), address(this));
    uint random = randomNumber();
    uint32 quality = _horseQuality.randomQuality(random, 2);
    _build(quality, random, to);
  }

  /// @custom:gameplay - mystery box
  function SSR_Build(address to, uint64 boxType) external whenNotPaused onlyRole(ACTIVITY_ROLE) {
    randomNonce++;
    uint256 random = randomNumber();
    uint32 quality = 3;
    _build(quality, random, to);
  }

  /// @custom:gameplay - breed
  function reproducation(uint fatherId, uint motherId) external whenNotPaused convertGasfee("reproducation") {
    if (
      _nftHorse.ownerOf(fatherId) == _msgSender() && _nftHorse.ownerOf(motherId) == _msgSender() && fatherId != motherId
    ) {
      HorseData memory father = _horseData.getHorseData(fatherId);
      HorseData memory mother = _horseData.getHorseData(motherId);
      if (father.appraisal == false || mother.appraisal == false) {
        revert NotAppraised();
      }
      uint32[] memory fatherAncestries = father.ancestryList;
      uint32[] memory motherAncestries = mother.ancestryList;
      if (father.birthNumber >= _birthNum) {
        revert ExceeedMaxBirth(fatherId);
      }
      if (mother.birthNumber >= _birthNum) {
        revert ExceeedMaxBirth(motherId);
      }
      if (father.sex == mother.sex) {
        revert IlegalSex();
      }
      randomNonce++;
      uint32[] memory ancestryPool = new uint32[](fatherAncestries.length + motherAncestries.length);

      uint32 i = 0;
      for (; i < fatherAncestries.length; i++) {
        ancestryPool[i] = fatherAncestries[i];
      }
      for (uint j = 0; j < motherAncestries.length; j++) {
        ancestryPool[i + j] = motherAncestries[j];
      }

      // Random Quality
      uint256 random = randomNumber();
      uint32 quality = _horseQuality.randomQuality(random, 3);

      random = nextRandom(randomNonce + 1, random);
      (
        HorseAttribute memory baseAttr,
        HorseAttribute memory extendAttr,
        uint32[] memory inheritedAncestries,
        uint hashRate
      ) = _horseAncestry.inheritAncestryAttr(random, randomNonce, ancestryPool, quality);

      // Random Appearance
      random = nextRandom(randomNonce + 2, random);
      HorseAppearances memory appearances = _horseAppearance.randomAppearance(random, randomNonce, quality);

      // Generic Attributes
      random = nextRandom(randomNonce + 3, random);
      (uint32 name, uint8 sex) = _horseGenericAttr.randomGenericAttr(random, randomNonce);
      (uint32 load, uint32 skillMax, uint32 maintainCost) = _horseQuality.getQualityConf(quality);

      uint256 tokenId = _nftHorse.safeMint(_msgSender());
      uint32[] memory skillList = new uint32[](0);
      _horseData.addHorseData(
        name,
        0,
        sex,
        quality,
        false,
        2,
        load,
        skillMax,
        skillList,
        maintainCost,
        inheritedAncestries,
        baseAttr,
        extendAttr,
        appearances,
        hashRate,
        tokenId
      );
      _horseData.adjustHorseData(2, fatherId);
      _horseData.adjustHorseData(2, motherId);
    } else {
      revert NotHorseOwner();
    }
  }

  function _build(uint32 quality, uint256 random, address to) private {
    randomNonce++;
    // Random Ancestry
    uint32[] memory ancestryList = new uint32[](1);
    uint8[] memory appearTypes = new uint8[](2);
    appearTypes[0] = 1;
    appearTypes[1] = 3;
    uint32 ancestryId = _horseAncestry.randomAncestry(random, quality, appearTypes);
    ancestryList[0] = ancestryId;

    // Random Attributes
    random = nextRandom(randomNonce + 1, random);
    (HorseAttribute memory baseAttr, HorseAttribute memory extendAttr, uint hashRate) = _horseAncestry
      .randomAncestryAttr(random, randomNonce, ancestryId, quality);

    // Random Appearance
    random = nextRandom(randomNonce + 2, random);
    HorseAppearances memory appearances = _horseAppearance.randomAppearance(random, randomNonce, quality);

    // Generic Attributes
    random = nextRandom(randomNonce + 3, random);
    (uint32 name, uint8 sex) = _horseGenericAttr.randomGenericAttr(random, randomNonce);
    (uint32 load, uint32 skillMax, uint32 maintainCost) = _horseQuality.getQualityConf(quality);

    uint256 tokenId = _nftHorse.safeMint(to);
    uint32[] memory skillList = new uint32[](0);
    _horseData.addHorseData(
      name,
      0,
      sex,
      quality,
      true,
      1,
      load,
      skillMax,
      skillList,
      maintainCost,
      ancestryList,
      baseAttr,
      extendAttr,
      appearances,
      hashRate,
      tokenId
    );
  }

  function randomNumber() public view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.coinbase, block.timestamp, block.difficulty, randomNonce)));
  }

  function nextRandom(uint256 index, uint256 number) internal view returns (uint256) {
    uint256 n1 = number % (block.number + block.timestamp + index);
    uint256 h1 = uint256(blockhash(n1));
    return uint256(keccak256(abi.encodePacked(n1, h1, index)));
  }

  /// @custom:note - GM functions
  function initializeServices(
    address horseQuality,
    address horseAppearance,
    address horseAncestry,
    address horseGenericAttr,
    address horseData,
    address nftHorse,
    address dvcToken
  ) external onlyRole(MANAGER_ROLE) {
    _horseQuality = IHorseQuality(horseQuality);
    _horseAppearance = IHorseAppearance(horseAppearance);
    _horseAncestry = IHorseAncestry(horseAncestry);
    _horseGenericAttr = IHorseGenericAttr(horseGenericAttr);
    _horseData = IHorseData(horseData);
    _nftHorse = IHorse(nftHorse);

    _dvcToken = dvcToken;
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function setUnitHorsePrice(uint256 horsePrice, uint256 appraisePrice) external onlyRole(MANAGER_ROLE) {
    randomNonce++;
    _horsePrice = horsePrice;
    _appraisePrice = appraisePrice;
  }

  function setHorseMaxBirhNum(uint32 birthNum) external onlyRole(MANAGER_ROLE) {
    _birthNum = birthNum;
  }

  function setHorseNumberPlate(uint tokenId, uint32 numberPlate) external onlyRole(MANAGER_ROLE) {
    randomNonce++;
    _horseData.attachHorseNumberPlate(tokenId, numberPlate);
  }

  function setRandomNonce(uint256 nonce) external onlyRole(MANAGER_ROLE) {
    randomNonce = nonce;
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev dependencies
import "./IHorseStruct.sol";

/// @title HorseGenericAttr - Managing horse generic attributes
/// @notice - DVCC Technology
contract HorseGenericAttr is AccessControl, HorseStruct {
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  uint32 public firstName;
  uint32 public lastName;

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());

    firstName = 26;
    lastName = 21;
  }

  /// @custom:gameplay - randomize horse generic attributes
  function randomGenericAttr(uint256 random, uint256 randomNonce) external view returns (uint32 name, uint8 sex) {
    // Random Name
    name = randomName(random);

    // Random Sex
    random = nextRandom(randomNonce, random);
    sex = randomSex(random);
  }

  function randomName(uint256 random) internal view returns (uint32 horseName) {
    uint32 _firstName = uint32(random % uint256(firstName)) + 1;
    random = nextRandom(1, random);
    uint32 _lastName = uint32(random % uint256(lastName)) + 1;
    uint32 name = _firstName * 10000 + _lastName;
    return name;
  }

  function randomSex(uint256 random) internal pure returns (uint8 horseSex) {
    horseSex = uint8(random % 100);
    if (horseSex < 50) {
      horseSex = 0;
    } else {
      horseSex = 1;
    }
  }

  function nextRandom(uint256 index, uint256 number) internal view returns (uint256) {
    uint256 n1 = number % (block.number + block.timestamp + index);
    uint256 h1 = uint256(blockhash(n1));
    return uint256(keccak256(abi.encodePacked(n1, h1, index)));
  }

  /// @custom:note - GM functions
  function setNameRange(uint32 _firstName, uint32 _lastName) external onlyRole(MANAGER_ROLE) {
    firstName = _firstName;
    lastName = _lastName;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";

interface IHorse {
  function setTokenURI(uint tokenId, string memory _tokenURI) external;

  function ownerOf(uint256 tokenId) external returns (address);
}

/// @title HorseManage - Exporting horses to public markets
/// @notice - DVCC Technology
/// @dev - Module will be updated to more decentralized structure after some product iterations
contract HorseManage is AccessControl, EIP712, ERC2771Context {
  using Counters for Counters.Counter;

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  /// @notice - Verify prefix
  bytes32 private constant _EXPORT_TYPEHASH =
    keccak256("ExportHorse(address owner,uint256 tokenId,bytes32 tokenURI,uint256 nonce)");

  /// @dev external contracts
  IHorse _nftHorse;

  mapping(address => Counters.Counter) private _nonces;
  address _dvcToken;
  address public RDAddress;

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint256 totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(string memory name, DVCCForwarder forwarder) EIP712(name, "1") ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:gameplay - Export Horse
  function exportHorse(
    uint256 tokenId,
    string memory tokenURI,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external convertGasfee("exportHorse") {
    require(_nftHorse.ownerOf(tokenId) == _msgSender(), "Not owner!");
    bytes32 structHash = keccak256(
      abi.encode(_EXPORT_TYPEHASH, _msgSender(), tokenId, keccak256(bytes(tokenURI)), _useNonce(RDAddress))
    );

    bytes32 hash = _hashTypedDataV4(structHash);

    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == RDAddress, "Export Horse: invalid signature");

    // string memory _tokenURI = string(abi.encodePacked(tokenURI));
    _nftHorse.setTokenURI(tokenId, tokenURI);
  }

  function nonces(address owner) public view returns (uint256) {
    return _nonces[owner].current();
  }

  function _useNonce(address owner) internal returns (uint256 current) {
    Counters.Counter storage nonce = _nonces[owner];
    current = nonce.current();
    nonce.increment();
  }

  /// @custom:note - GM functions
  function initializeServices(address dvcToken, address nftHorse, address rdAddress) external onlyRole(MANAGER_ROLE) {
    _dvcToken = dvcToken;
    _nftHorse = IHorse(nftHorse);
    RDAddress = rdAddress;
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function safeTransferToken(address token, address to, uint256 value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title HorseQuality - Managing horse quality
/// @notice - DVCC Technology
contract HorseQuality is AccessControl {
  struct HorseQualityConf {
    uint32 load;
    uint32 skillMax;
    uint32 maintainCost;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  mapping(uint32 => uint32) qualityRateMapping;
  mapping(uint32 => HorseQualityConf) qualityConfMapping;
  uint32 totalWeight;
  uint32 totalQualityLength;

  /// @custom:log errors
  /// quality not exist
  error qualityNotExist();
  /// internalError
  error InternalError();

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:base - view horse data sources
  // get each quality's probability
  function getQualityRateList() external view returns (uint32[] memory, uint32[] memory) {
    uint32[] memory qualityList = new uint32[](totalQualityLength);
    uint32[] memory rateList = new uint32[](totalQualityLength);
    uint32 valid = 0;
    for (uint16 index = 1; index < totalQualityLength + 1; index++) {
      if (qualityRateMapping[index] != 0) {
        qualityList[index - 1] = index;
        rateList[index - 1] = (qualityRateMapping[index] * 10000) / totalWeight;
        valid++;
      }
    }

    uint32[] memory _formattedQualityList = new uint32[](valid);
    uint32[] memory _formattedRateList = new uint32[](valid);
    uint32 count = 0;
    for (uint64 j = 0; j < rateList.length; j++) {
      if (rateList[j] != 0) {
        _formattedQualityList[count] = qualityList[j];
        _formattedRateList[count] = rateList[j];
        count++;
      }
    }
    return (_formattedQualityList, _formattedRateList);
  }

  // get each quality's characteristics
  function getQualityConf(uint32 quality) external view returns (uint32 load, uint32 skillMax, uint32 maintainCost) {
    HorseQualityConf memory _qualityConf = qualityConfMapping[quality];
    return (_qualityConf.load, _qualityConf.skillMax, _qualityConf.maintainCost);
  }

  /// @custom:note - GM functions
  function addQualityRate(uint32 quality, uint32 qualityRate) external onlyRole(MANAGER_ROLE) {
    uint32 _qualityRate = qualityRateMapping[quality];
    if (_qualityRate != 0) {
      totalWeight = totalWeight - _qualityRate + qualityRate;
      qualityRateMapping[quality] = qualityRate;
    } else {
      qualityRateMapping[quality] = qualityRate;
      totalWeight = totalWeight + qualityRate;
      totalQualityLength++;
    }
  }

  function addQualityConf(
    uint32 quality,
    uint32 load,
    uint32 skillMax,
    uint32 maintainCost
  ) external onlyRole(MANAGER_ROLE) {
    HorseQualityConf memory _qualityConf = HorseQualityConf(load, skillMax, maintainCost);
    qualityConfMapping[quality] = _qualityConf;
  }

  function removeQualityRate(uint32 quality) external onlyRole(MANAGER_ROLE) {
    uint32 _qualityRate = qualityRateMapping[quality];
    if (_qualityRate == 0) {
      revert qualityNotExist();
    } else {
      qualityRateMapping[quality] = 0;
      totalWeight = totalWeight - _qualityRate;

      delete qualityConfMapping[quality];
    }
  }

  /// @custom:gameplay - random picking horse quality
  function randomQuality(uint randomNumber, uint32 qualityLimit) external view returns (uint32) {
    uint32 _deductWeights;
    for (uint32 i = qualityLimit; i < totalQualityLength; i++) {
      _deductWeights += qualityRateMapping[qualityLimit + 1];
    }

    uint32 number = uint32(randomNumber % uint256(totalWeight - _deductWeights));
    uint32 start = 0;
    for (uint16 index = 1; index <= qualityLimit; index++) {
      uint32 qualityRate = qualityRateMapping[index];
      uint32 end = start + qualityRate;
      if (number >= start && number < end) {
        return index;
      }
      start = end;
    }
    revert InternalError();
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Revision: 2023-1-13
// version 1.0.0

interface HorseStruct {
  struct HorseData {
    uint32 name;
    uint32 numberPlate;
    uint8 sex;
    uint32 quality;
    bool appraisal;
    uint32 bornType;
    uint32 birthNumber;
    uint32 load;
    uint32 skillMax;
    uint32[] skillList;
    uint32 maintainCost;
    uint32[] ancestryList;
    HorseAttribute baseAttr;
    HorseAttribute extendAttr;
    HorseAppearances appearances;
    uint256 hashRate;
  }

  struct HorseAttribute {
    uint32 speed;
    uint32 endurance;
    uint32 burst;
    uint32 stable;
  }

  struct HorseAppearances {
    uint32[] partIds;
    uint32[] partsColors;
    uint32[] detailIds;
    uint32[] detailColors;
    bool unified;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";

/// @title NFTHorse - Dubai Verse Horse Asset
/// @notice - DVCC Technology
contract NFTHorse is
  ERC721,
  ERC721Enumerable,
  ERC721Burnable,
  ERC721URIStorage,
  Pausable,
  AccessControl,
  ERC2771Context
{
  using Counters for Counters.Counter;

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  address _dvcToken;
  address _horseManage;
  Counters.Counter private _tokenIdCounter;

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint256 totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(
    string memory name,
    string memory symbol,
    DVCCForwarder forwarder
  ) ERC2771Context(address(forwarder)) ERC721(name, symbol) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(PAUSER_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:gameplay - gasless approval
  function setApprovalForAll(
    address operator,
    bool approved
  ) public override(ERC721, IERC721) whenNotPaused convertGasfee("setApprovalForAll") {
    _setApprovalForAll(_msgSender(), operator, approved);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
  }

  function safeMint(address to) external onlyRole(MINTER_ROLE) returns (uint256) {
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();
    _safeMint(to, tokenId);
    return tokenId;
  }

  function setTokenURI(uint tokenId, string memory _tokenURI) external whenNotPaused onlyRole(MINTER_ROLE) {
    _setTokenURI(tokenId, _tokenURI);
  }

  /// @custom:note - GM functions
  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function initializeServices(address horseManage, address dvcToken) external onlyRole(MANAGER_ROLE) {
    _horseManage = horseManage;
    _dvcToken = dvcToken;
  }

  function specialMint(address to, string memory _tokenURI) public onlyRole(MANAGER_ROLE) {
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, _tokenURI);
  }

  function specialMintBatch(address[] memory to, string[] memory _tokenURI) external onlyRole(MANAGER_ROLE) {
    require(to.length == _tokenURI.length, "NFTHorse: to.length != _tokenURI.length");
    for (uint256 i = 0; i < to.length; i++) {
      specialMint(to[i], _tokenURI[i]);
    }
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }

  // The following functions are overrides required by Solidity.
  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /// Utility Method for tokens get stacked
  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";
import "../erc1155/IActivityStruct.sol";

interface IBoxApply is ActivityStruct {
  function roundIsValid(uint256 actId) external view returns (bool);

  function getActivityById(uint256 actId) external view returns (Activity memory);

  function getCurrentActivityId() external view returns (uint);
}

/// @title veDvcFarm - Dubai Verse Mystery Box Stake Farm
/// @notice - DVCC Technology
contract veDvcFarm is ActivityStruct, Pausable, AccessControl, ERC2771Context {
  bytes32 public constant ACTIVITY_ROLE = keccak256("ACTIVITY_ROLE");
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  /// @dev external contracts
  address _dvcToken;
  IBoxApply _boxApply;

  mapping(address => mapping(uint => StakeOrder)) stakeOrdersByUser;
  uint[] rates = [2, 5, 9];
  uint[] expiration = [90, 180, 365];

  /// @custom:log events
  event Stake(address owner, uint actId, uint8 option, uint amount, uint stakeTime);
  event Withdraw(address owner, uint actId, uint amount, uint withdrawTime);

  /// @custom:log errors
  /// Round `actId` is invalid, either not opened yet or closed.
  error InvalidApplyRound(uint actId);
  /// Stake amount `invalid` is invalid, should be multiplier of `valid`.
  error InvalidStakeAmount(uint valid, uint invalid);
  /// If you append the stack amount, you can't switch stake option, option should be `origin` but applied `applied`.
  error CantSwitchStakeOption(uint8 origin, uint8 applied);
  /// Applied stake option `option` is not valid.
  error InvalidStakeOption(uint8 option);
  /// You don't have any deposit on activity with actId `actId`.
  error EmptyStakeOrder(uint actId);
  /// Activity with actId `actId` is not matured, time now `now`, mature time `matureTime`.
  error StakeNotMature(uint actId, uint now, uint matureTime);
  /// ActId `actId` already withdrawed.
  error RepeteWithdraw(uint actId);

  modifier onlyActiveAct(uint actId) {
    if (!_boxApply.roundIsValid(actId)) {
      revert InvalidApplyRound(actId);
    }
    _;
  }

  modifier onlyMatchBoxNum(uint actId, uint amount) {
    Activity memory _activity = _boxApply.getActivityById(actId);
    uint multiplier = _activity.price * _activity.stakeRatio;
    bool validAmount = amount % multiplier == 0;
    if (!validAmount) {
      revert InvalidStakeAmount(multiplier, amount);
    }
    _;
  }

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(DVCCForwarder forwarder) ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
    _grantRole(PAUSER_ROLE, _msgSender());
  }

  /// @custom:gameplay - stake dvcc for mystery box
  function stake(
    uint actId,
    uint8 option,
    uint amount
  ) external whenNotPaused onlyActiveAct(actId) onlyMatchBoxNum(actId, amount) convertGasfee("stake") {
    StakeOrder memory _order = stakeOrdersByUser[_msgSender()][actId];
    if (_order.amount != 0 && option != _order.option) {
      revert CantSwitchStakeOption(_order.option, option);
    }
    if (option >= rates.length) {
      revert InvalidStakeOption(option);
    }

    _order.owner = _msgSender();
    _order.option = option;
    _order.amount += amount;

    stakeOrdersByUser[_order.owner][actId] = _order;
    TransferHelper.safeActivityFeeClaim(_dvcToken, amount, _order.owner, address(this));

    emit Stake(_order.owner, actId, option, amount, block.timestamp);
  }

  /// @custom:gameplay - withdraw stake rewards
  function withdraw(uint actId) external whenNotPaused convertGasfee("withdraw") {
    /// @dev retrieve stake order, check if stake matured
    StakeOrder storage _order = stakeOrdersByUser[_msgSender()][actId];
    if (_order.owner == address(0)) {
      revert EmptyStakeOrder(actId);
    }
    Activity memory _activity = _boxApply.getActivityById(actId);

    uint8 option = _order.option;
    uint matureTime = expiration[option] * 86400 + _activity.endTime;

    if (block.timestamp < matureTime) {
      revert StakeNotMature(actId, block.timestamp, matureTime);
    }
    if (_order.completed) {
      revert RepeteWithdraw(actId);
    }

    uint value = (_order.amount * rates[option]) / 100 + _order.amount;
    _order.withdrawed = value;
    _order.completed = true;
    TransferHelper.safeTransfer(_dvcToken, _msgSender(), value);

    emit Withdraw(_msgSender(), actId, value, block.timestamp);
  }

  function getStakeOrder(uint actId, address owner) external view returns (StakeOrder memory) {
    StakeOrder memory _order = stakeOrdersByUser[owner][actId];
    if (_order.owner == address(0)) {
      revert EmptyStakeOrder(actId);
    }
    return _order;
  }

  function getUserWithdrawableRounds() external view returns (uint64[] memory) {
    uint256 totalActs = _boxApply.getCurrentActivityId();
    uint64[] memory withdrawableRounds = new uint64[](totalActs);
    uint64 valid = 0;
    for (uint64 i = 1; i < totalActs + 1; i++) {
      StakeOrder memory _order = stakeOrdersByUser[_msgSender()][i];
      Activity memory _activity = _boxApply.getActivityById(i);
      uint matureTime = expiration[_order.option] * 86400 + _activity.endTime;
      if (_order.owner != address(0) && !_order.completed && block.timestamp > matureTime) {
        withdrawableRounds[i - 1] = i;
        valid++;
      }
    }

    uint64[] memory _formatted = new uint64[](valid);
    uint64 count = 0;
    for (uint64 j = 0; j < withdrawableRounds.length; j++) {
      if (withdrawableRounds[j] != 0) {
        _formatted[count] = withdrawableRounds[j];
        count++;
      }
    }

    return _formatted;
  }

  function getValidStakeAmountMultiplier(uint actId) external view returns (uint) {
    Activity memory _activity = _boxApply.getActivityById(actId);
    uint multiplier = _activity.price * _activity.stakeRatio;
    return multiplier;
  }

  function getStakeOption() external view returns (uint[] memory) {
    return rates;
  }

  function payBoxFee(uint actId, uint amount, address owner) external onlyRole(ACTIVITY_ROLE) {
    StakeOrder storage _order = stakeOrdersByUser[owner][actId];
    _order.amount -= amount;
    TransferHelper.safeTransfer(_dvcToken, address(_boxApply), amount);
  }

  /// @custom:note - GM functions
  function initializeServices(address dvcToken, address boxApply) external onlyRole(MANAGER_ROLE) {
    _dvcToken = dvcToken;
    _boxApply = IBoxApply(boxApply);
  }

  function setRatesAndOptions(uint8 index, uint32 expiration_, uint32 rate_) external onlyRole(MANAGER_ROLE) {
    rates[index] = rate_;
    expiration[index] = expiration_;
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function safeTransferToken(address token, address to, uint value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
  AggregatorV3Interface internal priceFeed;

  constructor() {
    priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
  }

  /**
   * Returns the latest price
   */
  function getLatestPrice() public view returns (int) {
    (
      ,
      /*uint80 roundID*/
      int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
      ,
      ,

    ) = priceFeed.latestRoundData();
    return price;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @dev gasless transaction dependencies
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../utils/DVCCForwarder.sol";

/// @dev dependencies
import "../utils/TransferHelper.sol";

/// @title NFTStore - Dubai Verse Horse Store
/// @notice - DVCC Technology
/// @dev - Module will be updated to more generalized structure and adding more functionalities after some product iterations
contract NFTStore is Context, Pausable, AccessControl, ERC721Holder, ERC2771Context {
  using EnumerableSet for EnumerableSet.UintSet;

  struct NFT {
    uint256 price;
    address owner;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  mapping(address => EnumerableSet.UintSet) private _holderTokens;
  mapping(uint256 => NFT) private _tokenOwner;
  uint256 public _feeRate;
  address public _feeAddr;

  /// @dev external contracts
  address _dvcToken;
  IERC721 public _nft;

  /// @custom:log events
  event Sell(address indexed seller, uint256 tokenId, uint256 price, uint256 timestamp);
  event Cancel(address indexed owner, uint256 tokenId, uint256 timestamp);
  event Buy(address indexed buyer, uint256 tokenId, uint256 price, uint256 timestamp);
  event SafeUnlock(address indexed owner, uint256 tokenId, uint256 timestamp);

  /// @notice Gasless Transaction, use DVCC to pay gasfee
  modifier convertGasfee(string memory action) {
    uint totalGas = gasleft();

    _;

    /// @dev pay gas fee with dvcc
    if (isTrustedForwarder(msg.sender)) {
      TransferHelper.safeGasFeeClaim(_dvcToken, totalGas, _msgSender(), action);
    }
  }

  constructor(DVCCForwarder forwarder) ERC2771Context(address(forwarder)) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
    _grantRole(PAUSER_ROLE, _msgSender());
  }

  function getNft(uint256 tokenId) external view returns (uint256, address) {
    NFT memory tokenNft = _tokenOwner[tokenId];
    require(tokenNft.owner != address(0), "operator query for nonexistent token");
    return (tokenNft.price, tokenNft.owner);
  }

  function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0), "balance query for the zero address");
    return _holderTokens[owner].length();
  }

  function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
    return _holderTokens[owner].at(index);
  }

  /// @custom:gameplay - sell
  function sell(uint256 tokenId, uint256 price) external convertGasfee("sell") whenNotPaused {
    require(_nft.ownerOf(tokenId) == _msgSender(), "sell token that not own");

    NFT storage newnft = _tokenOwner[tokenId];
    newnft.price = price;
    newnft.owner = _msgSender();
    _holderTokens[_msgSender()].add(tokenId);
    _nft.safeTransferFrom(_msgSender(), address(this), tokenId);

    emit Sell(_msgSender(), tokenId, price, block.timestamp);
  }

  /// @custom:gameplay - buy
  function buy(uint256 tokenId, uint256 amount) public convertGasfee("buy") whenNotPaused {
    NFT memory tokenNFT = _tokenOwner[tokenId];
    require(tokenNFT.owner != address(0), "operator query for nonexistent token");
    require(amount == tokenNFT.price, "amount error");

    uint256 fee = (tokenNFT.price * _feeRate) / 10000;
    if (fee > 0) {
      TransferHelper.safeActivityFeeClaim(_dvcToken, fee, _msgSender(), address(this));
    }

    TransferHelper.safeActivityFeeClaim(_dvcToken, tokenNFT.price - fee, _msgSender(), tokenNFT.owner);

    _holderTokens[tokenNFT.owner].remove(tokenId);
    delete _tokenOwner[tokenId];
    _nft.safeTransferFrom(address(this), _msgSender(), tokenId);

    emit Buy(_msgSender(), tokenId, amount, block.timestamp);
  }

  /// @custom:gameplay - cancel
  function cancel(uint256 tokenId) external convertGasfee("cancel") whenNotPaused {
    NFT memory tokenNFT = _tokenOwner[tokenId];
    require(tokenNFT.owner == _msgSender(), "transfer token that not own");

    _holderTokens[_msgSender()].remove(tokenId);
    delete _tokenOwner[tokenId];
    _nft.safeTransferFrom(address(this), _msgSender(), tokenId);

    emit Cancel(_msgSender(), tokenId, block.timestamp);
  }

  function safeUnlock(uint256 tokenId) external convertGasfee("safeUnlock") whenPaused {
    require(_tokenOwner[tokenId].owner == _msgSender(), "transfer token that not own");

    _holderTokens[_msgSender()].remove(tokenId);
    delete _tokenOwner[tokenId];
    _nft.safeTransferFrom(address(this), _msgSender(), tokenId);

    emit SafeUnlock(_msgSender(), tokenId, block.timestamp);
  }

  /// @custom:note - GM functions
  function initializeServices(
    address feeToken,
    address nft,
    address feeAddr,
    uint256 feeRate
  ) external onlyRole(MANAGER_ROLE) {
    _dvcToken = feeToken;
    _nft = IERC721(nft);

    _feeAddr = feeAddr;
    _feeRate = feeRate;
  }

  function setTrustedForwarder(address forwarder) external onlyRole(MANAGER_ROLE) {
    _setTrustedForwarder(forwarder);
  }

  function safeTransferToken(address token, address to, uint256 value) external onlyRole(MANAGER_ROLE) {
    TransferHelper.safeTransfer(token, to, value);
  }

  function pause() external virtual onlyRole(PAUSER_ROLE) whenNotPaused {
    _pause();
  }

  function unpause() external virtual onlyRole(PAUSER_ROLE) whenPaused {
    _unpause();
  }

  /// @dev Forwarder Override
  function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address sender) {
    if (isTrustedForwarder(msg.sender)) {
      // The assembly code is more direct than the Solidity version using `abi.decode`.
      /// @solidity memory-safe-assembly
      assembly {
        sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    } else {
      return super._msgSender();
    }
  }

  function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
    if (isTrustedForwarder(msg.sender)) {
      return msg.data[:msg.data.length - 20];
    } else {
      return super._msgData();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Revision: 2023-1-13
// version 1.0.0

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev - Module will be updated to more complete after some product iterations
contract DVCCForwarder is EIP712, AccessControl {
  using ECDSA for bytes32;

  bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

  struct ForwardRequest {
    address from;
    address to;
    uint256 value;
    uint256 gas;
    uint256 nonce;
    bytes data;
  }

  bytes32 private constant _TYPEHASH =
    keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

  mapping(address => uint256) private _nonces;

  event ForwardStatus(bool status, bytes msg);

  constructor() EIP712("DVCCForwarder", "0.0.1") {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function getNonce(address from) public view returns (uint256) {
    return _nonces[from];
  }

  function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
    address signer = _hashTypedDataV4(
      keccak256(abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data)))
    ).recover(signature);
    return _nonces[req.from] == req.nonce && signer == req.from;
  }

  function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
    // If the _res length is less than 68, then the transaction failed silently (without a revert message)
    if (_returnData.length < 68) return "Transaction reverted silently";

    assembly {
      // Slice the sighash.
      _returnData := add(_returnData, 0x04)
    }
    return abi.decode(_returnData, (string)); // All that remains is the revert string
  }

  function execute(
    ForwardRequest calldata req,
    bytes calldata signature
  ) public payable onlyRole(RELAYER_ROLE) returns (bool, bytes memory) {
    require(verify(req, signature), "DVCCForwarder: signature does not match request");
    _nonces[req.from] = req.nonce + 1;

    (bool success, bytes memory returndata) = req.to.call{gas: req.gas, value: req.value}(
      abi.encodePacked(req.data, req.from)
    );

    // Validate that the relayer has sent enough gas for the call.
    // See https://ronan.eth.limo/blog/ethereum-gas-dangers/
    if (gasleft() <= req.gas / 63) {
      assembly {
        invalid()
      }
    }
    if (success) {
      emit ForwardStatus(success, "");
    } else {
      emit ForwardStatus(success, returndata);
    }

    return (success, returndata);
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
  function safeApprove(address token, address to, uint256 value) internal {
    // bytes4(keccak256(bytes("approve(address,uint256)")));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeApprove: approve failed");
  }

  function safeTransfer(address token, address to, uint256 value) internal {
    // bytes4(keccak256(bytes("transfer(address,uint256)")));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper::safeTransfer: transfer failed");
  }

  function safeTransferFrom(address token, address from, address to, uint256 value) internal {
    // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::transferFrom: transferFrom failed"
    );
  }

  function safeGasFeeClaim(address token, uint256 amount, address payer, string memory action) internal {
    // bytes4(keccak256(bytes("gasFeeClaim(uint256,address,string)")));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x202d2be5, amount, payer, action));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::transferFrom: transferFrom failed"
    );
  }

  function safeActivityFeeClaim(address token, uint256 amount, address payer, address receiver) internal {
    // bytes4(keccak256(bytes("activityClaim(uint256,address,address)")));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x1b8af900, amount, payer, receiver));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::transferFrom: transferFrom failed"
    );
  }
}