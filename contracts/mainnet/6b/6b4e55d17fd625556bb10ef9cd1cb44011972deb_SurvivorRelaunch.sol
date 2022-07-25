/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) ||
                (!AddressUpgradeable.isContract(address(this)) &&
                    _initialized == 1),
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(
            !_initializing && _initialized < version,
            "Initializable: contract is already initialized"
        );
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

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

// File @openzeppelin/contracts-upgradeable/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts-upgradeable/security/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// File contracts/SurvivorRelaunch.sol

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IPancakeSwapPair {
    function sync() external;
}

interface IPancakeSwapRouter {
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

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IPancakeSwapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ISurvivorV1 {
    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

abstract contract SurvivorV1 is ISurvivorV1 {
    address public routerAddress;
    address public treasuryAddress;
    address public lifeLockAddress;
    address public lifeLineAddress;
    address public rationPoolAddress;
    address public jackpotAddress;
    address public burialGroundAddress;

    mapping(address => uint256) public tiers;
}

contract SurvivorRelaunch is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    IERC20MetadataUpgradeable
{
    struct Fees {
        uint256 lifeLock; // Liquidity Purchases
        uint256 lifeLine; // Buyback Fund
        uint256 treasury; // Treasury
        uint256 burialGroundAddress; // Burn Address
        uint256 rationPool; // BUSD Reflections
        uint256 jackpot; // Jackpot
    }

    Fees public buyFees;

    bool public buyFeesEnabled;

    Fees public sellFeesWeekOne;
    Fees public sellFeesWeekTwo;
    Fees public sellFeesForever;

    bool public sellFeesEnabled;

    uint256 public feeDenominator;

    uint256 private MAX_INT;
    uint256 private MAX_SHARES;

    uint256 public DECIMALS;
    uint256 private INITIAL_SUPPLY;
    uint256 private MAX_SUPPLY;
    uint256 public _totalSupply;

    address public routerAddress;
    IPancakeSwapRouter public router;

    address public treasuryAddress;
    uint256 private _pendingTreasury;
    address public lifeLockAddress;
    uint256 private _pendingLifeLock;
    address public lifeLineAddress;
    uint256 private _pendingLifeLine;
    address public rationPoolAddress;
    uint256 private _pendingRationPool;
    address public jackpotAddress;
    address public burialGroundAddress;
    address public WBNB;

    SurvivorV1 public oldToken;

    mapping(address => bool) public hasSwapped;

    uint256 private _nextToSwap; // 0 = Treasury, 1 = RationPool, 2 = LifeLine. Only swap one during any transaction to keep gas down.
    address public pair;
    IPancakeSwapPair public pairContract;

    uint8 public RATE_DECIMALS;
    uint256[11] public _rebasePcts;

    bool public autoRebaseEnabled;
    uint256 public firstRebasedTime;
    uint256 public lastRebasedTime;

    bool public autoLiquidityEnabled;
    uint256 public lastLiquidityAddedTime;

    uint256[11] private _tierShares;
    uint256[11] private _tierSupply;
    uint256[11] private _sharesPerFragment;

    mapping(address => uint256) private _shareBalances;
    mapping(address => uint256) public tiers;
    mapping(address => bool) public sold;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public mayTransfer;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    bool inSwap;

    bool launched;

    // MODIFIERS
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // CUSTOM ERRORS
    error ZeroAddressUsed();

    error NotLaunchedYet();

    error NothingToSwap();

    error NotAuthorizedToTransfer(address from, address to);

    error AlreadyWhitelisted(address wallet);

    error AlreadySold(address wallet);

    error NotEmpty(address wallet);

    error InsufficientAllowance(
        address spender,
        address from,
        address to,
        uint256 value,
        uint256 allowed
    );

    // EVENTS
    event Rebase(uint256 times, uint256 totalSupply);

    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();

        buyFees = Fees(20, 40, 50, 30, 20, 0); // 16%

        buyFeesEnabled = true;

        sellFeesWeekOne = Fees(60, 70, 60, 40, 70, 30); // 33%
        sellFeesWeekTwo = Fees(40, 50, 60, 30, 70, 30); // 28%
        sellFeesForever = Fees(40, 50, 60, 20, 30, 10); // 21%

        sellFeesEnabled = true;

        feeDenominator = 1000;

        MAX_INT = 2**256 - 1;

        DECIMALS = 5;
        INITIAL_SUPPLY = 500000 * 10**DECIMALS;
        MAX_SUPPLY = 5000000000 * 10**DECIMALS;

        MAX_SHARES = MAX_INT - (MAX_INT % MAX_SUPPLY);

        burialGroundAddress = 0x000000000000000000000000000000000000dEaD;
        oldToken = SurvivorV1(0x79EEe7769c731bCF5f215B0C1E14f4a52be00D52);
        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        RATE_DECIMALS = 7;

        _rebasePcts = [
            2368, // tier 10
            2170,
            1972,
            1775,
            1578,
            1381,
            1185,
            981,
            803,
            622, // tier 1
            2432 // "special tier" (tribal leaders)
        ];

        routerAddress = oldToken.routerAddress();
        router = IPancakeSwapRouter(routerAddress);

        treasuryAddress = oldToken.treasuryAddress();
        lifeLockAddress = oldToken.lifeLockAddress();
        lifeLineAddress = oldToken.lifeLineAddress();
        rationPoolAddress = oldToken.rationPoolAddress();
        jackpotAddress = oldToken.jackpotAddress();

        pair = IPancakeSwapFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73)
            .createPair(WBNB, address(this));
        pairContract = IPancakeSwapPair(pair);
        _allowedFragments[address(this)][routerAddress] = MAX_INT;

        lastLiquidityAddedTime = block.timestamp;
        firstRebasedTime = block.timestamp;
        lastRebasedTime = block.timestamp;
        mayTransfer[treasuryAddress] = true;
        mayTransfer[lifeLockAddress] = true;
        mayTransfer[lifeLineAddress] = true;
        mayTransfer[pair] = true;
        mayTransfer[burialGroundAddress] = true;
        mayTransfer[address(this)] = true;

        isFeeExempt[treasuryAddress] = true;
        isFeeExempt[address(this)] = true;

        _totalSupply = INITIAL_SUPPLY;
        _tierSupply[0] = INITIAL_SUPPLY;
        _tierShares[0] = MAX_SHARES;

        for (uint256 i = 0; i < 10; i++) {
            _sharesPerFragment[i] = MAX_SHARES / INITIAL_SUPPLY;
        }

        _shareBalances[address(this)] = MAX_SHARES;
        _transferFrom(
            address(this),
            treasuryAddress,
            oldToken.balanceOf(treasuryAddress)
        );
        _transferFrom(
            address(this),
            jackpotAddress,
            oldToken.balanceOf(jackpotAddress)
        );
        _transferFrom(
            address(this),
            burialGroundAddress,
            oldToken.balanceOf(burialGroundAddress)
        );
    }

