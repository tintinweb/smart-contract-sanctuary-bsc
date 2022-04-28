/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: SuperGaming.sol

pragma solidity >=0.8.0;








interface IPancakeRouter {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

interface Oracle {
    function getPrice() external view returns(uint);
    function inUSD() external view returns(uint);
}

interface SponsorLeague {
    function addPoints(address _sponsor, uint _points) external returns(bool);
}

interface Multiplier {
    function getMultiplier(address _sponsor) external returns(uint);
}

contract SuperGaming is AccessControl, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    using SafeMath for uint;

    IERC20 public immutable WBNB;
    IERC20 public immutable USDT;
    IERC20 public immutable DFSG;
    IPancakeRouter public ROUTER;

    uint public poolFee = 7500;         // 75%
    uint public liquidityFee = 1000;    // 10%
    uint public teamFee = 500;          // 5%
    uint public burnFee = 500;          // 5%
    uint public extraFee = 500;         // 5%

    address public teamAddress;
    address public burnAddress;
    address public extraAddress;
    address public leagueAddress;
    address public multiplierAddress;

    Oracle public DFSG_Oracle;

    Counters.Counter public tourneysCount;
    Counters.Counter public teamsCount;

    mapping(uint => Tourney) private _tourneysInfo;

    /* Tourney -> TeamIds registered */
    mapping(uint => EnumerableSet.UintSet) private _tourneyTeams;

    /* Gamer -> Tourney -> TeamId */
    mapping(address => mapping(uint => uint)) private _gamerTeams;

    /* Sponsor -> Tourney -> TeamIds */
    mapping(address => mapping(uint => EnumerableSet.UintSet)) private _sponsoredTeams;

    /* TamId -> TeamInfo */
    mapping(uint => Team) private _teamInfo;

    /* Sponsor stats */
    mapping(address => uint) private _sponsoredCount;
    mapping(address => EnumerableSet.UintSet) private _sponsorTourneys;
    mapping(address => uint) private _sponsorRewards;

    /* Gamer -> Tourneys*/
    mapping(address => EnumerableSet.UintSet) private _gamerTourneys;
    mapping(address => uint) private _gamerRewards;

    bytes32 public constant REFEREE_ROLE = keccak256("REFEREE_ROLE");

    enum TourneyStatus{
        Active,
        Paused,
        Finished
    }

    struct Team {
        string name;
        address sponsor;
        address[] gamers;
        uint position;
        uint score;
        uint teamRewards;
    }

    struct Tourney {
        uint id; 
        uint game;
        // 0 = LOL
        // 1 = CSGO
        // 2 = POKER
        // 3 = VALORANT
        // 4 = FIFA
        // 5 = CLASH ROYALE
        // 6 = COD
        // 7 = CHESS
        // 8 = BRAWL STARS
        // 9 = MINECRAFT
        // 10 = TFT
        // 11 = AXIE
        // 12 = ...
        uint secondIndex;   // Used for the tournaments naming
        uint price;         // In wei
        uint teamSize;
        uint maxTeams;
        uint teams;
        uint regs_startAt;
        uint regs_endAt;
        uint startsAt;
        uint endsAt;
        uint poolPerUser;   // In wei
        uint prizePool;     // Includes all fees
        uint totalScore;
        uint winner;
        uint leaguePoints;  // Sponsor League Points
        TourneyStatus status;
    }

