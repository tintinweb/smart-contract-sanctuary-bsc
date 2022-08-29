/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

/*
*                                                                                                                                                                                                                                                                                                                 
*                                                                                     
* MineCraft BNB - The Best Mining Game
* M2E, Mining to Earn
*
* Earn BNB !

* Website  : https://minecraftbnb.com
*
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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
}

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

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default : 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
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
        // On the first call to nonReentrant, _notEntered will be true
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

contract MCBNBInvestingHelper is Context, AccessControl, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;
    uint256 public REFERRAL = 70;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 100;
    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 150 * 1e18; /** 150 BNB  **/

    uint256 public COMPOUND_BONUS = 20;
    uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;
    bool public blacklistActive = true;
    mapping(address => bool) public Blacklisted;

    uint256 public CUTOFF_STEP = 48 * 60 * 60;
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    /* addresses */
    address public owner;
    address payable private ceoAddr;
    address public MCToken = 0x25fe6305D1807d4215b6c7421e647156fd8c563c;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 farmerCompoundCount; //added to monitor farmer consecutive compound without cap
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor() {
        owner = msg.sender;
        ceoAddr = payable(msg.sender);
    }

    function updateMCToken(address _newContract) external {
        require(msg.sender == owner, "Only owner can update MCToken Contract");
  	    MCToken = _newContract;
  	}

    function setblacklistActive(bool isActive) public{
        require(msg.sender == owner, "Admin use only.");
        blacklistActive = isActive;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        Blacklisted[Wallet] = isBlacklisted;
    }

    function blackMultipleWallets(address[] calldata Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            Blacklisted[Wallet[i]] = isBlacklisted;
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted){
        require(msg.sender == owner, "Admin use only.");
        blacklisted = Blacklisted[Wallet];
    }

    function startApiary(address addr) public payable{
        if (!contractStarted) {
            if (msg.sender == owner) {
                require(marketEggs == 0);
                contractStarted = true;
                marketEggs = 144000000000;
                hireMiners(addr);
            } else revert("Contract not yet started.");
        }
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

    function hireMoreMiners(bool isCompound) public nonReentrant {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        }

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
            //add compoundCount for monitoring purposes.
            user.farmerCompoundCount = user.farmerCompoundCount .add(1);
        }

        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function MeltingGold() public nonReentrant {
        require(contractStarted, "Contract not yet Started.");

        if (blacklistActive) {
            require(!Blacklisted[msg.sender], "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and eggValue will be deducted with 60% feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and eggValue will remain without deductions
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
        }

        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));

        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }


    /** transfer amount of BNB **/
    function hireMiners(address ref) public payable {
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Minimum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);


        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        IERC20(MCToken).transfer(payable(msg.sender), msg.value * 300000);
        hireMoreMiners(false);
    }


    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        ceoAddr.transfer(tax);
        return tax;
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS);
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _farmerCompoundCount, uint256 _lastWithdrawTime) {
        _initialDeposit = users[_adr].initialDeposit;
        _userDeposit = users[_adr].userDeposit;
        _miners = users[_adr].miners;
        _claimedEggs = users[_adr].claimedEggs;
        _lastHatch = users[_adr].lastHatch;
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _totalWithdrawn = users[_adr].totalWithdrawn;
        _referralEggRewards = users[_adr].referralEggRewards;
        _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
        _farmerCompoundCount = users[_adr].farmerCompoundCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(
            SafeMath.mul(PSN, bs),
            SafeMath.add(PSNH,
            SafeMath.div(
                SafeMath.add(
                    SafeMath.mul(PSN, rs),
                    SafeMath.mul(PSNH, rt)),
                rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, getBalance());
    }

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%
    // 1080000 - 8%, 959000 - 9%, 864000 - 10%, 720000 - 12%

    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 720000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 15);
        TAX = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100);
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50);
        MARKET_EGGS_DIVISOR = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 900);
        WITHDRAWAL_TAX = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 30);
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 24);
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e17;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_INVEST_MAX_USER() external {
        require(msg.sender == owner, "Admin use only");
        payable(msg.sender).transfer(address(this).balance);
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }

    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 12);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}