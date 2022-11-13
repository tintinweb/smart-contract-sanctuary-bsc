/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

pragma solidity ^0.8.4;

contract MyContract {


    string nome;

    constructor() public{
        nome = "fabio";
    }

    function setName(string memory _nome) public {
        nome = _nome;
    }

    function getNome() public view returns(string memory){

        return nome;

    }



}