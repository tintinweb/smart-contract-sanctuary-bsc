/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

// SPDX-License-Identifier: MIT
// Version: 1.0.0
pragma solidity 0.8.10;
// Version: 1.0.0
// Version: 1.0.0
// Version: 1.0.0
interface I_With_DAORole{
    /**
     * DAO_ROLE is able to grant and revoke roles. It can be used when the DAO
     * vote to change some contracts of Flask.
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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})
/
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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})
/
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
}
// Version: 1.0.0
// Version: 1.0.0
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
 * @notice Flask_Power is the ERC20 token (PWR) representing
 * a share of the fund in the Flask_Fund contract.
 *
 * There is a primary market that value PWR in the form of
 * mint and burn by the Flask_Fund contract.
 * In exchange of depositing or withdrawing BUSD from the fund,
 * PWR token are minted to or burned from the user address.
 * The minting/burning value of PWR only depends on the total supply
 * in BUSD in the fund related to the total supply of PWR.
 * This mean that PWR will gain primary value only via
 * Flask traders performance
 *
 * Also, as PWR is an ERC20 token, it can be freely traded, so secondary
 * markets can exist.
 */
interface I_Flask_Power is I_Math, IAccessControl, I_With_DAORole, IERC20, I_With_FundContract{
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
     * @notice Allow the Flask_Fund to mint PWR for an address
     * Flask_Fund can use this method to buy PWR in exchange of BUSD
     * This do not change the PWR price because there is the corresponding amount of BUSD
     * that have been added to the fund.
     *
     * Flask_Competition, Flask_stacking and Flask_Royalties can alsoo mint PWR
     * for their usage (competition and stacking reward, royalties).
     * These minting will decrease the value of PWR from the Flask_Fund contract.
     */
    function mintTo(address to, uint256 amount) external;
    /**
     * @notice Allow the Flask_Fund to burn PWR from an address
     * in exchange of withdrawing BUSD from the fund to the address.
     * When Flask_Fund use this method, this do not change the PWR price
     * because there is the right amount of BUSD that have been removed
     * from the fund.
     */
    function burnFrom(address from, uint256 amount) external;
    /**
     * @notice Allow the Flask_Fund to transfert PWR from an address
     * to a trade contract
     * Flask_Stacking and Flask_Trade_Manager use this method to lock the PWR from
     * direct withdraw. There is two main reason for this to happen :
     *
     * - PWR are locked from user to Flask_Trade contract by Flask_Trade_Manager
     * contract when starting a new trade. The corresponding BUSD from Flask_Fund are also
     * allocated to the trade. These locked PWR are returned at the end of the trade.
     *
     * - PWR are stacked by the user in Flask_Stacking. These PWR are returned
     * at the end of the stacking period. Note that returned PWR can be still
     * locked in a trade, that will be returned at the end of trade.
     */
    function transferFromTo(address from, address to, uint256 amount) external;
}
interface I_With_PWRToken is IAccessControl, I_With_DAORole{
    function setPWRToken(I_Flask_Power token) external;
}// Version: 1.0.0

interface I_With_BUSDToken is IAccessControl, I_With_DAORole{
    function setBUSDToken(IERC20 token) external;
}// Version: 1.0.0


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

interface I_With_UpdaterRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function UPDATER_ROLE() external view returns (bytes32);
}// Version: 1.0.0

interface I_With_TradeManagerRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function TRADE_MANAGER_ROLE() external view returns (bytes32);
}// Version: 1.0.0
interface I_Payable{
    receive() external payable;
}
// Version: 1.0.0
// Version: 1.0.0

interface I_With_WithdrawerContract is IAccessControl, I_With_DAORole{
    function setWithdrawer(address _withdrawer) external;
}// Version: 1.0.0

interface I_With_TradeManagerContract is IAccessControl, I_With_DAORole{
    function setTradeManager(address _tradeManager) external;
}// Version: 1.0.0

