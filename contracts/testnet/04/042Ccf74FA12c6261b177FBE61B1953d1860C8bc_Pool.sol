// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

import './libraries/DSMath.sol';
import './interfaces/IPriceOracleGetter.sol';
import './Asset.sol';
import './pool/Core.sol';
import './interfaces/IPool.sol';

import './MasterPlatypusV3.sol';
import './PTPV2.sol';

/**
 * @title Pool
 * @notice Manages deposits, withdrawals and swaps. Holds a mapping of assets and parameters.
 * @dev The main entry-point of Platypus protocol
 *
 * Note The Pool is ownable and the owner wields power.
 * Note The ownership will be transferred to a governance contract once Platypus community can show to govern itself.
 *
 * The unique features of the Platypus make it an important subject in the study of evolutionary biology.
 */
contract Pool is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, Core, IPool {
    using DSMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @notice Asset Map struct holds assets
    struct AssetMap {
        address[] keys;
        mapping(address => Asset) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    /// @notice Wei in 1 ether
    uint256 private constant ETH_UNIT = 10**18;

    /// @notice Slippage parameters K, N, C1 and xThreshold
    uint256 private _slippageParamK;
    uint256 private _slippageParamN;
    uint256 private _c1;
    uint256 private _xThreshold;

    /// @notice Haircut rate
    uint256 private _haircutRate;

    /// @notice Retention ratio
    uint256 private _retentionRatio;

    /// @notice Maximum price deviation
    /// @dev states the maximum price deviation allowed between assets
    uint256 private _maxPriceDeviation;

    /// @notice Dev address
    address private _dev;

    /// @notice The price oracle interface used in swaps
    IPriceOracleGetter private _priceOracle;

    /// @notice A record of assets inside Pool
    AssetMap private _assets;

    MasterPlatypusV3 private _masterPlatypus;
    PTPV2 private _ptp;
    uint256 private _sCoinPerMARKET = 200; // 100 times: 200 means 2: 2 Dais = 1 MARKET

    /// @notice An event emitted when an asset is added to Pool
    event AssetAdded(address indexed token, address indexed asset);

    /// @notice An event emitted when a deposit is made to Pool
    event Deposit(address indexed sender, address token, uint256 amount, uint256 liquidity, address indexed to);

    /// @notice An event emitted when a withdrawal is made from Pool
    event Withdraw(address indexed sender, address token, uint256 amount, uint256 liquidity, address indexed to);

    /// @notice An event emitted when dev is updated
    event DevUpdated(address indexed previousDev, address indexed newDev);

    event MasterPlatypusV3Updated(address indexed sender, address prevM, address indexed newM);
    event ScoinPerMARKETUpdated(address indexed sender, uint256 prevRate, uint256 newRate);
    event PTPV2Updated(address indexed sender, address indexed preP, address indexed newP);

    /// @notice An event emitted when oracle is updated
    event OracleUpdated(address indexed previousOracle, address indexed newOracle);

    /// @notice An event emitted when price deviation is updated
    event PriceDeviationUpdated(uint256 previousPriceDeviation, uint256 newPriceDeviation);

    /// @notice An event emitted when slippage params are updated
    event SlippageParamsUpdated(
        uint256 previousK,
        uint256 newK,
        uint256 previousN,
        uint256 newN,
        uint256 previousC1,
        uint256 newC1,
        uint256 previousXThreshold,
        uint256 newXThreshold
    );

    /// @notice An event emitted when haircut is updated
    event HaircutRateUpdated(uint256 previousHaircut, uint256 newHaircut);

    /// @notice An event emitted when retention ratio is updated
    event RetentionRatioUpdated(uint256 previousRetentionRatio, uint256 newRetentionRatio);

    /// @notice An event emitted when a swap is made in Pool
    event Swap(
        address indexed sender,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address indexed to
    );

    /// @dev Modifier ensuring that certain function can only be called by developer
    modifier onlyDev() {
        require(_dev == msg.sender, 'FORBIDDEN');
        _;
    }

    /// @dev Modifier ensuring a certain deadline for a function to complete execution
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    /**
     * @notice Initializes pool. Dev is set to be the account calling this function.
     */
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();

        // set variables
        _slippageParamK = 0.00002e18; //2 * 10**13 == 0.00002 * WETH
        _slippageParamN = 7; // 7
        _c1 = 376927610599998308; // ((k**(1/(n+1))) / (n**((n)/(n+1)))) + (k*n)**(1/(n+1))
        _xThreshold = 329811659274998519; // (k*n)**(1/(n+1))
        _haircutRate = 0.0004e18; // 4 * 10**14 == 0.0004 == 0.04% for intra-aggregate account swap
        _retentionRatio = ETH_UNIT; // 1
        _maxPriceDeviation = 2e28; 

        // set dev
        _dev = msg.sender;
    }

    // Getters //

    function getMasterPlatypusV3() external view returns (address) {
        return address(_masterPlatypus);
    }

    function getScoinPerMARKET() external view returns (uint256) {
        return _sCoinPerMARKET;
    }

    function getPTPV2() external view returns (address) {
        return address(_ptp);
    }

    /**
     * @notice Gets current Dev address
     * @return The current Dev address for Pool
     */
    function getDev() external view returns (address) {
        return _dev;
    }

    /**
     * @notice Gets current Price Oracle address
     * @return The current Price Oracle address for Pool
     */
    function getPriceOracle() external view returns (address) {
        return address(_priceOracle);
    }

    /**
     * @notice Gets current C1 slippage parameter
     * @return The current C1 slippage parameter in Pool
     */
    function getC1() external view returns (uint256) {
        return _c1;
    }

    /**
     * @notice Gets current XThreshold slippage parameter
     * @return The current XThreshold slippage parameter in Pool
     */
    function getXThreshold() external view returns (uint256) {
        return _xThreshold;
    }

    /**
     * @notice Gets current K slippage parameter
     * @return The current K slippage parameter in Pool
     */
    function getSlippageParamK() external view returns (uint256) {
        return _slippageParamK;
    }

    /**
     * @notice Gets current N slippage parameter
     * @return The current N slippage parameter in Pool
     */
    function getSlippageParamN() external view returns (uint256) {
        return _slippageParamN;
    }

    /**
     * @notice Gets current Haircut parameter
     * @return The current Haircut parameter in Pool
     */
    function getHaircutRate() external view returns (uint256) {
        return _haircutRate;
    }

    /**
     * @notice Gets current retention ratio parameter
     * @return The current retention ratio parameter in Pool
     */
    function getRetentionRatio() external view returns (uint256) {
        return _retentionRatio;
    }

    /**
     * @notice Gets current maxPriceDeviation parameter
     * @return The current _maxPriceDeviation parameter in Pool
     */
    function getMaxPriceDeviation() external view returns (uint256) {
        return _maxPriceDeviation;
    }

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external onlyDev {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external onlyDev {
        _unpause();
    }

    // Setters //
    /**
     * @notice Changes the contract dev. Can only be set by the contract owner.
     * @param dev new contract dev address
     */
    function setDev(address dev) external onlyOwner {
        require(dev != address(0), 'ZERO');
        emit DevUpdated(_dev, dev);
        _dev = dev;
    }

    function setMasterPlatypusV3(MasterPlatypusV3 mv) external onlyOwner {
        require(address(mv) != address(0), 'ZERO');
        emit MasterPlatypusV3Updated(msg.sender, address(_masterPlatypus), address(mv));
        _masterPlatypus = mv;
    }

    function setScoinPerMARKET(uint256 rate) external onlyOwner {
        require(rate > 0, 'UNDER_ZERO');
        emit ScoinPerMARKETUpdated(msg.sender, _sCoinPerMARKET, rate);
        _sCoinPerMARKET = rate;
    }

    function setPTPV2(PTPV2 newP) external onlyOwner {
        require(address(newP) != address(0), 'ZERO');
        emit PTPV2Updated(msg.sender, address(_ptp), address(newP));
        _ptp = newP;
    }

    /**
     * @notice Changes the pools slippage params. Can only be set by the contract owner.
     * @param k_ new pool's slippage param K
     * @param n_ new pool's slippage param N
     * @param c1_ new pool's slippage param C1
     * @param xThreshold_ new pool's slippage param xThreshold
     */
    function setSlippageParams(
        uint256 k_,
        uint256 n_,
        uint256 c1_,
        uint256 xThreshold_
    ) external onlyOwner {
        require(k_ <= ETH_UNIT); // k should not be set bigger than 1
        require(n_ > 0); // n should be bigger than 0

        emit SlippageParamsUpdated(_slippageParamK, k_, _slippageParamN, n_, _c1, c1_, _xThreshold, xThreshold_);

        _slippageParamK = k_;
        _slippageParamN = n_;
        _c1 = c1_;
        _xThreshold = xThreshold_;
    }

    /**
     * @notice Changes the pools haircutRate. Can only be set by the contract owner.
     * @param haircutRate_ new pool's haircutRate_
     */
    function setHaircutRate(uint256 haircutRate_) external onlyOwner {
        require(haircutRate_ <= ETH_UNIT); // haircutRate_ should not be set bigger than 1
        emit HaircutRateUpdated(_haircutRate, haircutRate_);
        _haircutRate = haircutRate_;
    }

    /**
     * @notice Changes the pools retentionRatio. Can only be set by the contract owner.
     * @param retentionRatio_ new pool's retentionRatio
     */
    function setRetentionRatio(uint256 retentionRatio_) external onlyOwner {
        require(retentionRatio_ <= ETH_UNIT); // retentionRatio_ should not be set bigger than 1
        emit RetentionRatioUpdated(_retentionRatio, retentionRatio_);
        _retentionRatio = retentionRatio_;
    }

    /**
     * @notice Changes the pools maxPriceDeviation. Can only be set by the contract owner.
     * @param maxPriceDeviation_ new pool's maxPriceDeviation
     */
    function setMaxPriceDeviation(uint256 maxPriceDeviation_) external onlyOwner {
        require(maxPriceDeviation_ <= ETH_UNIT); // maxPriceDeviation_ should not be set bigger than 1
        emit PriceDeviationUpdated(_maxPriceDeviation, maxPriceDeviation_);
        _maxPriceDeviation = maxPriceDeviation_;
    }

    /**
     * @notice Changes the pools priceOracle. Can only be set by the contract owner.
     * @param priceOracle new pool's priceOracle addres
     */
    function setPriceOracle(address priceOracle) external onlyOwner {
        require(priceOracle != address(0), 'ZERO');
        emit OracleUpdated(address(_priceOracle), priceOracle);
        _priceOracle = IPriceOracleGetter(priceOracle);
    }

    // Asset struct functions //

    /**
     * @notice Gets asset with token address key
     * @param key The address of token
     * @return the corresponding asset in state
     */
    function _getAsset(address key) private view returns (Asset) {
        return _assets.values[key];
    }

    /**
     * @notice Gets key (address) at index
     * @param index the index
     * @return the key of index
     */
    function _getKeyAtIndex(uint256 index) private view returns (address) {
        return _assets.keys[index];
    }

    /**
     * @notice get length of asset list
     * @return the size of the asset list
     */
    function _sizeOfAssetList() private view returns (uint256) {
        return _assets.keys.length;
    }

    /**
     * @notice Looks if the asset is contained by the list
     * @param key The address of token to look for
     * @return bool true if the asset is in asset list, false otherwise
     */
    function _containsAsset(address key) private view returns (bool) {
        return _assets.inserted[key];
    }

    /**
     * @notice Adds asset to the list
     * @param key The address of token to look for
     * @param val The asset to add
     */
    function _addAsset(address key, Asset val) private {
        if (_assets.inserted[key]) {
            _assets.values[key] = val;
        } else {
            _assets.inserted[key] = true;
            _assets.values[key] = val;
            _assets.indexOf[key] = _assets.keys.length;
            _assets.keys.push(key);
        }
    }

    /**
     * @notice Removes asset from asset struct
     * @dev Can only be called by owner
     * @param key The address of token to remove
     */
    function removeAsset(address key) external onlyOwner {
        if (!_assets.inserted[key]) {
            return;
        }

        delete _assets.inserted[key];
        delete _assets.values[key];

        uint256 index = _assets.indexOf[key];
        uint256 lastIndex = _assets.keys.length - 1;
        address lastKey = _assets.keys[lastIndex];

        _assets.indexOf[lastKey] = index;
        delete _assets.indexOf[key];

        _assets.keys[index] = lastKey;
        _assets.keys.pop();
    }

    // Pool Functions //
    /**
     * @notice Checks deviation is not higher than specified amount
     * @dev Reverts if deviation is higher than _maxPriceDeviation
     * @param tokenA First token
     * @param tokenB Second token
     */
    function _checkPriceDeviation(address tokenA, address tokenB) private view {
        uint256 tokenAPrice = _priceOracle.getAssetPrice(tokenA);
        uint256 tokenBPrice = _priceOracle.getAssetPrice(tokenB);

        // check if prices respect their maximum deviation for a > b : (a - b) / a < maxDeviation
        if (tokenBPrice > tokenAPrice) {
            require((((tokenBPrice - tokenAPrice) * ETH_UNIT) / tokenBPrice) <= _maxPriceDeviation, 'PRICE_DEV');
        } else {
            require((((tokenAPrice - tokenBPrice) * ETH_UNIT) / tokenAPrice) <= _maxPriceDeviation, 'PRICE_DEV');
        }
    }

    /**
     * @notice gets system equilibrium coverage ratio
     * @dev [ sum of Ai * fi / sum Li * fi ]
     * @return equilibriumCoverageRatio system equilibrium coverage ratio
     */
    function getEquilibriumCoverageRatio() private view returns (uint256) {
        uint256 totalCash = 0;
        uint256 totalLiability = 0;

        // loop on assets
        for (uint256 i = 0; i < _sizeOfAssetList(); i++) {
            // get token address
            address assetAddress = _getKeyAtIndex(i);

            // get token oracle price
            uint256 tokenPrice = _priceOracle.getAssetPrice(assetAddress);

            // used to convert cash and liabilities into ETH_UNIT to have equal decimals accross all assets
            uint256 offset = 10**(18 - _getAsset(assetAddress).decimals());

            totalCash += (_getAsset(assetAddress).cash() * offset * tokenPrice);
            totalLiability += (_getAsset(assetAddress).liability() * offset * tokenPrice);
        }

        // if there are no liabilities or no assets in the pool, return equilibrium state = 1
        if (totalLiability == 0 || totalCash == 0) {
            return ETH_UNIT;
        }

        return totalCash.wdiv(totalLiability);
    }

    /**
     * @notice Adds asset to pool, reverts if asset already exists in pool
     * @param token The address of token
     * @param asset The address of the platypus Asset contract
     */
    function addAsset(address token, address asset) external onlyOwner {
        require(token != address(0), 'ZERO');
        require(asset != address(0), 'ZERO');
        require(!_containsAsset(token), 'ASSET_EXISTS');

        _addAsset(token, Asset(asset));

        emit AssetAdded(token, asset);
    }

    /**
     * @notice Gets Asset corresponding to ERC20 token. Reverts if asset does not exists in Pool.
     * @param token The address of ERC20 token
     */
    function _assetOf(address token) private view returns (Asset) {
        require(_containsAsset(token), 'ASSET_NOT_EXIST');
        return _getAsset(token);
    }

    /**
     * @notice Gets Asset corresponding to ERC20 token. Reverts if asset does not exists in Pool.
     * @dev to be used externally
     * @param token The address of ERC20 token
     */
    function assetOf(address token) external view override returns (address) {
        return address(_assetOf(token));
    }

    /**
     * @notice Deposits asset in Pool
     * @param asset The asset to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the platypus assets (lp)
     * @return liquidity Total asset liquidity minted
     */
    function _deposit(
        Asset asset,
        uint256 amount,
        address to
    ) private returns (uint256 liquidity) {
        uint256 totalSupply = asset.totalSupply();
        uint256 liability = asset.liability();

        uint256 fee = _depositFee(_slippageParamK, _slippageParamN, _c1, _xThreshold, asset.cash(), liability, amount);

        // Calculate amount of LP to mint : ( deposit - fee ) * TotalAssetSupply / Liability
        if (liability == 0) {
            liquidity = amount - fee;
        } else {
            liquidity = ((amount - fee) * totalSupply) / liability;
        }

        // get equilibrium coverage ratio
        uint256 eqCov = getEquilibriumCoverageRatio();

        // apply impairment gain if eqCov < 1
        if (eqCov < ETH_UNIT) {
            liquidity = liquidity.wdiv(eqCov);
        }

        require(liquidity > 0, 'INSUFFICIENT_LIQ_MINT');

        asset.addCash(amount);
        asset.addLiability(amount - fee);
        asset.mint(to, liquidity);
    }

    /**
     * @notice Deposits amount of tokens into pool ensuring deadline
     * @dev Asset needs to be created and added to pool before any operation
     * @param token The token address to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the platypus assets (lp)
     * @param deadline The deadline to be respected
     * @return liquidity Total asset liquidity minted
     */
    function deposit(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256 liquidity) {
        require(amount > 0, 'ZERO_AMOUNT');
        require(token != address(0), 'ZERO');
        require(to != address(0), 'ZERO');

        IERC20 erc20 = IERC20(token);
        Asset asset = _assetOf(token);

        erc20.safeTransferFrom(address(msg.sender), address(asset), amount);
        liquidity = _deposit(asset, amount, to);

        emit Deposit(msg.sender, token, amount, liquidity, to);
    }

    function _innerDeposit(
        address token,
        uint256 amount,
        address to
    ) private whenNotPaused returns (uint256 liquidity) {
        require(amount > 0, 'ZERO_AMOUNT');
        require(token != address(0), 'ZERO');
        require(to != address(0), 'ZERO');

        IERC20 erc20 = IERC20(token);
        Asset asset = _assetOf(token);

        erc20.safeTransferFrom(address(this), address(asset), amount);
        liquidity = _deposit(asset, amount, to);

        emit Deposit(address(this), token, amount, liquidity, to);
    }

    function investProc (
        address token1,
        address token2, 
        address token3,
        uint256 amount1,
        uint256 amount2,
        uint256 amount3,
        uint256 investPercent,
        address from
    ) private {
        uint256 investAmount1 = amount1 * investPercent / 100 / 100;
        uint256 investAmount2 = amount2 * investPercent / 100 / 100;
        uint256 investAmount3 = amount3 * investPercent / 100 / 100;
        
        IERC20(token1).safeTransferFrom(from, address(_assetOf(token1)), investAmount1);
        IERC20(token2).safeTransferFrom(from, address(_assetOf(token2)), investAmount2);
        IERC20(token3).safeTransferFrom(from, address(_assetOf(token3)), investAmount3);
        
        uint256 MARKETAmount = (investAmount1 / 10**ERC20(token1).decimals() + investAmount2 / 10**ERC20(token2).decimals() + investAmount3 / 10**ERC20(token3).decimals()) / _sCoinPerMARKET * 100 * 10**_ptp.decimals();
        _ptp.transferFromWithoutFee(address(_ptp), msg.sender, MARKETAmount);

        IERC20(token1).safeTransferFrom(from, address(this), (amount1-investAmount1));
        IERC20(token2).safeTransferFrom(from, address(this), (amount2-investAmount2));
        IERC20(token3).safeTransferFrom(from, address(this), (amount3-investAmount3)); 
    }
    
    struct TokensParam {
        address token1;
        address token2;
        address token3;
    }

    struct AmountsParam {
        uint256 amount1;
        uint256 amount2;
        uint256 amount3;
    }

    struct ActualToAmountParam {
        uint256 actualToAmount12;
        uint256 actualToAmount13;
        uint256 actualToAmount21;
        uint256 actualToAmount23;
        uint256 actualToAmount31;
        uint256 actualToAmount32;
    }

    function baseAPR (
        uint256 i
    ) public view returns (uint256 apr) {
        return _masterPlatypus.baseAPR(i);
    }

    function swapProc (
        TokensParam memory token,
        AmountsParam memory amount
    ) private returns (
        ActualToAmountParam memory actualToAmount
    ) {
        uint256 baseAPR1 = _masterPlatypus.baseAPR(0); // 10**18 times (USDT)
        uint256 baseAPR2 = _masterPlatypus.baseAPR(1); // 10**18 times (DAI)
        uint256 baseAPR3 = _masterPlatypus.baseAPR(2); // 10**18 times (USDC)
        uint256 sumBaseAPR = baseAPR1 + baseAPR2 + baseAPR3;  

        if (amount.amount1 > 0) {
            (actualToAmount.actualToAmount12, ) = _innerSwap(
                token.token1,
                token.token2,
                amount.amount1 * baseAPR2 / sumBaseAPR,
                0
            );
            (actualToAmount.actualToAmount13, ) = _innerSwap(
                token.token1,
                token.token3,
                amount.amount1 * baseAPR3 / sumBaseAPR,
                0
            );
        } 
        
        if (amount.amount2 > 0) {
            (actualToAmount.actualToAmount21, ) = _innerSwap(
                token.token2,
                token.token1,
                amount.amount2 * baseAPR1 / sumBaseAPR,
                0
            );
            (actualToAmount.actualToAmount23, ) = _innerSwap(
                token.token2,
                token.token3,
                amount.amount2 * baseAPR3 / sumBaseAPR,
                0
            );
        }            

        if (amount.amount3 > 0) {
            (actualToAmount.actualToAmount31, ) = _innerSwap(
                token.token3,
                token.token1,
                amount.amount1 * baseAPR1 / sumBaseAPR,
                0
            );
            (actualToAmount.actualToAmount32, ) = _innerSwap(
                token.token3,
                token.token2,
                amount.amount3 * baseAPR2 / sumBaseAPR,
                0
            );
        }
    }

    function calcDepositsAmount (
        AmountsParam memory amount,
        ActualToAmountParam memory actualToAmount
    ) private view returns (uint256 a1, uint256 a2, uint256 a3) {
        uint256 baseAPR1 = _masterPlatypus.baseAPR(0); // 10**18 times (USDT)
        uint256 baseAPR2 = _masterPlatypus.baseAPR(1); // 10**18 times (DAI)
        uint256 baseAPR3 = _masterPlatypus.baseAPR(2); // 10**18 times (USDC)
        uint256 sumBaseAPR = baseAPR1 + baseAPR2 + baseAPR3;

        // final deposit amounts to each pool
        a1 = amount.amount1 * baseAPR1 / sumBaseAPR + actualToAmount.actualToAmount21 + actualToAmount.actualToAmount31;
        a2 = amount.amount2 * baseAPR2 / sumBaseAPR + actualToAmount.actualToAmount12 + actualToAmount.actualToAmount32;
        a3 = amount.amount3 * baseAPR3 / sumBaseAPR + actualToAmount.actualToAmount13 + actualToAmount.actualToAmount23;
    }

    function depositProc (
        TokensParam memory token,
        AmountsParam memory amount,
        ActualToAmountParam memory actualToAmount,
        address to
    ) private {    

        (uint256 a1, uint256 a2, uint256 a3) = calcDepositsAmount (
            amount, 
            actualToAmount
        );
        
        if (a1 > 0) {
            _innerDeposit(
                token.token1,
                a1,
                to
            );
        }

        if (a2 > 0) {
            _innerDeposit(
                token.token2,
                a2,
                to
            );
        }

        if (a3 > 0) {
            _innerDeposit(
                token.token3,
                a3,
                to
            );
        }
    }

    function depositAuto(
        address token1,
        address token2,
        address token3,
        uint256 amount1,
        uint256 amount2,
        uint256 amount3,
        address to,
        bool isAutoAllocation,
        uint256 investPercent // 100 times: 1500 means 15 percent, 0.15
        //bool isLock,
        //bool lockTimePeriod // unit: second
    ) external whenNotPaused {
        require(amount1 > 0 || amount2 > 0 || amount3 > 0, 'ZERO_AMOUNT');
        require(token1 != address(0) || token2 != address(0) || token3 != address(0), 'ZERO_ADDRESS');
        require(to != address(0), 'ZERO_ADDRESS');
        require(address(_ptp) != address(0), 'depositAuto: _ptp is ZERO_ADDRESS');
        require(address(_masterPlatypus) != address(0), 'depositAuto: _masterPlatypus is ZERO_ADDRESS');        

        if (investPercent > 0) {            
            investProc (token1, token2, token3, amount1, amount2, amount3, investPercent, address(msg.sender));
        } else {
            IERC20(token1).safeTransferFrom(address(msg.sender), address(this), amount1);
            IERC20(token2).safeTransferFrom(address(msg.sender), address(this), amount2);
            IERC20(token3).safeTransferFrom(address(msg.sender), address(this), amount3);            
        }

        if (isAutoAllocation) {            
            TokensParam memory tokens = TokensParam (token1, token2, token3);
            AmountsParam memory amounts = AmountsParam (amount1, amount2, amount3);

            ActualToAmountParam memory actualToAmount = swapProc (
                tokens,
                amounts
            );

            // depositProc (
            //     tokens,
            //     amounts,
            //     actualToAmount,
            //     msg.sender
            // );
        }
    }

    /**
     * @notice Calculates fee and liability to burn in case of withdrawal
     * @param asset The asset willing to be withdrawn
     * @param liquidity The liquidity willing to be withdrawn
     * @return amount Total amount to be withdrawn from Pool
     * @return liabilityToBurn Total liability to be burned by Pool
     * @return fee The fee of the withdraw operation
     */
    function _withdrawFrom(Asset asset, uint256 liquidity)
        private
        view
        returns (
            uint256 amount,
            uint256 liabilityToBurn,
            uint256 fee,
            bool enoughCash
        )
    {
        liabilityToBurn = (asset.liability() * liquidity) / asset.totalSupply();
        require(liabilityToBurn > 0, 'INSUFFICIENT_LIQ_BURN');

        fee = _withdrawalFee(
            _slippageParamK,
            _slippageParamN,
            _c1,
            _xThreshold,
            asset.cash(),
            asset.liability(),
            liabilityToBurn
        );

        // Get equilibrium coverage ratio before withdraw
        uint256 eqCov = getEquilibriumCoverageRatio();

        // Init enoughCash to true
        enoughCash = true;

        // Apply impairment in the case eqCov < 1
        uint256 amountAfterImpairment;
        if (eqCov < ETH_UNIT) {
            amountAfterImpairment = (liabilityToBurn).wmul(eqCov);
        } else {
            amountAfterImpairment = liabilityToBurn;
        }

        // Prevent underflow in case withdrawal fees >= liabilityToBurn, user would only burn his underlying liability
        if (amountAfterImpairment > fee) {
            amount = amountAfterImpairment - fee;

            // If not enough cash
            if (asset.cash() < amount) {
                amount = asset.cash(); // When asset does not contain enough cash, just withdraw the remaining cash
                fee = 0;
                enoughCash = false;
            }
        } else {
            fee = amountAfterImpairment; // fee overcomes the amount to withdraw. User would be just burning liability
            amount = 0;
            enoughCash = false;
        }
    }

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param asset The asset to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @return amount The total amount withdrawn
     */
    function _withdraw(
        Asset asset,
        uint256 liquidity,
        uint256 minimumAmount,
        address to
    ) private returns (uint256 amount) {
        // calculate liabilityToBurn and Fee
        uint256 liabilityToBurn;
        (amount, liabilityToBurn, , ) = _withdrawFrom(asset, liquidity);

        require(minimumAmount <= amount, 'AMOUNT_TOO_LOW');

        asset.burn(msg.sender, liquidity);
        asset.removeCash(amount);
        asset.removeLiability(liabilityToBurn);
        asset.transferUnderlyingToken(to, amount);
    }

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param token The token to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @return amount The total amount withdrawn
     */
    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256 amount) {
        require(liquidity > 0, 'ZERO_ASSET_AMOUNT');
        require(token != address(0), 'ZERO');
        require(to != address(0), 'ZERO');

        Asset asset = _assetOf(token);

        amount = _withdraw(asset, liquidity, minimumAmount, to);

        emit Withdraw(msg.sender, token, amount, liquidity, to);
    }

    /**
     * @notice Enables withdrawing liquidity from an asset using LP from a different asset in the same aggregate
     * @param initialToken The corresponding token user holds the LP (Asset) from
     * @param wantedToken The token wanting to be withdrawn (needs to be well covered)
     * @param liquidity The liquidity to be withdrawn (in wanted token d.p.)
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @dev initialToken and wantedToken assets' must be in the same aggregate
     * @dev Also, cov of wantedAsset must be higher than 1 after withdrawal for this to be accepted
     * @return amount The total amount withdrawn
     */
    function withdrawFromOtherAsset(
        address initialToken,
        address wantedToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256 amount) {
        require(liquidity > 0, 'ZERO_ASSET_AMOUNT');
        require(wantedToken != address(0), 'ZERO');
        require(initialToken != address(0), 'ZERO');
        require(to != address(0), 'ZERO');

        // get corresponding assets
        Asset initialAsset = _assetOf(initialToken);
        Asset wantedAsset = _assetOf(wantedToken);

        // assets need to be in the same aggregate in order to allow for withdrawing other assets
        require(wantedAsset.aggregateAccount() == initialAsset.aggregateAccount(), 'DIFF_AGG_ACC');

        // check if price deviation is OK between assets
        _checkPriceDeviation(initialToken, wantedToken);

        // Convert liquidity to d.p of initial asset
        uint256 liquidityInInitialAssetDP = (liquidity * 10**initialAsset.decimals()) / (10**wantedAsset.decimals());

        // require liquidity in initial asset dp to be > 0
        require(liquidityInInitialAssetDP > 0, 'DUST?');

        // request lp token from user
        IERC20Upgradeable(initialAsset).safeTransferFrom(
            address(msg.sender),
            address(initialAsset),
            liquidityInInitialAssetDP
        );

        // calculate liabilityToBurn and amount
        bool enoughCash;
        (amount, , , enoughCash) = _withdrawFrom(wantedAsset, liquidity);

        // If not enough cash in wanted asset, revert
        require(enoughCash, 'NOT_ENOUGH_CASH');

        // require after withdrawal coverage to >= 1
        require((wantedAsset.cash() - amount).wdiv(wantedAsset.liability()) >= ETH_UNIT, 'COV_RATIO_LOW');

        // require amount to be higher than the amount specified
        require(minimumAmount <= amount, 'AMOUNT_TOO_LOW');

        // calculate liability to burn in initialAsset
        uint256 liabilityToBurn = (initialAsset.liability() * liquidityInInitialAssetDP) / initialAsset.totalSupply();

        // burn initial asset recovered liquidity
        initialAsset.burn(address(initialAsset), liquidityInInitialAssetDP);
        initialAsset.removeLiability(liabilityToBurn); // remove liability from initial asset
        wantedAsset.removeCash(amount); // remove cash from wanted asset
        wantedAsset.transferUnderlyingToken(to, amount); // transfer wanted token to user

        emit Withdraw(msg.sender, wantedToken, amount, liquidityInInitialAssetDP, to);
    }

    /**
     * @notice Swap fromToken for toToken, ensures deadline and minimumToAmount and sends quoted amount to `to` address
     * @param fromToken The token being inserted into Pool by user for swap
     * @param toToken The token wanted by user, leaving the Pool
     * @param fromAmount The amount of from token inserted
     * @param minimumToAmount The minimum amount that will be accepted by user as result
     * @param to The user receiving the result of swap
     * @param deadline The deadline to be respected
     * @return actualToAmount The actual amount user receive
     * @return haircut The haircut that would be applied
     */
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external override ensure(deadline) nonReentrant whenNotPaused returns (uint256 actualToAmount, uint256 haircut) {
        require(fromToken != address(0), 'ZERO');
        require(toToken != address(0), 'ZERO');
        require(fromToken != toToken, 'SAME_ADDRESS');
        require(fromAmount > 0, 'ZERO_FROM_AMOUNT');
        require(to != address(0), 'ZERO');

        IERC20 fromERC20 = IERC20(fromToken);
        Asset fromAsset = _assetOf(fromToken);
        Asset toAsset = _assetOf(toToken);

        // Intrapool swapping only
        require(toAsset.aggregateAccount() == fromAsset.aggregateAccount(), 'DIFF_AGG_ACC');

        (actualToAmount, haircut) = _quoteFrom(fromAsset, toAsset, fromAmount);
        require(minimumToAmount <= actualToAmount, 'AMOUNT_TOO_LOW');

        fromERC20.safeTransferFrom(address(msg.sender), address(fromAsset), fromAmount);
        fromAsset.addCash(fromAmount);
        toAsset.removeCash(actualToAmount);
        toAsset.addLiability(_dividend(haircut, _retentionRatio));
        toAsset.transferUnderlyingToken(to, actualToAmount);       

        emit Swap(msg.sender, fromToken, toToken, fromAmount, actualToAmount, to);
    }

    function _innerSwap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount
    ) private whenNotPaused returns (uint256 actualToAmount, uint256 haircut) {
        require(fromToken != address(0), 'ZERO');
        require(toToken != address(0), 'ZERO');
        require(fromToken != toToken, 'SAME_ADDRESS');
        require(fromAmount > 0, 'ZERO_FROM_AMOUNT');

        IERC20 fromERC20 = IERC20(fromToken);
        Asset fromAsset = _assetOf(fromToken);
        Asset toAsset = _assetOf(toToken);

        // Intrapool swapping only
        require(toAsset.aggregateAccount() == fromAsset.aggregateAccount(), 'DIFF_AGG_ACC');

        (actualToAmount, haircut) = _quoteFrom(fromAsset, toAsset, fromAmount);
        require(minimumToAmount <= actualToAmount, 'AMOUNT_TOO_LOW');

        fromERC20.safeTransferFrom(address(this), address(fromAsset), fromAmount);
        fromAsset.addCash(fromAmount);
        toAsset.removeCash(actualToAmount);
        toAsset.addLiability(_dividend(haircut, _retentionRatio));
        toAsset.transferUnderlyingToken(address(this), actualToAmount);        
    }

    /**
     * @notice Swap fromToken for toToken, ensures deadline and minimumToAmount and sends quoted amount to `to` address
     * @param fromToken The token being inserted into Pool by user for swap
     * @param toToken The token wanted by user, leaving the Pool
     * @param fromAmount The amount of from token inserted
     * @param minimumToAmount The minimum amount that will be accepted by user as result
     * @param to The user receiving the result of swap
     * @param deadline The deadline to be respected
     * @return actualToAmount The actual amount user receive
     * @return haircut The haircut that would be applied
     */
    function swapBasedPrice(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external ensure(deadline) returns (uint256 actualToAmount, uint256 haircut) {
        require(fromToken != address(0), 'ZERO');
        require(toToken != address(0), 'ZERO');
        require(fromToken != toToken, 'SAME_ADDRESS');
        require(fromAmount > 0, 'ZERO_FROM_AMOUNT');
        require(to != address(0), 'ZERO');

        IERC20 fromERC20 = IERC20(fromToken);
        Asset fromAsset = _assetOf(fromToken);
        Asset toAsset = _assetOf(toToken);

        // Intrapool swapping only
        require(toAsset.aggregateAccount() == fromAsset.aggregateAccount(), 'DIFF_AGG_ACC');

        (actualToAmount, haircut) = _quoteFromBasedPrice(fromToken, toToken, fromAsset, toAsset, fromAmount);
        require(minimumToAmount <= actualToAmount, 'AMOUNT_TOO_LOW');

        fromERC20.safeTransferFrom(address(msg.sender), address(fromAsset), fromAmount);
        fromAsset.addCash(fromAmount);
        toAsset.removeCash(actualToAmount);
        toAsset.addLiability(_dividend(haircut, _retentionRatio));
        toAsset.transferUnderlyingToken(to, actualToAmount);

        emit Swap(msg.sender, fromToken, toToken, fromAmount, actualToAmount, to);
    }

    /**
     * @notice Quotes the actual amount user would receive in a swap, taking in account slippage and haircut
     * @param fromAsset The initial asset
     * @param toAsset The asset wanted by user
     * @param fromAmount The amount to quote
     * @return actualToAmount The actual amount user would receive
     * @return haircut The haircut that will be applied
     */
    function _quoteFromBasedPrice(
        address fromToken,
        address toToken,
        Asset fromAsset,
        Asset toAsset,
        uint256 fromAmount
    ) private view returns (uint256 actualToAmount, uint256 haircut) {
        uint256 fromPrice = _priceOracle.getAssetPrice(fromToken);
        uint toPrice = _priceOracle.getAssetPrice(toToken);
        uint256 toAmount = fromAmount*fromPrice/toPrice;     
        uint256 idealToAmount = _quoteIdealToAmount(fromAsset, toAsset, fromAmount);
        require(toAsset.cash() >= idealToAmount, 'INSUFFICIENT_CASH');   
        haircut = _haircut(toAmount, _haircutRate);
        actualToAmount = toAmount - haircut;
    }

    /**
     * @notice Quotes the actual amount user would receive in a swap, taking in account slippage and haircut
     * @param fromAsset The initial asset
     * @param toAsset The asset wanted by user
     * @param fromAmount The amount to quote
     * @return actualToAmount The actual amount user would receive
     * @return haircut The haircut that will be applied
     */
    function _quoteFrom(
        Asset fromAsset,
        Asset toAsset,
        uint256 fromAmount
    ) private view returns (uint256 actualToAmount, uint256 haircut) {
        uint256 idealToAmount = _quoteIdealToAmount(fromAsset, toAsset, fromAmount);
        require(toAsset.cash() >= idealToAmount, 'INSUFFICIENT_CASH');

        uint256 slippageFrom = _slippage(
            _slippageParamK,
            _slippageParamN,
            _c1,
            _xThreshold,
            fromAsset.cash(),
            fromAsset.liability(),
            fromAmount,
            true
        );
        uint256 slippageTo = _slippage(
            _slippageParamK,
            _slippageParamN,
            _c1,
            _xThreshold,
            toAsset.cash(),
            toAsset.liability(),
            idealToAmount,
            false
        );
        uint256 swappingSlippage = _swappingSlippage(slippageFrom, slippageTo);
        uint256 toAmount = idealToAmount.wmul(swappingSlippage);
        haircut = _haircut(toAmount, _haircutRate);
        actualToAmount = toAmount - haircut;
    }

    /**
     * @notice Quotes the ideal amount in case of swap
     * @dev Does not take into account slippage parameters nor haircut
     * @param fromAsset The initial asset
     * @param toAsset The asset wanted by user
     * @param fromAmount The amount to quote
     * @return idealToAmount The ideal amount user would receive
     */
    function _quoteIdealToAmount(
        Asset fromAsset,
        Asset toAsset,
        uint256 fromAmount
    ) private view returns (uint256 idealToAmount) {
        // check deviation is not higher than specified amount
        _checkPriceDeviation(fromAsset.underlyingToken(), toAsset.underlyingToken());

        // assume perfect peg between assets
        idealToAmount = ((fromAmount * 10**toAsset.decimals()) / 10**fromAsset.decimals());
    }

    /**
     * @notice Quotes potential outcome of a swap given current state, taking in account slippage and haircut
     * @dev To be used by frontend
     * @param fromToken The initial ERC20 token
     * @param toToken The token wanted by user
     * @param fromAmount The amount to quote
     * @return potentialOutcome The potential amount user would receive
     * @return haircut The haircut that would be applied
     */
    function quotePotentialSwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view override whenNotPaused returns (uint256 potentialOutcome, uint256 haircut) {
        require(fromToken != address(0), 'ZERO');
        require(toToken != address(0), 'ZERO');
        require(fromToken != toToken, 'SAME_ADDRESS');
        require(fromAmount > 0, 'ZERO_FROM_AMOUNT');

        Asset fromAsset = _assetOf(fromToken);
        Asset toAsset = _assetOf(toToken);

        // Intrapool swapping only
        require(toAsset.aggregateAccount() == fromAsset.aggregateAccount(), 'DIFF_AGG_ACC');

        (potentialOutcome, haircut) = _quoteFromBasedPrice(fromToken, toToken, fromAsset, toAsset, fromAmount);
    }

    /**
     * @notice Quotes potential withdrawal from pool
     * @dev To be used by frontend
     * @param token The token to be withdrawn by user
     * @param liquidity The liquidity (amount of lp assets) to be withdrawn
     * @return amount The potential amount user would receive
     * @return fee The fee that would be applied
     * @return enoughCash does the pool have enough cash? (cash >= liabilityToBurn - fee)
     */
    function quotePotentialWithdraw(address token, uint256 liquidity)
        external
        view
        override
        whenNotPaused
        returns (
            uint256 amount,
            uint256 fee,
            bool enoughCash
        )
    {
        require(token != address(0), 'ZERO');
        require(liquidity > 0, 'LIQ=0');

        Asset asset = _assetOf(token);
        (amount, , fee, enoughCash) = _withdrawFrom(asset, liquidity);
    }       

    /**
     * @notice Gets addresses of underlying token in pool
     * @dev To be used externally
     * @return addresses of assets in the pool
     */
    function getTokenAddresses() external view override returns (address[] memory) {
        return _assets.keys;
    }
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library DSMath {
    uint256 public constant WAD = 10**18;
    uint256 public constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }

    function reciprocal(uint256 x) internal pure returns (uint256) {
        return wdiv(WAD, x);
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = ((x * y) + (RAY / 2)) / RAY;
    }
}

