// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../tokens/interfaces/IUSDX.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IVaultUtils.sol";
import "./interfaces/IVaultPriceFeedV2.sol";
import "../DID/interfaces/IESBT.sol";
contract Vault is ReentrancyGuard, IVault, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct Position {
        uint256 size;
        uint256 collateral;
        uint256 averagePrice;
        uint256 entryFundingRate;
        uint256 reserveAmount;
        int256 realisedPnl;
        uint256 lastIncreasedTime;
    }


    bool public override isInitialized;
    bool public override isSwapEnabled = true;
    bool public override isLeverageEnabled = true;

    address public override vaultUtilsAddress;
    IVaultUtils public vaultUtils;
    IESBT public eSBT;

    address public override router;
    address public override priceFeed;

    address public override usdx;

    uint256 public override whitelistedTokenCount;

    uint256 public override fundingInterval = 8 hours;
    uint256 public override fundingRateFactor;
    uint256 public override stableFundingRateFactor;
    uint256 public override totalTokenWeights;

    bool public override inManagerMode = false;
    bool public override inPrivateLiquidationMode = true;

    mapping(address => mapping(address => bool)) public override approvedRouters;
    mapping(address => bool) public override isLiquidator;
    mapping(address => bool) public override isManager;

    address[] public override allWhitelistedTokens;

    mapping(address => bool) public override whitelistedTokens;
    mapping(address => uint256) public override tokenDecimals;
    mapping(address => uint256) public override minProfitBasisPoints;
    mapping(address => bool) public override stableTokens;
    mapping(address => bool) public override shortableTokens;

    // tokenBalances is used only to determine _transferIn values
    mapping(address => uint256) public override tokenBalances;

    // tokenWeights allows customisation of index composition
    mapping(address => uint256) public override tokenWeights;

    // usdxAmounts tracks the amount of USDX debt for each whitelisted token
    mapping(address => uint256) public override usdxAmounts;
    uint256 public override usdxSupply;

    // maxUSDAmounts allows setting a max amount of USDX debt for a token
    mapping(address => uint256) public override maxUSDAmounts;
    // poolAmounts tracks the number of received tokens that can be used for leverage
    // this is tracked separately from tokenBalances to exclude funds that are deposited as margin collateral
    mapping(address => uint256) public override poolAmounts;
    // reservedAmounts tracks the number of tokens reserved for open leverage positions
    mapping(address => uint256) public override reservedAmounts;
    // bufferAmounts allows specification of an amount to exclude from swaps
    // this can be used to ensure a certain amount of liquidity is available for leverage positions
    mapping(address => uint256) public override bufferAmounts;
    // guaranteedUsd tracks the amount of USD that is "guaranteed" by opened leverage positions
    mapping(address => uint256) public override guaranteedUsd;
    // cumulativeFundingRates tracks the funding rates based on utilization
    mapping(address => uint256) public override cumulativeFundingRates;
    // lastFundingTimes tracks the last time funding was updated for a token
    mapping(address => uint256) public override lastFundingTimes;

    // positions tracks all open positions
    mapping(bytes32 => Position) public positions;

    // feeReserves tracks the amount of fees per token
    mapping(address => uint256) public override feeReserves;
    mapping(address => uint256) public override feeSold;
    uint256 public override feeReservesUSD;
    uint256 public override feeReservesDiscountedUSD;

    mapping(uint256 => uint256) public override feeReservesRecord;
    uint256 public override feeClaimedUSD;

    mapping(address => uint256) public override globalShortSizes;
    mapping(address => uint256) public override globalShortAveragePrices;
    mapping(address => uint256) public override maxGlobalShortSizes;
  
    event ZeroOut(bytes32 key, address account, uint256 size);

    event Swap(
        address account,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 amountOutAfterFees,
        uint256 feeBasisPoints
    );

    event IncreasePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee
    );
    event DecreasePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee,
        uint256 usdOut,
        uint256 latestCollatral,
        uint256 prevCollateral
    );
    event DecreasePositionTransOut( bytes32 key,uint256 transOut);
    event LiquidatePosition(
        bytes32 key,
        address account,
        address collateralToken,
        address indexToken,
        bool isLong,
        uint256 size,
        uint256 collateral,
        uint256 reserveAmount,
        int256 realisedPnl,
        uint256 markPrice
    );
    event UpdatePosition(
        bytes32 key,
        address account,
        uint256 size,
        uint256 collateral,
        uint256 averagePrice,
        uint256 entryFundingRate,
        uint256 reserveAmount,
        int256 realisedPnl,
        uint256 markPrice
    );
    event ClosePosition(
        bytes32 key,
        address account,
        uint256 size,
        uint256 collateral,
        uint256 averagePrice,
        uint256 entryFundingRate,
        uint256 reserveAmount,
        int256 realisedPnl
    );

    event UpdateFundingRate(address token, uint256 fundingRate);
    event UpdatePnl(
        bytes32 key,
        bool hasProfit,
        uint256 delta,
        uint256 currentSize,
        uint256 currentCollateral,
        uint256 usdOut,
        uint256 usdOutAfterFee
    );
    event CollectSwapFees(address token, uint256 feeUsd, uint256 feeTokens);
    event CollectMarginFees(address token, uint256 feeUsd, uint256 feeTokens);

    event DirectPoolDeposit(address token, uint256 amount);
    event IncreasePoolAmount(address token, uint256 amount);
    event DecreasePoolAmount(address token, uint256 amount);
    event IncreaseReservedAmount(address token, uint256 amount);
    event DecreaseReservedAmount(address token, uint256 amount);
    event IncreaseGuaranteedUsd(address token, uint256 amount);
    event DecreaseGuaranteedUsd(address token, uint256 amount);

    // once the parameters are verified to be working correctly,
    // gov should be set to a timelock contract or a governance contract

    function initialize(
        address _router,
        address _usdx,
        address _priceFeed,
        uint256 /*_liquidationFeeUsd*/,
        uint256 _fundingRateFactor,
        uint256 _stableFundingRateFactor
    ) external onlyOwner{
        require(!isInitialized, "Err1");
        isInitialized = true;
        router = _router;
        usdx = _usdx;
        tokenDecimals[usdx] = 18;
        priceFeed = _priceFeed;
        fundingRateFactor = _fundingRateFactor;
        stableFundingRateFactor = _stableFundingRateFactor;
    }

    function setVaultUtils(address _vaultUtils) external override onlyOwner{
        vaultUtils = IVaultUtils(_vaultUtils);
        vaultUtilsAddress =_vaultUtils;
    }

    function setESBT(address _eSBT) external override onlyOwner{
        eSBT = IESBT(_eSBT);
    }

    function allWhitelistedTokensLength() external view override returns (uint256) {
        return allWhitelistedTokens.length;
    }

    function setInManagerMode(bool _inManagerMode) external override onlyOwner{
        inManagerMode = _inManagerMode;
    }

    function setManager(address _manager, bool _isManager) external override onlyOwner{
        isManager[_manager] = _isManager;
    }

    function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode) external override onlyOwner {
        inPrivateLiquidationMode = _inPrivateLiquidationMode;
    }

    function setLiquidator(address _liquidator, bool _isActive) external override onlyOwner {
        isLiquidator[_liquidator] = _isActive;
    }

    function setIsSwapEnabled(bool _isSwapEnabled) external override onlyOwner{
        isSwapEnabled = _isSwapEnabled;
    }

    function setIsLeverageEnabled(bool _isLeverageEnabled) external override onlyOwner{
        isLeverageEnabled = _isLeverageEnabled;
    }

    function setPriceFeed(address _priceFeed) external override onlyOwner{
        priceFeed = _priceFeed;
    }

    function setRouter(address _router) external override onlyOwner{
        router = _router;
    }

    function setBufferAmount(address _token, uint256 _amount) external override onlyOwner{
        bufferAmounts[_token] = _amount;
    }

    function setMaxGlobalShortSize(address _token, uint256 _amount) external override onlyOwner{
        maxGlobalShortSizes[_token] = _amount;
    }



    function setFundingRate(
        uint256 _fundingInterval,
        uint256 _fundingRateFactor,
        uint256 _stableFundingRateFactor
    ) external override onlyOwner{
        _validate(_fundingInterval >= vaultUtils.MIN_FUNDING_RATE_INTERVAL(), 10);
        _validate(_fundingRateFactor <= vaultUtils.MAX_FUNDING_RATE_FACTOR(), 11);
        _validate(_stableFundingRateFactor <= vaultUtils.MAX_FUNDING_RATE_FACTOR(), 12);
        fundingInterval = _fundingInterval;
        fundingRateFactor = _fundingRateFactor;
        stableFundingRateFactor = _stableFundingRateFactor;
    }

    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _tokenWeight,
        uint256 _minProfitBps,
        uint256 _maxUSDAmount,
        bool _isStable,
        bool _isShortable
    ) external override onlyOwner{
        // increment token count for the first time
        if (!whitelistedTokens[_token]) {
            whitelistedTokenCount = whitelistedTokenCount.add(1);
            allWhitelistedTokens.push(_token);
        }

        uint256 _totalTokenWeights = totalTokenWeights;
        _totalTokenWeights = _totalTokenWeights.sub(tokenWeights[_token]);

        whitelistedTokens[_token] = true;
        tokenDecimals[_token] = _tokenDecimals;
        tokenWeights[_token] = _tokenWeight;
        minProfitBasisPoints[_token] = _minProfitBps;
        maxUSDAmounts[_token] = _maxUSDAmount;
        stableTokens[_token] = _isStable;
        shortableTokens[_token] = _isShortable;

        totalTokenWeights = _totalTokenWeights.add(_tokenWeight);

        // validate price feed
        getMaxPrice(_token);
    }

    function clearTokenConfig(address _token) external onlyOwner{
        _validate(whitelistedTokens[_token], 13);
        totalTokenWeights = totalTokenWeights.sub(tokenWeights[_token]);
        delete whitelistedTokens[_token];
        delete tokenDecimals[_token];
        delete tokenWeights[_token];
        delete minProfitBasisPoints[_token];
        delete maxUSDAmounts[_token];
        delete stableTokens[_token];
        delete shortableTokens[_token];
        whitelistedTokenCount = whitelistedTokenCount.sub(1);
    }

    function addRouter(address _router) external {
        approvedRouters[msg.sender][_router] = true;
    }

    function removeRouter(address _router) external {
        approvedRouters[msg.sender][_router] = false;
    }

    function setUsdxAmount(address _token, uint256 _amount) external override onlyOwner{
        uint256 usdxAmount = usdxAmounts[_token];
        if (_amount > usdxAmount) {
            _increaseUsdxAmount(_token, _amount.sub(usdxAmount));
            return;
        }
        _decreaseUsdxAmount(_token, usdxAmount.sub(_amount));
    }

    // the governance controlling this function should have a timelock
    function upgradeVault(
        address _newVault,
        address _token,
        uint256 _amount
    ) external onlyOwner{
        IERC20(_token).safeTransfer(_newVault, _amount);
    }

    // deposit into the pool without minting USDX tokens
    // useful in allowing the pool to become over-collaterised
    function directPoolDeposit(address _token) external override nonReentrant {
        _validate(whitelistedTokens[_token], 14);
        uint256 tokenAmount = _transferIn(_token);
        _validate(tokenAmount > 0, 15);
        _increasePoolAmount(_token, tokenAmount);
        emit DirectPoolDeposit(_token, tokenAmount);
    }

    function buyUSDX(address _token, address _receiver)external override nonReentrant returns (uint256) {
        _validate(isManager[msg.sender], 54);
        _validate(whitelistedTokens[_token], 16);

        uint256 tokenAmount = _transferIn(_token);
        _validate(tokenAmount > 0, 17);

        updateCumulativeFundingRate(_token, _token);

        uint256 price = getMinPrice(_token);

        uint256 usdxAmount = tokenAmount.mul(price).div(vaultUtils.PRICE_PRECISION());
        usdxAmount = adjustForDecimals(usdxAmount, _token, usdx);
        _validate(usdxAmount > 0, 18);
        uint256 feeBasisPoints = vaultUtils.getBuyUsdxFeeBasisPoints(_token, usdxAmount);
        uint256 amountAfterFees = _collectSwapFees(_token, tokenAmount, feeBasisPoints);
        uint256 mintAmount = amountAfterFees.mul(price).div(vaultUtils.PRICE_PRECISION());
        mintAmount = adjustForDecimals(mintAmount, _token, usdx);
        _increaseUsdxAmount(_token, mintAmount);
        _increasePoolAmount(_token, amountAfterFees);
        usdxSupply = usdxSupply.add(mintAmount);
        _increaseUsdxAmount(_receiver, mintAmount);

        return mintAmount;
    }

    function sellUSDX(
        address _token,
        address _receiver,
        uint256 _usdxAmount
    ) external override nonReentrant returns (uint256) {
        _validate(isManager[msg.sender], 54);
        _validate(whitelistedTokens[_token], 19);
        require(usdxAmounts[msg.sender] > _usdxAmount, "insufficient usd");

        uint256 usdxAmount = _usdxAmount; // _transferIn(usdx);
        _validate(usdxAmount > 0, 20);

        updateCumulativeFundingRate(_token, _token);

        uint256 redemptionAmount = getRedemptionAmount(_token, usdxAmount);
        _validate(redemptionAmount > 0, 21);

        _decreaseUsdxAmount(_token, usdxAmount);
        _decreasePoolAmount(_token, redemptionAmount);

        // IUSDX(usdx).burn(address(this), usdxAmount);
        usdxSupply = usdxSupply > usdxAmount ? usdxSupply.sub(usdxAmount) : 0;

        usdxAmounts[msg.sender] = usdxAmounts[msg.sender] > _usdxAmount
            ? usdxAmounts[msg.sender].sub(_usdxAmount)
            : 0;
        uint256 feeBasisPoints = vaultUtils.getSellUsdxFeeBasisPoints(_token, usdxAmount);
        uint256 amountOut = _collectSwapFees(_token, redemptionAmount, feeBasisPoints);
        _validate(amountOut > 0, 22);
        _transferOut(_token, amountOut, _receiver);
        return amountOut;
    }

    function claimFeeToken(address _token)
        external
        override
        nonReentrant
        returns (uint256)
    {
        _validate(isManager[msg.sender], 54);
        if (!whitelistedTokens[_token]) {
            return 0;
        }
        _validate(whitelistedTokens[_token], 19);
        require(feeReserves[_token] >= feeSold[_token], "insufficient Fee");
        uint256 _amount = feeReserves[_token].sub(feeSold[_token]);
        feeSold[_token] = feeReserves[_token];
        if (_amount > 0) {
            _transferOut(_token, _amount, msg.sender);
        }
        return _amount;
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        address _receiver
    ) external override nonReentrant returns (uint256) {
        _validate(isSwapEnabled, 23);
        _validate(whitelistedTokens[_tokenIn], 24);
        _validate(whitelistedTokens[_tokenOut], 25);
        _validate(_tokenIn != _tokenOut, 26);

        updateCumulativeFundingRate(_tokenIn, _tokenIn);
        updateCumulativeFundingRate(_tokenOut, _tokenOut);

        uint256 amountIn = _transferIn(_tokenIn);
        _validate(amountIn > 0, 27);

        uint256 priceIn = getMinPrice(_tokenIn);
        uint256 priceOut = getMaxPrice(_tokenOut);

        uint256 amountOut = amountIn.mul(priceIn).div(priceOut);
        amountOut = adjustForDecimals(amountOut, _tokenIn, _tokenOut);

        // adjust usdxAmounts by the same usdxAmount as debt is shifted between the assets
        uint256 usdxAmount = amountIn.mul(priceIn).div(vaultUtils.PRICE_PRECISION());
        usdxAmount = adjustForDecimals(usdxAmount, _tokenIn, usdx);

        uint256 feeBasisPoints = vaultUtils.getSwapFeeBasisPoints(
            _tokenIn,
            _tokenOut,
            usdxAmount
        );
        uint256 amountOutAfterFees = _collectSwapFees(
            _tokenOut,
            amountOut,
            feeBasisPoints
        );

        _increaseUsdxAmount(_tokenIn, usdxAmount);
        _decreaseUsdxAmount(_tokenOut, usdxAmount);

        _increasePoolAmount(_tokenIn, amountIn);
        _decreasePoolAmount(_tokenOut, amountOut);

        _validateBufferAmount(_tokenOut);

        _transferOut(_tokenOut, amountOutAfterFees, _receiver);

        emit Swap(
            _receiver,
            _tokenIn,
            _tokenOut,
            amountIn,
            amountOut,
            amountOutAfterFees,
            feeBasisPoints
        );

        return amountOutAfterFees;
    }

    function increasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _sizeDelta,
        bool _isLong
    ) external override nonReentrant {
        _validate(isLeverageEnabled, 28);
        _validateRouter(_account);
        _validateTokens(_collateralToken, _indexToken, _isLong);
        vaultUtils.validateIncreasePosition(
            _account,
            _collateralToken,
            _indexToken,
            _sizeDelta,
            _isLong
        );
        updateCumulativeFundingRate(_collateralToken, _indexToken);

        bytes32 key = vaultUtils.getPositionKey(
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            0
        );
        Position storage position = positions[key];
        vaultUtils.addPosition(key, _account, _collateralToken, _indexToken, _isLong);
        uint256 price = _isLong
            ? getMaxPrice(_indexToken)
            : getMinPrice(_indexToken);

        if (position.size == 0) {
            position.averagePrice = price;
        }

        if (position.size > 0 && _sizeDelta > 0) {
            position.averagePrice = vaultUtils.getNextAveragePrice(
                _indexToken,
                position.size,
                position.averagePrice,
                _isLong,
                price,
                _sizeDelta,
                position.lastIncreasedTime
            );
        }

        uint256 fee = _collectMarginFees(
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            _sizeDelta,
            position.size,
            position.entryFundingRate
        );
        uint256 collateralDelta = _transferIn(_collateralToken);

        uint256 collateralDeltaUsd = tokenToUsdMin(
            _collateralToken,
            collateralDelta
        );

        position.collateral = position.collateral.add(collateralDeltaUsd);

        _validate(position.collateral >= fee, 29);

        position.collateral = position.collateral.sub(fee);
        position.entryFundingRate = vaultUtils.getEntryFundingRate(
            _collateralToken,
            _indexToken,
            _isLong
        );
        position.size = position.size.add(_sizeDelta);
        position.lastIncreasedTime = block.timestamp;

        _validate(position.size > 0, 30);
        _validatePosition(position.size, position.collateral);
        vaultUtils.validateLiquidation(
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            true
        );

        // reserve tokens to pay profits on the position
        uint256 reserveDelta = usdToTokenMax(_collateralToken, _sizeDelta);
        position.reserveAmount = position.reserveAmount.add(reserveDelta);
        _increaseReservedAmount(_collateralToken, reserveDelta);

        if (_isLong) {
            // guaranteedUsd stores the sum of (position.size - position.collateral) for all positions
            // if a fee is charged on the collateral then guaranteedUsd should be increased by that fee amount
            // since (position.size - position.collateral) would have increased by `fee`
            _increaseGuaranteedUsd(_collateralToken, _sizeDelta.add(fee));
            _decreaseGuaranteedUsd(_collateralToken, collateralDeltaUsd);
            // treat the deposited collateral as part of the pool
            _increasePoolAmount(_collateralToken, collateralDelta);
            // fees need to be deducted from the pool since fees are deducted from position.collateral
            // and collateral is treated as part of the pool
            _decreasePoolAmount(
                _collateralToken,
                usdToTokenMin(_collateralToken, fee)
            );
        } else {
            if (globalShortSizes[_indexToken] == 0) {
                globalShortAveragePrices[_indexToken] = price;
            } else {
                globalShortAveragePrices[
                    _indexToken
                ] = getNextGlobalShortAveragePrice(
                    _indexToken,
                    price,
                    _sizeDelta
                );
            }

            _increaseGlobalShortSize(_indexToken, _sizeDelta);
        }

        //address _account, address _collateralToken, uint256 _collateralSize,uint256 _positionSize, bool /*_isLong*/ )
        // eSBT.updateIncreaseLogForAccount(
        //     _account,
        //     _collateralToken,
        //     collateralDeltaUsd,
        //     _sizeDelta,
        //     _isLong
        // ); only update score is enough

        emit IncreasePosition(
            key,
            _account,
            _collateralToken,
            _indexToken,
            collateralDeltaUsd,
            _sizeDelta,
            _isLong,
            price,
            fee
        );
        emit UpdatePosition(
            key,
            _account,
            position.size,
            position.collateral,
            position.averagePrice,
            position.entryFundingRate,
            position.reserveAmount,
            position.realisedPnl,
            price
        );
    }

    function decreasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _collateralDelta,
        uint256 _sizeDelta,
        bool _isLong,
        address _receiver
    ) external override nonReentrant returns (uint256) {
        _validateRouter(_account);
        return
            _decreasePosition(
                _account,
                _collateralToken,
                _indexToken,
                _collateralDelta,
                _sizeDelta,
                _isLong,
                _receiver
            );
    }

    function _decreasePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _collateralDelta,
        uint256 _sizeDelta,
        bool _isLong,
        address _receiver
    ) private returns (uint256) {
        vaultUtils.validateDecreasePosition(_account,_collateralToken, _indexToken, _collateralDelta, _sizeDelta,_isLong,_receiver);
        updateCumulativeFundingRate(_collateralToken, _indexToken);
        bytes32 key = vaultUtils.getPositionKey( _account,_collateralToken,_indexToken,_isLong,0);
        Position storage position = positions[key];
        _validate(position.size > 0, 31);
        _validate(position.size >= _sizeDelta, 32);
        _validate(position.collateral >= _collateralDelta, 33);

        uint256 collateral = position.collateral;
        // scrop variables to avoid stack too deep errors
        {
            uint256 reserveDelta = position.reserveAmount.mul(_sizeDelta).div(position.size);
            position.reserveAmount = position.reserveAmount.sub(reserveDelta);
            _decreaseReservedAmount(_collateralToken, reserveDelta);
        }

        (uint256 usdOut, uint256 usdOutAfterFee) = _reduceCollateral( _account,_collateralToken,_indexToken,_collateralDelta, _sizeDelta,_isLong);
       
        // scrop variables to avoid stack too deep errors
        {
            uint256 price = _isLong ? getMinPrice(_indexToken) : getMaxPrice(_indexToken);
            emit DecreasePosition( key, _account, _collateralToken, _indexToken, _collateralDelta, _sizeDelta, _isLong, price,
                    usdOut.sub(usdOutAfterFee), usdOut, position.collateral, collateral);
            if (position.size != _sizeDelta) {
                position.entryFundingRate = vaultUtils.getEntryFundingRate(_collateralToken, _indexToken,_isLong);
                position.size = position.size.sub(_sizeDelta);
                _validatePosition(position.size, position.collateral);
                vaultUtils.validateLiquidation(_account,_collateralToken,_indexToken,_isLong,true);
                if (_isLong) {
                    _increaseGuaranteedUsd(_collateralToken, collateral.sub(position.collateral));
                    _decreaseGuaranteedUsd(_collateralToken, _sizeDelta);
                }
                emit UpdatePosition(key, _account, position.size, position.collateral, position.averagePrice, position.entryFundingRate,
                    position.reserveAmount, position.realisedPnl, price );
            } else {
                if (_isLong) {
                    _increaseGuaranteedUsd(_collateralToken, collateral);
                    _decreaseGuaranteedUsd(_collateralToken, _sizeDelta);
                }
                emit ClosePosition(key, _account,
                    position.size, position.collateral,position.averagePrice,position.entryFundingRate, position.reserveAmount, position.realisedPnl);

                delete positions[key];
                vaultUtils.removePosition(key);
            }
        }


        if (!_isLong) {
            _decreaseGlobalShortSize(_indexToken, _sizeDelta);
        }

        if (usdOut > 0) {
            uint256 amountOutAfterFees = 0;
            if (_isLong) {
                _decreasePoolAmount(_collateralToken, usdToTokenMin(_collateralToken, usdOut) );
            }
            amountOutAfterFees = usdToTokenMin(_collateralToken, usdOutAfterFee);
            emit DecreasePositionTransOut(key, amountOutAfterFees);
            _transferOut(_collateralToken, amountOutAfterFees, _receiver);
            return amountOutAfterFees;
        }else{
            emit ZeroOut(key, _receiver, _sizeDelta);
        }

        return 0;
    }

    function claimFeeReserves() external override returns (uint256) {
        _validate(isManager[msg.sender], 54);
        uint256 feeToClaim = feeReservesUSD.sub(feeReservesDiscountedUSD).sub(feeClaimedUSD);
        feeClaimedUSD = feeReservesUSD.sub(feeReservesDiscountedUSD);
        return feeToClaim;
    }

    function claimableFeeReserves() external view override returns (uint256) {
        return feeReservesUSD.sub(feeReservesDiscountedUSD).sub(feeClaimedUSD);
    }

    function liquidatePosition(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        address _feeReceiver
    ) external override nonReentrant {
        if (inPrivateLiquidationMode) {
            _validate(isLiquidator[msg.sender], 34);
        }
        updateCumulativeFundingRate(_collateralToken, _indexToken);

        bytes32 key = vaultUtils.getPositionKey(
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            0
        );
        Position memory position = positions[key];
        _validate(position.size > 0, 35);

        (uint256 liquidationState, uint256 marginFees) = vaultUtils.validateLiquidation(
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            false
        );
        _validate(liquidationState != 0, 36);
        if (liquidationState == 2) {
            // max leverage exceeded but there is collateral remaining after deducting losses so decreasePosition instead
            _decreasePosition(
                _account,
                _collateralToken,
                _indexToken,
                0,
                position.size,
                _isLong,
                _account
            );
            return;
        }

        uint256 feeTokens = usdToTokenMin(_collateralToken, marginFees);
        feeReserves[_collateralToken] = feeReserves[_collateralToken].add(
            feeTokens
        );
        feeReservesUSD = feeReservesUSD.add(marginFees);
        uint256 _discFee = eSBT.updateFee(_account, marginFees);
        feeReservesDiscountedUSD = feeReservesDiscountedUSD.add(_discFee);

        uint256 _tIndex = block.timestamp.div(24 hours);
        feeReservesRecord[_tIndex] = feeReservesRecord[_tIndex].add(marginFees);
        emit CollectMarginFees(_collateralToken, marginFees, feeTokens);

        _decreaseReservedAmount(_collateralToken, position.reserveAmount);
        if (_isLong) {
            _decreaseGuaranteedUsd(
                _collateralToken,
                position.size.sub(position.collateral)
            );
            _decreasePoolAmount(
                _collateralToken,
                usdToTokenMin(_collateralToken, marginFees)
            );
        }

        uint256 markPrice = _isLong
            ? getMinPrice(_indexToken)
            : getMaxPrice(_indexToken);
        emit LiquidatePosition(
            key,
            _account,
            _collateralToken,
            _indexToken,
            _isLong,
            position.size,
            position.collateral,
            position.reserveAmount,
            position.realisedPnl,
            markPrice
        );

        if (!_isLong && marginFees < position.collateral) {
            uint256 remainingCollateral = position.collateral.sub(marginFees);
            _increasePoolAmount(
                _collateralToken,
                usdToTokenMin(_collateralToken, remainingCollateral)
            );
        }

        if (!_isLong) {
            _decreaseGlobalShortSize(_indexToken, position.size);
        }

        delete positions[key];
        vaultUtils.removePosition(key);

        // pay the fee receiver using the pool, we assume that in general the liquidated amount should be sufficient to cover
        // the liquidation fees
        _decreasePoolAmount(
            _collateralToken,
            usdToTokenMin(_collateralToken, vaultUtils.liquidationFeeUsd())
        );
        _transferOut(
            _collateralToken,
            usdToTokenMin(_collateralToken, vaultUtils.liquidationFeeUsd()),
            _feeReceiver
        );
    }


    function getMaxPrice(address _token) public view override returns (uint256) {
        return IVaultPriceFeedV2(priceFeed).getPrice(_token, true, false, false);
    }

    function getMinPrice(address _token) public view override returns (uint256) {
        return IVaultPriceFeedV2(priceFeed).getPrice(_token, false, false, false);
    }

    function getRedemptionAmount(address _token, uint256 _usdxAmount) public view override returns (uint256) {
        uint256 price = getMaxPrice(_token);
        uint256 redemptionAmount = _usdxAmount.mul(vaultUtils.PRICE_PRECISION()).div(price);
        return adjustForDecimals(redemptionAmount, usdx, _token);
    }

    function getRedemptionCollateral(address _token) public view returns (uint256) {
        if (stableTokens[_token]) {
            return poolAmounts[_token];
        }
        uint256 collateral = usdToTokenMin(_token, guaranteedUsd[_token]);
        return collateral.add(poolAmounts[_token]).sub(reservedAmounts[_token]);
    }

    function getRedemptionCollateralUsd(address _token) public  view returns (uint256) {
        return tokenToUsdMin(_token, getRedemptionCollateral(_token));
    }

    function adjustForDecimals(uint256 _amount, address _tokenDiv, address _tokenMul ) public view returns (uint256) {
        return _amount.mul(10**tokenDecimals[_tokenMul]).div(10**tokenDecimals[_tokenDiv]);
    }

    function tokenToUsdMin(address _token, uint256 _tokenAmount) public  view override returns (uint256) {
        if (_tokenAmount == 0) {
            return 0;
        }
        uint256 price = getMinPrice(_token);
        uint256 decimals = tokenDecimals[_token];
        return _tokenAmount.mul(price).div(10**decimals);
    }

    function usdToTokenMax(address _token, uint256 _usdAmount) public override view returns (uint256) {
        if (_usdAmount == 0) {
            return 0;
        }
        return usdToToken(_token, _usdAmount, getMinPrice(_token));
    }

    function usdToTokenMin(address _token, uint256 _usdAmount) public override view returns (uint256) {
        if (_usdAmount == 0) {
            return 0;
        }
        return usdToToken(_token, _usdAmount, getMaxPrice(_token));
    }

    function usdToToken( address _token, uint256 _usdAmount, uint256 _price ) public view returns (uint256) {
        if (_usdAmount == 0) {
            return 0;
        }
        uint256 decimals = tokenDecimals[_token];
        return _usdAmount.mul(10**decimals).div(_price);
    }

    function getPosition(address _account, address _collateralToken, address _indexToken, bool _isLong
    ) public view override returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256) {
        return getPositionByKey(vaultUtils.getPositionKey(_account,_collateralToken,_indexToken, _isLong,0));
    }

    function getPositionByKey(bytes32 _key) public view override returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256) {
        Position memory position = positions[_key];
        uint256 realisedPnl = position.realisedPnl > 0 ? uint256(position.realisedPnl) : uint256(-position.realisedPnl);
        return (
            position.size, // 0
            position.collateral, // 1
            position.averagePrice, // 2
            position.entryFundingRate, // 3
            position.reserveAmount, // 4
            realisedPnl, // 5
            position.realisedPnl >= 0, // 6
            position.lastIncreasedTime // 7
        );
    }

    function getDelta(address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) public view override returns (bool, uint256) {
        _validate(_averagePrice > 0, 38);
        uint256 price = _isLong ? getMinPrice(_indexToken) : getMaxPrice(_indexToken);
        uint256 priceDelta = _averagePrice > price ? _averagePrice.sub(price) : price.sub(_averagePrice);
        uint256 delta = _size.mul(priceDelta).div(_averagePrice);

        bool hasProfit;
        if (_isLong) {
            hasProfit = price > _averagePrice;
        } else {
            hasProfit = _averagePrice > price;
        }

        // if the minProfitTime has passed then there will be no min profit threshold
        // the min profit threshold helps to prevent front-running issues
        uint256 minBps = block.timestamp > _lastIncreasedTime.add(vaultUtils.minProfitTime()) ? 0 : minProfitBasisPoints[_indexToken];
        if (hasProfit && delta.mul(vaultUtils.BASIS_POINTS_DIVISOR()) <= _size.mul(minBps)) {
            delta = 0;
        }

        return (hasProfit, delta);
    }

    function updateCumulativeFundingRate(address _collateralToken, address /*_indexToken*/) public {
        // bool shouldUpdate = vaultUtils.updateCumulativeFundingRate(
        //     _collateralToken,
        //     _indexToken
        // );
        // if (!shouldUpdate) {
        //     return;
        // }

        if (lastFundingTimes[_collateralToken] == 0) {
            lastFundingTimes[_collateralToken] = block.timestamp.div(fundingInterval).mul(fundingInterval);
            return;
        }

        if (lastFundingTimes[_collateralToken].add(fundingInterval) > block.timestamp) {
            return;
        }

        uint256 fundingRate = getNextFundingRate(_collateralToken);
        cumulativeFundingRates[_collateralToken] = cumulativeFundingRates[_collateralToken].add(fundingRate);
        lastFundingTimes[_collateralToken] = block.timestamp.div(fundingInterval).mul(fundingInterval);

        emit UpdateFundingRate(_collateralToken, cumulativeFundingRates[_collateralToken]);
    }

    function getNextFundingRate(address _token) public view override returns (uint256){
        if (lastFundingTimes[_token].add(fundingInterval) > block.timestamp) {
            return 0;
        }

        uint256 intervals = block.timestamp.sub(lastFundingTimes[_token]).div(fundingInterval);
        uint256 poolAmount = poolAmounts[_token];
        if (poolAmount == 0) {
            return 0;
        }

        uint256 _fundingRateFactor = stableTokens[_token] ? stableFundingRateFactor : fundingRateFactor;

        return _fundingRateFactor.mul(reservedAmounts[_token]).mul(intervals).div(poolAmount);
    }

    function getPositionLeverage(address _account, address _collateralToken, address _indexToken, bool _isLong) public view returns (uint256) {
        bytes32 key = vaultUtils.getPositionKey(_account, _collateralToken,_indexToken,_isLong,0);
        Position memory position = positions[key];
        _validate(position.collateral > 0, 37);
        return position.size.mul(vaultUtils.BASIS_POINTS_DIVISOR()).div(position.collateral);
    }

 

    // for longs: nextAveragePrice = (nextPrice * nextSize)/ (nextSize + delta)
    // for shorts: nextAveragePrice = (nextPrice * nextSize) / (nextSize - delta)
    function getNextGlobalShortAveragePrice(
        address _indexToken,
        uint256 _nextPrice,
        uint256 _sizeDelta
    ) public view returns (uint256) {
        uint256 size = globalShortSizes[_indexToken];
        uint256 averagePrice = globalShortAveragePrices[_indexToken];
        uint256 priceDelta = averagePrice > _nextPrice ? averagePrice.sub(_nextPrice) : _nextPrice.sub(averagePrice);
        uint256 delta = size.mul(priceDelta).div(averagePrice);
        bool hasProfit = averagePrice > _nextPrice;

        uint256 nextSize = size.add(_sizeDelta);
        uint256 divisor = hasProfit ? nextSize.sub(delta) : nextSize.add(delta);

        return _nextPrice.mul(nextSize).div(divisor);
    }

    function getGlobalShortDelta(address _token) public view returns (bool, uint256){
        uint256 size = globalShortSizes[_token];
        if (size == 0) {
            return (false, 0);
        }

        uint256 nextPrice = getMaxPrice(_token);
        uint256 averagePrice = globalShortAveragePrices[_token];
        uint256 priceDelta = averagePrice > nextPrice ? averagePrice.sub(nextPrice) : nextPrice.sub(averagePrice);
        uint256 delta = size.mul(priceDelta).div(averagePrice);
        bool hasProfit = averagePrice > nextPrice;
        return (hasProfit, delta);
    }




    function getTargetUsdxAmount(address _token) public view override returns (uint256){
        uint256 supply = usdxSupply; // IERC20(usdx).totalSupply();
        if (supply == 0) {
            return 0;
        }
        uint256 weight = tokenWeights[_token];
        return weight.mul(supply).div(totalTokenWeights);
    }

    function _reduceCollateral(
        address _account,
        address _collateralToken,
        address _indexToken,
        uint256 _collateralDelta,
        uint256 _sizeDelta,
        bool _isLong
    ) private returns (uint256, uint256) {
        bytes32 key = vaultUtils.getPositionKey( _account,_collateralToken,_indexToken,_isLong, 0);
        Position storage position = positions[key];

        uint256 fee = _collectMarginFees(_account, _collateralToken, _indexToken, _isLong,_sizeDelta, position.size, position.entryFundingRate);
        bool hasProfit;
        uint256 adjustedDelta;

        // scope variables to avoid stack too deep errors
        {
            (bool _hasProfit, uint256 delta) = getDelta(
                _indexToken,
                position.size,
                position.averagePrice,
                _isLong,
                position.lastIncreasedTime
            );
            hasProfit = _hasProfit;
            // get the proportional change in pnl
            adjustedDelta = _sizeDelta.mul(delta).div(position.size);
        }

        uint256 usdOut;
        // transfer profits out
        if (hasProfit && adjustedDelta > 0) {
            usdOut = adjustedDelta;
            position.realisedPnl = position.realisedPnl + int256(adjustedDelta);

            // pay out realised profits from the pool amount for short positions
            if (!_isLong) {
                uint256 tokenAmount = usdToTokenMin(_collateralToken, adjustedDelta);
                _decreasePoolAmount(_collateralToken, tokenAmount);
            }
        }

        if (!hasProfit && adjustedDelta > 0) {
            position.collateral = position.collateral.sub(adjustedDelta);

            // transfer realised losses to the pool for short positions
            // realised losses for long positions are not transferred here as
            // _increasePoolAmount was already called in increasePosition for longs
            if (!_isLong) {
                uint256 tokenAmount = usdToTokenMin(_collateralToken, adjustedDelta );
                _increasePoolAmount(_collateralToken, tokenAmount);
            }
            position.realisedPnl = position.realisedPnl - int256(adjustedDelta);
        }

        // reduce the position's collateral by _collateralDelta
        // transfer _collateralDelta out
        if (_collateralDelta > 0) {
            usdOut = usdOut.add(_collateralDelta);
            position.collateral = position.collateral.sub(_collateralDelta);
        }

        // if the position will be closed, then transfer the remaining collateral out
        if (position.size == _sizeDelta) {
            usdOut = usdOut.add(position.collateral);
            position.collateral = 0;
        }

        // if the usdOut is more than the fee then deduct the fee from the usdOut directly
        // else deduct the fee from the position's collateral
        uint256 usdOutAfterFee = usdOut;
        if (usdOut > fee) {
            usdOutAfterFee = usdOut.sub(fee);
        } else {
            position.collateral = position.collateral.sub(fee);
            if (_isLong) {
                uint256 feeTokens = usdToTokenMin(_collateralToken, fee);
                _decreasePoolAmount(_collateralToken, feeTokens);
            }
        }
        emit UpdatePnl(key, hasProfit, adjustedDelta, position.size, position.collateral, usdOut, usdOutAfterFee);

        return (usdOut, usdOutAfterFee);
    }

    function _validatePosition(uint256 _size, uint256 _collateral) private view {
        if (_size == 0) {
            _validate(_collateral == 0, 39);
            return;
        }
        _validate(_size >= _collateral, 40);
    }

    function _validateRouter(address _account) private view {
        if (msg.sender == _account) {
            return;
        }
        if (msg.sender == router) {
            return;
        }
        _validate(approvedRouters[_account][msg.sender], 41);
    }

    function _validateTokens(address _collateralToken, address _indexToken, bool _isLong) private view {
        _validate(whitelistedTokens[_collateralToken], 43);
        _validate(whitelistedTokens[_indexToken], 45);
        if (_isLong) {
            _validate(_collateralToken == _indexToken, 42);
            _validate(!stableTokens[_collateralToken], 44);
            return;
        }
        _validate(stableTokens[_collateralToken], 46);
        _validate(!stableTokens[_indexToken], 47);
        _validate(shortableTokens[_indexToken], 48);
    }

    function _collectSwapFees(address _token, uint256 _amount, uint256 _feeBasisPoints) private returns (uint256) {
        uint256 afterFeeAmount = _amount
            .mul(vaultUtils.BASIS_POINTS_DIVISOR().sub(_feeBasisPoints))
            .div(vaultUtils.BASIS_POINTS_DIVISOR());
        uint256 feeAmount = _amount.sub(afterFeeAmount);
        feeReserves[_token] = feeReserves[_token].add(feeAmount);
        uint256 _feeUSD = tokenToUsdMin(_token, feeAmount);
        feeReservesUSD = feeReservesUSD.add(_feeUSD);
        uint256 _tIndex = block.timestamp.div(24 hours);
        feeReservesRecord[_tIndex] = feeReservesRecord[_tIndex].add(_feeUSD);
        emit CollectSwapFees(_token, _feeUSD, feeAmount);
        return afterFeeAmount;
    }

    function _collectMarginFees(
        address _account,
        address _collateralToken,
        address _indexToken,
        bool _isLong,
        uint256 _sizeDelta,
        uint256 _size,
        uint256 _entryFundingRate
    ) private returns (uint256) {
        uint256 feeUsd_norm = vaultUtils.getPositionFee(_account,_collateralToken, _indexToken,_isLong,_sizeDelta);
        uint256 fundingFee = vaultUtils.getFundingFee(_account, _collateralToken, _indexToken, _isLong, _size, _entryFundingRate);
        feeUsd_norm = feeUsd_norm.add(fundingFee);
        uint256 feeUsd = feeUsd_norm;
        uint256 feeTokens = usdToTokenMin(_collateralToken, feeUsd);
        feeReserves[_collateralToken] = feeReserves[_collateralToken].add( feeTokens );
        feeReservesUSD = feeReservesUSD.add(feeUsd);
        uint256 _discFee = eSBT.updateFee(_account, feeUsd);
        feeReservesDiscountedUSD = feeReservesDiscountedUSD.add(_discFee);
        uint256 _tIndex = block.timestamp.div(24 hours);
        feeReservesRecord[_tIndex] = feeReservesRecord[_tIndex].add(feeUsd);
        emit CollectMarginFees(_collateralToken, feeUsd, feeTokens);
        return feeUsd;
    }

    function _transferIn(address _token) private returns (uint256) {
        uint256 prevBalance = tokenBalances[_token];
        uint256 nextBalance = IERC20(_token).balanceOf(address(this));
        tokenBalances[_token] = nextBalance;
        return nextBalance.sub(prevBalance);
    }

    function _transferOut( address _token, uint256 _amount, address _receiver ) private {
        IERC20(_token).safeTransfer(_receiver, _amount);
        tokenBalances[_token] = IERC20(_token).balanceOf(address(this));
    }

    function _increasePoolAmount(address _token, uint256 _amount) private {
        poolAmounts[_token] = poolAmounts[_token].add(_amount);
        uint256 balance = IERC20(_token).balanceOf(address(this));
        _validate(poolAmounts[_token] <= balance, 49);
        emit IncreasePoolAmount(_token, _amount);
    }

    function _decreasePoolAmount(address _token, uint256 _amount) private {
        poolAmounts[_token] = poolAmounts[_token].sub(_amount, "PoolAmount exceeded");
        _validate(reservedAmounts[_token] <= poolAmounts[_token], 50);
        emit DecreasePoolAmount(_token, _amount);
    }

    function _validateBufferAmount(address _token) private view {
        require(poolAmounts[_token] >= bufferAmounts[_token], "pool less than buffer");
    }

    function _increaseUsdxAmount(address _token, uint256 _amount) private {
        usdxAmounts[_token] = usdxAmounts[_token].add(_amount);
        uint256 maxUsdxAmount = maxUSDAmounts[_token];
        if (maxUsdxAmount != 0 && whitelistedTokens[_token]) {
            _validate(usdxAmounts[_token] <= maxUsdxAmount, 51);
        }
    }

    function _decreaseUsdxAmount(address _token, uint256 _amount) private {
        uint256 value = usdxAmounts[_token];
        if (value <= _amount) {
            usdxAmounts[_token] = 0;
            return;
        }
        usdxAmounts[_token] = value.sub(_amount);
    }

    function _increaseReservedAmount(address _token, uint256 _amount) private {
        reservedAmounts[_token] = reservedAmounts[_token].add(_amount);
        _validate(reservedAmounts[_token] <= poolAmounts[_token], 52);
        emit IncreaseReservedAmount(_token, _amount);
    }

    function _decreaseReservedAmount(address _token, uint256 _amount) private {
        reservedAmounts[_token] = reservedAmounts[_token].sub( _amount, "Vault: insufficient reserve" );
        emit DecreaseReservedAmount(_token, _amount);
    }

    function _increaseGuaranteedUsd(address _token, uint256 _usdAmount) private {
        guaranteedUsd[_token] = guaranteedUsd[_token].add(_usdAmount);
        emit IncreaseGuaranteedUsd(_token, _usdAmount);
    }

    function _decreaseGuaranteedUsd(address _token, uint256 _usdAmount)  private {
        guaranteedUsd[_token] = guaranteedUsd[_token].sub(_usdAmount);
        emit DecreaseGuaranteedUsd(_token, _usdAmount);
    }

    //----------
    function tokenUtilization(address _token) public view  override returns (uint256) {
        return poolAmounts[_token] > 0 ? reservedAmounts[_token].mul(1000000).div(poolAmounts[_token]) : 0;
    }

    function _increaseGlobalShortSize(address _token, uint256 _amount) private {
        globalShortSizes[_token] = globalShortSizes[_token].add(_amount);
        uint256 maxSize = maxGlobalShortSizes[_token];
        if (maxSize != 0) {
            require(globalShortSizes[_token] <= maxSize,"Vault: max shorts exceeded");
        }
    }

    function _decreaseGlobalShortSize(address _token, uint256 _amount) private {
        uint256 size = globalShortSizes[_token];
        if (_amount > size) {
            globalShortSizes[_token] = 0;
            return;
        }
        globalShortSizes[_token] = size.sub(_amount);
    }

    function _validate(bool _condition, uint256 _errorCode) private view {
        require(_condition, vaultUtils.errors(_errorCode));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

pragma solidity ^0.8.0;

interface IUSDX {
    function addVault(address _vault) external;
    function removeVault(address _vault) external;
    function mint(address _account, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../DID/interfaces/IESBT.sol";

interface IVault {
    function isInitialized() external view returns (bool);
    function isSwapEnabled() external view returns (bool);
    function isLeverageEnabled() external view returns (bool);

    function setVaultUtils(address _vaultUtils) external;
    function setESBT(address _eSBT) external;
    // function setError(uint256 _errorCode, string calldata _error) external;

    function router() external view returns (address);
    function usdx() external view returns (address);

    function whitelistedTokenCount() external view returns (uint256);

    function fundingInterval() external view returns (uint256);
    function totalTokenWeights() external view returns (uint256);
    function getTargetUsdxAmount(address _token) external view returns (uint256);

    function inManagerMode() external view returns (bool);
    function inPrivateLiquidationMode() external view returns (bool);

    function usdxSupply() external view returns (uint256);

    function approvedRouters(address _account, address _router) external view returns (bool);
    function isLiquidator(address _account) external view returns (bool);
    function isManager(address _account) external view returns (bool);

    function minProfitBasisPoints(address _token) external view returns (uint256);
    function tokenBalances(address _token) external view returns (uint256);
    function lastFundingTimes(address _token) external view returns (uint256);

    function setInManagerMode(bool _inManagerMode) external;
    function setManager(address _manager, bool _isManager) external;
    function setIsSwapEnabled(bool _isSwapEnabled) external;
    function setIsLeverageEnabled(bool _isLeverageEnabled) external;
    function setUsdxAmount(address _token, uint256 _amount) external;
    function setBufferAmount(address _token, uint256 _amount) external;
    function setMaxGlobalShortSize(address _token, uint256 _amount) external;
    function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode) external;
    function setLiquidator(address _liquidator, bool _isActive) external;

    function setFundingRate(uint256 _fundingInterval, uint256 _fundingRateFactor, uint256 _stableFundingRateFactor) external;

    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _redemptionBps,
        uint256 _minProfitBps,
        uint256 _maxUSDAmount,
        bool _isStable,
        bool _isShortable
    ) external;

    function setPriceFeed(address _priceFeed) external;
    function setRouter(address _router) external;
    function directPoolDeposit(address _token) external;
    function buyUSDX(address _token, address _receiver) external returns (uint256);
    function sellUSDX(address _token, address _receiver, uint256 _usdxAmount) external returns (uint256);
    function claimFeeToken(address _token) external returns (uint256);
    function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
    function increasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external;
    function decreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256);
    function liquidatePosition(address _account, address _collateralToken, address _indexToken, bool _isLong, address _feeReceiver) external;
    function tokenToUsdMin(address _token, uint256 _tokenAmount) external view returns (uint256);
    function usdToTokenMax(address _token, uint256 _usdAmount) external view returns (uint256);
    function usdToTokenMin(address _token, uint256 _usdAmount) external view returns (uint256);

    function priceFeed() external view returns (address);
    function fundingRateFactor() external view returns (uint256);
    function stableFundingRateFactor() external view returns (uint256);
    function cumulativeFundingRates(address _token) external view returns (uint256);
    function getNextFundingRate(address _token) external view returns (uint256);
    // function getFeeBasisPoints(address _token, uint256 _usdxDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);



    function allWhitelistedTokensLength() external view returns (uint256);
    function allWhitelistedTokens(uint256) external view returns (address);
    function whitelistedTokens(address _token) external view returns (bool);
    function stableTokens(address _token) external view returns (bool);
    function shortableTokens(address _token) external view returns (bool);
    function feeReserves(address _token) external view returns (uint256);
    
    function globalShortSizes(address _token) external view returns (uint256);
    function globalShortAveragePrices(address _token) external view returns (uint256);
    function maxGlobalShortSizes(address _token) external view returns (uint256);
    function tokenDecimals(address _token) external view returns (uint256);
    function tokenWeights(address _token) external view returns (uint256);
    function guaranteedUsd(address _token) external view returns (uint256);
    function poolAmounts(address _token) external view returns (uint256);
    function bufferAmounts(address _token) external view returns (uint256);
    function reservedAmounts(address _token) external view returns (uint256);
    function usdxAmounts(address _token) external view returns (uint256);
    function maxUSDAmounts(address _token) external view returns (uint256);
    function getRedemptionAmount(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getMaxPrice(address _token) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
    
    function getDelta(address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) external view returns (bool, uint256);
    
    function getPosition(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);
    function getPositionByKey(bytes32 _key) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);

 
    function tokenUtilization(address _token) external view returns (uint256);
    function claimFeeReserves( ) external returns (uint256) ;
    function claimableFeeReserves( )  external view returns (uint256);
    function feeSold (address _token)  external view returns (uint256);
    function feeReservesUSD() external view returns (uint256);
    function feeReservesDiscountedUSD() external view returns (uint256);
    
    function feeReservesRecord(uint256 _day) external view returns (uint256);
    function vaultUtilsAddress() external view returns (address);

    function feeClaimedUSD() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultUtils {
    function updateCumulativeFundingRate(address _collateralToken, address _indexToken) external returns (bool);
    function validateIncreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external view;
    function validateDecreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external view;
    function validateLiquidation(address _account, address _collateralToken, address _indexToken, bool _isLong, bool _raise) external view returns (uint256, uint256);
    function getLiqPrice(bytes32 _posKey) external view returns (uint256);
    function getEntryFundingRate(address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256);
    function getPositionFee(address _account, address _collateralToken, address _indexToken, bool _isLong, uint256 _sizeDelta) external view returns (uint256);
    function getFundingFee(address _account, address _collateralToken, address _indexToken, bool _isLong, uint256 _size, uint256 _entryFundingRate) external view returns (uint256);
    function getBuyUsdxFeeBasisPoints(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getSellUsdxFeeBasisPoints(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getSwapFeeBasisPoints(address _tokenIn, address _tokenOut, uint256 _usdxAmount) external view returns (uint256);
    function getFeeBasisPoints(address _token, uint256 _usdxDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);
    function getPositionKey(address _account,address _collateralToken, address _indexToken, bool _isLong, uint256 _keyID) external view returns (bytes32);
    function addPosition(bytes32 _key,address _account, address _collateralToken, address _indexToken, bool _isLong) external;
    function removePosition(bytes32 _key) external;
    // function getDiscountedFee(address _account, uint256 _origFee, address _token) external view returns (uint256);
    // function getSwapDiscountedFee(address _user, uint256 _origFee, address _token) external view returns (uint256);
    // function uploadFeeRecord(address _user, uint256 _feeOrig, uint256 _feeDiscounted, address _token) external;

    function BASIS_POINTS_DIVISOR() external view returns (uint256);
    function FUNDING_RATE_PRECISION() external view returns (uint256);

    function PRICE_PRECISION() external view returns (uint256);
    function MIN_LEVERAGE() external view returns (uint256);
    function USDX_DECIMALS() external view returns (uint256);
    function MAX_FEE_BASIS_POINTS() external view returns (uint256);
    function MAX_LIQUIDATION_FEE_USD() external view returns (uint256);
    function MIN_FUNDING_RATE_INTERVAL() external view returns (uint256);
    function MAX_FUNDING_RATE_FACTOR() external view returns (uint256);

    function liquidationFeeUsd() external view returns (uint256);
    function taxBasisPoints() external view returns (uint256);
    function stableTaxBasisPoints() external view returns (uint256);
    function mintBurnFeeBasisPoints() external view returns (uint256);
    function swapFeeBasisPoints() external view returns (uint256);
    function stableSwapFeeBasisPoints() external view returns (uint256);
    function marginFeeBasisPoints() external view returns (uint256);

    function minProfitTime() external view returns (uint256);
    function hasDynamicFees() external view returns (bool);
    function maxLeverage() external view returns (uint256);
    function setMaxLeverage(uint256 _maxLeverage) external;

    function errors(uint256) external view returns (string memory);

    function getNextAveragePrice(address _indexToken, uint256 _size, uint256 _averagePrice,
        bool _isLong, uint256 _nextPrice, uint256 _sizeDelta, uint256 _lastIncreasedTime ) external view returns (uint256);

    // function getPositionDelta(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (bool, uint256);



    function setFees(
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _marginFeeBasisPoints,
        uint256 _liquidationFeeUsd,
        uint256 _minProfitTime,
        bool _hasDynamicFees
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultPriceFeedV2 {
    function adjustmentBasisPoints(address _token) external view returns (uint256);
    function isAdjustmentAdditive(address _token) external view returns (bool);
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external;
    function setUseV2Pricing(bool _useV2Pricing) external;
    function setIsAmmEnabled(bool _isEnabled) external;
    function setIsSecondaryPriceEnabled(bool _isEnabled) external;
    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external;
    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external;
    function setFavorPrimaryPrice(bool _favorPrimaryPrice) external;
    function setPriceSampleSpace(uint256 _priceSampleSpace) external;
    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external;
    function getPrice(address _token, bool _maximise,bool,bool) external view returns (uint256);
    function getOrigPrice(address _token) external view returns (uint256);
    
    function getLatestPrimaryPrice(address _token) external view returns (uint256);
    function getPrimaryPrice(address _token, bool _maximise) external view returns (uint256, bool);
    function setTokenChainlink( address _token, address _chainlinkContract) external;
    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IESBT {
    // function updateIncreaseLogForAccount(address _account, address _collateralToken, 
            // uint256 _collateralSize,uint256 _positionSize, bool /*_isLong*/ ) external returns (bool);

    function scorePara(uint256 _paraId) external view returns (uint256);
    function createTime(address _account) external view returns (uint256);
    // function tradingKey(address _account, bytes32 key) external view returns (bytes32);
    function nickName(address _account) external view returns (string memory);


    function getReferralForAccount(address _account) external view returns (address[] memory , address[] memory);
    function userSizeSum(address _account) external view returns (uint256);
    // function updateFeeDiscount(address _account, uint256 _discount, uint256 _rebate) external;
    function updateFee(address _account, uint256 _origFee) external returns (uint256);
    // function calFeeDiscount(address _account, uint256 _amount) external view returns (uint256);

    function getESBTAddMpUintetRoles(address _mpaddress, bytes32 _key) external view returns (uint256[] memory);
    function updateClaimVal(address _account) external ;
    function userClaimable(address _account) external view returns (uint256, uint256);

    // function updateScoreForAccount(address _account, uint256 _USDamount, uint16 _opeType) external;
    function updateScoreForAccount(address _account, address /*_vault*/, uint256 _amount, uint256 _reasonCode) external;
    function updateTradingScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    function updateSwapScoreForAccount(address _account, address _vault, uint256 _amount) external;
    function updateAddLiqScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    // function updateStakeEDEScoreForAccount(address _account, uint256 _amount) external ;
    function getScore(address _account) external view returns (uint256);
    function getRefCode(address _account) external view returns (string memory);
    function accountToDisReb(address _account) external view returns (uint256, uint256);
    function rank(address _account) external view returns (uint256);
    function addressToTokenID(address _account) external view returns (uint256);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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