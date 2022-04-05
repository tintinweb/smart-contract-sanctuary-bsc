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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import {IReferral} from "./IReferral.sol";

// import "hardhat/console.sol";

/// @title BetSwirl's Bank
/// @author Romuald Hog
/// @notice The Bank contract holds the casino's funds,
/// whitelist the games betting tokens,
/// define the max bet amount based on a risk,
/// payout the bet profit to user and collect the loss bet amount from the game's contract,
/// split and allocate the house edge taken from each bet (won or loss),
/// manage the tokens balance overflow to dynamically send overflowed tokens to the treasury and team.
/// The admin role is transfered to a Timelock that execute administrative tasks,
/// only the Games could payout the bet profit from the bank, and send the loss bet amount to the bank.
/// @dev All rates are in basis point.
contract Bank is AccessControl {
    using SafeERC20 for IERC20;

    /// @notice Token's house edge allocations struct.
    /// The games house edge is split into several allocations.
    /// The allocated amounts stays in the bank until authorized parties withdraw. They are subtracted from the balance.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param referral Rate to be allocated to the referrers, on bet payout.
    /// @param treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    /// @param dividendAmount The number of tokens to be sent as staking rewards.
    /// @param treasuryAmount The number of tokens to be sent to the treasury.
    /// @param teamAmount The number of tokens to be sent to the team.
    struct HouseEdgeSplit {
        uint16 dividend;
        uint16 referral;
        uint16 treasury;
        uint16 team;
        uint256 dividendAmount;
        uint256 treasuryAmount;
        uint256 teamAmount;
    }

    /// @notice Token's balance overflow struct.
    /// @param thresholdRate Threshold rate for the token's balance reference.
    /// @param toTreasury Rate to be allocated to the treasury.
    /// @param toTeam Rate to be allocated to the team.
    struct BalanceOverflow {
        uint16 thresholdRate;
        uint16 toTreasury;
        uint16 toTeam;
    }

    /// @notice Token struct.
    /// List of tokens to bet on games.
    /// @param allowed Whether the token is allowed for bets.
    /// @param houseEdgeSplit House edge allocations.
    /// @param balanceReference Balance reference used to manage the bank overflow.
    /// @param balanceOverflow Balance overflow management configuration.
    struct Token {
        bool allowed;
        HouseEdgeSplit houseEdgeSplit;
        uint256 balanceReference;
        BalanceOverflow balanceOverflow;
    }

    /// @notice Token's metadata struct. It contains additional information from the ERC20 token.
    /// @dev Only used on the `getTokens` getter for the front-end.
    /// @param decimals Number of token's decimals.
    /// @param tokenAddress Contract address of the token.
    /// @param name Name of the token.
    /// @param symbol Symbol of the token.
    /// @param token Token data.
    struct TokenMetadata {
        uint8 decimals;
        address tokenAddress;
        string name;
        string symbol;
        Token token;
    }

    /// @notice Defines the maximum bank payout, used to calculate the max bet amount.
    uint16 public balanceRisk = 200;

    /// @notice Number of tokens added.
    uint16 public tokensCount;

    /// @notice Treasury multi-sig wallet.
    address payable public immutable treasury;

    /// @notice Team wallet.
    address payable public teamWallet;

    /// @notice Referral program contract.
    IReferral public referralProgram;

    /// @notice Role associated to Games smart contracts.
    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");

    /// @notice Role associated to SwirlMaster smart contract.
    bytes32 public constant SWIRLMASTER_ROLE = keccak256("SWIRLMASTER_ROLE");

    /// @notice Maps tokens addresses to token configuration.
    mapping(address => Token) public tokens;

    /// @notice Maps tokens indexes to token address.
    mapping(uint16 => address) public tokensList;

    /// @notice Emitted after the team wallet is set.
    /// @param teamWallet The team wallet address.
    event SetTeamWallet(address teamWallet);

    /// @notice Emitted after the referral program is set.
    /// @param referralProgram The referral program address.
    event SetReferralProgram(address referralProgram);

    /// @notice Emitted after the balance risk is set.
    /// @param balanceRisk Rate defining the balance risk.
    event SetBalanceRisk(uint16 balanceRisk);

    /// @notice Emitted after a token is added.
    /// @param token Address of the token.
    event AddToken(address token);

    /// @notice Emitted after a token is allowed.
    /// @param token Address of the token.
    /// @param allowed Whether the token is allowed for betting.
    event SetAllowedToken(address indexed token, bool allowed);

    /// @notice Emitted after a token deposit.
    /// @param token Address of the token.
    /// @param amount The number of token deposited.
    event Deposit(address indexed token, uint256 amount);

    /// @notice Emitted after a token withdrawal.
    /// @param token Address of the token.
    /// @param amount The number of token withdrawn.
    event Withdraw(address indexed token, uint256 amount);

    /// @notice Emitted after the token's house edge allocations for bet payout is set.
    /// @param token Address of the token.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param referral Rate to be allocated to the referrers, on bet payout.
    /// @param treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    event SetTokenHouseEdgeSplit(
        address indexed token,
        uint16 dividend,
        uint16 referral,
        uint16 treasury,
        uint16 team
    );

    /// @notice Emitted after the token's treasury and team allocations are distributed.
    /// @param token Address of the token.
    /// @param treasuryAmount The number of tokens sent to the treasury.
    /// @param teamAmount The number of tokens sent to the team.
    event HouseEdgeDistribution(
        address indexed token,
        uint256 treasuryAmount,
        uint256 teamAmount
    );

    /// @notice Emitted after the token's dividend allocation is distributed.
    /// @param token Address of the token.
    /// @param amount The number of tokens sent to the SwirlMaster.
    event HarvestDividend(address indexed token, uint256 amount);

    /// @notice Emitted after the token's balance overflow management configuration is set.
    /// @param token Address of the token.
    /// @param thresholdRate Threshold rate for the token's balance reference.
    /// @param toTreasury Rate to be allocated to the treasury.
    /// @param toTeam Rate to be allocated to the team.
    event SetBalanceOverflow(
        address indexed token,
        uint16 thresholdRate,
        uint16 toTreasury,
        uint16 toTeam
    );

    /// @notice Emitted after the token's bank overflow amount is distributed to the treasury and team.
    /// @param token Address of the token.
    /// @param amountToTreasury The number of tokens sent to the treasury.
    /// @param amountToTeam The number of tokens sent to the team.
    event BankOverflowTransfer(
        address indexed token,
        uint256 amountToTreasury,
        uint256 amountToTeam
    );

    /// @notice Emitted after the token's balance reference is set.
    /// This happends on deposit, withdraw and when the bank overflow threashold is reached.
    /// @param token Address of the token.
    /// @param balanceReference New balance reference used to determine the bank overflow.
    event SetBalanceReference(address indexed token, uint256 balanceReference);

    /// @notice Emitted after the token's house edge is allocated.
    /// @param token Address of the token.
    /// @param dividend The number of tokens allocated as staking rewards.
    /// @param referral The number of tokens allocated to the referrers.
    /// @param treasury The number of tokens allocated to the treasury.
    /// @param team The number of tokens allocated to the team.
    event AllocateHouseEdgeAmount(
        address indexed token,
        uint256 dividend,
        uint256 referral,
        uint256 treasury,
        uint256 team
    );

    /// @notice Emitted after the bet profit amount is sent to the user.
    /// @param token Address of the token.
    /// @param newBalance New token balance.
    /// @param profit Bet profit amount sent.
    event Payout(address indexed token, uint256 newBalance, uint256 profit);

    /// @notice Emitted after the bet amount is collected from the game smart contract.
    /// @param token Address of the token.
    /// @param newBalance New token balance.
    /// @param amount Bet amount collected.
    event CashIn(address indexed token, uint256 newBalance, uint256 amount);

    /// @notice Reverting error when trying to add an existing token.
    /// @param token Address of the token.
    error TokenExists(address token);
    /// @notice Reverting error when setting the house edge allocations, but the sum isn't 100%.
    /// @param splitSum Sum of the house edge allocations rates.
    error WrongHouseEdgeSplit(uint16 splitSum);
    /// @notice Reverting error when setting wrong balance overflow management configuration.
    error WrongBalanceOverflow();

    /// @notice Initialize the contract's admin role to the deployer, and state variables.
    /// @param treasuryAddress Treasury multi-sig wallet.
    /// @param teamWalletAddress Team wallet.
    constructor(
        address payable treasuryAddress,
        address payable teamWalletAddress,
        IReferral referralProgramAddress
    ) {
        // The ownership should then be transfered to the Timelock.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        treasury = treasuryAddress;
        setTeamWallet(teamWalletAddress);
        setReferralProgram(referralProgramAddress);
    }

    /// @notice Transfers a specific amount of token to an address.
    /// Uses native transfer or ERC20 transfer depending on the token.
    /// @dev The 0x address is considered the gas token.
    /// @param user Address of destination.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function _safeTransfer(
        address payable user,
        address token,
        uint256 amount
    ) private {
        if (_isGasToken(token)) {
            Address.sendValue(user, amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    /// @notice Splits the house edge fees and allocates them as dividends, for referrers, to the treasury and team.
    /// If the user has no referrer, the referral allocation is allocated evenly among the other allocations.
    /// @param user Address of the gamer.
    /// @param token Address of the token.
    /// @param fees Bet amount or bet profit fees.
    /// @param tokenHouseEdge To update the house edge allocations amounts.
    /// @param dividend Rate to be allocated as staking rewards.
    /// @param referral Rate to be allocated to the referrers.
    /// @param _treasury Rate to be allocated to the treasury.
    /// @param team Rate to be allocated to the team.
    function _allocateHouseEdge(
        address user,
        address token,
        uint256 fees,
        HouseEdgeSplit storage tokenHouseEdge,
        uint16 dividend,
        uint16 referral,
        uint16 _treasury,
        uint16 team
    ) private {
        uint256 referralAllocation = (fees * referral) / 10000;
        uint256 referralAmount;
        if (referralAllocation != 0 && address(referralProgram) != address(0)) {
            referralAmount = referralProgram.payReferral(
                user,
                token,
                referralAllocation
            );
            referralAllocation -= referralAmount;
        }

        uint256 referralAllocationRestPerSplit = (referralAllocation -
            (referralAllocation % 3)) / 3;
        uint256 dividendAmount = ((fees * dividend) / 10000) +
            referralAllocationRestPerSplit;
        uint256 treasuryAmount = ((fees * _treasury) / 10000) +
            referralAllocationRestPerSplit;
        uint256 teamAmount = ((fees * team) / 10000) +
            referralAllocationRestPerSplit;

        tokenHouseEdge.dividendAmount += dividendAmount;
        tokenHouseEdge.treasuryAmount += treasuryAmount;
        tokenHouseEdge.teamAmount += teamAmount;

        emit AllocateHouseEdgeAmount(
            token,
            dividendAmount,
            referralAmount,
            treasuryAmount,
            teamAmount
        );

        if (referralAmount != 0) {
            _safeTransfer(
                payable(address(referralProgram)),
                token,
                referralAmount
            );
        }
    }

    /// @notice Manages the balance overflow.
    /// When the bank overflow threshold amount is reached on a token balance,
    /// the bank sends a percentage to the treasury and team, and the new token's balance reference is set.
    /// @param tokenAddress Address of the token.
    function _manageBalanceOverflow(address tokenAddress) private {
        Token storage token = tokens[tokenAddress];

        uint256 tokenBalance = getBalance(tokenAddress);
        BalanceOverflow memory balanceOverflow = token.balanceOverflow;
        uint256 overflow = (token.balanceReference +
            ((tokenBalance * balanceOverflow.thresholdRate) / 10000));
        if (tokenBalance > overflow) {
            uint256 diff = tokenBalance - token.balanceReference;
            uint256 overflowAmountToTreasury = ((diff *
                balanceOverflow.toTreasury) / 10000);
            uint256 overflowAmountToTeam = ((diff * balanceOverflow.toTeam) /
                10000);
            _setBalanceReference(
                tokenAddress,
                tokenBalance - overflowAmountToTreasury - overflowAmountToTeam
            );

            uint256 treasuryAmount = token.houseEdgeSplit.treasuryAmount;
            uint256 teamAmount = token.houseEdgeSplit.teamAmount;
            token.houseEdgeSplit.treasuryAmount = 0;
            token.houseEdgeSplit.teamAmount = 0;

            _safeTransfer(
                treasury,
                tokenAddress,
                treasuryAmount + overflowAmountToTreasury
            );
            _safeTransfer(
                teamWallet,
                tokenAddress,
                teamAmount + overflowAmountToTeam
            );
            emit BankOverflowTransfer(
                tokenAddress,
                treasuryAmount + overflowAmountToTreasury,
                teamAmount + overflowAmountToTeam
            );
        }
    }

    /// @notice Sets the new token's balance reference.
    /// @param token Address of the token.
    /// @param newReference Balance amount corresponding to the new reference.
    function _setBalanceReference(address token, uint256 newReference) private {
        tokens[token].balanceReference = newReference;
        emit SetBalanceReference(token, newReference);
    }

    /// @notice Check if the token has the 0x address.
    /// @param token Address of the token.
    /// @return Whether the token's address is the 0x address.
    function _isGasToken(address token) private pure returns (bool) {
        return token == address(0);
    }

    /// @notice Deposit funds in the bank to allow gamers to win more.
    /// It is also setting the new balance reference, used to manage the bank overflow.
    /// ERC20 token allowance should be given prior to deposit.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function deposit(address token, uint256 amount)
        external
        payable
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 balance = getBalance(token);
        if (_isGasToken(token)) {
            _setBalanceReference(token, balance);
            amount = msg.value;
        } else {
            _setBalanceReference(token, balance + amount);
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
        emit Deposit(token, amount);
    }

    /// @notice Withdraw funds from the bank to migrate.
    /// It is also setting the new balance reference, used to manage the bank overflow.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function withdraw(address token, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setBalanceReference(token, getBalance(token) - amount);
        _safeTransfer(payable(msg.sender), token, amount);
        emit Withdraw(token, amount);
    }

    /// @notice Sets the new balance risk.
    /// @param _balanceRisk Risk rate.
    function setBalanceRisk(uint16 _balanceRisk)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        balanceRisk = _balanceRisk;
        emit SetBalanceRisk(_balanceRisk);
    }

    /// @notice Adds a new token that'll be enabled for the games' betting.
    /// Token shouldn't exist yet.
    /// @param token Address of the token.
    function addToken(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (tokensCount > 0) {
            for (uint16 i; i < tokensCount; i++) {
                if (tokensList[i] == token) {
                    revert TokenExists(token);
                }
            }
        }
        tokensList[tokensCount] = token;
        tokensCount += 1;
        emit AddToken(token);
    }

    /// @notice Changes the token's bet permission on an already added token.
    /// @param token Address of the token.
    /// @param allowed Whether the token is enabled for bets.
    function setAllowedToken(address token, bool allowed)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        tokens[token].allowed = allowed;
        emit SetAllowedToken(token, allowed);
    }

    /// @notice Sets the token's house edge allocations for bet payout.
    /// @param token Address of the token.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param referral Rate to be allocated to the referrers, on bet payout.
    /// @param _treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    /// @dev `dividend`, `referral`, `_treasury` and `team` rates sum must equals 10000.
    function setHouseEdgeSplit(
        address token,
        uint16 dividend,
        uint16 referral,
        uint16 _treasury,
        uint16 team
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint16 splitSum = dividend + team + _treasury + referral;
        if (splitSum != 10000) {
            revert WrongHouseEdgeSplit(splitSum);
        }

        HouseEdgeSplit storage tokenHouseEdge = tokens[token].houseEdgeSplit;
        tokenHouseEdge.dividend = dividend;
        tokenHouseEdge.referral = referral;
        tokenHouseEdge.treasury = _treasury;
        tokenHouseEdge.team = team;

        emit SetTokenHouseEdgeSplit(token, dividend, referral, _treasury, team);
    }

    /// @notice Distributes the token's treasury and team allocations amounts.
    /// @param token Address of the token.
    function distributeTokenHouseEdgeSplit(address token)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        HouseEdgeSplit storage tokenHouseEdge = tokens[token].houseEdgeSplit;
        uint256 treasuryAmount = tokenHouseEdge.treasuryAmount;
        uint256 teamAmount = tokenHouseEdge.teamAmount;
        tokenHouseEdge.treasuryAmount = 0;
        tokenHouseEdge.teamAmount = 0;
        _safeTransfer(treasury, token, treasuryAmount);
        _safeTransfer(teamWallet, token, teamAmount);
        emit HouseEdgeDistribution(token, treasuryAmount, teamAmount);
    }

    /// @notice Sets the token's balance overflow management configuration.
    /// The threshold shouldn't exceed 100% to be able to calculate the overflowed amount.
    /// The treasury and team rates sum shouldn't exceed 100% to allow the bank balance to grow organically.
    /// @param token Address of the token.
    /// @param thresholdRate Threshold rate for the token's balance reference.
    /// @param toTreasury Rate to be allocated to the treasury.
    /// @param toTeam Rate to be allocated to the team.
    function setBalanceOverflow(
        address token,
        uint16 thresholdRate,
        uint16 toTreasury,
        uint16 toTeam
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (thresholdRate > 10000 || (toTreasury + toTeam) > 10000) {
            revert WrongBalanceOverflow();
        }

        tokens[token].balanceOverflow = BalanceOverflow(
            thresholdRate,
            toTreasury,
            toTeam
        );
        emit SetBalanceOverflow(token, thresholdRate, toTreasury, toTeam);
    }

    /// @notice Harvests tokens dividends.
    /// @return The list of tokens addresses and amount harvested.
    function harvestDividends()
        external
        onlyRole(SWIRLMASTER_ROLE)
        returns (address[] memory, uint256[] memory)
    {
        address[] memory _tokens = new address[](tokensCount);
        uint256[] memory _amounts = new uint256[](tokensCount);

        for (uint16 i; i < tokensCount; i++) {
            address tokenAddress = tokensList[i];
            Token storage token = tokens[tokenAddress];
            uint256 dividendAmount = token.houseEdgeSplit.dividendAmount;
            if (dividendAmount > 0) {
                token.houseEdgeSplit.dividendAmount = 0;
                _safeTransfer(
                    payable(msg.sender),
                    tokenAddress,
                    dividendAmount
                );
                emit HarvestDividend(tokenAddress, dividendAmount);
                _tokens[i] = tokenAddress;
                _amounts[i] = dividendAmount;
            }
        }

        return (_tokens, _amounts);
    }

    /// @notice Payouts a winning bet, and allocate the house edge fee.
    /// @param user Address of the gamer.
    /// @param token Address of the token.
    /// @param profit Number of tokens to be sent to the gamer.
    /// @param fees Bet amount and bet profit fees amount.
    function payout(
        address payable user,
        address token,
        uint256 profit,
        uint256 fees
    ) external payable onlyRole(GAME_ROLE) {
        HouseEdgeSplit storage tokenHouseEdge = tokens[token].houseEdgeSplit;
        _allocateHouseEdge(
            user,
            token,
            fees,
            tokenHouseEdge,
            tokenHouseEdge.dividend,
            tokenHouseEdge.referral,
            tokenHouseEdge.treasury,
            tokenHouseEdge.team
        );

        // Pay the user
        _safeTransfer(user, token, profit);

        emit Payout(token, getBalance(token), profit);
    }

    /// @notice Accounts a loss bet, and manage the balance overflow.
    /// @dev In case of an ERC20, the bet amount should be transfered prior to this tx.
    /// @dev In case of the gas token, the bet amount is sent along with this tx.
    /// @param tokenAddress Address of the token.
    /// @param amount Loss bet amount.
    function cashIn(address tokenAddress, uint256 amount)
        external
        payable
        onlyRole(GAME_ROLE)
    {
        _manageBalanceOverflow(tokenAddress);

        emit CashIn(
            tokenAddress,
            getBalance(tokenAddress),
            _isGasToken(tokenAddress) ? msg.value : amount
        );
    }

    /// @dev For the front-end
    function getTokens() external view returns (TokenMetadata[] memory) {
        TokenMetadata[] memory _tokens = new TokenMetadata[](tokensCount);
        for (uint16 i; i < tokensCount; i++) {
            address tokenAddress = tokensList[i];
            Token memory token = tokens[tokenAddress];
            if (_isGasToken(tokenAddress)) {
                _tokens[i] = TokenMetadata({
                    decimals: 18,
                    tokenAddress: tokenAddress,
                    name: "ETH",
                    symbol: "ETH",
                    token: token
                });
            } else {
                IERC20Metadata erc20Metadata = IERC20Metadata(tokenAddress);
                _tokens[i] = TokenMetadata({
                    decimals: erc20Metadata.decimals(),
                    tokenAddress: tokenAddress,
                    name: erc20Metadata.name(),
                    symbol: erc20Metadata.symbol(),
                    token: token
                });
            }
        }
        return _tokens;
    }

    /// @notice Calculates the max bet amount based on the token balance, the balance risk, and the game multiplier.
    /// @param token Address of the token.
    /// @param multiplier The bet amount leverage determines the user's profit amount. 10000 = 100% = no profit.
    /// @return Maximum bet amount for the token.
    /// @dev The multiplier should be at least 10000.
    function getMaxBetAmount(address token, uint256 multiplier)
        external
        view
        returns (uint256)
    {
        return (getBalance(token) * balanceRisk) / multiplier;
    }

    /// @notice Gets the token's house edge allocation configuration.
    /// @param token Address of the token.
    /// @return Token's house edge allocations struct.
    function getTokenHouseEdgeSplit(address token)
        external
        view
        returns (HouseEdgeSplit memory)
    {
        return tokens[token].houseEdgeSplit;
    }

    /// @notice Gets the token's allow status used on the games smart contracts.
    /// @param token Address of the token.
    /// @return Whether the token is enabled for bets.
    function isAllowedToken(address token) external view returns (bool) {
        return tokens[token].allowed;
    }

    /// @notice Sets the new team wallet.
    /// @param _teamWallet The team wallet address.
    function setTeamWallet(address payable _teamWallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        teamWallet = _teamWallet;
        emit SetTeamWallet(teamWallet);
    }

    /// @notice Sets the new referral program.
    /// @param _referralProgram The referral program address.
    function setReferralProgram(IReferral _referralProgram)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        referralProgram = _referralProgram;
        emit SetReferralProgram(address(referralProgram));
    }

    /// @notice Gets the token's balance.
    /// The token's house edge allocation amounts are subtracted from the balance.
    /// @param token Address of the token.
    /// @return Whether the token is enabled for bets.
    function getBalance(address token) public view returns (uint256) {
        uint256 balance;
        if (_isGasToken(token)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
        HouseEdgeSplit memory tokenHouseEdgeSplit = tokens[token]
            .houseEdgeSplit;
        return
            balance -
            tokenHouseEdgeSplit.dividendAmount -
            tokenHouseEdgeSplit.treasuryAmount -
            tokenHouseEdgeSplit.teamAmount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/// @notice Referral interface
/// @author Romuald Hog.
interface IReferral {
    /// @notice Adds an address as referrer.
    /// @param user The address of the user.
    /// @param referrer The address would set as referrer of user.
    function addReferrer(address user, address referrer) external;

    /// @notice Updates referrer's last active timestamp.
    /// @param user The address would like to update active time.
    function updateReferrerActivity(address user) external;

    /// @notice Calculates and allocate referrer(s) credits to uplines.
    /// @param user Address of the gamer to find referrer(s).
    /// @param token The token to allocate.
    /// @param amount The number of tokens allocated for referrer(s).
    function payReferral(
        address user,
        address token,
        uint256 amount
    ) external returns (uint256);

    /// @notice Utils function for check whether an address has the referrer.
    /// @param user The address of the user.
    /// @return Whether user has a referrer.
    function hasReferrer(address user) external view returns (bool);
}