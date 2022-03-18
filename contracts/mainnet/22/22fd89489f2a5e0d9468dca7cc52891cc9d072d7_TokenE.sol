/**
 *Submitted for verification at BscScan.com on 2022-03-18
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

	receive() external payable {}

	function distributeDividendsUsingAmount(uint256 amount) public onlyOwner {
		require(totalSupply() > 0);
		if (amount > 0) {
			magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
			emit DividendsDistributed(msg.sender, amount);
			totalDividendsDistributed = totalDividendsDistributed.add(amount);
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
	function _swapBNBForTokensAndWithdrawDividend(address holder, uint256 bnbAmount) private returns(uint256) {
		address[] memory path = new address[](2);
		path[0] = uniswapV2Router.WETH();
		path[1] = address(rewardToken);

		try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : bnbAmount}(
			0, // accept any amount of tokens
			path,
			address(holder),
			block.timestamp
		) {
			return bnbAmount;
		} catch {
			withdrawnDividends[holder] = withdrawnDividends[holder].sub(bnbAmount);
			return 0;
		}
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

contract TokenE is Ownable, ERC20 {
	IUniswapV2Router02 public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private constant _name = "TokenE"; //"Equitable Growth Opportunity";
	string private constant _symbol = "TokenE"; //EGO
	uint8 private constant _decimals = 18;

	EquitableGrowthOpportunityDividendTracker public dividendTracker;

	bool public isTradingEnabled;
	uint256 private _tradingPausedTimestamp;

	// initialSupply
	uint256 constant initialSupply = 1000000000 * (10**18);

	// max wallet is 2.5% of initialSupply
	uint256 public maxWalletAmount = initialSupply * 250 / 10000;

    uint256 public maxTxBuyAmount = 10000000 * (10**18);
    uint256 public maxTxSellAmount = 5000000 * (10**18);

	bool private _swapping;
	uint256 public minimumTokensBeforeSwap = 1 * (10**18);
	uint256 public gasForProcessing = 300000;

	address public dividendToken;
	address public FETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; 
	//0x658b0c7613e890EE50B8C4BC6A3f41ef411208aD;
    
    address public liquidityWallet;
	address public marketingWallet;
	address public salaryWallet;
    address public investingWallet;
    address public dreamFoundationWallet;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint256 liquidityFeeOnBuy;
		uint256 liquidityFeeOnSell;
		uint256 marketingFeeOnBuy;
		uint256 marketingFeeOnSell;
		uint256 salaryFeeOnBuy;
		uint256 salaryFeeOnSell;
		uint256 investingFeeOnBuy;
		uint256 investingFeeOnSell;
        uint256 dreamFoundationFeeOnBuy;
		uint256 dreamFoundationFeeOnSell;
		uint256 holdersFeeOnBuy;
		uint256 holdersFeeOnSell;
	}

	// Launch taxes
	bool private _isLaunched;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',5,0,100,1,0,2,0,2,0,5,0,2,0,3);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,1,1,1,2,1,2,3,5,1,2,3,3);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,82800,1,1,1,2,1,2,3,5,1,2,3,3);

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,1,2,1,2,3,5,1,2,3,3);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,1,1,1,2,1,2,3,5,1,2,3,3);

	uint256 private constant _blockedTimeLimit = 172800;
	bool private _feeOnWalletTranfers;
	mapping (address => bool) private _feeOnSelectedWalletTransfers;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
    mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256) private _lastTransactions;

	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _salaryFee;
	uint256 private _investingFee;
    uint256 private _dreamFoundationFee;
	uint256 private _holdersFee;
	uint256 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
	event GasForProcessingChange(uint256 indexed newValue, uint256 indexed oldValue);
	event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 salaryFee, uint256 investingFee, uint256 dreamFoundationFee, uint256 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
	event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
	event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountForDividendsChange(uint256 indexed newValue, uint256 indexed oldValue);
	event DividendsSent(uint256 tokensSwapped);
    event DividendTokenChange(address newValue, address oldValue);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
	event ClaimFTMOverflow(uint256 amount);
	event FeeOnWalletTransferChange(bool indexed newValue, bool indexed oldValue);
	event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);
	event ProcessedDividendTracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed automatic,
		uint256 gas,
		address indexed processor
	);
	event FeesApplied(uint256 liquidityFee, uint256 marketingFee, uint256 salaryFee, uint256 investingFee, uint256 dreamFoundationFee, uint256 holdersFee, uint256 totalFee);
	event TimeCheck(uint256 secondsInAEST, uint256 dayOfWeek, uint256 hour, uint256 minute, bool lowerBound, bool upperBound);
	
	constructor() public ERC20(_name, _symbol) {
		dividendTracker = new EquitableGrowthOpportunityDividendTracker();
		dividendTracker.setUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		dividendTracker.setRewardToken(address(this));

		marketingWallet = owner();
		liquidityWallet = owner();
		salaryWallet = owner();
		investingWallet = owner();
        dreamFoundationWallet = owner();

		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //FTM 0xF491e7B69E4244ad4002BC14e878a34207E38c29
		address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
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
        _isAllowedToTradeWhenDisabled[address(dividendTracker)] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(dividendTracker)] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;

		_mint(owner(), initialSupply);
	}

	receive() external payable {}

	// Setters
	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}
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
		require(this.isInLaunch(), "EquitableGrowthOpportunity: Launch is not set");
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
	function updateDividendTracker(address newAddress) external onlyOwner {
		require(newAddress != address(dividendTracker), "EquitableGrowthOpportunity: The dividend tracker already has that address");
		EquitableGrowthOpportunityDividendTracker newDividendTracker = EquitableGrowthOpportunityDividendTracker(payable(newAddress));
		require(newDividendTracker.owner() == address(this), "EquitableGrowthOpportunity: The new dividend tracker must be owned by the EquitableGrowthOpportunity token contract");
		newDividendTracker.excludeFromDividends(address(newDividendTracker));
		newDividendTracker.excludeFromDividends(address(this));
		newDividendTracker.excludeFromDividends(owner());
		newDividendTracker.excludeFromDividends(address(uniswapV2Router));
		newDividendTracker.excludeFromDividends(address(uniswapV2Pair));
		emit DividendTrackerChange(newAddress, address(dividendTracker));
		dividendTracker = newDividendTracker;
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "EquitableGrowthOpportunity: Automated market maker pair is already set to that value");
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
		require(_isExcludedFromFee[account] != excluded, "EquitableGrowthOpportunity: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromDividends(address account) external onlyOwner {
		dividendTracker.excludeFromDividends(account);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "EquitableGrowthOpportunity: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
    function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "EquitableGrowthOpportunity: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
	function blockAccount(address account) external onlyOwner {
		uint256 currentTimestamp = _getNow();
		require(!_isBlocked[account], "EquitableGrowthOpportunity: Account is already blocked");
		if (_isLaunched) {
			require((currentTimestamp - _launchStartTimestamp) < _blockedTimeLimit, "EquitableGrowthOpportunity: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) external onlyOwner {
		require(_isBlocked[account], "EquitableGrowthOpportunity: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setFeeOnWalletTransfers(bool value) external onlyOwner {
		emit FeeOnWalletTransferChange(value, _feeOnWalletTranfers);
		_feeOnWalletTranfers = value;
	}
	function setFeeOnSelectedWalletTransfers(address account, bool value) public onlyOwner {
		require(_feeOnSelectedWalletTransfers[account] != value, "EquitableGrowthOpportunity: The selected wallet is already set to the value ");
		_feeOnSelectedWalletTransfers[account] = value;
		emit FeeOnSelectedWalletTransfersChange(account, value);
	}
	function setWallets(address newLiquidityWallet, address newMarketingWallet, address newSalaryWallet, address newInvestingWallet, address newDreamFoundationWallett) external onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "EquitableGrowthOpportunity: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "EquitableGrowthOpportunity: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
		if(salaryWallet != newSalaryWallet) {
			require(newSalaryWallet != address(0), "EquitableGrowthOpportunity: The salaryWallet cannot be 0");
			emit WalletChange('salaryWallet', newSalaryWallet, salaryWallet);
			salaryWallet = newSalaryWallet;
		}
        if(investingWallet != newInvestingWallet) {
			require(newInvestingWallet != address(0), "EquitableGrowthOpportunity: The investingWallet cannot be 0");
			emit WalletChange('investingWallet', newInvestingWallet, investingWallet);
			investingWallet = newInvestingWallet;
		}
        if(dreamFoundationWallet != newDreamFoundationWallett) {
			require(newDreamFoundationWallett != address(0), "EquitableGrowthOpportunity: The dreamFoundationWallet cannot be 0");
			emit WalletChange('dreamFoundationWallet', newDreamFoundationWallett, dreamFoundationWallet);
			dreamFoundationWallet = newDreamFoundationWallett;
		}
	}
	function setAllFeesToZero() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0, 0);
	}
	function resetAllFees() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.salaryFeeOnBuy,  _default.investingFeeOnBuy, _default.dreamFoundationFeeOnBuy, _default.holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.salaryFeeOnBuy, _default.investingFeeOnBuy, _default.dreamFoundationFeeOnBuy, _default.holdersFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.salaryFeeOnSell, _default.investingFeeOnSell, _default.dreamFoundationFeeOnSell, _default.holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.salaryFeeOnSell, _default.investingFeeOnSell, _default.dreamFoundationFeeOnSell, _default.holdersFeeOnSell);
	}
	// Base fees
	function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _salaryFeeOnBuy, uint256 _investingFeeOnBuy, uint256 _dreamFoundationFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _salaryFeeOnSell, uint256 _investingFeeOnSell, uint256 _dreamFoundationFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
	}
	//Launch2 Fees
	function setLaunch2FeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _salaryFeeOnBuy, uint256 _investingFeeOnBuy, uint256 _dreamFoundationFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_launch2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch2FeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _salaryFeeOnSell, uint256 _investingFeeOnSell, uint256 _dreamFoundationFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_launch2, _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
	}
	//Launch3 Fees
	function setLaunch3FeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _salaryFeeOnBuy, uint256 _investingFeeOnBuy, uint256 _dreamFoundationFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_launch3, _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch3Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _salaryFeeOnBuy, _investingFeeOnBuy, _dreamFoundationFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch3FeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _salaryFeeOnSell, uint256 _investingFeeOnSell, uint256 _dreamFoundationFeeOnSell,  uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_launch3, _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch3Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _salaryFeeOnSell, _investingFeeOnSell, _dreamFoundationFeeOnSell, _holdersFeeOnSell);
	}
	function setUniswapRouter(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "EquitableGrowthOpportunity: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IUniswapV2Router02(newAddress);
		dividendTracker.setUniswapRouter(newAddress);
	}
	function setGasForProcessing(uint256 newValue) external onlyOwner {
		require(newValue != gasForProcessing, "EquitableGrowthOpportunity: Cannot update gasForProcessing to same value");
		emit GasForProcessingChange(newValue, gasForProcessing);
		gasForProcessing = newValue;
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxWalletAmount, "EquitableGrowthOpportunity: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "EquitableGrowthOpportunity: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function setMinimumTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		dividendTracker.setTokenBalanceForDividends(newValue);
	}
    function setDividendToken(address newDividendToken) external onlyOwner {
		require(newDividendToken != dividendToken, "EquitableGrowthOpportunity: Cannot update dividend token to same value");
		require(newDividendToken != address(0), "EquitableGrowthOpportunity: The dividend token cannot be 0");
		require(newDividendToken != address(this), "EquitableGrowthOpportunity: The dividend token cannot be set to the current contract");
		emit DividendTokenChange(newDividendToken, dividendToken);
		dividendToken = newDividendToken;
		dividendTracker.setRewardToken(dividendToken);
	}
	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
	}
	function claimFTMOverflow(uint256 amount) external onlyOwner {
		require(amount < address(this).balance, "EquitableGrowthOpportunity: Cannot send more than contract balance");
		(bool success,) = address(owner()).call{value : amount}("");
		if (success){
			emit ClaimFTMOverflow(amount);
		}
	}

	// Getters
	function isInLaunch() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalLaunchTime =  _launch1.timeInPeriod + _launch2.timeInPeriod + _launch3.timeInPeriod;
		if(_isLaunched && ((currentTimestamp - _launchStartTimestamp) < totalLaunchTime || (block.number - _launchBlockNumber) < _launch1.blocksInPeriod )) {
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
	function getAccountDividendsInfo(address account)
		external view returns (
		address,
		int256,
		int256,
		uint256,
		uint256,
		uint256,
		uint256,
		uint256) {
		return dividendTracker.getAccount(account);
	}
	function getNumberOfDividendTokenHolders() external view returns(uint256) {
		return dividendTracker.getNumberOfTokenHolders();
	}
	function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.salaryFeeOnBuy, _base.investingFeeOnBuy, _base.dreamFoundationFeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.salaryFeeOnSell, _base.investingFeeOnSell, _base.dreamFoundationFeeOnSell, _base.holdersFeeOnSell);
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
			require(isTradingEnabled, "EquitableGrowthOpportunity: Trading is currently disabled.");
			require(_timestampAllowsTrading(currentTimestamp), "EquitableGrowthOpportunity: Trading is currently disabled.");
			require(!_isBlocked[to], "EquitableGrowthOpportunity: Account is blocked");
			require(!_isBlocked[from], "EquitableGrowthOpportunity: Account is blocked");
			
            if (isSelltoLp) {
				require((currentTimestamp - _lastTransactions[from]) > 60, "EquitableGrowthOpportunity: Must wait 60s after selling");
				if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
					require(amount <= maxTxSellAmount, "EquitableGrowthOpportunity: Buy amount exceeds the maxTxSellAmount.");
				}
			}
            if (isBuyFromLp) { 
				require((currentTimestamp - _lastTransactions[to]) > 60, "EquitableGrowthOpportunity: Must wait 60s after buying");
				if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
					require(amount <= maxTxBuyAmount, "EquitableGrowthOpportunity: Buy amount exceeds the maxTxBuyAmount.");
				}
			}
			if (!_isExcludedFromMaxWalletLimit[to]) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "EquitableGrowthOpportunity: Expected wallet amount exceeds the maxWalletAmount.");
			}
		}

		_adjustTaxes(isBuyFromLp, isSelltoLp, _isInLaunch);
		bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

		if (
			isTradingEnabled &&
			canSwap &&
			!_swapping &&
			_totalFee > 0 &&
			automatedMarketMakerPairs[to] &&
			from != liquidityWallet && to != liquidityWallet &&
			from != marketingWallet && to != marketingWallet &&
			from != salaryWallet && to != salaryWallet &&
			from != investingWallet && to != investingWallet &&
            from != dreamFoundationWallet && to != dreamFoundationWallet
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

		super._transfer(from, to, amount);

		if (isSelltoLp) {
			_lastTransactions[from] = currentTimestamp;
		}
        if (isBuyFromLp) {
			_lastTransactions[to] = currentTimestamp;
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
	function _timestampAllowsTrading(uint256 currentTimestamp) private returns(bool) {
		bool isAllowed = true;
		uint256 secondsInAEST = currentTimestamp + 36000;
		uint256 _days = secondsInAEST / 24 * 60 * 60;
		uint256 dayOfWeek = (_days + 3) % 7 + 1;
		// if (dayOfWeek > 5) {
			// isAllowed = false; 
			// return isAllowed;
		// }
		uint256 secs1 = secondsInAEST % (24 * 60 * 60);
        uint256 hour = secs1 / (60 * 60);
		uint256 secs2 = secondsInAEST % (60 * 60);
        uint256 minute = secs2 / 60;
		bool lowerBound = hour > 9 || (hour == 9 && minute >= 30);
		bool upperBound = hour <= 16;
		// if (!lowerBound || !upperBound) {
			// isAllowed = false; 
		// }
		emit TimeCheck(secondsInAEST, dayOfWeek, hour, minute, lowerBound, upperBound);
		return isAllowed;
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, bool isLaunching) private {
		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;
		_liquidityFee = 0;
		_marketingFee = 0;
		_salaryFee = 0;
		_investingFee = 0;
		_dreamFoundationFee = 0;
		_holdersFee = 0;

		if (isBuyFromLp) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_salaryFee = _base.salaryFeeOnBuy;
			_investingFee = _base.investingFeeOnBuy;
			_dreamFoundationFee = _base.dreamFoundationFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;

			if(isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnBuy;
					_marketingFee = _launch1.marketingFeeOnBuy;
					_salaryFee = _launch1.salaryFeeOnBuy;
					_investingFee = _launch1.investingFeeOnBuy;
					_dreamFoundationFee = _launch1.dreamFoundationFeeOnBuy;
					_holdersFee = _launch1.holdersFeeOnBuy;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnBuy;
					_marketingFee = _launch2.marketingFeeOnBuy;
					_salaryFee = _launch2.salaryFeeOnBuy;
					_investingFee = _launch2.investingFeeOnBuy;
					_dreamFoundationFee = _launch2.dreamFoundationFeeOnBuy;
					_holdersFee = _launch2.holdersFeeOnBuy;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnBuy;
					_marketingFee = _launch3.marketingFeeOnBuy;
					_salaryFee = _launch3.salaryFeeOnBuy;
					_investingFee = _launch3.investingFeeOnBuy;
					_dreamFoundationFee = _launch3.dreamFoundationFeeOnBuy;
					_holdersFee = _launch3.holdersFeeOnBuy;
				}
			}
		}
		if (isSelltoLp) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_salaryFee = _base.salaryFeeOnSell;
			_investingFee = _base.investingFeeOnSell;
			_dreamFoundationFee = _base.dreamFoundationFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;

			if(isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnSell;
					_marketingFee = _launch1.marketingFeeOnSell;
					_salaryFee = _launch1.salaryFeeOnSell;
					_investingFee = _launch1.investingFeeOnSell;
					_dreamFoundationFee = _launch1.dreamFoundationFeeOnSell;
					_holdersFee = _launch1.holdersFeeOnSell;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnSell;
					_marketingFee = _launch2.marketingFeeOnSell;
					_salaryFee = _launch2.salaryFeeOnSell;
					_investingFee = _launch2.investingFeeOnSell;
					_dreamFoundationFee = _launch2.dreamFoundationFeeOnSell;
					_holdersFee = _launch2.holdersFeeOnSell;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnSell;
					_marketingFee = _launch3.marketingFeeOnSell;
					_salaryFee = _launch3.salaryFeeOnSell;
					_investingFee = _launch3.investingFeeOnSell;
					_dreamFoundationFee = _launch3.dreamFoundationFeeOnSell;
					_holdersFee = _launch3.holdersFeeOnSell;
				}
			}
		}
		if (!isSelltoLp && !isBuyFromLp && _feeOnWalletTranfers) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_salaryFee = _base.salaryFeeOnBuy;
			_investingFee = _base.investingFeeOnBuy;
			_dreamFoundationFee = _base.dreamFoundationFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;
		}
		_totalFee = _liquidityFee + _marketingFee + _salaryFee + _investingFee + _dreamFoundationFee + _holdersFee;
		emit FeesApplied(_liquidityFee, _marketingFee, _salaryFee, _investingFee, _dreamFoundationFee, _holdersFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnSell,
		uint256 _marketingFeeOnSell,
		uint256 _salaryFeeOnSell,
		uint256 _investingFeeOnSell,
		uint256 _dreamFoundationFeeOnSell,
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
		if (map.salaryFeeOnSell != _salaryFeeOnSell) {
			emit CustomTaxPeriodChange(_salaryFeeOnSell, map.salaryFeeOnSell, 'salaryFeeOnSell', map.periodName);
			map.salaryFeeOnSell = _salaryFeeOnSell;
		}
		if (map.investingFeeOnSell != _investingFeeOnSell) {
			emit CustomTaxPeriodChange(_investingFeeOnSell, map.investingFeeOnSell, 'investingFeeOnSell', map.periodName);
			map.investingFeeOnSell = _investingFeeOnSell;
		}
		if (map.dreamFoundationFeeOnSell != _dreamFoundationFeeOnSell) {
			emit CustomTaxPeriodChange(_dreamFoundationFeeOnSell, map.dreamFoundationFeeOnSell, 'dreamFoundationFeeOnSell', map.periodName);
			map.dreamFoundationFeeOnSell = _dreamFoundationFeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnBuy,
		uint256 _marketingFeeOnBuy,
		uint256 _salaryFeeOnBuy,
		uint256 _investingFeeOnBuy,
		uint256 _dreamFoundationFeeOnBuy,
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
		if (map.salaryFeeOnBuy != _salaryFeeOnBuy) {
			emit CustomTaxPeriodChange(_salaryFeeOnBuy, map.salaryFeeOnBuy, 'salaryFeeOnBuy', map.periodName);
			map.salaryFeeOnBuy = _salaryFeeOnBuy;
		}
		if (map.investingFeeOnBuy != _investingFeeOnBuy) {
			emit CustomTaxPeriodChange(_investingFeeOnBuy, map.investingFeeOnBuy, 'investingFeeOnBuy', map.periodName);
			map.investingFeeOnBuy = _investingFeeOnBuy;
		}
		if (map.dreamFoundationFeeOnBuy != _dreamFoundationFeeOnBuy) {
			emit CustomTaxPeriodChange(_dreamFoundationFeeOnBuy, map.dreamFoundationFeeOnBuy, 'dreamFoundationFeeOnBuy', map.periodName);
			map.dreamFoundationFeeOnBuy = _dreamFoundationFeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialFTMBalance = address(this).balance;
		uint256 totalFeePrior = _totalFee;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
		uint256 amountForDreamFoundation = contractBalance * _dreamFoundationFee / _totalFee;
		uint256 amountForHolders = contractBalance * _holdersFee / _totalFee;
		uint256 amountToSwapForFTM = contractBalance - (amountToLiquify + amountForHolders + amountForDreamFoundation);

		_swapTokensForFTM(amountToSwapForFTM);

		uint256 FTMBalanceAfterSwap = address(this).balance - initialFTMBalance;
		uint256 totalFTMFee = _totalFee - (_liquidityFee / 2);
		uint256 amountFTMLiquidity = FTMBalanceAfterSwap * _liquidityFee / totalFTMFee / 2;
		uint256 amountFTMMarketing = FTMBalanceAfterSwap * _marketingFee / totalFTMFee;
		uint256 amountFTMSalary = FTMBalanceAfterSwap * _salaryFee / totalFTMFee;
        uint256 amountFTMInvesting = FTMBalanceAfterSwap - (amountFTMLiquidity + amountFTMMarketing + amountFTMSalary);

		payable(marketingWallet).transfer(amountFTMMarketing);
		payable(salaryWallet).transfer(amountFTMSalary);
        payable(investingWallet).transfer(amountFTMInvesting);

		_swapAndTransferTokensForFETH(amountForDreamFoundation);

		if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountFTMLiquidity);
			emit SwapAndLiquify(amountToSwapForFTM, amountFTMLiquidity, amountToLiquify);
		}

		(bool success) = IERC20(address(this)).transfer(address(dividendTracker), amountForHolders);
		if(success) {
			dividendTracker.distributeDividendsUsingAmount(amountForHolders);
			emit DividendsSent(amountForHolders);
		}
		_totalFee = totalFeePrior;
	}
	function _swapAndTransferTokensForFETH(uint256 tokenAmount) private {		
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();
		path[2] = address(FETH);
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(dreamFoundationWallet),
			block.timestamp
		);
	}
	function _swapTokensForFTM(uint256 tokenAmount) private {
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

contract EquitableGrowthOpportunityDividendTracker is DividendPayingToken {
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

	constructor() public DividendPayingToken("EquitableGrowthOpportunity_Dividend_Tracker", "EquitableGrowthOpportunity_Dividend_Tracker") {
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
		require(false, "EquitableGrowthOpportunity_Dividend_Tracker: No transfers allowed");
	}
	function excludeFromDividends(address account) external onlyOwner {
		require(!excludedFromDividends[account]);
		excludedFromDividends[account] = true;
		_setBalance(account, 0);
		tokenHoldersMap.remove(account);
		emit ExcludeFromDividends(account);
	}
	function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		require(minimumTokenBalanceForDividends != newValue, "EquitableGrowthOpportunity_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
		minimumTokenBalanceForDividends = newValue;
	}
	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
		require(newClaimWait >= 3600 && newClaimWait <= 86400, "EquitableGrowthOpportunity_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
		require(newClaimWait != claimWait, "EquitableGrowthOpportunity_Dividend_Tracker: Cannot update claimWait to same value");
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