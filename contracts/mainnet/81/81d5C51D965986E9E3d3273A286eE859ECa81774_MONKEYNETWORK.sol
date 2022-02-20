/**
 *Submitted for verification at BscScan.com on 2022-02-20
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


contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract ERC20 is IERC20, Ownable {
    using SafeMath for uint256;
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // live busd
    
    // address busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // testnet busd
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

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
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
        _name = "MONKEYNETWORK";
        _symbol = "MONKEY";
        _decimals = 18;
        _limitSupply = 1000000e18;
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

contract MONKEYNETWORK is Token {
    
    uint private startTime = 1645383600; 
    
    address payable private ADMIN;
    address payable private DEV;
    address payable private ADV;
    address payable private MAR;
    
    uint public totalUsers; 
    uint public totalBUSDStaked; 
    uint public totalTokenStaked;
    uint public totalTokenInCamp;
    uint public sentAirdrop;
    
    uint public ownerManualAirdrop;
    uint public ownerManualAirdropCheckpoint = startTime;
    
    uint8[] private REF_BONUSES             = [30, 20, 10];
    uint private constant ADV_FEE           = 25;     // 2.5% * 4 = 10%              
    uint private constant LIMIT_AIRDROP     = 50000 ether;
    uint private constant MANUAL_AIRDROP    = 50000 ether;    
    uint private constant USER_AIRDROP      = 50 ether; 
    uint private constant BONUS_AIRDROP     = 50 ether;
    uint public BUSD_DAILYPROFIT            = 15;
    uint public TOKEN_DAILYPROFIT           = 20;
    uint public CAMP_DAILYPROFIT            = 20;
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant PRICE_DIVIDER     = 1 ether;
    uint private constant TIME_STEP         = 1 days;
    uint private constant TIME_TO_UNSTAKE   = 7 days;
    uint private constant NEXT_AIRDROP      = 7 days;
    uint private constant BON_AIRDROP       = 3;
    uint public SELL_LIMIT                  = 40000 ether;
    uint private constant SELL_BURN_FEE     = 20;
    uint private constant SELL_MARKETING_FEE= 10;

    bool public allowBurn;
    
    mapping(address => User) private users;
    mapping(address => bool) public blackList;
    mapping(uint => uint) private sold; 
    
    struct Stake {
        uint checkpoint;
        uint totalStaked; 
        uint lastStakeTime;
        uint unClaimedTokens;
    }
    
    struct User {
        address referrer;
        uint lastAirdrop;
        uint countAirdrop;
        uint bonAirdrop;
        Stake sM;
        Stake sT;  
        Stake sC;
		uint256 bonus;
		uint256 totalBonus;
        uint totaReferralBonus;
        uint[3] levels;
        mapping(uint => uint) sold;
    }

    event TokenOperation(address indexed account, string txType, uint tokenAmount, uint trxAmount);

    constructor() public {
        token = IERC20(busd);

        ADMIN = msg.sender;
        DEV = msg.sender;
        ADV = 0x9f0Cad0EfFDa702E51fb811e34887511e6092F64;
        MAR = 0x9f0Cad0EfFDa702E51fb811e34887511e6092F64;

        _mint(msg.sender, MANUAL_AIRDROP.div(5));  
    }       
    
    function stakeBUSD(address referrer,  uint256 _amount) public {
        require (block.timestamp > 1645383600);                // February 20, 2022 17:00:00 PM GMT
        
        token.transferFrom(msg.sender, address(this), _amount);     // added
        
		uint fee = _amount.mul(ADV_FEE).div(PERCENT_DIVIDER);   // calculate fees on _amount and not msg.value
        
        token.transfer(ADMIN, fee);
        token.transfer(ADV, fee);     

        token.transfer(MAR, fee);
        token.transfer(DEV, fee);

		User storage user = users[msg.sender];
		
		if (user.referrer == address(0) && msg.sender != ADMIN) {
			if (users[referrer].sM.totalStaked == 0) {
				referrer = ADMIN;
			}
			user.referrer = referrer;
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					if (i == 0 && user.sM.totalStaked.add(_amount) >= BONUS_AIRDROP) {
					    users[upline].bonAirdrop = users[upline].bonAirdrop.add(1);
					}
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < REF_BONUSES.length; i++) {
				if (upline == address(0)) {
				    upline = ADMIN;
				}
				uint256 amount = _amount.mul(REF_BONUSES[i]).div(PERCENT_DIVIDER);
				users[upline].bonus = users[upline].bonus.add(amount);
				users[upline].totalBonus = users[upline].totalBonus.add(amount);
				upline = users[upline].referrer;
			}
		} 

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            totalUsers++;
        } else {
            updateStakeBUSD_IP(msg.sender);
        }
      
        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalBUSDStaked = totalBUSDStaked.add(_amount);
    }

    function compoundToStakeBUSD(uint256 _amount) private {
        require (block.timestamp > 1645383600);                // February 20, 2022 17:00:00 PM GMT

		User storage user = users[msg.sender];
		
        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            totalUsers++;
        } else {
            updateStakeBUSD_IP(msg.sender);
        }
      
        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalBUSDStaked = totalBUSDStaked.add(_amount);
    }
    
    function stakeToken(uint tokenAmount) public {

        User storage user = users[msg.sender];
        require(now >= startTime, "Stake not available yet");
        require(tokenAmount <= balanceOf(msg.sender), "Insufficient Token Balance");

        if (user.sT.totalStaked == 0) {
            user.sT.checkpoint = now;
        } else {
            updateStakeToken_IP(msg.sender);
        }
        
        _transfer(msg.sender, address(this), tokenAmount);
        user.sT.lastStakeTime = now;
        user.sT.totalStaked = user.sT.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 
    } 

    function compoundToStakeToken(uint tokenAmount) private {
        User storage user = users[msg.sender];
        require(now >= startTime, "Stake not available yet");

        if (user.sT.totalStaked == 0) {
            user.sT.checkpoint = now;
        } else {
            updateStakeToken_IP(msg.sender);
        }
        
        // user.sT.lastStakeTime = now;
        user.sT.totalStaked = user.sT.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 
    } 
    
    function unStakeToken() public {
        User storage user = users[msg.sender];
        require(now > user.sT.lastStakeTime.add(TIME_TO_UNSTAKE));
        updateStakeToken_IP(msg.sender);
        uint tokenAmount = user.sT.totalStaked;
        user.sT.totalStaked = 0;
        totalTokenStaked = totalTokenStaked.sub(tokenAmount); 
        _transfer(address(this), msg.sender, tokenAmount);
    }

    function stakeToCamp(uint256 tokenAmount) private {
        User storage user = users[msg.sender];
        require(now >= startTime, "Stake not available yet");

        if (user.sC.totalStaked == 0) {
            user.sC.checkpoint = now;
        } else {
            updateCampToken(msg.sender);
        }
        
        user.sC.lastStakeTime = now;
        user.sC.totalStaked = user.sC.totalStaked.add(tokenAmount);
        totalTokenInCamp = totalTokenInCamp.add(tokenAmount); 
    }
    
    function updateStakeBUSD_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeBUSD_IP(_addr);
        if(amount > 0) {
            user.sM.unClaimedTokens = user.sM.unClaimedTokens.add(amount);
            user.sM.checkpoint = now;
        }
    } 
    
    function getStakeBUSD_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = BUSD_DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }  
    
    function updateStakeToken_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeToken_IP(_addr);
        if(amount > 0) {
            user.sT.unClaimedTokens = user.sT.unClaimedTokens.add(amount);
            user.sT.checkpoint = now;
        }
    } 

    function updateCampToken(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getCampToken_IP(_addr);
        if(amount > 0) {
            user.sC.unClaimedTokens = user.sC.unClaimedTokens.add(amount);
            user.sC.checkpoint = now;
        }
    }
    
    function getStakeToken_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sT.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = TOKEN_DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sT.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }

    function getCampToken_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sC.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = CAMP_DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sC.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }     
    
    function claimToken_M() public {
        User storage user = users[msg.sender];
       
        updateStakeBUSD_IP(msg.sender);
        uint tokenAmount = user.sM.unClaimedTokens;  
        if(tokenAmount == 0)
            return;
        user.sM.unClaimedTokens = 0;                 
        
        uint claimAmount = tokenAmount.mul(75).div(100);
        _mint(msg.sender, claimAmount);
        stakeToCamp(tokenAmount.sub(claimAmount));

        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }

    function compoundToken_M() public {
        // Claim from mint
        User storage user = users[msg.sender];
       
        updateStakeBUSD_IP(msg.sender);
        uint tokenAmount = user.sM.unClaimedTokens;
        if(tokenAmount == 0)
            return;
        user.sM.unClaimedTokens = 0;

        uint stakeAmount = tokenAmount.mul(75).div(100);

        _mint(address(this), stakeAmount);

        stakeToCamp(tokenAmount.sub(stakeAmount));
        compoundToStakeToken(stakeAmount);
    }
    
    function claimToken_T() public {
        User storage user = users[msg.sender];
       
        updateStakeToken_IP(msg.sender);
        uint tokenAmount = user.sT.unClaimedTokens; 
        user.sT.unClaimedTokens = 0;
        if(tokenAmount == 0)
            return;

        uint claimAmount = tokenAmount.mul(75).div(100);
        _mint(msg.sender, claimAmount);
        stakeToCamp(tokenAmount.sub(claimAmount));
        
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }
    
    function compoundToken_T() public {
        User storage user = users[msg.sender];
       
        updateStakeToken_IP(msg.sender);
        uint tokenAmount = user.sT.unClaimedTokens; 
        user.sT.unClaimedTokens = 0; 
        if(tokenAmount == 0)
            return;

        uint stakeAmount = tokenAmount.mul(75).div(100);

        _mint(address(this), stakeAmount);

        stakeToCamp(tokenAmount.sub(stakeAmount));
        compoundToStakeToken(stakeAmount);
        
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }

    function compoundToken_C() public {
        User storage user = users[msg.sender];
       
        updateCampToken(msg.sender);
        uint tokenAmount = user.sC.unClaimedTokens; 
        user.sT.unClaimedTokens = 0; 

        uint tokenToStake = tokenAmount.div(2);
        uint busdToMint = tokenToBUSD(tokenAmount - tokenToStake);

        _mint(address(this), tokenToStake);
        
        compoundToStakeToken(tokenToStake);
        compoundToStakeBUSD(busdToMint);

        emit TokenOperation(msg.sender, "COMPOUND", tokenAmount, 0);
    }
    
    function sellToken(uint tokenAmount) public {
        User storage user = users[msg.sender];
        tokenAmount = minVal(tokenAmount, balanceOf(msg.sender));
        require(!blackList[msg.sender], "address is in black list");
        require(tokenAmount > 0, "Token amount can not be 0");
        
        require(sold[getCurrentDay()].add(tokenAmount) <= SELL_LIMIT, "Daily Sell Limit exceed");
        require(user.sold[getCurrentDay()].add(tokenAmount) <= getUserSellLimit(), "Daily Sell Limit exceed");

        sold[getCurrentDay()] = sold[getCurrentDay()].add(tokenAmount);
        user.sold[getCurrentDay()] = user.sold[getCurrentDay()].add(tokenAmount);
        uint burnFee = tokenAmount.mul(SELL_BURN_FEE).div(PERCENT_DIVIDER);
        uint marketingFee = tokenAmount.mul(SELL_MARKETING_FEE).div(PERCENT_DIVIDER);
        uint BUSDAmount = tokenToBUSD(tokenAmount - burnFee - marketingFee);
    
        require(getContractBUSDBalance() > BUSDAmount, "Insufficient Contract Balance");
        if(allowBurn) {
            _burn(msg.sender, tokenAmount - marketingFee);
        }
        else {
            _burn(msg.sender, tokenAmount - marketingFee - burnFee);
            _transfer(msg.sender, DEV, burnFee);
        }

        _transfer(msg.sender, MAR, marketingFee);

       token.transfer(msg.sender, BUSDAmount);
        
        emit TokenOperation(msg.sender, "SELL", tokenAmount, BUSDAmount);
    }

    function setAddresss(uint selector, address payable _addr) public {
        require(_addr != address(0), "can't set address with zero address");
        if(selector == 0) 
            ADV = _addr;
        else if(selector == 1)
            MAR = _addr;
    }
    
    function getCurrentUserBonAirdrop(address _addr) public view returns (uint) {
        return users[_addr].bonAirdrop;
    }  
    
    function claimAirdrop() public {
        require(getAvailableAirdrop() >= USER_AIRDROP, "Airdrop limit exceed");
        require(users[msg.sender].sM.totalStaked >= getUserAirdropReqInv());
        require(now > users[msg.sender].lastAirdrop.add(NEXT_AIRDROP));
        require(users[msg.sender].bonAirdrop >= BON_AIRDROP);
        // users[msg.sender].countAirdrop++;
        users[msg.sender].lastAirdrop = now;
        users[msg.sender].bonAirdrop = 0;
        _mint(msg.sender, USER_AIRDROP);
        sentAirdrop = sentAirdrop.add(USER_AIRDROP);
        emit TokenOperation(msg.sender, "AIRDROP", USER_AIRDROP, 0);
    }
    
    function claimAirdropM() public onlyOwner {
        uint amount = 5000 ether;
        ownerManualAirdrop = ownerManualAirdrop.add(amount);
        require(ownerManualAirdrop <= MANUAL_AIRDROP, "Airdrop limit exceed");
        require(now >= ownerManualAirdropCheckpoint.add(5 days), "Time limit error");
        ownerManualAirdropCheckpoint = now;
        _mint(msg.sender, amount); 
        emit TokenOperation(msg.sender, "AIRDROP", amount, 0);
    }    
    
	function withdrawRef() public {
		User storage user = users[msg.sender];
		
		uint totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
		//msg.sender.transfer(totalAmount);
		token.transfer(msg.sender, totalAmount);
	}

    function withdraw(uint256 _amount) public onlyOwner {
        token.transfer(owner(), _amount);
    }

    function updateParams(uint key, uint _value) public onlyOwner {
        if(key == 0) {
            SELL_LIMIT = _value;
        }
        else if(key == 1) {
            BUSD_DAILYPROFIT = _value;
        }
        else if(key == 2) {
            TOKEN_DAILYPROFIT = _value;
        }
        else if(key == 3) {
            CAMP_DAILYPROFIT = _value;
        }
    }

    function toggleBurn() public onlyOwner {
        allowBurn = !allowBurn;
    }

    function toggleBlackList(address _addr) onlyOwner public {
        blackList[_addr] = !blackList[_addr];
    }

    function getUserUnclaimedTokens_M(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeBUSD_IP(_addr).add(user.sM.unClaimedTokens); 
    }
    
    function getUserUnclaimedTokens_T(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeToken_IP(_addr).add(user.sT.unClaimedTokens); 
    }  

    function getUserUnclaimedTokens_C(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getCampToken_IP(_addr).add(user.sC.unClaimedTokens); 
    }  
    
	function getAvailableAirdrop() public view returns (uint) {
		return minZero(LIMIT_AIRDROP, sentAirdrop);
	}   
	
    function getUserTimeToNextAirdrop(address _addr) public view returns (uint) {
        return minZero(users[_addr].lastAirdrop.add(NEXT_AIRDROP), now);
    } 
    
    function getUserBonAirdrop(address _addr) public view returns (uint) {
        return users[_addr].bonAirdrop;
    }

    function getUserAirdropReqInv() public pure returns (uint) {
        return 100 ether;
    }
    
    function getUserCountAirdrop(address _addr) public view returns (uint) {
        return users[_addr].countAirdrop;
    }     
    
	function getContractBUSDBalance() public view returns (uint) {
	    // return address(this).balance;
	    return token.balanceOf(address(this));
	}  
	
	function getContractTokenBalance() public view returns (uint) {
		return balanceOf(address(this));
	}  
	
	function getAPY_M() public view returns (uint) {
		return BUSD_DAILYPROFIT.mul(365).div(10);
	}
	
	function getAPY_T() public view returns (uint) {
		return TOKEN_DAILYPROFIT.mul(365).div(10);
	}

    function getAPY_C() public view returns (uint) {
		return CAMP_DAILYPROFIT.mul(365).div(10);
	}
	
	function getUserBUSDBalance(address _addr) public view returns (uint) {
		return address(_addr).balance;
	}	
	
	function getUserTokenBalance(address _addr) public view returns (uint) {
		return balanceOf(_addr);
	}
	
	function getUserBUSDStaked(address _addr) public view returns (uint) {
		return users[_addr].sM.totalStaked;
	}	
	
	function getUserTokenStaked(address _addr) public view returns (uint) {
		return users[_addr].sT.totalStaked;
	}

    function getUserCampStaked(address _addr) public view returns (uint) {
        return users[_addr].sC.totalStaked;
    }
	
	function getUserTimeToUnstake(address _addr) public view returns (uint) {
		return  minZero(users[_addr].sT.lastStakeTime.add(TIME_TO_UNSTAKE), now);
	}	
	
    function getTokenPrice() public view returns(uint) {
        uint d1 = getContractBUSDBalance().mul(PRICE_DIVIDER);
        uint d2 = availableSupply().add(1);
        return d1.div(d2);
    } 

    function BUSDToToken(uint BUSDAmount) public view returns(uint) {
        return BUSDAmount.mul(PRICE_DIVIDER).div(getTokenPrice());
    }

    function tokenToBUSD(uint tokenAmount) public view returns(uint) {
        return tokenAmount.mul(getTokenPrice()).div(PRICE_DIVIDER);
    } 	

	function getUserDownlineCount(address userAddress) public view returns(uint, uint, uint) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
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
	
    function getCurrentDay() public view returns (uint) {
        return minZero(now, startTime).div(TIME_STEP);
    }	
    
    function getTokenSoldToday() public view returns (uint) {
        return sold[getCurrentDay()];
    }

    function getTokenSoldTodayForUser(address _user) public view returns (uint) {
        return users[_user].sold[getCurrentDay()];
    } 
    
    function getTokenAvailableToSell() public view returns (uint) {
       return minZero(SELL_LIMIT, sold[getCurrentDay()]);
    }

    function getTokenAvailableToSellForOneUser(address _user) public view returns (uint) {
       return minZero(getUserSellLimit(), users[_user].sold[getCurrentDay()]);
    }

    function getUserSellLimit() public view returns (uint) {
        if(totalSupply().div(200) > 2000)
            return 2000;
        return totalSupply().div(200);
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