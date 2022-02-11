/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

contract Utilisateur {
    address public adress;
    string public localisation;
    string public mail;
    string public tel;
    string public username;
    uint public nombreAnnonce;
    uint public nombreAchats;
    bool public registered;

    //Tableau contenant la liste des conversations, puis des messages 
    mapping(address => mapping(uint => string)) public listeMessagesEnvoyes;
    mapping(address => mapping(uint => string)) public listeMessagesRecus;

    constructor(address _adress, string memory _localisation, string memory _mail, string memory _tel, string memory _username) {
        adress = _adress;
        localisation = _localisation;
        mail = _mail;
        tel = _tel;
        username = _username;
        registered = true;
        nombreAnnonce = 0;
    }
    
    function modifierUtilisateur(string memory _localisation, string memory _mail, string memory _tel, string memory _username)public{
        localisation = _localisation;
        mail = _mail;
        tel = _tel;
        username = _username;
    }
    //Pour changer le nombre d'annonces
    function setNombreAnnonce(uint nb) public {
        nombreAnnonce = nb;
    }
    function nbrAchatsPlus() public returns(uint){
        nombreAchats +=1;
        return nombreAchats;
    }
}

contract Annonce {
    string public titre;
    string public description;
    string public etat;
    uint public prix;
    string public localisation;
    string public modeAcheminement;
    Utilisateur public user;
    bool public vendu;
    address public userVendu;

    constructor(Utilisateur _user, string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation) {
        titre = _titre;
        description = _description;
        etat = _etat;
        prix = _prix;
        localisation = _localisation;
        modeAcheminement = _modeAcheminement;
        user = _user;
        vendu=false;
        userVendu = address(0);
    }

    //Modifie une annonce
    function modifierAnnonce(string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation) public {
        titre = _titre;
        description = _description;
        etat = _etat;
        prix = _prix;
        localisation = _localisation;
        modeAcheminement = _modeAcheminement;
    }

    function setVendu(address _userVendu) public {
        vendu = true;
        userVendu = _userVendu;
    }

}

contract MonkeFlip{

    mapping(address => Utilisateur) public listeUtilisateurs;
    mapping(address => mapping(uint => Annonce)) public listeAnnonces;
    mapping(address => mapping(uint => Annonce)) public listeHistoriqueAchat;
    mapping(address => bool) utilisateurExiste;
    mapping(address => mapping(address => mapping(uint => string))) public listeMessagesEnvoyes;
    mapping(address => mapping(address => mapping(uint => string))) public listeMessagesRecus;

    event AnnonceCree(address createur, uint idAnnonce);

    modifier isRegistered() {
        require(utilisateurExiste[msg.sender], "Vous n'etes pas enregistre");
        _;
    }

    function test(string memory hello) public view isRegistered returns(string memory){
        return hello;
    }

    //Créé nouvel utilisateur
    function nouvelUtilisateur(string memory _localisation, string memory _mail, string memory _tel, string memory _username) public {
        Utilisateur newUser = new Utilisateur(msg.sender,_localisation,_mail,_tel,_username);
        utilisateurExiste[msg.sender]=true;
        listeUtilisateurs[msg.sender] = newUser;
    }
    function modifierUtilisateur(string memory _localisation, string memory _mail, string memory _tel, string memory _username) public{
        listeUtilisateurs[msg.sender].modifierUtilisateur(_localisation, _mail, _tel, _username);
    }
    //Créé nouvelle Annonce et fais les mises à jour des données
    function creerAnnonce(string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation) isRegistered public{
        require(_prix>0,"Le prix doit etre superieur a 0");
        Annonce newAnnonce = new Annonce(listeUtilisateurs[msg.sender],_titre,_description,_etat, _prix,_modeAcheminement,_localisation);
        listeAnnonces[msg.sender][listeUtilisateurs[msg.sender].nombreAnnonce()] = newAnnonce;
        listeUtilisateurs[msg.sender].setNombreAnnonce(listeUtilisateurs[msg.sender].nombreAnnonce()+1);
        emit AnnonceCree(msg.sender, listeUtilisateurs[msg.sender].nombreAnnonce());
    }

    //Modifie une annonce
    function modifierAnnonce(uint indexAnnonce, string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation) isRegistered public {
        listeAnnonces[msg.sender][indexAnnonce].modifierAnnonce(_titre,_description,_etat, _prix,_modeAcheminement,_localisation);
    }

    function acheterAnnonce(address userAnnonce, uint indexAnnonce) public payable isRegistered {
        require(msg.value >= listeAnnonces[userAnnonce][indexAnnonce].prix(), "Montant incorrect");
        listeHistoriqueAchat[msg.sender][listeUtilisateurs[msg.sender].nbrAchatsPlus()]=listeAnnonces[userAnnonce][indexAnnonce];
        payable(userAnnonce).transfer(msg.value);
        listeAnnonces[userAnnonce][indexAnnonce].setVendu(msg.sender);
    }

    function initAnnonces() public isRegistered {
        creerAnnonce("Titre1","Desc1","Etat1",1000000000000000000,"modeAcheminement1","localisation1");
        creerAnnonce("Titre2","Desc2","Etat2",2000000000000000000,"modeAcheminement2","localisation2");
        creerAnnonce("Titre3","Desc3","Etat3",3000000000000000000,"modeAcheminement3","localisation3");
        creerAnnonce("Titre4","Desc4","Etat4",4000000000000000000,"modeAcheminement4","localisation4");
    }

    function envoyerMessage(address _to, string memory _message, uint nbMessageConv) public isRegistered{
        Utilisateur sender = listeUtilisateurs[msg.sender];
        listeMessagesEnvoyes[sender.adress()][_to][nbMessageConv] = _message;
        listeMessagesRecus[_to][sender.adress()][nbMessageConv] = _message;
    }
   

    /*
        CreerEnchere
        ModifierEnchere
        SupprimerEnchere
        Messagerie
    */
}