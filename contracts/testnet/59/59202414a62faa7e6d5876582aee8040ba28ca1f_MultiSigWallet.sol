/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/*
          _____                    _____                    _____                _____                    _____                    _____                _____          
         /\    \                  /\    \                  /\    \              /\    \                  /\    \                  /\    \              |\    \         
        /::\    \                /::\    \                /::\    \            /::\    \                /::\    \                /::\____\             |:\____\        
       /::::\    \              /::::\    \              /::::\    \           \:::\    \               \:::\    \              /::::|   |             |::|   |        
      /::::::\    \            /::::::\    \            /::::::\    \           \:::\    \               \:::\    \            /:::::|   |             |::|   |        
     /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \           \:::\    \               \:::\    \          /::::::|   |             |::|   |        
    /:::/  \:::\    \        /:::/__\:::\    \        /:::/__\:::\    \           \:::\    \               \:::\    \        /:::/|::|   |             |::|   |        
   /:::/    \:::\    \      /::::\   \:::\    \       \:::\   \:::\    \          /::::\    \              /::::\    \      /:::/ |::|   |             |::|   |        
  /:::/    / \:::\    \    /::::::\   \:::\    \    ___\:::\   \:::\    \        /::::::\    \    ____    /::::::\    \    /:::/  |::|   | _____       |::|___|______  
 /:::/    /   \:::\ ___\  /:::/\:::\   \:::\    \  /\   \:::\   \:::\    \      /:::/\:::\    \  /\   \  /:::/\:::\    \  /:::/   |::|   |/\    \      /::::::::\    \ 
/:::/____/     \:::|    |/:::/__\:::\   \:::\____\/::\   \:::\   \:::\____\    /:::/  \:::\____\/::\   \/:::/  \:::\____\/:: /    |::|   /::\____\    /::::::::::\____\
\:::\    \     /:::|____|\:::\   \:::\   \::/    /\:::\   \:::\   \::/    /   /:::/    \::/    /\:::\  /:::/    \::/    /\::/    /|::|  /:::/    /   /:::/~~~~/~~      
 \:::\    \   /:::/    /  \:::\   \:::\   \/____/  \:::\   \:::\   \/____/   /:::/    / \/____/  \:::\/:::/    / \/____/  \/____/ |::| /:::/    /   /:::/    /         
  \:::\    \ /:::/    /    \:::\   \:::\    \       \:::\   \:::\    \      /:::/    /            \::::::/    /                   |::|/:::/    /   /:::/    /          
   \:::\    /:::/    /      \:::\   \:::\____\       \:::\   \:::\____\    /:::/    /              \::::/____/                    |::::::/    /   /:::/    /           
    \:::\  /:::/    /        \:::\   \::/    /        \:::\  /:::/    /    \::/    /                \:::\    \                    |:::::/    /    \::/    /            
     \:::\/:::/    /          \:::\   \/____/          \:::\/:::/    /      \/____/                  \:::\    \                   |::::/    /      \/____/             
      \::::::/    /            \:::\    \               \::::::/    /                                 \:::\    \                  /:::/    /                           
       \::::/    /              \:::\____\               \::::/    /                                   \:::\____\                /:::/    /                            
        \::/____/                \::/    /                \::/    /                                     \::/    /                \::/    /                             
         ~~                       \/____/                  \/____/                                       \/____/                  \/____/                              
*/
pragma solidity ^0.4.24;

interface Token { function transfer(address to, uint256 value) external returns (bool success); }

contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 9;
//Transaction Events=======================================================================================
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);

//Transfer Events=======================================================================================
    event TConfirmation(address indexed sender, uint indexed tokentransferId);
    event TRevocation(address indexed sender, uint indexed tokentransferId);
    event TSubmission(uint indexed tokentransferId);
    event TExecution(uint indexed tokentransferId);
    event TExecutionFailure(uint indexed tokentransferId);
//Transaction Variables=======================================================================================
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
//Transfer Variables=======================================================================================
    mapping (uint => TokenTransfer) public tokentransfers;
    mapping (uint => mapping (address => bool)) public tokentransferconfirmations;
    uint public tokentransferCount;
//Transaction struct=======================================================================================
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

//Transfer struct=======================================================================================
    struct  TokenTransfer {
        address contractaddress;
        address destination;
        uint value;
        bytes data;
        bool executed;
    }
