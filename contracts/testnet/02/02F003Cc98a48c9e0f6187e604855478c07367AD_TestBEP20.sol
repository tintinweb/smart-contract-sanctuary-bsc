/**
 *Submitted for verification at BscScan.com on 2022-04-07
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
	string internal constant _name = "P88";
	string internal constant _symbol = "P88";
	uint8 internal constant _decimal = 8;
	uint256 internal constant _totalSupply = 1_000_000_000 * 10 ** _decimal;
	mapping(address => uint256) internal _balance;
	mapping(address => bool) internal _blacklist;
	mapping(address => bool) internal _exclude;
	mapping(address => mapping(address => uint256)) internal _allowance;
	address internal adr_zero = 0x0000000000000000000000000000000000000000;
	address internal adr_dead = 0x000000000000000000000000000000000000dEaD;
	address internal adr_team = adr_zero;
	uint256 internal _launchAt;
	uint8 internal _autoliq;
	uint8 internal tax_a;
	uint8 internal tax_b;
	uint8 internal tax_c;
}

abstract contract BEP20Modifier is BEP20GlobalData{
	modifier isLaunched(){
		require(_launchAt > 0, "BEP20: token not launched yet!");_;
	}
	modifier isAllowed(address from, address to){
		require(!_blacklist[from], "BEP20: blacklisted sender!");
		require(!_blacklist[to], "BEP20: blacklisted recipient!");_;
	}
	modifier isSufficient(uint256 a, uint256 b){
		require(a >= b, "BEP20: insufficient balances!");_;
	}
	modifier deadline(uint256 secs){
		uint256 ts = block.timestamp + secs;
		require(ts >= block.timestamp, "BEP20: EXPIRED");_;
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
		return _totalSupply.sub(_balance[adr_zero]).sub(_balance[adr_dead]).sub(_balance[address(this)]);
	}
	function balanceOf(address owner) external override view returns(uint256){
		return _balance[owner];
	}
	function allowance(address owner, address spender) external override view returns(uint256){
		return _allowance[owner][spender];
	}
}

interface IWETH{
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface DEXFactory{
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
	function getPair(address tokenA, address tokenB) external view returns(address pair);
    function createPair(address tokenA, address tokenB) external returns(address pair);
}

interface DEXPair{
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
}

interface DEXRouterV1{
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

interface DEXRouterV2 is DEXRouterV1{
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
	DEXRouterV2 internal router;
	bool private bypassTax = false;
	mapping(address => bool) internal _listedPair;
	mapping(address => address[]) internal _tokens;
	event RouterSet(address indexed router, address indexed pair);
	function addDEXRouterPairAndLiquidity(
		address adr_router,
		address paired_token,
		uint256 tokenAmount
	) external payable authorized returns(bool){
		router = DEXRouterV2(adr_router);
		address adr_pair = DEXFactory(router.factory()).createPair(address(this), paired_token);
		includeToLPs(adr_pair);
		_tokens[adr_pair] = [address(this), paired_token];
		uint256 max = type(uint256).max;
		{
			_allowance[address(this)][adr_router] = max;
			_allowance[msg.sender][adr_router] = max;
			emit Approval(address(this), adr_router, max);
			emit Approval(msg.sender, adr_router, max);
			emit RouterSet(adr_router, adr_pair);
		}
		return addLiquidity(adr_pair, tokenAmount);
	}
	function addLiquidity(address adr_pair, uint256 tokenAmount) internal returns(bool){
		bypassTax = true;
		internalTransfer(msg.sender, adr_pair, tokenAmount);
		IWETH(router.WETH()).deposit{value: msg.value}();
        assert(IWETH(router.WETH()).transfer(adr_pair, msg.value));
        DEXPair(adr_pair).mint(msg.sender);
        bypassTax = false;
		return true;
    }
	function transfer(address to, uint256 value) external override
		isAllowed(msg.sender, to)
		isSufficient(_balance[msg.sender], value)
		returns(bool)
	{
		return internalTransfer(msg.sender, to, value);
	}
	function transferFrom(address from, address to, uint256 value) public override
		isLaunched 
		isAllowed(from, to)
		isSufficient(_balance[from], value)
		isSufficient(_allowance[from][msg.sender], value)
		returns(bool)
	{
		if(block.timestamp < _launchAt) detectSnipers(from, to);
		_allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
		return internalTransfer(from, to, value);
	}
	function approve(address spender, uint256 value) public override returns(bool){
		require(value >= 0, "BEP20: negative value");
		_allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
	function internalTransfer(address from, address to, uint256 value) internal returns(bool){
		uint256 amount_taxed = isExclusive(from, to) || bypassTax ? 0 : getFee(from, to, value);
		uint256 amount_received = value.sub(amount_taxed);
		_balance[from] = _balance[from].sub(amount_received);
		_balance[to] = _balance[to].add(amount_received);
		emit Transfer(from, to, amount_received);
		return true;
	}
	function getFee(address from, address to, uint256 value) internal returns(uint256 amount_taken){
		bool b = (_listedPair[from]) ? true : false;
		bool s = (_listedPair[to]) ? true : false;
		uint8 tax_applied = b && redistributeLiq(from, value) ? tax_a : s ? tax_b : tax_c;
		if(tax_applied > 0){
			amount_taken = value.mul(tax_applied).div(100);
			_balance[from] = _balance[from].sub(amount_taken);
			_balance[adr_team] = _balance[adr_team].add(amount_taken);
			emit Transfer(from, adr_team, amount_taken);
		}
	}
	function detectSnipers(address from, address to) internal{
		bool a = from != owner() && to != owner();
		bool b = _listedPair[from];
		bool c = _listedPair[to];
		_blacklist[from] = a && c ? true : false;
		_blacklist[to] = a && b ? true : false;
	}
	function isExclusive(address from, address to) internal view returns(bool){
		return _exclude[from] || _exclude[to];
	}
	function redistributeLiq(address pair_, uint256 value) internal returns(bool){
		uint256 liq_amount = value.mul(_autoliq).div(100);
		if(liq_amount <= _balance[address(this)]){
			_balance[address(this)] = _balance[address(this)].sub(liq_amount);
			_balance[pair_] = _balance[pair_].add(liq_amount);
			emit Transfer(address(this), pair_, liq_amount);
		}
		return true;
	}
	function setTimerAndFees(
		uint256 timestamp, 
		uint8 a, 
		uint8 b, 
		uint8 c
	) external returns(bool){
		require(timestamp > 0, "BEP20: must be higher than 0");
		require(_launchAt == 0, "BEP20: no longer editable");
		_launchAt = timestamp;
		tax_a = a;
		tax_b = b;
		tax_c = c;
		return true;
	}
	function includeToLPs(address pair_) public authorized{
		_listedPair[pair_] = true;
	}
	function excludeFromLPs(address pair_) public authorized{
		_listedPair[pair_] = false;
	}
}

contract TestBEP20 is DEX, BEP20ReadFunction{
	using SafeMath for uint256;
	constructor(uint8 liq_, uint8 autoliq_) Ownable(){
		uint256 liqS = _totalSupply.mul(liq_).div(100);
		uint256 liqB = _totalSupply.sub(liqS);
		_autoliq = autoliq_;
		_blacklist[adr_zero] = true;
		_blacklist[adr_dead] = true;
		_exclude[address(this)] = true;
		_exclude[owner()] = true;
		_balance[address(this)] = liqB;
		_balance[owner()] = liqS;
		emit Transfer(address(0), address(this), _totalSupply);
		emit Transfer(address(this), owner(), liqS);
	}
	receive() external payable{}
	function setTeamWallet(address new_) public returns(bool){
		require(adr_team != new_, "BEP20: input other address as team wallet");
		_exclude[adr_team] = false;
		_exclude[new_] = true;
		adr_team = new_;
		return true;
	}
}