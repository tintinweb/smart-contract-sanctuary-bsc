/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
// Version: 1.0.0
pragma solidity 0.8.10;

// Version: 1.0.0

// Version: 1.0.0

// Version: 1.0.0

// Version: 1.0.0

interface I_With_DAORole{
    /**
     * DAO_ROLE is able to grant and revoke roles. It can be used when the DAO
     * vote to change some contracts of Windmill.
     */
    function DAO_ROLE() external view returns (bytes32);
}// Version: 1.0.0

abstract contract Base{
}





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
}

abstract contract With_DAORole is Base, AccessControl, I_With_DAORole{
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    constructor(){
        _setRoleAdmin(DAO_ROLE, DAO_ROLE);
        _setupRole(DAO_ROLE, msg.sender);
    }
}// Version: 1.0.0


// Version: 1.0.0


interface I_With_UpdaterRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function UPDATER_ROLE() external view returns (bytes32);
}

abstract contract With_UpdaterRole is Base, AccessControl, With_DAORole, I_With_UpdaterRole{
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    constructor(){
        _setRoleAdmin(UPDATER_ROLE, DAO_ROLE);
    }
}// Version: 1.0.0


// Version: 1.0.0


interface I_With_TradeManagerRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function TRADE_MANAGER_ROLE() external view returns (bytes32);
}

abstract contract With_TradeManagerRole is Base, AccessControl, With_DAORole, I_With_TradeManagerRole{
    bytes32 public constant TRADE_MANAGER_ROLE = keccak256("TRADE_MANAGER_ROLE");

    constructor(){
        _setRoleAdmin(TRADE_MANAGER_ROLE, DAO_ROLE);
    }
}// Version: 1.0.0


// Version: 1.0.0




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

interface I_With_BUSDToken is IAccessControl, I_With_DAORole{
    function setBUSDToken(IERC20 token) external;
}

abstract contract With_BUSDToken is Base, AccessControl, With_DAORole, I_With_BUSDToken{
    IERC20 public BUSDToken;

    function setBUSDToken(IERC20 token) external onlyRole(DAO_ROLE){
        BUSDToken = token;
    }
}// Version: 1.0.0


abstract contract Adressable is Base{
    address payable immutable internal thisAddr;

    constructor(){
        thisAddr = payable(address(this));
    }
}
// Version: 1.0.0


// Version: 1.0.0

// Version: 1.0.0

// Version: 1.0.0


// Version: 1.0.0



interface I_With_FundContract is IAccessControl, I_With_DAORole{
    function setFund(address _fund) external;
}// Version: 1.0.0

interface I_Math{
    struct Fraction{
        uint256 numerator;
        uint256 denominator;
    }
}

/**
 * @notice Windmill_Power is the ERC20 token (PWR) representing
 * a share of the fund in the Windmill_Fund contract.
 *
 * There is a primary market that value PWR in the form of
 * mint and burn by the Windmill_Fund contract.
 * In exchange of depositing or withdrawing BUSD from the fund,
 * PWR token are minted to or burned from the user address.
 * The minting/burning value of PWR only depends on the total supply
 * in BUSD in the fund related to the total supply of PWR.
 * This mean that PWR will gain primary value only via
 * Windmill traders performance
 *
 * Also, as PWR is an ERC20 token, it can be freely traded, so secondary
 * markets can exist.
 */
interface I_Windmill_Power is I_Math, IAccessControl, I_With_DAORole, IERC20, I_With_FundContract{
    /**
     * MINTER_ROLE is able to mint PWR to an address.
     *
     * BURNER_ROLE is able to burn PWR from an address.
     *
     * MOVER_ROLE is able to transfer PWR from an address to another.
     */
    function MINTER_ROLE() external view returns (bytes32);
    function BURNER_ROLE() external view returns (bytes32);
    function MOVER_ROLE() external view returns (bytes32);
    
    /**
     * @notice Allow the Windmill_Fund to mint PWR for an address

     * Windmill_Fund can use this method to buy PWR in exchange of BUSD
     * This do not change the PWR price because there is the corresponding amount of BUSD
     * that have been added to the fund.
     *
     * Windmill_Competition, Windmill_stacking and Windmill_Royalties can alsoo mint PWR
     * for their usage (competition and stacking reward, royalties).
     * These minting will decrease the value of PWR from the Windmill_Fund contract.
     */
    function mintTo(address to, uint256 amount) external;

