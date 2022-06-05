/**
 *Submitted for verification at BscScan.com on 2022-06-04
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
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
    function isBlacklisted(address account) external view returns (bool);
    function setBlacklistEnabled(address account, bool enabled) external;
    function setBlacklistEnabledMultiple(address[] memory accounts, bool enabled) external;
}

interface Cashier {
    function setRewardsProperties(uint256 _minPeriod, uint256 _minReflection) external;
    function tally(address user, uint256 amount) external;
    function load() external payable;
    function cashout(uint256 gas) external;
    function giveMeWelfarePlease(address hobo) external;
    function getTotalDistributed() external view returns(uint256);
    function getUserInfo(address user) external view returns(string memory, string memory, string memory, string memory);
    function getUserRealizedRewards(address user) external view returns (uint256);
    function getPendingRewards(address user) external view returns (uint256);
    function initialize() external;
}

contract WEARE8 is IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping (address => uint256) _tOwned;
    mapping (address => uint256) _fOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;
    mapping (address => bool) private _isExcludedFromDividends;
    mapping (address => bool) private _liquidityHolders;

    uint256 constant private startingSupply = 100_000_000;

    string constant private _name = "We Are 8";
    string constant private _symbol = "WeR8";
    uint8 constant private _decimals = 5;

    uint256 private _tTotal = startingSupply * 10**_decimals;
    uint256 constant private MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _aSupply = _rTotal / _tTotal;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct Ratios {
        uint16 rewards;
        uint16 liquidity;
        uint16 marketing;
        uint16 total;
    }

    Fees public _taxRates = Fees({
        buyFee: 1200,
        sellFee: 1200,
        transferFee: 0
        });

    Ratios public _ratios = Ratios({
        rewards: 400,
        liquidity: 400,
        marketing: 400,
        total: 1200
        });

    uint256 constant public maxBuyTaxes = 1200;
    uint256 constant public maxSellTaxes = 1200;
    uint256 constant public maxTransferTaxes = 1200;
    uint256 constant public maxRoundtripTax = 1200;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;
    IV2Pair v2Pair_lpPair;

    // REWARD MAINNET TOKEN CONTRACT ADDRESS
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private ZERO = 0x0000000000000000000000000000000000000000;

    struct TaxWallets {
        address payable marketing;
        address liquidity;
    }

    TaxWallets public _taxWallets = TaxWallets({
        marketing: payable(0x4438Cdb7bF5F37d7423b2974981EFAD2d0C0e7C7),
        liquidity: 0x6870E9f37De40157D0355b4e694f72ee69A18ec1
        });

    Cashier reflector;
    uint256 reflectorGas = 600000;

    bool inSwap;
    bool public contractSwapEnabled = false;
    uint256 public swapThreshold;
    uint256 public swapAmount;
    bool public piContractSwapsEnabled;
    uint256 public piSwapPercent;

    bool public processReflect = false;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    AntiSnipe antiSnipe;

    bool public autoRebaseEnabled = false;
    uint256 public launchStamp;
    uint256 public autoRebaseLastTriggered;
    uint256 public rebaseTimeInMinutes = 15;
    uint256 public rebaseShortTerm = 1972;
    uint256 public rebaseLongTerm = 1117;
    uint8 constant private _rateDecimals = 7;


    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountBNB, uint256 amount);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    constructor () payable {
        // Set the owner.
        _owner = msg.sender;
        _tOwned[_owner] = _rTotal;
        emit Transfer(address(0), _owner, _tTotal);
        emit OwnershipTransferred(address(0), _owner);

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4) {
            dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            //Ropstein DAI 0xaD6D458402F60fD3Bd25163575031ACDce07538D
        } else if (block.chainid == 43114) {
            dexRouter = IRouter02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        } else if (block.chainid == 250) {
            dexRouter = IRouter02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
        } else {
            revert();
        }

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;
        v2Pair_lpPair = IV2Pair(lpPair);

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromDividends[_owner] = true;
        _isExcludedFromDividends[lpPair] = true;
        _isExcludedFromDividends[address(this)] = true;
        _isExcludedFromDividends[DEAD] = true;
        _isExcludedFromDividends[ZERO] = true;
    }

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromDividends[newOwner] = true;
        
        if(balanceOf(_owner) > 0) {
            _finalizeTransfer(_owner, newOwner, balanceOf(_owner), false, false, true);
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        
    }

    function renounceOwnership() external onlyOwner {
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================

    receive() external payable {}

    function totalSupply() external view override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account] / _aSupply;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setNewRouter(address newRouter) public onlyOwner {
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
        if (enabled == false) {
            lpPairs[pair] = false;
            antiSnipe.setLpPair(pair, false);
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "Cannot set a new pair this week!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
            antiSnipe.setLpPair(pair, true);
        }
    }

    function setInitializers(address aInitializer, address cInitializer) external onlyOwner {
        require(!tradingEnabled);
        require(cInitializer != address(this) && aInitializer != address(this) && cInitializer != aInitializer);
        reflector = Cashier(cInitializer);
        antiSnipe = AntiSnipe(aInitializer);
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromDividends(address account) external view returns(bool) {
        return _isExcludedFromDividends[account];
    }

    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function isExcludedFromProtection(address account) external view returns (bool) {
        return _isExcludedFromProtection[account];
    }

    function setExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function setDividendExcluded(address holder, bool enabled) public onlyOwner {
        require(holder != address(this) && holder != lpPair);
        _isExcludedFromDividends[holder] = enabled;
        if (enabled) {
            reflector.tally(holder, 0);
        } else {
            reflector.tally(holder, _tOwned[holder]);
        }
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function setExcludedFromProtection(address account, bool enabled) external onlyOwner {
        _isExcludedFromProtection[account] = enabled;
    }

//================================================ BLACKLIST

    function setBlacklistEnabled(address account, bool enabled) external onlyOwner {
        antiSnipe.setBlacklistEnabled(account, enabled);
        setDividendExcluded(account, enabled);
    }

    function setBlacklistEnabledMultiple(address[] memory accounts, bool enabled) external onlyOwner {
        antiSnipe.setBlacklistEnabledMultiple(accounts, enabled);
        for(uint256 i = 0; i < accounts.length; i++){
            setDividendExcluded(accounts[i], enabled);
        }
    }

//================================================ BLACKLIST

    function isBlacklisted(address account) public view returns (bool) {
        return antiSnipe.isBlacklisted(account);
    }

    function removeSniper(address account) external onlyOwner {
        antiSnipe.removeSniper(account);
    }

    function setProtectionSettings(bool _antiSnipe, bool _antiBlock) external onlyOwner {
        antiSnipe.setProtections(_antiSnipe, _antiBlock);
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        if(address(antiSnipe) == address(0)){
            antiSnipe = AntiSnipe(address(this));
        }
        try antiSnipe.setLaunch(lpPair, uint32(block.number), uint64(block.timestamp), _decimals) {} catch {}
        try reflector.initialize() {} catch {}
        tradingEnabled = true;
        processReflect = true;
        swapThreshold = (balanceOf(lpPair) * 10) / 10000;
        swapAmount = (balanceOf(lpPair) * 30) / 10000;
        launchStamp = block.timestamp;
    }

    function setTaxes(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        require(buyFee + sellFee <= maxRoundtripTax, "Cannot exceed roundtrip maximum.");
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function setRatios(uint16 rewards, uint16 liquidity, uint16 marketing) external onlyOwner {
        _ratios.rewards = rewards;
        _ratios.liquidity = liquidity;
        _ratios.marketing = marketing;
        _ratios.total = rewards + liquidity + marketing;
        uint256 total = _taxRates.buyFee + _taxRates.sellFee;
        require(_ratios.total <= total, "Cannot exceed sum of buy and sell fees.");
    }

    function setWallets(address payable marketing, address liquidity) external onlyOwner {
        _taxWallets.marketing = payable(marketing);
        _taxWallets.liquidity = liquidity;
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

    function setContractSwapEnabled(bool swapEnabled, bool processReflectEnabled, bool priceImpactSwapEnabled) external onlyOwner {
        contractSwapEnabled = swapEnabled;
        processReflect = processReflectEnabled;
        piContractSwapsEnabled = priceImpactSwapEnabled;
        emit ContractSwapEnabledUpdated(swapEnabled);
    }

    function setRewardsProperties(uint256 _minPeriod, uint256 _minReflection, uint256 minReflectionMultiplier) external onlyOwner {
        _minReflection = _minReflection * 10**minReflectionMultiplier;
        reflector.setRewardsProperties(_minPeriod, _minReflection);
    }

    function setReflectorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        reflectorGas = gas;
    }

    function setAutoRebaseEnabled(bool enabled) external onlyOwner {
        if (enabled) {
            autoRebaseLastTriggered = block.timestamp;
        }
        autoRebaseEnabled = enabled;
    }

    function setLongtermRebase(uint256 rate) external onlyOwner {
        require(rate <= rebaseShortTerm, "Cannot be higher than short term rate.");
        rebaseLongTerm = rate;
    }

    function getReflectionlessBalance(address account) external view returns (uint256) {
        return _fOwned[account];
    }

    function _hasLimits(address from, address to) private view returns (bool) {
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

        if (sell) {
            if (!inSwap) {
                if(autoRebaseEnabled
                   && block.timestamp >= autoRebaseLastTriggered + 15 minutes
                ) {
                    uint256 rebaseRate;
                    uint256 deltaTimeFromInitialization = block.timestamp - launchStamp;
                    uint256 deltaTime = block.timestamp - autoRebaseLastTriggered;
                    uint256 rebaseAmounts = deltaTime / (rebaseTimeInMinutes * 1 minutes);
                    uint256 epoch = rebaseAmounts * rebaseTimeInMinutes;

                    if (deltaTimeFromInitialization < 365 days) {
                        rebaseRate = rebaseShortTerm;
                    } else {
                        rebaseRate = rebaseLongTerm;
                    }

                    for (uint256 i = 0; i < rebaseAmounts; i++) {
                        _tTotal = (_tTotal * ((10**_rateDecimals) + rebaseRate)) / (10**_rateDecimals);
                    }

                    _aSupply = _rTotal / _tTotal;
                    autoRebaseLastTriggered += rebaseAmounts * 15 minutes;

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
        return _finalizeTransfer(from, to, amount, buy, sell, other);
    }

    function _finalizeTransfer(address from, address to, uint256 amount, bool buy, bool sell, bool other) internal returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to) && !_isExcludedFromProtection[from] && !_isExcludedFromProtection[to] && !other) {
                revert("Only owner can transfer at this time.");
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
        uint256 adjustedAmount = amount * aSupply;
        uint256 fromOwned = _tOwned[from];
        _tOwned[from] -= adjustedAmount;
        uint256 amountReceived = takeTaxes(from, to, buy, sell, other, adjustedAmount, fromOwned, aSupply, takeFee);
        _tOwned[to] += amountReceived;

        processRewards(from, to, aSupply);

        emit Transfer(from, to, amountReceived / aSupply);
        return true;
    }

    function processRewards(address from, address to, uint256 aSupply) internal {
        if (!_isExcludedFromDividends[from]) {
            try reflector.tally(from, _tOwned[from] / aSupply) {} catch {}
        }
        if (!_isExcludedFromDividends[to]) {
            try reflector.tally(to, _tOwned[to] / aSupply) {} catch {}
        }
        if (processReflect) {
            try reflector.cashout(reflectorGas) {} catch {}
        }
    }

    function takeTaxes(address from, address to, bool buy, bool sell, bool other, uint256 amount, uint256 fromOwned, uint256 aSupply, bool takeFee) internal returns (uint256) {
        uint256 currentFee;
        uint256 taxableAmount = amount;

        uint256 fromReflections = (fromOwned > 0) ? ((fromOwned / aSupply) - _fOwned[from]) * aSupply : 0;
        if(takeFee) {
            if (buy) {
                currentFee = _taxRates.buyFee;
            } else if (sell) {
                currentFee = _taxRates.sellFee;
            } else {
                currentFee = _taxRates.transferFee;
            }
        }

        if(!buy) {
            if(fromReflections >= amount) {
                taxableAmount = 0;
            } else {
                taxableAmount = amount - fromReflections;
                _fOwned[from] -= taxableAmount / aSupply;
            }
        }
        uint256 feeAmount;
        if (currentFee > 0) {
            feeAmount = (taxableAmount / masterTaxDivisor) * currentFee;
            if (feeAmount > 0) {
                _tOwned[address(this)] += feeAmount;
                emit Transfer(from, address(this), feeAmount / aSupply);
            }
        }

        if(!sell) {
            _fOwned[to] += (amount - feeAmount) / aSupply;
        }

        return amount - feeAmount;
    }

    function contractSwap(uint256 contractTokenBalance) internal swapping {
        Ratios memory ratios = _ratios;
        if (ratios.total == 0) {
            return;
        }
        
        if(_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 toLiquify = ((contractTokenBalance * ratios.liquidity) / (ratios.total)) / 2;
        uint256 swapAmt = contractTokenBalance - toLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmt,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amtBalance = address(this).balance;
        uint256 liquidityBalance = (amtBalance * toLiquify) / swapAmt;

        if (toLiquify > 0) {
            dexRouter.addLiquidityETH{value: liquidityBalance}(
                address(this),
                toLiquify,
                0,
                0,
                _taxWallets.liquidity,
                block.timestamp
            );
            emit AutoLiquify(liquidityBalance, toLiquify);
        }

        amtBalance -= liquidityBalance;
        ratios.total -= ratios.liquidity;
        bool success;
        uint256 rewardsBalance = (amtBalance * ratios.rewards) / ratios.total;
        uint256 marketingBalance = amtBalance - (rewardsBalance);

        if (ratios.rewards > 0) {
            try reflector.load{value: rewardsBalance}() {} catch {}
        }

        if(ratios.marketing > 0){
            (success,) = _taxWallets.marketing.call{value: marketingBalance, gas: 35000}("");
        }
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            if(address(antiSnipe) == address(0)) {
                antiSnipe = AntiSnipe(address(this));
            }
            if(address(reflector) ==  address(0)) {
                reflector = Cashier(address(this));
            }
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            _finalizeTransfer(msg.sender, accounts[i], amounts[i]*10**_decimals, false, false, true);
        }
    }

    function manualDeposit() external onlyOwner {
        try reflector.load{value: address(this).balance}() {} catch {}
    }

    function sweepContingency() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
    }

//=====================================================================================
//            Reflector

    function claimPendingRewards() external {
        reflector.giveMeWelfarePlease(msg.sender);
    }

    function getTotalReflected() external view returns (uint256) {
        return reflector.getTotalDistributed();
    }

    function getUserInfo(address user) external view returns (string memory, string memory, string memory, string memory) {
        return reflector.getUserInfo(user);
    }

    function getUserRealizedGains(address user) external view returns (uint256) {
        return reflector.getUserRealizedRewards(user);
    }

    function getUserUnpaidEarnings(address user) external view returns (uint256) {
        return reflector.getPendingRewards(user);
    }
}