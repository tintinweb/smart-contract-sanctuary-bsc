/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.8.7;

contract Bytecode {

    uint public valor;

    constructor() {
        valor = 20;
    }

    function setValor(uint _valor) public {
        valor = _valor;
    }

}