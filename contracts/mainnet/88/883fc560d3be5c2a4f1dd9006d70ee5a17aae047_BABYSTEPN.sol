/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: UNLICENSED

// Telegram: https://t.me/babystepntoken

pragma solidity 0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface ERC20 {
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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) external onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) external onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) external onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
}
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    ERC20 RWRD = ERC20(0x3019BF2a2eF8040C242C9a4c5c4BD4C81678b2A1); 
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 constant public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
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

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
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

contract BABYSTEPN is ERC20, Auth {
    using SafeMath for uint256;

    //events
    event Fupdated(uint256 _timeF);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetMaxWalletExempt(address _address, bool _bool);
    event SellFeesChanged(uint256 _liquidityFee, uint256 _marketingFee, uint256 _operationsFee, uint256 _rewardsFee);
    event BuyFeesChanged(uint256 _liquidityFee, uint256 _marketingFee, uint256 _operationsFee, uint256 _rewardsFee);
    event TransferFeeChanged(uint256 _transferFee);
    event SetFeeReceivers(address _liquidityReceiver, address _marketingReceiver, address _operationsFeeReceiver);
    event ChangedSwapBack(bool _enabled, uint256 _amount);
    event SetFeeExempt(address _addr, bool _value);
    event InitialDistributionFinished(bool _value);
    event ChangedMaxWallet(uint256 _maxWalletDenom);
    event ChangedMaxTX(uint256 _maxSellDenom);
    event ChangedDividendExempt(address holder, bool exempt);
    event ChangedDistributorSettings(uint256 gas);
    event ChangedDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution);
    event BlacklistUpdated(address[] addresses, bool status);
    event SingleBlacklistUpdated(address _address, bool status);
    event SetTxLimitExempt(address holder, bool exempt);
    event updateMinPeriod(uint256 _period);

    address private WBNB;
    address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private ZERO = 0x0000000000000000000000000000000000000000;

    string constant private _name = "Baby Stepn";
    string constant private _symbol = "$BABYSTEPN";
    uint8 constant private _decimals = 18;

    uint256 constant private _totalSupply = 1000000000* 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _maxWalletAmount = _totalSupply / 100;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMaxWalletExempt;
    mapping (address => bool) public isDividendExempt;

    //distributor
    DividendDistributor public dividendDistributor;
    uint256 private distributorGas = 500000;

    //Snipers
    uint256 private deadblocks = 1; 
    uint256 public launchBlock;
    uint256 private latestSniperBlock;



    //buyFees
    uint256 private liquidityFee = 3;
    uint256 private marketingFee = 2;
    uint256 private opsFee = 1;
    uint256 private rewardsFee = 4; 


    //sellFees
    uint256 private sellFeeLiquidity = 4;
    uint256 private sellFeeMarketing = 6;
    uint256 private sellFeeOps = 1;
    uint256 private sellFeeRewards = 4; 

    //transfer fee
    uint256 private transferFee = 0;
    uint256 constant public maxFee = 25; 

    //totalFees
    uint256 private totalBuyFee = liquidityFee.add(marketingFee).add(opsFee).add(rewardsFee);
    uint256 private totalSellFee = sellFeeLiquidity.add(sellFeeMarketing).add(sellFeeOps).add(sellFeeRewards);

    uint256 private feeDenominator  = 100;

    address private autoLiquidityReceiver;
    address private marketingFeeReceiver = 0xDEeA2030f7dDA3fE76E860f87F9f0AA93A824467;
    address private opsFeeReceiver = 0x94D46881d686206D35f2D6c31C7B7B64Fa175F50;

    IDEXRouter public router;
    address public pair;

    bool public tradingEnabled = false;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 5000;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        dividendDistributor = new DividendDistributor(address(router));

        setAutomatedMarketMakerPair(pair, true);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletExempt[msg.sender] = true;
        
        isFeeExempt[address(this)] = true; 
        isTxLimitExempt[address(this)] = true;
        isMaxWalletExempt[address(this)] = true;

        isMaxWalletExempt[pair] = true; 

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        autoLiquidityReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
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
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(tradingEnabled,"Trading not open yet");
        }

        if(shouldSwapBack()){ swapBack(); }


        uint256 amountReceived = amount; 

        if(automatedMarketMakerPairs[sender]) { //buy
            if(!isFeeExempt[recipient]) {
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[recipient], "TX Limit Exceeded");
                amountReceived = takeBuyFee(sender, recipient, amount);
            }

        } else if(automatedMarketMakerPairs[recipient]) { //sell
            if(!isFeeExempt[sender]) {
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeSellFee(sender, amount);
            }
        } else {	
            if (!isFeeExempt[sender]) {	
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeTransferFee(sender, amount);	
            }
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Fees
    function takeBuyFee(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 realFee = totalBuyFee;
        if (block.number < latestSniperBlock) {
            if (recipient != pair && recipient != address(router)) {
                realFee = 99;
            }
            }

        uint256 feeAmount = amount.mul(realFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);


        return amount.sub(feeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256){

        uint256 feeAmount = amount.mul(totalSellFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
            
    }

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256){
        uint256 feeAmount = amount.mul(transferFee).div(feeDenominator);
          
            
        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);	
            emit Transfer(sender, address(this), feeAmount); 
        }
            	
        return amount.sub(feeAmount);	
    }    

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender]
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance() external authorized {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueERC20(address tokenAddress, uint256 amount) external onlyOwner returns (bool) {
        return ERC20(tokenAddress).transfer(msg.sender, amount);
    }

    // switch Trading
    function tradingStatus(bool _status) external onlyOwner {
        require (!tradingEnabled, "Can't pause trading");
        tradingEnabled = _status;
        launchBlock = block.number;
        latestSniperBlock = block.number.add(deadblocks);

        emit InitialDistributionFinished(_status);
    }

    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquidityFee.add(sellFeeLiquidity);
        uint256 realTotalFee =totalBuyFee.add(totalSellFee);

        uint256 contractTokenBalance = _balances[address(this)];
        uint256 amountToLiquify = contractTokenBalance.mul(swapLiquidityFee).div(realTotalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        uint256 balanceBefore = address(this).balance;

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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = realTotalFee.sub(swapLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee.add(sellFeeLiquidity)).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee.add(sellFeeMarketing)).div(totalBNBFee);
        uint256 amountBNBReflection = amountBNB.mul(rewardsFee.add(sellFeeRewards)).div(totalBNBFee);
        uint256 amountBNBOps = amountBNB.sub(amountBNBLiquidity).sub(amountBNBMarketing).sub(amountBNBReflection);

        try dividendDistributor.deposit{value: amountBNBReflection}() {} catch {}

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing}("");
        (tmpSuccess,) = payable(opsFeeReceiver).call{value: amountBNBOps}("");
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }


    
    }

    // Admin Functions

    function setTxLimit(uint256 amount) external authorized {
        require(amount > _totalSupply / 10000, "Can't limit trading");
        _maxTxAmount = amount;

        emit ChangedMaxTX(amount);
    }

    function setMaxWallet(uint256 amount) external authorized {
        require(amount > _totalSupply / 10000, "Can't limit trading");
        _maxWalletAmount = amount;

        emit ChangedMaxWallet(amount);
    }

    function manage_blacklist(address[] calldata addresses, bool status) external onlyOwner {
        require (addresses.length < 200, "Can't add too many addresses at once");
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }

        emit BlacklistUpdated(addresses, status);
    }

    function setBL(address _address, bool _bool) external onlyOwner {
        isBlacklisted[_address] = _bool;
        
        emit SingleBlacklistUpdated(_address, _bool);
    }

    function updateF (uint256 _number) external onlyOwner {
        require(_number < 50, "Can't go that high");
        deadblocks = _number;
        
        emit Fupdated(_number);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;

        emit SetFeeExempt(holder, exempt);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;

        emit SetTxLimitExempt(holder, exempt);
    }

    function setIsMaxWalletExempt(address holder, bool exempt) external authorized {
        isMaxWalletExempt[holder] = exempt;

        emit SetMaxWalletExempt(holder, exempt);
        
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _opsFee, uint256 _rewardsFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        opsFee = _opsFee;
        rewardsFee = _rewardsFee;
        totalBuyFee = _liquidityFee.add(_marketingFee).add(_opsFee).add(_rewardsFee);
        feeDenominator = _feeDenominator;
        require(totalBuyFee <= maxFee, "Fees cannot be higher than 25%");
        require(_feeDenominator >= 100, "Can't limit trading");

        emit BuyFeesChanged(_liquidityFee, _marketingFee, _opsFee, _rewardsFee);
    }

    function setSellFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _opsFee, uint256 _rewardsFee, uint256 _feeDenominator) external authorized {
        sellFeeLiquidity = _liquidityFee;
        sellFeeMarketing = _marketingFee;
        sellFeeOps = _opsFee;
        sellFeeRewards = _rewardsFee;
        totalSellFee = _liquidityFee.add(_marketingFee).add(_opsFee).add(_rewardsFee);
        feeDenominator = _feeDenominator;
        require(totalSellFee <= maxFee, "Fees cannot be higher than 25%");
        require(_feeDenominator >= 100, "Can't limit trading");

        emit SellFeesChanged(_liquidityFee, _marketingFee, _opsFee, _rewardsFee);
    }

    function setTransferFee(uint256 _transferFee) external authorized {
        require(_transferFee < maxFee, "Fees cannot be higher than 25%");
        transferFee = _transferFee;

	    emit TransferFeeChanged(_transferFee); 
    }


    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _opsFeeReceiver) external authorized {
        require(_autoLiquidityReceiver != address(0) && _marketingFeeReceiver != address(0) && _opsFeeReceiver != address(0) , "Zero Address validation" );
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        opsFeeReceiver = _opsFeeReceiver;

        emit SetFeeReceivers(_autoLiquidityReceiver, _marketingFeeReceiver, _opsFeeReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit ChangedSwapBack(_enabled, _amount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
            require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

            automatedMarketMakerPairs[_pair] = _value;

            if(_value){
                _markerPairs.push(_pair);
            }else{
                require(_markerPairs.length > 1, "Required 1 pair");
                for (uint256 i = 0; i < _markerPairs.length; i++) {
                    if (_markerPairs[i] == _pair) {
                        _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                        _markerPairs.pop();
                        break;
                    }
                }
            }

            emit SetAutomatedMarketMakerPair(_pair, _value);
        }

    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair, "Can't exempt those");
        isDividendExempt[holder] = exempt;

        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }

        emit ChangedDividendExempt(holder, exempt);

    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);

        emit ChangedDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "gas too high");
        distributorGas = gas;

        emit ChangedDistributorSettings(gas);

    }
    
    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


}