    /**
     * @notice Allow the Windmill_Fund to burn PWR from an address
     * in exchange of withdrawing BUSD from the fund to the address.

     * When Windmill_Fund use this method, this do not change the PWR price
     * because there is the right amount of BUSD that have been removed
     * from the fund.
     */
    function burnFrom(address from, uint256 amount) external;

    /**
     * @notice Allow the Windmill_Fund to transfert PWR from an address
     * to a trade contract

     * Windmill_Stacking and Windmill_Trade_Manager use this method to lock the PWR from
     * direct withdraw. There is two main reason for this to happen :
     *
     * - PWR are locked from user to Windmill_Trade contract by Windmill_Trade_Manager
     * contract when starting a new trade. The corresponding BUSD from Windmill_Fund are also
     * allocated to the trade. These locked PWR are returned at the end of the trade.
     *
     * - PWR are stacked by the user in Windmill_Stacking. These PWR are returned
     * at the end of the stacking period. Note that returned PWR can be still
     * locked in a trade, that will be returned at the end of trade.
     */
    function transferFromTo(address from, address to, uint256 amount) external;
}

interface I_With_PWRToken is IAccessControl, I_With_DAORole{
    function setPWRToken(I_Windmill_Power token) external;
}// Version: 1.0.0


interface I_With_TradeRole is I_With_DAORole, I_With_TradeManagerRole{
    function TRADE_ROLE() external view returns (bytes32);
}


interface I_Windmill_Withdrawer is I_Math, IAccessControl, I_With_DAORole, I_With_TradeManagerRole, I_With_TradeRole,
                                   I_With_PWRToken, I_With_BUSDToken, I_With_FundContract{
    
    event WithdrawUpdate(address addr);
    
    struct WithdrawData{
        uint256 totalPWR;
        mapping(address=>uint256) userPWR;
        uint256 totalBUSD;
        bool claimable;
    }
    
    struct PendingWithdrawData{
        mapping(uint256=>uint256) tradeIdToPendingTradeIdShifted;
        mapping(uint256=>uint256) pendingTrade;
        uint256 pendingTradeLength;
    }
    
    function getNbPWRToWithdraw(uint256 tradeId) external view returns(uint256);
    
    function closeTrade(uint256 tradeId, uint256 transferedBUSD) external;
}// Version: 1.0.0



interface I_With_WithdrawerContract is IAccessControl, I_With_DAORole{
    function setWithdrawer(address _withdrawer) external;
}

abstract contract With_WithdrawerContract is Base, AccessControl, With_DAORole, I_With_WithdrawerContract{
    I_Windmill_Withdrawer public withdrawer;

    function setWithdrawer(address _withdrawer) public onlyRole(DAO_ROLE){
        withdrawer = I_Windmill_Withdrawer(payable(_withdrawer));
    }
}// Version: 1.0.0


// Version: 1.0.0

// Version: 1.0.0





/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

interface I_With_WBNBToken is IAccessControl, I_With_DAORole{
    function setWBNBToken(IERC20 token) external;
}// Version: 1.0.0



interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface PancakeRouter is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface I_With_PancakeRouter is IAccessControl, I_With_DAORole{
    function setPancakeRouter(PancakeRouter token) external;
}// Version: 1.0.0

interface I_Payable{
    receive() external payable;
}
// Version: 1.0.0

// Version: 1.0.0



interface I_With_TradeManagerContract is IAccessControl, I_With_DAORole{
    function setTradeManager(address _tradeManager) external;
}// Version: 1.0.0



interface I_With_CompetitionContract is IAccessControl, I_With_DAORole{
    function setCompetition(address _competition) external;
}

interface I_Windmill_Trade_Abstract is I_Math, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole,
                                       I_With_BUSDToken, I_With_FundContract, I_With_TradeManagerContract, I_With_WithdrawerContract, I_With_CompetitionContract{
    
    function getTradeProfit() external view returns(Fraction memory);
    
    function initTrade(address _owner, address _manager, address _fund, address _updater, address _withdrawer, address _competition) external;
    
    function setTradeId(uint256 _tradeId) external;
    
    function setMaxStopLoss(Fraction memory _maxStopLoss) external;
    
    function setMaxDuration(uint256 _maxDurationNbBlock) external;
    
    function setInitBUSDBalance(uint256 _initBUSDBalance) external;
    
    function forceEndTrade() external;
    
    function endTrade() external;
    
    function updateNeeded() external view returns (bool);
    
    function endTradeNeeded() external view returns (bool);
    
    function update() external;
    
    function getInitBUSDBalance() external view returns (uint256);
    
    function estimateBUSDBalance() external view returns (uint256);
    
    function getPnL() external view returns (Fraction memory);
}// Version: 1.0.0



