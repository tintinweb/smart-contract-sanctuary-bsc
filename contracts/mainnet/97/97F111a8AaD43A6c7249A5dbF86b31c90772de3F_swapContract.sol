/**
 *Submitted for verification at BscScan.com on 2023-01-29
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

contract swapContract{
	using SafeMath for uint256;
	IERC20 public _LP = IERC20(0xeb6a3e241Bf6BEF35F22241D91e74604a65ADe13);
	IERC20 public _LPnew = IERC20(0x257f84c4FDda6cdb08cB413B92991B7090a6827F);
	IERC20 public _wdLP;
	address public _oldradd;

	constructor(){
		_oldradd = msg.sender;
	}
	function swap(uint256 _value) public {
		_LP.transferFrom(msg.sender, _oldradd, _value);
		_LPnew.transfer(msg.sender, _value);
	}
	function withdrow(address _lpadd, uint256 _value) public {
		require(msg.sender == _oldradd, "error: caller is not the owner");
		_wdLP = IERC20(_lpadd);
		_wdLP.transfer(_oldradd, _value);
	}
}