// Based on AAVE protocol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

/// @title IPriceOracleGetter interface
interface IPriceOracleGetter {
    /// @dev returns the asset price in ETH
    function getAssetPrice(address _asset) external view returns (uint256);

    /// @dev returns the reciprocal of asset price
    function getAssetPriceReciprocal(address _asset) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './interfaces/IAsset.sol';

/**
 * @title Asset
 * @notice Contract presenting an asset in pools
 * @dev Expect to be owned by Timelock for management, and _pools links to Pools for coordination
 */
contract Asset is Initializable, OwnableUpgradeable, ERC20Upgradeable, IAsset {
    using SafeERC20 for IERC20; // underlying token is ERC20

    /// @notice The underlying underlyingToken represented by this asset
    address private _underlyingToken;    
    /// @notice base pool and masterpool
    address[] private _pools;
    /// @notice Cash balance, normally it should align with IERC20(_underlyingToken).balanceOf(address(this))
    uint256 private _cash;
    /// @notice Total liability, equals to the sum of deposit and dividend
    uint256 private _liability;
    /// @notice Owner
    address private _owner;
    /// @notice Aggregate Account of the asset
    address private _aggregateAccount;
    /// @notice _maxSupply the maximum amount of asset the pool is allowed to mint.
    /// @dev if 0, means asset has no max
    uint256 private _maxSupply;

    /// @notice An event thats emitted when pool is updated
    event PoolUpdated(address indexed previousPool, address indexed newPool);

    /// @notice An event thats emitted when max supply is updated
    event MaxSupplyUpdated(uint256 previousMaxSupply, uint256 newMaxSupply);

    /// @notice An event thats emitted when cash is addedd
    event CashAdded(uint256 previousCashPosition, uint256 cashBeingAdded);

    /// @notice An event thats emitted when cash is removed
    event CashRemoved(uint256 previousCashPosition, uint256 cashBeingRemoved);

    /// @notice An event thats emitted when liability is added
    event LiabilityAdded(uint256 previousLiabilityPosition, uint256 liabilityBeingAdded);

    /// @notice An event thats emitted when liability is removed
    event LiabilityRemoved(uint256 previousLiabilityPosition, uint256 liabilityBeingRemoved);

    /**
     * @notice Initializer.
     * @dev _ suffix to avoid shadowing underlyingToken() name and  symbol
     * @dev max decimal points for underlying token is 18.
     * @param underlyingToken_ The token represented by the asset
     * @param name_ The name of the asset
     * @param symbol_ The symbol of the asset
     * @param aggregateAccount_ The aggregate account to which the the asset belongs
     */
    function initialize(
        address underlyingToken_,
        string memory name_,
        string memory symbol_,
        address aggregateAccount_
    ) external initializer {
        require(underlyingToken_ != address(0), 'PTL:Token address cannot be zero');
        require(aggregateAccount_ != address(0), 'PTL:Aggregate account address cannot be zero');
        require(ERC20(underlyingToken_).decimals() <= 18, 'PLT:Decimals must be under 18');

        __Ownable_init();
        __ERC20_init(name_, symbol_);

        _owner = msg.sender;
        _underlyingToken = underlyingToken_;
        _aggregateAccount = aggregateAccount_;
    }

    /// @dev Modifier ensuring that certain function can only be called by pool
    modifier onlyPool() {
        require(isPool(msg.sender), 'PTL:FORBIDDEN');
        _;
    }

    function isPool(address pool) private view returns (bool) {
        bool ispool = false;
        for (uint256 i=0;i<_pools.length;i++) {
            if (pool == _pools[i]) ispool = true;
        }
        return ispool;
    }

    /**
     * @notice Gets current asset max supply
     * @return The current max supply of asset
     */
    function maxSupply() external view override returns (uint256) {
        return _maxSupply;
    }

    /**
     * @notice Changes asset max supply. Can only be set by the contract owner.
     * @param maxSupply_ the new asset's max supply
     */
    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        emit MaxSupplyUpdated(_maxSupply, maxSupply_);
        _maxSupply = maxSupply_;
    }

