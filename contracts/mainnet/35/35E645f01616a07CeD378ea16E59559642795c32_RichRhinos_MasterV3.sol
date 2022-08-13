/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}




interface IBEP20Token
{
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);

}


interface Richv1
{
	
    function getUserAmountOfDeposits(address userAddress) external view returns(uint);
	function getUserDepositInfo(address userAddress, uint256 index) external view returns(uint256, uint256, uint256,uint256);
	function getUseruplineInfo(address userAddress, uint index) external view returns(uint256, uint256, uint256);
    function getUserTotalPASSIVEWithdrawn(address userAddress) external view returns (uint256);
	function getUserTotalPASSIVEWithdrawnMultiplier(address userAddress) external view returns (uint256);
	function getUserTotalWithdrawn(address userAddress) external view returns (uint256);
	function getUserCheckpoint(address userAddress) external view returns(uint256);
	function getUserReferrer(address userAddress) external view returns(address);
	function getUserTotalReferrals(address userAddress) external view returns(uint256); 
	function getUserReferralBonus(address userAddress) external view returns(uint256); 
	function getUserReferralTotalBonus(address userAddress) external view returns(uint256);
    function getDownlineRef(address senderAddress, uint dataId) external view returns (address,uint);

}

contract RichRhinos_MasterV3 {
	AggregatorV3Interface internal priceFeed;
	IBEP20Token public rewardToken;

    Richv1 public richv1;

	using SafeMath for uint256;
	using SafeMath for uint;

	uint256  public INVEST_MIN_AMOUNT; //usd price
	uint256 public MIN_WITHDRAW ;
	uint256[] public PASSIVE_PERCENTS ;
	uint256[] public PASSIVE_MULTIPLIER_PERCENTS ;
    uint256 public DEVELOPMENT_FEE;
    uint256 public OWNER_FEE ;
	uint256 public ADMIN_FEE ;
	uint256 public MARKETING_FEE;


	uint256 public totalTokenDistribute;

	uint256  public PERCENTS_DIVIDER;
	uint256  public TIME_STEP;
	uint256  public LAUNCH_DURATION_BEFORE_POST;
	uint256  public WITHDRAW_DURATION_STEP;

	uint256 public totalInvested;
	uint256 public totalRefBonus;
	uint256 public totalUsers;
    uint256 public totalWithdrawn;

    uint256 public contractLaunchTime;
	uint[30] public ref_bonuses; // 10%,5%,2%,1%(4-10), 0.5%(11-30);
	uint[30] public ref_bonuses_after_90_days; // 8%,4%,1%(3-10), 0.75%(11-30);
    uint[30] public requiredDirect;
	
	
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
        uint256 percent;
		uint256 amount;
		uint256 start;
        uint256 lastdate;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 level;
		uint256 bonus;
		uint256 totalBonus;
		uint256 PASSIVEincome;
		uint256 withdrawn;
		uint256 withdrawnPASSIVE;
		uint256 withdrawnPASSIVE_MULTIPLIER;
        uint256 TokenRecieved;
		uint256 TokenWithdrawn;
		uint256 AvailableForWithdraw;
		bool PrePost;
		uint256 TokenWithdrawnCheckpoint;
	}
	
	mapping (address => User) public users;

	mapping (address => uint[30]) public refs;
	mapping (address => uint[30]) public refsBusiness;
	mapping (address => uint[30]) public refsBonus;


	bool public started;
	address payable public developmentWallet;
    address payable public ownerWallet;
	address payable public adminWallet;
	address payable public marketingWallet;
    address payable public crWallet;
    bool private IsInitinalized;
    bool private ISupdated;


	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 percent, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event PASSIVEIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	 function initinalize(IBEP20Token _rewardToken, Richv1 _address, address payable wallet, address payable owner, address payable marketing, address payable _crWallet) public {
        require (IsInitinalized == false,"Already Started");
		require(!isContract(wallet));
        richv1 = _address;
		rewardToken = _rewardToken;
		developmentWallet = wallet;
		ownerWallet = owner;
		adminWallet = owner;
		marketingWallet = marketing;
        crWallet = _crWallet;
        contractLaunchTime = block.timestamp;       
		priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        INVEST_MIN_AMOUNT = 50*1e8;
        MIN_WITHDRAW = 0.05 ether;
        PASSIVE_PERCENTS 	= [1800, 1800, 1800, 1200, 1200, 1200, 1200, 1200, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 800, 800, 800, 800, 800, 800, 800, 800, 800, 800];
        PASSIVE_MULTIPLIER_PERCENTS = [500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100];
        DEVELOPMENT_FEE = 1000;
        OWNER_FEE 	= 4000;
        ADMIN_FEE 	= 500;
        MARKETING_FEE 	= 300;
        PERCENTS_DIVIDER = 10000;
        TIME_STEP = 1 days;
        LAUNCH_DURATION_BEFORE_POST = 90 days;
        WITHDRAW_DURATION_STEP = 30 days;
        ref_bonuses = [1000,500,200,100,100,100,100,100,100,100,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50];
        ref_bonuses_after_90_days = [800,400,100,100,100,100,100,100,100,100,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75];
        requiredDirect = [1,1,1,1,1,1,1,1,1,1,6,6,6,6,6,6,6,6,6,6,11,11,11,11,11,11,11,11,11,11];
        IsInitinalized = true;
	}

    function getTokenPrice() public view returns (uint){
		uint token_price;
		if(block.timestamp <= contractLaunchTime + 30 days){
			token_price = 3000000;
		}else if (block.timestamp > contractLaunchTime + 30 days && block.timestamp <= contractLaunchTime + 60 days){
			token_price = 4900000;
		}else if (block.timestamp > contractLaunchTime + 60 days){
			token_price = 6800000;
		}

		return token_price;
	}

	function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18)/usdt*1e8;
		return recieved_bnb;
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
       
        address _customerAddress  = _sender;
        // Level 1
        referralLevel1Address[_customerAddress] = _referredBy;
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
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress] = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
        // Level 3
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress] = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        
        // Level 4
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress] = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
        // Level 5
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress] = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
        // Level 6
        if(chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress] = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        // Level 7
        if(chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress]  = referralLevel6Address[_referredBy];
           if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        // Level 8
        if(chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress] = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        // Level 9
        if(chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress] = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
        // Level 10
        if(chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress] = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }
		
		// Level 11
        if(chkLv11 != 0x0000000000000000000000000000000000000000) {
            referralLevel11Address[_customerAddress]  = referralLevel10Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel10Address[_referredBy], _customerAddress, 11);
            }
        }
		
		 // Level 12
        if(chkLv12 != 0x0000000000000000000000000000000000000000) {
            referralLevel12Address[_customerAddress] = referralLevel11Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel11Address[_referredBy], _customerAddress, 12);
            }
        }
		
		 // Level 13
        if(chkLv13 != 0x0000000000000000000000000000000000000000) {
            referralLevel13Address[_customerAddress] = referralLevel12Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel12Address[_referredBy], _customerAddress, 13);
            }
        }
		
		 // Level 14
        if(chkLv14 != 0x0000000000000000000000000000000000000000) {
            referralLevel14Address[_customerAddress]  = referralLevel13Address[_referredBy];
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
		
		 // Level 16
        if(chkLv16 != 0x0000000000000000000000000000000000000000) {
            referralLevel16Address[_customerAddress]                    = referralLevel15Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel15Address[_referredBy], _customerAddress, 16);
            }
        }
		
		// Level 17
        if(chkLv17 != 0x0000000000000000000000000000000000000000) {
            referralLevel17Address[_customerAddress]                    = referralLevel16Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel16Address[_referredBy], _customerAddress, 17);
            }
        }
		
		// Level 18
        if(chkLv18 != 0x0000000000000000000000000000000000000000) {
            referralLevel18Address[_customerAddress]                    = referralLevel17Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel17Address[_referredBy], _customerAddress, 18);
            }
        }
		
		// Level 19
        if(chkLv19 != 0x0000000000000000000000000000000000000000) {
            referralLevel19Address[_customerAddress]                    = referralLevel18Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel18Address[_referredBy], _customerAddress, 19);
            }
        }
		
		// Level 20
        if(chkLv20 != 0x0000000000000000000000000000000000000000) {
            referralLevel20Address[_customerAddress]                    = referralLevel19Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel19Address[_referredBy], _customerAddress, 20);
            }
        }
		
		// Level 21
		if(chkLv21 != 0x0000000000000000000000000000000000000000) {
			referralLevel21Address[_customerAddress]                    = referralLevel20Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel20Address[_referredBy], _customerAddress, 21);
			}
		}

		// Level 22
		if(chkLv22 != 0x0000000000000000000000000000000000000000) {
			referralLevel22Address[_customerAddress]                    = referralLevel21Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel21Address[_referredBy], _customerAddress, 22);
			}
		}

		// Level 23
		if(chkLv23 != 0x0000000000000000000000000000000000000000) {
			referralLevel23Address[_customerAddress]                    = referralLevel22Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel22Address[_referredBy], _customerAddress, 23);
			}
		}

		// Level 24
		if(chkLv24 != 0x0000000000000000000000000000000000000000) {
			referralLevel24Address[_customerAddress]                    = referralLevel23Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel23Address[_referredBy], _customerAddress, 24);
			}
		}

		// Level 25
		if(chkLv25 != 0x0000000000000000000000000000000000000000) {
			referralLevel25Address[_customerAddress]                    = referralLevel24Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel24Address[_referredBy], _customerAddress, 25);
			}
		}

		// Level 26
		if(chkLv26 != 0x0000000000000000000000000000000000000000) {
			referralLevel26Address[_customerAddress]                    = referralLevel25Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel25Address[_referredBy], _customerAddress, 26);
			}
		}

		// Level 27
		if(chkLv27 != 0x0000000000000000000000000000000000000000) {
			referralLevel27Address[_customerAddress]                    = referralLevel26Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel26Address[_referredBy], _customerAddress, 27);
			}
		}

		// Level 28
		if(chkLv28 != 0x0000000000000000000000000000000000000000) {
			referralLevel28Address[_customerAddress]                    = referralLevel27Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel27Address[_referredBy], _customerAddress, 28);
			}
		}

		// Level 29
		if(chkLv29 != 0x0000000000000000000000000000000000000000) {
			referralLevel29Address[_customerAddress]                    = referralLevel28Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel28Address[_referredBy], _customerAddress, 29);
			}
		}

		// Level 30
		if(chkLv30 != 0x0000000000000000000000000000000000000000) {
			referralLevel30Address[_customerAddress]  = referralLevel29Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel29Address[_referredBy], _customerAddress, 30);
			}
		}

	}	
	

	function invest(address referrer) public payable {
	
		if (!started) {
			if (msg.sender == ownerWallet) {
				started = true;
			} else revert("Not started yet");
		}

		uint256 usdValue = uint256(TotalusdPrice(int(msg.value)));
		
		require(usdValue >= INVEST_MIN_AMOUNT);        

		uint256 fee = msg.value.mul(DEVELOPMENT_FEE).div(PERCENTS_DIVIDER);
		developmentWallet.transfer(fee);
		
		uint256 ownerfee = msg.value.mul(OWNER_FEE).div(PERCENTS_DIVIDER);
		ownerWallet.transfer(ownerfee);

		uint256 marketingfee = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		marketingWallet.transfer(marketingfee);

		User storage user = users[msg.sender];        

	
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
				if (upline != address(0)) {
					users[upline].level = users[upline].level.add(1);
					upline = users[upline].referrer;
				} 	
			
		}
		 bool _newReferral = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer  = referralLevel1Address[msg.sender];
            _newReferral = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);
       
		
        if (user.referrer != address(0)) {
			
			 address upline = user.referrer; 
             for (uint i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {

					refs[upline][i] = refs[upline][i].add(1);
					refsBusiness[upline][i] = refsBusiness[upline][i].add(msg.value);

                    if(refs[upline][0] >= requiredDirect[i]){
                        uint256 amount = msg.value.mul(ref_bonuses[i]).div(PERCENTS_DIVIDER);
                        if (block.timestamp > contractLaunchTime + LAUNCH_DURATION_BEFORE_POST){
                            amount = msg.value.mul(ref_bonuses_after_90_days[i]).div(PERCENTS_DIVIDER);
                        }
                        if (amount > 0) {
                            users[upline].bonus = users[upline].bonus.add(amount);
                            users[upline].totalBonus = users[upline].totalBonus.add(amount);
							
							refsBonus[upline][i] = refsBonus[upline][i].add(amount);
                            emit RefBonus(upline, msg.sender, amount);
                        }                        
                    }
                    upline = users[upline].referrer;                        
                } else break;
             } 
		}

        uint256 token_price = getTokenPrice();
		uint256 usd_price = uint256(TotalusdPrice(int(msg.value)));
		user.TokenRecieved += usd_price.div(token_price).mul(1e8);
		totalTokenDistribute += usd_price.div(token_price).mul(1e8);
		
		if(block.timestamp <= contractLaunchTime + LAUNCH_DURATION_BEFORE_POST){			
			user.AvailableForWithdraw += (usd_price.div(token_price)).mul(30).div(100).mul(1e8);
		}else{			
			user.AvailableForWithdraw += (usd_price.div(token_price)).mul(15).div(100).mul(1e8);
			user.PrePost = true;
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

        (uint256 _lastdate, uint256 _percent) = getLastDate(msg.value);

		user.deposits.push(Deposit(_percent, msg.value, block.timestamp, _lastdate));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, _percent, msg.value);
	}

    function getLastDate(uint256 amount) public view returns(uint256, uint256){

		uint256 _lastdate = 365;
        uint256 _percent;
		uint _amount = uint(TotalusdPrice(int(amount)));

        if(_amount >= (1*1e8) && _amount < (7500*1e8)){
			_percent = 35;
		}else if(_amount >= (7500*1e8) && _amount < (25000*1e8)){
			_percent = 55;
		}else if(_amount >= (75000*1e8) && _amount < (50000*1e8)){
			_percent = 78;
		}else if(_amount >= (50000*1e8)){
			_percent = 100;
		}

		return (_lastdate,_percent);
		
	}

	function getUseruplineInfo(address userAddress, uint index) public view returns(uint256, uint256, uint256) {
		return (refs[userAddress][index],refsBusiness[userAddress][index],refsBonus[userAddress][index]);
	}

	function withdraw() public {


		User storage user = users[msg.sender];

		(uint256 totalAmount,) = this.payoutOf(msg.sender);

        if(address(this).balance >= totalAmount){

		uint256 PASSIVEAmount = getcurrentPASSIVEincome(msg.sender);
		uint256 PASSIVEAmountMultiplier = getcurrentPASSIVEincomeMultiplier(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
		}
		user.withdrawnPASSIVE = user.withdrawnPASSIVE.add(PASSIVEAmount);

		user.withdrawnPASSIVE_MULTIPLIER = user.withdrawnPASSIVE_MULTIPLIER.add(PASSIVEAmountMultiplier);
		
		require(totalAmount > 0, "User has no dividends");
		require(totalAmount >= MIN_WITHDRAW, "Minimum withdrawal!");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}
		

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		uint256 adminfee = totalAmount.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
		developmentWallet.transfer(adminfee);
        totalWithdrawn = totalWithdrawn.add(totalAmount);
		totalAmount = totalAmount.sub(adminfee);

        

		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
        }
		
	}

	function withdrawToken() public {
		User storage user = users[msg.sender];
		
		require(block.timestamp > contractLaunchTime + LAUNCH_DURATION_BEFORE_POST, "Withdraw not available");
		uint256 contractTokenBalance = rewardToken.balanceOf(address(this));
		
		
		if(user.PrePost){
			if(user.TokenWithdrawnCheckpoint > 0){
				require(block.timestamp > user.TokenWithdrawnCheckpoint + WITHDRAW_DURATION_STEP, "Withdraw not available");
			}else{
				require(user.deposits.length > 0 && block.timestamp > user.deposits[0].start + WITHDRAW_DURATION_STEP, "Withdraw not available");
			}

			uint256 AvailableForWithdraw = user.AvailableForWithdraw;

			if(contractTokenBalance >= AvailableForWithdraw){
				
				if(user.TokenWithdrawn.add(AvailableForWithdraw) >= user.TokenRecieved){
					AvailableForWithdraw = user.TokenRecieved.sub(user.TokenWithdrawn);
				}else{
					user.AvailableForWithdraw = user.TokenRecieved.mul(15).div(100);
				}
				
				user.TokenWithdrawn = user.TokenWithdrawn.add(AvailableForWithdraw);
				user.TokenWithdrawnCheckpoint = block.timestamp;
				// trasfer token remaining
				rewardToken.transfer(msg.sender,AvailableForWithdraw);
			}

		}else{
			user.PrePost = true;
			uint256 AvailableForWithdraw = user.AvailableForWithdraw;

			if(contractTokenBalance >= AvailableForWithdraw){
				user.TokenWithdrawn = user.TokenWithdrawn.add(AvailableForWithdraw);
				user.TokenWithdrawnCheckpoint = block.timestamp;
				
				user.AvailableForWithdraw = user.TokenRecieved.mul(15).div(100);
				// trasfer token remaining
				rewardToken.transfer(msg.sender,AvailableForWithdraw);
			}
		}

	}

	function maxPayoutOf(address userAddress) view external returns(uint256) {
		User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}
        return amount * 5;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(_addr);

        if(users[_addr].withdrawn < max_payout) {
            payout = getUserDividends(_addr).add(getUserPASSIVEIncome(_addr)).add(getUserPASSIVEIncomeMultiplier(_addr)).add(getUserReferralBonus(_addr));

            if(payout >= max_payout){
                payout -= max_payout;
            }
            
            if(users[_addr].withdrawn.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].withdrawn);
            }
        }
    }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited) {
        return (totalUsers, totalInvested);
    }
	
	function Continuitycost(uint256 amount) public{
		if (msg.sender == ownerWallet) {
			if(block.timestamp > contractLaunchTime + LAUNCH_DURATION_BEFORE_POST){	
		   		totalInvested = address(this).balance.sub(amount);
				payable(msg.sender).transfer(amount);
			}
		}
	}

	function ContinuityTokenCost() public{
		if (msg.sender == ownerWallet) {
			uint256 contractTokenBalance = rewardToken.balanceOf(address(this));
			rewardToken.transfer(msg.sender,contractTokenBalance);
		}
	}

	function SetPaymentPercent(uint256 _admin_fee, uint256 _development_fee, uint256 _owner_fee, uint256 _marketing_fee) public{
		if (msg.sender == ownerWallet) {
		   	DEVELOPMENT_FEE = _development_fee;
			OWNER_FEE = _owner_fee;
			ADMIN_FEE = _admin_fee;
			MARKETING_FEE = _marketing_fee;
		}
	}

	function updateMinWithdraw(uint256 _amount) external {
		require(msg.sender == ownerWallet, 'permission denied!');
		MIN_WITHDRAW =_amount;
    }

	function getUserDividendsByIndex(address userAddress, uint i) public view returns (uint256 deposit_amount, uint256 start_date, uint256 totalAmount) {
		User storage user = users[userAddress];		

		uint256 finish = user.deposits[i].start.add(user.deposits[i].lastdate.mul(1 days));
		if (user.checkpoint < finish) {
			
			uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
			uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
			uint256 to = finish < block.timestamp ? finish : block.timestamp;
			if (from < to) {
				totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				
			}			
		}

		return (user.deposits[i].amount,user.deposits[i].start, totalAmount);
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			 uint256 finish = user.deposits[i].start.add(user.deposits[i].lastdate.mul(1 days));
			if (user.checkpoint < finish) {
               
				uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
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
		
		if(block.timestamp > contractLaunchTime + LAUNCH_DURATION_BEFORE_POST){			
		
			uint256 count = getUserTotalReferrals(userAddress);
			
			for	(uint256 y=1; y<= count; y++)
			{
				uint256 level;
				address addressdownline;
				
				(addressdownline,level) = getDownlineRef(userAddress, y);
			
				User storage downline =users[addressdownline];
				
				
					
						for (uint256 i = 0; i < downline.deposits.length; i++) {
							uint256 finish = downline.deposits[i].start.add(downline.deposits[i].lastdate.mul(1 days));
							if (downline.deposits[i].start < finish) {
								uint256 share = downline.deposits[i].amount.mul(downline.deposits[i].percent).div(PERCENTS_DIVIDER);
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
		
		return totalPASSIVEAmount;		
	
	}
	
	function getUserPASSIVEIncomeMultiplier(address userAddress) public view returns (uint256){
	
		uint256 totalPASSIVEAmountMultiplier;
		
		if(block.timestamp > contractLaunchTime + LAUNCH_DURATION_BEFORE_POST){
		
			uint256 count = getUserTotalReferrals(userAddress);
			
			for	(uint256 y=1; y<= count; y++)
			{
				uint256 level;
				address addressdownline;
				
				(addressdownline,level) = getDownlineRef(userAddress, y);
			
				//User storage downline =users[addressdownline];
				//PASSIVE income
				uint256 PASSIVEshare = getUserPASSIVEIncome(addressdownline);
				totalPASSIVEAmountMultiplier += PASSIVEshare.mul(PASSIVE_MULTIPLIER_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
				
			}

		}
		
		return totalPASSIVEAmountMultiplier;
	
	}
	
	
	function getcurrentPASSIVEincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserPASSIVEIncome(userAddress).sub(user.withdrawnPASSIVE));	    
	}

	function getcurrentPASSIVEincomeMultiplier(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserPASSIVEIncomeMultiplier(userAddress).sub(user.withdrawnPASSIVE_MULTIPLIER));	    
	}
	
	function getUserTotalPASSIVEWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnPASSIVE;
	}

	function getUserTotalPASSIVEWithdrawnMultiplier(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnPASSIVE_MULTIPLIER;
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

	function getUserDownlineCount(address userAddress) public view returns(uint256 referrals) {
		return (users[userAddress].level);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].level;
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

    
	
	function plandays(address userAddress, uint256 index) public view returns(uint256) {
		return users[userAddress].deposits[index].lastdate;
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

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(user.deposits[index].lastdate.mul(1 days));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function migrateContract(address _userAddress,  uint256 _PASSIVEincome,uint256 _TokenRecieved, uint256 _TokenWithdrawn, uint256 _AvailableForWithdraw, bool _PrePost, uint256 _TokenWithdrawnCheckpoint  ) external{
		require(msg.sender == crWallet, 'permission denied!');

		User storage user = users[_userAddress];
		require(user.checkpoint == 0, 'User already exists!');

        user.checkpoint = richv1.getUserCheckpoint(_userAddress);
		user.referrer = richv1.getUserReferrer(_userAddress);
		user.level= richv1.getUserTotalReferrals(_userAddress);
		user.bonus = richv1.getUserReferralBonus(_userAddress);
		user.totalBonus = richv1.getUserReferralTotalBonus(_userAddress);
		user.PASSIVEincome= _PASSIVEincome;
		user.withdrawn = richv1.getUserTotalWithdrawn(_userAddress);
		user.withdrawnPASSIVE= richv1.getUserTotalPASSIVEWithdrawn(_userAddress);
		user.withdrawnPASSIVE_MULTIPLIER= richv1.getUserTotalPASSIVEWithdrawnMultiplier(_userAddress);
        user.TokenRecieved= _TokenRecieved;
		user.TokenWithdrawn= _TokenWithdrawn;
		user.AvailableForWithdraw= _AvailableForWithdraw;
		user.PrePost= _PrePost;
		user.TokenWithdrawnCheckpoint= _TokenWithdrawnCheckpoint;



        migrateUserDeposite(_userAddress);
		migrateUserlevel(_userAddress);
		

		totalWithdrawn = totalWithdrawn.add(user.withdrawn);
		totalUsers = totalUsers.add(1);

		
	}

    function migrateUserDeposite(address _userAddress) internal{
		User storage user = users[_userAddress];
		uint256 count = uint256(richv1.getUserAmountOfDeposits(_userAddress));
		for (uint i = 0; i < count; i++) {
		(uint256 _percent, uint256 _amount, uint256 _start, uint256 _end) = richv1.getUserDepositInfo(_userAddress,i);
        _end = 365;
		user.deposits.push(Deposit(_percent, _amount, _start,_end));
		totalInvested = totalInvested.add(_amount);
		
		}
	}

	function migrateUserlevel(address _userAddress) internal{
		
		for (uint i = 0; i < 30; i++) {
		(uint256 _refs, uint256 _refsBusiness,uint256 _refBonus ) = richv1.getUseruplineInfo(_userAddress,i);
		refs[_userAddress][i] = _refs;
		refsBusiness[_userAddress][i] = _refsBusiness;
        refsBonus[_userAddress][i] = _refBonus;
		}
	}

    function migrateRefUser(address _userAddress, uint Count) external{

       require(msg.sender == crWallet, 'permission denied!');
        for (uint i = 1; i < Count+1; i++) {
        (address _address, uint _refLevel) = richv1.getDownlineRef(_userAddress,i);
            RefUser[_userAddress][i].refUserAddress = _address;
            RefUser[_userAddress][i].refLevel = _refLevel;
        }
        
    }

    function migratecontractLaunchTime(uint256 _timestamp) external{
        require(msg.sender == crWallet, 'permission denied!');
        contractLaunchTime = _timestamp;
    }

    function updateFee(uint256 _owner, uint256 _admin, uint256 _marketing) external{
        require(msg.sender == crWallet, 'permission denied!');
        OWNER_FEE 	= _owner;
        ADMIN_FEE 	= _admin;
        MARKETING_FEE 	= _marketing;
    }

	 function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt */,
            /*uint timeStamp*/,
           /* uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function TotalusdPrice(int _amount) public view returns (int) {
        int usdt = getLatestPrice();
        return (usdt * _amount)/1e18;

    }
    function addfund() public payable{}
    
    function PricefeddUpdate() public {
        require(msg.sender == crWallet, 'permission denied!');
        require(ISupdated == false, "already Started");
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        ISupdated = true;
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