/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.4;


// ----------------------------------------------------------------------------
// SafeMath library
// ----------------------------------------------------------------------------
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC20: sending to the zero address");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract StakingOptions730 is Owned, ReentrancyGuard {
    using SafeMath for uint256;
    
    address public LockPayV2        = 0xdCAC116fF1B4D3595E323a92902E85fBee1104bf;
    address public BUSD             = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public LockingPeriod    = 365 days;
    uint256 public ExtraReward      = 3;

    uint256 public totalStakes      = 0;
    uint256 public totalRewards     = 0;
    uint256 public totalDividends   = 0;
    uint256 private scaledRemainder = 0;
    uint256 private scaling         = uint256(10) ** 12;
    uint public round = 1;

    uint256 public totalRewardsLockPayV2    = 0;
    uint256 public totalDividendsLockPayV2  = 0;
    uint256 private scaledRemainderLockPayV2= 0;
    uint256 private scalingLockPayV2        = uint256(10) ** 12;
    uint public roundLockPayV2 = 1;
    
    
    /* Fees breaker, to protect withdraws if anything ever goes wrong */
    bool public breaker = false; // withdraw can be lock,, default unlocked
    mapping(address => uint256) public farmTime; // period that your sake it locked to keep it for farming
    
    bool public p = false;
    
    struct USER{
        uint256 stakedTokens;
        uint256 lastDividends;
        uint256 fromTotalDividend;
        uint round;
        uint256 remainder;

        uint256 lastDividendsLockPayV2;
        uint256 fromTotalDividendLockPayV2;
        uint roundLockPayV2;
        uint256 remainderLockPayV2;

        bool initialized;
    }
    
    address[] internal stakeholders;
    mapping(address => USER) stakers;
    address[] public farmers;
    mapping (uint => uint256) public payouts;                   // keeps record of each payout
    mapping (uint => uint256) public payoutsLockPayV2;      
    
    event STAKED(address staker, uint256 tokens);
    event EARNED(address staker, uint256 tokens);
    event UNSTAKED(address staker, uint256 tokens);
    event PAYOUT(uint256 round, uint256 tokens, address sender);
    event PAYOUTLockPayV2(uint256 round, uint256 tokens, address sender);
    event CLAIMEDREWARD(address staker, uint256 reward);
    event CLAIMEDREWARDLockPayV2(address staker, uint256 reward);
    
    constructor() {  
    }

    function setBreaker(bool _breaker) external onlyOwner {
        breaker = _breaker;
    }
    
    function setp(bool _p) external onlyOwner {
        p = _p;
    }
    
    
    function isStakeholder(address _address)
       public
       view
       returns(bool)
   {
       
       if(stakers[_address].initialized) return true;
       else return false;
   }
   
   function addStakeholder(address _stakeholder)
       internal
   {
       (bool _isStakeholder) = isStakeholder(_stakeholder);
       if(!_isStakeholder) {
           stakers[_stakeholder].initialized = true;
           farmTime[msg.sender] =  block.timestamp;
            farmers.push(_stakeholder);
       }
   }
   
    // ------------------------------------------------------------------------
    function STAKE(uint256 tokens) external nonReentrant returns(bool) {
        require(tokens > 0, "ERROR: Cannot Stake 0 tokens");
        
        require(IERC20(LockPayV2).transferFrom(msg.sender, address(this), tokens), "Tokens cannot be transferred from user for locking");
           
            // add pending rewards to remainder to be claimed by user later, if there is any existing stake
            uint256 owing = pendingReward(msg.sender);
            stakers[msg.sender].remainder += owing;
            
            stakers[msg.sender].stakedTokens = tokens.add(stakers[msg.sender].stakedTokens);
            stakers[msg.sender].lastDividends = owing;
            stakers[msg.sender].fromTotalDividend= totalDividends;
            stakers[msg.sender].round =  round;
            
            totalStakes = totalStakes.add(tokens);
            
            addStakeholder(msg.sender);
            
            emit STAKED(msg.sender, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Owners can send the funds to be distributed to stakers using this function
    // @param tokens number of tokens to distribute
    // ------------------------------------------------------------------------
    function ADDFUNDS(uint256 tokens) external nonReentrant {
        require(tokens > 0, "ERROR: Cannot give reward of 0 BUSD");

        require(IERC20(BUSD).transferFrom(msg.sender, address(this), tokens), "Tokens cannot be transferred from user for locking");
        
        totalRewards = totalRewards.add(tokens);
        _addPayout(tokens);

        
    }
    
    // ------------------------------------------------------------------------
    // Private function to register payouts
    // ------------------------------------------------------------------------
    function _addPayout(uint256 tokens) private{
        // divide the funds among the currently staked tokens
        // scale the deposit and add the previous remainder
        uint256 available = (tokens.mul(scaling)).add(scaledRemainder); 
        uint256 dividendPerToken = available.div(totalStakes);
        scaledRemainder = available.mod(totalStakes);
        
        totalDividends = totalDividends.add(dividendPerToken);
        payouts[round] = payouts[round - 1].add(dividendPerToken);
        
        emit PAYOUT(round, tokens, msg.sender);
        round++;
    }
    
    // ------------------------------------------------------------------------
    // Stakers can claim their pending rewards using this function
    // ------------------------------------------------------------------------
    function CLAIMREWARD() public nonReentrant {
        
        if(totalDividends >= stakers[msg.sender].fromTotalDividend){
            uint256 owing = pendingReward(msg.sender);
        
            owing = owing.add(stakers[msg.sender].remainder);
            stakers[msg.sender].remainder = 0;

            //-- send token here
            require(IERC20(BUSD).transfer(msg.sender, owing), "Error in un-staking tokens");
             emit CLAIMEDREWARD(msg.sender, owing);
        
            stakers[msg.sender].lastDividends = owing; // unscaled
            stakers[msg.sender].round = round; // update the round
            stakers[msg.sender].fromTotalDividend = totalDividends; // scaled
        }  
    }
    
    // ------------------------------------------------------------------------
    // Get the pending rewards of the staker
    // @param _staker the address of the staker
    // ------------------------------------------------------------------------    
    function pendingReward(address staker) private returns (uint256) {
        require(staker != address(0), "ERC20: sending to the zero address");
        
        uint stakersRound = stakers[staker].round;
        uint256 amount =  ((totalDividends.sub(payouts[stakersRound - 1])).mul(stakers[staker].stakedTokens)).div(scaling);
        stakers[staker].remainder += ((totalDividends.sub(payouts[stakersRound - 1])).mul(stakers[staker].stakedTokens)) % (scaling) ;
        return amount;
    }
    
    function getPendingReward(address staker) public view returns(uint256 _pendingReward) {
        require(staker != address(0), "ERC20: sending to the zero address");
         uint stakersRound = stakers[staker].round;
         
        uint256 amount =  ((totalDividends.sub(payouts[stakersRound - 1])).mul(stakers[staker].stakedTokens)).div(scaling);
        amount += ((totalDividends.sub(payouts[stakersRound - 1])).mul(stakers[staker].stakedTokens)) % (scaling) ;
        return (amount.add(stakers[staker].remainder));
    }

    function UnlockTime(address account) public view returns(uint256){
        return farmTime[account]+ LockingPeriod;
    }
    
    // ------------------------------------------------------------------------
    // Stakers can un stake the staked tokens using this function
    // @param tokens the number of tokens to withdraw
    // ------------------------------------------------------------------------
    function WITHDRAW(uint256 tokens) external nonReentrant returns(bool){
        require(breaker == false, "Admin Restricted WITHDRAW");
        require(block.timestamp >= UnlockTime(msg.sender), "ERR: Funds are Locked");
        farmTime[msg.sender] =  0;

        require(stakers[msg.sender].stakedTokens >= tokens && tokens > 0, "Invalid token amount to withdraw");
        totalStakes = totalStakes.sub(tokens);
        
        // add pending rewards to remainder to be claimed by user later, if there is any existing stake
        uint256 owing = pendingReward(msg.sender);
        stakers[msg.sender].remainder += owing;
                
        stakers[msg.sender].stakedTokens = stakers[msg.sender].stakedTokens.sub(tokens);
        stakers[msg.sender].lastDividends = owing;
        stakers[msg.sender].fromTotalDividend= totalDividends;
        stakers[msg.sender].round =  round;
        
        require(IERC20(LockPayV2).transfer(msg.sender, tokens), "Error in un-staking tokens");
        emit UNSTAKED(msg.sender, tokens);

        return true;
        
    }
    
    // ------------------------------------------------------------------------
    // Private function to calculate 1% percentage
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) private pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    // ------------------------------------------------------------------------
    // Get the number of tokens staked by a staker
    // @param _staker the address of the staker
    // ------------------------------------------------------------------------
    function yourStakedLockPayV2(address staker) public view returns(uint256 stakedLockPayV2){
        require(staker != address(0), "ERC20: sending to the zero address");
        
        return stakers[staker].stakedTokens;
    } 
     
    // ------------------------------------------------------------------------
    // Get the LockPayV2 balance of the token holder
    // @param user the address of the token holder
    // ------------------------------------------------------------------------
    function yourLockPayV2Balance(address user) external view returns(uint256 LockPayV2Balance){
        require(user != address(0), "ERC20: sending to the zero address");
        return IERC20(LockPayV2).balanceOf(user);
    }


    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    

    //----------------------------------------------------------------------------------------------------------------
    //---------------------------------L O C K   P A Y -- V2   -------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------

    // Owners can send the funds to be distributed to stakers using this function
    // @param tokens number of tokens to distribute

    uint256 public UnClaimed = 0;
    // ------------------------------------------------------------------------
    function ADDFUNDSLockPayV2() public nonReentrant {
        uint256 balanceLockPayV2inStaking = IERC20(LockPayV2).balanceOf(address(this));
        uint256 tokens = balanceLockPayV2inStaking.sub(UnClaimed.add(totalStakes));
        //require(tokens > 0, "ERROR: Cannot give reward of 0 LockPayV2");
        
        if(tokens > 0) {
            uint256 reward = (tokens.mul(ExtraReward)).div(1000); //0.1% of tokens
            require(IERC20(LockPayV2).transferFrom(owner, address(this), reward), "Tokens cannot be transferred from user for locking");
            
            UnClaimed += tokens.add(reward);
            totalRewardsLockPayV2 = totalRewardsLockPayV2.add(tokens.add(reward));
            _addPayoutLockPayV2(tokens.add(reward));
        }
    }
    
    // ------------------------------------------------------------------------
    // Private function to register payouts
    // ------------------------------------------------------------------------
    function _addPayoutLockPayV2(uint256 tokens) private{
        // divide the funds among the currently staked tokens
        // scale the deposit and add the previous remainder
        uint256 available = (tokens.mul(scalingLockPayV2)).add(scaledRemainderLockPayV2); 
        uint256 dividendPerToken = available.div(totalStakes);
        scaledRemainderLockPayV2 = available.mod(totalStakes);
        
        totalDividendsLockPayV2 = totalDividendsLockPayV2.add(dividendPerToken);
        payoutsLockPayV2[roundLockPayV2] = payoutsLockPayV2[roundLockPayV2 - 1].add(dividendPerToken);
        
        emit PAYOUTLockPayV2(roundLockPayV2, tokens, msg.sender);
        roundLockPayV2++;
    }
    
    // ------------------------------------------------------------------------
    // Stakers can claim their pending rewards using this function
    // ------------------------------------------------------------------------
    function CLAIMREWARDLockPayV2() public {
        require(block.timestamp >= UnlockTime(msg.sender) , "ERR: Funds are Locked");
        
        if(totalDividendsLockPayV2 >= stakers[msg.sender].fromTotalDividendLockPayV2){
            uint256 owing = pendingRewardLockPayV2(msg.sender);
        
            owing = owing.add(stakers[msg.sender].remainderLockPayV2);
            stakers[msg.sender].remainderLockPayV2 = 0;

            //-- send token here
            UnClaimed = UnClaimed.sub(owing);
            require(IERC20(LockPayV2).transfer(msg.sender, owing), "Error in un-staking tokens");
            emit CLAIMEDREWARDLockPayV2(msg.sender, owing);
        
            stakers[msg.sender].lastDividendsLockPayV2 = owing; // unscaled
            stakers[msg.sender].roundLockPayV2 = roundLockPayV2; // update the round
            stakers[msg.sender].fromTotalDividendLockPayV2 = totalDividendsLockPayV2; // scaled
        }
    }
    
    // ------------------------------------------------------------------------
    // Get the pending rewards of the staker
    // @param _staker the address of the staker
    // ------------------------------------------------------------------------    
    function pendingRewardLockPayV2(address staker) private returns (uint256) {
        require(staker != address(0), "ERC20: sending to the zero address");
        
        uint stakersRound = stakers[staker].roundLockPayV2;
        uint256 amount =  ((totalDividendsLockPayV2.sub(payoutsLockPayV2[stakersRound - 1])).mul(stakers[staker].stakedTokens)).div(scalingLockPayV2);
        stakers[staker].remainderLockPayV2 += ((totalDividendsLockPayV2.sub(payoutsLockPayV2[stakersRound - 1])).mul(stakers[staker].stakedTokens)) % (scalingLockPayV2) ;
        return amount;
    }
    
    function getPendingRewardLockPayV2(address staker) public view returns(uint256 _pendingReward) {
        require(staker != address(0), "ERC20: sending to the zero address");
         uint stakersRound = stakers[staker].roundLockPayV2;
         
        uint256 amount =  ((totalDividendsLockPayV2.sub(payoutsLockPayV2[stakersRound - 1])).mul(stakers[staker].stakedTokens)).div(scalingLockPayV2);
        amount += ((totalDividendsLockPayV2.sub(payoutsLockPayV2[stakersRound - 1])).mul(stakers[staker].stakedTokens)) % (scalingLockPayV2) ;
        return (amount.add(stakers[staker].remainderLockPayV2));
    }
   
}