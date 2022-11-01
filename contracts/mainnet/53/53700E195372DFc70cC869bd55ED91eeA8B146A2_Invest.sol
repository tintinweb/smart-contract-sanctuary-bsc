/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface USDT{
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) ;
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    }
contract Invest
    {
       
        address public owner;

        uint public totalusers;




        uint public plan2_min_Stake_amount=10000000000000000000000;  



        uint public second_investmentPeriod=30 days;

        
        uint public totalbusiness; 
        uint rew_till_done;
        mapping(uint=>address) public All_investors;

        struct allInvestments{

            uint investedAmount;
            uint withdrawnTime;
            uint DepositTime;
            uint investmentNum;
            uint unstakeTime;
            bool unstake;
           uint  expire_Time;
           uint claimable_reward;



        }

        struct allWithdrawals{

            uint withdrawn_Time;
            uint amount;
            uint total_withdraws;
            uint total_withdraw_amount;

        }

        struct ref_data{
            uint reward;
            uint count;
        }

        struct Admin_Data
        {

            address investor;
            uint totalInvestment;
            uint reward;
            uint noOfInvestment;
            uint totalWithdraw_reward;
            uint Total_referrals;
        }

        struct Data
        {

            mapping(uint=>allInvestments) investment;
            mapping(uint=>mapping(uint=>allWithdrawals)) withdrawal;
  
            uint reward;
            uint noOfInvestment;
            uint totalInvestment;
            uint totalWithdraw_reward;
            bool investBefore;
            uint stakeTime;
        }
  
        address public usdt_address=0xbAA7b15748898Ee5cdb9D21Ab66aadd0B5eF512a;


        mapping(address=>Data) public plan1;




      


        constructor(){
            
            owner=msg.sender;              //here we are setting the owner of this contract

        }

       


        function Stake(uint _investedamount) external returns(bool success)
        {
            // _investedamount=_investedamount*10**18;

 
                require(_investedamount >=  plan2_min_Stake_amount,"value is not greater than 10000 and less than 5000000");     //ensuring that investment amount is not less than zero
                require(USDT(usdt_address).balanceOf(msg.sender)>=_investedamount,"You dont have enough USDT");
                require(USDT(usdt_address).allowance(msg.sender,address(this))>=_investedamount,"Kindly appprove the USDT");

                if(plan1[msg.sender].investBefore == false)
                { 
                    All_investors[totalusers]=msg.sender;

                    totalusers++;                                     
                }

                uint num = plan1[msg.sender].noOfInvestment;
                plan1[msg.sender].investment[num].investedAmount =_investedamount;
                plan1[msg.sender].investment[num].DepositTime=block.timestamp;
                plan1[msg.sender].investment[num].expire_Time=block.timestamp + second_investmentPeriod ;  // 300 days
                plan1[msg.sender].investment[num].investmentNum=num;
                plan1[msg.sender].totalInvestment+=_investedamount;
                plan1[msg.sender].noOfInvestment++;
                totalbusiness+=_investedamount;
                USDT(usdt_address).transferFrom(msg.sender,address(this),_investedamount);


                plan1[msg.sender].investBefore=true;
            
           
           

            return true;
            
        }

        
       
        function getReward(uint _inv) view public returns(uint)
        { 

            uint totalReward;
            uint depTime;
            uint rew;

                // uint temp = plan1[msg.sender].noOfInvestment;
                uint i=_inv;
  
                    if(!plan1[msg.sender].investment[i].unstake)
                    {
                        depTime =block.timestamp - plan1[msg.sender].investment[i].DepositTime;
                        
                    }
                    else
                    {
                        
                        depTime =plan1[msg.sender].investment[i].unstakeTime - plan1[msg.sender].investment[i].DepositTime;
                    }
                    bool execuation=true;
                    depTime=depTime/86400; //1 day
                    uint curr_inv = plan1[msg.sender].investment[i].investedAmount;
                    uint count=0;
                    uint month=0;
                    uint total_withdraw;
                    if(depTime>0)
                    {
                        for(uint j=0;j<depTime;j++)
                        {
                            if(j>=360)
                            {
                                break;
                            }
                            if(count>=30)
                            {   
                                month+=30;
                                curr_inv+=totalReward;
                                uint temp1= plan1[msg.sender].withdrawal[i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    if(month == plan1[msg.sender].withdrawal[i][k].withdrawn_Time)
                                    {
                                       curr_inv-= plan1[msg.sender].withdrawal[i][k].amount; 
                                       total_withdraw+=plan1[msg.sender].withdrawal[i][k].amount;
                                    }
                                }
                                execuation=true;
                                count=0;

                            }
                        
                            if(execuation)
                            {
                                rew  = ((curr_inv)*500000000000000000)/100000000000000000000;
                                execuation=false;

                            }
                                

                            totalReward += rew;  
                            count++;
                            
            
                        }
                    }

                
                totalReward -= plan1[msg.sender].withdrawal[i][i].total_withdraw_amount;


            return totalReward;
        }


        function withdrawReward(uint _invNum, uint _amount) external returns (uint success)
        {


                require(plan1[msg.sender].investment[_invNum].investedAmount>0,"you dont have investment to withdrawn");
                require(!plan1[msg.sender].investment[_invNum].unstake ,"you have withdrawn");
                uint depTime = block.timestamp - plan1[msg.sender].investment[_invNum].DepositTime;

                require( timeLeft(_invNum,msg.sender)==0,"time is not over");

                uint Total_reward = getReward(_invNum);
                require(Total_reward>0,"you dont have rewards to withdrawn");         
                require(Total_reward>=_amount,"hello 1");
                uint total_withdrawals=plan1[msg.sender].withdrawal[_invNum][_invNum].total_withdraws;
                plan1[msg.sender].withdrawal[_invNum][total_withdrawals].amount=_amount;
                depTime =block.timestamp - plan1[msg.sender].investment[_invNum].DepositTime;

                depTime=depTime/86400; //1 day
                plan1[msg.sender].withdrawal[_invNum][total_withdrawals].withdrawn_Time=depTime;

                USDT(usdt_address).transfer(msg.sender,_amount);  
                plan1[msg.sender].withdrawal[_invNum][_invNum].total_withdraws++;                   
                plan1[msg.sender].totalWithdraw_reward+=_amount;
                plan1[msg.sender].withdrawal[_invNum][_invNum].total_withdraw_amount+=_amount;

          
           

            return depTime;

        }

        

        function withdrawReward_inside(address investor,uint _invNum, uint _amount) internal returns (bool success)
        {

   
                // require(plan1[investor].investment[_invNum].investedAmount>0,"you dont have investment to withdrawn");
                // require(!plan1[investor].investment[_invNum].unstake ,"you have withdrawn");
                uint depTime = block.timestamp - plan1[investor].investment[_invNum].DepositTime;

                // require( timeLeft(_invNum,investor)==0,"time is not over");

                // uint Total_reward = getReward(_invNum);
                // require(Total_reward>0,"you dont have rewards to withdrawn");         
                // require(Total_reward>=_amount,"hello 1");
                uint total_withdrawals=plan1[investor].withdrawal[_invNum][_invNum].total_withdraws;
                plan1[investor].withdrawal[_invNum][total_withdrawals].amount=_amount;
                depTime =block.timestamp - plan1[investor].investment[_invNum].DepositTime;

                depTime=depTime/86400; //1 day
                plan1[investor].withdrawal[_invNum][total_withdrawals].withdrawn_Time=depTime;

                USDT(usdt_address).transfer(investor,_amount);  
                plan1[investor].withdrawal[_invNum][_invNum].total_withdraws++;                   
                plan1[investor].totalWithdraw_reward+=_amount;
                plan1[investor].withdrawal[_invNum][_invNum].total_withdraw_amount+=_amount;

            

            return true;

        }







  

        function unStake(uint num) external  returns (bool success)
        {


                require(plan1[msg.sender].investment[num].investedAmount>0,"you dont have investment to withdrawn");             //checking that he invested any amount or not
                require(!plan1[msg.sender].investment[num].unstake ,"you have withdrawn");

                
                require( timeLeft(num,msg.sender)==0,"time is not over");

                uint amount=plan1[msg.sender].investment[num].investedAmount;

    
        
                USDT(usdt_address).transfer(msg.sender,amount);
                uint Total_reward=getReward(num);
                withdrawReward_inside(msg.sender,num,Total_reward);     
            
                plan1[msg.sender].investment[num].unstake =true;    
                plan1[msg.sender].investment[num].unstakeTime =block.timestamp;    

                plan1[msg.sender].totalInvestment-=plan1[msg.sender].investment[num].investedAmount;
                plan1[msg.sender].investment[num].investedAmount=0;           

                return true;

   
            
            
    

        }


        function getAllinvestments() public view returns (allInvestments[] memory) 
        { 
           
       
            uint num = plan1[msg.sender].noOfInvestment;
            uint temp;
            uint currentIndex;
            
            for(uint i=0;i<num;i++)
            {
            if( plan1[msg.sender].investment[i].investedAmount > 0  ){
                temp++;
            }

            }
        
            allInvestments[] memory Invested =  new allInvestments[](temp) ;

            for(uint i=0;i<num;i++)
            {
            if( plan1[msg.sender].investment[i].investedAmount > 0 ){
                Invested[currentIndex]=plan1[msg.sender].investment[i];
                // Invested[currentIndex].expire_Time=0;
                // Invested[currentIndex].claimable_reward=0;
                Invested[currentIndex].expire_Time=timeLeft(plan1[msg.sender].investment[i].investmentNum,msg.sender);
                Invested[currentIndex].claimable_reward=getReward(plan1[msg.sender].investment[i].investmentNum);

                currentIndex++;
            }

            }
            return Invested;

           
          
           
            
        }


        function transferOwnership(address _owner)  public
        {
            require(msg.sender==owner,"only Owner can call this function");
            owner = _owner;
        }

        function total_withdraw_reaward() view public returns(uint){


            uint Temp = plan1[msg.sender].totalWithdraw_reward;

            return Temp;
            

        }
        function get_currTime() public view returns(uint)
        {
            return block.timestamp;
        }
        function withdraw_investments()  public
        {
            require(msg.sender==owner,"only Owner can call this function");
            uint bal = USDT(usdt_address).balanceOf(address(this)); 

            USDT(usdt_address).transfer(msg.sender,bal); 
        }
        
        function timeLeft(uint inv,address investor) public view returns(uint)
        {
            uint totalReward;
            uint depTime;
            uint rew;

                uint i=inv;
  
                    if(!plan1[investor].investment[i].unstake) 
                    {

                        depTime =block.timestamp - plan1[investor].investment[i].DepositTime;
                        
                    }
                    else
                    {
                        
                        depTime =plan1[investor].investment[i].unstakeTime - plan1[investor].investment[i].DepositTime;
                    }
                    bool execuation=true;
                    depTime=depTime/86400; //1 day
                    uint curr_inv = plan1[investor].investment[i].investedAmount;
                    uint count=30;
                    
                    if(depTime>0)
                    {
                        for(uint j=0;j<depTime;j++)
                        {
                            if(j>=86400)
                            {
                                count=0;
                                break;
                            }
                            if(count==0)
                            {   
                              
                                curr_inv+=totalReward;
                                execuation=true;
                                count=31;

                            }
                        
                            if(execuation)
                            {
                                rew  = ((curr_inv)*500000000000000000)/100000000000000000000;
                                execuation=false;

                            }
                                

                            totalReward += rew;  
                            count--;
                            
            
                        }
                    }

                

            
            

       
           

            return count;
        
        }

        function get_withdraw_amount(uint i) public view returns(uint)
        {
           uint total=get_Total_withdraws(i,i);
           uint amount;
           for(uint j=0;j<total;j++)
           {
             amount=plan1[msg.sender].withdrawal[i][j].amount;
           }
            return amount;
        }
        function get_withdraw_Time(uint i,uint j) public view returns(uint)        {
            return plan1[msg.sender].withdrawal[i][j].withdrawn_Time;
        }
        function get_Total_withdraws(uint i,uint j) public view returns(uint)
        {
            return plan1[msg.sender].withdrawal[i][j].total_withdraws;
        }










    }