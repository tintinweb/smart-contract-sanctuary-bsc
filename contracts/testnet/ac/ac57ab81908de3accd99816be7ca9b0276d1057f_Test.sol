/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.7.0;

contract Test {
    address proxy;
    
    constructor(address _proxy) {
        proxy = _proxy;
    }
    
    function test() external returns (bytes memory) {
        bytes memory payload = abi.encodeWithSignature("add(uint256,uint256)", 30, 12);
        (bool success, bytes memory returnData) = proxy.call(payload);

        require(success, "call to proxy failed");
        return returnData;
    }
}