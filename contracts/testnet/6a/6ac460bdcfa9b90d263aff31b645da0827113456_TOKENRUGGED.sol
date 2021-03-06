/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

library IterableMapping {
	struct Map {
		address[] keys;
		mapping(address => uint256) values;
		mapping(address => uint256) indexOf;
		mapping(address => bool) inserted;
	}

	function get(Map storage map, address key) public view returns (uint256) {
		return map.values[key];
	}

	function getIndexOfKey(Map storage map, address key) public view returns (int256) {
		if (!map.inserted[key]) {
			return -1;
		}
		return int256(map.indexOf[key]);
	}

	function getKeyAtIndex(Map storage map, uint256 index) public view returns (address) {
		return map.keys[index];
	}

	function size(Map storage map) public view returns (uint256) {
		return map.keys.length;
	}

	function set(
		Map storage map,
		address key,
		uint256 val
	) public {
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

		uint256 index = map.indexOf[key];
		uint256 lastIndex = map.keys.length - 1;
		address lastKey = map.keys[lastIndex];

		map.indexOf[lastKey] = index;
		delete map.indexOf[key];

		map.keys[index] = lastKey;
		map.keys.pop();
	}
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

	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library SafeMathInt {
	int256 private constant MIN_INT256 = int256(1) << 255;
	int256 private constant MAX_INT256 = ~(int256(1) << 255);

	function mul(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a * b;

		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}

	function div(int256 a, int256 b) internal pure returns (int256) {
		require(b != -1 || a != MIN_INT256);

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
	function dividendOf(address _owner) external view returns (uint256);

	function withdrawDividend() external;

	event DividendsDistributed(address indexed from, uint256 weiAmount);

	event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

interface DividendPayingTokenOptionalInterface {
	function withdrawableDividendOf(address _owner) external view returns (uint256);

	function withdrawnDividendOf(address _owner) external view returns (uint256);

	function accumulativeDividendOf(address _owner) external view returns (uint256);
}

interface IUniswapV2Pair {
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint256);

	function balanceOf(address owner) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 value) external returns (bool);

	function transfer(address to, uint256 value) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint256);

	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	event Mint(address indexed sender, uint256 amount0, uint256 amount1);
	event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
	event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint256);

	function factory() external view returns (address);

	function token0() external view returns (address);

	function token1() external view returns (address);

	function getReserves()
		external
		view
		returns (
			uint112 reserve0,
			uint112 reserve1,
			uint32 blockTimestampLast
		);

	function price0CumulativeLast() external view returns (uint256);

	function price1CumulativeLast() external view returns (uint256);

	function kLast() external view returns (uint256);

	function mint(address to) external returns (uint256 liquidity);

	function burn(address to) external returns (uint256 amount0, uint256 amount1);

	function swap(
		uint256 amount0Out,
		uint256 amount1Out,
		address to,
		bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

interface IUniswapV2Factory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

	function feeTo() external view returns (address);

	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);

	function allPairs(uint256) external view returns (address pair);

	function allPairsLength() external view returns (uint256);

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
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
		external
		returns (
			uint256 amountA,
			uint256 amountB,
			uint256 liquidity
		);

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

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

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

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this;
		return msg.data;
	}
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
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

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	address public immutable BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

	uint256 internal constant magnitude = 2**128;

	uint256 internal magnifiedDividendPerShare;

	mapping(address => int256) internal magnifiedDividendCorrections;
	mapping(address => uint256) internal withdrawnDividends;

	uint256 public totalDividendsDistributed;

	constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

	function distributeBUSDDividends(uint256 amount) public onlyOwner {
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
			bool success = IERC20(BUSD).transfer(user, _withdrawableDividend);

			if (!success) {
				withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
				return 0;
			}

			return _withdrawableDividend;
		}

		return 0;
	}

	function dividendOf(address _owner) public view override returns (uint256) {
		return withdrawableDividendOf(_owner);
	}

	function withdrawableDividendOf(address _owner) public view override returns (uint256) {
		return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
	}

	function withdrawnDividendOf(address _owner) public view override returns (uint256) {
		return withdrawnDividends[_owner];
	}

	function accumulativeDividendOf(address _owner) public view override returns (uint256) {
		return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe().add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
	}

	function _transfer(
		address from,
		address to,
		uint256 value
	) internal virtual override {
		require(false);

		int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
		magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
		magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
	}

	function _mint(address account, uint256 value) internal override {
		super._mint(account, value);

		magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
	}

	function _burn(address account, uint256 value) internal override {
		super._burn(account, value);

		magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
	}

	function _setBalance(address account, uint256 newBalance) internal {
		uint256 currentBalance = balanceOf(account);

		if (newBalance > currentBalance) {
			uint256 mintAmount = newBalance.sub(currentBalance);
			_mint(account, mintAmount);
		} else if (newBalance < currentBalance) {
			uint256 burnAmount = currentBalance.sub(newBalance);
			_burn(account, burnAmount);
		}
	}
}

