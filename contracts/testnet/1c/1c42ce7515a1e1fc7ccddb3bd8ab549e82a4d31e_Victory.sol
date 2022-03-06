/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

// File: @openzeppelin/contracts/access/Ownable.sol

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.6;


/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/
// 
interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// File: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

// File: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// File: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/victory.sol



pragma solidity ^0.8.6;







contract Victory is IERC20, Ownable , AccessControl ,Pausable{

    using SafeMath for uint256;
    
    bytes32 public constant LP_FEE_CONTROL_ROLE = keccak256("LP_BALLOT_FEE_CONTROL");

    mapping(address => uint256) private _vOwned;

    mapping(address => uint256) private _lockedLp; 

    mapping(address => uint) public cooldownTimer;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isSniper;
    
    mapping(address => bool) private _isExcludedFromFee;

    address public _marketAddr;

    address public _acrossChainPoolAddr;

    string private _name;
    
    string private _symbol;

    uint8 private _decimals = 18;
    
    uint256 public _repoFee = 100;  

    uint256 public _burnFee = 200;

    uint256 public _lpBallotFee = 300;

    uint256 public _crossChainPoolFee = 200;

    uint256 public _nodeFee = 100;

    uint256 public _inviterFee = 300;

    uint256 public _cancelTime = 432000;

    uint256 public _inviterAmount;  

    uint256 public _lpFeeRewardTotal = 0;
      
    uint256 private _vTotal =10 * 10**8 * 10**18;

    uint256 public _launchedAt = 0;

    uint256 public _nodeLimit;

    bool public _hasLiqBeenAdded = false;

    bool public _hasFreedBeenGet = false;
  
    IUniswapV2Router02 public immutable uniswapV2Router;

    address public uniswapV2Pair;
    
    mapping(address => address) public inviter;

    mapping(address => mapping(address => bool)) public inviterList;

    mapping(address => bool) public isBabyNode;

    mapping(address => bool) public isSuperNode;

    mapping(address => bool) public isBallot;

    mapping(address => address) public setBallotAddr;

    struct Share {
        uint256 amount;
        uint256 totalRealised;
    }

    struct Locked {
        uint256 lockUpAmount;
        uint256 freedAmount;
    }

    mapping (address => Share) public shares;

    mapping (address => Locked) public locked;

    event SetBallot(address bidder , address node , uint256 amount);

    event CancelBallot(address bidder , address node);

    event SetInviter(address bidder , address inviter);

    event SetSuperNode(address account);

    event SetBabyNode(address account);

    event AddLpFeeReward(uint256 amount);

    event RemoveLpFeeReward(uint256 amount);

    modifier blackList() {
        require(!_isSniper[msg.sender]); 
        _;
    }

    constructor(
        string memory symbol_,
        string memory name_,
        uint256 inviteramount_,
        uint256 nodelimit_,
        address router_,
        address market_,
        address chainpool_
    ) {
        _name = name_;
        _symbol = symbol_;
        _vOwned[msg.sender] = _vTotal;
        _marketAddr = market_;
        _acrossChainPoolAddr = chainpool_;
        _inviterAmount = inviteramount_;
        _nodeLimit = nodelimit_;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketAddr] = true;
        _isExcludedFromFee[_acrossChainPoolAddr] = true;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(LP_FEE_CONTROL_ROLE, msg.sender);
      
        emit Transfer(address(0), msg.sender, _vTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _vTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _vOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function updateMarketConfig(uint256 inviteramount_,
        address market_,
        address chainpool_) external onlyOwner {
        _inviterAmount = inviteramount_;
        _marketAddr = market_;
        _acrossChainPoolAddr = chainpool_;      
    }

    function updatePair(address pair_) external onlyOwner {
        uniswapV2Pair = pair_;
    }

    function updateNodeLimit (uint256 nodelimit_) external onlyOwner {
        _nodeLimit = nodelimit_;
    }

    function updateCancelTime (uint256 canceltime_) external onlyOwner {
        _cancelTime = canceltime_;
    }

    function updateFreedGet () external onlyOwner {
        _hasFreedBeenGet = true;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    function addSniper(address account) external onlyOwner {
        _isSniper[account] = true;
    }

    function removeSniper(address account) external onlyOwner {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function addSuperNode(address[] memory account) external onlyOwner {
        require(account.length > 0, "address length error");
        for(uint256 i = 0; i < account.length; i++) {
            require((!isBallot[account[i]] && setBallotAddr[account[i]] == address(0)) || setBallotAddr[account[i]] == account[i] , "Account is not allowed");
            isSuperNode[account[i]] = true;
            isBabyNode[account[i]] = false;
            emit SetSuperNode(account[i]);
        }
    }

    function addBabyNode(address[] memory account) external onlyOwner {
        require(account.length > 0, "address length error");
        for(uint256 i = 0; i < account.length; i++) {
            require((!isBallot[account[i]] && setBallotAddr[account[i]] == address(0)) || setBallotAddr[account[i]] == account[i] , "Account is not allowed");
            isBabyNode[account[i]] = true;
            isSuperNode[account[i]] = false;
            emit SetBabyNode(account[i]);
        }
    }

    function addPrivateLock(address[] memory _tos, uint256[] memory _values) external onlyOwner {
        require(_tos.length > 0, "address length error");
        require(_tos.length == _values.length, "values length error");
        for(uint256 i = 0; i < _tos.length; i++) {
            locked[_tos[i]].lockUpAmount = locked[_tos[i]].lockUpAmount.add(_values[i]);
            _basicTransfer(msg.sender ,address(this) ,_values[i]);
        }
    }

    function applyBabyNode() external {
        require(!isBallot[msg.sender] && setBallotAddr[msg.sender] == address(0), "Account is not allowed");
        require(!isBabyNode[msg.sender] || !isSuperNode[msg.sender], "Account is a node");
        require(_vOwned[msg.sender] >= _nodeLimit, "Account is not allowed");
        isBabyNode[msg.sender] = true;
        emit SetBabyNode(msg.sender);
    }
 
    function getLockedLp(address account) public view  returns (uint256) {
        return _lockedLp[account];
    }

    function addInviter(address account) external blackList {
        require(inviterList[msg.sender][account] && account != address(0) && inviter[msg.sender] == address(0) && account != msg.sender , "Account is not allowed");
        inviter[msg.sender] = account;
        emit SetInviter(msg.sender, account);
    }

    function setBallot(address node, uint256 amount) external blackList whenNotPaused {
        require(node != address(0), "Account is not a node");
        require(isBabyNode[node] || isSuperNode[node], "Account is not a node");
        require(!isBallot[msg.sender] || setBallotAddr[msg.sender] == node , "Ballot rejected");
        require(amount > 0, "Ballot amount must be greater than zero");
        IERC20(uniswapV2Pair).transferFrom(msg.sender, address(this), amount);
        _lockedLp[msg.sender] = _lockedLp[msg.sender].add(amount);
        isBallot[msg.sender] = true;
        cooldownTimer[msg.sender] = block.timestamp + _cancelTime;//lock 5 days
        setBallotAddr[msg.sender] = node;
        emit SetBallot(msg.sender, node, amount);
    }

    function cancelBallot() external blackList whenNotPaused {
        require(isBallot[msg.sender] && setBallotAddr[msg.sender] != address(0) , "Cancel rejected");
        require(block.timestamp > cooldownTimer[msg.sender] , "Ballot is locked");
        uint256 amount = _lockedLp[msg.sender];
        _lockedLp[msg.sender] = _lockedLp[msg.sender].sub(amount);
        IERC20(uniswapV2Pair).transfer(msg.sender, amount);
        address node = setBallotAddr[msg.sender];
        setBallotAddr[msg.sender] = address(0);
        isBallot[msg.sender] = false;
        emit CancelBallot(msg.sender, node);
    }

    function getShare(address[] memory _tos, uint256[] memory _values, uint256 total) external onlyRole(LP_FEE_CONTROL_ROLE) whenNotPaused {
        require(_tos.length > 0, "address length error");
        require(_tos.length == _values.length, "values length error");
        require(total <= _lpFeeRewardTotal, "get share error");
        uint256 count;
        for(uint256 i = 0; i < _tos.length; i++) {
            shares[_tos[i]].amount = shares[_tos[i]].amount.add(_values[i]);
            _addFreedAmount(_tos[i], _values[i]); 
            count = count.add(_values[i]);
        }
        if(count != total){
            revert("count error");
        }
        _lpFeeRewardTotal = _lpFeeRewardTotal.sub(total);
        emit RemoveLpFeeReward(total);
    }

    function takeShare() external blackList whenNotPaused {
        require(shares[msg.sender].amount > 0, "take share error");
        uint256 amount = shares[msg.sender].amount;
        _vOwned[msg.sender] = _vOwned[msg.sender].add(amount);
        shares[msg.sender].totalRealised = shares[msg.sender].totalRealised.add(amount);
        shares[msg.sender].amount = 0;
        emit Transfer(address(this), msg.sender, amount);
    }

    function takeFreed() external blackList whenNotPaused {
        require(locked[msg.sender].freedAmount > 0, "take freed error");
        require(_hasFreedBeenGet, "take freed error");
        uint256 amount = locked[msg.sender].freedAmount;
        locked[msg.sender].freedAmount = 0;
        _basicTransfer(address(this), msg.sender, amount);
    }

    function _checkLiquidityAdd(address from, address to) private {
        // if liquidity is added by the _liquidityholders set trading enables to true and start the anti sniper timer
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");

        if (_isExcludedFromFee[from] && to == uniswapV2Pair) {
            _hasLiqBeenAdded = true;
            _launchedAt = block.number;
        }
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private whenNotPaused {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (isSniper(from)) {
            revert("Sniper rejected.");
        }

        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
        } else {
            if (
                _launchedAt > 0 &&
                from == uniswapV2Pair &&
                !_isExcludedFromFee[from] &&
                !_isExcludedFromFee[to]
            ) {
                if (block.number - _launchedAt < 3) {
                    _isSniper[to] = true;
                }
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || to == uniswapV2Pair || from == address(uniswapV2Router)) {
            takeFee = false;
        }

        bool shouldSetInviter = inviter[to] == address(0) &&
            from != uniswapV2Pair && amount >= _inviterAmount ;

        _transferStandard(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviterList[to][from] = true;
        }

    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        uint256 senderBalance = _vOwned[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
            
        _vOwned[sender] = senderBalance.sub(amount);
        
        _vOwned[recipient] = _vOwned[recipient].add(amount);

        if(recipient == address(0)){
            _vTotal = _vTotal.sub(amount);
        }

        emit Transfer(sender, recipient, amount);

    }

    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        _basicTransfer(sender, address(0), tAmount);
    }

    function _takeRepoFee(
        address sender,
        uint256 tAmount
    ) private {
        _basicTransfer(sender, _marketAddr, tAmount);
    }

    function _takeAcrossChainFee(
        address sender,
        uint256 tAmount
    ) private {
        _basicTransfer(sender, _acrossChainPoolAddr, tAmount);
    }

    function _takeLpFee(address sender, address recipient, uint256 tAmount) private {
        address cur = sender;

        if (sender == uniswapV2Pair) {
            cur = recipient;
        } 

        if( !isBallot[cur] || setBallotAddr[cur] == address(0) ) {
            _basicTransfer(sender, address(0), tAmount);
            return;
        }
        _lpFeeRewardTotal = _lpFeeRewardTotal.add(tAmount);
        emit AddLpFeeReward(tAmount);

    }

    function _addFreedAmount(address account, uint256 amount) private {
        if(locked[account].lockUpAmount == 0){
            return;
        }
        uint256 addFreedAmount = locked[account].lockUpAmount;
        if(locked[account].lockUpAmount <= amount){
            locked[account].freedAmount = locked[account].freedAmount.add(addFreedAmount);
            locked[account].lockUpAmount = 0;
        }else{
            locked[account].freedAmount = locked[account].freedAmount.add(amount);
            locked[account].lockUpAmount = locked[account].lockUpAmount.sub(amount);
        }
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        address cur = sender;

        if (sender == uniswapV2Pair) {
            cur = recipient;
        } 
       
        if(inviter[cur] == address(0)){
            _basicTransfer(sender, address(0), tAmount.div(10000).mul(_inviterFee.add(_nodeFee)));
            return;
        }  

        bool isSendNode = false;

        uint256 rate;

        uint256 accurRate;

        for (int256 i = 0; i < 6; i++) {
            if (i == 0) {
                rate = 100;
            } else if(i == 1){
                rate = 60;
            } else if (i == 2) {
                rate = 50;
            }else if (i == 3) {
                rate = 40;
            }else if (i == 4) {
                rate = 30;
            }else if (i == 5) {
                rate = 20;
            }

            cur = inviter[cur];
            
            if (!isSendNode) {

               if(isBabyNode[cur]){

                _basicTransfer(sender, cur, tAmount.div(10000).mul(_nodeFee.div(2)));

                _basicTransfer(sender, address(0), tAmount.div(10000).mul(_nodeFee.div(2)));

                _addFreedAmount(cur, tAmount.div(10000).mul(_nodeFee.div(2)));   
        
                isSendNode = true;

               } else if(isSuperNode[cur]){
                
                _basicTransfer(sender, cur, tAmount.div(10000).mul(_nodeFee));

                _addFreedAmount(cur, tAmount.div(10000).mul(_nodeFee)); 

                isSendNode = true;

               }

            }

            if (cur == address(0)) {
                if(!isSendNode){

                _basicTransfer(sender, address(0), tAmount.div(10000).mul(_nodeFee));

                }
                break;
            }
            
            accurRate = accurRate.add(rate);

            uint256 curTAmount = tAmount.div(10000).mul(rate);

            _basicTransfer(sender, cur, curTAmount);

            _addFreedAmount(cur, curTAmount); 

        }

        if (accurRate < _inviterFee){
            _basicTransfer(sender, address(0), tAmount.div(10000).mul(_inviterFee.sub(accurRate)));
        }

    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        uint256 recipientRate = 10000;
    
        if (takeFee){

        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));

        _takeLpFee(sender, recipient, tAmount.div(10000).mul(_lpBallotFee));

        _takeRepoFee(sender, tAmount.div(10000).mul(_repoFee));

        _takeAcrossChainFee(sender, tAmount.div(10000).mul(_crossChainPoolFee));
    
        _takeInviterFee(sender, recipient, tAmount);

         recipientRate = recipientRate -
            _burnFee -
            _lpBallotFee -
            _repoFee -
            _crossChainPoolFee -
            _inviterFee -
            _nodeFee;
        }

        _basicTransfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
     
    }
}