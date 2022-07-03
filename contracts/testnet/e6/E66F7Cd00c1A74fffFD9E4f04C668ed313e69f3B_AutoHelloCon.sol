/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

// File: contracts/HY3D1155.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;




interface ITokenInterface{
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface I_21PToken{
    function getInviters(address sender) external view returns(address[] memory);  //获取所有下级
    function inviter(address sender) external view returns (address); //获取上级
}

contract OtherTOKEN {
    mapping(address => address) public inviter;
}

contract AutoHelloCon is AccessControl, Ownable, ReentrancyGuard{
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public _optoken;
    address private _receiveAddress;
    uint256 public IdoAmount_1;
    uint256 public IdoAmount_2;

    struct NftsCanGot {
        address user;
        uint256 TeamAmounts;
        uint256 upAmounts;
        uint256 Nfts;
    }

    mapping(address => bool) public idostatus;
    address[] public idolist;

    uint256 private decimals = 10 **18;

    address public _21PToken;

    uint256 public IdoAmounts; //ido 总量
    uint256 public IdoReceived; // 总已领取的量
    mapping(address => uint256) public UserIdoAmounts; //用户的ido总量
    mapping(address => uint256) public UserIdoReceived; //用户已经领取的量
    mapping(address => uint256) public UserCanReceived; //用户可以领取的量

    mapping(address => uint256) public UserSuperiorReceived; //直推的总量
    mapping(address => uint256) public UserTeamReceived; //用户团队的量

    mapping(address => address) public UserSup;
    mapping(address => address[]) public UserSubs;
    mapping(address => address[]) public UserTeams;

    mapping(address => bool) public UserBindStatus;

    mapping(address => uint256) public NftCanGet;
    mapping(address => uint256) public NFTHasGot;

    //构造函数
    constructor(){
        _setupRole(OWNER_ROLE, msg.sender);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
        _setRoleAdmin(ADMIN_ROLE, OWNER_ROLE); //
        _setupRole(ADMIN_ROLE, msg.sender); // 
        IdoAmount_1 = 1 * decimals; //  1
        IdoAmount_2 = 2 * decimals; //  2
    }

    //used for add admin control 
    modifier onlyOwnerAndAdmin() { // Modifier
        require(
            hasRole(ADMIN_ROLE, msg.sender)|| (owner() == msg.sender),
            "Only owner and admin can call this."
        );
        _;
    }

    function setInit(address opTokenAddress, address receiverAddress) external onlyOwnerAndAdmin{
        _optoken = opTokenAddress; //
        _receiveAddress = receiverAddress; //
        // _21PToken = _21PtokenAddress;
    }

    //修改收款地址
    event SetReceiveAddressEvent(address newReceiver);

    function setReceiveAddress(address newReceiver) external onlyOwnerAndAdmin {
        _receiveAddress = newReceiver;
        emit SetReceiveAddressEvent(newReceiver);
    }

    //修改 _21PToken 的地址
    event set21PTokenAddressEvent(address _21PTokenAddress);

    function set21PTokenAddress(address _21PTokenAddress) external onlyOwnerAndAdmin {
        _21PToken = _21PTokenAddress;
        emit set21PTokenAddressEvent(_21PTokenAddress);
    }

    //修改IDO 金额
    event SetThresholdsEvent(uint256 IdoAmount_1,uint256 IdoAmount_2);

    function setThresholds(uint256 _IdoAmount_1, uint256 _IdoAmount_2) external onlyOwnerAndAdmin {
        IdoAmount_1 =  _IdoAmount_1 * decimals;
        IdoAmount_2 =  _IdoAmount_2 * decimals;
        emit SetThresholdsEvent(_IdoAmount_1,_IdoAmount_2);
    }

    function transferOwnership(address newOwner) public override onlyOwnerAndAdmin{

        super.transferOwnership(newOwner);

        _setupRole(OWNER_ROLE, newOwner);

        //revoke at last
        revokeRole(OWNER_ROLE,msg.sender);

    }

    event IDOEvent(address user,address to, uint256 amount);

    function getTeams(address sender) external view returns(address[] memory){
        return UserTeams[sender];
    }

    function getUserSubs(address sender) external view returns(address[] memory){
        return UserSubs[sender];
    }

    function setSup(address _supAddress) external {
        require(UserBindStatus[msg.sender] == false,"user is areadly bind");
        require(_supAddress != msg.sender,"not yourslfe");
        UserSup[msg.sender] = _supAddress;

        UserBindStatus[msg.sender] = true;

        address upupAddress = UserSup[_supAddress];

        UserSubs[_supAddress].push(msg.sender);

        UserTeams[_supAddress].push(msg.sender);

        UserTeams[upupAddress].push(msg.sender);

    }

    function getInviter() external view returns(address){

        // OtherTOKEN _token = OtherTOKEN(_21PToken); 
        
        address upAddress = UserSup[msg.sender];
        //获取用户的上级
        // address upAddress = _token.inviter(msg.sender);

        return upAddress;
    }

    //收u 收到之后转入到指定地址中
    function startIDO(uint256 _amounts) external nonReentrant {

        //判断是不是制定价格
        require(_amounts == (IdoAmount_1) || _amounts == (IdoAmount_2), "not specified price");

        //该用户有没有进来过 
        require(idostatus[msg.sender] == false, "have take part in ido already");

        (bool status) = ITokenInterface(_optoken).transferFrom(msg.sender,address(this),_amounts);

        require(status ,"failed to transfer token from user to platform");
        
        idostatus[msg.sender] = true; //记录是否已经IDO

        idolist.push(msg.sender);  //IDO LIST列表

        IdoAmounts += _amounts;  // IDO 总额

        // OtherTOKEN _token = OtherTOKEN(_21PToken); 

        //获取用户的上级
        // address upAddress = _token.inviter(msg.sender);
        address upAddress =  UserSup[msg.sender];
        // address upupAddress = _token.inviter(upAddress);
        address upupAddress = UserSup[upAddress];

        UserTeamReceived[upupAddress] += _amounts; //上上级的总金额
        UserTeamReceived[upAddress] += _amounts; //上级的总金额
        UserSuperiorReceived[upAddress] += _amounts;

        UserCanReceived[upupAddress] += (_amounts * 10 / 100);
        UserCanReceived[upAddress] += (_amounts * 20 / 100);

        UserIdoAmounts[msg.sender] = _amounts;

        NftCanGet[upAddress]++;
        NftCanGet[upupAddress]++;

        emit IDOEvent(msg.sender,address(this), _amounts);
    }

    function NftGet(uint256 count) external {
        uint256 _total = NftCanGet[msg.sender] / 5;

        require(idostatus[msg.sender] == true, "user not in idolist");

        require((count + NFTHasGot[msg.sender]) < _total, "The number of nft can be insufficient for Mint");
        NFTHasGot[msg.sender] += count;
    }

    //管理员提现
    function withdraw() external onlyOwner nonReentrant {
  
        ITokenInterface(_optoken).transfer(msg.sender,ITokenInterface(_optoken).balanceOf(address(this)));
    }

    //获取可以领取多少个NFT资格 
    function NftDraw(address sender) external view returns(uint256, uint256, uint256){

        //判断用户团队金额能获取多少个
        uint256 NFTTeamCanGet = UserTeamReceived[sender] / ( 10 * decimals);

        //判断用户直推可以获取多少个
        uint256 NFTCanGet = UserSuperiorReceived[sender] / ( 5 * decimals);

        uint256 NFTAmounts = NFTTeamCanGet + NFTCanGet;

        return (NFTTeamCanGet, NFTCanGet, NFTAmounts);
    }

    //统计IDO要方法的NFT

    function UsersCanGetNft() external view returns(NftsCanGot[] memory) {
        uint256 length = idolist.length;


        NftsCanGot[] memory users = new NftsCanGot[](length);

        for(uint256 i = 0 ; i < length; i ++) {
            users[i].user = idolist[i];

            (uint256 TeamAmounts, uint256 upAmounts, uint256 Nfts) = this.NftDraw(idolist[i]);
            users[i].TeamAmounts = TeamAmounts;
            users[i].upAmounts = upAmounts;
            users[i].Nfts = Nfts;
        }

        
        return users;
    }
    

    //领取收益的方法
    function received() external nonReentrant  returns(bool) {

        require(idostatus[msg.sender] == true, "user not in idolist");

        require(UserCanReceived[msg.sender]  > 0 ,"Received Must be greater than 0");

        require(ITokenInterface(_optoken).balanceOf(address(this)) >= UserCanReceived[msg.sender], "Insufficient funds in wallet");

        (bool status) = ITokenInterface(_optoken).transfer(msg.sender,UserCanReceived[msg.sender]);

        IdoReceived += UserCanReceived[msg.sender];

        UserIdoReceived[msg.sender] += UserCanReceived[msg.sender];

        UserCanReceived[msg.sender] = 0;

        require(status , "USDT received fail");

        return status;

    }

    function getlist() external view returns(address[] memory) {

        return idolist ;
        
    }

    // function getTeamCount() external view returns(uint256, uint256){
    //     (address[] memory straight)= I_21PToken(_21PToken).getInviters(msg.sender);

    //     uint256 straightLength = straight.length;

    //     uint256 teamLength = 0;

    //     for(uint256 i = 0; i < straightLength; i++){
    //         (address[] memory push) = I_21PToken(_21PToken).getInviters(straight[i]);
    //         teamLength += push.length;
    //     }

    //     teamLength += straightLength;

    //     return (straightLength, teamLength);

    // }

}