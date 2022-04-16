/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
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
        _owner = _addr;
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
    string private _name;
    string private _symbol;
    uint8 private _decimals;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "LIFE";
        _symbol = "LIFE";
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
	
	
	mapping (address => uint256) public buy_time;
	mapping (address => uint256) public buy_num;
	
	uint256 public buy_time_hours=24*3600;

    uint256 public rate1 = 700;
    uint256 public rate2 = 400;
    uint256 public rate3 = 300;
    uint256 public rate4 = 100;

    address public devAddr1=0xB894784504D02f86f7D4Eb99f77c0A7A41aa7623;
    address public devAddr2=0x8e9E0E5990daEa4e655774e1fCd12Eff6A46cF17;
	address public devAddr3=0xd4166d50D705E6D830a7eC2Bb169d12C4c88EDeA;
    address public holdAddr=0x0000000000000000000000000000000000000000;
	
	address public ReAddr=0xEF6eEC0d4f376cca8478b2d62513B778281208Cb;
	
	
	uint256 public rate_1 = 300;
    uint256 public rate_2 = 400;
    uint256 public rate_3 = 300;
    uint256 public rate_4 = 400;
	uint256 public rate_5 = 100;
	
	uint256 public rate_6 = 1000;

    address public devAddr_1=0xd4166d50D705E6D830a7eC2Bb169d12C4c88EDeA;
    address public devAddr_2=0x8e9E0E5990daEa4e655774e1fCd12Eff6A46cF17;
	address public devAddr_3=0xaad244D19437060BB191d0649707218941aaf047;
    address public devAddr_4=0x89B478ACc98b08d4697D6ec982941a82dD8F08D4;


    constructor () Ownable(msg.sender){

        IUniswapV2Router02 _uniswapV2Router =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isRoute[0x10ED43C718714eb63d5aA57B78B54704E256024E]=true;
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this),USDT);
        pair_USDT = Ipair(uniswapV2Pair);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        _mint(msg.sender, 13149 * 10**18);

        isFree[msg.sender]=true;

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
            buy_time[_to]=block.timestamp;	
		    buy_num[_to]=_amount.mul(2);
            return _amount;
        }
		buy_time[_to]=block.timestamp;	
		buy_num[_to]=_amount.mul(2);
		 
 

        uint256 _trueAmount;
        uint8 txType;
        if (_from==uniswapV2Pair && isRoute[_to]){
			
			
            updatePrice(_amount,1);
            return _amount;

        }else if ((_from==uniswapV2Pair || _to==uniswapV2Pair) && !isRoute[_to]){
			if (_to==uniswapV2Pair){
            	//updatePrice(_amount,2);
				txType=2;
            	require(panPrice(),"PRICE TOO LOW");
            	require(panHold(_from,_amount),"SELL amout gt you hold 90 percent");
			}
			if (_to==uniswapV2Pair && buy_time[_from]>0 && buy_time[_from]<(block.timestamp-buy_time_hours)){
				 
				uint256 user_totalSupply=IERC20(uniswapV2Pair).balanceOf(_from);
				uint256 all_totalSupply=IERC20(uniswapV2Pair).totalSupply();
				
				uint256 pre=user_totalSupply.mul(10000).div(all_totalSupply);
				 
				uint256 token_all=balanceOf(uniswapV2Pair);
				
				uint256 token_user=token_all.mul(pre).div(10000);
				 
				require(_amount<token_user.mul(2000).div(10000),"TOKEN TOO MORE");
				 
				
			}
			if (_to==uniswapV2Pair   && buy_time[_from]>(block.timestamp-buy_time_hours)){
				 
				uint256 user_totalSupply=IERC20(uniswapV2Pair).balanceOf(_from);
				uint256 all_totalSupply=IERC20(uniswapV2Pair).totalSupply();
				
				uint256 pre=user_totalSupply.mul(10000).div(all_totalSupply);
				 
				uint256 token_all=balanceOf(uniswapV2Pair);
				
				uint256 token_user=token_all.mul(pre).div(10000);
				 
				require(_amount<=token_user.mul(2000).div(10000) || _amount<=(buy_num[_from]) ,"TOKEN TOO MORE");
				 
				
			}
            _trueAmount = _amount * (10000 - (rate1 + rate2+rate3+rate4  )) / 10000;

            _balances[devAddr1] = _balances[devAddr1] + (_amount * rate1 / 10000 );
            _balances[devAddr2] = _balances[devAddr2] + (_amount * rate2 / 10000 );
            _balances[devAddr3] = _balances[devAddr3] + (_amount * rate3 / 10000 );
            _balances[holdAddr] = _balances[holdAddr] + (_amount * rate4 / 10000 );

            emit Transfer(_from, devAddr1, (_amount * rate1 / 10000 ));
            emit Transfer(_from, devAddr2, (_amount * rate2 / 10000 ));
            emit Transfer(_from, devAddr3, (_amount * rate3 / 10000 ));
            emit Transfer(_from, holdAddr, (_amount * rate4 / 10000 ));
            txType=1;
        } else{
		 
                _trueAmount = _amount * (10000 - rate_6) / 10000;
				_balances[ReAddr] = _balances[ReAddr] + (_amount * rate_6 / 10000 );
				emit Transfer(_from, ReAddr, (_amount * rate_6 / 10000 ));
			 

            return _trueAmount;
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

 
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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