// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IDAOProxy.sol";
import "../../utils/StoreAddresses.sol";

import "../../../../../CheckDot.DAOProxyContract/contracts/interfaces/IOwnedProxy.sol";

contract CheckDotInsuranceStore {
    using StoreAddresses for StoreAddresses.StoreAddressesSlot;

    /**
     * @dev Store slot with the upgrades of the contract.
     * This is the keccak-256 hash of "io.checkdot.index.updates" subtracted by 1
     */
    bytes32 private constant _INDEX_UPDATES_SLOT = 0xa6e9f6f4f5f44cd389c65f0f1dce0abd10b43565e36a1246ece73be4a7146964;

    /**
     * @dev Store slot with the keys of the contract.
     * This is the keccak-256 hash of "io.checkdot.index.keys" subtracted by 1
     */
    bytes32 private constant _INDEX_KEYS_SLOT = 0x50be8a13ecec2d77a06a6bd58c41283bea83050138a149f5656e98c79439ee4a;

    function initialize(bytes memory _data) external onlyOwner {
        // unused
    }

    modifier onlyOwner {
        require(msg.sender == IOwnedProxy(address(this)).getOwner(), "FORBIDDEN");
        _;
    }

    /**
     * @dev Update function of one key address value
     */
    function updateAddress(string calldata _key, address _newAddress) external onlyOwner {
        require(msg.sender == IOwnedProxy(address(this)).getOwner(), "FORBIDDEN");
        require(bytes(_key).length > 0, "FORBIDEN");

        _updateAddress(_key, _newAddress);
    }

    /**
     * @dev Returns the Insurance Protocol addresses.
     */
    function getAddress(string calldata _key) external view returns (address) {
        return StoreAddresses.getStoreAddressesSlot(_INDEX_KEYS_SLOT).value[_key];
    }

    /**
     * @dev Stores a new addresses of the Insurance Protocol.
     */
    function _setAddress(string calldata _key, address _newKeyAddress) internal {
        StoreAddresses.getStoreAddressesSlot(_INDEX_KEYS_SLOT).value[_key] = _newKeyAddress;
    }

    /**
     * @dev Stores a new Insurance Protocol address by key index.
     */
    function _updateAddress(string calldata _key, address _newKeyAddress) internal {
        _setAddress(_key, _newKeyAddress);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title IndexAddresses
 * @author Jeremy Guyet (@jguyet)
 * @dev Library to manage the storage of mapped addresses.
 */
library StoreAddresses {
    struct StoreAddressesSlot {
        mapping(string => address) value;
    }

    /**
     * @dev Returns an `StoreAddressesSlot` with member `value` located at `slot`.
     */
    function getStoreAddressesSlot(bytes32 slot) internal pure returns (StoreAddressesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title IDAOProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IDAOProxy {

    function getGovernance() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IOwnedProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IOwnedProxy {

    function getOwner() external view returns (address);

    function transferOwnership(address _newOwner) external payable;
}