// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";
import "./interfaces/IERC20Burnable.sol";
import "./interfaces/IGymLevelPool.sol";
import "./interfaces/IGymMLM.sol";
import "./interfaces/IGymMLMQualifications.sol";
import "./interfaces/IGymNetwork.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IWETH.sol";
import "./RewardRateConfigurable.sol";
import "./interfaces/INFTReflection.sol";
import "./interfaces/ICommissionActivation.sol";

/* preserved Line */
/* preserved Line */
/* preserved Line */
/* preserved Line */

/**
 * @notice GymSinglePool contract:
 * - Users can:
 *   # Deposit GYMNET
 *   # Withdraw assets
 */

contract GymSinglePool is ReentrancyGuardUpgradeable, OwnableUpgradeable, RewardRateConfigurable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Info of each user
     * One Address can have many Deposits with different periods. Unlimited Amount.
     * Total Depsit Tokens = Total amount of user active stake in all.
     * Total Depsit Dollar Value = Total Dollar Value over all staking single pools. Calculated when user deposits tokens, and dollar value is for that exact moment rate.
     * level = level qualification for this pool. Used internally, for global qualification please check MLM Contract.
     * depositId = incremental ID of deposits, eg. if user has 3 stakings then this value will be 2;
     * totalClaimt = Total amount of tokens user claimt.
     */
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 totalGGYMNET;
        uint256 level;
        uint256 depositId;
        uint256 totalClaimt;
    }

    /**
     * @notice Info for each staking by ID
     * One Address can have many Deposits with different periods. Unlimited Amount.
     * depositTokens = amount of tokens for exact deposit.
     * depositDollarValue = Dollar value of deposit.
     * stakePeriod = Locking Period - from 3 months to 30 months. value is integer
     * depositTimestamp = timestamp of deposit
     * withdrawalTimestamp = Timestamp when user can withdraw his locked tokens
     * rewardsGained = amount of rewards user has gained during the process
     * is_finished = checks if user has already withdrawn tokens
     */
    struct UserDeposits {
        uint256 depositTokens;
        uint256 depositDollarValue;
        uint256 stakePeriod;
        uint256 depositTimestamp;
        uint256 withdrawalTimestamp;
        uint256 rewardsGained;
        uint256 rewardsClaimt;
        uint256 rewardDebt;
        uint256 ggymnetAmt;
        bool is_finished;
        bool is_unlocked;
    }
    /**
     * @notice Info of Pool
     * @param lastRewardBlock: Last block number that reward distribution occurs
     * @param accUTacoPerShare: Accumulated rewardPool per share, times 1e18
     */
    struct PoolInfo {
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    /// Startblock number
    uint256 public startBlock;
    uint256 public withdrawFee;

    // MLM Contract - RelationShip address
    address public relationship;
    /// Treasury address where will be sent all unused assets
    address public treasuryAddress;
    /// Info of pool.
    PoolInfo public poolInfo;
    /// Info of each user that staked tokens.
    mapping(address => UserInfo) public userInfo;

    /// accepts user address and id of element to select - returns information about selected staking by id
    mapping(address => UserDeposits[]) public user_deposits;

    uint256 private lastChangeBlock;

    /// GYMNET token contract address
    address public tokenAddress;

    /// Level Qualifications for the pool
    uint256[25] public levels;
    /// Locking Periods
    uint256[6] public months;
    /// GGYMNET AMT Allocation
    uint256[6] public ggymnetAlloc;

    /// Amount of Total GYMNET Locked in the pool
    uint256 public totalGymnetLocked;
    uint256 public totalGGymnetInPoolLocked;

    /// Amount of GYMNET all users has claimt over time.
    uint256 public totalClaimtInPool;

    /// Percent that will be sent to MLM Contract for comission distribution
    uint256 public RELATIONSHIP_REWARD;

    /// 6% comissions
    uint256 public poolRewardsAmount;

    address public holderRewardContractAddress;

    address public runnerScriptAddress;
    uint256 public totalBurntInSinglePool;
    bool public isPoolActive;
    bool public isInMigrationToVTwo;
    uint256 public totalGymnetUnlocked;
    address public vaultContractAddress;
    address public farmingContractAddress;

    address public levelPoolContractAddress;
    address public mlmQualificationsAddress;
    mapping(address => bool) private whitelist_contract;
    address public nftReflectionAddress;
    /* ========== EVENTS ========== */

    event Initialized(address indexed executor, uint256 at);
    event Deposit(address indexed user, uint256 amount, uint256 indexed period);
    event Withdraw(address indexed user, uint256 amount, uint256 indexed period);
    event RewardPaid(address indexed token, address indexed user, uint256 amount);
    event ClaimUserReward(address indexed user, uint256 amount);

    event WhitelistContract(address indexed _contract, bool _whitelist);

    event SetStartBlock(uint256 startBlock);
    event SetGymMLMAddress(address indexed _address);
    event SetTokenAddress(address indexed _address);
    event SetGymVaultsBankAddress(address indexed _address);
    event SetGymFarmingAddress(address indexed _address);
    event SetGymMLMQualificationsAddress(address indexed _address);
    event SetGymLevelPoolAddress(address indexed _address);
    event SetRunnerScriptAddress(address indexed _address);
    event SetGymHolderRewardAddress(address indexed _address);
    event SetTreasuryAddress(address indexed _address);

    event SetRelationshipReward(uint256 amount);
    event SetPoolActive(bool isActive);
    event SetMigrationToV2(bool isMigration);

    modifier onlyRunnerScript() {
        require(msg.sender == runnerScriptAddress || msg.sender == owner(), "Only Runner Script");
        _;
    }
    modifier onlyWhitelistedContract() {
        require(
            whitelist_contract[msg.sender] || msg.sender == owner(),
            "GymSinglePool: not whitelisted or owner"
        );
        _;
    }

    modifier hasInvestment(address _user) {
        require(
            IGymMLM(relationship).hasInvestment(_user),
            "GymFarming: only user with investment"
        );
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    // all initialize parameters are mandatory
    function initialize(
        uint256 _startBlock,
        address _gym,
        address _mlm,
        uint256 _gymRewardRate
    ) external initializer {
        require(block.number < _startBlock, "SinglePool: Start block must have a bigger value");
        startBlock = _startBlock; // Number of Upcoming Block
        relationship = _mlm; // address of MLM contract
        tokenAddress = _gym; // address of GYMNET Contract
        runnerScriptAddress = msg.sender;
        isPoolActive = false;
        isInMigrationToVTwo = false;
        RELATIONSHIP_REWARD = 39; // Relationship commission amount
        levels = [
            0,
            0,
            50,
            100,
            250,
            500,
            1000,
            2500,
            5000,
            7500,
            10000,
            10000,
            15000,
            20000,
            20000,
            25000,
            30000,
            30000,
            30000,
            30000,
            35000,
            35000,
            40000,
            45000,
            50000
        ]; // Internal Pool Levels
        months = [3, 6, 12, 18, 24, 30]; // Locking Periods
        ggymnetAlloc = [
            76923076920000000,
            90909090910000000,
            105263157900000000,
            125000000000000000,
            153846153800000000,
            200000000000000000
        ]; // GGYMNET ALLOCATION AMOUNT

        poolInfo = PoolInfo({lastRewardBlock: _startBlock, accRewardPerShare: 0});

        lastChangeBlock = _startBlock;

        __Ownable_init();
        __ReentrancyGuard_init();
        __RewardRateConfigurable_init(_gymRewardRate, 864000);
    }

    function setPoolInfo(
        uint256 lastRewardBlock,
        uint256 accRewardPerShare,
        uint256 rewardPerBlock,
        uint256 rewardUpdateBlocksInterval
    ) external onlyOwner {
        updatePool();

        poolInfo = PoolInfo({
            lastRewardBlock: lastRewardBlock,
            accRewardPerShare: accRewardPerShare
        });

        _setRewardConfiguration(rewardPerBlock, rewardUpdateBlocksInterval);
    }

    function setLastRewardBlock(uint256 lastRewardBlock, uint256 accRewardPerShare)
        external
        onlyOwner
    {
        poolInfo = PoolInfo({
            lastRewardBlock: lastRewardBlock,
            accRewardPerShare: accRewardPerShare
        });
    }

    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;

        emit SetStartBlock(_startBlock);
    }

    function setMLMAddress(address _relationship) external onlyOwner {
        relationship = _relationship;

        emit SetGymMLMAddress(_relationship);
    }

    function setNftReflectionAddress(address _nftReflection) external onlyOwner {
        nftReflectionAddress = _nftReflection;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;

        emit SetTokenAddress(_tokenAddress);
    }

    function setVaultContractAddress(address _vaultContractAddress) external onlyOwner {
        vaultContractAddress = _vaultContractAddress;

        emit SetGymVaultsBankAddress(_vaultContractAddress);
    }

    function setFarmingContractAddress(address _farmingContractAddress) external onlyOwner {
        farmingContractAddress = _farmingContractAddress;

        emit SetGymFarmingAddress(_farmingContractAddress);
    }

    function setMLMQualificationsAddress(address _address) external onlyOwner {
        mlmQualificationsAddress = _address;

        emit SetGymMLMQualificationsAddress(_address);
    }

    function setLevelPoolContractAddress(address _levelPoolContractAddress) external onlyOwner {
        levelPoolContractAddress = _levelPoolContractAddress;

        emit SetGymLevelPoolAddress(_levelPoolContractAddress);
    }

    function setRelationshipReward(uint256 _amount) external onlyOwner {
        RELATIONSHIP_REWARD = _amount;

        emit SetRelationshipReward(_amount);
    }

    function setOnlyRunnerScript(address _onlyRunnerScript) external onlyOwner {
        runnerScriptAddress = _onlyRunnerScript;

        emit SetRunnerScriptAddress(_onlyRunnerScript);
    }

    function setIsPoolActive(bool _isPoolActive) external onlyOwner {
        isPoolActive = _isPoolActive;

        emit SetPoolActive(_isPoolActive);
    }

    function setIsInMigrationToVTwo(bool _isInMigrationToVTwo) external onlyOwner {
        isInMigrationToVTwo = _isInMigrationToVTwo;

        emit SetMigrationToV2(_isInMigrationToVTwo);
    }

    function setHolderRewardContractAddress(address _holderRewardContractAddress)
        external
        onlyOwner
    {
        holderRewardContractAddress = _holderRewardContractAddress;

        emit SetGymHolderRewardAddress(_holderRewardContractAddress);
    }

    function setLevels(uint256[25] calldata _levels) external onlyOwner {
        levels = _levels;
    }

    /**
     * @notice Add or remove wallet to/from whitelist, callable only by contract owner
     *         whitelisted wallet will be able to call functions
     *         marked with onlyWhitelistedContract modifier
     * @param _wallet wallet to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistContract(address _wallet, bool _whitelist) external onlyOwner {
        whitelist_contract[_wallet] = _whitelist;

        emit WhitelistContract(_wallet, _whitelist);
    }

    function isWhitelistedContract(address wallet) external view returns (bool) {
        return whitelist_contract[wallet];
    }

    /**
     * @notice  Function to set Treasury address
     * @param _treasuryAddress Address of treasury address
     */
    function setTreasuryAddress(address _treasuryAddress) external nonReentrant onlyOwner {
        treasuryAddress = _treasuryAddress;

        emit SetTreasuryAddress(_treasuryAddress);
    }

    /**
     * @notice Deposit in given pool
     * @param _depositAmount: Amount of want token that user wants to deposit
     */
    function deposit(
        uint256 _depositAmount,
        uint8 _periodId,
        bool isUnlocked
    ) external nonReentrant hasInvestment(msg.sender) {
        require(isPoolActive, "Contract is not running yet");
        //TO-DO Add Vault check here
        if (isUnlocked) {
            _periodId = 0;
        }
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            _activatePendingCommissions(msg.sender);
        }

        _deposit(_depositAmount, _periodId, isUnlocked);
        _updateLevelPoolQualification(msg.sender);
    }

    /**
     * @notice Deposit in given pool
     * @param _depositAmount: Amount of want token that user wants to deposit
     */
    function depositFromOtherContract(
        uint256 _depositAmount,
        uint8 _periodId,
        bool isUnlocked,
        address _from
    ) external nonReentrant onlyWhitelistedContract {
        require(isPoolActive, "Contract is not running yet");
        if (isUnlocked) {
            _periodId = 0;
        }
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(_from, 3)
        ) {
            _activatePendingCommissions(_from);
        }
        _autoDeposit(_depositAmount, _periodId, isUnlocked, _from);

        _updateLevelPoolQualification(_from);
    }

    /**
     * @notice To get User level in other contract for single pool.
     * @param _user: User address
     */
    function getUserLevelInSinglePool(address _user) external view returns (uint32) {
        uint256 _totalDepositDollarValue = userInfo[_user].totalDepositDollarValue;
        uint32 level = 0;
        for (uint32 i = 0; i < levels.length; i++) {
            if (_totalDepositDollarValue >= levels[i]) {
                level = i;
            }
        }
        return level;
    }

    function activatePendingCommissions() external {
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            _activatePendingCommissions(msg.sender);
        }
    }

    function _activatePendingCommissions(address _from) private {
        //TODO: change before deployment
        ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e).activateCommissions(
            3,
            _from
        );
        uint256 ggymnetAmtTotal = 0;
        for (uint256 _depositId = 0; _depositId < userInfo[_from].depositId; ++_depositId) {
            UserDeposits memory depositDetails = user_deposits[_from][_depositId];
            if (!depositDetails.is_finished) {
                ggymnetAmtTotal += depositDetails.ggymnetAmt;
            }
        }
        if(ggymnetAmtTotal > 0) {
            IGymMLM(relationship).distributeCommissions(
                ggymnetAmtTotal,
                0,
                3,
                true,
                _from
            );
        }
    }

    /**
    Should approve allowance before initiating
    accepts depositAmount in WEI
    periodID - id of months array accordingly
    */
    function _deposit(
        uint256 _depositAmount,
        uint8 _periodId,
        bool _isUnlocked
    ) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        updatePool();

        uint256 lockTimesamp = DateTime.addMonths(block.timestamp, months[_periodId]);
        uint256 burnTokensAmount = 0;

        if (!_isUnlocked) {
            burnTokensAmount = (_depositAmount * 4) / 100;
            totalBurntInSinglePool += burnTokensAmount;
            IERC20Burnable(tokenAddress).burnFrom(msg.sender, burnTokensAmount);
        }

        uint256 amountToDeposit = _depositAmount - burnTokensAmount;

        token.safeTransferFrom(msg.sender, address(this), amountToDeposit);

        uint256 UsdValueOfGym = ((amountToDeposit * IGYMNETWORK(tokenAddress).getGYMNETPrice()) /
            1e18) / 1e18;
        uint256 _ggymnetAmt = (amountToDeposit * ggymnetAlloc[_periodId]) / 1e18;

        if (_isUnlocked) {
            _ggymnetAmt = 0;
            totalGymnetUnlocked += amountToDeposit;
            lockTimesamp = DateTime.addSeconds(block.timestamp, months[_periodId]);
        }
        user.totalDepositTokens += amountToDeposit;
        user.totalDepositDollarValue += UsdValueOfGym;
        totalGymnetLocked += amountToDeposit;
        totalGGymnetInPoolLocked += _ggymnetAmt;

        uint256 rewardDebt = (_ggymnetAmt * (pool.accRewardPerShare)) / (1e18);
        UserDeposits memory depositDetails = UserDeposits({
            depositTokens: amountToDeposit,
            depositDollarValue: UsdValueOfGym,
            stakePeriod: _isUnlocked ? 0 : months[_periodId],
            depositTimestamp: block.timestamp,
            withdrawalTimestamp: lockTimesamp,
            rewardsGained: 0,
            is_finished: false,
            rewardsClaimt: 0,
            rewardDebt: rewardDebt,
            ggymnetAmt: _ggymnetAmt,
            is_unlocked: _isUnlocked
        });
        user.totalGGYMNET += _ggymnetAmt;
        user_deposits[msg.sender].push(depositDetails);
        user.depositId = user_deposits[msg.sender].length;

        IGymMLM(relationship).distributeCommissions(_ggymnetAmt, 0, 3, true, msg.sender);

        refreshMyLevel(msg.sender);
        emit Deposit(msg.sender, _depositAmount, _periodId);
    }

    /**
    Should approve allowance before initiating
    accepts depositAmount in WEI
    periodID - id of months array accordingly
    */
    function _autoDeposit(
        uint256 _depositAmount,
        uint8 _periodId,
        bool _isUnlocked,
        address _from
    ) private {
        UserInfo storage user = userInfo[_from];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        token.approve(address(this), _depositAmount);
        updatePool();
        uint256 lockTimesamp = DateTime.addMonths(block.timestamp, months[_periodId]);
        uint256 burnTokensAmount = 0;
        uint256 amountToDeposit = _depositAmount - burnTokensAmount;
        uint256 UsdValueOfGym = ((amountToDeposit * IGYMNETWORK(tokenAddress).getGYMNETPrice()) /
            1e18) / 1e18;
        uint256 _ggymnetAmt = (amountToDeposit * ggymnetAlloc[_periodId]) / 1e18;

        if (_isUnlocked) {
            _ggymnetAmt = 0;
            totalGymnetUnlocked += amountToDeposit;
            lockTimesamp = DateTime.addSeconds(block.timestamp, months[_periodId]);
        }
        user.totalDepositTokens += amountToDeposit;
        user.totalDepositDollarValue += UsdValueOfGym;
        totalGymnetLocked += amountToDeposit;
        totalGGymnetInPoolLocked += _ggymnetAmt;

        uint256 rewardDebt = (_ggymnetAmt * (pool.accRewardPerShare)) / (1e18);
        UserDeposits memory depositDetails = UserDeposits({
            depositTokens: amountToDeposit,
            depositDollarValue: UsdValueOfGym,
            stakePeriod: _isUnlocked ? 0 : months[_periodId],
            depositTimestamp: block.timestamp,
            withdrawalTimestamp: lockTimesamp,
            rewardsGained: 0,
            is_finished: false,
            rewardsClaimt: 0,
            rewardDebt: rewardDebt,
            ggymnetAmt: _ggymnetAmt,
            is_unlocked: _isUnlocked
        });
        user_deposits[_from].push(depositDetails);
        user.totalGGYMNET += _ggymnetAmt;
        user.depositId = user_deposits[_from].length;

        IGymMLM(relationship).distributeCommissions(_ggymnetAmt, 0, 3, true, _from);
        refreshMyLevel(_from);
        emit Deposit(_from, amountToDeposit, _periodId);
    }

    /**
     * @notice withdraw one claim
     * @param _depositId: is the id of user element.
     */
    function withdraw(uint256 _depositId) external nonReentrant {
        require(_depositId >= 0, "Value is not specified");
        updatePool();
        _withdraw(_depositId);

        _updateLevelPoolQualification(msg.sender);
    }

    /**
    Should approve allowance before initiating
    accepts _depositId - is the id of user element. 
    */
    function _withdraw(uint256 _depositId) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        UserDeposits storage depositDetails = user_deposits[msg.sender][_depositId];
        if (!isInMigrationToVTwo) {
            require(
                block.timestamp > depositDetails.withdrawalTimestamp,
                "Locking Period isn't over yet."
            );
        }
        require(!depositDetails.is_finished, "You already withdrawn your deposit.");

        _claim(_depositId, 1);
        depositDetails.rewardDebt = (depositDetails.ggymnetAmt * (pool.accRewardPerShare)) / (1e18);

        user.totalDepositTokens -= depositDetails.depositTokens;
        user.totalDepositDollarValue -= depositDetails.depositDollarValue;
        user.totalGGYMNET -= depositDetails.ggymnetAmt;
        totalGymnetLocked -= depositDetails.depositTokens;
        totalGGymnetInPoolLocked -= depositDetails.ggymnetAmt;

        if (depositDetails.stakePeriod == 0) {
            totalGymnetUnlocked -= depositDetails.depositTokens;
        }

        token.safeTransfer(msg.sender, depositDetails.depositTokens);

        refreshMyLevel(msg.sender);
        //TODO: change before deployment
        if (
            ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            IGymMLM(relationship).distributeCommissions(
                depositDetails.ggymnetAmt,
                0,
                3,
                false,
                msg.sender
            );
        }
        depositDetails.is_finished = true;
        emit Withdraw(msg.sender, depositDetails.depositTokens, depositDetails.stakePeriod);
    }

    /**
     * @notice Claim rewards you gained over period
     * @param _depositId: is the id of user element.
     */
    function claim(uint256 _depositId) external nonReentrant {
        require(_depositId >= 0, "Value is not specified");
        updatePool();
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            _activatePendingCommissions(msg.sender);
        }
        _claim(_depositId, 0);
    }

    /*
    Should approve allowance before initiating
    accepts _depositId - is the id of user element. 
    */
    function _claim(uint256 _depositId, uint256 fromWithdraw) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        UserDeposits storage depositDetails = user_deposits[msg.sender][_depositId];
        PoolInfo storage pool = poolInfo;

        uint256 pending = pendingReward(_depositId, msg.sender);

        if (fromWithdraw == 0) {
            require(pending > 0, "No rewards to claim.");
        }

        if (pending > 0) {
            uint256 distributeRewardTokenAmt = (pending * RELATIONSHIP_REWARD) / 100;
            token.safeTransfer(relationship, distributeRewardTokenAmt);
            IGymMLM(relationship).distributeRewards(pending, address(tokenAddress), msg.sender, 3);

            // 6% distribution
            uint256 calculateDistrubutionReward = (pending * 6) / 100;
            poolRewardsAmount += calculateDistrubutionReward;

            uint256 calcUserRewards = (pending -
                distributeRewardTokenAmt -
                calculateDistrubutionReward);
            safeRewardTransfer(tokenAddress, msg.sender, calcUserRewards);

            user.totalClaimt += calcUserRewards;
            totalClaimtInPool += pending;
            depositDetails.rewardsClaimt += pending;
            depositDetails.rewardDebt =
                (depositDetails.ggymnetAmt * (pool.accRewardPerShare)) /
                (1e18);
            emit ClaimUserReward(msg.sender, calcUserRewards);
            depositDetails.rewardsGained = 0;
        }

        // token.safeTransferFrom(address(this),msg.sender, depositDetails.rewardsGained);
    }

    /*
    transfers pool commisions to management
    */
    function transferPoolRewards() public onlyRunnerScript {
        require(
            address(holderRewardContractAddress) != address(0x0),
            "Holder Reward Address::SET_ZERO_ADDRESS"
        );
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        token.safeTransfer(holderRewardContractAddress, poolRewardsAmount);
        // token.safeTransfer(relationship, poolRewardsAmount/2);
        poolRewardsAmount = 0;
    }

    /**
     * @notice  Safe transfer function for reward tokens
     * @param _rewardToken Address of reward token contract
     * @param _to Address of reciever
     * @param _amount Amount of reward tokens to transfer
     */
    function safeRewardTransfer(
        address _rewardToken,
        address _to,
        uint256 _amount
    ) internal {
        uint256 _bal = IERC20Upgradeable(_rewardToken).balanceOf(address(this));
        uint256 amountToTransfer = _amount > _bal ? _bal : _amount;

        IERC20Upgradeable(_rewardToken).safeTransfer(_to, amountToTransfer);
    }

    /**
     * @notice To get User Info in other contract.
     */
    function getUserInfo(address _user) external view returns (UserInfo memory) {
        return userInfo[_user];
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _depositId: Staking pool id
     * @param _user: User address
     */
    function pendingReward(uint256 _depositId, address _user) public view returns (uint256) {
        return _getPendingRewards(_depositId, _user);
    }

    /**
     * @notice View function to see all pending rewards
     * @param _user: User address
     */
    function pendingRewardTotal(address _user) external view returns (uint256) {
        uint256 rewards;
        for (uint256 _depositId = 0; _depositId < userInfo[_user].depositId; ++_depositId) {
            rewards += _getPendingRewards(_depositId, _user);
        }
        return rewards;
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 sharesTotal = totalGGymnetInPoolLocked;
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        if (multiplier <= 0) {
            return;
        }
        uint256 _reward = (multiplier * getRewardPerBlock());
        pool.accRewardPerShare = pool.accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        pool.lastRewardBlock = block.number;

        // Update rewardPerBlock right AFTER pool update
        _updateRewardPerBlock();
    }

    /**
     * @notice Claim All Rewards in one Transaction Internat Function.
     * If reinvest = true, Rewards will be reinvested as a new Staking
     * Reinvest Period Id is the id of months element
     */
    function _claimAll(bool reinvest, uint8 reinvestPeriodId) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        updatePool();
        uint256 distributeRewardTokenAmtTotal = 0;
        uint256 calcUserRewardsTotal = 0;
        uint256 totalDistribute = 0;
        for (uint256 i = 0; i < user.depositId; i++) {
            UserDeposits storage depositDetails = user_deposits[msg.sender][i];
            uint256 pending = pendingReward(i, msg.sender);
            totalDistribute += pending;
            if (pending > 0) {
                uint256 distributeRewardTokenAmt = (pending * RELATIONSHIP_REWARD) / 100;
                distributeRewardTokenAmtTotal += distributeRewardTokenAmt;
                // 6% distribution
                uint256 calculateDistrubutionReward = (pending * 6) / 100;
                poolRewardsAmount += calculateDistrubutionReward;

                uint256 calcUserRewards = (pending -
                    distributeRewardTokenAmt -
                    calculateDistrubutionReward);
                calcUserRewardsTotal += calcUserRewards;

                user.totalClaimt += calcUserRewards;
                totalClaimtInPool += pending;
                depositDetails.rewardsClaimt += pending;
                depositDetails.rewardDebt =
                    (depositDetails.ggymnetAmt * (pool.accRewardPerShare)) /
                    (1e18);
                emit ClaimUserReward(msg.sender, calcUserRewards);
                depositDetails.rewardsGained = 0;
            }
        }
        token.safeTransfer(relationship, distributeRewardTokenAmtTotal);
        IGymMLM(relationship).distributeRewards(
            totalDistribute,
            address(tokenAddress),
            msg.sender,
            3
        );
        safeRewardTransfer(tokenAddress, msg.sender, calcUserRewardsTotal);
        if (reinvest == true) {
            _deposit(calcUserRewardsTotal, reinvestPeriodId, false);
        }
    }

    /**
     * @notice Claim All Rewards in one Transaction.
     */
    function claimAll() external nonReentrant {
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            _activatePendingCommissions(msg.sender);
        }
        _claimAll(false, 0);
    }

    /**
     * @notice Claim and Reinvest all rewards public function to trigger internal _claimAll function.
     */
    function claimAndReinvest(bool reinvest, uint8 periodId) public nonReentrant {
        require(isPoolActive, "Contract is not running yet");
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(msg.sender, 3)
        ) {
            _activatePendingCommissions(msg.sender);
        }
        _claimAll(reinvest, periodId);
    }

    function refreshMyLevel(address _user) public {
        UserInfo storage user = userInfo[_user];
        for (uint256 i = 0; i < levels.length; i++) {
            if (user.totalDepositDollarValue >= levels[i]) {
                user.level = i;
            }
        }
        if (nftReflectionAddress != address(0)) {
            INFTReflection(nftReflectionAddress).updateUser(user.totalGGYMNET, _user);
        }
    }

    function totalLockedTokens(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 totalDepositLocked = 0;
        for (uint256 i = 0; i < user.depositId; i++) {
            UserDeposits memory depositDetails = user_deposits[_user][i];
            if (depositDetails.stakePeriod != 0 && !depositDetails.is_finished) {
                totalDepositLocked += depositDetails.depositTokens;
            }
        }
        return totalDepositLocked;
    }

    function userTotalGGymnetLocked(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 totalGgymnetLocked = 0;
        for (uint256 i = 0; i < user.depositId; i++) {
            UserDeposits memory depositDetails = user_deposits[_user][i];
            if (!depositDetails.is_unlocked && !depositDetails.is_finished) {
                totalGgymnetLocked += depositDetails.ggymnetAmt;
            }
        }
        return totalGgymnetLocked;
    }

    function _updateLevelPoolQualification(address wallet) internal {
        if (mlmQualificationsAddress != address(0) && levelPoolContractAddress != address(0)) {
            uint256 userLevel = IGymMLMQualifications(mlmQualificationsAddress).getUserCurrentLevel(
                wallet
            );
            IGymLevelPool(levelPoolContractAddress).updateUserQualification(wallet, userLevel);
        }
    }

    /**
    Should approve allowance before initiating
    accepts depositAmount in WEI
    periodID - id of months array accordingly
    */
    function transferFromOldVersion(
        uint256 _depositAmount,
        uint8 _periodId,
        bool _isUnlocked,
        address _from,
        uint256 totalDepositValue
    ) public nonReentrant onlyWhitelistedContract {
        if (
            !ICommissionActivation(0x3E1240E879b4613C7Ae6eE1772292FC80B9c259e)
                .getCommissionActivation(_from, 3)
        ) {
            _activatePendingCommissions(_from);
        }

        UserInfo storage user = userInfo[_from];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;

        token.safeApprove(address(this), 0);
        token.safeApprove(address(this), _depositAmount);

        updatePool();

        uint256 lockTimesamp = DateTime.addMonths(block.timestamp, months[_periodId]);
        uint256 burnTokensAmount = 0;
        uint256 amountToDeposit = _depositAmount - burnTokensAmount;
        uint256 _ggymnetAmt = (amountToDeposit * ggymnetAlloc[_periodId]) / 1e18;

        if (_isUnlocked) {
            _ggymnetAmt = 0;
            totalGymnetUnlocked += amountToDeposit;
            lockTimesamp = DateTime.addSeconds(block.timestamp, months[_periodId]);
        }

        user.totalDepositTokens += amountToDeposit;
        user.totalDepositDollarValue += (totalDepositValue / 1e18);
        totalGymnetLocked += amountToDeposit;
        totalGGymnetInPoolLocked += _ggymnetAmt;

        uint256 rewardDebt = (_ggymnetAmt * (pool.accRewardPerShare)) / (1e18);
        UserDeposits memory depositDetails = UserDeposits({
            depositTokens: amountToDeposit,
            depositDollarValue: (totalDepositValue / 1e18),
            stakePeriod: _isUnlocked ? 0 : months[_periodId],
            depositTimestamp: block.timestamp,
            withdrawalTimestamp: lockTimesamp,
            rewardsGained: 0,
            is_finished: false,
            rewardsClaimt: 0,
            rewardDebt: rewardDebt,
            ggymnetAmt: _ggymnetAmt,
            is_unlocked: _isUnlocked
        });
        user_deposits[_from].push(depositDetails);
        user.totalGGYMNET += _ggymnetAmt;
        user.depositId = user_deposits[_from].length;


         IGymMLM(relationship).distributeCommissions(_ggymnetAmt, 0, 3, true, _from);
        refreshMyLevel(_from);
        emit Deposit(_from, amountToDeposit, _periodId);
    }

    function _getPendingRewards(uint256 _depositId, address _user) private view returns (uint256) {
        UserDeposits storage depositDetails = user_deposits[_user][_depositId];
        PoolInfo storage pool = poolInfo;
        if (depositDetails.is_finished || depositDetails.is_unlocked) {
            return 0;
        }

        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 sharesTotal = totalGGymnetInPoolLocked;

        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 _multiplier = block.number - pool.lastRewardBlock;
            uint256 _reward = (_multiplier * getRewardPerBlock());
            _accRewardPerShare = _accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        }

        return
            (depositDetails.ggymnetAmt * _accRewardPerShare) / (1e18) - (depositDetails.rewardDebt);
    }
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Burnable is IERC20Upgradeable {
    function burn(uint256 _amount) external;

    function burnFrom(address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymLevelPool {
    function updateUserQualification(address _wallet, uint256 _level) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLM {
    function addGymMLM(address, uint256) external;

    function addGymMLMNFT(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;

    function distributeCommissions(
        uint256,
        uint256,
        uint256,
        bool,
        address
    ) external;

    function updateInvestment(address _user, bool _isInvesting) external;

    function getPendingRewards(address, uint32) external view returns (uint256);

    function hasInvestment(address) external view returns (bool);

    function addressToId(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLMQualifications {
    struct RockstarLevel {
        uint64 qualificationLevel;
        uint64 usdAmountVault;
        uint64 usdAmountFarm;
        uint64 usdAmountPool;
    }

    function addDirectPartner(address, address) external;

    function getUserCurrentLevel(address) external view returns (uint32);

    function directPartners(address) external view returns (address[] memory);

    function getRockstarAmount(uint32 _rank) external view returns (RockstarLevel memory);

    function updateRockstarRank(
        address,
        uint8,
        bool
    ) external;

    function getDirectPartners(address) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGYMNETWORK {
    function getGYMNETPrice() external view returns (uint256);

    function getBNBPrice() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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
pragma solidity 0.8.15;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external;

    function balanceOf(address dst) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract RewardRateConfigurable is Initializable {
    struct RewardsConfiguration {
        uint256 rewardPerBlock;
        uint256 lastUpdateBlockNum;
        uint256 updateBlocksInterval;
    }

    uint256 public constant REWARD_PER_BLOCK_MULTIPLIER = 967742;
    uint256 public constant DIVIDER = 1e6;

    RewardsConfiguration private rewardsConfiguration;

    event RewardPerBlockUpdated(uint256 oldValue, uint256 newValue);

    function __RewardRateConfigurable_init(
        uint256 _rewardPerBlock,
        uint256 _rewardUpdateBlocksInterval
    ) internal onlyInitializing {
        __RewardRateConfigurable_init_unchained(_rewardPerBlock, _rewardUpdateBlocksInterval);
    }

    function __RewardRateConfigurable_init_unchained(
        uint256 _rewardPerBlock,
        uint256 _rewardUpdateBlocksInterval
    ) internal onlyInitializing {
        rewardsConfiguration.rewardPerBlock = _rewardPerBlock;
        rewardsConfiguration.lastUpdateBlockNum = block.number;
        rewardsConfiguration.updateBlocksInterval = _rewardUpdateBlocksInterval;
    }

    function getRewardsConfiguration() public view returns (RewardsConfiguration memory) {
        return rewardsConfiguration;
    }

    function getRewardPerBlock() public view returns (uint256) {
        return rewardsConfiguration.rewardPerBlock;
    }

    function _setRewardConfiguration(uint256 rewardPerBlock, uint256 updateBlocksInterval)
        internal
    {
        uint256 oldRewardValue = rewardsConfiguration.rewardPerBlock;

        rewardsConfiguration.rewardPerBlock = rewardPerBlock;
        rewardsConfiguration.lastUpdateBlockNum = block.number;
        rewardsConfiguration.updateBlocksInterval = updateBlocksInterval;

        emit RewardPerBlockUpdated(oldRewardValue, rewardPerBlock);
    }

    function _updateRewardPerBlock() internal {
        if (
            (block.number - rewardsConfiguration.lastUpdateBlockNum) <
            rewardsConfiguration.updateBlocksInterval
        ) {
            return;
        }

        uint256 rewardPerBlockOldValue = rewardsConfiguration.rewardPerBlock;

        rewardsConfiguration.rewardPerBlock =
            (rewardPerBlockOldValue * REWARD_PER_BLOCK_MULTIPLIER) / DIVIDER;

        rewardsConfiguration.lastUpdateBlockNum = block.number;

        emit RewardPerBlockUpdated(rewardPerBlockOldValue, rewardsConfiguration.rewardPerBlock);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface INFTReflection {
    struct UserInfo {
        uint256 totalGgymnetAmt;
        uint256 rewardsClaimt;
        uint256 rewardDebt;
    }

    function pendingReward(address) external view returns (uint256);

    function updateUser(uint256, address) external;

    function updatePool(uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface ICommissionActivation {
    function activateCommissions(uint256, address) external;

    function getCommissionActivation(address, uint256) external view returns (bool);
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity 0.8.15;

interface IPancakeRouter01 {
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