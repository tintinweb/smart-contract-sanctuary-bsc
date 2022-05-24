// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseBananaMaximizerStrategy.sol";
import "../libs/IVaultApe.sol";
import "../libs/IBananaVault.sol";
import "../libs/IMasterApe.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IStrategyMaximizerMasterApe.sol";
import "../libs/IMaximizerVaultApe.sol";

/// @title Strategy Maximizer - MasterApe
/// @author ApeSwapFinance
/// @notice MasterApe strategy for maximizer vaults
contract StrategyMaximizerMasterApe is BaseBananaMaximizerStrategy {
    using SafeERC20 for IERC20;

    // Farm info
    IMasterApe public immutable STAKE_TOKEN_FARM;
    uint256 public immutable FARM_PID;
    bool public immutable IS_BANANA_STAKING;

    constructor(
        address _masterApe,
        uint256 _farmPid,
        bool _isBananaStaking,
        address _stakedToken,
        address _farmRewardToken,
        address _bananaVault,
        address _router,
        address[] memory _pathToBanana,
        address[] memory _pathToWbnb,
        address[] memory _addresses //[_owner, _vaultApe]
    )
        BaseBananaMaximizerStrategy(
            _stakedToken,
            _farmRewardToken,
            _bananaVault,
            _router,
            _pathToBanana,
            _pathToWbnb,
            _addresses
        )
    {
        STAKE_TOKEN_FARM = IMasterApe(_masterApe);
        FARM_PID = _farmPid;
        IS_BANANA_STAKING = _isBananaStaking;
    }

    /// @notice total staked tokens of vault in farm
    /// @return total staked tokens of vault in farm
    function totalStake() public view override returns (uint256) {
        (uint256 amount, ) = STAKE_TOKEN_FARM.userInfo(FARM_PID, address(this));
        return amount;
    }

    /// @notice Handle deposits for this strategy
    /// @param _amount Amount to deposit
    function _vaultDeposit(uint256 _amount) internal override {
        _approveTokenIfNeeded(STAKE_TOKEN, _amount, address(STAKE_TOKEN_FARM));
        if (IS_BANANA_STAKING) {
            STAKE_TOKEN_FARM.enterStaking(_amount);
        } else {
            STAKE_TOKEN_FARM.deposit(FARM_PID, _amount);
        }
    }

    /// @notice Handle withdraw of this strategy
    /// @param _amount Amount to remove from staking
    function _vaultWithdraw(uint256 _amount) internal override {
        if (IS_BANANA_STAKING) {
            STAKE_TOKEN_FARM.leaveStaking(_amount);
        } else {
            STAKE_TOKEN_FARM.withdraw(FARM_PID, _amount);
        }
    }

    /// @notice Handle harvesting of this strategy
    function _vaultHarvest() internal override {
        if (IS_BANANA_STAKING) {
            STAKE_TOKEN_FARM.enterStaking(0);
        } else {
            STAKE_TOKEN_FARM.deposit(FARM_PID, 0);
        }
    }

    /// @notice Using total rewards as the input, find the output based on the path provided
    /// @param _path Array of token addresses which compose the path from index 0 to n
    /// @return Reward output amount based on path
    function _getExpectedOutput(address[] memory _path)
        internal
        view
        override
        returns (uint256)
    {
        uint256 rewards = _rewardTokenBalance() +
            (STAKE_TOKEN_FARM.pendingCake(FARM_PID, address(this)));

        if (_path.length <= 1 || rewards == 0) {
            return rewards;
        } else {
            uint256[] memory amounts = router.getAmountsOut(rewards, _path);
            return amounts[amounts.length - 1];
        }
    }

    /// @notice Handle emergency withdraw of this strategy without caring about rewards. EMERGENCY ONLY.
    function emergencyVaultWithdraw() public override onlyVaultApe {
        STAKE_TOKEN_FARM.emergencyWithdraw(FARM_PID);
    }

    function _beforeDeposit(address _to) internal override {}

    function _beforeWithdraw(address _to) internal override {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../libs/IVaultApe.sol";
import "../libs/IBananaVault.sol";
import "../libs/IMasterApe.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IStrategyMaximizerMasterApe.sol";
import "../libs/IMaximizerVaultApe.sol";

/// @title Base BANANA Maximizer Strategy
/// @author ApeSwapFinance
/// @notice MasterApe strategy for maximizer vaults
abstract contract BaseBananaMaximizerStrategy is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        // How many assets the user has provided.
        uint256 stake;
        // How many staked $BANANA user had at his last action
        uint256 autoBananaShares;
        // Banana shares not entitled to the user
        uint256 rewardDebt;
        // Timestamp of last user deposit
        uint256 lastDepositedTime;
    }

    struct UseDefaultSettings {
        bool treasury;
        bool keeperFee;
        bool platform;
        bool platformFee;
        bool buyBackRate;
        bool withdrawFee;
        bool withdrawFeePeriod;
        bool withdrawRewardsFee;
    }

    IMaximizerVaultApe.Settings public strategySettings;

    UseDefaultSettings public useDefaultSettings =
        UseDefaultSettings(true, true, true, true, true, true, true, true);

    // Addresses
    address public immutable WBNB;
    IERC20 public immutable BANANA;
    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    // Runtime data
    mapping(address => UserInfo) public userInfo; // Info of users
    uint256 public accSharesPerStakedToken; // Accumulated BANANA_VAULT shares per staked token, times 1e18.
    uint256 private unallocatedShares;

    // Vault info
    address public immutable STAKE_TOKEN_ADDRESS;
    IERC20 public immutable STAKE_TOKEN;
    IERC20 public immutable FARM_REWARD_TOKEN;
    IBananaVault public immutable BANANA_VAULT;

    // Settings
    IUniRouter02 public immutable router;
    address[] public pathToBanana; // Path from staked token to BANANA
    address[] public pathToWbnb; // Path from staked token to WBNB

    IMaximizerVaultApe public immutable vaultApe;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, uint256 withdrawFee);
    event ClaimRewards(address indexed user, uint256 shares, uint256 amount);

    // Setting updates
    event SetPathToBanana(address[] oldPath, address[] newPath);
    event SetPathToWbnb(address[] oldPath, address[] newPath);
    event SetTreasury(
        address oldTreasury,
        address newTreasury,
        bool useDefaultFee
    );
    event SetPlatform(
        address oldPlatform,
        address newPlatform,
        bool useDefaultFee
    );
    event SetBuyBackRate(
        uint256 oldBuyBackRate,
        uint256 newBuyBackRate,
        bool useDefaultFee
    );
    event SetKeeperFee(
        uint256 oldKeeperFee,
        uint256 newKeeperFee,
        bool useDefaultFee
    );
    event SetPlatformFee(
        uint256 oldPlatformFee,
        uint256 newPlatformFee,
        bool useDefaultFee
    );
    event SetWithdrawRewardsFee(
        uint256 oldWithdrawRewardsFee,
        uint256 newWithdrawRewardsFee,
        bool useDefaultFee
    );
    event SetWithdrawFee(
        uint256 oldEarlyWithdrawFee,
        uint256 newEarlyWithdrawFee,
        bool useDefaultFee
    );

    function totalStake() public view virtual returns (uint256);

    function emergencyVaultWithdraw() public virtual;

    function _vaultDeposit(uint256 _amount) internal virtual;

    function _vaultWithdraw(uint256 _amount) internal virtual;

    function _vaultHarvest() internal virtual;

    function _beforeDeposit(address _from) internal virtual;

    function _beforeWithdraw(address _from) internal virtual;

    function _getExpectedOutput(address[] memory _path)
        internal
        view
        virtual
        returns (uint256);

    constructor(
        address _stakeToken,
        address _farmRewardToken,
        address _bananaVault,
        address _router,
        address[] memory _pathToBanana,
        address[] memory _pathToWbnb,
        address[] memory _addresses //[_owner, _vaultApe]
    ) {
        require(
            _stakeToken != address(0),
            "BaseBananaMaximizerStrategy: Cant be zero address"
        );
        require(
            _farmRewardToken != address(0),
            "BaseBananaMaximizerStrategy: Cant be zero address"
        );
        require(
            _bananaVault != address(0),
            "BaseBananaMaximizerStrategy: Cant be zero address"
        );
        require(
            _router != address(0),
            "BaseBananaMaximizerStrategy: Cant be zero address"
        );

        IBananaVault bananaVault = IBananaVault(_bananaVault);
        address bananaTokenAddress = bananaVault.bananaToken();
        IUniRouter02 uniRouter = IUniRouter02(_router);
        address wbnbAddress = uniRouter.WETH();
        require(
            _pathToBanana[0] == address(_farmRewardToken) &&
                _pathToBanana[_pathToBanana.length - 1] == bananaTokenAddress,
            "BaseBananaMaximizerStrategy: Incorrect path to BANANA"
        );

        require(
            _pathToWbnb[0] == address(_farmRewardToken) &&
                _pathToWbnb[_pathToWbnb.length - 1] == wbnbAddress,
            "BaseBananaMaximizerStrategy: Incorrect path to WBNB"
        );

        STAKE_TOKEN = IERC20(_stakeToken);
        STAKE_TOKEN_ADDRESS = _stakeToken;
        FARM_REWARD_TOKEN = IERC20(_farmRewardToken);
        BANANA_VAULT = bananaVault;
        BANANA = IERC20(bananaTokenAddress);
        WBNB = wbnbAddress;

        router = uniRouter;
        pathToBanana = _pathToBanana;
        pathToWbnb = _pathToWbnb;

        _transferOwnership(_addresses[0]);
        vaultApe = IMaximizerVaultApe(_addresses[1]);
        // Can't access immutable variables in constructor
        strategySettings = IMaximizerVaultApe(_addresses[1]).getSettings();
    }

    /**
     * @dev Throws if called by any account other than the VaultApe.
     */
    modifier onlyVaultApe() {
        require(
            address(vaultApe) == msg.sender,
            "BaseBananaMaximizerStrategy: caller is not the VaultApe"
        );
        _;
    }

    /// @notice Get all balances of a user
    /// @param _userAddress user address
    /// @return stake
    /// @return banana
    /// @return autoBananaShares
    function balanceOf(address _userAddress)
        external
        view
        returns (
            uint256 stake,
            uint256 banana,
            uint256 autoBananaShares
        )
    {
        IMaximizerVaultApe.Settings memory settings = getSettings();

        UserInfo memory user = userInfo[_userAddress];

        uint256 pendingShares = ((user.stake * accSharesPerStakedToken) /
            1e18) - user.rewardDebt;

        stake = user.stake;
        autoBananaShares = (user.autoBananaShares + pendingShares);
        banana =
            (autoBananaShares * BANANA_VAULT.getPricePerFullShare()) /
            1e18;
        if (settings.withdrawRewardsFee > 0) {
            uint256 rewardFee = (banana * settings.withdrawRewardsFee) / 10000;
            banana -= rewardFee;
        }
    }

    /// @notice Using total harvestable rewards as the input, find the outputs for each respective output
    /// @return platformOutput WBNB output amount which goes to the platform
    /// @return keeperOutput WBNB output amount which goes to the keeper
    /// @return burnOutput BANANA amount which goes to the burn address
    /// @return bananaOutput BANANA amount which goes to compounding
    function getExpectedOutputs()
        external
        view
        returns (
            uint256 platformOutput,
            uint256 keeperOutput,
            uint256 burnOutput,
            uint256 bananaOutput
        )
    {
        IMaximizerVaultApe.Settings memory settings = getSettings();

        // Find the expected WBNB value of the current harvestable rewards
        uint256 wbnbOutput = _getExpectedOutput(pathToWbnb);
        // Find the expected BANANA value of the current harvestable rewards
        uint256 bananaOutputWithoutFees = _getExpectedOutput(pathToBanana);
        // Calculate the WBNB values
        keeperOutput = (wbnbOutput * settings.keeperFee) / 10000;
        // Calculate the BANANA values
        platformOutput = (bananaOutputWithoutFees * settings.platformFee) / 10000;
        burnOutput = (bananaOutputWithoutFees * settings.buyBackRate) / 10000;
        uint256 bananaFees = 
            ((bananaOutputWithoutFees * settings.keeperFee) / 10000) + platformOutput + burnOutput;
        bananaOutput = bananaOutputWithoutFees - bananaFees;
    }

    /// @notice deposit in vault
    /// @param _userAddress user address
    function deposit(address _userAddress, uint256 _amount)
        external
        nonReentrant
        onlyVaultApe
    {
        require(
            _amount > 0,
            "BaseBananaMaximizerStrategy: amount must be greater than zero"
        );
        _beforeDeposit(_userAddress);
        // Update userInfo
        UserInfo storage user = userInfo[_userAddress];
        // Update autoBananaShares
        user.autoBananaShares +=
            ((user.stake * accSharesPerStakedToken) / 1e18) -
            user.rewardDebt;

        uint256 deposited = _farm();
        user.rewardDebt = (user.stake * accSharesPerStakedToken) / 1e18;
        user.stake += deposited;
        user.lastDepositedTime = block.timestamp;

        emit Deposit(_userAddress, deposited);
    }

    /// @notice withdraw tokens from vault
    /// @param _userAddress user address
    /// @param _amount amount to withdraw
    function withdraw(address _userAddress, uint256 _amount)
        external
        nonReentrant
        onlyVaultApe
    {
        require(
            _amount > 0,
            "BaseBananaMaximizerStrategy: amount must be greater than zero"
        );
        _beforeWithdraw(_userAddress);
        UserInfo storage user = userInfo[_userAddress];
        uint256 currentAmount = user.stake < _amount ? user.stake : _amount;

        uint256 stakeTokenBalance = IERC20(STAKE_TOKEN).balanceOf(
            address(this)
        );

        if (currentAmount > stakeTokenBalance) {
            _vaultWithdraw(currentAmount - stakeTokenBalance);
            stakeTokenBalance = IERC20(STAKE_TOKEN).balanceOf(address(this));
        }

        IMaximizerVaultApe.Settings memory settings = getSettings();
        // Handle stake token
        uint256 withdrawFee = 0;
        if (
            settings.withdrawFee > 0 &&
            block.timestamp <
            (user.lastDepositedTime + settings.withdrawFeePeriod)
        ) {
            // Take withdraw fees
            withdrawFee = (currentAmount * settings.withdrawFee) / 10000;
            STAKE_TOKEN.safeTransfer(settings.treasury, withdrawFee);
        }
        STAKE_TOKEN.safeTransfer(_userAddress, currentAmount - withdrawFee);

        user.autoBananaShares +=
            ((user.stake * accSharesPerStakedToken) / 1e18) -
            user.rewardDebt;
        // Setting order so that rewardDebt is zero when withdrawing all
        user.stake -= currentAmount;
        user.rewardDebt = (user.stake * accSharesPerStakedToken) / 1e18;
        // Withdraw banana rewards if user leaves
        if (user.stake == 0 && user.autoBananaShares > 0) {
            // Not updating in the withdraw as it's accomplished above
            _bananaVaultWithdraw(_userAddress, user.autoBananaShares, false);
        }

        emit Withdraw(_userAddress, currentAmount - withdrawFee, withdrawFee);
    }

    /// @notice claim rewards
    /// @param _userAddress user address
    /// @param _shares shares to withdraw
    function claimRewards(address _userAddress, uint256 _shares)
        external
        nonReentrant
        onlyVaultApe
    {
        _bananaVaultWithdraw(_userAddress, _shares, true);
    }

    // 1. Harvest rewards
    // 2. Collect fees
    // 3. Convert rewards to $BANANA
    // 4. Stake to banana auto-compound vault
    /// @notice compound of vault
    /// @param _minPlatformOutput Minimum platform fee output
    /// @param _minKeeperOutput Minimum keeper fee output
    /// @param _minBurnOutput Minimum burn fee output
    /// @param _minBananaOutput Minimum banana output
    /// @param _takeKeeperFee Take keeper fee for chainlink keeper
    function earn(
        uint256 _minPlatformOutput,
        uint256 _minKeeperOutput,
        uint256 _minBurnOutput,
        uint256 _minBananaOutput,
        bool _takeKeeperFee
    ) public nonReentrant {
        _vaultHarvest();

        IMaximizerVaultApe.Settings memory settings = getSettings();
        uint256 rewardTokenBalance = _rewardTokenBalance();

        // Collect keeper fees
        if (_takeKeeperFee && settings.keeperFee > 0) {
            _swap(
                (rewardTokenBalance * settings.keeperFee) / 10000,
                _minKeeperOutput,
                pathToWbnb,
                settings.treasury
            );
        }

        // Convert remaining rewards to BANANA
        if (address(FARM_REWARD_TOKEN) != address(BANANA)) {
            // Collect platform fees
            if (settings.platformFee > 0) {
                _swap(
                    (rewardTokenBalance * settings.platformFee) / 10000,
                    _minPlatformOutput,
                    pathToBanana,
                    settings.platform
                );
            }
            // Collect Burn fees
            if (settings.buyBackRate > 0) {
                _swap(
                    (rewardTokenBalance * settings.buyBackRate) / 10000,
                    _minBurnOutput,
                    pathToBanana,
                    BURN_ADDRESS
                );
            }

            _swap(
                _rewardTokenBalance(),
                _minBananaOutput,
                pathToBanana,
                address(this)
            );
        } else {
            // Collect platform fees
            if (settings.platformFee > 0) {
                BANANA.transfer(
                    settings.platform,
                    (rewardTokenBalance * settings.platformFee) / 10000
                );
            }
            // Collect Burn fees
            if (settings.buyBackRate > 0) {
                BANANA.transfer(
                    BURN_ADDRESS,
                    (rewardTokenBalance * settings.buyBackRate) / 10000
                );
            }
        }
        // Earns inside BANANA on deposits
        _bananaVaultDeposit(false);
    }

    /// @notice getter function for settings
    /// @return settings
    function getSettings()
        public
        view
        returns (IMaximizerVaultApe.Settings memory)
    {
        IMaximizerVaultApe.Settings memory defaultSettings = vaultApe
            .getSettings();

        address treasury = useDefaultSettings.treasury
            ? defaultSettings.treasury
            : strategySettings.treasury;
        uint256 keeperFee = useDefaultSettings.keeperFee
            ? defaultSettings.keeperFee
            : strategySettings.keeperFee;
        address platform = useDefaultSettings.platform
            ? defaultSettings.platform
            : strategySettings.platform;
        uint256 platformFee = useDefaultSettings.platformFee
            ? defaultSettings.platformFee
            : strategySettings.platformFee;
        uint256 buyBackRate = useDefaultSettings.buyBackRate
            ? defaultSettings.buyBackRate
            : strategySettings.buyBackRate;
        uint256 withdrawFee = useDefaultSettings.withdrawFee
            ? defaultSettings.withdrawFee
            : strategySettings.withdrawFee;
        uint256 withdrawFeePeriod = useDefaultSettings.withdrawFeePeriod
            ? defaultSettings.withdrawFeePeriod
            : strategySettings.withdrawFeePeriod;
        uint256 withdrawRewardsFee = useDefaultSettings.withdrawRewardsFee
            ? defaultSettings.withdrawRewardsFee
            : strategySettings.withdrawRewardsFee;

        IMaximizerVaultApe.Settings memory actualSettings = IMaximizerVaultApe
            .Settings(
                treasury,
                keeperFee,
                platform,
                platformFee,
                buyBackRate,
                withdrawFee,
                withdrawFeePeriod,
                withdrawRewardsFee
            );
        return actualSettings;
    }

    function _farm() internal returns (uint256) {
        uint256 stakeTokenBalance = IERC20(STAKE_TOKEN).balanceOf(
            address(this)
        );
        if (stakeTokenBalance == 0) return 0;

        uint256 stakeBefore = totalStake();
        _vaultDeposit(stakeTokenBalance);
        // accSharesPerStakedToken is updated here to ensure
        _bananaVaultDeposit(true);
        uint256 stakeAfter = totalStake();

        return stakeAfter - stakeBefore;
    }

    function _bananaVaultWithdraw(
        address _userAddress,
        uint256 _shares,
        bool _update
    ) internal {
        IMaximizerVaultApe.Settings memory settings = getSettings();
        UserInfo storage user = userInfo[_userAddress];

        if (_update) {
            // Add claimable Banana to user state and update debt
            user.autoBananaShares +=
                ((user.stake * accSharesPerStakedToken) / 1e18) -
                user.rewardDebt;
            user.rewardDebt = (user.stake * accSharesPerStakedToken) / 1e18;
        }

        uint256 currentShares = user.autoBananaShares < _shares
            ? user.autoBananaShares
            : _shares;
        user.autoBananaShares -= currentShares;

        uint256 pricePerFullShare = BANANA_VAULT.getPricePerFullShare();
        uint256 bananaToWithdraw = (currentShares * pricePerFullShare) / 1e18;
        uint256 bananaBalance = _bananaBalance();
        uint256 bananaShareBalance = (bananaBalance * 1e18) / pricePerFullShare;
        uint256 totalStrategyBanana = totalBanana();

        if (bananaToWithdraw > totalStrategyBanana) {
            bananaToWithdraw = totalStrategyBanana;
            currentShares = (bananaToWithdraw * 1e18) / pricePerFullShare;
        }

        if (currentShares > bananaShareBalance) {
            BANANA_VAULT.withdraw(currentShares - bananaShareBalance);
            bananaBalance = _bananaBalance();
        }

        if (bananaToWithdraw > bananaBalance) {
            bananaToWithdraw = bananaBalance;
        }

        if (settings.withdrawRewardsFee > 0) {
            uint256 bananaFee = (bananaToWithdraw *
                settings.withdrawRewardsFee) / 10000;
            // BananaVault fees are taken on withdraws
            _safeBANANATransfer(settings.treasury, bananaFee);
            bananaToWithdraw -= bananaFee;
        }

        _safeBANANATransfer(_userAddress, bananaToWithdraw);

        emit ClaimRewards(_userAddress, currentShares, bananaToWithdraw);
    }

    function _bananaVaultDeposit(bool _takeFee) internal {
        uint256 bananaBalance = _bananaBalance();
        if (bananaBalance == 0) {
            // earn
            BANANA_VAULT.deposit(0);
            return;
        }
        uint256 previousShares = totalAutoBananaShares();
        // Handle fee if needed
        IMaximizerVaultApe.Settings memory settings = getSettings();
        if (_takeFee && settings.withdrawRewardsFee > 0) {
            // This catches times when banana is deposited outside of earn and harvests are generated
            uint256 bananaFee = (bananaBalance * settings.withdrawRewardsFee) /
                10000;
            _safeBANANATransfer(settings.treasury, bananaFee);
            bananaBalance -= bananaFee;
        }

        _approveTokenIfNeeded(BANANA, bananaBalance, address(BANANA_VAULT));
        BANANA_VAULT.deposit(bananaBalance);

        uint256 currentShares = totalAutoBananaShares();
        uint256 shareIncrease = currentShares - previousShares;

        uint256 increaseAccSharesPerStakedToken = ((shareIncrease +
            unallocatedShares) * 1e18) / totalStake();
        accSharesPerStakedToken += increaseAccSharesPerStakedToken;

        // Not all shares are allocated because it's divided by totalStake() and can have rounding issue.
        // Example: 12345/100 shares = 123.45 which is 123 as uint
        // This calculates the unallocated shares which can then will be allocated later.
        // From example: 45 missing shares still to be allocated
        unallocatedShares =
            (shareIncrease + unallocatedShares) -
            ((increaseAccSharesPerStakedToken * totalStake()) / 1e18);
    }

    function _rewardTokenBalance() internal view returns (uint256) {
        return FARM_REWARD_TOKEN.balanceOf(address(this));
    }

    function _bananaBalance() internal view returns (uint256) {
        return BANANA.balanceOf(address(this));
    }

    /// @notice total strategy shares in banana vault
    /// @return totalAutoBananaShares rewarded banana shares in banana vault
    function totalAutoBananaShares() public view returns (uint256) {
        (uint256 shares, , , ) = BANANA_VAULT.userInfo(address(this));
        return shares;
    }

    /// @notice Returns the total amount of BANANA stored in the vault + the strategy
    /// @return totalBananaShares rewarded banana shares in banana vault
    function totalBanana() public view returns (uint256) {
        uint256 autoBanana = (totalAutoBananaShares() *
            BANANA_VAULT.getPricePerFullShare()) / 1e18;
        return autoBanana + _bananaBalance();
    }

    // Safe BANANA transfer function, just in case if rounding error causes pool to not have enough
    function _safeBANANATransfer(address _to, uint256 _amount) internal {
        uint256 balance = _bananaBalance();

        if (_amount > balance) {
            BANANA.transfer(_to, balance);
        } else {
            BANANA.transfer(_to, _amount);
        }
    }

    function _swap(
        uint256 _inputAmount,
        uint256 _minOutputAmount,
        address[] memory _path,
        address _to
    ) internal {
        _approveTokenIfNeeded(FARM_REWARD_TOKEN, _inputAmount, address(router));

        router.swapExactTokensForTokens(
            _inputAmount,
            _minOutputAmount,
            _path,
            _to,
            block.timestamp
        );
    }

    function _approveTokenIfNeeded(
        IERC20 _token,
        uint256 _amount,
        address _spender
    ) internal {
        if (_token.allowance(address(this), _spender) < _amount) {
            _token.safeIncreaseAllowance(_spender, _amount);
        }
    }

    /** onlyOwner functions */
    /// @notice set path from reward token to banana
    /// @param _path path to banana
    /// @dev only owner
    function setPathToBanana(address[] memory _path) external onlyOwner {
        require(
            _path[0] == address(FARM_REWARD_TOKEN) &&
                _path[_path.length - 1] == address(BANANA),
            "BaseBananaMaximizerStrategy: Incorrect path to BANANA"
        );
        emit SetPathToBanana(pathToBanana, _path);
        pathToBanana = _path;
    }

    /// @notice set path from reward token to wbnb
    /// @param _path path to wbnb
    /// @dev only owner
    function setPathToWbnb(address[] memory _path) external onlyOwner {
        require(
            _path[0] == address(FARM_REWARD_TOKEN) &&
                _path[_path.length - 1] == WBNB,
            "BaseBananaMaximizerStrategy: Incorrect path to WBNB"
        );
        emit SetPathToWbnb(pathToWbnb, _path);
        pathToWbnb = _path;
    }

    /// @notice set platform address
    /// @param _platform platform address
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setPlatform(address _platform, bool _useDefault)
        external
        onlyOwner
    {
        useDefaultSettings.platform = _useDefault;
        emit SetPlatform(strategySettings.platform, _platform, _useDefault);
        strategySettings.platform = _platform;
    }

    /// @notice set treasury address
    /// @param _treasury treasury address
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setTreasury(address _treasury, bool _useDefault)
        external
        onlyOwner
    {
        useDefaultSettings.treasury = _useDefault;
        emit SetTreasury(strategySettings.treasury, _treasury, _useDefault);
        strategySettings.treasury = _treasury;
    }

    /// @notice set keeper fee
    /// @param _keeperFee keeper fee
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setKeeperFee(uint256 _keeperFee, bool _useDefault)
        external
        onlyOwner
    {
        require(
            _keeperFee <= IMaximizerVaultApe(vaultApe).KEEPER_FEE_UL(),
            "BaseBananaMaximizerStrategy: Keeper fee too high"
        );
        useDefaultSettings.keeperFee = _useDefault;
        emit SetKeeperFee(strategySettings.keeperFee, _keeperFee, _useDefault);
        strategySettings.keeperFee = _keeperFee;
    }

    /// @notice set platform fee
    /// @param _platformFee platform fee
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setPlatformFee(uint256 _platformFee, bool _useDefault)
        external
        onlyOwner
    {
        require(
            _platformFee <= IMaximizerVaultApe(vaultApe).PLATFORM_FEE_UL(),
            "BaseBananaMaximizerStrategy: Platform fee too high"
        );
        useDefaultSettings.platformFee = _useDefault;
        emit SetPlatformFee(
            strategySettings.platformFee,
            _platformFee,
            _useDefault
        );
        strategySettings.platformFee = _platformFee;
    }

    /// @notice set buyback rate fee
    /// @param _buyBackRate buyback rate fee
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setBuyBackRate(uint256 _buyBackRate, bool _useDefault)
        external
        onlyOwner
    {
        require(
            _buyBackRate <= IMaximizerVaultApe(vaultApe).BUYBACK_RATE_UL(),
            "BaseBananaMaximizerStrategy: Buy back rate too high"
        );
        useDefaultSettings.buyBackRate = _useDefault;
        emit SetBuyBackRate(
            strategySettings.buyBackRate,
            _buyBackRate,
            _useDefault
        );
        strategySettings.buyBackRate = _buyBackRate;
    }

    /// @notice set withdraw fee
    /// @param _withdrawFee withdraw fee
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setWithdrawFee(uint256 _withdrawFee, bool _useDefault)
        external
        onlyOwner
    {
        require(
            _withdrawFee <= IMaximizerVaultApe(vaultApe).WITHDRAW_FEE_UL(),
            "BaseBananaMaximizerStrategy: Early withdraw fee too high"
        );
        useDefaultSettings.withdrawFee = _useDefault;
        emit SetWithdrawFee(
            strategySettings.withdrawFee,
            _withdrawFee,
            _useDefault
        );
        strategySettings.withdrawFee = _withdrawFee;
    }

    /// @notice set withdraw fee period
    /// @param _withdrawFeePeriod withdraw fee period
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod, bool _useDefault)
        external
        onlyOwner
    {
        require(
            _withdrawFeePeriod <=
                IMaximizerVaultApe(vaultApe).WITHDRAW_FEE_PERIOD_UL(),
            "BaseBananaMaximizerStrategy: Withdraw fee period too long"
        );
        useDefaultSettings.withdrawFeePeriod = _useDefault;
        emit SetWithdrawFee(
            strategySettings.withdrawFeePeriod,
            _withdrawFeePeriod,
            _useDefault
        );
        strategySettings.withdrawFeePeriod = _withdrawFeePeriod;
    }

    /// @notice set withdraw rewards fee
    /// @param _withdrawRewardsFee withdraw rewards fee
    /// @param _useDefault usage of VaultApeMaximizer default
    /// @dev only owner
    function setWithdrawRewardsFee(
        uint256 _withdrawRewardsFee,
        bool _useDefault
    ) external onlyOwner {
        require(
            _withdrawRewardsFee <=
                IMaximizerVaultApe(vaultApe).WITHDRAW_REWARDS_FEE_UL(),
            "BaseBananaMaximizerStrategy: Withdraw rewards fee too high"
        );
        useDefaultSettings.withdrawRewardsFee = _useDefault;
        emit SetWithdrawRewardsFee(
            strategySettings.withdrawRewardsFee,
            _withdrawRewardsFee,
            _useDefault
        );
        strategySettings.withdrawRewardsFee = _withdrawRewardsFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IVaultApe {
    struct PoolInfo {
        IERC20 want; // Address of the want token.
        address strat; // Strategy address that will auto compound want tokens
    }

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256 shares);

    function poolLength() external view returns (uint256);

    function addPool(address _strat) external;

    function stakedWantTokens(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function deposit(
        uint256 _pid,
        uint256 _wantAmt,
        address _to
    ) external;

    function deposit(uint256 _pid, uint256 _wantAmt) external;

    function withdraw(
        uint256 _pid,
        uint256 _wantAmt,
        address _to
    ) external;

    function withdraw(uint256 _pid, uint256 _wantAmt) external;

    function withdrawAll(uint256 _pid) external;

    function earnAll() external;

    function earnSome(uint256[] memory pids) external;

    function resetAllowances() external;

    function resetSingleAllowance(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IUniRouter01.sol";

interface IUniRouter02 is IUniRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IUniRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../libs/IMaximizerVaultApe.sol";

// For interacting with our own strategy
interface IStrategyMaximizerMasterApe {
    function STAKE_TOKEN_ADDRESS() external returns (address);

    function vaultApe() external returns (IMaximizerVaultApe);

    function accSharesPerStakedToken() external view returns (uint256);

    function totalStake() external view returns (uint256);

    function getExpectedOutputs()
        external
        view
        returns (
            uint256 platformOutput,
            uint256 keeperOutput,
            uint256 burnOutput,
            uint256 bananaOutput
        );

    function balanceOf(address)
        external
        view
        returns (
            uint256 stake,
            uint256 banana,
            uint256 autoBananaShares
        );

    function userInfo(address)
        external
        view
        returns (
            uint256 stake,
            uint256 autoBananaShares,
            uint256 rewardDebt,
            uint256 lastDepositedTime
        );

    // Main want token compounding function
    function earn(
        uint256 _minPlatformOutput,
        uint256 _minKeeperOutput,
        uint256 _minBurnOutput,
        uint256 _minBananaOutput,
        bool _takeKeeperFee
    ) external;

    // Transfer want tokens autoFarm -> strategy
    function deposit(address _userAddress, uint256 _amount) external;

    // Transfer want tokens strategy -> vaultChef
    function withdraw(address _userAddress, uint256 _wantAmt) external;

    function claimRewards(address _userAddress, uint256 _shares) external;

    function emergencyVaultWithdraw() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IMaximizerVaultApe {
    function KEEPER_FEE_UL() external view returns (uint256);

    function PLATFORM_FEE_UL() external view returns (uint256);

    function BUYBACK_RATE_UL() external view returns (uint256);

    function WITHDRAW_FEE_UL() external view returns (uint256);

    function WITHDRAW_REWARDS_FEE_UL() external view returns (uint256);

    function WITHDRAW_FEE_PERIOD_UL() external view returns (uint256);

    struct Settings {
        address treasury;
        uint256 keeperFee;
        address platform;
        uint256 platformFee;
        uint256 buyBackRate;
        uint256 withdrawFee;
        uint256 withdrawFeePeriod;
        uint256 withdrawRewardsFee;
    }

    function getSettings() external view returns (Settings memory);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 stake,
            uint256 autoBananaShares,
            uint256 rewardDebt,
            uint256 lastDepositedTime
        );

    function vaultsLength() external view returns (uint256);

    function addVault(address _strat) external;

    function stakedWantTokens(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function deposit(uint256 _pid, uint256 _wantAmt) external;

    function withdraw(uint256 _pid, uint256 _wantAmt) external;

    function withdrawAll(uint256 _pid) external;

    function earnAll() external;

    function earnSome(uint256[] memory pids) external;

    function harvest(uint256 _pid, uint256 _wantAmt) external;

    function harvestAll(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMasterApe {
    function BONUS_MULTIPLIER() external view returns (uint256);

    function cake() external view returns (address);

    function cakePerBlock() external view returns (uint256);

    function devaddr() external view returns (address);

    function owner() external view returns (address);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function renounceOwnership() external;

    function startBlock() external view returns (uint256);

    function syrup() external view returns (address);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function updateMultiplier(uint256 multiplierNumber) external;

    function poolLength() external view returns (uint256);

    function checkPoolDuplicate(address _lpToken) external view;

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function dev(address _devaddr) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/IAccessControlEnumerable.sol";

interface IBananaVault is IAccessControlEnumerable {
    function DEPOSIT_ROLE() external view returns (bytes32);

    function userInfo(address _address)
        external
        view
        returns (
            uint256 shares,
            uint256 lastDepositedTime,
            uint256 pacocaAtLastUserAction,
            uint256 lastUserActionTime
        );

    function earn() external;

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _shares) external;

    function lastHarvestedTime() external view returns (uint256);

    function calculateTotalPendingBananaRewards()
        external
        view
        returns (uint256);

    function getPricePerFullShare() external view returns (uint256);

    function available() external view returns (uint256);

    function underlyingTokenBalance() external view returns (uint256);

    function masterApe() external view returns (address);
    
    function bananaToken() external view returns (address);

    function totalShares() external view returns (uint256);

    function withdrawAll() external;

    function treasury() external view returns (address);

    function setTreasury(address _treasury) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}