/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

pragma solidity ^0.4.25;

contract Alice{
    function ping(uint)  returns(uint){ 
    }  
}
  
 contract Bob{
      uint x=0;
      function pong(Alice c)   returns(uint){
          x=1;
          c.ping(42);
          x=2; 
      } 
 }  
 
  
contract C {
 function pay(uint n, address d){
   d.send(n); 
  }   
 }  
 contract D1 {
  uint public count = 0; 
  function()
   { 
       count++;
   }
 }
 contract D2 { 
     function() {

     }  
}