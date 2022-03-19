/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.10;













// BABY 
contract madeBy_tokensByGEN_dot_com { 

    address payable public _owner;
    address payable public Wallet_Marketing;
    address payable public Wallet_Liquidity;

    string public _name;
    string public _symbol;
    uint256 public _decimals;
    uint256 public _tTotal;

    string public Website;
    string public Telegram;

    uint256 public ContractFee;

    constructor (string memory _TokenSymbol, string memory _TokenName, address payable _WalletAddress, uint256 _TotalSupply, uint256 _Decimals, string memory _Website, string memory _Telegram, uint256 _ContractFee) {

   

    _owner              = _WalletAddress;
    _name               = _TokenName;
    _symbol             = _TokenSymbol;
    _decimals           = _Decimals;
    _tTotal             = _TotalSupply * 10**_decimals;

    Wallet_Marketing    = _WalletAddress;
    Wallet_Liquidity    = _WalletAddress;

    // Set Socials 
    Website             = _Website;
    Telegram            = _Telegram;

    // Set contract fee
    ContractFee         = _ContractFee;


    }






}