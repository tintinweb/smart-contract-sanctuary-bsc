/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {
    
    mapping(string => uint) valorAReceber;
    address owner = msg.sender;

    function escreveValor(string memory _nome, uint valor) public {
        require(msg.sender == owner);
        valorAReceber[_nome] = valor;
    }

    function pegaValor(string memory _nome) public view returns(uint) {
        return valorAReceber[_nome];
    }

    //visibilidade: public, private, external, internal
    // function nome() (visibilidade) [modifiers] {}
}