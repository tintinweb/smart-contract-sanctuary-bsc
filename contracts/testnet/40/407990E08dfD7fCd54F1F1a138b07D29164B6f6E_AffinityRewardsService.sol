/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.8.13;

interface IService {

    function process(address from_, address to_, uint256 amount) external returns (uint256);
    function withdraw(address to_) external;
    function fee() external view returns (uint);
    function provider() external view returns (address);
    function providerFee() external view returns (uint);
}

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !any(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed, uint256, uint256);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal view returns (uint256) {
        return _getFlagStorage()[uint256(uint160(account_))];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[uint256(uint160(account_))] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(uint256 => uint256) storage);

}

abstract contract UsingPrecision {
   uint256 constant DEFAULT_PRECISION = 10 ** 5; // 000.000

   function _PRECISION() internal pure virtual returns (uint256) {
      return DEFAULT_PRECISION;
   }
}

abstract contract UsingDefaultFlags is UsingFlags {
    using bits for uint256;

    /// @notice the value of the initializer flag
    function _INITIALIZED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 255;
    }

    function _TRANSFER_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _INITIALIZED_FLAG() >> 1;
    }

    function _PROVIDER_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_DISABLED_FLAG() >> 1;
    }

    function _SERVICE_FLAG() internal pure virtual returns (uint256) {
        return _PROVIDER_FLAG() >> 1;
    }

    function _NETWORK_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FLAG() >> 1;
    }

    function _SERVICE_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _NETWORK_FLAG() >> 1;
    }

    function _PROCESSING_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1;
    }

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _PROCESSING_FLAG() >> 1;
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1;
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;
    }

    function _SERVICE_FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _SERVICES_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FEE_EXEMPT_FLAG() >> 1;
    }

    function _FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _SERVICES_DISABLED_FLAG() >> 1;
    }

    function _isFeeExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).all(_FEE_EXEMPT_FLAG());
    }

    function _isServiceFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_FEE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_FEE_EXEMPT_FLAG());
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_EXEMPT_FLAG());
    }
}

abstract contract UsingAdmin is UsingFlags, UsingDefaultFlags {

    function _initializeAdmin(address admin_) internal virtual {
        _setFlags(admin_, _ADMIN_FLAG(), 0);
    }

    function setFlags(address account_, uint256 set_, uint256 clear_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFlags(account_, set_, clear_);
    }

}

abstract contract UsingFees is UsingDefaultFlags, UsingPrecision {

    function _setFee(address account_, uint256 fee_) internal virtual {
        _getFeesStorage()[account_] = fee_;
    }

    function _getFee(address account_) internal view virtual returns (uint) {
        return _getFeesStorage()[account_];
    }

    function _applyFee(address account_, uint amount_) internal view returns (uint) {
        if (!_isFeeExempt(account_)) {
            return _getFee(account_) * amount_ / _PRECISION();
        }
        return 0;
    }

    function _getFeesStorage() internal view virtual returns (mapping(address => uint) storage);
}

error ServiceSendFailed();
error ServiceWithdrawDisabled();
abstract contract UsingService is IService, UsingAdmin, UsingFees  {
    using bits for uint256;
    uint constant public MAX_FEE = 999999;

    receive() external payable {
        _receive(msg.sender, msg.value);
    }

    function process(address from_, address to_, uint amount_) external virtual override requires(msg.sender, _PROVIDER_FLAG(), 0)  returns (uint256) {
        return _process(from_, to_, amount_);
    }

    function withdraw(address to_) external virtual requires(msg.sender, _PROVIDER_FLAG() | _NETWORK_FLAG() | _ADMIN_FLAG(), 0) {
        _withdraw(to_);
    }

    function provider() external view override returns(address) {
        return _getProviderStorage();
    }

    function providerFee() external view override returns(uint) {
        return _getProviderFeeStorage();
    }

    function fee() external view override returns(uint) {
        return _getFeeStorage();
    }

    function _calculateFee(address from_, address to_, uint amount_) internal virtual view returns (uint) {
        return _getFeeStorage();
    }

    function _deposit(address account_, uint value_) internal virtual {
        (bool success,) = payable(account_).call{value: value_}("");
        if (!success) {
            revert ServiceSendFailed();
        }
    }

    function _withdraw(address to_) internal virtual {
        uint balance = address(this).balance;
        if (balance > 0) {
            address provider = _getProviderStorage();
            uint providerFee = _getProviderFeeStorage();
            if ( provider != address(0) && providerFee > 0) {
                _deposit(provider,  balance * _getProviderFeeStorage() / _PRECISION());
            }
            _deposit(to_, address(this).balance);
        }
    }

    function _process(address from_, address to_, uint256 amount_) internal virtual returns (uint256){
        return _isServiceExempt(from_, to_) ? 0 : _calculateFee(from_, to_, amount_);
    }

    function _receive(address from_, uint256 value_) internal virtual {}
    function _getFeeStorage() internal virtual view returns (uint);
    function _setFeeStorage(uint fee_) internal virtual;
    function _getProviderStorage() internal virtual view returns (address);
    function _getProviderFeeStorage() internal virtual view returns (uint);
}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(uint256 => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(uint256 => uint256) storage) {
        return _flags;
    }
}

abstract contract UsingFeesWithStorage is UsingFees {

    mapping(address => uint) _fees;

    function _initializeFeesWithStorage(address[] memory accounts_, uint[] memory fees_) internal virtual {
        for (uint i=0; i<accounts_.length; i++) {
            if (accounts_[i] != address(0)) {
                _setFee(accounts_[i], fees_[i]);
            }
        }
    }

    function _getFeesStorage() internal view virtual override returns (mapping(address => uint) storage) {
        return _fees;
    }
}

