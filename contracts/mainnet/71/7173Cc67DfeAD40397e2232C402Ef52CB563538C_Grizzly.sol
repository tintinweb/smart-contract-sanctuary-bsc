/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// Sources flattened with hardhat v2.6.8 https://hardhat.org

// File contracts/Interfaces/IMasterChef.sol
//SPDX-License-identifier: Unlicensed
 
pragma solidity ^ 0.8.4;

interface IMasterChef {
    function CAKE() external pure returns(address);

function lpToken(uint256 _pid) external view returns(address);

function userInfo(uint256 _pid, address _user)
external
pure
returns(
    uint256 amount,
    uint256 rewardDebt,
    uint256 boostMultiplier
);

function pendingCake(uint256 _pid, address _user)
external
view
returns(uint256);

function deposit(uint256 _pid, uint256 _amount) external;

function withdraw(uint256 _pid, uint256 _amount) external;
}


// File contracts/Interfaces/IUniswapV2Router01.sol

 
pragma solidity >= 0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns(address);
function WETH() external pure returns(address);

function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external returns(uint amountA, uint amountB, uint liquidity);
function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) external payable returns(uint amountToken, uint amountETH, uint liquidity);
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external returns(uint amountA, uint amountB);
function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) external returns(uint amountToken, uint amountETH);
function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
) external returns(uint amountA, uint amountB);
function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
) external returns(uint amountToken, uint amountETH);
function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) external returns(uint[] memory amounts);
function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
) external returns(uint[] memory amounts);
function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
external
payable
returns(uint[] memory amounts);
function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
external
returns(uint[] memory amounts);
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
external
returns(uint[] memory amounts);
function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
external
payable
returns(uint[] memory amounts);

function quote(uint amountA, uint reserveA, uint reserveB) external pure returns(uint amountB);
function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns(uint amountOut);
function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns(uint amountIn);
function getAmountsOut(uint amountIn, address[] calldata path) external view returns(uint[] memory amounts);
function getAmountsIn(uint amountOut, address[] calldata path) external view returns(uint[] memory amounts);
}


// File contracts/Interfaces/IUniswapV2Pair.sol

 
pragma solidity >= 0.6.2;

interface IUniswapV2Pair {
    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
);
    event Transfer(address indexed from, address indexed to, uint256 value);

function name() external pure returns(string memory);

function symbol() external pure returns(string memory);

function decimals() external pure returns(uint8);

function totalSupply() external view returns(uint256);

function balanceOf(address owner) external view returns(uint256);

function allowance(address owner, address spender)
external
view
returns(uint256);

function approve(address spender, uint256 value) external returns(bool);

function transfer(address to, uint256 value) external returns(bool);

function transferFrom(
    address from,
    address to,
    uint256 value
) external returns(bool);

function DOMAIN_SEPARATOR() external view returns(bytes32);

function PERMIT_TYPEHASH() external pure returns(bytes32);

function nonces(address owner) external view returns(uint256);

function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
);
    event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
);
    event Sync(uint112 reserve0, uint112 reserve1);

function MINIMUM_LIQUIDITY() external pure returns(uint256);

function factory() external view returns(address);

function token0() external view returns(address);

function token1() external view returns(address);

function getReserves()
external
view
returns(
    uint112 reserve0,
    uint112 reserve1,
    uint32 blockTimestampLast
);

function price0CumulativeLast() external view returns(uint256);

function price1CumulativeLast() external view returns(uint256);

function kLast() external view returns(uint256);

function mint(address to) external returns(uint256 liquidity);

function burn(address to)
external
returns(uint256 amount0, uint256 amount1);

function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
) external;

function skim(address to) external;

function sync() external;
}


// File contracts/Interfaces/IUniswapV2Factory.sol

pragma solidity >= 0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
);

function feeTo() external view returns(address);

function feeToSetter() external view returns(address);

function getPair(address tokenA, address tokenB)
external
view
returns(address pair);

function allPairs(uint256) external view returns(address pair);

function allPairsLength() external view returns(uint256);

function createPair(address tokenA, address tokenB)
external
returns(address pair);

function setFeeTo(address) external;

function setFeeToSetter(address) external;
}


// File contracts/Interfaces/IDEX.sol

 
pragma solidity ^ 0.8.4;
interface IDEX {
    function SwapRouter() external returns(IUniswapV2Router01);

function convertEthToPairLP(address lpAddress)
external
payable
returns(
    uint256 lpAmount,
    uint256 unusedTokenA,
    uint256 unusedTokenB
);

function convertEthToTokenLP(address token)
external
payable
returns(
    uint256 lpAmount,
    uint256 unusedEth,
    uint256 unusedToken
);

function convertPairLpToEth(address lpAddress, uint256 amount)
external
returns(uint256 ethAmount);

function convertTokenLpToEth(address token, uint256 amount)
external
returns(uint256 ethAmount);

function convertEthToToken(address token)
external
payable
returns(uint256 tokenAmount);

function convertTokenToEth(uint256 amount, address token)
external
returns(uint256 ethAmount);

function getTokenEthPrice(address token) external view returns(uint256);

function totalPendingReward(uint256 poolID) external view returns(uint256);

function totalStakedAmount(uint256 poolID) external view returns(uint256);

function checkSlippage(
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage
) external view;

function recoverFunds() external;
}


// File contracts/Interfaces/IHoney.sol

 
pragma solidity ^ 0.8.4;

