// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
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
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

pragma solidity ^0.8.0;

/*
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

pragma solidity =0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/utils/Address.sol';

contract FeeCollector is Ownable {
    using Address for address;

    mapping(string => uint256) public configureFees;
    uint256 public collectedFees;
    uint256 public withdrawnFees;

    event FeeConfigureChanged(string method, uint256 fee);
    event FeeWithdrawn(address indexed user, uint256 amount);

    function setFeesConfiguration(string[] memory methods, uint256[] memory fees) public onlyOwner {
        require(methods.length == fees.length, 'FeeCollector: invalid set of configuration provided');
        for (uint i=0; i<methods.length; i++) {
            configureFees[methods[i]] = fees[i];
            emit FeeConfigureChanged(methods[i], fees[i]);
        }
    }

    function withdrawCollectedFees(address addr, uint256 amount) public onlyOwner {
        require(addr != address(0), 'FeeCollector: address needs to be different than zero!');
        require(collectedFees >= amount, 'FeeCollector: not enough fees to withdraw!');
        collectedFees = collectedFees - amount;
        withdrawnFees = withdrawnFees + amount;
        Address.sendValue(payable(addr), amount);
        emit FeeWithdrawn(addr, amount);
    }

    modifier collectFee(string memory method) {
        require(msg.value > 0 || configureFees[method] == 0, 'FeeCollector: this method requires fee');
        require(msg.value == configureFees[method], 'FeeCollector: wrong fee amount provided');
        collectedFees = collectedFees + msg.value;
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "./ILaunchpadVault.sol";

interface ILaunchpadFeeDecider {
    function calculateFee(address addr, uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

interface ILaunchpadPooledDelegate {
    function deposit(uint256 pid, uint256 amount) external;
    
    function withdraw(uint256 pid, uint256 amount) external;

    function claim(uint256 pid) external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

interface ILaunchpadSimpleDelegate {
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function claim() external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

interface ILaunchpadVault {
    function currentUserInfoAt(address addr, uint256 index) external view returns (uint256);

    function increasePeggedAmount(address addr, uint256 amount) external returns (uint256);

    function decreasePeggedAmount(address addr, uint256 amount) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "./Extension/ILaunchpadVault.sol";

interface ILaunchpadCore is ILaunchpadVault {
    function startFactory() external;

    function closeFactory() external;

    function suspend() external;

    function restore() external;

    function deposit(uint256 baseAmount, uint256 pairAmount, uint256 timestamp) external payable;

    function defaultRelease() external payable;

    function instantRelease() external payable;

    function defaultWithdraw() external payable;

    function instantWithdraw() external payable;

    function releaseFor(address addr) external;

    function withdrawFor(address addr) external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import './ILaunchpadCore.sol';
import './Extension/ILaunchpadSimpleDelegate.sol';
import './Extension/ILaunchpadPooledDelegate.sol';
import './Extension/ILaunchpadFeeDecider.sol';
import "./Extension/FeeCollector.sol";
import "./Extension/ILaunchpadFeeDecider.sol";
import '../Token/IERC20Delegated.sol';

/**
 * @title Token Factory
 * @dev BEP20 compatible token.
 */
