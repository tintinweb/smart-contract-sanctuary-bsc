/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
 */

pragma solidity 0.5.17;

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
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
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
        require(c >= a, "DMH SafeMath: addition overflow");

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
        return sub(a, b, "DMH SafeMath: subtraction overflow");
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
        require(c / a == b, "DMH SafeMath: multiplication overflow");

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
        return div(a, b, "DMH SafeMath: division by zero");
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
        return mod(a, b, "DMH SafeMath: modulo by zero");
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

library stack {
    struct Stack {
        uint256[] data;
        uint256 capacity;
        uint256 top;
    }

    function push(Stack storage self, uint256 val) internal returns (bool) {
        if (self.top >= self.capacity) {
            self.data.push(val);
            self.capacity = self.data.length;
        } else {
            self.data[self.top] = val;
        }
        self.top++;
        assert(self.top > 0);
        assert(self.capacity > 0);
        assert(self.data.length > 0);
        return true;
    }

    function pop(Stack storage self) internal returns (uint256 val) {
        assert(self.top > 0);
        val = self.data[self.top - 1];
        self.top--;
    }

    function getTop(Stack storage self) internal view returns (uint256) {
        assert(!(self.top == 0));
        return self.data[self.top - 1];
    }
}

library IterableMapping {
    struct itmap {
        mapping(uint256 => IndexValue) data;
        KeyFlag[] keys;
        uint256 size;
        stack.Stack holes; //for save deleted keyIndex. note the offset, save the zero based index, the real array pos start at 0.
        uint256 tail; //save tail pos, can't use size anymore, otherwise may overwrite some later part of the array.
    }
    struct IndexValue {
        uint256 keyIndex;
        address value;
    }
    struct KeyFlag {
        uint256 key;
        bool deleted;
    }

    function getKeyHint(itmap storage self) internal view returns (uint256) {
        if (self.holes.top > 0) {
            return stack.getTop(self.holes);
        }
        return self.tail;
    }

    function insert(
        itmap storage self,
        uint256 key,
        address value
    ) internal returns (bool replaced) {
        uint256 keyIndex = self.data[key].keyIndex; //means the begin with 0 position in array, but we will save a +1 number
        //in data map for judeing if the element exists.
        self.data[key].value = value;
        if (keyIndex > 0) return true;
        else {
            if (self.holes.top == 0) {
                //old logic.
                keyIndex = self.keys.length++;
                self.data[key].keyIndex = keyIndex + 1;
                self.keys[keyIndex].key = key;
            } else {
                //reuse space.
                keyIndex = getKeyHint(self);
                self.data[key].keyIndex = keyIndex + 1; // save +1 to judge if valid, 0 is not valid.
                self.keys[keyIndex].key = key;
                self.keys[keyIndex].deleted = false;
                stack.pop(self.holes);
            }
            self.size++;
            if (self.size - 1 > self.tail) {
                self.tail = self.size - 1;
            }

            return false;
        }
    }

    function remove(itmap storage self, uint256 key)
        internal
        returns (bool success)
    {
        uint256 keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0) return false;
        delete self.data[key];
        stack.push(self.holes, keyIndex - 1); //save the real offset, begin with 0, so need -1.
        self.keys[keyIndex - 1].deleted = true;
        self.size--;
        return true;
    }

    function contains(itmap storage self, uint256 key)
        internal
        view
        returns (bool)
    {
        return self.data[key].keyIndex > 0;
    }

    function iterate_start(itmap storage self)
        internal
        view
        returns (uint256 keyIndex)
    {
        return iterate_next(self, uint256(-1));
    }

    function iterate_valid(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (bool)
    {
        return keyIndex < self.keys.length;
    }

    function iterate_next(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (uint256 r_keyIndex)
    {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }

    function iterate_get(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (address value)
    {
        value = self.data[self.keys[keyIndex].key].value;
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
    constructor() internal {
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
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address PancakePair);
}

interface IPancakePair {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract PancakeTool {
    address public PancakePair;
    IRouter internal PancakeV2Router;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    function initIRouter(address _router) internal {
        PancakeV2Router = IRouter(_router);
        PancakePair = IFactory(PancakeV2Router.factory()).createPair(
            address(this),
            USDT
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

    function swapTokensForTokens(uint256 amountA, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
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
        returns (uint112 WETHAmount, uint112 TOKENAmount)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(PancakePair)
            .getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPancakePair(PancakePair).token0() == PancakeV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }

    function getLPTotal(address user) external view returns (uint256) {
        return IBEP20(PancakePair).balanceOf(user);
    }

    function getTotalSupply() external view returns (uint256) {
        return IBEP20(PancakePair).totalSupply();
    }
}

contract DHAND is Context, IBEP20, Ownable, PancakeTool {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    address private cakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private initPoolHolder;

    uint256 public balanceTop;

    uint8 private _Percent = 3;

    uint256 private divBase = 100;
    uint256 private tokenSize = 1000000000000000000;

    uint256 private rewardTime = now;

    IterableMapping.itmap shareHolders;
    uint256 private shareSize = 0;

    uint256 private _liquiditySupply;
    mapping(address => uint256) private _liquidityBalances;

    struct Client {
        bool isJoin;
        uint256 joinKey;
        uint256 joinTime;
    }

    mapping(address => Client) private ClientMap;
    mapping(address => uint256) private dividendMap;
    mapping(address => uint256) private logCountMap;
    bool private isSwaping;

    event Withdraw(address indexed account, uint256 value);
    event PledgeLP(address indexed account, uint256 value);
    event RemovePledge(address indexed account, uint256 value);

    constructor() public {
        _name = "DHAND Token";
        _symbol = "DHAND";
        _decimals = 18;

        _totalSupply = 6666 * tokenSize;
        _balances[msg.sender] = 6666 * tokenSize;
        initPoolHolder = msg.sender;
        initIRouter(cakeRouter);

        _approve(address(this), cakeRouter, ~uint256(0));
        _approve(owner(), cakeRouter, ~uint256(0));
        IBEP20(USDT).approve(cakeRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
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

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
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
    function approve(address spender, uint256 amount) external returns (bool) {
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
    ) external returns (bool) {
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
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        if (
            sender != owner() &&
            sender != address(this) &&
            sender != initPoolHolder &&
            recipient != owner() &&
            recipient != address(this) &&
            recipient != initPoolHolder
        ) {
            uint256 Fee = (amount / divBase) * _Percent;
            _balances[address(this)] = _balances[address(this)].add(Fee);
            amount = amount.sub(Fee);
            emit Transfer(sender, address(this), Fee);
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        if(!isSwaping){
            calculateDividend();
        }
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (sender == address(this) || sender == initPoolHolder) {
            return;
        }

        if (recipient == tx.origin && recipient != initPoolHolder) {
            require(amount <= 5 * tokenSize);
            require(_balances[recipient].add(amount) <= 20 * tokenSize);
            return;
        }

        if (sender == tx.origin && sender != initPoolHolder) {
            require(amount <= 5 * tokenSize);
            require(amount <= (_balances[sender] / divBase) * 99);
        }
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

    function liquiditySupply() external view returns (uint256) {
        return _liquiditySupply;
    }

    function liquidityBalance(address account)
        external
        view
        returns (uint256)
    {
        return _liquidityBalances[account];
    }

    function addPledge(uint256 amount) public returns (bool) {
        IPancakePair(PancakePair).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        _liquidityBalances[msg.sender] = _liquidityBalances[msg.sender].add(
            amount
        );
        _liquiditySupply = _liquiditySupply.add(amount);
        Client memory client = ClientMap[msg.sender];
        if (!client.isJoin) {
            ClientMap[msg.sender] = Client(true, shareSize, now);
            insertHolder(shareSize, msg.sender);
            shareSize = shareSize.add(1);
        }

        emit PledgeLP(msg.sender, amount);
        return true;
    }

    function removePledge(uint256 amount) public payable returns (bool) {
        Client memory client = ClientMap[msg.sender];
        require(_liquidityBalances[msg.sender] >= amount);
        require(         
            msg.value >= 2000000000000000,
            "You need to pay 0.002 BNB to cover the bonus calculation fee."
        );
        _liquidityBalances[msg.sender] = _liquidityBalances[msg.sender].sub(
            amount
        );
        address(this).transfer(msg.value);
        _liquiditySupply = _liquiditySupply.sub(amount);
        IPancakePair(PancakePair).transfer(msg.sender, amount);
        if (_liquidityBalances[msg.sender] <= 0) {
            removeHolder(client.joinKey);
            delete ClientMap[msg.sender];
        }
        emit RemovePledge(msg.sender, amount);
        return true;
    }

    function shareAll() public view returns (address[] memory) {
        uint256 index = 0;
        address[] memory shareList = new address[](shareHolders.size);
        for (
            uint256 i = IterableMapping.iterate_start(shareHolders);
            IterableMapping.iterate_valid(shareHolders, i);
            i = IterableMapping.iterate_next(shareHolders, i)
        ) {
            address account = IterableMapping.iterate_get(shareHolders, i);
            shareList[index] = account;
            index += 1;
        }
        return shareList;
    }

    function shareAllSize() public view returns (uint256) {
        return shareHolders.size;
    }

    function calculateDividend() public  returns (bool) {
        if (now - rewardTime >= 86400) {
            //当前余额 - 上次分红时的余额 = 本期可进行分红的数量
            uint256 lastBalance = _balances[address(this)] - balanceTop;
            //如果余额满足
            if (lastBalance >= 0) {
                rewardTime = now;
                balanceTop = _balances[address(this)];
                for (
                    uint256 i = IterableMapping.iterate_start(shareHolders);
                    IterableMapping.iterate_valid(shareHolders, i);
                    i = IterableMapping.iterate_next(shareHolders, i)
                ) {
                    address account = IterableMapping.iterate_get(
                        shareHolders,
                        i
                    );
                    uint256 r = calculateReward(
                        _liquiditySupply,
                        lastBalance,
                        _liquidityBalances[account]
                    );
                    dividendMap[account] = dividendMap[account].add(r);
                }
            } 

            //If the number of LP pledgers reaches 100, the Gas fee return mechanism starts
            if (shareHolders.size > 100) {
                uint256 gas = (tx.gasprice * block.gaslimit) - gasleft();
                uint256 bnb = address(this).balance;
                if(bnb > 0){
                    if (bnb >= gas) { 
                        tx.origin.transfer(gas);
                    }   
                }
            }
        }
    }

    function withdrawDividend() public payable returns (bool) {
        uint256 amount = dividendMap[msg.sender];
        require(amount > 0, "No dividend for now");
        require(         
            msg.value >= 2000000000000000,
            "You need to pay 0.002 BNB to cover the bonus calculation fee."
        );
        dividendMap[msg.sender] = dividendMap[msg.sender].sub(
            amount,
            "amount exceeds balance"
        );
        address(this).transfer(msg.value);
        balanceTop = balanceTop.sub(amount);
        uint256 liquidity = (amount / divBase) * 3;
        backflowPool(liquidity);
        amount = amount.sub(liquidity);
        _transfer(address(this), msg.sender, amount);
        logCountMap[msg.sender] = logCountMap[msg.sender].add(amount);
        emit Withdraw(msg.sender, amount);
        return true;
    }

    function backflowPool(uint256 amount) internal {
        isSwaping = true;

        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);
        uint256 oldBalance = IBEP20(USDT).balanceOf(address(this));

        swapTokensForTokens(half, initPoolHolder);

        IBEP20(USDT).transferFrom(
            initPoolHolder,
            address(this),
            IBEP20(USDT).balanceOf(initPoolHolder)
        );
        
        uint256 newBalance = IBEP20(USDT).balanceOf(address(this)) - oldBalance;
        addLiquidity(address(this), USDT, otherHalf, newBalance);

        isSwaping = false;
    }

    function joinTime(address account) public view returns (uint256) {
        return ClientMap[account].joinTime;
    }

    function dividend(address account) public view returns (uint256) {
        return dividendMap[account];
    }

    function logsCount(address account) public view returns (uint256) {
        return logCountMap[account];
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) internal view returns (uint256) {
        return (reward * ((holders * tokenSize) / total)) / tokenSize;
    }

    // Increase shareholder
    function insertHolder(uint256 k, address v)
        internal
        returns (uint256 size)
    {
        // Actually calls itmap_impl.insert, auto-supplying the first parameter for us.
        IterableMapping.insert(shareHolders, k, v);
        // We can still access members of the struct - but we should take care not to mess with them.
        return shareHolders.size;
    }

    //remove shareholder
    function removeHolder(uint256 k) internal returns (uint256 size) {
        // Actually calls itmap_impl.insert, auto-supplying the first parameter for us.
        IterableMapping.remove(shareHolders, k);
        // We can still access members of the struct - but we should take care not to mess with them.
        return shareHolders.size;
    }

    function() external payable {}
}