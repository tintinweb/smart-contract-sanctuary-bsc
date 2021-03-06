/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

pragma solidity ^0.8.9;

contract Token{
	mapping(address => uint) public balances;
	mapping(address => mapping(address => uint)) public allowance;
	uint public totalSupply = 1000*10**18;
	uint public decimals = 18;
	string public name = "Rama Token";
	string public symbol = "JAV";
	// event functions
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	// constructor
	constructor(){
		balances[msg.sender] = totalSupply;
	}
	// showing balance
	function balanceOf(address owner) public view returns(uint){
		return balances[owner];
	}
	// transfer
	function transfer(address to, uint value) public returns(bool){
		require(balanceOf(msg.sender) >= value, 'balance too low');
		balances[to] += value;
		balances[msg.sender] -= value;
		emit Transfer(msg.sender, to, value);
		return true;
	}
	// delegate-transfer
	function transferFrom(address from, address to, uint value) public returns(bool){
		require(balanceOf(from) >= value, 'balance too low');
		require(allowance[from][msg.sender] >= value, 'allowance too low');
		balances[to] += value;
		balances[from] -= value;
		emit Transfer(from, to, value);
		return true;
	}
	// allowance
	function approve(address spender, uint value) public returns(bool){
		allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
}