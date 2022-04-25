/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IBEP20 {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns(uint256);

	/**
	 * @dev Returns the token decimals.
	 */
	function decimals() external view returns(uint8);

	/**
	 * @dev Returns the token symbol.
	 */
	function symbol() external view returns(string memory);

	/**
	 * @dev Returns the token name.
	 */
	function name() external view returns(string memory);

	/**
	 * @dev Returns the bep token owner.
	 */
	function getOwner() external view returns(address);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns(uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `recipient`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address recipient, uint256 amount)
	external
	returns(bool);

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address _owner, address spender)
	external
	view
	returns(uint256);

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * IMPORTANT: Beware that changing an allowance with this method brings the risk
	 * that someone may use both the old and the new allowance by unfortunate
	 * transaction ordering. One possible solution to mitigate this race
	 * condition is to first reduce the spender's allowance to 0 and set the
	 * desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 *
	 * Emits an {Approval} event.
	 */
	function approve(address spender, uint256 amount) external returns(bool);



	function burn(uint256 amount) external returns(bool);
	/**
	 * @dev Moves `amount` tokens from `sender` to `recipient` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns(bool);

	/**
	 * @dev Emitted when `value` tokens are moved from one account (`from`) to
	 * another (`to`).
	 *
	 * Note that `value` may be zero.
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Emitted when the allowance of a `spender` for an `owner` is set by
	 * a call to {approve}. `value` is the new allowance.
	 */
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {

	function _msgSender() internal view returns(address) {
		return msg.sender;
	}

	function _msgData() internal view returns(bytes memory) {
		this
		; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}

}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns(uint256) {
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
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 * - Subtraction cannot overflow.
	 */
	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
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
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
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
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns(uint256) {
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
	 * - The divisor cannot be zero.
	 */
	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
		// Solidity only automatically asserts when dividing by 0
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
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
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
	 * - The divisor cannot be zero.
	 */
	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}


interface IRouter {
	function factory() external pure returns(address);

	function WETH() external pure returns(address);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
	external
	view
	returns(uint256[] memory amounts);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns(uint256 amountA, uint256 amountB, uint256 liquidity);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
}

interface IFactory {
	function createPair(address tokenA, address tokenB)
	external
	returns(address PancakePair);
}

interface IPair {
	function getReserves()
	external
	view
	returns(
		uint112 reserve0,
		uint112 reserve1,
		uint32 blockTimestampLast
	);

	function token0() external view returns(address);

	function token1() external view returns(address);
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor() {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view returns(address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 */
	function _transferOwnership(address newOwner) internal {
		require(
			newOwner != address(0),
			"Ownable: new owner is the zero address"
		);
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract PancakeTool {
	address public PancakePair;
	IRouter internal PancakeV2Router;
	
	function initIRouter(address router,address pair) internal {
		PancakeV2Router = IRouter(router);
		PancakePair = IFactory(PancakeV2Router.factory()).createPair(
			address(this),
			pair
		);
	}

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountA,
		uint256 amountB
	) internal {
		PancakeV2Router.addLiquidity(
			tokenA,
			tokenB,
			amountA,
			amountB,
			0,
			0,
			address(0x0),
			block.timestamp
		);
	}

	function swapTokensForTokens(uint256 amountA,address tokenB , address to) internal {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = tokenB;
		PancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amountA,
			0,
			path,
			to,
			block.timestamp
		);
	}

	function getPoolInfo()
	public
	view
	returns(uint112 WETHAmount, uint112 TOKENAmount) {
		(uint112 _reserve0, uint112 _reserve1, ) = IPair(PancakePair)
			.getReserves();
		WETHAmount = _reserve1;
		TOKENAmount = _reserve0;
		if (IPair(PancakePair).token0() == PancakeV2Router.WETH()) {
			WETHAmount = _reserve0;
			TOKENAmount = _reserve1;
		}
	}

	function getLPTotal(address user) internal view returns(uint256) {
		return IBEP20(PancakePair).balanceOf(user);
	}

	function getTotalSupply() internal view returns(uint256) {
		return IBEP20(PancakePair).totalSupply();
	}
}

contract TokenDistributor {
	constructor(address token) {
		IBEP20(token).approve(msg.sender, uint256(~uint256(0)));
	}
}

contract NobodyLaToken is Context, IBEP20, Ownable, PancakeTool {
	using SafeMath
	for uint256;

	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	uint8 public _decimals;
	string public _symbol;
	string public _name;

	uint256 private shareSize = 0;

    address private USDT = 0x55d398326f99059fF775485246999027B3197955;
	address private pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	address public walletM = 0x16799554DE451C47625D993B4aB2820e86E71994;
	address private unLockPool = 0xeC013ae8336926679C534695B29AfE99e8101000;

	address private initPoolHolder;

	uint256 public _fund;
	uint256 public _backflow;

	address public lastSender;
	address public lastRecipient;

	uint8 private _cPercent = 40;
	uint8 private _iPercent = 30;
	uint8 private _mPercent = 10;
	uint8 private _Percent = 80;
	uint8 private _Fee = _Percent - _iPercent;

	uint256 private divBase = 1000;
	uint256 private tokenSize = 1000000000000000000;
	
	uint256 public constant  TIME_LIMIT = 86400;
	uint256 private rewardMin = 100000000000000000;
	uint256 private swapMin = 400000 * tokenSize;

	uint256 private startIndex = 0;
	uint256 private interval = 10;


	uint256 public _lpHolderTotal;
	mapping(address => bool) public isLpHolders;
	mapping(uint256 => address) private _lpHolders;

	bool public unLock;
	uint256 public unLockTime;

	bool swapLocking;

	modifier lockTheSwap() {
		swapLocking = true;
		_;
		swapLocking = false;
	}


	TokenDistributor private _distSwap; 
	TokenDistributor private _distBack;

	constructor() {
		_name = "NobodyLa Token";
		_symbol = "NobodyLa";
		_decimals = 18;
		_totalSupply = 1000000000 * tokenSize;
		_balances[msg.sender] = _totalSupply;

		_distSwap = new TokenDistributor(USDT);
		_distBack = new TokenDistributor(USDT);

		initIRouter(pancakeRouter,USDT);

		initPoolHolder = msg.sender;
		
		_approve(address(this), pancakeRouter, ~uint256(0));
		_approve(owner(), pancakeRouter, ~uint256(0));

		IBEP20(USDT).approve(pancakeRouter, ~uint256(0));

		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	
	/**
	 * @dev Returns the bep token owner.
	 */
	function getOwner() override external view returns(address) {
		return owner();
	}

	/**
	 * @dev Returns the token decimals.
	 */
	function decimals() override external view returns(uint8) {
		return _decimals;
	}

	/**
	 * @dev Returns the token symbol.
	 */
	function symbol() override external view returns(string memory) {
		return _symbol;
	}

	/**
	 * @dev Returns the token name.
	 */
	function name() override external view returns(string memory) {
		return _name;
	}

	/**
	 * @dev See {BEP20-totalSupply}.
	 */
	function totalSupply() override external view returns(uint256) {
		return _totalSupply;
	}

	/**
	 * @dev See {BEP20-balanceOf}.
	 */
	function balanceOf(address account) override external view returns(uint256) {
		return _balances[account];
	}

	/**
	 * @dev See {BEP20-transfer}.
	 *
	 * Requirements:
	 *
	 * - `recipient` cannot be the zero address.
	 * - the caller must have a balance of at least `amount`.
	 */


	function transfer(address recipient, uint256 amount) override
	external
	returns(bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	/**
	 * @dev See {BEP20-allowance}.
	 */
	function allowance(address owner, address spender)
	override external
	view
	returns(uint256) {
		return _allowances[owner][spender];
	}

	/**
	 * @dev See {BEP20-approve}.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function approve(address spender, uint256 amount) override external returns(bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	/**
	 * @dev See {BEP20-transferFrom}.
	 *
	 * Emits an {Approval} event indicating the updated allowance. This is not
	 * required by the EIP. See the note at the beginning of {BEP20};
	 *
	 * Requirements:
	 * - `sender` and `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 * - the caller must have allowance for `sender`'s tokens of at least
	 * `amount`.
	 */
	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) override external returns(bool) {
		_transfer(sender, recipient, amount);
		_approve(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(
				amount,
				"BEP20: transfer amount exceeds allowance"
			)
		);
		return true;
	}

	/**
	 * @dev Atomically increases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to {approve} that can be used as a mitigation for
	 * problems described in {BEP20-approve}.
	 *
	 * Emits an {Approval} event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function increaseAllowance(address spender, uint256 addedValue)
	public
	returns(bool) {
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].add(addedValue)
		);
		return true;
	}

	/**
	 * @dev Atomically decreases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to {approve} that can be used as a mitigation for
	 * problems described in {BEP20-approve}.
	 *
	 * Emits an {Approval} event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 * - `spender` must have allowance for the caller of at least
	 * `subtractedValue`.
	 */
	function decreaseAllowance(address spender, uint256 subtractedValue)
	public
	returns(bool) {
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(
				subtractedValue,
				"BEP20: decreased allowance below zero"
			)
		);
		return true;
	}

	/**
	 * @dev Burn `amount` tokens and decreasing the total supply.
	 */
	function burn(uint256 amount) public returns(bool) {
		_burn(_msgSender(), amount);
		return true;
	}



	function getTokens() public view returns(address[2] memory adds) {
        adds[0] = address(_distSwap);
        adds[1] = address(_distBack);
	}


	/**
	 * @dev Moves tokens `amount` from `sender` to `recipient`.
	 *
	 * This is internal function is equivalent to {transfer}, and can be used to
	 * e.g. implement automatic token fees, slashing mechanisms, etc.
	 *
	 * Emits a {Transfer} event.
	 *
	 * Requirements:
	 *
	 * - `sender` cannot be the zero address.
	 * - `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 */
	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal {	
		require(sender != address(0), "BEP20: transfer from the zero address");
		require(recipient != address(0), "BEP20: transfer to the zero address");
		if (_balances[address(this)] > 0 && sender != PancakePair && !swapLocking) { swapAndbackflow(); }

		if (swapLocking) {
			_balances[sender] = _balances[sender].sub(
				amount,
				"BEP20: transfer amount exceeds balance"
			);
			_balances[recipient] = _balances[recipient].add(amount);
			emit Transfer(sender, recipient, amount);
		} else {
			_beforeTransfer(sender,recipient,amount);

			_balances[sender] = _balances[sender].sub(
				amount,
				"BEP20: transfer amount exceeds balance"
			);

			if (sender != owner() && sender != address(this) && recipient != address(this) && recipient != owner()) {
				uint256 totalFee = (amount / divBase) * _Percent;
				_balances[address(this)] = _balances[address(this)].add(totalFee);
				emit Transfer(sender, address(this), totalFee);
				amount = amount.sub(totalFee);
			}

			_balances[recipient] = _balances[recipient].add(amount);
			emit Transfer(sender, recipient, amount);

			_afterTransfer(sender, recipient);
		}

	}

	function _beforeTransfer(address sender,address recipient,uint256 amount) internal {
		if (lastRecipient != address(0)) {
			if (!isLpHolders[lastRecipient] && super.getLPTotal(lastRecipient) > 0) {
				isLpHolders[lastRecipient] = true;
				_lpHolders[_lpHolderTotal] = lastRecipient;
				_lpHolderTotal = _lpHolderTotal.add(1);
			}
			delete lastRecipient;
		}

		if (lastSender != address(0)) {
			if (!isLpHolders[lastSender] && super.getLPTotal(lastSender) > 0) {
				isLpHolders[lastSender] = true;
				_lpHolders[_lpHolderTotal] = lastSender;
				_lpHolderTotal = _lpHolderTotal.add(1);
			}
			delete lastSender;
		}

		if (sender == initPoolHolder || sender == address(this) || recipient == initPoolHolder) {
            return;
        }

		if(recipient == unLockPool && unLockTime == 0){
			unLock = true;
			unLockTime = block.timestamp;
		}	

		require(unLock,"Can't buy");
		if(block.timestamp - unLockTime <= TIME_LIMIT){
			if (recipient == tx.origin && recipient != initPoolHolder) {
				require(amount <= 2000000 * tokenSize && _balances[recipient] <= 10000000 * tokenSize);
        	}

			if (sender == tx.origin && sender != initPoolHolder) {
				require(amount <= 2000000 * tokenSize);
				require(amount <= (_balances[sender] / divBase) * 999);
			}
		}else{
			if (sender == tx.origin && sender != initPoolHolder) {
				require(amount <= (_balances[sender] / divBase) * 999);
			}
		}
	}


	function _afterTransfer(address sender, address recipient) internal {
		if (sender == tx.origin &&
			!isLpHolders[sender] &&
			sender != initPoolHolder &&
			sender != walletM
		) {
			lastSender = sender;
		}

		if (recipient == tx.origin &&
			!isLpHolders[recipient] &&
			recipient != initPoolHolder &&
			recipient != walletM
		) {
			lastRecipient = recipient;
		}
		//Increase impact reward
		rewardLiquidity();
	}

	function swapAndbackflow() private lockTheSwap {
        uint256 balance = _balances[address(this)];
		if (_balances[PancakePair] / 100 < balance) balance = _balances[PancakePair] / 100;
		if(balance >= swapMin){
            swapTokensForUSDT(balance * _Fee / _Percent);
            backflow(balance * _iPercent / _Percent);
       }
	}

	function swapTokensForUSDT(uint256 amount) private{
		uint256 oldBalance = IBEP20(USDT).balanceOf(address(this));
		swapTokensForTokens(amount, USDT, address(_distSwap));

		IBEP20(USDT).transferFrom(
			address(_distSwap),
			address(this),
			IBEP20(USDT).balanceOf(address(_distSwap))
		);

		uint256 riseBalance = IBEP20(USDT).balanceOf(address(this)) - oldBalance;
		_fund = _fund.add(calculateReward(_Fee, riseBalance, _cPercent));

		TransferUSDT(walletM, calculateReward(_Fee, riseBalance, _mPercent));
	}

	function backflow(uint256 amount) private{
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);
        uint256 oldBalance = IBEP20(USDT).balanceOf(address(this));

        swapTokensForTokens(half, USDT, address(_distBack));

        IBEP20(USDT).transferFrom(
            address(_distBack),
            address(this),
            IBEP20(USDT).balanceOf(address(_distBack))
        );
        
        uint256 riseBalance = IBEP20(USDT).balanceOf(address(this)) - oldBalance;
        addLiquidity(address(this), USDT, otherHalf, riseBalance);
	}

	function rewardLiquidity() private  {
		// exclude initial pool holder and locked part.
		uint256 pool = super.getTotalSupply() - (super.getLPTotal(initPoolHolder) + super.getLPTotal(address(0)));
		uint256 reward = _fund;
		if (reward >= rewardMin) { 
			for (uint256 index = startIndex; index < _lpHolderTotal; index++) {
				address account = _lpHolders[index];
				uint256 LPHolders = super.getLPTotal(account);
				if (LPHolders > 0) {
					uint256 r = calculateReward(pool, reward, LPHolders);
					_fund = _fund.sub(r);
					TransferUSDT(account, r);
				}

				if (index == _lpHolderTotal - 1) {
					startIndex = 0;
					return;
				}

				if (index - startIndex == interval) {
					startIndex += interval;
					return;
				}
			}
		}
	}


    function changeSwapMin(uint256 min) public returns(bool){
		require(msg.sender == unLockPool);
        swapMin = min * tokenSize;
        return true;
    }


	function calculateReward(
		uint256 total,
		uint256 reward,
		uint256 holders
	) internal view returns(uint256) {
		return (reward * ((holders * tokenSize) / total)) / tokenSize;
	}


	/**
	 * @dev Destroys `amount` tokens from `account`, reducing the
	 * total supply.
	 *
	 * Emits a {Transfer} event with `to` set to the zero address.
	 *
	 * Requirements
	 *
	 * - `account` cannot be the zero address.
	 * - `account` must have at least `amount` tokens.
	 */
	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: burn from the zero address");

		_balances[account] = _balances[account].sub(
			amount,
			"BEP20: burn amount exceeds balance"
		);
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
	 *
	 * This is internal function is equivalent to `approve`, and can be used to
	 * e.g. set automatic allowances for certain subsystems, etc.
	 *
	 * Emits an {Approval} event.
	 *
	 * Requirements:
	 *
	 * - `owner` cannot be the zero address.
	 * - `spender` cannot be the zero address.
	 */
	function _approve(
		address owner,
		address spender,
		uint256 amount
	) internal {
		require(owner != address(0), "BEP20: approve from the zero address");
		require(spender != address(0), "BEP20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	/**
	 * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
	 * from the caller's allowance.
	 *
	 * See {_burn} and {_approve}.
	 */
	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(
			account,
			_msgSender(),
			_allowances[account][_msgSender()].sub(
				amount,
				"BEP20: burn amount exceeds allowance"
			)
		);
	}

	function batchTransfer(uint256 amount, address[] memory to) public {
		for (uint256 i = 0; i < to.length; i++) {
			_transfer(_msgSender(), to[i], amount);
		}
	}




	function TransferUSDT(address account, uint256 amount) private {
		IBEP20(USDT).transfer(account, amount);
	}

}