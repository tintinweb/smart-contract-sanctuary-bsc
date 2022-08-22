/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity 0.5.9; /*





-------------------------------------------------------------------
 Copyright (c) 2020 onwards Billion Money Inc. ( https://mmmglobal.live )
-------------------------------------------------------------------
 */


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;
    address defaultAddress;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
       
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


//*******************************************************************//
//------------------        MAIN contract         -------------------//
//*******************************************************************//

contract MMM is owned {

   // Some Administrative Parameter
   
    uint64 public ph_lockDays = 15 days;
    uint64 public maxgrowthDays =30 days;
	uint64 public primaryTime= 2 days;
	uint64 public secondaryTime= 10 days;
	uint64 public userCapTime= 24 hours;
    uint64 public minPh = 50000000 ;
    uint64 public maxPh = 10000000000 ;
	uint8 public dailyGrowth = 1 ;
	uint8 public orderPercent;
	uint lastOrderID=1;
    address public defaultAddress ;   //this ref address will be used if user joins without any ref ID
	uint32[] guiderLevelBonus;
	uint32[] referralBonus;
	uint referralState=1;
	uint leaderBonusDist=0;
	uint maxOrder = 5;
    
	struct userInfo {
        bool joined;
        address referral;
		uint32 capLimit;
		uint32 remainCapLimit;
		uint64 renewCapTime;
    }
	
	mapping (address => userInfo) public userInfos;

	
	
    
	struct phInfo {
        uint  orderID;
		address phAddress;
		uint64 orderValue;
		uint32 paidValue;
		uint64 orderTime;
    }
    
    mapping (uint => phInfo) public phInfos;
	
	struct ghInfo {
	    uint[] orderID;
		uint64 orderValue;
		
    }
	
    mapping (address => ghInfo) public ghInfos;
	
	struct bonusInfo {
	    
        uint32 totlReferralBonusAv;
		uint32 totlReferralBonus;
		uint32 totlGuiderBonus;
		uint32 totlGuiderBonusAv;
    }
	
	mapping (address => bonusInfo) public bounsInfos;
    
	uint32 internal totalPaidSystem;
    uint8 systemDistPart=5;

    constructor(address _default) public{
        
        defaultAddress=_default;
        
    }
	
	// Only Owner function*****
	
	
	function setOrderPercent(uint8 _percent) public onlyOwner returns(bool){
        
        orderPercent=_percent;
        
    }
    
	function sysTimesPrams(uint64 _primaryTime ,uint64 _secondaryTime, uint64 _phLockdays ,uint64 _maxgrowthdays) public onlyOwner returns(bool) {
		
		primaryTime= _primaryTime;
		secondaryTime=_secondaryTime;
		ph_lockDays= _phLockdays;
		maxgrowthDays=_maxgrowthdays;
// 		capRenewtime= _capRenewHours;
		
		
		return true;
	}
	
	function sysLimits(uint64 minPhAmount ,uint64 maxPhAmount, uint8 _dailyGrowth,uint8 _donationPart) public onlyOwner returns(bool) {
		
		minPh= minPhAmount;
		maxPh= maxPhAmount;
		dailyGrowth=_dailyGrowth;
		systemDistPart= _donationPart;
		
		
		return true;
	}

	
	function barredUser(address _user, bool _allow) public onlySigner returns(bool) {
		require(userInfos[msg.sender].joined==true, "User is not exist");
		userInfos[_user].joined=_allow;

		return true;
	}
	
    
	function systemDistribution(uint32 _amount) internal {
	
		uint32 amount = _amount*systemDistPart/100;
		totalPaidSystem +=amount;
	
	}
	
    function () payable external {
        //regUser(defaultAddress);
    }
	
	
// 	event paidForReferralBonusEv(address _user ,uint32 _amount);
// 	function payForReferralBonus(address _referrerAdresss) internal returns(bool){
	
// 		uint32 Amount = guiderLevelBonus[0];
//         totlReferralBonus[_referrerAdresss] += Amount;
//         totlReferralBonusAv[_referrerAdresss] += Amount;
// 		emit paidForReferralBonusEv(_referrerAdresss, Amount);
	
// 	    return true;
// 	}
	
	
	// User function ****

    event regUserEv(address _user, address referralAddress);
    function regUser(address referralAddress) public returns(bool) 
    {
        
        require(defaultAddress!=address(0),"please set defaultAddress first");
        if(referralAddress==address(0)){
            
            referralAddress=defaultAddress;
        }
        require(userInfos[msg.sender].joined == false, "alredy registered");
        require(userInfos[referralAddress].joined == true || referralAddress==defaultAddress, "invalid referral address");
        
        
        userInfos[msg.sender].joined=true;
        userInfos[msg.sender].referral=referralAddress;
        
        emit regUserEv(msg.sender, referralAddress);
        return true;
    }
    
	
	event provideHelpEv(uint orderID,address user,uint64 amount);
    function phHelp(uint64 amount) public  returns(bool) 
    {
        require(ghInfos[msg.sender].orderID.length<=maxOrder,"you reached max order limit");
		require(userInfos[msg.sender].joined==true, "please registered first");
		require(amount>=minPh && amount<=maxPh,"Invalid Amount");
        require(userInfos[msg.sender].capLimit <= amount , "This is not equal to the last amount");
		
        
        phInfo memory PhInfo;
            PhInfo = phInfo({
			orderID:lastOrderID,
			phAddress:msg.sender,
			orderValue:amount,
			paidValue:0,
			orderTime:uint64(now)
        });
		
		
        phInfos[lastOrderID] = PhInfo;
		userInfos[msg.sender].capLimit=uint32(amount);
		userInfos[msg.sender].renewCapTime=uint64(now)+userCapTime;
		emit provideHelpEv(lastOrderID,msg.sender,amount); 
		lastOrderID++;
		
		return true;
    }
	
	event paidPrimaryEv(uint oderID, address user, uint paidAmount);
	function paid1(uint64 orderID) public payable returns(bool)
	{	
		uint32 paidPrimary = uint32 (phInfos[orderID].orderValue*orderPercent/100);
        require(orderPercent>0,'please set Order Percent first');
		require( phInfos[orderID].phAddress== msg.sender,"user is not mathed !");
		require(phInfos[orderID].orderTime+primaryTime <now,"exceed  the order paid time");
		require(msg.value==paidPrimary,"you don't have sufficient fund ");
		phInfos[orderID].paidValue=paidPrimary;
		
		
		emit paidPrimaryEv(orderID,msg.sender,msg.value);
		return true;
		
	}
	
	event paidSecondaryEv(uint oderID, address user, uint paidAmount);
	function paid2(uint64 orderID) public payable returns(bool)
	{
	    
	    // if user is already paid then no need for further execution 
	    require(phInfos[orderID].paidValue!=phInfos[orderID].orderValue,"Order is 100% paid");
		uint paidSecondary = phInfos[orderID].orderValue-phInfos[orderID].paidValue;
		require( phInfos[orderID].phAddress== msg.sender,"user is not matched !");
		
		require(phInfos[orderID].paidValue !=0,"You paid primary amount first");
		require(phInfos[orderID].orderTime+secondaryTime<now,"your secondary order time is not come");
		require(msg.value==paidSecondary,"you don't have sufficient fund ");
		phInfos[orderID].paidValue= uint32(phInfos[orderID].orderValue);
		
		// check all eligible order id  of gh info
	    
	    ghInfos[msg.sender].orderValue+=phInfos[orderID].paidValue;
		ghInfos[msg.sender].orderID.push(orderID);
		emit paidSecondaryEv(orderID,msg.sender,msg.value);
		return true;
	}
	
	event getHelpEv(address _user, uint32 _amount);
    function ghHelp() public returns(bool) 
    {
        //ghinfo order value should not be zero 
        // after transfer set ordervalue as zero
        require(ghInfos[msg.sender].orderValue>0,"you don't have any running order");
        require(userInfos[msg.sender].joined == true, "Get help is locked");
		
		// if captime is expire, so renew the captime and caplimit
		
		if(userInfos[msg.sender].renewCapTime<now){
			
			userInfos[msg.sender].renewCapTime = uint64(now)+userCapTime;
			userInfos[msg.sender].remainCapLimit= userInfos[msg.sender].capLimit;
		}
		
        require(userInfos[msg.sender].remainCapLimit > 0, "today cap limit is exhausted");
	
        //get all order avBonus 
        uint totalOrderAvBonus=0;
        
        for(uint i=0;i<ghInfos[msg.sender].orderID.length;i++){
            
            totalOrderAvBonus+=totalAvBonus(ghInfos[msg.sender].orderID[i]);
            
        }
	
        // transfer all bonus amount to msg.sender (caller)
		if(totalOrderAvBonus > 0){
		    
		    msg.sender.transfer(totalOrderAvBonus);
		}

		//reset after sending amount so next time user can't get withdraw with same order id
		//reseting 
	    ghInfos[msg.sender].orderValue = 0;
       
        emit getHelpEv(msg.sender,uint32(totalOrderAvBonus));
        return true;
    }
	function totalAvBonus(uint orderID) public view returns(uint){
		
		uint32 totalGrowth;
		uint current = now-phInfos[orderID].orderTime;
		if(current>= 15 days && current<= maxgrowthDays){
			current = current/ 1 days;
			uint32 growthRate = uint32(phInfos[orderID].orderValue*dailyGrowth/100);
			 totalGrowth = uint32(current*growthRate);
			
		}
		
		uint totalBonus = totalGrowth+bounsInfos[msg.sender].totlGuiderBonusAv+bounsInfos[msg.sender].totlReferralBonusAv;

		return totalBonus;
	}
	
	function mavroGrowth(uint oderID) public view returns(uint){
		
		uint current = now-phInfos[oderID].orderTime;
		if(current>= 1 days && current<= maxgrowthDays){
			current = current/ 1 days;
			uint growthRate = phInfos[oderID].orderValue*dailyGrowth/100;
			uint avGrowth = current*growthRate;
			return avGrowth;
		}
		
		return 0;
		
	}
	
	
// 	function recEth() public payable returns(bool) {

//     // address payable wallet = address(uint160(address(this)));
//     //  wallet.transfer(300);
    
//     address(this).transfer(msg.value);
	    
// 	}
	
// 	function viewContractBalance() public view returns(uint) {
	    
// 	    return address(this).balance;
// 	}

}