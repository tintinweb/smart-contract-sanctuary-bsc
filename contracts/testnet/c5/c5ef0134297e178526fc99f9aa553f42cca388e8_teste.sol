/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract teste{
    uint public num = 10;

    function alteraValor(uint _valor) public {
        num = _valor;
    }
}