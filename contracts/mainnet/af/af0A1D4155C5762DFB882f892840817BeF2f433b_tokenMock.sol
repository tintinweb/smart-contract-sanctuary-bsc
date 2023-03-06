/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
interface IBEP20Metadata is IBEP20 
{ 
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract tokenMock is IBEP20Metadata
{
    string public _name = "mock token";  
    string public _symbol = "moc"; 
   
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowances;
   
    address public owner;

    constructor ()
    {
        owner = msg.sender;
        balances[address(this)] = 1000000 * 10 ** 18;
        _transfer(address(this), owner, 1000000 * 10 ** 18);
    }



/// Metadata
    function name() public   override view returns (string memory)
    {
        return _name;
    }
    function symbol() public   override view returns (string memory)
    {
        return _symbol;
    }
    function decimals() public   override pure returns (uint8)
    {
        return 18;
    }
///

/// ERC20
    function totalSupply() public   override view returns (uint)
    {
        return balances[address(this)];
    }
    function balanceOf(address account) public   override view returns (uint)
    {
        return balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }


    function allowance(address _owner, address spender) public override view returns (uint)
    {
        return allowances[_owner][spender];
    }
    function approve(address spender, uint amount) external returns (bool)
    {
        return _approve(msg.sender, spender, amount);
    }
    function transferFrom(address from, address to, uint amount) external returns (bool)
    {
        require( balances[from] >= amount,"Not enought tokens");
        require( allowances[from][to] >= amount, "Not approve enought tokens");
        uint approving = allowances[from][to] - amount;
        _approve(from, to, approving);
        return _transfer(from, to, amount);
    }

    function _approve (address from, address to, uint amount) private returns (bool)
    {
        allowances[from][to] = amount;
        emit Approval(from, to, amount);
        return true;
    }
    function _transfer(address from , address to, uint amount) private returns (bool)
    {
        require( balances[from] >=amount,"Not enougtht tokens");
        require(to != address(0), "pecipient is 0" );
        
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
///
}