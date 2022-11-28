/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

pragma solidity ^0.8.0;

contract Token {
	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Approval(address indexed owner, address indexed spender, uint256 amount);
	
	string public constant name = "Candy Bitcoin";
	string public constant symbol = "CBTC";
	uint8 public constant decimals = 18;
	uint256 public constant totalSupply = 21e24;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;
	
	constructor(address init){
		balanceOf[init] = totalSupply;
		emit Transfer(address(0), init, totalSupply);
	}
	
	function _transfer(address from, address to, uint256 amount) internal{
		require(to != address(0) && from != to, "Token:invalid to");
		balanceOf[from] -= amount;
		balanceOf[to] += amount;
		emit Transfer(from, to, amount);
	}
	
	function _approve(address owner, address spender, uint256 amount) internal{
		allowance[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
	
	function transfer(address to, uint256 amount) external returns(bool){
		_transfer(msg.sender, to, amount);
		return true;
	}
	
	function transferFrom(address from, address to, uint256 amount) external returns(bool){
		_approve(from, msg.sender, allowance[from][msg.sender] - amount);
		_transfer(from, to, amount);
		return true;
	}
	
	function approve(address spender, uint256 amount) external returns(bool){
		_approve(msg.sender, spender, amount);
		return true;
	}
}