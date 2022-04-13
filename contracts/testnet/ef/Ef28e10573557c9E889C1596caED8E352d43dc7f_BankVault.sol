// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract BankVault {
    address public owner;

    mapping(string=>mapping(address=>uint256)) public accountBalances;

    mapping(address=>mapping(string=>bool)) private hasAccount;
    mapping(address=>string[]) private availableAccounts;
    mapping(address=>uint64) private accountCounts;

    event newCredit(address user, address from, uint256 amount, string account, string note);
    event newDebit(address user, uint256 amount, string account, string note);
    event newBatchCredit(address[] users, address from, uint256[] amounts, string account, string note);
    event newBatchTransfer(address[] users, address from, uint256[] amounts, string account, string note);
    event newTransfer(address from, address to, uint256 amount, string fromAccount, string toAccount, string note);

    constructor () {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender==owner, 'Forbidden');
        owner = newOwner;
    }

    function accounts(address user) public view returns (string[] memory) {
        return availableAccounts[user];
    }

    function saveAccount(address user, string memory account) internal {
        if (!hasAccount[user][account]) {
            hasAccount[user][account] = true;
            availableAccounts[user].push(account);
            accountCounts[user] += 1;
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
        require(users.length>=amounts.length, "Array mismatch");
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
    function debit(string memory account) public {
        uint256 accountBalance = accountBalances[account][msg.sender];
        // Check the value in that account
        require(accountBalance > 0, "Zero balance");
        // Transfer the value
        accountBalances[account][msg.sender] = 0; // No replay
        payable(msg.sender).transfer(accountBalance);
        emit newDebit(msg.sender, accountBalance, account, "user");
    }

    // Internal transfer to many users
    function transferMany(address[] memory users, uint256[] memory amounts, string memory fromAccount, string memory toAccount, string memory note) public {
        // Verify the sum matches the received value
        uint256 valSum = fastSum(amounts);
        require(accountBalances[fromAccount][msg.sender]>=valSum, "Sum mismatch");
        require(users.length>=amounts.length, "Array mismatch");
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

    receive() external payable {
        
    }
    
    fallback() external payable {
        accountBalances["default"][msg.sender] = msg.value; // Credit the sender to the default account
    }
}