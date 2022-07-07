/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT

/**
 * @author Brewlabs
 * This token contract has been developed by Brewlabs.info
 */

pragma solidity 0.8.13;

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount)
	external
	returns (bool);

	function allowance(address owner, address spender)
	external
	view
	returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

interface IFactory {
	function createPair(address tokenA, address tokenB)
	external
	returns (address pair);

	function getPair(address tokenA, address tokenB)
	external
	view
	returns (address pair);
}

interface IRouter {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
	external
	payable
	returns (
		uint256 amountToken,
		uint256 amountETH,
		uint256 liquidity
	);

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

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

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Context, IERC20, IERC20Metadata {
	using SafeMath for uint256;

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	string private _name;
	string private _symbol;

	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return 18;
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

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public virtual override returns (bool) {
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

	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal virtual {
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

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");
		_beforeTokenTransfer(account, address(0), amount);
		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(
		address owner,
		address spender,
		uint256 amount
	) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {}
}

contract BlocVestToken is ERC20, Ownable {
	IRouter public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private constant _name = "BlocVest Token";
	string private constant _symbol = "BVST";
	uint8 private constant _decimals = 18;

	bool public isTradingEnabled;
	uint256 private _tradingPausedTimestamp;

    address public BLVT = 0xb3ac46fE1A14589F5fB4EA735DA723cD12a3438A;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

	// initialSupply
	uint256 constant initialSupply = 10000000 * (10**18);

	// max wallet is 1.5% of initialSupply
	uint256 public maxWalletAmount = initialSupply * 150 / 10000;
	// max buy and sell tx is 0.5% of initialSupply
	uint256 public maxTxAmount = initialSupply * 50 / 10000;

	bool private _swapping;
	// threshold is 0.05% tokens
	uint256 public minimumTokensBeforeSwap = initialSupply * 500 / 1000000;

    address public liquidityWallet;
	address public devWallet;
	address public buyBackWallet;
    address public shareholderWallet;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint8 liquidityFeeOnBuy;
		uint8 liquidityFeeOnSell;
		uint8 devFeeOnBuy;
		uint8 devFeeOnSell;
        uint8 buyBackFeeOnBuy;
		uint8 buyBackFeeOnSell;
		uint8 shareholderFeeOnBuy;
		uint8 shareholderFeeOnSell;
	}

	// Launch taxes
	bool private _isLaunched;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',3,0,100,2,0,1,0,2,0,5);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,2,3,1,10,2,7,5,10);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,172800,2,5,1,5,2,5,5,10);

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,2,2,1,1,2,2,5,5);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,2,2,1,1,2,2,5,5);

