/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "Green Bull Coin";
    string public symbol = "GBC";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }

    // add the two state variables to your contract
    // specify the owner
    // added a true false flag that will be used to indicate if the tokens are tradable   

    address owner;
    bool public transferable = false;

    // add two function modifiers
    // a modifier to check the owner of the contract
    // a modifier to determine if the transferable flag is true of false
    modifier onlyOwner() {
        require(msg.sender == owner, 'Not Owner');
        _;
    }
    modifier istransferable() {
        require(transferable==false, 'Can Not Trade');
        _;
    }

    // Add a setter to change the transferable flag
    // only the owner of the contract can call because a modifier is specified
    function isTransferable(bool _choice) public onlyOwner{
        transferable = _choice;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    // USE THIS CODE TO ALLOW TRANSFER TO OTHER WALLET
    // function transfer(address to, uint value) public returns(bool) {
    //     require(balanceOf(msg.sender) >= value, 'balance too low');
    //     balances[to] += value;
    //     balances[msg.sender] -= value;
    //     emit Transfer(msg.sender, to, value);
    //     return true;
    // }

    // add the function modifier to the transfer function
    // if the transferable==false then one can not trade
    function transfer(address to, uint value) public istransferable returns (bool success) {
        if (value > 0 && value <= balanceOf(msg.sender)) {
            require(balanceOf(msg.sender) >= value, 'balance too low');
            balances[to] += value;
            balances[msg.sender] -= value;
            emit Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}