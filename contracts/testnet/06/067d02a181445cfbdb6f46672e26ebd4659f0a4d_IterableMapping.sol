/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

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

	constructor ()  {
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


/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
///  to token holders as dividends and allows token holders to withdraw their dividends.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;
	
	// With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
	// For more discussion about choosing the value of `magnitude`,
	//  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
	uint256 constant internal magnitude = 2**128;
	uint256 internal magnifiedDividendPerShare;
	uint256 public totalDividendsDistributed;
	address public rewardToken;
	IUniswapV2Router02 public uniswapV2Router;

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

	constructor(string memory _name, string memory _symbol)  ERC20(_name, _symbol) {}

	receive() external payable {
		distributeDividends();
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
			if (rewardToken == address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)) {
				(bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
				if(!success) {
					withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
					return 0;
				}
				return _withdrawableDividend;
			} else {
				return swapBNBForTokensAndWithdrawDividend(user, _withdrawableDividend);
			}
		}
		return 0;
	}
	function swapBNBForTokensAndWithdrawDividend(address holder, uint256 bnbAmount) private returns(uint256) {
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

contract Powerlabs is Ownable, ERC20 {
	using SafeMath for uint256;

	IUniswapV2Router02 public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private constant _name = "Powerlabs";
	string private constant _symbol = "PWL";
	uint8 private constant _decimals = 9;

	PowerlabsDividendTracker public dividendTracker;
	
	bool public isTradingEnabled;
	uint256 private _tradingPausedTimestamp;

	// initialSupply
	uint256 constant initialSupply = 1000000000 * (10**9);

	// max wallet is 1.5% of initialSupply
	uint256 public maxWalletAmount = initialSupply * 150 / 10000;
	
	// max buy and sell tx is 0.2% of initialSupply
	uint256 public maxTxAmount = initialSupply * 20 / 10000;

	bool private _swapping;
	uint256 public minimumTokensBeforeSwap = 250000000 * (10**9);
	uint256 public gasForProcessing = 300000;
	
	address public dividendToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //BUSD

	address public stakingAddress;
	address public marketingWallet;
	address public liquidityWallet;
	address public devWallet;
	address public buyBackWallet;

	uint256 private _blockTracker;
	address public mintAddress;
	uint256 public mintAmount;
	bool public mintOnBlockEmission;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint256 liquidityFeeOnBuy;
		uint256 liquidityFeeOnSell;
		uint256 marketingFeeOnBuy;
		uint256 marketingFeeOnSell;
		uint256 devFeeOnBuy;
		uint256 devFeeOnSell;
		uint256 buyBackFeeOnBuy;
		uint256 buyBackFeeOnSell;
		uint256 stakingFeeOnBuy;
		uint256 stakingFeeOnSell;
		uint256 holdersFeeOnBuy;
		uint256 holdersFeeOnSell;
	}

	// Launch taxes
	bool private _isLaunched;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',3,0,3,100,3,0,1,0,1,0,1,0,4,0);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,3,5,3,5,1,5,1,5,1,1,4,10);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,82800,3,5,3,10,1,2,1,3,1,1,4,5);

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,3,3,3,4,1,1,1,2,1,1,4,4);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,3,3,3,4,1,1,1,2,1,1,4,4);

	// Golden Hour taxes
	uint256 private _goldenHourStartTimestamp;
	CustomTaxPeriod private _golden1 = CustomTaxPeriod('golden1',0,3600,0,5,0,10,0,1,0,4,0,1,3,10);
	CustomTaxPeriod private _golden2 = CustomTaxPeriod('golden2',0,3600,3,2,3,5,1,1,1,4,1,1,4,10);

	uint256 private constant _blockedTimeLimit = 86400;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => uint256) private _buyTimesInLaunch;

	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _devFee;
	uint256 private _buyBackFee;
	uint256 private _stakingFee;
	uint256 private _holdersFee;
	uint256 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event DividendTrackerChange(address indexed newAddress, address indexed oldAddress);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
	event StakingAddressChange(address indexed newStakingAddress, address indexed oldStakingAddress);
	event GasForProcessingChange(uint256 indexed newValue, uint256 indexed oldValue);
	event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 devFee, uint256 buyBackFee, uint256 stakingFee, uint256 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
	event GoldenHourChange(bool indexed newValue, bool indexed oldValue);
	event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);	
	event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
	event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountForDividendsChange(uint256 indexed newValue, uint256 indexed oldValue);
	event DividendsSent(uint256 tokensSwapped);
	event StakingTokensSent(uint256 tokensSent);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
    event ClaimBNBOverflow(uint256 amount);
	event DividendTokenChange(address newDividendToken, address dividendToken);
	event MintOnEmission(address mintAddress, uint256 mintAmount, uint256 blockTracker, uint256 blockNumber);
	event ProcessedDividendTracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed automatic,
		uint256 gas,
		address indexed processor
	);
	event FeesApplied(uint256 liquidityFee, uint256 marketingFee, uint256 devFee, uint256 buyBackFee, uint256 stakingFee, uint256 holdersFee, uint256 totalFee);

	constructor()  ERC20(_name, _symbol) {
		dividendTracker = new PowerlabsDividendTracker();
		dividendTracker.setUniswapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        dividendTracker.setRewardToken(dividendToken);

		marketingWallet = owner();
		liquidityWallet = owner();
		devWallet = owner();
		buyBackWallet = owner();
		stakingAddress = owner();

		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Mainnet
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
	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}
	function _getNow() private view returns (uint256) {
		return block.timestamp;
	}
	function launch() public onlyOwner {
		_launchStartTimestamp = _getNow();
		_launchBlockNumber = block.number;
		isTradingEnabled = true;
		_isLaunched = true;
	}
	function cancelLaunch() public onlyOwner {
		require(this.isInLaunch(), "Powerlabs: Launch is not set");
		_launchStartTimestamp = 0;
		_launchBlockNumber = 0;
		_isLaunched = false;
	}
	function activateTrading() public onlyOwner {
		isTradingEnabled = true;
	}
	function deactivateTrading() public onlyOwner {
		isTradingEnabled = false;
		_tradingPausedTimestamp = _getNow();
	}
	function activateMintOnBlockEmission(address _mintAddress, uint256 _mintAmount) public onlyOwner {
	    require(!mintOnBlockEmission, "Powerlabs: Mint is already set activate");
	    mintAddress = _mintAddress;
		mintAmount = _mintAmount;
		_blockTracker = block.number;
	    mintOnBlockEmission = true;
	}
	function deactivateMintOnBlockEmission() public onlyOwner {
	    require(mintOnBlockEmission, "Powerlabs: Mint is already set deactivate");
	    mintOnBlockEmission = false;
		_blockTracker = 0;
	}
	function setGoldenHour() public onlyOwner {
		require(!this.isInGoldenHour(), "Powerlabs: Golden Hour is already set");
		require(isTradingEnabled, "Powerlabs: Trading must be enabled first");
		require(!this.isInLaunch(), "Powerlabs: Must not be in launch period");
		emit GoldenHourChange(true, false);
		_goldenHourStartTimestamp = _getNow();
	}
	function cancelGoldenHour() public onlyOwner {
		require(this.isInGoldenHour(), "Powerlabs: Golden Hour is not set");
		emit GoldenHourChange(false, true);
		_goldenHourStartTimestamp = 0;
	}
	function updateDividendTracker(address newAddress) public onlyOwner {
		require(newAddress != address(dividendTracker), "Powerlabs: The dividend tracker already has that address");
		PowerlabsDividendTracker newDividendTracker = PowerlabsDividendTracker(payable(newAddress));
		require(newDividendTracker.owner() == address(this), "Powerlabs: The new dividend tracker must be owned by the Powerlabs token contract");
		newDividendTracker.excludeFromDividends(address(newDividendTracker));
		newDividendTracker.excludeFromDividends(address(this));
		newDividendTracker.excludeFromDividends(owner());
		newDividendTracker.excludeFromDividends(address(uniswapV2Router));
		newDividendTracker.excludeFromDividends(address(uniswapV2Pair));
		emit DividendTrackerChange(newAddress, address(dividendTracker));
		dividendTracker = newDividendTracker;
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "Powerlabs: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
		if(value) {
			dividendTracker.excludeFromDividends(pair);
		}
		emit AutomatedMarketMakerPairChange(pair, value);
	}
	function allowTradingWhenDisabled(address account, bool allowed) public onlyOwner {
		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}
	function excludeFromFees(address account, bool excluded) public onlyOwner {
		require(_isExcludedFromFee[account] != excluded, "Powerlabs: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromDividends(address account) public onlyOwner {
		dividendTracker.excludeFromDividends(account);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) public onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "Powerlabs: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) public onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "Powerlabs: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
	function blockAccount(address account) public onlyOwner {
		uint256 currentTimestamp = _getNow();
		require(!_isBlocked[account], "Powerlabs: Account is already blocked");
		if (_isLaunched) {
			require(currentTimestamp.sub(_launchStartTimestamp) < _blockedTimeLimit, "Powerlabs: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) public onlyOwner {
		require(_isBlocked[account], "Powerlabs: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setWallets(address newLiquidityWallet, address newMarketingWallet, address newDevWallet, address newBuyBackWallet) public onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "Powerlabs: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "Powerlabs: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
		if(devWallet != newDevWallet) {
			require(newDevWallet != address(0), "Powerlabs: The devWallet cannot be 0");
			emit WalletChange('devWallet', newDevWallet, devWallet);
			devWallet = newDevWallet;
		}
		if(buyBackWallet != newBuyBackWallet) {
			require(newBuyBackWallet != address(0), "Powerlabs: The buyBackWallet cannot be 0");
			emit WalletChange('buyBackWallet', newBuyBackWallet, buyBackWallet);
			buyBackWallet = newBuyBackWallet;
		}
	}
	function setStakingAddress(address newStakingAddress) public onlyOwner {
		require(newStakingAddress != address(0), "Powerlabs: The stakingAddress cannot be 0");
		emit StakingAddressChange(newStakingAddress, stakingAddress);
		stakingAddress = newStakingAddress;
	}
	function setAllFeesToZero() public onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0, 0);
	}
	function resetAllFees() public onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.stakingFeeOnBuy, _default.holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.devFeeOnBuy, _default.buyBackFeeOnBuy, _default.stakingFeeOnBuy,  _default.holdersFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.stakingFeeOnSell,  _default.holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.devFeeOnSell, _default.buyBackFeeOnSell, _default.stakingFeeOnSell, _default.holdersFeeOnSell);
	}
	// Base fees
	function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _devFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _stakingFeeOnBuy, uint256 _holdersFeeOnBuy) public onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
	}
	//Launch2 Fees
	function setLaunch2FeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _devFeeOnBuy, uint256 _buyBackFeeOnBuy,uint256 _stakingFeeOnBuy,uint256 _holdersFeeOnBuy) public onlyOwner {
		_setCustomBuyTaxPeriod(_launch2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch2FeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint256 _buyBackFeeOnSell,uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
		_setCustomSellTaxPeriod(_launch2, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
	}
	//Launch3 Fees
	function setLaunch3FeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _devFeeOnBuy, uint256 _buyBackFeeOnBuy,uint256 _stakingFeeOnBuy, uint256 _holdersFeeOnBuy) public onlyOwner {
		_setCustomBuyTaxPeriod(_launch3, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch3Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch3FeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint256 _buyBackFeeOnSell,uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
		_setCustomSellTaxPeriod(_launch3, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch3Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
	}
	// Golden Hour 1 Fees
	function setGoldenHour1BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _devFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _stakingFeeOnBuy, uint256 _holdersFeeOnBuy) public onlyOwner {
		_setCustomBuyTaxPeriod(_golden1, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('golden1Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
	}
	function setGoldenHour1SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
		_setCustomSellTaxPeriod(_golden1, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('golden1Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
	}
	// Golden Hour 2 Fees
	function setGoldenHour2BuyFees(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy, uint256 _devFeeOnBuy, uint256 _buyBackFeeOnBuy, uint256 _stakingFeeOnBuy, uint256 _holdersFeeOnBuy) public onlyOwner {
		_setCustomBuyTaxPeriod(_golden2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('golden2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _stakingFeeOnBuy, _holdersFeeOnBuy);
	}
	function setGoldenHour2SellFees(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint256 _buyBackFeeOnSell, uint256 _stakingFeeOnSell, uint256 _holdersFeeOnSell) public onlyOwner {
		_setCustomSellTaxPeriod(_golden2, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('golden2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _stakingFeeOnSell, _holdersFeeOnSell);
	}
	function setUniswapRouter(address newAddress) public onlyOwner {
		require(newAddress != address(uniswapV2Router), "Powerlabs: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IUniswapV2Router02(newAddress);
		dividendTracker.setUniswapRouter(newAddress);
	}
	function setGasForProcessing(uint256 newValue) public onlyOwner {
		require(newValue != gasForProcessing, "Powerlabs: Cannot update gasForProcessing to same value");
		emit GasForProcessingChange(newValue, gasForProcessing);
		gasForProcessing = newValue;
	}
	function setMaxTransactionAmount(uint256 newValue) public onlyOwner {
		require(newValue != maxTxAmount, "Powerlabs: Cannot update maxTxAmount to same value");
		emit MaxTransactionAmountChange(newValue, maxTxAmount);
		maxTxAmount = newValue;
	}
	function setMaxWalletAmount(uint256 newValue) public onlyOwner {
		require(newValue != maxWalletAmount, "Powerlabs: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) public onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "Powerlabs: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function setMinimumTokenBalanceForDividends(uint256 newValue) public onlyOwner {
		dividendTracker.setTokenBalanceForDividends(newValue);
	}
	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }
	function setDividendToken(address newDividendToken) external onlyOwner {
		require(newDividendToken != dividendToken, "Powerlabs: Cannot update dividend token to same value");
		require(newDividendToken != address(0), "Powerlabs: The dividend token cannot be 0");
		require(newDividendToken != address(this), "Powerlabs: The dividend token cannot be set to the current contract");
		emit DividendTokenChange(newDividendToken, dividendToken);
		dividendToken = newDividendToken;
		dividendTracker.setRewardToken(dividendToken);
	}
	function claimBNBOverflow(uint256 amount) external onlyOwner {
	    require(amount < address(this).balance, "Powerlabs: Cannot send more than contract balance");
        (bool success,) = address(owner()).call{value : amount}("");
        if (success){
            emit ClaimBNBOverflow(amount);
        }
	}

	// Getters
	function timeSinceLastGoldenHour() external view returns(uint256){
	    uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _goldenHourStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		return currentTimestamp.sub(_goldenHourStartTimestamp);
	}
	function isInGoldenHour() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _goldenHourStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalGoldenTime = _golden1.timeInPeriod.add(_golden2.timeInPeriod);
		if(currentTimestamp.sub(_goldenHourStartTimestamp) < totalGoldenTime) {
			return true;
		} else {
			return false;
		}
	}
	function isInLaunch() external view returns (bool) {
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalLaunchTime =  _launch1.timeInPeriod.add(_launch2.timeInPeriod).add(_launch3.timeInPeriod);
		if(_isLaunched && (currentTimestamp.sub(_launchStartTimestamp) < totalLaunchTime || block.number.sub(_launchBlockNumber) < _launch1.blocksInPeriod )) {
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
		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.devFeeOnBuy, _base.buyBackFeeOnBuy, _base.stakingFeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.devFeeOnSell, _base.buyBackFeeOnSell, _base.stakingFeeOnSell, _base.holdersFeeOnSell);
	}
	function getGolden1BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_golden1.liquidityFeeOnBuy, _golden1.marketingFeeOnBuy, _golden1.devFeeOnBuy, _golden1.buyBackFeeOnBuy, _golden1.stakingFeeOnBuy, _golden1.holdersFeeOnBuy);
	}
	function getGolden1SellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_golden1.liquidityFeeOnSell, _golden1.marketingFeeOnSell, _golden1.devFeeOnSell, _golden1.buyBackFeeOnSell, _golden1.stakingFeeOnSell, _golden1.holdersFeeOnSell);
	}
	function getGolden2BuyFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_golden2.liquidityFeeOnBuy, _golden2.marketingFeeOnBuy, _golden2.devFeeOnBuy, _golden2.buyBackFeeOnBuy, _golden2.stakingFeeOnBuy, _golden2.holdersFeeOnBuy);
	}
	function getGolden2SellFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256){
		return (_golden2.liquidityFeeOnSell, _golden2.marketingFeeOnSell, _golden2.devFeeOnSell, _golden2.buyBackFeeOnSell, _golden2.stakingFeeOnSell, _golden2.holdersFeeOnSell);
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
				require(isTradingEnabled, "Powerlabs: Trading is currently disabled.");
				require(!_isBlocked[to], "Powerlabs: Account is blocked");
				require(!_isBlocked[from], "Powerlabs: Account is blocked");
				if (_isInLaunch && currentTimestamp.sub(_launchStartTimestamp) <= 300 && isBuyFromLp) {
					require(currentTimestamp.sub(_buyTimesInLaunch[to]) > 60, "Powerlabs: Cannot buy more than once per min in first 5min of launch");
				}
				if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
					require(amount <= maxTxAmount, "Powerlabs: Buy amount exceeds the maxTxBuyAmount.");
				}
				if (!_isExcludedFromMaxWalletLimit[to]) {
					require(balanceOf(to).add(amount) <= maxWalletAmount, "Powerlabs: Expected wallet amount exceeds the maxWalletAmount.");
				}
			}

			_adjustTaxes(isBuyFromLp, isSelltoLp);
			bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

			if (
				isTradingEnabled &&
				canSwap &&
				!_swapping &&
				_totalFee > 0 &&
				automatedMarketMakerPairs[to] &&
				from != liquidityWallet && to != liquidityWallet &&
				from != marketingWallet && to != marketingWallet &&
				from != devWallet && to != devWallet && 
				from != buyBackWallet && to != buyBackWallet && 
				from != stakingAddress && to != stakingAddress
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
				uint256 fee = amount.mul(_totalFee).div(100);
				amount = amount.sub(fee);
				super._transfer(from, address(this), fee);
			}

			if (_isInLaunch && currentTimestamp.sub(_launchStartTimestamp) <= 300) {
				if (to != owner() && isBuyFromLp  && currentTimestamp.sub(_buyTimesInLaunch[to]) > 60) {
					_buyTimesInLaunch[to] = currentTimestamp;
				}
			}

			super._transfer(from, to, amount);

			_mintOnBlockEmission();

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
	function _mintOnBlockEmission() private {
	    if (mintOnBlockEmission && _blockTracker < block.number) {
			uint256 _mintAmount = mintAmount.mul(block.number.sub(_blockTracker));
	        super._mint(mintAddress, _mintAmount);
			emit MintOnEmission(mintAddress, _mintAmount, _blockTracker, block.number);
	        _blockTracker = block.number;
	    }
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp) private {
	    uint256 blocksSinceLaunch = block.number.sub(_launchBlockNumber);
	    uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp.sub(_launchStartTimestamp);
		uint256 timeInLaunch = _launch3.timeInPeriod.add(_launch2.timeInPeriod);
		uint256 timeSinceGolden = currentTimestamp.sub(_goldenHourStartTimestamp);
		_liquidityFee = 0;
		_marketingFee = 0;
		_devFee = 0;
		_buyBackFee = 0;
		_stakingFee = 0;
		_holdersFee = 0;
			
		if (isBuyFromLp) {	
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_devFee = _base.devFeeOnBuy;
			_buyBackFee = _base.buyBackFeeOnBuy;
			_stakingFee = _base.stakingFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;

			if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
				_liquidityFee = _launch1.liquidityFeeOnBuy;
				_marketingFee = _launch1.marketingFeeOnBuy;
				_devFee = _launch1.devFeeOnBuy;
				_buyBackFee = _launch1.buyBackFeeOnBuy;
				_stakingFee = _launch1.stakingFeeOnBuy;
				_holdersFee = _launch1.holdersFeeOnBuy;
			}
			if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
				_liquidityFee = _launch2.liquidityFeeOnBuy;
				_marketingFee = _launch2.marketingFeeOnBuy;
				_devFee = _launch2.devFeeOnBuy;
				_buyBackFee = _launch2.buyBackFeeOnBuy;
				_stakingFee = _launch2.stakingFeeOnBuy;
				_holdersFee = _launch2.holdersFeeOnBuy;
			}
			if (_isLaunched && timeSinceLaunch > _launch2.timeInPeriod && timeSinceLaunch <= timeInLaunch && blocksSinceLaunch > _launch1.blocksInPeriod) {
				_liquidityFee = _launch3.liquidityFeeOnBuy;
				_marketingFee = _launch3.marketingFeeOnBuy;
				_devFee = _launch3.devFeeOnBuy;
				_buyBackFee = _launch3.buyBackFeeOnBuy;
				_stakingFee = _launch3.stakingFeeOnBuy;
				_holdersFee = _launch3.holdersFeeOnBuy;
			}
			if (timeSinceGolden <= _golden1.timeInPeriod) {
				_liquidityFee = _golden1.liquidityFeeOnBuy;
				_marketingFee = _golden1.marketingFeeOnBuy;
				_devFee = _golden1.devFeeOnBuy;
				_buyBackFee = _golden1.buyBackFeeOnBuy;
				_stakingFee = _golden1.stakingFeeOnBuy;
				_holdersFee = _golden1.holdersFeeOnBuy;
			}
			if (timeSinceGolden > _golden1.timeInPeriod && timeSinceGolden <= _golden1.timeInPeriod.add(_golden2.timeInPeriod)) {
				_liquidityFee = _golden2.liquidityFeeOnBuy;
				_marketingFee = _golden2.marketingFeeOnBuy;
				_devFee = _golden2.devFeeOnBuy;
				_buyBackFee = _golden2.buyBackFeeOnBuy;
				_stakingFee = _golden2.stakingFeeOnBuy;
				_holdersFee = _golden2.holdersFeeOnBuy;
			}
		}
	    if (isSelltoLp) {
	    	_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_devFee = _base.devFeeOnSell;
			_buyBackFee = _base.buyBackFeeOnSell;
			_stakingFee = _base.stakingFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;
			
			if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
				_liquidityFee = _launch1.liquidityFeeOnSell;
				_marketingFee = _launch1.marketingFeeOnSell;
				_devFee = _launch1.devFeeOnSell;
				_buyBackFee = _launch1.buyBackFeeOnSell;
				_stakingFee = _launch1.stakingFeeOnSell;
				_holdersFee = _launch1.holdersFeeOnSell;
			}
			if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
				_liquidityFee = _launch2.liquidityFeeOnSell;
				_marketingFee = _launch2.marketingFeeOnSell;
				_devFee = _launch2.devFeeOnSell;
				_buyBackFee = _launch2.buyBackFeeOnSell;
				_stakingFee = _launch2.stakingFeeOnSell;
				_holdersFee = _launch2.holdersFeeOnSell;
			}
			if (_isLaunched && timeSinceLaunch > _launch2.timeInPeriod && timeSinceLaunch <= timeInLaunch && blocksSinceLaunch > _launch1.blocksInPeriod) {
				_liquidityFee = _launch3.liquidityFeeOnSell;
				_marketingFee = _launch3.marketingFeeOnSell;
				_devFee = _launch3.devFeeOnSell;
				_buyBackFee = _launch3.buyBackFeeOnSell;
				_stakingFee = _launch3.stakingFeeOnSell;
				_holdersFee = _launch3.holdersFeeOnSell;
			}
			if (timeSinceGolden <= _golden1.timeInPeriod) {
				_liquidityFee = _golden1.liquidityFeeOnSell;
				_marketingFee = _golden1.marketingFeeOnSell;
				_devFee = _golden1.devFeeOnSell;
				_buyBackFee = _golden1.buyBackFeeOnSell;
				_stakingFee = _golden1.stakingFeeOnSell;
				_holdersFee = _golden1.holdersFeeOnSell;
			}
			if (timeSinceGolden > _golden1.timeInPeriod && timeSinceGolden <= _golden1.timeInPeriod.add(_golden2.timeInPeriod)) {
				_liquidityFee = _golden2.liquidityFeeOnSell;
				_marketingFee = _golden2.marketingFeeOnSell;
				_devFee = _golden2.devFeeOnSell;
				_buyBackFee = _golden2.buyBackFeeOnSell;
				_stakingFee = _golden2.stakingFeeOnSell;
				_holdersFee = _golden2.holdersFeeOnSell;
			} 
		}
		_totalFee = _liquidityFee.add(_marketingFee).add(_devFee).add(_buyBackFee).add(_stakingFee).add(_holdersFee);
		emit FeesApplied(_liquidityFee, _marketingFee, _devFee, _buyBackFee, _stakingFee, _holdersFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnSell,
		uint256 _marketingFeeOnSell,
		uint256 _devFeeOnSell,
		uint256 _buyBackFeeOnSell,
		uint256 _stakingFeeOnSell,
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
		if (map.devFeeOnSell != _devFeeOnSell) {
			emit CustomTaxPeriodChange(_devFeeOnSell, map.devFeeOnSell, 'devFeeOnSell', map.periodName);
			map.devFeeOnSell = _devFeeOnSell;
		}
		if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
			emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
			map.buyBackFeeOnSell = _buyBackFeeOnSell;
		}
		if (map.stakingFeeOnSell != _stakingFeeOnSell) {
			emit CustomTaxPeriodChange(_stakingFeeOnSell, map.stakingFeeOnSell, 'stakingFeeOnSell', map.periodName);
			map.stakingFeeOnSell = _stakingFeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnBuy,
		uint256 _marketingFeeOnBuy,
		uint256 _devFeeOnBuy,
		uint256 _buyBackFeeOnBuy,
		uint256 _stakingFeeOnBuy,
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
		if (map.devFeeOnBuy != _devFeeOnBuy) {
			emit CustomTaxPeriodChange(_devFeeOnBuy, map.devFeeOnBuy, 'devFeeOnBuy', map.periodName);
			map.devFeeOnBuy = _devFeeOnBuy;
		}
		if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
			emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
			map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
		}
		if (map.stakingFeeOnBuy != _stakingFeeOnBuy) {
			emit CustomTaxPeriodChange(_stakingFeeOnBuy, map.stakingFeeOnBuy, 'stakingFeeOnBuy', map.periodName);
			map.stakingFeeOnBuy = _stakingFeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialBNBBalance = address(this).balance;

		uint256 amountToLiquify = contractBalance.mul(_liquidityFee).div(_totalFee).div(2);
		uint256 amountForStaking = contractBalance.mul(_stakingFee).div(_totalFee);
		uint256 amountToSwap = contractBalance.sub((amountToLiquify.add(amountForStaking)));

		_swapTokensForBNB(amountToSwap);

		uint256 bnbBalanceAfterSwap = address(this).balance.sub(initialBNBBalance);
		uint256 totalBNBFee = _totalFee.sub(_liquidityFee.div(2));
		uint256 amountBNBLiquidity = bnbBalanceAfterSwap.mul(_liquidityFee).div(totalBNBFee).div(2);
		uint256 amountBNBMarketing = bnbBalanceAfterSwap.mul(_marketingFee).div(totalBNBFee);
		uint256 amountBNBBuyBack = bnbBalanceAfterSwap.mul(_buyBackFee).div(totalBNBFee);
		uint256 amountBNBDev = bnbBalanceAfterSwap.mul(_devFee).div(totalBNBFee);
		uint256 amountBNBHolders = bnbBalanceAfterSwap.sub((amountBNBLiquidity.add(amountBNBMarketing).add(amountBNBBuyBack).add(amountBNBDev)));

		payable(marketingWallet).transfer(amountBNBMarketing);
		payable(buyBackWallet).transfer(amountBNBBuyBack);
		payable(devWallet).transfer(amountBNBDev);
		
		if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountBNBLiquidity);
			emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);
		}

		(bool stakingSuccess) = IERC20(address(this)).transfer(address(stakingAddress), amountForStaking);
		if(stakingSuccess) {
			emit StakingTokensSent(amountForStaking);
		}
	
		(bool dividendSuccess,) = address(dividendTracker).call{value: amountBNBHolders}("");
		if(dividendSuccess) {
			emit DividendsSent(amountBNBHolders);
		}
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

