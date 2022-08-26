pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract withdrowC {
	function dayBonusNum() public returns (uint256) {}
}

contract MiningContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address public withdrowAdd = 0xAeE231A23d78fa0fa280201Ac1a0619aed86eCef;
	withdrowC private _withdrowC = withdrowC(withdrowAdd);

	uint256 public _NextTime = 0;
	uint256 private _xzTime = 1*60*60;

	constructor(){
		
	}
	function withdrow(address _lpAdd) external {
		require(_NextTime<=block.timestamp, "Err: error timestamp");
		uint256 _BonusNum = _withdrowC.dayBonusNum();
		if (_NextTime>0){
			_NextTime = _NextTime.add(_xzTime);
		}else{
			_NextTime = block.timestamp.add(_xzTime);
		}
		_LP = IERC20(_lpAdd);
		_LP.transfer(withdrowAdd, _BonusNum);
	}
}