/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract EjemploContrato {
    struct Tarea {
        uint id;
        string nombre;
        string descripcion;
    }
    
    Tarea[] ArrTareas;
    uint nextId;

    function crearTarea (string memory _nombre, string memory _descripcion) public {
        ArrTareas.push(Tarea(nextId, _nombre, _descripcion));
        nextId++;
    }

    function findIndexTarea(uint _id) internal view returns(uint){
        for (uint i = 0; i < ArrTareas.length; i++){
            if (ArrTareas[i].id == _id){
                return i;
            }
        }
        revert("Tarea no encontrada");
    }

    function leerTarea(uint _id) public view returns (uint, string memory, string memory) {
            uint index = findIndexTarea(_id);
            return (ArrTareas[index].id, ArrTareas[index].nombre, ArrTareas[index].descripcion);
    }

    function updateTarea(uint _id, string memory _nombre, string memory _descripcion) public {
        uint index =  findIndexTarea(_id);
        ArrTareas[index].nombre = _nombre;
        ArrTareas[index].descripcion = _descripcion;
    }

    function deleteTarea(uint _id) public {
        uint index = findIndexTarea(_id);
        delete ArrTareas[index];
    }


}