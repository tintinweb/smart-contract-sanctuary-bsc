/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

pragma solidity ^0.8.0;

contract RandomNumbers{
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % 100;
    }
}