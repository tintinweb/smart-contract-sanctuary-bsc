/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// File: contracts/StakingProxy.sol


pragma solidity >=0.7.0 <0.9.0;


contract StakingProxy {
    
    // bytes32 private constant master = keccak256("com.saitama.proxy.master");


    // function setImplementation(address newImplementation) public {
    //     bytes32 position = master;
    //     assembly {
    //         sstore(position, newImplementation)
    //     }
    // }

    // function implementation() public view returns (address impl) {
    //     bytes32 position = master;
    //     assembly {
    //         impl := sload(position)
    //     }
    // }
    address internal imp;

    constructor (address _imp) {
        imp = _imp;
    }

   
    fallback() external payable {
    address _impl = imp;
        assembly 
        {
  let ptr := mload(0x40)

  // (1) copy incoming call data
  calldatacopy(ptr, 0, calldatasize())

  // (2) forward call to logic contract
  let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
  let size := returndatasize()

  // (3) retrieve return data
  returndatacopy(ptr, 0, size)

  // (4) forward return data back to caller
  switch result
  case 0 { revert(ptr, size) }
  default { return(ptr, size) }
}
    }
}