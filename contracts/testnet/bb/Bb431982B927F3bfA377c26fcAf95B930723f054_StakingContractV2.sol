/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/StakingContractV2.sol


pragma solidity ^0.8.0;



// custom errors
error StakingFailed(address caller);
error UnstakingFailed(address caller);
error WithdrawingFailed();

contract StakingContractV2 is Ownable {
    IERC20 public sFSToken;
    address public fsTokenAddress;
    // holds the factors responsible for calculating rewards
    struct CalculationFactors {
        uint256[] lockupPeriods; // period for which token will be locked e.g. 0 is 30 days, 1 is 180 days, and so on
        uint256[] rewardFactors; // will be used to calculate reward e.g. 0 is 331 (for an APY of 3000% and locked for 30 days)
    }
    // holds information about a stake
    struct Stake {
        uint256 poolIndex; // 0 if staked for pool at index 0
        uint8 lockIndex; // 0 if locked for 30, 1 if locked for 180 days, and so on
        uint256 lockedAmount; // amount of tokens locked e.g., fs, pgk
        uint256 sFSLockedAmount; // amount of sFS locked e.g., sFS
        uint256 reward; // amount of tokens user will receive as reward
        uint256 timestamp; // time at which user staked tokens
        uint256 unstakeTimestamp; // time at which user can unstake tokens
        bool unstake; // true, if user unstaked their locked tokens
    }
    // array of stakes
    Stake[] public stakes;
    // holds information about pool
    struct Pool {
        IERC20 depositToken;
        IERC20 rewardToken;
        uint256 stakedSoFar; // token staked so far
        uint256 maxStake; // maximum amount of token that can be staked
        CalculationFactors calculationFactors; // factors that will influence reward
        bool pausePool; // will pause the pool and stop accepting new stakers
        uint256 rewardsToBePaid; // amount of rewward token that needs to be paid
    }
    // array of pools
    Pool[] public pools;

    // maps address with the pools
    mapping(address => uint256[]) public poolsOfAddress;
    // maps address with the stakes
    mapping(address => uint256[]) public stakesOfAddress;
    // maps index of stake with owner
    mapping(uint256 => address) public ownerOfIndex;
    // maps addresses with pool
    mapping(uint256 => address[]) public stakersOfPool;

    // events
    event tokenStaked(
        address indexed staker,
        uint256 indexed poolIndex,
        uint256 amountStaked,
        uint256 claimableReward,
        uint256 unstakeTimestamp
    );
    event tokenUnstaked(
        address indexed staker,
        uint256 stakeIndex,
        uint256 indexed poolIndex,
        uint256 reward
    );
    event rewardsWithdrawn(
        address indexed owner,
        uint256 indexed poolIndex,
        uint256 timestamp,
        uint256 withdrawnAmount
    );
    event poolInitialized(
        uint256 indexed poolIndex,
        address depositToken,
        address rewardToken,
        uint256 maxStake,
        uint256[] lockupPeriods,
        uint256[] rewardFactors
    );

    constructor(IERC20 _sFSToken, address _fsTokenAddress) {
        sFSToken = _sFSToken;
        fsTokenAddress = _fsTokenAddress;
        // dead stack
        stakes.push(
            Stake({
                poolIndex: 0,
                lockIndex: 0,
                lockedAmount: 0,
                sFSLockedAmount: 0,
                reward: 0,
                timestamp: block.timestamp,
                unstakeTimestamp: block.timestamp,
                unstake: true
            })
        );
    }

    /// @dev Allows owner to add new reward pool
    /// @param _depositToken deposit token contract
    /// @param _rewardToken reward token contract
    /// @param _maxStake max amount of token that can be staked in the pool
    /// @param _lockupPeriods array of lockup periods eg. 0 is 30 days, 1 is 90 days, and so on
    /// @param _rewardFactors array of reward factors eg. 0 is 3313, 1 is 13596, and so on (for APY 3000%)
    function initializePool(
        IERC20 _depositToken,
        IERC20 _rewardToken,
        uint256 _maxStake,
        uint256[] memory _lockupPeriods,
        uint256[] memory _rewardFactors
    ) public onlyOwner {
        require(
            _lockupPeriods.length == _rewardFactors.length,
            "Lockup Periods and Reward Factors must have same length!"
        );
        pools.push(
            Pool({
                depositToken: _depositToken,
                rewardToken: _rewardToken,
                stakedSoFar: 0,
                maxStake: _maxStake,
                calculationFactors: CalculationFactors({
                    lockupPeriods: _lockupPeriods,
                    rewardFactors: _rewardFactors
                }),
                pausePool: false,
                rewardsToBePaid: 0
            })
        );
        // emit event
        emit poolInitialized(
            pools.length - 1,
            address(_depositToken),
            address(_rewardToken),
            _maxStake,
            _lockupPeriods,
            _rewardFactors
        );
    }

    /// @dev Throws if pool is not valid
    modifier isValidPool(uint256 _poolIndex) {
        require(_poolIndex < pools.length, "Not a valid pool index!");
        _;
    }

    /// @dev Throws if lockup period index is not valid for the pool
    modifier isValidLockupPeriod(uint256 _poolIndex, uint8 _lockIndex) {
        require(
            _lockIndex <
                pools[_poolIndex].calculationFactors.lockupPeriods.length,
            "Doesn't match a valid lockup period!"
        );
        _;
    }

    /// @dev Throws if someone is already staking in the given pool
    modifier noOneStaked(uint256 _poolIndex) {
        require(pools[_poolIndex].stakedSoFar == 0, "Staking Started!");
        _;
    }

    /* Checks */
    /// @dev Allows user to check if user is staking in the pool
    /// @param _poolIndex index of the pool
    /// @param _user address of the user
    /// @return returns true if user is staking, else false
    function isStakingIn(uint256 _poolIndex, address _user)
        public
        view
        returns (bool)
    {
        uint256[] memory _pools = poolsOfAddress[_user];
        for (uint256 index = 0; index < _pools.length; index++) {
            if (_pools[index] == _poolIndex) {
                uint256 stakeIndex = stakesOfAddress[_user][index];
                Stake memory stake = stakes[stakeIndex];
                if (!stake.unstake) {
                    return true;
                }
            }
        }
        return false;
    }

    /// @dev Checks if tokenAddress is the address of FS token
    /// @param _tokenAddress address of the token
    /// @return returns true if tokenAddress is the address of FS token, else false
    function isFSToken(address _tokenAddress) public view returns (bool) {
        return _tokenAddress == fsTokenAddress;
    }

    /* Setters */
    /// @dev Allows owner to updates the maximum amount of tokens that can be staked for a given pool
    /// @param _poolIndex index of the pool
    /// @param _maxStake amount to which maxStake will get initialized to
    function updateMaxStake(uint256 _poolIndex, uint256 _maxStake)
        external
        onlyOwner
        isValidPool(_poolIndex)
    {
        pools[_poolIndex].maxStake = _maxStake;
    }

    /// @dev Allows owner to update the lockupPeriods and rewardFactors for the given pool
    /// @param _poolIndex index of the pool
    /// @param _lockupPeriods array of lockup periods eg. 0 is 30 days, 1 is 90 days, and so on
    /// @param _rewardFactors array of reward factors eg. 0 is 3313, 1 is 13596, and so on (for APY 3000%)
    function updateCalculationFactors(
        uint256 _poolIndex,
        uint256[] memory _lockupPeriods,
        uint256[] memory _rewardFactors
    ) public onlyOwner isValidPool(_poolIndex) noOneStaked(_poolIndex) {
        require(
            _lockupPeriods.length == _rewardFactors.length,
            "Lockup Periods and Reward Factors must have same length!"
        );
        pools[_poolIndex].calculationFactors = CalculationFactors({
            lockupPeriods: _lockupPeriods,
            rewardFactors: _rewardFactors
        });
    }

    /// @dev Allows owner to toggle pause for the given pool
    /// @param _poolIndex index of the pool
    function togglePausePoolFor(uint256 _poolIndex)
        public
        onlyOwner
        isValidPool(_poolIndex)
    {
        pools[_poolIndex].pausePool = !pools[_poolIndex].pausePool;
    }

    /* Getters */
    /// @dev Returns array of pools
    /// @return pools array of pools
    function getPools() public view returns (Pool[] memory) {
        return pools;
    }

    /// @dev Returns address of all the staker who has staked their tokens
    /// @param _poolIndex index of the pool
    /// @return stakers array of addresses
    function getStakersOf(uint256 _poolIndex)
        public
        view
        returns (address[] memory)
    {
        return stakersOfPool[_poolIndex];
    }

    /// @dev Returns stake infos for a staker
    /// @param _staker address for which stake info is returned
    /// @return _stakes stakes of the user
    function getStakesOf(address _staker) public view returns (Stake[] memory) {
        uint256[] memory _stakeIndexs = stakesOfAddress[_staker];
        Stake[] memory _stakes = new Stake[](_stakeIndexs.length);
        for (uint256 index = 0; index < _stakes.length; index++) {
            _stakes[index] = stakes[_stakeIndexs[index]];
        }
        return _stakes;
    }

    /// @dev Returns max reward token required for the given pool
    /// @param _poolIndex index of the pool
    /// @return maxReward amount of reward token that might need for the pool
    function getMaxRewards(uint256 _poolIndex)
        public
        view
        isValidPool(_poolIndex)
        returns (uint256)
    {
        uint256 maxReward = calculateReward(
            pools[_poolIndex].maxStake,
            _poolIndex,
            uint8(pools[_poolIndex].calculationFactors.rewardFactors.length - 1)
        );
        return maxReward;
    }

    /// @dev Allows user to return the index of stake in stakes for the given pool
    /// @param _poolIndex index of the pool
    /// @param _user address of the user
    /// @return stakeIndex the return variables of a contract’s function state variable
    function getStakeIndex(uint256 _poolIndex, address _user)
        public
        view
        returns (uint256)
    {
        uint256[] memory stakeIndexes = stakesOfAddress[_user];
        require(stakeIndexes.length != 0, "Haven't staked any tokens!");
        uint256[] memory _pools = poolsOfAddress[_user];
        uint256 stakeIndex;
        for (uint256 index = 0; index < _pools.length; index++) {
            if (_pools[index] == _poolIndex) {
                stakeIndex = stakeIndexes[index];
            }
        }
        return stakeIndex;
    }

    /* Business Logic */
    /// @dev Calculates and returns rewards that user can get for the given pool
    /// @param _amount amount of tokens for which rewards will be calculated
    /// @param _poolIndex amount of tokens for which rewards will be calculated
    /// @param _lockIndex index in lockupPeriods[], and rewardFactors[] eg. for 0 lockupPeriod is 30 days and rewardFactor is 3313(for APY 3000%)
    /// @return reward amount of token user can get
    function calculateReward(
        uint256 _amount,
        uint256 _poolIndex,
        uint8 _lockIndex
    )
        public
        view
        isValidPool(_poolIndex)
        isValidLockupPeriod(_poolIndex, _lockIndex)
        returns (uint256)
    {
        uint256 rewardFactor = pools[_poolIndex]
            .calculationFactors
            .rewardFactors[_lockIndex];
        return (_amount * rewardFactor) / 10000;
    }

    /// @dev Allow user to stake tokens for a selected period for the given pool
    /// @param _amount amount of token user will stake
    /// @param _poolIndex index of the pool
    /// @param _lockIndex selected period index in lockupPeriods[] eg. 0 is 30 days
    function stakeTokens(
        uint256 _amount,
        uint256 _sFSAmount,
        uint256 _poolIndex,
        uint8 _lockIndex
    )
        public
        isValidPool(_poolIndex)
        isValidLockupPeriod(_poolIndex, _lockIndex)
    {
        // checks
        require(_amount > 0, "Cannot stake 0 tokens!");
        require(!isStakingIn(_poolIndex, msg.sender), "Can't stake twice!");
        require(
            pools[_poolIndex].stakedSoFar + _amount <
                pools[_poolIndex].maxStake,
            "Staking limit reached!"
        );
        if (!isFSToken(address(pools[_poolIndex].depositToken))) {
            _sFSAmount = 0;
        }
        // calculations
        uint256 _lockingPeriod = pools[_poolIndex]
            .calculationFactors
            .lockupPeriods[_lockIndex];
        uint256 _reward = calculateReward(_amount, _poolIndex, _lockIndex);
        Stake memory stake = Stake({
            poolIndex: _poolIndex,
            lockIndex: _lockIndex,
            lockedAmount: _amount,
            sFSLockedAmount: _sFSAmount,
            reward: _reward,
            timestamp: block.timestamp,
            unstakeTimestamp: block.timestamp + _lockingPeriod * (1 days),
            unstake: false
        });
        stakersOfPool[_poolIndex].push(msg.sender);
        poolsOfAddress[msg.sender].push(_poolIndex);
        stakesOfAddress[msg.sender].push(stakes.length);
        ownerOfIndex[stakes.length] = msg.sender;
        stakes.push(stake);
        pools[_poolIndex].stakedSoFar += _amount;
        pools[_poolIndex].rewardsToBePaid += _reward;
        // transfer deposit token
        if (_sFSAmount > 0) {
            bool sFSSuccess = sFSToken.transferFrom(
                msg.sender,
                address(this),
                _sFSAmount
            );
            if (!sFSSuccess) {
                revert StakingFailed(msg.sender);
            }
        }
        bool success = pools[_poolIndex].depositToken.transferFrom(
            msg.sender,
            address(this),
            _amount - _sFSAmount
        );
        if (!success) {
            revert StakingFailed(msg.sender);
        }
        emit tokenStaked(
            msg.sender,
            _poolIndex,
            _amount,
            _reward,
            block.timestamp + _lockingPeriod * (1 days)
        );
    }

    /// @dev Allows user to unstake deposited tokens and withdraw rewards once lockup period is finished for the given pool
    /// @param _poolIndex index of the pool
    function unstakeTokens(uint256 _poolIndex) public isValidPool(_poolIndex) {
        // checks
        require(
            isStakingIn(_poolIndex, msg.sender),
            "Haven't staked any tokens!"
        );
        uint256 stakeIndex = getStakeIndex(_poolIndex, msg.sender);
        require(
            msg.sender == ownerOfIndex[stakeIndex],
            "You're not the owner of the stake!"
        );
        Stake storage _stake = stakes[stakeIndex];
        require(
            _stake.unstakeTimestamp < block.timestamp,
            "Lockup period not finished!"
        );
        // update state
        uint256 _reward = _stake.reward;
        uint256 _lockedAmount = _stake.lockedAmount;
        uint256 _sFSLockedAmount = _stake.sFSLockedAmount;
        _stake.unstake = true;
        pools[_poolIndex].rewardsToBePaid -= _reward;
        // transfer tokens
        if (_sFSLockedAmount > 0) {
            bool sFSSuccess = sFSToken.transfer(msg.sender, _sFSLockedAmount);
            if (!sFSSuccess) {
                revert UnstakingFailed(msg.sender);
            }
        }
        bool success = (pools[_poolIndex].depositToken.transfer(
            msg.sender,
            _lockedAmount - _sFSLockedAmount
        ) && pools[_poolIndex].rewardToken.transfer(msg.sender, _reward));
        if (!success) {
            revert UnstakingFailed(msg.sender);
        }
        emit tokenUnstaked(msg.sender, stakeIndex, _poolIndex, _reward);
    }

    /// @dev Allows owner to withdraw rewards by substracting rewards that needs to be paid, and pause staking
    /// @param _poolIndex index of the pool
    function withdrawRewards(uint256 _poolIndex)
        external
        onlyOwner
        isValidPool(_poolIndex)
    {
        uint256 _balance = pools[_poolIndex].rewardToken.balanceOf(
            address(this)
        ) - pools[_poolIndex].rewardsToBePaid;
        require(
            _balance > 0,
            "Balance is less or equal to rewards to be paid!"
        );
        // pause staking
        if (!pools[_poolIndex].pausePool) {
            togglePausePoolFor(_poolIndex);
        }
        // transfer
        bool success = pools[_poolIndex].rewardToken.transfer(
            msg.sender,
            _balance
        );
        if (!success) {
            revert WithdrawingFailed();
        }
        emit rewardsWithdrawn(
            msg.sender,
            _poolIndex,
            block.timestamp,
            _balance
        );
    }
}