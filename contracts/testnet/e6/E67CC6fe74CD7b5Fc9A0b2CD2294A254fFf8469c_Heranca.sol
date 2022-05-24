/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca{

    mapping (string => uint ) public valorAReceber;

    function escrevervalor(string memory _nome, uint valor) public{
        valorAReceber [_nome] = valor;
    }



}