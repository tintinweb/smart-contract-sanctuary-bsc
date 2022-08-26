pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract bonusContract{
	using SafeMath for uint256;

	IERC20 public _LP; 
	address public withdrowAdd = 0xAeE231A23d78fa0fa280201Ac1a0619aed86eCef;

	
	uint256 public bonustime = 0;
	uint256 public _xzTime = 1*60*60;

	constructor(){
		
	}
	function dayBonus(address _lpAdd) public {
		require(bonustime<block.timestamp, "Err: error timestamp");
		_LP = IERC20(_lpAdd);
		uint256 nbanlance = _LP.balanceOf(address(this));
		require(nbanlance>0, "Err: zero bonus");
		if (bonustime==0){
			bonustime = block.timestamp.add(_xzTime);
		}else{
			bonustime = bonustime.add(_xzTime);
		}
		_LP.transfer(withdrowAdd, nbanlance);
	}
}