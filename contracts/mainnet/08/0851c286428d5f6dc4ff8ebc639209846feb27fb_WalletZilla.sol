/**
 *Submitted for verification at BscScan.com on 2023-02-09
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


    uint256  IdProvider = 5000;
    address public owner;
    address public TokenLiquidityWallet;
    address public Operator; 
    uint256 public deployedTime;
    IERC20 public Busd;
    IERC20 public WZT;
 
  

    uint256 [] WithdrawPercentage = [0,7,8,9,10,11,12,13,14,15,16];
        
    struct userDetail{

        uint256 userId;
        address userAddress;
        uint256 userRefferdBy;
        address refralAddress;
        uint256 totalDirects;
        uint256  userLastAmountInvested;
        uint256   Totalwithdrwal;
        uint256  amountEarnedByRef;
        uint256 airdropReward;
        uint256 totalIncentiveEarned; 
        uint256 totalDeposite;
    
    }

    struct userRoyaltyIncome{
        uint256  usermanagerIncome;
        uint256  userSeniorManagerIncome;
        uint256  dailyTopFiveIncome; 
    }

    struct userStakingDetail{

        uint256   expTime;
        bool isStakingActive;
        uint256 timeOfLastAmountstakede;
        uint256 timeofLastWithdrwal;
        uint256  userLastTimeAmountTotalRewardClaimed;
        


    }


    
    mapping(address => userDetail ) public UserDetail;
    mapping(address => userStakingDetail ) public UserStakingDetail;
    mapping(address => userRoyaltyIncome) public  UserRoyalityDetail;
    mapping(uint256 => bool) public IsExist;
    mapping(uint256 => address ) public IdToAddress;

    modifier onlyOwner() {
            require(msg.sender == owner);
            _;
        }
        
      modifier onlyOperator() {
            require(msg.sender == Operator);
            _;
        }
          

    constructor (address _owner , address _TokenLiquidityWallet,address _Operator){

        Busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        WZT = IERC20(0x92c94A2658f685b6d20F7b53e613cedE78b4CEB7);


        owner = _owner;
        Operator = _Operator;
        TokenLiquidityWallet = _TokenLiquidityWallet;
        deployedTime = block.timestamp;

        IsExist[3999]=true;
            
        
    }

event Invest(uint256 AmountInv,address userAddress, uint256 uiserId, uint256  userRefferdById , address RefByAddress);
event RegNewuser(uint256 AmtInv,address  userAddress,  uint256 uiserId, uint256  userRefferdById , address RefByAddress);
event claimedReward (uint256 rewardClaimed,address userAddress); 
event incentiveShared (uint256 level ,uint256 amount , address addressOfuser,address claimBy);
event AirdropClaimed(address userAddr, uint256 amount);
event referalIncome(address userWoGotIncome,uint256 referalincome, address refealaddress ,uint256 ReferTo   );
event royalityIncome(address UserAddress , uint256 amount ,string incomeType );

    function InvestBusd (  uint256 amtInvest , uint256 refBy)  public {
        require( amtInvest >= 50*1e18, " please Increase Package Value !! Miniumum Value 50 busd ");
        require( amtInvest <= 10000*1e18 ," exceeding maximium Purchase Value  !! maximum package value is 10,000 Busd");
        require(UserStakingDetail[msg.sender].isStakingActive == false ,"Cannot Invest Now !! staking is in progress");
        require( IsExist[refBy] == true, "Invalid Refral Address");
        require(Busd.allowance(msg.sender,address(this))>=amtInvest,"Exceed :: allowance");
        bool pending = IsRewardClaimPending(msg.sender); 
        if(pending == true){
                revert("please Claim Pending Amount To invest More");
        }

        if(UserDetail[msg.sender].userId == 0){
            UserDetail[msg.sender].userId = IdProvider;
            UserDetail[msg.sender].userAddress = msg.sender;
            IdToAddress[IdProvider]=msg.sender;
            IsExist[IdProvider]=true;
            emit RegNewuser( amtInvest ,msg.sender,IdProvider, refBy ,IdToAddress[refBy]);
            IdProvider++;
        }   else{
          
            UserStakingDetail[msg.sender].timeofLastWithdrwal=0;
            UserStakingDetail[msg.sender].userLastTimeAmountTotalRewardClaimed=0;
            UserStakingDetail[msg.sender].timeOfLastAmountstakede =0;


        }
        if(UserDetail[msg.sender].userRefferdBy == 0){
            UserDetail[msg.sender].userRefferdBy = refBy;
            UserDetail[msg.sender].refralAddress =IdToAddress[refBy];
            UserDetail[IdToAddress[refBy]].totalDirects++;
            // UserDetail[IdToAddress[refBy]].totalTeamBusiness += amtInvest; 
        }
                UserDetail[msg.sender].userLastAmountInvested = amtInvest;
                UserDetail[msg.sender].totalDeposite += amtInvest;
                UserStakingDetail[msg.sender].isStakingActive= true; 
                UserStakingDetail[msg.sender].timeofLastWithdrwal= block.timestamp;
           
                Busd.transferFrom(msg.sender,address(this),amtInvest);

       
                
                    uint256 transferToTheRef = (amtInvest*5)/100;
                    uint256 ProfitValueRemaining = checkProfitForincomeAddition(IdToAddress[refBy]);
                if(ProfitValueRemaining!=0){
                    if(ProfitValueRemaining >= transferToTheRef){
                     UserDetail[IdToAddress[refBy]].amountEarnedByRef  += transferToTheRef;
                        emit referalIncome(IdToAddress[refBy],transferToTheRef,msg.sender, UserDetail[msg.sender].userId);
                     }else{
                             uint256 extra =  transferToTheRef - ProfitValueRemaining;
                             UserDetail[IdToAddress[refBy]].amountEarnedByRef  +=  transferToTheRef - extra;
                             emit referalIncome(IdToAddress[refBy],transferToTheRef,msg.sender, UserDetail[msg.sender].userId);

                        }
                }

                  
               
                Busd.transfer(owner,(amtInvest*5)/100);
               
                UserStakingDetail[msg.sender].timeOfLastAmountstakede = block.timestamp;
                UserStakingDetail[msg.sender].expTime = block.timestamp+18144000;
            
            uint256 totalUserWZTtoken = (amtInvest*1)/3;
            
            UserDetail[msg.sender].airdropReward += totalUserWZTtoken;
    
             emit Invest( amtInvest ,msg.sender,UserDetail[msg.sender].userId, refBy ,IdToAddress[refBy]) ; 

    }

    
    function calculateWithdrawlAmount ( address _userAddr)  public  view returns(uint256) {

          uint256   totalIncomeWithoutRoi =   UserDetail[_userAddr].totalIncentiveEarned + UserDetail[_userAddr].amountEarnedByRef  + UserStakingDetail[_userAddr].userLastTimeAmountTotalRewardClaimed  +  UserRoyalityDetail[_userAddr].dailyTopFiveIncome + UserRoyalityDetail[_userAddr].userSeniorManagerIncome + UserRoyalityDetail[_userAddr].usermanagerIncome  ;
            uint256 totalPercent =  (UserDetail[_userAddr].userLastAmountInvested*300)/100;

                if( UserStakingDetail[_userAddr].expTime < block.timestamp ){

                        uint256 time = UserStakingDetail[_userAddr].expTime - UserStakingDetail[_userAddr].timeOfLastAmountstakede;
                     
                        
                        uint256 profit =  (UserDetail[_userAddr].userLastAmountInvested*(301*1e21)/(60*60*24*210))/100;

                        uint256 amt =  (profit*time)/1e21;
                       if(amt + totalIncomeWithoutRoi <= totalPercent){
                       
                          return amt;

                       } else if(amt + totalIncomeWithoutRoi > totalPercent){
                                uint256 amount =amt + totalIncomeWithoutRoi; 
                                uint256 AmtAfterExcluding = amount-totalPercent;
                                uint256 amountToReturn = amt - AmtAfterExcluding;
                                if( amountToReturn >=0 ){
                                return amountToReturn;   
                                }else{
                                    return 0;
                                }           
                       }
        
                    }


                else if(  UserStakingDetail[_userAddr].expTime >= block.timestamp ){
                        uint256 time = block.timestamp - UserStakingDetail[_userAddr].timeOfLastAmountstakede;
                   
                        
                        uint256 profit =  (UserDetail[_userAddr].userLastAmountInvested*(301*1e21)/(60*60*24*210))/100;

                        uint256 amt =  (profit*time)/1e21;
                       if(amt + totalIncomeWithoutRoi <= totalPercent){
                        return amt;
                       
                      } else if(amt + totalIncomeWithoutRoi > totalPercent){
                                uint256 amount = amt + totalIncomeWithoutRoi; 
                                uint256 AmtAfterExcluding = amount-totalPercent;
                                uint256 amountToReturn = amt - AmtAfterExcluding;
                                  if( amountToReturn >=0 ){
                                return amountToReturn;   
                                }else{
                                    return 0;
                                }              
                       }
                        

                    }  

    }

    function ClaimReward  () public {


        if(UserStakingDetail[msg.sender].timeofLastWithdrwal + 604800 < block.timestamp){

            uint256 data =  calculateWithdrawlAmount(msg.sender);
            
            uint256 profitDecider = calculateProfit(msg.sender);

            
        
            

            if( UserDetail[msg.sender].totalIncentiveEarned != 0){
                data =  data +  UserDetail[msg.sender].totalIncentiveEarned;
                  UserDetail[msg.sender].totalIncentiveEarned =0;
            }  

            if(UserDetail[msg.sender].amountEarnedByRef!=0){
                
                data = data + UserDetail[msg.sender].amountEarnedByRef;
                  UserDetail[msg.sender].amountEarnedByRef=0;
            }
            if( UserRoyalityDetail[msg.sender].usermanagerIncome!=0){
                    
                data = data +  UserRoyalityDetail[msg.sender].usermanagerIncome;
                    UserRoyalityDetail[msg.sender].usermanagerIncome=0;
            }
            if( UserRoyalityDetail[msg.sender].userSeniorManagerIncome!=0){
                    
                data = data +  UserRoyalityDetail[msg.sender].userSeniorManagerIncome;
                    UserRoyalityDetail[msg.sender].userSeniorManagerIncome=0;
            }     
            if( UserRoyalityDetail[msg.sender].dailyTopFiveIncome!=0){
                    
                data = data +  UserRoyalityDetail[msg.sender].dailyTopFiveIncome;
                    UserRoyalityDetail[msg.sender].dailyTopFiveIncome=0;
            }
            
    

                if( profitDecider !=0  && data > profitDecider   ){
         
            
                        data = data-profitDecider;
                    
                
            }
            


                Busd.transfer(msg.sender,data);
                Busd.transfer(TokenLiquidityWallet,(data*5)/100);
                emit claimedReward(data,msg.sender);

                UserStakingDetail[msg.sender].userLastTimeAmountTotalRewardClaimed += data;
                bool staking = IsRewardClaimPending(msg.sender);
                if(staking == false){
                    UserStakingDetail[msg.sender].isStakingActive=false;
                }
                UserDetail[msg.sender].Totalwithdrwal +=  data;
                    
                uint256 Incentive = data;

                address _referrer = UserDetail[msg.sender].refralAddress;


            for (uint8 i = 1; i < 11; i++) {
                if (_referrer != address(0)){
                    if(UserDetail[_referrer].totalDirects>= i){

                       
                    uint256 ProfitValueRemaining = checkProfitForincomeAddition(_referrer);

                        if( ProfitValueRemaining !=0 ){ 
                            if( ProfitValueRemaining >=  (Incentive*WithdrawPercentage[i])/100){
                                    UserDetail[_referrer].totalIncentiveEarned +=(Incentive*WithdrawPercentage[i])/100;
                    emit incentiveShared(i,(Incentive*WithdrawPercentage[i])/100,_referrer,msg.sender);

                            } else{
                                   
                                  uint256 extra =  ((Incentive*WithdrawPercentage[i])/100) - ProfitValueRemaining;
                          UserDetail[_referrer].totalIncentiveEarned += ((Incentive*WithdrawPercentage[i])/100)- extra;
                    emit incentiveShared(i,(Incentive*WithdrawPercentage[i])/100,_referrer,msg.sender);
                           

                            }

                        } 

                
                    }

                if ( UserDetail[_referrer].refralAddress !=address(0))
                    _referrer = UserDetail[_referrer].refralAddress;
                else break;
                }
            } 
            UserStakingDetail[msg.sender].timeOfLastAmountstakede =block.timestamp;
            UserStakingDetail[msg.sender].timeofLastWithdrwal= block.timestamp;

            }else{
                revert("7 days not completed from last Withdrwal");
            }
    }
    
                  

    function TransferAmountToOwnerWallet() public  onlyOwner {
        Busd.transfer(msg.sender,(address(this).balance));    
    }

    function claimAirdrop () public {
        if(UserDetail[msg.sender].airdropReward<=0 ){
            revert(" Claimable Amount Is Zero");
        }else{

        WZT.transfer(msg.sender, UserDetail[msg.sender].airdropReward);
        emit AirdropClaimed( msg.sender,UserDetail[msg.sender].airdropReward);
        UserDetail[msg.sender].airdropReward =0;
        }
    } 

    
    function calculateProfit (address userAddr) public  view returns(uint256) {

          uint256 data =  calculateWithdrawlAmount(userAddr);
          uint256   Profit =   UserDetail[msg.sender].totalIncentiveEarned + UserDetail[userAddr].amountEarnedByRef + data + UserStakingDetail[msg.sender].userLastTimeAmountTotalRewardClaimed  +  UserRoyalityDetail[userAddr].dailyTopFiveIncome + UserRoyalityDetail[userAddr].userSeniorManagerIncome + UserRoyalityDetail[userAddr].usermanagerIncome  ;
     
             if  ((UserDetail[userAddr].userLastAmountInvested*300)/100 >=Profit){
              
                return 0;
             }

          else if((UserDetail[userAddr].userLastAmountInvested*300)/100<Profit){
            
            uint256 currentProfit = Profit - (UserDetail[userAddr].userLastAmountInvested*300)/100;
                        return currentProfit;
          }



    }


        function  checkProfitForincomeAddition ( address  userAddr) public  view returns(uint256){
               bool staking = IsRewardClaimPending(userAddr);
                    if(staking  == false){
                        return 0;
                    }else{
                uint256 data =  calculateWithdrawlAmount(userAddr);
                uint256 Profit = UserDetail[userAddr].totalIncentiveEarned  + data + UserDetail[userAddr].amountEarnedByRef  + UserStakingDetail[userAddr].userLastTimeAmountTotalRewardClaimed  +  UserRoyalityDetail[userAddr].dailyTopFiveIncome + UserRoyalityDetail[userAddr].userSeniorManagerIncome + UserRoyalityDetail[userAddr].usermanagerIncome  ;
                
                    if (  (UserDetail[userAddr].userLastAmountInvested*300)/100 >= Profit){
                            uint256 profitRem = (UserDetail[userAddr].userLastAmountInvested*300)/100 - Profit;
                            return profitRem;
                    }

                    else{
                            return 0;
                    }
                    }
                    
        
        }





    function  IsRewardClaimPending(address useradrs ) public view returns(bool){

            if(UserStakingDetail[useradrs].userLastTimeAmountTotalRewardClaimed >=(UserDetail[useradrs].userLastAmountInvested*300)/100 ){
                    return false ;
            }else{
                return true;
            }

        }   

     function isLastInvestmentActive  (address userAddr ) public view returns (bool){


            uint256 data =  calculateWithdrawlAmount(userAddr);
            uint256 Profit = UserDetail[userAddr].totalIncentiveEarned +  UserRoyalityDetail[userAddr].dailyTopFiveIncome + UserRoyalityDetail[userAddr].userSeniorManagerIncome + UserRoyalityDetail[userAddr].usermanagerIncome + data + UserDetail[userAddr].amountEarnedByRef  + UserStakingDetail[userAddr].userLastTimeAmountTotalRewardClaimed ;

                if( Profit >= (UserDetail[userAddr].userLastAmountInvested*300)/100 ){
                            return false;
                }  else{
                    return true;
                }




     }
 
            
         function SetManagerIncome (address[] memory userAddr ,uint256 _managerIncome ) public onlyOperator {
             address[] memory  _userAddr = userAddr;
              for (uint8 i = 0; i < _userAddr.length; i++){
           uint256 ProfitValueRemaining = checkProfitForincomeAddition(_userAddr[i]);
                if(ProfitValueRemaining!=0){   
                    if(ProfitValueRemaining >= _managerIncome){
                       UserRoyalityDetail[_userAddr[i]].usermanagerIncome += _managerIncome;
                        emit royalityIncome(_userAddr[i],  _managerIncome, "_managerIncome");

                        }else{
                           uint256 extra =  _managerIncome - ProfitValueRemaining;
                           UserRoyalityDetail[_userAddr[i]].usermanagerIncome +=  _managerIncome - extra;
                           emit royalityIncome(_userAddr[i],  _managerIncome - extra, "_managerIncome");
                        }
                        }
              }
        } 


     function SetSenManagerIncome (address[] memory userAddr ,uint256 _seManagerIncome) public  onlyOperator   {
          address[] memory  _userAddr = userAddr;
              for (uint8 i = 0; i < _userAddr.length; i++){
           uint256 ProfitValueRemaining = checkProfitForincomeAddition(_userAddr[i]);
                if(ProfitValueRemaining!=0){
                    if(ProfitValueRemaining >= _seManagerIncome){
                       UserRoyalityDetail[_userAddr[i]].userSeniorManagerIncome += _seManagerIncome;
                       emit royalityIncome(_userAddr[i], _seManagerIncome , "_seManagerIncome");
                     }else{
                           uint256 extra =  _seManagerIncome - ProfitValueRemaining;
                           UserRoyalityDetail[_userAddr[i]].userSeniorManagerIncome +=  _seManagerIncome - extra;
                           emit royalityIncome(_userAddr[i],  _seManagerIncome - extra , "_seManagerIncome");

                        }
                }
                 }
        } 

        function SetdailyTopFiveReward (address[] memory userAddr , uint256 _dailyTopFiveReward) public onlyOperator {
             address[] memory  _userAddr = userAddr;
              for (uint8 i = 0; i < _userAddr.length; i++){
           uint256 ProfitValueRemaining = checkProfitForincomeAddition(_userAddr[i]);
            if(ProfitValueRemaining!=0){
                    if(ProfitValueRemaining >= _dailyTopFiveReward){
                       UserRoyalityDetail[_userAddr[i]].dailyTopFiveIncome += _dailyTopFiveReward;
                       emit royalityIncome(_userAddr[i],  _dailyTopFiveReward, "dailyTopFiveIncome");
                        }else{
                           uint256 extra =  _dailyTopFiveReward - ProfitValueRemaining;
                           UserRoyalityDetail[_userAddr[i]].dailyTopFiveIncome +=  _dailyTopFiveReward - extra;
                           emit royalityIncome(_userAddr[i],  _dailyTopFiveReward - extra, "dailyTopFiveIncome");

                        }
                        }
            }            
        } 


    function RescueBusdTokenToAdminWallet (uint256 Amt)public onlyOwner{
         Busd.transfer(owner,Amt);


    } 
     function RescueWalletZillaTokenToAdminWallet (uint256 Amt)public onlyOwner{
         WZT.transfer(owner,Amt);


    } 


 


}