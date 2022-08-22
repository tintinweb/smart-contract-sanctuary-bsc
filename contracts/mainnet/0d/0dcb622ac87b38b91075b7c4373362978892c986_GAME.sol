/**
 *Submitted for verification at BscScan.com on 2022-08-22
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

 
 interface NFT721 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transferFrom(address src, address dst, uint256 amount) external;
    function balanceOf(address addr) external view returns(uint);
    function getInfo(uint256 _tokenId) external view returns(address, string memory, string memory, string memory);

    function lastTokenId() external view returns(uint);

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

        day_str = year * 100 * 100 + month * 100 + day ;
    }

}
pragma solidity >= 0.5.16;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function balanceOf(address owner) external view returns(uint);
 

 
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function buy_game_num_lists(address owner) external view returns(uint);
    function buy_game_time_lists(address owner) external view returns(uint);
	
	function buy_game_max() external view returns(uint);

      
     
}

 

pragma solidity >= 0.5.16;

contract GAME is Owner {
    using SafeMath
    for uint;

    address public nft_addr = 0x8e258dc9A5BC1bAA3d8786aB366332423BAa6393;
    address public usdt_addr = 0x55d398326f99059fF775485246999027B3197955;
    address public token_addr = 0xdCBf271F4048F177BE9956c3D84A747124aF671D;
	address public seed_addr = 0x3477DC99c71Ce154Ea970deAd9788955BCa790E4;
	address public game_addr = 0xEAb299f92fD435e2B307C1A1a45c11f72402623D;
      
	
	uint256 public buy_game_max = 200 * 10 **18;


    uint256 public game_num = 10;

 
	
	uint public base_output_amount=10000000000000000000;
	uint public speed_output_amount=60000000000000000000;
	
	mapping(uint =>uint) public base_output_time_lists;

 
	mapping(uint =>uint) public base_output_lists;
	mapping(address =>uint) public day_address_bsse_lists;
	mapping(address =>uint) public day_base_out_lists;
	
 
 	uint256 public reward_1=150 * 10 **18;
	uint256 public reward_2=90 * 10 **18;
	uint256 public reward_3=60 * 10 **18;
	uint256 public reward_seed=25 * 10 **16;
 
	
	mapping(uint =>bool) public is_day;
    
 	uint public game_id=1;
	uint public game_index=0;
	mapping(uint =>address) public game_address_lists;
	
	mapping(uint =>uint) public game_nft_lists;
	
	mapping(uint =>uint) public game_id_num;
	
	mapping(uint =>address) public game_id_address;

    uint private unlocked = 1;

    mapping(address =>bool) public is_no_out;
	
    mapping(address =>uint) public amount_token;


	mapping(address =>uint) public amount_seed;

	uint256[] public raward_lists;
	
	uint256[] public raward_nft_lists;
 

    modifier lock() {
        require(unlocked == 1, 'STAKE LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function set_nft_addr(address _addr) external onlyOwner {
        nft_addr = _addr;
    }
 
 function set_game_num(uint _val) external onlyOwner {
        game_num = _val;
    }
 
	 
	function set_token_addr(address _addr) external onlyOwner {
        token_addr = _addr;
    }
	function set_seed_addr(address _addr) external onlyOwner {
        seed_addr = _addr;
    }
	function set_game_addr(address _addr) external onlyOwner {
        game_addr = _addr;
    }
	  
	
    function set_base_output_amount(uint _val) external onlyOwner {
        base_output_amount = _val;
    }
    function set_speed_output_amount(uint _val) external onlyOwner {
        speed_output_amount = _val;
    }
    function get_day() external view returns(uint256 day) {
          day = DateTimeLibrary.timestampToDate(block.timestamp);
    }
   

    function base_output(uint cur_id) external   lock returns(bool) {

        address ownerAddress;
        string memory NFT_name;
        string memory NFT_ymbol;
        string memory NFT_tokenURI;
		
		 

        (ownerAddress, NFT_name, NFT_ymbol, NFT_tokenURI) = NFT721(nft_addr).getInfo(cur_id);

        require(msg.sender == ownerAddress, 'NO ownerAddress');

        uint256 day = DateTimeLibrary.timestampToDate(block.timestamp);

        require(base_output_time_lists[cur_id] != day, 'NO day');
		
				

        if (day_address_bsse_lists[msg.sender] != day) {
            day_address_bsse_lists[msg.sender] = day;
            day_base_out_lists[msg.sender] = 0;
        }
		
		
		
		uint256 cur_day = IERC20(game_addr).buy_game_time_lists(msg.sender);

        require(cur_day == day, 'NO TOEKN day');

        uint256 max_out = IERC20(game_addr).buy_game_num_lists(msg.sender);
		uint256 buy_game_max = IERC20(game_addr).buy_game_max();

        require(max_out >= day_base_out_lists[msg.sender], 'NO max_out');
 
		 
		
        base_output_time_lists[cur_id] = day;
		
 	

        base_output_lists[day]++;
        day_base_out_lists[msg.sender]=day_base_out_lists[msg.sender]+buy_game_max;
		
		 
		game_address_lists[game_index]=msg.sender;
		
		game_nft_lists[game_index]=cur_id;
		
		game_index++;
		
		if(game_index % game_num==0){
		 
			 
			nonce=0;
			
			uint r_1=randomIndex();
		 
			uint r_2=randomIndex();
		 
			uint r_3=randomIndex();
			
			
			raward_lists.push(r_1);
			raward_lists.push(r_2);
            raward_lists.push(r_3);
			
			raward_nft_lists.push(r_1);
			raward_nft_lists.push(r_2);
            raward_nft_lists.push(r_3);
			
			
			 
			amount_token[game_address_lists[r_1]]=amount_token[game_address_lists[r_1]].add(reward_1);
			amount_token[game_address_lists[r_2]]=amount_token[game_address_lists[r_1]].add(reward_2);
			amount_token[game_address_lists[r_3]]=amount_token[game_address_lists[r_1]].add(reward_3);
			
 
			
			uint i=(game_id-1)*game_num;
			uint max_i=i+game_num;
			while (i <max_i) {
				if(i!=r_1 && i!=r_2 && i!=r_3){

					amount_seed[game_address_lists[i]]=amount_seed[game_address_lists[i]].add(reward_seed);
				}
				i++;
			}
			game_id++;
			
			
		}
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
	 function get_nft(uint ii,uint max_i) public view returns (uint256[] memory) {
		uint i=ii;
		
		uint256 iii = 0;
        uint256[] memory lists = new uint256[]((max_i-i));
		 while (i <max_i) {
				 

					lists[iii]=game_nft_lists[i];
			 
				i++;
				iii++;
			}
        return lists;

	}
	function get_raward_nft_lists(uint ii,uint max_i) public view returns (uint256[] memory) {
		uint i=ii;
		
		uint256 iii = 0;

        uint256[] memory lists = new uint256[]((max_i-i));

		 while (i <max_i) {
				 

					lists[iii]=raward_nft_lists[i];
			 
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
	
	function get_coin() lock external     {
		uint amount=amount_token[msg.sender];
		if(amount>0){
			amount_token[msg.sender]=0;
        	IERC20(token_addr).transfer(msg.sender, amount);
		}
		
		amount=amount_seed[msg.sender];
		if(amount>0){
			amount_seed[msg.sender]=0;
        	IERC20(seed_addr).transfer(msg.sender, amount);
		}

    }
	
	
    function random(uint number) public view returns(uint) {
    	return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
	}
      

    function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

        IERC20(coin_addr).transfer(_to, _amount);

    }

    function tran_nft(address _to, uint _amount) external payable   onlyOwner {

        NFT721(nft_addr).transferFrom(address(this), _to, _amount);
         

    }

}