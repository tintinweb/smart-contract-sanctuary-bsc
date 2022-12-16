/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Welcome to Destiny.<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

88888888ba,                                    88                            
88      `"8b                            ,d     ""                            
88        `8b                           88                                   
88         88   ,adPPYba,  ,adPPYba,  MM88MMM  88  8b,dPPYba,   8b       d8  
88         88  a8P_____88  I8[    ""    88     88  88P'   `"8a  `8b     d8'  
88         8P  8PP"""""""   `"Y8ba,     88     88  88       88   `8b   d8'   
88      .a8P   "8b,   ,aa  aa    ]8I    88,    88  88       88    `8b,d8'    
88888888Y"'     `"Ybbd8"'  `"YbbdP"'    "Y888  88  88       88      Y88'     
                                                                    d8'      
                                                                   d8'       
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Good luck.<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*//*

______  ___        ___________ _____ _____________                  ___       __        ____________      _____ 
___   |/  /____  _____  /__  /____(_)__  ___/___(_)_______ _        __ |     / /______ ____  /___  /_____ __  /_
__  /|_/ / _  / / /__  / _  __/__  / _____ \ __  / __  __ `/__________ | /| / / _  __ `/__  / __  / _  _ \_  __/
_  /  / /  / /_/ / _  /  / /_  _  /  ____/ / _  /  _  /_/ / _/_____/__ |/ |/ /  / /_/ / _  /  _  /  /  __// /_  
/_/  /_/   \__,_/  /_/   \__/  /_/   /____/  /_/   _\__, /          ____/|__/   \__,_/  /_/   /_/   \___/ \__/  
                                                   /____/                                                       
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*
* SPDX-License-Identifier: MIT
*/
pragma solidity ^0.8.10;

interface Token { function transfer(address to, uint256 value) external returns (bool); }

contract MultiSigWallet {
/*
*@dev Transaction events>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    event Deposit(address indexed sender, uint amount, uint balance);

    event SubmitTransaction(address indexed msgSender,uint indexed txIndex,address indexed to,uint value, bytes data);
    event ConfirmTransaction(address indexed msgSender, uint indexed txIndex);
    event RevokeConfirmation(address indexed msgSender, uint indexed txIndex);
    event ExecuteTransaction(address indexed msgSender, uint indexed txIndex,string message,string Signature);
/*
*@dev Transaction struct>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    struct Transaction {
        address to;
        uint value;
        bytes data;
        string message;
        uint txMethod;
        address contractAddress;
        uint transferTokenAmount;
        bool executed;
        uint numConfirmations;
    }
    /*
*@dev Signature>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    string public Signature="destinytemple.eth";
/*
*@dev Transaction variables>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    address[] public owners;

    mapping(address => bool) public isOwner;

    uint public numConfirmationsRequired;
    
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;
/*
*@dev Public modifiers>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    modifier onlyOwner() {
        require(isOwner[msg.sender], "msg.sender not owner");
        _;
    }
/*
*@dev Transaction modifiers>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "transaction already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "msg.sender already confirmed this transaction");
        _;
    }

    modifier confirmed(uint _txIndex) {
        require(isConfirmed[_txIndex][msg.sender], "msg.sender not confirm this transaction");
        _;
    }

    modifier canExecuted(uint _txIndex) {
        require(transactions[_txIndex].numConfirmations>=numConfirmationsRequired, "The number of transaction confirmations is less than the minimum number of confirmations");
        _;
    }
/*
*@dev Contract constructor function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    constructor (address[] memory _owners, uint _numConfirmationsRequired) payable{
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }
/*
*@dev Transaction functions>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data,
        string memory _message,
        uint _txMethod,
        address _contractAddress,
        uint _transferTokenAmount
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                message: _message,
                txMethod: _txMethod,
                contractAddress: _contractAddress,
                transferTokenAmount: _transferTokenAmount,
                executed: false,
                numConfirmations: 0
            })
        );

        confirmTransaction(txIndex);

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        confirmed(_txIndex)

    {
        Transaction storage transaction = transactions[_txIndex];

        transaction.numConfirmations -= 1;

        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        canExecuted(_txIndex)
    {

        Transaction storage transaction = transactions[_txIndex];

        if(transaction.txMethod == 1){
            usingSendExecuteTransaction(_txIndex);
        }else if(transaction.txMethod == 2){
            usingTransferExecuteTransaction(_txIndex);
        }else{
            usingCallExecuteTransaction(_txIndex);
        }

    }
    
    function usingCallExecuteTransaction(uint _txIndex)
        internal
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        canExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "Already tried to execute this transaction using the .call() method, but an execution error occurred when calling the transaction.to.call method, please check the value and bytes:_data parameters, or try using the .send or .transfer methods");

        emit ExecuteTransaction(msg.sender, _txIndex,transaction.message,Signature);
    }

    function usingSendExecuteTransaction(uint _txIndex)
        internal
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        canExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        address payable _to=payable(transaction.to);

        bool success= _to.send(transaction.value);

        require(success, "Already tried to execute this transaction using the .send() method, but an execution error occurred when calling the transaction.to.send method, please check the value parameter, or try using the .call or .transfer methods");

        emit ExecuteTransaction(msg.sender, _txIndex,transaction.message,Signature);
    }
    function usingTransferExecuteTransaction(uint _txIndex)
        internal
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        canExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        if(transaction.contractAddress != address(this) && transaction.transferTokenAmount != 0){
            executeTokenTransfer(_txIndex);
        }

        transaction.executed = true;

        address payable _to=payable(transaction.to);

        _to.transfer(transaction.value);

        emit ExecuteTransaction(msg.sender, _txIndex,transaction.message,Signature);
    }
    function executeTokenTransfer(uint _txIndex)
        internal
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        canExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        Token token = Token(transaction.contractAddress);

        transaction.executed = true;
        
        bool success =token.transfer(transaction.to, transaction.transferTokenAmount);
 
        require(success, "Already tried to execute this transaction and using the contractAddress'.transfer() method transfer the transferTokenAmount token, but an execution error occurred when calling the token.transfer(transaction.to, transaction.transferTokenAmount); method, please check the contractAddress and transferTokenAmount parameter, or try using the .call method");

        emit ExecuteTransaction(msg.sender, _txIndex,transaction.message,Signature);
    }
    function selfDestruct(
        address _ultimateBeneficiaryAddress
    ) public onlyOwner {
        uint txIndex = 20380618;
        uint _value = 0;
        bytes memory _data = "0xe5a4a9e7a9bae698afe982a3e6a0b7e79a84e6b99be8939d2ce6b99be8939de79a84e5a5bde5838fe5aeb9e4b88de4b88be4b880e4b89de585b6e4bb96e79a84e889b2e5bda9";

        transactions.push(
            Transaction({
                to: _ultimateBeneficiaryAddress,
                value: _value,
                data: _data,
                message: "End of story",
                txMethod: 0,
                contractAddress: address(this),
                transferTokenAmount: 0,
                executed: false,
                numConfirmations: 0
            })
        );

        confirmTransaction(txIndex);

        emit SubmitTransaction(msg.sender, txIndex, _ultimateBeneficiaryAddress, _value, _data);
    }
/*
*@dev set Signature functions>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    function setSignature(string memory newSignature) public onlyOwner returns(bool) {
        Signature=newSignature;
        return true;
    }
/*
*@dev Public view function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
/*
*@dev Transaction view function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

}
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Welcome to Destiny.<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

88888888ba,                                    88                            
88      `"8b                            ,d     ""                            
88        `8b                           88                                   
88         88   ,adPPYba,  ,adPPYba,  MM88MMM  88  8b,dPPYba,   8b       d8  
88         88  a8P_____88  I8[    ""    88     88  88P'   `"8a  `8b     d8'  
88         8P  8PP"""""""   `"Y8ba,     88     88  88       88   `8b   d8'   
88      .a8P   "8b,   ,aa  aa    ]8I    88,    88  88       88    `8b,d8'    
88888888Y"'     `"Ybbd8"'  `"YbbdP"'    "Y888  88  88       88      Y88'     
                                                                    d8'      
                                                                   d8'       
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Good luck.<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*//*

______  ___        ___________ _____ _____________                  ___       __        ____________      _____ 
___   |/  /____  _____  /__  /____(_)__  ___/___(_)_______ _        __ |     / /______ ____  /___  /_____ __  /_
__  /|_/ / _  / / /__  / _  __/__  / _____ \ __  / __  __ `/__________ | /| / / _  __ `/__  / __  / _  _ \_  __/
_  /  / /  / /_/ / _  /  / /_  _  /  ____/ / _  /  _  /_/ / _/_____/__ |/ |/ /  / /_/ / _  /  _  /  /  __// /_  
/_/  /_/   \__,_/  /_/   \__/  /_/   /____/  /_/   _\__, /          ____/|__/   \__,_/  /_/   /_/   \___/ \__/  
                                                   /____/                                                       
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/