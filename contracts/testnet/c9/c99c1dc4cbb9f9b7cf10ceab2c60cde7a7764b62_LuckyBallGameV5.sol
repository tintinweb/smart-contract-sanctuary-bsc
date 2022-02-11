/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// File: ILuckyBallRandomness.sol


pragma solidity 0.8.11;

interface ILuckyBallRandomness {
    function randomResult() external view returns (uint256);
    function expand(uint256 randomValue, uint256 n) external pure returns (uint256[] memory expandedValues);
    function randomInRange(uint256 _randomValue, uint256 _begin, uint256 _end) external pure returns (uint256);
}
// File: ILuckyBallNFT.sol


pragma solidity 0.8.11;

interface ILuckyBallNFT {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
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

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


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


// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
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

// File: LuckyBallGame.sol


pragma solidity 0.8.11;






contract LuckyBallGameV5 is ERC1155Holder, AccessControl {
    struct Round {
        uint32 startAt;
        uint32 endAt;
        uint32 totalBall;
        uint32 prize1st;
        uint32 prize2nd;
        uint32 prize3rd;
        uint32 prize4th;
        uint32 prize5th;
        uint256 randomResult;
        uint256 totalJackpot;
    }

    struct Transaction {
        uint32 roundId;
        uint32 ballAmount;
        uint256 claim;
    }

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    event RoundCreated(uint32 indexed roundId, uint32 startAt, uint32 endAt);
    event BuyBall(bytes32 indexed transactionId, uint32 indexed roundId, address indexed player, uint256[] ballIds);
    event RoundResult(uint32 indexed roundId, uint32 prize1st, uint32 prize2nd, uint32 prize3rd, uint32 prize4th, uint32 prize5th, uint256 randomResult);
    event ClaimReward(bytes32 indexed transactionId, uint32 indexed roundId, address indexed player, uint256 claim);

    IERC20 public token;
    ILuckyBallNFT public ballNFT;
    ILuckyBallRandomness public randomness;
    address public feeWallet;
    uint32 public currentRound;
    uint32 public minimumBallPurchase;
    uint256 public ballPrice;
    uint256 public feeSupportProtocol;
    uint256 public prize1stProfitSharing;
    uint256 public prize2ndProfitSharing;
    uint256 public prize3rdProfitSharing;
    uint256 public prize4thProfitSharing;
    uint256 public prize5thProfitSharing;
    uint256 public prizeCourageProfitSharing;

    mapping(uint32 => Round) public rounds;
    mapping(bytes32 => Transaction) public players;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function initialize(IERC20 _token,
                        ILuckyBallNFT _ballNFT,
                        ILuckyBallRandomness _randomness,
                        address _feeWallet,
                        uint32 _minimumBallPurchase,
                        uint256 _ballPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        token = _token;
        ballNFT = _ballNFT;
        randomness = _randomness;
        feeWallet = _feeWallet;
        minimumBallPurchase = _minimumBallPurchase;
        ballPrice = _ballPrice;
    }

    function setPrizeReward(uint256 _feeSupportProtocol,
                            uint256 _prize1stProfitSharing,
                            uint256 _prize2ndProfitSharing,
                            uint256 _prize3rdProfitSharing,
                            uint256 _prize4thProfitSharing,
                            uint256 _prize5thProfitSharing,
                            uint256 _prizeCourageProfitSharing) external {
        feeSupportProtocol = _feeSupportProtocol;
        prize1stProfitSharing = _prize1stProfitSharing;
        prize2ndProfitSharing = _prize2ndProfitSharing;
        prize3rdProfitSharing = _prize3rdProfitSharing;
        prize4thProfitSharing = _prize4thProfitSharing;
        prize5thProfitSharing = _prize5thProfitSharing;
        prizeCourageProfitSharing = _prizeCourageProfitSharing;
    }

    function buyBall(uint32 _roundId, uint32 _ballAmount) external {
        require(_ballAmount >= minimumBallPurchase, "");
        require(block.timestamp >= rounds[_roundId].startAt && block.timestamp <= rounds[_roundId].endAt, "Round not available");

        address player = msg.sender;
        uint256 receipt = _ballAmount * ballPrice;

        token.transferFrom(player, address(this), receipt);

        uint32 _totalBall = rounds[_roundId].totalBall;
        uint32 _maxTotalBall = _totalBall + _ballAmount;
        uint256[] memory _nftIds = new uint256[](_ballAmount);
        uint256[] memory _nftAmounts = new uint256[](_ballAmount);
        uint32 mintingCount = 0;

        for (uint256 ballNo = _totalBall; ballNo < _maxTotalBall; ballNo++) {
            _nftIds[mintingCount] = ballNo;
            _nftAmounts[mintingCount] = 1 ether;
            mintingCount++;
        }

        ballNFT.mintBatch(address(this), _nftIds, _nftAmounts, "");
        ballNFT.safeBatchTransferFrom(address(this), player, _nftIds, _nftAmounts, "");

        bytes32 transactionId = keccak256(abi.encodePacked(_roundId, player));

        players[transactionId].roundId = _roundId;
        players[transactionId].ballAmount += _ballAmount;

        rounds[_roundId].totalBall += _ballAmount;
        rounds[_roundId].totalJackpot += receipt;

        emit BuyBall(transactionId, _roundId, player, _nftIds);
    }

    function claimReward(bytes32 _transactionId, uint256[] memory _ballIds) external {
        Transaction memory _transaction = players[_transactionId];
        uint32 _roundId = _transaction.roundId;
        address _player = msg.sender;
        
        require(block.timestamp > rounds[_roundId].endAt, "Waiting finish round");

        bytes32 transactionId = keccak256(abi.encodePacked(_roundId, _player));

        require(_transactionId == transactionId, "It not your transaction");

        Round memory _round = rounds[_roundId];
        uint32 _totalBallInRound = _round.totalBall;
        uint256 _totalPrizePool = _round.totalJackpot;
        uint256 _oddEven = _round.randomResult % 2;
        uint256 _reward = 0;

        uint256 _totalBallOfPlayer = _ballIds.length;

        for (uint256 i = 0; i < _totalBallOfPlayer; i++) {
            uint256 _ballId = _ballIds[i];
            uint256 _balanceBall = ballNFT.balanceOf(_player, _ballId);
            bool _isJackpot = (_ballId % 2) == _oddEven;
            
            if (_balanceBall == 0) {
                continue;
            }

            ballNFT.burn(_player, _ballId, 1 ether);

            if (_round.prize1st == _ballId) {
                _reward += (_totalPrizePool * prize1stProfitSharing) / 100 ether;
            } else if (_round.prize2nd == _ballId) {
                _reward += (_totalPrizePool * prize2ndProfitSharing) / 100 ether;
            } else if (_round.prize3rd == _ballId) {
                _reward += (_totalPrizePool * prize3rdProfitSharing) / 100 ether;
            } else if (_round.prize4th == _ballId) {
                _reward += (_totalPrizePool * prize4thProfitSharing) / 100 ether;
            } else if (_round.prize5th == _ballId) {
                _reward += (_totalPrizePool * prize5thProfitSharing) / 100 ether;
            } else if (_totalBallInRound > 5 && _isJackpot) {
                uint256 _remainBalls = ((_totalBallInRound * 10 ** 18) - 5 ether) / 2;
                uint256 _remainReward = (_totalPrizePool * prizeCourageProfitSharing) / 100 ether;
                _reward += (_remainReward / _remainBalls) * 10 ** 18;
            }
        }

        uint256 _feeForSupportProtocol = _reward > 0 ? (_reward * feeSupportProtocol) / 100 ether : 0;
        _reward -= _feeForSupportProtocol;

        players[_transactionId].claim += _reward;
        token.transfer(_player, _reward);
        token.transfer(feeWallet, _feeForSupportProtocol);

        emit ClaimReward(_transactionId, _roundId, _player, _reward);
    }

    function createRound(uint32 _startAt, uint32 _endAt) external onlyRole(MANAGER_ROLE) {
        uint32 _nextRound = currentRound + 1;

        require(_endAt > _startAt, "End should greater than Start");
        require(rounds[_nextRound].startAt == 0, "Round created");
        
        rounds[_nextRound].startAt = _startAt;
        rounds[_nextRound].endAt = _endAt;

        currentRound += 1;

        emit RoundCreated(_nextRound, _startAt, _endAt);
    }

    function randomBalls(uint32 _roundId) external onlyRole(MANAGER_ROLE) {
        require(block.timestamp > rounds[_roundId].endAt, "Waiting finish round");
        require(rounds[_roundId].randomResult == 0, "Round has been announced");

        uint256 _randomResult = randomness.randomResult();
        uint256[] memory _expand = randomness.expand(_randomResult, 21);
        uint32 _totalBall = rounds[_roundId].totalBall;

        uint32 _prize1st = uint32(randomness.randomInRange(_expand[0], 0, _totalBall));
        uint32 _prize2nd = uint32(randomness.randomInRange(_expand[5], 0, _totalBall));
        uint32 _prize3rd = uint32(randomness.randomInRange(_expand[10], 0, _totalBall));
        uint32 _prize4th = uint32(randomness.randomInRange(_expand[15], 0, _totalBall));
        uint32 _prize5th = uint32(randomness.randomInRange(_expand[20], 0, _totalBall));

        rounds[_roundId].prize1st = _prize1st;
        rounds[_roundId].prize2nd = _prize2nd;
        rounds[_roundId].prize3rd = _prize3rd;
        rounds[_roundId].prize4th = _prize4th;
        rounds[_roundId].prize5th = _prize5th;
        rounds[_roundId].randomResult = _randomResult;

        emit RoundResult(_roundId, _prize1st, _prize2nd, _prize3rd, _prize4th, _prize5th, _randomResult);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}