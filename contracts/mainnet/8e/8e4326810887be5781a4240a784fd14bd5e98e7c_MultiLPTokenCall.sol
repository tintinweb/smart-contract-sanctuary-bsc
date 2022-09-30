/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface LPToken {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract MultiLPTokenCall {
    function aggregate(address[] memory _lpAddresses) external view returns (uint256 _blockNumber, address[][] memory _payload) {
        _blockNumber = block.number;
        uint256 _length = _lpAddresses.length;
        _payload = new address[][](_length);
        for (uint256 i = 0; i < _length;) {
            address[] memory _lpData;
            _lpData[0] = LPToken(_lpAddresses[i]).token0();
            _lpData[1] = LPToken(_lpAddresses[i]).token1();
            _payload[i] = _lpData;
        }
    }
}