// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./interfaces/IBuyAndBurn.sol";
import "./interfaces/IGymLevelPool.sol";
import "./interfaces/IGymMLM.sol";
import "./interfaces/IGymMLMQualifications.sol";
import "./interfaces/IGymNetwork.sol";
import "./interfaces/IGymSinglePool.sol";
import "./interfaces/ILiquidityProvider.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IWETH.sol";

contract GymFarming is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice Info of each user
     * @param totalDepositTokens total amount of deposits in tokens
     * @param totalDepositDollarValue total amount of tokens converted to USD
     * @param lpTokensAmount: How many LP tokens the user has provided
     * @param rewardDebt: Reward debt. See explanation below
     */
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
    }

    /**
     * @notice Info of each pool
     * @param lpToken: Address of LP token contract
     * @param allocPoint: How many allocation points assigned to this pool. rewards to distribute per block
     * @param lastRewardBlock: Last block number that rewards distribution occurs
     * @param accRewardPerShare: Accumulated rewards per share, times 1e18. See below
     */
    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    /**
     * @notice Internal struct to transfer data between function calls
     * @param totalAddedInBaseToken total amount of tokens added to pool represented in base token
     * @param baseTokensAdded amount of base tokens added
     * @param gymnetTokensAdded amount of GYMNET tokens added
     * @param lpTokens total LP tokens
     */
    struct UserLiquidityData {
        uint256 totalAddedInBaseToken;
        uint256 baseTokensAdded;
        uint256 gymnetTokensAdded;
        uint256 lpTokens;
    }

    uint256 public constant MAX_COMISSION_PERCENT = 80;
    uint256 public constant BUY_BACK_COMMISION = 4;

    /// The reward token
    address public rewardToken;
    uint256 public rewardPerBlock;
    /// Info of each pool.
    PoolInfo[] public poolInfo;
    /// Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public isPoolExist;
    /// Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    /// The block number when reward mining starts.
    uint256 public startBlock;
    /// The Liquidity Provider
    address public liquidityProvider;
    uint256 public liquidityProviderApiId;
    address public bankAddress;
    address public routerAddress;
    address public wbnbAddress;
    address public treasury;
    address public buyAndBurnAddress;
    address[] public rewardTokenToWBNB;
    uint256 private rewardPerBlockChangesCount;
    uint256 private lastChangeBlock;
    uint256 public affilateComission;
    uint256 public poolComission;
    address public relationship;
    address public levelPool;
    address public mlmQualificationsAddress;
    address public busdAddress;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Provider(address oldProvider, uint256 oldApi, address newProvider, uint256 newApi);

    function initialize(
        address _buyAndBurnAddress,
        address _liquidityProviderAddress,
        address _bankAddress,
        address _rewardToken,
        address _wbnbAddress,
        address _busdAddress,
        address _routerAddress,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) public initializer {
        bankAddress = _bankAddress;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        rewardPerBlockChangesCount = 3;
        lastChangeBlock = _startBlock;
        buyAndBurnAddress = _buyAndBurnAddress;
        routerAddress = _routerAddress;
        wbnbAddress = _wbnbAddress;
        liquidityProvider = _liquidityProviderAddress;
        liquidityProviderApiId = 1;

        busdAddress = _busdAddress;

        rewardTokenToWBNB = [_rewardToken, wbnbAddress];

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "GymFarming: Zero address");
        _;
    }

    modifier poolExists(uint256 _pid) {
        require(_pid < poolInfo.length, "GymFarming: Unknown pool");
        _;
    }

    modifier onlyBank() {
        require(msg.sender == bankAddress, "GymFarming: Only bank");
        _;
    }

    modifier validComission(uint256 commission) {
        require(commission < MAX_COMISSION_PERCENT, "GymFarming: Max comission 80%");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @notice Function to set reward token
     * @param _rewardToken: address of reward token
     */
    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
        rewardTokenToWBNB = [_rewardToken, wbnbAddress];
    }

    function setMLMAddress(address _address) external onlyOwner validAddress(_address) {
        relationship = _address;
    }

    function setLevelPoolAddress(address _levelPoolAddress)
        external
        onlyOwner
        validAddress(_levelPoolAddress)
    {
        levelPool = _levelPoolAddress;
    }

    /**
     * @notice Function to set treasury
     * @param _newTreasury: new treasury address
     */
    function setTreasuryAddress(address _newTreasury)
        external
        onlyOwner
        validAddress(_newTreasury)
    {
        treasury = _newTreasury;
    }

    function setMLMQualificationsAddress(address _address)
        external
        onlyOwner
        validAddress(_address)
    {
        mlmQualificationsAddress = _address;
    }

    function setBUSDAddress(address _address) external onlyOwner validAddress(_address) {
        busdAddress = _address;
    }

    function setWBNBAddress(address _address) external onlyOwner validAddress(_address) {
        wbnbAddress = _address;

        rewardTokenToWBNB[1] = _address;
    }

    function setRouterAddress(address _address) external onlyOwner validAddress(_address) {
        routerAddress = _address;
    }

    function setBuyAndBurnAddress(address _address) external onlyOwner validAddress(_address) {
        buyAndBurnAddress = _address;
    }

    function setLiquidityProviderAddress(address _address)
        external
        onlyOwner
        validAddress(_address)
    {
        liquidityProvider = _address;
    }

    /**
     * @notice Function to set comission on claim
     * @param _comission: value between 0 and 80
     */
    function setAffilateComission(uint256 _comission)
        external
        onlyOwner
        validComission(_comission)
    {
        affilateComission = _comission;
    }

    /**
     * @notice Function to set comission on claim
     * @param _comission: value between 0 and 80
     */
    function setPoolComission(uint256 _comission) external onlyOwner validComission(_comission) {
        poolComission = _comission;
    }

    /**
     * @notice Function to set amount of reward per block
     */
    function setRewardPerBlock() external nonReentrant {
        massUpdatePools();

        if (block.number - lastChangeBlock > 20 && rewardPerBlockChangesCount > 0) {
            rewardPerBlock = (rewardPerBlock * 967742000000) / 1e12;
            rewardPerBlockChangesCount -= 1;
            lastChangeBlock = block.number;
        }
    }

    /**
     * @notice Add a new lp to the pool. Can only be called by the owner
     * @param _allocPoint: allocPoint for new pool
     * @param _lpToken: address of lpToken for new pool
     * @param _withUpdate: if true, update all pools
     */
    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external onlyOwner {
        require(!isPoolExist[address(_lpToken)], "GymFarming: Duplicate pool");
        require(_isSupportedLP(_lpToken), "GymFarming: Unsupported liquidity pool");

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint += _allocPoint;

        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0
            })
        );

        isPoolExist[address(_lpToken)] = true;
    }

    /**
     * @notice Update the given pool's reward allocation point. Can only be called by the owner
     */
    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner poolExists(_pid) {
        massUpdatePools();

        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /**
     * @notice Deposit LP tokens to GymFarming for reward allocation
     * @param _pid: pool ID on which LP tokens should be deposited
     * @param _amount: the amount of LP tokens that should be deposited
     */
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant poolExists(_pid) {
        updatePool(_pid);

        IERC20Upgradeable(poolInfo[_pid].lpToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        UserLiquidityData memory liquidityData;
        liquidityData.lpTokens = _amount;

        _updateUserInfo(_pid, msg.sender, liquidityData);

        emit Deposit(msg.sender, _pid, liquidityData.lpTokens);
    }

    /**
     * @notice Function which take ETH & tokens or tokens & tokens, add liquidity with provider and deposit given LP's
     * @param _pid: pool ID where we want deposit
     * @param _baseTokenAmount: amount of token pool base token for staking (used for BUSD, use 0 for BNB pool)
     * @param _gymnetTokenAmount: amount of GYMNET token for staking
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOutA: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _deadline transaction deadline timestamp
     * @param _minBurnAmt minimum amount of tokens to be burnt
     */
    function speedStake(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _gymnetTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOutA,
        uint256 _deadline,
        uint256 _minBurnAmt
    ) external payable poolExists(_pid) nonReentrant {
        require(
            _baseTokenAmount == 0 || msg.value == 0,
            "GymFarming: Cannot pass both BNB and BEP-20 assets"
        );

        updatePool(_pid);

        if (_gymnetTokenAmount > 0) {
            IERC20Upgradeable(rewardToken).safeTransferFrom(
                msg.sender,
                address(this),
                _gymnetTokenAmount
            );
        }

        _deposit(
            _pid,
            _baseTokenAmount,
            _gymnetTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOutA,
            _deadline,
            _minBurnAmt,
            true
        );
    }

    /**
     * @notice Claim accumulated GYMNET token rewards and deposit them 
        along with pool base token
     * @param _pid pool id
     * @param _baseTokenAmount pool base token amount to deposit
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOutA: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _deadline transaction deadline timestamp
     * @param _minBurnAmt minimum amount of tokens to be burnt
     */
    function claimAndDeposit(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOutA,
        uint256 _deadline,
        uint256 _minBurnAmt
    ) external payable poolExists(_pid) {
        require(
            _baseTokenAmount == 0 || msg.value == 0,
            "GymFarming: Cannot pass both BNB and BEP-20 assets"
        );

        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 gymnetTokenAmount = 0;

        if (user.lpTokensAmount > 0) {
            updatePool(_pid);

            uint256 accRewardPerShare = poolInfo[_pid].accRewardPerShare;

            gymnetTokenAmount = (user.lpTokensAmount * accRewardPerShare) / 1e18 - user.rewardDebt;
            user.rewardDebt = (user.lpTokensAmount * accRewardPerShare) / 1e18;
        }

        _deposit(
            _pid,
            _baseTokenAmount,
            gymnetTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOutA,
            _deadline,
            _minBurnAmt,
            false
        );
    }

    /**
     * @notice Deposit LP tokens to GymFarming from GymVaultsBank
     * @param _pid: pool ID on which LP tokens should be deposited
     * @param _baseTokenAmount: the amount of pool base tokens provided by user
     * @param _gymnetTokenAmount: the amount of reward tokens that should be converted to LP tokens
        and deposits to GymFarming contract
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOut: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _from: Address of user that called function from GymVaultsBank
     * @param _deadline transaction deadline timestamp
     */
    function depositFromOtherContract(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _gymnetTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOut,
        address _from,
        uint256 _deadline
    ) external payable poolExists(_pid) onlyBank {
        require(
            _baseTokenAmount == 0 || msg.value == 0,
            "GymFarming: Cannot pass both BNB and BEP-20 assets"
        );

        IPancakeswapPair lpToken = IPancakeswapPair(poolInfo[_pid].lpToken);
        UserLiquidityData memory liquidityData;

        bool isBnbPool = _isBnbPool(lpToken);
        address poolBaseToken = _getPoolBaseTokenFromPair(lpToken);
        uint256 poolBaseTokenAmount = 0;

        updatePool(_pid);

        if (_gymnetTokenAmount > 0) {
            IERC20Upgradeable(rewardToken).safeTransferFrom(
                msg.sender,
                address(this),
                _gymnetTokenAmount
            );
            IERC20Upgradeable(rewardToken).approve(routerAddress, _gymnetTokenAmount);

            liquidityData.gymnetTokensAdded = _gymnetTokenAmount;
        }

        if (_baseTokenAmount > 0) {
            IERC20Upgradeable(poolBaseToken).safeTransferFrom(
                msg.sender,
                address(this),
                _baseTokenAmount
            );
            IERC20Upgradeable(poolBaseToken).approve(routerAddress, _baseTokenAmount);

            liquidityData.baseTokensAdded = _baseTokenAmount;
        }

        if (isBnbPool) {
            uint256 contractBalance = address(this).balance - msg.value;

            IPancakeRouter02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
                _gymnetTokenAmount,
                _amountBMin,
                rewardTokenToWBNB,
                address(this),
                _deadline
            );

            poolBaseTokenAmount = address(this).balance - contractBalance;
        } else {
            address[] memory path = new address[](2);

            path[0] = rewardToken;
            path[1] = poolBaseToken;

            IPancakeRouter02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _gymnetTokenAmount,
                _amountBMin,
                path,
                address(this),
                _deadline
            );

            poolBaseTokenAmount = IERC20Upgradeable(poolBaseToken).balanceOf(address(this));
        }

        liquidityData.totalAddedInBaseToken = poolBaseTokenAmount;

        liquidityData.lpTokens = _addLiquidity(
            lpToken,
            poolBaseToken,
            poolBaseTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOut,
            _deadline
        );

        _updateUserInfo(_pid, _from, liquidityData);

        emit Deposit(_from, _pid, liquidityData.lpTokens);
    }

    /**
     * @notice Function which send accumulated reward tokens to messege sender
     * @param _pid: pool ID from which the accumulated reward tokens should be received
     */
    function harvest(uint256 _pid) external nonReentrant poolExists(_pid) {
        _harvest(_pid, msg.sender);
    }

    /**
     * @notice Function which send accumulated reward tokens to messege sender from all pools
     */
    function harvestAll() external nonReentrant {
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            if (poolInfo[pid].allocPoint > 0) {
                _harvest(pid, msg.sender);
            }
        }
    }

    /**
     * @notice Function which withdraw LP tokens to messege sender with the given amount
     * @param _pid: pool ID from which the LP tokens should be withdrawn
     */
    function withdraw(uint256 _pid) external nonReentrant poolExists(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 withdrawAmount = user.lpTokensAmount;

        updatePool(_pid);

        uint256 pending = (withdrawAmount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;

        safeRewardTransfer(msg.sender, pending);

        emit Harvest(msg.sender, _pid, pending);

        user.lpTokensAmount = 0;
        user.rewardDebt = 0;
        user.totalDepositTokens = 0;
        user.totalDepositDollarValue = 0;

        IERC20Upgradeable(pool.lpToken).safeTransfer(address(msg.sender), withdrawAmount);

        _updateLevelPoolQualification(msg.sender);

        emit Withdraw(msg.sender, _pid, withdrawAmount);
    }

    /// @return All pools amount
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     * @notice View function to see total pending rewards on frontend
     * @param _user: user address for which reward must be calculated
     * @return total Return reward for user
     */
    function pendingRewardTotal(address _user) external view returns (uint256 total) {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            total += pendingReward(pid, _user);
        }
    }

    function getUserInfo(uint256 _pid, address _user)
        external
        view
        poolExists(_pid)
        returns (UserInfo memory)
    {
        return userInfo[_pid][_user];
    }

    /**
     * @notice Get USD amount of user deposits in all farming pools
     * @param _user user address
     * @return uint256 total amount in USD
     */
    function getUserUsdDepositAllPools(address _user) external view returns (uint256) {
        uint256 usdDepositAllPools = 0;

        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            usdDepositAllPools += userInfo[pid][_user].totalDepositDollarValue;
        }

        return usdDepositAllPools;
    }

    /**
     * @notice Update reward vairables for all pools
     */
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date
     * @param _pid: pool ID for which the reward variables should be updated
     */
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = IERC20Upgradeable(pool.lpToken).balanceOf(address(this));

        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = (multiplier * pool.allocPoint) / totalAllocPoint;

        pool.accRewardPerShare = pool.accRewardPerShare + ((reward * 1e18) / lpSupply);
        pool.lastRewardBlock = block.number;
    }

    /**
     * @param _from: block block from which the reward is calculated
     * @param _to: block block before which the reward is calculated
     * @return Return reward multiplier over the given _from to _to block
     */
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return (rewardPerBlock * (_to - _from));
    }

    /**
     * @notice View function to see pending rewards on frontend
     * @param _pid: pool ID for which reward must be calculated
     * @param _user: user address for which reward must be calculated
     * @return Return reward for user
     */
    function pendingReward(uint256 _pid, address _user)
        public
        view
        poolExists(_pid)
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = IERC20Upgradeable(pool.lpToken).balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward = (multiplier * pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + ((reward * 1e18) / lpSupply);
        }

        return (user.lpTokensAmount * accRewardPerShare) / 1e18 - user.rewardDebt;
    }

    /**
     * @notice Contract private function to process user deposit.
        1. Transfe pool base tokens to this contract if _baseTokenAmount > 0
        2. Swap gymnet tokens for pool base token
        3. Buy and burn GYMNET using pool base token
        4. Provide liquidity using 50/50 split of pool base tokens:
            a. 50% of pool base tokens used as is
            b. 50% used to buy GYMNET tokens
            c. Add both amounts to liquidity pool
        5. Update user deposit information
     * @param _pid pool id
     * @param _baseTokenAmount amount of pool base tokens provided by user
     * @param _gymnetTokenAmount amount if GYMNET tokens provided by user
     * @param _amountAMin: bounds the extent to which the B/A price can go up before the transaction reverts.
        Must be <= amountADesired.
     * @param _amountBMin: bounds the extent to which the A/B price can go up before the transaction reverts.
        Must be <= amountBDesired
     * @param _minAmountOutA: the minimum amount of output A tokens that must be received
        for the transaction not to revert
     * @param _deadline transaction deadline timestamp
     * @param _minBurnAmt minimum amount of tokens to be burnt
     * @param _buyAndBurnWithGymnet bool flag to indicate if gymnet tokens will be used in buyAndBurn.
        Needed to make this function reusable
     */
    function _deposit(
        uint256 _pid,
        uint256 _baseTokenAmount,
        uint256 _gymnetTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOutA,
        uint256 _deadline,
        uint256 _minBurnAmt,
        bool _buyAndBurnWithGymnet
    ) private {
        UserLiquidityData memory liquidityData;

        IPancakeswapPair lpToken = IPancakeswapPair(address(poolInfo[_pid].lpToken));
        address poolBaseToken = _getPoolBaseTokenFromPair(lpToken);
        uint256 poolBaseTokenAmount = _isBnbPool(lpToken) ? msg.value : _baseTokenAmount;
        uint256 convertedGymnetInBase = 0;

        liquidityData.baseTokensAdded = poolBaseTokenAmount;
        liquidityData.gymnetTokensAdded = _gymnetTokenAmount;

        if (_baseTokenAmount > 0) {
            IERC20Upgradeable(poolBaseToken).safeTransferFrom(
                msg.sender,
                address(this),
                _baseTokenAmount
            );
        }

        if (_gymnetTokenAmount > 0) {
            IERC20Upgradeable(rewardToken).approve(routerAddress, _gymnetTokenAmount);

            convertedGymnetInBase = _swapTokens(
                address(rewardToken),
                poolBaseToken,
                _gymnetTokenAmount,
                _deadline
            );
        }

        liquidityData.totalAddedInBaseToken = poolBaseTokenAmount + convertedGymnetInBase;

        {
            // scope to avoid stack too deep errors
            uint256 amountToBurn = _percentage(
                _buyAndBurnWithGymnet
                    ? poolBaseTokenAmount + convertedGymnetInBase
                    : poolBaseTokenAmount,
                BUY_BACK_COMMISION
            );

            _buyAndBurnTokens(poolBaseToken, amountToBurn, _minBurnAmt, _deadline);
        }

        poolBaseTokenAmount = _isBnbPool(lpToken)
            ? address(this).balance
            : IERC20Upgradeable(poolBaseToken).balanceOf(address(this));

        liquidityData.lpTokens = _addLiquidity(
            lpToken,
            poolBaseToken,
            poolBaseTokenAmount,
            _amountAMin,
            _amountBMin,
            _minAmountOutA,
            _deadline
        );

        _updateUserInfo(_pid, msg.sender, liquidityData);

        emit Deposit(msg.sender, _pid, liquidityData.lpTokens);
    }

    /**
     * @notice Function to swap exact amount of tokens A for tokens B
     * @param inputToken have token address
     * @param outputToken want token address
     * @param inputAmount have token amount
     * @param deadline swap transaction deadline
     * @return uint256 amount of want tokens received
     */
    function _swapTokens(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 deadline
    ) private returns (uint256) {
        address[] memory path = new address[](2);

        path[0] = inputToken;
        path[1] = outputToken;

        uint256[] memory swapResult;

        if (outputToken == wbnbAddress) {
            swapResult = IPancakeRouter02(routerAddress).swapExactTokensForETH(
                inputAmount,
                0,
                path,
                address(this),
                deadline
            );
        } else {
            swapResult = IPancakeRouter02(routerAddress).swapExactTokensForTokens(
                inputAmount,
                0,
                path,
                address(this),
                deadline
            );
        }

        return swapResult[1];
    }

    /**
     * @notice Buy tokens from exchange and burn them
     * @param paymentToken token to pay with
     * @param spentAmount amount of tokens to spent on buy
     * @param minBurnAmount minimum amount of tokens to burn
     * @return burntAmount amount of burnt tokens
     */
    function _buyAndBurnTokens(
        address paymentToken,
        uint256 spentAmount,
        uint256 minBurnAmount,
        uint256 deadline
    ) private returns (uint256 burntAmount) {
        if (paymentToken == wbnbAddress) {
            IWETH(paymentToken).deposit{value: spentAmount}();
        }

        IERC20Upgradeable(paymentToken).safeTransfer(buyAndBurnAddress, spentAmount);

        burntAmount = IBuyAndBurn(buyAndBurnAddress).buyAndBurnToken(
            paymentToken,
            spentAmount,
            address(rewardToken),
            minBurnAmount,
            deadline
        );
    }

    function _addLiquidity(
        IPancakeswapPair _lpToken,
        address _basePoolToken,
        uint256 _baseTokenAmount,
        uint256 _amountAMin,
        uint256 _amountBMin,
        uint256 _minAmountOut,
        uint256 _deadline
    ) private returns (uint256 lpTokens) {
        if (_basePoolToken == wbnbAddress) {
            lpTokens = ILiquidityProvider(liquidityProvider).addLiquidityETHByPair{
                value: _baseTokenAmount
            }(
                _lpToken,
                address(this),
                _amountAMin,
                _amountBMin,
                _minAmountOut,
                _deadline,
                liquidityProviderApiId
            );
        } else {
            IERC20Upgradeable(_basePoolToken).approve(routerAddress, _baseTokenAmount / 2);

            uint256 gymnetTokenLiquidityAmount = _swapTokens(
                _basePoolToken,
                rewardToken,
                _baseTokenAmount / 2,
                _deadline
            );

            uint256 baseTokenLiquidityAmount = IERC20Upgradeable(_basePoolToken).balanceOf(
                address(this)
            );

            IERC20Upgradeable(_basePoolToken).approve(routerAddress, baseTokenLiquidityAmount);
            IERC20Upgradeable(rewardToken).approve(routerAddress, gymnetTokenLiquidityAmount);

            (, , lpTokens) = IPancakeRouter02(routerAddress).addLiquidity(
                _basePoolToken,
                address(rewardToken),
                baseTokenLiquidityAmount,
                gymnetTokenLiquidityAmount,
                _minAmountOut,
                0,
                address(this),
                _deadline
            );
        }
    }

    /**
     * @notice Function which transfer reward tokens to _to with the given amount
     * @param _to: transfer reciver address
     * @param _amount: amount of reward token which should be transfer
     */
    function safeRewardTransfer(address _to, uint256 _amount) private {
        if (_amount > 0) {
            uint256 rewardTokenBal = IERC20Upgradeable(rewardToken).balanceOf(address(this));

            require(_amount < rewardTokenBal, "GymFarming: No sufficient rewards");
            uint256 comission = (_amount * affilateComission) / 100;

            IERC20Upgradeable(rewardToken).safeTransfer(relationship, comission);
            IGymMLM(relationship).distributeRewards(_amount, address(rewardToken), msg.sender, 2);

            uint256 poolComissionAmount = (_amount * poolComission) / 100;
            IERC20Upgradeable(rewardToken).safeTransfer(treasury, poolComissionAmount);
            IERC20Upgradeable(rewardToken).safeTransfer(
                _to,
                (_amount - comission - poolComissionAmount)
            );
        }
    }

    /**
     * @notice Function for updating user info
     */
    function _updateUserInfo(
        uint256 _pid,
        address _from,
        UserLiquidityData memory liquidityData
    ) private {
        UserInfo storage user = userInfo[_pid][_from];
        address poolBaseToken = _getPoolBaseTokenFromPair(
            IPancakeswapPair(address(poolInfo[_pid].lpToken))
        );

        uint256 dollarValue = 0;

        _harvest(_pid, _from);

        user.totalDepositTokens += liquidityData.totalAddedInBaseToken;
        user.lpTokensAmount += liquidityData.lpTokens;
        user.rewardDebt = (user.lpTokensAmount * poolInfo[_pid].accRewardPerShare) / 1e18;

        if (poolBaseToken == wbnbAddress) {
            dollarValue +=
                (liquidityData.baseTokensAdded * IGYMNETWORK(rewardToken).getBNBPrice()) /
                1e18;
        } else {
            dollarValue += liquidityData.baseTokensAdded / 1e18;
        }

        if (liquidityData.gymnetTokensAdded > 0) {
            dollarValue +=
                ((liquidityData.gymnetTokensAdded * IGYMNETWORK(rewardToken).getGYMNETPrice()) /
                    1e18) /
                1e18;
        }

        user.totalDepositDollarValue += dollarValue;

        _updateLevelPoolQualification(_from);
    }

    /**
     * @notice Private function which send accumulated reward tokens to givn address
     * @param _pid: pool ID from which the accumulated reward tokens should be received
     * @param _from: Recievers address
     */
    function _harvest(uint256 _pid, address _from) private poolExists(_pid) {
        UserInfo storage user = userInfo[_pid][_from];

        if (user.lpTokensAmount > 0) {
            updatePool(_pid);

            uint256 accRewardPerShare = poolInfo[_pid].accRewardPerShare;
            uint256 pending = (user.lpTokensAmount * accRewardPerShare) / 1e18 - user.rewardDebt;

            safeRewardTransfer(_from, pending);
            user.rewardDebt = (user.lpTokensAmount * accRewardPerShare) / 1e18;

            emit Harvest(_from, _pid, pending);
        }
    }

    function _updateLevelPoolQualification(address wallet) private {
        if(address(levelPool) != address(0)) {
            uint256 userLevel = IGymMLMQualifications(mlmQualificationsAddress).getUserCurrentLevel(
                wallet
            );

            IGymLevelPool(levelPool).updateUserQualification(wallet, userLevel);
        }
    }

    /**
     * @notice Check if provided Pancakeswap Pair contains WNBN token
     * @param pair Pancakeswap pair contract
     * @return bool true if provided pair is WBNB/<Token> or <Token>/WBNB pair
                    false otherwise
     */
    function _isBnbPool(IPancakeswapPair pair) private view returns (bool) {
        IPancakeRouter02 router = IPancakeRouter02(routerAddress);

        return pair.token0() == router.WETH() || pair.token1() == router.WETH();
    }

    function _isSupportedLP(address pair) private view returns (bool) {
        address baseToken = _getPoolBaseTokenFromPair(IPancakeswapPair(pair));

        return baseToken == wbnbAddress || baseToken == busdAddress;
    }

    /**
     * @notice Get pool base token from Pancakeswap Pair. Base token - BUSD or WBNB
               Reverts for unsupported pool (not WBNB or BUSD)
     * @param pair Pancakeswap pair contract
     * @return address pool base token address
     */
    function _getPoolBaseTokenFromPair(IPancakeswapPair pair) private view returns (address) {
        return pair.token0() == rewardToken ? pair.token1() : pair.token0();
    }

    function _percentage(uint256 amount, uint256 percent) private pure returns (uint256) {
        return (amount * percent) / 100;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

pragma solidity 0.8.12;

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
pragma solidity 0.8.12;

interface IGymLevelPool {
    function updateUserQualification(address _wallet, uint256 _level) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IGymMLM {
    function addGymMLM(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;

    //   TODO remove this function after update VaultBank
    function updateInvestment(address _user, uint256 _newInvestment) external;

    //   TODO remove this function after update VaultBank
    function investment(address _user) external view returns (uint256);

    function updateInvestment(address _user, bool _isInvesting) external;

    function getPendingRewards(address, uint32) external view returns (uint256);

    function getReferrals(address) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IGymMLMQualifications {
    function addDirectPartner(address, address) external;

    function getUserCurrentLevel(address) external view returns (uint32);

    function getDirectPartners(address) external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IGYMNETWORK {
    function getGYMNETPrice() external view returns (uint256);
    function getBNBPrice() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

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
pragma solidity 0.8.12;

import "./IPancakeswapPair.sol";
import "./IPancakeRouter02.sol";

interface ILiquidityProvider {
    function apis(uint256)
        external
        view
        returns (
            address,
            address,
            address
        );

    function addExchange(IPancakeRouter02) external;

    function addLiquidityETH(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external payable returns (uint256);

    function addLiquidityETHByPair(
        IPancakeswapPair,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external payable returns (uint256);

    function addLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256
    ) external payable returns (uint256);

    function addLiquidityByPair(
        IPancakeswapPair,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256
    ) external payable returns (uint256);

    function removeLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256,
        uint8
    ) external returns (uint256[3] memory);

    function removeLiquidityETHByPair(
        IPancakeswapPair,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256,
        uint8
    ) external returns (uint256[3] memory);

    function removeLiquidityETHWithPermit(
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256,
        uint8,
        uint8,
        bytes32,
        bytes32
    ) external returns (uint256[3] memory);

    function removeLiquidity(
        address,
        address,
        uint256,
        uint256[2] memory,
        uint256[2] memory,
        address,
        uint256,
        uint256,
        uint8
    ) external returns (uint256[3] memory);

    function removeLiquidityByPair(
        IPancakeswapPair,
        uint256,
        uint256[2] memory,
        uint256[2] memory,
        address,
        uint256,
        uint256,
        uint8
    ) external returns (uint256[3] memory);

    function removeLiquidityWithPermit(
        address,
        address,
        uint256,
        uint256[2] memory,
        uint256[2] memory,
        address,
        uint256,
        uint256,
        uint8,
        uint8,
        bytes32,
        bytes32
    ) external returns (uint256[3] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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

pragma solidity 0.8.12;

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

pragma solidity 0.8.12;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external;

    function balanceOf(address dst) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
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

pragma solidity 0.8.12;

interface IPancakeswapPair {
    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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