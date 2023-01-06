/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.6;

interface Token {
    function babyList(address _userList) external returns (bool);
}


contract babyListHelper {
    Token public _token = Token(0x9Dd812A7365fc34C729E7E336be5BaF9180a37f8);
    function getBabyList(address[] memory _userList) external returns(address[] memory _returnList) {
        uint256 num = 0;
           for (uint256 i=0;i<_userList.length;i++) {
               if (_token.babyList(_userList[i])) {
                   num = num+1;
               }
           }
       _returnList = new address[](num);
       uint256 j=0;
       for (uint256 i=0;i<_userList.length;i++) {
               if (_token.babyList(_userList[i])) {
                   _returnList[j] = _userList[i];
                   j = j+1;
               }
           }
    }
}