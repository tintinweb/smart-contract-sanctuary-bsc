/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.4;


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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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

    address private _owner;
    address public rewardToken;
    IBEP20 public REWARD;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //dont change that (:
    address WCRO = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
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

    //once the minimum distribution limit is hit after "minPeriod" it awards the reward
    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner); _;
    }

    constructor (address _router, address _rewardToken) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _owner = msg.sender;
        rewardToken = _rewardToken;
        REWARD = IBEP20(_rewardToken);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyOwner {
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

    function deposit() external payable override onlyOwner {
        uint256 balanceBefore = REWARD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WCRO;
        path[1] = address(REWARD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = REWARD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyOwner {
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
            REWARD.transfer(shareholder, amount);
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

contract Avoid is IBEP20, Auth {
    using SafeMath for uint256;

    //define the token you want to be auto-rewarded
    address REWARD = 0x8076C74C5e3F5852037F31Ff0093Eeb8c8ADd8D3;
    //do not change this
    address WCRO = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    //do not change this 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    //change the token name
    string public _name;
    //change the token symbol
    string public _symbol;
    //dont change that
    uint8 constant _decimals = 8;

    //defines the total supply --> 100 = 100e8 <-- THE e8 HAS TO BE THERE
    uint256 _totalSupply = 500_000_000e8;

    //2% of all token can be bought with one transaction
    uint256 public _maxTxAmount = _totalSupply.mul(2).div(100);

    //one wallet can only hold 2% of all token
    uint256 public _maxWalletToken = _totalSupply.mul(2).div(100);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    //changes the liquidityFee
    uint256 buyLiquidityFee = 3;
    uint256 sellLiquidityFee = 3;
    //changes the rewardFee
    uint256 buyReflectionFee = 2;
    uint256 sellReflectionFee = 2;
    //changes the marketingFee which goes to a specific wallet
    uint256 buyMarketingFee = 1;
    uint256 sellMarketingFee = 1;
    //changes the operationsFee which goes to a specific wallet
    uint256 buyOperationsFee = 3;
    uint256 sellOperationsFee = 3;
    // "buyLiquidityFee + buyReflectionFee + buyMarketingFee" = totalFee
    uint256 public totalFee = 8;
    //dont change that
    uint256 feeDenominator = 100;

    //defines the marketing wallet
    address public marketingFeeReceiver = address(0);
    address public operationsFeeReceiver = address(0);




    //DONT CHANGE ANYTHING FROM HERE
    
    address public autoLiquidityReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = false;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 45;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; // 0.01% of supply
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    struct Transaction {
        uint256 amount;
        uint256 timestamp;
    }
    mapping(address => Transaction[]) public _previousTransfers;
    mapping(address => address[]) public linkedWallets;

    constructor () Auth(msg.sender) {
        _name = "TESTT"; // "Terrae"
        _symbol = "TTT"; // "XXX"
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair = IDEXFactory(router.factory()).createPair(WCRO, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router), REWARD);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        // TO DO, manually whitelist this
        //isFeeExempt[_presaleContract] = true;
        //isTxLimitExempt[_presaleContract] = true;
        //isDividendExempt[_presaleContract] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // NICE!
        autoLiquidityReceiver = DEAD;
        marketingFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }
    
    function maxAllowedToWithdraw(address _walletAddress) public view returns (uint256) {
        if (!authorizations[_walletAddress]){
            uint256 maxToUse = _maxWalletToken;
            if (linkedWallets[_walletAddress].length > 0) {
                maxToUse = maxToUse.div(linkedWallets[_walletAddress].length + 1);
            }
            return maxToUse;
        } else {
            return uint256(-1);
        }
    }
    
    function hasLessThanMaxTransfers(address _walletAddress) public view returns (bool) {
        if (_previousTransfers[_walletAddress].length > 5) {
            uint256 transfers;
            for (uint256 index = 0; index < _previousTransfers[_walletAddress].length; index++) {
                if (_previousTransfers[_walletAddress][index].timestamp > block.timestamp  - 7 days) {
                    transfers++;
                }
            }
            if (transfers >= 5) {
                return false;
            } else {
                return true;
            }
        }
        return true;
    }
    
    function hasLessThanMaxIn24h(address _walletAddress) public view returns (bool) {
        if (_previousTransfers[_walletAddress].length > 0) {
            uint256 transfers;
            for (uint256 index = 0; index < _previousTransfers[_walletAddress].length; index++) {
                if (_previousTransfers[_walletAddress][index].timestamp > block.timestamp  - 24 hours ) {
                    transfers = transfers.add(_previousTransfers[_walletAddress][index].amount);
                }
            }
            if (transfers >= maxAllowedToWithdraw(_walletAddress)) {
                return false;
            } else {
                return true;
            }
        }
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        // max wallet code
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxAllowedToWithdraw(sender),"Total Holding is currently limited, you can not buy that much.");
            require(hasLessThanMaxTransfers(sender),"You have reached the maximum number of transfers in a week.");
            require(hasLessThanMaxIn24h(sender),"You have reached the maximum amount of token you can transfer in the 24 hours.");
        }
        
        
        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }


        // Checks max transaction limit
        checkTxLimit(sender, amount);

        // Liquidity, Maintained at 25%
        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, recipient) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
    struct Fees {
        uint256 marketingPercent;
        uint256 liquidtyPercent;
        uint256 rewardsPercent;
        uint256 operationsPercent;
        uint256 totalPercent;
        uint256 feeAmount;
        address[] path;
        uint256 balanceBefore;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        Fees memory fees;
        if(recipient == pair){ // Buy LP
            fees.marketingPercent = buyMarketingFee;
            fees.liquidtyPercent = buyLiquidityFee;
            fees.rewardsPercent = buyReflectionFee;
            fees.operationsPercent = buyOperationsFee;
        } else {
            fees.marketingPercent = sellMarketingFee;
            fees.liquidtyPercent = sellLiquidityFee;
            fees.rewardsPercent = sellReflectionFee;
            fees.operationsPercent = sellOperationsFee;
        }

        fees.totalPercent = fees.marketingPercent.add(fees.liquidtyPercent).add(fees.rewardsPercent).add(fees.operationsPercent);
        fees.feeAmount = amount.mul(fees.totalPercent).div(feeDenominator);


        // address[] memory path = new address[](2);
        fees.path[0] = address(this);
        fees.path[1] = WCRO;

        fees.balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            fees.feeAmount,
            0,
            fees.path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(fees.balanceBefore);
        
        uint256 amountToLiquify = swapThreshold.mul(fees.liquidtyPercent).div(fees.totalPercent).div(2);
        uint256 amountBNBLiquidity = amountBNB.mul(100).div(fees.liquidtyPercent.mul(100).div(fees.totalPercent));
        
        try distributor.deposit{value: amountBNB.mul(100).div(fees.rewardsPercent.mul(100).div(fees.totalPercent))}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNB.mul(100).div(fees.marketingPercent.mul(100).div(fees.totalPercent)));
        payable(operationsFeeReceiver).transfer(amountBNB.mul(100).div(fees.operationsPercent.mul(100).div(fees.totalPercent)));
        emit Transfer(sender, marketingFeeReceiver, amountBNB.mul(100).div(fees.marketingPercent.mul(100).div(fees.totalPercent)));
        emit Transfer(sender, operationsFeeReceiver, amountBNB.mul(100).div(fees.operationsPercent.mul(100).div(fees.totalPercent)));
        
        if(amountToLiquify > 0){
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
        return amount.sub(fees.feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function withdrawTokenBalance(address _tokenAddress, address _reciever) public onlyOwner {
        uint256 availableBalance = IBEP20(_tokenAddress).balanceOf(address(this));
        if (availableBalance > 0) {
            IBEP20(_tokenAddress).transfer(_reciever, availableBalance);
        }
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }



    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : buyLiquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WCRO;

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
        uint256 amountBNBReflection = amountBNB.mul(buyReflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(buyMarketingFee).div(totalBNBFee);
        uint256 amountBNBOperations = amountBNB.mul(buyOperationsFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (bool tmp2Success,) = payable(operationsFeeReceiver).call{value: amountBNBOperations, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;
        tmp2Success = false;

        if(amountToLiquify > 0){
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


    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
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

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _operationsFee) external authorized {
        buyLiquidityFee = _liquidityFee;
        buyReflectionFee = _reflectionFee;
        buyMarketingFee = _marketingFee;
        buyOperationsFee = _operationsFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_operationsFee);
        require(totalFee < feeDenominator/4);
    }
    
    function setSellFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _operationsFee) external authorized {
        sellLiquidityFee = _liquidityFee;
        sellReflectionFee = _reflectionFee;
        sellMarketingFee = _marketingFee;
        sellOperationsFee = _operationsFee;
        uint256 _totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_operationsFee);
        require(_totalFee < feeDenominator/4);
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
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    function indexOf(address[] memory arr, address searchFor) pure private returns (int256) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == searchFor) {
            return int256(i);
            }
        }
        return -1; // not found
    }
    
    function remove(address _wallet, uint256 index) public authorized {
        if (linkedWallets[_wallet].length > 1) {
            linkedWallets[_wallet][index] = linkedWallets[_wallet][linkedWallets[_wallet].length - 1];
        }
        linkedWallets[_wallet].pop();
    }
    
    function addWalletLink(address _walletA, address _walletB) public authorized {
        linkedWallets[_walletA].push(_walletB);
        linkedWallets[_walletB].push(_walletA);
    }
    
    function removeWalletLink(address _walletA, address _walletB) public authorized {
        int256 index = indexOf(linkedWallets[_walletA], _walletB);
        if (index >= 0) {
            remove(_walletA, uint256(index));
        }
        index = indexOf(linkedWallets[_walletB], _walletA);
        if (index >= 0) {
            remove(_walletB, uint256(index));
        }
    }
    
    function getLinkedWallets(address _wallet) public view returns(address[] memory) {
        return linkedWallets[_wallet];
    }

/* Airdrop Begins */


 function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    uint256 SCCC = 0;

    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}