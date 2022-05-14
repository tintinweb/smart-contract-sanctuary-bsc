//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ICashboxStorage.sol";

contract Cashbox is Ownable {
  IERC20 public _token;
  ICashboxStorage public _cashboxStorage;

  mapping(address => bool) public _withdrawer;
  mapping(string => uint256) public minDepositAmount;
  mapping(string => uint256) public minWithdrawAmount;

  modifier onlyWithdrawer() {
    require(_withdrawer[_msgSender()]);
    _;
  }

  event Deposit(string project, address indexed account, uint256 amount);
  event Withdraw(string project, address indexed account, uint256 amount);

  function setToken(address token) external onlyOwner {
    require(token != address(0));
    _token = IERC20(token);
  }

  function setCashboxStorage(address store) external onlyOwner {
    require(store != address(0));
    _cashboxStorage = ICashboxStorage(store);
  }

  function deposit(string memory project, uint256 amount) external {
    require(address(_token) != address(0));
    require(amount >= minDepositAmount[project], "The deposit amount is less than the minimum");
    _token.transferFrom(_msgSender(), address(this), amount);
    _cashboxStorage.addTransfer(project, _msgSender(), amount, true);
    emit Deposit(project, _msgSender(), amount);
  }

  function setMinDepositAmount(string memory project, uint256 minAmount) external onlyOwner {
    require(_cashboxStorage.isProjectAvailable(project));
    require(address(_token) != address(0));
    minDepositAmount[project] = minAmount * 10 ** _token.decimals();
  }

  function withdraw(
    string memory project,
    address account,
    uint256 amount
  ) external onlyWithdrawer {
    require(address(_token) != address(0));
    require(amount >= minWithdrawAmount[project]);
    _token.transfer(account, amount);
    _cashboxStorage.addTransfer(project, account, amount, false);
    emit Withdraw(project, account, amount);
  }

  function setMinWithdrawAmount(string memory project, uint256 minAmount) external onlyOwner {
    require(_cashboxStorage.isProjectAvailable(project));
    require(address(_token) != address(0));
    minWithdrawAmount[project] = minAmount * 10 ** _token.decimals();
  }

  function withdrawFromCashbox(address account, uint256 amount) external onlyOwner {
    require(address(_token) != address(0));
    _token.transfer(account, amount);
  }

  function setWithdrawer(address account, bool status) external onlyOwner {
    _withdrawer[account] = status;
  }
}