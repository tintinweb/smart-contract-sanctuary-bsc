/**
 *Submitted for verification at BscScan.com on 2022-09-25
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

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address lpPair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface TaxReductionNFT {
    function getUserTaxReduction(address account)
        external
        returns (uint256 reductionRate);
}

contract VICEDAO is IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping(address => uint256) _tOwned;
    mapping(address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) _isFeeExcluded;

    mapping(address => bool) private _liquidityHolders;

    uint256 private constant startingSupply = 1_000_000_000;

    string private constant _name = "ViceWRLD DAO";
    string private constant _symbol = "VICEDAO";
    uint8 private _decimals = 18;

    uint256 private _tTotal = startingSupply * (10**_decimals);

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct StaticValuesStruct {
        uint16 maxBuyTaxes;
        uint16 maxSellTaxes;
        uint16 maxTransferTaxes;
        uint16 masterTaxDivisor;
    }

    struct BuyRatios {
        uint16 ecosystem;
        uint16 liquidity;
        uint16 marketing;
        uint16 reflectionTax;
        uint16 burn;
        uint16 total;
    }

    struct SellRatios {
        uint16 ecosystem;
        uint16 liquidity;
        uint16 marketing;
        uint16 reflectionTax;
        uint16 burn;
        uint16 total;
    }

    Fees public _taxRates = Fees({buyFee: 400, sellFee: 2000, transferFee: 0});

    BuyRatios public _buyRatios =
        BuyRatios({
            ecosystem: 625,
            liquidity: 250,
            marketing: 0,
            reflectionTax: 0,
            burn: 125,
            total: 1000
        });

    SellRatios public _sellRatios =
        SellRatios({
            ecosystem: 775,
            liquidity: 200,
            marketing: 0,
            reflectionTax: 0,
            burn: 25,
            total: 1000
        });

    StaticValuesStruct public staticVals =
        StaticValuesStruct({
            maxBuyTaxes: 2000,
            maxSellTaxes: 2000,
            maxTransferTaxes: 2000,
            masterTaxDivisor: 10000
        });

    IRouter02 public dexRouter;
    address public lpPair;
    address public currentRouter;

    address public WETH;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address private zero = 0x0000000000000000000000000000000000000000;

    TaxReductionNFT public taxReductionNFT =
        TaxReductionNFT(0x000000000000000000000000000000000000dEaD);

    address payable public marketingWallet =
        payable(0xa89cCD941F12Bb0F1841e0Dd1694235B07df0fD8);
    address payable public ecosystemWallet =
        payable(0xa89cCD941F12Bb0F1841e0Dd1694235B07df0fD8);
    address payable private liquidityReceiver =
        payable(0x4d160674B92662F6520f3A9Ee30f7f19A4e4b1df);
    address payable private reflectionPool =
        payable(0x0000000000000000000000000000000000000000);

    uint256 private _maxTxAmount = (_tTotal * 10) / 100;
    uint256 private _maxWalletSize = (_tTotal * 10) / 100;

    bool public contractSwapEnabled = false;
    uint256 private swapThreshold = _tTotal / 20000;
    uint256 private swapAmount = (_tTotal * 5) / 1000;
    bool inSwap;

    bool public tradingEnabled = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event AutoLiquify(uint256 amountETH, uint256 amount);

    constructor() {
        address msgSender = msg.sender;
        _tOwned[msgSender] = _tTotal;

        _owner = msgSender;

        currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        dexRouter = IRouter02(currentRouter);
        lpPair = IFactoryV2(dexRouter.factory()).createPair(
            dexRouter.WETH(),
            address(this)
        );
        lpPairs[lpPair] = true;
        _approve(msg.sender, currentRouter, type(uint256).max);
        _approve(address(this), currentRouter, type(uint256).max);

        WETH = dexRouter.WETH();

        _isFeeExcluded[owner()] = true;
        _isFeeExcluded[address(this)] = true;

        emit Transfer(zero, msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), msgSender);
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
        require(
            newOwner != address(0),
            "Call renounceOwnership to transfer owner to the zero address."
        );
        require(
            newOwner != DEAD,
            "Call renounceOwnership to transfer owner to the zero address."
        );
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

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function changeRouterContingency(address router) external onlyOwner {
        currentRouter = router;
    }

    function isFeeExcluded(address account) public view returns (bool) {
        return _isFeeExcluded[account];
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        contractSwapEnabled = true;
        tradingEnabled = true;
    }

    function setExcludedFromFees(address account, bool enabled)
        public
        onlyOwner
    {
        _isFeeExcluded[account] = enabled;
    }

    function setTaxes(
        uint16 buyFee,
        uint16 sellFee,
        uint16 transferFee
    ) external onlyOwner {
        require(
            buyFee <= staticVals.maxBuyTaxes &&
                sellFee <= staticVals.maxSellTaxes &&
                transferFee <= staticVals.maxTransferTaxes
        );
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function setBuyRatios(
        uint16 ecosystem,
        uint16 liquidity,
        uint16 marketing,
        uint16 burn,
        uint16 reflectionTax
    ) external onlyOwner {
        _buyRatios.ecosystem = ecosystem;
        _buyRatios.liquidity = liquidity;
        _buyRatios.marketing = marketing;
        _buyRatios.reflectionTax = reflectionTax;
        _buyRatios.burn = burn;
        _buyRatios.total =
            ecosystem +
            liquidity +
            marketing +
            burn +
            reflectionTax;
    }

    function setSellRatios(
        uint16 ecosystem,
        uint16 liquidity,
        uint16 marketing,
        uint16 burn,
        uint16 reflectionTax
    ) external onlyOwner {
        _sellRatios.ecosystem = ecosystem;
        _sellRatios.liquidity = liquidity;
        _sellRatios.marketing = marketing;
        _sellRatios.burn = burn;
        _sellRatios.reflectionTax = reflectionTax;
        _sellRatios.total =
            ecosystem +
            liquidity +
            marketing +
            burn +
            reflectionTax;
    }

    function setWallets(
        address payable _marketingWallet,
        address payable _ecosystemWallet,
        address payable _reflectionPool,
        address payable _liquidityReceiver
    ) external onlyOwner {
        marketingWallet = payable(_marketingWallet);
        ecosystemWallet = payable(_ecosystemWallet);
        reflectionPool = payable(_reflectionPool);
        liquidityReceiver = payable(_liquidityReceiver);
    }

    function setContractSwapSettings(bool _enabled) external onlyOwner {
        contractSwapEnabled = _enabled;
    }

    function setSwapSettings(
        uint256 thresholdPercent,
        uint256 thresholdDivisor,
        uint256 amountPercent,
        uint256 amountDivisor
    ) external onlyOwner {
        require(
            amountPercent > 0 && amountDivisor > 0,
            "AmountPercent & amountDivisor must be greater than 0"
        );
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function updateTaxReductionNFT(address _taxReductionNFT)
        external
        onlyOwner
    {
        require(
            _taxReductionNFT != address(this),
            "Tax reduction NFT address cannot be this address"
        );
        taxReductionNFT = TaxReductionNFT(_taxReductionNFT);
    }

    function setNewRouter(address newRouter) external onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(
            address(this),
            _newRouter.WETH()
        );
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(
                address(this),
                _newRouter.WETH()
            );
        } else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled = false) {
            lpPairs[pair] = false;
        } else {
            if (timeSinceLastPair != 0) {
                require(
                    block.timestamp - timeSinceLastPair > 3 days,
                    "Cannot set a new pair this week!"
                );
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
        }
    }

    function setMaxTxPercent(uint256 percent, uint256 divisor)
        external
        onlyOwner
    {
        require(
            (_tTotal * percent) / divisor >= (_tTotal / 1000),
            "Max Transaction amt must be above 0.1% of total supply."
        );
        _maxTxAmount = (_tTotal * percent) / divisor;
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor)
        external
        onlyOwner
    {
        require(
            (_tTotal * percent) / divisor >= (_tTotal / 1000),
            "Max Wallet amt must be above 0.1% of total supply."
        );
        _maxWalletSize = (_tTotal * percent) / divisor;
    }

    function getMaxTX() external view returns (uint256) {
        return _maxTxAmount / (10**_decimals);
    }

    function getMaxWallet() external view returns (uint256) {
        return _maxWalletSize / (10**_decimals);
    }

    function _hasLimits(address from, address to) public view returns (bool) {
        return
            from != owner() &&
            to != owner() &&
            tx.origin != owner() &&
            !_liquidityHolders[to] &&
            !_liquidityHolders[from] &&
            to != DEAD &&
            to != address(0) &&
            from != address(this);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_hasLimits(from, to)) {
            if (!tradingEnabled) {
                revert("Trading not yet enabled!");
            }

            if (lpPairs[from] || lpPairs[to]) {
                require(
                    amount <= _maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
            }
            if (to != currentRouter && !lpPairs[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Transfer amount exceeds the maxWalletSize."
                );
            }
        }

        bool takeFee = true;

        if (_isFeeExcluded[from] || _isFeeExcluded[to]) {
            takeFee = false;
        }

        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function _finalizeTransfer(
        address from,
        address to,
        uint256 amount,
        bool takeFee
    ) internal returns (bool) {
        _tOwned[from] -= amount;

        if (inSwap) {
            return _basicTransfer(from, to, amount);
        }

        uint256 contractTokenBalance = _tOwned[address(this)];
        if (contractTokenBalance >= swapAmount)
            contractTokenBalance = swapAmount;

        if (
            !inSwap &&
            !lpPairs[from] &&
            contractSwapEnabled &&
            contractTokenBalance >= swapThreshold
        ) {
            contractSwap(contractTokenBalance);
        }

        uint256 amountReceived = amount;

        if (takeFee) {
            amountReceived = takeTaxes(from, to, amount);
        }

        _tOwned[to] += amountReceived;

        emit Transfer(from, to, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _tOwned[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getTaxReduction(address from) public returns (uint256) {
        if (
            taxReductionNFT == TaxReductionNFT(DEAD) ||
            _taxRates.sellFee == 0 ||
            taxReductionNFT.getUserTaxReduction(from) > _taxRates.sellFee
        ) {
            return 0;
        } else return taxReductionNFT.getUserTaxReduction(from);
    }

    function takeTaxes(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        uint256 currentFee;
        uint256 feeAmount;
        uint256 amountToReflectionPool;
        uint256 amountToEcosystem;
        uint256 amountToBurn;
        uint256 amountToMarketing;
        uint256 amountToLiquidity;
        uint256 amountToLiquify;
        if (from == lpPair) {
            currentFee = _taxRates.buyFee;
            feeAmount = (amount * currentFee) / staticVals.masterTaxDivisor;
            amountToReflectionPool =
                (feeAmount * _buyRatios.reflectionTax) /
                _buyRatios.total;
            amountToEcosystem =
                (feeAmount * _buyRatios.ecosystem) /
                _buyRatios.total;
            amountToBurn = (feeAmount * _buyRatios.burn) / _buyRatios.total;
            amountToLiquidity =
                (feeAmount * _buyRatios.liquidity) /
                _buyRatios.total;
            amountToMarketing =
                (feeAmount * _buyRatios.marketing) /
                _buyRatios.total;
            amountToLiquify = amountToLiquidity + amountToMarketing;
        } else if (to == lpPair) {
            currentFee = _taxRates.sellFee - getTaxReduction(from);
            feeAmount = (amount * currentFee) / staticVals.masterTaxDivisor;
            amountToReflectionPool =
                (feeAmount * _sellRatios.reflectionTax) /
                _sellRatios.total;
            amountToEcosystem =
                (feeAmount * _sellRatios.ecosystem) /
                _sellRatios.total;
            amountToBurn = (feeAmount * _sellRatios.burn) / _sellRatios.total;
            amountToLiquidity =
                (feeAmount * _sellRatios.liquidity) /
                _sellRatios.total;
            amountToMarketing =
                (feeAmount * _sellRatios.marketing) /
                _sellRatios.total;
            amountToLiquify = amountToLiquidity + amountToMarketing;
        } else {
            currentFee = _taxRates.transferFee;
        }

        if (currentFee == 0) {
            return amount;
        }

        if (amountToLiquify > 0) {
            _tOwned[address(this)] += amountToLiquify;
            emit Transfer(from, address(this), amountToLiquify);
        }

        if (amountToEcosystem > 0) {
            _tOwned[ecosystemWallet] += amountToEcosystem;
            emit Transfer(from, ecosystemWallet, amountToEcosystem);
        }

        if (amountToReflectionPool > 0) {
            _tOwned[reflectionPool] += amountToReflectionPool;
            emit Transfer(from, reflectionPool, amountToReflectionPool);
        }

        if (amountToBurn > 0) {
            _tTotal -= amountToBurn;
            emit Transfer(from, DEAD, amountToBurn);
        }

        return amount - feeAmount;
    }

    function contractSwap(uint256 numTokensToSwap) internal swapping {
        if (_buyRatios.total + _sellRatios.total == 0) {
            return;
        }

        if (
            _allowances[address(this)][address(dexRouter)] != type(uint256).max
        ) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 amountToLiquify = ((numTokensToSwap *
            (_buyRatios.liquidity + _sellRatios.liquidity)) /
            (_buyRatios.liquidity +
                _sellRatios.liquidity +
                _buyRatios.marketing +
                _sellRatios.marketing)) / 2;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            numTokensToSwap - amountToLiquify,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance;
        uint256 amountETHLiquidity = ((amountETH *
            (_sellRatios.liquidity + _buyRatios.liquidity)) /
            (_buyRatios.liquidity +
                _sellRatios.liquidity +
                _buyRatios.marketing +
                _sellRatios.marketing));

        if (amountToLiquify > 0) {
            dexRouter.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }

        if (address(this).balance > 0) {
            amountETH = address(this).balance;
            marketingWallet.transfer(address(this).balance);
        }
    }

    function multiSendTokens(
        address[] memory accounts,
        uint256[] memory amounts
    ) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i] * 10**_decimals);
        }
    }

    function multiSendPercents(
        address[] memory accounts,
        uint256[] memory percents,
        uint256[] memory divisors
    ) external {
        require(
            accounts.length == percents.length &&
                percents.length == divisors.length,
            "Lengths do not match."
        );
        for (uint8 i = 0; i < accounts.length; i++) {
            require(
                _tOwned[msg.sender] >= (_tTotal * percents[i]) / divisors[i]
            );
            _transfer(
                msg.sender,
                accounts[i],
                (_tTotal * percents[i]) / divisors[i]
            );
        }
    }
}