/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BEP20 {

  uint private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  mapping (address => uint256) private _balances;
  
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
  * @notice constructor will be triggered when we create the Smart contract
  * _name = name of the token
  * _short_symbol = Short Symbol name for the token
  */
  constructor(string memory token_name, string memory short_symbol){
      _name = token_name;
      _symbol = short_symbol;
      _decimals = 18;
      _totalSupply = 1000000000000;

      // Add all the tokens created to the creator of the token
      _balances[msg.sender] = _totalSupply;

      // Emit an Transfer event to notify the blockchain that an Transfer has occured
      emit Transfer(address(0), msg.sender, _totalSupply);
      
  }
    /**
    * @notice decimals will return the number of decimal precision the Token is deployed with
    */
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    /**
    * @notice symbol will return the Token's symbol 
    */
    function symbol() external view returns (string memory){
        return _symbol;
    }
    /**
    * @notice name will return the Token's symbol 
    */
    function name() external view returns (string memory){
        return _name;
    }
    /**
    * @notice totalSupply will return the tokens total supply of tokens
    */
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "DevToken: transfer from zero address");
        require(recipient != address(0), "DevToken: transfer to zero address");
        require(_balances[sender] >= amount, "DevToken: cant transfer more than your account holds");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    } 
    
}