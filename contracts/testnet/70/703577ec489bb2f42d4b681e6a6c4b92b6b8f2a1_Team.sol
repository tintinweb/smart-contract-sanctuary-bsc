// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract Team is Ownable {
  uint public unlockTime = 1653670800; //Friday, May 27, 2022 5:00:00 PM(GMT)

  address public contractAKSToken = 0x0D1CeB4a0718d43785b169Ddf644E13ED86b94Ad;
  address[] public creatorAddress;

  function transferToken(address  _to, uint256 _amount) external 
  {
    require(block.timestamp >= unlockTime, "Cannot transfer at the moment.");
    require(isCreatorAddress(msg.sender), "Invalid address");
    
    IERC20 _tokenAKS = IERC20(contractAKSToken);
    _tokenAKS.transfer(_to, _amount);
  }
    
  function isCreatorAddress(address _creator) internal view returns (bool) 
  {
    for(uint i = 0; i < creatorAddress.length; i++) 
    {
      if(_creator == creatorAddress[i])
      {
        return true;
      }
    }
    return false;
  }

  function setUnlockTime(uint _unlockTime) external onlyOwner 
  {
    unlockTime = _unlockTime;
  }

  function setContractAKSToken(address _contractAKSToken) external onlyOwner 
  {
    contractAKSToken = _contractAKSToken;
  }

  function setCreatorAddress(address[] memory _creatorAddress) external onlyOwner 
  {
    creatorAddress = _creatorAddress;
  }
}