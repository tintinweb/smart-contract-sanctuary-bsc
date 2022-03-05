/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT
//
//
// This is a slightly complex ponzi. Buy taxes start at 45%, but the buy tax is lowered the more it's purchased. Sell taxes start at 0% and work inversely (capping out at 45%).
// It's still a ponzi. Someone will buy after you do, simple as. They're just getting a better price.
//
// 0% - 45% TAX:
// - 38% BUSD
// - 5% LIQUIDITY
// - 2% MARKETING
// Telegram: https://t.me/ponzianniversary

pragma solidity ^0.8.11;

library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

interface IBEP20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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
}

abstract contract Ownable {
    address public owner;
    constructor(address owner_) {
        owner = owner_;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownership required."); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function transferOwnership(address payable adr) public onlyOwner {
        address oldOwner = owner;
        owner = adr;
        emit OwnershipTransferred(oldOwner, owner);
    }
	function renouceOwnership() public onlyOwner {
		emit OwnershipTransferred(owner, address(0));
		owner = address(0);
	}
    event OwnershipTransferred(address from, address to);
}

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function process(uint256 gas) external;
    function claimDividend() external;
    function deposit() external payable;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
	function setDistributionCriteriaNoPeriod(uint256 _minTokens, uint8 _decimalPlaces) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;
	
    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Mainnet
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet
//  IBEP20 BUSD = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); // Testnet - BUSD Token
//  address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet - WBNB Token
    address public tokenAddress;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    IDEXRouter router;
    mapping (address => Share) public shares;
    mapping (address => uint256) shareholderIndexes;
    uint256 public totalShares;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    mapping (address => uint256) shareholderClaims;
    uint256 public minPeriod = 1 hours; // min 1 hour delay
    uint256 public minDistribution = 1 * (10 ** 18); // 1 BUSD minimum auto send
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 currentIndex;
    bool initialized;

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == tokenAddress); _;
    }

    // In case rewards need to be injected to the distributor for any reason
    receive() external payable { }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
