/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.1;

library Library {
  struct ids {
     uint256 id;
     bool isValue;
   }
}

contract Ownable {
    
  address internal _owner;

  constructor () {
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require( _owner == msg.sender, "Ownable: caller is not the owner" );
    _;
  }
}

contract Donation is Ownable {
    using Library for Library.ids;

    address[] wlist = new address[](25);
    uint256 count = 0;
    mapping(address => Library.ids) ids;

    function MakeDonation () public payable {
        //require(msg.value == 63000000000000000, "Your sent amount is less than 2.5$");
        require(ids[msg.sender].isValue == false, "You are already on the whitelist!");
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

    function Withdraw () public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}