//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./Rules.sol";

contract Token is Rules {
  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  string public name = "Logic for Token";
  string public symbol = "LFT";
  uint8 public decimals = 10;

  /** @dev функция инициализации вызываемая delegatecall из конструктора прокси или при смене implementation.
  * только администратор прокси контракта eip1967 может вызвать данный метод.
  * предполагается, что администратор не может выполнять fallback обращения к прокси,
  * потому вызов данного метода возможен лишь единожды
  * при создании прокси, или при смене implementation. 
  */
  function constructor1(
      string calldata tokenName, 
      string calldata tokenSymbol, 
      uint8 tokenDecimals,
      address tokenOwner,
      address initAddress,
      uint256 amount
  ) public
  {
    address adm;
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
    require(msg.sender == adm, "Only proxy admin can init contract");

    name = tokenName;
    symbol = tokenSymbol;
    decimals = tokenDecimals;
    _setOwner(tokenOwner);
    _mint(initAddress,amount);    
  }

  function transferMultiple(address[] calldata addresses, uint256[] calldata sums) external {
    if (addresses.length != sums.length) {
      revert();
    }
    for (uint i = 0; i < addresses.length; ++i) {
      _transfer(msg.sender, addresses[i], sums[i]);
    }
  }

  function transferMultiple(address[] calldata addresses, uint256 sum) external {
    for (uint i = 0; i < addresses.length; ++i) {
      _transfer(msg.sender, addresses[i], sum);
    }
  }
}