/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7.0 < 0.9.0;

contract Contract {
    address public owner;
    string public fileHash;
    string public metadataHash;
    string public metadata;
    string public folderId;
    
    event ContractCreated(Contract cntr);

    constructor(
        string memory fileHash_,
        string memory metadataHash_,
        string memory metadata_,
        string memory folderId_
    ) {
        owner = msg.sender;
        fileHash = fileHash_;
        metadataHash = metadataHash_;
        metadata = metadata_;
        folderId = folderId_;
        emit ContractCreated(this);
    }
}

contract Rastreabilidade {
    address owner;

    struct Data {
        string origin;
        string destino;
        uint256 timestamp;
        string description;
        string fileHash;
        string local;        
    }
   
    Data public data;    
    Data[] public transacoes;   

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    } 

    event RastreabilidadeCreated(Rastreabilidade wallet);
   
    constructor(
        string memory _origin,
        string memory _destino,
        uint256 _timestamp,        
        string memory _description,
        string memory _fileHash,
        string memory _local        
    ) {
       owner = msg.sender;
       data.origin = _origin;       
       data.destino = _destino;       
       data.timestamp = _timestamp;
       data.description = _description;
       data.fileHash = _fileHash;   
       data.local = _local;   
       transacoes.push(data);
       emit RastreabilidadeCreated(this);
    }
    
    function getData() public view returns (Data memory) {
        return data;
    } 

    function ObterDadosTransacao(string memory origin) public view returns (Data memory) {
        Data memory dataResultado;
        for (uint i = 0; i < transacoes.length; i++) {            
            
            //if (transacoes[i].origin == origin) {
            if(stringsEquals(transacoes[i].origin,origin)){
                dataResultado = transacoes[i];
                break;
            }
        }

        return dataResultado;
    }    

    function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        uint256 l1 = b1.length;
        if (l1 != b2.length) return false;
        for (uint256 i=0; i<l1; i++) {
            if (b1[i] != b2[i]) return false;
        }
        return true;
    }    

    function criarNovaRastreabilidade(
        string memory _origin,    
        string memory _destino,   
        uint256 _timestamp,        
        string memory _description,
        string memory _fileHash,
        string memory _local
    ) onlyOwner public {        

        data.origin = _origin;       
        data.destino = _destino;       
        data.timestamp = _timestamp;
        data.description = _description;
        data.fileHash = _fileHash;        
        data.local = _local;   

        transacoes.push(data);      
    }    
}

contract Transaction {

    struct Data {
        address origin;
        address target;
        string description;
        string partner;
        uint256 points;
        uint256 neutralizationPoints;
        uint256 timestamp;
        bool isCreditBuyingOperation;
        bool isVccCoinageOperation;
    }
   
    Data public data;
    event TransactionCreated(Transaction wallet);
   
    constructor(
        address _origin,
        address _target,
        uint256 _points,
        uint256 _neutralizationPoints,
        string memory _description,
        bool _isCreditBuyingOperation,
        uint256 _timestamp
    ) {
       data.origin = _origin;
       data.target = _target;
       data.points = _points;
       data.neutralizationPoints = _neutralizationPoints;
       data.timestamp = _timestamp;
       data.description = _description;
       data.isCreditBuyingOperation = _isCreditBuyingOperation;
       emit TransactionCreated(this);
    }
    
    function getData() public view returns (Data memory) {
        return data;
    }
}

contract Wallet {
    address owner;
        
    struct Data {
        string userEmail;
        uint256 points;
        uint256 neutralizationPoints;
        uint256 lastTransactionAt;
        uint256 createdAt;
    }
   
    Data public data;
    event WalletCreated(Wallet wallet);
    address[] transactions;
   
    constructor(
        uint256 _points,
        uint256 _neutralizationPoints,
        string memory _userEmail,
        uint256 _createdAt
        
    ) {
       owner = msg.sender;
       data.points = _points;
       data.neutralizationPoints = _neutralizationPoints;
       data.createdAt = _createdAt;
       data.lastTransactionAt = _createdAt;
       data.userEmail = _userEmail;
       emit WalletCreated(this);
    }
   
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }
    
    function addCredits(uint256 _points, uint256 _neutralizationPoints, address _transactionAddress, uint256 _timestamp) onlyOwner public {
        data.points += _points;
        data.neutralizationPoints += _neutralizationPoints;
        transactions.push(_transactionAddress);
        data.lastTransactionAt = _timestamp;
    }
    
    function addDebits(uint256 _points, uint256 _neutralizationPoints, address _transactionAddress, uint256 _timestamp) onlyOwner public {
        data.points -= _points;
        data.neutralizationPoints -= _neutralizationPoints;
        transactions.push(_transactionAddress);
        data.lastTransactionAt = _timestamp;
    }
    
    function getPoints() public view returns (uint256) {
        return data.points;
    }
    
    function getNeutralizationPoints() public view returns (uint256) {
        return data.neutralizationPoints;
    }
    
    function getTransactions() public view returns (address[] memory) {
        return transactions;
    }

    function getData() public view returns (Data memory) {
        return data;
    }
}

contract Factory {
    address owner;

    struct wallet_struct {
        Wallet wallet;
        bool exists;
    }


    mapping(string => wallet_struct) public wallets;
    string[] public all_wallets;

    constructor() {
        owner = msg.sender;
    }

    function createWallet(
        string memory _email,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _createdAt
    ) public {
        require(wallets[_email].exists == false, "user already has a wallet");
        Wallet wallet = new Wallet(
            _points,
            _neutralizationPoints,
            _email,
            _createdAt
        );
        wallets[_email] = wallet_struct(wallet, true);
        all_wallets.push(_email);
    }

    function addCredits(
        address _wallet,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _timestamp
    ) public {
        Wallet wallet = Wallet(_wallet);
        Transaction transaction = new Transaction(
            address(this),
            _wallet,
            _points,
            _neutralizationPoints,
            "Buy credit",
            true,
            _timestamp
        );
        wallet.addCredits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
    }

    function createWalletTransaction(
        address _origin,
        address _target,
        uint256 _points,
        uint256 _neutralizationPoints,
        uint256 _timestamp
    ) public {
        Wallet origin = Wallet(_origin);
        Wallet target = Wallet(_target);
        uint256 originAmount = origin.getPoints();
        require(
            originAmount >= _points,
            "origin wallet doesnt have enough points"
        );
        Transaction transaction = new Transaction(
            _origin,
            _target,
            _points,
            _neutralizationPoints,
            "Wallet transaction",
            false,
            _timestamp
        );
        origin.addDebits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
        target.addCredits(
            _points,
            _neutralizationPoints,
            address(transaction),
            _timestamp
        );
    }
}