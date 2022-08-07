/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

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
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
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
	
    function authorize(address adr) public onlyOwner {
	    require(adr != address(0), "Zero-Address");
        authorizations[adr] = true;
    }
	
    function unauthorize(address adr) public onlyOwner {
	    require(adr != address(0), "Zero-Address");
        authorizations[adr] = false;
    }
	
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
	
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
	
    function transferOwnership(address payable adr) public onlyOwner {
	    require(adr != address(0), "Zero-Address");
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
	
	function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
	
	function _transferOwnership(address newOwner) internal virtual {
        owner = newOwner;
        emit OwnershipTransferred(newOwner);
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

interface IAirDropDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function depositBUSD(uint256 amount) external;
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
	
    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
	
	event DistributionCriteriaUpdate(uint256 minPeriod, uint256 minDistribution);

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;
	
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);
	
    uint256 currentIndex;
	
    modifier onlyToken() {
        require(msg.sender == _token, "!TOKEN"); _;
    }

    constructor (address _router) {
        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
		emit DistributionCriteriaUpdate(minPeriod, minDistribution);
    }
	
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0)
		{
            addShareholder(shareholder);
        }
		else if(amount == 0 && shares[shareholder].amount > 0)
		{
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }
	
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
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

contract AirDrop is IAirDropDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
	  uint256 amount;
	  uint256 totalExcluded;
	  uint256 totalRealised;
    }
	
    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
	
	event DistributionCriteriaUpdate(uint256 minPeriod, uint256 minDistribution);
	event NewFundDeposit(uint256 amount);

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;
	
    uint256 public minPeriod = 24 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;
	
    modifier onlyToken() {
        require(msg.sender == _token, "!Token"); _;
    }
	
    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
		emit DistributionCriteriaUpdate(minPeriod, minDistribution);
    }
	
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0)
		{
            addShareholder(shareholder);
        }
		else if(amount == 0 && shares[shareholder].amount > 0)
		{
            removeShareholder(shareholder);
        }
		
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function depositBUSD(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
		emit NewFundDeposit(amount);
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }
	
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
	
    function claimAirDrop() external {
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

contract Gnox is IBEP20, Auth {
    using SafeMath for uint256;
	
    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
	
    string constant _name = "Gnox";
    string constant _symbol = "GNOX";
    uint8 constant _decimals = 9;
	
    uint256 constant _totalSupply = 5000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
	mapping (address => bool) isAirDropExempt;
	
	event WalletExemptFromFee(address holder, bool exempt);
    event NewFeeUpdated(uint256 liquidityFee, uint256 treasuryFee, uint256 reflectionFee, uint256 marketingFee);
    event NewFeeReceiversUpdated(address autoLiquidityReceiver, address marketingFeeReceiver, address treasuryFeeReceiver);
    event SwapBackSettingsUpdated(bool status, uint256 amount);
	
    uint256 liquidityFee = 100;
    uint256 treasuryFee = 600;
    uint256 reflectionFee = 100;
    uint256 marketingFee = 200;
    uint256 totalFee = 1000;
    uint256 constant feeDenominator = 10000;
	
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
	address public treasuryFeeReceiver;
	
    IDEXRouter public router;
    address public pair;
	
    DividendDistributor distributor;
	AirDrop airdrop;
	
    address public distributorAddress;
	address public airdropAddress;

    uint256 distributorGas = 500000;
	
    bool public swapEnabled = true;
	bool public airDropEnabled = false;
	
    uint256 public swapThreshold = _totalSupply / 2000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address _dexRouter) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
		
        distributor = new DividendDistributor(_dexRouter);
        distributorAddress = address(distributor);
		
		airdrop = new AirDrop();
		airdropAddress = address(airdrop);
		
        isFeeExempt[msg.sender] = true;
		
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
		
		isAirDropExempt[pair] = true;
        isAirDropExempt[address(this)] = true;
        isAirDropExempt[DEAD] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
		treasuryFeeReceiver = msg.sender;
		
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
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
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
	    require(recipient != address(0), "Zero-Address");
		
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
		
        if(shouldSwapBack()){ swapBack(); }
		
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
		
		if(!isAirDropExempt[sender]){ try airdrop.setShare(sender, _balances[sender]) {} catch {} }
        if(!isAirDropExempt[recipient]){ try airdrop.setShare(recipient, _balances[recipient]) {} catch {} }
		
		if(airDropEnabled)
		{
			 try airdrop.process(distributorGas.div(2)) {} catch {}
			 try distributor.process(distributorGas.div(2)) {} catch {}
		}
		else
		{
		    try distributor.process(distributorGas) {} catch {}
		}
		
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
	
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
	
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
    }
	
    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
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
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
		
        uint256 amountBNBLiquidity  = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing  = amountBNB.mul(marketingFee).div(totalBNBFee);
		uint256 amountBNBTreasury   = amountBNB.sub(amountBNBLiquidity).sub(amountBNBReflection).sub(amountBNBMarketing);
		
        try distributor.deposit{value: amountBNBReflection}() {} catch {}
		
        if(amountBNBLiquidity > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
		
		if(amountBNBMarketing > 0)
		{
		    swapBNBForBUSD(amountBNBMarketing, marketingFeeReceiver);
		}
		
		if(amountBNBTreasury > 0)
		{
		    swapBNBForBUSD(amountBNBTreasury, treasuryFeeReceiver);
		}
    }
	
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair, "Incorrect Address");
        isDividendExempt[holder] = exempt;
        if(exempt)
		{
            distributor.setShare(holder, 0);
        }
		else
		{
            distributor.setShare(holder, _balances[holder]);
        }
    }
	
	function setIsAirDropExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair, "Incorrect Address");
        isAirDropExempt[holder] = exempt;
        if(exempt)
		{
            airdrop.setShare(holder, 0);
        }
		else
		{
            airdrop.setShare(holder, _balances[holder]);
        }
    }
	
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
		emit WalletExemptFromFee(holder, exempt);
    }
	
    function setFees(uint256 _liquidityFee, uint256 _treasuryFee, uint256 _reflectionFee, uint256 _marketingFee) external authorized {
		liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_treasuryFee).add(_reflectionFee).add(_marketingFee);
		
		require(totalFee <= feeDenominator/4, "Fee is greater than 25%");
		emit NewFeeUpdated(_liquidityFee, _treasuryFee, _reflectionFee, _marketingFee);
    }
	
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _treasuryFeeReceiver) external authorized {
        require(_autoLiquidityReceiver != address(0) && _marketingFeeReceiver != address(0) && _treasuryFeeReceiver != address(0), "Zero-Address");
		
		autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
		treasuryFeeReceiver = _treasuryFeeReceiver;
		
		emit NewFeeReceiversUpdated(autoLiquidityReceiver, marketingFeeReceiver, treasuryFeeReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
		
		emit SwapBackSettingsUpdated(swapEnabled, swapThreshold);
    }
	
	function setAirDropEnabled(bool _enabled) external authorized {
        airDropEnabled = _enabled;
    }
	
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
	
	function setAirDropCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        airdrop.setDistributionCriteria(_minPeriod, _minDistribution);
    }
	
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "Gas is greater than limit");
        distributorGas = gas;
    }
	
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
	
	function swapBNBForBUSD(uint256 amount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(receiver),
            block.timestamp
        );
    }
	
	function depositAirDropBUSD(uint256 amount) public{
	   require(BUSD.balanceOf(msg.sender) >= amount, "BUSD balance not found on sender address");
	   
	   BUSD.transferFrom(msg.sender, airdropAddress, amount * 10**18);
	   airdrop.depositBUSD(amount * 10**18);
    }
}