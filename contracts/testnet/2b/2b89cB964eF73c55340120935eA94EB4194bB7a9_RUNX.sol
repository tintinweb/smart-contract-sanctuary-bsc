/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RUNX{

    IERC20 public token;
    address  public _owner;
    uint256 public  decimal=10e18;
    uint256  public uplineamount ;
    uint256 public total_Supply=500000000*decimal;
    uint256 public  rate = 1000000000000000;
    uint256 public rewardtime = 2 minutes;
    mapping (address=> uint256 )  balances;
       
 constructor (IERC20 _token )
 {
     token = _token;
     _owner = msg.sender;  
 }
          struct User 
    {
        uint256 amount;
        address payable upline;
        uint256 referrals;
        uint256 deposit_time;
        uint256 withdrawreward;
        uint256 withrawablereward;
        uint256  upcomingreward;
        uint256 totalReward;
        uint256 time;
    }  

        uint256 public total_users;
    mapping(address => User) public users;
    mapping(address => uint256) public uplinereward;

 modifier only_owner{
    require( _owner==msg.sender , "only owner can with_draw bnb");
    _;
 }


function BuyToken(address payable _upline) public payable {
   // require(msg.value>200000000000000000 ,"value must be greater than 0.2 bnb");

   uint256 a = check_tokenValue(msg.value);
    users[msg.sender].withdrawreward += a;
    users[msg.sender].totalReward += a;

   _setUpline(_upline ,msg.sender);
   users[msg.sender].deposit_time = uint40(block.timestamp);

    uplineamount += 35*msg.value/100;
   uplinereward[_upline] += uplineamount;
   _upline.transfer(uplineamount);


      users[msg.sender].amount += msg.value ;

      uint256 b = 20*a/100;
      uint256 c = a-b;

      users[msg.sender].withdrawreward += b;
      users[msg.sender].upcomingreward += c;
      token.transfer( msg.sender , b);

      users[msg.sender].time = uint(block.timestamp)+rewardtime;
     
   } 
   

   function vestingAmount(address add) public view returns (uint256)
   {
       uint256 a ;
       if(block.timestamp  > users[add].time)
       {
           uint256 c = block.timestamp-users[msg.sender].deposit_time ;
           uint256 d = c/rewardtime;

                         if(d>=0 && d<6)
                              { 
                                               if (d==0){
                                              
                                                   uint256 s = 1*15;
                                                 a= users[add].totalReward*s/100;
                                                 require(users[add].upcomingreward>a ,"your remaing amount is less");
                                                return  a;
                                                
                                                
                                               } 
                                               else{
               
                                                uint256 s = d*15;
                                             
                                              a= users[add].totalReward*s/100;
                                               require(users[add].upcomingreward>a ,"your remaing amount is less");
                                               return a;

                                               }
                               }
                        else
                                 {
                          return   a= users[add].upcomingreward;
                                 }
       }

       else{
       return a;
       }
   }


     function withdrawremeningAmount() public 
{
    uint256 z = vestingAmount(msg.sender);
    token.transfer( msg.sender , z);
    users[msg.sender].time = uint(block.timestamp)+rewardtime;
    users[msg.sender].upcomingreward  =  users[msg.sender].upcomingreward-z;
   
    


}


   function recive_ether() external payable { 
    require(msg.value >0);
    }

  function balanceOf(address receiver ) public view returns(uint256){
      return token.balanceOf( receiver);
  }
  function check_tokenValue(uint256 amount ) public view returns( uint256){
       return (amount*decimal)/rate;
  }
    function check_bnbValue(uint256 amount ) public view returns( uint256){
       return (amount*rate)/decimal;
    }


  
   function SaleToken( uint256 amount ) external   
{
    token.transferFrom(msg.sender,address(this), amount);

    uint256 a = check_bnbValue(amount);
    payable(msg.sender).transfer(a);

}

   function MinimumBuyTokn( ) public  pure returns(uint256 Minimum_value){
    return 200000000000000000;
}
   function pricePrToken( ) public  pure returns(uint256 Minimum_value){
    return 100000000000000;
    }
   function withdraw_bnb()  public only_owner {
    
      payable(msg.sender).transfer(address(this).balance);
   }
   function withdraw_Token()  public only_owner {
    
      payable(msg.sender).transfer(balanceOf(address(this)));
   }


     function _setUpline(address payable _upline,address add) public {
        if( users[add].upline == address(0) && _upline != add && add != _owner && (users[_upline].deposit_time > 0 || _upline == _owner)) {
        {
            users[add].upline = _upline;
            users[_upline].referrals++;
            total_users++;
         }
         }
         }
     function _chakUpline( address _upline , address add) public view returns(bool result){
        if( users[add].upline == address(0) && _upline != add && add != _owner && (users[_upline].deposit_time > 0 || _upline == _owner) ) {
          return true;
        }
        
    }
    
}