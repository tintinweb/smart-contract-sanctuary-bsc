// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ICommunity {
    
    function initialize(
        address implState,
        address implView,
        address hook, 
        address costManager, 
        string memory name, 
        string memory symbol
    ) external;
    
    function addressesCount(uint8 roleIndex) external view returns(uint256);
    function getRoles(address[] calldata accounts)external view returns(uint8[][] memory);
    function getAddresses(uint8[] calldata rolesIndexes) external view returns(address[][] memory);
    function hasRole(address account, uint8 roleIndex) external view returns(bool);
    function grantRoles(address[] memory accounts, uint8[] memory roleIndexes) external;
    function revokeRoles(address[] memory accounts, uint8[] memory roleIndexes) external;
}

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface ISubscriptionsHook {
    function onCharge(address token, uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface ISubscriptionsManagerFactory {
    function doCharge(address token, uint256 amount, address from, address to) external returns(bool success);
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
    error SubscriptionCantStart();

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@artman325/releasemanager/contracts/CostManagerHelper.sol";
import "@artman325/community/contracts/interfaces/ICommunity.sol";
import "./interfaces/ISubscriptionsManagerUpgradeable.sol";
import "./interfaces/ISubscriptionsManagerFactory.sol";
import "./interfaces/ISubscriptionsHook.sol";

contract SubscriptionsManagerUpgradeable is OwnableUpgradeable, ISubscriptionsManagerUpgradeable, ReentrancyGuardUpgradeable, CostManagerHelper {
    uint32 public interval;
    uint16 public intervalsMax; // if 0, no max
    uint16 public intervalsMin;
    uint8 public retries;
    address public token; // the token to charge
    uint256 public price; // the price to charge

    address recipient;
    address hook;

    mapping (address => Subscription) public subscriptions;
    mapping (address => bool) public callers;

    address public controller; // optional, smart contract that can start a subscription and pay first charge
    address public factory; // the factory
    //address owner; // owner can cancel subscriptions, add callers
    address community; // any CommunityContract
    uint8 roleId; // the role

    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;

    modifier onlyController() {
        
        if (controller == address(0)) {
            revert NotSupported();
        }

        if (controller != _msgSender()) {
            revert ControllerOnly(controller);
        }

        _;
    }

    
    modifier ownerOrCaller() {
        address ms = _msgSender();
        if (owner() != _msgSender() && callers[ms] != true) {
            revert OwnerOrCallerOnly();
        }
        _;
    }

    constructor() {
        _disableInitializers();
    }

    /**
    * @param interval_ period, day,week,month in seconds
    * @param intervalsMax_ max interval
    * @param intervalsMin_ min interval
    * @param retries_ amount of retries
    * @param token_ token address to charge
    * @param price_ price for subsription on single interval
    * @param controller_ [optional] controller address
    * @param recipient_ address which will obtain pay for subscription
    * @param hook_  if present then try to call hook.onCharge 
    * @param costManager_ costManager address
    * @param producedBy_ producedBy address
    * @custom:calledby factory
    * @custom:shortd initialize while factory produce
    */
    function initialize(
        uint32 interval_,
        uint16 intervalsMax_,
        uint16 intervalsMin_,
        uint8 retries_,
        address token_,
        uint256 price_,
        address controller_,
        address recipient_,
        address hook_,
        address costManager_,
        address producedBy_
    ) 
        external
        initializer  
        override
    {

        __CostManagerHelper_init(_msgSender());
        _setCostManager(costManager_);

        __Ownable_init();
        __ReentrancyGuard_init();
        
        factory = owner();

        interval = interval_;
        intervalsMax = intervalsMax_;
        intervalsMin = intervalsMin_;
        retries = retries_;
        token = token_;
        price = price_;
        controller = controller_;
        recipient = recipient_;
        hook = hook_;

        _accountForOperation(
            OPERATION_INITIALIZE << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy_)),
            0
        );
    }

    ///////////////////////////////////
    // external 
    ///////////////////////////////////
    function subscribeFromController(
        address subscriber, 
        uint256 customPrice, 
        uint16 desiredIntervals
    ) 
        external 
        override 
        onlyController
    {
        _subscribe(subscriber, customPrice, desiredIntervals);
    }
    function subscribe(
        uint16 desiredIntervals
    ) 
        external 
        override 
    {
        _subscribe(_msgSender(), price, desiredIntervals);
    }

    
    function cancel() external override {
        
        Subscription storage subscription = subscriptions[_msgSender()];
        if (subscription.state == SubscriptionState.ACTIVE) {
            _active(subscription, SubscriptionState.BROKEN);
            subscription.endTime = _currentBlockTimestamp();
            emit Canceled(subscription.subscriber, _currentBlockTimestamp());
        }
    }

    function cancel(address[] memory subscribers) external override onlyOwner {
        uint256 l = subscribers.length;
        for (uint256 i = 0; i < l; i++) {
            Subscription storage subscription = subscriptions[subscribers[i]];
            if (subscription.state == SubscriptionState.ACTIVE) {
                _active(subscription, SubscriptionState.BROKEN);
                subscription.endTime = _currentBlockTimestamp();
            }
            emit Canceled(subscription.subscriber, _currentBlockTimestamp());
        }
    
    }

    function setCommunity(address community_, uint8 roleId_) external onlyOwner {
        if (roleId_ == 0 && community_ != address(0)) {
            revert invalidCommunitySettings();
        }
        //todo: also need to check "can this contract grant and revoke roleId"

        community = community_;
        roleId = roleId_;
    }

    function charge(address[] memory subscribers) external override ownerOrCaller {
        // if all callers fail to do this within an interval
        // then restore() will have to be called before charge()
        _charge(subscribers, 1, false);
    }

    function restore() external override {
        address[] memory subscribers = new address[](1);
        subscribers[0] = _msgSender();
        _restore(subscribers, false);
    }
    function restore(address[] memory subscribers) external override ownerOrCaller{
        _restore(subscribers, true);
    }

    
    function addCaller(address caller) external override onlyOwner {
        callers[caller] = true;
    }
    function removeCaller(address caller) external override onlyOwner {
        //callers[caller] = false;
        delete callers[caller];
    }

    function isActive(address subscriber) external override view returns (bool, SubscriptionState) {
        Subscription storage subscription = subscriptions[subscriber];
        return (
            (
                subscription.state == SubscriptionState.ACTIVE || 
                subscription.state == SubscriptionState.EXPIRED 
                ? true 
                : false
            ),
            subscription.state
        );
    }
    function activeUntil(address subscriber) external override view returns (uint64) {
        Subscription storage subscription = subscriptions[subscriber];
        return subscription.endTime;
    }

    ///////////////////////////////////
    // public
    ///////////////////////////////////

    ///////////////////////////////////
    // internal
    ///////////////////////////////////
    /**
     * @notice helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**64 - 1]
     */
    function _currentBlockTimestamp() internal view returns (uint64) {
        return uint64(block.timestamp);
    }

    ///////////////////////////////////
    // private
    ///////////////////////////////////

    // must prepay intervalsMin intervals to start a subscription
    function _subscribe(
        address subscriber, 
        uint256 fee, 
        uint16 desiredIntervals
    ) 
        private 
    {
        
        if (intervalsMax > 0 && desiredIntervals > intervalsMax) {
            revert SubscriptionTooLong();
        }
        if (desiredIntervals != 0 && desiredIntervals < intervalsMin) {
            revert SubscriptionTooShort();
        }
        subscriptions[subscriber] = Subscription(
            fee,
            subscriber,
            _currentBlockTimestamp(),
            _currentBlockTimestamp(),
            desiredIntervals,
            SubscriptionState.EXPIRED
        );

        //---
        address[] memory subscribers = new address[](1);
        subscribers[0] = subscriber;
        //---
        uint16 count = _charge(subscribers, intervalsMin > 0 ? intervalsMin : 1, true); // charge the first intervalsMin intervals
        if (count > 0) {
            emit Subscribed(subscriber, _currentBlockTimestamp());
        }
    }

    // doesn't just charge but updates valid subscriptions
    // to be either extended or broken and set endTime
    // requiring them to be restored
    function _charge(
        address[] memory subscribers, 
        uint16 desiredIntervals,
        bool firstTime
    ) 
        private 
        returns(uint16 count)
    {
        
        uint256 l = subscribers.length;
        
        for (uint256 i = 0; i < l; i++) {
            address subscriber = subscribers[i];
            Subscription storage subscription = subscriptions[subscriber];

            if (subscription.endTime > _currentBlockTimestamp()) {
                // subscription is still active, no need to charge
                continue;
            }
            // will turn into expired state after trying to charge
            // if (subscription.endTime > _currentBlockTimestamp() - interval*retries) {
            //     // subscription turn to EXPIRED state, need to charge or manually restore
            //     _active(subscription, SubscriptionState.EXPIRED);
            //     emit SubscriptionExpired(subscriber, _currentBlockTimestamp());
            //     continue;
            // }

            if (subscriptionActualize(subscription)) {
                continue;
            }

            bool result = ISubscriptionsManagerFactory(factory).doCharge(token, getSubscriptionPrice(subscription) * desiredIntervals, subscriber, recipient);

            if (result) {
                _active(subscription, SubscriptionState.ACTIVE);
                emit Charged(subscriber, getSubscriptionPrice(subscription) * desiredIntervals);
                subscription.endTime += interval * desiredIntervals;
                count++;

                if (hook != address(0)) {
                    ISubscriptionsHook(hook).onCharge(token, getSubscriptionPrice(subscription));
                }
            } else {
                if (firstTime) {
                    revert SubscriptionCantStart();
                } else {
                        
                    if (subscription.state != SubscriptionState.EXPIRED) {
                        emit SubscriptionExpired(subscriber, _currentBlockTimestamp());
                    }
                    _active(subscription, SubscriptionState.EXPIRED);
                    emit ChargeFailed(subscriber, getSubscriptionPrice(subscription));
                
                }
            }
            
        }
        
        
    }

    function getSubscriptionPrice(Subscription storage subscription) private view returns(uint256) {
        return (subscription.price == 0) ? price : subscription.price;
    }

    function _active(Subscription storage subscription, SubscriptionState newState) private {
        if (subscription.state == newState) {
            return; // nothing to do
        }
        subscription.state = newState;
        emit StateChanged(subscription.subscriber, newState);
        
        if (community == address(0)) {
            return; // nothing to do
        }

        address[] memory _s = new address[](1);
        uint8[] memory _r = new uint8[](1);
        _s[0] = subscription.subscriber;
        _r[0] = roleId;
        if (newState == SubscriptionState.ACTIVE) {
            ICommunity(community).grantRoles(_s, _r);
        } else {
            ICommunity(community).revokeRoles(_s, _r);
        }
    }
    /**
    // try to check:
    // - is user interval expired?
    // - is subscription max interval expire?
    // - is exceed retries attempt?
    // - 
    */
    function subscriptionActualize(Subscription storage subscription) private returns(bool skip){
        if (subscription.state == SubscriptionState.EXPIRED) {
            if (
                // subscription turn to BROKEN state as reached maximum retries attempt
                (subscription.endTime < _currentBlockTimestamp() - interval*retries) || 
                // or exceed interval subscription
                (_currentBlockTimestamp() - subscription.startTime > interval * subscription.intervals)
            ) {
                // turn into the broken state, which can not be restored
                _active(subscription, SubscriptionState.BROKEN);
                emit SubscriptionIsBroken(subscription.subscriber, _currentBlockTimestamp());
                //continue;
                skip = true;
            }
        }
    }
   
    function _restore(
        address[] memory subscribers, 
        bool ownerOrCaller_
    ) 
        private 
    {
        uint256 l = subscribers.length;
        for (uint256 i = 0; i < l; i++) {
            address subscriber = subscribers[i];
            Subscription storage subscription = subscriptions[subscriber];

           
            if (
                subscription.state == SubscriptionState.NONE ||     // if not created before
                subscription.state == SubscriptionState.ACTIVE ||   // or already active
                subscription.state == SubscriptionState.BROKEN      // or already broken
            ) {
                continue; 
            }
            
            if (_currentBlockTimestamp() - subscription.startTime > interval * subscription.intervals) {
                emit SubscriptionExpired(subscriber, _currentBlockTimestamp());
                
            }

            uint64 difference = uint64(_currentBlockTimestamp() - subscription.endTime);
            uint64 diffIntervals = difference / interval + 1; // rounds up to nearest integer
            if (!ownerOrCaller_ && diffIntervals > uint64(retries)) {
                emit RetriesExpired(subscriber, _currentBlockTimestamp(), diffIntervals);
                
            }

            // and turn to broken if
            // - is user interval expired?
            // - is subscription max interval expire?
            // - is exceed retries attempt?
            // - 
            if (subscriptionActualize(subscription)) {
                continue;
            }

            

            uint256 amount = getSubscriptionPrice(subscription);
            
            bool result = ISubscriptionsManagerFactory(factory).doCharge(token, subscription.price * diffIntervals, subscriber, recipient);

            if (result) {
                _active(subscription, SubscriptionState.ACTIVE);
                emit Restored(subscriber, _currentBlockTimestamp(), subscription.endTime);
                subscription.endTime += interval * diffIntervals;
            } else {
                emit ChargeFailed(subscriber, amount);
            }
        }
    }

}