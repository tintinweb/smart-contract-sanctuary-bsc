/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;
 
/*
// Mintable
// Burnable
// Pausable
// Blacklist
// Whitelist
*/

contract Token {
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply;
    address payable public owner;

    bool public paused = false;
    mapping(address => bool) public blacklistUsers;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approve(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner {
        require(msg.sender == owner, "Operation unauthorised");
        _;
    }

    modifier notPaused {
        require(!paused);
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name; 
        symbol = _symbol; 
        decimals = 0;
  
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; 
        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint256 _value) public onlyOwner notPaused returns (bool success) {

        require(!blacklistUsers[_to], "Recipient is backlisted");

        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public onlyOwner returns (bool success) {

        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) public onlyOwner returns (bool success) {

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public onlyOwner returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function blacklist(address _user) public onlyOwner {
        require(!blacklistUsers[_user], "User already blacklisted");
        blacklistUsers[_user] = true;
    }
    
    function whitelist(address _user) public onlyOwner {
        require(blacklistUsers[_user], "User already whitelisted");
        blacklistUsers[_user] = false;
    }

}