    function name() public view virtual override returns (string memory) {
        return "Health Points";
    }

    function symbol() public view virtual override returns (string memory) {
        return "HP";
    }

    function decimals() public view virtual override returns (uint8) {
        return 5;
    }

    function getTier(address who) public view returns (uint256) {
        if (hasSwapped[who] || tiers[who] != 0) return tiers[who];
        return oldToken.tiers(who);
    }

    function swapV1TokensForV2() external {
        if (!launched) revert NotLaunchedYet();

        uint256 bal = oldToken.balanceOf(msg.sender);
        if (bal == 0) revert NothingToSwap();

        // burn old tokens
        oldToken.transferFrom(msg.sender, burialGroundAddress, bal);

        if (
            !hasSwapped[msg.sender] &&
            oldToken.tiers(msg.sender) > tiers[msg.sender] &&
            (!(oldToken.tiers(msg.sender) == 10 && tiers[msg.sender] > 0)) // if they have sold, do not give back tribal leader status!
        ) {
            _changeTier(msg.sender, getTier(msg.sender));
        }

        hasSwapped[msg.sender] = true;

        _transferFrom(address(this), msg.sender, bal);

        // Remaining lines will catch up on rebases for the transferred amount
        uint256 times = (block.timestamp - firstRebasedTime) / 15 minutes;

        uint256 myTier = getTier(msg.sender);

        uint256 rebasedBal = bal *
            ((((10**RATE_DECIMALS) + _rebasePcts[myTier]) /
                (10**RATE_DECIMALS))**times);

        uint256 rebaseAmt = rebasedBal - bal;

        _totalSupply += rebaseAmt;
        _tierSupply[myTier] += rebaseAmt;
        _tierShares[myTier] += rebaseAmt * _sharesPerFragment[myTier];

        _shareBalances[msg.sender] += rebaseAmt * _sharesPerFragment[myTier];
    }

