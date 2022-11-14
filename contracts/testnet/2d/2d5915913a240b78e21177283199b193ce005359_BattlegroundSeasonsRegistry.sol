/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

pragma solidity 0.8.17;

// SPDX-License-Identifier: UNLICENSED


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

    /**ff
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

// File: @openzeppelin/contracts/utils/Strings.sol

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

interface IBattlegroundSeasonsRegistry {

    struct Reward {
        // examples of place formats
        //
        // 1
        // 2
        // 3
        // ...
        // 51
        // ...
        // 100
        //
        //
        // 1
        // 2
        // 3
        // 5 - 10
        // 11 - 50
        // 51 - 100
        //
        //
        // 1
        // 2
        // 3
        // 10
        // Top 20
        // Top 50
        // 100
        //
        string place;
        string reward;
    }

    struct Season {
        uint256 id;
        string name;
        uint256 start;           // timestamp
        uint256 end;             // timestamp
        Reward[] rewards;
    }

    struct ClaimRewardRequest {
        uint256 id;
        uint256 seasonId;        // Identifier of the season in which the player ranked
        string profile;          // Some external player identifier (e.g. a database identifier)
        address sendTo;          // Address to which rewards should be transferred
        bool isInvalid;          // Set to true, if the request for any reason is recognized by the moderation as incorrect
        bool isClaimed;          // Set in true, if the request was satisfied
    }

    event NewSeason(uint256 indexed id, string _name, uint256 start, uint256 end);
    event NewClaimRewardRequest(uint256 indexed id, uint256 indexed seasonId, string indexed profile);
    event ClaimRewardRequestUpdated(uint256 indexed id, bool indexed isInvalid, bool indexed isClaimed);

    function ADMIN_ROLE() external pure returns (bytes32);
    function OPERATOR_ROLE() external pure returns (bytes32);
    function commissionToken() external view returns (IERC20);
    function claimRewardCommission() external view returns (uint256);
    function commissionRecipient() external view returns (address);
    function setCommissionToken(address _commissionToken) external;
    function setClaimRewardCommission(uint256 _claimRewardCommission) external;
    function setCommissionRecipient(address _commissionRecipient) external;

    function addSeason(string calldata _name, uint256 _start, uint256 _end, Reward[] calldata _rewards) external;
    function currentSeason() external view returns (Season memory season);
    function seasonCount() external view returns (uint256 count);
    function getSeason(uint256 _id) external view returns (Season memory season);
    /**
    * @dev Get a slice of the array of seasons from `_fromIndex` inclusive to `_toIndex` non-inclusive
    */
    function getSeasons(uint256 _fromIndex, uint256 _toIndex) external view returns (Season[] memory seasons);
    function getSeasonsByNames(string[] calldata _names) external view returns (Season[] memory _seasons);

    /**
    * @dev Creating a new reward request
    * The claimRewardCommission must be paid to create the request
    * @param _seasonId Identifier of the season in which the player ranked
    * @param _profile Some external player identifier (e.g. a database identifier)
    * @param _sendTo Address to which rewards should be transferred
    */
    function createClaimRewardRequest(uint256 _seasonId, string memory _profile, address _sendTo) external;
    /**
    * @dev Change reward request status
    * Method available only to operators
    * @param _requestId Identifier of the request
    * @param _isInvalid Set to true, if the request for any reason is recognized by the moderation as incorrect
    * @param _isClaimed Set in true, if the request was satisfied
    */
    function setClaimRewardRequests(uint256 _requestId, bool _isInvalid, bool _isClaimed) external;
    function claimRewardRequestCount() external view returns (uint256 count);
    function getClaimRewardRequest(uint256 _id) external view returns (ClaimRewardRequest memory claimRewardRequest);
    /**
    * @dev Get a slice of the array of claim reward requests from `_fromIndex` inclusive to `_toIndex` non-inclusive
    */
    function getClaimRewardRequests(uint256 _fromIndex, uint256 _toIndex) external view returns (ClaimRewardRequest[] memory claimRewardRequests);
}


