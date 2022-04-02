/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: UNLICENSED
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

contract Ownable{
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
	function totalSupply() external pure returns(uint256);
	function decimals() external pure returns(uint8);
	function name() external pure returns(string memory);
	function symbol() external pure returns(string memory);
	function balanceOf(address owner) external view returns(uint);
	function transfer(address to, uint256 value) external returns(bool);
	function transferFrom(address from, address to, uint256 value) external returns(bool);
	function approve(address spender, uint256 value) external returns(bool);
	function allowance(address owner, address spender) external view returns(uint256);
}

abstract contract BEP20GlobalData is BEP20{
	address public constant adr_zero = 0x0000000000000000000000000000000000000000;
	address public constant adr_dead = 0x000000000000000000000000000000000000dEaD;
	uint256 internal constant adr_factory = type(uint256).max;
	uint256 internal constant adr_router = type(uint256).max;
	string internal constant _name = "Batmobile";
	string internal constant _symbol = "XBM";
	uint8 internal constant _decimal = 18;
	uint256 internal constant _totalSupply = 1_000_000 * 10 ** _decimal;
	mapping(address => mapping(address => uint256)) internal _allowance;
	mapping(address => uint) internal _balance;
	mapping(address => bool) internal _blacklist;
	mapping(address => bool) internal _sniper;
	mapping(address => uint256) internal _request; 
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
	function balanceOf(address owner) external override view returns(uint256){
		return _balance[owner];
	}
	function allowance(address owner, address spender) external override view returns(uint256){
		return _allowance[owner][spender];
	}
}

abstract contract BEP20WriteFunction is BEP20Modifier{
	function transfer(address to, uint256 value) external override
		isAllowed(msg.sender, to)
		isSufficient(_balance[msg.sender],value)
		returns(bool)
	{
		_balance[msg.sender] -= value;
		_balance[to] += value;
		emit Transfer(msg.sender, to, value);
		return true;
	}
	function transferFrom(address from, address to, uint256 value) external override
		isAllowed(from, to)
		isSufficient(_balance[from], value)
		isSufficient(_allowance[from][msg.sender], value)
		returns(bool)
	{
		_balance[from] -= value;
		_balance[to] += value;
		emit Transfer(from, to, value);
		return true;
	}
	function approve(address spender, uint256 value) external override returns(bool){
		_allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
}

contract BatmobileBEP20 is Ownable, BEP20ReadFunction, BEP20WriteFunction{
	using SafeMath for uint256;
	constructor() Ownable(){
		emit Transfer(address(0), msg.sender, _totalSupply);
		_balance[msg.sender] += _totalSupply;
		_blacklist[adr_zero] = true;
		_blacklist[adr_dead] = true;
	}
	function getCirculatingSupply() public view returns(uint256){
		return _totalSupply.sub(_balance[adr_zero]).sub(_balance[adr_dead]);
	}
	function addNumber(uint256 value) external returns(bool){
		_request[msg.sender] = _request[msg.sender].add(value);
		return true;
	}
	function getNumber(address owner) external view returns(uint256){
		return _request[owner];
	}
}