/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract bolao {

    uint public balancePremioRodada = 0;
    uint public balanceDespesas = 0;
    uint public balancePremioAcumulado = 0;
    uint public balancePremioDomingo = 0;
    uint public rodadaAberta = 0; 
    uint public ultimaRodada = 0;

    address public owner;

    struct Partida {
        uint ordem;
        string timeA;
        string timeB;
    }

    struct Palpites {
        uint rodada;
        address player;
        string palpites;
    }

    mapping(uint => uint) listaRodadas;         // Mapeia a rodada ao total de palpites

    mapping(uint => Partida[]) listaPartidas;    // Mapeia as partidas da rodada

    modifier onlyOwner {
        require(msg.sender == owner, "Apenas o ADM pode executar essa feature");
    _;
    }

    constructor() {
        owner = msg.sender;
    }

    function novaRodada() external onlyOwner {
        uint idRodada = ultimaRodada + 1;
        listaRodadas[idRodada] = 0;
    }

    function getRodada() public view returns(uint) {
        return rodadaAberta;
    }

    function openRodada(uint _rodada) external onlyOwner {
        // Preciso verificar se a rodada existe
        rodadaAberta = _rodada;
    }

    function gravaPartida(uint _rodada, uint _ordem, string memory _timeA, string memory _timeB) external onlyOwner {
        
        // Verifico se já há 13 partidas cadastradas na rodada;
        uint totalPartidas = listaPartidas[_rodada].length + 1;
        require(totalPartidas < 13,'Total de partidas por rodada atingido');
        
        Partida memory novaPartida;
        novaPartida.ordem = _ordem;
        novaPartida.timeA = _timeA;
        novaPartida.timeB = _timeB;

        listaPartidas[_rodada].push(novaPartida);
    }

    function getListaPartidas(uint _rodada) external view returns(Partida[] memory) {
        return listaPartidas[_rodada];
    }
 

}