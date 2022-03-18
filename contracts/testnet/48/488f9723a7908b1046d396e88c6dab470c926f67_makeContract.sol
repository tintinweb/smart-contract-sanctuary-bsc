/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.10;

contract makeContract {

// SEND PAYMENT XXX

  function newToken(string memory __symbol, string memory __name, address payable __wallet) public payable {


    require(msg.value == 1*10**16); // 0.01BNB 
    new testToken(__symbol, __name, __wallet);
    
  }


receive() external payable {}

// PURGE BNB AND TOKENS FUNCTION XXXX

}



contract testToken { 

    string public _name; 
    string public _symbol;
    address payable public _owner;
    
    constructor (string memory tokenSymbol, string memory tokenName, address payable _yourWallet) {

    _name   = tokenName; 
    _symbol = tokenSymbol; 
    _owner  = _yourWallet;

    }

    
receive() external payable {}

}