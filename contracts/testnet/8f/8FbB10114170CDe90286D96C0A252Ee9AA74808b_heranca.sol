/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: GPL-3.0

 pragma solidity 0.8.16;

 contract heranca {

     mapping(string => uint) valorAReceber;
     address public owner = msg.sender;

     function escreveValor(string memory _nome, uint valor) public {
         require(msg.sender == owner);
         valorAReceber[_nome] = valor;
     }

     function pegaValor(string memory _nome) public view returns(uint) {
         return valorAReceber[_nome];
     }

 }