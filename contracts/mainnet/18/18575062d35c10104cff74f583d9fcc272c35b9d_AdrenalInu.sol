/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

abstract contract Ownable is Context {
    address private _owner;
	
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
	
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 9;
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
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
	
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
	
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
	
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
	
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Factory {
   function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
   function factory() external pure returns (address);
   function WETH() external pure returns (address);
   function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
   function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IPinkAntiBot {
   function setTokenOwner(address owner) external;
   function onPreTransferCheck(address from, address to, uint256 amount) external;
}

contract AdrenalInu is ERC20, Ownable {
    using SafeMath for uint256;
	
	uint256[] public liquidityFee;
	uint256[] public marketingFee;
	uint256[] public DevelopmentFee;
	
	uint256 public DevelopmentFeeTotal;
	uint256 public marketingFeeTotal;
	uint256 public liquidityFeeTotal;
	
	uint256 public maxSellPerDay;
	uint256 public maxTokenPerTxn;
	uint256 public swapTokensAtAmount;
	
	IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;
	
	address public marketingWallet;
	address public DevelopmentWallet;
	
	IPinkAntiBot public pinkAntiBot;
	
	bool private swapping;
    bool public swapAndLiquifyEnabled;
	bool public antiBotEnabled;

	mapping (address => bool) public isExcludedFromFee;
	mapping (address => bool) public isExcludedFromMaxTokenPerTxn;
	mapping (address => bool) public isExcludedFromDailySaleLimit;
	mapping (address => bool) public isAutomatedMarketMakerPairs;
	mapping (uint256 => mapping(address => uint256)) public dailyTransfers;
	
	event MaxTokenPerWalletUpdated(uint256 amount);
	event SwapTokensAmountUpdated(uint256 amount);
	event MaxTokenPerTxnUpdated(uint256 amount);
    event MaxSellPerDayUpdated(uint256 amount);
	event AutomatedMarketMakerPairUpdated(address pair, bool value);
	event SwapAndLiquifyStatusUpdated(bool status);
	event AntiBotStatusUpdated(bool status);
	event DevelopmentWalletUpdated(address newWallet);
    event MarketingWalletUpdated(address newWallet);
	event MarketingFeeUpdated(uint256 buy, uint256 sell, uint256 p2p);
	event LiquidityFee(uint256 buy, uint256 sell, uint256 p2p);
	event DevelopmentFeeUpdated(uint256 buy, uint256 sell, uint256 p2p);
	event TransferETH(address recipient, uint256 amount);
    event MigrateTokens(address token, address receiver, uint256 amount);
	
	constructor() ERC20("Adrenal Inu", "AINU") {
	
	   uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
	   
	   liquidityFee.push(100);
	   liquidityFee.push(100);
	   liquidityFee.push(100);
	   
	   marketingFee.push(200);
	   marketingFee.push(200);
	   marketingFee.push(200);
	   
	   DevelopmentFee.push(100);
	   DevelopmentFee.push(100);
	   DevelopmentFee.push(100);
	   
	   swapAndLiquifyEnabled = true;
	   antiBotEnabled = true;
	   
	   isExcludedFromFee[owner()] = true;
       isExcludedFromFee[address(this)] = true;
	   
	   isExcludedFromMaxTokenPerTxn[owner()] = true;
	   
	   isExcludedFromDailySaleLimit[address(this)] = true;
       isExcludedFromDailySaleLimit[owner()] = true;  

       isAutomatedMarketMakerPairs[uniswapV2Pair] = true; 	   
	   
	   maxSellPerDay = 1000000000000000 * (10 ** 18);
	   maxTokenPerTxn = 1000000000000000 * (10 ** 18);
	   swapTokensAtAmount = 1000000000 * (10 ** 18);
	   
	   pinkAntiBot = IPinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002);
	   pinkAntiBot.setTokenOwner(msg.sender);
	   
	   _mint(msg.sender, 1000000000000000 * (10 ** 18));
    }
	
	receive() external payable {}
	
	function excludeFromFee(address account, bool status) external onlyOwner {
	   require(isExcludedFromFee[account] != status, "Account is already the value of 'status'");
	   isExcludedFromFee[account] = status;
	}
	
	function excludeFromMaxTokenPerTxn(address account, bool status) public onlyOwner {
		require(isExcludedFromMaxTokenPerTxn[account] != status, "Account is already the value of 'status'");
		isExcludedFromMaxTokenPerTxn[account] = status;
	}
	
	function excludeFromDailySaleLimit(address account, bool status) public onlyOwner {
        require(isExcludedFromDailySaleLimit[account] != status, "Daily sale limit exclusion is already the value of 'status'");
		isExcludedFromDailySaleLimit[account] = status;
    }
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		
		swapTokensAtAmount = amount;
		emit SwapTokensAmountUpdated(amount);
  	}
	
	function setMaxSellPerDay(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply() && amount >= 1000000 * (10**18), "amount is not correct.");
		
        maxSellPerDay = amount;
		emit MaxSellPerDayUpdated(amount);
    }
	
	function setMaxTokenPerTxn(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply() && amount >= 1000000 * (10**18), "amount is not correct.");
		
        maxTokenPerTxn = amount;
		emit MaxTokenPerTxnUpdated(amount);
    }
	
	function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(isAutomatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
		
		isAutomatedMarketMakerPairs[address(pair)] = value;
		emit AutomatedMarketMakerPairUpdated(pair, value);
    }
	
	function setSwapAndLiquifyEnabled(bool status) external onlyOwner {
		require(swapAndLiquifyEnabled != status, "`swapAndLiquifyEnabled` is already the value of 'status'");
		
		swapAndLiquifyEnabled = status;
		emit SwapAndLiquifyStatusUpdated(status);
    }
	
	function setAntiBotStatus(bool status) external onlyOwner {
		require(antiBotEnabled != status, "`antiBotEnabled` is already the value of 'status'");
		
		antiBotEnabled = status;
		emit AntiBotStatusUpdated(status);
    }
	
	function setDevelopmentWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   
	   DevelopmentWallet = newWallet;
	   emit DevelopmentWalletUpdated(newWallet);
    }
	
	function setMarketingWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   
	   marketingWallet = newWallet;
	   emit MarketingWalletUpdated(newWallet);
    }
	
	function setDevelopmentFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(marketingFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(marketingFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(marketingFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		DevelopmentFee[0] = buy;
		DevelopmentFee[1] = sell;
		DevelopmentFee[2] = p2p;
		emit DevelopmentFeeUpdated(buy, sell, p2p);
	}
	
	function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(DevelopmentFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(DevelopmentFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(DevelopmentFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
		emit MarketingFeeUpdated(buy, sell, p2p);
	}
	
	function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(DevelopmentFee[0].add(marketingFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(DevelopmentFee[1].add(marketingFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(DevelopmentFee[2].add(marketingFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
		emit LiquidityFee(buy, sell, p2p);
	}
	
	function _transfer(address sender, address recipient, uint256 amount) internal override(ERC20){      
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
		
		if(antiBotEnabled) 
		{
           pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }
		
		if(!isExcludedFromMaxTokenPerTxn[sender]) 
		{
		    require(amount <= maxTokenPerTxn, "Transfer amount exceeds the `maxTokenPerTxn`");
		}
		
		if (!isExcludedFromDailySaleLimit[sender] && !isAutomatedMarketMakerPairs[sender] && isAutomatedMarketMakerPairs[recipient]) 
		{
		    require(dailyTransfers[getDay()][sender].add(amount) <= maxSellPerDay, "This account has exceeded max daily sell limit");
			dailyTransfers[getDay()][sender] = dailyTransfers[getDay()][sender].add(amount);
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if (!swapping && canSwap && swapAndLiquifyEnabled && isAutomatedMarketMakerPairs[recipient]) {
			swapping = true;
			
			uint256 tokenToDevelopment = DevelopmentFeeTotal;
			uint256 tokenToMarketing   = marketingFeeTotal;
			uint256 tokenToLiquidity   = liquidityFeeTotal;
			uint256 liquidityHalf      = tokenToLiquidity.div(2);
			uint256 tokenToSwap = tokenToDevelopment.add(tokenToMarketing).add(liquidityHalf);
			
			if(tokenToSwap >= swapTokensAtAmount) 
			{
			    uint256 initialBalance = address(this).balance;			
				swapTokensForETH(swapTokensAtAmount);
				uint256 newBalance = address(this).balance.sub(initialBalance);
				
				uint256 marketingPart    = newBalance.mul(tokenToMarketing).div(tokenToSwap);
				uint256 liquidityPart    = newBalance.mul(liquidityHalf).div(tokenToSwap);
				uint256 developmentPart  = newBalance.sub(marketingPart).sub(liquidityPart);
				
				if(marketingPart > 0) 
				{
					payable(marketingWallet).transfer(marketingPart);
					marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
				}
				
				if(liquidityPart > 0) 
				{
				    uint256 liqudityToken = swapTokensAtAmount.mul(liquidityHalf).div(tokenToSwap);
				    addLiquidity(liqudityToken, liquidityPart);
					liquidityFeeTotal = liquidityFeeTotal.sub(liqudityToken).sub(liqudityToken);
				}
				
				if(developmentPart > 0) 
				{
					payable(DevelopmentWallet).transfer(developmentPart);
					DevelopmentFeeTotal = DevelopmentFeeTotal.sub(swapTokensAtAmount.mul(tokenToDevelopment).div(tokenToSwap));
				}
			}
			swapping = false;
		}
		
		if(isExcludedFromFee[sender] || isExcludedFromFee[recipient]) 
		{
            super._transfer(sender, recipient, amount);
        }
		else 
		{
		    uint256 allFee = collectFee(amount, isAutomatedMarketMakerPairs[recipient], !isAutomatedMarketMakerPairs[sender] && !isAutomatedMarketMakerPairs[recipient]);
			if(allFee > 0) 
			{
			   super._transfer(sender, address(this), allFee);
			}
			super._transfer(sender, recipient, amount.sub(allFee));
        }
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256) {
        uint256 newDevelopmentFee = amount.mul(p2p ? DevelopmentFee[2] : sell ? DevelopmentFee[1] : DevelopmentFee[0]).div(10000);
		        DevelopmentFeeTotal = DevelopmentFeeTotal.add(newDevelopmentFee);
		
		uint256 newMarketingFee = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		        marketingFeeTotal = marketingFeeTotal.add(newMarketingFee);
		
		uint256 newLiquidityFee = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		        liquidityFeeTotal = liquidityFeeTotal.add(newLiquidityFee);
				
		uint256 totalFee = newDevelopmentFee.add(newMarketingFee).add(newLiquidityFee);
        return totalFee;
    }
	
	function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
		
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }
	
	function migrateTokens(address token, address receiver, uint256 amount) external onlyOwner{
       require(token != address(0), "Zero address");
	   require(receiver != address(0), "Zero address");
	   
	   if(address(token) == address(this))
	   {
	       require(IERC20(address(this)).balanceOf(address(this)).sub(DevelopmentFeeTotal).sub(marketingFeeTotal).sub(liquidityFeeTotal) >= amount, "Insufficient balance on contract");
	   }
	   else
	   {
	       require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient balance on contract");
	   }
	   IERC20(token).transfer(address(receiver), amount);
       emit MigrateTokens(token, receiver, amount);
    }
	
	function migrateETH(address payable recipient) external onlyOwner{
	   require(recipient != address(0), "Zero address");
	   
	   emit TransferETH(recipient, address(this).balance);
       recipient.transfer(address(this).balance);
    }
	
	function getDay() internal view returns(uint256){
        return block.timestamp.div(24 hours);
    }
}