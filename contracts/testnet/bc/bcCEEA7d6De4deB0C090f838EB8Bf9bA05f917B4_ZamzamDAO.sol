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
// SettleMint.com
/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contcontact [email protected]
 */
pragma solidity ^0.8.9;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev External interface of ZamzamDAO declared to support ERC165 detection.
 */
interface IZamzamDAO is IAccessControl {
  struct Project {
    uint256 fundingStartTime;
    uint256 goalAmount;
    uint256 totalRaised;
    uint256 totalSpent;
    bool refundsAllowed;
    bool unpublished;
    mapping(address => uint256) donations;
  }

  /**
   * @dev Emitted when a project with projectId `projectId` is created by a call to {createProject}.
   * Its funding start time is `fundingStartTime`, goal amount is `goalAmount`.
   */
  event ProjectCreated(uint256 indexed projectId, uint256 fundingStartTime, uint256 goalAmount);

  /**
   * @dev Emitted when a project with projectId `projectId` is updated by a call to {updateProject}.
   * Its new funding start time is `fundingStartTime`, and new goal amount is `goalAmount`.
   */
  event ProjectUpdated(uint256 indexed projectId, uint256 fundingStartTime, uint256 goalAmount);

  /**
   * @dev Emitted when a donation is made to projectId `projectId` by a donor `donor` by calling {donate}.
   * `tokenAmount` is the amount of tokens donated.
   */
  event Donation(uint256 indexed projectId, address indexed donor, uint256 tokenAmount);

  /**
   * @dev Emitted when funds are released from project `projectId` by calling {releaseFunds}.
   * `tokenAmount` Zamzam tokens are released to `receiver`.
   */
  event FundsReleased(uint256 indexed projectId, uint256 tokenAmount, address receiver);

  /**
   * @dev Emitted when funds are refunded from project `projectId` to donor `donor` by calling {refundFunds}.
   * `tokenAmount` is the amount of tokens refunded.
   */
  event FundsRefunded(uint256 indexed projectId, address indexed donor, uint256 tokenAmount);

  /**
   * @dev Returns the zamzam token
   */
  function token() external view returns (IERC20);

  /**
   * @dev Returns the admin wallet
   */
  function adminWallet() external view returns (address);

  /**
   * @dev Returns the funding start time of project `projectId`
   */
  function fundingStartTime(uint256 projectId) external view returns (uint256);

  /**
   * @dev Returns the goal amount of project `projectId`
   */
  function goalAmount(uint256 projectId) external view returns (uint256);

  /**
   * @dev Returns the total funds raised by project `projectId`
   */
  function totalRaised(uint256 projectId) external view returns (uint256);

  /**
   * @dev Returns the total funds spent by project `projectId`
   */
  function totalSpent(uint256 projectId) external view returns (uint256);

  /**
   * @dev Returns the total donation made by user `user` for project `projectId`
   */
  function amountDonated(uint256 projectId, address user) external view returns (uint256);

  /**
   * @dev Returns if refunds are allowed on project `projectId` or not
   */
  function refundsAllowed(uint256 projectId) external view returns (bool);

  /**
   * @dev Returns whether the project `projectId` is unpublished or not
   */
  function unpublished(uint256 projectId) external view returns (bool);

  /**
   * @dev Calculates the voting power of a user `userId` in project `projectId`
   * @param user Address of the user whose voting power calculated
   * @param projectId projectId of the project in which the voting power is calculated
   * @return Returns the voting power a user `user` in project `projectId`
   */
  function votingPower(uint256 projectId, address user) external view returns (uint256);

  /**
   * @notice Create a Zamzam project
   * @dev Create a Zamzam project, only a Zamzam admin can create a Zamzam project
   * @param fundingStartTime The date from which donations are accepted for this project
   * @param goalAmount The minimum amount of tokens needed to start the project
   * @return Returns the projectId of the created project
   */
  function createProject(uint256 fundingStartTime, uint256 goalAmount) external returns (uint256);

  /**
   * @notice Update a Zamzam project
   * @dev Update a Zamzam project, only a Zamzam admin can update a Zamzam project
   * Please make sure to pass in both the fundingStartTime and the goalAmount, even if you just have to update one of these values
   * @param _projectId The project ID of the project to be updated
   * @param _fundingStartTime The new fundingStartTime of the project
   * @param _goalAmount The new goalAmount of the project
   * @return Returns the projectId of the created project
   */
  function updateProject(
    uint256 _projectId,
    uint256 _fundingStartTime,
    uint256 _goalAmount
  ) external returns (uint256);

