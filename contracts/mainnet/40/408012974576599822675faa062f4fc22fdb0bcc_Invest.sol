/**
 *Submitted for verification at BscScan.com on 2022-12-15
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
        uint public temp_rew;

        
        uint time_divider=86400;
        // uint time_divider=60;





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

        struct allWithdrawals
        {

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
  
        // address public usdt_address=0x55d398326f99059fF775485246999027B3197955;
        // address public token_address=0x58f26DC61943698B565473057FADa470f16f6722;
        address public busd_address=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address public usdt_address=0x55d398326f99059fF775485246999027B3197955;
        address public token_address=0xa51c5B9Ca0Eace219f285a3273779D7591A3FDD3;

        uint public investmentPeriod=1 days;
        // uint public investmentPeriod=5 minutes;


        mapping(address=>bool) public investBefore;


        mapping(address=>Data) public plan1;
        mapping(address=>Data) public plan2;
        mapping(address=>Data) public plan3;



      


        constructor(){
            
            owner=msg.sender;              //here we are setting the owner of this contract

        }



        function Stake(uint package,uint investment, address _referral,uint selected_currency) external returns(bool success)
        {
            require(package>=1 && package <=3);
            address current_token;
            if(selected_currency==1)
            {
                current_token=usdt_address;
            }
            else{
                current_token=busd_address;

            }

            if(package==1)
            {
                require(investment>=1000000000000000000&& investment<501000000000000000000,"1");

                if(selected_currency==1)
                {
                    // require(USDT(usdt_address).balanceOf(msg.sender)>=investment,"2.0");
                    require(USDT(usdt_address).allowance(msg.sender,address(this))>=investment,"3.0");
                }
                else{
                    // require(USDT(busd_address).balanceOf(msg.sender)>=investment);
                    require(USDT(busd_address).allowance(msg.sender,address(this))>=investment);
                }



                uint num = plan1[msg.sender].noOfInvestment;
                plan1[msg.sender].investment[num].investedAmount =(investment/25000000000000000)*1 ether;
                plan1[msg.sender].investment[num].DepositTime=block.timestamp;
                plan1[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod;  // 300 days
                plan1[msg.sender].investment[num].investmentNum=num;
                // plan1[msg.sender].totalInvestment+=bronze_token;
                plan1[msg.sender].noOfInvestment++;
                // USDT(current_token).transferFrom(msg.sender,owner,investment);
                // USDT(token_address).transfer(msg.sender,bronze_token);
            }
            else if( package==2)
            {
                require(investment>500000000000000000000&& investment<1001000000000000000000);

                if(selected_currency==1)
                {
                    // require(USDT(usdt_address).balanceOf(msg.sender)>=investment);
                    require(USDT(usdt_address).allowance(msg.sender,address(this))>=investment);
                }
                else{
                    // require(USDT(busd_address).balanceOf(msg.sender)>=investment);
                    require(USDT(busd_address).allowance(msg.sender,address(this))>=investment);
                }



                uint num = plan2[msg.sender].noOfInvestment;
                plan2[msg.sender].investment[num].investedAmount =(investment/25000000000000000)*1 ether;
                plan2[msg.sender].investment[num].DepositTime=block.timestamp;
                plan2[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod ;  // 300 days
                plan2[msg.sender].investment[num].investmentNum=num;
                // plan2[msg.sender].totalInvestment+=silver_token;
                plan2[msg.sender].noOfInvestment++;
                // USDT(current_token).transferFrom(msg.sender,owner,investment);
                // USDT(token_address).transfer(msg.sender,silver_token);
            }
            else if(package==3)
            {
                require(investment>1000000000000000000000);

                if(selected_currency==1)
                {
                    // require(USDT(usdt_address).balanceOf(msg.sender)>=investment);
                    require(USDT(usdt_address).allowance(msg.sender,address(this))>=investment);
                }
                else{
                    // require(USDT(busd_address).balanceOf(msg.sender)>=investment);
                    require(USDT(busd_address).allowance(msg.sender,address(this))>=investment);
                }

  

                uint num = plan3[msg.sender].noOfInvestment;
                plan3[msg.sender].investment[num].investedAmount =(investment/25000000000000000)*1 ether;
                plan3[msg.sender].investment[num].DepositTime=block.timestamp;
                plan3[msg.sender].investment[num].expire_Time=block.timestamp + investmentPeriod ;  // 300 days
                plan3[msg.sender].investment[num].investmentNum=num;
                // plan3[msg.sender].totalInvestment+=gold_token;
                plan3[msg.sender].noOfInvestment++;
                // USDT(current_token).transferFrom(msg.sender,owner,investment);
                // USDT(token_address).transfer(msg.sender,gold_token);

                
            }
            if(investBefore[msg.sender] == false)
            { 
               
                if(_referral!=address(0) && _referral!=msg.sender)                                         //checking that investor comes from the referral link or not
                {

                   uint reward1 = (10000000000000000000 * investment)/100000000000000000000;
                    temp_rew=reward1;
                    // USDT(current_token).transfer(_referral,reward1);
                    USDT(current_token).transferFrom(msg.sender,_referral,reward1);
                    USDT(current_token).transferFrom(msg.sender,owner,investment-reward1);

                }
                

            }
            investBefore[msg.sender] =true;




           

            return true;
            
        }

        
       
        function getReward(uint _package,uint i) view public returns(uint)
        { 

            require(_package>=1 && _package <=3);
            uint totalReward;
            uint depTime;
            uint rew;
            uint count=0;
            // uint month=0;
            // uint total_withdraw;
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
                        if(count>=1)
                        {   
                            // month+=30;
                            curr_inv+=totalReward;
                            uint temp1= plan1[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    // if(month == plan1[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    // {
                                       curr_inv-= plan1[msg.sender].withdrawal[package][i][k].amount; 
                                    //    total_withdraw+=plan1[msg.sender].withdrawal[package][i][k].amount; 
                                    // }
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
                        if(count>=1)
                        {   
                            // month+=30;
                            curr_inv+=totalReward;
                            uint temp1= plan2[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    // if(month == plan2[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    // {
                                       curr_inv-= plan2[msg.sender].withdrawal[package][i][k].amount; 
                                    //    total_withdraw+=plan2[msg.sender].withdrawal[package][i][k].amount;
                                    // }
                                }
                            execuation=true;
                            count=0;

                        }
                    
                        if(execuation)
                        {
                            rew  = ((curr_inv)*666666666700000000)/100000000000000000000;
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
                                // month+=30;
                                curr_inv+=totalReward;
                                uint temp1= plan3[msg.sender].withdrawal[package][i][i].total_withdraws;
                                for(uint k=0;k<temp1;k++)
                                {
                                    // if(month == plan3[msg.sender].withdrawal[package][i][k].withdrawn_Time)
                                    // {
                                       curr_inv-= plan3[msg.sender].withdrawal[package][i][k].amount; 
                                    //    total_withdraw+=plan3[msg.sender].withdrawal[package][i][k].amount;
                                    // }
                                }
                                execuation=true;
                                count=0;

                            }
                        
                            if(execuation)
                            {
                                rew  = ((curr_inv)*1000000000000000000)/100000000000000000000;
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

        

        function withdrawReward(address investor,uint package ,uint _invNum, uint _amount) internal returns (bool success)
        {
            require(package>=1 && package <=3);
            // uint depTime;

           
            if(package==1)
            {
                require(plan1[investor].investment[_invNum].investedAmount>0);           
                require(!plan1[investor].investment[_invNum].unstake);
                // depTime = block.timestamp - plan1[investor].investment[_invNum].DepositTime;
                // require( timeLeft(1,_invNum,investor)==0);
                    require(plan1[msg.sender].investment[_invNum].expire_Time <block.timestamp);


                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);

            }
            else if(package==2)
            {
                require(plan2[investor].investment[_invNum].investedAmount>0);           
                require(!plan2[investor].investment[_invNum].unstake);
                // depTime = block.timestamp - plan2[investor].investment[_invNum].DepositTime;
                // require( timeLeft(2,_invNum,investor)==0);
                    require(plan2[msg.sender].investment[_invNum].expire_Time <block.timestamp);


                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);


            }
            else if(package==3)
            {

                require(plan3[investor].investment[_invNum].investedAmount>0);           
                require(!plan3[investor].investment[_invNum].unstake );
                // depTime = block.timestamp - plan3[investor].investment[_invNum].DepositTime;
                // require( timeLeft(3,_invNum,investor)==0);
                    require(plan3[msg.sender].investment[_invNum].expire_Time <block.timestamp);

                uint Total_reward = getReward(package,_invNum);
                require(Total_reward>0);         
                require(Total_reward>=_amount);
                safe_withdraw( package, _invNum, investor, _amount);


            }


            return true;

        }







  

            function unStake(uint package,uint num) external  returns (bool success)
            {
                require(package>=1 && package <=3);
                // uint depTime;
  

                if(package==1)
                {

                    require(plan1[msg.sender].investment[num].investedAmount>0,"1");           
                    require(!plan1[msg.sender].investment[num].unstake,"2");
                    // depTime = block.timestamp - plan1[msg.sender].investment[num].DepositTime;
                    // require( timeLeft(1,num,msg.sender)==0);
                    
                    require(plan1[msg.sender].investment[num].expire_Time <block.timestamp,"3");

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
                    require(plan2[msg.sender].investment[num].investedAmount>0,"1");           
                    require(!plan2[msg.sender].investment[num].unstake,"2");
                    // depTime = block.timestamp - plan2[msg.sender].investment[num].DepositTime;
                    // require( timeLeft(2,num,msg.sender)==0);
                    require(plan2[msg.sender].investment[num].expire_Time <block.timestamp,"3");



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
                    require(plan3[msg.sender].investment[num].investedAmount>0,"1");           
                    require(!plan3[msg.sender].investment[num].unstake,"2");
                    // depTime = block.timestamp - plan3[msg.sender].investment[num].DepositTime;
                    // require( timeLeft(3,num,msg.sender)==0,"time is not over");
                    require(plan3[msg.sender].investment[num].expire_Time <block.timestamp,"3");

  

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


        function getAllinvestments(uint package) public view returns (allInvestments[] memory hello) 
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
                    Invested[currentIndex].expire_Time=plan1[msg.sender].investment[i].expire_Time;

                    // Invested[currentIndex].expire_Time=timeLeft(1,plan1[msg.sender].investment[i].investmentNum,msg.sender);
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
                    if( plan2[msg.sender].investment[i].investedAmount > 0  )
                    {
                        temp++;
                    }

                }
            
                allInvestments[] memory Invested =  new allInvestments[](temp) ;

                for(uint i=0;i<num;i++)
                {
                if( plan2[msg.sender].investment[i].investedAmount > 0 ){
                    Invested[currentIndex]=plan2[msg.sender].investment[i];
                    Invested[currentIndex].expire_Time=plan2[msg.sender].investment[i].expire_Time;

                    // Invested[currentIndex].expire_Time=timeLeft(2,plan2[msg.sender].investment[i].investmentNum,msg.sender);
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
                        Invested[currentIndex].expire_Time=plan3[msg.sender].investment[i].expire_Time;

                        // Invested[currentIndex].expire_Time=timeLeft(3,plan3[msg.sender].investment[i].investmentNum,msg.sender);
                        Invested[currentIndex].claimable_reward=getReward(3,plan3[msg.sender].investment[i].investmentNum);
                        currentIndex++;
                    }

                }
                return Invested;
            }
           
            
        }

        function timeLeft(uint package, uint inv,address investor) public view returns(uint)
        {
            require(package>=1 && package <=3);

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
                        // if(j>=360)
                        // {
                        //     count=0;
                        //     break;
                        // }
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
            require(msg.sender==owner);
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


        function withdraw_investments_usdt()  public
        {
            require(msg.sender==owner);
            uint bal = USDT(usdt_address).balanceOf(address(this)); 

            USDT(usdt_address).transfer(msg.sender,bal); 
        }
        function withdraw_investments_busd()  public
        {
            require(msg.sender==owner);
            uint bal = USDT(busd_address).balanceOf(address(this)); 

            USDT(busd_address).transfer(msg.sender,bal); 
        }

        function withdraw_investments_tokens()  public
        {
            require(msg.sender==owner);
            uint bal = USDT(token_address).balanceOf(address(this)); 

            USDT(token_address).transfer(msg.sender,bal); 
        }
        function total_withdraw(uint package,uint _invNum) public view returns(uint)
        {

            return plan1[msg.sender].withdrawal[package][_invNum][_invNum].total_withdraw_amount;

        }
        
        

        







    }