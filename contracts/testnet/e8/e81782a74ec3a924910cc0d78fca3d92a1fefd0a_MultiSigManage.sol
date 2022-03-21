/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ERC20Basic {
    function signTransfer(address to, uint256 value) external;
}

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract MultiSigManage {
    uint256 constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event ReceiveDeposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);

    mapping (uint256 => Tran) public trans;
    mapping (uint256 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    string internal strTransfer = "transfer";
    string internal strAddOwner = "addOwner";
    string internal strRemoveOwner = "removeOwner";
    string internal strReplaceOwner = "replaceOwner";
    string internal strChangeRequirement = "changeRequirement";

    //Transaction容易与Solidity关键字冲突
    struct Tran {
        address destination;
        address to;
        uint256 value;
        //bytes data;
        string funcname;
        bool executed;
    }

    //event Log(string a, address addr);

    /*
    //出现问题，经过查询USDT对应的多重签名合约的交易数据中，所有操作与onlyWallet检查的，都是失败
    modifier onlyWallet() {
        //emit Log("msg.sender:", msg.sender);
        require(msg.sender == address(this), "msg.sender not.");
        if (msg.sender != address(this))
            revert();
        _;
    }*/

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            revert();
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            revert();
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        if (trans[transactionId].destination == address(0))
            revert();
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        if (confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        if (trans[transactionId].executed)
            revert();
        _;
    }

    modifier notNull(address _address) {
        if (_address == address(0))
            revert();
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            revert();
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    fallback() payable external {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    receive() payable external {
        // React to receiving ether
        if (msg.value > 0)
            emit ReceiveDeposit(msg.sender, msg.value);
    }


    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    //数组参数传参：["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
    constructor(address[] memory _owners, uint256 _required)
        validRequirement(_owners.length, _required)
    {
        for (uint256 i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == address(0))
                revert();
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        transactionCount = 1;//事务id从1开始

        emit RequirementChange(required);
    }

    //两个字符串比较
    function hashCompareStr(string memory a, string memory b) internal pure returns (bool result) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    /*
    function test() public {
        emit Log("msg.sender:", msg.sender);
    }

    function testTransfer(address _contractAddr, address _to, uint256 value) public {
        try ERC20Basic(_contractAddr).transfer(_to, value) {
            emit Execution(10000);
        } catch {
            emit ExecutionFailure(10001);
        }
    }*/

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        internal
        //onlyWallet
        ownerExists(msg.sender)//操作人必须是在owners中
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        internal
        //onlyWallet
        ownerExists(msg.sender)//操作人必须是在owners中
        ownerExists(owner)
    {
        isOwner[owner] = false;//mapping没有删除功能，遍历mapping会提高手续费，使用软删除标记被删除数据状态
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
                //delete owners[i];//长度不会变，删除的元素为变为0x0000000000000000000000000000000000000000
            } 
        }
        owners.pop();//数组长度减1，length为只读，不可修改
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param owner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        internal
        //onlyWallet
        ownerExists(msg.sender)//操作人必须是在owners中
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint256 i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint256 _required)
        internal
        //onlyWallet
        ownerExists(msg.sender)//操作人必须是在owners中
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    ///// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
    function submitTransaction(address destination, address _to, uint256 value, string memory funcname)//, bytes memory data
        public
        returns (uint256 transactionId)
    {
        transactionId = addTransaction(destination, _to, value, funcname);//, data
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        execTran(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        //撤销是在确认的前提下撤销，即已经确认了，但觉得不对，并且事务还未执行前，可撤销确认
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    // 在MultiSigWalletWithDailyLimit中重写了此方法，所以这里需要使用virtual修饰
    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function execTran(uint256 transactionId) 
        internal
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            trans[transactionId].executed = true;
            
            string memory funcname = trans[transactionId].funcname;
            if(hashCompareStr(funcname, strTransfer)) {
                try ERC20Basic(trans[transactionId].destination).signTransfer(trans[transactionId].to, trans[transactionId].value) {
                    emit Execution(transactionId);
                } catch {
                    trans[transactionId].executed = false;
                    emit ExecutionFailure(transactionId);
                }
            } else if(hashCompareStr(funcname, strAddOwner)) {
                addOwner(trans[transactionId].destination);
            } else if(hashCompareStr(funcname, strRemoveOwner)) {
                removeOwner(trans[transactionId].destination);
            } else if(hashCompareStr(funcname, strReplaceOwner)) {
                replaceOwner(trans[transactionId].destination, trans[transactionId].to);
            } else if(hashCompareStr(funcname, strChangeRequirement)) {
                changeRequirement(trans[transactionId].value);
            }
            
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint256 transactionId)
        public
        view
        returns (bool)
    {
        uint256 count = 0;
        for (uint256 i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
        }
        if (count >= required)
            return true;

        return false;
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    ///// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
    function addTransaction(address destination, address _to, uint256 value, string memory funcname)//, bytes memory data
        internal
        notNull(destination)
        returns (uint256 transactionId)
    {
        if(hashCompareStr(funcname, strTransfer)) { 
            //增发、赎回、转账。必须是合约地址
            require(Address.isContract(destination), "not a contract address");
        } else {
            require(destination != address(0), "destination address error");
        }
        if(hashCompareStr(funcname, strTransfer)) {
            require(_to != address(0), "_to address error");
        }
        transactionId = transactionCount;
        trans[transactionId] = Tran({
            destination: destination,
            to: _to, 
            value: value,
            //data: data,
            funcname: funcname,
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
    function getConfirmationCount(uint256 transactionId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return count Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i=0; i<transactionCount; i++)
            if (   pending && !trans[i].executed
                || executed && trans[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public
        view
        returns (address[] memory)
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return _confirmations Returns array of owner addresses.
    function getConfirmations(uint256 transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return _transactionIds Returns array of transaction IDs.
    function getTransactionIds(uint256 from, uint256 to, bool pending, bool executed)
        public
        view
        returns (uint256[] memory _transactionIds)
    {
        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !trans[i].executed
                || executed && trans[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }

}