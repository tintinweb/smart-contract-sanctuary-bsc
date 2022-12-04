/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// File: contracts/Proxy.sol

pragma solidity ^0.8.0;

contract Proxy {
    uint256 public bal;
    address public owner;
    address public implementation;

    function getImplementation() external view returns(address ){
        return implementation;
    }

    function setImplementation(address newImplementation) external {
        implementation = newImplementation;
    }

fallback() external payable {
    address _impl = implementation;
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