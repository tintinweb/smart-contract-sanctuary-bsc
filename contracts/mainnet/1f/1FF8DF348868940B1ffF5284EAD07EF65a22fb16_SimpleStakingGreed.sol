// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract  SimpleStakingGreed is Ownable {

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many Staking Tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of tokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTokensPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws Staking Tokens to a pool. Here's what happens:
        //   1. The pool's `accTokensPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        address stakingToken; // Address of Staking Token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Tokens to distribute per block.
        uint256 lastRewardBlock; // Last block number that tokens distribution occurs.
        uint256 accTokensPerShare; // Accumulated tokens per share, times 1e12. See below.
        uint256 totalStaked;
    }

    address public immutable reward; // The reward ERC-20 Token.
    uint256 public totalReward;
    uint256 public rewardPerBlock; // Tokens distributed per block. Use getTokenPerBlock() to get the updated reward.

    PoolInfo[] public poolInfo; // Info of each pool.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // Info of each user that stakes Staking Tokens.
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public startBlock; // The block number when token mining starts.

    uint256 public blockRewardUpdateCycle = 1 days; // The cycle in which the rewardPerBlock gets updated.
    uint256 public blockRewardLastUpdateTime = block.timestamp; // The timestamp when the block rewardPerBlock was last updated.
    uint256 public blocksPerDay = 28750; // The estimated number of mined blocks per day.
    uint256 public blockRewardPercentage = 3; // The percentage used for rewardPerBlock calculation.

    uint256 public stakingFeeRate = 500; // FeeRate 5%

    mapping(address => bool) public addedStakingTokens; // Used for preventing Staking Tokens from being added twice in add().
    
    address public treasuryWallet;
    bool public stakingEnabled = true;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    constructor(address _rewardToken, uint256 _startBlock) {
        require(address(_rewardToken) != address(0), "_rewardToken address is invalid");
        reward = _rewardToken;
        startBlock = _startBlock == 0 ? block.number : _startBlock;        
        treasuryWallet = address(0x75f5B78015D79B2f96BD6f24F77EF22ec829D7D0);
    }

    modifier updateRewardPerBlock() {
        (uint256 blockReward, bool update) = getRewardPerBlock();
        if (update) {
            rewardPerBlock = blockReward;
            blockRewardLastUpdateTime = block.timestamp;
        }
        _;
    }

    function setTotalReward(uint256 amount) external onlyOwner {
        totalReward = amount;
        rewardPerBlock = totalReward * blockRewardPercentage / 100 / blocksPerDay;  
    }

    function addTotalReward(uint256 amount) external onlyOwner {
        totalReward += amount;
        rewardPerBlock = totalReward * blockRewardPercentage / 100 / blocksPerDay;  
    }

    function toggleStakingEnabled() external onlyOwner {
        stakingEnabled = !stakingEnabled;
    }

    function getRewardPerBlock() public view returns (uint256, bool) {
        if (block.number < startBlock) {
            return (0, false);
        }

        //uint256 poolReward = IERC20(reward).balanceOf(address(this));
        if (totalReward == 0) {
            return (0, rewardPerBlock != 0);
        }

        if (block.timestamp >= getRewardPerBlockUpdateTime() || rewardPerBlock == 0) {
            return (totalReward * (blockRewardPercentage) / (100) / (blocksPerDay), true);
        }

        return (rewardPerBlock, false);
    }

    function getRewardPerBlockUpdateTime() public view returns (uint256) {
        // if blockRewardUpdateCycle = 1 day then roundedUpdateTime = today's UTC midnight
        uint256 roundedUpdateTime = blockRewardLastUpdateTime - (blockRewardLastUpdateTime % blockRewardUpdateCycle);
        // if blockRewardUpdateCycle = 1 day then calculateRewardTime = tomorrow's UTC midnight
        uint256 calculateRewardTime = roundedUpdateTime + blockRewardUpdateCycle;
        return calculateRewardTime;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, address _stakingToken, bool _withUpdate) public onlyOwner {
        require(address(_stakingToken) != address(0), "Staking Token is invalid");
        require(!addedStakingTokens[address(_stakingToken)], "Staking Token is already added");

        require(_allocPoint >= 5 && _allocPoint <= 10, "_allocPoint is outside of range 5-10");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + (_allocPoint);
        poolInfo.push(PoolInfo({
            stakingToken : _stakingToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accTokensPerShare : 0,
            totalStaked : 0
        }));

        addedStakingTokens[address(_stakingToken)] = true;
    }

    // Update the given pool's token allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        require(_allocPoint >= 5 && _allocPoint <= 10, "_allocPoint is outside of range 5-10");

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - (poolInfo[_pid].allocPoint) + (_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // View function to see pending tokens on frontend.
    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokensPerShare = pool.accTokensPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalStaked != 0) {
            uint256 multiplier = block.number - (pool.lastRewardBlock);
            (uint256 blockReward, ) = getRewardPerBlock();
            uint256 tokenReward = multiplier * (blockReward) * (pool.allocPoint) / (totalAllocPoint);
            accTokensPerShare = accTokensPerShare + (tokenReward * (1e12) / (pool.totalStaked));
        }
        return user.amount * (accTokensPerShare) / (1e12) - (user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date when lpSupply changes
    // For every deposit/withdraw pool recalculates accumulated token value
    function updatePool(uint256 _pid) public updateRewardPerBlock {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        //uint256 lpSupply = IERC20(pool.stakingToken).balanceOf(address(this));
        if (pool.totalStaked == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = block.number - (pool.lastRewardBlock);
        uint256 tokenReward = multiplier * (rewardPerBlock) * (pool.allocPoint) / (totalAllocPoint);

        // no minting is required, the contract should have token balance pre-allocated
        // accumulated per share is stored multiplied by 10^12 to allow small 'fractional' values
        pool.accTokensPerShare = pool.accTokensPerShare + (tokenReward * (1e12) / (pool.totalStaked));
        pool.lastRewardBlock = block.number;
    }

    // Deposit Staking Tokens to Farming for token allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(stakingEnabled, "STAKING_DISABLED");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount * (pool.accTokensPerShare) / (1e12) - (user.rewardDebt);
            if (pending > 0) {
                tokenTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            IERC20(pool.stakingToken).transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount + (_amount);
            pool.totalStaked += _amount;
        }
        user.rewardDebt = user.amount * (pool.accTokensPerShare) / (1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw Staking Tokens from Farming
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Withdraw amount is greater than user amount");

        updatePool(_pid);

        uint256 pending = user.amount * (pool.accTokensPerShare) / (1e12) - (user.rewardDebt);
        
        uint amountAfterFee;
        
        if (pending > 0) {
            tokenTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            
            //add withdraw fee editable
            uint fee = _amount * (stakingFeeRate) / (1e4);
            amountAfterFee = _amount - (fee);
            IERC20(pool.stakingToken).transfer(treasuryWallet, fee);
            IERC20(pool.stakingToken).transfer(address(msg.sender), amountAfterFee);
            
            user.amount = user.amount - (_amount);
            pool.totalStaked -= _amount;
        }
        
        user.rewardDebt = user.amount * (pool.accTokensPerShare) / (1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.totalStaked -= user.amount;
        IERC20(pool.stakingToken).transfer(address(msg.sender), user.amount);
        
        user.amount = 0;
        user.rewardDebt = 0;

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    // Safe token transfer function, just in case if
    // rounding error causes pool to not have enough tokens
    function tokenTransfer(address _to, uint256 _amount) internal {
        //uint256 balance = IERC20(reward).balanceOf(address(this));
        uint256 amount = _amount > totalReward ? totalReward : _amount;
        IERC20(reward).transfer(_to, amount);
        totalReward -= amount;
    }

    function getRewardToken1APY(uint256 _pid) external view returns (uint256) {
        if(totalReward == 0) return 0;
        (uint256 blockReward, ) = getRewardPerBlock();
        uint256 rewardForYear = blockReward * blocksPerDay * 365;
        return rewardForYear / poolInfo[_pid].totalStaked;
    }

    function getRewardToken1WPY(uint256 _pid) external view returns (uint256) {
        if(totalReward == 0) return 0;
        (uint256 blockReward, ) = getRewardPerBlock();
        uint256 rewardForYear = blockReward * blocksPerDay * 7;
        return rewardForYear / poolInfo[_pid].totalStaked;
    }

    function setStakingFeeRate(uint256 _stakingFeeRate) external onlyOwner {
        require(_stakingFeeRate > 0, "Value is zero");
        stakingFeeRate = _stakingFeeRate;
    }
    
    function setBlockRewardUpdateCycle(uint256 _blockRewardUpdateCycle) external onlyOwner {
        require(_blockRewardUpdateCycle > 0, "Value is zero");
        blockRewardUpdateCycle = _blockRewardUpdateCycle;
    }

    // Just in case an adjustment is needed since mined blocks per day
    // changes constantly depending on the network
    function setBlocksPerDay(uint256 _blocksPerDay) external onlyOwner {
        require(_blocksPerDay >= 1000 && _blocksPerDay <= 40000, "Value is outside of range 1000-40000");
        blocksPerDay = _blocksPerDay;
    }

    function setBlockRewardPercentage(uint256 _blockRewardPercentage) external onlyOwner {
        require(_blockRewardPercentage >= 1 && _blockRewardPercentage <= 5, "Value is outside of range 1-5");
        blockRewardPercentage = _blockRewardPercentage;
    }
    
    //Admin function to remove tokens mistakenly sent to this address
    function transferAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    function transferTokens(address _tokenAddr) public onlyOwner {
        IERC20(_tokenAddr).transfer(owner(), IERC20(_tokenAddr).balanceOf(address(this)));
    }    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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