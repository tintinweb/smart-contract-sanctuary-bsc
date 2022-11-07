/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/proxy/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


pragma solidity ^0.8.0;



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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


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


// File contracts/interfaces/IChainlinkPriceFeeds.sol

pragma solidity ^0.8.0;

interface IChainlinkPriceFeeds {

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) external view returns (uint256);
}


// File contracts/libraries/MediaEyeOrders.sol

pragma solidity ^0.8.0;

library MediaEyeOrders {
    enum NftTokenType {
        ERC1155,
        ERC721
    }

    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct SubscriptionSignature {
        bool isValid;
        UserSubscription userSubscription;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct UserSubscription {
        address userAddress;
        MediaEyeOrders.SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Listing {
        uint256 listingId;
        Nft[] nfts;
        address payable seller;
        uint256 timestamp;
        Split split;
    }

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        IChainlinkPriceFeeds priceFeed;
        bool invertedAggregator;
    }

    struct AuctionConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
        address _mediaEyeCharities;
        Chainlink _chainlink;
    }

    struct OfferConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
    }

    struct AuctionAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        address _newCharityContract;
        MediaEyeOrders.Chainlink _chainlink;
        uint256 _basisPointFee;
        bool _check;
        address _newInfoContract;
    }

    struct OfferAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        uint256 _basisPointFee;
        address _newInfoContract;
    }

    struct AuctionInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.AuctionPayment[] auctionPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        AuctionTime auctionTime;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    struct AuctionTime {
        uint256 startTime;
        uint256 endTime;
    }

    struct Auction {
        uint256 auctionId;
        Nft[] nfts;
        address seller;
        uint256 startTime;
        uint256 endTime;
        Split split;
    }

    struct Royalty {
        address payable artist;
        uint256 royaltyBasisPoint;
    }

    struct Split {
        address payable recipient;
        uint256 splitBasisPoint;
        address payable charity;
        uint256 charityBasisPoint;
    }

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    struct PaymentChainlink {
        bool isValid;
        address quoteAddress;
    }

    struct Feature {
        bool feature;
        address paymentMethod;
        uint256 numDays;
        uint256 id;
        address[] tokenAddresses;
        uint256[] tokenIds;
        uint256 price;
    }

    struct AuctionPayment {
        address paymentMethod;
        uint256 initialPrice;
        uint256 buyItNowPrice;
    }

    struct AuctionSignature {
        uint256 auctionId;
        uint256 price;
        address bidder;
        address paymentMethod;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct OfferSignature {
        Nft nft;
        uint256 price;
        address offerer;
        address paymentMethod;
        uint256 expiry;
        address charityAddress;
        uint256 charityBasisPoint;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }
}


// File contracts/interfaces/ISubscriptionTier.sol

pragma solidity ^0.8.0;

