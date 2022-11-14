/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

error ErrorCall(bytes);

library TokenConstant {
    function transferFrom(address from, address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount);
    }

    function transfer(address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function balanceOf(address owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("balanceOf(address)", owner);
    }

    function tokenCallData(address callAddress, bytes memory data) internal returns (bytes memory returnData) {
        (, returnData) = callAddress.call(data);
    }

    function tokenCall(address callAddress, bytes memory callData) internal {
        (bool success, ) = callAddress.call(callData);
        if(!success) {
            revert ErrorCall(callData);
        }
    }
}