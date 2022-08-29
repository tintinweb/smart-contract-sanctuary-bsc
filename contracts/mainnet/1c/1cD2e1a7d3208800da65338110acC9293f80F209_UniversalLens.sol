/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

// A universal lens implementation

contract UniversalLens {

    struct Param {
        address callee;
        bytes data;
    }

    function query(Param[] memory params) external view returns (
        uint256 blockNumber,
        uint256 blockTimestamp,
        bytes[] memory results
    ) {
        blockNumber = block.number;
        blockTimestamp = block.timestamp;

        uint256 length = params.length;
        results = new bytes[](length);
        for (uint256 i = 0; i < length; i++) {
            (, results[i]) = params[i].callee.staticcall(params[i].data);
        }
    }

}