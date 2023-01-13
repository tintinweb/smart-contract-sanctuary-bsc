/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Heranca {
    mapping (string => uint) valorAReceber;

    function escreveValor(string memory _nome, uint valor) public {
        valorAReceber[_nome] = valor;
        
    }

    function pegaValor(string memory _nome) public view returns (uint) {

        return valorAReceber[_nome];
    }



}