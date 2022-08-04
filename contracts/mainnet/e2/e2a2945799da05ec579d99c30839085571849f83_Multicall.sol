/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface UniV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Multicall {
    struct Result {
        uint112 reserve0;
        uint112 reserve1;
        address pair;
    }

    function process(address[] calldata pairs) public view returns(Result[] memory) {
        Result[] memory results = new Result[](pairs.length);

        for (uint256 i; i < pairs.length; i++) {
            (uint112 reserve0, uint112 reserve1, ) = UniV2Pair(pairs[i]).getReserves();
            results[i] = Result(reserve0, reserve1, pairs[i]);
        }

        return results;
    }
}