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
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

/* Our DividendDistributor contract responsible for distributing the earn token */
contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

  // EARN
     //address BUSDAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
     IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);//Testnet
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IBEP20 _WBNB = IBEP20(WBNB);
     IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10 ** 12);

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
        router = _router != address(0) ? IDEXRouter(_router)
      //  : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
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
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
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

/* Token contract */
contract DeerRun is IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;
    // Addresses
    //address BUSDAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
     IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);//Testnet
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEV = 0x3411B759fE6BA39D7a963d01ac4632ba285f5D63;

    // These are owner by default
    address private marketingFeeReceiver;

    // Name and symbol
    string constant _name = "this";
    string constant _symbol = "ONEE";
    uint8 constant _decimals = 9;

    // Total supply
    uint256 _totalSupply = 1_000_000 * (10**_decimals); // 1mill
    // Mappings
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) public isBlacklisted;

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
    uint256 totalFee;

    event SwapAndSend(uint256 tokensSwapped, uint256 bnbSend);

    // Sell amount of tokens when a sell takes place
    uint256 public swapThreshold = 1_000 * 10**_decimals; // 1% of supply
    bool private swapEnabled;

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
    constructor() Ownable() {
        if (block.chainid == 56) {
            router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // BSC Pancake Testnet Router
        } else {
            revert();
        }
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));

        // Should be the owner wallet/token distributor
        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;

        // Exempt from dividend
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Set the marketing and liq receiver to the owner as default
        marketingFeeReceiver = 0x99e7E31F98247eE70C284D0Ca98886dE8aE8554e; //compte 8

        _balances[_presaler] = _totalSupply;
        rewardFee = rewardFeeSell;
        emit Transfer(address(0), _presaler, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
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
        return owner();
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
        return approve(spender, type(uint256).max);
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
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    // Main transfer function
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (amount == 0) {
            _transfer(sender, recipient, 0);
            return true;
        }
        // Check if buying or selling
        bool isSell = recipient == pair;

        totalFee = isSell ? totalFeeSell : totalFeeBuy;
        // Check if we should do the swapback
        if (
            recipient == pair &&
            !swapEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            swapBack();
        }

        uint256 amountReceived = isFeeExempt[sender]
            ? amount
            : takeFee(sender, amount);
        _transfer(sender, recipient, amountReceived);

        try distributor.process(distributorGas) {} catch {}
        return true;
    }

    // Set the correct fees for buying or selling

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount;
        feeAmount = amount.mul(totalFee).div(100);
        _transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    // Main swapback to sell tokens for WBNB
    function swapBack() internal {
        swapEnabled = true;
         liquidityFee = liquidityFeeBuy + liquidityFeeSell;
        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;
        uint256 amountToLiquify = swapThreshold
            .mul(dynamicLiquidityFee)
            .div(totalFee)
            .div(2);
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

        uint256 marketingFee = marketingFeeSell.add(marketingFeeBuy);
        uint256 devFee = devFeeSell.add(devFeeBuy);

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 rewardBNB = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(
            totalBNBFee
        );
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        try distributor.deposit{value: rewardBNB}() {} catch {}
        payable(marketingFeeReceiver).sendValue(amountBNBMarketing);
        payable(DEV).sendValue(amountBNBDev);
        emit SwapAndSend(amountToSwap, amountBNB);

        if (amountToLiquify > 0) {
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
    function setBuyFees(
        uint256 _liquidityFeeBuy,
        uint256 _marketingFeeBuy,
        uint256 _devFeeBuy
    ) external onlyOwner {
        require(
            _liquidityFeeBuy + _marketingFeeBuy + _devFeeBuy < 5,
            "Buy fees cant be more than 5%"
        );
        liquidityFeeBuy = _liquidityFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        devFeeBuy = _devFeeBuy;
        totalFeeBuy = _liquidityFeeBuy.add(_marketingFeeBuy).add(_devFeeBuy);
    }

    // Set our sell fees
    function setSellFees(
        uint256 _liquidityFeeSell,
        uint256 _rewardFeeSell,
        uint256 _marketingFeeSell,
        uint256 _devFeeSell
    ) external onlyOwner {
        require(
            _liquidityFeeSell + _marketingFeeSell + _devFeeSell < 5,
            "Buy fees cant be more than 5%"
        );
        require(_rewardFeeSell < 10, "because of jeeters");
        liquidityFeeSell = _liquidityFeeSell;
        rewardFee = _rewardFeeSell;
        marketingFeeSell = _marketingFeeSell;
        devFeeSell = _devFeeSell;
        totalFeeSell = _liquidityFeeSell
            .add(_rewardFeeSell)
            .add(_marketingFeeSell)
            .add(_devFeeSell)
            .add(rewardFee);
    }

    // Set swapBack settings
    function setSwapBackSettings(uint256 _amount) external onlyOwner {
        swapThreshold = (_totalSupply * _amount) / 10000;
    }

    // Set target liquidity
    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        onlyOwner
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    // Send BNB to marketingwallet
    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(DEV).sendValue(contractETHBalance);
    }

    // Set criteria for auto distribution
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    // Let people claim there dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }



    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
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
    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    // Get if we are over liquified or not
    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(
            token != address(this),
            "Owner cannot claim contract's balance of its own tokens"
        );
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IBEP20 ERC20token = IBEP20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        uint256 senderBalance = _balances[sender];
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}