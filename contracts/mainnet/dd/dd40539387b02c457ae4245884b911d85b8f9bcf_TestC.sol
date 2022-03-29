/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT

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

interface DividendPayingTokenInterface {
	function dividendOf(address _owner) external view returns(uint256);
	function withdrawDividend() external;
	event DividendsDistributed(
		address indexed from,
		uint256 weiAmount
	);
	event DividendWithdrawn(
		address indexed to,
		uint256 weiAmount
	);
}

interface DividendPayingTokenOptionalInterface {
	function withdrawableDividendOf(address _owner) external view returns(uint256);
	function withdrawnDividendOf(address _owner) external view returns(uint256);
	function accumulativeDividendOf(address _owner) external view returns(uint256);
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

library SafeMathInt {
	int256 private constant MIN_INT256 = int256(1) << 255;
	int256 private constant MAX_INT256 = ~(int256(1) << 255);

	function mul(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a * b;

		// Detect overflow when multiplying MIN_INT256 with -1
		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}
	function div(int256 a, int256 b) internal pure returns (int256) {
		// Prevent overflow when dividing MIN_INT256 by -1
		require(b != -1 || a != MIN_INT256);

		// Solidity already throws when dividing by 0.
		return a / b;
	}
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));
		return c;
	}
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));
		return c;
	}
	function abs(int256 a) internal pure returns (int256) {
		require(a != MIN_INT256);
		return a < 0 ? -a : a;
	}
	function toUint256Safe(int256 a) internal pure returns (uint256) {
		require(a >= 0);
		return uint256(a);
	}
}

library SafeMathUint {
	function toInt256Safe(uint256 a) internal pure returns (int256) {
		int256 b = int256(a);
		require(b >= 0);
		return b;
	}
}

library IterableMapping {
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

	constructor () public {
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

	constructor(string memory name_, string memory symbol_) public {
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

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;
	
	uint256 constant internal magnitude = 2**128;
	uint256 internal magnifiedDividendPerShare;
	uint256 public totalDividendsDistributed;
    address public rewardToken;

	mapping(address => int256) internal magnifiedDividendCorrections;
	mapping(address => uint256) internal withdrawnDividends;

	constructor(string memory _name, string memory _symbol) public ERC20(_name, _symbol) {}

	receive() external payable {}

	function distributeDividendsUsingAmount(uint256 amount) public onlyOwner {
		require(totalSupply() > 0);
		if (amount > 0) {
			magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
			emit DividendsDistributed(msg.sender, amount);
			totalDividendsDistributed = totalDividendsDistributed.add(amount);
		}
	}
	function withdrawDividend() public virtual override {
		_withdrawDividendOfUser(payable(msg.sender));
	}
	function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
		uint256 _withdrawableDividend = withdrawableDividendOf(user);
		if (_withdrawableDividend > 0) {
			withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
			emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success) = IERC20(rewardToken).transfer(user, _withdrawableDividend);
            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
		}
		return 0;
	}
	function dividendOf(address _owner) public view override returns(uint256) {
		return withdrawableDividendOf(_owner);
	}
	function withdrawableDividendOf(address _owner) public view override returns(uint256) {
		return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
	}
	function withdrawnDividendOf(address _owner) public view override returns(uint256) {
		return withdrawnDividends[_owner];
	}
	function accumulativeDividendOf(address _owner) public view override returns(uint256) {
		return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
		.add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
	}
	function _transfer(address from, address to, uint256 value) internal virtual override {
		require(false);
		int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
		magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
		magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
	}
	function _mint(address account, uint256 value) internal override {
		super._mint(account, value);
		magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
		.sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
	}
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
    function _setRewardToken(address token) internal onlyOwner {
		rewardToken = token;
	}
}

