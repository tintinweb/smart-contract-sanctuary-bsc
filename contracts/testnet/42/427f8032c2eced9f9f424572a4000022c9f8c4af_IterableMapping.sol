/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}
	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

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

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}

interface DividendPayingTokenInterface {
	function dividendOf(address _owner) external view returns(uint256);
	function distributeDividends() external payable;
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
	IUniswapV2Router02 public uniswapV2Router;

	mapping(address => int256) internal magnifiedDividendCorrections;
	mapping(address => uint256) internal withdrawnDividends;

	constructor(string memory _name, string memory _symbol) public ERC20(_name, _symbol) {}

	receive() external payable {
		distributeDividends();
	}
	function distributeDividendsUsingAmount(uint256 amount) public onlyOwner {
		require(totalSupply() > 0);
		if (amount > 0) {
			magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
			emit DividendsDistributed(msg.sender, amount);
			totalDividendsDistributed = totalDividendsDistributed.add(amount);
		}
	}
	function distributeDividends() public override onlyOwner payable {
		require(totalSupply() > 0);
		if (msg.value > 0) {
			magnifiedDividendPerShare = magnifiedDividendPerShare.add((msg.value).mul(magnitude) / totalSupply());
			emit DividendsDistributed(msg.sender, msg.value);
			totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
		}
	}
	function withdrawDividend() public virtual override onlyOwner {
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
	function _setUniswapRouter(address router) internal onlyOwner {
		uniswapV2Router = IUniswapV2Router02(router);
	}
}

contract Grove is Ownable, ERC20 {
	IUniswapV2Router02 public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private constant _name = "Grove Token";
	string private constant _symbol = "GVR";
	uint8 private constant _decimals = 18;

	GroveDividendTracker public dividendTracker;
	IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _buyBackFee;
	uint256 private _burnFee;
	uint256 private _holdersFee;
	uint256 private _totalFee;

	bool public isTradingEnabled;
	bool private _isLaunched;
	bool private _swapping;
	bool private _feeOnWalletTranfers;
	uint256 private _tradingPausedTimestamp;
	uint256 public sellCoolDownPeriod = 21600;

	// initialSupply
	uint256 constant initialSupply = 100000000000000000 * (10**18);

	// max wallet is 1.0% of initialSupply
	uint256 public maxWalletAmount = initialSupply * 100 / 10000;

	// max buy and sell tx is 0.5% of initialSupply
	uint256 public maxTxAmount = initialSupply * 50 / 10000;
	uint256 public maxSellTxAmount = 50000000000000 * (10**18);
	uint256 public maxBuyTxAmount = 500000000000000 * (10**18);

	// swap and liquify tx is 0.05% of initialSupply
	uint256 public minimumTokensBeforeSwap = initialSupply * 50 / 100000;
	uint256 public gasForProcessing = 300000;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	uint256 private _sproutHourStartTimestamp;
	uint256 private constant _blockedTimeLimit = 172800;

	address public dividendToken;
	address public liquidityWallet;
	address public marketingWallet;
	address public buyBackWallet;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint24 timeInPeriod;
		uint256 liquidityFeeOnBuy;
		uint256 liquidityFeeOnSell;
		uint256 marketingFeeOnBuy;
		uint256 marketingFeeOnSell;
		uint256 buyBackFeeOnBuy;
		uint256 buyBackFeeOnSell;
		uint256 burnFeeOnBuy;
		uint256 burnFeeOnSell;
		uint256 holdersFeeOnBuy;
		uint256 holdersFeeOnSell;
	}

