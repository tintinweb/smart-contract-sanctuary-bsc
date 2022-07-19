/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**

 * Name         : The Pup&Dad Trip
 * Symbol       : PUPDAD
 * Telegram ENG : https://t.me/ThePupandDadTrip
 * Telegram CN  : https://t.me/ThePupandDadTripCN
 * Twitter ENG  : https://twitter.com/PupandDadTrip
 * Twitter CN   : https://twitter.com/PupandDadTripCN
 
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

pragma solidity ^0.8.4;

interface IBEP20 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity ^0.8.4;

interface IPANCAKERouter {
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

pragma solidity ^0.8.4;

contract RWRD_DISTRIBUTOR is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 RWRD     = IBEP20(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D); 
    address WBNB    = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IPANCAKERouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor  = 10 ** 36;
    uint256 public minPeriod                        = 2 hours;
    uint256 public minDistribution                  = 120000 * (10 ** 14);

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
            ? IPANCAKERouter(_router)
            : IPANCAKERouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
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

pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor ()  {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentry call.");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract ThePupandDadTrip is Context, IBEP20, Ownable, ReentrancyGuard{ 
    using SafeMath for uint256;

    address public RWRD                         = (0x2859e4544C4bB03966803b044A93563Bd2D0DD4D); // SHIB
    address WBNB                                = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address zeroReceiver                        = 0x0000000000000000000000000000000000000000;
    address burnReceiver                        = 0x000000000000000000000000000000000000dEaD;
    address marketingReceiver                   = 0xc708993cbED370D8F2374d3cA1A3260267375B1F;

    string constant _name                       = "The Pup&Dad Trip";
    string constant _symbol                     = "PUPDAD";
    uint8 constant _decimals                    = 9;

    uint256 _totalSupply                        = 1000000000 * (10 ** _decimals);
            
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => uint256) private _transactionCheckpoint;

    mapping (address => bool) private isFeeExempt;
    mapping (address => bool) public  isBlacklisted;
    mapping (address => bool) private isTxLimitExempt;
    mapping (address => bool) private isDividendExempt;
    mapping (address => bool) private isMaxWalletExempt;
    mapping (address => bool) private isBuyCooldownExempt;

    address private autoLiquidityReceiver;
    address private ecoReceiver;

    uint256 public rewardFee                    = 400;
    uint256 public marketingFee                 = 500;
    uint256 public ecoFee                       = 300;
    uint256 public liquidityFee                 = 300;

    uint256 public sellRewardFee                = 400;
    uint256 public sellMarketingFee             = 500;
    uint256 public sellEcoFee                   = 300;
    uint256 public sellLiquidityFee             = 300;

    uint256 public totalFee                     = rewardFee + marketingFee + ecoFee + liquidityFee;
    uint256 public totalSellFee                 = sellRewardFee + sellMarketingFee + sellEcoFee + sellLiquidityFee;
    uint256 private feeDenominator               = 10000;

    IPANCAKERouter public router;
    address public pair;
    
    uint256 targetLiquidity                     = 30;
    uint256 targetLiquidityDenominator          = 100;

    uint256 public _buyCooldownTime             = 0;

    RWRD_DISTRIBUTOR distributor; 
    uint256 distributorGas                      = 500000;

    bool public swapEnabled                     = true;
    uint256 public _maxTxLimit                  = _totalSupply / 50;   // 2 %
    uint256 public _maxWallet                   = _totalSupply / 50;   // 2 %
    uint256 public swapThreshold                = _totalSupply / 400;  // 0,0025%
    
    event AutoLiquify(uint256 bnbAmount, uint256 tokensAmount);

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        router = IPANCAKERouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        distributor = new RWRD_DISTRIBUTOR(address(router));

        isFeeExempt[msg.sender]                     = true;
        isFeeExempt[address(this)]                  = true;
        isFeeExempt[marketingReceiver]              = true;

        isTxLimitExempt[msg.sender]                 = true;
        isTxLimitExempt[address(this)]              = true;

        isDividendExempt[pair]                      = true;
        isDividendExempt[address(this)]             = true;
        isDividendExempt[burnReceiver]              = true;
        isDividendExempt[zeroReceiver]              = true;

        isBuyCooldownExempt[pair]                   = true;
        isBuyCooldownExempt[msg.sender]             = true;
        isBuyCooldownExempt[address(this)]          = true;
        isBuyCooldownExempt[address(router)]        = true;

        isMaxWalletExempt[pair]                     = true;
        isMaxWalletExempt[msg.sender]               = true;
        isMaxWalletExempt[burnReceiver]             = true;
        isMaxWalletExempt[zeroReceiver]             = true;
        isMaxWalletExempt[address(this)]            = true;
        isMaxWalletExempt[address(router)]          = true;

        autoLiquidityReceiver                       = msg.sender;
        ecoReceiver                                 = msg.sender;

        _balances[msg.sender]                       = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance.");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        require(amount <= _maxTxLimit || isTxLimitExempt[sender], "Max token limit for this trade exceeded. Try a lower amount.");
        require(isBlacklisted[sender] == false, "You are blacklisted.");
        require(isBlacklisted[recipient] == false, "The recipient has been blacklisted.");

