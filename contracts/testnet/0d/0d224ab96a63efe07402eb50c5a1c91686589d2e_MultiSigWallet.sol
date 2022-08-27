/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDoxy{
   function transferOwnership(address newOwner) external;
   function whitelistAddress(address _address , bool _value) external; 
   function whitelist(address _address) view  external returns(bool); 
}

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;
    IDoxy doxyContract;

    struct Transaction {
        string _transaction;
        address to;
        bool executed;
        uint numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired,address _contractAddress) {
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

        doxyContract = IDoxy(_contractAddress);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        uint256 _transaction,
        address _to
    ) public onlyOwner {
        uint txIndex = transactions.length;

        if(_transaction==1)
        {
            transactions.push
            (
                Transaction({
                    _transaction:"changeOwner",
                    to: _to,
                    executed: false,
                    numConfirmations: 0
                })
           );
        }else{

             transactions.push
            (
                Transaction({
                    _transaction:"addToWhiteList",
                    to: _to,
                    executed: false,
                    numConfirmations: 0
                })
           );

        }
    
        emit SubmitTransaction(msg.sender, txIndex, _to);
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

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        // call your functions from here

        if(stringsEquals(transaction._transaction,"changeOwner")){
            changeOwner(transaction.to);
        }else{
            addToWhiteList(transaction.to);
        }

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }


    function changeOwner(address _newOwner) internal{
        doxyContract.transferOwnership(_newOwner);
    }

    function addToWhiteList(address _address ) internal{ 
        
        bool status = doxyContract.whitelist(_address) ;  
        doxyContract.whitelistAddress(_address,!status) ; 
        
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            string memory _transaction,
            address to,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction._transaction,
            transaction.to,
            transaction.executed,
            transaction.numConfirmations
        );
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
}