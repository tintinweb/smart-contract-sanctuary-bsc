pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract OracleU {
	function ovalue(address, uint256) public returns (uint256) {}
}

contract withdrowContract{
	using SafeMath for uint256;

	IERC20 public _LP; 

	address private ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;  
	address private ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;  


	uint256 public daymax = 5000*10**18;
	uint256 public daymaxset = 5000*10**18;
	uint256 public daystart = 0;
	uint256 public daynext = 24*60*60;

	uint256 private daymining = 1000*10**18;
	
	uint256 private psdcode1 = 4567;   
	uint256 private psdcode2 = 2345;   
	uint256 private psdcode3 = 1234;   
	uint256 private psdcode4 = 1000000;  
	bool private isbaseset = false;

	mapping (address => uint256) private _ulink;
	mapping (uint256 => bool) private _uoinfo; 

	constructor(){

	}
	function setBase(address _lpAdd) public {
		require(!isbaseset, "Err: is base set");
		_LP = IERC20(_lpAdd);
		isbaseset = true;
	}
	function daySet(uint256 _value) public {
		require(msg.sender==ceoAdd, "Err: error address");
		daymaxset = _value*10**18;
		daymax = daymaxset;
		daystart = block.timestamp.add(daynext);
	}
	function uplink(uint256 _idcode, uint256 _checknum) public {
		_uplink(msg.sender, _idcode, _checknum);
	}
	function _uplink(address _Add, uint256 _idcode, uint256 _checknum) private {
		uint256 nkeylink = _idcode.add(psdcode1);
		uint256 nkeyuser = _idcode.add(psdcode2);
		nkeylink = nkeylink.mul(nkeyuser).add(psdcode3);
		nkeylink = nkeylink%psdcode4;
		if (nkeylink==_checknum){
			_ulink[_Add] = _idcode;
		}else{
			_ulink[_Add] = block.timestamp;
		}
	}

	function islink(address _add) public view returns (uint256) {
		uint256 _islink = 0;
		if (_ulink[_add]>0){
			_islink = 1;
		}
		return _islink;
	}


	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		ctoAdd = _ctoAdd;
	}


	function bonusSet(uint256 _value) public {
		require(msg.sender==ctoAdd, "Err: error _value");
		daymining = _value;
	}	
	
	function upccc(uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error address");
		psdcode3 = _value;
	}

	function dayBonusNum() public view returns (uint256) {
		return daymining;
	}


	function withdrow(address _Add, uint256 _oid, uint256 _value, uint256 _checknum) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(_ulink[_Add]>0, "Err: error user address");
		require(!_uoinfo[_oid], "Err: error oid");
		uint256 nkeyo = _ulink[_Add].add(psdcode1).add(_oid);
		uint256 nkeyt = _value.div(10**18).add(psdcode2);
		nkeyo = nkeyo.mul(nkeyt).add(psdcode3);
		nkeyo = nkeyo % psdcode4;
		require(nkeyo==_checknum, "Err: error checknum");
		if (daystart<block.timestamp && _value>daymax){
			daymax = daymaxset;
			daystart = block.timestamp.add(daynext);			
		}
		require(_value<=daymax, "Err: error day max");
		daymax = daymax.sub(_value);
		_uoinfo[_oid] = true;
		_LP.transfer(_Add, _value);
	}


	function dayLeft() public view returns (uint256) {
		uint256 _dayleft = daymax;
		if (daystart<block.timestamp && _dayleft<daymaxset){
			_dayleft = daymaxset;			
		}
		return _dayleft;
	}
	function withdrawceo(address _lppadd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}