interface I_Terminatable is I_With_DAORole{
    function terminate() external;
    
    function isTerminated() external view returns(bool);
}
// Version: 1.0.0



interface I_With_DAOContract is IAccessControl, I_With_DAORole{
    function setDAO(address _DAO) external;
}

/**
 * @notice Windmill_Fund is the contract that store and manage the BUSD used for
 * Windmill activities.
 *
 * The features of this contract are :
 * - Mint/burn PWR in exchange of depositing/withdrawing BUSD.
 * - Send BUSD to a Windmill_Contract trade.
 */
interface I_Windmill_Fund is I_Math, I_Payable, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_TradeRole,
                             I_With_PWRToken, I_With_BUSDToken, I_With_WBNBToken, I_With_PancakeRouter, I_With_TradeManagerContract, I_With_DAOContract{
        
    event MarketData(uint256 PWRPrice, uint256 PWRSupply);
    
    struct LockData{
        uint256 startBlock;
        Fraction factor;
    }
    
    struct FeeData{
        uint256 startBlock;
        uint256 startDynamicFeesNumerator;
    }
    
    function PWR_TOKEN_ROLE() external view returns (bytes32);
    
    function WITHDRAWER_ROLE() external view returns (bytes32);
    
    function beforePWRTransfer(address from, address to, uint256 amount) external;
    
    function setUpdaterAddress(address addr) external;
    
    function setBaseWithdrawFees(uint256 numerator, uint256 denominator) external;
    
    function setDynamicFeesDurationNbBlocks(uint256 _dynamicFeesDurationNbBlocks) external;
    
    function updateWithdrawFees(Fraction memory tradeProfit) external;
    
    function getWithdrawFees() external view returns(uint256);
    
    function getDataPWRLock(address addr) external view returns (uint256, uint256, uint256, uint256, uint256[2][] memory);

    function removeLockedPWRTokens(address addr, uint256 amountPWR) external;

    function getBNBForGasRefund(uint256 amountBNB) external;

    /**
     * Compute the BUSD hold buy Windmill contracts.
     */
    function getFundBUSD() external view returns (uint256);

    /**
     * Compute the BUSD hold buy Windmill contracts.
     */
    function getAvailableBUSD() external view returns (uint256);
    
    function sendBUSDToTrade(I_Windmill_Trade_Abstract trade, uint256 nbBUSD) external;
    
    /**
     * Compute the PWR total supply.
     */
    function getTotalPWR() external view returns (uint256);

    /**
     * Compute The number of PWR that corresponds to "amountBUSD" BUSD.
     */
    function getPWRAmountFromBUSD(uint256 amountBUSD) external view returns (uint256);

    /**
     * Compute The number of BUSD that corresponds to "amountPWR" PWR.
     */
    function getBUSDAmountFromPWR(uint256 amountPWR) external view returns (uint256);

    /**
     * Allow an address to buy PWR at the contract price for "amountBUSD" BUSD.
     * Node that the address must approve the transfer before calling this function.
     */
    function buyPWR(uint256 amountBUSD) external;

    /**
     * Allow an address to sell "amountPWR" PWR at the contract price for BUSD.
     */
    function sellPWR(uint256 amountPWR) external;
    
    function updatePWRPrice() external;
}

abstract contract With_FundContract is Base, AccessControl, With_DAORole, I_With_FundContract{
    I_Windmill_Fund public fund;

    function setFund(address _fund) public onlyRole(DAO_ROLE){
        fund = I_Windmill_Fund(payable(_fund));
    }
}// Version: 1.0.0


// Version: 1.0.0

// Version: 1.0.0



interface I_With_DAOAddress is IAccessControl, I_With_DAORole{
    function setDAOAddress(address _DAOAddress) external;
}// Version: 1.0.0



interface I_With_UpdaterContract is IAccessControl, I_With_DAORole{
    function setUpdater(address _updater) external;
}// Version: 1.0.0

// Version: 1.0.0

interface I_Initializable{
    function isInitialized(uint256 id) external view returns(bool);
}


interface I_Windmill_Trade_Deployer_Abstract is I_Initializable, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_BUSDToken{
    function name() external returns (string memory);
    
    function deployNewTrade(address owner, address manager, address fund, address updater, address withdrawer, address competition) external returns (I_Windmill_Trade_Abstract);
    
    function checkProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external view returns (bool);
    
    function applyProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external;
}

