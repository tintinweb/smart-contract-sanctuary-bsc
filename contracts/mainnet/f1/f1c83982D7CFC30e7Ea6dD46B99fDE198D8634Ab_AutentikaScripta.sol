/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
//100000000000000000 WEY = 0.1ETH che poi saranno BNB
//AutentikaScriptaV1
//modificato per essere usato in Binance Smart Chain
//Developer: Michele Zaniolo Crypto 2022 UnitedStates

pragma solidity ^0.8.13;

contract AutentikaScripta {
    // State variable to store a number
    string public TestoUtente;
    uint public IDnumerica = 12500000; // Inizializza il contatore a 12500000 per far partire un numer da 8 cifre a crescere +1
    
    address feeAddress = 0x28796154A3B187724CDfcA37e0cdAFe60BD86b78;//Metamask Deposito Fee
   
    mapping(uint => string) public ArchiviTesti; //Archivio chiave vlore ID --> TestoUnico

function ScriviInBlockchain(string memory _Unico) public payable returns (uint) { 
    require(msg.value == 0.1 ether, "A Process fee of 0.1 BNB is required");
    address payable payableFeeAddress = payable(feeAddress); // Converti feeAddress in un oggetto di tipo address payable usando il costruttore payable
    payableFeeAddress.transfer(msg.value); // Invia la fee all'indirizzo specificato
    TestoUtente = _Unico;
    IDnumerica++; // Incrementa il contatore di 1
    ArchiviTesti[IDnumerica] = _Unico; // Aggiungi il testo e l'ID al mapping
    return IDnumerica; // Restituisci l'ID numerico
}

function LeggiDaID(uint _id) public view returns (string memory) {
    return ArchiviTesti[_id];
}

   
}