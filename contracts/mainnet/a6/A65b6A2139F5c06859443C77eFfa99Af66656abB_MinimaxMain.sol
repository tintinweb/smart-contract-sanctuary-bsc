// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./exchange/IExchangeAdapter.sol";
import "./market/IMarket.sol";
import "./MinimaxStaking.sol";
import "./pool/IPoolAdapter.sol";
import "./interfaces/IERC20Decimals.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/ISmartChef.sol";
import "./interfaces/IGelatoOps.sol";
import "./interfaces/IWrapped.sol";
import "./ProxyCaller.sol";
import "./ProxyCallerApi.sol";
import "./ProxyPool.sol";
import "./market/IMarket.sol";

/*
    MinimaxMain
*/
contract MinimaxMain is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using ProxyCallerApi for ProxyCaller;

    event PositionWasCreated(uint indexed positionIndex);
    event PositionWasModified(uint indexed positionIndex);
    event PositionWasClosed(uint indexed positionIndex);

    uint public constant FEE_MULTIPLIER = 1e8;
    uint public constant SLIPPAGE_MULTIPLIER = 1e8;
    uint public constant POSITION_PRICE_LIMITS_MULTIPLIER = 1e8;

    address public cakeAddress; // TODO: remove when deploy clean version

    // BUSD for BSC, USDT for POLYGON
    address public busdAddress; // TODO: rename to stableToken when deploy clean version

    address public minimaxStaking;

    struct PositionInfo {
        uint stakedAmount; // wei
        uint feeAmount; // FEE_MULTIPLIER
        uint stopLossPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
        uint maxSlippage; // SLIPPAGE_MULTIPLIER
        address poolAddress;
        address owner;
        ProxyCaller callerAddress;
        bool closed;
        uint takeProfitPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
        IERC20Upgradeable stakedToken;
        IERC20Upgradeable rewardToken;
        bytes32 gelatoLiquidateTaskId; // TODO: rename to gelatoTaskId when deploy clean version
    }

    uint public lastPositionIndex;

    // Use mapping instead of array for upgradeability of PositionInfo struct
    mapping(uint => PositionInfo) public positions;

    mapping(address => bool) public isLiquidator;

    ProxyCaller[] public proxyPool;
    using ProxyPool for ProxyCaller[];

    // Fee threshold
    struct FeeThreshold {
        uint fee;
        uint stakedAmountThreshold;
    }

    FeeThreshold[] public depositFees;

    /// @custom:oz-renamed-from poolAdapters
    mapping(address => IPoolAdapter) public poolAdaptersDeprecated;

    mapping(IERC20Upgradeable => IPriceOracle) public priceOracles;

    mapping(IERC20Upgradeable => IExchangeAdapter) public tokenExchanges;

    // gelato
    IGelatoOps public gelatoOps;

    address payable public gelatoPayee;

    mapping(address => uint256) public gelatoLiquidateFee; // TODO: remove when deploy clean version
    uint256 public stakeGelatoFee; // TODO: rename to stakeGelatoFee
    address public gelatoFeeToken; // TODO: remove when deploy clean version

    // If token present in tokenExchanges -- use it. Otherwise use defaultExchange.
    IExchangeAdapter public defaultExchange;

    // poolAdapters by bytecode hash
    mapping(uint256 => IPoolAdapter) public poolAdapters;

    IMarket public market;

    address public wrappedNative;

    //
    //
    // Storage section ends!
    //
    //

    function setGasTankThreshold(uint256 value) external onlyOwner {
        stakeGelatoFee = value;
    }

    function setGelatoOps(address _gelatoOps) external onlyOwner {
        gelatoOps = IGelatoOps(_gelatoOps);
    }

    function setLastPositionIndex(uint newLastPositionIndex) external onlyOwner {
        require(newLastPositionIndex >= lastPositionIndex, "last position index may only be increased");
        lastPositionIndex = newLastPositionIndex;
    }

    function getPoolAdapterKeyByAddress(address pool) public view returns (uint256) {
        return uint256(keccak256(pool.code));
    }

    // Staking pool adapters
    function setPoolAdapters(address[] calldata pools, IPoolAdapter[] calldata adapters) external onlyOwner {
        require(pools.length == adapters.length, "pools and adapters parameters should have the same length");
        for (uint32 i = 0; i < pools.length; i++) {
            uint256 key = getPoolAdapterKeyByAddress(pools[i]);
            poolAdapters[key] = adapters[i];
        }
    }

    function getPoolAdapterSafe(address pool) public view returns (IPoolAdapter) {
        uint256 key = getPoolAdapterKeyByAddress(pool);
        IPoolAdapter adapter = poolAdapters[key];

        require(address(adapter) != address(0), "pool adapter not found");
        return adapter;
    }

    // Price oracles
    function setPriceOracles(IERC20Upgradeable[] calldata tokens, IPriceOracle[] calldata oracles) external onlyOwner {
        require(tokens.length == oracles.length, "tokens and oracles parameters should have the same length");
        for (uint32 i = 0; i < tokens.length; i++) {
            priceOracles[tokens[i]] = oracles[i];
        }
    }

    function getPriceOracleSafe(IERC20Upgradeable token) public view returns (IPriceOracle) {
        IPriceOracle oracle = priceOracles[token];
        require(address(oracle) != address(0), "price oracle not found");
        return oracle;
    }

    // Token exchanges
    function setDefaultTokenExchange(IExchangeAdapter exchange) external onlyOwner {
        defaultExchange = exchange;
    }

    function setTokenExchanges(IERC20Upgradeable[] calldata tokens, IExchangeAdapter[] calldata exchanges)
        external
        onlyOwner
    {
        require(tokens.length == exchanges.length, "tokens and exchanges parameters should have the same length");
        for (uint32 i = 0; i < tokens.length; i++) {
            tokenExchanges[tokens[i]] = exchanges[i];
        }
    }

    function getTokenExchangeSafe(IERC20Upgradeable token) public view returns (IExchangeAdapter) {
        // Return default exchange if not found.
        // That should be safe because function is called after token validation in stakeToken.
        IExchangeAdapter exchange = tokenExchanges[token];
        if (address(exchange) != address(0)) {
            return exchange;
        }
        return defaultExchange;
    }

    function setMarket(IMarket _market) external onlyOwner {
        market = _market;
    }

    function setWrappedNative(address _native) external onlyOwner {
        wrappedNative = _native;
    }

    modifier onlyLiquidator() {
        require(isLiquidator[address(msg.sender)], "only one of liquidators can close positions");
        _;
    }

    modifier onlyAutomator() {
        require(msg.sender == address(gelatoOps) || isLiquidator[address(msg.sender)], "onlyAutomator");
        _;
    }

    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize(
        address _minimaxStaking,
        address _busdAddress,
        address _gelatoOps
    ) external initializer {
        minimaxStaking = _minimaxStaking;
        busdAddress = _busdAddress;
        gelatoOps = IGelatoOps(_gelatoOps);

        __Ownable_init();
        __ReentrancyGuard_init();

        // staking pool
        depositFees.push(
            FeeThreshold({
                fee: 100000, // 0.1%
                stakedAmountThreshold: 1000 * 1e18 // all stakers <= 1000 MMX would have 0.1% fee for deposit
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 90000, // 0.09%
                stakedAmountThreshold: 5000 * 1e18
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 80000, // 0.08%
                stakedAmountThreshold: 10000 * 1e18
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 70000, // 0.07%
                stakedAmountThreshold: 50000 * 1e18
            })
        );
        depositFees.push(
            FeeThreshold({
                fee: 50000, // 0.05%
                stakedAmountThreshold: 10000000 * 1e18 // this level doesn't matter
            })
        );
    }

    receive() external payable {}

    function getSlippageMultiplier() public pure returns (uint) {
        return SLIPPAGE_MULTIPLIER;
    }

    function getUserFee() public view returns (uint) {
        MinimaxStaking staking = MinimaxStaking(minimaxStaking);

        uint amountPool2 = staking.getUserAmount(2, msg.sender);
        uint amountPool3 = staking.getUserAmount(3, msg.sender);
        uint totalStakedAmount = amountPool2 + amountPool3;

        uint length = depositFees.length;

        for (uint bucketId = 0; bucketId < length; ++bucketId) {
            uint threshold = depositFees[bucketId].stakedAmountThreshold;
            if (totalStakedAmount <= threshold) {
                return depositFees[bucketId].fee;
            }
        }
        return depositFees[length - 1].fee;
    }

    function getUserFeeAmount(uint stakeAmount) private view returns (uint) {
        uint userFeeShare = getUserFee();
        return (stakeAmount * userFeeShare) / FEE_MULTIPLIER;
    }

    function getPositionInfo(uint positionIndex) external view returns (PositionInfo memory) {
        return positions[positionIndex];
    }

    function fillProxyPool(uint amount) external onlyOwner {
        proxyPool.add(amount);
    }

    function cleanProxyPool() external onlyOwner {
        delete proxyPool;
    }

    function transferTo(
        address token,
        address to,
        uint amount
    ) external onlyOwner {
        address nativeToken = address(0);
        if (token == nativeToken) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "transferTo: BNB transfer failed");
        } else {
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(token), to, amount);
        }
    }

    function setDepositFee(uint poolIdx, uint feeShare) external onlyOwner {
        require(poolIdx < depositFees.length, "wrong pool index");
        depositFees[poolIdx].fee = feeShare;
    }

    function setMinimaxStakingAddress(address stakingAddress) external onlyOwner {
        minimaxStaking = stakingAddress;
    }

    struct PositionBalance {
        uint balance;
        uint reward;
        uint gasTank;
    }

    function getPositionBalances(uint[] calldata positionIndexes) public returns (PositionBalance[] memory) {
        PositionBalance[] memory balances = new PositionBalance[](positionIndexes.length);
        for (uint i = 0; i < positionIndexes.length; ++i) {
            balances[i] = getPositionBalance(positionIndexes[i]);
        }
        return balances;
    }

    function getPositionBalance(uint positionIndex) public returns (PositionBalance memory) {
        PositionInfo storage position = positions[positionIndex];
        IPoolAdapter adapter = getPoolAdapterSafe(position.poolAddress);

        uint gasTank = address(position.callerAddress).balance;
        uint stakingBalance = position.callerAddress.stakingBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );
        uint rewardBalance = position.callerAddress.rewardBalance(adapter, position.poolAddress, "");

        if (position.closed) {
            return PositionBalance({balance: 0, reward: 0, gasTank: 0});
        }

        if (position.stakedToken != position.rewardToken) {
            return PositionBalance({balance: position.stakedAmount, reward: rewardBalance, gasTank: gasTank});
        }

        uint totalBalance = rewardBalance + stakingBalance;

        if (totalBalance < position.stakedAmount) {
            return PositionBalance({balance: totalBalance, reward: 0, gasTank: gasTank});
        }

        return
            PositionBalance({
                balance: position.stakedAmount,
                reward: totalBalance - position.stakedAmount,
                gasTank: gasTank
            });
    }

    // before calling _stakeToken
    // tokenAmount of stakingToken should be on MinimaxMain contract
    function _stakeToken(
        IERC20Upgradeable stakingToken,
        address stakingPool,
        uint tokenAmount,
        uint maxSlippage,
        uint stopLossPrice,
        uint takeProfitPrice
    ) private returns (uint) {
        require(msg.value >= stakeGelatoFee, "gasTankThreshold");

        validatePosition(stakingToken, stopLossPrice, takeProfitPrice);
        emit PositionWasCreated(lastPositionIndex);

        IPoolAdapter adapter = getPoolAdapterSafe(stakingPool);
        require(
            adapter.stakedToken(stakingPool, abi.encode(stakingToken)) == address(stakingToken),
            "stakeToken: invalid staking token."
        );
        address rewardToken = adapter.rewardToken(stakingPool, abi.encode(stakingToken));

        uint userFeeAmount = getUserFeeAmount(tokenAmount);
        uint amountToStake = tokenAmount - userFeeAmount;

        uint positionIndex = lastPositionIndex;
        lastPositionIndex += 1;

        ProxyCaller proxy = proxyPool.acquire();
        depositGasTank(proxy);

        positions[positionIndex] = PositionInfo({
            stakedAmount: amountToStake,
            feeAmount: userFeeAmount,
            stopLossPrice: stopLossPrice,
            maxSlippage: maxSlippage,
            poolAddress: stakingPool,
            owner: address(msg.sender),
            callerAddress: proxy,
            closed: false,
            takeProfitPrice: takeProfitPrice,
            stakedToken: stakingToken,
            rewardToken: IERC20Upgradeable(rewardToken),
            gelatoLiquidateTaskId: gelatoCreateTask(positionIndex)
        });

        proxyDeposit(positions[positionIndex], amountToStake);
        return positionIndex;
    }

    function stakeToken(
        IERC20Upgradeable stakingToken,
        address stakingPool,
        uint tokenAmount,
        uint maxSlippage,
        uint stopLossPrice,
        uint takeProfitPrice
    ) public payable nonReentrant returns (uint) {
        stakingToken.safeTransferFrom(address(msg.sender), address(this), tokenAmount);
        return _stakeToken(stakingToken, stakingPool, tokenAmount, maxSlippage, stopLossPrice, takeProfitPrice);
    }

    function swapStakeToken(
        IERC20Upgradeable inputToken,
        IERC20Upgradeable stakingToken,
        address stakingPool,
        uint inputTokenAmount,
        uint stakingTokenAmountMin,
        uint maxSlippage,
        uint stopLossPrice,
        uint takeProfitPrice
    ) public payable nonReentrant returns (uint) {
        require(address(market) != address(0), "no market");
        inputToken.safeTransferFrom(address(msg.sender), address(this), inputTokenAmount);
        inputToken.approve(address(market), inputTokenAmount);
        uint actualAmount = market.swap(
            address(inputToken),
            address(stakingToken),
            inputTokenAmount,
            stakingTokenAmountMin,
            address(this)
        );
        return _stakeToken(stakingToken, stakingPool, actualAmount, maxSlippage, stopLossPrice, takeProfitPrice);
    }

    function swapStakeTokenNative(
        IERC20Upgradeable stakingToken,
        address stakingPool,
        uint inputAmount,
        uint stakingTokenAmountMin,
        uint maxSlippage,
        uint stopLossPrice,
        uint takeProfitPrice
    ) public payable nonReentrant returns (uint) {
        require(msg.value >= inputAmount + stakeGelatoFee, "no value");
        IWrapped(wrappedNative).deposit{value: inputAmount}();
        return
            swapStakeToken(
                IERC20Upgradeable(wrappedNative),
                stakingToken,
                stakingPool,
                inputAmount,
                stakingTokenAmountMin,
                maxSlippage,
                stopLossPrice,
                takeProfitPrice
            );
    }

    function swapStakeTokenEstimateNative(IERC20Upgradeable stakingToken, uint inputAmount) public view returns (uint) {
        require(address(market) != address(0), "no market");
        return market.estimateOut(wrappedNative, address(stakingToken), inputAmount);
    }

    function validatePosition(
        IERC20Upgradeable stakingToken,
        uint stopLossPrice,
        uint takeProfitPrice
    ) private {
        IPriceOracle oracle = priceOracles[stakingToken];
        if (stopLossPrice != 0) {
            require(address(oracle) != address(0), "stopLossPrice: price oracle is zero");
        }
        if (takeProfitPrice != 0) {
            require(address(oracle) != address(0), "takeProfitPrice: price oracle is zero");
        }
    }

    function deposit(uint positionIndex, uint amount) external nonReentrant {
        PositionInfo storage position = positions[positionIndex];
        depositImpl(position, positionIndex, amount);
    }

    function setLiquidator(address user, bool value) external onlyOwner {
        isLiquidator[user] = value;
    }

    function withdrawAll(uint positionIndex) external nonReentrant {
        withdrawImpl({positionIndex: positionIndex, amount: 0, amountAll: true});
    }

    function alterPositionParams(
        uint positionIndex,
        uint newAmount,
        uint newStopLossPrice,
        uint newTakeProfitPrice,
        uint newSlippage
    ) external nonReentrant {
        PositionInfo storage position = positions[positionIndex];
        require(position.owner == address(msg.sender), "stop loss may be changed only by position owner");
        validatePosition(position.stakedToken, newStopLossPrice, newTakeProfitPrice);

        position.stopLossPrice = newStopLossPrice;
        position.takeProfitPrice = newTakeProfitPrice;
        position.maxSlippage = newSlippage;

        if (newAmount < position.stakedAmount) {
            uint withdrawAmount = position.stakedAmount - newAmount;
            withdrawImpl({positionIndex: positionIndex, amount: withdrawAmount, amountAll: false});
        } else if (newAmount > position.stakedAmount) {
            uint depositAmount = newAmount - position.stakedAmount;
            depositImpl(position, positionIndex, depositAmount);
        } else {
            emit PositionWasModified(positionIndex);
        }
    }

    function withdraw(uint positionIndex, uint amount) external nonReentrant {
        withdrawImpl({positionIndex: positionIndex, amount: amount, amountAll: false});
    }

    // Always emits `PositionWasClosed`
    function liquidateByIndexImpl(uint positionIndex) private {
        requireReadyForLiquidation(positionIndex);

        PositionInfo storage position = positions[positionIndex];
        position.callerAddress.withdrawAll(
            getPoolAdapterSafe(position.poolAddress),
            position.poolAddress,
            abi.encode(position.stakedToken) // pass stakedToken for aave pools
        );

        uint stakedAmount = IERC20Upgradeable(position.stakedToken).balanceOf(address(position.callerAddress));

        if (address(position.stakedToken) != busdAddress) {
            // swapToStable transfers stablecoins directly to position owner address
            swapToStable(positionIndex, stakedAmount);
        } else {
            position.callerAddress.transferAll(position.stakedToken, position.owner);
        }

        // Firstly, 'transfer', then 'dumpRewards': order is important here when (rewardToken == CAKE)
        position.callerAddress.transferAll(position.rewardToken, position.owner);

        closePosition(positionIndex);
    }

    function liquidateByIndex(uint positionIndex) external nonReentrant onlyLiquidator {
        liquidateByIndexImpl(positionIndex);
    }

    // May run out of gas if array length is too big!
    function liquidateManyByIndex(uint[] calldata positionIndexes) external nonReentrant onlyLiquidator {
        for (uint i = 0; i < positionIndexes.length; ++i) {
            liquidateByIndexImpl(positionIndexes[i]);
        }
    }

    function proxyDeposit(PositionInfo storage position, uint amount) private {
        position.stakedToken.safeTransfer(address(position.callerAddress), amount);
        position.callerAddress.approve(position.stakedToken, position.poolAddress, amount);
        position.callerAddress.deposit(
            getPoolAdapterSafe(position.poolAddress),
            position.poolAddress,
            amount,
            abi.encode(position.stakedToken) // pass stakedToken for aave pools
        );
    }

    // Emits `PositionsWasModified` always.
    function depositImpl(
        PositionInfo storage position,
        uint positionIndex,
        uint amount
    ) private {
        emit PositionWasModified(positionIndex);

        require(position.owner == address(msg.sender), "deposit: only position owner allowed");
        require(position.closed == false, "deposit: position is closed");

        position.stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);

        uint userFeeShare = getUserFee();
        uint userFeeAmount = (amount * userFeeShare) / FEE_MULTIPLIER;
        uint amountToDeposit = amount - userFeeAmount;

        position.stakedAmount = position.stakedAmount + amountToDeposit;
        position.feeAmount = position.feeAmount + userFeeAmount;

        proxyDeposit(position, amountToDeposit);
        position.callerAddress.transferAll(position.rewardToken, position.owner);
    }

    // Emits:
    //   * `PositionWasClosed`,   if `amount == position.stakedAmount`.
    //   * `PositionWasModified`, otherwise.
    function withdrawImpl(
        uint positionIndex,
        uint amount,
        bool amountAll
    ) private {
        PositionInfo storage position = positions[positionIndex];

        require(position.owner == address(msg.sender), "withdraw: only position owner allowed");
        require(position.closed == false, "withdraw: position is closed");

        IPoolAdapter poolAdapter = getPoolAdapterSafe(position.poolAddress);
        if (amountAll) {
            position.callerAddress.withdrawAll(
                poolAdapter,
                position.poolAddress,
                abi.encode(position.stakedToken) // pass stakedToken for aave pools
            );
        } else {
            position.callerAddress.withdraw(
                poolAdapter,
                position.poolAddress,
                amount,
                abi.encode(position.stakedToken) // pass stakedToken for aave pools
            );
        }

        position.callerAddress.transferAll(position.stakedToken, position.owner);
        position.callerAddress.transferAll(position.rewardToken, position.owner);

        uint poolBalance = position.callerAddress.stakingBalance(
            poolAdapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );
        if (poolBalance == 0 || amountAll) {
            closePosition(positionIndex);
        } else {
            emit PositionWasModified(positionIndex);
            position.stakedAmount = poolBalance;
        }
    }

    function requireReadyForLiquidation(uint positionIndex) public view {
        require(isReadyForLiquidation(positionIndex), "requireReadyForLiquidation");
    }

    function isReadyForLiquidation(uint positionIndex) public view returns (bool) {
        PositionInfo memory position = positions[positionIndex];
        if (position.closed == true || position.owner == address(0)) {
            return false;
        }
        return isPriceOutsideRange(position);
    }

    // isPriceOutsideRange returns true only if price oracle exists
    // and the corresponding limit is set
    function isPriceOutsideRange(PositionInfo memory position) public view returns (bool) {
        IPriceOracle oracle = priceOracles[position.stakedToken];
        if (address(oracle) == address(0)) return false;

        uint oracleMultiplier = 10**oracle.decimals();
        uint oraclePrice = uint(oracle.latestAnswer());

        // oraclePriceFloat = oraclePrice / oracleMultiplier
        // stopLossPriceFloat = position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // if
        // oraclePrice / oracleMultiplier > position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // then
        // oraclePrice * POSITION_PRICE_LIMITS_MULTIPLIER > position.stopLossPrice * oracleMultiplier

        if (
            position.stopLossPrice != 0 &&
            oraclePrice * POSITION_PRICE_LIMITS_MULTIPLIER < position.stopLossPrice * oracleMultiplier
        ) return true;

        if (
            position.takeProfitPrice != 0 &&
            oraclePrice * POSITION_PRICE_LIMITS_MULTIPLIER > position.takeProfitPrice * oracleMultiplier
        ) return true;

        return false;
    }

    // swapToStable works only if price oracle exists
    function swapToStable(uint positionIndex, uint amount) private {
        PositionInfo storage position = positions[positionIndex];

        IPriceOracle oracle = getPriceOracleSafe(position.stakedToken);
        IExchangeAdapter tokenExchange = getTokenExchangeSafe(position.stakedToken);

        uint oracleMultiplier = 10**oracle.decimals();
        uint oraclePrice = uint(oracle.latestAnswer());

        // Optimistic conversion stablecoin amount
        uint minAmountOut = (amount * oraclePrice) / oracleMultiplier;
        // Accounting slippage
        minAmountOut = minAmountOut - (minAmountOut * position.maxSlippage) / SLIPPAGE_MULTIPLIER;
        // Scale according to tokens decimals
        uint8 tokenInDecimals = IERC20Decimals(address(position.stakedToken)).decimals();
        uint8 tokenOutDecimals = IERC20Decimals(busdAddress).decimals();

        // Check for bigger one to avoid int overflow while multiplying
        if (tokenInDecimals > tokenOutDecimals) {
            minAmountOut = minAmountOut / 10**(tokenInDecimals - tokenOutDecimals);
        } else if (tokenOutDecimals > tokenInDecimals) {
            minAmountOut = minAmountOut / 10**(tokenOutDecimals - tokenInDecimals);
        }

        position.callerAddress.swapExactTokensForTokens(
            tokenExchange, // adapter
            address(position.stakedToken), // tokenIn
            busdAddress, // tokenOut
            amount, // amountIn
            minAmountOut, // amountOutMin
            position.owner, // to
            block.timestamp // deadline
        );
    }

    function closePosition(uint positionIndex) private {
        PositionInfo storage position = positions[positionIndex];

        position.closed = true;

        if (isModernProxy(position.callerAddress)) {
            withdrawGasTank(position.callerAddress, position.owner);
            proxyPool.release(position.callerAddress);
        }

        gelatoCancelTask(position.gelatoLiquidateTaskId);

        emit PositionWasClosed(positionIndex);
    }

    function depositGasTank(ProxyCaller proxy) private {
        address(proxy).call{value: msg.value}("");
    }

    function withdrawGasTank(ProxyCaller proxy, address owner) private {
        proxy.transferNativeAll(owner);
    }

    function isModernProxy(ProxyCaller proxy) public returns (bool) {
        return address(proxy).code.length == 945;
    }

    //
    // Gelato
    //

    // gelatoIsReadyForLiquidation selector is stored in previously created tasks
    // dont delete for compatibility
    function gelatoIsReadyForLiquidation(uint256 positionIndex)
        public
        view
        returns (bool canExec, bytes memory execPayload)
    {
        canExec = isReadyForLiquidation(positionIndex);
        execPayload = abi.encodeWithSelector(this.gelatoLiquidate.selector, positionIndex);
    }

    // gelatoLiquidate selector is stored in previously created tasks
    // dont delete for compatibility
    function gelatoLiquidate(uint positionIndex) public onlyAutomator {
        liquidateByIndexImpl(positionIndex);
    }

    struct AutomationParams {
        uint256 positionIndex;
    }

    function automationResolve(uint positionIndex) public view returns (bool canExec, bytes memory execPayload) {
        canExec = isReadyForLiquidation(positionIndex);
        execPayload = abi.encodeWithSelector(this.automationExec.selector, AutomationParams(positionIndex));
    }

    function automationExec(AutomationParams calldata params) public onlyAutomator {
        gelatoPayFee(params.positionIndex);
        liquidateByIndexImpl(params.positionIndex);
    }

    function gelatoPayFee(uint positionIndex) private {
        (uint feeAmount, address feeToken) = gelatoOps.getFeeDetails();
        if (feeAmount == 0) {
            return;
        }

        require(feeToken == GelatoNativeToken);

        address feeDestination = gelatoOps.gelato();
        ProxyCaller proxy = positions[positionIndex].callerAddress;
        proxy.transferNative(feeDestination, feeAmount);
    }

    function gelatoCreateTask(uint positionIndex) private returns (bytes32) {
        return
            gelatoOps.createTaskNoPrepayment(
                address(this), /* execAddress */
                this.automationExec.selector, /* execSelector */
                address(this), /* resolverAddress */
                abi.encodeWithSelector(this.automationResolve.selector, positionIndex), /* resolverData */
                GelatoNativeToken
            );
    }

    function gelatoCancelTask(bytes32 gelatoTaskId) private {
        gelatoOps.cancelTask(gelatoTaskId);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
pragma solidity ^0.8.0;

interface IExchangeAdapter {
    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IMarket {
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address destination
    ) external returns (uint256);

    function estimateOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IMinimaxToken.sol";

contract MinimaxStaking is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint public constant SHARE_MULTIPLIER = 1e12;

    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct UserPoolInfo {
        uint amount; // How many LP tokens the user has provided.
        uint rewardDebt; // Reward debt. See explanation below.
        uint timeDeposited; // timestamp when minimax was deposited
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable token; // Address of LP token contract.
        uint totalSupply;
        uint allocPoint; // How many allocation points assigned to this pool. MINIMAXs to distribute per block.
        uint timeLocked; // How long stake must be locked for
        uint lastRewardBlock; // Last block number that MINIMAXs distribution occurs.
        uint accMinimaxPerShare; // Accumulated MINIMAXs per share, times SHARE_MULTIPLIER. See below.
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint => mapping(address => UserPoolInfo)) public userPoolInfo;

    address public minimaxToken;
    uint public minimaxPerBlock;
    uint public startBlock;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint public totalAllocPoint;

    event Deposit(address indexed user, uint indexed pid, uint amount);
    event Withdraw(address indexed user, uint indexed pid, uint amount);
    event EmergencyWithdraw(address indexed user, uint indexed pid, uint256 amount);
    event PoolAdded(uint allocPoint, uint timeLocked);
    event SetMinimaxPerBlock(uint minimaxPerBlock);
    event SetPool(uint pid, uint allocPoint);

    function initialize(
        address _minimaxToken,
        uint _minimaxPerBlock,
        uint _startBlock
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        minimaxToken = _minimaxToken;
        minimaxPerBlock = _minimaxPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(
            PoolInfo({
                token: IERC20Upgradeable(minimaxToken),
                totalSupply: 0,
                allocPoint: 800,
                timeLocked: 0 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IERC20Upgradeable(minimaxToken),
                totalSupply: 0,
                allocPoint: 1400,
                timeLocked: 7 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IERC20Upgradeable(minimaxToken),
                totalSupply: 0,
                allocPoint: 2000,
                timeLocked: 30 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IERC20Upgradeable(minimaxToken),
                totalSupply: 0,
                allocPoint: 3000,
                timeLocked: 90 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        totalAllocPoint = 7200;
    }

    /* ========== External Functions ========== */

    function getUserAmount(uint _pid, address _user) external view returns (uint) {
        UserPoolInfo storage user = userPoolInfo[_pid][_user];
        return user.amount;
    }

    // View function to see pending MINIMAXs from Pools on frontend.
    function pendingMinimax(uint _pid, address _user) external view returns (uint) {
        PoolInfo memory pool = poolInfo[_pid];
        UserPoolInfo memory user = userPoolInfo[_pid][_user];

        // Minting reward
        uint accMinimaxPerShare = pool.accMinimaxPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalSupply != 0) {
            uint multiplier = block.number - pool.lastRewardBlock;
            uint minimaxReward = (multiplier * minimaxPerBlock * pool.allocPoint) / totalAllocPoint;
            accMinimaxPerShare = accMinimaxPerShare + (minimaxReward * SHARE_MULTIPLIER) / pool.totalSupply;
        }
        uint pendingUserMinimax = (user.amount * accMinimaxPerShare) / SHARE_MULTIPLIER - user.rewardDebt;
        return pendingUserMinimax;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.totalSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        // Minting reward
        uint multiplier = block.number - pool.lastRewardBlock;
        uint minimaxReward = (multiplier * minimaxPerBlock * pool.allocPoint) / totalAllocPoint;
        pool.accMinimaxPerShare = pool.accMinimaxPerShare + (minimaxReward * SHARE_MULTIPLIER) / pool.totalSupply;
        pool.lastRewardBlock = block.number;
    }

    // Deposit lp tokens for MINIMAX allocation.
    function deposit(uint _pid, uint _amount) external nonReentrant {
        require(_amount > 0, "deposit: amount is 0");
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            _claimPendingMintReward(_pid, msg.sender);
        }
        if (_amount > 0) {
            uint before = pool.token.balanceOf(address(this));
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint post = pool.token.balanceOf(address(this));
            uint finalAmount = post - before;
            user.amount = user.amount + finalAmount;
            user.timeDeposited = block.timestamp;
            pool.totalSupply = pool.totalSupply + finalAmount;
            emit Deposit(msg.sender, _pid, finalAmount);
        }
        user.rewardDebt = (user.amount * pool.accMinimaxPerShare) / SHARE_MULTIPLIER;
    }

    // Withdraw LP tokens
    function withdraw(uint _pid, uint _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: requested amount is high");
        require(block.timestamp >= user.timeDeposited + pool.timeLocked, "can't withdraw before end of lock-up");

        updatePool(_pid);
        _claimPendingMintReward(_pid, msg.sender);

        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.totalSupply = pool.totalSupply - _amount;
            pool.token.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = (user.amount * pool.accMinimaxPerShare) / SHARE_MULTIPLIER;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        require(block.timestamp >= user.timeDeposited + pool.timeLocked, "time locked");

        uint amount = user.amount;

        pool.totalSupply = pool.totalSupply - user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.token.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint _allocPoint,
        address _poolToken,
        uint _timeLocked
    ) external onlyOwner {
        massUpdatePools();
        uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                token: IERC20Upgradeable(_poolToken),
                totalSupply: 0,
                allocPoint: _allocPoint,
                timeLocked: _timeLocked,
                lastRewardBlock: lastRewardBlock,
                accMinimaxPerShare: 0
            })
        );
        emit PoolAdded(_allocPoint, _timeLocked);
    }

    // Update the given pool's MINIMAX allocation point. Can only be called by the owner.
    function set(uint _pid, uint _allocPoint) external onlyOwner {
        massUpdatePools();
        uint prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
        }
        emit SetPool(_pid, _allocPoint);
    }

    function setMinimaxPerBlock(uint _minimaxPerBlock) external onlyOwner {
        minimaxPerBlock = _minimaxPerBlock;
        emit SetMinimaxPerBlock(_minimaxPerBlock);
    }

    function _claimPendingMintReward(uint _pid, address _user) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][_user];

        uint pendingMintReward = (user.amount * pool.accMinimaxPerShare) / SHARE_MULTIPLIER - user.rewardDebt;
        if (pendingMintReward > 0) {
            IMinimaxToken(minimaxToken).mint(_user, pendingMintReward);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolAdapter {
    function stakingBalance(address pool, bytes memory) external returns (uint256);

    function rewardBalance(address pool, bytes memory) external returns (uint256);

    function deposit(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdrawAll(address pool, bytes memory args) external;

    function stakedToken(address pool, bytes memory args) external returns (address);

    function rewardToken(address pool, bytes memory args) external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Decimals is IERC20Upgradeable {
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ISmartChef {
    function stakedToken() external view returns (IERC20Upgradeable);

    function rewardToken() external view returns (IERC20Upgradeable);

    // Deposit '_amount' of stakedToken tokens
    function deposit(uint256 _amount) external;

    // Withdraw '_amount' of stakedToken and all pending rewardToken tokens
    function withdraw(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

address constant GelatoNativeToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

interface IGelatoOps {
    function createTaskNoPrepayment(
        address execAddress,
        bytes4 execSelector,
        address resolverAddress,
        bytes calldata resolverData,
        address feeToken
    ) external returns (bytes32 task);

    function cancelTask(bytes32 taskId) external;

    function getFeeDetails() external view returns (uint256, address);

    function gelato() external view returns (address payable);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWrapped {
    function deposit() external payable;

    function withdraw(uint wad) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ProxyCaller contract is deployed frequently, and in order to reduce gas
// it has to be as small as possible
contract ProxyCaller {
    address immutable _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function exec(
        bool delegate,
        address target,
        bytes calldata data
    ) external onlyOwner returns (bool success, bytes memory) {
        if (delegate) {
            return target.delegatecall(data);
        }
        return target.call(data);
    }

    function transfer(address target, uint256 amount) external onlyOwner returns (bool success, bytes memory) {
        return target.call{value: amount}("");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./exchange/IExchangeAdapter.sol";
import "./ProxyCaller.sol";
import "./pool/IPoolAdapter.sol";

library ProxyCallerApi {
    function propagateError(
        bool success,
        bytes memory data,
        string memory errorMessage
    ) internal {
        // Forward error message from call/delegatecall
        if (!success) {
            if (data.length == 0) revert(errorMessage);
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    function deposit(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        uint256 amount,
        bytes memory args // used for passing stakedToken for Aave pools
    ) internal {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("deposit(address,uint256,bytes)", pool, amount, args) /* data */
        );

        propagateError(success, data, "deposit failed");
    }

    function stakingBalance(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        bytes memory args // used for passing stakedToken for Aave pools
    ) internal returns (uint256) {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("stakingBalance(address,bytes)", pool, args) /* data */
        );

        propagateError(success, data, "staking balance failed");

        return abi.decode(data, (uint256));
    }

    function rewardBalance(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        bytes memory args
    ) internal returns (uint256) {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("rewardBalance(address,bytes)", pool, args) /* data */
        );

        propagateError(success, data, "reward balance failed");

        return abi.decode(data, (uint256));
    }

    function withdraw(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        uint256 amount,
        bytes memory args // used for passing stakedToken for Aave pools
    ) internal {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("withdraw(address,uint256,bytes)", pool, amount, args) /* data */
        );

        propagateError(success, data, "withdraw failed");
    }

    function withdrawAll(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        bytes memory args // used for passing stakedToken for Aave pools
    ) internal {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("withdrawAll(address,bytes)", pool, args) /* data */
        );

        propagateError(success, data, "withdraw all failed");
    }

    function transfer(
        ProxyCaller proxy,
        IERC20Upgradeable token,
        address beneficiary,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = proxy.exec(
            false, /* delegate */
            address(token), /* target */
            abi.encodeWithSignature("transfer(address,uint256)", beneficiary, amount) /* data */
        );
        propagateError(success, data, "transfer failed");
    }

    function transferAll(
        ProxyCaller proxy,
        IERC20Upgradeable token,
        address beneficiary
    ) internal returns (uint256) {
        uint256 amount = token.balanceOf(address(proxy));
        if (amount > 0) {
            transfer(proxy, token, beneficiary, amount);
        }
        return amount;
    }

    function transferNative(
        ProxyCaller proxy,
        address beneficiary,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = proxy.transfer(
            address(beneficiary), /* target */
            amount /* amount */
        );
        propagateError(success, data, "transfer native failed");
    }

    function transferNativeAll(ProxyCaller proxy, address beneficiary) internal {
        (bool success, bytes memory data) = proxy.transfer(
            address(beneficiary), /* target */
            address(proxy).balance /* amount */
        );
        propagateError(success, data, "transfer native all failed");
    }

    function approve(
        ProxyCaller proxy,
        IERC20Upgradeable token,
        address beneficiary,
        uint amount
    ) internal {
        (bool success, bytes memory data) = proxy.exec(
            false, /* delegate */
            address(token), /* target */
            abi.encodeWithSignature("approve(address,uint256)", beneficiary, amount) /* data */
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "approve failed");
    }

    function swapExactTokensForTokens(
        ProxyCaller proxy,
        IExchangeAdapter adapter,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) internal returns (uint256) {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature( /* data */
                "swapExactTokensForTokens(address,address,uint256,uint256,address,uint256)",
                tokenIn,
                tokenOut,
                amountIn,
                amountOutMin,
                to,
                deadline
            )
        );
        propagateError(success, data, "swap exact tokens failed");
        return abi.decode(data, (uint256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProxyCaller.sol";

library ProxyPool {
    function release(ProxyCaller[] storage self, ProxyCaller proxy) internal {
        self.push(proxy);
    }

    function acquire(ProxyCaller[] storage self) internal returns (ProxyCaller) {
        if (self.length == 0) {
            return new ProxyCaller();
        }
        ProxyCaller proxy = self[self.length - 1];
        self.pop();
        return proxy;
    }

    function add(ProxyCaller[] storage self, uint amount) internal {
        for (uint i = 0; i < amount; i++) {
            self.push(new ProxyCaller());
        }
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
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
pragma solidity ^0.8.0;

interface IMinimaxToken {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function owner() external returns (address);
}