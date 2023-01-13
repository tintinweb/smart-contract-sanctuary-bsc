/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT

// WEBSITE: https://superstake.club/
// TELEGRAM: https://t.me/OfficialSuperStake
// CEO: https://t.me/stevelabsaccelerator


pragma solidity 0.8.15;

interface BEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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
}

interface InterfaceLP {
    function sync() external;
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    address public _token;
    address public WBNB;
    address[] public shareholders;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    BEP20 public REWARD;
    IDEXRouter public router;

    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**8);

    uint256 public currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(
        address _router,
        BEP20 reward,
        address token
    ) {
        REWARD = reward;
        router = IDEXRouter(_router);
        _token = token;
        WBNB = router.WETH();
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }
        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }
        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = REWARD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);
        uint256 amount = REWARD.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) {
            return;
        }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }
            gasUsed = (gasUsed + gasLeft) - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address shareholder) external onlyToken {
        distributeDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }
        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function setDividendTokenAddress(address newToken) external onlyToken {
        REWARD = BEP20(newToken);
    }
}

contract SUPERSTAKE is BEP20 {
    IDEXRouter public router =
        IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    DividendDistributor public distributor;
    InterfaceLP public pairContract;
    //token data
    string public constant name = "SUPERSTAKE";
    string public constant symbol = "SUPERSTAKE";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 2000000 * 10**decimals;
    //mappings
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) pairs;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) isDividendExempt;
    //uint256
    //BUY FEES
    uint256 public liquidityFee = 10; // 1% autoliquidify
    uint256 public marketingFee = 20; // 2% marketing
    uint256 public stakePoolFee = 10; // 1% stakePool
    uint256 public reflectionFee = 20; // 2% reflection supercake
    uint256 public burnFee = 10; // 1% BURN
    uint256 public totalBuyFee =
        marketingFee + reflectionFee + liquidityFee + burnFee + stakePoolFee;
    //SELL FEES
    uint256 public sellLiquidityFee = 10; // 1% autoliquidify
    uint256 public sellMarketingFee = 20; // 2% marketing
    uint256 public sellStakePoolFee = 10; // 1% stakePool
    uint256 public sellReflectionFee = 20; // 2% reflection supercake
    uint256 public sellBurnFee = 10; // 1% BURN
    uint256 public totalSellFee =
        sellLiquidityFee +
            sellMarketingFee +
            sellStakePoolFee +
            sellReflectionFee +
            sellBurnFee;

    uint256 public constant feeDenominator = 1000;
    uint256 distributorGas = 300000;
    uint256 transferMultiplier = 25;
    uint256 public swapThreshold = totalSupply / 5000;
    uint256 public lastSync;
    uint256 public launchedAt;
    //addresses
    address public marketingFeeReceiver;
    address public StakePoolReceiver;
    address private _owner;
    address public WBNB = router.WETH();
    //bools
    bool public tradingOpen = false;
    bool public burnEnabled = true;
    bool public swapEnabled = true;
    bool inSwap;
    //modifiers
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        _;
    }

    //constructor
    constructor() {
        _owner = msg.sender;
        distributor = new DividendDistributor(
            address(router),
            BEP20(0x2f3b3400427C359F9E4559C4F41C6e6e2D254ACa),
            address(this)
        );
        address pair = IDEXFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        pairContract = InterfaceLP(pair);
        lastSync = block.timestamp;

        marketingFeeReceiver = msg.sender;
        StakePoolReceiver = msg.sender;

        pairs[pair] = true;

        isFeeExempt[msg.sender] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;

        _allowances[address(this)][address(router)] = totalSupply;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        emit OwnershipTransferred(address(0), _owner);
    }

    //functions
    receive() external payable {}

    function owner() public view returns (address) {
        return _owner;
    }

    function allowance(address holder, address spender)
        external
        view
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

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[sender][msg.sender] =
            _allowances[sender][msg.sender] -
            amount;

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient Balance");
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (sender != owner() && recipient != owner()) {
            require(tradingOpen, "Trading not open yet");
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        balanceOf[sender] = balanceOf[sender] - amount;

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient])
            ? amount
            : takeFee(sender, amount, recipient);

        balanceOf[recipient] = balanceOf[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient Balance");
        balanceOf[sender] = balanceOf[sender] - amount;
        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _isSell(bool a) internal view returns (uint256) {
        //extra marketing fee
        return a ? totalSellFee : totalBuyFee;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= balanceOf[account]);
        balanceOf[account] = balanceOf[account] - amount;
        totalSupply = totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function famount(
        uint256 amount,
        uint256 fee,
        uint256 multi
    ) internal pure returns (uint256) {
        return ((amount * (fee)) * multi) / (feeDenominator * 100);
    }

    function takeFee(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        uint256 totalFee = _isSell(pairs[recipient]);
        if (amount == 0 || totalFee == 0) {
            return amount;
        }

        uint256 multiplier = (pairs[recipient] || pairs[sender])
            ? 100
            : transferMultiplier;

        uint256 feeAmount = famount(amount, totalFee, multiplier);
        uint256 BF = pairs[recipient] ? sellBurnFee : burnFee;
        uint256 burnTokens = (feeAmount * BF) / totalFee;
        uint256 contractTokens = feeAmount - burnTokens;

        if (contractTokens > 0) {
            _txTransfer(sender, address(this), contractTokens);
        }

        if (burnTokens > 0) {
            totalSupply = totalSupply - burnTokens;
            emit Transfer(sender, address(0), burnTokens);
        }

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, balanceOf[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, balanceOf[recipient])
            {} catch {}
        }
        try distributor.process(distributorGas) {} catch {}

        return amount - feeAmount;
    }

    function _txTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            !pairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            balanceOf[address(this)] >= swapThreshold;
    }

    function clearStuckToken(address tokenAddress, uint256 tokens)
        external
        onlyOwner
        returns (bool success)
    {
        require(tokenAddress != address(this), "Cannot withdraw native token");
        if (pairs[tokenAddress]) {
            //tokens from auto liquidify
            require(
                block.timestamp > launchedAt + 500 days,
                "Locked for 1 year"
            );
        }

        if (tokens == 0) {
            tokens = BEP20(tokenAddress).balanceOf(address(this));
        }

        emit clearToken(tokenAddress, tokens);

        return BEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    // switch Trading
    function tradingEnable() external onlyOwner {
        require(!tradingOpen, "Trading already open"); //trade only can change one time
        tradingOpen = true;
        launchedAt = block.timestamp;
        emit config_TradingStatus(tradingOpen);
    }

    function disableBurns() external onlyOwner {
        burnEnabled = false;
    }

    function swapBack() internal swapping {
        uint256 totalETHFee = totalSellFee - sellBurnFee;

        uint256 amountToLiquify = (swapThreshold * sellLiquidityFee) /
            (totalETHFee * 2);

        uint256 amountToSwap = swapThreshold - amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        totalETHFee = totalETHFee - (sellLiquidityFee / 2);

        uint256 amountBNBLiquidity = (amountBNB * sellLiquidityFee) /
            (totalETHFee * 2);

        uint256 amountBNBMarketing = (amountBNB * sellMarketingFee) /
            totalETHFee;

        uint256 amountBNBStakePool = (amountBNB * sellStakePoolFee) /
            totalETHFee;

        uint256 amountBNBReflection = (amountBNB * sellReflectionFee) /
            totalETHFee;

        if (amountBNBMarketing > 0) {
            payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        }
        if (amountBNBStakePool > 0) {
            payable(StakePoolReceiver).transfer(amountBNBStakePool);
        }

        if (amountBNBReflection > 0) {
            try distributor.deposit{value: amountBNBReflection}() {} catch {}
        }

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function setPair(address _pair, bool io) public onlyOwner {
        pairs[_pair] = io;
    }

    function manage_FeeExempt(address[] calldata addresses, bool status)
        external
        onlyOwner
    {
        require(
            addresses.length < 501,
            "GAS Error: max limit is 500 addresses"
        );
        for (uint256 i = 0; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
            emit Wallet_feeExempt(addresses[i], status);
        }
    }

    function update_fees() internal {
        require(
            (totalBuyFee + totalSellFee * (200)) / 100 <= 150,
            "Buy+Sell tax cannot be more than 15%"
        );

        emit UpdateFee(
            uint8((totalBuyFee * 100) / 100),
            uint8((totalSellFee * 100) / 100)
        );
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _stakePoolFee,
        uint256 _burnFee,
        uint256 _marketingFee,
        uint256 _sellLiquidityFee,
        uint256 _sellReflectionFee,
        uint256 _sellStakePoolFee,
        uint256 _sellBurnFee,
        uint256 _sellMarketingFee
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        reflectionFee = _reflectionFee;
        stakePoolFee = _stakePoolFee;
        burnFee = _burnFee;

        totalBuyFee =
            _liquidityFee +
            _marketingFee +
            _stakePoolFee +
            _reflectionFee +
            _burnFee;

        sellLiquidityFee = _sellLiquidityFee;
        sellReflectionFee = _sellReflectionFee;
        sellStakePoolFee = _sellStakePoolFee;
        sellBurnFee = _sellBurnFee;
        sellMarketingFee = _sellMarketingFee;

        totalSellFee =
            _sellLiquidityFee +
            _sellReflectionFee +
            _sellStakePoolFee +
            _sellBurnFee +
            _sellMarketingFee;
        update_fees();
    }

    function setFeeReceivers(
        address _marketingFeeReceiver,
        address _stakePoolReceiver
    ) external onlyOwner {
        require(
            _marketingFeeReceiver != address(0),
            "Marketing fee address cannot be zero address"
        );
        require(
            _stakePoolReceiver != address(0),
            "StalePool fee address cannot be zero address"
        );
        marketingFeeReceiver = _marketingFeeReceiver;
        StakePoolReceiver = _stakePoolReceiver;
        emit Set_Wallets(marketingFeeReceiver, StakePoolReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount < (totalSupply / 10), "Amount too high");

        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit config_SwapSettings(swapThreshold, swapEnabled);
    }

    function multiTransfer(
        address[] calldata addresses,
        uint256[] calldata tokens
    ) external {
        require(isFeeExempt[msg.sender]);
        address from = msg.sender;

        require(
            addresses.length < 501,
            "GAS Error: max limit is 500 addresses"
        );
        require(
            addresses.length == tokens.length,
            "Mismatch between address and token count"
        );

        uint256 SCCC = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf[from] >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
        }
    }

    function SuperBurn(uint256 percent) public onlyOwner returns (bool) {
        require(percent <= 200, "May not nuke more than 2% of tokens in LP");
        require(block.timestamp > lastSync + 5 minutes, "Too soon");
        require(burnEnabled, "Burns are disabled");

        uint256 lp_tokens = this.balanceOf(address(pairContract));
        uint256 lp_burn = (lp_tokens * percent) / 10_000;

        if (lp_burn > 0) {
            _burn(address(pairContract), lp_burn);
            pairContract.sync();
            return true;
        }

        return false;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 3000000);
        distributorGas = gas;
    }

    function setDividendToken(address _newContract) external onlyOwner {
        require(_newContract != address(0));
        distributor.setDividendTokenAddress(_newContract);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
    event UpdateFee(uint8 Buy, uint8 Sell);
    event Wallet_feeExempt(address Wallet, bool Status);
    event clearToken(address TokenAddressCleared, uint256 Amount);
    event Set_Wallets(address MarketingWallet, address StakeWallet);
    event config_TradingStatus(bool Status);
    event config_SwapSettings(uint256 Amount, bool Enabled);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}