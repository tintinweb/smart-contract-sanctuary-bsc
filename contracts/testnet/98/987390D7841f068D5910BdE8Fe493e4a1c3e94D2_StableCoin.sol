/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity ^0.5.0;

contract StableCoin {
  // The symbol for the stablecoin
  string public symbol;
  // The name of the stablecoin
  string public name;
  // The number of decimal places for the stablecoin
  uint8 public decimals;
  // The total supply of the stablecoin
  uint256 public totalSupply;
  // The address of the contract owner
  address public owner;

  // Mapping from addresses to their balance of the stablecoin
  mapping (address => uint256) public balanceOf;

  // Event for when the stablecoin is transferred
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value
  );

  // Constructor to initialize the contract with the symbol, name, and number of decimal places
  constructor(string memory _symbol, string memory _name, uint8 _decimals) public {
    symbol = _symbol;
    name = _name;
    decimals = _decimals;
    totalSupply = 1000000000 * 10**uint256(_decimals);
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
  }

  // Function to transfer the stablecoin from one address to another
  function transfer(address _to, uint256 _value) public {
    require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance.");
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
  }
}