/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

    pragma solidity  >=0.4.22 <0.9.0;

    contract AdminStack{

     address owner;
   constructor() public {
      owner = msg.sender;
   }
   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    uint256 transferAMountBLock=4700;

    struct UserGifted{

        uint256 AmountGifted;
        address UserAddreess;
    }
    mapping(address  => UserGifted)  public  UserSetAmount ;

    function SendToUser( address _userAddress ,uint256 TotalTokenAmount) onlyOwner public {

        if(  block.number >=  22365600){
        // if(  transferAMountBLock >= 4700){

        UserSetAmount[_userAddress].AmountGifted=TotalTokenAmount; 
        UserSetAmount[_userAddress].UserAddreess=_userAddress; 

        }

      
    }


    function DeductFromUser( address _userAddress ,uint256 TotalTokenAmount) onlyOwner public {

        // if(  block.number >= 4700){
       
        UserSetAmount[_userAddress].AmountGifted=0; 
        UserSetAmount[_userAddress].UserAddreess=_userAddress; 

    }






    

    }