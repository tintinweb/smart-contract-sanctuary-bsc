// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library ECDSAOffsetRecovery {
    function getSetMinQuorumHash(uint256 proposalIndex, uint256 quorum)
        public
        pure
        returns (bytes32 signature)
    {
        bytes32 newHash = keccak256(abi.encodePacked(proposalIndex, quorum));
        return newHash;
    }

    function getDeleteOwnerHash(uint256 proposalIndex, address owner)
        public
        pure
        returns (bytes32 signature)
    {
        bytes32 newHash = keccak256(abi.encodePacked(proposalIndex, owner));
        return newHash;
    }

    function getChangeOwnerWeightHash(
        uint256 proposalIndex,
        address owner,
        bool weight
    ) public pure returns (bytes32 signature) {
        bytes32 newHash = keccak256(
            abi.encodePacked(proposalIndex, owner, weight)
        );
        return newHash;
    }

    function getAddOwnerHash(
        uint256 proposalIndex,
        address owner,
        bool weight
    ) public pure returns (bytes32 signature) {
        bytes32 newHash = keccak256(
            abi.encodePacked(proposalIndex, owner, weight)
        );
        return newHash;
    }

    function getSwitchTokenHash(
        uint256 proposalIndex,
        address token,
        bool enableStatus,
        address[] memory tokenToUSdPath
    ) public pure returns (bytes32 signature) {
        bytes32 newHash = keccak256(
            abi.encodePacked(proposalIndex, token, enableStatus, tokenToUSdPath)
        );
        return newHash;
    }

    function toEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function ecOffsetRecover(
        bytes32 hash,
        bytes memory signature,
        uint256 offset
    ) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Divide the signature in r, s and v variables with inline assembly.
        assembly {
            r := mload(add(signature, add(offset, 0x20)))
            s := mload(add(signature, add(offset, 0x40)))
            v := byte(0, mload(add(signature, add(offset, 0x60))))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        }

        // bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        // hash = keccak256(abi.encodePacked(prefix, hash));
        // solium-disable-next-line arg-overflow
        return ecrecover(toEthSignedMessageHash(hash), v, r, s);
    }
}