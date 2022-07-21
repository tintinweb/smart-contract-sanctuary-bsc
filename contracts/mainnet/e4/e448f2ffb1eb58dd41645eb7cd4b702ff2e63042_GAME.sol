/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
        owner =0xcC58c9799AfE3F9A80109273D4f7211A29142AbF;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

}

pragma solidity >= 0.5.16;

 
interface parent_lists {
	function inviter(address addr) external returns(address);
}


interface grade {
	function grade_lists(address addr) external returns(uint);
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

     
     
}

interface NFT721 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transferFrom(address src, address dst, uint256 amount) external;
    function balanceOf(address addr) external view returns(uint);
    function getInfo(uint256 _tokenId) external view returns(address, string memory, string memory, string memory);

    function lastTokenId() external view returns(uint);

}

pragma solidity >= 0.5.16;

contract GAME is Owner {
    using SafeMath
    for uint;

    address public nft_addr = 0x8e258dc9A5BC1bAA3d8786aB366332423BAa6393;
    address public usdt_addr = 0x55d398326f99059fF775485246999027B3197955;
    address public token_addr = 0xdCBf271F4048F177BE9956c3D84A747124aF671D;
	address public grade_addr = 0x8b02c276240764C6f01C000bE78EDD6DD7f43c2B;
    address public parent_addr =0x51f1Dfe5eacC6BC07Bc8f83795eC917834B538eB;
	
	
	address public reward_addr=0x47d41E9104314C678a37E83812a383F31C90DD0d;
	
	address public own_addr=0xF13d0c5E16C87f714699288887F8f2F319867e33;
	
	
	uint256 public buy_game_max = 200 * 10 **18;

 
	
	uint public base_output_amount=10000000000000000000;
	uint public speed_output_amount=60000000000000000000;
	
	mapping(uint =>uint) public base_output_time_lists;

 
	mapping(uint =>uint) public base_output_lists;
	mapping(address =>uint) public day_address_bsse_lists;
	mapping(address =>uint) public day_base_out_lists;
	
 
	mapping(address =>uint) public day_address_speed_lists;
	mapping(address =>uint) public day_speed_out_lists;
	
	mapping(uint =>uint) public speed_output_time_lists;
	
	
	mapping(uint =>uint) public speed_output_lists;
	
	mapping(uint =>bool) public is_day;
    
    mapping(address =>uint) public reward;

    mapping(address =>uint) public share_amount_lists;

    mapping(address =>uint) public team_amount_lists;

 
     
 

    uint private unlocked = 1;

    mapping(address =>bool) public is_no_out;

    modifier lock() {
        require(unlocked == 1, 'STAKE LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function set_reward_addr(address _addr) external onlyOwner {
        reward_addr = _addr;
    }
	
	function set_own_addr(address _addr) external onlyOwner {
        own_addr = _addr;
    }
	
	
	function set_nft_addr(address _addr) external onlyOwner {
        nft_addr = _addr;
    }
	function set_is_no_out(address _addr,bool _val) external onlyOwner {
        is_no_out[_addr] = _val;
    }
	
	
	function set_token_addr(address _addr) external onlyOwner {
        token_addr = _addr;
    }
	function set_parent_addr(address _addr) external onlyOwner {
        parent_addr = _addr;
    }
	function set_grade_addr(address _addr) external onlyOwner {
        grade_addr = _addr;
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
   

    function base_output(uint cur_id) external payable lock returns(bool) {

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
		if (day_address_speed_lists[msg.sender] != day) {
            day_address_speed_lists[msg.sender] = day;
            day_speed_out_lists[msg.sender] = 0;
        }
		
        base_output_time_lists[cur_id] = day;

        IERC20(token_addr).transfer(msg.sender, base_output_amount);
		
		IERC20(token_addr).transfer(reward_addr, base_output_amount.mul(18).div(100));


        base_output_lists[day]++;
        day_base_out_lists[msg.sender]=day_base_out_lists[msg.sender]+base_output_amount;
        return true;

    }

    function speed_output(uint cur_id) external payable lock returns(bool) {
        uint256 day = DateTimeLibrary.timestampToDate(block.timestamp);
        require(speed_output_time_lists[cur_id] != day, 'NO day');
		
		require(base_output_time_lists[cur_id] == day, 'NO BASE');
 
        address ownerAddress;
        string memory NFT_name;
        string memory NFT_ymbol;
        string memory NFT__tokenURI;

        (ownerAddress, NFT_name, NFT_ymbol, NFT__tokenURI) = NFT721(nft_addr).getInfo(cur_id);

        require(msg.sender == ownerAddress, 'NO ownerAddress');

        uint256 cur_day = IERC20(token_addr).buy_game_time_lists(msg.sender);

        require(cur_day == day, 'NO TOEKN day');

        uint256 max_out = IERC20(token_addr).buy_game_num_lists(msg.sender);

        require(max_out > day_speed_out_lists[msg.sender], 'NO max_out');
 
         


        require(is_no_out[msg.sender] == false, 'NO OUT');

        
 
        day_speed_out_lists[msg.sender]=day_speed_out_lists[msg.sender].add(buy_game_max);
        speed_output_lists[day]++;

        speed_output_time_lists[cur_id] = day;

        IERC20(token_addr).transfer(msg.sender, speed_output_amount);

        return true;

    }

    function day_cal(uint256 _day) external onlyOwner returns(bool) {
        uint256 day = DateTimeLibrary.timestampToDate(block.timestamp);

        require(_day != day, 'NO day');
        require(is_day[_day] == false, 'NO _day');

        uint256 all_coin = NFT721(nft_addr).lastTokenId();

        if (base_output_lists[_day] < all_coin) {
            uint256 span = all_coin-base_output_lists[_day] ;

            span = span * base_output_amount;

            IERC20(token_addr).transfer(0x47d41E9104314C678a37E83812a383F31C90DD0d, span);

        }
        if (speed_output_lists[_day] < all_coin) {
            uint256 span = all_coin-speed_output_lists[_day];

            span = span * speed_output_amount;

            IERC20(token_addr).transfer(0x000000000000000000000000000000000000dEaD, span);

        }
        return true;

    }
      

    function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

        IERC20(coin_addr).transfer(_to, _amount);

    }

    function tran_nft(address _to, uint _amount) external payable   onlyOwner {

        NFT721(nft_addr).transferFrom(address(this), _to, _amount);
         

    }

}