contract TKRDividendTracker is Ownable, DividendPayingToken {
	using SafeMath for uint256;
	using SafeMathInt for int256;
	using IterableMapping for IterableMapping.Map;

	IterableMapping.Map private tokenHoldersMap;
	uint256 public lastProcessedIndex;

	mapping(address => bool) public excludedFromDividends;

	mapping(address => uint256) public lastClaimTimes;

	uint256 public claimWait;
	uint256 public minimumTokenBalanceForDividends;

	event ExcludeFromDividends(address indexed account);
	event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

	event Claim(address indexed account, uint256 amount, bool indexed automatic);

	constructor() DividendPayingToken("TOKEN RUGGED Dividend Tracker", "TKRDT") {
		claimWait = 3600;
		minimumTokenBalanceForDividends = 1000000 * (10**18);
	}

	function _transfer(
		address,
		address,
		uint256
	) internal pure override {
		require(false, "TKRDT: No transfers allowed");
	}

	function withdrawDividend() public pure override {
		require(false, "TKRDT: withdrawDividend disabled. Use the 'claim' function on the main TKR contract.");
	}

	function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
		require(_newMinimumBalance != minimumTokenBalanceForDividends, "New minimum balance for dividend cannot be same as current minimum balance");
		minimumTokenBalanceForDividends = _newMinimumBalance * (10**18);
	}

	function excludeFromDividends(address account) external onlyOwner {
		require(!excludedFromDividends[account]);
		excludedFromDividends[account] = true;

		_setBalance(account, 0);
		tokenHoldersMap.remove(account);

		emit ExcludeFromDividends(account);
	}

	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
		require(newClaimWait >= 3600 && newClaimWait <= 86400, "TKRDT: claimWait must be updated to between 1 and 24 hours");
		require(newClaimWait != claimWait, "TKRDT: Cannot update claimWait to same value");
		emit ClaimWaitUpdated(newClaimWait, claimWait);
		claimWait = newClaimWait;
	}

	function getLastProcessedIndex() external view returns (uint256) {
		return lastProcessedIndex;
	}

	function getNumberOfTokenHolders() external view returns (uint256) {
		return tokenHoldersMap.keys.length;
	}

	function getAccount(address _account)
		public
		view
		returns (
			address account,
			int256 index,
			int256 iterationsUntilProcessed,
			uint256 withdrawableDividends,
			uint256 totalDividends,
			uint256 lastClaimTime,
			uint256 nextClaimTime,
			uint256 secondsUntilAutoClaimAvailable
		)
	{
		account = _account;

		index = tokenHoldersMap.getIndexOfKey(account);

		iterationsUntilProcessed = -1;

		if (index >= 0) {
			if (uint256(index) > lastProcessedIndex) {
				iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
			} else {
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
		public
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
		if (index >= tokenHoldersMap.size()) {
			return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
		}

		address account = tokenHoldersMap.getKeyAtIndex(index);

		return getAccount(account);
	}

	function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
		if (lastClaimTime > block.timestamp) {
			return false;
		}

		return block.timestamp.sub(lastClaimTime) >= claimWait;
	}

	function setBalance(address payable account, uint256 newBalance) external onlyOwner {
		if (excludedFromDividends[account]) {
			return;
		}

		if (newBalance >= minimumTokenBalanceForDividends) {
			_setBalance(account, newBalance);
			tokenHoldersMap.set(account, newBalance);
		} else {
			_setBalance(account, 0);
			tokenHoldersMap.remove(account);
		}

		processAccount(account, true);
	}

	function process(uint256 gas)
		public
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

		if (numberOfTokenHolders == 0) {
			return (0, 0, lastProcessedIndex);
		}

		uint256 _lastProcessedIndex = lastProcessedIndex;

		uint256 gasUsed = 0;

		uint256 gasLeft = gasleft();

		uint256 iterations = 0;
		uint256 claims = 0;

		while (gasUsed < gas && iterations < numberOfTokenHolders) {
			_lastProcessedIndex++;

			if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
				_lastProcessedIndex = 0;
			}

			address account = tokenHoldersMap.keys[_lastProcessedIndex];

			if (canAutoClaim(lastClaimTimes[account])) {
				if (processAccount(payable(account), true)) {
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

		lastProcessedIndex = _lastProcessedIndex;

		return (iterations, claims, lastProcessedIndex);
	}

	function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
		uint256 amount = _withdrawDividendOfUser(account);

		if (amount > 0) {
			lastClaimTimes[account] = block.timestamp;
			emit Claim(account, amount, automatic);
			return true;
		}

		return false;
	}
}

