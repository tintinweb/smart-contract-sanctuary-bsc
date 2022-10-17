/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

pragma solidity ^0.8.2;


contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "best";
    string public symbol = "bbb";
    uint public decimals = 18;
    // uint public tokenPrice = 0.001 ether;
    address public owner;
    bool public sale;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event TokenBought(address owner, address  buyer, uint value);
    
    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }

    function buyToken(address _to,uint _value)public {
        require(balanceOf(owner) >= _value, 'balance too low');      
        // uint value = tokenPrice * _value;
        // require(msg.value == value, 'Price Not Equal');
        // payable(owner).transfer(msg.value);
        balances[_to] += _value;
        balances[owner] -= _value;
        emit TokenBought(owner,_to,_value);
    }

    function sellToken(uint tokenAmount)public {    
        require(sale == true, 'sale has not started yet');
        require(balanceOf(msg.sender) <= tokenAmount, 'Do not have enough tokens');
        // uint saleValue = tokenPrice * tokenAmount;
        // payable(msg.sender).transfer(saleValue = address(this).balance);
        balances[owner] += tokenAmount;
        balances[msg.sender] -= tokenAmount;
   

    }

    function sellOnOff()public {
        require(msg.sender == owner, 'Only Owner Allowed');
        if(sale == false){
            sale = true;
        }else{
            sale = false;
        }
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
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