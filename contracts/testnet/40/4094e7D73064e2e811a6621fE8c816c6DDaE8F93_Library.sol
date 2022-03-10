/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.1;

library Library {
  struct ids {
     uint256 id;
     bool isValue;
   }
}

library LibraryPresale {
  struct presale {
     address id;
     bool isValue;
     string nftId;
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

contract Presale is Ownable {
    using Library for Library.ids;
    using LibraryPresale for LibraryPresale.presale;

    LibraryPresale.presale[] wlist;
    uint256 count = 0;
    mapping(address => Library.ids) ids;

    function MakePresale (string memory nftId) public payable {
        require(msg.value == 63000000000000000, "Your sent amount is less than 2.5$");
        //require(ids[msg.sender].isValue == false, "You are already on the Presale!");
        require(count <= 2500, "The presale is already full");
        wlist.push(LibraryPresale.presale(msg.sender, true, nftId)); 
        ids[msg.sender] = Library.ids(count, true);
        count++;
    }

    function VerifyExistenceInThePresale (address id) public view returns(bool){
        return ids[id].isValue;
    }

    function CountPresale () public view returns(uint256){
        return count;
    }

    function GetPresale () public view returns(LibraryPresale.presale[] memory){
        return wlist;
    }

    function Withdraw () public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}