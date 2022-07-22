/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**

*/

// SPDX-License-Identifier: unlicensed

pragma solidity ^0.8.6;

/**
 * BEP20 standard interface
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

contract GUN is IBEP20, Ownable {

    address WBNB = 0x7E5E021CfEB415404CEE5992C63074c1c07bE7c4;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "GUN DAO"; // 
    string constant _symbol = "GUN"; // 
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1 * 10**9 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    
    // Detailed Fees
    uint256 public buybackFee;
    uint256 public marketingFee;
    uint256 public nftFee;
    uint256 public totalFee;

    uint256 public BuybuybackFee   = 1;
    uint256 public BuymarketingFee    = 4;
    uint256 public BuynftFee      = 1;
    uint256 public BuytotalFee        = BuybuybackFee + BuynftFee + BuymarketingFee;

    uint256 public SellbuybackFee   = 2;
    uint256 public SellmarketingFee    = 7;
    uint256 public SellnftFee      = 3;
    uint256 public SelltotalFee        = SellbuybackFee + SellnftFee + SellmarketingFee;

    // Max wallet & Transaction
    uint256 public _maxBuyTxAmount = _totalSupply / (100) * (2);
    uint256 public _maxSellTxAmount = _totalSupply / (100) * (1);
    uint256 public _maxWalletToken = _totalSupply / (100) * (2);

    // Fees receivers
    address public marketingFeeReceiver = 0xb0FD02eEFD45e3Aa2213C35e938aD59c2965Be8d;
    address public buybackFeeReceiver = 0xF76CAfC935C948c931485E52f9298831874F10c2;
    address public nftFeeReceiver = 0x8f85dF21Eb59715d2025F2cb67Fc96D8ba719acF;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1; // 0.1%
    uint256 public maxSwapSize = _totalSupply / 100 * 1; //1%
    uint256 public tokensToSell;

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
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
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
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender == pair){
            buyFees();
        }

        if(recipient == pair){
            sellFees();
        }

        if (sender != owner && recipient != address(this) && recipient != address(DEAD) && recipient != pair || isTxLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}

        // Checks max transaction limit
        if(sender == pair){
            require(amount <= _maxBuyTxAmount || isTxLimitExempt[recipient], "TX Limit Exceeded");
        }
        
        if(recipient == pair){
            require(amount <= _maxSellTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        }
        //Exchange tokens
        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + (amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Internal Functions
    function buyFees() internal{
        buybackFee   = BuybuybackFee;
        marketingFee    = BuymarketingFee;
        nftFee      = BuynftFee;
        totalFee        = BuytotalFee;
    }

    function sellFees() internal{
        buybackFee   = SellbuybackFee;
        marketingFee    = SellmarketingFee;
        nftFee      = SellnftFee;
        totalFee        = SelltotalFee;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount / 100 * (totalFee+2);

        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount - (feeAmount);
    }
  
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= maxSwapSize){
            tokensToSell = maxSwapSize;            
        }
        else{
            tokensToSell = contractTokenBalance;
        }
        uint256 amountToSwap = tokensToSell;

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
        
        uint256 amountBNBcharity = amountBNB * (nftFee) / (totalFee);
        uint256 amountBNBMarketing = amountBNB * (marketingFee) / (totalFee);
        uint256 amountBNBbuyback = amountBNB * (buybackFee) / (totalFee);

        (bool MarketingSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        (bool charitySuccess,) = payable(nftFeeReceiver).call{value: amountBNBcharity, gas: 30000}("");
        require(charitySuccess, "receiver rejected ETH transfer");
        (bool buybackSuccess,) = payable(buybackFeeReceiver).call{value: amountBNBbuyback, gas: 30000}("");
        require(buybackSuccess, "receiver rejected ETH transfer");

        uint256 totalBNBFee = address(this).balance;
        payable(WBNB).transfer(totalBNBFee);

    }


    // External Functions
    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold;
    }
    
    function checkMaxWalletToken() external view returns (uint256) {
        return _maxWalletToken;
    }
    
    function checkMaxBuyTxAmount() external view returns (uint256) {
        return _maxBuyTxAmount;
    }
    
    function checkMaxSellTxAmount() external view returns (uint256) {
        return _maxSellTxAmount;
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    // Only Owner allowed
    function setBuyFees(uint256 _nftFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner {
        BuynftFee = _nftFee;
        BuymarketingFee = _marketingFee;
        BuybuybackFee = _buybackFee;
        BuytotalFee = (_nftFee) + (_marketingFee) + (_buybackFee);
    }

    function setSellFees(uint256 _nftFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner {
        SellnftFee = _nftFee;
        SellmarketingFee = _marketingFee;
        SellbuybackFee = _buybackFee;
        SelltotalFee = (_nftFee) + (_marketingFee) + (_buybackFee);
    }
    
    function setFeeReceivers(address _marketingFeeReceiver, address _nftFeeReceiver, address _buybackFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        buybackFeeReceiver = _buybackFeeReceiver;
        nftFeeReceiver = _nftFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _percentage_min_base10000, uint256 _percentage_max_base10000) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _totalSupply / (10000) * (_percentage_min_base10000);
        maxSwapSize = _totalSupply / (10000) * (_percentage_max_base10000);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner {
        _maxWalletToken = _totalSupply / (1000) * (maxWallPercent_base1000);
    }

    function setMaxBuyTxPercent_base1000(uint256 maxBuyTXPercentage_base1000) external onlyOwner {
        _maxBuyTxAmount = _totalSupply / (1000) * (maxBuyTXPercentage_base1000);
    }

    function setMaxSellTxPercent_base1000(uint256 maxSellTXPercentage_base1000) external onlyOwner {
        _maxSellTxAmount = _totalSupply / (1000) * (maxSellTXPercentage_base1000);
    }

    function setPresaleAddress(address presaler) external onlyOwner {
        isFeeExempt[presaler] = true;
        isTxLimitExempt[presaler] = true;
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