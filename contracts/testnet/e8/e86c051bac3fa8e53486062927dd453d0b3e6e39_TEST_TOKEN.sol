/**
 *Submitted for verification at BscScan.com on 2022-07-09
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

pragma solidity >= 0.5.16;

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

pragma solidity >= 0.5.16;

library UQ112x112 {
	uint224 constant Q112 = 2 **112;

	// encode a uint112 as a UQ112x112
	function encode(uint112 y) internal pure returns(uint224 z) {
		z = uint224(y) * Q112; // never overflows
	}

	// divide a UQ112x112 by a uint112, returning a UQ112x112
	function uqdiv(uint224 x, uint112 y) internal pure returns(uint224 z) {
		z = x / uint224(y);
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
interface facotry {

	function swap_addr_output(address addr) external view returns(uint);

	function set_token_price(uint256 amount) external returns(bool);

	function get_fee(address addr, uint256 amount) external returns(bool);
	function add_token_amount(uint256 value) external returns(bool);
	function remove_token_amount(uint256 amount) external returns(bool);
}
interface stake {

	function share_holder() external view returns(bool);

}

pragma solidity >= 0.5.16;

contract TEST_TOKEN is Owner {
	using SafeMath
	for uint;

	string public constant name = 'TEST-LP';
	string public constant symbol = 'TEST-LP';
	uint8 public constant decimals = 18;
	uint public totalSupply;
	mapping(address =>uint) public balanceOf;
	mapping(address =>uint) public user_amount_1;
	mapping(address =>uint) public user_amount_2;

	mapping(address =>bool) public is_in_holder_lists;

	address[] public holder_lists;
	mapping(address =>uint256) public holder_lists_index;

	uint public trade_max_amount = 0;
	uint public trade_cur_amount = 0;

	uint public user_max_amount = 0;
	mapping(address =>uint) public user_cur_amount;

	mapping(address =>mapping(address =>uint)) public allowance;

	bytes32 public DOMAIN_SEPARATOR;

	uint public constant MINIMUM_LIQUIDITY = 10 **3;

	address public stake_addr;

	address public factory_addr;
	uint public factory_sync_time_span = 1800;
	uint public factory_sync_time_cur = 0;

	address public token1 = 0x51258E88Bcfa03a65Ad9DeE37Cd420cf3ae60412;
	address public token2 = 0xF4D2EBF791BAc710D3f84F71364f0fc3630E7cF3;

	uint public amount1;
	uint public amount2;

	uint public amount1_r;
	uint public amount2_r;

	address public hole_address = 0x000000000000000000000000000000000000dEaD;
 
 

	uint public hole_amount_max = 690000000 * 10 **18;
	uint public max_hole_pre = 4500;
 
	uint public lp_pre = 4500;

	uint public all_count = 10000;
	
	uint public all_count_unit = 1000000000;
	
	uint public all_count_hole = 10000*1000000000;

	uint public k;

	uint public price_1;
	uint public price_2;

	uint public x;

	uint public max_x = 20000;

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
		emit Transfer(address(0), to, value);

	}

	function _burn(address from, uint value) internal {
		balanceOf[from] = balanceOf[from].sub(value);
		totalSupply = totalSupply.sub(value);
		emit Transfer(from, address(0), value);
	}

	function _approve(address owner, address spender, uint value) private {
		allowance[owner][spender] = value;
		emit Approval(owner, spender, value);
	}

	function _transfer(address from, address to, uint value) private {
		balanceOf[from] = balanceOf[from].sub(value);

		balanceOf[to] = balanceOf[to].add(value);
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

	function addLiquidity(uint amount_1, uint amount_2, uint amount_1_min, uint amount_2_min, address to, uint deadline) external returns(uint amount_A, uint amount_B, uint amount_liquidity) {
		require(amount_1 > 0, 'amount_1>0');
		require(amount_2 > 0, 'amount_2>0');
		require(amount_1_min > 0, 'amount_1_min>0');
		require(amount_2_min > 0, 'amount_2_min>0');
		require(block.timestamp < deadline, "TIME PAST"); (amount_A, amount_B, amount_liquidity) = _addLiquidity(amount_1, amount_2, amount_1_min, amount_2_min, to);
	}

	function _addLiquidity(uint amount_1, uint amount_2, uint amount_1_min, uint amount_2_min, address to) private lock returns(uint real_amount_1, uint real_amount_2, uint liquidity) {
		uint _totalSupply = totalSupply;

		uint get_amount_1 = amount_1;
		uint get_amount_2 = amount_2;
		if (_totalSupply > 0) {

			get_amount_2 = amount_1.mul(all_count).div(amount1);
			get_amount_2 = get_amount_2.mul(amount2);
			get_amount_2 = get_amount_2.div(all_count);
			if (get_amount_2 <= amount_2) {

				require(get_amount_2 >= amount_2_min, 'INSUFFICIENT_2_AMOUNT');
			} else {
				get_amount_1 = amount_2.mul(all_count).div(amount2);
				get_amount_1 = get_amount_1.mul(amount1);
				get_amount_1 = get_amount_1.div(all_count);

				assert(get_amount_1 <= amount_1);

				require(get_amount_1 >= amount_1_min, 'INSUFFICIENT_1_AMOUNT');

			}

		}

		real_amount_1 = get_amount_1;
		real_amount_2 = get_amount_2;

		uint balance_1 = amount1;
		uint balance_2 = amount2;
		IERC20(token1).transferFrom(msg.sender, address(this), real_amount_1);
		IERC20(token2).transferFrom(msg.sender, address(this), real_amount_2);

		if (_totalSupply == 0) {
			liquidity = Math.sqrt(real_amount_1.mul(real_amount_2)).sub(MINIMUM_LIQUIDITY);
		} else {
			liquidity = Math.min(real_amount_1.mul(_totalSupply) / balance_1, real_amount_2.mul(_totalSupply) / balance_2);
		}

		add_holder_lists(to);
		amount1 = amount1.add(real_amount_1);
		amount2 = amount2.add(real_amount_2);

		require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');
		_mint(to, liquidity);

		//factory_sync();
		emit Mint(msg.sender, real_amount_1, real_amount_2);
	}

	function removeLiquidity(uint amount, address to, uint amount_1_min, uint amount_2_min) external {
		require(amount > 0, 'amount>0');
		require(amount_1_min > 0, 'amount_1_min>0');
		require(amount_2_min > 0, 'amount_2_min>0');

		burn(amount, to, amount_1_min, amount_2_min);
	}

	function burn(uint amount, address to, uint amount_1_min, uint amount_2_min) private lock returns(uint amount_1, uint amount_2) {

		uint balance0 = amount1;
		uint balance1 = amount2;
		uint liquidity = balanceOf[msg.sender];

		require(liquidity >= amount, 'TEST: INSUFFICIENT_LIQUIDITY_BURNED');

		uint _totalSupply = totalSupply;

		amount_1 = amount.mul(balance0) / _totalSupply;
		amount_2 = amount.mul(balance1) / _totalSupply;

		require(amount_1 > 0 && amount_2 > 0, 'TEST: INSUFFICIENT_LIQUIDITY_BURNED');

		require(amount_1 >= amount_1_min, 'TEST: INSUFFICIENT_AMOUNT_1');

		require(amount_2 >= amount_2_min, 'TEST: INSUFFICIENT_AMOUNT_2');

		_burn(msg.sender, amount);

		amount1 = amount1.sub(amount_1);
		amount2 = amount2.sub(amount_2);

		if (liquidity == amount) {
			amount_1 = amount_1.add(user_amount_1[msg.sender]);
			amount_2 = amount_2.add(user_amount_2[msg.sender]);
			user_amount_1[msg.sender] = 0;
			user_amount_2[msg.sender] = 0;

			remove_holder_lists(msg.sender);
		}

		IERC20(token1).transfer(to, amount_1);
		IERC20(token2).transfer(to, amount_2);

		//factory_sync();
		emit Burn(msg.sender, amount_1, amount_2, to);

	}
	function _get_pre(uint256 amount_1) internal view returns(uint pre) {

		uint hole_amount = IERC20(token2).balanceOf(hole_address);
		pre = (hole_amount.add(max_hole_pre.mul(amount_1).div(10000))).mul(all_count_hole) / (hole_amount_max.add(max_hole_pre.mul(amount_1)));
	}
	function get_pre(uint256 amount_1) external view returns(uint pre) {
		uint hole_amount = IERC20(token2).balanceOf(hole_address);
		pre = (hole_amount.add(max_hole_pre.mul(amount_1).div(10000))).mul(all_count_hole) / (hole_amount_max.add(max_hole_pre.mul(amount_1)));

	}
     
     

	function _get_lp_fee(uint256 amount_1) internal view returns(uint lp_fee) {
		uint pre = _get_pre(amount_1);
		lp_fee = amount_1.mul(lp_pre);
		lp_fee = lp_fee.mul(all_count_hole - pre).div(all_count_hole);
		lp_fee = lp_fee.div(10000) + 5;

	}
	function _get_y(uint256 amount_1, uint256 plan_fee, uint256 to_hole_amount, uint256 lp_fee) internal pure returns(uint to_y) {
		to_y = amount_1.sub(plan_fee);
		to_y = to_y.sub(to_hole_amount);
		to_y = to_y.sub(lp_fee);

	}
	function _get_x(uint256 amount_1) internal view returns(uint get_amount) {

		 uint pre = _get_pre(amount_1);

		if (pre > all_count_hole) {
			pre = all_count_hole;
		}			 
		 
		 
		
		uint x_tmp = all_count_hole + (max_x.mul(all_count_unit) - all_count_hole).mul((all_count_hole.sub(pre))).div(all_count_hole);
		if (x_tmp < all_count_hole) {
			x_tmp = all_count_hole;
		}
		 
		uint amount2_tmp=amount2.mul(x_tmp).div(all_count_hole);
		uint k_tmp =(amount1 * amount2_tmp );	
		get_amount = amount1.sub(k_tmp.div(amount2_tmp.add(amount_1)));

	}
	
	 
	
	function get_x(uint256 amount_1) external view  returns(uint get_amount) {

		  get_amount = _get_x(amount_1);
 

	}
	 
	
	 

	function _get_hole_amount(uint256 amount_1) internal view returns(uint to_hole_amount) {

		uint pre = _get_pre(amount_1);

		uint tmp = amount_1.mul(max_hole_pre);
		tmp = tmp.mul(all_count_hole.sub(pre));
		tmp = tmp.div(all_count_hole).div(all_count);
		to_hole_amount = tmp;
		uint hole_amount = IERC20(token2).balanceOf(hole_address);
		if (hole_amount_max < hole_amount.add(to_hole_amount)) {
			uint span = hole_amount.add(to_hole_amount).sub(hole_amount_max);
			if (span < to_hole_amount) {
				to_hole_amount = to_hole_amount.sub(span);
			} else {
				to_hole_amount = 0;
			}

		}

	}

	function swap(address token_1, address token_2, uint amount_1, uint amount_2, address to, uint deadline) lock external returns(uint amountB) {

		uint get_amount = 0;
		uint plan_fee = 0;
		uint lp_fee = 0;

		uint to_y = 0;

		if (address(token_1) == address(token1) && address(token_2) == address(token2)) {
			k = amount1 * amount2;
			get_amount = amount2 - k.div(amount1.add(amount_1));

		}
		if (address(token_1) == address(token2) && address(token_2) == address(token1)) {

			get_amount = _get_x(amount_1);

		}

		if (trade_max_amount > 0 && address(token_1) == address(token1)) {
			require(trade_max_amount >= trade_cur_amount.add(amount_1), 'too much');
		}
		if (user_max_amount > 0 && address(token_1) == address(token1)) {

			require(user_max_amount >= (user_cur_amount[to].add(amount_1)), 'too much for user');
		}

		require(get_amount > 0, 'get_amount');

		require(deadline > block.timestamp, 'deadline');

		require(get_amount.mul(9970).div(10000) >= amount_2, 'TEST: amount_2');

		if (address(token_1) == address(token1)) {

			IERC20(token_2).transfer(to, get_amount.mul(9970).div(10000));

			plan_fee = get_amount.mul(10).div(10000);

			IERC20(token_1).transferFrom(msg.sender, address(this), amount_1);
			IERC20(token_2).transfer(hole_address, get_amount.mul(10).div(10000));

			share_holder(token_2, get_amount.mul(10).div(10000));

			amount1 = amount1.add(amount_1);
			amount1 = amount1.add(get_amount.mul(10).div(10000));

			amount2 = amount2.sub(get_amount.mul(9990).div(10000));
		}
		if (address(token_1) == address(token2)) {

			uint to_hole_amount = _get_hole_amount(amount_1);
			require(to_hole_amount >= 0, 'TEST: to_hole_amount>=0');

			if (to_hole_amount > 0) {
				IERC20(token_1).transferFrom(msg.sender, hole_address, to_hole_amount);
			}

			 

			lp_fee = _get_lp_fee(amount_1);

			to_y = _get_y(amount_1, 0, to_hole_amount, lp_fee);

			IERC20(token_1).transferFrom(msg.sender, address(this), (lp_fee + to_y));

			IERC20(token_2).transfer(to, get_amount.mul(9970).div(10000));

			share_holder(token_1, lp_fee);
			share_holder(token_2, get_amount.mul(30).div(10000));

			amount1 = amount1.sub(get_amount);
			amount2 = amount2.add(to_y);

		}
		 

		if (trade_max_amount > 0 && address(token_1) == address(token1)) {
			trade_cur_amount = trade_cur_amount.add(amount_1);
		}

		if (user_max_amount > 0 && address(token_1) == address(token1)) {
			user_cur_amount[to] = user_cur_amount[to].add(amount_1);
		}

		amountB = get_amount;

//		factory_sync();
		emit Swap(msg.sender, token_1, token_2, amount_1, amount_2, to);
	}
	
	 

	function factory_sync() private {

		uint256 amount = amount2.div(totalSupply);
		if (factory_sync_time_span < (block.timestamp - factory_sync_time_cur) && factory_addr != address(0x0) && amount > 0) {
			facotry(factory_addr).set_token_price(amount);
			stake(stake_addr).share_holder();
		}
	}

	function share_holder(address token, uint256 all_amount) private {
		uint256 count = holder_lists.length;
		uint256 i = 0;
		while (i < count) {

			uint256 amount = all_amount.mul(balanceOf[holder_lists[i]]).div(totalSupply);
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

		add_holder(addr);
		is_in_holder_lists[addr] = true;

	}

	function add_holder(address addr) internal {
		holder_lists_index[addr] = holder_lists.length;
		holder_lists.push(addr);
	}
	function remove_holder_lists(address addr) private {
		remove_holder(addr);
		is_in_holder_lists[addr] = false;
	}
	function remove_holder(address addr) internal {
		holder_lists[holder_lists_index[addr]] = holder_lists[holder_lists.length - 1];
		holder_lists_index[holder_lists[holder_lists.length - 1]] = holder_lists_index[addr];
		holder_lists.pop();
	}

	function set_trade_max_amount(uint256 amount) external onlyOwner {
		trade_max_amount = amount;
	}

	function set_user_max_amount(uint256 amount) external onlyOwner {
		user_max_amount = amount;
	}

	function set_hole_amount_max(uint256 amount) external onlyOwner {
		hole_amount_max = amount;
	}
	function set_factory_addr(address addr) external onlyOwner {
		factory_addr = addr;
	}
	function set_factory_sync_time_span(uint256 time) external onlyOwner {
		factory_sync_time_span = time;
	}
	function set_stake_addr(address addr) external onlyOwner {
		stake_addr = addr;
	}
	function set_token1(address addr) external onlyOwner {
		token1 = addr;
	}
	function set_token2(address addr) external onlyOwner {
		token2 = addr;
	}

}