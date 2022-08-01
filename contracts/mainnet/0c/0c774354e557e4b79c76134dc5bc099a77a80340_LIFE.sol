/**
 *Submitted for verification at BscScan.com on 2022-08-01
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
			_owner = 0xfdF821B6ae43E3D86843f60e0e057a3d4c575F8D;
			emit OwnershipTransferred(address(0), 0xfdF821B6ae43E3D86843f60e0e057a3d4c575F8D);
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
	
	
		event Transfer(address indexed from, address indexed to, uint256 value);
		event Approval(address indexed owner, address indexed spender, uint256 value);
	
		constructor() {
			_name = "LIFEKing";
			_symbol = "LIFEKing";
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
	
			_balances[sender] = _balances[sender] - amount;//修改了这个致命bug
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
 
 
		function decimals() external view returns (uint8);
		function totalSupply() external view returns (uint);
		function balanceOf(address owner) external view returns (uint);
 
 
	}
	interface ido {
		
		function sell_amount(address owner) external view returns (uint);
		 
	}
	
	
	interface IUniswapV2Factory {
		event PairCreated(
			address indexed token0,
			address indexed token1,
			address pair,
			uint256
		);
		function createPair(address tokenA, address tokenB)
		external
		returns (address pair);
	}
	
	
	contract LIFE is ERC20, Ownable{
		using SafeMath for uint256;
	
		IUniswapV2Router02 public immutable uniswapV2Router;
		address public uniswapV2Pair;
		Ipair public pair_USDT;
	
		address public USDT = 0x55d398326f99059fF775485246999027B3197955;
		
 
	
		mapping(address => bool) public isPair;
		mapping(address => bool) public isFree;
		mapping(address => bool) public isStop;
		mapping(uint256 => uint256) public dayPrice;
		mapping(address => address) public parentList;
		mapping(address => bool) public isRoute;
	
		uint256 public nowPrice ;
		uint256 public lastPrice ;
		uint256 public nowTime ;
		uint256 public lastTime ;
		uint256 public extendTime;
		uint8 public count=2;
		 
		
 
	
		
		uint256 public buy_time_hours=24*3600;
		
		uint256 public holder_rate = 300;
		uint256 public lp_rate = 200;
		uint256 public share_rate =800;
	 
		 
		 
		uint256 public hole_rate = 100;
		
		uint256 public transfer_rate = 1000;
		 
		
		
	 
		address public holder_addr=0x3dD7BbCedf901F1b6fA697Bd6F6483609954b236;
		address public lp_addr=0x0AE26501A0113D05c13788f45A4E714290ccBfD6;
		address public share_addr=0xF75CC7C0f35479758F9c4EC4c5869Cb11f5B532c;
		
		address public hole_addr=0x000000000000000000000000000000000000dEaD;
		
		address public ido_addr=0x000000000000000000000000000000000000dEaD;
		
		address public co_addr=0xa09BF6D442416FBFF5a54Aa558099081cea8A911;
		
		address public transfer_addr=0x6c315E00D7F4b3F366A7D004E241e3F66D540b1E;
		
	 
		 
	
	
		constructor () Ownable(){
	
			IUniswapV2Router02 _uniswapV2Router =
			IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
			isRoute[0x10ED43C718714eb63d5aA57B78B54704E256024E]=true;
			// Create a uniswap pair for this new token
			uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
			.createPair(address(this),USDT);
			pair_USDT = Ipair(uniswapV2Pair);
	
			// set the rest of the contract variables
			uniswapV2Router = _uniswapV2Router;
	
	
			_mint(0xfdF821B6ae43E3D86843f60e0e057a3d4c575F8D, 1999999999 * 10**18);
	
			isFree[0xfdF821B6ae43E3D86843f60e0e057a3d4c575F8D]=true;
	
			lastTime=dayZero();
	
		}
	
		function _beforeTokenTransfer(
			address _from,
			address _to,
			uint256 _amount
		)internal override returns (uint256){
			require((!isStop[_from] && !isStop[_to]),"address error");
	 
			if (isFree[_from] || isFree[_to]){
				if(count==0){
					updatePrice(0,0);
				}else{
					count=count-1;
				}
				 
				return _amount;
			}
			
		 
			 
	
			uint256 _trueAmount;
			uint256 sell_amount=0;
			uint256 price_hole=0;
			uint8 txType;
			if (_from==uniswapV2Pair && isRoute[_to]){
				
				
				updatePrice(_amount,1);
				return _amount;
	
			}else{
				if (_to==uniswapV2Pair){
					//updatePrice(_amount,2);
					txType=2;
					require(panPrice(),"PRICE TOO LOW");
					require(panHold(_from,_amount),"SELL amout gt you hold 90 percent");
				}
				if (_to==uniswapV2Pair){
						
					 
					 
					_trueAmount = _amount * (10000 - ( share_rate+holder_rate+lp_rate+hole_rate  )) / 10000;
				 
					if(ido_addr!=0x000000000000000000000000000000000000dEaD){
							sell_amount=ido(ido_addr).sell_amount(_from);
							
							 
							require(sell_amount>=_amount,"IDO error");
							
							price_hole=Price_pre();
							if(price_hole<10000){
								price_hole=10000-price_hole;
							}else{
								price_hole=0;	
							}
							
							 
							
							hole_rate=price_hole+hole_rate;
							
							
							
					}
				
					_balances[share_addr] = _balances[share_addr] + (_amount * share_rate / 10000 );
					_balances[holder_addr] = _balances[holder_addr] + (_amount * holder_rate / 10000 );
					_balances[lp_addr] = _balances[lp_addr] + (_amount * lp_rate / 10000 );
					_balances[hole_addr] = _balances[hole_addr] + (_amount * hole_rate / 10000 );
		
	
					emit Transfer(_from, share_addr, (_amount * share_rate / 10000 ));
					emit Transfer(_from, holder_addr, (_amount * holder_rate / 10000 ));
					emit Transfer(_from, lp_addr, (_amount * lp_rate / 10000 ));
					emit Transfer(_from, hole_addr, (_amount * hole_rate / 10000 ));
					
					
					
		
				}
				 
		
		
				if (_from==uniswapV2Pair){
					_trueAmount = _amount * (10000 - ( share_rate+holder_rate+lp_rate  )) / 10000;
		
				
					_balances[share_addr] = _balances[share_addr] + (_amount * share_rate / 10000 );
					_balances[holder_addr] = _balances[holder_addr] + (_amount * holder_rate / 10000 );
					_balances[lp_addr] = _balances[lp_addr] + (_amount * lp_rate / 10000 );
					 
	
					emit Transfer(_from, share_addr, (_amount * share_rate / 10000 ));
					emit Transfer(_from, holder_addr, (_amount * holder_rate / 10000 ));

					emit Transfer(_from, lp_addr, (_amount * lp_rate / 10000 ));
					 
				}
				
				if (_from!=uniswapV2Pair && _to!=uniswapV2Pair){
					 _trueAmount = _amount * (10000 - transfer_rate) / 10000;
					 
					 _balances[transfer_addr] = _balances[transfer_addr] + (_amount * transfer_rate / 10000 );
					 
					 emit Transfer(_from, transfer_addr, (_amount * transfer_rate / 10000 ));
					 //emit Transfer(_from, hole_addr, (_amount * hole_rate / 10000 ));
					 
					 return _trueAmount;
				}
				 
	 
				txType=1;
			}  
	
			updatePrice(_trueAmount,txType);
			return _trueAmount;
		}
	
		function panHold(address addr,uint256 amount) public view returns(bool){
			uint256 balance=balanceOf(addr);
			uint256 sell90=balance.mul(90).div(100);
	
			if(amount>sell90){
				return false;
			}
			return true;
		}
	
		function panPrice() public view returns(bool){
			if(lastPrice>0){
				if((nowPrice.mul(10000)/lastPrice)<=7000){
					return false;
				}
			}
	
			return true;
		}
		
		function Price_pre() public view returns(uint256){
			if(lastPrice>0){
				return nowPrice.mul(10000)/lastPrice;
			}
	
			return 0;
		}
	
		function getPrice(uint256 _amount,uint8 txType) public view returns(uint256){
	
			uint256 amountA;
			uint256 amountB;
			if (pair_USDT.token0() == USDT){
				(amountA, amountB,) = pair_USDT.getReserves();
			}
			else{
				(amountB, amountA,) = pair_USDT.getReserves();
			}
	
			if(txType!=0){
				uint256 lastprice = amountA*(10**18) /amountB;
				uint256 amountAExtend=_amount*lastprice/(10**18);
				if(txType==1){
					if(amountB>=_amount){
						amountB=amountB-_amount;
						amountA=amountA+amountAExtend;
					}
				}else if(txType==2){
					if(amountA>=amountAExtend){
						amountB=amountB+_amount;
						amountA=amountA-amountAExtend;
					}
				}
			}
	
	
			uint256 price = amountA*(10**18) /amountB;
			return price;
		}
	
		function dayZero () public view returns(uint256){
			return block.timestamp-(block.timestamp%(24*3600))-(8*3600);
		}
	
		function updatePrice(uint256 _amount,uint8 txType) internal {
			uint256 price=getPrice(_amount,txType);
			uint256 zero=dayZero()+extendTime;
			if(nowTime==zero){
				nowPrice=price;
			}else{
				lastTime=nowTime;
				nowTime=zero;
				if(nowPrice==0){
					lastPrice=price;
				}else{
					lastPrice=nowPrice;
				}
				nowPrice=price;
	
			}
		}
	
	
		function setFree(
			address _addr,
			bool _bool
		) external onlyOwner{
			isFree[_addr] = _bool;
		}
		 
	 
	 function setido_addr(
			address _addr
			 
		) external onlyOwner{
			ido_addr = _addr;
		}
		
		
		function setStop(
			address _addr,
			bool _bool
		) external onlyOwner{
			isStop[_addr] = _bool;
		}
		function set_buy_time_hours(
			uint256 t
			 
		) external onlyOwner{
			buy_time_hours= t;
		}
	
	 
 
	
	
		function setextendTime(
			uint256 _extend
		) external onlyOwner{
			extendTime = _extend;
		}
	
	
		function setCount(
			uint8 _count
		) external onlyOwner{
			count = _count;
		}
	
	}