    /**
     * @notice Changes the pool. Can only be set by the contract owner.
     * @param pool_ new pool's address
     */
    function setPool(address pool_) external onlyOwner {
        require(pool_ != address(0), 'PTL:Pool address cannot be zero');
        require(!isPool(pool_), 'PTL: already exist');
        _pools.push(pool_);
    }

    /**
     * @notice Changes the aggregate account. Can only be set by the contract owner.
     * @param aggregateAccount_ new aggregate account address
     */
    function setAggregateAccount(address aggregateAccount_) external onlyOwner {
        require(aggregateAccount_ != address(0), 'PTL:Aggregate Account address cannot be zero');
        _aggregateAccount = aggregateAccount_;
    }

    /**
     * @notice Returns the address of the Aggregate Account 'holding' this asset
     * @return The current Aggregate Account address for Asset
     */
    function aggregateAccount() external view override returns (address) {
        return _aggregateAccount;
    }

    /**
     * @notice Returns the address of ERC20 underlyingToken represented by this asset
     * @return The current address of ERC20 underlyingToken for Asset
     */
    function underlyingToken() external view override returns (address) {
        return _underlyingToken;
    }

    /**
     * @notice Returns the decimals of ERC20 underlyingToken
     * @return The current decimals for underlying token
     */
    function decimals() public view override(IAsset, ERC20Upgradeable) returns (uint8) {
        // `decimals` not in IERC20
        return ERC20(_underlyingToken).decimals();
    }