    function _isTimeToRebase() internal view returns (bool) {
        // It is time to rebase when all of these are true:
        // - The autoRebaseEnabled flag is set to true
        // - Not in the middle of a swap
        // - We have not reached max supply
        // - The transaction is NOT a buy
        // - It has been at least 15 minutes since the last rebase
        return (autoRebaseEnabled &&
            !inSwap &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            block.timestamp >= (lastRebasedTime + 15 minutes));
    }

    function _rebase() internal {
        uint256 times = (block.timestamp - lastRebasedTime) / 15 minutes;

        for (uint256 nextTier = 0; nextTier < 11; nextTier++) {
            if (_tierSupply[nextTier] > 0) {
                _totalSupply -= _tierSupply[nextTier];

                _tierSupply[nextTier] *=
                    (((10**RATE_DECIMALS) + _rebasePcts[nextTier]) /
                        (10**RATE_DECIMALS)) **
                        times;

                _totalSupply += _tierSupply[nextTier];

                _sharesPerFragment[nextTier] =
                    _tierShares[nextTier] /
                    _tierSupply[nextTier];
            }
        }

        lastRebasedTime += (times * 15 minutes);

        pairContract.sync();

        emit Rebase(times, _totalSupply);
    }

    function _isTimeToAddLiquidity() internal view returns (bool) {
        // It is time to add liquidity when all of these are true:
        // - The autoLiquidityEnabled flag is set to true
        // - Not in the middle of a swap
        // - The transaction is NOT a buy
        // - The Life Lock fee pool has at least 0.01 HP
        // - It has been at least 2 days since the last liquidity add
        return (autoLiquidityEnabled &&
            !inSwap &&
            msg.sender != pair &&
            _pendingLifeLock > 100 &&
            block.timestamp >= (lastLiquidityAddedTime + 2 days));
    }

    function _addLiquidity() internal swapping {
        uint256 amountToLiquify = _pendingLifeLock / 2;
        uint256 amountToSwap = _pendingLifeLock - amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETH(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance - balanceBefore;

        router.addLiquidityETH{value: amountETHLiquidity}(
            address(this),
            amountToLiquify,
            0,
            0,
            lifeLockAddress,
            block.timestamp
        );
        lastLiquidityAddedTime = block.timestamp;
        _pendingLifeLock = 0;
    }

    function _isTimeToSwapLifeLine() internal view returns (bool) {
        return
            !inSwap &&
            msg.sender != pair &&
            _pendingLifeLine > 0 &&
            _nextToSwap == 2;
    }

    function _swapLifeLine() internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETH(
            _pendingLifeLine,
            0,
            path,
            lifeLineAddress,
            block.timestamp
        );

        _pendingLifeLine = 0;
        _nextToSwap = 0;
    }

    function _isTimeToSwapTreasury() internal view returns (bool) {
        return
            !inSwap &&
            msg.sender != pair &&
            _pendingTreasury > 0 &&
            _nextToSwap == 0;
    }

    function _swapTreasury() internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETH(
            _pendingTreasury,
            0,
            path,
            treasuryAddress,
            block.timestamp
        );

