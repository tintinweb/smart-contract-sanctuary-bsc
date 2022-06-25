// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./CPool.sol";
import "./interfaces/ICopyStaking.sol";
import "./interfaces/ICRules.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPriceProvider.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CPoolFactory is Ownable {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public stableCoin;
    ICopyStaking public stakingContract;
    ICRules public rulesContract;
    IPancakeRouter public pancakeRouter;
    IPriceProvider public priceProvider;
    IParticipationManager public participationManagerContract;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _stakingContract,
        address _rulesContract,
        address _pancakeRouter,
        address _priceProviderContract,
        address _participationManagerContract
    ) {
        stakingContract = ICopyStaking(_stakingContract);
        rulesContract = ICRules(_rulesContract);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        priceProvider = IPriceProvider(_priceProviderContract);
        participationManagerContract = IParticipationManager(
            _participationManagerContract
        );

        stableCoin = IERC20(rulesContract.stableToken());
    }

    /* ========== EVENTS ========== */

    event NewCPool(
        address indexed _trader,
        address _cPoolAddress,
        uint256 _amount
    );

    /* ========== MUTATIVE FUNCTIONS ========== */
    function createCPool(
        uint256 _traderAmount,
        uint256 _performanceFee,
        uint256 _minAmount
    ) external validateCreation(_traderAmount, _minAmount, _performanceFee) {
        CPool newPool = new CPool(
            msg.sender,
            _traderAmount,
            _performanceFee,
            _minAmount,
            address(stakingContract),
            address(pancakeRouter),
            address(stableCoin),
            address(rulesContract),
            address(priceProvider),
            address(participationManagerContract)
        );

        stableCoin.safeTransferFrom(msg.sender, address(this), _traderAmount);

        stableCoin.safeTransfer(address(newPool), _traderAmount);

        rulesContract.addPoolToWhiteList(address(newPool));

        emit NewCPool(msg.sender, address(newPool), _traderAmount);
    }

    function setStaking(address _staking) external onlyOwner {
        stakingContract = ICopyStaking(_staking);
    }

    function setRouter(address _router) external onlyOwner {
        pancakeRouter = IPancakeRouter(_router);
    }

    function setRules(address _rules) external onlyOwner {
        rulesContract = ICRules(_rules);
    }

    function setPriceProvider(address _priceProvider) external onlyOwner {
        priceProvider = IPriceProvider(_priceProvider);
    }

    function setParticipationManager(address _participationManager)
        external
        onlyOwner
    {
        participationManagerContract = IParticipationManager(
            _participationManager
        );
    }

    /* ========== MODIFIERS ========== */

    modifier validateCreation(
        uint256 _traderAmount,
        uint256 _minAmount,
        uint256 _performanceFee
    ) {
        require(_traderAmount != 0, "Trader amount cannot be zero.");
        require(
            _traderAmount >= _minAmount,
            "Trader amount mus be grater than the defined minimum."
        );
        require(
            _traderAmount >= rulesContract.minAmountToCreatePool(),
            "Trader amount mus be grater than the minimum defined in the rules."
        );

        require(
            _performanceFee <= rulesContract.getMaxPerformanceFee(),
            "Max performance fee exceeded"
        );

        require(
            rulesContract.isTraderInWhiteList(msg.sender),
            "Trader must be on the whitelist"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/ICopyStaking.sol";
import "./interfaces/ICRules.sol";
import "./interfaces/IParticipationManager.sol";
import "./interfaces/IPriceProvider.sol";
import "./interfaces/ICPool.sol";

contract CPool {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public trader;
    uint256 public maxParticipationsPerParticipant;
    uint256 public performanceFee;
    uint256 public minAmount;
    uint256 public totalShares;
    ICopyStaking public stakingContract;
    IPancakeRouter public pancakeRouter;
    IERC20 public stableCoin;
    ICRules public rulesContract;
    IPriceProvider public priceProvider;
    IParticipationManager public participationManagerContract;
    IERC20[] public tokens;
    bool public isOpen;
    uint256 public performanceFeeCounter;

    mapping(address => ICPool.Invest) public investmentOf;
    mapping(address => uint256) public tokenAddressesIndex;
    mapping(address => uint256) public tokenBalanceOf;

    uint256 private lastIndexOfToken = 1;
    uint256 private constant PERCENTAGE_DIVIDER = 100;

    /* ========== EVENTS ========== */

    event Subscribe(
        address indexed _copier,
        address indexed _cPool,
        uint256 _amount,
        uint256 _shares
    );
    event PartialUnsubscribe(
        address indexed _copier,
        address indexed _cPool,
        uint256 _amount,
        uint256 _performanceFeeAmount,
        uint256 _platformFeeAmount,
        uint256 _sellPrice
    );
    event TotalUnsubscribe(
        address indexed _copier,
        address indexed _cPool,
        uint256 _amount,
        uint256 _performanceFeeAmount,
        uint256 _platformFeeAmount,
        uint256 _sellPrice
    );
    event ClosedPool(address _cPool);

    /* ========== CONSTRUCTOR ========== */
    /**
     * @dev When a pool is created, a share is worth one dollar.
     */
    constructor(
        address _trader,
        uint256 _traderAmount,
        uint256 _performanceFee,
        uint256 _minAmount,
        address _stakingContract,
        address _routerContract,
        address _stableCoin,
        address _rulesContract,
        address _priceProviderContract,
        address _participationManagerContract
    ) {
        trader = _trader;
        performanceFee = _performanceFee;
        minAmount = _minAmount;
        stakingContract = ICopyStaking(_stakingContract);
        pancakeRouter = IPancakeRouter(_routerContract);
        stableCoin = IERC20(_stableCoin);
        rulesContract = ICRules(_rulesContract);
        priceProvider = IPriceProvider(_priceProviderContract);
        participationManagerContract = IParticipationManager(
            _participationManagerContract
        );

        _init(_trader, _traderAmount, _stableCoin);
    }

    function _init(
        address _trader,
        uint256 _traderAmount,
        address _stableCoin
    ) private {
        investmentOf[_trader] = ICPool.Invest(_traderAmount, 1 ether);
        totalShares += _traderAmount;
        tokenBalanceOf[_stableCoin] = _traderAmount;

        tokens.push(IERC20(address(0)));
        tokens.push(stableCoin);
        tokenAddressesIndex[_stableCoin] = lastIndexOfToken;
        lastIndexOfToken++;

        isOpen = true;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function closePool() external onlyTrader whenPoolIsOpen {
        address[] memory path = new address[](2);
        path[1] = address(stableCoin);
        for (uint256 i = 1; i < tokens.length; i++) {
            if (tokens[i] != stableCoin) {
                path[0] = address(tokens[i]);
                uint256 balance = tokens[i].balanceOf(address(this));
                uint256[] memory amountOutMin = pancakeRouter.getAmountsOut(
                    balance,
                    path
                );
                swap(
                    address(tokens[i]),
                    address(stableCoin),
                    balance,
                    amountOutMin[path.length - 1]
                );

                delete tokens[i];
            }
        }

        isOpen = false;
        emit ClosedPool(address(this));
    }

    function withdrawPerformanceFee() external onlyTrader {
        stableCoin.safeTransfer(msg.sender, performanceFeeCounter);
        delete performanceFeeCounter;
    }

    function _addOrDeleteTokens(address _tokenA, address _tokenB) private {
        if (tokenAddressesIndex[_tokenA] == 0) {
            tokenAddressesIndex[_tokenA] = lastIndexOfToken;
            tokens.push(IERC20(_tokenA));
            lastIndexOfToken++;
        }
        if (tokenAddressesIndex[_tokenB] == 0) {
            tokenAddressesIndex[_tokenB] = lastIndexOfToken;
            tokens.push(IERC20(_tokenB));
            lastIndexOfToken++;
        }
        if (IERC20(_tokenA).balanceOf(address(this)) == 0) {
            delete tokens[tokenAddressesIndex[_tokenA]];
            delete tokenAddressesIndex[_tokenA];
        }
        if (IERC20(_tokenB).balanceOf(address(this)) == 0) {
            delete tokens[tokenAddressesIndex[_tokenB]];
            delete tokenAddressesIndex[_tokenB];
        }
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) public onlyTrader validateTokens(_tokenIn, _tokenOut) returns (uint256) {
        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IERC20(_tokenIn).approve(address(pancakeRouter), _amountIn);

        uint256[] memory result = pancakeRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            address(this),
            block.timestamp
        );

        tokenBalanceOf[_tokenIn] -= _amountIn;
        tokenBalanceOf[_tokenOut] += result[result.length - 1];

        return result[result.length - 1];
    }

    function subscribe(uint256 _amount)
        external
        validateSubscribe(_amount)
        whenPoolIsOpen
    {
        uint256 participationPrice = getParticipationPrice();
        uint256 shares = (_amount * (10**18)) / participationPrice;
        totalShares += shares;

        ICPool.Invest storage invest = investmentOf[msg.sender];

        uint256 oldShares = invest.shares;
        uint256 oldAverageCostPerShare = invest.averageCostPerShare;

        invest.shares += shares;
        invest.averageCostPerShare = calcAveragePriceIn(
            oldAverageCostPerShare,
            oldShares,
            shares,
            participationPrice
        );

        participationManagerContract.computeSuscribe(
            msg.sender,
            shares,
            oldShares,
            invest.averageCostPerShare,
            oldAverageCostPerShare
        );

        stableCoin.safeTransferFrom(msg.sender, address(this), _amount);
        stableCoin.safeTransferFrom(
            msg.sender,
            rulesContract.platformAddress(),
            getPlatformFeeAmount(_amount)
        );
        emit Subscribe(msg.sender, address(this), _amount, shares);
    }

    function getPlatformFeeAmount(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return (_amount / PERCENTAGE_DIVIDER) * rulesContract.platformFee();
    }

    function redeem(uint256 _amount)
        external
        validateUnsubscribe(_amount)
        whenPoolIsOpen
    {
        uint256 sharePrice = getParticipationPrice();
        uint256 shares = (_amount * 10**18) / sharePrice;

        ICPool.Invest storage invest = investmentOf[msg.sender];

        require(shares <= invest.shares, "Insufficient balance in pool.");

        participationManagerContract.computeUnsuscribe(
            msg.sender,
            shares,
            invest.shares,
            invest.averageCostPerShare
        );

        _redeem(shares, invest);
    }

    function _redeem(uint256 _shares, ICPool.Invest storage _invest) private {
        uint256 busdAcquired = swapTokensToRedeem(_shares);
        uint256 sellPrice = (busdAcquired * 10**18) / _shares;

        uint256 performanceFeeAmount = _calcPerformanceFee(
            _shares,
            _invest.averageCostPerShare,
            sellPrice
        );

        uint256 platformFeeAmount = _calcPlatformFeeAmount(busdAcquired);

        if (platformFeeAmount == 0) {
            stableCoin.safeTransferFrom(
                msg.sender,
                rulesContract.platformAddress(),
                platformFeeAmount
            );
        }

        totalShares -= _shares;
        _invest.shares -= _shares;

        performanceFeeCounter += performanceFeeAmount;

        stableCoin.safeTransfer(
            msg.sender,
            (busdAcquired - performanceFeeAmount - platformFeeAmount)
        );

        emit PartialUnsubscribe(
            msg.sender,
            address(this),
            busdAcquired,
            performanceFeeAmount,
            platformFeeAmount,
            sellPrice
        );
    }

    function totalRedeem() external whenPoolIsOpen {
        ICPool.Invest storage invest = investmentOf[msg.sender];

        uint256 busdAcquired = swapTokensToRedeem(invest.shares);
        uint256 sellPrice = (busdAcquired * 10**18) / invest.shares;

        uint256 performanceFeeAmount = _calcPerformanceFee(
            invest.shares,
            invest.averageCostPerShare,
            sellPrice
        );
        uint256 platformFeeAmount = _calcPlatformFeeAmount(busdAcquired);

        totalShares -= invest.shares;
        delete investmentOf[msg.sender];

        stableCoin.safeTransfer(
            msg.sender,
            (busdAcquired - performanceFeeAmount - platformFeeAmount)
        );

        emit TotalUnsubscribe(
            msg.sender,
            address(this),
            busdAcquired,
            performanceFeeAmount,
            platformFeeAmount,
            sellPrice
        );
    }

    /**
     * @dev To increase the accuracy of the percentage calculation increase
     *      the number of zeros in the percentageDivider variable.
     *      For example: 100000 gives a precision of 2 decimal places.
     */
    function swapTokensToRedeem(uint256 _shares) private returns (uint256) {
        uint256 percentageDivider = 100000;
        uint256 percentageOfTotal = (_shares * percentageDivider) / totalShares;
        uint256 balanceBUSD = stableCoin.balanceOf(address(this));
        uint256 counter = (balanceBUSD / percentageDivider) * percentageOfTotal;

        address[] memory path = new address[](2);
        path[1] = address(stableCoin);
        for (uint256 i = 1; i < tokens.length; i++) {
            if (tokens[i] != stableCoin) {
                path[0] = address(tokens[i]);
                uint256 balance = tokens[i].balanceOf(address(this));
                uint256 toSwap = (balance / percentageDivider) *
                    percentageOfTotal;

                uint256[] memory amountOutMin = pancakeRouter.getAmountsOut(
                    toSwap,
                    path
                );
                counter += swap(
                    address(tokens[i]),
                    address(stableCoin),
                    balance,
                    amountOutMin[path.length - 1]
                );
            }
        }

        return counter;
    }

    function _calcPlatformFeeAmount(uint256 _amount) private returns (uint256) {
        (, , uint256 penaltyDeadline) = participationManagerContract
            .getCopierInfo(msg.sender);

        if (block.timestamp > penaltyDeadline) {
            return 0;
        } else {
            return
                (_amount / PERCENTAGE_DIVIDER) *
                rulesContract.platformFeeWithPenalty();
        }
    }

    function _calcPerformanceFee(
        uint256 _shares,
        uint256 _averagePriceIn,
        uint256 _currentSharePrice
    ) private view returns (uint256) {
        uint256 profit = _shares *
            (
                _averagePriceIn >= _currentSharePrice
                    ? 0
                    : _currentSharePrice - _averagePriceIn
            );

        return (profit / PERCENTAGE_DIVIDER) * performanceFee;
    }

    function setStakingContract(address _stakingContract) external onlyTrader {
        stakingContract = ICopyStaking(_stakingContract);
    }

    function setRouterContract(address _routerContract) external onlyTrader {
        pancakeRouter = IPancakeRouter(_routerContract);
    }

    function setStableCoint(address _stableCoin) external onlyTrader {
        stableCoin = IERC20(_stableCoin);
    }

    function setRulesContract(address _rulesContract) external onlyTrader {
        rulesContract = ICRules(_rulesContract);
    }

    function setPriceProviderContract(address _priceProviderContract)
        external
        onlyTrader
    {
        priceProvider = IPriceProvider(_priceProviderContract);
    }

    function setParticipationManagerContract(
        address _participationManagerContract
    ) external onlyTrader {
        participationManagerContract = IParticipationManager(
            _participationManagerContract
        );
    }

    /* ========== VIEWS ========== */
    function capitalInvestedOf(address _copierAddress)
        external
        view
        returns (uint256)
    {
        ICPool.Invest memory invest = investmentOf[_copierAddress];
        return (invest.shares * invest.averageCostPerShare) / 10**18;
    }

    function calcAveragePriceIn(
        uint256 _averagePriceIn,
        uint256 _currentParticipations,
        uint256 _newParticipations,
        uint256 _participationPrice
    ) private pure returns (uint256) {
        uint256 t1 = _averagePriceIn == 0 || _currentParticipations == 0
            ? 0
            : _averagePriceIn * _currentParticipations;

        uint256 t2 = _newParticipations * _participationPrice;

        return (t1 + t2) / (_newParticipations + _currentParticipations);
    }

    function getParticipationPrice() private view returns (uint256) {
        uint256 cPoolValue;
        for (uint256 i = 1; i < tokens.length; i++) {
            uint256 balance = tokens[i].balanceOf(address(this));
            uint256 price = priceProvider.getPrice(address(tokens[i]));
            cPoolValue += balance * price;
        }
        return cPoolValue / totalShares;
    }

    /* ========== MODIFIERS ========== */

    modifier whenPoolIsOpen() {
        require(isOpen, "The pool must be open to execute this action.");
        _;
    }

    modifier validateSubscribe(uint256 _amount) {
        require(
            rulesContract.isPoolInWhiteList(address(this)),
            "This pool is not on the whitelist."
        );
        if (msg.sender != trader) {
            _validateFirstInvestment(_amount);
            _validateIsNotTrader(msg.sender);
            _validateAmountToSubscribe(_amount);
        }
        _;
    }

    modifier validateUnsubscribe(uint256 _amount) {
        if (msg.sender == trader) {
            _validateMinAmountToTrader(_amount);
        } else {
            _validateIsNotTrader(msg.sender);
        }
        _;
    }

    modifier validateTokens(address _tokenA, address _tokenB) {
        require(tokenBalanceOf[_tokenA] > 0, "Token not allowed to operate.");
        require(
            rulesContract.isTokenInWhiteList(_tokenB),
            "Token not allowed to operate."
        );
        _;
        _addOrDeleteTokens(_tokenA, _tokenB);
    }

    modifier onlyTrader() {
        require(
            msg.sender == trader,
            "Only the trader may perform this action"
        );
        _;
    }

    /**
     * @dev If average cost per share is 0, it means that
     *      the Copier does'nt exists.
     */
    function _validateFirstInvestment(uint256 _amount) private view {
        if (investmentOf[msg.sender].averageCostPerShare == 0) {
            require(
                _amount >= minAmount,
                "The amount does not exceed the minimum required."
            );
        }
    }

    function _validateMinAmountToTrader(uint256 _amount) private {
        ICPool.Invest memory invest = investmentOf[msg.sender];

        uint256 currentAmount = (invest.shares * getParticipationPrice()) /
            10**18;

        uint256 result = currentAmount - _amount;
        uint256 minAmountToCreatePool = rulesContract.minAmountToCreatePool();

        if (minAmount > minAmountToCreatePool) {
            require(
                result >= minAmount,
                "The trader's shares must be greater than the minimum allowed."
            );
        } else {
            require(
                result >= minAmountToCreatePool,
                "The trader's shares must be greater than the minimum allowed."
            );
        }
    }

    function _validateIsNotTrader(address _copierAddress) private view {
        require(
            !rulesContract.isTraderInWhiteList(_copierAddress),
            "A trader cannot enter a pool as a copier."
        );
    }

    function _validateAmountToSubscribe(uint256 _amount) private {
        uint256 stakedTokens = stakingContract.balanceOf(msg.sender);
        require(
            stakedTokens >=
                rulesContract
                    .maxPerTier(ICRules.Tier.FREEMIUM)
                    .requiredTokenStaked,
            "Insufficient staked tokens."
        );
        (
            uint256 maxAllocationAvailable,
            uint256 maxPoolsAvailable
        ) = participationManagerContract.getMaxInvestmentAvailable(
                msg.sender,
                stakedTokens
            );

        if (investmentOf[msg.sender].shares == 0) {
            require(maxPoolsAvailable != 0, "You cannot invest in more pools.");
        }

        require(
            _amount <= maxAllocationAvailable,
            "Maximum amount per tier exceeded."
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICopyStaking {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stakingToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../CRules.sol";

interface ICRules {
    /* ========== ENUMS ========== */
    enum Tier {
        FREEMIUM,
        BRONZE,
        SILVER,
        GOLD,
        DIAMOND
    }

    /* ========== STRUCTS ========== */
    struct MaxPerTier {
        uint256 maxAllocations;
        uint256 maxPools;
        uint256 requiredTokenStaked;
    }

    function getMaxPerformanceFee() external pure returns (uint256);

    function getMaxAllocationPerStaking(uint256 _stakedTokens)
        external
        view
        returns (uint256, uint256);

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool);

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool);

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool);

    function addPoolToWhiteList(address _poolAddress) external;

    function getTier(uint256 _stakedTokens) external pure returns (Tier);

    function maxPerTier(Tier _tier) external returns (MaxPerTier memory);

    function minAmountToCreatePool() external returns (uint256);

    function stableToken() external returns (address);

    function platformFee() external view returns (uint256);

    function platformFeeWithPenalty() external returns (uint256);

    function penaltyRange() external returns (uint256);

    function platformAddress() external returns (address);
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IPriceProvider {
    function getPrice(address _tokenAddress) external view returns (uint256);
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
pragma solidity 0.8.13;

interface IParticipationManager {
    /* ========== STRUCTS ========== */

    struct Copier {
        mapping(address => bool) pools;
        uint256 penaltyDeadLine;
        uint256 capitalInvested;
        uint256 allocation;
        uint8 poolsLength;
    }

    function getCopierInfo(address _copierAddress)
        external
        view
        returns (
            uint256 allocation,
            uint256 pools,
            uint256 penaltyDeadline
        );

    function computeSuscribe(
        address _copierAddress,
        uint256 _newShares,
        uint256 _oldShares,
        uint256 _oldAverageCostPerShare,
        uint256 _newAverageCostPerShare
    ) external;

    function computeUnsuscribe(
        address _copierAddress,
        uint256 _shares,
        uint256 _oldShares,
        uint256 _averageCostPerShare
    ) external;

    function getMaxInvestmentAvailable(address _copier, uint256 _stakedTokens)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable);

    function isCopierSuscribed(address pool) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICPool {
    struct Invest {
        uint256 shares;
        uint256 averageCostPerShare;
    }

    function capitalInvestedOf(address _copierAddress)
        external
        view
        returns (uint256);

    function investmentsOf(address _copierAddress)
        external
        view
        returns (uint256);
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
pragma solidity 0.8.13;

import "./interfaces/IParticipationManager.sol";
import "./interfaces/ICRules.sol";

contract CRules {
    /* ========== STATE VARIABLES ========== */

    mapping(ICRules.Tier => ICRules.MaxPerTier) public maxPerTier;
    mapping(address => bool) public tradersWhiteList;
    mapping(address => bool) public tokenWhiteList;
    mapping(address => bool) public poolWhiteList;
    mapping(address => bool) public ownerList;

    uint256 public minAmountToCreatePool;
    uint256 public platformFee;
    uint256 public platformFeeWithPenalty;
    uint256 public penaltyRange;
    address public stableToken;
    address public platformAddress;

    uint256 private constant PERCENTS_DIVIDER = 100;
    uint256 private constant MAX_PERFORMANCE_FEE = 20;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _minAmountToCreatePool,
        uint256 _platformFee,
        uint256 _platformFeeWithPenalty,
        uint256 _penaltyRange,
        address _stableToken,
        address[] memory _owners
    ) {
        minAmountToCreatePool = _minAmountToCreatePool;
        platformFee = _platformFee;
        platformFeeWithPenalty = _platformFeeWithPenalty;
        penaltyRange = _penaltyRange;
        stableToken = _stableToken;
        _loadTiers();
        _loadOwners(_owners);
    }

    function _loadOwners(address[] memory _owners) private {
        ownerList[msg.sender] = true;
        for (uint256 i; i < _owners.length; i++) {
            ownerList[_owners[i]] = true;
        }
    }

    function _loadTiers() private {
        maxPerTier[ICRules.Tier.FREEMIUM] = ICRules.MaxPerTier(
            500 * (10**18),
            1,
            1000 * (10**18)
        );
        maxPerTier[ICRules.Tier.BRONZE] = ICRules.MaxPerTier(
            3000 * (10**18),
            3,
            20000 * (10**18)
        );
        maxPerTier[ICRules.Tier.SILVER] = ICRules.MaxPerTier(
            7000 * (10**18),
            7,
            40000 * (10**18)
        );
        maxPerTier[ICRules.Tier.GOLD] = ICRules.MaxPerTier(
            15000 * (10**18),
            15,
            70000 * (10**18)
        );
        maxPerTier[ICRules.Tier.DIAMOND] = ICRules.MaxPerTier(
            1000000 * (10**18),
            1000,
            200000 * (10**18)
        );
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function modifyMaxPerTier(
        uint8 _tier,
        uint256 _maxAllocations,
        uint256 _maxPools
    ) external onlyOwners {
        require(_tier <= uint8(ICRules.Tier.DIAMOND), "Tier not found.");

        ICRules.MaxPerTier storage maxs = maxPerTier[ICRules.Tier(_tier)];

        maxs.maxAllocations = _maxAllocations;
        maxs.maxPools = _maxPools;
    }

    function setPlatformAddress(address _platformAddress) external onlyOwners {
        platformAddress = _platformAddress;
    }

    function setPenaltyDeadline(uint256 _penaltyRange) external onlyOwners {
        penaltyRange = _penaltyRange;
    }

    function setMinAmountToCreatePool(uint256 _minAmountToCreatePool)
        external
        onlyOwners
    {
        minAmountToCreatePool = _minAmountToCreatePool;
    }

    function setPlatformFee(uint256 _platformFee) external onlyOwners {
        platformFee = _platformFee;
    }

    function setPlatformFeeWithPenalty(uint256 _platformFeeWithPenalty)
        external
        onlyOwners
    {
        platformFeeWithPenalty = _platformFeeWithPenalty;
    }

    function addPoolToWhiteList(address _poolAddress) external onlyOwners {
        poolWhiteList[_poolAddress] = true;
    }

    function removePoolFromWhiteList(address _poolAddress) external onlyOwners {
        if (poolWhiteList[_poolAddress]) delete poolWhiteList[_poolAddress];
    }

    function addTraderToWhiteList(address _traderAddress) external onlyOwners {
        tradersWhiteList[_traderAddress] = true;
    }

    function removeTraderFromWhiteList(address _traderAddress)
        external
        onlyOwners
    {
        if (tradersWhiteList[_traderAddress])
            delete tradersWhiteList[_traderAddress];
    }

    function addTokenToWhiteList(address _tokenAddress) external onlyOwners {
        tokenWhiteList[_tokenAddress] = true;
    }

    function removeTokenFromWhiteList(address _tokenAddress)
        external
        onlyOwners
    {
        if (tokenWhiteList[_tokenAddress]) delete tokenWhiteList[_tokenAddress];
    }

    function addOwner(address _ownerAddress) external onlyOwners {
        ownerList[_ownerAddress] = true;
    }

    function removeOwner(address _ownerAddress) external onlyOwners {
        if (ownerList[_ownerAddress]) delete ownerList[_ownerAddress];
    }

    /* ========== VIEWS ========== */
    function getMaxPerformanceFee() external pure returns (uint256) {
        return MAX_PERFORMANCE_FEE;
    }

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool)
    {
        return poolWhiteList[_poolAddress];
    }

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool)
    {
        return tradersWhiteList[_traderAddress];
    }

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool)
    {
        return tokenWhiteList[_tokenAddress];
    }

    function getMaxAllocationPerStaking(uint256 _stakedTokens)
        public
        view
        returns (ICRules.MaxPerTier memory)
    {
        return maxPerTier[getTier(_stakedTokens)];
    }

    function getTier(uint256 _stakedTokens) public view returns (ICRules.Tier) {
        if (
            _stakedTokens >=
            maxPerTier[ICRules.Tier.DIAMOND].requiredTokenStaked
        ) return ICRules.Tier.DIAMOND;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.GOLD].requiredTokenStaked
        ) return ICRules.Tier.GOLD;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.SILVER].requiredTokenStaked
        ) return ICRules.Tier.SILVER;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.BRONZE].requiredTokenStaked
        ) return ICRules.Tier.BRONZE;
        return ICRules.Tier.FREEMIUM;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyOwners() {
        require(
            ownerList[msg.sender],
            "Ownable: caller is not one of the owners."
        );
        _;
    }
}