// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
    function isContract(address account) internal view returns (bool) {
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

        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    ) internal returns (bytes memory) {
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
    ) internal returns (bytes memory) {
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
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
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
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
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

pragma solidity >=0.5.0;

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

// Copyright (c) 2022 EG Global Ltd. All rights reserved.
// EG licenses this file to you under the MIT license.

/*

EG is a community token making a difference by maximising crypto's impact in a purposeful ecosystem.

The EG Token powers the EG Ecosystem that includes:

* Salesforce Exchange for Enterprise
* EGTrade
* EGSwap (DEX)
* EGMigrate
* Gator Gang NFT Collection
* Burn Party Platform
* Blockchain Alliance for Global Good (BAGG)
* EG Social Impact Portal
* EG Blockchain Agency
* and many more dApps & utilities to come.

 _______   _______    .___________.  ______    __  ___  _______ .__   __. 
|   ____| /  _____|   |           | /  __  \  |  |/  / |   ____||  \ |  | 
|  |__   |  |  __     `---|  |----`|  |  |  | |  '  /  |  |__   |   \|  | 
|   __|  |  | |_ |        |  |     |  |  |  | |    <   |   __|  |  . `  | 
|  |____ |  |__| |        |  |     |  `--'  | |  .  \  |  |____ |  |\   | 
|_______| \______|        |__|      \______/  |__|\__\ |_______||__| \__| 


From education initiatives to disaster relief, the EG community has 
defied the limits of an online movement by donating over $3.7 Million
in direct aid, around the world.

Learn more about EG and our Ecosystem by visting
https://www.EGToken.io

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// helper methods for discovering LP pair addresses
library PairHelper {
    bytes private constant token0Selector =
        abi.encodeWithSelector(IUniswapV2Pair.token0.selector);
    bytes private constant token1Selector =
        abi.encodeWithSelector(IUniswapV2Pair.token1.selector);

    function token0(address pair) internal view returns (address) {
        return token(pair, token0Selector);
    }

    function token1(address pair) internal view returns (address) {
        return token(pair, token1Selector);
    }

    function token(address pair, bytes memory selector)
        private
        view
        returns (address)
    {
        // Do not check if pair is not a contract to avoid warning in transaction log
        if (!isContract(pair)) return address(0);

        (bool success, bytes memory data) = pair.staticcall(selector);

        if (success && data.length >= 32) {
            return abi.decode(data, (address));
        }

        return address(0);
    }

    function isContract(address account) private view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }

        return (codehash != accountHash && codehash != 0x0);
    }
}

contract EG is IERC20Upgradeable, OwnableUpgradeable {
    using PairHelper for address;

    struct TransferDetails {
        uint112 balance0; // balance of token0
        uint112 balance1; // balance of token1
        uint32 blockNumber; // block number of  transfer
        address to; // receive address of transfer
        address origin; // submitter address of transfer
    }

    uint256 public totalSupply; // total supply

    uint8 public constant decimals = 18; // decimals of token

    string public constant name = "EG Token"; // name of token
    string public constant symbol = "EG"; // symbol of token

    IUniswapV2Router02 public uniswapV2Router; // uniswap router
    address public uniswapV2Pair; // uniswap pair

    uint256 public buyFee; // buy fee
    uint256 public sellFee; // sell fee
    uint256 public transferFee; // transfer fee

    address public marketingWallet; // marketing wallet address
    address public liquidityWallet; // liquidity wallet address
    address public techWallet; // tech wallet address
    address public donationsWallet; // donations wallet address
    address public stakingRewardsWallet; // staking rewards wallet address

    uint256 public marketingWalletFee; // marketing wallet fee
    uint256 public liquidityWalletFee; // liquidity wallet fee
    uint256 public techWalletFee; // tech wallet fee
    uint256 public donationsWalletFee; // donations wallet fee
    uint256 public stakingRewardsWalletFee; // staking rewards wallet fee

    uint256 public maxTransactionAmount; // max transaction amount, can be 0 if no limit
    uint256 public maxTransactionCoolDownAmount; // max transaction amount during cooldown

    mapping(address => uint256) private _balances; // balances of token

    mapping(address => mapping(address => uint256)) private _allowances; // allowances of token

    uint256 private constant MAX = ~uint256(0); // max uint256

    uint256 private _tradingStart; // trading start time
    uint256 private _tradingStartCooldown; // trading start time during cooldown

    uint8 private _checkingTokens; // checking tokens flag

    TransferDetails private _lastTransfer; // last transfer details

    mapping(address => uint256) private _lastCoolDownTrade; // last cooldown trade time
    mapping(address => bool) public whiteList; // white list => excluded from fee
    mapping(address => bool) public blackList; // black list => disable _transfer

    uint8 private constant _FALSE = 1;
    uint8 private constant _TRUE = 2;

    modifier tokenCheck() {
        require(_checkingTokens != _TRUE);
        _checkingTokens = _TRUE;
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _checkingTokens = _FALSE;
    }

    event TradingEnabled();
    event RouterAddressUpdated(address prevAddress, address newAddress);
    event MarketingWalletUpdated(address prevAddress, address newAddress);
    event MarketingWalletFeeUpdated(uint256 prevFee, uint256 newFee);
    event LiquidityWalletUpdated(address prevAddress, address newAddress);
    event LiquidityWalletFeeUpdated(uint256 prevFee, uint256 newFee);
    event TechWalletUpdated(address prevAddress, address newAddress);
    event TechWalletFeeUpdated(uint256 prevFee, uint256 newFee);
    event DonationsWalletUpdated(address prevAddress, address newAddress);
    event DonationsWalletFeeUpdated(uint256 prevFee, uint256 newFee);
    event StakingRewardsWalletUpdated(address prevAddress, address newAddress);
    event StakingRewardsWalletFeeUpdated(uint256 prevFee, uint256 newFee);

    event BuyFeeUpdated(uint256 prevValue, uint256 newValue);
    event SellFeeUpdated(uint256 prevValue, uint256 newValue);
    event TransferFeeUpdated(uint256 prevValue, uint256 newValue);

    event AddClientsToWhiteList(address[] account);
    event RemoveClientsFromWhiteList(address[] account);

    event WithdrawTokens(uint256 amount);
    event WithdrawAlienTokens(
        address indexed token,
        address indexed to,
        uint256 amount
    );
    event WithdrawNativeTokens(address indexed to, uint256 amount);
    event MaxTransactionAmountUpdated(uint256 prevValue, uint256 nextValue);
    event MaxTransactionCoolDownAmountUpdated(
        uint256 prevValue,
        uint256 nextValue
    );
    event AddClientsToBlackList(address[] accounts);
    event RemoveClientsFromBlackList(address[] accounts);

    /**
     * @param _routerAddress BSC MAIN 0x10ed43c718714eb63d5aa57b78b54704e256024e
     * @param _routerAddress BSC TEST 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
     **/
    function initialize(address _routerAddress) external initializer {
        require(
            _routerAddress != address(0),
            "EG: routerAddress should not be the zero address"
        );

        __Ownable_init();

        _tradingStart = MAX; // trading start time
        _tradingStartCooldown = MAX; // trading start time during cooldown

        totalSupply = 6 * 10**9 * 10**decimals; // total supply of token (6 billion)

        maxTransactionCoolDownAmount = totalSupply / 1000; // 0.1% of total supply

        _checkingTokens = _FALSE;

        buyFee = 5; // 5%
        sellFee = 5; // 5%
        transferFee = 0; // 0%

        marketingWalletFee = 20; // 20%
        liquidityWalletFee = 20; // 20%
        techWalletFee = 30; // 30%
        donationsWalletFee = 10; // 10%
        stakingRewardsWalletFee = 20; // 20%

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _routerAddress
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _balances[msg.sender] = totalSupply;

        whiteList[owner()] = true;
        whiteList[address(this)] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    /**
     * @dev Function to receive ETH when msg.data is empty
     * @dev Receives ETH from uniswapV2Router when swapping
     **/
    receive() external payable {}

    /**
     * @dev Fallback function to receive ETH when msg.data is not empty
     **/
    fallback() external payable {}

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address from, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[from][spender];
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 balance0 = _balanceOf(account);
        if (
            _lastTransfer.blockNumber == uint32(block.number) &&
            account == _lastTransfer.to
        ) {
            // Balance being checked is the same address that did the last _transfer_in
            // check if likely same transaction. If True, then it is a Liquidity Add
            _validateIfLiquidityAdd(account, uint112(balance0));
        }

        return balance0;
    }

    /**
     * @param accounts list of clients to whitelist so they do not pay tax on buy or sell
     *
     * @dev exclude a wallet from paying tax
     **/
    function addClientsToWhiteList(address[] calldata accounts)
        external
        onlyOwner
    {
        for (uint256 i; i < accounts.length; i++) {
            require(
                accounts[i] != address(0),
                "EG: Zero address can't be added to whitelist"
            );
        }

        for (uint256 i; i < accounts.length; i++) {
            if (!whiteList[accounts[i]]) {
                whiteList[accounts[i]] = true;
            }
        }

        emit AddClientsToWhiteList(accounts);
    }

    /**
     * @param accounts list of clients to remove from whitelist so they start paying tax on buy or sell
     *
     * @dev include a wallet to pay tax
     **/
    function removeClientsFromWhiteList(address[] calldata accounts)
        external
        onlyOwner
    {
        for (uint256 i; i < accounts.length; i++) {
            if (whiteList[accounts[i]]) {
                whiteList[accounts[i]] = false;
            }
        }

        emit RemoveClientsFromWhiteList(accounts);
    }

    /**
     * @param accounts list of clients to add to blacklist (trading not allowed)
     *
     * @dev add clients to blacklist
     **/
    function addClientsToBlackList(address[] calldata accounts)
        external
        onlyOwner
    {
        for (uint256 i; i < accounts.length; i++) {
            require(
                accounts[i] != address(0),
                "EG: Zero address can't be added to blacklist"
            );
        }

        for (uint256 i; i < accounts.length; i++) {
            if (!blackList[accounts[i]]) {
                blackList[accounts[i]] = true;
            }
        }

        emit AddClientsToBlackList(accounts);
    }

    /**
     * @param accounts list to remove from blacklist
     *
     * @dev remove accounts from blacklist
     **/
    function removeClientsFromBlackList(address[] calldata accounts)
        external
        onlyOwner
    {
        for (uint256 i; i < accounts.length; i++) {
            if (blackList[accounts[i]]) {
                blackList[accounts[i]] = false;
            }
        }

        emit RemoveClientsFromBlackList(accounts);
    }

    /**
     * @dev check trading enabled
     *
     **/
    function isTradingEnabled() public view returns (bool) {
        // Trading has been set and time buffer has elapsed
        return _tradingStart < block.timestamp;
    }

    /**
     * @dev check trading start cool down
     *
     **/
    function inTradingStartCoolDown() public view returns (bool) {
        // Trading has been started and the cool down period has elapsed
        return _tradingStartCooldown >= block.timestamp;
    }

    /**
     * @param to receiver address
     * @param from sender address
     *
     * @dev Multiple trades in same block from the same source are not allowed during trading start cooldown period
     **/
    function validateDuringTradingCoolDown(address to, address from) private {
        address pair = uniswapV2Pair;
        bool disallow;

        // Disallow multiple same source trades in same block
        if (from == pair) {
            disallow =
                _lastCoolDownTrade[to] == block.number ||
                _lastCoolDownTrade[msg.sender] == block.number;
            _lastCoolDownTrade[to] = block.number;
            _lastCoolDownTrade[msg.sender] = block.number;
        } else if (to == pair) {
            disallow =
                _lastCoolDownTrade[from] == block.number ||
                _lastCoolDownTrade[msg.sender] == block.number;
            _lastCoolDownTrade[from] = block.number;
            _lastCoolDownTrade[msg.sender] = block.number;
        }

        require(
            !disallow,
            "EG: Multiple trades in same block from the same source are not allowed during trading start cooldown"
        );
    }

    /**
     * @param _tradeStartDelay trade delay (uint is minute)
     * @param _tradeStartCoolDown cooldown delay (unit is minute)
     *
     * @dev This function can only be called once
     **/
    function setTradingEnabled(
        uint256 _tradeStartDelay,
        uint256 _tradeStartCoolDown
    ) external onlyOwner {
        require(
            _tradeStartDelay < 10,
            "EG: tradeStartDelay should be less than 10 minutes"
        );
        require(
            _tradeStartCoolDown < 120,
            "EG: tradeStartCoolDown should be less than 120 minutes"
        );
        require(
            _tradeStartDelay < _tradeStartCoolDown,
            "EG: tradeStartDelay must be less than tradeStartCoolDown"
        );
        // This can only be called once
        require(
            _tradingStart == MAX && _tradingStartCooldown == MAX,
            "EG: Trading has started already"
        );

        _tradingStart = block.timestamp + _tradeStartDelay * 1 minutes;
        _tradingStartCooldown = _tradingStart + _tradeStartCoolDown * 1 minutes;
        // Announce to the blockchain immediately, even though trading
        // can't start until delay passes (stop those sniping bots!)
        emit TradingEnabled();
    }

    /**
     * @param routerAddress SWAP router address
     *
     * @dev set swap router address
     **/
    function setRouterAddress(address routerAddress) external onlyOwner {
        require(
            routerAddress != address(0),
            "routerAddress should not be the zero address"
        );

        address prevAddress = address(uniswapV2Router);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        emit RouterAddressUpdated(prevAddress, routerAddress);
    }

    /**
     * @param _wallet, marketing wallet address
     *
     * @dev set Marketing Wallet Address
     **/
    function setMarketingWallet(address _wallet) external onlyOwner {
        require(
            _wallet != address(0),
            "EG: The marketing wallet should not be the zero address"
        );

        address prevAddress = marketingWallet;

        marketingWallet = _wallet;
        emit MarketingWalletUpdated(prevAddress, marketingWallet);
    }

    /**
     * @param _fee, marketing wallet fee
     *
     * @dev set Marketing Wallet fee percent
     **/
    function setMarketingWalletFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "EG: The fee should be less than 100%");

        uint256 prevFee = marketingWalletFee;

        marketingWalletFee = _fee;
        emit MarketingWalletFeeUpdated(prevFee, marketingWalletFee);
    }

    /**
     * @param _wallet, liquidity wallet address
     *
     * @dev set Liquidity Wallet Address
     **/
    function setLiquidityWallet(address _wallet) external onlyOwner {
        require(
            _wallet != address(0),
            "EG: The liquidity wallet should not be the zero address"
        );

        address prevAddress = liquidityWallet;

        liquidityWallet = _wallet;
        emit LiquidityWalletUpdated(prevAddress, liquidityWallet);
    }

    /**
     * @param _fee, liquidity wallet fee
     *
     * @dev set Liquidity Wallet fee percent
     **/
    function setLiquidityWalletFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "EG: The fee should be less than 100%");

        uint256 prevFee = liquidityWalletFee;

        liquidityWalletFee = _fee;
        emit LiquidityWalletFeeUpdated(prevFee, liquidityWalletFee);
    }

    /**
     * @param _wallet, tech wallet address
     *
     * @dev set Tech Wallet Address
     **/
    function setTechWallet(address _wallet) external onlyOwner {
        require(
            _wallet != address(0),
            "EG: The tech wallet should not be the zero address"
        );

        address prevAddress = techWallet;

        techWallet = _wallet;

        emit TechWalletUpdated(prevAddress, techWallet);
    }

    /**
     * @param _fee, tech wallet fee
     *
     * @dev set Tech Wallet fee percent
     **/
    function setTechWalletFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "EG: The fee should be less than 100%");

        uint256 prevFee = techWalletFee;

        techWalletFee = _fee;

        emit TechWalletFeeUpdated(prevFee, techWalletFee);
    }

    /**
     * @param _wallet, donation wallet address
     *
     * @dev set Donation Wallet Address
     **/
    function setDonationsWallet(address _wallet) external onlyOwner {
        require(
            _wallet != address(0),
            "EG: The donation wallet should not be the zero address"
        );

        address prevAddress = donationsWallet;

        donationsWallet = _wallet;
        emit DonationsWalletUpdated(prevAddress, donationsWallet);
    }

    /**
     * @param _fee, donation wallet fee
     *
     * @dev set Donation Wallet fee percent
     **/
    function setDonationsWalletFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "EG: The fee should be less than 100%");

        uint256 prevFee = donationsWalletFee;

        donationsWalletFee = _fee;
        emit DonationsWalletFeeUpdated(prevFee, donationsWalletFee);
    }

    /**
     * @param _wallet, staking rewards wallet address
     *
     * @dev set Staking Rewards Wallet Address
     **/
    function setStakingRewardsWallet(address _wallet) external onlyOwner {
        require(
            _wallet != address(0),
            "EG: The staking wallet should not be the zero address"
        );

        address prevAddress = stakingRewardsWallet;

        stakingRewardsWallet = _wallet;
        emit StakingRewardsWalletUpdated(prevAddress, stakingRewardsWallet);
    }

    /**
     * @param _fee, staking rewards fee
     *
     * @dev set Staking Reward Wallet fee percent
     **/
    function setStakingRewardsWalletFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "EG: The fee should be less than 100%");

        uint256 prevFee = stakingRewardsWalletFee;

        stakingRewardsWalletFee = _fee;
        emit StakingRewardsWalletFeeUpdated(prevFee, stakingRewardsWalletFee);
    }

    /**
     * @param amount Max txn amount
     *
     * @dev Max Amount allowed per Buy/Sell/Transfer transaction
     **/
    function setMaxTransactionAmount(uint256 amount) external onlyOwner {
        uint256 _prevAmount = maxTransactionAmount;
        maxTransactionAmount = amount;

        emit MaxTransactionAmountUpdated(_prevAmount, maxTransactionAmount);
    }

    /**
     * @param amount Max cooldown txn amount
     *
     * @dev Max transaction amount allowed during cooldown period
     **/
    function setMaxTransactionCoolDownAmount(uint256 amount)
        external
        onlyOwner
    {
        require(amount > 0, "EG: Amount should be a positive number.");
        if (maxTransactionAmount > 0) {
            require(
                amount < maxTransactionAmount,
                "EG: Amount should be less than maxTransactionAmount."
            );
        }

        uint256 _prevAmount = maxTransactionCoolDownAmount;
        maxTransactionCoolDownAmount = amount;

        emit MaxTransactionCoolDownAmountUpdated(
            _prevAmount,
            maxTransactionCoolDownAmount
        );
    }

    /**
     * @param _amount amount
     *
     * @dev calculate buy fee
     **/
    function calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return (_amount * buyFee) / 100;
    }

    /**
     * @param _amount amount
     *
     * @dev calculate sell fee
     **/
    function calculateSellFee(uint256 _amount) private view returns (uint256) {
        return (_amount * sellFee) / 100;
    }

    /**
     * @param _amount amount
     *
     * @dev calculate transfer fee
     **/
    function calculateTransferFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * transferFee) / 100;
    }

    /**
     * @param _buyFee. Buy fee percent (0% ~ 99%)
     *
     **/
    function setBuyFee(uint256 _buyFee) external onlyOwner {
        require(_buyFee < 100, "EG: buyFeeRate should be less than 100%");

        uint256 prevValue = buyFee;
        buyFee = _buyFee;
        emit BuyFeeUpdated(prevValue, buyFee);
    }

    /**
     * @param _sellFee. Sell fee percent (0% ~ 99%)
     *
     **/
    function setSellFee(uint256 _sellFee) external onlyOwner {
        require(_sellFee < 100, "EG: sellFeeRate should be less than 100%");

        uint256 prevValue = sellFee;
        sellFee = _sellFee;
        emit SellFeeUpdated(prevValue, sellFee);
    }

    /**
     * @param _transferFee. Transfer fee pcercent (0% ~ 99%)
     *
     **/
    function setTransferFee(uint256 _transferFee) external onlyOwner {
        require(
            _transferFee < 100,
            "EG: transferFeeRate should be less than 100%"
        );

        uint256 prevValue = transferFee;
        transferFee = _transferFee;
        emit TransferFeeUpdated(prevValue, transferFee);
    }

    /**
     * @param account receiver address of transfer
     * @param balance0 token0 balance of account
     * @dev test to see if this tx is part of a Liquidity Add not by Owner
     **/
    function _validateIfLiquidityAdd(address account, uint112 balance0)
        private
        view
    {
        // using the data recorded in _transfer
        if (_lastTransfer.origin == tx.origin) {
            // May be same transaction as _transfer, check LP balances
            address token1 = account.token1();

            if (token1 == address(this)) {
                // Switch token so token1 is always on the other side of pair
                token1 = account.token0();
            }

            // Not LP pair
            if (token1 == address(0)) return;

            uint112 balance1 = uint112(IERC20(token1).balanceOf(account));

            if (
                balance0 > _lastTransfer.balance0 &&
                balance1 > _lastTransfer.balance1
            ) {
                // Both pair balances have increased, this is a Liquidty Add
                require(false, "EG: Liquidity can be added by the owner only");
            } else if (
                balance0 < _lastTransfer.balance0 &&
                balance1 < _lastTransfer.balance1
            ) {
                // Both pair balances have decreased, this is a Liquidty Remove
                require(
                    false,
                    "EG: Liquidity can be removed by the owner only"
                );
            }
        }
    }

    function _balanceOf(address account) private view returns (uint256) {
        return _balances[account];
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(
            !blackList[from] || to == owner(), // allow blacklisted user to send token only to contract owner
            "EG: transfer from the blacklist address is not allowed"
        );
        require(
            !blackList[to],
            "EG: transfer to the blacklist address is not allowed"
        );
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        require(
            _balances[from] >= amount,
            "ERC20: tokens balance is insufficient"
        );
        require(from != to, "ERC20: Transfer to and from address are the same");
        require(
            !inTokenCheck(),
            "Invalid reentrancy from token0/token1 balanceOf check"
        );

        address _owner = owner();
        bool isIgnoredAddress = from == _owner || to == _owner;

        bool _isTradingEnabled = isTradingEnabled();

        if (!(isIgnoredAddress || whiteList[from])) {
            // allow whitelisted user to transfer unlimited tokens during cooldown.
            if (inTradingStartCoolDown()) {
                // cooldown
                require(
                    amount <= maxTransactionCoolDownAmount,
                    "EG: Transfer amount exceeds the maxTransactionCoolDownAmount"
                );
            } else if (maxTransactionAmount > 0) {
                // after cooldown
                require(
                    amount <= maxTransactionAmount,
                    "EG: Transfer amount exceeds the maxTransactionAmount"
                );
            }
        }

        address _pair = uniswapV2Pair;
        require(
            _isTradingEnabled ||
                isIgnoredAddress ||
                (from != _pair && to != _pair),
            "EG: Trading is not enabled"
        );

        if (
            _isTradingEnabled && inTradingStartCoolDown() && !isIgnoredAddress
        ) {
            validateDuringTradingCoolDown(to, from);
        }

        uint256 takeFee = 0;

        // check buy
        bool _isBuy = from == _pair;
        // check sell
        bool _isSell = to == _pair;
        // is exclude fee
        bool _isNotExcludeFee = !(whiteList[from] || whiteList[to]);

        if (_isNotExcludeFee) {
            if (_isBuy) {
                // liquidity ( buy / sell ) fee
                takeFee = calculateBuyFee(amount);
            } else if (_isSell) {
                // liquidity ( buy / sell ) fee
                takeFee = calculateSellFee(amount);
            } else {
                // transfer fee
                takeFee = calculateTransferFee(amount);
            }
        }

        if (isIgnoredAddress) {
            // Clear transfer data
            _clearTransferIfNeeded();
        } else {
            // Not in a swap during a LP add, so record the transfer details
            _recordPotentialLiquidityAddTransaction(to);
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    /**
     * @dev not a Liquidity Add or isOwner, clear data from same block to allow balanceOf
     *
     **/
    function _clearTransferIfNeeded() private {
        if (_lastTransfer.blockNumber == uint32(block.number)) {
            // Don't need to clear if different block
            _lastTransfer = TransferDetails({
                balance0: 0,
                balance1: 0,
                blockNumber: 0,
                to: address(0),
                origin: address(0)
            });
        }
    }

    /**
     * @dev record the transfer details, will be used to check LP not added by owner
     *
     **/
    function _recordPotentialLiquidityAddTransaction(address to)
        private
        tokenCheck
    {
        uint112 balance0 = uint112(_balanceOf(to));
        address token1 = to.token1();
        if (token1 == address(this)) {
            // Switch token so token1 is always other side of pair
            token1 = to.token0();
        }

        uint112 balance1;
        if (token1 == address(0)) {
            // Not a LP pair, or not yet (contract being created)
            balance1 = 0;
        } else {
            balance1 = uint112(IERC20(token1).balanceOf(to));
        }

        _lastTransfer = TransferDetails({
            balance0: balance0,
            balance1: balance1,
            blockNumber: uint32(block.number),
            to: to,
            origin: msg.sender
        });
    }

    /**
     * @param sender sender
     * @param recipient recipient
     * @param amount amount
     * @param takeFee fee
     *
     * @dev update balances of sender and receiver, add fee to contract balance
     **/
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint256 takeFee
    ) private {
        uint256 senderBefore = _balances[sender];
        uint256 senderAfter = senderBefore - amount;
        _balances[sender] = senderAfter;

        uint256 tTransferAmount = amount;

        if (takeFee > 0) {
            _balances[address(this)] = _balances[address(this)] + takeFee;
            tTransferAmount = amount - takeFee;
        }

        uint256 recipientBefore = _balances[recipient];
        uint256 recipientAfter = recipientBefore + tTransferAmount;
        _balances[recipient] = recipientAfter;

        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
     * @dev withdraw and distribute fee accumulated in smart contract to EG wallets
     **/
    function withdrawTokens() external onlyOwner {
        uint256 amount = _balanceOf(address(this));
        require(amount > 0, "EG: There are no tokens to withdraw.");
        require(
            marketingWalletFee +
                liquidityWalletFee +
                techWalletFee +
                donationsWalletFee +
                stakingRewardsWalletFee <=
                100,
            "EG: Total Fees should not be greater than 100."
        );
        require(
            marketingWallet != address(0),
            "EG: The Marketing wallet is not set."
        );
        require(
            liquidityWallet != address(0),
            "EG: The Liquidity wallet is not set."
        );
        require(techWallet != address(0), "EG: The Tech wallet is not set.");
        require(
            donationsWallet != address(0),
            "EG: The Donations wallet is not set."
        );
        require(
            stakingRewardsWallet != address(0),
            "EG: The Staking Rewards wallet is not set."
        );

        _transfer(
            address(this),
            marketingWallet,
            (amount * marketingWalletFee) / 100
        );
        _transfer(
            address(this),
            liquidityWallet,
            (amount * liquidityWalletFee) / 100
        );
        _transfer(address(this), techWallet, (amount * techWalletFee) / 100);
        _transfer(
            address(this),
            donationsWallet,
            (amount * donationsWalletFee) / 100
        );
        _transfer(
            address(this),
            stakingRewardsWallet,
            (amount * stakingRewardsWalletFee) / 100
        );

        emit WithdrawTokens(amount);
    }

    /**
     * @param token token address
     * @param to receive address
     * @param amount token amount
     *
     * @dev Withdraw any tokens that are sent to the contract address
     **/
    function withdrawAlienTokens(
        address token,
        address payable to,
        uint256 amount
    ) external onlyOwner {
        require(
            token != address(0),
            "EG: The zero address should not be a token."
        );
        require(
            to != address(0),
            "EG: The zero address should not be a transfer address."
        );
        require(
            token != address(this),
            "EG: The token should not be the same as the contract address."
        );

        require(amount > 0, "EG: Amount should be a postive number.");
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "EG: Out of balance."
        );

        IERC20(token).transfer(to, amount);

        emit WithdrawAlienTokens(token, to, amount);
    }

    /**
     * @param to receive address
     * @param amount token amount
     *
     * @dev You can withdraw native tokens (BNB) accumulated in the contract address
     **/
    function withdrawNativeTokens(address payable to, uint256 amount)
        external
        onlyOwner
    {
        require(
            to != address(0),
            "EG: The zero address should not be a transfer address."
        );
        require(amount > 0, "EG: Amount should be a postive number.");
        require(
            address(this).balance >= amount,
            "EG: Out of native token balance."
        );

        (bool success, ) = (to).call{value: amount}("");
        require(success, "EG: Withdraw failed");

        emit WithdrawNativeTokens(to, amount);
    }

    function inTokenCheck() private view returns (bool) {
        return _checkingTokens == _TRUE;
    }
}