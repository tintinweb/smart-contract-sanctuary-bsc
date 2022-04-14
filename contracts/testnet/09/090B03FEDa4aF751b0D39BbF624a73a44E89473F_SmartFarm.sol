// SPDX-License-Identifier: MIT

/**
 * Smart Farming Contract
 * @author Sho
 */

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import './libs/TransferHelper.sol';
import './interfaces/ISmartComp.sol';
import './interfaces/IUniswapRouter.sol';
import './interfaces/IUniswapPair.sol';
import './interfaces/IUniswapFactory.sol';

contract SmartFarm is UUPSUpgradeable, OwnableUpgradeable, ISmartFarm {
  /// @dev Params for Passive Rewards
  uint public constant DURATION = 7 days;

  // Timestamp for current period finish
  uint256 public periodFinish;
  // RewardRate for the rest of the PERIOD
  uint256 public rewardRate;
  // Last time any user took action
  uint256 public lastUpdateTime;
  // Ever increasing rewardPerToken rate, based on % of total supply
  uint256 public rewardPerTokenStored;

  ISmartComp public comptroller;

  /// @dev Info of each user that stakes LP tokens.
  mapping(address => UserInfo) public userInfo;

  /// @dev Farming Tax percent to distribute
  uint256 public farmingTax_referral;
  uint256 public farmingTax_golden;
  uint256 public farmingTax_dev;
  uint256 public farmingTax_passive;
  uint256 public unstakingFee;

  uint256 public farmingRewardPercent;

  /// @dev Address for collecting fee
  address public feeAddress;

  uint256 public totalLpStaked;
  uint256 public totalStaked;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  event RewardAdded(uint256 reward);
  event Staked(address indexed account, uint256 amount, uint256 lp);
  event Withdrawn(address indexed account, uint256 amount, uint256 lp);
  event Claimed(address indexed account, uint256 amount);
  event UpdatedRewardWallet(address indexed account);

  function initialize(address _comp) 
    public initializer 
  {
		__Ownable_init();
    __SmartFarm_init_unchained(_comp);
  }

  function _authorizeUpgrade(address newImplementation) 
    internal override onlyOwner 
  {    
  }

  function __SmartFarm_init_unchained(
    address _comp
  ) internal initializer {
    comptroller = ISmartComp(_comp);
    
    farmingTax_referral = 1000;
    farmingTax_golden = 300;
    farmingTax_dev = 100;
    farmingTax_passive = 100;

    unstakingFee = 0;
    farmingRewardPercent = 10;   // 0.1 %

    feeAddress = msg.sender;
    _status = _NOT_ENTERED;
  }

  /**
  * @notice Sets a new comptroller
  * @dev Admin function to set a new comptroller
  */
  function setComptroller(ISmartComp newComptroller) 
    external onlyOwner 
  {
    // Ensure invoke comptroller.isComptroller() returns true
    require(newComptroller.isComptroller(), "marker method returned false");
    // Set comptroller to newComptroller
    comptroller = newComptroller;
  }

  /**
   * Update Fee information
   */
  function updateFeeInfo(
    uint256 _farmingTax_referral,             // Farming tax percent for referral system
    uint256 _farmingTax_golden,               // Farming tax percent for golden tree pool
    uint256 _farmingTax_dev,                  // Farming tax percent for dev wallet
    uint256 _farmingTax_passive,              // Farming tax percent for passive share
    uint256 _unstakingFee,                    // Unstaking fee percent
    address _feeAddress
  ) external onlyOwner {
    require(_farmingTax_referral < 5000, "SmartFarm#updateFeeInfo: Too big farming tax referral");
    require(_farmingTax_golden < 5000, "SmartFarm#updateFeeInfo: Too big farming tax golden");
    require(_farmingTax_dev < 5000, "SmartFarm#updateFeeInfo: Too big farming tax dev");
    require(_farmingTax_passive < 5000, "SmartFarm#updateFeeInfo: Too big farming tax passwive");    
    require(_unstakingFee < 5000, "SmartFarm#updateFeeInfo: Too big unstaking fee");
    require(_feeAddress != address(0x0), "SmartFarm#updateFeeInfo: should be not zero address");
    
    farmingTax_referral = _farmingTax_referral;
    farmingTax_golden = _farmingTax_golden;
    farmingTax_dev = _farmingTax_dev;
    farmingTax_passive = _farmingTax_passive;
    unstakingFee = _unstakingFee;
    feeAddress = _feeAddress;
  }

  /**
   * Update farming reward pecentage and wallet address
   */
  function updateFarmingRewardParams(
    uint256 percent
  ) external onlyOwner {

    require(percent <= 10_000, "SmartFarm#updateFarmingReward: too big percent");
    farmingRewardPercent = percent;
  }

  /** @dev only Rewards distributors */
  modifier onlyRewardsDistributor() {
    require(
      msg.sender == (address)(comptroller.getSMT())
      || msg.sender == owner(), 
      "SmartFarm: only reward distributors"
    );
    _;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Notifies the contract that new rewards have been added.
   * Calculates an updated rewardRate based on the rewards in period.
   * @param _reward Units of RewardToken that have been added to the pool
   */
  function notifyRewardAmount(uint _reward)
    external override
    onlyRewardsDistributor
    updatePassiveReward(address(0), true)
  {
    uint currentTime = block.timestamp;

    // If previous period over, reset rewardRate
    if (currentTime >= periodFinish) {
      rewardRate = _reward / DURATION;
    }
    // If additional reward to existing period, calc sum
    else {
      uint remaining = periodFinish - currentTime;
      uint leftover = remaining * rewardRate;
      rewardRate = (_reward + leftover) / DURATION;
    }

    lastUpdateTime = currentTime;
    periodFinish = currentTime + DURATION;

    emit RewardAdded(_reward);
  }

  function calcPassiveReward(address account) internal {
    // Setting of global vars
    uint256 newRewardPerToken = rewardPerToken();
    // If statement protects against loss in initialisation case
    if (newRewardPerToken > 0) {
      rewardPerTokenStored = newRewardPerToken;
      lastUpdateTime = lastTimeRewardApplicable();
      // Setting of personal vars based on new globals
      if (account != address(0)) {
        UserInfo storage uInfo = userInfo[account];
        uInfo.rewards = earnedPassive(account);
        uInfo.rewardPerTokenPaid = newRewardPerToken;
      }
    }
  }

  /** @dev Updates the reward for a given address, before executing function */
  modifier updatePassiveReward(address account, bool beforeAndAfter) { // beforeAndAfter: 0: before,  1: after
    if(!beforeAndAfter) calcPassiveReward(account);
    _;
    if(beforeAndAfter) calcPassiveReward(account);
  }

  function calcFixedReward(address account) internal {
    if (account != address(0)) {
        UserInfo storage uInfo = userInfo[account];
        uInfo.rewards = earned(account);
        uInfo.lastUpdated = block.timestamp;
    }
  }

  modifier updateFixedReward(address account, bool beforeAndAfter) { // beforeAndAfter: 0: before,  1: after
      if(!beforeAndAfter) calcFixedReward(account);
      _;
      if(beforeAndAfter) calcFixedReward(account);
  }

  function reserveOf(address account) public view returns (uint256) {
    return userInfo[account].tokenBalance;
  }

  function balanceOf(address account) public view returns (uint256) {
    return userInfo[account].balance;
  }

  function rewardsOf(address account) public view returns (uint256) {
    return userInfo[account].rewards;
  }

  function havestOf(address account) public view returns (uint256) {
    return userInfo[account].havested;
  }

  function userInfoOf(address account) public view returns (UserInfo memory) {
    return userInfo[account];
  }

   /**
   * @dev Gets the last applicable timestamp for this reward period
   */
  function lastTimeRewardApplicable() public view returns (uint) {
    return block.timestamp < periodFinish? block.timestamp : periodFinish;
  }

  /**
   * @dev Calculates the amount of unclaimed rewards per token since last update,
   * and sums with stored to give the new cumulative reward per token
   * @return 'Reward' per staked token
   */
  function rewardPerToken() public view returns (uint) {
    // If there is no StakingToken liquidity, avoid div(0)
    uint256 stakedTokens = totalStaked;
    if (stakedTokens == 0) {
      return rewardPerTokenStored;
    }
    // new reward units to distribute = rewardRate * timeSinceLastUpdate
    uint256 rewardUnitsToDistribute = rewardRate * (lastTimeRewardApplicable() - lastUpdateTime);
    // prevent overflow
    require(rewardUnitsToDistribute < type(uint256).max / 1e18);
    // new reward units per token = (rewardUnitsToDistribute * 1e18) / totalTokens
    uint256 unitsToDistributePerToken = rewardUnitsToDistribute * 1e18 / stakedTokens;
    // return summed rate
    return rewardPerTokenStored + unitsToDistributePerToken;
  }

  /**
   * Calculate earned amount from lastUpdated to block.timestamp
   * Check License activate status while staking 
   */
  function earned(address account) public view returns (uint256) {
    uint256 blockTime = block.timestamp;
    UserInfo memory uInfo = userInfo[account];
    // Check license activation duration 
    (uint256 start, uint256 end) = comptroller.getSmartArmy().licenseActiveDuration(account, uInfo.lastUpdated, blockTime);
    if(start == 0 || end == 0) {
      return uInfo.rewards;
    }    
    uint256 duration = end - start;
    uint256 amount = duration * reserveOf(account) * farmingRewardPercent / 86400 / 10_000;
    return uInfo.rewards + amount;
  }

  /**
   * @dev Calculates the amount of unclaimed rewards a user has earned
   * @param _account User address
   * @return Total reward amount earned
   */
  function earnedPassive(address _account) public view returns (uint256) {
    UserInfo memory uInfo = userInfo[_account];

    // current rate per token - rate user previously received
    uint256 userRewardDelta = rewardPerToken() - uInfo.rewardPerTokenPaid;
    // new reward = staked tokens * difference in rate
    uint256 userNewReward = reserveOf(_account) * userRewardDelta / 1e18;
    // add to previous rewards
    return uInfo.rewards + userNewReward;
  }

  /**
   * Stake SMT token
   * Swap with BUSD and add liquidity to pcs
   * Lock LP token to contract
   */
  function stakeSMT(
    address account,
    uint256 amount    
  ) 
    public override
    updateFixedReward(account, true)
    updatePassiveReward(account, true)
    nonReentrant
    returns(uint256)
  {
    ISmartArmy smartArmy = comptroller.getSmartArmy();
    require(_msgSender() == address(smartArmy) || _msgSender() == account, "SmartFarm#stakeSMT: invalid account");

    (uint256 liquidity, uint256 stakedAmount) = _tranferSmtToContract(account, amount);
    require(liquidity > 0, "SmartFarm#stakeSMT: failed to add liquidity");

    ISmartOtherAchievement ach = comptroller.getSmartOtherAchievement();
    if(stakedAmount > 100) ach.addFarmDistributor(account);

    UserInfo storage uInfo = userInfo[account];
    uInfo.balance = uInfo.balance + liquidity;
    uInfo.tokenBalance = uInfo.tokenBalance + stakedAmount;

    totalLpStaked = totalLpStaked + liquidity;
    totalStaked = totalStaked + stakedAmount;

    emit Staked(account, amount, liquidity);

    return liquidity;
  }

  /**
   * @notice Withdraw Staked SMT
   */
  function withdrawSMT(
    address account,
    uint256 lpAmount
  )
    public 
    override
    updateFixedReward(account, false)
    updatePassiveReward(account, false)
    nonReentrant
    returns(uint256)
  {
    require(lpAmount > 0, "SmartFarm#withdrawSMT: Cannot withdraw 0");
    require(lpAmount <= balanceOf(account), "SmartFarm#withdrawSMT: Cannot withdraw more than balance");

    ISmartArmy smartArmy = comptroller.getSmartArmy();
    uint256 lpLocked = smartArmy.lockedLPOf(account);

    require(_msgSender() == address(smartArmy) || _msgSender() == account, "SmartFarm#withdrawSMT: invalid account");

    if(_msgSender() == address(smartArmy)) {
      require(lpLocked == lpAmount, "SmartFarm#withdrawSMT: withdraw amount from SmartArmy is invalid");
    } else {
      require(lpLocked + lpAmount <= balanceOf(account), "SmartFarm#withdrawSMT: withdraw amount is invalid");
    }

    ISmartOtherAchievement ach = comptroller.getSmartOtherAchievement();
    if(ach.isFarmer(account))
      ach.removeFarmDistributor(account);

    UserInfo storage uInfo = userInfo[account];

    uint256 smtAmount = _tranferSmtToUser(account, lpAmount);
    require(smtAmount > 0, "SmartFarm#withdrawSMT: failed to sent SMT to staker");

    uInfo.balance = uInfo.balance - lpAmount;
    
    if(uInfo.tokenBalance < smtAmount) uInfo.tokenBalance = 0;
    else uInfo.tokenBalance = uInfo.tokenBalance - smtAmount;
    
    if(totalStaked < smtAmount) totalStaked = 0;
    else totalStaked = totalStaked - smtAmount;

    totalLpStaked = totalLpStaked - lpAmount;
    
    emit Withdrawn(account, smtAmount, lpAmount);

    return smtAmount;
  }

  /**
   * ///@notice Redeem SMT rewards from staking
   */
  function claimReward(uint256 _amount) 
    public 
    override
    nonReentrant
    updateFixedReward(_msgSender(), false)
  {
      UserInfo storage uInfo = userInfo[_msgSender()];
      uint256 rewards = rewardsOf(_msgSender());
      require(rewards > 0 , "SmartFarm#stakeSMT: Not enough rewards to claim");

      TransferHelper.safeTransfer(address(comptroller.getSMT()), _msgSender(), _amount);

      uInfo.rewards = uInfo.rewards - _amount;
      uInfo.havested = uInfo.havested + _amount;
      emit Claimed(_msgSender(), rewards);
  }

    function claimRewardV2(uint256 _amount) 
    public 
    nonReentrant
    updateFixedReward(_msgSender(), false)
  {
      UserInfo storage uInfo = userInfo[_msgSender()];
      uint256 rewards = rewardsOf(_msgSender());
      require(rewards > 0 , "SmartFarm#stakeSMT: Not enough rewards to claim");

      TransferHelper.safeTransfer(address(comptroller.getSMT()), _msgSender(), _amount);

      uInfo.rewards = uInfo.rewards - _amount;
      uInfo.havested = uInfo.havested + _amount;
      emit Claimed(_msgSender(), rewards);
  }
  
  function exit() external nonReentrant {
    withdrawSMT(msg.sender, balanceOf(msg.sender));
    claimReward(rewardsOf(msg.sender));
  }

  /**
   * Transfer smt token to contract.
   * Swap half as BUSD, 
   * Add Liquidity => LP token Lock
   */
  function _tranferSmtToContract(
    address _from, 
    uint256 _amount
  ) private returns(uint, uint) {
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
  
    // Transfer SMT token from user to contract
    uint256 beforeBalance = smtToken.balanceOf(address(this));
    IERC20(smtToken).transferFrom(_from, address(this), _amount);
    uint256 amount = smtToken.balanceOf(address(this)) - beforeBalance;
    require(amount > 0, "SmartFarm#_transferSmtToContract: faild to transfer SMT token");

    // distribute farming tax
    {
      uint256 totalFarmingTax = _distributeFarmingTax(_from, amount);
      amount = amount - totalFarmingTax;
    }

    // Swap half of SMT token to BUSD
    uint256 half = amount / 2;
    uint256 otherHalf = amount - half;

    uint256 beforeBusdBalance = busdToken.balanceOf(address(this));
    _swapTokensForBUSD(half);
    uint256 newBusdBalance = busdToken.balanceOf(address(this)) - beforeBusdBalance;

    // add liquidity
    (, , uint liquidity) = _addLiquidity(otherHalf, newBusdBalance);

    return (liquidity, amount);
  }

  /**
   * Distribute farming tax to ...
   */
  function _distributeFarmingTax(
    address account,
    uint256 farmingAmount
  ) internal returns (uint256) {
    // distribute farming tax
    // 10% goes to referral system
    // 3% goes to golden tree pool
    // 1% goes to development wallet
    // 1% goes to passive global share
    IERC20 smtToken = comptroller.getSMT();

    uint256 farmingTaxReferralAmount = farmingAmount * farmingTax_referral / 10_000;
    uint256 farmingTaxGoldenAmount = farmingAmount * farmingTax_golden / 10_000;
    uint256 farmingTaxDevAmount = farmingAmount * farmingTax_dev / 10_000;
    uint256 farmingTaxPassiveAmount = farmingAmount * farmingTax_passive / 10_000;

    uint256 totalPaid = 0;

    if(farmingTaxReferralAmount > 0) {
      ISmartLadder smartLadder = comptroller.getSmartLadder();
      TransferHelper.safeTransfer(address(smtToken), address(smartLadder), farmingTaxReferralAmount);
      smartLadder.distributeFarmingTax(account);

      totalPaid = totalPaid + farmingTaxReferralAmount;
    }
    
    if(farmingTaxGoldenAmount > 0) {
      IGoldenTreePool pool = comptroller.getGoldenTreePool();

      TransferHelper.safeTransfer(address(smtToken), address(pool), farmingTaxGoldenAmount);
      pool.notifyReward(farmingTaxGoldenAmount, account);

      totalPaid = totalPaid + farmingTaxGoldenAmount;
    }

    if(farmingTaxDevAmount > 0) {
      TransferHelper.safeTransfer(address(smtToken), address(feeAddress), farmingTaxDevAmount);
      totalPaid = totalPaid + farmingTaxDevAmount;
    }

    if(farmingTaxPassiveAmount > 0) {
      // TODO
      // transfer smt to passive pool and sync
      ISmartNobilityAchievement ach = comptroller.getSmartNobilityAchievement();
      TransferHelper.safeTransfer(address(smtToken), address(ach), farmingTaxPassiveAmount);
      ach.swapDistribute(farmingTaxPassiveAmount);
      ach.distributePassiveShare(farmingTaxPassiveAmount);
      totalPaid = totalPaid + farmingTaxPassiveAmount;
    }

    return totalPaid;
  }


  /**
   * Transfer smt token to user.
   * Remove liquidity
   * Swap half as SMT, 
   */
  function _tranferSmtToUser(address _to, uint256 _lpAmount) private returns(uint) {
    if(_lpAmount == 0) {
      return 0;
    }
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
    IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

    // Tranfer Penalty Fee to fee address
    uint256 feeAmount = _lpAmount * unstakingFee / 10_1000;

    address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(smtToken), address(busdToken));
    IERC20(pair).transfer(feeAddress, feeAmount);

    // Remove liquidity from dex
    (uint smtAmount, uint busdAmount) = _removeLiquidity(_lpAmount - feeAmount);

    // Swap BUSD to smt token
    uint256 beforeBalance = smtToken.balanceOf(address(this));
    _swapTokensForSMT(busdAmount);
    uint256 amount = uint256(smtAmount) + smtToken.balanceOf(address(this)) - beforeBalance;
    
    // Transfer SMT token to user
    IERC20(smtToken).transfer(_to, amount);
    
    return amount;
  }

  function _swapTokensForBUSD(uint256 tokenAmount) private {
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
    IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

    // generate the uniswap pair path of token -> busd
    address[] memory path = new address[](2);
    path[0] = address(smtToken);
    path[1] = address(busdToken);

    smtToken.approve(address(uniswapV2Router), tokenAmount);
    
    // make the swap
    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
    );
  }

  function _swapTokensForSMT(uint256 tokenAmount) private {
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
    IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

    // generate the uniswap pair path of token -> busd
    address[] memory path = new address[](2);
    path[0] = address(busdToken);
    path[1] = address(smtToken);

    busdToken.approve(address(uniswapV2Router), tokenAmount);
    
    // make the swap
    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
    );
  }

  function _addLiquidity(uint256 tokenAmount, uint256 busdAmount) 
    private 
    returns (uint amountA, uint amountB, uint liquidity)
  {
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
    IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

    // approve token transfer to cover all possible scenarios
    smtToken.approve(address(uniswapV2Router), tokenAmount);
    busdToken.approve(address(uniswapV2Router), busdAmount);
    
    // add the liquidity
    (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(
        address(smtToken),
        address(busdToken),
        tokenAmount,
        busdAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        address(this),
        block.timestamp
    );
  }

  function _removeLiquidity(uint256 lpAmount) 
    private 
    returns (uint amountA, uint amountB)
  {
    IERC20 smtToken = comptroller.getSMT();
    IERC20 busdToken = comptroller.getBUSD();
    IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

    // approve token transfer to cover all possible scenarios
    address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(smtToken), address(busdToken));
    IERC20(pair).approve(address(uniswapV2Router), lpAmount);    
    
    // add the liquidity
    (amountA, amountB) = uniswapV2Router.removeLiquidity(
        address(smtToken),
        address(busdToken),
        lpAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        address(this),
        block.timestamp
    );
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    address constant NATIVE_TOKEN = address(0);

    function isEther(address token) internal pure returns (bool) {
      return token == NATIVE_TOKEN;
    }

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function safeTransferTokenOrETH(address token, address to, uint value) internal {
        isEther(token) 
            ? safeTransferETH(to, value)
            : safeTransfer(token, to, value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './ISmartArmy.sol';
import './ISmartLadder.sol';
import './ISmartFarm.sol';
import './IGoldenTreePool.sol';
import './ISmartNobilityAchievement.sol';
import './ISmartOtherAchievement.sol';
import './IUniswapRouter.sol';
import "./ISmartTokenCash.sol";

// Smart Comptroller Interface
interface ISmartComp {
    function isComptroller() external pure returns(bool);
    function getSMT() external view returns(IERC20);
    function getBUSD() external view returns(IERC20);
    function getWBNB() external view returns(IERC20);

    function getSMTC() external view returns(ISmartTokenCash);
    function getUniswapV2Router() external view returns(IUniswapV2Router02);
    function getUniswapV2Factory() external view returns(address);
    function getSmartArmy() external view returns(ISmartArmy);
    function getSmartLadder() external view returns(ISmartLadder);
    function getSmartFarm() external view returns(ISmartFarm);
    function getGoldenTreePool() external view returns(IGoldenTreePool);
    function getSmartNobilityAchievement() external view returns(ISmartNobilityAchievement);
    function getSmartOtherAchievement() external view returns(ISmartOtherAchievement);
    function getSmartBridge() external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartArmy {
    /// @dev License Types
    struct LicenseType {
        uint256  level;        // level
        string   name;         // Trial, Opportunist, Runner, Visionary
        uint256  price;        // 100, 1000, 5000, 10,000
        uint256  ladderLevel;  // Level of referral system with this license
        uint256  duration;     // default 6 months
        uint256  portions;
        bool     isValid;
    }

    enum LicenseStatus {
        None,
        Pending,
        Active,
        Expired
    }

    /// @dev User information on license
    struct UserLicense {
        address owner;
        uint256 level;
        uint256 startAt;
        uint256 activeAt;
        uint256 expireAt;
        uint256 lpLocked;
        string tokenUri;

        LicenseStatus status;
    }

    /// @dev User Personal Information
    struct UserPersonal {
        address sponsor;
        string username;
        string telegram;
    }

    /// @dev Fee Info 
    struct FeeInfo {
        uint256 penaltyFeePercent;      // liquidate License LP fee percent
        uint256 extendFeeBNB;       // extend Fee as BNB
        address feeAddress;
    }

    function licenseOf(address account) external view returns(UserLicense memory);
    function licensePortionOf(address account) external view returns(uint256);
    function licenseIdOf(address account) external view returns(uint256);
    function licenseTypeOf(uint256 level) external view returns(LicenseType memory);
    function lockedLPOf(address account) external view returns(uint256);
    function isActiveLicense(address account) external view returns(bool);
    function isEnabledIntermediary(address account) external view returns(bool);
    function licenseLevelOf(address account) external view returns(uint256);
    function licensedUsers() external view returns(address[] memory);
    function licenseActiveDuration(address account, uint256 from, uint256 to) external view returns(uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartLadder {
    /// @dev Ladder system activities
    struct Activity {
        string      name;         // buytax, farming, ...
        uint16[7]   share;        // share percentage
        address     token;        // share token address
        bool        enabled;      // enabled or disabled temporally
        bool        isValid;
        uint256     totalDistributed; // total distributed
    }
    
    function registerSponsor(address _user, address _sponsor) external;
    function distributeTax(uint256 id, address account) external; 
    function distributeBuyTax(address account) external; 
    function distributeFarmingTax(address account) external; 
    function distributeSmartLivingTax(address account) external; 
    function distributeEcosystemTax(address account) external; 
    
    function activity(uint256 id) external view returns(Activity memory);
    function sponsorOf(address account) external view returns(address);
    function usersOf(address _sponsor) external view returns(address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartFarm {
    /// @dev Pool Information
    struct PoolInfo {
        address stakingTokenAddress;     // staking contract address
        address rewardTokenAddress;      // reward token contract
        uint256 rewardPerDay;            // reward percent per day
        uint unstakingFee;            
        uint256 totalStaked;             /* How many tokens we have successfully staked */
    }

    struct UserInfo {
        uint256 tokenBalance;
        uint256 balance;
        uint256 havested;
        uint256 rewards;
        uint256 rewardPerTokenPaid;     // User rewards per token paid for passive
        uint256 lastUpdated;
    }
    
    function stakeSMT(address account, uint256 amount) external returns(uint256);
    function withdrawSMT(address account, uint256 amount) external returns(uint256);
    function claimReward(uint256 _amount) external;
    function notifyRewardAmount(uint _reward) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IGoldenTreePool {
    function swapDistribute(uint256 _amount) external;
    function notifyReward(uint256 amount, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartNobilityAchievement {

    struct NobilityType {
        string            title;               // Title of Nobility Folks Baron Count Viscount Earl Duke Prince King
        uint256           growthRequried;      // Required growth token
        uint256           goldenTreeRewards;   // SMTC golden tree rewards
        uint256           passiveShare;        // Passive share percent
        uint256           availableTitles;     // Titles available
        uint256[]         chestSMTRewardPool;
        uint256[]         chestSMTCRewardPool;        
    }

    struct UserInfo {
        uint256[] chestRewards; // 0: SMT,  1: SMTC
        uint256 checkRewardUpdated;
        uint256[] nobleRewards; // 0: claim, 1: unclaim
        uint256[] passiveShareRewards; // 0: claim, 1: unclaim
    }

    function claimChestSMTReward(uint256) external;
    function claimChestSMTCReward(uint256) external;
    function claimNobleReward(uint256) external;
    function claimPassiveShareReward(uint256) external;

    function distributeToNobleLeaders(uint256) external;
    function distributePassiveShare(uint256) external;

    function notifyGrowth(address, uint256, uint256) external returns(bool);

    function swapDistribute(uint256) external;

    function isNobleLeader(address) external view returns(bool);
    function isUpgradeable(uint256, uint256) external view returns(bool, uint256);

    function nobilityOf(address) external view returns(NobilityType memory);
    function nobilityTitleOf(address) external view returns(string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartOtherAchievement {

    struct UserInfo {
        uint256[] surprizeRewards; // 0: SMT, 1: SMTC
        uint256[] farmRewards;  // 0: claim, 1: unclaim
        uint256[] sellTaxRewards;  // 0: claim, 1: unclaim
    }

    function claimFarmReward(uint256) external;
    function claimSurprizeSMTReward(uint256) external;
    function claimSurprizeSMTCReward(uint256) external;
    function claimSellTaxReward(uint256) external;

    function distributeSellTax(uint256) external;
    function distributeToFarmers(uint256) external;
    function distributeSurprizeReward(address, uint256) external;

    function addFarmDistributor(address) external;
    function removeFarmDistributor(address) external;

    function swapDistribute(uint256) external;

    function isFarmer(address) external view returns(bool);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '../libs/IBEP20.sol';

interface ISmartTokenCash is IBEP20 {
    function burn(uint256 amount) external; 
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

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