interface IHoney {
    function totalClaimed(address claimer) external view returns(uint256);

function claimTokens(uint256 amount) external;

function setDevelopmentFounders(address _developmentFounders) external;

function setAdvisors(address _advisors) external;

function setMarketingReservesPool(address _marketingReservesPool) external;

function setDevTeam(address _devTeam) external;

function claimTokensWithoutAdditionalTokens(uint256 amount) external;
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^ 0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns(bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount } ("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns(bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns(bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns(bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns(bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value } (data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns(bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns(bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size:= mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^ 0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns(bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
function hasRole(bytes32 role, address account) external view returns(bool);

/**
 * @dev Returns the admin role that controls `role`. See {grantRole} and
 * {revokeRole}.
 *
 * To change a role's admin, use {AccessControl-_setRoleAdmin}.
 */
function getRoleAdmin(bytes32 role) external view returns(bytes32);

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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^ 0.8.0;

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns(string memory) {
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
    function toHexString(uint256 value) internal pure returns(string memory) {
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
    function toHexString(uint256 value, uint256 length) internal pure returns(string memory) {
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


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^ 0.8.0;


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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]

 
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^ 0.8.0;





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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns(bool) {
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns(bytes32) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^ 0.8.0;

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
function totalSupply() external view returns(uint256);

/**
 * @dev Returns the amount of tokens owned by `account`.
 */
function balanceOf(address account) external view returns(uint256);

/**
 * @dev Moves `amount` tokens from the caller's account to `to`.
 *
 * Returns a boolean value indicating whether the operation succeeded.
 *
 * Emits a {Transfer} event.
 */
function transfer(address to, uint256 amount) external returns(bool);

/**
 * @dev Returns the remaining number of tokens that `spender` will be
 * allowed to spend on behalf of `owner` through {transferFrom}. This is
 * zero by default.
 *
 * This value changes when {approve} or {transferFrom} are called.
 */
function allowance(address owner, address spender) external view returns(uint256);

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
function approve(address spender, uint256 amount) external returns(bool);

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
) external returns(bool);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^ 0.8.0;


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

        function safeTransfer(
            IERC20Upgradeable token,
            address to,
            uint256 value
        ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^ 0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns(bool) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File contracts/DEX.sol

 
pragma solidity ^ 0.8.4;
/// @title DEX proxy
/// @notice The DEX proxy is responsible to convert the different tokens and the native coin. It uses the pancakeswap swap router to exchange these tokens
/// @dev All swaps are done on behalf of this contract. This means all tokens are owned by this contract and are then divided for the different investors in the strategy contracts
contract DEX is
Initializable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    IDEX,
    PausableUpgradeable
{
    // is necessary to receive unused bnb from the swaprouter
    receive() external payable { }

    using SafeERC20Upgradeable for IERC20Upgradeable;

        bytes32 public constant FUNDS_RECOVERY_ROLE =
            keccak256("FUNDS_RECOVERY_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 private constant MAX_PERCENTAGE = 100000;

    IUniswapV2Router01 public override SwapRouter;
    IMasterChef public StakingContract;

    mapping(address => address[]) public pathFromTokenToEth;
    mapping(address => address[]) public pathFromEthToToken;

    function initialize(
        address _SwapRouterAddress,
        address _StakingContractAddress,
        address _Admin
    ) public initializer {
        SwapRouter = IUniswapV2Router01(_SwapRouterAddress);
        StakingContract = IMasterChef(_StakingContractAddress);
        __Pausable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _Admin);
    }

    /// @notice pause
    /// @dev pause the contract
    function pause() external whenNotPaused onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice unpause
    /// @dev unpause the contract
    function unpause() external whenPaused onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Converts bnbs to the two tokens for liquidity providing. Then provides these tokens to the liquidity pool and receives lp tokens
    /// @dev No slippage implemented at this time. BNB needs to be provided as value.
    /// @param lpAddress The address for the LP Token
    /// @return lpAmount The recieved lp tokens for the liq. providing
    /// @return unusedTokenA The amount of token A that could not be provided as liquidity
    /// @return unusedTokenB The amount of token B that could not be provided as liquidity
    function convertEthToPairLP(address lpAddress)
    external
    payable
    override
    whenNotPaused
    returns(
        uint256 lpAmount,
        uint256 unusedTokenA,
        uint256 unusedTokenB
    )
    {
        IUniswapV2Pair LPToken = IUniswapV2Pair(lpAddress);

        if (LPToken.token0() == SwapRouter.WETH()) {
            (lpAmount, unusedTokenA, unusedTokenB) = convertEthToTokenLP(
                LPToken.token1()
            );
            return (lpAmount, unusedTokenA, unusedTokenB);
        }
        if (LPToken.token1() == SwapRouter.WETH()) {
            (lpAmount, unusedTokenB, unusedTokenA) = convertEthToTokenLP(
                LPToken.token0()
            );
            return (lpAmount, unusedTokenA, unusedTokenB);
        }

        IERC20Upgradeable TokenA = IERC20Upgradeable(LPToken.token0());

        IERC20Upgradeable TokenB = IERC20Upgradeable(LPToken.token1());

        address[] memory _pathFromEthToTokenA = pathFromEthToToken[
            address(TokenA)
        ];
        address[] memory _pathFromEthToTokenB = pathFromEthToToken[
            address(TokenB)
        ];

        require(
            _pathFromEthToTokenA.length >= 2 &&
            _pathFromEthToTokenB.length >= 2,
            "TN"
        );

        uint256 tokenAValue = SwapRouter.swapExactETHForTokens{
            value: msg.value / 2
        } (1, _pathFromEthToTokenA, address(this), block.timestamp + 1)[
            _pathFromEthToTokenA.length - 1
        ];

        uint256 tokenBValue = SwapRouter.swapExactETHForTokens{
            value: msg.value / 2
        } (1, _pathFromEthToTokenB, address(this), block.timestamp + 1)[
            _pathFromEthToTokenB.length - 1
        ];

        uint256 allowanceA = TokenA.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowanceA < tokenAValue) {
            require(TokenA.approve(address(SwapRouter), tokenAValue), "FS");
        }

        uint256 allowanceB = TokenB.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowanceB < tokenBValue) {
            require(TokenB.approve(address(SwapRouter), tokenBValue), "FS");
        }

        (uint256 usedTokenA, uint256 usedTokenB, uint256 lpValue) = SwapRouter
            .addLiquidity(
                address(TokenA),
                address(TokenB),
                tokenAValue,
                tokenBValue,
                1,
                1,
                msg.sender,
                block.timestamp + 1
            );

        lpAmount = lpValue;
        unusedTokenA = tokenAValue - usedTokenA;
        unusedTokenB = tokenBValue - usedTokenB;

        // send back unused tokens
        TokenA.safeTransfer(msg.sender, unusedTokenA);
        TokenB.safeTransfer(msg.sender, unusedTokenB);
    }

    /// @notice Converts half of the bnbs to the one other token for liquidity providing in a bnb-token liquidity pool. Then provides bnb and the token to the liquidity pool and receives lp tokens
    /// @dev No slippage implemented at this time. BNB needs to be provided as value.
    /// @param token The address of the token for liq. providing
    /// @return lpAmount The recieved lp tokens for the bnb-token liq. providing
    /// @return unusedEth The amount bnbs that could not be provided as liquidity
    /// @return unusedToken The amount of the token that could not be provided as liquidity
    function convertEthToTokenLP(address token)
    public
    payable
    override
    whenNotPaused
    returns(
        uint256 lpAmount,
        uint256 unusedEth,
        uint256 unusedToken
    )
    {
        IERC20Upgradeable Token = IERC20Upgradeable(token);

        address[] memory _pathFromEthToToken = pathFromEthToToken[
            address(Token)
        ];

        require(_pathFromEthToToken.length >= 2, "TN");

        uint256 tokenValue = SwapRouter.swapExactETHForTokens{
            value: msg.value / 2
        } (1, _pathFromEthToToken, address(this), block.timestamp + 1)[
            _pathFromEthToToken.length - 1
        ];

        uint256 allowance = Token.allowance(address(this), address(SwapRouter));
        if (allowance < tokenValue) {
            require(Token.approve(address(SwapRouter), tokenValue), "FS");
        }

        (uint256 usedToken, uint256 usedEth, uint256 lpValue) = SwapRouter
            .addLiquidityETH{ value: msg.value / 2 } (
                address(Token),
                tokenValue,
                1,
                1,
                msg.sender,
                block.timestamp + 1
            );

        lpAmount = lpValue;
        unusedToken = tokenValue - usedToken;
        unusedEth = msg.value / 2 - usedEth;

        // send back unused tokens / BNB
        Token.safeTransfer(msg.sender, unusedToken);
        (bool transferSuccess, ) = payable(msg.sender).call{ value: unusedEth } (
            ""
        );
        require(transferSuccess, "TF");
    }

    /// @notice Converts lp tokens back to bnbs. First removes liquidity using the lp tokens and then swaps the tokens to bnbs
    /// @dev No slippage implemented at this time
    /// @param amount The amount in lp tokens to be converted into bnbs
    /// @param lpAddress The recieved lp tokens for the liq. providing
    /// @return ethAmount The total amount of bnbs that were received from the swaps
    function convertPairLpToEth(address lpAddress, uint256 amount)
    external
    override
    whenNotPaused
    returns(uint256 ethAmount)
    {
        IUniswapV2Pair LPToken = IUniswapV2Pair(lpAddress);

        if (LPToken.token0() == SwapRouter.WETH()) {
            ethAmount = convertTokenLpToEth(LPToken.token1(), amount);
            return ethAmount;
        }
        if (LPToken.token1() == SwapRouter.WETH()) {
            ethAmount = convertTokenLpToEth(LPToken.token0(), amount);
            return ethAmount;
        }

        IERC20Upgradeable(lpAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        IERC20Upgradeable TokenA = IERC20Upgradeable(LPToken.token0());

        IERC20Upgradeable TokenB = IERC20Upgradeable(LPToken.token1());

        address[] memory _pathFromTokenAToEth = pathFromTokenToEth[
            address(TokenA)
        ];
        address[] memory _pathFromTokenBToEth = pathFromTokenToEth[
            address(TokenB)
        ];

        require(
            _pathFromTokenAToEth.length >= 2 &&
            _pathFromTokenBToEth.length >= 2,
            "TN"
        );

        uint256 allowance = LPToken.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowance < amount) {
            require(LPToken.approve(address(SwapRouter), amount), "FS");
        }

        (uint256 tokenABalance, uint256 tokenBBalance) = SwapRouter
            .removeLiquidity(
                address(TokenA),
                address(TokenB),
                amount,
                1,
                1,
                address(this),
                block.timestamp + 1
            );

        uint256 allowanceA = TokenA.allowance(
                address(this),
                address(SwapRouter)
            );
        if (allowanceA < tokenABalance) {
            require(TokenA.approve(address(SwapRouter), tokenABalance), "FS");
        }

        uint256 tokenAEth = SwapRouter.swapExactTokensForETH(
            tokenABalance,
            1,
            _pathFromTokenAToEth,
            payable(msg.sender),
            block.timestamp + 1
        )[_pathFromTokenAToEth.length - 1];

        uint256 allowanceB = TokenB.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowanceB < tokenBBalance) {
            require(TokenB.approve(address(SwapRouter), tokenBBalance), "FS");
        }

        // Convert Token B into ETH
        uint256 tokenBEth = SwapRouter.swapExactTokensForETH(
            tokenBBalance,
            1,
            _pathFromTokenBToEth,
            payable(msg.sender),
            block.timestamp + 1
        )[_pathFromTokenBToEth.length - 1];

        return tokenAEth + tokenBEth;
    }

    /// @notice Converts lp tokens back to bnbs for a BNB token liquidity pool. First removes liquidity using the lp tokens and then swaps the token to bnb and sends the swapped bnb plus the provided bnb
    /// @dev No slippage implemented at this time
    /// @param amount The amount in lp tokens to be converted into bnbs
    /// @param token The token that is one side of the bnb-token liquidity pool
    /// @return ethAmount The total amount of bnbs that were received from the swaps
    function convertTokenLpToEth(address token, uint256 amount)
    public
    override
    whenNotPaused
    returns(uint256 ethAmount)
    {
        address lpToken = IUniswapV2Factory(SwapRouter.factory()).getPair(
        token,
        SwapRouter.WETH()
    );

        IUniswapV2Pair LPToken = IUniswapV2Pair(lpToken);

        IERC20Upgradeable(lpToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        IERC20Upgradeable Token = IERC20Upgradeable(token);

        address[] memory _pathFromTokenToEth = pathFromTokenToEth[
            address(Token)
        ];

        require(_pathFromTokenToEth.length >= 2, "TN");

        uint256 allowanceLP = LPToken.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowanceLP < amount) {
            require(LPToken.approve(address(SwapRouter), amount), "FS");
        }

        (uint256 tokenBalance, uint256 ethBalance) = SwapRouter
            .removeLiquidityETH(
                token,
                amount,
                1,
                1,
                address(this),
                block.timestamp + 1
            );

        uint256 allowance = Token.allowance(address(this), address(SwapRouter));
        if (allowance < tokenBalance) {
            require(Token.approve(address(SwapRouter), tokenBalance), "FS");
        }

        uint256 tokenEth = SwapRouter.swapExactTokensForETH(
            tokenBalance,
            1,
            _pathFromTokenToEth,
            payable(msg.sender),
            block.timestamp + 1
        )[_pathFromTokenToEth.length - 1];

        (bool transferSuccess, ) = payable(msg.sender).call{ value: ethBalance } (
            ""
        );
        require(transferSuccess, "TF");

        return tokenEth + ethBalance;
    }

    /// @notice Converts bnbs to a specific token
    /// @dev No slippage implemented at this time. BNB needs to be provided as value.
    /// @param token The token address to which bnbs should be converted
    /// @return tokenAmount The amount of tokens received
    function convertEthToToken(address token)
    external
    payable
    override
    whenNotPaused
    returns(uint256 tokenAmount)
    {
        address[] memory _pathFromEthToToken = pathFromEthToToken[token];
        require(_pathFromEthToToken.length >= 2, "TN");
        tokenAmount = SwapRouter.swapExactETHForTokens{ value: msg.value } (
            1,
            _pathFromEthToToken,
            msg.sender,
            block.timestamp + 1
        )[_pathFromEthToToken.length - 1];
    }

    /// @notice Converts a specific token to bnbs
    /// @dev No slippage implemented at this time
    /// @param amount The amount of tokens to be converted
    /// @param token The token address which should be converted to bnbs
    /// @return ethAmount The amount of bnbs received
    function convertTokenToEth(uint256 amount, address token)
    external
    override
    whenNotPaused
    returns(uint256 ethAmount)
    {
        address[] memory _pathFromTokenToEth = pathFromTokenToEth[token];
        require(_pathFromTokenToEth.length >= 2, "TN");

        IERC20Upgradeable tokenInstance = IERC20Upgradeable(token);
        tokenInstance.safeTransferFrom(msg.sender, address(this), amount);

        uint256 allowance = tokenInstance.allowance(
            address(this),
            address(SwapRouter)
        );
        if (allowance < amount) {
            require(tokenInstance.approve(address(SwapRouter), amount), "FS");
        }

        ethAmount = SwapRouter.swapExactTokensForETH(
            amount,
            1,
            _pathFromTokenToEth,
            payable(msg.sender),
            block.timestamp + 1
        )[_pathFromTokenToEth.length - 1];
    }

    /// @notice Tells how many tokens can be bought with one bnb
    /// @param token The address of the token to get the price
    /// @return price The amount of tokens that can be bought with one bnb
    function getTokenEthPrice(address token)
    external
    view
    override
    returns(uint256)
    {
        address[] memory _pathFromEthToToken = pathFromEthToToken[token];
        require(_pathFromEthToToken.length >= 2, "TN");

        return
        SwapRouter.getAmountsOut(1e18, _pathFromEthToToken)[
            _pathFromEthToToken.length - 1
        ];
    }

    /// @notice Gets the total pending reward from pancakeswap master chef
    /// @return pendingReward The total pending reward for the lp staking
    function totalPendingReward(uint256 poolID)
    external
    view
    override
    returns(uint256)
    {
        address lpToken = StakingContract.lpToken(poolID);

        IUniswapV2Pair LPToken = IUniswapV2Pair(lpToken);

        IERC20Upgradeable TokenA = IERC20Upgradeable(LPToken.token0());

        IERC20Upgradeable TokenB = IERC20Upgradeable(LPToken.token1());

        require(
            pathFromEthToToken[address(TokenA)].length >= 2 &&
            pathFromEthToToken[address(TokenB)].length >= 2,
            "TN"
        );

        IERC20Upgradeable RewardToken = IERC20Upgradeable(
            StakingContract.CAKE()
        );

        uint256 pendingRewardToken = StakingContract.pendingCake(
            poolID,
            msg.sender
        );

        if (pendingRewardToken == 0) return 0;

        address[] memory pairsTokenA = new address[](
            pathFromEthToToken[address(TokenA)].length + 1
        );

        pairsTokenA[0] = address(RewardToken);

        for (
            uint256 i = 1;
            i <= pathFromEthToToken[address(TokenA)].length;
        i++
        ) {
            pairsTokenA[i] = pathFromEthToToken[address(TokenA)][i - 1];
        }

        uint256 tokenAValue = SwapRouter.getAmountsOut(
            pendingRewardToken / 2,
            pairsTokenA
        )[2];

        address[] memory pairsTokenB = new address[](
            pathFromEthToToken[address(TokenB)].length + 1
        );

        pairsTokenB[0] = address(RewardToken);

        for (
            uint256 i = 1;
            i <= pathFromEthToToken[address(TokenB)].length;
        i++
        ) {
            pairsTokenB[i] = pathFromEthToToken[address(TokenB)][i - 1];
        }

        uint256 tokenBValue = SwapRouter.getAmountsOut(
            pendingRewardToken / 2,
            pairsTokenB
        )[2];

        (uint256 reserveA, uint256 reserveB, ) = LPToken.getReserves();

        if (reserveA == 0 || reserveB == 0) return 0;

        uint256 lpValueA = (tokenAValue * LPToken.totalSupply()) / reserveA;
        uint256 lpValueB = (tokenBValue * LPToken.totalSupply()) / reserveB;

        return lpValueA < lpValueB ? lpValueA : lpValueB;
    }

    /// @notice Gets the total staked amount from pancakeswap master chef
    /// @return amount The currently total staked amount in lp tokens
    function totalStakedAmount(uint256 poolID)
    external
    view
    override
    returns(uint256)
    {
        (uint256 amount,,) = StakingContract.userInfo(poolID, msg.sender);
        return amount;
    }

    /// @notice Checks if the current price is within the slippage tolerance compared to the quoted price
    /// @dev Item order in the lists is critical. All lists must have the same length, otherwise the call revers. Reverts if splippage tolerance is not met
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    function checkSlippage(
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage
    ) external view override {
        require(
            fromToken.length == toToken.length &&
            fromToken.length == amountIn.length &&
            fromToken.length == amountOut.length,
            "IS"
        );
        require(slippage <= MAX_PERCENTAGE, "MP");

        address[] memory pairs = new address[](2);

        for (uint256 i = 0; i < fromToken.length; i++) {
            pairs[0] = fromToken[i];
            pairs[1] = toToken[i];
            uint256 currentAmoutOut = SwapRouter.getAmountsOut(
                amountIn[i],
                pairs
            )[1];
            require(
                ((MAX_PERCENTAGE - slippage) * amountOut[i]) / MAX_PERCENTAGE <
                currentAmoutOut,
                "SH"
            );
        }
    }

    /// @notice Used to recover remainder funds that are stuck
    function recoverFunds()
    external
    override
    nonReentrant
    onlyRole(FUNDS_RECOVERY_ROLE)
    {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool transferSuccess, ) = payable(msg.sender).call{ value: balance } (
                ""
            );
            require(transferSuccess, "TF");
        }
    }

