// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract Private is Ownable {
  uint public unlockTime = 1646197200; //Wednesday, March 2, 2022 5:00:00 AM(GMT)
  uint public weekTime = 1209600; //2 weeks
  uint public numberOfAccountType = 20;
  uint public numberOfDaysToClaim = 25;
  uint[] public tokensAmountPerAccount = [1700, 2500, 3000, 5000, 10000, 15000, 20000, 21500, 23000, 30000, 
                                          35000, 40000, 45000, 50000, 63334, 66666, 70000, 100000, 150000, 180000];

  address public contractAKSToken = 0x0D1CeB4a0718d43785b169Ddf644E13ED86b94Ad;

  mapping(address => uint) public accountType;
  mapping(address => mapping(uint => uint)) public privateWalletClaimPerTime;

  function claimPrivateTokens(uint _phase) external
  {
    require(accountType[msg.sender] > 0 && accountType[msg.sender] <= numberOfAccountType, "Invalid address.");
    require(_phase > 0 && _phase <= numberOfDaysToClaim, "Invalid phase.");
    require(privateWalletClaimPerTime[msg.sender][_phase] != 0, "Account has already received the tokens.");

    require(block.timestamp >= unlockTime+(weekTime*(_phase-1)), "Currently unavailable.");
    transferClaim(msg.sender, _phase);
  }

  function transferClaim(address _account, uint _phase) internal
  {
    IERC20 _tokenAKS = IERC20(contractAKSToken);

    require(_tokenAKS.balanceOf(address(this)) > 0, "This contract has no balance.");
    _tokenAKS.transfer(_account, privateWalletClaimPerTime[_account][_phase]);

    privateWalletClaimPerTime[_account][_phase] = 0;
  }

  function importPrivateWalletAccount(address[] memory _privateWalletAddress, uint _accountType) external onlyOwner
  {
    require(_accountType > 0 && _accountType <= numberOfAccountType, "Invalid request.");

    for(uint i = 0; i < _privateWalletAddress.length; i++) 
    {
      accountType[_privateWalletAddress[i]] = _accountType;
      for(uint daysCount = 2; daysCount <= numberOfDaysToClaim; daysCount++)
      {
        privateWalletClaimPerTime[_privateWalletAddress[i]][1] = 0;
        privateWalletClaimPerTime[_privateWalletAddress[i]][daysCount] = tokensAmountPerAccount[_accountType-1] * 4 * 10**18 / 100;
      }
    }
  }

  function transferToken(address  _to, uint256 _amount) external onlyOwner 
  {
    IERC20 _tokenAKS = IERC20(contractAKSToken);
    _tokenAKS.transfer(_to, _amount);
  }
    
  function setContractAKSToken(address _contractAKSToken) external onlyOwner 
  {
    contractAKSToken = _contractAKSToken;
  }

  function setUnlockTime(uint _unlockTime) external onlyOwner 
  {
    unlockTime = _unlockTime;
  }

  function setNumberOfAccountType(uint8 _numberOfAccountType) external onlyOwner 
  {
    numberOfAccountType = _numberOfAccountType;
  }

  function setNumberOfDaysToClaim(uint8 _numberOfDaysToClaim) external onlyOwner 
  {
    numberOfDaysToClaim = _numberOfDaysToClaim;
  }
}