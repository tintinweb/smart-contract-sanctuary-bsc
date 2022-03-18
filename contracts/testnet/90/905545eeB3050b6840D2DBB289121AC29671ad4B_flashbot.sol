/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIXED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract flashbot {
    function testCall() public payable {
        address payable bp = payable(block.coinbase);
        bp.transfer(msg.value);
    }

    function getCoinbase() public view returns(address c){
        c=block.coinbase;
    }
}