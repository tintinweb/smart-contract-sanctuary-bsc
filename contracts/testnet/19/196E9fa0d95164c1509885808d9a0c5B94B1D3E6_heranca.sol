/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract heranca {
    mapping (string => uint) valorAReceber;
    
    address public owner = msg.sender;

    function escrevevalor(string memory _nome, uint valor) public {
        require(msg.sender == owner); 
        valorAReceber [_nome] = valor;
    }

    function pegavalor (string memory _nome) public view returns (uint) {

        return valorAReceber[_nome];
    }




}