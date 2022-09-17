//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    /**
     * Function modifier to require caller to be contract distributor
     */
    modifier onlyDistributor(address _distributor) {
        require(
            isOwner(msg.sender) || msg.sender != _distributor,
            "!DISTRIBUTOR"
        );
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
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
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod
    ) external;

    function setShare(address shareholder, uint256 amount) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    TheKindToken thiscontract = TheKindToken(payable(address(this)));
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    IDEXRouter router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;
    mapping(address => uint256) public shareReleaseAmount;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;

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
            : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setDistributionCriteria(
        uint256 _minPeriod
    ) external override onlyToken {
        minPeriod = _minPeriod;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 500 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount <= 500 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function getStateShare(address shareholder)
        external
        view
        onlyToken
        returns (uint256)
    {
        return shareReleaseAmount[shareholder];
    }

    function depositFee(uint256 amount) external onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            shareReleaseAmount[shareholder] = shareReleaseAmount[shareholder]
                .add(amount);
            totalDistributed = totalDistributed.add(amount);
        }
    }

    function distributeClaimToken(address shareholder, uint256 amountclaim)
        external onlyToken
    {
        shareReleaseAmount[shareholder] = 0;
        shareholderClaims[shareholder] = block.timestamp;
        shares[shareholder].totalRealised = shares[shareholder]
            .totalRealised
            .add(amountclaim);
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
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

contract TheKindToken is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;
    address pancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    string constant _name = "THE KIND TOKEN";
    string constant _symbol = "KIND";
    uint8 constant _decimals = 9;
    struct charity {
        uint256 amount;
        uint256 date;
        uint256 period;
        uint256 delaytime;
        uint256 index;
        bool state;
    }

    uint256 constant _totalSupply = 2000000000 * (10**_decimals);
    uint256 public _maxTxAmount = _totalSupply.div(1000); // 0.01%

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(uint256 => mapping(uint256 => address)) _postTimes;
    mapping(uint256 => uint256) _postAmountoftimes;
    mapping(address => charity) _postAddr;
    mapping(address => mapping(uint256 => uint256)) _voterOfpost;
    mapping(address => mapping(address => mapping(uint256 => bool))) _voterState;
    mapping(address => bool) _voter;
    mapping(uint256 => uint256) _rewards;
    mapping(uint256 => uint256) _voterRewards;
    mapping(address => uint256) _voterStarttime;

    mapping(address => uint256) _checkcharity;
    mapping(uint256 => uint256) _charitypercent;
    mapping(uint256 => uint256) postamount;

    mapping(address => uint256) _voterUnstake;
    mapping(address => uint256) _limitofVoter;
    mapping(address => uint256) _limitofCharity;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;

    uint256 constant buybackFee = 120;
    uint256 constant reflectionFee = 240;
    uint256 constant marketingFee = 60;
    uint256 constant devFee = 60;
    uint256 constant adminFee = 120;
    uint256 constant charityFee = 300;
    uint256 constant voterRewardsFee = 300;
    uint256 constant totalFee = 1200;
    uint256 constant feeDenominator = 10000;
    uint256 public claimTime;
    uint256 public Times;
    uint256 currentTimes;
    uint256 index;
    uint256 voterAmount;

    address public marketingFeeReceiver;
    address public devFeeReceiver;
    address public charityFeeReceiver;
    address public adminReceiver;
    address public buyBackReceiver;
    address public voterRewardsReceiver;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 public amountReflection;
    uint256 public amountCharity;
    uint256 public amountVoterRewards;
    uint256 public amountBuyBack;
    uint256 public amountMarketing;
    uint256 public amountDev;
    uint256 public amountAdmin;
    uint256 public RemainedTokenAmount;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;
    uint256 postAndVoteFee = 500;

    bool public autoBuybackEnabled = false;
    mapping(address => bool) buyBacker;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    DividendDistributor distributor;
    address public distributorAddress;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 2000; // 0.005%
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _dexRouter) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(_dexRouter);
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(router)] = true;
        isFeeExempt[pair] = true;

        isTxLimitExempt[msg.sender] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        buyBacker[msg.sender] = true;

        marketingFeeReceiver = msg.sender;
        devFeeReceiver = msg.sender;
        adminReceiver = msg.sender;
        charityFeeReceiver = msg.sender;
        buyBackReceiver = msg.sender;
        voterRewardsReceiver = msg.sender;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        claimTime = block.timestamp;
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

    modifier onlyBuybacker() {
        require(buyBacker[msg.sender] == true, "");
        _;
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

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "Kind Token: TX Limit Exceeded"
        );
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if (selling) {
            return getMultipliedFee();
        }
        return totalFee;
    }

    function getMultipliedFee() public view returns (uint256) {
            if (
            buybackMultiplierTriggeredAt.add(buybackMultiplierLength) >
            block.timestamp
        ) {
            uint256 remainingTime = buybackMultiplierTriggeredAt
                .add(buybackMultiplierLength)
                .sub(block.timestamp);
            uint256 feeIncrease = totalFee
                .mul(buybackMultiplierNumerator)
                .div(buybackMultiplierDenominator)
                .sub(totalFee);
            return
                totalFee.add(
                    feeIncrease.mul(remainingTime).div(buybackMultiplierLength)
                );
        }
        return totalFee;
    }

    function takeFee(
        address sender,
        address receiver,
        uint256 amount
    ) internal returns (uint256) {
        uint256 tempTotalFee = getTotalFee(receiver == pair);
        uint256 feeAmount = amount.mul(tempTotalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] - RemainedTokenAmount >= swapThreshold;
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
                _allowances[sender][msg.sender] = _allowances[sender][
                    msg.sender
                ].sub(amount, "Kind Token: Insufficient Allowance");
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

        if (shouldSwapBack()) swapBack();
        if (claimTime <= block.timestamp) {
            distributeCharity();
        }

        uint256 minBalance = 10**uint256(_decimals);
        if (
            _balances[sender].sub(
                amount,
                "BEP20: transfer amount exceeds balance"
            ) < minBalance
        ) {
            require(
                _balances[sender] > minBalance,
                "Kind Token: 1 Kind Token must remain in wallet"
            );
            amount = _balances[sender].sub(minBalance);
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Kind Token: Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, recipient, amount)
            : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

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
        uint256 minBalance = 10**uint256(_decimals);
        if (
            _balances[sender].sub(
                amount,
                "BEP20: transfer amount exceeds balance"
            ) < minBalance
        ) {
            require(
                _balances[sender] > minBalance,
                "Kind Token: 1 Kind Token must remain in wallet"
            );
            amount = _balances[sender].sub(minBalance);
        }
        _balances[sender] = _balances[sender].sub(
            amount,
            "Kind Token: Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function swapBack() internal swapping {
        amountReflection = swapThreshold.mul(reflectionFee).div(totalFee);
        amountCharity =
            amountCharity +
            swapThreshold.mul(charityFee).div(totalFee);
        amountVoterRewards =
            amountVoterRewards +
            swapThreshold.mul(voterRewardsFee).div(totalFee);
        uint256 amountToSwap = swapThreshold.mul(360).div(totalFee);
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
        amountMarketing = amountMarketing + amountBNB.div(6);
        amountDev = amountDev + amountBNB.div(6);
        amountAdmin = amountAdmin + amountBNB.div(3);
        amountBuyBack = amountBuyBack + amountBNB.div(3);
        RemainedTokenAmount =
            RemainedTokenAmount +
            swapThreshold.mul(840).div(totalFee);
        try distributor.depositFee(amountReflection) {} catch {}
    }

    //###################################################################

    function buyBackReceiverFun() external payable {
        require(msg.sender == buyBackReceiver, "You are not buyback");
        payable(buyBackReceiver).transfer(amountBuyBack);
        amountBuyBack = 0;
    }

    function marketingReceiver() external payable {
        require(
            msg.sender == marketingFeeReceiver,
            "You are not marketingReceiver"
        );
        payable(marketingFeeReceiver).transfer(amountMarketing);
        amountMarketing = 0;
    }

    function devReceiverFun() external payable {
        require(msg.sender == devFeeReceiver, "You are not devReceiver");
        payable(devFeeReceiver).transfer(amountDev);
        amountDev = 0;
    }

    function adminReceiverFun() external payable {
        require(msg.sender == adminReceiver, "You are not devReceiver");
        payable(adminReceiver).transfer(amountAdmin);
        amountAdmin = 0;
    }

    function getSharesInfo(address addr) external view returns (uint256) {
        return distributor.getStateShare(addr);
    }


    function claimReflection() external {
        address addr = msg.sender;
        uint256 amount = distributor.getStateShare(addr);
        _balances[addr] = _balances[addr].add(amount);
        _balances[address(this)] = _balances[address(this)].sub(amount);
        RemainedTokenAmount = RemainedTokenAmount - amount;
        distributor.distributeClaimToken(addr, amount);
    }

    function buyBackAndBurn(uint256 _amount) external {
        require(msg.sender == buyBackReceiver, "You can not buyback&burn");
        require(_amount != 0, "You need to send  over 0 BNB ");
        require(_amount >= autoBuybackAmount, "Please input again value");
        if (shouldAutoBuyback()) {
            triggerAutoBuyback(_amount);
        }
    }

    function getclaimTime() external view returns (uint256) {
        return claimTime;
    }

    function distributeCharity() internal {
        if (Times > 90) {
            periodCalculation(90);
        }
        if (Times > 180) {
            periodCalculation(180);
        }

        uint256 postpercent;
        if (voterAmount != 0) {
            postpercent = amountCharity.div(voterAmount);
        }
        _charitypercent[Times] = postpercent;
        amountCharity = 0;
        claimTime = claimTime + 1 days;
        if (Times != 0) {
            _rewards[Times] = _rewards[Times - 1] + _rewards[Times];
        }
        if (_rewards[Times] != 0) {
            _voterRewards[Times] = amountVoterRewards.div(_rewards[Times]);
        } else {
            _voterRewards[Times] = 0;
        }
        Times = Times + 1;
    }

    function periodCalculation(uint256 _periodTime) internal {
        uint256 unstakeNum = Times - _periodTime;
        uint256 Index = _postAmountoftimes[unstakeNum];
        for (uint256 i = 1; i <= Index; i++) {
            address addr = _postTimes[unstakeNum][i];
            if (_postAddr[addr].period == _periodTime) {
                _postAddr[addr].state = false;
                voterAmount = voterAmount - _postAddr[addr].amount;
                _postAddr[addr].amount = 0;
            }
        }
    }

    function post(bool _type) external {
        require(
            !_postAddr[msg.sender].state,
            "You have already posted your article"
        );
        require(
            _postAddr[msg.sender].period +
                _postAddr[msg.sender].date +
                _postAddr[msg.sender].delaytime <=
                Times,
            "You can not Post now!"
        );
        if (currentTimes != Times) {
            index = 1;
        }
        _postTimes[Times][index] = msg.sender;
        _postAddr[msg.sender].amount = 0;
        if (_type) {
            _postAddr[msg.sender].period = 90;
        } else {
            _postAddr[msg.sender].period = 180;
        }
        _postAddr[msg.sender].date = Times;
        _postAddr[msg.sender].delaytime = 2;
        _postAddr[msg.sender].index = _postAddr[msg.sender].index + 1;
        _postAddr[msg.sender].state = true;
        _postAmountoftimes[Times] = index;
        index = index + 1;
        currentTimes = Times;
        _balances[msg.sender] = _balances[msg.sender] - postAndVoteFee * (10**_decimals);
        _balances[adminReceiver] =
            _balances[adminReceiver] +
            postAndVoteFee *
            (10**_decimals);
    }

    function claimCharity() external returns (uint256) {
        uint256 claimedTimes = _checkcharity[msg.sender];

        if (claimedTimes < Times) {
            uint256 sum = 0;
            for (uint256 i = claimedTimes; i < Times; i++) {
                if (i != 0) {
                    _voterOfpost[msg.sender][i] =
                        _voterOfpost[msg.sender][i - 1] +
                        _voterOfpost[msg.sender][i];
                }
                sum = sum.add(_voterOfpost[msg.sender][i] * _charitypercent[i]);
            }
            if (sum != 0) {
                _limitofCharity[msg.sender] = _limitofCharity[msg.sender] + 1;
                require(_limitofCharity[msg.sender] <= 35000 * (10**_decimals));
                _balances[msg.sender] = _balances[msg.sender].add(sum);
                _balances[address(this)] = _balances[address(this)].sub(sum);
                RemainedTokenAmount = RemainedTokenAmount - sum;
            }
            _checkcharity[msg.sender] = Times;
            return sum;
        } else {
            return 0;
        }
    }

    function vote(address addr) external {
        if (
            _voterUnstake[msg.sender] + 2 <= Times &&
            _voterUnstake[msg.sender] != 0
        ) {
            _voterUnstake[msg.sender] = 0;
            _voter[msg.sender] = false;
        }
        require(addr != msg.sender, "Voter function => Alert : Your article!");

        require(_postAddr[addr].state, "Post don't exist!");
        uint256 postIndex = _postAddr[addr].index;
        require(
            !_voterState[msg.sender][addr][postIndex],
            "You have already voted!"
        );
        _voterState[msg.sender][addr][postIndex] = true;
        voterAmount = voterAmount + 1;
        _postAddr[addr].amount = _postAddr[addr].amount + 1;
        _voterOfpost[addr][Times] = _voterOfpost[addr][Times] + 1;
        if (!_voter[msg.sender]) {
            _voter[msg.sender] = true;
            _voterStarttime[msg.sender] = Times;
            _rewards[Times] = _rewards[Times] + 1;
            _balances[msg.sender] =
                _balances[msg.sender] -
                postAndVoteFee *
                (10**_decimals);
            _balances[adminReceiver] =
                _balances[adminReceiver] +
                postAndVoteFee *
                (10**_decimals);
        }
    }

    function claimVote() external {
        require(_voterUnstake[msg.sender] == 0, "You have already unstaked!");
        if (_voter[msg.sender]) {
            uint256 votertimes = _voterStarttime[msg.sender];
            uint256 sum = 0;
            for (uint256 i = votertimes; i < Times; i++) {
                sum = sum.add(_voterRewards[i]);
            }
            _voterStarttime[msg.sender] = Times;

            if (sum != 0) {
                _limitofVoter[msg.sender] = _limitofVoter[msg.sender] + sum;
                require(
                    _limitofVoter[msg.sender] <= 35000 * (10**_decimals),
                    "Balance is limitated!"
                );
                _balances[msg.sender] = _balances[msg.sender].add(sum);
                _balances[address(this)] = _balances[address(this)].sub(sum);
                RemainedTokenAmount = RemainedTokenAmount - sum;
            }
        }
    }

    function unstake() external {
        require(_voter[msg.sender], "You didn't stake");
        _voterUnstake[msg.sender] = Times;
        _voter[msg.sender] = false;
        _balances[msg.sender] = _balances[msg.sender] + (postAndVoteFee - 15) * (10**_decimals);
        _balances[adminReceiver] =
            _balances[adminReceiver] -
            (postAndVoteFee - 15) *
            (10**_decimals);
    }

    function postValidityDate(address addr) external view returns (uint256) {
        return _postAddr[addr].date; // Post Validity Date
    }

    function postExpiredDate(address addr) external view returns (uint256) {
        return _postAddr[addr].period + _postAddr[addr].date; // Post Expired Date
    }

    //#################################################
    function shouldAutoBuyback() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            autoBuybackEnabled &&
            autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number; // After N blocks from last buyback
    }

    function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier)
        external
        authorized
    {
        buyTokens(amount, DEAD);
        if (triggerBuybackMultiplier) {
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function triggerAutoBuyback(uint256 amount) internal {
        buyTokens(amount, DEAD);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(amount);
        if (autoBuybackAccumulator > autoBuybackCap) {
            autoBuybackEnabled = false;
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }

    function setAutoBuybackSettings(
        bool _enabled,
        uint256 _cap,
        uint256 _amount,
        uint256 _period
    ) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(
        uint256 numerator,
        uint256 denominator,
        uint256 length
    ) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Kind Token: Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyDistributor(holder)
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt)
        external
        onlyDistributor(holder)
    {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyDistributor(holder)
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(
        address _marketingFeeReceiver,
        address _devFeeReceiver,
        address _charityFeeReceiver,
        address _adminReceiver,
        address _buyBackReceiver,
        address _voterRewardsReceiver
    ) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
        charityFeeReceiver = _charityFeeReceiver;
        adminReceiver = _adminReceiver;
        buyBackReceiver = _buyBackReceiver;
        voterRewardsReceiver = _voterRewardsReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        authorized
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }


    function setPostAndVoteFee(uint256 _amount)
        external
        authorized
    {
        postAndVoteFee = _amount;
    }

    function setDistributionCriteria(
        uint256 _minPeriod
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}