/**
 *Submitted for verification at BscScan.com on 2022-08-02
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

interface NFT721 {
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);
 
	function transferFrom(address src, address dst, uint256 amount) external;
	function balanceOf(address addr) external view returns(uint);

    function add_new(address _addr,uint256 _grade_id,string calldata _tokenURI) external;
 
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

	 
 
 
  
	 
	
 	  
	mapping(address => bool) public is_admin;
	 
	address public nft_addr =0x8e258dc9A5BC1bAA3d8786aB366332423BAa6393;
 
	address public token_addr=0xdCBf271F4048F177BE9956c3D84A747124aF671D;
 
	address public nft_addr_2 =0xF102FC23f3495EcF1C984d4DDbB972530903Ea51;
	
	address public nft_addr_land =0xF2F2DEfD3d8700917512fbD3c2459dd1E4C89aEb;
	
	 address public hold_addr = 0x000000000000000000000000000000000000dEaD;
	 
	uint public price= 1000*10**18;
	
	uint public cur_id=0;
	
	uint private unlocked = 1;

	modifier lock() {
		require(unlocked == 1, 'STAKE LOCKED');
		unlocked = 0;
		_;
		unlocked = 1;
	}

	function set_nft_addr(address _addr) external onlyOwner {
		nft_addr = _addr;
	}
	
	function set_nft_addr_2(address _addr) external onlyOwner {
		nft_addr_2 = _addr;
	}
	
	function set_nft_addr_land(address _addr) external onlyOwner {
		nft_addr_land = _addr;
	}
	
 
	
 
	
	function set_price(uint _price) external onlyOwner {
		price = _price;
	}
	
	 

	 
	 
	function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

	 
		IERC20(coin_addr).transfer(_to, _amount);

	}
	
	function tran_nft(address _to, uint _amount) external payable lock onlyOwner {
		uint i=0;
	 	while (i < _amount) {
			NFT721(nft_addr).transferFrom(address(this), _to,cur_id);
			i++;
			cur_id++;
		}
	}
	
 

 
 
	
	
	function buy_nft(uint256 value_1,uint256 value_2,uint256 value_3) public   lock returns(bool) {
		
		NFT721(nft_addr).transferFrom(msg.sender, hold_addr,value_1);
		NFT721(nft_addr).transferFrom(msg.sender, hold_addr,value_2);
		NFT721(nft_addr).transferFrom(msg.sender, hold_addr,value_3);
		 
		  
		IERC20(token_addr).transferFrom(msg.sender,hold_addr,price);	
		 
		uint r=random(100);
		string memory url="https://gateway.pinata.cloud/ipfs/QmWw7C687cBpu3AeJiVyTs55Paqb8GpJafXPLTxyboYgmW";
		
		uint grade_id=1;
		if(r<5){ grade_id=4;url="https://gateway.pinata.cloud/ipfs/QmXQ1ca8eHaN3Awtz1QV5jNZJZ7nDBJ365Eam1oemTrsCh";}
		if(r<15 && r>=5){ grade_id=3;url="https://gateway.pinata.cloud/ipfs/QmVepoQPAT9e4UyAFHb4eFA4UQVB5YukmimGavdWewe47U";}
		if(r<30 && r>=15){ grade_id=2;url="https://gateway.pinata.cloud/ipfs/QmW2FPvLtLGVaGmAcNmANzyhGaFhfCmrZNLFkLqUSYivU4";}
		
		NFT721(nft_addr_2).add_new(msg.sender, grade_id,url);
		
		r=random(100);
		if(r<25){
			url="https://gateway.pinata.cloud/ipfs/QmNedjn4ARVzmKbZk3kJbkRzWZko3pCvPim5rGRS73PPhR";
			NFT721(nft_addr_land).add_new(msg.sender, 1,url);
				 
		}
 		
		
		 
 

		 
		return true;
	}
	
	 function random(uint number) public view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
}
	 

}