    event TourneyCreated(uint _id, uint _secondIndex, uint _game, uint _price, uint _teamSize, uint _maxTeams, uint _regs_startAt, uint _regs_endAt, uint _startsAt,  uint _endsAt, uint _leaguePoints, uint _poolPerUser);
    event TourneyUpdated(uint _id, uint _secondIndex, uint _game, uint _price, uint _teamSize, uint _maxTeams, uint _regs_startAt, uint _regs_endAt, uint _startsAt,  uint _endsAt, uint _poolPerUser);
    event TourneyPaused(uint _id);
    event TourneyUnpaused(uint _id);
    event Registered(uint _tourneyId, uint _teamId, string _name, address indexed _sponsor, address[] _gamers, uint _dfsgAmount);
    event Invited(uint _tourneyId, uint _teamId, string _name, address indexed _sponsor, address indexed _gamer);
    event FeesUpdated(uint _poolFee, uint _liquidityFee, uint _teamFee, uint _burnFee, uint _extraFee);
    event FeeAddressesUpdated(address _teamAddress, address _burnAddress, address _extraAddress);
    event ScoresSet(uint _tourneyId, uint[] _teamIds, uint[] _scores, uint[] _positions);
    event RewardsSent(uint _tourneyId);

    constructor(){
        WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        DFSG = IERC20(0x612C49b95c9121107BE3A2FE1fcF1eFC1C4730AD);
        DFSG_Oracle = Oracle(0x0490CC13f9bADbA4c390f4C7A2cd9465FeFa153E);
        ROUTER = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        teamAddress = 0xE4e5838fF470D50739D94E100aeAe20F76aBcaF2;
        extraAddress = 0xE4e5838fF470D50739D94E100aeAe20F76aBcaF2;
        burnAddress = 0x000000000000000000000000000000000000dEaD;
        leagueAddress = 0xfa6124D12a6e673B9d9aF6Cf8d81c8Be7d8E2b08;
        multiplierAddress = 0xEdC788C608e9233CCCBe4b4F0e1e496F8F544FEB;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(REFEREE_ROLE, msg.sender);
    }

    receive() external payable{}

    function createTourney(
        uint _game, 
        uint _secondIndex,
        uint _price,
        uint _teamSize, 
        uint _maxTeams, 
        uint _regs_startAt, 
        uint _regs_endAt, 
        uint _startsAt,
        uint _endsAt,  
        uint _poolPerUser,
        uint _leaguePoints
    ) external onlyRole(DEFAULT_ADMIN_ROLE) { // EDITED

        require(_teamSize > 0, "Team size cannot be zero");

        require(_maxTeams > 0, "Max teams cannot be zero");

        require(
            _regs_startAt < _regs_endAt && _regs_endAt < _startsAt && _startsAt <= _endsAt,
            "Check dates inputs"
        );

        tourneysCount.increment();
        uint new_id = tourneysCount.current();

        _tourneysInfo[new_id] = Tourney({

            id: new_id,
            game: _game,
            secondIndex : _secondIndex,
            price: _price,
            teamSize: _teamSize,
            maxTeams: _maxTeams,
            teams: 0,
            regs_startAt: _regs_startAt,
            regs_endAt: _regs_endAt,
            startsAt: _startsAt,
            endsAt: _endsAt,
            poolPerUser: _poolPerUser,
            prizePool: 0,
            totalScore: 0,
            winner: 0,
            leaguePoints: _leaguePoints,
            status: TourneyStatus.Active

        });

        emit TourneyCreated(new_id, _secondIndex, _game, _price, _teamSize, _maxTeams, _regs_startAt, _regs_endAt, _startsAt, _endsAt, _leaguePoints, _poolPerUser);

    }

    function updateTourney(uint _id, uint _game, uint _secondIndex, uint _price, uint _teamSize, uint _maxTeams, uint _regs_startAt, uint _regs_endAt, uint _startsAt, uint _endsAt, uint _poolPerUser) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(_teamSize > 0, "Team size cannot be zero");

        require(_maxTeams > 0, "Max teams cannot be zero");

        require(
            _regs_startAt < _regs_endAt && _regs_endAt < _startsAt && _startsAt <= _endsAt,
            "Check dates inputs"
        );

        require(_id > 0 && _id <= tourneysCount.current(), "Tourney does not exist");

        Tourney memory tourney = _tourneysInfo[_id];

        require(tourney.status == TourneyStatus.Active , "Tourney already finished");
        require(block.timestamp < tourney.regs_startAt, "Can only be updated before registrations start");

