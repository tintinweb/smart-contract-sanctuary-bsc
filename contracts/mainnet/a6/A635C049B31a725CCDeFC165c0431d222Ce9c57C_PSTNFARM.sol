/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// File: contracts/3_Ballot.sol

pragma solidity 0.5.8;

library SafeMath {

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function limitSupply() external view returns (uint256);
    function availableSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PSTNFARM {
    
    using SafeMath for uint256;
    uint256 private startTime = 1654195500; 
    
	address pstn = 0xBfACD29427fF376FF3BC22dfFB29866277cA5Fb4;
	address payable private admin = 0x8955c3dC23988121e60b219F0780e2d65475393d;
    
    uint public totalUsers; 
    uint256 public totalPSTNStaked; 
    
    uint8[] private REF_BONUSES             = [70, 30, 20, 10, 10, 10];	
    uint private constant PSTN_DAILYPROFIT  = 25;
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant PRICE_DIVIDER     = 1 ether;
	uint private constant TIME_STEP         = 1 days;
	uint private constant ADM_FEE           = 100;
    
    mapping(address => User) private users;
    
    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked; 
        uint256 lastStakeTime;
        uint256 unClaimedTokens;        
    }
    
    struct User {
        address referrer;
        Stake sM; 
		uint256 bonus;
		uint256 totalBonus;
		uint commonKeys;
		uint rareKeys;
		uint legendaryKeys;
		uint unknownKeys;
        uint[6] levels;
		uint256[6] commissions;
    } 
	event TokenOperation(address indexed account, string txType, uint tokenAmount, uint trxAmount);
	
	function buyTicket(address referrer,  uint256 _amount) public payable {
        
    ERC20(pstn).transferFrom(msg.sender, address(this), _amount);
	
	uint fee =  _amount.mul(ADM_FEE).div(PERCENT_DIVIDER);
        
    ERC20(pstn).transfer(admin, fee);
	
	require(_amount == 1000000000000000000 || _amount == 10000000000000000000 || _amount == 100000000000000000000 || _amount == 1000000000000000000000);

		User storage user = users[msg.sender];
		
		uint random = getRandomNumber(msg.sender);
		
		if (_amount == 1000000000000000000 && random <= 5) {
		user.commonKeys++;
		}
		
		if (_amount == 1000000000000000000 && random >= 6 && random <=7) {
		user.rareKeys++;
		}
		
		if (_amount == 1000000000000000000 && random == 8) {
		user.legendaryKeys++;
		}
				
		if (_amount == 10000000000000000000 && random <= 10) {
		user.commonKeys++;
		}
		
		if (_amount == 10000000000000000000 && random >= 11 && random <= 15) {
		user.rareKeys++;
		}
		
		if (_amount == 10000000000000000000 && random >= 16 && random <=18) {
		user.legendaryKeys++;
		}
				
		if (_amount == 100000000000000000000 && random <= 10) {
		user.commonKeys++;
		}
		
		if (_amount == 100000000000000000000 && random >= 11 && random <= 16) {
		user.rareKeys++;
		}
		
		if (_amount == 100000000000000000000 && random >= 17 && random <= 20) {
		user.legendaryKeys++;
		}
		
		if (_amount == 100000000000000000000 && random >= 21 && random <= 23) {
		user.unknownKeys++;
		}		
		
		if (_amount == 1000000000000000000000 && random <= 5) {
		user.commonKeys++;
		}
		
		if (_amount == 1000000000000000000000 && random >= 6 && random <= 7) {
		user.rareKeys++;
		}
		
		if (_amount == 1000000000000000000000 && random >= 8 && random <= 14) {
		user.legendaryKeys++;
		}
		
		if (_amount == 1000000000000000000000 && random >= 15 && random <= 19) {
		user.unknownKeys++;
		}	
				
		if (user.referrer == address(0) && msg.sender != admin) {
			if (users[referrer].sM.totalStaked == 0) {
				referrer = admin;
			}
			user.referrer = referrer;
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i]+1;
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline == address(0)) {
				    upline = admin;
				}
				uint256 amountCom = (_amount*REF_BONUSES[i]) / (PERCENT_DIVIDER);
				users[upline].commissions[i] = users[upline].commissions[i].add(amountCom);
				users[upline].bonus = users[upline].bonus.add(amountCom);
				users[upline].totalBonus = users[upline].totalBonus.add(amountCom);
				upline = users[upline].referrer;
			}
		} 

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            totalUsers++;
        } else {
            updateStakePSTN_IP(msg.sender);
        }
      
        user.sM.lastStakeTime = now;
        user.sM.totalStaked += _amount;
        totalPSTNStaked += _amount;
			
    }
    
    
    function updateStakePSTN_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakePSTN_IP(_addr);
        if(amount > 0) {
            user.sM.unClaimedTokens = user.sM.unClaimedTokens.add(amount);
            user.sM.checkpoint = now;
        }
    } 
    
    function getStakePSTN_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = PSTN_DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }     
    
    function claimToken_M() public {
		
        User storage user = users[msg.sender];
       
        updateStakePSTN_IP(msg.sender);
        uint256 tokenAmount = user.sM.unClaimedTokens;
        ERC20(pstn).transfer(msg.sender, tokenAmount);		
        user.sM.unClaimedTokens = 0;                 

    }       
    
	function withdrawRef() public {
		User storage user = users[msg.sender];	
		uint256 totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
		ERC20(pstn).transfer(msg.sender, totalAmount);
	}	    

    function getUserUnclaimedTokens_M(address _addr) public view returns(uint256 value) {
        User storage user = users[_addr];
        return getStakePSTN_IP(_addr).add(user.sM.unClaimedTokens); 
    }  
    
	function getContractPSTNBalance() public view returns (uint256) {
	    return ERC20(pstn).balanceOf(address(this));
	}  
	
	function getAPY_M() public pure returns (uint256) {
		return PSTN_DAILYPROFIT.mul(365).div(10);
	}
	
	function getUserPSTNBalance(address _addr) public view returns (uint256) {
		return address(_addr).balance;
	}	
	
	function getUserPSTNStaked(address _addr) public view returns (uint256) {
		return users[_addr].sM.totalStaked;
	}

    function getUserCOMMONkeys(address _addr) public view returns (uint) {
		return users[_addr].commonKeys;
	}

    function getUserRAREkeys(address _addr) public view returns (uint) {
		return users[_addr].rareKeys;
	}

    function getUserLEGENDkeys(address _addr) public view returns (uint) {
		return users[_addr].legendaryKeys;
	}

    function getUserUNKNOWNkeys(address _addr) public view returns (uint) {
		return users[_addr].unknownKeys;
	}		

	function getUserDownlineCount(address userAddress) public view returns(uint, uint, uint, uint, uint, uint) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4], users[userAddress].levels[5]);
	}

	function getUserDownlineValue(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
		return (users[userAddress].commissions[0], users[userAddress].commissions[1], users[userAddress].commissions[2], users[userAddress].commissions[3], users[userAddress].commissions[4], users[userAddress].commissions[5]);
	} 
	
	function playerReferrals(address userAddress) view external returns(uint[] memory ref_count, uint256[] memory ref_earnings){
        uint256[] memory _ref_count = new uint[](6);
        uint256[] memory _ref_earnings = new uint256[](6);
        User storage user = users[userAddress];

        for(uint8 i = 0; i < 6; i++){
            _ref_count[i] = user.levels[i];
            _ref_earnings[i] = user.commissions[i];
        }

        return (_ref_count, _ref_earnings);
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
    
	function getContractLaunchTime() public view returns(uint) {
		return minZero(startTime, block.timestamp);
	}
	
    function getCurrentDay() public view returns (uint) {
        return minZero(now, startTime).div(TIME_STEP);
    }
	
	function getRandomNumber(address _addr) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,_addr))) % 100;
	}
    
    function getTimeToNextDay() public view returns (uint) {
        uint t = minZero(now, startTime);
        uint g = getCurrentDay().mul(TIME_STEP);
        return g.add(TIME_STEP).sub(t);
    }     
    
    function minZero(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return a - b; 
        } else {
           return 0;    
        }    
    }   
    
    function maxVal(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return a; 
        } else {
           return b;    
        }    
    }
    
    function minVal(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return b; 
        } else {
           return a;    
        }    
    }    
}