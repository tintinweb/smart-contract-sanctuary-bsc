/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;
    // This code has not been professionally audited, therefore I cannot make any promises about
// safety or correctness. Use at own risk.
contract Randomness {
    uint256 random;
    uint256 id = 0;
    mapping(uint256 => uint256) public idToBlock;
    event randomRequest(uint256 _id);
    event randomGenerated(uint256 _random);
    function setRandom(uint256 _id) external{
        random = uint256(keccak256(abi.encodePacked(blockhash(idToBlock[_id]), msg.sender))) % 10;
        emit randomGenerated(random);
    }

    function callRandom() public {
        id = id+1;
        idToBlock[id] = block.number; 
        emit randomRequest(id);
    }

}