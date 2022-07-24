//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ICashboxStorage.sol";
import "./ReentrancyGuard.sol";
import "./Address.sol";

contract Cashbox is Ownable, ReentrancyGuard {
  using Address for address;

  ICashboxStorage public _cashboxStorage;

  mapping(address => bool) public _withdrawer;
  mapping(string => mapping(address => uint256)) public minDepositAmount;
  mapping(string => mapping(address => uint256)) public minWithdrawAmount;
  mapping(address => bool) public _availableToken;

  modifier onlyWithdrawer() {
    require(_withdrawer[_msgSender()]);
    _;
  }

  event Deposit(string project, address indexed account, address token, uint256 amount);
  event Withdraw(string project, address indexed account, address token, uint256 amount);

  constructor() {
    _availableToken[0x55d398326f99059fF775485246999027B3197955] = true;
    _availableToken[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true;


    minDepositAmount["casino"][address(0)] = 1 * 10 ** 18 / 100;
    minDepositAmount["casino"][0x55d398326f99059fF775485246999027B3197955] = 1 * 10 ** 18;
    minDepositAmount["casino"][0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 1 * 10 ** 18;

    minDepositAmount["bookmaker"][address(0)] = 1 * 10 ** 18 / 100;
    minDepositAmount["bookmaker"][0x55d398326f99059fF775485246999027B3197955] = 1 * 10 ** 18;
    minDepositAmount["bookmaker"][0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 1 * 10 ** 18;


    minWithdrawAmount["casino"][address(0)] = 1 * 10 ** 18 / 100;
    minWithdrawAmount["casino"][0x55d398326f99059fF775485246999027B3197955] = 1 * 10 ** 18;
    minWithdrawAmount["casino"][0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 1 * 10 ** 18;
    
    minWithdrawAmount["bookmaker"][address(0)] = 1 * 10 ** 18 / 100;
    minWithdrawAmount["bookmaker"][0x55d398326f99059fF775485246999027B3197955] = 1 * 10 ** 18;
    minWithdrawAmount["bookmaker"][0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 1 * 10 ** 18;
  }

  function setTokenAviability(address token, bool status) external onlyOwner {
    _availableToken[token] = status;
  }

  function setCashboxStorage(address store) external onlyOwner {
    require(store != address(0));
    _cashboxStorage = ICashboxStorage(store);
  }

  function setWithdrawer(address account, bool status) external onlyOwner {
    _withdrawer[account] = status;
  }

  function deposit(string memory project) external payable {
    require(_cashboxStorage.isProjectAvailable(project), "Selected project not available");
    require(msg.value >= minDepositAmount[project][address(0)], "The deposit amount is less than the minimum");
    _cashboxStorage.addTransfer(project, _msgSender(), address(0), msg.value, true);
    emit Deposit(project, _msgSender(), address(0), msg.value);
  }

  function depositERC20(string memory project, address token, uint256 amount) external {
    require(_cashboxStorage.isProjectAvailable(project), "Selected project not available");
    require(token != address(0));
    require(_availableToken[token], "Selected token not available");
    require(amount >= minDepositAmount[project][token], "The deposit amount is less than the minimum");
    IERC20(token).transferFrom(_msgSender(), address(this), amount);
    _cashboxStorage.addTransfer(project, _msgSender(), token, amount, true); 
    emit Deposit(project, _msgSender(), token, amount); 
  }

    function setMinDepositAmount(string memory project, address token, uint256 minAmount) external onlyOwner {
    require(_cashboxStorage.isProjectAvailable(project));
    minDepositAmount[project][token] = minAmount;
  }

  function withdraw(string memory project, address account, uint256 amount) external nonReentrant onlyWithdrawer {
    require(_cashboxStorage.isProjectAvailable(project), "Selected project not available");
    require(amount >= minWithdrawAmount[project][address(0)], "The withdraw amount is less than the minimum");
    _cashboxStorage.addTransfer(project, account, address(0), amount, false);
    emit Withdraw(project, account, address(0), amount);
    Address.sendValue(payable(account), amount);
  }

  function withdrawERC20(string memory project, address account, address token, uint256 amount) external onlyWithdrawer {
    require(_cashboxStorage.isProjectAvailable(project), "Selected project not available");
    require(token != address(0));
    require(_availableToken[token], "Selected token not available");
    require(amount >= minWithdrawAmount[project][token], "The withdraw amount is less than the minimum");
    IERC20(token).transfer(account, amount);
    _cashboxStorage.addTransfer(project, account, token, amount, false);
    emit Withdraw(project, account, token, amount);
  }

  function setMinWithdrawAmount(string memory project, address token, uint256 minAmount) external onlyOwner {
    require(_cashboxStorage.isProjectAvailable(project));
    minWithdrawAmount[project][token] = minAmount;
  }

  function transferBNB(address account, uint256 amount) external onlyOwner {
    Address.sendValue(payable(account), amount);
  }

  function transferERC20(address account, address token, uint256 amount) external onlyOwner {
    IERC20(token).transfer(account, amount);
  }
}