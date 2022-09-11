/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract BatchTransferAndCollect {
    function batchTransfer(uint256 amount, address[] memory toAddress) external payable{
        uint length = toAddress.length;
        uint256 total = length * amount;
        require(msg.value >= total, "Balance not enough");
        for(uint i=0; i<length; i++){
            payable(toAddress[i]).transfer(amount);
        }
    }
}