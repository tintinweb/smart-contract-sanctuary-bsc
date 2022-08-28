/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity  >=0.4.22 <0.9.0;

contract refer{

  struct user {
    //    uint256 UserId; 
    //    uint256 referlal_Id;    
    //    uint256 tokenpurchased;
    //    uint256 totalPayment;

       address refered_by;
       address level_1 ;
       address level_2 ;
       address level_3 ;
  }  



  mapping(address => user) public setUser;

function BuyByReference( address _ReferalAddress ) public {

//  , uint256 _tokenAmt , uint256 _tokenCurrenPrice 
    // setUser[msg.sender].tokenpurchased= _tokenAmt;
    // setUser[msg.sender].totalPayment= _tokenAmt * _tokenCurrenPrice;
    // setUser[msg.sender].refered_by = _ReferalAddress;

     setUser[msg.sender].level_1 = _ReferalAddress;
    setUser[msg.sender].level_2 =  setUser[_ReferalAddress].level_1;
    //  setUser[msg.sender].level_3 =  setUser[level_2].level_1;




     
      

   





}









}