  /**
   * @notice Donate to a Zamzam Project
   * @dev Donates `tokenAmount` Zamzam tokens to project `projectId`
   * @param projectId The ID of the project to which the donation will be made
   * @param tokenAmount The amount of Zamzam tokens which will be donated
   * @return Returns true if the donation was successful
   */
  function donate(uint256 projectId, uint256 tokenAmount) external returns (bool);

  /**
   * @notice Zamzam admin can donate in the name of a user
   * @dev Zamzam admin can donate in the name of a user to support fiat donations
   * To support fiat donations, the DApp sends BNB amount purchased by the user to this function, and then an equivalent amount of Zamzam tokens are are donated to the project `projectId` in the name of `donor`
   * @param projectId The ID of the project to which the donation will be made
   * @param tokenAmount The amount of BNB which will be converted into equivalent Zamzam tokens for donation
   * @param donor The address of the user who will be accounted for the donation
   * @return Returns true if the donation was successful
   */
  function donateFiat(
    uint256 projectId,
    uint256 tokenAmount,
    address donor
  ) external returns (bool);

  /**
   * @notice Release the tokens of a Zamzam Project
   * @dev Releases `tokenAmount` tokens of a Zamzam project `projectId` to the admin wallet `_adminWallet`
   * The Zamzam admin then releases the tokens to the appropriate addresses.
   * @param projectId The ID of the project whose tokens will be released
   * @param tokenAmount The amount of tokens which will be released
   * @param receiver The amount of tokens which will be released
   * @return Returns true if the release of tokens was successful
   */
  function releaseFunds(
    uint256 projectId,
    uint256 tokenAmount,
    address receiver
  ) external returns (bool);

  /**
   * @dev Enables refunds on a proejct `projectId`
   * @param projectId The ID of the project for whom refunds will be enabled
   * Only Zamzam admin can set this field
   */
  function allowRefunds(uint256 projectId) external;

  /**
   * @notice Refund tokens to a donor
   * @dev Refunds the unused tokens of a Zamzam project `projectId` back to the msg.sender
   * @param projectId The ID of the project whose tokens will be refunded
   * @return Returns true if refund of tokens of project was successful
   */
  function refundDonor(uint256 projectId) external returns (bool);
}

// SPDX-License-Identifier: MIT
// SettleMint.com
/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contcontact [email protected]
 */
pragma solidity ^0.8.9;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IZamzamDAO} from "./IZamzamDAO.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "./library/integration/chainlink/AggregatorV3Interface.sol";

/**
@title Zamzam DAO contract
@notice This contract is used by the Zamzam platform to create projects, collect, release and refund funds for projects, etc.
@dev This contract keeps track of all the projects created from the Zamzam platform, their states and attributes, eg. total amonut raised for a project.
 */
