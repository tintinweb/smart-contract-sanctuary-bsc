/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

pragma solidity ^0.8.0;

contract Herenca {

mapping (string => uint) valorAReceber;

function escreverValor(string memory nome, uint valor) public {

valorAReceber[nome] = valor;

}

function getValue (string memory _nome) public view returns (uint) {

return valorAReceber[_nome];

}


}