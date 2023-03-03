// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICostManager.sol";
import "./interfaces/ICostManagerFactoryHelper.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract CostManagerBase is Initializable {
    using AddressUpgradeable for address;

    address public costManager;
    address public deployer;

    /** 
    * @dev sets the costmanager token
    * @param costManager_ new address of costmanager token, or 0
    */
    function overrideCostManager(address costManager_) external {
        // require factory owner or operator
        // otherwise needed deployer(!!not contract owner) in cases if was deployed manually
        require (
            (deployer.isContract()) 
                ?
                    ICostManagerFactoryHelper(deployer).canOverrideCostManager(_sender(), address(this))
                :
                    deployer == _sender()
            ,
            "cannot override"
        );
        
        _setCostManager(costManager_);
    }

    function __CostManagerHelper_init(address deployer_) internal onlyInitializing
    {
        deployer = deployer_;
    }

     /**
     * @dev Private function that tells contract to account for an operation
     * @param info uint256 The operation ID (first 8 bits). in other bits any else info
     * @param param1 uint256 Some more information, if any
     * @param param2 uint256 Some more information, if any
     */
    function _accountForOperation(uint256 info, uint256 param1, uint256 param2) internal {
        if (costManager != address(0)) {
            try ICostManager(costManager).accountForOperation(
                _sender(), info, param1, param2
            )
            returns (uint256 /*spent*/, uint256 /*remaining*/) {
                // if error is not thrown, we are fine
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
                revert(reason);
            } catch {
                revert("unknown error");
            }
        }
    }
    
    function _setCostManager(address costManager_) internal {
        costManager = costManager_;
    }
    
    function _sender() internal virtual returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CostManagerBase.sol";

