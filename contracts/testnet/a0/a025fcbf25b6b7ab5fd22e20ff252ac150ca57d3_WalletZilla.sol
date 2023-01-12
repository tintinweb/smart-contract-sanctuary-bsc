/**
 *Submitted for verification at BscScan.com on 2023-01-11
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
address owner;
IERC20 public Busd;

 uint256 [] WithdrawPercentage = [7,8,9,10,11,12,13,14,15,16];


struct userDetail{
    uint256 userId;
    address userAddress;
    uint256 userRefferdBy;
    address refralAddress;
    uint256 totalDirects;
    uint256  userLastAmountInvested;
    uint256 timeOfLastAmountstakede;
    bool     CanInvest;
    uint256  amountEarned;
   
}



mapping(address => userDetail ) public UserDetail;
mapping(uint256 => bool) public IsExist;
mapping(uint256 => address ) public IdToAddress;

modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

constructor (address _owner){

     Busd = IERC20(0x7acB87EcFeF8DF169Aa9d531aA76e445D1d29604);
     owner = _owner;
     IsExist[3999]=true;

}


function InvestBusd (  uint256 amtInvest , uint256 refBy)  public {
    // require( amtInvest >= 50*1e18, " please Increase Package Value !! Miniumum Value 50 busd ");
    // require( amtInvest <= 10000*1e18 ," exceeding maximium Purchase Value  !! maximum package vlaue is 10000 Busd");
    require(UserDetail[msg.sender].CanInvest == true ,"Cannot Invest Now !! staking is in progress");
    require( IsExist[refBy] == true, "Invalid Refral Address");
    require(Busd.allowance(msg.sender,address(this))>=amtInvest,"Exceed :: allowance");

    if(UserDetail[msg.sender].userId == 0){
        UserDetail[msg.sender].userId = IdProvider;
        UserDetail[msg.sender].userAddress = msg.sender;
        IdToAddress[IdProvider]=msg.sender;
        IsExist[IdProvider]=true;
        IdProvider++;
    }   
      if(UserDetail[msg.sender].userRefferdBy == 0){
         UserDetail[msg.sender].userRefferdBy = refBy;
         UserDetail[msg.sender].refralAddress =IdToAddress[refBy];
          UserDetail[IdToAddress[refBy]].totalDirects++;
    }
            UserDetail[msg.sender].userLastAmountInvested = amtInvest;
            UserDetail[msg.sender].CanInvest= false; 
            // Busd.approve(msg.sender,amtInvest*1e18);
            uint256 transferToTheRef = (amtInvest*5)/100;
           if( (UserDetail[IdToAddress[refBy]].userLastAmountInvested*300)/100> UserDetail[IdToAddress[refBy]].amountEarned){ 
           Busd.transferFrom(msg.sender, IdToAddress[refBy],transferToTheRef);
            UserDetail[IdToAddress[refBy]].amountEarned += transferToTheRef;
           Busd.transferFrom(msg.sender,address(this),amtInvest-transferToTheRef);
           }
           else{
                Busd.transferFrom(msg.sender,address(this),amtInvest);
           }
           
           UserDetail[msg.sender].timeOfLastAmountstakede = block.timestamp;

     
}

function WithdrwalStakeAmount(uint256 userId) public {
  require( IsExist[userId]  == true, "Invalid user Address");
//   if(UserDetail[msg.sender].timeOfLastAmountstakede+ 604800 >= block.timestamp ){
  if(UserDetail[msg.sender].timeOfLastAmountstakede+ 420 >= block.timestamp ){
    uint256 amt =   (UserDetail[msg.sender].userLastAmountInvested*300)/100;
    Busd.transfer(msg.sender,amt);
    UserDetail[msg.sender].amountEarned = amt;
    UserDetail[msg.sender].CanInvest = true;
  }else
  revert("Staking time Period Not Completed ");


}
function WithdrwalPricipalAmount (uint256 UserId) public{

  require( IsExist[UserId]  == true, "Invalid user Address");

    if(UserDetail[msg.sender].CanInvest == true ){

    uint256 userInv = UserDetail[msg.sender].userLastAmountInvested;
    uint256 Incentive = (userInv*116)/100;  
    
    
    //   Busd.transfer(msg.sender,UserDetail[msg.sender].userLastAmountInvested );



     address _referrer = UserDetail[msg.sender].refralAddress;

        for (uint8 i = 0; i < 10; i++) {
            if (_referrer != address(0)){
                if(UserDetail[msg.sender].totalDirects>= i){
              Busd.transfer(msg.sender,(Incentive*WithdrawPercentage[i])/100);
                }

              
                if ( UserDetail[_referrer].refralAddress !=address(0))
                _referrer = UserDetail[_referrer].refralAddress;
                else break;
            }
        } 
    }else
    revert(" Staking in  in progress");


}

function TransferAmountToOwnerWallet() public  onlyOwner {
      Busd.transfer(msg.sender,(address(this).balance));
    
}


function getBalance() public onlyOwner view  returns (uint) {
    return address(this).balance;
}











}