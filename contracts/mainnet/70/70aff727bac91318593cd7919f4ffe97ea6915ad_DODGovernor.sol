/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/*
 * Day of Defeat (DOD)
 *
 * Radical Social Experiment token mathematically designed to give holders 10,000,000X PRICE INCREASE
 *
 * Website: https://dayofdefeat.app/
 * Twitter: https://twitter.com/dayofdefeatBSC
 * Telegram: https://t.me/DayOfDefeatBSC
 * BTok: https://titanservice.cn/dayofdefeatCN
 *
 * By Studio L, Legacy Capital Division
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


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// File: StudioL/DOD/DODGovernor.sol



pragma solidity ^0.8.0;



interface IERC721 {
    /**
     * @dev Returns the owner of the `tokenId` token.
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    /**
     * @dev Returns the totalSupply of the NFT.
     */
    function totalSupply() external view returns (uint256);
}

interface IDOD {
    /**
     * @dev Returns the pool address of the DOD token.
     */
    function getPool() external view returns (address marketing, address fund);
    
    /**
     * @dev Returns the unlock status of the DOD token.
     */
    function getUnlockInfo() external view returns (
        uint256 _busdBalanceUnlocking,
        uint256 _totalSupplyUnlocking,
        uint256 _unlockTime,
        bool _stopTrade,
        bool _meetCriteria,
        bool _pass,
        uint256 _deadline,
        uint256 _exchangePeriod,
        uint256 _dodToBusdMultiplier
    );
}

/**
 * @dev Core of the governance system,.
 */
