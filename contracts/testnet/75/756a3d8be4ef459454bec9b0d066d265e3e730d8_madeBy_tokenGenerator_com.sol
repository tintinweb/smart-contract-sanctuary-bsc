/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.10;

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