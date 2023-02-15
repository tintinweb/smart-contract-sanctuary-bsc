/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public owner;
    address public marketingWallet;
    address public stakingWallet;
    
    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public marketingTax;
    uint256 public stakingTax;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, uint256 _buyTax, uint256 _sellTax, uint256 _marketingTax, uint256 _stakingTax, address _marketingWallet, address _stakingWallet) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        buyTax = _buyTax;
        sellTax = _sellTax;
        marketingTax = _marketingTax;
        stakingTax = _stakingTax;
        marketingWallet = _marketingWallet;
        stakingWallet = _stakingWallet;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Not allowed to spend this amount");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function setBuyTax(uint256 _buyTax) public {
        require(msg.sender == owner, "Only owner can call this function");
        buyTax = _buyTax;
    }
    
    function setSellTax(uint256 _sellTax) public {
        require(msg.sender == owner, "Only owner can call this function");
        sellTax = _sellTax;
    }
    
    function setMarketingWallet(address _marketingWallet) public {
        require(msg.sender == owner, "Only owner can call this function");
        marketingWallet = _marketingWallet;
    }
    
    function setStakingWallet(address _stakingWallet) public {
        require(msg.sender == owner, "Only owner can call this function");
        stakingWallet = _stakingWallet;
    }
    
    function buy() public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 amount = msg.value * (10 ** uint256(decimals)) / buyTax;
        require
    (balanceOf[owner] >= amount, "Insufficient tokens in contract");
    balanceOf[owner] -= amount;
    balanceOf[msg.sender] += amount;
    payable(marketingWallet).transfer(msg.value * marketingTax / 100);
    payable(stakingWallet).transfer(msg.value * stakingTax / 100);
    emit Transfer(owner, msg.sender, amount);
}

function sell(uint256 _amount) public {
    require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
    require(_amount > 0, "Amount must be greater than 0");
    uint256 value = _amount * sellTax / (10 ** uint256(decimals));
    require(address(this).balance >= value, "Insufficient ether in contract");
    balanceOf[msg.sender] -= _amount;
    balanceOf[owner] += _amount;
    payable(msg.sender).transfer(value);
    emit Transfer(msg.sender, owner, _amount);
}

function transferOwnership(address _newOwner) public {
    require(msg.sender == owner, "Only owner can call this function");
    owner = _newOwner;
}

function renounceOwnership() public {
    require(msg.sender == owner, "Only owner can call this function");
    owner = address(0);
}
}