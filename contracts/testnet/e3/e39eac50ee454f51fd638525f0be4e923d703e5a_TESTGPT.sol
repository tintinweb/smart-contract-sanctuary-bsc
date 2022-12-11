/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

pragma solidity ^0.6.0;

// This smart contract is licensed under the MIT license.
// This smart contract is producted by ChatGPT

contract TESTGPT {
  string public name = "TESTGPT";
  string public symbol = "TEST";
  uint8 public decimals = 18;
  uint256 public totalSupply = 10000000 * (10 ** uint256(decimals));
  address public owner;
  

  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor() public {
    balanceOf[msg.sender] = totalSupply;
    owner = msg.sender;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value && _value > 0, "Invalid transfer amount.");
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[_from] >= _value && allowance[_from][msg.sender] >= _value && _value > 0, "Invalid transfer amount.");
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function mint(address _to, uint256 _amount) public {
  require(msg.sender == owner, "Only the owner can mint new tokens.");
  balanceOf[_to] += _amount;
  totalSupply += _amount;
  emit Mint(_to, _amount);
}

  event Mint(address indexed _to, uint256 _amount);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}