/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract accumulationTwo {

    address owner;
    address receiver;
    uint feeIndex = 7000;
    uint x;
    
    constructor(address _owner, address _receiver){
        owner = _owner;
        receiver = _receiver;
    }

    receive() external payable {
        uint value = msg.value;
        if (value < 5000000000000000) {  
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "Failed");
        } else {
             transaction(value);
        }
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "you are not owner");
        _;
    }

    function transaction (uint value) internal {
        uint remainder = value % 100;
        for (uint i = 1; i<=100; i++) {
            uint sendValue =value/100;
            if (i <= remainder) {
                sendValue++;
            }
            (bool success, ) = receiver.call{value: sendValue}("");
            require(success, "Failed");
        }
        for (uint i = 1; i<=feeIndex; i++) {
            x = x + 1;
        }
        x = 0;
    }

    function withdraw(address _receiver) external onlyOwner {
        (bool success, ) = _receiver.call{value: address(this).balance}("");
        require(success, "Failed");
    }

    function setFeeIndex(uint _feeIndex) external onlyOwner {
        feeIndex = _feeIndex;
    }

    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }


}