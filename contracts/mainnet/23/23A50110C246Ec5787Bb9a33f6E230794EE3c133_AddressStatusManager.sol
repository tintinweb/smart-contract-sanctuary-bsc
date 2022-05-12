// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * Below we refer to the status, which is just an int, we have several different options such as:
 * 0 - Unverified
 * 1 - Blacklisted
 * ...
 * The reason we just use ints is because an enum is not upgradable
 */

contract AddressStatusManager is Ownable {
    mapping(address => uint8) private _addressStatuses;

    event ChangeAddressStatus(address indexed account, uint8 status);

    function setStatus(address account, uint8 status) external onlyOwner {
        _addressStatuses[account] = status;
        emit ChangeAddressStatus(account, status);
    }

    function statusOf(address account) external view returns (uint8) {
        return _addressStatuses[account];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * Follows the ERC173 standard.
 * TODO: Once standard is finalised should move to that one
 */
contract Ownable {
    address private _owner;

    /**
     * Event that gets emitted if an owner is transferred
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * Returns the address of the owner
     */
    function contractOwner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(
            msg.sender == contractOwner(),
            "Ownable: Only the owner can call this"
        );
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}