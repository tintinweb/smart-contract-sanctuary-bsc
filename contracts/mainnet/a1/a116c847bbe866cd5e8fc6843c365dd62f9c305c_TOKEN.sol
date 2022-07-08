/**
 *Submitted for verification at BscScan.com on 2022-07-08
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
    constructor (address _addr) {
        _owner = 0xA8e95CE45b63c8B87Ea9E46263721441E1E94b49;
        emit OwnershipTransferred(address(0), _addr);
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
    uint256  public amount_all;
    string private _name;
    string private _symbol;
    uint8 private _decimals;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "Rubbertree";
        _symbol = "RUBB";
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
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


 

contract TOKEN is ERC20, Ownable{
    using SafeMath for uint256;

   
 

    mapping(address => bool) public isLpAddr;
    mapping(address => bool) public isFree;
    mapping(address => bool) public isStop;
	
	
 
    mapping(address => bool) public isRoute;

  	mapping(address => bool) public is_in_holder_lists;
	address[] public holder_lists;
    mapping(address =>uint256) public holder_lists_index;
	 
	 
	
	mapping (address => uint256) public buy_time;
	mapping (address => uint256) public buy_num;
	
	uint256 public buy_num_max=0;

    mapping (address => uint256) public fee_num;
	
	
 
    mapping(address => uint) public user_amount_lists;

	
	uint256 public startime=0;
	
	uint256 public day=24*3600*3;

	
	 
 
    uint256 public fund_rate = 100;
	uint256 public comm_rate = 100;
    uint256 public gold_rate = 200;
	uint256 public com_rate =200;
	uint256 public fee_rate = 300;
	uint256 public hold_rate = 100;
	
	uint256 count_x=0;
	

    address public fund_addr=0x182F779e357B281Bc373686885AE28d1e3d05859;
	address public comm_addr=0xD7CfCe55B9CbE6Ac1F70c197157fd95bDf89E56e;
    address public gold_addr=0x05bAD79ACD318c7fC05503ecb962f3eeAd87ef3B;
	address public com_addr=0xc77d256656c94ff44566E52ff59aC4582D8086AD;
	
	address public fee_addr=0xAd6C4F8bA2cC8bD3d196bc37C178b1EC374f341A;
    
    uint256 unlocked=1;
 	modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
	
    constructor () Ownable(msg.sender){

        _mint(0xA8e95CE45b63c8B87Ea9E46263721441E1E94b49, 200000000 * 10**18);
        
        isFree[0xA8e95CE45b63c8B87Ea9E46263721441E1E94b49]=true;

        

    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    )internal override  returns (uint256){
        require((!isStop[_from] && !isStop[_to]),"address error");
 	
		
		if(!is_in_holder_lists[_to]){
			 holder_lists_index[_to] = holder_lists.length;
      	 	 holder_lists.push(_to);	
			 is_in_holder_lists[_to]=true;
		}
        if (isFree[_from] || isFree[_to]){
            return _amount;
        }
		
		if (!isLpAddr[_from] && !isLpAddr[_to]){
				
			return _amount;
		}
		if(startime<block.timestamp  && block.timestamp<(startime+day) && isLpAddr[_from]){
			uint256 tmp=buy_num[_to]+_amount;
			
			require((buy_num_max>=tmp),"buy_num_max error");
			
			buy_num[_to]=buy_num[_to]+_amount;
			 
		}
		 
		 

        uint256 _trueAmount;
        _trueAmount = _amount * (10000 - ( fund_rate+comm_rate+gold_rate+com_rate+fee_rate+hold_rate  )) / 10000;
		if(!is_in_holder_lists[fund_addr]){
			 add_holder(fund_addr);
			 add_holder(comm_addr);
			 add_holder(gold_addr);
			 add_holder(com_addr);
			 add_holder(fee_addr);
			 
		}
		
		
				_balances[fund_addr] = _balances[fund_addr] + (_amount * fund_rate / 10000 );
				_balances[comm_addr] = _balances[comm_addr] + (_amount * comm_rate / 10000 );
				_balances[gold_addr] = _balances[gold_addr] + (_amount * gold_rate / 10000 );
				_balances[com_addr] = _balances[com_addr] + (_amount * com_rate / 10000 );
				_balances[fee_addr] = _balances[fee_addr] + (_amount * fee_rate / 10000 );
	

				emit Transfer(_from, fund_addr, (_amount * fund_rate / 10000 ));
				emit Transfer(_from, comm_addr, (_amount * comm_rate / 10000 ));
				emit Transfer(_from, gold_addr, (_amount * gold_rate / 10000 ));
				emit Transfer(_from, com_addr, (_amount * com_rate / 10000 ));
				emit Transfer(_from, fee_addr, (_amount * fee_rate / 10000 ));
		
		_balances[address(this)] = _balances[address(this)] + (_amount * hold_rate / 10000 );
		
		emit Transfer(_from, address(this), (_amount * hold_rate / 10000 ));
		
		
		share_holder((_amount * hold_rate / 10000 ))	;	
        return _trueAmount;
    }
	
	function add_holder(address addr) private  returns (bool){
		if(!is_in_holder_lists[addr]){
			 holder_lists_index[addr] = holder_lists.length;
      	 	 holder_lists.push(addr);	
			 is_in_holder_lists[addr]=true;
		}
		return true;
	}
	
	function get_fee() public   returns (bool){
		
		//share_holder(); 
		uint256 tmp=user_amount_lists[msg.sender];
		user_amount_lists[msg.sender] = 0;
	 	
		
		_balances[msg.sender] = _balances[msg.sender] + tmp;
		emit Transfer(address(this), msg.sender, tmp); 
		 
		return true;
		 
		
         
    }
	
	
	function share_holder(uint256 amount_span) lock private   {
	 
		
		uint256 count= holder_lists.length;
		uint256 i = 0;
		
		uint256 amount=200000000 * 10**18;
		 
		uint256 amount_tmp;
		 
		
		while (i < count) {
            	 
			amount_tmp = amount_span.mul(_balances[holder_lists[i]]).div(amount);
			
			if(amount_tmp>0){
			 
				user_amount_lists[holder_lists[i]]=user_amount_lists[holder_lists[i]].add(amount_tmp);
			
			}
			 
			i++; 
		}
		 
		 
	}
   

    function setFree(
        address _addr,
        bool _bool
    ) external onlyOwner{
        isFree[_addr] = _bool;
    }
	 
	
 
	
	
    function setLpAddr(
        address _addr,
        bool _bool
    ) external onlyOwner{
        isLpAddr[_addr] = _bool;
    }
	
	 

 
 
    function setStop(
        address _addr,
        bool _bool
    ) external onlyOwner{
        isStop[_addr] = _bool;
    }
 
	
	function setstartime(
        uint256 t
         
    ) external onlyOwner{
        startime= t;
    }
	function setbuy_num_max(
        uint256 t
         
    ) external onlyOwner{
        buy_num_max= t;
    }

  
 

  

}