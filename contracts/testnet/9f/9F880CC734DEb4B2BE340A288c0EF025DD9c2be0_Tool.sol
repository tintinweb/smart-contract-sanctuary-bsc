// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Tool{

    function chainId() public view returns (uint256){
        return block.chainid;
    }

    function msgSender() public view returns (address){
        return msg.sender;
    }
}