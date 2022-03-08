/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// ShibaYachtClubStaking
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ShibaYachtClubStaking is Auth {

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

    uint256 public totalRewardsSentOutAlready;
    uint256 public totalStakedTokens;

    mapping (address => Stake) public stakes;
    mapping (address => bool) public neverUnstaked;
    mapping (address => uint256) public howManyTimesUnstaked;
	event Realised(address account, uint amount);
    event Staked(address account, uint stakedAmount);
    event Unstaked(address account, uint amount);
    event Compounded(address account, uint amount);

    constructor (address _stakingToken) Auth(msg.sender) {
        stakingToken = _stakingToken;
        admin = msg.sender;
    }

    uint256 _accuracyFactor = 10 ** 36;
    uint256 public _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed;
    uint256 public _currentContractBalanceOfBonusRewards;
    uint256 public _contractBalanceOfBonusRewards = 0;
    uint256 public _lostBonusRewardsBecauseOfUnstaking;

    uint256 public _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed;
    uint256 public _currentContractBalanceOfRewards;
    uint256 public _lastContractBalanceOfRewards = 0;
    uint256 public _lockDuration = 0;

    uint256 lastBonusPayout;

    function getTotalRewards() external view  returns (uint256) {
        return totalRewardsSentOutAlready + IBEP20(stakingToken).balanceOf(address(this)) - totalStakedTokens;
    }

    function getCumulativeRewardsPerLP() external view returns (uint256) {
        return _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed;
    }

    function getLastContractBalance() external view returns (uint256) {
        return _lastContractBalanceOfRewards;
    }

    function getAccuracyFactor() external view returns (uint256) {
        return _accuracyFactor;
    }

    function getStake(address account) public view returns (uint256) {

        return stakes[account].stakedAmount;
    }

    function getRealisedEarnings(address staker) external view returns (uint256) {
        return stakes[staker].totalRewardsCollectedAlready; // realised gains
    }

    function getCumulativeRewards(uint256 amount) public view returns (uint256) {
        return amount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
    }


    function StakeSome(uint amount) external {
        require(amount > 0);

        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);

        _stake(msg.sender, amount);
    }

    function stakeFor(address staker, uint amount) external {
        require(amount > 0);

        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);

        _stake(staker, amount);
    }
    
    function StakeAll() external {
        uint256 amount = IBEP20(stakingToken).balanceOf(msg.sender);
        require(amount > 0);

        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);

        _stake(msg.sender, amount);
    }

    

    function UnstakeSome(uint amount) external {
        require(amount > 0);

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

    function updateRewardsBalance() public returns (uint256) {
         uint256 rewardsBalance = IBEP20(stakingToken).balanceOf(address(this)) - totalStakedTokens - _contractBalanceOfBonusRewards + _lostBonusRewardsBecauseOfUnstaking;
        _lostBonusRewardsBecauseOfUnstaking = 0;
        return rewardsBalance;
    }

    function _realise(address staker) internal {
        _currentContractBalanceOfRewards = updateRewardsBalance();

        if (_currentContractBalanceOfRewards > _lastContractBalanceOfRewards && totalStakedTokens != 0) {
            uint256 newRewards = _currentContractBalanceOfRewards - _lastContractBalanceOfRewards;
            uint256 additionalAmountPerStakedToken = newRewards * _accuracyFactor / totalStakedTokens;
            _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _lastContractBalanceOfRewards = _currentContractBalanceOfRewards;
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


        if (totalStakedTokens > 0) {
			_lastContractBalanceOfRewards = updateRewardsBalance();
		}

        emit Realised(staker, rewardsBeingSentToStaker);
    }


    function Compound() external {
        _currentContractBalanceOfRewards = updateRewardsBalance();

        if (_currentContractBalanceOfRewards > _lastContractBalanceOfRewards && totalStakedTokens != 0) {
            uint256 newRewards = _currentContractBalanceOfRewards - _lastContractBalanceOfRewards;
            uint256 additionalAmountPerStakedToken = newRewards * _accuracyFactor / totalStakedTokens;
            _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _lastContractBalanceOfRewards = _currentContractBalanceOfRewards;
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


    function _stake(address staker, uint256 stakedAmount) internal {
        require(stakedAmount > 0);
        stakedAmount = stakedAmount * 10**18;

        _realise(staker);
        if(stakes[staker].stakedAmount == 0){
            if(howManyTimesUnstaked[staker] == 0){
                neverUnstaked[staker] = true;
            }
            stakes[staker].lockedUntil = block.timestamp + _lockDuration;
        }

        // add to current address' stake
        stakes[staker].stakedAmount += stakedAmount;
        stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[staker].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        totalStakedTokens += stakedAmount;

        emit Staked(staker, stakedAmount);
    }

    function _unstake(address staker, uint256 amount) internal {
        amount = amount * 10**18;
        require(stakes[staker].stakedAmount >= amount, "Insufficient Stake");
        require(stakes[staker].lockedUntil <= block.timestamp, "Your staked tokens ares still locked, please try again later");

        _realise(staker); // realise staking gains

        // remove stake
        stakes[staker].stakedAmount -= amount;
        stakes[staker].rewardsEitherPaidOutAlreadyOrNeverEligibleFor = stakes[staker].stakedAmount * _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed / _accuracyFactor;
        totalStakedTokens -= amount;
        
        neverUnstaked[staker] = false;
        howManyTimesUnstaked[staker] += 1;        
        IBEP20(stakingToken).transfer(staker, amount);
        emit Unstaked(staker, amount);
    }

    function getCurrentRewardsPerLP() public returns (uint256 currentRewardsPerLP) {
        if(updateRewardsBalance() > _lastContractBalanceOfRewards && totalStakedTokens != 0){
            uint256 newRewards = updateRewardsBalance() - _lastContractBalanceOfRewards;
            uint256 additionalAmountPerStakedToken = newRewards * _accuracyFactor / totalStakedTokens;
            currentRewardsPerLP = _rewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed + additionalAmountPerStakedToken;
        }
    }

    
    function emergencyUnstakeAll() external {
        require(stakes[msg.sender].stakedAmount > 0, "No Stake");

        IBEP20(stakingToken).transfer(msg.sender, stakes[msg.sender].stakedAmount);
        totalStakedTokens -= stakes[msg.sender].stakedAmount;
        stakes[msg.sender].stakedAmount = 0;
    }


    function rescueTokens() external {
        require(msg.sender == admin, "Only the tokencontract can use this");
        IBEP20(stakingToken).transferFrom(address(this), admin, IBEP20(stakingToken).balanceOf(address(this)));
    }


    function depositBonusRewards(uint amount) external {
        IBEP20(stakingToken).transferFrom(msg.sender, address(this), amount);
        if (amount > 0) {
            uint256 additionalAmountPerStakedToken = amount * _accuracyFactor / totalStakedTokens;
            _bonusRewardsPerTokenStakedIfStakedSinceStartAndNeverClaimed += additionalAmountPerStakedToken;
            _contractBalanceOfBonusRewards += amount;
        }
    }
}