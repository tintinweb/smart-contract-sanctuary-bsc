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
	function checkFeeExempt(address account) external view returns (bool);
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

contract StakeORYEarnBUSD is Ownable, ReentrancyGuard{
    using SafeBEP20 for IBEP20;
	
    uint256 public minStaking = 1 * 10**18;
	uint256 public stakingPeriod = 365 days;
	uint256 public totalStaked;
	
    IBEP20 public stakedToken = IBEP20(0xBD46f6903aBd8b0aC5Fcc2DBAd6d44ed551888a2);
	IBEP20 public rewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	
	bool public paused = false;
	
	modifier whenNotPaused() {
		require(!paused, "Contract is paused");
		_;
	}
	
	modifier whenPaused() {
		require(paused, "Contract is unpaused");
		_;
	}
	
    struct StakeToEarn {
       uint256 amount; 
       uint256 startTime;
	   uint256 endTime;
	   uint256 status;
    }
	
	mapping (address => mapping(uint256 => StakeToEarn)) public mapStakeToEarn;
	mapping (address => uint256) public totalStakingRequest;
	
    event MigrateTokens(address tokenRecovered, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
	event Pause();
    event Unpause();
	
    constructor() {}

	function Staking(uint256 amount) external nonReentrant{
		require(!paused, "Deposit is paused");
		require(stakedToken.balanceOf(msg.sender) >= amount, "Balance not available for staking");
		require(amount >= minStaking, "Amount is less than minimum staking amount");
		require(stakedToken.checkFeeExempt(address(this)), "Contract address is not excluded from fee");
		
		mapStakeToEarn[msg.sender][totalStakingRequest[msg.sender]].amount = amount;
		mapStakeToEarn[msg.sender][totalStakingRequest[msg.sender]].startTime = block.timestamp;
		mapStakeToEarn[msg.sender][totalStakingRequest[msg.sender]].endTime = block.timestamp + stakingPeriod;
		mapStakeToEarn[msg.sender][totalStakingRequest[msg.sender]].status = 1;
		
		totalStaked = totalStaked + amount;
		totalStakingRequest[msg.sender] +=1;
		
		stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);
        emit Staked(msg.sender, amount);
    }
	
    function withdraw(uint256 id) external nonReentrant{
		require(mapStakeToEarn[msg.sender][id].status == 1, "staking already unstaked");
		require(mapStakeToEarn[msg.sender][id].endTime > block.timestamp, "Staking time not completed");
		
		uint256 amount = mapStakeToEarn[msg.sender][id].amount;
		uint256 reward = pendingreward(msg.sender, id);
		
		require(stakedToken.balanceOf(address(this)) >= amount, "Token balance not available for withdraw");
		
		totalStaked = totalStaked - amount;
		
		mapStakeToEarn[msg.sender][id].status = 2; 
		
		rewardToken.safeTransfer(address(msg.sender), reward);
		stakedToken.safeTransfer(address(msg.sender), amount);
		emit Withdraw(msg.sender, amount);
    }
	
	function withdrawEarly(uint256 id) external nonReentrant{
		require(mapStakeToEarn[msg.sender][id].status == 1, "staking already unstaked");
		require(mapStakeToEarn[msg.sender][id].endTime < block.timestamp, "Staking time is completed");
		
		uint256 amount = mapStakeToEarn[msg.sender][id].amount;
		
		require(stakedToken.balanceOf(address(this)) >= amount, "Token balance not available for withdraw");
		
		totalStaked = totalStaked - amount;
		
		mapStakeToEarn[msg.sender][id].status = 2; 
		
		stakedToken.safeTransfer(address(msg.sender), amount);
		emit Withdraw(msg.sender, amount);
    }
	
	function pendingreward(address userAddress, uint256 id) public view returns (uint256) {
		if(mapStakeToEarn[userAddress][id].amount > 0 && mapStakeToEarn[userAddress][id].status == 1)
		{
			 uint256 reward = mapStakeToEarn[userAddress][id].amount * rewardToken.balanceOf(address(this)) / totalStaked;
		     return reward;
        }
		else
		{
		    return 0;
		}
    }
	
	function migrateTokens(address receiver, address tokenAddress, uint256 tokenAmount) external onlyOwner nonReentrant{
       IBEP20(tokenAddress).safeTransfer(receiver, tokenAmount);
       emit MigrateTokens(tokenAddress, tokenAmount);
    }
	
	function SetMinStaking(uint256 newAmount) external onlyOwner {
	   require(newAmount >= 0, "Incorrect `New Amount` value");
	   minStaking = newAmount;
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