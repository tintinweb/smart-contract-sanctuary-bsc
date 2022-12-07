/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Matic {
    uint256  IdProvider  = 4000;
    address owner;
    address secondOwner;
    bool isWithdrawAvailable = true;
    

    uint256[] InvestmentPercentage = [
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
        5
        
    ];
    uint256[] WithdrawPercentage = [
        23,
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
        8
        
    ];

    uint256 [] directTurnoverRecord = [0,100,200,300,400,500,600,700,800,900,1000,1100] ;
    uint256 [] teamTurnoverRecord = [0,0,0,0,0,500,700,1000,1300,1600,1900,2100]; 
    uint32 PercentDivider = 1000;
    uint256 priceDivider = 1e8;

    struct userDetail {
    uint256 userID;
    address Useraddress;
    uint256 referalId;
    address referalAddress;
    uint256 UserTotalWthdrwal;
    uint256 userTotalInvestment;
    uint256 userDirectReferal;
    uint256 userTeamreferalEarnings;
    uint256 totalIncentive;
    }



    mapping(address => userDetail) public UserAllDetailByAddress;
    mapping(address => mapping(uint8 => uint256)) public UserIncentiveDetail;
    mapping(address => mapping(uint8 => uint256)) public UserwithdrwalIncentiveDetail;
    mapping(address => uint256 ) public ReferalInPreviousAMonth;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => uint256 ) public returnvalue;
    mapping(uint256 =>  uint256 ) public returnPrice;
    mapping(address => uint256  ) public MaticFiInUserWallet;
    mapping(address => bool)  public isUserRegisterd;
    mapping(uint256  => bool) public IsIdValid;
    mapping(address => uint256) public UserMaticInCurrentPurchase;
    mapping(address => uint256) public lastWithdrawlMaticRecived;

     modifier onlyOwner() {
        require(msg.sender == owner);
    
        _;
    }
      modifier onlySecondOwner() {
        require(msg.sender == secondOwner);
        _;
    }

    event InvestmentDetail( address  Buyer,address  RefferedBy,uint256  referdbyId, uint256 AmountInvetsed );
    event register( address Buyer,address  RefferedBy,uint256  referdbyId, uint256 AmountInvetsed );
    event withdrawDetail( address WithdarawalBy , uint256 Amount);


    constructor()  {
        owner = msg.sender;
        secondOwner =0x4Bb8401E93fd89488F5D0cd099c3c40D49B1B5D0;
         UserAllDetailByAddress[msg.sender].userID =3999;
         IsIdValid[3999]=true;
          UserAllDetailByAddress[msg.sender].Useraddress=owner;
           idToAddress[3999]=owner;
           UserAllDetailByAddress[msg.sender].referalId=3998;
           UserAllDetailByAddress[msg.sender].referalAddress= 0x6Be705610b19Ff3412b64F628478B404FF311269;

            UserAllDetailByAddress[msg.sender].userTotalInvestment =100;
             UserAllDetailByAddress[msg.sender].userTeamreferalEarnings = 10000;

             
                returnvalue[2] = 5;   
                returnvalue[50] = 50;   
                returnvalue[75] = 70;   
                returnvalue[100] = 70;   



                returnPrice[0]=1; 
                returnPrice[1]=10; 
                returnPrice[2]=100; 
                returnPrice[3]=1000; 
                returnPrice[4]=10000; 
                returnPrice[5]=100000; 
                returnPrice[6]=1000000; 
                returnPrice[7]=10000000;
                returnPrice[8]=100000000; 


    }

    function Invest(uint256 _amount, uint256 _ReferdBy) public payable {
        
            // require( _amount >=10*1e18,"value must be greater than 10 matic" );
            
            require(IsIdValid[_ReferdBy]==true,"not Valid referal Id !!");
            require(_ReferdBy != 0,"Please Check Refral ID !! Not valid ID");
            require(msg.value >= _amount,"Amount Transfer Issues !! Please check Issue");
            require(UserAllDetailByAddress[msg.sender].userID != _ReferdBy," This is not valid Action");

            // user info        
          
            if (UserAllDetailByAddress[msg.sender].userID != 0) {
            UserAllDetailByAddress[msg.sender].userID = UserAllDetailByAddress[ msg.sender].userID;
            } else {
            UserAllDetailByAddress[msg.sender].userID = IdProvider;
            idToAddress[IdProvider]=msg.sender;
            IsIdValid[IdProvider]=true;
             emit register(msg.sender,idToAddress[_ReferdBy],_ReferdBy,_amount);
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
            UserAllDetailByAddress[idToAddress[_ReferdBy]].userDirectReferal += _amount;
            //direct transfer
            UserAllDetailByAddress[idToAddress[_ReferdBy]].totalIncentive +=(_amount * InvestmentPercentage[0]) / PercentDivider;
             UserIncentiveDetail[idToAddress[_ReferdBy]][0] += (_amount * InvestmentPercentage[0]) / PercentDivider;

         
             isUserRegisterd[msg.sender]= true;
            emit InvestmentDetail(msg.sender,idToAddress[_ReferdBy],_ReferdBy,_amount);

            uint256  TurnOver  = balanceInContract();
            uint256 MaticFi;

            if(TurnOver == 0*1e18){
            MaticFi  = (_amount/returnPrice[0])/1e8 ;
            }
            else if(TurnOver > 0*1e18 && TurnOver <= 10*1e18){
            MaticFi =  (_amount/returnPrice[1])/1e8 ;
            }
            else if(TurnOver > 10*1e18 && TurnOver <= 100*1e18 ){
            MaticFi =  (_amount/returnPrice[2])/1e8 ;
            }
            else if(TurnOver > 100*1e18 && TurnOver <= 1000*1e18 ){
            MaticFi =  (_amount/returnPrice[3])/1e8 ;
            }
            else if(TurnOver > 1000*1e18 && TurnOver <= 10000*1e18 ){
            MaticFi =  (_amount/returnPrice[4])/1e8 ;
            }
            else if(TurnOver > 10000*1e18 && TurnOver <= 100000*1e18 ){
            MaticFi =  (_amount/returnPrice[5])/1e8 ;
            } 
            else if(TurnOver > 100000*1e18 && TurnOver <= 1000000 *1e18){
            MaticFi =  (_amount/returnPrice[6])/1e8 ;
            }
            else if(TurnOver > 1000000*1e18 && TurnOver <= 10000000*1e18 ){
            MaticFi =  (_amount/returnPrice[7])/1e8 ;
            }else if(TurnOver > 10000000*1e18 && TurnOver <= 100000000*1e18 ){
            MaticFi =  (_amount/returnPrice[8])/1e8 ;
            }else if(TurnOver > 100000000*1e18  ){
            MaticFi =  (_amount/returnPrice[8])/1e8 ;
            }


//last amount of matic user gotted

            UserMaticInCurrentPurchase[msg.sender] =  MaticFi;

            MaticFiInUserWallet[msg.sender] += MaticFi;



            address _referrer = UserAllDetailByAddress[msg.sender].referalAddress;

            for (uint8 i = 0; i < 12; i++) {

            if (_referrer != address(0)) {


            if(i !=0){
            UserAllDetailByAddress[_referrer].userTeamreferalEarnings += _amount;
            

            if(directTurnoverRecord[i] <=  UserAllDetailByAddress[_referrer].userDirectReferal && teamTurnoverRecord[i] <=  UserAllDetailByAddress[_referrer].userTeamreferalEarnings ){
            UserAllDetailByAddress[_referrer].totalIncentive +=(_amount * InvestmentPercentage[i]) / PercentDivider;
             UserIncentiveDetail[idToAddress[_ReferdBy]][i] +=(_amount * InvestmentPercentage[i]) / PercentDivider;

            }else{
            payable(owner).transfer((_amount * InvestmentPercentage[i]) / PercentDivider);
            }
            }

            if (UserAllDetailByAddress[_referrer].referalAddress != address(0) )
            _referrer = UserAllDetailByAddress[_referrer].referalAddress;
            else break;
            }
            }

            }


            function withdrawAmount(uint256 _amount) public {

            require(  isWithdrawAvailable == true ," Currently Withdrawl Is Unavaible");
            require(MaticFiInUserWallet[msg.sender] >  0 , " User balance is zero !! Unable To Complete transanction ");


            uint256  TurnOver  = balanceInContract();
               
            uint256 Maticrem;

            uint256 userDemanded =  _amount ;

            userDemanded =  (  MaticFiInUserWallet[msg.sender] * userDemanded )/100;  

            require(MaticFiInUserWallet[msg.sender] >= userDemanded ,"Not Enough Maticfi !! Please Purchase More to Continue");


            if(TurnOver == 0*1e18){
            Maticrem  = (userDemanded*returnPrice[0])/1e8 ;
            }
            else if(TurnOver > 0*1e18 && TurnOver <= 10*1e18 ){
            Maticrem =  (userDemanded*returnPrice[1])/1e8 ;
            }
            else if(TurnOver > 10*1e18 && TurnOver <= 100*1e18 ){
            Maticrem =  (userDemanded*returnPrice[2])/1e8 ;
            }
            else if(TurnOver > 100*1e18 && TurnOver <= 1000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[3])/1e8 ;
            }
            else if(TurnOver > 1000*1e18 && TurnOver <= 10000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[4])/1e8 ;
            }
            else if(TurnOver > 10000*1e18 && TurnOver <= 100000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[5])/1e8 ;
            } 
            else if(TurnOver > 100000*1e18 && TurnOver <= 1000000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[6])/1e8 ;
            }
            else if(TurnOver > 1000000*1e18 && TurnOver <= 10000000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[7])/1e8 ;
            }else if(TurnOver > 10000000*1e18 && TurnOver <= 100000000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[8])/1e8 ;
            }else if(TurnOver > 100000000*1e18 ){
            Maticrem =  (userDemanded*returnPrice[8])/1e8 ;
            }


            MaticFiInUserWallet[msg.sender] = MaticFiInUserWallet[msg.sender] - userDemanded;


            uint256 levelWillGet = (Maticrem * returnvalue[_amount])/100;     

            payable(msg.sender).transfer(userDemanded - levelWillGet);
               lastWithdrawlMaticRecived[msg.sender] = userDemanded - levelWillGet;
            uint256 Amount;

            UserAllDetailByAddress[msg.sender].UserTotalWthdrwal += userDemanded;

            uint256 refBalance = levelWillGet;
            Amount = refBalance;
            refBalance = (refBalance * 80) / 100;

            emit withdrawDetail(msg.sender,userDemanded);

            address _referrer = UserAllDetailByAddress[msg.sender].referalAddress;

            for (uint8 i = 0; i < 12; i++) {
            if (_referrer != address(0)){
            UserAllDetailByAddress[_referrer].totalIncentive +=(refBalance * WithdrawPercentage[i]) / 100;
            UserwithdrwalIncentiveDetail[_referrer][i] += (refBalance * WithdrawPercentage[i]) / 100;
            if ( UserAllDetailByAddress[_referrer].referalAddress !=address(0))
             _referrer = UserAllDetailByAddress[_referrer].referalAddress;
            else break;
            }
            }

            uint256 adminwallet = ((Amount * 20) / 100);
            payable(owner).transfer(adminwallet);

            }

            function TransferAmountToOwnerWallet() public payable onlyOwner {
            payable(msg.sender).transfer(address(this).balance);
            }

            function transferOwnership(address newOwner) public onlyOwner {
            require(newOwner != address(0));
            owner = newOwner;
            }

            function balanceInContract() public view returns (uint256){

            return  address(this).balance;

            }   

            function ClaimIncentiveReward () public payable{
                require( UserAllDetailByAddress[msg.sender].totalIncentive > 0,"available balance Is Zero ");
                 payable(msg.sender).transfer(UserAllDetailByAddress[msg.sender].totalIncentive);
                 UserAllDetailByAddress[msg.sender].totalIncentive = 0;
            }  
          
                function ChangeOwner (address newOwner) public  onlyOwner{
                owner = newOwner;
                }
                function ChangeSecondOwner (address newOwner) public  onlyOwner{
                secondOwner = newOwner;
                }



                //   function updateReward(uint256 index ,uint256 value) public onlySecondOwner {
                //     UserAllDetailByAddress[msg.sender].deposit[index].rewardGenrated =value;
                // }  


                // function claimReward(uint256 ind ) public payable {
                //    payable(msg.sender).transfer(UserAllDetailByAddress[msg.sender].deposit[ind].rewardGenrated);
                // } 

                function stopWithdrawl(bool _status) public  onlyOwner{
                    isWithdrawAvailable = _status;
                } 
    receive() external payable {}
}