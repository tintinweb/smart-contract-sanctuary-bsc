/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface LPToken {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract MultiLPTokenCall {
    function aggregate(address[] memory _lpAddresses) external view returns (uint256 blockNumber, address[][] memory payload) {
        blockNumber = block.number;
        uint256 _length = _lpAddresses.length;
        payload = new address[][](_length);
        for (uint256 i = 0; i < _length; i++) {
            address[] memory _lpData = new address[](2);
            _lpData[0] = LPToken(_lpAddresses[i]).token0();
            _lpData[1] = LPToken(_lpAddresses[i]).token1();
            payload[i] = _lpData;
        }
    }
}