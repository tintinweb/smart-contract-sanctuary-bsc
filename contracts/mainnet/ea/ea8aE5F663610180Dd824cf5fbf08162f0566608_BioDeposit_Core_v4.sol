/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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


/**
 * @dev String operations.
 */
library StringsUpgradeable {
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





interface IBioDepositNFT {
    function tokenExists(uint256 _userTokenID) external view returns(bool);
    function tokenMint(address _to) external returns(uint256);
    function tokenIDByUser(address owner) external view returns (uint256);
    function ownerOfToken(uint256 _userTokenID) external view returns(address);
    function balanceOfAddress(address owner) external view returns(uint256);
}


interface IBioDepositTree {
    function getTreeInfoByID(uint32 _treeID) external view returns(string memory, uint16, string memory, string memory, uint128, uint128, uint128);
}


interface IBioDepositInit {
    function getLevelData_1(uint8 _levelIndex) external view returns(uint128, uint128, uint128, uint128);
    function getLevelData_2(uint8 _levelIndex) external view returns(uint16, uint16, uint16);
    function getLBonusData(uint8 _levelIndex) external view returns(uint128, uint128, uint128, uint128, uint128);
}

interface IBioDepositCore {
    function setLastItemID (uint8 _productID, uint32 _lastItemID) external;
}
/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
    uint256[49] private __gap;
}



/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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
    uint256[49] private __gap;
}

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


