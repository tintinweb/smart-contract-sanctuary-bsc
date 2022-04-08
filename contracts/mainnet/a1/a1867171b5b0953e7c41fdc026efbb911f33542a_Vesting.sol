/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Strings.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/IAccessControl.sol


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

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/Vesting.sol


pragma solidity 0.8.11;





/**
 * @title Vesting
 */
contract Vesting is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    // Investor data structure. Mapping from these structures is stored in the contract, it is filled before the start of vesting
    struct InvestorData {
        bool cliffPaid;
        address investor; // investor address
        uint256 amount; // amount of tokens to be released at the end of the vesting except for amount paid after the cliff
        uint256 released; // amount of tokens released
        uint256 amountAfterCliff; // amount paid after cliff, must be calculated outside the contract from the percentage (cliffPercent)
        uint256 phaseID; // ID of the vesting phase, for each phase set a unique number outside the contract
    }

    // The structure of the vesting phases. Mapping from these structures is stored in the contract, it is filled before the start of vesting
    struct VestingPhase {
        uint256 start; // start time of the vesting period
        uint256 duration; // duration of the vesting period arter cliff in seconds (total duration - cliff)
        uint256 cliff; // cliff period in seconds
        uint256 cliffPercent; // % after cliff period (multiply by 10, because could be fractional percentage, like - 7.5)
        uint256 slicePeriodSeconds; // duration of a slice period in seconds
        string phaseName; // name of the vesting phase
    }

    // The full structure of vesting in the context of the investor. Not stored in the contract, but returned upon request from the web application
    struct VestingSchedule {
        bool cliffPaid;
        address investor; // investor address
        uint256 cliff; // cliff period in seconds
        uint256 cliffPercent; // % after cliff period (multiply by 10, because could be fractional percentage, like - 7,5)
        uint256 amountAfterCliff; // amount paid after cliff
        uint256 start; // start time of the vesting period
        uint256 duration; // duration of the vesting period arter cliff in seconds
        uint256 slicePeriodSeconds; // duration of a slice period for the vesting in seconds
        uint256 amount; // amount of tokens to be released at the end of the vesting except for percentages after the cliff
        uint256 released; // amount of tokens released exept cliff percent
        uint256 releasedTotal; // total amount of tokens released with cliff percent
        uint256 releasableAmount; // amount of tokens ready for release now
        uint256 phaseID; // ID of the vesting phase
        string phaseName; // name of the vesting phase
    }

    IERC20 private immutable _token;
    // Create a new role identifier for the admin role
    bytes32 public constant STAGE_ADJUSTMENT_ROLE =
        keccak256("STAGE_ADJUSTMENT_ROLE");
    mapping(bytes32 => InvestorData) private investorsData;
    mapping(uint256 => VestingPhase) private vestingPhases;
    uint256 private vestingTotalAmount;
    mapping(address => uint256) private holdersVestingCount;

    event Released(address indexed investor, uint256 amount);

    /**
     * @dev Reverts if the vesting schedule does not exist or has been revoked.
     */
    modifier onlyIfNotRevoked(bytes32 investorDataId) {
        require(investorsData[investorDataId].amount > 0);
        _;
    }

    /**
     * @dev Throws if called by any accounts other than the SA (stage adjustment) or admin.
     */
    modifier onlyAdminOrSA() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(STAGE_ADJUSTMENT_ROLE, msg.sender),
            "Caller is not an admin and has no stage adjustment role"
        );
        _;
    }

    /**
     * @dev Creates a vesting contract.
     * @param token_ address of the IERC20/BEP20 token contract
     */
    constructor(address token_) {
        require(token_ != address(0x0));
        _token = IERC20(token_);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @notice Returns the total amount of vesting.
     * @return the total amount of vesting
     */
    function getvestingTotalAmount() external view returns (uint256) {
        return vestingTotalAmount;
    }

    /**
     * @dev Returns the number of vesting schedules associated to an investor.
     * @return the number of vesting schedules
     */
    function getVestingSchedulesCountByInvestor(address _investor)
        external
        view
        returns (uint256)
    {
        return holdersVestingCount[_investor];
    }

    /**
     * @notice Returns the investor data information for a given holder and index.
     * @return the investor data structure information
     */
    function getInvestorDataByAddressAndIndex(address holder, uint256 index)
        external
        view
        returns (InvestorData memory)
    {
        return
            getInvestorData(
                computeInvestorDataIdForAddressAndIndex(holder, index)
            );
    }

    /**
     * @notice Returns the vesting schedule information for a given holder and index.
     * @return the vesting schedule structure information
     */
    function getVestingScheduleByAddressAndIndex(address holder, uint256 index)
        public
        view
        returns (VestingSchedule memory)
    {
        InvestorData memory investorData = getInvestorData(
            computeInvestorDataIdForAddressAndIndex(holder, index)
        );
        uint256 releasedTotal = investorData.released;
        if (investorData.cliffPaid) {
            releasedTotal = releasedTotal + investorData.amountAfterCliff;
        }
        VestingPhase memory vestingPhase = vestingPhases[investorData.phaseID];
        return
            VestingSchedule(
                investorData.cliffPaid,
                investorData.investor,
                vestingPhase.cliff,
                vestingPhase.cliffPercent,
                investorData.amountAfterCliff,
                vestingPhase.start,
                vestingPhase.duration,
                vestingPhase.slicePeriodSeconds,
                investorData.amount,
                investorData.released,
                releasedTotal,
                _computeReleasableAmount(investorData),
                investorData.phaseID,
                vestingPhase.phaseName
            );
    }

    /**
     * @notice Returns the array of vesting schedules for a given holder.
     * @return the array of vesting schedule structures
     * @param _investor address of investor
     */
    function getScheduleArrayByInvestor(address _investor)
        external
        view
        returns (VestingSchedule[] memory)
    {
        uint256 vestingSchedulesCount = holdersVestingCount[_investor];
        VestingSchedule[] memory schedulesArray = new VestingSchedule[](
            vestingSchedulesCount
        );
        for (uint256 i = 0; i < vestingSchedulesCount; i++) {
            schedulesArray[i] = getVestingScheduleByAddressAndIndex(
                _investor,
                i
            );
        }
        return schedulesArray;
    }

    /**
     * @dev Returns the address of the IERC20/BEP20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    /**
     * @notice Creates a new vesting phase.
     * @param _phaseId ID of vesting phase
     * @param _start start time of the vesting period
     * @param _duration duration in seconds of the period in which the tokens will vest
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
     * @param _cliffPercent % of token amount could be clamed after the cliff
     * @param _slicePeriodSeconds duration of a slice period for the vesting in seconds
     * @param _phaseName name of the vesting phase
     */
    function createVestingPhase(
        uint256 _phaseId,
        uint256 _start,
        uint256 _duration,
        uint256 _cliff,
        uint256 _cliffPercent,
        uint256 _slicePeriodSeconds,
        string memory _phaseName
    ) external onlyAdminOrSA {
        require(_duration >= 0, "Vesting: duration must be >= 0");
        require(
            _slicePeriodSeconds >= 1,
            "Vesting: slicePeriodSeconds must be >= 1"
        );
        vestingPhases[_phaseId] = VestingPhase(
            _start,
            _duration,
            _start + _cliff,
            _cliffPercent,
            _slicePeriodSeconds,
            _phaseName
        );
    }

    /**
     * @notice Change vesting phase.
     * @param _phaseId ID of vesting phase
     * @param _start start time of the vesting period
     * @param _duration duration in seconds of the period in which the tokens will vest
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
     * @param _cliffPercent % of token amount could be clamed after the cliff
     * @param _slicePeriodSeconds duration of a slice period for the vesting in seconds
     * @param _phaseName name of the vesting phase
     */
    function changeVestingPhase(
        uint256 _phaseId,
        uint256 _start,
        uint256 _duration,
        uint256 _cliff,
        uint256 _cliffPercent,
        uint256 _slicePeriodSeconds,
        string memory _phaseName
    ) external onlyAdminOrSA {
        require(_duration >= 0, "Vesting: duration must be >= 0");
        require(
            _slicePeriodSeconds >= 1,
            "Vesting: slicePeriodSeconds must be >= 1"
        );
        VestingPhase storage vestingPhase = vestingPhases[_phaseId];
        vestingPhase.start = _start;
        vestingPhase.duration = _duration;
        vestingPhase.cliff = _start + _cliff;
        vestingPhase.cliffPercent = _cliffPercent;
        vestingPhase.slicePeriodSeconds = _slicePeriodSeconds;
        vestingPhase.phaseName = _phaseName;
    }

    /**
     * @notice Creates a new vesting schedule for an investor.
     * @param _investor address of the investor to whom vested tokens are transferred
     * @param _amount total amount of tokens to be released at the end of the vesting
     * @param _cliffPercent percent from total amount to be payd after cliff
     * @param _phaseID ID of the vesting phase
     */
    function addInvestor(
        address _investor,
        uint256 _amount,
        uint256 _cliffPercent,
        uint256 _phaseID
    ) external onlyAdminOrSA {
        require(_amount > 0, "Vesting: amount must be > 0");
        bytes32 investorDataId = computeNextinvestorDataIdForHolder(_investor);
        uint256 _amountAfterCliff = (_amount * _cliffPercent) / 1000;

        investorsData[investorDataId] = InvestorData(
            false,
            _investor,
            _amount - _amountAfterCliff,
            0,
            _amountAfterCliff,
            _phaseID
        );
        vestingTotalAmount = vestingTotalAmount + _amount;
        holdersVestingCount[_investor] += 1;
    }

    /**
     * @notice Cancels an existing schedule by resetting the amount
     * @param investorDataId the vesting schedule identifier
     */
    function cancelInvestorSchedule(bytes32 investorDataId)
        external
        onlyAdminOrSA
    {
        InvestorData storage investorData = investorsData[investorDataId];
        vestingTotalAmount =
            vestingTotalAmount -
            ((investorData.amount + investorData.amountAfterCliff) -
                investorData.released);
        investorData.amount = 0;
        investorData.amountAfterCliff = 0;
        investorData.cliffPaid = true;
    }

    /**
     * @notice Change an existing schedule by overwriting all parameters
     * @param investorDataId the vesting schedule identifier
     * @param _cliffPaid was the amount paid after the cliff
     * @param _amount total amount of tokens to be released at the end of the vesting
     * @param _released how much has already been paid to the investor
     * @param _cliffPercent percent from total amount to be payd after cliff
     * @param _phaseID ID of the vesting phase
     */
    function changeInvestorSchedule(
        bytes32 investorDataId,
        bool _cliffPaid,
        uint256 _amount,
        uint256 _released,
        uint256 _cliffPercent,
        uint256 _phaseID
    ) external onlyAdminOrSA {
        uint256 _amountAfterCliff = (_amount * _cliffPercent) / 1000;
        InvestorData storage investorData = investorsData[investorDataId];

        if (_released == 0) {
            _released = investorData.released;
        }
        if (_phaseID == 0) {
            _phaseID = investorData.phaseID;
        }

        vestingTotalAmount =
            vestingTotalAmount -
            ((investorData.amount + investorData.amountAfterCliff) -
                investorData.released);

        investorData.cliffPaid = _cliffPaid;
        investorData.amount = _amount - _amountAfterCliff;
        investorData.released = _released;
        investorData.amountAfterCliff = _amountAfterCliff;
        investorData.phaseID = _phaseID;

        vestingTotalAmount = (vestingTotalAmount + _amount) - _released;
    }

    /**
     * @notice Withdraw the specified amount if possible.
     * @param amount the amount to withdraw
     */
    function withdraw(uint256 amount) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        _token.safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Release vested amount of tokens.
     * @param investorDataId the vesting schedule identifier
     * @param amount the amount to release
     */
    function release(bytes32 investorDataId, uint256 amount)
        public
        nonReentrant
        onlyIfNotRevoked(investorDataId)
    {
        InvestorData storage investorData = investorsData[investorDataId];
        require(
            msg.sender == investorData.investor ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Vesting: only investor and admin can release vested tokens"
        );
        uint256 vestedAmount = _computeReleasableAmount(investorData);
        require(
            vestedAmount >= amount,
            "Vesting: cannot release tokens, not enough vested tokens"
        );
        if (amount != 0) {
            if (investorData.cliffPaid) {
                investorData.released = investorData.released + amount;
            } else {
                investorData.released =
                    (investorData.released + amount) -
                    investorData.amountAfterCliff;
            }
            vestingTotalAmount = vestingTotalAmount - amount;
            investorData.cliffPaid = true;
            address payable investorPayable = payable(investorData.investor);

            _token.safeTransfer(investorPayable, amount);

            emit Released(investorData.investor, amount);
        }
    }

    /**
     * @notice Computes the vested amount of tokens for the given vesting schedule identifier.
     * @return the vested amount
     */
    function computeReleasableAmount(bytes32 investorDataId)
        external
        view
        onlyIfNotRevoked(investorDataId)
        returns (uint256)
    {
        //InvestorData storage investorData = investorsData[investorDataId];
        return _computeReleasableAmount(investorsData[investorDataId]);
    }

    /**
     * @notice Returns the investor data information for a given identifier.
     * @return the investor data structure information
     */
    function getInvestorData(bytes32 investorDataId)
        public
        view
        returns (InvestorData memory)
    {
        return investorsData[investorDataId];
    }

    /**
     * @dev Returns the amount of tokens that can be withdrawn by the admin.
     * @return the amount of tokens
     */
    function getWithdrawableAmount() external view returns (uint256) {
        return _token.balanceOf(address(this)) - vestingTotalAmount;
    }

    /**
     * @dev Computes the next investor data identifier for a given holder address.
     */
    function computeNextinvestorDataIdForHolder(address holder)
        public
        view
        returns (bytes32)
    {
        return
            computeInvestorDataIdForAddressAndIndex(
                holder,
                holdersVestingCount[holder]
            );
    }

    /**
     * @dev Get vesting phase.
     * @param _phaseID ID of phase
     * @return structure of vesting phase
     */
    function getVestingPhase(uint256 _phaseID)
        external
        view
        returns (VestingPhase memory)
    {
        return vestingPhases[_phaseID];
    }

    /**
     * @dev Get current timestamp in seconds.
     * @return current timestamp
     */
    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Computes the investor data identifier for an address and an index.
     */
    function computeInvestorDataIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    /**
     * @dev Grant the stage adjustment role to a specified account
     * @param saRole_ the address to which SA permissions are set
     */
    function grantSARole(address saRole_) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        _setupRole(STAGE_ADJUSTMENT_ROLE, saRole_);
    }

    /**
     * @dev Computes the releasable amount of tokens for a vesting schedule.
     * @return the amount of releasable tokens
     */
    function _computeReleasableAmount(InvestorData memory investorData)
        internal
        view
        returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        VestingPhase memory vestingPhase = vestingPhases[investorData.phaseID];

        if (
            (currentTime < vestingPhase.cliff) || (investorData.amount == 0) // If cliff not finished or total amount = 0 (schedule was canceled)
        ) {
            return 0;
        } else if (currentTime >= vestingPhase.cliff + vestingPhase.duration) {
            // If vesting period finished
            return investorData.amount - investorData.released;
        } else {
            uint256 timeFromStart = currentTime - vestingPhase.cliff;
            uint256 secondsPerSlice = vestingPhase.slicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;
            uint256 vestedAmount = (investorData.amount * vestedSeconds) /
                vestingPhase.duration;
            if (investorData.cliffPaid) {
                vestedAmount = vestedAmount - investorData.released;
            } else {
                vestedAmount = vestedAmount + investorData.amountAfterCliff;
            }
            return vestedAmount;
        }
    }
}