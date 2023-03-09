/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IBEP20 {
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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /*
      Authorize address. Owner only
     */
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    /**
     * Remove address authorization. Owner only
     */
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        authorizations[account] = true;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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
    using SafeMath for uint256;

    address _token;
    address _rewardToken_address;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // EARN
    IBEP20 RWRD = IBEP20(_rewardToken_address); //BUSD BSC Token address
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB address
    IDEXRouter router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**12);

    uint256 currentIndex;

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

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //router address
        _token = msg.sender;
    }

    function setRWRDToken(address _newToken) external onlyToken {
        _rewardToken_address = _newToken;       
        
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

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
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

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
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
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
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

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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
}

//////////////////////////////Token Start//////////////////////////////

contract REWARD_TOKEN is IBEP20, Auth {
    using SafeMath for uint256;

    // Addresses
    address RWRD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //BUSD BSC Token address on launch
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB address
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address _rewardToken_address = RWRD;

    // These are owner by default
    address private autoLiquidityReceiver;
    address private DEVFeeReceiver;

    // Name and symbol
    string constant _name = "RWRD_TOK";
    string constant _symbol = "RWRD";
    uint8 constant _decimals = 18;

    // Total supply
    uint256 _totalSupply = 1000000000 * (10**_decimals); // 1,000,000,000

    // Max wallet and TX
    uint256 public _maxBuyTxAmount = (_totalSupply * 700) / 10000; // 70,000,000 Tokens on launch
    uint256 public _maxSellTxAmount = (_totalSupply * 700) / 10000; // 70,000,000 Tokens on launch
    uint256 public _maxWalletToken = (_totalSupply * 700) / 10000; // 70,000,000 Tokens on launch

    // Buy Fees
    uint256 public liquidityFeeBuy = 3;
    uint256 public reflectionFeeBuy = 3;
    uint256 public DEVFeeBuy = 1;
    uint256 public totalFeeBuy =
        liquidityFeeBuy.add(reflectionFeeBuy).add(DEVFeeBuy);

    // Sell fees
    uint256 public liquidityFeeSell = 3;
    uint256 public reflectionFeeSell = 7;
    uint256 public DEVFeeSell = 3;
    uint256 public totalFeeSell =
        liquidityFeeSell.add(reflectionFeeSell).add(DEVFeeSell);

    // Mappings
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isTimelockExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) public isBlacklisted;

    // Fee variables
    uint256 liquidityFee;
    uint256 reflectionFee;
    uint256 DEVFee;
    uint256 totalFee;
    uint256 feeDenominator = 100;

    // Dead blocks
    uint256 deadBlocks = 3;

    // Sell amount of tokens when a sell takes place
    uint256 public swapThreshold = (_totalSupply * 200) / 10000; // 2% of supply

    // Liquidity
    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 30;
    mapping(address => uint256) private cooldownTimer;

    // Other variables
    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    bool public tradingOpen = false;
    bool public swapEnabled = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /* Token constructor */
    constructor() Auth(msg.sender) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //ROUTER ADDRESS
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));
        distributor.setRWRDToken(RWRD); //Set RWRD in distributor on launch

        // Should be the owner wallet/token distributor
        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;
        isTxLimitExempt[_presaler] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        // Exempt from dividend
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Set the liq receiver to the owner as default
        autoLiquidityReceiver = msg.sender;
        DEVFeeReceiver = msg.sender;

        _balances[_presaler] = _totalSupply;
        emit Transfer(address(0), _presaler, _totalSupply);
    }

    receive() external payable {}

    function setNewRWRDToken(address _newToken) public authorized {
        RWRD = _newToken;
        distributor.setRWRDToken(_newToken);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
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
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    // settting the max wallet in percentages
    // NOTE: 1% = 100
    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        _maxWalletToken = _totalSupply.mul(maxWallPercent).div(10000);
    }

    // Main transfer function
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        // Check if trading is enabled
        if (!authorizations[sender] && !authorizations[recipient]) {
            require(tradingOpen, "Trading not enabled yet");
        }

        // Check if address is blacklisted
        require(
            !isBlacklisted[recipient] && !isBlacklisted[sender],
            "Address is blacklisted"
        );

        // Check if buying or selling
        bool isSell = recipient == pair;

        // Set buy or sell fees
        setCorrectFees(isSell);

        // Check max wallet
        checkMaxWallet(sender, recipient, amount);

        // Buycooldown
        checkBuyCooldown(sender, recipient);

        // Checks maxTx
        checkTxLimit(sender, amount, recipient, isSell);

        // Check if we should do the swapback
        if (shouldSwapBack()) {
            swapBack();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, amount)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    // Do a normal transfer
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Set the correct fees for buying or selling
    function setCorrectFees(bool isSell) internal {
        if (isSell) {
            liquidityFee = liquidityFeeSell;
            reflectionFee = reflectionFeeSell;
            DEVFee = DEVFeeSell;
            totalFee = totalFeeSell;
        } else {
            liquidityFee = liquidityFeeBuy;
            reflectionFee = reflectionFeeBuy;
            DEVFee = DEVFeeBuy;
            totalFee = totalFeeBuy;
        }
    }

    // Check for maxTX
    function checkTxLimit(
        address sender,
        uint256 amount,
        address recipient,
        bool isSell
    ) internal view {
        if (recipient != owner) {
            if (isSell) {
                require(
                    amount <= _maxSellTxAmount ||
                        isTxLimitExempt[sender] ||
                        isTxLimitExempt[recipient],
                    "TX Limit Exceeded"
                );
            } else {
                require(
                    amount <= _maxBuyTxAmount ||
                        isTxLimitExempt[sender] ||
                        isTxLimitExempt[recipient],
                    "TX Limit Exceeded"
                );
            }
        }
    }

    // Check buy cooldown
    function checkBuyCooldown(address sender, address recipient) internal {
        if (
            sender == pair && buyCooldownEnabled && !isTimelockExempt[recipient]
        ) {
            require(
                cooldownTimer[recipient] < block.timestamp,
                "Please wait between two buys"
            );
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }

    // Check maxWallet
    function checkMaxWallet(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (
            !authorizations[sender] &&
            recipient != owner &&
            recipient != address(this) &&
            recipient != address(DEAD) &&
            recipient != pair &&
            recipient != DEVFeeReceiver &&
            recipient != autoLiquidityReceiver
        ) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= _maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }
    }

    // Check if sender is not feeExempt
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    // Get total fee's or multiplication of fees
    function getTotalFee(bool selling) public view returns (uint256) {
        if (launchedAt + deadBlocks >= block.number) {
            return feeDenominator.sub(1);
        }
        if (selling) {}
        return totalFee;
    }

    // Take  total Fee
    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount;

        feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    // Check if we should sell tokens
    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    // switch Trading
    function LaunchToken() public authorized {
        tradingOpen = false;
        swapEnabled = false;

        launch();
    }

    function setTradingStatus(bool _status) public authorized {
        tradingOpen = _status;
    }

    // Enable/disable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    // Blacklist/unblacklist an address
    function blacklistAddress(address _address, bool _value) public authorized {
        isBlacklisted[_address] = _value;
    }

    // Main swapback to sell tokens for WBNB
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;
        uint256 amountToLiquify = swapThreshold
            .mul(dynamicLiquidityFee)
            .div(totalFee)
            .div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(
            totalBNBFee
        );
        uint256 amountBNBDEV = amountBNB.mul(DEVFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        (
            bool successDEV, /* bytes memory data */

        ) = payable(DEVFeeReceiver).call{value: amountBNBDEV, gas: 30000}("");

        require(successDEV, "DEV receiver rejected RWRD transfer");

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    // Trigger a manual buyback...maybe
    function BuynBURN(uint256 bnbAmountInWei) external authorized {
        buyTokens(bnbAmountInWei, DEAD);
    }

    // Buy amount of tokens with bnb from the contract
    function buyTokens(uint256 bnbAmountInWei, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmountInWei
        }(0, path, to, block.timestamp);
    }

    // Check when the token is launched
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    // Set the launchedAt to token launch
    function launch() internal {
        launchedAt = block.number;
    }

    // Set max TX
    function setBuyTxLimitInPercent(
        uint256 maxBuyTxPercent,
        uint256 maxSellTxPercent
    ) external authorized {
        _maxBuyTxAmount = _totalSupply.mul(maxBuyTxPercent).div(10000); //#+18
        _maxSellTxAmount = _totalSupply.mul(maxSellTxPercent).div(10000); //#+18
    }

    // Exempt from dividend
    function setIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    // Exempt from fee
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    // Exempt from max TX
    function setIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    // Exempt from buy CD
    function setIsTimelockExempt(address holder, bool exempt)
        external
        authorized
    {
        isTimelockExempt[holder] = exempt;
    }

    // Set our buy fees
    function setBuyFees(
        uint256 _liquidityFeeBuy,
        uint256 _reflectionFeeBuy,
        uint256 _DEVFeeBuy,
        uint256 _feeDenominator
    ) external authorized {
        liquidityFeeBuy = _liquidityFeeBuy;
        reflectionFeeBuy = _reflectionFeeBuy;
        DEVFeeBuy = _DEVFeeBuy;
        totalFeeBuy = _liquidityFeeBuy.add(_reflectionFeeBuy).add(_DEVFeeBuy);
        feeDenominator = _feeDenominator;
    }

    // Set our sell fees
    function setSellFees(
        uint256 _liquidityFeeSell,
        uint256 _reflectionFeeSell,
        uint256 _DEVFeeSell,
        uint256 _feeDenominator
    ) external authorized {
        liquidityFeeSell = _liquidityFeeSell;
        reflectionFeeSell = _reflectionFeeSell;
        DEVFeeSell = _DEVFeeSell;
        totalFeeSell = _liquidityFeeSell.add(_reflectionFeeSell).add(
            _DEVFeeSell
        );
        feeDenominator = _feeDenominator;
    }

    // Set the FEE receivers
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _DEVFeeReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        DEVFeeReceiver = _DEVFeeReceiver;
    }

    // Set swapBack settings
    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        authorized
    {
        swapEnabled = _enabled;
        swapThreshold = (_totalSupply * _amount) / 10000;
    }

    // Set target liquidity
    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    // Send BNB to DEVwallet
    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(DEVFeeReceiver).transfer(contractETHBalance);
    }

    // Set criteria for auto distribution
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    // claim dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    // Set gas for distributor
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    // Get the circulatingSupply
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    // Get the liquidity backing
    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    // Get if we are over liquified or not
    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}