pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract MyContract{
	using SafeMath for uint256;

	IERC20 public _usdtLP = IERC20(0xdaf85821BD2840962d36637b988d4694559EB23b);

	uint256 private idoi = 0;
	uint256 private idoall = 0;
	uint256 private idoshare = 0;
	mapping(address => uint256) private _idoAdd;
	mapping(uint256 => address) private _idoOrder;

	address private tranAdd = 0xD110E90D37B3A2eAB848512f972d4063530674dc;   

	constructor(){
		_idoAdd[msg.sender] = idoi;
		_idoOrder[idoi] = msg.sender;
		idoi++;
	}
	function idoBuy() external {
		require(_idoAdd[msg.sender]==0, "Err: The address has been Ido");
		_idoAdd[msg.sender] = idoi;
		_idoOrder[idoi] = msg.sender;
		idoi++;
		_usdtLP.transferFrom(msg.sender, tranAdd, 200*10**6);
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