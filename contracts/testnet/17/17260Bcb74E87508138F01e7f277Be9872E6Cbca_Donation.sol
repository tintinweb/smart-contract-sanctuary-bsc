/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.0;

contract Donation {
    address[] wlist = new address[](5);
    uint256 count = 0;
    mapping(address => uint) ids;

    function MakeDonation () public {
        wlist[count] = msg.sender; 
        ids[msg.sender] = count;
        count++;
    }

    function VerifyExistenceInTheWhitelist (address id) public view returns(uint){
        return ids[id];
    }

    function CountWhiteList () public view returns(uint256){
        return count;
    }

    function GetWhiteList () public view returns(address[] memory ){
        return wlist;
    }
}