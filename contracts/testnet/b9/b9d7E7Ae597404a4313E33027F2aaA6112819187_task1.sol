// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract task1 {

    constructor() payable {
    }

    function play(uint guess) external {
        uint num = uint(keccak256(abi.encodePacked(block.timestamp,block.number,block.difficulty)));
        if(guess == num){
            (bool sent, )= msg.sender.call{value: address(this).balance}("");
            require(sent, "failed to send bnb");
        }
    }
}