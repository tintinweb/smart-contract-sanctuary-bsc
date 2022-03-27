/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

pragma solidity ^0.8.9;
contract Token{
	mapping(address => uint) public balances;
	mapping(address => mapping(address => uint)) public allowance;
	mapping(address => bool) blacklist;
	uint public totalSupply = 999*10**18;
	uint public decimals = 18;
	string public name = "Fucking Jeets";
	string public symbol = "FJEET";
	address adr_zero = 0x0000000000000000000000000000000000000000;
	address adr_dead = 0x000000000000000000000000000000000000dEaD;
	// event functions
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	// constructor
	constructor(){
		emit Transfer(adr_zero, msg.sender, totalSupply);
		balances[msg.sender] += totalSupply;
		blacklist[adr_zero] = true;
		blacklist[adr_dead] = true;
	}
	// showing balance
	function balanceOf(address owner) public view returns(uint){
		return balances[owner];
	}
	// transfer
	function transfer(address to, uint value) public returns(bool){
		require(!blacklist[msg.sender], 'blacklisted address');
		require(balanceOf(msg.sender) >= value, 'balance too low');
		balances[msg.sender] -= value;
		balances[to] += value;
		emit Transfer(msg.sender, to, value);
		return true;
	}
	// delegate-transfer
	function transferFrom(address from, address to, uint value) public returns(bool){
		require(!blacklist[from],'blacklisted address');
		require(balanceOf(from) >= value, 'balance too low');
		require(allowance[from][msg.sender] >= value, 'allowance too low');
		balances[from] -= value;
		balances[to] += value;
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