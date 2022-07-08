// SPDX-License-Identifier: MIT
import "./Ownable.sol";
import "./SafeMath.sol";
pragma solidity ^0.8.4;

contract forkbakedBeans is Ownable {
	using SafeMath for uint256;
	
	//IERC20 public token = IERC20(0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402);  token en desarrollo
	uint256 public constant MININVEST = 0.0428 ether;  //10 DOLARES;
	uint256 private devFeeVal = 600; 
	uint private withdrawnFee = 600;
	bool private initialized = false;

    uint256[2] public REFERRAL_PERCENTS = [1000, 500];   // porcentajes por nivel de usuario


	uint256 private EGGS_TO_HATCH_1MINERS = 1080000;//
	uint256 private PSN = 10000;
	uint256 private PSNH = 5000;
	//uint256 private devFeeVal = 3; //
	
    address payable public devAddress;
    address payable public marketingAddress;
    address payable public projectAddress;
	// mapping (address => uint256) private hatcheryMiners;
	// mapping (address => uint256) private claimedEggs;
	// mapping (address => uint256) private lastHatch;
	// mapping (address => address) private referrals;
	uint256 public marketEggs;

	struct User{
		uint256 invest;
		uint256 withdraw;
		uint256 hatcheryMiners;
		uint256 claimedEggs;
		uint256 lastHatch;
		uint checkpoint;
		address payable referrals;
		uint256 totalAmountByRef;
		uint256[2] levels;
	}

	mapping (address => User) public users;

	uint public totalInvested;
	uint256 public totalReinvested;
	uint256 constant internal TIME_STEP = 1 days;

	constructor(address _dev, address _mark, address _proj) {		
		devAddress = payable(_dev);
		marketingAddress = payable(_mark);
		projectAddress = payable(_proj);
	}

	modifier initializer() {
		require(initialized, "The contract is not started by owner");
		_;
	}

	function re_invest(address payable ref) external payable initializer {		
	User storage user = users[msg.sender];
//uint256 acumulateProfit =currentProfitbyuser(user.invest, user.checkpoint);
	//	require(msg.value <= acumulateProfit, "The re-invest amount cannot be higher than the actual profit");
		require(msg.value >= MININVEST, "insufficient deposit to reinvest here");

	uint256 fee = devFee(msg.value);
	
	payFees(fee);
	user.invest += msg.value;

		if(user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		

		address currentReferred = user.referrals;
        	for (uint256 i; i < 2; i++) {
        		
        		if (currentReferred != address(0)) {
				//	uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
				uint256 amount = msg.value * REFERRAL_PERCENTS[i] / 10000;
				//	users[currentReferred].bonus = users[currentReferred].bonus.add(amount);
				
				users[currentReferred].totalAmountByRef = users[currentReferred].totalAmountByRef + amount;
				users[currentReferred].levels[i] = users[currentReferred].levels[i]+1;
				currentReferred = users[currentReferred].referrals;
				} else break;
			}
}
        user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
totalReinvested += msg.value;


	}
	
	function withdraw() external initializer {
		User storage user =users[msg.sender];
		uint256 acumulateProfit =currentProfitbyuser(user.invest, user.checkpoint);
		
		uint256 totalAmount=user.totalAmountByRef+acumulateProfit;
		
		uint256 fee = withdrawFee(totalAmount);
		
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		payFees(fee);
		user.withdraw += totalAmount;
		transferHandler(payable(msg.sender), SafeMath.sub(totalAmount,fee));
	}

 function currentProfit() public view returns (uint256) {
 	  uint256 local_profit;
 	   local_profit = (((users[msg.sender].invest) * (block.timestamp - users[msg.sender].checkpoint)) / (8 * (1 days))); 
		    return local_profit;
 }


 function currentProfitbyuser(uint256 _invest,uint256 _checkpoint) private view returns (uint256) {
 	  uint256 local_profit;
 	   local_profit = (((_invest) * (block.timestamp - _checkpoint)) / (8 * (1 days))); 
		    return local_profit;
 }

	
	function invest(address payable ref) external payable initializer {
		//token.transferFrom(msg.sender, address(this), _amount);
		require(msg.value >= MININVEST, "insufficient deposit to invest here");
	//	console.log(msg.value,"msg.value");
	User storage user = users[msg.sender];

	uint256 fee = devFee(msg.value);
	//	console.log(fee,"fee");
	payFees(fee);
	user.invest += msg.value;

		if(user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		

		address currentReferred = user.referrals;
        	for (uint256 i; i < 2; i++) {
        		
        		if (currentReferred != address(0)) {
				//	uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
				uint256 amount = msg.value * REFERRAL_PERCENTS[i] / 10000;
				//	users[currentReferred].bonus = users[currentReferred].bonus.add(amount);
			
				users[currentReferred].totalAmountByRef = users[currentReferred].totalAmountByRef + amount;
				users[currentReferred].levels[i] = users[currentReferred].levels[i]+1;
				currentReferred = users[currentReferred].referrals;
				} else break;
			}
}
        user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
totalInvested += msg.value;

}

	function devFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,devFeeVal),10000);
	}

	function withdrawFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,withdrawnFee),10000);
	}

	function startContrat() public onlyOwner {
		require(marketEggs == 0);
		initialized = true;
		marketEggs = 108000000000;
	}
	
	function getBalance() public view returns(uint256) {
	//	return 	token.balanceOf(address(this));
	return address(this).balance;
}

function getMyMiners(address adr) public view returns(uint256) {
	User memory user =users[adr];
	return user.hatcheryMiners;
}

/*
function getMyEggs(address adr) public view returns(uint256) {
	User memory user =users[adr];
	return SafeMath.add(user.claimedEggs,getEggsSinceLastHatch(adr));
}
*/
function getEggsSinceLastHatch(address adr) public view returns(uint256) {
	User memory user =users[adr];
	uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,user.lastHatch));
	return SafeMath.mul(secondsPassed,user.hatcheryMiners);
}

function min(uint256 a, uint256 b) private pure returns (uint256) {
	return a < b ? a : b;
}
/*
function getSellEggs(address user_) public view returns(uint eggValue){
	uint256 hasEggs = getMyEggs(user_);
	eggValue = calculateEggSell(hasEggs);

}
*/
function getPublicData() external view returns(uint _totalInvest, uint _balance) {
	_totalInvest = totalInvested;
	_balance = getBalance();
}



function userData(address user_) external view returns (
	uint256 hatcheryMiners_,
	uint256 claimedEggs_,
	uint256 lastHatch_,
	uint256 eggsMiners_,
	address referrals_,
	uint256 checkpoint,
	uint256 totalAmountByRef_
	) { 	
	User memory user =users[user_];
	hatcheryMiners_=getMyMiners(user_);
	claimedEggs_=currentProfitbyuser(user.invest, user.checkpoint);
	lastHatch_=user.lastHatch;
	referrals_=user.referrals;
	eggsMiners_=getEggsSinceLastHatch(user_);
	checkpoint=user.checkpoint;
	totalAmountByRef_=user.totalAmountByRef;
}

function payFees(uint _amount) internal {
	uint256 toOwners = _amount.div(3);

	transferHandler(marketingAddress, toOwners);
	transferHandler(projectAddress, toOwners);
	transferHandler(devAddress, toOwners);
}

function transferHandler(address payable _to, uint _amount) internal {
	_to.transfer(_amount);
}

/*
	function transferHandler(address _to, uint _amount) internal {
		token.transfer(_to, _amount);
	}
	*/
	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}



}