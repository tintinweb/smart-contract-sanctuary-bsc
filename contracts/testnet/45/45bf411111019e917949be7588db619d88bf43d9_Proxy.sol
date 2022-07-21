/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.5 <0.9.0;

contract Proxy {
    function forward(address target, string memory signature, bytes memory data) external {
        bytes memory callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        (bool status,) = target.call(callData);
        require(status, "Forwarded call failed.");
    }
}