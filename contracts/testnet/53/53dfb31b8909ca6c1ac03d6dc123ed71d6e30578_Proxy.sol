/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Proxy {
    address public implementation;

    function setImplementation(address addr) public {
        implementation = addr;
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), sload(implementation.slot), ptr, calldatasize(), 0, 0 )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}