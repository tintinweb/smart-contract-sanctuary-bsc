/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.7;



contract SimpleCounter {

    uint256 private counter;
    address keeperRegistry;
    constructor(){
        counter = 0;
        keeperRegistry = address(0x02777053d6764996e594c3E88AF1D58D5363a2e6);
    }

    modifier isKeeper {
        require(msg.sender == keeperRegistry, "Unauthorized");
        _;
    }

    function increment() external isKeeper returns (uint256, address){
        counter++;
        return (counter, msg.sender);
    }
    function getCounter() external view returns(uint256){
        return counter;
    }
}