//Public modifiers=======================================================================================
    modifier notNull(address _address) {
        if (_address == 0||_address==address(0))
            throw;
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            throw;
        _;
    }
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
//Transaction modifiers=======================================================================================
    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0 || transactions[transactionId].destination == address(0)||transactions[transactionId].value <= 0)
            throw;
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            throw;
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner])
            throw;
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            throw;
        _;
    }
//Transfer modifiers=======================================================================================
    modifier tokentransferExists(uint tokentransferId) {
        if (tokentransfers[tokentransferId].destination == 0)
            throw;
        _;
    }

    modifier tokentransferconfirmed(uint tokentransferId, address owner) {
        if (!tokentransferconfirmations[tokentransferId][owner])
            throw;
        _;
    }

    modifier tokentransfernotConfirmed(uint tokentransferId, address owner) {
        if (tokentransferconfirmations[tokentransferId][owner])
            throw;
        _;
    }

    modifier tokentransfernotExecuted(uint tokentransferId) {
        if (tokentransfers[tokentransferId].executed)
            throw;
        _;
    }

    /// @dev Fallback function allows to deposit ether.=======================================================================================
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.=======================================================================================
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    constructor (address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
                throw;
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    function getOwners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

//Transaction event functions=======================================================================================
    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        onlyOwner
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }
    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
        internal
        onlyOwner
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        Submission(transactionId);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
        public
        onlyOwner
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        onlyOwner
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        onlyOwner
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        onlyOwner
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
            }
        }
    }
//Transfer view functions=======================================================================================
    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        onlyOwner
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        onlyOwner
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public
        onlyOwner
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

