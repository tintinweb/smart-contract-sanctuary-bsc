//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract DelegationHandler {
    bytes public constant PREFIX = "\x19Ethereum Signed Message:\n";

    // nonce[msg.sender][account]
    mapping(address => mapping(address => uint256)) public nonce;

    function increaseNonce(address account) public {
        nonce[msg.sender][account]++;
    }

    function getMessageHash(address contractAddress, address account, bytes32 hashedValues)
        public
        view
        returns (bytes32)
    {
        uint256 account_nonce = nonce[contractAddress][account];
        return keccak256(abi.encodePacked(hashedValues, account_nonce));
    }

    function reconstruct(bytes32 signedHash)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(PREFIX, "32", signedHash);
    }

    function recoverAddress(
        bytes32 signedHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        bytes32 prefixedHash = keccak256(reconstruct(signedHash));

        return ecrecover(prefixedHash, v, r, s);
    }

    function verifyByAddr(
        address _signer,
        bytes32 hashValue,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (bool) {
        return recoverAddress(hashValue, v, r, s) == _signer;
    }

    function verifyAndIncrement(
        address addr,
        bytes32 hashValue,
        address signer,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(verifyByAddr(signer, hashValue, v, r, s), "DelegationHandler: signature verification failed");

        increaseNonce(addr);
    }
}