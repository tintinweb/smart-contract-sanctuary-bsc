/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract gameContract{
	using SafeMath for uint256;
	IERC20 public _LP = IERC20(0xdAcA7C8e16DDfA5d5B266380228Ca9e2288F3931);
	mapping(address => uint256) public _ulock;
	mapping(address => uint256) public _ulockcell;
	mapping(address => uint256) public _ulocktime;
	uint256 public nmonth = 30*24*60*60;

	constructor(){
		nmonth = 60;
	}
	function lock(uint256 _value) public {
		uint256 nvalue = _value*10**18;
		uint256 nall = nvalue.add(_ulock[msg.sender]);

		_ulock[msg.sender] = _ulock[msg.sender].add(nvalue);
		_ulockcell[msg.sender] = nall.div(6);
		_ulocktime[msg.sender] = block.timestamp + nmonth;
		_LP.transferFrom(msg.sender, address(this), nvalue);
	}
	function unlock() public {
		require(_ulock[msg.sender]>0, "Err: error address");
		require(_ulockcell[msg.sender]>0, "Err: error address");
		require(_ulocktime[msg.sender]>block.timestamp, "Err: error address");

		uint256 nvalue = _ulockcell[msg.sender];
		if (nvalue>_ulock[msg.sender]){
			nvalue = _ulock[msg.sender];
		}
		_ulock[msg.sender] = _ulock[msg.sender].sub(nvalue);
		_ulocktime[msg.sender] = _ulocktime[msg.sender] + nmonth;
		_LP.transfer(msg.sender, nvalue);
	}
	function info(address _add) public view returns(	
		uint256 _lock,
		uint256 _time, 
		uint256 _cell
	) { 
		_lock = _ulock[_add];
		_time = _ulocktime[_add];
		_cell = _ulockcell[_add];
	}
}