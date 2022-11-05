/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT
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


// File contracts/common/zeppelin/utils/Context.sol

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


// File contracts/common/zeppelin/utils/Strings.sol

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


// File contracts/common/zeppelin/utils/introspection/IERC165.sol

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


// File contracts/common/zeppelin/utils/introspection/ERC165.sol

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


// File contracts/common/zeppelin/access/AccessControl.sol

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


// File contracts/common/token/BlackWhiteRestraint.sol

pragma solidity ~0.8.6;

abstract contract BlackWhiteRestraint is AccessControl {
    bytes32 public constant ROLE_LIST = keccak256("ROLE_LIST");

    mapping(address => bool) internal fromBlacks;
    mapping(address => bool) internal fromWhites;
    mapping(address => bool) internal toBlacks;
    mapping(address => bool) internal toWhites;

    constructor() {
        _setupRole(ROLE_LIST, msg.sender);
        _setRoleAdmin(ROLE_LIST, keccak256("ROLE_ADMIN"));
    }

    function blackWhitesFilter(address from_, address to_) internal view {
        require(
            !fromBlacks[from_] || toWhites[to_],
            "Transfer: transfer deny by sender"
        );
        require(
            !toBlacks[to_] || fromWhites[from_],
            "Transfer: transfer deny by recipient"
        );
    }
    
    function setFromBlacks(address account_, bool state_) external onlyRole(ROLE_LIST) {
        fromBlacks[account_] = state_;
    }

    function setFromWhites(address account_, bool state_) external onlyRole(ROLE_LIST) {
        fromWhites[account_] = state_;
    }

    function setToBlacks(address account_, bool state_) external onlyRole(ROLE_LIST) {
        toBlacks[account_] = state_;
    }

    function setToWhites(address account_, bool state_) external onlyRole(ROLE_LIST) {
        toWhites[account_] = state_;
    }

    function isInFromBlacks(address account_) external view returns (bool) {
        return fromBlacks[account_];
    }

    function isInFromWhites(address account_) external view returns (bool) {
        return fromWhites[account_];
    }

    function isInToBlacks(address account_) external view returns (bool) {
        return toBlacks[account_];
    }

    function isInToWhites(address account_) external view returns (bool) {
        return toWhites[account_];
    }
}


// File contracts/common/zeppelin/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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


// File contracts/common/token/TransferAmountRestraint.sol

pragma solidity ~0.8.6;


abstract contract TransferAmountRestraint is AccessControl {
    uint256 public constant PRECISION = 1000;
    bytes32 public constant ROLE_AMOUNT = keccak256("ROLE_AMOUNT");

    mapping(address => bool) internal amountLimitExcludes;
    uint256 internal maxTransferRatio = 999;
    uint256 internal minTransferAmount = 0;

    constructor() {
        _setupRole(ROLE_AMOUNT, msg.sender);
        _setRoleAdmin(ROLE_AMOUNT, keccak256("ROLE_ADMIN"));
    }

    function transferAmountFilter(address from_, address to_, uint256 amount_) internal view {
        if (amountLimitExcludes[from_] || amountLimitExcludes[to_]) {
            return;
        }

        require(
            amount_ >= minTransferAmount,
            "Transfer: tranfer amount can not smaller than min limit"
        );
        
        uint256 limit_ = (IERC20(address(this)).balanceOf(from_) * maxTransferRatio) / PRECISION;
        require(
            amount_ <= limit_, 
            "Transfer: max transfer limit"
        );
    }

    function addAmountLimitExcludes(address account_, bool state_) external onlyRole(ROLE_AMOUNT) {
        amountLimitExcludes[account_] = state_;
    }

    function setMaxTransferRatio(uint256 ratio_) external onlyRole(ROLE_AMOUNT) {
        maxTransferRatio = ratio_;
    }

    function setMinTransferAmount(uint256 amount_) external onlyRole(ROLE_AMOUNT) {
        minTransferAmount = amount_;
    }

    function isInAmountLimitExcludes(address account_) external view returns (bool) {
        return amountLimitExcludes[account_];
    }

    function getMaxTransferRatio() external view returns (uint256) {
        return maxTransferRatio;
    }

    function getMinTransferAmount() external view returns (uint256) {
        return minTransferAmount;
    }
}


// File contracts/common/uniswap/IUniswapV2Pair.sol

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// File contracts/common/uniswap/IUniswapV2Factory.sol

pragma solidity ^0.8.0;

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


// File contracts/common/uniswap/IUniswapV2Router01.sol

pragma solidity ^0.8.0;

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


