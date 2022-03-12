// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IFactoryV2.sol";
import "./IERC20.sol";
import "./IUniswapV2Pair.sol";

contract LIFEGAMES is IERC20 {
    using SafeMath for uint256;

    struct Fees {
        uint16 distributionToHoldersFee;
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct StaticValuesStruct {
        uint16 maxTotalFee;
        uint16 maxDistributionToHoldersFee;
        uint16 maxBuyFee;
        uint16 maxSellFee;
        uint16 maxTransferFee;
        uint16 masterTaxDivisor;
    }

    struct Ratios {
        uint16 liquidityRatio;
        uint16 buyBurnRatio;
        uint16 total;
    }

    Fees public _taxRates = Fees({
        distributionToHoldersFee : 150,
        buyFee : 150,
        sellFee : 150,
        transferFee : 0
    });

    Ratios public _ratios = Ratios({
        liquidityRatio : 50,
        buyBurnRatio : 100,
        total : 150
    });

    StaticValuesStruct public staticVals = StaticValuesStruct({
        maxTotalFee : 300,
        maxDistributionToHoldersFee : 300,
        maxBuyFee : 300,
        maxSellFee : 300,
        maxTransferFee : 300,
        masterTaxDivisor : 10000
    });

    // reflection
    uint256 private _tTotal = 1 * 1e7 * 1e18;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint16 private _previousTaxFee = 0;
    mapping(address => uint256) private _rOwned;
    address[] private _excluded;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    bool public takeFeeEnabled = true;
    // ---------------------------------------------------

    bool private gasLimitActive = false;
    uint256 private gasPriceLimit = 15000000000; // 15 gWei / gWei -> Default 10
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = false;
    uint256 private initialBlock;

    bool private autoAddliquidityEnabled = false;
    uint256 private autoliquidityTokenPriceThreshold = 1000000000000000000;
    uint256 public autoAddliquidityThreshold = 0;

    event Burn(
        address indexed sender,
        uint256 amount
    );

    mapping(address => bool) public bridges;

    address private _owner;

    mapping(address => uint256) _tOwned;
    mapping(address => bool) public lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) _isFeeExcluded;
    mapping(address => bool) private _isSniper;

    mapping(address => bool) private _liquidityRatioHolders;

    string constant private _name = "LIFEGAMES";
    string constant private _symbol = "LFG";
    uint8 private _decimals = 18;

    uint256 private snipeBlockAmt = 0;
    uint256 public snipersCaught = 0;
    bool private sameBlockActive = true;
    bool private sniperProtection = true;
    uint256 private _liqAddBlock = 0;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public zero = 0x0000000000000000000000000000000000000000;

    address payable public busdForLiquidityAddress;
    address payable public busdBuyBurnAddress;

    bool public contractSwapEnabled = true;
    uint256 public swapThreshold = 100000000000000000000;
    uint256 public swapAmount = 99000000000000000000;
    bool inSwap;

    bool public tradingActive = false;
    bool public hasLiqBeenAdded = false;

    address public busdAddress;

    uint256 whaleFeePercent = 0;
    uint256 whaleFee = 0;
    bool public transferToPoolsOnSwaps = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyBridge() {
        require(bridges[msg.sender] == true, "Only bridges contracts can call this function");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountAVAX, uint256 amount);
    event SniperCaught(address sniperAddress);

    constructor (address[] memory addresses) {


        _rOwned[msg.sender] = _rTotal;
        _owner = msg.sender;

        busdAddress = address(addresses[0]);

        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[busdAddress] = true;

        // exclude LiquidityAddress and busdBuyBurnAddress
        _isExcludedFromFee[addresses[3]] = true;
        _isExcludedFromFee[addresses[4]] = true;
        
        _approve(msg.sender, addresses[1], type(uint256).max);
        _approve(address(this), addresses[1], type(uint256).max);
        _approve(msg.sender, busdAddress, type(uint256).max);
        _approve(address(this), busdAddress, type(uint256).max);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[1]);
        lpPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), busdAddress);
        lpPairs[lpPair] = true;
        dexRouter = _uniswapV2Router;

        bridges[addresses[2]] = true;

        setLiquidityAddress(addresses[3]);
        setbusdBuyBurnAddress(addresses[4]);

        initialBlock = block.number;

        emit Transfer(zero, msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    //===============================================================================================================
    //===============================================================================================================
    //===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _isFeeExcluded[_owner] = false;
        _isFeeExcluded[newOwner] = true;

        if (_tOwned[_owner] > 0) {
            _transfer(_owner, newOwner, _tOwned[_owner]);
        }

        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _isFeeExcluded[_owner] = false;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    //===============================================================================================================
    //===============================================================================================================
    //===============================================================================================================

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _tTotal;}

    function decimals() external view override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner();}

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

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

    function setStartingProtections(uint8 _block) external onlyOwner {
        require(snipeBlockAmt == 0 && _block <= 5 && !hasLiqBeenAdded);
        snipeBlockAmt = _block;
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    function removeSniper(address account) external onlyOwner() {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function setProtectionSettings(bool antiSnipe, bool antiBlock) external onlyOwner() {
        sniperProtection = antiSnipe;
        sameBlockActive = antiBlock;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function isFeeExcluded(address account) public view returns (bool) {
        return _isFeeExcluded[account];
    }

    function enableTrading() public onlyOwner {
        require(!tradingActive, "Trading already enabled!");
        require(hasLiqBeenAdded, "liquidityRatio must be added.");
        _liqAddBlock = block.number;
        tradingActive = true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setTaxes(uint16 distributionToHoldersFee, uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        // check each individual fee dont be higer than 3%
        require(
            distributionToHoldersFee <= staticVals.maxDistributionToHoldersFee &&
            buyFee <= staticVals.maxBuyFee &&
            sellFee <= staticVals.maxSellFee &&
            transferFee <= staticVals.maxTransferFee,
            "MAX TOTAL BUY FEES EXCEEDED 3%");

        // check max fee dont be higer than 3%
        require((distributionToHoldersFee + buyFee + transferFee) <= staticVals.maxTotalFee, "MAX TOTAL BUY FEES EXCEEDED 3%");
        require((distributionToHoldersFee + sellFee + transferFee) <= staticVals.maxTotalFee, "MAX TOTAL SELL FEES EXCEEDED 3%");

        _taxRates.distributionToHoldersFee = distributionToHoldersFee;
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function setRatios(uint16 liquidityRatio, uint16 buyBurnRatio) external onlyOwner {
        _ratios.liquidityRatio = liquidityRatio;
        _ratios.buyBurnRatio = buyBurnRatio;
        _ratios.total = liquidityRatio + buyBurnRatio;
    }

    function setLiquidityAddress(address _busdForLiquidityAddress) public onlyOwner {
        require(
            _busdForLiquidityAddress != address(0),
            "_busdForLiquidityAddress address cannot be 0"
        );
        busdForLiquidityAddress = payable(_busdForLiquidityAddress);
    }

    function setbusdBuyBurnAddress(address _busdBuyBurnAddress)
    public
    onlyOwner
    {
        require(
            _busdBuyBurnAddress != address(0),
            "_busdBuyBurnAddress address cannot be 0"
        );
        busdBuyBurnAddress = payable(_busdBuyBurnAddress);
    }

    function setContractSwapSettings(bool _enabled) external onlyOwner {
        contractSwapEnabled = _enabled;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function setNewRouter(address newRouter, address busd) public onlyOwner() {
        require(!hasLiqBeenAdded);
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(busd), address(this));
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(busd), address(this));
        }
        else {
            lpPair = get_pair;
        }
        lpPairs[lpPair] = true;
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled = false) {
            lpPairs[pair] = false;
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "Cannot set a new pair this week!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
        }
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != _owner
        && to != _owner
        && tx.origin != _owner
        && !_liquidityRatioHolders[to]
        && !_liquidityRatioHolders[from]
        && to != DEAD
        && to != address(0)
        && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_hasLimits(from, to)) {
            if (!tradingActive) {
                revert("Trading not yet enabled!");
            }
        }

        // blacklist
        require(
            _isSniper[from] == false || _isSniper[to] == false,
            "Blacklisted address"
        );

        // only use to prevent sniper buys in the first blocks.
        if (gasLimitActive && lpPairs[from]) {
            require(tx.gasprice <= gasPriceLimit, "Gas price exceeds limit.");
        }

        // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.

        if (transferDelayEnabled && block.number < (initialBlock + (1200))) {
            
            if (transferDelayEnabled && block.number < (initialBlock + 60)) {
                if (from != owner() && to != address(dexRouter) && to != address(lpPair)) {
                    require(_holderLastTransferTimestamp[tx.origin] < block.number,
                     "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

        }

        if (sniperProtection) {
            if (isSniper(from) || isSniper(to)) {
                revert("Sniper rejected.");
            }

            if (!hasLiqBeenAdded) {
                _checkliquidityRatioAdd(from, to);
                if (!hasLiqBeenAdded && _hasLimits(from, to)) {
                    revert("Only owner can transfer at this time.");
                }
            } else {
                if (_liqAddBlock > 0
                && lpPairs[from]
                    && _hasLimits(from, to)
                ) {
                    if (block.number - _liqAddBlock < snipeBlockAmt) {
                        _isSniper[to] = true;
                        snipersCaught++;
                        emit SniperCaught(to);
                    }
                }
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        return _finalizeTransfer(from, to, amount, takeFee && takeFeeEnabled);
    }

    function _finalizeTransfer(address from, address to, uint256 amount, bool takeFee) internal returns (bool) {


        if (inSwap) {
            removeAllFee();
            _tokenTransferNoFee(from, to, amount);
            restoreAllFee();
            return true;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if (
            contractTokenBalance >= swapThreshold &&
            !inSwap &&
            from != lpPair &&
            balanceOf(lpPair) > 0 &&
            !_isExcludedFromFee[to] &&
            !_isExcludedFromFee[from] &&
            contractSwapEnabled
        ) {
            contractSwap(swapAmount);
        }

        //uint256 amountReceived = amount;
        // apply buy, sell or transfer fees
        if (takeFee) {

            // BUY
            if (from == lpPair) {
                
            }
            // SELL
            else if (to == lpPair) {
                
            }
            // TRANSFER
            else {
                removeAllFee();
                _tokenTransferNoFee(from, to, amount);
                restoreAllFee();
                return true;
            }

            //uint256 amountReceived = takeBuySellTransferFee(from, to, amount);
            takeBuySellTransferFee(from, to, amount);
        }

        _tokenTransfer(from, to, amount, takeFee);
        return true;
    }

    // todo max whale fees
    function setWhaleFeesPercentage(uint256 _whaleFeePercent) external onlyOwner {
        whaleFeePercent = _whaleFeePercent;
    }

    function updateTransferDelayEnabled(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    function updateAutoliquidityTokenPriceThreshold(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    // todo max whale fees
    function setWhaleFees(uint256 _whaleFee) external onlyOwner {
        whaleFee = _whaleFee;
    }

    function calculateWhaleFee(uint256 amount) public view returns (uint256) {
        uint256 busdAmount = getOutEstimatedTokensForTokens(address(this), busdAddress, amount);
        uint256 liquidityRatioAmount = getOutEstimatedTokensForTokens(address(this), busdAddress, getReserves()[0]);

        // if amount in busd exceeded the % setted as whale, calc the estimated fee
        if (busdAmount >= ((liquidityRatioAmount * whaleFeePercent) / staticVals.masterTaxDivisor)) {
            // mod of busd amount sold and whale amount
            uint256 modAmount = busdAmount % ((liquidityRatioAmount * whaleFeePercent) / staticVals.masterTaxDivisor);
            return whaleFee * modAmount;
        } else {
            return 0;
        }
    }

    function takeBuySellTransferFee(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 takesAmount = 0;
        uint256 totalFee = 0;
        uint256 antiWhaleAmount = 0;

        // BUY
        if (from == lpPair) {
            if (_taxRates.buyFee > 0) {
                totalFee += _taxRates.buyFee;
            }

            // ANTIWHALE
            if (whaleFee > 0) {
                antiWhaleAmount = calculateWhaleFee(amount);
                totalFee += antiWhaleAmount;
            }
        }

        // SELL
        else if (to == lpPair) {
            if (_taxRates.sellFee > 0) {
                totalFee += _taxRates.sellFee;
            }
        }

        // TRANSFER
        else {
            if (_taxRates.transferFee > 0) {
                totalFee += _taxRates.transferFee;
            } 
            
            /*
            else {
                removeAllFee();
                _tokenTransferNoFee(from, to, amount);
                restoreAllFee();
            }

            */
        }

        // CALC FEES AMOUT AND SEND TO CONTRACT
        if (totalFee > 0) {
            uint256 feeAmount = (amount * totalFee) / staticVals.masterTaxDivisor;
            _takeFees(feeAmount);
            emit Transfer(from, address(this), feeAmount);
            takesAmount = amount - feeAmount;
        }
        return takesAmount;
    }

    function contractSwap(uint256 numTokensToSwap) internal swapping {
        // cancel swap if fees are zero
        if (_ratios.total == 0) {
            return;
        }

        // check allowances // todo
        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        // calculate percentage to bsud reserver and manual buyback and burn 
        uint256 tokensToliquidityAmount = (numTokensToSwap * _ratios.liquidityRatio) / (_ratios.total);
        uint256 tokensToBuyBurnAmount = (numTokensToSwap * _ratios.buyBurnRatio) / (_ratios.total);
        //uint256 minOut = getOutEstimatedTokensForTokens(address(this), busdAddress, numTokensToSwap);

        // swap tokens for busd and send to busd liquidity address
        if (tokensToliquidityAmount > 0) {

            address[] memory tokensBusdPath = getPathForTokensToTokens(address(this), busdAddress);
            IERC20(address(this)).approve(address(dexRouter), numTokensToSwap);
            IERC20(busdAddress).approve(address(dexRouter), numTokensToSwap);

            dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokensToliquidityAmount,
                0,
                tokensBusdPath,
                busdForLiquidityAddress,
                block.timestamp + 600
            );
        }

        // swap tokens for busd and send to manual busd buyback and burn address 
        if (tokensToBuyBurnAmount > 0) {

            address[] memory tokensBusdPath = getPathForTokensToTokens(address(this), busdAddress);
            IERC20(address(this)).approve(address(dexRouter), numTokensToSwap);
            IERC20(busdAddress).approve(address(dexRouter), numTokensToSwap);

            dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokensToBuyBurnAmount,
                0,
                tokensBusdPath,
                busdBuyBurnAddress,
                block.timestamp + 600
            );
        }

        // todo test auto liquidityRatio
        if (autoAddliquidityEnabled) {

            uint256 tokenPriceInBusd = getOutEstimatedTokensForTokens(address(this), busdAddress, 1000000000000000000);

            // todo create update autoliquidity price condition 
            if (tokenPriceInBusd > autoliquidityTokenPriceThreshold) {

                // amounts
                uint256 estimatedTokensForAutoliquidity = getOutEstimatedTokensForTokens(address(this), busdAddress, 100000000000000000000);
                uint256 estimatedBusdForAutoliquidity = getOutEstimatedTokensForTokens(busdAddress, address(this), estimatedTokensForAutoliquidity);

                // if hit threshold
                // transfer tokens and busd contract
                if (estimatedTokensForAutoliquidity > autoAddliquidityThreshold) {

                    IERC20(address(busdAddress)).transferFrom(busdForLiquidityAddress, address(this), estimatedBusdForAutoliquidity);
                    IERC20(address(busdAddress)).transferFrom(busdBuyBurnAddress, address(this), estimatedTokensForAutoliquidity);

                    // swap busd for tokens?
                    addLiquidity(address(this), busdAddress, estimatedTokensForAutoliquidity, estimatedBusdForAutoliquidity, 0, 0, owner());
                }
            }
        }
    }

    function _checkliquidityRatioAdd(address from, address to) private {
        require(!hasLiqBeenAdded, "liquidityRatio already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {

            _liqAddBlock = block.number;
            _liquidityRatioHolders[from] = true;
            hasLiqBeenAdded = true;

            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i] * 10 ** _decimals);
        }
    }

    function multiSendPercents(address[] memory accounts, uint256[] memory percents, uint256[] memory divisors) external {
        require(accounts.length == percents.length && percents.length == divisors.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= (_tTotal * percents[i]) / divisors[i]);
            _transfer(msg.sender, accounts[i], (_tTotal * percents[i]) / divisors[i]);
        }
    }

    function updateTransferToPoolsOnSwaps(bool newValue) external onlyOwner {
        transferToPoolsOnSwaps = newValue;
    }

    function updateBUSDAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "ROUTER CANNOT BE ZERO");
        require(
            newAddress != address(busdAddress),
            "TKN: The BUSD already has that address"
        );
        busdAddress = address(newAddress);
    }

    function updateHasLiqBeenAdded() external onlyOwner {
        require(!hasLiqBeenAdded, "liquidityRatio already added and marked.");
        hasLiqBeenAdded = true;
    }

    function updateAutoAddliquidityEnabled(bool newValue) external onlyOwner {
        autoAddliquidityEnabled = newValue;
    }

    function updateAutoAddliquidityThreshold(uint256 newValue) external onlyOwner {
        autoAddliquidityThreshold = newValue;
    }

    function updatetakeFeeEnabled(bool newValue) external onlyOwner {
        takeFeeEnabled = newValue;
    }

    function getReserves() public view returns (uint[] memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(lpPair);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint[] memory reserves = new uint[](2);
        reserves[0] = Res0;
        reserves[1] = Res1;

        return reserves;
        // return amount of token0 needed to buy token1
    }

    function getTokenPrice(uint amount) public view returns (uint) {
        uint[] memory reserves = getReserves();
        uint res0 = reserves[0] * (10 ** _decimals);
        return ((amount * res0) / reserves[1]);
        // return amount of token0 needed to buy token1
    }

    function getOutEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsOut(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[1];
    }

    function getInEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsIn(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[1];
    }

    function getPathForTokensToTokens(address tokenAddressA, address tokenAddressB) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenAddressA;
        path[1] = tokenAddressB;
        return path;
    }

    function updateBridges(address bridgeAddress, bool newVal) external onlyBridge {
        require(bridgeAddress != address(0), "new bridge cant be zero address");
        bridges[bridgeAddress] = newVal;
    }

    function mint(address to, uint amount) external onlyBridge {
        _tOwned[to] = _tOwned[to] + amount;
    }

    function burn(address to, uint256 amount) public {
        require(amount >= 0, "Burn amount should be greater than zero");

        if (msg.sender != to) {
            uint256 currentAllowance = _allowances[to][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            }
        }

        require(
            amount <= balanceOf(to),
            "Burn amount should be less than account balance"
        );

        _tOwned[to] = _tOwned[to] - amount;
        _tTotal = _tTotal - amount;
        emit Burn(to, amount);
    }

    // reflection -------------------------------------------------------------------------------------------
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxRates.distributionToHoldersFee).div(staticVals.masterTaxDivisor);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amt must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amt must be less than tot refl");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isFeeExcluded[account], "Account is already excluded from reward");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isFeeExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function removeAllFee() private {
        if (_taxRates.distributionToHoldersFee == 0) return;
        _previousTaxFee = _taxRates.distributionToHoldersFee;
        _taxRates.distributionToHoldersFee = 0;
    }

    function restoreAllFee() private {
        _taxRates.distributionToHoldersFee = _previousTaxFee;
    }

    function _takeFees(uint256 tFee) private {
        uint256 currentRate = _getRate();
        uint256 rFee = tFee.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rFee);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _tokenTransferNoFee(address sender, address recipient, uint256 amount) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private returns (bool) {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        return true;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee)
            restoreAllFee();
    }

    function deliver(uint256 tAmount) public {
        address sender = msg.sender;
        require(!_isFeeExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) private {
        _approve(address(this), address(dexRouter), amountADesired);
        _approve(address(this), address(dexRouter), amountBDesired);
        dexRouter.addLiquidity(
            tokenA,
            tokenB,
            amountADesired, // slippage is unavoidable
            amountBDesired, // slippage is unavoidable
            amountAMin,
            amountBMin,
            to,
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

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
pragma solidity ^0.8.12;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
pragma solidity ^0.8.12;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IUniswapV2Router01 {
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