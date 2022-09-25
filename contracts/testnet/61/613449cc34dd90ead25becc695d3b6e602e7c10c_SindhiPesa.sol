/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SindhiPesa {

    string public name = "Sindhi Pesa";
    string public symbol = "SNDP";
    uint8 public decimals = 6;
    uint256 public totalSupply = 1000000 * 10 ** decimals; // 1,000,000


    uint transactionFees = 1 * 10 ** (decimals - 1); // 0.1%
    bool transactionsPaused = false;

    address public burnWallet;
    bool isBurnWalletSet = false;

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public blacklisted;

    // events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event TokenInfoChange(string infoType, string previous, string newInfo);

    constructor  () payable  {
        owner = msg.sender;
        balances[owner] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);
    }

    // only the owner of token can mint
    function mint(address receiver, uint amount) public {
        require(msg.sender == owner);

        balances[receiver] += amount;
        totalSupply += amount;
    }

    // only owner can burn
    function burn(uint amount) public {
        require(msg.sender == owner);
        require(isBurnWalletSet == true);
        require(balances[burnWallet] >= amount);

        balances[burnWallet] -= amount;
        totalSupply -= amount;
    }

    
    // only owner can change transaction fees
    function changeTransactionFees(uint newFees) public {
        require(msg.sender == owner, "Only the owner can change the transaction fees.");

        transactionFees = newFees;
    }

    // owner can assign someone else as a new owner
    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "Only the owner can assign new owner.");

        owner = newOwner;
    }

    // token name and symbol can be changed later if there is any copyright problem
    // or if exchanges require us so, as a demand for listing (due to copyright)
    // after informing all investors, for sure
    function changeName(string calldata newName) public {
        require(msg.sender == owner, "Only the owner can change token info.");

        string memory old = name;
        name = newName;

        emit TokenInfoChange("name", old, name);
    }

    function changeSymbol(string calldata newSymbol) public {
        require(msg.sender == owner, "Only the owner can change token info.");

        string memory old = symbol;
        symbol = newSymbol;

        emit TokenInfoChange("symbol", old, newSymbol);
    }
    

    function setBurnWallet(address wallet) public {
        require(msg.sender == owner, "Only the owner can set burn wallet.");

        burnWallet = wallet;
    }


    // only owner can blacklist someone
    function blacklist(address person) public {
        require(msg.sender == owner, "Only the owner can blacklist someone.");

        blacklisted[person] = true;
    }

    // only the owner can remove someone from blacklist
    function removeFromBlacklist(address person) public {
        require(msg.sender == owner, "Only the owner can remove someone from blacklist.");

        blacklisted[person] = false;
    }
    
    
    // transactions can be paused by owner
    // in case of vulneribility or due to other factors
    function pauseTransactions() public {
        require(msg.sender == owner, "Only the owner can pause transactions.");

        transactionsPaused = true;
    }

    function unpauseTransactions() public {
        require(msg.sender == owner, "Only the owner can unpause transactions.");

        transactionsPaused = false;
    }

    function calculateTransactionFees(uint amount) public view returns (uint256) {
        return ((amount * transactionFees) / 100) / (10 ** decimals);
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
    
        emit Approval(msg.sender, spender, value);
    
        return true;   
    }

    function transfer(address to, uint256 amount) public returns (bool success) {
        require(balanceOf(msg.sender) >= amount, 'Balance too low');
        require(blacklisted[msg.sender] != true, "Sender is blacklisted.");
        require(blacklisted[to] != true, "Receiver is blacklisted.");
        require(transactionsPaused == false, "Transactions are paused at the moment.");

        uint fees = calculateTransactionFees(amount);
        balances[owner] += fees;

        uint remaining = amount - fees;

        balances[msg.sender] -= amount;
        balances[to] += remaining;

        emit Transfer(msg.sender, owner, fees);
        emit Transfer(msg.sender, to, remaining);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns(bool success) {

        require(balanceOf(from) >= amount, 'Balance too low');
        require(allowance[from][msg.sender] >= amount, 'Allowance too low');
        require(blacklisted[from] != true, "Sender is blacklisted.");
        require(blacklisted[to] != true, "Receiver is blacklisted.");
        require(transactionsPaused == false, "Transactions are paused at the moment.");

        uint fees = calculateTransactionFees(amount);
        balances[owner] += fees;

        uint remaining = amount - fees;

        balances[from] -= amount;
        balances[to] += remaining;

        allowance[from][msg.sender] -= amount;

        emit Transfer(from, owner, fees);
        emit Transfer(from, to, remaining);

        return true;
    }

    function balanceOf(address person) public view returns(uint) {
        return balances[person];
    }
}