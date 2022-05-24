// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Console {

  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) public pure returns (string memory) {
      // Inspired by OraclizeAPI's implementation - MIT licence
      // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

      if (value == 0) {
          return "0";
      }
      uint256 temp = value;
      uint256 digits;
      while (temp != 0) {
          digits++;
          temp /= 10;
      }
      bytes memory buffer = new bytes(digits);
      while (value != 0) {
          digits -= 1;
          buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
          value /= 10;
      }
      return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) public pure returns (string memory) {
      if (value == 0) {
          return "0x00";
      }
      uint256 temp = value;
      uint256 length = 0;
      while (temp != 0) {
          length++;
          temp >>= 8;
      }
      return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) public pure returns (string memory) {
      bytes memory buffer = new bytes(2 * length + 2);
      buffer[0] = "0";
      buffer[1] = "x";
      for (uint256 i = 2 * length + 1; i > 1; --i) {
          buffer[i] = _HEX_SYMBOLS[value & 0xf];
          value >>= 4;
      }
      require(value == 0, "Strings: hex length insufficient");
      return string(buffer);
    }

    function stringConcat(string[] memory arr) public pure returns(string memory) {
      uint256 digits;
      bytes[] memory bytesArr = new bytes[](arr.length);

      for (uint i = 0; i < arr.length; i++) {
          bytes memory strAsBytes = bytes(arr[i]);
          digits += strAsBytes.length;
          bytesArr[i] = strAsBytes;
      }

      bytes memory ret = new bytes(digits);
      uint256 pos;

      for (uint i = 0; i < bytesArr.length; i++) {
          bytes memory _bytes = bytesArr[i];
          for (uint j = 0; j < _bytes.length; j++) {
              ret[pos++] = _bytes[j];
          }
      }

      return string(ret);
    }

    function stringConcat(string memory a, string memory b) public pure returns(string memory) {
      string[] memory arr = new string[](2);
      arr[0] = a;
      arr[1] = b;
      return stringConcat(arr);
    }

    event LogBool(string, bool);
    function log(string memory s , bool x) internal {
      emit LogBool(s, x);
    }
        
    event LogInt(string, int);
    function log(string memory s , int x) internal {
      emit LogInt(s, x);
    }

    event LogUint(string, uint);
    function log(string memory s , uint x) internal {
      emit LogUint(s, x);
    }

    // event LogUint256(string, uint256);
    // function log(string memory s , uint256 x) internal {
    //   emit LogUint256(s, x);
    // }

    event LogAddress(string, address);
    function log(string memory s , address x) internal {
      emit LogAddress(s, x);
    }
    
    event LogBytes(string, bytes);
    function log(string memory s , bytes memory x) internal {
      emit LogBytes(s, x);
    }
    
    event LogBytes32(string, bytes32);
    function log(string memory s , bytes32 x) internal {
      emit LogBytes32(s, x);
    }

    event LogString(string, string);
    function log(string memory s , string memory x) internal {
      emit LogString(s, x);
    }

    event Log(string);
    function log(string memory s) internal {
      emit Log(s);
    }

    function io(string memory s) pure internal {
      require(false, s);
    }
}