//Transfer event functions=======================================================================================

    /// @dev Returns the confirmation status of a tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    /// @return Confirmation status.
    function isConfirmedBytokentransferId(uint tokentransferId)
        public
        onlyOwner
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (tokentransferconfirmations[tokentransferId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }
    /*
     * Internal functions
     */
    /// @dev Adds a new tokentransfer to the tokentransfer mapping, if tokentransfer does not exist yet.
    /// @param destination TokenTransfer target address.
    /// @param value TokenTransfer ether value.
    /// @param data TokenTransfer data payload.
    /// @return Returns tokentransfer ID.
    function addTokenTransfer(address contractaddress, address destination, uint value, bytes data)
        internal
        onlyOwner
        notNull(destination)
        returns (uint tokentransferId)
    {
        tokentransferId = tokentransferCount;
        tokentransfers[tokentransferId] = TokenTransfer({
            contractaddress: contractaddress,
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        tokentransferCount += 1;
        TSubmission(tokentransferId);
    }

    /// @dev Allows an owner to submit and confirm a tokentransfer.
    /// @param destination TokenTransfer target address.
    /// @param value TokenTransfer ether value.
    /// @param data TokenTransfer data payload.
    /// @return Returns tokentransfer ID.
    function submitTokenTransfer(address contractaddress, address destination, uint value, bytes data)
        public
        onlyOwner
        returns (uint tokentransferId)
    {
        tokentransferId = addTokenTransfer(contractaddress, destination, value, data);
        confirmTokenTransfer(tokentransferId);
    }

    /// @dev Allows an owner to confirm a tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    function confirmTokenTransfer(uint tokentransferId)
        public
        onlyOwner
        tokentransferExists(tokentransferId)
        tokentransfernotConfirmed(tokentransferId, msg.sender)
    {
        tokentransferconfirmations[tokentransferId][msg.sender] = true;
        TConfirmation(msg.sender, tokentransferId);
        executeTokenTransfer(tokentransferId);
    }

    /// @dev Allows an owner to revoke a confirmation for a tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    function revokeConfirmationBytokentransferId(uint tokentransferId)
        public
        onlyOwner
        tokentransferconfirmed(tokentransferId, msg.sender)
        tokentransfernotExecuted(tokentransferId)
    {
        tokentransferconfirmations[tokentransferId][msg.sender] = false;
        TRevocation(msg.sender, tokentransferId);
    }


    function exetransfer(address contractaddress,address _to,uint256 amount)
        public 
        onlyOwner
        returns (bool success)
    {
        Token token = Token(contractaddress); //发送到token 
        require(success=token.transfer(_to, amount), "tx failed");
    } 
    /// @dev Allows anyone to execute a confirmed tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    function executeTokenTransfer(uint tokentransferId)
        public
        onlyOwner
        tokentransfernotExecuted(tokentransferId)
    {
        if (isConfirmedBytokentransferId(tokentransferId)) {
            TokenTransfer tx = tokentransfers[tokentransferId];
            tx.executed = true;
            if (exetransfer(tx.contractaddress,tx.destination,tx.value))
                TExecution(tokentransferId);
            else {
                TExecutionFailure(tokentransferId);
                tx.executed = false;
            }
        }
    }
//Transfer view functions=======================================================================================

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    /// @return Number of confirmations.
    function getConfirmationCountBytokentransferId(uint tokentransferId)
        public
        onlyOwner
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (tokentransferconfirmations[tokentransferId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of tokentransfers after filers are applied.
    /// @param pending Include pending tokentransfers.
    /// @param executed Include executed tokentransfers.
    /// @return Total number of tokentransfers after filters are applied.
    function getTokenTransferCount(bool pending, bool executed)
        public
        onlyOwner
        constant
        returns (uint count)
    {
        for (uint i=0; i<tokentransferCount; i++)
            if (   pending && !tokentransfers[i].executed
                || executed && tokentransfers[i].executed)
                count += 1;
    }


    /// @dev Returns array with owner addresses, which confirmed tokentransfer.
    /// @param tokentransferId TokenTransfer ID.
    /// @return Returns array of owner addresses.
    function getConfirmationsBytokentransferId(uint tokentransferId)
        public
        onlyOwner
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (tokentransferconfirmations[tokentransferId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }
}
/*
          _____                    _____                    _____                _____                    _____                    _____                _____          
         /\    \                  /\    \                  /\    \              /\    \                  /\    \                  /\    \              |\    \         
        /::\    \                /::\    \                /::\    \            /::\    \                /::\    \                /::\____\             |:\____\        
       /::::\    \              /::::\    \              /::::\    \           \:::\    \               \:::\    \              /::::|   |             |::|   |        
      /::::::\    \            /::::::\    \            /::::::\    \           \:::\    \               \:::\    \            /:::::|   |             |::|   |        
     /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \           \:::\    \               \:::\    \          /::::::|   |             |::|   |        
    /:::/  \:::\    \        /:::/__\:::\    \        /:::/__\:::\    \           \:::\    \               \:::\    \        /:::/|::|   |             |::|   |        
   /:::/    \:::\    \      /::::\   \:::\    \       \:::\   \:::\    \          /::::\    \              /::::\    \      /:::/ |::|   |             |::|   |        
  /:::/    / \:::\    \    /::::::\   \:::\    \    ___\:::\   \:::\    \        /::::::\    \    ____    /::::::\    \    /:::/  |::|   | _____       |::|___|______  
 /:::/    /   \:::\ ___\  /:::/\:::\   \:::\    \  /\   \:::\   \:::\    \      /:::/\:::\    \  /\   \  /:::/\:::\    \  /:::/   |::|   |/\    \      /::::::::\    \ 
/:::/____/     \:::|    |/:::/__\:::\   \:::\____\/::\   \:::\   \:::\____\    /:::/  \:::\____\/::\   \/:::/  \:::\____\/:: /    |::|   /::\____\    /::::::::::\____\
\:::\    \     /:::|____|\:::\   \:::\   \::/    /\:::\   \:::\   \::/    /   /:::/    \::/    /\:::\  /:::/    \::/    /\::/    /|::|  /:::/    /   /:::/~~~~/~~      
 \:::\    \   /:::/    /  \:::\   \:::\   \/____/  \:::\   \:::\   \/____/   /:::/    / \/____/  \:::\/:::/    / \/____/  \/____/ |::| /:::/    /   /:::/    /         
  \:::\    \ /:::/    /    \:::\   \:::\    \       \:::\   \:::\    \      /:::/    /            \::::::/    /                   |::|/:::/    /   /:::/    /          
   \:::\    /:::/    /      \:::\   \:::\____\       \:::\   \:::\____\    /:::/    /              \::::/____/                    |::::::/    /   /:::/    /           
    \:::\  /:::/    /        \:::\   \::/    /        \:::\  /:::/    /    \::/    /                \:::\    \                    |:::::/    /    \::/    /            
     \:::\/:::/    /          \:::\   \/____/          \:::\/:::/    /      \/____/                  \:::\    \                   |::::/    /      \/____/             
      \::::::/    /            \:::\    \               \::::::/    /                                 \:::\    \                  /:::/    /                           
       \::::/    /              \:::\____\               \::::/    /                                   \:::\____\                /:::/    /                            
        \::/____/                \::/    /                \::/    /                                     \::/    /                \::/    /                             
         ~~                       \/____/                  \/____/                                       \/____/                  \/____/                              
*/