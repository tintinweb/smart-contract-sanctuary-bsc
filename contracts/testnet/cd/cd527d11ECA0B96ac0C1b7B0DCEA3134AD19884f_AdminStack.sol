/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT

    pragma solidity  >=0.4.22 <0.9.0;



interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}


    contract AdminStack{
    IERC20 public inrXToken;

     address owner;
   constructor(IERC20 _inrX, address payable ownerAddress) {
        owner = ownerAddress;  
        inrXToken = _inrX;
   }
   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    uint256 public transferAMountBLock;


    struct UserGifted{

        uint256 AmountGifted;
        address UserAddreess;
        uint256 UserReveneGenrated;
        bool IsUserWithdrwalAmount; 
        uint256 UserTokenRelasingTIme;
        uint256 UserClaimedToken;
        uint256 userMontlyLimit;
    }
    mapping(address  => UserGifted)  public  UserSetAmount ;

    function SendToUser( address _userAddress ,uint256 TotalTokenAmount , uint8 phase  ) onlyOwner public {

       
         UserSetAmount[_userAddress].AmountGifted += TotalTokenAmount*1e18; 
         UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
         UserSetAmount[_userAddress].UserAddreess = _userAddress; 

    }
     
     function ReveneGenration(  address _userAddress )  public view  returns( uint256 ){
        if( block.timestamp <=  UserSetAmount[_userAddress].UserTokenRelasingTIme + 1200){
        uint256 cal =  ((UserSetAmount[_userAddress].AmountGifted*5))/100;
       if(UserSetAmount[_userAddress].UserClaimedToken ==0){
        return   (cal/60)* (block.timestamp  - UserSetAmount[_userAddress].UserTokenRelasingTIme);
       } else {
       return (cal/60)* (block.timestamp  - UserSetAmount[_userAddress].UserTokenRelasingTIme) - UserSetAmount[_userAddress].UserClaimedToken ;
            }
            
    }
          
             if( block.timestamp >=  UserSetAmount[_userAddress].UserTokenRelasingTIme + 1200){
            if(UserSetAmount[_userAddress].UserClaimedToken == 0){
            return UserSetAmount[_userAddress].AmountGifted;
                } else {
                  return UserSetAmount[_userAddress].AmountGifted - UserSetAmount[_userAddress].UserClaimedToken ;
            }
            
        }   
   
    }
    

     function avaibleForClaim( address _userAddress ) onlyOwner public {
        uint256 setvalue = ReveneGenration(_userAddress ); 
       

        if(UserSetAmount[_userAddress].userMontlyLimit + 2592000 < block.timestamp &&  UserSetAmount[_userAddress].IsUserWithdrwalAmount == true ){
                UserSetAmount[_userAddress].UserClaimedToken = setvalue;
                inrXToken.transfer(_userAddress,setvalue);
                UserSetAmount[_userAddress].userMontlyLimit=block.timestamp;
                UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
  
      
         }
        
            if(UserSetAmount[_userAddress].IsUserWithdrwalAmount == false){
                 UserSetAmount[_userAddress].UserClaimedToken = setvalue;
                 inrXToken.transfer(_userAddress,setvalue);
                 UserSetAmount[_userAddress].userMontlyLimit=block.timestamp;
                 UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
                 UserSetAmount[_userAddress].IsUserWithdrwalAmount =  true;
        

           }  
        

    }

    function NilAccount( address _userAddress) onlyOwner public {
         UserSetAmount[_userAddress].AmountGifted =0; 

    }
   

receive() external payable {
       
    }





    }