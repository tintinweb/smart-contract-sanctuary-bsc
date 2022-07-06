/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface AntiSnipe {
    function checkUser(address from, address to, uint256 amt) external returns (bool);
    function setLaunch(address _initialLpPair, uint32 _liqAddBlock, uint64 _liqAddStamp, uint8 dec) external;
    function setLpPair(address pair, bool enabled) external;
    function setProtections(bool _as, bool _ab) external;
    function removeSniper(address account) external;
    function removeBlacklisted(address account) external;
    function isBlacklisted(address account) external view returns (bool);
    function withdraw(uint256 amount) external;
    function _addLiquidity(address receiver) external returns (bool);
    function withdrawAll() external returns (uint256, uint256);

    function fullReset() external;
}

contract ReferralHolder {
    address private _contract;
    IERC20 IERC20_contract;

    constructor(address __contract) {
        _contract = __contract;
        IERC20_contract = IERC20(__contract);
    }

    modifier onlyContract() {
        require(_contract == msg.sender, "Caller =/= contract.");
        _;
    }

    function withdraw(uint256 amount, bool allOfIt, address receiver) external onlyContract {
        if (allOfIt) {
            amount = IERC20_contract.balanceOf(address(this));
        }
        IERC20_contract.transfer(receiver, amount);
    }

    receive() payable external {
        revert("Do not send AVAX here.");
    }
}

