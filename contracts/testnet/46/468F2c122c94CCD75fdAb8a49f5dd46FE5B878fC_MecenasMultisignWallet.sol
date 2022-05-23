// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./ReentrancyGuard.sol";


interface MecenasPool {

    function withdrawyield(uint _amount, uint _flag) external;
    function withdrawdonations(uint _amount) external;
}

interface ERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}


contract MecenasMultisignWallet is ReentrancyGuard {

    address public constant EMPTY_ADDRESS = address(0);

    ERC20 public walletunderlying;
    MecenasPool public walletpool;

    address public owner;
    
    struct OwnerState {
        address thesigner;
        uint thestate;
    }

    OwnerState[] public owners;

    mapping(address => uint) public signers;
    mapping(address => uint) public signersindex;
    uint public threshold;
    uint public ownerscounter;

    struct Transaction {
        uint datecreation;
        address creator;
        uint transtype;
        uint amount;
        address to;
        uint signaturesCount;
        uint status;
        uint dateexecution;
        uint signthreshold;
}


    mapping (address => mapping(uint => uint)) public signatures;


    Transaction[] public pendingtransactions;

    event PendingTransactionAdded(address indexed from, uint _type, uint amount, address indexed to);
    event TransactionSigned(address indexed from, uint transactionid);
    event SignatureRevoked(address indexed from, uint transactionid);
    event TransactionDeleted(address indexed from, uint transactionid);
    event TransferUnderlying(uint transactionid, address indexed to, uint amount);
    event WithdrawUnderlying(uint transactionid, uint amount);
    event SignerAdded(uint transactionid, address indexed signer);
    event SignerRemoved(uint transactionid, address indexed signer);
    event ThresholdChanged(uint transactionid, uint numbersignature);


    constructor(address _owner, address _pooladdress, address _underlyingaddress) {
        require(_owner != EMPTY_ADDRESS);
        owner = _owner;
        signers[_owner] = 1;
        owners.push(OwnerState(_owner, 1));
        signersindex[_owner] = owners.length - 1;
        ownerscounter += 1;
        threshold = 1;
        walletpool = MecenasPool(_pooladdress);
        walletunderlying = ERC20(_underlyingaddress);
    }


    // Adds a pending Transaction
    // _transyype 1 = whithdraw interest
    // _transyype 2 = whithdraw reserves
    // _transyype 3 = whithdraw donations
    // _transyype 4 = transfer underlying
    // _transyype 5 = add a new signer
    // _transyype 6 = change the threshold signatures
    // _transyype 7 = remove signer

    function addPendingTransaction(uint _transtype, uint _amount, address _to) external nonReentrant {
        require(signers[msg.sender] == 1);
        require(_amount > 0);
        require(_transtype == 1 || _transtype == 2 || _transtype == 3 || _transtype == 4 || _transtype == 5 
                || _transtype == 6 || _transtype == 7);

        if(_transtype == 4 || _transtype == 5 || _transtype == 7) {
            require(_to != EMPTY_ADDRESS);
        }

        if(_transtype == 5) {
            require(signers[_to] != 1);
        }

        if(_transtype == 6) {
            require(_amount > 0);
            require(_amount <= ownerscounter);
            require(_amount != threshold);
        }

        if(_transtype == 7) {
            require(signers[_to] == 1);
            require(ownerscounter > 1);
        }

        pendingtransactions.push(Transaction(block.timestamp, msg.sender, _transtype, _amount, address(_to), 1, 0, 0, threshold));

        uint idtransaction = pendingtransactions.length - 1;
        signatures[msg.sender][idtransaction] = 1;
        
        if (pendingtransactions[idtransaction].signaturesCount == pendingtransactions[idtransaction].signthreshold) {
        _executetransaction(idtransaction);
        }

        emit PendingTransactionAdded(msg.sender, _transtype, _amount, _to);
    }


    // Executes transaction if signatures threshold is reached

    function _executetransaction(uint _index) internal {
      
        Transaction storage transaction = pendingtransactions[_index];    

        if (transaction.transtype == 1 || transaction.transtype == 2) {
            walletpool.withdrawyield(transaction.amount, transaction.transtype);
            emit WithdrawUnderlying(_index, transaction.amount);
        }

        if (transaction.transtype == 3) {
            walletpool.withdrawdonations(transaction.amount);
            emit WithdrawUnderlying(_index, transaction.amount);
        }    
                    
        if (transaction.transtype == 4) {
            require(walletunderlying.balanceOf(address(this)) >= transaction.amount); 
            require(walletunderlying.transfer(transaction.to, transaction.amount));
            emit TransferUnderlying(_index, transaction.to, transaction.amount);
        }
            
        if (transaction.transtype == 5) {
            require(signers[transaction.to] != 1);
            ownerscounter += 1;
                    
                if (signers[transaction.to] == 0) {
                    owners.push(OwnerState(transaction.to, 1));
                    signersindex[transaction.to] = owners.length - 1;
                }
                    
                if (signers[transaction.to] == 2) {
                    uint theindex = signersindex[transaction.to];
                    owners[theindex].thestate = 1;
                }

            signers[transaction.to] = 1;
                
            emit SignerAdded(_index, transaction.to);
        }

        if (transaction.transtype == 6) {
            require(transaction.amount > 0);
            require(transaction.amount <= ownerscounter);
            require(transaction.amount != threshold);

            threshold = transaction.amount;
                
            emit ThresholdChanged(_index, transaction.amount);
        }

        if (transaction.transtype == 7) {
            require(signers[transaction.to] == 1);
            require(ownerscounter > 1);

            signers[transaction.to] = 2;
            ownerscounter -= 1;
            uint theindex = signersindex[transaction.to];
            owners[theindex].thestate = 2;

            if (threshold > ownerscounter) {
                threshold -= 1;
            }
                
            emit SignerRemoved(_index, transaction.to);
        }    

        transaction.status = 1;
        transaction.dateexecution = block.timestamp;
}


    // Signs a transaction

    function signTransaction(uint _index) external nonReentrant {
        require(signers[msg.sender] == 1);
        require(pendingtransactions.length > 0 && _index <= pendingtransactions.length - 1);
        require(signatures[msg.sender][_index] == 0);
        require(pendingtransactions[_index].signaturesCount < pendingtransactions[_index].signthreshold);
        require(pendingtransactions[_index].status == 0);
            
        pendingtransactions[_index].signaturesCount += 1;
        signatures[msg.sender][_index] = 1;

        if(pendingtransactions[_index].signaturesCount == pendingtransactions[_index].signthreshold) {
            _executetransaction(_index);
        }

        emit TransactionSigned(msg.sender, _index);
    }


    // Revokes a previous signature

    function revokeSignature(uint _index) external nonReentrant {
        require(signers[msg.sender] == 1);
        require(pendingtransactions.length > 0 && _index <= pendingtransactions.length - 1);
        require(pendingtransactions[_index].status == 0);
        require(signatures[msg.sender][_index] == 1);

        pendingtransactions[_index].signaturesCount -= 1;
        signatures[msg.sender][_index] = 0;

        emit SignatureRevoked(msg.sender, _index);
}


    // Removes a pending transaction

    function deleteTransaction(uint _index) external nonReentrant {
        require(signers[msg.sender] == 1);
        require(pendingtransactions.length > 0 && _index <= pendingtransactions.length - 1);
        require(pendingtransactions[_index].status == 0);

        pendingtransactions[_index].status = 2;
        pendingtransactions[_index].dateexecution = block.timestamp;
    
        emit TransactionDeleted(msg.sender, _index);
    }


    // Returns an array of pending transactions

    function getPendingTransactions() external view returns (Transaction[] memory) {
        return pendingtransactions;
    }


    // Returns the wallet balance of the underlying 

    function getBalanceWallet() external view returns (uint) {
        return walletunderlying.balanceOf(address(this));
    }


    // Returns the length of the pending transactions array

    function getPendingTransactionsLength() external view returns (uint) {
        return pendingtransactions.length;
    }


    // Returns an array of wallet owners 

    function getOwners() external view returns (OwnerState[] memory) {
    return owners;
    }
  
}