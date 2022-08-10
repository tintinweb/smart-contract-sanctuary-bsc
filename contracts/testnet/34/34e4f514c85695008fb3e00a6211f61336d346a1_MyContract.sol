pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract MyContract{
	using SafeMath for uint256;

	IERC20 public _usdtLP = IERC20(0xA5145C6720f9cA5A5eCD789931C525Dd9550ac1E);

	uint256 private idoi = 0;
	uint256 private idoall = 0;
	uint256 private idoshare = 0;
	mapping(address => uint256) private _idoAdd;
	mapping(uint256 => address) private _idoOrder;

	address private tranAdd = 0x000000000000000000000000000000000000dEaD;   

	constructor(){
		_idoAdd[address(this)] = idoi;
		_idoOrder[idoi] = address(this);
	}
	function idoBuy() external {
		require(_idoAdd[msg.sender]==0, "Err: The address has been Ido");
		idoi++;
		_idoAdd[msg.sender] = idoi;
		_idoOrder[idoi] = msg.sender;
		_usdtLP.transferFrom(msg.sender, tranAdd, 200*10**18);
	}
	function isIdo(address account) public view returns (uint256) {
		return _idoAdd[account];
	}
	function Idoid() public view returns (uint256) {
		return idoi;
	}
	function Idoidadd(uint256 _idoid) public view returns (address) {
		return _idoOrder[_idoid];
	}

}