/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

contract bt {

    uint256 public xxxxx;

    function call_a2(uint256 xxx) external returns (uint256 _r) {

        bytes memory payload = abi.encodeWithSignature("Hash(uint256)", xxx);

        (, bytes memory returnData) = address(0xf56bDdAAb8d11d3164B6431F9c0E2b65a5574755).call(payload);

        _r = abi.decode(returnData,(uint256));
        xxxxx = _r;
    }
}