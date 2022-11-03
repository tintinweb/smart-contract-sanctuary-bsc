/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
 
interface USDT {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract tfwcontractnew 
{
    USDT public USDt;

    address public contractOwner;
    uint public totalNumberofUsers;

    uint256 public totalPackagePurchased1;
    uint256 public totalPackagePurchased2;
    uint256 public totalPackagePurchased3;

    uint256 public totalReferralIncome;
    uint256 public totalLevelIncome;
    uint256 public totalIncome;
    uint256 public totalRewardIncome;

    struct UserAffiliateDetails {
        bool isExist;
        uint userId;
        address sponsor;
        uint joiningDateTime;
        uint selfInvestment;
        uint selfInvestment1;
        uint selfInvestment2;
        uint selfInvestment3;
        uint totalReferralBonus;
        uint totalLevelBonus;
        //uint totalBonus;       
        uint totalRewardBonus;
        uint totalDirect;    
        address[] Directlist;  
    }

    mapping (address => UserAffiliateDetails) public _UserAffiliateDetails;
 
     constructor()  {

        USDt = USDT(0x55d398326f99059fF775485246999027B3197955);

        contractOwner=0x8e37226A24b27F98706D15c7ACFA95aAe084E07A;
        
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[contractOwner].isExist = true;
        _UserAffiliateDetails[contractOwner].userId = TimeStamp;
        _UserAffiliateDetails[contractOwner].sponsor =address(0);
        _UserAffiliateDetails[contractOwner].joiningDateTime= TimeStamp;

        _UserAffiliateDetails[contractOwner].selfInvestment=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment1=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment2=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment3=0 ; 

        _UserAffiliateDetails[contractOwner].totalReferralBonus=0 ; 
        _UserAffiliateDetails[contractOwner].totalLevelBonus=0 ; 
       // _UserAffiliateDetails[contractOwner].totalBonus=0 ; 
        _UserAffiliateDetails[contractOwner].totalRewardBonus=0;
        _UserAffiliateDetails[contractOwner].totalDirect=0 ; 
        
        totalNumberofUsers=0;

        totalPackagePurchased1=0;
        totalPackagePurchased2=0;
        totalPackagePurchased3=0;

        totalReferralIncome=0;
        totalLevelIncome=0;
        totalIncome=0;
        totalRewardIncome=0;
    }
 
   
    // Admin Can Check Is User Exists Or Not
    function _IsUserExists(address user) public view returns (bool) {
        return (_UserAffiliateDetails[user].userId != 0);
    }

   event Joining(address indexed user, uint256 amount,address referrer);
 
   function _Joining(address referrer, uint256 _package) external   {
            
        require(_UserAffiliateDetails[referrer].isExist == true, "Refer Not Found!");
        
        address user = msg.sender;
        
        if (_UserAffiliateDetails[user].isExist == false)
        {
            uint TimeStamp=block.timestamp;
            _UserAffiliateDetails[user].isExist = true; 
            _UserAffiliateDetails[user].userId = TimeStamp;
            _UserAffiliateDetails[user].sponsor = referrer;
            _UserAffiliateDetails[user].joiningDateTime= TimeStamp;
        
            _UserAffiliateDetails[user].selfInvestment1=0 ; 
            _UserAffiliateDetails[user].selfInvestment2=0 ; 
            _UserAffiliateDetails[user].selfInvestment3=0 ; 

            _UserAffiliateDetails[user].totalReferralBonus=0 ; 
            _UserAffiliateDetails[user].totalLevelBonus=0 ; 
          //  _UserAffiliateDetails[user].totalBonus=0 ; 
            _UserAffiliateDetails[user].totalRewardBonus=0;
            _UserAffiliateDetails[user].totalDirect=0 ; 

            _UserAffiliateDetails[referrer].totalDirect+=1 ; 
            _UserAffiliateDetails[referrer].Directlist.push(user);  

            totalNumberofUsers+=1;
 
        }

        if (_package==1 && _UserAffiliateDetails[user].selfInvestment1==0)
        {
            registration(user, 100*10**18, 1);
        }
        else if (_package==2 && _UserAffiliateDetails[user].selfInvestment2==0)
        {
            registration(user, 300*10**18, 2);
        }
        else if (_package==3 && _UserAffiliateDetails[user].selfInvestment3==0)
        {
            registration(user, 500*10**18, 3);
        }
        else
        {
            revert("This Package Already Activated!");
        }
    }

