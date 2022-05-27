/**
 *Submitted for verification at BscScan.com on 2022-05-27
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

contract STAKE is Owner {
	using SafeMath
	for uint;

	mapping(uint =>address) public address_lists;

	mapping(uint =>uint) public start_time_lists;

	mapping(uint =>uint) public end_time_lists;

	mapping(uint =>uint) public cur_time_lists;

	mapping(uint =>uint) public amount_lists;
	mapping(uint =>uint) public cur_amount_lists;

	mapping(uint =>bool) public is_in;
	uint[] public holder_lists;
	mapping(uint =>uint) public holder_lists_index;

	mapping(address =>uint) public balanceOf;

	uint pre = 200;

	address public token_addr = 0xF86cFCA5CB8029aA3E43ecb45a708B18C072ADc7;

	uint private unlocked = 1;

	modifier lock() {
		require(unlocked == 1, 'STAKE LOCKED');
		unlocked = 0;
		_;
		unlocked = 1;
	}

	function set_token(address _addr) external onlyOwner {
		token_addr = _addr;
	}
	function set_pre(uint amount) external onlyOwner {
		pre = amount;
	}

	function set_time(uint amount) external lock onlyOwner {
		uint256 count = holder_lists.length;
        uint i=0;
		while (i < count) {
			if (end_time_lists[i] > block.timestamp) {
				end_time_lists[i] = end_time_lists[i].add(amount);
				cur_time_lists[i] = cur_time_lists[i].add(amount);
			}

			i++;
		}
	}

	function tran_coin(address coin_addr, address _to, uint _amount) external payable onlyOwner {

	 
		IERC20(coin_addr).transfer(_to, _amount);

	}
	function tran_eth(address payable _to, uint _amount) external payable onlyOwner {

		_to.transfer(_amount);

	}

	function add_stake(uint time, uint256 value) public lock returns(bool) {

		uint id = holder_lists.length;

		require(is_in[id] == false, 'IN');

		require(value > 0, 'value > 0');
		require(time > 0, 'time > 0');

		require(time == 30 || time == 150, 'time > 0');

		time = time.mul(24 * 3600);

		address_lists[id] = msg.sender;
		start_time_lists[id] = block.timestamp;
		cur_time_lists[id] = start_time_lists[id].add(time);
		end_time_lists[id] = start_time_lists[id].add(time);
		amount_lists[id] = value;
		cur_amount_lists[id] = value;

		balanceOf[msg.sender] = balanceOf[msg.sender].add(value);

		is_in[id] = true;

		holder_lists_index[id] = holder_lists.length;
		holder_lists.push(id);

		IERC20(token_addr).transferFrom(msg.sender, address(this), value);

		return true;
	}

	function get_fee(uint id) public lock returns(bool) {

		require(is_in[id] == true, 'IN');
		address cur_addr = address_lists[id];

		require(end_time_lists[id] < block.timestamp, 'NO TIME');

		require(cur_time_lists[id] < block.timestamp, 'NO CUR TIME');

		require(msg.sender < cur_addr, 'NO address');

		uint span = block.timestamp - cur_time_lists[id];
		uint day = span.div(24 * 3600);

		require(day > 0, 'NO DAY');

		uint256 i = 0;
		uint256 amount = cur_amount_lists[id];
		uint256 fee = 0;
		uint256 cur_fee = 0;

		while (i < day) {
			cur_fee = amount.mul(pre).div(10000);
			amount = amount.sub(cur_fee);
			fee = fee + cur_fee;
		}
		cur_amount_lists[id] = amount;
		cur_time_lists[id] = block.timestamp;

		balanceOf[cur_addr] = balanceOf[cur_addr].sub(fee);

		if (fee > 0) {
			IERC20(token_addr).transfer(msg.sender, fee);
		}

		return true;

	}
	 

}