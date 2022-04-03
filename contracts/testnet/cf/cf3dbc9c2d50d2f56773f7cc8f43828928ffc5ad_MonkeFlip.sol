/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;


contract Utilisateur {
    address public adress;
    string public username;
    string public mail;
    string public localisation;
    string public tel;
    uint public nombreAnnonce;
    uint public nombreAchats;
    bool public registered;

    constructor(address _adress, string memory _localisation, string memory _mail, string memory _tel, string memory _username) {
        adress = _adress;
        localisation = _localisation;
        mail = _mail;
        tel = _tel;
        username = _username;
        registered = true;
        nombreAnnonce = 0;
        nombreAchats=0;
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
    string public urlImage;
    Utilisateur public user;
    bool public vendu;
    address public userVendu;
    string public categorie;

    string[] public categories = ["Mobilier interieur", "Mobilier exterieur", "Accessoires", "Vehicules", "Multimedia", "Vetements", "Jeux-videos", "Services", "High-Tech", "Electromenager", "Decoration", "Immobilier"];

    constructor(Utilisateur _user, string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation, string memory _categorie, string memory _urlImage) {

        bool catTrouve = false;
        for(uint i=0;i<categories.length;i++){
            if(keccak256(abi.encodePacked((_categorie))) == keccak256(abi.encodePacked((categories[i])))){
                catTrouve = true;
            }
        }
        require(catTrouve, "La categorie selectionne n'existe pas");

        titre = _titre;
        description = _description;
        etat = _etat;
        prix = _prix;
        localisation = _localisation;
        modeAcheminement = _modeAcheminement;
        user = _user;
        urlImage = _urlImage;
        categorie = _categorie;
        vendu=false;
        userVendu = address(0);
    }

    function modifierAnnonce(string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _categorie, string memory _localisation) public {
        bool catTrouve = false;
        for(uint i=0;i<categories.length;i++){
            if(keccak256(abi.encodePacked((_categorie))) == keccak256(abi.encodePacked((categories[i])))){
                catTrouve = true;
            }
        }
        require(catTrouve, "La categorie selectionne n'existe pas"); 
        titre = _titre;
        description = _description;
        etat = _etat;
        prix = _prix;
        localisation = _localisation;
        categorie = _categorie;
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

    mapping(address => mapping(address => uint)) public nbMessagesEnvoyes;
    mapping(address => mapping(address => uint)) public nbMessagesRecus;

    event AnnonceCree(address createur, uint idAnnonce);
    event AnnonceAchetee(address acheteur, uint idAnnonce);

    modifier isRegistered() {
        require(utilisateurExiste[msg.sender], "Vous n'etes pas enregistre");
        _;
    }

    function nouvelUtilisateur(string memory _localisation, string memory _mail, string memory _tel, string memory _username) public {
        Utilisateur newUser = new Utilisateur(msg.sender,_localisation,_mail,_tel,_username);
        utilisateurExiste[msg.sender]=true;
        listeUtilisateurs[msg.sender] = newUser;
    }
    function modifierUtilisateur(string memory _localisation, string memory _mail, string memory _tel, string memory _username) public{
        listeUtilisateurs[msg.sender].modifierUtilisateur(_localisation, _mail, _tel, _username);
    }

    function creerAnnonce(string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _localisation, string memory _categorie, string memory _urlImage) isRegistered public{
        require(_prix>0,"Le prix doit etre superieur a 0");
        Annonce newAnnonce = new Annonce(listeUtilisateurs[msg.sender],_titre,_description,_etat, _prix,_modeAcheminement,_localisation, _categorie, _urlImage);
        listeAnnonces[msg.sender][listeUtilisateurs[msg.sender].nombreAnnonce()] = newAnnonce;
        listeUtilisateurs[msg.sender].setNombreAnnonce(listeUtilisateurs[msg.sender].nombreAnnonce()+1);
        emit AnnonceCree(msg.sender, listeUtilisateurs[msg.sender].nombreAnnonce());
    }

    function modifierAnnonce(uint indexAnnonce, string memory _titre, string memory _description, string memory _etat, uint _prix, string memory _modeAcheminement, string memory _categorie, string memory _localisation) isRegistered public {
        listeAnnonces[msg.sender][indexAnnonce].modifierAnnonce(_titre,_description,_etat, _prix,_modeAcheminement, _categorie, _localisation);
    }

    function acheterAnnonce(address userAnnonce, uint indexAnnonce) public payable isRegistered {
        require(msg.value >= listeAnnonces[userAnnonce][indexAnnonce].prix(), "Montant incorrect");
        listeHistoriqueAchat[msg.sender][listeUtilisateurs[msg.sender].nbrAchatsPlus()]=listeAnnonces[userAnnonce][indexAnnonce];
        payable(userAnnonce).transfer(msg.value);
        listeAnnonces[userAnnonce][indexAnnonce].setVendu(msg.sender);
        
        emit AnnonceAchetee(msg.sender, indexAnnonce);
    }

    function envoyerMessage(address _to, string memory _message) public isRegistered{
        require(msg.sender!=_to, "Vous ne pouvez pas envoyer de messages a vous meme");
        require(utilisateurExiste[msg.sender], "Utilisateur non enregistre");
        Utilisateur sender = listeUtilisateurs[msg.sender];
        
        nbMessagesEnvoyes[sender.adress()][_to] = nbMessagesEnvoyes[sender.adress()][_to] + 1;
        listeMessagesEnvoyes[sender.adress()][_to][nbMessagesEnvoyes[sender.adress()][_to]] = _message;
        
        nbMessagesRecus[_to][sender.adress()] = nbMessagesRecus[_to][sender.adress()]+ 1;
        listeMessagesRecus[_to][sender.adress()][nbMessagesRecus[_to][sender.adress()]] = _message;
    }
}