interface I_Windmill_Trade_Manager is I_Math, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterContract, I_With_CompetitionContract,
                                      I_With_FundContract, I_With_DAOAddress, I_With_BUSDToken, I_With_WithdrawerContract{
    
    event StartTrade(uint256 deployerId, uint256 tradeId, address owner);
    event EndTrade(uint256 tradeId);
    event EnergyUpdate(address addr);
    
    struct DeployerData{
        I_Windmill_Trade_Deployer_Abstract deployer;
        bool enabled;
    }
    
    struct TradeData{
        I_Windmill_Trade_Abstract trade;
        address owner;
        uint256 energy;
        bool isActive;
        uint256 percentPWRLockedNumerator;
        uint256 blockStart;
        uint256 blockEnd;
    }
    
    function setBaseEnergyBonusRatio(uint256 numerator, uint256 denominator) external;
    
    function getMaxEnergy(address addr) external view returns (uint256);
    
    function setMaxLeverage(uint256 numerator, uint256 denominator) external;
    
    function setMaxTradeStopLoss(uint256 numerator, uint256 denominator) external;
    
    function setMaxTradeDurationNbBlock(uint256 _maxTradeDurationNbBlock) external;
    
    function setMinimumBUSDToTrade(uint256 _minimumBUSDToTrade) external;
    
    function setTraderLevel(address addr, uint8 level) external;
    
    function addTradeDeployer(I_Windmill_Trade_Deployer_Abstract trade) external;
    
    function disableTradeDeployer(uint256 deployerId) external;
    
    function getNbTradeDeployers() external view returns (uint256);
    
    function getTrade(uint256 id) external view returns (TradeData memory);
    
    function getNbOpenTrades() external view returns (uint256);
    
    function getNbTrades() external view returns (uint256);
    
    function getOpenTrade(uint openId) external view returns (TradeData memory, uint256);
    
    function getTradeDeployer(uint256 id) external view returns (DeployerData memory);
    
    function endTrade(uint256 tradeId) external;
    
    function forceEndTrade(uint256 tradeId) external;
}

abstract contract With_TradeManagerContract is Base, AccessControl, With_DAORole, I_With_TradeManagerContract{
    I_Windmill_Trade_Manager public tradeManager;

    function setTradeManager(address _tradeManager) public onlyRole(DAO_ROLE){
        tradeManager = I_Windmill_Trade_Manager(_tradeManager);
    }
}// Version: 1.0.0


// Version: 1.0.0



/**
 * @notice Windmill_Competition
 */
interface I_Windmill_Competition is I_Math, IAccessControl, I_With_DAORole, I_With_TradeRole, I_With_UpdaterRole, I_With_PWRToken, I_With_FundContract, I_With_TradeManagerContract{
    struct CycleData{
        uint256 totalPWRMinted;
        uint256 totalProfitNumerator;
        bool completed;
        mapping(address=>UserDetails) user;
    }
    
    struct UserDetails{
        uint256 pnl;
        bool isProfit;
        bool rewardClaimed;
    }
    
    function setPercentPWRRewardMint(uint256 numerator, uint256 denominator) external;
    
    function updateCycle(uint256 cycleId) external;
    
    function updateEndTrade(Fraction memory tradeProfit, uint256 tradeId) external;
}

abstract contract With_CompetitionContract is Base, AccessControl, With_DAORole, I_With_CompetitionContract{
    I_Windmill_Competition public competition;

    function setCompetition(address _competition) public onlyRole(DAO_ROLE){
        competition = I_Windmill_Competition(payable(_competition));
    }
}// Version: 1.0.0



abstract contract Math is Base, I_Math{
    /**
     * @notice Compute the number of digits in an uint256 number.
     *
     * Node that if number = 0, it returns 0.
     */
    function numDigits(uint256 number) internal pure returns (uint8) {
        uint8 digits = 0;
        while (number != 0) {
            number /= 10;
            digits++;
        }
        return digits;
    }
    
    function _min(uint256 a, uint256 b) internal pure returns (uint256){
        return (a<b ? a : b);
    }
}



