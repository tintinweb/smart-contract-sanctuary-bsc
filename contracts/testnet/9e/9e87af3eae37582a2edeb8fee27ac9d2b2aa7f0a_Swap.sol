/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/* SPDX-License-Identifier: SimPL-2.0*/
pragma solidity >= 0.5.16;

library SafeMath {
    function add(uint x, uint y) internal pure returns(uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns(uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns(uint z) {
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

library Math {
    function min(uint x, uint y) internal pure returns(uint z) {
        z = x < y ? x: y;
    }

    function sqrt(uint y) internal pure returns(uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract Owner {
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function balanceOf(address owner) external view returns(uint);
    function allowance(address owner, address spender) external view returns(uint);

    function transfer(address to, uint value) external returns(bool);
    function transferFrom(address from, address to, uint value) external returns(bool);
}
interface DAO {

 	function burn(address account, uint256 amount) external returns(uint256);
    function mint(address account, uint256 amount) external returns(bool);
}

contract Swap is Owner {
    using SafeMath
    for uint;

    string public constant name = 'SXS-LP';
    string public constant symbol = 'SXS-LP';
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address =>uint) public balanceOf;
	mapping(address =>uint) public balanceOf_share;
    mapping(address =>uint) public user_amount_1;
    mapping(address =>uint) public user_amount_2;

    mapping(address =>bool) public is_in_holder_lists;

    address[] public holder_lists;
	
	address[] public holder_lists_tmp;
	
 
	
    mapping(address =>uint256) public holder_lists_index;
	uint public max_index;
	
	uint public is_reward_span_start=0;
	uint public reward_tmp_1=0;
	uint public reward_tmp_2=0;
	
	uint public has_amount_1=0;
	uint public has_amount_2=0;
	



    uint public trade_max_amount = 0;
    uint public trade_cur_amount = 0;

    uint public user_max_amount = 0;
    mapping(address =>uint) public user_cur_amount;

    mapping(address =>mapping(address =>uint)) public allowance;

    uint private constant MINIMUM_LIQUIDITY = 10 **3;

    address public token1=0xD084f943EA225dda0577208B36A9c3472b457284;
    address public token2=0xF8636680577FB3A77A1fa29a4677F47C5DA0dD2b;
	
	
	uint public start_time=1662073200;
	uint public end_time=start_time+3600;
	
	uint public max_cur_amount=50* 10 **18;
	
	 

    uint public amount1;
    uint public amount2;

    address private hole_address = 0x000000000000000000000000000000000000dEaD;


    address private plan_addr = 0xFB254BF2b175F29eBa2EC357b435E6CEA256F9B6;
	
	address private plan_dao_addr = 0xDE55B32af6aecAEA54E8C8E159Be6b29B03737d9;
	
   
   	address public stake_addr=0x3b3d14770eBFA48893c5C3a749D9d470063ef51d;
	address public dao_addr=0x6d058359C40aB35f75C66868e22eB0E7cA3679Ff; 
	
	address public lock_addr=0x2Af68683a0Bc32852B19D4AA06fC0Ab212b59d78; 

    uint public hole_amount_max = 990000000 * 10 **18;
    uint public max_hole_pre = 4500;
    uint private plan_pre = 400;
    uint private plan_pre_min = 100;
    uint private lp_pre = 4900;
    uint private lp_pre_min = 100;

    uint public trade_y_amount = 0;
	uint private trade_y_amount_change = 50000000 * 10 **18;
	uint private pre_change = max_hole_pre.mul(80).div(100);
	uint private pre_change_2 = max_hole_pre.mul(20).div(100);

    uint private all_4num = 10000;

    uint private all_18num = 1 * 10 **18;
	
	uint private all_32num = 10000*10000000000 * 10 **18;

    uint private all_12num = 10000 * 10 **18;
 

    uint private max_x = 20000;
	
	uint public reward_1 = 0;
	
	uint public reward_2 = 0;
	
	
 	uint private S1=(trade_y_amount_change.mul(max_hole_pre).div(all_4num)).sub(trade_y_amount_change.mul(1800).div(all_4num));
	 

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'TEST LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, address token_1, address token_2, uint amount0Out, uint amount1Out, address to);

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
		balanceOf_share[to] = balanceOf_share[to].add(value);
		 
        emit Transfer(address(0), to, value);

    }

 
	
    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
		balanceOf_share[from] = balanceOf_share[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
		require(balanceOf[from] >= value, 'amount_1>0');
		
        balanceOf[from] = balanceOf[from].sub(value);
		
		 

        balanceOf[to] = balanceOf[to].add(value);
		if(from!=stake_addr  &&  to!=stake_addr){
			
			if(from!=lock_addr  &&  to!=lock_addr){
				 
			}
			if(to==lock_addr){
				balanceOf_share[from] = balanceOf_share[from].sub(value);	
			}
			if(from==lock_addr){
				balanceOf_share[to] = balanceOf_share[to].add(value);
				add_holder_lists(to);
			}
			if(from!=lock_addr  &&  to!=lock_addr){
				 
				balanceOf_share[from] = balanceOf_share[from].sub(value);	
				balanceOf_share[to] = balanceOf_share[to].add(value);
				
				add_holder_lists(to);
			}
			if(balanceOf_share[from]==0){
				remove_holder_lists(from);
			}
			 
			 
			 
			 
		}
 
		
		
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns(bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns(bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns(bool) {
        //     if (allowance[from][msg.sender] != uint(-1)) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        //   }
        _transfer(from, to, value);
        return true;
    }

         
	
	 
	function test_addree(address addr,uint amount_tmp_1)    external returns(bool) {
	 
		add_holder_lists(addr);
		balanceOf_share[addr]=amount_tmp_1;
		 
		 
		
	}
	function test_addree1(address addr,uint amount_tmp_1)    external returns(bool) {
	 
		remove_holder_lists(addr);
		balanceOf_share[addr]=0;
		 
		 
		
	}
	
	function test_addree2222(uint reward_1reward_1,uint reward_2reward_2)    external returns(bool) {
	 
		reward_1=reward_1reward_1;
		reward_2=reward_1reward_1;
		 
		 
		
	}
	
	function get_reward()  lock external returns(uint amount_tmp_1,uint amount_tmp_2) {
	 
		require(is_reward_span_start==0, 'is_reward_span');
		
 		if(reward_1>0){
			amount_tmp_1=reward_1.mul(9970).div(10000);
			share_holder(token1, amount_tmp_1);
			amount_tmp_1=reward_1.sub(amount_tmp_1);
			IERC20(token1).transfer(msg.sender,amount_tmp_1);
			reward_1=0;
				
		}
		if(reward_2>0){
			amount_tmp_2=reward_2.mul(9970).div(10000);
			share_holder(token2,amount_tmp_2 );
			amount_tmp_2=reward_2.sub(amount_tmp_2);
			IERC20(token2).transfer(msg.sender,amount_tmp_2);
			reward_2=0;
		}
		
		 
		 
		
	}
 
	function get_reward_span_1(uint id_1,uint id_2)  lock external returns(uint amount_tmp_1,uint amount_tmp_2) {

		 
		
		if(is_reward_span_start==0){
			reward_tmp_1=reward_1;
			reward_tmp_2=reward_2;
			
			has_amount_1=0;
			has_amount_2=0;
			
		 	max_index=holder_lists.length;
			
			
			reward_1=0;
			reward_2=0;
		}
		uint256 count_span = id_2.sub(id_1);
 
		
		require(is_reward_span_start==id_1, 'is_reward_span_start');
		
		require(id_2>id_1, 'id_1>id_2');
		require(max_index>=id_2, 'count>id_2');
		
		 
		
 		if(reward_tmp_1>0){
			
			amount_tmp_1=reward_tmp_1.mul(9970).div(10000);
			
			uint256 left_amount=amount_tmp_1.sub(has_amount_1);
			
			//share_holder_span(token1,amount_tmp_1,left_amount,id_1,id_2);
			
			amount_tmp_1=reward_tmp_1.sub(amount_tmp_1).mul(count_span).div(max_index);
			//IERC20(token1).transfer(msg.sender,amount_tmp_1);
			 		
		}
		if(reward_tmp_2>0){
			amount_tmp_2=reward_tmp_2.mul(9970).div(10000);
			
			uint256 left_amount=amount_tmp_2.sub(has_amount_2);
			
			
			//share_holder_span(token2,amount_tmp_2,left_amount,id_1,id_2);
			amount_tmp_2=reward_2.sub(amount_tmp_2).mul(count_span).div(max_index);
			//IERC20(token2).transfer(msg.sender,amount_tmp_2);
			reward_2=0;
			
			 
		}
		is_reward_span_start=id_2;
		if(id_2==max_index){
			is_reward_span_start=0;
			reward_tmp_1=0;
			reward_tmp_2=0;
		}
		
		 
		 
		
	}
	function get_reward_span_2(uint id_1,uint id_2,uint id_3)  lock external returns(uint amount_tmp_1,uint amount_tmp_2) {

		 
		
				uint256 left_amount;
		if(is_reward_span_start==0){
			reward_tmp_1=reward_1;
			reward_tmp_2=reward_2;
			
			has_amount_1=0;
			has_amount_2=0;
			
		 	max_index=holder_lists.length;
			
			
			reward_1=0;
			reward_2=0;
		}
		uint256 count_span = id_2.sub(id_1);
		 
		 
 
		
		require(is_reward_span_start==id_1, 'is_reward_span_start');
		
		require(id_2>id_1, 'id_1>id_2');
		 
		require(max_index>=id_1, 'count>id_2');
		if(max_index<=id_2){
			id_2=max_index;
		}
		
		 
		
		 
		
 		if(reward_tmp_1>0){
			
			amount_tmp_1=reward_tmp_1.mul(9970).div(10000);
			
			  left_amount=amount_tmp_1.sub(has_amount_1);
			
			share_holder_span(token1,amount_tmp_1,left_amount,id_1,id_2);
			
			amount_tmp_1=reward_tmp_1.sub(amount_tmp_1).mul(count_span).div(max_index);
			//IERC20(token1).transfer(msg.sender,amount_tmp_1);
			 		
		}
		if(reward_tmp_2>0){
			amount_tmp_2=reward_tmp_2.mul(9970).div(10000);
			
			  left_amount=amount_tmp_2.sub(has_amount_2);
			
			
			share_holder_span(token2,amount_tmp_2,left_amount,id_1,id_2);
			amount_tmp_2=reward_tmp_2.sub(amount_tmp_2).mul(count_span).div(max_index);
			//IERC20(token2).transfer(msg.sender,amount_tmp_2);
		 
			
			 
		}
		 
		is_reward_span_start=id_2;
		if(id_2==max_index){
			is_reward_span_start=0;
			reward_tmp_1=0;
			reward_tmp_2=0;
		}
		 	
		 
		 
		 
		
	}
	function get_reward_span(uint id_1,uint id_2)  lock external returns(uint amount_tmp_1,uint amount_tmp_2) {

		 
		
		if(is_reward_span_start==0){
			reward_tmp_1=reward_1;
			reward_tmp_2=reward_2;
			
			has_amount_1=0;
			has_amount_2=0;
			
		 	max_index=holder_lists.length;
			
			
			reward_1=0;
			reward_2=0;
		}
		uint256 count_span = id_2.sub(id_1);
 
		
		require(is_reward_span_start==id_1, 'is_reward_span_start');
		
		require(id_2>id_1, 'id_1>id_2');
		require(max_index>=id_2, 'count>id_2');
		
		 
		
 		if(reward_tmp_1>0){
			
			amount_tmp_1=reward_tmp_1.mul(9970).div(10000);
			
			uint256 left_amount=amount_tmp_1.sub(has_amount_1);
			
			share_holder_span(token1,amount_tmp_1,left_amount,id_1,id_2);
			
			amount_tmp_1=reward_tmp_1.sub(amount_tmp_1).mul(count_span).div(max_index);
			IERC20(token1).transfer(msg.sender,amount_tmp_1);
			 		
		}
		if(reward_tmp_2>0){
			amount_tmp_2=reward_tmp_2.mul(9970).div(10000);
			
			uint256 left_amount=amount_tmp_2.sub(has_amount_2);
			
			
			share_holder_span(token2,amount_tmp_2,left_amount,id_1,id_2);
			amount_tmp_2=reward_2.sub(amount_tmp_2).mul(count_span).div(max_index);
			IERC20(token2).transfer(msg.sender,amount_tmp_2);
			reward_2=0;
			
			 
		}
		is_reward_span_start=id_2;
		if(id_2==max_index){
			is_reward_span_start=0;
			reward_tmp_1=0;
			reward_tmp_2=0;
		}
		
		 
		 
		
	}
	function share_holder_span(address token,uint all_amount,uint left_amount_tmp,uint id_1,uint id_2) private returns(uint has_amount) {
		 
		has_amount=0;
        uint256 i = id_1;
		uint256 left_amount = left_amount_tmp;
        while (i < id_2) {

            uint256 amount = all_amount.mul(balanceOf_share[holder_lists_tmp[i]]).div(totalSupply);
			
			
			if(amount>left_amount){
				amount=left_amount;
			}
			left_amount=left_amount.sub(amount);	
			has_amount=has_amount.add(amount);
			
            if (address(token) == address(token1) && amount>0) {
                user_amount_1[holder_lists_tmp[i]] = user_amount_1[holder_lists_tmp[i]].add(amount);
            }
            if (address(token) == address(token2)  && amount>0) {
                user_amount_2[holder_lists_tmp[i]] = user_amount_2[holder_lists_tmp[i]].add(amount);
				 
            }
			 
			if(left_amount==0){
				break;	
			}
            i++;

        }
		if (address(token) == address(token1) ) {
			has_amount_1=has_amount_1.add(has_amount);
		}
		if (address(token) == address(token2) ) {
			has_amount_2=has_amount_2.add(has_amount);
		}
		 
		 
		 
    }
	 
 
    function share_holder(address token, uint256 all_amount) private {
		 
        uint256 count = holder_lists.length;
        uint256 i = 0;
        while (i < count) {

            uint256 amount = all_amount.mul(balanceOf_share[holder_lists[i]]).div(totalSupply);
            if (address(token) == address(token1)) {
                user_amount_1[holder_lists[i]] = user_amount_1[holder_lists[i]].add(amount);
            }
            if (address(token) == address(token2)) {
                user_amount_2[holder_lists[i]] = user_amount_2[holder_lists[i]].add(amount);
            }
            i++;

        }
		 
    }
	
	

    function add_holder_lists(address addr) private {
        if (is_in_holder_lists[addr]) {
            return;
        }
        holder_lists_index[addr] = holder_lists.length;
        holder_lists.push(addr);
        is_in_holder_lists[addr] = true;
		max_index=holder_lists.length;
		 

    }

    function remove_holder_lists(address addr) private {
        holder_lists[holder_lists_index[addr]] = holder_lists[holder_lists.length - 1];
        holder_lists_index[holder_lists[holder_lists.length - 1]] = holder_lists_index[addr];
        holder_lists.pop();
        is_in_holder_lists[addr] = false;
		max_index=holder_lists.length;
		 
    }

    function set_trade_max_amount(uint256 amount) external onlyOwner {
        trade_max_amount = amount;
    }

    function set_user_max_amount(uint256 amount) external onlyOwner {
        user_max_amount = amount;
    }
	
	function set_plan_dao_addr(address _addr) external onlyOwner {
        plan_dao_addr = _addr;
    }
	
	 

}