contract ZamzamDAO is IZamzamDAO, AccessControl, ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private projectIds;

  mapping(uint256 => Project) private projects;

  address private _adminWallet;

  IERC20 private zamzamToken;

  bytes32 public constant FIAT_DONATION_CONTROLLER_ROLE = keccak256("FIAT_DONATION_CONTROLLER_ROLE");

  /**
   * @dev Modifier that allows donations for project `projectId` only when donations are open
   */
  modifier whenDonationsOpen(uint256 projectId) {
    Project storage project = projects[projectId];
    require(project.fundingStartTime <= block.timestamp, "ZamzamDAO: Donations are closed");
    require(project.totalRaised < project.goalAmount, "ZamzamDAO: Goal amount reached");
    _;
  }

  constructor(address _zamzamToken) {
    _adminWallet = msg.sender;
    zamzamToken = IERC20(_zamzamToken);
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setRoleAdmin(FIAT_DONATION_CONTROLLER_ROLE, DEFAULT_ADMIN_ROLE);
  }

  /**
   * @dev Returns the zamzam token
   */
  function token() external view returns (IERC20) {
    return zamzamToken;
  }

  /**
   * @dev Returns the admin wallet
   */
  function adminWallet() external view returns (address) {
    return _adminWallet;
  }

  /**
   * @dev Returns the funding start time of project `projectId`
   */
  function fundingStartTime(uint256 projectId) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.fundingStartTime;
  }

  /**
   * @dev Returns the goal amount of project `projectId`
   */
  function goalAmount(uint256 projectId) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.goalAmount;
  }

  /**
   * @dev Returns the total funds raised by project `projectId`
   */
  function totalRaised(uint256 projectId) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.totalRaised;
  }

  /**
   * @dev Returns the total funds spent by project `projectId`
   */
  function totalSpent(uint256 projectId) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.totalSpent;
  }

  /**
   * @dev Returns the total donation made by user `user` for project `projectId`
   */
  function amountDonated(uint256 projectId, address user) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.donations[user];
  }

  /**
   * @dev Returns if refunds are allowed on project `projectId` or not
   */
  function refundsAllowed(uint256 projectId) external view returns (bool) {
    Project storage project = projects[projectId];
    return project.refundsAllowed;
  }

  /**
   * @dev Calculates the voting power of a user `userId` in project `projectId`
   * @param user Address of the user whose voting power calculated
   * @param projectId projectId of the project in which the voting power is calculated
   * @return Returns the voting power a user `user` in project `projectId`
   */
  function votingPower(uint256 projectId, address user) external view returns (uint256) {
    Project storage project = projects[projectId];
    return project.donations[user];
  }

  /**
   * @dev Returns whether the project `projectId` is unpublished or not
   */
  function unpublished(uint256 projectId) external view returns (bool) {
    Project storage project = projects[projectId];
    return project.unpublished;
  }

  /**
   * @notice Create a Zamzam project
   * @dev Create a Zamzam project, only a Zamzam admin can create a Zamzam project
   * The projectIds start from 0, i.e, the first project will have projectId 0
   * @param _fundingStartTime The date from which donations will be accepted for this project
   * @param _goalAmount The minimum amount of tokens needed to start the project
   * @return Returns the projectId of the created project
   */
  function createProject(uint256 _fundingStartTime, uint256 _goalAmount)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    returns (uint256)
  {
    require(_fundingStartTime >= block.timestamp, "ZamzamDAO: Invalid start time");
    require(_goalAmount > 0, "ZamzamDAO: Invalid amount");

    uint256 newProjectId = projectIds.current();
    Project storage _project = projects[newProjectId];
    _project.fundingStartTime = _fundingStartTime;
    _project.goalAmount = _goalAmount;
    projectIds.increment();

    emit ProjectCreated(newProjectId, _fundingStartTime, _goalAmount);

    return newProjectId;
  }

  /**
   * @notice Update a Zamzam project
   * @dev Update a Zamzam project, only a Zamzam admin can update a Zamzam project
   * Please make sure to pass in both the fundingStartTime and the goalAmount, even if you just have to update one of these values
   * @param _projectId The project ID of the project to be updated
   * @param _fundingStartTime The new fundingStartTime of the project
   * @param _goalAmount The new goalAmount of the project
   * @return Returns the projectId of the created project
   */
  function updateProject(
    uint256 _projectId,
    uint256 _fundingStartTime,
    uint256 _goalAmount
  ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
    Project storage _project = projects[_projectId];

    require(_projectId < projectIds.current(), "ZamzamDAO: Invalid projectId");
    require(!_project.unpublished, "ZamzamDAO: Project closed");

    _project.fundingStartTime = _fundingStartTime;
    _project.goalAmount = _goalAmount;

    emit ProjectUpdated(_projectId, _fundingStartTime, _goalAmount);

    return _projectId;
  }

  /**
   * @notice Donate to a Zamzam Project
   * @dev Donates `tokenAmount` Zamzam tokens to project `projectId`
   * We guard from overfunding of tokens
   * @param projectId The ID of the project to which the donation will be made
   * @param tokenAmount The amount of Zamzam tokens which will be donated
   * @return Returns true if the donation was successful
   */
  function donate(uint256 projectId, uint256 tokenAmount)
    external
    nonReentrant
    whenDonationsOpen(projectId)
    returns (bool)
  {
    require(tokenAmount > 0, "ZamzamDAO: Invalid amount");

    Project storage project = projects[projectId];
    require(!project.unpublished, "ZamzamDAO: Project closed");

    SafeERC20.safeTransferFrom(zamzamToken, msg.sender, address(this), tokenAmount);

    if (project.totalRaised + tokenAmount > project.goalAmount) {
      tokenAmount = project.goalAmount - project.totalRaised;
    }
    project.totalRaised += tokenAmount;
    project.donations[msg.sender] += tokenAmount;

    emit Donation(projectId, msg.sender, tokenAmount);

    return true;
  }

  /**
   * @notice Zamzam admin can donate in the name of a user
   * @dev Zamzam admin can donate in the name of a user to support fiat donations
   * @param projectId The ID of the project to which the donation will be made
   * @param tokenAmount The amount of BNB which will be converted into equivalent Zamzam tokens for donation
   * @param donor The address of the user who will be accounted for the donation
   * @return Returns true if the donation was successful
   */
  function donateFiat(
    uint256 projectId,
    uint256 tokenAmount,
    address donor
  ) external nonReentrant onlyRole(FIAT_DONATION_CONTROLLER_ROLE) returns (bool) {
    require(tokenAmount > 0, "ZamzamDAO: Invalid amount");

    Project storage project = projects[projectId];
    require(!project.unpublished, "ZamzamDAO: Project closed");

    SafeERC20.safeTransferFrom(zamzamToken, msg.sender, address(this), tokenAmount);

    project.totalRaised += tokenAmount;
    project.donations[donor] += tokenAmount;

    emit Donation(projectId, donor, tokenAmount);

    return true;
  }

  /**
   * @notice Release the tokens of a Zamzam Project
   * @dev Releases `tokenAmount` tokens of a Zamzam project `projectId` to the admin wallet `_adminWallet`
   * The Zamzam admin then releases the tokens to the appropriate addresses.
   * @param projectId The ID of the project whose tokens will be released
   * @param tokenAmount The amount of tokens which will be released
   * @param receiver The amount of tokens which will be released
   * @return Returns true if the release of tokens was successful
   */
  function releaseFunds(
    uint256 projectId,
    uint256 tokenAmount,
    address receiver
  ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
    Project storage project = projects[projectId];
    require((project.totalRaised - project.totalSpent) >= tokenAmount, "ZamzamDAO: Insufficient funds");

    SafeERC20.safeTransfer(zamzamToken, receiver, tokenAmount);

    project.totalSpent += tokenAmount;

    emit FundsReleased(projectId, tokenAmount, receiver);
    return true;
  }

  /**
   * @dev Enables refunds on a proejct `projectId`
   * @param projectId The ID of the project for whom refunds will be enabled
   * Only Zamzam admin can set this field
   */
  function allowRefunds(uint256 projectId) external onlyRole(DEFAULT_ADMIN_ROLE) {
    Project storage project = projects[projectId];
    project.refundsAllowed = true;
  }

  /**
   * @dev Enables refunds on a proejct `projectId`
   * @param projectId The ID of the project for which will be unpublished
   * Only Zamzam admin can set this field
   */
  function unpublishProject(uint256 projectId) external onlyRole(DEFAULT_ADMIN_ROLE) {
    Project storage project = projects[projectId];
    project.unpublished = true;
  }

  /**
   * @notice Refund tokens to a donor
   * @dev Refunds the unused tokens of a Zamzam project `projectId` back to the msg.sender
   * @param projectId The ID of the project whose tokens will be refunded
   * @return Returns true if refund of tokens of project was successful
   */
  function refundDonor(uint256 projectId) external nonReentrant returns (bool) {
    Project storage project = projects[projectId];

    require(project.refundsAllowed, "ZamzamDAO: Refunds not allowed");
    require((project.totalRaised - project.totalSpent) > 0, "ZamzamDAO: Insufficient funds");

    uint256 totalFundsLeft = project.totalRaised - project.totalSpent;
    uint256 _refundableAmount = (totalFundsLeft * project.donations[msg.sender]) / project.totalRaised;

    SafeERC20.safeTransfer(zamzamToken, msg.sender, _refundableAmount);

    project.donations[msg.sender] = 0;

    emit FundsRefunded(projectId, msg.sender, _refundableAmount);
    return true;
  }
}

// SPDX-License-Identifier: MIT
// source: https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
pragma solidity ^0.8.9;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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