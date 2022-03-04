/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// File: utility/BytesUtils.sol



pragma solidity ^0.8.9;

library BytesUtils {
    function slice(bytes calldata data, uint256 beginInclusive) public pure returns (bytes calldata) {
        return data[beginInclusive:];
    }

    function slice(bytes calldata data, uint256 beginInclusive, uint256 endExclusive) public pure returns (bytes calldata) {
        return data[beginInclusive:endExclusive];
    }
}