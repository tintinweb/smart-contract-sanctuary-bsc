/**
 *Submitted for verification at BscScan.com on 2022-08-30
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
        uint256 UserReveneGenrated;
        bool IsAviableForWithdrwal; 
        uint256 UserTokenRelasingTIme;
    }
    mapping(address  => UserGifted)  public  UserSetAmount ;

    function SendToUser( address _userAddress ,uint256 TotalTokenAmount , uint8 phase  ) onlyOwner public {

       
        UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp*1000;
        UserSetAmount[_userAddress].AmountGifted += TotalTokenAmount; 
        UserSetAmount[_userAddress].UserAddreess = _userAddress; 

    }
    function ReveneGenration(  address _userAddress ) public{
        
        if( UserSetAmount[_userAddress].UserTokenRelasingTIme <=  UserSetAmount[_userAddress].UserTokenRelasingTIme + 1200){

            uint256 cal =  ((UserSetAmount[_userAddress].AmountGifted*5)*1e18)/100;
                UserSetAmount[_userAddress].UserReveneGenrated +=  cal/60;

        }

        
    }
        







    }