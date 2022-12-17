/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

contract Blockchain {

    struct BlockStruck {
        uint256 index;
        uint256 timestamp;
        uint256 amount;
        address sender;
        address recipient;
    }

    event BlockEvent(uint256 amount, address sender, address recipient);

    BlockStruck[] chain;
    uint256 chainCount;

    constructor() {
        chainCount = 0;
    }


    function addToBlockChain(uint256 amount, address payable recipient) public {
        chainCount += 1;

        chain.push(
            BlockStruck(
                chainCount,
                block.timestamp,
                amount,
                msg.sender,
                recipient
            )
        );

        emit BlockEvent(amount, msg.sender, recipient);
    }

    function getChain() public view returns (BlockStruck[] memory) {
        return chain;
    }

    function getChainCount() public view returns (uint256) {
        return chainCount;
    }


}