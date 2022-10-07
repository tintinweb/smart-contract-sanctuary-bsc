/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library Bytes32Lib {
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /// @dev Converts an unsigned integert to its string representation.
    /// @param v The number to be converted.
    function uintToBytes(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    /// @dev Converts a numeric string to it's unsigned integer representation.
    /// @param v The string to be converted.
    function bytesToUInt(bytes32 v) internal pure returns (uint ret) {
        if (v == 0x0) {
            revert();
        }

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            }
            else if (digit < 48 || digit > 57) {
                revert();
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
    }
}