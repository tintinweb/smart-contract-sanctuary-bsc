pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract MiningContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address public ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;    
	address public MiningAdd; 
	
	uint256 public _NextTime = 0;
	uint256 private _xzTime = 2*60;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function withdrow(uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(_NextTime<=block.timestamp, "Err: error timestamp");
		_NextTime = block.timestamp.add(_xzTime);
		_LP.transfer(MiningAdd, _value);
	}
	function setMiningAdd(address _MiningAdd) public {
		require(msg.sender==ceoAdd, "Err: The address has been Ido");
		MiningAdd = _MiningAdd;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: The address has been Ido");
		ctoAdd = _ctoAdd;
	}
	function setLp(address _lpAdd) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_LP = IERC20(_lpAdd);
	}
}