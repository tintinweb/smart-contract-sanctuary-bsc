/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface BEP20 {
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

interface InterfaceLP {
    function sync() external;
}

contract TokenContract is BEP20, Ownable {

    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Test";
    string constant _symbol = "TEST";
    string constant ContractCreator = "@FrankFourier";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  1 * 10**8 * 10**_decimals;
    uint256 public _maxWalletToken = _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isMaxWalletExempt;

    uint256 public marketingFee     = 4;
    uint256 public teamFee          = 2;
    uint256 public liquidityFee     = 4;
    uint256 public totalFee         = liquidityFee + marketingFee + teamFee;
    uint256 public feeDenominator   = 100;

    uint256 public sellMultiplier = 120;
    uint256 public buyMultiplier = 100;
    uint256 public transferMultiplier = 100;

    uint256 public deadBlocks = 40;
    uint256 public launchedAt = 0;

    address public marketingFeeReceiver;
    address public teamFeeReceiver;
    address public liquidityReceiver;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;

    PCSv2Router public router;
    address public pair;
    InterfaceLP public pairContract;

    bool public launched;
    bool public gasLimitActive = false;
    uint256 public gasPriceLimit = 10 gwei;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000;
    uint256 public swapTransactionThreshold = _totalSupply * 5 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        router = PCSv2Router(0x482eC5Bac2e048014187D245b2C8aaa49A6284a8);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        pairContract = InterfaceLP(pair);

        marketingFeeReceiver = 0x115131a15102E4A6D42e64Faa0637230Ed6e1A4F;
        teamFeeReceiver = 0x115131a15102E4A6D42e64Faa0637230Ed6e1A4F;
        liquidityReceiver = 0x115131a15102E4A6D42e64Faa0637230Ed6e1A4F; 
        
        isFeeExempt[owner] = true;

        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[DEAD] = true;

        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + (amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - (amount);
        emit Transfer(account, address(0), amount);
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        _maxWalletToken = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner && recipient != owner){
            require(launched,"Trading not open yet");
            
            if(gasLimitActive) {
                require(tx.gasprice <= gasPriceLimit,"Gas price exceeds limit");
            }
        }

        if (sender != owner && recipient != owner  && recipient != address(this) && sender != address(this) && recipient != address(DEAD) ){
            if(recipient != pair)
            require((amount + balanceOf(recipient)) <= _maxWalletToken || isMaxWalletExempt[recipient],"Max wallet holding reached");
        }

        // Swap
        if(sender != pair
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
        if(recipient == pair){
            multiplier = sellMultiplier;
        } else if(sender == pair){
            multiplier = buyMultiplier;
        }

        uint256 feeAmount = amount * (totalFee) * (multiplier) / (feeDenominator * 100);


        if(sender == pair && (launchedAt + deadBlocks) > block.number){
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
    function launch(uint256 _deadBlocks) public onlyOwner {
        require(launched == false);
        launched = true;
        launchedAt = block.number;
        deadBlocks = _deadBlocks;
    }

    function swapBack() internal swapping {       
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, 100) ? 0 : liquidityFee;
        uint256 amountToLiquify = contractTokenBalance * dynamicLiquidityFee / totalFee / (2);
        uint256 amountToSwap = contractTokenBalance - amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee - (dynamicLiquidityFee / (2));
        uint256 amountBNBLiquidity = amountBNB * dynamicLiquidityFee / totalBNBFee / (2);
        uint256 amountBNBMarketing = amountBNB * marketingFee / totalBNBFee;
        uint256 amountBNBTeam = amountBNB - amountBNBLiquidity - amountBNBMarketing;

        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected BNB transfer");
        (bool TeamSuccess, /* bytes memory data */) = payable(teamFeeReceiver).call{value: amountBNBTeam, gas: 30000}("");
        require(TeamSuccess, "receiver rejected BNB transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function _swapTokensForFees(uint256 amount) external onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this));
        require(amount <= swapThreshold);
        require(contractTokenBalance >= amount);
        swapBack();
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        require(_buy <= 300, "Fees too high");
        require(_sell <= 300, "Fees too high");
        require(_trans <= 300, "Fees too high");
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 10 gwei);
        gasPriceLimit = gas * 1 gwei;
    }

    function setgasLimitActive(bool antiGas) external onlyOwner {
        gasLimitActive = antiGas;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsMaxwalletExempt(address holder, bool exempt) external onlyOwner {
        isMaxWalletExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _teamFee, uint256 _feeDenominator) external onlyOwner {
        require(_liquidityFee + _marketingFee + _teamFee < 33, "Total fees must be below 33%");
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        totalFee = _liquidityFee + _marketingFee + _teamFee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/3, "Fees cannot be more than 33%");
    }

    function setFeeReceivers( address _marketingFeeReceiver, address _teamFeeReceiver, address _liquidityReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        liquidityReceiver = _liquidityReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _transaction) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        swapTransactionThreshold = _transaction;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return isFeeExempt[account];
    }

    function isExcludedFromMaxWallet(address account) public view returns(bool) {
        return isMaxWalletExempt[account];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(address(this) != token);
        BEP20(token).transfer(to, BEP20(token).balanceOf(address(this))); 
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy * (balanceOf(pair) * (2)) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    /* Airdrop Begins */
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