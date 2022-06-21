/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IBEP20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IPancakeRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IPancakeRouter02 is IPancakeRouter01 {
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


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


contract DividendDistributor {
    address _token;

    struct Shareholder {
        uint256 numShares;
        uint256 totalExcluded;
        uint256 lastClaimed;
    }

    IBEP20 BUSD;
    IBEP20 WBNB;
    IPancakeRouter02 router;

    mapping(address => Shareholder) public shareholders;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**18);

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router, address _WBNB, address _BUSD) {

        require(_router != address(0));
        require(_WBNB != address(0));
        require(_BUSD != address(0));

        router = IPancakeRouter02(_router);
        WBNB = IBEP20(_WBNB);
        BUSD = IBEP20(_BUSD);
        _token = msg.sender;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 numShares)
        external
        onlyToken
    {
        if (shareholders[shareholder].numShares > 0) {
            distributeDividend(shareholder);
        }

        totalShares =
            (totalShares - shareholders[shareholder].numShares) +
            numShares;
        shareholders[shareholder].numShares = numShares;
        shareholders[shareholder].totalExcluded = getCumulativeDividends(
            shareholders[shareholder].numShares
        );
    }

    function deposit() external payable onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)) - (balanceBefore);

        totalDividends = totalDividends + (amount);
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * (amount)) / (totalShares));
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholders[shareholder].lastClaimed + minPeriod <
            block.timestamp && // past min period
            getUnpaidEarnings(shareholder) > minDistribution; // has min amount
    }

    function distributeDividend(address shareholder) internal {
        if (shareholders[shareholder].numShares == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + (amount);

            BUSD.transfer(shareholder, amount);

            shareholders[shareholder].lastClaimed = block.timestamp;
            shareholders[shareholder].totalExcluded = getCumulativeDividends(
                shareholders[shareholder].numShares
            );
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shareholders[shareholder].numShares == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shareholders[shareholder].numShares
        );
        uint256 shareholderTotalExcluded = shareholders[shareholder]
            .totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 numShares)
        internal
        view
        returns (uint256)
    {
        return
            (numShares * (dividendsPerShare)) /
            (dividendsPerShareAccuracyFactor);
    }
}