interface ISubscriptionTier {
    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct UserSubscription {
        address userAddress;
        SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Featured {
        uint256 startTime;
        uint256 numDays;
        uint256 featureType;
        address contractAddress;
        uint256 listingId;
        uint256 auctionId;
        uint256 id;
        address featuredBy;
        uint256 price;
    }

    function getUserSubscription(address account)
        external
        view
        returns (UserSubscription memory);

    function checkUserSubscription(address _user)
        external
        view
        returns (uint256);

    function checkUserSubscriptionBySig(
        MediaEyeOrders.UserSubscription memory _userSubscription,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint256);

    function payFeatureFee(
        address _paymentMethod,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        Featured memory _featured
    ) external payable;
}


// File contracts/MediaEyeCollectionFactory.sol

pragma solidity ^0.8.0;






interface Collection {
    struct ERC721Mints {
        address to;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    struct ERC1155Mints {
        address to;
        uint256[] amounts;
        bytes data;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    function initialize(
        address owner,
        address[] memory minters,
        string memory name,
        string memory symbol,
        ERC721Mints memory mints,
        address feeContract
    ) external;

    function initialize(
        address owner,
        address[] memory minters,
        ERC1155Mints memory mints,
        address feeContract
    ) external;
}

contract CollectionFactory is AccessControl {
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Feature;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address public erc721Implementation;
    address public erc1155Implementation;
    address public feeContract;
    bool public subscriptionCheckActive;

    event ERC721CollectionDeployed(
        address addr,
        string name,
        string symbol,
        address owner,
        address[] minters,
        string tokenData,
        Collection.ERC721Mints mints
    );
    event ERC1155CollectionDeployed(
        address addr,
        address owner,
        address[] minters,
        string tokenData,
        Collection.ERC1155Mints mints
    );

    constructor(
        address _owner,
        address[] memory _admins,
        address _ERC721Implementation,
        address _ERC1155Implementation,
        address _feeContract
    ) {
        erc721Implementation = _ERC721Implementation;
        erc1155Implementation = _ERC1155Implementation;
        feeContract = _feeContract;
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        subscriptionCheckActive = true;
    }

    function createERC721Collection(
        address _owner,
        address[] memory _minters,
        string memory _name,
        string memory _symbol,
        Collection.ERC721Mints memory _mints,
        string calldata _tokenData,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature,
        MediaEyeOrders.Feature memory _featureCollection
    ) external payable returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");
        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeCollectionFactory: must be subscribed to start a collection."
            );
            if (tier == 1) {
                require(
                    _minters.length == 0,
                    "MediaEyeCollectionFactory: must be subscribed to level 2 to start a group collection."
                );
            }
        }

        clone = Clones.clone(erc721Implementation);
        Collection(clone).initialize(
            _owner,
            _minters,
            _name,
            _symbol,
            _mints,
            feeContract
        );
        if (_featureCollection.feature) {
            if (_featureCollection.paymentMethod != address(0)) {
                IERC20(_featureCollection.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _featureCollection.price
                );
            }
            ISubscriptionTier.Featured memory featured = ISubscriptionTier
                .Featured(
                    0,
                    _featureCollection.numDays,
                    2,
                    clone,
                    0,
                    0,
                    _featureCollection.id,
                    _owner,
                    _featureCollection.price
                );
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _featureCollection.paymentMethod,
                _featureCollection.tokenAddresses,
                _featureCollection.tokenIds,
                featured
            );
        }

        emit ERC721CollectionDeployed(
            clone,
            _name,
            _symbol,
            _owner,
            _minters,
            _tokenData,
            _mints
        );
    }

    function createERC1155Collection(
        address _owner,
        address[] memory _minters,
        Collection.ERC1155Mints memory _mints,
        string calldata _tokenData,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature,
        MediaEyeOrders.Feature memory _featureCollection
    ) external payable returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");
        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeCollectionFactory: must be subscribed to start a collection."
            );
            if (tier == 1) {
                require(
                    _minters.length == 0,
                    "MediaEyeCollectionFactory: must be subscribed to level 2 to start a group collection."
                );
            }
        }

        clone = Clones.clone(erc1155Implementation);
        Collection(clone).initialize(_owner, _minters, _mints, feeContract);

        if (_featureCollection.feature) {
            if (_featureCollection.paymentMethod != address(0)) {
                IERC20(_featureCollection.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _featureCollection.price
                );
            }
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _featureCollection.paymentMethod,
                _featureCollection.tokenAddresses,
                _featureCollection.tokenIds,
                ISubscriptionTier.Featured(
                    0,
                    _featureCollection.numDays,
                    3,
                    clone,
                    0,
                    0,
                    _featureCollection.id,
                    _owner,
                    _featureCollection.price
                )
            );
        }

        emit ERC1155CollectionDeployed(
            clone,
            _owner,
            _minters,
            _tokenData,
            _mints
        );
    }

    function updateERC721Implementation(address _newERC721Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change 721 implementation."
        );
        erc721Implementation = _newERC721Implementation;
    }

    function updateERC1155Implementation(address _newERC1155Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change 1155 implementation."
        );
        erc1155Implementation = _newERC1155Implementation;
    }

    function updateFeeContract(address _newFeeContract) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change fee contract."
        );
        feeContract = _newFeeContract;
    }

    function updateSubscriptionCheck(bool _check) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change subscription check."
        );
        subscriptionCheckActive = _check;
    }
}