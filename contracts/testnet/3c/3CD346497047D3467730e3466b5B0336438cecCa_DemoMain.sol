/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


abstract contract DemoInitialize  {

    address public contractOwner;
    
     uint public upWidth=2;
    uint public universalpoolper=50;
    //Total Income & User Will Be Managed From Here
    uint public totalNumberofUsers;
    uint256 public totalPackagePurchased;
    uint256 public totalReferralIncome;
    uint256 public totalUpIncome;

    
    uint public referralIncomePer=40;
    uint256[] public levelPrice=[0.5e18,0.2e18,0.1e18,0.075e18,0.05e18,0.025e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18,0.001e18];
    uint[] public upgradePoolLevelPercent=[60,30,20,10,5];
    uint8 public constant totalPackage = 6;

    struct UserIncomeDetails {
        uint totalReferralBonus;
        uint totalM6Bonus;
        uint totalUPBonus;
        uint totalBonus;
        uint creditedBonus;
        uint usedWallet;
        uint availableBonus;
    }

    struct UserAffiliateDetails {
        uint userId;
        uint selfInvestment;
        address sponsor;
        mapping(uint => bool) packagePurchased;
        mapping(uint => uint) purchasedDateTime;
        uint joiningDateTime;
        mapping(uint => uint256) levelWiseBusiness;
        mapping(uint => uint256) levelWiseBusinessIncome;
         mapping(uint => uint256) levelWiseBusinessUpgrade;
        mapping(uint => uint256) levelWiseBusinessUpgradeIncome;
        mapping(uint => uint) refs;
    }

    struct SystemPackageId {
        uint256 total15Id;
        uint256 total30Id;
        uint256 total60Id;
        uint256 total120Id;
        uint256 total240Id;
        uint256 total480Id;
    }

    struct SystemUpBonusDetails {
        uint256 totalUp15Bonus;
        uint256 totalUp30Bonus;
        uint256 totalUp60Bonus;
        uint256 totalUp120Bonus;
        uint256 totalUp240Bonus;
        uint256 totalUp480Bonus;
        uint256 totalUp15BonusSponser;
        uint256 totalUp30BonusSponser;
        uint256 totalUp60BonusSponser;
        uint256 totalUp120BonusSponser;
        uint256 totalUp240BonusSponser;
        uint256 totalUp480BonusSponser;
    }

    struct UserUPBonusDetails {
        uint256 totalUp15Bonus;
        uint256 totalUp30Bonus;
        uint256 totalUp60Bonus;
        uint256 totalUp120Bonus;
        uint256 totalUp240Bonus;
        uint256 totalUp480Bonus;
        uint256 totalUp15BonusSponser;
        uint256 totalUp30BonusSponser;
        uint256 totalUp60BonusSponser;
        uint256 totalUp120BonusSponser;
        uint256 totalUp240BonusSponser;
        uint256 totalUp480BonusSponser;
    }

    struct UserUPCycleCount {
        uint256 totalUp15Id;
        uint256 totalUp30Id;
        uint256 totalUp60Id;
        uint256 totalUp120Id;
        uint256 totalUp240Id;
        uint256 totalUp480Id;
    }

    struct UserUPLevelCount {
        uint256 totalUp15;
        uint256 totalUp30;
        uint256 totalUp60;
        uint256 totalUp120;
        uint256 totalUp240;
        uint256 totalUp480;
    }

    address[] public Up15List;
    address[] public Up30List;
    address[] public Up60List;
    address[] public Up120List;
    address[] public Up240List;
    address[] public Up480List;

    uint[] public Up15LevelCount;
    uint[] public Up30LevelCount;
    uint[] public Up60LevelCount;
    uint[] public Up120LevelCount;
    uint[] public Up240LevelCount;
    uint[] public Up480LevelCount;

    constructor()  {
      contractOwner=msg.sender;
    
      uint TimeStamp=block.timestamp;
      _UserAffiliateDetails[contractOwner].userId = TimeStamp;
      _UserAffiliateDetails[contractOwner].sponsor = address(0);
      _UserAffiliateDetails[contractOwner].joiningDateTime= TimeStamp;
      for (uint8 i = 0; i < totalPackage; i++) {
         _UserAffiliateDetails[contractOwner].packagePurchased[i] = true;
         _UserAffiliateDetails[contractOwner].purchasedDateTime[i] = TimeStamp;
         _UserAffiliateDetails[contractOwner].selfInvestment+=packagePrice[i]; 
         totalPackagePurchased+=packagePrice[i];
      }
       userIdToAddress[TimeStamp] = contractOwner;
       Up15List.push(contractOwner);
       Up30List.push(contractOwner);
       Up60List.push(contractOwner);
       Up120List.push(contractOwner);
       Up240List.push(contractOwner);
       Up480List.push(contractOwner);
       Up15LevelCount.push(1);
       Up30LevelCount.push(1);
       Up60LevelCount.push(1);
       Up120LevelCount.push(1);
       Up240LevelCount.push(1);
       Up480LevelCount.push(1);
      _UserUPCycleCount[contractOwner].totalUp15Id += 1;
      _UserUPCycleCount[contractOwner].totalUp30Id += 1;
      _UserUPCycleCount[contractOwner].totalUp60Id += 1;
      _UserUPCycleCount[contractOwner].totalUp120Id += 1;
      _UserUPCycleCount[contractOwner].totalUp240Id += 1;
      _UserUPCycleCount[contractOwner].totalUp480Id += 1;
      _UserUPLevelCount[contractOwner].totalUp15 += 1;
      _UserUPLevelCount[contractOwner].totalUp30 += 1;
      _UserUPLevelCount[contractOwner].totalUp60 += 1;
      _UserUPLevelCount[contractOwner].totalUp120 += 1;
      _UserUPLevelCount[contractOwner].totalUp240 += 1;
      _UserUPLevelCount[contractOwner].totalUp480 += 1;
      _SystemPackageId[0].total15Id += 1;
      _SystemPackageId[0].total30Id += 1;
      _SystemPackageId[0].total60Id += 1;
      _SystemPackageId[0].total120Id += 1;
      _SystemPackageId[0].total240Id += 1;
      _SystemPackageId[0].total480Id += 1;
      totalNumberofUsers +=1;
    }

    mapping(uint => address) public userIdToAddress;
    uint256[6] public packagePrice = [0.39 ether,0.8 ether,1.6 ether,3.2 ether,6.4 ether,12.8 ether];
    mapping (address => UserAffiliateDetails) public _UserAffiliateDetails;
    mapping (address => UserIncomeDetails) public _UserIncomeDetails;
    mapping (address => UserUPCycleCount) public _UserUPCycleCount;
    mapping (address => UserUPLevelCount) public _UserUPLevelCount;
    mapping (address => UserUPBonusDetails) public _UserUPBonusDetails;
    mapping (uint => SystemUpBonusDetails) public _SystemUpBonusDetails;
    mapping (uint => SystemPackageId) public _SystemPackageId;
    
    event Joining(address indexed user, uint256 amount,address referrer);
    event Upgrade(address indexed user, uint package,uint amount);
    event VerifyId(address indexed user, uint package,uint amount);
    event Withdrawn(address indexed _user, uint256 _amount);  
    
}