contract DODGovernor is AccessControl {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant CANCELLER_ROLE = keccak256("CANCELLER_ROLE");

    enum VoteType {
        For,
        Against,
        Abstain
    }

    enum ProposalState {
        NotExist,
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Expired,
        Executed
    }

    struct ProposalCore {
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        bytes32 descriptionHash;
        uint256 nonce;
    }

    struct ProposalResult {
        uint256 proposalId;
        address proposer;
        bool executed;
        bool canceled;
        uint32 startTime;
        uint32 votingPeriod;
        uint32 executingPeriod;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        uint256 votesRequired;
    }

    mapping(uint256 => ProposalCore) private _proposalCore;
    mapping(uint256 => ProposalResult) private _proposalResult;

    // proposalId => account => VoteType => votes(amount of dod nft)
    mapping(uint256 => mapping(address => mapping(VoteType => uint256))) private _userVotes;

    mapping(uint256 => mapping(uint256 => bool)) public hasVoted;
    mapping(uint256 => uint256) public nonceProposalId;

    uint256 private constant DIVISOR = 10000;

    uint32 public minVotingPeriod; // minimum vote time
    uint32 public minExecutingPeriod; // minimum executing time
    uint256 public minVotesRequired = 5000; // Occupies the smallest percentage of the current total NFT supply
    uint256 private _nonce;
    address public dodNft; // Voting rights
    address public dodToken; // DODv2 Token
    address public owner; // Deployer

    /**
     * @dev Emitted when a proposal is created.
     */
    event ProposalCreated(
        uint256 proposalId,
        uint256 nonce,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    );

    /**
     * @dev Emitted when a proposal is canceled.
     */
    event ProposalCanceled(uint256 proposalId);

    /**
     * @dev Emitted when a proposal is executed.
     */
    event ProposalExecuted(uint256 proposalId);

    /**
     * @dev Emitted when a vote is cast without params.
     *
     * Note: `VoteType` values should be seen as buckets. Their interpretation depends on the voting module used.
     */
    event VoteCast(
        address indexed voter,
        uint256 proposalId,
        VoteType voteType,
        uint256[] tokenIds,
        string reason
    );
    event UpdateVoteRequires(uint32 indexed _minVotingPeriod, uint32 indexed _minExecutingPeriod, uint256 _minVotesRequired);
    event UpdateToken(address indexed oldToken, address indexed newToken);

    constructor(
        address _dodNft,
        uint32 _minVotingPeriod,
        uint32 _minExecutingPeriod,
        uint256 _minVotesRequired,
        address[] memory proposers,
        address[] memory executors
    ) {
        require(_minVotingPeriod != 0, "DODGovernor: invalid voting period");
        require(_minExecutingPeriod != 0, "DODGovernor: invalid executing period");
        require(_minVotesRequired != 0 && _minVotesRequired <= DIVISOR, "DODGovernor: invalid votes target");
        require(
            _dodNft != address(0) && Address.isContract(_dodNft),
            "DODGovernor: invalid dod NFT"
        );
        dodNft = _dodNft;
        minVotingPeriod = _minVotingPeriod;
        minExecutingPeriod = _minExecutingPeriod;
        minVotesRequired = _minVotesRequired;
        owner = _msgSender();

        /**
         *  Manage roles through proposal voting,
         *  only this governance contract has administrator privileges
         */
        _setupRole(DEFAULT_ADMIN_ROLE, address(this));

        // register proposers and cancellers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
            _setupRole(CANCELLER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    /**
     * @dev See {IGovernorCompatibilityBravo-getActions}.
     */
    function getActions(
        uint256 proposalId
    )
        external
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            bytes32 descriptionHash,
            uint256 nonce
        )
    {
        ProposalCore storage proposalCore = _proposalCore[proposalId];
        return (
            proposalCore.targets,
            proposalCore.values,
            proposalCore.calldatas,
            proposalCore.descriptionHash,
            proposalCore.nonce
        );
    }

    /**
     * @dev See {IDODGovernor-hashProposal}.
     *
     * The proposal id is produced by hashing the ABI encoded `targets` array, the `values` array, the `calldatas` array
     * and the descriptionHash (bytes32 which itself is the keccak256 hash of the description string). This proposal id
     * can be produced from the proposal data which is part of the {ProposalCreated} event. It can even be computed in
     * advance, before the proposal is submitted.
     *
     */
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash,
        uint256 nonce
    ) public pure returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encode(
                        targets,
                        values,
                        calldatas,
                        descriptionHash,
                        nonce
                    )
                )
            );
    }

    /**
     * @dev See {IDODGovernor-state}.
     */
    function state(uint256 proposalId) public view returns (ProposalState) {
        ProposalResult storage proposal = _proposalResult[proposalId];

        if (proposal.startTime == 0) {
            return ProposalState.NotExist;
        }

        if (proposal.executed) {
            return ProposalState.Executed;
        }

        if (proposal.canceled) {
            return ProposalState.Canceled;
        }

        if (block.timestamp <= proposal.startTime) {
            return ProposalState.Pending;
        }

        if (
            block.timestamp > proposal.startTime &&
            block.timestamp <= proposal.startTime + proposal.votingPeriod
        ) {
            return ProposalState.Active;
        }

        if (
            block.timestamp >
            proposal.startTime +
                proposal.votingPeriod +
                proposal.executingPeriod
        ) {
            return ProposalState.Expired;
        }
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        if (
            ( totalVotes * ( DIVISOR / 1000 )) < ( IERC721(dodNft).totalSupply() * proposal.votesRequired / ( DIVISOR / 10 ) ) ||
            proposal.forVotes <= proposal.againstVotes
        ) {
            return ProposalState.Defeated;
        }

        return ProposalState.Succeeded;
    }

    /**
     * @dev Register a vote for `proposalId` by `account` with a given `For`, `Against` or `Abstain`.
     *
     * Note: VoteType is generic and can represent various things depending on the voting system used.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        VoteType voteType,
        uint256[] memory tokenIds
    ) internal {
        for (uint i = 0; i < tokenIds.length; i++) {
            require(
                !hasVoted[proposalId][tokenIds[i]],
                "_countVote: tokenId has been cast repeatedly"
            );
            require(
                IERC721(dodNft).ownerOf(tokenIds[i]) == account,
                "tokenId is not owned by the voter"
            );
            if (voteType == VoteType.For) {
                _proposalResult[proposalId].forVotes++;
            } else if (voteType == VoteType.Against) {
                _proposalResult[proposalId].againstVotes++;
            } else if (voteType == VoteType.Abstain) {
                _proposalResult[proposalId].abstainVotes++;
            }
            hasVoted[proposalId][tokenIds[i]] = true;
            _userVotes[proposalId][account][voteType]++;
        }
    }

    /**
     * @dev See nonce.
     */
    function currentNonce() external view returns (uint256) {
        return _nonce;
    }

    // ======================================== Governor proposal start ========================================

    function adjustmentFeeProposal(
        uint256 _marketingFee,
        uint256 _transitionFee,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(
            _marketingFee + _transitionFee <= 2500,
            "DODGovernor: total tax over 25%"
        );
        require(dodToken != address(0), "DODGovernor: dod token not initialized");

        bytes memory _calldata = abi.encodeWithSignature(
            "adjustmentFee(uint256,uint256)",
            _marketingFee,
            _transitionFee
        );
        proposalId = _propose(
            dodToken,
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function setVotePassProposal(
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        (, , , , bool _meetCriteria, bool _pass, , ,) = IDOD(dodToken).getUnlockInfo();
        require(_meetCriteria && !_pass, "Unlock bonus pool conditions not met");
        bytes memory _calldata = abi.encodeWithSignature("setVotePass()");
        proposalId = _propose(
            dodToken,
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function setPoolInCaseProposal(
        address _marketingPool,
        address _fundPool,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        require(_marketingPool != address(0), "Zero marketing pool");
        require(_fundPool != address(0), "Zero fund pool");
        require(
            Address.isContract(_marketingPool),
            "Marketing pool non contract address"
        );
        require(
            Address.isContract(_fundPool),
            "Fund pool non contract address"
        );

        (address marketing, address fund) = IDOD(dodToken).getPool();
        require(_marketingPool != marketing || _fundPool != fund, "Pool address unchanged");

        bytes memory _calldata = abi.encodeWithSignature("setPoolInCase(address,address)", _marketingPool, _fundPool);
        proposalId = _propose(
            dodToken,
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function setTradeInCase(
        bool enable,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        (, , uint256 _unlockTime, bool _stopTrade, , , , , ) = IDOD(dodToken).getUnlockInfo();
        require(_unlockTime != 0, "The bonus pool has not been unlocked yet");
        require(_stopTrade != enable, "Same value");

        bytes memory _calldata = abi.encodeWithSignature("setTradeInCase(bool)", enable);
        proposalId = _propose(
            dodToken,
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function setGovernorProposal(
        address _newGovernor,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        require(_newGovernor != address(0), "Zero governor");
        require(
            Address.isContract(_newGovernor),
            "New governor non contract address"
        );
        (address marketing, address fund) = IDOD(dodToken).getPool();

        bytes memory _calldata = abi.encodeWithSignature("setGovernor(address)", _newGovernor);
        address[] memory targets = new address[](3);
        targets[0] = marketing;
        targets[1] = fund;
        targets[2] = dodToken;
        uint256[] memory values = new uint256[](3);
        bytes[] memory calldatas = new bytes[](3);
        for (uint8 i = 0; i < 3; i++) {
            values[i] = 0;
            calldatas[i] = _calldata;
        }

        return _proposeMultiple(
            targets,
            values,
            calldatas,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function withdrawTokenProposal(
        address target,
        address _token,
        address _to,
        uint256 _amount,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        (address marketing, address fund) = IDOD(dodToken).getPool();
        require(target == dodToken || target == marketing || target == fund, "Non-dod target address");
        require(_to != address(0), "Zero recipient");

        bytes memory _calldata = abi.encodeWithSignature("withdrawToken(address,address,uint256)", _token, _to, _amount);
        proposalId = _propose(
            target,
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function grantRoleProposal(
        bytes32 _role,
        address _account,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(
            _role == DEFAULT_ADMIN_ROLE ||
                _role == PROPOSER_ROLE ||
                _role == EXECUTOR_ROLE ||
                _role == CANCELLER_ROLE,
            "Unknown role"
        );
        require(_account != address(0), "Zero account");
        require(!hasRole(_role, _account), "This account already has this role");

        bytes memory _calldata = abi.encodeWithSignature("grantRole(bytes32,address)", _role, _account);
        proposalId = _propose(
            address(this),
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function revokeRoleProposal(
        bytes32 _role,
        address _account,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(
            _role == DEFAULT_ADMIN_ROLE ||
                _role == PROPOSER_ROLE ||
                _role == EXECUTOR_ROLE ||
                _role == CANCELLER_ROLE,
            "Unknown role"
        );
        require(_account != address(0), "Zero account");
        require(hasRole(_role, _account), "This account does not have this role");

        bytes memory _calldata = abi.encodeWithSignature("revokeRole(bytes32,address)", _role, _account);
        proposalId = _propose(
            address(this),
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function updateVoteRequiresProposal(
        uint32 _minVotingPeriod,
        uint32 _minExecutingPeriod,
        uint256 _minVotesRequired,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(_minVotingPeriod != 0, "DODGovernor: invalid voting period");
        require(_minExecutingPeriod != 0, "DODGovernor: invalid executing period");
        require(_minVotesRequired != 0 && _minVotesRequired <= DIVISOR, "DODGovernor: invalid votes target");
        require(
            minVotingPeriod != _minVotingPeriod ||
            minExecutingPeriod != _minExecutingPeriod ||
            minVotesRequired != _minVotesRequired,
            "DODGovernor: same minimum value"
        );

        bytes memory _calldata = abi.encodeWithSignature(
            "updateVoteRequires(uint32,uint32,uint256)",
            _minVotingPeriod,_minExecutingPeriod,_minVotesRequired
        );

        return _propose(
            address(this),
            0,
            _calldata,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    function updateTokenProposal(
        address _dodToken,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256 proposalId) {
        require(dodToken != address(0), "DODGovernor: dod token not initialized");
        require(Address.isContract(_dodToken), "Non contract address");
        require(dodToken !=_dodToken, "Same address");

        (address marketing, address fund) = IDOD(dodToken).getPool();

        bytes memory _calldata = abi.encodeWithSignature("updateToken(address)", _dodToken);
        address[] memory targets = new address[](3);
        targets[0] = marketing;
        targets[1] = fund;
        targets[2] = address(this);
        uint256[] memory values = new uint256[](3);
        bytes[] memory calldatas = new bytes[](3);
        for (uint8 i = 0; i < 3; i++) {
            values[i] = 0;
            calldatas[i] = _calldata;
        }

        return _proposeMultiple(
            targets,
            values,
            calldatas,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    // ======================================== Governor proposal end ========================================

    /**
     * @dev Store proposal metadata for later lookup
     */
    function _storeProposalCore(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash,
        uint256 nonce
    ) private {
        ProposalCore storage proposalCore = _proposalCore[proposalId];
        proposalCore.targets = targets;
        proposalCore.values = values;
        proposalCore.calldatas = calldatas;
        proposalCore.descriptionHash = descriptionHash;
        proposalCore.nonce = nonce;
    }

    /**
     * @dev Store proposal detail for later lookup
     */
    function _storeProposalResult(
        uint256 proposalId,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) private {
        ProposalResult storage proposalResult = _proposalResult[proposalId];

        require(proposalResult.startTime == 0, "DODGovernor: proposal already exists");

        proposalResult.proposalId = proposalId;
        proposalResult.proposer = _msgSender();
        proposalResult.startTime = startTime;
        proposalResult.votingPeriod = votingPeriod;
        proposalResult.executingPeriod = executingPeriod;
        proposalResult.votesRequired = votesRequired;
    }

    /**
     * @dev propose single action.
     */
    function _propose(
        address target,
        uint256 value,
        bytes memory targetCalldata,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) internal onlyRoleOrOpenRole(PROPOSER_ROLE) returns (uint256) {
        require(startTime > block.timestamp, "DODGovernor: invalid start time");
        require(
            votingPeriod >= minVotingPeriod,
            "DODGovernor: invalid voting period"
        );
        require(
            executingPeriod >= minExecutingPeriod,
            "DODGovernor: invalid executing period"
        );
        require(votesRequired >= minVotesRequired,
            "DODGovernor: invalid votes target"
        );
        require(
            target != address(0) && Address.isContract(target),
            "DODGovernor: invalid target"
        );

        address[] memory targets = new address[](1);
        targets[0] = target;
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = targetCalldata;

        _nonce++;

        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash,
            _nonce
        );

        _storeProposalCore(proposalId, targets, values, calldatas, descriptionHash, _nonce);
        _storeProposalResult(proposalId, startTime, votingPeriod, executingPeriod, votesRequired);

        nonceProposalId[_nonce] = proposalId;

        emit ProposalCreated(
            proposalId,
            _nonce,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );

        return proposalId;
    }

    /**
     * @dev propose multiple action.
     */
    function _proposeMultiple(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) internal onlyRoleOrOpenRole(PROPOSER_ROLE) returns (uint256) {
        require(startTime > block.timestamp, "DODGovernor: invalid start time");
        require(
            votingPeriod >= minVotingPeriod,
            "DODGovernor: invalid voting period"
        );
        require(
            executingPeriod >= minExecutingPeriod,
            "DODGovernor: invalid executing period"
        );
        require(votesRequired >= minVotesRequired,
            "DODGovernor: invalid votes target"
        );
        require(targets.length > 0, "DODGovernor: empty proposal");
        require(
            targets.length == values.length,
            "DODGovernor: invalid proposal length"
        );
        require(
            targets.length == calldatas.length,
            "DODGovernor: invalid calldata length"
        );

        for (uint i = 0; i < targets.length; i++) {
            require(
                targets[i] != address(0) && Address.isContract(targets[i]),
                "DODGovernor: invalid target"
            );
        }
        _nonce++;

        bytes32 descriptionHash = keccak256(bytes(description));

        uint256 proposalId = hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash,
            _nonce
        );

        ProposalCore storage proposalCore = _proposalCore[proposalId];
        proposalCore.targets = targets;
        proposalCore.values = values;
        proposalCore.calldatas = calldatas;
        proposalCore.descriptionHash = descriptionHash;
        proposalCore.nonce = _nonce;

        ProposalResult storage proposalResult = _proposalResult[proposalId];

        require(
            proposalResult.startTime == 0,
            "DODGovernor: proposal already exists"
        );

        proposalResult.proposalId = proposalId;
        proposalResult.proposer = _msgSender();
        proposalResult.startTime = startTime;
        proposalResult.votingPeriod = votingPeriod;
        proposalResult.executingPeriod = executingPeriod;
        proposalResult.votesRequired = votesRequired;

        nonceProposalId[_nonce] = proposalId;
        emit ProposalCreated(
            proposalId,
            _nonce,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );

        return proposalId;
    }

    /**
     * @dev Propose multiple actions.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        uint32 startTime,
        uint32 votingPeriod,
        uint32 executingPeriod,
        uint256 votesRequired
    ) external returns (uint256) {
        return _proposeMultiple(
            targets,
            values,
            calldatas,
            description,
            startTime,
            votingPeriod,
            executingPeriod,
            votesRequired
        );
    }

    /**
     * @dev See {IDODGovernor-execute}.
     */
    function execute(
        uint256 proposalId
    ) external payable onlyRoleOrOpenRole(EXECUTOR_ROLE) returns (uint256) {
        ProposalState status = state(proposalId);
        require(
            status == ProposalState.Succeeded,
            "DODGovernor: proposal not successful"
        );
        _proposalResult[proposalId].executed = true;

        emit ProposalExecuted(proposalId);

        _execute(
            _proposalCore[proposalId].targets,
            _proposalCore[proposalId].values,
            _proposalCore[proposalId].calldatas
        );

        return proposalId;
    }

    /**
     * @dev See {IDODGovernor-execute}.
     */
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash,
        uint256 nonce
    ) external payable onlyRoleOrOpenRole(EXECUTOR_ROLE) returns (uint256) {
        uint256 proposalId = hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash,
            nonce
        );

        ProposalState status = state(proposalId);
        require(
            status == ProposalState.Succeeded,
            "DODGovernor: proposal not successful"
        );
        _proposalResult[proposalId].executed = true;

        emit ProposalExecuted(proposalId);

        _execute(targets, values, calldatas);

        return proposalId;
    }

    /**
     * @dev Internal execution mechanism.
     */
    function _execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) internal {
        string memory errorMessage = "DODGovernor: call reverted without message";
        require(targets.length > 0, "DODGovernor: empty proposal");
        require(
            targets.length == calldatas.length,
            "DODGovernor: invalid proposal length"
        );
        for (uint256 i = 0; i < targets.length; ++i) {
            require(targets[i] != address(0), "DODGovernor: invalid target");
            (bool success, bytes memory returndata) = targets[i].call{
                value: values[i]
            }(calldatas[i]);
            Address.verifyCallResult(success, returndata, errorMessage);
        }
    }

    /**
     * @dev Internal cancel mechanism: locks up the proposal timer, preventing it from being re-submitted. Marks it as
     * canceled to allow distinguishing it from executed proposals.
     *
     * Emits a {IDODGovernor-ProposalCanceled} event.
     */
    function cancel(
        uint256 proposalId
    ) external onlyRoleOrOpenRole(CANCELLER_ROLE) returns (uint256) {
        ProposalState status = state(proposalId);

        require(
            status != ProposalState.Canceled &&
                status != ProposalState.Expired &&
                status != ProposalState.Executed,
            "DODGovernor: proposal not active"
        );
        require(
            _msgSender() == _proposalResult[proposalId].proposer,
            "DODGovernor: caller is not the proposer"
        );
        _proposalResult[proposalId].canceled = true;

        emit ProposalCanceled(proposalId);

        return proposalId;
    }

    /**
     * @dev Internal cancel mechanism: locks up the proposal timer, preventing it from being re-submitted. Marks it as
     * canceled to allow distinguishing it from executed proposals.
     *
     * Emits a {IDODGovernor-ProposalCanceled} event.
     */
    function cancel(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash,
        uint256 nonce
    ) external onlyRoleOrOpenRole(CANCELLER_ROLE) returns (uint256) {
        uint256 proposalId = hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash,
            nonce
        );
        ProposalState status = state(proposalId);

        require(
            status != ProposalState.Canceled &&
                status != ProposalState.Expired &&
                status != ProposalState.Executed,
            "DODGovernor: proposal not active"
        );
        require(
            _msgSender() == _proposalResult[proposalId].proposer,
            "DODGovernor: caller is not the proposer"
        );
        _proposalResult[proposalId].canceled = true;

        emit ProposalCanceled(proposalId);

        return proposalId;
    }

    /**
     * @dev Get User Votes for proposalId.
     */
    function getUserVotes(
        uint256 proposalId,
        address account
    ) external view returns (uint256 _for, uint256 _against, uint256 _abstain) {
        return (
            _userVotes[proposalId][account][VoteType.For],
            _userVotes[proposalId][account][VoteType.Against],
            _userVotes[proposalId][account][VoteType.Abstain]
        );
    }

    /**
     * @dev Get proposal result of proposalId.
     */
    function getProposalResult(
        uint256 proposalId
    ) external view returns (ProposalResult memory) {
        return _proposalResult[proposalId];
    }

    /**
     * @dev See {IDODGovernor-castVote}.
     */
    function castVote(
        uint256 proposalId,
        VoteType voteType,
        uint256[] calldata tokenIds
    ) external returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, voteType, tokenIds, "");
    }

    /**
     * @dev See {IDODGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        VoteType voteType,
        uint256[] calldata tokenIds,
        string memory reason
    ) external returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, voteType, tokenIds, reason);
    }

    /**
     * @dev Internal vote casting mechanism: Check that the vote is active, that it has not been cast yet
     */
    function _castVote(
        uint256 proposalId,
        address account,
        VoteType voteType,
        uint256[] calldata tokenIds,
        string memory reason
    ) internal returns (uint256) {
        ProposalCore storage details = _proposalCore[proposalId];
        for (uint256 i = 0; i < details.targets.length; i++) {
            require(
                details.targets[i] != address(0),
                "DODGovernor: error target"
            );
        }
        require(
            state(proposalId) == ProposalState.Active,
            "DODGovernor: vote not currently active"
        );

        _countVote(proposalId, account, voteType, tokenIds);

        emit VoteCast(account, proposalId, voteType, tokenIds, reason);

        return tokenIds.length;
    }

    /**
     * @dev Update Voting Requirements
     */
    function updateVoteRequires(
        uint32 _minVotingPeriod,
        uint32 _minExecutingPeriod,
        uint256 _minVotesRequired
    ) external {
        require(_msgSender() == address(this), "Governor: caller is not the governor");
        require(_minVotingPeriod != 0, "Governor: invalid voting period");
        require(_minExecutingPeriod != 0, "Governor: invalid executing period");
        require(_minVotesRequired != 0 && _minVotesRequired <= DIVISOR, "DODGovernor: invalid votes target");
        require(
            minVotingPeriod != _minVotingPeriod ||
            minExecutingPeriod != _minExecutingPeriod ||
            minVotesRequired != _minVotesRequired,
            "DODGovernor: same minimum value"
        );
        minVotingPeriod = _minVotingPeriod;
        minExecutingPeriod = _minExecutingPeriod;
        minVotesRequired = _minVotesRequired;
        emit UpdateVoteRequires(_minVotingPeriod, _minExecutingPeriod,_minVotesRequired);
    }

    /**
     * @dev If the DOD token is attacked or needs to be migrated, update the token address
     */
    function updateToken(address _dodToken) external {
        require(_msgSender() == address(this), "Governor: caller is not the governor");
        require(dodToken != _dodToken, "Governor: same address");
        emit UpdateToken(dodToken, _dodToken);
        dodToken = _dodToken;
    }

    /**
     * Initialize when deploying dod token contract
     */
    function initializeToken(address _dodToken) external {
        require(_msgSender() == owner, "DODGovernor: caller is not the owner");
        require(dodToken == address(0), "DODGovernor: dod token has been set");
        require(Address.isContract(_dodToken), "DODGovernor: invalid dod token");
        dodToken = _dodToken;
    }
}