// File contracts/common/uniswap/IUniswapV2Router02.sol

pragma solidity ^0.8.0;

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


// File contracts/common/token/TradeRestraint.sol

pragma solidity ~0.8.6;



// NONE 都允许
// ALLOW_ALL 都禁止
// DENY_ALL 都允许
// DENY_BUY 允许卖出
// DENY_SELL 允许买入
enum TradeLimitMode {
    NONE, 
    ALLOW_ALL, 
    DENY_ALL, 
    DENY_BUY, 
    DENY_SELL 
}

abstract contract TradeRestraint is BlackWhiteRestraint {
    bytes32 public constant ROLE_TRADE = keccak256("ROLE_TRADE");
    mapping(address => bool) internal dexPairs;
    mapping(address => bool) internal feeWhites;

    constructor() BlackWhiteRestraint() {
        _setupRole(ROLE_TRADE, msg.sender);
        _setRoleAdmin(ROLE_TRADE, keccak256("ROLE_ADMIN"));
    }

    function slippage(address from_, address to_, uint256 amount_) internal returns (uint256 used_) {
        if (isInFeeWhites(from_) || isInFeeWhites(to_)) {
            return 0;
        }

        if (dexPairs[from_]) {
            return doBuySlippage(to_, from_, amount_);
        }

        if (dexPairs[to_]) {
            return doSellSlippage(from_, to_, amount_);
        }

        return doTransferSlippage(from_, to_, amount_);
    }

    function doBuySlippage(address account_, address dex_, uint256 amount_) internal virtual returns (uint256);

    function doSellSlippage(address account_, address dex_, uint256 amount_) internal virtual returns (uint256);

    function doTransferSlippage(address from_, address to_, uint256 amount_) internal virtual returns (uint256);

    function addTradePair(
        address token0_, 
        address token1_, 
        address router_, 
        TradeLimitMode mode_
    ) public onlyRole(ROLE_TRADE) {
        address factory_ = IUniswapV2Router02(router_).factory();
        address pair_ = address(0);

        if (IUniswapV2Factory(factory_).getPair(token0_, token1_) == address(0)) {
            pair_ = IUniswapV2Factory(factory_).createPair(token0_, token1_);
        } else {
            pair_ = IUniswapV2Factory(factory_).getPair(token0_, token1_);
        }

        require(pair_ != address(0), "Trade: pair zero");
        
        dexPairs[pair_] = true;

        if (mode_ == TradeLimitMode.ALLOW_ALL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_ALL) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = true;
        } else if (mode_ == TradeLimitMode.DENY_BUY) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_SELL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = true;
        } else {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        }
    }

    function setTradePairMode(
        address token0_, 
        address token1_, 
        address router_, 
        TradeLimitMode mode_
    ) public onlyRole(ROLE_TRADE) {
        address factory_ = IUniswapV2Router02(router_).factory();
        address pair_ = IUniswapV2Factory(factory_).getPair(token0_, token1_);

        require(pair_ != address(0), "Trade: pair zero");
        
        if (mode_ == TradeLimitMode.ALLOW_ALL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_ALL) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = true;
        } else if (mode_ == TradeLimitMode.DENY_BUY) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_SELL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = true;
        } else {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        }
    }

    function setTradePairMode(
        address pair_,
        TradeLimitMode mode_
    ) public onlyRole(ROLE_TRADE) {
        require(pair_ != address(0), "Trade: pair zero");
        
        if (mode_ == TradeLimitMode.ALLOW_ALL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_ALL) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = true;
        } else if (mode_ == TradeLimitMode.DENY_BUY) {
            fromBlacks[pair_] = true;
            toBlacks[pair_] = false;
        } else if (mode_ == TradeLimitMode.DENY_SELL) {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = true;
        } else {
            fromBlacks[pair_] = false;
            toBlacks[pair_] = false;
        }
    }

    function setFeeWhites(address account_, bool state_) public onlyRole(ROLE_TRADE) {
        feeWhites[account_] = state_;
    }

    function batchSetFeeWhites(address[] calldata accounts_, bool[] memory states_) public onlyRole(ROLE_TRADE) {
        require(accounts_.length == states_.length, "Trade: length not same");
        
        for (uint256 i = 0; i < accounts_.length; i++) {
            feeWhites[accounts_[i]] = states_[i];
        }
    }

    function isInFeeWhites(address account_) public view returns (bool) {
        return feeWhites[account_];
    }

    function isDexPair(address pair_) public view returns (bool) {
        return dexPairs[pair_];
    }
}


