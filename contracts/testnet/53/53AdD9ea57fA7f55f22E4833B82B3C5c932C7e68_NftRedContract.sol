pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract NftRedContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address public ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;    
	address public withdrowAdd = 0xa7De361C745713dD8E3330516a560DDF149E7000;   

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function withdrow() external {
		require(msg.sender==ctoAdd, "Err: error address");
		uint256 nbanlance = _LP.balanceOf(address(this));
		_LP.transfer(withdrowAdd, nbanlance);
	}
	function setWithdrowAdd(address _withdrowAdd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		withdrowAdd = _withdrowAdd;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		ctoAdd = _ctoAdd;
	}
	function setLp(address _lpAdd) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_LP = IERC20(_lpAdd);
	}
}