abstract contract Windmill_Trade_Abstract is Base, Math, Adressable, AccessControl, With_DAORole, With_UpdaterRole,
                                             With_TradeManagerRole, With_BUSDToken, With_FundContract, With_TradeManagerContract,
                                             With_WithdrawerContract, With_CompetitionContract, I_Windmill_Trade_Abstract{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    
    address public deployer;
    address public owner;
    
    uint256 public tradeId;
    
    Fraction public maxStopLoss;
    uint256 public maxDurationNbBlock;
    
    uint256 public initBlock;
    
    string public name;
    
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////
    Fraction internal tradeProfit;
    uint256 internal initBUSDBalance;
    
    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor(){
        _setRoleAdmin(OWNER_ROLE, DAO_ROLE);
        deployer = msg.sender;
    }

    ////
    ////
    ////
    //////////////// Public functions ////////////////
    function initTrade(address _owner, address _manager, address _fund, address _updater, address _withdrawer, address _competition) public onlyRole(DAO_ROLE) virtual{
        owner = _owner;
        
        setTradeManager(_manager);
        setFund(_fund);
        setWithdrawer(_withdrawer);
        setCompetition(_competition);
        
        initBlock = block.number;
        
        grantRole(OWNER_ROLE, owner);
        grantRole(TRADE_MANAGER_ROLE, _manager);
        grantRole(UPDATER_ROLE, _updater);
        revokeRole(DAO_ROLE, deployer);
    }
    
    function getTradeProfit() external view returns(Fraction memory){
        return tradeProfit;
    }
    
    function setTradeId(uint256 _tradeId) external onlyRole(TRADE_MANAGER_ROLE){
        tradeId = _tradeId;
    }
    
    function setMaxStopLoss(Fraction memory _maxStopLoss) external onlyRole(TRADE_MANAGER_ROLE){
        maxStopLoss = _maxStopLoss;
    }
    
    function setInitBUSDBalance(uint256 _initBUSDBalance) public virtual onlyRole(TRADE_MANAGER_ROLE){
        initBUSDBalance = _initBUSDBalance;
    }
    
    function setMaxDuration(uint256 _maxDurationNbBlock) external onlyRole(TRADE_MANAGER_ROLE){
        maxDurationNbBlock = _maxDurationNbBlock;
    }
    
    function forceEndTrade() public onlyRole(TRADE_MANAGER_ROLE) virtual{
        _endTrade();
    }
    
    function endTrade() public onlyRole(TRADE_MANAGER_ROLE) virtual{
        _endTrade();
    }
    
    function updateNeeded() public view virtual returns (bool){
        return false;
    }
    
    function update() public virtual onlyRole(UPDATER_ROLE){
    }
    
    function endTradeNeeded() public view virtual returns (bool){
        if (tradeManager.isTerminated()){
            return true;
        }
        
        if (block.number >= initBlock + maxDurationNbBlock){
            return true;
        }
        
        Fraction memory pnl = getPnL();
        if (pnl.numerator <= pnl.denominator - (pnl.denominator * maxStopLoss.numerator) / maxStopLoss.denominator){
            return true;
        }
        
        return false;
    }
    
    function getInitBUSDBalance() external view returns (uint256){
        return initBUSDBalance;
    }
    
    function estimateBUSDBalance() public view virtual returns (uint256){
        uint256 balance = BUSDToken.balanceOf(thisAddr);
        return balance;
    }
    
    function getPnL() public view returns (Fraction memory){
        Fraction memory f;
        f.numerator = estimateBUSDBalance();
        f.denominator = initBUSDBalance;
        
        return f;
    }
    
    ////
    ////
    ////
    //////////////// Private functions ////////////////
    function _endTrade() internal{
        uint256 balance = BUSDToken.balanceOf(thisAddr);
        
        tradeProfit.numerator = balance;
        tradeProfit.denominator = initBUSDBalance;
        
        fund.updateWithdrawFees(tradeProfit);
        competition.updateEndTrade(tradeProfit, tradeId);
        
        uint256 withdrawFeesNumerator = fund.getWithdrawFees();
        
        uint256 nbPWRToWithdraw = withdrawer.getNbPWRToWithdraw(tradeId);
        uint256 nbPWRFees = (nbPWRToWithdraw * withdrawFeesNumerator) / 1e10;
        
        uint256 nbBUSDToWithdraw = fund.getBUSDAmountFromPWR(nbPWRToWithdraw - nbPWRFees);
        
        if (nbBUSDToWithdraw > balance){
            nbBUSDToWithdraw = balance;
        }
        
        if (nbBUSDToWithdraw > 0){
            BUSDToken.transfer(address(withdrawer), nbBUSDToWithdraw);
        }
        
        withdrawer.closeTrade(tradeId, nbBUSDToWithdraw);
        
        if (nbBUSDToWithdraw < balance){
            BUSDToken.transfer(address(fund), balance - nbBUSDToWithdraw);
        }
    }

}// Version: 1.0.0





abstract contract With_PancakeRouter is Base, AccessControl, With_DAORole, I_With_PancakeRouter{
    PancakeRouter public pancakeRouter;

    function setPancakeRouter(PancakeRouter addr) external onlyRole(DAO_ROLE){
        pancakeRouter = addr;
    }
}// Version: 1.0.0



