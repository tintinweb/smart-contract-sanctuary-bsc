// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Libraries.sol";

contract coii is ERC20, Ownable {
	using SafeMath for uint256;
	
	IUniswapV2Router02 public uniswapV2Router;
	address public uniswapV2Pair;
	
	bool private swapping;
	
	address public marketingWallet;
	address public liquidityWallet;
	address public devWallet;
	
	uint256 public maxTransactionAmount;
	uint256 public swapTokensAtAmount;
	
	bool public limitsInEffect = true;
	bool public tradingActive = false;
	bool public swapEnabled = false;
	
	// sell fees
	uint256 public sellLiquidityFee;
	uint256 public sellOperationsFee;
	uint256 public sellDevFee;
	uint256 public sellTotalFees;
	
	// sell fees
	uint256 public buyLiquidityFee;
	uint256 public buyOperationsFee;
	uint256 public buyDevFee;
	uint256 public buyTotalFees;
	
	uint256 public feeDivisor;
	
	uint256 private _liquidityTokensToSwap;
	uint256 private _marketingTokensToSwap;
	uint256 private _devTokensToSwap;
	
	/******************/
	
	// exlcude from fees and max transaction amount
	mapping(address => bool) private _isExcludedFromFees;
	mapping(address => bool) public _isExcludedMaxTransactionAmount;
	
	// store addresses that a automatic market maker pairs. Any transfer *to* these addresses
	// could be subject to a maximum transfer amount
	mapping(address => bool) public automatedMarketMakerPairs;
	
	event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
	
	event ExcludeFromFees(address indexed account, bool isExcluded);
	
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	
	event marketingWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
	
	event SwapAndLiquify(
		uint256 tokensSwapped,
		uint256 ethReceived,
		uint256 tokensIntoLiqudity
	);
	
	constructor() ERC20("coii coin", "coii") payable {
		
		uint256 totalSupply = 10 * 1e3 * 1e7 * 1e18;
		
		maxTransactionAmount = totalSupply * 50 / 1000;
		// 5% maxTransactionAmountTxn
		swapTokensAtAmount = totalSupply * 50 / 1000;
		// 5% swap tokens amount
		
		// sell fees
		sellLiquidityFee = 20;
		sellOperationsFee = 20;
		sellDevFee = 10;
		sellTotalFees = sellLiquidityFee + sellOperationsFee + sellDevFee;
		//5%
		
		// buy fees
		buyLiquidityFee = 20;
		buyOperationsFee = 20;
		buyDevFee = 10;
		buyTotalFees = buyLiquidityFee + buyOperationsFee + buyDevFee;
		// 5%
		
		feeDivisor = 1000;
		
		marketingWallet = address(0xa9331B30C41522d926BAC549b391Bf9474F7830c);
		devWallet = address(0x3042ad8cFf7Bc4c63BaA33d124C9Ac3abA7925f9);
		
		// set as marketing wallet
		liquidityWallet = address(owner());
		// set as owner to start, can change to whatever later, but keep this as owner so the liquidity tokens go into the owner's wallet.
		
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
		// ROPSTEN or HARDHAT
			0x1b0Dc4c2499B693546d761C13841200eC2eeB5e8
		);
		
		address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
		.createPair(address(this), _uniswapV2Router.WETH());
		
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);
		
		// exclude from paying fees or having max transaction amount
		excludeFromFees(owner(), true);
		excludeFromFees(address(this), true);
		excludeFromFees(address(0xdead), true);
		
		excludeFromMaxTransaction(owner(), true);
		excludeFromMaxTransaction(address(this), true);
		
		excludeFromMaxTransaction(address(0xdead), true);
		
		/*liquidityWallet
			_mint is an internal function in ERC20.sol that is only called here,
			and CANNOT be called ever again
		*/
		_mint(address(owner()), totalSupply);
	}
	
	receive() external payable {
	
	}
	
	// once enabled, can never be turned off (can be called automatically by launching, but use this with a manual Uniswap add if needed)
	function enableTrading() public onlyOwner {
		tradingActive = true;
		swapEnabled = true;
	}
	
	// remove limits after token is stable
	function removeLimits() external onlyOwner returns (bool){
		limitsInEffect = false;
		return true;
	}
	
	// change the minimum amount of tokens to sell from fees
	function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
	//	require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
		require(newAmount <= totalSupply() * 50 / 1000, "Swap amount cannot be higher than 5% total supply.");
		swapTokensAtAmount = newAmount;
		return true;
	}
	
	function updateMaxAmount(uint256 newNum) external onlyOwner {
		require(newNum >= (totalSupply() * 50 / 1000) / 1e18, "Cannot set maxTransactionAmount lower than 5%");
		maxTransactionAmount = newNum * (10 ** 18);
	}
	
	
	function updateBuyFees(uint256 _operationsFee, uint256 _liquidityFee, uint256 _devFee) external onlyOwner {
		buyOperationsFee = _operationsFee;
		buyLiquidityFee = _liquidityFee;
		buyDevFee = _devFee;
		
		buyTotalFees = buyLiquidityFee + buyOperationsFee + buyDevFee;
		require(buyTotalFees <= 200, "Must keep fees at 20% or less");
	}
	
	function updateSellFees(uint256 _operationsFee, uint256 _liquidityFee, uint256 _devFee) external onlyOwner {
		sellOperationsFee = _operationsFee;
		sellLiquidityFee = _liquidityFee;
		sellDevFee = _devFee;
		
		sellTotalFees = sellLiquidityFee + sellOperationsFee + sellDevFee;
		require(sellTotalFees <= 200, "Must keep fees at 20% or less");
	}
	
	function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
		_isExcludedMaxTransactionAmount[updAds] = isEx;
	}
	
	// only use to disable contract sales if absolutely necessary (emergency use only)
	function updateSwapEnabled(bool enabled) external onlyOwner() {
		swapEnabled = enabled;
	}
	
	function excludeFromFees(address account, bool excluded) public onlyOwner {
		_isExcludedFromFees[account] = excluded;
		
		emit ExcludeFromFees(account, excluded);
	}
	
	function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
		require(pair != uniswapV2Pair, "The Uniswap pair cannot be removed from automatedMarketMakerPairs");
		
		_setAutomatedMarketMakerPair(pair, value);
	}
	
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		automatedMarketMakerPairs[pair] = value;
		excludeFromMaxTransaction(pair, value);
		emit SetAutomatedMarketMakerPair(pair, value);
	}
	
	function updateMarketingWallet(address newMarketingWallet) external onlyOwner {
		excludeFromFees(newMarketingWallet, true);
		emit marketingWalletUpdated(newMarketingWallet, marketingWallet);
		marketingWallet = newMarketingWallet;
	}
	
	function updateLiquidityWallet(address newLiquidityWallet) external onlyOwner {
		excludeFromFees(newLiquidityWallet, true);
		liquidityWallet = newLiquidityWallet;
	}
	
	function updateDevWallet(address newDevWallet) external onlyOwner {
		excludeFromFees(newDevWallet, true);
		devWallet = newDevWallet;
	}
	
	function isExcludedFromFees(address account) public view returns (bool) {
		return _isExcludedFromFees[account];
	}
	
	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal override {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		
		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}
		
		if (!tradingActive) {
			require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
		}
		
		if (limitsInEffect) {
			if (
				from != owner() &&
				to != owner() &&
				to != address(0) &&
				to != address(0xdead) &&
				!swapping
			) {
				
				//when buy
				if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
					require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
				}
				//when sell
				else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
					require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
				}
			}
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		
		bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if (
			canSwap &&
			swapEnabled &&
			!swapping &&
			!automatedMarketMakerPairs[from] &&
			!_isExcludedFromFees[from] &&
			!_isExcludedFromFees[to]
		) {
			swapping = true;
			swapBack();
			swapping = false;
		}
		
		bool takeFee = !swapping;
		
		// if any account belongs to _isExcludedFromFee account then remove the fee
		if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
			takeFee = false;
		}
		
		// only take fees on buys/sells, do not take on wallet transfers
		if (takeFee) {
			uint256 fees;
			uint256 totalFees;
			//buy
			if (automatedMarketMakerPairs[from]) {
				totalFees = buyTotalFees;
				fees = amount.mul(totalFees).div(feeDivisor);
				_liquidityTokensToSwap += fees * buyLiquidityFee / totalFees;
				_marketingTokensToSwap += fees * buyOperationsFee / totalFees;
				_devTokensToSwap += fees * buyDevFee / totalFees;
				
			}
			
			//sell
			if (automatedMarketMakerPairs[to]) {
				totalFees = sellTotalFees;
				fees = amount.mul(totalFees).div(feeDivisor);
				_liquidityTokensToSwap += fees * sellLiquidityFee / totalFees;
				_marketingTokensToSwap += fees * sellOperationsFee / totalFees;
				_devTokensToSwap += fees * sellDevFee / totalFees;
				
			}
			
			if (fees > 0) {
				amount = amount.sub(fees);
				
				super._transfer(from, address(this), fees);
			}
			
		}
		
		super._transfer(from, to, amount);
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
		uniswapV2Router.addLiquidityETH{value : ethAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			address(liquidityWallet),
			block.timestamp
		);
	}
	
	function setRouterVersion(address _router) public onlyOwner {
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
		
		uniswapV2Router = _uniswapV2Router;
		// Set the router of the contract variables
		uniswapV2Router = _uniswapV2Router;
		excludeFromMaxTransaction(address(_uniswapV2Router), true);
	}
	
	function swapBack() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 totalTokensToSwap = _liquidityTokensToSwap + _marketingTokensToSwap + _devTokensToSwap;
		
		// Halve the amount of liquidity tokens
		uint256 tokensForLiquidity = _liquidityTokensToSwap / 2;
		uint256 amountToSwapForBNB = contractBalance - tokensForLiquidity;
		
		uint256 initialBNBBalance = address(this).balance;
		
		swapTokensForEth(amountToSwapForBNB);
		
		uint256 bnbBalance = address(this).balance.sub(initialBNBBalance);
		
		uint256 bnbForMarketing = bnbBalance.mul(_marketingTokensToSwap).div(totalTokensToSwap);
		uint256 bnbForDev = bnbBalance.mul(_devTokensToSwap).div(totalTokensToSwap);
		
		
		uint256 bnbForLiquidity = bnbBalance - bnbForMarketing - bnbForDev;
		
		_liquidityTokensToSwap = 0;
		_marketingTokensToSwap = 0;
		_devTokensToSwap = 0;
		
		(bool success,) = address(marketingWallet).call{value : bnbForMarketing}("");
		(success,) = address(devWallet).call{value : bnbForDev}("");
		
		addLiquidity(tokensForLiquidity, bnbForLiquidity);
		emit SwapAndLiquify(amountToSwapForBNB, bnbForLiquidity, tokensForLiquidity);
	}
	
	// withdraw ETH if stuck before launch
	function withdrawStuckETH() external onlyOwner {
		require(!tradingActive, "Can only withdraw if trading hasn't started");
		bool success;
		(success,) = address(msg.sender).call{value : address(this).balance}("");
	}
}