    /**
     * @notice Get underlying Token Balance
     * @return Returns the actual balance of ERC20 underlyingToken
     */
    function underlyingTokenBalance() external view override returns (uint256) {
        return IERC20(_underlyingToken).balanceOf(address(this));
    }

    /**
     * @notice Transfers ERC20 underlyingToken from this contract to another account. Can only be called by Pool.
     * @dev Not to be confused with transferring platypus Assets.
     * @param to address to transfer the token to
     * @param amount amount to transfer
     */
    function transferUnderlyingToken(address to, uint256 amount) external onlyPool {
        IERC20(_underlyingToken).safeTransfer(to, amount);
    }

    /**
     * @notice Mint Asset Token, expect pool coordinates other state updates. Can only be called by Pool.
     * @param to address to transfer the token to
     * @param amount amount to transfer
     */
    function mint(address to, uint256 amount) external onlyPool {
        if (this.maxSupply() != 0) {
            // if maxSupply == 0, asset is uncapped.
            require(amount + this.totalSupply() <= this.maxSupply(), 'PTL:MAX_SUPPLY_REACHED');
        }
        return _mint(to, amount);
    }

    /**
     * @notice Burn Asset Token, expect pool coordinates other state updates. Can only be called by Pool.
     * @param to address holding the tokens
     * @param amount amount to burn
     */
    function burn(address to, uint256 amount) external onlyPool {
        return _burn(to, amount);
    }

