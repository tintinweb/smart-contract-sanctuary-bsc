// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./CustomEIP712Upgradeable.sol";
import "./NonceManager.sol";
import "./Component.sol";
import "./IVerifier.sol";
import "./errors.sol";

contract ValidatorManager is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    CustomEIP712Upgradeable,
    NonceManager,
    Component
{
    /*=========================== 1. STRUCTS =================================*/
    struct ValidatorInfo {
        uint256 gasPrice;
        address signer;
        uint64 lastSubmit;
        uint32 epoch;
    }

    /*=========================== 2. CONSTANTS ===============================*/
    uint256 private constant _MIN_WEIGHT = 2e16;
    uint256 private constant _CONFIRM_PERCENT = 51;
    uint256 private constant _EPOCH_TIME = 72 * 3600; // 72 hours
    uint256 private constant _REWARD_TIME = 71 * 3600; // reward: 0 ~ 71 hour, purge: 71 ~ 72 hour
    uint256 private constant _REWARD_FACTOR = 1e9;
    bytes32 private constant _SUBMIT_VALIDATOR_TYPEHASH =
        keccak256("SubmitValidator(bytes32 validator,address signer,uint256 weight,uint32 epoch)");
    bytes32 private constant _SET_FEE_RATE_TYPEHASH =
        keccak256("SetFeeRate(uint256 feeRate,uint256 nonce)");

    /*=========================== 3. STATE VARIABLES =========================*/
    address private _genesisSigner;
    bytes32 private _genesisValidator;
    uint256 private _totalWeight;
    uint256 private _weightedGasPrice;
    uint256 private _feeRate; // gas as unit

    // Mapping from signer's address to election _weightedGasPrice
    mapping(address => uint256) private _weights;

    // Mapping from signer's address to validator's address (public key)
    mapping(address => bytes32) private _signerToValidator;

    mapping(bytes32 => ValidatorInfo) private _validatorInfos;

    // Array with all token ids, used for enumeration
    bytes32[] private _validators;

    /*=========================== 4. EVENTS ==================================*/
    event FeeRateUpdated(uint256 feeRate, uint256 nonce);
    event ValidatorSubmitted(
        bytes32 indexed validator,
        address indexed signer,
        uint256 weight,
        uint32 epoch
    );
    event ValidatorPurged(
        bytes32 indexed validator,
        address indexed signer,
        uint256 weight,
        uint32 epoch
    );
    event WeightedGasPriceUpdated(uint256 previousPrice, uint256 newPrice);
    event TotalWeightUpdated(uint256 previousWeight, uint256 newWeight);

    /*=========================== 5. MODIFIERS ===============================*/
    modifier onlySigner(address signer) {
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender != signer || tx.origin != signer) revert NotCalledBySigner();
        _;
    }

    /*=========================== 6. FUNCTIONS ===============================*/
    function __ValidatorManager_init(bytes32 genesisValidator, address genesisSigner)
        internal
        onlyInitializing
    {
        __ValidatorManager_init_unchained(genesisValidator, genesisSigner);
    }

    function __ValidatorManager_init_unchained(bytes32 genesisValidator, address genesisSigner)
        internal
        onlyInitializing
    {
        _feeRate = 21000;
        _genesisSigner = genesisSigner;
        _genesisValidator = genesisValidator;
        _validators.push(genesisValidator);
    }

    function setFeeRate(
        uint256 feeRate,
        uint256 nonce,
        bytes calldata signatures
    ) external nonReentrant whenNotPaused useNonce(nonce) coreContractValid {
        if (!verify(keccak256(abi.encode(_SET_FEE_RATE_TYPEHASH, feeRate, nonce)), signatures)) {
            revert VerificationFailed();
        }
        _feeRate = feeRate;
        emit FeeRateUpdated(feeRate, nonce);
        IVerifier(coreContract()).setFee(feeRate * _weightedGasPrice);
    }

    function submitValidator(
        bytes32 validator,
        address signer,
        uint256 weight,
        uint32 epoch,
        address rewardTo,
        bytes calldata signatures
    ) external nonReentrant whenNotPaused onlySigner(signer) coreContractValid {
        {
            // Statck too deep
            bytes32 structHash = keccak256(
                abi.encode(_SUBMIT_VALIDATOR_TYPEHASH, validator, signer, weight, epoch)
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (validator == bytes32(0) || validator == _genesisValidator) revert InvalidValidator();
        if (signer == address(0) || signer == _genesisSigner) revert InvalidSigner();

        ValidatorInfo memory info = _validatorInfos[validator];
        if (epoch < info.epoch || epoch != _getCurrentEpoch()) revert InvalidEpoch();

        uint256 totalWeight = _totalWeight;
        uint256 weightClear = _revokeSubmission(validator, info, false);
        if (!_inRewardTimeRange(info) || info.epoch == epoch) {
            weightClear = 0;
        }

        if (_signerToValidator[signer] != bytes32(0)) revert SignerReferencedByOtherValidator();
        if (_weights[signer] != 0) revert SignerWeightNotCleared();

        if (info.epoch == 0) {
            _validators.push(validator);
        }

        info.gasPrice = tx.gasprice;
        info.signer = signer;
        // solhint-disable-next-line not-rely-on-time
        info.lastSubmit = uint64(block.timestamp);
        info.epoch = epoch;
        _doSubmission(validator, info, weight);

        if (weightClear > 0 && rewardTo != address(0)) {
            _sendReward(rewardTo, weight, totalWeight);
        }
    }

    function purgeValidators(bytes32[] calldata validators, address rewardTo)
        external
        nonReentrant
        whenNotPaused
        coreContractValid
    {
        if (!_inPurgeTimeRange()) revert NotInPurgeTimeRange();
        uint256 totalWeight = _totalWeight;
        uint256 weight = 0;
        for (uint256 i = 0; i < validators.length; i++) {
            bytes32 validator = validators[i];
            ValidatorInfo memory info = _validatorInfos[validator];
            if (_canPurge(info)) {
                weight += _revokeSubmission(validator, info, true);
            }
        }

        if (weight > 0 && rewardTo != address(0)) {
            _sendReward(rewardTo, weight, totalWeight);
        }
    }

    function getWeight(address signer) external view returns (uint256) {
        return _getWeight(signer, _genesisSigner, _totalWeight);
    }

    function getFeeRate() external view returns (uint256) {
        return _feeRate;
    }

    function getWeightedGasPrice() external view returns (uint256) {
        return _weightedGasPrice;
    }

    function getTotalWeight() external view returns (uint256) {
        return _totalWeight;
    }

    function getValidatorInfo(bytes32 validator) external view returns (ValidatorInfo memory) {
        return _validatorInfos[validator];
    }

    function getValidators(uint256 begin, uint256 end) external view returns (bytes32[] memory) {
        uint256 length = _validators.length;
        if (end > length) end = length;
        if (begin >= end) return  new bytes32[](0);
        bytes32[] memory result = new bytes32[](end - begin);
        for ((uint256 i, uint256 j) = (begin, 0); i < end; (++i, ++j)) {
            result[j] = _validators[i];
        }
        return result;
    }

    function getValidatorCount() external view returns (uint256) {
        return _validators.length;
    }

    function verify(bytes32 structHash, bytes calldata signatures) public view returns (bool) {
        bytes32 typedHash = _hashTypedDataV4(structHash);
        return verifyTypedData(typedHash, signatures);
    }

    function verifyTypedData(bytes32 typedHash, bytes calldata signatures)
        public
        view
        returns (bool)
    {
        uint256 length = signatures.length;
        if (length == 0 || length % 65 != 0) revert InvalidSignatures();
        uint256 count = length / 65;

        uint256 total = _totalWeight;
        address genesis = _genesisSigner;
        address last = address(0);
        address current;

        bytes32 r;
        bytes32 s;
        uint8 v;
        uint256 i;

        uint256 weight = 0;

        for (i = 0; i < count; ++i) {
            (r, s, v) = _decodeSignature(signatures, i);
            current = ecrecover(typedHash, v, r, s);
            if (current == address(0)) revert EcrecoverFailed();
            if (current <= last) revert InvalidSignerOrder();
            last = current;
            weight += _getWeight(current, genesis, total);
        }

        uint256 adjustTotal = total > _MIN_WEIGHT ? total : _MIN_WEIGHT;
        return weight > (adjustTotal * _CONFIRM_PERCENT) / 100;
    }

    function _getWeight(
        address signer,
        address genesis,
        uint256 total
    ) internal view returns (uint256) {
        if (signer != genesis) {
            return _weights[signer];
        } else {
            return total >= _MIN_WEIGHT ? 0 : _MIN_WEIGHT - total;
        }
    }

    function _getCurrentEpoch() internal view returns (uint32) {
        // solhint-disable-next-line not-rely-on-time
        return uint32(block.timestamp / _EPOCH_TIME);
    }

    function _inRewardTimeRange(ValidatorInfo memory info) internal view returns (bool) {
        uint256 rewardTime = _REWARD_TIME;
        uint256 epochTime = _EPOCH_TIME;
        uint256 hour = 3600;
        uint256 lastDelay = info.lastSubmit % epochTime;
        if (lastDelay > rewardTime) {
            lastDelay = rewardTime;
        }
        uint256 delay = (lastDelay + rewardTime - hour) % rewardTime;
        if (delay > rewardTime - hour) {
            delay = rewardTime - hour;
        }
        // solhint-disable-next-line not-rely-on-time
        return (block.timestamp % epochTime) >= delay;
    }

    function _inPurgeTimeRange() internal view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return (block.timestamp % _EPOCH_TIME) > _REWARD_TIME;
    }

    function _canPurge(ValidatorInfo memory info) internal view returns (bool) {
        if (info.epoch >= _getCurrentEpoch()) {
            return false;
        }
        return info.signer != address(0);
    }

    function _decodeSignature(bytes calldata signatures, uint256 index)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        // |{bytes32 r}{bytes32 s}{uint8 v}|...|{bytes32 r}{bytes32 s}{uint8 v}|
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let start := signatures.offset
            let offset := mul(0x41, index)
            r := calldataload(add(start, offset))
            s := calldataload(add(start, add(offset, 0x20)))
            v := and(calldataload(add(start, add(offset, 0x21))), 0xff)
        }
    }

    function _doSubmission(
        bytes32 validator,
        ValidatorInfo memory info,
        uint256 weight
    ) private {
        address signer = info.signer;
        _signerToValidator[signer] = validator;
        _weights[signer] = weight;

        _validatorInfos[validator] = info;
        emit ValidatorSubmitted(validator, info.signer, weight, info.epoch);

        _increaseTotalWeightAndUpdateGasPrice(weight, info.gasPrice);
    }

    function _revokeSubmission(
        bytes32 validator,
        ValidatorInfo memory info,
        bool store
    ) private returns (uint256) {
        address signer = info.signer;
        if (signer == address(0)) {
            return 0;
        }
        _signerToValidator[signer] = bytes32(0);
        uint256 weight = _weights[signer];
        _weights[signer] = 0;
        _decreaseTotalWeightAndUpdateGasPrice(weight, info.gasPrice);

        info.gasPrice = 0;
        info.signer = address(0);
        if (store) {
            _validatorInfos[validator] = info;
            emit ValidatorPurged(validator, signer, weight, info.epoch);
        }
        return weight;
    }

    function _sendReward(
        address to,
        uint256 weight,
        uint256 totalWeight
    ) private {
        if (weight == 0) {
            return;
        }
        uint256 share = _REWARD_FACTOR;
        if (weight < totalWeight) {
            share = (_REWARD_FACTOR * weight) / totalWeight;
        }
        IVerifier(coreContract()).sendReward(to, share);
    }

    function _increaseTotalWeightAndUpdateGasPrice(uint256 weight, uint256 gasPrice) private {
        if (weight == 0) {
            return;
        }

        uint256 currentWeight = _totalWeight;
        uint256 newWeight = currentWeight + weight;
        _totalWeight = newWeight;
        emit TotalWeightUpdated(currentWeight, newWeight);

        uint256 currentPrice = _weightedGasPrice;
        uint256 newPrice = ((currentPrice * currentWeight) + (weight * gasPrice)) / newWeight;
        _updateWeightedGasPrice(newPrice);
    }

    function _decreaseTotalWeightAndUpdateGasPrice(uint256 weight, uint256 gasPrice) private {
        if (weight == 0) {
            return;
        }

        uint256 currentWeight = _totalWeight;
        if (weight >= currentWeight) {
            _totalWeight = 0;
            emit TotalWeightUpdated(currentWeight, 0);
            _updateWeightedGasPrice(0);
            return;
        }

        uint256 newWeight = currentWeight - weight;
        _totalWeight = newWeight;
        emit TotalWeightUpdated(currentWeight, newWeight);

        uint256 currentPrice = _weightedGasPrice;
        uint256 removalPrice = (gasPrice * weight) / currentWeight;
        if (removalPrice >= currentPrice) {
            _updateWeightedGasPrice(0);
            return;
        }

        uint256 newPrice = ((currentPrice - removalPrice) * currentWeight) / newWeight;
        _updateWeightedGasPrice(newPrice);
    }

    function _updateWeightedGasPrice(uint256 price) private {
        uint256 currentPrice = _weightedGasPrice;
        if (currentPrice == price) {
            return;
        }

        _weightedGasPrice = price;
        emit WeightedGasPriceUpdated(currentPrice, price);
        IVerifier(coreContract()).setFee(_feeRate * price);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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

    function _setInitializedVersion(uint8 version) private returns (bool) {
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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

// SPDX-License-Identifier: MIT

// This contract will be frequently called by user, custom it for gas saving

// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract CustomEIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private constant _HASHED_NAME = keccak256("Raicoin");
    bytes32 private constant _HASHED_VERSION = keccak256("1.0");
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
     // solhint-disable-next-line no-empty-blocks
    function __EIP712_init() internal onlyInitializing {}

    function __EIP712_init_unchained(string memory name, string memory version)
        internal
        onlyInitializing
     // solhint-disable-next-line no-empty-blocks
    {}

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./errors.sol";

contract NonceManager is Initializable {
    uint256 private _nonce;

    modifier useNonce(uint256 nonce) {
        if (nonce != _nonce) revert NonceMismatch();
        nonce++;
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./errors.sol";

abstract contract Component {
    address private immutable _deployer;
    address private _coreContract;

    event CoreContractSet(address);

    modifier onlyCoreContract() {
        if (msg.sender != _coreContract) revert NotCalledByCoreContract();
        _;
    }

    modifier coreContractValid() {
        if (_coreContract == address(0)) revert CoreContractNotSet();
        _;
    }

    constructor() {
        _deployer = msg.sender;
    }

    function setCoreContract(address core) external {
        if (core == address(0)) revert InvalidCoreContract();
        if (msg.sender != _deployer) revert NotCalledByDeployer();
        if (_coreContract != address(0)) revert CoreContractAreadySet();
        _coreContract = core;
        emit CoreContractSet(_coreContract);
    }

    function deployer() public view returns (address) {
        return _deployer;
    }

    function coreContract() public view returns (address) {
        return _coreContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IVerifier {
    function setFee(uint256 fee) external;

    function sendReward(address recipient, uint256 share) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

error NotCalledByCoreContract();
error CoreContractNotSet();
error InvalidCoreContract();
error NotCalledByDeployer();
error CoreContractAreadySet();
error VerificationFailed();
error InvalidImplementation();
error InvalidTokenAddress();
error InvalidAmount();
error InvalidRecipient();
error TokenTypeNotMatch();
error CanNotMapWrappedToken();
error InvalidBalance();
error InvalidShare();
error InvalidValue();
error TokenIdAlreadyMapped();
error ZeroBlockNumber();
error TokenIdAlreadyOwned();
error TransferFailed();
error InvalidSender();
error AlreadyUnmapped();
error TokenNotInitialized();
error CanNotUnmapWrappedToken();
error TokenIdNotMapped();
error TokenIdNotOwned();
error WrappedTokenAlreadyCreated();
error CreateWrappedTokenFailed();
error InvalidOriginalChainId();
error InvalidOriginalContract();
error WrappedTokenNotCreated();
error NotWrappedToken();
error TokenAlreadyInitialized();
error NotERC721Token();
error NonceMismatch();
error NotCalledBySigner();
error InvalidValidator();
error InvalidSigner();
error InvalidEpoch();
error SignerReferencedByOtherValidator();
error SignerWeightNotCleared();
error NotInPurgeTimeRange();
error InvalidSignatures();
error EcrecoverFailed();
error InvalidSignerOrder();
error NotCalledByValidatorManager();
error FeeTooLow();
error SendRewardFailed();
error ChainIdMismatch();

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