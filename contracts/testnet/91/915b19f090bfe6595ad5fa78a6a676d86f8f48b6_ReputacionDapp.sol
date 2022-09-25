/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
//Creacion del token ERC-20 kamikaze en la blockchain de ethereum (luego lo pasamos a otra), este token tiene objetivos de especulacion.
//Contratos para Airbnb decentralizado (varios)

pragma solidity ^0.8.0;


contract ReputacionDapp {

    struct DatosDeCuentas {
        string Mensajes;
        uint TiempoDePublicacion;
    }

    address[] public addresses;

    mapping(address => DatosDeCuentas) DireccionDeUsuarioYMapping;
    address[] public instructorArray;


    function PostearMensaje(string calldata _mensaje) public {
        DireccionDeUsuarioYMapping[msg.sender].Mensajes = _mensaje;
        DireccionDeUsuarioYMapping[msg.sender].TiempoDePublicacion = block.timestamp;
    }


    function VerMensajes() public view returns(address[] memory){
        return(instructorArray);
    }


}