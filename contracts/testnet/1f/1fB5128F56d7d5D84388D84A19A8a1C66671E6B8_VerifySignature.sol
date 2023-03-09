/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// File: coupons/Coupons.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract VerifySignature {

    // 1. PRIMERO GENERAMOS EL NUMERO RANDOM CodId del generador del HASH

    function generateRandomNumber()
        public
        view
        returns (uint256)
    {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return seed;
    } 

    // 2. GENERAMOS EL HASH USANDO EL CODIGO RANDOM OBTENIDO
    
    function getMessageHash(

        uint256 codeId,
        address beneficiary,
        uint256 giftAmount,
        uint256 directPay
      
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(codeId, beneficiary, giftAmount, directPay));
    }



    // 3. AQUI FIRMO CON LA BILLETERA EL Hash que devolvió getMessageHash

     /* 3. Sign message hash
    # using browser
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    DEVUELVE Signature will be different for different accounts
    EJEMPLO: 0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */

    
    // 4. HAGO split de la firma generada en la  función splitSignature

    function splitSignature(
        bytes memory signature
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, "invalid signature length");

        assembly {

            v := byte(0, mload(add(signature, 96)))
           
            r := mload(add(signature, 32))
           
            s := mload(add(signature, 64))
           
            
        }

    }


    // 5. Y POR ULTIMO VERIFICO TODO EN LA FUNCION verifyGiftCertificate

    function verifyGiftCertificate(
       
        uint256 codeId,
        address beneficiary,
        uint256 giftAmount,
        uint256 directPay,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address signer
        

    ) public pure returns (bool) {
        bytes32 messageHash =  keccak256(abi.encodePacked(codeId, beneficiary, giftAmount, directPay));
        bytes32 ethSignedMessageHash =  keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        return ecrecover(ethSignedMessageHash, v, r, s) == signer;
    }


    
}