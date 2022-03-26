/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

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

interface IERC20 {
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

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    address btcb = 0x722dd3F80BAC40c951b51BdD28Dd19d435762180;
    IERC20 token;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function limitSupply() public view returns (uint256) {
        return _limitSupply;
    }
    
    function availableSupply() public view returns (uint256) {
        return _limitSupply.sub(_totalSupply);
    }    

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(availableSupply() >= amount, "Supply exceed");

        _totalSupply = _totalSupply.add(amount);
        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external;
}

contract Token is ERC20 {
    mapping (address => bool) private _contracts;

    constructor() public {
        _name = "BTCENERGY";
        _symbol = "BNRG";
        _decimals = 18;
        _limitSupply = 1000000000e18;
    }

    function approveAndCall(address spender, uint256 amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {

        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }

        return true;
    }

}

contract BTCBFARM is Token {
    
    using SafeMath for uint256;
    uint private startTime; 
    address payable private commissionAdd = 0x0aceC878e2656fC599d0979F49F7E557f7224a15;
    address payable private marketingFund = 0x2D1ad8C2CCCcDBBf42118Ec7709924b2740b542d;
	address payable private developFund   = 0x01107014853005b6876C8F33b459E3266D652A3D;
	// address payable private influencer000 = 0xf3e47A6d10Bf2b232E08c3451F777Ac6933353dE;
	// address payable private influencer001 = 0xE1eB1bfc456D10Bf7412FbD9CA0339226d342502;
	// address payable private influencer002 = 0xce2D5A8a90de87E673212a90F947A5B75265b27a;
	// address payable private influencer003 = 0x422278F46632F8F4250a5e076252f415A0D4162a;
	
    uint256 public totalUsers; 
    uint256 public totalBTCBStaked;
	uint256 public totalBTCBFarmed;
	uint256 public totalEnergyinUse;
	
	address payable private creAd;
    
    uint256[] public REF_BONUSES            = [70, 50, 30, 10, 10, 5, 5];
	uint private constant FREE_BONUS        = 1e16;
    uint private constant PROJECT_FEE       = 5;	
    uint private constant DAILY_PROFIT       = 12;
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant TIME_STEP         = 1 days;
	uint private constant PREMINE           = 1000000 ether;
    
    mapping(address => User) private users; 
    
    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked; 
        uint256 lastStakeTime;
        uint256 unClaimedBTCB;
		uint256 energyUser;
    }
    
    struct User {
	    Stake sM;
        address referrer;
		uint256 freeBonus;
		uint256 bonus;
		uint256 totalBonus;
        uint[7] levels;
    }

    event TokenOperation(address indexed account, string txType, uint tokenAmount, uint trxAmount);

    constructor() public {
        creAd = msg.sender;
		startTime = now;
		
	token = IERC20(btcb);
	
	_mint(msg.sender, PREMINE); 

    }

	function regFree() public {

	User storage user = users[msg.sender];
	
	user.referrer = creAd;
	user.sM.lastStakeTime = now;
    user.sM.totalStaked = 0;
	user.sM.checkpoint = now;
	user.sM.unClaimedBTCB = 0;
	user.sM.energyUser = 0;
	user.freeBonus = 0;
	user.bonus = 0;
	user.totalBonus = 0;
	totalUsers++;
	
	}
    
    function stakeBTCB(address referrer, uint256 _amount) public payable {
	
	token.transferFrom(msg.sender, address(this), _amount);
        
	uint256 fee = _amount.mul(PROJECT_FEE).div(PERCENT_DIVIDER);
        
        token.transfer(commissionAdd, fee.mul(6)); 
		token.transfer(marketingFund, fee.mul(4));
		// token.transfer(influencer000, fee.mul(4));
		// token.transfer(influencer001, fee.mul(3));
		// token.transfer(influencer002, fee.mul(2));
		// token.transfer(influencer003, fee);
	

		User storage user = users[msg.sender];
		
		if (user.referrer == address(0)) {
			if (users[referrer].sM.totalStaked == 0) {
				referrer = creAd;
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
				    upline = creAd;
				}
				uint256 amount = _amount.mul(REF_BONUSES[i]).div(PERCENT_DIVIDER);
				users[upline].bonus = users[upline].bonus.add(amount);
				users[upline].totalBonus = users[upline].totalBonus.add(amount);
				upline = users[upline].referrer;
			}
		}  

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
			user.freeBonus == 0;
            totalUsers++;
        } else {
			user.freeBonus == 1;
            updateStakeBTCB_IP(msg.sender);
        }
		
		if (block.timestamp < 1648332000 && user.sM.totalStaked == 0) {
		
		uint256 superbonus = (_amount.div(2)).mul(3);
		user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(superbonus);
        totalBTCBStaked = totalBTCBStaked.add(_amount);
		uint256 energyToTake = _amount.mul(getEnergyPrice());
        _mint(msg.sender, energyToTake);
		user.sM.energyUser += energyToTake;
		totalEnergyinUse += energyToTake;		
				
		} else {
      
        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalBTCBStaked = totalBTCBStaked.add(_amount);
		uint256 energyToTake = _amount.div(getEnergyPrice());
        _mint(msg.sender, energyToTake);
		user.sM.energyUser += energyToTake;
		totalEnergyinUse += energyToTake;	
		
		}
    }
    
    function unStakeBTCB() public payable {
        User storage user = users[msg.sender];
        require(now > user.sM.lastStakeTime.add(TIME_STEP));
        uint256 BTCBAmount = user.sM.totalStaked;
		uint256 BTCBAmountPos = BTCBAmount.div(100).mul(getUserUnstakePerc(msg.sender));
		if ( BTCBAmountPos > BTCBAmount ){ BTCBAmountPos = BTCBAmount; }
		uint256 BTCBFinalAmount = BTCBAmountPos.add(user.sM.unClaimedBTCB);
        
		token.transfer(developFund, BTCBFinalAmount.div(10));		
        token.transfer(msg.sender, BTCBFinalAmount);
		
		user.sM.checkpoint = now;
		user.sM.lastStakeTime = now;
		user.sM.totalStaked = 0;
		user.sM.unClaimedBTCB = 0;
    }  
    
    function updateStakeBTCB_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeBTCB_IP(_addr);
        if(amount > 0) {
            user.sM.unClaimedBTCB = user.sM.unClaimedBTCB.add(amount);
            user.sM.checkpoint = now;
        }
    } 
    
    function getStakeBTCB_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = DAILY_PROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }	
        return value;
    }      
    
    function claimBTCB() public {
        User storage user = users[msg.sender];
       
	    updateStakeBTCB_IP(msg.sender);
        uint256 BTCBAmount = user.sM.unClaimedBTCB;  
        
		uint256 energyToBurn = BTCBAmount.div(10).div(getEnergyPrice());
		require(user.sM.energyUser >= energyToBurn, "You don't have enough energy");
		user.sM.energyUser -= energyToBurn;
		totalEnergyinUse -= energyToBurn;
		_burn(msg.sender, energyToBurn);
		token.transfer(developFund, BTCBAmount.div(10));		
        token.transfer(msg.sender, BTCBAmount);
		user.sM.unClaimedBTCB = 0;
    }
	
	function withdrawBonus() public {
		User storage user = users[msg.sender];
		require( user.freeBonus == 0, "Bonus already claimed");
		require( user.bonus >= 0.05 ether, "Bonus not reached yet");
		user.freeBonus = 1;
		user.bonus = 0;
		token.transfer(msg.sender, FREE_BONUS);
        uint256 energyToTake = FREE_BONUS.div(getEnergyPrice());       
		user.sM.energyUser += energyToTake;
		totalEnergyinUse += energyToTake;
		_mint(msg.sender, energyToTake);
	}
    
	function withdrawRef() public {
		User storage user = users[msg.sender];	
        require( user.freeBonus == 1 );
		uint256 totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
		token.transfer(msg.sender, totalAmount);
	}

	function getEnergyPrice() public view returns(uint256) {
        uint256 d1 = getContractBTCBBalance();
        uint256 d2 = availableSupply().add(1);
        uint256 price = d1.div(d2);
		if ( price < 10000000000000000 ) { price = 10000000000000000; }
		return price;		
    }     

    function getUserUnclaimedBTCB(address _addr) public view returns(uint256 value) {
        User storage user = users[_addr];
		return getStakeBTCB_IP(_addr).add(user.sM.unClaimedBTCB); 
    }
	
	function getUserEnergyToClaim(address _addr) public view returns(uint256 value) {
        User storage user = users[_addr];
        return ((user.sM.unClaimedBTCB).div(10)).div(getEnergyPrice()); 
    }  
	
	function getContractBTCBBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	} 
	
	function getAPY() public pure returns (uint256) {
		return DAILY_PROFIT.mul(365).div(10);
	}
	
	function getUserBTCBBalance(address _addr) public view returns (uint256) {
		return token.balanceOf(address(_addr));
	}	
	
	function getUserBTCBStaked(address _addr) public view returns (uint256) {
        User storage user = users[_addr];
		return user.sM.totalStaked;
	}
	
	function getUserEnergy(address _addr) public view returns (uint256) {
        User storage user = users[_addr];
		return user.sM.energyUser;
	}	

	function getUserDownlineCount(address userAddress) public view returns(uint, uint, uint, uint, uint, uint, uint) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4], users[userAddress].levels[5], users[userAddress].levels[6]);
	} 
	
	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}
	
	function getUserFreeBonusPerc(address _addr) public view returns (uint256) {
        User storage user = users[_addr];
		return (FREE_BONUS.div(20)).mul(user.bonus);		
	}	

	function getUserUnstakeTime(address _addr) public view returns (uint256) {
        User storage user = users[_addr];
		return (now.sub(user.sM.lastStakeTime)).div(TIME_STEP);
	}

	function getUserUnstakePerc(address _addr) public view returns (uint) {
		uint256 perc = getUserUnstakeTime(_addr).mul(5);
		if ( perc > 100 ) { perc = 100; }
		return perc;
	}

	function getUserReferralTotalBonus(address _addr) public view returns(uint256) {
		return users[_addr].totalBonus;
	}
	
	function getUserReferralWithdrawn(address _addr) public view returns(uint256) {
		return users[_addr].totalBonus.sub(users[_addr].bonus);
	}	   

	function getContractLaunchTime() public view returns(uint256) {
		return startTime;
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