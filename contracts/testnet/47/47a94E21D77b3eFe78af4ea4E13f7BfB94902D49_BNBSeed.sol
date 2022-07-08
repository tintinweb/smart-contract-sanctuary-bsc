/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

pragma solidity 0.5.10;

contract BNBSeed {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 1e16; // Min 0.01 bnb 
	uint256[] public REFERRAL_PERCENTS 	= [800, 200, 200, 100, 100, 50, 50, 50, 25, 25];
	uint256[] public SEED_PERCENTS 		= [1000, 900, 800, 700, 600, 500, 400, 300, 200, 100, 75, 75, 75, 75, 50, 50, 50, 50, 50, 50, 20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20];
	uint256 constant public PROJECT_FEE = 800;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 minutes;
	uint256 public WITHDRAW_MAX_TIMES = 8;
	uint256 public totalInvested;
	uint256 public totalRefBonus;
	uint256 public totalrandom;

	
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
	
	address chkLv31;
	address chkLv32;
    address chkLv33;
    address chkLv34;
    address chkLv35;
    address chkLv36;
    address chkLv37;
    address chkLv38;
    address chkLv39;
    address chkLv40;
	
	address chkLv41;
	address chkLv42;
    address chkLv43;
    address chkLv44;
    address chkLv45;
    address chkLv46;
    address chkLv47;
    address chkLv48;
    address chkLv49;
    address chkLv50;
	
	address chkLv51;
	address chkLv52;
    address chkLv53;
    address chkLv54;
    address chkLv55;
    address chkLv56;
    address chkLv57;
    address chkLv58;
    address chkLv59;
    address chkLv60;
	
	address chkLv61;
	address chkLv62;
    address chkLv63;
    address chkLv64;
    address chkLv65;

	

	
	
    
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
	
	mapping(address => address) internal referralLevel31Address;
    mapping(address => address) internal referralLevel32Address;
    mapping(address => address) internal referralLevel33Address;
    mapping(address => address) internal referralLevel34Address;
    mapping(address => address) internal referralLevel35Address;
    mapping(address => address) internal referralLevel36Address;
    mapping(address => address) internal referralLevel37Address;
    mapping(address => address) internal referralLevel38Address;
    mapping(address => address) internal referralLevel39Address;
    mapping(address => address) internal referralLevel40Address;
	
	mapping(address => address) internal referralLevel41Address;
    mapping(address => address) internal referralLevel42Address;
    mapping(address => address) internal referralLevel43Address;
    mapping(address => address) internal referralLevel44Address;
    mapping(address => address) internal referralLevel45Address;
    mapping(address => address) internal referralLevel46Address;
    mapping(address => address) internal referralLevel47Address;
    mapping(address => address) internal referralLevel48Address;
    mapping(address => address) internal referralLevel49Address;
    mapping(address => address) internal referralLevel50Address;
    
	mapping(address => address) internal referralLevel51Address;
    mapping(address => address) internal referralLevel52Address;
    mapping(address => address) internal referralLevel53Address;
    mapping(address => address) internal referralLevel54Address;
    mapping(address => address) internal referralLevel55Address;
    mapping(address => address) internal referralLevel56Address;
    mapping(address => address) internal referralLevel57Address;
    mapping(address => address) internal referralLevel58Address;
    mapping(address => address) internal referralLevel59Address;
    mapping(address => address) internal referralLevel60Address;
	
	mapping(address => address) internal referralLevel61Address;
    mapping(address => address) internal referralLevel62Address;
    mapping(address => address) internal referralLevel63Address;
    mapping(address => address) internal referralLevel64Address;
    mapping(address => address) internal referralLevel65Address;

	

    
	

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
		uint256[10] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 withdrawnseed;
		uint256 withdrawntimes;
		uint256 yourboomplan;
		uint256 yourbonuspercent;
		uint256 yourbonusminmoney;
		uint256 withdrawnblocktime;
		uint256 success;
		uint256 bonustime;
		uint256 bonusstart;
	}
	
	
	

	mapping (address => User) internal users;

	bool public started;
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;

        plans.push(Plan(10, 180));
		plans.push(Plan(15, 280));
		plans.push(Plan(30, 380));
        plans.push(Plan(21, 1000));
        plans.push(Plan(7, 1000));
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
		
		chkLv31                          = referralLevel30Address[_referredBy];
	    chkLv32                          = referralLevel31Address[_referredBy];
        chkLv33                          = referralLevel32Address[_referredBy];
        chkLv34                          = referralLevel33Address[_referredBy];
        chkLv35                          = referralLevel34Address[_referredBy];
        chkLv36                          = referralLevel35Address[_referredBy];
        chkLv37                          = referralLevel36Address[_referredBy];
        chkLv38                          = referralLevel37Address[_referredBy];
        chkLv39                          = referralLevel38Address[_referredBy];
        chkLv40                          = referralLevel39Address[_referredBy];
		
		chkLv41                          = referralLevel40Address[_referredBy];
	    chkLv42                          = referralLevel41Address[_referredBy];
        chkLv43                          = referralLevel42Address[_referredBy];
        chkLv44                          = referralLevel43Address[_referredBy];
        chkLv45                          = referralLevel44Address[_referredBy];
        chkLv46                          = referralLevel45Address[_referredBy];
        chkLv47                          = referralLevel46Address[_referredBy];
        chkLv48                          = referralLevel47Address[_referredBy];
        chkLv49                          = referralLevel48Address[_referredBy];
        chkLv50                          = referralLevel49Address[_referredBy];
		
		chkLv51                          = referralLevel50Address[_referredBy];
	    chkLv52                          = referralLevel51Address[_referredBy];
        chkLv53                          = referralLevel52Address[_referredBy];
        chkLv54                          = referralLevel53Address[_referredBy];
        chkLv55                          = referralLevel54Address[_referredBy];
        chkLv56                          = referralLevel55Address[_referredBy];
        chkLv57                          = referralLevel56Address[_referredBy];
        chkLv58                          = referralLevel57Address[_referredBy];
        chkLv59                          = referralLevel58Address[_referredBy];
        chkLv60                          = referralLevel59Address[_referredBy];
		
		chkLv61                          = referralLevel60Address[_referredBy];
	    chkLv62                          = referralLevel61Address[_referredBy];
        chkLv63                          = referralLevel62Address[_referredBy];
        chkLv64                          = referralLevel63Address[_referredBy];
        chkLv65                          = referralLevel64Address[_referredBy];

		

		

		

		
		
		
		
		
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
			referralLevel30Address[_customerAddress]                    = referralLevel29Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel29Address[_referredBy], _customerAddress, 30);
			}
		}
		
		// Level 31
		if(chkLv31 != 0x0000000000000000000000000000000000000000) {
			referralLevel31Address[_customerAddress]                    = referralLevel30Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel30Address[_referredBy], _customerAddress, 31);
			}
		}

		// Level 32
		if(chkLv32 != 0x0000000000000000000000000000000000000000) {
			referralLevel32Address[_customerAddress]                    = referralLevel31Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel31Address[_referredBy], _customerAddress, 32);
			}
		}

		// Level 33
		if(chkLv33 != 0x0000000000000000000000000000000000000000) {
			referralLevel33Address[_customerAddress]                    = referralLevel32Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel32Address[_referredBy], _customerAddress, 33);
			}
		}

		// Level 34
		if(chkLv34 != 0x0000000000000000000000000000000000000000) {
			referralLevel34Address[_customerAddress]                    = referralLevel33Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel33Address[_referredBy], _customerAddress, 34);
			}
		}

		// Level 35
		if(chkLv35 != 0x0000000000000000000000000000000000000000) {
			referralLevel35Address[_customerAddress]                    = referralLevel34Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel34Address[_referredBy], _customerAddress, 35);
			}
		}

		// Level 36
		if(chkLv36 != 0x0000000000000000000000000000000000000000) {
			referralLevel36Address[_customerAddress]                    = referralLevel35Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel35Address[_referredBy], _customerAddress, 36);
			}
		}

		// Level 37
		if(chkLv37 != 0x0000000000000000000000000000000000000000) {
			referralLevel37Address[_customerAddress]                    = referralLevel36Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel36Address[_referredBy], _customerAddress, 37);
			}
		}

		// Level 38
		if(chkLv38 != 0x0000000000000000000000000000000000000000) {
			referralLevel38Address[_customerAddress]                    = referralLevel37Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel37Address[_referredBy], _customerAddress, 38);
			}
		}

		// Level 39
		if(chkLv39 != 0x0000000000000000000000000000000000000000) {
			referralLevel39Address[_customerAddress]                    = referralLevel38Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel38Address[_referredBy], _customerAddress, 39);
			}
		}

		// Level 40
		if(chkLv40 != 0x0000000000000000000000000000000000000000) {
			referralLevel40Address[_customerAddress]                    = referralLevel39Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel39Address[_referredBy], _customerAddress, 40);
			}
		}
		// Level 41
		if(chkLv41 != 0x0000000000000000000000000000000000000000) {
			referralLevel41Address[_customerAddress]                    = referralLevel40Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel40Address[_referredBy], _customerAddress, 41);
			}
		}

		// Level 42
		if(chkLv42 != 0x0000000000000000000000000000000000000000) {
			referralLevel42Address[_customerAddress]                    = referralLevel41Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel41Address[_referredBy], _customerAddress, 42);
			}
		}
		
			// Level 43
		if(chkLv43 != 0x0000000000000000000000000000000000000000) {
			referralLevel43Address[_customerAddress]                    = referralLevel42Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel42Address[_referredBy], _customerAddress, 43);
			}
		}

		// Level 44
		if(chkLv44 != 0x0000000000000000000000000000000000000000) {
			referralLevel44Address[_customerAddress]                    = referralLevel42Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel42Address[_referredBy], _customerAddress, 44);
			}
		}



		// Level 45
		if(chkLv45 != 0x0000000000000000000000000000000000000000) {
			referralLevel45Address[_customerAddress]                    = referralLevel44Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel44Address[_referredBy], _customerAddress, 45);
			}
		}

		// Level 46
		if(chkLv46 != 0x0000000000000000000000000000000000000000) {
			referralLevel46Address[_customerAddress]                    = referralLevel45Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel45Address[_referredBy], _customerAddress, 46);
			}
		}

		// Level 47
		if(chkLv47 != 0x0000000000000000000000000000000000000000) {
			referralLevel47Address[_customerAddress]                    = referralLevel46Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel46Address[_referredBy], _customerAddress, 47);
			}
		}

		// Level 48
		if(chkLv48 != 0x0000000000000000000000000000000000000000) {
			referralLevel48Address[_customerAddress]                    = referralLevel47Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel47Address[_referredBy], _customerAddress, 48);
			}
		}

		// Level 49
		if(chkLv49 != 0x0000000000000000000000000000000000000000) {
			referralLevel49Address[_customerAddress]                    = referralLevel48Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel48Address[_referredBy], _customerAddress, 49);
			}
		}

		// Level 50
		if(chkLv50 != 0x0000000000000000000000000000000000000000) {
			referralLevel50Address[_customerAddress]                    = referralLevel49Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel49Address[_referredBy], _customerAddress, 50);
			}
		}
		

			
			
		// Level 51
		if(chkLv51 != 0x0000000000000000000000000000000000000000) {
			referralLevel51Address[_customerAddress]                    = referralLevel50Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel50Address[_referredBy], _customerAddress, 51);
			}
		}
			
		
		// Level 52
		if(chkLv52 != 0x0000000000000000000000000000000000000000) {
			referralLevel52Address[_customerAddress]                    = referralLevel51Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel51Address[_referredBy], _customerAddress, 52);
			}
		}
		
		// Level 53
		if(chkLv53 != 0x0000000000000000000000000000000000000000) {
			referralLevel53Address[_customerAddress]                    = referralLevel52Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel52Address[_referredBy], _customerAddress, 53);
			}
		}
		
		// Level 54
		if(chkLv54 != 0x0000000000000000000000000000000000000000) {
			referralLevel54Address[_customerAddress]                    = referralLevel53Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel53Address[_referredBy], _customerAddress, 54);
			}
		}
		
		
		// Level 55
		if(chkLv55 != 0x0000000000000000000000000000000000000000) {
			referralLevel55Address[_customerAddress]                    = referralLevel54Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel54Address[_referredBy], _customerAddress, 55);
			}
		}
		
		// Level 56
		if(chkLv56 != 0x0000000000000000000000000000000000000000) {
			referralLevel56Address[_customerAddress]                    = referralLevel55Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel55Address[_referredBy], _customerAddress, 56);
			}
		}
		
		
		// Level 57
		if(chkLv57 != 0x0000000000000000000000000000000000000000) {
			referralLevel57Address[_customerAddress]                    = referralLevel56Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel56Address[_referredBy], _customerAddress, 57);
			}
		}
		
		// Level 58
		if(chkLv58 != 0x0000000000000000000000000000000000000000) {
			referralLevel58Address[_customerAddress]                    = referralLevel57Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel57Address[_referredBy], _customerAddress, 58);
			}
		}
		
		
		// Level 59
		if(chkLv59 != 0x0000000000000000000000000000000000000000) {
			referralLevel59Address[_customerAddress]                    = referralLevel58Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel58Address[_referredBy], _customerAddress, 59);
			}
		}
		
		
		// Level 60
		if(chkLv60 != 0x0000000000000000000000000000000000000000) {
			referralLevel60Address[_customerAddress]                    = referralLevel59Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel59Address[_referredBy], _customerAddress, 60);
			}
		}
		
		// Level 61
		if(chkLv61 != 0x0000000000000000000000000000000000000000) {
			referralLevel61Address[_customerAddress]                    = referralLevel60Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel60Address[_referredBy], _customerAddress, 61);
			}
		}
		
		// Level 62
		if(chkLv62 != 0x0000000000000000000000000000000000000000) {
			referralLevel62Address[_customerAddress]                    = referralLevel61Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel61Address[_referredBy], _customerAddress, 62);
			}
		}
			
			
		// Level 63
		if(chkLv63 != 0x0000000000000000000000000000000000000000) {
			referralLevel63Address[_customerAddress]                    = referralLevel62Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel62Address[_referredBy], _customerAddress, 63);
			}
		}

		// Level 64
		if(chkLv64 != 0x0000000000000000000000000000000000000000) {
			referralLevel64Address[_customerAddress]                    = referralLevel63Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel63Address[_referredBy], _customerAddress, 64);
			}
		}
		
		// Level 65
		if(chkLv65 != 0x0000000000000000000000000000000000000000) {
			referralLevel65Address[_customerAddress]                    = referralLevel64Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel64Address[_referredBy], _customerAddress, 65);
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
        require(plan < 3, "Invalid plan");

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

		User storage user = users[msg.sender];

		//user.yourbonusminmoney = 0;

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


		if(user.yourboomplan <= plan) {
			user.yourboomplan = plan;
		}

		


		user.deposits.push(Deposit(plan, msg.value, block.timestamp));



		/*for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
			if(user.deposits[i].plan < 3){
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
					if(user.deposits[i].plan == 0){
						user.yourbonusminmoney = user.yourbonusminmoney.add(users[msg.sender].deposits[i].amount*18/1000);

					}else if(user.deposits[i].plan == 1){
						user.yourbonusminmoney = user.yourbonusminmoney.add(users[msg.sender].deposits[i].amount*28/1000);

					}else if(user.deposits[i].plan == 2){
						user.yourbonusminmoney = user.yourbonusminmoney.add(users[msg.sender].deposits[i].amount*38/1000);

					}

				}
			}
		}*/


		emit NewDeposit(msg.sender, plan, msg.value);
	}







	function bonus(uint8 times) public payable {
		User storage user = users[msg.sender];
        require(times < 3, "Invalid plan");
		if(user.bonusstart==0){
			user.bonustime = block.timestamp;
		}else if((block.timestamp>(user.bonustime+300))){
			user.bonusstart = 0;
			user.bonustime = block.timestamp;
		}

		
		
		//uint256 t_dailybonus;
		uint256 t_bonus0=0;
		uint256 t_bonus1=0;
		uint256 success;
		uint256 amount;
		if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
		



		require(user.deposits.length > 0);

		for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
			if(user.deposits[i].plan < 3){
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){

					if(user.deposits[i].plan == 0){
						amount = amount.add(users[msg.sender].deposits[i].amount*18/1000);
					}else if(user.deposits[i].plan == 1){
						amount = amount.add(users[msg.sender].deposits[i].amount*28/1000);
					}else if(user.deposits[i].plan == 2){
						amount = amount.add(users[msg.sender].deposits[i].amount*38/1000);
					}
				
				}
			}
		}

		require(amount > 0);

		if(times==0){

			require(msg.value >= amount);
			times = 1;
			user.bonusstart = user.bonusstart.add(times);
			require(user.bonusstart<=10, "Invalid bonustime");
		}else if(times==1){

			require(msg.value >= amount*5);
			times = 5;
			user.bonusstart = user.bonusstart.add(times);
			require(user.bonusstart<=10, "Invalid bonustime");
		}else if(times==2){

			require(msg.value >= amount*10);
			times = 10;
			user.bonusstart = user.bonusstart.add(times);
			require(user.bonusstart<=10, "Invalid bonustime");
		}

		totalInvested = totalInvested.add(msg.value);
		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);



		uint index0;
		uint index1;

		
		index0 = uint(keccak256(abi.encodePacked(totalrandom%1000, msg.sender, block.difficulty, block.timestamp)));
		totalrandom = totalrandom.add(block.timestamp);
		for (uint256 p = 0; p < times; p++) {




			index0 = uint(keccak256(abi.encodePacked(totalrandom%100, msg.sender, block.difficulty, index0)));
			index0 = uint(keccak256(abi.encodePacked(totalrandom%7, msg.sender, block.difficulty, index0)));
			index1 = uint(keccak256(abi.encodePacked(totalrandom%7, msg.sender, block.difficulty, index0)))% 100;


			
			
			if(index1 > 50){
				success = success + 1;
			}
		}



		if(success==0){
			for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
					if(user.deposits[i].plan==0){
						t_bonus0 = t_bonus0.add(18*7*users[msg.sender].deposits[i].amount);
				//		t_dailybonus = t_dailybonus.add(18*users[msg.sender].deposits[i].amount);
						//user.deposits.push(Deposit(6, (users[msg.sender].deposits[i].amount)*18/1000, block.timestamp));
					}else if(user.deposits[i].plan==1){
						t_bonus0 = t_bonus0.add(28*7*users[msg.sender].deposits[i].amount);
				//		t_dailybonus = t_dailybonus.add(28*users[msg.sender].deposits[i].amount);
						//user.deposits.push(Deposit(7, (users[msg.sender].deposits[i].amount)*28/1000, block.timestamp));
					}else if(user.deposits[i].plan==2){
						t_bonus0 = t_bonus0.add(38*7*users[msg.sender].deposits[i].amount);
				//		t_dailybonus = t_dailybonus.add(38*users[msg.sender].deposits[i].amount);
						//user.deposits.push(Deposit(8, (users[msg.sender].deposits[i].amount)*38/1000, block.timestamp));
					}
				}
			}
			user.deposits.push(Deposit(4, t_bonus0/7/1000, block.timestamp));
		}else if(success==times){
			for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
					if(user.deposits[i].plan==0){
						t_bonus1 = t_bonus1.add(18*21*users[msg.sender].deposits[i].amount*success);
				//		t_dailybonus = t_dailybonus.add(18*users[msg.sender].deposits[i].amount*success);
					//	user.deposits.push(Deposit(3, (users[msg.sender].deposits[i].amount)*success*18/1000, block.timestamp));
					}else if(user.deposits[i].plan==1){
						t_bonus1 = t_bonus1.add(28*21*users[msg.sender].deposits[i].amount*success);
				//		t_dailybonus = t_dailybonus.add(28*users[msg.sender].deposits[i].amount*success);
					//	user.deposits.push(Deposit(4, (users[msg.sender].deposits[i].amount)*success*28/1000, block.timestamp));
					}else if(user.deposits[i].plan==2){
						t_bonus1 = t_bonus1.add(38*21*users[msg.sender].deposits[i].amount*success);
				//		t_dailybonus = t_dailybonus.add(38*users[msg.sender].deposits[i].amount*success);
				//		user.deposits.push(Deposit(5, (users[msg.sender].deposits[i].amount)*success*38/1000, block.timestamp));
					}
				}
			}
			user.deposits.push(Deposit(3, t_bonus1/21/1000, block.timestamp));
		}else{



			for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
					if(user.deposits[i].plan==0){
						t_bonus1 = t_bonus1.add(18*21*users[msg.sender].deposits[i].amount*success);
						t_bonus0 = t_bonus0.add(18*7*users[msg.sender].deposits[i].amount*(times-success));
					//	t_dailybonus = t_dailybonus.add(18*users[msg.sender].deposits[i].amount*success);
					//	t_dailybonus = t_dailybonus.add(18*users[msg.sender].deposits[i].amount*(times-success));
						//user.deposits.push(Deposit(3, (users[msg.sender].deposits[i].amount)*success*18/1000, block.timestamp));
					//	user.deposits.push(Deposit(6, (users[msg.sender].deposits[i].amount)*(times-success)*18/1000, block.timestamp));
					}else if(user.deposits[i].plan==1){
						t_bonus1 = t_bonus1.add(28*21*users[msg.sender].deposits[i].amount*success);
						t_bonus0 = t_bonus0.add(28*7*users[msg.sender].deposits[i].amount*(times-success));
					//	t_dailybonus = t_dailybonus.add(28*users[msg.sender].deposits[i].amount*success);
					//	t_dailybonus = t_dailybonus.add(28*users[msg.sender].deposits[i].amount*(times-success));
						//user.yourbonus = 1;
						//totalrandom = totalrandom.add(block.timestamp);
					//	user.deposits.push(Deposit(4, (users[msg.sender].deposits[i].amount)*success*28/1000, block.timestamp));
					//	user.deposits.push(Deposit(7, (users[msg.sender].deposits[i].amount)*(times-success)*28/1000, block.timestamp));
					}else if(user.deposits[i].plan==2){
						t_bonus1 = t_bonus1.add(38*21*users[msg.sender].deposits[i].amount*success);
						t_bonus0 = t_bonus0.add(38*7*users[msg.sender].deposits[i].amount*(times-success));
					//	t_dailybonus = t_dailybonus.add(38*users[msg.sender].deposits[i].amount*success);
					//	t_dailybonus = t_dailybonus.add(38*users[msg.sender].deposits[i].amount*(times-success));
						//user.yourbonus = 1;
						//totalrandom = totalrandom.add(block.timestamp);
						//user.deposits.push(Deposit(5, (users[msg.sender].deposits[i].amount)*success*38/1000, block.timestamp));
						//user.deposits.push(Deposit(8, (users[msg.sender].deposits[i].amount)*(times-success)*38/1000, block.timestamp));
					}
				}
			}
			user.deposits.push(Deposit(4, t_bonus0/7/1000, block.timestamp));
			user.deposits.push(Deposit(3, t_bonus1/21/1000, block.timestamp));
		}

		
			






		//user.yourboompercent = user.yourboompercent.add(t_dailybonus);
		
		user.yourbonuspercent = user.yourbonuspercent.add(t_bonus0+t_bonus1);
		user.success = user.success.add(success);


	}













	function withdraw() public {
		User storage user = users[msg.sender];
		if(user.withdrawntimes==0){
			user.withdrawnblocktime = block.timestamp;
		}
		if(user.withdrawntimes!=0 && (block.timestamp>(user.withdrawnblocktime + 259200))){
			user.withdrawntimes = 0;
		}
		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		

		
		

		

		
		
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}
		
		if(user.withdrawntimes > 0){
			uint256 fee = totalAmount.div(100).mul(user.withdrawntimes);
			totalAmount = totalAmount.sub(fee);
			commissionWallet.transfer(fee/2);
			emit FeePayed(msg.sender, fee/2);
		}
		
		if(user.withdrawntimes < WITHDRAW_MAX_TIMES) {
			user.withdrawntimes = user.withdrawntimes.add(1);
		}
		
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes));
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

	function getUserbonuspercent(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 daliybonus;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
				if(user.deposits[i].plan==3){
					daliybonus = daliybonus.add(user.deposits[i].amount);
				}else if(user.deposits[i].plan==4){
					daliybonus = daliybonus.add(user.deposits[i].amount);
				}
			}
		}
		return daliybonus;
	}





	function getyourbonusminmoney(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 yourbonusminmoney1=0;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan < 3){
				if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 minutes)) > block.timestamp){
					if(user.deposits[i].plan == 0){
						yourbonusminmoney1 = yourbonusminmoney1+(user.deposits[i].amount*18/1000);

					}else if(user.deposits[i].plan == 1){
						yourbonusminmoney1 = yourbonusminmoney1+(user.deposits[i].amount*28/1000);

					}else if(user.deposits[i].plan == 2){
						yourbonusminmoney1 = yourbonusminmoney1+(user.deposits[i].amount*38/1000);

					}

				}
			}
		}
		return yourbonusminmoney1;
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
				uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 minutes));
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

	function getyoursuccess(address userAddress) public view returns (uint256){
	    return users[userAddress].success;
	}	
	
	
	
	/*function getyourbonusminmoney(address userAddress) public view returns (uint256){
	    return users[userAddress].yourbonusminmoney;
	}	*/
	
	function getyourbonuspercent(address userAddress) public view returns (uint256){
	    return users[userAddress].yourbonuspercent;
	}	
	
	function getcurrentwithdrawntime(address userAddress) public view returns (uint256 withdrawntimes_, uint256 withdrawnblocktime_, uint256 block_){
	    return (users[userAddress].withdrawntimes, users[userAddress].withdrawnblocktime, block.timestamp);
	}	
	
	function getyourboomplan(address userAddress) public view returns (uint256){
	    return users[userAddress].yourboomplan+1;
	}	
	

	
	function getUserbonusstart(address userAddress) public view returns (uint256){
		if((block.timestamp>(users[userAddress].bonustime+300))){
			return 0;
		}
	    return users[userAddress].bonusstart;
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

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256, uint256 yourbonusminmoney) {
		return (users[userAddress].deposits.length, getyourbonusminmoney(userAddress));
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			if(users[userAddress].deposits[i].plan < 3){
				amount = amount.add(users[userAddress].deposits[i].amount);
			}
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 minutes));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 yourboomplan, uint256 yourbonuspercent, uint256 Userbonuspercent,uint256 Userbonusstart) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getyourboomplan(userAddress), getyourbonuspercent(userAddress), getUserbonuspercent(userAddress), getUserbonusstart(userAddress));
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