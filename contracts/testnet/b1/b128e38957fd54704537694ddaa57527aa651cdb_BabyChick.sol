/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity 0.5.10;

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
        _name = "Baby Chick";
        _symbol = "BABYCHICK";
        _decimals = 18;
        _limitSupply = 500000e18;
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

contract BabyChick is Token {
    
    uint256 public totalUsers; 
    uint256 public totalStaked; 
    uint256 public totalTokenStaked;
        
    uint8[] private REF_BONUSES = [50, 20, 10, 10, 10];
	uint256 private constant CEO_FEE = 90;
	uint256 private constant DEV_FEE = 10;

    uint256 private constant MIN_STAKE  = 0.001 ether;
    uint256 private constant PRICE_RATIO  = 5;
    uint256 private constant DAILYPROFIT  = 2000;
    uint256 private constant TOKEN_DAILYPROFIT = 60;
    uint256 private constant PERCENTS_DIVIDER  = 1000;
    uint256 private constant PRICE_DIVIDER     = 1 ether;
    uint256 private constant TIME_STEP         = 1 days;
    uint256 private constant TIME_TO_UNSTAKE   = 7 days;
    uint256 public SELL_LIMIT = 8000 ether; 
    
    mapping(address => User) private users;
    mapping(uint256 => uint256) private sold; 
    
    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked; 
        uint256 lastStakeTime;
        uint256 unClaimedTokens;        
    }
    
    struct User {
        address referrer;
        Stake sM;
        Stake sT;  
		uint256 bonus;
		uint256 totalBonus;
        uint256 totaReferralBonus;
        uint256[5] levels;
    }

    event NewStake(address indexed user, uint256 amount, uint256 time);
    event NewStakeToken(address indexed user, uint256 amount, uint256 time);
	event UnStakeToken(address indexed user, uint256 amount, uint256 time);
	event WithdrawRef(address indexed user, uint256 amount, uint256 time);
    event Sell(address indexed account, uint256 tokenAmount, uint256 amount, uint256 time);
    event Claim(address indexed account, uint256 tokenAmount, uint256 time);
    event FeePaid(address indexed user, uint256 totalAmount);


    uint256 public startDate;
	address payable public ceoWallet;
	address payable public devWallet;

	constructor(address payable ceoAddr, address payable devAddr, uint256 start) public {
		require(!isContract(ceoAddr) && !isContract(devAddr));
		ceoWallet = ceoAddr;
		devWallet = devAddr;
		if(start > 0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}
    }       
    
    
    function stake(address referrer) public payable {
        require (block.timestamp > startDate, "not launched yet");
        require (msg.value >= MIN_STAKE, "min stake is 0.01 BNB");
        uint256 _amount = msg.value;
        
        uint256 ceo = _amount.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		uint256 dFee = _amount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		ceoWallet.transfer(ceo);
		devWallet.transfer(dFee);
		emit FeePaid(msg.sender, ceo.add(dFee));

		User storage user = users[msg.sender];
		
		if (user.referrer == address(0) && msg.sender != ceoWallet) {
			if (users[referrer].sM.totalStaked == 0) {
				referrer = ceoWallet;
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
				uint256 amount = _amount.mul(REF_BONUSES[i]).div(PERCENTS_DIVIDER);
				users[upline].bonus = users[upline].bonus.add(amount);
				users[upline].totalBonus = users[upline].totalBonus.add(amount);
				upline = users[upline].referrer;
			}
		} 

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(block.timestamp, startDate);
            totalUsers++;
        } else {
            updateStake(msg.sender);
        }
      
        user.sM.lastStakeTime = block.timestamp;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalStaked = totalStaked.add(_amount);
        emit NewStake(msg.sender, _amount, block.timestamp);
    }
    
    function stakeToken(uint256 tokenAmount) public {

        User storage user = users[msg.sender];
        require (block.timestamp > startDate, "not launched yet");
        require(tokenAmount <= balanceOf(msg.sender), "Insufficient Token Balance");

        if (user.sT.totalStaked == 0) {
            user.sT.checkpoint = block.timestamp;
        } else {
            updateStakeToken(msg.sender);
        }
        
        _transfer(msg.sender, address(this), tokenAmount);
        user.sT.lastStakeTime = block.timestamp;
        user.sT.totalStaked = user.sT.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 
        emit NewStakeToken(msg.sender, tokenAmount, block.timestamp);
    } 
    
    function unStakeToken() public {
        User storage user = users[msg.sender];
        require(block.timestamp > user.sT.lastStakeTime.add(TIME_TO_UNSTAKE));
        updateStakeToken(msg.sender);
        uint256 tokenAmount = user.sT.totalStaked;
        user.sT.totalStaked = 0;
        totalTokenStaked = totalTokenStaked.sub(tokenAmount); 
        _transfer(address(this), msg.sender, tokenAmount);
        emit UnStakeToken(msg.sender, tokenAmount, block.timestamp);
    }  
    
    function updateStake(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStake(_addr);
        if(amount > 0) {
            user.sM.unClaimedTokens = user.sM.unClaimedTokens.add(amount);
            user.sM.checkpoint = block.timestamp;
        }
    } 
    
    function getStake(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startDate > block.timestamp) {
          fr = block.timestamp; 
        }
        uint256 Tarif = DAILYPROFIT;
        uint256 to = block.timestamp;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENTS_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }  
    
    function updateStakeToken(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeToken(_addr);
        if(amount > 0) {
            user.sT.unClaimedTokens = user.sT.unClaimedTokens.add(amount);
            user.sT.checkpoint = block.timestamp;
        }
    } 
    
    function getStakeToken(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sT.checkpoint;
        if (startDate > block.timestamp) {
          fr = block.timestamp; 
        }
        uint256 Tarif = TOKEN_DAILYPROFIT;
        uint256 to = block.timestamp;
        if(fr < to) {
            value = user.sT.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENTS_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }      
    
    function claimToken_M() public {
        User storage user = users[msg.sender];
       
        updateStake(msg.sender);
        uint256 tokenAmount = user.sM.unClaimedTokens;  
        user.sM.unClaimedTokens = 0;                 
        
        _mint(msg.sender, tokenAmount);
        emit Claim(msg.sender, tokenAmount, block.timestamp);
    }    
    
    function claimToken_T() public {
        User storage user = users[msg.sender];
       
        updateStakeToken(msg.sender);
        uint256 tokenAmount = user.sT.unClaimedTokens; 
        user.sT.unClaimedTokens = 0; 
        
        _mint(msg.sender, tokenAmount);
        emit Claim(msg.sender, tokenAmount, block.timestamp);
    }     
    
    function sellToken(uint256 tokenAmount) public {
        tokenAmount = minVal(tokenAmount, balanceOf(msg.sender));
        require(tokenAmount > 0, "Token amount can not be 0");
        
        require(sold[getCurrentDay()].add(tokenAmount) <= SELL_LIMIT, "Daily Sell Limit exceed");
        sold[getCurrentDay()] = sold[getCurrentDay()].add(tokenAmount);
        uint256 Amount = tokenTo(tokenAmount);
    
        require(getContractBalance() > Amount, "Insufficient Contract Balance");
        _burn(msg.sender, tokenAmount);

       (msg.sender).transfer(Amount);
        
        emit Sell(msg.sender, tokenAmount, Amount, block.timestamp);
    }

	function withdrawRef() public {
		User storage user = users[msg.sender];
		
		uint256 totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
        (msg.sender).transfer(totalAmount);
        emit WithdrawRef(msg.sender, totalAmount, block.timestamp);
	}	    

    function getUserUnclaimedTokens_M(address _addr) public view returns(uint256 value) {
        User storage user = users[_addr];
        return getStake(_addr).add(user.sM.unClaimedTokens); 
    }
    
    function getUserUnclaimedTokens_T(address _addr) public view returns(uint256 value) {
        User storage user = users[_addr];
        return getStakeToken(_addr).add(user.sT.unClaimedTokens); 
    }         
    
	function getContractBalance() public view returns (uint256) {
	    return address(this).balance;
	}  
	
	function getContractTokenBalance() public view returns (uint256) {
		return balanceOf(address(this));
	}  
	
	function getAPY_M() public pure returns (uint256) {
		return DAILYPROFIT.mul(365).div(10);
	}
	
	function getAPY_T() public pure returns (uint256) {
		return TOKEN_DAILYPROFIT.mul(365).div(10);
	}	
	
	function getUserBalance(address _addr) public view returns (uint256) {
		return address(_addr).balance;
	}	
	
	function getUserTokenBalance(address _addr) public view returns (uint256) {
		return balanceOf(_addr);
	}
	
	function getUserStaked(address _addr) public view returns (uint256) {
		return users[_addr].sM.totalStaked;
	}	
	
	function getUserTokenStaked(address _addr) public view returns (uint256) {
		return users[_addr].sT.totalStaked;
	}
	
	function getUserTimeToUnstake(address _addr) public view returns (uint256) {
		return  minZero(users[_addr].sT.lastStakeTime.add(TIME_TO_UNSTAKE), block.timestamp);
	}	
	
    function getTokenPrice() public view returns(uint256) {
        uint256 d1 = getContractBalance().mul(PRICE_DIVIDER);
        uint256 d2 = availableSupply().add(1);
        return d1.div(d2).mul(PRICE_RATIO);
    } 

    function toToken(uint256 Amount) public view returns(uint256) {
        return Amount.mul(PRICE_DIVIDER).div(getTokenPrice());
    }

    function tokenTo(uint256 tokenAmount) public view returns(uint256) {
        return tokenAmount.mul(getTokenPrice()).div(PRICE_DIVIDER);
    } 	

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4]);
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
    
	function getContractLaunchTime() public view returns(uint256) {
		return minZero(startDate, block.timestamp);
	}
	
    function getCurrentDay() public view returns (uint256) {
        return minZero(block.timestamp, startDate).div(TIME_STEP);
    }	
    
    function getTokenSoldToday() public view returns (uint256) {
        return sold[getCurrentDay()];
    }   
    
    function getTokenAvailableToSell() public view returns (uint256) {
       return minZero(SELL_LIMIT, sold[getCurrentDay()]);
    }  
    
    function getTimeToNextDay() public view returns (uint256) {
        uint256 t = minZero(block.timestamp, startDate);
        uint256 g = getCurrentDay().mul(TIME_STEP);
        return g.add(TIME_STEP).sub(t);
    }

    function getGlobalInfo1() public view returns (uint256,uint256,uint256,uint256) {
        return (
            getTokenPrice(),
            limitSupply(),
            totalSupply(),
            availableSupply()
        );
    }

    function getGlobalInfo2() public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        return (
            getAPY_M(),
            getAPY_T(),
            totalStaked,
            totalTokenStaked,
            SELL_LIMIT,
            getTokenAvailableToSell(),
            getTokenSoldToday(),
            getTimeToNextDay()
        );
    }

    function getUserInfo(address addr) public view returns (uint256,uint256,uint256,uint256,uint256,uint256) {
        return (
            getUserStaked(addr),
            getUserTokenStaked(addr),
            getUserTimeToUnstake(addr),
            getUserUnclaimedTokens_M(addr),
            getUserUnclaimedTokens_T(addr),
            getUserTokenBalance(addr)
        );
    }

    function getUserRefInfo(address addr) public view returns (uint256,uint256,uint256) {
        return (
            getUserReferralBonus(addr),
            getUserReferralTotalBonus(addr),
            getUserReferralWithdrawn(addr)
        );
    }
    
    function minZero(uint256 a, uint256 b) private pure returns(uint256) {
        if (a > b) {
           return a - b; 
        } else {
           return 0;    
        }    
    }   
    
    function maxVal(uint256 a, uint256 b) private pure returns(uint256) {
        if (a > b) {
           return a; 
        } else {
           return b;    
        }    
    }
    
    function minVal(uint256 a, uint256 b) private pure returns(uint256) {
        if (a > b) {
           return b; 
        } else {
           return a;    
        }    
    }    

    function setSellLimit(uint256 amount) public {
        require(msg.sender == ceoWallet, "only owner");
        require(amount >= 6000 ether && amount <= 100000 ether, "incorrect amount");
        SELL_LIMIT = amount;
    }

	function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}