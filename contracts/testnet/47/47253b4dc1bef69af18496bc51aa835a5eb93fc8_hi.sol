/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

//// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.7;
contract hi {
    function globalvar() external  view returns(address,uint,uint){
        address mine = msg.sender;
        uint ts = block.timestamp;
        uint blockNum = block.number;
        return (mine,ts,blockNum);
    }

}