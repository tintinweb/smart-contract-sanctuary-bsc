// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./ERC20Detailed.sol";

contract DogeProtocol is ERC20Detailed {
    
  string constant tokenNameWeNeed = "Mutant Doge";
  string constant tokenSymbol = "Mdoge";
  uint8 decimalsWeNeed = 18;
  
  uint256 totalSupplyWeNeed = 100 * (10**12) * (10**decimalsWeNeed);
  uint256  baseBurnPercentDivisor = 10000; //1% per transaction

  
  constructor(address priorApprovalContractAddress,address priorContractAddress) public payable ERC20Detailed
  (
       tokenNameWeNeed, 
       tokenSymbol, 
       totalSupplyWeNeed,
       baseBurnPercentDivisor, 
       decimalsWeNeed,
       priorApprovalContractAddress,
       priorContractAddress
   ) 
  {
    _mint(msg.sender, totalSupply());
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  
}