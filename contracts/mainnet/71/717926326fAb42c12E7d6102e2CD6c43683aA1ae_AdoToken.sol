// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
// Web: https://www.ado.network
// Twitter: https://twitter.com/NetworkAdo
// Discord: https://discord.gg/n9FyS5Tr
// Telegram: https://t.me/ADONetworkEnglish
// Reddit: https://www.reddit.com/r/ADO_Network/

// ADO works simultaneously with two liquidity pools, ADO-BNB and ADO-BUSD.
// ADO can switch between pools anytime, moving 99% of the funds from
// main pool to secondary pool and generate revenue for holders by earning in price compared to the price of BNB.
// ADO.Network Team is not responsible for any losses incurred by swaping in the secondary pool.
// If you use PancakeSwap, make sure you are dealing with the Main Pool.
// We'd recommend using the swap mode on www.ado.network as it is set to always work with the Main Pool.
import "./libraries/SafeMath.sol";
import "./DividendTracker.sol";
import "./AdoVault.sol";
import "./LPManager.sol";
import "./abstracts/Ownable.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IPancakeSwapV2Pair.sol";
import "./interfaces/IPancakeSwapV2Factory.sol";
import "./interfaces/IPancakeSwapV2Router02.sol";

contract AdoToken is IBEP20, Ownable {
	using SafeMath for uint256;

	address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	address public immutable deployer;
	address public mainLPToken;
	IPancakeSwapV2Router02 public pancakeSwapV2Router;
	IPancakeSwapV2Pair public pancakeSwapWETHV2Pair;
	IPancakeSwapV2Pair public pancakeSwapBUSDV2Pair;
	DividendTracker public dividendContract;
	LPManager public lpManager;
	IBEP20 public busdContract;
	
	string private _name = "ADO.Network";
	string private _symbol = "ADO";
	uint8 private _decimals = 18;
	bool public swapEnabled = false;
	bool private _swapping = false;
	bool private _dividendContractSet = false;
	bool private _busdContractSet = false;
	bool private _lpManagerSet = false;
	uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
	uint256 private _tokensToLiqudate = _totalSupply.div(10000);
	uint256 private _lpWeight;
	uint256 private _holdersLotteryFund;
	uint256 private _referrersLotteryFund;
	uint256 private _buyBackBalance;
	uint256 private _cursor;
	uint256 private _dividendFee = 2;
	uint256 private _buyBackFee = 6;
	uint256 private _lotteryFee = 2;
	uint256 private _totalFee = 10;
	uint256 private _totalIterations;
	uint256 public partners;
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping (address => bool) private _isExcludedFromFees;
	mapping (address => bool) private _partners;

	event ExcludedAddress(address indexed account, bool fromFee, bool fromDividends, bool fromLottery);
	event NewPartner(address indexed account);
	event BuyBackUpdate(address indexed token, uint256 eth, uint256 busd);
	event LPWeight(uint256 lp, uint256 bb);
	event FeeDistribution(uint256 buyBack, uint256 dividend, uint256 lottery);
	event TokenBalanceToLiqudate(uint256 indexed newValue, uint256 indexed oldValue);
	event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 indexed lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);
	event MainLPSwitch(address indexed newToken);

	modifier onlyDeployer() {
		require(_msgSender() == deployer, "Token: Only the token deployer can call this function");
		_;
	}

	constructor() {
		deployer = owner();
		_isExcludedFromFees[owner()] = true;
		_isExcludedFromFees[address(this)] = true;
		_isExcludedFromFees[BURN_ADDRESS] = true;
		_balances[owner()] = _totalSupply;
		emit Transfer(address(0), owner(), _totalSupply);
	}

	receive() external payable {}

	function name() external view override returns (string memory) {
		return _name;
	}

	function symbol() external view override returns (string memory) {
		return _symbol;
	}

	function decimals() external view override returns (uint8) {
		return _decimals;
	}

	function getOwner() external view override returns (address) {
		return owner();
	}

	function totalFee() external view returns (uint256) {
		return _totalFee;
	}

	function fees() external view returns (uint256 dividendFee, uint256 buyBackFee, uint256 lotteryFee, bool isActive) {
		dividendFee = _dividendFee;
		buyBackFee = _buyBackFee;
		lotteryFee = _lotteryFee;
		isActive = _totalFee > 0;
	}

	function totalSupply() external view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) external view override returns (uint256) {
		return _balances[account];
	}

	function isExcludedFromFees(address account) external view returns(bool) {
		return _isExcludedFromFees[account];
	}

	function tokensToLiqudate() external view returns(uint256) {
		return _tokensToLiqudate;
	}

	function totalIterations() external view returns(uint256) {
		return _totalIterations;
	}

	function cursor() external view returns(uint256) {
		return _cursor;
	}

	function lpvsbb() external view returns(uint256 lp, uint256 bb) {
		uint256 weight = 10;
		lp = _lpWeight;
		bb = weight.sub(_lpWeight);
	}

	function funds() external view returns(uint256 hlf, uint256 rlf, uint256 bbbnb, uint256 bbbusd) {
		hlf = _holdersLotteryFund;
		rlf = _referrersLotteryFund;
		bbbnb = _buyBackBalance;
		bbbusd = busdContract.balanceOf(address(this));
	}

	function transfer(address recipient, uint256 amount) external override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Token: transfer amount exceeds allowance"));
		return true;
	}

	function updateLPWeight(uint256 lpWeight) external onlyDeployer returns (bool) {
		require(lpWeight <= 10, "Token: LPWeight must be between 0 and 10");
		_lpWeight = lpWeight;
		emit LPWeight(_lpWeight, 10 - _lpWeight);
		return true;
	}

	function updateFeeDistribution(uint256 newBuyBackFee) external onlyDeployer returns (bool) {
		require(newBuyBackFee != _buyBackFee, "Token: The BuyBack fee is already set to the requested value");
		require(newBuyBackFee == 2 || newBuyBackFee == 4 || newBuyBackFee == 6, "Token: The BuyBack fee can only be 2 4 or 6");
		_buyBackFee = newBuyBackFee;
		_dividendFee = _totalFee.sub(_buyBackFee).sub(_lotteryFee);
		emit FeeDistribution(_buyBackFee, _dividendFee, _lotteryFee);
		return true;
	}

	function updateTokensToLiqudate(uint256 newValue) external onlyDeployer returns (bool) {
		require(newValue >= 100000000000000000000 && newValue <= 1000000000000000000000000, "Token: numTokensToLiqudate must be between 100 and 1.000.000 ADO");
		emit TokenBalanceToLiqudate(newValue, _tokensToLiqudate);
		_tokensToLiqudate = newValue;
		return true;
	}

	function buyBack(uint256 amount, address recipient) external onlyDeployer {
		require(recipient == BURN_ADDRESS || recipient == address(dividendContract), "Token: Invalid recipient.");
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			require(amount <= _buyBackBalance, "Token: Insufficient funds.");
			swapETHForTokens(recipient, 0, amount);
			_buyBackBalance = address(this).balance
				.sub(_holdersLotteryFund)
				.sub(_referrersLotteryFund);
		} else {
			require(amount <= busdContract.balanceOf(address(this)), "Token: Insufficient funds.");
			address[] memory path = new address[](2);
			path[0] = address(busdContract);
			path[1] = address(this);
			busdContract.approve(address(pancakeSwapV2Router), amount);
			pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				amount,
				0,
				path,
				recipient,
				block.timestamp
			);
		}
	}

	function processDividendTracker() external onlyDeployer {
		require(_dividendContractSet, "Token: Dividend Contract Token is not set");
		uint256 contractTokenBalance = _balances[address(this)];
		bool canSwap = contractTokenBalance > _tokensToLiqudate;
		if (canSwap) {
			_swapping = true;
			swapAndSendDividends(_tokensToLiqudate);
			_swapping = false;
		}
		uint256 _iterations = 0;
		try dividendContract.process() returns (uint256 iterations, uint256 claims, uint256 lpIndex) {
			emit ProcessedDividendTracker(iterations, claims, lpIndex, true, dividendContract.gasForProcessing(), tx.origin);
			_iterations = iterations;
		} catch {}
		_totalIterations = _totalIterations.add(_iterations);
	}

	function addPartner(address account) external onlyDeployer returns (uint256) {
		require(_partners[account] == false, "Token: Account is a partner");
		_partners[account] = true;
		partners++;
		dividendContract.excludeFromLottery(account);
		emit NewPartner(account);
		return partners;
	}

	function excludeAddress(address account, bool fromFee, bool fromDividends, bool fromLottery) external onlyDeployer returns (bool) {
		if (fromFee) {
			require(_isExcludedFromFees[account] == false, "Token: Account is already excluded");
			_isExcludedFromFees[account] = true;
		}
		if (fromDividends) {
			dividendContract.excludeFromDividends(account);
		}
		if (fromLottery) {
			dividendContract.excludeFromLottery(account);
		}
		emit ExcludedAddress(account, fromFee, fromDividends, fromLottery);
		return true;
	}

	function removeTax() external onlyDeployer returns (uint256) {
		require(dividendContract.maxMilestone() == 0, "Token: milestone in progress");
		_totalFee = 0;
		uint256 burnedAmount = _balances[address(this)];
		_transfer(address(this), BURN_ADDRESS, burnedAmount);
		_buyBackBalance = address(this).balance;
		_holdersLotteryFund = 0;
		_referrersLotteryFund = 0;
		uint256 dBurnedAmount = dividendContract.burnTheHouseDown();
		return burnedAmount.add(dBurnedAmount);
	}

	function _approve(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "Token: approve from the zero address");
		require(spender != address(0), "Token: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function swapBUSDforETH(uint256 amount, address to) private returns (uint256) {
		uint256 initialBalance = address(this).balance;
		address[] memory path = new address[](2);
		path[0] = address(busdContract);
		path[1] = pancakeSwapV2Router.WETH();
		busdContract.approve(address(pancakeSwapV2Router), amount);
		pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			amount,
			0,
			path,
			to,
			block.timestamp
		);
		return address(this).balance.sub(initialBalance);
	}

	function swapETHforBUSD(uint256 amount, address to) private returns (uint256) {
		uint256 initialBalance = busdContract.balanceOf(address(this));
		address[] memory path = new address[](2);
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(busdContract);
		pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0, path, to, block.timestamp);
		return busdContract.balanceOf(address(this)).sub(initialBalance);
	}

	function swapETHForTokens(address recipient, uint256 minTokenAmount, uint256 amount) private {
		address[] memory path = new address[](2);
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(this);
		pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
			minTokenAmount,
			path,
			recipient,
			block.timestamp
		);
	}

	function swapTokensForEth(uint256 tokenAmount) public returns (uint256) {
		uint256 pathlength = mainLPToken == pancakeSwapV2Router.WETH() ? 2 : 3;
		address[] memory path = new address[](pathlength);
		path[0] = address(this);
		path[1] = mainLPToken;
		if (mainLPToken != pancakeSwapV2Router.WETH()) {
			path[2] = pancakeSwapV2Router.WETH();
		}
		uint256 initialBalance = address(this).balance;
		_approve(address(this), address(pancakeSwapV2Router), tokenAmount);
		pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0,
			path,
			address(this),
			block.timestamp
		);
		uint256 eth = address(this).balance.sub(initialBalance);
		return eth;
	}

	function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
		_approve(address(this), address(pancakeSwapV2Router), tokenAmount);
		pancakeSwapV2Router.addLiquidityETH{value: ethAmount}(
			address(this),
			tokenAmount,
			0,
			0,
			address(lpManager),
			block.timestamp
		);
	}

	function swapAndSendDividends(uint256 amount) private {
		_cursor++;
		bool addLP = (mainLPToken == pancakeSwapV2Router.WETH()) && (_cursor.mod(10) < _lpWeight);
		uint256 swapTokensAmount = amount;
		if (addLP) {
			uint256 lpf = _buyBackFee.div(2);
			lpf = lpf.add(_lotteryFee).add(_dividendFee);
			swapTokensAmount = amount.div(_totalFee).mul(lpf);
		}
		uint256 eth = swapTokensForEth(swapTokensAmount);
		uint256 lotteriesEth = eth.div(_totalFee).mul(_lotteryFee);
		_holdersLotteryFund = _holdersLotteryFund.add(lotteriesEth.div(2));
		_referrersLotteryFund = _referrersLotteryFund.add(lotteriesEth.div(2));
		uint256 dividendEth = eth.div(_totalFee).mul(_dividendFee);
		(bool dividendContractTransfer,) = payable(address(dividendContract)).call{value: dividendEth, gas: 3000}('');
		if (dividendContractTransfer) {
			dividendContract.updateDividendsDistributed(dividendEth);
		}
		if (addLP) {
			uint256 lpeth = eth.sub(lotteriesEth).sub(dividendEth);
			addLiquidity(amount.sub(swapTokensAmount), lpeth);
		}
		_buyBackBalance = address(this).balance.sub(_holdersLotteryFund).sub(_referrersLotteryFund);
	}

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "Token: Transfer from the zero address");
		require(to != address(0), "Token: Transfer to the zero address");
		require(amount > 0, "Token: Transfer amount must be greater than zero");
		require(swapEnabled || from == deployer, "Token: Public transfer has not yet been activated");
		require(_dividendContractSet, "Token: Dividend Contract Token is not set");
		
		bool takeFee = true;
		bool process = true;
		if (
			_isExcludedFromFees[from] ||
			_isExcludedFromFees[to] ||
			(_partners[from]) ||
			(_partners[to])
		) {
			takeFee = false;
			process = false;
			if (_partners[from]) {
				if (to == address(pancakeSwapWETHV2Pair) || to == address(pancakeSwapBUSDV2Pair)) takeFee = true;
			}
			if (_partners[to]) {
				if (from == address(pancakeSwapWETHV2Pair) || from == address(pancakeSwapBUSDV2Pair)) takeFee = true;
			}
		}

		if (!_swapping && _totalFee != 0 && takeFee) {
			uint256 contractTokenBalance = _balances[address(this)];
			bool canSwap = contractTokenBalance > _tokensToLiqudate;
			if (canSwap) {
				if (
					(mainLPToken == pancakeSwapV2Router.WETH() && from != address(pancakeSwapWETHV2Pair)) ||
					(mainLPToken == address(busdContract) && from != address(pancakeSwapBUSDV2Pair)))
				{
					_swapping = true;
					swapAndSendDividends(_tokensToLiqudate);
					_swapping = false;
					process = false;
				}
			}

			uint256 txFee = amount.div(100).mul(_totalFee);
			amount = amount.sub(txFee);
			_balances[from] = _balances[from].sub(txFee, "Token: Transfer amount exceeds balance");
			_balances[address(this)] = _balances[address(this)].add(txFee);
			emit Transfer(from, address(this), txFee);
		}

		_balances[from] = _balances[from].sub(amount, "Token: Transfer amount exceeds balance");
		_balances[to] = _balances[to].add(amount);
		emit Transfer(from, to, amount);

		dividendContract.setBalance(payable(from), _balances[from], false);
		dividendContract.setBalance(payable(to), _balances[to], true);

		if (!_swapping && process) {
			if (
				from == address(pancakeSwapWETHV2Pair) ||
				to == address(pancakeSwapWETHV2Pair) ||
				from == address(pancakeSwapBUSDV2Pair) ||
				to == address(pancakeSwapBUSDV2Pair)
			) {
				uint256 _iterations = 0;
				try dividendContract.process() returns (uint256 iterations, uint256 claims, uint256 lpIndex) {
					emit ProcessedDividendTracker(iterations, claims, lpIndex, true, dividendContract.gasForProcessing(), tx.origin);
					_iterations = iterations;
				} catch {}
				_totalIterations = _totalIterations.add(_iterations);
			}
		}
	}

	function setDividendTrackerContract(address _dividendTracker, uint256 amount) external onlyOwner {
		dividendContract = DividendTracker(payable(_dividendTracker));
		_dividendContractSet = true;
		_isExcludedFromFees[_dividendTracker] = true;
		_transfer(_msgSender(), _dividendTracker, amount);
	}

	function setLPManeger(address _lpManager) external onlyOwner {
		require(!_lpManagerSet, "Token: LP Maneger is already set");
		require(address(pancakeSwapV2Router) != address(0), "Token: PancakeSwapV2 Router is not set");
		require(address(pancakeSwapWETHV2Pair) != address(0), "Token: PancakeSwapV2 WETH Pair is not set");
		require(address(pancakeSwapBUSDV2Pair) != address(0), "Token: PancakeSwapV2 BUSD Pair is not set");
		lpManager = LPManager(payable(_lpManager));
		_lpManagerSet = true;
		_isExcludedFromFees[_lpManager] = true;
		dividendContract.excludeFromDividends(_lpManager);
	}

	function setBUSDContract(address _busd) external onlyOwner {
		require(!_busdContractSet, "Token: BUSD Token is already set");
		busdContract = IBEP20(_busd);
		_busdContractSet = true;
	}

	function createPancakeSwapPair(address PancakeSwapRouter) external onlyOwner {
		require(_dividendContractSet, "Token: Dividend Contract contract is not set");
		require(_busdContractSet, "Token: BUSD Token Contract contract is not set");
		pancakeSwapV2Router = IPancakeSwapV2Router02(PancakeSwapRouter);
		pancakeSwapWETHV2Pair = IPancakeSwapV2Pair(IPancakeSwapV2Factory(pancakeSwapV2Router
			.factory())
			.createPair(address(this), pancakeSwapV2Router.WETH()));
		mainLPToken = pancakeSwapV2Router.WETH();
		pancakeSwapBUSDV2Pair = IPancakeSwapV2Pair(IPancakeSwapV2Factory(pancakeSwapV2Router
			.factory())
			.createPair(address(this), address(busdContract)));
		dividendContract.excludeFromDividends(address(pancakeSwapV2Router));
		dividendContract.excludeFromDividends(address(pancakeSwapWETHV2Pair));
		dividendContract.excludeFromDividends(address(pancakeSwapBUSDV2Pair));
	}

	function enableSwap() external onlyDeployer returns (bool) {
		require(!swapEnabled, "Token: PublicSwap is already enabeled");
		require(address(pancakeSwapV2Router) != address(0), "Token: PancakeSwapV2 Router is not set");
		swapEnabled = true;
		return swapEnabled;
	}

	function swapETHForExactTokens(uint256 amountOut, address referrer) external payable returns (uint256) {
		address[] memory path = new address[](2);
		path[1] = address(this);
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			path[0] = pancakeSwapV2Router.WETH();
			pancakeSwapV2Router.swapETHForExactTokens{value: msg.value}(
				amountOut,
				path,
				_msgSender(),
				block.timestamp
			);
			uint256 ethBack = address(this).balance
				.sub(_holdersLotteryFund)
				.sub(_referrersLotteryFund)
				.sub(_buyBackBalance);
			(bool refund, ) = _msgSender().call{value: ethBack, gas: 3000}("");
			require(refund, "Token: Refund Failed");
		} else {
			uint256 initialBUSDBalance = busdContract.balanceOf(address(this));
			path[0] = address(busdContract);
			uint256 busdAmount = swapETHforBUSD(msg.value, address(this));
			busdContract.approve(address(pancakeSwapV2Router), busdAmount);
			pancakeSwapV2Router.swapTokensForExactTokens(
				amountOut,
				busdAmount,
				path,
				_msgSender(),
				block.timestamp
			);
			uint256 busdBack = busdContract.balanceOf(address(this))
				.sub(initialBUSDBalance);
			swapBUSDforETH(busdBack, _msgSender());
		}
		uint256 txFee = amountOut.div(100).mul(_totalFee);
		uint256 amount = amountOut.sub(txFee);
		if (referrer != address(0) && referrer != _msgSender() && _totalFee > 0) {
			dividendContract.payCommission(referrer, amount);
		}
		return amount;
	}

	function swapBUSDForExactTokens(uint256 busdAmount, uint256 amountOut, address referrer) external returns (uint256) {
		uint256 initialBUSDBalance = busdContract.balanceOf(address(this));
		busdContract.transferFrom(_msgSender(), address(this), busdAmount);
		address[] memory path = new address[](2);
		path[1] = address(this);
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			uint256 eth = swapBUSDforETH(busdAmount, address(this));
			path[0] = pancakeSwapV2Router.WETH();
			pancakeSwapV2Router.swapETHForExactTokens{value: eth}(
				amountOut,
				path,
				_msgSender(),
				block.timestamp
			);
			uint256 ethBack = address(this).balance
				.sub(_buyBackBalance)
				.sub(_holdersLotteryFund)
				.sub(_referrersLotteryFund);
			swapETHforBUSD(ethBack, _msgSender());
		} else {
			path[0] = address(busdContract);
			busdContract.approve(address(pancakeSwapV2Router), busdAmount);
			pancakeSwapV2Router.swapTokensForExactTokens(
				amountOut,
				busdAmount,
				path,
				_msgSender(),
				block.timestamp
			);
			uint256 busdBack = busdContract.balanceOf(address(this))
				.sub(initialBUSDBalance);
			busdContract.transfer(_msgSender(), busdBack);
		}
		uint256 txFee = amountOut.div(100).mul(_totalFee);
		uint256 amount = amountOut.sub(txFee);
		if (referrer != address(0) && referrer != _msgSender() && _totalFee > 0) {
			dividendContract.payCommission(referrer, amount);
		}
		return amount;
	}

	function swapExactETHForTokens(uint256 amountOutMin, address referrer) external payable returns (uint256) {
		uint256 initialTokenBalance = _balances[_msgSender()];
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			swapETHForTokens(_msgSender(), amountOutMin, msg.value);
		} else {
			uint256 busdAmount = swapETHforBUSD(msg.value, address(this));
			address[] memory path = new address[](2);
			path[0] = address(busdContract);
			path[1] = address(this);
			busdContract.approve(address(pancakeSwapV2Router), busdAmount);
			pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				busdAmount,
				amountOutMin,
				path,
				_msgSender(),
				block.timestamp
			);
		}
		uint256 amount = _balances[_msgSender()].sub(initialTokenBalance);
		if (referrer != address(0) && referrer != _msgSender() && _totalFee > 0) {
			dividendContract.payCommission(referrer, amount);
		}
		return amount;
	}

	function swapExactBUSDForTokens(uint256 busdAmount, uint256 amountOutMin, address referrer) external returns (uint256) {
		busdContract.transferFrom(_msgSender(), address(this), busdAmount);
		uint256 initialTokenBalance = _balances[_msgSender()];
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			uint256 eth = swapBUSDforETH(busdAmount, address(this));
			swapETHForTokens(_msgSender(), amountOutMin, eth);
		} else {
			address[] memory path = new address[](2);
			path[0] = address(busdContract);
			path[1] = address(this);
			busdContract.approve(address(pancakeSwapV2Router), busdAmount);
			pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				busdAmount,
				amountOutMin,
				path,
				_msgSender(),
				block.timestamp
			);
		}
		uint256 amount = _balances[_msgSender()].sub(initialTokenBalance);
		if (referrer != address(0) && referrer != _msgSender() && _totalFee > 0) {
			dividendContract.payCommission(referrer, amount);
		}
		return amount;
	}

	function switchPool(uint bp) external onlyDeployer returns (address) {
		require(bp <= 5 , "Token: Burn to high");
		_swapping = true;
		(address lptoken, bool updateBB) = lpManager.switchPool(bp);
		_swapping = false;
		mainLPToken = lptoken;
		if (updateBB) {
			_buyBackBalance = address(this).balance
				.sub(_holdersLotteryFund)
				.sub(_referrersLotteryFund);
		}
		emit MainLPSwitch(mainLPToken);
		return lptoken;
	}

	function addToBuyBack() external payable returns (uint256) {
		require(msg.value > 0, "Token: Transfer amount must be greater than zero");
		_buyBackBalance = _buyBackBalance.add(msg.value);
		emit BuyBackUpdate(_msgSender(), msg.value, 0);
		return _buyBackBalance;
	}

	function swapBuyBack2BNB() external onlyDeployer returns (uint256) {
		uint256 busd = busdContract.balanceOf(address(this));
		require(busd > 0, "Token: Insufficient funds.");
		uint256 eth = swapBUSDforETH(busdContract.balanceOf(address(this)), address(this));
		emit BuyBackUpdate(pancakeSwapV2Router.WETH(), eth, busd);
		_buyBackBalance = _buyBackBalance.add(eth);
		return eth;
	}

	function swapBuyBack2BUSD() external onlyDeployer returns (uint256) {
		require(_buyBackBalance > 0, "Token: Insufficient funds.");
		uint256 busd = swapETHforBUSD(_buyBackBalance, address(this));
		emit BuyBackUpdate(address(busdContract), _buyBackBalance, busd);
		_buyBackBalance = 0;
		return busd;
	}

	function payTheWinner(address winner) external returns (bool) {
		require(_msgSender() == address(dividendContract), "Token: Only the Dividend contract can call this function");
		(bool success,) = payable(winner).call{value: _holdersLotteryFund, gas: 3000}('');
		require(success, "Token: Transfer to lottery winner faild");
		_holdersLotteryFund = 0;
		return success;
	}

	function referrersLotteryFundWithdrawal(address referrerLotteryWallet) external returns (bool) {
		require(_msgSender() == address(dividendContract), "Token: Only the Dividend contract can call this function");
		(bool success,) = payable(referrerLotteryWallet).call{value: _referrersLotteryFund, gas: 3000}('');
		require(success, "Token: Transfer to Referrer Lottery Wallet faild");
		_referrersLotteryFund = 0;
		return success;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "./IPancakeSwapV2Router01.sol";
interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface IPancakeSwapV2Factory {
	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);
	function createPair(address tokenA, address tokenB) external returns (address pair);
	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface IPancakeSwapV2Pair {
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
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);
	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
	event Sync(uint112 reserve0, uint112 reserve1);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface IBEP20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	function getOwner() external view returns (address);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;
import "./Context.sol";
abstract contract Ownable is Context {
	address private _owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
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
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}
	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./abstracts/Context.sol";
import "./libraries/SafeMath.sol";
import "./AdoToken.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IPancakeSwapV2Pair.sol";
import "./interfaces/IPancakeSwapV2Router02.sol";

contract LPManager is Context {
	using SafeMath for uint256;

	address private _owner;
	uint private _lockedUntil;
	address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	AdoToken public tokenContract;
	address public mainLPToken;
	IBEP20 public busdContract;
	IPancakeSwapV2Router02 public pancakeSwapV2Router;
	IPancakeSwapV2Pair public pancakeSwapWETHV2Pair;
	IPancakeSwapV2Pair public pancakeSwapBUSDV2Pair;

	event LPLocked(uint indexed newDate);

	modifier onlyOwner() {
		require(_owner == _msgSender(), "LPManager: caller is not the owner");
		_;
	}

	modifier onlyTokenContract() {
		require(_msgSender() == address(tokenContract), "LPManager: Only the token contract can call this function");
		_;
	}

	constructor(AdoToken _tokenContract) {
		_owner = _msgSender();
		tokenContract = _tokenContract;
		_lockedUntil = block.timestamp;
	}

	receive() external payable {}

	function owner() external view returns (address) {
		return _owner;
	}

	function lpWBNB() external view returns (uint256) {
		return pancakeSwapWETHV2Pair.balanceOf(address(this));
	}

	function lpBUSD() external view returns (uint256) {
		return pancakeSwapBUSDV2Pair.balanceOf(address(this));
	}

	function totalWBNBLPs() external view returns (uint256) {
		return pancakeSwapWETHV2Pair.totalSupply();
	}

	function totalBUSDLPs() external view returns (uint256) {
		return pancakeSwapBUSDV2Pair.totalSupply();
	}

	function lockedUntil() external view returns (uint) {
		return _lockedUntil;
	}

	function updateTokenDetails() external onlyOwner {
		require(address(tokenContract.pancakeSwapV2Router()) != address(0), "LPManager: PancakeSwapV2Router is invalid");
		require(address(tokenContract.busdContract()) != address(0), "LPManager: BusdContract is invalid");
		require(address(tokenContract.pancakeSwapWETHV2Pair()) != address(0), "LPManager: PancakeSwap WETHV2Pair: is invalid");
		require(address(tokenContract.pancakeSwapBUSDV2Pair()) != address(0), "LPManager: PancakeSwap BUSDV2Pair is invalid");
		pancakeSwapV2Router = tokenContract.pancakeSwapV2Router();
		busdContract = tokenContract.busdContract();
		pancakeSwapWETHV2Pair = tokenContract.pancakeSwapWETHV2Pair();
		pancakeSwapBUSDV2Pair = tokenContract.pancakeSwapBUSDV2Pair();
		mainLPToken = tokenContract.mainLPToken();
	}

	function checkAmountsOut() public view returns (bool, uint256, uint256) {
		address[] memory path = new address[](3);
		path[0] = address(tokenContract);
		path[1] = mainLPToken;
		path[2] = mainLPToken == pancakeSwapV2Router.WETH()
			? address(busdContract)
			: pancakeSwapV2Router.WETH();
		uint256 mp = pancakeSwapV2Router.getAmountsOut(10**18, path)[1];
		path[1] = path[2];
		path[2] = mainLPToken;
		uint256 sp = pancakeSwapV2Router.getAmountsOut(10**18, path)[2];
		uint256 op = mp.div(100);
		uint256 tp = op.mul(3);
		if (sp >= mp) {
			return (false, mp.sub(tp), mp.sub(op));
		} else {
			uint256 pd = mp.sub(sp);
			return (pd > op && pd < tp, mp.sub(tp), mp.sub(op));
		}
	}

	function switchPool(uint256 bp) external onlyTokenContract returns (address, bool) {
		require(pancakeSwapWETHV2Pair.balanceOf(address(this)) > 0, "LPManager: ADO WETH LPs Balance is 0");
		require(pancakeSwapBUSDV2Pair.balanceOf(address(this)) > 0, "LPManager: ADO BUSD LPs Balance is 0");
		(bool canBeSwitched,,) = checkAmountsOut();
		require(canBeSwitched == true, "LPManager: The parity between the liquidity pools is invalid");
		bool updateBB = false;
		if (mainLPToken == pancakeSwapV2Router.WETH()) {
			uint256 liquidity = pancakeSwapWETHV2Pair.balanceOf(address(this)).div(100).mul(99);
			pancakeSwapWETHV2Pair.approve(address(pancakeSwapV2Router), liquidity);
			uint256 amountETH = pancakeSwapV2Router.removeLiquidityETHSupportingFeeOnTransferTokens(
				address(tokenContract),
				liquidity,
				0,
				0,
				address(this),
				block.timestamp
			);
			uint256 amountADO = tokenContract.balanceOf(address(this));
			if (bp > 0) {
				uint256 burn = amountADO.div(100).mul(bp);
				tokenContract.transfer(BURN_ADDRESS, burn);
				amountADO = amountADO.sub(burn);
			}
			address[] memory path = new address[](2);
			path[0] = pancakeSwapV2Router.WETH();
			path[1] = address(busdContract);
			pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountETH}(
				0,
				path,
				address(this),
				block.timestamp
			);
			uint256 amountBUSD = busdContract.balanceOf(address(this));
			busdContract.approve(address(pancakeSwapV2Router), amountBUSD);
			tokenContract.approve(address(pancakeSwapV2Router), amountADO);
			pancakeSwapV2Router.addLiquidity(
				address(tokenContract),
				address(busdContract),
				amountADO,
				amountBUSD,
				amountADO,
				0,
				address(this),
				block.timestamp
			);
			amountBUSD = busdContract.balanceOf(address(this));
			if (amountBUSD > 0) {
				busdContract.transfer(address(tokenContract), amountBUSD);
			}
			mainLPToken = address(busdContract);
		} else {
			uint256 liquidity = pancakeSwapBUSDV2Pair.balanceOf(address(this)).div(100).mul(99);
			pancakeSwapBUSDV2Pair.approve(address(pancakeSwapV2Router), liquidity);
			(uint256 amountADO, uint256 amountBUSD) = pancakeSwapV2Router.removeLiquidity(
				address(tokenContract),
				address(busdContract),
				liquidity,
				0,
				0,
				address(this),
				block.timestamp
			);
			if (bp > 0) {
				uint256 burn = amountADO.div(100).mul(bp);
				tokenContract.transfer(BURN_ADDRESS, burn);
				amountADO = amountADO.sub(burn);
			}
			address[] memory path = new address[](2);
			path[0] = address(busdContract);
			path[1] = pancakeSwapV2Router.WETH();
			busdContract.approve(address(pancakeSwapV2Router), amountBUSD);
			pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
				amountBUSD,
				0,
				path,
				address(this),
				block.timestamp
			);
			uint256 ethBalance = address(this).balance;
			tokenContract.approve(address(pancakeSwapV2Router), amountADO);
			pancakeSwapV2Router.addLiquidityETH{value: ethBalance}(
				address(tokenContract),
				amountADO,
				amountADO,
				0,
				address(this),
				block.timestamp
			);
			ethBalance = address(this).balance;
			if (ethBalance > 0) {
				(updateBB,) = payable(address(tokenContract)).call{value: ethBalance, gas: 3000}("");
			}
			mainLPToken = pancakeSwapV2Router.WETH();
		}
		return (mainLPToken, updateBB);
	}

	function extendLockedLPs(uint _days) external onlyOwner returns (bool) {
		uint unit = 1 days;
		if (_lockedUntil < block.timestamp) {
			_lockedUntil = block.timestamp + (_days * unit);
		} else {
			_lockedUntil = _lockedUntil + (_days * unit);
		}
		emit LPLocked(_lockedUntil);
		return true;
	}

	function withdrawalLPs() external onlyOwner returns (bool) {
		require(block.timestamp > _lockedUntil, "LPManager: LP tokens cannot be withdrawn");
		bool success = true;
		uint256 wethl = pancakeSwapWETHV2Pair.balanceOf(address(this));
		if (wethl > 0) {
			pancakeSwapWETHV2Pair.transfer(_owner, wethl);
		}
		uint256 busdl = pancakeSwapBUSDV2Pair.balanceOf(address(this));
		if (busdl > 0) {
			pancakeSwapBUSDV2Pair.transfer(_owner, busdl);
		}
		uint256 busd = busdContract.balanceOf(address(this));
		if (busd > 0) {
			busdContract.transfer(_owner, busd);
		}
		uint256 token = tokenContract.balanceOf(address(this));
		if (token > 0) {
			tokenContract.transfer(_owner, token);
		}
		uint256 eth = address(this).balance;
		if (eth > 0) {
			(success,) = payable(_owner).call{value: eth, gas: 3000}("");
		}
		return success;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./abstracts/Context.sol";
import "./libraries/SafeMath.sol";
import "./AdoToken.sol";
import "./DividendTracker.sol";

contract AdoVault is Context {
	using SafeMath for uint256;
	address private _owner;
	AdoToken public tokenContract;
	DividendTracker public dividendContract;
	uint256 public immutable slice;
	uint256 public pendingMilestone;

	event VaultWithdraw(address indexed to, uint256 indexed slice, uint256 indexed milestone);

	modifier onlyOwner() {
		require(_owner == _msgSender(), "Vault: caller is not the owner");
		_;
	}

	constructor(AdoToken _tokenContract, DividendTracker _dividendContract) {
		_owner = _msgSender();
		tokenContract = _tokenContract;
		dividendContract = _dividendContract;
		slice = tokenContract.totalSupply().div(20);
		pendingMilestone = dividendContract.MILESTONE4();
	}

	function owner() external view returns (address) {
		return _owner;
	}

	function unlockSlice(address to) external onlyOwner returns (uint256) {
		require(to != address(0), "Vault: transfer to the zero address");
		require(tokenContract.balanceOf(address(this)) >= slice, "Vault: insufficient funds");
		require(dividendContract.lastMilestoneReached() >= pendingMilestone, "Vault: no eligible milestone has been reached");

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE4() && pendingMilestone == dividendContract.MILESTONE4()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE5();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE4());
			return slice;
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE5() && pendingMilestone == dividendContract.MILESTONE5()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE6();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE5());
			return slice;
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE6() && pendingMilestone == dividendContract.MILESTONE6()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE7();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE6());
			return slice;
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE7() && pendingMilestone == dividendContract.MILESTONE7()) {
			tokenContract.transfer(to, tokenContract.balanceOf(address(this)));
			pendingMilestone = 0;
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE7());
			return slice;
		}
		return 0;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./abstracts/Context.sol";
