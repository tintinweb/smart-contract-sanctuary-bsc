/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Hash{
    bytes32 _msg = keccak256(abi.encodePacked("1"));

    // 唯一数字标识
    function hash(
        uint _num
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_num));
    }

    // 弱抗碰撞性
    function weak(
        string memory string1
    )public view returns (bool){
        return keccak256(abi.encodePacked(string1)) == _msg;
    }

    // 强抗碰撞性
    function strong(
        string memory string1,
        string memory string2
    )public pure returns (bool){
        return keccak256(abi.encodePacked(string1)) == keccak256(abi.encodePacked(string2));
    }
}