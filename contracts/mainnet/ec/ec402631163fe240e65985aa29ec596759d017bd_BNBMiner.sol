/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
	
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
	
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract BNBMiner is Ownable, ReentrancyGuard {

	uint256 public ROI = 100;
	uint256 public referralIncome = 500;
	uint256 public teamFee = 500;
	uint256 public withdrawFee = 0;
	uint256 public minStaking = 5 * 10**15;
	uint256 public totalStaked;
	uint256 public totalClaimed;
	uint256 public totalReferred;
	
    mapping(address => UserInfo) internal userInfo;
	uint256 constant TIME_STEP = 1 days;
	
	bool public paused = false;
	
	modifier whenNotPaused() {
		require(!paused, "Contract is paused");
		_;
	}
	
	modifier whenPaused() {
		require(paused, "Contract is unpaused");
		_;
	}
	
    struct UserInfo {
        uint256 amount; 
		uint256 rewardRemaining;
		uint256 rewardWithdrawal;
        uint256 startTime;
		address sponsor;
		uint256 team;
		uint256 teamEarning;
    }
	
    event Deposit(address indexed user, uint256 amount);
    event NewROI(uint256 ROI);
	event NewReferralIncome(uint256 referralIncome);
	event NewTeamFee(uint256 teamFee);
    event Withdraw(address indexed user, uint256 amount);
	event Compound(address indexed user, uint256 amount);
	event NewWithdrawFee(uint256 withdrawFee);
	event Pause();
    event Unpause();
	
    constructor() {}
	
    function deposit(address sponsor) external nonReentrant payable{
	    UserInfo storage user = userInfo[msg.sender];
		
		require(!paused, "Deposit is paused");
		require(sponsor != msg.sender, "ERR: referrer different required");
		require(sponsor != address(0), 'zero address');
		require(msg.value >= minStaking, 'zero address');
		
		if(user.sponsor == address(0)) 
		{
		    user.sponsor = sponsor;
			
			uint256 referralReward = msg.value * referralIncome / 10000;
		    payable(user.sponsor).transfer(referralReward);
			
			UserInfo storage sponsorInfo = userInfo[user.sponsor];
		    sponsorInfo.team += 1; 
			sponsorInfo.teamEarning += referralReward; 
			totalReferred += referralReward;
		}
		else
		{
		    UserInfo storage sponsorInfo = userInfo[user.sponsor];
			
			uint256 referralReward = msg.value * referralIncome / 10000;
		    payable(user.sponsor).transfer(referralReward);
			
			sponsorInfo.teamEarning += referralReward; 
			totalReferred += referralReward;
		}
		
		uint256 teamReward = msg.value * teamFee / 10000;
		payable(owner()).transfer(teamReward);
		
		uint256 pending = pendingreward(msg.sender);
		
		user.amount += msg.value;
		user.rewardRemaining += pending;
		user.startTime = block.timestamp;
		
		totalStaked += msg.value;
		
        emit Deposit(msg.sender, msg.value);
    }
	
	function withdrawReward() external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		
		uint256 pending = pendingreward(msg.sender);
		uint256 reward  = user.rewardRemaining + pending;
		
		user.rewardWithdrawal += reward;
		user.rewardRemaining = 0;
		user.startTime = block.timestamp;
		totalClaimed += reward;
		
		if(withdrawFee > 0)
		{
		   uint256 withdrawFeeAmount = reward * withdrawFee / 10000;
		   payable(owner()).transfer(withdrawFeeAmount);
		   payable(msg.sender).transfer(reward - withdrawFeeAmount);
		}
		else
		{
		   payable(msg.sender).transfer(reward);
		}
		
		emit Withdraw(msg.sender, reward);
    }
	
	function compoundReward() external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		
		uint256 pending = pendingreward(msg.sender);
		uint256 reward  = user.rewardRemaining + pending;
		
		user.rewardWithdrawal += reward;
		user.rewardRemaining = 0;
		user.startTime = block.timestamp;
		user.amount += reward;
		
		totalClaimed += reward;
		
		emit Compound(msg.sender, reward);
    }
	
	function pendingreward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
		if(user.amount > 0)
		{
			uint256 sTime  = user.startTime;
			uint256 eTime  = block.timestamp;
			uint256 reward = (uint(user.amount) * (ROI) * (eTime-sTime)) / (TIME_STEP * 10000);
			return reward;
		}
		else
		{
		    return 0;
		}
    }
	
	function getUserInfo(address userAddress) public view returns (uint256, uint256, uint256, uint256, address, uint256, uint256) {
        UserInfo storage user = userInfo[userAddress];
        return (user.amount, user.rewardRemaining, user.rewardWithdrawal, user.startTime, user.sponsor, user.team, user.teamEarning);
    }
	
	function updateROI(uint256 newROI) external onlyOwner {
	    require(newROI >= 100, "ROI is less than `1%`");
		require(newROI <= 10000, "ROI is greater than `100%`");
		
        ROI = newROI;
        emit NewROI(newROI);
    }
	
	function updateMinStaking(uint256 newMinStaking) external onlyOwner {
	    require(newMinStaking > 0, "Min staking is less than or equal to `0`");
        minStaking = newMinStaking;
    }
	
	function updateReferralIncome(uint256 newReferralIncome) external onlyOwner {
	    require(newReferralIncome >= 100, "ROI is less than `1%`");
		require(newReferralIncome <= 10000, "ROI is greater than `100%`");
		
        referralIncome = newReferralIncome;
        emit NewReferralIncome(newReferralIncome);
    }
	
	function updateTeamFee(uint256 newTeamFee) external onlyOwner {
		require(newTeamFee <= 10000, "ROI is greater than `100%`");
		
        teamFee = newTeamFee;
        emit NewTeamFee(newTeamFee);
    }
	
	function updateWithdrawFee(uint256 newWithdrawFee) external onlyOwner {
		require(newWithdrawFee <= 10000, "ROI is greater than `100%`");
		
        withdrawFee = newWithdrawFee;
        emit NewWithdrawFee(newWithdrawFee);
    }
	
	function pause() whenNotPaused external onlyOwner{
		paused = true;
		emit Pause();
	}
	
	function unpause() whenPaused external onlyOwner{
		paused = false;
		emit Unpause();
	}
	
	function migrateBNB(uint256 amount) external onlyOwner {
	    require(address(this).balance >= amount, "Incorrect value");
        payable(msg.sender).transfer(amount);
    }
}