/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

/*   

        TG: https://t.me/skittlesinuofficial
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

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
        require(isOwner(msg.sender), "You are not the owner!");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * Router Interfaces
 */

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

/**
 * Contract Code
 */

contract SkittlesInu is IBEP20, Ownable {
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Skittles Inu";
    string constant _symbol = "TIMOTHY"; 
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1 * 10**9 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public tradingEnabled = false;
    uint256 private genesisBlock = 0;
    uint256 private deadline = 0;

    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    
    //General Fees Variables
    uint256 public devFee;
    uint256 public marketingFee;
    uint256 public charityFee;
    uint256 public totalFee;

    //Buy Fees Variables
    uint256 private buyDevFee = 0;
    uint256 private buyMarketingFee = 10;
    uint256 private buyCharityFee = 0;
    uint256 private buyTotalFee = buyDevFee + buyMarketingFee + buyCharityFee;

    //Sell Fees Variables
    uint256 private sellDevFee = 0;
    uint256 private sellMarketingFee = 10;
    uint256 private sellCharityFee = 0;
    uint256 private sellTotalFee = sellDevFee + sellMarketingFee + sellCharityFee;

    //Max Transaction & Wallet
    uint256 public _maxTxAmount = _totalSupply * 100 / 10000; //Initial 1%
    uint256 public _maxWalletSize = _totalSupply * 200 / 10000; //Initial 2%

    // Fees Receivers
    address public devFeeReceiver = 0xd143F52aa592a2cf7dA82690Ec871C9bfFe015C8;
    address public marketingFeeReceiver = 0xd143F52aa592a2cf7dA82690Ec871C9bfFe015C8;
    address public charityFeeReceiver = 0xd143F52aa592a2cf7dA82690Ec871C9bfFe015C8;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; //0.1%
    uint256 public maxSwapSize = _totalSupply * 100 / 10000; //1%

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
  
    constructor () Ownable(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

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

    function setTradingStatus(bool status, uint256 deadblocks) external onlyOwner {
        require(status, "No rug here ser");
        tradingEnabled = status;
        deadline = deadblocks;
        if (status == true) {
            genesisBlock = block.number;
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap || amount == 0){ return _basicTransfer(sender, recipient, amount); }

        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && !tradingEnabled && sender == pair) {
            isBlacklisted[recipient] = true;
        }

        require(!isBlacklisted[sender], "You are a bot!"); 

        setFees(sender);
        
        if (sender != owner && recipient != address(this) && recipient != address(DEAD) && recipient != pair) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletSize || isTxLimitExempt[recipient], "Total Holding is currently limited, you can not hold that much.");
        }

        // Checks Max Transaction Limit
        if(sender == pair){
            require(amount <= _maxTxAmount || isTxLimitExempt[recipient], "TX limit exceeded.");
        }

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);

        return true;
    }

    function manageBlacklist(address account, bool status) public onlyOwner {
        isBlacklisted[account] = status;
    }

    function setFees(address sender) internal {
        if(sender == pair) {
            buyFees();
        }
        else {
            sellFees();
        }
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + (amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function buyFees() internal {
        devFee = buyDevFee;
        marketingFee = buyMarketingFee;
        charityFee = buyCharityFee;
        totalFee = buyTotalFee;
    }

    function sellFees() internal{
        devFee = sellDevFee;
        marketingFee = sellMarketingFee;
        charityFee = sellCharityFee;
        totalFee = sellTotalFee;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = block.number <= (genesisBlock + deadline) ?  amount / 100 * 99 : amount / 100 * totalFee;
        
        _balances[address(this)] = _balances[address(this)] + (feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }
  
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = 0;
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= maxSwapSize) {
            amountToSwap = maxSwapSize;            
        }
        else {
            amountToSwap = contractTokenBalance;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - (balanceBefore);
        
        uint256 amountBNBDev = amountBNB * (devFee) / (totalFee);
        uint256 amountBNBMarketing = amountBNB * (marketingFee) / (totalFee);
        uint256 amountBNBCharity = amountBNB * (charityFee) / (totalFee);

        (bool devSucess,) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}("");
        require(devSucess, "receiver rejected ETH transfer");
        (bool marketingSucess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(marketingSucess, "receiver rejected ETH transfer");
        (bool charitySucess,) = payable(charityFeeReceiver).call{value: amountBNBCharity, gas: 30000}("");
        require(charitySucess, "receiver rejected ETH transfer");
    }

    function setBuyFees(uint256 _devFee, uint256 _marketingFee, uint256 _charityFee) external onlyOwner {
        buyDevFee = _devFee;
        buyMarketingFee = _marketingFee;
        buyCharityFee = _charityFee;
        buyTotalFee = buyDevFee + buyMarketingFee + buyCharityFee;
        require(buyTotalFee <= 25, "Invalid buy tax fees");
    }

    function setSellFees(uint256 _devFee, uint256 _marketingFee, uint256 _charityFee) external onlyOwner {
        sellDevFee = _devFee;
        sellMarketingFee = _marketingFee;
        sellCharityFee = _charityFee;
        sellTotalFee = sellDevFee + sellMarketingFee + sellCharityFee;
        require(sellTotalFee <= 25, "Invalid sell tax fees");
    }
    
    function setFeeReceivers(address _devFeeReceiver, address _marketingFeeReceiver, address _charityFeeReceiver) external onlyOwner {
        devFeeReceiver = _devFeeReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        charityFeeReceiver = _charityFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _percentageMinimum, uint256 _percentageMaximum) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _totalSupply * _percentageMinimum / 10000;
        maxSwapSize = _totalSupply * _percentageMaximum / 10000;
    }

    function setIsFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
    }
    
    function setIsTxLimitExempt(address account, bool exempt) external onlyOwner {
        isTxLimitExempt[account] = exempt;
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= 100, "Invalid max wallet size");
        _maxWalletSize = _totalSupply * amount / 10000;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        require(amount >= 50, "Invalid max tx amount");
        _maxTxAmount = _totalSupply * amount / 10000;
    }

    // Stuck Balances Functions

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB);
    }
}