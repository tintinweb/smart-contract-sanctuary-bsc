/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

pragma solidity ^0.8.7;

contract Kmik{
    string public usuario;
    string public gasusado;
    function EntaKmikZE(string memory usu) public{
        usuario = usu;
    }

    function myWallet() public view returns(address){
        return msg.sender;
    }

    function kmikze_in(string memory name) public{
        usuario = name;
    }

    function setgas(string memory gas_) public{
        gasusado = gas_;
    }
}