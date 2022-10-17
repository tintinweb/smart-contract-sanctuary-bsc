// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../../../../CheckDot.DAOProxyContract/contracts/Proxy.sol";

contract UpgradableCheckDotInsuranceCalculator is Proxy {
    constructor() Proxy() { }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ProxyAddresses
 * @author Jeremy Guyet (@jguyet)
 * @dev Library to manage the storage of addresses for proxies.
 */
library ProxyAddresses {
    struct AddressSlot {
        address value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./utils/ProxyAddresses.sol";

/**
 * @title UpgradableProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev Smart contract to implement on a contract proxy.
 * This contract allows the management of the important memory of a proxy.
 * The memory spaces are extremely far from the beginning of the memory
 * which allows a high security against collisions.
 * This contract allows updates using a DAO program governed by an
 * ERC20 governance token. A voting session is mandatory for each update.
 * All holders of at least one whole token are eligible to vote.
 * There are several memory locations dedicated to the proper functioning
 * of the proxy (Implementation, admin, governance, upgrades).
 * For more information about the security of these locations please refer
 * to the discussions around the EIP-1967 standard we have been inspired by.
 */
contract UpgradableProxy {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /**
     * @dev Returns the current Owner address.
     */
    function getOwner() external view returns (address) {
        return _getOwner();
    }

    /**
     * @dev Transfer the ownership onlyOwner can call this function.
     */
    function transferOwnership(address _newOwner) external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        _setOwner(_newOwner);
    }

    /**
     * @dev Update function of the proxified implementation,
     */
    function upgrade(address _newImplementationAddress, bytes memory _initializationData) external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        _upgrade(_newImplementationAddress, _initializationData);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address _newImplementation) private {
        ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value = _newImplementation;
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getOwner() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setOwner(address _owner) private {
        ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value = _owner;
    }

    /**
     * @dev Stores the new implementation address in the implementation slot
     * and call the internal _afterUpgrade function used for calling functions
     * on the new implementation just after the set in the same nonce block.
     */
    function _upgrade(address _newFunctionalAddress, bytes memory _initializationData) internal {
        _setImplementation(_newFunctionalAddress);
        _afterUpgrade(_newFunctionalAddress, _initializationData);
    }

    /**
     * @dev internal virtual function implemented in the Proxy contract.
     * This is called just after all upgrades of the proxy implementation.
     */
    function _afterUpgrade(address _newFunctionalAddress, bytes memory _initializationData) internal virtual { }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UpgradableProxy.sol";

/**
 * @title Proxy
 * @author Jeremy Guyet (@jguyet)
 * @dev Proxy contract allows the binding of a version by version
 * implementation which can be updated thanks to the
 * UpgradableProxy abstraction.
 */
contract Proxy is UpgradableProxy {

    constructor() UpgradableProxy() {}

    /**
     * @dev This is the fallback function a fall back function is triggered if someone
     * sends a function call or a transaction to this contract AND there is no function
     * that corresponds to the name the callers is trying to execute.
     * Each call is then passed to the _delegate function which will call the functions
     * of the functional implementation.
     */
    fallback() external payable {
        _delegate(_getImplementation());
    }

    /**
     * @dev This is the receive function is triggered if someone send transaction to
     * this contract. Each call is then passed to the _delegate function which will
     * call the functions of the functional implementation.
     */
    receive() external payable {
        _delegate(_getImplementation());
    }

    /**
     * @dev This is the fallback function a fall back function is triggered if someone
     * sends a function call or a transaction to this contract AND there is no function
     * that corresponds to the name the callers is trying to execute 
     * e.g. if someone tries to call HelloWorld() to this contract, which doesn't exist
     * in this contract, then the fallback function will be called. 
     * In this case, the fallback function will redirect the call to the functional contract
     */
    function _delegate(address implementation) internal {
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
     * @dev This function is called once the implementation is updated.
     * It calls the initialize function of the proxy contract,
     * this allows an update of some variables if necessary
     * when updating the proxy code again.
     */
    function _afterUpgrade(address _newFunctionalAddress, bytes memory _initializationData) internal virtual override {
        address implementation = _newFunctionalAddress;
        bytes memory data = abi.encodeWithSignature("initialize(bytes)", _initializationData);

        assembly {
            let result := delegatecall(
                gas(),
                implementation,
                add(data, 0x20), // add is another assembly function; this changes the format to something that delegate call can read
                mload(data), // mload is memory load
                0,
                0
            )
            let size := returndatasize()
            let ptr := mload(0x40) // ptr as in pointer
            returndatacopy(ptr, 0, size)
            switch result // result will either be 0 (as in function call failed), or 1 (function call success)
            case 0 {
                revert(ptr, size)
            } // revert if function call failed
            default {
                return(ptr, size)
            } // default means "else"; else return
        }
    }
}