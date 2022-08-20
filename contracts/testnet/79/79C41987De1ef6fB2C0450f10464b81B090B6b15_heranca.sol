/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: GPL-3.0

 pragma solidity ^0.8.0;

 contract heranca {
      mapping(string => uint) valorAReceber;

      function escrevValor(string memory nome, uint valor) public {
          valorAReceber[nome] = valor;
      } 

      function mostraValor(string memory nome) public view returns(uint) {
          return valorAReceber[nome];
      }
      
}