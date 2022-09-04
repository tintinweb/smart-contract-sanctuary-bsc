// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./interfaces/IMinimaxStaking.sol";
import "./interfaces/IMinimaxMain.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IGelatoOps.sol";

import "./pool/IPoolAdapter.sol";
import "./ProxyCaller.sol";
import "./ProxyCallerApi.sol";
import "./ProxyPool.sol";
import "./PositionInfo.sol";
import "./PositionBalanceLib.sol";
import "./PositionLib.sol";

/*
    MinimaxMain
*/
contract MinimaxMain is IMinimaxMain, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    // -----------------------------------------------------------------------------------------------------------------
    // Using declarations.

    using SafeERC20Upgradeable for IERC20Upgradeable;

    using ProxyCallerApi for ProxyCaller;

    using ProxyPool for ProxyCaller[];

    // -----------------------------------------------------------------------------------------------------------------
    // Events.

    // NB: If `estimatedStakedTokenPrice` is equal to `0`, then the price is unavailable for some reason.

    event PositionWasCreated(uint indexed positionIndex);
    event PositionWasCreatedV2(
        uint indexed positionIndex,
        uint timestamp,
        uint stakedTokenPrice,
        uint8 stakedTokenPriceDecimals
    );

    event PositionWasModified(uint indexed positionIndex);

    event PositionWasClosed(uint indexed positionIndex);
    event PositionWasClosedV2(
        uint indexed positionIndex,
        uint timestamp,
        uint stakedTokenPrice,
        uint8 stakedTokenPriceDecimals
    );

    event PositionWasLiquidatedV2(
        uint indexed positionIndex,
        uint timestamp,
        uint stakedTokenPrice,
        uint8 stakedTokenPriceDecimals
    );

    event StakedBaseTokenWithdraw(uint indexed positionIndex, address token, uint amount);

    event StakedSwapTokenWithdraw(uint indexed positionIndex, address token, uint amount);

    event RewardTokenWithdraw(uint indexed positionIndex, address token, uint amount);

    // -----------------------------------------------------------------------------------------------------------------
    // Storage.

    uint public constant FEE_MULTIPLIER = 1e8;
    uint public constant SLIPPAGE_MULTIPLIER = 1e8;
    uint public constant POSITION_PRICE_LIMITS_MULTIPLIER = 1e8;

    address public cakeAddress; // TODO: remove when deploy clean version

    // BUSD for BSC, USDT for POLYGON
    address public busdAddress; // TODO: rename to stableToken when deploy clean version

    address public minimaxStaking;

    uint public lastPositionIndex;

    // Use mapping instead of array for upgradeability of PositionInfo struct
    mapping(uint => PositionInfo) public positions;

    mapping(address => bool) public isLiquidator;

    ProxyCaller[] public proxyPool;

    // Fee threshold
    struct FeeThreshold {
        uint fee;
        uint stakedAmountThreshold;
    }

    FeeThreshold[] public depositFees;

    /// @custom:oz-renamed-from poolAdapters
    mapping(address => IPoolAdapter) public poolAdaptersDeprecated;

    mapping(IERC20Upgradeable => IPriceOracle) public priceOracles;

    // TODO: deprecated
    mapping(address => address) public tokenExchanges;

    // gelato
    IGelatoOps public gelatoOps;

    address payable public gelatoPayee;

    mapping(address => uint256) public gelatoLiquidateFee; // TODO: remove when deploy clean version
    uint256 public liquidatorFee; // transfered to liquidator (not gelato) when `gelatoOps` is not set
    address public gelatoFeeToken; // TODO: remove when deploy clean version

    // TODO: deprecated
    address public defaultExchange;

    // poolAdapters by bytecode hash
    mapping(uint256 => IPoolAdapter) public poolAdapters;

    IMarket public market;

    address public wrappedNative;

    address public oneInchRouter;

    // -----------------------------------------------------------------------------------------------------------------
    // Methods.

    function setGasTankThreshold(uint256 value) external onlyOwner {
        liquidatorFee = value;
    }

    function setGelatoOps(address _gelatoOps) external onlyOwner {
        gelatoOps = IGelatoOps(_gelatoOps);
    }

    function setLastPositionIndex(uint newLastPositionIndex) external onlyOwner {
        require(newLastPositionIndex >= lastPositionIndex, "last position index may only be increased");
        lastPositionIndex = newLastPositionIndex;
    }

    function getPoolAdapterKey(address pool) public view returns (uint256) {
        return uint256(keccak256(pool.code));
    }

    function getPoolAdapter(address pool) public view returns (IPoolAdapter) {
        uint256 key = getPoolAdapterKey(pool);
        return poolAdapters[key];
    }

    function getPoolAdapterSafe(address pool) public view returns (IPoolAdapter) {
        IPoolAdapter adapter = getPoolAdapter(pool);
        require(address(adapter) != address(0), "pool adapter not found");
        return adapter;
    }

    function getPoolAdapters(address[] calldata pools)
        public
        view
        returns (IPoolAdapter[] memory adapters, uint256[] memory keys)
    {
        adapters = new IPoolAdapter[](pools.length);
        keys = new uint256[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            uint256 key = getPoolAdapterKey(pools[i]);
            keys[i] = key;
            adapters[i] = poolAdapters[key];
        }
    }

    // Staking pool adapters
    function setPoolAdapters(address[] calldata pools, IPoolAdapter[] calldata adapters) external onlyOwner {
        require(pools.length == adapters.length, "pools and adapters parameters should have the same length");
        for (uint32 i = 0; i < pools.length; i++) {
            uint256 key = getPoolAdapterKey(pools[i]);
            poolAdapters[key] = adapters[i];
        }
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

    function setMarket(IMarket _market) external onlyOwner {
        market = _market;
    }

    function setWrappedNative(address _native) external onlyOwner {
        wrappedNative = _native;
    }

    function setOneInchRouter(address _router) external onlyOwner {
        oneInchRouter = _router;
    }

    modifier onlyAutomator() {
        require(msg.sender == address(gelatoOps) || isLiquidator[address(msg.sender)], "onlyAutomator");
        _;
    }

    modifier onlyThis() {
        require(msg.sender == address(this));
        _;
    }

    modifier onlyPositionOwner(uint positionIndex) {
        require(positions[positionIndex].owner == address(msg.sender), "onlyPositionOwner");
        _;
    }

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

    function getUserFee(address user) public view returns (uint) {
        IMinimaxStaking staking = IMinimaxStaking(minimaxStaking);

        uint amountPool2 = staking.getUserAmount(2, user);
        uint amountPool3 = staking.getUserAmount(3, user);
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

    function getUserFeeAmount(address user, uint amount) public view returns (uint) {
        uint userFeeShare = getUserFee(user);
        return (amount * userFeeShare) / FEE_MULTIPLIER;
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

    function emergencyWithdraw(uint positionIndex) external onlyOwner {
        PositionLib.emergencyWithdraw(this, positions[positionIndex], positionIndex);
    }

    function setDepositFee(uint poolIdx, uint feeShare) external onlyOwner {
        require(poolIdx < depositFees.length, "wrong pool index");
        depositFees[poolIdx].fee = feeShare;
    }

    function setMinimaxStakingAddress(address stakingAddress) external onlyOwner {
        minimaxStaking = stakingAddress;
    }

    // Deprecated
    function getPositionBalances(uint[] calldata positionIndexes)
        public
        returns (PositionBalanceLib.PositionBalanceV1[] memory)
    {
        return PositionBalanceLib.getManyV1(this, positions, positionIndexes);
    }

    function getPositionBalancesV2(uint[] calldata positionIndexes)
        public
        returns (PositionBalanceLib.PositionBalanceV2[] memory)
    {
        return PositionBalanceLib.getManyV2(this, positions, positionIndexes);
    }

    function getPositionBalancesV3(uint[] calldata positionIndexes)
        public
        returns (PositionBalanceLib.PositionBalanceV3[] memory)
    {
        return PositionBalanceLib.getManyV3(this, positions, positionIndexes);
    }

    function stake(
        uint inputAmount,
        IERC20Upgradeable inputToken,
        uint stakingAmountMin,
        IERC20Upgradeable stakingToken,
        address stakingPool,
        uint maxSlippage,
        uint stopLossPrice,
        uint takeProfitPrice,
        uint swapKind,
        bytes calldata swapParams
    ) public payable nonReentrant returns (uint) {
        require(msg.value >= liquidatorFee, "gasTankThreshold");

        PositionLib.StakeParams memory stakeParams = PositionLib.StakeParams(
            inputAmount,
            inputToken,
            stakingAmountMin,
            stakingToken,
            stakingPool,
            maxSlippage,
            stopLossPrice,
            takeProfitPrice
        );

        uint positionIndex = lastPositionIndex;
        lastPositionIndex += 1;

        PositionInfo memory position = PositionLib.stake(
            this,
            proxyPool.acquire(),
            positionIndex,
            stakeParams,
            swapKind,
            swapParams
        );

        // NB: current implementation assume that liquidation in some way should work. If we want to deploy on a new
        // blockchain without liquidation, this code should be modified.
        if (address(gelatoOps) != address(0)) {
            position.gelatoLiquidateTaskId = _gelatoCreateTask(positionIndex);
        }

        depositGasTank(position.callerAddress);

        positions[positionIndex] = position;
        return positionIndex;
    }

    function swapEstimate(
        address inputToken,
        address stakingToken,
        uint inputTokenAmount
    ) public view returns (uint amountOut, bytes memory hints) {
        require(address(market) != address(0), "no market");
        return market.estimateOut(inputToken, stakingToken, inputTokenAmount);
    }

    function deposit(uint positionIndex, uint amount) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.deposit(this, positions[positionIndex], positionIndex, amount);
    }

    function setLiquidator(address user, bool value) external onlyOwner {
        isLiquidator[user] = value;
    }

    function alterPositionParams(
        uint positionIndex,
        uint newAmount,
        uint newStopLossPrice,
        uint newTakeProfitPrice,
        uint newSlippage
    ) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.alterPositionParams(
            this,
            positions[positionIndex],
            positionIndex,
            newAmount,
            newStopLossPrice,
            newTakeProfitPrice,
            newSlippage
        );
    }

    function withdrawAll(uint positionIndex) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.withdraw(
            this,
            positions[positionIndex],
            positionIndex,
            0,
            PositionLib.WithdrawType.Manual,
            PositionLib.WithdrawSimple,
            ""
        );
    }

    function withdraw(uint positionIndex, uint amount) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.withdraw(
            this,
            positions[positionIndex],
            positionIndex,
            amount,
            PositionLib.WithdrawType.Manual,
            PositionLib.WithdrawSimple,
            ""
        );
    }

    function estimateLpPartsForPosition(uint positionIndex)
        external
        nonReentrant
        onlyPositionOwner(positionIndex)
        returns (uint, uint)
    {
        return PositionLib.estimateLpParts(this, positions[positionIndex], positionIndex);
    }

    function estimateWithdrawalAmountForPosition(uint positionIndex)
        external
        nonReentrant
        onlyPositionOwner(positionIndex)
        returns (uint)
    {
        return PositionLib.estimateWithdrawnAmount(this, positions[positionIndex], positionIndex);
    }

    function withdrawAllWithSwap(
        uint positionIndex,
        address withdrawalToken,
        bytes memory oneInchCallData
    ) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.withdraw(
            this,
            positions[positionIndex],
            positionIndex,
            0,
            PositionLib.WithdrawType.Manual,
            PositionLib.WithdrawSwapOneInchSingle,
            abi.encode(PositionLib.WithdrawSwapOneInchSingleParams(withdrawalToken, oneInchCallData))
        );
    }

    // TODO: add slippage for swaps
    function withdrawAllWithSwapLp(
        uint positionIndex,
        address withdrawalToken,
        bytes memory oneInchCallDataToken0,
        bytes memory oneInchCallDataToken1
    ) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.withdraw(
            this,
            positions[positionIndex],
            positionIndex,
            0,
            PositionLib.WithdrawType.Manual,
            PositionLib.WithdrawSwapOneInchPair,
            abi.encode(
                PositionLib.WithdrawSwapOneInchPairParams(withdrawalToken, oneInchCallDataToken0, oneInchCallDataToken1)
            )
        );
    }

    function withdrawV2(
        uint positionIndex,
        uint amount,
        bool amountAll,
        uint withdrawSwapKind,
        bytes calldata withdrawSwapParams
    ) external nonReentrant onlyPositionOwner(positionIndex) {
        PositionLib.withdraw(
            this,
            positions[positionIndex],
            positionIndex,
            amountAll ? 0 : amount,
            PositionLib.WithdrawType.Manual,
            withdrawSwapKind,
            withdrawSwapParams
        );
    }

    function closePosition(uint positionIndex) external onlyThis {
        PositionInfo storage position = positions[positionIndex];

        position.closed = true;

        if (isModernProxy(position.callerAddress)) {
            withdrawGasTank(position.callerAddress, position.owner);
            proxyPool.release(position.callerAddress);
        }

        _gelatoCancelTask(position.gelatoLiquidateTaskId);
    }

    function depositGasTank(ProxyCaller proxy) private {
        address(proxy).call{value: msg.value}("");
    }

    function withdrawGasTank(ProxyCaller proxy, address owner) private {
        proxy.transferNativeAll(owner);
    }

    function isModernProxy(ProxyCaller proxy) public view returns (bool) {
        return address(proxy).code.length == 945;
    }

    // -----------------------------------------------------------------------------------------------------------------
    // Position events.

    function emitPositionWasModified(uint positionIndex) external onlyThis {
        emit PositionWasModified(positionIndex);
    }

    function emitPositionWasCreated(uint positionIndex, IERC20Upgradeable stakedToken) external onlyThis {
        // TODO(TmLev): Remove once `PositionWasCreatedV2` is stable.
        emit PositionWasCreated(positionIndex);

        (uint price, uint8 priceDecimals) = PositionLib.estimatePositionStakedTokenPrice(this, stakedToken);
        emit PositionWasCreatedV2(positionIndex, block.timestamp, price, priceDecimals);
    }

    function emitPositionWasClosed(uint positionIndex, IERC20Upgradeable stakedToken) external onlyThis {
        // TODO(TmLev): Remove once `PositionWasClosedV2` is stable.
        emit PositionWasClosed(positionIndex);

        (uint price, uint8 priceDecimals) = PositionLib.estimatePositionStakedTokenPrice(this, stakedToken);
        emit PositionWasClosedV2(positionIndex, block.timestamp, price, priceDecimals);
    }

    function emitPositionWasLiquidated(uint positionIndex, IERC20Upgradeable stakedToken) external onlyThis {
        // TODO(TmLev): Remove once `PositionWasLiquidatedV2` is stable.
        emit PositionWasClosed(positionIndex);

        (uint price, uint8 priceDecimals) = PositionLib.estimatePositionStakedTokenPrice(this, stakedToken);
        emit PositionWasLiquidatedV2(positionIndex, block.timestamp, price, priceDecimals);
    }

    function emitStakedBaseTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external onlyThis {
        emit StakedBaseTokenWithdraw(positionIndex, token, amount);
    }

    function emitStakedSwapTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external onlyThis {
        emit StakedSwapTokenWithdraw(positionIndex, token, amount);
    }

    function emitRewardTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external onlyThis {
        emit RewardTokenWithdraw(positionIndex, token, amount);
    }

    // -----------------------------------------------------------------------------------------------------------------
    // Gelato

    struct AutomationParams {
        uint256 positionIndex;
        uint256 minAmountOut;
        bytes marketHints;
    }

    function automationResolve(uint positionIndex) public returns (bool canExec, bytes memory execPayload) {
        PositionInfo storage position = positions[positionIndex];
        uint256 amountOut;
        bytes memory hints;
        (canExec, amountOut, hints) = PositionLib.isOutsideRange(this, position);
        if (canExec) {
            uint minAmountOut = amountOut - (amountOut * position.maxSlippage) / SLIPPAGE_MULTIPLIER;
            AutomationParams memory params = AutomationParams(positionIndex, minAmountOut, hints);
            execPayload = abi.encodeWithSelector(this.automationExec.selector, abi.encode(params));
        }
    }

    function automationExec(bytes calldata raw) public onlyAutomator {
        AutomationParams memory params = abi.decode(raw, (AutomationParams));
        _gelatoPayFee(params.positionIndex);
        PositionLib.withdraw(
            this,
            positions[params.positionIndex],
            params.positionIndex,
            0,
            PositionLib.WithdrawType.Liquidation,
            PositionLib.WithdrawSwapMarket,
            abi.encode(PositionLib.WithdrawSwapMarketParams(params.minAmountOut, params.marketHints))
        );
    }

    function _gelatoPayFee(uint positionIndex) private {
        uint feeAmount;
        address feeDestination;

        if (address(gelatoOps) != address(0)) {
            address feeToken;
            (feeAmount, feeToken) = gelatoOps.getFeeDetails();
            if (feeAmount == 0) {
                return;
            }

            require(feeToken == GelatoNativeToken);

            feeDestination = gelatoOps.gelato();
        } else {
            feeAmount = liquidatorFee;
            feeDestination = msg.sender;
        }

        ProxyCaller proxy = positions[positionIndex].callerAddress;
        proxy.transferNative(feeDestination, feeAmount);
    }

    function _gelatoCreateTask(uint positionIndex) private returns (bytes32) {
        return
            gelatoOps.createTaskNoPrepayment(
                address(this), /* execAddress */
                this.automationExec.selector, /* execSelector */
                address(this), /* resolverAddress */
                abi.encodeWithSelector(this.automationResolve.selector, positionIndex), /* resolverData */
                GelatoNativeToken
            );
    }

    function _gelatoCancelTask(bytes32 gelatoTaskId) private {
        if (address(gelatoOps) != address(0) && gelatoTaskId != "") {
            gelatoOps.cancelTask(gelatoTaskId);
        }
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

interface IMinimaxStaking {
    function getUserAmount(uint _pid, address _user) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../pool/IPoolAdapter.sol";
import "../interfaces/IPriceOracle.sol";
import "../market/IMarket.sol";

interface IMinimaxMain {
    function getUserFeeAmount(address user, uint stakeAmount) external view returns (uint);

    function oneInchRouter() external view returns (address);

    function market() external view returns (IMarket);

    function priceOracles(IERC20Upgradeable) external view returns (IPriceOracle);

    function getPoolAdapterSafe(address pool) external view returns (IPoolAdapter);

    function poolAdapters(uint256 pool) external view returns (IPoolAdapter);

    function busdAddress() external view returns (address);

    function emitPositionWasModified(uint positionIndex) external;

    function emitPositionWasCreated(uint positionIndex, IERC20Upgradeable stakedToken) external;

    function emitPositionWasClosed(uint positionIndex, IERC20Upgradeable stakedToken) external;

    function emitPositionWasLiquidated(uint positionIndex, IERC20Upgradeable stakedToken) external;

    function emitStakedBaseTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external;

    function emitStakedSwapTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external;

    function emitRewardTokenWithdraw(
        uint positionIndex,
        address token,
        uint amount
    ) external;

    function closePosition(uint positionIndex) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
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

interface IPoolAdapter {
    function stakingBalance(address pool, bytes memory) external returns (uint256);

    function rewardBalances(address, bytes memory) external returns (uint256[] memory);

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

    function rewardTokens(address pool, bytes memory args) external view returns (address[] memory);
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
import "./ProxyCaller.sol";
import "./market/IMarket.sol";
import "./pool/IPoolAdapter.sol";

library ProxyCallerApi {
    function propagateError(
        bool success,
        bytes memory data,
        string memory errorMessage
    ) public {
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
    ) external {
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
    ) external returns (uint256) {
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
    ) external returns (uint256) {
        uint256[] memory balances = rewardBalances(proxy, adapter, pool, args);
        if (balances.length > 0) {
            return balances[0];
        }

        return 0;
    }

    function rewardBalances(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        bytes memory args
    ) public returns (uint256[] memory) {
        (bool success, bytes memory data) = proxy.exec(
            true, /* delegate */
            address(adapter), /* target */
            abi.encodeWithSignature("rewardBalances(address,bytes)", pool, args) /* data */
        );

        propagateError(success, data, "reward balances failed");

        return abi.decode(data, (uint256[]));
    }

    function withdraw(
        ProxyCaller proxy,
        IPoolAdapter adapter,
        address pool,
        uint256 amount,
        bytes memory args // used for passing stakedToken for Aave pools
    ) external {
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
    ) external {
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
    ) public {
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
    ) external returns (uint256) {
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
    ) external {
        (bool success, bytes memory data) = proxy.transfer(
            address(beneficiary), /* target */
            amount /* amount */
        );
        propagateError(success, data, "transfer native failed");
    }

    function transferNativeAll(ProxyCaller proxy, address beneficiary) external {
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
    ) external {
        (bool success, bytes memory data) = proxy.exec(
            false, /* delegate */
            address(token), /* target */
            abi.encodeWithSignature("approve(address,uint256)", beneficiary, amount) /* data */
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "approve failed");
    }

    function swap(
        ProxyCaller proxy,
        IMarket market,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint256) {
        (bool success, bytes memory data) = proxy.exec(
            false, /* delegate */
            address(market), /* target */
            abi.encodeWithSelector(market.swap.selector, tokenIn, tokenOut, amountIn, amountOutMin, destination, hints) /* data */
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

import "./ProxyCaller.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProxyCallerApi.sol";
import "./PositionInfo.sol";
import "./pool/IPoolAdapter.sol";
import "./interfaces/IMinimaxMain.sol";

library PositionBalanceLib {
    using ProxyCallerApi for ProxyCaller;

    struct PositionBalanceV3 {
        uint gasTank;
        uint stakedAmount;
        uint poolStakedAmount;
        uint[] poolRewardAmounts;
    }

    struct PositionBalanceV2 {
        uint gasTank;
        uint stakedAmount;
        uint poolStakedAmount;
        uint poolRewardAmount;
    }

    struct PositionBalanceV1 {
        uint total;
        uint reward;
        uint gasTank;
    }

    function getManyV3(
        IMinimaxMain main,
        mapping(uint => PositionInfo) storage positions,
        uint[] calldata positionIndexes
    ) public returns (PositionBalanceV3[] memory) {
        PositionBalanceV3[] memory balances = new PositionBalanceV3[](positionIndexes.length);
        for (uint i = 0; i < positionIndexes.length; ++i) {
            balances[i] = getV3(main, positions[positionIndexes[i]]);
        }
        return balances;
    }

    function getV3(IMinimaxMain main, PositionInfo storage position) public returns (PositionBalanceV3 memory result) {
        if (position.closed) {
            return result;
        }

        IPoolAdapter adapter = main.poolAdapters(uint256(keccak256(position.poolAddress.code)));

        result.gasTank = address(position.callerAddress).balance;
        result.stakedAmount = position.stakedAmount;
        result.poolStakedAmount = position.callerAddress.stakingBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );
        result.poolRewardAmounts = position.callerAddress.rewardBalances(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );

        return result;
    }

    function getManyV2(
        IMinimaxMain main,
        mapping(uint => PositionInfo) storage positions,
        uint[] calldata positionIndexes
    ) public returns (PositionBalanceV2[] memory) {
        PositionBalanceV2[] memory balances = new PositionBalanceV2[](positionIndexes.length);
        for (uint i = 0; i < positionIndexes.length; ++i) {
            balances[i] = getV2(main, positions[positionIndexes[i]]);
        }
        return balances;
    }

    function getV2(IMinimaxMain main, PositionInfo storage position) public returns (PositionBalanceV2 memory) {
        if (position.closed) {
            return PositionBalanceV2({gasTank: 0, stakedAmount: 0, poolStakedAmount: 0, poolRewardAmount: 0});
        }

        IPoolAdapter adapter = main.poolAdapters(uint256(keccak256(position.poolAddress.code)));

        uint gasTank = address(position.callerAddress).balance;
        uint stakingBalance = position.callerAddress.stakingBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );
        uint rewardBalance = position.callerAddress.rewardBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );

        return
            PositionBalanceV2({
                gasTank: gasTank,
                stakedAmount: position.stakedAmount,
                poolStakedAmount: stakingBalance,
                poolRewardAmount: rewardBalance
            });
    }

    function getManyV1(
        IMinimaxMain main,
        mapping(uint => PositionInfo) storage positions,
        uint[] calldata positionIndexes
    ) public returns (PositionBalanceV1[] memory) {
        PositionBalanceV1[] memory balances = new PositionBalanceV1[](positionIndexes.length);
        for (uint i = 0; i < positionIndexes.length; ++i) {
            balances[i] = getV1(main, positions[positionIndexes[i]]);
        }
        return balances;
    }

    function getV1(IMinimaxMain main, PositionInfo storage position) public returns (PositionBalanceV1 memory) {
        if (position.closed) {
            return PositionBalanceV1({total: 0, reward: 0, gasTank: 0});
        }

        IPoolAdapter adapter = main.poolAdapters(uint256(keccak256(position.poolAddress.code)));

        uint gasTank = address(position.callerAddress).balance;
        uint stakingBalance = position.callerAddress.stakingBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );
        uint rewardBalance = position.callerAddress.rewardBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken)
        );

        if (position.stakedToken != position.rewardToken) {
            return PositionBalanceV1({total: position.stakedAmount, reward: rewardBalance, gasTank: gasTank});
        }

        uint totalBalance = rewardBalance + stakingBalance;

        if (totalBalance < position.stakedAmount) {
            return PositionBalanceV1({total: totalBalance, reward: 0, gasTank: gasTank});
        }

        return PositionBalanceV1({total: totalBalance, reward: totalBalance - position.stakedAmount, gasTank: gasTank});
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./PositionInfo.sol";
import "./pool/IPoolAdapter.sol";
import "./ProxyCaller.sol";
import "./ProxyCallerApi.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IMinimaxMain.sol";
import "./interfaces/IERC20Decimals.sol";
import "./market/IMarket.sol";
import "./PositionBalanceLib.sol";
import "./PositionExchangeLib.sol";

library PositionLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using ProxyCallerApi for ProxyCaller;

    enum WithdrawType {
        Manual,
        Liquidation
    }

    uint public constant StakeSimpleKind = 1;

    uint public constant StakeSwapMarketKind = 2;

    struct StakeSwapMarket {
        bytes hints;
    }

    uint public constant StakeSwapOneInchKind = 3;

    struct StakeSwapOneInch {
        bytes oneInchCallData;
    }

    struct StakeParams {
        uint inputAmount;
        IERC20Upgradeable inputToken;
        uint stakingAmountMin;
        IERC20Upgradeable stakingToken;
        address stakingPool;
        uint maxSlippage;
        uint stopLossPrice;
        uint takeProfitPrice;
    }

    function stake(
        IMinimaxMain main,
        ProxyCaller proxy,
        uint positionIndex,
        StakeParams memory params,
        uint swapKind,
        bytes memory swapParams
    ) external returns (PositionInfo memory) {
        uint tokenAmount;
        if (swapKind == StakeSimpleKind) {
            tokenAmount = _stakeSimple(params);
        } else if (swapKind == StakeSwapMarketKind) {
            StakeSwapMarket memory decoded = abi.decode(swapParams, (StakeSwapMarket));
            tokenAmount = _stakeSwapMarket(main, params, decoded);
        } else if (swapKind == StakeSwapOneInchKind) {
            StakeSwapOneInch memory decoded = abi.decode(swapParams, (StakeSwapOneInch));
            tokenAmount = _stakeSwapOneInch(main, params, decoded);
        } else {
            revert("invalid stake kind param");
        }

        main.emitPositionWasCreated(positionIndex, params.stakingToken);

        return _createPosition(main, params, tokenAmount, positionIndex, proxy);
    }

    function _stakeSimple(StakeParams memory params) private returns (uint) {
        params.stakingToken.safeTransferFrom(address(msg.sender), address(this), params.inputAmount);
        return params.inputAmount;
    }

    function _stakeSwapMarket(
        IMinimaxMain main,
        StakeParams memory genericParams,
        StakeSwapMarket memory params
    ) private returns (uint) {
        IMarket market = main.market();
        require(address(market) != address(0), "no market");
        genericParams.inputToken.safeTransferFrom(address(msg.sender), address(this), genericParams.inputAmount);
        genericParams.inputToken.approve(address(market), genericParams.inputAmount);

        return
            market.swap(
                address(genericParams.inputToken),
                address(genericParams.stakingToken),
                genericParams.inputAmount,
                genericParams.stakingAmountMin,
                address(this),
                params.hints
            );
    }

    function makeSwapOneInch(
        uint amount,
        IERC20Upgradeable inputToken,
        address router,
        StakeSwapOneInch memory params
    ) public returns (uint) {
        require(router != address(0), "no 1inch router set");
        // Approve twice more in case of amount fluctuation between estimate and transaction
        inputToken.approve(router, amount * 2);

        (bool success, bytes memory retData) = router.call(params.oneInchCallData);

        ProxyCallerApi.propagateError(success, retData, "1inch");

        require(success == true, "calling 1inch got an error");
        (uint actualAmount, ) = abi.decode(retData, (uint, uint));
        return actualAmount;
    }

    function _stakeSwapOneInch(
        IMinimaxMain main,
        StakeParams memory genericParams,
        StakeSwapOneInch memory params
    ) private returns (uint) {
        genericParams.inputToken.safeTransferFrom(address(msg.sender), address(this), genericParams.inputAmount);
        address oneInchRouter = main.oneInchRouter();
        return makeSwapOneInch(genericParams.inputAmount, genericParams.inputToken, oneInchRouter, params);
    }

    function _createPosition(
        IMinimaxMain main,
        StakeParams memory params,
        uint tokenAmount,
        uint positionIndex,
        ProxyCaller proxy
    ) private returns (PositionInfo memory) {
        IPoolAdapter adapter = main.getPoolAdapterSafe(params.stakingPool);

        require(
            adapter.stakedToken(params.stakingPool, abi.encode(params.stakingToken)) == address(params.stakingToken),
            "_createPosition: invalid staking token."
        );

        require(tokenAmount > 0, "_createPosition: zero tokenAmount");

        address[] memory rewardTokens = adapter.rewardTokens(params.stakingPool, abi.encode(params.stakingToken));
        IERC20Upgradeable rewardToken = params.stakingToken;
        if (rewardTokens.length > 0) {
            rewardToken = IERC20Upgradeable(rewardTokens[0]);
        }

        uint userFeeAmount = main.getUserFeeAmount(address(msg.sender), tokenAmount);
        uint amountToStake = tokenAmount - userFeeAmount;

        PositionInfo memory position = PositionInfo({
            stakedAmount: amountToStake,
            feeAmount: userFeeAmount,
            stopLossPrice: params.stopLossPrice,
            maxSlippage: params.maxSlippage,
            poolAddress: params.stakingPool,
            owner: address(msg.sender),
            callerAddress: proxy,
            closed: false,
            takeProfitPrice: params.takeProfitPrice,
            stakedToken: params.stakingToken,
            rewardToken: rewardToken,
            gelatoLiquidateTaskId: 0
        });

        _proxyDeposit(position, adapter, amountToStake);

        return position;
    }

    function _proxyDeposit(
        PositionInfo memory position,
        IPoolAdapter adapter,
        uint amount
    ) private {
        position.stakedToken.safeTransfer(address(position.callerAddress), amount);
        position.callerAddress.approve(position.stakedToken, position.poolAddress, amount);
        position.callerAddress.deposit(
            adapter,
            position.poolAddress,
            amount,
            abi.encode(position.stakedToken) // pass stakedToken for aave pools
        );
    }

    function alterPositionParams(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        uint newAmount,
        uint newStopLossPrice,
        uint newTakeProfitPrice,
        uint newSlippage
    ) external {
        position.stopLossPrice = newStopLossPrice;
        position.takeProfitPrice = newTakeProfitPrice;
        position.maxSlippage = newSlippage;
        main.emitPositionWasModified(positionIndex);

        if (newAmount < position.stakedAmount) {
            uint withdrawAmount = position.stakedAmount - newAmount;
            IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);
            _withdrawToProxy(
                main,
                adapter,
                position,
                positionIndex,
                withdrawAmount, /* amountAll */
                WithdrawType.Manual
            );

            position.callerAddress.transferAll(position.stakedToken, position.owner);
            _withdrawRewards(main, adapter, position, positionIndex);
            return;
        }

        if (newAmount > position.stakedAmount) {
            uint depositAmount = newAmount - position.stakedAmount;
            deposit(main, position, positionIndex, depositAmount);
        }
    }

    // Emits `PositionsWasModified` always.
    function deposit(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        uint amount
    ) public {
        IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);

        require(position.owner == address(msg.sender), "deposit: only position owner allowed");
        require(position.closed == false, "deposit: position is closed");

        position.stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);

        uint userFeeAmount = main.getUserFeeAmount(msg.sender, amount);
        uint amountToDeposit = amount - userFeeAmount;

        position.stakedAmount = position.stakedAmount + amountToDeposit;
        position.feeAmount = position.feeAmount + userFeeAmount;

        _proxyDeposit(position, adapter, amountToDeposit);

        _withdrawRewards(main, adapter, position, positionIndex);
        main.emitPositionWasModified(positionIndex);
    }

    function emergencyWithdraw(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex
    ) external {
        position.callerAddress.transferAll(position.stakedToken, position.owner);
        IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);
        _withdrawRewards(main, adapter, position, positionIndex);
    }

    function estimatePositionStakedTokenPrice(IMinimaxMain minimaxMain, IERC20Upgradeable positionStakedToken)
        public
        returns (uint price, uint8 priceDecimals)
    {
        // Try price oracle first.

        IPriceOracle priceOracle = minimaxMain.priceOracles(positionStakedToken);
        if (address(priceOracle) != address(0)) {
            int price = Math.max(0, priceOracle.latestAnswer());
            return (uint(price), priceOracle.decimals());
        }

        // We don't have price oracles for `positionStakedToken` -- try to estimate via the Market.

        IMarket market = minimaxMain.market();

        // Market is unavailable, nothing we can do here.
        if (address(market) == address(0)) {
            return (0, 0);
        }

        uint8 positionStakedTokenDecimals = IERC20Decimals(address(positionStakedToken)).decimals();

        (bool success, bytes memory encodedEstimateOutResult) = address(market).call(
            abi.encodeCall(
                market.estimateOut,
                (address(positionStakedToken), minimaxMain.busdAddress(), 10**positionStakedTokenDecimals)
            )
        );
        if (!success) {
            return (0, 0);
        }

        (uint estimatedOut, ) = abi.decode(encodedEstimateOutResult, (uint256, bytes));
        uint8 stablecoinDecimals = IERC20Decimals(minimaxMain.busdAddress()).decimals();
        return (estimatedOut, stablecoinDecimals);
    }

    function estimateLpParts(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex
    ) public returns (uint, uint) {
        IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);

        _withdrawToProxy(main, adapter, position, positionIndex, 0, WithdrawType.Manual);

        uint withdrawnBalance = position.stakedToken.balanceOf(address(position.callerAddress));
        position.callerAddress.transferAll(position.stakedToken, address(main));

        IERC20Upgradeable(position.stakedToken).transfer(address(position.stakedToken), withdrawnBalance);

        (uint amount0, uint amount1) = IPairToken(address(position.stakedToken)).burn(address(main));
        return (amount0, amount1);
    }

    function estimateWithdrawnAmount(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex
    ) public returns (uint) {
        IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);

        _withdrawToProxy(main, adapter, position, positionIndex, 0, WithdrawType.Manual);
        return position.stakedToken.balanceOf(address(position.callerAddress));
    }

    function isOutsideRange(IMinimaxMain minimaxMain, PositionInfo storage position)
        external
        returns (
            bool isOutsideRange,
            uint256 amountOut,
            bytes memory hints
        )
    {
        if (_isClosed(position)) {
            return (isOutsideRange, amountOut, hints);
        }

        PositionBalanceLib.PositionBalanceV3 memory balance = PositionBalanceLib.getV3(minimaxMain, position);

        uint amountIn = balance.poolStakedAmount;
        (amountOut, hints) = minimaxMain.market().estimateOut(
            address(position.stakedToken),
            minimaxMain.busdAddress(),
            amountIn
        );

        uint8 outDecimals = IERC20Decimals(minimaxMain.busdAddress()).decimals();
        uint8 inDecimals = IERC20Decimals(address(position.stakedToken)).decimals();
        isOutsideRange = PositionExchangeLib.isPriceOutsideRange(
            position,
            amountOut,
            amountIn,
            outDecimals,
            inDecimals
        );
        if (!isOutsideRange) {
            return (isOutsideRange, amountOut, hints);
        }

        // if price oracle exists then double check
        // that price is outside range
        IPriceOracle oracle = minimaxMain.priceOracles(position.stakedToken);
        if (address(oracle) != address(0)) {
            uint oracleMultiplier = 10**oracle.decimals();
            uint oraclePrice = uint(oracle.latestAnswer());
            isOutsideRange = PositionExchangeLib.isPriceOutsideRange(position, oraclePrice, oracleMultiplier, 0, 0);
            if (!isOutsideRange) {
                return (isOutsideRange, amountOut, hints);
            }
        }

        return (isOutsideRange, amountOut, hints);
    }

    uint public constant WithdrawSimple = 1;

    uint public constant WithdrawSwapMarket = 2;

    struct WithdrawSwapMarketParams {
        uint amountOutMin;
        bytes hints;
    }

    uint public constant WithdrawSwapOneInchSingle = 3;

    struct WithdrawSwapOneInchSingleParams {
        address withdrawToken;
        bytes oneInchCallData;
    }

    uint public constant WithdrawSwapOneInchPair = 4;

    struct WithdrawSwapOneInchPairParams {
        address withdrawToken;
        bytes oneInchCallDataToken0;
        bytes oneInchCallDataToken1;
    }

    function withdraw(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        uint amount,
        WithdrawType withdrawType,
        uint withdrawSwapKind,
        bytes memory withdrawSwapParams
    ) public {
        IPoolAdapter adapter = main.getPoolAdapterSafe(position.poolAddress);
        _withdrawToProxy(main, adapter, position, positionIndex, amount, withdrawType);
        _withdrawRewards(main, adapter, position, positionIndex);
        _withdrawStaked(main, position, positionIndex, withdrawSwapKind, withdrawSwapParams);
    }

    function _withdrawRewards(
        IMinimaxMain main,
        IPoolAdapter adapter,
        PositionInfo storage position,
        uint positionIndex
    ) private {
        address[] memory rewardTokens = adapter.rewardTokens(position.poolAddress, abi.encode(position.stakedToken));
        for (uint i = 0; i < rewardTokens.length; i++) {
            uint amount = position.callerAddress.transferAll(IERC20Upgradeable(rewardTokens[i]), position.owner);
            main.emitRewardTokenWithdraw(positionIndex, rewardTokens[i], amount);
        }
    }

    function _withdrawStaked(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        uint withdrawSwapKind,
        bytes memory withdrawSwapParams
    ) private {
        if (withdrawSwapKind == WithdrawSimple) {
            _withdrawNoSwap(main, position, positionIndex);
        } else if (withdrawSwapKind == WithdrawSwapMarket) {
            WithdrawSwapMarketParams memory decoded = abi.decode(withdrawSwapParams, (WithdrawSwapMarketParams));
            _withdrawMarketSwap(main, position, positionIndex, decoded.amountOutMin, decoded.hints);
        } else if (withdrawSwapKind == WithdrawSwapOneInchSingle) {
            WithdrawSwapOneInchSingleParams memory decoded = abi.decode(
                withdrawSwapParams,
                (WithdrawSwapOneInchSingleParams)
            );
            _withdrawOneInchSingleSwap(main, position, positionIndex, decoded.withdrawToken, decoded.oneInchCallData);
        } else if (withdrawSwapKind == WithdrawSwapOneInchPair) {
            WithdrawSwapOneInchPairParams memory decoded = abi.decode(
                withdrawSwapParams,
                (WithdrawSwapOneInchPairParams)
            );
            _withdrawOneInchPairSwap(
                main,
                position,
                positionIndex,
                decoded.withdrawToken,
                decoded.oneInchCallDataToken0,
                decoded.oneInchCallDataToken0
            );
        } else {
            revert("unexpected withdrawSwapKind");
        }
    }

    function _withdrawNoSwap(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex
    ) private {
        uint amount = position.callerAddress.transferAll(position.stakedToken, position.owner);
        main.emitStakedBaseTokenWithdraw(positionIndex, address(position.stakedToken), amount);
    }

    function _withdrawMarketSwap(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        uint amountOutMin,
        bytes memory marketHints
    ) private {
        IMarket market = main.market();
        uint stakedAmount = IERC20Upgradeable(position.stakedToken).balanceOf(address(position.callerAddress));
        main.emitStakedBaseTokenWithdraw(positionIndex, address(position.stakedToken), stakedAmount);

        position.callerAddress.approve(position.stakedToken, address(market), stakedAmount);

        address withdrawToken = main.busdAddress();
        uint amountOut = position.callerAddress.swap(
            market, // adapter
            address(position.stakedToken), // tokenIn
            withdrawToken, // tokenOut
            stakedAmount, // amountIn
            amountOutMin, // amountOutMin
            position.owner, // to
            marketHints // hints
        );
        main.emitStakedSwapTokenWithdraw(positionIndex, withdrawToken, amountOut);
    }

    function _withdrawOneInchSingleSwap(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        address withdrawToken,
        bytes memory oneInchCallData
    ) private {
        uint stakedAmount = position.callerAddress.transferAll(position.stakedToken, address(this));
        main.emitStakedBaseTokenWithdraw(positionIndex, address(position.stakedToken), stakedAmount);

        address oneInchRouter = main.oneInchRouter();
        uint amountOut = makeSwapOneInch(
            stakedAmount,
            position.stakedToken,
            oneInchRouter,
            StakeSwapOneInch(oneInchCallData)
        );

        IERC20Upgradeable(withdrawToken).safeTransfer(msg.sender, amountOut);
        main.emitStakedSwapTokenWithdraw(positionIndex, withdrawToken, amountOut);
    }

    function _withdrawOneInchPairSwap(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex,
        address withdrawToken,
        bytes memory oneInchCallDataToken0,
        bytes memory oneInchCallDataToken1
    ) private {
        (IERC20Upgradeable token0, uint amount0, IERC20Upgradeable token1, uint amount1) = _burnStaked(
            main,
            position,
            positionIndex
        );
        address oneInchRouter = main.oneInchRouter();
        uint amountOutToken0 = makeSwapOneInch(amount0, token0, oneInchRouter, StakeSwapOneInch(oneInchCallDataToken0));
        uint amountOutToken1 = makeSwapOneInch(amount1, token1, oneInchRouter, StakeSwapOneInch(oneInchCallDataToken1));
        uint amountOut = amountOutToken0 + amountOutToken1;
        IERC20Upgradeable(withdrawToken).safeTransfer(msg.sender, amountOut);
        main.emitStakedSwapTokenWithdraw(positionIndex, withdrawToken, amountOut);
    }

    function _burnStaked(
        IMinimaxMain main,
        PositionInfo storage position,
        uint positionIndex
    )
        private
        returns (
            IERC20Upgradeable token0,
            uint amount0,
            IERC20Upgradeable token1,
            uint amount1
        )
    {
        uint stakedAmount = position.callerAddress.transferAll(position.stakedToken, address(this));
        main.emitStakedBaseTokenWithdraw(positionIndex, address(position.stakedToken), stakedAmount);

        // TODO: when fee of contract is non-zero, then ensure fees from LP-tokens are not burned here
        address lpToken = address(position.stakedToken);
        IERC20Upgradeable(lpToken).transfer(address(lpToken), stakedAmount);
        (amount0, amount1) = IPairToken(lpToken).burn(address(this));
        token0 = IERC20Upgradeable(IPairToken(lpToken).token0());
        token1 = IERC20Upgradeable(IPairToken(lpToken).token1());
        return (token0, amount0, token1, amount1);
    }

    function _isClosed(PositionInfo storage position) private view returns (bool) {
        return position.closed || position.owner == address(0);
    }

    // Withdraws specified amount from pool to proxy
    // If pool balance after withdraw equals zero then position is closed
    // By the end of the function staked and reward tokens are on proxy balance
    function _withdrawToProxy(
        IMinimaxMain main,
        IPoolAdapter adapter,
        PositionInfo storage position,
        uint positionIndex,
        uint amount,
        WithdrawType reason
    ) private {
        require(!_isClosed(position), "_withdraw: position closed");

        if (amount == 0) {
            position.callerAddress.withdrawAll(
                adapter,
                position.poolAddress,
                abi.encode(position.stakedToken) // pass stakedToken for aave pools
            );

            if (reason == WithdrawType.Manual) {
                main.emitPositionWasClosed(positionIndex, position.stakedToken);
                main.closePosition(positionIndex);
                return;
            }

            if (reason == WithdrawType.Liquidation) {
                main.emitPositionWasLiquidated(positionIndex, position.stakedToken);
                main.closePosition(positionIndex);
                return;
            }

            return;
        }

        position.callerAddress.withdraw(
            adapter,
            position.poolAddress,
            amount,
            abi.encode(position.stakedToken) // pass stakedToken for aave pools
        );

        uint poolBalance = position.callerAddress.stakingBalance(
            adapter,
            position.poolAddress,
            abi.encode(position.stakedToken) // pass stakedToken for aave pools
        );

        if (poolBalance == 0) {
            main.emitPositionWasClosed(positionIndex, position.stakedToken);
            main.closePosition(positionIndex);
            return;
        }

        main.emitPositionWasModified(positionIndex);

        // When user withdraws partially, stakedAmount should only decrease
        //
        // Consider the following case:
        // position.stakedAmount = 100
        // pool.stakingBalance = 120
        //
        // If user withdraws 10, then:
        // position.stakedAmount = 100
        // pool.stakingBalance = 110
        //
        // If user withdraws 30, then:
        // position.stakedAmount = 90
        // pool.stakingBalance = 90
        //
        if (poolBalance < position.stakedAmount) {
            position.stakedAmount = poolBalance;
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

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Hints.sol";
import "./v2/PancakeLpMarket.sol";

interface IMarket {
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint256);

    function estimateOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256 amountOut, bytes memory hints);

    function estimateBurn(address lpToken, uint amountIn) external view returns (uint, uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ArrayHelper.sol";

library Hints {
    uint8 private constant IS_PAIR = 0;
    uint8 private constant PAIR_INPUT = 1;
    uint8 private constant RELAY = 2;
    uint8 private constant ROUTER = 3;

    function setIsPair(address key) internal pure returns (bytes memory) {
        return _encode(IS_PAIR, uint160(key), 1);
    }

    function getIsPair(bytes memory hints, address key) internal pure returns (bool isPairToken) {
        return _decode(hints, IS_PAIR, uint160(key)) == 1;
    }

    function setPairInput(address key, uint value) internal pure returns (bytes memory) {
        return _encode(PAIR_INPUT, uint160(key), value);
    }

    function getPairInput(bytes memory hints, address key) internal pure returns (uint value) {
        value = _decode(hints, PAIR_INPUT, uint160(key));
    }

    function setRouter(
        address tokenIn,
        address tokenOut,
        address router
    ) internal pure returns (bytes memory) {
        return _encodeAddress(ROUTER, _hashTuple(tokenIn, tokenOut), router);
    }

    function getRouter(
        bytes memory hints,
        address tokenIn,
        address tokenOut
    ) internal pure returns (address router) {
        return _decodeAddress(hints, ROUTER, _hashTuple(tokenIn, tokenOut));
    }

    function setRelay(
        address tokenIn,
        address tokenOut,
        address relay
    ) internal pure returns (bytes memory) {
        return _encodeAddress(RELAY, _hashTuple(tokenIn, tokenOut), relay);
    }

    function getRelay(
        bytes memory hints,
        address tokenIn,
        address tokenOut
    ) internal pure returns (address) {
        return _decodeAddress(hints, RELAY, _hashTuple(tokenIn, tokenOut));
    }

    function merge2(bytes memory h0, bytes memory h1) internal pure returns (bytes memory) {
        return abi.encodePacked(h0, h1);
    }

    function merge3(
        bytes memory h0,
        bytes memory h1,
        bytes memory h2
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(h0, h1, h2);
    }

    function empty() internal pure returns (bytes memory) {
        return "";
    }

    function _encode(
        uint8 kind,
        uint key,
        uint value
    ) private pure returns (bytes memory) {
        return abi.encodePacked(kind, key, value);
    }

    function _encodeAddress(
        uint8 kind,
        uint key,
        address value
    ) private pure returns (bytes memory) {
        return _encode(kind, key, uint160(value));
    }

    function _decode(
        bytes memory hints,
        uint8 kind,
        uint key
    ) private pure returns (uint value) {
        // each hint takes 65 bytes (1+32+32). 1 byte for kind, 32 bytes for key, 32 bytes for value
        for (uint i = 0; i < hints.length; i += 65) {
            // kind is at offset 0
            if (uint8(hints[i]) != kind) {
                continue;
            }
            // key is at offset 1
            if (ArrayHelper.sliceUint(hints, i + 1) != key) {
                continue;
            }
            // value is at offset 33 (1+32)
            return ArrayHelper.sliceUint(hints, i + 33);
        }
    }

    function _decodeAddress(
        bytes memory hints,
        uint8 kind,
        uint key
    ) private pure returns (address) {
        return address(uint160(_decode(hints, kind, key)));
    }

    function _hashTuple(address a1, address a2) private pure returns (uint256) {
        uint256 u1 = uint160(a1);
        uint256 u2 = uint160(a2);
        u2 = u2 << 96;
        return u1 ^ u2;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./IPairToken.sol";
import "../ArrayHelper.sol";
import "../Hints.sol";
import "../SingleMarket.sol";
import "../../interfaces/IPancakeFactory.sol";
import "../../interfaces/IPancakeRouter.sol";
import "../../helpers/Math.sol";

contract PancakeLpMarket is OwnableUpgradeable {
    using ArrayHelper for uint[];

    address public relayToken;
    SingleMarket public market;

    constructor() initializer {
        __Ownable_init();
    }

    function setRelayToken(address _relayToken) external onlyOwner {
        relayToken = _relayToken;
    }

    function setMarket(SingleMarket _market) external onlyOwner {
        market = _market;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint) {
        IERC20Upgradeable(tokenIn).transferFrom(address(msg.sender), address(this), amountIn);
        if (tokenIn == tokenOut) {
            require(amountIn >= amountOutMin, "amountOutMin");
            IERC20Upgradeable(tokenIn).transfer(destination, amountIn);
            return amountIn;
        }

        bool tokenInPair = Hints.getIsPair(hints, tokenIn);
        bool tokenOutPair = Hints.getIsPair(hints, tokenOut);
        uint amountOut;
        if (tokenInPair && tokenOutPair) {
            uint amountRelay = _swapPairToSingle(tokenIn, relayToken, amountIn, hints);
            amountOut = _swapSingleToPair(tokenIn, tokenOut, amountIn, hints);
        }

        if (tokenInPair && !tokenOutPair) {
            amountOut = _swapPairToSingle(tokenIn, tokenOut, amountIn, hints);
        }

        if (!tokenInPair && tokenOutPair) {
            amountOut = _swapSingleToPair(tokenIn, tokenOut, amountIn, hints);
        }

        if (!tokenInPair && !tokenOutPair) {
            amountOut = _swapSingles(tokenIn, tokenOut, amountIn, hints);
        }

        IERC20Upgradeable(tokenOut).transfer(destination, amountOut);
        require(amountOut >= amountOutMin, "amountOutMin");
        return amountOut;
    }

    function _swapPairToSingle(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bytes memory hints
    ) private returns (uint) {
        IPairToken pairIn = IPairToken(tokenIn);
        address token0 = pairIn.token0();
        address token1 = pairIn.token1();
        IERC20Upgradeable(tokenIn).transfer(tokenIn, amountIn);
        (uint amount0, uint amount1) = pairIn.burn(address(this));
        return _swapSingles(token0, tokenOut, amount0, hints) + _swapSingles(token1, tokenOut, amount1, hints);
    }

    function _swapSingleToPair(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bytes memory hints
    ) private returns (uint) {
        IPairToken pair = IPairToken(tokenOut);

        uint amountIn0 = Hints.getPairInput(hints, tokenOut);
        require(amountIn0 > 0, "swapSingleToPair: no hint");

        uint amountIn1 = amountIn - amountIn0;

        uint amount0 = _swapSingles(tokenIn, pair.token0(), amountIn0, hints);
        uint amount1 = _swapSingles(tokenIn, pair.token1(), amountIn1, hints);

        (uint liquidity, uint effective0, uint effective1) = _calculateEffective(pair, amount0, amount1);
        IERC20Upgradeable(pair.token0()).transfer(address(pair), effective0);
        IERC20Upgradeable(pair.token1()).transfer(address(pair), effective1);
        return pair.mint(address(this));
    }

    function _swapSingles(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bytes memory hints
    ) private returns (uint) {
        if (tokenIn == tokenOut) {
            return amountIn;
        }

        IERC20Upgradeable(tokenIn).approve(address(market), amountIn);
        return market.swap(tokenIn, tokenOut, amountIn, 0, address(this), hints);
    }

    function estimateOut(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bool tokenInPair,
        bool tokenOutPair
    ) external view returns (uint amountOut, bytes memory hints) {
        if (tokenIn == tokenOut) {
            return (amountIn, Hints.empty());
        }

        uint amountRelay;
        uint amountOut;
        bytes memory hints0;
        bytes memory hints1;

        if (tokenInPair && tokenOutPair) {
            (amountRelay, hints0) = _estimatePairToSingle(tokenIn, relayToken, amountIn);
            (amountOut, hints1) = _estimateSingleToPair(relayToken, tokenOut, amountRelay);
        }

        if (tokenInPair && !tokenOutPair) {
            (amountOut, hints0) = _estimatePairToSingle(tokenIn, tokenOut, amountIn);
        }

        if (!tokenInPair && tokenOutPair) {
            (amountOut, hints0) = _estimateSingleToPair(tokenIn, tokenOut, amountIn);
        }

        if (!tokenInPair && !tokenOutPair) {
            (amountOut, hints0) = market.estimateOut(tokenIn, tokenOut, amountIn);
        }

        return (amountOut, Hints.merge2(hints0, hints1));
    }

    struct reservesState {
        address token0;
        address token1;
        uint reserve0;
        uint reserve1;
    }

    function estimateBurn(address lpToken, uint amountIn) public view returns (uint, uint) {
        IPairToken pair = IPairToken(lpToken);

        reservesState memory state;
        state.token0 = pair.token0();
        state.token1 = pair.token1();

        state.reserve0 = IERC20Upgradeable(state.token0).balanceOf(address(lpToken));
        state.reserve1 = IERC20Upgradeable(state.token1).balanceOf(address(lpToken));
        uint totalSupply = pair.totalSupply();

        uint amount0 = (amountIn * state.reserve0) / totalSupply;
        uint amount1 = (amountIn * state.reserve1) / totalSupply;

        return (amount0, amount1);
    }

    function _estimatePairToSingle(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        (uint amount0, uint amount1) = estimateBurn(tokenIn, amountIn);

        (uint amountOut0, bytes memory hint0) = market.estimateOut(IPairToken(tokenIn).token0(), tokenOut, amount0);
        (uint amountOut1, bytes memory hint1) = market.estimateOut(IPairToken(tokenIn).token1(), tokenOut, amount1);
        amountOut = amountOut0 + amountOut1;
        hints = Hints.merge2(hint0, hint1);
    }

    function _estimateSingleToPair(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        IPairToken pair = IPairToken(tokenOut);
        uint amountIn0 = _calculatePairInput0(tokenIn, pair, amountIn);
        uint amountIn1 = amountIn - amountIn0;
        (uint amountOut0, bytes memory hints0) = market.estimateOut(tokenIn, pair.token0(), amountIn0);
        (uint amountOut1, bytes memory hints1) = market.estimateOut(tokenIn, pair.token1(), amountIn1);

        (uint liquidity, , ) = _calculateEffective(pair, amountOut0, amountOut1);
        amountOut = liquidity;
        hints = Hints.merge3(hints0, hints1, Hints.setPairInput(tokenOut, amountIn0));
    }

    // assume that pair consists of token0 and token1
    // _calculatePairInput0 returns the amount of tokenIn that
    // should be exchanged on token0,
    // so that token0 and token1 proportion match reserves proportions
    function _calculatePairInput0(
        address tokenIn,
        IPairToken pair,
        uint amountIn
    ) private view returns (uint) {
        reservesState memory state;
        state.token0 = pair.token0();
        state.token1 = pair.token1();
        (state.reserve0, state.reserve1, ) = pair.getReserves();

        (, bytes memory hints0) = market.estimateOut(tokenIn, state.token0, amountIn / 2);
        (, bytes memory hints1) = market.estimateOut(tokenIn, state.token1, amountIn / 2);

        uint left = 0;
        uint right = amountIn;
        uint eps = amountIn / 1000;

        while (right - left >= eps) {
            uint left_third = left + (right - left) / 3;
            uint right_third = right - (right - left) / 3;
            uint f_left = _targetFunction(state, tokenIn, amountIn, left_third, hints0, hints1);
            uint f_right = _targetFunction(state, tokenIn, amountIn, right_third, hints0, hints1);
            if (f_left < f_right) {
                left = left_third;
            } else {
                right = right_third;
            }
        }

        return (left + right) / 2;
    }

    function _targetFunction(
        reservesState memory state,
        address tokenIn,
        uint amountIn,
        uint amount0,
        bytes memory hints0,
        bytes memory hints1
    ) private view returns (uint) {
        uint amountOut0 = market.estimateOutWithHints(tokenIn, state.token0, amount0, hints0) * state.reserve1;
        uint amountOut1 = market.estimateOutWithHints(tokenIn, state.token1, amountIn - amount0, hints1) *
            state.reserve0;
        return Math.min(amountOut0, amountOut1);
    }

    function _calculateEffective(
        IPairToken pair,
        uint amountIn0,
        uint amountIn1
    )
        private
        view
        returns (
            uint liquidity,
            uint effective0,
            uint effective1
        )
    {
        (uint r0, uint r1, ) = pair.getReserves();
        uint totalSupply = pair.totalSupply();
        liquidity = Math.min((amountIn0 * totalSupply) / r0, (amountIn1 * totalSupply) / r1);
        effective0 = (liquidity * r0) / totalSupply;
        effective1 = (liquidity * r1) / totalSupply;
    }

    function transferTo(
        address token,
        address to,
        uint amount
    ) external onlyOwner {
        address nativeToken = address(0);
        if (token == nativeToken) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "transferTo failed");
        } else {
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(token), to, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ArrayHelper {
    function first(uint256[] memory arr) internal pure returns (uint256) {
        return arr[0];
    }

    function last(uint256[] memory arr) internal pure returns (uint256) {
        return arr[arr.length - 1];
    }

    // assume that b is encoded uint[]
    function lastUint(bytes memory b) internal pure returns (uint res) {
        require(b.length >= 32, "lastUint: out of range");
        uint i = b.length - 32;
        assembly {
            res := mload(add(b, add(0x20, i)))
        }
    }

    function sliceUint(bytes memory b, uint i) internal pure returns (uint res) {
        require(b.length >= i + 32, "sliceUint: out of range");
        assembly {
            res := mload(add(b, add(0x20, i)))
        }
    }

    function new2(address a0, address a1) internal pure returns (address[] memory) {
        address[] memory p = new address[](2);
        p[0] = a0;
        p[1] = a1;
        return p;
    }

    function new3(
        address a0,
        address a1,
        address a2
    ) internal pure returns (address[] memory) {
        address[] memory p = new address[](3);
        p[0] = a0;
        p[1] = a1;
        p[2] = a2;
        return p;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IPairToken is IERC20Upgradeable {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function burn(address to) external returns (uint amount0, uint amount1);

    function mint(address to) external returns (uint liquidity);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./ArrayHelper.sol";
import "./Hints.sol";

interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract SingleMarket is OwnableUpgradeable {
    using ArrayHelper for uint[];

    address[] public relayTokens;
    IRouter[] public routers;

    constructor() initializer {
        __Ownable_init();
    }

    function getRelayTokens() external view returns (address[] memory) {
        return relayTokens;
    }

    function setRelayTokens(address[] calldata _relayTokens) external onlyOwner {
        relayTokens = _relayTokens;
    }

    function getRouters() external view returns (IRouter[] memory) {
        return routers;
    }

    function setRouters(IRouter[] calldata _routers) external onlyOwner {
        routers = _routers;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination,
        bytes memory hints
    ) external returns (uint) {
        IERC20Upgradeable(tokenIn).transferFrom(address(msg.sender), address(this), amountIn);
        if (tokenIn == tokenOut) {
            require(amountIn >= amountOutMin, "amountOutMin");
            IERC20Upgradeable(tokenIn).transfer(destination, amountIn);
            return amountIn;
        }

        address tokenRelay = Hints.getRelay(hints, tokenIn, tokenOut);
        if (tokenRelay == address(0)) {
            address router = Hints.getRouter(hints, tokenIn, tokenOut);
            return _swapDirect(router, tokenIn, tokenOut, amountIn, amountOutMin, destination);
        }

        address routerIn = Hints.getRouter(hints, tokenIn, tokenRelay);
        address routerOut = Hints.getRouter(hints, tokenRelay, tokenOut);
        return _swapRelay(routerIn, routerOut, tokenIn, tokenRelay, tokenOut, amountIn, amountOutMin, destination);
    }

    function _swapDirect(
        address router,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination
    ) private returns (uint) {
        IERC20Upgradeable(tokenIn).approve(router, amountIn);
        return
            IRouter(router)
                .swapExactTokensForTokens({
                    amountIn: amountIn,
                    amountOutMin: amountOutMin,
                    path: ArrayHelper.new2(tokenIn, tokenOut),
                    to: destination,
                    deadline: block.timestamp
                })
                .last();
    }

    function _swapRelay(
        address routerIn,
        address routerOut,
        address tokenIn,
        address tokenRelay,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address destination
    ) private returns (uint) {
        if (routerIn == routerOut) {
            IERC20Upgradeable(tokenIn).approve(routerIn, amountIn);
            return
                IRouter(routerIn)
                    .swapExactTokensForTokens({
                        amountIn: amountIn,
                        amountOutMin: amountOutMin,
                        path: ArrayHelper.new3(tokenIn, tokenRelay, tokenOut),
                        to: destination,
                        deadline: block.timestamp
                    })
                    .last();
        }

        IERC20Upgradeable(tokenIn).approve(routerIn, amountIn);
        uint amountRelay = IRouter(routerIn)
            .swapExactTokensForTokens({
                amountIn: amountIn,
                amountOutMin: 0,
                path: ArrayHelper.new2(tokenIn, tokenRelay),
                to: address(this),
                deadline: block.timestamp
            })
            .last();

        IERC20Upgradeable(tokenRelay).approve(routerOut, amountRelay);
        return
            IRouter(routerOut)
                .swapExactTokensForTokens({
                    amountIn: amountRelay,
                    amountOutMin: amountOutMin,
                    path: ArrayHelper.new2(tokenRelay, tokenOut),
                    to: destination,
                    deadline: block.timestamp
                })
                .last();
    }

    function estimateOut(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) external view returns (uint amountOut, bytes memory hints) {
        if (tokenIn == tokenOut) {
            return (amountIn, Hints.empty());
        }

        (amountOut, hints) = _estimateOutDirect(tokenIn, tokenOut, amountIn);

        for (uint i = 0; i < relayTokens.length; i++) {
            (uint attemptOut, bytes memory attemptHints) = _estimateOutRelay(
                tokenIn,
                relayTokens[i],
                tokenOut,
                amountIn
            );
            if (attemptOut > amountOut) {
                amountOut = attemptOut;
                hints = attemptHints;
            }
        }

        require(amountOut > 0, "no estimation");
    }

    function estimateOutWithHints(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        bytes memory hints
    ) external view returns (uint amountOut) {
        if (tokenIn == tokenOut) {
            return amountIn;
        }

        address relay = Hints.getRelay(hints, tokenIn, tokenOut);
        if (relay == address(0)) {
            address router = Hints.getRouter(hints, tokenIn, tokenOut);
            return _getAmountOut2(IRouter(router), tokenIn, tokenOut, amountIn);
        }

        address routerIn = Hints.getRouter(hints, tokenIn, relay);
        address routerOut = Hints.getRouter(hints, relay, tokenOut);
        if (routerIn == routerOut) {
            return _getAmountOut3(IRouter(routerIn), tokenIn, relay, tokenOut, amountIn);
        }

        uint amountRelay = _getAmountOut2(IRouter(routerIn), tokenIn, relay, amountIn);
        return _getAmountOut2(IRouter(routerOut), relay, tokenOut, amountRelay);
    }

    function _estimateOutDirect(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        IRouter router;
        (router, amountOut) = _optimalAmount(tokenIn, tokenOut, amountIn);
        hints = Hints.setRouter(tokenIn, tokenOut, address(router));
    }

    function _estimateOutRelay(
        address tokenIn,
        address tokenRelay,
        address tokenOut,
        uint amountIn
    ) private view returns (uint amountOut, bytes memory hints) {
        (IRouter routerIn, uint amountRelay) = _optimalAmount(tokenIn, tokenRelay, amountIn);
        (IRouter routerOut, ) = _optimalAmount(tokenRelay, tokenOut, amountRelay);

        hints = Hints.setRelay(tokenIn, tokenOut, address(tokenRelay));
        hints = Hints.merge2(hints, Hints.setRouter(tokenIn, tokenRelay, address(routerIn)));
        hints = Hints.merge2(hints, Hints.setRouter(tokenRelay, tokenOut, address(routerOut)));

        if (routerIn == routerOut) {
            amountOut = _getAmountOut3(routerIn, tokenIn, tokenRelay, tokenOut, amountIn);
        } else {
            amountOut = _getAmountOut2(routerOut, tokenRelay, tokenOut, amountRelay);
        }
    }

    function _optimalAmount(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (IRouter optimalRouter, uint optimalOut) {
        for (uint32 i = 0; i < routers.length; i++) {
            IRouter router = routers[i];
            uint amountOut = _getAmountOut2(router, tokenIn, tokenOut, amountIn);
            if (amountOut > optimalOut) {
                optimalRouter = routers[i];
                optimalOut = amountOut;
            }
        }
    }

    function _getAmountOut2(
        IRouter router,
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) private view returns (uint) {
        return _getAmountSafe(router, ArrayHelper.new2(tokenIn, tokenOut), amountIn);
    }

    function _getAmountOut3(
        IRouter router,
        address tokenIn,
        address tokenMid,
        address tokenOut,
        uint amountIn
    ) private view returns (uint) {
        return _getAmountSafe(router, ArrayHelper.new3(tokenIn, tokenMid, tokenOut), amountIn);
    }

    function _getAmountSafe(
        IRouter router,
        address[] memory path,
        uint amountIn
    ) public view returns (uint output) {
        bytes memory payload = abi.encodeWithSelector(router.getAmountsOut.selector, amountIn, path);
        (bool success, bytes memory response) = address(router).staticcall(payload);
        if (success && response.length > 32) {
            return ArrayHelper.lastUint(response);
        }
        return 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address);
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

library Math {
    function max(int x, int y) internal pure returns (int z) {
        z = x > y ? x : y;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Decimals is IERC20Upgradeable {
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./PositionInfo.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IERC20Decimals.sol";

library PositionExchangeLib {
    uint public constant POSITION_PRICE_LIMITS_MULTIPLIER = 1e8;
    uint public constant SLIPPAGE_MULTIPLIER = 1e8;

    function isPriceOutsideRange(
        PositionInfo memory position,
        uint priceNumerator,
        uint priceDenominator,
        uint8 numeratorDecimals,
        uint8 denominatorDecimals
    ) public view returns (bool) {
        if (denominatorDecimals > numeratorDecimals) {
            priceNumerator *= 10**(denominatorDecimals - numeratorDecimals);
        } else if (numeratorDecimals > denominatorDecimals) {
            priceDenominator *= 10**(numeratorDecimals - denominatorDecimals);
        }

        // priceFloat = priceNumerator / priceDenominator
        // stopLossPriceFloat = position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // if
        // priceNumerator / priceDenominator > position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // then
        // priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER > position.stopLossPrice * priceDenominator

        if (
            position.stopLossPrice != 0 &&
            priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER < position.stopLossPrice * priceDenominator
        ) return true;

        if (
            position.takeProfitPrice != 0 &&
            priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER > position.takeProfitPrice * priceDenominator
        ) return true;

        return false;
    }
}