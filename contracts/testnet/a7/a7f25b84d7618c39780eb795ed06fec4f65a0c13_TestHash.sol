/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract TestHash{
    uint constant public TOKEN_LIMIT = 999;
    uint[TOKEN_LIMIT] public indices;
    uint nonce;

    uint[] datas;
    function randomIndex() private returns (uint) {
        uint totalSize = TOKEN_LIMIT - nonce;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }
 
        if (indices[totalSize - 1] == 0) {
            indices[index] = totalSize - 1;
        } else {
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        return value+1;
    }

    function random() public  returns (uint) {
       uint value = randomIndex();
        datas.push(value);
        return value;
    }

    function randomMul() public {
        for(uint i=0;i<5;i++){
            datas.push(randomIndex());
        }
    }

    function getDatas() public view returns(uint [] memory){
        return datas;
    }

    function getDatasLength() public view returns(uint){
        return datas.length;
    }
    
    function getDatasAtIndex(uint index) public view returns(uint){
        return datas[index];
    }
    
}