contract TOKENRUGGED is ERC20, Ownable {
	using SafeMath for uint256;
	IUniswapV2Router02 public uniswapV2Router;
	address public uniswapV2Pair;
	TKRDividendTracker public dividendTracker;
	address public deadWallet = 0x000000000000000000000000000000000000dEaD;
	address public immutable BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	address public marketingWallet = 0xFba1D5ADe6a6b1075Eb48Ec17509D2F0856474Ee;
	uint256 public maxWalletBalance = 1500000000 * (10**18);
	uint256 public swapTokensAtAmount = 1000000 * (10**18);
	uint256 public gasForProcessing = 600000;
	uint256 public marketingFee = 9;
	uint256 public liquidityFee = 1;
	uint256 public BUSDRewardsFee = 2;
	uint256 public totalFees = marketingFee.add(liquidityFee).add(BUSDRewardsFee);
	uint256 public sellIncreaseFactor = 200;
	uint256 public quickSellIncreaseFactor = 400;
	uint256 public quickSellInterval = 24;
	bool public walletCheckEnabled = true;
	bool private swapping;
	bool private canSwap;
	bool private takeFee;
	bool private excludedAccount;
	uint256 private contractTokenBalance;
	uint256 private adjustedSellIncreaseFactor;
	uint256 private marketingTokens;
	uint256 private liquidityTokens;
	uint256 private BUSDRewardsTokens;
	uint256 private fees;
	mapping(address => bool) private _automatedMarketMakerPairs;
	mapping(address => bool) private _isBlacklisted;
	mapping(address => bool) private _isExcludedFromFees;
	mapping(address => uint256) private _quickSell;
	event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
	event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
	event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
	event SendDividends(uint256 tokensSwapped, uint256 amount);
	event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

	constructor() ERC20("TOKEN RUGGED", "TKR") {
		dividendTracker = new TKRDividendTracker();
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
		address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);
		dividendTracker.excludeFromDividends(address(dividendTracker));
		dividendTracker.excludeFromDividends(address(_uniswapV2Router));
		dividendTracker.excludeFromDividends(address(this));
		dividendTracker.excludeFromDividends(owner());
		dividendTracker.excludeFromDividends(deadWallet);
		_isExcludedFromFees[address(this)] = true;
		_isExcludedFromFees[owner()] = true;
		_isExcludedFromFees[deadWallet] = true;
		_mint(owner(), 100000000000 * (10**18));
	}

	receive() external payable {}

	function manualWithdrawTokens() external {
		require(_msgSender() == marketingWallet || _msgSender() == owner(), "TKR: Only marketingWallet can call this function");
		if (balanceOf(address(this)) > 0) {
			swapTokensForBUSD(balanceOf(address(this)));
			uint256 BUSDBalance = IERC20(BUSD).balanceOf(address(this));
			IERC20(BUSD).transfer(marketingWallet, BUSDBalance);
		}
	}

	function manualWithdrawBNB() external {
		require(_msgSender() == marketingWallet || _msgSender() == owner(), "TKR: Only marketingWallet can call this function");
		if (address(this).balance > 0) {
			payable(marketingWallet).transfer(address(this).balance);
		}
	}

	function updateDividendTracker(address newAddress) external onlyOwner {
		require(newAddress != address(dividendTracker), "TKR: The dividend tracker already has that address");
		TKRDividendTracker newDividendTracker = TKRDividendTracker(payable(newAddress));
		require(newDividendTracker.owner() == address(this), "TKR: The new dividend tracker must be owned by the TKR token contract");
		newDividendTracker.excludeFromDividends(address(newDividendTracker));
		newDividendTracker.excludeFromDividends(address(this));
		newDividendTracker.excludeFromDividends(owner());
		newDividendTracker.excludeFromDividends(address(uniswapV2Router));
		emit UpdateDividendTracker(newAddress, address(dividendTracker));
		dividendTracker = newDividendTracker;
	}

	function updateUniswapV2Router(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "TKR: The router already has that address");
		emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
		uniswapV2Router = IUniswapV2Router02(newAddress);
		address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
		uniswapV2Pair = _uniswapV2Pair;
	}

	function blacklistAddress(address account, bool value) external onlyOwner {
		require(value != _isBlacklisted[account], "TKR: Cannot update to same value");
		_isBlacklisted[account] = value;
	}

	function excludeFromFees(address account, bool value) external onlyOwner {
		require(value != _isExcludedFromFees[account], "TKR: Cannot update to same value");
		_isExcludedFromFees[account] = value;
	}

	function setQuickSell(address account, uint256 value) external onlyOwner {
		require(value != _quickSell[account], "TKR: Cannot update to same value");
		_quickSell[account] = value;
	}

	function excludeMultipleAccountsFromFees(address[] calldata accounts, bool value) external onlyOwner {
		for (uint256 i = 0; i < accounts.length; i++) {
			_isExcludedFromFees[accounts[i]] = value;
		}
		emit ExcludeMultipleAccountsFromFees(accounts, value);
	}

	function setMarketingWallet(address payable wallet) external onlyOwner {
		require(wallet != marketingWallet, "TKR: Cannot update to same value");
		_isExcludedFromFees[marketingWallet] = false;
		_isExcludedFromFees[wallet] = true;
		marketingWallet = wallet;
	}

	function setMaxWalletBalance(uint256 value) external onlyOwner {
		require((value* (10**18)) != maxWalletBalance, "TKR: Cannot update to same value");
		maxWalletBalance = value * (10**18);
	}

	function setSellIncreaseFactor(uint256 value) external onlyOwner {
		require(value >= 100, "TKR: sellIncreaseFactor must be greater than or equal to 100");
		require(value != sellIncreaseFactor, "TKR: Cannot update to same value");
		sellIncreaseFactor = value;
	}

	function setQuickSellIncreaseFactor(uint256 value) external onlyOwner {
		require(value >= 100, "TKR: quickSellIncreaseFactor must be greater than or equal to 100");
		require(value != quickSellIncreaseFactor, "TKR: Cannot update to same value");
		quickSellIncreaseFactor = value;
	}

	function setQuickSellInterval(uint256 value) external onlyOwner {
		require(value != quickSellInterval, "TKR: Cannot update to same value");
		quickSellInterval = value;
	}

	function setWalletCheckEnabled(bool value) external onlyOwner {
		require(value != walletCheckEnabled, "TKR: Cannot update to same value");
		walletCheckEnabled = value;
	}

	function setSwapTokensAtAmount(uint256 value) external onlyOwner {
		require((value* (10**18)) != swapTokensAtAmount, "TKR: Cannot update to same value");
		swapTokensAtAmount = value * (10**18);
	}

	function setMarketingFee(uint256 value) external onlyOwner {
		require(value != marketingFee, "TKR: Cannot update to same value");
		marketingFee = value;
		totalFees = marketingFee.add(liquidityFee).add(BUSDRewardsFee);
	}

	function setLiquidityFee(uint256 value) external onlyOwner {
		require(value != liquidityFee, "TKR: Cannot update to same value");
		liquidityFee = value;
		totalFees = marketingFee.add(liquidityFee).add(BUSDRewardsFee);
	}

	function setBUSDRewardsFee(uint256 value) external onlyOwner {
		require(value != BUSDRewardsFee, "TKR: Cannot update to same value");
		BUSDRewardsFee = value;
		totalFees = marketingFee.add(liquidityFee).add(BUSDRewardsFee);
	}

	function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
		require(pair != uniswapV2Pair, "TKR: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
		_setAutomatedMarketMakerPair(pair, value);
	}

	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(value != _automatedMarketMakerPairs[pair], "TKR: Cannot update to same value");
		_automatedMarketMakerPairs[pair] = value;
		if (value) {
			dividendTracker.excludeFromDividends(pair);
		}
		emit SetAutomatedMarketMakerPair(pair, value);
	}

	function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
		dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
	}

	function updateGasForProcessing(uint256 newValue) external onlyOwner {
		require(newValue >= 300000 && newValue <= 900000, "TKR: gasForProcessing must be between 300000 and 900000");
		require(newValue != gasForProcessing, "TKR: Cannot update to same value");
		emit GasForProcessingUpdated(newValue, gasForProcessing);
		gasForProcessing = newValue;
	}

	function updateClaimWait(uint256 claimWait) external onlyOwner {
		dividendTracker.updateClaimWait(claimWait);
	}

	function excludeFromDividends(address account) external onlyOwner {
		dividendTracker.excludeFromDividends(account);
	}

	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
	}

	function processDividendTracker(uint256 gas) external onlyOwner {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
	}

	function getRemainingSupply() public view returns (uint256) {
		return totalSupply().sub(balanceOf(deadWallet));
	}

	function getClaimWait() external view returns (uint256) {
		return dividendTracker.claimWait();
	}

	function getTotalDividendsDistributed() external view returns (uint256) {
		return dividendTracker.totalDividendsDistributed();
	}

	function isBlackListed(address account) public view returns (bool) {
		return _isBlacklisted[account];
	}

	function isExcludedFromFees(address account) public view returns (bool) {
		return _isExcludedFromFees[account];
	}

	function getQuickSell(address account) public view returns (uint256) {
		return _quickSell[account];
	}

	function getAutomatedMarketMakerPairs(address account) public view returns (bool) {
		return _automatedMarketMakerPairs[account];
	}

	function withdrawableDividendOf(address account) public view returns (uint256) {
		return dividendTracker.withdrawableDividendOf(account);
	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function getAccountDividendsInfo(address account)
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

	function getAccountDividendsInfoAtIndex(uint256 index)
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

	function getLastProcessedIndex() external view returns (uint256) {
		return dividendTracker.getLastProcessedIndex();
	}

	function getNumberOfDividendTokenHolders() external view returns (uint256) {
		return dividendTracker.getNumberOfTokenHolders();
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal override {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address");
		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}
		excludedAccount = _isExcludedFromFees[from] || _isExcludedFromFees[to];
		adjustedSellIncreaseFactor = sellIncreaseFactor;
		if (!excludedAccount) {
			if (walletCheckEnabled && _automatedMarketMakerPairs[from]) {
				require(balanceOf(to).add(amount) <= maxWalletBalance, "Wallet balance is exceeding maxWalletBalance");
			}
			if (quickSellInterval > 0) {
				if (_automatedMarketMakerPairs[from]) {
					_quickSell[to] = block.timestamp + (quickSellInterval * 1 hours);
				} else if (_automatedMarketMakerPairs[to] && _quickSell[from] > 0 && block.timestamp < _quickSell[from]) {
					adjustedSellIncreaseFactor = quickSellIncreaseFactor;
				}
			}
		}
		contractTokenBalance = balanceOf(address(this));
		canSwap = contractTokenBalance >= swapTokensAtAmount;
		if (canSwap && !swapping && _automatedMarketMakerPairs[to]) {
			swapping = true;
			if (marketingFee > 0) {
				marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
				swapAndSendToFee(marketingTokens);
			}
			if (liquidityFee > 0) {
				liquidityTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
				swapAndLiquify(liquidityTokens);
			}
			if (BUSDRewardsFee > 0) {
				BUSDRewardsTokens = contractTokenBalance.mul(BUSDRewardsFee).div(totalFees);
				swapAndSendDividends(BUSDRewardsTokens);
			}
			swapping = false;
		}
		takeFee = !swapping && !excludedAccount;
		if (takeFee) {
			fees = amount.mul(totalFees).div(100);
			if (_automatedMarketMakerPairs[to]) {
				fees = fees.mul(adjustedSellIncreaseFactor).div(100);
			}
			amount = amount.sub(fees);
			super._transfer(from, address(this), fees);
		}
		super._transfer(from, to, amount);
		try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
		try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
		if (!swapping && BUSDRewardsFee > 0) {
			try dividendTracker.process(gasForProcessing) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
				emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gasForProcessing, tx.origin);
			} catch {}
		}
	}

	function swapAndSendToFee(uint256 tokens) private {
		uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));
		swapTokensForBUSD(tokens);
		uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
		IERC20(BUSD).transfer(marketingWallet, newBalance);
	}

	function swapAndLiquify(uint256 tokens) private {
		uint256 half = tokens.div(2);
		uint256 otherHalf = tokens.sub(half);
		uint256 initialBalance = address(this).balance;
		swapTokensForBNB(half);
		uint256 newBalance = address(this).balance.sub(initialBalance);
		addLiquidity(otherHalf, newBalance);
		emit SwapAndLiquify(half, newBalance, otherHalf);
	}

	function swapTokensForBNB(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
	}

	function swapTokensForBUSD(uint256 tokenAmount) private {
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();
		path[2] = BUSD;
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
	}

	function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.addLiquidityETH{ value: bnbAmount }(address(this), tokenAmount, 0, 0, marketingWallet, block.timestamp);
	}

	function swapAndSendDividends(uint256 tokens) private {
		swapTokensForBUSD(tokens);
		uint256 dividends = IERC20(BUSD).balanceOf(address(this));
		bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);
		if (success) {
			dividendTracker.distributeBUSDDividends(dividends);
			emit SendDividends(tokens, dividends);
		}
	}
}