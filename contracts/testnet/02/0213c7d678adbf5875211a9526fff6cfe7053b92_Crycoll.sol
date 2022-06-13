/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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
    function shouldPrintTokens() external view returns(bool);
    function currentPrice() external view returns(uint256);
    function burn(uint256 amount) external returns (bool);    
	function printToken(uint256 amount)external returns (bool); 
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
    function getPair(address tokenA, address tokenB) external returns (address pair);  
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
        ) external returns (uint amountA, uint amountB);

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
    
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
        ) external view returns (uint[] memory amounts);
    
}

interface ICrycollBank {
    function depositToBank(address shareholder, uint256 amount) external;   
    function addDeposit(uint256 amount) external;
    function addBankFund(uint256 amount) external;
    function clientSharesAmount(address client) external view returns(uint256);
}

interface IresenderWallet {
    function resend(uint256 amountCRY) external;
}

contract ResenderWallet is IresenderWallet {
    using SafeMath for uint256;

    IBEP20 busdToken;
    address cryAddress;

    modifier onlyToken() {
       require(msg.sender == cryAddress); _;
    }

    constructor (address busd) {
        cryAddress = msg.sender;
        busdToken = IBEP20(busd);  
        }

    function resend(uint256 amountBUSD) external override onlyToken {
            busdToken.transfer(cryAddress, amountBUSD);
        }
    }

