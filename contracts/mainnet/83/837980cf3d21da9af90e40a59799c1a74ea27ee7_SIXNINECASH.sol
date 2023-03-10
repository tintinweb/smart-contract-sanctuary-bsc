/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity 0.5.8;

contract ERC20 {
    function totalSupply() public returns (uint);
    function balanceOf(address tokenOwner) public returns (uint balance);
    function allowance(address tokenOwner, address spender) public returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SIXNINECASH {
    
    using SafeMath for uint256;
    uint private startTime = 1678476258; 
    
    uint public totalUsers; 
    uint256 public totalBNBStaked;
	
	address dmoon = 0x7D18f3fE6e638faD0AdACC5dB1A47f871a2C2cC4;
	address payable development = 0xd6014fEBf1F3814A3FdA1cd13E4A877021aB3DAb;
    address payable admin = 0xE0dE8D5BCa75DBA89dc6759EbF01Ee7443896Ed4;
    
    uint[] private REF_BONUSES    = [60, 9];
    uint private constant PROJECT_FEE       = 69;	
    uint private constant DAILYPROFIT       = 69;
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant TIME_STEP         = 1 days;
    
    mapping(address => User) private users;
    
    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked;
		uint256 totalClaimed; 		
        uint256 lastStakeTime;
        uint256 unClaimedBNB;        
    }
    
    struct User {
        address referrer;
        Stake sM;  
		uint256 bonus;
		uint256 totalBonus;
        uint totaReferralBonus;
        uint[2] levels;
		uint256[2] commissions;
    }

    function() external payable{
        stakeBNB(address(0), msg.value);
    }   
    
    function stakeBNB(address referrer, uint256 _amount) public payable {
	
	require(_amount <= ERC20(dmoon).balanceOf(address(msg.sender)));
	
	ERC20(dmoon).transferFrom(address(msg.sender), address(this), _amount);
	
	ERC20(dmoon).transfer(development, (((_amount).mul(35)).div(1000)));
    ERC20(dmoon).transfer(admin, (((_amount).mul(34)).div(1000)));
		
    User storage user = users[msg.sender];
		
		if (user.referrer == address(0) && msg.sender != development) {
			if (users[referrer].sM.totalStaked == 0) {
				referrer = development;
			}
			user.referrer = referrer;
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline == address(0)) {
				    upline = development;
				}
				uint256 amount = _amount.mul(REF_BONUSES[i]).div(PERCENT_DIVIDER);
				users[upline].bonus = users[upline].bonus.add(amount);
				users[upline].commissions[i] = users[upline].commissions[i].add(amount);
				users[upline].totalBonus = users[upline].totalBonus.add(amount);
				upline = users[upline].referrer;
			}
		} 

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            totalUsers++;
        } else {
            updateStakeBNB_IP(msg.sender);
        }
		
        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalBNBStaked = totalBNBStaked.add(_amount);
		user.sM.unClaimedBNB = user.sM.unClaimedBNB.add((_amount / 100) * 69);
		}
    
    
    function updateStakeBNB_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeBNB_IP(_addr);
        if(amount > 0) {
            user.sM.unClaimedBNB = user.sM.unClaimedBNB.add(amount);
            user.sM.checkpoint = now;
        }
    } 
    
    function getStakeBNB_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }      
    
    function claimBNB() public {
		
        User storage user = users[msg.sender];
		
		require(user.sM.unClaimedBNB <= ((user.sM.totalStaked * 138) / 100));
		require(user.sM.totalClaimed <= ((user.sM.totalStaked * 1311) / 1000));
       
        updateStakeBNB_IP(msg.sender);
        uint256 bnbAmount = user.sM.unClaimedBNB;  
        user.sM.unClaimedBNB = 0; 
		user.sM.totalClaimed += bnbAmount;		
        
        ERC20(dmoon).transfer(msg.sender, bnbAmount);
    }     
    
	function withdrawRef() public {
		User storage user = users[msg.sender];	
		uint totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
		ERC20(dmoon).transfer(msg.sender, totalAmount);
	}	    

    function getUserUnclaimedBNB(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeBNB_IP(_addr).add(user.sM.unClaimedBNB); 
    }    
	
	function getContractBNBBalance() public view returns (uint) {
		return address(this).balance;
	}  
	
	function getUserBNBBalance(address _addr) public view returns (uint) {
		return address(_addr).balance;
	}	
	
	function getUserBNBStaked(address _addr) public view returns (uint) {
		return users[_addr].sM.totalStaked;
	}	
	
	function getUserBNBClaimed(address _addr) public view returns (uint) {
		return users[_addr].sM.totalClaimed;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint, uint) {
		return (users[userAddress].levels[0], users[userAddress].levels[1]);
	} 
	
	function getUserReferralBonus(address userAddress) public view returns(uint) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint) {
		return users[userAddress].totalBonus;
	}
	
	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}	   
	function getContractLaunchTime() public view returns(uint) {
		return minZero(startTime, block.timestamp);
	}
	
	function playerReferrals(address userAddress) view external returns(uint[] memory ref_count, uint256[] memory ref_earnings){
        uint256[] memory _ref_count = new uint[](2);
        uint256[] memory _ref_earnings = new uint256[](2);
        User storage user = users[userAddress];

        for(uint8 i = 0; i < 2; i++){
            _ref_count[i] = user.levels[i];
            _ref_earnings[i] = user.commissions[i];
        }

        return (_ref_count, _ref_earnings);
    }
	
    function getCurrentDay() public view returns (uint) {
        return minZero(now, startTime).div(TIME_STEP);
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