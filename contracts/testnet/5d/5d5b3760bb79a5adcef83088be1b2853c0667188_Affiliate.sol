/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract Affiliate{

    struct Data {
        address utente;
        address sponsor;
    }

    Data[] public Affiliati;

    address public CompanyAddress = 0x5Fa494BC205999c28CEc4F608968A09C12bBB924; // Indirizzo "Company" 

    mapping (address => bool) public isAffiliate; // mapping per verificare se un indirizzo è presente nell'array Affiliati

    event PaymentReceived(address indexed sender, uint amount); // evento per registrare i pagamenti ricevuti


function AggiungiNuovo(address _utente, address _sponsor) public {
        for (uint i = 0; i < Affiliati.length; i++) {
            if (Affiliati[i].utente == _utente) {
                revert("L'utente inserito \u00E8 gi\u00E0 presente nell'array");
            }
        }
        Affiliati.push(Data({utente: _utente, sponsor: _sponsor}));
        isAffiliate[_utente] = true;
    }

function AggiungiNuovi(Data[] memory _nuoviAffiliati) public {
        for (uint i = 0; i < _nuoviAffiliati.length; i++) {
            address utente = _nuoviAffiliati[i].utente;
            for (uint j = 0; j < Affiliati.length; j++) {
                if (Affiliati[j].utente == utente) {
                    revert("L'utente inserito \u00E8 gi\u00E0 presente nell'array");
                }
            }
            Affiliati.push(_nuoviAffiliati[i]);
            isAffiliate[utente] = true;
        }
    }

function ModificaSponsor(address _utente, address _nuovoSponsor) public {
    bool utenteTrovato = false;
    for (uint i = 0; i < Affiliati.length; i++) {
        if (Affiliati[i].utente == _utente) {
            Affiliati[i].sponsor = _nuovoSponsor;
            utenteTrovato = true;
        }
    }
    if (!utenteTrovato) {
        revert("L'utente non \u00E8 presente nell'array");
    }
}

function ModificaUtente(address _sponsor, address _nuovoUtente) public {
    bool sponsorTrovato = false;
    for (uint i = 0; i < Affiliati.length; i++) {
        if (Affiliati[i].sponsor == _sponsor) {
            Affiliati[i].utente = _nuovoUtente;
            isAffiliate[Affiliati[i].utente] = false;
            isAffiliate[_nuovoUtente] = true;
            sponsorTrovato = true;
            break;
        }
    }
    if (!sponsorTrovato) {
        revert("Lo sponsor non \u00E8 presente nell'array");
    }
}

function getAffiliateIndex(address _utente) internal view returns (uint) {
    for (uint i = 0; i < Affiliati.length; i++) {
        if (Affiliati[i].utente == _utente) {
            return i;
        }
    }
    revert("L'utente non \u00E8 presente nell'array");
}

receive() external payable {
    emit PaymentReceived(msg.sender, msg.value);
    if (isAffiliate[msg.sender]) {
        uint sponsorShare = msg.value / 3; // calcola la quota da inviare allo sponsor (33%)
        payable(Affiliati[getAffiliateIndex(msg.sender)].sponsor).transfer(sponsorShare);
        payable(CompanyAddress).transfer(msg.value - sponsorShare); // invia il restante
    }
}

}