abstract contract UsingServiceWithStorage is UsingService, UsingFeesWithStorage {

    address _provider; // 160 bit starts the storage slot

    function _initializeServiceWithStorage(address provider_, uint providerFee_, uint fee_) internal {
        _setFlags(provider_, _PROVIDER_FLAG(), 0);
        _setFee(provider_, providerFee_);
        _provider = provider_;
        _setFee(address(this), fee_);
    }

    function _getProviderStorage() internal view override returns (address) {
        return _provider;
    }

    function _getFeeStorage() internal view override returns (uint) {
        return _getFee(address(this));
    }

    function _setFeeStorage(uint fee_) internal override {
        _setFee(address(this), fee_);
    }

    function _getProviderFeeStorage() internal view override returns (uint) {
        return _getFee(_provider);
    }
}

/// @notice This error is emitted when attempting to use the initializer twice
error InitializationRecursion();

/// @title UsingInitializer
/// @notice Use this contract in conjunction with UsingUUPS to allow initialization instead of construction
abstract contract UsingInitializer is UsingFlags, UsingDefaultFlags {
    using bits for uint256;

    /// @notice modifier to prevent double initialization
    modifier initializer() {
        if (_getFlags(address(this)).all(_INITIALIZED_FLAG())) revert InitializationRecursion();
        _;
        _setFlags(address(this), _INITIALIZED_FLAG(), 0);
    }

    /// @notice helper function to check if the contract has been initialized
    function initialized() public view returns (bool) {
        return _getFlags(address(this)).all(_INITIALIZED_FLAG());
    }

}

abstract contract AffinityFlags is UsingFlags, UsingDefaultFlags, UsingAdmin {
    using bits for uint256;

    struct Flags {
        uint transferLimitDisabled;
        uint lpPair;
        uint rewardExempt;
        uint transferLimitExempt;
        uint sellLimitPerTxDisabled;
        uint sellLimitPerPeriodDisabled;
        uint rewardDistributionDisabled;
        uint rewardSwapDisabled;
    }

    function _TRANSFER_LIMIT_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 128;
    }

    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _LP_PAIR_FLAG() >> 1;
    }

    function _TRANSFER_LIMIT_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _REWARD_EXEMPT_FLAG() >> 1;
    }

    function _PER_TX_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _24HR_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _PER_TX_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_DISTRIBUTION_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _24HR_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_SWAP_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _REWARD_DISTRIBUTION_DISABLED_FLAG() >> 1;
    }

    function _isLPPair(address from_, address to_) internal view virtual returns (bool) {
        return _isLPPair(from_) || _isLPPair(to_);
    }

    function _isLPPair(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_LP_PAIR_FLAG(), 0);
    }

    function _isTransferLimitEnabled() internal view virtual returns (bool) {
        return _getFlags(address(this)).check(0, _TRANSFER_LIMIT_DISABLED_FLAG());
    }

    function _isRewardExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
    }

    function _isTransferLimitExempt(address account_) internal view virtual returns (bool) {
        return _isTransferLimitEnabled() && _getFlags(account_).check(_TRANSFER_LIMIT_EXEMPT_FLAG(), 0);
    }

    function _isRouter(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_ROUTER_FLAG(), 0);
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _getFlags(account_).check(set_, cleared_);
    }

    function flags() external returns (Flags memory) {
        return Flags(
            _TRANSFER_DISABLED_FLAG(),
            _LP_PAIR_FLAG(),
            _REWARD_EXEMPT_FLAG(),
            _TRANSFER_LIMIT_DISABLED_FLAG(),
            _PER_TX_SELL_LIMIT_DISABLED_FLAG(),
            _24HR_SELL_LIMIT_DISABLED_FLAG(),
            _REWARD_DISTRIBUTION_DISABLED_FLAG(),
            _REWARD_SWAP_DISABLED_FLAG()
        );
    }

}

