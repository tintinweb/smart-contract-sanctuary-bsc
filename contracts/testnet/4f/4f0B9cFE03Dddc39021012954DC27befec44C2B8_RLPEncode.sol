/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


contract RLPEncode {


    uint256 index = 0;

    function getHash(bytes memory bloom) public pure returns (bytes32){
        return keccak256(bloom);
    }

    function rlpBlock(bytes32[] memory bytes32Data, address coinbase, bytes[] memory bytesData, uint256[]  memory uintData) external pure returns (bytes memory){
        bytes[] memory t = new bytes[](16);
        bytes[] memory a = parseBytes32(bytes32Data);
        bytes[] memory b = parseBytes(bytesData);
        bytes[] memory c = parseUint(uintData);
        t[0] = a[0];
        t[1] = a[1];
        t[2] = encodeAddress(coinbase);
        t[3] = a[2];
        t[4] = a[3];
        t[5] = a[4];
        t[6] = b[0];
        t[7] = c[0];
        t[8] = c[1];
        t[9] = c[2];
        t[10] = c[3];
        t[11] = c[4];
        t[12] = b[1];
        t[13] = a[5];
        t[14] = b[2];
        t[15] = c[5];
        return encodeList(t);
    }

    function rlpBlockPay(bytes32[] memory bytes32Data, address coinbase, bytes[] memory bytesData, uint256[]  memory uintData) external returns (bytes memory){
        bytes[] memory t = new bytes[](16);
        bytes[] memory a = parseBytes32(bytes32Data);
        bytes[] memory b = parseBytes(bytesData);
        bytes[] memory c = parseUint(uintData);
        t[0] = a[0];
        t[1] = a[1];
        t[2] = encodeAddress(coinbase);
        t[3] = a[2];
        t[4] = a[3];
        t[5] = a[4];
        t[6] = b[0];
        t[7] = c[0];
        t[8] = c[1];
        t[9] = c[2];
        t[10] = c[3];
        t[11] = c[4];
        t[12] = b[1];
        t[13] = a[5];
        t[14] = b[2];
        t[15] = c[5];
        index++;
        return encodeList(t);
    }


    function parseBytes32(bytes32[] memory bytes32Data) internal pure returns (bytes[] memory){
        bytes[] memory data = new bytes[](6);
        data[0] = encodeBytes(abi.encodePacked(bytes32Data[0]));
        data[1] = encodeBytes(abi.encodePacked(bytes32Data[1]));
        data[2] = encodeBytes(abi.encodePacked(bytes32Data[2]));
        data[3] = encodeBytes(abi.encodePacked(bytes32Data[3]));
        data[4] = encodeBytes(abi.encodePacked(bytes32Data[4]));
        data[5] = encodeBytes(abi.encodePacked(bytes32Data[5]));
        return data;
    }

    function parseBytes(bytes[] memory bytesData) internal pure returns (bytes[] memory){
        bytes[] memory data = new bytes[](3);
        data[0] = encodeBytes(bytesData[0]);
        data[1] = encodeBytes(bytesData[1]);
        data[2] = encodeBytes(bytesData[2]);
        return data;
    }


    function parseUint(uint256[]  memory uintData) internal pure returns (bytes[] memory){
        bytes[] memory data = new bytes[](7);
        data[0] = encodeUint((uintData[0]));
        data[1] = encodeUint((uintData[1]));
        data[2] = encodeUint((uintData[2]));
        data[3] = encodeUint((uintData[3]));
        data[4] = encodeUint((uintData[4]));
        data[5] = encodeUint((uintData[5]));
        return data;
    }



    /**
     * @dev RLP encodes a byte string.
     * @param self The byte string to encode.
     * @return The RLP encoded string in bytes.
     */
    function encodeBytes(bytes memory self) internal pure returns (bytes memory) {
        bytes memory encoded;
        if (self.length == 1 && uint8(self[0]) < 128) {
            encoded = self;
        } else {
            encoded = concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

    /**
     * @dev RLP encodes a list of RLP encoded byte byte strings.
     * @param self The list of RLP encoded byte strings.
     * @return The RLP encoded list of items in bytes.
     */
    function encodeList(bytes[] memory self) internal pure returns (bytes memory) {
        bytes memory list = flatten(self);
        return concat(encodeLength(list.length, 192), list);
    }

    /**
     * @dev RLP encodes a string.
     * @param self The string to encode.
     * @return The RLP encoded string in bytes.
     */
    function encodeString(string memory self) internal pure returns (bytes memory) {
        return encodeBytes(bytes(self));
    }

    /**
     * @dev RLP encodes an address.
     * @param self The address to encode.
     * @return The RLP encoded address in bytes.
     */
    function encodeAddress(address self) internal pure returns (bytes memory) {
        bytes memory inputBytes;
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, self))
            mstore(0x40, add(m, 52))
            inputBytes := m
        }
        return encodeBytes(inputBytes);
    }

    /**
     * @dev RLP encodes a uint.
     * @param self The uint to encode.
     * @return The RLP encoded uint in bytes.
     */
    function encodeUint(uint self) internal pure returns (bytes memory) {
        return encodeBytes(toBinary(self));
    }

    /**
     * @dev RLP encodes an int.
     * @param self The int to encode.
     * @return The RLP encoded int in bytes.
     */
    function encodeInt(int self) internal pure returns (bytes memory) {
        return encodeUint(uint(self));
    }

    /**
     * @dev RLP encodes a bool.
     * @param self The bool to encode.
     * @return The RLP encoded bool in bytes.
     */
    function encodeBool(bool self) internal pure returns (bytes memory) {
        bytes memory encoded = new bytes(1);
        encoded[0] = (self ? bytes1(0x01) : bytes1(0x80));
        return encoded;
    }


    /*
     * Private functions
     */

    /**
     * @dev Encode the first byte, followed by the `len` in binary form if `length` is more than 55.
     * @param len The length of the string or the payload.
     * @param offset 128 if item is string, 192 if item is list.
     * @return RLP encoded bytes.
     */
    function encodeLength(uint len, uint offset) private pure returns (bytes memory) {
        bytes memory encoded;
        if (len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes32(len + offset)[31];
        } else {
            uint lenLen;
            uint i = 1;
            while (len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes32(lenLen + offset + 55)[31];
            for (i = 1; i <= lenLen; i++) {
                encoded[i] = bytes32((len / (256 ** (lenLen - i))) % 256)[31];
            }
        }
        return encoded;
    }

    /**
     * @dev Encode integer in big endian binary form with no leading zeroes.
     * @notice TODO: This should be optimized with assembly to save gas costs.
     * @param _x The integer to encode.
     * @return RLP encoded bytes.
     */
    function toBinary(uint _x) private pure returns (bytes memory) {
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), _x)
        }
        uint i;
        for (i = 0; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        bytes memory res = new bytes(32 - i);
        for (uint j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }
        return res;
    }

    /**
     * @dev Copies a piece of memory to another location.
     * @notice From: https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol.
     * @param _dest Destination location.
     * @param _src Source location.
     * @param _len Length of memory to copy.
     */
    function memcpy(uint _dest, uint _src, uint _len) private pure {
        uint dest = _dest;
        uint src = _src;
        uint len = _len;

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /**
     * @dev Flattens a list of byte strings into one byte string.
     * @notice From: https://github.com/sammayo/solidity-rlp-encoder/blob/master/RLPEncode.sol.
     * @param _list List of byte strings to flatten.
     * @return The flattened byte string.
     */
    function flatten(bytes[] memory _list) private pure returns (bytes memory) {
        if (_list.length == 0) {
            return new bytes(0);
        }

        uint len;
        uint i;
        for (i = 0; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint flattenedPtr;
        assembly {flattenedPtr := add(flattened, 0x20)}

        for (i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];

            uint listPtr;
            assembly {listPtr := add(item, 0x20)}

            memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }

        return flattened;
    }

    /**
     * @dev Concatenates two bytes.
     * @notice From: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol.
     * @param _preBytes First byte string.
     * @param _postBytes Second byte string.
     * @return Both byte string combined.
     */
    function concat(bytes memory _preBytes, bytes memory _postBytes) private pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31)
            ))
        }

        return tempBytes;
    }
}