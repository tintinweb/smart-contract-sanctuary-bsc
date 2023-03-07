/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


/**
 * IBEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BEP20 is IBEP20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    string public name = "staking token";
    string public symbol = "STAKE";
    uint8 public decimals = 18;

    function transfer(address recipient, uint256 amount) external returns (bool) {
	balanceOf[msg.sender] -= amount;
	balanceOf[recipient] += amount;
	emit Transfer(msg.sender, recipient, amount);
	return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
	allowance[msg.sender][spender] = amount;
	emit Approval(msg.sender, spender, amount);
	return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)  {
	allowance[sender][msg.sender] -= amount;
	balanceOf[sender] -= amount;
	balanceOf[recipient] += amount;
	emit Transfer(sender, recipient, amount);
	return true;
    }

    function mint(uint amount) external {
	balanceOf[msg.sender] += amount;
	totalSupply += amount;
	emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
	balanceOf[msg.sender] -= amount;
	totalSupply -= amount;
	emit Transfer(msg.sender, address(0), amount);
    }

}