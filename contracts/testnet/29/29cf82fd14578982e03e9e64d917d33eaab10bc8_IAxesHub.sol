/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

pragma solidity 0.8.16;

// SPDX-License-Identifier: UNLICENSED

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/Strings.sol

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/access/AccessControl.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IAxes721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function currentId() external view returns (uint _currentId);
    function systemMint(address to, string memory _item) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external view returns (uint256);
    function tokenFullInfo(uint256 tokenId) external view returns (address owner, string memory tokenUri, string memory tokenRnd, string memory tokenItem, string memory tokenData, uint tokenSeason);
}

interface IStaking {

    struct Stake {
        uint256 tokenId;
        address owner;
        uint256 miningPower;
        uint256 startTimestamp;
        bool isActive;
    }
    
    struct UserMiningInfo {
        address user;
        uint256 startTimestamp;
        uint256 totalMiningPower;
        uint256 numberOfStakes;
        uint256 rewardBalance;
        uint256 lastRateIndex;
    }

    struct RateInfo {
        uint256 startsFrom;
        uint256 rateBefore;
        uint256 rateAfter;
    }

    struct MiningPowerSetup {
        uint256 tokenId;
        uint256 miningPower;
        bool isActive;
    }

    event Staked(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event Unstaked(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event RewardUpdated(address indexed owner, uint256 rewardBalance, uint256 miningTime, uint256 rewardSum, uint256 indexed timestamp);
    event MiningPowerUpdated(uint256 indexed tokenId, uint256 indexed miningPower);
    event Claimed(address indexed owner, uint256 indexed amount);
}
contract IAxesHub is AccessControl {
    struct Event {
        string name;
        string data;
    }

    event NewEvent(string name, string data);

    bytes32 public constant RECORDER_ROLE = keccak256("RECORDER_ROLE");

    Event[] public events;
    mapping(string => uint256[]) public eventIdsByName;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function register(string memory name, string memory data) public onlyRole(RECORDER_ROLE) {
        eventIdsByName[name].push(numberOfEvents());
        events.push(Event(name, data));
        emit NewEvent(name, data);
    }

    function numberOfEvents() public view returns (uint256) {
        return events.length;
    }

    function getEventIds(string memory name) public view returns (uint256[] memory) {
        return eventIdsByName[name];
    }
}
contract AxesStaking is IStaking, AccessControl, IERC721Receiver {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    IERC20 public rewardToken;
    IAxes721 public axes721;
    IAxesHub public hub;

    uint256 public daysDuration;                    // time period of remuneration (in days)
    uint256 public durationReward;                  // reward for a given interval
    uint256 public rewardRate;                      // the reward for one second of stake
    uint256 public energyRecoveryRate;
    uint256 public minStakingTime;
    uint256 public maxNumberOfStakesPerAccount;

    bool public isActive;

    mapping(uint256 => Stake) public stakes;        // maps tokenId to stake
    uint256 public numberOfStakes;

    mapping(address => UserMiningInfo) public usersMiningInfo;
    uint256 public totalMiningPower;

    RateInfo[] public rates;

    constructor(
        address _rewardToken,
        address _axes721,
        address _hub,
        uint256 _daysDuration,
        uint256 _durationReward,
        uint256 _energyRecoveryRate,
        uint256 _minStakingTime,
        uint256 _maxNumberOfStakesPerAccount
    ) {
        rewardToken=IERC20(_rewardToken);
        axes721=IAxes721(_axes721);
        hub=IAxesHub(_hub);

        isActive = true;
        daysDuration = _daysDuration;
        durationReward = _durationReward;
        _recalculateRewardRate();
        energyRecoveryRate = _energyRecoveryRate;
        minStakingTime = _minStakingTime;
        maxNumberOfStakesPerAccount = _maxNumberOfStakesPerAccount;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);

    }

    modifier checkTokensOwner(address _caller, uint256[] calldata _tokenIds) {
        for (uint i = 0; i < _tokenIds.length; i++) {
            require(axes721.ownerOf(_tokenIds[i]) == _caller, "AxesStaking: caller is not owner");
        }
        _;
    }

    modifier checkStakesOwner(address _caller, uint256[] calldata _tokenIds) {
        for (uint i = 0; i < _tokenIds.length; i++) {
            require(stakes[_tokenIds[i]].owner == _caller, "AxesStaking: caller is not owner");
        }
        _;
    }

    modifier checkMinStakesTime(uint256[] calldata _tokenIds) {
        for (uint i = 0; i < _tokenIds.length; i++) {
            require(
                block.timestamp - stakes[_tokenIds[i]].startTimestamp >= minStakingTime,
                "AxesStaking: take your time, it's been too little time for mining"
            );
        }
        _;
    }

    /**
    * @dev Freezes the nft tokens of `msg.sender` for mining
    * @param _tokenIds Array of nft token identifiers
    */
    function stake(uint256[] calldata _tokenIds) external checkTokensOwner(msg.sender, _tokenIds) {
        require(isActive, "AxesStaking: staking disabled");
        require(
            maxNumberOfStakesPerAccount >= _tokenIds.length + usersMiningInfo[msg.sender].numberOfStakes,
            "AxesStaking: the limit of the number of stakes is exceeded"
        );
        if (usersMiningInfo[msg.sender].startTimestamp != 0) {
            recalculateReward(msg.sender);
        }
        for (uint i = 0; i < _tokenIds.length; i++) {
            axes721.transferFrom(msg.sender, address(this), _tokenIds[i]);
            stakes[_tokenIds[i]] = Stake(_tokenIds[i], msg.sender, 0, block.timestamp, false);
            usersMiningInfo[msg.sender] = UserMiningInfo(
                msg.sender,
                block.timestamp,
                usersMiningInfo[msg.sender].totalMiningPower,
                usersMiningInfo[msg.sender].numberOfStakes + 1,
                usersMiningInfo[msg.sender].rewardBalance,
                rates.length - 1 
            );
            numberOfStakes++;
            emit Staked(msg.sender, _tokenIds[i], block.timestamp);
        }
        hub.register("AxesStaking:Staked", string(abi.encode(msg.sender, _tokenIds, block.timestamp)));
    }

    /**
    * @dev Updating of the mining power (hash power) for the selected nft token
    * @param _tokenId The identifier of nft token
    * @param _miningPower New value of mining power (hash power)
    * @param _isActive Indicator that the correct miningPower is set
    */
    function setMiningPower(uint256 _tokenId, uint256 _miningPower, bool _isActive) public onlyRole(OPERATOR_ROLE) {
        Stake memory currentStake = stakes[_tokenId];
        require(currentStake.tokenId == _tokenId, "AxesStaking: incorrect tokenId");
        require(currentStake.owner != address(0), "AxesStaking: the owner for this token is not specified");
        emit MiningPowerUpdated(_tokenId, _miningPower);
        hub.register("AxesStaking:MiningPowerUpdated", string(abi.encode(_tokenId, _miningPower)));
        stakes[_tokenId].miningPower = _miningPower;
        stakes[_tokenId].isActive = _isActive;
        // recalculateReward(currentStake.owner);
        usersMiningInfo[currentStake.owner].totalMiningPower += _miningPower - currentStake.miningPower;
        totalMiningPower += _miningPower - currentStake.miningPower;
    }

    /**
    * @dev Updating of the mining power (hash power) for the selected nft token
    * @param batch array of MiningPowerSetup structs (see setMiningPower params)
    */
    function setMiningPowerBatched(MiningPowerSetup[] calldata batch) public onlyRole(OPERATOR_ROLE) {
        for (uint i = 0; i < batch.length; i++) {
            setMiningPower(batch[i].tokenId, batch[i].miningPower, batch[i].isActive);
        }
    }

    /**
    * @dev Releases the locked nft tokens from mining
    * @param _tokenIds Array of nft token identifiers
    */
    function unstake(uint256[] calldata _tokenIds) external checkStakesOwner(msg.sender, _tokenIds) checkMinStakesTime(_tokenIds) {
        recalculateReward(msg.sender);
        for (uint i = 0; i < _tokenIds.length; i++) {
            axes721.transferFrom(address(this), msg.sender, _tokenIds[i]);
            usersMiningInfo[msg.sender] = UserMiningInfo(
                msg.sender,
                block.timestamp,
                usersMiningInfo[msg.sender].totalMiningPower - stakes[_tokenIds[i]].miningPower,
                usersMiningInfo[msg.sender].numberOfStakes - 1,
                usersMiningInfo[msg.sender].rewardBalance,
                usersMiningInfo[msg.sender].lastRateIndex
            );
            totalMiningPower -= stakes[_tokenIds[i]].miningPower;
            delete stakes[_tokenIds[i]];
            numberOfStakes--;
            emit Unstaked(msg.sender, _tokenIds[i], block.timestamp);
        }
        hub.register("AxesStaking:Unstaked", string(abi.encode(msg.sender, _tokenIds, block.timestamp)));
    }

    /**
    * @dev Recalculation of the reward amount for the specified user
    * @param _user The address of user
    */
    function recalculateReward(address _user) public {
        (uint256 miningTime, uint256 rewardSum) = rewardCurrentInfo(_user);
        usersMiningInfo[_user].startTimestamp = block.timestamp;
        emit RewardUpdated(_user, usersMiningInfo[_user].rewardBalance, miningTime, rewardSum, block.timestamp);
        usersMiningInfo[_user].rewardBalance += rewardSum;
        usersMiningInfo[_user].lastRateIndex = rates.length - 1;
        hub.register(
            "AxesStaking:RewardUpdated",
            string(abi.encode(_user, usersMiningInfo[_user].rewardBalance, miningTime, rewardSum, block.timestamp))
        );
    }

    /**
    * @dev Calculation of current reward parameters
    * @param _user The address of user
    * @return miningTime Number of seconds in which mining is performed
    * @return rewardSum The current amount of rewards
    */
    function rewardCurrentInfo(address _user) public view returns(uint256 miningTime, uint256 rewardSum) {
        uint256 normalizedTotalMiningPower = totalMiningPower == 0 ? 1 : totalMiningPower;
        uint256 stepTimestamp = usersMiningInfo[_user].startTimestamp;
        uint256 usersLastRateIndex = usersMiningInfo[_user].lastRateIndex;
        if (usersLastRateIndex == rates.length - 1) {
            uint256 intervalRewardCoef = rates[usersLastRateIndex].rateAfter * usersMiningInfo[_user].totalMiningPower / normalizedTotalMiningPower;
            uint256 intervalMiningTime = block.timestamp - stepTimestamp;
            rewardSum += intervalMiningTime * intervalRewardCoef;
        } else {
            for (uint i = usersLastRateIndex; i < rates.length; i++) {
                uint256 calculatingRateStartFrom = 0;
                if (i + 1 == rates.length) {
                    calculatingRateStartFrom = block.timestamp;
                } else {
                    calculatingRateStartFrom = rates[i + 1].startsFrom;
                }
                uint256 intervalRewardCoef = rates[i].rateAfter * usersMiningInfo[_user].totalMiningPower / normalizedTotalMiningPower;
                uint256 intervalMiningTime = calculatingRateStartFrom - stepTimestamp;
                rewardSum += intervalMiningTime * intervalRewardCoef;
                stepTimestamp = calculatingRateStartFrom;
            }
        }
        miningTime = block.timestamp - usersMiningInfo[_user].startTimestamp;
    }

    /**
    * @dev Withdraw their accumulated rewards
    * @param _amount Withdrawal amount
    */
    function claimReward(uint256 _amount) external {
        recalculateReward(msg.sender);
        require(usersMiningInfo[msg.sender].rewardBalance >= _amount, "AxesStaking: insufficient reward balance");
        usersMiningInfo[msg.sender].rewardBalance -= _amount;
        rewardToken.transfer(msg.sender, _amount);
        emit Claimed(msg.sender, _amount);
    }

    /**
    * @dev Withdrawal of funds from the reward pool by the contract owner
    * @param _amount Withdrawal amount
    * @param _to Destination address
    */
    function withdraw(uint256 _amount, address _to) external onlyRole(ADMIN_ROLE) {
        require(_to != address(0), "AxesStaking: zero address of receipient");
        rewardToken.transfer(msg.sender, _amount);
    }

    function _recalculateRewardRate() internal {
        uint256 newRewardRate = durationReward / daysDuration / 86400;
        rates.push(RateInfo(block.timestamp, rewardRate, newRewardRate));
        rewardRate = newRewardRate;
    }

    function setDaysDuration(uint256 _daysDuration) external onlyRole(ADMIN_ROLE) {
        daysDuration = _daysDuration;
        _recalculateRewardRate();
    }

    function setDurationReward(uint256 _durationReward) external onlyRole(ADMIN_ROLE) {
        durationReward = _durationReward;
        _recalculateRewardRate();
    }

    function setEnergyRecoveryRate(uint256 _energyRecoveryRate) external onlyRole(ADMIN_ROLE) {
        energyRecoveryRate = _energyRecoveryRate;
    }

    function setMinStakingTime(uint256 _minStakingTime) external onlyRole(ADMIN_ROLE) {
        minStakingTime = _minStakingTime;
    }

    function setMaxNumberOfStakesPerAccount(uint256 _maxNumberOfStakesPerAccount) external onlyRole(ADMIN_ROLE) {
        maxNumberOfStakesPerAccount = _maxNumberOfStakesPerAccount;
    }

    function toggleActive() external onlyRole(ADMIN_ROLE) {
        isActive = !isActive;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function stakesByIds(uint256[] calldata _tokenIds) public view returns (Stake[] memory _stakes) {
        _stakes = new Stake[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _stakes[i] = stakes[_tokenIds[i]];
        }
    }

    /**
    * @dev Getting the array of all stakes
    * ! should never be used inside of transaction because of gas fee !
    */
    function allStakes() public view returns (Stake[] memory _stakes) {
        _stakes = new Stake[](numberOfStakes);
        uint256 currentTokenId = axes721.currentId();
        uint256 index = 0;
        for (uint256 i = 0; i < currentTokenId; i++) {
            if (stakes[i].owner != address(0)) {
                _stakes[index++] = stakes[i];
            }
        }
    }

    /**
    * @dev Getting the array of current stakes of the specified user
    * ! should never be used inside of transaction because of gas fee !
    * @param _user User address
    */
    function stakesOfOwner(address _user) public view returns (Stake[] memory _stakes) {
        _stakes = new Stake[](usersMiningInfo[_user].numberOfStakes);
        uint256 currentTokenId = axes721.currentId();
        uint256 index = 0;
        for (uint256 i = 0; i < currentTokenId; i++) {
            if (stakes[i].owner == _user) {
                _stakes[index++] = stakes[i];
            }
        }
    }

    /**
    * @dev Getting the array of stakes with a false "isActive" field
    * ! should never be used inside of transaction because of gas fee !
    */
    function notActiveStakes() public view returns (Stake[] memory _stakes){
        Stake[] memory temp = new Stake[](numberOfStakes);
        uint256 currentTokenId = axes721.currentId();
        uint256 index = 0;
        for (uint256 i = 0; i < currentTokenId; i++) {
            if (stakes[i].owner != address(0) && !stakes[i].isActive) {
                temp[index++] = stakes[i];
            }
        }
        _stakes = new Stake[](index);
        for (uint256 i = 0; i < index; i++) {
            _stakes[i] = temp[i];
        }
    }
}