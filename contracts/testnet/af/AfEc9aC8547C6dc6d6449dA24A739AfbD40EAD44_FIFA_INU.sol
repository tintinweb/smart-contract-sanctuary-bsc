// SPDX-License-Identifier: MIT

/**

███████╗██╗███████╗ █████╗     ██╗███╗   ██╗██╗   ██╗
██╔════╝██║██╔════╝██╔══██╗    ██║████╗  ██║██║   ██║
█████╗  ██║█████╗  ███████║    ██║██╔██╗ ██║██║   ██║
██╔══╝  ██║██╔══╝  ██╔══██║    ██║██║╚██╗██║██║   ██║
██║     ██║██║     ██║  ██║    ██║██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                     

*/
pragma solidity ^0.8.10;

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

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
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

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 _amount) external;

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

    IERC20Extended public _token;
    IDexRouter public router;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution;

    uint256 currentIndex;

    bool initialized;
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == address(_token));
        _;
    }

    constructor(address router_) {
        _token = IERC20Extended(msg.sender);
        router = IDexRouter(router_);
        minDistribution = 1 * 10 ** 18;
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

    function deposit(uint256 _amount) external override onlyToken {
        totalDividends = totalDividends.add(_amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(_amount).div(totalShares)
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
            _token.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address _user) external {
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

// main contract
contract FIFA_INU is IERC20Extended, Auth {
    using SafeMath for uint256;

    string private constant _name = "FIFA INU";
    string private constant _symbol = "FIFA INU";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10 **_decimals;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);
    IDexRouter public router;
    address public pair;
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public treasuryFeeReceiver;
    address public devFeeReceiver;

    uint256 _reflectionBuyFee = 3;
    uint256 _liquidityBuyFee = 3;
    uint256 _marketingBuyFee = 3;
    uint256 _treasuryBuyFee = 3;
    uint256 _devBuyFee = 1;
    uint256 _burnBuyFee = 3;

    uint256 _reflectionSellFee = 3;
    uint256 _liquiditySellFee = 3;
    uint256 _marketingSellFee = 3;
    uint256 _treasurySellFee = 3;
    uint256 _devSellFee = 1;
    uint256 _burnSellFee = 5;

    uint256 _reflectionFeeCount;
    uint256 _liquidityFeeCount;
    uint256 _marketingFeeCount;
    uint256 _treasuryFeeCount;
    uint256 _devFeeCount;
    uint256 _burnFeeCount;

    uint256 public totalBuyFee = 16;
    uint256 public totalSellFee = 18;
    uint256 public feeDenominator = 100;

    DividendDistributor public distributor;
    uint256 public distributorGas = 500000;
    uint256 public maxWalletAmount = 30_000_000 * 10**_decimals;
    uint256 public targetLiquidity = 25;
    uint256 public targetLiquidityDenominator = 100;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isLimitExmpt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) isSniper;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    uint256 antiSnipingTime = 60 seconds;

    bool public swapEnabled;
    bool public tradingOpen;
    uint256 public swapThreshold = 250_000 * 10**_decimals;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event AutoLiquify(uint256 amountEth, uint256 amountBOG);

    constructor() Auth(msg.sender) {
        address router_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        treasuryFeeReceiver = msg.sender;
        devFeeReceiver = msg.sender;

        router = IDexRouter(router_);
        pair = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        distributor = new DividendDistributor(router_);

        isFeeExempt[autoLiquidityReceiver] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[treasuryFeeReceiver] = true;
        isFeeExempt[devFeeReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isLimitExmpt[autoLiquidityReceiver] = true;
        isLimitExmpt[address(this)] = true;
        isLimitExmpt[marketingFeeReceiver] = true;
        isLimitExmpt[treasuryFeeReceiver] = true;
        isLimitExmpt[devFeeReceiver] = true;
        isLimitExmpt[msg.sender] = true;
        isLimitExmpt[address(router)] = true;
        isLimitExmpt[address(pair)] = true;

        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;

        _balances[autoLiquidityReceiver] = _totalSupply;
        emit Transfer(address(0), autoLiquidityReceiver, _totalSupply);
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

        if (!isLimitExmpt[recipient]) {
            require(
                balanceOf(recipient).add(amount) <= maxWalletAmount,
                "Max wallet limit exceeds"
            );
            // trading disable till launch
            if (!tradingOpen) {
                require(
                    sender != pair && recipient != pair,
                    "Trading is not enabled yet"
                );
            }
            // antibot
            if (
                block.timestamp < launchedAtTimestamp + antiSnipingTime &&
                sender != address(router)
            ) {
                if (sender == pair) {
                    isSniper[recipient] = true;
                } else if (recipient == pair) {
                    isSniper[sender] = true;
                }
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived;
        if (
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            (sender != pair && recipient != pair)
        ) {
            amountReceived = amount;
        } else {
            uint256 feeAmount;
            if (sender == pair) {
                feeAmount = amount.mul(totalBuyFee).div(feeDenominator);
                amountReceived = amount.sub(feeAmount);
                takeFee(sender, feeAmount);
                setBuyAccFee(amount);
            } else {
                feeAmount = amount.mul(totalSellFee).div(feeDenominator);
                amountReceived = amount.sub(feeAmount);
                takeFee(sender, feeAmount);
                setSellAccFee(amount);
            }
        }

        _balances[recipient] = _balances[recipient].add(amountReceived);

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

    function takeFee(address sender, uint256 feeAmount) internal {
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
    }

    function setBuyAccFee(uint256 _amount) internal {
        _liquidityFeeCount = _amount.mul(_liquidityBuyFee).div(feeDenominator);
        _reflectionFeeCount = _amount.mul(_reflectionBuyFee).div(
            feeDenominator
        );
        _marketingFeeCount = _amount.mul(_marketingBuyFee).div(feeDenominator);
        _treasuryFeeCount = _amount.mul(_treasuryBuyFee).div(feeDenominator);
        _devFeeCount = _amount.mul(_devBuyFee).div(feeDenominator);
        _burnFeeCount = _amount.mul(_burnBuyFee).div(feeDenominator);
    }

    function setSellAccFee(uint256 _amount) internal {
        _liquidityFeeCount = _amount.mul(_liquiditySellFee).div(feeDenominator);
        _reflectionFeeCount = _amount.mul(_reflectionSellFee).div(
            feeDenominator
        );
        _marketingFeeCount = _amount.mul(_marketingSellFee).div(feeDenominator);
        _treasuryFeeCount = _amount.mul(_treasurySellFee).div(feeDenominator);
        _devFeeCount = _amount.mul(_devSellFee).div(feeDenominator);
        _burnFeeCount = _amount.mul(_burnSellFee).div(feeDenominator);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 totalFee = _liquidityFeeCount
            .add(_reflectionFeeCount)
            .add(_marketingFeeCount)
            .add(_treasuryFeeCount)
            .add(_devFeeCount)
            .add(_burnFeeCount);

        uint256 dynamic_LiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : _liquidityFeeCount;

        uint256 amountToLiquify = swapThreshold
            .mul(dynamic_LiquidityFee)
            .div(totalFee)
            .div(2);

        uint256 amountToReflect = swapThreshold.mul(_reflectionFeeCount).div(
            totalFee
        );

        uint256 amountToBurn = swapThreshold.mul(_burnFeeCount).div(totalFee);

        uint256 amountToSwap = swapThreshold.sub(
            amountToLiquify.add(amountToReflect).add(amountToBurn)
        );

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountEth = address(this).balance.sub(balanceBefore);

        uint256 totalEthFee = totalFee.sub(dynamic_LiquidityFee.div(2));

        uint256 amountEthLiquidity = amountEth
            .mul(dynamic_LiquidityFee)
            .div(totalEthFee)
            .div(2);
        uint256 amountEthMarketing = amountEth.mul(_marketingFeeCount).div(
            totalEthFee
        );
        uint256 amountEthTreasury = amountEth.mul(_treasuryFeeCount).div(
            totalEthFee
        );
        uint256 amountEthDev = amountEth.mul(_devFeeCount).div(totalEthFee);

        try distributor.deposit(amountToReflect) {
            _basicTransfer(
                address(this),
                address(distributor),
                amountToReflect
            );
        } catch {}
        _basicTransfer(address(this), DEAD, amountToBurn);
        payable(marketingFeeReceiver).transfer(amountEthMarketing);
        payable(treasuryFeeReceiver).transfer(amountEthTreasury);
        payable(devFeeReceiver).transfer(amountEthDev);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountEthLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountEthLiquidity, amountToLiquify);
        }

        _liquidityFeeCount = 0;
        _reflectionFeeCount = 0;
        _marketingFeeCount = 0;
        _treasuryFeeCount = 0;
        _devFeeCount = 0;
        _burnFeeCount = 0;
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getPaidDividend(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getPaidEarnings(shareholder);
    }

    function getUnpaidDividend(address shareholder)
        external
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function getTotalDistributedDividend() external view returns (uint256) {
        return distributor.totalDistributed();
    }

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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsLimitExempt(address holder, bool exempt) external authorized {
        isLimitExmpt[holder] = exempt;
    }

    function airdrop(address[] calldata addresses, uint256[] calldata amounts)
        external
        onlyOwner
    {
        require(
            addresses.length == amounts.length,
            "Array sizes must be equal"
        );
        uint256 i = 0;
        while (i < addresses.length) {
            uint256 _amount = amounts[i].mul(1e18);
            _basicTransfer(msg.sender, addresses[i], _amount);
            i += 1;
        }
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

    function withdrawETH(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Invalid Amount");
        payable(msg.sender).transfer(_amount);
    }

    function withdrawToken(IERC20Extended _token, uint256 _amount)
        external
        onlyOwner
    {
        require(_token.balanceOf(address(this)) >= _amount, "Invalid Amount");
        _token.transfer(msg.sender, _amount);
    }

    function setBuyFees(
        uint256 _reflectionFee,
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    ) public authorized {
        _reflectionBuyFee = _reflectionFee;
        _liquidityBuyFee = _liquidityFee;
        _marketingBuyFee = _marketingFee;
        _treasuryBuyFee = _treasuryFee;
        _burnBuyFee = _burnFee;
        totalBuyFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_treasuryFee)
            .add(_devBuyFee)
            .add(_burnFee);
        require(
            totalBuyFee <= feeDenominator.div(4),
            "Can't be greater than 25%"
        );
    }

    function setSellFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    ) public authorized {
        _liquiditySellFee = _liquidityFee;
        _reflectionSellFee = _reflectionFee;
        _marketingSellFee = _marketingFee;
        _treasurySellFee = _treasuryFee;
        _burnSellFee = _burnFee;
        totalSellFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_treasuryFee)
            .add(_devSellFee)
            .add(_burnFee);
        require(
            totalSellFee <= feeDenominator.div(4),
            "Can't be greater than 25%"
        );
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _treasuryFeeReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        treasuryFeeReceiver = _treasuryFeeReceiver;
    }

    function setMaxWalletlimit(uint256 _maxWalletAmount) external authorized {
        maxWalletAmount = _maxWalletAmount;
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

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
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
}