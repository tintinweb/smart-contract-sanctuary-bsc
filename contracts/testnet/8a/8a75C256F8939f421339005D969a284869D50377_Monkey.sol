/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// Selects the solidity version
pragma solidity ^0.8.2;

// Contract scope
contract Monkey {
    // 0x123123213 => 1200
    // 0x4343j4jdf => 400
    mapping(address => uint) public balances;

    // 0x2133jin1j3
    //      => 0x123dasaad1 => 1000
    //      => 0x123dasaad1 => 20000
    //      => 0x123dasaad1 => 4000
    mapping(address => mapping(address => uint)) public allowance;

    // 1 Token = 10 * 18
    uint public totalSupply = 10000 * 10 ** 18; // Ten thousand and decimals
    string public name = "Monkey";
    string public symbol = "MON";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // Executed only once, when the contract is deployed
    constructor() {
        // msg.sender is the admin of the project
        balances[msg.sender] = totalSupply;
    }

    // A public function can be called from outside of the smart contract
    // A function with type view is a read only function
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }


    // TRANSFER BLOCK

    // Ex: value = 1 * 10 ** 18
    // This function doesn't have the keyword view because 
    // it will actually modify data on the blockchain
    function transfer(address to, uint value) public returns(bool) {
        // require() allow the test of a logical condition.
        // If it is true than the execution continues otherwise it returns an error
        // And the transaction is cancelled
        require(balanceOf(msg.sender) >= value, 'balance to low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }


    // DELEGATED TRANSFER BLOCK
    // With delegated transfer is possible to another address to spend tokens
    // on behalf of another address
    // Commonly used by decentralized accent who manipulates tokens instead of
    // sending tokens directly to the address of a smart contract
    // It allows the smart contract to spend token on your behalf
    // It pulls the tokens from your address to its own address

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance to low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        // The spender is allowed to spend x value tokens on behalf of the sender
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}