/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract ReceiverPays {

    address public manager = msg.sender;
    
    mapping(uint => bool) usedNonces;

    constructor() payable {}

    function claimPayment(uint amount, uint nonce, bytes memory signature) public{

        // This recreates the message that was signed on the client.
        bytes32 hashedMessage = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, address(this))));
        
        require(!usedNonces[nonce], 'nonce already used');
        usedNonces[nonce] = true;

        require(recoverSigner(hashedMessage, signature) == manager, 'not signed by manager');
        payable(msg.sender).transfer(amount);

    }

    //allow contract to recieve ether from EOA or other contract
    receive () payable external  {}

    //destroy contract and reclaim leftover funds on the contract.
    function kill() public{
        require(msg.sender == manager, 'manager only');
        selfdestruct(payable(msg.sender));
    }

    //signature method
    function splitSignature(bytes memory sig) internal pure returns(uint8, bytes32, bytes32){
        require(sig.length == 65, 'invalid signature length');
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly{
            //first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            //second 32 bytes
            s := mload(add(sig, 64))
            //final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address){
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    //build a prefixed hash to mimic the behavior of eth_sign
    function prefixed(bytes32 hash) internal pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function append(string memory a, string memory b, string memory  c) internal pure returns (string memory) 
    {
        return string(abi.encodePacked(a, b, c));
    }
}