contract PowerlabsDividendTracker is DividendPayingToken {
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

	constructor() DividendPayingToken("Powerlabs_Dividend_Tracker", "Powerlabs_Dividend_Tracker") {
		claimWait = 3600;
		minimumTokenBalanceForDividends = 200000000 * (10**18);
	}
	function setRewardToken(address token) external onlyOwner {
	    _setRewardToken(token);
	}
	function setUniswapRouter(address router) external onlyOwner {
	    _setUniswapRouter(router);
	}
	function _transfer(address, address, uint256) internal pure override {
		require(false, "Powerlabs_Dividend_Tracker: No transfers allowed");
	}
	function excludeFromDividends(address account) external onlyOwner {
		require(!excludedFromDividends[account]);
		excludedFromDividends[account] = true;
		_setBalance(account, 0);
		tokenHoldersMap.remove(account);
		emit ExcludeFromDividends(account);
	}
	function setTokenBalanceForDividends(uint256 newValue) external onlyOwner {
		require(minimumTokenBalanceForDividends != newValue, "Powerlabs_Dividend_Tracker: minimumTokenBalanceForDividends already the value of 'newValue'.");
		minimumTokenBalanceForDividends = newValue;
	}
	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
		require(newClaimWait >= 3600 && newClaimWait <= 86400, "Powerlabs_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
		require(newClaimWait != claimWait, "Powerlabs_Dividend_Tracker: Cannot update claimWait to same value");
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