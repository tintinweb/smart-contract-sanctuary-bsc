/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath{
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
	function div(uint256 a, uint256 b) internal pure returns (uint256){
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
	function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b != 0, "Safemath: modulo by zero");
        return a % b;
    }
}

abstract contract Ownable{
	address private _owner;
	constructor(){
		emit OwnershipTransferred(address(0), msg.sender);
		_owner = msg.sender;
	}
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	modifier authorized(){
		require(_owner == msg.sender, "Ownable: caller is not the owner");_;
	}
	function owner() public view returns(address){
		return _owner;
	}
	function transferOwnership(address newOwner) public authorized{
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
	function renounceOwnership() public authorized{
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}
}

interface BEP20{
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	function name() external pure returns(string memory);
	function symbol() external pure returns(string memory);
	function decimals() external pure returns(uint8);
	function totalSupply() external pure returns(uint256);
	function circulatingSupply() external view returns(uint256);
	function balanceOf(address owner) external view returns(uint);
	function transfer(address to, uint256 value) external returns(bool);
	function transferFrom(address from, address to, uint256 value) external returns(bool);
	function approve(address spender, uint256 value) external returns(bool);
	function allowance(address owner, address spender) external view returns(uint256);
}

abstract contract BEP20GlobalData is BEP20{
	string internal constant _name = "TEST45";
	string internal constant _symbol = "T45";
	uint8 internal constant _decimal = 9;
	uint256 internal constant _totalSupply = 1_000_000 * 10 ** _decimal;
	mapping(address => uint256) internal _balance;
	mapping(address => bool) internal _sniper;
	mapping(address => bool) internal _exclude;
	mapping(address => bool) internal _blacklist;
	mapping(address => mapping(address => uint256)) internal _allowance;
	address internal adr_zero = 0x0000000000000000000000000000000000000000;
	address internal adr_dead = 0x000000000000000000000000000000000000dEaD;
	address internal adr_team = adr_zero;
	uint8 internal tax_buy = 15;
	uint8 internal tax_sell = 10;
	uint8 internal tax_basic = 5;
}

abstract contract BEP20Modifier is BEP20GlobalData{
	modifier isAllowed(address from, address to){
		require(!_blacklist[from], "BEP20Modifier: blacklisted sender!");
		require(!_blacklist[to], "BEP20Modifier: blacklisted recipient!");_;
	}
	modifier isSufficient(uint256 a, uint256 b){
		require(a >= b, "BEP20Modifier: insufficient balances!");_;
	}
}

abstract contract BEP20ReadFunction is BEP20GlobalData{
	using SafeMath for uint256;
	function name() external override pure returns(string memory){
		return _name;
	}
	function symbol() external override pure returns(string memory){
		return _symbol;
	}
	function decimals() external override pure returns(uint8){
		return _decimal;
	}
	function totalSupply() external override pure returns(uint256){
		return _totalSupply;
	}
	function circulatingSupply() external override view returns(uint256){
		return _totalSupply.sub(_balance[adr_zero]).sub(_balance[adr_dead]);
	}
	function balanceOf(address owner) external override view returns(uint256){
		return _balance[owner];
	}
	function allowance(address owner, address spender) external override view returns(uint256){
		return _allowance[owner][spender];
	}
}

interface DEXFactory{
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
	function getPair(address tokenA, address tokenB) external view returns(address pair);
    function allPairs(uint) external view returns(address pair);
    function allPairsLength() external view returns(uint);
	function feeTo() external view returns(address);
    function setFeeTo(address) external;
    function feeToSetter() external view returns(address);
	function setFeeToSetter(address) external;
	function createPair(address tokenA, address tokenB) external returns(address pair);
}

interface DEXPair{
	event Sync(uint112 reserve0, uint112 reserve1);
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
    function MINIMUM_LIQUIDITY() external pure returns(uint);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function PERMIT_TYPEHASH() external pure returns(bytes32);
    function factory() external view returns(address);
    function token0() external view returns(address);
    function token1() external view returns(address);
    function getReserves() external view returns(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns(uint);
    function price1CumulativeLast() external view returns(uint);
    function kLast() external view returns(uint);
    function nonces(address owner) external view returns(uint);
	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
	function mint(address to) external returns(uint liquidity);
    function burn(address to) external returns(uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface DEXRouter01{
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
    ) external returns(uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns(uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns(uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns(uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);
    function swapExactETHForTokens(
		uint amountOutMin, 
		address[] calldata path, 
		address to, 
		uint deadline
	) external payable returns(uint[] memory amounts);
    function swapTokensForExactETH(
		uint amountOut, 
		uint amountInMax, 
		address[] calldata path, 
		address to, 
		uint deadline
	) external returns(uint[] memory amounts);
    function swapExactTokensForETH(
		uint amountIn, 
		uint amountOutMin, 
		address[] calldata path, 
		address to, 
		uint deadline
	) external returns(uint[] memory amounts);
    function swapETHForExactTokens(
		uint amountOut, 
		address[] calldata path, 
		address to, 
		uint deadline
	) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface DEXRouter02 is DEXRouter01{
	function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns(uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountETH);
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

abstract contract DEX is Ownable, BEP20Modifier{
	using SafeMath for uint256;
	mapping(address => bool) internal _listedLP;
	address internal adr_factory;
	address internal adr_router;
	address internal adr_pair;
	bool private bypassTax = false;
	bool private dexInitalized = false;
	event RouterSet(address indexed router, address indexed pair);
	DEXRouter02 internal router;
	function initDEXRouter(address adr_router_) external authorized{
		if(adr_pair != adr_zero){
			removeFromLPs(adr_pair);
		}
		dexInitalized = true;
		router = DEXRouter02(adr_router_);
		adr_pair = DEXFactory(router.factory()).createPair(address(this), router.WETH());
		addToLPs(adr_pair);
		adr_router = address(router);
		uint256 max = type(uint256).max;
		_allowance[address(this)][adr_router] = max;
		_allowance[msg.sender][adr_router] = max;
		emit Approval(address(this), adr_router, max);
		emit Approval(msg.sender, adr_router, max);
		emit RouterSet(adr_router, adr_pair);
	}
	function setTeamWallet(address adr_new_) public returns(bool){
		require(adr_team != adr_new_, "the wallet is already a team wallet");
		_exclude[adr_team] = false;
		_exclude[adr_new_] = true;
		adr_team = adr_new_;
		return true;
	}
	function transfer(address to, uint256 value) external override
		isAllowed(msg.sender, to)
		isSufficient(_balance[msg.sender], value)
		returns(bool)
	{
		return taxedTransfer(msg.sender, to, value);
	}
	function transferFrom(address from, address to, uint256 value) external override
		isAllowed(from, to)
		isSufficient(_balance[from], value)
		isSufficient(_allowance[from][msg.sender], value)
		returns(bool)
	{
		return taxedTransfer(from, to, value);
	}
	function approve(address spender, uint256 value) public override returns(bool){
		require(value >= 0, "BEP20: negative value");
		_allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
	function taxedTransfer(address from, address to, uint256 value) internal returns(bool){
		uint256 amount_taxed = isExclusive(from, to) || bypassTax ? 0 : getFee(from, to, value);
		uint256 amount_received = value.sub(amount_taxed);
		_balance[from] = _balance[from].sub(amount_received);
		_balance[to] = _balance[to].add(amount_received);
		emit Transfer(from, to, amount_received);
		return true;
	}
	function getFee(address from, address to, uint256 value) internal returns(uint256){
		bool buy = (to == adr_pair) ? true : false;
		bool sell = (from == adr_pair) ? true : false;
		uint8 tax_applied = buy ? tax_buy : sell ? tax_sell : tax_basic;
		uint256 amount_taken = value.mul(tax_applied).div(100);
		_balance[from] = _balance[from].sub(amount_taken);
		_balance[adr_team] = _balance[adr_team].add(amount_taken);
		emit Transfer(from, adr_team, amount_taken);
		return amount_taken;
	}
	function isExclusive(address from, address to) internal view returns(bool){
		return _exclude[from] || _exclude[to];
	}
	function addLiquidity(uint256 amountToken) public payable 
		isSufficient(_balance[msg.sender], amountToken)
		authorized
		returns(uint a, uint b, uint c)
	{
		require(dexInitalized, "pair not created yet");
		require(adr_team != adr_zero, "no team wallet yet!");
		require(amountToken > 0, "token amount must be higher than 0");
		require(msg.value > 0, "weth amount must be higher than 0");
		bypassTax = true;
		(a, b, c) = router.addLiquidityETH{value: msg.value}(
			address(this),
			amountToken,
			0,
			0,
			msg.sender,
			block.timestamp
		);
		bypassTax = false;
		return (a, b, c);
	}
	function addToLPs(address adr_pair_) public authorized{
		_listedLP[adr_pair_] = true;
	}
	function removeFromLPs(address adr_pair_) public authorized{
		_listedLP[adr_pair_] = false;
	}
}

contract ToTeTotBEP20 is DEX, BEP20ReadFunction{
	using SafeMath for uint256;
	constructor() Ownable(){
		_blacklist[adr_zero] = true;
		_blacklist[adr_dead] = true;
		_balance[owner()] += _totalSupply;
		emit Transfer(address(0), owner(), _totalSupply);
	}
	receive() external payable{}
}