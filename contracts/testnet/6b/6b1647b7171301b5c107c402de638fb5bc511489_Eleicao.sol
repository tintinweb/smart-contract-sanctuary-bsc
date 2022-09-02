/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Eleicao {

    /* Endereço do dono do contrato */
    address public owner;

    /* Candidatos */
    Candidato[] public candidatos;

    /* Struct que define o candidato */
    struct Candidato {
        TipoCandidatura tipoCandidatura;
        uint codigoCandidato;
        string nomeCandidato;
        string partido;
        string foto_base64;
    }

    /* Enum que define tipo da candidatura */
    enum TipoCandidatura {
        Prefeito,
        Presidente,
        Governador,
        DeputadoMunicipal,
        DeputadoEstadual,
        DeputadoFederal,
        Senador
    }

    modifier OnlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(
        uint _tipoCandidatura,
        uint _codigo,
        string memory _nomeCandidato,
        string memory _nomePartido,
        string memory _fotoCandidato
    ) public OnlyOwner {
        require(_tipoCandidatura >= 0 && _tipoCandidatura <= 6);

        TipoCandidatura _candidaturaAux;

        if(_tipoCandidatura == 0){
            _candidaturaAux = TipoCandidatura.Prefeito;
        }
		else if(_tipoCandidatura == 1){
            _candidaturaAux = TipoCandidatura.Presidente;
        }
		else if(_tipoCandidatura == 2){
            _candidaturaAux = TipoCandidatura.Governador;
        }
		else if(_tipoCandidatura == 3){
            _candidaturaAux = TipoCandidatura.DeputadoMunicipal;
        }
		else if(_tipoCandidatura == 4){
            _candidaturaAux = TipoCandidatura.DeputadoEstadual;
        }
		else if(_tipoCandidatura == 5){
            _candidaturaAux = TipoCandidatura.DeputadoFederal;
        }
		else if(_tipoCandidatura == 6){
            _candidaturaAux = TipoCandidatura.Senador;
        }

        Candidato memory _novoCandidato;

        _novoCandidato.nomeCandidato = _nomeCandidato;
        _novoCandidato.foto_base64 = _fotoCandidato;
        _novoCandidato.partido = _nomePartido;
        _novoCandidato.codigoCandidato = _codigo;
        _novoCandidato.tipoCandidatura = _candidaturaAux;

        candidatos.push(_novoCandidato);
    }

}