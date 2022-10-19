/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {
// minha conta 0x37AAa267C4E733d0687D8f3Bf779c35cDed55aA4
    mapping (string => uint) valorAReceber;

    function escreveValor(string memory _nome, uint valor) public {
        valorAReceber[_nome] = valor;
    }

    function pegaValor (string memory _nome) public view returns(uint) {
        return valorAReceber[_nome];
    }
}