contract AffinityFlagsWithStorage is UsingFlagsWithStorage, AffinityFlags {
    using bits for uint256;

}

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract UsingERC1967UpgradeUpgradeable {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/// @title UsingUUPS upgradeable proxy contract
/// @notice this is just a renamed from OpenZeppelin (UUPSUpgradeable)
abstract contract UsingUUPS is IERC1822ProxiableUpgradeable, UsingERC1967UpgradeUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

contract AffinityService is  UsingServiceWithStorage, UsingInitializer, AffinityFlagsWithStorage, UsingUUPS {

    function _initializeAffinityService(address provider_, uint providerFee_, uint fee_) internal {
        _initializeServiceWithStorage(provider_, providerFee_, fee_);
        _initializeAdmin(msg.sender);
    }

    function initialize(address provider_, uint providerFee_, uint fee_) external virtual initializer {
        _initializeAffinityService(provider_, providerFee_, fee_);
    }

    function _authorizeUpgrade(address newImplementation) internal override virtual requires(msg.sender, _ADMIN_FLAG(), 0) {}

}

library Sets {

    struct AddressSet {
        address[] addresses;
        mapping(address => uint) indices;
    }
    error AddressExists();
    error AddressNotFound();

    function add(AddressSet storage set_, address address_) internal {
        if (set_.indices[address_] != 0) {
            revert AddressExists();
        }
        set_.addresses.push(address_);
        set_.indices[address_] = set_.addresses.length;
    }

    function remove(AddressSet storage set_, address address_) internal {
        uint index = set_.indices[address_];
        if (index == 0) {
            revert AddressNotFound();
        }
        for (uint i=index-1; i<set_.addresses.length-1; i++) {
            set_.addresses[i] = set_.addresses[i+1];
            set_.indices[set_.addresses[i]] = i+1;
        }
        set_.addresses.pop();
    }

    function get(AddressSet storage set_, uint256 index) internal view returns (address) {
        return set_.addresses[index];
    }

    function pop(AddressSet storage set_) internal returns (address) {
        address item = set_.addresses[set_.addresses.length-1];
        set_.addresses.pop();
        return item;
    }

    function contains(AddressSet storage set_, address address_) internal view returns (bool) {
        return set_.indices[address_] != 0;
    }

    function length(AddressSet storage set_) internal view returns (uint) {
        return set_.addresses.length;
    }

}

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

/// @notice The signer of the permit doesn't match
error PermitSignatureInvalid(address recovered, address expected, uint256 amount);
/// @notice the block.timestamp has passed the deadline
error PermitExpired(address owner, address spender, uint256 amount, uint256 deadline);
error PermitInvalidSignatureSValue();
error PermitInvalidSignatureVValue();

/// @title Using EIP-2612 Permits
/// @author originally written by soliditylabs with modifications made by [email protected]
/// @dev reference implementation can be found here https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol.
///      This contract contains the implementation and lacks storage. Use this with existing upgradeable contracts.
abstract contract UsingPermit  {

    /// @notice initialize the permit function internally
    function _initializePermits() internal {
        _updateDomainSeparator();
    }

    /// @notice get the nonce for the given account
    /// @param account_ the account to get the nonce for
    /// @return the nonce
    function nonces(address account_) public view returns (uint256) {
        return _getNoncesStorage()[account_];
    }

    /// @notice the domain separator for a chain
    /// @param chainId_ the chain id to get the domain separator for
    function domainSeparators(uint256 chainId_) public view returns (bytes32) {
        return _getDomainSeparatorsStorage()[chainId_];
    }

    /// @notice check if the permit is valid
    function _permit(address owner_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) internal virtual {
        if(block.timestamp > deadline_) revert PermitExpired(owner_, spender_, amount_, deadline_);
        bytes32 hashStruct;
        uint256 nonce = _getNoncesStorage()[owner_]++;
        assembly {
            let memPtr := mload(64)
            mstore(memPtr, 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9)
            mstore(add(memPtr, 32), owner_)
            mstore(add(memPtr, 64), spender_)
            mstore(add(memPtr, 96), amount_)
            mstore(add(memPtr, 128),nonce)
            mstore(add(memPtr, 160), deadline_)
            hashStruct := keccak256(memPtr, 192)
        }
        bytes32 eip712DomainHash = _domainSeparator();
        bytes32 hash;
        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)
            mstore(add(memPtr, 2), eip712DomainHash)
            mstore(add(memPtr, 34), hashStruct)

            hash := keccak256(memPtr, 66)
        }
        address signer = _recover(hash, v_, r_, s_);
        if (signer != owner_) revert PermitSignatureInvalid(signer, owner_, amount_);
    }

    /// @notice add a new domain separator to the mapping
    /// @return the domain separator hash
    function _updateDomainSeparator() internal returns (bytes32) {
        uint256 chainID = block.chainid;
        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_getNameStorage())), // ERC-20 Name
                keccak256(bytes("1")),    // Version
                chainID,
                address(this)
            )
        );
        _getDomainSeparatorsStorage()[chainID] = newDomainSeparator;
        return newDomainSeparator;
    }

    /// @notice get the domain separator and add it to the mapping if it doesn't exist
    /// @return the new or cached domain separator
    function _domainSeparator() private returns (bytes32) {
        bytes32 domainSeparator = _getDomainSeparatorsStorage()[block.chainid];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        return _updateDomainSeparator();
    }

    /// @notice recover the signer address from the signature
    function _recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert PermitInvalidSignatureSValue();
        }

        if (v != 27 && v != 28) {
            revert PermitInvalidSignatureVValue();
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) revert PermitSignatureInvalid(signer, address(0), 0);
        return signer;
    }

    /// @notice the name used to compute the domain separator
    function _getNameStorage() internal view virtual returns (string memory);
    /// @notice get the nonce storage
    function _getNoncesStorage() internal view virtual returns (mapping(address => uint256) storage);
    /// @notice get the domain separator storage
    function _getDomainSeparatorsStorage() internal view virtual returns (mapping(uint256 => bytes32) storage);

}

/// @notice the spender isn't authorized to spend this amount
error ERC20AllowanceInsufficient(address account, address spender, uint256 amount);
/// @notice the amount trying being from the account is greater than the account's balance
error ERC20BalanceInsufficient(address account, uint256 amount);

