/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.0;

contract MyToken {
    string public name = "My Token";
    string public symbol = "MTK";
    uint256 public totalSupply = 1000000000000000000000000; // 1 billion tokens with 18 decimal places
    uint8 public decimals = 18;
    address public owner; // new variable for the contract owner
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender; // set the contract creator as the owner
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address.");
        require(value > 0, "Value must be greater than zero.");
        require(balanceOf[msg.sender] >= value, "Insufficient balance.");
        
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Cannot approve the zero address.");
        
        allowance[msg.sender][spender] = value;
        
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address.");
        require(value > 0, "Value must be greater than zero.");
        require(balanceOf[from] >= value, "Insufficient balance.");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance.");
        
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        
        emit Transfer(from, to, value);
        return true;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Cannot transfer ownership to the zero address.");
        
        owner = newOwner;
    }
}