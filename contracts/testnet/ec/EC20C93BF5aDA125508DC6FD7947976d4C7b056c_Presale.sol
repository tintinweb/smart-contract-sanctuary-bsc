// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Token.sol';

contract Presale {
	Token _token = Token(0x159e34c2aA21b0933548b8CD1a2A8De7243B7C31);
	address payable public _admin = payable(0x4D9f030DF73A55e43eDCD4187bc062804Cd84d8c);
	bool public _active;
	uint256 public _rate;

	constructor() {
		_rate = 1500; // 1500 tokens for 1 BNB
		_active = true; // setting presale to be active
	}

	// this function triggers whenever someone sends any bnb to this contract address
	receive() external payable {
		// it will call this getTokens function with the bnb sender as the beneficiary
		getTokens(msg.sender);
	}

	function getTokens(address beneficiary) public payable {
		// this line checks if the presale is active, if it's inactive it will stop the function
		require(_active, 'presale inactive');

		// this line calculates how much tokens to send
		// msg.value is how much bnb is sent
		uint256 value = msg.value * _rate;

		// check if the value calculated is higher than the amount of tokens this contract have
		require(value <= _token.balanceOf(address(this)), 'amount is larger than token balance');

		// send tokens to the user
		_token.approve(beneficiary, value);
		_token.transfer(beneficiary, value);

		// send bnb to the admin address
		_admin.transfer(msg.value);
	}

	function withdrawAll() public {
		// check if the admin is the one calling this function
		require(msg.sender == _admin, 'not admin');
		_token.approve(_admin, _token.balanceOf(address(this)));
		_token.transfer(_admin, _token.balanceOf(address(this)));
	}

	function withdraw(uint256 amount) public {
		// check if the admin is the one calling this function
		require(msg.sender == _admin, 'not admin');
		require(amount <= _token.balanceOf(address(this)), 'amount is larger than token balance');
		_token.approve(_admin, amount);
		_token.transfer(_admin, amount);
	}

	function setActive(bool active) public {
		// check if the admin is the one calling this function
		require(msg.sender == _admin, 'not admin');
		_active = active;
	}

	function setRate(uint256 rate) public {
		// check if the admin is the one calling this function
		require(msg.sender == _admin, 'not admin');
		_rate = rate;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Token {
	mapping(address => uint256) public balances;
	mapping(address => mapping(address => uint256)) public allowance;
	uint256 public totalSupply = 1000000000 * 10**18;
	string public name = 'Argonon Helium Test';
	string public symbol = 'ARG';
	uint256 public decimals = 18;

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	constructor() {
		balances[msg.sender] = totalSupply;
	}

	function balanceOf(address owner) public view returns (uint256) {
		return balances[owner];
	}

	function transfer(address to, uint256 value) public returns (bool) {
		require(balanceOf(msg.sender) >= value, 'balance too low');
		balances[to] += value;
		balances[msg.sender] -= value;
		emit Transfer(msg.sender, to, value);
		return true;
	}

	function transferFrom(
		address from,
		address to,
		uint256 value
	) public returns (bool) {
		require(balanceOf(from) >= value, 'balance too low');
		require(allowance[from][msg.sender] >= value, 'allowance too low');
		balances[to] += value;
		balances[from] -= value;
		emit Transfer(from, to, value);
		return true;
	}

	function approve(address spender, uint256 value) public returns (bool) {
		allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
}