    /**
     * @notice Returns the amount of underlyingToken transferrable, expect to match underlyingTokenBalance()
     */
    function cash() external view override returns (uint256) {
        return _cash;
    }

    /**
     * @notice Adds cash, expects actual ERC20 underlyingToken got transferred in. Can only be called by Pool.
     * @param amount amount to add
     */
    function addCash(uint256 amount) external onlyPool {
        _cash += amount;
        emit CashAdded(this.cash() - amount, amount);
    }

    /**
     * @notice Deducts cash, expect actual ERC20 got transferred out (by transferUnderlyingToken()).
     * Can only be called by Pool.
     * @param amount amount to remove
     */
    function removeCash(uint256 amount) external onlyPool {
        require(_cash >= amount, 'PTL:INSUFFICIENT_CASH');
        _cash -= amount;
        emit CashRemoved(this.cash() + amount, amount);
    }

    /**
     * @notice Returns the amount of liability, the total deposit and dividend
     */
    function liability() external view override returns (uint256) {
        return _liability;
    }

    /**
     * @notice Adds deposit or dividend, expect LP underlyingToken minted in case of deposit.
     * Can only be called by Pool.
     * @param amount amount to add
     */
    function addLiability(uint256 amount) external onlyPool {
        _liability += amount;
        emit LiabilityAdded(this.liability() - amount, amount);
    }

