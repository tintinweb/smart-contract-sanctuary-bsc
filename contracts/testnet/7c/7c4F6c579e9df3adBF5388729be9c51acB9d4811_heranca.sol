/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract heranca {

    mapping(string => uint) private valorAreceber;

    function escreveValor(string memory _nome, uint valor) public {
        valorAreceber[_nome] = valor;
    }
//visibilidade: public, private, external, internal

    function PegaValor(string memory _nome) public view returns (uint) {
        return valorAreceber [_nome];
    }

}