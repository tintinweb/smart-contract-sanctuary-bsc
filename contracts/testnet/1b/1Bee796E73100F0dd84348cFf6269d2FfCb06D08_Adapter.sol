/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT

// Modified from Delegatable.sol from gTrade

pragma solidity ^0.8.0;

contract Adapter {
    mapping (address => address) public delegations;
    address private senderOverride;

    address public targetGmx; // Added

    constructor(address gmx) {
        targetGmx = gmx;
    }

    function setDelegate(address delegate) external {
        require(tx.origin == msg.sender, "NO_CONTRACT");

        delegations[msg.sender] = delegate;
    }

    function removeDelegate() external {
        delegations[msg.sender] = address(0);
    }

    function delegatedAction(address trader, bytes calldata call_data) external returns (bytes memory) {
        require(delegations[trader] == msg.sender, "DELEGATE_NOT_APPROVED");

        senderOverride = trader;
        //(bool success, bytes memory result) = address(this).delegatecall(call_data); // Comment off
        (bool success, bytes memory result) = targetGmx.delegatecall(call_data); // Test this

        if (!success) {
            // Next 5 lines from https://ethereum.stackexchange.com/a/83577 (return the original revert reason)
            if (result.length < 68) revert();
            assembly {
                result := add(result, 0x04)
            }
            revert(abi.decode(result, (string)));
        }

        senderOverride = address(0);

        return result;
    }


    function _msgSender() public view returns (address) {
        if (senderOverride == address(0)) {
            return msg.sender;
        } else {
            return senderOverride;
        }
    }
}