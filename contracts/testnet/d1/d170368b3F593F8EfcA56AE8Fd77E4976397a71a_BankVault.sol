// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title Bank Vault
/// @author 0x6Fa02ed6248A4a78609368441265a5798ebaFC78
/// @notice A secure decentralized Ether Bank Vault. Store Ether on multiple accounts only you have access to. Transfers, debits, credit many, escrow, ...
/// @dev Built as an Ether vault for Rounds V4. Free to use.
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


    /// @notice Returns the user's list of accounts
    /// @param user User Address
    /// @return accounts An array of account names
    function accounts(address user) public view returns (string[] memory) {
        return availableAccounts[user];
    }


    /// @notice Returns the balance of a user account
    /// @param user User Address
    /// @param account Account name
    /// @return balance The account balance
    function balance(address user, string memory account) public view returns (uint256) {
        return accountBalances[account][user];
    }

    /// @notice Return the balance of a all the accounts
    /// @param user User Address
    function balance(address user) public view returns (uint256) {
        uint256 totalBalance;
        uint i;
        uint l = accountCounts[user];
        for (i=0;i<l;i++) {
            totalBalance += accountBalances[availableAccounts[user][i]][user];
        }
        return totalBalance;
    }

    /// @notice Internal, record that the user has a new account.
    /// @param user User Address
    /// @param account Account name
    function saveAccount(address user, string memory account) internal {
        if (!hasAccount[user][account]) {
            hasAccount[user][account] = true;
            availableAccounts[user].push(account);
            accountCounts[user] += 1;
            emit newAccount(user, account);
        }
    }

    /// @notice Credit external value to a single user
    /// @param user User Address
    /// @param account Account name
    /// @param note Note attached to the operation
    function credit(address user, string memory account, string memory note) public payable {
        accountBalances[account][user] += msg.value;
        saveAccount(user, account);
        emit newCredit(user, msg.sender, msg.value, account, note);
    }

    /// @notice Credit external value to an array of users. The value sent must match `sum(amounts[])`
    /// @param users Array of addresses
    /// @param amounts Array of amounts in wei
    /// @param account Account name where that value is received
    /// @param note Note attached to the operation
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

        // Refund the extra is the crezator overpays the fees
        if (msg.value>valSum) {
            uint256 overpaid = msg.value-valSum;
            accountBalances["Overpaid"][msg.sender] += overpaid;
            emit newCredit(msg.sender, msg.sender, overpaid, "Overpaid", note);
        }
    }

    /// @notice User debit
    /// @param account Account name
    /// @param amount Amount to debit in wei
    function debit(string memory account, uint256 amount) public {
        uint256 accountBalance = accountBalances[account][msg.sender];
        // Check the value in that account
        require(accountBalance >= amount, "Zero balance");
        // Transfer the value
        accountBalances[account][msg.sender] -= amount;
        payable(msg.sender).transfer(accountBalance);
        emit newDebit(msg.sender, amount, account, "User debit");
    }

    /// @notice User total withdraw: Empties all accounts
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

    /// @notice Internal transfer to many users.
    /// @param users Array of addresses
    /// @param amounts Array of amounts in wei
    /// @param fromAccount Account name from which to debit (sender)
    /// @param toAccount Account name where that value is received (recipients)
    /// @param note Note attached to the operation
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

    /// @notice Internal transfer to a single user
    /// @param to Address of the recipient
    /// @param amount Amount to transfer
    /// @param fromAccount Account name from which to debit (sender)
    /// @param toAccount Account name where that value is received (recipient)
    /// @param note Note attached to the operation
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


    /// @notice Returns a dynamic account name for an escrow. Internal function.
    /// @param escrow_owner Owner of the escrow
    /// @param escrow_id Escrow ID
    /// @return accountName The generated account name
    function escrowAccountName(address escrow_owner, uint256 escrow_id) internal pure returns (string memory) {
        return string(abi.encodePacked(escrow_owner,escrow_id));
    }

    /// @notice Escrow some value. Transfered on closing, returned to the sender on cancelation. Multiple escrow can be done under a single escrow ID, as long as that escrow is open.
    /// @dev `msg.sender` is the escrow owner. Multiple senders can use the same escrow ID, as they are unique per owner.
    /// @param escrow_id Escrow ID
    /// @param user The recipient
    /// @param account Account on which to transfer the value on closing
    /// @param note Note attached to the operation
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

    /// @notice Close an escrow, releasing the funds to their respective accounts
    /// @dev Doesn't break on failure as to not fail transactions that calls it.
    /// @param escrow_id Escrow ID
    /// @return success True if the escrow was successfully closed. Failure if the escrow wasn't open.
    function closeEscrow(uint256 escrow_id) public returns (bool) {
        if (escrowStatus[msg.sender][escrow_id]!=1) {
            return false;
        }
        escrowStatus[msg.sender][escrow_id] = 2; // Closed
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

    /// @notice Cancel an escrow, releasing the funds to their respective accounts
    /// @dev Doesn't break on failure as to not fail transactions that calls it.
    /// @param escrow_id Escrow ID
    /// @return success True if the escrow was successfully closed. Failure if the escrow wasn't open.
    function cancelEscrow(uint256 escrow_id) public returns (bool) {
        if (escrowStatus[msg.sender][escrow_id]!=1) {
            return false;
        }
        escrowStatus[msg.sender][escrow_id] = 3; // Canceled
        uint256 i;
        uint256 l = escrowCounts[msg.sender][escrow_id];
        uint256 sum;
        for (i=0;i<l;i++) {
            escrow_struct memory escrowObj = escrows[msg.sender][escrow_id][i];
            sum += escrowObj.amount;
        }
        payable(msg.sender).transfer(sum);
        emit escrowCanceled(msg.sender, escrow_id);
        return true;
    }



    /*
        Utilities fallbacks
    */


    /// @notice Fast Sum in assembly, for gas efficiency. Internal.
    /// @param _data Array of uint256 to sum
    /// @return sum Sum of the values
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

    /// @notice Transfer ownership of the Vault. An owner has no power.
    /// @param newOwner Address of the new owner
    function transferOwnership(address newOwner) public {
        require(msg.sender==owner, 'Forbidden');
        owner = newOwner;
    }

    receive() external payable {
        
    }
    
    /// @notice Direct transfer, assign the value to the user's default account so they can withdraw it back
    fallback() external payable {
        accountBalances["default"][msg.sender] += msg.value; // Credit the sender to the default account
        emit newCredit(msg.sender, msg.sender, msg.value, "default", "Direct transfer to the vault");
    }
}