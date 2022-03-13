/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {
//0xED47772df39606C4443B40D5c4D1E536bE74377E
//0xc2De53B565887ba4d2951DD1EE5Dfa12ecaD150D

    mapping(string => uint) valorAReceber;
    address public owner = msg.sender;

    function escreveValor(string memory _nome, uint valor) public{
        require(msg.sender == owner);
        valorAReceber[_nome] = valor;
    }

    function pegaValor(string memory _nome) public view returns (uint) {
        return  valorAReceber[_nome];
    }
}