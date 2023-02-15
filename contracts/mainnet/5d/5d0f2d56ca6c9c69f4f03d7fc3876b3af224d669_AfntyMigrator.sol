//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISafeAffinity.sol";
import "./Utils.sol";

contract AfntyMigrator is Pausable, Ownable {

  ISafeAffinity public legacyToken;
  IERC20 public newToken;

  uint public cutOff = 0;
  uint public swapRate = 10 ** 5; // migratedToken: legacyToken * (swapRate / swapRateDenominator) 
  uint public swapRateDenominator = 10 ** 5;

  event Deposited(uint amount);
  event Withdrawn(uint amount);
  event CutOffSet(uint newCutOff);
  event SwapRateSet(uint newSwapRate);
  event Migrated(uint convertedAmount, uint burnedAmount, address walletAddr);
  event MigrateApproved(uint legacyTokenBalance, address spender, address approver);
  event Rescued(address erc20Addr, uint balance, address to);

    constructor (address _legacyToken, address payable _newToken){
      legacyToken = ISafeAffinity(payable(_legacyToken));
      newToken = IERC20(_newToken);
  }

  // FOR OWNER
  function withdraw(uint amount) external onlyOwner {
    newToken.transfer(msg.sender, amount);
    emit Withdrawn(amount);
  }
  function setCutOff(uint newCutOff) external onlyOwner {
    cutOff = newCutOff;
    emit CutOffSet(newCutOff);
  }
  function setSwapRate(uint newSwapRate) external onlyOwner {
    swapRate = newSwapRate;
    emit SwapRateSet(newSwapRate);
  }
  
  // FOR USER
  function migrate() external {
    // NEED APPROVE FROM UI
    uint legacyTokenBalance = legacyToken.balanceOf(msg.sender);
    uint newTokenBalance = newToken.balanceOf(msg.sender);
    legacyToken.transferFrom(msg.sender, address(this), legacyTokenBalance);
    uint contractTokenBalance = legacyToken.balanceOf(address(this));
    legacyToken.deleteBag(contractTokenBalance);

    uint calcBase = newTokenBalance >= legacyTokenBalance ? legacyTokenBalance : newTokenBalance;
    if (calcBase > cutOff && calcBase > 0 ) {      
      uint convertedAmount = calcBase * swapRate / swapRateDenominator;
      newToken.transfer(msg.sender, convertedAmount);
      emit Migrated(convertedAmount,legacyTokenBalance, msg.sender);
    } else {
      emit Migrated(0, legacyTokenBalance, msg.sender);
    }
  } 

  function rescueERC20(address erc20Addr, address to) public onlyOwner {
    IERC20 token = IERC20(erc20Addr);
    uint balance = token.balanceOf(address(this));
    token.transfer(to, balance);
    emit Rescued(erc20Addr, balance, to);
  }
}