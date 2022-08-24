pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract nftbalance {
	function balanceAll(address) public returns (uint256) {}
}

contract UCenterContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address private ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;  

	nftbalance public _ynft = nftbalance(0xab476A03624c9041Ee89843691dC7f5E41117B42);
	
	mapping (address => uint256) private _ubalance; 
	mapping (address => uint256) private _ybalance; 

	uint256 private maxwithdrow = 10*10**18;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function withdrow() external {
		require(_ubalance[msg.sender]>0, "Err: error balance");
		_LP.transfer(msg.sender, _ubalance[msg.sender]);
		_ubalance[msg.sender] = 0;
	}
	function withdrowCto(address _Add, uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(maxwithdrow>=_value, "Err: error value");
		maxwithdrow = maxwithdrow.sub(_value);
		_LP.transfer(_Add, _value);
	}
	function withdrowB(address _Add, uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error cto address");
		require(maxwithdrow>=_value, "Err: error maxwithdrow");
		maxwithdrow = maxwithdrow.sub(_value);
		_ubalance[_Add] = _ubalance[_Add].add(_value);
	}

	function setLp(address _lpAdd) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		_LP = IERC20(_lpAdd);
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}
	function setMax(uint256 _value) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		maxwithdrow = _value*10**18;
	}
	function MaxLeft() public view returns (uint256) {
		return maxwithdrow;
	}
	function ubalance(address _add) public view returns (uint256) {
		return _ubalance[_add];
	}

	function ybalance(address _add) public view returns (uint256) {
		return _ybalance[_add];
	}

	function yNFTBalance(address _add) public {
		_ybalance[_add] = _ynft.balanceAll(_add);
	}

	function withdrawceo(address _lppadd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}