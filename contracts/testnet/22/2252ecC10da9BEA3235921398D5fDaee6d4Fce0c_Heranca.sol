/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// https://testnet.bscscan.com/
// https://remix-ide.readthedocs.io/en/latest/create_deploy.html
// https://academy.binance.com/pt/articles/connecting-metamask-to-binance-smart-chain

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {

    mapping(string => uint) valorAReceber;

    function escreveValor(string memory _nome, uint _valor) public {
        valorAReceber[_nome] = _valor;
    }

    // Visibilidade: public, private, external, internal
    function pegaValor(string memory _nome) public view returns(uint) {
        return valorAReceber[_nome];
    }

}