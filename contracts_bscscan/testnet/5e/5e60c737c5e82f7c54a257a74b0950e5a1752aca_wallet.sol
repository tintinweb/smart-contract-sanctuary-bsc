/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.3;

contract wallet{

// Vamos a  crear una simple wallet la cual va recibir fondos, transferir , y que solo el owner pueda retirar
// divirtamonos :), hagamoos funciones extra

address  payable public OwnerOfWallet;

constructor()payable{
    OwnerOfWallet=payable(msg.sender); 
}
// Ahora hagamos la funcion para recibir ethereum , de forma indirecta
receive()external payable{}

// Haremos una funcion para transferir del contrato al owner, luego otra extra que trasnfiera todo..
// Adicional vamos a crear un modifier de onlyOwner para que solo el dev la ejecute

modifier onlyOwner{
    require(msg.sender == OwnerOfWallet,"You are not the owner of the wallet");
    _;
}   
 // Funcion para transferir del contrato a owner, por ello carece de payable
function transferirOwner(uint amountToSend)public{
    OwnerOfWallet.transfer(amountToSend);
}
// Funcion para obtener el balance
function getBalance()public view returns(uint){ 
    return address(this).balance; 
}
//Funcion para enviar de una persona a otro sin tocar el dinero del contrato 
function sendToAnyone(address payable to)public payable{ // El payable hace que la persona introduzca y no tenga que ver con el contrato
(bool success)= to.send(msg.value);
require(success, " Your transaction failed bitch"); 

}
// Funcion para transferir todo el dinero del contrato al owner
function transferAll()public onlyOwner{

    OwnerOfWallet.transfer(address(this).balance);
}
//Funcion para depositar

function deposit()public payable{}

}