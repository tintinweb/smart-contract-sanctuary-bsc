/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\IAccessControl.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Strings.sol

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol";

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\AccessControl.sol

// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\IAccessControl.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Context.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\Strings.sol";
// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol";

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\interfaces\IERC20.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

// pragma solidity ^0.8.0;

// import "C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol";


// Dependency file: C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\security\ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

// pragma solidity ^0.8.0;

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


// Dependency file: contracts\interfaces\IUniswapV2Router02.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Router02 {
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );
}


// Dependency file: contracts\interfaces\IUniswapV2Factory.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}


// Dependency file: contracts\interfaces\IUniswapV2Pair.sol

// Uniswap V2
// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function token0() external view returns (address);
}


// Root file: contracts\Marketplace.sol

pragma solidity 0.8.15;

// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\access\AccessControl.sol';
// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\interfaces\IERC20.sol';
// import 'C:\Blockchain\ds-backend\node_modules\@openzeppelin\contracts\security\ReentrancyGuard.sol';
// import 'contracts\interfaces\IUniswapV2Router02.sol';
// import 'contracts\interfaces\IUniswapV2Factory.sol';
// import 'contracts\interfaces\IUniswapV2Pair.sol';

// TODO: Test

// ? TDL FROM 30/08
// ? #1: Add the fees logic to the marketplace contract to remember how it all works.
// ? --> feeRecipient is the same. When it reaches 25,000, swap.
// ? #2: Implement the functions on the front-end (delegate) & directly test there. It will be much easier than testing everything manually.
// ? #3: Perform further testing on more isolated functions.
// ? #4: Set up reward contract. Should be easy.

