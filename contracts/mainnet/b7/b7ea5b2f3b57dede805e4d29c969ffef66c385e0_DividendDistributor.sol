/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
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

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!NOT OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!NOT AUTHORIZED"); _;
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

interface IDEXRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

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

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 rewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IDEXRouter router;
    address public _rewardToken;
    address private _BUSD;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours; 
    uint256 public minDistribution = 1 * (10 ** 16); //Shareholder must have at least $0.01 BUSD in unpaid earnings

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

    //Pancakeswap Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 , 0xD99D1c33F9fC3444f8101754aBC46c52416550D1)

    constructor (address _router) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
        _rewardToken = address(rewardToken);
        _BUSD = address(BUSD);
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

    function deposit() public payable override onlyToken {
        if(_rewardToken == _BUSD){
            uint256 amount = rewardToken.balanceOf(address(this));
            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
        }
        else{
            uint256 balanceBefore = rewardToken.balanceOf(address(this));
            uint256 BUSDtoswap = BUSD.balanceOf(address(this));

            address[] memory path = new address[](2);
            path[0] = address(BUSD);
            path[1] = address(rewardToken);

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                BUSDtoswap,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);

            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
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

    function setRewardToken(IBEP20 RewardToken) external onlyToken {
        rewardToken = RewardToken;
        _rewardToken = address(RewardToken);
    }
}

