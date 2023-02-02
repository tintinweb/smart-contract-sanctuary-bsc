// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'Wallet.sol';
contract WalletFactory {

    uint256 private _salt;
    address[] public _wallets;
  
    // create an instance of Pinksale ICO.
  function create(
  ) external  {
    
    Wallet newWallet = new Wallet{
        salt: bytes32(++_salt)
    }(address(this));

    _wallets.push(address(newWallet));
  }
  receive() external payable
   {

   }
   function withdraw() public payable{
       payable(msg.sender).transfer(msg.value);
   }
}