        require(isMaxWalletExempt[recipient] || balanceOf(recipient) + amount <= _maxWallet,
        "Max tokens limit for this account exceeded. Or try lower amount.");
        require(isBuyCooldownExempt[sender] || block.timestamp >= _transactionCheckpoint[sender] + _buyCooldownTime,
        "Wait for transaction cooldown time to end before making a transaction.");
        require(isBuyCooldownExempt[recipient] || block.timestamp >= _transactionCheckpoint[recipient] + _buyCooldownTime,
        "Wait for transaction cooldown time to end before making a transaction.");

        _transactionCheckpoint[sender] = block.timestamp;
        _transactionCheckpoint[recipient] = block.timestamp;

        if(sender != pair && !inSwap && swapEnabled 
        && _balances[address(this)] >= swapThreshold)
        { swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance.");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance.");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

    function swapBack() internal swapping {
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

        uint256 receivedBNB = address(this).balance.sub(balanceBefore);

        uint256 swapPercent = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity              = receivedBNB.mul(dynamicLiquidityFee).div(swapPercent).div(2);
        uint256 amountBNBReward                 = receivedBNB.mul(rewardFee).div(swapPercent);
        uint256 amountBNBMarketing              = receivedBNB.mul(marketingFee).div(swapPercent);
        uint256 amountBNBEco                    = receivedBNB.mul(ecoFee).div(swapPercent);


        try distributor.deposit{value: amountBNBReward.add(balanceBefore)}() {} catch {}
            (bool tmpSuccess,) = payable(marketingReceiver).call{value: amountBNBMarketing, gas: 30000}("");
            (tmpSuccess,) = payable(ecoReceiver).call{value: amountBNBEco, gas: 30000}("");

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
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function setBuyCooldownTime(uint256 buycooldowntime) public onlyOwner {
        _buyCooldownTime = buycooldowntime;
    }

    function setMaxTxLimit(uint256 amount) external onlyOwner {
        _maxTxLimit = amount.mul(10**_decimals);
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        _maxWallet = amount.mul(10**_decimals);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount.mul(10**_decimals);
    }
    
    function setIsDividendExempt(address holder, bool exempt) public onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsBuyCooldownExempt(address account, bool excluded) public onlyOwner {
        isBuyCooldownExempt[account] = excluded;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsMaxWalletExempt(address account, bool excluded) public onlyOwner {
        isMaxWalletExempt[account] = excluded;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _rewardFee, uint256 _marketingFee, uint256 _ecoFee, uint256 _liquidityFee, uint256 _feeDenominator) external onlyOwner {

        rewardFee               = _rewardFee;
        marketingFee            = _marketingFee;
        ecoFee                  = _ecoFee;
        liquidityFee            = _liquidityFee;

        totalFee                = _rewardFee + _marketingFee + _ecoFee + _liquidityFee;

        feeDenominator          = _feeDenominator;
        require(totalFee < feeDenominator, "Fees cannot be more than 99%");
    }

    function setSellFees(uint256 _sellRewardFee, uint256 _sellMarketingFee, uint256 _sellEcoFee, uint256 _sellLiquidityFee, uint256 _feeDenominator) external onlyOwner {

        sellRewardFee           = _sellRewardFee;
        sellMarketingFee        = _sellMarketingFee;
        sellEcoFee              = _sellEcoFee;
        sellLiquidityFee        = _sellLiquidityFee;

        totalSellFee            = _sellRewardFee + _sellMarketingFee + _sellEcoFee + _sellLiquidityFee;

        feeDenominator          = _feeDenominator;
        require(totalSellFee < feeDenominator, "Fees cannot be more than 20%");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingReceiver, address _ecoReceiver) external onlyOwner {
        autoLiquidityReceiver   = _autoLiquidityReceiver;
        marketingReceiver       = _marketingReceiver;
        ecoReceiver             = _ecoReceiver;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setRWRDDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }
    
    function blacklistSingleWallet(address account) external onlyOwner {
        if(isBlacklisted[account] == true) return;
        isBlacklisted[account] = true;
        setIsDividendExempt(account, true); 
    }

    function unBlacklistSingleWallet(address account) external onlyOwner {
         if(isBlacklisted[account] == false) return;
        isBlacklisted[account] = false;
        setIsDividendExempt(account, false);
    }
    
    function blacklistMultipleWallets(address[] calldata accounts) external onlyOwner {
        require(accounts.length < 50, "Can't blacklist more then 600 address in one transaction.");
        for (uint256 i; i < accounts.length; ++i) {
            isBlacklisted[accounts[i]] = true;
            setIsDividendExempt(accounts[i], true);
        }
    }

    function unBlacklistMultipleWallets(address[] calldata accounts) external onlyOwner {
        require(accounts.length < 50, "Can't blacklist more then 600 address in one transaction.");
        for (uint256 i; i < accounts.length; ++i) {
            isBlacklisted[accounts[i]] = false;
            setIsDividendExempt(accounts[i], false);
        }
    }

    function recoverTokens(address tokenAddress, uint256 amountToRecover) external onlyOwner {
        IBEP20 token = IBEP20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amountToRecover, "Not Enough Tokens in contract to recover.");

        if(amountToRecover > 0)
            token.transfer(msg.sender, amountToRecover);
    }

    function recoverBNB() external onlyOwner {
        address payable recipient = payable(msg.sender);
        if(address(this).balance > 0)
            recipient.transfer(address(this).balance);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(burnReceiver)).sub(balanceOf(zeroReceiver));
    }
    
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

}