contract UDTestBUSD9 is IBEP20, Auth {
    using SafeMath for uint256;

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 rewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address public _rewardToken;

    string constant _name = "UDTest BUSD 9";
    string constant _symbol = "UDTBUSD9";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = 50 * 1e18; // $50 BUSD

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) private lpPair;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;

    uint256 public reflectionFee = 800;
    uint256 public utilityFee = 200;
    uint256 public totalFee = 1000;
    uint256 public feeDenominator = 10000;
    uint256 public Cycle = 0;
    uint256 public target_buy;
    uint256 public target_sell;
    uint256 public _delta;
    uint256 public _deltafactor;
    uint256 public delta_buy;
    uint256 public delta_sell;

    bool public can_buy;
    bool public can_sell;

    address public utilityFeeReceiver;

    IDEXRouter public router;
    address public pair;

    DividendDistributor distributor;
    address public distributorAddress;

    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 20000; // 0.005%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    //Pancakeswap Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 , 0xD99D1c33F9fC3444f8101754aBC46c52416550D1)

    constructor (
        address _dexRouter
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(_dexRouter);
        distributorAddress = address(distributor);
        _rewardToken = address(rewardToken);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        utilityFeeReceiver = msg.sender;

        approve(_dexRouter, _totalSupply);
        _balances[msg.sender] = _totalSupply;

        target_buy = 0;
        target_sell = 0;
        _delta = 50;
        _deltafactor = 1;
        delta_buy = 50;
        delta_sell = 100;
        can_buy = false;
        can_sell = false;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function withdraw(address _token) external authorized {
        require(_token != address(0x0));
        uint256 remainingBalance = IBEP20(_token).balanceOf(address(this));
        require(remainingBalance > 0);
        IBEP20(_token).transfer(owner, remainingBalance);
    }

    function setRewardToken(IBEP20 RewardToken) external authorized {
        distributor.setRewardToken(RewardToken);
        rewardToken = RewardToken;
        _rewardToken = address(RewardToken);
    }

    function manageTrading(uint256 _type, bool _status) external authorized {
        if (_type == 0) {
            can_buy = _status;
        } else {
            can_sell = _status;
        }
    }

    function setDelta(uint256 delta) external authorized {
        require(delta >= 1, "Step size must be whole number greater than zero");
        _delta = delta;
        delta_buy = delta;
        delta_sell = delta_buy * 2;
        //With a deltafactor of 1: delta of 1 = 100%, 2 = 50%, 4 = 25%, 5 = 20%, 10 = 10%, 20 = 5%, 50 = 2%, 100 = 1%, 1000 = 0.1%, and so on
    }

    function setDeltaFactor(uint256 deltafactor) external authorized {
        require(deltafactor >= 1, "Step size must be whole number greater than zero");
        _deltafactor = deltafactor;
    }

    function setTargets() public authorized {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD);
        uint256 price = router.getAmountsOut(1e18, path)[1];
        target_buy = price.add(price.div(delta_buy).mul(_deltafactor));
        target_sell = price;
    }

    function ManAdjustTarget_buy() external authorized {
        target_buy = target_buy.add(target_sell.div(delta_buy).mul(_deltafactor));
    }

    function setTarget_buy(uint256 Target_Buy) external authorized {
        target_buy = Target_Buy;
    }

    function ManAdjustTarget_sell() external authorized {
        target_sell = target_sell.add(target_buy.div(delta_sell).mul(_deltafactor));
    }

    function setTarget_sell(uint256 Target_Sell) external authorized {
        target_sell = Target_Sell;
    }

    function adjustTarget_buy() private {
        target_buy = target_buy.add(target_sell.div(delta_buy).mul(_deltafactor));
    }

    function adjustTarget_sell() private {
        target_sell = target_sell.add(target_buy.div(delta_sell).mul(_deltafactor));
    }

    function adjustCycle() private {
        Cycle = Cycle + 1;
    }

    function setCycle(uint256 cycle) external authorized {
        Cycle = cycle;
    }

    function processTrade(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(BUSD);
            uint256 tokenPrice = router.getAmountsOut(1e18, path)[1];

            if (tokenPrice > target_buy && can_buy) {
                can_buy = false;
                can_sell = true;
                adjustTarget_buy();
            } else if (tokenPrice < target_sell && can_sell) {
                can_sell = false;
                can_buy = true;
                adjustTarget_sell();
                _maxTxAmount = _maxTxAmount + (50 * 1e18);
                adjustCycle();
            }

            uint256 investment = (tokenPrice * _amount).div(1e18);
            require(investment <= _maxTxAmount, "Transaction limit exceeded");

            // Check Sell
            if (lpPair[_recipient]) {
                require(can_sell, "Cannot sell");
            }
            // Check Buy
            else if (lpPair[_sender]) {
                require(can_buy, "Cannot buy");
            }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if (
            isFeeExempt[msg.sender] ||
            isFeeExempt[sender] ||
            (!lpPair[recipient] && !lpPair[sender])
        ) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            processTrade(sender, recipient, amount);

            if(shouldSwapBack()){ swapBack(); }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

            _balances[recipient] = _balances[recipient].add(amountReceived);

            if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
            if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

            try distributor.process(distributorGas) {} catch {}

            emit Transfer(sender, recipient, amountReceived);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        receiver = address(this);
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

    function swapBack() internal swapping {
        uint256 amountToSwap = balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD);
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBUSD = address(this).balance.sub(balanceBefore);

        uint256 amountReflection = amountBUSD.mul(reflectionFee).div(totalFee);
        uint256 amountUtility = amountBUSD.mul(utilityFee).div(totalFee);

        try distributor.deposit{value: amountReflection}() {} catch {}
        payable(utilityFeeReceiver).transfer(amountUtility);
            
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= 50 * 1e18); //minimum $50 BUSD, which is initial limit
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this));
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

    function setLPPair(address _pair) external authorized {
        lpPair[_pair] = true;
        approve(address(_pair), _totalSupply);
        pair = _pair;
    }

    function setFees(uint256 _reflectionFee, uint256 _utilityFee, uint256 _feeDenominator) external authorized {
        reflectionFee = _reflectionFee;
        utilityFee = _utilityFee;
        totalFee = _reflectionFee.add(_utilityFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }

    function setFeeReceivers(address _utilityFeeReceiver) external authorized {
        utilityFeeReceiver = _utilityFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

}