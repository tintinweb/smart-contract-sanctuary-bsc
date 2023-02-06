/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Check {
    function checkBalance(address[] memory accounts,uint256 threshold) public view returns (address[2] memory){
        address[2] memory result ;
        uint256 j=0;

        for(uint i =0; i < accounts.length;i++){
            if(j>1) break;
            if(accounts[i].balance>threshold){
                result[j] = accounts[i];
                j++;
            }
        }
        return result;
    }
}