    /**
     * @notice Removes deposit and dividend earned, expect LP underlyingToken burnt.
     * Can only be called by Pool.
     * @param amount amount to remove
     */
    function removeLiability(uint256 amount) external onlyPool {
        require(_liability >= amount, 'PTL:INSUFFICIENT_LIABILITY');
        _liability -= amount;
        emit LiabilityRemoved(this.liability() + amount, amount);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

import '../libraries/DSMath.sol';

/**
 * @title Core
 * @notice Handles math operations of Platypus protocol.
 * @dev Uses DSMath to compute using WAD and RAY.
 */
contract Core {
    using DSMath for uint256;

    /// @notice WAD unit. Used to handle most numbers.
    uint256 internal constant WAD = 10**18;

    /// @notice RAY unit. Used for rpow function.
    uint256 internal constant RAY = 10**27;

    /// @notice Accommodates unforeseen upgrades to Core.
    bytes32[64] internal emptyArray;

    /**
     * @notice Yellow Paper Def. 2.4 (Price Slippage Curve)
     * @dev Calculates g(xr,i) or g(xr,j). This function always returns >= 0
     * @param k K slippage parameter in WAD
     * @param n N slippage parameter
     * @param c1 C1 slippage parameter in WAD
     * @param xThreshold xThreshold slippage parameter in WAD
     * @param x coverage ratio of asset in WAD
     * @return The result of price slippage curve
     */
    function _slippageFunc(
        uint256 k,
        uint256 n,
        uint256 c1,
        uint256 xThreshold,
        uint256 x
    ) internal pure returns (uint256) {
        if (x < xThreshold) {
            return c1 - x;
        } else {
            return k.wdiv((((x * RAY) / WAD).rpow(n) * WAD) / RAY); // k / (x ** n)
        }
    }

    /**
     * @notice Yellow Paper Def. 2.4 (Asset Slippage)
     * @dev Calculates -Si or -Sj (slippage from and slippage to)
     * @param k K slippage parameter in WAD
     * @param n N slippage parameter
     * @param c1 C1 slippage parameter in WAD
     * @param xThreshold xThreshold slippage parameter in WAD
     * @param cash cash position of asset in WAD
     * @param cashChange cashChange of asset in WAD
     * @param addCash true if we are adding cash, false otherwise
     * @return The result of one-sided asset slippage
     */
    function _slippage(
        uint256 k,
        uint256 n,
        uint256 c1,
        uint256 xThreshold,
        uint256 cash,
        uint256 liability,
        uint256 cashChange,
        bool addCash
    ) internal pure returns (uint256) {
        uint256 covBefore = cash.wdiv(liability);
        uint256 covAfter;
        if (addCash) {
            covAfter = (cash + cashChange).wdiv(liability);
        } else {
            covAfter = (cash - cashChange).wdiv(liability);
        }

        // if cov stays unchanged, slippage is 0
        if (covBefore == covAfter) {
            return 0;
        }

        uint256 slippageBefore = _slippageFunc(k, n, c1, xThreshold, covBefore);
        uint256 slippageAfter = _slippageFunc(k, n, c1, xThreshold, covAfter);

        if (covBefore > covAfter) {
            return (slippageAfter - slippageBefore).wdiv(covBefore - covAfter);
        } else {
            return (slippageBefore - slippageAfter).wdiv(covAfter - covBefore);
        }
    }

    /**
     * @notice Yellow Paper Def. 2.5 (Swapping Slippage). Calculates 1 - (Si - Sj).
     * Uses the formula 1 + (-Si) - (-Sj), with the -Si, -Sj returned from _slippage
     * @dev Adjusted to prevent dealing with underflow of uint256
     * @param si -si slippage parameter in WAD
     * @param sj -sj slippage parameter
     * @return The result of swapping slippage (1 - Si->j)
     */
    function _swappingSlippage(uint256 si, uint256 sj) internal pure returns (uint256) {
        return WAD + si - sj;
    }

    /**
     * @notice Yellow Paper Def. 4.0 (Haircut).
     * @dev Applies haircut rate to amount
     * @param amount The amount that will receive the discount
     * @param rate The rate to be applied
     * @return The result of operation.
     */
    function _haircut(uint256 amount, uint256 rate) internal pure returns (uint256) {
        return amount.wmul(rate);
    }

    /**
     * @notice Applies dividend to amount
     * @param amount The amount that will receive the discount
     * @param ratio The ratio to be applied in dividend
     * @return The result of operation.
     */
    function _dividend(uint256 amount, uint256 ratio) internal pure returns (uint256) {
        return amount.wmul(WAD - ratio);
    }

    /**
     * @notice Yellow Paper Def. 5.2 (Withdrawal Fee)
     * @dev When covBefore >= 1, fee is 0
     * @dev When covBefore < 1, we apply a fee to prevent withdrawal arbitrage
     * @param k K slippage parameter in WAD
     * @param n N slippage parameter
     * @param c1 C1 slippage parameter in WAD
     * @param xThreshold xThreshold slippage parameter in WAD
     * @param cash cash position of asset in WAD
     * @param liability liability position of asset in WAD
     * @param amount amount to be withdrawn in WAD
     * @return The final fee to be applied
     */
    function _withdrawalFee(
        uint256 k,
        uint256 n,
        uint256 c1,
        uint256 xThreshold,
        uint256 cash,
        uint256 liability,
        uint256 amount
    ) internal pure returns (uint256) {
        uint256 covBefore = cash.wdiv(liability);
        if (covBefore >= WAD) {
            return 0;
        }

        if (liability <= amount) {
            return 0;
        }

        uint256 cashAfter;
        // Cover case where cash <= amount
        if (cash > amount) {
            cashAfter = cash - amount;
        } else {
            cashAfter = 0;
        }

        uint256 covAfter = (cashAfter).wdiv(liability - amount);
        uint256 slippageBefore = _slippageFunc(k, n, c1, xThreshold, covBefore);
        uint256 slippageAfter = _slippageFunc(k, n, c1, xThreshold, covAfter);
        uint256 slippageNeutral = _slippageFunc(k, n, c1, xThreshold, WAD); // slippage on cov = 1

        // fee = [(Li - Di) * SlippageAfter] + [g(1) * Di] - [Li * SlippageBefore]
        return
            ((liability - amount).wmul(slippageAfter) + slippageNeutral.wmul(amount)) - liability.wmul(slippageBefore);
    }

    /**
     * @notice Yellow Paper Def. 6.2 (Arbitrage Fee) / Deposit fee
     * @dev When covBefore <= 1, fee is 0
     * @dev When covBefore > 1, we apply a fee to prevent deposit arbitrage
     * @param k K slippage parameter in WAD
     * @param n N slippage parameter
     * @param c1 C1 slippage parameter in WAD
     * @param xThreshold xThreshold slippage parameter in WAD
     * @param cash cash position of asset in WAD
     * @param liability liability position of asset in WAD
     * @param amount amount to be deposited in WAD
     * @return The final fee to be applied
     */
    function _depositFee(
        uint256 k,
        uint256 n,
        uint256 c1,
        uint256 xThreshold,
        uint256 cash,
        uint256 liability,
        uint256 amount
    ) internal pure returns (uint256) {
        // cover case where the asset has no liquidity yet
        if (liability == 0) {
            return 0;
        }

        uint256 covBefore = cash.wdiv(liability);
        if (covBefore <= WAD) {
            return 0;
        }

        uint256 covAfter = (cash + amount).wdiv(liability + amount);
        uint256 slippageBefore = _slippageFunc(k, n, c1, xThreshold, covBefore);
        uint256 slippageAfter = _slippageFunc(k, n, c1, xThreshold, covAfter);

        // (Li + Di) * g(cov_after) - Li * g(cov_before)
        return ((liability + amount).wmul(slippageAfter)) - (liability.wmul(slippageBefore));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

interface IPool {
    function assetOf(address token) external view returns (address);

    function deposit(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external returns (uint256 liquidity);

    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function withdrawFromOtherAsset(
        address initialToken,
        address wantedToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 actualToAmount, uint256 haircut);

    function quotePotentialSwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 potentialOutcome, uint256 haircut);

    function quotePotentialWithdraw(address token, uint256 liquidity)
        external
        view
        returns (
            uint256 amount,
            uint256 fee,
            bool enoughCash
        );

    

    function getTokenAddresses() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import './PTPV2.sol';
import './VePTPV3.sol';
import './Asset.sol';
import './libraries/Math.sol';

contract MasterPlatypusV3 {    

    /** 
        pid:  0 - USDT_LP
              1 - DAI_LP
              2 - USDC_LP
    */
    struct LPStakedUserInfo {
        uint256 lpAmount;
        uint256 rewardAmount;
        uint256 lastTimestamp; // second
        uint256 pid;
    }

    struct PTPStakedUserInfo {
        uint256 ptpAmount;
        uint256 rewardAmount;
        uint256 lastTimestamp; // second        
    }

    address private _owner;
    PTPV2 public PTP;
    VePTPV3 public VePTP;

    address private USDT_LP = address(0x4937ECa119a501072F0b4DeEe7f3C5c3A7F5ef24);
    address private BUSD_LP = address(0xBB0fc3c79c579fDF28C1B92f439bAa54BA2d7c99);
    address private DAI_LP = address(0xb226c0cE7E5153e27793F10baa3c0425B2382f47);
    address private USDC_LP = address(0xCbF81F1176438A70B5986324E1Bb78A6Bd3ec74E);
    address[] public lpTokens;    
    mapping(uint256 => mapping(address => LPStakedUserInfo)) private _lpStakedUserInfo;
    mapping(address => PTPStakedUserInfo) private _ptpStakedUserInfo;
    
    uint256 private _rfBasePTP = 1157400000; //1157400000 = 1.1574 * 10**9
    uint256 private _rfBoostPTP = 1157400000; //9000000000 = 9 * 10**9
    uint256 private _rfVePTP = 3858100000000;  // 10**(-18) * 10month *_rfVePTP = 100 => _rfVePTP = 10**20 / 10month = 3.859*10**12 = 3858100000000
    uint256 private _rfVePTPMultiple = 100;    // users can get reward maximum 100 times of staked PTP amount

    /** Reward Generation Formula
    - Total PTP Reward Amount = Base PTP Reward Amount + Boost PTP Reward Amount        
        Base PTP Reward Amount = _rfBasePTP * myStakedLPAmount * stakingTime * coverageRatio * totalLPAmountOfAllLPPool / (lpCounts * totalLPAmountOfCurrentLPPool * (10 ** 18))            
        Boost PTP Reward Amount = _rfBoostPTP * sqrt(myStakedLPAmount * myVePTPBalance) * stakingTime / sumOfAllVePTPHolders(sqrt(stakedLPAmount * VePTPBalance)) * (10 ** 18))    
        (lpCount: 3 - USDT_LP, USDC_LP, DAI_LP)    
    - VePTP Reward Amount = _rfVePTP * myStakedPTPAmount * stakingTime / (10 ** 18)
    */

    event PTPBaseFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event PTPBoostFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event VePTPFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event VePTPMultipleFactorUpdated(address indexed user, uint256 oldFactor, uint256 newFactor);
    event PTPUpdated(address indexed user, address indexed oldPtp, address indexed newPtp);
    event VePTPUpdated(address indexed user, address indexed oldVePtp, address indexed newVePtp);
    event LPAdded(address indexed user, address indexed lptoken);
    event LPStaked(address indexed user, address indexed lptoken, uint256 amount);
    event LPUnStaked(address indexed user, address indexed lptoken, uint256 amount);
    event PTPStaked(address indexed user, address indexed ptptoken, uint256 amount);
    event PTPUnStaked(address indexed user, address indexed ptptoken, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PTPClaimed(address indexed user, uint256 amount);
    event VePTPClaimed(address indexed user, uint256 amount);

    constructor () {       
        _owner = msg.sender;        
        lpTokens.push(USDT_LP);
        lpTokens.push(DAI_LP);
        lpTokens.push(USDC_LP);
    }   

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    } 

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: same owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function isLpExist(address tk) private view returns (bool) {
        for (uint i = 0; i<lpTokens.length; i++) {
            if (lpTokens[i] == tk) return true;            
        }
        return false;
    }
    
    function addLPToken(address lpToken) public onlyOwner {
        require(lpToken != address(0), "addLPToken: zero address");
        require(Address.isContract(address(lpToken)), 'addLPToken: LP token must be a valid contract');
        require(isLpExist(lpToken) == false, "addLPToken: already exist");
        lpTokens.push(lpToken);
        emit LPAdded(msg.sender, lpToken);
    }

    function baseRewardFactorPTP() public view returns (uint256) {
        return _rfBasePTP;
    }

    function boostRewardFactorPTP() public view returns (uint256) {
        return _rfBoostPTP;
    }

    function rewardFactorVePTP() public view returns (uint256) {
        return _rfVePTP;
    }

    function rewardFactorVePTPMultiple() public view returns (uint256) {
        return _rfVePTPMultiple;
    }

    function updateBaseRewardFactorPTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateBaseRewardFactorPTP: reward factor can not be negative");
        uint256 oldFactor = _rfBasePTP;
        _rfBasePTP = newFactor;
        emit PTPBaseFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateBoostRewardFactorPTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateBoostRewardFactorPTP: reward factor can not be negative");
        uint256 oldFactor = _rfBoostPTP;
        _rfBoostPTP = newFactor;
        emit PTPBoostFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateRewardFactorVePTP(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateRewardFactorVePTP: reward factor can not be negative");
        uint256 oldFactor = _rfVePTP;
        _rfVePTP = newFactor;
        emit VePTPFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    function updateRewardFactorVePTPMultiple(uint256 newFactor) public onlyOwner {
        require (newFactor > 0, "updateRewardFactorVePTPMultiple: multiple reward factor can not be negative");
        uint256 oldFactor = _rfVePTPMultiple;
        _rfVePTPMultiple = newFactor;
        emit VePTPMultipleFactorUpdated(msg.sender, oldFactor, newFactor);
    }

    // LP Staking / Unstaking
    function isExistLPStakedUserInfo(uint256 pid, address user) private view returns (bool) {
        return _lpStakedUserInfo[pid][user].lpAmount > 0;
    }

    function _totalLPAmount() internal view returns (uint256) {
        uint256 totalLpAmounts;
        for (uint i=0;i<lpTokens.length;i++) {
            totalLpAmounts += Asset(lpTokens[i]).totalSupply() / (10**Asset(lpTokens[i]).decimals());
        }
        return totalLpAmounts;
    }

    function _coverageRatio (uint256 pid) private view returns (uint256) {
        if (Asset(lpTokens[pid]).liability() > 0) 
            return Asset(lpTokens[pid]).cash() * 100000 / Asset(lpTokens[pid]).liability();
        return 0;
    }

    function _calcIncreasedBasePTPReward (uint256 pid, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60 && Asset(lpTokens[pid]).totalSupply() > 0)
            return _rfBasePTP * userinfo.lpAmount * (block.timestamp - userinfo.lastTimestamp) * _coverageRatio(pid) * _totalLPAmount() / (lpTokens.length * (Asset(lpTokens[pid]).totalSupply() / (10**Asset(lpTokens[pid]).decimals())) * 10**18 * 100000);
        else return 0;
    }

    function _calcIncreasedBoostPTPReward (uint256 pid, address user, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60) {
            uint256 sum = _sumSqrtLPVe(pid);
            if (sum > 0) 
                return _rfBoostPTP * Math.sqrt(userinfo.lpAmount * VePTP.balanceOf(user)) * userinfo.lpAmount * (block.timestamp - userinfo.lastTimestamp) / (sum * 10**18);
            else return 0;
        } else return 0;
    }

    function _sumSqrtLPVe (uint256 pid) private view returns (uint256) {
        uint256 sum;
        for (uint256 i=0;i<VePTP.holders().length;i++) {
            sum += Math.sqrt(_lpStakedUserInfo[pid][VePTP.holders()[i]].lpAmount * VePTP.balanceOf(VePTP.holders()[i]));
        }
        return sum;
    }

    function sumSqrtLPVe (uint256 pid) public view returns (uint256) {
        uint256 sum;
        for (uint256 i=0;i<VePTP.holders().length;i++) {
            sum += Math.sqrt(_lpStakedUserInfo[pid][VePTP.holders()[i]].lpAmount * VePTP.balanceOf(VePTP.holders()[i]));
        }
        return sum;
    }    

    function _calcPTPReward (uint256 pid, address user, LPStakedUserInfo storage userinfo) private view returns (uint256) {
        uint256 baseIncreasedPTP = _calcIncreasedBasePTPReward(pid, userinfo);
        uint256 boostIncreasedPTP = _calcIncreasedBoostPTPReward(pid, user, userinfo);
        return userinfo.rewardAmount + baseIncreasedPTP + boostIncreasedPTP;
    }

    function _updateLPStakedUserInfoForStaking (uint256 pid, address user, uint256 amount) private {
        if (isExistLPStakedUserInfo(pid, user)) {
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
            _lpStakedUserInfo[pid][user].rewardAmount = _calcPTPReward(pid, user, userinfo);
            _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
            _lpStakedUserInfo[pid][user].lpAmount += amount / (10**Asset(lpTokens[pid]).decimals());
        } else {
            _lpStakedUserInfo[pid][user].rewardAmount = 0;
            _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
            _lpStakedUserInfo[pid][user].lpAmount = amount / (10**Asset(lpTokens[pid]).decimals());
        }
    }

    function _updateLPStakedUserInfoForUnStaking (uint256 pid, address user, uint256 amount) private {
        require(isExistLPStakedUserInfo(pid, user), "_updateLPStakedUserInfoForUnStaking: user didn't stake lp token");    
        _lpStakedUserInfo[pid][user].rewardAmount = 0;
        _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
        _lpStakedUserInfo[pid][user].lpAmount -= amount / (10**Asset(lpTokens[pid]).decimals());
    }

    /**
        Whenever staking LP, should update LPStakedUserInfo
        - rewardAmount += base reward + boosted reward
        - lastTimestamp = currentTimestamp
        - lpAmount += newLPAmount            
    */
    function stakingLP (uint256 pid, uint256 amount) public { 
        require(address(PTP) != address(0), "stakingLP: PTP does not set");        
        require(IERC20(lpTokens[pid]).balanceOf(msg.sender) >= amount, "stakingLP: insufficient amount");
        IERC20(lpTokens[pid]).transferFrom(msg.sender, address(this), amount);
        _updateLPStakedUserInfoForStaking(pid, msg.sender, amount);
        emit LPStaked(msg.sender, lpTokens[pid], amount);
    }    

    // whenever unstaking LP token, reward token should be transferred to msg sender
    function unStakingLP(uint256 pid, uint256 amount) public {
        require(address(PTP) != address(0), "unStakingLP: PTP does not set");
        require(isExistLPStakedUserInfo(pid, msg.sender), "unStakingLP: user didn't stake lp token");
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][msg.sender];
        require(userinfo.lpAmount >= amount / (10**Asset(lpTokens[pid]).decimals()), "unStakingLP: insufficient amount");
        IERC20(lpTokens[pid]).transfer(msg.sender, amount);
        uint256 rewardAmount = _calcPTPReward(pid, msg.sender, userinfo);        
        PTP.transferWithoutFee(msg.sender, rewardAmount);
        _updateLPStakedUserInfoForUnStaking(pid, msg.sender, amount);
        emit LPUnStaked(msg.sender, lpTokens[pid], amount);
    }

    // PTP Staking / Unstaking
    function isExistPTPStakedUserInfo(address user) private view returns (bool) {
        return _ptpStakedUserInfo[user].ptpAmount > 0;
    }

    function _calcIncreasedVePTPReward (PTPStakedUserInfo storage userinfo) private view returns (uint256) {
        if (block.timestamp - userinfo.lastTimestamp > 60)
            return _rfVePTP * userinfo.ptpAmount * (block.timestamp - userinfo.lastTimestamp) / (10**18);
        else return 0;
    }

    function _calcVePTPReward (address user, PTPStakedUserInfo storage userinfo) private view returns (uint256) {        
        uint256 rAmount = userinfo.rewardAmount + _calcIncreasedVePTPReward(userinfo);
        if (rAmount + VePTP.balanceOf(user) > userinfo.ptpAmount * _rfVePTPMultiple) {
            if (userinfo.ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                rAmount = userinfo.ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else return 0;
        }
        return rAmount;
    }

    function _updatePTPStakedUserInfoForStaking (address user, uint256 amount) private {
        if (isExistPTPStakedUserInfo(user)) {
            PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[user];
            _ptpStakedUserInfo[user].rewardAmount = _calcVePTPReward(user, userinfo);
            _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
            _ptpStakedUserInfo[user].ptpAmount += amount;
        } else {
            _ptpStakedUserInfo[user].rewardAmount = 0;
            _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
            _ptpStakedUserInfo[user].ptpAmount = amount;
        }
    }

    function _updatePTPStakedUserInfoForUnStaking (address user, uint256 amount) private {
        require(isExistPTPStakedUserInfo(user), "_updatePTPStakedUserInfoForUnStaking: user didn't stake PTP token");    
        _ptpStakedUserInfo[user].rewardAmount = 0;
        _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
        _ptpStakedUserInfo[user].ptpAmount -= amount;
    }

    function stakingPTP (uint256 amount) public { 
        require(address(VePTP) != address(0), "stakingPTP: VePTP does not set");        
        require(IERC20(PTP).balanceOf(msg.sender) >= amount, "stakingPTP: insufficient amount");
        PTP.transferFromWithoutFee(msg.sender, address(this), amount);
        _updatePTPStakedUserInfoForStaking(msg.sender, amount);
        emit PTPStaked(msg.sender, address(PTP), amount);
    }

    function unStakingPTP(uint256 amount) public {
        require(address(VePTP) != address(0), "unStakingPTP: PTP does not set");
        require(isExistPTPStakedUserInfo(msg.sender), "unStakingPTP: user didn't stake ptp token");
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[msg.sender];
        require(userinfo.ptpAmount >= amount, "unStakingPTP: insufficient amount");
        PTP.transferWithoutFee(msg.sender, amount);        
        VePTP.mint(msg.sender, _calcVePTPReward(msg.sender, userinfo));
        _updatePTPStakedUserInfoForUnStaking(msg.sender, amount);
        emit PTPUnStaked(msg.sender, address(PTP), amount);
    }

    // Claim PTP
    function _updateLPStakedUserInfoForClaim (uint256 pid, address user) private {        
        _lpStakedUserInfo[pid][user].rewardAmount = 0;
        _lpStakedUserInfo[pid][user].lastTimestamp = block.timestamp;
    }

    function _updateLPStakedUserInfoForMultiClaim (address user) private {    
        for (uint256 i=0;i<lpTokens.length;i++) {
            _updateLPStakedUserInfoForClaim(i, user);
        }            
    }

    function claimPTP(uint256 pid) external {
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][msg.sender];
        uint256 rewardAmount = _calcPTPReward(pid, msg.sender, userinfo);
        PTP.transferWithoutFee(msg.sender, rewardAmount);
        _updateLPStakedUserInfoForClaim(pid, msg.sender);
        emit PTPClaimed(msg.sender, rewardAmount);
    }

    function multiClaimPTP() external {
        _multiClaimPTP(msg.sender);
    }

    function _multiClaimPTP(address user) private {
        uint256 rewardAmount;
        for (uint256 i=0;i<lpTokens.length;i++) {
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[i][user];
            rewardAmount += _calcPTPReward(i, user, userinfo);                      
        }
        PTP.transferWithoutFee(user, rewardAmount);
        _updateLPStakedUserInfoForMultiClaim(user);
        emit PTPClaimed(user, rewardAmount);
    }

    // Claim vePTP
    function _updatePTPStakedUserInfoForClaim (address user) private {        
        _ptpStakedUserInfo[user].rewardAmount = 0;
        _ptpStakedUserInfo[user].lastTimestamp = block.timestamp;
    }

    function claimVePTP() external {
        _claimVePTP();
    }

    function _claimVePTP() private {
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[msg.sender];
        uint256 rewardAmount = _calcVePTPReward(msg.sender, userinfo);
        VePTP.mint(msg.sender, rewardAmount);
        _updatePTPStakedUserInfoForClaim(msg.sender);
        emit VePTPClaimed(msg.sender, rewardAmount);
    }

    function updatePTP(PTPV2 newPtp) public onlyOwner {
        require(address(newPtp) != address(0), "updatePTP: zero address");
        require(Address.isContract(address(newPtp)), "updatePTP: invalied contract");
        PTPV2 oldPtp = PTP;
        PTP = newPtp;
        emit PTPUpdated(msg.sender, address(oldPtp), address(newPtp));
    }

    function updateVePTP(VePTPV3 newVePtp) public onlyOwner {
        require(address(newVePtp) != address(0), "updateVePTP: zero address");
        require(Address.isContract(address(newVePtp)), "updateVePTP: invalied contract");
        VePTPV3 oldVePtp = VePTP;
        VePTP = newVePtp;
        emit VePTPUpdated(msg.sender, address(oldVePtp), address(newVePtp));
    }

    function lpStakedInfo(uint256 pid, address user) public view returns (uint256 lpAmount, uint256 rewardAmount) {
        LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
        rewardAmount = _calcPTPReward(pid, user, userinfo);
        lpAmount = userinfo.lpAmount * (10**Asset(lpTokens[pid]).decimals());
    }

    function multiLpStakedInfo(address user) 
        public 
        view 
        returns (
            uint256,
            uint256[] memory, 
            uint256[] memory
        ) 
    {        
        uint256 totalRewardAmount;
        uint256[] memory lpAmounts = new uint256[](lpTokens.length);
        uint256[] memory rewardAmounts = new uint256[](lpTokens.length);
        for (uint i = 0; i<lpTokens.length; i++) {   
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[i][user];
            uint256 rAmount = _calcPTPReward(i, user, userinfo);
            totalRewardAmount += rAmount;
            lpAmounts[i] = userinfo.lpAmount * (10**Asset(lpTokens[i]).decimals());
            rewardAmounts[i] = rAmount;
        }
        return (totalRewardAmount, lpAmounts, rewardAmounts);
    }

    function ptpStakedInfo(address user) public view returns (uint256 ptpAmount, uint256 rewardAmount) {
        PTPStakedUserInfo storage userinfo = _ptpStakedUserInfo[user];
        rewardAmount = _calcVePTPReward(user, userinfo);
        ptpAmount = userinfo.ptpAmount;
    }  

    function calcVePTPReward (address user, uint256 ptpAmount, uint256 stakingTimeSecond) public view returns (uint256) {                
        uint256 rAmount = _rfVePTP * ptpAmount * stakingTimeSecond / (10**18);
        if (rAmount + VePTP.balanceOf(user) > ptpAmount * _rfVePTPMultiple) {
            if(ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                rAmount = ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else return 0;
        }
        return rAmount;
    }

    function coverageRatio (uint256 pid) public view returns (uint256) {
        return _coverageRatio(pid);
    }

    function baseAPR (uint256 pid) public view returns (uint256) {     
        if (Asset(lpTokens[pid]).totalSupply() > 0)   
            return _rfBasePTP * (365 * 24 * 60 * 60) * _coverageRatio(pid) * _totalLPAmount() * 100 * 10**18 / (lpTokens.length * (Asset(lpTokens[pid]).totalSupply() / (10**Asset(lpTokens[pid]).decimals())) * 10**18 * 100000);
        else return 0;
    }

    function boostedAPR (uint256 pid, address user) public view returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid);
        if (isExistLPStakedUserInfo(pid, user) && sum > 0) {   
            LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
            return _rfBoostPTP * Math.sqrt(userinfo.lpAmount * VePTP.balanceOf(user)) * (365 * 24 * 60 * 60) * 100 * 10**18 / (sum * 10**18);      
        }
        return 0;
    }

    function estimatedBoostedAPRFromVePTP (uint256 pid, address user, uint256 lpAmount, uint256 vePTPAmount) public view returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid) - Math.sqrt(_lpStakedUserInfo[pid][user].lpAmount * VePTP.balanceOf(user)) + Math.sqrt(lpAmount * vePTPAmount);
        if (sum > 0) {            
            return _rfBoostPTP * Math.sqrt(lpAmount * vePTPAmount) * (365 * 24 * 60 * 60) * 100 * 10**18 / (sum * 10**18);                       
        }
        return 0;
    }

