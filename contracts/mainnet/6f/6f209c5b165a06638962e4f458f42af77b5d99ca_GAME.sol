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

    constructor() {
        owner =0x4D5f030bA8C513698bC74eda46D3A9BF59E1e5Dd;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

}

pragma solidity >= 0.5.16;

 
 
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

        day_str = year * 100 * 100 + month * 100 + day ;
    }

}
pragma solidity >= 0.5.16;

 

 

pragma solidity >= 0.5.16;

contract GAME is Owner {
    using SafeMath
    for uint;

      
 
    
 	uint public game_id=1;
	uint public game_index=0;
	mapping(uint =>address) public game_address_lists;
 

    uint private unlocked = 1;

 

	uint256[] public raward_lists;

    mapping(uint =>uint) public raward_listsraward_lists;
 

    modifier lock() {
        require(unlocked == 1, 'STAKE LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    
 
   

    function base_output(uint cur_id) external   lock returns(bool) {
 
  
		 
		    game_address_lists[game_index]=msg.sender;
		
		    game_index++;
		
		 
		 
			 
			nonce=0;
			
			uint r_1=randomIndex();
		 
			uint r_2=randomIndex();
		 
			uint r_3=randomIndex();
			
			
			raward_lists[raward_lists.length]=r_1;
			raward_lists[raward_lists.length]=r_2;
			raward_lists[raward_lists.length]=r_3;
			
	 
 
  
			game_id++;
			
			
		 
        return true;

    }
       function base_output_1(uint cur_id) external   lock returns(bool) {
 
  
		    game_address_lists[game_index]=msg.sender;
		
		    game_index++;
		
		 nonce=0;
			
			  			uint r_1=randomIndex();
		 
			uint r_2=randomIndex();
		 
			uint r_3=randomIndex();
			
			
			raward_listsraward_lists[1]=r_1;
			raward_listsraward_lists[2]=r_2;
			raward_listsraward_lists[3]=r_3;
            raward_listsraward_lists[4]=raward_lists.length;
        return true;
    }
    function base_output_2(uint cur_id) external   lock returns(bool) {
 
  
		 
		    game_address_lists[game_index]=msg.sender;
		
		    game_index++;
		
		 nonce=0;
			
			uint r_1=randomIndex();
		 
			uint r_2=randomIndex();
		 
			uint r_3=randomIndex();
			
			
			raward_lists.push(r_1);
			raward_lists.push(r_2);
            raward_lists.push(r_3);
        return true;

    }
    function get_address(uint ii,uint max_i) public view returns (address[] memory) {
		uint i=ii;
		
		uint256 iii = 0;
        address[] memory lists = new address[]((max_i-i));
		 while (i <max_i) {
				 

					lists[iii]=game_address_lists[i];
			 
				i++;
				iii++;
			}
        return lists;

	}
	function get_raward_lists(uint ii,uint max_i) public view returns (uint256[] memory) {
		uint i=ii;
		
		uint256 iii = 0;

        uint256[] memory lists = new uint256[]((max_i-i));

		 while (i <max_i) {
				 

					lists[iii]=raward_lists[i];
			 
				i++;
				iii++;
			}
         return lists;

		
	}
	
	 
 	 
	uint constant public TOKEN_LIMIT = 10;
 
    uint[TOKEN_LIMIT] public indices;
    uint public nonce;
    function randomIndex() public returns (uint) {
        uint totalSize = TOKEN_LIMIT - nonce;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }

        // Move last value to selected position
        if (indices[totalSize - 1] == 0) {
            // Array position not initialized, so use position
            indices[index] = totalSize - 1;
        } else {
            // Array position holds a value so use that
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }
	
 
	
 

 

    

}