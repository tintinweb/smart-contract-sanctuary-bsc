/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

// SPDX-License-Identifier: None
pragma solidity 0.8.12;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner;authorizations[_owner] = true;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public onlyOwner {authorizations[adr] = true;}
    function unauthorize(address adr) public onlyOwner {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr;authorizations[adr] = true;emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
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

contract MogeStaking is Auth {
    uint256 _accuracyFactor = 10 ** 36;
    
    struct Stake {
        uint256 stakedAmount;
        uint256 rewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        uint256 totalRewardsCollectedAlready;
        uint256 lockedUntil;
        uint256 bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        uint256 totalBonusRewardsCollectedAlready;
    }

    address public stakingToken;
    address public admin;

    uint256 public totalRewardsSentOutAlready = 0;
    uint256 public totalStakedTokens = 0;
    uint256 public rewardsBalance = 0;
    uint256 public totalStakers = 0;
    uint256 private currentStakeBeingAdded = 0;
    
    uint256 public _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed = 0;
    uint256 public _currentContractBalanceOfBonusRewards = 0;
    uint256 public _contractBalanceOfBonusRewards = 0;
    uint256 public _lostBonusRewardsBecauseOfUnstaking = 0;

    uint256 public _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed = 0;
    uint256 public _currentContractBalanceOfRewards = 0;
    uint256 public _lastContractBalanceOfRewards = 0;
    uint256 public _lockDuration = 1 days;

    mapping (address => Stake) public stakes;
    mapping (address => bool) public neverUnstaked;
    mapping (address => uint256) public howManyTimesUnstaked;
    mapping (uint256 => address) public addressOfIndex;
    mapping (address => uint256) public stakerIndex;

	event Realised(address account, uint amount);
    event Staked(address account, uint stakedAmount);
    event Unstaked(address account, uint amount);
    event Compounded(address account, uint amount);
    event BonusRewardsAdded(uint256 amount);

    constructor (address _stakingToken) Auth(msg.sender) {
        stakingToken = _stakingToken;
        admin = msg.sender;
    }

    function getRewardsBalance() external view returns (uint256) {
        return rewardsBalance;
    }

    function getStake(address account) public view returns (uint256) {
        return stakes[account].stakedAmount;
    }

    function getTotalClaimsOfStaker(address staker) external view returns (uint256) {
        return stakes[staker].totalRewardsCollectedAlready;
    }

    function getTotalStakers() external view returns (uint256) {
        return totalStakers;
    }

    function availableRewards(address staker) public view returns (uint256){
        uint256 totalRewardsIfFirstStakerAndNeverClaimed = stakes[staker].stakedAmount *  _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        uint256 totalBonusRewardsIfFirstStakerAndNeverClaimed = stakes[staker].stakedAmount *  _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        uint256 availableRewardsOfStaker = totalRewardsIfFirstStakerAndNeverClaimed - stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        uint256 bonusRewardsBeingSentToStaker = totalBonusRewardsIfFirstStakerAndNeverClaimed - stakes[staker].bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        if(neverUnstaked[staker]){
            availableRewardsOfStaker += bonusRewardsBeingSentToStaker;
        }
        return availableRewardsOfStaker;
    }

    function rewardsMissedCauseNotStaked(address staker) public view returns (uint256) {
        return (IBEP20(stakingToken).balanceOf(staker) - stakes[staker].stakedAmount) * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
    }

    function StakeSome(uint amount) external {
        require(amount > 0);
        amount = amount * 10**9;
        if(amount == IBEP20(stakingToken).balanceOf(msg.sender)){
            amount = IBEP20(stakingToken).balanceOf(msg.sender) * 9999 / 10000;
        }
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);
        _stake(msg.sender, amount);
    }

    function StakeAll() external {
        uint256 amount = IBEP20(stakingToken).balanceOf(msg.sender) * 9999 / 10000;
        require(amount > 0);
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);
        _stake(msg.sender, amount);
    }

    function UnstakeSome(uint amount) external {
        require(amount > 0);
        amount = amount * 10**18;
        _unstake(msg.sender, amount);
    }

    function UnstakeAll() external {
        uint256 amount = getStake(msg.sender);
        require(amount > 0);
        _unstake(msg.sender, amount);
    }
    
    function ClaimRewards() external {
        _realise(msg.sender);
    }

    function Compound() external {
        updateRewardsBalance();

        if (rewardsBalance > _lastContractBalanceOfRewards && totalStakedTokens != 0) {
            uint256 newRewards = rewardsBalance - _lastContractBalanceOfRewards;
            uint256 additionalAmountPerStakedToken = newRewards * _accuracyFactor / totalStakedTokens;
            _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _lastContractBalanceOfRewards = rewardsBalance;
        }

        uint256 totalRewardsIfFirstStakerAndNeverClaimed = stakes[msg.sender].stakedAmount *  _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        uint256 totalBonusRewardsIfFirstStakerAndNeverClaimed = stakes[msg.sender].stakedAmount *  _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;

        if(stakes[msg.sender].stakedAmount == 0 || totalRewardsIfFirstStakerAndNeverClaimed <= stakes[msg.sender].rewardsEitherPaidOutAlreadyOrNeverEligibleFor){
            return;
        }
        uint256 rewardsBeingSentToStaker = totalRewardsIfFirstStakerAndNeverClaimed - stakes[msg.sender].rewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        stakes[msg.sender].totalRewardsCollectedAlready += rewardsBeingSentToStaker;
        totalRewardsSentOutAlready += rewardsBeingSentToStaker;
        uint256 bonusRewardsBeingSentToStaker = totalBonusRewardsIfFirstStakerAndNeverClaimed - stakes[msg.sender].bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        stakes[msg.sender].totalBonusRewardsCollectedAlready += bonusRewardsBeingSentToStaker;
        totalRewardsSentOutAlready += bonusRewardsBeingSentToStaker;

        if(neverUnstaked[msg.sender]){
            stakes[msg.sender].stakedAmount += rewardsBeingSentToStaker + bonusRewardsBeingSentToStaker;
            totalStakedTokens += rewardsBeingSentToStaker + bonusRewardsBeingSentToStaker;
            emit Compounded(msg.sender, rewardsBeingSentToStaker + bonusRewardsBeingSentToStaker);
        } else {
            stakes[msg.sender].stakedAmount += rewardsBeingSentToStaker;
            _contractBalanceOfBonusRewards -=  bonusRewardsBeingSentToStaker;
            _lostBonusRewardsBecauseOfUnstaking += bonusRewardsBeingSentToStaker;
            totalStakedTokens += rewardsBeingSentToStaker;
            emit Compounded(msg.sender, rewardsBeingSentToStaker);
        }
        stakes[msg.sender].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[msg.sender].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        stakes[msg.sender].bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[msg.sender].stakedAmount * _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        if (totalStakedTokens > 0) {
			_lastContractBalanceOfRewards = updateRewardsBalance();
		}
    }
    function updateRewardsBalance() public returns (uint256) {
        if(IBEP20(stakingToken).balanceOf(address(this)) + _lostBonusRewardsBecauseOfUnstaking > totalStakedTokens + _contractBalanceOfBonusRewards + currentStakeBeingAdded){
            rewardsBalance = IBEP20(stakingToken).balanceOf(address(this)) - totalStakedTokens - _contractBalanceOfBonusRewards + _lostBonusRewardsBecauseOfUnstaking - currentStakeBeingAdded;
        }
        _lostBonusRewardsBecauseOfUnstaking = 0;
        return rewardsBalance;
    }

    function _realise(address staker) internal {
        updateRewardsBalance();

        if (rewardsBalance > _lastContractBalanceOfRewards && totalStakedTokens != 0) {
            uint256 newRewards = rewardsBalance - _lastContractBalanceOfRewards;
            uint256 additionalAmountPerStakedToken = newRewards * _accuracyFactor / totalStakedTokens;
            _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _lastContractBalanceOfRewards = rewardsBalance;
        }
        uint256 totalRewardsIfFirstStakerAndNeverClaimed = stakes[staker].stakedAmount *  _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        uint256 totalBonusRewardsIfFirstStakerAndNeverClaimed = stakes[staker].stakedAmount *  _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        if(stakes[staker].stakedAmount == 0 || totalRewardsIfFirstStakerAndNeverClaimed <= stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor){
            return;
        }
        uint256 rewardsBeingSentToStaker = totalRewardsIfFirstStakerAndNeverClaimed - stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        stakes[staker].totalRewardsCollectedAlready += rewardsBeingSentToStaker;
        totalRewardsSentOutAlready += rewardsBeingSentToStaker;
        uint256 bonusRewardsBeingSentToStaker = totalBonusRewardsIfFirstStakerAndNeverClaimed - stakes[staker].bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor;
        stakes[staker].totalBonusRewardsCollectedAlready += bonusRewardsBeingSentToStaker;
        totalRewardsSentOutAlready += bonusRewardsBeingSentToStaker;
        if(neverUnstaked[staker]){
        IBEP20(stakingToken).transfer(staker, rewardsBeingSentToStaker + bonusRewardsBeingSentToStaker);
        } else {
            IBEP20(stakingToken).transfer(staker, rewardsBeingSentToStaker);
            _contractBalanceOfBonusRewards -=  bonusRewardsBeingSentToStaker;
            _lostBonusRewardsBecauseOfUnstaking += bonusRewardsBeingSentToStaker;
        }
        stakes[msg.sender].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[msg.sender].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        stakes[msg.sender].bonusRewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[msg.sender].stakedAmount * _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        if (totalStakedTokens > 0) {
			_lastContractBalanceOfRewards = updateRewardsBalance();
		}
        emit Realised(staker, rewardsBeingSentToStaker);
    }


    


    function _stake(address staker, uint256 stakedAmount) internal {
        require(stakedAmount > 0);
        currentStakeBeingAdded = stakedAmount;
        _realise(staker);
        currentStakeBeingAdded = 0;
        if(stakes[staker].stakedAmount == 0){
            if(howManyTimesUnstaked[staker] == 0){
                neverUnstaked[staker] = true;
                totalStakers++;
                stakerIndex[staker] = totalStakers;
                addressOfIndex[totalStakers] = staker;
            }
            stakes[staker].lockedUntil = block.timestamp + _lockDuration;
        }
        stakes[staker].stakedAmount += stakedAmount;
        stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[staker].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        totalStakedTokens += stakedAmount;

        emit Staked(staker, stakedAmount);
    }

    function _unstake(address staker, uint256 amount) internal {
        require(stakes[staker].stakedAmount >= amount, "Insufficient Stake");
        require(stakes[staker].lockedUntil <= block.timestamp, "Your staked tokens ares still locked, please try again later");

        _realise(staker);

        stakes[staker].stakedAmount -= amount;
        stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[staker].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        totalStakedTokens -= amount;
        
        neverUnstaked[staker] = false;
        howManyTimesUnstaked[staker] += 1;       
        IBEP20(stakingToken).transfer(staker, amount);
        emit Unstaked(staker, amount);
    }


    function refundEveryone() external {
        require(msg.sender == admin, "Only the admin can close the staking and send everyone their tokens");
        for(uint256 i = 1; i <= totalStakers; i++) {
            if(availableRewards(addressOfIndex[i]) > 0) {
                IBEP20(stakingToken).transfer(addressOfIndex[i], stakes[addressOfIndex[i]].stakedAmount + availableRewards(addressOfIndex[i]));
            } else if(stakes[addressOfIndex[i]].stakedAmount > 0){
                IBEP20(stakingToken).transfer(addressOfIndex[i], stakes[addressOfIndex[i]].stakedAmount);
            }
        }
        IBEP20(stakingToken).transfer(admin, IBEP20(stakingToken).balanceOf(address(this)));
        payable(admin).transfer(address(this).balance);
    }

    function stakeFor(address staker, uint amount) external {
        require(amount > 0);
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);
        _stake(staker, amount);
    }
    
    function stakeForMany(address[] calldata stakeWallets, uint256[] calldata amount, uint256 totalAmount) external {
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), totalAmount);
        
        for(uint256 i = 0; i < stakeWallets.length; i++) {
            _stake(stakeWallets[i], amount[i]);
        }
    }

    function setLockTime(uint256 time) external authorized{
        _lockDuration = time;
    }

    function depositBonusRewards(uint amount) external {
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);
        if (amount > 0) {
            uint256 additionalAmountPerStakedToken = amount * _accuracyFactor / totalStakedTokens;
            _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _contractBalanceOfBonusRewards += amount;
            emit BonusRewardsAdded(amount);
        }  
    }
}