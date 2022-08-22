/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract heranca{

    //Variáveis de estado
    mapping (string => uint) ValoraReceber;
    address public owner = msg.sender;

    //Valor, uint, int, uint56, uint8, uint6..., bool,address
    //referencia, string, mapping, array,struct...
    // msg.sender = quem chamou o contrato

    function entre_com_valor(string memory _nome, uint valor) public{
        require(msg.sender == owner);
        ValoraReceber[_nome] = valor;
       
    }

    //visibilidade: public, private, external, internal
    function PegaValor(string memory _nome)public view returns (uint){
            return ValoraReceber[_nome];
    }

}