/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address to, uint256 quantity) external returns(bool);

  event Transfer(address from, address to, uint256 value);
}

contract CryptoToken is IERC20 {

  //Properties
  string public constant name = "CryptoToken";
  string public constant symbol = "CRY";
  uint8 public constant decimals = 18;  //Padrão do Ether é 18
  uint256 private totalsupply;

  mapping(address => uint256) private addressToBalance;

  //Constructor
  constructor(uint256 total) {
    totalsupply = total;
    addressToBalance[msg.sender] = totalsupply;
  }

  //Public Functions
  function totalSupply() public override view returns(uint256) {
    return totalsupply;
  }

  function balanceOf(address account) public override view returns(uint256) {
    return addressToBalance[account];
  }

  function transfer(address to, uint256 quantity) public override returns(bool) {
    require(addressToBalance[msg.sender] >= quantity, "Insufficient Balance to Transfer");


    addressToBalance[msg.sender] = addressToBalance[msg.sender] - quantity;
    addressToBalance[to] = addressToBalance[to] + quantity;

    emit Transfer(msg.sender, to, quantity);
    return true;
  }
}