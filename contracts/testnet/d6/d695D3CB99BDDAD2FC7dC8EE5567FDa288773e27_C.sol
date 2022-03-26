/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IDataTypesPractice {
    function getInt256() external view returns(int256);
    function getUint256() external view returns(uint256);
    function getIint8() external view returns(int8);
    function getUint8() external view returns(uint8);
    function getBool() external view returns(bool);
    function getAddress() external view returns(address);
    function getBytes32() external view returns(bytes32);
    function getArrayUint5() external view returns(uint256[5] memory);
    function getArrayUint() external view returns(uint256[] memory);
    function getString() external view returns(string memory);

    function getBigUint() external pure returns(uint256);
}

contract C is IDataTypesPractice {
    int256  n = 1;
    bytes32 constant fourtyTwo = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x22";
    uint256 m = bytesToUint(fourtyTwo);
    int8    k = 2;
    uint8   t = 3;

    bool cake = false;
    address IERC1820Registry = 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24;

    uint[5] fib = [5, 8, 13, 21, 34];

    string hello = "H\n\te\n\x09\x09l\n\t\\x09\x09l\x09\x09lo\x0b\x57orl\x64\x21";

    uint256[] primes = [0x2, 0x3, 0x5, 0x7, 0xb, 0xd, 0x11, 0x13, 0x17, 0x1d, 0x1f, 0x25, 0x29, 0x2b, 0x2f, 0x35, 0x3b, 0x3d, 0x43, 0x47, 0x49, 0x4f, 0x53, 0x59, 0x61, 0x65, 0x67, 0x6b, 0x6d, 0x71, 0x7f, 0x83, 0x89, 0x8b, 0x95, 0x97, 0x9d, 0xa3, 0xa7, 0xad, 0xb3, 0xb5, 0xbf, 0xc1, 0xc5, 0xc7, 0xd3, 0xdf, 0xe3, 0xe5, 0xe9, 0xef, 0xf1, 0xfb, 0x101, 0x107, 0x10d, 0x10f, 0x115, 0x119, 0x11b, 0x125, 0x133, 0x137, 0x139, 0x13d, 0x14b, 0x151, 0x15b, 0x15d, 0x161, 0x167, 0x16f, 0x175, 0x17b, 0x17f, 0x185, 0x18d, 0x191, 0x199, 0x1a3, 0x1a5, 0x1af, 0x1b1, 0x1b7, 0x1bb, 0x1c1, 0x1c9, 0x1cd, 0x1cf, 0x1d3, 0x1df, 0x1e7, 0x1eb, 0x1f3, 0x1f7, 0x1fd, 0x209, 0x20b, 541];


    function getInt256() external view returns(int256)
    {
        return n;
    }

    function getUint256() external view returns(uint256)
    {
        return m;
    }

    function getIint8() external view returns(int8) 
    {

        return k;
    }

    function getUint8() external view returns(uint8)
    {

        return t;
    }
    function getBool() external view returns(bool) 
    {

        return cake || true;
    }

    function getAddress() external view returns(address)
    {
        return IERC1820Registry;
    }

    function getBytes32() external pure returns(bytes32)
    {
        return fourtyTwo;
    }

    function getArrayUint5() external view returns(uint256[5] memory)
    {
        return fib;
    }

    function getArrayUint() external view returns(uint256[] memory) 
    {

        return primes;
    }

    function getString() external pure returns(string memory)
    {

        return "Hello World!";
    }

    function bytesToUint(bytes32 b) public pure returns (uint256)
    {
        uint256 number;
        for(uint i = 0; i < 32; i++) {
            number = number + uint8(b[i]);
        }
        return number;
    }

    function getBigUint() external pure returns(uint256)
    {
        uint256 v1 = bytesToUint("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x22") ** 5;
        uint256 v2 = 0x0ffffff;
        return v1 ^ v2;
    }
}