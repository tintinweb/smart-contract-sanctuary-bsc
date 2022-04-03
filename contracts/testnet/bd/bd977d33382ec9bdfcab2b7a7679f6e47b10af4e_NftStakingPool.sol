/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT

// TODO: Unit testing
// TODO: Add soldoc

pragma solidity ^0.8.0;

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

    function balanceOf(address account) external view returns (uint256);
}

interface NFT {
    // transfer NFT
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
  
    function ownerOf(uint256 tokenId) external view returns (address);
}

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

library Math {
    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint32 a, uint32 b) internal pure returns (uint32) {
        return a < b ? a : b;
    }
}

contract NftStakingPool is ReentrancyGuard {
    
    /* ========== STATE VARIABLES ========== */

    address public owner;
    uint32 public nextId;
    uint32 public periodFinish;
    uint32 public rewardsDuration;
    uint32 public lastUpdateTime;
    address public immutable rewardsToken;
    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    uint256 public totalSupply;

    struct NftBinding {
        address ownerOfNft;
		address targetContract;
		uint256 targetId;
        uint256 stakedOn;
        uint256 stakedAmount;
	}

    struct Whitelist {
        bool isWhitelisted;
        uint256 stakingFee;
        uint256 lockingPeriod;
        uint256 allocation;
    }

    struct LpBinding {
        uint256 balance;
        uint256 stakedOn;
    }

    struct LpWhitelist {
        bool isWhitelisted;
        uint256 lockingPeriod;
        uint256 allocation;
        uint256 timeDiscount;
    }
    
    mapping(uint32 => NftBinding) public bindings;
    mapping(address => mapping(uint256 => uint32)) public reverseBindings;
    mapping(address => mapping(uint256 => uint256)) public bonus;
    mapping(address => Whitelist) public collection;
    mapping(address => LpWhitelist) public lpTokens;
    mapping(address => mapping(address => LpBinding)) public lpBalances;

    mapping(address => uint256) private userRewardPerTokenPaid;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private _balances;
    
    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _owner,
        address _rewardsToken,
        uint32 _nextId
    ) {
        require(_nextId > 0, "Invalid input");

        owner = _owner;
        rewardsToken = _rewardsToken;
        nextId = _nextId;
    }

    /* ========== VIEWS ========== */

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint32) {
        return Math.min(uint32(block.timestamp), periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime * rewardRate * 1e18 / totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
    }

    function calculateAllocation(address targetContract_, uint256 targetId_) public view returns (uint256) {
        return collection[targetContract_].allocation + bonus[targetContract_][targetId_];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeNft(address targetContract_, uint256 targetId_) external nonReentrant {
        
        address _owner = NFT(targetContract_).ownerOf(targetId_);

		require(_owner != address(0) && _owner == msg.sender, "Invalid access");

        require(collection[targetContract_].isWhitelisted, "Not whitelisted");

        payable(owner).transfer(collection[targetContract_].stakingFee);

        NFT(targetContract_).transferFrom(msg.sender, address(this), targetId_);

        uint256 _amount = calculateAllocation(targetContract_, targetId_);

        stake(_amount);

        bindings[nextId] = NftBinding({
			ownerOfNft : _owner,
			targetContract : targetContract_,
			targetId : targetId_,
            stakedOn : block.timestamp,
            stakedAmount : _amount 
		});

        reverseBindings[targetContract_][targetId_] = nextId;

        nextId++;

        emit PoolNFT(msg.sender, nextId, 2, targetContract_, targetId_, _amount);
    }

    function unstakeNft(address targetContract_, uint256 targetId_) external nonReentrant {
        
        uint32 _nextId = reverseBindings[targetContract_][targetId_];

        address _owner = bindings[_nextId].ownerOfNft;

		require(_owner != address(0) && _owner == msg.sender, "Invalid access");

        uint256 _lockingPeriod = collection[targetContract_].lockingPeriod;

        require(
            block.timestamp > bindings[_nextId].stakedOn + _lockingPeriod,
            "Locking period is not over"
        );

        uint256 _amount = bindings[_nextId].stakedAmount; 
        
        withdraw(_amount);

        delete bindings[_nextId];

        delete reverseBindings[targetContract_][targetId_];

        NFT(targetContract_).transferFrom(address(this), msg.sender, targetId_);

        emit PoolNFT(msg.sender, _nextId, 1, targetContract_, targetId_, _amount);
    }

    function stakeLp(address lpToken_, uint256 amount_) external nonReentrant {
        require(lpTokens[lpToken_].isWhitelisted, "Not whitelisted");

        IBEP20Token(lpToken_).transferFrom(msg.sender, address(this), amount_);

        lpBalances[msg.sender][lpToken_].balance += amount_;

        lpBalances[msg.sender][lpToken_].stakedOn = block.timestamp;

        emit PoolLP(msg.sender, 2, lpToken_, amount_);
    }

    function unstakeLp(address lpToken_, uint256 amount_) external nonReentrant {
        
        uint256 _lockingPeriod = lpTokens[lpToken_].lockingPeriod;

        require(amount_ <= lpBalances[msg.sender][lpToken_].balance, "Invalid amount");

        require(
            block.timestamp > lpBalances[msg.sender][lpToken_].stakedOn + _lockingPeriod,
            "Locking period is not over"
        );

        lpBalances[msg.sender][lpToken_].balance -= amount_;        

        IBEP20Token(lpToken_).transfer(msg.sender, amount_);

        emit PoolLP(msg.sender, 1, lpToken_, amount_);
    }
    
    function boost(
        address targetContract_,
        uint256 targetId_,
        address lpToken_,
        uint8 option_,
        uint8 amount_
    ) external {
        uint32 _nextId = reverseBindings[targetContract_][targetId_];

        address _owner = bindings[_nextId].ownerOfNft;

		require(_owner != address(0) && _owner == msg.sender, "Invalid access");

        require(amount_ <= lpBalances[msg.sender][lpToken_].balance, "Invalid amount");

        lpBalances[msg.sender][lpToken_].balance -= amount_;

        if(option_ == 1) {
            
            uint256 _allocation = (amount_ * lpTokens[lpToken_].allocation) / 1e18;

            stake(_allocation);

            bindings[_nextId].stakedAmount += _allocation;

            emit Boosted(msg.sender, _nextId, 1, lpToken_, amount_, _allocation);

        } else if(option_ == 2) {

            uint256 _discount = (amount_ * lpTokens[lpToken_].timeDiscount) / 1e18;

            bindings[_nextId].stakedOn -= _discount;

            emit Boosted(msg.sender, _nextId, 2, lpToken_, amount_, _discount);   
        }
    }

    function stake(uint256 amount) internal updateReward(msg.sender) {
        require(amount > 0, 'Cannot stake 0');
        totalSupply = totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) internal updateReward(msg.sender) {
        require(amount > 0, 'Cannot withdraw 0');
        totalSupply = totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IBEP20Token(rewardsToken).transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {
        require(rewardRate > 0, 'Reward Rate is not yet set');
        if (block.timestamp >= periodFinish) {
            rewardsDuration = uint32(reward / rewardRate);
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardsDuration = uint32(reward + leftover / rewardRate);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = IBEP20Token(rewardsToken).balanceOf(address(this));
        require(rewardRate <= balance / rewardsDuration, 'Provided reward too high');

        lastUpdateTime = uint32(block.timestamp);
        periodFinish = uint32(block.timestamp + rewardsDuration);
        emit RewardAdded(reward);
    }

    function setRewardRate(uint256 rewardsPerInterval, uint256 interval) external onlyOwner {
        require(rewardsPerInterval > 0 && interval > 0, 'rewardsPerInterval and interval should be greater than 0');
        require(block.timestamp > periodFinish, 'Previous rewards period must be complete before changing the reward rate');
        rewardRate = rewardsPerInterval / interval;

        emit RewardRateUpdated(rewardsPerInterval, interval, rewardRate);
    }

    function transferOwnership(address newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;
    
        // Emits an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    function manageCollection(
        address nftContract_,
        bool whitelisted_,
        uint256 stakingFee_,
        uint256 lockingPeriod_,
        uint256 baseAllocation_
    ) external onlyOwner {
        require(nftContract_ != address(0), "Invalid input");
        
        collection[nftContract_] = Whitelist({
			isWhitelisted : whitelisted_,
			stakingFee : stakingFee_,
			lockingPeriod : lockingPeriod_,
            allocation : baseAllocation_
		});

        emit CollectionUpdate(nftContract_, whitelisted_, stakingFee_, lockingPeriod_, baseAllocation_);
    }
    
    function manageBonus(
        address targetContract_,
        uint256[] memory targetId_,
        uint256[] memory bonus_
    ) external onlyOwner {
        require(targetId_.length == bonus_.length, "Invalid inputs");

        for(uint8 i; i < bonus_.length; i++) {
            bonus[targetContract_][targetId_[i]] = bonus_[i];

            emit BonusUpdate(targetContract_, targetId_[i], bonus_[i]);
        }
    }

    function manageLpToken(
        address lpToken_,
        bool whitelisted_,
        uint256 lockingPeriod_,
        uint256 allocation_,
        uint256 timeDiscount_
    ) external onlyOwner {
        require(lpToken_ != address(0), "Invalid input");
        
        lpTokens[lpToken_] = LpWhitelist({
			isWhitelisted : whitelisted_,
			lockingPeriod : lockingPeriod_,
            allocation : allocation_,
            timeDiscount : timeDiscount_
		});

        emit LpUpdate(lpToken_, whitelisted_, lockingPeriod_, allocation_, timeDiscount_);
    }

    function rescueBep20(address _contract, address _to, uint256 _value) public onlyOwner {
		IBEP20Token(_contract).transfer(_to, _value);
	}

	function rescueBep721(address _contract, address _to, uint256 _tokenId) public onlyOwner {
		NFT(_contract).transferFrom(address(this), _to, _tokenId);
	}

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function transferRewardToken() external onlyOwner {
        IBEP20Token(rewardsToken).transfer(owner, IBEP20Token(rewardsToken).balanceOf(address(this)));
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, 'Only the contract owner may perform this action');
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 rewardsPerInterval, uint256 interval, uint256 rewardRate);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CollectionUpdate(address indexed nftContract, bool whitelisted, uint256 stakingFee, uint256 lockingPeriod, uint256 baseAllocation_);
    event BonusUpdate(address indexed targetContract, uint256 targetId, uint256 bonus);
    event LpUpdate(address indexed lpToken, bool whitelisted, uint256 lockingPeriod, uint256 allocation, uint256 timeDiscount);
    event PoolNFT(address indexed nftOwner, uint32 nextId, uint8 status, address targetContract, uint256 targetId, uint256 amount);
    event PoolLP(address indexed lpOwner, uint8 status, address lpToken, uint256 amount);
    event Boosted(address indexed user, uint32 nextId, uint8 option, address lpToken, uint256 amount, uint256 benefit);
}