// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libraries/TransfersExecutionUtils.sol";

/**
 * @title The Algoblocks SafeWithdraw Upgradeable
 * @author Algoblocks
 * @notice Recover tokens and ETH
 */
abstract contract AlgoblocksSafeWithdrawUpgradeable is OwnableUpgradeable {
   /// @notice Receive native chain token
   receive() external payable {}

   /**
    * @notice Initliazation of AlgoblocksSafeWithdrawUpgradeable
    */
   function __AlgoblocksSafeWithdrawUpgradeable_init() internal initializer {
      __Ownable_init();
   }

   /**
    * @notice Recover ERC20 tokens
    * @dev Execute by only owner
    * @param recipient The account of recipient to send these tokens
    * @param tokenAddresses The list of token addresses
    * @param amounts The list of amount to transfer respectively
    */
   function recoverTokens(
      address recipient,
      address[] memory tokenAddresses,
      uint256[] memory amounts
   ) external onlyOwner {
      require(recipient != address(0), "INVALID_RECIPIENT");
      uint256 tokensCount = tokenAddresses.length;
      require(tokensCount > 0 && tokensCount == amounts.length, "MISMATCH_ARGUMENTS");
      for (uint8 k = 0; k < tokensCount; k++) {
         require(tokenAddresses[k] != address(0), "INVALID_RECOVER_TOKEN");
         require(amounts[k] > 0, "INVALID_RECOVER_AMOUNT");
         TransfersExecutionUtils.executeTransfer(tokenAddresses[k], recipient, amounts[k]);
      }
   }

   /**
    * @notice Recover ETH
    * @dev Execute by only owner
    * @param recipient The account of recipient to send these tokens
    * @param value The eth value to send
    */
   function recoverETH(address recipient, uint256 value) external onlyOwner {
      require(recipient != address(0), "INVALID_RECIPIENT");
      require(value > 0 && address(this).balance >= value, "INVALID_VALUE");
      TransfersExecutionUtils.executeTransferETH(recipient, value);
   }

   /**
    * @dev This empty reserved space is put in place to allow future versions to add new
    * variables without shifting down storage in the inheritance chain.
    * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    */
   uint256[49] private __gap;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

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
   function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

// interfaces
import "../interfaces/IERC20.sol";

/**
 * @title The Transfer Execution Utils
 * @author Algoblocks
 * @notice Performs token transfers, approvals etc
 */
library TransfersExecutionUtils {
   /**
    * @dev Execute approve function of a ERC20 token
    * @param token The contract address of ERC20 token
    * @param to The account of spender
    * @param value The value that should be approve by the contract
    */
   function executeApprove(
      address token,
      address to,
      uint256 value
   ) internal {
      (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
      require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVAL_FAILED");
   }

   /**
    * @dev Checks the allowance then execute ERC20 tokens approval
    * @param token The contract address of ERC20 token
    * @param spender The account of spender
    */
   function checkAllownaceThenExecuteApprove(address token, address spender) internal {
      if (IERC20(token).allowance(address(this), spender) == 0) {
         executeApprove(token, spender, type(uint256).max);
      }
   }

   /**
    * @notice Execute transfers of ERC20 tokens
    * @dev Provide sufficient token approval before execute this
    * @param target The contract address of ERC20 token
    * @param sender The account of sender
    * @param recipient The account of recipient
    * @param amount The amount of tokens thats needs to transfer
    */
   function executeTransferFrom(
      address target,
      address sender,
      address recipient,
      uint256 amount
   ) internal {
      (bool success, ) = target.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
      require(success, "TRANSFER_FAILED");
   }

   /**
    * @notice Execute transfers of ERC20 tokens
    * @param target The contract address of target
    * @param to The account of recipient
    * @param amount The number of tokens that needs to transfer
    */
   function executeTransfer(
      address target,
      address to,
      uint256 amount
   ) internal {
      if (amount > 0) {
         (bool success, ) = target.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
         require(success, "TRANSFER_FAILED");
      }
   }

   /**
    * @notice Transfer native chain token
    * @param to The account of receiver
    * @param value The value to transfer
    */
   function executeTransferETH(address to, uint256 value) internal {
      if (value > 0) {
         (bool success, ) = to.call{value: uint128(value)}(new bytes(0));
         require(success, "TRANSFER_FAILED");
      }
   }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

/**
 * @title The Interface of AlgoblocksZapFeatureUpgradeable
 * @author Algoblocks
 * @notice Executes zaps via algoblocks router contract
 */
interface IAlgoblocksZapFeatureUpgradeable {
   /**
    * @notice Perform zaps
    * @param token0 The contract address of token0
    * @param token1 The contract address of token1
    * @param user The account of user
    * @param token0Amount The amount of token0 to add liquidity
    * @param token1Amount The amount of token1 to add liquidity
    * @param deadline The deadline to executing zap
    * @param isNative The identifier to know if there is one token is native token
    * @return lp The minted lp tokens
    */
   function zap(
      address token0,
      address token1,
      address user,
      uint256 token0Amount,
      uint256 token1Amount,
      uint256 deadline,
      bool isNative
   ) external payable returns (uint256 lp);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

// interfaces
import "@algoblocks/zap/contracts/interfaces/IAlgoblocksZapFeatureUpgradeable.sol";
import "./interfaces/IAlgoblocksRouterUpgradeable.sol";

// contracts
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@algoblocks/token-transfers/contracts/AlgoblocksSafeWithdrawUpgradeable.sol";
import "./metatx/ERC2771ContextUpgradeable.sol";

/**
 * @title The Algoblocks router Contract
 * @author Algoblocks
 * @notice The smart common router of algoblocks to execute swaps, zaps
 * with multiple supported protocols
 * @dev The smart contract is designed to upgradeable via EIP1967 proxy standard
 */
contract AlgoblocksRouterUpgradeable is
   Initializable,
   ERC2771ContextUpgradeable,
   PausableUpgradeable,
   AlgoblocksSafeWithdrawUpgradeable,
   ReentrancyGuardUpgradeable,
   IAlgoblocksRouterUpgradeable
{
   struct FeeConfig {
      // The account of fee recipient
      address feeRecipient;
      // The percentage of fee charge to develop algoblocks
      uint256 feePercentage;
   }

   /// @dev The fee side status
   enum FeeSide {
      To,
      From,
      None
   }

   /// @notice The contract address of swap aggregator
   address public constant SWAP_AGGREGATOR = 0xDef1C0ded9bec7F1a1670819833240f027b25EfF;

   /// @notice The contract address of native chain token
   address public constant NATIVE_CHAIN_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

   /// @notice The fee denominator to divide fee percentage
   uint256 public constant FEE_DENOMINATOR = 100000000;

   /// @notice The fee configuration of algoblocks
   FeeConfig public feeConfig;

   /// @dev The list of supported zap adapters of algoblocks
   mapping(bytes4 => address) private _zapAdapters;

   /// @dev The list of supported fee tokens which algoblocks charging on swaps & zaps
   mapping(address => bool) public supportedFeeTokens;

   /**
    * @notice Initialize AlgoblocksRouterUpgradeable contract
    * @param trustedForwarder_ The contract address of trusted forwarder
    */
   function __AlgoblocksRouterUpgradeable_init(address trustedForwarder_) external initializer {
      __AlgoblocksSafeWithdrawUpgradeable_init();
      _setTrustedForwarder(trustedForwarder_);
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function setZapAdapters(bytes4 zapAdapterId, address zapAdapter) external onlyOwner {
      require(zapAdapterId != bytes4(0) && zapAdapter != address(0), "INVALID_ARGS");
      _zapAdapters[zapAdapterId] = zapAdapter;
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function setFeeConfig(address feeRecipient, uint256 feePercentage) external onlyOwner {
      require(feeRecipient != address(0), "INVALID_FEE_RECIPIENT");
      require(feePercentage != 0 && feePercentage < FEE_DENOMINATOR, "INVALID_FEE_PERCENTAGE");
      feeConfig = FeeConfig(feeRecipient, feePercentage);
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function setSupportedFeeTokens(address[] memory tokens, bool[] memory flags) external onlyOwner {
      uint8 tokensCount = uint8(tokens.length);
      require(tokensCount > 0 && tokensCount == flags.length, "MISMATCH_ARGUMENTS");
      for (uint8 k = 0; k < tokensCount; k++) {
         require(tokens[k] != address(0), "INVALID_FEE_TOKEN");
         supportedFeeTokens[tokens[k]] = flags[k];
      }
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function swap(
      address tokenA,
      address tokenB,
      uint256 amount,
      bytes memory swapCallData
   ) external payable nonReentrant whenNotPaused {
      _extractTokens(SWAP_AGGREGATOR, tokenA, amount);
      uint256 outAmount = _swap(SWAP_AGGREGATOR, tokenA, tokenB, amount, swapCallData, true);
      _transferFunds(tokenB, _msgSender(), outAmount);
      emit Swap(_msgSender(), tokenA, tokenB, amount, outAmount);
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function zap(
      bytes4 zapAdapterId,
      address zapToken,
      uint256 zapAmount,
      bytes[] memory swapCallDatas,
      bytes memory zapCallData
   ) external payable nonReentrant whenNotPaused {
      // decode the zap calldata
      (address tokenA, address tokenB, uint256 deadline) = abi.decode(zapCallData, (address, address, uint256));
      require(zapAmount > 0, "INVALID_ZAP_AMOUNT");
      address zapAdapter = _validateZap(zapAdapterId, tokenA, tokenB);

      if (zapToken == NATIVE_CHAIN_TOKEN) {
         require(msg.value > 0 && msg.value == zapAmount, "INVALID_ZAP_VALUE");
      } else {
         require(zapToken != address(0), "INVALID_ZAP_TOKEN");
         require(msg.value == 0, "INVALID_ZAP_TRANSACTION");
         TransfersExecutionUtils.executeTransferFrom(zapToken, _msgSender(), address(this), zapAmount);
         TransfersExecutionUtils.checkAllownaceThenExecuteApprove(zapToken, SWAP_AGGREGATOR);
      }

      bool takeFee = true;
      if (supportedFeeTokens[zapToken]) {
         zapAmount = _chargeProtocolFee(zapToken, zapAmount);
         takeFee = false;
      }

      (uint256 tokenADesired, uint256 tokenBDesired) = _getZapTokens(
         zapToken,
         tokenA,
         tokenB,
         zapAmount,
         swapCallDatas,
         takeFee
      );

      // block scoping see https://soliditydeveloper.com/stacktoodeep
      {
         uint256 newZapAmount = zapAmount;
         _zap(zapToken, zapAdapter, tokenA, tokenB, tokenADesired, tokenBDesired, deadline, newZapAmount);
      }
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function directZap(
      bytes4 zapAdapterId,
      address tokenA,
      address tokenB,
      uint256 amountA,
      uint256 amountB,
      uint256 deadline
   ) external payable nonReentrant whenNotPaused {
      address zapAdapter = _validateZap(zapAdapterId, tokenA, tokenB);
      require(tokenA != NATIVE_CHAIN_TOKEN, "TOKENA_IS_NATIVE");
      bool isNative = tokenB == NATIVE_CHAIN_TOKEN;
      uint256 ethValue;

      if (isNative) {
         require(msg.value == amountB, "INVALID_VALUE");
         TransfersExecutionUtils.executeTransferFrom(tokenA, _msgSender(), zapAdapter, amountA);
         ethValue = msg.value;
      }
      // when both tokens are ERC20 tokens
      else {
         require(msg.value == 0, "DIRECT_ZAP_FAILED");
         TransfersExecutionUtils.executeTransferFrom(tokenA, _msgSender(), zapAdapter, amountA);
         TransfersExecutionUtils.executeTransferFrom(tokenB, _msgSender(), zapAdapter, amountB);
      }

      uint256 lp = IAlgoblocksZapFeatureUpgradeable(zapAdapter).zap{value: ethValue}(
         tokenA,
         tokenB,
         _msgSender(),
         amountA,
         amountB,
         deadline,
         isNative
      );

      emit Zap(_msgSender(), address(0), tokenA, tokenB, 0, amountA, amountB, lp);
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function pause() external onlyOwner {
      _pause();
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function unpause() external onlyOwner {
      _unpause();
   }

   /**
    * @inheritdoc IAlgoblocksRouterUpgradeable
    */
   function updateTrustedForwarder(address trustedForwarder) external onlyOwner {
      _setTrustedForwarder(trustedForwarder);
   }

   /**
    * @notice Returns token amounts for zaps
    * @param _zapToken The contract address of zap token
    * @param _tokenA The contract address of tokenA
    * @param _tokenB The contract address of tokenB
    * @param _zapAmount The amount of zap
    * @param _swapCallDatas The payload calldata of swaps
    * @param _takeFee The identifier to take swap fee
    * @return tokenADesired The desired amount to put tokenA
    * @return tokenBDesired The desired amount to put tokenB
    */
   function _getZapTokens(
      address _zapToken,
      address _tokenA,
      address _tokenB,
      uint256 _zapAmount,
      bytes[] memory _swapCallDatas,
      bool _takeFee
   ) internal returns (uint256 tokenADesired, uint256 tokenBDesired) {
      // if zap token equal to TokenA
      if (_zapToken == _tokenA) {
         tokenADesired = _zapAmount / 2;
         tokenBDesired = _swap(SWAP_AGGREGATOR, _zapToken, _tokenB, tokenADesired, _swapCallDatas[0], _takeFee);
      }

      // if zap token equal to TokenB
      if (_zapToken == _tokenB) {
         tokenBDesired = _zapAmount / 2;
         tokenADesired = _swap(SWAP_AGGREGATOR, _zapToken, _tokenA, tokenBDesired, _swapCallDatas[0], _takeFee);
      }

      // not both
      if ((_zapToken != _tokenA && _zapToken != _tokenB)) {
         uint256 halfZapAmount = _zapAmount / 2;
         tokenADesired = _swap(SWAP_AGGREGATOR, _zapToken, _tokenA, halfZapAmount, _swapCallDatas[0], _takeFee);
         tokenBDesired = _swap(SWAP_AGGREGATOR, _zapToken, _tokenB, halfZapAmount, _swapCallDatas[1], _takeFee);
      }
   }

   /**
    * @notice Performs zap
    * @param _zapToken The contract address of zap token
    * @param _zapAdapter The contract address of zap adapter
    * @param _tokenA The contract address of tokenA
    * @param _tokenB The contract address of tokenB
    * @param _tokenADesired The desired amount of tokenA to zap
    * @param _tokenBDesired The desired amount of tokenB to zap
    * @param _deadline The zap transaction deadline
    * @param _zapAmount The amount to zap
    */
   function _zap(
      address _zapToken,
      address _zapAdapter,
      address _tokenA,
      address _tokenB,
      uint256 _tokenADesired,
      uint256 _tokenBDesired,
      uint256 _deadline,
      uint256 _zapAmount
   ) internal {
      // fund transfers
      (uint256 ethValue, bool isNative) = _transfersTokensToZapAdapter(
         _zapAdapter,
         _tokenA,
         _tokenB,
         _tokenADesired,
         _tokenBDesired
      );
      uint256 lp = IAlgoblocksZapFeatureUpgradeable(_zapAdapter).zap{value: ethValue}(
         _tokenA,
         _tokenB,
         _msgSender(),
         _tokenADesired,
         _tokenBDesired,
         _deadline,
         isNative
      );

      emit Zap(_msgSender(), _zapToken, _tokenA, _tokenB, _zapAmount, _tokenADesired, _tokenBDesired, lp);
   }

   /**
    * @notice Transfers tokens to zap adapter & Returns eth value and
    * status of native chain token
    * @param _zapAdapter The contract address of zapAdapter
    * @param _tokenA The contract address of tokenA
    * @param _tokenB The contract address of tokenB
    * @param _tokenADesired The desired value of tokenA
    * @param _tokenBDesired The desired value of tokenB
    * @return ethValue The value of eth to send on zap adapter contract
    * @return isNative The status of native token availablity
    */
   function _transfersTokensToZapAdapter(
      address _zapAdapter,
      address _tokenA,
      address _tokenB,
      uint256 _tokenADesired,
      uint256 _tokenBDesired
   ) internal returns (uint256 ethValue, bool isNative) {
      // tokenA is equal to native chain token
      require(_tokenA != NATIVE_CHAIN_TOKEN, "TOKENA_IS_NATIVE");

      // when tokenB is equal to native chain token
      if (_tokenB == NATIVE_CHAIN_TOKEN) {
         TransfersExecutionUtils.executeTransfer(_tokenA, _zapAdapter, _tokenADesired);
         isNative = true;
         ethValue = _tokenBDesired;
      }
      // no one
      else {
         TransfersExecutionUtils.executeTransfer(_tokenA, _zapAdapter, _tokenADesired);
         TransfersExecutionUtils.executeTransfer(_tokenB, _zapAdapter, _tokenBDesired);
      }
   }

   /**
    * @notice Validate zaps
    * @dev Throws errors on validation failure
    * @param _zapAdapterId The id of specific zap adapter
    * @param _tokenA The contract address of tokenA
    * @param _tokenB The contract address of tokenB
    * @return zapAdapter The contract address of zap adapter
    */
   function _validateZap(
      bytes4 _zapAdapterId,
      address _tokenA,
      address _tokenB
   ) internal view returns (address zapAdapter) {
      require(_tokenA != _tokenB, "IDENTICAL_TOKENS");
      require(_tokenA != address(0) && _tokenB != address(0), "INVALID_TOKEN_ADDRESS");
      zapAdapter = _zapAdapters[_zapAdapterId];
      require(zapAdapter != address(0), "ZAP_APDAPTER_NOT_SUPPORTED");
   }

   /**
    * @notice Perform swaps
    * @param _aggregator The contract address of dex aggregator
    * @param _tokenA The contract address of tokenA
    * @param _tokenB The contract address of tokenB
    * @param _amount The amount to swap
    * @param _swapCallData The payload calldata for swap
    * @param _takeFee The status to charge fees on swap
    * @return outAmount The output amount
    */
   function _swap(
      address _aggregator,
      address _tokenA,
      address _tokenB,
      uint256 _amount,
      bytes memory _swapCallData,
      bool _takeFee
   ) internal returns (uint256 outAmount) {
      FeeSide feeside = _deriveSwapFeeSide(_tokenA, _tokenB);
      if (_takeFee && feeside == FeeSide.From) {
         _amount = _chargeProtocolFee(_tokenA, _amount);
      }
      uint256 ethValue = _tokenA == NATIVE_CHAIN_TOKEN ? _amount : 0;
      (bool success, ) = _aggregator.call{value: ethValue}(_swapCallData);
      require(success, "SWAP_FAILED");

      outAmount = _tokenB == NATIVE_CHAIN_TOKEN ? address(this).balance : IERC20(_tokenB).balanceOf(address(this));
      if (_takeFee && feeside == FeeSide.To) {
         outAmount = _chargeProtocolFee(_tokenB, outAmount);
      }
      require(outAmount > 0, "INSUFFICIENT_OUT_AMOUNT");
   }

   /**
    * @notice Charge protocol fee
    * @param _token The contract address of token
    * @param _amount The amount to charge as fee
    */
   function _chargeProtocolFee(address _token, uint256 _amount) internal returns (uint256) {
      uint256 fees = (_amount * feeConfig.feePercentage) / FEE_DENOMINATOR;
      _transferFunds(_token, feeConfig.feeRecipient, fees);
      return _amount - fees;
   }

   /**
    * @notice Derive swap fee side
    * @param _tokenA The contract address tokenA
    * @param _tokenB The contract address tokenB
    * @return feeSide The actual fee side
    */
   function _deriveSwapFeeSide(address _tokenA, address _tokenB) internal view returns (FeeSide) {
      bool isSellSide = supportedFeeTokens[_tokenA];
      bool isBuySide = supportedFeeTokens[_tokenB];
      // if fee token fall on sell side
      if (isSellSide && !isBuySide) {
         return FeeSide.From;
      }
      // if fee token fall on buy side
      else if (isBuySide && !isSellSide) {
         return FeeSide.To;
      }
      // if fee token fall on both side
      else if (isSellSide && isBuySide) {
         return FeeSide.From;
      }
      // nothing
      else {
         return FeeSide.None;
      }
   }

   /**
    * @notice Extract tokens from algoblocks user
    * @param _aggregator The contract address of dex aggregator
    * @param _token The contract address of token
    * @param _amount The amount to extract
    */
   function _extractTokens(
      address _aggregator,
      address _token,
      uint256 _amount
   ) internal {
      if (_token == NATIVE_CHAIN_TOKEN) {
         require(msg.value > 0 && msg.value == _amount, "INVALID_VALUE");
      } else {
         require(msg.value == 0, "SWAP_TX_FAILED");
         TransfersExecutionUtils.executeTransferFrom(_token, _msgSender(), address(this), _amount);
         TransfersExecutionUtils.checkAllownaceThenExecuteApprove(_token, _aggregator);
      }
   }

   /**
    * @notice Transfer funds
    * @param _token The contract address of token
    * @param _recipient The account of recipient
    * @param _amount The amount to transfer
    */
   function _transferFunds(
      address _token,
      address _recipient,
      uint256 _amount
   ) internal {
      if (_token == NATIVE_CHAIN_TOKEN) {
         TransfersExecutionUtils.executeTransferETH(_recipient, _amount);
      } else {
         TransfersExecutionUtils.executeTransfer(_token, _recipient, _amount);
      }
   }

   /**
    * @inheritdoc ERC2771ContextUpgradeable
    */
   function _msgSender()
      internal
      view
      override(ERC2771ContextUpgradeable, ContextUpgradeable)
      returns (address sender)
   {
      sender = ERC2771ContextUpgradeable._msgSender();
   }

   /**
    * @inheritdoc ERC2771ContextUpgradeable
    */
   function _msgData() internal view override(ERC2771ContextUpgradeable, ContextUpgradeable) returns (bytes calldata) {
      return ERC2771ContextUpgradeable._msgData();
   }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.11;

/**
 * @title The Interface of AlgoblocksRouterUpgradeable
 * @author Algoblocks
 * @notice Perform swaps & zaps
 */
interface IAlgoblocksRouterUpgradeable {
   /**
    * @notice Emit on each swaps
    * @param user The account of user
    * @param tokenA The contract address of tokenA
    * @param tokenB The contract address of tokenB
    * @param inAmount The amount of input
    * @param outAmount The amount of swap output
    */
   event Swap(address user, address tokenA, address tokenB, uint256 inAmount, uint256 outAmount);

   /**
    * @notice Emit on each zaps of algoblocks
    * @param user The account of user
    * @param zapToken The contract address of zap token
    * @param tokenA The contract address of tokenA
    * @param tokenB The contract address of tokenB
    * @param zapAmount The zap amount
    * @param tokenADesired The desired amount of tokenA
    * @param tokenBDesired The desired amount of tokenB
    * @param lp The minted lp
    */
   event Zap(
      address user,
      address zapToken,
      address tokenA,
      address tokenB,
      uint256 zapAmount,
      uint256 tokenADesired,
      uint256 tokenBDesired,
      uint256 lp
   );

   /**
    * @notice Perform swaps
    * @param tokenA The contract address of tokenA
    * @param tokenB The contract address of tokenB
    * @param amount The swap amount
    * @param swapCallData The payload calldata of swap
    */
   function swap(
      address tokenA,
      address tokenB,
      uint256 amount,
      bytes calldata swapCallData
   ) external payable;

   /**
    * @notice Perform zaps
    * @param zapAdapterId The uniqueId of specific zap adapter
    * @param zapToken The contract address of token
    * @param zapAmount The amount to zap
    * @param swapCallDatas The list of payload calldatas for swaps
    * @param zapCallData The payload calldata of zap
    */
   function zap(
      bytes4 zapAdapterId,
      address zapToken,
      uint256 zapAmount,
      bytes[] calldata swapCallDatas,
      bytes calldata zapCallData
   ) external payable;

   /**
    * @notice Performs direct zaps
    * @param zapAdapterId The uniqueId of specific zap adapter
    * @param tokenA The contract address of tokenA
    * @param tokenB The contract address of tokenB
    * @param amountA The amount of tokenA to deposit
    * @param amountB The amount of tokenB to deposit
    * @param deadline The zap transaction deadline
    */
   function directZap(
      bytes4 zapAdapterId,
      address tokenA,
      address tokenB,
      uint256 amountA,
      uint256 amountB,
      uint256 deadline
   ) external payable;

   /**
    * @notice Sets supported fee tokens of algoblocks
    * @dev Can execute by only owner
    * @param tokens The list of supported fee tokens
    * @param flags The list of status
    */
   function setSupportedFeeTokens(address[] memory tokens, bool[] memory flags) external;

   /**
    * @notice Sets fee config of algoblocks
    * @dev Can execute by only owner
    * @param feeRecipient The account of fee recipient
    * @param feePercentage The fee percentage of algoblocks
    */
   function setFeeConfig(address feeRecipient, uint256 feePercentage) external;

   /**
    * @notice Sets supported zap adapters
    * @dev Can execute by only owner
    * @param zapAdapterId The uniqueId of zap adapter
    * @param zapAdapter The contract address of zap adapter
    */
   function setZapAdapters(bytes4 zapAdapterId, address zapAdapter) external;

   /**
    * @notice Pause algoblocks router
    * @dev Execute by only owner
    */
   function pause() external;

   /**
    * @notice Unpause algoblocks router
    * @dev Execute by only owner
    */
   function unpause() external;

   /**
    * @notice Updates trusted forwarder
    * @param trustedForwarder The contract address of trusted forwarder
    */
   function updateTrustedForwarder(address trustedForwarder) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.9;

// contracts
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
   /// @notice The contract address of trusted forwarder
   address private _trustedForwarder;

   function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
      return forwarder == _trustedForwarder;
   }

   /**
    * @notice Sets trusted forwarder
    * @param trustedForwarder_ The contract address of trusted forwarder
    */
   function _setTrustedForwarder(address trustedForwarder_) internal {
      require(trustedForwarder_ != address(0), "INVALID_TRUSTED_FORWARDER");
      _trustedForwarder = trustedForwarder_;
   }

   function _msgSender() internal view virtual override returns (address sender) {
      if (isTrustedForwarder(msg.sender)) {
         // The assembly code is more direct than the Solidity version using `abi.decode`.
         /// @solidity memory-safe-assembly
         assembly {
            sender := shr(96, calldataload(sub(calldatasize(), 20)))
         }
      } else {
         return super._msgSender();
      }
   }

   function _msgData() internal view virtual override returns (bytes calldata) {
      if (isTrustedForwarder(msg.sender)) {
         return msg.data[:msg.data.length - 20];
      } else {
         return super._msgData();
      }
   }

   /**
    * @dev This empty reserved space is put in place to allow future versions to add new
    * variables without shifting down storage in the inheritance chain.
    * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
    */
   uint256[50] private __gap;
}