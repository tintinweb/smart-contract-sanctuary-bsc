/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

//SPDX-License-Identifier: MIT;

pragma solidity >=0.7.0 <0.8.0;

contract HolaBlock{

    string texto;

    function escribir(string calldata _texto) public{
        texto = _texto;
    }

    function leer() public view returns(string memory){
        return texto;
    }

}