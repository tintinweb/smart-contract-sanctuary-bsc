/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
// Version: 1.0.0
pragma solidity 0.8.10;

// Version: 1.0.0

abstract contract Base{
}
// Version: 1.0.0


// Version: 1.0.0

interface I_Math{
    struct Fraction{
        uint256 numerator;
        uint256 denominator;
    }
}

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

// Version: 1.0.0

interface I_With_DAORole{
    /**
     * DAO_ROLE is able to grant and revoke roles. It can be used when the DAO
     * vote to change some contracts of Flask.
     */
    function DAO_ROLE() external view returns (bytes32);
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
}
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
}// Version: 1.0.0



interface I_With_PWRToken is IAccessControl, I_With_DAORole{
    function setPWRToken(I_Flask_Power token) external;
}

abstract contract With_PWRToken is Base, AccessControl, With_DAORole, I_With_PWRToken{
    I_Flask_Power public PWRToken;

    function setPWRToken(I_Flask_Power token) external onlyRole(DAO_ROLE){
        PWRToken = token;
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

// Version: 1.0.0



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

// Version: 1.0.0




abstract contract With_TradeManagerRole is Base, AccessControl, With_DAORole, I_With_TradeManagerRole{
    bytes32 public constant TRADE_MANAGER_ROLE = keccak256("TRADE_MANAGER_ROLE");

    constructor(){
        _setRoleAdmin(TRADE_MANAGER_ROLE, DAO_ROLE);
    }
}


abstract contract With_TradeRole is Base, AccessControl, With_DAORole, With_TradeManagerRole, I_With_TradeRole{
    bytes32 public constant TRADE_ROLE = keccak256("TRADE_ROLE");

    constructor(){
        _setRoleAdmin(TRADE_ROLE, TRADE_MANAGER_ROLE);
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


interface I_Flask_Trade_Deployer_Abstract is I_Initializable, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_BUSDToken{
	function isPaper() external returns (bool);
	function name() external returns (string memory);
	
	function deployNewTrade(address owner, address manager, address fund, address updater, address withdrawer, address competition) external returns (I_Flask_Trade_Abstract);
	
	function checkProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external view returns (bool);
	
	function applyProposal(uint256 id, uint256 paramsUint256, address paramsAddress) external;
}// Version: 1.0.0

// Version: 1.0.0



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

}

interface I_With_StackingContract is IAccessControl, I_With_DAORole{
    function setStacking(I_Flask_Stacking _stacking) external;
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
}

abstract contract With_TradeManagerContract is Base, AccessControl, With_DAORole, I_With_TradeManagerContract{
    I_Flask_Trade_Manager public tradeManager;

    function setTradeManager(address _tradeManager) public onlyRole(DAO_ROLE){
        tradeManager = I_Flask_Trade_Manager(_tradeManager);
    }
}
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

contract Flask_Competition is Base, Math, Adressable, AccessControl, With_DAORole, With_TradeRole,
                              With_UpdaterRole, With_PWRToken, With_FundContract, With_TradeManagerContract, I_Flask_Competition{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    uint256 public currentCycle;
    
    Fraction public percentPWRRewardMint;
    
    mapping(uint256 => CycleData) public cycleData;
    
    mapping(address => mapping(uint256=>uint256)) public claimableCycles;
    mapping(address => uint256) public claimableCyclesLength;
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////

    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor(){
        currentCycle = 0;
        cycleData[0].startBlock = block.number;
        
        percentPWRRewardMint.numerator = 10;
        percentPWRRewardMint.denominator = 1000;
    }

    ////
    ////
    ////
    //////////////// Public functions ////////////////
    function setPercentPWRRewardMint(uint256 numerator, uint256 denominator) external onlyRole(DAO_ROLE){
        require(denominator>0, "Flask_Competition: Denominator cannot be null");
        percentPWRRewardMint.numerator = numerator;
        percentPWRRewardMint.denominator = denominator;
    }
    
    function getUserDetails(uint256 cycleId, address addr) external view returns(UserDetails memory){
        require(cycleId <= currentCycle, "Flask_Competition: Cycle not found");
        
        return cycleData[cycleId].user[addr];
    }
    
    function getProfitUsers(uint256 cycleId) external view returns(address[] memory){
        require(cycleId <= currentCycle, "Flask_Competition: Cycle not found");
        
        return cycleData[cycleId].users;
    }
    
    function getProfitUsersLength(uint256 cycleId) external view returns(uint256){
        require(cycleId <= currentCycle, "Flask_Competition: Cycle not found");
        
        return cycleData[cycleId].users.length;
    }
    
    function getOneProfitUser(uint256 cycleId, uint256 userId) external view returns(address){
        require(cycleId <= currentCycle, "Flask_Competition: Cycle not found");
        
        CycleData storage cycle = cycleData[cycleId];
        
        require(userId < cycle.users.length, "Flask_Competition: User not found");
        
        return cycle.users[userId];
    }
    
    function updateCycle(uint256 cycleId) external onlyRole(UPDATER_ROLE){
        currentCycle = cycleId;
        
        uint256 totalPWR = fund.getTotalPWR();
        
        
        CycleData storage data = cycleData[cycleId];
        data.completed = true;
        data.endBlock = block.number;
        
        cycleData[cycleId+1].startBlock = block.number;
        
        if (data.totalProfitNumerator > 0){
            uint256 nbPWRToMint = (totalPWR * percentPWRRewardMint.numerator) / percentPWRRewardMint.denominator;
            data.totalPWRMinted = nbPWRToMint;
            PWRToken.mintTo(thisAddr, nbPWRToMint);
        }
        
        fund.updatePWRPrice();
        
        currentCycle += 1;
        
        emit CompetitionEnded();
    }
    
    function getClaimableReward(address addr) public view returns (uint256){
        mapping(uint256=>uint256) storage c = claimableCycles[addr];
        
        uint256 totalReward = 0;
        uint256 l = claimableCyclesLength[addr];
        
        for(uint256 i=0; i<l; i++){
            totalReward += _getOneClaimableReward(addr, c[i]);
        }
        
        return totalReward;
    }
    
    function claimReward() external{
        uint256 claimAmount = getClaimableReward(msg.sender);
        
        require(claimAmount>0, "Flask_Competition: No reward to claim.");
        
        mapping(uint256=>uint256) storage c = claimableCycles[msg.sender];
        uint256 l = claimableCyclesLength[msg.sender];
        
        for(uint256 i=0; i<l; i++){
            CycleData storage data = cycleData[c[i]];
            if (data.completed){
                data.user[msg.sender].rewardClaimed = true;
            }
        }
        
        UserDetails storage user = cycleData[currentCycle].user[msg.sender];
        if (user.isProfit){
            claimableCycles[msg.sender][0] = currentCycle;
            claimableCyclesLength[msg.sender] = 1;
        }else{
            claimableCyclesLength[msg.sender] = 0;
        }
        
        emit CompetitionRewardClaimed(msg.sender);
        
        PWRToken.transferFromTo(thisAddr, msg.sender, claimAmount);
    }
    
    
    function updateEndTrade(Fraction memory tradeProfit, uint256 tradeId) external onlyRole(TRADE_ROLE){
        
        I_Flask_Trade_Manager.TradeData memory tradeData = tradeManager.getTrade(tradeId);
        
        uint256 maxEnergy = tradeManager.getMaxEnergy(tradeData.owner);
        uint256 usedEnergy = tradeData.energy;
        
        if (usedEnergy > maxEnergy){
            maxEnergy = usedEnergy;
        }
        
        CycleData storage data = cycleData[currentCycle];
        UserDetails storage user = data.user[tradeData.owner];
        
        if (tradeProfit.numerator > tradeProfit.denominator){
            uint256 profit = ((tradeProfit.numerator - tradeProfit.denominator) * usedEnergy * 1e10) / (tradeProfit.denominator * maxEnergy);
            
            if (user.isProfit){
                data.totalProfitNumerator += profit;
                user.pnl += profit;
            }else{
                if (user.pnl > profit){
                    user.pnl -= profit;
                }else{
                    user.pnl = profit - user.pnl;
                    data.totalProfitNumerator += user.pnl;
                    user.isProfit = true;
                }
            }
        }else{
            uint256 loss = ((tradeProfit.denominator - tradeProfit.numerator) * usedEnergy * 1e10) / (tradeProfit.denominator * maxEnergy);

            if (!user.isProfit){
                user.pnl += loss;
            }else{
                if (user.pnl > loss){
                    data.totalProfitNumerator -= loss;
                    user.pnl -= loss;
                }else{
                    data.totalProfitNumerator -= user.pnl;
                    user.pnl = loss - user.pnl;
                    user.isProfit = false;
                }
            }
        }
        
        mapping(uint256=>uint256) storage cycles = claimableCycles[tradeData.owner];
        uint256 l = claimableCyclesLength[tradeData.owner];
        if (user.isProfit){
            if (l == 0 || cycles[l-1] != currentCycle){
                cycles[l] = currentCycle;
                claimableCyclesLength[tradeData.owner] = l+1;
            }
            if (data.usersId[tradeData.owner] == 0){
                data.users.push(tradeData.owner);
                data.usersId[tradeData.owner] = data.users.length;
            }
        }else{
            if (l>0 && cycles[l-1] == currentCycle){
                claimableCyclesLength[tradeData.owner] = l-1;
            }
            if (data.usersId[tradeData.owner] != 0){
                uint256 id0 = data.usersId[tradeData.owner] - 1;
                uint256 id1 = data.users.length - 1;
                
                if (id0 != id1){
                    data.users[id0] = data.users[id1];
                    data.usersId[data.users[id0]] = id0;
                }
                
                data.users.pop();
                data.usersId[tradeData.owner] = 0;
            }
        }
        
    }

    ////
    ////
    ////
    //////////////// Private functions ////////////////
    function _getOneClaimableReward(address addr, uint256 cycleId) internal view returns (uint256){
        CycleData storage data = cycleData[cycleId];
        UserDetails storage user = data.user[addr];
        
        if (!user.rewardClaimed && user.isProfit && data.completed){
            return data.totalPWRMinted * user.pnl / data.totalProfitNumerator;
        }
        
        return 0;
    }
    

}