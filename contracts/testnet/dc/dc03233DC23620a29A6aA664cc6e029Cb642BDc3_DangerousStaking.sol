/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DangerousStaking {

        IERC20 public token;
        address public owner;
       address marketingWallet = 0x9fc1aA5157Ee24801a6e27A09784170eB12C502d ;
       uint public stakingPeriod = 30 days;
       uint public immortalWithdrawingTimes;
       uint public silverPoolWithdrawingTime;
       uint public goldPoolWithdrawingTime;
       uint public diamondPoolWithdrawingTime;
       uint public crownPoolWithdrawingTime;
       uint public supremeInvestorwithdrawingTime;
       uint public superLeadershipWithdrawTime;

    event Messege(string value);

        constructor(address _token)  {
          owner=msg.sender;
          token= IERC20(_token);
          immortalWithdrawingTimes=block.timestamp+30 days;
          silverPoolWithdrawingTime=block.timestamp+30 days;
          goldPoolWithdrawingTime=block.timestamp+30 days;
          diamondPoolWithdrawingTime=block.timestamp+30 days;
          crownPoolWithdrawingTime=block.timestamp+30 days;
          superLeadershipWithdrawTime=block.timestamp+30 days;
          supremeInvestorwithdrawingTime=block.timestamp+30 days;

          users[owner].silverMember=true;
          users[owner].goldMember=true;
          users[owner].diamondMember=true;
          users[owner].crownMember=true;
          users[owner].superLeadershipMember=true;
          users[owner].supremeInvestorMember=true;
          users[owner].immortalMember=true;
          users[owner].stakings.treasureLevel=10;

          SilverMembers.push(owner);
          GoldMembers.push(owner);
          DiamondMembers.push(owner);
          CrownMembers.push(owner);
          superLeadershipMembers.push(owner);
          supremeInvestorMembers.push(owner);
          immortalMembers.push(owner);
          

        }
         
        uint[] public UgcTreasurePacks = [20, 50, 100, 200, 500, 1000];
        uint[] public UgcTreasureLevelPercentages = [10, 10, 5, 5, 4, 4, 3, 3, 2, 2];
        uint[] public StakingPlansMonthly = [5, 7, 10, 12, 15];
        uint[] public StakingLevelPercentages = [5, 5, 3, 3, 2, 2, 2, 1, 1, 1];

        
        //Pools
        uint public silverPool;
        uint public goldPool;
        uint public diamondPool;
        uint public crownPool;
        uint public ImmortalPool;
        uint public superLeadershipIncomePool;
        uint public supremeInvestorIncomePool;
       
    //    fourPercentMembers
        address[] SilverMembers; 
        address[] GoldMembers; 
        address[] DiamondMembers; 
        address[] CrownMembers; 

        //SuperLeaderShipMembers
        address[] superLeadershipMembers;
        address[] supremeInvestorMembers;
        address[] immortalMembers;

        struct Stakings{
             uint256 totalStaked;
            uint256 stakingStartTime;
            uint256 treasureLevel;
            uint256[] stakingTimes;
            uint256[] MonthlystakePlans;
            uint256[] trasureHoldings;
            uint256[] remainingTreasureHoldings;
            uint256[] trasureHoldingsDistribtutions;
            uint[6] treasures;
        }

        struct User{

            Stakings stakings;
            address upline;
            address[] directs;
            uint teamTurnover;
            bool silverMember;
            bool goldMember; 
            bool diamondMember;
            bool crownMember;
            bool superLeadershipMember;
            bool supremeInvestorMember;
            bool immortalMember;
        }
        
        mapping(address => User) public users;


        function buy(uint256 buyPlan , address _referer, uint _plan) public returns(bool) {
               
            User storage user = users[msg.sender];
            
            require(_plan<5,"Invalid Plan");
            require(msg.sender!=_referer,"You cannot reffer yourself!");


             if(msg.sender==owner){
            user.upline = address(0);
            }
            if(user.upline==address(0)&& msg.sender!=owner){
            (users[_referer].stakings.totalStaked==0 || _referer==address(0))?user.upline=owner:user.upline=_referer;
          
             users[user.upline].directs.push(msg.sender);
        }


        require(buyPlan<UgcTreasurePacks.length,"You entered invalid pack");
        if(buyPlan!=0){
        require(user.stakings.treasures[buyPlan]!=0,"You don't have enough treasure to buy this pack");
        }
        
        uint amount = UgcTreasurePacks[buyPlan]*1e18;
        token.transferFrom(msg.sender,address(this),amount);

                    if(user.stakings.treasures[buyPlan+1]==0){
                    user.stakings.treasureLevel += 2;
                    }
                    if(user.stakings.stakingStartTime==0){
                      user.stakings.stakingStartTime=block.timestamp;
                    }
                user.stakings.treasures[buyPlan+1] += 1;                    
                user.stakings.totalStaked+= amount;   
                user.stakings.stakingTimes.push(block.timestamp);
                user.stakings.trasureHoldings.push(amount);
                user.stakings.remainingTreasureHoldings.push(amount);
                UgcTreasureLevelDisdributions(amount ,msg.sender);   
                UgcStakingLevelDisdributions(amount , msg.sender);      
                PoolDistributions(amount);      
                    

            users[msg.sender].stakings.MonthlystakePlans.push(StakingPlansMonthly[_plan]);
            StateUpdation(amount);  

            return true;
        }



        function withdraw(uint StakingIndex)public  returns(bool){
            User storage user = users[msg.sender];
           require(block.timestamp-user.stakings.stakingTimes[StakingIndex]>stakingPeriod,"You cannot withdraw this staking");
           require(user.stakings.remainingTreasureHoldings[StakingIndex]>0,"You have'nt staking at this index");
           uint percentage = (user.stakings.MonthlystakePlans[StakingIndex]*user.stakings.trasureHoldings[StakingIndex])/100;


           if(user.stakings.remainingTreasureHoldings[StakingIndex]>percentage)
           {
               token.transfer(msg.sender,percentage);
               user.stakings.remainingTreasureHoldings[StakingIndex]-=percentage;
               user.stakings.stakingTimes[StakingIndex]=block.timestamp;
           }
           else
           {
               token.transfer(msg.sender,user.stakings.remainingTreasureHoldings[StakingIndex]);
               user.stakings.remainingTreasureHoldings[StakingIndex]=  user.stakings.remainingTreasureHoldings[user.stakings.remainingTreasureHoldings.length-1];
               user.stakings.trasureHoldings[StakingIndex]= user.stakings.trasureHoldings[user.stakings.trasureHoldings.length-1];
               user.stakings.stakingTimes[StakingIndex] = user.stakings.stakingTimes[user.stakings.stakingTimes.length-1];
               user.stakings.trasureHoldings.pop();
               user.stakings.remainingTreasureHoldings.pop();
               user.stakings.stakingTimes.pop();
               user.stakings.totalStaked-=user.stakings.trasureHoldings[StakingIndex];
           }
           return true;
        }

           
    function UgcTreasureLevelDisdributions(uint amount , address candidate) internal returns(bool){

        address upline = users[candidate].upline ;

        for (uint i ; i<=UgcTreasureLevelPercentages.length; i++){
            if(upline==address(0)){
                break;
            }    
            token.transfer(upline,((amount*UgcTreasureLevelPercentages[i])/100));
            upline = users[upline].upline;        
        }
        return true;
    }


    function UgcStakingLevelDisdributions(uint amount , address candidate) internal returns(bool){
        address upline = users[candidate].upline ;
        for (uint i ; i<=StakingLevelPercentages.length ; i++){
            if(upline==address(0)){
                break;
            }    

            if(users[upline].stakings.treasureLevel>=i && users[users[upline].upline].stakings.stakingStartTime>365 days){
                token.transfer(upline,(amount*StakingLevelPercentages[i])/100);
            }
            upline = users[upline].upline;        
        }
        return true;
    }
        
     function PoolDistributions(uint amount) internal returns(bool){
          silverPool+=(amount*1)/100;
          goldPool+=(amount*1)/100;
          diamondPool+=(amount*1)/100;
          crownPool+=(amount*1)/100;
          ImmortalPool+=(amount*1)/100;
          superLeadershipIncomePool+=(amount*1)/100;
          supremeInvestorIncomePool+=(amount*1)/100;
          token.transfer(marketingWallet,(amount*1)/100);
          return true;

    }

    function MonthlySilverPoolWithDraw() public returns(bool){
         User storage user = users[msg.sender];
        require(user.silverMember==true,"You are not a part of monthly plans");
        require (block.timestamp>=silverPoolWithdrawingTime,"Monthly Reward time not reached");

         for(uint i; i<SilverMembers.length;i++){
            if(SilverMembers[i]!=address(0))
            {
                token.transfer(SilverMembers[i], silverPool/SilverMembers.length);
            }
         }
         silverPoolWithdrawingTime= block.timestamp+30 days;
         silverPool=0;
         return true;
    }

    function MonthlyGoldPoolWithDraw() public returns(bool){
         User storage user = users[msg.sender];
        require(user.goldMember==true,"You are not a part of monthly plans");
        require (block.timestamp>=goldPoolWithdrawingTime,"Monthly Reward time not reached");

         for(uint i; i<GoldMembers.length;i++){
            if(GoldMembers[i]!=address(0))
            {
                token.transfer(GoldMembers[i], goldPool/GoldMembers.length);
            }
         }
         goldPoolWithdrawingTime= block.timestamp+30 days;
         goldPool=0;
         return true;


    }

        function MonthlyDiamondPoolWithDraw() public returns(bool){
         User storage user = users[msg.sender];
        require(user.diamondMember==true,"You are not a part of monthly plans");
        require (block.timestamp>diamondPoolWithdrawingTime,"Monthly Reward time not reached");

         for(uint i; i<DiamondMembers.length;i++){
            if(DiamondMembers[i]!=address(0))
            {
                token.transfer(DiamondMembers[i], diamondPool/DiamondMembers.length);
            }
         }
         diamondPoolWithdrawingTime= block.timestamp+30 days;
         diamondPool=0;
         return true;


    }
    function MonthlyCrownPoolWithDraw() public returns(bool){
         User storage user = users[msg.sender];
        require(user.crownMember==true,"You are not a part of monthly plans");
        require (block.timestamp>=crownPoolWithdrawingTime,"Monthly Reward time not reached");

         for(uint i; i<CrownMembers.length;i++){
            if(CrownMembers[i]!=address(0))
            {
                token.transfer(CrownMembers[i], crownPool/CrownMembers.length);
            }
         }
         crownPoolWithdrawingTime= block.timestamp+30 days;
         crownPool=0;
         return true;

    }

     
 

        function SuperLeaderShipReward() public returns(bool)
    {
        User storage user = users[msg.sender];
        require(user.superLeadershipMember,"You are not a part of monthly plans");
        require (block.timestamp>=superLeadershipWithdrawTime,"Monthly Reward time not reached");
        
        for(uint i; i<superLeadershipMembers.length;i++){    
            token.transfer(superLeadershipMembers[i],superLeadershipIncomePool/superLeadershipMembers.length);
        }
       superLeadershipWithdrawTime =0;
        superLeadershipWithdrawTime=block.timestamp+30 days;
        return true;

    }

        function supremeInvestorWithdraw() public returns(bool)
    {
        User storage user = users[msg.sender];
        require(user.superLeadershipMember,"You are not a part of monthly plans");
        require (block.timestamp>=supremeInvestorwithdrawingTime,"Monthly Reward time not reached");
        
        for(uint i; i<supremeInvestorMembers.length;i++){    
            token.transfer(supremeInvestorMembers[i],superLeadershipIncomePool/superLeadershipMembers.length);
        }
       supremeInvestorwithdrawingTime =0;
        supremeInvestorwithdrawingTime=block.timestamp+30 days;
        return true;

    }


    function immortalPoolWithdraw() public returns(bool)
    {
        User storage user = users[msg.sender];
        require(user.immortalMember,"You are not a part of monthly plans");
        require (block.timestamp>=immortalWithdrawingTimes,"Monthly Reward time not reached");
        
        for(uint i; i<immortalMembers.length;i++){    
            token.transfer(immortalMembers[i],ImmortalPool/immortalMembers.length);
        }
       ImmortalPool =0;
        immortalWithdrawingTimes=block.timestamp+30 days;
        return true;

    }



    function StateUpdation(uint tokenAmount) internal returns(bool){
        User storage user = users[msg.sender];
        
        users[user.upline].teamTurnover+=tokenAmount;


        if(users[user.upline].stakings.totalStaked>=500 || users[user.upline].stakings.totalStaked>=1000)
        {
            superLeadershipMembers.push(user.upline);
            user.superLeadershipMember=true;

        }


         if( users[user.upline].directs.length>=10 &&users[user.upline].teamTurnover>10000){
            SilverMembers.push(user.upline);
            users[user.upline].silverMember=true;
        }
         if(users[user.upline].directs.length>=20 &&users[user.upline].teamTurnover>100000)
        {
            GoldMembers.push(user.upline);
            users[user.upline].goldMember=true;
        }
          if(users[user.upline].directs.length>=30 &&users[user.upline].teamTurnover>1000000)
        {
            DiamondMembers.push(user.upline);
            users[user.upline].diamondMember=true;
        }
         if(users[user.upline].directs.length>=5 && users[user.upline].teamTurnover>10000000)
        {
            CrownMembers.push(user.upline);
            users[user.upline].crownMember=true;
        }
        if(user.stakings.totalStaked>=7000*1e18 && block.timestamp-user.stakings.stakingStartTime>365 days)
        {
            supremeInvestorMembers.push(msg.sender);
            user.supremeInvestorMember= true;
        }

        for(uint i ;i<user.stakings.trasureHoldings.length;i++)
        {
          if(user.stakings.trasureHoldings[i]==1000 && user.stakings.stakingTimes[i]>365 days){
                immortalMembers.push(msg.sender);
                user.immortalMember=true;
          }
          
        }
    return true;
    }

      

}