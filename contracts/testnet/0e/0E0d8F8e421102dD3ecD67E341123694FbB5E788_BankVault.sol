// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface Referral {
    function refer(address user, address referrer) external returns (bool);
    function addAdmin(address admin) external view;
    function disableAdmin(address admin) external view;
    function get(address user) external view returns (bool, address);
}

contract BankVault {
    address public owner;

    mapping(string=>mapping(address=>uint256)) public accountBalances;

    mapping(address=>mapping(string=>bool)) private _hasAccount;
    mapping(address=>string[]) public availableAccounts;

    event newCredit(address[] addrs, uint256[] values, string account);
    event newDebit(address user, uint256 value, string account);

    constructor () {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender==owner, 'Forbidden');
        owner = newOwner;
    }

    function saveAccount(address user, string memory account) internal {
        if (!_hasAccount[user][account]) {
            _hasAccount[user][account] = true;
            availableAccounts[user].push(account);
        }
    }

    function credit(address[] memory addrs, uint256[] memory values, string memory account) public payable {
        // Verify the sum matches the received value
        uint256 valSum = fastSum(values);
        require(msg.value>=valSum, "Sum mismatch");
        require(addrs.length>=values.length, "Array mismatch");
        // increment the value mappings
        uint i;
        uint l = addrs.length;
        for (i=0;i<l;i++) {
            accountBalances[account][addrs[i]] += values[i];
            saveAccount(addrs[i], account);
        }
        emit newCredit(addrs, values, account);
    }

    function debit(string memory account) public {
        uint256 accountBalance = accountBalances[account][msg.sender];
        // Check the value in that account
        require(accountBalance > 0, "Zero balance");
        // Transfer the value
        accountBalances[account][msg.sender] = 0; // No replay
        payable(msg.sender).transfer(accountBalance);
        emit newDebit(msg.sender, accountBalance, account);
    }

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
        
    }
}