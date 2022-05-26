/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Registro{
          
    struct datos 
    {
        string nombre;
        string apellido;
        uint8 edad;
    }
    mapping(address => datos) private registro;
    mapping(address => bool) private ifregister;
    event Register(address indexed from, datos value);


    function registrar(string memory nombre, string memory apellido, uint8 edad) public{
        require(!ifregister[msg.sender] , "Usuario ya registrado");
        datos memory data;
        data.nombre = nombre;
        data.apellido = apellido;
        data.edad = edad;
        registro[msg.sender] = data;
        ifregister[msg.sender] = true;
        emit Register(msg.sender, data);
    }

    function verData() public view returns(string memory, string memory, uint8) {
        datos memory data = registro[msg.sender];
        return (data.nombre, data.apellido, data.edad);
    }
    
   /** 
   
   function funcpure() public{
        int a;
        a = 10 + 10;
    }
    function funcview() public{
        datos memory a = registro[msg.sender];
    }
    */
}