//  	    : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        tokenAddress = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setDistributionCriteriaNoPeriod(uint256 _minTokens, uint8 _decimalPlaces) external override onlyToken {
        minDistribution = _minTokens * (10 ** _decimalPlaces);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }
        if(amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        }
        else if(amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);
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
            if(currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            if(shouldDistribute(shareholders[currentIndex])) {
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

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0) { return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external override {
        distributeDividend(msg.sender);
    }

    function claimDividendAddress(address _shareholder) external {
        distributeDividend(_shareholder);
    }

    function claimDividendArray(address[] memory _shareholders) external {
        for (uint256 i = 0; i < _shareholders.length; i++) {
            distributeDividend(_shareholders[i]);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0) { return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    // Debug function - clears reflections tokens of too small an amount to be reflected to holders
    function clearRewards(address _address) external onlyToken {
        BUSD.transfer(_address, BUSD.balanceOf(address(this)));
    }
}

contract PonziAnniversary is IBEP20, Ownable {
    using SafeMath for uint256;

    string constant _name = "PonziAnniversary";
    string constant _symbol = "PonziAnniversary";
    uint8 constant _decimals = 18;
    uint256 public tSupply = 10 ** 12 * (10 ** _decimals);
    uint256 public startingReflectionFee = 380;
    uint256 public startingLiquidityFee = 50;
    uint256 public startingMarketingFee = 20;
    uint256 public reflectionFee = startingReflectionFee;
    uint256 public liquidityFee = startingLiquidityFee;
    uint256 public marketingFee = startingMarketingFee; // Again, I will be using this to fund Reflex. Not this project
    uint256 public feeDenominator = 1000;
    uint256 public startingFee = reflectionFee.add(liquidityFee).add(marketingFee);
    uint256 public currentFee = startingFee; // Assigned to startingFee on deployment, modified thereon from updateFees()
    uint256 public maxHold = tSupply / 50; // 1% max wallet
    address public marketingFeeReceiver = 0x5085392Bb88Bac1C955EBEC98B2C5E502a51a87F;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet - BUSD Token
	address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet - WBNB Token
//  address BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // Testnet - BUSD Token
//	address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet - WBNB Token
    address public debugger;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
    address public autoLiquidityReceiver;
    address[] public pairs;
    IDEXRouter public router;
    address pancakeV2BNBPair;
    DividendDistributor distributor;
    uint256 distributorGas = 600000;
    uint256 public launchedAt;
    bool public liquifyEnabled = true;
    bool public feesDynamic = true;
    bool inSwap;
    uint256 public swapThreshold = tSupply / 2000; // 0.05%
    event SwapBackSuccess(uint256 amount);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackFailed(string message);
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event MarketTransfer(bool status);

    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () Ownable(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
	//	router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    	autoLiquidityReceiver = DEAD;
        _allowances[address(this)][address(router)] = ~uint256(0);
        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));
        isDividendExempt[ZERO] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isMaxHoldExempt[ZERO] = true;
        isMaxHoldExempt[DEAD] = true;
        isMaxHoldExempt[pancakeV2BNBPair] = true;
        isMaxHoldExempt[address(this)] = true;
        isMaxHoldExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        debugger = msg.sender;
        _balances[msg.sender] = tSupply;
        emit Transfer(address(0), msg.sender, tSupply);
    }

    receive() external payable { }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function getOwner() external view override returns (address) { return owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function totalSupply() external view override returns (uint256) { return tSupply; }

    event DebuggerTransferred (address oldDebugger, address newDebugger);

    modifier onlyDebugger() {
        require(_isDebugger(msg.sender), "Only the debugger can do this."); _;
    }

    function _isDebugger(address account) internal view returns (bool) {
        return account == debugger;
    }

    function transferDebugger(address newDebugger) public onlyDebugger {
        address oldDebugger = debugger;
        debugger = newDebugger;
        emit DebuggerTransferred(oldDebugger, newDebugger);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if(shouldSwapBack()){
            swapBack();
        }
        if(feesDynamic) { updateFees(); } // The price of gas has JUST gone up... but we gotta keep it constant
        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); } // Launches trading once LP is added
        if(!isMaxHoldExempt[recipient]){
            require((_balances[recipient] + (amount - amount * currentFee / feeDenominator))<= maxHold, "Wallet cannot hold more than 2%");
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
        try distributor.process(distributorGas) {} catch {}
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    function getCurrentFee() public view returns (uint256) {
        if(launchedAt + 1 >= block.number) { return feeDenominator.sub(1); }
        return currentFee;
    }

    function updateFees() internal {
        reflectionFee = startingReflectionFee.mul(_balances[pancakeV2BNBPair].mul(10000)).div(getCirculatingSupply()).div(10000);
        liquidityFee = startingLiquidityFee.mul(_balances[pancakeV2BNBPair].mul(10000)).div(getCirculatingSupply()).div(10000);
        marketingFee = startingMarketingFee.mul(_balances[pancakeV2BNBPair].mul(10000)).div(getCirculatingSupply()).div(10000);
        currentFee = reflectionFee.add(liquidityFee).add(marketingFee);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true; // Does not take fees on transfer
        }
        return false;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feetoTake = currentFee;
        if (recipient == pancakeV2BNBPair) { // If it is a sell, get the sell fee by calculating the difference between the starting fee. This is less gas heavy than having 2 separate fees as storage variables
            feetoTake = startingFee.sub(currentFee);
        }
        uint256 feeAmount = amount.mul(feetoTake).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

/**
    // LiqRatio is basically the price of 1 coin as defined by the current BNB pair
    // Does not currently work
    function getLiqRatio() public view returns (uint256) {
        // return pancakeV2BNBPair.balance.div(_balances[pancakeV2BNBPair]);
        return pancakeV2BNBPair.balance.mul(100000).div(_balances[pancakeV2BNBPair]).div(100000);
    }

    // Does not currently work
    function getCurrentMcapBNB() public view returns (uint256) {
        //return getLiqRatio().div(getCirculatingSupply());
        return getLiqRatio().div(getCirculatingSupply().mul(10000)).div(10000);
    }
**/

    function getCirculatingSupply() public view returns (uint256) {
        return tSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }

    function setLaunchedAt(uint256 launched_) public onlyDebugger {
        launchedAt = launched_;
    }

    function setIsMaxHoldExempt(address holder, bool exempt) public onlyDebugger {
        isMaxHoldExempt[holder] = exempt;
    }

    function setIsDividendExempt(address holder, bool exempt) public onlyDebugger {
        require(holder != address(this) && holder != pancakeV2BNBPair);
        isDividendExempt[holder] = exempt;
        if(exempt) {
            distributor.setShare(holder, 0);
        }
        else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) public onlyDebugger {
        isFeeExempt[holder] = exempt;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) public onlyDebugger {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setTokenDistributionCriteria(uint256 _minTokens, uint8 _decimalPlaces) public onlyDebugger {
        distributor.setDistributionCriteriaNoPeriod(_minTokens, _decimalPlaces);
    }

    function setDistributorGas(uint256 gas) public onlyDebugger {
        require(gas <= 5000000);
        distributorGas = gas;
    }

    // Ability for people to claim their dividends from the distributor straight from the original contract
    function claimDividend() public {
        distributor.claimDividendAddress(msg.sender);
    }
    // Ability for anyone to claimDividend for an address
    function claimDividendAddress(address _shareholder) public {
        distributor.claimDividendAddress(_shareholder);
    }

    // Ability to pass a list of shareholders to have claim their dividends
    function claimDividendArray(address[] memory _shareholders) public {
        distributor.claimDividendArray(_shareholders);
    }

    // Ability for people to see their unpaid dividends straight from the original contract
    function getUnpaidEarningsDistributor() public view returns (uint256) {
        return distributor.getUnpaidEarnings(msg.sender);
    }

    // Ability for people to see the unpaid dividends for an address straight from the original contract
    function getUnpaidEarningsDistributorAddress(address _shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(_shareholder);
    }

    function addPair(address pair) public onlyDebugger {
        pairs.push(pair);
    }
    
    function removeLastPair() public onlyDebugger {
        pairs.pop();
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquifyEnabled ? liquidityFee : 0;
        uint256 amountToLiquify = _balances[address(this)].mul(swapLiquidityFee).div(currentFee).div(2);
        uint256 amountToSwap = _balances[address(this)].sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;
        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ) {
            uint256 amountBNB = address(this).balance.sub(balanceBefore);
            uint256 totalBNBFee = currentFee.sub(swapLiquidityFee.div(2));
            uint256 amountBNBLiquidity = amountBNB.mul(swapLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
            try distributor.deposit{value: amountBNBReflection}() {} catch {}
            (bool marketSuccess, ) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
            emit MarketTransfer(marketSuccess);
            if(amountToLiquify > 0){
                try router.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                ) {
                    emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
                } catch {
                    emit AutoLiquify(0, 0);
                }
            }
        } catch Error(string memory e) {
            emit SwapBackFailed(string(abi.encodePacked("SwapBack failed with error ", e)));
        } catch {
            emit SwapBackFailed("SwapBack failed without an error message from pancakeSwap");
        }
    }

    // Debug function - Manually update the fees (does not allow direct access to fees)
    function manualUpdateFees() public onlyDebugger {
        updateFees();
    }

    // Debug function - Enable dynamic fees (enabled by default)
    function enableDynamicFees() public onlyDebugger {
        feesDynamic = true;
        updateFees();
    }

    // Debug function - Disable dynamic fees in case there's an issue with calculating them, resets fees if _setStarting is true
    // Note: The combined fee amounts can't exceed startingFee, if startingFee needs to be modified then call setStartingFee
    function disableDynamicFees(bool _setStarting) public onlyDebugger {
        feesDynamic = false;
        if (_setStarting) {
            reflectionFee = startingReflectionFee;
            liquidityFee = startingLiquidityFee;
            marketingFee = startingMarketingFee;
            currentFee = reflectionFee.add(liquidityFee).add(marketingFee);
        }
    }

    // Debug function - Allows for manual override of fees, recommended to call disableDynamicFees first otherwise they will be overwritten
    function overrideFees(uint256 _reflectionFee, uint256 _liquidityFee, uint256 _marketingFee) public onlyDebugger {
        reflectionFee = _reflectionFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        currentFee = reflectionFee.add(liquidityFee).add(marketingFee);
    }

    // Debug function - Allows for manual override of startingFee, in case dynamic fees are disabled and currentFee exceeds it due to using overrideFees
    function setStartingFee(uint256 _startingFee) public onlyDebugger {
        startingFee = _startingFee;
    }

    // Debug function - Used if needed to modify the amounts being sold for divvies
    function setSwapThresholdDiv(uint256 _div) public onlyDebugger {
        swapThreshold = tSupply / _div;
    }

    // Debug function - Distributes stuck BNB to deployer
    function clearStuckBNB() public onlyDebugger {
        payable(debugger).transfer(address(this).balance);
    }

    // Debug function - Manually trigger a swapback if the contract is past threshold
    function manualSwapBack() public onlyDebugger {
        if(shouldSwapBack()){
            swapBack();
        }
    }

    // Debug function - In case of accident (let's face it, it has happened before)
    function clearDistributorRewards() public onlyDebugger {
        distributor.clearRewards(debugger);
    }

}