// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity 0.8.17;

/* solhint-disable reason-string */

import "./EIP4337Account/EIP4337Account.sol";
import "./AccountManager/BaseAccount.sol";
import "./AccountManager/TransactionManager.sol";
import "./AccountManager/SecurityManager.sol";
import "./AccountManager/GuardianManager.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./Utils.sol";

/**
 * @dev Account implementation.
 */
contract Account is EIP4337Account, BaseAccount, Initializable, TransactionManager, SecurityManager, GuardianManager {
    enum OwnerSignature {
        Required, // Owner required
        Disallowed, // Guardians only
        Invalid // Invalid called function
    }

    /* solhint-disable */
    error NotTheOwner();
    error NotTheOwnerOrTheEntryPoint();

    /* solhint-enable */

    /**
     * @dev Setup the verifirst data for account. Can only call one time
     * @param accountEntryPoint Entrypoint of the account
     * @param accountOwner EOA owner of the account
     * @param firstGuardian The first guardian
     */
    function initialize(address accountEntryPoint, address accountOwner, address firstGuardian) external initializer {
        addGuardianIntoStorage(firstGuardian);
        entryPoint = IEntryPoint(accountEntryPoint);
        owner = accountOwner;
    }

    /**
     * @dev return contract's EOA owner
     */
    function getOwner() internal view override returns (address) {
        return owner;
    }

    /**
     * @dev Validate userOp signature
     */
    function validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        address aggregator
    ) internal view override returns (uint256 sigTimeRange) {
        (aggregator);
        bytes32 signHash = Utils.toEthSignedMessageHash(userOpHash);
        bytes memory signatures = userOp.signature;
        if (userOp.initCode.length == 0 && userOp.callData.length < 4) {
            return SIG_VALIDATION_FAILED;
        }
        if (userOp.initCode.length > 0) {
            if (owner != Utils.recoverSigner(signHash, signatures, 0)) {
                return SIG_VALIDATION_FAILED;
            }
        }
        if (userOp.callData.length >= 4) {
            (uint256 requiredSignatures, OwnerSignature option) = getRequiredSignatures(userOp.callData);
            if (option == OwnerSignature.Invalid) {
                return SIG_VALIDATION_FAILED;
            }
            if (!validSignatureFormat(requiredSignatures, signatures.length)) {
                return SIG_VALIDATION_FAILED;
            }
            if (!validateSigner(signHash, signatures, option)) {
                return SIG_VALIDATION_FAILED;
            }
        }
        return 0;
    }

    /**
     * @dev Check signatures and signature requirement
     */
    function validateSigner(
        bytes32 signHash,
        bytes memory signatures,
        OwnerSignature option
    ) internal view returns (bool) {
        address[] memory guardians;
        if (option != OwnerSignature.Required || signatures.length > 65) {
            guardians = getGuardians(); // guardians are only read if they may be needed
        }
        bool isGuardian;
        address lastSigner = address(0);
        for (uint256 i = 0; i < signatures.length / 65; i++) {
            address signer = Utils.recoverSigner(signHash, signatures, i);
            if (i == 0) {
                if (option == OwnerSignature.Required) {
                    // First signer must be owner
                    if (getOwner() != signer) {
                        return false;
                    }
                    continue;
                }
            }
            if (signer <= lastSigner) {
                return false;
            }
            lastSigner = signer;
            (isGuardian, guardians) = Utils.isGuardianOrGuardianSigner(guardians, signer);
            if (!isGuardian) {
                return false;
            }
        }
        return true;
    }

    /**
     * @notice Get require signatures information.
     * @param data The data for the relayed transaction
     * @return tuple (number of require signatures, signature type)
     */
    function getRequiredSignatures(bytes calldata data) public view returns (uint256, OwnerSignature) {
        //TODO: add the other case
        bytes4 methodId = Utils.functionPrefix(data);
        if (methodId == TransactionManager.execBatchFromEntryPoint.selector) {
            (address[] memory targets, uint256[] memory values, bytes[] memory funcs) = abi.decode(
                data[4:],
                (address[], uint256[], bytes[])
            );
            (values);
            address[] memory spenders = Utils.recoverSpenders(targets, funcs);
            if (isWhitelisted(spenders)) return (1, OwnerSignature.Required);
            // owner + majority of guardians
            return (majorityOfGuardians() + 1, OwnerSignature.Required);
        }

        if (methodId == TransactionManager.execFromEntryPoint.selector) {
            (address target, uint256 value, bytes memory func) = abi.decode(data[4:], (address, uint256, bytes));
            (value);
            address spender = Utils.recoverSpender(target, func);
            if (isWhitelisted(spender)) return (1, OwnerSignature.Required);
            // owner + majority of guardians
            return (majorityOfGuardians() + 1, OwnerSignature.Required);
        }
        if (methodId == TransactionManager.removeFromWhitelist.selector || methodId == SecurityManager.lock.selector) {
            // require owner
            return (1, OwnerSignature.Required);
        }
        if (
            methodId == TransactionManager.addToWhitelist.selector ||
            methodId == SecurityManager.unlock.selector ||
            methodId == GuardianManager.addGuardian.selector ||
            methodId == GuardianManager.cancelGuardianAddition.selector ||
            methodId == GuardianManager.revokeGuardian.selector ||
            methodId == GuardianManager.cancelGuardianRevokation.selector ||
            methodId == SecurityManager.cancelRecovery.selector ||
            methodId == EIP4337Account.updateEntryPoint.selector
        ) {
            // owner + majority of guardians
            return (majorityOfGuardians() + 1, OwnerSignature.Required);
        }

        if (methodId == SecurityManager.executeRecovery.selector) {
            // majority of guardians
            return (majorityOfGuardians(), OwnerSignature.Disallowed);
        }
        return (0, OwnerSignature.Invalid);
    }

    function majorityOfGuardians() internal view returns (uint256) {
        if (guardians.length == 0) return 0;
        if (guardians.length % 2 == 0) return Utils.ceil(guardians.length, 2) + 1;
        return Utils.ceil(guardians.length, 2);
    }

    /**
     * @notice Check if signature in right format
     * @param requireSignature Number of signatures needed
     * @param signatureLength Signature bytes length
     */
    function validSignatureFormat(uint256 requireSignature, uint256 signatureLength) internal pure returns (bool) {
        if (requireSignature == 0 || requireSignature * 65 != signatureLength) return false;
        return true;
    }

    function onlyOwner() internal view override(BaseAccount, EIP4337Account) {
        if (msg.sender != getOwner()) revert NotTheOwner();
    }

    function onlyEntryPoint() internal view override(BaseAccount, EIP4337Account) {
        require(msg.sender == address(entryPoint), "Account: caller must be an entrypoint");
    }

    function onlyOwnerOrEntryPoint() internal view override(BaseAccount) {
        if (msg.sender != owner && msg.sender != address(entryPoint)) revert NotTheOwnerOrTheEntryPoint();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @dev Basic contract for implementing account's features.
 */
abstract contract BaseAccount {
    /**
     * @notice the struct contains the info about a guardian
     */
    struct GuardianInfo {
        bool exists;
        uint128 index;
    }

    // The security window
    uint256 internal constant SECURITY_WINDOW = 3 minutes;

    /**
     * @notice The owner of account.
     */
    address public owner;

    /**
     * @notice Lock related states.
     */
    bool public isLocked;

    /**
     * @notice the signature of the method that set the last lock
     */
    bytes4 public locker;

    /**
     * @notice account specific storage
     */
    mapping(address => uint256) internal whitelist;

    /**
     * @notice the list of guardians
     */
    address[] internal guardians;

    /**
     * @notice the info about guardians
     */
    mapping(address => GuardianInfo) internal infoGuardians;

    /**
     * @notice the time at which a guardian addition or revokation will be confirmabled
     */
    mapping(bytes32 => uint256) internal pendingGuardianPeriod;

    /* solhint-disable */
    error NotLocked();
    error NotUnlocked();
    error NotInWhitelist();
    error OwnerMustNotInWhitelist();
    error AccountAlreadyAddedIntoWhitelist();
    error AccountNotInWhitelist();

    /* solhint-enable */

    /**
     * @notice Returns the number of guardians for this account.
     * @return the number of guardians.
     */
    function guardianCount() public view returns (uint256) {
        return guardians.length;
    }

    /**
     * @notice Checks if an account is active guardian for this account.
     * @param guardian The account.
     * @return true if the account is an active guardian for this account.
     */
    function isGuardian(address guardian) public view returns (bool) {
        return infoGuardians[guardian].exists;
    }

    /**
     * @dev Helper method to lock the account
     */
    function setLock(bool locked, bytes4 lockerFunction) internal {
        isLocked = locked;
        locker = lockerFunction;
    }

    /**
     * @notice add new or remove an account to whitelist
     * @param targets The account to add/remove.
     * @param value The epoch time at which an account starts to be whitelisted, or zero if the account is not whitelisted
     */
    function setWhitelist(address[] calldata targets, uint256 value) internal {
        for (uint256 i = 0; i < targets.length; i++) {
            if (value == 0 && whitelist[targets[i]] == 0) revert AccountNotInWhitelist();
            if (value > 0 && whitelist[targets[i]] > 0) revert AccountAlreadyAddedIntoWhitelist();
            if (targets[i] == owner) revert OwnerMustNotInWhitelist();
            whitelist[targets[i]] = value;
        }
    }

    /**
     * @notice Gets the whitelist state of an account for a account.
     * @param target The account.
     * @return The epoch time at which an account starts to be whitelisted, or zero if the account is not whitelisted
     */
    function getWhitelist(address target) internal view returns (uint256) {
        return whitelist[target];
    }

    /**
     * @dev Check if target is in whitelist or not
     */
    function isWhitelisted(address target) internal view returns (bool) {
        uint256 whitelistAfter = getWhitelist(target);
        // solhint-disable-next-line not-rely-on-time
        return whitelistAfter > 0 && whitelistAfter < block.timestamp;
    }

    function onlyWhenLocked() internal view {
        if (!isLocked) revert NotLocked();
    }

    function onlyWhenUnlocked() internal view {
        if (isLocked) revert NotUnlocked();
    }

    function onlyOwner() internal view virtual {}

    function onlyEntryPoint() internal view virtual {}

    function onlyOwnerOrEntryPoint() internal view virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BaseAccount.sol";

/**
 * @dev Implementation of guardian-related features of the account.
 */
abstract contract GuardianManager is BaseAccount {
    // The security period to add/remove guardians
    uint256 internal constant SECURITY_PERIOD = 3 minutes;

    // *************** Errors *************************** //
    /* solhint-disable */
    error GuardianCannotBeOwner();
    error DuplicateGuardian();
    error IsNotAnEOAOrSmartAccount();
    error GuardianDoesNotExist();

    error DuplicatePendingAddition();
    error UnknownPendingAddition();
    error PendingAddtionNotOver();
    error PendingAdditionExpired();
    error DuplicatePendingRevokation();
    error UnknownPendingRevokation();
    error PendingRevokationNotOver();
    error PendingRevokationExpired();
    /* solhint-enable */

    // *************** Events *************************** //

    event GuardianAdditionRequested(address indexed guardian, uint256 executeAfter);
    event GuardianRevokationRequested(address indexed guardian, uint256 executeAfter);
    event GuardianAdditionCancelled(address indexed guardian);
    event GuardianRevokationCancelled(address indexed guardian);
    event GuardianAdded(address indexed guardian);
    event GuardianRevoked(address indexed guardian);

    // *************** Guardian functions ************************ //

    /**
     * @notice Lets add a guardian to this account.
     * The first guardian is added immediately. All following additions must be confirmed
     * by calling the finalizeGuardianAddition() method.
     * @param guardian The guardian to add.
     */
    function addGuardian(address guardian) external {
        onlyEntryPoint();
        onlyWhenUnlocked();
        if (owner == guardian) revert GuardianCannotBeOwner();
        if (isGuardian(guardian)) revert DuplicateGuardian();

        // Guardians must either be an EOA or a contract with an owner()
        // method that returns an address with a 25000 gas stipend.
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = guardian.call{gas: 25000}(abi.encodeWithSignature("owner()"));
        if (!success) revert IsNotAnEOAOrSmartAccount();

        bytes32 id = keccak256(abi.encodePacked(guardian, "addition"));
        // solhint-disable-next-line not-rely-on-time
        if (pendingGuardianPeriod[id] > 0 && block.timestamp <= pendingGuardianPeriod[id] + SECURITY_WINDOW)
            revert DuplicatePendingAddition();
        // solhint-disable-next-line not-rely-on-time
        pendingGuardianPeriod[id] = block.timestamp + SECURITY_PERIOD;
        // solhint-disable-next-line not-rely-on-time
        emit GuardianAdditionRequested(guardian, block.timestamp + SECURITY_PERIOD);
    }

    /**
     * @notice Confirms the pending addition of a guardian to this account.
     * The method must be called during the confirmation window and can be called by anyone to enable orchestration.
     * @param guardian The guardian.
     */
    function finalizeGuardianAddition(address guardian) external {
        onlyWhenUnlocked();
        bytes32 id = keccak256(abi.encodePacked(guardian, "addition"));
        if (pendingGuardianPeriod[id] == 0) revert UnknownPendingAddition();
        // solhint-disable-next-line not-rely-on-time
        if (pendingGuardianPeriod[id] >= block.timestamp) revert PendingAddtionNotOver();
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > pendingGuardianPeriod[id] + SECURITY_WINDOW) revert PendingAdditionExpired();
        addGuardianIntoStorage(guardian);
        emit GuardianAdded(guardian);
        delete pendingGuardianPeriod[id];
    }

    /**
     * @notice Lets cancel a pending guardian addition.
     * @param guardian The guardian.
     */
    function cancelGuardianAddition(address guardian) external {
        onlyEntryPoint();
        onlyWhenUnlocked();
        bytes32 id = keccak256(abi.encodePacked(guardian, "addition"));
        if (pendingGuardianPeriod[id] == 0) revert UnknownPendingAddition();
        delete pendingGuardianPeriod[id];
        emit GuardianAdditionCancelled(guardian);
    }

    /**
     * @notice Lets revoke a guardian from its account.
     * @param guardian The guardian to revoke.
     */
    function revokeGuardian(address guardian) external {
        onlyEntryPoint();
        if (!isGuardian(guardian)) revert GuardianDoesNotExist();
        bytes32 id = keccak256(abi.encodePacked(guardian, "revokation"));
        // solhint-disable-next-line not-rely-on-time
        if (pendingGuardianPeriod[id] > 0 && block.timestamp <= pendingGuardianPeriod[id] + SECURITY_WINDOW)
            revert DuplicatePendingRevokation();
        // solhint-disable-next-line not-rely-on-time
        pendingGuardianPeriod[id] = block.timestamp + SECURITY_PERIOD;
        // solhint-disable-next-line not-rely-on-time
        emit GuardianRevokationRequested(guardian, block.timestamp + SECURITY_PERIOD);
    }

    /**
     * @notice Confirms the pending revokation of a guardian to a account.
     * The method must be called during the confirmation window and can be called by anyone to enable orchestration.
     * @param guardian The guardian.
     */
    function finalizeGuardianRevokation(address guardian) external {
        bytes32 id = keccak256(abi.encodePacked(guardian, "revokation"));
        if (pendingGuardianPeriod[id] == 0) revert UnknownPendingRevokation();
        // solhint-disable-next-line not-rely-on-time
        if (pendingGuardianPeriod[id] >= block.timestamp) revert PendingRevokationNotOver();
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > pendingGuardianPeriod[id] + SECURITY_WINDOW) revert PendingRevokationExpired();
        removeGuardianFromStorage(guardian);
        emit GuardianRevoked(guardian);
        delete pendingGuardianPeriod[id];
    }

    /**
     * @notice Lets cancel a pending guardian revokation.
     * @param guardian The guardian.
     */
    function cancelGuardianRevokation(address guardian) external {
        onlyEntryPoint();
        onlyWhenUnlocked();
        bytes32 id = keccak256(abi.encodePacked(guardian, "revokation"));
        if (pendingGuardianPeriod[id] == 0) revert UnknownPendingRevokation();
        delete pendingGuardianPeriod[id];
        emit GuardianRevokationCancelled(guardian);
    }

    function addGuardianIntoStorage(address guardian) internal {
        infoGuardians[guardian].exists = true;
        guardians.push(guardian);
        infoGuardians[guardian].index = uint128(guardians.length - 1);
    }

    function removeGuardianFromStorage(address guardian) internal {
        address lastGuardian = guardians[guardians.length - 1];
        if (guardian != lastGuardian) {
            uint128 targetIndex = infoGuardians[guardian].index;
            guardians[targetIndex] = lastGuardian;
            infoGuardians[lastGuardian].index = targetIndex;
        }
        delete infoGuardians[guardian];
        guardians.pop();
    }

    /**
     * @notice Gets the list of guaridans for a account.
     * @return the list of guardians.
     */
    function getGuardians() public view returns (address[] memory) {
        return guardians;
    }

    /**
     * @notice Gets the info of an guaridan for this account.
     * @param guardian The guardian.
     * @return the info of an guaridan.
     */
    function getGuardianInfo(address guardian) external view returns (GuardianInfo memory) {
        return infoGuardians[guardian];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./BaseAccount.sol";

/**
 * @dev Implementation of transaction-related features of the account.
 */
abstract contract SecurityManager is BaseAccount {
    uint256 internal constant RECOVERY_PERIOD = 3 minutes;

    // Recovery related variables
    /**
     * @notice new owner of the account if succeed to recovery.
     */
    address public recoveryOwner;

    /**
     * @notice time at which recovery can be finalized.
     */
    uint256 public recoveryExecuteAfter;

    /**
     * @notice the number of guardians at recovery time.
     */
    uint256 public recoveryGuardianCount;

    /* solhint-disable */
    error WrongLocker();
    error NullNewOwner();
    error CannotBeGuardian();
    error OngoingRecovery();
    error NoOngoingRecovery();
    error RecoveryPeriodNotOver();
    error PendingRecoveryExpired();
    /* solhint-enable */
    event Locked();
    event Unlocked();
    event RecoveryExecuted(address indexed recovery, uint256 executeAfter);
    event RecoveryFinalized(address indexed recovery);
    event RecoveryCanceled(address indexed recovery);

    /* --------------------------------------------------------Lock/Unlock---------------------------------------------*/

    /**
     * @notice Lock the account.
     */
    function lock() external {
        onlyOwnerOrEntryPoint();
        onlyWhenUnlocked();
        /* solhint-disable not-rely-on-time */
        setLock(true, SecurityManager.lock.selector);
        emit Locked();
        /* solhint-enable not-rely-on-time */
    }

    /**
     * @notice Unlock the account.
     */
    function unlock() external {
        onlyEntryPoint();
        onlyWhenLocked();
        if (locker != SecurityManager.lock.selector) revert WrongLocker();
        setLock(false, bytes4(0));
        emit Unlocked();
    }

    /* --------------------------------------------------------Recovery---------------------------------------------*/

    /**
     * @notice Lets the guardians start the execution of the recovery procedure.
     * Once triggered the recovery is pending for the security period before it can be finalised.
     * Must be confirmed by N guardians, where N = ceil(Nb Guardians / 2).
     * @param recovery The address to which ownership should be transferred.
     */
    function executeRecovery(address recovery) external {
        onlyEntryPoint();
        notWhenRecovery();
        validateNewOwner(recovery);
        recoveryOwner = recovery;
        // solhint-disable-next-line not-rely-on-time
        recoveryExecuteAfter = block.timestamp + RECOVERY_PERIOD;
        recoveryGuardianCount = guardianCount();
        // solhint-disable-next-line not-rely-on-time
        setLock(true, SecurityManager.executeRecovery.selector);

        emit RecoveryExecuted(recovery, recoveryExecuteAfter);
    }

    /**
     * @notice Finalizes an ongoing recovery procedure if the security period is over.
     * The method is public and callable by anyone to enable orchestration.
     */
    function finalizeRecovery() external {
        onlyWhenRecovery();
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp <= recoveryExecuteAfter) revert RecoveryPeriodNotOver();
        owner = recoveryOwner;
        resetRecovery();

        emit RecoveryFinalized(owner);
    }

    /**
     * @notice Lets the owner cancel an ongoing recovery procedure.
     * Must be confirmed by N guardians, where N = ceil(Nb Guardian at executeRecovery + 1) / 2) - 1.
     */
    function cancelRecovery() external {
        onlyEntryPoint();
        onlyWhenRecovery();
        address newOwner = recoveryOwner;
        resetRecovery();

        emit RecoveryCanceled(newOwner);
    }

    /*-----------------------------------------------Internal function------------------------------------------------*/

    function validateNewOwner(address newOwner) internal view {
        if (newOwner == address(0)) revert NullNewOwner();
        if (isGuardian(newOwner)) revert CannotBeGuardian();
    }

    function notWhenRecovery() internal view {
        // solhint-disable-next-line not-rely-on-time
        if (recoveryExecuteAfter > 0 && block.timestamp <= recoveryExecuteAfter + SECURITY_WINDOW)
            revert OngoingRecovery();
    }

    function onlyWhenRecovery() internal view {
        if (recoveryExecuteAfter == 0) revert NoOngoingRecovery();
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > recoveryExecuteAfter + SECURITY_WINDOW) revert PendingRecoveryExpired();
    }

    /*-----------------------------------------------Private function------------------------------------------------*/
    function resetRecovery() private {
        delete recoveryOwner;
        delete recoveryExecuteAfter;
        delete recoveryGuardianCount;
        setLock(false, bytes4(0));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./BaseAccount.sol";

/**
 * @dev Implementation of transaction-related features of the account.
 */
abstract contract TransactionManager is BaseAccount {
    /* solhint-disable */
    error WrongArrayLength();
    /* solhint-enable */
    uint256 internal constant WHITELIST_PERIOD = 3 minutes;

    /**
     * @dev A transaction executed by low-level call successfully.
     */
    event Invoked(address indexed target, uint256 value, bytes data);

    /**
     * @dev A batch of transactions executed by low-level call successfully.
     */
    event BatchInvoked(address[] target, uint256 value, bytes[] data);
    event WhitelistAdded(address[] target, uint256 whitelistTime);
    event WhitelistRemoved(address[] target);

    /**
     * @dev Called by entryPoint, only after validateUserOp succeeded.
     * @param dest destination address of the transaction
     * @param value value of the transaction.
     * @param func function data for the low-level call
     */
    function execFromEntryPoint(address dest, uint256 value, bytes calldata func) external {
        onlyEntryPoint();
        invoke(dest, value, func);
    }

    /**
     * @dev Called by entryPoint, only after validateUserOp succeeded.
     * Execute a batch of transactions
     * @param dests list destination addresses of the transactions
     * @param values list values of the transactions.
     * @param funcs list function data for the low-level calls
     */
    function execBatchFromEntryPoint(
        address[] calldata dests,
        uint256[] calldata values,
        bytes[] calldata funcs
    ) external {
        onlyEntryPoint();
        batchInvoke(dests, values, funcs);
    }

    /**
     * @dev Execute a sequence of transactions by calling low-level call.
     */
    function batchInvoke(address[] calldata dests, uint256[] calldata values, bytes[] calldata funcs) internal {
        if (dests.length != funcs.length || dests.length != values.length) revert WrongArrayLength();
        uint256 totalValue = 0;
        for (uint256 i = 0; i < dests.length; i++) {
            invoke(dests[i], values[i], funcs[i]);
            totalValue += values[i];
        }
        emit BatchInvoked(dests, totalValue, funcs);
    }

    /**
     * @dev Execute a transaction by calling low-level call.
     */
    function invoke(address target, uint256 value, bytes memory data) internal {
        onlyWhenUnlocked();
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
        emit Invoked(target, value, data);
    }

    function isWhitelisted(address[] memory targets) public view returns (bool) {
        for (uint256 i = 0; i < targets.length; i++) {
            if (!isWhitelisted(targets[i])) return false;
        }
        return true;
    }

    /**
     * @notice Add account from whitelist
     */
    function addToWhitelist(address[] calldata targets) external {
        onlyEntryPoint();
        onlyWhenUnlocked();
        /* solhint-disable not-rely-on-time */
        setWhitelist(targets, block.timestamp + WHITELIST_PERIOD);
        emit WhitelistAdded(targets, block.timestamp + WHITELIST_PERIOD);
        /* solhint-enable not-rely-on-time */
    }

    /**
     * @notice remove accounts from whitelist
     */
    function removeFromWhitelist(address[] calldata targets) external {
        onlyEntryPoint();
        onlyWhenUnlocked();
        setWhitelist(targets, 0);
        emit WhitelistRemoved(targets);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./IEIP4337Account.sol";
import "../../entrypoint/IEntryPoint.sol";

/**
 * @dev Basice implementation of a EIP4337 compatible account.
 */
abstract contract EIP4337Account is IEIP4337Account {

    //return value in case of signature failure, with no time-range.
    uint256 constant internal SIG_VALIDATION_FAILED = 1;

    IEntryPoint public entryPoint;
    mapping(uint256 => bool) private accountNonce;

    /* solhint-disable */
    error DepositFailed();
    error NeedToOverride();
    /* solhint-enable */

    /**
     * @dev Account's entryPoint changed event.
     */
    event EntryPointChanged(address indexed oldEntryPoint, address indexed newEntryPoint);

    /*------------------------------------------external functions---------------------------------*/

    /**
     * @dev Validate user's signature and nonce.
     * Subclass doesn't need to override this method. Instead, it should override the specific internal validation methods.
     */
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        address aggregator,
        uint256 missingAccountFunds
    ) external virtual override returns (uint256 sigTimeRange) {
        onlyEntryPoint();
        sigTimeRange = validateSignature(userOp, userOpHash, aggregator);
        if (userOp.initCode.length == 0 && userOp.callData.length != 0) {
            validateAndUpdateNonce(userOp);
        }
        payPrefund(missingAccountFunds);
    }

    /**
     * @dev Expose an api to modify the entryPoint.
     * Must be called by current "admin" of the account.
     * @param newEntryPoint the new entrypoint to trust.
     */
    function updateEntryPoint(address newEntryPoint) external {
        onlyEntryPoint();
        emit EntryPointChanged(address(entryPoint), newEntryPoint);
        entryPoint = IEntryPoint(newEntryPoint);
    }

    /*------------------------------------------public functions---------------------------------*/

    /**
     * @notice Deposit more funds for this account in the entryPoint.
     */
    function addDeposit() public payable {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(entryPoint).call{value: msg.value}("");
        if (!success) revert DepositFailed();
    }

    /**
     * @notice Withdraw value from the account's deposit.
     * @param withdrawAddress target to send to
     * @param amount to withdraw
     */
    //TODO: define signature requirements for this method
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public {
        onlyOwner();
        entryPoint.withdrawTo(withdrawAddress, amount);
    }

    /**
     * @notice Check current account deposit in the entryPoint.
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint.getBalanceOf(address(this));
    }

    /**
     * @notice Get nonce of account.
     */
    function nonce(uint256 nonce_) public view returns (bool) {
        return accountNonce[nonce_];
    }

    /*------------------------------------------internal functions---------------------------------*/

    /**
     * @dev Sends to the entrypoint (msg.sender) the missing funds for this transaction.
     * Subclass MAY override this method for better funds management
     * (e.g. send to the entryPoint more than the minimum required, so that in future transactions
     * it will not be required to send again)
     * @param missingAccountFunds the minimum value this method should send the entrypoint.
     *  this value MAY be zero, in case there is enough deposit, or the userOp has a paymaster.
     */
    function payPrefund(uint256 missingAccountFunds) internal virtual {
        if (missingAccountFunds == 0) return;
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
        (success);
    }

    /**
     * @dev Validate the signature is valid for this message.
     * @param userOp validate the userOp.signature field
     * @param userOpHash convenient field: the hash of the request, to check the signature against
     *          (also hashes the entrypoint and chain-id)
     * @param aggregator the current aggregator. can be ignored by accounts that don't use aggregators
     */
    function validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        address aggregator
    ) internal virtual returns (uint256 sigTimeRange);

    /**
     * @dev Validate the current nonce matches the UserOperation nonce.
     * Then it should update the account's state to prevent replay of this UserOperation.
     * called only if initCode is empty (since "nonce" field is used as "salt" on account creation)
     * @param userOp the op to validate.
     */
    function validateAndUpdateNonce(UserOperation calldata userOp) internal {
        require(accountNonce[userOp.nonce] == false, "EIP4337Account: invalid nonce");
        accountNonce[userOp.nonce] = true;
    }

    function getOwner() internal view virtual returns (address);

    function onlyOwner() internal view virtual {}

    function onlyEntryPoint() internal view virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../../UserOperation.sol";

/**
 * @dev Account interface specified in https://eips.ethereum.org/EIPS/eip-4337.
 */
interface IEIP4337Account {
    /**
     * Validate user's signature and nonce
     * the entryPoint will make the call to the recipient only if this validation call returns successfully.
     *
     * @dev Must validate caller is the entryPoint.
     *      Must validate the signature and nonce
     * @param userOp the operation that is about to be executed.
     * @param userOpHash hash of the user's request data. can be used as the basis for signature.
     * @param aggregator the aggregator used to validate the signature. NULL for non-aggregated signature accounts.
     * @param missingAccountFunds missing funds on the account's deposit in the entrypoint.
     *      This is the minimum amount to transfer to the sender(entryPoint) to be able to make the call.
     *      The excess is left as a deposit in the entrypoint, for future calls.
     *      can be withdrawn anytime using "entryPoint.withdrawTo()"
     *      In case there is a paymaster in the request (or the current deposit is high enough), this value will be zero.
     *      Note that the validation code cannot use block.timestamp (or block.number) directly.
     */
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        address aggregator,
        uint256 missingAccountFunds
    ) external returns (uint256 sigTimeRange);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Utils
 * @notice Common utility methods used by modules.
 */
library Utils {
    // ERC20, ERC721 & ERC1155 transfers & approvals
    bytes4 private constant ERC20_TRANSFER = 0xa9059cbb;
    bytes4 private constant ERC20_APPROVE = 0x095ea7b3;
    bytes4 private constant ERC721_SET_APPROVAL_FOR_ALL = 0xa22cb465;
    bytes4 private constant ERC721_TRANSFER_FROM = 0x23b872dd; //ERC20.transferFrom and ERC721.transferFrom have same selector
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM = 0x42842e0e;
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM_BYTES = 0xb88d4fde;
    bytes4 private constant ERC1155_SAFE_TRANSFER_FROM = 0xf242432a;
    bytes4 private constant ERC1155_SAFE_BATCH_TRANSFER_FROM = 0x2eb2c2d6;
    /* solhint-disable */

    error BadValueSignature();
    error EcrecoverReturnedZero();
    error InvalidArrayLength();
    /* solhint-enable */

    bytes4 private constant OWNER_SIG = 0x8da5cb5b;

    /**
     * @notice Helper method to recover the signer at a given position from a list of concatenated signatures.
     * @param signedHash The signed hash
     * @param signatures The concatenated signatures.
     * @param index The index of the signature to recover.
     */
    function recoverSigner(bytes32 signedHash, bytes memory signatures, uint256 index) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        // we jump 32 (0x20) as the first slot of bytes contains the length
        // we jump 65 (0x41) per signature
        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signatures, add(0x20, mul(0x41, index))))
            s := mload(add(signatures, add(0x40, mul(0x41, index))))
            v := and(mload(add(signatures, add(0x41, mul(0x41, index)))), 0xff)
        }
        if (v != 27 && v != 28) {
            revert BadValueSignature();
        }

        address recoveredAddress = ecrecover(signedHash, v, r, s);
        if (recoveredAddress == address(0)) {
            revert EcrecoverReturnedZero();
        }
        return recoveredAddress;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @notice Helper method to parse data and extract the method signature.
     */
    function functionPrefix(bytes memory data) internal pure returns (bytes4 prefix) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            prefix := mload(add(data, 0x20))
        }
    }

    /**
     * @notice Returns ceil(a / b).
     */
    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        if (a % b == 0) {
            return c;
        } else {
            return c + 1;
        }
    }

    /**
     * @notice Checks if an address is a guardian or an account authorised to sign on behalf of a smart-contract guardian
     * given a list of guardians.
     * @param guardians the list of guardians
     * @param signer the address to test
     * @return true and the list of guardians minus the found guardian upon success, false and the original list of guardians if not found.
     */
    function isGuardianOrGuardianSigner(
        address[] memory guardians,
        address signer
    ) internal view returns (bool, address[] memory) {
        if (guardians.length == 0 || signer == address(0)) {
            return (false, guardians);
        }
        bool isFound = false;
        address[] memory updatedGuardians = new address[](guardians.length - 1);
        uint256 index = 0;
        for (uint256 i = 0; i < guardians.length; i++) {
            if (!isFound) {
                // check if signer is an account guardian
                if (signer == guardians[i]) {
                    isFound = true;
                    continue;
                }
                // check if signer is the owner of a smart contract guardian
                if (Address.isContract(guardians[i]) && isGuardianOwner(guardians[i], signer)) {
                    isFound = true;
                    continue;
                }
            }
            if (index < updatedGuardians.length) {
                updatedGuardians[index] = guardians[i];
                index++;
            }
        }
        return isFound ? (true, updatedGuardians) : (false, guardians);
    }

    /**
     * @notice Checks if an address is the owner of a guardian contract.
     * The method does not revert if the call to the owner() method consumes more then 25000 gas.
     * @param guardian The guardian contract
     * @param guardianOwner_ The owner to verify.
     */
    function isGuardianOwner(address guardian, address guardianOwner_) internal view returns (bool) {
        address guardianOwner = address(0);

        // solhint-disable-next-line no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, OWNER_SIG)
            let result := staticcall(25000, guardian, ptr, 0x20, ptr, 0x20)
            if eq(result, 1) {
                guardianOwner := mload(ptr)
            }
        }
        return guardianOwner == guardianOwner_;
    }

    /**
     * @notice Helper method to recover the spender from a contract call.
     * The method returns the contract unless the call is to a standard method of a ERC20/ERC721/ERC1155 token
     * in which case the spender is recovered from the data.
     */
    function recoverSpenders(address[] memory targets, bytes[] memory datas) internal pure returns (address[] memory) {
        if (targets.length != datas.length) revert InvalidArrayLength();
        address[] memory spenders = new address[](targets.length);
        for (uint256 i = 0; i < targets.length; i++) {
            spenders[i] = recoverSpender(targets[i], datas[i]);
        }
        return spenders;
    }

    function recoverSpender(address to, bytes memory data) internal pure returns (address spender) {
        if (data.length >= 68) {
            bytes4 methodId;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                methodId := mload(add(data, 0x20))
            }
            if (methodId == ERC20_TRANSFER || methodId == ERC20_APPROVE || methodId == ERC721_SET_APPROVAL_FOR_ALL) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    spender := mload(add(data, 0x24))
                }
                return spender;
            }
            if (
                methodId == ERC721_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM_BYTES ||
                methodId == ERC1155_SAFE_TRANSFER_FROM ||
                methodId == ERC1155_SAFE_BATCH_TRANSFER_FROM
            ) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    spender := mload(add(data, 0x44))
                }
                return spender;
            }
        }

        spender = to;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../UserOperation.sol";
