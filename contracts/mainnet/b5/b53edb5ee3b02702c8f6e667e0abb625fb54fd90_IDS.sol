/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract IDS {

    address public medico;

    //Crear el constructor
    constructor(){
        medico = msg.sender;
    }

    // Mapping para relacionar los hash con los datos del paciente
    mapping (bytes32 => string) RegistrosNombre;
    mapping (bytes32 => uint) RegistrosPeso;
    mapping (bytes32 => uint) RegistrosAltura;

    // Evento
    event paciente_atendido(bytes32, string, uint, uint);

    //Función para registrar los datos de los pacientes
    function AtenderPacientes(string memory _idPaciente, string memory _nombrePaciente, uint _peso, uint _altura) public UnicamenteMedico(msg.sender) {
        //Hash del paciente
        bytes32 hash_idPaciente = keccak256(abi.encodePacked(_idPaciente));
        //Relacionar el hash del paciente con sus datos
        RegistrosNombre[hash_idPaciente] = _nombrePaciente;
        RegistrosPeso[hash_idPaciente] = _peso;
        RegistrosAltura[hash_idPaciente] = _altura;

        emit paciente_atendido(hash_idPaciente, _nombrePaciente, _peso, _altura);
        
    }

    modifier UnicamenteMedico(address _direccion){
        require(_direccion == medico, "Solo el medico tiene permisos para crear registros de pacientes");
        _;
    }

    //Función para ver registros
    function VerRegistros(string memory _idPaciente)public view returns(bytes32, string memory, uint, uint){
        //Hash del paciente
        bytes32 hash_idPaciente = keccak256(abi.encodePacked(_idPaciente));
        //Indicadores del paciente
        string memory nombrePaciente = RegistrosNombre[hash_idPaciente];
        uint peso = RegistrosPeso[hash_idPaciente];
        uint altura = RegistrosAltura[hash_idPaciente];

        return (hash_idPaciente, nombrePaciente, peso, altura);

    }



}