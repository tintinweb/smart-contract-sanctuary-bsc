/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract Crud{
   int counter=0;
   struct Books {
      string name;
      string writter;
      uint id;
      bool published;
      bool available;
      }
   
   mapping(int =>Books) public mybook;
   function Add(string memory param1, string memory param2, uint param3, bool param4, bool param5 )  public {
      Books memory Book;

      Book.name=param1;
      Book.writter=param2;
      Book.id=param3;
      Book.available=param4;
      Book.published=param5;
      mybook[counter]=Book;
      counter++;
   }
   function View(int index
   )public view returns (
     string memory, string memory, uint, bool, bool) { 
           
        return(mybook[index].name, mybook[index].writter,
               mybook[index].id, mybook[index].available, mybook[index].published); 
    }
    function Update(int index, string memory param1, string memory param2, uint param3, bool param4, bool param5 )  public {
      mybook[index].name=param1;
      mybook[index].writter=param2;
      mybook[index].id=param3;
      mybook[index].available=param4;
      mybook[index].published=param5;
   }
}