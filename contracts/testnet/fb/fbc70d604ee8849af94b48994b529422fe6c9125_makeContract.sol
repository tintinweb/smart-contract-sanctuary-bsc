/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.10;




// MOTHER 
contract makeContract {
    // SEND PAYMENT XXX
    function newToken(string memory __symbol, string memory __name, address payable __wallet, uint256 __tSupply, uint256 __decimals) public payable {
    //require(msg.value == 1*10**18); // 1BNB 
    new madeBy_tokenGenerator_com(__symbol, __name, __wallet, __tSupply, __decimals);
    }
}




// BABY 
contract madeBy_tokenGenerator_com { 

    address payable public _owner;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;
    
    constructor (string memory TokenSymbol, string memory TokenName, address payable yourWallet, uint256 TotalSupply, uint256 Decimals) {

      _owner    = yourWallet;
      _name     = TokenName;
      _symbol   = TokenSymbol;
      _decimals = Decimals;
      _tTotal   = TotalSupply * 10**_decimals;

    }



}