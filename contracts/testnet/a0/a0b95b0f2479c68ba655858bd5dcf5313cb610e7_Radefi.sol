/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

/* SafeMath removed for solidity 0.8+ */
/* info: SafeMath prevents overflow/underflow which occurs on prior versions of solidity */
/* reason: overflow/underflow checks are already done on machine level in solidity 0.8+ */

contract Radefi {
	using SafeERC20 for IERC20;
	
	uint256 public constant TIME_STEP = 60 * 60 * 24; // seconds in 1 day
	uint256 public constant MIN = 20 ether; // 20 busd
	uint256 public constant RATE_DIVISOR = 1000;
	uint256 public constant BASE_ROI = 25; // 2.5%
	uint256 public constant MAX_PROFIT_RATE = 2400; // 240%
	uint256 public constant TAX = 50; // 5%
	uint256 public constant REF_BONUS = 50; // 50%
	
	uint256 public constant BOOSTER1_COST = 100; // 10%
	uint256 public constant BOOSTER2_COST = 200; // 20%
	uint256 public constant BOOSTER3_COST = 300; // 30%
	
	uint256 public constant BOOSTER1_RATE = 5;  // 0.5%
	uint256 public constant BOOSTER2_RATE = 10; // 1.0%
	uint256 public constant BOOSTER3_RATE = 15; // 1.5%

	address private dev;
	
	uint256 totalDeposit;
	uint256 totalCompound;
	uint256 totalWithdraw;
	uint256 totalReferral;
	
	IERC20 private TokenInterface;
	
	address private constant tokenAddress = 0x2DB089EbBbefbC5EAB8C00C7BFE4AEBE37552E5d;
	uint256 public initBlock = 1673456400; // start time: 11th January 5PM GMT
	
	struct User {
		uint256 totalDeposit;
		uint256 totalCompound;
		uint256 totalInvites;
		uint256 unclaimedProfit;
		uint256 totalProfit;
		address referredBy;
		uint256 claimableRewards;
		uint256 totalRewards;
		uint256 lastAction;
		bool[3] activeBoosters;
	}

	mapping (address => User) internal users;
	
	
	event Deposit(address indexed _from, uint256 _amount);
	event Claim(address indexed _from, uint256 _amount);
	event ClaimRef(address indexed _from, uint256 _amount);
	event Compound(address indexed _from, uint256 _amount);
	event Boost(address indexed _from, uint256 _booster);
	
	constructor() {
		TokenInterface = IERC20(tokenAddress);
		dev = msg.sender;
	}
	
	/////////////////////////////////////////////////////////////////////////
	// safe transfers
	// checks source balance against transfer amount
	/////////////////////////////////////////////////////////////////////////
	function tokenTransfer(address _to, uint256 _amount) private {
		uint256 _balance = getContractBalance();
		if(_balance > _amount) {
			TokenInterface.safeTransfer(_to, _amount);
		} else {
			TokenInterface.safeTransfer(_to, _balance);
		}
	}
	/////////////////////////////////////////////////////////////////////////
	// end safe transfer functions
	/////////////////////////////////////////////////////////////////////////


	// tax is automatically deducted and is reflected in deposit value
	function deposit(address _ref, uint256 _amount) public {
		require(block.timestamp >= initBlock);
		require(_amount >= MIN);
	   
		// check if user referral address is empty
		// once referral is set, it cannot be modified
		if(users[msg.sender].referredBy == address(0)) {
			// referral address should be registered, not self, not empty
			if(users[_ref].lastAction != 0 && _ref != msg.sender && _ref != address(0)) {
				// save referral
				users[msg.sender].referredBy = _ref;
				users[_ref].totalInvites += 1;
			}
		}
		
		// subtract deposit tax first before making calculations
		uint256 _tax = _amount * TAX / RATE_DIVISOR;
		_amount -= _tax;
		
		// reflect referral rewards
		_ref = users[msg.sender].referredBy;
		if(_ref != address(0)) {
			uint256 _refBonus = _amount * REF_BONUS / RATE_DIVISOR;
			users[_ref].claimableRewards += _refBonus;
		}
			
		// for existing users: save current profit and update total deposit
		// reason: lastAction is updated to the current block.timestamp
		if(users[msg.sender].lastAction > 0) {
			users[msg.sender].unclaimedProfit = getUserWithdrawable(msg.sender);
		}
		
		// remove boosters
		users[msg.sender].activeBoosters[0] = false;
		users[msg.sender].activeBoosters[1] = false;
		users[msg.sender].activeBoosters[2] = false;
		
		users[msg.sender].totalDeposit += _amount;
		users[msg.sender].lastAction = block.timestamp;
		
		// send tax to dev
        TokenInterface.safeTransferFrom(msg.sender, dev, _tax);
		
		// deposit to contract
        TokenInterface.safeTransferFrom(msg.sender, address(this), _amount);
		
		totalDeposit += _amount;
		
		emit Deposit(msg.sender, _amount);
	}
	
	function claim() public {
		require(block.timestamp >= initBlock);
		require(users[msg.sender].lastAction > 0);
		
		uint256 _profit = getUserWithdrawable(msg.sender);
		
		// update user data
		users[msg.sender].unclaimedProfit = 0;
		users[msg.sender].totalProfit += _profit;
		users[msg.sender].lastAction = block.timestamp;
		
		totalWithdraw += _profit;
        
		tokenTransfer(msg.sender, _profit);
		emit Claim(msg.sender, _profit);
	}
	
	function claimRef() public {
		require(block.timestamp >= initBlock);
		require(users[msg.sender].lastAction > 0);
		require(users[msg.sender].claimableRewards > 0);
		
		uint256 _rewards = users[msg.sender].claimableRewards;
		
		// update user data
		users[msg.sender].claimableRewards = 0;
		users[msg.sender].totalRewards += _rewards;
		users[msg.sender].unclaimedProfit = getUserWithdrawable(msg.sender);
		users[msg.sender].lastAction = block.timestamp;
		
		totalReferral += _rewards;

		tokenTransfer(msg.sender, _rewards);
		emit ClaimRef(msg.sender, _rewards);
	}
	
	function compound() public {
		require(block.timestamp >= initBlock);
		require(users[msg.sender].lastAction > 0);
		
		uint256 _profit = getUserWithdrawable(msg.sender);
		
		// update user data
		users[msg.sender].unclaimedProfit = 0;
		users[msg.sender].totalCompound += _profit;
		users[msg.sender].lastAction = block.timestamp;
		
		totalCompound += _profit;
		emit Compound(msg.sender, _profit);
	}
	
	function compoundRef() public {
		require(block.timestamp >= initBlock);
		require(users[msg.sender].lastAction > 0);
		require(users[msg.sender].claimableRewards > 0);
		
		uint256 _rewards = users[msg.sender].claimableRewards;
		
		// update user data
		users[msg.sender].claimableRewards = 0;
		users[msg.sender].totalCompound += _rewards;
		users[msg.sender].totalRewards += _rewards;
		users[msg.sender].unclaimedProfit = getUserWithdrawable(msg.sender);
		users[msg.sender].lastAction = block.timestamp;
		
		totalReferral += _rewards;
		emit Compound(msg.sender, _rewards);
	}
	
	function boost(uint256 _booster) public {
		require(block.timestamp >= initBlock);
		require(users[msg.sender].lastAction > 0);
		require(_booster < 3);
		
		uint256 _cost = getBoosterCost(_booster);
		
		// subtract deposit tax first before making calculations
		uint256 _tax = _cost * TAX / RATE_DIVISOR;
		_cost -= _tax;
		
		// send tax to dev        
        TokenInterface.safeTransferFrom(msg.sender, dev, _tax);
		
		// deposit to contract
        TokenInterface.safeTransferFrom(msg.sender, address(this), _cost);
		
		// activate booster
		users[msg.sender].activeBoosters[_booster] = true;
		
		emit Boost(msg.sender, _booster);
	}
	
	// read-only functions
	/////////////////////////////////////////////////////////////////////////////
	// gets unclaimed profit & current profit
	function getUserWithdrawable(address _addr) public view returns(uint256) {
		if(users[_addr].lastAction > 0) {
			uint256 _unclaimedProfit = users[_addr].unclaimedProfit;
			uint256 _currentProfit = getUserProfit(_addr);
			uint256 _maxWithdraw = getUserRemainingProfit(_addr);
			uint256 _withdrawable = _unclaimedProfit + _currentProfit;
			if(_maxWithdraw < _withdrawable) {
				return _maxWithdraw;
			} else {
				return _withdrawable;
			}
		} else {
			return 0;
		}
	}
	
	// gets only current profit, excluding unclaimed profit
	function getUserProfit(address _addr) public view returns(uint256) {
		uint256 _dailyRoi = getDailyRoi(_addr);
		uint256 _totalInvestment = getUserTotalInvestment(_addr);
		uint256 _totalBlocks = block.timestamp - users[_addr].lastAction;
		uint256 _totalProfit = _totalInvestment * _dailyRoi / RATE_DIVISOR * _totalBlocks / TIME_STEP;
		return _totalProfit;
	}

	
	function getHoldBonus(address _addr) public view returns(uint256) {
		if(getUserLastAction(_addr) > 0) {
			uint256 _elapsed = block.timestamp - getUserLastAction(_addr);
			if(_elapsed >= TIME_STEP * 7) {
				return 7; // 0.7% (0.1 + 0.2 + 0.4)
			}
			if(_elapsed >= TIME_STEP * 3) {
				return 3; // 0.3% (0.1 + 0.2)
			}
			if(_elapsed >= TIME_STEP) {
				return 1; // 0.1%
			}
		}
		return 0;
	}
	
	function getInviteBonus(address _addr) public view returns(uint256) {
		uint256 _total = getUserTotalInvites(_addr);
		if(_total >= 50) {
			return 7; // 0.7% (0.1 + 0.2 + 0.4)
		}
		if(_total >= 30) {
			return 3; // 0.3% (0.1 + 0.2)
		}
		if(_total >= 10) {
			return 1; // 0.1%
		}
		return 0;
	}
	
	function getCompoundBonus(address _addr) public view returns(uint256) {
		if(getUserTotalDeposit(_addr) == 0) return 0; // avoid division by zero
		uint256 _comp = getUserTotalCompound(_addr) * RATE_DIVISOR / getUserTotalDeposit(_addr);
		if(_comp >= 1000) {
			return 11; // 1.1% (0.2 + 0.4 + 0.5)
		}
		if(_comp >= 500) {
			return 6; // 0.6% (0.2 + 0.4)
		}
		if(_comp >= 200) {
			return 2; // 0.2%
		}
		return 0;
	}
	
	function getActiveBoosters(address _addr) public view returns(bool[3] memory) {
		return users[_addr].activeBoosters;
	}
	
	// return value must be divided by RATE_DIVISOR to get percentage
	function getDailyRoi(address _addr) public view returns(uint256) {
		if(users[_addr].totalDeposit > 0) {
			uint256 _roi = BASE_ROI;
			_roi += getHoldBonus(_addr);
			_roi += getInviteBonus(_addr);
			_roi += getCompoundBonus(_addr);
			_roi += getUserTotalBoost(_addr);
			return _roi;
		} else {
			return BASE_ROI;
		}
	}

	function getUserTotalInvestment(address _addr) public view returns(uint256) {
		return users[_addr].totalDeposit + users[_addr].totalCompound;
	}

	function getUserTotalDeposit(address _addr) public view returns(uint256) {
		return users[_addr].totalDeposit;
	}
	
	function getUserTotalProfit(address _addr) public view returns(uint256) {
		return users[_addr].totalProfit;
	}
	
	function getUserUnclaimedProfit(address _addr) public view returns(uint256) {
		return users[_addr].unclaimedProfit;
	}
	
	function getUserTotalCompound(address _addr) public view returns(uint256) {
		return users[_addr].totalCompound;
	}
	
	function getUserTotalInvites(address _addr) public view returns(uint256) {
		return users[_addr].totalInvites;
	}
	
	function getUserTotalBoost(address _addr) public view returns(uint256 total) {
		if(users[_addr].activeBoosters[0] == true) total += BOOSTER1_RATE;
		if(users[_addr].activeBoosters[1] == true) total += BOOSTER2_RATE;
		if(users[_addr].activeBoosters[2] == true) total += BOOSTER3_RATE;
	}
	
	function getUserLastAction(address _addr) public view returns(uint256) {
		return users[_addr].lastAction;
	}
	
	function getUserReferrer(address _addr) public view returns(address) {
		return users[_addr].referredBy;
	}
	
	function getUserRemainingProfit(address _addr) public view returns(uint256) {
		uint256 _maxProfit = getUserTotalInvestment(_addr) * MAX_PROFIT_RATE / RATE_DIVISOR;
		uint256 _totalProfit = users[_addr].totalProfit;
		if(_totalProfit < _maxProfit) {
			return _maxProfit - _totalProfit;
		} else {
			return 0;
		}
	}
	
	// returns total referral, claimed + unclaimed rewards
	function getUserTotalReferral(address _addr) public view returns(uint256) {
		uint256 _claimable = getUserClaimableRewards(_addr);
		uint256 _claimed = users[_addr].totalRewards;
		return _claimable + _claimed;
	}
	
	function getUserClaimableRewards(address _addr) public view returns(uint256) {
		return users[_addr].claimableRewards;
	}
	
	function getBoosterCost(uint256 _booster) public view returns(uint256) {
		if(_booster == 0) {
			return getUserTotalDeposit(msg.sender) * BOOSTER1_COST / RATE_DIVISOR;
		}
		if(_booster == 1) {
			return getUserTotalDeposit(msg.sender) * BOOSTER2_COST / RATE_DIVISOR;
		}
		if(_booster == 2) {
			return getUserTotalDeposit(msg.sender) * BOOSTER3_COST / RATE_DIVISOR;
		}
        return 0;
	}

	function getContractBalance() public view returns(uint256) {
		return TokenInterface.balanceOf(address(this));
	}
	
	// used for front-end sync & animations
	function getCurrentBlock() public view returns(uint256) {
		return block.timestamp;
	}
	function syncFrontEnd() public view returns(uint256[14] memory, bool[3] memory) {
		return ([getContractBalance(),
				getUserTotalDeposit(msg.sender),
				getUserTotalProfit(msg.sender),
				getUserTotalCompound(msg.sender),
				getUserRemainingProfit(msg.sender),
				getUserTotalReferral(msg.sender),
				getUserClaimableRewards(msg.sender),
				getUserTotalInvites(msg.sender),
				getUserLastAction(msg.sender),
				getDailyRoi(msg.sender),
				getUserWithdrawable(msg.sender),
				getHoldBonus(msg.sender),
				getInviteBonus(msg.sender),
				getCompoundBonus(msg.sender)],
				getActiveBoosters(msg.sender));
	}
	
	// user.lastAction is initialized with block.timestamp
	function newUser() public view returns(bool) {
		address _addr = msg.sender;
		if(users[_addr].lastAction != 0){
			return false;
		}
		else{
			return true;
		}
	}
}