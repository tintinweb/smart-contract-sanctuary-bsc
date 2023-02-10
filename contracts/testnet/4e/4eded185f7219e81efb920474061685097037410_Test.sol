/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Test {
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public TYPE_HASH;

    struct Data {
        bytes32 digest;
        address signer; 
    }

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f, // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Web3ShotPassportLevel")),
                0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6, // keccak256(bytes("1")) for versionId = 1,
                chainId,
                address(this)
            )
        );
        TYPE_HASH = keccak256("PassportLevelUp(uint256 tokenId,uint256 learningPoints,bool connexProfile,uint256 connexConnections)");
    }

    function setPassportLevelByUser(
        uint256 tokenId,
        uint256 learningPoints,
        bool connexProfile,
        uint256 connexConnections,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (Data memory) {
        // check signature
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TYPE_HASH, tokenId, learningPoints, connexProfile, connexConnections))
            )
        );
        address signer = ecrecover(digest, v, r, s);
        return Data(digest, signer);
    }
}