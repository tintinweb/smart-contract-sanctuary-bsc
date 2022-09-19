/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

contract ProjetSergent04 {

    // définition d'un bar : nom et liste de ses clients
    struct Bar { 
        string barName;
        uint nbClients;
        mapping(uint => Client) clientsBar;
    }

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    // un client est défini par son address et sa dernière visite
    struct Client { 
        address clientAddress;
        uint derniereVisite;
    }
    // mapping "bars" qui renvoie un bar à partir d'une address
    mapping(address => Bar) bars;

    // ajouter un bar en renseignant son nom (tx à faire depuis address bar)
    function addBar(string memory name) public {
        bars[msg.sender].barName= name;
    }

    // ajouter un client en renseignant son adresse (tx à faire depuis address bar)
    // dev : ajout d'une condition pour vérifier que le client n'existe pas déjà
    function addClient(address _clientAddress) public {
        bool doesListContainElement = false;
        uint indiceClient;
        for (uint i=0; i < bars[msg.sender].nbClients; i++) {
            if (_clientAddress == bars[msg.sender].clientsBar[i].clientAddress) {
                doesListContainElement = true;
                indiceClient = i;
                break;
                }
            }
        require (doesListContainElement==false, "Ce client existe deja");
        bars[msg.sender].clientsBar[bars[msg.sender].nbClients].derniereVisite = block.timestamp;
        bars[msg.sender].clientsBar[bars[msg.sender].nbClients].clientAddress = _clientAddress;
        bars[msg.sender].nbClients++;
    }

    // permet de maj la dernière venue d'un client
    function venueClient(address _clientAddress) public {
        bool doesListContainElement = false;
        uint indiceClient;
        for (uint i=0; i < bars[msg.sender].nbClients; i++) {
            if (_clientAddress == bars[msg.sender].clientsBar[i].clientAddress) {
                doesListContainElement = true;
                indiceClient = i;
                break;
                }
            }
        bars[msg.sender].clientsBar[indiceClient].derniereVisite=block.timestamp;
    }

    // renvoie le nombre de clients d'un bar
    function nbClientsBar(address _barAddress) public view returns (uint)  {
        return (bars[_barAddress].nbClients);
    }

    // renvoie le nom d'un bar
    function nomBar(address _barAddress) public view returns (string memory) {
        return (bars[_barAddress].barName);
    }

    // renvoie la derniere visite d'un client dans un bar donné
    // si le client n'existe pas, renvoie 0
    function derniereVisiteClient(address _barAddress, address _clientAddress) public view returns (uint) {
        bool doesListContainElement = false;
        uint indiceClient;
        for (uint i=0; i < bars[_barAddress].nbClients; i++) {
            if (_clientAddress == bars[_barAddress].clientsBar[i].clientAddress) {
                doesListContainElement = true;
                indiceClient = i;
                break;
            }
        }
        if (doesListContainElement) {
            return (bars[_barAddress].clientsBar[indiceClient].derniereVisite);
        }
        else {
            return (0);
        }

        // todo : pourquoi pas modifier fonction addBar pour que ce soit le owner qui puisse le faire
    
    }
}