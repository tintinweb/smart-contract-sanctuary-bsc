/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity ^0.8.0;

contract Herenca {

mapping (string => uint) valorAReceber;
address public owner = msg.sender;

function escreverValor(string memory nome, uint valor) public {
require(msg.sender == owner);
valorAReceber[nome] = valor;

}

function getValue (string memory _nome) public view returns (uint) {

return valorAReceber[_nome];

}


}