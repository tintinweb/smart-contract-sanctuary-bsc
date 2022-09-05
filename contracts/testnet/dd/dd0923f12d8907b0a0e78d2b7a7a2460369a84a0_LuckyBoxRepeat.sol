/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

pragma solidity ^0.8.9;

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

pragma solidity ^0.8.9;

interface IRandomNumberGenerator {
    function requestRandomNumber(uint256 id) external;
}

pragma solidity ^0.8.9;

// 奖票
struct lotteryInfo2 {
    uint256 buyType; // 支付类型 1.erc20 2.bnb
    address buyToken; // 支付类型是 erc20 时对应的合约地址
    uint256 ticketPrice; // 单价
    uint256 ticketUserAmount; // 单个钱包购买上限
    uint256 ticketAllAmount; // 奖品总量
}

interface IStrategy {
    function calculateCount(lotteryInfo2 memory lottery, uint256 countIn) external pure returns (uint256 value, uint256 countOut) ;
}

pragma solidity ^0.8.9;

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

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract LuckyBoxRepeat is AccessControl, ReentrancyGuard{
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    enum Status {
        NotOpened,
        Openable,
        Opening,
        Claimable,
        End
    }
    // 奖品
    struct lotteryInfo {
        Status status; // 状态
        uint256 tokenType; // 奖品类型 1.erc20 2.bnb 3.erc721
        uint256 tokenChain; // 奖品所在链 1.eth 2.bsc 3.polygon
        address tokenAddress; // 奖品合约地址
        uint256 tokenId; // 奖品是 nft 时对应的 token id
        address tokenOwner; // 奖品所在地址
        uint256 tokenAmount; // 奖品数量
        address ticketStrategy; // 策略地址
        // 其他
        uint64 startTime;  // 开始时间
        uint64 endTime; // 结束时间
        uint256 soldCount; // 已买数量
        uint256 luckyTicket; // 中奖号码
    }

    // 奖票
    // struct lotteryInfo2 {
    //     uint256 buyType; // 支付类型 1.erc20 2.bnb
    //     address buyToken; // 支付类型是 erc20 时对应的合约地址
    //     uint256 ticketPrice; // 单价
    //     uint256 ticketUserAmount; // 单个钱包购买上限
    //     uint256 ticketAllAmount; // 奖品总量
    // }
    // 房间 id > idTolottery[id]
    mapping(uint256 => lotteryInfo) public idTolottery; // 奖品
    mapping(uint256 => lotteryInfo2) public idTolottery2; // 奖票

    mapping(uint256 => mapping(address => uint256[][])) public idToUserTicketIdxs; // [ [ticketStartIdx, ticketEndIdx], ... ]
    mapping(uint256 => mapping(address => uint256)) public idToUserTicketAmount; // 用户对应购买数量
    mapping(uint256 => address[]) public idToUsers; // 用户总量
    mapping(uint256 => bool) public idToWinnerClaimed;
    mapping(uint256 => bool) public idToOwnerClaimed;
    mapping(uint256 => uint256) public idToRandomNumber;
    uint256 public currentId = 0;
    IRandomNumberGenerator public rng; 


    event lotteryStatusChanged(Status newStatus);
    event BuyTickets(address buyer,uint256 ticketStartIdx,uint256 tickectEndIdx);
    event NftClaimed(address winner);
    event PaymentClaimed(address creator);

    constructor(address _randomGenerator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        rng = IRandomNumberGenerator(_randomGenerator);
    }

    // 可接受本币
    receive() external payable {}

    // 创建
    function createBox(lotteryInfo memory lottery,lotteryInfo2 memory lottery2) external onlyRole(DEFAULT_ADMIN_ROLE){
        currentId++;

        // 公共部分
        if (lottery.tokenType == 1) { // erc20
        }
        if (lottery.tokenType == 2) { // bnb
            
        }
        if (lottery.tokenType == 3) { // erc721
            
        }
        idTolottery[currentId] = lottery;
        idTolottery2[currentId] = lottery2;
    }

    // 购买
    function buyTicket(uint256 id, address tokenAddress, address owner, uint256 amount, uint256 count) external payable {
        // 判断状态
        require(idTolottery[id].status == Status.NotOpened, "Only not opened");
        // 判断时间
        require(block.timestamp > idTolottery[id].startTime, "Not start");
        require(idTolottery[id].endTime == 0 || block.timestamp < idTolottery[id].endTime, "Ended");
        // 判断购买数量
        require(count > 0, "Invalid count");
        // 判断购买上限
        require(idToUserTicketAmount[id][owner] <= idTolottery2[id].ticketUserAmount, "Over buy amount");
        // 判断总量
        require(idTolottery[id].soldCount + count < idTolottery2[id].ticketAllAmount + 1,"Not enough tickets");


        (uint256 value, uint256 countOut) = IStrategy(idTolottery[id].ticketStrategy).calculateCount(idTolottery2[id], count);
                // 判断 
        if (idTolottery2[id].buyType == 1) {
            // erc20 支付
            require(amount >= value, "Not enough value");
            IERC20(tokenAddress).transferFrom(owner, address(this), value);
        }else {
            // 本币支付
            require(msg.value >= value, "Not enough value");
            if (msg.value > value) {
                payable(owner).transfer(msg.value-value);
            }
        }

        uint256 ticketStartIdx = idTolottery[id].soldCount;
        uint256 ticketEndIdx = ticketStartIdx + countOut - 1;
        if (idToUserTicketIdxs[id][owner].length == 0) {
            idToUsers[id].push(owner);
        }
        idToUserTicketIdxs[id][owner].push([ticketStartIdx, ticketEndIdx]);
        emit BuyTickets(msg.sender, ticketStartIdx, ticketEndIdx);

        idToUserTicketAmount[id][owner] += countOut;
        idToUserTicketAmount[id][owner] += count;

        idTolottery[id].soldCount += countOut;
        idTolottery[id].soldCount += count;

        if (idTolottery[id].soldCount == idTolottery2[id].ticketAllAmount) {
            setlotteryStatus(id, Status.Openable);
        }
    }

    // 开奖
    function openLucky(uint256 id) external nonReentrant {
        require(idTolottery[id].status == Status.Openable, "Not openable");
        rng.requestRandomNumber(id);
        setlotteryStatus(id, Status.Opening);
    }

    // 领奖
    function claim(uint256 id, address owner, uint256 idx) external {
        require(idTolottery[id].status == Status.Claimable && !idToWinnerClaimed[id],"Not claimable");
        require(idToUserTicketIdxs[id][owner].length > idx, "Only valid idx");

        uint256[][] memory ticketIdxs = idToUserTicketIdxs[id][owner];
        uint256 ticketStartIdx = ticketIdxs[idx][0];
        uint256 ticketEndIdx = ticketIdxs[idx][1];
        require(idTolottery[id].luckyTicket >= ticketStartIdx && idTolottery[id].luckyTicket <= ticketEndIdx,"Not the winner");

        idToWinnerClaimed[id] = true;
         // 判断 
        if (idTolottery[id].tokenType == 1) { // erc20
            IERC20(idTolottery[id].tokenAddress).transferFrom(address(this),owner,idTolottery[id].tokenAmount);
        } else if (idTolottery[id].tokenType == 2) { // bnb
            payable(owner).transfer(idTolottery[id].tokenAmount);
        }
        emit NftClaimed(owner);
        if (idToWinnerClaimed[id] && idToOwnerClaimed[id]) {
            setlotteryStatus(id, Status.End);
        }
    }

    // 合约款项
    function claimPayment(uint256 id, address owner) external {
        require(idTolottery[id].status == Status.Claimable && !idToOwnerClaimed[id],"Not claimable");
        idToOwnerClaimed[id] = true;
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit PaymentClaimed(owner);
        if (idToWinnerClaimed[id] && idToOwnerClaimed[id]) {
            setlotteryStatus(id, Status.End);
        }
    }

    function refund(uint256 id, address owner) external {

    }

    // chainlink 回调
    function receiveRandomNumber(uint256 id, uint256 _randomNumber) external {
        require(idTolottery[id].status == Status.Opening, "Not opening");
        idToRandomNumber[id] = _randomNumber;
        idTolottery[id].luckyTicket = idToRandomNumber[id] % idTolottery[id].soldCount;
        setlotteryStatus(id, Status.Claimable);
    }

    function getUsers(uint256 id) external view returns (address[] memory) {
        return idToUsers[id];
    }

    // 状态设置
    function setlotteryStatus(uint256 id, Status newStatus) private {
        idTolottery[id].status = newStatus;
        emit lotteryStatusChanged(newStatus);
    }
}