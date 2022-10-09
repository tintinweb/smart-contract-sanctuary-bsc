/**
 *Submitted for verification at BscScan.com on 2022-10-08
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

    constructor()  {
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
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint);
    function balanceOf(address owner) external view returns(uint);
    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint value) external returns(bool);
    function transfer(address to, uint value) external returns(bool);
    function transferFrom(address from, address to, uint value) external returns(bool);
} 
 
contract Sale is Owner {
	 
    using SafeMath
    for uint;
    
	uint public index=0;
	
	 
	
	mapping(address => uint256) public address_index;
	mapping(uint256 => address) public index_address;
	mapping(uint256 => address) public coin_addr_lists;
	mapping(uint256 => uint256) public amount_lists;
	mapping(uint256 => address) public sell_address_lists;
	mapping(uint256 => uint256) public buy_start_time_lists;
	mapping(uint256 => uint256) public buy_end_time_lists;
	mapping(uint256 => uint256) public buy_min_amount_lists;
	mapping(uint256 => uint256) public buy_max_amount_lists;
	mapping(uint256 => uint256) public price_type_lists;
	mapping(uint256 => uint256) public release_type_lists;
	mapping(uint256 => uint256) public price_length_lists;
	mapping(uint256 => uint256) public release_length_lists;
	
	
	 
	
	mapping(uint256 => mapping(uint256 => uint256)) public price_time_lists;
	mapping(uint256 => mapping(uint256 => uint256)) public price_amount_lists;
	mapping(uint256 => mapping(uint256 => uint256)) public release_time_lists;
	mapping(uint256 => mapping(uint256 => uint256)) public release_amount_lists;
	
	mapping(uint256 => mapping(uint256 => uint256)) public tmp_lists;
	
	
	uint public unlocked=1; 
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
	uint public unlocked_2=1;
	modifier lock_2() {
        require(unlocked_2 == 1, 'LOCKED');
        unlocked_2 = 0;
        _;
        unlocked_2 = 1;
    }
	
	// buy_start_time,uint buy_end_time,uint buy_min_amount,uint buy_max_amount,uint price_type,uint release_type
	function add_presale(address coin_address,uint amount,address sell_address,uint[] calldata arr,uint[] calldata price_lists,uint[] calldata release_lists)   public lock returns (bool success) {
		
		IERC20(coin_address).transferFrom(msg.sender,address(this), amount);
		
		address_index[msg.sender]=index;
		index_address[index]=msg.sender;
		
		coin_addr_lists[index]=coin_address;
		amount_lists[index]=amount;
		sell_address_lists[index]=sell_address;
		buy_start_time_lists[index]=arr[0];
		buy_end_time_lists[index]=arr[1];
		buy_min_amount_lists[index]=arr[2];
		buy_max_amount_lists[index]=arr[3];
		price_type_lists[index]=arr[4];
		release_type_lists[index]=arr[5];
		
		uint price_length=(price_lists.length)/2;
        for (uint i=0; i < (price_length-1) ; i++) {
            price_time_lists[index][i]=price_lists[i*2];
			price_amount_lists[index][i]=price_lists[i*2+1];
        }
		price_length_lists[index]=price_length;
		
		uint release_length=(release_lists.length)/2;
        for (uint i=0; i < (release_length-1) ; i++) {
            release_time_lists[index][i]=release_lists[i*2];
			release_amount_lists[index][i]=release_lists[i*2+1];
        }
		
		release_length_lists[index]=release_length;
        return true;
    }
    function add_presale_2(uint[] calldata price_lists)   public lock returns (bool sucess) {
		 
		
		uint price_length=(price_lists.length)/2;
        for (uint i=0; i < (price_length-1) ; i++) {
            price_time_lists[index][i]=price_lists[i*2];
			price_amount_lists[index][i]=price_lists[i*2+1];
        }
		 
		 
        return true;
    }
    function add_presale_3(uint[] calldata price_lists)   public lock returns (bool sucess) {
		 
		
		uint price_length=(price_lists.length)/2;
        for (uint i=0; i < (price_length-1) ; i++) {
            price_time_lists[index][i]=price_lists[i*2];
			price_amount_lists[index][i]=price_lists[i*2-1];
        }
		for (uint ii=0; ii < (price_lists.length-1) ; ii++) {
            tmp_lists[index][ii]=price_lists[ii];
			 
        }
		 
        return true;
    }
     function add_presale_4(uint[] calldata price_lists)   public lock returns (bool sucess) {
		 
		
		uint price_length=(price_lists.length)/2;
        for (uint i=0; i < (price_length-1) ; i++) {
            price_time_lists[index][i]=price_lists[i*2];
			price_amount_lists[index][i]=price_lists[i*2-1];
        }
		for (uint ii=0; ii < (price_length-1) ; ii++) {
            tmp_lists[index][ii]=price_lists[ii];
			 
        }
		 
        return true;
    }
     function add_presale_5(uint[] calldata price_lists)   public lock returns (bool sucess) {
		 
		
		uint price_length=(price_lists.length)/2;
        
		for (uint ii=0; ii < (price_length-1) ; ii++) {
            tmp_lists[index][ii]=price_lists[ii];
			 
        }
		 
        return true;
    }
	function test(address coin_address,uint[] calldata arr,address address_2)   public returns (bool sucess) {
	 
    }
	function get_detail(uint id)   public view returns (address,uint,address) {
	 	address addr=index_address[id];
		uint amount=amount_lists[id];
		address sell_address=sell_address_lists[id];
		
		
		 
		return (addr,amount,sell_address);
		
    }
    function get_price_time_lists(uint id)   public view returns (uint[] memory,uint[] memory) {
	 	 
		uint price_length=price_length_lists[id];
		uint[] memory price_time_lists_tmp = new uint[](price_length);
        uint[] memory price_amount_lists_tmp = new uint[](price_length);
        for (uint i=0; i < (price_length-1) ; i++) {
            price_time_lists_tmp[i]=price_time_lists[id][i];
			price_amount_lists_tmp[i]=price_amount_lists[id][i];
        }
		 
	 
		return (price_time_lists_tmp,price_amount_lists_tmp);
		
    }

}