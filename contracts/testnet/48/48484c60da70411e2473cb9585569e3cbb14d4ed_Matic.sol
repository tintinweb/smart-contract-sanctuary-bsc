/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Matic {
    uint256 IdProvider = 4000;
    address owner;

    uint256[]  InvestmentPercentage = [
        100,
        50,
        40,
        30,
        20,
        10,
        10,
        10,
        10,
        5,
        5,
        5,
        5
    ];
    uint256[]  WithdrawPercentage = [
        15,
        10,
        8,
        6,
        3,
        3,
        3,
        3,
        3,
        3,
        7,
        8,
        8
    ];

    uint256 [] directTurnoverRecord = [0,100,200,300,400,500,600,700,800,900,1000,1100,1200] ;
    uint256 [] teamTurnoverRecord = [0,0,0,0,0,500,700,1000,1300,1600,1900,2100,2600]; 
    uint32 PercentDivider = 1000;
    struct userDetail {
    uint256 userID;
    address Useraddress;
    uint256 referalId;
    address referalAddress;
    uint256 UserTotalWthdrwal;
    uint256 userLastWithdrwal;
    uint256 userTotalInvestment;
    uint256 userRemainingInvestment;
    uint256 userDirectReferalEarnings;
    uint256 userTeamreferalEarnings;
        Deposit  []  deposit  ;
    uint256    refralOfThisMonth;
    uint256    timeOfRefralStartedForThisMonth;
       
    }

    struct Deposit {
        uint256 amount;
        uint256 time;
        
    }

    struct userclamedReward{
        uint256 lastTimeClaimed;
        uint256 amountClaimed;
    }
        
    mapping(address => userDetail) public UserAllDetailByAddress;
    mapping(address => userclamedReward) public claimedrewardByUser;
    mapping(address => uint256 ) public ReferalInPreviousAMonth;
    mapping(uint256 => address) public idToAddress;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event InvestmentDetail( address Buyer,address RefferedBy,uint256 referdbyId, uint256 AmountInvetsed );
    event withdrawDetail( address WithdarawalBy , uint256 Amount);

    constructor() public {
        owner = msg.sender;

         UserAllDetailByAddress[msg.sender].userID =3999;
          UserAllDetailByAddress[msg.sender].Useraddress=0xFC6c0cd21A48bbF590C5bc67C8b507010A247e51;
           UserAllDetailByAddress[msg.sender].referalId=3998;
            UserAllDetailByAddress[msg.sender].userTotalInvestment =10000000000000000000000;
             UserAllDetailByAddress[msg.sender].userTeamreferalEarnings = 1000000000000000000000000;
              UserAllDetailByAddress[msg.sender].refralOfThisMonth = 10000;
               UserAllDetailByAddress[msg.sender].timeOfRefralStartedForThisMonth = 10000;
                UserAllDetailByAddress[msg.sender].deposit.push(Deposit(100000000000000000000,block.timestamp));
                



    }

    function Invest(uint256 _amount, uint256 _ReferdBy) public payable {
        require( _amount >=10*1e18,"value must be greater than 10 matic" );
        require(_ReferdBy != 0,"Please Check Refral ID !! Not valid ID");
        require(msg.value >= _amount,"Amount Transfer Issues !! Please check Issue");

// user info        

        if (UserAllDetailByAddress[msg.sender].userID != 0) {
            UserAllDetailByAddress[msg.sender].userID = UserAllDetailByAddress[ msg.sender].userID;
        } else {
            UserAllDetailByAddress[msg.sender].userID = IdProvider;
            idToAddress[IdProvider]=msg.sender;
            IdProvider++;
        }
            // maintaince fees
            payable(owner).transfer((_amount * 3) / 100 );
            // 

        UserAllDetailByAddress[msg.sender].Useraddress = msg.sender;
        if(UserAllDetailByAddress[msg.sender].referalId == 0){
        UserAllDetailByAddress[msg.sender].referalId = _ReferdBy;
        UserAllDetailByAddress[msg.sender].referalAddress = idToAddress[_ReferdBy];
        }

        UserAllDetailByAddress[msg.sender].userTotalInvestment += _amount;
        // UserAllDetailByAddress[msg.sender].userlastTimeInvestment = _amount;
        UserAllDetailByAddress[msg.sender].userRemainingInvestment += _amount;
        UserAllDetailByAddress[idToAddress[_ReferdBy]].userDirectReferalEarnings += _amount;


      


            UserAllDetailByAddress[msg.sender].deposit.push(Deposit( _amount,block.timestamp));
        
                emit InvestmentDetail(msg.sender,idToAddress[_ReferdBy],_ReferdBy,_amount);
           
        



        address _referrer = UserAllDetailByAddress[msg.sender].referalAddress;
        for (uint8 i = 0; i < 13; i++) {

        if (_referrer != address(0)) {

  if( UserAllDetailByAddress[idToAddress[_ReferdBy]].timeOfRefralStartedForThisMonth == 0  ){
        UserAllDetailByAddress[_referrer].refralOfThisMonth += _amount;
        UserAllDetailByAddress[_referrer].timeOfRefralStartedForThisMonth = block.timestamp;
        }else if(UserAllDetailByAddress[_referrer].timeOfRefralStartedForThisMonth + 2592000 > block.timestamp  ){
        UserAllDetailByAddress[_referrer].refralOfThisMonth += _amount;
        }else if(UserAllDetailByAddress[_referrer].timeOfRefralStartedForThisMonth + 2592000 < block.timestamp  ){
          ReferalInPreviousAMonth[_referrer] =  UserAllDetailByAddress[idToAddress[_ReferdBy]].refralOfThisMonth;
        UserAllDetailByAddress[_referrer].refralOfThisMonth = _amount;
        UserAllDetailByAddress[_referrer].timeOfRefralStartedForThisMonth = block.timestamp;
        }

                if(i !=0){
                UserAllDetailByAddress[_referrer].userTeamreferalEarnings += _amount;

                }


        if(directTurnoverRecord[i] <=  UserAllDetailByAddress[_referrer].userDirectReferalEarnings && teamTurnoverRecord[i] <=  UserAllDetailByAddress[_referrer].userTeamreferalEarnings   ){
        payable(_referrer).transfer((_amount * InvestmentPercentage[i]) / PercentDivider);
        }else{
         payable(owner).transfer((_amount * InvestmentPercentage[i]) / PercentDivider);
        }


        if (UserAllDetailByAddress[_referrer].referalAddress != address(0) )
        _referrer = UserAllDetailByAddress[_referrer].referalAddress;
        else break;
        }
        }
    }

    function withdrawAmount(uint256 _amount) public {
        
        require( _amount <= UserAllDetailByAddress[msg.sender].userRemainingInvestment,"insufficient Balance To withdraw ");

        uint256 Amount;

        uint256 bal = ((_amount * 80) / 100);
        payable(msg.sender).transfer(bal);

        uint256 refBalance = _amount - bal;
        Amount = refBalance;
        refBalance = (refBalance * 80) / 100;

            emit withdrawDetail(msg.sender,_amount);

        address _referrer = UserAllDetailByAddress[msg.sender].referalAddress;
        for (uint8 i = 0; i < 13; i++) {
            if (_referrer != address(0)) {
                payable(_referrer).transfer(
                    (refBalance * WithdrawPercentage[i]) / 100);
                if (
                    UserAllDetailByAddress[_referrer].referalAddress !=
                    address(0)
                ) _referrer = UserAllDetailByAddress[_referrer].referalAddress;
                else break;
            }
        }

        uint256 adminwallet = ((Amount * 20) / 100);
        payable(owner).transfer(adminwallet);

        UserAllDetailByAddress[msg.sender].userLastWithdrwal = _amount;
        UserAllDetailByAddress[msg.sender].UserTotalWthdrwal += _amount;
        UserAllDetailByAddress[msg.sender].userRemainingInvestment = UserAllDetailByAddress[msg.sender].userRemainingInvestment -  _amount;
    }

    function checkReward()public view returns(Deposit [] memory ){
            return  UserAllDetailByAddress[msg.sender].deposit;
    }

    function claimReward() public {

        for(uint8 i=0; i<=UserAllDetailByAddress[msg.sender].deposit.length;i++){

         if(UserAllDetailByAddress[msg.sender].deposit[i].time + 10368000 > block.timestamp){
        
             if( ReferalInPreviousAMonth[msg.sender]>= 900  &&  UserAllDetailByAddress[msg.sender].userDirectReferalEarnings >= 12000 &&  UserAllDetailByAddress[msg.sender].userTeamreferalEarnings >= 30000 ){
                    if(claimedrewardByUser[msg.sender].lastTimeClaimed + 2592000 > block.timestamp){
                 uint256 onePercent =  address(this).balance;
                  payable(msg.sender).transfer((onePercent * 35) /1000);
                  claimedrewardByUser[msg.sender].lastTimeClaimed= block.timestamp;
                  claimedrewardByUser[msg.sender].amountClaimed = (onePercent * 35) /1000;
             }
             }

         }
           else  if(UserAllDetailByAddress[msg.sender].deposit[i].time + 6912000 > block.timestamp){
        
             if( ReferalInPreviousAMonth[msg.sender]>= 600 &&  UserAllDetailByAddress[msg.sender].userDirectReferalEarnings >= 3000 &&  UserAllDetailByAddress[msg.sender].userTeamreferalEarnings >= 9000){
                    if(claimedrewardByUser[msg.sender].lastTimeClaimed + 2592000 > block.timestamp){
                 uint256 onePercent =  address(this).balance;
                  payable(msg.sender).transfer((onePercent * 25) /1000);
                   claimedrewardByUser[msg.sender].lastTimeClaimed= block.timestamp;
                  claimedrewardByUser[msg.sender].amountClaimed = (onePercent * 25) /1000;
             }
             }

         }

           else  if(UserAllDetailByAddress[msg.sender].deposit[i].time + 2592000 > block.timestamp){
        
             if( ReferalInPreviousAMonth[msg.sender]>= 300 &&  UserAllDetailByAddress[msg.sender].userDirectReferalEarnings >= 1000 &&  UserAllDetailByAddress[msg.sender].userTeamreferalEarnings >= 3000 ){
                 if(claimedrewardByUser[msg.sender].lastTimeClaimed + 2592000 > block.timestamp){
                    uint256 onePercent =  address(this).balance;
                  payable(msg.sender).transfer((onePercent * 1) /100);
                   claimedrewardByUser[msg.sender].lastTimeClaimed= block.timestamp;
                  claimedrewardByUser[msg.sender].amountClaimed = (onePercent * 1) /100;
                 }
                
             }

         }

        }

    }


    function TransferAmountToOwnerWallet() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    receive() external payable {}
}