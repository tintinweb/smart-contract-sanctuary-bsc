/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/**
   Simple Token for Sparklab Factory
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

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

abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface PCSFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PCSv2Router {
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

contract Sparklab_Factory is IBEP20, Ownable {

    address constant private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private ZERO = 0x0000000000000000000000000000000000000000;
    address public marketingFeeReceiver;
    address public teamFeeReceiver;
    address public pair;

    string private _name;
    string private _symbol;
    string public ContractCreator = "@FrankFourier";

    uint8 constant  private _decimals = 18;

    uint256 private _supply;
    uint256 private _totalSupply =  _supply * 10**_decimals;
    uint256 private _maxTx_factor;
    uint256 private _maxWallet_factor;
    uint256 public _maxTxAmount = _totalSupply / 1000 * _maxTx_factor;
    uint256 public _maxWalletToken = _totalSupply / 1000 * _maxWallet_factor;

    mapping (address => uint256)                      private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool)                         private isFeeExempt;
    mapping (address => bool)                         private isTxLimitExempt;
    mapping (address => bool)                         private isWalletLimitExempt;
    // store addresses that are automatic market maker pairs
    mapping (address => bool)                         public  automatedMarketMakerPairs;
    //Anti Dump
    mapping (address => uint256)                      private _lastBuy;
    
    uint256 private liquidityFee;
    uint256 private marketingFee;
    uint256 private teamFee;
    uint256 public totalFee = liquidityFee + marketingFee + teamFee;
    uint256 constant public feeDenominator   = 100;
    uint256 public sellMultiplier = 100;
    uint256 public buyMultiplier = 100;
    uint256 public transferMultiplier = 100;
    uint256 public launchedAt = 0;
    uint256 public launch_time = 0;
    uint256 public targetLiquidity = 100;
    uint256 public targetLiquidityDenominator = 100;
    uint256 public deadBlocks_highslippage = 2;
    uint256 public antiDump_factor;
    uint256 public antiDump_duration;

    PCSv2Router public router;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public swapThreshold = _totalSupply / 10000;
    uint256 public swapTransactionThreshold = _totalSupply * 5 / 10000;
    uint256 public coolDownTime;

    bool    public launched;
    bool    public swapEnabled = true;
    bool    public swapandliquifyEnabled = true;
    bool    private inSwap;
    bool    public coolDownEnabled;
    bool    public AntibotEnabled;
    bool    public antiDump;
    bool    private initialized;

    constructor (address _marketingFeeReceiver, address _teamFeeReceiver, string memory __name, string memory __symbol, uint256 __supply, uint256 _liquidityFee, uint256 _marketingFee, uint256 _teamFee) Ownable(msg.sender) {
        router = PCSv2Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        _setAutomatedMarketMakerPair(address(pair), true);

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[ZERO] = true;

        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        _name = __name;
        _symbol = __symbol;
        _supply = __supply;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    //to recieve BNB
    receive() external payable {}

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function initialize(uint256 __maxTx_factor, uint256 __maxWallet_factor, uint256 _sellMultiplier, uint256 _buyMultiplier, uint256 _transferMultiplier, uint256 _deadBlocks_highslippage, uint256 _antiDump_factor, uint256 _antiDump_duration, uint256 _coolDownTime, bool _coolDownEnabled, bool _AntibotEnabled, bool _antiDump) public {
        require(!initialized, "Contract instance has already been initialized");

        _maxTx_factor = __maxTx_factor;
        _maxWallet_factor = __maxWallet_factor;
        sellMultiplier = _sellMultiplier;
        buyMultiplier = _buyMultiplier;
        transferMultiplier = _transferMultiplier;
        deadBlocks_highslippage = _deadBlocks_highslippage;
        antiDump_factor = _antiDump_factor;
        antiDump_duration = _antiDump_duration;
        coolDownTime = _coolDownTime;
        coolDownEnabled = _coolDownEnabled;
        AntibotEnabled = _AntibotEnabled;
        antiDump = _antiDump;
    }

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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 100);
        require(amount <= _totalSupply);
        _maxWalletToken = amount;
    }

    function setMaxTx(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000);
        require(amount <= _totalSupply);
        _maxTxAmount = amount;
    }

    function setAutomatedMarketMakerPair(address _pair, bool value) public onlyOwner {
        require(_pair != pair, "The pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(_pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address _pair, bool value) internal {
        automatedMarketMakerPairs[_pair] = value;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner && recipient != owner && sender != address(this) && !isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(launched,"Trading not open yet");
            if(coolDownEnabled && automatedMarketMakerPairs[sender]){
                require(block.timestamp - _lastBuy[recipient] >= coolDownTime, "Cooldown enabled");
                _lastBuy[recipient] = block.timestamp;
            }
        }

        if (sender != owner && recipient != owner && recipient != address(this) && sender != address(this) && recipient != address(DEAD) && recipient != address(ZERO) && !isFeeExempt[sender]){
            require(amount <= _maxTxAmount || isTxLimitExempt[sender],"TX Limit Exceeded");
            if(!automatedMarketMakerPairs[recipient])
            require((amount + balanceOf(recipient)) <= _maxWalletToken || isWalletLimitExempt[recipient],"Max wallet holding reached");
        }

        // Swap
        if(!automatedMarketMakerPairs[sender]
            && !inSwap
            && swapEnabled
            && amount > swapTransactionThreshold
            && _balances[address(this)] >= swapThreshold) {
            swapBack();
        }

        // Actual transfer
        _balances[sender] = _balances[sender] - amount;   
        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
        _balances[recipient] = _balances[recipient] + (amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 multiplier = transferMultiplier;
        if(automatedMarketMakerPairs[recipient]){
            multiplier = sellMultiplier;
        } else if(automatedMarketMakerPairs[sender]){
            multiplier = buyMultiplier;
        }

        if(antiDump && launch_time + antiDump_duration > block.timestamp && automatedMarketMakerPairs[recipient])
        multiplier = antiDump_factor * multiplier;

        uint256 feeAmount = amount * (totalFee) * (multiplier) / (feeDenominator * 100);

        if(AntibotEnabled) {
            if(automatedMarketMakerPairs[sender] && (launchedAt + (deadBlocks_highslippage)) > block.number)
                feeAmount = amount/ (100) * (99);
        }

        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount - (feeAmount);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // launch
    function launch(uint256 _deadBlocks_highslippage) external onlyOwner {
        require(launched == false, "Already launched");
        launched = true;
        launchedAt = block.number;
        launch_time = block.timestamp;
        deadBlocks_highslippage = _deadBlocks_highslippage;
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }

    function swapBack() internal swapping { 
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = 0;
        uint256 amountToSwap = 0;
        if (swapandliquifyEnabled) {
        amountToLiquify = swapThreshold * dynamicLiquidityFee / totalFee / (2);
        amountToSwap = swapThreshold - amountToLiquify;
        } else amountToSwap = swapThreshold;
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 _balance = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        _balance = address(this).balance - _balance;
        uint256 totalBNBFee = totalFee - (dynamicLiquidityFee / (2));
        uint256 amountBNBLiquidity = _balance * dynamicLiquidityFee / totalBNBFee / (2);
        uint256 amountBNBMarketing = _balance * marketingFee / totalBNBFee;
        uint256 amountBNBTeam = _balance - amountBNBLiquidity - amountBNBMarketing;

        if (!swapandliquifyEnabled)
        amountBNBMarketing += amountBNBLiquidity;
        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected BNB transfer");
        (bool TeamSuccess, /* bytes memory data */) = payable(teamFeeReceiver).call{value: amountBNBTeam, gas: 30000}("");
        require(TeamSuccess, "receiver rejected BNB transfer");

        if(swapandliquifyEnabled) {
            if (amountToLiquify > 0) {
                router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
            }
        }
    }

    function _swapTokensForFees(uint256 amount) external onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this));
        require(amount <= swapThreshold); //cooldown
        require(contractTokenBalance >= amount);
        swapBack();
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        require(_buy <= 200, "Fees too high");
        require(_sell <= 200, "Fees too high");
        require(_trans <= 200, "Fees too high");
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function updateCooldown(bool state, uint256 time) external onlyOwner{
        require(time <= 10 minutes);
        coolDownTime = time;
        coolDownEnabled = state;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsMaxwalletExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _teamFee) external onlyOwner {
        require(_liquidityFee + _marketingFee + _teamFee <= 10, "Total Fees cannot be more than 10%");
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        totalFee = _liquidityFee + _marketingFee + _teamFee;
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _teamFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _transaction) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        swapTransactionThreshold = _transaction;
    }

    function setSwapandLiquifySettings(bool _enabled) external onlyOwner {
        swapandliquifyEnabled = _enabled;
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return isFeeExempt[account];
    }

    function isExcludedFromTxLimit(address account) external view returns(bool) {
        return isTxLimitExempt[account];
    }

    function isExcludedFromMaxWallet(address account) external view returns(bool) {
        return isWalletLimitExempt[account];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(token != address(this), "Can't drain contract balance");
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this))); 
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
       return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy * (balanceOf(pair) * (2)) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function get_tokenLiquidity() public view returns (uint256) {
        return(balanceOf(pair));
    }

    function get_WBNBLiquidity() public view returns (uint256) {
        return IBEP20(WBNB).balanceOf(pair);
    }

    /* Airdrop Begins */
    function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        uint256 cumulative_amount = 0;

        for(uint i=0; i < addresses.length; i++){
           cumulative_amount = cumulative_amount + tokens[i];
        }

        require(balanceOf(msg.sender) >= cumulative_amount, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],tokens[i]);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}