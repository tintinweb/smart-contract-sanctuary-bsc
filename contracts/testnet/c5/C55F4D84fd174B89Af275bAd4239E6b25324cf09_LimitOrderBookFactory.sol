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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
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
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
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
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/UpgradeableBeacon.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../../access/Ownable.sol";
import "../../utils/Address.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

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
library StorageSlot {
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
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
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
    function toHexString(uint256 value) internal pure returns (string memory) {
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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICDFTable {
    function addRows(int128[] calldata _fKeys, int128[] calldata _fValues) external;

    function getValue(int128 _fKey) external view returns (int128);
}

// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly
pragma solidity 0.8.13;

/**
 * A base contract to be inherited by any contract that want to receive relayed transactions
 * A subclass must use "msgSender()" instead of "msg.sender"
 */
abstract contract BaseRelayRecipient {
    /*
     * Forwarder singleton we accept calls from
     */
    address internal _trustedForwarder;

    function _isTrustedForwarder(address forwarder) internal view returns (bool) {
        return forwarder == _trustedForwarder;
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function msgSender() internal view returns (address payable ret) {
        if (msg.data.length >= 20 && _isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            ret = payable(msg.sender);
        }
    }

    /**
     * return the msg.data of this call.
     * if the call came through our trusted forwarder, then the real sender was appended as the last 20 bytes
     * of the msg.data - so this method will strip those 20 bytes off.
     * otherwise (if the call was made directly and not through the forwarder), return `msg.data`
     * should be used in the contract instead of msg.data, where this difference matters.
     */
    function msgData() internal view returns (bytes calldata ret) {
        if (msg.data.length >= 20 && _isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IShareTokenFactory {
    function createShareToken() external returns (address);
}

// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity 0.8.13;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
    /*
     * Minimum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt(int256 x) internal pure returns (int128) {
        require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF, "ABDK.fromInt");
        return int128(x << 64);
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt(int128 x) internal pure returns (int64) {
        return int64(x >> 64);
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt(uint256 x) internal pure returns (int128) {
        require(x <= 0x7FFFFFFFFFFFFFFF, "ABDK.fromUInt");
        return int128(int256(x << 64));
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt(int128 x) internal pure returns (uint64) {
        require(x >= 0, "ABDK.toUInt");
        return uint64(uint128(x >> 64));
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128(int256 x) internal pure returns (int128) {
        int256 result = x >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.from128x128");
        return int128(result);
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128(int128 x) internal pure returns (int256) {
        return int256(x) << 64;
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add(int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) + y;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.add");
        return int128(result);
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub(int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) - y;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.sub");
        return int128(result);
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul(int128 x, int128 y) internal pure returns (int128) {
        int256 result = (int256(x) * y) >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.mul");
        return int128(result);
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli(int128 x, int256 y) internal pure returns (int256) {
        if (x == MIN_64x64) {
            require(y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF && y <= 0x1000000000000000000000000000000000000000000000000, "ABDK.muli-1");
            return -y << 63;
        } else {
            bool negativeResult = false;
            if (x < 0) {
                x = -x;
                negativeResult = true;
            }
            if (y < 0) {
                y = -y;
                // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint256 absoluteResult = mulu(x, uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000, "ABDK.muli-2");
                return -int256(absoluteResult);
                // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "ABDK.muli-3");
                return int256(absoluteResult);
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu(int128 x, uint256 y) internal pure returns (uint256) {
        if (y == 0) return 0;

        require(x >= 0, "ABDK.mulu-1");

        uint256 lo = (uint256(int256(x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
        uint256 hi = uint256(int256(x)) * (y >> 128);

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "ABDK.mulu-2");
        hi <<= 64;

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo, "ABDK.mulu-3");
        return hi + lo;
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) internal pure returns (int128) {
        require(y != 0, "ABDK.div-1");
        int256 result = (int256(x) << 64) / y;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.div-2");
        return int128(result);
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi(int256 x, int256 y) internal pure returns (int128) {
        require(y != 0, "ABDK.divi-1");

        bool negativeResult = false;
        if (x < 0) {
            x = -x;
            // We rely on overflow behavior here
            negativeResult = true;
        }
        if (y < 0) {
            y = -y;
            // We rely on overflow behavior here
            negativeResult = !negativeResult;
        }
        uint128 absoluteResult = divuu(uint256(x), uint256(y));
        if (negativeResult) {
            require(absoluteResult <= 0x80000000000000000000000000000000, "ABDK.divi-2");
            return -int128(absoluteResult);
            // We rely on overflow behavior here
        } else {
            require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "ABDK.divi-3");
            return int128(absoluteResult);
            // We rely on overflow behavior here
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu(uint256 x, uint256 y) internal pure returns (int128) {
        require(y != 0, "ABDK.divu-1");
        uint128 result = divuu(x, y);
        require(result <= uint128(MAX_64x64), "ABDK.divu-2");
        return int128(result);
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg(int128 x) internal pure returns (int128) {
        require(x != MIN_64x64, "ABDK.neg");
        return -x;
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs(int128 x) internal pure returns (int128) {
        require(x != MIN_64x64, "ABDK.abs");
        return x < 0 ? -x : x;
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv(int128 x) internal pure returns (int128) {
        require(x != 0, "ABDK.inv-1");
        int256 result = int256(0x100000000000000000000000000000000) / x;
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.inv-2");
        return int128(result);
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg(int128 x, int128 y) internal pure returns (int128) {
        return int128((int256(x) + int256(y)) >> 1);
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg(int128 x, int128 y) internal pure returns (int128) {
        int256 m = int256(x) * int256(y);
        require(m >= 0, "ABDK.gavg-1");
        require(m < 0x4000000000000000000000000000000000000000000000000000000000000000, "ABDK.gavg-2");
        return int128(sqrtu(uint256(m)));
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow(int128 x, uint256 y) internal pure returns (int128) {
        bool negative = x < 0 && y & 1 == 1;

        uint256 absX = uint128(x < 0 ? -x : x);
        uint256 absResult;
        absResult = 0x100000000000000000000000000000000;

        if (absX <= 0x10000000000000000) {
            absX <<= 63;
            while (y != 0) {
                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x2 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x4 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x8 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                y >>= 4;
            }

            absResult >>= 64;
        } else {
            uint256 absXShift = 63;
            if (absX < 0x1000000000000000000000000) {
                absX <<= 32;
                absXShift -= 32;
            }
            if (absX < 0x10000000000000000000000000000) {
                absX <<= 16;
                absXShift -= 16;
            }
            if (absX < 0x1000000000000000000000000000000) {
                absX <<= 8;
                absXShift -= 8;
            }
            if (absX < 0x10000000000000000000000000000000) {
                absX <<= 4;
                absXShift -= 4;
            }
            if (absX < 0x40000000000000000000000000000000) {
                absX <<= 2;
                absXShift -= 2;
            }
            if (absX < 0x80000000000000000000000000000000) {
                absX <<= 1;
                absXShift -= 1;
            }

            uint256 resultShift = 0;
            while (y != 0) {
                require(absXShift < 64, "ABDK.pow-1");

                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                    resultShift += absXShift;
                    if (absResult > 0x100000000000000000000000000000000) {
                        absResult >>= 1;
                        resultShift += 1;
                    }
                }
                absX = (absX * absX) >> 127;
                absXShift <<= 1;
                if (absX >= 0x100000000000000000000000000000000) {
                    absX >>= 1;
                    absXShift += 1;
                }

                y >>= 1;
            }

            require(resultShift < 64, "ABDK.pow-2");
            absResult >>= 64 - resultShift;
        }
        int256 result = negative ? -int256(absResult) : int256(absResult);
        require(result >= MIN_64x64 && result <= MAX_64x64, "ABDK.pow-3");
        return int128(result);
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt(int128 x) internal pure returns (int128) {
        require(x >= 0, "ABDK.sqrt");
        return int128(sqrtu(uint256(int256(x)) << 64));
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2(int128 x) internal pure returns (int128) {
        require(x > 0, "ABDK.log_2");

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) {
            xc >>= 64;
            msb += 64;
        }
        if (xc >= 0x100000000) {
            xc >>= 32;
            msb += 32;
        }
        if (xc >= 0x10000) {
            xc >>= 16;
            msb += 16;
        }
        if (xc >= 0x100) {
            xc >>= 8;
            msb += 8;
        }
        if (xc >= 0x10) {
            xc >>= 4;
            msb += 4;
        }
        if (xc >= 0x4) {
            xc >>= 2;
            msb += 2;
        }
        if (xc >= 0x2) msb += 1;
        // No need to shift xc anymore

        int256 result = (msb - 64) << 64;
        uint256 ux = uint256(int256(x)) << uint256(127 - msb);
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256(b);
        }

        return int128(result);
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0, "ABDK.ln");

            return int128(int256(
                (uint256(int256(log_2(x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128));
        }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2(int128 x) internal pure returns (int128) {
        require(x < 0x400000000000000000, "ABDK.exp_2-1");
        // Overflow

        if (x < -0x400000000000000000) return 0;
        // Underflow

        uint256 result = 0x80000000000000000000000000000000;

        if (x & 0x8000000000000000 > 0) result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
        if (x & 0x4000000000000000 > 0) result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
        if (x & 0x2000000000000000 > 0) result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
        if (x & 0x1000000000000000 > 0) result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
        if (x & 0x800000000000000 > 0) result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
        if (x & 0x400000000000000 > 0) result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
        if (x & 0x200000000000000 > 0) result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
        if (x & 0x100000000000000 > 0) result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
        if (x & 0x80000000000000 > 0) result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
        if (x & 0x40000000000000 > 0) result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
        if (x & 0x20000000000000 > 0) result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
        if (x & 0x10000000000000 > 0) result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
        if (x & 0x8000000000000 > 0) result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
        if (x & 0x4000000000000 > 0) result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
        if (x & 0x2000000000000 > 0) result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
        if (x & 0x1000000000000 > 0) result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
        if (x & 0x800000000000 > 0) result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
        if (x & 0x400000000000 > 0) result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
        if (x & 0x200000000000 > 0) result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
        if (x & 0x100000000000 > 0) result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
        if (x & 0x80000000000 > 0) result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
        if (x & 0x40000000000 > 0) result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
        if (x & 0x20000000000 > 0) result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
        if (x & 0x10000000000 > 0) result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
        if (x & 0x8000000000 > 0) result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
        if (x & 0x4000000000 > 0) result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
        if (x & 0x2000000000 > 0) result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
        if (x & 0x1000000000 > 0) result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
        if (x & 0x800000000 > 0) result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
        if (x & 0x400000000 > 0) result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
        if (x & 0x200000000 > 0) result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
        if (x & 0x100000000 > 0) result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
        if (x & 0x80000000 > 0) result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
        if (x & 0x40000000 > 0) result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
        if (x & 0x20000000 > 0) result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
        if (x & 0x10000000 > 0) result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
        if (x & 0x8000000 > 0) result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
        if (x & 0x4000000 > 0) result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
        if (x & 0x2000000 > 0) result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
        if (x & 0x1000000 > 0) result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
        if (x & 0x800000 > 0) result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
        if (x & 0x400000 > 0) result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
        if (x & 0x200000 > 0) result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
        if (x & 0x100000 > 0) result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
        if (x & 0x80000 > 0) result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
        if (x & 0x40000 > 0) result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
        if (x & 0x20000 > 0) result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
        if (x & 0x10000 > 0) result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
        if (x & 0x8000 > 0) result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
        if (x & 0x4000 > 0) result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
        if (x & 0x2000 > 0) result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
        if (x & 0x1000 > 0) result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
        if (x & 0x800 > 0) result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
        if (x & 0x400 > 0) result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
        if (x & 0x200 > 0) result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
        if (x & 0x100 > 0) result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
        if (x & 0x80 > 0) result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
        if (x & 0x40 > 0) result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
        if (x & 0x20 > 0) result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
        if (x & 0x10 > 0) result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
        if (x & 0x8 > 0) result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
        if (x & 0x4 > 0) result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
        if (x & 0x2 > 0) result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
        if (x & 0x1 > 0) result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

        result >>= uint256(int256(63 - (x >> 64)));
        require(result <= uint256(int256(MAX_64x64)), "ABDK.exp_2-2");

        return int128(int256(result));
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp(int128 x) internal pure returns (int128) {
        require(x < 0x400000000000000000, "ABDK.exp");
        // Overflow

        if (x < -0x400000000000000000) return 0;
        // Underflow

        return exp_2(int128((int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128));
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu(uint256 x, uint256 y) private pure returns (uint128) {
        require(y != 0, "ABDK.divuu-1");

        uint256 result;

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) result = (x << 64) / y;
        else {
            uint256 msb = 192;
            uint256 xc = x >> 192;
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1;
            // No need to shift xc anymore

            result = (x << (255 - msb)) / (((y - 1) >> (msb - 191)) + 1);
            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "ABDK.divuu-2");

            uint256 hi = result * (y >> 128);
            uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 xh = x >> 192;
            uint256 xl = x << 64;

            if (xl < lo) xh -= 1;
            xl -= lo;
            // We rely on overflow behavior here
            lo = hi << 128;
            if (xl < lo) xh -= 1;
            xl -= lo;
            // We rely on overflow behavior here

            assert(xh == hi >> 128);

            result += xl / y;
        }

        require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "ABDK.divuu-3");
        return uint128(result);
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu(uint256 x) private pure returns (uint128) {
        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128(r < r1 ? r : r1);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library Bytes32Pagination {
    function paginate(
        bytes32[] memory hashes,
        uint256 page,
        uint256 limit
    ) internal pure returns (bytes32[] memory result) {
        result = new bytes32[](limit);
        for (uint256 i = 0; i < limit; i++) {
            if (page * limit + i < hashes.length) {
                result[i] = hashes[page * limit + i];
            } else {
                break;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @title Library for managing loan sets.
 *
 * @notice Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Include with `using EnumerableBytes4Set for EnumerableBytes4Set.Bytes4Set;`.
 * */
library EnumerableBytes4Set {
    struct Bytes4Set {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes4 => uint256) index;
        bytes4[] values;
    }

    /**
     * @notice Add an address value to a set. O(1).
     *
     * @param set The set of values.
     * @param addrvalue The address to add.
     *
     * @return False if the value was already in the set.
     */
    function addAddress(Bytes4Set storage set, address addrvalue) internal returns (bool) {
        bytes4 value;
        assembly {
            value := addrvalue
        }
        return addBytes4(set, value);
    }

    /**
     * @notice Add a value to a set. O(1).
     *
     * @param set The set of values.
     * @param value The new value to add.
     *
     * @return False if the value was already in the set.
     */
    function addBytes4(Bytes4Set storage set, bytes4 value) internal returns (bool) {
        if (!contains(set, value)) {
            set.values.push(value);
            set.index[value] = set.values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Remove an address value from a set. O(1).
     *
     * @param set The set of values.
     * @param addrvalue The address to remove.
     *
     * @return False if the address was not present in the set.
     */
    function removeAddress(Bytes4Set storage set, address addrvalue) internal returns (bool) {
        bytes4 value;
        assembly {
            value := addrvalue
        }
        return removeBytes4(set, value);
    }

    /**
     * @notice Remove a value from a set. O(1).
     *
     * @param set The set of values.
     * @param value The value to remove.
     *
     * @return False if the value was not present in the set.
     */
    function removeBytes4(Bytes4Set storage set, bytes4 value) internal returns (bool) {
        if (contains(set, value)) {
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            /// If the element we're deleting is the last one,
            /// we can just remove it without doing a swap.
            if (lastIndex != toDeleteIndex) {
                bytes4 lastValue = set.values[lastIndex];

                /// Move the last value to the index where the deleted value is.
                set.values[toDeleteIndex] = lastValue;

                /// Update the index for the moved value.
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            /// Delete the index entry for the deleted value.
            delete set.index[value];

            /// Delete the old entry for the moved value.
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Find out whether a value exists in the set.
     *
     * @param set The set of values.
     * @param value The value to find.
     *
     * @return True if the value is in the set. O(1).
     */
    function contains(Bytes4Set storage set, bytes4 value) internal view returns (bool) {
        return set.index[value] != 0;
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsAddress(Bytes4Set storage set, address addrvalue) internal view returns (bool) {
        bytes4 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

    /**
     * @notice Get all set values.
     *
     * @param set The set of values.
     * @param start The offset of the returning set.
     * @param count The limit of number of values to return.
     *
     * @return output An array with all values in the set. O(N).
     *
     * @dev Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * WARNING: This function may run out of gas on large sets: use {length} and
     * {get} instead in these cases.
     */
    function enumerate(
        Bytes4Set storage set,
        uint256 start,
        uint256 count
    ) internal view returns (bytes4[] memory output) {
        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes4[](end - start);
        for (uint256 i; i < end - start; i++) {
            output[i] = set.values[i + start];
        }
        return output;
    }

    /**
     * @notice Get the legth of the set.
     *
     * @param set The set of values.
     *
     * @return the number of elements on the set. O(1).
     */
    function length(Bytes4Set storage set) internal view returns (uint256) {
        return set.values.length;
    }

    /**
     * @notice Get an item from the set by its index.
     *
     * @dev Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * @param set The set of values.
     * @param index The index of the value to return.
     *
     * @return the element stored at position `index` in the set. O(1).
     */
    function get(Bytes4Set storage set, uint256 index) internal view returns (bytes4) {
        return set.values[index];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function enumerate(
        AddressSet storage set,
        uint256 start,
        uint256 count
    ) internal view returns (address[] memory output) {
        uint256 end = start + count;
        require(end >= start, "addition overflow");
        uint256 len = length(set);
        end = len < end ? len : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new address[](end - start);
        for (uint256 i; i < end - start; i++) {
            output[i] = at(set, i + start);
        }
        return output;
    }

    function enumerateAll(AddressSet storage set) internal view returns (address[] memory output) {
        return enumerate(set, 0, length(set));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library RSKAddrValidator {
    /*
     * @param addr it is an address to check that it does not originates from
     * signing with PK = ZERO. RSK has a small difference in which @ZERO_PK_ADDR is
     * also an address from PK = ZERO. So we check for both of them.
     * */
    function checkPKNotZero(address addr) internal pure returns (bool) {
        return (addr != 0xdcc703c0E500B653Ca82273B7BFAd8045D85a470 && addr != address(0));
    }

    /*
     * Safely compares two addresses, checking they do not originate from
     * a zero private key.
     * */
    function safeEquals(address addr1, address addr2) internal pure returns (bool) {
        return (addr1 == addr2 && addr1 != 0xdcc703c0E500B653Ca82273B7BFAd8045D85a470 && addr1 != address(0));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

//import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../../interface/IShareTokenFactory.sol";
import "../../libraries/ABDKMath64x64.sol";
import "./../functions/AMMPerpLogic.sol";
import "../../libraries/EnumerableSetUpgradeable.sol";
import "../../libraries/EnumerableBytes4Set.sol";
import "../../gsn/BaseRelayRecipient.sol";

contract PerpStorage is Ownable, ReentrancyGuard, BaseRelayRecipient {
    using ABDKMath64x64 for int128;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableBytes4Set for EnumerableBytes4Set.Bytes4Set; // enumerable map of bytes4 or addresses
    /**
     * @notice  Perpetual state:
     *          - INVALID:      Uninitialized or not non-existent perpetual.
     *          - INITIALIZING: Only when LiquidityPoolData.isRunning == false. Traders cannot perform operations.
     *          - NORMAL:       Full functional state. Traders are able to perform all operations.
     *          - EMERGENCY:    Perpetual is unsafe and the perpetual needs to be settled.
     *          - CLEARED:      All margin accounts are cleared. Traders can withdraw remaining margin balance.
     */
    enum PerpetualState {
        INVALID,
        INITIALIZING,
        NORMAL,
        EMERGENCY,
        CLEARED
    }

    // margin and liquidity pool are held in 'collateral currency' which can be either of
    // quote currency, base currency, or quanto currency

    int128 internal constant ONE_64x64 = 0x10000000000000000; // 2^64
    //int128 internal constant ONE_HUNDRED_64x64 = 0x640000000000000000; // 100 * 2^64
    int128 internal constant FUNDING_INTERVAL_SEC = 0x70800000000000000000; //3600 * 8 * 0x10000000000000000 = 8h in seconds scaled by 2^64 for ABDKMath64x64
    int128 internal constant CEIL_PNL_SHARE = 0xc000000000000000; //=0.75: participants get PnL proportional to min[PFund/(PFund+allAMMFundSizes), 75%]
    int128 internal constant CEIL_AMT_FUND_WITHDRAWAL = 0xc000000000000000; //=0.75: maximal relative amount we withdraw from the default fund and stakers in rebalance
    int128 internal constant PRICE_MOVE_THRESHOLD = 0xa7c5ac471b47; //0.00001... =0.1 bps: if index price changes more than that, we rebalance
    // at target, 1% of missing amount is transferred
    // at every rebalance

    IShareTokenFactory internal shareTokenFactory;

    uint256 internal iPoolCount;
    //pool id (incremental index, starts from 1) => pool data
    mapping(uint256 => LiquidityPoolData) internal liquidityPools;

    //bytes32 id = keccak256(abi.encodePacked(poolId, perpetualIndex));
    //perpetual id (hash(poolId, perpetualIndex)) => pool id
    mapping(bytes32 => uint256) internal perpetualPoolIds;

    /**
     * @notice  Data structure to store oracle price data.
     */
    struct OraclePriceData {
        int128 fPrice;
        uint256 time;
        bool isInSignificant; // set to true if price change is not significant
    }

    /**
     * @notice  Data structure to store user margin information.
     */
    struct MarginAccount {
        int128 fLockedInValueQC; // unrealized value locked-in when trade occurs in
        int128 fCashCC; // cash in collateral currency (base, quote, or quanto)
        int128 fPositionBC; // position in base currency (e.g., 1 BTC for BTCUSD)
        int128 fUnitAccumulatedFundingStart; // accumulated funding rate
        bytes32 positionId; // unique id for the position (for given trader, and perpetual). Current position, zero otherwise.
    }

    /**
     * @notice  Store information for a given perpetual market.
     */
    struct PerpetualData {
        //keccak256(abi.encodePacked(poolId, perpetualIndex)), perpetualIndex starts from 1
        bytes32 id;
        uint256 poolId;
        address oracleS2Addr; //parameter: base-quote pair
        address oracleS3Addr; //parameter: quanto index
        //prices
        OraclePriceData currentPremiumRate; //signed relative diff to index price
        OraclePriceData currentMarkPremiumRate; //relative diff to index price EMA, used for markprice.. was: currentPremiumRateEMA
        int128 premiumRatesEMA; // EMA of premium rate
        OraclePriceData settlementMarkPremiumRate; //relative diff to index price EMA, used for markprice..was: settlementPremiumRateEMA
        OraclePriceData settlementS2PriceData; //base-quote pair
        OraclePriceData settlementS3PriceData; //quanto index
        // funding state
        int128 fCurrentFundingRate;
        int128 fUnitAccumulatedFunding; //accumulated funding in collateral currency
        // Perpetual AMM state
        PerpetualState state;
        int128 fOpenInterest; //open interest is the amount of long positions in base currency or, equiv., the amount of short positions.
        int128 fAMMFundCashCC; // fund-cash in this perpetual - not margin
        int128 fkStar; // signed trade size that minimizes the AMM risk
        int128 fkStarSide; // corresponds to sign(-k*)
        // base parameters
        int128 fInitialMarginRateAlpha; //parameter: initial margin
        int128 fMarginRateBeta; //parameter: initial margin increase factor m=alpha+beta*pos
        int128 fInitialMarginRateCap; //parameter: initial margin stops growing at cap
        int128 fMaintenanceMarginRateAlpha; //parameter: required maintenance margin
        int128 fTreasuryFeeRate; //parameter: fee that the treasury earns
        int128 fPnLPartRate; //parameter: fee that the PnL participants earn
        int128 fReferralRebateCC; //parameter: referall rebate in collateral currency
        int128 fLiquidationPenaltyRate; //parameter: penalty if AMM closes the position and not the trader
        int128 fMinimalSpread; //parameter: minimal spread between long and short perpetual price
        int128 fMinimalSpreadInStress; //parameter: minimal spread between long and short perpetual price if Default Fund underfunded
        int128 fLotSizeBC; //parameter: minimal trade unit (in base currency) to avoid dust positions
        // risk parameters for underlying instruments
        int128 fFundingRateClamp; // parameter: funding rate clamp between which we charge 1bps
        int128 fMarkPriceEMALambda; // parameter: Lambda parameter for EMA used in mark-price for funding rates
        int128 fSigma2; // parameter: volatility of base-quote pair
        int128 fSigma3; // parameter: volatility of quanto-quote pair
        int128 fRho23; // parameter: correlation of quanto/base returns
        AMMPerpLogic.CollateralCurrency eCollateralCurrency; //parameter: in what currency is the collateral held?
        // risk parameters for default fund / AMM fund
        int128[2] fStressReturnS2; // parameter: negative and positive stress returns for base-quote asset
        int128[2] fStressReturnS3; // parameter: negative and positive stress returns for quanto-quote asset
        int128 fDFCoverNRate; // parameter: cover-n rule for default fund. E.g., fDFCoverNRate=0.05 -> we try to cover 5% of active accounts with default fund
        int128[2] fDFLambda; // parameter: EMA lambda for AMM and trader exposure K,k: EMA*lambda + (1-lambda)*K. 0 regular lambda, 1 if current value exceeds past
        int128[2] fAMMTargetDD; // parameter: target distance to default (=inverse of default probability), [0] baseline [1] stress
        int128 fAMMMinSizeCC; // parameter: minimal size of AMM pool, regardless of current exposure
        int128 fMinimalTraderExposureEMA; // parameter: minimal value for fCurrentTraderExposureEMA that we don't want to undershoot
        int128 fMinimalAMMExposureEMA; // parameter: minimal value for fCurrentTraderExposureEMA that we don't want to undershoot
        int128 fMaximalTradeSizeBumpUp; // parameter: >1, users can create a maximal position of size fMaximalTradeSizeBumpUp*fCurrentAMMExposureEMA
        //  this is to avoid overly large trades that would put the AMM at risk

        // state: default fund sizing
        int128 fTargetAMMFundSize; //target AMM fund size
        bool isBaselineAMMFundState; // whether to rebalance towards fAMMTargetDD[0] or fAMMTargetDD[1]
        int128 fTargetDFSize; // target default fund size
        int128[2] fCurrentAMMExposureEMA; // 0: negative aggregated exposure (storing negative value), 1: positive
        int128 fCurrentTraderExposureEMA; // trade amounts (storing absolute value)
        // users
        int128 fTotalMarginBalance; //calculated for settlement, in collateral currency
        int128 fMaxPositionBC; // max position in base currency (e.g., 1 BTC for BTCUSD);
    }

    // users
    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) internal activeAccounts; //perpetualId => traderAddressSet
    // accounts
    mapping(bytes32 => mapping(address => MarginAccount)) internal marginAccounts;

    struct Checkpoint {
        uint128 timestamp;
        int128 amount; //amount of tokens returned
    }

    struct LiquidityPoolData {
        //index, starts from 1
        uint256 id;
        bool isRunning;
        //parameters
        address treasuryAddress; // parameter: address for the protocol treasury
        address marginTokenAddress; //parameter: address of the margin token
        address shareTokenAddress; //
        uint256 iTargetPoolSizeUpdateTime; //parameter: timestamp in seconds. How often would we want to update the target size of the pool?
        // liquidity state (held in collateral currency)
        int128 fPnLparticipantsCashCC; //addLiquidity/removeLiquidity + profit/loss - rebalance
        int128 fAMMFundCashCC; //profit/loss - rebalance (sum of cash in individual perpetuals)
        int128 fDefaultFundCashCC; //profit/loss
        uint256 iPriceUpdateTimeSec; // timestamp from block.timestamp
        int128 fTargetAMMFundSize; //target AMM pool size for all perpetuals in pool (sum)
        int128 fTargetDFSize; //target default fund size for all perpetuals in pool
        uint256 iLastTargetPoolSizeTime; //timestamp (seconds) since last update of fTargetDFSize and fTargetAMMFundSize
        uint256 iLastFundingTime; //timestamp since last funding rate payment
        // Liquidity provider restrictions
        //the withdrawal limitation period
        uint256 iPnLparticipantWithdrawalPeriod;
        //percentage of total fPnLparticipantsCashCC (e.g. 10%)
        int128 fPnLparticipantWithdrawalPercentageLimit;
        //minimum amount of tokens to be restricted for the withdrawal (e.g. 1000)
        int128 fPnLparticipantWithdrawalMinAmountLimit;
        int128 fRedemptionRate; // used for settlement in case of AMM default
        uint256 iPerpetualCount;
        int128 fMaxTotalTraderFunds; // total trader funds allowed across all perpetuals in this pool
    }

    //pool id => perpetual id list
    mapping(uint256 => bytes32[]) internal perpetualIds;

    //pool id => perpetual id => data
    mapping(uint256 => mapping(bytes32 => PerpetualData)) internal perpetuals;

    //pool id => user => array of checkpoint data
    mapping(uint256 => mapping(address => Checkpoint[])) internal checkpoints;

    address internal ammPerpLogic;

    /// @dev user => flag whether user has admin role.
    /// @dev recommended that multisig be an admin
    //mapping(address => bool) internal ammGovernanceAddresses;
    EnumerableSetUpgradeable.AddressSet internal ammGovernanceAddresses;

    /// @dev flag whether MarginTradeOrder was already executed
    mapping(bytes32 => bool) internal executedOrders;

    /// @dev flag whether MarginTradeOrder was canceled
    mapping(bytes32 => bool) internal canceledOrders;

    //current prices
    mapping(address => OraclePriceData) internal oraclePriceData;

    EnumerableSetUpgradeable.AddressSet internal whitelisted;

    bool internal whitelistActive;

    mapping(bytes32 => EnumerableBytes4Set.Bytes4Set) internal moduleActiveFuncSignatureList;
    mapping(bytes32 => address) internal moduleNameToAddress;
    mapping(address => bytes32) internal moduleAddressToModuleName;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2; // to pass structs in public function

import "../../libraries/ABDKMath64x64.sol";
import "../../perpetual/interfaces/IAMMPerpLogic.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../cdf/ICDFTable.sol";

contract AMMPerpLogic is Ownable, IAMMPerpLogic {
    using ABDKMath64x64 for int128;

    int128 public constant ONE_64x64 = 0x10000000000000000; // 2^64
    int128 public constant TWO_64x64 = 0x20000000000000000; // 2*2^64
    int128 public constant FOUR_64x64 = 0x40000000000000000; //4*2^64
    int128 public constant HALF_64x64 = 0x8000000000000000; //0.5*2^64
    int128 public constant TWENTY_64x64 = 0x140000000000000000; //20*2^64

    enum CollateralCurrency {
        QUOTE,
        BASE,
        QUANTO
    }

    struct AMMVariables {
        // all variables are
        // signed 64.64-bit fixed point number
        int128 fLockedValue1; // L1 in quote currency
        int128 fPoolM1; // M1 in quote currency
        int128 fPoolM2; // M2 in base currency
        int128 fPoolM3; // M3 in quanto currency
        int128 fAMM_K2; // AMM exposure (positive if trader long)
    }

    struct MarketVariables {
        int128 fIndexPriceS2; // base index
        int128 fIndexPriceS3; // quanto index
        int128 fSigma2; // standard dev of base currency
        int128 fSigma3; // standard dev of quanto currency
        int128 fRho23; // correlation base/quanto currency
    }

    ICDFTable public CDFTable;

    function setCDFTable(address _CDFTable) external onlyOwner {
        require(_CDFTable != address(0), "invalid address");
        CDFTable = ICDFTable(_CDFTable);
    }

    /**
     * Calculate Exponentially Weighted Moving Average.
     * Returns updated EMA based on
     * _fEMA = _fLambda * _fEMA + (1-_fLambda)* _fCurrentObs
     * @param _fEMA signed 64.64-bit fixed point number
     * @param _fCurrentObs signed 64.64-bit fixed point number
     * @param _fLambda signed 64.64-bit fixed point number
     * @return updated EMA, signed 64.64-bit fixed point number
     */
    function ema(
        int128 _fEMA,
        int128 _fCurrentObs,
        int128 _fLambda
    ) external pure virtual override returns (int128) {
        require(_fLambda > 0, "EMA Lambda must be greater than 0");
        require(_fLambda < ONE_64x64, "EMA Lambda must be smaller than 1");
        // result must be between the two values _fCurrentObs and _fEMA, so no overflow
        int128 fEWMANew = ABDKMath64x64.add(_fEMA.mul(_fLambda), ABDKMath64x64.mul(ONE_64x64.sub(_fLambda), _fCurrentObs));
        return fEWMANew;
    }

    /**
     *  Calculate the normal CDF value of _fX, i.e.,
     *  k=P(X<=_fX), for X~normal(0,1)
     *  @dev replace with proper CDF table
     *  @param _fX signed 64.64-bit fixed point number
     *  @return response approximated normal-cdf evaluated at X
     */
    function _normalCDF(int128 _fX) internal view returns (int128 response) {
        bool isPositive = false;
        if (_fX > 0) {
            _fX = _fX.neg();
            isPositive = true;
        }
        response = CDFTable.getValue(_fX);
        if (isPositive) {
            response = ONE_64x64.sub(response);
        }
        return response;
    }

    /**
     *  Calculate the target size for the default fund
     *
     *  @param _fK2AMM       signed 64.64-bit fixed point number, Conservative negative[0]/positive[1] AMM exposure
     *  @param _fk2Trader    signed 64.64-bit fixed point number, Conservative (absolute) trader exposure
     *  @param _fCoverN      signed 64.64-bit fixed point number, cover-n rule for default fund parameter
     *  @param fStressRet2   signed 64.64-bit fixed point number, negative[0]/positive[1] stress returns for base/quote pair
     *  @param fStressRet3   signed 64.64-bit fixed point number, negative[0]/positive[1] stress returns for quanto/quote currency
     *  @param fIndexPrices  signed 64.64-bit fixed point number, spot price for base/quote[0] and quanto/quote[1] pairs
     *  @param _eCCY         enum that specifies in which currency the collateral is held: QUOTE, BASE, QUANTO
     *  @return approximated normal-cdf evaluated at X
     */
    function calculateDefaultFundSize(
        int128[2] memory _fK2AMM,
        int128 _fk2Trader,
        int128 _fCoverN,
        int128[2] calldata fStressRet2,
        int128[2] calldata fStressRet3,
        int128[2] calldata fIndexPrices,
        AMMPerpLogic.CollateralCurrency _eCCY
    ) external pure override returns (int128) {
        require(_fK2AMM[0] < 0, "First element of _fK2AMM required to be negative");
        require(_fK2AMM[1] > 0, "Second element of _fK2AMM required to be positive");
        require(_fk2Trader > 0, "_fk2Trader required to be positive");

        int128[2] memory fEll;
        _fK2AMM[0] = _fK2AMM[0].abs();
        _fK2AMM[1] = _fK2AMM[1].abs();
        // downward stress scenario
        fEll[0] = (_fK2AMM[0].add(_fk2Trader.mul(_fCoverN))).mul(ONE_64x64.sub(fStressRet2[0].exp()));
        // upward stress scenario
        fEll[1] = (_fK2AMM[1].add(_fk2Trader.mul(_fCoverN))).mul(fStressRet2[1].exp().sub(ONE_64x64));
        int128 fIstar;
        if (_eCCY == AMMPerpLogic.CollateralCurrency.BASE) {
            fIstar = fEll[0].div(fStressRet2[0].exp());
            int128 fI2 = fEll[1].div(fStressRet2[1].exp());
            if (fI2 > fIstar) {
                fIstar = fI2;
            }
        } else if (_eCCY == AMMPerpLogic.CollateralCurrency.QUANTO) {
            fIstar = fEll[0].div(fStressRet3[0].exp());
            int128 fI2 = fEll[1].div(fStressRet3[1].exp());
            if (fI2 > fIstar) {
                fIstar = fI2;
            }
            fIstar = fIstar.mul(fIndexPrices[0].div(fIndexPrices[1]));
        } else {
            assert(_eCCY == AMMPerpLogic.CollateralCurrency.QUOTE);
            if (fEll[0] > fEll[1]) {
                fIstar = fEll[0].mul(fIndexPrices[0]);
            } else {
                fIstar = fEll[1].mul(fIndexPrices[0]);
            }
        }
        return fIstar;
    }

    /**
     *  Calculate the risk neutral Distance to Default (Phi(DD)=default probability) when
     *  there is no quanto currency collateral.
     *  We assume r=0 everywhere.
     *  The underlying distribution is log-normal, hence the log below.
     *  All variables are 64.64-bit fixed point number (or struct thereof)
     *  @param _mktVars current Market variables (price&params)
     *  @param _fSign signed 64.64-bit fixed point number, sign of denominator of distance to default
     *  @return _fThresh signed 64.64-bit fixed point number, number for which the log is the unnormalized distance to default
     */
    function _calculateRiskNeutralDDNoQuanto(
        MarketVariables memory _mktVars,
        int128 _fSign,
        int128 _fThresh
    ) internal pure returns (int128) {
        require(_fThresh > 0, "argument to log must be >0");
        require(_mktVars.fSigma2 > 0, "volatility Sigma2 must be positive");
        int128 _fLogTresh = _fThresh.ln();
        int128 fSigma2_2 = _mktVars.fSigma2.mul(_mktVars.fSigma2);
        int128 fMean = fSigma2_2.div(TWO_64x64).neg();
        int128 fDistanceToDefault = ABDKMath64x64.sub(_fLogTresh, fMean).div(_mktVars.fSigma2);
        // because 1-Phi(x) = Phi(-x) we change the sign if _fSign<0
        // now we would like to get the normal cdf of that beast
        if (_fSign < 0) {
            fDistanceToDefault = fDistanceToDefault.neg();
        }
        return fDistanceToDefault;
    }

    /**
     *  Calculate the standard deviation for the random variable
     *  evolving when quanto currencies are involved.
     *  We assume r=0 everywhere.
     *  All variables are 64.64-bit fixed point number (or struct thereof)
     *  @param _mktVars current Market variables (price&params)
     *  @param _fC3 signed 64.64-bit fixed point number current AMM/Market variables
     *  @param _fC3_2 signed 64.64-bit fixed point number, squared fC3
     *  @return standard deviation, 64.64-bit fixed point number
     */
    function _calculateStandardDeviationQuanto(
        MarketVariables memory _mktVars,
        int128 _fC3,
        int128 _fC3_2
    ) internal pure returns (int128) {
        int128 fSigmaZ;
        int128 fSigma2_2 = _mktVars.fSigma2.mul(_mktVars.fSigma2);
        int128 fSigma3_2 = _mktVars.fSigma3.mul(_mktVars.fSigma3);
        // fVarA = (exp(sigma2^2) - 1)
        int128 fVarA = ABDKMath64x64.sub(fSigma2_2.exp(), ONE_64x64);
        // fVarB1 = exp(sigma2*sigma3*rho)
        int128 fVarB1 = (_mktVars.fSigma2.mul(_mktVars.fSigma3).mul(_mktVars.fRho23)).exp();
        // fVarB = 2*(exp(sigma2*sigma3*rho) - 1)
        int128 fVarB = ABDKMath64x64.sub(fVarB1, ONE_64x64).mul(TWO_64x64);
        // fVarC = exp(sigma3^2) - 1
        int128 fVarC = ABDKMath64x64.sub(fSigma3_2.exp(), ONE_64x64);
        // sigmaZ = fVarA*C^2 + fVarB*C + fVarC
        int128 fSigmaZ_2 = ABDKMath64x64.add(fVarA.mul(_fC3_2), fVarB.mul(_fC3)).add(fVarC);
        fSigmaZ = fSigmaZ_2.sqrt();
        return fSigmaZ;
    }

    /**
     *  Calculate the risk neutral Distance to Default (Phi(DD)=default probability) when
     *  presence of quanto currency collateral.
     *
     *  We approximate the distribution with a normal distribution
     *  We assume r=0 everywhere.
     *  All variables are 64.64-bit fixed point number
     *  @param _ammVars current AMM/Market variables
     *  @param _mktVars current Market variables (price&params)
     *  @param _fSign 64.64-bit fixed point number, current AMM/Market variables
     *  @return _fLambdasigned 64.64-bit fixed point number
     */
    function _calculateRiskNeutralDDWithQuanto(
        AMMVariables memory _ammVars,
        MarketVariables memory _mktVars,
        int128 _fSign,
        int128 _fThresh
    ) internal pure returns (int128) {
        require(_fSign > 0, "no sign distinction in quanto case");
        // 1) Calculate C3
        int128 fC3 = _mktVars.fIndexPriceS2.mul(_ammVars.fPoolM2.sub(_ammVars.fAMM_K2)).div(_ammVars.fPoolM3.mul(_mktVars.fIndexPriceS3));
        int128 fC3_2 = fC3.mul(fC3);

        // 2) Calculate Variance
        int128 fSigmaZ = _calculateStandardDeviationQuanto(_mktVars, fC3, fC3_2);

        // 3) Calculate mean
        int128 fMean = ABDKMath64x64.add(fC3, ONE_64x64);
        // 4) Distance to default
        int128 fDistanceToDefault = ABDKMath64x64.sub(_fThresh, fMean).div(fSigmaZ);
        return fDistanceToDefault;
    }

    /**
     *  Calculate the risk neutral default probability (>=0).
     *  Function decides whether pricing with or without quanto CCY is chosen.
     *  We assume r=0 everywhere.
     *  All variables are 64.64-bit fixed point number (or struct thereof)
     *  @param _ammVars         current AMM variables.
     *  @param _mktVars         current Market variables (price&params)
     *  @param _fTradeAmount    Trade amount (can be 0), hence amounts k2 are not already factored in
     *                          that is, function will set K2:=K2+k2, L1:=L1+k2*s2 (k2=_fTradeAmount)
     *  @param _withCDF         bool. If false, the normal-cdf is not evaluated (in case the caller is only
     *                          interested in the distance-to-default, this saves calculations)
     *  @return (default probabilit, distance to default) ; 64.64-bit fixed point numbers
     */
    function calculateRiskNeutralPD(
        AMMVariables memory _ammVars,
        MarketVariables calldata _mktVars,
        int128 _fTradeAmount,
        bool _withCDF
    ) external view virtual override returns (int128, int128) {
        int128 dL = _fTradeAmount.mul(_mktVars.fIndexPriceS2);
        int128 dK = _fTradeAmount;
        _ammVars.fLockedValue1 = _ammVars.fLockedValue1.add(dL);
        _ammVars.fAMM_K2 = _ammVars.fAMM_K2.add(dK);
        // -L1 - k*s2 - M1
        int128 fNumerator = (_ammVars.fLockedValue1.neg()).sub(_ammVars.fPoolM1);
        // s2*(M2-k2-K2) if no quanto, else M3 * s3 
        int128 fDenominator = _ammVars.fPoolM3 == 0
            ? (_ammVars.fPoolM2.sub(_ammVars.fAMM_K2)).mul(_mktVars.fIndexPriceS2)
            : _ammVars.fPoolM3.mul(_mktVars.fIndexPriceS3);

        // handle cases when denominator close to zero
        // or when we have opposite signs (to avoid ln(-|value|))
        // when M3 > 0, denominator is always > 0
        int128 fThresh = fDenominator == 0 ? int128(0) : fNumerator.div(fDenominator);
        if (fThresh <= 0 && _ammVars.fPoolM3 == 0) {
            if (fNumerator <= 0) {
                // undo changing the struct
                _ammVars.fLockedValue1 = _ammVars.fLockedValue1.sub(dL);
                _ammVars.fAMM_K2 = _ammVars.fAMM_K2.sub(dK);
                return (int128(0), TWENTY_64x64.neg());
            } else {
                // undo changing the struct
                _ammVars.fLockedValue1 = _ammVars.fLockedValue1.sub(dL);
                _ammVars.fAMM_K2 = _ammVars.fAMM_K2.sub(dK);
                return (int128(ONE_64x64), TWENTY_64x64);
            }
        }
        // sign tells us whether we consider norm.cdf(f(threshold)) or 1-norm.cdf(f(threshold))
        int128 fSign = fDenominator < 0 ? ONE_64x64.neg() : ONE_64x64;
        int128 dd = _ammVars.fPoolM3 == 0
            ? _calculateRiskNeutralDDNoQuanto(_mktVars, fSign, fThresh)
            : _calculateRiskNeutralDDWithQuanto(_ammVars, _mktVars, fSign, fThresh);

        int128 q;
        if (_withCDF) {
            q = _normalCDF(dd);
        }
        // undo changing the struct
        _ammVars.fLockedValue1 = _ammVars.fLockedValue1.sub(dL);
        _ammVars.fAMM_K2 = _ammVars.fAMM_K2.sub(dK);
        return (q, dd);
    }

    /**
     *  Calculate AMM price.
     *
     *  All variables are 64.64-bit fixed point number (or struct thereof)
     *  @param _ammVars current AMM variables.
     *  @param _mktVars current Market variables (price&params)
     *                 Trader amounts k2 must already be factored in
     *                 that is, K2:=K2+k2, L1:=L1+k2*s2
     *  @param _fTradeAmount 64.64-bit fixed point number, signed size of trade
     *  @param _fMinimalSpread minimal spread, 64.64-bit fixed point number
     *  @return 64.64-bit fixed point number, AMM price
     */
    function calculatePerpetualPrice(
        AMMVariables calldata _ammVars,
        MarketVariables calldata _mktVars,
        int128 _fTradeAmount,
        int128 _fMinimalSpread
    ) external view virtual override returns (int128) {
        // get risk-neutral default probability (always >0)
        int128 fQ;
        int128 dd;
        bool isPositive;
        int128 fkStar = _ammVars.fPoolM2.sub(_ammVars.fAMM_K2);
        (fQ, dd) = this.calculateRiskNeutralPD(_ammVars, _mktVars, _fTradeAmount, true);
        if (_ammVars.fPoolM3 != 0) {
            // amend K* (see whitepaper)
            int128 nominator = _mktVars.fRho23.mul(_mktVars.fSigma2);
            nominator = nominator.mul(_mktVars.fSigma3).exp().sub(ONE_64x64);
            int128 denom = (_mktVars.fSigma2).mul(_mktVars.fSigma2).exp().sub(ONE_64x64);
            int128 h = nominator.div(denom).mul(_ammVars.fPoolM3);
            h = h.mul(_mktVars.fIndexPriceS3).div(_mktVars.fIndexPriceS2);
            fkStar = fkStar.add(h);
        }
        isPositive = _fTradeAmount >= fkStar;
        // add minimal spread in quote currency
        _fMinimalSpread = _fTradeAmount > 0 ? _fMinimalSpread : _fMinimalSpread.neg();
        if (_fTradeAmount == 0) {
            _fMinimalSpread = 0;
        }
        // decide on sign of premium
        if (!isPositive) {
            fQ = fQ.neg();
        }
        // s2*(1 + sign(qp-q)*q + sign(k)*minSpread)
        return _mktVars.fIndexPriceS2.mul(ONE_64x64.add(fQ).add(_fMinimalSpread));
    }

    /**
     *  Calculate target collateral M1 (Quote Currency), when no M2, M3 is present
     *  The targeted default probability is expressed using the inverse
     *  _fTargetDD = Phi^(-1)(targetPD)
     *  _fK2 in absolute terms must be 'reasonably large'
     *  sigma3, rho23, IndexpriceS3 not relevant.
     *  @param _fK2 signed 64.64-bit fixed point number, !=0, EWMA of actual K.
     *  @param _fL1 signed 64.64-bit fixed point number, >0, EWMA of actual L.
     *  @param  _mktVars contains 64.64 values for fIndexPriceS2*, fIndexPriceS3, fSigma2*, fSigma3, fRho23
     *  @param _fTargetDD signed 64.64-bit fixed point number
     *  @return M1Star signed 64.64-bit fixed point number, >0
     */
    function getTargetCollateralM1(
        int128 _fK2,
        int128 _fL1,
        MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure virtual override returns (int128) {
        assert(_fK2 != 0);
        assert(_mktVars.fSigma3 == 0);
        assert(_mktVars.fIndexPriceS3 == 0);
        assert(_mktVars.fRho23 == 0);
        int128 fMu2 = HALF_64x64.neg().mul(_mktVars.fSigma2).mul(_mktVars.fSigma2);
        int128 ddScaled = _fK2 < 0 ? _mktVars.fSigma2.mul(_fTargetDD) : _mktVars.fSigma2.mul(_fTargetDD).neg();
        int128 A1 = ABDKMath64x64.exp(fMu2.add(ddScaled));
        return _fK2.mul(_mktVars.fIndexPriceS2).mul(A1).sub(_fL1);
    }

    /**
     *  Calculate target collateral *M2* (Base Currency), when no M1, M3 is present
     *  The targeted default probability is expressed using the inverse
     *  _fTargetDD = Phi^(-1)(targetPD)
     *  _fK2 in absolute terms must be 'reasonably large'
     *  sigma3, rho23, IndexpriceS3 not relevant.
     *  @param _fK2 signed 64.64-bit fixed point number, EWMA of actual K.
     *  @param _fL1 signed 64.64-bit fixed point number, EWMA of actual L.
     *  @param _mktVars contains 64.64 values for fIndexPriceS2, fIndexPriceS3, fSigma2, fSigma3, fRho23
     *  @param _fTargetDD signed 64.64-bit fixed point number
     *  @return M2Star signed 64.64-bit fixed point number
     */
    function getTargetCollateralM2(
        int128 _fK2,
        int128 _fL1,
        MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure virtual override returns (int128) {
        assert(_fK2 != 0);
        assert(_mktVars.fSigma3 == 0);
        assert(_mktVars.fIndexPriceS3 == 0);
        assert(_mktVars.fRho23 == 0);
        int128 fMu2 = HALF_64x64.mul(_mktVars.fSigma2).mul(_mktVars.fSigma2).neg();
        int128 ddScaled = _fL1 < 0 ? _mktVars.fSigma2.mul(_fTargetDD) : _mktVars.fSigma2.mul(_fTargetDD).neg();
        int128 A1 = ABDKMath64x64.exp(fMu2.add(ddScaled)).mul(_mktVars.fIndexPriceS2);
        return _fK2.sub(_fL1.div(A1));
    }

    /**
     *  Calculate target collateral M3 (Quanto Currency), when no M1, M2 not present
     *
     *  @param _fK2 signed 64.64-bit fixed point number. EWMA of actual K.
     *  @param _fL1 signed 64.64-bit fixed point number.  EWMA of actual L.
     *  @param  _mktVars contains 64.64 values for
     *           fIndexPriceS2, fIndexPriceS3, fSigma2, fSigma3, fRho23 - all required
     *  @param _fTargetDD signed 64.64-bit fixed point number
     *  @return M2Star signed 64.64-bit fixed point number
     */
    function getTargetCollateralM3(
        int128 _fK2,
        int128 _fL1,
        MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure override returns (int128) {
        assert(_fK2 != 0);
        assert(_mktVars.fSigma3 != 0);
        assert(_mktVars.fIndexPriceS3 != 0);
        assert(_mktVars.fRho23 != 0);
        int128 fDDSquared = _fTargetDD.mul(_fTargetDD);
        // quadratic equation A x^2 + Bx + C = 0

        int128 fTwoA;
        {
            int128 fV = _mktVars.fIndexPriceS3.div(_mktVars.fIndexPriceS2).div(_fK2).neg();
            // A = ((exp(sig3^2)-1) * DD^2 - 1)*fV
            fTwoA = _mktVars.fSigma3.mul(_mktVars.fSigma3).exp().sub(ONE_64x64);
            fTwoA = fTwoA.mul(fDDSquared).sub(ONE_64x64);
            fTwoA = fTwoA.mul(fV).mul(fV).mul(TWO_64x64);
        }

        int128 fB;
        {
            // b = 2( exp(sig2*sig3*rho) -1 )
            int128 fb = ABDKMath64x64.sub(_mktVars.fSigma2.mul(_mktVars.fSigma3).mul(_mktVars.fRho23).exp(), ONE_64x64).mul(TWO_64x64);
            // B = (b*DD^2- 2 + 2  Kappa ) * v
            int128 fKappa = _fL1.div(_mktVars.fIndexPriceS2).div(_fK2);
            fB = ABDKMath64x64.add(fb.mul(fDDSquared).sub(TWO_64x64), fKappa.mul(TWO_64x64));
            int128 fV = _mktVars.fIndexPriceS3.div(_mktVars.fIndexPriceS2).div(_fK2).neg();
            fB = fB.mul(fV);
        }

        int128 fC;
        {
            // c = exp(sig2^2)-1
            int128 fc = _mktVars.fSigma2.mul(_mktVars.fSigma2).exp().sub(ONE_64x64);
            // C = c*DD^2 - kappa^2 + 2 kappa - 1
            int128 fKappa = _fL1.div(_mktVars.fIndexPriceS2).div(_fK2);
            fC = ABDKMath64x64.add(fc.mul(fDDSquared).sub(fKappa.mul(fKappa)), fKappa.mul(TWO_64x64)).sub(ONE_64x64);
        }

        // two solutions
        int128 delta = ABDKMath64x64.sqrt(fB.mul(fB).sub(TWO_64x64.mul(fTwoA).mul(fC)));
        int128 fMStar = ABDKMath64x64.add(fB.neg(), delta).div(fTwoA);
        {
            int128 fM2 = ABDKMath64x64.sub(fB.neg(), delta).div(fTwoA);
            if (fM2 > fMStar) {
                fMStar = fM2;
            }
        }
        return fMStar;
    }

    /**
     *  Calculate the required deposit for a new position
     *  of size _fPosition+_fTradeAmount and leverage _fTargetLeverage, 
     *  having an existing position with balance fBalance0 and size _fPosition.
     *  This is the amount to be added to the margin collateral and can be negative (hence remove).
     *  Fees not factored-in.
     *  @param _fPosition0   signed 64.64-bit fixed point number. Position in base currency
     *  @param _fBalance0   signed 64.64-bit fixed point number. Current balance.
     *  @param _fTradeAmount signed 64.64-bit fixed point number. Trade amt in base currency
     *  @param _fTargetLeverage signed 64.64-bit fixed point number. Desired leverage
     *  @param _fPrice signed 64.64-bit fixed point number. Price for the trade of size _fTradeAmount
     *  @param _fS2Mark signed 64.64-bit fixed point number. Mark-price
     *  @param _fS3 signed 64.64-bit fixed point number. Collateral 2 quote conversion
     *  @return signed 64.64-bit fixed point number. Required cash_cc
     */
    function getDepositAmountForLvgPosition(
        int128 _fPosition0,
        int128 _fBalance0,
        int128 _fTradeAmount,
        int128 _fTargetLeverage,
        int128 _fPrice,
        int128 _fS2Mark,
        int128 _fS3
    ) external pure override returns (int128) {
        int128 fPnL = _fTradeAmount.mul(_fS2Mark.sub(_fPrice));
        fPnL = fPnL.div(_fS3);
        int128 fLvgFrac = _fPosition0.add(_fTradeAmount).abs().mul(_fS2Mark);
        fLvgFrac = fLvgFrac.div(_fS3).div(_fTargetLeverage);
        return _fBalance0.add(fPnL).sub(fLvgFrac).neg();
    }

    function getTradeFees(
        int128 _fDeltaPosCC,
        int128 _fTreasuryFeeRate,
        int128 _fPnLPartRate,
        int128 _fReferralRebate,
        address _referrerAddr
    ) external pure returns (int128, int128, int128) {
        int128 fDeltaPos = _fDeltaPosCC.abs();
        int128 fTreasuryFee = fDeltaPos.mul(_fTreasuryFeeRate);
        int128 fPnLparticipantFee = fDeltaPos.mul(_fPnLPartRate);
        int128 fReferralRebate = _referrerAddr != address(0) ? _fReferralRebate : int128(0);
        return (fTreasuryFee, fPnLparticipantFee, fReferralRebate);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IPerpetualOrder.sol";

contract PerpetualHashFunctions {
    string private constant NAME = "Perpetual Trade Manager";

    //The EIP-712 typehash for the contract's domain.
    bytes32 private constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    //The EIP-712 typehash for the Order struct used by the contract.
    bytes32 private constant TRADE_ORDER_TYPEHASH =
        keccak256(
            "Order(bytes32 iPerpetualId,address traderAddr,int128 fAmount,int128 fLimitPrice,int128 fTriggerPrice,uint256 iDeadline,uint32 flags,int128 fLeverage,uint256 createdTimestamp)"
        );

    /**
     * @notice Creates the hash for an order
     * @param _order the address of perpetual proxy manager.
     * @param _contract The id of perpetual.
     * @param _createOrder true if order is to be executed, false for cancel-order digest
     * @return hash of order and _createOrder-flag
     * */
    function _getDigest(
        IPerpetualOrder.Order memory _order,
        address _contract,
        bool _createOrder
    ) internal view returns (bytes32) {
        /*
         * The DOMAIN_SEPARATOR is a hash that uniquely identifies a
         * smart contract. It is built from a string denoting it as an
         * EIP712 Domain, the name of the token contract, the version,
         * the chainId in case it changes, and the address that the
         * contract is deployed at.
         */
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(NAME)), _getChainId(), _contract));

        // ORDER_TYPEHASH
        bytes32 structHash = _getStructHash(_order);

        bytes32 digest = keccak256(abi.encode(domainSeparator, structHash, _createOrder));

        digest = ECDSA.toEthSignedMessageHash(digest);
        return digest;
    }

    function _getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    /**
     * @notice Creates the hash of the order-struct
     * @dev order.referrerAddr is not hashed, 
     * because it is to be set by the referrer
     * @param _order : order struct
     * @return bytes32 hash of order
     * */
    function _getStructHash(IPerpetualOrder.Order memory _order) internal pure returns (bytes32) { 
        bytes32 structHash = keccak256(
            abi.encode(
                TRADE_ORDER_TYPEHASH,
                _order.iPerpetualId,
                _order.traderAddr,
                _order.fAmount,
                _order.fLimitPrice,
                _order.fTriggerPrice,
                _order.iDeadline,
                _order.flags,
                _order.fLeverage,
                _order.createdTimestamp
            )
        );
        return structHash;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../functions/AMMPerpLogic.sol";
pragma experimental ABIEncoderV2;

interface IAMMPerpLogic {
    function ema(
        int128 _fEMA,
        int128 _fCurrentObs,
        int128 _fLambda
    ) external pure returns (int128);

    function calculateDefaultFundSize(
        int128[2] memory _fK2AMM,
        int128 _fk2Trader,
        int128 _fCoverN,
        int128[2] calldata fStressRet2,
        int128[2] calldata fStressRet3,
        int128[2] calldata fIndexPrices,
        AMMPerpLogic.CollateralCurrency _eCCY
    ) external pure returns (int128);

    function calculateRiskNeutralPD(
        AMMPerpLogic.AMMVariables memory _ammVars,
        AMMPerpLogic.MarketVariables calldata _mktVars,
        int128 _fTradeAmount,
        bool _withCDF
    ) external view returns (int128, int128);

    function calculatePerpetualPrice(
        AMMPerpLogic.AMMVariables calldata _ammVars,
        AMMPerpLogic.MarketVariables calldata _mktVars,
        int128 _fTradeAmount,
        int128 _fMinimalSpread
    ) external view returns (int128);

    function getTargetCollateralM1(
        int128 _fK2,
        int128 _fL1,
        AMMPerpLogic.MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure returns (int128);

    function getTargetCollateralM2(
        int128 _fK2,
        int128 _fL1,
        AMMPerpLogic.MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure returns (int128);

    function getTargetCollateralM3(
        int128 _fK2,
        int128 _fL1,
        AMMPerpLogic.MarketVariables calldata _mktVars,
        int128 _fTargetDD
    ) external pure returns (int128);

    function getDepositAmountForLvgPosition(
        int128 _fPosition0,
        int128 _fBalance0,
        int128 _fTradeAmount,
        int128 _fTargetLeverage,
        int128 _fPrice,
        int128 _fS2Mark,
        int128 _fS3
    ) external pure returns (int128);

    function getTradeFees(
        int128 _fDeltaPos,
        int128 _fTreasuryFeeRate,
        int128 _fPnLPartRate,
        int128 _fReferralRebate,
        address _referrerAddr
    ) external pure returns (int128, int128, int128);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualDepositManager {
    function deposit(bytes32 _iPerpetualId, int128 _fAmount) external;

    function depositToDefaultFund(uint256 _poolId, int128 _fAmount) external;

    function withdrawFromDefaultFund(
        uint256 _poolId,
        address _receiver,
        int128 _fAmount
    ) external;

    function transferEarningsToTreasury(uint256 _poolId, int128 _fAmount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualFactory {
    function createPerpetual(
        uint256 _iPoolId,
        address[2] calldata _oracles,
        int128[11] calldata _baseParams,
        int128[5] calldata _underlyingRiskParams,
        int128[13] calldata _defaultFundRiskParams,
        uint256 _eCollateralCurrency
    ) external;

    function activatePerpetual(bytes32 _perpetualId) external;

    function setEmergencyState(bytes32 _iPerpetualId) external;

    function setPerpetualOracles(bytes32 _iPerpetualId, address[2] calldata _oracles) external;

    function setPerpetualBaseParams(bytes32 _iPerpetualId, int128[11] calldata _baseParams) external;

    function setPerpetualRiskParams(
        bytes32 _iPerpetualId,
        int128[5] calldata _underlyingRiskParams,
        int128[13] calldata _defaultFundRiskParams
    ) external;

    function setPerpetualParam(
        bytes32 _iPerpetualId,
        string memory _varName,
        int128 _value
    ) external;

    function setPerpetualParamPair(
        bytes32 _iPerpetualId,
        string memory _name,
        int128 _value1,
        int128 _value2
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "../core/PerpStorage.sol";
import "../../interface/IShareTokenFactory.sol";

interface IPerpetualGetter {
    function getPoolCount() external view returns (uint256);

    function getPerpetualId(uint256 _poolId, uint256 _perpetualIndex) external view returns (bytes32);

    function getLiquidityPool(uint256 _id) external view returns (PerpStorage.LiquidityPoolData memory);

    function getPoolIdByPerpetualId(bytes32 _perpetualId) external view returns (uint256);

    function getPerpetual(bytes32 _perpetualId) external view returns (PerpStorage.PerpetualData memory);

    function getMarginAccount(bytes32 _perpetualId, address _account) external view returns (PerpStorage.MarginAccount memory);

    function isActiveAccount(bytes32 _perpetualId, address _account) external view returns (bool);

    function getCheckpoints(uint256 _poolId, address _account) external view returns (PerpStorage.Checkpoint[] memory);

    function getAMMPerpLogic() external view returns (address);

    function getGovernanceAddresses() external view returns (address[] memory);

    function isGovernanceAddress(address _address) external view returns (bool);

    function getShareTokenFactory() external view returns (IShareTokenFactory);

    function getPerpMarginAccount(bytes32 _perpId, address _trader) external view returns (PerpStorage.MarginAccount memory);

    function getActivePerpAccounts(bytes32 _perpId) external view returns (address[] memory perpActiveAccounts);

    function getPerpetualCountInPool(uint256 _poolId) external view returns (uint256);

    function getAMMState(bytes32 _iPerpetualId) external view returns (int128[13] memory);

    function getTraderState(bytes32 _iPerpetualId, address _traderAddr) external view returns (int128[7] memory);

    // function getActiveAccounts() external view returns (address[] memory allActiveAccounts);

    function getActivePerpAccountsByChunks(
        bytes32 _perpId,
        uint256 _from,
        uint256 _to
    ) external view returns (address[] memory chunkPerpActiveAccounts);

    function isTraderMaintenanceMarginSafe(bytes32 _iPerpetualId, address _traderAddr) external view returns (bool);

    function countActivePerpAccounts(bytes32 _perpId) external view returns (uint256);

    function getOraclePriceData(address _oracle) external view returns (PerpStorage.OraclePriceData memory);

    function getUpdatedTargetAMMFundSize(bytes32 _iPerpetualId, bool _isBaseline) external returns (int128);

    function isAddrWhitelisted(address _account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IPerpetualOrder.sol";
pragma experimental ABIEncoderV2;

interface IPerpetualLimitTradeManager is IPerpetualOrder {
    function tradeBySig(Order memory _order, bytes memory signature) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualLiquidator {
    function liquidateByAMM(
        bytes32 _perpetualIndex,
        address _liquidatorAddr,
        address _traderAddr
    ) external returns (int128 liquidatedAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "./IPerpetualFactory.sol";
import "./IPerpetualPoolFactory.sol";
import "./IPerpetualDepositManager.sol";
import "./IPerpetualWithdrawManager.sol";
import "./IPerpetualWithdrawAllManager.sol";
import "./IPerpetualLiquidator.sol";
import "./IPerpetualTreasury.sol";
import "./IPerpetualTradeManager.sol";
import "./IPerpetualSettlement.sol";
import "./IPerpetualGetter.sol";
import "./ISOVLibraryEvents.sol";
import "./IPerpetualTradeLogic.sol";
import "./IAMMPerpLogic.sol";
import "./IPerpetualTradeLimits.sol";
import "./IPerpetualUpdateLogic.sol";
import "./IPerpetualRelayRecipient.sol";
import "./IPerpetualRebalanceLogic.sol";
import "./IPerpetualMarginLogic.sol";
import "./IPerpetualLimitTradeManager.sol";
import "./IPerpetualOrderManager.sol";

interface IPerpetualManager is
    IPerpetualFactory,
    IPerpetualPoolFactory,
    IPerpetualDepositManager,
    IPerpetualWithdrawManager,
    IPerpetualWithdrawAllManager,
    IPerpetualLiquidator,
    IPerpetualTreasury,
    IPerpetualTradeLogic,
    IPerpetualTradeManager,
    IPerpetualLimitTradeManager,
    IPerpetualOrderManager,
    IPerpetualSettlement,
    IPerpetualGetter,
    IPerpetualTradeLimits,
    IAMMPerpLogic,
    ISOVLibraryEvents,
    IPerpetualUpdateLogic,
    IPerpetualRelayRecipient,
    IPerpetualRebalanceLogic,
    IPerpetualMarginLogic
{}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "./IPerpetualOrder.sol";

interface IPerpetualMarginLogic is IPerpetualOrder {
    function depositMarginForOpeningTrade(
        bytes32 _iPerpetualId,
        int128 _fDepositRequired,
        Order memory _order
    ) external returns (bool);

    function withdrawDepositFromMarginAccount(bytes32 _iPerpetualId, address _traderAddr) external;

    function reduceMarginCollateral(
        bytes32 _iPerpetualId,
        address _traderAddr,
        int128 _fAmountToWithdraw
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualOrder {
    //     iPerpetualId  global id for perpetual
    //     traderAddr    address of trader
    //     fAmount       amount in base currency to be traded
    //     fLimitPrice   limit price
    //     fTriggerPrice trigger price. Non-zero for stop orders.
    //     iDeadline     deadline for price (seconds timestamp)
    //     referrerAddr  address of abstract referrer
    //     flags         trade flags
    struct Order {
        bytes32 iPerpetualId;
        address traderAddr;
        int128 fAmount;
        int128 fLimitPrice;
        int128 fTriggerPrice;
        uint256 iDeadline;
        address referrerAddr;
        uint32 flags;
        int128 fLeverage; // 0 if deposit and trade separate
        uint256 createdTimestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IPerpetualOrder.sol";
pragma experimental ABIEncoderV2;

interface IPerpetualOrderManager is IPerpetualOrder {
    function cancelOrder(Order memory _order, bytes memory signature) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualPoolFactory {
    function setPerpetualPoolFactory(address _shareTokenFactory) external;

    function createLiquidityPool(
        address _treasuryAddress,
        address _marginTokenAddress,
        uint256 _iTargetPoolSizeUpdateTime,
        uint256 _iPnLparticipantWithdrawalPeriod,
        int128 _fPnLparticipantWithdrawalPercentageLimit,
        int128 _fPnLparticipantWithdrawalMinAmountLimit,
        int128 _fMaxTotalTraderFunds
    ) external returns (uint256);

    function runLiquidityPool(uint256 _liqPoolID) external;

    function setAMMPerpLogic(address _AMMPerpLogic) external;

    function setTreasury(uint256 _liqPoolID, address _treasury) external;

    function setTargetPoolSizeUpdateTime(uint256 _poolId, uint256 _iTargetPoolSizeUpdateTime) external;

    function setWithdrawalLimit(
        uint256 _poolId,
        uint256 _iPnLparticipantWithdrawalPeriod,
        int128 _fPnLparticipantWithdrawalPercentageLimit,
        int128 _fPnLparticipantWithdrawalMinAmountLimit
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualRebalanceLogic {
    function rebalance(bytes32 _iPerpetualId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualRelayRecipient {
    function trustedForwarder() external view returns (address);

    function setTrustedForwarder(address _forwarder) external;

    function isTrustedForwarder(address forwarder) external view returns (bool);

    function versionRecipient() external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualSettlement {
    function settleNextTraderInPool(uint256 _id) external returns (bool);

    function settle(bytes32 _perpetualID, address _traderAddr) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "../core/PerpStorage.sol";

interface IPerpetualTradeLimits {
    function setWhitelistActive(bool _flag) external;

    function isWhitelistActive() external view returns (bool);

    function addToWhitelist(address[] memory _accounts) external;

    function removeFromWhitelist(address[] memory _accounts) external;

    function getWhitelistedAddresses() external view returns (address[] memory);

    function isWhitelisted(address _account) external view returns (bool);

    function setMaxPosition(bytes32 _perpetualId, int128 _value) external;

    function getMaxPosition(bytes32 _perpetualId) external view returns (int128);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualTradeLogic {
    function executeTrade(
        bytes32 _iPerpetualId,
        address _traderAddr,
        int128 _fTraderPos,
        int128 _fTradeAmount,
        int128 _fPrice,
        bool _isClose
    ) external returns (int128);

    function preTrade(
        bytes32 _iPerpetualId,
        address _traderAddr,
        int128 _fAmount,
        int128 _fLimitPrice,
        uint32 _flags
    ) external returns (int128, int128);

    function distributeFees(
        bytes32 _iPerpetualId,
        address _traderAddr,
        address _referrerAddr,
        int128 _fDeltaPositionBC,
        bool _hasOpened
    ) external returns (int128);

    function validateStopPrice(
        bool _isLong,
        int128 _fMarkPrice,
        int128 _fTriggerPrice
    ) external pure;

    function getMaxSignedTradeSizeForPos(
        bytes32 _perpetualId,
        int128 _fCurrentTraderPos,
        int128 fTradeAmountBC
    ) external view returns (int128);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IPerpetualOrder.sol";
pragma experimental ABIEncoderV2;

interface IPerpetualTradeManager is IPerpetualOrder {
    function trade(Order memory _order) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualTreasury {
    function addLiquidity(uint256 _iPoolIndex, int128 _fTokenAmount) external;

    function addAMMLiquidityToPerpetual(bytes32 _iPerpetualId, int128 _fTokenAmount) external;

    function removeLiquidity(
        uint256 _iPoolIndex,
        int128 _fShareAmount) external;

    function addAmmGovernanceAddress(address _gAddress) external;

    function removeAmmGovernanceAddress(address _gAddress) external;

    function getTokenAmountToReturn(uint256 _poolId, int128 _fShareAmount) external view returns (int128);

    function getAmountForPeriod(uint256 _poolId, address _user) external view returns (int128);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualUpdateLogic {
    function updateAMMTargetFundSize(bytes32 _iPerpetualId, int128 fTargetFundSize) external;

    function updateDefaultFundTargetSize(uint256 _iPoolIndex) external;

    function updateFundingAndPricesBefore(uint256 _iPoolIdx) external;

    function updateFundingAndPricesAfter(uint256 _iPoolIdx) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualWithdrawAllManager {
    function withdrawAll(bytes32 _iPerpetualId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

interface IPerpetualWithdrawManager {
    function withdraw(bytes32 _iPerpetualId, int128 _fAmount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

/**
 * @notice  The libraryEvents defines events that will be raised from modules (contract/modules).
 * @dev     DO REMEMBER to add new events in modules here.
 */
interface ISOVLibraryEvents {
    // PerpetualModule
    event Clear(bytes32 indexed perpetualId, address indexed trader);
    event Settle(bytes32 indexed perpetualId, address indexed trader, int256 amount);
    event SetNormalState(bytes32 indexed perpetualId);
    event SetEmergencyState(
        bytes32 indexed perpetualId,
        int128 fSettlementMarkPremiumRate,
        int128 fSettlementS2Price,
        int128 fSettlementS3Price,
        uint256 iTimestamp
    );
    event SetClearedState(bytes32 indexed perpetualId);
    event UpdateUnitAccumulatedFunding(bytes32 perpetualId, int128 unitAccumulativeFunding);

    // Participation pool
    event LiquidityAdded(uint256 indexed poolId, address indexed user, uint256 tokenAmount, uint256 shareAmount);
    event LiquidityRemoved(uint256 indexed poolId, address indexed user, uint256 tokenAmount, uint256 shareAmount);

    // setters
    event SetOracles(bytes32 indexed perpetualId, address[2] oracles);
    event SetPerpetualBaseParameters(bytes32 indexed perpetualId, int128[11] baseParams);
    event SetPerpetualRiskParameters(bytes32 indexed perpetualId, int128[5] underlyingRiskParams, int128[13] defaultFundRiskParams);
    event TransferTreasuryTo(uint256 indexed poolId, address oldTreasury, address newTreasury);
    event SetParameter(bytes32 indexed perpetualId, string name, int128 value);
    event SetParameterPair(bytes32 indexed perpetualId, string name, int128 value1, int128 value2);

    event SetTargetPoolSizeUpdateTime(uint256 indexed poolId, uint256 targetPoolSizeUpdateTime);
    event SetWithdrawalLimit(
        uint256 indexed poolId,
        uint256 PnLparticipantWithdrawalPeriod,
        int128 PnLparticipantWithdrawalPercentageLimit,
        int128 PnLparticipantWithdrawalMinAmountLimit
    );

    // funds
    event UpdateAMMFundCash(bytes32 indexed perpetualId, int128 fNewAMMFundCash, int128 fNewLiqPoolTotalAMMFundsCash);
    event UpdateParticipationFundCash(uint256 indexed poolId, int128 fDeltaAmountCC, int128 fNewFundCash);
    event UpdateDefaultFundCash(uint256 indexed poolId, int128 fDeltaAmountCC, int128 fNewFundCash);

    // TradeModule
    event Trade(
        bytes32 indexed perpetualId,
        address indexed trader,
        bytes32 indexed positionId,
        bytes32 orderDigest,
        uint32 orderFlags,
        int128 tradeAmountBC,
        int128 newPositionSizeBC,
        int128 price,
        int128 limitPrice
    );

    event UpdateMarginAccount(
        bytes32 indexed perpetualId,
        address indexed trader,
        bytes32 indexed positionId,
        int128 fPositionBC,
        int128 fCashCC,
        int128 fLockedInValueQC,
        int128 fFundingPaymentCC,
        int128 fOpenInterestBC
    );

    event Liquidate(
        bytes32 perpetualId,
        address indexed liquidator,
        address indexed trader,
        bytes32 indexed positionId,
        int128 amountLiquidatedBC,
        int128 liquidationPrice,
        int128 newPositionSizeBC
    );
    event TransferFeeToReferrer(bytes32 indexed perpetualId, address indexed trader, address indexed referrer, int256 referralRebate);
    event RealizedPnL(bytes32 indexed perpetualId, address indexed trader, bytes32 indexed positionId, int128 pnlCC);
    event PerpetualLimitOrderCancelled(bytes32 indexed orderHash);
    event DistributeFees(uint256 indexed poolId, bytes32 indexed perpetualId, address indexed trader, int128 protocolFeeCC, int128 participationFundFeeCC);

    // PerpetualManager/factory
    event RunLiquidityPool(uint256 _liqPoolID);
    event LiquidityPoolCreated(
        uint256 id,
        address treasuryAddress,
        address marginTokenAddress,
        address shareTokenAddress,
        uint256 iTargetPoolSizeUpdateTime,
        uint256 iPnLparticipantWithdrawalPeriod,
        int128 fPnLparticipantWithdrawalPercentageLimit,
        int128 fPnLparticipantWithdrawalMinAmountLimit
    );
    event PerpetualCreated(
        uint256 poolId,
        bytes32 id,
        address[2] oracles,
        int128[11] baseParams,
        int128[5] underlyingRiskParams,
        int128[13] defaultFundRiskParams,
        uint256 eCollateralCurrency
    );

    event TokensDeposited(bytes32 indexed perpetualId, address indexed trader, int128 amount);
    event TokensWithdrawn(bytes32 indexed perpetualId, address indexed trader, int128 amount);

    event UpdatePrice(
        bytes32 indexed perpetualId,
        address indexed oracleS2Addr,
        address indexed oracleS3Addr,
        int128 spotPriceS2,
        uint256 timePriceS2,
        int128 spotPriceS3,
        uint256 timePriceS3
    );

    event UpdateMarkPrice(bytes32 indexed perpetualId, int128 fMarkPricePremium, int128 fSpotIndexPrice);

    event UpdateFundingRate(bytes32 indexed perpetualId, int128 fFundingRate);

    event UpdateAMMFundTargetSize(
        bytes32 indexed perpetualId,
        uint256 indexed liquidityPoolId,
        int128 fAMMFundCashCCInPerpetual,
        int128 fTargetAMMFundSizeInPerpetual,
        int128 fAMMFundCashCCInPool,
        int128 fTargetAMMFundSizeInPool
    );

    event UpdateDefaultFundTargetSize(uint256 indexed liquidityPoolId, int128 fDefaultFundCashCC, int128 fTargetDFSize);

    event UpdateReprTradeSizes(
        bytes32 indexed perpetualId,
        int128 fCurrentTraderExposureEMA,
        int128 fCurrentAMMExposureEMAShort,
        int128 fCurrentAMMExposureEMALong
    );

    event RemoveAmmGovernanceAddress(address indexed gAddress);
    event AddAmmGovernanceAddress(address indexed gAddress);
    event TransferEarningsToTreasury(uint256 _poolId, int128 fEarnings, int128 newDefaultFundSize);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IPerpetualManager.sol";
import "../interfaces/IPerpetualOrder.sol";
import "../../libraries/RSKAddrValidator.sol";
import "../../libraries/Bytes32Pagination.sol";
import "../functions/PerpetualHashFunctions.sol";

/**
 * @title Limit/Stop Order Book Proxy Contract.
 *
 * @notice A new perpetual limit order book contract.
 *
 * @dev We can have several order books as the product grows.
 * Hence, we create a new contract for each order book and
 * set the implementation to the same contract.
 * This saves deployment cost. We can upgrade the implementation and add
 * functions to the contract ONLY at the end. We cannot
 * add state variables as that will mess up the storage for exisitng
 * order books.
 * */
contract LimitOrderBook is IPerpetualOrder, Initializable, PerpetualHashFunctions {
    using Bytes32Pagination for bytes32[];
    uint256 private constant MAX_ORDERS_PER_TRADER = 15;
    // Events
    event PerpetualLimitOrderCreated(bytes32 indexed perpetualId, 
        address indexed trader,
        int128 tradeAmount,
        int128 limitPrice, 
        int128 triggerPrice, 
        uint256 deadline, 
        address referrerAddr, 
        uint32 flags, 
        int128 leverage,
        uint256 createdTimestamp,
        bytes32 digest);

    // Array of digests of all orders - irrespecitve of deletion
    bytes32[] public allDigests;

    // Address of trader => digests (orders)
    mapping(address => bytes32[]) public digestsOfTrader;

    // Digest of an order => the order and its data
    mapping(bytes32 => IPerpetualOrder.Order) public orderOfDigest;

    // OrderDigest => Signature
    mapping(bytes32 => bytes) public orderSignature;

    // Next order digest of a digest
    mapping(bytes32 => bytes32) public nextOrderHash;

    //Previous order digest of a digest
    mapping(bytes32 => bytes32) public prevOrderHash;

    // Stores last order digest
    bytes32 public lastOrderHash;

    // Order actual count - after addition/removal
    uint256 public orderCount;

    // Perpetual Manager
    IPerpetualManager public perpManager;

    // Stores perpetual id - specific to a perpetual
    bytes32 public perpetualId;

    /**
     * @notice Creates the Perpetual Limit Order Book.
     * @dev Replacement of constructor by initialize function for Upgradable Contracts
     * This function will be called only once while deploying order book using Factory.
     * @param _perpetualManagerAddr the address of perpetual proxy manager.
     * @param _perpetualId The id of perpetual.
     * */
    function initialize(address _perpetualManagerAddr, bytes32 _perpetualId) external initializer {
        require(_perpetualManagerAddr != address(0), "perpetual manager invalid");
        require(_perpetualId != bytes32(0), "perpetualId invalid");
        perpetualId = _perpetualId;
        perpManager = IPerpetualManager(_perpetualManagerAddr);
    }

    /**
     * @notice Creates Limit/Stop Order using order object with the following fields:
     * iPerpetualId  global id for perpetual
     * traderAddr    address of trader
     * fAmount       amount in base currency to be traded
     * fLimitPrice   limit price
     * fTriggerPrice trigger price, non-zero for stop orders
     * iDeadline     deadline for price (seconds timestamp)
     * referrerAddr  address of abstract referrer
     * flags         trade flags
     * @dev Replacement of constructor by initialize function for Upgradable Contracts
     * This function will be called only once while deploying order book using Factory.
     * @param _order the order details.
     * @param signature The traders signature.
     * */
    function createLimitOrder(Order memory _order, bytes memory signature) external {
        // Validations
        require(perpetualId == _order.iPerpetualId, "order should be sent to correct order book");
        require(_order.traderAddr != address(0), "invalid-trader");
        require(_order.iDeadline > block.timestamp, "invalid-deadline");

        bytes32 digest = _getDigest(_order, address(perpManager), true);
        address signatory = ECDSA.recover(digest, signature);
        //Verify address is not null and PK is not null either.
        require(RSKAddrValidator.checkPKNotZero(signatory), "invalid signature or PK");
        require(signatory == _order.traderAddr, "invalid signature");
        require(orderOfDigest[digest].traderAddr == address(0), "order-exists");
        require(digestsOfTrader[_order.traderAddr].length < MAX_ORDERS_PER_TRADER, "max num orders for trader exceeded");
        // register
        _addOrder(digest, _order, signature);
        emit PerpetualLimitOrderCreated(_order.iPerpetualId, 
            _order.traderAddr, _order.fAmount, _order.fLimitPrice, 
            _order.fTriggerPrice, _order.iDeadline, _order.referrerAddr, 
            _order.flags, _order.fLeverage, _order.createdTimestamp, digest);

    }

    /**
     * @notice Execute Order or cancel & remove it (if expired).
     * @dev Interacts with the PerpetualTradeManager.
     * @param _order the order details.
     * */
    function executeLimitOrder(Order memory _order) external {
        bytes32 digest = _getDigest(_order, address(perpManager), true);
        _executeLimitOrder(_order, digest);
    }

    /**
     * @notice Execute Order or cancel & remove it (if expired).
     * @dev Interacts with the PerpetualTradeManager.
     * @param _digest hash of the order.
     * @param _referrerAddr address that will receive referral rebate
     * */
    function executeLimitOrderByDigest(bytes32 _digest, address _referrerAddr) external {
        Order memory order = orderOfDigest[_digest];
        order.referrerAddr = _referrerAddr;
        _executeLimitOrder(order, _digest);
    }

    /**
     * @notice Execute Order or cancel & remove it
     * @dev Interacts with the PerpetualTradeManager.
     * @param _digest hash of the order.
     * @param _order the order details.
     * */
    function _executeLimitOrder(Order memory _order, bytes32 _digest) internal {
        bytes memory signature = orderSignature[_digest];
        // Remove the order (locally) if it has expired
        if (block.timestamp <= _order.iDeadline) {
            perpManager.tradeBySig(_order, signature);
        }
        // if expired or executed, we remove the order
        // if the order does not match with prices, there is a revert so
        // we do not end up here
        _removeOrder(_digest);
    }

    /**
     * @notice Cancels limit/stop order
     * @dev Order can be cancelled by the trader himself or it can be
     * removed by the relayer if it has expired.
     * @param _digest hash of the order.
     * @param _signature signed cancel-order; 0 if order expired
     * */
    function cancelLimitOrder(bytes32 _digest, bytes memory _signature) public {
        Order memory order = orderOfDigest[_digest];
        require(perpetualId == order.iPerpetualId, "cancel order should be sent to correct order book");
        perpManager.cancelOrder(order, _signature);
        _removeOrder(_digest);
    }

    /**
     * @notice Internal function to add order to order book.
     * */
    function _addOrder(
        bytes32 _digest,
        Order memory _order,
        bytes memory _signature
    ) internal {
        orderOfDigest[_digest] = _order;
        orderSignature[_digest] = _signature;
        allDigests.push(_digest);
        digestsOfTrader[_order.traderAddr].push(_digest);
        // add order to orderbook linked list
        nextOrderHash[lastOrderHash] = _digest;
        prevOrderHash[_digest] = lastOrderHash;
        lastOrderHash = _digest;
        orderCount = orderCount + 1;
    }

    /**
     * @notice Internal function to remove order from order book.
     * @dev We do not remove entry from orderOfDigest & orderSignature.
     * */
    function _removeOrder(bytes32 _digest) internal {
        // remove from trader's order-array 'orderOfDigest'
        Order memory order = orderOfDigest[_digest];
        bytes32[] storage orderArr = digestsOfTrader[order.traderAddr];
        require(orderArr.length <= MAX_ORDERS_PER_TRADER, "too many orders");
        uint256 k = 0;
        while (k < orderArr.length) {
            if (orderArr[k] == _digest) {
                orderArr[k] = orderArr[orderArr.length - 1];
                orderArr.pop();
                k = MAX_ORDERS_PER_TRADER;
            }
            k = k + 1;
        }
        // remove order
        delete orderOfDigest[_digest];

        // remove from linked list needed
        if (lastOrderHash == _digest) {
            lastOrderHash = prevOrderHash[_digest];
        } else {
            prevOrderHash[nextOrderHash[_digest]] = prevOrderHash[_digest];
        }
        bytes32 prevHash = prevOrderHash[_digest];
        nextOrderHash[prevHash] = nextOrderHash[_digest];
        // delete obsolete entries
        delete prevOrderHash[_digest];
        delete nextOrderHash[_digest];
        orderCount = orderCount - 1;
    }

    /**
     * @notice Returns the number of (active) limit orders of a trader
     * @param trader address of trader.
     * */
    function numberOfDigestsOfTrader(address trader) external view returns (uint256) {
        return digestsOfTrader[trader].length;
    }

    /**
     * @notice Returns the number of all limit orders - including those
     * that are cancelled/removed.
     * */
    function numberOfAllDigests() external view returns (uint256) {
        return allDigests.length;
    }

    /**
     * @notice Returns the number of all limit orders - excluding those
     * that are cancelled/removed.
     * */
    function numberOfOrderBookDigests() external view returns (uint256) {
        return orderCount;
    }

    /**
     * @notice Returns an array of digests of orders of a trader
     * @param trader address of trader.
     * @param page start/offset.
     * @param limit count.
     * */
    function limitDigestsOfTrader(
        address trader,
        uint256 page,
        uint256 limit
    ) external view returns (bytes32[] memory) {
        return digestsOfTrader[trader].paginate(page, limit);
    }

    /**
     * @notice Returns an array of all digests - including those
     * that are cancelled/removed.
     * */
    function allLimitDigests(uint256 page, uint256 limit) external view returns (bytes32[] memory) {
        return allDigests.paginate(page, limit);
    }

    /**
     * @notice Returns the address of trader for an order digest
     * @param digest order digest.
     * @return trader address
     * */
    function getTrader(bytes32 digest) external view returns (address trader) {
        Order memory order = orderOfDigest[digest];
        trader = order.traderAddr;
    }

    /**
     * @notice Returns all orders(specified by offset/start and limit/count) of a trader
     * @param trader address of trader.
     * @param offset start.
     * @param limit count.
     * @return orders : array of orders
     * */
    function getOrders(
        address trader,
        uint256 offset,
        uint256 limit
    ) external view returns (Order[] memory orders) {
        orders = new Order[](limit);
        bytes32[] memory digests = digestsOfTrader[trader];
        for (uint256 i = 0; i < limit; i++) {
            if (i + offset < digests.length) {
                bytes32 digest = digests[i + offset];
                orders[i] = orderOfDigest[digest];
            }
        }
    }

    /**
     * @notice Returns the signature of trader for an order digest.
     * @param digest digest of an order.
     * @return signature signature of the trader who created the order.
     * */
    function getSignature(bytes32 digest) public view returns (bytes memory signature) {
        return orderSignature[digest];
    }

    /**
     * @notice Returns the details of the specified number of orders from
     * the passed starting digest
     * @param _startAfter digest to start.
     * @param _numElements number of orders to display.
     * return (orders, orderHashes) : (order hash details, orderHashes).
     * */
    function pollLimitOrders(bytes32 _startAfter, uint256 _numElements) external view returns (Order[] memory orders, bytes32[] memory orderHashes) {
        uint256 k = 0;
        orders = new Order[](_numElements);
        orderHashes = new bytes32[](_numElements);
        bytes32 current = _startAfter;
        while (k < _numElements) {
            orders[k] = orderOfDigest[nextOrderHash[current]];
            orderHashes[k] = nextOrderHash[current];
            k++;
            current = nextOrderHash[current];
            if (current == bytes32(0)) {
                // no more elements in list, we're done
                k = _numElements;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Limit Order Book Beacon: It holds the address of the implementation.
 * @notice The beacon holds the address of the actual Order Book contract. It is
 * created by the factoy contract and passes the initial implementation. A beacon
 * never changes.
 * */
contract LimitOrderBookBeacon is Ownable {
    // Creates instance of upgradable beacon
    UpgradeableBeacon public immutable beacon;

    /**
     * @notice Deploys beacon with initial implementation.
     * @param _initImplementation Address of first deployed LimitOrderBook implementation.
     * */
    constructor(address _initImplementation, address sender) {
        beacon = new UpgradeableBeacon(_initImplementation);
        transferOwnership(sender);
    }

    /**
     * @notice Updates the implementation.
     * @param _newImplementation Address of updated LimitOrderBook implementation.
     * */
    function update(address _newImplementation) public onlyOwner {
        beacon.upgradeTo(_newImplementation);
    }

    /**
     * @notice Returns current the implementation.
     * */
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./LimitOrderBook.sol";
import "./LimitOrderBookBeacon.sol";

/**
 * @title Limit Order Book Factory: Contract to deploy limit
 * order book for perpetuals
 * @notice Factory pattern allows to create multiple instances
 * of the same contract and keep track of them easily. LimitOrderBookFactory
 * creates Beacon Proxy. This proxy interacts with the beacon to fetch the address
 * of implementation and delegate call to it.
 * */
contract LimitOrderBookFactory is Ownable {
    // Events
    event PerpetualLimitOrderBookDeployed(bytes32 indexed perpetualId, address perpManagerAddress, address limitOrderBookAddress);

    // Perpetual Id => Address of Order Book
    mapping(bytes32 => address) private orderBooks;
    // Instance of beacon
    LimitOrderBookBeacon public immutable beacon;

    /**
     * @notice Sets the initial implementation and creates upgradable beacon.
     * @param _initImplementation Address of first deployed LimitOrderBook implementation.
     * */
    constructor(address _initImplementation) {
        require(_initImplementation != address(0), "invalid implementation address");
        beacon = new LimitOrderBookBeacon(_initImplementation, msg.sender);
    }

    /**
     * @notice Deploys limit order book beacon proxy contract.
     * @param _perpetualManagerAddr the address of perpetual proxy manager.
     * @param _perpetualId The id of perpetual.
     * */
    function deployLimitOrderBookProxy(address _perpetualManagerAddr, bytes32 _perpetualId) external onlyOwner {
        require(orderBooks[_perpetualId] == address(0), "orderbook already deployed");
        BeaconProxy limitOrderBookProxy = new BeaconProxy(
            address(beacon),
            abi.encodeWithSelector(LimitOrderBook(address(0)).initialize.selector, _perpetualManagerAddr, _perpetualId)
        );
        orderBooks[_perpetualId] = address(limitOrderBookProxy);
        emit PerpetualLimitOrderBookDeployed(_perpetualId, _perpetualManagerAddr, address(limitOrderBookProxy));
    }

    /**
     * @notice Gets the address of order book deployed for a specific perpetual.
     * @param _perpetualId The id of perpetual.
     * */
    function getOrderBookAddress(bytes32 _perpetualId) external view returns (address) {
        return orderBooks[_perpetualId];
    }

    /**
     * @notice Gets the beacon address.
     * */
    function getBeacon() public view returns (address) {
        return address(beacon);
    }

    /**
     * @notice Gets the current implementation.
     * */
    function getImplementation() public view returns (address) {
        return beacon.implementation();
    }
}