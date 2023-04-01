// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

pragma solidity 0.8.9;
import '@openzeppelin/contracts/access/Ownable.sol';

contract MultiSigWallet is Ownable {
    uint256 public constant MAX_member_COUNT = 20;

    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event MemberAddition(address indexed member);
    event MemberRemoval(address indexed member);
    event RequirementChange(uint256 required);

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isMember;
    address[] public members;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this), 'only for Wallet call');
        _;
    }

    modifier memberDoesNotExist(address member) {
        require(!isMember[member], 'member exists');
        _;
    }

    modifier memberExists(address member) {
        require(isMember[member], 'member not exist');
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(
            transactions[transactionId].destination != address(0),
            'transaction not exist'
        );
        _;
    }

    modifier confirmed(uint256 transactionId, address member) {
        require(
            confirmations[transactionId][member],
            'transaction not comfired'
        );
        _;
    }

    modifier notConfirmed(uint256 transactionId, address member) {
        require(!confirmations[transactionId][member], 'transaction comfired');
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, 'transaction executed');
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), 'address is null');
        _;
    }

    modifier validRequirement(uint256 memberCount, uint256 _required) {
        require(
            memberCount <= MAX_member_COUNT &&
                _required <= memberCount &&
                _required != 0 &&
                memberCount != 0,
            'error'
        );
        _;
    }

    constructor(
        address[] memory _members,
        uint256 _required
    ) validRequirement(_members.length, _required) {
        for (uint256 i = 0; i < _members.length; i++) {
            require(_members[i] != address(0), 'address is null');
            isMember[_members[i]] = true;
        }
        members = _members;
        required = _required;
    }

    /// @dev Allows to add a new member. Transaction has to be sent by wallet.
    /// @param member Address of new member.
    function addMember(
        address member
    )
        public
        onlyWallet
        memberDoesNotExist(member)
        notNull(member)
        validRequirement(members.length + 1, required)
    {
        isMember[member] = true;
        members.push(member);
        emit MemberAddition(member);
    }

    /// @dev Allows to remove an member. Transaction has to be sent by wallet.
    /// @param member Address of member.
    function removeMember(
        address member
    ) public onlyWallet memberExists(member) {
        isMember[member] = false;
        for (uint256 i = 0; i < members.length - 1; i++)
            if (members[i] == member) {
                members[i] = members[members.length - 1];
                break;
            }
        if (required > members.length) changeRequirement(members.length);
        emit MemberRemoval(member);
    }

    // /// @dev Allows to replace an member with a new member. Transaction has to be sent by wallet.
    // /// @param member Address of member to be replaced.
    // /// @param member Address of new member.
    // function replaceMember(address member, address newMember)
    //     public
    //     onlyWallet
    //     memberExists(member)
    //     memberDoesNotExist(newMember)
    // {
    //     for (uint256 i = 0; i < members.length; i++)
    //         if (members[i] == member) {
    //             members[i] = newMember;
    //             break;
    //         }
    //     isMember[member] = false;
    //     isMember[newMember] = true;
    //     emit MemberRemoval(member);
    //     emit MemberAddition(newMember);
    // }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(
        uint256 _required
    ) public onlyWallet validRequirement(members.length, _required) {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an member to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) public onlyOwner returns (uint256 transactionId) {
        transactionId = addTransaction(destination, value, data);
        // confirmTransaction(transactionId);
    }

    /// @dev Allows an member to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(
        uint256 transactionId
    )
        public
        memberExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an member to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(
        uint256 transactionId
    )
        public
        memberExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(
        uint256 transactionId
    ) public notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage transaction = transactions[transactionId];
            transaction.executed = true;
            (bool success, ) = transaction.destination.call{
                value: transaction.value
            }(transaction.data);
            if (success) emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                transaction.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint256 transactionId) public view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < members.length; i++) {
            if (confirmations[transactionId][members[i]]) count += 1;
            if (count == required) return true;
        }
        return false;
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
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

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return count Number of confirmations.
    function getConfirmationCount(
        uint256 transactionId
    ) public view returns (uint256 count) {
        for (uint256 i = 0; i < members.length; i++)
            if (confirmations[transactionId][members[i]]) count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return count Total number of transactions after filters are applied.
    function getTransactionCount(
        bool pending,
        bool executed
    ) public view returns (uint256 count) {
        for (uint256 i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    /// @dev Returns list of members.
    /// @return List of member addresses.
    function getmembers() public view returns (address[] memory) {
        return members;
    }

    /// @dev Returns array with member addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return _confirmations Returns array of member addresses.
    function getConfirmations(
        uint256 transactionId
    ) public view returns (address[] memory _confirmations) {
        address[] memory confirmationsTemp = new address[](members.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < members.length; i++)
            if (confirmations[transactionId][members[i]]) {
                confirmationsTemp[count] = members[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    // function getTransactionIds(
    //     uint256 from,
    //     uint256 to,
    //     bool pending,
    //     bool executed
    // ) public view returns (uint256[] memory _transactionIds) {
    //     uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
    //     uint256 count = 0;
    //     uint256 i;
    //     for (i = 0; i < transactionCount; i++)
    //         if (
    //             (pending && !transactions[i].executed) ||
    //             (executed && transactions[i].executed)
    //         ) {
    //             transactionIdsTemp[count] = i;
    //             count += 1;
    //         }
    //     _transactionIds = new uint256[](to - from);
    //     for (i = from; i < to; i++)
    //         _transactionIds[i - from] = transactionIdsTemp[i];
    // }
}