contract Crycoll is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address ZERO = 0x0000000000000000000000000000000000000000;
    string constant _name = "Crycoll";
    string constant _symbol = "CRY";    
    uint8 constant _decimals = 18;

    uint256 _totalSupply;
    uint256 public _maxTxAmount;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    
    uint256 liquidityFee = 0;
    uint256 bankFundFee = 20;
    uint256 burnFee = 0;
    uint256 dividendFee = 30;
    uint256 hedgeFundFee = 10;
    uint256 totalFee = 60;
    uint256 feeDenominator = 1000;
    IBEP20 LPtokens;
    IBEP20 BUSDtokens;

	bool public dynamicFees;
    bool public priceRescueEnabled = true; 
    bool public printStopped;
    bool public stimulus;
    uint256 public stimulusFactor;
    uint256[] public previousTotalSupply;
    uint256[] public previousPrice;
    uint256 allowableInflation = 60;

    uint256 lpAmountMul = 8;

    address public hedgeFund;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
    address dexRouter_;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    uint256 public unlockLPTime;
    uint256 public timePeriodInflation = 30;
    uint256 public timePeriodPrice = 7;
    uint256 dailyUpdate;
    address public resenderAddress;
    address public bankAddress;
    ICrycollBank bank;
    ResenderWallet resender;
    bool public swapEnabled;
    bool public initLPEnabled = true;
    uint256 public swapThreshold = 600 * (10 ** 18);
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        dexRouter_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        router = IDEXRouter(dexRouter_);
        pair = IDEXFactory(router.factory()).createPair(address(this), BUSD);
        bank = ICrycollBank(bankAddress);
        resender = new ResenderWallet(BUSD);
        resenderAddress = address(resender); 
        LPtokens = IBEP20(pair);
        BUSDtokens = IBEP20(BUSD);
        hedgeFund = 0xFE03D73a04eE2C5Bf508A0dcCf6205Afc6f1a2c8;
        _maxTxAmount = 25000 * (10**18);
        _allowances[address(this)][dexRouter_] = 2**256 - 1;
        _allowances[address(this)][address(pair)] = 2**256 - 1;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[hedgeFund] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[hedgeFund] = true;

		 _print(address(this), 548000 * (10 ** 18));
		 _print(hedgeFund, 42000 * (10 ** 18));
		 _print(msg.sender, 10000 * (10 ** 18));
       
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function burn(uint256 amount) public returns (bool) {_burn(msg.sender, amount);  return true; }
    function printToken(uint256 amount) public returns (bool) {_printToken(amount);  return true; }	
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
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if(recipient != bankAddress){ checkTxLimit(sender, amount); }
 
        if(shouldDistributeFee()){ distributeFee(); }

        if(shouldProvideLP(amount) && sender == pair){ provideLP(amount); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(recipient == bankAddress){ bank.depositToBank(sender, amountReceived); }          
        updateMarketCondition();

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
        require((amount <= _maxTxAmount && launched()) || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(address sender, address receiver) public view returns (uint256) {
        if (dynamicFees && receiver == pair) { 
            uint256 priceImpact = priceChange();
            if (priceImpact <= 700) { return totalFee.mul(3);  } // strong downtrend
            else if (priceImpact <= 1000) { return totalFee.mul(2);  }// downtrend 
         }
         else if (dynamicFees && sender == pair) {
            uint256 priceImpact = priceChange();
            if (priceImpact <= 700) { return totalFee.div(3);  }
            else if (priceImpact <= 1000) { return totalFee.div(2);  } 
         }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(sender, receiver)).div(feeDenominator);
        if(receiver == bankAddress) { feeAmount = 0; }
        if(stimulus && sender == pair) {
           feeAmount = 0;
           uint256 stimulusAmount = amount.mul(stimulusFactor).div(feeDenominator);
           _print(receiver, stimulusAmount);
        }
        if(feeAmount > 0){
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }
    
    function updateMarketCondition() internal {
        if(dailyUpdate <= block.timestamp && launched()){
            updatePreviousPrice();
            updateTotalSupply();
            dailyUpdate = block.timestamp.add(1 days);
            emit conditionUpdated(inflationRate(), priceChange());    
        }   
    }   

    function currentPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD;
        uint256[] memory amounts = router.getAmountsOut(10**18, path);
        return amounts[1].mul(10**18).div(amounts[0]);
    }

    function updatePreviousPrice() internal {
        previousPrice.push();
        previousPrice[previousPrice.length.sub(1)] = currentPrice();
    }

    function updateTotalSupply() internal {
        previousTotalSupply.push();
        previousTotalSupply[previousTotalSupply.length.sub(1)] = _totalSupply;
    }

    function inflationRate() public view returns (uint256) {
        uint256 index = previousTotalSupply.length.sub(timePeriodInflation);
        return _totalSupply.mul(1000).div(previousTotalSupply[index]);
    }	

    function priceChange() public view returns (uint256) {
        uint256 index = previousPrice.length.sub(timePeriodPrice);
        return currentPrice().mul(1000).div(previousPrice[index]);
    }	
    
    function priceRescue() internal view returns (bool) {
        return priceChange() < 700
        && priceRescueEnabled;
    }
	
    function shouldPrintTokens() public view returns (bool) {
        return inflationRate() <= allowableInflation.add(1000)
        && !priceRescue()
		&& !printStopped
		&& launched();
    }	
    
    function shouldDistributeFee() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && launched()
        && _balances[address(this)] >= swapThreshold;
    }

    function shouldProvideLP(uint256 amount) internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && initLPEnabled
        && launched()
        && _balances[pair] <= 200000 * (10**18)
        && _balances[address(this)] >= amount.mul(2);
    }

    function distributeFee() internal {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToken = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 burnAmount = swapThreshold.mul(burnFee).div(totalFee);
        if(burnAmount > 0){
            _burn(address(this), burnAmount); 
        }     

        uint256 amountToSwap = swapThreshold.sub(amountToken).sub(burnAmount);
        uint256 balanceBefore = BUSDtokens.balanceOf(resenderAddress);
        swapBack(amountToSwap);
        uint256 amountBUSD = BUSDtokens.balanceOf(resenderAddress).sub(balanceBefore);
        resender.resend(amountBUSD);

        uint256 totalBUSDFee = totalFee.sub(burnFee).sub(dynamicLiquidityFee.div(2));

        uint256 amountBUSDLiquidity = amountBUSD.mul(dynamicLiquidityFee).div(totalBUSDFee).div(2);
        uint256 amountBUSDdividend = amountBUSD.mul(dividendFee).div(totalBUSDFee);
        uint256 amountBUSDhedgeFund = amountBUSD.mul(hedgeFundFee).div(totalBUSDFee);
        uint256 amountBUSDBankFund = amountBUSD.mul(bankFundFee).div(totalBUSDFee);

        BUSDtokens.transfer(hedgeFund, amountBUSDhedgeFund);
        BUSDtokens.transfer(bankAddress, amountBUSDdividend.add(amountBUSDBankFund));
        try bank.addDeposit(amountBUSDdividend) {} catch {}
        try bank.addBankFund(amountBUSDBankFund) {} catch {}

        if(amountToken > 0){
           router.addLiquidity(
                address(this),
                BUSD,
                amountToken,
                amountBUSDLiquidity,
                0,
                0,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(amountBUSDLiquidity, amountToken);
        }		
    }

    function swapBack(uint256 amount) internal swapping {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = BUSD;
    
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                resenderAddress,
                block.timestamp
            );
    }

    function provideLP(uint256 amount) internal {
        amount = amount.mul(lpAmountMul).div(10);
        uint256 amountToSwap = amount.div(2);
        uint256 balanceBefore = BUSDtokens.balanceOf(resenderAddress);
        swapBack(amount.div(2));
        uint256 amountBUSD = BUSDtokens.balanceOf(resenderAddress).sub(balanceBefore);
        resender.resend(amountBUSD);

        router.addLiquidity(
            address(this),
            BUSD,
            amountToSwap,
            amountBUSD,
            0,
            0,
            address(this),
            block.timestamp
        );

        emit AutoLiquify(amountBUSD, amountToSwap);     		
    }

    function updateTimePeriod(uint256 price, uint256 inflation) external authorized {
        require(previousPrice.length - price >= 0, "There is no price data for this period");
        require(previousTotalSupply.length - inflation >= 0, "There is no total supply data for this period");
        timePeriodPrice = price;
        timePeriodInflation = inflation;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function updateRouter(address newAddress) external onlyOwner {
        require(newAddress != address(router), "The router already has that address");
        router = IDEXRouter(newAddress);
    }

    function setBankAddress(address newAddress) external onlyOwner {
        bankAddress = newAddress;
        isFeeExempt[bankAddress] = true;
        isTxLimitExempt[bankAddress] = true;
        bank = ICrycollBank(bankAddress);
    }

    function launch() external onlyOwner {
        require(!launched(), "Already launched");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
        /**
         * Initial data
        */
        for (uint k = 0; k < 30; k++){ updateTotalSupply(); }
        for (uint k = 0; k < 7; k++){ updatePreviousPrice(); }
        dynamicFees = true;
    }

    function _print(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: print to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);    
        emit Transfer(ZERO, account, amount);
    }
	
    function _printToken(uint256 amount) internal {
        require(msg.sender == bankAddress, "Only Crycoll Bank can print tokens");
		_print(bankAddress, amount); 
    }	

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, ZERO, amount);
    }

    function unlockLP() external authorized {
        require(block.timestamp >= unlockLPTime, "The liquidity pool is still locked");	
		if(LPtokens.balanceOf(address(this)) > 0){  
        LPtokens.transfer(owner, LPtokens.balanceOf(address(this)));
        }
    }    

    function lockLP(uint256 duration) external authorized {	
        require(block.timestamp >= unlockLPTime, "The liquidity pool is still locked");
        unlockLPTime = block.timestamp.add(duration * 1 days);
    }  

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply.div(10000), "Invalid amount");
        _maxTxAmount = amount;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _bankFundFee, uint256 _dividendFee, uint256 _hedgeFundFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;
        bankFundFee = _bankFundFee;
        dividendFee = _dividendFee;
        hedgeFundFee = _hedgeFundFee;
        totalFee = _liquidityFee.add(_burnFee).add(_dividendFee).add(_hedgeFundFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }

    function setNewFeeReceiver(address _hedgeFund) external onlyOwner {
        hedgeFund = _hedgeFund;
    }
 
    function printSettings(bool _printStopped, bool _priceRescueEnabled, uint256 _allowableInflation) external authorized {
        printStopped = _printStopped;
        priceRescueEnabled = _priceRescueEnabled;
        allowableInflation = _allowableInflation;
    }     
    
    function setSwapBackSettings(bool _enabled, bool _Ienabled,uint256 _lpMul, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        initLPEnabled = _Ienabled;
        lpAmountMul = _lpMul;
        swapThreshold = _amount * (10 ** 18);  
    }

    function setDynamicFees(bool _enabled) external authorized {
        dynamicFees = _enabled;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setStimulus(bool enabled, bool inflationary) external authorized {
        stimulus = enabled;
        if(inflationary){ stimulusFactor = totalFee; }
        else stimulusFactor = burnFee;    
        emit Stimulus(enabled, stimulusFactor); 
    }
    
    function feeInfo() public view returns (
        uint256 Liquidity_fee, 
        uint256 BankFund_fee,
        uint256 Burn_fee, 
        uint256 Dividend_fee, 
        uint256 HedgeFund_fee, 
        uint256 Total_fee, 
        uint256 totalFeeForBuyers, 
        uint256 totalFeeForSellers) {
        return (
            liquidityFee, 
            bankFundFee,
            burnFee, 
            dividendFee, 
            hedgeFundFee, 
            totalFee, 
            getTotalFee(pair, msg.sender), 
            getTotalFee(msg.sender, pair));
    }    

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(_totalSupply);
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountCRY);
    event tokensBought(address buyer, uint256 amountCRY);
    event Stimulus(bool enabled, uint256 stimulusFactor); 
    event conditionUpdated(uint256 inflation, uint256 priceChange);
}