contract ClearToken is IBEP20, Auth {
    string private constant _name = "Clear";
    string private constant _symbol = "CLR";

    uint8 private constant _decimals = 18;

    uint256 public constant MAX_INT = type(uint128).max;

    address public migrationBank;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public _maxTxAmount;
    uint256 public liquidityFee = 100;
    uint256 public reflectionFee = 100;
    uint256 public marketingFee = 300;
    uint256 public feeDenominator = 10000;
    uint256 public swapThreshold;
    uint256 public sellDenom = 1800;
    uint256 public sellDenomDays = 0;

    uint256 private totalFee = 500;
    uint256 private targetLiquidity = 25;
    uint256 private targetLiquidityDenominator = 100;

    uint256 private _totalSupply;

    address public BUSD;
    address public WBNB;
    address public oldCLR;
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public pair;
    address public distributorAddress;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;

    bool public swapEnabled = true;
    bool public openMigrate = true;
    bool inSwap;

    IPancakeRouter02 public router;
    DividendDistributor distributor;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address oldToken,
        address _dexRouter,
        address _WBNB,
        address _BUSD,
        address _migrationBank
    ) payable Auth(msg.sender) {
        require(_dexRouter != address(0)); // dev: router 0
        require(_WBNB != address(0)); // dev: WBNB 0
        require(_BUSD != address(0)); // dev: BUSD 0
        require(oldToken != address(0)); // dev: oldToken 0

        oldCLR = oldToken;
        WBNB = _WBNB;
        BUSD = _BUSD;

        router = IPancakeRouter02(_dexRouter);
        pair = IPancakeFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(_dexRouter, _WBNB, _BUSD);
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = address(this);
        marketingFeeReceiver = address(this);

        oldCLR = oldToken;

        IBEP20 old = IBEP20(oldCLR);

        _totalSupply = old.totalSupply();

        // TODO: on deployment, must have a migrationBank from a multi-sig wallet
        migrationBank = _migrationBank == address(0)
            ? _migrationBank
            : 0x69d8Efd74c6A86696175e109f6c1cDeb966Db0B2;

        // mint the total supply to the migration bank
        _balances[migrationBank] = _totalSupply;

        _maxTxAmount = _totalSupply / 400; // 0.25%
        swapThreshold = _totalSupply / 2000; // 0.005%

        _allowances[address(this)][_dexRouter] = MAX_INT;
        _allowances[address(this)][pair] = MAX_INT;

        emit Transfer(address(0), migrationBank, _totalSupply);
    }

    function mint(address account, uint256 amount) internal {
        _balances[account] = _balances[account] + amount;
        _totalSupply = _totalSupply + amount;
    }

    function adminMint(address account, uint256 amount) external authorized {
        mint(account, amount);
    }

    function setOpenMigrate(bool gate) external authorized {
        openMigrate = gate;
    }

    function burn(uint256 amount) external {
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _totalSupply = _totalSupply - amount;
    }

    function setRouter(IPancakeRouter02 value) external authorized {
        router = value;
    }

    function setMarketingWalletReceiver(address value) external authorized {
        marketingFeeReceiver = value;
    }

    function setAutoLiquidityReceiver(address value) external authorized {
        autoLiquidityReceiver = value;
    }

    receive() external payable {}

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
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
        // Check allowance only if the msg.sender does not own the tokens.
        if (sender != msg.sender) {
            require(
                _allowances[sender][msg.sender] >= amount,
                "Insufficient allowance"
            );
        }

        if (_allowances[sender][msg.sender] != MAX_INT) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        checkTxLimit(sender, amount);

        if (shouldSwapBack()) {
            swapBack();
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, amount)
            : amount;

        _balances[recipient] = _balances[recipient] + (amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + (amount);
        return true;
    }

    function migrate(uint256 amount) external {
        require(openMigrate == true); // Migration must be open

        IBEP20 old = IBEP20(oldCLR);
        // Tokens must have been burned
        require(
            old.transferFrom(msg.sender, DEAD, amount) == true,
            "Failed to burn old token"
        );

        _basicTransfer(migrationBank, msg.sender, amount);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function setSellDenomDays(uint256 value) external authorized {
        sellDenomDays = value;
    }

    function setSellDenom(uint256 value) external authorized {
        sellDenom = value;
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = (amount * totalFee) / (feeDenominator);

        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount - (feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = (swapThreshold * (liquidityFee)) /
            (totalFee) /
            (2);
        uint256 amountToSwap = swapThreshold - (amountToLiquify);

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

        uint256 amountBNB = address(this).balance - (balanceBefore);

        uint256 totalBNBFee = totalFee - (liquidityFee / (2));

        uint256 amountBNBLiquidity = (amountBNB * (liquidityFee)) /
            (totalBNBFee) /
            (2);

        uint256 amountBNBReflection = (amountBNB * (reflectionFee)) /
            (totalBNBFee);

        uint256 amountBNBMarketing = (amountBNB * (marketingFee)) /
            (totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);

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

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && holder != pair); // dev: "Cannot be token contract or liquidity pair contract"
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function _setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _feeDenominator
    ) internal {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee + _reflectionFee + _marketingFee;
        feeDenominator = _feeDenominator;
    }

    function setFees(
        uint256 liq,
        uint256 reflection,
        uint256 market,
        uint256 feeDenom
    ) external authorized {
        require(liq <= feeDenom / 5);
        require(reflection <= feeDenom / 5);
        require(market <= feeDenom / 5);

        liquidityFee = liq;
        reflectionFee = reflection;
        marketingFee = market;

        totalFee = liquidityFee + reflectionFee + marketingFee;

        feeDenominator = feeDenom;

    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        authorized
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            _totalSupply -
            (balanceOf(DEAD)) -
            (balanceOf(0x0000000000000000000000000000000000000000));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return (accuracy * (balanceOf(pair) * (2))) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    // TODO: TESTING ONLY FUNCTIONS. REMOVE BEFORE DEPLOYMENT.

    function testIsDividendExemptAccounts(address addr)
        public
        view
        returns (bool)
    {
        return isDividendExempt[addr];
    }

    function testIsFeeExemptAccounts(address addr) public view returns (bool) {
        return isFeeExempt[addr];
    }
}