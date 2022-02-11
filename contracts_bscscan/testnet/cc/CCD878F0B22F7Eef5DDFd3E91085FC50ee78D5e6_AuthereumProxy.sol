/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.17;


/**
 * @title AuthereumProxy
 * @author Authereum Labs, Inc.
 * @dev The Authereum Proxy.
 */
contract AuthereumProxy {

    // We do not include a name or a version for this contract as this
    // is a simple proxy. Including them here would overwrite the declaration
    // of these variables in the implementation.

    /// @dev Storage slot with the address of the current implementation.
    /// @notice This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @dev Set the implementation in the constructor
    /// @param _logic Address of the logic contract
    constructor(address _logic) public payable {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _logic)
        }
    }

    /// @dev Fallback function
    /// @notice A payable fallback needs to be implemented in the implementation contract
    /// @notice This is a low level function that doesn't return to its internal call site.
    /// @notice It will return to the external caller whatever the implementation returns.
    function () external payable {
        if (msg.data.length == 0) return;

        assembly {
            // Load the implementation address from the IMPLEMENTATION_SLOT
            let impl := sload(IMPLEMENTATION_SLOT)

            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, impl, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
}