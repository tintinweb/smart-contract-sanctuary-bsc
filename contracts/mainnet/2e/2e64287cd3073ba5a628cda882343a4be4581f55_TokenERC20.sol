/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/* SPDX-License-Identifier: SimPL-2.0*/
pragma solidity >=0.6.2;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external; }

contract Owner {
    address private owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
   
}	
library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
library DateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysToDate(uint _days) internal pure returns(uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns(uint day_str) { 
        uint year;
        uint month;
        uint day;
		(year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
		
		day_str=year*100*100+month*100+day;
    }

}
 
 
contract TokenERC20 is Owner {
	 
    using SafeMath
    for uint;
    string public name;
    string public symbol;
    uint8 public decimals = 18;  
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
	
	
	uint256 public max_pre =2; 
	
	mapping(address => address) public inviter;
	
	
	mapping(address => bool) public is_black;
	mapping(address => bool) public is_fee;
	
	mapping(address => uint256) public day_lists;
	
	mapping(address => uint256) public num_lists;
	
 	 
	  
	 
    
     constructor() public {
        totalSupply = 25000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = "Seed";
        symbol = "Seed";
		 
    }
	  function isContract(address account) internal view returns (bool) {

    bytes32 codehash;
    bytes32 accountHash =
      0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
		require(_value>0,">0");
		
		
		require(!is_black[_from]);
		require(!is_black[_to]);
		
		 uint256 day = DateTimeLibrary.timestampToDate(block.timestamp);
		
 		if (day_lists[_from] != day) {
            day_lists[msg.sender] = day;
            num_lists[msg.sender] = 0;
        }
		
		uint256 max_num=num_lists[msg.sender].add(_value);
		uint256 left_num=balanceOf[_from].sub(_value);
		require(max_num<(left_num.mul(max_pre).div(100)) || is_fee[_from],">max_num");
 
		num_lists[msg.sender]=num_lists[msg.sender].add(_value);
		
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
		
 
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
		
		
		 
		
		
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
 
	
	 function set_max_pre(uint256 _value) public  onlyOwner returns (bool success) {
		max_pre=_value;
		return true;
	}
	
	function set_is_black(address _addr,bool _bool) external onlyOwner{
		is_black[_addr] = _bool;
    }
	function set_is_fee(address _addr,bool _bool) external onlyOwner{
		is_fee[_addr] = _bool;
    }
 
	 

}