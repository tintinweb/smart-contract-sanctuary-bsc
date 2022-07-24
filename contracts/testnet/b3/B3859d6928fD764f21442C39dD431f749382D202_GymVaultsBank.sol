// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IGymMLMQualifications.sol";
import "./interfaces/IGymSinglePool.sol";
import "./interfaces/IGymLevelPool.sol";
import "./interfaces/IGymNetwork.sol";
import "./interfaces/IBuyAndBurn.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IGymFarming.sol";
import "./interfaces/IGymMLM.sol";
import "./interfaces/IWETH.sol";
import "./RewardRateConfigurable.sol";

/**
 * @notice GymVaultsBank contract:
 * - Users can:
 *   # Deposit token
 *   # Deposit BNB
 *   # Withdraw assets
 */

contract GymVaultsBank is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    EIP712Upgradeable,
    RewardRateConfigurable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    string private constant SIGNING_DOMAIN = "VAULT_BANK";
    string private constant SIGNATURE_VERSION = "1";

    /**
     * @notice Struct for EIP712
     * @param userWallet: user address
     * @param salt: salt
     * @param signature: signature
     */
    struct SignatureMessage {
        address userWallet;
        uint256 salt;
        bytes signature;
    }

    /**
     * @notice Info of each user
     * @param shares: How many LP tokens the user has provided
     * @param rewardDebt: Reward debt. See explanation below
     * @dev Any point in time, the amount of UTACOs entitled to a user but is pending to be distributed is:
     *   amount = user.shares / sharesTotal * wantLockedTotal
     *   pending reward = (amount * pool.accRewardPerShare) - user.rewardDebt
     *   Whenever a user deposits or withdraws want tokens to a pool. Here's what happens:
     *   1. The pool's `accRewardPerShare` (and `lastStakeTime`) gets updated.
     *   2. User receives the pending reward sent to his/her address.
     *   3. User's `amount` gets updated.
     *   4. User's `rewardDebt` gets updated.
     */
    struct UserInfo {
        uint256 shares;
        uint256 rewardDebt;
        uint256 dollarValue;
    }
    /**
     * @notice Info of each pool
     * @param want: Address of want token contract
     * @param allocPoint: How many allocation points assigned to this pool. GYM to distribute per block
     * @param lastRewardBlock: Last block number that reward distribution occurs
     * @param accUTacoPerShare: Accumulated rewardPool per share, times 1e18
     * @param strategy: Address of strategy contract
     */
    struct PoolInfo {
        IERC20Upgradeable want;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        address strategy;
    }

    /// Percent of amount that will be sent to relationship contract
    uint256 public RELATIONSHIP_REWARD;
    uint256 public POOLS_REWARD;
    uint256 public BUY_AND_BURN_FEE;
    /// Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    /// Startblock number
    uint256 public startBlock;
    /// Amount for BNB buy and burn
    uint256 public buyAndBurnAmountBNB;
    /// Amount for BUSD buy and burn
    uint256 public buyAndBurnAmountBUSD;
    /// Reward token address
    address public rewardToken;
    /// Info of each pool.
    PoolInfo[] public poolInfo;

    address public farmingAddress;
    address public mlmAddress;
    address public wbnbAddress;
    address public busdAddress;
    address public buyAndBurnAddress;
    address public gymNetworkAddress;
    address public singlePoolAddress;
    address public levelPoolAddress;
    address public mlmQualificationsAddress;
    address public rewardsDistributorAddress;

    address private serviceSignerAddress;

    /// Info of each user that stakes want tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userInvestment;
    mapping(address => bool) public isEmailVerified;
    mapping(address => uint256) public termsOfConditionsTimeStamp;

    mapping(address => uint8) private rockstarRank;
    mapping(bytes => bool) private signatureUsed;
    /* ========== EVENTS ========== */

    event Initialized(address indexed executor, uint256 at);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed token, address indexed user, uint256 amount);
    event ClaimUserReward(address indexed user, address indexed affilate);

    function initialize(
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        address _gymToken,
        address _wbnbAddress,
        address _busdAddress,
        address _buyAndBurnAddress,
        address _mlmAddress,
        address _farmingAddress,
        address _singlePoolAddress,
        address _levelPoolAddress,
        address _mlmQualificationsAddress,
        address _rewardsDistributorAddress
    ) external initializer {
        require(block.number < _startBlock, "GymVaultsBank: Start block must have a bigger value");
        startBlock = _startBlock;
        RELATIONSHIP_REWARD = 39;
        POOLS_REWARD = 6;
        BUY_AND_BURN_FEE = 4;
        rewardToken = _gymToken;
        farmingAddress = _farmingAddress;
        mlmAddress = _mlmAddress;
        wbnbAddress = _wbnbAddress;
        busdAddress = _busdAddress;
        buyAndBurnAddress = _buyAndBurnAddress;
        gymNetworkAddress = _gymToken;
        singlePoolAddress = _singlePoolAddress;
        levelPoolAddress = _levelPoolAddress;
        mlmQualificationsAddress = _mlmQualificationsAddress;
        rewardsDistributorAddress = _rewardsDistributorAddress;

        __Ownable_init();
        __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
        __ReentrancyGuard_init();
        __RewardRateConfigurable_init(_rewardPerBlock, 864000);

        emit Initialized(msg.sender, block.number);
    }

    modifier onlyEmailVerified(address _user) {
        require(isEmailVerified[_user], "GymVaultsBank:: Only users with verified email");
        _;
    }

    modifier onlyMLM() {
        require(msg.sender == mlmAddress, "GymVaultBank:: Only MLM contract can call the method");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function setRewardConfiguration(
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _rewardUpdateBlocksInterval
    ) external onlyOwner {
        rewardToken = _rewardToken;

        _setRewardConfiguration(_rewardPerBlock, _rewardUpdateBlocksInterval);
    }

    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;
    }

    function setGymNetworkAddress(address _address) external onlyOwner {
        gymNetworkAddress = _address;
    }

    function setMLMAddress(address _address) external onlyOwner {
        mlmAddress = _address;
    }

    function setBuyAndBurnAddress(address _address) external onlyOwner {
        buyAndBurnAddress = _address;
    }

    function setWBNBAddress(address _address) external onlyOwner {
        wbnbAddress = _address;
    }

    function setBUSDAddress(address _address) external onlyOwner {
        busdAddress = _address;
    }

    function setFarmingAddress(address _address) external onlyOwner {
        farmingAddress = _address;
    }

    function setSinglePoolAddress(address _address) external onlyOwner {
        singlePoolAddress = _address;
    }

    function setLevelPoolAddress(address _levelPoolAddress) external onlyOwner {
        levelPoolAddress = _levelPoolAddress;
    }

    function setMLMQualificationsAddress(address _address) external onlyOwner {
        mlmQualificationsAddress = _address;
    }

    function setServiceSignerAddress(address _address) external onlyOwner {
        serviceSignerAddress = _address;
    }

    function setRewardsDistributorAddress(address _address) external onlyOwner {
        rewardsDistributorAddress = _address;
    }

    /**
     * @notice Function to set terms of conditions timestamp
     * @param _user: user address
     */
    function updateTermsOfConditionsTimestamp(address _user) external onlyMLM {
        termsOfConditionsTimeStamp[_user] = block.timestamp;
    }

    /**
     * @notice Function to verify user email
     * @param signatureMessage: SignatureMessage
     */
    function verifyEmail(SignatureMessage calldata signatureMessage) external {
        require(!signatureUsed[signatureMessage.signature], "GymVaultBank:: Already claimed");
        address _messageSigner = _verify(signatureMessage);

        require(msg.sender == signatureMessage.userWallet, "GymVaultBank:: Invalid reward");
        require(_messageSigner == serviceSignerAddress, "GymVaultBank:: Invalid signer");

        isEmailVerified[signatureMessage.userWallet] = true;

        signatureUsed[signatureMessage.signature] = true;
    }

    /**
     * @notice Update the given pool's reward allocation point. Can only be called by the owner
     * @param _pid: Pool id that will be updated
     * @param _allocPoint: New allocPoint for pool
     */
    function setPoolAllocationPoint(uint256 _pid, uint256 _allocPoint) external onlyOwner {
        massUpdatePools();
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /**
     * @notice Update the given pool's strategy. Can only be called by the owner
     * @param _pid: Pool id that will be updated
     * @param _strategy: New strategy contract address for pool
     */
    function resetStrategy(uint256 _pid, address _strategy) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        require(
            pool.want.balanceOf(pool.strategy) == 0 || pool.accRewardPerShare == 0,
            "GymVaultsBank: Strategy not empty"
        );
        pool.strategy = _strategy;
    }

    /**
     * @notice Function to Add pool
     * @param _want: Address of want token contract
     * @param _allocPoint: AllocPoint for new pool
     * @param _withUpdate: If true will call massUpdatePools function
     * @param _strategy: Address of Strategy contract
     */
    function addPool(
        IERC20Upgradeable _want,
        uint256 _allocPoint,
        bool _withUpdate,
        address _strategy
    ) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                want: _want,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0,
                strategy: _strategy
            })
        );
    }

    /**
     * @notice Function to activate Rockstar Rank
     * @param _pid: Pool id that will be updated
     * @param _rank: rank (0-2)
     * @param _amount: amount of tokens
     */
    function activateRockstarRank(
        uint256 _pid,
        uint8 _rank,
        uint256 _amount
    ) external {
        require(
            termsOfConditionsTimeStamp[msg.sender] + 2419200 < block.timestamp &&
                rockstarRank[msg.sender] < _rank + 1,
            "GymVaultsBank:: This action is not active"
        );

        uint256 _rockstarAmount = IGymMLMQualifications(mlmQualificationsAddress)
            .getRockstarAmount(_rank)
            .usdAmountVault;

        require(
            _amount >= (_rockstarAmount * BUY_AND_BURN_FEE) / 100,
            "GymVaultsBank:: Not enough money"
        );
        PoolInfo memory pool = poolInfo[_pid];

        _buyAndBurn(address(pool.want), _amount);

        rockstarRank[msg.sender] = _rank;

        IGymMLMQualifications(mlmQualificationsAddress).updateRockstarRank(msg.sender, _rank, true);
    }

    /**
     * @notice Migrates all assets to new strategy. Can only be called by the owner
     * @param _pid: Pool id that will be updated
     * @param _newStrategy: New strategy contract address for pool
     */
    function migrateStrategy(uint256 _pid, address _newStrategy) external onlyOwner {
        require(
            IStrategy(_newStrategy).wantLockedTotal() == 0 &&
                IStrategy(_newStrategy).sharesTotal() == 0,
            "GymVaultsBank: New strategy not empty"
        );
        PoolInfo storage pool = poolInfo[_pid];
        address _oldStrategy = pool.strategy;
        uint256 _oldSharesTotal = IStrategy(_oldStrategy).sharesTotal();
        uint256 _oldWantAmt = IStrategy(_oldStrategy).wantLockedTotal();
        IStrategy(_oldStrategy).withdraw(address(this), _oldWantAmt);
        require(pool.want.transfer(_newStrategy, _oldWantAmt), "GymVaulstBank:: Transfer failed");
        IStrategy(_newStrategy).migrateFrom(_oldStrategy, _oldWantAmt, _oldSharesTotal);
        pool.strategy = _newStrategy;
    }

    /**
     * @notice Deposit in given pool
     * @param _pid: Pool id
     * @param _wantAmt: Amount of want token that user wants to deposit
     * @param _referrerId: Referrer address
     */
    function deposit(
        uint256 _pid,
        uint256 _wantAmt,
        uint256 _referrerId
    ) external payable onlyEmailVerified(msg.sender) {
        require(
            _wantAmt == 0 || msg.value == 0,
            "GymVaultsBank:: Cannot pass both BNB and BEP-20 assets"
        );

        IGymMLM(mlmAddress).addGymMLM(msg.sender, _referrerId);
        PoolInfo memory pool = poolInfo[_pid];

        if (address(pool.want) == wbnbAddress && _wantAmt == 0) {
            // If `want` is WBNB
            IWETH(wbnbAddress).deposit{value: msg.value}();
            _wantAmt = msg.value;
        }

        _deposit(_pid, _wantAmt);
        _updateLevelPoolQualification(msg.sender);
    }

    function claimAndDepositSinglePool(
        uint256 _pid,
        bool _isUnlocked,
        uint8 _periodId
    ) external onlyEmailVerified(msg.sender) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = (user.shares * pool.accRewardPerShare) / (1e18) - (user.rewardDebt);
        if (pending > 0) {
            uint256 _distributedRewards = _distributeRewards(pending, rewardToken, msg.sender);

            IERC20Upgradeable(rewardToken).approve(
                singlePoolAddress,
                (pending - _distributedRewards)
            );
            IERC20Upgradeable(rewardToken).safeTransfer(
                singlePoolAddress,
                (pending - _distributedRewards)
            );

            IGymSinglePool(singlePoolAddress).depositFromOtherContract(
                (pending - _distributedRewards),
                _periodId,
                _isUnlocked,
                msg.sender
            );
        }
        user.rewardDebt = (user.shares * (pool.accRewardPerShare)) / (1e18);
    }

    /**
     * @notice Claim users rewards and add deposit in Farming contract
     * @param _pid: pool Id
     */
    function claimAndDepositFarming(
        uint256 _pid,
        uint256 _amountTokenMin,
        uint256 _amountETHMin,
        uint256 _minAmountOut,
        uint256 _deadline
    ) external payable onlyEmailVerified(msg.sender) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = (user.shares * pool.accRewardPerShare) / (1e18) - (user.rewardDebt);
        if (pending > 0) {
            uint256 _distributedRewards = _distributeRewards(pending, rewardToken, msg.sender);

            IERC20Upgradeable(rewardToken).approve(farmingAddress, (pending - _distributedRewards));
            IGymFarming(farmingAddress).depositFromOtherContract{value: msg.value}(
                0,
                address(pool.want) == busdAddress ? (pending - _distributedRewards) : 0,
                address(pool.want) == wbnbAddress ? (pending - _distributedRewards) : 0,
                _amountTokenMin,
                _amountETHMin,
                _minAmountOut,
                msg.sender,
                _deadline
            );
        }
        user.rewardDebt = (user.shares * (pool.accRewardPerShare)) / (1e18);
    }

    /**
     * @notice Withdraw user`s assets
     */
    function withdraw(uint256 _pid) external nonReentrant onlyEmailVerified(msg.sender) {
        _withdraw(_pid);

        IGymMLM(mlmAddress).updateInvestment(msg.sender, false);
        _updateLevelPoolQualification(msg.sender);
    }

    /**
     * @notice Claim users rewards from all pools
     */
    function claimAll() external onlyEmailVerified(msg.sender) {
        uint256 length = _getPoolLength();
        for (uint256 i = 0; i <= length - 1; i++) {
            claim(i);
        }
    }

    /**
     * @notice Function to buy and Burn tokens from selected pool
     * @param _pid: Pool id where user has assets
     */
    function buyBurnTokens(uint256 _pid) external onlyOwner {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 burnableAmount = 0;
        if (address(pool.want) == wbnbAddress) {
            burnableAmount = buyAndBurnAmountBNB;
        } else {
            burnableAmount = buyAndBurnAmountBUSD;
        }

        _buyAndBurn(address(pool.want), burnableAmount);
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _pid: Pool id where user has assets
     * @param _user: Users address
     */
    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 sharesTotal = IStrategy(pool.strategy).sharesTotal();
        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 _multiplier = block.number - pool.lastRewardBlock;
            uint256 _reward = (_multiplier * getRewardPerBlock() * pool.allocPoint) /
                totalAllocPoint;
            _accRewardPerShare = _accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        }
        return (user.shares * _accRewardPerShare) / 1e18 - user.rewardDebt;
    }

    /**
     * @notice View function to see staked Want tokens on frontend.
     * @param _pid: Pool id where user has assets
     * @param _user: Users address
     */
    function stakedWantTokens(uint256 _pid, address _user) external view returns (uint256) {
        return _getStakedWantTokens(_pid, _user);
    }

    /**
     * @notice View function to see Affilates BNB share from a user.
     * @param _pid: Pool id where user has assets
     * @param _user: Users address
     */
    function stakedWantTokensAffilate(uint256 _pid, address _user) external view returns (uint256) {
        uint256 userBalance = _getStakedWantTokens(_pid, _user);
        uint256 investment = userInvestment[_pid][_user];
        return ((userBalance - investment) * 45) / 100;
    }

    /**
     * @notice View function to get user investment
     * @param _user: User address
     */
    function getUserInvestment(address _user) external view returns (bool) {
        return _checkUserInvestment(_user);
    }

    /**
     * @notice View function to get user deposit in dollar value
     * @param _user: User address
     */
    function getUserDepositDollarValue(address _user) external view returns (uint256 _userDeposit) {
        uint256 length = _getPoolLength();
        for (uint256 i = 0; i <= length - 1; i++) {
            _userDeposit += userInfo[i][_user].dollarValue;
        }
    }

    /**
     * @notice Claim users rewards from given pool
     * @param _pid pool Id
     */
    function claim(uint256 _pid) public onlyEmailVerified(msg.sender) {
        updatePool(_pid);
        _claim(_pid, msg.sender);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        user.rewardDebt = (user.shares * (pool.accRewardPerShare)) / (1e18);
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     * @param _pid: Pool id that will be updated
     */
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        _updateRewardPerBlock();
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 sharesTotal = IStrategy(pool.strategy).sharesTotal();
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        if (multiplier <= 0) {
            return;
        }
        uint256 _rewardPerBlock = getRewardPerBlock();
        uint256 _reward = (multiplier * _rewardPerBlock * pool.allocPoint) / totalAllocPoint;
        pool.accRewardPerShare = pool.accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        pool.lastRewardBlock = block.number;
    }

    /**
     * @notice Update reward variables for all pools. Be careful of gas spending!
     */
    function massUpdatePools() public {
        uint256 length = _getPoolLength();
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
     * @notice  Safe transfer function for reward tokens
     * @param _rewardToken Address of reward token contract
     * @param _to Address of receiver
     * @param _amount Amount of reward tokens to transfer
     */
    function _safeRewardTransfer(
        address _rewardToken,
        address _to,
        uint256 _amount
    ) private {
        uint256 _bal = IERC20Upgradeable(_rewardToken).balanceOf(address(this));
        if (_amount > _bal) {
            require(
                IERC20Upgradeable(_rewardToken).transfer(_to, _bal),
                "GymVaulstBank:: Transfer failed"
            );
        } else {
            require(
                IERC20Upgradeable(_rewardToken).transfer(_to, _amount),
                "GymVaulstBank:: Transfer failed"
            );
        }
    }

    /**
     * @notice Calculates amount of reward user will get.
     * @param _pid: Pool id
     */
    function _claim(uint256 _pid, address _user) private {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 pending = (user.shares * pool.accRewardPerShare) / (1e18) - (user.rewardDebt);
        if (pending > 0) {
            uint256 _distributedRewards = _distributeRewards(pending, rewardToken, _user);

            _safeRewardTransfer(rewardToken, _user, (pending - _distributedRewards));
            emit RewardPaid(rewardToken, _user, pending);
        }
    }

    /**
     * @notice Private deposit function
     * @param _pid: Pool id
     * @param _wantAmt: Amount of want token that user wants to deposit
     */
    function _deposit(uint256 _pid, uint256 _wantAmt) private {
        updatePool(_pid);
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.shares > 0) {
            _claim(_pid, msg.sender);
        }

        if (_wantAmt > 0) {
            if (address(pool.want) == busdAddress) {
                user.dollarValue += (_wantAmt / 1e18);
            } else if (address(pool.want) == wbnbAddress) {
                user.dollarValue += (_wantAmt * IGYMNETWORK(gymNetworkAddress).getBNBPrice() / 1e18);
            }

            pool.want.safeIncreaseAllowance(pool.strategy, _wantAmt);
            uint256 sharesAdded = IStrategy(poolInfo[_pid].strategy).deposit(msg.sender, _wantAmt);
            user.shares += sharesAdded;
            userInvestment[_pid][msg.sender] += _wantAmt;

            _updateInvestment(msg.sender);

            user.rewardDebt = (user.shares * (pool.accRewardPerShare)) / (1e18);

            emit Deposit(msg.sender, _pid, _wantAmt);
        }
    }

    /**
     * @notice Private distribute rewards function
     * @param _amount: Amount of token
     * @param _token: token address
     * @param _user: user address
     */
    function _distributeRewards(
        uint256 _amount,
        address _token,
        address _user
    ) private returns (uint256) {
        uint256 _mlmRewards = (_amount * RELATIONSHIP_REWARD) / 100;
        uint256 _poolsRewards = (_amount * POOLS_REWARD) / 100;
        IERC20Upgradeable(_token).safeTransfer(rewardsDistributorAddress, _poolsRewards);
        IERC20Upgradeable(_token).safeTransfer(mlmAddress, _mlmRewards);
        // Distribute MLM rewards
        IGymMLM(mlmAddress).distributeRewards(_amount, _token, _user, 1);

        return _mlmRewards + _poolsRewards;
    }

    /**
     * @notice Private withdraw function
     * @param _pid: Pool id
     */
    function _withdraw(uint256 _pid) private {
        updatePool(_pid);

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = _getStakedWantTokens(_pid, msg.sender);
        uint256 investment = userInvestment[_pid][msg.sender];
        require(investment > 0, "GymVaultsBank: user amount is 0");
        require(amount > 0, "GymVaultsBank: user amount is 0");

        _claim(_pid, msg.sender);
        if (address(pool.want) == wbnbAddress) {
            buyAndBurnAmountBNB += (amount - investment);
        } else if (address(pool.want) == busdAddress) {
            buyAndBurnAmountBUSD += (amount - investment);
        }

        user.shares = 0;
        user.dollarValue = 0;
        userInvestment[_pid][msg.sender] = 0;

        IStrategy(poolInfo[_pid].strategy).withdraw(msg.sender, investment);
        IERC20Upgradeable(address(pool.want)).safeTransfer(msg.sender, investment);
        user.rewardDebt = (user.shares * (pool.accRewardPerShare)) / (1e18);
        emit Withdraw(msg.sender, _pid, investment);
    }

    function _updateLevelPoolQualification(address wallet) private {
        uint256 userLevel = IGymMLMQualifications(mlmQualificationsAddress).getUserCurrentLevel(
            wallet
        );
        IGymLevelPool(levelPoolAddress).updateUserQualification(wallet, userLevel);
    }

    /**
     * @notice Private function to buy and burn tokens
     * @param _address: token address
     * @param _amount: amount
     */
    function _buyAndBurn(address _address, uint256 _amount) private {
        IERC20Upgradeable(_address).safeTransfer(buyAndBurnAddress, _amount);
        IBuyAndBurn(buyAndBurnAddress).buyAndBurnToken(
            _address,
            _amount,
            gymNetworkAddress,
            uint256(0),
            uint256(block.timestamp + 100)
        );
    }

    /**
     * @notice View function to see staked Want tokens on frontend.
     * @param _pid: Pool id where user has assets
     * @param _user: Users address
     */
    function _getStakedWantTokens(uint256 _pid, address _user) private view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];

        uint256 sharesTotal = IStrategy(pool.strategy).sharesTotal();

        if (sharesTotal == 0) {
            return 0;
        }

        uint256 wantLockedTotal = IStrategy(poolInfo[_pid].strategy).wantLockedTotal();

        return (user.shares * wantLockedTotal) / sharesTotal;
    }

    function _getPoolLength() private view returns (uint256) {
        return poolInfo.length;
    }

    // /**
    //  * @notice View function to check user investment
    //  * @param _user: user address
    //  */
    function _checkUserInvestment(address _user) private view returns (bool) {
        uint256 length = _getPoolLength();
        for (uint256 i = 0; i <= length - 1; i++) {
            if (userInvestment[i][_user] != 0) {
                return true;
            }
        }
        return false;
    }

    // /**
    //  * @notice Private function to update user investment
    //  * @param _user: user address
    //  */
    function _updateInvestment(address _user) private {
        bool _isUserInvest = _checkUserInvestment(_user);
        if (!_isUserInvest) {
            IGymMLM(mlmAddress).updateInvestment(msg.sender, true);
        }
    }

    /**
     * @notice Private function to verify
     * @param signatureMessage: SignatureMessage
     */
    function _verify(SignatureMessage calldata signatureMessage) private view returns (address) {
        bytes32 _digest = _hash(signatureMessage);
        return ECDSAUpgradeable.recover(_digest, signatureMessage.signature);
    }

    /**
     * @notice Private function to return hash
     * @param signatureMessage: SignatureMessage
     */
    function _hash(SignatureMessage calldata signatureMessage) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("SignatureMessage(address userWallet,uint256 salt)"),
                        signatureMessage.userWallet,
                        signatureMessage.salt
                    )
                )
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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

    function getDirectPartners(address) external view returns (address[] memory);

    function getRockstarAmount(uint32 _rank) external view returns (RockstarLevel memory);

    function updateRockstarRank(
        address,
        uint8,
        bool
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymSinglePool {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 totalGGYMNET;
        uint256 level;
        uint256 depositId;
        uint256 totalClaimt;
    }

    function getUserInfo(address) external view returns (UserInfo memory);

    function pendingReward(uint256, address) external view returns (uint256);

    function getUserLevelInSinglePool(address) external view returns (uint32);

    function depositFromOtherContract(
        uint256,
        uint8,
        bool,
        address
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymLevelPool {
    function updateUserQualification(address _wallet, uint256 _level) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGYMNETWORK {
    function getGYMNETPrice() external view returns (uint256);

    function getBNBPrice() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBuyAndBurn {
    function buyAndBurnToken(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IStrategy {
    // Total want tokens managed by strategy
    function wantLockedTotal() external view returns (uint256);

    // Sum of all shares of users to wantLockedTotal
    function sharesTotal() external view returns (uint256);

    function wantAddress() external view returns (address);

    function token0Address() external view returns (address);

    function token1Address() external view returns (address);

    function earnedAddress() external view returns (address);

    function ratio0() external view returns (uint256);

    function ratio1() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);

    // Main want token compounding function
    function earn(uint256 _amountOutAmt, uint256 _deadline) external;

    // Transfer want tokens autoFarm -> strategy
    function deposit(address _userAddress, uint256 _wantAmt) external returns (uint256);

    // Transfer want tokens strategy -> autoFarm
    function withdraw(address _userAddress, uint256 _wantAmt) external returns (uint256);

    function migrateFrom(
        address _oldStrategy,
        uint256 _oldWantLockedTotal,
        uint256 _oldSharesTotal
    ) external;

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymFarming {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    function getUserInfo(uint256, address) external view returns (UserInfo memory);

    function getUserUsdDepositAllPools(address) external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable;

    function pendingRewardTotal(address) external view returns (uint256 total);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLM {
    function addGymMLM(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;

    function updateInvestment(address _user, bool _isInvesting) external;

    function getPendingRewards(address, uint32) external view returns (uint256);

    function getReferrals(address) external view returns (address[] memory);
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
        if ((block.number - rewardsConfiguration.lastUpdateBlockNum) < rewardsConfiguration.updateBlocksInterval) {
            return;
        }

        uint256 rewardPerBlockOldValue = rewardsConfiguration.rewardPerBlock;

        rewardsConfiguration.rewardPerBlock =
            (rewardPerBlockOldValue * REWARD_PER_BLOCK_MULTIPLIER) /
            DIVIDER;

        rewardsConfiguration.lastUpdateBlockNum = block.number;

        emit RewardPerBlockUpdated(rewardPerBlockOldValue, rewardsConfiguration.rewardPerBlock);
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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