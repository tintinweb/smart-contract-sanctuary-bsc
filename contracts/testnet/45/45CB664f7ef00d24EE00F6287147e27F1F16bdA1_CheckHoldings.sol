/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CheckHoldings {
    struct TokenInfo {
        string name;
        string symbol;
        uint256 balance;
        uint8 decimals;
    }
    
    mapping (address => TokenInfo[]) public holdings;

    function checkHoldings(address _wallet) public view returns (TokenInfo[] memory) {
        return holdings[_wallet];
    }
}