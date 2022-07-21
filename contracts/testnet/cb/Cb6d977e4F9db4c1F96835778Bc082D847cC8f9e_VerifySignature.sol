/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract VerifySignature
{
    address Auth=0x06573d15e3367D7b4a0Cb0668aEef3E2Dc074003;
    

     function getMessageHashUser(string memory _message) private pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked(_message));
    }
    function getMessageHashAuth(string memory _messageAuth) private view returns (bytes32) 
    {
        require(msg.sender==Auth, "not a valid user");
        getMessageHashUser(_messageAuth); 
        return keccak256(abi.encodePacked(_messageAuth));
    }
    

    function getEthSignedMessageHash(bytes32 _messageHash)public pure returns (bytes32)
    {    
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(address _signer,string memory _message,bytes memory signature) public pure returns (bool) 
    {
        bytes32 messageHash = getMessageHashUser( _message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
       
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r,bytes32 s,uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly 
        {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
}