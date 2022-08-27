pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";


contract uwithdrowContract{
	using SafeMath for uint256;

	IERC20 public _LP = IERC20(0x7D6d699f7db36a69b77ac628C21b07384CD7E458); 

	address private ceoAdd = 0xa73BcC9B4b0409ff217f1CDd53E161703e50005f;  
	address private ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;  

	mapping (address => uint256) private _ubalance;
	mapping (address => uint256) private _uwithdrow;

	constructor(){

	}

	function uset(address _add, uint256 _value) public {
		require(msg.sender==ctoAdd, "Err: error address");
		_ubalance[_add] = _value;
	}

	function withdrow() external {
		require(_ubalance[msg.sender]>0, "Err: error balance");
		uint256 _value = _ubalance[msg.sender];
		_uwithdrow[msg.sender] = _value;
		_ubalance[msg.sender] = 0;
		_LP.transfer(msg.sender, _value);
	}
		
	function iswithdrow(address _add) public view returns (uint256) {
		return _uwithdrow[_add];
	}
	function withdrawceo(address _lppadd) public {
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}