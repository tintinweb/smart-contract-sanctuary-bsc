/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.8.0;

contract Heranca {
    mapping(string=>uint) valores;

    function addValor(string memory _nome, uint _valor) public {
        valores[_nome] = _valor;
    }

    function pegaValor(string memory _nome) public view returns(uint) {
        return valores[_nome];
    }
}