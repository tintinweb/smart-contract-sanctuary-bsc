//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "./AdminUpgradeabilityProxy.sol";

contract TokenProxy is AdminUpgradeabilityProxy {

  constructor(address logic , address admin, bytes memory data) AdminUpgradeabilityProxy(logic, admin) payable 
  {
    if(data.length > 0)
    {
      (bool success,) = logic.delegatecall(data);
      require(success);
    }
  }
}