/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/*
🅼🅸🅽🆃🅴🅳 🆃🅾🅺🅴🅽
*/

pragma solidity ^0.8.2;
// SPDX-License-Identifier: Unlicensed

contract Token{
	
	address public minter;
	mapping(address => uint) public balances;
	mapping(address => mapping(address => uint)) public allowance;
	
	string public name = "Mint Token";
	string public symbol = "mintToken";
	uint public decimals = 9;
	uint public totalSupply = 1000 * 10 ** decimals;

	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	event Sent(address from, address to, uint amount);

constructor(){
		balances[msg.sender] = totalSupply;
		minter = msg.sender;
	}

	function balanceOf(address owner) public view returns(uint){
		return balances[owner];
	}
	
	function transfer (address to, uint value) public returns(bool) {
		require(balanceOf(msg.sender) >= value, 'balance too low');
		balances[to] += value;
		balances[msg.sender] -= value;
		emit Transfer(msg.sender, to, value);
		return true;
	}
	
	function transferFrom(address from, address to, uint value) public returns(bool){
		require(balanceOf(from) >= value, 'balance too low');
		require(allowance[from][msg.sender] >= value, 'allowance too low');
		balances[to] += value;
		balances[from] -= value;
		emit Transfer(from, to, value);
		return true;
	}
	
	function approve(address spender, uint value) public returns(bool){
		allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);	
		return true;
	}


	function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }

	// Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

}