/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// Sources flattened with hardhat v2.10.2 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/MultiSig.sol
pragma solidity ^0.8.4;
contract MultiSig is Ownable {
    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);

    /*
     *  views
     */
    uint256 public constant MAX_OWNER_COUNT = 10;

    /*
     *  Storage
     */
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    mapping(uint256 => uint256) public executionTime;
    address[] owners;
    uint256 public required;
    uint256 public transactionCount;
    uint256 public delayTime;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(
            msg.sender == address(this),
            "MultiSig: For contract execution only"
        );
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner], "MultiSig: User must not be owner");
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner], "MultiSig: User must be owner");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(
            transactions[transactionId].destination != address(0),
            "MultiSig: Transaction must exist"
        );
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        require(
            confirmations[transactionId][owner],
            "MultiSig: User must have confirmed transaction"
        );
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner],"MultiSig: User must not have confirmed transaction");
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "MultiSig: Transaction proceed");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), "MultiSig: Not null");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {
        require(
            ownerCount <= MAX_OWNER_COUNT &&
                _required <= ownerCount &&
                _required != 0 &&
                ownerCount != 0
        );
        _;
    }

    modifier isExecutionTime(uint256 transactionId) {
        require(
            block.timestamp > executionTime[transactionId],
            "not execution time"
        );
        _;
    }

    // @dev Contract constructor sets initial owners and required number of confirmations.
    // @param _owners List of initial owners.
    // @param _required Number of required confirmations.
    // @param _delayTime Number of seconds delay transaction
    constructor(
        address[] memory _owners,
        uint256 _required,
        uint256 _delayTime
    ) validRequirement(_owners.length, _required) {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        delayTime = _delayTime;
    }

    // @dev Allows to add a new owner. Transaction has to be sent by wallet.
    // @param owner Address of new owner.
    function addOwner(address owner)
        external
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
        onlyOwner
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    // @dev Allows to remove an owner. Transaction has to be sent by wallet.
    // @param owner Address of owner.
    function removeOwner(address owner) external onlyOwner ownerExists(owner) {
        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[(owners.length - 1)];
                owners.pop();
                break;
            }

        if (required > owners.length) changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    // @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    // @param owner Address of owner to be replaced.
    // @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        external
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
        onlyOwner
    {
        for (uint256 i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    // @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    // @param _required Number of required confirmations.
    function changeRequirement(uint256 _required)
        public
        validRequirement(owners.length, _required)
        onlyOwner
    {
        required = _required;
        emit RequirementChange(_required);
    }

    // @dev Allows an owner to submit and confirm a transaction.
    // @param destination Transaction target address.
    // @param value Transaction ether value.
    // @param data Transaction data payload.
    // @return Returns transaction ID.
    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) external ownerExists(msg.sender) returns (uint256 transactionId) {
        transactionId = addTransaction(destination, value, data);
        executionTime[transactionId] = block.timestamp + delayTime;
        confirmTransaction(transactionId);
    }

    // @dev Allows an owner to confirm a transaction.
    // @param transactionId Transaction ID.
    function confirmTransaction(uint256 _transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(_transactionId)
        notConfirmed(_transactionId, msg.sender)
    {
        require(!isTimeOver(_transactionId), "Time over");
        confirmations[_transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, _transactionId);
    }

    // @dev Allows an owner to revoke a confirmation for a transaction.
    // @param transactionId Transaction ID.
    function revokeConfirmation(uint256 _transactionId)
        external
        ownerExists(msg.sender)
        confirmed(_transactionId, msg.sender)
        notExecuted(_transactionId)
    {
        require(!isTimeOver(_transactionId), "Time over");
        confirmations[_transactionId][msg.sender] = false;
        emit Revocation(msg.sender, _transactionId);
    }

    // @dev Allows anyone to execute a confirmed transaction.
    // @param transactionId Transaction ID.
    function executeTransaction(uint256 transactionId)
        external
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
        isExecutionTime(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            require(
                external_call(
                    txn.destination,
                    txn.value,
                    txn.data.length,
                    txn.data
                ),
                "execution failed"
            );
        }
    }

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(
        address destination,
        uint256 value,
        uint256 dataLength,
        bytes memory data
    ) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40) // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas(), 150710), // 34710 is the value that solidity is currently emitting
                // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                d,
                dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0 // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    // @dev Returns the confirmation status of a transaction.
    // @param transactionId Transaction ID.
    // @return Confirmation status.
    function isConfirmed(uint256 transactionId) public view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) count += 1;
        }

        return count >= required;
    }

    /*
     * Internal functions
     */
    // @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    // @param destination Transaction target address.
    // @param value Transaction ether value.
    // @param data Transaction data payload.
    // @return Returns transaction ID.
    function addTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) internal notNull(destination) returns (uint256 transactionId) {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    function isTimeOver(uint256 _transactionId) internal view returns (bool) {
        return block.timestamp > executionTime[_transactionId];
    }

    /*
     * Web3 call functions
     */
    // @dev Returns number of confirmations of a transaction.
    // @param transactionId Transaction ID.
    // @return Number of confirmations.
    function getConfirmationCount(uint256 transactionId)
        external
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) count += 1;
    }

    // @dev Returns total number of transactions after filers are applied.
    // @param pending Include pending transactions.
    // @param executed Include executed transactions.
    // @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        external
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    // @dev Returns list of owners.
    // @return List of owner addresses.
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    // @dev Returns array with owner addresses, which confirmed transaction.
    // @param transactionId Transaction ID.
    // @return Returns array of owner addresses.
    function getConfirmations(uint256 transactionId)
        external
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    // @dev Returns list of transaction IDs in defined range.
    // @param from Index start position of transaction array.
    // @param to Index end position of transaction array.
    // @param pending Include pending transactions.
    // @param executed Include executed transactions.
    // @return Returns array of transaction IDs.
    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) external view returns (uint256[] memory _transactionIds) {
        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}