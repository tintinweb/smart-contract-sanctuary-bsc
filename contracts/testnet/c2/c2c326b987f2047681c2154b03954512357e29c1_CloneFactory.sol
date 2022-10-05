/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract CloneFactory {

  function createClone(address target) public returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function createClone16(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target)<<32;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602980600a3d3981f3363d3d373d3d3d363d6f000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x24), 0x5af43d82803e903d91602757fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x33)
    }
  }
  function createClone18(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target)<<16;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602b80600a3d3981f3363d3d373d3d3d363d71000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x26), 0x5af43d82803e903d91602957fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x35)
    }
  }
  function createClone17(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target)<<24;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602a80600a3d3981f3363d3d373d3d3d363d70000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x25), 0x5af43d82803e903d91602857fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x34)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }

  function isClone16(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target)<<32;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d6f00000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1a), 0x5af43d82803e903d91602757fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x29)

      result := and(
        eq(mload(clone), mload(other)), 
        eq(mload(add(clone, 0x20)), mload(add(other, 0x20)))
      )
    }
  }

  function isClone17(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target)<<24;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7000000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1b), 0x5af43d82803e903d91602857fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2a)

      result := and(
        eq(mload(clone), mload(other)), 
        eq(mload(add(clone, 0x20)), mload(add(other, 0x20)))
      )
    }
  }

  function isClone18(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target)<<16;
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7100000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1c), 0x5af43d82803e903d91602957fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2b)

      result := and(
        eq(mload(clone), mload(other)), 
        eq(mload(add(clone, 0x20)), mload(add(other, 0x20)))
      )
    }
  }
}