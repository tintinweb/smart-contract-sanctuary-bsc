/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface IAutomateCompatible {
  function checkTask(bytes calldata checkData) external returns (bool taskNeeded, bytes memory performData);
  function performTask(bytes calldata performData) external;
}

contract SampleCompatible is IAutomateCompatible {
    uint public counter;
    address public owner;
    uint public interval;
    uint public lastTimeStamp;

    constructor() {
        interval = 3600;
        lastTimeStamp = block.timestamp;
        owner = msg.sender;

        counter = 0;
    }

    function checkTask(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performTask(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            counter = counter + 1;
        }
    }

    function setInterval(uint256 _interval) external {
        require(msg.sender == owner);
        interval = _interval;
    } 
}