interface I_With_CompetitionContract is IAccessControl, I_With_DAORole{
    function setCompetition(address _competition) external;
}
interface I_Flask_Trade_Abstract is I_Math, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole,
                                       I_With_BUSDToken, I_With_FundContract, I_With_TradeManagerContract, I_With_WithdrawerContract, I_With_CompetitionContract{
    
    event Action(uint256 id, uint256 timestamp, uint256 data0, uint256 data1, address dataAddr0, address dataAddr1);
    
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

interface I_With_TradeRole is I_With_DAORole, I_With_TradeManagerRole{
    function TRADE_ROLE() external view returns (bytes32);
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
 * @notice Flask_Fund is the contract that store and manage the BUSD used for
 * Flask activities.
 *
 * The features of this contract are :
 * - Mint/burn PWR in exchange of depositing/withdrawing BUSD.
 * - Send BUSD to a Flask_Contract trade.
 */
interface I_Flask_Fund is I_Math, I_Payable, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_TradeRole,
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
    
    function updateWithdrawFees(uint256 finalBalance, uint256 initBalance) external;
    
    function getWithdrawFees() external view returns(uint256);
    
    function getDataPWRLock(address addr) external view returns (uint256, uint256, uint256, uint256, uint256[2][] memory);
    function removeLockedPWRTokens(address addr, uint256 amountPWR) external;
    function getBNBForGasRefund(uint256 amountBNB) external;
    /**
     * Compute the BUSD hold buy Flask contracts.
     */
    function getFundBUSD() external view returns (uint256);
    /**
     * Compute the BUSD hold buy Flask contracts.
     */
    function getAvailableBUSD() external view returns (uint256);
    
    function sendBUSDToTrade(I_Flask_Trade_Abstract trade, uint256 nbBUSD) external;
    
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
    I_Flask_Fund internal fund;
    function setFund(address _fund) public onlyRole(DAO_ROLE){
        fund = I_Flask_Fund(payable(_fund));
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
// Version: 1.0.0

abstract contract Adressable is Base{
    address payable immutable internal thisAddr;
    constructor(){
        thisAddr = payable(address(this));
    }
}
// Version: 1.0.0

// Version: 1.0.0

interface I_With_DAOAddress is IAccessControl, I_With_DAORole{
    function setDAOAddress(address _DAOAddress) external;
}
abstract contract With_DAOAddress is Base, AccessControl, With_DAORole, I_With_DAOAddress{
    address public DAOAddress;
    function setDAOAddress(address _DAOAddress) external onlyRole(DAO_ROLE){
        DAOAddress = _DAOAddress;
    }
}// Version: 1.0.0


abstract contract With_BUSDToken is Base, AccessControl, With_DAORole, I_With_BUSDToken{
    IERC20 public BUSDToken;
    function setBUSDToken(IERC20 token) external onlyRole(DAO_ROLE){
        BUSDToken = token;
    }
}// Version: 1.0.0

// Version: 1.0.0

interface I_With_UpdaterContract is IAccessControl, I_With_DAORole{
    function setUpdater(address _updater) external;
}// Version: 1.0.0
// Version: 1.0.0


/**
 * @notice Flask_Royalties
 */
interface I_Flask_Royalty is I_Math, IAccessControl, I_With_DAORole, I_With_UpdaterRole, IERC20, I_With_PWRToken, I_With_FundContract{
    function percentPWRRoyaltyMint() external view returns (uint256, uint256);
    function mintTo(address to, uint256 amount) external;
    function setRoyaltyRatio(uint256 numerator, uint256 denominator) external;
    /**
     * @notice The loop length have a maximum of ROY supply (in ether)
     */
    function processRoyalties() external;
}// Version: 1.0.0

/**
 * @notice Flask_Stacking
 */
interface I_Flask_Stacking is I_Math, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterRole, I_With_PWRToken, I_With_FundContract{
    event StackingTotalSupplyUpdate(uint256 Supply);
    event StackingGroupUpdate(address indexed addr);
    
    struct StackingGroup{
        uint256 nbPWR;
        uint256 nbSPWR;
        uint256 startCycle;
        uint256 currentCycle;
        uint256 endCycle;
        bool stacked;
        address userAddr;
    }
    struct CycleData{
        uint256 sPWRSupply;
        uint256 totalPWRMinted;
    }
    
    function stackedPWR(address addr) external view returns(uint256);
    
    function setMaxCycleLock(uint256 nbCycles) external;
    function setStackingRewardRatio(uint256 numerator, uint256 denominator) external;
    function setStackingBonusRatio(uint256 numerator, uint256 denominator) external;
    function setEarlyUnstackingFeesPercent(uint256 numerator, uint256 denominator) external;
    function updateCycle(uint256 cycleId) external;
    function updateStackingNeeded() external view returns (bool);
    
    function updateOneClaimRewardNeeded(uint256 groupId) external view returns (bool);
    
    function updateOneStackingNeeded(uint256 groupId) external view returns (bool);
    function updateOneStacking(uint256 groupId) external;
    
    function updateOneClaimReward(uint256 groupId) external;
    function updateStacking() external;
}// Version: 1.0.0

interface I_Gas_Refundable is I_Math{
    struct RefundData{
        uint256 usedGas;
        uint256 refundLastBlock;
    }
    function refundBNBBonusRatio() external view returns (uint256, uint256);
    function refundGas() external;
}// Version: 1.0.0

interface I_With_StackingContract is IAccessControl, I_With_DAORole{
    function setStacking(I_Flask_Stacking _stacking) external;
}// Version: 1.0.0

interface I_With_RoyaltyContract is IAccessControl, I_With_DAORole{
    function setRoyalty(I_Flask_Royalty _royalty) external;
}
interface I_Flask_Updater is I_Payable, I_Gas_Refundable, IAccessControl, I_With_DAORole, I_With_DAOContract, I_With_FundContract,
                                I_With_StackingContract, I_With_RoyaltyContract, I_With_CompetitionContract, I_With_TradeManagerContract{
    function init() external;
    
    function setDAOCycleDuration(uint256 duration) external;
    function setStackingCycleDuration(uint256 duration) external;
    function setRoyaltyCycleDuration(uint256 duration) external;
    function setCompetitionCycleDuration(uint256 duration) external;
    
    function setUserGovernorStatus(address user, bool isGovernor) external;
    
    function setRefundGasDefaultPrice(uint256 val) external;
    
    function setRefundNbBlockDelay(uint256 val) external;
    
    function setRefundBNBBonusRatio(uint256 numerator) external;
    
    function setRefundNbBNBMin(uint256 val) external;
}

abstract contract With_UpdaterContract is Base, AccessControl, With_DAORole, I_With_UpdaterContract{
    I_Flask_Updater public updater;
    function setUpdater(address _updater) external onlyRole(DAO_ROLE){
        updater = I_Flask_Updater(payable(_updater));
    }
}// Version: 1.0.0


abstract contract With_PWRToken is Base, AccessControl, With_DAORole, I_With_PWRToken{
    I_Flask_Power public PWRToken;
    function setPWRToken(I_Flask_Power token) external onlyRole(DAO_ROLE){
        PWRToken = token;
    }
}// Version: 1.0.0

// Version: 1.0.0


interface I_Flask_Withdrawer is I_Math, IAccessControl, I_With_DAORole, I_With_TradeManagerRole, I_With_TradeRole,
                                   I_With_PWRToken, I_With_BUSDToken, I_With_FundContract{
    
    event WithdrawUpdate(address indexed addr);
    
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
}
abstract contract With_WithdrawerContract is Base, AccessControl, With_DAORole, I_With_WithdrawerContract{
    I_Flask_Withdrawer public withdrawer;
    function setWithdrawer(address _withdrawer) public onlyRole(DAO_ROLE){
        withdrawer = I_Flask_Withdrawer(payable(_withdrawer));
    }
}// Version: 1.0.0

// Version: 1.0.0

/**
 * @notice Flask_Competition
 */
interface I_Flask_Competition is I_Math, IAccessControl, I_With_DAORole, I_With_TradeRole, I_With_UpdaterRole, I_With_PWRToken, I_With_FundContract, I_With_TradeManagerContract{
    event CompetitionEnded();
    event CompetitionRewardClaimed(address indexed addr);
    
    struct CycleData{
        uint256 totalPWRMinted;
        uint256 totalProfitNumerator;
        bool completed;
        mapping(address=>UserDetails) user;
        address[] users;
        mapping(address=>uint256) usersId;
        uint256 startBlock;
        uint256 endBlock;
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
    I_Flask_Competition public competition;
    function setCompetition(address _competition) public onlyRole(DAO_ROLE){
        competition = I_Flask_Competition(payable(_competition));
    }
}// Version: 1.0.0


abstract contract With_StackingContract is Base, AccessControl, With_DAORole, I_With_StackingContract{
    I_Flask_Stacking public stacking;
    function setStacking(I_Flask_Stacking _stacking) external onlyRole(DAO_ROLE){
        stacking = _stacking;
    }
}// Version: 1.0.0

abstract contract Terminatable is Base, With_DAORole, I_Terminatable{
    bool internal terminated;
    
    modifier onlyNotTerminated() {
        require(!terminated, "Terminatable: already terminated");
        _;
    }
    
    function terminate() external onlyRole(DAO_ROLE){
        terminated = true;
    }
    
    function isTerminated() external view returns(bool){
        return terminated;
    }
}
// Version: 1.0.0
// Version: 1.0.0
// Version: 1.0.0
interface I_Initializable{
    function isInitialized(uint256 id) external view returns(bool);
}

interface I_Flask_Trade_Deployer_Abstract is I_Initializable, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_BUSDToken{
    function isPaper() external returns (bool);
    function name() external returns (string memory);
    
    function deployNewTrade(address owner, address manager, address fund, address updater, address withdrawer, address competition) external returns (I_Flask_Trade_Abstract);
    
    function checkProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external view returns (bool);
    
    function applyProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external;
}
interface I_Flask_Trade_Manager is I_Math, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterContract, I_With_CompetitionContract,
                                      I_With_StackingContract, I_With_FundContract, I_With_DAOAddress, I_With_BUSDToken, I_With_PWRToken, I_With_WithdrawerContract{
    
    event StartTrade(uint256 deployerId, uint256 tradeId, address owner);
    event EndTrade(uint256 tradeId);
    event EnergyUpdate(address addr);
    event TraderLevelUpdated(address indexed addr);
    
    struct DeployerData{
        I_Flask_Trade_Deployer_Abstract deployer;
        bool enabled;
    }
    
    struct TradeData{
        I_Flask_Trade_Abstract trade;
        address owner;
        uint256 energy;
        bool isActive;
        uint256 percentPWRLockedNumerator;
        uint256 blockStart;
        uint256 blockEnd;
        bool isPaper;
        uint256 maxEnergy;
    }
    
    struct PointData{
        uint256 nbPoints;
        uint256 cycleEndBlock;
        bool isNegative;
    }
    
    function setBaseEnergyBonusRatio(uint256 numerator, uint256 denominator) external;
    
    function getMaxEnergy(address addr) external view returns (uint256);
    
    function setMaxLeverage(uint256 numerator, uint256 denominator) external;
    
    function setMaxTradeStopLoss(uint256 numerator, uint256 denominator) external;
    
    function setMaxTradeDurationNbBlock(uint256 _maxTradeDurationNbBlock) external;
    
    function setMinimumBUSDToTrade(uint256 _minimumBUSDToTrade) external;
    
    function setJuniorTrader(address addr) external;
    
    function setSeniorTrader(address addr) external;
    
    function demoteTrader(address addr) external;
    
    function addTradeDeployer(I_Flask_Trade_Deployer_Abstract trade) external;
    
    function disableTradeDeployer(uint256 deployerId) external;
    
    function getNbTradeDeployers() external view returns (uint256);
    
    function getTrade(uint256 id) external view returns (TradeData memory);
    
    function getNbOpenTrades() external view returns (uint256);
    
    function getNbOpenRealTrades() external view returns (uint256);
    
    function getNbTrades() external view returns (uint256);
    
    function getOpenTrade(uint openId) external view returns (TradeData memory, uint256);
    
    function getOpenRealTrade(uint openId) external view returns (TradeData memory, uint256);
    
    function getTradeDeployer(uint256 id) external view returns (DeployerData memory);
    
    function endTrade(uint256 tradeId) external;
    
    function forceEndTrade(uint256 tradeId) external;
    
    function setMinPWRToStartPaperTrade(uint256 nb) external;
    
    function setAutoPromotionEnabled(bool enabled) external;
    
    function setNbBlockPerPointCycle(uint256 nb) external;
    
    function setNbPointsToPromoteJuniorTrader(uint256 nb) external;
    
    function setNbPointsToPromoteSeniorTrader(uint256 nb) external;
    
    function setNbNegativePointsToDemoteJuniorTrader(uint256 nb) external;
    
    function setNbNegativePointsToDemoteSeniorTrader(uint256 nb) external;
    
    function initBUSDBlanceInTrades() external view returns(uint256);
}// Version: 1.0.0


/**
 * @notice Flask_DAO is the contract that manage de DAO of Flask.
 *
 * It can modify all the parameters of Flask, and update the Flask contracts
 */
interface I_Flask_DAO is IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterRole, I_With_FundContract,
                            I_With_StackingContract, I_With_RoyaltyContract, I_With_CompetitionContract, I_With_TradeManagerContract,
                            I_With_UpdaterContract, I_With_PWRToken{
    event ConfigUpdate();
    event NewProposal(address indexed applicant);
    event VoteUpdate(uint256 proposalId);
    event ProposalRejected();
    
    /**
     * @notice Define an address capability about the DAO
     *
     *
     * nbProposalsDone -> How many proposals have been made in the lastProposalCycle cycle
     * lastProposalDAOCycle -> Last cycle where the address have made a proposal
     */
    struct DAOLevel{
        uint256 lastProposalDAOCycle;
        uint16 nbProposalsDone;
        bool isGovernor;
        bool isInvestor;
        string username;
    }
    
    struct VoteLevelData{
        uint256 quorum;
        uint256 majorityPercent;
        uint256 blockDuration;
        uint256 quorumTrigger;
    }
    /**
     * @notice Define a proposal.
     *
     * id -> Identifiant of the proposal
     * paramsUint256 -> parameter of type uint256 associated with the proposal
     * paramsAddress -> parameter of type address associated with the proposal
     * - 0 -> Change the number of proposals per user per cycle
     *      (uint256) [1, 100] -> Number of proposals
     * - 1 -> Change the duration of vote
     *      (uint256) [28800 (1 day), 864000 (1 month)] -> Number of block
     * - 2 -> Change the quorum
     *      (uint256) [1, 100] -> Number of vote
     * - 3 -> Change the max number of open proposals
     *      (uint256) [10, 1000] -> Number of open proposals
     * - 4 -> Change the vote majority percent
     *      (uint256) [50, 100] -> Percent of yes votes
     * - 5 -> Change the duration of a super vote
     *      (uint256) [28800 (1 day), 864000 (1 month)] -> Number of block
     * - 6 -> Change the quorum of a super vote
     *      (uint256) [1, 100] -> Number of vote
     * - 7 -> Change the vote majority percent of a super vote
     *      (uint256) [50, 100] -> Percent of yes votes
     * - 8 -> define a vote as super status
     *      (uint256) [0, nbProposals] -> Vote id
     * - 9 -> define a vote as normal status
     *      (uint256) [0, nbProposals] -> Vote id
     * - 10 -> update trade max stop loss
     *      (uint256) [0, 500] -> stop loss (per 1000 ratio -> 10 = 1% / 100 = 10%)
     * - 11 -> set the ratio of PWR supply minted per competition cycle
     *      (uint256) [0, 1000] -> PWR ratio (per 10000 ratio -> 10 = 0.1% / 100 = 1%)
     * - 12 -> Change the DAO cycle duration
     *      (uint256) [201600 (7 days), 10512000 (1 year)] -> Number of block
     * - 13 -> Change the gas refund price
     *      (uint256) [0, 100000000000 (100 gwei)] -> Gas price in Wei
     * - 14 -> Change the refund minimum BNB quantity
     *      (uint256) [0, inf] -> Minimum BNB quantity to refund
     * - 15 -> Change the refund bonus
     *      (uint256) [100, 200] -> 100 + Percent of bonus
     * - 16 -> Promote a user to junior trader
     *      (address) -> user address
     * - 17 -> Promote a user to senior trader
     *      (address) -> user address
     * - 18 -> Promote a user to governor
     *      (address) -> user address
     * - 19 -> Demote user from governor
     *      (address) -> user address
     * - 20 -> Change the minimum delay between two user refund
     *      (uint256) [28800 (1 day), 864000 (1 month)] -> Number of block
     * - 21 -> Change the royalty minting ratio
     *      (uint256) [25, 1000] -> ratio (per 10.000 ratio -> 100 = 1%)
     * - 22 -> Change the dynamic fees duration
     *      (uint256) [0, 10512000 (1 year)] -> Number of block
     * - 23 -> Change the Royalty cycle duration
     *      (uint256) [28800 (1 day), 201600 (1 week)] -> Number of block
     * - 24 -> Change the Stacking cycle duration
     *      (uint256) [28800 (1 day), 10512000 (1 year)] -> Number of block
     * - 25 -> Change the Stacking reward minting ratio
     *      (uint256) [0, 1000] -> ratio (per 10.000 ratio -> 100 = 1%)
     * - 26 -> Change the Stacking bonus factor per cycle lock
     *      (uint256) [0, 10000] -> ratio (per 10.000 ratio -> 0 = 0% / 100 = 1%)
     * - 27 -> Change the early unstacking fees per remaining cycle
     *      (uint256) [0, 10000] -> ratio (per 10.000 ratio -> 100 = 1%)
     * - 28 -> Change the fund PWR sell base fees
     *      (uint256) [0, 2500] -> ratio (per 10.000 ratio -> 100 = 1%)
     * - 29 -> Trade deployer proposal
     *      (uint16) [0, 65536] -> Deployer id in Flask_Trade_Manaager
     *      (uint8) [0, 255] -> Deployer proposal id
     *      (uint232) -> Parameter of type integer
     *      (address) -> Parameter of type address
     * - 30 -> Add deployer
     *      (address) -> Deployer address
     * - 31 -> Change the max fund trading leverage
     *      (uint256) [0, 100] -> ratio (per 100 ratio -> 1 = 1%)
     * - 32 -> Change the maximum trade duration
     *      (uint256) [28800 (1 day), 10512000 (1 year)] -> Number of blocks
     * - 33 -> Change the minimum BUSD to enter a trade
     *      (uint256) [1 ether, inf] -> number of BUSD (in wei -> 1e18 = 1 BUSD)
     * - 34 -> Change the energy ratio bonus/malus of trade energy for +-100% profit
     *      (uint256) [0, 10000] -> energy bonus/malus ratio (per 10.000 ratio -> 100 = 1%)
     * - 35 -> Change the Competition cycle duration
     *      (uint256) [28800 (1 day), 10512000 (1 year)] -> Number of block
     * - 36 -> Change the duration of a security vote
     *      (uint256) [28800 (1 day), 864000 (1 month)] -> Number of block
     * - 37 -> Change the quorum of a security vote
     *      (uint256) [1, 100] -> Number of vote
     * - 38 -> Change the vote majority percent of a security vote
     *      (uint256) [50, 100] -> Percent of yes votes
     * - 39 -> define a vote as security status
     *      (uint256) [0, nbProposals] -> Vote id
     * - 40 -> Change the trigger quorum of a security vote (don't wait duration if trigger quorum reached)
     *      (uint256) [0, 100] -> Number of vote (0 disabled this functionality)
     * - 41 -> Terminate flask
     * - 42 -> Delete stuck proposal
     *      (uint256) -> Proposal id
     * - 43 -> Force end a trade (try to get the funds then close the trade)
     *      (uint256) -> Trade id
     * - 44 -> Promote a user to investor
     *      (address) -> user address
     * - 45 -> Enable investor whitelist
     * - 46 -> Disable investor whitelist
     * - 47 -> Set the maximum stacking lock cycles
     *      (uint256) [1, 100000] -> nb cycles
     * - 48 -> Disable a trade deployer
     *      (uint256) -> trade deployer id
     * - 49 -> Demote trader
     *      (address) -> user address
     * - 50 -> Demote investor
     *      (address) -> user address
     * - 51 -> Enable trader auto promotion
     * - 52 -> Disable trader auto promotion
     * - 53 -> Set trader auto promotion cycle duration
     *      (uint256) [201600 (7 days), 2592000 (3 months)] -> Number of block
     * - 54 -> Set min bought PWR to start paper trades
     *      (uint256) [ether] -> nb PWR
     * - 55 -> Set number of points to promote to junior trader (1 point = 1% of PnL with 1% of max energy)
     *      (uint256) [100 ether (1% per cycle), 10000 ether (100% per cycle)] -> nb points
     * - 56 -> Set number of points to promote to senior trader (1 point = 1% of PnL with 1% of max energy)
     *      (uint256) [100 ether (1% per cycle), 10000 ether (100% per cycle)] -> nb points
     * - 57 -> Set number of negative points to demote from junior trader (1 point = 1% of PnL with 1% of max energy)
     *      (uint256) [100 ether (1% per cycle), 10000 ether (100% per cycle)] -> nb points
     * - 58 -> Set number of negative points to demote from senior trader (1 point = 1% of PnL with 1% of max energy)
     *      (uint256) [100 ether (1% per cycle), 10000 ether (100% per cycle)] -> nb points
     *
     *
     *
     * startBlock -> Voting is allowed since this block number
     * endBlock -> Voting is terminated since this block number
     * nbYesVotes -> Number of yes vote
     * nbNoVotes -> Number of no vote
     * done -> Proposal is closed
     *
     * status -> Proposal status
     * - 0: Vote period not terminated
     * - 1: Not applied because quorum is not reached
     * - 2: Not applies because "no" majority
     * - 3: Applied
     */
    struct Proposal{
        uint256 paramsUint256;
        address paramsAddress;
        uint256 startBlock;
        uint256 endBlock;
        uint256 quorumTrigger;
        uint64 nbYesVotes;
        uint64 nbNoVotes;
        uint16 id;
        uint16 status;
        bool done;
        address owner;
    }
    /**
     *            uint256 _nbProposalPerUserPerCycle,
     *            uint256 _maxNbOpenProposals,
     *            uint256 _voteBlockDuration,
     *            uint256 _quorum,
     *            uint256 _voteMajorityPercent,
     *            uint256 _superVoteBlockDuration,
     *            uint256 _superQuorum,
     *            uint256 _superVoteMajorityPercent,
     *            uint256 _DAOcycleDurationNbBlock,
     *            uint256 _royaltyCycleDurationNbBlock,
     *            uint256 _stackingCycleDurationNbBlock,
     *            uint256 _competitionCycleDurationNbBlock,
     *            uint256 _securityVoteBlockDuration,
     *            uint256 _securityQuorum,
     *            uint256 _securityVoteMajorityPercent,
     *            uint256 _securityTriggerQuorum
     *
     */
    function init(uint256[16] calldata data,
                  uint256[] calldata _proposalLevel) external;
    function setDAOCycle(uint256 cycle) external;
    
    function getNbOpenProposalIds() external view returns (uint256);
    
    function updateOpenProposalNeeded(uint256 i) external view returns (bool);
    
    function updateOneOpenProposal(uint256 i) external;
    
    function investorWhitelistEnabled() external returns(bool);
    
    /**
     * @notice Add a user with capability on the DAO (used only at DAO contract initialization).
     */
    function addUser(address addr, bool isGovernor, bool isJuniorTrader, bool isSeniorTrader) external;
    
    function getUserData(address addr) external view returns (DAOLevel memory);
}

contract Flask_Trade_Manager is Base, Math, Adressable, AccessControl, With_DAORole, Terminatable, With_UpdaterContract, With_CompetitionContract,
                                   With_StackingContract, With_FundContract, With_DAOAddress, With_BUSDToken, With_PWRToken, With_WithdrawerContract, I_Flask_Trade_Manager{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    uint256 immutable public juniorTraderDefaultMaxEnergy;
    uint256 immutable public seniorTraderDefaultMaxEnergy;
    uint256 immutable public defaultPaperMaxEnergy;
    
    uint256 public minimumBUSDToTrade;
    
    uint256 public initBUSDBlanceInTrades;
    
    Fraction public maxLeverage;
    
    Fraction public maxTradeStopLoss;
    uint256 public maxTradeDurationNbBlock;
    
    uint256 public maxEnergyTotalSupply;
    
    Fraction public baseEnergyBonusRatio;
    
    uint256 public minPWRToStartPaperTrade;
    
    bool public autoPromotionEnabled;
    uint256 public nbPointsToPromoteJuniorTrader;
    uint256 public nbPointsToPromoteSeniorTrader;
    uint256 public nbNegativePointsToDemoteJuniorTrader;
    uint256 public nbNegativePointsToDemoteSeniorTrader;
    uint256 public nbBlockPerPointCycle;
    
    mapping(address=>uint256) public traderLevel;
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////
    mapping(address=>PointData) internal nbPoints;
    mapping(address=>uint256) internal maxEnergy;
    mapping(address=>uint256) internal usedEnergy;
    mapping(address=>uint256) internal maxPaperEnergy;
    mapping(address=>uint256) internal usedPaperEnergy;
    
    
    TradeData[] internal trades;
    uint256[] internal openTradeId;
    uint256[] internal openRealTradeId;
    
    DeployerData[] internal deployers;
    
    mapping(uint256=>uint256) internal TradeIdToOpenId;
    mapping(uint256=>uint256) internal TradeIdToOpenRealId;
    
    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor(){
        maxLeverage.numerator = 80;
        maxLeverage.denominator = 100;
        
        minimumBUSDToTrade = 500 ether;
        
        juniorTraderDefaultMaxEnergy = 10 ether;
        seniorTraderDefaultMaxEnergy = 100 ether;
        defaultPaperMaxEnergy = 100 ether;
        
        maxTradeStopLoss.numerator = 20;
        maxTradeStopLoss.denominator = 100;
        
        maxTradeDurationNbBlock = 864000;
        
        baseEnergyBonusRatio.numerator = 1000;
        baseEnergyBonusRatio.denominator = 10000;
        
        minPWRToStartPaperTrade = 100 ether;
        autoPromotionEnabled = true;
        nbPointsToPromoteJuniorTrader = 700 ether;
        nbPointsToPromoteSeniorTrader = 1400 ether;
        nbNegativePointsToDemoteJuniorTrader = 200 ether;
        nbNegativePointsToDemoteSeniorTrader = 300 ether;
        
        nbBlockPerPointCycle = 20 * 60 * 24 * 30;
    }
    ////
    ////
    ////
    //////////////// Public functions ////////////////
    function getPoints(address addr) external view returns(PointData memory){
        return nbPoints[addr];
    }
    
    function setNbBlockPerPointCycle(uint256 nb) external onlyRole(DAO_ROLE){
        nbBlockPerPointCycle = nb;
    }
    
    function setMinPWRToStartPaperTrade(uint256 nb) external onlyRole(DAO_ROLE){
        minPWRToStartPaperTrade = nb;
    }
    
    function setAutoPromotionEnabled(bool enabled) external onlyRole(DAO_ROLE){
        autoPromotionEnabled = enabled;
    }
    
    function setNbPointsToPromoteJuniorTrader(uint256 nb) external onlyRole(DAO_ROLE){
        nbPointsToPromoteJuniorTrader = nb;
    }
    
    function setNbPointsToPromoteSeniorTrader(uint256 nb) external onlyRole(DAO_ROLE){
        nbPointsToPromoteSeniorTrader = nb;
    }
    
    function setNbNegativePointsToDemoteJuniorTrader(uint256 nb) external onlyRole(DAO_ROLE){
        nbNegativePointsToDemoteJuniorTrader = nb;
    }
    
    function setNbNegativePointsToDemoteSeniorTrader(uint256 nb) external onlyRole(DAO_ROLE){
        nbNegativePointsToDemoteSeniorTrader = nb;
    }
    
    
    function setBaseEnergyBonusRatio(uint256 numerator, uint256 denominator) external onlyRole(DAO_ROLE){
        require(denominator>0, "Flask_Trade_Manager: Denominator cannot be null");
        
        baseEnergyBonusRatio.numerator = numerator;
        baseEnergyBonusRatio.denominator = denominator;
    }
    
    function setMaxLeverage(uint256 numerator, uint256 denominator) external onlyRole(DAO_ROLE){
        require(denominator>0, "Flask_Trade_Manager: Denominator cannot be null");
        
        maxLeverage.numerator = numerator;
        maxLeverage.denominator = denominator;
    }
    
    function setMaxTradeStopLoss(uint256 numerator, uint256 denominator) external onlyRole(DAO_ROLE){
        require(denominator>0, "Flask_Trade_Manager: Denominator cannot be null");
        
        maxTradeStopLoss.numerator = numerator;
        maxTradeStopLoss.denominator = denominator;
    }
    
    function setMaxTradeDurationNbBlock(uint256 _maxTradeDurationNbBlock) external onlyRole(DAO_ROLE){
        maxTradeDurationNbBlock = _maxTradeDurationNbBlock;
    }
    
    function setMinimumBUSDToTrade(uint256 _minimumBUSDToTrade) external onlyRole(DAO_ROLE){
        minimumBUSDToTrade = _minimumBUSDToTrade;
    }
    
    function claimPaperEnergy() external{
        require(maxPaperEnergy[msg.sender] == 0, "Flask_Trade_Manager: Paper energy already claimed.");
        require(maxEnergy[msg.sender] == 0, "Flask_Trade_Manager: Real trader cannot claim paper energy.");
        require(autoPromotionEnabled, "Flask_Trade_Manager: Autopromotion systemm is not enabled.");
    
        I_Flask_DAO DAO = I_Flask_DAO(DAOAddress);
        I_Flask_DAO.DAOLevel memory data = DAO.getUserData(msg.sender);
        bool investorWhitelistEnabled = DAO.investorWhitelistEnabled();
        uint256 nbPWR = PWRToken.balanceOf(msg.sender) + stacking.stackedPWR(msg.sender);
        
        require(nbPWR >= minPWRToStartPaperTrade, "Flask_Trade_Manager: Not enough PWR to claim paper energy.");
        require(!investorWhitelistEnabled || (data.isInvestor && investorWhitelistEnabled), "Flask_Trade_Manager: Only investors can claim paper energy.");
        
        maxPaperEnergy[msg.sender] = defaultPaperMaxEnergy;
        
        emit EnergyUpdate(msg.sender);
    }
    
    function setJuniorTrader(address addr) external onlyRole(DAO_ROLE){
        _setJuniorTrader(addr);
    }
    
    function setSeniorTrader(address addr) external onlyRole(DAO_ROLE){
        _setSeniorTrader(addr);
    }
    
    function demoteTrader(address addr) external onlyRole(DAO_ROLE){
        _demoteTrader(addr);
    }
    
    function getMaxEnergy(address addr) public view returns (uint256){
        return maxEnergy[addr];
    }
    
    function getMaxPaperEnergy(address addr) public view returns (uint256){
        return maxPaperEnergy[addr];
    }
    
    function getRemainingEnergy(address addr) public view returns (uint256){
        uint256 m = maxEnergy[addr];
        uint256 u = usedEnergy[addr];
        
        if (u >= m){
            return 0;
        }
        return m - u;
    }
    
    function getRemainingPaperEnergy(address addr) public view returns (uint256){
        uint256 m = maxPaperEnergy[addr];
        uint256 u = usedPaperEnergy[addr];
        
        if (u >= m){
            return 0;
        }
        return m - u;
    }
    
    function getEnergyValueBUSD() public view returns (Fraction memory){
        Fraction memory value;
        
        value.numerator = fund.getFundBUSD() * maxLeverage.numerator;
        
        if (maxEnergyTotalSupply == 0){
            value.denominator = 100 ether * maxLeverage.denominator;
        }else{
            value.denominator = maxEnergyTotalSupply * maxLeverage.denominator;
        }
        
        
        
        return value;
    }
    
    function getMinimumEnergyToTrade() public view returns (uint256){
        Fraction memory value = getEnergyValueBUSD();
        
        return 1 + (value.denominator * (minimumBUSDToTrade-1)) / value.numerator;
    }
    
    function addTradeDeployer(I_Flask_Trade_Deployer_Abstract deployer) external onlyRole(DAO_ROLE){
        require(deployer.hasRole(deployer.DAO_ROLE(), thisAddr), "Flask_Trade_Manager: Trade deployer have not set correct DAO address.");
        
        DeployerData memory data;
        data.deployer = deployer;
        data.enabled = true;
        
        deployer.setBUSDToken(BUSDToken);
        
        deployers.push(data);
    }
    
    function disableTradeDeployer(uint256 deployerId) external onlyRole(DAO_ROLE){
        require(deployerId < deployers.length, "Flask_Trade_Manager: Trade deployer not found.");
        
        deployers[deployerId].enabled = false;
    }
    
    function getNbTradeDeployers() external view returns (uint256){
        return deployers.length;
    }
    
    function getNbTrades() external view returns (uint256){
        return trades.length;
    }
    
    function getTrade(uint256 id) external view returns (TradeData memory){
        require(id < trades.length, "Flask_Trade_Manager: Trade id not found.");
        return trades[id];
    }
    
    function getNbOpenTrades() external view returns (uint256){
        return openTradeId.length;
    }
    
    function getNbOpenRealTrades() external view returns (uint256){
        return openRealTradeId.length;
    }
    
    function getMinOpenTradeId() external view returns (uint256, bool){
        uint256 l = openTradeId.length;
        if (l == 0){
            return (0, false);
        }
        
        uint256 minId = openTradeId[0];
        for(uint256 i=1; i<l; i++){
            if (openTradeId[i]<minId){
                minId = openTradeId[i];
            }
        }
       
        return (minId, true);
    }
    
    
    function getOpenTrade(uint openId) external view returns (TradeData memory, uint256){
        require(openId < openTradeId.length, "Flask_Trade_Manager: Open trade id not found.");
        uint256 id = openTradeId[openId];
        return (trades[id], id);
    }
    
    function getOpenRealTrade(uint openId) external view returns (TradeData memory, uint256){
        require(openId < openRealTradeId.length, "Flask_Trade_Manager: Open real trade id not found.");
        uint256 id = openRealTradeId[openId];
        return (trades[id], id);
    }
    
    function getTradeDeployer(uint256 id) external view returns (DeployerData memory){
        require(id < deployers.length, "Flask_Trade_Manager: Deployer id not found.");
        
        return deployers[id];
    }
    
    function startTrade(uint256 deployerId, uint256 nbEnergy) external onlyNotTerminated returns (uint256){
        require(deployerId < deployers.length, "Flask_Trade_Manager: Trade deployer not found.");
        
        DeployerData storage deployer = deployers[deployerId];
        
        bool isPaper = deployer.deployer.isPaper();
        
        require(!isPaper || autoPromotionEnabled, "Flask_Trade_Manager: Cannot start paper trade when auto-promotion system disabled.");
        
        require(deployer.enabled, "Flask_Trade_Manager: Trade deployer disabled.");
        
        if (isPaper){
            require(getMaxEnergy(msg.sender) == 0, "Flask_Trade_Manager: Real trader cannot start paper trades.");
            require(nbEnergy <= getRemainingPaperEnergy(msg.sender), "Flask_Trade_Manager: Not enough remaining energy.");
            require(nbEnergy >= 10, "Flask_Trade_Manager: Not enough energy to start a trade.");
            
            uint256 nbPWR = PWRToken.balanceOf(msg.sender) + stacking.stackedPWR(msg.sender);
            require(nbPWR >= minPWRToStartPaperTrade, "Flask_Trade_Manager: Not enough PWR to start paper trade.");
            
        }else{
            require(getMaxPaperEnergy(msg.sender) == 0, "Flask_Trade_Manager: Paper trader cannot start real trades.");
            require(nbEnergy <= getRemainingEnergy(msg.sender), "Flask_Trade_Manager: Not enough remaining energy.");
            require(nbEnergy >= getMinimumEnergyToTrade(), "Flask_Trade_Manager: Not enough energy to start a trade.");
            require(nbEnergy*7 >= getMaxEnergy(msg.sender), "Flask_Trade_Manager: Not enough energy to start a trade.");
        }
        
        
        
        uint256 totalBUSD = fund.getFundBUSD();
        Fraction memory energyValueBUSD = getEnergyValueBUSD();
        uint256 nbBUSD = (energyValueBUSD.numerator * nbEnergy) / energyValueBUSD.denominator;
        
        
        I_Flask_Trade_Abstract trade = deployer.deployer.deployNewTrade(msg.sender, thisAddr, address(fund), address(updater), address(withdrawer), address(competition));
        
        initBUSDBlanceInTrades += nbBUSD;
        
        trade.setTradeId(trades.length);
        trade.setMaxStopLoss(maxTradeStopLoss);
        trade.setMaxDuration(maxTradeDurationNbBlock);
        trade.setInitBUSDBalance(nbBUSD);
        
        
        if (!isPaper){
            address tradeAddr = address(trade);
            fund.grantRole(fund.TRADE_ROLE(), tradeAddr);
            withdrawer.grantRole(withdrawer.TRADE_ROLE(), tradeAddr);
            competition.grantRole(competition.TRADE_ROLE(), tradeAddr);
        }
        
        TradeData memory data;
        data.owner = msg.sender;
        data.trade = trade;
        data.energy = nbEnergy;
        data.isActive = true;
        data.blockStart = block.number;
        
        if (!isPaper){
            data.percentPWRLockedNumerator =  nbBUSD * 1e20 / totalBUSD;
        }
        
        data.isPaper = isPaper;
        data.maxEnergy = isPaper ? getMaxPaperEnergy(msg.sender) : getMaxEnergy(msg.sender);
        
        emit StartTrade(deployerId, trades.length, msg.sender);
        
        TradeIdToOpenId[trades.length] = openTradeId.length;
        openTradeId.push(trades.length);
        
        if (!isPaper){
            TradeIdToOpenRealId[trades.length] = openRealTradeId.length;
            openRealTradeId.push(trades.length);
        }
        
        trades.push(data);
        
        if (isPaper){
            usedPaperEnergy[msg.sender] += nbEnergy;
        }else{
            usedEnergy[msg.sender] += nbEnergy;
        }
        
        if (!isPaper){
            fund.sendBUSDToTrade(trade, nbBUSD);
        }
        
        emit EnergyUpdate(msg.sender);
        
        return trades.length - 1;
    }
    
    function forceEndTrade(uint256 tradeId) external onlyRole(DAO_ROLE){
        _endTrade(tradeId, true);
    }
    
    function endTrade(uint256 tradeId) public{
        _endTrade(tradeId, false);
    }
    
    ////
    ////
    ////
    //////////////// Private functions ////////////////
    function _updatePoints(TradeData storage data, Fraction memory profit) internal{
        if (autoPromotionEnabled){
            PointData storage pointData = nbPoints[data.owner];
            
            if (block.number > pointData.cycleEndBlock){
                pointData.nbPoints = 0;
                pointData.cycleEndBlock = block.number + nbBlockPerPointCycle;
            }
            
            if (profit.denominator > 0){
                if (profit.numerator > profit.denominator){
                    uint256 nbPoint = ((10000 ether) * data.energy * (profit.numerator - profit.denominator)) / (data.maxEnergy * profit.denominator);
                    if (pointData.isNegative){
                        if (pointData.nbPoints > nbPoint){
                            pointData.nbPoints -= nbPoint;
                        }else{
                            pointData.isNegative = false;
                            pointData.nbPoints = nbPoint - pointData.nbPoints;
                        }
                    }else{
                        pointData.nbPoints += nbPoint;
                    }
                }else{
                    uint256 nbNegativePoint = ((10000 ether) * data.energy * (profit.denominator - profit.numerator)) / (data.maxEnergy * profit.denominator);
                    if (pointData.isNegative){
                        pointData.nbPoints += nbNegativePoint;
                    }else{
                        if (pointData.nbPoints > nbNegativePoint){
                            pointData.nbPoints -= nbNegativePoint;
                        }else{
                            pointData.isNegative = true;
                            pointData.nbPoints = nbNegativePoint - pointData.nbPoints;
                        }
                    }
                }
            }
            
            uint256 level = traderLevel[data.owner];
            if (level == 0){
                if (!pointData.isNegative && pointData.nbPoints >= nbPointsToPromoteJuniorTrader){
                    pointData.nbPoints = 0;
                    pointData.cycleEndBlock = block.number + nbBlockPerPointCycle;
                    _setJuniorTrader(data.owner);
                }
            }else if (level == 1){
                if (pointData.isNegative && pointData.nbPoints >= nbNegativePointsToDemoteJuniorTrader){
                    pointData.nbPoints = 0;
                    pointData.cycleEndBlock = block.number + nbBlockPerPointCycle;
                    _demoteTrader(data.owner);
                }
                if (!pointData.isNegative && pointData.nbPoints >= nbPointsToPromoteSeniorTrader){
                    pointData.nbPoints = 0;
                    pointData.cycleEndBlock = block.number + nbBlockPerPointCycle;
                    _setSeniorTrader(data.owner);
                }
            }else if (level == 2){
                if (pointData.isNegative && pointData.nbPoints >= nbNegativePointsToDemoteSeniorTrader){
                    pointData.nbPoints = 0;
                    pointData.cycleEndBlock = block.number + nbBlockPerPointCycle;
                    _setJuniorTrader(data.owner);
                }
            }
        }
    }
    
    function _updateEnergyReward(TradeData storage data, Fraction memory profit) internal{
        if (!data.isPaper){
            uint256 baseEnergyBonus = (data.energy * baseEnergyBonusRatio.numerator) / (baseEnergyBonusRatio.denominator);
            
            if (profit.denominator > 0){
                if (profit.numerator > profit.denominator){
                    uint256 energyBonus = (baseEnergyBonus * (profit.numerator - profit.denominator)) / (profit.denominator);
                    maxEnergy[data.owner] += energyBonus;
                    maxEnergyTotalSupply += energyBonus;
                    
                }else{
                    uint256 energyMalus = (baseEnergyBonus * (profit.denominator - profit.numerator)) / (profit.denominator);
                    
                    if (energyMalus > maxEnergy[data.owner]){
                        energyMalus = maxEnergy[data.owner];
                    }
                    
                    maxEnergy[data.owner] -= energyMalus;
                    maxEnergyTotalSupply -= energyMalus;
                }
            }
        }
    }
    
    function _updateUsedEnergy(TradeData storage data) internal{
        if (data.isPaper){
            if (usedPaperEnergy[data.owner] < data.energy){
                usedPaperEnergy[data.owner] = 0;
            }else{
                usedPaperEnergy[data.owner] -= data.energy;
            }
        }else{
            if (usedEnergy[data.owner] < data.energy){
                usedEnergy[data.owner] = 0;
            }else{
                usedEnergy[data.owner] -= data.energy;
            }
        }
    }
    
    function _endTrade(uint256 tradeId, bool force) internal{
        require(tradeId < trades.length, "Flask_Trade_Manager: Trade not found.");
        
        TradeData storage data = trades[tradeId];
        
        require(force || (data.owner == msg.sender || msg.sender == address(updater)), "Flask_Trade_Manager: Only the owner or updater can end the trade.");
        
        require(data.isActive, "Flask_Trade_Manager: Trade already ended.");
        
        data.isActive = false;
        data.blockEnd = block.number;
        
        if (force){
            try data.trade.endTrade(){
            }catch{
                try data.trade.forceEndTrade(){
                }catch{
                
                }
            }
        }else{
            data.trade.endTrade();
        }
        
        uint256 initBalance = data.trade.getInitBUSDBalance();
        if (initBalance > initBUSDBlanceInTrades){
            initBUSDBlanceInTrades = 0;
        }else{
            initBUSDBlanceInTrades -= initBalance;
        }
        
        
        if ((traderLevel[data.owner] == 0 && data.isPaper) || (traderLevel[data.owner] > 0 && !data.isPaper)){
            Fraction memory profit = data.trade.getTradeProfit();
            _updateEnergyReward(data, profit);
            _updatePoints(data, profit);
        }
        
        _updateUsedEnergy(data);
        
        if (!data.isPaper){
            address tradeAddr = address(data.trade);
            fund.revokeRole(fund.TRADE_ROLE(), tradeAddr);
            withdrawer.revokeRole(withdrawer.TRADE_ROLE(), tradeAddr);
            competition.revokeRole(competition.TRADE_ROLE(), tradeAddr);
        }
        
        uint256 i = TradeIdToOpenId[tradeId];
        uint256 lastI = openTradeId.length - 1;
        if (lastI != i){
            uint256 lastTradeId = openTradeId[lastI];
            openTradeId[i] = lastTradeId;
            TradeIdToOpenId[lastTradeId] = i;
        }
        openTradeId.pop();
        
        if (!data.isPaper){
            i = TradeIdToOpenRealId[tradeId];
            lastI = openRealTradeId.length - 1;
            if (lastI != i){
                uint256 lastTradeId = openRealTradeId[lastI];
                openRealTradeId[i] = lastTradeId;
                TradeIdToOpenRealId[lastTradeId] = i;
            }
            openRealTradeId.pop();
        }
        
        emit EnergyUpdate(data.owner);
        emit EndTrade(tradeId);
        
        if (!data.isPaper){
            fund.updatePWRPrice();
        }
    }
    
    function _setJuniorTrader(address addr) internal{
        maxEnergyTotalSupply += juniorTraderDefaultMaxEnergy;
        maxEnergyTotalSupply -= maxEnergy[addr];
        maxEnergy[addr] = juniorTraderDefaultMaxEnergy;
        maxPaperEnergy[addr] = 0;
        traderLevel[addr] = 1;
        emit TraderLevelUpdated(addr);
        emit EnergyUpdate(addr);
    }
    
    function _setSeniorTrader(address addr) internal{
        maxEnergyTotalSupply += seniorTraderDefaultMaxEnergy;
        maxEnergyTotalSupply -= maxEnergy[addr];
        maxEnergy[addr] = seniorTraderDefaultMaxEnergy;
        maxPaperEnergy[addr] = 0;
        traderLevel[addr] = 2;
        emit TraderLevelUpdated(addr);
        emit EnergyUpdate(addr);
    }
    
    function _demoteTrader(address addr) internal{
        maxEnergyTotalSupply -= maxEnergy[addr];
        maxEnergy[addr] = 0;
        maxPaperEnergy[addr] = defaultPaperMaxEnergy;
        traderLevel[addr] = 0;
        emit TraderLevelUpdated(addr);
        emit EnergyUpdate(addr);
    }
}