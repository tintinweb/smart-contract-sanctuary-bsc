/**
 *Submitted for verification at BscScan.com on 2022-06-02
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
	function isExcludedFromFees(address account) external view returns (bool);
	function bigETHPayDayPotFeeAddress() external view returns (address);
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

contract StakeDUTYEarnETH is Ownable, ReentrancyGuard{
    using SafeBEP20 for IBEP20;
	
    uint256 public minStaking = 100 * (10**10);
	uint256 public penaltyFee = 200;
	uint256 public penaltyTime = 90 days;
	
	uint256 public BEPDStartTime = 1654181568;
	
	uint256 public totalStaked;
	uint256 private BEPDScore;
	uint256 private BEPDTime = BEPDStartTime;
	
	IBEP20 public stakedToken = IBEP20(0xF00500bD3f18bb4c35086bEB517DDa2F3aB45b2F);
	IBEP20 public rewardToken = IBEP20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);
    address public potAddress = payable(0xC51a5683D66f4B331272F56e9DcA5Df22EbBa64a);

	
    mapping(address => UserInfo) internal userInfo;
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
       uint256 startTime;
	   uint256 BEPDScore;
    }
	
    event MigrateTokens(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event MinStakePerUser(uint256 minStakePerUser);
    event Withdraw(address indexed user, uint256 amount);
	event NewPenaltyFee(uint256 newFee);
	event Pause();
    event Unpause();
	
    constructor() {
    }

    function deposit(uint256 amount) external nonReentrant{
	    UserInfo storage user = userInfo[msg.sender];
		
		require(!paused, "Deposit is paused");
		require(stakedToken.balanceOf(msg.sender) >= amount, "Balance not available for staking");
		require(stakedToken.isExcludedFromFees(address(this)), "Contract address is not excluded from fee");
		require(amount >= minStaking, "Amount is less than minimum staking amount");
		
		uint256 userScore = pendingscore(msg.sender);
		uint256 score = pendingScore();
		
		user.amount = user.amount + amount;
		user.startTime = block.timestamp > BEPDStartTime ? block.timestamp : BEPDStartTime;
		user.BEPDScore = user.BEPDScore + userScore;
		
		totalStaked = totalStaked + amount;
		BEPDScore = BEPDScore + score;
		BEPDTime = block.timestamp;
		
		stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);
        emit Deposit(msg.sender, amount);
    }
	
    function withdraw() external nonReentrant{
	    UserInfo storage user = userInfo[msg.sender];
		require(user.amount > 0, "Amount is not staked");
		
		uint256 fee;
		uint256 amount  = user.amount;
		uint256 pending = pendingreward(msg.sender);
		
		uint256 score = pendingscore(msg.sender);
		        score = score + user.BEPDScore;
		uint256 scoreAll = pendingScore();
		
        uint256 ETHreward = (score * rewardToken.balanceOf(potAddress)) / (scoreAll + BEPDScore);		
		
		if(user.startTime + penaltyTime >= block.timestamp)
		{
		    fee = (user.amount * penaltyFee) / 10000;
		}
		
		require(rewardToken.balanceOf(address(this)) >= pending, "Reward token balance not available for withdraw");
		require(stakedToken.balanceOf(address(this)) >= amount - fee, "Token balance not available for withdraw");
		require(rewardToken.balanceOf(potAddress) >= ETHreward, "Reward token balance not available for withdraw");
		
		totalStaked = totalStaked - amount;
		BEPDScore = (scoreAll + BEPDScore) - score;
		BEPDTime = block.timestamp;
		
		user.amount = 0;
		user.startTime = 0;
		user.BEPDScore = 0;
		
		rewardToken.safeTransfer(address(msg.sender), pending);
		stakedToken.safeTransfer(address(msg.sender), amount - fee);
		rewardToken.safeTransferFrom(potAddress, address(msg.sender), ETHreward);
		emit Withdraw(msg.sender, amount - fee);
    }
	
	function pendingreward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
		if(user.amount > 0 && user.startTime <= block.timestamp) 
		{
			uint256 reward = (rewardToken.balanceOf(address(this))) * (user.amount) / (totalStaked);
			return reward;
		}
		else
		{
		    return 0;
		}
    }
	
	function pendingscore(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
		if(user.amount > 0 && user.startTime <= block.timestamp) 
		{
		    uint256 sTime  = user.startTime;
			uint256 eTime  = block.timestamp;
			uint256 tDays  = (eTime - sTime) / (1 days);
			
			uint256 amount = user.amount;
			for (uint256 i=0; i < tDays; i++) {
			    amount += amount* 70/100;
			}
			uint256 reward = amount - user.amount;
			return reward;
		}
		else
		{
		    return 0;
		}
    }
	
	function pendingScore() private view returns (uint256)
	{
		if(totalStaked > 0 && BEPDStartTime <= block.timestamp) 
		{
		    uint256 sTime  = BEPDTime;
			uint256 eTime  = block.timestamp;
			uint256 tDays  = (eTime - sTime) / (1 hours);
			uint256 amount = totalStaked;
			for (uint256 i=0; i < tDays; i++) {
			    amount += amount* 70/100;
			}
			uint256 reward = amount - totalStaked;
			return reward;
			
		}
		else
		{
		    return 0;
		}
    }
	
	function getUserInfo(address userAddress) public view returns (uint256, uint256) {
        UserInfo storage user = userInfo[userAddress];
        return (user.amount, user.startTime);
    }
	
	function migrateTokens(address tokenAddress, uint256 tokenAmount) external onlyOwner nonReentrant{
        IBEP20(tokenAddress).safeTransfer(address(msg.sender), tokenAmount);
        emit MigrateTokens(tokenAddress, tokenAmount);
    }
	
	function updateMinStaking(uint256 minStakingAmount) external onlyOwner {
	    require(stakedToken.totalSupply() > minStakingAmount, "Total supply is less than minimum staking amount");
		require(minStakingAmount >= 100 * (10**18), "Minimum staking amount is less than `100` token");
		
        minStaking = minStakingAmount;
        emit MinStakePerUser(minStakingAmount);
    }
	
	function updatePenaltyFee(uint256 newFee) external onlyOwner {
	    require(newFee >= 0, "Fee is less than `0%`");
		require(newFee <= 2000, "Fee is greater than `20%`");
		
        penaltyFee = newFee;
        emit NewPenaltyFee(newFee);
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