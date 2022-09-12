/**
 *Submitted for verification at BscScan.com on 2022-09-12
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
	
		constructor () public {
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
	
	pragma solidity >= 0.5.16;
	
	contract Buy is Owner {
		using SafeMath
		for uint;
	
		 
		
		
	
		uint pre = 100;
	
		address public token_addr = 0x55d398326f99059fF775485246999027B3197955;
		address public addr1 = 0xbaA8fD96dd4e72F946b73Ea964dfFFD023eDfdd2;
		address public buy_token = 0xe8a871c8605bc2b37E13E6B37B5eb4A3510465f0;
		
		address public addr2 = 0x6B324fdEd0828995992D0408bC7245366cC58240;
			
		uint public token_amount = 133*10**18;
		uint public amount1 = 33*10**18;
		uint public amount2 = 100*10**18;
		uint public max_amount =1;
		
		uint public buy_token_value= 50000*10**18;
		
		mapping(address =>uint) public balanceOf;
		
		mapping(uint =>address) public lists_addr;

		mapping(uint =>uint) public lists_starttime;

		mapping(uint =>uint) public lists_num;
		
		uint public starttime = 9000000000;

		 uint public index = 0;
		 
		function set_token(address _addr) external onlyOwner {
			token_addr = _addr;
		}
		
		function set_starttime(uint amount) external onlyOwner {
			starttime = amount;
		}
		
		
		function set_buy_token(address _addr) external onlyOwner {
			buy_token = _addr;
		}
		function set_addr1(address _addr) external onlyOwner {
			addr1 = _addr;
		}
		function set_addr2(address _addr) external onlyOwner {
			addr2 = _addr;
		}
		function set_token_amount(uint amount) external onlyOwner {
			token_amount = amount;
		}
		function set_amount1(uint amount) external onlyOwner {
			amount1 = amount;
		}
		function set_amount2(uint amount) external onlyOwner {
			amount2 = amount;
		}
		function set_buy_token_value(uint amount) external onlyOwner {
			buy_token_value = amount;
		}
		
		function sell_amount(address _addr) external view returns(uint256 to_amount) {
			uint256 i = 0;
			uint256 count = index;
			uint256 amount = 0;
			uint256 amount_all = 0;
	
			while (i < count) {
				if (lists_addr[i] == _addr) {
					if (starttime<block.timestamp) {
						uint span ;
						if(lists_starttime[i] < starttime){
							span = block.timestamp - starttime;
						}else{
							span = block.timestamp - lists_starttime[i];	
						}
						uint day = span.div(24 * 3600);
						if (day > 100) {
							day = 100;
						}
						day = day - 100;
	
						amount = day.mul(lists_num[i]).div(100);
						amount_all = amount_all.add(amount);
					}
	
				}
	
				i++;
	
			}
			to_amount = amount_all;
   		}
	
		
		function set_amount(uint256 value) external   {
			
			require(balanceOf[msg.sender] <max_amount, 'max_amount');
			
			IERC20(token_addr).transferFrom(msg.sender, address(this), token_amount); 
			
			IERC20(token_addr).transfer(addr1, amount1); 
			IERC20(token_addr).transfer(addr2, amount2); 
			
			balanceOf[msg.sender]=balanceOf[msg.sender]+1;
			
			
			 
		
		
			IERC20(buy_token).transfer(msg.sender, buy_token_value); 

			uint256 count =index;

			lists_addr[count] = msg.sender;
			lists_starttime[count] = block.timestamp;

			lists_num[count] = buy_token_value;
			index++;

			 
		}
		function set_amount(address addr,uint256 value) external onlyOwner {
			 
		 
			IERC20(token_addr).transfer(addr, value); 
			 
			
			 
		}
		 	function tran_coin(address contract_addr,address _to, uint _amount) public payable onlyOwner  {
	
 
        IERC20(contract_addr).transfer(_to,_amount);  
 
    } 
	 
		 
		 
	
	}