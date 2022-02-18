/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.0;

library Library {
  struct ids {
     uint256 id;
     bool isValue;
   }
}

contract Donation {
    using Library for Library.ids;

    address[] wlist = new address[](5);
    uint256 count = 0;
    mapping(address => Library.ids) ids;

    function MakeDonation () public {
        require(ids[msg.sender].isValue == true, "You are already on the whitelist!");
        wlist[count] = msg.sender; 
        ids[msg.sender] = Library.ids(count, true);
        count++;
    }

    function VerifyExistenceInTheWhitelist (address id) public view returns(bool){
        return ids[id].isValue;
    }

    function CountWhiteList () public view returns(uint256){
        return count;
    }

    function GetWhiteList () public view returns(address[] memory ){
        return wlist;
    }
}