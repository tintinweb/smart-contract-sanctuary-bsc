// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract ERCMAKER {
  address[] public tokenList;

  struct Token {
    string name;
    string symbol;
    uint8 decimals;
  }

  constructor(Token[] memory tokens) {
    for (uint i = 0; i < tokens.length; i++) {
      Token memory token = tokens[i];
      tokenList.push(address(new ERC20(token.name, token.symbol, token.decimals)));
    }
  }

  function createNewToken(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) public returns (address) {
    tokenList.push(address(new ERC20(name, symbol, decimals)));
    return tokenList[tokenList.length - 1];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    mint(tx.origin, 1e10 * 10 ** _decimals);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function mint(address to, uint256 amount) private {
    balanceOf[to] += amount;
    totalSupply += amount;
    emit Transfer(address(0), to, amount);
  }
}