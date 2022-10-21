// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./interfaces/IPriceOracle.sol";
import "./interfaces/IGelatoOps.sol";

import "./pool/IPoolAdapter.sol";
import "./ProxyCaller.sol";
import "./ProxyPool.sol";
import "./PositionInfo.sol";
import "./IProxyOwner.sol";
import "./market/IMarket.sol";

contract MinimaxMain is IProxyOwner, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using ProxyPool for ProxyCaller[];

    address cakeAddress; // TODO: remove when deploy clean version

    // BUSD for BSC, USDT for POLYGON
    address public busdAddress; // TODO: rename to stableToken when deploy clean version

    address minimaxStaking;

    uint public lastPositionIndex;

    // Use mapping instead of array for upgradeability of PositionInfo struct
    mapping(uint => PositionInfo) positions;

    mapping(address => bool) isLiquidator;

    ProxyCaller[] proxyPool;

    // Fee threshold
    struct FeeThreshold {
        uint fee;
        uint stakedAmountThreshold;
    }

    FeeThreshold[] depositFees;

    /// @custom:oz-renamed-from poolAdapters
    mapping(address => IPoolAdapter) poolAdaptersDeprecated;

    mapping(IERC20Upgradeable => IPriceOracle) public priceOracles;

    // TODO: deprecated
    mapping(address => address) tokenExchanges;

    // gelato
    IGelatoOps public gelatoOps;

    address payable public gelatoPayee;

    mapping(address => uint256) gelatoLiquidateFee; // TODO: remove when deploy clean version
    uint256 liquidatorFee; // transfered to liquidator (not gelato) when `gelatoOps` is not set
    address gelatoFeeToken; // TODO: remove when deploy clean version

    // TODO: deprecated
    address defaultExchange;

    // poolAdapters by bytecode hash
    mapping(uint256 => IPoolAdapter) public poolAdapters;

    IMarket public market;

    address wrappedNative;

    address public oneInchRouter;

    // Migrate

    bool public disabled;

    mapping(address => bool) public isProxyManager;

    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function setProxyManager(address _address, bool _value) external onlyOwner {
        isProxyManager[_address] = _value;
    }

    modifier onlyProxyManager() {
        require(isProxyManager[address(msg.sender)], "onlyProxyManager");
        _;
    }

    function acquireProxy() external onlyProxyManager returns (ProxyCaller) {
        return proxyPool.acquire();
    }

    function isModernProxy(ProxyCaller proxy) public view returns (bool) {
        return address(proxy).code.length == 945;
    }

    function releaseProxy(ProxyCaller proxy) external onlyProxyManager {
        if (isModernProxy(proxy)) {
            proxyPool.release(proxy);
        }
    }

    function proxyExec(
        ProxyCaller proxy,
        bool delegate,
        address target,
        bytes calldata data
    ) external nonReentrant onlyProxyManager returns (bool success, bytes memory) {
        return proxy.exec(delegate, target, data);
    }

    function proxyTransfer(
        ProxyCaller proxy,
        address target,
        uint256 amount
    ) external nonReentrant onlyProxyManager returns (bool success, bytes memory) {
        return proxy.transfer(target, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGelatoOps {
    function createTaskNoPrepayment(
        address execAddress,
        bytes4 execSelector,
        address resolverAddress,
        bytes calldata resolverData,
        address feeToken
    ) external returns (bytes32 task);

    function cancelTask(bytes32 taskId) external;

    function getFeeDetails() external view returns (uint256, address);

    function gelato() external view returns (address payable);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolAdapter {
    function stakingBalance(address pool, bytes memory) external returns (uint256);

    function rewardBalances(address, bytes memory) external returns (uint256[] memory);

    function deposit(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdrawAll(address pool, bytes memory args) external;

    function stakedToken(address pool, bytes memory args) external returns (address);

    function rewardTokens(address pool, bytes memory args) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ProxyCaller contract is deployed frequently, and in order to reduce gas
// it has to be as small as possible
contract ProxyCaller {
    address immutable _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function exec(
        bool delegate,
        address target,
        bytes calldata data
    ) external onlyOwner returns (bool success, bytes memory) {
        if (delegate) {
            return target.delegatecall(data);
        }
        return target.call(data);
    }

    function transfer(address target, uint256 amount) external onlyOwner returns (bool success, bytes memory) {
        return target.call{value: amount}("");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProxyCaller.sol";

library ProxyPool {
    function release(ProxyCaller[] storage self, ProxyCaller proxy) internal {
        self.push(proxy);
    }

    function acquire(ProxyCaller[] storage self) internal returns (ProxyCaller) {
        if (self.length == 0) {
            return new ProxyCaller();
        }
        ProxyCaller proxy = self[self.length - 1];
        self.pop();
        return proxy;
    }

    function add(ProxyCaller[] storage self, uint amount) internal {
        for (uint i = 0; i < amount; i++) {
            self.push(new ProxyCaller());
        }
    }
}

import "./ProxyCaller.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

struct PositionInfo {
    uint stakedAmount; // wei
    uint feeAmount; // FEE_MULTIPLIER
    uint stopLossPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
    uint maxSlippage; // SLIPPAGE_MULTIPLIER
    address poolAddress;
    address owner;
    ProxyCaller callerAddress;
    bool closed;
    uint takeProfitPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
    IERC20Upgradeable stakedToken;
    IERC20Upgradeable rewardToken;
    bytes32 gelatoLiquidateTaskId; // TODO: rename to gelatoTaskId when deploy clean version
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProxyCaller.sol";

interface IProxyOwner {
    function acquireProxy() external returns (ProxyCaller);

    function releaseProxy(ProxyCaller proxy) external;

    function proxyExec(
        ProxyCaller proxy,
        bool delegate,
        address target,
        bytes calldata data
    ) external returns (bool success, bytes memory);

    function proxyTransfer(
        ProxyCaller proxy,
        address target,
        uint256 amount
    ) external returns (bool success, bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SingleMarket.sol";

interface IMarket {
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint256);

    function estimateOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256 amountOut, bytes memory hints);

    function estimateOutCustomRouters(
        IRouter[] memory routers,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256 amountOut, bytes memory hints);

    function estimateBurn(address lpToken, uint amountIn) external view returns (uint, uint);
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./ArrayHelper.sol";
import "./Hints.sol";

interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract SingleMarket is OwnableUpgradeable {
    using ArrayHelper for uint[];

    address[] public relayTokens;
    IRouter[] public defaultRouters;

    constructor() initializer {
        __Ownable_init();
    }

    function getRelayTokens() external view returns (address[] memory) {
        return relayTokens;
    }

    function setRelayTokens(address[] calldata _relayTokens) external onlyOwner {
        relayTokens = _relayTokens;
    }

    function getRouters() external view returns (IRouter[] memory) {
        return defaultRouters;
    }

    function setRouters(IRouter[] calldata _routers) external onlyOwner {
        defaultRouters = _routers;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint) {
        IERC20Upgradeable(tokenIn).transferFrom(address(msg.sender), address(this), amountIn);
        if (tokenIn == tokenOut) {
            require(amountIn >= amountOutMin, "amountOutMin");
            IERC20Upgradeable(tokenIn).transfer(destination, amountIn);
            return amountIn;
        }

        address tokenRelay = Hints.getRelay(hints, tokenIn, tokenOut);
        if (tokenRelay == address(0)) {
            address router = Hints.getRouter(hints, tokenIn, tokenOut);
            return _swapDirect(router, tokenIn, tokenOut, amountIn, amountOutMin, destination);
        }

        address routerIn = Hints.getRouter(hints, tokenIn, tokenRelay);
        address routerOut = Hints.getRouter(hints, tokenRelay, tokenOut);
        return _swapRelay(routerIn, routerOut, tokenIn, tokenRelay, tokenOut, amountIn, amountOutMin, destination);
    }

    function _swapDirect(
        address router,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination
    ) private returns (uint) {
        IERC20Upgradeable(tokenIn).approve(router, amountIn);
        return
            IRouter(router)
                .swapExactTokensForTokens({
                    amountIn: amountIn,
                    amountOutMin: amountOutMin,
                    path: ArrayHelper.new2(tokenIn, tokenOut),
                    to: destination,
                    deadline: block.timestamp
                })
                .last();
    }

    function _swapRelay(
        address routerIn,
        address routerOut,
        address tokenIn,
        address tokenRelay,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination
    ) private returns (uint) {
        if (routerIn == routerOut) {
            IERC20Upgradeable(tokenIn).approve(routerIn, amountIn);
            return
                IRouter(routerIn)
                    .swapExactTokensForTokens({
                        amountIn: amountIn,
                        amountOutMin: amountOutMin,
                        path: ArrayHelper.new3(tokenIn, tokenRelay, tokenOut),
                        to: destination,
                        deadline: block.timestamp
                    })
                    .last();
        }

        IERC20Upgradeable(tokenIn).approve(routerIn, amountIn);
        uint amountRelay = IRouter(routerIn)
            .swapExactTokensForTokens({
                amountIn: amountIn,
                amountOutMin: 0,
                path: ArrayHelper.new2(tokenIn, tokenRelay),
                to: address(this),
                deadline: block.timestamp
            })
            .last();

        IERC20Upgradeable(tokenRelay).approve(routerOut, amountRelay);
        return
            IRouter(routerOut)
                .swapExactTokensForTokens({
                    amountIn: amountRelay,
                    amountOutMin: amountOutMin,
                    path: ArrayHelper.new2(tokenRelay, tokenOut),
                    to: destination,
                    deadline: block.timestamp
                })
                .last();
    }

    function estimateOut(
        IRouter[] memory routers,
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) external view returns (uint amountOut, bytes memory hints) {
        if (routers.length == 0) {
            routers = defaultRouters;
        }

        if (tokenIn == tokenOut) {
            return (amountIn, Hints.empty());
        }

        (amountOut, hints) = _estimateOutDirect(routers, tokenIn, tokenOut, amountIn);

        for (uint i = 0; i < relayTokens.length; i++) {
            (uint attemptOut, bytes memory attemptHints) = _estimateOutRelay(
                routers,
                tokenIn,
                relayTokens[i],
                tokenOut,
                amountIn
            );
            if (attemptOut > amountOut) {
                amountOut = attemptOut;
                hints = attemptHints;
            }
        }

        require(amountOut > 0, "no estimation");
    }

    function estimateOutWithHints(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bytes memory hints
    ) external view returns (uint amountOut) {
        if (tokenIn == tokenOut) {
            return amountIn;
        }

        address relay = Hints.getRelay(hints, tokenIn, tokenOut);
        if (relay == address(0)) {
            address router = Hints.getRouter(hints, tokenIn, tokenOut);
            return _getAmountOut2(IRouter(router), tokenIn, tokenOut, amountIn);
        }

        address routerIn = Hints.getRouter(hints, tokenIn, relay);
        address routerOut = Hints.getRouter(hints, relay, tokenOut);
        if (routerIn == routerOut) {
            return _getAmountOut3(IRouter(routerIn), tokenIn, relay, tokenOut, amountIn);
        }

        uint amountRelay = _getAmountOut2(IRouter(routerIn), tokenIn, relay, amountIn);
        return _getAmountOut2(IRouter(routerOut), relay, tokenOut, amountRelay);
    }

    function _estimateOutDirect(
        IRouter[] memory routers,
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        IRouter router;
        (router, amountOut) = _optimalAmount(routers, tokenIn, tokenOut, amountIn);
        hints = Hints.setRouter(tokenIn, tokenOut, address(router));
    }

    function _estimateOutRelay(
        IRouter[] memory routers,
        address tokenIn,
        address tokenRelay,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        (IRouter routerIn, uint amountRelay) = _optimalAmount(routers, tokenIn, tokenRelay, amountIn);
        (IRouter routerOut, ) = _optimalAmount(routers, tokenRelay, tokenOut, amountRelay);

        hints = Hints.setRelay(tokenIn, tokenOut, address(tokenRelay));
        hints = Hints.merge2(hints, Hints.setRouter(tokenIn, tokenRelay, address(routerIn)));
        hints = Hints.merge2(hints, Hints.setRouter(tokenRelay, tokenOut, address(routerOut)));

        if (routerIn == routerOut) {
            amountOut = _getAmountOut3(routerIn, tokenIn, tokenRelay, tokenOut, amountIn);
        } else {
            amountOut = _getAmountOut2(routerOut, tokenRelay, tokenOut, amountRelay);
        }
    }

    function _optimalAmount(
        IRouter[] memory routers,
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (IRouter optimalRouter, uint optimalOut) {
        for (uint32 i = 0; i < routers.length; i++) {
            IRouter router = routers[i];
            uint amountOut = _getAmountOut2(router, tokenIn, tokenOut, amountIn);
            if (amountOut > optimalOut) {
                optimalRouter = routers[i];
                optimalOut = amountOut;
            }
        }
    }

    function _getAmountOut2(
        IRouter router,
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint) {
        return _getAmountSafe(router, ArrayHelper.new2(tokenIn, tokenOut), amountIn);
    }

    function _getAmountOut3(
        IRouter router,
        address tokenIn,
        address tokenMid,
        address tokenOut,
        uint amountIn
    ) private view returns (uint) {
        return _getAmountSafe(router, ArrayHelper.new3(tokenIn, tokenMid, tokenOut), amountIn);
    }

    function _getAmountSafe(
        IRouter router,
        address[] memory path,
        uint amountIn
    ) public view returns (uint output) {
        bytes memory payload = abi.encodeWithSelector(router.getAmountsOut.selector, amountIn, path);
        (bool success, bytes memory response) = address(router).staticcall(payload);
        if (success && response.length > 32) {
            return ArrayHelper.lastUint(response);
        }
        return 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ArrayHelper {
    function first(uint256[] memory arr) internal pure returns (uint256) {
        return arr[0];
    }

    function last(uint256[] memory arr) internal pure returns (uint256) {
        return arr[arr.length - 1];
    }

    // assume that b is encoded uint[]
    function lastUint(bytes memory b) internal pure returns (uint res) {
        require(b.length >= 32, "lastUint: out of range");
        uint i = b.length - 32;
        assembly {
            res := mload(add(b, add(0x20, i)))
        }
    }

    function sliceUint(bytes memory b, uint i) internal pure returns (uint res) {
        require(b.length >= i + 32, "sliceUint: out of range");
        assembly {
            res := mload(add(b, add(0x20, i)))
        }
    }

    function new2(address a0, address a1) internal pure returns (address[] memory) {
        address[] memory p = new address[](2);
        p[0] = a0;
        p[1] = a1;
        return p;
    }

    function new3(
        address a0,
        address a1,
        address a2
    ) internal pure returns (address[] memory) {
        address[] memory p = new address[](3);
        p[0] = a0;
        p[1] = a1;
        p[2] = a2;
        return p;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ArrayHelper.sol";

library Hints {
    uint8 private constant IS_PAIR = 0;
    uint8 private constant PAIR_INPUT = 1;
    uint8 private constant RELAY = 2;
    uint8 private constant ROUTER = 3;

    function setIsPair(address key) internal pure returns (bytes memory) {
        return _encode(IS_PAIR, uint160(key), 1);
    }

    function getIsPair(bytes memory hints, address key) internal pure returns (bool isPairToken) {
        return _decode(hints, IS_PAIR, uint160(key)) == 1;
    }

    function setPairInput(address key, uint value) internal pure returns (bytes memory) {
        return _encode(PAIR_INPUT, uint160(key), value);
    }

    function getPairInput(bytes memory hints, address key) internal pure returns (uint value) {
        value = _decode(hints, PAIR_INPUT, uint160(key));
    }

    function setRouter(
        address tokenIn,
        address tokenOut,
        address router
    ) internal pure returns (bytes memory) {
        return _encodeAddress(ROUTER, _hashTuple(tokenIn, tokenOut), router);
    }

    function getRouter(
        bytes memory hints,
        address tokenIn,
        address tokenOut
    ) internal pure returns (address router) {
        return _decodeAddress(hints, ROUTER, _hashTuple(tokenIn, tokenOut));
    }

    function setRelay(
        address tokenIn,
        address tokenOut,
        address relay
    ) internal pure returns (bytes memory) {
        return _encodeAddress(RELAY, _hashTuple(tokenIn, tokenOut), relay);
    }

    function getRelay(
        bytes memory hints,
        address tokenIn,
        address tokenOut
    ) internal pure returns (address) {
        return _decodeAddress(hints, RELAY, _hashTuple(tokenIn, tokenOut));
    }

    function merge2(bytes memory h0, bytes memory h1) internal pure returns (bytes memory) {
        return abi.encodePacked(h0, h1);
    }

    function merge3(
        bytes memory h0,
        bytes memory h1,
        bytes memory h2
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(h0, h1, h2);
    }

    function empty() internal pure returns (bytes memory) {
        return "";
    }

    function _encode(
        uint8 kind,
        uint key,
        uint value
    ) private pure returns (bytes memory) {
        return abi.encodePacked(kind, key, value);
    }

    function _encodeAddress(
        uint8 kind,
        uint key,
        address value
    ) private pure returns (bytes memory) {
        return _encode(kind, key, uint160(value));
    }

    function _decode(
        bytes memory hints,
        uint8 kind,
        uint key
    ) private pure returns (uint value) {
        // each hint takes 65 bytes (1+32+32). 1 byte for kind, 32 bytes for key, 32 bytes for value
        for (uint i = 0; i < hints.length; i += 65) {
            // kind is at offset 0
            if (uint8(hints[i]) != kind) {
                continue;
            }
            // key is at offset 1
            if (ArrayHelper.sliceUint(hints, i + 1) != key) {
                continue;
            }
            // value is at offset 33 (1+32)
            return ArrayHelper.sliceUint(hints, i + 33);
        }
    }

    function _decodeAddress(
        bytes memory hints,
        uint8 kind,
        uint key
    ) private pure returns (address) {
        return address(uint160(_decode(hints, kind, key)));
    }

    function _hashTuple(address a1, address a2) private pure returns (uint256) {
        uint256 u1 = uint160(a1);
        uint256 u2 = uint160(a2);
        u2 = u2 << 96;
        return u1 ^ u2;
    }
}