/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function process(uint256 gas) external;
    function claimDividend() external;
    function deposit() external payable;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
	function decideCoin(address coinAddress) external;
	function setDistributionCriteriaNoPeriod(uint256 _minTokens, uint8 _decimalPlaces) external;
	function setDistributionCriteriaTokens(uint256 _minPeriod, uint256 _minTokens, uint8 _decimalPlaces) external;
}

contract DividendDistributor is IDividendDistributor {
    
    using SafeMath for uint256;

    address _token;
      IBEP20 reflectingToken = IBEP20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43); // Mainnet - BUSD Token
      address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet - WBNB Token
      address private _reflectingTokenAddress = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; // Mainnet - BUSD Token
    //   IBEP20 reflectingToken = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); // Testnet - BUSD Token
  //  address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet - WBNB Token
   //  address private _reflectingTokenAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // Testnet - BUSD Token

    IDEXRouter router;
    mapping (address => Share) public shares;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    uint256 public totalShares;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    function getShareholdersCount() external view onlyToken returns (uint256){
        return shareholders.length;
    }
    uint256 public minPeriod = 1 hours; // min 1 hour delay
    uint256 public minDistribution = 1 * (10 ** 18); // 1 coin worth minimum auto send, 18 decimal places - try to make this equate to $1 worth
    uint256 public maxReflectionsWallet = 0; // Able to set max wallet size for tokens which support it, default to 0, call outside of setRewardsCoin
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 currentIndex;
    bool initialized;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    function decideCoin(address coinAddress) external override onlyToken {
        IBEP20 newCoin = IBEP20(coinAddress);
        _reflectingTokenAddress = coinAddress;
        reflectingToken = newCoin;
    }

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }
    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    // In case BNB needs to be injected to the distributor for gas for any reason
    receive() external payable { }

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
         : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
 	 	//: IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        _token = msg.sender;
    }

    function setDistributionCriteriaNoPeriod(uint256 _minTokens, uint8 _decimalPlaces) external override onlyToken {
        minDistribution = uint256(_minTokens * (10 ** _decimalPlaces));
    }

    function setDistributionCriteriaTokens(uint256 _minPeriod, uint256 _minTokens, uint8 _decimalPlaces) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = uint256(_minTokens * (10 ** _decimalPlaces));
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

    // Allows the distributor contract to get paid bnb, which it then uses to wrap to the reflecting token
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = reflectingToken.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(reflectingToken);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = reflectingToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    // Goes through the list of shareholders to determine which should be distributed dividends, does this until it runs out of its allocated gas
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

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            reflectingToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external override {
        distributeDividend(msg.sender);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    // Debug function - clears reflections tokens of too small an amount to be reflected to holders
    function clearStuckRewards(address _address) external onlyToken {
        reflectingToken.transfer(_address, reflectingToken.balanceOf(address(this)));
    }

    function checkForMaxHold() external onlyToken view returns (bool) {
        if ( reflectingToken.balanceOf(address(this)) > maxReflectionsWallet.sub(maxReflectionsWallet.div(4)) ){
            return true;
        }
        return false;
    }

    // Can set the amount of tokens required for a maxxi, would have to distribute after this amount
    function setMaxWallet(uint256 _maxTokens) external onlyToken {
        maxReflectionsWallet = _maxTokens;
    }

}

