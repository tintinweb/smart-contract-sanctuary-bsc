// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Util {

    // Return the lenght of a string
    function length(string memory str) internal pure returns (uint256) {
        uint256 len;
        uint256 i = 0;
        uint256 bytelength = bytes(str).length;
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(str)[i];
            if (b < 0x80) { i += 1; } 
            else if (b < 0xE0) { i += 2; } 
            else if (b < 0xF0) { i += 3; }
            else if (b < 0xF8) { i += 4; } 
            else if (b < 0xFC) { i += 5; } 
            else { i += 6; }
        }
        return len;
    }
    
    // bytes8ToString
    function toString(bytes8 _bytes8) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 8 && _bytes8[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 8 && _bytes8[i] != 0; i++) {
            bytesArray[i] = _bytes8[i];
        }
        return string(bytesArray);
    }
    
    function toBytes8(string memory str) public pure returns (bytes8) {
        return bytes8(bytes(str));
    }
}