contract eXpanz is IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _liquidityHolders;
    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;
   
    uint256 constant private startingSupply = 100_000;
    string constant private _name = "eXpanz";
    string constant private _symbol = "XPANZ";
    uint8 constant private _decimals = 5;

    uint256 private _tTotal = startingSupply * 10**_decimals;
    uint256 constant private MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _aSupply = _rTotal / _tTotal;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
        uint16 piTaxBonus;
        uint16 referrerBonus;
        uint16 circuitBreakerBonus;
    }

    struct Ratios {
        uint16 liquidity;
        uint16 treasury;
        uint16 xtf;
        uint16 burn;
        uint16 total;
    }

    Fees public _taxRates = Fees({
        buyFee: 1400,
        sellFee: 1400,
        transferFee: 1000,
        piTaxBonus: 400,
        referrerBonus: 500,
        circuitBreakerBonus: 1100
    });

    Ratios public _ratios = Ratios({
        liquidity: 1,
        treasury: 1,
        xtf: 1,
        burn: 1,
        total: 3
    });

    uint256 constant public maxBuyTaxes = 1500;
    uint256 constant public maxSellTaxes = 1500;
    uint256 constant public maxTransferTaxes = 1500;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;
    IV2Pair v2Pair_lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    // address constant public USDC.E = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;
    // IERC20 constant public IERC20_USDC.E = IERC20(USDC.E);
    address public USDCE = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;
    IERC20 public IERC20_USDCE = IERC20(USDCE);

    struct TaxWallets {
        address xtf;
        address treasury;
        address liquidity;
    }

    TaxWallets public _taxWallets = TaxWallets({
        xtf: 0x60808eaaED5AfA68DC2d7B1b8B3efF84c846754d,
        treasury: 0x60808eaaED5AfA68DC2d7B1b8B3efF84c846754d,
        liquidity: 0x60808eaaED5AfA68DC2d7B1b8B3efF84c846754d
    });
    
    bool inSwap;
    bool public contractSwapEnabled = false;
    uint256 public swapThreshold;
    uint256 public swapAmount;
    bool public piContractSwapsEnabled;
    uint256 public piSwapPercent;
    uint256 public autoLiquidityLastAdded;
    uint256 public autoLiquidityTimer = 24 hours;
    bool liqLock;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    AntiSnipe antiSnipe;

    bool public autoRebaseEnabled = false;
    uint256 public autoRebaseInitializationStamp;
    uint256 public autoRebaseLastTriggered;
    uint256 public rebaseTimeInSeconds = 15;
    uint256 public rebaseRate = 835;
    uint8 constant private _rateDecimals = 9;
    uint256 public maxRebasesPerTX = 1000;
    bool public manualRebaseIsPublic = true;

    bool public piEnabled;

    bool public cbFeatureEnabled = false;
    uint256 public durationTradeBlock = 1 hours;
    uint256 public lastTradeBlockStamp;
    uint256 public currentPrice;
    uint256 public lastTradeBlockPrice;
    bool public circuitBreakerEnabled = false;
    uint256 public durationCircuitBreaker = 1 hours;
    uint256 public circuitBreakerStartStamp;
    uint256 public cbThresholdPercent = 1;
    uint256 public cbThresholdDivisor = 100;

    ReferralHolder refHolder;
    mapping (address => address) private referMap;
    bool public referralBonusEnabled = true;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountCurrency, uint256 amountTokens);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }
    
    constructor () payable {
        _tOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), _owner);

        // Set the owner.
        _owner = msg.sender;

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 43114) {
            dexRouter = IRouter02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        } else if (block.chainid == 250) {
            dexRouter = IRouter02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
        } else {
            revert();
        }

        if (block.chainid == 97) {
            USDCE = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
            IERC20_USDCE = IERC20(USDCE);
        }

        address avaxPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPair = IFactoryV2(dexRouter.factory()).createPair(USDCE, address(this));
        lpPairs[avaxPair] = true;
        lpPairs[lpPair] = true;
        v2Pair_lpPair = IV2Pair(lpPair);

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);
        IERC20_USDCE.approve(address(dexRouter), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _liquidityHolders[_owner] = true;

        refHolder = new ReferralHolder(address(this));
    }

    receive() external payable {}

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
        
        if (balanceOf(_owner) > 0) {
            finalizeTransfer(_owner, newOwner, balanceOf(_owner), false, false, true);
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        
    }

    function renounceOwnership() external onlyOwner {
        setExcludedFromFees(_owner, false);
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
//===============================================================================================================
//===============================================================================================================
//===============================================================================================================

    function totalSupply() external view override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external view override returns (uint8) { if (_tTotal == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account] / _aSupply;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() external onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (!enabled) {
            lpPairs[pair] = false;
            antiSnipe.setLpPair(pair, false);
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "3 Day cooldown.!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
            antiSnipe.setLpPair(pair, true);
        }
    }

    function setInitializer(address initializer) external onlyOwner {
        require(!_hasLiqBeenAdded);
        require(initializer != address(this), "Can't be self.");
        antiSnipe = AntiSnipe(initializer);
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromProtection(address account) external view returns (bool) {
        return _isExcludedFromProtection[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function setExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function setExcludedFromProtection(address account, bool enabled) external onlyOwner {
        _isExcludedFromProtection[account] = enabled;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function removeBlacklisted(address account) external onlyOwner {
        // To remove from the pre-built blacklist ONLY. Cannot add to blacklist.
        antiSnipe.removeBlacklisted(account);
    }

    function isBlacklisted(address account) external view returns (bool) {
        return antiSnipe.isBlacklisted(account);
    }

    function removeSniper(address account) external onlyOwner {
        antiSnipe.removeSniper(account);
    }

    function setProtectionSettings(bool _antiSnipe, bool _antiBlock) external onlyOwner {
        antiSnipe.setProtections(_antiSnipe, _antiBlock);
    }

    function setWallets(address treasury, address xtf, address liquidity) external onlyOwner {
        _taxWallets.treasury = treasury;
        _taxWallets.xtf = xtf;
        _taxWallets.liquidity = liquidity;
    }

    function setTaxes(uint16 buyFee, uint16 sellFee, uint16 transferFee, uint16 piTaxBonus, uint16 referrerBonus, uint16 circuitBreakerBonus) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.piTaxBonus = piTaxBonus;
        _taxRates.referrerBonus = referrerBonus;
        _taxRates.transferFee = transferFee;
        _taxRates.circuitBreakerBonus = circuitBreakerBonus;
    }
    
    function setRatios(uint16 liquidity, uint16 treasury, uint16 xtf, uint16 burn) external onlyOwner {
        _ratios.liquidity = liquidity;
        _ratios.treasury = treasury;
        _ratios.xtf = xtf;
        _ratios.burn = burn;
        _ratios.total = liquidity + treasury + xtf;
        uint256 total = _taxRates.buyFee + _taxRates.sellFee;
        require(_ratios.total + _ratios.burn <= total, "Cannot exceed sum of buy and sell fees.");
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        require(swapThreshold <= swapAmount, "Threshold cannot be above amount.");
    }

    function setPriceImpactSwapAmount(uint256 priceImpactSwapPercent) external onlyOwner {
        require(priceImpactSwapPercent <= 200, "Cannot set above 2%.");
        piSwapPercent = priceImpactSwapPercent;
    }

    function setContractSwapEnabled(bool swapEnabled, bool priceImpactSwapEnabled) external onlyOwner {
        contractSwapEnabled = swapEnabled;
        piContractSwapsEnabled = priceImpactSwapEnabled;
        emit ContractSwapEnabledUpdated(swapEnabled);
    }

    function setAutoLiquidityTimer(uint256 timeInSeconds) external onlyOwner {
        autoLiquidityTimer = timeInSeconds;
    }

    function setAutoRebaseEnabled(bool enabled) external onlyOwner {
        if (enabled) {
            autoRebaseLastTriggered = block.timestamp;
            if (autoRebaseInitializationStamp == 0) {
                autoRebaseInitializationStamp = block.timestamp;
            }
        }
        autoRebaseEnabled = enabled;
    }

    function setPriceImpactTaxEnabled(bool enabled) external onlyOwner {
        piEnabled = enabled;
    }

    function setReferralBonusEnabled(bool enabled) external onlyOwner {
        referralBonusEnabled = enabled;
    }

    function setCiruitBreakerEnabled(bool enabled) external onlyOwner {
        cbFeatureEnabled = enabled;
        if (enabled) {
            lastTradeBlockStamp = block.timestamp;
            lastTradeBlockPrice = IERC20_USDCE.balanceOf(lpPair) / balanceOf(lpPair);
        }
    }

    function setMaxRebasesPerTX(uint256 amount) external onlyOwner {
        require(amount <= 1000, "Cannot exceed 1000 rebases per tx.");
        maxRebasesPerTX = amount;
    }

    function setCircuitBreakerSettings(uint256 tradeblockDuration, uint256 cbDuration) external onlyOwner {
        durationTradeBlock = tradeblockDuration;
        durationCircuitBreaker = cbDuration;
    }

    function setCircuitBreakerThresholds(uint256 percent, uint256 divisor) external onlyOwner {
        cbThresholdPercent = percent;
        cbThresholdDivisor = divisor;
    }

    function getReferrer(address account) external view returns (address referrer) {
        return referMap[account];
    }

    function _hasLimits(address from, address to) internal view returns (bool) {
        return from != _owner
            && to != _owner
            && tx.origin != _owner
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this)
            && from != address(antiSnipe);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (lpPairs[from]) {
            buy = true;
        } else if (lpPairs[to]) {
            sell = true;
        } else {
            other = true;
        }
        if (_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }

            if (cbFeatureEnabled) {
                if (circuitBreakerEnabled) {
                    if (block.timestamp > circuitBreakerStartStamp + durationCircuitBreaker) {
                        circuitBreakerEnabled = false;
                        lastTradeBlockStamp = block.timestamp;
                        lastTradeBlockPrice = IERC20_USDCE.balanceOf(lpPair) / balanceOf(lpPair);
                    }
                }

                if (!circuitBreakerEnabled && block.timestamp > lastTradeBlockStamp + durationTradeBlock) {
                    lastTradeBlockStamp = block.timestamp;
                    lastTradeBlockPrice = IERC20_USDCE.balanceOf(lpPair) / balanceOf(lpPair);
                }
            }

            if (buy) {
                if (referralBonusEnabled && referMap[to] != address(0) && balanceOf(address(refHolder)) != 0) {
                    uint256 referTokens = (amount * _taxRates.referrerBonus) / masterTaxDivisor;
                    if (balanceOf(address(refHolder)) > referTokens) {
                        basicTransfer(address(refHolder), referMap[to], referTokens);
                    } else {
                        basicTransfer(address(refHolder), referMap[to], balanceOf(address(refHolder)));
                    }
                }
            } else {
                if (!liqLock && !inSwap && _ratios.liquidity > 0 && autoLiquidityLastAdded + autoLiquidityTimer < block.timestamp) {
                    liqLock = true;
                    try antiSnipe._addLiquidity(_taxWallets.liquidity) returns (bool added) {
                        if (added) {
                            autoLiquidityLastAdded = block.timestamp;
                        }
                    } catch {}
                    liqLock = false;
                }
            }
        }


        if (sell) {
            if (!inSwap && !liqLock && from != address(antiSnipe)) {
                runRebase(maxRebasesPerTX);

                if (contractSwapEnabled) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapThreshold) {
                        uint256 swapAmt = swapAmount;
                        if (piContractSwapsEnabled) { swapAmt = (balanceOf(lpPair) * piSwapPercent) / masterTaxDivisor; }
                        if (contractTokenBalance >= swapAmt) { contractTokenBalance = swapAmt; }
                        contractSwap(contractTokenBalance);
                    }
                }
            }
        } 
        return finalizeTransfer(from, to, amount, buy, sell, other);
    }

    function runRebase(uint256 _maxRebasesPerTX) internal {
        if (autoRebaseEnabled
           && block.timestamp >= autoRebaseLastTriggered + rebaseTimeInSeconds
        ) {
            uint256 deltaTimeFromInitialization = block.timestamp - autoRebaseInitializationStamp;
            uint256 deltaTime = block.timestamp - autoRebaseLastTriggered;
            uint256 rebaseAmounts = deltaTime / (rebaseTimeInSeconds);
            if (rebaseAmounts > _maxRebasesPerTX) {
                rebaseAmounts = _maxRebasesPerTX;
            }
            uint256 epoch = rebaseAmounts * rebaseTimeInSeconds;

            if (deltaTimeFromInitialization > 365 days) {
                if (rebaseRate > 30) {
                    rebaseRate -= 30;
                    autoRebaseInitializationStamp = block.timestamp;
                }
            }

            uint256 tTotal = _tTotal;
            uint256 _rDec = _rateDecimals;
            uint256 _rRate = rebaseRate;
            __rebaseTimes += rebaseAmounts;
            for (uint256 i = 0; i < rebaseAmounts; i++) {
                tTotal = (tTotal * ((10**_rDec) + _rRate)) / (10**_rDec);
            }
            if (tTotal > 1_000_000_000 * 10**_decimals) {
                tTotal = 1_000_000_000 * 10**_decimals;
                autoRebaseEnabled = false;
            }
            _tTotal = tTotal;
            _aSupply = _rTotal / tTotal;
            autoRebaseLastTriggered += rebaseAmounts * rebaseTimeInSeconds;

            v2Pair_lpPair.sync();

            emit LogRebase(epoch, tTotal);
        } else {
            return;
        }
    }

    function basicTransfer(address from, address to, uint256 amount) internal {
        uint256 amountReceived = amount * _aSupply;
        _tOwned[from] -= amountReceived;
        _tOwned[to] += amountReceived;
        emit Transfer(from, to, amount);
    }

    function contractSwap(uint256 contractTokenBalance) internal lockTheSwap {
        Ratios memory ratios = _ratios;
        if (ratios.total == 0) {
            return;
        }

        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        if (_allowances[address(antiSnipe)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(antiSnipe)][address(dexRouter)] = type(uint256).max;
        }

        if (IERC20_USDCE.allowance(address(this), address(dexRouter)) != type(uint256).max) {
            IERC20_USDCE.approve(address(dexRouter), type(uint256).max);
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDCE;

        uint256 initial = IERC20_USDCE.balanceOf(address(antiSnipe));

        dexRouter.swapExactTokensForTokens(
            contractTokenBalance,
            0,
            path,
            address(antiSnipe),
            block.timestamp
        );

        uint256 amtBalance = IERC20_USDCE.balanceOf(address(antiSnipe)) - initial;
        uint256 liquidityBalance = (amtBalance * ratios.liquidity) / ratios.total;
        antiSnipe.withdraw(amtBalance - liquidityBalance);

        amtBalance = IERC20_USDCE.balanceOf(address(this));
        ratios.total -= ratios.liquidity;
        uint256 xtfBalance = (amtBalance * ratios.xtf) / ratios.total;
        uint256 treasuryBalance = amtBalance - xtfBalance;
        if (ratios.xtf > 0) {
            IERC20_USDCE.transfer(_taxWallets.xtf, xtfBalance);
        }
        if (ratios.treasury > 0) {
            IERC20_USDCE.transfer(_taxWallets.treasury, treasuryBalance);
        }
    }

    function _checkLiquidityAdd(address from, address to) internal {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            if (address(antiSnipe) == address(0)){
                antiSnipe = AntiSnipe(address(this));
            }
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        if (address(antiSnipe) == address(0)){
            antiSnipe = AntiSnipe(address(this));
        }
        try antiSnipe.setLaunch(lpPair, uint32(block.number), uint64(block.timestamp), _decimals) {} catch {}
        _approve(address(antiSnipe), address(dexRouter), type(uint256).max);
        _isExcludedFromFees[address(antiSnipe)] = true;
        tradingEnabled = true;
        piEnabled = true;
        swapThreshold = (balanceOf(lpPair) * 10) / 10000;
        swapAmount = (balanceOf(lpPair) * 30) / 10000;
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            finalizeTransfer(msg.sender, accounts[i], amounts[i]*10**_decimals, false, false, true);
        }
    }

    function finalizeTransfer(address from, address to, uint256 amount, bool buy, bool sell, bool other) internal returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to) && !_isExcludedFromProtection[from] && !_isExcludedFromProtection[to] && !other) {
                revert("Pre-liquidity transfer protection.");
            }
        }

        bool takeFee = true;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        uint256 aSupply = _aSupply;
        amount *= aSupply;
        _tOwned[from] -= amount;
        uint256 amountReceived = (takeFee) ? takeTaxes(from, buy, sell, amount, aSupply) : amount;
        _tOwned[to] += amountReceived;

        emit Transfer(from, to, amountReceived / aSupply);

        if (_hasLimits(from, to)) {
            bool checked;
            try antiSnipe.checkUser(from, to, amount) returns (bool check) {
                checked = check;
            } catch {
                revert();
            }

            if(!checked) {
                revert();
            }

            if (cbFeatureEnabled) {
                if (!circuitBreakerEnabled) {
                    uint256 price = IERC20_USDCE.balanceOf(lpPair) / balanceOf(lpPair);
                    uint256 checkPrice = (lastTradeBlockPrice * cbThresholdPercent) / cbThresholdDivisor;
                    __price = price;
                    __checkedPrice = lastTradeBlockPrice - checkPrice;
                    if (price < lastTradeBlockPrice - checkPrice) {
                        circuitBreakerEnabled = true;
                        circuitBreakerStartStamp = block.timestamp;
                    }
                }
            }
        }

        return true;
    }

    uint256 public _currentFee;
    uint256 public _bonus;

    function takeTaxes(address from, bool buy, bool sell, uint256 amount, uint256 aSupply) internal returns (uint256) {
        uint256 currentFee;
        if (buy) {
            currentFee = _taxRates.buyFee;
        } else if (sell) {
            currentFee = _taxRates.sellFee;
            if (piEnabled) {
                uint256 balance = balanceOf(lpPair);
                uint256 trueAmount = amount / aSupply;
                if (trueAmount > balance / 100) {
                    _bonus = (((trueAmount * (masterTaxDivisor)) / balance) * _taxRates.piTaxBonus) / 100;
                    currentFee += ((trueAmount * (masterTaxDivisor)) / balance * _taxRates.piTaxBonus) / 100;
                }
            }
            if (circuitBreakerEnabled) {
                currentFee += _taxRates.circuitBreakerBonus;
            }
            _currentFee = currentFee;
            if (currentFee > 2800) {
                currentFee = 2800;
            }
        } else {
            currentFee = _taxRates.transferFee;
        }

        if (currentFee == 0) {
            return amount;
        }

        uint256 burnRatio = _ratios.burn;
        uint256 feeAmount = (amount / masterTaxDivisor) * currentFee;
        uint256 burnAmount = (feeAmount * burnRatio) / (burnRatio + _ratios.total);
        uint256 swapAmt = feeAmount - burnAmount;

        if (burnRatio > 0) {
            _tOwned[DEAD] += burnAmount;
            emit Transfer(from, DEAD, burnAmount / aSupply);
        }

        _tOwned[address(this)] += swapAmt;
        emit Transfer(from, address(this), swapAmt / aSupply);

        return amount - feeAmount;
    }

    function manualAddLiquidity() external onlyOwner {
        antiSnipe._addLiquidity(_taxWallets.liquidity);
        autoLiquidityLastAdded = block.timestamp;
    }

    function setManualRebaseToPublic(bool enabled) external onlyOwner {
        manualRebaseIsPublic = enabled;
    }

    function manualRebase(uint256 maxTimesToRebase) external {
        if (!manualRebaseIsPublic) {
            require(msg.sender == _owner);
        }
        runRebase(maxTimesToRebase);
    }

    function setReferrer(address referrer) external {
        referMap[msg.sender] = referrer;
    }

    function withdrawReferralTokens(uint256 amount, bool allOfIt) external onlyOwner {
        refHolder.withdraw(amount, allOfIt, msg.sender);
    }

    function depositReferralTokens(uint256 amount) external onlyOwner {
        amount *= 10**_decimals;
        basicTransfer(msg.sender, address(refHolder), amount);
    }

    function sweepAvax(address receiver) external onlyOwner {
        bool success;
        (success,) = payable(receiver).call{value: address(this).balance, gas: 35000}("");
        require(success, "Send failed.");
    }

    function sweepForeignTokens(address _token, address receiver) external onlyOwner {
        IERC20(_token).transfer(receiver, IERC20(_token).balanceOf(address(this)));
    }

// ==================================================================================================================================================
// ==================================================================================================================================================
// ==================================================================================================================================================
//                                                              DEV SHIT
//                                                    REMOVE BEFORE MAINNET DEPLOYMENT

    function __timeToRebase(uint256 times) external onlyOwner {
        autoRebaseEnabled = true;
        autoRebaseLastTriggered = block.timestamp - (times * (rebaseTimeInSeconds * 1 minutes));
    }

    function __setAutoRebaseInit(uint256 epoch) external onlyOwner {
        autoRebaseInitializationStamp = epoch;
    }

    function _loadReferralTokens(uint256 amount) internal onlyOwner {
        basicTransfer(address(this), address(refHolder), amount);
    }

    uint256 public __rebaseTimes;

    function __viewAmtRebases() external view onlyOwner returns (uint256) {
        uint256 deltaTimeFromInitialization = block.timestamp - autoRebaseInitializationStamp;
        uint256 deltaTime = block.timestamp - autoRebaseLastTriggered;
        uint256 rebaseAmounts = deltaTime / (rebaseTimeInSeconds);
        return rebaseAmounts;
    }

    function __setReferrer(address referrer, address referred) external {
        referMap[referred] = referrer;
    }

    uint256 public __price;
    uint256 public __checkedPrice;
}