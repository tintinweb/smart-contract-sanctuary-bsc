/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Get a link to BEP20 token contract
interface IBEP20Token {
    // Transfer tokens on behalf
    function transferFrom(
      address _from,
      address _to,
      uint256 _value
    ) external returns (bool success);
    
    // Transfer tokens
    function transfer(
      address _to,
      uint256 _value
    ) external returns (bool success);
}

// Get a link to SEED Token smart contract
interface ISEED {
    // Mint new tokens
    function mint(
        address user,
        uint256 amount
    ) external;
}

// Get a link to NFT contract
interface NFT {
    // `Tree` keeps information realted to specific tree    
    struct Tree {
        uint256 treeId;
        uint256 treeName;
        uint256 longitude;
        uint256 latitude;
        uint256 carbonDioxideOffset;
    }

    // returns `Tree` data for given id
    function _treeData(
        uint256 tokenId
    ) external view returns (Tree memory treeData);
    
    // transfer NFT
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function
 */
contract ReentrancyGuard {
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
    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;

    uint8 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

/**
 * @dev Library module that helps to perform mathematical operations
 */
library Math {
    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint32 a, uint32 b) internal pure returns (uint32) {
        return a < b ? a : b;
    }
}

/**
 * @title Treedefi NftreeLpStakingPool Version 1.0
 *
 * @author treedefi
 */
contract NftreeLpStakingPool is ReentrancyGuard {
    
    /* ========== STATE VARIABLES ========== */

    // Address of contract owner
    address public owner;

    // Timestamp of reward period getting over
    uint32 public periodFinish;

    // Reward duration in seconds
    uint32 public rewardsDuration;

    // Timestamp of last snapshot
    uint32 public lastUpdateTime;

    // Locking period for nftree in seconds
    uint32 public lockingPeriod;

    // Locking period for lp tokens in seconds
    uint32 public lpLockingPeriod;

    // Minimum nftrees needs to be staked for lp staking 
    uint32 public minTreeStaked;

    // Contract address of reward token
    address public immutable rewardsToken;

    // Contract address of nftree
    address public immutable nftree;

    // Contract address of lp token i.e.staking token
    address public immutable lpToken;

    // Lp token deposit fee in percentage
    uint8 public lpDepositFee;

    // Harvest fee in terms of reward token in percentage
    uint8 public harvestFee;

    // Offset allocation in grams per lp token staked
    uint256 public immutable lpAllocation;

    // Fee paid in BNB for seed token harvest
    uint256 public seedTokenFee;

    // Reward distributed per second
    uint256 public rewardRate;

    // Reward distributed per input token or allocation
    uint256 public rewardPerTokenStored;

    // Total allocation counter
    uint256 public totalSupply;

    // `Stake` records stake data
    struct Stake {
        uint256 tokenId;
        uint32 stakedOn;
        uint32 unlockTime;
    }

    // `LpBinding` records LP staking data
    struct LpBinding {
        uint256 balance;
        uint256 stakedOn;
    }

    // Mapping from address to userStakes
    mapping (address => Stake[]) public userStakes;

    // Mapping from treeId to tokenIndex
    mapping (uint256 => uint256) public tokenIndex;

    // Mapping from address to lp staking data
    mapping(address => LpBinding) public lpBalance;

    // Mapping from address to userRewardPerTokenPaid
    mapping(address => uint256) private userRewardPerTokenPaid;
    
    // Mapping from address to rewards
    mapping(address => uint256) private rewards;
    
    // Mapping from address to allocation balance
    mapping(address => uint256) private _balances;
    
    /* ========== CONSTRUCTOR ========== */

    /**
	 * @dev Creates/deploys treedefi NftreeLpStakingPool Version 1.0
	 *
	 * @param owner_ address of contract owner
	 * @param rewardsToken_ address of reward bep20 token
     * @param nftree_ address of nftree contract
     * @param lpToken_ address of lp token
     * @param allocation_ offset allocation in grams per lp token staked
	 */
    constructor(
        address owner_,
        address rewardsToken_,
        address nftree_,
        address lpToken_,
        uint256 allocation_
    ) {
        // Setup smart contract internal state
        owner = owner_;
        rewardsToken = rewardsToken_;
        nftree = nftree_;
        lpToken = lpToken_;
        lpAllocation = allocation_;
    }

    /* ========== VIEWS ========== */

    /**
	 * @dev Returns total pool allocation amount of given account  
	 */
    function balanceOf(address account_) external view returns (uint256) {
        return _balances[account_];
    }

    /**
	 * @dev Returns last applicable time for reward calculation  
	 */
    function lastTimeRewardApplicable() public view returns (uint32) {
        return Math.min(uint32(block.timestamp), periodFinish);
    }

    /**
	 * @dev Returns reward per allocated amount  
	 */
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / totalSupply);
    }

    /**
	 * @dev Returns earned reward amount  
	 */
    function earned(address account_) public view returns (uint256) {
        return _balances[account_] * (rewardPerToken() - userRewardPerTokenPaid[account_]) / 1e18 + rewards[account_];
    }

    /**
	 * @dev Calculates allocation for given Nftree  
	 */
    function calculateAllocation(uint256 targetId_) public view returns (uint256) {
        return NFT(nftree)._treeData(targetId_).carbonDioxideOffset * 1e6;
    }

    /** 
     * @dev Calculates carbon offset generated for given index
     *
     * @param staker_ address of staker
     * @param index_ staking index
     */
    function calculateGeneration(address staker_, uint256 index_) public view returns (uint256) {
        uint256 _treeId = userStakes[staker_][index_].tokenId;
        return ((block.timestamp - userStakes[staker_][index_].stakedOn) * NFT(nftree)._treeData(_treeId).carbonDioxideOffset) / 31536000;
    }

    /** 
     * @dev Returns number of stakes for given address
     *
     * @param staker_ address of staker
     */
    function getStakeLength(address staker_) external view returns(uint256) {
        return userStakes[staker_].length; 
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /** 
     * @dev Stake trees
     *
     * @param tokenId_ token Id of given trees
     */
    function stakeBatch(uint256[] memory tokenId_) external {

        for(uint i; i < tokenId_.length; i++) {
            stake(tokenId_[i]);
        }

    }

    /** 
     * @dev Stake tree
     *
     * @param tokenId_ token Id of given tree
     */
    function stake(uint256 tokenId_) public nonReentrant {
        // Transfer tree to staking contract
        NFT(nftree).transferFrom(msg.sender, address(this), tokenId_);

        // Get index to be assigned
        uint256 _index = userStakes[msg.sender].length;

        // Assign index to given tokenId
        tokenIndex[tokenId_] = _index;

        // Calculate unlock time
        uint32 _unlockTime = uint32(block.timestamp + lockingPeriod);

        // Record user stakedata
        userStakes[msg.sender].push(Stake(tokenId_, uint32(block.timestamp), _unlockTime));

        // Calculate allocation for given tokenId
        uint256 _amount = calculateAllocation(tokenId_);

        // Stake given allocation
        deposit(_amount);

        // Emit an event
        emit PoolNFT(msg.sender, 2, tokenId_);
    }

    /** 
     * @dev Unstake trees
     *
     * @param tokenId_ token Id of given trees
     */
    function unstakeBatch(uint256[] memory tokenId_) external {

        for(uint i; i < tokenId_.length; i++) {
            unstake(tokenId_[i]);
        }

    }

    /** 
     * @dev Unstake tree
     *
     * @param tokenId_ token Id of given tree
     */
    function unstake(uint256 tokenId_) public nonReentrant {
        // Get index of given token
        uint256 _index = tokenIndex[tokenId_];

        require(userStakes[msg.sender][_index].tokenId == tokenId_, "Access denied");

        require(
            userStakes[msg.sender][_index].unlockTime < block.timestamp,
            "Treedefi: locking period is not over"
        );

        // Transfer tree from staking contract to user
        NFT(nftree).transferFrom(address(this), msg.sender, tokenId_);

        // Get staked allocation amount
        uint256 _amount = calculateAllocation(tokenId_); 

        // Withdraw given allocated amount
        withdraw(_amount);
        
        // Get last index
        uint256 _lastIndex = userStakes[msg.sender].length - 1;

        // Get last token Id
        uint256 _lastTokenId = userStakes[msg.sender][_lastIndex].tokenId;

        // Assign new index to last tokenId
        tokenIndex[_lastTokenId] = _index;

        // Delete index of unstake tokenId 
        delete tokenIndex[tokenId_];

        // Update stake data
        userStakes[msg.sender][_index] = userStakes[msg.sender][_lastIndex];

        // Remove element from stake data
        userStakes[msg.sender].pop();

        // Emit an event
        emit PoolNFT(msg.sender, 1, tokenId_);
    }

    /**
	 * @dev Stakes LP tokens to the staking pool
     *
     * @param amount_ amount of token to stake
	 */
    function stakeLp(uint256 amount_) external nonReentrant {
        require(userStakes[msg.sender].length >= minTreeStaked, "Staked nftrees not enough");

        // Calculate deposit fee
        uint256 _fee = (amount_ * lpDepositFee) / 100;
        
        // Transfer LP tokens to the staking pool
        IBEP20Token(lpToken).transferFrom(msg.sender, address(this), amount_ - _fee);

        // Transfer fee to the owner
        IBEP20Token(lpToken).transferFrom(msg.sender, owner, _fee);

        // Increment LP balance of user by given deducted amount
        lpBalance[msg.sender].balance += (amount_ - _fee);

        // Record staking time
        lpBalance[msg.sender].stakedOn = block.timestamp;

        // Calculate allocation based on given deducted LP amount
        uint256 _allocation = ((amount_ - _fee) * lpAllocation) / 1e12;
            
        // Stake given allocation
        deposit(_allocation);

        // Emit an event
        emit PoolLP(msg.sender, 2, amount_);
    }

    /**
	 * @dev Unstakes LP tokens from the staking pool
     *
     * @param amount_ amount of token to unstake
	 */
    function unstakeLp(uint256 amount_) external nonReentrant {
        require(amount_ <= lpBalance[msg.sender].balance, "Invalid amount");

        require(
            block.timestamp > lpBalance[msg.sender].stakedOn + lpLockingPeriod,
            "Locking period is not over"
        );

        // Decrement LP balance of user by given amount
        lpBalance[msg.sender].balance -= amount_;        

        // Transfer amount to user
        IBEP20Token(lpToken).transfer(msg.sender, amount_);

        // Calculate allocation based on given LP amount
        uint256 _allocation = (amount_ * lpAllocation) / 1e12; 

        // Withdraw given allocated amount
        withdraw(_allocation);

        // Emit an event
        emit PoolLP(msg.sender, 1, amount_);
    }

    /**
	 * @dev Stakes allocated amount to the staking pool
     *
     * @param amount_ amount of allocation based on staking
	 */
    function deposit(uint256 amount_) internal updateReward(msg.sender) {
        require(amount_ > 0, 'Cannot stake 0');
        
        // Increment total allocation counter by given amount
        totalSupply = totalSupply + amount_;

        // Increment allocation balance of user
        _balances[msg.sender] = _balances[msg.sender] + amount_;
        
        // Emit an event
        emit Deposited(msg.sender, amount_);
    }

    /**
	 * @dev Unstakes allocated amount from the staking pool
     *
     * @param amount_ amount of allocation based on staking
	 */
    function withdraw(uint256 amount_) internal updateReward(msg.sender) {
        require(amount_ > 0, 'Cannot withdraw 0');
        
        // Decrement total allocation counter by given amount
        totalSupply = totalSupply - amount_;

        // Decrement allocation balance of user
        _balances[msg.sender] = _balances[msg.sender] - amount_;
        
        // Emit an event
        emit Withdrawn(msg.sender, amount_);
    }
    
    /**
	 * @dev Transfers pending rewards to user
     * 
     * @param amount_ reward token amount to be harvest 
     */
    function harvest(uint256 amount_) external payable nonReentrant updateReward(msg.sender) {
        // Get reward amount
        uint256 reward = rewards[msg.sender];

        require(amount_ > 0 && amount_ <= reward, "Invalid amount");
        
        // Calculate fee
        uint256 _fee = (seedTokenFee * amount_) / 1e18;

        // Tansfer fee to owner
        payable(owner).transfer(_fee);
        
        // Remove given reward amount data of user
        rewards[msg.sender] -= amount_;

        // Emit an event
        emit RewardPaid(msg.sender, amount_);

        // Deduct harvest fee
        amount_ -= ((amount_ * harvestFee) / 100);

        // Mint reward amount to user
        ISEED(rewardsToken).mint(msg.sender, amount_);    
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
	 * @dev Notifies reward amount to be distributed into the staking pool
     *
     * @param reward_ amount of reward token to distribute
	 */
    function notifyRewardAmount(uint256 reward_) external onlyOwner updateReward(address(0)) {
        require(rewardRate > 0, 'Reward Rate is not yet set');
        
        // Check if reward period is finished or not
        if (block.timestamp >= periodFinish) {
            // Update reward duration
            rewardsDuration = uint32(reward_ / rewardRate);
        } else {
            // Calculate remaining duration
            uint256 remaining = periodFinish - block.timestamp;
            
            // Calculate leftover reward amount
            uint256 leftover = remaining * rewardRate;

            // Update reward duration
            rewardsDuration = uint32((reward_ + leftover) / rewardRate);
        }

        // Record last update time
        lastUpdateTime = uint32(block.timestamp);

        // Update finish period
        periodFinish = uint32(block.timestamp) + rewardsDuration;
        
        // Emit an event
        emit RewardAdded(reward_);
    }

    /**
	 * @dev Sets reward rate of the staking pool
     *
     * @param rewardsPerInterval_ amount of reward token to distribute for given interval
     * @param interval_ total duration of interval in seconds
	 */
    function setRewardRate(uint256 rewardsPerInterval_, uint256 interval_) external onlyOwner {
        require(rewardsPerInterval_ > 0 && interval_ > 0, 'rewardsPerInterval and interval should be greater than 0');
        
        require(block.timestamp > periodFinish, 'Previous rewards period must be complete before changing the reward rate');
        
        // Record reward rate
        rewardRate = rewardsPerInterval_ / interval_;

        // Emit an event
        emit RewardRateUpdated(rewardsPerInterval_, interval_, rewardRate);
    }

    /**
	 * @dev Reduces finish period 
     *
     * @param timestamp_ duration in seconds to reduce
     */
    function reduceFinishPeriod(uint32 timestamp_) external onlyOwner updateReward(address(0)) {
        require(timestamp_ > block.timestamp, "timestamp must be greater than current Time");
        
        require(timestamp_ < periodFinish, "timestamp must be less than periodFinish");

        // Update finish period
        periodFinish = timestamp_;
    }

    /**
	 * @dev Transfer ownership to given address
     *
	 * @param newOwner_ address of new owner
	 */
    function transferOwnership(address newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;
    
        // Emits an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /** 
    * @dev Sets locking period for nftree
    * 
    * @notice restricted access function 
    * @param lockingPeriodInSeconds_ unsigned integer defines locking period in seconds
    */
    function setLockingPeriod(uint32 lockingPeriodInSeconds_) external onlyOwner {
        // Update locking period for nftrees
        lockingPeriod = lockingPeriodInSeconds_;
    }

    /** 
    * @dev Sets locking period for lpToken
    * 
    * @notice restricted access function 
    * @param lockingPeriodInSeconds_ unsigned integer defines locking period in seconds
    */
    function setLpLockingPeriod(uint32 lockingPeriodInSeconds_) external onlyOwner {
        // Update locking period for lp tokens
        lpLockingPeriod = lockingPeriodInSeconds_;
    }

    /** 
    * @dev Sets fee paid in BNB for seed token harvest
    *
    * @notice restricted access function 
    * @param fee_ unsigned integer defines fee
    */
    function setSeedTokenFee(uint256 fee_) external onlyOwner {
        // Update seed token fee
        seedTokenFee = fee_;
    }
    
    /** 
     * @dev Sets harvest fee in terms of reward token in percentage
     *
     * @notice restricted access function 
     * @param fee_ unsigned integer defines fee
     */
    function setHarvestFee(uint8 fee_) external onlyOwner {
        require(fee_ < 100, "Invalid input");

        // Update harvest fee
        harvestFee = fee_;
    }

    /**
     * @dev Sets lp token deposit fee in percentage
     *
     * @notice restricted access function 
     * @param fee_ unsigned integer defines fee
     */
    function setLpDepositFee(uint8 fee_) external onlyOwner {
        require(fee_ < 100, "Invalid input");

        // Update lp deposit fee
        lpDepositFee = fee_;
    }

    /**
     * @dev Sets minimum nftrees needs to be staked for lp staking
     *
     * @notice restricted access function 
     * @param number_ unsigned integer defines number of nftrees to be staked
     */
    function setMinTreeStaked(uint32 number_) external onlyOwner {
        // Update minimum tree staked
        minTreeStaked = number_;
    }

    /**
	 * @dev Withdraws bep20 tokens from the staking pool
     *
     * @param contract_ address of bep20 token 
     * @param to_ address of receiver
     * @param value_ amount of given bep20 token
     */
    function rescueBep20(address contract_, address to_, uint256 value_) external onlyOwner {
		// Transfer tokens to given address
        IBEP20Token(contract_).transfer(to_, value_);
	}
    
    /**
	 * @dev Withdraws NFT from the staking pool
     *
     * @param contract_ address of NFT collection 
     * @param to_ address of receiver
     * @param tokenId_ tokenId of given NFT collection
     */
	function rescueBep721(address contract_, address to_, uint256 tokenId_) external onlyOwner {
		// Transfer nft to given address
        NFT(contract_).transferFrom(address(this), to_, tokenId_);
	}

    /* ========== MODIFIERS ========== */

    // To update reward snapshot
    modifier updateReward(address account_) {
        // Calculate and store reward per token
        rewardPerTokenStored = rewardPerToken();
        
        // Record last update time
        lastUpdateTime = lastTimeRewardApplicable();
        
        // Check if account is non-zero address
        if (account_ != address(0)) {
            // Update reward amount for given account
            rewards[account_] = earned(account_);

            // Update reward per token paid for given account
            userRewardPerTokenPaid[account_] = rewardPerTokenStored;
        }

        _;
    }

    // To check if accessed by an owner
    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    /**
     * @dev Checks if accessed by an owner
     */
    function _onlyOwner() private view {
        require(msg.sender == owner, 'Only the contract owner may perform this action');
    }

    /* ========== EVENTS ========== */

    /**
	 * @dev Fired in notifyRewardAmount()
	 *
	 * @param reward amount of reward token added
	 */
    event RewardAdded(uint256 reward);

    /**
	 * @dev Fired in deposit()
	 *
	 * @param user address of staker
     * @param amount staked amount
	 */
    event Deposited(address indexed user, uint256 amount);

    /**
	 * @dev Fired in withdraw()
	 *
	 * @param user address of staker
     * @param amount withdrawn amount
	 */
    event Withdrawn(address indexed user, uint256 amount);

    /**
	 * @dev Fired in harvest()
	 *
	 * @param user address of staker
     * @param reward amount of reward paid
	 */
    event RewardPaid(address indexed user, uint256 reward);

    /**
	 * @dev Fired in setRewardRate()
	 *
	 * @param rewardsPerInterval amount of reward token to distribute for given interval
     * @param interval total duration of interval in seconds
     * @param rewardRate reward rate of the staking pool
	 */
    event RewardRateUpdated(uint256 rewardsPerInterval, uint256 interval, uint256 rewardRate);
    
    /**
	 * @dev Fired in transferOwnership() when ownership is transferred
	 *
	 * @param previousOwner an address of previous owner
	 * @param newOwner an address of new owner
	 */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Fired in stake() and unstake()
     *
     * @param by an address of staker
     * @param status 1 = unstake, 2 = stake
     * @param tokenId Id of token that is staked/unstaked
     */
    event PoolNFT(address indexed by, uint8 status, uint256 indexed tokenId);

    /**
	 * @dev Fired in stakeLp() and unstakeLp()
	 *
	 * @param lpOwner address of LP token owner
     * @param status 1 = unstake, 2 = stake
     * @param amount staked/unstaked amount
	 */
    event PoolLP(address indexed lpOwner, uint8 status, uint256 amount);
    
}