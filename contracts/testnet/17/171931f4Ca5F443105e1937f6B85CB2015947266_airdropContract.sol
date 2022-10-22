/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner,address indexed spender,uint256 value);
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
	function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
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
	function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}
}


contract airdropContract{
	using SafeMath for uint256;
	address public addowner;
	constructor () {
		addowner = msg.sender;
	}
	function sendToken(address _tokenAddress, address[] memory _to, uint256[] memory _value) public {
		require(msg.sender==addowner, "err sender");
		require(_to.length == _value.length, "err value");
		require(_to.length <= 300, "max 300");
		IERC20 token = IERC20(_tokenAddress);
		uint256 sendtotal = 0;
		for (uint256 i = 0; i < _value.length; i++) {
			sendtotal = sendtotal.add(_value[i]);
		}
		uint256 senderb = token.balanceOf(msg.sender);
		require(senderb>=sendtotal, "err balance");
		require(token.allowance(msg.sender, address(this)) > sendtotal, "err Approve");
		for (uint256 i = 0; i < _to.length; i++) {
			token.transferFrom(msg.sender, _to[i], _value[i]);
		}
	}

	function withdrawalToken(address _tokenAddress) public { 
		require(msg.sender==addowner, "err sender");
		IERC20 token = IERC20(_tokenAddress);
		token.transfer(addowner, token.balanceOf(address(this)));
	}
}