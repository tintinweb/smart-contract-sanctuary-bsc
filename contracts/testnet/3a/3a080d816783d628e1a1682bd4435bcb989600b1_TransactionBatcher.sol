/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// File: contracts/TycoonTokenTransfer/TransactionBatcher.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface TFTCToken {
     function transfer(address recipient, uint256 amount)
        external
        returns (bool success);
}
contract TransactionBatcher {
    TFTCToken public TFTC  ;
    constructor(address TFTCTokenAddress) {
        TFTCToken _TFTCToken = TFTCToken(TFTCTokenAddress);
        TFTC = _TFTCToken;
        owner = msg.sender;
    }

   address public owner; 

  function batchTokenTransfer(address[] memory userAccount, uint256[] memory values) public {
     for(uint i =0 ; i<= userAccount.length; i++) {
          TFTC.transfer(userAccount[i],values[i]);
     }
  }
  
  function singleTokenTransfer(address userAccount, uint256 values) external returns(bool){
    TFTC.transfer(userAccount,values);
    return true;
  }

 }