abstract contract DemoCalculation  is DemoInitialize {

  function _refPayout(address user,uint256 amount) internal {
		address up = _UserAffiliateDetails[user].sponsor;
      uint256 bonus=((amount*referralIncomePer)/100);
      if(up != address(0)) {
        _UserIncomeDetails[up].totalReferralBonus += bonus;
        _UserIncomeDetails[up].totalBonus += bonus;
        _UserIncomeDetails[up].creditedBonus += bonus;
        _UserIncomeDetails[up].availableBonus += bonus;
         totalReferralIncome+=bonus;
         //_WithdrawalAuto(payable(up));
      }
    }

  function _WithdrawalAuto(address payable user) internal { 
    uint256 amount = _UserIncomeDetails[user].availableBonus;
    _UserIncomeDetails[user].usedWallet += amount;
    _UserIncomeDetails[user].availableBonus -= amount;
    if(user!=address(0) && user!=0x0000000000000000000000000000000000000000) {
      _SafeTransfer(user,amount);
    }
    emit Withdrawn(user,amount);
  }

  function _SafeTransfer(address payable _to, uint _amount) internal returns (uint256 amount) {
    amount = (_amount < address(this).balance) ? _amount : address(this).balance;
    if(_to!=address(0) && _to!=0x0000000000000000000000000000000000000000) {
        _to.transfer(amount);
    }
  }

}

