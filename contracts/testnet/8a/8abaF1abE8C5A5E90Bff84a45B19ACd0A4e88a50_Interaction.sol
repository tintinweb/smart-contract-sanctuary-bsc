/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface ICounter {
    function count() external view returns (uint);
    function increment() external;
    function tokenURI(uint256) external view returns(string memory);
}

contract Interaction {
    address counterAddr;

    function setCounterAddr(address _counter) public payable {
       counterAddr = _counter;
    }

    function getCount() external view returns (uint) {
        return ICounter(counterAddr).count();
    }

    function getURI(uint256 _tokenID) external view returns (string memory) {
        return ICounter(counterAddr).tokenURI(_tokenID);
    }

}