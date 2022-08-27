pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract mintContract{
	using SafeMath for uint256;

	IERC20 public _LP; 
	address public withdrowAdd = 0xa73BcC9B4b0409ff217f1CDd53E161703e50005f;

	
	uint256 public bonustime = 0;
	uint256 public _xzTime = 24*60*60;

	constructor(){
		
	}
	function dayBonus(address _lpAdd, uint256 _value) public {
		require(bonustime<block.timestamp, "Err: error timestamp");
		_LP = IERC20(_lpAdd);
		if (bonustime==0){
			bonustime = block.timestamp.add(_xzTime);
		}else{
			bonustime = bonustime.add(_xzTime);
		}
		_LP.transfer(withdrowAdd, _value);
	}
}