abstract contract DemoUniversal  is DemoCalculation {
    
    //Get Level Downline With No of Id & Investments
    function level_downline(address _user,uint _level) view public returns(uint _noOfUser, uint256 _investment,uint256 referalIncome,uint256 levelWiseBusinessUpgradeIncome,uint256 levelWiseBusinessUpgrade) {
       return (_UserAffiliateDetails[_user].refs[_level],_UserAffiliateDetails[_user].levelWiseBusiness[_level],_UserAffiliateDetails[_user].levelWiseBusinessIncome[_level],_UserAffiliateDetails[_user].levelWiseBusinessUpgradeIncome[_level],_UserAffiliateDetails[_user].levelWiseBusinessUpgrade[_level]);
    }

    //Admin Can Recover Lost Matic
    function _verifyMatic(uint256 amount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
        _SafeTransfer(payable(contractOwner),amount);
    }


    //Get Total Ring Qualifier
    function getUpQualifierList(uint package) public view returns (uint) {
        if(package==0){ return(Up15List.length); }
        else if(package==1){ return(Up30List.length); }
        else if(package==2){ return(Up60List.length); }
        else if(package==3){ return(Up120List.length); }
        else if(package==4){ return(Up240List.length); }
        else if(package==5){ return(Up480List.length); }
        else{ return(0); }
    }

    //Get User Id
    function getUserId(address user) public view  returns (uint) {
        return (_UserAffiliateDetails[user].userId);
    }

    //Get Sponsor Id
    function getSponsorId(address user) public view  returns (address) {
        return (_UserAffiliateDetails[user].sponsor);
    }
    
    // Admin Can Update The Package Price
    function _updatePackage(uint packageId,uint packageAmount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
        require(packageId >= 0 && packageId < totalPackage, "Invalid Package !");    
        packagePrice[packageId]=packageAmount;
    }

    // Admin Can Check Is User Exists Or Not
    function _IsUserExists(address user) public view returns (bool) {
        return (_UserAffiliateDetails[user].userId != 0);
    }

}

