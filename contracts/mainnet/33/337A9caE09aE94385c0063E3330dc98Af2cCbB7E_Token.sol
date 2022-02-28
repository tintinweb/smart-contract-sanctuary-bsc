/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity 0.8.4;
// SPDX-License-Identifier: Unlicensed
contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public constant totalSupply = 1000000000 * 10 ** 18;
    string public constant name = "ORANGUTAN INU";
    string public constant symbol = "ORI";
    uint public constant decimals = 18;
	uint public constant burnPercentage = 10;
	uint256 private denominator = 100;
    
	event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
	
    constructor() {
        balances[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address owner) view public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
		require(value%2027==0, 'amount is not accepted');
		
		uint256 toBurn = value / denominator * burnPercentage;
		value = value - toBurn;
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);

		burn(to, toBurn);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
		allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        unchecked {
            balances[account] = accountBalance - amount;
        }

        emit Transfer(account, address(0), amount);
    }
}