contract TestC is ERC20, Ownable {
	IRouter public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private _name = "TestC"; //"CryptoComedyClub"; 
	string private _symbol = "TestC"; //"LOL";
	uint8 private _decimals = 18;

	CryptoComedyClubDividendTracker public dividendTracker;
	
	bool public isTradingEnabled;
	uint256 private _tradingPausedTimestamp;

	// initialSupply
	uint256 constant initialSupply = 1000000000000 * (10**18);

	// max wallet is 5% of initialSupply
	uint256 public maxWalletAmount = initialSupply * 500 / 10000;
	// max buy and sell tx is 5% of initialSupply
	uint256 public maxTxAmount = initialSupply * 500 / 10000;

	bool private _swapping;
	uint256 public minimumTokensBeforeSwap = 25000000 * (10**18);
	uint256 public gasForProcessing = 300000;
	
    address public liquidityWallet;
	address public marketingWallet;
	address public talentWallet;
	address public dev1Wallet;
	address public dev2Wallet;
    address public dev3Wallet;
    address public dev4Wallet;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint256 liquidityFeeOnBuy;
		uint256 liquidityFeeOnSell;
		uint256 marketingFeeOnBuy;
		uint256 marketingFeeOnSell;
        uint256 talentFeeOnBuy;
		uint256 talentFeeOnSell;
        uint256 dev1FeeOnBuy;
		uint256 dev1FeeOnSell;
		uint256 dev2FeeOnBuy;
		uint256 dev2FeeOnSell;
		uint256 dev3FeeOnBuy;
		uint256 dev3FeeOnSell;
        uint256 dev4FeeOnBuy;
		uint256 dev4FeeOnSell;
		uint256 holdersFeeOnBuy;
		uint256 holdersFeeOnSell;
	}

	// Launch taxes
	bool private _isLaunched;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',3,0,10000,200,0,200,0,200,0,75,0,75,0,75,0,75,0,100);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,200,500,200,1100,200,500,75,100,75,100,75,100,75,100,100,500);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,82800,200,300,200,800,200,600,75,100,75,100,75,100,75,100,100,400);

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,200,200,200,200,200,200,75,75,75,75,75,75,75,75,100,100);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,200,200,200,200,200,200,75,75,75,75,75,75,75,75,100,100);

	// ROFL Hour taxes
	uint256 private _roflHourStartTimestamp;
	CustomTaxPeriod private _rofl1 = CustomTaxPeriod('rofl1',0,3600,0,500,0,1100,0,500,0,100,0,100,0,100,0,100,300,500);
	CustomTaxPeriod private _rofl2 = CustomTaxPeriod('rofl2',0,3600,200,300,200,800,200,600,75,100,75,100,75,100,75,100,100,400);

	uint256 private _blockedTimeLimit = 86400;
    bool private _feeOnWalletTranfers;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _feeOnSelectedWalletTransfers;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => uint256) private _buyTimesInLaunch;

	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _talentFee;
	uint256 private _dev1Fee;
    uint256 private _dev2Fee;
    uint256 private _dev3Fee;
    uint256 private _dev4Fee;
	uint256 private _holdersFee;
	uint256 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed walletIdentifier, address indexed newWallet, address indexed oldWallet);
	event GasForProcessingChange(uint256 indexed newValue, uint256 indexed oldValue);
	event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 talentFee, uint256 dev1Fee, uint256 dev2Fee, uint256 dev3Fee, uint256 dev4Fee, uint256 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
	event RoflHourChange(bool indexed newValue, bool indexed oldValue);
    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
    event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
    event MinTokenAmountForDividendsChange(uint256 indexed newValue, uint256 indexed oldValue);
    event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
	event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
    event FeeOnWalletTransferChange(bool indexed newValue, bool indexed oldValue);
	event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);
	event DividendsSent(uint256 tokensSwapped);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
    event ClaimBNBOverflow(uint256 amount);
	event ProcessedDividendTracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed automatic,
		uint256 gas,
		address indexed processor
	);
	event FeesApplied(uint256 liquidityFee, uint256 marketingFee, uint256 talentFee, uint256 dev1Fee, uint256 dev2Fee, uint256 dev3Fee, uint256 dev4Fee, uint256 holdersFee, uint256 totalFee);
    event ValueCheck(uint256 initialBNBBalance, uint256 amountToLiquify, uint256 amountForHolders, uint256 amountToSwap, uint256 BNBBalanceAfterSwap, uint256 totalBNBFee);
    event BNBAmounts(uint256 amountBNBLiquidity, uint256 amountBNBMarketing, uint256 amountBNBDev1, uint256 amountBNBDev2, uint256 amountBNBDev3, uint256 amountBNBDev4, uint256 amountBNBTalent);
    event TakeFee(uint256 totalFee, uint256 fee, uint256 amount, uint256 originalAmount);

	constructor() public ERC20(_name, _symbol) {
        liquidityWallet = owner();
        marketingWallet = owner();
	    talentWallet = owner();
	    dev1Wallet = owner();
	    dev2Wallet = owner();
        dev3Wallet = owner();
        dev4Wallet = owner();

		dividendTracker = new CryptoComedyClubDividendTracker();
        dividendTracker.setRewardToken(address(this));

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
		_isExcludedFromFee[address(dividendTracker)] = true;

		dividendTracker.excludeFromDividends(address(dividendTracker));
		dividendTracker.excludeFromDividends(address(this));
		dividendTracker.excludeFromDividends(address(0x000000000000000000000000000000000000dEaD));
		dividendTracker.excludeFromDividends(owner());
		dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        _isAllowedToTradeWhenDisabled[owner()] = true;

		_isExcludedFromMaxTransactionLimit[address(dividendTracker)] = true;
		_isExcludedFromMaxTransactionLimit[address(this)] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(dividendTracker)] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;

		_mint(owner(), initialSupply);
	}

	receive() external payable {}

	// Setters
	function _getNow() private view returns (uint256) {
		return block.timestamp;
	}
	function launch() external onlyOwner {
		_launchStartTimestamp = _getNow();
		_launchBlockNumber = block.number;
		isTradingEnabled = true;
		_isLaunched = true;
	}
	function cancelLaunch() external onlyOwner {
		require(this.isInLaunch(), "CryptoComedyClub: Launch is not set");
		_launchStartTimestamp = 0;
		_launchBlockNumber = 0;
		_isLaunched = false;
	}
	function activateTrading() external onlyOwner {
		isTradingEnabled = true;
	}
	function deactivateTrading() external onlyOwner {
		isTradingEnabled = false;
		_tradingPausedTimestamp = _getNow();
	}
	function setRoflHour() external onlyOwner {
		require(!this.isInRoflHour(), "CryptoComedyClub: Rofl Hour is already set");
		require(isTradingEnabled, "CryptoComedyClub: Trading must be enabled first");
		require(!this.isInLaunch(), "CryptoComedyClub: Must not be in launch period");
		emit RoflHourChange(true, false);
		_roflHourStartTimestamp = _getNow();
	}
	function cancelRoflHour() external onlyOwner {
		require(this.isInRoflHour(), "CryptoComedyClub: Rofl Hour is not set");
		emit RoflHourChange(false, true);
		_roflHourStartTimestamp = 0;
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "CryptoComedyClub: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
		if(value) {
			dividendTracker.excludeFromDividends(pair);
		}
		emit AutomatedMarketMakerPairChange(pair, value);
	}
    function allowTradingWhenDisabled(address account, bool allowed) external onlyOwner {
		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}
	function excludeFromFees(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromFee[account] != excluded, "CryptoComedyClub: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromDividends(address account) external onlyOwner {
		dividendTracker.excludeFromDividends(account);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "CryptoComedyClub: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "CryptoComedyClub: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
	function blockAccount(address account) external onlyOwner {
		uint256 currentTimestamp = _getNow();
		require(!_isBlocked[account], "CryptoComedyClub: Account is already blocked");
		if (_isLaunched) {
			require((currentTimestamp - _launchStartTimestamp) < _blockedTimeLimit, "CryptoComedyClub: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) external onlyOwner {
		require(_isBlocked[account], "CryptoComedyClub: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setWallets(address newLiquidityWallet, address newMarketingWallet, address newTalentWallet, address newDev1Wallet, address newDev2Wallet, address newDev3Wallet, address newDev4Wallet) external onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "CryptoComedyClub: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "CryptoComedyClub: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
        if(talentWallet != newTalentWallet) {
			require(newTalentWallet != address(0), "CryptoComedyClub: The talentWallet cannot be 0");
			emit WalletChange('talentWallet', newTalentWallet, talentWallet);
			talentWallet = newTalentWallet;
		}
		if(dev1Wallet != newDev1Wallet) {
			require(newDev1Wallet != address(0), "CryptoComedyClub: The dev1Wallet cannot be 0");
			emit WalletChange('dev1Wallet', newDev1Wallet, dev1Wallet);
			dev1Wallet = newDev1Wallet;
		}
        if(dev2Wallet != newDev2Wallet) {
			require(newDev2Wallet != address(0), "CryptoComedyClub: The dev2Wallet cannot be 0");
			emit WalletChange('dev2Wallet', newDev2Wallet, dev2Wallet);
			dev2Wallet = newDev2Wallet;
		}
        if(dev3Wallet != newDev3Wallet) {
			require(newDev3Wallet != address(0), "CryptoComedyClub: The dev3Wallet cannot be 0");
			emit WalletChange('dev3Wallet', newDev3Wallet, dev3Wallet);
			dev3Wallet = newDev3Wallet;
		}
        if(dev4Wallet != newDev4Wallet) {
			require(newDev4Wallet != address(0), "CryptoComedyClub: The dev4Wallet cannot be 0");
			emit WalletChange('dev4Wallet', newDev4Wallet, dev4Wallet);
			dev4Wallet = newDev4Wallet;
		}
	}
    function setFeeOnWalletTransfers(bool value) external onlyOwner {
		emit FeeOnWalletTransferChange(value, _feeOnWalletTranfers);
		_feeOnWalletTranfers = value;
	}
	function setFeeOnSelectedWalletTransfers(address account, bool value) external onlyOwner {
		require(_feeOnSelectedWalletTransfers[account] != value, "CryptoComedyClub: The selected wallet is already set to the value ");
		_feeOnSelectedWalletTransfers[account] = value;
		emit FeeOnSelectedWalletTransfersChange(account, value);
	}
	function setAllFeesToZero() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0, 0, 0, 0);
	}
	function resetAllFees() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.talentFeeOnBuy,  _default.dev1FeeOnBuy, _default.dev2FeeOnBuy, _default.dev3FeeOnBuy, _default.dev4FeeOnBuy, _default.holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.talentFeeOnBuy,  _default.dev1FeeOnBuy, _default.dev2FeeOnBuy, _default.dev3FeeOnBuy, _default.dev4FeeOnBuy, _default.holdersFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.talentFeeOnSell, _default.dev1FeeOnSell, _default.dev2FeeOnSell, _default.dev3FeeOnSell, _default.dev4FeeOnSell, _default.holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.talentFeeOnSell, _default.dev1FeeOnSell, _default.dev2FeeOnSell, _default.dev3FeeOnSell, _default.dev4FeeOnSell, _default.holdersFeeOnSell);
	}
	// Base Fees
	function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _talentFeeOnBuy, uint256 _dev1FeeOnBuy, uint256 _dev2FeeOnBuy, uint256 _dev3FeeOnBuy, uint256 _dev4FeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _talentFeeOnSell, uint256 _dev1FeeOnSell, uint256 _dev2FeeOnSell, uint256 _dev3FeeOnSell, uint256 _dev4FeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
	}
	// Rofl1 Hour Fees
	function setRoflHour1BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _talentFeeOnBuy, uint256 _dev1FeeOnBuy, uint256 _dev2FeeOnBuy, uint256 _dev3FeeOnBuy, uint256 _dev4FeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_rofl1, _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('rofl1Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
	}
	function setRoflHour1SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _talentFeeOnSell, uint256 _dev1FeeOnSell, uint256 _dev2FeeOnSell, uint256 _dev3FeeOnSell, uint256 _dev4FeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_rofl1, _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
		emit FeeChange('rofl1Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
	}
	// Rofl2 Hour Fees
	function setRoflHour2BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _talentFeeOnBuy, uint256 _dev1FeeOnBuy, uint256 _dev2FeeOnBuy, uint256 _dev3FeeOnBuy, uint256 _dev4FeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_rofl2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('rofl2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _talentFeeOnBuy, _dev1FeeOnBuy, _dev2FeeOnBuy, _dev3FeeOnBuy, _dev4FeeOnBuy, _holdersFeeOnBuy);
	}
	function setRoflHour2SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _talentFeeOnSell, uint256 _dev1FeeOnSell, uint256 _dev2FeeOnSell, uint256 _dev3FeeOnSell, uint256 _dev4FeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_rofl2, _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
		emit FeeChange('rofl2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _talentFeeOnSell, _dev1FeeOnSell, _dev2FeeOnSell, _dev3FeeOnSell, _dev4FeeOnSell, _holdersFeeOnSell);
	}
	function setUniswapRouter(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "CryptoComedyClub: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IRouter(newAddress);
	}
	function setGasForProcessing(uint256 newValue) external onlyOwner {
		require(newValue != gasForProcessing, "CryptoComedyClub: Cannot update gasForProcessing to same value");
		emit GasForProcessingChange(newValue, gasForProcessing);
		gasForProcessing = newValue;
	}
	function setMaxTransactionAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxTxAmount, "CryptoComedyClub: Cannot update maxTxAmount to same value");
		emit MaxTransactionAmountChange(newValue, maxTxAmount);
		maxTxAmount = newValue;
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxWalletAmount, "CryptoComedyClub: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "CryptoComedyClub: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function setMinimumTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		dividendTracker.setTokenBalanceForDividends(newValue);
	}
	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
	}
	function claimBNBOverflow() external onlyOwner {
	    uint256 amount = address(this).balance;
        (bool success,) = address(owner()).call{value : amount}("");
        if (success){
            emit ClaimBNBOverflow(amount);
        }
	}

	// Getters
	function timeSinceLastRoflHour() external view returns(uint256){
	    uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _roflHourStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		return currentTimestamp - _roflHourStartTimestamp;
	}
	function isInRoflHour() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _roflHourStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalRoflTime = _rofl1.timeInPeriod + _rofl2.timeInPeriod;
		uint256 timeSinceRofl = currentTimestamp - _roflHourStartTimestamp;
		if(timeSinceRofl < totalRoflTime) {
			return true;
		} else {
			return false;
		}
	}
	function isInLaunch() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 totalLaunchTime =  _launch1.timeInPeriod + _launch2.timeInPeriod + _launch3.timeInPeriod;

		if(_isLaunched && (timeSinceLaunch < totalLaunchTime || blocksSinceLaunch < _launch1.blocksInPeriod )) {
			return true;
		} else {
			return false;
		}
	}
	function getTotalDividendsDistributed() external view returns (uint256) {
		return dividendTracker.totalDividendsDistributed();
	}
	function getNumberOfDividendTokenHolders() external view returns(uint256) {
		return dividendTracker.getNumberOfTokenHolders();
	}
	function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.talentFeeOnBuy, _base.dev1FeeOnBuy, _base.dev2FeeOnBuy, _base.dev3FeeOnBuy, _base.dev4FeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.talentFeeOnSell, _base.dev1FeeOnSell, _base.dev2FeeOnSell, _base.dev3FeeOnSell, _base.dev4FeeOnSell, _base.holdersFeeOnSell);
	}
	function getRofl1BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_rofl1.liquidityFeeOnBuy, _rofl1.marketingFeeOnBuy, _rofl1.talentFeeOnBuy, _rofl1.dev1FeeOnBuy, _rofl1.dev2FeeOnBuy, _rofl1.dev3FeeOnBuy, _rofl1.dev4FeeOnBuy, _rofl1.holdersFeeOnBuy);
	}
	function getRofl1SellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_rofl1.liquidityFeeOnSell, _rofl1.marketingFeeOnSell, _rofl1.talentFeeOnSell, _rofl1.dev1FeeOnSell, _rofl1.dev2FeeOnSell, _rofl1.dev3FeeOnSell, _rofl1.dev4FeeOnSell, _rofl1.holdersFeeOnSell);
	}
	function getRofl2BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_rofl2.liquidityFeeOnBuy, _rofl2.marketingFeeOnBuy, _rofl2.talentFeeOnBuy, _rofl2.dev1FeeOnBuy, _rofl2.dev2FeeOnBuy, _rofl2.dev3FeeOnBuy, _rofl2.dev4FeeOnBuy, _rofl2.holdersFeeOnBuy);
	}
	function getRofl2SellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
		return (_rofl2.liquidityFeeOnSell, _rofl2.marketingFeeOnSell, _rofl2.talentFeeOnSell, _rofl2.dev1FeeOnSell, _rofl2.dev2FeeOnSell, _rofl2.dev3FeeOnSell, _rofl2.dev4FeeOnSell, _rofl2.holdersFeeOnSell);
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
			uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();

		    if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
				require(isTradingEnabled, "CryptoComedyClub: Trading is currently disabled.");
				require(!_isBlocked[to], "CryptoComedyClub: Account is blocked");
				require(!_isBlocked[from], "CryptoComedyClub: Account is blocked");
				if (_isInLaunch && (currentTimestamp - _launchStartTimestamp) <= 300 && isBuyFromLp) {
					require((currentTimestamp - _buyTimesInLaunch[to]) > 60, "CryptoComedyClub: Cannot buy more than once per min in first 5min of launch");
				}
				if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
					require(amount <= maxTxAmount, "CryptoComedyClub: Buy amount exceeds the maxTxBuyAmount.");
				}
				if (!_isExcludedFromMaxWalletLimit[to]) {
					require((balanceOf(to) + amount) <= maxWalletAmount, "CryptoComedyClub: Expected wallet amount exceeds the maxWalletAmount.");
				}
			}

			_adjustTaxes(isBuyFromLp, isSelltoLp, _isInLaunch, to, from);
			bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

			if (
				isTradingEnabled &&
				canSwap &&
				!_swapping &&
				_totalFee > 0 &&
				automatedMarketMakerPairs[to] &&
				from != liquidityWallet && to != liquidityWallet &&
				from != marketingWallet && to != marketingWallet &&
                from != talentWallet && to != talentWallet &&
				from != dev1Wallet && to != dev1Wallet &&
                from != dev2Wallet && to != dev2Wallet &&
                from != dev3Wallet && to != dev3Wallet &&
                from != dev4Wallet && to != dev4Wallet
				
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
				uint256 fee = amount * _totalFee / 10000;
                uint256 originalAmount = amount;
				amount = amount - fee;
				super._transfer(from, address(this), fee);
                emit TakeFee(_totalFee, fee, amount, originalAmount);
			}

			if (_isInLaunch && (currentTimestamp - _launchStartTimestamp) <= 300) {
				if (to != owner() && isBuyFromLp  && (currentTimestamp - _buyTimesInLaunch[to]) > 60) {
					_buyTimesInLaunch[to] = currentTimestamp;
				}
			}

			super._transfer(from, to, amount);
            
			try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
			try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

			if(!_swapping) {
				uint256 gas = gasForProcessing;
				try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
					emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
				}
				catch {}
			}
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, bool isLaunching, address to, address from) private {
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		uint256 timeSinceRofl = currentTimestamp - _roflHourStartTimestamp;

		_liquidityFee = 0;
		_marketingFee = 0;
		_talentFee = 0;
        _dev1Fee = 0;
		_dev2Fee = 0;
        _dev3Fee = 0;
		_dev4Fee = 0;
		_holdersFee = 0;
			
		if (isBuyFromLp) {
		    _liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
            _talentFee = _base.talentFeeOnBuy;
			_dev1Fee = _base.dev1FeeOnBuy;
			_dev2Fee = _base.dev2FeeOnBuy;
			_dev3Fee = _base.dev3FeeOnBuy;
            _dev4Fee = _base.dev4FeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;
			
			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnBuy;
					_marketingFee = _launch1.marketingFeeOnBuy;
					_talentFee = _launch1.talentFeeOnBuy;
                    _dev1Fee = _launch1.dev1FeeOnBuy;
                    _dev2Fee = _launch1.dev2FeeOnBuy;
                    _dev3Fee = _launch1.dev3FeeOnBuy;
                    _dev4Fee = _launch1.dev4FeeOnBuy;
					_holdersFee = _launch1.holdersFeeOnBuy;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnBuy;
					_marketingFee = _launch2.marketingFeeOnBuy;
					_talentFee = _launch2.talentFeeOnBuy;
                    _dev1Fee = _launch2.dev1FeeOnBuy;
                    _dev2Fee = _launch2.dev2FeeOnBuy;
                    _dev3Fee = _launch2.dev3FeeOnBuy;
                    _dev4Fee = _launch2.dev4FeeOnBuy;
					_holdersFee = _launch2.holdersFeeOnBuy;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnBuy;
					_marketingFee = _launch3.marketingFeeOnBuy;
					_talentFee = _launch3.talentFeeOnBuy;
                    _dev1Fee = _launch3.dev1FeeOnBuy;
                    _dev2Fee = _launch3.dev2FeeOnBuy;
                    _dev3Fee = _launch3.dev3FeeOnBuy;
                    _dev4Fee = _launch3.dev4FeeOnBuy;
					_holdersFee = _launch3.holdersFeeOnBuy;
				}
			}
			else if (timeSinceRofl <= _rofl1.timeInPeriod) {
				_liquidityFee = _rofl1.liquidityFeeOnBuy;
				_marketingFee = _rofl1.marketingFeeOnBuy;
				_talentFee = _rofl1.talentFeeOnBuy;
                _dev1Fee = _rofl1.dev1FeeOnBuy;
                _dev2Fee = _rofl1.dev2FeeOnBuy;
                _dev3Fee = _rofl1.dev3FeeOnBuy;
                _dev4Fee = _rofl1.dev4FeeOnBuy;
				_holdersFee = _rofl1.holdersFeeOnBuy;
			}
			else if (timeSinceRofl > _rofl1.timeInPeriod && timeSinceRofl <= (_rofl1.timeInPeriod + _rofl2.timeInPeriod)) {
				_liquidityFee = _rofl2.liquidityFeeOnBuy;
				_marketingFee = _rofl2.marketingFeeOnBuy;
				_talentFee = _rofl2.talentFeeOnBuy;
                _dev1Fee = _rofl2.dev1FeeOnBuy;
                _dev2Fee = _rofl2.dev2FeeOnBuy;
                _dev3Fee = _rofl2.dev3FeeOnBuy;
                _dev4Fee = _rofl2.dev4FeeOnBuy;
				_holdersFee = _rofl2.holdersFeeOnBuy;
			}
		}
	    if (isSelltoLp) {
	    	_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
            _talentFee = _base.talentFeeOnSell;
            _dev1Fee = _base.dev1FeeOnSell;
            _dev2Fee = _base.dev2FeeOnSell;
            _dev3Fee = _base.dev3FeeOnSell;
            _dev4Fee = _base.dev4FeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;
			
			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnSell;
					_marketingFee = _launch1.marketingFeeOnSell;
					_talentFee = _launch1.talentFeeOnSell;
                    _dev1Fee = _launch1.dev1FeeOnSell;
                    _dev2Fee = _launch1.dev2FeeOnSell;
                    _dev3Fee = _launch1.dev3FeeOnSell;
                    _dev4Fee = _launch1.dev4FeeOnSell;
					_holdersFee = _launch1.holdersFeeOnSell;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnSell;
					_marketingFee = _launch2.marketingFeeOnSell;
					_talentFee = _launch2.talentFeeOnSell;
                    _dev1Fee = _launch2.dev1FeeOnSell;
                    _dev2Fee = _launch2.dev2FeeOnSell;
                    _dev3Fee = _launch2.dev3FeeOnSell;
                    _dev4Fee = _launch2.dev4FeeOnSell;
					_holdersFee = _launch2.holdersFeeOnSell;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnSell;
					_marketingFee = _launch3.marketingFeeOnSell;
					_talentFee = _launch3.talentFeeOnSell;
                    _dev1Fee = _launch3.dev1FeeOnSell;
                    _dev2Fee = _launch3.dev2FeeOnSell;
                    _dev3Fee = _launch3.dev3FeeOnSell;
                    _dev4Fee = _launch3.dev4FeeOnSell;
					_holdersFee = _launch3.holdersFeeOnSell;
				}
			}
			else if (timeSinceRofl <= _rofl1.timeInPeriod) {
				_liquidityFee = _rofl1.liquidityFeeOnSell;
				_marketingFee = _rofl1.marketingFeeOnSell;
				_talentFee = _rofl1.talentFeeOnSell;
                _dev1Fee = _rofl1.dev1FeeOnSell;
                _dev2Fee = _rofl1.dev2FeeOnSell;
                _dev3Fee = _rofl1.dev3FeeOnSell;
                _dev4Fee = _rofl1.dev4FeeOnSell;
				_holdersFee = _rofl1.holdersFeeOnSell;
			}
			else if (timeSinceRofl > _rofl1.timeInPeriod && timeSinceRofl <= (_rofl1.timeInPeriod + _rofl2.timeInPeriod)) {
				_liquidityFee = _rofl2.liquidityFeeOnSell;
				_marketingFee = _rofl2.marketingFeeOnSell;
				_talentFee = _rofl2.talentFeeOnSell;
                _dev1Fee = _rofl2.dev1FeeOnSell;
                _dev2Fee = _rofl2.dev2FeeOnSell;
                _dev3Fee = _rofl2.dev3FeeOnSell;
                _dev4Fee = _rofl2.dev4FeeOnSell;
				_holdersFee = _rofl2.holdersFeeOnSell;
			} 
		}
		if (!isSelltoLp && !isBuyFromLp && (_feeOnSelectedWalletTransfers[from] || _feeOnSelectedWalletTransfers[to])) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
            _talentFee = _base.talentFeeOnSell;
            _dev1Fee = _base.dev1FeeOnSell;
            _dev2Fee = _base.dev2FeeOnSell;
            _dev3Fee = _base.dev3FeeOnSell;
            _dev4Fee = _base.dev4FeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;
			
		}
		else if (!isSelltoLp && !isBuyFromLp && !_feeOnSelectedWalletTransfers[from] && !_feeOnSelectedWalletTransfers[to] && _feeOnWalletTranfers) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_talentFee = _base.talentFeeOnBuy;
            _dev1Fee = _base.dev1FeeOnBuy;
            _dev2Fee = _base.dev2FeeOnBuy;
            _dev3Fee = _base.dev3FeeOnBuy;
            _dev4Fee = _base.dev4FeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;
		}
		_totalFee = _liquidityFee + _marketingFee + _talentFee + _dev1Fee + _dev2Fee + _dev3Fee + _dev4Fee + _holdersFee;
		emit FeesApplied(_liquidityFee, _marketingFee, _talentFee, _dev1Fee, _dev2Fee, _dev3Fee, _dev4Fee, _holdersFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnSell,
		uint256 _marketingFeeOnSell,
		uint256 _talentFeeOnSell,
        uint256 _dev1FeeOnSell,
		uint256 _dev2FeeOnSell,
        uint256 _dev3FeeOnSell,
		uint256 _dev4FeeOnSell,
		uint256 _holdersFeeOnSell
	) private {
		if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
			emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
			map.liquidityFeeOnSell = _liquidityFeeOnSell;
		}
		if (map.marketingFeeOnSell != _marketingFeeOnSell) {
			emit CustomTaxPeriodChange(_marketingFeeOnSell, map.marketingFeeOnSell, 'marketingFeeOnSell', map.periodName);
			map.marketingFeeOnSell = _marketingFeeOnSell;
		}
		if (map.talentFeeOnSell != _talentFeeOnSell) {
			emit CustomTaxPeriodChange(_talentFeeOnSell, map.talentFeeOnSell, 'talentFeeOnSell', map.periodName);
			map.talentFeeOnSell = _talentFeeOnSell;
		}
        if (map.dev1FeeOnSell != _dev1FeeOnSell) {
			emit CustomTaxPeriodChange(_dev1FeeOnSell, map.dev1FeeOnSell, 'dev1FeeOnSell', map.periodName);
			map.dev1FeeOnSell = _dev1FeeOnSell;
		}
        if (map.dev2FeeOnSell != _dev2FeeOnSell) {
			emit CustomTaxPeriodChange(_dev2FeeOnSell, map.dev2FeeOnSell, 'dev2FeeOnSell', map.periodName);
			map.dev2FeeOnSell = _dev2FeeOnSell;
		}
		if (map.dev3FeeOnSell != _dev3FeeOnSell) {
			emit CustomTaxPeriodChange(_dev3FeeOnSell, map.dev3FeeOnSell, 'dev3FeeOnSell', map.periodName);
			map.dev3FeeOnSell = _dev3FeeOnSell;
		}
        if (map.dev4FeeOnSell != _dev4FeeOnSell) {
			emit CustomTaxPeriodChange(_dev4FeeOnSell, map.dev4FeeOnSell, 'dev4FeeOnSell', map.periodName);
			map.dev4FeeOnSell = _dev4FeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnBuy,
		uint256 _marketingFeeOnBuy,
		uint256 _talentFeeOnBuy,
        uint256 _dev1FeeOnBuy,
		uint256 _dev2FeeOnBuy,
        uint256 _dev3FeeOnBuy,
		uint256 _dev4FeeOnBuy,
		uint256 _holdersFeeOnBuy
		) private {
		if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
			emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
			map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
		}
		if (map.marketingFeeOnBuy != _marketingFeeOnBuy) {
			emit CustomTaxPeriodChange(_marketingFeeOnBuy, map.marketingFeeOnBuy, 'marketingFeeOnBuy', map.periodName);
			map.marketingFeeOnBuy = _marketingFeeOnBuy;
		}
		if (map.talentFeeOnBuy != _talentFeeOnBuy) {
			emit CustomTaxPeriodChange(_talentFeeOnBuy, map.talentFeeOnBuy, 'talentFeeOnBuy', map.periodName);
			map.talentFeeOnBuy = _talentFeeOnBuy;
		}
		if (map.dev1FeeOnBuy != _dev1FeeOnBuy) {
			emit CustomTaxPeriodChange(_dev1FeeOnBuy, map.dev1FeeOnBuy, 'dev1FeeOnBuy', map.periodName);
			map.dev1FeeOnBuy = _dev1FeeOnBuy;
		}
        if (map.dev2FeeOnBuy != _dev2FeeOnBuy) {
			emit CustomTaxPeriodChange(_dev2FeeOnBuy, map.dev2FeeOnBuy, 'dev2FeeOnBuy', map.periodName);
			map.dev2FeeOnBuy = _dev2FeeOnBuy;
		}
        if (map.dev3FeeOnBuy != _dev3FeeOnBuy) {
			emit CustomTaxPeriodChange(_dev3FeeOnBuy, map.dev3FeeOnBuy, 'dev3FeeOnBuy', map.periodName);
			map.dev3FeeOnBuy = _dev3FeeOnBuy;
		}
        if (map.dev4FeeOnBuy != _dev4FeeOnBuy) {
			emit CustomTaxPeriodChange(_dev4FeeOnBuy, map.dev4FeeOnBuy, 'dev4FeeOnBuy', map.periodName);
			map.dev4FeeOnBuy = _dev4FeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialBNBBalance = address(this).balance;

		uint256 totalFeePrior = _totalFee;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
        uint256 amountForHolders = contractBalance * _holdersFee / _totalFee;
		uint256 amountToSwap = contractBalance - (amountToLiquify + amountForHolders);

		_swapTokensForBNB(amountToSwap);

		uint256 BNBBalanceAfterSwap = address(this).balance - initialBNBBalance;
		uint256 totalBNBFee = _totalFee - (_liquidityFee / 2) - (_holdersFee);

		uint256 amountBNBLiquidity = BNBBalanceAfterSwap * _liquidityFee / totalBNBFee / 2;
		uint256 amountBNBMarketing = BNBBalanceAfterSwap * _marketingFee / totalBNBFee;
        uint256 amountBNBDev1 = BNBBalanceAfterSwap * _dev1Fee / totalBNBFee;
        uint256 amountBNBDev2 = BNBBalanceAfterSwap * _dev2Fee / totalBNBFee;
        uint256 amountBNBDev3 = BNBBalanceAfterSwap * _dev3Fee / totalBNBFee;
        uint256 amountBNBDev4 = BNBBalanceAfterSwap * _dev4Fee / totalBNBFee;
		uint256 amountBNBTalent = BNBBalanceAfterSwap - (amountBNBLiquidity + amountBNBMarketing + amountBNBDev1 + amountBNBDev2 + amountBNBDev3 + amountBNBDev4);

		payable(marketingWallet).transfer(amountBNBMarketing);
		payable(talentWallet).transfer(amountBNBTalent);
        payable(dev1Wallet).transfer(amountBNBDev1);
        payable(dev2Wallet).transfer(amountBNBDev2);
        payable(dev3Wallet).transfer(amountBNBDev3);
        payable(dev4Wallet).transfer(amountBNBDev4);
		
        emit ValueCheck(initialBNBBalance, amountToLiquify, amountForHolders,amountToSwap, BNBBalanceAfterSwap, totalBNBFee);
        emit BNBAmounts(amountBNBLiquidity, amountBNBMarketing, amountBNBDev1, amountBNBDev2, amountBNBDev3, amountBNBDev4, amountBNBTalent);
		
        if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountBNBLiquidity);
			emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
		}

		(bool success) = IERC20(address(this)).transfer(address(dividendTracker), amountForHolders);
		if(success) {
			dividendTracker.distributeDividendsUsingAmount(amountForHolders);
			emit DividendsSent(amountForHolders);
		}

		_totalFee = totalFeePrior;
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