import "./IStakeManager.sol";

/**
 * @dev EntryPoint interface specified in https://eips.ethereum.org/EIPS/eip-4337
 */
interface IEntryPoint is IStakeManager {
    /**
     * gas and return values during simulation
     * @param preOpGas the gas used for validation (including preValidationGas)
     * @param prefund the required prefund for this operation
     * @param sigFailed validateUserOp's (or paymaster's) signature check failed
     * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param validUntil - last timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param paymasterContext returned by validatePaymasterUserOp (to be passed into postOp)
     */
    struct ReturnInfo {
        uint256 preOpGas;
        uint256 prefund;
        bool sigFailed;
        uint64 validAfter;
        uint64 validUntil;
        bytes paymasterContext;
    }

    /* solhint-disable */

    /**
     * a custom revert error of handleOps, to identify the offending op.
     *  NOTE: if simulateValidation passes successfully, there should be no reason for handleOps to fail on it.
     *  @param opIndex - index into the array of ops to the failed one (in simulateValidation, this is always zero)
     *  @param paymaster - if paymaster.validatePaymasterUserOp fails, this will be the paymaster's address. if validateUserOp failed,
     *       this value will be zero (since it failed before accessing the paymaster)
     *  @param reason - revert reason
     *   Should be caught in off-chain handleOps simulation and not happen on-chain.
     *   Useful for mitigating DoS attempts against batchers or for troubleshooting of account/paymaster reverts.
     */
    error FailedOp(uint256 opIndex, address paymaster, string reason);