	uint256 private _blockedTimeLimit = 172800;
    bool private _feeOnWalletTranfers;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _feeOnSelectedWalletTransfers;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => uint256) private _buyTimesInLaunch;

	uint8 private _liquidityFee;
	uint8 private _devFee;
	uint8 private _buyBackFee;
	uint8 private _shareholderFee;
	uint8 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed walletIdentifier, address indexed newWallet, address indexed oldWallet);
	event FeeChange(string indexed identifier, uint8 liquidityFee, uint8 devFee, uint8 buyBackFee, uint8 shareholderFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
    event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
    event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
    event FeeOnWalletTransferChange(bool indexed newValue, bool indexed oldValue);
	event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
    event ClaimBNBOverflow(uint256 amount);
	event FeesApplied(uint8 liquidityFee, uint8 devFee, uint8 buyBackFee, uint8 shareholderFee, uint8 totalFee);

	constructor() ERC20(_name, _symbol) {
        liquidityWallet = owner();
        devWallet = owner();
	    buyBackWallet = owner();
        shareholderWallet = owner();

		IRouter _uniswapV2Router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
		address _uniswapV2Pair = IFactory(_uniswapV2Router.factory()).createPair(
			address(this),
			_uniswapV2Router.WETH()
		);
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);

		_isExcludedFromFee[owner()] = true;
		_isExcludedFromFee[address(this)] = true;

         _isAllowedToTradeWhenDisabled[owner()] = true;

		_isExcludedFromMaxTransactionLimit[address(this)] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;

		_mint(owner(), initialSupply);
	}

	receive() external payable {}

	// Setters
	function launch() external onlyOwner {
		_launchStartTimestamp = block.timestamp;
		_launchBlockNumber = block.number;
		isTradingEnabled = true;
		_isLaunched = true;
	}
	function cancelLaunch() external onlyOwner {
		require(this.isInLaunch(), "BlocVest: Launch is not set");
		_launchStartTimestamp = 0;
		_launchBlockNumber = 0;
		_isLaunched = false;
	}
	function activateTrading() external onlyOwner {
		isTradingEnabled = true;
	}
	function deactivateTrading() external onlyOwner {
		isTradingEnabled = false;
		_tradingPausedTimestamp = block.timestamp;
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "BlocVest: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
		emit AutomatedMarketMakerPairChange(pair, value);
	}
    function allowTradingWhenDisabled(address account, bool allowed) external onlyOwner {
		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}
	function excludeFromFees(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromFee[account] != excluded, "BlocVest: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "BlocVest: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "BlocVest: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
	function blockAccount(address account) external onlyOwner {
		require(!_isBlocked[account], "BlocVest: Account is already blocked");
		if (_isLaunched) {
			require((block.timestamp - _launchStartTimestamp) < _blockedTimeLimit, "BlocVest: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) external onlyOwner {
		require(_isBlocked[account], "BlocVest: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setWallets(address newLiquidityWallet, address newDevWallet, address newBuyBackWallet, address newShareholderWallet) external onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "BlocVest: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(devWallet != newDevWallet) {
			require(newDevWallet != address(0), "BlocVest: The devWallet cannot be 0");
			emit WalletChange('devWallet', newDevWallet, devWallet);
			devWallet = newDevWallet;
		}
		if(buyBackWallet != newBuyBackWallet) {
			require(newBuyBackWallet != address(0), "BlocVest: The buyBackWallet cannot be 0");
			emit WalletChange('buyBackWallet', newBuyBackWallet, buyBackWallet);
			buyBackWallet = newBuyBackWallet;
		}
        if(shareholderWallet != newShareholderWallet) {
			require(newShareholderWallet != address(0), "BlocVest: The shareholderWallet cannot be 0");
			emit WalletChange('shareholderWallet', newShareholderWallet, shareholderWallet);
			shareholderWallet = newShareholderWallet;
		}
	}
    function setBLVTAddress(address newBLVTAddress) external onlyOwner {
		require(newBLVTAddress != BLVT, "BlocVest: The BLVT address is already the value of newBLVTAddress");
		BLVT = newBLVTAddress;
	}
    function setBUSDAddress(address newBUSDAddress) external onlyOwner {
		require(newBUSDAddress != BUSD, "BlocVest: The BUSD address is already the value of newBUSDAddress");
		BUSD = newBUSDAddress;
	}
    function setFeeOnWalletTransfers(bool value) external onlyOwner {
		emit FeeOnWalletTransferChange(value, _feeOnWalletTranfers);
		_feeOnWalletTranfers = value;
	}
	function setFeeOnSelectedWalletTransfers(address account, bool value) external onlyOwner {
		require(_feeOnSelectedWalletTransfers[account] != value, "BlocVest: The selected wallet is already set to the value ");
		_feeOnSelectedWalletTransfers[account] = value;
		emit FeeOnSelectedWalletTransfersChange(account, value);
	}
	function setAllFeesToZero() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0);
	}
	function resetAllFees() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.shareholderFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.shareholderFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.shareholderFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.shareholderFeeOnSell);
	}
	// Base Fees
	function setBaseFeesOnBuy(uint8 _liquidityFeeOnBuy, uint8 _devFeeOnBuy, uint8 _buyBackFeeOnBuy, uint8 _shareholderFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _shareholderFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _shareholderFeeOnBuy);
	}
	function setBaseFeesOnSell(uint8 _liquidityFeeOnSell,uint8 _devFeeOnSell, uint8 _buyBackFeeOnSell, uint8 _shareholderFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _shareholderFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _shareholderFeeOnSell);
	}
	function setUniswapRouter(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "BlocVest: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IRouter(newAddress);
	}
	function setMaxTransactionAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxTxAmount, "BlocVest: Cannot update maxTxAmount to same value");
		emit MaxTransactionAmountChange(newValue, maxTxAmount);
		maxTxAmount = newValue;
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxWalletAmount, "BlocVest: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "BlocVest: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function claimBNBOverflow() external onlyOwner {
	    uint256 amount = address(this).balance;
        (bool success,) = address(owner()).call{value : amount}("");
        if (success){
            emit ClaimBNBOverflow(amount);
        }
	}

	// Getters
	function isInLaunch() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : block.timestamp;
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 totalLaunchTime =  _launch1.timeInPeriod + _launch2.timeInPeriod + _launch3.timeInPeriod;

		if(_isLaunched && (timeSinceLaunch < totalLaunchTime || blocksSinceLaunch < _launch1.blocksInPeriod )) {
			return true;
		} else {
			return false;
		}
	}
	function getBaseBuyFees() external view returns (uint8, uint8, uint8, uint8){
		return (_base.liquidityFeeOnBuy, _base.devFeeOnBuy, _base.buyBackFeeOnBuy, _base.shareholderFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint8, uint8, uint8, uint8){
		return (_base.liquidityFeeOnSell, _base.devFeeOnSell, _base.buyBackFeeOnSell, _base.shareholderFeeOnSell);
	}

	// Main
	function _transfer(
		address from,
		address to,
		uint256 amount
		) internal override {
			require(from != address(0), "ERC20: transfer from the zero address");
			require(to != address(0), "ERC20: transfer to the zero address");

			if(amount == 0) {
				super._transfer(from, to, 0);
				return;
			}

			bool isBuyFromLp = automatedMarketMakerPairs[from];
			bool isSelltoLp = automatedMarketMakerPairs[to];
			bool _isInLaunch = this.isInLaunch();
			uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : block.timestamp;

		    if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
				require(isTradingEnabled, "BlocVest: Trading is currently disabled.");
				require(!_isBlocked[to], "BlocVest: Account is blocked");
				require(!_isBlocked[from], "BlocVest: Account is blocked");
				if (_isInLaunch && (currentTimestamp - _launchStartTimestamp) <= 300 && isBuyFromLp) {
					require((currentTimestamp - _buyTimesInLaunch[to]) > 60, "BlocVest: Cannot buy more than once per min in first 5min of launch");
				}
				if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
					require(amount <= maxTxAmount, "BlocVest: Buy amount exceeds the maxTxBuyAmount.");
				}
				if (!_isExcludedFromMaxWalletLimit[to]) {
					require((balanceOf(to) + amount) <= maxWalletAmount, "BlocVest: Expected wallet amount exceeds the maxWalletAmount.");
				}
			}

			_adjustTaxes(isBuyFromLp, isSelltoLp, _isInLaunch, to, from);
			bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

			if (
				isTradingEnabled &&
				canSwap &&
				!_swapping &&
				_totalFee > 0 &&
				automatedMarketMakerPairs[to]

			) {
				_swapping = true;
				_swapAndLiquify();
				_swapping = false;
			}

			bool takeFee = !_swapping && isTradingEnabled;

			if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
				takeFee = false;
			}
			if (takeFee) {
				uint256 fee = amount * _totalFee / 100;
				amount = amount - fee;
				super._transfer(from, address(this), fee);
			}

			if (_isInLaunch && (currentTimestamp - _launchStartTimestamp) <= 300) {
				if (to != owner() && isBuyFromLp  && (currentTimestamp - _buyTimesInLaunch[to]) > 60) {
					_buyTimesInLaunch[to] = currentTimestamp;
				}
			}

			super._transfer(from, to, amount);
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, bool isLaunching, address to, address from) private {
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : block.timestamp;
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		_liquidityFee = 0;
		_devFee = 0;
        _buyBackFee = 0;
		_shareholderFee = 0;

		if (isBuyFromLp) {
		    _liquidityFee = _base.liquidityFeeOnBuy;
			_devFee = _base.devFeeOnBuy;
			_buyBackFee = _base.buyBackFeeOnBuy;
			_shareholderFee = _base.shareholderFeeOnBuy;

			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnBuy;
					_devFee = _launch1.devFeeOnBuy;
                    _buyBackFee = _launch1.buyBackFeeOnBuy;
					_shareholderFee = _launch1.shareholderFeeOnBuy;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnBuy;
					_devFee = _launch2.devFeeOnBuy;
                    _buyBackFee = _launch2.buyBackFeeOnBuy;
					_shareholderFee = _launch2.shareholderFeeOnBuy;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnBuy;
					_devFee = _launch3.devFeeOnBuy;
                    _buyBackFee = _launch3.buyBackFeeOnBuy;
					_shareholderFee = _launch3.shareholderFeeOnBuy;
				}
			}
		}
	    if (isSelltoLp) {
	    	_liquidityFee = _base.liquidityFeeOnSell;
			_devFee = _base.devFeeOnSell;
            _buyBackFee = _base.buyBackFeeOnSell;
			_shareholderFee = _base.shareholderFeeOnSell;

			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnSell;
					_devFee = _launch1.devFeeOnSell;
                    _buyBackFee = _launch1.buyBackFeeOnSell;
					_shareholderFee = _launch1.shareholderFeeOnSell;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnSell;
					_devFee = _launch2.devFeeOnSell;
                    _buyBackFee = _launch2.buyBackFeeOnSell;
					_shareholderFee = _launch2.shareholderFeeOnSell;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnSell;
					_devFee = _launch3.devFeeOnSell;
                    _buyBackFee = _launch3.buyBackFeeOnSell;
					_shareholderFee = _launch3.shareholderFeeOnSell;
				}
			}
		}
		if (!isSelltoLp && !isBuyFromLp && (_feeOnSelectedWalletTransfers[from] || _feeOnSelectedWalletTransfers[to])) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_devFee = _base.devFeeOnSell;
            _buyBackFee = _base.buyBackFeeOnSell;
			_shareholderFee = _base.shareholderFeeOnSell;

		}
		else if (!isSelltoLp && !isBuyFromLp && !_feeOnSelectedWalletTransfers[from] && !_feeOnSelectedWalletTransfers[to] && _feeOnWalletTranfers) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_devFee = _base.devFeeOnBuy;
            _buyBackFee = _base.buyBackFeeOnBuy;
			_shareholderFee = _base.shareholderFeeOnBuy;
		}
		_totalFee = _liquidityFee + _devFee + _buyBackFee + _shareholderFee;
		emit FeesApplied(_liquidityFee, _devFee, _buyBackFee, _shareholderFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint8 _liquidityFeeOnSell,
		uint8 _devFeeOnSell,
        uint8 _buyBackFeeOnSell,
		uint8 _shareholderFeeOnSell
	) private {
		if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
			emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
			map.liquidityFeeOnSell = _liquidityFeeOnSell;
		}
		if (map.devFeeOnSell != _devFeeOnSell) {
			emit CustomTaxPeriodChange(_devFeeOnSell, map.devFeeOnSell, 'devFeeOnSell', map.periodName);
			map.devFeeOnSell = _devFeeOnSell;
		}
        if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
			emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
			map.buyBackFeeOnSell = _buyBackFeeOnSell;
		}
		if (map.shareholderFeeOnSell != _shareholderFeeOnSell) {
			emit CustomTaxPeriodChange(_shareholderFeeOnSell, map.shareholderFeeOnSell, 'shareholderFeeOnSell', map.periodName);
			map.shareholderFeeOnSell = _shareholderFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint8 _liquidityFeeOnBuy,
		uint8 _devFeeOnBuy,
        uint8 _buyBackFeeOnBuy,
		uint8 _shareholderFeeOnBuy
		) private {
		if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
			emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
			map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
		}
		if (map.devFeeOnBuy != _devFeeOnBuy) {
			emit CustomTaxPeriodChange(_devFeeOnBuy, map.devFeeOnBuy, 'devFeeOnBuy', map.periodName);
			map.devFeeOnBuy = _devFeeOnBuy;
		}
		if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
			emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
			map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
		}
		if (map.shareholderFeeOnBuy != _shareholderFeeOnBuy) {
			emit CustomTaxPeriodChange(_shareholderFeeOnBuy, map.shareholderFeeOnBuy, 'shareholderFeeOnBuy', map.periodName);
			map.shareholderFeeOnBuy = _shareholderFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialBNBBalance = address(this).balance;

		uint8 totalFeePrior = _totalFee;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
		uint256 amountToSwap = contractBalance - amountToLiquify;

		_swapTokensForBNB(amountToSwap);

		uint256 BNBBalanceAfterSwap = address(this).balance - initialBNBBalance;
		uint256 totalBNBFee = _totalFee - (_liquidityFee / 2);

		uint256 amountBNBLiquidity = BNBBalanceAfterSwap * _liquidityFee / totalBNBFee / 2;
		uint256 amountBNBDev = BNBBalanceAfterSwap * _devFee / totalBNBFee;
        uint256 amountBNBBuyBack = BNBBalanceAfterSwap * _buyBackFee / totalBNBFee;
        uint256 amountBNBShareholder = BNBBalanceAfterSwap - (amountBNBLiquidity + amountBNBDev + amountBNBBuyBack);

		payable(devWallet).transfer(amountBNBDev);

        _swapBNBForCustomToken(amountBNBBuyBack, BLVT, buyBackWallet);
        _swapBNBForCustomToken(amountBNBShareholder, BUSD, shareholderWallet);

        if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountBNBLiquidity);
			emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
        }
		_totalFee = totalFeePrior;
	}
    function _swapBNBForCustomToken(uint256 bnbAmount, address token, address wallet) private {
        address[] memory path = new address[](2);
		path[0] = uniswapV2Router.WETH();
		path[1] = token;

		uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : bnbAmount}(
		0, // accept any amount of ETH
		path,
		address(wallet),
		block.timestamp
		);
    }
	function _swapTokensForBNB(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(this),
			block.timestamp
		);
	}
	function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.addLiquidityETH{value: ethAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			liquidityWallet,
			block.timestamp
		);
	}
}