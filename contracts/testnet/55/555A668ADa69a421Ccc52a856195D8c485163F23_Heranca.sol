/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Heranca{

    mapping(string => uint) public valorAReceber;
    //address é um tipo de variável que guarda um endereço 
    //msg.sender é aquele que faz a transação - que invocou o contrato
    address public owner = msg.sender; //O criador do contrato vai ser o owner
    //owner = 0x720b6754e1A5eE872179046Ac446a90Fa108E871
    //contrato criado: 0x555A668ADa69a421Ccc52a856195D8c485163F23

    function escreveValor(string memory _nome, uint valor) public{
        require(msg.sender == owner); //requeiro que seja só o owner a mandar transação (escrever algo no contrato)
        valorAReceber[_nome] = valor;
    }

    // visibilidade: public, private, external, internal
    function pegaValor(string memory _nome) public view returns(uint){
        return valorAReceber[_nome];
    }
}