abstract contract Initializable is Base, I_Initializable{
    mapping(uint256=>bool) internal initialized;
    
    modifier onlyInitialized(uint256 id) {
        require(initialized[id], "Initializable: not initialized");
        _;
    }
    
    modifier onlyNotInitialized(uint256 id) {
        require(!initialized[id], "Initializable: already initialized");
        _;
    }
    
    function _initialize(uint256 id) internal{
        initialized[id] = true;
    }
    
    function isInitialized(uint256 id) public view returns(bool){
        return initialized[id];
    }
}

// Version: 1.0.0


interface I_Windmill_Trade_Swap is I_Initializable, I_With_PancakeRouter, I_Windmill_Trade_Abstract{
    struct LimitOrder{
        bool increaseSize;
        uint256 sizeIn;
        uint256 triggerPrice;
    }
    
    function getAvailableBUSD() external view returns(uint256);
}// Version: 1.0.0



interface I_Windmill_Trade_Deployer_Swap is I_With_PancakeRouter, I_Windmill_Trade_Deployer_Abstract{
    struct Token{
        IERC20 token;
        uint256 routeId;
    }
    
    function getRoute(uint256 routeId) external view returns (address[] memory);
}

abstract contract Windmill_Trade_Swap is Base, Initializable, Windmill_Trade_Abstract, With_PancakeRouter, I_Windmill_Trade_Swap{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    IERC20 public token;
    
    uint256 public constant nbMaxLimitOrders = 10;
    
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////
    I_Windmill_Trade_Deployer_Swap internal deployerSwap;
    
    
    address[] internal route;
    address[] internal reverseRoute;
    
    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor(){
        deployerSwap = I_Windmill_Trade_Deployer_Swap(deployer);
    }

    ////
    ////
    ////
    //////////////// Public functions ////////////////
    
    function initTrade(address _owner, address _manager, address _fund, address _updater, address _withdrawer, address _competition) public onlyRole(DAO_ROLE) virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract){
        super.initTrade(_owner, _manager, _fund, _updater, _withdrawer, _competition);
        
        BUSDToken.approve(address(pancakeRouter), type(uint256).max);
    }
    
    function forceEndTrade() public onlyRole(TRADE_MANAGER_ROLE) virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract){
        if (isInitialized(0)){
            try token.balanceOf(thisAddr) returns(uint256 nbToken){
                if (nbToken>0){
                    _trySwap(nbToken, reverseRoute);
                }
            }catch{}
        }
        
        super.forceEndTrade();
    }
    
    function endTrade() public onlyRole(TRADE_MANAGER_ROLE) virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract){
        
        if (isInitialized(0)){
            uint256 nbToken = token.balanceOf(thisAddr);
            if (nbToken>0){
                _swap(nbToken, reverseRoute);
            }
        }
        
        super.endTrade();
    }
    
    function getNbToken() external view returns (uint256){
        return token.balanceOf(thisAddr);
    }
    
    function getAvailableBUSD() public view virtual returns(uint256){
        return BUSDToken.balanceOf(thisAddr);
    }
    
    
    
    function estimateBUSDBalance() public view virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract) returns (uint256){
        uint256 BUSDBalance = super.estimateBUSDBalance();
        
        if (!isInitialized(0)){
            return BUSDBalance;
        }
        
        uint256 tokenBalance = token.balanceOf(thisAddr);
        
        if (tokenBalance==0){
            return BUSDBalance;
        }
        
        uint256[] memory sizeBUSD = pancakeRouter.getAmountsOut(tokenBalance, reverseRoute);
        
        return BUSDBalance + sizeBUSD[sizeBUSD.length-1];
    }
    
    

    
    ////
    ////
    ////
    //////////////// Private functions ////////////////
    
    function _swap(uint256 sizeIn, address[] storage _route) internal returns(uint256){
        uint256[] memory sizeOut = pancakeRouter.getAmountsOut(sizeIn, _route);
        uint256 sizeOutMin = sizeOut[sizeOut.length-1];
        
        uint[] memory amounts = pancakeRouter.swapExactTokensForTokens(sizeIn, sizeOutMin, _route, thisAddr, block.timestamp);
        
        return amounts[amounts.length-1];
    }
    
    function _trySwap(uint256 sizeIn, address[] storage _route) internal returns(uint256){
        try pancakeRouter.getAmountsOut(sizeIn, _route) returns(uint256[] memory sizeOut){
            if (sizeOut.length>0){
                uint256 sizeOutMin = sizeOut[sizeOut.length-1];
                try pancakeRouter.swapExactTokensForTokens(sizeIn, sizeOutMin, _route, thisAddr, block.timestamp) returns(uint[] memory amounts){
                    if (amounts.length>0){
                        return amounts[amounts.length-1];
                    }
                }catch{}
            }
        }catch{}
        
        return 0;
    }
    
    function _swapTo(uint256 sizeOut, address[] storage _route) internal returns(uint256){
        uint256[] memory sizeIn = pancakeRouter.getAmountsIn(sizeOut, _route);
        uint256 sizeInMax = sizeIn[0];
        
        uint[] memory amounts = pancakeRouter.swapTokensForExactTokens(sizeOut, sizeInMax, _route, thisAddr, block.timestamp);
        
        return amounts[0];
    }
    
    function _trySwapTo(uint256 sizeOut, address[] storage _route) internal returns(uint256){
        try pancakeRouter.getAmountsIn(sizeOut, _route) returns(uint256[] memory sizeIn){
            if (sizeIn.length>0){
                uint256 sizeInMax = sizeIn[0];
                try pancakeRouter.swapTokensForExactTokens(sizeOut, sizeInMax, _route, thisAddr, block.timestamp) returns(uint[] memory amounts){
                    if (amounts.length>0){
                        return amounts[0];
                    }
                }catch{}
            }
        }catch{}
        
        return 0;
    }
    
    function _setRoute(address[] memory _route, IERC20 _token) internal{
        uint256 l = _route.length;
        
        address[] memory _reverseRoute = new address[](l);
        for(uint i=0; i<l; i++){
            _reverseRoute[i] = _route[l-i-1];
        }
        
        route = _route;
        reverseRoute = _reverseRoute;
        
        token = _token;
        
        token.approve(address(pancakeRouter), type(uint256).max);
        
        _initialize(0);
    }
    
    function _deleteOrder(LimitOrder[] storage arr, uint256 i) internal{
        uint256 lastI = arr.length - 1;
        if (i != lastI){
            arr[i] = arr[lastI];
        }
        arr.pop();
    }
}
// Version: 1.0.0


