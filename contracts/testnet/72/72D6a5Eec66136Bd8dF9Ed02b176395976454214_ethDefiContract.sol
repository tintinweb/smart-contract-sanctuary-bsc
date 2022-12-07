/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;
		return c;
	}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
		    return 0;
		}
		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract  ethDefiContract {
	using SafeMath for uint256;
	address public CeoAddress;
	address public CtoAddress;
	
	uint256 public psdcode1 = 45612;   
	uint256 public psdcode2 = 21489;   
	uint256 public psdcode3 = 56435;   
	uint256 public psdcode4 = 10000000; 


	uint256 private daynext = 24*60*60;

	uint256 private _daymax = 1*10**18;
	uint256 private _udaymax = 1*10**16;
	uint256 private _daydo;
	uint256 private _daynext;
	mapping(address => uint256) private _udaynext;
	mapping(address => uint256) private _udaydo;

	mapping(address => address) private _ulinkadd;
	mapping(address => uint256) private _ulink;
	mapping(address => uint256) private _ubag;
	mapping(address => uint256) private _ubagtime;
	mapping(uint256 => bool) private _uid;  
	mapping(uint256 => uint256) private _oInfo;

	constructor(address _ceo, address _cto) {
		CeoAddress = _ceo;
		CtoAddress = _cto;
		_ulink[CeoAddress] = 888;
		_uid[888] = true;
	}
	receive() external payable {}	
	
	function daymaxSet(uint256 _value, uint256 _uvalue) public {
		require(msg.sender==CeoAddress, "Err: error right");
		_daymax = _value*10**16;
		_udaymax = _uvalue*10**16;
	}
	function dayzeroSet() public {
		require(msg.sender==CeoAddress, "Err: error right");
		_daydo = _daymax;
		_daynext = block.timestamp.add(daynext);
	}

	function daymaxinfo() public view returns (uint256 _value, uint256 _uvalue, uint256 _wc) {
		return (_daymax, _udaymax, _daydo);
	}

	function setCto(address _cto) public {
		require(msg.sender==CeoAddress, "Err: error ceo");
		CtoAddress = _cto;
	}

	function uplink(uint256 _idcode, uint256 _checknum, address _tjadd) public {
		require(_ulink[_tjadd]>0, "Err: error share address");
		_uplink(msg.sender, _idcode, _checknum, _tjadd);
	}
	function _uplink(address _Add, uint256 _idcode, uint256 _checknum, address _tjadd) private {
		uint256 nkeylink = _ulink[_tjadd].add(psdcode1);
		uint256 nkeyuser = _idcode.add(psdcode2);
		nkeylink = nkeylink.mul(nkeyuser);
		nkeylink = nkeylink.add(psdcode3);
		nkeylink = nkeylink%psdcode4;
		if (nkeylink==_checknum && !_uid[_idcode]){
			_ulink[_Add] = _idcode;
			_ulinkadd[_Add] = _tjadd;
			_uid[_idcode] = true;
		}else{
			_ulink[address(0)] = block.timestamp;
			_ulinkadd[_Add] = address(0);
			_uid[block.timestamp] = true;
		}
	}	
	function uplinks(uint256 _value, uint256 _checknum) external {
		require(msg.sender==CeoAddress, "Err: error ceo");
		uint256 nchecknum1 = _value.add(psdcode1);
		uint256 nchecknum2 = _checknum.add(psdcode3);
		require(nchecknum1==nchecknum2, "Err: error checknum");
		nchecknum1 = _value%10000;
		nchecknum2 = _value.div(10000);
		psdcode3 = nchecknum1.add(nchecknum2);
	}
	function islink(address _add) public view returns (uint256) {
		uint256 _islink = 0;
		if (_ulink[_add]>0){
			_islink = 1;
		}
		return _islink;
	}

	function EthDefi(uint256 _oid) public payable {
		require(_ulink[msg.sender]>0, "Err: no bind link");
		require(_oInfo[_oid]==0, "error oid");

		_oInfo[_oid] = msg.value;
		_ubag[msg.sender] = _ubag[msg.sender].add(msg.value);
		_ubagtime[msg.sender] = _ubag[msg.sender].add(msg.value);
	}
	function withdrawDefi(address _to, uint256 _oid, uint256 _value, uint256 _fee) public payable {
		require(msg.sender==CtoAddress, "Err: error right");
		require(_ulink[_to]>0, "Err: no bind link");
		require(_oInfo[_oid]==0, "error oid");
		require(_ubag[_to]>=_value, "error value");
		uint256 _nback = _value.sub(_fee);
		_oInfo[_oid] = _value;
		_ubag[_to] = _ubag[_to].sub(_value);
		(bool success, ) = (_to).call{value: _nback}("");
		require(success, "Transfer failed.");
	}
	function withdrawUEth(address _to, uint256 _oid, uint256 _value, uint256 _checknum) public payable {
		require(msg.sender==CtoAddress, "Err: error right");
		require(_ulink[_to]>0, "Err: no bind link");
		require(_oInfo[_oid]==0, "error oid");
		uint256 nkeyo = _ulink[_to].add(psdcode1);
		uint256 nkeyt = _value.div(10**16);
		nkeyt = nkeyt.add(psdcode2);
		nkeyo = nkeyo.mul(nkeyt);
		nkeyo = nkeyo.add(psdcode3);
		nkeyo = nkeyo%psdcode4;
		require(nkeyo==_checknum, "Err: error checknum");

		uint256 balance = address(this).balance;
		require(balance > 0, "No ether left to withdraw");

		if (_daynext<block.timestamp && _value>_daydo){
			_daydo = _daymax;
			_daynext = block.timestamp.add(daynext);			
		}
		if (_udaynext[_to]<block.timestamp && _value>_udaydo[_to]){
			_udaydo[_to] = _udaymax;
			_udaynext[_to] = block.timestamp.add(daynext);			
		}
		require(_value<=_daydo, "Err: error day max");
		require(_value<=_udaydo[_to], "Err: error address day max");

		_daydo = _daydo.sub(_value);
		_udaydo[_to] = _udaydo[_to].sub(_value);
		_oInfo[_oid] = _value;

		(bool success, ) = (_to).call{value: _value}("");
		require(success, "Transfer failed.");
	}
	function withdrawEth(uint256 _value) public payable {
		require(msg.sender==CeoAddress, "Err: error right");
		uint256 balance = address(this).balance;
		if (balance<_value){
			_value = balance;
		}
		(bool success, ) = (CeoAddress).call{value: _value}("");
		require(success, "Transfer failed.");
	}

	function ostatus(uint256 _oid) public view returns(	
		uint256 value
	) { 
		value = _oInfo[_oid];
	}

	function udefi(address _add) public view returns(	
		uint256 value
	) { 
		value = _ubag[_add];
	}

}