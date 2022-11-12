import "./Address.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IBEP20.sol";
import "./IDEXStuff.sol";

//SPDX-License-Identifier: MITa

pragma solidity ^0.8.16;

/**
 * BEP20 standard interface.
 */

/* Interface for the DividendDistributor */

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

/* Our DividendDistributor contract responsible for distributing the earn token */
contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 amountForXmas;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // EARN
    IBEP20  BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalXmasDividends;
    uint256 public totalDistributed;
    uint256 public totalxmasDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareXmas;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 2000;
    uint256 public xmasDate = 1671997113;
    uint256 public minDistribution = 0; //5 * (10 ** 12); // 5 busd

    uint256 currentIndex;

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

        if(shouldDistributeXmas()) {
            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(totalDividends).div(totalShares));
        } else {
            uint256 halfAmount = amount.div(2);
            totalDividends = totalDividends.add(halfAmount);
            totalXmasDividends = totalXmasDividends.add(halfAmount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(totalDividends).div(totalShares));
            dividendsPerShareXmas = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(totalXmasDividends).div(totalShares));
        }
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

        function shouldDistributeXmas() internal view returns (bool) {
        return xmasDate < block.timestamp;
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

    function distributeXmaxDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 xmaxAmount = getCumulativeXmasDividends(shares[shareholder].amountForXmas);
        if(xmaxAmount > 0){
            totalxmasDistributed = totalxmasDistributed.add(xmaxAmount);
            BUSD.transfer(shareholder, xmaxAmount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(xmaxAmount);
        }
    }
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }

    function claimXmaxDividend(address shareholder) external onlyToken{
        distributeXmaxDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalXmasDividends = getCumulativeXmasDividends(shares[shareholder].amountForXmas);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shouldDistributeXmas()) shareholderTotalDividends += shareholderTotalXmasDividends;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getUnpaidXmasEarnings(address shareholder) public view returns (uint256) {
        return getCumulativeXmasDividends(shares[shareholder].amountForXmas);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

      function getCumulativeXmasDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShareXmas).div(dividendsPerShareAccuracyFactor);
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

