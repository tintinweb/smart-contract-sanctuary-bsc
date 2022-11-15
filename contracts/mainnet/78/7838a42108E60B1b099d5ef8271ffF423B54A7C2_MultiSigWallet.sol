/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.4.8;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}







contract MultiSigWallet {

    address public owner;
    mapping (address => uint8) public managers;
    mapping (uint256 => address) public managersLists;

    modifier isOwner{
        require(owner == msg.sender);
        _;
    }
    
    modifier isManager{
        require(
            msg.sender == owner || managers[msg.sender] == 1);
        _;
    }
    
    uint public MIN_SIGNATURES = 2;
    uint public transactionIdx;
    uint256 public managersNum;

    struct Transaction {
        address token;
        address from;
        address to;
        uint amount;
        uint8 signatureCount;
        mapping (address => uint8) signatures;
    }
    
    mapping (uint => Transaction) public transactions;
    uint[] public pendingTransactions;
 
    constructor() public{
        owner = msg.sender;
    }

    event OwnershipTransferred(address owner);   
    event DepositFunds(address from, uint amount);
    event TransferFunds(address token,address to, uint amount);
    event TransactionCreated(
        address token,
        address from,
        address to,
        uint amount,
        uint transactionId
        );
 

    function recoverBNB(uint256 tokenAmount) public isOwner {
         address(msg.sender).transfer(tokenAmount);
        
    }

     function renounceOwnership() public  isOwner {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function addManager(address manager) public isOwner{
        managers[manager] = 1;
        managersLists[managersNum++] = manager;
     }

     function setMinSign(uint256 num ) public isOwner{

        MIN_SIGNATURES = num;
 
    }    
    
    function removeManager(address manager) public isOwner{
        managers[manager] = 0;
 
    }

    function () public payable{
        emit DepositFunds(msg.sender, msg.value);
    }
 
    
    function Awithdraw(address token, uint amount) isManager public{
        transferTo(token,msg.sender, amount);
    }

    function transferTo(address token, address to,  uint amount) isManager public{
        //require(address(this).balance >= amount);
        uint transactionId = transactionIdx++;
        
        Transaction memory  transaction;
        transaction.token = token;
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;
        transactions[transactionId] = transaction;
        pendingTransactions.push(transactionId);
        emit TransactionCreated(token,msg.sender, to, amount, transactionId);
    }
    
    function getPendingTransactions() public isManager view returns(uint[]){
        return pendingTransactions;
    }
    
    function BsignTransaction(uint transactionId) public isManager{
        Transaction storage transaction = transactions[transactionId];
        require(0x0 != transaction.from);
        require(msg.sender != transaction.from,"sender  dont need");
        require(transaction.signatures[msg.sender]!=1,"signed yet");
        transaction.signatures[msg.sender] = 1;
        transaction.signatureCount++;

        
        if(transaction.signatureCount >= MIN_SIGNATURES){
            //require(address(this).balance >= transaction.amount);
            //address(uint160((transaction.to))).transfer(transaction.amount);

            //bytes4 callid=bytes4(keccak256("transferFrom(address,address,uint256)"));
            bytes4 callid=bytes4(keccak256("transfer(address,uint256)"));
            transaction.token.call(callid,transaction.to,transaction.amount);

            emit TransferFunds(transaction.token,transaction.to, transaction.amount);
            deleteTransactions(transactionId);
        }
    }
    
    function deleteTransactions(uint transacionId) public isManager{
        uint8 replace = 0;
        for(uint i = 0; i< pendingTransactions.length; i++){
            if(1==replace){
                pendingTransactions[i-1] = pendingTransactions[i];
            }else if(transacionId == pendingTransactions[i]){
                replace = 1;
            }
        } 
        delete pendingTransactions[pendingTransactions.length - 1];
        pendingTransactions.length--;
        delete transactions[transacionId];
    }
    
    function walletBalance() public isManager view returns(uint){
        return address(this).balance;
    }
}