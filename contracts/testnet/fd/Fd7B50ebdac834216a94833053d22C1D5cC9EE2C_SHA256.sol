/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
//import ".deps/npm/hardhat/console.sol";
struct HashId{
    uint hashId;
}
struct Hash {
    bytes32 previousBlockHash;
    bytes32 hashValue;
}

contract SHA256{
    mapping(address => HashId) private hashId; 
    mapping(address => mapping (uint => Hash)) public hash;
    event getPreviousBlockHashEvent(bytes32 previousBlockHash);  

   function getPreviousBlockHash() public {
       emit getPreviousBlockHashEvent(blockhash(block.number - 1)); 
   }
}
//Current contract address: 0xFd7B50ebdac834216a94833053d22C1D5cC9EE2C