/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract YUMM {
    string public name = "YUMM";
    string public symbol = "YM";
    uint256 public totalSupply = 100000000 * (10 ** 18);
    uint8 public decimals = 18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlackListed;

    address public owner;

    uint256 public buyFee = 5;
	uint256 public sellFee = 100;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Blacklisted(address indexed target);
    event Unblacklisted(address indexed target);
    event FeeUpdated(uint256 buyFee, uint256 sellFee);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;    
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of the contract.");
        _;
    }
    
    modifier notBlackListed(address _recipient) {
        require(!isBlackListed[_recipient], "The recipient's address is blacklisted.");
        _;
    }

    function transfer(address _recipient, uint256 _amount) public notBlackListed(_recipient) returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "You don't have enough tokens to make this transfer.");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_recipient] += _amount;
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public notBlackListed(_recipient) returns (bool success) {
        require(balanceOf[_sender] >= _amount, "The sender doesn't have enough tokens to make this transfer.");
        require(allowance[_sender][msg.sender] >= _amount, "The spender doesn't have enough allowance to make this transfer.");
        balanceOf[_sender] -= _amount;
        balanceOf[_recipient] += _amount;
        allowance[_sender][msg.sender] -= _amount;
        emit Transfer(_sender, _recipient, _amount);
        return true;
    }

    function addToBlacklist(address _target) public onlyOwner {
        isBlackListed[_target] = true;
        emit Blacklisted(_target);
    }
    
    function removeFromBlacklist(address _target) public onlyOwner {
        isBlackListed[_target] = false;
        emit Unblacklisted(_target);
    }

    function updateFees(uint256 _buyFee, uint256 _sellFee) public onlyOwner {
        buyFee = _buyFee;
        sellFee = _sellFee;
        emit FeeUpdated(buyFee, sellFee);
    }

    function buy() public payable {
        require(msg.value > 0, "You need to send some ether to buy this token.");
        uint256 amountToTransfer = (msg.value * (10 ** decimals)) / ((100 + buyFee) * 10);
        balanceOf[owner] -= amountToTransfer;
        balanceOf[msg.sender] += amountToTransfer;
        emit Transfer(owner, msg.sender, amountToTransfer);
    }

    function sell(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "You don't have enough tokens to make this sell.");
        uint256 etherToTransfer = (_amount * (100 + sellFee)) / (10 ** decimals);
        balanceOf[msg.sender] -= _amount;
        balanceOf[owner] += _amount;
        payable(msg.sender).transfer(etherToTransfer);
        emit Transfer(msg.sender, owner, _amount);
    }
}