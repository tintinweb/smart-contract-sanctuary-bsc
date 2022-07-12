/**
 *Submitted for verification at BscScan.com on 2022-07-11
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
    function transfer(address sender) external;
    function withdraw() external;
    function isBlacklisted(address account) external view returns (bool);
    function setBlacklistEnabled(address account, bool enabled) external;
    function setBlacklistEnabledMultiple(address[] memory accounts, bool enabled) external;
}

contract BalticFinancialToken is IERC20 {
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
   
    uint256 constant private startingSupply = 4_000_000_000;

    string constant private _name = "Baltic Miners Financial Token";
    string constant private _symbol = "BMFT";
    uint8 constant private _decimals = 5;

    uint256 private _tTotal = startingSupply * 10**_decimals;
    uint256 constant private MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _aSupply = _rTotal / _tTotal;

    struct Fees {
        uint16 liquidity;
        uint16 insurance;
        uint16 treasury;
        uint16 firePit;
        uint16 total;
    }

    Fees public _buyTaxes = Fees({
        liquidity: 1000,
        insurance: 250,
        treasury: 250,
        firePit: 100,
        total: 1600
    });

    Fees public _sellTaxes = Fees({
        liquidity: 1400,
        insurance: 250,
        treasury: 250,
        firePit: 100,
        total: 2000
    });

    Fees public _transferTaxes = Fees({
        liquidity: 0,
        insurance: 0,
        treasury: 0,
        firePit: 0,
        total: 0
    });

    uint256 constant public maxBuyTaxes = 2000;
    uint256 constant public maxSellTaxes = 2000;
    uint256 constant public maxTransferTaxes = 2000;
    uint256 constant public maxRoundtripTax = 4000;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;
    IV2Pair v2Pair_lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant public USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    IERC20 constant public IERC20_USDT = IERC20(USDT);

    struct TaxWallets {
        address payable insurance;
        address payable treasury;
        address payable firePit;
        address liquidity;
    }

    TaxWallets public _taxWallets = TaxWallets({
        insurance: payable(0xe29A4b2dc4c32C24e9497E0C0839CA1Dd613834f),
        treasury: payable(0x8Dbf6F465E67280850d7c4e936ac97426F83f985),
        firePit: payable(0xF24d31eF4F2E26EfADb9E889B2DD20b30aD5f9E2),
        liquidity: 0x917152Ad6Bd8527d84ad5C7289e4d2A63E04A792
    });
    
    bool inSwap;
    bool public contractSwapEnabled = false;
    uint256 public swapThreshold;
    uint256 public swapAmount;
    bool public piContractSwapsEnabled;
    uint256 public piSwapPercent;
    
    uint256 private _maxTxAmount = 10000;
    uint256 private _maxWalletSize = 10000;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    AntiSnipe antiSnipe;

    bool public autoRebaseEnabled = false;
    uint256 public autoRebaseInitializationStamp;
    uint256 public autoRebaseLastTriggered;
    uint256 public rebaseTimeInMinutes = 480;
    uint256 public rebaseRate = 11830;
    uint8 constant private _rateDecimals = 7;

    struct UserLimits {
        uint256 totalBought;
        uint256 lastSellStamp;
        uint256 sellLimitPerTime;
        uint256 soldDuringLimit;
    }

    mapping (address => bool) limitedWallet;
    mapping (address => UserLimits) userLimits;
    uint256 public limitTime = 4 weeks;
    uint256 public limitPercent = 2000;

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

        lpPair = IFactoryV2(dexRouter.factory()).createPair(USDT, address(this));
        address bnbPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;
        lpPairs[bnbPair] = true;
        v2Pair_lpPair = IV2Pair(lpPair);

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);
        IERC20_USDT.approve(address(dexRouter), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _liquidityHolders[_owner] = true;
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
        
        if(balanceOf(_owner) > 0) {
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

    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
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

    function setNewRouter(address newRouter) external onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        v2Pair_lpPair = IV2Pair(lpPair);
        _approve(address(this), address(dexRouter), type(uint256).max);
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

    function setWallets(address payable liquidity, address payable insurance, address payable firePit, address payable treasury) external onlyOwner {
        _taxWallets.liquidity = payable(liquidity);
        _taxWallets.insurance = payable(insurance);
        _taxWallets.firePit = payable(firePit);
        _taxWallets.treasury = payable(treasury);
    }

    function setTaxesBuy(uint16 liquidity, uint16 insurance, uint16 treasury, uint16 firePit) external onlyOwner {
        _buyTaxes.liquidity = liquidity;
        _buyTaxes.insurance = insurance;
        _buyTaxes.treasury = treasury;
        _buyTaxes.firePit = firePit;
        _buyTaxes.total = liquidity + insurance + treasury + firePit;
        require(_buyTaxes.total <= maxBuyTaxes, "Cannot exceed maximums.");
        require(_buyTaxes.total + _sellTaxes.total <= maxRoundtripTax, "Cannot exceed roundtrip maximum.");
    }

    function setTaxesSell(uint16 liquidity, uint16 insurance, uint16 treasury, uint16 firePit) external onlyOwner {
        _sellTaxes.liquidity = liquidity;
        _sellTaxes.insurance = insurance;
        _sellTaxes.treasury = treasury;
        _sellTaxes.firePit = firePit;
        _sellTaxes.total = liquidity + insurance + treasury + firePit;
        require(_sellTaxes.total <= maxSellTaxes, "Cannot exceed maximums.");
        require(_sellTaxes.total + _sellTaxes.total <= maxRoundtripTax, "Cannot exceed roundtrip maximum.");
    }

    function setTaxesTransfer(uint16 liquidity, uint16 insurance, uint16 treasury, uint16 firePit) external onlyOwner {
        _buyTaxes.liquidity = liquidity;
        _buyTaxes.insurance = insurance;
        _buyTaxes.treasury = treasury;
        _buyTaxes.firePit = firePit;
        _buyTaxes.total = liquidity + insurance + treasury + firePit;
        require(_transferTaxes.total <= maxTransferTaxes, "Cannot exceed maximums.");
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

    function setAutoRebaseEnabled(bool enabled) external onlyOwner {
        if (enabled) {
            autoRebaseLastTriggered = block.timestamp;
            if(autoRebaseInitializationStamp == 0) {
                autoRebaseInitializationStamp = block.timestamp;
            }
        }
        autoRebaseEnabled = enabled;
    }

    function setRebaseSettings(uint256 rate, uint256 timeInMinutes) external onlyOwner {
        require (rebaseTimeInMinutes >= 15, "Must be above 15 minutes minimum.");
        rebaseRate = rate;
        rebaseTimeInMinutes = timeInMinutes;
        autoRebaseLastTriggered = block.timestamp;
    }

    function setLimitedWallet(address account, bool enabled) external onlyOwner {
        require(account != address(this) && account != address(dexRouter), "Cannot set contract or router.");
        limitedWallet[account] = enabled;
        if (enabled) {
            userLimits[account].totalBought = balanceOf(account);
            userLimits[account].sellLimitPerTime = (userLimits[account].totalBought * limitPercent) / 10000;
        }
    }

    function setLimitedWalletSettings(uint256 timeInMinutes, uint256 percentInHundreds) external onlyOwner {
        limitTime = timeInMinutes * 1 minutes;
        limitPercent = percentInHundreds;
    }

    function getLimitedWalletInfo(address account) external view returns (uint256 totalBought, uint256 lastSellStamp, uint256 sellLimitPerTime, uint256 soldDuringCurrentLimit) {
        return(userLimits[account].totalBought / (10**_decimals),
               userLimits[account].lastSellStamp, 
               userLimits[account].sellLimitPerTime / (10**_decimals), 
               userLimits[account].soldDuringLimit / (10**_decimals)
               );
    }

    function getAdjustedSupply() external view returns (uint256) {
        return _aSupply;
    }

    function getRTotal() external view returns (uint256) {
        return _rTotal;
    }

    function _hasLimits(address from, address to) internal view returns (bool) {
        return from != _owner
            && to != _owner
            && tx.origin != _owner
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
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
        if(_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
        }

        if (!buy) {
            if (limitedWallet[from]) {
                require(amount <= userLimits[from].sellLimitPerTime, "Limited wallet selling above limit.");
                if (userLimits[from].lastSellStamp + limitTime < block.timestamp) {
                    userLimits[from].lastSellStamp = block.timestamp;
                    userLimits[from].soldDuringLimit = amount;
                } else {
                    require(userLimits[from].soldDuringLimit + amount <= userLimits[from].sellLimitPerTime, "Limited wallet selling above limit.");
                    userLimits[from].soldDuringLimit += amount;
                }
            }
        }

        if (sell) {
            if (!inSwap) {
                uint256 rebaseMinutes = rebaseTimeInMinutes * 1 minutes;
                if(autoRebaseEnabled
                   && block.timestamp >= autoRebaseLastTriggered + rebaseMinutes
                ) {
                    uint256 deltaTime = block.timestamp - autoRebaseLastTriggered;
                    uint256 rebaseAmounts = deltaTime / (rebaseMinutes);
                    uint256 epoch = rebaseAmounts * rebaseTimeInMinutes;

                    for (uint256 i = 0; i < rebaseAmounts; i++) {
                        _tTotal = (_tTotal * ((10**_rateDecimals) + rebaseRate)) / (10**_rateDecimals);
                    }

                    _aSupply = _rTotal / _tTotal;
                    autoRebaseLastTriggered += rebaseAmounts * rebaseMinutes;

                    v2Pair_lpPair.sync();

                    emit LogRebase(epoch, _tTotal);
                }

                if(contractSwapEnabled) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapThreshold) {
                        uint256 swapAmt = swapAmount;
                        if(piContractSwapsEnabled) { swapAmt = (balanceOf(lpPair) * piSwapPercent) / masterTaxDivisor; }
                        if(contractTokenBalance >= swapAmt) { contractTokenBalance = swapAmt; }
                        contractSwap(contractTokenBalance);
                    }
                }
            }      
        } 
        return finalizeTransfer(from, to, amount, buy, sell, other);
    }

    function contractSwap(uint256 contractTokenBalance) internal lockTheSwap {
        if(_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        if(IERC20_USDT.allowance(address(this), address(dexRouter)) != type(uint256).max) {
            IERC20_USDT.approve(address(dexRouter), type(uint256).max);
        }

        uint256 toLiquify = contractTokenBalance / 2;
        uint256 swapAmt = contractTokenBalance - toLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapAmt,
            0,
            path,
            address(antiSnipe),
            block.timestamp
        );

        antiSnipe.withdraw();

        uint256 tokenAmount = balanceOf(address(this));
        uint256 USDTAmount = IERC20_USDT.balanceOf(address(this));

        if (toLiquify > 0) {
            dexRouter.addLiquidity(
                USDT,
                address(this),
                USDTAmount,
                tokenAmount,
                0,
                0,
                _taxWallets.liquidity,
                block.timestamp
            );
            emit AutoLiquify(USDTAmount, tokenAmount);
        }
    }

    function _checkLiquidityAdd(address from, address to) internal {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            if(address(antiSnipe) == address(0)){
                antiSnipe = AntiSnipe(address(this));
            }
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        if(address(antiSnipe) == address(0)){
            antiSnipe = AntiSnipe(address(this));
        }
        try antiSnipe.setLaunch(lpPair, uint32(block.number), uint64(block.timestamp), _decimals) {} catch {}
        tradingEnabled = true;
        swapThreshold = (balanceOf(lpPair) * 10) / 10000;
        swapAmount = (balanceOf(lpPair) * 30) / 10000;
    }

    function sweepContingency() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
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
        }

        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        uint256 aSupply = _aSupply;
        amount *= aSupply;
        _tOwned[from] -= amount;
        uint256 amountReceived = (takeFee) ? takeTaxes(from, buy, sell, amount, aSupply) : amount;
        _tOwned[to] += amountReceived;

        uint256 finalAmount = amountReceived / aSupply;
        emit Transfer(from, to, amountReceived / aSupply);

        if (limitedWallet[to]) {
            userLimits[to].totalBought += finalAmount;
            userLimits[to].sellLimitPerTime = (userLimits[to].totalBought * limitPercent) / 10000;
        }

        return true;
    }

    function takeTaxes(address from, bool buy, bool sell, uint256 amount, uint256 aSupply) internal returns (uint256) {
        Fees memory currentFee;
        if (buy) {
            currentFee = _buyTaxes;
        } else if (sell) {
            currentFee = _sellTaxes;
        } else {
            currentFee = _transferTaxes;
        }

        if (currentFee.total == 0) {
            return amount;
        }

        uint256 feeAmount = (amount / masterTaxDivisor) * currentFee.total;
        uint256 insuranceAmount = (feeAmount / currentFee.total) * currentFee.insurance;
        uint256 treasuryAmount = (feeAmount / currentFee.total) * currentFee.treasury;
        uint256 firePitAmount = (feeAmount / currentFee.total) * currentFee.firePit;
        uint256 liquidityAmount = feeAmount - (insuranceAmount + treasuryAmount + firePitAmount);

        if (currentFee.insurance > 0) {
            _tOwned[_taxWallets.insurance] += insuranceAmount;
            emit Transfer(from, _taxWallets.insurance, insuranceAmount / aSupply);
        }
        if (currentFee.treasury > 0) {
            _tOwned[_taxWallets.treasury] += treasuryAmount;
            emit Transfer(from, _taxWallets.treasury, treasuryAmount / aSupply);
        }
        if (currentFee.firePit > 0) {
            _tOwned[_taxWallets.firePit] += firePitAmount;
            emit Transfer(from, _taxWallets.firePit, firePitAmount / aSupply);
        }

        if (currentFee.liquidity > 0) {
            _tOwned[address(this)] += liquidityAmount;
            emit Transfer(from, address(this), liquidityAmount / aSupply);
        }

        return amount - feeAmount;
    }
}