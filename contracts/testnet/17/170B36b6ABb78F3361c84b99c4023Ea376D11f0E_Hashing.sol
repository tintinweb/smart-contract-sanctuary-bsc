// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Base64 {

    bytes constant private base64stdchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    bytes constant private base64urlchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=";
                                            
    function encode(string memory _str) internal pure returns (string memory) {
        uint i = 0;                                 // Counters & runners
        uint j = 0;

        uint padlen = bytes(_str).length;           // Lenght of the input string "padded" to next multiple of 3
        if (padlen%3 != 0) padlen+=(3-(padlen%3));

        bytes memory _bs = bytes(_str);
        bytes memory _ms = new bytes(padlen);       // extra "padded" bytes in _ms are zero by default
        // copy the string
        for (i=0; i<_bs.length; i++) {              // _ms = input string + zero padding
            _ms[i] = _bs[i];
        }
 
        uint res_length = (padlen/3) * 4;           // compute the length of the resulting string = 4/3 of input
        bytes memory res = new bytes(res_length);   // create the result string

        for (i=0; i < padlen; i+=3) {
            uint c0 = uint(uint8(_ms[i])) >> 2;
            uint c1 = (uint(uint8(_ms[i])) & 3) << 4 |  uint(uint8(_ms[i+1])) >> 4;
            uint c2 = (uint(uint8(_ms[i+1])) & 15) << 2 | uint(uint8(_ms[i+2])) >> 6;
            uint c3 = (uint(uint8(_ms[i+2])) & 63);

            res[j]   = base64urlchars[c0];
            res[j+1] = base64urlchars[c1];
            res[j+2] = base64urlchars[c2];
            res[j+3] = base64urlchars[c3];

            j += 4;
        }

        // Adjust trailing empty values
        if ((padlen - bytes(_str).length) >= 1) { res[j-1] = base64urlchars[64];}
        if ((padlen - bytes(_str).length) >= 2) { res[j-2] = base64urlchars[64];}
        return string(res);
    }


    function decode(string memory _str) internal pure returns (string memory) {
        require( (bytes(_str).length % 4) == 0, "Length not multiple of 4");
        bytes memory _bs = bytes(_str);

        uint i = 0;
        uint j = 0;
        uint dec_length = (_bs.length/4) * 3;
        bytes memory dec = new bytes(dec_length);

        for (; i< _bs.length; i+=4 ) {
            (dec[j], dec[j+1], dec[j+2]) = dencode4(
                bytes1(_bs[i]),
                bytes1(_bs[i+1]),
                bytes1(_bs[i+2]),
                bytes1(_bs[i+3])
            );
            j += 3;
        }
        while (dec[--j]==0)
            {}

        bytes memory res = new bytes(j+1);
        for (i=0; i<=j;i++)
            res[i] = dec[i];

        return string(res);
    }


    function dencode4 (bytes1 b0, bytes1 b1, bytes1 b2, bytes1 b3) private pure returns (bytes1 a0, bytes1 a1, bytes1 a2)
    {
        uint pos0 = charpos(b0);
        uint pos1 = charpos(b1);
        uint pos2 = charpos(b2)%64;
        uint pos3 = charpos(b3)%64;

        a0 = bytes1(uint8(( pos0 << 2 | pos1 >> 4 )));
        a1 = bytes1(uint8(( (pos1&15)<<4 | pos2 >> 2)));
        a2 = bytes1(uint8(( (pos2&3)<<6 | pos3 )));
    }

    function charpos(bytes1 char) private pure returns (uint pos) {
        for (; base64urlchars[pos] != char; pos++) 
            {}    //for loop body is not necessary
        require (base64urlchars[pos]==char, "Illegal char in string");
        return pos;
    }

}



contract Hashing {

     constructor() {}

    function encode(uint256 timestamp, string memory input, address addr) public pure returns (bytes memory) {
        return abi.encode(timestamp, input, addr);
    }

    function decode(bytes memory hash) public pure returns (uint256, string memory, address) {

        (uint timestamp, string memory input, address addr) = abi.decode(hash, (uint256, string, address));
        return (timestamp, input, addr);
    }

    function b64encode(string memory _str) public pure returns (string memory) {
        return Base64.encode(_str);
    }

    function b64decode(string memory _str) public pure returns (string memory) {
        return Base64.decode(_str);
    }

    function b64toHex(bytes memory hash) public pure returns (bytes memory) {
        return toHex(hash);
    }

    function b64fromHex(bytes memory hash) public pure returns (bytes memory) {
        return fromHex(hash);
    }

    function toHex(bytes memory data) public pure returns(bytes memory res) {
        res = new bytes(data.length * 2);
        bytes memory alphabet = "0123456789abcdef";
        for (uint i = 0; i < data.length; i++) {
            res[i*2 + 0] = alphabet[uint256(uint8(data[i])) >> 4];
            res[i*2 + 1] = alphabet[uint256(uint8(data[i])) & 15];
        }
    }

    // Convert an hexadecimal character to their value
    function fromHexChar(uint8 c) public pure returns (uint8) {
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            return c - uint8(bytes1('0'));
        }
        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            return 10 + c - uint8(bytes1('a'));
        }
        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            return 10 + c - uint8(bytes1('A'));
        }
        revert("fail");
    }

    // Convert an hexadecimal string to raw bytes
    function fromHex(bytes memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }
        return r;
    }

}