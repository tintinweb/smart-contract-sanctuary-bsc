/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: MIT
	pragma solidity 0.8.7;
	interface Ipair{
		function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
		function token0() external view returns (address);
		function token1() external view returns (address);
	}
	library SafeMath {
		/**
		 * @dev Returns the addition of two unsigned integers, reverting on
		 * overflow.
		 *
		 * Counterpart to Solidity's `+` operator.
		 *
		 * Requirements:
		 *
		 * - Addition cannot overflow.
		 */
		function add(uint256 a, uint256 b) internal pure returns (uint256) {
			uint256 c = a + b;
			require(c >= a, "SafeMath: addition overflow");
	
			return c;
		}
	
		/**
		 * @dev Returns the subtraction of two unsigned integers, reverting on
		 * overflow (when the result is negative).
		 *
		 * Counterpart to Solidity's `-` operator.
		 *
		 * Requirements:
		 *
		 * - Subtraction cannot overflow.
		 */
		function sub(uint256 a, uint256 b) internal pure returns (uint256) {
			return sub(a, b, "SafeMath: subtraction overflow");
		}
	
		/**
		 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
		 * overflow (when the result is negative).
		 *
		 * Counterpart to Solidity's `-` operator.
		 *
		 * Requirements:
		 *
		 * - Subtraction cannot overflow.
		 */
		function sub(
			uint256 a,
			uint256 b,
			string memory errorMessage
		) internal pure returns (uint256) {
			require(b <= a, errorMessage);
			uint256 c = a - b;
	
			return c;
		}
	
		/**
		 * @dev Returns the multiplication of two unsigned integers, reverting on
		 * overflow.
		 *
		 * Counterpart to Solidity's `*` operator.
		 *
		 * Requirements:
		 *
		 * - Multiplication cannot overflow.
		 */
		function mul(uint256 a, uint256 b) internal pure returns (uint256) {
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) {
				return 0;
			}
	
			uint256 c = a * b;
			require(c / a == b, "SafeMath: multiplication overflow");
	
			return c;
		}
	
		/**
		 * @dev Returns the integer division of two unsigned integers. Reverts on
		 * division by zero. The result is rounded towards zero.
		 *
		 * Counterpart to Solidity's `/` operator. Note: this function uses a
		 * `revert` opcode (which leaves remaining gas untouched) while Solidity
		 * uses an invalid opcode to revert (consuming all remaining gas).
		 *
		 * Requirements:
		 *
		 * - The divisor cannot be zero.
		 */
		function div(uint256 a, uint256 b) internal pure returns (uint256) {
			return div(a, b, "SafeMath: division by zero");
		}
	
		/**
		 * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
		 * division by zero. The result is rounded towards zero.
		 *
		 * Counterpart to Solidity's `/` operator. Note: this function uses a
		 * `revert` opcode (which leaves remaining gas untouched) while Solidity
		 * uses an invalid opcode to revert (consuming all remaining gas).
		 *
		 * Requirements:
		 *
		 * - The divisor cannot be zero.
		 */
		function div(
			uint256 a,
			uint256 b,
			string memory errorMessage
		) internal pure returns (uint256) {
			require(b > 0, errorMessage);
			uint256 c = a / b;
			// assert(a == b * c + a % b); // There is no case in which this doesn't hold
	
			return c;
		}
	
		/**
		 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
		 * Reverts when dividing by zero.
		 *
		 * Counterpart to Solidity's `%` operator. This function uses a `revert`
		 * opcode (which leaves remaining gas untouched) while Solidity uses an
		 * invalid opcode to revert (consuming all remaining gas).
		 *
		 * Requirements:
		 *
		 * - The divisor cannot be zero.
		 */
		function mod(uint256 a, uint256 b) internal pure returns (uint256) {
			return mod(a, b, "SafeMath: modulo by zero");
		}
	
		/**
		 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
		 * Reverts with custom message when dividing by zero.
		 *
		 * Counterpart to Solidity's `%` operator. This function uses a `revert`
		 * opcode (which leaves remaining gas untouched) while Solidity uses an
		 * invalid opcode to revert (consuming all remaining gas).
		 *
		 * Requirements:
		 *
		 * - The divisor cannot be zero.
		 */
		function mod(
			uint256 a,
			uint256 b,
			string memory errorMessage
		) internal pure returns (uint256) {
			require(b != 0, errorMessage);
			return a % b;
		}
	}
	contract Ownable {
		address private _owner;
	
		event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
		/**
		 * @dev Initializes the contract setting the deployer as the initial owner.
		 */
		constructor () {
			_owner = msg.sender;
			emit OwnershipTransferred(address(0), _owner);
		}
	
		/**
		 * @dev Returns the address of the current owner.
		 */
		function owner() public view  returns (address) {
			return _owner;
		}
	
		/**
		 * @dev Throws if called by any account other than the owner.
		 */
		modifier onlyOwner() {
			require(owner() == msg.sender, "Ownable: caller is not the owner");
			_;
		}
	
		/**
		 * @dev Leaves the contract without owner. It will not be possible to call
		 * `onlyOwner` functions anymore. Can only be called by the current owner.
		 *
		 * NOTE: Renouncing ownership will leave the contract without an owner,
		 * thereby removing any functionality that is only available to the owner.
		 */
		function renounceOwnership() public  onlyOwner {
			emit OwnershipTransferred(_owner, address(0));
			_owner = address(0);
		}
	
		/**
		 * @dev Transfers ownership of the contract to a new account (`newOwner`).
		 * Can only be called by the current owner.
		 */
		function transferOwnership(address newOwner) public onlyOwner {
			require(newOwner != address(0), "Ownable: new owner is the zero address");
			emit OwnershipTransferred(_owner, newOwner);
			_owner = newOwner;
		}
	}
	contract ERC20 {
	
		mapping (address => uint256) internal _balances;
		 
		mapping (address => mapping (address => uint256)) private _allowances;
	
	
		uint256 private _totalSupply;
		string private _name;
		string private _symbol;
		uint8 private _decimals;
		
		
		address public holder_addr=0x0000000000000000000000000000000000000000;
	
	
		event Transfer(address indexed from, address indexed to, uint256 value);
		event Approval(address indexed owner, address indexed spender, uint256 value);
	
		constructor() {
			_name = "Chocolate";
			_symbol = "Chocolate";
			_decimals = 18;
		}
	
		function name() public view returns (string memory) {
			return _name;
		}
	
		function symbol() public view returns (string memory) {
			return _symbol;
		}
	
		function decimals() public view returns (uint8) {
			return _decimals;
		}
	
		function totalSupply() public view returns (uint256) {
			return _totalSupply;
		}
	
		function balanceOf(address account) public view returns (uint256) {
			return _balances[account];
		}
	
		function transfer(address recipient, uint256 amount) public virtual returns (bool) {
			_transfer(msg.sender, recipient, amount);
			return true;
		}
	
		function allowance(address owner, address spender) public view virtual returns (uint256) {
			return _allowances[owner][spender];
		}
	
		function approve(address spender, uint256 amount) public virtual returns (bool) {
			_approve(msg.sender, spender, amount);
			return true;
		}
	
		function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
			_transfer(sender, recipient, amount);
			_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
			return true;
		}
	
		function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
			_approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
			return true;
		}
	
		function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
			_approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
			return true;
		}
	
		function _transfer(address sender, address recipient, uint256 amount) internal virtual {
			require(sender != address(0), "ERC20: transfer from the zero address");
	
			uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);
	
			_balances[sender] = _balances[sender] - amount;
			_balances[recipient] = _balances[recipient] + trueAmount;
			emit Transfer(sender, recipient, trueAmount);
		}
	
		function _mint(address account, uint256 amount) internal virtual {
			require(account != address(0), "ERC20: mint to the zero address");
	
			_totalSupply = _totalSupply + amount;
			_balances[account] = _balances[account] + amount;
			emit Transfer(address(0), account, amount);
		}
	
		function _approve(address owner, address spender, uint256 amount) internal virtual {
			require(owner != address(0), "ERC20: approve from the zero address");
			require(spender != address(0), "ERC20: approve to the zero address");
	
			_allowances[owner][spender] = amount;
			emit Approval(owner, spender, amount);
		}
	
		function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
	}
	
	
	
	
	contract Chocolate is ERC20, Ownable{
		using SafeMath for uint256;
	
		
	
		mapping(address => bool) public Pair_address;
		 
	
		uint256 public buy_rate = 100;
		uint256 public sell_rate = 100;
		constructor () Ownable(){	
	
			_mint(msg.sender,700000000 * 10**18);
	
		}
	
		function _beforeTokenTransfer(
			address _from,
			address _to,
			uint256 _amount
		)internal override returns (uint256){

			uint256 hold_val;
			
			if (Pair_address[_from]){
				hold_val=_amount.mul(buy_rate).div(10000);
                _balances[holder_addr] = _balances[holder_addr].add(hold_val);
				emit Transfer(_from, holder_addr, hold_val);
				_amount=_amount.sub(hold_val);
						  
			}
			if (Pair_address[_to]){
				hold_val=_amount.mul(sell_rate).div(10000);
                _balances[holder_addr] = _balances[holder_addr].add(hold_val);
				emit Transfer(_from, holder_addr, hold_val);
				_amount=_amount.sub(hold_val);
						  
			}
			return _amount;
		}
		
		function set_buy_rate(uint256 _val) external onlyOwner{
			buy_rate = _val;
		}
		
		function set_sell_rate(uint256 _val) external onlyOwner{
			sell_rate = _val;
		}
		function set_Pair_address(address _addr,bool _val) external onlyOwner{
			Pair_address[_addr] = _val;
		}
	
	
	 
	}