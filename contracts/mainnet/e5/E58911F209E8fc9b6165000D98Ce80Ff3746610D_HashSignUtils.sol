// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Strings.sol";

contract HashSignUtils {

    function hashMessage(string memory s) public pure returns (bytes32){
        return keccak256(abi.encodePacked(s));
    }

    function hashMessageToString(string memory s) public pure returns (string memory){
        return Strings.toHexString(uint256(keccak256(abi.encodePacked(s))), 32);
    }

    function verifyMessage(string memory message, bytes memory signature) public pure returns (address signer) {
        require(signature.length == 65, "wrong signature");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := and(mload(add(signature, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "wrong signature");
        return verifyMessage(hashMessage(message), v, r, s);
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }


    function verifySign(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address signer) {
        return ecrecover(_hashedMessage, _v, _r, _s);
    }

}