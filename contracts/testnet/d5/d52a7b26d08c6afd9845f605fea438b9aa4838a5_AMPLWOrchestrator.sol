pragma solidity 0.4.24;

import "./Ownable.sol";
import "./AMPLWPolicy.sol";

contract AMPLWOrchestrator is Ownable {

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);
    Transaction[] public transactions;
    AMPLWPolicy public policy;
    mapping(address => bool) public isAdmin;

    constructor(address policy_) public {
        Ownable.initialize(msg.sender);
        policy = AMPLWPolicy(policy_);
    }
    
     function addAdmin(address _admin)
        external 
        onlyOwner 
    {
        isAdmin[_admin] = true; 
    }

    function rebase()
        external 
        onlyAdmin
    {
        require(msg.sender == tx.origin);  

        policy.rebase();

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    }
    
    function rebase(uint256 _price)
        external 
        onlyAdmin
    {
        policy.EmergencyRebase(_price);
    }

    function addTransaction(address destination, bytes data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }

    function removeTransaction(uint index)
        external
        onlyOwner
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    function transactionsSize()
        external
        view
        returns (uint256)
    {
        return transactions.length;
    }

    function externalCall(address destination, bytes data)
        internal
        returns (bool)
    {
        bool result;
        assembly {  
            let outputAddress := mload(0x40)
            let dataAddress := add(data, 32)

            result := call(
                sub(gas, 34710),
                destination,
                0, 
                dataAddress,
                mload(data),  
                outputAddress,
                0  
            )
        }
        return result;
    }
    
    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "only admin can call rebase method");
        _;
    }
}