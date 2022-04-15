// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title A secure decentralized Ether Bank Vault
/// @author 0xB0B
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.
contract BankVault {
    address public owner;

    constructor () {
        owner = msg.sender;
    }

    /*
        Banking
    */

    mapping(string=>mapping(address=>uint256)) public accountBalances;

    mapping(address=>mapping(string=>bool)) private hasAccount;
    mapping(address=>string[]) private availableAccounts;
    mapping(address=>uint64) private accountCounts;

    event newAccount(address user, string account);
    event newCredit(address user, address from, uint256 amount, string account, string note);
    event newDebit(address user, uint256 amount, string account, string note);
    event newBatchCredit(address[] users, address from, uint256[] amounts, string account, string note);
    event newBatchTransfer(address[] users, address from, uint256[] amounts, string account, string note);
    event newTransfer(address from, address to, uint256 amount, string fromAccount, string toAccount, string note);


    // Returns the user's list of accounts
    function accounts(address user) public view returns (string[] memory) {
        return availableAccounts[user];
    }

    // Return the balance of a user account
    function balance(address user, string memory account) public view returns (uint256) {
        return accountBalances[account][user];
    }

    // Return the balance of a all the accounts
    function balance(address user) public view returns (uint256) {
        uint256 totalBalance;
        uint i;
        uint l = accountCounts[user];
        for (i=0;i<l;i++) {
            totalBalance += accountBalances[availableAccounts[user][i]][user];
        }
        return totalBalance;
    }

    function saveAccount(address user, string memory account) internal {
        if (!hasAccount[user][account]) {
            hasAccount[user][account] = true;
            availableAccounts[user].push(account);
            accountCounts[user] += 1;
            emit newAccount(user, account);
        }
    }

    // Credit external value to a single user
    function credit(address user, string memory account, string memory note) public payable {
        accountBalances[account][user] += msg.value;
        saveAccount(user, account);
        emit newCredit(user, msg.sender, msg.value, account, note);
    }

    // Credit external value to an array of users
    function creditMany(address[] memory users, uint256[] memory amounts, string memory account, string memory note) public payable {
        // Verify the sum matches the received value
        uint256 valSum = fastSum(amounts);
        require(msg.value>=valSum, "Sum mismatch");
        require(users.length==amounts.length, "Array mismatch");
        // increment the value mappings
        uint i;
        uint l = users.length;
        for (i=0;i<l;i++) {
            accountBalances[account][users[i]] += amounts[i];
            saveAccount(users[i], account);
        }
        emit newBatchCredit(users, msg.sender, amounts, account, note);
    }

    // User debit
    function debit(string memory account, uint256 amount) public {
        uint256 accountBalance = accountBalances[account][msg.sender];
        // Check the value in that account
        require(accountBalance > amount, "Zero balance");
        // Transfer the value
        accountBalances[account][msg.sender] -= amount;
        payable(msg.sender).transfer(accountBalance);
        emit newDebit(msg.sender, amount, account, "User debit");
    }

    // User total withdraw: Empties all accounts
    function withdrawAll() public {
        uint256 totalBalance;
        uint i;
        uint l = accountCounts[msg.sender];
        for (i=0;i<l;i++) {
            totalBalance += accountBalances[availableAccounts[msg.sender][i]][msg.sender];
            accountBalances[availableAccounts[msg.sender][i]][msg.sender] = 0;
            emit newDebit(msg.sender, totalBalance, availableAccounts[msg.sender][i], "User withdrawal");
        }
        payable(msg.sender).transfer(totalBalance);
    }

    // Internal transfer to many users
    function transferMany(address[] memory users, uint256[] memory amounts, string memory fromAccount, string memory toAccount, string memory note) public {
        // Verify the sum matches the received value
        uint256 valSum = fastSum(amounts);
        require(accountBalances[fromAccount][msg.sender]>=valSum, "Sum mismatch");
        require(users.length==amounts.length, "Array mismatch");
        // Debit the account
        accountBalances[fromAccount][msg.sender] -= valSum;
        emit newDebit(msg.sender, valSum, fromAccount, note);
        // increment the value mappings
        uint i;
        uint l = users.length;
        for (i=0;i<l;i++) {
            accountBalances[toAccount][users[i]] += amounts[i];
            saveAccount(users[i], toAccount);
        }
        emit newBatchTransfer(users, msg.sender, amounts, toAccount, note);
    }

    // Internal transfer to a single user
    function transfer(address to, uint256 amount, string memory fromAccount, string memory toAccount, string memory note) public {
        require(accountBalances[fromAccount][msg.sender]>=amount, "Not enough balance");
        accountBalances[fromAccount][msg.sender] -= amount;
        accountBalances[toAccount][to] += amount;
        emit newTransfer(msg.sender, to, amount, fromAccount, toAccount, note);
        emit newDebit(msg.sender, amount, fromAccount, note);
        emit newCredit(to, msg.sender, amount, toAccount, note);
    }



    /*
        Escrow
    */
    struct escrow_struct {
        address user;
        uint256 amount;
        string account;
        string note;
    }
    // escrow_owner -> escrow_id -> data
    mapping(address=>mapping(uint256=>escrow_struct[])) public escrows;
    mapping(address=>mapping(uint256=>uint256)) public escrowCounts;
    mapping(address=>mapping(uint256=>uint32)) public escrowStatus; // 0:none, 1:open , 2:closed, 3:canceled

    event newEscrow(address escrow_owner, uint256 escrow_id);
    event escrowClosed(address escrow_owner, uint256 escrow_id);
    event escrowCanceled(address escrow_owner, uint256 escrow_id);

    // Get the escrow account name
    function escrowAccountName(address escrow_owner, uint256 escrow_id) internal pure returns (string memory) {
        return string(abi.encodePacked(escrow_owner,escrow_id));
    }

    // Lock a credit in an escrow that can be canceled or released by the escrow creator
    function escrow(uint256 escrow_id, address user, string memory account, string memory note) public payable {
        require(escrowStatus[msg.sender][escrow_id]==0||escrowStatus[msg.sender][escrow_id]==1, "Wrong escrow status");
        escrows[msg.sender][escrow_id].push(escrow_struct(user, msg.value, account, note));
        escrowCounts[msg.sender][escrow_id] += 1;
        if (escrowStatus[msg.sender][escrow_id]==0) {
            escrowStatus[msg.sender][escrow_id] = 1;
            emit newEscrow(msg.sender, escrow_id);
        }
        accountBalances[escrowAccountName(msg.sender, escrow_id)][address(this)] += msg.value;
    }

    // Close an escrow, releasing the funds to their respective accounts
    function closeEscrow(uint256 escrow_id) public returns (bool) {
        if (escrowStatus[msg.sender][escrow_id]!=1) {
            return false;
        }
        escrowStatus[msg.sender][escrow_id] = 2;
        accountBalances[escrowAccountName(msg.sender, escrow_id)][address(this)] = 0; // Empty the escrow account
        uint256 i;
        uint256 l = escrowCounts[msg.sender][escrow_id];
        for (i=0;i<l;i++) {
            escrow_struct memory escrowObj = escrows[msg.sender][escrow_id][i];
            accountBalances[escrowObj.account][escrowObj.user] += escrowObj.amount;
            emit newCredit(escrowObj.user, msg.sender, escrowObj.amount, escrowObj.account, escrowObj.note);
        }
        emit escrowClosed(msg.sender, escrow_id);
        return true;
    }

    // Close an escrow, releasing the funds to their respective accounts
    function cancelEscrow(uint256 escrow_id) public {
        require(escrowStatus[msg.sender][escrow_id]==1, "Wrong escrow status");
        escrowStatus[msg.sender][escrow_id] = 3;
        uint256 i;
        uint256 l = escrowCounts[msg.sender][escrow_id];
        for (i=0;i<l;i++) {
            escrow_struct memory escrowObj = escrows[msg.sender][escrow_id][i];
            payable(escrowObj.user).transfer(escrowObj.amount);
        }
        emit escrowCanceled(msg.sender, escrow_id);
    }



    /*
        Utilities fallbacks
    */


    // Assembly sum
    function fastSum(uint256[] memory _data) internal pure returns (uint sum) {
        assembly {
            let len := mload(_data)
            let data := add(_data, 0x20)
            for
                { let end := add(data, mul(len, 0x20)) }
                lt(data, end)
                { data := add(data, 0x20) }
            {
                sum := add(sum, mload(data))
            }
        }
    }

    // Ownership Transfer (no point in ownership tho)
    function transferOwnership(address newOwner) public {
        require(msg.sender==owner, 'Forbidden');
        owner = newOwner;
    }

    receive() external payable {
        
    }
    
    // Direct transfer, assign the value to the user's default account so they can withdraw it back
    fallback() external payable {
        accountBalances["default"][msg.sender] += msg.value; // Credit the sender to the default account
        emit newCredit(msg.sender, msg.sender, msg.value, "default", "Direct transfer to the vault");
    }
}