//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ICashboxStorage.sol";

contract CashboxStorage is Ownable, ICashboxStorage {
  struct Transfer {
    string project;
    address account;
    address token;
    uint256 amount;
    uint256 timestamp;
    bool isDeposit;
  }

  Transfer[] public transfers;
  
  mapping(string => bool) public availableProjects;

  mapping(address => bool) public cashboxAdmin;

  modifier onlyAdmin() {
    require(cashboxAdmin[_msgSender()]);
    _;
  }

  constructor() {
    cashboxAdmin[_msgSender()] = true;
    availableProjects["casino"] = true;
    availableProjects["bookmaker"] = true;
  }

  function isProjectAvailable(string memory project) external view returns (bool) {
    return availableProjects[project];
  }

  function setAdmin(address account, bool status) external onlyOwner {
    cashboxAdmin[account] = status;
  }

  function setProjectAvailability(string memory project, bool status) external onlyOwner {
    availableProjects[project] = status;
  }

  function addTransfer(
    string memory project,
    address account,
    address token,
    uint256 amount,
    bool isDeposit
  ) external onlyAdmin {
    require(availableProjects[project]);
    Transfer memory transfer = Transfer({
      project: project,
      account: account,
      token: token,
      amount: amount,
      timestamp: block.timestamp,
      isDeposit: isDeposit
    });
    transfers.push(transfer);
  }
}