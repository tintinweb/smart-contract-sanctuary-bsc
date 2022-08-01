/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
	
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
  
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using Address for address;
	
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract StakeAndEarn is Ownable, ReentrancyGuard{
    using SafeBEP20 for IBEP20;
	
	uint256 public poolFee = 50;
	uint256 public earlyWithdrawalFee = 8000;
	uint256 public maxStakePerWallet = 150 * 10**9 * 10**18;
	uint256 public totalStaked;
	
    IBEP20 public stakedToken = IBEP20(0x08Aed8578dAaBf12d48031fA5d9727e4afD42dee);
	IBEP20 public monthlyRewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	address public developmentWallet = 0xe301726297c6f7A517DfdB945c05F8DbC9CA5376;
	
	uint256 constant TIME_STEP = 365 days;
	
	uint256[6] public stakingAmount = [5 * 10**6 * 10**18, 25 * 10**5 * 10**18, 1 * 10**6 * 10**18, 5 * 10**6 * 10**18, 25 * 10**5 * 10**18, 1 * 10**6 * 10**18];
    uint256[6] public rewardPerMonth = [60 * 10**18, 40 * 10**18, 15 * 10**18, 25 * 10**18, 10 * 10**18, 3 * 10**18];
	uint256[6] public APR = [12000, 10000, 7500, 8000, 5500, 4500];
	uint256[6] public stakingTime = [730 days, 730 days, 730 days, 365 days, 365 days, 365 days];
	
	mapping (address => uint256) public lockedAmount;

	bool public paused = false;
	
	modifier whenNotPaused() {
		require(!paused, "Contract is paused");
		_;
	}
	
	modifier whenPaused() {
		require(paused, "Contract is unpaused");
		_;
	}
	
	struct Deposit {
        uint256 amount; 
		uint256 rewardTime;
        uint256 startTime;
		uint256 endTime;
		uint256 poolFee;
		uint256 earlyWithdrawalFee;
		uint256 monthlyReward;
		uint256 monthlyRewardWithdrawal;
		uint256 package;
		uint256 status;
    }
	
    struct UserInfo {
       Deposit[] deposits;
    }

	mapping(address => UserInfo) userInfo;
	
    event MigrateTokens(address tokenRecovered, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event NewAPR(uint256 packageOneAPR, uint256 packageTwoAPR, uint256 packageThreeAPR, uint256 packageFourAPR, uint256 packageFiveAPR, uint256 packageSixAPR);
	event NewWithdrawalFee(uint256 newFee);
    event MaxStakePerWallet(uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event SetDevelopmentWallet(address wallet);
    event NewPoolFee(uint256 newFee);
	event NewRewardPerMonth(uint256 packageOneReward, uint256 packageTwoReward, uint256 packageThreeReward, uint256 packageFourReward, uint256 packageFiveReward, uint256 packageSixReward);
	event Pause();
    event Unpause();
	
    constructor() {}
	
    function deposit(uint256 amount, uint256 package) external nonReentrant{
	    UserInfo storage user = userInfo[msg.sender];
		
		uint256 balance = stakedToken.balanceOf(msg.sender);
		
		require(!paused, "deposit is paused");
		require(balance >= amount, "balance not available for staking");
		require(package < stakingAmount.length, "package not found");
		require(amount == stakingAmount[package], "amount is not equal to required staking amount");
		require(maxStakePerWallet >= lockedAmount[msg.sender] + amount, "per wallet staking limit is reached");
		
		user.deposits.push(Deposit(amount, block.timestamp, block.timestamp, block.timestamp + stakingTime[package], poolFee, earlyWithdrawalFee, rewardPerMonth[package], 0, package, 1));
		lockedAmount[msg.sender] = lockedAmount[msg.sender] + amount;
		totalStaked = totalStaked + amount;
		
		stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);
        emit Staked(msg.sender, amount);
    }
	
    function withdraw(uint256 stakingID) external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		require(user.deposits.length > stakingID, "no staking found");
		require(user.deposits[stakingID].status == 1, "staking already unstaked");
		
		uint256 amount   = user.deposits[stakingID].amount;
		uint256 reward   = pendingreward(msg.sender, stakingID);
		uint256 monthlyPending = rewardpermonth(msg.sender, stakingID);
		uint256 fee = (reward * user.deposits[stakingID].poolFee) / 10000;
		
		require(stakedToken.balanceOf(address(this)) >= amount + reward - fee, "Token balance not available for withdrawal");
		
		if(user.deposits[stakingID].endTime > block.timestamp)
		{
			uint256 penalty = (amount * user.deposits[stakingID].earlyWithdrawalFee) / 10000;
			stakedToken.safeTransferFrom(address(msg.sender), address(developmentWallet), penalty);
		}
		
		if(monthlyPending > 0)
		{
		    require(monthlyRewardToken.balanceOf(address(this)) >= monthlyPending, "Token balance not available for withdrawal");
		    monthlyRewardToken.safeTransfer(address(msg.sender), monthlyPending);
		}
		
		stakedToken.safeTransfer(address(msg.sender), amount + reward - fee);
		lockedAmount[msg.sender] = lockedAmount[msg.sender] - amount;
		
		user.deposits[stakingID].status = 2; 
		totalStaked = totalStaked - amount;
		
		emit Withdraw(msg.sender, amount + reward - fee);
    }
	
	function withdrawReward(uint256 stakingID) external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		require(user.deposits[stakingID].amount > 0, "no staking found");
		
		uint256 reward = pendingreward(msg.sender, stakingID);
        require(reward > 0, "no reward found");
		
		uint256 fee = (reward * user.deposits[stakingID].poolFee) / 10000;
		
		require(stakedToken.balanceOf(address(this)) >= reward - fee, "Token balance not available for withdraw");
		
		user.deposits[stakingID].rewardTime = block.timestamp;
		
		stakedToken.safeTransfer(address(msg.sender), reward-fee);
		
		emit Withdraw(msg.sender, reward);
    }
	
	function pendingreward(address staker, uint256 stakingID) public view returns (uint256) {
        UserInfo storage user = userInfo[staker];
		
		if(user.deposits[stakingID].amount > 0 && user.deposits[stakingID].status == 1)
		{
			uint256 sTime  = user.deposits[stakingID].rewardTime;
			uint256 eTime  = block.timestamp > user.deposits[stakingID].endTime ? user.deposits[stakingID].endTime : block.timestamp;
			uint256 reward = (uint(user.deposits[stakingID].amount) * (APR[user.deposits[stakingID].package]) * (eTime-sTime)) / (TIME_STEP * 10000);
			return reward;
		}
		else
		{
		    return 0;
		}
    }
	
	function withdrawMonthly(uint256 stakingID) external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		require(user.deposits[stakingID].amount > 0, "No staking found");
		
		uint256 reward = rewardpermonth(msg.sender, stakingID);
        require(reward > 0, "No reward found");
		
		require(monthlyRewardToken.balanceOf(address(this)) >= reward, "Token balance not available for withdraw");
		
		user.deposits[stakingID].monthlyRewardWithdrawal = user.deposits[stakingID].monthlyRewardWithdrawal + reward;
		monthlyRewardToken.safeTransfer(address(msg.sender), reward);
		
		emit Withdraw(msg.sender, reward);
    }
	
	function rewardpermonth(address staker, uint256 stakingID) public view returns (uint256) {
        UserInfo storage user = userInfo[staker];

		if(user.deposits[stakingID].amount > 0 && user.deposits[stakingID].status == 1)
		{
			uint256 sTime   = user.deposits[stakingID].startTime;
			uint256 eTime   = block.timestamp > user.deposits[stakingID].endTime ? user.deposits[stakingID].endTime : block.timestamp;
			uint256 tTime   = (eTime - sTime) / 30 days;
			if(tTime > 12)
			{
			    tTime = 12;
			}
			uint256 reward  = tTime * user.deposits[stakingID].monthlyReward;
			uint256 rewardWithdrawal = user.deposits[stakingID].monthlyRewardWithdrawal;
			uint256 pending = reward - rewardWithdrawal;
			return pending;
		}
		else
		{
		    return 0;
		}
    }
	
    function getUserStaking(address staker) public view returns (uint256) {
	    UserInfo storage user = userInfo[staker];
		return user.deposits.length;
    }
	
	function getUserStats(address staker, uint256 stakingID) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
	    UserInfo storage user = userInfo[staker];
		return (user.deposits[stakingID].amount, user.deposits[stakingID].rewardTime, user.deposits[stakingID].startTime, user.deposits[stakingID].endTime,  user.deposits[stakingID].monthlyReward, user.deposits[stakingID].monthlyRewardWithdrawal, user.deposits[stakingID].status);
    }
	
	function migrateTokens(address tokenAddress, uint256 tokenAmount) external onlyOwner nonReentrant{
       IBEP20(tokenAddress).safeTransfer(address(msg.sender), tokenAmount);
       emit MigrateTokens(tokenAddress, tokenAmount);
    }
	
	function updateMaxStakingPerWallet(uint256 amount) external onlyOwner {
	    require(stakedToken.totalSupply() >= amount, "Total supply is less than max staking amount");
		require(amount >= 10000 * 10**18, "Max staking amount is less than `10000` token");
		
        maxStakePerWallet = amount;
        emit MaxStakePerWallet(amount);
    }
	
	function setDevelopmentWallet(address payable newWallet) external onlyOwner{
        require(newWallet != address(0), "zero-address not allowed");
		
	    developmentWallet = newWallet;
		emit SetDevelopmentWallet(newWallet);
    }
	
	function updateEarlyWithdrawalFee(uint256 newFee) external onlyOwner {
	    require(earlyWithdrawalFee >= 6000, "Early withdrawal fee is less than `60%`");
		require(earlyWithdrawalFee <= 8500, "Early withdrawal fee is greater than `85%`");
		
        earlyWithdrawalFee = newFee;
        emit NewWithdrawalFee(newFee);
    }

	function SetAPR(uint256 packageOneAPR, uint256 packageTwoAPR, uint256 packageThreeAPR, uint256 packageFourAPR, uint256 packageFiveAPR, uint256 packageSixAPR) external onlyOwner {
	    require(packageOneAPR >= 3000 && packageOneAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageTwoAPR >= 3000 && packageTwoAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageThreeAPR >= 3000 && packageThreeAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageFourAPR >= 3000 && packageFourAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageFiveAPR >= 3000 && packageFiveAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageSixAPR >= 3000 && packageSixAPR <= 20000, "APR % is less then `30` or greater than `200`");
		
	    APR[0] = packageOneAPR;
        APR[1] = packageTwoAPR;
        APR[2] = packageThreeAPR;
		APR[3] = packageFourAPR;
		APR[4] = packageFiveAPR;
		APR[5] = packageSixAPR;
		
		emit NewAPR(packageOneAPR, packageTwoAPR, packageThreeAPR, packageFourAPR, packageFiveAPR, packageSixAPR);
    }
	
    function SetRewardPerMonth(uint256 packageOneReward, uint256 packageTwoReward, uint256 packageThreeReward, uint256 packageFourReward, uint256 packageFiveReward, uint256 packageSixReward) external onlyOwner {
	    require(packageOneReward >= 30 * 10**18 && packageOneReward <= 240 * 10**18, "Reward amount is less then `30` or greater than `240` BUSD");
		require(packageTwoReward >= 20 * 10**18 && packageTwoReward <= 160 * 10**18, "Reward amount is less then `20` or greater than `160` BUSD");
		require(packageThreeReward >= 5 * 10**18 && packageThreeReward <= 60 * 10**18, "Reward amount is less then `5` or greater than `60` BUSD");
		require(packageFourReward >= 10 * 10**18 && packageFourReward <= 100 * 10**18, "Reward amount is less then `10` or greater than `100` BUSD");
		require(packageFiveReward >= 5 * 10**18 && packageFiveReward <= 50 * 10**18, "Reward amount is less then `5` or greater than `50` BUSD");
		require(packageSixReward >= 2 * 10**18 && packageSixReward <= 20 * 10**18, "Reward amount is less then `2` or greater than `20` BUSD");
		
	    rewardPerMonth[0] = packageOneReward;
        rewardPerMonth[1] = packageTwoReward;
        rewardPerMonth[2] = packageThreeReward;
		rewardPerMonth[3] = packageFourReward;
		rewardPerMonth[4] = packageFiveReward;
		rewardPerMonth[5] = packageSixReward;
		
		emit NewRewardPerMonth(packageOneReward, packageTwoReward, packageThreeReward, packageFourReward, packageFiveReward, packageSixReward);
    }
	
	function updatePoolFee(uint256 newFee) external onlyOwner {
	    require(newFee >= 0, "Fee is less than `0%`");
		require(newFee <= 200, "Fee is greater than `2%`");
		
        poolFee = newFee;
        emit NewPoolFee(newFee);
    }
	
	function pause() whenNotPaused external onlyOwner{
		paused = true;
		emit Pause();
	}
	
	function unpause() whenPaused external onlyOwner{
		paused = false;
		emit Unpause();
	}
}