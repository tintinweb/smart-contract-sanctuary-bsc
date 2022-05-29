/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
contract testblockhash {
        //测试
    function Getblockhash(uint256 Forwardblock) public view returns(bytes32){
      return blockhash(block.number-Forwardblock);
    }
}