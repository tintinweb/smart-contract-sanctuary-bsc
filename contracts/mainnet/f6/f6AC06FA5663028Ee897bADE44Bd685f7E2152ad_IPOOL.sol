/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "NOT AN OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface Irouter {
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
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address _user) external;

    function getPaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function getUnpaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function totalDistributed() external view returns (uint256);
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address WBNB;
    Irouter router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**18);

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
        router = Irouter(_router);
        WBNB = router.WETH();
        _token = msg.sender;
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
        uint256 amount = msg.value;
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
            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address _user) public {
        distributeDividend(_user);
    }

    function getPaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
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

contract IPOOL is IBEP20, Ownable {
    using SafeMath for uint256;

    string constant _name = "Infinity Pool";
    string constant _symbol = "IPOOL";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 100 * 10**9 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isSniper;

    Irouter public router;
    address public pair;
    address public WBNB;
    DividendDistributor distributor;
    address public distributorAddress;

    address public autoLiquidityReceiver;
    address public marketFeeReceiver;
    address public poolFeeReceiver;

    // buy tax fee
    uint256 reflectionFeeOnBuying = 0;
    uint256 liquidityFeeOnBuying = 20;
    uint256 poolFeeOnBuying = 30;
    uint256 marketFeeOnBuying = 50;

    // sell tax fee
    uint256 reflectionFeeOnSelling = 0;
    uint256 liquidityFeeOnSelling = 50;
    uint256 poolFeeOnSelling = 300;
    uint256 marketFeeOnSelling = 50;

    // normal tax fee
    uint256 reflectionFee = 0;
    uint256 liquidityFee = 0;
    uint256 devFee = 0;
    uint256 marketFee = 0;

    // current tx fee contract use
    uint256 _reflectionFee;
    uint256 _liquidityFee;
    uint256 _poolFee;
    uint256 _marketFee;

    // counters for swaping
    uint256 _accumulatedReflection;
    uint256 _accumulatedLiquidity;
    uint256 _accumulatedPool;
    uint256 _accumulatedMarket;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    uint256 public feeDenominator = 1000;
    uint256 public swapThreshold = _totalSupply / 2000; // 0.005%
    uint256 distributorGas = 500000;

    bool public swapEnabled;
    bool public tradingOpen;
    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
    ) Ownable(msg.sender) {
        router = Irouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//router address
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(0x10ED43C718714eb63d5aA57B78B54704E256024E);//router address
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true; 

        autoLiquidityReceiver = msg.sender;
        marketFeeReceiver = payable(0x374b78b464649bdC265657F4c5f14bd59b0e7372);// market wallet
        poolFeeReceiver =  payable(0xde847D79729E9DF1144B00631CeaBA017A67AaE4);//pool wallet

        approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, _totalSupply);//router address
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
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
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!isSniper[sender], "Sniper detected");
        require(!isSniper[recipient], "Sniper detected");
        if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
            // trading disable till launch
            if (!tradingOpen) {
                require(
                    sender != pair && recipient != pair,
                    "Trading is not enabled yet"
                );
            }

        }
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            // buying handler
            if (sender == pair) { 
                setBuyFee();
            }
            // selling handler
            else if (recipient == pair) { 
                setSellFee();
            }
            // wallet to wallet handler
            else {
                setNormalFee();
            }

            _feeTransfer(sender, recipient, amount);
        }

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _feeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 transferAmount = amount.sub(
            amount
                .mul(
                    _reflectionFee
                        .add(_liquidityFee)
                        .add(_poolFee)
                        .add(_marketFee) 
                )
                .div(feeDenominator)
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        if (_reflectionFee > 0) _takeReflectionFee(sender, amount);

        if (_liquidityFee > 0) _takeLiquidityFee(sender, amount);

        if (_poolFee > 0) _takePoolFee(sender, amount);

        if (_marketFee > 0) _takeMarketFee(sender, amount); 
    }

    function _takeReflectionFee(address sender, uint256 amount) private {
        uint256 reflectionFeeAmount;
        reflectionFeeAmount = amount.mul(_reflectionFee).div(feeDenominator);
        _accumulatedReflection = _accumulatedReflection.add(
            reflectionFeeAmount
        );
        _balances[address(this)] = _balances[address(this)].add(
            reflectionFeeAmount
        );
        emit Transfer(sender, address(this), reflectionFeeAmount);
    }

    function _takeLiquidityFee(address sender, uint256 amount) private {
        uint256 liquidityFeeAmount;
        liquidityFeeAmount = amount.mul(_liquidityFee).div(feeDenominator);
        _accumulatedLiquidity = _accumulatedLiquidity.add(liquidityFeeAmount);
        _balances[address(this)] = _balances[address(this)].add(
            liquidityFeeAmount
        );
        emit Transfer(sender, address(this), liquidityFeeAmount);
    }

    function _takePoolFee(address sender, uint256 amount) private {
        uint256 devFeeAmount;
        devFeeAmount = amount.mul(_poolFee).div(feeDenominator);
        _accumulatedPool = _accumulatedPool.add(devFeeAmount);
        _balances[address(this)] = _balances[address(this)].add(devFeeAmount);
        emit Transfer(sender, address(this), devFeeAmount);
    }

    function _takeMarketFee(address sender, uint256 amount) private {
        uint256 marketFeeAmount;
        marketFeeAmount = amount.mul(_marketFee).div(feeDenominator);
        _accumulatedMarket = _accumulatedMarket.add(marketFeeAmount);
        _balances[address(this)] = _balances[address(this)].add(
            marketFeeAmount
        );
        emit Transfer(sender, address(this), marketFeeAmount);
    }

    function setBuyFee() private {
        _reflectionFee = reflectionFeeOnBuying;
        _liquidityFee = liquidityFeeOnBuying;
        _poolFee = poolFeeOnBuying;
        _marketFee = marketFeeOnBuying; 
    }

    function setSellFee() private {
        _reflectionFee = reflectionFeeOnSelling;
        _liquidityFee = liquidityFeeOnSelling;
        _poolFee = poolFeeOnSelling;
        _marketFee = marketFeeOnSelling; 
    }

    function setNormalFee() private {
        _reflectionFee = reflectionFee;
        _liquidityFee = liquidityFee;
        _poolFee = devFee;
        _marketFee = marketFee; 
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 swapDivider = _accumulatedLiquidity
            .add(_accumulatedReflection)
            .add(_accumulatedPool)
            .add(_accumulatedMarket);
        uint256 halfLiquidity = _accumulatedLiquidity.div(2);
        uint256 amountToSwap = swapThreshold.sub(halfLiquidity);

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

        uint256 amountBNBLiquidity = amountBNB.mul(halfLiquidity).div(
            swapDivider
        );
        uint256 amountBNBReflection = amountBNB.mul(_accumulatedReflection).div(
            swapDivider
        );
        uint256 amountBNBDev = amountBNB.mul(_accumulatedPool).div(
            swapDivider
        );
        uint256 amountBNBMarketing = amountBNB
            .sub(amountBNBLiquidity)
            .sub(amountBNBReflection)
            .sub(amountBNBDev);

        payable(marketFeeReceiver).transfer(amountBNBMarketing);
        payable(poolFeeReceiver).transfer(amountBNBDev);
        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        if (halfLiquidity > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                halfLiquidity,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, halfLiquidity);
        }
        _accumulatedReflection = 0;
        _accumulatedLiquidity = 0;
        _accumulatedPool = 0;
        _accumulatedMarket = 0;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyOwner {
        require(launchedAt == 0, "Already launched");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
        tradingOpen = true;
        swapEnabled = true;
    }

    // owner can remove stuck tokens of any type in case tokens are accidentally sent to contract
    function removeStuckToken(address _token, uint256 _amount)
        external
        onlyOwner
    {
        IBEP20(_token).transfer(msg.sender, _amount);
    }

    function setIsFeeExempt(address[] calldata _addrs, bool exempt) external onlyOwner {
        for (uint256 i =0; i< _addrs.length; i++) {
            isFeeExempt[_addrs[i]] = exempt;
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setBuyFeePercent(
        uint256 liquidityFee_,
        uint256 devFee_,
        uint256 marketFee_,
        uint256 _feeDenominator
    ) external onlyOwner {
        liquidityFeeOnBuying = liquidityFee_;
        poolFeeOnBuying = devFee_;
        marketFeeOnBuying = marketFee_;
        feeDenominator = _feeDenominator;

    }

    function setSellFeePercent(
        uint256 liquidityFee_,
        uint256 devFee_,
        uint256 marketFee_,
        uint256 _feeDenominator
    ) external onlyOwner {
        liquidityFeeOnSelling = liquidityFee_;
        poolFeeOnSelling = devFee_;
        marketFeeOnSelling = marketFee_; 
        feeDenominator = _feeDenominator;

    }

    function setNormalFeePercent( 
        uint256 liquidityFee_,
        uint256 devFee_,
        uint256 marketFee_, 
        uint256 _feeDenominator
    ) external onlyOwner { 
        liquidityFee = liquidityFee_;
        devFee = devFee_;
        marketFee = marketFee_; 
        feeDenominator = _feeDenominator;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketFeeReceiver,
        address _poolFeeReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketFeeReceiver = _marketFeeReceiver;
        poolFeeReceiver = _poolFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    } 
    function addSniperInList(address _account) external onlyOwner {
        require(_account != address(router), "We can not blacklist router");
        require(!isSniper[_account], "Sniper already exist");
        isSniper[_account] = true;
    }

    function removeSniperFromList(address _account) external onlyOwner {
        require(isSniper[_account], "Not a sniper");
        isSniper[_account] = false;
    }

    function changeRoute(address _router, address _pair) external onlyOwner {
        router = Irouter(_router);
        pair = _pair;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}