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

    // import "package_data.sol";

    contract Invest 
    {
       
        address public owner;

        uint public bronze_amount=100000000000000000000;  
        uint public silver_amount=200000000000000000000;
        uint public gold_amount=  300000000000000000000;


        uint public bronze_token=10000000000000000000000;
        uint public silver_token=20000000000000000000000;
        uint public gold_token=30000000000000000000000;
        
        uint time_divider=86400;




        // uint public second_investmentPeriod=30 days;
  

        


        struct allInvestments{

            uint investedAmount;
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



        struct Data
        {

            mapping(uint=>allInvestments) investment;
            mapping(uint=>mapping(uint=>mapping(uint=>allWithdrawals))) withdrawal;
            uint noOfInvestment;
            // uint totalInvestment;
            // uint totalWithdraw_reward;
        }
  
        address public usdt_address=0x55d398326f99059fF775485246999027B3197955;
        address public token_address=0x58f26DC61943698B565473057FADa470f16f6722;

        uint public investmentPeriod=360 days;


        mapping(address=>Data) public plan1;
        mapping(address=>Data) public plan2;
        mapping(address=>Data) public plan3;



      


        constructor(){
            
            owner=msg.sender;              //here we are setting the owner of this contract

        }

       


        function Stake(uint package) external returns(bool success)
        {
            require(package>=1 && package <=3,"wrong pack");


            if(package==1)
            {
                require(USDT(usdt_address).balanceOf(msg.sender)>=bronze_amount);
                require(USDT(usdt_address).allowance(msg.sender,address(this))>=bronze_amount);


                uint num = plan1[msg.sender].noOfInvestment;
                plan1[msg.sender].investment[num].investedAmount =bronze_token;
                plan1[msg.sender].investment[num].DepositTime=block.timestamp;
                plan1[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod;  // 300 days
                plan1[msg.sender].investment[num].investmentNum=num;
                // plan1[msg.sender].totalInvestment+=bronze_token;
                plan1[msg.sender].noOfInvestment++;
                USDT(usdt_address).transferFrom(msg.sender,address(this),bronze_amount);
                // USDT(token_address).transfer(msg.sender,bronze_token);
            }
            else if( package==2)
            {
                require(USDT(usdt_address).balanceOf(msg.sender)>=silver_amount);
                require(USDT(usdt_address).allowance(msg.sender,address(this))>=silver_amount);



                uint num = plan2[msg.sender].noOfInvestment;
                plan2[msg.sender].investment[num].investedAmount =silver_token;
                plan2[msg.sender].investment[num].DepositTime=block.timestamp;
                plan2[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod ;  // 300 days
                plan2[msg.sender].investment[num].investmentNum=num;
                // plan2[msg.sender].totalInvestment+=silver_token;
                plan2[msg.sender].noOfInvestment++;
                USDT(usdt_address).transferFrom(msg.sender,address(this),silver_amount);
                // USDT(token_address).transfer(msg.sender,silver_token);
            }
            else if(package==3)
            {
                require(USDT(usdt_address).balanceOf(msg.sender)>=gold_amount);
                require(USDT(usdt_address).allowance(msg.sender,address(this))>=gold_amount);

  

                uint num = plan3[msg.sender].noOfInvestment;
                plan3[msg.sender].investment[num].investedAmount =gold_token;
                plan3[msg.sender].investment[num].DepositTime=block.timestamp;
                plan3[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod ;  // 300 days
                plan3[msg.sender].investment[num].investmentNum=num;
                // plan3[msg.sender].totalInvestment+=gold_token;
                plan3[msg.sender].noOfInvestment++;
                USDT(usdt_address).transferFrom(msg.sender,address(this),gold_amount);
                // USDT(token_address).transfer(msg.sender,gold_token);
            }
           

            return true;
            
        }

        
       
        function getReward(uint _package,uint i) view public returns(uint)
        { 

            // require(package>=1 && package <=3,"please select a right package");
            uint totalReward;
            uint depTime;
            uint rew;
            uint count=0;
            uint month=0;
            uint total_withdraw;
            bool execuation=true;
            uint curr_inv;
            // uint i=_inv;
            uint package=_package;
            if(package==1)
            {
  
                if(!plan1[msg.sender].investment[i].unstake)
                {
                    depTime =block.timestamp - plan1[msg.sender].investment[i].DepositTime;
                    
                }
                else
                {
                    
                    depTime =plan1[msg.sender].investment[i].unstakeTime - plan1[msg.sender].investment[i].DepositTime;
                }
                depTime=depTime/time_divider; //1 day
                 curr_inv = plan1[msg.sender].investment[i].investedAmount;
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
                            uint temp1= plan1[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    if(month == plan1[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    {
                                       curr_inv-= plan1[msg.sender].withdrawal[package][i][k].amount; 
                                       total_withdraw+=plan1[msg.sender].withdrawal[package][i][k].amount;
                                    }
                                }
                            execuation=true;
                            count=0;

                        }
                    
                        if(execuation)
                        {
                            rew  = ((curr_inv)*266666666700000000)/100000000000000000000;
                            execuation=false;

                        }
                            

                        totalReward += rew;  
                        count++;
                        
        
                    }
                }

                
                totalReward -= plan1[msg.sender].withdrawal[package][i][i].total_withdraw_amount;

            }
            else if(package==2)
            {
  
                if(!plan2[msg.sender].investment[i].unstake)
                {
                    depTime =block.timestamp - plan2[msg.sender].investment[i].DepositTime;
                    
                }
                else
                {
                    
                    depTime =plan2[msg.sender].investment[i].unstakeTime - plan2[msg.sender].investment[i].DepositTime;
                }
                // bool execuation=true;
                depTime=depTime/time_divider; //1 day
                 curr_inv = plan2[msg.sender].investment[i].investedAmount;

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
                            uint temp1= plan2[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    if(month == plan2[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    {
                                       curr_inv-= plan2[msg.sender].withdrawal[package][i][k].amount; 
                                       total_withdraw+=plan2[msg.sender].withdrawal[package][i][k].amount;
                                    }
                                }
                            execuation=true;
                            count=0;

                        }
                    
                        if(execuation)
                        {
                            rew  = ((curr_inv)*400000000000000000)/100000000000000000000;
                            execuation=false;

                        }
                            

                        totalReward += rew;  
                        count++;
                        
        
                    }
                }

                 totalReward -= plan2[msg.sender].withdrawal[package][i][i].total_withdraw_amount;


            }
            else if(package==3)
            {
  
                    if(!plan3[msg.sender].investment[i].unstake)
                    {
                        depTime =block.timestamp - plan3[msg.sender].investment[i].DepositTime;
                        
                    }
                    else
                    {
                        
                        depTime =plan3[msg.sender].investment[i].unstakeTime - plan3[msg.sender].investment[i].DepositTime;
                    }
                    // bool execuation=true;
                    depTime=depTime/time_divider; //1 day
                     curr_inv = plan3[msg.sender].investment[i].investedAmount;

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
                                uint temp1= plan3[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    if(month == plan3[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    {
                                       curr_inv-= plan3[msg.sender].withdrawal[package][i][k].amount; 
                                       total_withdraw+=plan3[msg.sender].withdrawal[package][i][k].amount;
                                    }
                                }
                                execuation=true;
                                count=0;

                            }
                        
                            if(execuation)
                            {
                                rew  = ((curr_inv)*533333333300000000)/100000000000000000000;
                                execuation=false;

                            }
                                

                            totalReward += rew;  
                            count++;
                            
            
                        }
                    }

                    totalReward -= plan3[msg.sender].withdrawal[package][i][i].total_withdraw_amount;


            }


       
           

            return totalReward;
        }

        

        function withdrawReward(address investor,uint package ,uint _invNum, uint _amount) public returns (bool success)
        {
            require(package>=1 && package <=3);
            uint depTime;

           
            if(package==1)
            {
                require(plan1[investor].investment[_invNum].investedAmount>0);           
                require(!plan1[investor].investment[_invNum].unstake);
                depTime = block.timestamp - plan1[investor].investment[_invNum].DepositTime;
                require( timeLeft(1,_invNum,investor)==0);


                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);

            }
            else if(package==2)
            {
                require(plan2[investor].investment[_invNum].investedAmount>0);           
                require(!plan2[investor].investment[_invNum].unstake);
                depTime = block.timestamp - plan2[investor].investment[_invNum].DepositTime;
                require( timeLeft(2,_invNum,investor)==0);


                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);


            }
            else if(package==3)
            {

                require(plan3[investor].investment[_invNum].investedAmount>0);           
                require(!plan3[investor].investment[_invNum].unstake );
                depTime = block.timestamp - plan3[investor].investment[_invNum].DepositTime;
                require( timeLeft(3,_invNum,investor)==0);

                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);


            }


            return true;

        }







  

            function unStake(uint package,uint num) external  returns (bool success)
            {
                require(package>=1 && package <=3,"wrong pack");
                uint depTime;
  

                if(package==1)
                {

                    require(plan1[msg.sender].investment[num].investedAmount>0);           
                    require(!plan1[msg.sender].investment[num].unstake );
                    depTime = block.timestamp - plan1[msg.sender].investment[num].DepositTime;
                    require( timeLeft(1,num,msg.sender)==0);

                    uint amount=plan1[msg.sender].investment[num].investedAmount;

                    uint Total_reward=getReward(package, num);

            
                    USDT(token_address).transfer(msg.sender,amount);
                    // withdrawReward(msg.sender,package,num,Total_reward);     
                    safe_withdraw( package, num, msg.sender, Total_reward);

                    plan1[msg.sender].investment[num].unstake =true;    
                    plan1[msg.sender].investment[num].unstakeTime =block.timestamp;    

                    // plan1[msg.sender].totalInvestment-=plan1[msg.sender].investment[num].investedAmount;
                    plan1[msg.sender].investment[num].investedAmount=0;         

                    return true;

                }
                else if(package==2)
                {
                    require(plan2[msg.sender].investment[num].investedAmount>0);           
                    require(!plan2[msg.sender].investment[num].unstake);
                    depTime = block.timestamp - plan2[msg.sender].investment[num].DepositTime;
                    require( timeLeft(2,num,msg.sender)==0);


                    uint amount=plan2[msg.sender].investment[num].investedAmount;

                    uint Total_reward=getReward(package, num);

            
                    USDT(token_address).transfer(msg.sender,amount);
                    // withdrawReward(msg.sender,package,num,Total_reward);     
                    safe_withdraw( package, num, msg.sender, Total_reward);

                    plan2[msg.sender].investment[num].unstake =true;    
                    plan2[msg.sender].investment[num].unstakeTime =block.timestamp;    

                    // plan2[msg.sender].totalInvestment-=plan2[msg.sender].investment[num].investedAmount;
                    plan2[msg.sender].investment[num].investedAmount=0;         

                    return true;

                }
                else if(package ==3)
                {
                    require(plan3[msg.sender].investment[num].investedAmount>0);           
                    require(!plan3[msg.sender].investment[num].unstake);
                    depTime = block.timestamp - plan3[msg.sender].investment[num].DepositTime;
                    require( timeLeft(3,num,msg.sender)==0,"time is not over");
  

                    uint amount=plan3[msg.sender].investment[num].investedAmount;

                    uint Total_reward=getReward(package, num);

            
                    USDT(token_address).transfer(msg.sender,amount);
                    // withdrawReward(msg.sender,package,num,Total_reward);     
                    safe_withdraw( package, num, msg.sender, Total_reward);

                    plan3[msg.sender].investment[num].unstake =true;    
                    plan3[msg.sender].investment[num].unstakeTime =block.timestamp;    

                    // plan3[msg.sender].totalInvestment-=plan3[msg.sender].investment[num].investedAmount;
                    plan3[msg.sender].investment[num].investedAmount=0;         

                    return true;

                }
                
        

            }


        function getAllinvestments(uint package) public view returns (allInvestments[] memory) 
        { 
                uint temp;
                uint currentIndex;
           if(package==1)
           {
                uint num = plan1[msg.sender].noOfInvestment;

                
                for(uint i=0;i<num;i++)
                {
                if( plan1[msg.sender].investment[i].investedAmount > 0  ){
                    temp++;
                }

                }
            
                allInvestments[] memory Invested =  new allInvestments[](temp) ;

                for(uint i=0;i<num;i++)
                {
                if( plan1[msg.sender].investment[i].investedAmount > 0 )
                {
                    Invested[currentIndex]=plan1[msg.sender].investment[i];
                    Invested[currentIndex].expire_Time=timeLeft(1,plan1[msg.sender].investment[i].investmentNum,msg.sender);
                    Invested[currentIndex].claimable_reward=getReward(1,plan1[msg.sender].investment[i].investmentNum);
                    currentIndex++;
                }

                }
                return Invested;

           }
           else if(package==2)
           {
                uint num = plan2[msg.sender].noOfInvestment;

                
                for(uint i=0;i<num;i++)
                {
                if( plan2[msg.sender].investment[i].investedAmount > 0  ){
                    temp++;
                }

                }
            
                allInvestments[] memory Invested =  new allInvestments[](temp) ;

                for(uint i=0;i<num;i++)
                {
                if( plan2[msg.sender].investment[i].investedAmount > 0 ){
                    Invested[currentIndex]=plan2[msg.sender].investment[i];
                    Invested[currentIndex].expire_Time=timeLeft(2,plan2[msg.sender].investment[i].investmentNum,msg.sender);
                    Invested[currentIndex].claimable_reward=getReward(2,plan2[msg.sender].investment[i].investmentNum);
                    currentIndex++;
                }

                }
                return Invested;

           }
           else if(package==3)
           {
                uint num = plan3[msg.sender].noOfInvestment;

                
                for(uint i=0;i<num;i++)
                {
                if( plan3[msg.sender].investment[i].investedAmount > 0  ){
                    temp++;
                }

                }
            
                allInvestments[] memory Invested =  new allInvestments[](temp) ;

                for(uint i=0;i<num;i++)
                {
                    if( plan3[msg.sender].investment[i].investedAmount > 0 )
                    {
                        Invested[currentIndex]=plan3[msg.sender].investment[i];
                        Invested[currentIndex].expire_Time=timeLeft(3,plan3[msg.sender].investment[i].investmentNum,msg.sender);
                        Invested[currentIndex].claimable_reward=getReward(3,plan3[msg.sender].investment[i].investmentNum);
                        currentIndex++;
                    }

                }
                return Invested;
            }
           
            
        }

        function timeLeft(uint package, uint inv,address investor) public view returns(uint)
        {
            require(package>=1 && package <=3,"wrong pack");

            uint depTime;
            uint count=360;       
            uint i=inv;
            bool execuation=true;

            if(package==1)
            {
                if(!plan1[investor].investment[i].unstake)
                {
                    depTime =block.timestamp - plan1[investor].investment[i].DepositTime;
                    
                }
                else
                {
                    
                    depTime =plan1[investor].investment[i].unstakeTime - plan1[investor].investment[i].DepositTime;
                }
                depTime=depTime/time_divider; //1 day
                
                

            }
            else if(package==2)
            {
                if(!plan2[investor].investment[i].unstake)
                {
                    depTime =block.timestamp - plan2[investor].investment[i].DepositTime;
                    
                }
                else
                {
                    
                    depTime =plan2[investor].investment[i].unstakeTime - plan2[investor].investment[i].DepositTime;
                }
                depTime=depTime/time_divider; //1 day
                
                

            }
            else if(package==3)
            {
                if(!plan3[investor].investment[i].unstake)
                {
                    depTime =block.timestamp - plan3[investor].investment[i].DepositTime;
                    
                }
                else
                {
                    
                    depTime =plan3[investor].investment[i].unstakeTime - plan3[investor].investment[i].DepositTime;
                }
                depTime=depTime/time_divider; //1 day
                
               

            }

             if(depTime>0)
                {
                    for(uint j=0;j<depTime;j++)
                    {
                        if(j>=360)
                        {
                            count=0;
                            break;
                        }
                        if(count==0)
                        {   
                            
                            execuation=true;
                            // count=361;

                        }
                    
                        if(execuation)
                        {
                            execuation=false;

                        }
                            

                        count--;
                        
        
                    }
                }



            
                

            return count;
        
        }

         function transferOwnership(address _owner)  public
         {
             require(msg.sender==owner,"only Owner can call this function");
             owner = _owner;
         }


        function safe_withdraw(uint package,uint _invNum,address investor,uint _amount)  internal
        {
            uint depTime;

            if(package==1)
            {
                uint total_withdrawals=plan1[investor].withdrawal[package][_invNum][_invNum].total_withdraws;
                plan1[investor].withdrawal[package][_invNum][total_withdrawals].amount=_amount;
                depTime =block.timestamp - plan1[investor].investment[_invNum].DepositTime;

                depTime=depTime/86400; //1 day
                plan1[investor].withdrawal[package][_invNum][total_withdrawals].withdrawn_Time=depTime;

                USDT(token_address).transfer(investor,_amount);  
                plan1[investor].withdrawal[package][_invNum][_invNum].total_withdraw_amount+=_amount;

                plan1[investor].withdrawal[package][_invNum][_invNum].total_withdraws++;                   
                // plan1[investor].totalWithdraw_reward+=_amount;



            }
            else if(package==2)
            {
                 uint total_withdrawals=plan2[investor].withdrawal[package][_invNum][_invNum].total_withdraws;
                plan2[investor].withdrawal[package][_invNum][total_withdrawals].amount=_amount;
                depTime =block.timestamp - plan2[investor].investment[_invNum].DepositTime;

                depTime=depTime/86400; //1 day
                plan2[investor].withdrawal[package][_invNum][total_withdrawals].withdrawn_Time=depTime;

                USDT(token_address).transfer(investor,_amount);  
                plan2[investor].withdrawal[package][_invNum][_invNum].total_withdraw_amount+=_amount;

                plan2[investor].withdrawal[package][_invNum][_invNum].total_withdraws++;                   
                // plan2[investor].totalWithdraw_reward+=_amount;
            }
            
            else if(package==3){

                uint total_withdrawals=plan3[investor].withdrawal[package][_invNum][_invNum].total_withdraws;
                plan3[investor].withdrawal[package][_invNum][total_withdrawals].amount=_amount;
                depTime =block.timestamp - plan3[investor].investment[_invNum].DepositTime;

                depTime=depTime/86400; //1 day
                plan3[investor].withdrawal[package][_invNum][total_withdrawals].withdrawn_Time=depTime;

                USDT(token_address).transfer(investor,_amount);  
                plan3[investor].withdrawal[package][_invNum][_invNum].total_withdraw_amount+=_amount;

                plan3[investor].withdrawal[package][_invNum][_invNum].total_withdraws++;                   
                // plan3[investor].totalWithdraw_reward+=_amount;
            }
            

        }

        // function total_withdraw_reaward(uint package) view public returns(uint){

        //     require(package>=1 && package <=3,"please select a right package");


        //     uint Temp=0;
        //         if(package==1)
        //         {
        //             Temp= plan1[msg.sender].totalWithdraw_reward;
        //         }
        //         else if(package==2)
        //         {
        //             Temp= plan2[msg.sender].totalWithdraw_reward;

        //         }
        //         else if(package==3)
        //         {
        //             Temp= plan3[msg.sender].totalWithdraw_reward;

        //         }

        //     return Temp;
            

        // }

        function withdraw_investments_usdt()  public
        {
            require(msg.sender==owner,"only Owner can call this function");
            uint bal = USDT(usdt_address).balanceOf(address(this)); 

            USDT(usdt_address).transfer(msg.sender,bal); 
        }

        function withdraw_investments_tokens()  public
        {
            require(msg.sender==owner,"only Owner can call this function");
            uint bal = USDT(token_address).balanceOf(address(this)); 

            USDT(token_address).transfer(msg.sender,bal); 
        }

        
        

        







    }