contract CryptoComedyClubDividendTracker is DividendPayingToken {
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
	event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event Claim(address indexed account, uint256 amount, bool indexed automatic);

	constructor() public DividendPayingToken("CryptoComedyClub_Dividend_Tracker", "CryptoComedyClub_Dividend_Tracker") {
		claimWait = 3600;
		minimumTokenBalanceForDividends = 0 * (10**18);
	}
    function setRewardToken(address token) external onlyOwner {
		_setRewardToken(token);
	}
	function _transfer(address, address, uint256) internal override {
		require(false, "CryptoComedyClub_Dividend_Tracker: No transfers allowed");
	}
	function excludeFromDividends(address account) external onlyOwner {
		require(!excludedFromDividends[account]);
		excludedFromDividends[account] = true;
		_setBalance(account, 0);
		tokenHoldersMap.remove(account);
		emit ExcludeFromDividends(account);
	}
	function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		require(minimumTokenBalanceForDividends != newValue, "CryptoComedyClub_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
		minimumTokenBalanceForDividends = newValue;
	}
	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
		require(newClaimWait >= 3600 && newClaimWait <= 86400, "CryptoComedyClub_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
		require(newClaimWait != claimWait, "CryptoComedyClub_Dividend_Tracker: Cannot update claimWait to same value");
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
					uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
					iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
				}
			}
			withdrawableDividends = withdrawableDividendOf(account);
			totalDividends = accumulativeDividendOf(account);
			lastClaimTime = lastClaimTimes[account];
			nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
			secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
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
	function setBalance(address payable account, uint256 newBalance) external onlyOwner {
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

	function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
		uint256 amount = _withdrawDividendOfUser(account);
		if(amount > 0) {
			lastClaimTimes[account] = block.timestamp;
			emit Claim(account, amount, automatic);
			return true;
		}
		return false;
	}
}