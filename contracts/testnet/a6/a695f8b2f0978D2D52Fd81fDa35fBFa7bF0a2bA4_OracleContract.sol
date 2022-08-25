pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./SafeMath.sol";

contract withdrowC {
	function dayLeftu(address) public returns (uint256) {}
	function wostatus(uint256) public returns (uint256) {}
}

contract OracleContract{
	using SafeMath for uint256;

	address private ceoAdd;   
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4; 
	bool public isbaseset = false;

	withdrowC private _withdrowC;
	
	mapping (address => uint256) private _uolist; 
	mapping (uint256 => uint256) private _uoinfo; 
	uint256 private psdcode1 = 456;   
	uint256 private psdcode2 = 234;   
	uint256 private psdcode3 = 123;
	uint256 private psdcode4 = 1000000;

	constructor(){
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}
	function withdrow(address _add, uint256 _value, uint256 _oid, uint256 _checknum) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(_uolist[_add]==0, "Err: error oid");
		require(_uoinfo[_oid]==0, "Err: error oid");
		uint256 ncheckv = _value.add(psdcode1);
		uint256 nchecko = _oid.add(psdcode2);
		ncheckv = ncheckv.mul(nchecko).add(psdcode3);
		ncheckv = ncheckv%psdcode4;
		require(ncheckv==_checknum, "Err: error _checknum");
		uint256 _dayleft = _withdrowC.dayLeftu(_add);
		require(_value<=_dayleft, "Err: error dayleft");
		_uolist[_add] = _oid;
		_uoinfo[_oid] = _value;
	}

	function upccc(uint256 _value) external {
		require(msg.sender==ctoAdd, "Err: error address");
		psdcode3 = _value;
	}

	function uporder(address _add, uint256 _oid) external {
		require(msg.sender==ctoAdd, "Err: error address");
		require(_uolist[_add]>0, "Err: error _add");
		require(_uolist[_add]==_oid, "Err: error oid");
		require(_uoinfo[_oid]>0, "Err: error oid");
		uint256 _ostatus = _withdrowC.wostatus(_oid);
		_uolist[_add] = 0;
		if (_ostatus>0){
			_uoinfo[_oid] = 1;
		}else{
			_uoinfo[_oid] = 2;
		}
	}

	function ovalue(address _add, uint256 _oid) public view returns (uint256) {
		uint256 _balance = 0;
		if (_uolist[_add]>0 && _uolist[_add]==_oid && _uoinfo[_oid]>3){
			_balance = _uoinfo[_oid];
		}
		return _balance;
	}

	function ostatus(uint256 _oid) public view returns (uint256) {
		return _uoinfo[_oid];
	}

	function ustatus(address _add) public view returns (uint256, uint256) {
		return (_uolist[_add], _uoinfo[_uolist[_add]]);
	}


	function SetBase(address _add) public {
		require(!isbaseset, "Err: is base set");
		_withdrowC = withdrowC(_add);
		isbaseset = true;
	}

	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}
	
}