contract BioDeposit_Core_v4 is AccessControlUpgradeable, PausableUpgradeable
{
    struct Level{
        uint128 personalDeposit; // Personal Deposit Requirement in USDT for this level (18 decimals)
        uint128 firstLineVolume; // First Line Volume Requirement in USDT for this level (18 decimals)
        uint128 structureVolume; // Structure Volume Requirement in USDT for this level(18 decimals)
        uint128 investorVolume; // Investor Volume Requirement in USDT for this level(18 decimals)

        uint16 USDBonus; //USD Bonus*1000. 4% = 40
        uint16 revenueBonus; // Revenue Bonus*1000. 1.5% = 15
        uint16 utilityBonus; // Utitlity Bonus*1000. 1.5% = 15
    }

    Level[10] private levels;


   struct LeaderBonus{
        uint128 personalDeposit; // Personal Deposit Requirement in USDT for this level (18 decimals)
        uint128 firstLineVolume; // First Line Volume Requirement in USDT for this level (18 decimals)
        uint128 mainBranchVolume; // Main Branch Volume Requirement in USDT for this level(18 decimals)
        uint128 sideBranchVolume; // Side Branch Volume Requirement in USDT for this level(18 decimals)
        uint128 USDBonus; //USD Bonus in USDT (18 decimals)  
    }

    LeaderBonus[22] private LBonus;


    struct Product{
        uint128 price; // Full product price that user should pay in USDT (18 decimals)
        uint128 cost1; // Amount of USDT we should send to CostAddress_1 (18 decimals)
        uint128 cost2; // Amount of USDT we should send to CostAddress_2 (18 decimals)
        address costAddress_1; //Address #1 we should send usdt for covering costs
        address costAddress_2; //Address #2 we should send usdt for covering costs
        uint32 itemsAmount; // How many items of the product available for sale
        uint32 lastItemID; // ID of first unsold item
        bool isActive; // Is this product currently acive
    }

    Product[10] private products;


    struct User{
        uint8 level; // User Level
        uint8 lblevel; // User LBLevel
        uint256[] parents; // Parent IDs Array
        uint256[] firstLine; // First Line IDs Array
        uint32[][10] productIDs; // Product IDs arrays

        uint128 personalDeposit; // Personal Deposit in USDT (18 decimals)
        uint128 firstLineVolume; // First Line Volume in USDT (18 decimals)
        uint128 mainBranchVolume; // Main Branch Volume in USDT (18 decimals)
        uint128 sideBranchVolume; // Side Branch Volume in USDT (18 decimals)
        uint128 structureVolume; // Structure Volume in USDT (18 decimals)

        uint128 USDBalance; //Total Balance in USDT (18 decimals)
        uint128 USDBalanceWithdrawn; //Withdrawn Balance in USDT (18 decimals)

        uint128 revenueBalance; //Revenue Balance in revenue token (18 decimals)
        uint128 revenueBalanceWithdrawn; //Withdrawn Balance in revenue token (18 decimals)

        uint128 utilityBalance; //Utility Balance in utility token (18 decimals)
        uint128 utilityBalanceWithdrawn; //Withdrawn Balance in utility token (18 decimals)

        bool isLevelProtected; // Does user have his Level protected from lowering
        string imageHash; // imageHash in IPFS
    }

    mapping(uint256 => User) private users; //tokenID => User; tokenID starts from 1;
    
    uint128[10] private totalBuyAmounts; // Total Buy Amounts By Products in USDT (18 decimals)
    uint128[3] private counters; // Admin totals in USDT (18 decimals)
                                 // [0] - totalUniLevelBonusBalance
                                 // [1] - totalLeaderBonusBalance
                                 // [2] - USDTWithdrawn
    address private constant service_1 = 0xD2308164406E4cd89756e6aF9B0e4809B685B9CB;
    address private constant service_2 = 0x058C02254965Cf3e6d19a7ea9d5a80ba7655EBA6;

    bool private isPromoLive;

    uint8 storageVersion;
    IERC20Metadata public usdt;

    address NFTContract;
    address initContract;
    address[10] productContract;

    event rewardClaimed(uint256 indexed tokenID, uint128 payoutAmount);
    event productBought(uint256 indexed tokenID, uint8 productID, uint32 itemsAmount, uint128 usdtAmount);
    event nftMinted(uint256 indexed tokenID);
    event gotBonus(uint256 indexed toTokenID, uint256 fromTokenID, uint128 bonusAmount);
    event gotLeaderBonus(uint256 indexed toTokenID, uint8 bonusLevel, uint128 bonusAmount);


    function initialize(address _NFTContract) public initializer {
        __Pausable_init_unchained();
        __AccessControl_init_unchained();      
 
        //2 ADMIN ADDRESSES
        _setupRole(DEFAULT_ADMIN_ROLE, 0x058C02254965Cf3e6d19a7ea9d5a80ba7655EBA6);
        _setupRole(DEFAULT_ADMIN_ROLE, 0xD2308164406E4cd89756e6aF9B0e4809B685B9CB);

        usdt = IERC20Metadata(0x55d398326f99059fF775485246999027B3197955);
        NFTContract = _NFTContract;

        storageVersion = version(); 
    }


    function version() public pure returns (uint8){
        return uint8(0);
    }


    function updateStorage() public {
        require (storageVersion < version(), "Can't upgrade. Already done!");
        storageVersion = version();
    }


//*************** USER FUNCTIONS ******************************* */

   // user mints BioDeposit NFT
   function mint(uint256 _parentTokenID) public whenNotPaused(){
        require(!isContract(msg.sender), "Contract calls are not available");
        require(IBioDepositNFT(NFTContract).balanceOfAddress(msg.sender) == 0, "NFT is already minted for this address");

        uint256 mintedTokenID = IBioDepositNFT(NFTContract).tokenMint(msg.sender);

        if (mintedTokenID != 1) {
            if(IBioDepositNFT(NFTContract).tokenExists(_parentTokenID)){
                users[mintedTokenID].parents.push(_parentTokenID);
                users[_parentTokenID].firstLine.push(mintedTokenID);            
            }else{ 
            users[mintedTokenID].parents.push(1);
            users[1].firstLine.push(mintedTokenID);
            }
        }

        if ((mintedTokenID > 1) && (users[_parentTokenID].parents.length > 0)) {
            uint i=0;
            while (i < users[_parentTokenID].parents.length) {
                users[mintedTokenID].parents.push(users[_parentTokenID].parents[i]);
                i++;
            }
        }
        emit nftMinted(mintedTokenID);
    }


    // user buys products
    function buyProduct(uint8 _productID, uint32 _itemsAmount) public whenNotPaused(){
        uint256 _userTokenID = IBioDepositNFT(NFTContract).tokenIDByUser(msg.sender);
    
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "_userTokenID doesn't exist");
        require(!isContract(msg.sender), "Contract calls are not available");

        require(products.length > _productID, "Invalid productID");
        require(products[_productID].isActive, "Product is inactive");

        require((_itemsAmount > 0) && (_itemsAmount < 1000), "Not a valid buy amount");
        require((products[_productID].lastItemID + _itemsAmount) <= products[_productID].itemsAmount, "Not enough products for sale");

        uint128 amountPaid = products[_productID].price * _itemsAmount;
        uint128 usdtAmount = amountPaid;


        //receive payment
        uint256 balanceBefore = usdt.balanceOf(address(this));
        usdt.transferFrom(msg.sender, address(this), amountPaid);
        require(usdt.balanceOf(address(this)) - balanceBefore == amountPaid, "USDT Payment error");
      

        // transfer funds
        amountPaid -= amountPaid*25/100;

        usdt.transfer(products[_productID].costAddress_1, products[_productID].cost1 * _itemsAmount);
        amountPaid -= products[_productID].cost1 * _itemsAmount;

        usdt.transfer(products[_productID].costAddress_2, products[_productID].cost2 * _itemsAmount);
        amountPaid -= products[_productID].cost2 * _itemsAmount;

        usdt.transfer(service_1, amountPaid/2);
        usdt.transfer(service_2, amountPaid/2);


        // updating structure
        totalBuyAmounts[_productID] += usdtAmount;
        users[_userTokenID].personalDeposit += usdtAmount;
        checkLevel(_userTokenID);
        checkLBLevel(_userTokenID);

        // processing promo
        if ((isPromoLive) && (usdtAmount >= 3000000000000000000000)){
            setUserLevel(_userTokenID, 4);
        }

        if ((isPromoLive) && (usdtAmount >= 5000000000000000000000)){
            setUserLevel(_userTokenID, 5);
        }


        // adding IDs of products
        addItems(_userTokenID, _productID, _itemsAmount);

        emit productBought(_userTokenID, _productID, _itemsAmount, usdtAmount);

        if ((users[_userTokenID].parents.length == 0) || 
           (!IBioDepositNFT(NFTContract).tokenExists(users[_userTokenID].parents[0]))){
           return;
        }        


        // updating parents stat
        uint256 parentID = users[_userTokenID].parents[0];

        users[parentID].firstLineVolume += usdtAmount;
        users[parentID].structureVolume += usdtAmount;
        checkLevel(parentID);

        users[parentID].USDBalance += usdtAmount*levels[users[parentID].level].USDBonus/1000;
        emit gotBonus(parentID, _userTokenID, usdtAmount*levels[users[parentID].level].USDBonus/1000);
        counters[0] += usdtAmount*levels[users[parentID].level].USDBonus/1000;
        
        users[parentID].revenueBalance += usdtAmount*levels[users[parentID].level].revenueBonus/1000;
        users[parentID].utilityBalance += usdtAmount*levels[users[parentID].level].utilityBonus/1000;

        (users[parentID].mainBranchVolume, users[parentID].sideBranchVolume) = calcBV(parentID);
        checkLBLevel(parentID);

        uint8 tempLevel = users[parentID].level;

        if (users[_userTokenID].parents.length > 1) {
            for (uint i=1; i < users[_userTokenID].parents.length; i++){
                users[users[_userTokenID].parents[i]].structureVolume += usdtAmount;
                checkLevel(users[_userTokenID].parents[i]);
                (users[users[_userTokenID].parents[i]].mainBranchVolume, users[users[_userTokenID].parents[i]].sideBranchVolume) = calcBV(users[_userTokenID].parents[i]);
                checkLBLevel(users[_userTokenID].parents[i]);

                if (users[users[_userTokenID].parents[i]].level > tempLevel){
                    uint128 usdReward = usdtAmount*(levels[users[users[_userTokenID].parents[i]].level].USDBonus - levels[tempLevel].USDBonus)/1000;
                    users[users[_userTokenID].parents[i]].USDBalance += usdReward;
                    emit gotBonus(users[_userTokenID].parents[i], _userTokenID, usdReward);
                    tempLevel = users[users[_userTokenID].parents[i]].level;
                    counters[0] += usdReward;
                }
            }

        }
    }


    // user claims reward
    function claimReward() public whenNotPaused() {
        uint256 _tokenID = IBioDepositNFT(NFTContract).tokenIDByUser(msg.sender);
      
        require(IBioDepositNFT(NFTContract).tokenExists(_tokenID), "_tokenID doesn't exist");       
        require(!isContract(msg.sender), "Contract calls are not allowed");

        uint128 payoutAmount = users[_tokenID].USDBalance - users[_tokenID].USDBalanceWithdrawn;
        require(usdt.balanceOf(address(this)) >= payoutAmount, "Contract USDT Balance Low");
        users[_tokenID].USDBalanceWithdrawn = users[_tokenID].USDBalance;

        if (_tokenID == 1){
            usdt.transfer(service_1, payoutAmount/2);
            usdt.transfer(service_2, payoutAmount/2);
        }else{
            usdt.transfer(msg.sender, payoutAmount);
        }
        counters[2] += payoutAmount;

        emit rewardClaimed(_tokenID, payoutAmount);
    }

    // updating lastProductID
    function setLastItemID (uint8 _productID, uint32 _lastItemID) external {
        require(msg.sender == 0x6122C8Ca7d7387945ECa57dF9394Cc166A495dd1, "Only CoreContract can call");

        products[_productID].lastItemID = _lastItemID;
    }


