/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;

contract Heranca{

    mapping (string => uint) valoraReceber;

    function escreveValo(string memory _nome, uint valor)public{

        valoraReceber[_nome] = valor;

    }
    
    function pegarValor(string memory _nome)public view returns(uint){
        return valoraReceber[_nome];
    }

}