/* Token contract */
contract DeerRun is IBEP20, Ownable {
    using SafeMath for uint256;

    // Addresses
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEV = 0x3411B759fE6BA39D7a963d01ac4632ba285f5D63;

    // These are owner by default
    address private marketingFeeReceiver;

    // Name and symbol
    string constant _name = "elonMusj";
    string constant _symbol = "MUST";
    uint8 constant _decimals = 9;

    // Total supply
    uint256 _totalSupply = 1_000_000 * (10 ** _decimals); // 20mill

    // Max wallet and TX
    uint256 public _maxBuyTxAmount = _totalSupply * 100 / 10000; // 2% on launch or 2B tokens
    uint256 public _maxSellTxAmount = _totalSupply * 100 / 10000; // 1% or 1B tokens
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 10000; // 2% or 2B tokens

    // Mappings
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public isBlacklisted;
    
    // Buy Fees
    uint256 public liquidityFeeBuy = 1; 
    uint256 public reflectionFeeBuy = 0;
    uint256 public marketingFeeBuy = 1;
    uint256 public devFeeBuy = 1;
    uint256 public totalFeeBuy = 3;

    // Sell fees
    uint256 public liquidityFeeSell = 1;
    uint256 public rewardFeeSell = 3;
    uint256 public marketingFeeSell = 1;
    uint256 public devFeeSell = 1;
    uint256 public totalFeeSell = 6;

    // Fee variables
    uint256 liquidityFee;
    uint256 rewardFee;
    uint256 marketingFee;
    uint256 devFee;
    uint256 totalFee;
    


    // Sell amount of tokens when a sell takes place
    uint256 public swapThreshold = 10_000 * 10 ** _decimals; // 1% of supply
    bool public swapEnabled = true;

    // Liquidity
    uint256 targetLiquidity = 200;
    uint256 targetLiquidityDenominator = 100;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Other variables
    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    bool public tradingOpen = true;

    /* Token constructor */
    constructor () Ownable() {
        if (block.chainid == 56) {
            router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router =  IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // BSC Pancake Testnet Router
        } else {
            revert();
        }
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));
        
        // Should be the owner wallet/token distributor
        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;
        isTxLimitExempt[_presaler] = true;
        
        // Exempt from dividend
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Set the marketing and liq receiver to the owner as default
        marketingFeeReceiver = 0x99e7E31F98247eE70C284D0Ca98886dE8aE8554e; //compte 8

        _balances[_presaler] = _totalSupply;
        emit Transfer(address(0), _presaler, _totalSupply);
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
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }




    // settting the max wallet in percentages
    // NOTE: 1% = 100
     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = _totalSupply.mul(maxWallPercent).div(10000);

    }

    // Main transfer function
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        // Check if buying or selling
        bool isSell = recipient == pair; 
        // Set buy or sell fees
        setCorrectFees(isSell);

        // Check if we should do the swapback
        if(shouldSwapBack()){ swapBack(); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    // Set the correct fees for buying or selling
    function setCorrectFees(bool isSell) internal {
        if(isSell){
            liquidityFee = liquidityFeeSell;
            rewardFee = rewardFeeSell;
            marketingFee = marketingFeeSell;
            devFee = devFeeSell;
            totalFee = totalFeeSell;
        } else {
            liquidityFee = liquidityFeeBuy;
            marketingFee = marketingFeeBuy;
            devFee = devFeeBuy;
            totalFee = totalFeeBuy;
        }
    }
    // Check for maxTX
    function checkTxLimit(address sender, uint256 amount, address recipient, bool isSell) internal view {
        if (recipient != owner()){
            if(isSell){
                require(amount <= _maxSellTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
            } else {
                require(amount <= _maxBuyTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
            }
        }
    }



    // Check maxWallet
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if (sender != owner() && recipient != owner() && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != ZERO && recipient != DEV){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }
    }

    // Check if sender is not feeExempt
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    // Take the normal total Fee or the GREED Fee
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount;
        feeAmount = amount.mul(totalFee).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    // Check if we should sell tokens
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    // Main swapback to sell tokens for WBNB
    function swapBack() internal {
        swapEnabled = true;
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
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
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 rewardBNB = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee); 


        try distributor.deposit{value: rewardBNB}() {} catch {}
        (bool successMarketing, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (bool successDev, /* bytes memory data */) = payable(DEV).call{value: amountBNBDev, gas: 30000}(""); 
        require(successMarketing, "marketing receiver rejected ETH transfer");
        require(successDev, "dev receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ZERO,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
        swapEnabled = false;
    }
    // Exempt from fee
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    // Set our buy fees
    function setBuyFees(uint256 _liquidityFeeBuy, uint256 _marketingFeeBuy, uint256 _devFeeBuy) external onlyOwner {
        liquidityFeeBuy = _liquidityFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        devFeeBuy = _devFeeBuy;
        totalFeeBuy = _liquidityFeeBuy.add(_marketingFeeBuy).add(_devFeeBuy);
    }

    // Set our sell fees
    function setSellFees(uint256 _liquidityFeeSell, uint256 _reflectionFeeSell, uint256 _marketingFeeSell, uint256 _devFeeSell) external onlyOwner {
        liquidityFeeSell = _liquidityFeeSell;
        rewardFee = _reflectionFeeSell;
        marketingFeeSell = _marketingFeeSell;
        devFeeSell = _devFeeSell;
        totalFeeSell = _liquidityFeeSell.add(_reflectionFeeSell).add(_marketingFeeSell).add(_devFeeSell);
    }
    // Set swapBack settings
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _totalSupply * _amount / 10000; 
    }

    // Set target liquidity
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    // Send BNB to marketingwallet
    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(DEV).transfer(contractETHBalance);
    }
    
    // Set criteria for auto distribution
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
    
    // Let people claim there dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function claimXmaxDividend() external {
        distributor.claimXmaxDividend(msg.sender);
    }

    
    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 

    function getUnpaidXmasEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidXmasEarnings(shareholder);
    }

    // Set gas for distributor
    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }
    
    // Get the circulatingSupply
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    // Get the liquidity backing
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    // Get if we are over liquified or not
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}