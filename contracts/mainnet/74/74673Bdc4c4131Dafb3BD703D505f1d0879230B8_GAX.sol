// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
import "./IERC20.sol";
import "./ownable.sol";
import "./safemath.sol";
contract GAX is IERC20,Ownable {
	//使用SafeMath
    using SafeMath for uint256;

    uint256 public override  totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    string public name ;
    string public symbol ;
    uint8 public decimals ;
	constructor()  {
        totalSupply = 1000000000;//10亿
        name = "Galaxy boys";
        symbol = "GAX";
        decimals = 18;
        totalSupply = totalSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
		require(recipient != address(0));
		require(amount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
		require(recipient != address(0));
        require(amount <= balanceOf[sender]);
        require(amount <= allowance[sender][msg.sender]);
        allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address target,uint256 amount) onlyOwner external {
        balanceOf[target] = balanceOf[target].add(amount);
        totalSupply = totalSupply.add(amount);
        emit Transfer(address(0), target, amount);
    }

    function burn(address target,uint256 amount) onlyOwner external {
        balanceOf[target] = balanceOf[target].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}