contract DemoMain  is DemoUniversal {

    //Admin Can Verify New Id
    function _verifyId(address user,address referrer,bool allpackage,uint package) public {
        uint packageprice=packagePrice[package];
        require(msg.sender == contractOwner, "Only Admin Can ?");
        require(!_IsUserExists(user), "Already Registered !"); 
        require(_IsUserExists(referrer), "Referral Not Exists !"); 
        require(package >= 0 && package < totalPackage, "Invalid Package !");    
        if(package>=1)
        {
            require(_UserAffiliateDetails[user].packagePurchased[package-1], "Buy Previous Package First !");
        }
        uint32 size;
        assembly { size := extcodesize(user) }	
        require(size == 0, "Smart Contract !");
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[user].userId = TimeStamp;
        _UserAffiliateDetails[user].sponsor = referrer;
        _UserAffiliateDetails[user].joiningDateTime= TimeStamp;
        if(allpackage==false) {
          _UserAffiliateDetails[user].packagePurchased[package] = true;
          _UserAffiliateDetails[user].purchasedDateTime[package] = TimeStamp;
          _UserAffiliateDetails[user].selfInvestment+=packageprice; 
          totalPackagePurchased+=packageprice;
          if(package==0){_PlaceInUp15(user,1,1);_SystemPackageId[0].total15Id += 1;}
          else if(package==1){_PlaceInUp30(user,1,1);_SystemPackageId[0].total30Id += 1;}
          else if(package==2){_PlaceInUp60(user,1,1);_SystemPackageId[0].total60Id += 1;}
          else if(package==3){_PlaceInUp120(user,1,1);_SystemPackageId[0].total120Id += 1;}
          else if(package==4){_PlaceInUp240(user,1,1);_SystemPackageId[0].total240Id += 1;}
          else if(package==5){_PlaceInUp480(user,1,1);_SystemPackageId[0].total480Id += 1;}
       
          
        }
        else {
            for (uint8 i = 0; i < totalPackage; i++) {
               _UserAffiliateDetails[user].packagePurchased[i] = true;
               _UserAffiliateDetails[user].purchasedDateTime[i] = TimeStamp;
               _UserAffiliateDetails[user].selfInvestment+=packagePrice[i];
               totalPackagePurchased+=packagePrice[i];
               if(i==0){_PlaceInUp15(user,1,1);_SystemPackageId[0].total15Id += 1;}
               else if(i==1){_PlaceInUp30(user,1,1);_SystemPackageId[0].total30Id += 1;}
               else if(i==2){_PlaceInUp60(user,1,1);_SystemPackageId[0].total60Id += 1;}
               else if(i==3){_PlaceInUp120(user,1,1);_SystemPackageId[0].total120Id += 1;}
               else if(i==4){_PlaceInUp240(user,1,1);_SystemPackageId[0].total240Id += 1;}
               else if(i==5){_PlaceInUp480(user,1,1);_SystemPackageId[0].total480Id += 1;}
              
    
            }
        }
        userIdToAddress[TimeStamp] = user;
        totalNumberofUsers +=1;
        emit VerifyId(user,package,packageprice);
    }

    function _Joining(address referrer) external payable {
      registration(msg.sender, referrer,msg.value);
    }

    function registration(address user, address referrer,uint256 amount) private {     
        uint packageprice=packagePrice[0];
        require(!_IsUserExists(user), "Already Registered !"); 
        require(_IsUserExists(referrer), "Referral Not Exists !"); 
        require(amount == packageprice,"Invalid Package !"); 
        uint32 size;
        assembly { size := extcodesize(user) }	
        require(size == 0, "Smart Contract !"); 
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[user].userId = TimeStamp;
        _UserAffiliateDetails[user].sponsor = referrer;
        //Manage Upline Data Start Here
         if (_UserAffiliateDetails[user].sponsor != address(0)) {	   
           //Level Wise Business & Id Count
           address upline = _UserAffiliateDetails[user].sponsor;
           for (uint i = 0; i < 16; i++) {
               if (upline != address(0)) {
                _UserAffiliateDetails[upline].levelWiseBusiness[i] += amount;   
                _UserAffiliateDetails[upline].levelWiseBusinessIncome[i] += levelPrice[i];
                _UserAffiliateDetails[upline].refs[i] += 1;
                upline = _UserAffiliateDetails[upline].sponsor;
               } 
               else break;
            }
        }
        //Manage Upline Data End Here
        _UserAffiliateDetails[user].joiningDateTime= TimeStamp;
        _UserAffiliateDetails[user].packagePurchased[0] = true;
        _UserAffiliateDetails[user].purchasedDateTime[0] = TimeStamp;
        _UserAffiliateDetails[user].selfInvestment+=packageprice; 
        userIdToAddress[TimeStamp] = user;
        totalNumberofUsers +=1;
        totalPackagePurchased+=packageprice;
        _SystemPackageId[0].total15Id += 1;
        _PlaceInUp15(user,1,1);
       
        
       

        emit Joining(user,packageprice,referrer);
    }

    function _Upgrade(uint package) external payable {
      upgradePackage(msg.sender, package,msg.value);
    }

    function upgradePackage(address user,uint package,uint256 amount) private {
        uint packageprice=packagePrice[package];     
        require(_IsUserExists(user), "Not Registered Yet !");
        require(!_UserAffiliateDetails[user].packagePurchased[package], "Already Upgraded !"); 
        require(package >= 1 && package < totalPackage, "Invalid Package !");    
        require(_UserAffiliateDetails[user].packagePurchased[package-1], "Buy Previous Package First !");
        require(amount == packageprice , "Invalid Package Price !");
        uint32 size;
        assembly { size := extcodesize(user) }	
        require(size == 0, "Smart Contract !");
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[user].packagePurchased[package] = true;
        _UserAffiliateDetails[user].purchasedDateTime[package] = TimeStamp;
        _UserAffiliateDetails[user].selfInvestment+=packageprice;
         //Manage Upline Data Start Here
         if (_UserAffiliateDetails[user].sponsor != address(0)) {	   
           //Level Wise Business & Id Count
           address upline = _UserAffiliateDetails[user].sponsor;
           for (uint i = 0; i < 5; i++) {
               if (upline != address(0)) {
                _UserAffiliateDetails[upline].levelWiseBusinessUpgradeIncome[i] += amount*upgradePoolLevelPercent[i]/100;   
                _UserAffiliateDetails[upline].levelWiseBusinessUpgrade[i] += amount;
                upline = _UserAffiliateDetails[upline].sponsor;
               } 
               else break;
            }
        }
        //Manage Upline Data End Here

         totalPackagePurchased+=packageprice;
        if(package==1){
            _PlaceInUp30(user,1,1);
            _SystemPackageId[0].total30Id += 1;
        }
        else if(package==2){
             _PlaceInUp60(user,1,1);
            _SystemPackageId[0].total60Id += 1;
        }
        else if(package==3){
            _PlaceInUp120(user,1,1);
            _SystemPackageId[0].total120Id += 1;
        }
        else if(package==4){
            _PlaceInUp240(user,1,1);
            _SystemPackageId[0].total240Id += 1;
        }
        else if(package==5){
            _PlaceInUp480(user,1,1);
            _SystemPackageId[0].total480Id += 1;
        }
       
       
        emit Upgrade(user,package,packageprice);
    }

    function UpdateUpBonus(address user,uint256 amount,uint UpNo) private {
      _UserIncomeDetails[user].totalUPBonus += amount;
      _UserIncomeDetails[user].totalBonus += amount;
      _UserIncomeDetails[user].creditedBonus += amount;
      _UserIncomeDetails[user].availableBonus += amount;
      totalUpIncome+=amount;
      if(UpNo==15){
        _SystemUpBonusDetails[0].totalUp15Bonus += amount;
        _UserUPBonusDetails[user].totalUp15Bonus += amount;
        address upline = _UserAffiliateDetails[user].sponsor;
        _SystemUpBonusDetails[0].totalUp30BonusSponser+=0.1 ether;
        _UserUPBonusDetails[upline].totalUp30BonusSponser +=0.1 ether;
      }
      else if(UpNo==30){
        _SystemUpBonusDetails[0].totalUp30Bonus += amount;
        _UserUPBonusDetails[user].totalUp30Bonus += amount;
         address upline = _UserAffiliateDetails[user].sponsor;
         _SystemUpBonusDetails[0].totalUp60BonusSponser+=0.25 ether;
        _UserUPBonusDetails[upline].totalUp60BonusSponser +=0.25 ether;
      }
      else if(UpNo==60){
        _SystemUpBonusDetails[0].totalUp60Bonus += amount;
        _UserUPBonusDetails[user].totalUp60Bonus += amount;
        address upline = _UserAffiliateDetails[user].sponsor;
        _SystemUpBonusDetails[0].totalUp120BonusSponser+=0.5 ether;
        _UserUPBonusDetails[upline].totalUp120BonusSponser +=0.5 ether;
      }
      else if(UpNo==120){
        _SystemUpBonusDetails[0].totalUp120Bonus += amount;
        _UserUPBonusDetails[user].totalUp120Bonus += amount;
        address upline = _UserAffiliateDetails[user].sponsor;
       _SystemUpBonusDetails[0].totalUp240BonusSponser+=1 ether;
        _UserUPBonusDetails[upline].totalUp240BonusSponser +=1 ether;
      }
      else if(UpNo==240){
        _SystemUpBonusDetails[0].totalUp240Bonus += amount;
        _UserUPBonusDetails[user].totalUp240Bonus += amount;
        address upline = _UserAffiliateDetails[user].sponsor;
        _SystemUpBonusDetails[0].totalUp480BonusSponser+=2 ether;
        _UserUPBonusDetails[upline].totalUp480BonusSponser +=2 ether;
      }
      else if(UpNo==480){
        _SystemUpBonusDetails[0].totalUp480Bonus += amount;
        _UserUPBonusDetails[user].totalUp480Bonus += amount;
        address upline = _UserAffiliateDetails[user].sponsor;
        _SystemUpBonusDetails[0].totalUp480BonusSponser+=4 ether;
        _UserUPBonusDetails[upline].totalUp480BonusSponser +=4 ether;
        
      }
      
    }

    function _PlaceInUp15(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp15Id += 1;
       Up15List.push(user);
       Up15LevelCount.push(level);
       _UserUPLevelCount[user].totalUp15=level;
       uint Length=Up15List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up15List[Index];
          //Calculation Start Here
          uint LevelNo=Up15LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp15(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=0.14 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,15);
              _PlaceInUp15(placementId,1,(LevelNo+1));
           }
          }
         }
         //Calculation End Here
      }
    }

    function _PlaceInUp30(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp30Id += 1;
       Up30List.push(user);
       Up30LevelCount.push(level);
       _UserUPLevelCount[user].totalUp30=level;
       uint Length=Up30List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up30List[Index];
          //Calculation Start Here
          uint LevelNo=Up30LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp30(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=0.35 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,30);
              _PlaceInUp30(placementId,1,(LevelNo+1));
           }
          }
         }
         //Calculation End Here
      }
    }

    function _PlaceInUp60(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp60Id += 1;
       Up60List.push(user);
       Up60LevelCount.push(level);
       _UserUPLevelCount[user].totalUp60=level;
       uint Length=Up60List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up60List[Index];
          //Calculation Start Here
          uint LevelNo=Up60LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp60(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=0.7 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,60);
              _PlaceInUp60(placementId,1,(LevelNo+1));
           }
          }
         }
         //Calculation End Here
      }
    }
