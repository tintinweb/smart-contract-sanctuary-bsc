/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

/* SPDX-License-Identifier: SimPL-2.0*/
pragma solidity >= 0.5.16;

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
contract Owner {
	address private owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor ()   {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "only Owner");
		_;
	}

}

pragma solidity >= 0.5.16;

library Math {
	function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
		z = x < y ? x: y;
	}

	// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
	function sqrt(uint256 y) internal pure returns(uint256 z) {
		if (y > 3) {
			z = y;
			uint256 x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}
}

pragma solidity >= 0.5.16;

interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external view returns(string memory);
	function symbol() external view returns(string memory);
	function decimals() external view returns(uint8);
	function totalSupply() external view returns(uint);
	function balanceOf(address owner) external view returns(uint);
	function allowance(address owner, address spender) external view returns(uint);

	function approve(address spender, uint256 value) external returns(bool);
	function transfer(address to, uint256 value) external returns(bool);
	function transferFrom(address from, address to, uint256 value) external returns(bool);
	 
}

interface PANCAKEPair {
			function factory() external view returns (address);
			function token0() external view returns (address);
			function token1() external view returns (address);
			function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
			function sync() external;
			
 
		}

interface parent_lists {
	 

	function inviter(address addr) external returns(address);
	 
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

pragma solidity >= 0.5.16;

contract STAKE is Owner {
	using SafeMath
	for uint;

	 
 
    mapping(address =>uint) public grade_lists;
	
	mapping(address =>uint) public buy_game_time_lists;
	mapping(address =>uint) public buy_game_num_lists;

  
	uint buy_game_max=0;
	
	
 
 
	 
	
 	  
	mapping(address => bool) public is_admin;
	 
	address public token_addr =0xdCBf271F4048F177BE9956c3D84A747124aF671D;
	address public usdt_addr =0x55d398326f99059fF775485246999027B3197955;
	
	
	address public lp_addr =0xD4BAbF1dE88a0DE11Cb6056D42f97ec8bCb6fE1E;
	 
	 
	uint public cur_id=0;
	
	uint private unlocked = 1;

	modifier lock() {
		require(unlocked == 1, 'STAKE LOCKED');
		unlocked = 0;
		_;
		unlocked = 1;
	}

	function set_token_addr(address _addr) external onlyOwner {
		token_addr = _addr;
	}
	
	function set_usdt_addr(address _addr) external onlyOwner {
		usdt_addr = _addr;
	}
	
	
 
	
	function set_buy_game_max(uint value) external onlyOwner {
		 
		buy_game_max=value;
	
	}
	
  
	function set_is_admin(address addr,bool value) external onlyOwner {
		is_admin[addr] = value;
	}

	 
	 
	function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

	 
		IERC20(coin_addr).transfer(_to, _amount);

	}
	
 
	
 
	
	
	function buy_nft(uint256 value) public  lock returns(bool) {
		
		 
			address _to=msg.sender;
			 
	 
			uint256 day_str=DateTimeLibrary.timestampToDate(block.timestamp);	
			
			if(buy_game_time_lists[_to]!=day_str){
				buy_game_time_lists[_to]=day_str;
				buy_game_num_lists[_to]=0;
			}
			if(value>=buy_game_max){
				buy_game_num_lists[_to]=buy_game_num_lists[_to]+buy_game_max;
			}
            uint amountA;
            uint amountB;
		 
            (amountA, amountB,) = PANCAKEPair(lp_addr).getReserves();

			uint256 usdt_amount=value.mul(amountA.div(amountB));
												 
			IERC20(usdt_addr).transferFrom(msg.sender,address(this),usdt_amount);	
	 		
   
		
		
			IERC20(token_addr).transfer(msg.sender,value);	
 
		 
		return true;
	}
	
	function buy_nft_1(uint256 value) public  view returns(uint256 usdt_amount) {
		
		 
			address _to=msg.sender;
			 
	 
			uint256 day_str=DateTimeLibrary.timestampToDate(block.timestamp);	
			
		 
            uint amountA;
            uint amountB;
		 
            (amountA, amountB,) = PANCAKEPair(lp_addr).getReserves();

			  usdt_amount=value.mul(amountA.div(amountB));
	}
	
	function buy_nft_2(uint256 value) public  view returns(uint256 amountA,uint256 amountB) {
		
		 
			address _to=msg.sender;
			 
	 
			uint256 day_str=DateTimeLibrary.timestampToDate(block.timestamp);	
			
	 
		 
            (amountA, amountB,) = PANCAKEPair(lp_addr).getReserves();
 
	}
	
	 
	 

}