    /**
     * return value of getSenderAddress
     * @param sender address returned
     */
    error SenderAddressResult(address sender);

    /**
     * Successful result from simulateValidation.
     * @param returnInfo gas and time-range returned values
     * @param senderInfo stake information about the sender
     * @param factoryInfo stake information about the factor (if any)
     * @param paymasterInfo stake information about the paymaster (if any)
     */
    error ValidationResult(ReturnInfo returnInfo, StakeInfo senderInfo, StakeInfo factoryInfo, StakeInfo paymasterInfo);

    /**
     * Successful result from simulateHandleOp.
     * @param preOpGas the gas used for validation (including preValidationGas)
     * @param paid cost of user operation
     * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param validBefore - last timestamp this UserOp is valid (merging account and paymaster time-range)
     */
    error ExecutionResult(uint256 preOpGas, uint256 paid, uint64 validAfter, uint64 validBefore);

    /***
     * An event emitted after each successful request
     * @param userOpHash - unique identifier for the request (hash its entire content, except signature).
     * @param sender - the account that generates this request.
     * @param paymaster - if non-null, the paymaster that pays for this request.
     * @param nonce - the nonce value from the request
     * @param actualGasCost - the total cost (in gas) of this request.
     * @param actualGasPrice - the actual gas price the sender agreed to pay.
     * @param success - true if the sender transaction succeeded, false if reverted.
     */
    event UserOperationEvent(
        bytes32 indexed userOpHash,
        address indexed sender,
        address indexed paymaster,
        uint256 nonce,
        uint256 actualGasCost,
        uint256 actualGasPrice,
        bool success
    );

