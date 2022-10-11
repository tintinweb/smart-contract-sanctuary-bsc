/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
/** 
 *  SourceUnit: /Users/vuong/Documents/Ekoios/DA-NFT-Fractional/DA_FractionalNFT_Contract/contracts/nft-fractional/SignatureUtils.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

interface ISignatureUtils {
    function getMessageHash(uint256 poolId,uint256 amount, uint256 nonce, uint256 typeSignature,address sender) external returns (bytes32);
    function getEthSignedMessageHash(bytes32 _messageHash) external returns (bytes32);
    function verify(uint256 poolId,uint256 amount, uint256 nonce,uint256 typeSignature, address sender,address signer,bytes memory signature) external returns (bool);
    function recoverSigner(bytes32 hash, bytes memory signature) external returns (address);
}

/** 
 *  SourceUnit: /Users/vuong/Documents/Ekoios/DA-NFT-Fractional/DA_FractionalNFT_Contract/contracts/nft-fractional/SignatureUtils.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "./ISignatureUtils.sol";
contract SignatureUtils is ISignatureUtils{
    function getMessageHash( 
        uint256 poolId,
        uint256 amount,
        uint256 nonce,
        uint256 typeSignature,
        address sender
    ) public override pure returns (bytes32) {
        return keccak256(abi.encodePacked(poolId, amount,nonce,typeSignature,sender));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        override
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

    function verify(
        uint256 poolId,
        uint256 amount,
        uint256 nonce,
        uint256 typeSignature,
        address sender,
        address signer,
        bytes memory signature
    ) public override pure returns (bool) {
        bytes32 messageHash = getMessageHash(
            poolId,
            amount,
            nonce,
            typeSignature,
            sender
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        public
        override
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }
}