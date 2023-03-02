/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutoTransfer {
    address payable public recipient1;
    address payable public recipient2;
    uint256 public transferAmount1;
    uint256 public transferAmount2;
    uint256 public lastTransferTime;

    constructor() {
        recipient1 = payable(0x5b299CE9c73b286CcEc2abFA145Cba63fCF724C3);
        recipient2 = payable(0xF22B976EA899662017EC98d3E1B1299aDfD89df2);
        transferAmount1 = (address(this).balance * 99) / 100;
        transferAmount2 = (address(this).balance * 1) / 100;
        lastTransferTime = block.timestamp;
    }

    function transfer() public payable {
        require(block.timestamp >= lastTransferTime + 1, "Transfer interval not elapsed yet");
        require(address(this).balance >= transferAmount1 + transferAmount2, "Insufficient balance");

        (bool success1,) = recipient1.call{value: transferAmount1}("");
        require(success1, "Transfer to recipient1 failed");

        (bool success2,) = recipient2.call{value: transferAmount2}("");
        require(success2, "Transfer to recipient2 failed");

        lastTransferTime = block.timestamp;
    }
}