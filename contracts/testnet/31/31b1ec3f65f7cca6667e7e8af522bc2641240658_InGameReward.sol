// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract InGameReward is Ownable {
  address public contractAKSToken = 0x0D1CeB4a0718d43785b169Ddf644E13ED86b94Ad;
  address[] public depositWithdrawAddress;

  function transferToken(address  _to, uint256 _amount) external 
  {
    require(isDepositWithdrawAddress(msg.sender) && isDepositWithdrawAddress(_to), "Invalid address");

    IERC20 _tokenAKS = IERC20(contractAKSToken);
    _tokenAKS.transfer(_to, _amount);
  }

  function isDepositWithdrawAddress(address _depositWithdraw) internal view returns (bool) 
  {
    for(uint i = 0; i < depositWithdrawAddress.length; i++) 
    {
      if(_depositWithdraw == depositWithdrawAddress[i])
      {
        return true;
      }
    }
    return false;
  }
    
  function setContractAKSToken(address _contractAKSToken) external onlyOwner 
  {
    contractAKSToken = _contractAKSToken;
  }

  function setDepositWithdrawAddress(address[] memory _depositWithdrawAddress) external onlyOwner 
  {
    depositWithdrawAddress = _depositWithdrawAddress;
  }
}