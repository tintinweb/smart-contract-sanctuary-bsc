/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract heranca {

    mapping(string => uint) valorAReceber;
    address public owner = msg.sender;

    function escreveValor(string memory _nome, uint valor) public {
        require(msg.sender == owner);
        valorAReceber [_nome] = valor;
    }

    //visibilidade: public, private, external, internal
    //modificadores: view
    function pegaValor(string memory _nome) public view returns (uint) {

        return valorAReceber [_nome];

    }


}