/// @title Using ERC20 an implementation of EIP-20
/// @dev this is purely the implementation and doesn't contain storage it can be used with existing upgradable contracts just map the existing storage.
/// @author [email protected]
abstract contract UsingERC20 is  UsingPermit, UsingFlags, UsingDefaultFlags {

    /// @notice the event emitted after the a transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice the event emitted upon receiving approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice transfer tokens from sender to account
    /// @param to_ the address to transfer to
    /// @param amount_ the amount to transfer
    /// @dev requires the BLOCKED_FLAG() to be unset
    function transfer(address to_, uint256 amount_) public virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG())  returns (bool) {
        if (amount_ > _getBalancesStorage()[msg.sender]) {
            revert ERC20BalanceInsufficient(msg.sender, amount_);
        }
        _transfer(msg.sender, to_, amount_);
        return true;
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param from_ the account to transfer from
    /// @param to_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev requires the _TRANSFER_DISABLED_FLAG to be cleared
    function transferFrom(address from_, address to_, uint256 amount_) external virtual requires(address(this), 0, _TRANSFER_DISABLED_FLAG()) returns (bool) {
        if (amount_ > _getBalancesStorage()[from_]) {
            revert ERC20BalanceInsufficient(from_, amount_);
        }
        uint256 fromAllowance = _allowanceFor(from_, msg.sender);
        if (fromAllowance != type(uint256).max) {
            if (_getAllowanceStorage()[from_][msg.sender] < amount_) revert ERC20AllowanceInsufficient(from_, msg.sender, amount_);
            unchecked {
                _getAllowanceStorage()[from_][msg.sender] -= amount_;
            }
        }
        _transfer(from_, to_, amount_);
        return true;
    }

    /// @notice the allowance the spender is allowed to spend for an account
    /// @param account_ the account to check
    /// @param spender_ the trusted spender
    /// @return uint256 amount of the account that the spender_ can transfer
    function allowance(address account_, address spender_) public view virtual returns (uint256) {
        return _allowanceFor(account_, spender_);
    }

    function permit(address account_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) public virtual {}

    /// @notice returns the total supply of tokens
    function totalSupply() public view virtual returns (uint256) {
        return _getTotalSupplyStorage();
    }

    /// @notice check the balance of the given account
    /// @param account_ the account to check
    /// @return uint256 the balance of the account
    function balanceOf(address account_) external view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice the symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _getSymbolStorage();
    }

    /// @notice the decimals of the token
    function decimals() public view virtual returns (uint8) {
        return _getDecimalStorage();
    }

    /// @notice the name of the token
    function name() public view virtual returns (string memory) {
        return _getNameStorage();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    /// @notice initialize the token
    /// @dev used internally if you use this in a public function be sure to use the initializer
    function _initializeERC20() internal {
        _initializePermits();
    }

    /// @notice helper to get the allowance of a given account for spender
    function _allowanceFor(address account_, address spender_) internal view returns (uint256) {
        return _getAllowanceStorage()[account_][spender_];
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function _approve(address sender_, address spender_, uint256 amount_) internal virtual {
        _getAllowanceStorage()[sender_][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
    }

    /// @notice used internally to get the balance of the account
    function _balanceOf(address account_) internal view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice transfer tokens to one account from another
    /// @param from_ the account to transfer from
    /// @param to_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev inherit from this function to implement custom taxation or other logic warning this function does zero checking for underflows and overflows
    function _transfer(address from_, address to_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getBalancesStorage()[from_] -= amount_;
            _getBalancesStorage()[to_] += amount_;
        }
        emit Transfer(from_, to_, amount_);
        return true;
    }

    /// @notice mint tokens and adjust the supply
    /// @param to_ the account to mint to
    /// @param amount_ the amount to mint
    function _mint(address to_, uint256 amount_) internal virtual {
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() + amount_);
            _getBalancesStorage()[to_] += amount_;
        }
        emit Transfer(address(0), to_, amount_);
    }

    /// @notice burn tokens and adjust the supply
    /// @param from_ the account to burn from
    /// @param amount_ the amount to burn
    function _burn(address from_, uint amount_) internal virtual {
        if (amount_ > _getBalancesStorage()[from_]) {
            revert ERC20BalanceInsufficient(from_, amount_);
        }
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() - amount_);
            _getBalancesStorage()[from_] -= amount_;
        }
        emit Transfer(from_, address(0), amount_);
    }

    /// @notice get the storage for allowance
    /// @return mapping(address => mapping(address => uint256)) allowance storage
    function _getAllowanceStorage() internal view virtual returns (mapping(address => mapping(address => uint256)) storage);
    /// @notice get the storage for balances
    /// @return mapping(address => uint256) balances storage
    function _getBalancesStorage() internal view virtual returns (mapping(address => uint256) storage);
    function _getTotalSupplyStorage() internal view virtual returns (uint256);
    function _setTotalSupplyStorage(uint256 value) internal virtual;
    function _getSymbolStorage() internal view virtual returns (string memory);
    function _getDecimalStorage() internal view virtual returns (uint8);
}

abstract contract UsingPermitWithStorage is UsingPermit {
    /// @notice nonces per account to prevent re-use of permit
    mapping(address => uint256) internal _nonces;
    /// @notice the predefined type hash
    bytes32 public constant TYPE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    /// @notice a mapping of chainId and domain separators
    mapping(uint256 => bytes32) internal _domainSeparators;

    function _initializePermitWithStorage() internal {
        _updateDomainSeparator();
    }

    function _getNoncesStorage() internal view override returns (mapping(address => uint256) storage) {
        return _nonces;
    }

    function _getDomainSeparatorsStorage() internal view override returns (mapping(uint256 => bytes32) storage) {
        return _domainSeparators;
    }

}

/// @title UsingERC20WithStorage ERC20 contract with storage
/// @dev This should be used with new token contracts or upgradeable contracts with incompatible storage.
abstract contract UsingERC20WithStorage is UsingERC20, UsingPermitWithStorage {
    /// @notice the total supply of tokens
    /// @custom:fix this is supposed to be internal
    uint256 internal _totalSupply;
    /// @notice the mapping of allowances
    /// @custom:fix this was supposed to be internal
    mapping(address => mapping(address => uint256)) internal _allowance;
    /// @notice the mapping of account balances
    mapping(address => uint256) internal _balances;

    function _initializeERC20WithStorage() internal {
        _initializePermitWithStorage();
    }

    /// @notice get the storage for balances
    /// @return mapping(address => uint256) the storage for balances
    function _getBalancesStorage() internal view virtual override returns (mapping(address => uint256) storage){
        return _balances;
    }

    /// @notice get the storage for allowances
    /// @return mapping(address => mapping(address => uint256)) the storage for allowances
    function _getAllowanceStorage() internal view virtual override returns (mapping(address => mapping(address => uint256)) storage){
        return _allowance;
    }

    /// @notice get the storage for total supply
    /// @return uint256 the storage for total supply
    function _getTotalSupplyStorage() internal view virtual override returns (uint256){
        return _totalSupply;
    }

    /// @notice set the storage for total supply
    function _setTotalSupplyStorage(uint256 _value) internal virtual override {
        _totalSupply = _value;
    }

}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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