    /**
     * An event emitted if the UserOperation "callData" reverted with non-zero length
     * @param userOpHash the request unique identifier.
     * @param sender the sender of this request
     * @param nonce the nonce used in the request
     * @param revertReason - the return bytes from the (reverted) call to "callData".
     */
    event UserOperationRevertReason(
        bytes32 indexed userOpHash,
        address indexed sender,
        uint256 nonce,
        bytes revertReason
    );

    /**
     * account "sender" was deployed.
     * @param userOpHash the userOp that deployed this account. UserOperationEvent will follow.
     * @param sender the account that is deployed
     * @param factory the factory used to deploy this account (in the initCode)
     * @param paymaster the paymaster used by this UserOp
     */
    event AccountDeployed(bytes32 indexed userOpHash, address indexed sender, address factory, address paymaster);

    /* solhint-enable */

    /**
     * @dev Process a list of operations
     */
    function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;

    /**
     * Simulate a call to account.validateUserOp and paymaster.validatePaymasterUserOp.
     * @dev this method always revert. Successful result is ValidationResult error. other errors are failures.
     * @dev The node must also verify it doesn't use banned opcodes, and that it doesn't reference storage outside the account's data.
     * @param userOp the user operation to validate.
     */
    function simulateValidation(UserOperation calldata userOp) external;

