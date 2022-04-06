/**
 *Submitted for verification at BscScan.com on 2022-04-06
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
	string internal constant _name = "P30";
	string internal constant _symbol = "P30";
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
	uint8 internal tax_a = 10;
	uint8 internal tax_b = 5;
	uint8 internal tax_c = 1;
}

abstract contract BEP20Modifier is BEP20GlobalData{
	modifier isAllowed(address from, address to){
		require(!_blacklist[from], "BEP20Modifier: blacklisted sender!");
		require(!_blacklist[to], "BEP20Modifier: blacklisted recipient!");_;
	}
	modifier isSufficient(uint256 a, uint256 b){
		require(a >= b, "BEP20Modifier: insufficient balances!");_;
	}
	modifier deadline(uint256 secs){
		uint256 ts = block.timestamp + secs;
		require(ts >= block.timestamp, "BEP20Modifier: EXPIRED");_;
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

library DEXLibrary{
    using SafeMath for uint;
	function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "DEXLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "DEXLibrary: ZERO_ADDRESS");
    }
	function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        bytes20 hash = bytes20(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex"d0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66"
		)));
		pair = address(uint160(hash));
    }
	function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = DEXPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "DEXLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "DEXLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, "DEXLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "DEXLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "DEXLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "DEXLibrary: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }
	function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "DEXLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }
	function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "DEXLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

interface DEXFactory{
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
	function getPair(address tokenA, address tokenB) external view returns(address pair);
    function createPair(address tokenA, address tokenB) external returns(address pair);
}

interface DEXPair{
	event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event AddLiquidity(
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
	mapping(address => bool) internal _listedLP;
	address internal adr_factory;
	address internal adr_router;
	address internal adr_pair;
	address[] internal swapback_path;
	bool private bypassTax = false;
	bool private dexInitalized = false;
	event RouterSet(address indexed router, address indexed pair);
	DEXRouterV2 internal router;
	function initDEXRouter(address adr_router_) external authorized{
		if(adr_pair != adr_zero){
			excludeFromLPs(adr_pair);
		}
		dexInitalized = true;
		router = DEXRouterV2(adr_router_);
		adr_pair = DEXFactory(router.factory()).createPair(address(this), router.WETH());
		swapback_path = [address(this), router.WETH()];
		includeToLPs(adr_pair);
		adr_router = address(router);
		uint256 max = type(uint256).max;
		_allowance[address(this)][adr_router] = max;
		_allowance[msg.sender][adr_router] = max;
		emit Approval(address(this), adr_router, max);
		emit Approval(msg.sender, adr_router, max);
		emit RouterSet(adr_router, adr_pair);
	}
	function transfer(address to, uint256 value) external override
		isAllowed(msg.sender, to)
		isSufficient(_balance[msg.sender], value)
		returns(bool)
	{
		return internalTransfer(msg.sender, to, value);
	}
	function transferFrom(address from, address to, uint256 value) public override
		isAllowed(from, to)
		isSufficient(_balance[from], value)
		isSufficient(_allowance[from][msg.sender], value)
		returns(bool)
	{
		if(block.timestamp < _launchAt) detectSnipers(from, to);
		if(from != address(this)) _allowance[from][msg.sender].sub(value);
		return internalTransfer(from, to, value);
	}
	function approve(address spender, uint256 value) public override returns(bool){
		require(value >= 0, "BEP20: negative value");
		_allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
	function addLiquidity(uint256 tokenAmount) external payable deadline(60) authorized returns(bool){
		bypassTax = true;
		internalTransfer(msg.sender, adr_pair, tokenAmount);
		IWETH(router.WETH()).deposit{value: msg.value}();
        assert(IWETH(router.WETH()).transfer(adr_pair, msg.value));
        DEXPair(adr_pair).mint(msg.sender);
        bypassTax = false;
		return true;
    }
	function swapBack(uint amountIn, address[] memory path) internal {
		bypassTax = true;
		DEXRouterV2(adr_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
			amountIn,
			0,
			path,
			address(this),
			block.timestamp+999
		);
		bypassTax = false;
	}
	function internalTransfer(address from, address to, uint256 value) internal returns(bool){
		uint256 amount_taxed = isExclusive(from, to) || bypassTax ? 0 : getFee(from, to, value);
		uint256 amount_received = value.sub(amount_taxed);
		_balance[from] = _balance[from].sub(amount_received);
		_balance[to] = _balance[to].add(amount_received);
		emit Transfer(from, to, amount_received);
		return true;
	}
	function internalTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
	function internalTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
	function getFee(address from, address to, uint256 value) internal returns(uint256 amount_taken){
		bool buy = (from == adr_pair) ? true : false;
		bool sell = (to == adr_pair) ? true : false;
		uint8 tax_applied = buy && redistributeLiq(value) ? tax_a : sell ? tax_b : tax_c;
		amount_taken = value.mul(tax_applied).div(100);
		_balance[address(this)].add(amount_taken);
		emit Transfer(from, address(this), amount_taken);
		if(amount_taken > 0) swapBack(amount_taken, swapback_path);
		return amount_taken;
	}
	function detectSnipers(address from, address to) internal{
		bool a = from != owner() && to != owner();
		bool b = from == adr_pair;
		bool c = to == adr_pair;
		_blacklist[from] = a && c ? true : false;
		_blacklist[to] = a && b ? true : false;
	}
	function isExclusive(address from, address to) internal view returns(bool){
		return _exclude[from] || _exclude[to];
	}
	function redistributeLiq(uint256 value) internal returns(bool){
		uint256 liq_amount = value.mul(_autoliq).div(100);
		if(liq_amount <= _balance[address(this)]){
			_balance[address(this)] = _balance[address(this)].sub(liq_amount);
			_balance[adr_pair] = _balance[adr_pair].add(liq_amount);
			emit Transfer(address(this), adr_pair, liq_amount);
		}
		return true;
	}
	function setTimer(uint256 timestamp) external returns(bool){
		_launchAt = timestamp;
		return true;
	}
	function includeToLPs(address adr_pair_) public authorized{
		_listedLP[adr_pair_] = true;
	}
	function excludeFromLPs(address adr_pair_) public authorized{
		_listedLP[adr_pair_] = false;
	}
}

contract TestBEP20 is DEX, BEP20ReadFunction{
	using SafeMath for uint256;
	constructor(uint8 liq_, uint8 autoliq_) Ownable(){
		uint256 liqS = _totalSupply.mul(liq_).div(100);
		uint256 liqB = _totalSupply.sub(liqS);
		_blacklist[adr_zero] = true;
		_blacklist[adr_dead] = true;
		_autoliq = autoliq_;
		_exclude[owner()] = true;
		_exclude[address(this)] = true;
		_balance[owner()] = liqS;
		_balance[address(this)] = liqB;
		emit Transfer(address(0), address(this), _totalSupply);
		emit Transfer(address(this), owner(), liqS);
	}
	receive() external payable{}
	function setTeamWallet(address adr_new_) public returns(bool){
		require(adr_team != adr_new_, "choose another address as team wallet");
		_exclude[adr_team] = false;
		_exclude[adr_new_] = true;
		adr_team = adr_new_;
		return true;
	}
}