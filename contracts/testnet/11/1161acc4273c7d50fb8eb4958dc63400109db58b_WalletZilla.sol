/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

//pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract  WalletZilla{

uint256 minimunBusdForStaking = 50;
uint256 maximumBusdForTrading = 10000;
uint256 busdCycle =  7;
uint256 maxProfit = 10;

uint256 IdProvider = 4000;
IERC20 public Busd;

struct userDetail{
    uint256 userId;
    address userAddress;
    uint256 userRefferdBy;
    address refralAddress;
    uint256 totalDirects;
    uint256 [] userTotalTimesInvestmentWithAmount;
}

struct UserInvestDetail{
    address userAddress;
    uint256 amount;
    uint256 timeperiod;
}

mapping(address => userDetail ) public UserDetail;
mapping(uint256 => UserInvestDetail ) public InvestDeatil;
mapping(uint256 => bool) public IsExist;
mapping(uint256 => address ) public IdToAddress;

  constructor (){

     Busd = IERC20(0x7acB87EcFeF8DF169Aa9d531aA76e445D1d29604);
      IsExist[3999]=true;

   }


function InvestBusd (  uint256 amtInvest , uint256 refBy)  public {
    // require( amtInvest >= 50*1e18, " please Increase Package Value !! Miniumum Value 50 busd ");
    // require( amtInvest <= 10000*1e18 ," exceeding maximium Purchase Value  !! maximum package vlaue is 10000 Busd");
    require( IsExist[refBy] == true, "Invalid Refral Address");
    require(Busd.allowance(msg.sender,address(this))>=amtInvest,"Exceed :: allowance");

    if(UserDetail[msg.sender].userId == 0){
        UserDetail[msg.sender].userId = IdProvider;
        UserDetail[msg.sender].userAddress = msg.sender;
        IdToAddress[IdProvider]=msg.sender;
        IsExist[IdProvider]=true;
    }   
      if(UserDetail[msg.sender].userRefferdBy == 0){
         UserDetail[msg.sender].userRefferdBy = refBy;
         UserDetail[msg.sender].refralAddress =IdToAddress[refBy];
          UserDetail[msg.sender].totalDirects++;
    }
            UserDetail[msg.sender].userTotalTimesInvestmentWithAmount.push(amtInvest); 
            Busd.approve(msg.sender,amtInvest*1e18);
           Busd.transferFrom(msg.sender,address(this),amtInvest);
           address _referrer = UserDetail[msg.sender].refralAddress;

        // for (uint8 i = 0; i < 10; i++) {
        //     if (_referrer != address(0)){
        //         if(UserDetail[msg.sender].totalDirects>= i){
             
        //         }

              
        //         if ( UserAllDetailByAddress[_referrer].referalAddress !=address(0))
        //         _referrer = UserAllDetailByAddress[_referrer].referalAddress;
        //         else break;
        //     }
        // } 
        
    
}










}