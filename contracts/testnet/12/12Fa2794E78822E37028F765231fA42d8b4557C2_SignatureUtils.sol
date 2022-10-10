// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Signature Verification
contract SignatureUtils {
    // Using Openzeppelin ECDSA cryptography library
    function getMessageHash(
        string memory _internalTx,
        address receiver_,
        uint256 amount_
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_internalTx, receiver_, amount_));
    }

    // Verify signature function
    function verify(
        address _signer,
        string memory _internalTx,
        address receiver_,
        uint256 amount_,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_internalTx,receiver_, amount_);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s) == _signer;
    }


    // Split signature to r, s, v
    function splitSignature(bytes memory _signature)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_signature.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );

    }
}