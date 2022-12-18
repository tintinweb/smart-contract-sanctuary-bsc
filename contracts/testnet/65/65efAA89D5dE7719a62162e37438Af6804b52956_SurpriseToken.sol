// SPDX-License-Identifier: MIT


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

    function transferrecipient(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(
        address indexed recipient,
        address indexed to,
        uint256 value
    );
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

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20Extended public BUSD =
        IERC20Extended(0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337);
    IDexRouter public router;

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
    uint256 public minDistribution = 1 * (10**BUSD.decimals());

    uint256 currentIndex;

    bool initialized;
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address router_) {
        _token = msg.sender;
        router = IDexRouter(router_);
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
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

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
            BUSD.transfer(shareholder, amount);
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
contract SurpriseToken is IERC20Extended, Auth {
    using SafeMath for uint256;

    string private constant _name = "Token";
    string private constant _symbol = "Tkn";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000_00 * 10**_decimals;

    address public BUSD = 0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337;
    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);
    IDexRouter public router;
    address public pair;
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public giftsFeeReceiver;

    uint256 _liquidityBuyFee = 0;
    uint256 _reflectionBuyFee = 0;
    uint256 _marketingBuyFee = 2;
    uint256 _giftsBuyFee = 1;
    uint256 _surpriseBuyFee = 1;

    uint256 _liquiditySellFee = 0;
    uint256 _reflectionSellFee = 0;
    uint256 _marketingSellFee = 2;
    uint256 _giftsSellFee = 1;
    uint256 _surpriseSellFee = 1;

    uint256 _liquidityFeeCount;
    uint256 _reflectionFeeCount;
    uint256 _marketingFeeCount;
    uint256 _giftsFeeCount;
    uint256 _surpriseFeeCount;

    uint256 public totalBuyFee = 0;
    uint256 public totalSellFee = 0;
    uint256 public feeDenominator = 100;

    DividendDistributor public distributor;
    uint256 public distributorGas = 500000;
    uint256 public maxTxAmount = _totalSupply / 100;
    uint256 public targetLiquidity = 25;
    uint256 public targetLiquidityDenominator = 100;
    uint256 public launchedAt;
    uint256 public snipingTime = 40 seconds;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isLimitExmpt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isBot;
    address[] public buyers;

    bool public swapEnabled;
    uint256 public swapThreshold = _totalSupply / 20000;
    bool public trading; // once enable can't be disable afterwards

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    constructor() Auth(msg.sender) {
        address router_ = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        giftsFeeReceiver = msg.sender;

        router = IDexRouter(router_);
        pair = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        distributor = new DividendDistributor(router_);

        isFeeExempt[autoLiquidityReceiver] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[giftsFeeReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isLimitExmpt[autoLiquidityReceiver] = true;
        isLimitExmpt[address(this)] = true;
        isLimitExmpt[marketingFeeReceiver] = true;
        isLimitExmpt[giftsFeeReceiver] = true;

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
        return _transferrecipient(msg.sender, recipient, amount);
    }

    function transferrecipient(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferrecipient(sender, recipient, amount);
    }

    function _transferrecipient(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (!isLimitExmpt[sender] && !isLimitExmpt[recipient]) {
            require(amount <= maxTxAmount, "Max limit exceeds");
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }
        if (!trading) {
            require(pair != sender && pair != recipient, " trading is disable");
        }

        require(!isBot[sender], "Bot detected");

        if (
            block.timestamp < launchedAt + snipingTime &&
            recipient != address(router)
        ) {
            if (pair == sender) {
                isBot[recipient] = true;
            } else if (pair == recipient) {
                isBot[sender] = true;
            }
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
               buyers.push(msg.sender);

            } else {
                feeAmount = amount.mul(totalSellFee).div(feeDenominator);
                amountReceived = amount.sub(feeAmount);
                takeFee(sender, feeAmount);
                setSellAccFee(amount);
                rewardBuyers();
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
        _giftsFeeCount = _amount.mul(_giftsBuyFee).div(feeDenominator);
        _surpriseFeeCount = _amount.mul(_surpriseBuyFee).div(feeDenominator);
    }

    function setSellAccFee(uint256 _amount) internal {
        _liquidityFeeCount = _amount.mul(_liquiditySellFee).div(feeDenominator);
        _reflectionFeeCount = _amount.mul(_reflectionSellFee).div(
            feeDenominator
        );
        _marketingFeeCount = _amount.mul(_marketingSellFee).div(feeDenominator);
        _giftsSellFee = _amount.mul(_giftsSellFee).div(feeDenominator);
        _surpriseFeeCount = _amount.mul(_surpriseSellFee).div(feeDenominator);
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
            .add(_giftsFeeCount);

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

        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamic_LiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamic_LiquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBReflection = amountBNB.mul(_reflectionFeeCount).div(
            totalBNBFee
        );
        uint256 amountBNBMarketing = amountBNB.mul(_marketingFeeCount).div(
            totalBNBFee
        );
        uint256 amountBNBgifts = amountBNB.mul(_giftsFeeCount).div(totalBNBFee);

        if (amountBNBReflection > 0) {
            try distributor.deposit{value: amountBNBReflection}() {} catch {}
        }

        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        payable(giftsFeeReceiver).transfer(amountBNBgifts);

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

        _liquidityFeeCount = 0;
        _reflectionFeeCount = 0;
        _marketingFeeCount = 0;
        _giftsFeeCount = 0;
    }

    function rewardBuyers() internal swapping {
        uint256 amountToSwap = _surpriseFeeCount;

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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        if (buyers.length < 5) {
            for (uint256 i; i < buyers.length; i++) {
                payable(buyers[i]).transfer(amountBNB / buyers.length);
            }
        } 
        else {

            for (uint256 i = buyers.length - 1; i >= buyers.length - 5; i--) {
                payable(buyers[i]).transfer(amountBNB / 5);
            }

        }

        _surpriseFeeCount = 0;
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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function enableTrading() external onlyOwner {
        require(!trading, "$BUB: already enabled");
        trading = true;
        swapEnabled = true;
        launchedAt = block.timestamp;
    }

    function setIsLimitExempt(address holder, bool exempt) external authorized {
        isLimitExmpt[holder] = exempt;
    }

    function setBuyFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _giftsFee,
        uint256 _surpriseFee,
        uint256 _feeDenominator
    ) public authorized {
        _liquidityBuyFee = _liquidityFee;
        _reflectionBuyFee = _reflectionFee;
        _marketingBuyFee = _marketingFee;
        _surpriseBuyFee = _giftsFee;
        _giftsBuyFee = _surpriseFee;
        totalBuyFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_giftsFee)
            .add(_surpriseFee);
        feeDenominator = _feeDenominator;
    }

    function setSellFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _giftsFee,
        uint256 _surpriseFee,
        uint256 _feeDenominator
    ) public authorized {
        _liquiditySellFee = _liquidityFee;
        _reflectionSellFee = _reflectionFee;
        _marketingSellFee = _marketingFee;
        _giftsSellFee = _giftsFee;
        _surpriseSellFee = _surpriseFee;
        totalSellFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_giftsFee)
            .add(_surpriseFee);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _giftsFeeReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        giftsFeeReceiver = _giftsFeeReceiver;
    }

    function addOrRemoveBots(address[] memory accounts, bool value)
        external
        onlyOwner
    {
        for (uint256 i; i < accounts.length; i++) {
            require(
                accounts[i] != address(router) && pair != accounts[i],
                "$BUB: cannot blacklist Dex"
            );
            isBot[accounts[i]] = value;
        }
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