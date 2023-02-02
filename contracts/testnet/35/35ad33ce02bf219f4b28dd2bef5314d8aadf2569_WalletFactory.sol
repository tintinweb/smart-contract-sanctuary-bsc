// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'Wallet.sol';
contract WalletFactory {
     uint256 private _salt;
    address[] public _wallets; 
    address _owner;
     constructor()  {
        _owner = msg.sender;
        }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // create an instance of Pinksale ICO.
  function create(
  ) external onlyOwner {
    
    Wallet newWallet = new Wallet{
        salt: bytes32(++_salt)
    }(address(this));

    _wallets.push(address(newWallet));
  }
  receive() external payable
   {

   }
   function withdraw() public onlyOwner{
     
        payable(msg.sender).transfer(address(this).balance);
   }
   function balanceOfContract() public view returns(uint256 _bal){

       return address(this).balance;
   }
}