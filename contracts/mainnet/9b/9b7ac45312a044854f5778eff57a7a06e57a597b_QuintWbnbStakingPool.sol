/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

pragma solidity 0.8.12;

interface IPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

abstract contract OwnershipManager {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(
            owner() == msg.sender,
            "OwnershipManager: caller is not the owner"
        );
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
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
        require(
            newOwner != address(0),
            "OwnershipManager: new owner is the zero address"
        );
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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

/**
 * @notice Quint/WBNB Staking pool enables users to stake their LP tokens,
 *         to earn % APY for providing their tokens to the staking pool.
 */
contract QuintWbnbStakingPool is OwnershipManager {
    struct StakingDetails {
        uint256 stakedAt;
        uint256 LPAmount;
        uint256 tokenAmount;
        uint256 pendingRewards;
        uint256 compoundedOrHarvestedAt;
    }
    // Tracking of internal account level staking details.
    mapping(address => StakingDetails) public stakingDetails;

    struct AccountDetails {
        uint256 totalStakedLPs;
        uint256 totalUnstakedLPs;
        uint256 totalStakeEntries;
        uint256 totalPendingRewards;
        uint256 totalHarvestedRewards;
    }
    // Tracking of global account level staking details.
    mapping(address => AccountDetails) public accountDetails;

    // Staking Pool token dependencies.
    IERC20 public immutable QUINT_TOKEN;
    IPair public immutable LIQUIDITY_PAIR;

    // Tracking of staking pool details.
    uint256 public totalStakedLPs;
    uint256 public totalUniqueStakers;
    uint256 public totalHarvestedRewards;
    uint256 public totalPendingRewards;
    uint256 public totalUnstakedLPs;

    // Staking pool % APY configurations.
    uint256 public rewardMultiplier = 1048;
    uint256 public rewardDivider = 1e12;

    // Staking pool account requirements.
    uint256 public minimumStakingAmount = 1e16;

    // Staking pool taxation settings.
    uint256 public unstakeTaxRemovedAt = 15 days;
    uint256 public unstakeTaxPercentage = 20;

    // Staking pool reward provisioning distributor endpoint.
    address payable public rewardVault;

    // Staking pool events to log core functionality.
    event Staked(address indexed staker, uint256 amount, uint256 rewards);
    event Unstaked(address indexed staker, uint256 amount, uint256 rewards);
    event Compounded(address indexed staker, uint256 rewards);
    event Harvested(address indexed staker, uint256 rewards);

    /**
     * @dev Initialize contract by deploying a staking pool and setting
     *      up external dependencies.
     *
     * @param initialOwner --> The manager of access restricted functionality.
     * @param rewardToken --> The token that will be rewarded for staking in the pool.
     * @param liquidityPair --> The LP token that must be staked in the pool to earn rewards.
     * @param distributor --> The reward distribution endpoint that will do reward provisioning.
     */
    constructor(
        address payable initialOwner,
        address rewardToken,
        address liquidityPair,
        address payable distributor
    ) OwnershipManager(initialOwner) {
        QUINT_TOKEN = IERC20(rewardToken);
        LIQUIDITY_PAIR = IPair(liquidityPair);
        rewardVault = distributor;
    }

    /**
     * @notice Set the staking pool APY configurations, the reward multiplier and
     *         reward divider forms the % APY rewarded from the staking pool.
     *
     * @param newRewardMultiplier --> The multiplier used for reward calculations.
     * @param newRewardDivider --> The divider used for reward calculations.
     */
    function SetPoolAPYSettings(
        uint256 newRewardMultiplier,
        uint256 newRewardDivider
    ) external onlyOwner {
        rewardMultiplier = newRewardMultiplier;
        rewardDivider = newRewardDivider;
    }

    /**
     * @notice Set the minimum LP token staking requirement,
     *         the account must comply with the minimum to stake.
     *
     * @param newMinimumStakingAmount --> The minimum LP token amount for entry.
     */
    function SetMinimumStakingAmount(uint256 newMinimumStakingAmount)
        external
        onlyOwner
    {
        minimumStakingAmount = newMinimumStakingAmount;
    }

    /**
     * @notice Set the staking pool taxation settings, the staking pool
     *         punishes premature withdrawal from the staking pool.
     *
     * @param newUnstakeTaxPercentage --> The new taxation percentage from unstaking.
     * @param newUnstakeTaxRemovedAt --> The new duration for taxation of rewards.
     */
    function SetUnstakeTaxAndDuration(
        uint256 newUnstakeTaxPercentage,
        uint256 newUnstakeTaxRemovedAt
    ) external onlyOwner {
        unstakeTaxPercentage = newUnstakeTaxPercentage;
        unstakeTaxRemovedAt = newUnstakeTaxRemovedAt;
    }

    /**
     * @notice Set the reward provisioning endpoint,
     *         this should be the distributor that handle rewards.
     *
     * @param newRewardVault --> The new distributor for reward provisioning.
     */
    function setRewardVault(address payable newRewardVault) external onlyOwner {
        rewardVault = newRewardVault;
    }

    /**
     * @notice Stake LP tokens to accumulate token rewards,
     *         token reward accumulation is based on the % APY.
     *
     * @param amount --> The amount of LP tokens that the account wish,
     *         to stake in the staking pool.
     */
    function stake(uint256 amount) external {
        address account = msg.sender;

        // Check that the staked amount complies with the minimum staking requirement.
        require(
            amount >= minimumStakingAmount,
            "QuintWBNBStakingPool: staking amount not sufficient"
        );

        // Check if the account is unique, if yes then add it to global tracking.
        if (accountDetails[account].totalStakeEntries == 0)
            totalUniqueStakers++;

        // Transfer the staked amount of LP tokens to the staking pool.
        LIQUIDITY_PAIR.transferFrom(account, address(this), amount);

        // Check if the account has any unsettled rewards from previous entries,
        // if yes, then transfer the unsettled rewards to the account.
        uint256 unsettledRewards = calculateLPReward(account);
        if (unsettledRewards > 0)
            QUINT_TOKEN.transferFrom(
                rewardVault,
                address(this),
                unsettledRewards
            );

        // Update internal account staking details.
        stakingDetails[account].LPAmount += amount;
        stakingDetails[account].tokenAmount += getTokenForLP(amount);
        stakingDetails[account].pendingRewards += unsettledRewards;
        stakingDetails[account].stakedAt = block.timestamp;
        stakingDetails[account].compoundedOrHarvestedAt = block.timestamp;

        // Update global account staking details.
        accountDetails[account].totalStakeEntries++;
        accountDetails[account].totalStakedLPs += amount;
        accountDetails[account].totalPendingRewards += unsettledRewards;

        // Update global staking pool details.
        totalUniqueStakers++;
        totalStakedLPs += amount;
        totalPendingRewards += unsettledRewards;

        // Log successful activity.
        emit Staked(account, amount, unsettledRewards);
    }

    /**
     * @notice Compound unsettled rewards to increase staking position,
     *         unsettled rewards are transformed into pendingRewards.
     */
    function compound() external {
        address account = msg.sender;

        // Check if the account has any unsettled rewards from previous entries,
        // the unsettled rewards must be larger than zero to compound. If yes,
        // then compound the unsettled rewards to the staking position.
        uint256 unsettledRewards = calculateLPReward(account);
        require(
            unsettledRewards != 0,
            "QuintWBNBStakingPool: no rewards to compound"
        );
        QUINT_TOKEN.transferFrom(rewardVault, address(this), unsettledRewards);

        // Update internal account staking details.
        stakingDetails[account].tokenAmount += unsettledRewards;
        stakingDetails[account].pendingRewards += unsettledRewards;
        stakingDetails[account].compoundedOrHarvestedAt = block.timestamp;

        // Update global account staking details.
        accountDetails[account].totalPendingRewards += unsettledRewards;

        // Update global staking pool details.
        totalPendingRewards += unsettledRewards;

        // Log successful activity.
        emit Compounded(account, unsettledRewards);
    }

    /**
     * @notice Harvest available rewards from staking in the staking pool,
     *         the rewards are transferred to the staking account.
     */
    function harvest() external {
        address account = msg.sender;

        // Check if the account has any available rewards from previous entries,
        // the available rewards must be larger than zero to harvest. If yes,
        // then harvest the available rewards by transferring to account.
        uint256 unsettledRewards = calculateLPReward(account);

        uint256 pendingRewards = stakingDetails[account].pendingRewards;
        delete stakingDetails[account].pendingRewards;

        require(
            unsettledRewards + pendingRewards > 0,
            "QuintWBNBStakingPool: no rewards to harvest"
        );

        bool earlyUnstaker = block.timestamp <
            (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

        if (unsettledRewards > 0) {
            if (earlyUnstaker) {
                uint256 taxAmount = (unsettledRewards * unstakeTaxPercentage) /
                    100;
                unsettledRewards -= taxAmount;
            }
            QUINT_TOKEN.transferFrom(rewardVault, account, unsettledRewards);
        }

        if (pendingRewards > 0) {
            if (earlyUnstaker) {
                uint256 taxAmount = (pendingRewards * unstakeTaxPercentage) /
                    100;
                pendingRewards -= taxAmount;
            }
            QUINT_TOKEN.transfer(account, pendingRewards);
        }

        // Update internal account staking details.
        stakingDetails[account].compoundedOrHarvestedAt = block.timestamp;

        // Update global staking pool details.
        uint256 availableRewards = unsettledRewards + pendingRewards;
        totalHarvestedRewards += availableRewards;

        // Log successful activity.
        emit Harvested(account, availableRewards);
    }

    /**
     * @notice Unstake LP tokens to withdraw your position from the staking pools,
     *         available rewards are transferred to the staking account.
     */
    function unstake() external {
        address account = msg.sender;
        uint256 amount = stakingDetails[account].LPAmount;
        delete stakingDetails[account].LPAmount;

        bool earlyUnstaker = block.timestamp <
            (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

        // Check if the account has any available rewards from previous entries,
        // the available rewards must be larger than zero to harvest. If yes,
        // then auto harvest the available rewards by transferring to account.
        uint256 unsettledRewards = calculateLPReward(account);
        if (unsettledRewards > 0) {
            if (earlyUnstaker) {
                uint256 taxAmount = (unsettledRewards * unstakeTaxPercentage) /
                    100;
                unsettledRewards -= taxAmount;
            }
            QUINT_TOKEN.transferFrom(rewardVault, account, unsettledRewards);
        }

        uint256 pendingRewards = stakingDetails[account].pendingRewards;
        delete stakingDetails[account].pendingRewards;

        if (pendingRewards > 0) {
            if (earlyUnstaker) {
                uint256 taxAmount = (pendingRewards * unstakeTaxPercentage) /
                    100;
                pendingRewards -= taxAmount;
            }
            // Reward any accumulated token rewards to staked account
            QUINT_TOKEN.transfer(account, pendingRewards);
        }

        // Update internal account staking details.
        stakingDetails[account].compoundedOrHarvestedAt = block.timestamp;

        delete stakingDetails[account].tokenAmount;

        // Transfer the staked amount of LP tokens back to the account.
        LIQUIDITY_PAIR.transfer(account, amount);

        // Update global account staking details.
        accountDetails[account].totalUnstakedLPs += amount;
        uint256 availableRewards = unsettledRewards + pendingRewards;
        accountDetails[account].totalHarvestedRewards += availableRewards;

        // Update global staking pool details.
        totalHarvestedRewards += availableRewards;
        totalUnstakedLPs += amount;

        // Log successful activity.
        emit Unstaked(account, amount, availableRewards);
        emit Harvested(account, availableRewards);
    }

    /**
     * @notice Unstake partial amount of LP tokens from the staking pools,
     *         available rewards are transferred to the staking account.
     *
     * @param amount --> The amount of LP tokens that the account wish to
     *         withdraw from the staking pool.
     */
    function unstakePartial(uint256 amount) external {
        address account = msg.sender;
        uint256 stakedLPs = stakingDetails[account].LPAmount;

        // Check if the staking position is larger than the unstaked amount.
        require(
            stakedLPs >= amount,
            "QuintWBNBStakingPool: insuffiscient staked LP tokens"
        );

        stakingDetails[account].LPAmount -= amount;

        bool earlyUnstaker = block.timestamp <
            (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

        // Check if the account has any available rewards from previous entries,
        // the available rewards must be larger than zero to harvest. If yes,
        // then auto harvest the available rewards by transferring to account.
        uint256 unsettledRewards = calculateLPReward(account);
        if (unsettledRewards > 0) {
            if (earlyUnstaker) {
                uint256 taxAmount = (unsettledRewards * unstakeTaxPercentage) /
                    100;
                unsettledRewards -= taxAmount;
            }
            QUINT_TOKEN.transferFrom(rewardVault, account, unsettledRewards);
        }

        uint256 pendingRewards = stakingDetails[account].pendingRewards;
        delete stakingDetails[account].pendingRewards;

        if (pendingRewards > 0) {
            // Reward any accumulated token rewards to staked account
            if (earlyUnstaker) {
                uint256 taxAmount = (pendingRewards * unstakeTaxPercentage) /
                    100;
                pendingRewards -= taxAmount;
            }
            QUINT_TOKEN.transfer(account, pendingRewards);
        }

        // Update internal account staking details.
        stakingDetails[account].compoundedOrHarvestedAt = block.timestamp;

        // Transfer the partial amount of staked LP tokens back to the account.
        LIQUIDITY_PAIR.transfer(account, amount);

        // Update global account staking details.
        accountDetails[account].totalUnstakedLPs += amount;
        uint256 availableRewards = unsettledRewards + pendingRewards;
        accountDetails[account].totalHarvestedRewards += availableRewards;

        // Update global staking pool details.
        totalHarvestedRewards += availableRewards;
        totalUnstakedLPs += amount;

        // Log successful activity.
        emit Unstaked(account, amount, availableRewards);
        emit Harvested(account, availableRewards);
    }

    /**
     * @notice Calculate the unsettled rewards for an account from staking
     *         in the pool, rewards that has not been compounded yet.
     *
     * @param account --> The account to use for reward calculation.
     */
    function calculateLPReward(address account)
        public
        view
        returns (uint256 reward)
    {
        // Calculate the staking duration of an account.
        uint256 rewardDuration = block.timestamp -
            stakingDetails[account].compoundedOrHarvestedAt;
        // Calculate the reward rate of an account.
        reward =
            (stakingDetails[account].tokenAmount *
                rewardDuration *
                rewardMultiplier) /
            rewardDivider;
    }

    /**
     * @notice Fetch the token to LP tokens proportionality based on,
     *         a specific LP tokens amount.
     *
     * @param LPAmount --> The LP token amount to calculate based on.
     *
     * @return The proportionality based on LP token amount.
     */
    function getTokenForLP(uint256 LPAmount) public view returns (uint256) {
        uint256 LPSupply = LIQUIDITY_PAIR.totalSupply();
        uint256 totalReserve = getTokenReserve() * 2;

        // Calculate the proportionality of LP amount.
        return (totalReserve * LPAmount) / LPSupply;
    }

    /**
     * @notice Fetch the token side of the reserve in the LP pair.
     *
     * @return The token side of the reserve in the LP pair.
     */
    function getTokenReserve() public view returns (uint256) {
        (uint256 token0Reserve, uint256 token1Reserve, ) = LIQUIDITY_PAIR
            .getReserves();

        if (LIQUIDITY_PAIR.token0() == address(QUINT_TOKEN)) {
            return token0Reserve;
        }
        return token1Reserve;
    }
}