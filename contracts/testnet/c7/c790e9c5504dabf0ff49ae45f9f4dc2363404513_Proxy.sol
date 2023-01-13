/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

//SPDX-License-Identifier: No-Idea!

pragma solidity 0.8.1;

 
contract Proxy  {

     mapping(bytes4 => uint32) _sizes;
    address _dest;

    constructor(address target) {
        replace(target);
    }

  function replace(address target) public {
        _dest = target;
        //target.delegatecall(abi.encodeWithSelector(bytes4(keccak256("initialize()"))));
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                sload(_dest.slot),
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}