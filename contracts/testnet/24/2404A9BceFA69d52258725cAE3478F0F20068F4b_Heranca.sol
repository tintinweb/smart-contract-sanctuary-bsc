/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {

    mapping(string => uint) public valorareceber;
    
    function escrevavalor(string memory _nome, uint valor) public {
valorareceber[_nome] = valor;

    }

    function pegavalor(string memory _nome) public view returns (uint) {

        return valorareceber [_nome];



    }
    

}