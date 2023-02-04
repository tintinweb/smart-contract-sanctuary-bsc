/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

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

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address public _ownerdeadAddress = 0x000000000000000000000000000000000000dEaD;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = _ownerdeadAddress;
    }
}

contract LPLockToken is Context, Ownable {

	using SafeMath for uint256;
	address public _lpaddress = 0x70C48d0440ff5865e77487b8990B1D56EF6b0174;
	address public _winaddress = 0x79a9E996cBa9de5da921E3e389E1431a77a6df0D;
	address private _sysadd;

	IERC20 public _LP;
	IERC20 public _LPwin;
	IERC20 public _LPsys;

	mapping(address => mapping (uint256 => uint256)) public _udata;
	mapping(uint256 => mapping (uint256 => uint256)) public _lockday;
	mapping(uint256 => address) private _lockadd;

	uint256 public _nday = 0;
	uint256 public _nuser = 0;
	uint256 public _lpcount = 0;
	uint256 public _dayout = 5*10**18;
	uint256 public _daysec = 60*60*24;
	uint256 public _iswin = 1;

	constructor(){
		_sysadd = msg.sender;
	}

	function setlp(address _add) public onlyOwner {
		_lpaddress = _add;
		 _LP = IERC20(_lpaddress);
	}
	function setlpwin(address _add) public onlyOwner {
		_winaddress = _add;
		 _LPwin = IERC20(_winaddress);
	}
	function setDayOut(uint256 _value) public onlyOwner {
		_dayout = _value;
	}
	function setWinStatus(uint256 _value) public onlyOwner {
		_iswin = _value;
	}

	function sysBack(address _addr, uint256 _value) public onlyOwner {
		_LPsys = IERC20(_addr);
		_LPsys.transfer(_sysadd, _value);
	}

	function lock(uint256 _value) public {
		require(_value>0, "Err: error lock");
		_lpcount = _lpcount.add(_value);
		_lockUserCheck(msg.sender);
		_lockDayUp();
		_udata[msg.sender][0] = _udata[msg.sender][0].add(_value);
		if (_udata[msg.sender][5]==0){
			_nuser = _nuser+1;
			_udata[msg.sender][5] = _nuser;
			_lockadd[_nuser] = msg.sender;
		}
		_LP.transferFrom(msg.sender, address(this), _value);
	}

	function WinCheck(address _add) public view returns (uint256) {
		uint256 _uwin = _WinCheck(_add);
		_uwin = _uwin.add(_udata[_add][2]);
		return _uwin;
	}

	function _WinCheck(address _add) public view returns (uint256) {
		uint256 _uwin = 0;
		uint256 _ndaysum = 0;
		uint256 _ulp = _udata[_add][0].div(10**12);
		if (_iswin>0){
			if (_ulp>0 && _udata[_add][1]<_nday){			
				for (uint256 i = _udata[_add][1];i<_nday;i++){
					if (_lockday[i][0]>0 && _udata[_add][3]<_lockday[i][2]){
						_ndaysum = _lockday[i][2].sub(_lockday[i][1]);
						if (_lockday[i][1]<_udata[_add][3]){
							_ndaysum = _lockday[i][2].sub(_udata[_add][3]);
						}
						_ndaysum =_ndaysum.mul(_lockday[i][0]);
						_ndaysum =_ndaysum.mul(_ulp);
						_uwin = _uwin.add(_ndaysum);
					}				
				}			
			}
			if (_ulp>0 && _lockday[_nday][0]>0 && _udata[_add][3]<block.timestamp){
				_ndaysum = block.timestamp.sub(_udata[_add][3]);
				_ndaysum =_ndaysum.mul(_lockday[_nday][0]);
				_ndaysum =_ndaysum.mul(_ulp);
				_uwin = _uwin.add(_ndaysum);			
			}
		}
		return _uwin;
	}
	function _lockUserCheck(address _add) private {
		uint256 _uwin = _WinCheck(_add);
		if (_uwin>0){
			_udata[_add][2] = _udata[_add][2].add(_uwin);
		}
		if (_udata[_add][1]<_nday){
			_udata[_add][1] = _nday;
		}
		_udata[_add][3] = block.timestamp;
	}

	function _lockDayUp() private {
		uint256 _daycell = 0;
		if (_lpcount>0 && _dayout>0){
			uint256 _lpall = _lpcount.div(10**12);
			_daycell = _dayout.div(_daysec);
			_daycell = _daycell.div(_lpall);
		}
		if (_lockday[_nday][0]!=_daycell){
			_lockday[_nday][2] = block.timestamp;
			_nday = _nday+1;
			_lockday[_nday][0] = _daycell;	
			_lockday[_nday][1] = block.timestamp;		
		}
	}

	function unlock() public {
		require(_udata[msg.sender][0]>0, "Err: error lock");
		uint256 _ulockall = _udata[msg.sender][0];

		_lockUserCheck(msg.sender);
		_lpcount = _lpcount.sub(_ulockall);
		_lockDayUp();

		_udata[msg.sender][0] = 0;
		_udata[msg.sender][1] = _nday;
		_udata[msg.sender][3] = block.timestamp;
		_LP.transfer(msg.sender, _ulockall);
	}

	function withdrow() public {
		uint256 _uwin = _WinCheck(msg.sender);
		_uwin = _uwin.add(_udata[msg.sender][2]);
		require(_uwin>0, "Err: error withdrow");
		_lockUserCheck(msg.sender);
		_uwin = _udata[msg.sender][2];
		_udata[msg.sender][2] = 0;
		_udata[msg.sender][4] = _udata[msg.sender][4].add(_uwin);
		_LPwin.transfer(msg.sender, _uwin);
	}
}