contract BattlegroundSeasonsRegistry is IBattlegroundSeasonsRegistry, AccessControl {
    bytes32 public override constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public override constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    uint256 public override seasonCount = 0;
    mapping(uint256 => Season) internal seasons;
    mapping(string => uint256) internal seasonByName;

    uint256 public override claimRewardRequestCount = 0;
    mapping(uint256 => ClaimRewardRequest) internal claimRewardRequests;

    IERC20 public override commissionToken;
    uint256 public override claimRewardCommission;
    address public override commissionRecipient;

    constructor(
        address _commissionToken,
        uint256 _claimRewardCommission,
        address _commissionRecipient
    ) {
        require(_commissionRecipient != address(0), "Season: _commissionRecipient is zero address");
        commissionToken = IERC20(_commissionToken);
        claimRewardCommission = _claimRewardCommission;
        commissionRecipient = _commissionRecipient;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        grantRole(OPERATOR_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        require(account != address(0), "Season: account is zero address");
        if (role == OPERATOR_ROLE) {
            commissionToken.approve(account, type(uint256).max);
        }
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        require(account != address(0), "Season: account is zero address");
        if (role == OPERATOR_ROLE) {
            commissionToken.approve(account, 0);
        }
        _revokeRole(role, account);
    }

    function setCommissionToken(address _commissionToken) external onlyRole(ADMIN_ROLE) {
        commissionToken = IERC20(_commissionToken);
    }

    function setClaimRewardCommission(uint256 _claimRewardCommission) external onlyRole(ADMIN_ROLE) {
        claimRewardCommission = _claimRewardCommission;
    }

    function setCommissionRecipient(address _commissionRecipient) external onlyRole(ADMIN_ROLE) {
        require(_commissionRecipient != address(0), "Season: _commissionRecipient is zero address");
        commissionRecipient = _commissionRecipient;
    }

    function addSeason(string calldata _name, uint256 _start, uint256 _end, Reward[] calldata _rewards) external onlyRole(OPERATOR_ROLE) {
        Season storage season = seasons[seasonCount];
        season.id = seasonCount;
        season.name = _name;
        season.start = _start;
        season.end = _end;
        for (uint256 i = 0; i < _rewards.length; i++) {
            season.rewards.push(_rewards[i]);
        }
        seasonByName[_name] = seasonCount;
        emit NewSeason(seasonCount++, _name, _start, _end);
    }

    function currentSeason() external view returns (Season memory season) {
        return seasons[seasonCount - 1];
    }

    function getSeason(uint256 _id) external view returns (Season memory season) {
        return seasons[_id];
    }

    /**
    * @dev Get a slice of the array of seasons from `_fromIndex` inclusive to `_toIndex` non-inclusive
    */
    function getSeasons(uint256 _fromIndex, uint256 _toIndex) external view returns (Season[] memory _seasons) {
        _seasons = new Season[](_toIndex - _fromIndex);
        for (uint256 i = 0; i < _toIndex - _fromIndex; i++) {
            _seasons[i] = seasons[i + _fromIndex];
        }
    }

    function getSeasonsByNames(string[] calldata _names) external view returns (Season[] memory _seasons) {
        _seasons = new Season[](_names.length);
        for (uint256 i = 0; i < _names.length; i++) {
            uint256 seasonId = seasonByName[_names[i]];
            if (seasonId != 0 || keccak256(abi.encodePacked(seasons[seasonId].name)) == keccak256(abi.encodePacked(_names[i]))) {
                _seasons[i] = seasons[seasonId];
            }
        }
    }

    /**
    * @dev Creating a new reward request
    * The claimRewardCommission must be paid to create the request
    * @param _seasonId Identifier of the season in which the player ranked
    * @param _profile Some external player identifier (e.g. a database identifier)
    * @param _sendTo Address to which rewards should be transferred
    */
    function createClaimRewardRequest(uint256 _seasonId, string memory _profile, address _sendTo) external {
        require(seasons[_seasonId].end < block.timestamp, "Season not finished");
        require(_seasonId <= seasonCount, "Season: Incorrect seasonId");
        require(_sendTo != address(0), "Season: _sendTo is zero address");
        commissionToken.transferFrom(msg.sender, commissionRecipient, claimRewardCommission);
        claimRewardRequestCount++;
        claimRewardRequests[claimRewardRequestCount] = ClaimRewardRequest(claimRewardRequestCount, _seasonId, _profile, _sendTo, false, false);
        emit NewClaimRewardRequest(claimRewardRequestCount, _seasonId, _profile);
    }

    /**
    * @dev Change reward request status
    * Method available only to operators
    * @param _requestId Identifier of the request
    * @param _isInvalid Set to true, if the request for any reason is recognized by the moderation as incorrect
    * @param _isClaimed Set in true, if the request was satisfied
    */
    function setClaimRewardRequests(uint256 _requestId, bool _isInvalid, bool _isClaimed) external onlyRole(OPERATOR_ROLE) {
        require(_requestId <= claimRewardRequestCount, "Season: Incorrect _requestId");
        claimRewardRequests[_requestId].isClaimed = _isClaimed;
        claimRewardRequests[_requestId].isInvalid = _isInvalid;
        emit ClaimRewardRequestUpdated(_requestId, _isInvalid, _isClaimed);
    }

    function getClaimRewardRequest(uint256 _id) external view returns (ClaimRewardRequest memory claimRewardRequest) {
        return claimRewardRequests[_id];
    }

    /**
    * @dev Get a slice of the array of claim reward requests from `_fromIndex` inclusive to `_toIndex` non-inclusive
    */
    function getClaimRewardRequests(uint256 _fromIndex, uint256 _toIndex) external view returns (ClaimRewardRequest[] memory _claimRewardRequests) {
        _claimRewardRequests = new ClaimRewardRequest[](_toIndex - _fromIndex);
        for (uint256 i = 0; i < _toIndex - _fromIndex; i++) {
            _claimRewardRequests[i] = claimRewardRequests[i + _fromIndex];
        }
    }

}