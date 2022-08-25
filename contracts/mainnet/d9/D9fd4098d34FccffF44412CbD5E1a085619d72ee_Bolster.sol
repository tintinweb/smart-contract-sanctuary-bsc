// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error Bolster__TransferFailed();
error Bolster__NeedsMoreThanZero();
error Bolster__BalanceNotEnough();
error Bolster__TokenNotAllowed();
error Bolster__DurationNotReached();
error Bolster__CantWithdrawNow();
error Bolster__NeedsMoreThanMinStakingAmount();
error Bolster__UserAlreadyReffered();
error Bolster__InsufficentDirectBonusBalance();
error Bolster__InsufficentIncentiveBonusBalance();
error Bolster__InsufficentTeamBonusBalance();
error Bolster__TeamDurationNotReached();
error Bolster__InsufficentAirDropBonusBalance();
error Bolster__StakingNotActive();
error Bolster__WithdrawAirDropNotActive();

contract Bolster is ReentrancyGuard, Ownable {
    
    IERC20 public s_stakingToken;

    struct Associate {
     uint256 referralCount;
     uint256 directRefBonus;
     uint256 incentiveBonus;
     uint256 teamReward;
     uint256 airDrop;
     string level;
     string  referralLink;
     address[] referrals;
     mapping(address=>bool) s_userReffered;
    }


    mapping(address=>Associate) private s_addressToAssociate;
   


    enum Levels {MERCURY, VENUES, EARTH, MARS, JUPITER, SATURN, URANUS, NEPTUNE, PLUTO, ERIS}
    
  

    uint256 private REWARD_RATE = 2000000;
    uint256 private s_lastUpdateTime;
    mapping(address => uint256) private s_stakingDuration;
    mapping(address => uint256) private s_teamDuration;
    uint256 private s_directBonus = 5;
    uint256 private s_incentiveBonus = 2;
    uint256 private s_teamReward = 2;
    uint256 private s_teamBonusWid = 20;
    mapping(address=>uint256) private s_AirDrop;
    bool private s_stakingOn = true;
    bool private s_withdrawAirDropOn = false;


    
    // keeps track of each users reward
    uint256 private s_rewardPerTokenStored;
    // keeps track of how much each user has been paid already
    mapping(address => uint256) private s_userRewardPerTokenPaid;
    // keeps tracks of reward each user has to claim
    mapping(address => uint256) private s_rewards;
    // total amount staked
    uint256 private s_totalSupply;
    // min staking amount
    uint256 private s_minStakingAmount = 100 ether;
    // keeps tracks of each users staked balance
    mapping(address => uint256) private s_balances;


    enum StakingState {RUNNING, CANCELLED, COMPLETED}


    event Staked(address indexed user, uint256 indexed amount, StakingState indexed state);
    event UnStaked(address indexed user, uint256 indexed amount, StakingState indexed state);
    event RewardsClaimed(address indexed user, uint256 indexed amount, StakingState indexed state);
    event WithdrawOwner(uint256 indexed amount);
    event SetMinStakeAmount(uint256 indexed newAmount);
    event DirectBonusClaimed(address indexed user, uint256 indexed amount);
    event AirDropClaimed(address indexed user, uint256 indexed amount);
    event IncentiveBonusClaimed(address indexed user, uint256 indexed amount);
    event TeamBonusClaimed(address indexed user, uint256 indexed amount);
  

    address[] private allowedTokens;
    

    constructor(address stakingToken)
    {
        s_stakingToken = IERC20(stakingToken);
        allowedTokens.push(stakingToken);
       
    }

    /**
     * @notice How much reward a token gets based on how long it's been in and during which "snapshots"
     */
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    /**
     * @notice How much reward a user has earned
     */
    function earned(address account) internal view returns (uint256){
        
        return
            ((s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account])) /
                1e10) + s_rewards[account];
    }

    /**
     * @notice Deposit tokens into this contract
     * @param amount | How much to stake
     */
    function stake(uint256 amount, address token, address referrer)
        external
        checkAllowedTokens(token)
        updateReward(msg.sender)
        nonReentrant
        moreThanMin(amount)
        updateStakingDuration()
        updateWithdrawalDurationTeam()
        
    {
        if(s_stakingOn == false){
            revert Bolster__StakingNotActive();
        }
        s_totalSupply += amount;
        s_balances[msg.sender] += amount;
      
        if(referrer != address(0))
        {
            Associate storage associate = s_addressToAssociate[referrer];

            uint256 directBonus = uint256((s_directBonus * amount) /(100 * 1e18));
            associate.directRefBonus += directBonus;

            uint256 airDropBonus = uint256((1 * amount) /(100 * 1e18));
            associate.airDrop += airDropBonus;

            if(associate.s_userReffered[msg.sender] == false)
            {

                associate.referralCount += 1;
                associate.referrals.push(msg.sender);

                if(associate.referralCount <= 50)
                {
                  associate.level = "MERCURY";

                }
                else if(associate.referralCount > 50 && associate.referralCount <= 150)
                {
                  associate.level = "VENUES";
                }
                else if(associate.referralCount > 150 && associate.referralCount <= 400)
                {
                    associate.level = "EARTH";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                }
                else if(associate.referralCount > 400 && associate.referralCount <= 900)
                {
                    associate.level = "MARS";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                }
                else if(associate.referralCount > 900 && associate.referralCount <= 1900)
                {
                    associate.level = "JUPITER";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                }
                else if(associate.referralCount > 1900 && associate.referralCount <= 4900)
                {
                    associate.level = "SATURN";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                }
                else if(associate.referralCount > 4900 && associate.referralCount <= 9900)
                {
                    associate.level = "URANUS";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                    uint256 teamReward = uint256((s_teamReward * amount) /(100 * 1e18));
                    associate.teamReward += teamReward;

                }
                else if(associate.referralCount > 9900 && associate.referralCount <= 19900)
                {
                    associate.level = "NEPTUNE";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                    uint256 teamReward = uint256((s_teamReward * amount) /(100 * 1e18));
                    associate.teamReward += teamReward;

                }
                else if(associate.referralCount > 19900 && associate.referralCount <= 39900)
                {
                    associate.level = "PLUTO";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                    uint256 teamReward = uint256((s_teamReward * amount) /(100 * 1e18));
                    associate.teamReward += teamReward;

                }
                else if(associate.referralCount > 39900 && associate.referralCount <= 80000)
                {
                    associate.level = "ERIS";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                    uint256 teamReward = uint256((s_teamReward * amount) /(100 * 1e18));
                    associate.teamReward += teamReward;

                }
                else if(associate.referralCount > 80000)
                {
                    associate.level = "ERIS";

                    uint256 incentiveBonus = uint256((s_incentiveBonus * amount) /(100 * 1e18));
                    associate.incentiveBonus += incentiveBonus;

                    uint256 teamReward = uint256((s_teamReward * amount) /(100 * 1e18));
                    associate.teamReward += teamReward;

                }
            
                associate.s_userReffered[msg.sender] = true;
            }
            
            

        }

        
        
        emit Staked(msg.sender, amount, StakingState.RUNNING);
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    /**
     * @notice Withdraw tokens from this contract
     * @param amount | How much to withdraw
     */
    function unstake(uint256 amount) external updateReward(msg.sender) nonReentrant {
        uint256 duration = s_stakingDuration[msg.sender];
        if(block.timestamp < duration){
            revert Bolster__DurationNotReached();
        }

        if(s_balances[msg.sender] < amount)
        {
            revert Bolster__BalanceNotEnough();
        }
       
        
        s_totalSupply -= amount;
        s_balances[msg.sender] -= amount;
        if(s_balances[msg.sender] <= 0){
            s_stakingDuration[msg.sender] = 0;
            s_rewards[msg.sender] = 0;
        }
       
        emit UnStaked(msg.sender, amount, StakingState.CANCELLED);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    /**
     * @notice User claims their tokens
     */
    function claimReward() external updateReward(msg.sender) nonReentrant {
        
        uint256 reward = s_rewards[msg.sender];
        s_rewards[msg.sender] = 0;
        
        emit RewardsClaimed(msg.sender, reward, StakingState.COMPLETED);
        bool success = s_stakingToken.transfer(msg.sender, reward);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    function withdrawDirectBonus(uint256 amount)  external moreThanZero(amount) nonReentrant  {
        
        Associate storage associate = s_addressToAssociate[msg.sender];
        uint256 temWid = associate.directRefBonus * 1e18;
        if(amount > temWid)
        {
            revert Bolster__InsufficentDirectBonusBalance();
        }
        temWid -= amount;
        associate.directRefBonus = (temWid * 1) / 1e18;
        
        emit DirectBonusClaimed(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    function withdrawIncentiveBonus(uint256 amount) external moreThanZero(amount) nonReentrant {
        
        Associate storage associate = s_addressToAssociate[msg.sender];
        uint256 temWid = associate.incentiveBonus * 1e18;
        if(amount > temWid)
        {
            revert Bolster__InsufficentIncentiveBonusBalance();
        }
        temWid -= amount;
        associate.incentiveBonus = (temWid * 1) / 1e18;
        
        emit IncentiveBonusClaimed(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    function withdrawTeamBonus() external nonReentrant
    {
        uint256 duration = s_teamDuration[msg.sender];
        if(block.timestamp < duration)
        {
            revert Bolster__TeamDurationNotReached();
        }

        Associate storage associate = s_addressToAssociate[msg.sender];
        uint256 temWid = associate.teamReward * 1e18;
        if(temWid <= 0)
        {
            revert Bolster__InsufficentTeamBonusBalance();
        }

        uint256 amount = (s_teamBonusWid * temWid) / 100;
        
        
        temWid -= amount;
        associate.teamReward = (temWid * 1) / 1e18;
        s_teamDuration[msg.sender] = block.timestamp + 31 days;
        
        emit TeamBonusClaimed(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    function withdrawAirDrop()  external nonReentrant  {
        
        if(s_withdrawAirDropOn == false){
            revert Bolster__WithdrawAirDropNotActive();
        }
        Associate storage associate = s_addressToAssociate[msg.sender];
        uint256 air = associate.airDrop * 1e18;
        if(air <= 0)
        {
            revert Bolster__InsufficentAirDropBonusBalance();
        }
      
        associate.airDrop = 0;
        
        emit AirDropClaimed(msg.sender, air);
        bool success = s_stakingToken.transfer(msg.sender, air);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    function withdrawAdmin(uint256 amount) external onlyOwner nonReentrant {
        s_totalSupply -= amount;
        emit WithdrawOwner(amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }

    
    function getEarned() external view returns(uint256)  {

         return earned(msg.sender);
    }

   
    /********************/
    /* Modifiers Functions */
    /********************/
    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }



    modifier moreThanMin(uint256 amount) {
        if (amount < s_minStakingAmount) {
            revert Bolster__NeedsMoreThanMinStakingAmount();
        }
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount < 0) {
            revert Bolster__NeedsMoreThanZero();
        }
        _;
    }

    modifier updateStakingDuration(){
        if(s_balances[msg.sender] > 0){
          s_stakingDuration[msg.sender] = s_stakingDuration[msg.sender];

        }else{
            s_stakingDuration[msg.sender] = block.timestamp + 365 days;
        }
        _;
    }

    modifier updateWithdrawalDurationTeam()
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        
        if(associate.teamReward > 0)
        {
          s_teamDuration[msg.sender] = s_teamDuration[msg.sender];

        }
        else
        {
            s_teamDuration[msg.sender] = block.timestamp + 31 days;
        }
        _;
    }



    modifier checkAllowedTokens(address token){
        address [] memory tempAllowed = allowedTokens;
        for(uint256 i = 0; i < tempAllowed.length; i++)
        {
            require(tempAllowed[i] == token, "Token Not Allowed");
                
        }
        
        _;
    }

 

    function setRewardRate(uint256 newAmount) external onlyOwner
    {
        REWARD_RATE = newAmount;
    } 

    function getRewardRate() external view onlyOwner returns(uint256){
        return REWARD_RATE;
    }
    
    function getTotalSupply() external view returns(uint256){
        return s_totalSupply;
    }
    
    function getUserBalance() external view returns(uint256){
       return s_balances[msg.sender];
    }
    function getRewardTokenPaid() external view returns(uint256){
        return s_userRewardPerTokenPaid[msg.sender];
    }

    function getStakingDuration() external view returns(uint256){
       return s_stakingDuration[msg.sender];
    }

    function getTeamDuration() external view returns(uint256){
       return s_teamDuration[msg.sender];
    }

    function setMinStakingAmount(uint256 newAmount) external onlyOwner
    {
        s_minStakingAmount = newAmount;
        emit SetMinStakeAmount(newAmount);
    } 

    function getMinStakingAmount() external view onlyOwner returns(uint256){
        return s_minStakingAmount;
    }

    function getRewardPerTokenStored() external view onlyOwner returns(uint256){
        return rewardPerToken();
    }

    function getRewards() external view returns(uint256){
        return s_rewards[msg.sender];
    }

    function getDirectRefBonus() external view returns(uint256)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.directRefBonus * 1e18;
    }
    function getIncentiveBonus() external view returns(uint256)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.incentiveBonus * 1e18;
    }
    function getTeamReward() external view returns(uint256)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.teamReward * 1e18;
    }
    function getAirDrop() external view returns(uint256)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.airDrop * 1e18;
    }
    function getReferrals() external view returns(address[] memory)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.referrals;
    }
    function getRefCount() external view returns(uint256)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.referralCount;
    }
    function getLevel() external view returns(string memory)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        return associate.level;
    }
    function generateUrl(string calldata url) external
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        associate.referralLink = url;

    }
    function getUrl() external view returns(string memory)
    {
        Associate storage associate = s_addressToAssociate[msg.sender];
        
        return associate.referralLink;
    }
    function getUserNetEarning() external view returns(uint256)
    {
    
        Associate storage associate = s_addressToAssociate[msg.sender];
        uint256 team = associate.teamReward * 1e18;
        uint256 direct = associate.directRefBonus * 1e18;
        uint256 incentive = associate.incentiveBonus* 1e18;
        uint256 staking = earned(msg.sender);

        uint256 total = (team + direct + incentive + staking);
        return total;

    }
   
    function getUserNetworkChart(address account) external view 
    returns(uint256, uint256, uint256,uint256, string memory, string memory)
    {
       Associate storage ass = s_addressToAssociate[account];
       return (ass.referralCount, ass.directRefBonus,
        ass.incentiveBonus, ass.teamReward, ass.referralLink, ass.level);
    }
    
    function setDirectBonus(uint256 newFee) external onlyOwner
    {

       s_directBonus = newFee;
    
    }
    function getDirectBonus() external view onlyOwner returns(uint256)
    {

       return s_directBonus;
    
    }
    function setIncentiveBonus(uint256 newFee) external onlyOwner
    {

       s_incentiveBonus = newFee;
    
    }
    function getIncentiveBonusAdmin() external view onlyOwner returns(uint256)
    {

       return s_incentiveBonus;
    
    }

    function setTeamBonus(uint256 newFee) external onlyOwner
    {

       s_teamReward = newFee;
    
    }
    function getTeamBonusAdmin() external view onlyOwner returns(uint256)
    {

       return s_teamReward;
 
    }

    function setTeamPercentageWid(uint256 newFee) external onlyOwner
    {

       s_teamBonusWid = newFee;
    
    }
    function getTeamPercentageWid() external view onlyOwner returns(uint256)
    {

       return s_teamBonusWid;
 
    }
    function setStakingOn(bool status) external onlyOwner
    {
        s_stakingOn = status;
    }
    function getStakingOn() external view onlyOwner returns(bool)
    {
        return s_stakingOn;
    }
    function setwithdrawAirDropOn(bool status) external onlyOwner
    {
        s_withdrawAirDropOn = status;
    }
    function getwithdrawAirDropOn() external view onlyOwner returns(bool)
    {
        return s_withdrawAirDropOn;
    }

    function withdrawOtherCoins(uint256 amount, address coin) external onlyOwner nonReentrant {
       
        s_totalSupply -= amount;
        bool success = IERC20(coin).transfer(msg.sender, amount);
        if (!success) {
            revert Bolster__TransferFailed();
        }
    }
    
    fallback() external payable
    {
        s_totalSupply += msg.value;
    }
    receive() external payable
    {
        s_totalSupply += msg.value;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}