        _tourneysInfo[_id].game = _game;
        _tourneysInfo[_id].secondIndex = _secondIndex;
        _tourneysInfo[_id].price = _price;
        _tourneysInfo[_id].teamSize = _teamSize;
        _tourneysInfo[_id].maxTeams = _maxTeams;
        _tourneysInfo[_id].regs_startAt = _regs_startAt;
        _tourneysInfo[_id].regs_endAt = _regs_endAt;
        _tourneysInfo[_id].startsAt = _startsAt;
        _tourneysInfo[_id].regs_endAt = _endsAt;
        _tourneysInfo[_id].poolPerUser = _poolPerUser;

        emit TourneyUpdated(_id, _secondIndex, _game, _price, _teamSize, _maxTeams, _regs_startAt, _regs_endAt, _startsAt, _endsAt, _poolPerUser);

    }

    function pauseTourney(uint _id) external onlyRole(DEFAULT_ADMIN_ROLE){

        require(_id > 0 && _id <= tourneysCount.current(), "Tourney does not exist");

        Tourney memory tourney = _tourneysInfo[_id];

        require(tourney.status == TourneyStatus.Active , "Tourney already finished");

        _tourneysInfo[_id].status = TourneyStatus.Paused;

        emit TourneyPaused(_id);
    }

    function unpauseTourney(uint _id) external onlyRole(DEFAULT_ADMIN_ROLE){

        require(_id > 0 && _id <= tourneysCount.current(), "Tourney does not exist");

        Tourney memory tourney = _tourneysInfo[_id];

        require(tourney.status == TourneyStatus.Paused , "Tourney not paused");

        _tourneysInfo[_id].status = TourneyStatus.Active;

        emit TourneyUnpaused(_id);
    }

    /* Tourney registration */
    function register(uint _tourneyId , address[] calldata _gamers, string calldata _name, uint option) external payable nonReentrant{

        require(option > 0 && option < 4, "Invalid option");
        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");

        if(option != 2) require(msg.value == 0, "Invalid option for BNB");

        Tourney storage tourney = _tourneysInfo[_tourneyId];

        require(block.timestamp > tourney.regs_startAt && block.timestamp < tourney.regs_endAt, "Registrations are closed");
        require(tourney.status == TourneyStatus.Active, "Tourney is paused");
        require(_gamers.length == tourney.teamSize, "Team size not valid");
        require(tourney.teams < tourney.maxTeams, "Tourney is full");

        uint amountUSDT = _sponsoredTeams[msg.sender][_tourneyId].length() > 1 ? (tourney.price.div(2)) : tourney.price;

        uint dfsgAmount = 0;
        if(!hasRole(REFEREE_ROLE, msg.sender)){
            //1 -> DFSG, 2 -> BNB, 3 -> USDT

            uint DFSG_price = DFSG_Oracle.getPrice();
            dfsgAmount = (amountUSDT.mul(1e18)).div(DFSG_price);
            if(option == 1){
                require(DFSG.transferFrom(msg.sender, address(this), dfsgAmount), "Error receiving DFSG from user");
            } 
            else if(option == 3){
                require(USDT.transferFrom(msg.sender, address(this), amountUSDT), "Error receiving USDT from user");
                USDT.approve(address(ROUTER), amountUSDT);
                uint[] memory amounts = ROUTER.swapExactTokensForTokens(
                    amountUSDT,
                    0,
                    getPath(address(USDT), address(DFSG)),
                    address(this),
                    block.timestamp
                );
                dfsgAmount = amounts[amounts.length.sub(1)];
            } else{
                uint userBNB = ROUTER.getAmountsIn(dfsgAmount, getPath(address(WBNB), address(DFSG)))[0];
                IWETH(address(WBNB)).deposit{value: userBNB}();
                WBNB.approve(address(ROUTER), userBNB);
                uint[] memory amounts = ROUTER.swapTokensForExactTokens(
                    dfsgAmount,
                    userBNB,
                    getPath(address(WBNB), address(DFSG)),
                    address(this),
                    block.timestamp
                );
                dfsgAmount = amounts[amounts.length.sub(1)];
                if(msg.value > userBNB) payable(msg.sender).transfer(msg.value.sub(userBNB));
            } 
            tourney.prizePool = tourney.prizePool.add(dfsgAmount);
        }
        
        tourney.prizePool = tourney.prizePool.add(tourney.poolPerUser);

        teamsCount.increment();
        tourney.teams = tourney.teams.add(1);

        uint teamId = teamsCount.current();

        _teamInfo[teamId] = Team({
            name: _name,
            sponsor: msg.sender,
            gamers: _gamers,
            position: 0,
            score: 0,
            teamRewards: 0
        });

        _tourneyTeams[_tourneyId].add(teamId);

        for(uint i = 0; i < _gamers.length; i = i.add(1)){
            
            //Check if gamer is already registered
            require(!_gamerTourneys[_gamers[i]].contains(_tourneyId), "Gamer already registered");
            
            //Update gamer tourneys & teams
            _gamerTourneys[_gamers[i]].add(_tourneyId);
            _gamerTeams[_gamers[i]][_tourneyId] = teamId;
        }

        //Update sponsor teams, count and tourneys
        _sponsoredTeams[msg.sender][_tourneyId].add(teamId);
        _sponsoredCount[msg.sender] = _sponsoredCount[msg.sender].add(1);

        //If it is the first sponsor team for this tourney, add tourney to sponsor tourneys
        if(!_sponsorTourneys[msg.sender].contains(_tourneyId)){
            _sponsorTourneys[msg.sender].add(_tourneyId);
        }

        SponsorLeague(leagueAddress).addPoints(msg.sender, tourney.leaguePoints);

        emit Registered(_tourneyId, teamId, _name, msg.sender, _gamers, dfsgAmount);
    }

    /* Tourney invitation */
    function invite(uint _tourneyId , address[] calldata _gamers, string[] calldata _name) external onlyRole(DEFAULT_ADMIN_ROLE){

        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");

        Tourney storage tourney = _tourneysInfo[_tourneyId];
        address[] memory current_gamer = new address[](1);
        
        for(uint i = 0; i < _gamers.length; i = i.add(1)){
            tourney.prizePool = tourney.prizePool.add(tourney.poolPerUser);

            teamsCount.increment();
            tourney.teams = tourney.teams.add(1);

            uint teamId = teamsCount.current();
            
            current_gamer[0] = _gamers[i];

            _teamInfo[teamId] = Team({
                name: _name[i],
                sponsor: _gamers[i],
                gamers: current_gamer,
                position: 0,
                score: 0,
                teamRewards: 0
            });

            _tourneyTeams[_tourneyId].add(teamId);
                
            require(!_gamerTourneys[_gamers[i]].contains(_tourneyId), "Gamer already registered");
                
            _gamerTourneys[_gamers[i]].add(_tourneyId);
            _gamerTeams[_gamers[i]][_tourneyId] = teamId;
            
            _sponsoredTeams[_gamers[i]][_tourneyId].add(teamId);
            _sponsoredCount[_gamers[i]] = _sponsoredCount[msg.sender].add(1);

            if(!_sponsorTourneys[_gamers[i]].contains(_tourneyId)){
                _sponsorTourneys[_gamers[i]].add(_tourneyId);
            }

            SponsorLeague(leagueAddress).addPoints(_gamers[i], tourney.leaguePoints);
            emit Invited(_tourneyId, teamId, _name[i], _gamers[i], _gamers[i]);
        }

        
    }

    /* Set tourney scores */
    function setScores(uint _tourneyId, uint[] calldata _teamIds, uint[] calldata _scores, uint[] calldata _positions) external onlyRole(DEFAULT_ADMIN_ROLE){
        
        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");

        uint length = _teamIds.length;
        require(length == _scores.length && length == _positions.length, "Invalid inputs");

        require(block.timestamp > _tourneysInfo[_tourneyId].endsAt, "Cannot set scores yet");
        require(_tourneysInfo[_tourneyId].winner == 0, "Scores already set");

        uint tourneyScore;
        for(uint i = 0; i < length; i = i.add(1)){

            require(_tourneyTeams[_tourneyId].contains(_teamIds[i]), "Team not registered");

            tourneyScore = tourneyScore.add(_scores[i]);
            _teamInfo[_teamIds[i]].score = _scores[i];
            _teamInfo[_teamIds[i]].position = _positions[i];

            address sponsor = _teamInfo[_teamIds[i]].sponsor;
            if(_positions[i] == 1){
                _tourneysInfo[_tourneyId].winner = _teamIds[i];
                SponsorLeague(leagueAddress).addPoints(sponsor, 25);
            }else if(_positions[i] == 2){
                SponsorLeague(leagueAddress).addPoints(sponsor, 20);
            }else if(_positions[i] == 3){
                SponsorLeague(leagueAddress).addPoints(sponsor, 15);
            } 

        }

        _tourneysInfo[_tourneyId].totalScore = tourneyScore;
        emit ScoresSet(_tourneyId, _teamIds, _scores, _positions);
    }

    /* Send rewards to winners, fees and adds liquidity */
    function sendRewards(uint _tourneyId) external onlyRole(DEFAULT_ADMIN_ROLE){

        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");
        
        Tourney memory tourney = _tourneysInfo[_tourneyId];

        require(tourney.winner != 0, "Set scores first");

        require(tourney.status == TourneyStatus.Active, "Rewards already sent");

        _tourneysInfo[_tourneyId].status = TourneyStatus.Finished;

        EnumerableSet.UintSet storage teamsId = _tourneyTeams[_tourneyId];

        uint totalScore = _tourneysInfo[_tourneyId].totalScore;
        uint teamSize = _tourneysInfo[_tourneyId].teamSize;
        uint prizePool = tourney.prizePool.sub(tourney.poolPerUser.mul(tourney.teams));
        uint poolAmount = prizePool.mul(poolFee).div(10000).add(tourney.poolPerUser.mul(tourney.teams));
        //uint length = teamsId.length();

        uint share; 
        uint _reward; 
        uint _rSponsor; 
        uint _rGamer; 
        address sponsor; 
        address gamer;
        uint multiplier_NFT;

        for(uint i = 0; i < teamsId.length(); i = i.add(1)){

            uint teamId = teamsId.at(i);

            if(_teamInfo[teamId].score > 0){
                share = (_teamInfo[teamId].score).mul(1e18).div(totalScore);
                _reward = share.mul(poolAmount).div(1e18);
                multiplier_NFT = Multiplier(multiplierAddress).getMultiplier(sponsor);
                if(multiplier_NFT > 100){
                    _reward = _reward.mul(multiplier_NFT).div(100);
                }
                
                if(_reward > 0){
                    _rSponsor = _reward.mul(60).div(100);
                    _rGamer = (_reward.sub(_rSponsor)).div(teamSize);

                    _teamInfo[teamId].teamRewards = _reward;

                    sponsor = _teamInfo[teamId].sponsor;
                    
                    

                    _sponsorRewards[sponsor] = _sponsorRewards[sponsor].add(_rSponsor);
                    require(DFSG.transfer(sponsor, _rSponsor), "Error transferring to sponsor");

                    for(uint j = 0; j < teamSize; j = j.add(1)){
                        gamer = _teamInfo[teamId].gamers[j];
                        _gamerRewards[gamer] = _gamerRewards[gamer].add(_rGamer);
                        require(DFSG.transfer(gamer, _rGamer), "Error transferring to gamer");
                    }
                }
            }
        }
        
        //Fee transfers
        require(DFSG.transfer(burnAddress, prizePool.mul(burnFee).div(10000)), "Error transferring to dead address");
        require(DFSG.transfer(teamAddress, prizePool.mul(teamFee).div(10000)), "Error transferring to team address");
        require(DFSG.transfer(extraAddress, prizePool.mul(extraFee).div(10000)), "Error transferring to extra address");

        //Add liquidity
        addLiquidity(prizePool.mul(liquidityFee).div(10000));

        emit RewardsSent(_tourneyId);
    }

    /* Swaps DFSG to BNB, and adds liquidity */
    function addLiquidity(uint _dfsgAmount) internal {
        uint dividedAmount = _dfsgAmount.div(2);
        DFSG.approve(address(ROUTER), _dfsgAmount);

        uint[] memory amounts = ROUTER.swapExactTokensForETH(
            dividedAmount,
            0,
            getPath(address(DFSG), address(WBNB)),
            address(this),
            block.timestamp
        );  

        ROUTER.addLiquidityETH{value: amounts[amounts.length.sub(1)]}(
            address(DFSG),
            dividedAmount,
            0,
            0,
            burnAddress,
            block.timestamp
        );
    }

    /* Update fees */
    function setFees(uint _poolFee, uint _liquidityFee, uint _teamFee, uint _burnFee, uint _extraFee) external onlyRole(DEFAULT_ADMIN_ROLE){
        poolFee = _poolFee;
        liquidityFee = _liquidityFee;
        teamFee = _teamFee;
        burnFee = _burnFee;
        extraFee = _extraFee;

        emit FeesUpdated(_poolFee, _liquidityFee, _teamFee, _burnFee, _extraFee);
    }

    /* Update fee addresses */
    function setFeeAddresses(address _teamAddress, address _burnAddress, address _extraAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        teamAddress = _teamAddress;
        burnAddress = _burnAddress;
        extraAddress = _extraAddress;

        emit FeeAddressesUpdated(_teamAddress, _burnAddress, _extraAddress);
    }

    /* Update Sponsor League addresses */
    function setSponsorLeagueAddress(address _new) external onlyRole(DEFAULT_ADMIN_ROLE){
        leagueAddress = _new;
    }

    /* Update Sponsor League addresses */
    function setMultiplierAddress(address _new) external onlyRole(DEFAULT_ADMIN_ROLE){
        multiplierAddress = _new;
    }

    /* Update router address */
    function setRouter(IPancakeRouter _router) external onlyRole(DEFAULT_ADMIN_ROLE){
        ROUTER = _router;
    }

    /* Update oracle address */
    function setOracle(address _new) external onlyRole(DEFAULT_ADMIN_ROLE){
        DFSG_Oracle = Oracle(_new);
    }

    /* Aux function for router functions */
    function getPath(address _tokenIn, address _tokenOut) internal view returns(address[] memory path){

        if(_tokenIn != address(WBNB) && _tokenOut != address(WBNB)){
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = address(WBNB);
            path[2] = _tokenOut;
        } else{
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        }

        return path;
    }

    /* Check if address is gamer */
    function isGamer(address _gamer) public view returns(bool){
        return _gamerTourneys[_gamer].length() > 0;
    }

    /* Check if address is sponsor */
    function isSponsor(address _sponsor) public view returns(bool){
        return _sponsoredCount[_sponsor] > 0;
    }


    /* TOURNEY GETTERS */

    /* Check if gamer is registered in tourney */
    function isRegistered(uint _tourneyId, address _gamer) external view returns(bool){
        return _gamerTourneys[_gamer].contains(_tourneyId);
    }

    /* Get tourney struct */
    function getTourneyInfo(uint _tourneyId) external view returns (Tourney memory) {

        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");

        return _tourneysInfo[_tourneyId];
    }

    /* Get teams (ids) from tourney */
    function getTourneyTeams(uint _tourneyId, uint pointer, uint size) external view returns(uint[] memory teamsId, uint){
        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");
        
        uint length = size;
        if(size > _tourneyTeams[_tourneyId].length() - pointer){
            length = _tourneyTeams[_tourneyId].length() - pointer;
        }

        teamsId = new uint[](length);

        for(uint i = 0; i < length; i = i.add(1)){
            teamsId[i] = _tourneyTeams[_tourneyId].at(pointer.add(i));
        }

        return (teamsId, pointer.add(length));
    }

    /* Get prizepool and fee amounts */
    function getTourneyAmounts(uint _tourneyId) external view returns(uint poolAmount, uint burnAmount, uint teamAmount, uint liquidityAmount, uint extraAmount){
        require(_tourneyId > 0 && _tourneyId <= tourneysCount.current(), "Tourney does not exist");

        Tourney memory tourney = _tourneysInfo[_tourneyId];

        uint prizePool = tourney.prizePool.sub(tourney.poolPerUser.mul(tourney.teams));

        poolAmount = prizePool.mul(poolFee).div(10000).add(tourney.poolPerUser.mul(tourney.teams));
        burnAmount = prizePool.mul(burnFee).div(10000);
        teamAmount = prizePool.mul(teamFee).div(10000);
        liquidityAmount = prizePool.mul(liquidityFee).div(10000);
        extraAmount = prizePool.mul(extraFee).div(10000);

        return(poolAmount, burnAmount, teamAmount, liquidityAmount, extraAmount);
    }


    /* GAMER GETTERS */

    /* Get overall stats */
    function getStatsFromGamer(address _gamer) external view returns(uint tourneys, uint rewards){

        require(isGamer(_gamer), "Address is not a gamer");
        
        tourneys = _gamerTourneys[_gamer].length();
        rewards = _gamerRewards[_gamer];

        return(tourneys, rewards);
    }

    /* SPONSOR GETTERS */

    /* Get overall stats */
    function getStatsFromSponsor(address _sponsor) external view returns(uint tourneys, uint sponsored, uint rewards){

        require(isSponsor(_sponsor), "Address is not a sponsor");

        tourneys = _sponsorTourneys[_sponsor].length();
        sponsored = _sponsoredCount[_sponsor];
        rewards = _sponsorRewards[_sponsor];

        return(tourneys, sponsored, rewards);
    }

    /* Get teams (ids) sponsored in tourney */
    function getSponsoredTeamsForTourney(uint _tourneyId, address _sponsor, uint pointer, uint size) 
        external 
        view 
        returns (
            uint[] memory teamsId,
            Team[] memory teams,
            uint 
        )
    {

        uint length = size;
        if(size > _sponsoredTeams[_sponsor][_tourneyId].length() - pointer){
            length =_sponsoredTeams[_sponsor][_tourneyId].length() - pointer;
        }

        teamsId = new uint[](length);
        teams = new Team[](length);

        for(uint i = 0; i < length; i = i.add(1)){
            uint _teamId = _sponsoredTeams[_sponsor][_tourneyId].at(pointer.add(i));
            teamsId[i] = _teamId;
            teams[i] = _teamInfo[_teamId];
        }

        return(teamsId, teams, pointer.add(length));
    }

    /* Get gamer teams */
    function getGamerTeams(address _gamer, uint pointer, uint size) external view returns(uint[] memory _teamsId, uint){

        uint length = size;
        if(size >  _gamerTourneys[_gamer].length() - pointer){
            length = _gamerTourneys[_gamer].length() - pointer;
        }

        _teamsId = new uint[](length);

        for(uint i = 0; i < length; i = i.add(1)){
            _teamsId[i] = _gamerTeams[_gamer][_gamerTourneys[_gamer].at(pointer.add(i))];
        }

        return (_teamsId, pointer.add(length));
    }


    /* TEAM GETTER */

    /* Get team struct */
    function getTeam(uint _teamId) external view returns(string memory, address, address[] memory, uint, uint, uint){
        require(_teamId > 0 && _teamId <= teamsCount.current(), "Team does not exist");

        return (
            _teamInfo[_teamId].name,
            _teamInfo[_teamId].sponsor,
            _teamInfo[_teamId].gamers,
            _teamInfo[_teamId].position,
            _teamInfo[_teamId].score,
            _teamInfo[_teamId].teamRewards
        );
    }


}