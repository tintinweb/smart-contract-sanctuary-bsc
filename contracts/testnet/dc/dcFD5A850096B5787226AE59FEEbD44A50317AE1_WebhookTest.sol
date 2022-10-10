/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract WebhookTest {

    event SampleEvent1(uint256 data1);
    event SampleEvent2(uint256 data1, uint256 data2);
    event SampleEvent3(uint256 data1, uint256 data2, uint256 data3);

    function emitTestEvent1(uint256 data1, uint256 data2, uint256 data3) external {
        emit SampleEvent3(data1, data2, data3);
    }

    function emitTestEvent2(uint256 data1, uint256 data2, uint256 data3) external {
        emit SampleEvent3(data1, data2, data3);
    }

    function emitTestEvent3(uint256 data1, uint256 data2, uint256 data3) external {
        emit SampleEvent3(data1, data2, data3);
    }

}