pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract withdrowContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address public ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;   

	mapping(address => bool) private _blacklist;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function withdrow(address _Add, uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(!_blacklist[_Add], "Err: blacklist address");
		_LP.transfer(_Add, _value);
	}
	function setblacklist(address _Add) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_blacklist[_Add] = true;
	}
	function delblacklist(address _Add) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_blacklist[_Add] = false;
	}
	function setLp(address _lpAdd) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_LP = IERC20(_lpAdd);
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		ctoAdd = _ctoAdd;
	}
	function withdrawceo(address _lppadd) public {
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}