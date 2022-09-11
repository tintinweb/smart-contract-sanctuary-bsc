/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface USDT{

    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) ;

    }

contract DOI{


      struct allInvestments{

            uint investedAmount;
            uint buying_Time;
            uint investmentNum;
            uint unstakeTime;
            bool claimed;



        }



    struct user_info{

        mapping(uint=>allInvestments) investment;
        uint tokens_for_claiming;
        address referralFrom;
        bool investBefore;
        address[] hisReferrals;
        uint ref_tokens_claiming;
        uint total_investments;
        uint total_referrals;
        uint total_ref_reward;
        uint total_investmentOf_ref;
         


    }


    struct Data{

        uint  upper_limit;
        uint  quantity;
        uint  total_limit;

    }

    constructor(address _usdt_add, address _buy_token_add){

        usdt_address=_usdt_add;
        buy_token_add=_buy_token_add;
        owner=msg.sender;

        for(uint i=0; i<3;i++)
        {
            if(i==0)
            {
                round[i].upper_limit=100;
                round[i].quantity=10000;
                round[i].total_limit=50000000;//50000000

            }
            if(i==1)
            {
                round[i].upper_limit=500;
                round[i].quantity=25000;
                round[i].total_limit=50000000;//50000000

            }
            if(i==2)
            {
                round[i].upper_limit=1000;
                round[i].quantity=33333;
                round[i].total_limit=66666667;//66666667

            }
        }

    }

    mapping(address=>user_info) public user;
    mapping(uint=>Data) public round;
    address public usdt_address;
    address public buy_token_add;
    address public owner;
    uint public time_end;
    uint public  total_earning;
    uint public num;
    uint public total_investors;

    function sendRewardToReferrals(address investor,uint _investedAmount)  internal  //this is the freferral function to transfer the reawards to referrals
    { 

        address temp = investor;       
        uint[] memory percentage = new uint[](5);
        percentage[0] = 5;
        percentage[1] = 4;
        // percentage[2] = 3;



        uint j;



        for(uint i=0;i<2;i++)
        {

            if(i==0)
            {
                j=0;
            }
            else if(i==1)
            {
                j=1;
            }
            // else if(i==2)
            // {
            //     j=2;
            // }
            
            if(user[temp].referralFrom!=address(0))
            {

                temp=user[temp].referralFrom;
                uint reward1 = (percentage[j] * _investedAmount)/100;
                user[temp].total_ref_reward+=reward1;
                user[temp].ref_tokens_claiming+=reward1;



            } 
            else{
                break;
            }

        }

    }





    function buy_tokens(address _referral) external returns(bool){
        require(round[num].quantity<=round[num].total_limit,"asking tokens are more than the limit");
        require(USDT(usdt_address).balanceOf(msg.sender)>round[num].upper_limit*10**18,"you dont have enough balance to buy");
        require(USDT(usdt_address).transferFrom(msg.sender,owner,round[num].upper_limit*10**18),"tokens does not transferred");
        total_earning+=round[num].upper_limit;
        user[msg.sender].investment[user[msg.sender].total_investments].investedAmount=round[num].quantity;
        user[msg.sender].investment[user[msg.sender].total_investments].buying_Time=block.timestamp;

        user[msg.sender].total_investments++;
        user[msg.sender].tokens_for_claiming+=round[num].quantity;
        round[num].total_limit-=round[num].quantity;
        
        if(_referral==address(0) || _referral==msg.sender)                                         //checking that investor comes from the referral link or not
        {

            user[msg.sender].referralFrom = address(0);
        }
        else
        {
            if(user[msg.sender].investBefore == false)
            { 
                total_investors++;
                user[msg.sender].referralFrom = _referral;
                user[_referral].hisReferrals.push(msg.sender);
            }
            user[_referral].total_investmentOf_ref+=round[num].quantity;
            user[_referral].total_referrals++;

            sendRewardToReferrals(msg.sender,round[num].quantity);      //with this function, sending the reward to the all 12 parent referrals
            
        }
        if(round[num].total_limit==0)
        {
            if(num==2)
            {
                time_end=block.timestamp+100 days;            

                // time_end=block.timestamp+2 minutes;            
            }
            num++;
        }
        user[msg.sender].investBefore=true;

        return true;
    }

    function claim_ref_tokens() external returns(bool)
    {
        require(user[msg.sender].ref_tokens_claiming>0,"you dont have tokens to claim");
        require(round[2].total_limit==0 && time_end > 0 && time_end < block.timestamp);

        USDT(buy_token_add).transfer(msg.sender,(user[msg.sender].ref_tokens_claiming)*10**18);
        user[msg.sender].ref_tokens_claiming=0;


        return true;
    }

    function claim_bought_tokens() external returns(bool)
    {
        require(round[2].total_limit==0 && time_end > 0 && time_end < block.timestamp,"time is not end");
        require(user[msg.sender].tokens_for_claiming>0,"you dont have any token");

        USDT(buy_token_add).transfer(msg.sender,(user[msg.sender].tokens_for_claiming)*10**18);
        user[msg.sender].tokens_for_claiming=0;




        return true;
    }

    function getAll_Buyings() public view returns (allInvestments[] memory) { //this function will return the all investments of the investor and withware date
            uint _num = user[msg.sender].total_investments;
            uint temp;
            uint currentIndex;
            
            for(uint i=0;i<_num;i++)
            {
               if( user[msg.sender].investment[i].investedAmount > 0 && !user[msg.sender].investment[i].claimed ){
                   temp++;
               }

            }
         
            allInvestments[] memory Invested =  new allInvestments[](temp) ;

            for(uint i=0;i<_num;i++)
            {
               if( user[msg.sender].investment[i].investedAmount > 0 && !user[msg.sender].investment[i].claimed){
                 //allInvestments storage currentitem=DUSDinvestor[msg.sender].investment[i];
                   Invested[currentIndex]=user[msg.sender].investment[i];
                   currentIndex++;
               }

            }
            return Invested;

        }


    function get_claim_ref_tokens() external view returns(uint)
    {
        return user[msg.sender].ref_tokens_claiming;
    }

    function get_claimable_tokens() external view returns(uint)
    {
        return user[msg.sender].tokens_for_claiming;
    }

    function change_upperLimit(uint _upper_limit,uint _round)  public
    {
        require(msg.sender==owner,"only Owner can call this function");
        round[_round-1].upper_limit=_upper_limit;
    
    }

    function transferOwnership(address _owner)  public
    {
        require(msg.sender==owner,"only Owner can call this function");
        owner = _owner;
    }
    function get_current_quantity() external view returns(uint){

        return round[num].quantity;
    }
        function get_current_upperLimit() external view returns(uint){

        return round[num].upper_limit;
    }
    function get_currTime() external view returns(uint){

        return block.timestamp;
    }
    function get_total_ref_rew() external view returns(uint){

        return user[msg.sender].total_ref_reward;
    }
    function get_total_ref() external view returns(uint){

        return user[msg.sender].total_referrals;
    }
    function get_total_ref_invest() external view returns(uint){

        return user[msg.sender].total_investmentOf_ref;
    }

    










}