//*************** ADMIN FUNCTIONS ******************************* */
    
    // admin mints BioDeposit NFT for user
   function admin_mint(address _receiver, uint256 _parentTokenID, uint8 _startLevel, bool _levelProtected) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused(){

        require(IBioDepositNFT(NFTContract).balanceOfAddress(_receiver) == 0, "NFT is already minted");

        uint256 mintedTokenID = IBioDepositNFT(NFTContract).tokenMint(_receiver);

         if (mintedTokenID != 1) {
            if(IBioDepositNFT(NFTContract).tokenExists(_parentTokenID)){
                users[mintedTokenID].parents.push(_parentTokenID);
                users[_parentTokenID].firstLine.push(mintedTokenID);            
            }else{ 
            users[mintedTokenID].parents.push(1);
            users[1].firstLine.push(mintedTokenID);
            }
        }

        users[mintedTokenID].level = _startLevel;
        users[mintedTokenID].isLevelProtected = _levelProtected;     

        if ((mintedTokenID > 1) && (users[_parentTokenID].parents.length > 0)) {
            uint i=0;
            while (i < users[_parentTokenID].parents.length) {
                users[mintedTokenID].parents.push(users[_parentTokenID].parents[i]);
                i++;
            }
        }
    }


    //admin adds items to user by ID
    function adminAddItems(uint256 _userTokenID, uint8 _productID, uint32 _itemsAmount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(products.length > _productID, "Invalid productID");        
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
        require((products[_productID].lastItemID + _itemsAmount) <= products[_productID].itemsAmount, "Not enough products for adding");

        addItems(_userTokenID, _productID, _itemsAmount);
        totalBuyAmounts[9] += _itemsAmount;
    }

    //admin moves Items from user1 to user2
    function adminTransferItems(uint256 user1_TokenID, uint256 user2_TokenID, uint8 _productID) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(products.length > _productID, "Invalid productID");        
        require(IBioDepositNFT(NFTContract).tokenExists(user1_TokenID), "user1 doesn't exist");
        require(IBioDepositNFT(NFTContract).tokenExists(user2_TokenID), "user2 doesn't exist");
        require(users[user1_TokenID].productIDs[_productID].length>0, "Nothing to move");

        for (uint32 i=0; i < users[user1_TokenID].productIDs[_productID].length; i++){
          users[user2_TokenID].productIDs[_productID].push(users[user1_TokenID].productIDs[i][_productID]);
        }

        while (users[user1_TokenID].productIDs[_productID].length > 0) {
          users[user1_TokenID].productIDs[_productID].pop();
        }
    }

    //admin sets address of BioDeposit products contracts
    function setProductContractAddress(uint8 _productIndex, address _productContract) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_productIndex < products.length, "Product index is out of bounds");
        productContract[_productIndex] = _productContract;
    }

    // admin sets level for user. Level can not be lowered!
    function adminSetUserLevel(uint256 _userTokenID, uint8 _newLevel) public onlyRole(DEFAULT_ADMIN_ROLE) {
        setUserLevel(_userTokenID, _newLevel);
    }


    // admin updates existing product by its ID
    function updateProduct(uint8  _productIndex,
                           uint128 _price,
                           uint128 _cost1,
                           uint128 _cost2,
                           address _costAddress_1,
                           address _costAddress_2                           
                           ) public onlyRole(DEFAULT_ADMIN_ROLE){

        require(_productIndex < products.length, "Product index is out of bounds");

        products[_productIndex].price = _price;
        products[_productIndex].cost1 = _cost1;
        products[_productIndex].cost2 = _cost2;
        products[_productIndex].costAddress_1 =  _costAddress_1;
        products[_productIndex].costAddress_2 =  _costAddress_2;
    }

    // admin updates available product price by _productIndex
    function updateProductPrice(uint8 _productIndex, uint32 _newPrice) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(_productIndex < products.length, "Product index is out of bounds");
        products[_productIndex].price = _newPrice;
    }


    // admin updates available product amount by _productIndex
    function updateProductAmount(uint8 _productIndex, uint32 _newAmount) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(_productIndex < products.length, "Product index is out of bounds");
        products[_productIndex].itemsAmount = _newAmount;
    }


    // admin changes product status i.e. active -> inactive or vice versa
    function changeProductStatus(uint8 _productIndex) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(_productIndex < products.length, "Product index is out of bounds");
        products[_productIndex].isActive = !products[_productIndex].isActive;
    }


    // admin changes status of promo
    function changePromoStatus() public onlyRole(DEFAULT_ADMIN_ROLE){
        isPromoLive = !isPromoLive;
    }


    // admin removes user's level protection
    function removeLevelProtection(uint256 _userTokenID) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
        users[_userTokenID].isLevelProtected = false;
    }

    // admin updates LBonus
    function updateLBonus() public onlyRole(DEFAULT_ADMIN_ROLE){
        require(usdt.balanceOf(address(this)) > (counters[0]+counters[1]-counters[2]), "no LBonus available");
        usdt.transfer(msg.sender, usdt.balanceOf(address(this)) - (counters[0]+counters[1]-counters[2]));

    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        super._pause();
    }


    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        super._unpause();
    }


    //***************** VIEW Functions ************************/

    function getUserDataByID_1(uint256 _userTokenID) external view returns(uint256, uint256, uint8, uint8, uint256){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
       
        uint256 _parentID = 1;
        if (users[_userTokenID].parents.length > 0){
            _parentID = users[_userTokenID].parents[0];
        }

        return(
        _userTokenID,
        _parentID,
                       
        users[_userTokenID].level,
        users[_userTokenID].lblevel,

        users[_userTokenID].productIDs[0].length
        );
    }


   function getUserDataByID_2(uint256 _userTokenID) external view returns(uint128, uint128, uint128, uint128, uint128){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
      
        return(
        users[_userTokenID].personalDeposit,

        users[_userTokenID].firstLineVolume,
        users[_userTokenID].mainBranchVolume, 

        users[_userTokenID].sideBranchVolume, 
        users[_userTokenID].structureVolume
        );
    }


    function getUserDataByID_3(uint256 _userTokenID) external view returns(uint128, uint128, uint128, uint128, uint128){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
       
        return(
        users[_userTokenID].revenueBalance,
        users[_userTokenID].utilityBalance,

        users[_userTokenID].USDBalance,
        users[_userTokenID].USDBalanceWithdrawn,

        users[_userTokenID].USDBalance - users[_userTokenID].USDBalanceWithdrawn
        );
    }


    function getProductInfo(uint8 _productID) external view returns(uint128, uint128, uint128, address, address, uint32, uint32){
        require(_productID < products.length, "Product ID is out of bounds");

        return(
            products[_productID].price,
            products[_productID].cost1,
            products[_productID].cost2,
            products[_productID].costAddress_1,
            products[_productID].costAddress_2,
            products[_productID].itemsAmount,
            products[_productID].lastItemID
        );
    }


    function isProductActive(uint8 _productID) external view returns(bool){
        require(_productID < products.length, "Product ID is out of bounds");
        return products[_productID].isActive;
    }


    function checkPromoLive() external view returns(bool){
        return isPromoLive;
    }


    function getTreeInfo(uint32 _treeID) external view returns(string memory, uint16, string memory, string memory, uint128, uint128, uint128) {
        return IBioDepositTree(productContract[0]).getTreeInfoByID(_treeID);
    }


    function getUserParents(uint256 _userTokenID) external view returns(uint256[] memory){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
        return users[_userTokenID].parents;
    }


    function getUserFirstLine(uint256 _userTokenID) external view returns(uint256[] memory){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
        return users[_userTokenID].firstLine;
    }


    function getUserProductIDs(uint256 _userTokenID, uint8 _productID) external view returns(uint32[] memory){
        require(IBioDepositNFT(NFTContract).tokenExists(_userTokenID), "user doesn't exist");
        require(_productID < products.length, "Product ID is out of bounds");
        return users[_userTokenID].productIDs[_productID];
    }


    // get total buy amounts  (18 decimals)
    function getTotals() external view returns(uint128[10] memory) {
        return totalBuyAmounts;
    }


    // get counters (18 decimals)
    function getCounters() external view returns(uint128[3] memory) {
        return counters;
    }

    //***************** INTERNAL Functions ************************/

    // checks user level
    function checkLevel(uint256 _userTokenID) private{
        bool b = true;
        uint8 i = 0;
        uint8 currentLevel = users[_userTokenID].level;

        while ((b == true) && (i<10)){


           if (((users[_userTokenID].personalDeposit >= levels[i].personalDeposit) &&
              (users[_userTokenID].firstLineVolume >= levels[i].firstLineVolume) &&
              (users[_userTokenID].structureVolume >= levels[i].structureVolume)) ||
              (users[_userTokenID].personalDeposit >= levels[i].investorVolume)){
                  users[_userTokenID].level = i;
                  i++;
                  } else {
                      b = false;
                    }
            }

        if ((users[_userTokenID].isLevelProtected) && (users[_userTokenID].level < currentLevel)){
                    
            users[_userTokenID].level = currentLevel;
        }   
    }


    // checks user LBonus level
    function checkLBLevel(uint256 _userTokenID) private{
        bool b = true;
        uint8 i = users[_userTokenID].lblevel+1;

        while ((b == true) && (i<22)){
            
            if ((users[_userTokenID].personalDeposit >= LBonus[i].personalDeposit) &&
               (users[_userTokenID].firstLineVolume >= LBonus[i].firstLineVolume) &&
               (users[_userTokenID].mainBranchVolume >= LBonus[i].mainBranchVolume) &&
               (users[_userTokenID].sideBranchVolume >= LBonus[i].sideBranchVolume)){

                   users[_userTokenID].lblevel = i;
                   users[_userTokenID].USDBalance += LBonus[i].USDBonus;  
                   emit gotLeaderBonus(_userTokenID, i, LBonus[i].USDBonus);
                   counters[1] += LBonus[i].USDBonus;
                   i++;
                } else {
                    b = false;
            }
        } 
    }


    // returns user's mainBranchVolume and sideBranchVolume by userTokenID
    function calcBV(uint256 _userTokenID) private view returns (uint128 mainBV, uint128 sideBV){
        if (users[_userTokenID].firstLine.length == 0) {
            return (0,0);
        }
        
        if (users[_userTokenID].firstLine.length == 1) {
            return (users[users[_userTokenID].firstLine[0]].structureVolume + 
                    users[users[_userTokenID].firstLine[0]].personalDeposit,0);
            }
        
        if (users[_userTokenID].firstLine.length > 1) {
            uint128 max = 0;
            uint128 sum = 0;
            uint128 c = 0;

            for (uint i=0; i < users[_userTokenID].firstLine.length; i++){
                    c = users[users[_userTokenID].firstLine[i]].structureVolume + users[users[_userTokenID].firstLine[i]].personalDeposit;
                    sum += c;
                    if (c > max){
                        max = c;
                    }
            }
            return (max, sum - max);
        }
    }    


    // updates user's level (only usable while promo is live)
    function setUserLevel(uint256 _userTokenID, uint8 _newLevel) private{
        require(_newLevel > users[_userTokenID].level, "Can not decrease level");
        require(_newLevel < levels.length, "Max Level is 9");

        users[_userTokenID].level = _newLevel;
        users[_userTokenID].isLevelProtected = true;
    }


    // adds product IDs to user's productIDs array  
    function addItems(uint256 _userTokenID, uint8 _productID, uint32 _itemsAmount) private{
        uint32 i = 0;
        while (i < _itemsAmount){
            users[_userTokenID].productIDs[_productID].push(products[_productID].lastItemID+i);
            i++;
        }
        products[_productID].lastItemID+= _itemsAmount;

        // update lastItemID in VIPContract
        IBioDepositCore(0x6122C8Ca7d7387945ECa57dF9394Cc166A495dd1).setLastItemID(_productID, products[_productID].lastItemID);
    }


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
}