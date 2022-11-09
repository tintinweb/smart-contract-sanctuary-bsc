/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract PomStaking is ReentrancyGuard {
    using SafeMath for uint256;

    struct Stake {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    struct AllInfo {
        uint256 totalStakes;
        uint256 totalDistributed;
        uint256 totalRewards;
        uint256 stakingStart;
        uint256 stakingEnd;

        uint256 userStaked;
        uint256 pendingRewards;
        uint256 totalClaimed;
        uint256 stakeTime;
        uint256 lastClaim;
        bool earlyWithdraw;
    }
    
    address[] stakeholders;
    mapping (address => uint256) stakeholderIndexes;
    mapping (address => uint256) stakeholderClaims;
    mapping (address => uint256) stakeholderStaking;

    mapping (address => Stake) public stakes;

    uint256 public totalStakes;
    uint256 public totalDistributed;
    uint256 public totalRewards;
    uint256 public totalDays = 73 minutes; // 2 years
    uint256 public dividendsPerStake;
    uint256 public dividendsPerStakeAccuracyFactor = 10 ** 36;
	
	uint256 public stakingStart = 0;
	uint256 public stakingEnd = 0;
    uint256 public dividendsCheckPoint;
	
    uint256 public lockPeriod = 3 minutes;
    uint256 public earlyWithdrawPenalty = 5; // 5%
	

    constructor (uint256 _totalRewards, uint256 _stakingStart) payable {
		require(msg.value == _totalRewards, "Amount not match");
		
		totalRewards = _totalRewards;
		stakingStart = _stakingStart;
		dividendsCheckPoint = stakingStart;
		stakingEnd = stakingStart + totalDays;
	}

    function deposit(address stakeholder, uint256 amount) payable external nonReentrant {
        require(amount > 0, "No deposit amount");
        require(msg.value == amount, "Amount not match");
        require(block.timestamp < stakingEnd, "Staking Ended");
        require(block.timestamp >= stakingStart, "Staking Not Started");
		
		if(stakes[stakeholder].amount > 0){
            distributeReward(stakeholder);
        }

        if(stakes[stakeholder].amount == 0){
            addStakeholder(stakeholder);
        }
		
        totalStakes = totalStakes.add(amount);
        stakes[stakeholder].amount += amount;
        stakes[stakeholder].totalExcluded = getCumulativeDividends(stakes[stakeholder].amount);
		stakeholderStaking[stakeholder] = block.timestamp;
		updateCumulativeDividends();
    }

    function withdraw(uint256 amount) external nonReentrant {
		address stakeholder = msg.sender;
		
		require(amount > 0, "No withdraw amount");
        require(stakes[stakeholder].amount >= amount, "insufficient balance");
		
		distributeReward(stakeholder);
		
		totalStakes = totalStakes.sub(amount);
		stakes[stakeholder].amount -= amount;
		stakes[stakeholder].totalExcluded = getCumulativeDividends(stakes[stakeholder].amount);
		
		if(stakes[stakeholder].amount == 0){
            removeStakeholder(stakeholder);
        }
		
		updateCumulativeDividends();
		
		uint256 withdrawAmount = amount;
		uint256 penaltyFee = 0;
		
		if(stakeholderStaking[stakeholder] < (block.timestamp + lockPeriod)){
			penaltyFee = (amount * earlyWithdrawPenalty) / 100;
			withdrawAmount -= penaltyFee;
			payable(address(0xdead)).transfer(penaltyFee);
		}
		
		payable(msg.sender).transfer(withdrawAmount);
    }
    
    function distributeReward(address stakeholder) internal {
        if(stakes[stakeholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(stakeholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            stakeholderClaims[stakeholder] = block.timestamp;
            stakes[stakeholder].totalRealised = stakes[stakeholder].totalRealised.add(amount);
            stakes[stakeholder].totalExcluded = getCumulativeDividends(stakes[stakeholder].amount);
			payable(stakeholder).transfer(amount);
        }
    }

    function claimReward() external nonReentrant{
        distributeReward(msg.sender);
    }
	
	function updateCumulativeDividends() internal {
        uint256 timestamp = block.timestamp;
		
		if(timestamp > stakingEnd){
			timestamp = stakingEnd;
		}
		
		uint256 pendingDividendsShare = (timestamp - dividendsCheckPoint) / 60;
        uint256 rewardPerDay = totalRewards / (totalDays / 60);
        uint256 valueShare = pendingDividendsShare * rewardPerDay;
		
		dividendsPerStake = dividendsPerStake.add(dividendsPerStakeAccuracyFactor.mul(valueShare).div(totalStakes));
		if (pendingDividendsShare > 0) {
            dividendsCheckPoint += timestamp - dividendsCheckPoint;
        }
    }
	
	function getCumulativeDividends(uint256 stake) internal view returns (uint256) {
        uint256 timestamp = block.timestamp;
		
		if(timestamp > stakingEnd){
			timestamp = stakingEnd;
		}
		
		uint256 pendingDividendsShare = (timestamp - dividendsCheckPoint) / 60;
        uint256 rewardPerDay = (totalRewards / (totalDays / 60));
        uint256 valueShare = pendingDividendsShare * rewardPerDay;
		
        // 1 days = 86400 seconds

        // timestamp - dividendsCheckPoint = time passed since last update / 
		uint256 _dividendsPerStake = dividendsPerStake.add(dividendsPerStakeAccuracyFactor.mul(valueShare).div(totalStakes));
		return stake.mul(_dividendsPerStake).div(dividendsPerStakeAccuracyFactor);
    }
	
    function getUnpaidEarnings(address stakeholder) public view returns (uint256) {
        if(stakes[stakeholder].amount == 0){ return 0; }

        uint256 stakeholderTotalDividends = getCumulativeDividends(stakes[stakeholder].amount);
        uint256 stakeholderTotalExcluded = stakes[stakeholder].totalExcluded;

        if(stakeholderTotalDividends <= stakeholderTotalExcluded){ return 0; }

        return stakeholderTotalDividends.sub(stakeholderTotalExcluded);
    }

    function addStakeholder(address stakeholder) internal {
        stakeholderIndexes[stakeholder] = stakeholders.length;
        stakeholders.push(stakeholder);
    }

    function removeStakeholder(address stakeholder) internal {
        stakeholders[stakeholderIndexes[stakeholder]] = stakeholders[stakeholders.length-1];
        stakeholderIndexes[stakeholders[stakeholders.length-1]] = stakeholderIndexes[stakeholder];
        stakeholders.pop();
    }

    function getAllInfo(address user) public view returns (AllInfo memory) {
        return AllInfo(
            totalStakes,
            totalDistributed,
            stakingStart,
            totalRewards,
            stakingEnd,

            stakes[user].amount,
            getUnpaidEarnings(user),
            stakes[user].totalRealised,
            stakeholderStaking[user],
            stakeholderClaims[user],
            stakeholderStaking[user] < (block.timestamp + lockPeriod)
        );
    }
}