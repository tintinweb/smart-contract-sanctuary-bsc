// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Deposit {

  event DepositAmount(address indexed from, uint256 amount);
  event WithdrawAmount(address indexed from, uint256 amount);
  event TransferAmountInDeposit(address indexed from, address indexed to, uint256 amount);

  mapping (address => uint256) public amountOf;

  function deposit() external payable {

    require(msg.value != 0, "Not zero");
    amountOf[msg.sender] = msg.value;

    emit DepositAmount(msg.sender, msg.value);
  }

  function withdraw(uint256 _amount) external {

    require(amountOf[msg.sender] != 0, "No call");
    require(amountOf[msg.sender] >= _amount, "No enough");
    require(msg.sender != address(0), "No zero address");

    (bool success, ) = payable(msg.sender).call{ value: _amount }("");
    require(success, "No success to withdraw ");

    amountOf[msg.sender] = amountOf[msg.sender] - _amount;
    emit WithdrawAmount(msg.sender, _amount);
  }

  function withdrawAll() external {

    require(amountOf[msg.sender] != 0, "No call");
    require(msg.sender != address(0), "No zero address");

    (bool success, ) = payable(msg.sender).call{ value: amountOf[msg.sender] }("");
    require(success, "No success to withdraw ");

    amountOf[msg.sender] = 0;
    emit WithdrawAmount(msg.sender, amountOf[msg.sender]);
  }

  function transfer(address recipient, uint256 amount) external returns(bool) {
    address owner = msg.sender;
    _transfer(owner, recipient, amount);
    emit TransferAmountInDeposit(owner, recipient, amount);

    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns(bool) {
    _transfer(from, to, amount);
    emit TransferAmountInDeposit(from, to, amount);
    
    return true;
  }

  function _transfer(address from, address to, uint256 amount) internal {
    amountOf[from] = amountOf[from] - amount;
    amountOf[to] = amountOf[to] + amount;
  }

  function depositedBalanceOf(address _address) public view returns (uint256) {
    return amountOf[_address];
  }

  function totalBalance() public view returns (uint256) {
    return address(this).balance;
  }
}