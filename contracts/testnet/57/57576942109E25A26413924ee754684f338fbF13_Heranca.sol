/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {
        
    mapping(string => uint) valorAReceber;


    function writeValue(string memory _name, uint valor) public {
        valorAReceber[_name] = valor;
    }

    

    function pegaValor(string memory _name) public view returns (uint) {

         return valorAReceber[_name];

    }

}