/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Heranca {
    // 0xab4D4Ae231C99fd2c6bA8F1a8c49d06ac9b596E3

    mapping(string => uint) public valorAReceber;

    // address é um tipo de variável
    address public owner = msg.sender;


    function escreveValor(string memory _nome, uint valor) public{

        require(msg.sender == owner);
        valorAReceber[_nome] = valor;
    }

    // visibilidade: public, private, external and internal
    // modifiers: view

    function pegarValor(string memory _nome) public view returns(uint){
        return valorAReceber[_nome];
    }

}