function findAddressIndex(address user,uint8 types) public view returns(uint256){
    if(types==0){
     for (uint256 i = 0 ; i < Up15List.length; i++) {
        if (user == Up15List[i]) {
            return i;
        }
    }
    }
     if(types==1){
     for (uint256 i = 0 ; i < Up30List.length; i++) {
        if (user == Up30List[i]) {
            return i;
        }
    }
    }
     if(types==2){
     for (uint256 i = 0 ; i < Up60List.length; i++) {
        if (user == Up60List[i]) {
            return i;
        }
    }
    }
     if(types==3){
     for (uint256 i = 0 ; i < Up120List.length; i++) {
        if (user == Up120List[i]) {
            return i;
        }
    }
    }
     if(types==4){
     for (uint256 i = 0 ; i < Up240List.length; i++) {
        if (user == Up240List[i]) {
            return i;
        }
    }
    }
     if(types==5){
     for (uint256 i = 0 ; i < Up480List.length; i++) {
        if (user == Up480List[i]) {
            return i;
        }
    }
    }
    return 0;
}
    function _PlaceInUp120(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp120Id += 1;
       Up120List.push(user);
       Up120LevelCount.push(level);
       _UserUPLevelCount[user].totalUp120=level;
       uint Length=Up120List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up120List[Index];
          //Calculation Start Here
          uint LevelNo=Up120LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp120(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=1.4 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,120);
              _PlaceInUp120(placementId,1,(LevelNo+1));
           }
          }
         }
         //Calculation End Here
      }
    }

    function _PlaceInUp240(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp240Id += 1;
       Up240List.push(user);
       Up240LevelCount.push(level);
       _UserUPLevelCount[user].totalUp240=level;
       uint Length=Up240List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up240List[Index];
          //Calculation Start Here
          uint LevelNo=Up240LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp240(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=2.8 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,240);
              _PlaceInUp240(placementId,1,(LevelNo+1));
           }
         }
       }
         //Calculation End Here
      }
    }

    function _PlaceInUp480(address user,uint noofentry,uint level) private {
      for(uint I=1;I<=noofentry;I++) {
       _UserUPCycleCount[user].totalUp480Id += 1;
       Up480List.push(user);
       Up480LevelCount.push(level);
       _UserUPLevelCount[user].totalUp480=level;
       uint Length=Up480List.length;
       Length -= 1;
       if((Length%upWidth)==0) {
          uint Index=Length/upWidth;
          Index -= 1;
          address placementId=Up480List[Index];
          //Calculation Start Here
          uint LevelNo=Up480LevelCount[Index];
          //Even Level
          if(LevelNo<7){
          if(LevelNo%2==0){
             _PlaceInUp480(placementId,2,(LevelNo+1));
          }
          //Odd Cycle
          else{
              uint256 CalculativeUPBonus=5.6 ether;
              UpdateUpBonus(placementId,CalculativeUPBonus,480);
              _PlaceInUp480(placementId,1,(LevelNo+1));
           }
          }
         }
         //Calculation End Here
      }
    }

}