import "./libraries/SafeMath.sol";
import "./libraries/SafeMathUint.sol";
import "./libraries/SafeMathInt.sol";
import "./AdoToken.sol";
import "./interfaces/IPancakeSwapV2Router02.sol";

contract DividendTracker is Context {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	IPancakeSwapV2Router02 public pancakeSwapV2Router;

	address private _owner;
	address public referrerLotteryWallet;
	address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	uint256 private constant MAGNITUDE = 2**128;
	uint256 public constant MILESTONE1 = 5000;
	uint256 public constant MILESTONE2 = 10000;
	uint256 public constant MILESTONE3 = 25000;
	uint256 public constant MILESTONE4 = 50000;
	uint256 public constant MILESTONE5 = 75000;
	uint256 public constant MILESTONE6 = 100000;
	uint256 public constant MILESTONE7 = 150000;
	struct MilestoneDetails { bool active; uint8 burn; }
	struct ReferrerDetails { uint256 transactions; uint256 bonus; uint256 totalValue; uint256 commissions; }
	struct DividendsHolders {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) active;
	}
	DividendsHolders private _tokenHoldersMap;
	address[] private _referredSwaps;
	uint256 private _totalSupply;
	uint256 private _totalDividendsDistributed;
	uint256 private _magnifiedDividendPerShare;
	uint256 private _minimumTokenBalanceForDividends;
	uint256 private _minimumDividendBalanceToProcess;
	uint256 private _minimumTokenBalanceForLottery;
	uint256 private _lastProcessedIndex;
	uint256 private _claimWait = 600;
	uint256 private _gasForProcessing = 200000;
	uint256 private _lastMilestoneReached;
	uint256 private _unqualified;
	address private _hlWinner;
	address private _rlWinner;
	mapping(address => bool) private _projects;
	mapping(address => int256) private _magnifiedDividendCorrections;
	mapping(address => uint256) private _withdrawnDividends;
	mapping(address => uint256) private _balances;
	mapping(address => bool) private _excludedFromDividends;
	mapping(address => bool) private _excludedFromLottery;
	mapping(address => uint256) private _lastClaimTimes;
	mapping(address => ReferrerDetails) private _referrers;
	mapping(uint256 => MilestoneDetails) private _milestones;
	uint256[] private _milestonesList;
	mapping(uint256 => uint256) private _bonusStructure;
	AdoToken public tokenContract;

	event NewProject(address indexed account);
	event NewMilestone(uint256 indexed milestone);
	event ExcludeFromDividends(address indexed account);
	event ExcludeFromLottery(address indexed account);
	event GasForProcessing(uint256 indexed newValue, uint256 indexed oldValue);
	event MinimumDividendBalanceToProcess(uint256 indexed newValue, uint256 indexed oldValue);
	event ClaimWait(uint256 indexed newValue, uint256 indexed oldValue);
	event Claim(address indexed account, uint256 amount, bool indexed automatic);
	event MinimumTokenBalanceForDividends(uint256 indexed newValue, uint256 indexed oldValue);
	event MinimumTokenBalanceForLottery(uint256 indexed newValue);
	event HoldersLotteryWinner(address indexed account, uint256 indexed milestone, uint256 amount, uint256 burn);
	event ReferrersLotteryWinner(address indexed account);
	event ReferrerLotteryWallet(address indexed newValue, address indexed oldValue);
	event DividendsDistributed(address indexed from, uint256 weiAmount);

	modifier onlyTokenContract() {
		require(_msgSender() == address(tokenContract), "DividendTracker: Only the token contract can call this function");
		_;
	}

	modifier onlyOwner() {
		require(_owner == _msgSender(), "DividendTracker: caller is not the owner");
		_;
	}

	constructor(AdoToken _tokenContract) {
		_owner = _msgSender();
		tokenContract = _tokenContract;
		_projects[address(tokenContract)] = true;
		referrerLotteryWallet = _msgSender();
		_minimumTokenBalanceForDividends = tokenContract.totalSupply().div(100000);
		_excludedFromDividends[address(this)] = true;
		_excludedFromDividends[address(tokenContract)] = true;
		_excludedFromDividends[BURN_ADDRESS] = true;
		_excludedFromDividends[_msgSender()] = true;
		_milestones[MILESTONE1] = MilestoneDetails({ active : true, burn: 5 });
		_milestones[MILESTONE2] = MilestoneDetails({ active : true, burn: 10 });
		_milestones[MILESTONE3] = MilestoneDetails({ active : true, burn: 15 });
		_milestones[MILESTONE4] = MilestoneDetails({ active : true, burn: 20 });
		_milestones[MILESTONE5] = MilestoneDetails({ active : true, burn: 25 });
		_milestones[MILESTONE6] = MilestoneDetails({ active : true, burn: 30 });
		_milestones[MILESTONE7] = MilestoneDetails({ active : true, burn: 35 });
		_milestonesList = [MILESTONE1, MILESTONE2, MILESTONE3, MILESTONE4, MILESTONE5, MILESTONE6, MILESTONE7];
		_bonusStructure[5] = 1;
		_bonusStructure[20] = 2;
		_bonusStructure[50] = 4;
		_bonusStructure[100] = 6;
		_bonusStructure[250] = 9;
	}

	receive() external payable {}

	function totalTokens() external view returns (uint256) {
		return _totalSupply;
	}

	function owner() external view returns (address) {
		return _owner;
	}

	function balanceOf(address account) external view returns (uint256) {
		return _balances[account];
	}

	function holdersLotteryWinner() external view returns (address) {
		return _hlWinner;
	}

	function referrersLotteryWinner() external view returns (address) {
		return _rlWinner;
	}

	function gasForProcessing() external view returns (uint256) {
		return _gasForProcessing;
	}

	function minimumDividendBalanceToProcess() external view returns (uint256) {
		return _minimumDividendBalanceToProcess;
	}

	function lastMilestoneReached() external view returns (uint256) {
		return _lastMilestoneReached;
	}

	function nextMilestone() external view returns (uint256) {
		return _milestonesList.length > 0 ? _milestonesList[0] : 0;
	}

	function maxMilestone() external view returns (uint256) {
		return _milestonesList.length > 0 ? _milestonesList[_milestonesList.length-1] : 0;
	}

	function isProject(address account) external view returns (bool) {
		return _projects[account];
	}

	function referredSwaps() external view returns (uint256 total, uint256 lotterySwaps) {
		total = _unqualified.add(_referredSwaps.length);
		lotterySwaps = _referredSwaps.length;
	}

	function isExcludedFromLottery(address account) external view returns (bool) {
		return _excludedFromLottery[account];
	}

	function isExcludedFromDividends(address account) external view returns (bool) {
		return _excludedFromDividends[account];
	}

	function totalDividendsDistributed() external view returns (uint256) {
		return _totalDividendsDistributed;
	}

	function withdrawableDividendOf(address account) public view returns(uint256) {
		return accumulativeDividendOf(account).sub(_withdrawnDividends[account]);
	}

	function minimumTokenBalanceForDividends() external view returns(uint256) {
		return _minimumTokenBalanceForDividends;
	}

	function minimumTokenBalanceForLottery() external view returns(uint256) {
		return _minimumTokenBalanceForLottery;
	}

	function claimWait() external view returns(uint256) {
		return _claimWait;
	}

	function lastProcessedIndex() external view returns(uint256) {
		return _lastProcessedIndex;
	}

	function dividendsTokenHolders() external view returns(uint256) {
		return _tokenHoldersMap.keys.length;
	}

	function accumulativeDividendOf(address _account) public view returns(uint256) {
		return _magnifiedDividendPerShare.mul(_balances[_account])
			.toInt256Safe()
			.add(_magnifiedDividendCorrections[_account])
			.toUint256Safe() / MAGNITUDE;
	}

	function getReferrer(address account) external view returns (uint256 transactions, uint256 bonus, uint256 totalValue, uint256 commissions, bool excludedFromLottery) {
		transactions = _referrers[account].transactions;
		bonus = _referrers[account].bonus;
		totalValue = _referrers[account].totalValue;
		commissions = _referrers[account].commissions;
		excludedFromLottery = _excludedFromLottery[account];
	}

	function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
		account = _account;
		index = _getIndexOfKey(account);
		iterationsUntilProcessed = -1;

		if (index >= 0) {
			if (uint256(index) > _lastProcessedIndex) {
				iterationsUntilProcessed = index.sub(int256(_lastProcessedIndex));
			} else {
				uint256 processesUntilEndOfArray = _tokenHoldersMap.keys.length > _lastProcessedIndex ? _tokenHoldersMap.keys.length.sub(_lastProcessedIndex) : 0;
				iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
			}
		}
		withdrawableDividends = withdrawableDividendOf(account);
		totalDividends = accumulativeDividendOf(account);
		lastClaimTime = _lastClaimTimes[account];
		nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(_claimWait) : 0;
		secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
	}

	function getAccountAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
		if (index >= _tokenHoldersMap.keys.length) {
			return (address(0), -1, -1, 0, 0, 0, 0, 0);
		}
		address account = _getKeyAtIndex(index);
		return getAccount(account);
	}

	function _removeMilestoneFromList() private {
		if (_milestonesList.length > 1) {
			for (uint i = 0; i < _milestonesList.length-1; i++) {
			_milestonesList[i] = _milestonesList[i+1];
			}
		}
		_milestonesList.pop();
	}

	function _withdrawDividendOfUser(address payable user) private returns (uint256) {
		uint256 _withdrawableDividend = withdrawableDividendOf(user);
		if (_withdrawableDividend > 0) {
			_withdrawnDividends[user] = _withdrawnDividends[user].add(_withdrawableDividend);
			(bool success,) = user.call{value: _withdrawableDividend, gas: 3000}('');
			if (!success) {
				_withdrawnDividends[user] = _withdrawnDividends[user].sub(_withdrawableDividend);
				return 0;
			}
			return _withdrawableDividend;
		}
		return 0;
	}

	function _setBalance(address account, uint256 newBalance) private {
		uint256 currentBalance = _balances[account];
		if (newBalance > currentBalance) {
			uint256 mintAmount = newBalance.sub(currentBalance);
			_mint(account, mintAmount);
		} else if (newBalance < currentBalance) {
			uint256 burnAmount = currentBalance.sub(newBalance);
			_burn(account, burnAmount);
		}
	}

	function _mint(address account, uint256 value) private {
		require(account != address(0), "DividendTracker: mint to the zero address");
		_totalSupply = _totalSupply.add(value);
		_balances[account] = _balances[account].add(value);
		_magnifiedDividendCorrections[account] = _magnifiedDividendCorrections[account]
			.sub((_magnifiedDividendPerShare.mul(value))
			.toInt256Safe());
	}

	function _burn(address account, uint256 value) private {
		require(account != address(0), "DividendTracker: burn from the zero address");
		_balances[account] = _balances[account].sub(value, "DividendTracker: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(value);
		_magnifiedDividendCorrections[account] = _magnifiedDividendCorrections[account]
			.add((_magnifiedDividendPerShare.mul(value))
			.toInt256Safe());
	}

	function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
		if (lastClaimTime > block.timestamp) {
			return false;
		}
		return block.timestamp.sub(lastClaimTime) >= _claimWait;
	}

	function _setHolder(address key, uint val) private {
		if (_tokenHoldersMap.active[key]) {
			_tokenHoldersMap.values[key] = val;
		} else {
			_tokenHoldersMap.active[key] = true;
			_tokenHoldersMap.values[key] = val;
			_tokenHoldersMap.indexOf[key] = _tokenHoldersMap.keys.length;
			_tokenHoldersMap.keys.push(key);
		}
	}

	function _removeHolder(address key) private {
		if (!_tokenHoldersMap.active[key]) {
			return;
		}
		delete _tokenHoldersMap.active[key];
		delete _tokenHoldersMap.values[key];
		uint index = _tokenHoldersMap.indexOf[key];
		uint lastIndex = _tokenHoldersMap.keys.length - 1;
		address lastKey = _tokenHoldersMap.keys[lastIndex];
		_tokenHoldersMap.indexOf[lastKey] = index;
		delete _tokenHoldersMap.indexOf[key];
		_tokenHoldersMap.keys[index] = lastKey;
		_tokenHoldersMap.keys.pop();
	}

	function _processAccount(address payable account, bool automatic) private returns (bool) {
		uint256 amount = _withdrawDividendOfUser(account);
		if (amount > 0) {
			_lastClaimTimes[account] = block.timestamp;
			emit Claim(account, amount, automatic);
			return true;
		}
		return false;
	}

	function _getIndexOfKey(address key) private view returns (int) {
		if(!_tokenHoldersMap.active[key]) {
			return -1;
		}
		return int(_tokenHoldersMap.indexOf[key]);
	}

	function _getKeyAtIndex(uint index) private view returns (address) {
		return _tokenHoldersMap.keys[index];
	}

	function claim() external {
		_processAccount(payable(_msgSender()), false);
	}

	function addToDividends() external payable {
		require(msg.value > 0, "DividendTracker: Transfer amount must be greater than zero");
		_updateDividendsDistributed(msg.value);
	}

	function updateDividendsDistributed(uint256 amount) external {
		require(_projects[_msgSender()] == true, "DividendTracker: Only authorized projects can call this function");
		_updateDividendsDistributed(amount);
	}

	function _updateDividendsDistributed(uint256 amount) private {
		if (_totalSupply > 0 && amount > 0) {
			_magnifiedDividendPerShare = _magnifiedDividendPerShare
				.add((amount)
				.mul(MAGNITUDE) / _totalSupply);
			emit DividendsDistributed(_msgSender(), amount);
			_totalDividendsDistributed = _totalDividendsDistributed.add(amount);
		}
	}

	function excludeFromDividends(address account) external onlyTokenContract {
		require(!_excludedFromDividends[account]);
		_excludeFromDividends(account);
	}

	function _excludeFromDividends(address account) private {
		require(!_excludedFromDividends[account]);
		_excludedFromDividends[account] = true;
		_setBalance(account, 0);
		_removeHolder(account);
		emit ExcludeFromDividends(account);
	}

	function excludeMeFromLottery() external {
		require(!_excludedFromLottery[_msgSender()]);
		_excludedFromLottery[_msgSender()] = true;
		emit ExcludeFromLottery(_msgSender());
	}

	function excludeFromLottery(address account) external onlyTokenContract {
		require(!_excludedFromLottery[account]);
		_excludedFromLottery[account] = true;
		emit ExcludeFromLottery(account);
	}

	function payCommission(address referrer, uint256 amount) external onlyTokenContract {
		if (amount >= _minimumTokenBalanceForDividends) {
			_referrers[referrer].transactions = _referrers[referrer].transactions.add(1);
			uint256 commission = 1;
			if (_bonusStructure[_referrers[referrer].transactions] > _referrers[referrer].bonus) {
				_referrers[referrer].bonus = _bonusStructure[_referrers[referrer].transactions];
			}
			_referrers[referrer].totalValue = _referrers[referrer].totalValue.add(amount);
			commission = commission.add(_referrers[referrer].bonus);
			uint256 commissionValue = amount.div(100).mul(commission);
			_referrers[referrer].commissions = _referrers[referrer].commissions.add(commissionValue);
			tokenContract.transfer(referrer, commissionValue);
			if (!_excludedFromLottery[referrer] && _referrers[referrer].transactions >= 5) {
				_referredSwaps.push(referrer);
			} else {
				_unqualified++;
			}
		}
	}

	function updateReferrerLotteryWallet(address wallet) external onlyOwner returns (bool) {
		require(wallet != address(0), "DividendTracker: ReferrerLotteryWallet cannot be the zero address");
		emit ReferrerLotteryWallet(wallet, referrerLotteryWallet);
		referrerLotteryWallet = wallet;
		return true;
	}

	function updateMinimumDividendBalanceToProcess(uint256 newValue) external onlyOwner returns (bool) {
		require(newValue <= 10 * 10 ** 18, "Token: MinimumDividendBalanceToProcess must be between 0 and 10 BNB");
		emit MinimumDividendBalanceToProcess(newValue, _minimumDividendBalanceToProcess);
		_minimumDividendBalanceToProcess = newValue;
		return true;
	}

	function updateGasForProcessing(uint256 newValue) external onlyOwner returns (bool) {
		require(newValue >= 150000 && newValue <= 500000, "DividendTracker: gasForProcessing must be between 100,000 and 500,000");
		emit GasForProcessing(newValue, _gasForProcessing);
		_gasForProcessing = newValue;
		return true;
	}

	function updateMinimumTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		require(newValue >= 10 ** 18 && newValue <= 100000 * 10 ** 18, "DividendTracker: numTokensToLiqudate must be between 1 and 100.000 ADO");
		emit MinimumTokenBalanceForDividends(_minimumTokenBalanceForDividends, newValue);
		_minimumTokenBalanceForDividends = newValue;
	}

	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
		require(newClaimWait >= 600 && newClaimWait <= 86400, "DividendTracker: claimWait must be between 1 and 24 hours");
		emit ClaimWait(newClaimWait, _claimWait);
		_claimWait = newClaimWait;
	}

	function setBalance(address payable account, uint256 newBalance, bool keep) external onlyTokenContract {
		if (_excludedFromDividends[account]) {
			return;
		}
		if (newBalance >= _minimumTokenBalanceForDividends || (_tokenHoldersMap.active[account] && keep)) {
			_setBalance(account, newBalance);
			_setHolder(account, newBalance);
		} else {
			_setBalance(account, 0);
			_removeHolder(account);
		}
		_processAccount(account, true);
	}

	function process() external onlyTokenContract returns (uint256, uint256, uint256) {
		uint256 gas = _gasForProcessing;
		uint256 numberOfTokenHolders = _tokenHoldersMap.keys.length;
		if (numberOfTokenHolders == 0) {
			return (0, 0, _lastProcessedIndex);
		}
		uint256 lpi = _lastProcessedIndex;
		uint256 gasUsed = 0;
		uint256 gasLeft = gasleft();
		uint256 iterations = 0;
		uint256 claims = 0;
		while (gasUsed < gas && iterations < numberOfTokenHolders) {
			lpi++;
			if (lpi >= _tokenHoldersMap.keys.length) {
				lpi = 0;
			}
			address account = _tokenHoldersMap.keys[lpi];
			if (_canAutoClaim(_lastClaimTimes[account])) {
				if (_processAccount(payable(account), true)) {
					claims++;
				}
			}
			iterations++;
			uint256 newGasLeft = gasleft();
			if (gasLeft > newGasLeft) {
				gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
			}
			gasLeft = newGasLeft;
		}
		_lastProcessedIndex = lpi;
		return (iterations, claims, _lastProcessedIndex);
	}

	function addNewProject(address account) external onlyOwner {
		require(!_projects[account], "DividendTracker: Smart Contract already added");
		require(account.code.length > 0, "DividendTracker: Only Smart Contracts can be added as projects");
		emit NewProject(account);
		_projects[account] = true;
	}

	function addNewMilestone(uint256 milestone) external onlyOwner {
		require(milestone > _milestonesList[_milestonesList.length-1], "DividendTracker: The new milestone cannot be smaller than the existing ones");
		_milestonesList.push(milestone);
		_milestones[milestone] = MilestoneDetails({ active : true, burn: 0 });
		emit NewMilestone(milestone);
	}

	function holdersLotteryDraw() external onlyOwner returns (address) {
		require(_milestonesList.length > 0, "DividendTracker: There are no active milestones");
		uint256 milestone = _milestonesList[0];
		require(_milestones[milestone].active, "DividendTracker: This milestone is not active");
		uint256 holders = _tokenHoldersMap.keys.length;
		require(holders >= milestone, "DividendTracker: Insufficient holders to activate this milestone");
		uint256 randomIndex = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _totalSupply, _magnifiedDividendPerShare, milestone, _msgSender()))) % holders);
		require(!_excludedFromLottery[_tokenHoldersMap.keys[randomIndex]], "DividendTracker: Excluded from lottery");
		require(tokenContract.balanceOf(_tokenHoldersMap.keys[randomIndex]) >= _minimumTokenBalanceForLottery, "DividendTracker: Insufficient tokens");
		(uint256 hlf,,,) = tokenContract.funds();
		bool success = tokenContract.payTheWinner(_tokenHoldersMap.keys[randomIndex]);
		if (success) {
			_hlWinner = _tokenHoldersMap.keys[randomIndex];
			_lastMilestoneReached = milestone;
			_removeMilestoneFromList();
			_milestones[milestone].active = false;
			uint256 toBurn = 0;
			if (_milestones[milestone].burn > 0) {
				toBurn = tokenContract.balanceOf(address(this))
					.div(100)
					.mul(_milestones[milestone].burn);
				tokenContract.transfer(BURN_ADDRESS, toBurn);
			}
			emit HoldersLotteryWinner(_hlWinner, milestone, hlf, toBurn);
		}
		return _hlWinner;
	}

	function referrersLotteryDraw() external onlyOwner returns (address) {
		uint256 referrers = _referredSwaps.length;
		uint256 randomIndex = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _totalSupply, _magnifiedDividendPerShare, _tokenHoldersMap.keys.length, address(this).balance, _msgSender()))) % referrers);
		require(!_excludedFromLottery[_referredSwaps[randomIndex]], "DividendTracker: Excluded from lottery");
		bool success = tokenContract.referrersLotteryFundWithdrawal(referrerLotteryWallet);
		if (success) {
			_rlWinner = _referredSwaps[randomIndex];
			emit ReferrersLotteryWinner(_rlWinner);
		}
		return _rlWinner;
	}

	function updateMinimumTokensForLottery() external onlyOwner returns (bool) {
		if (address(pancakeSwapV2Router) == address(0)) {
			pancakeSwapV2Router = tokenContract.pancakeSwapV2Router();
		}
		uint256 amount = 0;
		address[] memory path = new address[](2);
		if (tokenContract.mainLPToken() == pancakeSwapV2Router.WETH()) {
			path[0] = address(tokenContract.busdContract());
			path[1] = pancakeSwapV2Router.WETH();
			uint256 ethPrice = pancakeSwapV2Router.getAmountsOut(10**20, path)[1];
			path[0] = pancakeSwapV2Router.WETH();
			path[1] = address(tokenContract);
			amount = pancakeSwapV2Router.getAmountsOut(ethPrice, path)[1];
		} else {
			path[0] = address(tokenContract.busdContract());
			path[1] = address(tokenContract);
			amount = pancakeSwapV2Router.getAmountsOut(10**20, path)[1];
		}
		emit MinimumTokenBalanceForLottery(amount);
		_minimumTokenBalanceForLottery = amount;
		return true;
	}

	function burnTheHouseDown() external onlyTokenContract returns (uint256) {
		uint256 toBurn = tokenContract.balanceOf(address(this));
		tokenContract.transfer(BURN_ADDRESS, toBurn);
		return toBurn;
	}

	function addV1Comission(address referrer, uint256 amount) external onlyOwner {
		require(!tokenContract.swapEnabled(), "DividendTracker: V2 is public");
		_referrers[referrer].transactions = _referrers[referrer].transactions.add(1);
		uint256 commission = 1;
		if (_bonusStructure[_referrers[referrer].transactions] > _referrers[referrer].bonus) {
			_referrers[referrer].bonus = _bonusStructure[_referrers[referrer].transactions];
		}
		_referrers[referrer].totalValue = _referrers[referrer].totalValue.add(amount);
		commission = commission.add(_referrers[referrer].bonus);
		uint256 commissionValue = amount.div(100).mul(commission);
		_referrers[referrer].commissions = _referrers[referrer].commissions.add(commissionValue);
		if (!_excludedFromLottery[referrer] && _referrers[referrer].transactions >= 5) {
			_referredSwaps.push(referrer);
		} else {
			_unqualified++;
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * CAUTION
 * This version of SafeMath should only be used with Solidity 0.8 or later,
 * because it relies on the compiler's built in overflow checks.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			uint256 c = a + b;
			if (c < a) return (false, 0);
			return (true, c);
		}
	}
	/**
	 * @dev Returns the substraction of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b > a) return (false, 0);
			return (true, a - b);
		}
	}
	/**
	 * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) return (true, 0);
			uint256 c = a * b;
			if (c / a != b) return (false, 0);
			return (true, c);
		}
	}
	/**
	 * @dev Returns the division of two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a / b);
		}
	}
	/**
	 * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a % b);
		}
	}
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
		return a + b;
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
		return a - b;
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
		return a * b;
	}
	/**
	 * @dev Returns the integer division of two unsigned integers, reverting on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator.
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}
	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting when dividing by zero.
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
		return a % b;
	}
	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {trySub}.
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		unchecked {
			require(b <= a, errorMessage);
			return a - b;
		}
	}
	/**
	 * @dev Returns the integer division of two unsigned integers, reverting with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
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
		unchecked {
			require(b > 0, errorMessage);
			return a / b;
		}
	}
	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting with custom message when dividing by zero.
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {tryMod}.
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
		unchecked {
			require(b > 0, errorMessage);
			return a % b;
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
interface IPancakeSwapV2Router01 {
	function factory() external view returns (address);
	function WETH() external view returns (address);
	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
	function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
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