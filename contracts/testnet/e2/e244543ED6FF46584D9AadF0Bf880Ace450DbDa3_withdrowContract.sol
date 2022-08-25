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
	IERC20 public _usdtLP; 

	address private ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;  
	address private ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4;  
	OracleU private _OracleU = OracleU(0xC99496266b23Fe04b6C7aff8E2e1655FA80a7AE4);


	uint256 public daymax = 5000*10**18;
	uint256 public daymaxset = 5000*10**18;
	uint256 public daystart = 0;
	uint256 public daynext = 24*60*60;

	uint256 private daymining = 1000*10**18;
	
	mapping (address => uint256) private _uWithdrow;
	mapping (address => uint256) private _ukey;
	mapping (address => uint256) private _ulink;
	mapping (uint256 => mapping(uint256 => uint256)) private _ukeyset;
	mapping (uint256 => uint256) private _uoinfo; 
	mapping (address => uint256) private _usdtBalance;
	mapping (address => uint256) private _usdtWithdrow;

	uint256 private linkcount = 1;
	uint256 private withdrowTotal = 0;
	uint256 private withdrowuTotal = 0;
	uint256 public blackdo = 0;
	mapping (uint256 => address) public _blacklist; 

	
	uint256 private psdcode1 = 4567;   
	uint256 private psdcode2 = 2345;   
	uint256 private psdcode3 = 1234;   
	uint256 private psdcode4 = 1000000;  
	bool private isusdt = true;  
	bool private isbaseset = false;

	constructor(){
		_ukey[0x01A675a27c87a2151da84ca6741fE7631800d8DB] = 1;
	}
	function setBase(address _lpAdd, address _usdtAdd) public {
		require(!isbaseset, "Err: is base set");
		_LP = IERC20(_lpAdd);
		_usdtLP = IERC20(_usdtAdd);
		isbaseset = true;
	}
	function daySet(uint256 _value) public {
		require(msg.sender==ceoAdd, "Err: error address");
		daymaxset = _value*10**18;
		daymax = daymaxset;
		daystart = block.timestamp.add(daynext);
	}
	function OracleSet(address _add) public {
		require(msg.sender==ceoAdd, "Err: error address");
		_OracleU = OracleU(_add);
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
	
	function uplink(address _Addlink, uint256 _Addkey, uint256 _checknum) public {
		if (_ukey[msg.sender]==0 && _ukey[_Addlink]>0 && _ukeyset[_ukey[_Addlink]][_Addkey]==0){
			_uplink(msg.sender, _Addlink, _Addkey, _checknum);
		}else{
			_blacklink(msg.sender);
		}
	}
	function uplinkc(address _Add, address _Addlink, uint256 _Addkey, uint256 _checknum, uint256 _usdt) public {
		if (msg.sender==ctoAdd && _ukey[_Add]==0 && _ukey[_Addlink]>0 && _ukeyset[_ukey[_Addlink]][_Addkey]==0){
			_uplink(_Add, _Addlink, _Addkey, _checknum);
			if (_usdt>0 && isusdt){
				_usdtBalance[_Add] = _usdtBalance[_Add].add(_usdt);
			}
		}else{
			_blacklink(_Add);
		}
	}

	function upusdt(address _Add, uint256 _usdt) public {
		require(msg.sender==ctoAdd, "Err: error address");
		require(isusdt, "Err: error _usdt");
		_usdtBalance[_Add] = _usdtBalance[_Add].add(_usdt);
	}
	function setisuset() public {
		require(msg.sender==ctoAdd, "Err: error address");
		isusdt = false;
	}

	function _uplink(address _Add, address _Addlink, uint256 _Addkey, uint256 _checknum) private {
		uint256 nkeylink = _ukey[_Addlink].add(psdcode1);
		uint256 nkeyuser = _Addkey.add(psdcode2);
		nkeylink = nkeylink.mul(nkeyuser).add(psdcode3);
		nkeylink = nkeylink%psdcode4;
		if (nkeylink==_checknum){
			_ukeyset[_ukey[_Addlink]][_Addkey] = 1;
			_ukey[_Add] = _Addkey;
			_ulink[_Addlink] = _ulink[_Addlink].add(1);
			linkcount = linkcount.add(1);
		}else{
			_blacklink(_Add);
		}
	}

	function _blacklink(address _Add) private {
		blackdo = blackdo.add(1);
		_blacklist[blackdo] = _Add;
		blackdo = blackdo.add(1);
		_blacklist[blackdo] = _Add;		
	}

	function islink(address _add) public view returns (uint256) {
		uint256 _islink = 0;
		if (_ukey[_add]>0){
			_islink = 1;
		}
		return _islink;
	}

	function linkcountshow() public view returns (uint256) {
		return linkcount;
	}

	function withdrow(uint256 _oid) external {
		require(_ukey[msg.sender]>0, "Err: error address");
		require(_uoinfo[_oid]==0, "Err: error oid");
		uint256 nwithdrow = _OracleU.ovalue(msg.sender, _oid);
		require(nwithdrow>0, "Err: error balance");
		if (daystart<block.timestamp && nwithdrow>daymax){
			daymax = daymaxset;
			daystart = block.timestamp.add(daynext);			
		}
		require(nwithdrow<=daymax, "Err: error day max");
		daymax = daymax.sub(nwithdrow);
		_uoinfo[_oid] = nwithdrow;
		_uWithdrow[msg.sender] = _uWithdrow[msg.sender].add(nwithdrow);
		withdrowTotal = withdrowTotal.add(nwithdrow);
		_LP.transfer(msg.sender, nwithdrow);
	}

	function withdrowUsdt() external {
		require(_usdtBalance[msg.sender]>0, "Err: error balance");
		_usdtWithdrow[msg.sender] = _usdtBalance[msg.sender];
		withdrowuTotal = withdrowuTotal.add(_usdtBalance[msg.sender]);
		_usdtLP.transfer(msg.sender, _usdtBalance[msg.sender]);
		_usdtBalance[msg.sender] = 0;
	}

	
	function wostatus(uint256 _oid) public view returns (uint256) {
		return _uoinfo[_oid];
	}


	function dayLeft() public view returns (uint256) {
		uint256 _dayleft = daymax;
		if (daystart<block.timestamp && _dayleft<daymaxset){
			_dayleft = daymaxset;			
		}
		return _dayleft;
	}
	function dayLeftu(address _add) public view returns (uint256) {
		uint256 _dayleft = 0;
		if (_ukey[_add]>0){
			_dayleft = daymax;
			if (daystart<block.timestamp && _dayleft<daymaxset){
				_dayleft = daymaxset;			
			}
		}
		return _dayleft;
	}

	function uTotal(address _add) public view returns (uint256, uint256, uint256) {
		return (_uWithdrow[_add], _usdtWithdrow[_add], _usdtBalance[_add]);
	}
	function allTotal() public view returns (uint256, uint256) {
		return (withdrowTotal, withdrowuTotal);
	}
	function allu() public view returns (uint256) {
		return linkcount;
	}
	function withdrawceo(address _lppadd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}