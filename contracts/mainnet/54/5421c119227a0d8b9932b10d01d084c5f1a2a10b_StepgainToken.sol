/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IUniswapV2Factory {
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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function setDistributionCriteria( uint256 _minPeriod, uint256 _minDistribution ) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function getPaidEarnings(address shareholder) external view returns (uint256);
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
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

    IERC20Extended public rewardToken =
    IERC20Extended(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
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
    uint256 public minDistribution = 1 * (10 ** 18);

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

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    } 

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public payable override {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
        value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;   
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getPaidEarnings(address shareholder) public view returns (uint256) {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract StepgainToken is IERC20Extended, Auth {
    using SafeMath for uint256;

    string private constant _name = "Stepgain Token";
    string private constant _symbol = "SGT";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10**_decimals;

    address public constant DEAD = address(0xdead);
    address public constant ZERO = address(0);
    address public pair;
    address public autoLiquidityReceiver = 0x1589e5db8CbB3B1808C9Ae458B34993FDFfaF088; // MultiSig address to receive LP tokens from liquidity add from fee
    address public marketingFeeReceiver = 0xF18bb347428bC5B5C55FC60c76ADa402156fCa42; // address to receive marketing fee

    // fees info
    uint256 public liquidityFee = 0;
    uint256 public buybackFee = 0;
    uint256 public reflectionFee = 3;
    uint256 public marketingFee = 3;
    uint256 public constant sellFee = 1;
    uint256 public totalFee = 7;
    uint256 public constant feeDenominator = 100;

    // Determines whether to add liquidity fee to liquidity, target liquidity is 25%
    uint256 public targetLiquidity = 25;
    uint256 public targetLiquidityDenominator = 100;

    uint256 public distributorGas = 500000;
    uint256 public antiWhaleTxLimitDenominator = 1000; // 1,000,000 
    uint256 public swapThreshold = _totalSupply / 5000; //200,000 = 0.02% 

    bool public swapEnabled = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isTxLimitExempt;

    DividendDistributor public distributor;
    IDexRouter public router;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }


    constructor()
    payable
    Auth(msg.sender)
    {

        router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        distributor = new DividendDistributor(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[autoLiquidityReceiver] = true;

        isDividendExempt[msg.sender] = true;
        isDividendExempt[autoLiquidityReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}



    // Whitelist pinksale
    function setPresale(
        address presaleAddress
    )
    external
    authorized
    {
        isFeeExempt[presaleAddress] = true;
        isDividendExempt[presaleAddress] = true;
        isTxLimitExempt[presaleAddress] = true;
    }


    // Standard ERC-20 Functions
    function totalSupply()
    external
    pure
    override
    returns (uint256)
    {
        return _totalSupply;
    }


    function decimals()
    external
    pure
    override
    returns (uint8)
    {
        return _decimals;
    }


    function symbol()
    external
    pure
    override
    returns (string memory)
    {
        return _symbol;
    }


    function name()
    external
    pure
    override
    returns (string memory)
    {
        return _name;
    }


    function balanceOf(
        address account
    )
    public
    view
    override
    returns (uint256)
    {
        return _balances[account];
    }


    function allowance(
        address holder,
        address spender
    )
    external
    view
    override
    returns (uint256)
    {
        return _allowances[holder][spender];
    }


    function approve(
        address spender,
        uint256 amount
    )
    public
    override
    returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function approveMax(
        address spender
    )
    external
    returns (bool)
    {
        return approve(spender, _totalSupply);
    }


    function transfer(
        address recipient,
        uint256 amount
    )
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
    )
    external
    override
    returns (bool)
    {
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
    )
    internal
    returns (bool)
    {

        if (recipient == pair && sender != owner && !isTxLimitExempt[sender]) {
            uint256 sellLimit = getAntiWhaleTx();
            require(amount <= sellLimit, "Antiwhale limit exceeded");
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

        uint256 amountReceived = shouldTakeFee(sender, recipient)
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

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }


    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    )
    internal
    returns (bool)
    {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function shouldTakeFee(
        address sender,
        address recipient
    )
    internal
    view
    returns (bool)
    {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            return false;
        }
        else if (sender != pair && recipient != pair) {
            return false;
        }
        return true;
    }


    function getTotalFee(
        bool selling
    )
    public
    view
    returns (uint256)
    {
        if (selling) {
            return getsellFee();
        }
        return totalFee;
    }

    function getsellFee() public view returns (uint256) {
        return totalFee.add(sellFee);
    }

    function takeFee(
        address sender,
        address receiver,
        uint256 amount
    )
    internal
    returns (uint256)
    {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(
            feeDenominator
        );

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }


    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap 
        && swapEnabled 
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack()
    internal
    swapping
    {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
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

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB
        .mul(dynamicLiquidityFee)
        .div(totalBNBFee)
        .div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(
            totalBNBFee
        );
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(
            totalBNBFee
        );

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

    // Buyback and burn
    function triggerManualBuyback(uint256 amount) external authorized {
        buyTokens(amount, DEAD);
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
        value: amount
        }(0, path, to, block.timestamp);
    }

    function getTotalDistributedDividend() external view returns (uint256) {
        return distributor.totalDistributed();
    }

    function setRoute(address _router, address _pair) external authorized {
        router = IDexRouter(_router);
        pair = _pair;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setTxLimitExempt(address _address, bool _value ) external authorized {
        isTxLimitExempt[_address] = _value;
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee ) external authorized {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
        require(
            totalFee < feeDenominator / 5,
            "Total fee should not be greater than 20%"
        );
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

   function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function setAntiWhaleSellLimitDenominator(uint256 newDenominator) external authorized {
        require(newDenominator >= 1 && newDenominator <= 10000, "amount must be greater than 0.01% of circulating supply supply and cannot be 0");
        antiWhaleTxLimitDenominator = newDenominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getAntiWhaleTx() public view returns (uint256) {
        return getCirculatingSupply()/antiWhaleTxLimitDenominator;
    }

    // Determines what percent of market cap is backed
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    // Determines if target liquidity is met
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

}