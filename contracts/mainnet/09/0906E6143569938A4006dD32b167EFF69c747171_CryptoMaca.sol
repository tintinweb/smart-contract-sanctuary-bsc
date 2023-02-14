/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
        returns (uint256);

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
    function approve(address spender, uint256 amount) external returns (bool);

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
    ) external returns (bool);

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
contract Ownable is Context {
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
    function owner() public view returns (address) {
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

interface IRouter {
	function factory() external pure returns(address);

	function WETH() external pure returns(address);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
	external
	view
	returns(uint256[] memory amounts);

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


contract PancakeTool {
	address public PancakePair;
    address public WbnbAddress;

	IRouter internal PancakeV2Router;
	
	function _initIRouter(address router) internal {
		PancakeV2Router = IRouter(router);
		PancakePair = IFactory(PancakeV2Router.factory()).createPair(
			address(this),
			PancakeV2Router.WETH()
		);
        WbnbAddress = PancakeV2Router.WETH();
	}

	function _swapTokensForTokens(uint256 amountA,address tokenB , address to) internal {
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = PancakeV2Router.WETH();
        path[2] = tokenB;
		PancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amountA,
			0,
			path,
			to,
			block.timestamp
		);
	}


    function getCost(uint256 amount,address tokenB) internal view returns(uint256) {
        address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = PancakeV2Router.WETH();
        path[2] = tokenB;
        uint256 value;
        value = PancakeV2Router.getAmountsOut(amount,path)[2];
		return value;
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


contract CryptoMaca is Context, IBEP20, Ownable, PancakeTool {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private excluded;


    
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address private _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private _pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _market = 0x98e395403EAD48548D894fA45390ed70E1E81111;
    address private _lockLp;

    address private _lastAddr;
    uint256 private _lastTime;

    uint256 public _marketFee;
    uint256 public _stockFee;
    uint256 public _pondFee;
    
    uint256 public _startIndex = 0;
    uint256 public _interval = 3;
    uint256 public _lpHolderTotal;
    
    mapping(address => bool) public isLpHolders;
    mapping(uint256 => address) public _lpHolders;

    bool private _freeTax = true;

	TokenDistributor private _distStock;
    TokenDistributor private _distPond;

    constructor() {
		_distStock = new TokenDistributor(_usdt);
        _distPond = new TokenDistributor(_usdt);
        _initIRouter(_pancakeRouter);
        _approve(address(this), _pancakeRouter, ~uint256(0));
        _approve(owner(), _pancakeRouter, ~uint256(0));

        _name = "CryptoMaca Token"; 
        _symbol = "MACA";
        _decimals = 18;
        _totalSupply = 10000000 * 10**_decimals;
        _balances[msg.sender] = _totalSupply;
        excluded[msg.sender] = true;
        excluded[address(this)] = true;
        excluded[address(_distStock)] = true;
        excluded[address(_distPond)] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() public override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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

    //The token pancake  6%
    //Increased liquidity and transaction number is 6
    function transfer(address recipient, uint256 amount)
        public override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
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
    ) public override returns (bool) {
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
        returns (bool)
    {
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
        returns (bool)
    {
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
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
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
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] = _balances[from].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        if(!_freeTax){
            amount = _fee(from, to, amount);
        }
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }


    function _fee(address from, address to, uint256 amount) private returns (uint256 finalAmount) {
        finalAmount = amount;
        if (to == address(PancakePair) && !excluded[from]) {
            finalAmount = _countFee(from,amount,false);
            uint256 value = _cost(amount);
            if(value >= 100 * 10**_decimals){
                if(_lastAddr != from){
                    _lastAddr = from;
                    _lastTime = block.timestamp;
                }
            }
            _rewardLP();    
        }
        
        if (from == address(PancakePair) && !excluded[to]) {
            finalAmount = _countFee(to,amount,true);
            uint256 value = _cost(amount);
            if(value >= 10 * 10**_decimals){
                if(_lastAddr != to){
                    _lastAddr = to;
                    _lastTime = block.timestamp;
                }
            }
            if(!isLpHolders[to] && super.getLPTotal(to) > 0){
                isLpHolders[to] = true;
                _lpHolders[_lpHolderTotal] = to;
                _lpHolderTotal = _lpHolderTotal.add(1);    
            }
            _rewardLP();
        }
    }

    function _cost(uint256 amount) private view returns(uint256){
        return super.getCost(amount,_usdt);
    }

    function _countFee(address from,uint256 amount,bool isBuy) private returns (uint256 finalAmount) {
        uint256 Fee = amount.div(100).mul(6);
        finalAmount = amount - Fee;
        if(isBuy){
           _marketFee = _marketFee.add(Fee.div(6).mul(3));
           _stockFee = _stockFee.add(Fee.div(6).mul(2));
           _pondFee = _pondFee.add(Fee.div(6).mul(1));
        }else{
           _marketFee = _marketFee.add(Fee.div(6).mul(3));
           _stockFee = _stockFee.add(Fee.div(6).mul(1));
           _pondFee = _pondFee.add(Fee.div(6).mul(2));
        }
        _balances[address(this)] = _balances[address(this)].add(Fee);
        emit Transfer(from, address(this), Fee);
        return finalAmount;
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint256 i = 0; i < to.length; i++) {
            _transfer(_msgSender(), to[i], amount);
        }
    }


    function getAward() public returns(bool){
        if(block.timestamp - _lastTime >= 1800 && _lastAddr != address(0x0)){
            uint256 uBalance = IBEP20(_usdt).balanceOf(address(_distPond));
            if(uBalance >= 1){
                uint256 num = uBalance.div(100).mul(80);
                uint256 fee = num.div(100).mul(10);
                IBEP20(_usdt).transferFrom(address(_distPond),_market,fee);
                IBEP20(_usdt).transferFrom(address(_distPond),_lastAddr,num.sub(fee));
                _lastAddr = address(0x0);
                _lastTime = 0;
            }
        }
        return true;
    }

    function _rewardLP() internal {
        uint256 uBalance = IBEP20(_usdt).balanceOf(address(_distStock));
        if(uBalance >= 100 * 10**_decimals){
            uint256 u = 100 * 10**_decimals;
            uint256 pool = super.getTotalSupply() - (super.getLPTotal(_lockLp)+super.getLPTotal(address(0x0)));
            for (uint256 index = _startIndex; index < _lpHolderTotal; index++) {
                    address account = _lpHolders[index];
                    uint256 LPHolders = super.getLPTotal(account);

                    if(LPHolders > 0){
                        uint256 r = calculateReward(pool, u, LPHolders);
                        IBEP20(_usdt).transferFrom(address(_distStock),account,r);
                    }
                    
                    if(index == _lpHolderTotal - 1){
                        _startIndex = 0;
                        return;
                    }

                    if(index - _startIndex == _interval - 1){
                        _startIndex += _interval;
                        return;
                    }       
            }
        }
        
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) internal view returns (uint256) {
        return (reward * ((holders * (1*10**_decimals)) / total)) / (1*10**_decimals);
    }

    function swapTokensForTokensAll() public returns (bool) {
        super._swapTokensForTokens(_marketFee, _usdt, _market);
        super._swapTokensForTokens(_stockFee, _usdt, address(_distStock));
        super._swapTokensForTokens(_pondFee, _usdt, address(_distPond));
        _marketFee = 0;
        _stockFee = 0;
        _pondFee = 0;
        return true;    
	}

    function lockAddress(address lock) public onlyOwner {
       _lockLp = lock;
    }

    function freeTax(bool free) public onlyOwner {
       _freeTax = free;
    }

    function getLast() public view returns(address,uint256) {
       return (_lastAddr,_lastTime);
    }

    function getTokens() public view returns(address,address) {
       return (address(_distPond),address(_distStock));
    }

}