/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.13;


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

contract TheLastWill is ERC20, Ownable {
   
    IUniswapV2Router public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool private swapping;

    address public constant deadAddress = address(0x0);
    address public marketingDevRewardsReceiver = 0x3Ab42278edc3a55977F9D826C141b50679519E33;
    address public autoLiquidityReceiver = 0x3Ab42278edc3a55977F9D826C141b50679519E33;
    
    string private constant NAME = "TheLastWill(t.me/lastwillbsc)";
    string private constant SYMBOL = "TLW";
    uint8 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 50 * 1e6 * 10**DECIMALS; // 50 million tokens
    
    uint256 public swapTokensAtAmount = 3 * TOTAL_SUPPLY / 1000;  // 0.3% of total supply, 150 thousand tokens 

    uint256 public marketingDevRewardsFee = 4;
    uint256 public liquidityFee = 1;
    uint256 public totalFees = marketingDevRewardsFee + liquidityFee;   
    
    bool public tradingIsEnabled = false;

    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isPair;

    event Launch();
    event ClearedStuckBalance(address indexed marketingDevRewardsReceiver, uint256 indexed amount);
    event ClearBalanceFailure(address indexed marketingDevRewardsReceiver, uint256 indexed feeAmount);
    event ExcludeFromFees(address indexed account, bool indexed isExcluded);
    event ModifyTaxes(uint256 indexed marketingDevRewardsFee, uint256 indexed liquidityFee);
    event ChangeFeeReceivers(address indexed marketingDevRewardsReceiver, address indexed autoLiquidityReceiver);
    event FeeDistributionFailure(address indexed marketingDevRewardsReceiver, uint256 indexed feeAmount);
    event SetSwapTokensAtAmount(uint256 indexed swapTokensAtAmount);  
    event SwapAndLiquify(uint256 indexed tokensSwapped, uint256 indexed ethReceived);

    constructor() ERC20(NAME, SYMBOL, DECIMALS) {
        
    	IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    	
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        isPair[_uniswapV2Pair] = true;
        
        excludeFromFees(deadAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);

        /*
            Initial mint of token supply. 
            The function is and can only be called once, internally on contract deployment.
        */
        _mint(owner(), TOTAL_SUPPLY);        
    }
    
    modifier inSwap {
        swapping = true;
        _;
        swapping = false;
    }

    function launch() external onlyOwner {
        require(!tradingIsEnabled, "Project already launched.");

        tradingIsEnabled = true;
        
        emit Launch();
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        require(0 < amountPercentage && amountPercentage <= 100, 
          "Requested percentage of contract balance not within acceptable range, [0,100].");

        uint256 amountBNB = amountPercentage * address(this).balance / 100;
        (bool success,) = payable(marketingDevRewardsReceiver).call{value: amountBNB, gas: 30000}(""); 

        if(success == true){
            emit ClearedStuckBalance(marketingDevRewardsReceiver, amountBNB);
        }
        else{
            emit ClearBalanceFailure(marketingDevRewardsReceiver, amountBNB);
        }  
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");

        isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
     
    function modifyTaxes(uint256 _marketingDevRewardsFee, uint256 _liquidityFee) external onlyOwner {
        require(0 <= _liquidityFee && _liquidityFee <= 10 , 
          "Requested liquidity fee not within acceptable range, [0,10] .");
        require(0 <= _marketingDevRewardsFee && _marketingDevRewardsFee <= 10, 
          "Requested marketing/dev./rewards fee percentage not within acceptable range, [0,10].");
        require(0 < _marketingDevRewardsFee + _liquidityFee && _marketingDevRewardsFee + _liquidityFee <= 20, 
          "Total fee percentage must be strictly positive, (0, 20].");
        
        marketingDevRewardsFee = _marketingDevRewardsFee;
        liquidityFee = _liquidityFee;         
        totalFees = marketingDevRewardsFee + liquidityFee;
        
        emit ModifyTaxes(marketingDevRewardsFee, liquidityFee);  
    }

    function changeFeeReceivers(address _marketingDevRewardsReceiver, address _autoLiquidityReceiver) external onlyOwner {
        marketingDevRewardsReceiver = _marketingDevRewardsReceiver;
        autoLiquidityReceiver = _autoLiquidityReceiver;

        emit ChangeFeeReceivers(marketingDevRewardsReceiver, autoLiquidityReceiver);
    }
    
    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) external onlyOwner {
        require(2 * TOTAL_SUPPLY / 1000 <= _swapTokensAtAmount && _swapTokensAtAmount <= 5 * TOTAL_SUPPLY / 1000,
          "Requested contract swap amount not within acceptable range, [0.2% of TOTAL_SUPPLY, 0.5% of TOTAL_SUPPLY].");
        
        swapTokensAtAmount = _swapTokensAtAmount;
         
        emit SetSwapTokensAtAmount(swapTokensAtAmount);  
    }
    
    function checkValidTrade(address from, address to) private view {
        if (from != owner() && to != owner() && !isExcludedFromFees[from]) {
            require(tradingIsEnabled, "Project has yet to launch.");
        } 
    }
    
    function _transfer(address from, address to, uint256 amount) internal override {
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
    
        checkValidTrade(from, to);
        bool takeFee = tradingIsEnabled && !swapping;
        
        if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        if(takeFee) {
            uint256 fees = amount * totalFees / 100;   
        	amount = amount - fees;
            super._transfer(from, address(this), fees);
        }
        
        if(shouldSwap(from)) {
            swapTokens(swapTokensAtAmount);
        }
        
        super._transfer(from, to, amount);
    }
    

    function shouldSwap(address from) private view returns (bool) {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        return tradingIsEnabled && canSwap && !swapping && !isPair[from];
    }    
        
    function swapTokens(uint256 tokens) private inSwap {
        uint256 LPtokens = tokens * liquidityFee / totalFees;
        uint256 halfLPTokens = LPtokens / 2;
        uint256 marketingDevRewardsTokens = tokens * marketingDevRewardsFee / totalFees;
        uint256 swapAmount = halfLPTokens + marketingDevRewardsTokens;
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(swapAmount); 
         
        uint256 newBalance = address(this).balance - initialBalance;
        uint256 BNBForLP = newBalance * halfLPTokens / swapAmount;
        uint256 BNBForMarketingDevRewards = newBalance * marketingDevRewardsTokens / swapAmount;

        (bool temp,) = payable(marketingDevRewardsReceiver).call{value: BNBForMarketingDevRewards, gas: 30000}(""); 
        if(temp == false){
            emit FeeDistributionFailure(marketingDevRewardsReceiver, BNBForMarketingDevRewards);
        }
        
        if(halfLPTokens > 0 && BNBForLP > 0){
            addLiquidity(halfLPTokens, BNBForLP);
            emit SwapAndLiquify(halfLPTokens, BNBForLP);
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
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
       uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            autoLiquidityReceiver,
            block.timestamp
        );
    }

    receive() external payable {}
}