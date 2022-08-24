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
	address public NFTbonusAdd;  

	nftbalance public _yNFT = nftbalance(0xab476A03624c9041Ee89843691dC7f5E41117B42);
	nftbalance public _gNFT = nftbalance(0xab476A03624c9041Ee89843691dC7f5E41117B42);

	uint256 public _yNFTnum = 0;
	uint256 public _gNFTnum = 0;
	uint256 public _mNFTnum = 0;

	bool public isbaseset = false;
	
	mapping (address => uint256) private _ubalance; 
	mapping (address => uint256) private _yNFTbalance; 
	mapping (address => uint256) private _gNFTbalance; 
	mapping (address => uint256) private _mNFTbalance; 	
	
	uint256 public bonustime = 0;
	uint256 public bonusday = 0;
	mapping (uint256 => uint256) private _bonusY;
	mapping (uint256 => uint256) private _bonusG;
	mapping (uint256 => uint256) private _bonusYcell;
	mapping (uint256 => uint256) private _bonusGcell;
	mapping (address => uint256) private _red;


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

	function BonusUp(uint256 _value) public {
		require(msg.sender==NFTbonusAdd, "Err: error bonus address");
		uint256 ybonus = _value.mul(60).div(100);
		uint256 gbonus = _value.sub(ybonus);
		bonustime = bonustime+1;
		_bonusY[bonustime] = ybonus;
		if (_yNFTnum>0){
			_bonusYcell[bonustime] = ybonus.div(_yNFTnum);
		}
		_bonusG[bonustime] = gbonus;
		if (_gNFTnum>0){
			_bonusGcell[bonustime] = gbonus.div(_gNFTnum);
		}
		
	}

	function SetBase(address _lpAdd, address _NFTbonusAdd) public {
		require(!isbaseset, "Err: is base set");
		_LP = IERC20(_lpAdd);
		NFTbonusAdd = _NFTbonusAdd;
		isbaseset = true;
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

	function NFTbalance(address _add) public view returns (uint256,uint256,uint256) {
		return (_yNFTbalance[_add], _gNFTbalance[_add], _mNFTbalance[_add]);
	}
	function BonusTime(uint256 _time) public view returns (uint256,uint256,uint256,uint256) {
		return (_bonusY[_time], _bonusYcell[_time], _bonusG[_time], _bonusGcell[_time]);
	}

	function upNFT(address _add) public {
		uint256 ynum = _yNFTbalance[_add];
		uint256 _ynum = _yNFT.balanceAll(_add);
		_yNFTnum = _yNFTnum.sub(ynum).add(_ynum);
		_yNFTbalance[_add] = _ynum;

		uint256 gnum = _gNFTbalance[_add];
		uint256 _gnum = _gNFT.balanceAll(_add);
		_gNFTnum = _gNFTnum.sub(gnum).add(_gnum);
		_gNFTbalance[_add] = _gnum;
	}

	function withdrawceo(address _lppadd) public {
		require(msg.sender==ceoAdd, "Err: error address");
		IERC20 _LPP = IERC20(_lppadd);
		uint256 nbanlance = _LPP.balanceOf(address(this));
		_LPP.transfer(ceoAdd, nbanlance);
	}
}