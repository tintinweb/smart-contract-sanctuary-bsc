/**
 *Submitted for verification at BscScan.com on 2022-05-30
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
	function isStakingAddress(address _address) external view returns (bool);
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
	uint256 public maxStakePoll = 300 * 10**12 * 10**7;
	uint256 public totalStaked;
	
	IBEP20 public stakedToken = IBEP20(0x679D5b2d94f454c950d683D159b87aa8eae37C9e);
	IBEP20 public rewardToken = IBEP20(0x08Aed8578dAaBf12d48031fA5d9727e4afD42dee);
	
	IBEP20 public monthlyRewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	address public developmentWallet = 0xe301726297c6f7A517DfdB945c05F8DbC9CA5376;
	
	uint256 constant TIME_STEP = 365 days;
	
	uint256[2] public stakingAmount = [1 * 10**12 * 10**7, 1 * 10**12 * 10**7];
	uint256[2] public stakingTime = [365 days, 730 days];
    uint256[2] public rewardPerMonth = [50 * 10**18, 100 * 10**18];
	uint256[6] public APR = [4000, 6000];
	
	
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
		uint256 APR;
		uint256 monthlyReward;
		uint256 monthlyRewardWithdrawal;
		uint256 status;
    }
	
    struct UserInfo {
       Deposit[] deposits;
    }

	mapping(address => UserInfo) userInfo;
	
    event MigrateTokens(address tokenRecovered, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event NewAPR(uint256 packageOneAPR, uint256 packageTwoAPR);
	event NewWithdrawalFee(uint256 newFee);
    event MaxStakePoll(uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event SetDevelopmentWallet(address wallet);
	event NewStakingAmount(uint256 newAmountOne, uint256 newAmountTwo);
	event NewRewardPerMonth(uint256 packageOneReward, uint256 packageTwoReward);
	event NewPoolFee(uint256 newFee);
	event Pause();
    event Unpause();
	
    constructor() {}
	
    function deposit(uint256 amount, uint256 package) external nonReentrant{
	    UserInfo storage user = userInfo[msg.sender];

		require(!paused, "deposit is paused");
		require(stakedToken.isStakingAddress(address(this)), "contract not whitelist for deposit");
		require(stakedToken.balanceOf(msg.sender) >= amount, "balance not available for staking");
		
		require(package < stakingAmount.length, "package not found");
		require(amount == stakingAmount[package], "amount is not equal to required staking amount");
		require(maxStakePoll >= totalStaked+amount, "poll staking limit is reached");
		
		user.deposits.push(Deposit(amount, block.timestamp, block.timestamp, block.timestamp + stakingTime[package], poolFee, earlyWithdrawalFee, APR[package], rewardPerMonth[package], 0, 1));
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
		
		require(rewardToken.balanceOf(address(this)) >= reward - fee, "reward token balance not available for withdraw");
		require(stakedToken.balanceOf(address(this)) >= amount, "token balance not available for withdraw");

		if(user.deposits[stakingID].endTime > block.timestamp)
		{
			uint256 penalty = (amount * user.deposits[stakingID].earlyWithdrawalFee) / 10000;
			stakedToken.safeTransferFrom(address(msg.sender), address(developmentWallet), penalty);
			stakedToken.safeTransfer(address(msg.sender), amount - penalty);
		}
		else
		{
		    stakedToken.safeTransfer(address(msg.sender), amount);
		}
		
		if(monthlyPending > 0)
		{
		    require(monthlyRewardToken.balanceOf(address(this)) >= monthlyPending, "token balance not available for withdrawal");
		    monthlyRewardToken.safeTransfer(address(msg.sender), monthlyPending);
		}
		
		if(reward > 0)
		{
		    stakedToken.safeTransfer(address(msg.sender), reward - fee);
		}
		
		lockedAmount[msg.sender] = lockedAmount[msg.sender] - amount;
		user.deposits[stakingID].status = 2; 
		totalStaked = totalStaked - amount;
		
		emit Withdraw(msg.sender, amount + reward);
    }
	
	function withdrawReward(uint256 stakingID) external nonReentrant{
		UserInfo storage user = userInfo[msg.sender];
		require(user.deposits[stakingID].amount > 0, "no staking found");
		
		uint256 reward = pendingreward(msg.sender, stakingID);
        require(reward > 0, "no reward found");
		
		uint256 fee = (reward * user.deposits[stakingID].poolFee) / 10000;
		
		require(stakedToken.balanceOf(address(this)) >= reward - fee, "Token balance not available for withdraw");
		
		user.deposits[stakingID].rewardTime = block.timestamp;
		
		rewardToken.safeTransfer(address(msg.sender), reward - fee);
		
		emit Withdraw(msg.sender, reward);
    }
	
	function pendingreward(address staker, uint256 stakingID) public view returns (uint256) {
        UserInfo storage user = userInfo[staker];
		
		if(user.deposits[stakingID].amount > 0 && user.deposits[stakingID].status == 1)
		{
			uint256 sTime  = user.deposits[stakingID].rewardTime;
			uint256 eTime  = block.timestamp > user.deposits[stakingID].endTime ? user.deposits[stakingID].endTime : block.timestamp;
			uint256 reward = (uint(user.deposits[stakingID].amount)*(user.deposits[stakingID].APR)*(eTime-sTime)) / (TIME_STEP * 10000);
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
			uint256 rewardWithdrawal  = user.deposits[stakingID].monthlyRewardWithdrawal;
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

	function updateMaxStakePoll(uint256 amount) external onlyOwner {
	    require(stakedToken.totalSupply() >= amount, "Total supply is less than max staking amount");
        require(maxStakePoll >= totalStaked, "Maximum staking amount is less than staked token");
		
        maxStakePoll = amount;
        emit MaxStakePoll(amount);
    }
	
	function updateEarlyWithdrawalFee(uint256 newFee) external onlyOwner {
	    require(earlyWithdrawalFee >= 6000, "Early withdrawal fee is less than `60%`");
		require(earlyWithdrawalFee <= 8500, "Early withdrawal fee is greater than `85%`");
		
        earlyWithdrawalFee = newFee;
        emit NewWithdrawalFee(newFee);
    }
	
	function SetAPR(uint256 packageOneAPR, uint256 packageTwoAPR) external onlyOwner {
	    require(packageOneAPR >= 3000 && packageOneAPR <= 20000, "APR % is less then `30` or greater than `200`");
		require(packageTwoAPR >= 3000 && packageTwoAPR <= 20000, "APR % is less then `30` or greater than `200`");
		
	    APR[0] = packageOneAPR;
        APR[1] = packageTwoAPR;
		
		emit NewAPR(packageOneAPR, packageTwoAPR);
    }
	
	function SetRewardPerMonth(uint256 packageOneReward, uint256 packageTwoReward) external onlyOwner {
	    require(packageOneReward >= 20 * 10**18 && packageOneReward <= 160 * 10**18, "Reward amount is less then `20` or greater than `160` BUSD");
		require(packageTwoReward >= 30 * 10**18 && packageTwoReward <= 120 * 10**18, "Reward amount is less then `30` or greater than `120` BUSD");
		
	    rewardPerMonth[0] = packageOneReward;
        rewardPerMonth[1] = packageTwoReward;
		
		emit NewRewardPerMonth(packageOneReward, packageTwoReward);
    }
	
	function updatePoolFee(uint256 newFee) external onlyOwner {
	    require(newFee >= 0, "Fee is less than `0%`");
		require(newFee <= 200, "Fee is greater than `2%`");
		
        poolFee = newFee;
        emit NewPoolFee(newFee);
    }

	function setDevelopmentWallet(address payable newWallet) external onlyOwner{
        require(newWallet != address(0), "zero-address not allowed");
		
	    developmentWallet = newWallet;
		emit SetDevelopmentWallet(newWallet);
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