contract LaunchpadCore is Ownable, AccessControl, FeeCollector, ILaunchpadCore {
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant MIN = 0;

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    bytes32 public constant AGENT_ROLE = keccak256('AGENT_ROLE');

    struct UserInfo {
        uint256 baseAmount;
        uint256 pairAmount;
        uint256 mintAmount;
        uint256 lockedSince;
        uint256 lockedUntil;
        uint256 releaseTimestamp;
        uint256 releaseTimerange;
        bool isLocked;
    }

    mapping(address => UserInfo) public userInfo;
    uint256 userSize;

    IERC20 public baseToken;
    IERC20 public pairToken;
    IERC20Delegated public mintToken;

    uint256 public precWeight;
    uint256 public baseWeight;
    uint256 public baseMaxWeight;
    uint256 public pairWeight;
    uint256 public pairMaxWeight;
    uint256 public multWeight;
    uint256 public distWeight;

    struct DelegateInfo {
        address addr;
        uint256 mode;
        uint256 pool;
        uint256 deposited;
    }

    uint256 public startBlock;
    uint256 public closeBlock;
    
    uint256[2] public totalValue;
    uint256[2] public feeClaimed;
    uint256[2] public feeAwarded;

    uint256 public minLockTime;
    uint256 public maxLockTime;
    uint256 public maxRewardTime;
    uint256 public releaseTime;

    ILaunchpadFeeDecider public instantReleasesFeeDecider;
    ILaunchpadFeeDecider public instantWithdrawFeeDecider;
    ILaunchpadFeeDecider public exitFeeDecider;
    bool private _paused;

    event Deposited(address indexed user, uint256 baseAmount, uint256 pairAmount);
    event Withdrawn(address indexed user, uint256 baseAmount, uint256 pairAmount);
    event WithdrawnRemaining(address indexed user, uint256 baseAmount, uint256 pairAmount);
    event WithdrawnFeeValues(address indexed user, uint256 baseAmount, uint256 pairAmount);
    event AllocatedFeeValues(address indexed user, uint256 baseAmount, uint256 pairAmount);
    event RewardMinted(address indexed user, uint256 mintAmount);
    event RewardBurned(address indexed user, uint256 mintAmount);
    event FactoryStarted(uint256 block);
    event FactoryStopped(uint256 block);
    event TokenAddressChanged(address indexed baseToken, address indexed pairToken, address indexed mintToken);
    event TokenWeightsChanged(uint256 weigtht0, uint256 weigtht1, uint256 weight2, uint256 weight3, uint256 weight4);
    event TotalWeightsChanged(uint256 weigtht0, uint256 weigtht1);
    event LockIntervalChanged(uint256 minLock, uint256 maxLock, uint256 maxReward, uint256 release);
    event FarmingAddressChanged(address indexed addr, uint256 mode, uint256 pool);
    event StakingAddressChanged(address indexed addr, uint256 mode, uint256 pool);
    event LockRenewed(address indexed user, uint256 timestamp);
    event LockDeleted(address indexed user, uint256 timestamp);
    event PaidReleasesFeeDeciderChanged(address indexed addr);
    event PaidWithdrawFeeDeciderChanged(address indexed addr);
    event ExitFeeDeciderChanged(address indexed addr);
    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        transferOwnership(_msgSender());
        _paused = true;

        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(AGENT_ROLE, ADMIN_ROLE);

        _setupRole(ADMIN_ROLE, address(this));
    }

    function setAgent(address account, bool status) external onlyOwner returns (bool) {
        bytes4 selector = status ? this.grantRole.selector : this.revokeRole.selector;
        address(this).functionCall(abi.encodeWithSelector(selector, AGENT_ROLE, account));
        return true;
    }

    function isAgent(address account) external view returns (bool) {
        return hasRole(AGENT_ROLE, account);
    }

    function setTokenAddress(IERC20 _baseToken, IERC20 _pairToken, IERC20Delegated _mintToken) public onlyOwner {
        require(address(_baseToken) != address(0), 'Factory: token address needs to be different than zero!');
        require(address(_pairToken) != address(0), 'Factory: token address needs to be different than zero!');
        require(address(_mintToken) != address(0), 'Factory: token address needs to be different than zero!');
        require(address(baseToken) == address(0), 'Factory: tokens already set!');
        require(address(pairToken) == address(0), 'Factory: tokens already set!');
        require(address(mintToken) == address(0), 'Factory: tokens already set!');
        baseToken = _baseToken;
        pairToken = _pairToken;
        mintToken = _mintToken;
        emit TokenAddressChanged(address(baseToken), address(pairToken), address(mintToken));
    }

    function setTotalWeights(uint256 _multWeight, uint256 _distWeight) public onlyOwner {
        require(_multWeight > 0 && _distWeight > 0, 'Factory: weights need to be higher than zero!');
        multWeight = _multWeight;
        distWeight = _distWeight;
        emit TotalWeightsChanged(multWeight, distWeight);
    }

    function setTokenWeights(uint256 _precWeight, uint256 _baseWeight, uint256 _pairWeight, uint256 _baseMaxWeight, uint256 _pairMaxWeight) public onlyOwner {
        require(_baseWeight > 0 && _pairWeight > 0, 'Factory: weights need to be higher than zero!');
        precWeight = _precWeight;
        baseWeight = _baseWeight;
        pairWeight = _pairWeight;
        baseMaxWeight = _baseMaxWeight;
        pairMaxWeight = _pairMaxWeight;
        emit TokenWeightsChanged(precWeight, baseWeight, pairWeight, baseMaxWeight, pairMaxWeight);
    }

    function setLockInterval(uint256 _minLock, uint256 _maxLock, uint256 _maxRewardTime, uint256 _release) public onlyOwner {
        require(_maxLock > 0 && _maxRewardTime > 0, 'Factory: maxLock time needs to be higher than zero!');
        minLockTime = _minLock;
        maxLockTime = _maxLock;
        maxRewardTime = _maxRewardTime;
        releaseTime = _release;
        emit LockIntervalChanged(minLockTime, maxLockTime, maxRewardTime, releaseTime);
    }

    function setPaidReleasesFeeDecider(ILaunchpadFeeDecider addr) public onlyOwner {
        require(address(addr) != address(0), 'Factory: paid release fee decider address needs to be different from zero!');
        instantReleasesFeeDecider = addr;
        emit PaidReleasesFeeDeciderChanged(address(addr));
    }

    function setPaidWithdrawFeeDecider(ILaunchpadFeeDecider addr) public onlyOwner {
        require(address(addr) != address(0), 'Factory: paid withdraw fee decider address needs to be different from zero!');
        instantWithdrawFeeDecider = addr;
        emit PaidWithdrawFeeDeciderChanged(address(addr));
    }

    function setExitFeeDecider(ILaunchpadFeeDecider addr) public onlyOwner {
        require(address(addr) != address(0), 'Factory: exit fee decider address needs to be different from zero!');
        exitFeeDecider = addr;
        emit ExitFeeDeciderChanged(address(addr));
    }

    function startFactory() external virtual override onlyOwner {
        require(startBlock == 0, 'Factory: factory has been already started');
        startBlock = block.number;
        _paused = false;
        emit FactoryStarted(startBlock);
    }

    function closeFactory() external virtual override onlyOwner {
        require(startBlock != 0, 'Factory: unable to close before start');
        require(closeBlock == 0, 'Factory: factory has been already stopped');
        closeBlock = block.number;
        _paused = true;
        emit FactoryStopped(closeBlock);
    }

    function isStarted() public view returns (bool) {
        return startBlock != 0 && block.number >= startBlock;
    }

    function isStopped() public view returns (bool) {
        return closeBlock != 0 && block.number >= closeBlock;
    }

    function suspend() external virtual override onlyOwner {
        require(startBlock != 0, 'Factory: factory is not yet started');
        require(closeBlock == 0, 'Factory: factory has been already stopped');
        require(isRunning(), 'Factory: paused');
        _paused = true;
        emit Paused(_msgSender());
    }

    function restore() external virtual override onlyOwner {
        require(startBlock != 0, 'Factory: factory is not yet started');
        require(closeBlock == 0, 'Factory: factory has been already stopped');
        require(!isRunning(), 'Factory: not paused');
        _paused = false;
        emit Unpaused(_msgSender());
    }

    function isRunning() public view returns (bool) {
        return !_paused;
    }

    function currentMintAmount(address addr) public view returns (uint256) {
        UserInfo storage user = userInfo[addr];
        return user.mintAmount;
    }

    function currentUserInfoAt(address addr, uint256 index) external view virtual override returns (uint256) {
        UserInfo storage user = userInfo[addr];
        uint256[7] memory temp = [user.baseAmount, user.pairAmount, user.mintAmount, user.lockedSince, user.lockedUntil,
            user.releaseTimestamp, user.releaseTimerange];
        return (index >= 7) ? 0 : temp[index];
    }

    function predictLockSince(address addr, uint256 timerange, uint256 timestamp) public view returns (uint256) {
        UserInfo storage user = userInfo[addr];
        uint256 lockedSince = timestamp;
        uint256 lockedUntil = timestamp + timerange;
        if (lockedUntil < user.lockedUntil) {
            lockedSince = user.lockedSince;
        }
        return lockedSince;
    }

    function predictLockUntil(address addr, uint256 timerange, uint256 timestamp) public view returns (uint256) {
        UserInfo storage user = userInfo[addr];
        uint256 lockedUntil = timestamp + timerange;
        if (lockedUntil < user.lockedUntil) {
            lockedUntil = user.lockedUntil;
        }
        return lockedUntil;
    }

    function predictMintAmount(
        address addr, uint256 baseAmount, uint256 pairAmount, uint256 timerange, uint256 timestamp
    ) public view returns (uint256) {
        UserInfo storage user = userInfo[addr];

        uint256 paramBaseAmount = baseAmount;
        uint256 paramPairAmount = pairAmount;
        uint256 lockUntil = timestamp + timerange;
        uint256 extraBaseAmount = 0;
        uint256 extraPairAmount = 0;
        uint256 paramTime = timerange;
        uint256 extraTime = 0;
        uint256 relateTimestamp = 0;

        if (user.lockedUntil > timestamp) {
            relateTimestamp = user.lockedUntil;
        } else {
            relateTimestamp = timestamp;
        }
        if (lockUntil > user.lockedUntil) {
            extraBaseAmount = user.baseAmount;
            extraPairAmount = user.pairAmount;
            extraTime = lockUntil - relateTimestamp;
        }
        if (lockUntil < user.lockedUntil) {
            extraBaseAmount = paramBaseAmount;
            extraPairAmount = paramPairAmount;
            extraTime = relateTimestamp - lockUntil;
        }
        uint256 tokenMint = 0;
        if (paramBaseAmount > 0 || paramPairAmount > 0) {
            tokenMint = tokenMint + predictBaseAmount(paramBaseAmount, paramPairAmount, paramTime);
        }
        if (extraBaseAmount > 0 || extraPairAmount > 0) {
            tokenMint = tokenMint + predictBaseAmount(extraBaseAmount, extraPairAmount, extraTime);
        }
        return tokenMint;
    }

    function predictBaseAmount(uint256 baseAmount, uint256 pairAmount, uint256 timerange) public view returns (uint256) {
        uint256 weight1 = baseWeight > 0 ? baseWeight : 1;
        uint256 weight2 = pairWeight > 0 ? pairWeight : 1;
        uint256 mintAmount1 = baseAmount;
        uint256 mintAmount2 = baseToken.balanceOf(address(pairToken)) * 2 * pairAmount / pairToken.totalSupply();
        mintAmount1 = (precWeight > 0 ? precWeight : 1) * weight1 * mintAmount1 / (baseMaxWeight > 0 ? baseMaxWeight : 1);
        mintAmount2 = (precWeight > 0 ? precWeight : 1) * weight2 * mintAmount2 / (pairMaxWeight > 0 ? pairMaxWeight : 1);
        uint256 temprange = timerange > maxLockTime ? maxLockTime : timerange;
        return (mintAmount1 + mintAmount2) * multWeight * temprange / maxRewardTime / distWeight;
    }

    function withdrawRemaining() external onlyOwner {
        require(isStarted(), 'Factory: start block needs to be set first');

        uint256 baseVal = withdrawLeftovers(0);
        uint256 pairVal = withdrawLeftovers(1);

        if (baseVal > 0 || pairVal > 0) {
            emit WithdrawnRemaining(owner(), baseVal, pairVal);
        }
    }

    function withdrawFeeValues() external onlyOwner {
        require(isStarted(), 'Factory: start block needs to be set first');

        uint256 baseFee = withdrawFeeStored(0);
        uint256 pairFee = withdrawFeeStored(1);

        if (baseFee > 0 || pairFee > 0) {
            emit WithdrawnFeeValues(owner(), baseFee, pairFee);
        }
    }

    function deposit(uint256 baseAmount, uint256 pairAmount, uint256 timestamp) external virtual override payable collectFee('deposit') {
        _deposit(msg.sender, msg.sender, baseAmount, pairAmount, timestamp, 0);
    }

    function depositFor(address addr, uint256 baseAmount, uint256 pairAmount, uint256 timestamp, uint256 timerange) external virtual onlyRole(AGENT_ROLE) {
        _deposit(msg.sender, addr, baseAmount, pairAmount, timestamp, timerange);
    }

    function defaultRelease() external virtual override payable collectFee('defaultRelease') {
        _defaultRelease(msg.sender, false);
    }

    function instantRelease() external virtual override payable collectFee('instantRelease') {
        require(address(instantReleasesFeeDecider) != address(0), 'Factory: paid releasing is not active at this time!');
        _instantRelease(msg.sender, false);
    }

    function defaultWithdraw() external virtual override payable collectFee('defaultWithdraw') {
        _defaultWithdraw(msg.sender, false);
    }

    function instantWithdraw() external virtual override payable collectFee('instantWithdraw') {
        require(address(instantWithdrawFeeDecider) != address(0), 'Factory: paid withdraws is not active at this time!');
        _instantWithdraw(msg.sender, false);
    }

    function releaseFor(address addr) external virtual override onlyOwner {
        UserInfo storage user = userInfo[addr];
        uint256 baseAmount = user.baseAmount;
        uint256 pairAmount = user.pairAmount;
        user.baseAmount = 0;
        user.pairAmount = 0;
        user.mintAmount = mintToken.balanceOf(addr);
        _instantRelease(addr, true);
        user.baseAmount = baseAmount;
        user.pairAmount = pairAmount;
    }

    function withdrawFor(address addr) external virtual override onlyOwner {
        UserInfo storage user = userInfo[addr];
        uint256 baseAmount = user.baseAmount;
        uint256 pairAmount = user.pairAmount;
        user.baseAmount = 0;
        user.pairAmount = 0;
        user.mintAmount = mintToken.balanceOf(addr);
        _instantRelease(addr, true);
        user.baseAmount = baseAmount;
        user.pairAmount = pairAmount;
        _defaultWithdraw(addr, true); // withdraw can be free to not take any fines and instantRelease already released everything
    }

    function increasePeggedAmount(address addr, uint256 amount) external virtual override onlyRole(AGENT_ROLE) returns (uint256) {
        return _increaseMintedAmount(addr, amount);
    }

    function decreasePeggedAmount(address addr, uint256 amount) external virtual override onlyRole(AGENT_ROLE) returns (uint256) {
        return _decreaseMintedAmount(addr, amount);
    }

    function _deposit(address from, address addr, uint256 baseAmount, uint256 pairAmount, uint256 timestamp, uint256 timerangeReward) internal {
        require(isStarted(), 'Factory: not started yet');
        require(isRunning(), 'Factory: deposits are not accepted at this time');
        require(baseAmount > 0 || pairAmount > 0, 'Factory: deposit amounts need to be higher than zero!');
        require(timestamp > block.timestamp, 'Factory: timestamp has to be higher than current time!');

        uint256 time = timestamp - block.timestamp;
        require(timerangeReward > 0 || maxLockTime >= time && minLockTime <= time && time > 0, 
            'Factory: timelock that long is not supported!');
        UserInfo storage user = userInfo[addr];
        if (user.baseAmount == 0 && user.pairAmount == 0) {
            userSize++;
        }
        timerangeReward = (timerangeReward > 0) ? timerangeReward : time;

        require(user.lockedUntil == 0 || user.lockedUntil == timestamp,
            'Factory: you already deposited funds before, please use same timestamp');
        require(user.releaseTimestamp == 0 || user.releaseTimestamp < block.timestamp,
            'Factory: cannot re-deposit during unbonding');
        
        createReward(addr, baseAmount, pairAmount, timerangeReward);
        extendLocker(addr, baseAmount, pairAmount, time);

        if (baseAmount > 0) {
            user.baseAmount = user.baseAmount + baseAmount;
            totalValue[0] = totalValue[0] + baseAmount;
            uint256 prevBalance = baseToken.balanceOf(address(this));
            transferBaseToken(from, baseAmount);
            require(baseToken.balanceOf(address(this)) - prevBalance == baseAmount, 'Factory: fees are unsupported during deposits');
        }
        if (pairAmount > 0) {
            user.pairAmount = user.pairAmount + pairAmount;
            totalValue[1] = totalValue[1] + pairAmount;
            uint256 prevBalance = pairToken.balanceOf(address(this));
            transferPairToken(from, pairAmount);
            require(pairToken.balanceOf(address(this)) - prevBalance == pairAmount, 'Factory: fees are unsupported during deposits');
        }
        emit Deposited(addr, baseAmount, pairAmount);
    }

    function _defaultRelease(address addr, bool safe) internal {
        require(isStarted(), 'Factory: not started yet');

        UserInfo storage user = userInfo[addr];
        require(isStopped() || user.lockedUntil <= block.timestamp, 'Factory: cannot release tokens before timelock finishes');
        require(safe || user.baseAmount > 0 || user.pairAmount > 0, 'Factory: release amounts need to be higher than zero!');

        deleteReward(addr);
        recallLocker(addr, safe);
    }

    function _instantRelease(address addr, bool safe) internal {
        require(isStarted(), 'Factory: not started yet');

        UserInfo storage user = userInfo[addr];
        require(safe || user.baseAmount > 0 || user.pairAmount > 0, 'Factory: release amounts need to be higher than zero!');

        deleteReward(addr);
        deleteLocker(addr, safe);
    }

    function _instantWithdraw(address addr, bool safe) internal {
        require(isStarted(), 'Factory: not started yet');

        UserInfo storage user = userInfo[addr];
        require(user.lockedUntil <= block.timestamp, 'Factory: cannot withdraw tokens before timelock finishes!');

        recallUnbond(addr, address(instantReleasesFeeDecider));
        _defaultWithdraw(addr, safe);
    }

    function _defaultWithdraw(address addr, bool safe) internal {
        require(isStarted(), 'Factory: not started yet');

        UserInfo storage user = userInfo[addr];
        require(user.lockedUntil <= block.timestamp, 'Factory: cannot withdraw tokens before timelock finishes!');
        require(user.releaseTimestamp == 0 || user.releaseTimestamp < block.timestamp, 'Factory: cannot withdraw tokens before release finishes!');
        if (user.baseAmount != 0 || user.pairAmount != 0) {
            userSize--;
        }

        recallLocker(addr, safe);

        // TODO it  is not elegant to have it here - find a better place in the future ;)
        if (!isStopped() && address(exitFeeDecider) != address(0)) {
            applyFee(addr, address(exitFeeDecider));
        }

        uint256 baseAmount = user.baseAmount;
        uint256 pairAmount = user.pairAmount;
        if (baseAmount > 0) {
            user.baseAmount = user.baseAmount - baseAmount;
            totalValue[0] = totalValue[0] - baseAmount;
            withdrawBaseToken(addr, baseAmount);
        }
        if (pairAmount > 0) {
            user.pairAmount = user.pairAmount - pairAmount;
            totalValue[1] = totalValue[1] - pairAmount;
            withdrawPairToken(addr, pairAmount);
        }
        emit Withdrawn(addr, baseAmount, pairAmount);
    }

    function extendLocker(address addr, uint256 baseAmount, uint256 pairAmount, uint256 time) internal {
        UserInfo storage user = userInfo[addr];
        require(user.releaseTimestamp == 0 || user.releaseTimestamp < block.timestamp, 'Factory: cannot create lock yet!');
        createLocker(addr, baseAmount, pairAmount, time);
    }

    function createLocker(address addr, uint256 baseAmount, uint256 pairAmount, uint256 time) internal {
        UserInfo storage user = userInfo[addr];
        require(user.baseAmount + baseAmount > 0 || user.pairAmount + pairAmount > 0, 'Factory: you don\'t have any tokens to lock!');

        user.isLocked = true;
        user.releaseTimestamp = 0;
        user.releaseTimerange = releaseTime;
        user.lockedSince = predictLockSince(addr, time, block.timestamp);
        user.lockedUntil = predictLockUntil(addr, time, block.timestamp);

        emit LockRenewed(addr, user.lockedUntil);
    }

    function deleteLocker(address addr, bool safe) internal {
        UserInfo storage user = userInfo[addr];
        if (user.isLocked) {
            recallLocker(addr, safe);
        } else { // keep the same constraints behavior as in deleteLocker() without calling it!
            require(safe || user.baseAmount > 0 || user.pairAmount > 0, 'Factory: you don\'t have any tokens to unlock!');
        }
        if (user.releaseTimestamp != 0) {
            bool isEarly = user.releaseTimestamp > block.timestamp;
            // user.releaseTimestamp = 0; // recall unbound already does this!
            user.lockedUntil = 0; // block.timestamp;

            recallUnbond(addr, address(instantReleasesFeeDecider));
            if (isEarly) {
                emit LockDeleted(addr, user.lockedUntil);
            }
        }
    }

    function recallLocker(address addr, bool safe) internal {
        UserInfo storage user = userInfo[addr];
        require(safe || user.baseAmount > 0 || user.pairAmount > 0, 'Factory: you don\'t have any tokens to unlock!');

        if (user.isLocked == true) {
            user.isLocked = false;
            user.releaseTimestamp = block.timestamp + user.releaseTimerange;
            user.releaseTimerange = 0;
            user.lockedSince = 0;
            user.lockedUntil = 0; // block.timestamp;

            emit LockDeleted(addr, user.releaseTimestamp);
        }
        if (user.releaseTimestamp != 0) {
            bool isEarly = user.releaseTimestamp > block.timestamp;
            bool isAllow = isStopped() || !isEarly;
            if (isAllow) {
                user.releaseTimestamp = 0;
                user.lockedUntil = 0; // block.timestamp;
            }
            if (isEarly) {
                emit LockDeleted(addr, user.lockedUntil);
            }
        }
    }

    function recallUnbond(address addr, address feeDecider) internal {
        UserInfo storage user = userInfo[addr];
        if (user.releaseTimestamp != 0) {
            bool isEarly = user.releaseTimestamp > block.timestamp;
            user.releaseTimestamp = 0;

            if (isEarly && !isStopped() && feeDecider != address(0)) {
                applyFee(addr, feeDecider);
            }
        }
    }

    function applyFee(address addr, address feeDecider) internal {
        UserInfo storage user = userInfo[addr];
        uint256 baseFee = ILaunchpadFeeDecider(feeDecider).calculateFee(addr, user.baseAmount); // X% fee
        uint256 pairFee = ILaunchpadFeeDecider(feeDecider).calculateFee(addr, user.pairAmount); // X% fee
        feeAwarded[0] = feeAwarded[0] + baseFee;
        feeAwarded[1] = feeAwarded[1] + pairFee;
        user.baseAmount = user.baseAmount - baseFee;
        user.pairAmount = user.pairAmount - pairFee;
        if (baseFee > 0 || pairFee > 0) {
            emit AllocatedFeeValues(addr, baseFee, pairFee);
        }
    }

    function withdrawLeftovers(uint256 index) internal returns (uint256) {
        require(index == 0 || index == 1, 'Factory: unsupported index');
        uint256 value;
        if (index == 0) value = baseToken.balanceOf(address(this));
        if (index == 1) value = pairToken.balanceOf(address(this));
        
        uint256 reservedAmount = totalValue[index];
        uint256 possibleAmount = value;
        uint256 unlockedAmount = 0;

        if (possibleAmount > reservedAmount) {
            unlockedAmount = possibleAmount - reservedAmount;
        }
        if (unlockedAmount > 0) {
            totalValue[index] = totalValue[index] - unlockedAmount;
            if (index == 0) withdrawBaseToken(owner(), unlockedAmount);
            if (index == 1) withdrawPairToken(owner(), unlockedAmount);
        }
        return unlockedAmount;
    }

    function withdrawFeeStored(uint256 index) internal returns (uint256) {
        require(index == 0 || index == 1, 'Factory: unsupported index');
        uint256 value;
        if (index == 0) value = baseToken.balanceOf(address(this));
        if (index == 1) value = pairToken.balanceOf(address(this));
        
        uint256 unlockedFeeReward = feeAwarded[index] - feeClaimed[index];
        uint256 possibleFeeAmount = value;

        if (unlockedFeeReward > possibleFeeAmount) {
            unlockedFeeReward = possibleFeeAmount;
        }
        if (unlockedFeeReward > 0) {
            feeClaimed[index] = feeClaimed[index] + unlockedFeeReward;
            totalValue[index] = totalValue[index] - unlockedFeeReward;
            if (index == 0) withdrawBaseToken(owner(), unlockedFeeReward);
            if (index == 1) withdrawPairToken(owner(), unlockedFeeReward);
        }
        return unlockedFeeReward;
    }

    function transferBaseToken(address addr, uint256 amount) internal {
        baseToken.safeTransferFrom(addr, address(this), amount);
    }

    function withdrawBaseToken(address addr, uint256 amount) internal {
        baseToken.safeTransfer(addr, amount);
    }

    function transferPairToken(address addr, uint256 amount) internal {
        pairToken.safeTransferFrom(addr, address(this), amount);
    }

    function withdrawPairToken(address addr, uint256 amount) internal {
        pairToken.safeTransfer(addr, amount);
    }


    function createReward(address addr, uint256 baseAmount, uint256 pairAmount, uint256 timerange) internal {
        uint256 amount = mintReward(addr, baseAmount, pairAmount, timerange);
        if (amount > 0) {
            _increaseMintedAmount(addr, amount);
        }
    }

    function deleteReward(address addr) internal {
        uint256 amount = burnReward(addr);
        if (amount > 0) {
            _decreaseMintedAmount(addr, amount);
        }
    }

    function mintReward(address addr, uint256 baseAmount, uint256 pairAmount, uint256 timerange) internal returns (uint256) {
        uint256 amount = predictMintAmount(addr, baseAmount, pairAmount, timerange, block.timestamp);
        if (amount > 0) {
            mintToken.mintFor(addr, amount);
            emit RewardMinted(addr, amount);
        }
        return amount;
    }

    function burnReward(address addr) internal returns (uint256) {
        uint256 virtAmount = currentMintAmount(addr);
        uint256 realAmount = mintToken.balanceOf(addr);
        require(virtAmount <= realAmount, 'Factory: you need to have all reward tokens on your wallet to do this action');
        if (virtAmount > 0) {
            mintToken.burnFor(addr, virtAmount);
            emit RewardBurned(addr, virtAmount);
        }
        return virtAmount;
    }

    function _increaseMintedAmount(address addr, uint256 amount) private returns (uint256) {
        UserInfo storage user = userInfo[addr];
        user.mintAmount = user.mintAmount + amount;
        return amount;
    }

    function _decreaseMintedAmount(address addr, uint256 amount) private returns (uint256) {
        UserInfo storage user = userInfo[addr];
        require(user.mintAmount >= amount, 'Factory: cannot decrease minted amount by value greater than current amount');
        user.mintAmount = user.mintAmount - amount;
        return amount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "./IERC20DelegatedBurn.sol";
import "./IERC20DelegatedMint.sol";

interface IERC20Delegated is IERC20DelegatedBurn, IERC20DelegatedMint {}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20DelegatedBurn is IERC20 {

    function burn(uint256 amount) external;

    function burnFor(address addr, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20DelegatedMint is IERC20 {

    function mint(uint256 amount) external;

    function mintFor(address addr, uint256 amount) external;
}