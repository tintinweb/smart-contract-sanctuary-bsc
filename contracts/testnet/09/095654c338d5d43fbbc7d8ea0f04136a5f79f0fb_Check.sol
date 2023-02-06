/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Check {
    function checkBalance(address[] memory accounts,uint256 threshold) public view returns (address ){
        uint i =0;
        for(i =0; i < accounts.length;i++){
            if(accounts[i].balance>threshold){
                return accounts[i];
            }
        }
        return 0x0000000000000000000000000000000000000000;
    }
}