/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin\contracts\utils\Strings.sol


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

// File: @openzeppelin\contracts\access\IAccessControl.sol


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

// File: @openzeppelin\contracts\utils\Context.sol


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

// File: @openzeppelin\contracts\utils\introspection\IERC165.sol


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

// File: @openzeppelin\contracts\utils\introspection\ERC165.sol


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

// File: @openzeppelin\contracts\access\AccessControl.sol


// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

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

// File: src\Exchange.sol


pragma solidity >=0.8.0 <0.9.0;
interface Token {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

interface Nft {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function publishMint(address to) external returns (uint256);
}

contract Exchange is AccessControl {
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    struct BuyParams {
        address nftContract; // NFT合约地址
        address tokenContract; // USDT合约地址
        address buyer; // 买家地址
        address owner; // NFT卖家地址
        uint256 price; // 卖价
        uint256 fee; // 手续费
        address feeAddress;
        uint256 itemId; // NFT的tokenId号
        string dealId; // 订单id; // 订单id
        uint256 deadline; // 有效期，此时间戳之前有效
    }
    struct PublishParams {
        address nftContract; // NFT合约地址
        address tokenContract; // USDT合约地址
        address buyer; // 买家地址
        address owner; // NFT卖家地址
        uint256 price; // 卖价
        string publishId; // 订单id; // 订单id
        uint256 deadline; // 有效期，此时间戳之前有效
    }
    // 购买事件
    event boughtAsset(
        address buyer,
        address owner,
        uint256 price,
        uint256 fee,
        uint256 itemId,
        string dealId
    );
    event publishedAsset(
        address buyer,
        address owner,
        uint256 price,
        uint256 itemId,
        string publishId
    );
    // 手续费收款地址
    //  address FEE_ACCEPT_ADDRESS;
    address ENCODE_ADDRESS;

    function setEncodeAddress(address encodeAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        ENCODE_ADDRESS = encodeAddress;
    }

    function getEncodeAddress() public view returns (address) {
        return ENCODE_ADDRESS;
    }

    // // 设置手续费地址
    // function setFeeAcceptAddress(address acceptAddress)
    //     public
    //     onlyRole(DEFAULT_ADMIN_ROLE)
    // {
    //     FEE_ACCEPT_ADDRESS = acceptAddress;
    // }

    // // 显示手续费地址
    // function getFeeAcceptAddress() public view returns (address) {
    //     return FEE_ACCEPT_ADDRESS;
    // }

    function changeAdmin(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newAdmin != msg.sender, "");
        _grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // 是否是管理员
    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function isCanEncode(address encodeAddress) public view returns (bool) {
        return encodeAddress == ENCODE_ADDRESS;
    }

    //放置出现多个管理员
    function grantRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
    {
        require(account != msg.sender, "");
        _grantRole(role, account);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // 验证签名
    function verify(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        address addr = ecrecover(hash, v, r, s);
        return addr;
    }

    // address转字符串
    function toHexString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    function buyAsset(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        BuyParams memory buyParams
    ) public {
        // 检测参数has
        string memory message = string(
            abi.encodePacked(
                "buyer=",
                toHexString(buyParams.buyer),
                "&contract=",
                toHexString(buyParams.nftContract),
                "&deadline=",
                Strings.toString(buyParams.deadline),
                "&dealId=",
                buyParams.dealId,
                "&fee=",
                Strings.toString(buyParams.fee),
                "&feeAddress=",
                toHexString(buyParams.feeAddress),
                "&itemId=",
                Strings.toString(buyParams.itemId),
                "&owner=",
                toHexString(buyParams.owner),
                "&price=",
                Strings.toString(buyParams.price),
                "&tokenContract=",
                toHexString(buyParams.tokenContract)
            )
        );
        bytes memory messageBytes = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            Strings.toString(bytes(message).length),
            message
        );
        require(
            hash == keccak256(messageBytes),
            "inconsistent parameter hash values"
        );

        // 交易发起方必须是买家
        require(
            msg.sender == buyParams.buyer,
            "the transaction originator must be the buyer"
        );

        // 检测时间有效性
        require(block.timestamp < buyParams.deadline, "transaction expired");

        // 检测是否是管理员的签名
        address encodeAddr = verify(hash, v, r, s);
        require(encodeAddr == ENCODE_ADDRESS, "insufficient permissions");

        // 初始化合约
        Token token = Token(buyParams.tokenContract);
        Nft nft = Nft(buyParams.nftContract);

        // 检测买家余额
        uint256 buyerBalance = token.allowance(msg.sender, address(this));
        require(buyerBalance >= buyParams.price, "insufficient balance");

        // 检测卖家是否持有nft
        require(
            nft.ownerOf(buyParams.itemId) == buyParams.owner,
            "nft does not exist"
        );

        // 将usdt转给卖家
        token.transferFrom(
            msg.sender,
            buyParams.owner,
            buyParams.price - buyParams.fee
        );

        // 将手续费转给收款合约
        if (buyParams.fee != 0) {
            require(buyParams.feeAddress != address(0), "feeAddress not set");
            token.transferFrom(msg.sender, buyParams.feeAddress, buyParams.fee);
        }

        // 将NFT转给买家
        nft.transferFrom(buyParams.owner, msg.sender, buyParams.itemId);

        // 触发事件
        emit boughtAsset(
            msg.sender,
            buyParams.owner,
            buyParams.price,
            buyParams.fee,
            buyParams.itemId,
            buyParams.dealId
        );
    }

    function publishAsset(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        PublishParams memory buyParams
    ) public {
        // 检测参数has
        string memory message = string(
            abi.encodePacked(
                "buyer=",
                toHexString(buyParams.buyer),
                "&contract=",
                toHexString(buyParams.nftContract),
                "&deadline=",
                Strings.toString(buyParams.deadline),
                "&owner=",
                toHexString(buyParams.owner),
                "&price=",
                Strings.toString(buyParams.price),
                "&publishId=",
                buyParams.publishId,
                "&tokenContract=",
                toHexString(buyParams.tokenContract)
            )
        );
        bytes memory messageBytes = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            Strings.toString(bytes(message).length),
            message
        );
        require(
            hash == keccak256(messageBytes),
            "inconsistent parameter hash values"
        );

        // 交易发起方必须是买家
        require(
            msg.sender == buyParams.buyer,
            "the transaction originator must be the buyer"
        );

        // 检测时间有效性
        require(block.timestamp < buyParams.deadline, "transaction expired");

        // 检测是否是管理员的签名
        address encodeAddr = verify(hash, v, r, s);
        require(encodeAddr == ENCODE_ADDRESS, "insufficient permissions");

        // 初始化合约
        Token token = Token(buyParams.tokenContract);
        Nft nft = Nft(buyParams.nftContract);

        // 检测买家余额
        uint256 buyerBalance = token.allowance(msg.sender, address(this));
        require(buyerBalance >= buyParams.price, "insufficient balance");

        // // 检测卖家是否持有nft
        // require(
        //     nft.ownerOf(buyParams.itemId) == buyParams.owner,
        //     "nft does not exist"
        // );
        uint256 itemId = nft.publishMint(buyParams.buyer);
        // 将usdt转给卖家
        token.transferFrom(msg.sender, buyParams.owner, buyParams.price);

        // 将NFT转给买家
        //  nft.transferFrom(buyParams.owner, msg.sender, buyParams.itemId);

        // 触发事件
        emit publishedAsset(
            msg.sender,
            buyParams.owner,
            buyParams.price,
            itemId,
            buyParams.publishId
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}