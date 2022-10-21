/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

contract walletBytes {

function bytes32ToAddress(bytes memory bys) public pure returns (address addr) {
    assembly {
      addr := mload(add(bys,32))
    } 
}

function encode(address _addy) public pure returns (bytes memory) {
   return abi.encode(address(_addy));
}

    }