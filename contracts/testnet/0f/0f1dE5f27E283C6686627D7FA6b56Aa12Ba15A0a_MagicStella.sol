// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./MagicStellaDividendTracker.sol";
import "./Interface/IStellaSwapFactory.sol";
import "./Interface/IStellaSwapPair.sol";
import "./Ownable.sol";

/// @title Stella Token
/// @author Tiber
contract MagicStella is BEP20, Ownable {
	using SafeMath for uint256;

	IUniswapV2Router02 public stellaRouter;
	address public immutable stellaSwapV2Pair;

	bool private swapping;
	MagicStellaDividendTracker public dividendTracker;

	mapping(address => bool) public isAllowedDuringDisabled;
	mapping(address => bool) public isIgnoredAddress;

	// see tokenomics for more details
	address payable public buyBackWallet; // sell team wallet & feed algos
	address payable public liquidityWallet;
	address payable public marketingWallet;
	address payable public devWallet;
	address payable public teamWallet;

	uint8 constant _decimals = 18;

	// 10M
	uint256 private _initTotalSupply = 1 * 10**7 * (10**_decimals); // 6M

	// Max Price Impact
	uint256 public constant DENOMINATOR = 10_000;
	uint256 private constant FLOAT_PRECISION = 10 * DENOMINATOR;
	uint256 private constant SLIPPAGE_TOLERANCE_DENOMINATOR = 100 * DENOMINATOR;
	uint256 public slippageToleranceNum = 2 * DENOMINATOR; // 2%
	uint256 public priceImpact = 2; // 2%
	uint256 public constant KLAST = 1000000000000000000000000 * (10**_decimals);

	// Min amount to transform token in contract to dividends, burn, feed algo & liquify 0.01%
	uint256 public swapTokensAtAmount = (_initTotalSupply * 1) / 10000;
	bool public autoDistributionOfContractsTokens = false;
	bool public autoLunchOfDividendProcess = false;

	// Cooldown & timer functionality
	bool public sellCooldownEnabled = false;
	uint256 public cooldownTimerInterval = 48 hours;
	mapping(address => uint256) public cooldownTimer;
	mapping(address => bool) public isTimelockExempt;

	// max wallet holding of 1% supply - 100 000 tokens
	uint256 public maxTokenByWallet = (_initTotalSupply * 10) / 1000;
	bool public maxWalletEnabled = false;
	mapping(address => bool) public isMaxWalletExempt;

	// fees
	uint256 public buyBackFee = 4;
	uint256 public dividendFee = 4;
	uint256 public burnFee = 0;
	uint256 public totalFee = 8;
	uint256 public sellFee = 20;
	uint256 public lastSwapTime;
	// exclude from fees and max transaction amount
	mapping(address => bool) private _isExcludedFromFees;

	// Disable trading initially
	bool public isTradingEnabled = false;

	// use by default 30,000 gas to process auto-claiming dividends
	uint256 public gasForProcessing = 30000;

	// store addresses that a automatic market maker pairs. Any transfer *to* these addresses
	// could be subject to a maximum transfer amount
	mapping(address => bool) public automatedMarketMakerPairs;

	// Net tokens contracts
	address private constant BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	address private constant USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
	address private constant ETH = address(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);
	address private constant DEAD = address(0x000000000000000000000000000000000000dEaD);
	address private constant ZERO = address(0x0000000000000000000000000000000000000000);

	// Events
	event SwapAndAddLiquidity(uint256 tokensSwapped, uint256 nativeReceived, uint256 tokensIntoLiquidity);
	event ExcludeFromFees(address indexed account, bool isExcluded);
	event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event BuyBackWithNoFees(address indexed holder, uint256 indexed bnbSpent);
	event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
	event BuyBackWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
	event FeesUpdated(
		uint256 indexed buyBackFee,
		uint256 dividendFee,
		uint256 totalFee,
		uint256 sellFee,
		uint256 burnFee
	);
	event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
	event SendDividends(uint256 tokensSwapped, uint256 amount);
	event ProcessedDividendTracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed automatic,
		uint256 gas,
		address indexed processor
	);
	event Burn(uint256 amount);
	event TakeFees(uint256 amount);
	event TakeLargeFees();

	constructor() BEP20("MagicStella", "MagicStella", _decimals) {
		dividendTracker = new MagicStellaDividendTracker(_decimals);
		IUniswapV2Router02 _stellaRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet

		_setAllEcoSystemWallets();

		// Create a pancake pair for this new token (Stella/BUSD)
		address _stellaSwapV2Pair = IUniswapV2Factory(_stellaRouter.factory()).createPair(address(this), BUSD);

		stellaRouter = _stellaRouter;
		stellaSwapV2Pair = _stellaSwapV2Pair;

		_setAutomatedMarketMakerPair(_stellaSwapV2Pair, true);

		_removeRestrictionForEcoSystemWallets(_stellaRouter);

		_dispatchSupplyInAllEcoSystemWallets();
	}

	receive() external payable {}

	function _dispatchSupplyInAllEcoSystemWallets() private {
		uint256 totalForTeamWallet = (_initTotalSupply * 10) / 100;
		uint256 totalForMarketingWallet = (_initTotalSupply * 5) / 100;
		uint256 totalForLiquidityWallet = (_initTotalSupply * 10) / 100;
		uint256 totalForDevWallet = (_initTotalSupply * 5) / 100;
		uint256 totalForSellTeamWallet = (_initTotalSupply * 70) / 100;

		_mint(teamWallet, totalForTeamWallet);
		_mint(marketingWallet, totalForMarketingWallet);
		_mint(devWallet, totalForDevWallet);
		_mint(buyBackWallet, totalForSellTeamWallet);
		_mint(liquidityWallet, totalForLiquidityWallet);
	}

	function _setAllEcoSystemWallets() private {
		//TODO Replace by mainnet contract
		marketingWallet = payable(0xFc3a5413c1bbD21a6e50a47568689AF4c122888e);
		devWallet = payable(0xC9687FaC5d27bAe82412564032938b9c763F0c5E);
		teamWallet = payable(0xad2805b8113066b4f9859689cB8a3fa360fcA1b3);
		liquidityWallet = payable(0x1C7CB4E5171434cdF832F0A57b7B240dB789DD5A);
		buyBackWallet = payable(0xcFB06bAc22107e9Cb741cf6CB94ad2302038742d);
	}

	function _removeRestrictionForEcoSystemWallets(IUniswapV2Router02 _stellaRouter) private {
		ExcludeWalletFromDividends(address(dividendTracker));
		ExcludeWalletFromDividends(address(this));
		ExcludeWalletFromDividends(liquidityWallet);
		ExcludeWalletFromDividends(address(DEAD));
		ExcludeWalletFromDividends(address(ZERO));
		ExcludeWalletFromDividends(address(_stellaRouter));

		ExcludeWalletFromFees(address(this), true);
		ExcludeWalletFromFees(owner(), true);
		ExcludeWalletFromFees(address(dividendTracker), true);
		ExcludeWalletFromFees(buyBackWallet, true);
		ExcludeWalletFromFees(marketingWallet, true);
		ExcludeWalletFromFees(devWallet, true);
		ExcludeWalletFromFees(teamWallet, true);
		ExcludeWalletFromFees(liquidityWallet, true);

		SetIsTimelockExempt(owner(), true);
		SetIsTimelockExempt(marketingWallet, true);
		SetIsTimelockExempt(liquidityWallet, true);
		SetIsTimelockExempt(devWallet, true);
		SetIsTimelockExempt(teamWallet, true);
		SetIsTimelockExempt(buyBackWallet, true);
		SetIsTimelockExempt(address(this), true);
		SetIsTimelockExempt(address(dividendTracker), true);

		SetIsMaxTokenByWalletExempt(owner(), true);
		SetIsMaxTokenByWalletExempt(marketingWallet, true);
		SetIsMaxTokenByWalletExempt(liquidityWallet, true);
		SetIsMaxTokenByWalletExempt(devWallet, true);
		SetIsMaxTokenByWalletExempt(teamWallet, true);
		SetIsMaxTokenByWalletExempt(buyBackWallet, true);
		SetIsMaxTokenByWalletExempt(address(this), true);
		SetIsMaxTokenByWalletExempt(address(dividendTracker), true);

		AllowWalletDuringContractDisabled(owner(), true);
		AllowWalletDuringContractDisabled(address(this), true);
		AllowWalletDuringContractDisabled(teamWallet, true);
		AllowWalletDuringContractDisabled(liquidityWallet, true);
	}

	// @dev Owner functions start -------------------------------------

	// enable / disable custom AMMs
	function SetWhiteListAMM(address ammAddress, bool isWhiteListed) external authorized {
		require(IsContract(ammAddress));
		dividendTracker.setWhiteListAMM(ammAddress, isWhiteListed);
	}

	// change the minimum amount of tokens to sell from fees
	function UpdateSwapTokensAtAmount(uint256 newAmount) external authorized returns (bool) {
		require(newAmount < totalSupply());
		swapTokensAtAmount = newAmount;
		return true;
	}

	function ActiveCooldown(bool _status, uint8 _interval) public authorized {
		sellCooldownEnabled = _status;
		cooldownTimerInterval = _interval;
	}

	function ActiveMaxWalletControlStatus(bool _status) public authorized {
		maxWalletEnabled = _status;
	}

	function ActiveAutoDistributionOfContractsTokensStatus(bool _status) public authorized {
		autoDistributionOfContractsTokens = _status;
	}

	function ActiveAutoDistributionOfDividendProcessStatus(bool _status) public authorized {
		autoLunchOfDividendProcess = _status;
	}

	function UpdateDividendTokensMinimumToHold(uint256 minimumToEarnDivs) external authorized {
		dividendTracker.updateDividendMinimum(minimumToEarnDivs);
	}

	function ExcludeWalletFromFees(address account, bool excluded) public authorized {
		_isExcludedFromFees[account] = excluded;
		emit ExcludeFromFees(account, excluded);
	}

	function AllowWalletDuringContractDisabled(address wallet, bool status) public authorized {
		isAllowedDuringDisabled[wallet] = status;
	}

	function BlacklistWalletForTrading(address wallet, bool status) external authorized {
		isIgnoredAddress[wallet] = status;
	}

	function ExcludeWalletFromDividends(address account) public authorized {
		dividendTracker.excludeFromDividends(account);
	}

	function IncludeWalletInDividends(address account) external authorized {
		dividendTracker.includeInDividends(account);
	}

	function setAutomatedMarketMakerPair(address pair, bool value) external authorized {
		require(pair != stellaSwapV2Pair);

		_setAutomatedMarketMakerPair(pair, value);
	}

	function UpdateBuyBackWallet(address payable newBuyBackWallet) external authorized {
		require(newBuyBackWallet != buyBackWallet);
		ExcludeWalletFromFees(newBuyBackWallet, true);
		emit BuyBackWalletUpdated(newBuyBackWallet, buyBackWallet);
		buyBackWallet = payable(newBuyBackWallet);
	}

	function UpdateFees(
		uint256 _buyBackFee,
		uint256 _dividendFee,
		uint256 _sellFee,
		uint256 _burnFee
	) external authorized {
		uint256 localTotalFee = _buyBackFee.add(_dividendFee).add(_burnFee);
		require(localTotalFee <= 4000); // 40% fees max

		buyBackFee = _buyBackFee;
		dividendFee = _dividendFee;
		totalFee = localTotalFee.sub(_burnFee);
		sellFee = _sellFee;
		burnFee = _burnFee;

		emit FeesUpdated(buyBackFee, dividendFee, totalFee, sellFee, burnFee);
	}

	// changes the gas reserve for processing dividend distribution
	function UpdateGasForProcessing(uint256 newValue) external authorized {
		require(newValue >= 30000 && newValue <= 300000);
		require(newValue != gasForProcessing);
		emit GasForProcessingUpdated(newValue, gasForProcessing);
		gasForProcessing = newValue;
	}

	function UpdateClaimWait(uint256 claimWait) external authorized returns (bool) {
		dividendTracker.updateClaimWait(claimWait);
		return true;
	}

	function SetIgnoreTokenToDividends(address tokenAddress, bool isIgnored) external authorized returns (bool) {
		dividendTracker.setIgnoreToken(tokenAddress, isIgnored);
		return true;
	}

	function SetIsTimelockExempt(address holder, bool status) public authorized {
		isTimelockExempt[holder] = status;
	}

	function SetIsMaxTokenByWalletExempt(address holder, bool status) public authorized {
		isMaxWalletExempt[holder] = status;
	}

	// @dev Views start here ------------------------------------

	// determines if an AMM can be used for rewards
	function IsAMMWhitelisted(address ammAddress) public view returns (bool) {
		return dividendTracker.ammIsWhiteListed(ammAddress);
	}

	function IsContract(address addr) internal view returns (bool) {
		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
		bytes32 codehash;
		assembly {
			codehash := extcodehash(addr)
		}
		return (codehash != 0x0 && codehash != accountHash);
	}

	function GetUserCurrentRewardToken(address holder) public view returns (address) {
		return dividendTracker.userCurrentRewardToken(holder);
	}

	function GetUserHasCustomRewardToken(address holder) public view returns (bool) {
		return dividendTracker.userHasCustomRewardToken(holder);
	}

	function GetRewardTokenSelectionCount(address token) public view returns (uint256) {
		return dividendTracker.rewardTokenSelectionCount(token);
	}

	function GetLastProcessedIndex() external view returns (uint256) {
		return dividendTracker.getLastProcessedIndex();
	}

	function GetNumberOfDividendTokenHolders() external view returns (uint256) {
		return dividendTracker.getNumberOfTokenHolders();
	}

	function GetDividendTokensMinimum() external view returns (uint256) {
		return dividendTracker.minimumTokenBalanceForDividends();
	}

	function GetClaimWait() external view returns (uint256) {
		return dividendTracker.claimWait();
	}

	function GetTotalDividendsDistributed() external view returns (uint256) {
		return dividendTracker.totalDividendsDistributed();
	}

	function IsExcludedFromFees(address account) public view returns (bool) {
		return _isExcludedFromFees[account];
	}

	function WithdrawableDividendOf(address account) public view returns (uint256) {
		return dividendTracker.withdrawableDividendOf(account);
	}

	function DividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function GetAccountDividendsInfo(address account)
		external
		view
		returns (
			address,
			int256,
			int256,
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		)
	{
		return dividendTracker.getAccount(account);
	}

	function GetAccountDividendsInfoAtIndex(uint256 index)
		external
		view
		returns (
			address,
			int256,
			int256,
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		)
	{
		return dividendTracker.getAccountAtIndex(index);
	}

	function IsIgnoredToken(address tokenAddress) public view returns (bool) {
		return dividendTracker.isIgnoredToken(tokenAddress);
	}

	// @dev User Callable Functions start here! ---------------------------------------------

	function SetRewardToken(address rewardTokenAddress) public returns (bool) {
		require(IsContract(rewardTokenAddress));
		require(rewardTokenAddress != address(this));
		require(!IsIgnoredToken(rewardTokenAddress));
		dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, address(stellaRouter));
		return true;
	}

	function SetRewardTokenWithCustomAMM(address rewardTokenAddress, address ammContractAddress) public returns (bool) {
		require(IsContract(rewardTokenAddress));
		require(ammContractAddress != address(stellaRouter));
		require(rewardTokenAddress != address(this));
		require(!IsIgnoredToken(rewardTokenAddress));
		require(IsAMMWhitelisted(ammContractAddress) == true);

		dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, ammContractAddress);
		return true;
	}

	function UnsetRewardToken() public returns (bool) {
		dividendTracker.unsetRewardToken(msg.sender);
		return true;
	}

	function ActivateContract() public authorized {
		isTradingEnabled = true;
	}

	function Claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
	}

	function ProcessDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
	}

	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value);
		automatedMarketMakerPairs[pair] = value;

		if (value) {
			dividendTracker.excludeFromDividends(pair);
		}
		emit SetAutomatedMarketMakerPair(pair, value);
	}

	function _checkPrerequisites(
		address from,
		address to,
		uint256 amount
	) private {
		require(from != address(0), "");
		require(to != address(0), "");
		require(!isIgnoredAddress[to] || !isIgnoredAddress[from]);

		if (!isTradingEnabled) {
			require(isAllowedDuringDisabled[to] || isAllowedDuringDisabled[from]);
		}

		if (automatedMarketMakerPairs[to] && !isTradingEnabled && isAllowedDuringDisabled[from]) {
			require((from == owner() || to == owner()) || isAllowedDuringDisabled[from]);
		}

		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}

		_cooldownTimer(from, to);
		_verifyMaxTokensForWallet(from, to, amount);
	}

	function _cooldownTimer(address from, address to) private {
		if (sellCooldownEnabled && _isSellerTransfer(to) && !isTimelockExempt[from] && !isTimelockExempt[to]) {
			require(cooldownTimer[from] < block.timestamp);
			cooldownTimer[from] = block.timestamp + cooldownTimerInterval;
		}
	}

	function _isSellerTransfer(address to) private view returns (bool) {
		return automatedMarketMakerPairs[to];
	}

	function _isBuyerTransfer(address from) private view returns (bool) {
		return automatedMarketMakerPairs[from];
	}

	function _verifyMaxTokensForWallet(
		address from,
		address to,
		uint256 amount
	) private view {
		if (maxWalletEnabled && !isMaxWalletExempt[to] && !isMaxWalletExempt[from] && !_isSellerTransfer(to)) {
			uint256 heldTokens = balanceOf(to);
			require((heldTokens + amount) <= maxTokenByWallet);
		}
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal override {
		_checkPrerequisites(from, to, amount);

		uint256 senderBalance = balanceOf(from);
		require(senderBalance >= amount);

		uint256 contractTokenBalance = balanceOf(address(this));
		uint256 contractNativeBalance = address(this).balance;

		bool canSwapContractToken = _canSwapContractToken(from, to, contractTokenBalance);

		if (canSwapContractToken) {
			swapping = true;

			_executeSwap(contractTokenBalance, contractNativeBalance);

			lastSwapTime = block.timestamp;
			swapping = false;
		}

		bool takeFee = _doNeedToTakeFees(from, to, swapping);

		if (takeFee) {
			uint256 localFeesRation = totalFee;
			uint256 initialAmount = amount;

			// Ajout d'une taxe car grosse vente
			if (_isSellerTransfer(to) && _shouldApplySlippageTax(amount)) {
				localFeesRation = localFeesRation.add(sellFee);
				emit TakeLargeFees();
			}

			uint256 fees = (initialAmount.mul(localFeesRation)).div(100);
			amount = amount.sub(fees);

			// Burn
			if (burnFee > 0) {
				uint256 burnTokens = (initialAmount.mul(burnFee)).div(100);
				_burnTokens(from, burnTokens);
				amount = amount.sub(burnTokens);
			}

			_executeTransfer(from, address(this), fees);

			emit TakeFees(fees);
		}

		_executeTransfer(from, to, amount);

		try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
		try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

		if (!swapping && autoLunchOfDividendProcess) {
			_lunchDividendProcess();
		}
	}

	function _canSwapContractToken(
		address from,
		address to,
		uint256 contractTokenBalance
	) private view returns (bool) {
		if (
			autoDistributionOfContractsTokens &&
			contractTokenBalance >= swapTokensAtAmount &&
			!swapping &&
			!automatedMarketMakerPairs[from] &&
			from != address(stellaRouter) &&
			from != owner() &&
			to != owner()
		) {
			return true;
		} else {
			return false;
		}
	}

	function _doNeedToTakeFees(
		address from,
		address to,
		bool _swapping
	) private view returns (bool) {
		bool takeFee;

		if (from == stellaSwapV2Pair || to == stellaSwapV2Pair) {
			takeFee = true;
		}

		if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
			takeFee = false;
		}

		if (_swapping) {
			takeFee = false;
		}

		return takeFee;
	}

	// Permet de processer le contrat de dividende et lancer une distribution
	function _lunchDividendProcess() private {
		uint256 gas = gasForProcessing;

		try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
			emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
		} catch {}
	}

	// permet de lancer manuellement le swap interne pour distribution des dividendes & BB
	function LunchDistributionOfContratsTokens() public authorized returns (uint256) {
		uint256 contractTokenBalance = balanceOf(address(this));
		uint256 contractNativeBalance = address(this).balance;

		lastSwapTime = block.timestamp;

		uint256 nbOfTokensSwaped = _executeSwap(contractTokenBalance, contractNativeBalance);

		if (nbOfTokensSwaped > 0) {
			lastSwapTime = block.timestamp;
		}

		return nbOfTokensSwaped;
	}

	// Lancer un transfer
	function _executeTransfer(
		address sender,
		address recipient,
		uint256 amount
	) private {
		require(sender != address(0));
		require(recipient != address(0));

		uint256 senderBalance = balanceOf(sender);
		require(senderBalance >= amount);

		DeduceAmountToBalanceOf(sender, amount);
		AddAmountToBalanceOf(recipient, amount);

		emit Transfer(sender, recipient, amount);
	}

	// Permet d'utiliser les stella sur le contrat afin de convertir en BNB et distribuer vers le contrat de dividendes & le contrat des BB
	function _executeSwap(uint256 tokens, uint256 native) private returns (uint256) {
		if (tokens <= 0) {
			return 0;
		}

		// BuyBack for algo
		uint256 swapTokensBuyBack;
		if (address(buyBackWallet) != address(0)) {
			swapTokensBuyBack = (tokens * buyBackFee) / totalFee;
		}

		// Dividends
		uint256 swapTokensDividends;
		if (dividendTracker.totalSupply() > 0) {
			swapTokensDividends = (tokens * dividendFee) / totalFee;
		}

		uint256 swapTokensTotal = swapTokensBuyBack + swapTokensDividends;

		uint256 initNativeBal = address(this).balance;
		bool isSwaped = _swapTokensForNative(swapTokensTotal);
		if (!isSwaped) return 0;

		uint256 nativeSwapped = (address(this).balance - initNativeBal) + native;

		uint256 nativeBuyBack = (nativeSwapped * swapTokensBuyBack) / swapTokensTotal;
		uint256 nativeDividends = (nativeSwapped * swapTokensDividends) / swapTokensTotal;

		if (nativeBuyBack > 0) {
			payable(buyBackWallet).transfer(nativeBuyBack);
		}

		if (nativeDividends > 0) {
			(bool success, ) = address(dividendTracker).call{ value: nativeDividends }("");
			if (success) {
				emit SendDividends(swapTokensDividends, nativeDividends);
			}
		}

		return swapTokensTotal;
	}

	// permet de swap le stella vers le BNB
	function _swapTokensForNative(uint256 tokens) private returns (bool) {
		address[] memory path = new address[](4);
		path[0] = address(this);
		path[1] = BUSD;
		path[2] = USDT;
		path[3] = stellaRouter.WETH();

		_approve(address(this), address(stellaRouter), tokens);

		try
			stellaRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
				tokens,
				0, // accept any amount of native
				path,
				address(this),
				block.timestamp.add(300)
			)
		{
			return true;
		} catch {
			return false;
		}
	}

	// Permet de bruler des tokens ( envoie vers wallet DEAD )
	function _burnTokens(address sender, uint256 amount) private {
		_executeTransfer(sender, DEAD, amount);
		emit Burn(amount);
	}

	// Permet d'envoyer tous les stella disponible sur le contrat vers le wallet des BB
	function RecoverContractStellaToBuyBackWallet(uint256 recoverRate) public authorized {
		uint256 stellaAmount = address(this).balance;

		if (stellaAmount > 0) {
			uint256 amount = stellaAmount.mul(recoverRate).div(100);
			payable(buyBackWallet).transfer(amount);
		}
	}

	// Nombre de token maximum par wallet
	function SetMaxTokenByWallet(uint256 _maxTokenByWallet) external authorized {
		maxTokenByWallet = _maxTokenByWallet;
	}

	// function SetPriceImpact(uint256 _percent) external authorized {
	// 	require(_percent < 20);
	// 	slippageToleranceNum = _percent * DENOMINATOR;
	// }

	// function _shouldApplySlippageTax(uint256 amount) public view returns (bool) {
	// 	return _calculateSlippage(amount) > slippageToleranceNum ? true : false;
	// }

	// function _calculateSlippage(uint256 amount) public view returns (uint256) {
	// 	address[] memory _path = new address[](2);
	// 	_path[0] = address(this);
	// 	_path[1] = BUSD;

	// 	uint256 _instantPrice = stellaRouter.getAmountsOut(FLOAT_PRECISION, _path)[1];
	// 	uint256 _amountOut = stellaRouter.getAmountsOut(amount, _path)[1];
	// 	uint256 _amountOutInstant = (amount * _instantPrice) / FLOAT_PRECISION;

	// 	if (_amountOutInstant < _amountOut || amount < FLOAT_PRECISION) {
	// 		return 0;
	// 	}
	// 	return SLIPPAGE_TOLERANCE_DENOMINATOR - (_amountOut * SLIPPAGE_TOLERANCE_DENOMINATOR) / _amountOutInstant;
	// }

	function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
		require(tokenA != tokenB);
		(token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		require(token0 != address(0));
	}

	function getReserves(address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
		(address token0, ) = sortTokens(tokenA, tokenB);
		(uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(stellaSwapV2Pair).getReserves();
		(reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
	}

	function _shouldApplySlippageTax(uint256 amount) internal view returns (bool) {
		(uint256 _reserveA, uint256 _reserveB) = getReserves(address(this), BUSD);
		uint256 _constant = IUniswapV2Pair(stellaSwapV2Pair).kLast();
		if (_constant == 0) _constant = KLAST;

		uint256 _market_price = _reserveA.div(_reserveB);

		if (_reserveA == 0 && _reserveB == 0) {
			return false;
		} else {
			if (amount >= _reserveA) return false;

			uint256 _reserveA_new = _reserveA.sub(amount);
			uint256 _reserveB_new = _constant.div(_reserveA_new);

			if (_reserveB >= _reserveB_new) return false;
			uint256 receivedBUSD = _reserveB_new.sub(_reserveB);

			uint256 _new_price = (amount.div(receivedBUSD)).mul(10**18);
			uint256 _delta_price = _new_price.div(_market_price);
			uint256 _priceImpact = calculPriceImpactLimit();

			return (_delta_price < _priceImpact);
		}
	}

	function setPriceImpact(uint256 _percent) external authorized {
		priceImpact = _percent;
	}

	function calculPriceImpactLimit() internal view returns (uint256) {
		return ((uint256(100).sub(priceImpact)).mul(10**_decimals)).div(100);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./AbstractContract/Context.sol";

contract Ownable is Context{

    address private _owner;
    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = _msgSender();
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }


    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        authorizations[_owner] = false;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        authorizations[newOwner] = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Library/IterableMapping.sol";
import "./DividendPayingToken.sol";

contract MagicStellaDividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(uint8 _decimals) DividendPayingToken("MagicStella_Dividend_Tracker", "MagicStella_Dividend_Tracker", _decimals) {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 1 * 10 ** 3 * (10**_decimals); //must hold 1000+ tokens to get divs
    }

    function _transfer(address, address, uint256) pure internal override {
        require(false, "MagicStella_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() pure public override {
        require(false, "MagicStella_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main MagicStella contract.");
    }

    function excludeFromDividends(address account) external authorized {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account) external authorized {
        require(excludedFromDividends[account]);
        excludedFromDividends[account] = false;

        emit IncludeInDividends(account);
    }
    
    function updateDividendMinimum(uint256 minimumToEarnDivs) external authorized {
        minimumTokenBalanceForDividends = minimumToEarnDivs;
    }

    function updateClaimWait(uint256 newClaimWait) external authorized {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "MagicStella_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "MagicStella_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external authorized {
        
        if(excludedFromDividends[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public authorized returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }



    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IStellaRouter01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface DividendPayingTokenOptionalInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface DividendPayingTokenInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) external view returns(uint256);

  /// @notice Distributes ether to token holders as dividends.
  /// @dev SHOULD distribute the paid ether to token holders as dividends.
  ///  SHOULD NOT directly transfer ether to token holders in this function.
  ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
  function distributeDividends() external payable;

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./BEP20.sol";
import "./Ownable.sol";
import "./Interface/DividendPayingTokenInterface.sol";
import "./Interface/DividendPayingTokenOptionalInterface.sol";
import "./Interface/IStellaRouter02.sol";


/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable BEP20 token that allows anyone to pay and distribute ether
///  to token holders as dividends and allows token holders to withdraw their dividends.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken is BEP20, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface, Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
  // For more discussion about choosing the value of `magnitude`,
  //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
  uint256 constant internal magnitude = 2**128;
  
  uint256 internal magnifiedDividendPerShare;

  // About dividendCorrection:
  // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
  //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
  // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
  //   `dividendOf(_user)` should not be changed,
  //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
  // To keep the `dividendOf(_user)` unchanged, we add a correction term:
  //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
  //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
  //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
  // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  mapping(address => uint256) internal rawBNBWithdrawnDividends;
  mapping(address => address) public userCurrentRewardToken;
  mapping(address => bool) public userHasCustomRewardToken;
  mapping(address => address) public userCurrentRewardAMM;
  mapping(address => bool) public userHasCustomRewardAMM;
  mapping(address => uint256) public rewardTokenSelectionCount; // keep track of how many people have each reward token selected (for fun mostly)
  mapping(address => bool) public ammIsWhiteListed; // only allow whitelisted AMMs
  mapping(address => bool) public ignoreRewardTokens;
 
  IUniswapV2Router02 public stellaRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
  
  function updateDividendStellaRouter(address newAddress) external authorized {
        require(newAddress != address(stellaRouter), "MagicStella: The router already has that address");
        stellaRouter = IUniswapV2Router02(newAddress);
    }
  
  uint256 public totalDividendsDistributed; // dividends distributed per reward token

  address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) BEP20(_name, _symbol, _decimals) {
    // add whitelisted AMMs here -- more will get added postlaunch
    ammIsWhiteListed[address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)] = true; // PCS V2 router
    //ammIsWhiteListed[address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F)] = true; // PCS V1 router
    //ammIsWhiteListed[address(0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7)] = true; // ApeSwap router
  }

  /// @dev Distributes dividends whenever ether is paid to this contract.
  receive() external payable {
    distributeDividends();
  }
  
  
  // Customized function to send tokens to dividend recipients
  function swapETHForTokens(
        address recipient,
        uint256 bnbAmount
    ) private returns (uint256) {
        
        bool swapSuccess;
        IBEP20 token = IBEP20(userCurrentRewardToken[recipient]);
        IUniswapV2Router02 swapRouter = stellaRouter;
        
        if(userHasCustomRewardAMM[recipient] && ammIsWhiteListed[userCurrentRewardAMM[recipient]]){
            swapRouter = IUniswapV2Router02(userCurrentRewardAMM[recipient]);
        }
        
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = swapRouter.WETH();
        path[1] = address(token);
        
        // make the swap
        try swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}( //try to swap for tokens, if it fails (bad contract, or whatever other reason, send BNB)
            1, // accept any amount of Tokens above 1 wei (so it will fail if nothing returns)
            path,
            address(recipient),
            block.timestamp + 360
        ){
            swapSuccess = true;
        }
        catch {
            swapSuccess = false;
        }
        
        // if the swap failed, send them their BNB instead
        if(!swapSuccess){
            rawBNBWithdrawnDividends[recipient] = rawBNBWithdrawnDividends[recipient].add(bnbAmount);
            (bool success,) = recipient.call{value: bnbAmount, gas: 3000}("");
    
            if(!success) {
                withdrawnDividends[recipient] = withdrawnDividends[recipient].sub(bnbAmount);
                rawBNBWithdrawnDividends[recipient] = rawBNBWithdrawnDividends[recipient].sub(bnbAmount);
                return 0;
            }
        }
        return bnbAmount;
    }

    function swapETHForBUSDTokens(
        address recipient,
        uint256 bnbAmount
    ) private returns (uint256) {
        
        bool swapSuccess;
        IBEP20 token = IBEP20(BUSD);
        IUniswapV2Router02 swapRouter = stellaRouter;
        
        if(userHasCustomRewardAMM[recipient] && ammIsWhiteListed[userCurrentRewardAMM[recipient]]){
            swapRouter = IUniswapV2Router02(userCurrentRewardAMM[recipient]);
        }
        
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = swapRouter.WETH();
        path[1] = address(token);
        
        // make the swap
        try swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}( //try to swap for tokens, if it fails (bad contract, or whatever other reason, send BNB)
            1, // accept any amount of Tokens above 1 wei (so it will fail if nothing returns)
            path,
            address(recipient),
            block.timestamp + 360
        ){
            swapSuccess = true;
        }
        catch {
            swapSuccess = false;
        }
        
        // if the swap failed, send them their BNB instead
        if(!swapSuccess){
            rawBNBWithdrawnDividends[recipient] = rawBNBWithdrawnDividends[recipient].add(bnbAmount);
            (bool success,) = recipient.call{value: bnbAmount, gas: 3000}("");
    
            if(!success) {
                withdrawnDividends[recipient] = withdrawnDividends[recipient].sub(bnbAmount);
                rawBNBWithdrawnDividends[recipient] = rawBNBWithdrawnDividends[recipient].sub(bnbAmount);
                return 0;
            }
        }
        return bnbAmount;
    }
  
  function setIgnoreToken(address tokenAddress, bool isIgnored) external authorized {
      ignoreRewardTokens[tokenAddress] = isIgnored;
  }
  
  function isIgnoredToken(address tokenAddress) public view returns (bool){
      return ignoreRewardTokens[tokenAddress];
  }
  
  function getRawBNBDividends(address holder) external view returns (uint256){
      return rawBNBWithdrawnDividends[holder];
  }
    
  function setWhiteListAMM(address ammAddress, bool whitelisted) external authorized {
      ammIsWhiteListed[ammAddress] = whitelisted;
  }
  
  // call this to set a custom reward token (call from token contract only)
  function setRewardToken(address holder, address rewardTokenAddress, address ammContractAddress) external authorized {
    if(userHasCustomRewardToken[holder] == true){
        if(rewardTokenSelectionCount[userCurrentRewardToken[holder]] > 0){
            rewardTokenSelectionCount[userCurrentRewardToken[holder]] -= 1; // remove count from old token
        }
    }

    userHasCustomRewardToken[holder] = true;
    userCurrentRewardToken[holder] = rewardTokenAddress;
    // only set custom AMM if the AMM is whitelisted.
    if(ammContractAddress != address(stellaRouter) && ammIsWhiteListed[ammContractAddress]){
        userHasCustomRewardAMM[holder] = true;
        userCurrentRewardAMM[holder] = ammContractAddress;
    } else {
        userHasCustomRewardAMM[holder] = false;
        userCurrentRewardAMM[holder] = address(stellaRouter);
    }
    rewardTokenSelectionCount[rewardTokenAddress] += 1; // add count to new token
  }
  
  
  // call this to go back to receiving BNB after setting another token. (call from token contract only)
  function unsetRewardToken(address holder) external authorized {
    userHasCustomRewardToken[holder] = false;
    if(rewardTokenSelectionCount[userCurrentRewardToken[holder]] > 0){
        rewardTokenSelectionCount[userCurrentRewardToken[holder]] -= 1; // remove count from old token
    }
    userCurrentRewardToken[holder] = address(0);
    userCurrentRewardAMM[holder] = address(stellaRouter);
    userHasCustomRewardAMM[holder] = false;
  }

  /// @notice Distributes ether to token holders as dividends.
  /// @dev It reverts if the total supply of tokens is 0.
  /// It emits the `DividendsDistributed` event if the amount of received ether is greater than 0.
  /// About undistributed ether:
  ///   In each distribution, there is a small amount of ether not distributed,
  ///     the magnified amount of which is
  ///     `(msg.value * magnitude) % totalSupply()`.
  ///   With a well-chosen `magnitude`, the amount of undistributed ether
  ///     (de-magnified) in a distribution can be less than 1 wei.
  ///   We can actually keep track of the undistributed ether in a distribution
  ///     and try to distribute it in the next distribution,
  ///     but keeping track of such data on-chain costs much more than
  ///     the saved ether, so we don't do that.
  
  function distributeDividends() public override payable {
    require(totalSupply() > 0);

    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);

      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }
  
  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {

    uint256 _withdrawableDividend = withdrawableDividendOf(user);

    if (_withdrawableDividend > 0) {
      
        withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
        emit DividendWithdrawn(user, _withdrawableDividend);

         // if no custom reward token or reward token is ignored, send BNB.
        if(!userHasCustomRewardToken[user] && !isIgnoredToken(userCurrentRewardToken[user])){
        
          // withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
          // rawBNBWithdrawnDividends[user] = rawBNBWithdrawnDividends[user].add(_withdrawableDividend);
          // emit DividendWithdrawn(user, _withdrawableDividend);
          // (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
    
          // if(!success) {
          //   withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
          //   rawBNBWithdrawnDividends[user] = rawBNBWithdrawnDividends[user].sub(_withdrawableDividend);
          //   return 0;
          // }
          // return _withdrawableDividend;

          return swapETHForBUSDTokens(user, _withdrawableDividend);
          
        // the reward is a token, not BNB, use an IBEP20 buyback instead!
        } else { 
            
          return swapETHForTokens(user, _withdrawableDividend);
        }
    }
    return 0;
  }


  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }

  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }


  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  /// @dev Internal function that transfer tokens from one address to another.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param from The address to transfer from.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }

  /// @dev Internal function that mints tokens to an account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account that will receive the created tokens.
  /// @param value The amount that will be created.
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  /// @dev Internal function that burns an amount of the token of a given account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account whose tokens will be burnt.
  /// @param value The amount that will be burnt.
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Library/SafeMath.sol";
import "./Interface/IBEP20.sol";
import "./AbstractContract/Context.sol";

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-Add Amount to balance}.
     */
    function AddAmountToBalanceOf(address account, uint256 amount) internal returns (bool) {
        _balances[account] += amount;
        return true;
    }

    /**
     * @dev See {IBEP20- deduce Amount to balance}.
     */
    function DeduceAmountToBalanceOf(address account, uint256 amount) internal returns (bool) {
        _balances[account] -= amount;
        return true;
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    } 

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}