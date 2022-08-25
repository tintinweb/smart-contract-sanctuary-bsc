/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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



/*

interface IBioDeposit {
    function tokenExists(uint256 _userTokenID) external view returns(bool);
    function tokenMint(address _to) external returns(uint256);
    function tokenIDByUser(address owner) external view returns (uint256);
    function ownerOfToken(uint256 _userTokenID) external view returns(address);
    function balanceOfAddress(address owner) external view returns(uint256);
}

*/
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


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


contract BioDeposit_Init is AccessControlUpgradeable, PausableUpgradeable
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


    uint8 storageVersion;

 
    function initialize() public initializer {
        __Pausable_init_unchained();
        __AccessControl_init_unchained();      
 
        //2 ADMIN ADDRESSES
        _setupRole(DEFAULT_ADMIN_ROLE, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        _setupRole(DEFAULT_ADMIN_ROLE, 0xD2308164406E4cd89756e6aF9B0e4809B685B9CB);
        _setupRole(DEFAULT_ADMIN_ROLE, 0x058C02254965Cf3e6d19a7ea9d5a80ba7655EBA6);

 
        //Levels Initialize 
        levels[0].personalDeposit = 0;
        levels[0].firstLineVolume = 0;
        levels[0].structureVolume = 0;
        levels[0].investorVolume  = 0;
        levels[0].USDBonus        = 0;
        levels[0].revenueBonus    = 0;
        levels[0].utilityBonus    = 0;

        levels[1].personalDeposit = 1000000000000000000000;
        levels[1].firstLineVolume = 0;
        levels[1].structureVolume = 0;
        levels[1].investorVolume  = 1000000000000000000000;
        levels[1].USDBonus        = 40;
        levels[1].revenueBonus    = 15;
        levels[1].utilityBonus    = 15;

        levels[2].personalDeposit = 1500000000000000000000;
        levels[2].firstLineVolume =  750000000000000000000;
        levels[2].structureVolume = 2500000000000000000000;
        levels[2].investorVolume  = 2500000000000000000000;
        levels[2].USDBonus        = 50;
        levels[2].revenueBonus    = 15;
        levels[2].utilityBonus    = 15;

        levels[3].personalDeposit =  2000000000000000000000;
        levels[3].firstLineVolume =  2000000000000000000000;
        levels[3].structureVolume = 10000000000000000000000;
        levels[3].investorVolume  = 10000000000000000000000;
        levels[3].USDBonus        = 60;
        levels[3].revenueBonus    = 15;
        levels[3].utilityBonus    = 15;

        levels[4].personalDeposit =   2500000000000000000000;
        levels[4].firstLineVolume =   5000000000000000000000;
        levels[4].structureVolume =  40000000000000000000000;
        levels[4].investorVolume  =  40000000000000000000000;
        levels[4].USDBonus        = 80;
        levels[4].revenueBonus    = 15;
        levels[4].utilityBonus    = 15;

        levels[5].personalDeposit =    3500000000000000000000;
        levels[5].firstLineVolume =   15000000000000000000000;
        levels[5].structureVolume =  150000000000000000000000;
        levels[5].investorVolume  =  150000000000000000000000;
        levels[5].USDBonus        = 100;
        levels[5].revenueBonus    =  15;
        levels[5].utilityBonus    =  15;

        levels[6].personalDeposit =    5000000000000000000000;
        levels[6].firstLineVolume =   35000000000000000000000;
        levels[6].structureVolume =  500000000000000000000000;
        levels[6].investorVolume  =  500000000000000000000000;
        levels[6].USDBonus        = 120;
        levels[6].revenueBonus    =  15;
        levels[6].utilityBonus    =  15;

        levels[7].personalDeposit =    10000000000000000000000;
        levels[7].firstLineVolume =    80000000000000000000000;
        levels[7].structureVolume =  1250000000000000000000000;
        levels[7].investorVolume  =  1250000000000000000000000;
        levels[7].USDBonus        = 140;
        levels[7].revenueBonus    =  15;
        levels[7].utilityBonus    =  15;

        levels[8].personalDeposit =    25000000000000000000000;
        levels[8].firstLineVolume =   225000000000000000000000;
        levels[8].structureVolume =  2500000000000000000000000;
        levels[8].investorVolume  =  2500000000000000000000000;
        levels[8].USDBonus        = 160;
        levels[8].revenueBonus    =  15;
        levels[8].utilityBonus    =  15;

        levels[9].personalDeposit =    50000000000000000000000;
        levels[9].firstLineVolume =   500000000000000000000000;
        levels[9].structureVolume =  5000000000000000000000000;
        levels[9].investorVolume  =  5000000000000000000000000;
        levels[9].USDBonus        = 190;
        levels[9].revenueBonus    =  15;
        levels[9].utilityBonus    =  15;


        //LBonus Initialize
        LBonus[0].personalDeposit   = 0;
        LBonus[0].firstLineVolume   = 0;
        LBonus[0].mainBranchVolume  = 0;
        LBonus[0].sideBranchVolume  = 0;
        LBonus[0].USDBonus          = 0;

        LBonus[1].personalDeposit   = 1000000000000000000000;
        LBonus[1].firstLineVolume   = 0;
        LBonus[1].mainBranchVolume  = 1250000000000000000000;
        LBonus[1].sideBranchVolume  = 1250000000000000000000;
        LBonus[1].USDBonus          =   50000000000000000000;
       
        LBonus[2].personalDeposit   = 1000000000000000000000;
        LBonus[2].firstLineVolume   = 0;
        LBonus[2].mainBranchVolume  = 3125000000000000000000;
        LBonus[2].sideBranchVolume  = 3125000000000000000000;
        LBonus[2].USDBonus          =  100000000000000000000;

        LBonus[3].personalDeposit   = 1000000000000000000000;
        LBonus[3].firstLineVolume   = 0;
        LBonus[3].mainBranchVolume  = 5000000000000000000000;
        LBonus[3].sideBranchVolume  = 5000000000000000000000;
        LBonus[3].USDBonus          =  150000000000000000000;

        LBonus[4].personalDeposit   =  1000000000000000000000;
        LBonus[4].firstLineVolume   = 0;
        LBonus[4].mainBranchVolume  = 11750000000000000000000;
        LBonus[4].sideBranchVolume  = 11750000000000000000000;
        LBonus[4].USDBonus          =   200000000000000000000;

        LBonus[5].personalDeposit   =  1000000000000000000000;
        LBonus[5].firstLineVolume   = 0;
        LBonus[5].mainBranchVolume  = 18500000000000000000000;
        LBonus[5].sideBranchVolume  = 18500000000000000000000;
        LBonus[5].USDBonus          =   250000000000000000000;

        LBonus[6].personalDeposit   =   1000000000000000000000;
        LBonus[6].firstLineVolume   =   5000000000000000000000;
        LBonus[6].mainBranchVolume  =  25000000000000000000000;
        LBonus[6].sideBranchVolume  =  25000000000000000000000;
        LBonus[6].USDBonus          =    300000000000000000000;

        LBonus[7].personalDeposit   =   1300000000000000000000;
        LBonus[7].firstLineVolume   =   7250000000000000000000;
        LBonus[7].mainBranchVolume  =  40000000000000000000000;
        LBonus[7].sideBranchVolume  =  40000000000000000000000;
        LBonus[7].USDBonus          =    400000000000000000000;

        LBonus[8].personalDeposit   =   1600000000000000000000;
        LBonus[8].firstLineVolume   =   9500000000000000000000;
        LBonus[8].mainBranchVolume  =  56000000000000000000000;
        LBonus[8].sideBranchVolume  =  56000000000000000000000;
        LBonus[8].USDBonus          =    500000000000000000000;

        LBonus[9].personalDeposit   =   2000000000000000000000;
        LBonus[9].firstLineVolume   =  12000000000000000000000;
        LBonus[9].mainBranchVolume  =  75000000000000000000000;
        LBonus[9].sideBranchVolume  =  75000000000000000000000;
        LBonus[9].USDBonus          =    750000000000000000000;

        LBonus[10].personalDeposit   =    2650000000000000000000;
        LBonus[10].firstLineVolume   =   17250000000000000000000;
        LBonus[10].mainBranchVolume  =  130000000000000000000000;
        LBonus[10].sideBranchVolume  =  130000000000000000000000;
        LBonus[10].USDBonus          =    1000000000000000000000;

        LBonus[11].personalDeposit   =    3300000000000000000000;
        LBonus[11].firstLineVolume   =   22500000000000000000000;
        LBonus[11].mainBranchVolume  =  190000000000000000000000;
        LBonus[11].sideBranchVolume  =  190000000000000000000000;
        LBonus[11].USDBonus          =    1300000000000000000000;

        LBonus[12].personalDeposit   =    4000000000000000000000;
        LBonus[12].firstLineVolume   =   28000000000000000000000;
        LBonus[12].mainBranchVolume  =  250000000000000000000000;
        LBonus[12].sideBranchVolume  =  250000000000000000000000;
        LBonus[12].USDBonus          =    2000000000000000000000;

        LBonus[13].personalDeposit   =    5250000000000000000000;
        LBonus[13].firstLineVolume   =   39000000000000000000000;
        LBonus[13].mainBranchVolume  =  375000000000000000000000;
        LBonus[13].sideBranchVolume  =  375000000000000000000000;
        LBonus[13].USDBonus          =    3000000000000000000000;

        LBonus[14].personalDeposit   =    6700000000000000000000;
        LBonus[14].firstLineVolume   =   50000000000000000000000;
        LBonus[14].mainBranchVolume  =  500000000000000000000000;
        LBonus[14].sideBranchVolume  =  500000000000000000000000;
        LBonus[14].USDBonus          =    5000000000000000000000;

        LBonus[15].personalDeposit   =    8000000000000000000000;
        LBonus[15].firstLineVolume   =   60000000000000000000000;
        LBonus[15].mainBranchVolume  =  625000000000000000000000;
        LBonus[15].sideBranchVolume  =  625000000000000000000000;
        LBonus[15].USDBonus          =    7500000000000000000000;

        LBonus[16].personalDeposit   =   12000000000000000000000;
        LBonus[16].firstLineVolume   =  100000000000000000000000;
        LBonus[16].mainBranchVolume  =  825000000000000000000000;
        LBonus[16].sideBranchVolume  =  825000000000000000000000;
        LBonus[16].USDBonus          =   12000000000000000000000;

        LBonus[17].personalDeposit   =    16000000000000000000000;
        LBonus[17].firstLineVolume   =   140000000000000000000000;
        LBonus[17].mainBranchVolume  =  1050000000000000000000000;
        LBonus[17].sideBranchVolume  =  1050000000000000000000000;
        LBonus[17].USDBonus          =    18000000000000000000000;

        LBonus[18].personalDeposit   =    20000000000000000000000;
        LBonus[18].firstLineVolume   =   180000000000000000000000;
        LBonus[18].mainBranchVolume  =  1250000000000000000000000;
        LBonus[18].sideBranchVolume  =  1250000000000000000000000;
        LBonus[18].USDBonus          =    25000000000000000000000;

        LBonus[19].personalDeposit   =    30000000000000000000000;
        LBonus[19].firstLineVolume   =   290000000000000000000000;
        LBonus[19].mainBranchVolume  =  1650000000000000000000000;
        LBonus[19].sideBranchVolume  =  1650000000000000000000000;
        LBonus[19].USDBonus          =    50000000000000000000000;

        LBonus[20].personalDeposit   =    40000000000000000000000;
        LBonus[20].firstLineVolume   =   400000000000000000000000;
        LBonus[20].mainBranchVolume  =  2050000000000000000000000;
        LBonus[20].sideBranchVolume  =  2050000000000000000000000;
        LBonus[20].USDBonus          =    75000000000000000000000;

        LBonus[21].personalDeposit   =    50000000000000000000000;
        LBonus[21].firstLineVolume   =   500000000000000000000000;
        LBonus[21].mainBranchVolume  =  2500000000000000000000000;
        LBonus[21].sideBranchVolume  =  2550000000000000000000000;
        LBonus[21].USDBonus          =   150000000000000000000000;



        storageVersion = version(); 
    }


    function version() public pure returns (uint8){
        return uint8(0);
    }


    function updateStorage() public {
        require (storageVersion < version(), "Can't upgrade. Already done!");
        storageVersion = version();
    }


//*************** ADMIN FUNCTIONS ******************************* */
    
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        super._pause();
    }


    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        super._unpause();
    }



    //***************** VIEW Functions ************************/

    function getLevelData_1(uint8 _levelIndex) external view returns(uint128, uint128, uint128, uint128){
        require(_levelIndex < levels.length, "Level index is out of bound");

        return(
        levels[_levelIndex].personalDeposit,
        levels[_levelIndex].firstLineVolume,
        levels[_levelIndex].structureVolume,
        levels[_levelIndex].investorVolume
       );
    }


    function getLevelData_2(uint8 _levelIndex) external view returns(uint16, uint16, uint16){
        require(_levelIndex < levels.length, "Level index is out of bound");

        return(
         levels[_levelIndex].USDBonus,
        levels[_levelIndex].revenueBonus,
        levels[_levelIndex].utilityBonus
        );
    }


    function getLBonusData(uint8 _levelIndex) external view returns(uint128, uint128, uint128, uint128, uint128){
        require(_levelIndex < LBonus.length, "LB Level index is out of bound");

        return(
        LBonus[_levelIndex].personalDeposit,
        LBonus[_levelIndex].firstLineVolume,
        LBonus[_levelIndex].mainBranchVolume,
        LBonus[_levelIndex].sideBranchVolume,
        LBonus[_levelIndex].USDBonus
        );
    }


    function getContractSize() public view returns (uint256) {

        uint256 size;
        address account = address(this);
        assembly {
            size := extcodesize(account)
        }
        return size;
    }


    //***************** INTERNAL Functions ************************/


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