	// Launch taxes
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',5,0,1,100,3,0,1,0,2,0,3,0);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,1,3,3,9,1,7,2,2,3,9);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,82800,1,2,3,8,1,4,2,3,3,8);

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,3,3,1,1,2,2,3,3);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,1,1,3,3,1,1,2,2,3,3);

	// sprout Hour taxes
	CustomTaxPeriod private _sprout1 = CustomTaxPeriod('sprout1',0,3600,0,3,0,9,0,7,0,2,3,9);
	CustomTaxPeriod private _sprout2 = CustomTaxPeriod('sprout2',0,3600,1,2,3,8,1,4,2,3,3,8);

	mapping (address => bool) private _feeOnSelectedWalletTransfers;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isExcludedFromSellCoolDown;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => uint256) private _buyTimesInLaunch;
	mapping (address => uint256) private _lastSells;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
	event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 burnFee, uint256 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
	event SproutHourChange(bool indexed newValue, bool indexed oldValue);
	event MaxTransactionAmountChange(uint256 indexed globalValue, uint256 indexed sellValue, uint256 indexed buyValue);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFrom(string indexed excludeType, address indexed account, bool isExcluded);
	event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountForDividendsChange(uint256 indexed newValue, uint256 indexed oldValue);
	event DividendsSent(uint256 tokensSwapped);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived,uint256 tokensIntoLiqudity);
	event ClaimBNBOverflow(uint256 amount);
	event MarketingSent(uint256 amountBNBMarketing, uint256 BUSDBalanceAfterSwap);
	event FeeOnWalletTransferChange(bool indexed newValue, bool indexed oldValue);
	event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);
	event SellCoolDownPeriodChange(uint256 indexed newCoolDown, uint256 indexed sellCoolDownPeriod);
	event FeesApplied(uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 burnFee, uint256 holdersFee, uint256 totalFee);
	event ProcessedDividendTracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed automatic,
		uint256 gas,
		address indexed processor
	);

	constructor() public ERC20(_name, _symbol) {
		dividendToken = address(this);
		dividendTracker = new GroveDividendTracker();
		dividendTracker.setUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		dividendTracker.setRewardToken(dividendToken);

		marketingWallet = address(0x09F19d320C0E758552f0692BD6aBc10b80185AeE);
		liquidityWallet = address(0xF032646F1c003b73f696fb4Ca6267C2690732aE1);
		buyBackWallet = address(0x545498c71f9894c641f8304f408153084bF39fBa);

		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
		address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);

		_isExcludedFromFee[owner()] = true;
		_isExcludedFromFee[address(this)] = true;
		_isExcludedFromFee[address(dividendTracker)] = true;
		_isExcludedFromFee[marketingWallet] = true;
		_isExcludedFromFee[buyBackWallet] = true;
		_isExcludedFromFee[liquidityWallet] = true;

		dividendTracker.excludeFromDividends(address(dividendTracker));
		dividendTracker.excludeFromDividends(address(this));
		dividendTracker.excludeFromDividends(address(0x000000000000000000000000000000000000dEaD));
		dividendTracker.excludeFromDividends(owner());
		dividendTracker.excludeFromDividends(address(_uniswapV2Router));

		_isAllowedToTradeWhenDisabled[owner()] = true;
		_isExcludedFromSellCoolDown[owner()] = true;
		_isExcludedFromSellCoolDown[address(dividendTracker)] = true;
		_isExcludedFromSellCoolDown[_uniswapV2Pair] = true;
		_isExcludedFromSellCoolDown[address(uniswapV2Router)] = true;
		_isExcludedFromSellCoolDown[address(this)] = true;
		_isExcludedFromSellCoolDown[marketingWallet] = true;
		_isExcludedFromSellCoolDown[buyBackWallet] = true;
		_isExcludedFromSellCoolDown[liquidityWallet] = true;

		_isExcludedFromMaxTransactionLimit[address(dividendTracker)] = true;
		_isExcludedFromMaxTransactionLimit[address(this)] = true;
		_isExcludedFromMaxTransactionLimit[owner()] = true;
		_isExcludedFromMaxTransactionLimit[marketingWallet] = true;
		_isExcludedFromMaxTransactionLimit[buyBackWallet] = true;
		_isExcludedFromMaxTransactionLimit[liquidityWallet] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(dividendTracker)] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;
		_isExcludedFromMaxWalletLimit[marketingWallet] = true;
		_isExcludedFromMaxWalletLimit[buyBackWallet] = true;
		_isExcludedFromMaxWalletLimit[liquidityWallet] = true;

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
		require(this.isInLaunch(), "Grove: Launch is not set");
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
	function setSellCoolDownPeriod(uint256 newCoolDown) external onlyOwner {
		require(newCoolDown != sellCoolDownPeriod, "Grove: sellCoolDownPeriod is already set to the value of newCoolDown");
		emit SellCoolDownPeriodChange(newCoolDown, sellCoolDownPeriod);
		sellCoolDownPeriod = newCoolDown;
	}
	function setSproutHour() external onlyOwner {
		require(!this.isInSproutHour(), "Grove: Sprout Hour is already set");
		require(isTradingEnabled, "Grove: Trading must be enabled first");
		require(!this.isInLaunch(), "Grove: Must not be in launch period");
		emit SproutHourChange(true, false);
		_sproutHourStartTimestamp = _getNow();
	}
	function cancelSproutHour() external onlyOwner {
		require(this.isInSproutHour(), "Grove: Sprout Hour is not set");
		emit SproutHourChange(false, true);
		_sproutHourStartTimestamp = 0;
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "Grove: Automated market maker pair is already set to that value");
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
		require(_isExcludedFromFee[account] != excluded, "Grove: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromDividends(address account) external onlyOwner {
		dividendTracker.excludeFromDividends(account);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "Grove: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFrom('maxTransaction', account, excluded);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "Grove: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFrom('maxWallet', account, excluded);
	}
	function excludeFromSellCoolDown(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromSellCoolDown[account] != excluded, "Grove: Account is already the value of 'excluded'");
		_isExcludedFromSellCoolDown[account] = excluded;
		emit ExcludeFrom('sellCoolDown', account, excluded);
	}
	function blockAccount(address account) external onlyOwner {
		uint256 currentTimestamp = _getNow();
		require(!_isBlocked[account], "Grove: Account is already blocked");
		if (_isLaunched) {
			require(currentTimestamp - _launchStartTimestamp < _blockedTimeLimit, "Grove: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) external onlyOwner {
		require(_isBlocked[account], "Grove: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setFeeOnWalletTransfers(bool value) external onlyOwner {
		emit FeeOnWalletTransferChange(value, _feeOnWalletTranfers);
		_feeOnWalletTranfers = value;
	}
	function setFeeOnSelectedWalletTransfers(address account, bool value) external onlyOwner {
		require(_feeOnSelectedWalletTransfers[account] != value, "Grove: The selected wallet is already set to the value ");
		_feeOnSelectedWalletTransfers[account] = value;
		emit FeeOnSelectedWalletTransfersChange(account, value);
	}
	function setWallets(address newLiquidityWallet, address newMarketingWallet, address newBuyBackWallet) external onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "Grove: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "Grove: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
		if(buyBackWallet != newBuyBackWallet) {
			require(newBuyBackWallet != address(0), "Grove: The buyBackWallet cannot be 0");
			emit WalletChange('buyBackWallet', newBuyBackWallet, buyBackWallet);
			buyBackWallet = newBuyBackWallet;
		}
	}
	function setAllFeesToZero() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0);
	}
	function resetAllFees() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.buyBackFeeOnBuy, _default.burnFeeOnBuy, _default.holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.buyBackFeeOnBuy, _default.burnFeeOnBuy,  _default.holdersFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.buyBackFeeOnSell, _default.burnFeeOnSell,  _default.holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.buyBackFeeOnSell, _default.burnFeeOnSell, _default.holdersFeeOnSell);
	}
	// Base fees
	function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _burnFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _burnFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
	}
	// sprout Hour 1 Fees
	function setSproutHour1BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _burnFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_sprout1, _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('Sprout1Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
	}
	function setSproutHour1SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _burnFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_sprout1, _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('Sprout1Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
	}
	// Sprout Hour 2 Fees
	function setSproutHour2BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _burnFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_sprout2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('sprout2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _buyBackFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
	}
	function setSproutHour2SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _burnFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_sprout2, _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('sprout2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _buyBackFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
	}
	function setUniswapRouter(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "Grove: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IUniswapV2Router02(newAddress);
		dividendTracker.setUniswapRouter(newAddress);
	}
	function setMaxTransactionAmount(uint256 globalValue, uint256 buyValue, uint256 sellValue) external onlyOwner {
		emit MaxTransactionAmountChange(globalValue, sellValue, buyValue);
		maxTxAmount = globalValue;
		maxSellTxAmount = sellValue;
		maxBuyTxAmount = buyValue;
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxWalletAmount, "Grove: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "Grove: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function setMinimumTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		dividendTracker.setTokenBalanceForDividends(newValue);
	}
	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
	}
	function claimBNBOverflow(uint256 amount) external onlyOwner {
		require(amount < address(this).balance, "Grove: Cannot send more than contract balance");
		(bool success,) = address(owner()).call{value : amount}("");
		if (success){
			emit ClaimBNBOverflow(amount);
		}
	}

	// Getters
	function isInSproutHour() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _sproutHourStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalsproutTime = _sprout1.timeInPeriod + _sprout2.timeInPeriod;
		if(currentTimestamp - _sproutHourStartTimestamp < totalsproutTime) {
			return true;
		} else {
			return false;
		}
	}
	function isInLaunch() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalLaunchTime =  _launch1.timeInPeriod + _launch2.timeInPeriod + _launch3.timeInPeriod;
		if(_isLaunched && (currentTimestamp - _launchStartTimestamp < totalLaunchTime || block.number - _launchBlockNumber < _launch1.blocksInPeriod )) {
			return true;
		} else {
			return false;
		}
	}
	function getTotalDividendsDistributed() external view returns (uint256) {
		return dividendTracker.totalDividendsDistributed();
	}
	function withdrawableDividendOf(address account) public view returns(uint256) {
		return dividendTracker.withdrawableDividendOf(account);
	}
	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}
	function getNumberOfDividendTokenHolders() external view returns(uint256) {
		return dividendTracker.getNumberOfTokenHolders();
	}
	function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.buyBackFeeOnBuy, _base.burnFeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.buyBackFeeOnSell, _base.burnFeeOnSell, _base.holdersFeeOnSell);
	}
	function getSprout1BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_sprout1.liquidityFeeOnBuy, _sprout1.marketingFeeOnBuy, _sprout1.buyBackFeeOnBuy, _sprout1.burnFeeOnBuy, _sprout1.holdersFeeOnBuy);
	}
	function getSprout1SellFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_sprout1.liquidityFeeOnSell, _sprout1.marketingFeeOnSell, _sprout1.buyBackFeeOnSell, _sprout1.burnFeeOnSell, _sprout1.holdersFeeOnSell);
	}
	function getSprout2BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_sprout2.liquidityFeeOnBuy, _sprout2.marketingFeeOnBuy, _sprout2.buyBackFeeOnBuy, _sprout2.burnFeeOnBuy, _sprout2.holdersFeeOnBuy);
	}
	function getSprout2SellFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_sprout2.liquidityFeeOnSell, _sprout2.marketingFeeOnSell, _sprout2.buyBackFeeOnSell, _sprout2.burnFeeOnSell, _sprout2.holdersFeeOnSell);
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
			require(isTradingEnabled, "Grove: Trading is currently disabled.");
			require(!_isBlocked[to], "Grove: Account is blocked");
			require(!_isBlocked[from], "Grove: Account is blocked");
			if (_isInLaunch && currentTimestamp - _launchStartTimestamp <= 300 && isBuyFromLp) {
				require((currentTimestamp - _buyTimesInLaunch[to]) > 60, "Grove: Cannot buy more than once per min in launch");
			}
			if (isSelltoLp && !_isExcludedFromSellCoolDown[from]) {
				require((currentTimestamp - _lastSells[from]) >= sellCoolDownPeriod, "Grove: Must wait sellCoolDownPeriod to sell again");
			}
			if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
				require(amount <= maxTxAmount, "Grove: Amount > maxTxAmount.");
				if (isSelltoLp) {
					require(amount <= maxSellTxAmount, "Grove: Sell amount > maxSellTxAmount.");
				}
				if (isBuyFromLp) {
					require(amount <= maxBuyTxAmount, "Grove: Buy amount > maxBuyTxAmount.");
				}
			}
			if (!_isExcludedFromMaxWalletLimit[to] && isBuyFromLp) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "Grove: Expected wallet amount > maxWalletAmount.");
			}
		}

		_adjustTaxes(isBuyFromLp, isSelltoLp, _isInLaunch, from);
		bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

		if (
			isTradingEnabled &&
			canSwap &&
			!_swapping &&
			_totalFee > 0 &&
			automatedMarketMakerPairs[to] &&
			from != liquidityWallet && to != liquidityWallet &&
			from != marketingWallet && to != marketingWallet &&
			from != buyBackWallet && to != buyBackWallet
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
			uint256 burnAmount = amount * _burnFee / 100;
			amount = amount - fee;
			super._transfer(from, address(this), fee);

			if (burnAmount > 0) {
				super._burn(address(this), burnAmount);
			}
		}

		super._transfer(from, to, amount);

		if (_isInLaunch && (currentTimestamp - _launchStartTimestamp) <= 300) {
			if (to != owner() && isBuyFromLp  && (currentTimestamp - _buyTimesInLaunch[to]) > 60) {
				_buyTimesInLaunch[to] = currentTimestamp;
			}
		}

		if (isSelltoLp) {
			_lastSells[from] = currentTimestamp;
		}

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
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, bool isLaunching, address from) private {
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		uint256 timeSinceSprout = currentTimestamp - _sproutHourStartTimestamp;
		_liquidityFee = 0;
		_marketingFee = 0;
		_buyBackFee = 0;
		_burnFee = 0;
		_holdersFee = 0;

		if (isBuyFromLp) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_buyBackFee = _base.buyBackFeeOnBuy;
			_burnFee = _base.burnFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;

			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnBuy;
					_marketingFee = _launch1.marketingFeeOnBuy;
					_buyBackFee = _launch1.buyBackFeeOnBuy;
					_burnFee = _launch1.burnFeeOnBuy;
					_holdersFee = _launch1.holdersFeeOnBuy;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnBuy;
					_marketingFee = _launch2.marketingFeeOnBuy;
					_buyBackFee = _launch2.buyBackFeeOnBuy;
					_burnFee = _launch2.burnFeeOnBuy;
					_holdersFee = _launch2.holdersFeeOnBuy;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnBuy;
					_marketingFee = _launch3.marketingFeeOnBuy;
					_buyBackFee = _launch3.buyBackFeeOnBuy;
					_burnFee = _launch3.burnFeeOnBuy;
					_holdersFee = _launch3.holdersFeeOnBuy;
				}
			}
			else if (timeSinceSprout <= _sprout1.timeInPeriod) {
				_liquidityFee = _sprout1.liquidityFeeOnBuy;
				_marketingFee = _sprout1.marketingFeeOnBuy;
				_buyBackFee = _sprout1.buyBackFeeOnBuy;
				_burnFee = _sprout1.burnFeeOnBuy;
				_holdersFee = _sprout1.holdersFeeOnBuy;
			}
			else if (timeSinceSprout > _sprout1.timeInPeriod && timeSinceSprout <= _sprout1.timeInPeriod + _sprout2.timeInPeriod) {
				_liquidityFee = _sprout2.liquidityFeeOnBuy;
				_marketingFee = _sprout2.marketingFeeOnBuy;
				_buyBackFee = _sprout2.buyBackFeeOnBuy;
				_burnFee = _sprout2.burnFeeOnBuy;
				_holdersFee = _sprout2.holdersFeeOnBuy;
			}
		}
		if (isSelltoLp) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_buyBackFee = _base.buyBackFeeOnSell;
			_burnFee = _base.burnFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;

			if (isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnSell;
					_marketingFee = _launch1.marketingFeeOnSell;
					_buyBackFee = _launch1.buyBackFeeOnSell;
					_burnFee = _launch1.burnFeeOnSell;
					_holdersFee = _launch1.holdersFeeOnSell;
				}
				if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnSell;
					_marketingFee = _launch2.marketingFeeOnSell;
					_buyBackFee = _launch2.buyBackFeeOnSell;
					_burnFee = _launch2.burnFeeOnSell;
					_holdersFee = _launch2.holdersFeeOnSell;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnSell;
					_marketingFee = _launch3.marketingFeeOnSell;
					_buyBackFee = _launch3.buyBackFeeOnSell;
					_burnFee = _launch3.burnFeeOnSell;
					_holdersFee = _launch3.holdersFeeOnSell;
				}
			}
			else if (timeSinceSprout <= _sprout1.timeInPeriod) {
				_liquidityFee = _sprout1.liquidityFeeOnSell;
				_marketingFee = _sprout1.marketingFeeOnSell;
				_buyBackFee = _sprout1.buyBackFeeOnSell;
				_burnFee = _sprout1.burnFeeOnSell;
				_holdersFee = _sprout1.holdersFeeOnSell;
			}
			else if (timeSinceSprout > _sprout1.timeInPeriod && timeSinceSprout <= _sprout1.timeInPeriod + _sprout2.timeInPeriod) {
				_liquidityFee = _sprout2.liquidityFeeOnSell;
				_marketingFee = _sprout2.marketingFeeOnSell;
				_buyBackFee = _sprout2.buyBackFeeOnSell;
				_burnFee = _sprout2.burnFeeOnSell;
				_holdersFee = _sprout2.holdersFeeOnSell;
			}
		}
		if (!isSelltoLp && !isBuyFromLp && _feeOnSelectedWalletTransfers[from]) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_buyBackFee = _base.buyBackFeeOnSell;
			_burnFee = _base.burnFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;
		}
		if (!isSelltoLp && !isBuyFromLp && !_feeOnSelectedWalletTransfers[from] && _feeOnWalletTranfers) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_buyBackFee = _base.buyBackFeeOnBuy;
			_burnFee = _base.burnFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;
		}

		_totalFee = _liquidityFee + _marketingFee + _buyBackFee + _burnFee + _holdersFee;
		emit FeesApplied(_liquidityFee, _marketingFee, _buyBackFee, _burnFee, _holdersFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnSell,
		uint256 _marketingFeeOnSell,
		uint256 _buyBackFeeOnSell,
		uint256 _burnFeeOnSell,
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
		if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
			emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
			map.buyBackFeeOnSell = _buyBackFeeOnSell;
		}
		if (map.burnFeeOnSell != _burnFeeOnSell) {
			emit CustomTaxPeriodChange(_burnFeeOnSell, map.burnFeeOnSell, 'burnFeeOnSell', map.periodName);
			map.burnFeeOnSell = _burnFeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnBuy,
		uint256 _marketingFeeOnBuy,
		uint256 _buyBackFeeOnBuy,
		uint256 _burnFeeOnBuy,
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
		if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
			emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
			map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
		}
		if (map.burnFeeOnBuy != _burnFeeOnBuy) {
			emit CustomTaxPeriodChange(_burnFeeOnBuy, map.burnFeeOnBuy, 'burnFeeOnBuy', map.periodName);
			map.burnFeeOnBuy = _burnFeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialBNBBalance = address(this).balance;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
		uint256 amountForHolders = contractBalance * _holdersFee / _totalFee;
		uint256 amountToSwap = contractBalance - (amountToLiquify + amountForHolders);

		_swapTokensForBNB(amountToSwap);

		uint256 BNBBalanceAfterSwap = address(this).balance - initialBNBBalance;
		uint256 totalBNBFee = _totalFee - (_liquidityFee / 2);
		uint256 amountBNBLiquidity = BNBBalanceAfterSwap * _liquidityFee / totalBNBFee / 2;
		uint256 amountBNBMarketing = BNBBalanceAfterSwap * _marketingFee / totalBNBFee;
		uint256 amountBNBBuyBack = BNBBalanceAfterSwap - (amountBNBLiquidity + amountBNBMarketing);

		payable(buyBackWallet).transfer(amountBNBBuyBack);

		if (amountBNBMarketing > 0 ) {
			uint256 initialBUSDBalance = BUSD.balanceOf(address(this));
			_swapBNBForBUSD(amountBNBMarketing);
			uint256 BUSDBalanceAfterSwap = BUSD.balanceOf(address(this)) - initialBUSDBalance;
			(bool marketingSuccess) = BUSD.transfer(marketingWallet, BUSDBalanceAfterSwap);
			if (marketingSuccess) {
				emit MarketingSent(amountBNBMarketing, BUSDBalanceAfterSwap);
			}
		}

		if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountBNBLiquidity);
			emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
		}

		(bool success) = IERC20(address(this)).transfer(address(dividendTracker), amountForHolders);
		if(success) {
			dividendTracker.distributeDividendsUsingAmount(amountForHolders);
			emit DividendsSent(amountForHolders);
		}
	}
	function _swapBNBForBUSD(uint256 bnbAmount) private {
		address[] memory path = new address[](2);
		path[0] = uniswapV2Router.WETH();
		path[1] = address(BUSD);

		_approve(address(this), address(uniswapV2Router), bnbAmount);
		uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : bnbAmount}(
			0, // accept any amount of tokens
			path,
			address(this),
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

contract GroveDividendTracker is DividendPayingToken {
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

	constructor() public DividendPayingToken("Grove_Dividend_Tracker", "Grove_Dividend_Tracker") {
		claimWait = 3600;
		minimumTokenBalanceForDividends = 0 * (10**18);
	}
	function setRewardToken(address token) external onlyOwner {
		_setRewardToken(token);
	}
	function setUniswapRouter(address router) external onlyOwner {
		_setUniswapRouter(router);
	}
	function _transfer(address, address, uint256) internal override {
		require(false, "Grove_Dividend_Tracker: No transfers allowed");
	}
	function excludeFromDividends(address account) external onlyOwner {
		require(!excludedFromDividends[account]);
		excludedFromDividends[account] = true;
		_setBalance(account, 0);
		tokenHoldersMap.remove(account);
		emit ExcludeFromDividends(account);
	}
	function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		require(minimumTokenBalanceForDividends != newValue, "Grove_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
		minimumTokenBalanceForDividends = newValue;
	}
	function getLastProcessedIndex() external view returns(uint256) {
		return lastProcessedIndex;
	}
	function getNumberOfTokenHolders() external view returns(uint256) {
		return tokenHoldersMap.keys.length;
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
	function process(uint256 gas) public onlyOwner returns (uint256, uint256, uint256) {
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