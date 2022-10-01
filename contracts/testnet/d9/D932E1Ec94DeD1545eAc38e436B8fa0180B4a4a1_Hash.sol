/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hash {

    bytes32[] public registros;

    function recebeTexto(string memory texto) public pure returns(bytes32){
        return sha256(bytes(texto));
    } 

    function recebeHash(bytes32 hash) public returns(uint){
        registros.push(hash);
        return registros.length - 1;
    } 
}