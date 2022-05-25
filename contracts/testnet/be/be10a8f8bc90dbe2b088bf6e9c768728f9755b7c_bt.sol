/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

contract bt {
    function call_a1(uint256 xxx) external  returns (uint256 _r) {
        // uint256 memory xxxx = 3;
        // bytes4 methodId = bytes4();

        // _r = address(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8).call(abi.encodeWithSignature("aa(uint256)", 15));
        bytes memory payload = abi.encodeWithSignature("aa(uint256)", xxx);

        (, bytes memory returnData) = address(0x51e52c5C5f69e8d4cBF7d2D84b265EcADAE9cfFD).call(payload);

        _r = abi.decode(returnData,(uint256));
        
        // .call(keccak256(abi.), 3);

    }

    function call_a2(uint256 xxx) external returns (uint256 _r) {

        bytes memory payload = abi.encodeWithSignature("a2(uint256)", xxx);

        (, bytes memory returnData) = address(0x51e52c5C5f69e8d4cBF7d2D84b265EcADAE9cfFD).call(payload);

        _r = abi.decode(returnData,(uint256));
    }
}