library collections {
    using bits for uint16;
    using collections for CircularSet;

    error KeyExists();
    error KeyError(uint key_);

    struct CircularSet {
        uint[] items;
        mapping(uint => uint) indices;
        uint iter;
    }

    function add(CircularSet storage set_, uint item_) internal {
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function add(CircularSet storage set_, address item_) internal {
        add(set_, uint(uint160(item_)));
    }

    function replace(CircularSet storage set_, uint oldItem_, uint newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError(oldItem_);
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function replace(CircularSet storage set_, address oldItem_, address newItem_) internal {
        set_.replace(uint(uint160(oldItem_)), uint(uint160(newItem_)));
    }

    function pop(CircularSet storage set_) internal returns (uint) {
        uint last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(CircularSet storage set_, uint index_) internal view returns (uint) {
        return set_.items[index_];
    }

    function getAsAddress(CircularSet storage set_, uint index_) internal view returns (address) {
        return address(uint160(get(set_, index_)));
    }

    function next(CircularSet storage set_) internal returns (uint) {
        uint item =  set_.items[set_.iter++];
        if (set_.iter >= set_.length()) {
            set_.iter = 0;
        }
        return item;
    }

    function current(CircularSet storage set_) internal view returns (uint) {
        return set_.items[set_.iter];
    }

    function currentAsAddress(CircularSet storage set_) internal view returns (address) {
        return address(uint160(set_.items[set_.iter]));
    }

    function nextAsAddress(CircularSet storage set_) internal returns (address) {
        return address(uint160(next(set_)));
    }

    function length(CircularSet storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(CircularSet storage set_, uint item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError(item_);
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[item_] = 0;
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        if (set_.iter == index) {
            set_.iter = set_.length();
        }
    }

    function remove(CircularSet storage set_, address item_) internal  {
        remove(set_, uint(uint160(item_)));
    }

    function clear(CircularSet storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            uint key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
        set_.iter = 0;
    }

    function itemsAsAddresses(CircularSet storage set_) internal view returns (address[] memory) {
        address[] memory items = new address[](set_.length());
        for (uint i = 0; i < set_.length(); i++) {
            items[i] = address(uint160(set_.items[i]));
        }
        return items;
    }

    function contains(CircularSet storage set_, address item_) internal view returns (bool) {
        return set_.indices[uint(uint160(item_))] > 0;
    }

    function indexOf(CircularSet storage set_, address item_) internal view returns (uint) {
        return set_.indices[uint(uint160(item_))] - 1;
    }

}

abstract contract UsingAccounts {
    using collections for collections.CircularSet;

    function _isAccount(address account_) internal virtual returns (bool) {
        return _getAccountsStorage().indices[uint256(uint160(account_))] > 0;
    }

    function _addAccount(address account) internal virtual  {
        return _getAccountsStorage().add(account);
    }

    function _removeAccount(address account) internal virtual  {
        return _getAccountsStorage().remove(account);
    }

    function _getAccountsStorage() internal view virtual returns (collections.CircularSet storage);
}

abstract contract UsingAccountsWithStorage is UsingAccounts {
    using collections for collections.CircularSet;

    collections.CircularSet _accounts;

    function _initializeAccountsWithStorage(address[] memory accounts_) internal {
        for (uint i = 0; i < accounts_.length; i++) {
            _addAccount(accounts_[i]);
        }
    }

    function _getAccountsStorage() internal view override returns (collections.CircularSet storage) {
        return _accounts;
    }
}

abstract contract UsingMultiToken  {
    using collections for collections.CircularSet;

    function _addToken(address token_) internal {
        _getTokensStorage().add(token_);
    }

    function _removeToken(address token_) internal {
        _getTokensStorage().remove(token_);
    }

    function _getTokensStorage() internal view virtual returns (collections.CircularSet storage);

}

abstract contract UsingMultiTokenWithStorage is UsingMultiToken {
    using collections for collections.CircularSet;

    collections.CircularSet _tokens;

    function _initializeMultiTokenWithStorage(address[] memory tokens_) internal virtual {
        for (uint i = 0; i < tokens_.length; i++) {
            if (tokens_[i] != address(0)) {
                _addToken(tokens_[i]);
            }
        }
    }

    function _getTokensStorage() internal view override returns (collections.CircularSet storage) {
        return _tokens;
    }

}

error RewardsWithdrawDisabled();
error RewardsSelectionInvalid(address);
error RewardsSelectionOutOfRange(uint, uint);
error RewardRatioMismatch(uint);

contract AffinityRewardsService is AffinityService, UsingAccountsWithStorage {
    using collections for collections.CircularSet;
    using bits for uint256;
//

    /// @notice a snapshot of an account balance at a given timestamp only one storage write
    struct AccountSnapshot {
        uint128 balance; // unclaimed rewards are total divided by total total
        uint128 updateTimestamp;
    }
    /// @notice a snapshot of rewards earned and the balance of the rewards pool at last update one storage write
    struct RewardSnapshot {
        uint128 claimed; // how many rewards have been claimed
        uint128 startingBalance;
    }

    struct Snapshot {
        AccountSnapshot account;
        mapping(address => RewardSnapshot) rewards;
    }
    /// @notice rewards selected by a given address
    mapping(address => collections.CircularSet) _rewards;
    /// @notice the snapshot for each account
    mapping(address => Snapshot) _snapshots;
    /// @notice the ratio of rewards to purchase
    mapping(address => uint) _rewardRatio;
    /// @notice the router to purchase the rewards from
    mapping(address => address) _rewardRouters;
    /// @notice the total amount of rewards purchased
    mapping(address => address[]) _rewardPaths;
    /// @notice the address of the token using this service
    address _token;
    /// @notice the divisor to set the minimum reward threshold
    uint96 _rewardDivisor;
    /// @notice the allowance left for purchasing rewards that's update once per iteration
    uint256 _rewardAllowance;
    /// @notice the number of rewards to distribute per account
    uint80 _distributionsPerBuy;
    uint80 _distributionsPerSell;
    uint80 _distributionsPerTransfer;
    uint16 _maxSelectableRewards;

    function initialize(address provider_, address token_, address[] calldata routers_, address[] calldata rewardTokens_, uint[] calldata ratios_) external initializer {
        _initializeAffinityService(provider_, 0, 0);
        _token = token_;
        for (uint i = 0; i < rewardTokens_.length; i++) {
            address rewardToken = rewardTokens_[i];
            _addRewardToken(rewardToken, ratios_[i]);
            _setRewardRouter(rewardToken, routers_[i]);
        }
        _rewardDivisor = 10 ** 9;
    }

    /// @notice set the fee for an account
    /// @param account_ the account to set the fee for
    /// @param fee_ the fee to set
    function setFee(address account_, uint fee_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFee(account_, fee_);
    }

    /// @notice set the reward divisor to set the minimum reward threshold
    /// @param divisor_ the divisor to set the minimum reward threshold
    /// @dev be mindful that the storage is a uin128 so keep the divisor large enough to ensure it won't overflow
    function setRewardDivisor(uint96 divisor_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _rewardDivisor = divisor_;
    }

    /// @notice set the number of selectable rewards allowed
    /// @param value_ the max selectable rewards allowed
    function setMaxSelectableRewards(uint16 value_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _maxSelectableRewards = value_;
    }

    /// @notice add accounts to the rewards service and update the totals
    /// @param accounts_ the accounts to add
    /// @dev requires admin privileges
    function addAccounts(address[] calldata accounts_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        for (uint i=0; i < accounts_.length;) {
            if (!_isAccount(accounts_[i])) {
                _addAccount(accounts_[i]);
            }
            unchecked {
                i++;
            }
            _updateSnapshot(accounts_[i], _scaleAmount(IERC20(_token).balanceOf(accounts_[i])), 0);
        }
    }

    /// @notice remove accounts from the rewards service
    /// @param accounts_ the accounts to remove
    /// @dev requires admin privileges
    function removeAccounts(address[] calldata accounts_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        for (uint i=0; i < accounts_.length;) {
            if (_isAccount(accounts_[i])) {
                _removeAccount(accounts_[i]);
            }
            unchecked {
                i++;
            }
        }
    }

    /// @notice set the router used to purchase rewards
    /// @param rewardToken_ the reward token to set the router for
    /// @param router_ the router to set
    /// @dev this requires admin privileges
    function setRewardRouter(address rewardToken_, address router_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setRewardRouter(rewardToken_, router_);
    }

    /// @notice set the buy, sell, and transfer distribution count
    /// @param distributionsPerBuy_ the number of accounts to distribute rewards too for each buy
    /// @param distributionsPerSell_ the number of accounts to distribute rewards too for each sell
    /// @param distributionsPerTransfer_ the number of accounts to distribute rewards too for each transfer
    /// @dev be mindful of gas usage on the token being distributed
    function setDistributions(uint80 distributionsPerBuy_, uint80 distributionsPerSell_, uint80 distributionsPerTransfer_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        (_distributionsPerBuy, _distributionsPerSell, _distributionsPerTransfer) = (distributionsPerBuy_, distributionsPerSell_, distributionsPerTransfer_);
    }

    /// @notice replace a reward token with a new one
    /// @param oldRewardToken_ the old reward token to replace
    /// @param newRewardToken_ the new reward token to use
    /// @param ratio_ the new ratio to be purchased
    function replaceReward(address oldRewardToken_, address newRewardToken_, uint ratio_, address router_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        delete _rewardRouters[oldRewardToken_];
        delete _rewardRatio[oldRewardToken_];
        delete _rewardRouters[newRewardToken_];
        _rewards[address(this)].replace(oldRewardToken_, newRewardToken_);
        _rewardRatio[newRewardToken_] = ratio_;
        _rewardRouters[newRewardToken_] = router_;
    }

    /// @notice Add a reward to the selectable reward mapping
    /// @param rewardToken_ the reward token to add
    /// @param ratio_ the ratio to be purchased
    /// @param router_ the router to purchase the rewards from
    function addReward(address rewardToken_, uint[] calldata ratio_, address router_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _rewards[address(this)].add(rewardToken_);
        _setRewardRouter(rewardToken_, router_);
        collections.CircularSet storage rewards = _rewards[address(this)];
        if (rewards.length() > ratio_.length) {
            revert RewardRatioMismatch(ratio_.length);
        }
        for (uint i = 0; i < rewards.length(); i++) {
            _rewardRatio[rewards.getAsAddress(i)] = ratio_[i];
        }
    }

    /// @notice claim available rewards for an account
    /// @param account_ the account to claim rewards for
    function claim(address account_) external  {
        Snapshot storage accountSnapshot = _snapshots[account_];
        collections.CircularSet storage rewards = _rewards[account_];
        _claim(account_, accountSnapshot, rewards);
    }

    /// @notice selectRewards for an account
    /// @param rewards_ the new selection of rewards_
    /// @dev claim rewards prior to changing the selected rewards then re-initialize the rewards snapshots
    function selectRewards(address[] calldata rewards_) external  {
        if (rewards_.length > _maxSelectableRewards) {
            revert RewardsSelectionOutOfRange(rewards_.length, _maxSelectableRewards);
        }
        collections.CircularSet storage rewards = _rewards[msg.sender];
        collections.CircularSet storage selectableRewards = _rewards[address(this)];
        Snapshot storage accountSnapshot = _snapshots[msg.sender];
        _claim(msg.sender, accountSnapshot, rewards);
        rewards.clear();
        for (uint i=0; i < rewards_.length;) {
            address reward = rewards_[i];
            if (!selectableRewards.contains(reward)) {
                revert RewardsSelectionInvalid(reward);
            }
            rewards.add(rewards_[i]);
            _initializeRewardSnapshot(accountSnapshot, reward);
            unchecked {
                i++;
            }
        }
    }

    function withdrawTokens(address token_, address to_, uint amount_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        IERC20(token_).transfer(to_, amount_);
    }

    /// @notice the selected rewards for an account
    /// @param account_ the account to get the selected rewards for
    /// @return the selected rewards for an account
    function selected(address account_) external view returns (address[] memory) {
        return _rewards[account_].itemsAsAddresses();
    }

    /// @notice selectable rewards
    /// @return the selectable rewards
    function selectable() external view returns (address[] memory) {
        return _rewards[address(this)].itemsAsAddresses();
    }

    /// @notice distribute rewards to accounts
    /// @param count_ the number of accounts to distribute rewards to
    function distribute(uint count_) external {
        _distribute(count_);
    }

    /// @notice export the accounts being tracked inside the rewards service
    /// @param begin_ the index to start at
    /// @param end_ the index to end at
    /// @dev use this in conjunction with totalAccounts to get all the accounts
    function accounts(uint256 begin_, uint256 end_) public view returns (address[] memory) {
        address[] memory accounts = new address[](end_ - begin_);
        uint index;
        for (uint i=begin_; i < end_;) {
            accounts[index++] = _accounts.getAsAddress(i);
            unchecked {
                i++;
            }
        }
        return accounts;
    }

    /// @notice the total number of accounts being tracked inside the rewards service
    /// @return the total number of accounts being tracked inside the rewards service
    function totalAccounts() external view returns (uint256) {
        return _accounts.length();
    }

    /// @notice get the snapshot for an account of a given reward
    /// @param account_ the account to get the snapshot for
    /// @return the account snapshot and a snapshot of all the selectable rewards
    function snapshot(address account_) external view returns (AccountSnapshot memory, RewardSnapshot[] memory, address[] memory) {
        collections.CircularSet storage rewards = _rewards[address(this)];
        RewardSnapshot[] memory rewardSnapshots = new RewardSnapshot[](rewards.length());
        for (uint i=0; i < rewards.length();) {
            rewardSnapshots[i] = _snapshots[account_].rewards[rewards.getAsAddress(i)];
            unchecked {
                i++;
            }
        }
        return (_snapshots[account_].account, rewardSnapshots, _rewards[account_].itemsAsAddresses());
    }

    function _claim(address account_, Snapshot storage accountSnapshot_, collections.CircularSet storage rewards_) internal{
        uint128 totalBalance = _snapshots[address(this)].account.balance;
        uint128 rewardDivisor = _rewardDivisor;
        for (uint i=0; i < rewards_.length();) {
            address reward = rewards_.getAsAddress(i);
            uint128 rewardTotal = _snapshots[reward].account.balance + _snapshots[reward].rewards[reward].claimed;
            uint128 claimed = _distributeRewardToAccount(totalBalance, reward, rewardTotal, rewardDivisor, account_);
            _updateRewardSnapshot(accountSnapshot_, reward, claimed, rewardTotal);
            unchecked {
                i++;
            }
        }
    }

    function _initializeRewardSnapshot(Snapshot storage accountSnapshot_, address reward_) internal {
        Snapshot storage rewardSnapshot = _snapshots[reward_];
        _updateRewardSnapshot(accountSnapshot_, reward_, 0, rewardSnapshot.account.balance + rewardSnapshot.rewards[reward_].claimed);
    }

    function _addAccount(address account_) internal override {
        super._addAccount(account_);
        Snapshot storage accountSnapshot = _snapshots[account_];
        for (uint i=0; i < _maxSelectableRewards;) {
            // new accounts should not be distributed any pending rewards
            // set the starting balance so that the account only claims future rewards from this point on
            _initializeRewardSnapshot(accountSnapshot, _rewards[address(this)].getAsAddress(i));
            unchecked {
                i++;
            }
        }
    }

    function _removeAccount(address account_) internal override {
        super._removeAccount(account_);
        delete _snapshots[account_];
    }

    function _addRewardToken(address reward_, uint ratio_) internal {
        _rewards[address(this)].add(reward_);
        _rewardRatio[reward_] = ratio_;
    }

    function _setRewardRouter(address reward_, address router_) internal {
        address[] memory path = _rewardPaths[reward_] = new address[](2);
        (path[0], path[1]) = (IUniswapV2Router02(router_).WETH(), reward_);
    }

    function _setRewardRatio(address reward_, uint ratio_) internal {
        _rewardRatio[reward_] = ratio_;
    }

    function _timestamp() internal view returns (uint128) {
        return uint128(block.timestamp / 60);
    }

    function _calculateUnclaimedRewards(address reward_, uint128 rewardTotal_, uint128 rewardDivisor_, Snapshot storage accountSnapshot_, uint128 totalBalance_) internal view returns (uint128) {
        RewardSnapshot storage rewards = accountSnapshot_.rewards[reward_];
        uint128 unclaimed = rewardTotal_ - rewards.startingBalance;
        return accountSnapshot_.account.balance * _calculateRewardPerToken(unclaimed, rewardDivisor_, totalBalance_) / rewardDivisor_;
    }

    function _calculateRewardPerToken(uint128 unclaimed_, uint128 rewardDivisor_, uint128 totalBalance_) internal view returns (uint128) {
        return unclaimed_ * rewardDivisor_ / totalBalance_;
    }

    function _updateRewardSnapshot(Snapshot storage accountSnapshot_, address reward_, uint128 claimedIncrease_, uint128 startingBalance_) internal {
        RewardSnapshot storage rewardsSnapshot = accountSnapshot_.rewards[reward_];
        accountSnapshot_.rewards[reward_] = RewardSnapshot(rewardsSnapshot.claimed + claimedIncrease_, startingBalance_);
    }

    function _isRewardToken(address address_) internal returns (bool) {
        return _rewards[address(this)].contains(address_);
    }

    function _updateAccountSnapshot(Snapshot storage accountSnapshot_, address account_, uint128 balanceIncrease_, uint128 balanceDecrease_) internal {
        uint128 balance = (accountSnapshot_.account.balance + balanceIncrease_) - balanceDecrease_;
        if (balance > 0) {
            accountSnapshot_.account = AccountSnapshot(balance, _timestamp());
        } else if (!_isRewardToken(account_)) {
            _removeAccount(account_);
        }
    }

    function _updateSnapshot(address account_, uint128 increaseBalance_, uint128 decreaseBalance_) internal {
        _updateAccountSnapshot(_snapshots[account_], account_, increaseBalance_, decreaseBalance_);
    }

    function _scaleAmount(uint256 amount_) internal view returns (uint128) {
        return uint128(amount_ / _rewardDivisor);
    }

    function _calculateFee(address from_, address to_, uint amount_) internal view override returns (uint) {
        return _fees[from_] + _fees[to_];
    }

    function _swapForReward(address reward_, uint value_) internal {
        Snapshot storage rewardSnapshot = _snapshots[reward_];
        address[] storage path = _rewardPaths[reward_];
        uint value = value_ * _rewardRatio[reward_] / DEFAULT_PRECISION;
        uint oldRewardBalance = IERC20(reward_).balanceOf(address(this));
        IUniswapV2Router02(_rewardRouters[reward_]).swapExactETHForTokensSupportingFeeOnTransferTokens{value: value}(0, path, address(this), block.timestamp + 1);
        _updateAccountSnapshot(rewardSnapshot, reward_, _scaleAmount(IERC20(reward_).balanceOf(address(this)) - oldRewardBalance), 0);
    }

    function _swapForRewards(uint balance_) internal {
        collections.CircularSet storage rewards = _rewards[address(this)];
        address reward = rewards.nextAsAddress();
        uint allowance = _rewardAllowance;
        if (rewards.iter == 0) {
            allowance = _rewardAllowance = _rewardAllowance + balance_;
        }
        _swapForReward(reward, allowance);
    }

    function _isRewardDistributionDisabled() internal view returns (bool) {
        return _getFlags(address(this)).all(_REWARD_DISTRIBUTION_DISABLED_FLAG());
    }

    function _isRewardSwapDisabled() internal view returns (bool) {
        return _getFlags(address(this)).all(_REWARD_SWAP_DISABLED_FLAG());
    }

    function _process(address from_, address to_, uint amount_) internal override returns (uint256) {
        uint toFlags = _getFlags(to_);
        uint fromFlags = _getFlags(from_);
        if (!_isRewardSwapDisabled()) {
            uint balance = address(this).balance;
            if (balance > 0) {
                _swapForRewards(balance);
            }
        }
        uint128 amount = _scaleAmount(amount_);
        if (!_isRewardExempt(to_)) {
            if (!_isAccount(to_)) _addAccount(to_);
            _updateSnapshot(to_, amount, 0);
            _updateSnapshot(address(this), amount, 0);
        }
        if (!_isRewardExempt(from_)) {
            _updateSnapshot(from_, 0, amount);
            _updateSnapshot(address(this), 0, amount);
        }
        if (!_isRewardDistributionDisabled()) {
            _distribute(_isLPPair(from_), _isLPPair(to_));
        }
        return super._process(from_, to_, amount_);
    }

    function _distributeRewardToAccount(uint128 totalBalance_,  address reward_, uint128 rewardTotal_, uint128 rewardDivisor_, address account_) internal returns (uint128) {
        Snapshot storage accountSnapshot = _snapshots[account_];
        uint128 amount;
        if (accountSnapshot.account.balance > 0) {
            amount = _calculateUnclaimedRewards(reward_, rewardTotal_, rewardDivisor_, accountSnapshot, totalBalance_);
            if (amount > 0) {
                IERC20(reward_).transfer(account_, amount * _rewardDivisor);
                _updateAccountSnapshot(accountSnapshot, account_, 0, 0);
                _updateRewardSnapshot(accountSnapshot, reward_, amount, rewardTotal_);
            }
        }
        return amount;
    }

    function _distributeReward(uint128 totalBalance_, address reward_,  uint128 rewardDivisor_, uint count_) internal returns (uint128){
        Snapshot storage rewardSnapshot = _snapshots[reward_];
        uint128 rewardTotal = rewardSnapshot.account.balance + rewardSnapshot.rewards[reward_].claimed;
        uint128 amount;
        for (uint i=0; i < count_;) {
            address account = _accounts.nextAsAddress();
            if (_rewards[account].contains(reward_)) {
                amount += _distributeRewardToAccount(totalBalance_, reward_, rewardTotal, rewardDivisor_, account);
            }
            unchecked {
                i++;
            }
        }
        return amount;
    }

    /// @notice distribute rewards to a number of accounts in round robin fashion
    /// @dev rewards are distributed per count per each reward token
    function _distribute(uint count_) internal {
        Snapshot storage thisSnapshot = _snapshots[address(this)];
        collections.CircularSet storage rewards = _rewards[address(this)];
        uint128 totalBalance = thisSnapshot.account.balance; // gas optimization
        uint128 rewardDivisor = _rewardDivisor; // gas optimization
        uint128 claimed;
        for (uint i=0; i < rewards.length();) {
            address reward = rewards.getAsAddress(i);
            claimed = _distributeReward(totalBalance, reward, rewardDivisor, count_);
            _updateRewardSnapshot(thisSnapshot, reward, claimed, 0);
            unchecked {
                i++;
            }
        }
    }

    /// @notice distribute rewards during processing
    function _distribute(bool isBuy_, bool isSell_) internal {
        if (isBuy_) {
            _distribute(_distributionsPerBuy);
        } else if (isSell_) {
            _distribute(_distributionsPerSell);
        } else {
            _distribute(_distributionsPerTransfer);
        }
    }

}