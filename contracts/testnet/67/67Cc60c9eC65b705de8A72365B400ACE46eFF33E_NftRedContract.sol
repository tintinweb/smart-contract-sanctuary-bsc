pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract NftRedContract{
	using SafeMath for uint256;

	IERC20 public _LP; 
	address public udataAdd = 0x59Cdc6b4De372CE38977106a124113E017711EE7;

	address public ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4; 
	
	uint256 public bonustime = 0;
	uint256 public bonusday = 0;
	uint256 public mintimes = 23*60*60;
	mapping (uint256 => uint256) private _bonustime;

	
	bool public isbaseset = false;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}
	function dayBonus() public {
		require(bonusday<block.timestamp, "Err: error timestamp");
		uint256 nbanlance = _LP.balanceOf(address(this));
		require(nbanlance>0, "Err: zero bonus");
		bonustime = bonustime+1;
		_bonustime[bonustime] = nbanlance;
		bonusday = block.timestamp.add(mintimes);
		_LP.transfer(udataAdd, nbanlance);
	}
	function nftbonustime(uint256 _times) public view returns (uint256) {
		return _bonustime[_times];
	}
	function setUcadd(address _ucAdd) public {
		udataAdd = _ucAdd;
	}
	function setBase(address _lpAdd) public {
		require(!isbaseset, "Err: is base set");
		require(msg.sender==ctoAdd, "Err: error cto address");
		_LP = IERC20(_lpAdd);
		isbaseset = true;
	}
}