    /**
     * @notice Simulate full execution of a UserOperation (including both validation and target execution)
     * this method will always revert with "ExecutionResult".
     * it performs full validation of the UserOperation, but ignores signature error.
     * Note that in order to collect the the success/failure of the target call, it must be executed
     * with trace enabled to track the emitted events.
     * @param op the user operation to validate.
     */
    function simulateHandleOp(UserOperation calldata op) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IStakeManager {
    /**
     * @param deposit the account's deposit
     * @param staked true if this account is staked as a paymaster
     * @param stake actual amount of ether staked for this paymaster. must be above paymasterStake
     * @param unstakeDelaySec minimum delay to withdraw the stake
     * @param withdrawTime - first block timestamp where 'withdrawStake' will be callable, or zero if already locked
     * @dev sizes were chosen so that (deposit,staked) fit into one cell (used during handleOps)
     *    and the rest fit into a 2nd cell.
     *    112 bit allows for 10^15 eth
     *    64 bit for full timestamp
     *    32 bit allow 150 years for unstake delay
     */
    struct DepositInfo {
        uint112 deposit;
        bool staked;
        uint112 stake;
        uint32 unstakeDelaySec;
        uint64 withdrawTime;
    }

    //API struct used by getStakeInfo and simulateValidation
    struct StakeInfo {
        uint256 stake;
        uint256 unstakeDelaySec;
    }

    event Deposited(address indexed account, uint256 totalDeposit);

    event Withdrawn(address indexed account, address withdrawAddress, uint256 amount);

    event StakeLocked(address indexed account, uint256 totalStaked, uint256 withdrawTime);

    event StakeUnlocked(address indexed account, uint256 withdrawTime);

    event StakeWithdrawn(address indexed account, address withdrawAddress, uint256 amount);

    // return the deposit (for gas payment) of the account
    function getBalanceOf(address account) external view returns (uint256);

    // add to the deposit of the given account
    function depositTo(address account) external payable;

    /**
     * add to the account's stake - amount and delay
     * any pending unstake is first cancelled.
     * @param unstakeDelaySec the new lock duration before the deposit can be withdrawn.
     */
    function addStake(uint32 unstakeDelaySec) external payable;

    /**
     * attempt to unlock the stake.
     * the value can be withdrawn (using withdrawStake) after the unstake delay.
     */
    function unlockStake() external;

    /**
     * withdraw from the (unlocked) stake.
     * must first call unlockStake and wait for the unstakeDelay to pass
     * @param withdrawAddress the address to send withdrawn value.
     */
    function withdrawStake(address payable withdrawAddress) external;

    /**
     * withdraw from the deposit.
     * @param withdrawAddress the address to send withdrawn value.
     * @param withdrawAmount the amount to withdraw.
     */
    function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @dev Operation object specified in https://eips.ethereum.org/EIPS/eip-4337
 */
/**
 * User Operation struct
 * @param sender the sender account of this request
 * @param nonce unique value the sender uses to verify it is not a replay.
 * @param initCode if set, the account contract will be created by this constructor
 * @param callData the method call to execute on this account.
 * @param verificationGasLimit gas used for validateUserOp and validatePaymasterUserOp
 * @param preVerificationGas gas not calculated by the handleOps method, but added to the gas paid. Covers batch overhead.
 * @param maxFeePerGas same as EIP-1559 gas parameter
 * @param maxPriorityFeePerGas same as EIP-1559 gas parameter
 * @param paymasterAndData if set, this field hold the paymaster address and "paymaster-specific-data". the paymaster will pay for the transaction instead of the sender
 * @param signature sender-verified signature over the entire request, the EntryPoint address and the chain ID.
 */
struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    uint256 callGasLimit;
    uint256 verificationGasLimit;
    uint256 preVerificationGas;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    bytes paymasterAndData;
    bytes signature;
}

library UserOperationLib {
    function getSender(UserOperation calldata userOp) internal pure returns (address) {
        address data;
        //read sender from userOp, which is first userOp member (saves 800 gas...)
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := calldataload(userOp)
        }
        return address(uint160(data));
    }

    //relayer/miner might submit the TX with higher priorityFee, but the user should not
    // pay above what he signed for.
    function gasPrice(UserOperation calldata userOp) internal view returns (uint256) {
        unchecked {
            uint256 maxFeePerGas = userOp.maxFeePerGas;
            uint256 maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
            if (maxFeePerGas == maxPriorityFeePerGas) {
                //legacy mode (for networks that don't support basefee opcode)
                return maxFeePerGas;
            }
            return min(maxFeePerGas, maxPriorityFeePerGas + block.basefee);
        }
    }

    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
        //lighter signature scheme. must match UserOp.ts#packUserOp
        bytes calldata sig = userOp.signature;
        // copy directly the userOp from calldata up to (but not including) the signature.
        // this encoding depends on the ABI encoding of calldata, but is much lighter to copy
        // than referencing each field separately.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let ofs := userOp
            let len := sub(sub(sig.offset, ofs), 32)
            ret := mload(0x40)
            mstore(0x40, add(ret, add(len, 32)))
            mstore(ret, len)
            calldatacopy(add(ret, 32), ofs, len)
        }
    }

    function hash(UserOperation calldata userOp) internal pure returns (bytes32) {
        return keccak256(pack(userOp));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}