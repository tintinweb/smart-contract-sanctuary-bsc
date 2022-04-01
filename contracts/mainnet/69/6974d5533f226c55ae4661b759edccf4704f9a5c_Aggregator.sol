/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Aggregator {
    fallback () external payable {
    }

    function aggregate(address[] memory addresses, uint256[] memory values, bytes[] memory payloads, address beneficiary) public payable {
        for (uint256 i = 0; i < addresses.length; i++) {
            (bool success, ) = addresses[i].call{value: values[i]}(payloads[i]);
            require(success);
        }
        (bool success, ) = beneficiary.call{value: address(this).balance}(new bytes(0));
        require(success);
    }
}