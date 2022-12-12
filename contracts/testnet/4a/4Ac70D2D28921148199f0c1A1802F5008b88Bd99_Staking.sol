//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

 
library SafeMath {
	function add(uint x, uint y) internal pure returns (uint z) {
		require((z = x + y) >= x, 'ds-math-add-overflow');
	}

	function sub(uint x, uint y) internal pure returns (uint z) {
		require((z = x - y) <= x, 'ds-math-sub-underflow');
	}

	function mul(uint x, uint y) internal pure returns (uint z) {
		require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
	}  
	
	function div(uint a, uint b) internal pure returns (uint c) {
		require(b > 0, "ds-math-mul-overflow");
		c = a / b;
	}

}

interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);
	function mint(uint amount) external returns (bool);
}

// each staking instance mapping to each pool
contract Staking {
	using SafeMath for uint;
	event Stake(address staker, uint amount);
	event Reward(address staker, uint amount);
	event Withdraw(address staker, uint amount);
    //staker inform
	struct Staker {
		uint firstStakingBlock; // block number when first staking
		uint stakingAmount;  // staking token amount
		uint lastUpdateTime;  // last amount updatetime
		uint lastStakeUpdateTime;  // last Stake updatetime
		uint stake;          // stake amount
		uint rewards;          // stake amount
	}

	uint public startStakingTime=1647356400;

	address public tokenAddress;

	uint public totalStakingAmount; // total staking token amount

	uint public lastUpdateTime; // total stake amount and reward update time
	uint public totalReward;  // total reward amount
	uint public totalStake;   // total stake amount
	
	uint256 public quota;
	uint256 public limitReward;
	mapping(address=>Staker) public stakers;

	constructor (address _tokenAddress, uint256 _quota, uint256 _limitReward) {
		tokenAddress = _tokenAddress;
		lastUpdateTime = block.timestamp;
		quota = _quota*10**18;
		limitReward = _limitReward*10**18;
		ownerConstructor();
	}
	function countTotalStake() public view returns (uint _totalStake) {
		_totalStake = totalStake + totalStakingAmount.mul((block.timestamp).sub(lastUpdateTime));
	}

	function countTotalReward() public view returns (uint _totalReward) {
		_totalReward = totalReward + quota.mul(block.timestamp.sub(lastUpdateTime)).div(86400);
	}

	function updateTotalStake() internal {
		totalStake = countTotalStake();
		totalReward = countTotalReward();
		lastUpdateTime = block.timestamp;
		totalStakingAmount = IERC20(tokenAddress).balanceOf(address(this));
	}

	/* ----------------- personal counts ----------------- */

	function getStakeInfo(address stakerAddress) public view returns(uint _total, uint _staking, uint _rewardable, uint _rewards) {
		_total = totalStakingAmount;
		_staking = stakers[stakerAddress].stakingAmount;
		_rewardable = countReward(stakerAddress); 
		_rewards = stakers[stakerAddress].rewards;

	}
	function countStake(address stakerAddress) public view returns(uint _stake) {
		Staker memory _staker = stakers[stakerAddress];
		if(totalStakingAmount == 0 && _staker.stake == 0 ) return 0;
		_stake = _staker.stake + ((block.timestamp).sub(_staker.lastUpdateTime)).mul(_staker.stakingAmount);
	}
	
	function countReward(address stakerAddress) public view returns(uint _reward) {
		uint _totalStake = countTotalStake();
		uint _totalReward = countTotalReward();
		uint _stake = countStake(stakerAddress);
		_reward = _totalStake==0 ? 0 : _totalReward.mul(_stake).div(_totalStake);
	}

	function stake(uint amount) external {
		require(block.timestamp >= startStakingTime, "staking : you can not stake yet");
		address stakerAddress = msg.sender;
		IERC20(tokenAddress).transferFrom(stakerAddress,address(this),amount);
		if(stakers[stakerAddress].firstStakingBlock==0) stakers[stakerAddress].firstStakingBlock = block.timestamp;
		stakers[stakerAddress].stake = countStake(stakerAddress);
		stakers[stakerAddress].stakingAmount += amount;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		stakers[stakerAddress].lastStakeUpdateTime = block.timestamp;
		
		updateTotalStake();
		emit Stake(stakerAddress,amount);
	}

	function unstaking() external {
		address stakerAddress = msg.sender;
		uint amount = stakers[stakerAddress].stakingAmount;
		require(0 < amount,"staking : amount over stakeAmount");
		IERC20(tokenAddress).transfer(stakerAddress,amount.mul(1000).div(1000));
		stakers[stakerAddress].stake = countStake(stakerAddress);
		stakers[stakerAddress].stakingAmount = 0;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		stakers[stakerAddress].lastStakeUpdateTime = block.timestamp;

		updateTotalStake();
		emit Withdraw(stakerAddress,amount);
	}

	function claimRewards() external {
		address stakerAddress = msg.sender;

		uint _stake = countStake(stakerAddress);
		uint _reward = countReward(stakerAddress);

		require((block.timestamp-stakers[stakerAddress].firstStakingBlock).div(86400) >= 7,"claim : you can not claim the reward yet");
		require(_reward>0 && limitReward>0,"claim : reward amount is 0");
		_reward = limitReward<_reward ? limitReward : _reward;
		IERC20(tokenAddress).transfer(stakerAddress, _reward);
		stakers[stakerAddress].rewards += _reward;
		totalStake -= _stake;
		totalReward -= _reward;
		limitReward -= _reward;
		stakers[stakerAddress].stake = 0;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		
		updateTotalStake();
		emit Reward(stakerAddress,_reward);
	}
	
	
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function ownerConstructor () internal {
		_owner = msg.sender;
		emit OwnershipTransferred(address(0), _owner);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}