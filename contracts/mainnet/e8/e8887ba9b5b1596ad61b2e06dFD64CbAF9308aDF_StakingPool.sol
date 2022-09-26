/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

pragma solidity 0.8.10;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract StakingPool is Ownable {
    
    struct StakingDetails {
        uint256 stakedAt;
        uint256 tokenAmount;
        uint256 rewardedAt;
    }

    struct AccountDetails {
        uint256 totalStakedTokens;
        uint256 totalUnstakedTokens;
        uint256 totalStakeEntries;
        uint256 totalHarvestedRewards;
    }

    mapping(address => StakingDetails) public stakingDetails;
    mapping(address => AccountDetails) public accountDetails;

    struct GeneralDetails {
        uint256 totalStakedTokens;
        uint256 totalUnstakedTokens;
        uint256 totalUniqueStakers;
        uint256 totalHarvestedRewards;
    }
    GeneralDetails public generalDetails;

    IERC20 public immutable poolToken;
    address payable public poolVault;

    uint256 public rewardMultiplier;
    uint256 public rewardDivider;

    uint256 public minimumStakingAmount;
    uint256 public unstakeTaxRemovedAt;
    uint256 public unstakeTaxPercentage;

    mapping(address => bool) public isExemptFromTaxation;
    mapping(address => bool) public isBanned;

    bool public isPaused;
    bool public isEmergencyWithdrawEnabled;

    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Harvested(address indexed account, uint256 rewards);
    event Exempted(address indexed account, bool isExempt);
    event Banned(address indexed account, bool isBanned);
    event Paused(bool isPaused);
    event EmergencyWithdrawalEnabled(bool isEnabled);
    event EmergencyWithdrawn(
        address indexed account,
        uint256 tokenAmount,
        uint256 stakedAt,
        uint256 rewardedAt
    );

    modifier onlyIfNotPaused() {
        require(!isPaused, "actions are paused");
        _;
    }

    modifier onlyIfNotBanned() {
        require( !isBanned[msg.sender], "account is banned");
        _;
    }

    constructor(address token, address payable vault) {
        poolToken = IERC20(token);
        poolVault = vault;

        rewardMultiplier = 4757;
        rewardDivider = 1e12;

        minimumStakingAmount = 1e16;

        unstakeTaxRemovedAt = 10 days;
        unstakeTaxPercentage = 20;
    }

    function SetPoolAPYSettings(
        uint256 newRewardMultiplier,
        uint256 newRewardDivider) 
        external 
        onlyOwner 
    {
        rewardMultiplier = newRewardMultiplier;
        rewardDivider = newRewardDivider;
    }

    function SetMinimumStakingAmount(
        uint256 newMinimumStakingAmount) 
        external 
        onlyOwner 
    {
        minimumStakingAmount = newMinimumStakingAmount;
    }

    function SetExemptFromTaxation(
        address account, 
        bool isExempt) 
        external 
        onlyOwner 
    {
        isExemptFromTaxation[account] = isExempt;
        emit Exempted(account, isExempt);
    }

    function SetUnstakeTaxAndDuration(
        uint256 newUnstakeTaxPercentage,
        uint256 newUnstakeTaxRemovedAt) 
        external 
        onlyOwner 
    {
        unstakeTaxPercentage = newUnstakeTaxPercentage;
        unstakeTaxRemovedAt = newUnstakeTaxRemovedAt;
    }

    function setRewardVault(address payable newRewardVault) external onlyOwner {
        poolVault = newRewardVault;
    }

    function setBanned(address account, bool state) external onlyOwner {
        isBanned[account] = state;
        emit Banned(account, state);
    }

    function setPaused(bool state) external onlyOwner {
        isPaused = state;
        emit Paused(state);
    }

    function setAllowEmergencyWithdraw(bool state) external onlyOwner {
        isEmergencyWithdrawEnabled = state;
        emit EmergencyWithdrawalEnabled(state);
    }

    function stake(uint256 amount) external onlyIfNotPaused onlyIfNotBanned {
        address account = _msgSender();

        require(
            amount >= minimumStakingAmount,
            "staking amount not sufficient"
        );

        if (accountDetails[account].totalStakeEntries == 0)
            generalDetails.totalUniqueStakers++;

        uint256 rewards = calculateTokenReward(account);
        if (rewards > 0) {
            bool beforeLockPeriodEnds = block.timestamp <
                (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

            if (beforeLockPeriodEnds && !isExemptFromTaxation[account]) {
                uint256 taxAmount = (rewards * unstakeTaxPercentage) / 100;
                rewards -= taxAmount;
            }
            poolToken.transferFrom(poolVault, account, rewards);
            accountDetails[account].totalHarvestedRewards += rewards;
            emit Harvested(account, rewards);
        }

        poolToken.transferFrom(account, address(this), amount);

        stakingDetails[account].tokenAmount += amount;
        stakingDetails[account].stakedAt = block.timestamp;
        stakingDetails[account].rewardedAt = block.timestamp;
        accountDetails[account].totalStakeEntries++;
        accountDetails[account].totalStakedTokens += amount;
        generalDetails.totalStakedTokens += amount;
        emit Staked(account, amount);
    }

    function harvest() external onlyIfNotPaused onlyIfNotBanned {
        address account = _msgSender();

        uint256 rewards = calculateTokenReward(account);
        require(rewards > 0, "no rewards to harvest");

        bool beforeLockPeriodEnds = block.timestamp <
            (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

        if (beforeLockPeriodEnds && !isExemptFromTaxation[account]) {
            uint256 taxAmount = (rewards * unstakeTaxPercentage) / 100;
            rewards -= taxAmount;
        }

        poolToken.transferFrom(poolVault, account, rewards);

        stakingDetails[account].rewardedAt = block.timestamp;
        accountDetails[account].totalHarvestedRewards += rewards;
        generalDetails.totalHarvestedRewards += rewards;
        emit Harvested(account, rewards);
    }

    function unstake() external onlyIfNotPaused onlyIfNotBanned {
        address account = _msgSender();

        uint256 rewards = calculateTokenReward(account);
        if (rewards > 0) {
            bool beforeLockPeriodEnds = block.timestamp <
                (stakingDetails[account].stakedAt + unstakeTaxRemovedAt);

            if (beforeLockPeriodEnds && !isExemptFromTaxation[account]) {
                uint256 taxAmount = (rewards * unstakeTaxPercentage) / 100;
                rewards -= taxAmount;
            }
            poolToken.transferFrom(poolVault, account, rewards);
        }

        stakingDetails[account].rewardedAt = block.timestamp;
        uint256 amount = stakingDetails[account].tokenAmount;
        delete stakingDetails[account].tokenAmount;

        poolToken.transfer(account, amount);

        accountDetails[account].totalUnstakedTokens += amount;
        accountDetails[account].totalHarvestedRewards += rewards;
        generalDetails.totalHarvestedRewards += rewards;
        generalDetails.totalUnstakedTokens += amount;
        emit Unstaked(account, amount);
        emit Harvested(account, rewards);
    }

    function unstakePartial(uint256 amount)
        external
        onlyIfNotPaused
        onlyIfNotBanned
    {
        address account = _msgSender();
        uint256 stakedTokens = stakingDetails[account].tokenAmount;

        require(
            stakedTokens >= amount,
            "insufficient staked tokens"
        );

        stakingDetails[account].tokenAmount -= amount;

        poolToken.transfer(account, amount);

        accountDetails[account].totalUnstakedTokens += amount;
        generalDetails.totalUnstakedTokens += amount;
        emit Unstaked(account, amount);
    }

    function emergencyWithdraw() external {
        address account = _msgSender();

        require(
            isEmergencyWithdrawEnabled,
            "emergency withdrawal not enabled"
        );

        uint256 tokenAmount = stakingDetails[account].tokenAmount;
        require(tokenAmount > 0, "nothing to withdraw");

        delete stakingDetails[account].tokenAmount;

        if (isBanned[account]) {
            poolToken.transfer(owner(), tokenAmount);
        } else {
            poolToken.transfer(account, tokenAmount);
        }

        emit EmergencyWithdrawn(
            account,
            tokenAmount,
            stakingDetails[account].stakedAt,
            stakingDetails[account].rewardedAt
        );
    }

    function calculateTokenReward(address account)
        public
        view
        returns (uint256 reward)
    {
        uint256 rewardDuration = block.timestamp -
            stakingDetails[account].rewardedAt;

        reward =
            (stakingDetails[account].tokenAmount *
                rewardDuration *
                rewardMultiplier) /
            rewardDivider;
    }
}