/**
* used for instances that have created(cloned) by factory.
*/
contract CostManagerHelper is CostManagerBase {

    function _sender() internal override view returns(address){
        return msg.sender;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ICostManager/* is IERC165Upgradeable*/ {
    function accountForOperation(
        address sender, 
        uint256 info, 
        uint256 param1, 
        uint256 param2
    ) 
        external 
        returns(uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICostManagerFactoryHelper {
    
    function canOverrideCostManager(address account, address instance) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface ISubscriptionsManagerUpgradeable {
    enum SubscriptionState{ 
        NONE,       // Subscription notfound. its like default value for subscription state
        EXPIRED,    // Subscription just created, but contract cannot charge funds OR failed charge in next interval after being active
        ACTIVE,     // Active subscription
        BROKEN      // Becomes broken after failed retries to charge 
    }
    struct Subscription {
        uint256 price; // if not 0, it overrides the global price
        address subscriber;
        uint64 startTime;
        uint64 endTime; // because it was canceled or broken, otherwise it is when it expires
        uint16 intervals;
        SubscriptionState state;
    }

    event Canceled(address subscriber, uint64 cancelTime);
    event Subscribed(address subscriber, uint64 startTime);
    event Restored(address subscriber, uint64 restoreTime, uint64 startTime);
    event Charged(address subscriber, uint256 amount);
    event ChargeFailed(address subscriber, uint256 amount);
    event RetriesExpired(address subscriber, uint64 tryTime, uint64 retries);
    event SubscriptionIsBroken(address subscriber, uint64 chargeTime);
    event SubscriptionExpired(address subscriber, uint64 chargeTime);
    event StateChanged(address subscriber, SubscriptionState newState);

    error SubscriptionTooLong();
    error SubscriptionTooShort();
    error ControllerOnly(address controller);
    error OwnerOrCallerOnly();
    error NotSupported();
    error invalidCommunitySettings();

    function initialize(
        uint32 interval,
        uint16 intervalsMax,
        uint16 intervalsMin,
        uint8 retries,
        address token,
        uint256 price,
        address controller,
        address recipient,
        address hook,
        address costManager,
        address producedBy
    ) external;

    
    function subscribeFromController(
        address subscriber, 
        uint256 customPrice, 
        uint16 intervals
    ) external;
    
    // called by subscriber himself
    function subscribe(uint16 intervals) external; // intervals is maximum times to renew
    function cancel() external;
    function restore() external;
    
    // called by owner
    function cancel(address[] memory subscribers) external;
    function addCaller(address caller) external;
    function removeCaller(address caller) external;
    
    // ownerOrCaller
    // called to charge some subscribers and extend their subscriptions
    function charge(address[] memory subscribers) external;// ownerOrCaller
    function restore(address[] memory subscribers) external; // ownerOrCaller
    
    function isActive(address subscriber) external view returns (bool, SubscriptionState);
    function activeUntil(address subscriber) external view returns (uint64);
        
}

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
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IAuctionBase.sol";
import "./interfaces/IAuctionFactory.sol";
import "@artman325/releasemanager/contracts/CostManagerHelper.sol";
//import "hardhat/console.sol";
contract AuctionBase is IAuctionBase, ReentrancyGuardUpgradeable, CostManagerHelper, OwnableUpgradeable {

    event AlreadyWinning(address bidder, uint256 index);
    event Bid(address bidder, uint256 amount, uint32 numBids);
    event RefundedBid(address bidder, uint256 amount);
    event SpentBid(address bidder, uint256 amount);

    error OutsideOfIntercoinEcosystem();
    error ChargeFailed();
    error BidTooSmall();
    error NotWinning();
    error AlreadyClaimed();
    error SubscribeFailed();
    error NotCancelable();
    error CannotBidAboveCurrentPrice();
    error CannotWithdrawDuringClaimPeriod();

    error AuctionWasCanceled();
    error AuctionNotCanceled();
    error AuctionNotFinished();
    error MaximumBidsAmountExceeded();

    //address factory;
    //address owner; // whoever called produce() or produceDeterministic()
    address token; // 0 means native coin

    

    bool canceled;
    bool cancelable;
    uint64 startTime;
    uint64 endTime;
    uint64 claimPeriod;
    uint256 startingPrice;
    uint256 currentPrice;
    Increase priceIncrease;

    BidStruct[] public bids;
    uint32 public maxWinners;
    uint32 public winningSmallestIndex; // starts at 1

    struct WinningStruct {
        uint32 bidIndex;
        bool claimed;
    }
    mapping (address => WinningStruct) winningBidIndex; // 1-based index, thus 0 means not winning

    // Constants for shifts
    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;
    
    constructor() {
        _disableInitializers();
    }
    
    function __AuctionBase_init(
        address token_,
        bool cancelable_,
        uint64 startTime_,
        uint64 endTime_,
        uint64 claimPeriod_,
        uint256 startingPrice_,
        Increase memory increase_,
        uint32 maxWinners_, 
        address costManager,
        address producedBy
    ) 
        internal
        
    {
        __Ownable_init();
        __ReentrancyGuard_init();

        __CostManagerHelper_init(_msgSender()); // here sender it's deployer/ it's our factory.
        // or we can put `owner()` instead `_msgSender()`. it was the same here
        // EOA will be owner after factory will transferOwnership in produce

        _setCostManager(costManager);

        token = token_;
        canceled = false;
        cancelable = cancelable_;
        startTime = startTime_;
        endTime = endTime_;
        claimPeriod = claimPeriod_;
        startingPrice = startingPrice_;
        priceIncrease.amount = increase_.amount;
        priceIncrease.numBids = increase_.numBids;
        priceIncrease.canBidAboveIncrease = increase_.canBidAboveIncrease;
        maxWinners = maxWinners_;

        winningBidIndex[address(0)].bidIndex = 0;
        bids.push(BidStruct(address(0), 0));
        winningSmallestIndex++;

        _accountForOperation(
            OPERATION_INITIALIZE << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy)),
            0
        );
    }

    function bid(uint256 amount) payable public {
        
        address ms = _msgSender();
        uint32 index = winningBidIndex[ms].bidIndex;

        if (index > 0) {
            emit AlreadyWinning(ms, index);
            return;
        }

        if (token != address(0) && amount == 0) {
            amount = currentPrice;
        }
        if (amount < currentPrice) {
            revert BidTooSmall();
        }
        if (currentPrice < amount) {
            if (!priceIncrease.canBidAboveIncrease) {
                revert CannotBidAboveCurrentPrice();
            }
            currentPrice = amount;
        }

        _charge(ms, amount);

        if (bids.length % priceIncrease.numBids == 0) {
            currentPrice += priceIncrease.amount; // every so often
        }
        
        if (bids.length > maxWinners) {
            _refundBid(winningSmallestIndex);
            winningSmallestIndex++;
        }

        if (bids.length > type(uint32).max) {
            revert MaximumBidsAmountExceeded();
        }


        bids.push(BidStruct(ms, amount));

        winningBidIndex[ms].bidIndex = uint32(bids.length) - 1;
        emit Bid(ms, amount, uint32(bids.length));
        
    }

    // return winning bids, from largest to smallest
    function winning() external view returns (BidStruct[] memory result) {
        uint32 l = uint32(bids.length);
        
        result = new BidStruct[](l-winningSmallestIndex);
        uint256 ii = 0;
        for (uint32 i=l-1; i >= winningSmallestIndex; --i) {
            result[ii] = bids[i];
            ii++;
        }
    }

    // sends all the money back to the people
    function cancel() external onlyOwner {
        if (!cancelable) {
            revert NotCancelable();
        }
        uint32 l = uint32(bids.length);
        for (uint32 i=winningSmallestIndex; i<l; ++i) {
            _refundBid(i); // send money back
        }
        canceled = true;
    }

    // owner withdraws all the money after auction is over
    function withdraw(address recipient) external onlyOwner {
        withdrawValidate();

        // if (token == address(0)) {
        //     send(recipient, this.balance);
        // } else {
        //     IERC20(token).transfer(recipient, IERC20(token).balanceOf(this));
        // }
        uint256 totalContractBalance = IERC20Upgradeable(token).balanceOf(address(this));
        IERC20Upgradeable(token).transfer(recipient, totalContractBalance);
    }

    function withdrawValidate() internal view {
        if (block.timestamp < endTime) {
            revert AuctionNotFinished();
        }
        

        uint32 l = uint32(bids.length);
        uint256 numClaimed = 0;
        for (uint32 i=l-1; i >= winningSmallestIndex; --i) {
            if (winningBidIndex[bids[i].bidder].claimed == true) {
                numClaimed++;
            }
        }

        if (
            (block.timestamp >= endTime + claimPeriod) ||
            (numClaimed == maxWinners) 
        ) {
            // pass condition
        } else {
            revert CannotWithdrawDuringClaimPeriod();
        }
        
    }
   
    // should be call in any variant of claim
    // validation sender as winner, setup sender as already claimed  etc
    function _claim(address sender) internal {
        requireWinner(sender);
        winningBidIndex[sender].claimed = true;
    }
     
    function requireWinner(address sender) internal view {
        if (canceled) {
            revert AuctionWasCanceled();
        }
        if (block.timestamp < endTime) {
            revert AuctionNotFinished();
        }
        
        if (winningBidIndex[sender].bidIndex == 0) {
            revert NotWinning();
        }
        if (winningBidIndex[sender].claimed == true) {
            revert AlreadyClaimed();
        }

    }

    // send back the bids when someone isn't winning anymore
    function _refundBid(uint32 index) internal {
        BidStruct storage b = bids[index];
        // if (token == address(0)) {
        //     send(b.bidder, b.amount);
        // } else {
        //     IERC20(token).transfer(b.bidder, b.amount);
        // }
        IERC20Upgradeable(token).transfer(b.bidder, b.amount);
        emit RefundedBid(b.bidder, b.amount);
        //bids[winningSmallestIndex] = 0; // or maybe use delete
        delete bids[winningSmallestIndex];
        delete winningBidIndex[b.bidder];
        
    }

    
    function _charge(address payer, uint256 amount) private {
        bool success = IAuctionFactory(deployer).doCharge(token, amount, payer, address(this));
        if (!success) {
            revert ChargeFailed();
        }
    }

    
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;
import "./AuctionBase.sol";
import "./interfaces/IAuctionSubscription.sol";
import "@artman325/subscriptioncontract/contracts/interfaces/ISubscriptionsManagerUpgradeable.sol";
import "./libs/SwapSettingsLib.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";


contract AuctionSubscription is AuctionBase, IAuctionSubscription {
    
    ISubscriptionsManagerUpgradeable public subscriptionManager; // for subscribe function

    address internal wethAddr;

    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint64 claimPeriod,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address manager, 
        address costManager,
        address producedBy
    ) 
        external 
        initializer 
    {
        __AuctionBase_init(token, cancelable, startTime, endTime, claimPeriod, startingPrice, increase, maxWinners, costManager, producedBy);
        if (manager == address(0)) {
            revert SubscriptionManagerMissing();
        }
        subscriptionManager = ISubscriptionsManagerUpgradeable(manager);
        

        // setup swap addresses
        (,,wethAddr,,,,) = SwapSettingsLib.netWorkSettings();
        
    }

    function subscribe(
        uint16 intervalsMin, 
        uint16 intervals
    ) 
        external
    {
        address sender = _msgSender();
        
        _claim(sender);
        
        uint32 index = winningBidIndex[sender].bidIndex;
        uint256 customPrice = bids[index].amount/intervalsMin;

        _spend(sender, index, true);

        // subscriptionManager.subscribeFromController(
        //     sender, 
        //     customPrice, 
        //     intervals
        // );
        try subscriptionManager.subscribeFromController(sender, customPrice, intervals) {
            // all ok
        } catch {
            // else if any errors. do refund
            _refundBid(winningBidIndex[sender].bidIndex);
        }
        
    }

    function _spend(
        address sender,
        uint32 index,
        bool asWETH
    ) private
    {
        
        //BidStruct storage b = bids[index];
        address bidder = bids[index].bidder;
        uint256 amount = bids[index].amount;

        winningBidIndex[sender].bidIndex = 0; // to prevent replay attacks, since winningSmallestIndex wasn't incremented
        winningBidIndex[sender].claimed = true;

        emit SpentBid(bidder, amount);

        if (token == address(0)) {
            if (asWETH) {
                IWETH(wethAddr).deposit{value: amount}();
                TransferHelper.safeTransfer(wethAddr, bidder, amount);

            } else {
                TransferHelper.safeTransferETH(bidder, amount);
            }
        } else {
            TransferHelper.safeTransfer(token, bidder, amount);
        }
        
    }

}


/*
    //
    // SUBSCRIPTION related
    // 

    

    function subscribe(address manager, uint16 intervalsMin, uint16 intervals)
    {
        if (subscriptionManager == address(0)) {
            throw SubscriptionManagerMissing();
        }
        if (canceled) {
            throw AuctionWasCanceled();
        }
        if (!subscribeEvenIfNotFinished && block.timestamp < endTime) {
            throw AuctionNotFinished();
        }
        address ms = _msgSender();
        index = winningBidIndex[ms];
        if (index == 0) {
            throw NotWinning();
        }

        uint256 amount = bids[index].amount;
        _spend(bids[index].bidder, amount, true);

        (success, result) = ISubscriptionManager(subscriptionManager).subscribe(
            _msgCaller(), amount / intervalsMin, intervals
        );
        if (!success) {
            throw SubscribeFailed();
        }
    }

    function _spend(address recipient, uint256 amount, bool asWETH) private
    {
        Bid b = bids[index];
        if (token == address(0)) {
            if (asWETH) {
                const address WETH = 0x...; // depends on the chain
                WETH.wrap(b.amount);
                WETH.transfer(ms, b.amount);
            } else {
                send(ms, b.amount);
            }
        } else {
            IERC20(token).transfer(ms, amount);
        }
        bids[index] = 0; // to prevent replay attacks, since winningSmallestIndex wasn't incremented
        emit SpentBid(b.bidder, b.amount);
    }

*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface IAuctionBase {
    struct BidStruct {
        address bidder;
        uint256 amount;
    }
    struct Increase {
        uint128 amount; // can't increase by over half the range
        uint32 numBids; // increase after this many bids
        bool canBidAboveIncrease;
    }

    function bid(uint256 amount) payable external;
    function winning() external view returns (BidStruct[] memory result);
    function cancel() external;
    function withdraw(address recipient) external;
    
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface IAuctionFactory {
    function doCharge(address token, uint256 amount, address from, address to) external returns(bool success);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "./IAuctionBase.sol";

interface IAuctionSubscription is IAuctionBase {

    error SubscriptionManagerMissing();

    function initialize(
        address token,
        bool cancelable,
        uint64 startTime,
        uint64 endTime,
        uint64 claimPeriod,
        uint256 startingPrice,
        Increase memory increase,
        uint32 maxWinners,
        address subscriptionManager,
        address costManager,
        address producedBy
    ) external;
   
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SwapSettingsLib {
    function netWorkSettings(
    )
        internal
        view
        returns(address, address, address, uint256 k1, uint256 k2, uint256 k3, uint256 k4)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        if ((chainId == 0x1) || (chainId == 0x3) || (chainId == 0x4) || (chainId == 0x539) || (chainId == 0x7a69)) {  //+ localganache chainId, used for fork 
            // Ethereum-Uniswap
            (k1,k2,k3,k4) = _koefficients(1000, 3); // fee = 0.3%
            return( 
                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, //uniswapRouter
                0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f, //uniswapRouterFactory
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, //WETH
                //3988000,3988009,1997,1994
                k1,k2,k3,k4
            );
            //_koefficients(1000, 3);
        } else if((chainId == 0x89)) {
            // Matic-QuickSwap
            (k1,k2,k3,k4) = _koefficients(1000, 3); // fee = 0.3%
            return( 
                0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff, //uniswapRouter
                0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32, //uniswapRouterFactory
                0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, //WMATIC
                //3988000,3988009,1997,1994
                k1,k2,k3,k4
            );
        } else if((chainId == 0x38)) {
            // Binance-PancakeSwap
            (k1,k2,k3,k4) = _koefficients(10000, 25); // fee = 0.25%
            return( 
                0x10ED43C718714eb63d5aA57B78B54704E256024E, //uniswapRouter
                0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, //uniswapRouterFactory
                0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, //WBNB
                //399000000,399000625,19975,19950
                k1,k2,k3,k4
            );
            //_koefficients(10000, 25);
        } else {
            revert("unsupported chain");
        }
    }
    /**
    * @dev calculation koefficients for formula in https://blog.alphaventuredao.io/onesideduniswap/
    */
    function _koefficients(uint256 d, uint256 f) private pure returns(uint256, uint256, uint256, uint256) {
            // uint256 f = 3000;//0,003 mul denominator
            // uint256 k1=4*(1*d-f)*d; //4*(1-f)^2 = 3988000
            // uint256 k2=(2*d-f)*(2*d-f); //(2-f)^2 = 3988009
            // uint256 k3=(2*d-f); //(2-f) = 1997
            // uint256 k4=2*(1*d-f); //2*(1-f) // 1994
            return(
                4*(1*d-f)*d,
                (2*d-f)*(2*d-f),
                (2*d-f),
                2*(1*d-f)
            );
    }
}