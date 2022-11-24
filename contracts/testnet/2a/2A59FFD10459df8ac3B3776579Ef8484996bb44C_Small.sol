/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT

 pragma solidity ^0.8.0;
  
   contract Small 
   {

       string private _name = "Gamefy";
       string  private _symbol = "GMF";

       address Diployr;

       constructor () {

           Diployr = msg.sender;
       }
        

    address [] accounts ;
    mapping (address => bool) Sucses;

    function length()
     public view
     returns (uint) {

        return accounts.length;
    }

    function setdata()
    public {
        
        require(Sucses[msg.sender] != true, "the address is Sucses");
        accounts.push(msg.sender);

        Sucses[msg.sender] = true;
    }

    function getdata(uint id)
    public view 
    returns (address) {

      return accounts[id];
    }

    function name()
    public view 
    returns (string memory) {

        return _name;
    }

    function symbol()
    public view 
    returns (string memory) {

        return _symbol;
    }

       function Blaance()
       public view 
       returns (uint256) {

           return address(this).balance;
       }

       function Add(uint amount)
       public payable {

       }
   }