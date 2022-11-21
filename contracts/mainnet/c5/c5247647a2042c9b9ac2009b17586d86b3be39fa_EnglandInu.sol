/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/*

https://twitter.com/EnglandInu

*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsIn(uint amountOut, address[] memory path)
        external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

contract ERC20 is IERC20 {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;

        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;

        emit Transfer(account, address(0), amount);
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract EnglandInu is ERC20, Ownable {

    string private constant NAME = "England Inu";
    string private constant SYMBOL = "ENG";
    uint8 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 100 * 1e6 * 10**DECIMALS; // 100 million tokens

    uint256 public maxWalletLimit = 1 * TOTAL_SUPPLY / 100; // 1% of total supply, one million tokens 
    uint256 public swapTokensAtAmount = 1 * TOTAL_SUPPLY / 1000;  // 0.1% of total supply, 100 thousand tokens 
    bool private swapping;
    
    IUniswapV2Router public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant DEAD_ADDRESS = address(0x0);

    address public immutable deployer = msg.sender;
    address public marketingReceiver = msg.sender;
    address public autoLiquidityReceiver = msg.sender;

    bool public tradingIsEnabled = false;
    uint256 public launchTime;
    uint256 public LAUNCH_PERIOD_SECONDS = 3600;
    
    uint256 public marketingBuyFee = 5;
    uint256 public liquidityBuyFee = 0;
    uint256 public totalBuyFees = marketingBuyFee + liquidityBuyFee;

    uint256 public marketingSellFee = 5;
    uint256 public liquiditySellFee = 0;
    uint256 public totalSellFees = marketingSellFee + liquiditySellFee;

    uint256 public marketingTokenPool;
    uint256 public liquidityTokenPool;
    
    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isPair;

    /*
    25 presalers are permitted tax-free 0.2 BNB buys each 5 minutes
      for a total of 1 BNB during launch hour
    */
    mapping(address => bool) public isPresaler;
    mapping(address => uint256) public presalerBuyAmountBNB; 

    event Launch();
    event ClearedStuckBNBBalance(address indexed marketingReceiver, uint256 indexed bnbAmount);
    event ClearBalanceBNBFailure(address indexed marketingReceiver, uint256 indexed bnbAmount);
    event ClearedStuckTokenBalance(address indexed marketingReceiver, uint256 indexed tokenAmount);
    event ExcludeFromFees(address indexed account, bool indexed isExcluded);
    event ModifyTaxes(
        uint256 marketingBuyFee,
        uint256 liquidityBuyFee,
        uint256 marketingSellFee, 
        uint256 liquiditySellFee);
    event ChangeFeeReceivers(address indexed marketingReceiver, address indexed autoLiquidityReceiver);
    event FeeDistributionFailure(address indexed marketingReceiver, uint256 indexed feeAmount);
    event SetSwapTokensAtAmount(uint256 indexed swapTokensAtAmount);  
    event SetMaxWalletAmount(uint256 indexed maxWalletAmount);  
    event SwapAndLiquify(uint256 indexed tokensSwapped, uint256 indexed bnbReceived);

    modifier inSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() ERC20(NAME, SYMBOL, DECIMALS) {
        
    	IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);        
        
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        isPair[_uniswapV2Pair] = true;
        
        excludeFromFees(DEAD_ADDRESS, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);

        /*
            Initial mint of token supply. 
            The function is and can only be called once, internally on contract deployment.
        */
        _mint(owner(), TOTAL_SUPPLY);        
    }

    receive() external payable {}
    
    function launch(address[] calldata _presalers) external onlyOwner {
        require(!tradingIsEnabled, "Token already launched."); 

        assert(_presalers.length == 25);

        for(uint256 i = 0;i<_presalers.length;i++){
            isPresaler[_presalers[i]] = true;
            isExcludedFromFees[_presalers[i]] = true;
        }

        tradingIsEnabled = true;
        launchTime = block.timestamp;
        
        emit Launch();
    }

    function clearStuckBNBBalance(uint256 amountPercentage) external onlyOwner {
        require(0 < amountPercentage && amountPercentage <= 100, 
          "Requested percentage of contract bnb balance not within acceptable range, (0,100].");

        uint256 amountBNB = amountPercentage * address(this).balance / 100;
        (bool success,) = payable(marketingReceiver).call{value: amountBNB, gas: 30000}(""); 

        if(success == true){
            emit ClearedStuckBNBBalance(marketingReceiver, amountBNB);
        }
        else{
            emit ClearBalanceBNBFailure(marketingReceiver, amountBNB);
        }  
    }

    function clearStuckTokenBalance(uint256 amountPercentage) external onlyOwner {
        require(0 < amountPercentage && amountPercentage <= 100, 
          "Requested percentage of contract token balance not within acceptable range, (0,100].");

        uint256 amountTokens = amountPercentage * (balanceOf(address(this)) - (liquidityTokenPool + marketingTokenPool)) / 100;

        _transfer(address(this), marketingReceiver, amountTokens);
         
        emit ClearedStuckTokenBalance(marketingReceiver, amountTokens);
    }

    function modifyTaxes(
        uint256 _marketingBuyFee, 
        uint256 _liquidityBuyFee,
        uint256 _marketingSellFee, 
        uint256 _liquiditySellFee) external onlyOwner {
        require(_liquidityBuyFee <= 10 && _liquiditySellFee <= 10, 
          "Requested liquidity fee not within acceptable range, [0,10] .");
        require(_marketingBuyFee <= 10 && _marketingSellFee <= 10, 
          "Requested marketing fee percentage not within acceptable range, [0,10].");
        require(_marketingBuyFee + _liquidityBuyFee <= 10 &&  _marketingSellFee + _liquiditySellFee <= 10, 
          "Total fee percentage not within acceptable range, [0,10].");
        
        marketingBuyFee = _marketingBuyFee;
        marketingSellFee = _marketingSellFee;
        liquidityBuyFee = _liquidityBuyFee;         
        liquiditySellFee = _liquiditySellFee;         
        totalBuyFees = marketingBuyFee + liquidityBuyFee;
        totalSellFees = marketingSellFee + liquiditySellFee;
        
        emit ModifyTaxes(marketingBuyFee, liquidityBuyFee, marketingSellFee, liquiditySellFee);  
    }

    function changeFeeReceivers(address _marketingReceiver, address _autoLiquidityReceiver) external onlyOwner {
        require(_marketingReceiver != address(0x0), "Requested marketing fee receiver may not be the dead address.");
        require(_autoLiquidityReceiver != address(0x0), "Requested liquidity receiver may not be the dead address.");
        marketingReceiver = _marketingReceiver;
        autoLiquidityReceiver = _autoLiquidityReceiver;

        emit ChangeFeeReceivers(marketingReceiver, autoLiquidityReceiver);
    }
    
    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) external onlyOwner {
        require(1 * TOTAL_SUPPLY / 1000 <= _swapTokensAtAmount && _swapTokensAtAmount <= 5 * TOTAL_SUPPLY / 1000,
          "Requested contract swap amount not within acceptable range, [0.1% of TOTAL_SUPPLY, 0.5% of TOTAL_SUPPLY].");
        
        swapTokensAtAmount = _swapTokensAtAmount;
         
        emit SetSwapTokensAtAmount(swapTokensAtAmount);  
    }

    function setMaxWalletAmount(uint256 newMaxWalletAmount) external onlyOwner {
        require(1 * TOTAL_SUPPLY / 100 <= newMaxWalletAmount,
          "Requested max wallet amount not within acceptable range, [1% of TOTAL_SUPPLY, type(uint256).max].");
        
        maxWalletLimit = newMaxWalletAmount;
         
        emit SetMaxWalletAmount(maxWalletLimit);  
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");

        isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function checkValidTrade(address from, address to, uint256 amount) private {
        if (from != deployer && to != deployer && !isExcludedFromFees[from]) { 
            require(tradingIsEnabled, "Token has yet to launch.");

            if(from == uniswapV2Pair && isPresaler[to]){   
                address[] memory path = new address[](2);
                path[0] = uniswapV2Router.WETH();
                path[1] = address(this);

                uint256[] memory amounts = uniswapV2Router.getAmountsIn(amount, path);
                require(presalerBuyAmountBNB[to] + amounts[0] <= getBuyAllowance());                
                presalerBuyAmountBNB[to] += amounts[0];
            }
            if(!isPair[to]){                                        
                require(balanceOf(to) + amount <= maxWalletLimit, "Max wallet holdings exceeded");
            }
        } 
    }

    function getBuyAllowance() private view returns (uint256 buyAmount) {
        if(block.timestamp - launchTime <= 300){
            buyAmount = 0.1 ether;
        }
        else if(block.timestamp - launchTime <= 600){
            buyAmount = 0.3 ether;
        }
        else if(block.timestamp - launchTime <= 900){
            buyAmount = 0.6 ether;
        }
        else if(block.timestamp - launchTime <= 1200){
            buyAmount = 0.8 ether;
        }
        else if(block.timestamp - launchTime <= 1500){
            buyAmount = 1 ether;
        }
        else{
            buyAmount = type(uint256).max;
        }
    }
    
    function _transfer(address from, address to, uint256 amount) internal override {
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        else if(to == address(this))
            revert();
    
        checkValidTrade(from, to, amount);
        bool takeFee = tradingIsEnabled && !swapping;
        
        if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        if(takeFee) {
            (uint256 marketingTokens, uint256 liquidityTokens, uint256 fees) = getFees(from, amount);
            marketingTokenPool += marketingTokens;
            liquidityTokenPool += liquidityTokens;
            amount -= fees;
            super._transfer(from, address(this), fees);
        }
        
        if(shouldSwap(from)) {
            swapTokens(swapTokensAtAmount);
        }
        
        super._transfer(from, to, amount);
    }

    function getFees(address from, uint256 amount) private view returns 
        (uint256 marketingTokens, uint256 liquidityTokens, uint256 fees) {

        if(isPair[from]){
                if(block.timestamp - launchTime > LAUNCH_PERIOD_SECONDS){
                    fees = amount * totalBuyFees / 100;   
                }
                else{
                    fees = amount * getLaunchBuyTax() / 100;   
                }
                marketingTokens = fees * marketingBuyFee / totalBuyFees;
                liquidityTokens = fees - marketingTokens;
        }
        else{
            fees = amount * totalSellFees / 100;                   
            marketingTokens = fees * marketingSellFee / totalSellFees;
            liquidityTokens = fees - marketingTokens;
        }
    }

    function getLaunchBuyTax() private view returns (uint256 buyTax) {
        buyTax = 100 - (block.timestamp - launchTime) * 100 / LAUNCH_PERIOD_SECONDS;
    }

    function shouldSwap(address from) private view returns (bool) {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        return tradingIsEnabled && canSwap && !swapping && !isPair[from];
    }    
    
    function swapTokens(uint256 totalSwapTokens) private inSwap {

        (uint256 marketingTokens, uint256 LPtokens) = getTokenShares(totalSwapTokens);
        marketingTokenPool -= marketingTokens;
        liquidityTokenPool -= LPtokens;

        uint256 halfLPTokens = LPtokens / 2;
        uint256 swapAmount = halfLPTokens + marketingTokens;
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(swapAmount); 
         
        uint256 newBalance = address(this).balance - initialBalance;
        uint256 BNBForLP = newBalance * halfLPTokens / swapAmount;
        uint256 BNBForMarketing = newBalance * marketingTokens / swapAmount;

        (bool success,) = payable(marketingReceiver).call{value: BNBForMarketing, gas: 30000}(""); 
        if(success == false){
            emit FeeDistributionFailure(marketingReceiver, BNBForMarketing);
        }
        
        if(halfLPTokens > 0 && BNBForLP > 0){
            (uint256 tokensAddedLiquidity, uint256 bnbAddedLiquidity) = addLiquidity(halfLPTokens, BNBForLP);
            if(halfLPTokens - tokensAddedLiquidity > 0){
                liquidityTokenPool += (halfLPTokens - tokensAddedLiquidity);
            }            
            emit SwapAndLiquify(tokensAddedLiquidity, bnbAddedLiquidity);
        }
    }

    function getTokenShares(uint256 totalSwapTokens) private view returns (uint256, uint256) {
        if(marketingTokenPool >= totalSwapTokens){
            return (totalSwapTokens, 0);
        }        
        else{            
            return (marketingTokenPool, totalSwapTokens - marketingTokenPool);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private returns (uint256 tokensLiquidity, uint256 bnbLiquidity) {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
       (tokensLiquidity, bnbLiquidity, ) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            autoLiquidityReceiver,
            block.timestamp
        );
    }
}