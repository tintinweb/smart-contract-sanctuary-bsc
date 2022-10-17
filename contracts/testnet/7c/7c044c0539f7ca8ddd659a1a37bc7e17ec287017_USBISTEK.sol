/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface ERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract USBISTEK is ERC20 {

    string public constant name = "USBISTEK";
    string public constant symbol = "USBISTEK";
    address private _owner;
    uint8 public constant decimals = 18;
    
    
    mapping(address => uint256) balances;
    
    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_ = 1000000000 ether;
    
    constructor() {
        balances[msg.sender] = totalSupply_;
        _owner = msg.sender;
    }
    
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function mintToken(uint256 numTokens, address receiver) public returns (bool) {
        require(msg.sender == _owner);
        totalSupply_ += numTokens;
        balances[receiver] += numTokens;
        return true;
    }
    
    function burnToken(uint256 numTokens) public returns (bool) {
        require(balances[msg.sender] >= numTokens);
        totalSupply_ -= numTokens;
        balances[msg.sender] -= numTokens;
        return true;
    }
}