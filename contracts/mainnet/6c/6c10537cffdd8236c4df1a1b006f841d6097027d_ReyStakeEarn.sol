/**
 *Submitted for verification at BscScan.com on 2022-04-05
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
	
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
	
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
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
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return _verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function safeApprove( IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeBEP20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
	
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract ReyStakeEarn is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
	
    uint256 public minStakePerUser = 100 * 10**18;
	uint256 public rewardPerYear = 3800;
	uint256 public totalStakedToken;
    IBEP20 public stakedToken;
	
    mapping(address => UserInfo) internal userInfo;
	uint256 public TIME_STEP = 365 days;
	bool public paused = false;
	
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
	
	modifier whenPaused() {
		require(paused);
		_;
	}
	
    struct UserInfo {
        uint256 amount; 
		uint256 rewardRemaining;
		uint256 rewardWithdrawl;
        uint256 startTime;
    }
	
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewRewardRate(uint256 rewardPerStake);
    event MinStakePerUser(uint256 minStakePerUser);
    event Withdraw(address indexed user, uint256 amount);
	event Pause();
    event Unpause();
   
    constructor(IBEP20 _stakedToken) {
	    stakedToken = _stakedToken;
    }
	
    function initialize(uint256 _rewardPerYear, uint256 _minStakePerUser) external onlyOwner {
		require(_minStakePerUser >= 0, "Inccorect min stake per user");
		rewardPerYear = _rewardPerYear;
		minStakePerUser = _minStakePerUser;
    }
	
    function deposit(uint256 _amount) external nonReentrant {
	    UserInfo storage user = userInfo[msg.sender];
	    require(!paused, "Deposit is paused");
		require(_amount >= minStakePerUser, "Minimum staking amount required");
		
		uint256 pendingRewardToken = pendingreward(msg.sender);
		
		user.amount = user.amount.add(_amount);
		user.rewardRemaining = user.rewardRemaining.add(pendingRewardToken);
		user.startTime = block.timestamp;
		totalStakedToken = totalStakedToken.add(_amount);
		
		stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }
	
    function withdraw() public nonReentrant {
	    UserInfo storage user = userInfo[msg.sender];
		require(user.amount > 0, "Stake not found");
		uint256 _amount = user.amount;
		
		uint256 pendingRewardToken = pendingreward(msg.sender);
		uint256 pending = user.rewardRemaining.add(pendingRewardToken);
		
		user.rewardRemaining = 0;
		user.amount = 0;
		user.rewardWithdrawl = 0;
		totalStakedToken = totalStakedToken.sub(_amount);
		
		stakedToken.safeTransfer(address(msg.sender), _amount.add(pending));
		emit Withdraw(msg.sender, _amount.add(pending));
    }
	
	function withdrawreward() public nonReentrant {
		UserInfo storage user = userInfo[msg.sender];
		
		uint256 pendingRewardToken = pendingreward(msg.sender);
		uint256 pending = user.rewardRemaining.add(pendingRewardToken);
		user.rewardWithdrawl = user.rewardWithdrawl.add(pending);
		
		user.rewardRemaining = 0;
		user.startTime = block.timestamp;
		
		stakedToken.safeTransfer(address(msg.sender), pending);
		emit Withdraw(msg.sender, pending);
    }
	
	function pendingreward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
		if(user.amount > 0)
		{
			uint256 sTime  = user.startTime;
			uint256 eTime  = block.timestamp;
			uint256 reward = (uint(user.amount).mul(rewardPerYear).div(10000)).mul(eTime.sub(uint(sTime))).div(TIME_STEP);
			return reward;
		}
		else
		{
		    return 0;
		}
    }
	
	function getUserInfo(address userAddress) public view returns (uint256, uint256, uint256, uint256, uint256) {
        UserInfo storage user = userInfo[userAddress];
        return (user.amount, user.rewardRemaining, user.rewardWithdrawl, user.startTime, rewardPerYear);
    }
	
	function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
       IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
       emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
	
	function updateMinStakePerUser(uint256 _minStakePerUser) external onlyOwner {
        minStakePerUser = _minStakePerUser;
        emit MinStakePerUser(_minStakePerUser);
    }
	
	function updateRewardRate(uint256 _newRewardRate) external onlyOwner {
        rewardPerYear = _newRewardRate;
        emit NewRewardRate(_newRewardRate);
    }
	
	function updateTimeStep(uint256 _newTimeStep) external onlyOwner {
        TIME_STEP = _newTimeStep;
    }
	
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}