    /// @notice Sets the swapping path for a token
    /// @dev Requires non zero address for token and a swap path to eth and from eth with length >= 2, only updater role can set these variables
    /// @param token The token address for which the path is set
    /// @param pathFromEth The swapping path when converting from eth to token
    /// @param pathToEth The swapping path when converting from token to eth
    function setSwapPathForToken(
        address token,
        address[] memory pathFromEth,
        address[] memory pathToEth
    ) public onlyRole(UPDATER_ROLE) {
        require(token != address(0), "TA");
        require(pathFromEth.length >= 2, "PI");
        require(pathToEth.length >= 2, "PI");
        require(pathFromEth[0] == SwapRouter.WETH(), "FW");
        require(pathFromEth[pathFromEth.length - 1] == token, "LT");
        require(pathToEth[0] == token, "FP");
        require(pathToEth[pathToEth.length - 1] == SwapRouter.WETH(), "LW");
        pathFromEthToToken[token] = pathFromEth;
        pathFromTokenToEth[token] = pathToEth;
    }

    /// @notice Sets the swapping path for a token with bulk
    /// @dev Take care of out of gas issues as there is a for loop over the input arrays, each index of the tokens array needs to be corresponding to the same index in the paths array
    /// @param tokens The token addresses for which the paths are set
    /// @param pathsFromEth The swapping paths from eth to token according to Uniswap paths
    /// @param pathsToEth The swapping paths from token to eth according to Uniswap paths
    function setSwapPathForTokenBulk(
        address[] memory tokens,
        address[][] memory pathsFromEth,
        address[][] memory pathsToEth
    ) external onlyRole(UPDATER_ROLE) {
        require(
            tokens.length == pathsFromEth.length &&
            tokens.length == pathsToEth.length,
            "AS"
        );
        for (uint256 i = 0; i < tokens.length; i++) {
            setSwapPathForToken(tokens[i], pathsFromEth[i], pathsToEth[i]);
        }
    }

    /// @notice Returns full path array from ETH to Token
    /// @param token The token addresses for which the path is to be returned
    function getPathArrayEthToToken(address token)
    external
    view
    returns(address[] memory)
    {
        return pathFromEthToToken[token];
    }

    /// @notice Returns full path array from Token to ETH
    /// @param token The token addresses for which the path is to be returned
    function getPathArrayTokenToEth(address token)
    external
    view
    returns(address[] memory)
    {
        return pathFromTokenToEth[token];
    }

    uint256[50] private __gap;
}


// File contracts/Interfaces/IStakingPool.sol

 
pragma solidity ^ 0.8.4;

interface IStakingPool {
    function stakerAmounts(address staker)
external
view
returns(
    uint256 stakedAmount,
    uint256 honeyMask,
    uint256 lpMask,
    uint256 pendingLp,
    uint256 claimedHoney,
    uint256 claimedLp,
    uint256 honeyMintMask,
    uint256 pendingHoneyMint,
    uint256 claimedHoneyMint
);

function stake(uint256 amount) external;

function unstake(uint256 amount) external;

function balanceOf(address staker) external view returns(uint256);

function lpBalanceOf(address staker) external view returns(uint256);

function rewardHoney(uint256 amount) external;

function rewardLP(uint256 amount) external;

function claimLpTokens(
    uint256 amount,
    uint256 additionalHoneyAmount,
    address to
) external returns(uint256 stakedTokenOut, uint256 bnbOut);

function updateLpRewardMask() external;

function updateAdditionalMintRoundMask() external;

function getPendingHoneyRewards() external view returns(uint256);

function getHoneyMintRewardsInRange(uint256 fromBlock, uint256 toBlock)
external
view
returns(uint256);

function setHoneyMintingRewards(
    uint256 _blockRewardPhase1End,
    uint256 _blockRewardPhase2Start,
    uint256 _blockRewardPhase1Amount,
    uint256 _blockRewardPhase2Amount
) external;
}


// File contracts/Interfaces/IReferral.sol

 
pragma solidity ^ 0.8.4;

interface IReferral {
    function totalReferralDepositForPool(address _poolAddress)
external
view
returns(uint256);

function referralDeposit(
    uint256 _amount,
    address _referralRecipient,
    address _referralGiver
) external;

function referralWithdraw(uint256 _amount, address _referralRecipient)
external;

function getReferralRewards(address _poolAddress, address _referralGiver)
external
view
returns(uint256);

function withdrawReferralRewards(uint256 _amount, address _poolAddress)
external;

function withdrawAllReferralRewards(address[] memory _poolAddress)
external
returns(uint256);

function referralUpdateRewards(uint256 _rewardedAmount) external;

function getExpericencePoints(address _from)
external
view
returns(uint256 points);

function getLevel(address _from) external view returns(uint256 level);
}


// File contracts/Interfaces/IAveragePriceOracle.sol

 
pragma solidity ^ 0.8.4;

interface IAveragePriceOracle {
    function getAverageHoneyForOneEth()
external
view
returns(uint256 amountOut);

function updateHoneyEthPrice() external;
}


// File contracts/Config/BaseConfig.sol

 
pragma solidity ^ 0.8.4;
/// @title Base config for grizzly contract
/// @notice This contract contains all external addresses and dependencies for the grizzly contract. It also approves dependent contracts to spend tokens on behalf of grizzly.sol
/// @dev The contract grizzly.sol inherits this contract to have all dependencies available. This contract is always inherited and never deployed alone
abstract contract BaseConfig is
Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
        // the role that allows updating parameters
        bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant FUNDS_RECOVERY_ROLE =
        keccak256("FUNDS_RECOVERY_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant MAX_PERCENTAGE = 100000;
    uint256 public constant DECIMAL_OFFSET = 10e12;

    IUniswapV2Pair public LPToken;
    IMasterChef public StakingContract;
    IStakingPool public StakingPool;
    IHoney public HoneyToken;
    IERC20Upgradeable public HoneyBnbLpToken;
    IERC20Upgradeable public RewardToken;
    IERC20Upgradeable public TokenA;
    IERC20Upgradeable public TokenB;
    IReferral public Referral;
    IAveragePriceOracle public AveragePriceOracle;
    IDEX public DEX;
    uint256 public PoolID;
    address public DevTeam;

    function __BaseConfig_init(
        address _Admin,
        address _StakingContractAddress,
        address _StakingPoolAddress,
        address _HoneyTokenAddress,
        address _HoneyBnbLpTokenAddress,
        address _DevTeamAddress,
        address _ReferralAddress,
        address _AveragePriceOracleAddress,
        address _DEXAddress,
        uint256 _PoolID
    ) internal {
        _grantRole(DEFAULT_ADMIN_ROLE, _Admin);

        StakingContract = IMasterChef(_StakingContractAddress);
        StakingPool = IStakingPool(_StakingPoolAddress);
        HoneyToken = IHoney(_HoneyTokenAddress);
        HoneyBnbLpToken = IERC20Upgradeable(_HoneyBnbLpTokenAddress);
        Referral = IReferral(_ReferralAddress);
        AveragePriceOracle = IAveragePriceOracle(_AveragePriceOracleAddress);
        DEX = IDEX(_DEXAddress);

        DevTeam = _DevTeamAddress;
        PoolID = _PoolID;

        address lpToken = StakingContract.lpToken(PoolID);

        LPToken = IUniswapV2Pair(lpToken);

        TokenA = IERC20Upgradeable(LPToken.token0());

        TokenB = IERC20Upgradeable(LPToken.token1());

        RewardToken = IERC20Upgradeable(StakingContract.CAKE());

        IERC20Upgradeable(address(LPToken)).safeApprove(
            address(StakingContract),
            type(uint256).max
        );

        IERC20Upgradeable(address(RewardToken)).safeApprove(
            address(DEX),
            type(uint256).max
        );

        IERC20Upgradeable(address(LPToken)).safeApprove(
            address(DEX),
            type(uint256).max
        );

        IERC20Upgradeable(address(HoneyToken)).safeApprove(
            address(StakingPool),
            type(uint256).max
        );
        IERC20Upgradeable(address(HoneyToken)).safeApprove(
            address(Referral),
            type(uint256).max
        );
        IERC20Upgradeable(address(HoneyBnbLpToken)).safeApprove(
            address(StakingPool),
            type(uint256).max
        );
    }

    function isNotPaused() internal {
        require(!paused(), "PS");
    }

    function isPaused() internal {
        require(paused(), "NP");
    }

    uint256[50] private __gap;
}