    function estimatedBoostedAPRFromPTP (uint256 pid, address user, uint256 lpAmount, uint256 ptpAmount, uint256 stakingTimeSecond) public view returns (uint256) {        
        uint256 vePTPAmount = _rfVePTP * ptpAmount * stakingTimeSecond / (10**18);
        if (vePTPAmount + VePTP.balanceOf(user) > ptpAmount * _rfVePTPMultiple) {
            if(ptpAmount * _rfVePTPMultiple > VePTP.balanceOf(user)) {
                vePTPAmount = ptpAmount * _rfVePTPMultiple - VePTP.balanceOf(user);
            } else vePTPAmount = 0;
        }

        uint256 sum = _sumSqrtLPVe(pid) - Math.sqrt(_lpStakedUserInfo[pid][user].lpAmount * VePTP.balanceOf(user)) + Math.sqrt(lpAmount * vePTPAmount);
        if (sum > 0) {            
            return _rfBoostPTP * Math.sqrt(lpAmount * vePTPAmount) * (365 * 24 * 60 * 60) * 100 * 10**18 / (sum * 10**18);                       
        } 
        return 0;
    }

    function medianBoostedAPR (uint256 pid) public view returns (uint256) {
        uint256 sum = _sumSqrtLPVe(pid);
        uint256 sumAPR;
        uint256 holdersCount = VePTP.holders().length;
        uint256 boostingUserCount;
        for (uint256 i=0;i<holdersCount;i++) {
            address user = VePTP.holders()[i];
            if (isExistLPStakedUserInfo(pid, user) && sum > 0) {            
                LPStakedUserInfo storage userinfo = _lpStakedUserInfo[pid][user];
                sumAPR += _rfBoostPTP * Math.sqrt(userinfo.lpAmount * VePTP.balanceOf(user)) * (365 * 24 * 60 * 60) * 100 * 10**18 / (sum * 10**18); 
                boostingUserCount++;          
            }
        }
        
        if (boostingUserCount > 0) {
            return sumAPR / boostingUserCount;
        }

        return 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './libraries/SafeMath.sol';

contract PTPV2 is ERC20 {     
    using SafeMath for uint256;   
    address private _basePool; // should be base pool (Pool)
    address private _minter; // should be staking pool (MasterPlatypusV3)
    address private _owner;

    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnFee = 1; 
    uint256 private totalSupplyAmount = 300_000_000e18;
    
    event BurnFeeUpdated(address indexed user, uint256 oldBurnFee, uint256 newBurnFee);
    event MinterChanged(address indexed minter, address indexed newMinter);
    event BasePoolChanged(address indexed basePool, address indexed newBasePool);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() ERC20("Platypus", "PTP") {
        _owner = msg.sender;
        uint256 half = totalSupplyAmount.div(2);
        uint256 anotherHalf = totalSupplyAmount.sub(half);

        _mint(_owner, half); // for market place
        _mint(address(this), anotherHalf); // for reward
    }
    
    function owner() public view returns (address) {
        return _owner;
    }

    function minter() public view returns (address) {
        return _minter;
    }

    function basePool() public view returns (address) {
        return _basePool;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMinter() {
        require(_minter == msg.sender, "Minable: caller is not the minter");
        _;
    }

    modifier onlyBasePool() {
        require(_basePool == msg.sender, "Minable: caller is not the base pool");
        _;
    }

    modifier onlyOwnerOrMinter() {
        require(_minter == msg.sender || _owner == msg.sender, "Minable: caller is not the owner or minter");
        _;
    }

    modifier onlybasePoolOrMinter() {
        require(_minter == msg.sender || _basePool == msg.sender, "Minable: caller is not the basePool or minter");
        _;
    }

    modifier onlyOwnerOrMinterOrBasePool() {
        require(_minter == msg.sender || _owner == msg.sender || _basePool == msg.sender, "Minable: caller is not the owner, minter or basePool");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: same owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setBasePool(address newpool) external onlyOwner {    
        require(newpool != address(0), "basePool: new pool is the zero address");
        require(newpool != _basePool, "basePool: same basePool");
        emit BasePoolChanged(_basePool, newpool);
        _basePool = newpool;
        super._approve(address(this), _basePool, type(uint256).max);
    }

    function setMinter(address newMinter) external onlyOwner {    
        require(newMinter != address(0), "Minter: new minter is the zero address");
        require(newMinter != _minter, "Minter: same minter");
        address oldMinter = _minter;           
        _minter = newMinter;
        emit MinterChanged(oldMinter, newMinter);
    }

    function mint(address dst, uint256 amount) external onlyOwnerOrMinter {
        _mint(dst, amount);
    }

    function transferWithoutFee(address to, uint256 amount) public onlyMinter {
        require(to != address(this), "transferWithoutFee: return back");
        require(to != address(0), "transferWithoutFee: zero address");
        super._transfer(address(this), to, amount);
    }
    
    function transferFromWithoutFee(address from, address to, uint256 amount) public onlybasePoolOrMinter {
        require(to != address(this), "transferFromWithoutFee: return back");
        require(to != address(0), "transferFromWithoutFee: zero address");
        address spender = msg.sender;
        super._spendAllowance(from, spender, amount);
        super._transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 burnFeeAmount = amount.mul(burnFee).div(100);        
        uint256 realAmount = amount.sub(burnFeeAmount);
        super._transfer(from, to, realAmount);
        super._transfer(from, deadWallet, burnFeeAmount);
    }

    function updateBurnFee(uint256 newBurnFee) public onlyOwner {
        require(burnFee != newBurnFee, "updateBurnFee: same burn fee");
        uint256 oldBurnFee = burnFee;
        burnFee = newBurnFee;
        emit BurnFeeUpdated(msg.sender, oldBurnFee, newBurnFee);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

interface IAsset {
    function maxSupply() external view returns (uint256);

    function aggregateAccount() external view returns (address);

    function underlyingToken() external view returns (address);

    function decimals() external view returns (uint8);

    function underlyingTokenBalance() external view returns (uint256);

    function cash() external view returns (uint256);

    function liability() external view returns (uint256);
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

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './libraries/SafeMath.sol';

contract VePTPV3 {     
    using SafeMath for uint256;   
    address private _minter; // should be staking pool (MasterPlatypusV2)
    address private _owner;    
    
    address[] private _holders;
    
    event MinterChanged(address indexed minter, address indexed newMinter);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);

    string private _name = "Platypus vePTP";
    string private _symbol = "vePTP";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    constructor() {
        _owner = msg.sender;        
    }
    
    function owner() public view returns (address) {
        return _owner;
    }

    function minter() public view returns (address) {
        return _minter;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMinter() {
        require(_minter == msg.sender, "Minable: caller is not the minter");
        _;
    }

    modifier onlyOwnerOrMinter() {
        require(_minter == msg.sender || _owner == msg.sender, "Minable: caller is not the owner or minter");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _owner, "Ownable: same owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setMinter(address newMinter) external onlyOwner {    
        require(newMinter != address(0), "Minter: new minter is the zero address");
        require(newMinter != _minter, "Minter: same minter");
        address oldMinter = _minter;           
        _minter = newMinter;
        emit MinterChanged(oldMinter, newMinter);
    }

    function mint(address dst, uint256 amount) external onlyOwnerOrMinter {
        _mint(dst, amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        if (!isHolderExist(account)) _holders.push(account);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function isHolderExist(address user) private view returns (bool) {
        if(_balances[user] > 0) return true;
        return false;
    }

    function holders() public view returns (address[] memory) {
        return _holders;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

// a library for performing various math operations

library Math {
    uint256 public constant WAD = 10**18;

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }
}

// SPDX-License-Identifier: MIT
/* SafeMath.sol */

pragma solidity 0.8.9;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}