        _pendingTreasury = 0;
        _nextToSwap++;
    }

    function _isTimeToSwapRationPool() internal view returns (bool) {
        return
            !inSwap &&
            msg.sender != pair &&
            _pendingRationPool > 0 &&
            _nextToSwap == 1;
    }

    function _swapRationPool() internal swapping {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD

        router.swapExactTokensForTokens(
            _pendingRationPool,
            0,
            path,
            rationPoolAddress,
            block.timestamp
        );

        _pendingRationPool = 0;
        _nextToSwap++;
    }

    function _takeFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        if (isFeeExempt[from] || (pair != from && pair != to)) {
            return amount;
        }

        Fees memory myFees;

        if (pair == from) {
            if (!buyFeesEnabled) return amount;
            myFees = buyFees;
        }
        if (pair == to) {
            if (!sellFeesEnabled) return amount;
            uint256 timeSinceLaunch = block.timestamp - firstRebasedTime;
            if (timeSinceLaunch <= 7 days) {
                myFees = sellFeesWeekOne;
            } else if (timeSinceLaunch <= 14 days) {
                myFees = sellFeesWeekTwo;
            } else {
                myFees = sellFeesForever;
            }
        }

        uint256 thisTier = getTier(address(this));

        uint256 totalFee;

        // Life Lock - Liquidity Purchases
        uint256 lifeLockAmount = (amount * myFees.lifeLock) / feeDenominator;
        totalFee += lifeLockAmount;
        _pendingLifeLock += lifeLockAmount;

        _tierSupply[thisTier] += lifeLockAmount;
        _tierShares[thisTier] += lifeLockAmount * _sharesPerFragment[thisTier];
        _shareBalances[address(this)] +=
            lifeLockAmount *
            _sharesPerFragment[thisTier];

        // Life Line - Buyback Fund
        uint256 lifeLineAmount = (amount * myFees.lifeLine) / feeDenominator;

        totalFee += lifeLineAmount;
        _pendingLifeLine += lifeLineAmount;

        _tierSupply[thisTier] += lifeLineAmount;
        _tierShares[thisTier] += lifeLineAmount * _sharesPerFragment[thisTier];
        _shareBalances[address(this)] +=
            lifeLineAmount *
            _sharesPerFragment[thisTier];

        // Treasury
        uint256 treasuryAmount = (amount * myFees.treasury) / feeDenominator;

        totalFee += treasuryAmount;
        _pendingTreasury += treasuryAmount;

        _tierSupply[thisTier] += treasuryAmount;
        _tierShares[thisTier] += treasuryAmount * _sharesPerFragment[thisTier];
        _shareBalances[address(this)] +=
            treasuryAmount *
            _sharesPerFragment[thisTier];

        // Burial Ground - Burn Address
        uint256 burialGroundAddressAmount = (amount *
            myFees.burialGroundAddress) / feeDenominator;

        uint256 bgTier = getTier(burialGroundAddress);

        totalFee += burialGroundAddressAmount;

        _tierSupply[bgTier] += burialGroundAddressAmount;
        _tierShares[bgTier] +=
            burialGroundAddressAmount *
            _sharesPerFragment[bgTier];

        _shareBalances[burialGroundAddress] +=
            burialGroundAddressAmount *
            _sharesPerFragment[bgTier];

        // Ration Pool - BUSD Reflections
        uint256 rationPoolAmount = (amount * myFees.rationPool) /
            feeDenominator;

        totalFee += rationPoolAmount;
        _pendingRationPool += rationPoolAmount;

        _tierSupply[thisTier] += rationPoolAmount;
        _tierShares[thisTier] +=
            rationPoolAmount *
            _sharesPerFragment[thisTier];
        _shareBalances[address(this)] +=
            rationPoolAmount *
            _sharesPerFragment[thisTier];

        // Jackpot
        uint256 jackpotAmount = (amount * myFees.jackpot) / feeDenominator;

        uint256 jTier = getTier(jackpotAddress);

        totalFee += jackpotAmount;

        _tierSupply[jTier] += jackpotAmount;
        _tierShares[jTier] += jackpotAmount * _sharesPerFragment[jTier];

        _shareBalances[jackpotAddress] +=
            jackpotAmount *
            _sharesPerFragment[jTier];

        return amount - totalFee;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 sTier = getTier(sender);
        uint256 shareAmountFrom = amount * _sharesPerFragment[sTier];

        _tierSupply[sTier] -= amount;
        _tierShares[sTier] -= shareAmountFrom;
        _shareBalances[sender] -= shareAmountFrom;

        uint256 rTier = getTier(recipient);
        uint256 shareAmountTo = amount * _sharesPerFragment[rTier];

        _tierSupply[rTier] += amount;
        _tierShares[rTier] += shareAmountTo;
        _shareBalances[recipient] += shareAmountTo;
    }

    function _changeTier(address who, uint256 newTier) internal {
        uint256 oldTier = getTier(who);
        if (oldTier == newTier) return;

        uint256 balanceToMove = balanceOf(who);

        _tierSupply[oldTier] -= balanceToMove;
        _tierShares[oldTier] -= _shareBalances[who];

        tiers[who] = newTier;

        // Increase balance of the new tier
        _tierSupply[newTier] += balanceToMove;
        _shareBalances[who] = balanceToMove * _sharesPerFragment[newTier];
        _tierShares[newTier] += _shareBalances[who];
    }

    function _dropTier(address paperhand) internal {
        // Executing this code? NGMI
        uint256 oldTier = getTier(paperhand);

        if (oldTier < 9 || oldTier == 10) {
            // Tribal leaders have a tier value of 10. When they sell they go to 1 (which is called Tier 9 in the game)
            if (oldTier == 10) {
                _changeTier(paperhand, 1);
            } else {
                _changeTier(paperhand, getTier(paperhand) + 1);
            }
        }
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal whenNotPaused returns (bool) {
        if (inSwap) {
            _basicTransfer(sender, recipient, amount);
            return (true);
        }

        // Handle the case where a user is transferring ALL tokens to a new (empty, tier 10) wallet
        if (
            getTier(recipient) == 0 &&
            balanceOf(sender) == amount &&
            balanceOf(recipient) == 0
        ) {
            tiers[recipient] = getTier(sender);
            _shareBalances[recipient] = _shareBalances[sender];
            _shareBalances[sender] = 0;
            return true;
        }

        if (
            recipient == address(0) ||
            (!mayTransfer[sender] && !mayTransfer[recipient])
        ) revert NotAuthorizedToTransfer(sender, recipient);

        if (_isTimeToRebase()) _rebase();

        if (_isTimeToAddLiquidity()) _addLiquidity();

        bool _swapped;

        if (_isTimeToSwapTreasury()) {
            _swapTreasury();
            _swapped = true;
        }

        if (_isTimeToSwapRationPool() && !_swapped) {
            _swapRationPool();
            _swapped = true;
        }

        if (_isTimeToSwapLifeLine() && !_swapped) _swapLifeLine();

        uint256 sTier = getTier(sender);
        uint256 shareAmountFrom = amount * _sharesPerFragment[sTier];

        _tierSupply[sTier] -= amount;
        _tierShares[sTier] -= shareAmountFrom;
        _shareBalances[sender] -= shareAmountFrom;

        if (recipient == pair) _dropTier(sender); // this is a sell. drop tier.

        uint256 amountReceived = _takeFee(sender, recipient, amount);

        uint256 rTier = getTier(recipient);
        uint256 shareAmountTo = amountReceived * _sharesPerFragment[rTier];

        _tierSupply[rTier] += amountReceived;
        _tierShares[rTier] += shareAmountTo;
        _shareBalances[recipient] += shareAmountTo;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(burialGroundAddress);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _shareBalances[who] / _sharesPerFragment[getTier(who)];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] += addedValue;
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        whenNotPaused
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        whenNotPaused
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] -= subtractedValue;
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (_allowedFragments[from][msg.sender] != MAX_INT) {
            if (_allowedFragments[from][msg.sender] < value) {
                revert InsufficientAllowance(
                    msg.sender,
                    from,
                    to,
                    value,
                    _allowedFragments[from][msg.sender]
                );
            }
            unchecked {
                _allowedFragments[from][msg.sender] -= value;
            }
        }
        _transferFrom(from, to, value);
        return true;
    }

    function whitelist(address wallet) external onlyOwner {
        if (getTier(wallet) == 10) revert AlreadyWhitelisted(wallet);
        if (getTier(wallet) != 0) revert AlreadySold(wallet);
        if (balanceOf(wallet) != 0) revert NotEmpty(wallet);

        tiers[wallet] = 10;
    }

    function setFeeReceivers(
        address treasuryAddress_,
        address lifeLockAddress_,
        address lifeLineAddress_,
        address rationPoolAddress_,
        address jackpotAddress_
    ) external onlyOwner {
        if (
            treasuryAddress_ == address(0) ||
            lifeLockAddress_ == address(0) ||
            lifeLineAddress_ == address(0) ||
            rationPoolAddress_ == address(0) ||
            jackpotAddress_ == address(0)
        ) {
            revert ZeroAddressUsed();
        }

        treasuryAddress = treasuryAddress_;
        lifeLockAddress = lifeLockAddress_;
        lifeLineAddress = lifeLineAddress_;
        rationPoolAddress = rationPoolAddress_;
        jackpotAddress = jackpotAddress_;
    }

    function toggleRebase() external onlyOwner {
        autoRebaseEnabled = !autoRebaseEnabled;
    }

    function toggleLiquidity() external onlyOwner {
        autoLiquidityEnabled = !autoLiquidityEnabled;
    }

    function toggleBuyFees() external onlyOwner {
        buyFeesEnabled = !buyFeesEnabled;
    }

    function toggleSellFees() external onlyOwner {
        sellFeesEnabled = !sellFeesEnabled;
    }

    function toggleTransfers(address wallet) external onlyOwner {
        mayTransfer[wallet] = !mayTransfer[wallet];
    }

    function setLaunched(bool _launched) external onlyOwner {
        launched = _launched;
    }

    function setLaunchTime(uint256 launchTime) external onlyOwner {
        firstRebasedTime = launchTime;
        lastRebasedTime = launchTime;
    }
}