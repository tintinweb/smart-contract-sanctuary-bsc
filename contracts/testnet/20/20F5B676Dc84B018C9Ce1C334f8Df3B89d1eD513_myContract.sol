/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;



contract myContract {

    address owner;
    string tokenName;
    string symbol;
    uint decimals;
    uint256 totalSupply;

    constructor(

        string memory _tokenName,
        string memory _symbol,
        uint256 _totalSupply,
        uint _decimals,
        address _owner
        
        ) {
             tokenName = _tokenName;
              symbol = _symbol;
                totalSupply = _totalSupply;
                  decimals = _decimals;
              owner = _owner;     
    }
      
}