/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract MusiciansManager {

  //Events
  event createMusician(string _name);
  event addedTrack(string _name, string _title);
  event getTheTracks(Track[] _tracks );
  
  // Représente une compilation
  struct Track{
    string _title;    //Titre de la musique
    uint _duration;   //Durée de la musique
  } 

  //Représente un musicien
  struct Musician{
    string _name;     //Nom du musicien
    Track[] _tracks;  //Tableau représente une compilation de musique
  }

  mapping (address => Musician) Musicians;  //Link l'adresse à un musicien
  address owner;    //addresse du propriétaire

  constructor (){
    owner = msg.sender; //Lors du deploiement stock l'addresse de la personne qui deploie le contrat
  } 

  //Modifier controle si la personne est bien celle qui a déployer le contrat
  modifier onlyOwner(){
    require(msg.sender == owner, "Not the owned");
    _;
  }
  
  //Ajoute un musicien
  function addMusician(address _musicianAdress, string memory _name) external onlyOwner{
    //Check si le musicien existe si non le créer en lui attribuant un nom
    require(bytes(Musicians[_musicianAdress]._name).length == 0, "This musician has already been created");
    Musicians[_musicianAdress]._name = _name;
    //Déclencher l'evenement permet de récuperer la data sur la partie Front end entre autre
    emit createMusician(_name);
  }

  //Ajoute une musique au musicien
  function addTrack(address _musicianAdress, string memory _title, uint _duration) external onlyOwner{
    //Check si le musicien existe si oui créer une variable de type Structure Track et lui affecte pour valeur
    //Le titre et la durée passé en paramètre
    require(bytes(Musicians[_musicianAdress]._name).length > 0, "This musician does'nt exists");
    Track memory thisTrack = Track(_title, _duration);
    //Envoi dans le tableau Tracks du musicien la structure thisTrack
    Musicians[_musicianAdress]._tracks.push(thisTrack);
    //Récupère le nom du musicien et le titre pour la partie front end
    emit addedTrack(Musicians[_musicianAdress]._name, _title);
  }

  //Récupère les tracks d'un musicien
  function getMusicianTracks(address _musicianAdress) external {
    require(bytes(Musicians[_musicianAdress]._name).length > 0, "This musician does'nt exists");
    // Récupère le tableau représentatn la compilation pour le front end
    emit getTheTracks(Musicians[_musicianAdress]._tracks);
  }
}