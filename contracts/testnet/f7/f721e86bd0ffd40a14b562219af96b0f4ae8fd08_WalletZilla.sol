/**
 *Submitted for verification at BscScan.com on 2023-02-01
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


    uint256 public IdProvider = 4000;
    address public owner;
    address public WelfareWallet;
    uint256 public deployedTime;
    IERC20 public Busd;
    IERC20 public WZT;
  

    uint256 [] WithdrawPercentage = [7,8,9,10,11,12,13,14,15,16];
        
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

    struct userStakingDetail{

        uint256   expTime;
        bool isStakingActive;
        uint256 timeOfLastAmountstakede;
        uint256 timeofLastWithdrwal;
        uint256  userLastTimeAmountTotalRewardClaimed;
        


    }


    
    mapping(address => userDetail ) public UserDetail;
    mapping(address => userStakingDetail ) public UserStakingDetail;
    mapping(uint256 => bool) public IsExist;
    mapping(uint256 => address ) public IdToAddress;

    modifier onlyOwner() {
            require(msg.sender == owner);
            _;
        }

    constructor (address _owner , address _WelfareWallet){

        Busd = IERC20(0x7acB87EcFeF8DF169Aa9d531aA76e445D1d29604);
        WZT = IERC20(0xd94EB0a34458f29490CaA6d69fD298d499Cef25a);


        owner = _owner;
        WelfareWallet = _WelfareWallet;
        deployedTime = block.timestamp;

        IsExist[3999]=true;
        
        
    }

event Invest(uint256 AmountInv,address userAddress, uint256  userRefferdById , address RefByAddress);
event claimedReward (uint256 rewardClaimed,address userAddress); 
event incentiveShared (uint256 level ,uint256 amount , address addressOfuser );
event AirdropClaimed(address userAddr, uint256 amount);
event referalIncome(address userWoGotIncome,uint256 referalincome, address refealId  );

    function InvestBusd (  uint256 amtInvest , uint256 refBy)  public {
        // require( amtInvest >= 50*1e18, " please Increase Package Value !! Miniumum Value 50 busd ");
        // require( amtInvest <= 10000*1e18 ," exceeding maximium Purchase Value  !! maximum package vlaue is 10000 Busd");
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
            IdProvider++;
        }   else{
            // UserDetail[msg.sender].amountEarnedByRef=0;
            // UserDetail[msg.sender].totalIncentiveEarned=0;
            // UserStakingDetail[msg.sender].expTime=0;
            // UserStakingDetail[msg.sender].timeOfLastAmountstakede=0;
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

                 uint256 data = checkProfitForincomeAddition(IdToAddress[refBy]);

                 if( data !=0 ){ 
                
                 uint256 transferToTheRef = (amtInvest*5)/100;
                 if(data < transferToTheRef){
                        transferToTheRef =  data;
                        UserDetail[IdToAddress[refBy]].amountEarnedByRef += transferToTheRef;
                        emit referalIncome(IdToAddress[refBy],transferToTheRef,msg.sender);
                  }else{
                      UserDetail[IdToAddress[refBy]].amountEarnedByRef += transferToTheRef;
                      }
                  }
               
                Busd.transfer(owner,(amtInvest*5)/100);
                UserStakingDetail[msg.sender].timeOfLastAmountstakede = block.timestamp;
                UserStakingDetail[msg.sender].expTime = block.timestamp+210;
            
            uint256 totalUserWZTtoken = (amtInvest*1)/3;
            
            UserDetail[msg.sender].airdropReward += totalUserWZTtoken;
    
             emit Invest( amtInvest ,msg.sender, refBy ,IdToAddress[refBy]) ; 

    }

    
    function calculateWithdrawlAmount ( address _userAddr)  public  view returns(uint256) {

          uint256   totalIncomeWithoutRoi =   UserDetail[_userAddr].totalIncentiveEarned + UserDetail[_userAddr].amountEarnedByRef  + UserStakingDetail[_userAddr].userLastTimeAmountTotalRewardClaimed ;
            uint256 totalPercent =  (UserDetail[_userAddr].userLastAmountInvested*300)/100;

                if( UserStakingDetail[_userAddr].expTime < block.timestamp ){

                        uint256 time = UserStakingDetail[_userAddr].expTime - UserStakingDetail[_userAddr].timeOfLastAmountstakede;
                        // uint256 amt =  (16534391534391*time);
                        uint256 profit =  (UserDetail[_userAddr].userLastAmountInvested*1428571428571428600)/100;
                        uint256 amt =  (profit*time)/1e18;
                       if(amt + totalIncomeWithoutRoi <= totalPercent){
                        
                          return amt;

                       } else if(amt + totalIncomeWithoutRoi > totalPercent){
                                uint256 amount =amt + totalIncomeWithoutRoi; 
                                uint256 AmtAfterExcluding = amount-totalPercent;
                                uint256 amountToReturn = amt - AmtAfterExcluding;
                                return amountToReturn;              
                       }
        
                    }


                else if(  UserStakingDetail[_userAddr].expTime >= block.timestamp ){
                        uint256 time = block.timestamp - UserStakingDetail[_userAddr].timeOfLastAmountstakede;
                        // uint256 amt =  (16534391534391*time);
                        uint256 profit =  (UserDetail[_userAddr].userLastAmountInvested*1428571428571428600)/100;
                        uint256 amt =  (profit*time)/1e18;
                       if(amt + totalIncomeWithoutRoi <= totalPercent){
                        return amt;
                       
                      } else if(amt + totalIncomeWithoutRoi > totalPercent){
                                uint256 amount = amt + totalIncomeWithoutRoi; 
                                uint256 AmtAfterExcluding = amount-totalPercent;
                                uint256 amountToReturn = amt - AmtAfterExcluding;
                                return amountToReturn;              
                       }
                        

                    }  

    }

        function ClaimReward  () public {

            // if(UserStakingDetail[msg.sender].timeofLastWithdrwal+604800 > block.timestamp){

            if(UserStakingDetail[msg.sender].timeofLastWithdrwal + 60 < block.timestamp){

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
             
      

                 if( profitDecider !=0  && data > profitDecider   ){
                //  if( profitDecider !=0 ){
               
                         data = data-profitDecider;
                      
                  
                }
                


                    Busd.transfer(msg.sender,data);
                    emit claimedReward(data,msg.sender);

                    UserStakingDetail[msg.sender].userLastTimeAmountTotalRewardClaimed += data;
                    bool staking = IsRewardClaimPending(msg.sender);
                    if(staking == false){
                       UserStakingDetail[msg.sender].isStakingActive=false;
                    }
                    UserDetail[msg.sender].Totalwithdrwal +=  data;
                        
                    uint256 Incentive = (data*116)/100;

                    address _referrer = UserDetail[msg.sender].refralAddress;


                for (uint8 i = 0; i < 10; i++) {
                    if (_referrer != address(0)){
                        if(UserDetail[_referrer].totalDirects>= i){

                             uint256 profitdata = checkProfitForincomeAddition(_referrer);

                            if( profitdata !=0 ){ 
                                if( profitdata >=  (Incentive*WithdrawPercentage[i])/100){
                                     UserDetail[_referrer].totalIncentiveEarned +=(Incentive*WithdrawPercentage[i])/100;
                                } else{
                                     UserDetail[_referrer].totalIncentiveEarned += profitdata ;
                                    //  UserDetail[_referrer].totalIncentiveEarned +=(Incentive*WithdrawPercentage[i])/100;

                                }

                         }   


                        emit incentiveShared(i,(Incentive*WithdrawPercentage[i])/100,_referrer);
                    
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
          uint256   Profit =   UserDetail[msg.sender].totalIncentiveEarned + UserDetail[userAddr].amountEarnedByRef + data + UserStakingDetail[msg.sender].userLastTimeAmountTotalRewardClaimed ;

             if  ((UserDetail[userAddr].userLastAmountInvested*300)/100 >=Profit){
              
                return 0;
             }

          else if((UserDetail[userAddr].userLastAmountInvested*300)/100<Profit){
            
            uint256 currentProfit = Profit - (UserDetail[userAddr].userLastAmountInvested*300)/100;
                        return currentProfit;
          }



    }


            function  checkProfitForincomeAddition ( address  userAddr) public  view returns(uint256){
                
                    uint256 data =  calculateWithdrawlAmount(userAddr);
                    uint256 Profit = UserDetail[userAddr].totalIncentiveEarned + UserDetail[userAddr].amountEarnedByRef  + UserStakingDetail[userAddr].userLastTimeAmountTotalRewardClaimed ;

                      if ((UserDetail[userAddr].userLastAmountInvested*300)/100 > Profit){
                              uint256 profitRem = (UserDetail[userAddr].userLastAmountInvested*300)/100 - Profit;
                                return profitRem;
                        }

                        else{
                                return 0;
                        }
           
            }

// event check( uint256 );
            function totalTeamBusiness (address userAddress) public view returns(uint256) {
                    uint256 amt;
            
                 address _referrer = UserDetail[userAddress].refralAddress;

                for (uint8 i = 0; i < 10; i++) {
                    if (_referrer != address(0)){
                    //  emit check(UserDetail[_referrer].totalDeposite);
                     amt += UserDetail[_referrer].totalDeposite ;

                    if ( UserDetail[_referrer].refralAddress !=address(0))
                        _referrer = UserDetail[_referrer].refralAddress;
                    else break;
                    }
                }
                return amt;
                
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
            uint256 Profit = UserDetail[userAddr].totalIncentiveEarned + data + UserDetail[userAddr].amountEarnedByRef  + UserStakingDetail[userAddr].userLastTimeAmountTotalRewardClaimed ;

                if( Profit > (UserDetail[userAddr].userLastAmountInvested*300)/100 ){
                            return false;
                }  else{
                    return true;
                }




        }
             
            



}