contract Marketplace is AccessControl, ReentrancyGuard {
  struct Product {
    uint256 price; // Price of the product in SRV. A product with a price of 0 is considered not available
    string id; // ID of the product
  }

  struct Purchase {
    uint256 purchasedProductsIndex; // The products that were bought; the index refers to "purchasedProducts"
    address buyer; // The address that initiated the purchase
    uint256 totalPrice; // The total price of the purchase
    uint256 time; // The time at which the purchase was done
  }

  bytes32 public constant ADMIN = keccak256('ADMIN');
  uint256 public PRICE_PRECISION = 1_000_000_000;

  IUniswapV2Router02 public pancakeRouter;
  address public wbnb;
  address public busd;
  IUniswapV2Pair public pancakeSrvBnbPair;
  IUniswapV2Pair public pancakeBnbBusdPair;

  address public admin;
  IERC20 public srv;
  address private salesRecipient; // Tokens made from sales are sent to this address
  address private rewardDispenser; // Wallet that distributes rewards

  uint256 public srvThresholdToProcessFunds = 25_000e18; // This contract will process the funds when it exceeds this number
  uint256 public marketingFundsBalance = 0;
  uint256 public liquidityFundsBalance = 0;

  // Liquify percentage & limit price
  uint256 public liquifyPercentage = 50; // (/1000)
  uint256 public limitPrice = 10_000_000; // (/PRICE_PRECISION)

  Product[] public availableProducts; // List of available products
  // @dev "purchasedProducts" and "numberOfPurchases" is necessary to add elements to purchasesByUser without causing storage errors
  mapping(uint256 => Product[]) public purchasedProducts; // List of all bought products
  mapping(uint256 => Purchase) public purchases; // List of all purchases
  uint256 public numberOfPurchases = 0; // Number of total purchases
  mapping(address => Purchase[]) public purchasesByUser; // For each user, store the IDs of what they bought in this array

  // Here to control when funds get processed
  bool public allowProcessingFunds = true;
  bool private swapping = false;
  bool private liquifying = false;

  event PurchasedProducts(Purchase purchase);
  event SwappedSrvForBnb(uint256 amount);
  event SwappedBnbForBusd(uint256 amount);
  event AddedLiquidity(uint256 srvAmount, uint256 bnbAmount);

  constructor(
    address _pancakeRouter,
    address _busd,
    address _srv,
    address payable _salesRecipient,
    address _rewardDispenser
  ) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    grantRole(ADMIN, msg.sender);
    admin = msg.sender;

    pancakeRouter = IUniswapV2Router02(_pancakeRouter);
    wbnb = pancakeRouter.WETH();
    busd = _busd;
    srv = IERC20(_srv);

    IUniswapV2Factory pancakeFactory = IUniswapV2Factory(pancakeRouter.factory());
    pancakeSrvBnbPair = IUniswapV2Pair(pancakeFactory.getPair(_srv, wbnb));
    pancakeBnbBusdPair = IUniswapV2Pair(pancakeFactory.getPair(wbnb, busd));

    salesRecipient = _salesRecipient;
    rewardDispenser = _rewardDispenser;
  }

  receive() external payable {}

  // Allows user to buy multiple products using SRV
  function buyProducts(uint256[] memory _indexes) external nonReentrant {
    // Safety check
    require(_indexes.length > 0, 'Cannot buy zero products');

    uint256 totalToSpend = 0;

    // Go through the list of products to determine the total amount of SRV to spend
    for (uint256 i = 0; i < _indexes.length; i++) {
      // Out of bounds safety check
      require(_indexes[i] < availableProducts.length, 'Trying to purchase a product that does not exist');

      // Fetch product price
      uint256 productPrice = availableProducts[_indexes[i]].price;

      // Product availability safety check
      require(productPrice > 0, 'This product is not available for purchase');

      // Add product price to total amount of SRV to spend
      totalToSpend += productPrice;

      // Store purchased product
      // @dev Store the purchased product directly in storage to avoid errors
      purchasedProducts[numberOfPurchases].push(availableProducts[_indexes[i]]); // TODO: Investigate gas fees
    }

    // User balance safety check
    require(srv.balanceOf(msg.sender) >= totalToSpend, 'SRV balance is too low to purchase these products');

    // Buy products
    srv.transferFrom(msg.sender, address(this), totalToSpend);

    // Store the amount of SRV that were sent
    uint256 liquidityFunds = (totalToSpend * liquifyPercentage) / 1000;
    marketingFundsBalance += totalToSpend - liquidityFunds;
    liquidityFundsBalance += liquidityFunds;

    // Funds processing logic
    if (allowProcessingFunds) {
      if (!swapping && marketingFundsBalance > srvThresholdToProcessFunds && msg.sender != address(pancakeRouter)) {
        // Swap funds
        _swapFunds();
      } else if (!liquifying && liquidityFundsBalance > srvThresholdToProcessFunds && msg.sender != address(pancakeRouter)) {
        // Add liquidity
        _liquify();
      }
    }

    // Store purchase
    Purchase memory purchase = Purchase(numberOfPurchases, msg.sender, totalToSpend, block.timestamp);
    purchases[numberOfPurchases] = purchase;
    purchasesByUser[msg.sender].push(purchase);

    // Increment the number of purchases
    numberOfPurchases++;

    // Emit event
    emit PurchasedProducts(purchase);
  }

  // Processes funds stored on sales recipient's wallet
  function _swapFunds() internal {
    // Forbid processing marketing funds
    swapping = true;

    // Safety check
    require(marketingFundsBalance > 0, 'Not enough SRV tokens to swap for marketing funds processing');

    // Fetch price of SRV in USD
    uint256 srvPrice = getSrvPriceInUsd(); // (/PRICE_PRECISION)

    // If the price is under limitPrice, send remaining SRV to rewardDispenser
    if (srvPrice < limitPrice) srv.transfer(rewardDispenser, marketingFundsBalance);

    // If the price is above limitPrice, swap remaining SRV to BUSD & send them to salesRecipient
    else _swapSrvForBusd(salesRecipient, marketingFundsBalance);

    // Reset the marketing funds balance
    marketingFundsBalance = 0;

    // Allow processing marketing funds again
    swapping = false;
  }

  // Swaps "_amount" SRV for BNB
  function _swapSrvForBnb(address _recipient, uint256 _srvAmount) internal {
    address[] memory path = new address[](2);
    path[0] = address(srv);
    path[1] = wbnb;

    srv.approve(address(pancakeRouter), _srvAmount);

    pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _srvAmount,
      0, // accept any amount of BUSD
      path,
      _recipient,
      block.timestamp
    );

    emit SwappedSrvForBnb(_srvAmount);
  }

  // Swaps "_amount" SRV for BUSD
  function _swapSrvForBusd(address _recipient, uint256 _srvAmount) internal {
    address[] memory path = new address[](3);
    path[0] = address(srv);
    path[1] = wbnb;
    path[2] = busd;

    srv.approve(address(pancakeRouter), _srvAmount);

    pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _srvAmount,
      0, // accept any amount of BUSD
      path,
      _recipient,
      block.timestamp
    );

    emit SwappedBnbForBusd(_srvAmount);
  }

  // Sends "_srvAmount" SRV to the SRV / BNB pool
  function _liquify() internal {
    // Forbid processing liquidity funds
    liquifying = true;

    // Safety check
    require(liquidityFundsBalance > 0, 'Not enough SRV tokens to swap for adding liquidity');

    // Store old BNB balance
    uint256 oldBnbBalance = address(this).balance;

    // Sell half of the SRV for BNB
    uint256 lowerHalf = liquidityFundsBalance / 2;
    uint256 upperHalf = liquidityFundsBalance - lowerHalf;

    // Swap
    _swapSrvForBnb(address(this), lowerHalf);

    // Add liquidity
    _addLiquidity(upperHalf, address(this).balance - oldBnbBalance);

    // Reset the liquidity funds balance
    liquidityFundsBalance = 0;

    // Allow processing liquidity funds again
    liquifying = false;
  }

  // Adds liquidity to the SRV / BNB pair on Pancakeswap
  function _addLiquidity(uint256 _srvAmount, uint256 _bnbAmount) internal {
    // Approve token transfer to cover all possible scenarios
    srv.approve(address(pancakeRouter), _srvAmount);

    // Add the liquidity
    pancakeRouter.addLiquidityETH{value: _bnbAmount}(
      address(this),
      _srvAmount,
      0, // Slippage is unavoidable
      0, // Slippage is unavoidable
      address(0),
      block.timestamp
    );

    emit AddedLiquidity(_srvAmount, _bnbAmount);
  }

  // Returns the price of SRV in BUSD, times PRICE_PRECISION
  function getSrvPriceInUsd() public view returns (uint256) {
    // Get price of SRV in BNB
    uint256 pooledSrvInSrvBnb;
    uint256 pooledBnbInSrvBnb;

    (uint256 reserve0a, uint256 reserve1a, ) = pancakeSrvBnbPair.getReserves();

    if (pancakeBnbBusdPair.token0() == address(this)) {
      pooledSrvInSrvBnb = reserve0a;
      pooledBnbInSrvBnb = reserve1a;
    } else {
      pooledSrvInSrvBnb = reserve1a;
      pooledBnbInSrvBnb = reserve0a;
    }

    uint256 srvPriceInBnb = (PRICE_PRECISION * pooledBnbInSrvBnb) / pooledSrvInSrvBnb;

    // Get price of BNB in BUSD
    uint256 pooledBnbInBnbBusd;
    uint256 pooledBusdInBnbBusd;

    (uint256 reserve0b, uint256 reserve1b, ) = pancakeBnbBusdPair.getReserves();

    if (pancakeBnbBusdPair.token0() == wbnb) {
      pooledBnbInBnbBusd = reserve0b;
      pooledBusdInBnbBusd = reserve1b;
    } else {
      pooledBnbInBnbBusd = reserve1b;
      pooledBusdInBnbBusd = reserve0b;
    }

    uint256 bnbPriceInBusd = (PRICE_PRECISION * pooledBusdInBnbBusd) / pooledBnbInBnbBusd;

    // Get price of SRV in BUSD times PRICE_PRECISION
    return (srvPriceInBnb * bnbPriceInBusd) / PRICE_PRECISION;
  }

  function getAvailableProducts() external view returns (Product[] memory) {
    return availableProducts;
  }

  function getPurchasedProducts(uint256 _index) external view returns (Product[] memory) {
    return purchasedProducts[_index];
  }

  function getPurchase(uint256 _index) external view returns (Purchase memory) {
    return purchases[_index];
  }

  function getPurchasesByUser(address _address) external view returns (Purchase[] memory) {
    return purchasesByUser[_address];
  }

  // Withdraws an amount of BNB stored on the contract
  function withdrawAdmin(uint256 _amount) external onlyRole(ADMIN) {
    payable(msg.sender).transfer(_amount);
  }

  // Withdraws an amount of ERC20 tokens stored on the contract
  function withdrawERC20Admin(address _erc20, uint256 _amount) external onlyRole(ADMIN) {
    IERC20(_erc20).transfer(msg.sender, _amount);
  }

  function changeAdmin(address _admin) external onlyRole(ADMIN) {
    revokeRole(ADMIN, admin);
    grantRole(ADMIN, _admin);
    admin = _admin;
  }

  function revokeAdmin(address _adminToRevoke) external onlyRole(ADMIN) {
    revokeRole(ADMIN, _adminToRevoke);
  }

  // Manually swaps funds
  function manualSwapFundsAdmin() external onlyRole(ADMIN) {
    _swapFunds();
  }

  // Manually swaps SRV for BNB
  function manualSwapSrvForBnbAdmin(address _recipient, uint256 _amount) external onlyRole(ADMIN) {
    _swapSrvForBnb(_recipient, _amount);
  }

  // Manually swaps SRV for BUSD
  function manualSwapSrvForBusdAdmin(address _recipient, uint256 _amount) external onlyRole(ADMIN) {
    _swapSrvForBusd(_recipient, _amount);
  }

  // Manually liquifies SRV to the SRV / BNB liquidity pool
  function manualLiquifyAdmin() external onlyRole(ADMIN) {
    _liquify();
  }

  // Sets the list of products
  function setProductsAdmin(Product[] memory _availableProducts) external onlyRole(ADMIN) {
    delete availableProducts; // TODO: Test this. It is possible that this only deletes the first element
    for (uint256 i = 0; i < _availableProducts.length; i++) {
      availableProducts.push(_availableProducts[i]);
    }
  }

  // Adds a product to the list of products
  function addProductAdmin(Product memory _product) external onlyRole(ADMIN) {
    availableProducts.push(_product);
  }

  // Update a specific product
  function updateProductAdmin(Product memory _product, uint256 _index) external onlyRole(ADMIN) {
    availableProducts[_index] = _product;
  }

  // Remove a specific product
  function removeProductAdmin(uint256 _index) external onlyRole(ADMIN) {
    // Safety check
    require(availableProducts.length > _index, 'Index is too high');

    // Move all products to the left, starting with _index + 1
    for (uint256 i = _index; i < availableProducts.length - 1; i++) {
      availableProducts[i] = availableProducts[i + 1];
    }

    // Delete the last product
    availableProducts.pop();
  }

  function popProductAdmin() external onlyRole(ADMIN) {
    availableProducts.pop();
  }

  function setSrvThresholdToProcessFundsAdmin(uint256 _srvThresholdToProcessFunds) external onlyRole(ADMIN) {
    srvThresholdToProcessFunds = _srvThresholdToProcessFunds;
  }

  function allowProcessingFundsAdmin(bool _allowProcessingFunds) external onlyRole(ADMIN) {
    allowProcessingFunds = _allowProcessingFunds;
  }

  function setLiquifyPercentageAdmin(uint256 _liquifyPercentage) external onlyRole(ADMIN) {
    liquifyPercentage = _liquifyPercentage; // (/1000)
  }

  function setLimitPriceAdmin(uint256 _limitPrice) external onlyRole(ADMIN) {
    limitPrice = _limitPrice; // (/PRICE_PRECISION)
  }
}