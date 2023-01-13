/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract Inversiones {

    struct InformacionSobreInversion {
        int id;
        string nombre;
        int valor;
        string fecha; // '13-01-2023'
        // uint256 fechaUNIX; // numero de segundos que han pasado desde 1 de enero de 1970
        // 1673566200 segundos desde 1 de enero de 1970 hasta 13-01-2023 00:30 UTC
        string descripcion;
    }

    InformacionSobreInversion[] todasInversiones;
    // Mapeo de identificador de la inversion al dato completo
    mapping(int => InformacionSobreInversion) datos;

    constructor() {}

    function InsertarDatoNuevoEnListado(
        int id, 
        string memory nombre, 
        int valor, 
        string memory fecha, 
        string memory descipcion) 
        public {

        // Insertar en el listado un nuevo dato
        todasInversiones.push(
            InformacionSobreInversion(
                id,
                nombre,
                valor,
                fecha,
                descipcion)
        );

        datos[id] = todasInversiones[todasInversiones.length - 1];
    }

    function LeerInformacionSobreInversion(int id) 
        public 
        view 
        returns(InformacionSobreInversion memory) {
        // Devuelve informacion sobre la inversion segun el identificador pasado
        return datos[id];
    }

}