// File contracts/Strategy/GrizzlyStrategy.sol

 
pragma solidity ^ 0.8.4;
/// @title Grizzly strategy handler
/// @notice The contract keeps track of the liquidity pool balances, of the GHNY staking pool lp tokens and the GHNY staking pool honey rewards of a grizzly strategy investor using EIP-1973
/// @dev This contract is abstract and is intended to be inherited by grizzly.sol. Honey and lp rewards are handled using round masks
abstract contract GrizzlyStrategy is Initializable, BaseConfig {
    using SafeERC20Upgradeable for IERC20Upgradeable;

        struct GrizzlyStrategyParticipant {
        uint256 amount;
        uint256 honeyMask;
        uint256 pendingHoney;
        uint256 lpMask;
        uint256 pendingLp;
        uint256 pendingAdditionalHoney;
        uint256 additionalHoneyMask;
    }

    uint256 public grizzlyStrategyDeposits;

    uint256 public grizzlyStrategyLastHoneyBalance;
    uint256 public grizzlyStrategyLastLpBalance;
    uint256 public grizzlyStrategyLastAdditionalHoneyBalance;

    uint256 private honeyRoundMask;
    uint256 private lpRoundMask;
    uint256 private additionalHoneyRoundMask;

    event GrizzlyStrategyClaimHoneyEvent(
        address indexed user,
        uint256 honeyAmount
    );
    event GrizzlyStrategyClaimLpEvent(
        address indexed user,
        uint256 honeyAmount,
        uint256 bnbAmount
    );

    mapping(address => GrizzlyStrategyParticipant) private participantData;

    function __GrizzlyStrategy_init() internal initializer {
        honeyRoundMask = 1;
        lpRoundMask = 1;
        additionalHoneyRoundMask = 1;
    }

    /// @notice Deposits the desired amount for a grizzly strategy investor
    /// @dev User masks are updated before the deposit to have a clean state
    /// @param amount The desired deposit amount for an investor
    function grizzlyStrategyDeposit(uint256 amount) internal {
        updateUserMask();
        participantData[msg.sender].amount += amount;
        grizzlyStrategyDeposits += amount;
    }

    /// @notice Withdraws the desired amount for a grizzly strategy investor
    /// @dev User masks are updated before the deposit to have a clean state
    /// @param amount The desired withdraw amount for an investor
    function grizzlyStrategyWithdraw(uint256 amount) internal {
        require(amount > 0, "TZ");
        require(amount <= getGrizzlyStrategyBalance(), "SD");

        updateUserMask();
        participantData[msg.sender].amount -= amount;
        grizzlyStrategyDeposits -= amount;
    }

    /// @notice Stakes the honey rewards into the honey staking pool
    /// @param amount The honey reward to be staked
    function grizzlyStrategyStakeHoney(uint256 amount) internal {
        StakingPool.stake(amount);
    }

    /// @notice Updates the round mask for the honey and lp rewards
    /// @dev The honey and lp rewards are requested from the GHNY staking pool for the whole contract
    function updateRoundMasks() public {
        isNotPaused();
        if (grizzlyStrategyDeposits == 0) return;

        // In order to keep track of how many new tokens were rewarded to this contract, we need to take
        // into account claimed tokens as well, otherwise the balance will become lower than "last balance"
        (
            ,
            ,
            ,
            ,
            uint256 claimedHoney,
                uint256 claimedLp,
            ,
            ,
                    uint256 claimedAdditionalHoney
        ) = StakingPool.stakerAmounts(address(this));

        uint256 newHoneyTokens = claimedHoney +
            StakingPool.balanceOf(address(this)) -
            grizzlyStrategyLastHoneyBalance;
        uint256 newLpTokens = claimedLp +
            StakingPool.lpBalanceOf(address(this)) -
            grizzlyStrategyLastLpBalance;
        uint256 newAdditionalHoneyTokens = claimedAdditionalHoney +
            StakingPool.getPendingHoneyRewards() -
            grizzlyStrategyLastAdditionalHoneyBalance;

        grizzlyStrategyLastHoneyBalance += newHoneyTokens;
        grizzlyStrategyLastLpBalance += newLpTokens;
        grizzlyStrategyLastAdditionalHoneyBalance += newAdditionalHoneyTokens;

        honeyRoundMask +=
            (DECIMAL_OFFSET * newHoneyTokens) /
            grizzlyStrategyDeposits;
        lpRoundMask += (DECIMAL_OFFSET * newLpTokens) / grizzlyStrategyDeposits;
        additionalHoneyRoundMask +=
            (DECIMAL_OFFSET * newAdditionalHoneyTokens) /
            grizzlyStrategyDeposits;
    }

    /// @notice Updates the user round mask for the honey and lp rewards
    function updateUserMask() internal {
        updateRoundMasks();

        participantData[msg.sender].pendingHoney +=
            ((honeyRoundMask - participantData[msg.sender].honeyMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender].honeyMask = honeyRoundMask;

        participantData[msg.sender].pendingLp +=
            ((lpRoundMask - participantData[msg.sender].lpMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender].lpMask = lpRoundMask;

        participantData[msg.sender].pendingAdditionalHoney +=
            ((additionalHoneyRoundMask -
                participantData[msg.sender].additionalHoneyMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender]
            .additionalHoneyMask = additionalHoneyRoundMask;
    }

    /// @notice Claims the staked honey for an investor. The investors honnies are first unstaked from the GHNY staking pool and then transfered to the investor.
    /// @dev The investors honey mask is updated to the current honey round mask and the pending honeies are paid out
    /// @dev Can be called static to get the current investors pending Honey
    /// @return the pending Honey
    function grizzlyStrategyClaimHoney() public returns(uint256) {
        isNotPaused();
        updateRoundMasks();
        uint256 pendingHoney = participantData[msg.sender].pendingHoney +
            ((honeyRoundMask - participantData[msg.sender].honeyMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender].honeyMask = honeyRoundMask;

        if (pendingHoney > 0) {
            participantData[msg.sender].pendingHoney = 0;
            StakingPool.unstake(pendingHoney);

            IERC20Upgradeable(address(HoneyToken)).safeTransfer(
                msg.sender,
                pendingHoney
            );
        }
        emit GrizzlyStrategyClaimHoneyEvent(msg.sender, pendingHoney);
        return pendingHoney;
    }

    /// @notice Claims the staked lp tokens for an investor. The investors lps are first unstaked from the GHNY staking pool and then transfered to the investor.
    /// @dev The investors lp mask is updated to the current lp round mask and the pending lps are paid out
    /// @dev Can be called static to get the current investors pending LP
    /// @return claimedHoney The claimed honey amount
    /// @return claimedBnb The claimed bnb amount
    function grizzlyStrategyClaimLP()
    public
    returns(uint256 claimedHoney, uint256 claimedBnb)
    {
        isNotPaused();
        updateRoundMasks();
        uint256 pendingLp = participantData[msg.sender].pendingLp +
            ((lpRoundMask - participantData[msg.sender].lpMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender].lpMask = lpRoundMask;

        uint256 pendingAdditionalHoney = participantData[msg.sender]
            .pendingAdditionalHoney +
            ((additionalHoneyRoundMask -
                participantData[msg.sender].additionalHoneyMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;

        participantData[msg.sender]
            .additionalHoneyMask = additionalHoneyRoundMask;

        uint256 _claimedHoney = 0;
        uint256 _claimedBnb = 0;
        if (pendingLp > 0 || pendingAdditionalHoney > 0) {
            participantData[msg.sender].pendingLp = 0;
            participantData[msg.sender].pendingAdditionalHoney = 0;
            (_claimedHoney, _claimedBnb) = StakingPool.claimLpTokens(
                pendingLp,
                pendingAdditionalHoney,
                msg.sender
            );
        }
        emit GrizzlyStrategyClaimLpEvent(
            msg.sender,
            _claimedHoney,
            _claimedBnb
        );
        return (_claimedHoney, _claimedBnb);
    }

    /// @notice Gets the current grizzly strategy balance from the liquidity pool
    /// @return The current grizzly strategy balance for the investor
    function getGrizzlyStrategyBalance() public view returns(uint256) {
        return participantData[msg.sender].amount;
    }

    /// @notice Gets the current staked honey for a grizzly strategy investor
    /// @dev Gets the current honey balance from the GHNY staking pool to calculate the current honey round mask. This is then used to calculate the total pending honey for the investor
    /// @return The current honey balance for a grizzly investor
    function getGrizzlyStrategyStakedHoney() public view returns(uint256) {
        if (
            participantData[msg.sender].honeyMask == 0 ||
            grizzlyStrategyDeposits == 0
        ) return 0;

        (, , , , uint256 claimedHoney, , , , ) = StakingPool.stakerAmounts(
            address(this)
        );

        uint256 newHoneyTokens = claimedHoney +
            StakingPool.balanceOf(address(this)) -
            grizzlyStrategyLastHoneyBalance;
        uint256 currentHoneyRoundMask = honeyRoundMask +
            (DECIMAL_OFFSET * newHoneyTokens) /
            grizzlyStrategyDeposits;

        return
        participantData[msg.sender].pendingHoney +
            ((currentHoneyRoundMask - participantData[msg.sender].honeyMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Gets the current staked lps for a grizzly strategy investor
    /// @dev Gets the current lp balance from the GHNY staking pool to calculate the current lp round mask. This is then used to calculate the total pending lp for the investor
    /// @return The current lp balance for a grizzly investor
    function getGrizzlyStrategyLpRewards() external view returns(uint256) {
        if (
            participantData[msg.sender].lpMask == 0 ||
            grizzlyStrategyDeposits == 0
        ) return 0;

        (, , , , , uint256 claimedLp, , , ) = StakingPool.stakerAmounts(
            address(this)
        );

        uint256 newLpTokens = claimedLp +
            StakingPool.lpBalanceOf(address(this)) -
            grizzlyStrategyLastLpBalance;
        uint256 currentLpRoundMask = lpRoundMask +
            (DECIMAL_OFFSET * newLpTokens) /
            grizzlyStrategyDeposits;

        return
        participantData[msg.sender].pendingLp +
            ((currentLpRoundMask - participantData[msg.sender].lpMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Reads out the participant data
    /// @param participant The address of the participant
    /// @return Participant data
    function getGrizzlyStrategyParticipantData(address participant)
    external
    view
    returns(GrizzlyStrategyParticipant memory)
    {
        return participantData[participant];
    }

    uint256[50] private __gap;
}


// File contracts/Strategy/StableCoinStrategy.sol

 
pragma solidity ^ 0.8.4;
/// @title Stablecoin strategy handler
/// @notice The contract keeps track of the balances of stablecoin strategy investors and their reinvests (rewards) using EIP-1973
/// @dev This contract is abstract and is intended to be inherited by grizzly.sol. State change functions are all internal which are called by other contracts functions
abstract contract StableCoinStrategy is Initializable, BaseConfig {
    struct StablecoinStrategyParticipant {
        uint256 amount;
        uint256 rewardMask;
        uint256 totalReinvested;
    }

    uint256 public stablecoinStrategyDeposits;
    uint256 private roundMask;

    mapping(address => StablecoinStrategyParticipant) private participantData;

    function __StableCoinStrategy_init() internal initializer {
        roundMask = 1;
    }

    /// @notice Deposits the desired amount for a stablecoin strategy investor
    /// @dev The current round mask for rewards is updated before the deposit to have a clean state
    /// @param amount The desired deposit amount for an investor
    function stablecoinStrategyDeposit(uint256 amount) internal {
        uint256 currentBalance = getStablecoinStrategyBalance();
        uint256 currentAmount = participantData[msg.sender].amount;

        participantData[msg.sender].rewardMask = roundMask;
        participantData[msg.sender].amount = currentBalance + amount;
        participantData[msg.sender].totalReinvested +=
            currentBalance -
            currentAmount;

        stablecoinStrategyDeposits += currentBalance - currentAmount + amount;
    }

    /// @notice Withdraws the desired amount for a stablecoin strategy investor
    /// @dev The current round mask for rewards is updated before the deposit to have a clean state
    /// @param amount The desired withdraw amount for an investor
    function stablecoinStrategyWithdraw(uint256 amount) internal {
        require(amount > 0, "TZ");

        uint256 currentBalance = getStablecoinStrategyBalance();
        require(amount <= currentBalance, "SD");

        uint256 currentAmount = participantData[msg.sender].amount;
        participantData[msg.sender].rewardMask = roundMask;
        participantData[msg.sender].amount = currentBalance - amount;
        participantData[msg.sender].totalReinvested +=
            currentBalance -
            currentAmount;

        stablecoinStrategyDeposits =
            stablecoinStrategyDeposits +
            currentBalance -
            currentAmount -
            amount;
    }

    /// @notice Gets the current stablecoin balance for an investor. Rewards are included too
    /// @dev Pending rewards are calculated through the difference between the current round mask and the investors rewardMask according to EIP-1973
    /// @return Current stablecoin balance
    function getStablecoinStrategyBalance() public view returns(uint256) {
        if (participantData[msg.sender].rewardMask == 0) return 0;

        return
        participantData[msg.sender].amount +
            ((roundMask - participantData[msg.sender].rewardMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Adds rewards to the contract
    /// @dev The roundmask is increased by the share of the rewarded amount such that investors get their share of pending rewards
    /// @param rewardedAmount The amount to be rewarded
    function stablecoinStrategyUpdateRewards(uint256 rewardedAmount) internal {
        if (stablecoinStrategyDeposits == 0) return;

        roundMask +=
            (DECIMAL_OFFSET * rewardedAmount) /
            stablecoinStrategyDeposits;
    }

    /// @notice Reads out the participant data
    /// @param participant The address of the participant
    /// @return Participant data
    function getStablecoinStrategyParticipantData(address participant)
    public
    view
    returns(StablecoinStrategyParticipant memory)
    {
        return participantData[participant];
    }

    uint256[50] private __gap;
}


// File contracts/Strategy/StandardStrategy.sol

 
pragma solidity ^ 0.8.4;
/// @title Standard strategy handler
/// @notice The contract keeps track of the balances of the lp tokens and their reinvests (rewards) including the honey rewards using EIP-1973
/// @dev This contract is abstract and is intended to be inherited by grizzly.sol. Honey rewards and lp rewards are handled using a round mask
abstract contract StandardStrategy is Initializable, BaseConfig {
    using SafeERC20Upgradeable for IERC20Upgradeable;

        struct StandardStrategyParticipant {
        uint256 amount;
        uint256 lpMask;
        uint256 rewardMask;
        uint256 pendingRewards;
        uint256 totalReinvested;
    }

    uint256 public lpRoundMask;
    uint256 public standardStrategyDeposits;

    uint256 public totalHoneyRewards;
    uint256 private honeyRoundMask;

    event StandardStrategyClaimHoneyEvent(
        address indexed user,
        uint256 honeyAmount
    );

    mapping(address => StandardStrategyParticipant) private participantData;

    function __StandardStrategy_init() internal initializer {
        lpRoundMask = 1;
        honeyRoundMask = 1;
    }

    /// @notice Deposits the desired amount for a standard strategy investor
    /// @dev Pending lp rewards are rewarded and the investors rewardMask is set again to the current roundMask
    /// @param amount The desired deposit amount for an investor
    function standardStrategyDeposit(uint256 amount) internal {
        updateStandardRewardMask();
        uint256 currentDeposit = getStandardStrategyBalance();
        uint256 currentAmount = participantData[msg.sender].amount;

        standardStrategyDeposits =
            standardStrategyDeposits +
            currentDeposit -
            currentAmount +
            amount;

        participantData[msg.sender].amount = currentDeposit + amount;
        participantData[msg.sender].lpMask = lpRoundMask;
        participantData[msg.sender].totalReinvested +=
            currentDeposit -
            currentAmount;
    }

    /// @notice Withdraws the desired amount for a standard strategy investor
    /// @dev Pending lp rewards are rewarded and the investors rewardMask is set again to the current roundMask
    /// @param amount The desired withdraw amount for an investor
    function standardStrategyWithdraw(uint256 amount) internal {
        require(amount > 0, "TZ");

        updateStandardRewardMask();
        uint256 currentDeposit = getStandardStrategyBalance();
        uint256 currentAmount = participantData[msg.sender].amount;
        require(amount <= currentDeposit, "SD");

        standardStrategyDeposits =
            standardStrategyDeposits +
            currentDeposit -
            currentAmount -
            amount;

        participantData[msg.sender].amount = currentDeposit - amount;
        participantData[msg.sender].lpMask = lpRoundMask;
        participantData[msg.sender].totalReinvested +=
            currentDeposit -
            currentAmount;
    }

    /// @notice Adds global lp rewards to the contract
    /// @dev The lp roundmask is increased by the share of the rewarded amount such that investors get their share of pending lp rewards
    /// @param amount The amount to be rewarded
    function standardStrategyRewardLP(uint256 amount) internal {
        if (standardStrategyDeposits == 0) return;

        lpRoundMask += (DECIMAL_OFFSET * amount) / standardStrategyDeposits;
    }

    /// @notice Gets the current standard strategy balance for an investor. Pending lp rewards are included too
    /// @dev Pending rewards are calculated through the difference between the current round mask and the investors rewardMask according to EIP-1973
    /// @return Current standard strategy balance
    function getStandardStrategyBalance() public view returns(uint256) {
        if (participantData[msg.sender].lpMask == 0) return 0;

        return
        participantData[msg.sender].amount +
            ((lpRoundMask - participantData[msg.sender].lpMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Adds global honey rewards to the contract
    /// @dev The honey roundmask is increased by the share of the rewarded amount such that investors get their share of pending honey rewards
    /// @param amount The amount of honey to be rewarded
    function standardStrategyRewardHoney(uint256 amount) internal {
        if (standardStrategyDeposits == 0) {
            return;
        }
        totalHoneyRewards += amount;
        honeyRoundMask += (DECIMAL_OFFSET * amount) / standardStrategyDeposits;
    }

    /// @notice Claims the standard strategy investors honey rewards
    /// @dev Can be called static to get the current standard strategy honey pending reward
    /// @return The pending rewards transfered to the investor
    function standardStrategyClaimHoney() public returns(uint256) {
        isNotPaused();
        updateStandardRewardMask();
        uint256 pendingRewards = participantData[msg.sender].pendingRewards;
        participantData[msg.sender].pendingRewards = 0;
        IERC20Upgradeable(address(HoneyToken)).safeTransfer(
            msg.sender,
            pendingRewards
        );
        emit StandardStrategyClaimHoneyEvent(msg.sender, pendingRewards);
        return pendingRewards;
    }

    /// @notice Gets the current standard strategy honey rewards for an investor. Pending honey rewards are included too
    /// @dev Pending rewards are calculated through the difference between the current round mask and the investors rewardMask according to EIP-1973
    /// @return Current standard strategy honey rewards
    function getStandardStrategyHoneyRewards() public view returns(uint256) {
        if (participantData[msg.sender].rewardMask == 0) return 0;

        return
        participantData[msg.sender].pendingRewards +
            ((honeyRoundMask - participantData[msg.sender].rewardMask) *
                participantData[msg.sender].amount) /
            DECIMAL_OFFSET;
    }

    /// @notice Updates the standard strategy honey rewards mask
    function updateStandardRewardMask() private {
        uint256 currentRewardBalance = getStandardStrategyHoneyRewards();
        participantData[msg.sender].pendingRewards = currentRewardBalance;
        participantData[msg.sender].rewardMask = honeyRoundMask;
    }

    /// @notice Reads out the participant data
    /// @param participant The address of the participant
    /// @return Participant data
    function getStandardStrategyParticipantData(address participant)
    public
    view
    returns(StandardStrategyParticipant memory)
    {
        return participantData[participant];
    }

    uint256[50] private __gap;
}


// File contracts/Interfaces/IGrizzly.sol

 
pragma solidity ^ 0.8.4;

interface IGrizzly {
    enum Strategy {
    STANDARD,
    GRIZZLY,
    STABLECOIN
}

function deposit(
    address referralGiver,
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external payable returns(uint256);

function depositFromToken(
    address token,
    uint256 amount,
    address referralGiver,
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external returns(uint256);

function withdraw(
    uint256 amount,
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external returns(uint256);

function withdrawAll(
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external returns(uint256);

function withdrawToToken(
    address token,
    uint256 amount,
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external returns(uint256);

function changeStrategy(
    Strategy toStrategy,
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
) external;

function stakeRewards(
    address[] memory fromToken,
    address[] memory toToken,
    uint256[] memory amountIn,
    uint256[] memory amountOut,
    uint256 slippage,
    uint256 deadline
)
external
returns(
    uint256 totalBnb,
    uint256 standardBnb,
    uint256 grizzlyBnb,
    uint256 stablecoinBnb
);

function updateBeeEfficiencyLevel(uint256 _beeEfficiencyThreshold) external;

function updateRestakeThreshold(uint256 _restakeThreshold) external;

function recoverFunds() external;
}


// File contracts/Oracle/AveragePriceOracle.sol

 
pragma solidity ^ 0.8.4;
/// @notice This oracle calculates the average price of the Honey BNB liquidity pool. The time period can be set for the average price window. The larger the price window is set, the riskier it is for an attacker to manipulate the price using e.q. a flash loan attack. However, the larger the price window, the less current the Honey-BNB price
/// @dev The amount out in Honey for one BNB is the Bee Efficiency Level (BEL).
/// @dev Implementation based on (Fixed windows): https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/building-an-oracle
contract AveragePriceOracle is
Initializable,
    IAveragePriceOracle,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    // 30 seconds average price window
    uint32 constant TIME_PERIOD = 30;
    uint224 constant Q112 = 2 ** 112;

    uint256 private blockTimestampLast;
    uint224 private honeyEthPriceAverage;
    uint256 private honeyEthCumulativeLast;
    bool private honeyIsToken0;

    IERC20Upgradeable private HoneyToken;
    IUniswapV2Pair private HoneyBnbLpToken;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    function initialize(
        address _honeyTokenAddress,
        address _honeyBnbLpToken,
        address _admin
    ) public initializer {
        require(
            IUniswapV2Pair(_honeyBnbLpToken).token0() == _honeyTokenAddress ||
            IUniswapV2Pair(_honeyBnbLpToken).token1() == _honeyTokenAddress,
            "LA"
        );
        HoneyToken = IERC20Upgradeable(_honeyTokenAddress);
        HoneyBnbLpToken = IUniswapV2Pair(_honeyBnbLpToken);
        honeyIsToken0 = HoneyBnbLpToken.token0() == _honeyTokenAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        __Pausable_init();
    }

    /// @notice pause
    /// @dev pause the contract
    function pause() external whenNotPaused onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice unpause
    /// @dev unpause the contract
    function unpause() external whenPaused onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice gets the average amount of Honey Token out for one BNB
    /// @dev uses the average price oracle to calculate the price
    /// @return amountOut the amount out in Honey Token for one BNB
    function getAverageHoneyForOneEth()
    public
    view
    override
    returns(uint256 amountOut)
    {
        return (honeyEthPriceAverage * 1e18) / Q112;
    }

    /// @notice Updates the average Honey BNB price
    /// @dev Needs to be called periodically such that the price updates. Should always be called before the average price is used. The first time called, the values are initialized.
    function updateHoneyEthPrice() external override whenNotPaused {
        (
            uint256 _price0Cumulative,
                uint256 _price1Cumulative,
                    uint32 _blockTimestamp
        ) = currentCumulativePrices(HoneyBnbLpToken);

        // initialized the first time called
        if (blockTimestampLast == 0) {
            (
                uint112 _reserve0,
                    uint112 _reserve1,
                        uint32 _blockTimestampLast
            ) = HoneyBnbLpToken.getReserves();

            if (honeyIsToken0) {
                honeyEthPriceAverage = (Q112 * _reserve0) / _reserve1;
                honeyEthCumulativeLast = _price1Cumulative;
            } else {
                honeyEthPriceAverage = (Q112 * _reserve1) / _reserve0;
                honeyEthCumulativeLast = _price0Cumulative;
            }
            blockTimestampLast = _blockTimestamp;
            return;
        }

        uint256 _timeElapsed = _blockTimestamp - blockTimestampLast;

        if (_timeElapsed >= TIME_PERIOD) {
            if (honeyIsToken0) {
                honeyEthPriceAverage = uint224(
                    (_price1Cumulative - honeyEthCumulativeLast) / _timeElapsed
                );
                honeyEthCumulativeLast = _price1Cumulative;
            } else {
                honeyEthPriceAverage = uint224(
                    (_price0Cumulative - honeyEthCumulativeLast) / _timeElapsed
                );
                honeyEthCumulativeLast = _price0Cumulative;
            }
            blockTimestampLast = _blockTimestamp;
        }
    }

    /// @notice Gets the current block timestamp in uint32 format
    /// @return The current timestamp
    function currentBlockTimestamp() internal view returns(uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    /// @notice Gets the current cumulative prices
    /// @dev This function takes the cumulative prices from the pair LP token and adds the accumulated price since the last update of the average price.
    /// @param pair The LP pair to receive the cumulative prices
    /// @return _price0Cumulative The cumulative price for token 0
    /// @return _price1Cumulative The cumulative price for token 1
    /// @return _blockTimestamp The timestamp for the respective cumulative prices
    function currentCumulativePrices(IUniswapV2Pair pair)
    internal
    view
    returns(
        uint256 _price0Cumulative,
        uint256 _price1Cumulative,
        uint32 _blockTimestamp
    )
    {
        _blockTimestamp = currentBlockTimestamp();
        _price0Cumulative = pair.price0CumulativeLast();
        _price1Cumulative = pair.price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (
            uint112 _reserve0,
                uint112 _reserve1,
                    uint32 _blockTimestampLast
        ) = pair.getReserves();
        if (_blockTimestampLast != _blockTimestamp) {
            uint32 _timeElapsed = _blockTimestamp - _blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            _price0Cumulative += uint256(
                ((Q112 * _reserve1) / _reserve0) * _timeElapsed
            );
            // counterfactual
            _price1Cumulative += uint256(
                ((Q112 * _reserve0) / _reserve1) * _timeElapsed
            );
        }
    }

    uint256[50] private __gap;
}


// File contracts/Grizzly.sol

 
pragma solidity ^ 0.8.4;
/// @title The Grizzly contract
/// @notice This contract put together all abstract contracts and is deployed once for each token pair (hive). It allows the user to deposit and withdraw funds to the predefined hive. In addition, rewards can be staked using stakeReward.
/// @dev AccessControl from openzeppelin implementation is used to handle the update of the beeEfficiency level.
/// User with DEFAULT_ADMIN_ROLE can grant UPDATER_ROLE to any address.
/// The DEFAULT_ADMIN_ROLE is intended to be a 2 out of 3 multisig wallet in the beginning and then be moved to governance in the future.
/// The Contract uses ReentrancyGuard from openzeppelin for all transactions that transfer bnbs to the msg.sender
contract Grizzly is
Initializable,
    BaseConfig,
    GrizzlyStrategy,
    StableCoinStrategy,
    StandardStrategy,
    ReentrancyGuardUpgradeable,
    IGrizzly
{
    receive() external payable { }

    using SafeERC20Upgradeable for IERC20Upgradeable;

        function initialize(
            address _Admin,
            address _StakingContractAddress,
            address _StakingPoolAddress,
            address _HoneyTokenAddress,
            address _HoneyBnbLpTokenAddress,
            address _DevTeamAddress,
            address _ReferralAddress,
            address _AveragePriceOracleAddress,
            address _DEXAddress,
            uint256 _PoolID
        ) public initializer {
        __BaseConfig_init(
            _Admin,
            _StakingContractAddress,
            _StakingPoolAddress,
            _HoneyTokenAddress,
            _HoneyBnbLpTokenAddress,
            _DevTeamAddress,
            _ReferralAddress,
            _AveragePriceOracleAddress,
            _DEXAddress,
            _PoolID
        );
        __StandardStrategy_init();
        __GrizzlyStrategy_init();
        __StableCoinStrategy_init();
        __Pausable_init();

        beeEfficiencyLevel = 500 ether;
    }

    uint256 public beeEfficiencyLevel;

    mapping(address => Strategy) public userStrategy;
    uint256 public totalUnusedTokenA;
    uint256 public totalUnusedTokenB;
    uint256 public totalRewardsClaimed;
    uint256 public totalStandardBnbReinvested;
    uint256 public totalStablecoinBnbReinvested;
    uint256 public lastStakeRewardsCall;
    uint256 public lastStakeRewardsDuration;
    uint256 public lastStakeRewardsDeposit;
    uint256 public lastStakeRewardsCake;
    uint256 public restakeThreshold;

    event DepositEvent(
        address indexed user,
        uint256 lpAmount,
        Strategy indexed currentStrategy
    );
    event WithdrawEvent(
        address indexed user,
        uint256 lpAmount,
        Strategy indexed currentStrategy
    );
    event SwitchStrategyEvent(
        address indexed user,
        Strategy indexed fromStrategy,
        Strategy indexed toStrategy
    );
    event StakeRewardsEvent(
        address indexed caller,
        uint256 bnbAmount,
        uint256 standardShare,
        uint256 grizzlyShare,
        uint256 stablecoinShare
    );

    /// @notice pause
    /// @dev pause the contract
    function pause() external onlyRole(PAUSER_ROLE) {
        isNotPaused();
        _pause();
    }

    /// @notice unpause
    /// @dev unpause the contract
    function unpause() external onlyRole(PAUSER_ROLE) {
        isPaused();
        _unpause();
    }

    /// @notice The public deposit function
    /// @dev This is a payable function where the user can deposit bnbs
    /// @param referralGiver The address of the account that provided referral
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return The value in LP tokens that was deposited
    function deposit(
        address referralGiver,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external payable override nonReentrant returns(uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        return _deposit(msg.value, referralGiver);
    }

    /// @notice The public deposit from token function
    /// @dev The user can define a token which he would like to use to deposit. This token is then firstly converted into bnbs
    /// @param token The tokens address
    /// @param amount The amount of the token to be deposited
    /// @param referralGiver The address of the account that provided referral
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return The value in LP tokens that was deposited
    function depositFromToken(
        address token,
        uint256 amount,
        address referralGiver,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external override nonReentrant returns(uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        IERC20Upgradeable TokenInstance = IERC20Upgradeable(token);
        TokenInstance.safeTransferFrom(msg.sender, address(this), amount);
        if (TokenInstance.allowance(address(this), address(DEX)) < amount) {
            TokenInstance.approve(address(DEX), amount);
        }
        uint256 amountConverted = DEX.convertTokenToEth(amount, token);
        return _deposit(amountConverted, referralGiver);
    }

    /// @notice The public withdraw function
    /// @dev Withdraws the desired amount for the user and transfers the bnbs to the user by using the call function. Adds a reentrant guard
    /// @param amount The amount of the token to be withdrawn
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return The value in BNB that was withdrawn
    function withdraw(
        uint256 amount,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external override nonReentrant returns(uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        _stakeRewards();
        uint256 amountWithdrawn = _withdraw(amount);
        _transferEth(msg.sender, amountWithdrawn);
        return amountWithdrawn;
    }

    /// @notice The public withdraw all function
    /// @dev Calculates the total staked amount in the first place and uses that to withdraw all funds. Adds a reentrant guard
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return The value in BNB that was withdrawn
    function withdrawAll(
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external override nonReentrant returns(uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        _stakeRewards();
        uint256 currentDeposits = 0;

        if (userStrategy[msg.sender] == Strategy.STANDARD) {
            currentDeposits = getStandardStrategyBalance();
        } else if (userStrategy[msg.sender] == Strategy.GRIZZLY) {
            currentDeposits = getGrizzlyStrategyBalance();
        } else {
            currentDeposits = getStablecoinStrategyBalance();
        }

        uint256 amountWithdrawn = 0;
        if (currentDeposits > 0) {
            amountWithdrawn = _withdraw(currentDeposits);
            _transferEth(msg.sender, amountWithdrawn);
        }
        return amountWithdrawn;
    }

    /// @notice The public withdraw to token function
    /// @dev The user can define a token in which he would like to withdraw the deposits. The bnb amount is converted into the token and transferred to the user
    /// @param token The tokens address
    /// @param amount The amount of the token to be withdrawn
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return The value in token amount that was withdrawn
    function withdrawToToken(
        address token,
        uint256 amount,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external override nonReentrant returns(uint256) {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        _stakeRewards();
        uint256 amountWithdrawn = _withdraw(amount);
        uint256 tokenAmountWithdrawn = DEX.convertEthToToken{
            value: amountWithdrawn
        } (token);
        IERC20Upgradeable(token).safeTransfer(msg.sender, tokenAmountWithdrawn);
        return tokenAmountWithdrawn;
    }

    /// @notice The internal deposit function
    /// @dev The actual deposit function. Bnbs are converted to lp tokens of the token pair and then staked with masterchef
    /// @param amount The amount of bnb to be deposited
    /// @param referralGiver The address of the account that provided referral
    /// @return The value in LP tokens that was deposited
    function _deposit(uint256 amount, address referralGiver)
    internal
    returns(uint256)
    {
        require(amount > 0, "DL");
        _stakeRewards();

        (uint256 lpValue, uint256 unusedTokenA, uint256 unusedTokenB) = DEX
            .convertEthToPairLP{ value: amount } (address(LPToken));

        if (unusedTokenA > 0 || unusedTokenB > 0) {
            uint256 excessAmount;
            address excessToken;

            if (unusedTokenA > 0) {
                excessAmount = unusedTokenA;
                excessToken = address(TokenA);
            } else {
                excessAmount = unusedTokenB;
                excessToken = address(TokenB);
            }

            if (excessToken == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
                _transferEth(msg.sender, excessAmount);
            } else {
                IERC20Upgradeable(excessToken).safeTransfer(
                    msg.sender,
                    excessAmount
                );
            }
        }

        if (userStrategy[msg.sender] == Strategy.STANDARD) {
            standardStrategyDeposit(lpValue);
        } else if (userStrategy[msg.sender] == Strategy.GRIZZLY) {
            grizzlyStrategyDeposit(lpValue);
        } else {
            stablecoinStrategyDeposit(lpValue);
        }

        StakingContract.deposit(PoolID, lpValue);

        Referral.referralDeposit(lpValue, msg.sender, referralGiver);
        emit DepositEvent(msg.sender, lpValue, userStrategy[msg.sender]);
        return lpValue;
    }

    /// @notice The internal withdraw function
    /// @dev The actual withdraw function. First the withdrwan from the strategy is performed and then Lp tokens are withdrawn from masterchef, converted into bnbs and returned.
    /// @param amount The amount of bnb to be withdrawn
    /// @return Amount to be withdrawn
    function _withdraw(uint256 amount) internal returns(uint256) {
        if (userStrategy[msg.sender] == Strategy.STANDARD) {
            standardStrategyWithdraw(amount);
            standardStrategyClaimHoney();
        } else if (userStrategy[msg.sender] == Strategy.GRIZZLY) {
            grizzlyStrategyWithdraw(amount);
            grizzlyStrategyClaimHoney();
            grizzlyStrategyClaimLP();
        } else {
            stablecoinStrategyWithdraw(amount);
        }

        StakingContract.withdraw(PoolID, amount);

        uint256 bnbAmount = DEX.convertPairLpToEth(address(LPToken), amount);

        Referral.referralWithdraw(amount, msg.sender);
        emit WithdrawEvent(msg.sender, amount, userStrategy[msg.sender]);
        return bnbAmount;
    }

    /// @notice Change the strategy of a user
    /// @dev When changing the strategy, the amount is withdrawn from the current strategy and deposited into the new strategy
    /// @param toStrategy the strategy the user wants to change to
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    function changeStrategy(
        Strategy toStrategy,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external override nonReentrant {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        require(userStrategy[msg.sender] != toStrategy, "UA");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);

        _stakeRewards();
        uint256 currentDeposits = 0;

        if (userStrategy[msg.sender] == Strategy.STANDARD) {
            currentDeposits = getStandardStrategyBalance();
            if (currentDeposits > 0) {
                standardStrategyWithdraw(currentDeposits);
                standardStrategyClaimHoney();
            }
        } else if (userStrategy[msg.sender] == Strategy.GRIZZLY) {
            currentDeposits = getGrizzlyStrategyBalance();
            if (currentDeposits > 0) {
                grizzlyStrategyWithdraw(currentDeposits);
                grizzlyStrategyClaimHoney();
                grizzlyStrategyClaimLP();
            }
        } else {
            currentDeposits = getStablecoinStrategyBalance();
            if (currentDeposits > 0) {
                stablecoinStrategyWithdraw(currentDeposits);
            }
        }

        if (currentDeposits > 0) {
            if (toStrategy == Strategy.STANDARD)
                standardStrategyDeposit(currentDeposits);
            else if (toStrategy == Strategy.GRIZZLY)
                grizzlyStrategyDeposit(currentDeposits);
            else stablecoinStrategyDeposit(currentDeposits);
        }

        emit SwitchStrategyEvent(
            msg.sender,
            userStrategy[msg.sender],
            toStrategy
        );
        userStrategy[msg.sender] = toStrategy;
    }

    /// @notice Stake rewards public function
    /// @dev Executes the restaking of the rewards. Adds a reentrant guard
    /// @param fromToken The list of token addresses from which the conversion is done
    /// @param toToken The list of token addresses to which the conversion is done
    /// @param amountIn The list of quoted input amounts
    /// @param amountOut The list of output amounts for each quoted input amount
    /// @param slippage The allowed slippage
    /// @param deadline The deadline for the transaction
    /// @return totalBnb The total BNB reward
    /// @return standardBnb the standard BNB reward
    /// @return grizzlyBnb the grizzly BNB reward
    /// @return stablecoinBnb the stalbcoin BNB reward
    function stakeRewards(
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    )
    external
    override
    nonReentrant
    returns(
        uint256 totalBnb,
        uint256 standardBnb,
        uint256 grizzlyBnb,
        uint256 stablecoinBnb
    )
    {
        isNotPaused();
        require(deadline > block.timestamp, "DE");
        DEX.checkSlippage(fromToken, toToken, amountIn, amountOut, slippage);
        return _stakeRewards();
    }

    /// @notice The actual internal stake rewards function
    /// @dev Executes the actual restaking of the rewards. Gets the current rewards from masterchef and divides the reward into the different strategies.
    /// Then executes the stakereward for the strategies. StakingContract.deposit(PoolID, 0); is executed in order to update the balance of the reward token
    /// @return totalBnb The total BNB reward
    /// @return standardBnb the standard BNB reward
    /// @return grizzlyBnb the grizzly BNB reward
    /// @return stablecoinBnb the stalbcoin BNB reward
    function _stakeRewards()
    internal
    returns(
        uint256 totalBnb,
        uint256 standardBnb,
        uint256 grizzlyBnb,
        uint256 stablecoinBnb
    )
    {
        // update average honey bnb price
        AveragePriceOracle.updateHoneyEthPrice();
        // Get rewards from MasterChef

        uint256 beforeAmount = RewardToken.balanceOf(address(this));
        StakingContract.deposit(PoolID, 0);
        uint256 afterAmount = RewardToken.balanceOf(address(this));
        uint256 currentRewards = afterAmount - beforeAmount;

        if (currentRewards < restakeThreshold) return (0, 0, 0, 0);

        // Store rewards for APY calculation
        lastStakeRewardsDuration = block.timestamp - lastStakeRewardsCall;
        lastStakeRewardsCall = block.timestamp;
        (lastStakeRewardsDeposit, , ) = StakingContract.userInfo(
            PoolID,
            address(this)
        );
        lastStakeRewardsCake = currentRewards;
        totalRewardsClaimed += currentRewards;

        // Convert all rewards to BNB
        uint256 bnbAmount = DEX.convertTokenToEth(
            currentRewards,
            address(RewardToken)
        );

        uint256 totalDeposits = standardStrategyDeposits +
            grizzlyStrategyDeposits +
            stablecoinStrategyDeposits;

        uint256 standardShare = 0;
        uint256 grizzlyShare = 0;
        if (totalDeposits != 0) {
            standardShare =
                (bnbAmount * standardStrategyDeposits) /
                totalDeposits;
            grizzlyShare =
                (bnbAmount * grizzlyStrategyDeposits) /
                totalDeposits;
        }
        uint256 stablecoinShare = bnbAmount - standardShare - grizzlyShare;

        if (standardShare > 100) stakeStandardRewards(standardShare);
        if (grizzlyShare > 100) stakeGrizzlyRewards(grizzlyShare);
        if (stablecoinShare > 100) stakeStablecoinRewards(stablecoinShare);

        /*if (bnbAmount > 100 && totalDeposits != 0) {
            // Get the price of Honey relative to BNB
            uint256 ghnyBnbPrice = AveragePriceOracle
                .getAverageHoneyForOneEth();
            // get 1 % of the referralDeposit totalDeposit share
            uint256 referralReward = (bnbAmount *
                Referral.totalReferralDepositForPool(address(this))) /
                totalDeposits /
                100;

            // Honey (based on Honey-BNB price) is minted
            uint256 mintedHoney = mintTokens(referralReward, ghnyBnbPrice);
            // referral contract is rewarded with the minted honey
            Referral.referralUpdateRewards(mintedHoney);
        }*/

        emit StakeRewardsEvent(
            msg.sender,
            bnbAmount,
            standardShare,
            grizzlyShare,
            stablecoinShare
        );
        return (bnbAmount, standardShare, grizzlyShare, stablecoinShare);
    }

    /// @notice Stakes the rewards for the standard strategy
    /// @param bnbReward The pending bnb reward to be restaked
    function stakeStandardRewards(uint256 bnbReward) internal {
        // 50% of the BNB is converted into TokenA-TokenB LP tokens
        uint256 tokenPairLpShare = (bnbReward * 50) / 100;
        (
            uint256 tokenPairLpAmount,
                uint256 unusedTokenA,
                    uint256 unusedTokenB
        ) = DEX.convertEthToPairLP{ value: tokenPairLpShare } (address(LPToken));

        totalStandardBnbReinvested += tokenPairLpShare;
        totalUnusedTokenA += unusedTokenA;
        totalUnusedTokenB += unusedTokenB;

        // Update TokenA-TokenB LP rewards
        standardStrategyRewardLP(tokenPairLpAmount);

        // The TokenA-TokenB LP tokens are staked in the MasterChef
        StakingContract.deposit(PoolID, tokenPairLpAmount);

        // Get the price of Honey relative to BNB
        uint256 ghnyBnbPrice = AveragePriceOracle.getAverageHoneyForOneEth();

        // If Honey price too low, use buyback strategy
        if (ghnyBnbPrice > beeEfficiencyLevel) {
            // 40% of the BNB is used to buy Honey from the DEX
            uint256 honeyBuybackShare = (bnbReward * 40) / 100;
            uint256 honeyBuybackAmount = DEX.convertEthToToken{
                value: honeyBuybackShare
            } (address(HoneyToken));

            // 10% of the equivalent amount of Honey (based on Honey-BNB price) is minted
            (uint256 mintedHoney, uint256 referralHoney) = mintTokens(
                (bnbReward * 10) / 100,
                beeEfficiencyLevel,
                (1 ether) / 100
            );

            // The purchased and minted Honey is rewarded to the Standard strategy participants
            standardStrategyRewardHoney(honeyBuybackAmount + mintedHoney);
            Referral.referralUpdateRewards(referralHoney);

            // The remaining 10% is transferred to the devs
            _transferEth(
                DevTeam,
                bnbReward - tokenPairLpShare - honeyBuybackShare
            );
        } else {
            // If Honey price is high, 40% is converted into Honey-BNB LP
            uint256 honeyBnbLpShare = (bnbReward * 40) / 100;
            (uint256 honeyBnbLpAmount, , ) = DEX.convertEthToTokenLP{
                value: honeyBnbLpShare
            } (address(HoneyToken));

            // That Honey-BNB LP is sent as reward to the Staking Pool
            StakingPool.rewardLP(honeyBnbLpAmount);

            // 50% of the equivalent amount of Honey (based on Honey-BNB price) is minted
            (uint256 mintedHoney, uint256 referralHoney) = mintTokens(
                (bnbReward * 50) / 100,
                beeEfficiencyLevel,
                (1 ether) / 100
            );

            // The minted Honey is rewarded to the Standard strategy participants
            standardStrategyRewardHoney(mintedHoney);
            Referral.referralUpdateRewards(referralHoney);

            // The remaining 10% of BNB is transferred to the devs
            _transferEth(
                DevTeam,
                bnbReward - tokenPairLpShare - honeyBnbLpShare
            );
        }
    }

    /// @notice Stakes the rewards for the grizzly strategy
    /// @param bnbReward The pending bnb reward to be restaked
    function stakeGrizzlyRewards(uint256 bnbReward) internal {
        // Get the price of Honey relative to BNB
        uint256 ghnyBnbPrice = AveragePriceOracle.getAverageHoneyForOneEth();

        // If Honey price too low, use buyback strategy
        if (ghnyBnbPrice > beeEfficiencyLevel) {
            // 90% (50% + 40%) of the BNB is used to buy Honey from the DEX
            uint256 honeyBuybackShare = (bnbReward * (50 + 40)) / 100;
            uint256 honeyBuybackAmount = DEX.convertEthToToken{
                value: honeyBuybackShare
            } (address(HoneyToken));

            // 10% of the equivalent amount of Honey (based on Honey-BNB price) is minted
            (uint256 mintedHoney, uint256 referralHoney) = mintTokens(
                (bnbReward * 10) / 100,
                beeEfficiencyLevel,
                (1 ether) / 100
            );

            // The purchased and minted Honey is staked
            grizzlyStrategyStakeHoney(honeyBuybackAmount + mintedHoney);
            Referral.referralUpdateRewards(referralHoney);

            // The remaining 6% of BNB is transferred to the devs
            _transferEth(DevTeam, bnbReward - honeyBuybackShare);
        } else {
            // If Honey price is high, 50% of the BNB is used to buy Honey from the DEX
            uint256 honeyBuybackShare = (bnbReward * 50) / 100;
            uint256 honeyBuybackAmount = DEX.convertEthToToken{
                value: honeyBuybackShare
            } (address(HoneyToken));

            // 40% of the BNB is converted into Honey-BNB LP
            uint256 honeyBnbLpShare = (bnbReward * 40) / 100;
            (uint256 honeyBnbLpAmount, , ) = DEX.convertEthToTokenLP{
                value: honeyBnbLpShare
            } (address(HoneyToken));
            // The Honey-BNB LP is provided as reward to the Staking Pool
            StakingPool.rewardLP(honeyBnbLpAmount);

            // 50% of the equivalent amount of Honey (based on Honey-BNB price) is minted
            (uint256 mintedHoney, uint256 referralHoney) = mintTokens(
                (bnbReward * 50) / 100,
                beeEfficiencyLevel,
                (1 ether) / 100
            );

            // The purchased and minted Honey is staked
            grizzlyStrategyStakeHoney(honeyBuybackAmount + mintedHoney);
            Referral.referralUpdateRewards(referralHoney);

            // The remaining 6% of BNB is transferred to the devs
            _transferEth(
                DevTeam,
                bnbReward - honeyBuybackShare - honeyBnbLpShare
            );
        }
    }

    /// @notice Stakes the rewards for the stablecoin strategy
    /// @param bnbReward The pending bnb reward to be restaked
    function stakeStablecoinRewards(uint256 bnbReward) internal {
        // 94% of the BNB is converted into TokenA-TokenB LP tokens
        uint256 pairLpShare = (bnbReward * 94) / 100;
        (uint256 pairLpAmount, uint256 unusedTokenA, uint256 unusedTokenB) = DEX
            .convertEthToPairLP{ value: pairLpShare } (address(LPToken));

        totalStablecoinBnbReinvested += pairLpShare;
        totalUnusedTokenA += unusedTokenA;
        totalUnusedTokenB += unusedTokenB;

        // The stablecoin strategy round mask is updated
        stablecoinStrategyUpdateRewards(pairLpAmount);

        // The TokenA-TokenB LP tokens are staked in the MasterChef
        StakingContract.deposit(PoolID, pairLpAmount);

        // The remaining 6% of BNB is transferred to the devs
        _transferEth(DevTeam, bnbReward - pairLpShare);
    }

    /// @notice Mints tokens according to the bee efficiency level
    /// @param _share The share that should be minted in honey
    /// @param _beeEfficiencyLevel The bee efficiency level to be uset to convert bnb shares into honey amounts
    /// @param _additionalShare The additional share tokens to be minted
    /// @return tokens The amount minted in honey tokens
    /// @return additionalTokens The additional tokens that were minted
    function mintTokens(
        uint256 _share,
        uint256 _beeEfficiencyLevel,
        uint256 _additionalShare
    ) internal returns(uint256 tokens, uint256 additionalTokens) {
        tokens = (_share * _beeEfficiencyLevel) / (1 ether);
        additionalTokens = (tokens * _additionalShare) / (1 ether);

        HoneyToken.claimTokens(tokens + additionalTokens);
    }

    /// @notice Updates the bee efficiency level
    /// @dev only updater role can perform this function
    /// @param _newBeeEfficiencyLevel The new bee efficiency level
    function updateBeeEfficiencyLevel(uint256 _newBeeEfficiencyLevel)
    external
    override
    onlyRole(UPDATER_ROLE)
    {
        beeEfficiencyLevel = _newBeeEfficiencyLevel;
    }

    /// @notice Updates the restake threshold. If the CAKE rewards are bleow this value, stakeRewards() is ignored
    /// @dev only updater role can perform this function
    /// @param _restakeThreshold The new restake threshold value
    function updateRestakeThreshold(uint256 _restakeThreshold)
    external
    override
    onlyRole(UPDATER_ROLE)
    {
        restakeThreshold = _restakeThreshold;
    }

    /// @notice Used to recover funds sent to this contract by mistake and claims unused tokens
    function recoverFunds()
    external
    override
    nonReentrant
    onlyRole(FUNDS_RECOVERY_ROLE)
    {
        if (address(TokenA) != 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
            TokenA.safeTransfer(msg.sender, totalUnusedTokenA);
        }

        if (address(TokenB) != 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
            TokenB.safeTransfer(msg.sender, totalUnusedTokenB);
        }

        totalUnusedTokenA = 0;
        totalUnusedTokenB = 0;
        _transferEth(msg.sender, address(this).balance);
    }

    /// @notice Used to get the most up-to-date state for caller's deposits. It is intended to be statically called
    /// @dev Calls stakeRewards before reading strategy-specific data in order to get the most up to-date-state
    /// @return currentStrategy - The current strategy in which the caller is in
    /// @return deposited - The amount of LP tokens deposited in the current strategy
    /// @return balance - The sum of deposited LP tokens and reinvested amounts
    /// @return totalReinvested - The total amount reinvested, including unclaimed rewards
    /// @return earnedHoney - The amount of Honey tokens earned
    /// @return earnedBnb - The amount of BNB earned
    /// @return stakedHoney - The amount of Honey tokens staked in the Staking Pool
    function getUpdatedState()
    external
    returns(
        Strategy currentStrategy,
        uint256 deposited,
        uint256 balance,
        uint256 totalReinvested,
        uint256 earnedHoney,
        uint256 earnedBnb,
        uint256 stakedHoney
    )
    {
        isNotPaused();
        _stakeRewards();
        currentStrategy = userStrategy[msg.sender];
        if (currentStrategy == Strategy.GRIZZLY) {
            deposited = getGrizzlyStrategyBalance();
            balance = deposited;
            totalReinvested = 0;
            (earnedHoney, earnedBnb) = grizzlyStrategyClaimLP();
            stakedHoney = getGrizzlyStrategyStakedHoney();
        } else if (currentStrategy == Strategy.STANDARD) {
            StandardStrategyParticipant
                memory participantData = getStandardStrategyParticipantData(
                msg.sender
            );

            deposited = participantData.amount;
            balance = getStandardStrategyBalance();
            totalReinvested =
                participantData.totalReinvested +
                balance -
                deposited;

            earnedHoney = getStandardStrategyHoneyRewards();
            earnedBnb = 0;
            stakedHoney = 0;
        } else if (currentStrategy == Strategy.STABLECOIN) {
            StablecoinStrategyParticipant
                memory participantData = getStablecoinStrategyParticipantData(
                msg.sender
            );

            deposited = participantData.amount;
            balance = getStablecoinStrategyBalance();
            totalReinvested =
                participantData.totalReinvested +
                balance -
                deposited;

            earnedHoney = 0;
            earnedBnb = 0;
            stakedHoney = 0;
        }
    }

    /// @notice payout function
    /// @dev care about non reentrant vulnerabilities
    function _transferEth(address to, uint256 amount) internal {
        (bool transferSuccess, ) = payable(to).call{ value: amount } ("");
        require(transferSuccess, "TF");
    }

    uint256[49] private __gap;
}