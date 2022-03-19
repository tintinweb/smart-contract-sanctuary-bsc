/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/IAccessControl.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol


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

// File: contracts/Staking.sol


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


contract Staking is AccessControl {

    bytes32 constant public ADMIN_ROLE = keccak256("Admin Role");

    struct User {
        uint256 stakeTime;
        uint256 lastClaimTime;
        uint256 packageIndex;
        uint256 amount;
        uint256 tokenId;
        bool isActive;
    }
    mapping(address => User[]) public users;

    mapping(address => uint256) public guaranteeTokenAmounts;

    address public treasuryAddress = 0x8460B592e23d08f35f669B0A5a3581eb694d5F72;
    bool public enableTreasury = true;
    bool public enableBuyDexo = false;


    uint256[4] public defaultPacages = [1000 ether, 2000 ether, 5000 ether, 10000 ether];
    uint256[4] public defaultAPY = [60, 60, 60, 60];

    uint256 public penaltyPercent = 10;
    uint256 public minAmountToGetReward = 10 ether;
    uint256 public minAmountToStakeWithDexo = 10 ether;
    uint256 public minAmountToBuyDexo = 10 ether;
    bool public enableMinAmountToGetReward = false;
    uint256 public timePeriod = 1 days;
    uint256 public liveTimePeriod = 1 seconds;

    bool public lastPackageEnabled = true;

    IUniswapV2Router02 public uniswapV2Router;

    IERC20 public USDT;
    IERC20 public DEXO;
    IERC20 public oneXD;
    IERC20 public oneSD;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "!admin");
        _;
    }

    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, treasuryAddress);
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        USDT = IERC20(0xbbf3b8A91eD33FAb104f02861f15F90E9dcEe530);
        DEXO = IERC20(0xe1c87A591fF01B2635cCD5290830A85677585E57);
        oneSD = IERC20(0x46A606f9D7f36c7aA12256021Cbfd948F29cAEA7);
        oneXD = IERC20(0x6188cE1eFF7859B6b87cfC5167c8cFe7f538036F);

    }

    modifier stakingStarted {
        uint256 guaranteeBalance = oneXD.balanceOf(address(this));
        uint256 rewardBalance = DEXO.balanceOf(address(this));
        uint256 standardBalance = oneSD.balanceOf(address(this));
        require(guaranteeBalance > 0 && rewardBalance > 0 && standardBalance > 0, "!Not Start");
        _;
    }

    function stake(uint256 amount, address _address, uint256 tokenId) public stakingStarted {
        IERC20 token;
        if (tokenId == 0) {
            token = USDT;
        }
        if (tokenId == 1) {
            uint256 userAmount = 0;
            for (uint256 i = 0; i < users[_address].length; i++) {
                userAmount += users[_address][i].amount;
            }
            require(userAmount >= minAmountToStakeWithDexo, 'Insufficient Stake Amount');
            token = DEXO;
        }
        if (tokenId == 2) {
            uint256 userAmount = 0;
            for (uint256 i = 0; i < users[_address].length; i++) {
                userAmount += users[_address][i].amount;
            }
            token = oneSD;
        }

        bool packageExist = false;
        uint256 packageIndex;
        for (uint256 i = 0; i < defaultPacages.length; i++) {
            if (amount == defaultPacages[i]) {
                packageExist = true;
                packageIndex = i;
            }
        }
        if (packageIndex == 4) {
            require(lastPackageEnabled, 'Package is not active');
        }
        require(packageExist, 'Invalid Package');
        if (enableTreasury) {
            token.transferFrom(msg.sender, treasuryAddress, tokenId == 0 ? amount : getRewardByUSDT(amount));
        } else {
            token.transferFrom(msg.sender, address(this), tokenId == 0 ? amount : getRewardByUSDT(amount));
        }
        oneXD.transfer(_address, amount);
        guaranteeTokenAmounts[_address] += amount;
        users[_address].push(User({
            stakeTime: block.timestamp,
            lastClaimTime: block.timestamp,
            packageIndex: packageIndex,
            amount: amount,
            tokenId: tokenId,
            isActive: true
        }));

    }

    function buyDexo(uint256 amount) public {
        require(enableBuyDexo, 'Buy Is Not Active');
        uint256 userAmount = 0;
        for (uint256 i = 0; i < users[msg.sender].length; i++) {
            userAmount += users[msg.sender][i].amount;
        }
        require(userAmount >= minAmountToBuyDexo, 'Insufficient Stake Amount');
        if (enableTreasury) {
            USDT.transferFrom(msg.sender, treasuryAddress, amount);
        } else {
            USDT.transferFrom(msg.sender, address(this), amount);
        }
        uint256 dexoAmount = getRewardByUSDT(amount);
        DEXO.transfer(msg.sender, dexoAmount);
    }

    function unStake(uint256 stakeTime, address user) public onlyAdmin {
        require(users[user].length > 0, '!NO Stake');
        uint256 reward = earned(user);
        if (enableMinAmountToGetReward) {
            require(reward >= minAmountToGetReward, '!Insufficient Reward');
        }

        bool stakeExist;
        uint256 stakeIndex;
        for (uint256 i = 0; i < users[user].length; i++) {
            if (stakeTime == users[user][i].stakeTime) {
                stakeExist = true;
                stakeIndex = i;
            }
        }
        require(stakeExist, 'Invalid Stake Time');
        require(users[user][stakeIndex].isActive, 'Already Unstaked');
        uint256 allowance = oneXD.allowance(msg.sender, address(this));
        require(allowance >= users[user][stakeIndex].amount, "OneXD Allowance");
        oneXD.transferFrom(user, address(this), users[user][stakeIndex].amount);

        uint256 rewardTokenAmount = getRewardByUSDT(reward);
        DEXO.transfer(user, rewardTokenAmount);
        USDT.transfer(user, (users[user][stakeIndex].amount * (100 - penaltyPercent)) / 100);
        users[user][stakeIndex].lastClaimTime = block.timestamp;
        users[user][stakeIndex].isActive = false;
        guaranteeTokenAmounts[user] -= users[user][stakeIndex].amount;

    }

    function earned(address user) public view returns(uint256 reward) {
        reward = 0;
        for (uint i = 0; i < users[user].length; i++) {
            if (users[user][i].isActive) {
                uint256 periodByDay = (block.timestamp - users[user][i].lastClaimTime) / timePeriod;
                reward += periodByDay * users[user][i].amount * defaultAPY[users[user][i].packageIndex] / 365 / 100;
            }
        }
    }

    function earnedLive(address user) public view returns(uint256 reward) {
        reward = 0;
        for (uint i = 0; i < users[user].length; i++) {
            if (users[user][i].isActive) {
                uint256 periodByDay = (block.timestamp - users[user][i].lastClaimTime) / liveTimePeriod;
                reward += periodByDay * users[user][i].amount * defaultAPY[users[user][i].packageIndex] / 365 / 100;
            }
        }
    }

    function withdrawReward(address user) public onlyAdmin {
        uint256 reward = earned(user);
        require(reward >= minAmountToGetReward, '!Insufficient Reward');

        uint256 rewardTokenAmount = getRewardByUSDT(reward);
        DEXO.transfer(user, rewardTokenAmount);
        for (uint i = 0; i < users[user].length; i++) {
             if (users[user][i].isActive) {
                users[user][i].lastClaimTime = block.timestamp;
             }
        }
    }

    function getRewardByUSDT(uint256 rewardAmount) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(DEXO);
        return uniswapV2Router.getAmountsOut(rewardAmount, path)[1];
    }

    function setUSDT(IERC20 newUSDT) public onlyAdmin {
        USDT = newUSDT;
    }

    function setGuaranteeToken(IERC20 newGuaranteeToken) public onlyAdmin {
        oneXD = newGuaranteeToken;
    }

    function setStandardToken(IERC20 newGuaranteeToken) public onlyAdmin {
        oneSD = newGuaranteeToken;
    }

    function setRewardToken(IERC20 newRewardToken) public onlyAdmin {
        DEXO = newRewardToken;
    }

    function setMinAmountToGetReward(uint256 newAmount) public onlyAdmin {
        minAmountToGetReward = newAmount;
    }

    function updateEnableTreasury(bool _enable) public onlyAdmin {
        enableTreasury = _enable;
    }

    function updateEnableBuyDexo(bool _enable) public onlyAdmin {
        enableBuyDexo = _enable;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyAdmin {
        treasuryAddress = _treasuryAddress;
    }

    function setMinAmountToBuyDexo (uint256 newAmount) public onlyAdmin {
        minAmountToBuyDexo = newAmount;
    }

    function setLiveTimePeriod(uint256 _liveTimePeriod) public onlyAdmin {
        liveTimePeriod = _liveTimePeriod;
    }

    function setPeriodTime(uint256 _period) public onlyAdmin {
        timePeriod = _period;
    }

    function setLastPackageEnabled(bool _lastPackageEnabled) public onlyAdmin {
        lastPackageEnabled = _lastPackageEnabled;
    }

    function setPenaltyPercent(uint256 percent) public onlyAdmin {
        penaltyPercent = percent;
    }

    function setDefaultPacages(uint256[4] memory newDefaultPacages) public onlyAdmin {
        defaultPacages = newDefaultPacages;
    }

    function setDefaultAPY(uint256[4] memory newDefaultAPY) public onlyAdmin {
        defaultAPY = newDefaultAPY;
    }

    function setMinAmountToStakeWithDexo(uint256 _minAmountToStakeWithDexo) public onlyAdmin {
        minAmountToStakeWithDexo = _minAmountToStakeWithDexo;
    }

    function setEnableMinAmountToGetReward(bool _enableMinAmountToGetReward) public onlyAdmin {
        enableMinAmountToGetReward = _enableMinAmountToGetReward;
    }



    function adminWithdrawTokens(uint256 amount, address _to, address _tokenAddr) public onlyAdmin {
        require(_to != address(0));
        if(_tokenAddr == address(0)){
            payable(_to).transfer(amount);
        }else{
            IERC20(_tokenAddr).transfer(_to, amount);
        }
    }

    function getUserInfo(address user) public view returns(
        User[30] memory info
    ){
        for(uint256 i = 0; i < users[user].length; i++){
            info[i] = users[user][i];
        }
    }

}