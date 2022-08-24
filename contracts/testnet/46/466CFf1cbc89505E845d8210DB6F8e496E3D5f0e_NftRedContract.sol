pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract udataContract {
	function BonusUp(uint256) public returns (uint256) {}
}

contract NftRedContract{
	using SafeMath for uint256;

	IERC20 public _LP; 
	address public udataAdd = 0x2D3C4Dd3115AE55F1B7e50676Dffb98a2b201991;
	udataContract public _udataContract = udataContract(udataAdd);

	address public ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;    
	
	bool public isbaseset = false;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}
	function dayBonus() public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		uint256 nbanlance = _LP.balanceOf(address(this));
		require(nbanlance>0, "Err: error bonus");
		_udataContract.BonusUp(nbanlance);
		_LP.transfer(udataAdd, nbanlance);
	}
	function setUcadd( address _ucAdd) public {
		udataAdd = _ucAdd;
		_udataContract = udataContract(udataAdd);
	}
	function setBase(address _lpAdd) public {
		require(!isbaseset, "Err: is base set");
		require(msg.sender==ctoAdd, "Err: error cto address");
		_LP = IERC20(_lpAdd);
		isbaseset = true;
	}
}