// File contracts/common/zeppelin/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File contracts/common/zeppelin/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/nlt/token.sol

pragma solidity ^0.8.0;




struct Receiver {
    address receiver;
    uint ratio;
}

contract NewLandToken is ERC20, AccessControl, BlackWhiteRestraint, TradeRestraint, TransferAmountRestraint {
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 public constant ROLE_TOKEN = keccak256("ROLE_TOKEN");
    bytes32 public constant ROLE_ROBOT = keccak256("ROLE_ROBOT");

    uint private _tradeSlippageRatioNormal = 200;
    uint private _tradeSlippageRatioRelief = 50;
    uint private _transferSlippageRatio = 0;
    mapping(address => bool) private _slippageReliefList;

    Receiver[] private _normalSlippageReceivers;
    Receiver[] private _reliefSlippageReceivers;
    Receiver[] private _transferSlippageReceivers;

    constructor(address admin_, address robot_) ERC20("New Land Token", "NLT") {
        _setupRole(ROLE_ADMIN, admin_);

        _setupRole(ROLE_TOKEN, admin_);
        _setupRole(ROLE_TOKEN, msg.sender);

        _setupRole(ROLE_ROBOT, admin_);
        _setupRole(ROLE_ROBOT, robot_);
        _setupRole(ROLE_ROBOT, msg.sender);

        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);
        _setRoleAdmin(ROLE_TOKEN, ROLE_ADMIN);
        _setRoleAdmin(ROLE_ROBOT, ROLE_ADMIN);

        _mint(msg.sender, 100_000_000 * (10**decimals()));
    }

    function _transfer(address from_, address to_, uint256 amount_) override internal {
        require(from_ != address(0),  "Transfer: from_ is zero");
        require(to_ != address(0), "Transfer: to_ is zero");

        blackWhitesFilter(from_, to_);

        transferAmountFilter(from_, to_, amount_);

        uint256 amountUsed_ = slippage(from_, to_, amount_);

        super._transfer(from_, to_, (amount_ - amountUsed_));
    }

    function doBuySlippage(address account_, address dex_, uint256 amount_) override internal returns (uint256) {
        if (_slippageReliefList[account_]) {
            if (_tradeSlippageRatioRelief <= 0) {
                return 0;
            }
            uint256 slippageAmount_ = amount_ * _tradeSlippageRatioRelief / PRECISION;
            if (slippageAmount_ <= 0) {
                return 0;
            }
            return _transferToReceivers(dex_, slippageAmount_, _reliefSlippageReceivers);
        } else {
            if (_tradeSlippageRatioNormal <= 0) {
                return 0;
            }
            uint256 slippageAmount_ = amount_ * _tradeSlippageRatioNormal / PRECISION;
            if (slippageAmount_ <= 0) {
                return 0;
            }
            return _transferToReceivers(dex_, slippageAmount_, _normalSlippageReceivers);
        }
    }

    function doSellSlippage(address account_, address, uint256 amount_) override internal returns (uint256) {
        if (_slippageReliefList[account_]) {
            if (_tradeSlippageRatioRelief <= 0) {
                return 0;
            }
            uint256 slippageAmount_ = amount_ * _tradeSlippageRatioRelief / PRECISION;
            if (slippageAmount_ <= 0) {
                return 0;
            }
            return _transferToReceivers(account_, slippageAmount_, _reliefSlippageReceivers);
        } else {
            if (_tradeSlippageRatioNormal <= 0) {
                return 0;
            }
            uint256 slippageAmount_ = amount_ * _tradeSlippageRatioNormal / PRECISION;
            if (slippageAmount_ <= 0) {
                return 0;
            }
            return _transferToReceivers(account_, slippageAmount_, _normalSlippageReceivers);
        }
    }

    function doTransferSlippage(address from_, address, uint256 amount_) override internal returns (uint256) {
        if (_transferSlippageRatio == 0) {
            return 0;
        }
        uint256 slippage_ = amount_ * _transferSlippageRatio / PRECISION;
        if (slippage_ <= 0) {
            return 0;
        }
        return _transferToReceivers(from_, slippage_, _transferSlippageReceivers);
    }

    function _transferToReceivers(address from_, uint256 amount_, Receiver[] memory receivers_) private returns (uint256) {
        if (from_ == address(0)) {
            return 0;
        }

        if (amount_ <= 0) {
            return 0;
        }

        uint256 used_ = 0;

        for (uint i = 0; i < receivers_.length; i ++) {
            Receiver memory receiver_ = receivers_[i];

            address receiverAddress_ = receiver_.receiver;
            if (receiverAddress_ == address(0)) {
                continue;
            }

            if (receiver_.ratio <= 0) {
                continue;
            }
            uint256 receiverAmount_ = amount_ * receiver_.ratio / PRECISION;
            if (receiverAmount_ <= 0) {
                continue;
            }
            
            super._transfer(from_, receiverAddress_, receiverAmount_);
            used_ = used_ + receiverAmount_;
        }

        return used_;
    }

    function setTradeSlippageRatioNormal(uint ratio_) public onlyRole(ROLE_TOKEN) {
        _tradeSlippageRatioNormal = ratio_;
    }

    function getTradeSlippageRatioNormal() public view returns (uint) {
        return _tradeSlippageRatioNormal;
    }

    function setTradeSlippageRatioRelief(uint ratio_) public onlyRole(ROLE_TOKEN) {
        _tradeSlippageRatioRelief = ratio_;
    }

    function getTradeSlippageRatioRelief() public view returns (uint) {
        return _tradeSlippageRatioRelief;
    }

    function setTransferSlippageRatio(uint ratio_) public onlyRole(ROLE_TOKEN) {
        _transferSlippageRatio = ratio_;
    }

    function getTransferSlippageRatio() public view returns (uint) {
        return _transferSlippageRatio;
    }

    function setTradeSlippageReliefState(address user_, bool state_) public onlyRole(ROLE_ROBOT) {
        _slippageReliefList[user_] = state_;
    }

    function batchSetTradeSlippageReliefState(address[] memory users_, bool[] memory states_) public onlyRole(ROLE_ROBOT) {
        require(users_.length == states_.length, "NLT: length not same");

        for (uint i = 0; i < users_.length; i ++) {
            _slippageReliefList[users_[i]] = states_[i];
        }
    }

    function isInTradeSlippageReliefList(address user_) public view returns (bool) {
        return _slippageReliefList[user_];
    }

    function setNormalSlippageReceiver(address[] memory receivers_, uint[] memory ratios_) public onlyRole(ROLE_TOKEN) {
        require(receivers_.length == ratios_.length, "NLT: length not same");

        uint length = _normalSlippageReceivers.length;
        for (uint i = 0; i < length; i ++) {
            _normalSlippageReceivers.pop();
        }

        for (uint i = 0; i < receivers_.length; i ++) {
            _normalSlippageReceivers.push(Receiver({receiver: receivers_[i], ratio: ratios_[i]}));
        }
    }

    function getNormalSlippageReceivers() public view returns (Receiver[] memory) {
        Receiver[] memory receivers_ = new Receiver[](_normalSlippageReceivers.length);
        for (uint i = 0; i < receivers_.length; i ++) {
            receivers_[i] = _normalSlippageReceivers[i];
        }
        return receivers_;
    }

    function setReliefSlippageReceiver(address[] memory receivers_, uint[] memory ratios_) public onlyRole(ROLE_TOKEN) {
        require(receivers_.length == ratios_.length, "NLT: length not same");

        uint length = _reliefSlippageReceivers.length;
        for (uint i = 0; i < length; i ++) {
            _reliefSlippageReceivers.pop();
        }

        for (uint i = 0; i < receivers_.length; i ++) {
            _reliefSlippageReceivers.push(Receiver({receiver: receivers_[i], ratio: ratios_[i]}));
        }
    }

    function getReliefSlippageReceivers() public view returns (Receiver[] memory) {
        Receiver[] memory receivers_ = new Receiver[](_reliefSlippageReceivers.length);
        for (uint i = 0; i < receivers_.length; i ++) {
            receivers_[i] = _reliefSlippageReceivers[i];
        }
        return receivers_;
    }

    function setTransferSlippageReceiver(address[] memory receivers_, uint[] memory ratios_) public onlyRole(ROLE_TOKEN) {
        require(receivers_.length == ratios_.length, "NLT: length not same");

        uint length = _transferSlippageReceivers.length;
        for (uint i = 0; i < length; i ++) {
            _transferSlippageReceivers.pop();
        }

        for (uint i = 0; i < receivers_.length; i ++) {
            _transferSlippageReceivers.push(Receiver({receiver: receivers_[i], ratio: ratios_[i]}));
        }
    }

    function getTransferSlippageReceivers() public view returns (Receiver[] memory) {
        Receiver[] memory receivers_ = new Receiver[](_transferSlippageReceivers.length);
        for (uint i = 0; i < receivers_.length; i ++) {
            receivers_[i] = _transferSlippageReceivers[i];
        }
        return receivers_;
    }
}