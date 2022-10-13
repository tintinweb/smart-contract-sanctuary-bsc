// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Wallet {

    uint256 public constant MIN = 10000000000000000; // 0.01
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function forward() private {
        if(msg.value >= MIN){
            (bool success,) = payable(owner).call{value: address(this).balance}("");
            require(success);
        }
    }

    receive() external payable { forward(); }
    fallback() external payable { forward(); }
}