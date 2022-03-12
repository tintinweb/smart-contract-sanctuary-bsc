/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Escribir{
    string texto;

//calldata: variable que proviene de la funcion
    function setTexto(string calldata _texto) public {
        texto = _texto;
    }

//view: funcion que no modifica información 'GET'
//memory: almacenado en memoria
    function getTexto() public view returns(string memory) {
        return texto;
    }
}