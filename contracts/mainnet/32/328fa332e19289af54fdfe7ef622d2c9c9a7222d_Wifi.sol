/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT

/**
Telegram - 
*/
pragma solidity ^0.8.5;

contract Wifi 
{
string Name ;
uint Pass; 

constructor()public 
{ Name = "Ravi" ;
  Pass = 15;
  }

function getName() view public returns ( string memory) 
    {
        return  Name ; 
        } 
 
 function getPass() view public returns ( uint) 
    {
        return  Pass ; 
        } 
   
 function changePass () public 
 {
     Pass = 25 ;
 }
}