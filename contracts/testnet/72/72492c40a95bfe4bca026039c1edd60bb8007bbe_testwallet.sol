/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: Sep
pragma solidity ^0.6.6;

contract testwallet {

    function callSeed(address _seed1) public view returns (uint256[40] memory _seed) {
        bytes memory load = abi.encodeWithSignature("Hash(uint256,uint256)", 10000, 40);
        (, bytes memory returnData) = address(_seed1).staticcall(load);
        _seed = abi.decode(returnData,(uint256[40]));
    }

    uint256 public aaaa;

    function testWrite(uint256 _a) public {
        aaaa = _a;

    }
    function testWriteLoop(uint256 _a, uint256 times) public {
        uint256 __a = _a;

        for(uint i = 0; i < times; i++) {
            __a++;
        }
        aaaa = __a;
    }

    uint256[] public bbbb;

    function testpush(uint256 times) public {
        for (uint i = 0; i < times; i++) {
            bbbb.push(i);
        }
    }

    function testpush(uint256 a1,uint256 a2,uint256 a3,uint256 a4,uint256 a5,uint256 a6) public {
        bbbb[0] = a1;
        bbbb[1] = a2;
        bbbb[2] = a3;
        bbbb[3] = a4;
        bbbb[4] = a5;
        bbbb[5] = a6;
    }
}