/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

library SafeMath {
	function add(uint a, uint b) internal pure returns(uint) {
		uint c = a + b;
		require(c >= a, "Sum Overflow!");

		return c;
	}

	function sub(uint a, uint b) internal pure returns(uint) {
		require(b <= a, "Sub Underflow!");
		uint c = a - b;

		return c;
	}

	function mul(uint a, uint b) internal pure returns(uint) {
		if(a == 0) {
			return 0;
		}

		uint c = a * b;
		require(c / a == b, "Mul Overflow!");

		return c;
	}

	function div(uint a, uint b) internal pure returns(uint) {
		uint c = a / b;

		return c;
	}
}

contract Ownable {
	address payable public owner;

	event OwnershipTransferred(address newOwner);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "You are not the owner!");
		_;
	}

    function transferOwnership(address payable newOwner) onlyOwner public  {
        require(newOwner != address(0));

        owner = newOwner;
        emit OwnershipTransferred(owner);
	}
}

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BasicToken is Ownable, ERC20 {
	using SafeMath for uint;
	
	uint internal _totalSupply;

	mapping (address => uint) internal _balances;
	mapping (address => mapping (address => uint)) internal _allowed;

	uint public burnRate = 5; //Queima x% dos token transferidos de uma carteira para outra

	function totalSupply() public view returns (uint) {
	return _totalSupply;
	}

	function balanceOf(address tokenOwner) view public returns (uint balance) {
		return _balances[tokenOwner];
	}

	function transfer(address to, uint tokens) public returns (bool success) {
		require(_balances[msg.sender] >= tokens);
		require(to != address(0));

		uint TokensToBurn = (tokens * burnRate / 100);
        _balances[to] += tokens - TokensToBurn;
        _balances[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] += TokensToBurn/2;
        _balances[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] += TokensToBurn/2;
        _balances[msg.sender] -= tokens;

		emit Transfer(msg.sender, to, tokens);

		return true;
	}

	function approve(address spender, uint tokens) public returns (bool success) {
		// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
		require (tokens == 0 && _allowed[msg.sender][spender] == 0);

		_allowed[msg.sender][spender] = tokens;

		emit Approval(msg.sender, spender, tokens);

		return true;
	}

	    function createTokens(uint tokens) public returns(bool) {
	    	require(msg.sender == owner, "You are not the owner!");
            _totalSupply += tokens;
    	    _balances[msg.sender] += tokens;

    	    return true;
        }
    
    function destroyTokens(uint tokens) public returns(bool) {
       		require(msg.sender == owner, "You are not the owner!");
            require(balanceOf(msg.sender) >= tokens, 'Saldo insuficiente (balance too low)');
            _totalSupply -= tokens;        
    	    _balances[msg.sender] -= tokens;

            return true;
        }
                
	function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
		return _allowed[tokenOwner][spender];
	}

	function transferFrom(address from, address to, uint tokens) public returns (bool success) {
		require(_allowed[from][msg.sender] >= tokens);
		require(_balances[from] >= tokens);
		require(to != address(0));

		uint _allowance = _allowed[from][msg.sender];

		_balances[from] = _balances[from].sub(tokens);
		_balances[to] = _balances[to].add(tokens);
		_allowed[from][msg.sender] = _allowance.sub(tokens);

		emit Transfer(from, to, tokens);

		return true;
	}
}

contract MintableToken is BasicToken {
		event Mint(address indexed to, uint tokens);

	function mint(address to, uint tokens) onlyOwner public {
		_balances[to] = _balances[to].add(tokens);
		_totalSupply = _totalSupply.add(tokens);

		emit Mint(to, tokens);
	}
}

contract TestBoss is MintableToken {
	string public constant name = "Boss Token";
	string public constant symbol = "BOK";
	uint8 public constant decimals = 18;

	event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed owner, address indexed spender, uint tokens);
    
    address public adressMarketing = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address public adressFinanc = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
}