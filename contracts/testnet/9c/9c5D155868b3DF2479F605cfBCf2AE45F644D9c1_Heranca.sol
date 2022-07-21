/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {

    mapping(string => uint) valorAReceber;

    function escreveValor(string memory _nome, uint valor) public {
        valorAReceber[_nome] = valor;

    }

    //visibilidade: public, private, external, internal
    function pegaValor(string memory _nome) public view returns (uint) {

        return valorAReceber[_nome];

    }

}