    function registration(address user, uint256 amount, uint package) private {     

            USDt.transferFrom(user, address(this), amount );
       
            _UserAffiliateDetails[user].selfInvestment+=amount ; 

            if(package==1)
            {
                _UserAffiliateDetails[user].selfInvestment1=amount ; 
                totalPackagePurchased1+=amount;
            }
            else if(package==2)
            {
                _UserAffiliateDetails[user].selfInvestment2=amount ;
                totalPackagePurchased2+=amount;
            }
            else if(package==3)
            {
                _UserAffiliateDetails[user].selfInvestment3=amount ;
                 totalPackagePurchased3+=amount;
            }

            _refPayoutDirect( user ,amount);
            _refPayoutLevel ( user ,amount);
            
             uint256 finalbonus=USDt.balanceOf(address(this));
             USDt.approve(contractOwner,finalbonus );
             USDt.transfer(contractOwner,finalbonus );

            address ref =  _UserAffiliateDetails[user].sponsor;
            emit Joining(user,amount, ref);
    }


// diret income 
 function _refPayoutDirect(address  user,uint256 amount) internal {

		address   upline = _UserAffiliateDetails[user].sponsor;

        uint256 bonus=((amount*60)/100);
       
         _UserAffiliateDetails[upline].totalReferralBonus+=bonus ; 
      //   _UserAffiliateDetails[upline].totalBonus+=bonus ; 

        uint256 bonus2=((amount*10)/100);
         _UserAffiliateDetails[upline].totalRewardBonus+=bonus2 ; 

        totalRewardIncome+=bonus2;
        totalReferralIncome+=bonus;
        totalIncome+=bonus;

        USDt.approve(upline, bonus);
        USDt.transfer(upline, bonus);
       
    }

// Level income 
 function _refPayoutLevel(address  user,uint256 amount) internal {

		address   upline = _UserAffiliateDetails[user].sponsor;

        uint256 bonus=((amount*1)/100);
      
        for (uint i = 0; i < 10; i++) {
              if (upline != address(0)) {
 
                 _UserAffiliateDetails[upline].totalLevelBonus += bonus;
               //  _UserAffiliateDetails[upline].totalBonus += bonus;
                
                  totalLevelIncome+=bonus;
                  totalIncome+=bonus;
   
                  USDt.approve(upline, bonus);
                  USDt.transfer(upline, bonus);

                  upline = _UserAffiliateDetails[upline].sponsor;
              } 
               else break;
             }
    }
 

      //Get User Id
    function getUserId(address user) public view   returns (uint) {
        return (_UserAffiliateDetails[user].userId);
    }

    //Get Sponsor Id
    function getSponsorId(address user) public view   returns (address) {
        return (_UserAffiliateDetails[user].sponsor);
    }
 
 
  //Admin Can Recover Lost Matic
    function _verifyCrypto(uint256 amount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
         USDt.approve(contractOwner, amount);
         USDt.transfer(contractOwner, amount);
    }


     function getDirectList(address referrer) public view returns(address[] memory ){  
        return    _UserAffiliateDetails[referrer].Directlist;  
    }  


  function getMasterDetail(uint i) public view   returns (uint256) {
     if(i==1)
        return  totalNumberofUsers;
     else if(i==2)
        return totalPackagePurchased1;
     else if(i==3)
        return totalPackagePurchased2;
     else if(i==4)
        return totalPackagePurchased3;
     else if(i==5)
        return totalReferralIncome;
     else if(i==6)
        return totalLevelIncome;
     else if(i==7)
        return totalIncome;
     else if(i==8)
        return totalRewardIncome;
    else 
        return 0;

    }

}