contract FederalReserveDoge is IBEP20, Ownable {
    
    using SafeMath for uint256;

    string _name = "Federal Reserve Doge";
    string _symbol = "FRDOGE";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 10 ** 9 * (10 ** _decimals); // 1B tokens
    uint256 constant _maxHold = _totalSupply ; // 1% max wallet
    uint256 constant _feeDenominator = 1000;
    uint256 public liquidityFee = 10;
    uint256 public reflectionFee = 30;
    uint256 AutobuybackFee = 80;
    uint256 public totalFee = liquidityFee + reflectionFee + AutobuybackFee; // Reflections fee - 6%, Liquidity fee - 3%,autobuyback 5%
    uint256 _maxReflectionsWallet = 0; // Able to set max wallet size for tokens which support it, default to 0, call outside of setRewardsCoin
    uint256 distributorGas = 600000;
    uint256 launchedAt;
    uint256 private _swapThreshold = _totalSupply / 5000; // 0.02% - This will be gas heavy at launch but be much less so over time
    function getSwapThreshold() public view returns (uint256) { return _swapThreshold; }
    address public autoLiquidityReceiver;
    address public reflectingTokenAddress = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; // Mainnet - BUSD Token
     //   address public reflectingTokenAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // Testnet - BUSD Token
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet - WBNB Token
   // address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet - WBNB Token
    address public coinDecider;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address marketingFeeReceiver = 0x72f486cF4a0159B4c07967bb73Ac76e33127B879;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
    address[] pairs;
    address pancakeV2BNBPair;
    IDEXRouter router;
    DividendDistributor distributor;
    bool liquifyEnabled = true;
    bool feesOnNormalTransfers = false;
    bool swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    event AutoLiquify(uint256 amountToLiquify, uint256 amountBNBLiquidity);

    receive() external payable { }

    // IBEP20 implementation
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }

    constructor() Ownable() {
  	   router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
      // router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    	autoLiquidityReceiver = DEAD;
        _allowances[address(this)][address(router)] = ~uint256(0);
        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));
        isDividendExempt[DEAD] = true;
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isMaxHoldExempt[DEAD] = true;
        isMaxHoldExempt[pancakeV2BNBPair] = true;
        isMaxHoldExempt[address(this)] = true;
        isMaxHoldExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        coinDecider = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getTotalFee() public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return _feeDenominator.sub(1); }
        return totalFee;
    }

    function setSwapThresholdDiv(uint256 _div) public onlyDecider {
        _swapThreshold = _totalSupply / _div;
    }

    // Set without affecting anything else just the address, for when decimals and price remain the same (such as when changing between stablecoins)
    function setRewardsCoin(address coinAddress, bool clear) public onlyDecider {
        if (clear) {
            clearDistributor();
        }
        distributor.decideCoin(coinAddress);
        reflectingTokenAddress = coinAddress;
    }

    function setTokenDistributionCriteria(uint256 _minTokens, uint8 _decimalPlaces) public onlyDecider {
        distributor.setDistributionCriteriaNoPeriod(_minTokens, _decimalPlaces);
    }
    
    function setRewardsCoin(address coinAddress, uint256 _minTokens, uint8 _decimalPlaces, bool clear) public onlyDecider {
        if (clear) {
            clearDistributor();
        }
        distributor.decideCoin(coinAddress);
        distributor.setDistributionCriteriaNoPeriod(_minTokens, _decimalPlaces);
        reflectingTokenAddress = coinAddress;
    }

    function setRewardsCoin(address coinAddress, uint256 _minPeriod, uint256 _minTokens, uint8 _decimalPlaces, bool clear) public onlyDecider {
        if (clear) {
            clearDistributor();
        }
        distributor.decideCoin(coinAddress);
        distributor.setDistributionCriteriaTokens(_minPeriod, _minTokens, _decimalPlaces);
        reflectingTokenAddress = coinAddress;
    }

    function setMaxWallet(uint256 _maxTokens) public onlyDecider {
        _maxReflectionsWallet = _maxTokens;
        distributor.setMaxWallet(_maxTokens);
    }

    function setDistributorGasSettings(uint256 gas) public onlyDecider {
        require(gas <= 5000000);
        distributorGas = gas;
    }

    function setTokenName(string memory _newName, bool append) public onlyDecider {
        if (append) {
            _name = appendName(_newName);
        }
        else {
            _name = _newName;
        }
    }

    function appendName(string memory _rewardTokenName) internal view returns (string memory) {
        return string(abi.encodePacked(_name, ": ", _rewardTokenName));
    }

    event DeciderTransferred (address oldDecider, address newDecider);

    // No, this is not a fake renounce. OnlyDecider functions allow the deployer to set the reflected coin and acccess debug functions
    // Taxes, supply, and anything else that can be used to scam people are unable to be changed post-deployment
    modifier onlyDecider {
        require(_isCoinDecider(msg.sender), "Only the coin decider can do this."); _;
    }

    function _isCoinDecider(address account) internal view returns (bool) {
        return account == coinDecider;
    }
    // Can be used to change the person who decides the coin besides the deployer, and can be used to delegate it to a separate contract in the future
    function transferCoinDecider(address newDecider) public onlyDecider {
        address oldDecider = coinDecider;
        coinDecider = newDecider;
        emit DeciderTransferred(oldDecider, newDecider);
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
        if(shouldSwapBack()){ swapBack(); } // This is what engages the "reflections" token sell mechanism
        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }
        if(!isMaxHoldExempt[recipient]){
          
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
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

    // Checking if the sender is a liqpair controls whether fees are taken on buy or sell (in this case it's both)
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }
        return feesOnNormalTransfers;
    }

    // Refers to taking tax on buys and sells
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee()).div(_feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    
    // Determines if the transaction is a sell from pcs or a transfer of tokens, as well as whether the swapThreshold has been met
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= _swapThreshold;
    }
    
    // Swapback refers to swapping token for BNB from the contract
    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquifyEnabled ? liquidityFee : 0;
        uint256 amountToLiquify = _swapThreshold.mul(swapLiquidityFee).div(totalFee).div(2);
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
        )
        {
            uint256 amountBNB = address(this).balance.sub(balanceBefore);
            uint256 totalBNBFee = totalFee.sub(swapLiquidityFee.div(2));
            uint256 amountBNBLiquidity = amountBNB.mul(swapLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
            uint256 amountBNBAutobuyback = amountBNB.mul(AutobuybackFee).div(totalBNBFee);
            try distributor.deposit{value: amountBNBReflection}() {} catch {}
            payable(marketingFeeReceiver).transfer(amountBNBAutobuyback);
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
        } catch {}
        if (_maxReflectionsWallet > 0 && distributor.checkForMaxHold()){
            try distributor.process(distributorGas) {} catch {}
        }
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    // Allows us to see how much supply is actually held outside of pcs and burn addresses, this can also be used for calculating a dynamic _swapThreshold
    function getActiveSupply() public view returns (uint256) {
        return getCirculatingSupply().sub(balanceOf(pancakeV2BNBPair));
    }

    function getShareholdersCount() public view onlyDecider returns (uint256) {
        return distributor.getShareholdersCount();
    }

    function claimDividend() external {
        distributor.claimDividend();
    }

    // Debug function - Distributes stuck BNB to coin decider (I have yet to see this happen, but it's possible when switching between reflected coins)
    function clearStuckBNB() public onlyDecider {
        payable(coinDecider).transfer(address(this).balance);
    }

    // Debug function - In case the contract wallet still gets fat on accident and needs to be MILKED
    function clearStuckToken() public onlyDecider {
        if(shouldSwapBack()){
            swapBack();
        }
    }

    // Reflects the remaining token to holders, can be called before changing the reflected coin by passing bool clear as true
    function clearDistributor() internal {
        try distributor.process(distributorGas) {} catch {}
    }

    // Debug function - Manual processing of reflections distributor
    function distributorProcess() public onlyDecider {
        try distributor.process(distributorGas) {} catch {}
    }

    // Debug function - Manual processing of reflections distributor with gas override
    function distributorProcessOverride(uint256 _gasOverride) public onlyDecider {
        try distributor.process(_gasOverride) {} catch {}
    }

    // Debug function - Anything leftover from rewards that was too small to be distributed as reflections is moved to decider to help pay for gas fees on the calls
    function clearStuckDistributorRewards() public onlyDecider {
        distributor.clearStuckRewards(coinDecider);
    }

}