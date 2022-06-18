/**
 *Submitted for verification at BscScan.com on 2022-06-18
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
}

interface parent_lists {
	 

	function inviter(address addr) external returns(address);
	 
}


pragma solidity >= 0.5.16;

contract STAKE is Owner {
	using SafeMath
	for uint;

	 
 
    mapping(address =>uint) public grade_lists;

  
	 
	
	
	uint price = 150*10**18;
	
	uint public all_buy_num=0;

	uint public all_max_num=2000;
	 
	
 	  
	mapping(address => bool) public is_admin;
	 
	address public nft_addr =0x8e258dc9A5BC1bAA3d8786aB366332423BAa6393;
	address public usdt_addr =0x55d398326f99059fF775485246999027B3197955;
	address public parent_addr =0x51f1Dfe5eacC6BC07Bc8f83795eC917834B538eB;
	
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
	function set_price(uint _price) external onlyOwner {
		price = _price;
	}
	
	function set_parent_addr(address addr) external onlyOwner {
		parent_addr = addr;
	}
	function set_cur_id(uint value) external onlyOwner {
		cur_id = value;
	}
	function set_all_max_num(uint value) external onlyOwner {
		all_max_num = value;
	}
	function set_is_admin(address addr,bool value) external onlyOwner {
		is_admin[addr] = value;
	}

	 
	 
	function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

	 
		IERC20(coin_addr).transfer(_to, _amount);

	}
	
	function tran_nft(address _to, uint _amount) external payable lock onlyOwner {

	 
		NFT721(nft_addr).transferFrom(address(this), _to,cur_id);
		cur_id++;

	}
	
 

 
	function set_grade(address addr,uint256 value) public lock returns(bool) {
		 
		require(is_admin[msg.sender]==true, 'NO ADMIN');
		
		grade_lists[addr]=value;
	
	}
	function buy_nft(uint256 value) public   lock returns(bool) {
		
		uint256 all_price=value.mul(price);
		require(all_price>0, 'NO PRICE');
		
		all_buy_num=all_buy_num.add(value);
		
        require(all_buy_num<=all_max_num, 'MAX');
		 
		
		
		IERC20(usdt_addr).transferFrom(msg.sender,address(this),all_price);	
	 
		get_fee(msg.sender,all_price);
		
	
		 
		uint256 i=0;
		while (i < value) {
			NFT721(nft_addr).transferFrom(address(this), msg.sender,cur_id);
			i++;
			cur_id++;
		}
		
		 
		 
		return true;
	}
	
	 
	
	 
	function get_fee(address addr,uint256 val) public   returns(bool) {

		uint256 amount;
		address cur_addr;
		uint256 pre;
		uint256 max_grade_id=0;
		uint256 i=0;
		cur_addr=parent_lists(parent_addr).inviter(addr);
		if(cur_addr==address(0x0)){
				return true;
		}
		if(NFT721(nft_addr).balanceOf(cur_addr)>0){
		
			pre=12;
			amount=val.mul(pre).div(100); 
			IERC20(usdt_addr).transfer(cur_addr, amount);
			
			if(grade_lists[cur_addr]>0){
				if(grade_lists[cur_addr]==1){pre=1;}
				if(grade_lists[cur_addr]==2){pre=2;}
				if(grade_lists[cur_addr]==3){pre=3;}
				amount=val.mul(pre).div(100); 
				IERC20(usdt_addr).transfer(cur_addr, amount);
				max_grade_id=grade_lists[cur_addr];
			}
		}
		
		
		cur_addr=parent_lists(parent_addr).inviter(cur_addr);
		if(cur_addr==address(0x0)){
				return true;
		}
		if(NFT721(nft_addr).balanceOf(cur_addr)>0){
			
			pre=5;
			amount=val.mul(pre).div(100); 
			IERC20(usdt_addr).transfer(cur_addr, amount);
			
			if(grade_lists[cur_addr]>0 && grade_lists[cur_addr]>max_grade_id){
				if(grade_lists[cur_addr]==1){pre=1;}
				if(grade_lists[cur_addr]==2){pre=2;}
				if(grade_lists[cur_addr]==3){pre=3;}
				pre=max_grade_id.sub(pre);
				amount=val.mul(pre).div(100); 
				IERC20(usdt_addr).transfer(cur_addr, amount);
				max_grade_id=grade_lists[cur_addr];
			}
		}
		if(max_grade_id>=3){
			return true;
		}
		
		 
		while (i < 30) {
			cur_addr=parent_lists(parent_addr).inviter(cur_addr);
			if(cur_addr==address(0x0)){
				break;
			}
			if(NFT721(nft_addr).balanceOf(cur_addr)>0){
				
					
				 
				pre=0;
				if(grade_lists[cur_addr]==1){pre=1;}
				if(grade_lists[cur_addr]==2){pre=2;}
				if(grade_lists[cur_addr]==3){pre=3;}
				
				if(grade_lists[cur_addr]>0 && grade_lists[cur_addr]>max_grade_id){
					if(grade_lists[cur_addr]==1){pre=1;}
					if(grade_lists[cur_addr]==2){pre=2;}
					if(grade_lists[cur_addr]==3){pre=3;}
					pre=max_grade_id.sub(pre);
					amount=val.mul(pre).div(100); 
					IERC20(usdt_addr).transfer(cur_addr, amount);
					max_grade_id=grade_lists[cur_addr];
					if(max_grade_id>=3){
						break;
					}
				}
			}
			
		}
		return true;
		 

	}
	 

}