/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.0;

contract Donation {
    string text;
    address[] whitelist;
    address owner;
    uint256 count;

    function MakeDonation () public {
        whitelist[count] = msg.sender; 
        count++;
    }

    function CountWhiteList () public view returns(uint256){
        return count;
    }

    function GetWhiteList () public view returns(address[] memory ){
        return whitelist;
    }
}