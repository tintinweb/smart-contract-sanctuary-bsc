/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: No

pragma solidity = 0.8.17;

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address public _safuDeployer;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SAFUDeployerTransferred(address indexed oldMultiSig, address indexed newMultiSig);

    constructor() {
        _setOwner(_msgSender());
        _setSafuDeployer(_msgSender());
    }

    function safuDeployer() public view virtual returns (address) {
        return _safuDeployer;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || safuDeployer() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlySafuDeveloper() {
        require(safuDeployer() == _msgSender(), "SAFU: caller is not the safu developer");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function transferSafuDeveloper(address newSafuDeployer) public virtual onlySafuDeveloper {
        require(newSafuDeployer != address(0), "SAFU: new owner is the zero address");
        _setSafuDeployer(newSafuDeployer);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setSafuDeployer(address newSafuDeployer) private {
        address oldSafuDeployer = newSafuDeployer;
        _safuDeployer = oldSafuDeployer;
        emit SAFUDeployerTransferred(oldSafuDeployer, oldSafuDeployer);
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


//--- IDivinded ---//
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

//--- Dividend ---//
contract DividendDistributor is IDividendDistributor {

    address private _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 private RWRD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    IRouter02 private dexRouter;



    address[] private shareholders;
    mapping (address => uint256) private shareholderIndexes;
    mapping (address => uint256) private shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 3 * 60 * 60;
    uint256 public minDistribution = 1 * (10 ** 4);

    uint256 private currentIndex;

    bool private initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _dexRouter) {
        _token = msg.sender;
        dexRouter = _dexRouter != address(0) ? IRouter02(_dexRouter) : IRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

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

        totalShares = totalShares - (shares[shareholder].amount) + (amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));


        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(RWRD);

            dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RWRD.balanceOf(address(this)) - (balanceBefore);

        totalDividends = totalDividends + (amount);
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * (amount) / (totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - (gasleft()));
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
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed + (amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised + (amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * (dividendsPerShare) / (dividendsPerShareAccuracyFactor);
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

//
contract BabyInu is IERC20, Ownable {

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address private DEV = 0xC726Ac99258552bFa2AbaABA47126a8335400299;

    string constant _name = "Baby inu";
    string constant _symbol = "$BINU";
    uint8 constant _decimals = 9;

    uint256 public _totalSupply = 100_000_000_000_000 * 10**_decimals;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowances;


    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) private liquidityAdd;
    mapping (address => bool) private isLpPair;
    mapping (address => bool) private isPresaleAddress;

    uint256 public reflectionFee   = 1;
    uint256 public marketingFee    = 2;
    uint256 public devFee          = 2;
    uint256 public cexFee         = 2;
    uint256 public totalFee        = marketingFee + reflectionFee + cexFee + devFee;
    uint256 public constant feeDenominator  = 100;

    bool private cannotChangeMore;
    address payable private marketingFeeReceiver;
    address payable private devFeeReceiver;
    address payable private cexFeeReceiver;

    IRouter02 public dexRouter;

    address public pair;

    bool public isTradingEnabled = false;

    DividendDistributor public distributor;
    uint256 private distributorGas = 500_000;

    bool private swapEnabled = true;
    uint256 public swapThreshold = _totalSupply;
    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () {
        dexRouter = IRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        pair = IDEXFactory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        _allowances[address(this)][address(pair)] = type(uint256).max;

        distributor = new DividendDistributor(address(dexRouter));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(DEV)] = true;
        isFeeExempt[address(this)] = true;

        marketingFeeReceiver = payable(0x60f5F646daF8E4e837BA6DBf57917d0ca309b5fB);
        devFeeReceiver = payable(0xf0A7854ECd1e89FBD7F27605b61Bd15959040e08);
        cexFeeReceiver = payable(0x357a484EF3751A750A1857c2b3C8C0fCae096722);

        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[marketingFeeReceiver] = true;
        isDividendExempt[devFeeReceiver] = true;
        isDividendExempt[cexFeeReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    } 


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transferFrom(sender, recipient, amount);
    }
    

    function isLimitedAddress(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner() && tx.origin != owner() // any transaction with no direct interaction from owner will be accepted
            && msg.sender != owner()
            && !liquidityAdd[ins]  && !liquidityAdd[out] && out != DEAD && out != address(0) && out != address(this);
            return isLimited;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer to the zero address");
        require(recipient != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (isLimitedAddress(sender,recipient)) {
            require(isTradingEnabled,"Trading is not enabled");
        }

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient] + (amountReceived);

        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
    
     return true; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount * (totalFee) / feeDenominator;
        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount - (feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function enableTrading() public onlySafuDeveloper {
        require(!isTradingEnabled,"Owner cannot stop trading");
        isTradingEnabled = true;
        swapThreshold = balanceOf(pair) / 10000;
    }

    function swapBack() internal swapping {

        uint256 contractBalance = balanceOf(address(this));
        _allowances[address(this)][address(dexRouter)] = type(uint256).max;

        uint256 amountToSwap = contractBalance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        uint256 balanceBefore = address(this).balance;

        try dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ){} catch {
            return;
        }

        uint256 amountBNB = address(this).balance - (balanceBefore);
        uint256 totalBNBFee = totalFee;

        uint256 amountBNBReflection = amountBNB * (reflectionFee) / (totalBNBFee);
        uint256 amountBNBMarketing = amountBNB * (marketingFee) / (totalBNBFee);
        uint256 amountBNBcexFee = amountBNB * (cexFee) / (totalBNBFee);
        uint256 amountBNBDev = amountBNB * (devFee) / (totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        
            if(amountBNBMarketing > 0) {
                (bool mrktSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
                mrktSuccess = false;
                }
            if(amountBNBDev > 0) {
                (bool devSuccess,) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}("");
                devSuccess = false;
                }

            if(amountBNBcexFee > 0){
                (bool cexSuccess,) = payable(cexFeeReceiver).call{value: amountBNBcexFee, gas: 30000}(""); 
                cexSuccess = false;
            }

    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }


    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setPresaleAddress(address presale, bool yesno) external onlyOwner {
        isFeeExempt[presale] = yesno;
        isDividendExempt[presale] = yesno;
        liquidityAdd[presale] = yesno;
    }

    event ChangeFees(uint256 newGlobalFee);

    function setFees(uint256 _cexFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _devFee) external onlySafuDeveloper {
        require(!cannotChangeMore,"Owner has locked fees");
        cexFee = _cexFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        totalFee = _cexFee + (_reflectionFee) + (_marketingFee) + (devFee);
        checkFees(totalFee);
        emit ChangeFees(totalFee);
    }

    function checkFees(uint256 _totalFee) pure internal {
        require(_totalFee <= 10,"No more than 10%");
    }

    function lockTax() external onlySafuDeveloper {
        require(!cannotChangeMore,"Owner has locked fees");
        cannotChangeMore = true;
    }

    function setFeeReceivers(address _cexReceiver, address _marketingFeeReceiver, address _devFeeReceiver) external onlyOwner {
        require(!cannotChangeMore,"Owner has locked fees");
        cexFeeReceiver = payable(_cexReceiver);
        marketingFeeReceiver = payable(_marketingFeeReceiver);
        devFeeReceiver = payable(_devFeeReceiver);
    }

    event NewFeesSwapSettings(bool yesno, uint256 threshold);

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlySafuDeveloper {
        require(!cannotChangeMore,"Owner has locked fees");
        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit NewFeesSwapSettings(_enabled, _amount);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000 && gas > 1000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD)) - (balanceOf(ZERO));
    }

}