interface I_Windmill_Trade_Long is I_Windmill_Trade_Swap{
}

contract Windmill_Trade_Long is Base, Windmill_Trade_Swap, I_Windmill_Trade_Long{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////
    LimitOrder[] internal swapLimitOrders;
    LimitOrder[] internal swapStopOrders;
    
    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor(){
        name = 'Windmill_Trade_Long';
    }

    ////
    ////
    ////
    //////////////// Public functions ////////////////
    function setRoute(uint256 routeId) external onlyRole(OWNER_ROLE) onlyNotInitialized(0){
        address[] memory _route = deployerSwap.getRoute(routeId);
        
        _setRoute(_route, IERC20(_route[_route.length-1]));
    }
    
    function placeSwapMarketOrder(bool increaseSize, uint256 sizeIn) external onlyRole(OWNER_ROLE) onlyInitialized(0){
        if (increaseSize){
            uint256 nbToken = getAvailableBUSD();
            require(sizeIn <= nbToken, "Windmill_Trade_Swap: Not enough BUSD");
            
            _swap(sizeIn, route);
        }else{
            uint256 nbToken = token.balanceOf(thisAddr);
            require(sizeIn <= nbToken, "Windmill_Trade_Swap: Not enough token");
            
            _swap(sizeIn, reverseRoute);
        }
    }
    
    
    function placeSwapOrder(bool increaseSize, uint256 sizeIn, uint256 triggerPrice, bool isLimit) external onlyRole(OWNER_ROLE) onlyInitialized(0){
        
        LimitOrder memory order;
        order.increaseSize = increaseSize;
        order.sizeIn = sizeIn;
        order.triggerPrice = triggerPrice;
        
        if (isLimit){
            require(swapLimitOrders.length < nbMaxLimitOrders, "Windmill_Trade_Swap: Maximum of 10 orders reached.");
            swapLimitOrders.push(order);
        }else{
            require(swapStopOrders.length < nbMaxLimitOrders, "Windmill_Trade_Swap: Maximum of 10 orders reached.");
            swapStopOrders.push(order);
        }
    }
    
    function getNbSwapLimitOrders() external view returns (uint256){
        return swapLimitOrders.length;
    }

    function getSwapLimitOrder(uint256 id) external view returns (LimitOrder memory){
        uint256 l = swapLimitOrders.length;
        
        require(id < l, "Windmill_Trade_Swap: Limit order id not found.");
        
        return swapLimitOrders[id];
    }
    
    function getNbSwapStopOrders() external view returns (uint256){
        return swapStopOrders.length;
    }
    
    function getSwapStopOrder(uint256 id) external view returns (LimitOrder memory){
        uint256 l = swapStopOrders.length;
        
        require(id < l, "Windmill_Trade_Swap: Stop order id not found.");
        
        return swapStopOrders[id];
    }
    
    function deleteSwapLimitOrder(uint256 id) external onlyRole(OWNER_ROLE){
        require(id < swapLimitOrders.length, "Windmill_Trade_Swap: Limit order id not found.");
        
        _deleteOrder(swapLimitOrders, id);
    }
    
    function deleteSwapStopOrder(uint256 id) external onlyRole(OWNER_ROLE){
        require(id < swapStopOrders.length, "Windmill_Trade_Swap: Stop order id not found.");
        
        _deleteOrder(swapStopOrders, id);
    }
    
    
    function updateNeeded() public view virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract) returns (bool){
        if (super.updateNeeded()){
            return true;
        }
        
        if (_processSwapUpdateNeeded(swapLimitOrders, false)){
            return true;
        }
        
        if (_processSwapUpdateNeeded(swapStopOrders, true)){
            return true;
        }
        
        return false;
    }
    
    function update() public virtual override(I_Windmill_Trade_Abstract, Windmill_Trade_Abstract) onlyRole(UPDATER_ROLE){
        super.update();
        
        _processSwapUpdate(swapLimitOrders, false);
        _processSwapUpdate(swapStopOrders, true);
    }
    
    function getTokenPrice(uint256 sizeBUSD) public view onlyInitialized(0) returns (uint256){
        uint256[] memory sizeToken = pancakeRouter.getAmountsOut(sizeBUSD, route);
        uint256 tokenPrice = (sizeBUSD * 1e18) / sizeToken[sizeToken.length-1];
        
        return tokenPrice;
    }
    
    function getTokenPriceFromTokenSize(uint256 sizeToken) public view onlyInitialized(0) returns (uint256){
        uint256[] memory sizeBUSD = pancakeRouter.getAmountsOut(sizeToken, reverseRoute);
        uint256 tokenPrice = (sizeBUSD[sizeBUSD.length-1] * 1e18) / sizeToken;
        
        return tokenPrice;
    }
    
    ////
    ////
    ////
    //////////////// Private functions ////////////////
    
    function _processSwapUpdate(LimitOrder[] storage arr, bool isStop) internal{
        uint256 l = arr.length;
        
        uint256 i = l;
        while(i>0){
            i--;
            LimitOrder storage order = arr[i];
            _updateOneSwapOrder(arr, order, i, isStop);
        }
    }
    
    function _processSwapUpdateNeeded(LimitOrder[] storage arr, bool isStop) internal view returns(bool){
        uint256 l = arr.length;
        
        for(uint256 i=0; i<l; i++){
            LimitOrder storage order = arr[i];
            if (_oneSwapUpdateNeeded(order, isStop)){
                return true;
            }
        }
        return false;
    }
    
    function _updateOneSwapOrder(LimitOrder[] storage arr, LimitOrder storage order, uint256 i, bool isStop) internal{
        if (_oneSwapUpdateNeeded(order, isStop)){
            uint256 sizeIn = order.sizeIn;
            
            if (order.increaseSize){
                uint256 nbToken = getAvailableBUSD();
                if (nbToken > 0){
                    if (nbToken < sizeIn){
                        sizeIn = nbToken;
                    }
                    _swap(sizeIn, route);
                }
                
            }else{
                uint256 nbToken = token.balanceOf(thisAddr);
                if (nbToken > 0){
                    if (nbToken < sizeIn){
                        sizeIn = nbToken;
                    }
                    _swap(sizeIn, reverseRoute);
                }
                
            }
            
            _deleteOrder(arr, i);
        }
    }
    
    
    function _oneSwapUpdateNeeded(LimitOrder storage order, bool isStop) internal view returns (bool){
        
        if ((order.increaseSize && !isStop) || (!order.increaseSize && isStop)){
            uint256 tokenPrice = getTokenPrice(order.sizeIn);
            if (tokenPrice <= order.triggerPrice){
                return true;
            }
        }else{
            uint256 tokenPrice = getTokenPriceFromTokenSize(order.sizeIn);
            if (tokenPrice >= order.triggerPrice){
                return true;
            }
        }
        
        return false;
    }
}