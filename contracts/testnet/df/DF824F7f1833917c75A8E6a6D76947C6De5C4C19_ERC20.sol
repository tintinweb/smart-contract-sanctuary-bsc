/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract FeeHelper is Ownable {
    using SafeMath for uint256;

    constructor(){}

    function transferToken(address token_, address to_, uint256 amount_) public onlyOwner {
        IERC20(token_).transfer(to_, amount_);
    }
}

contract ShellToken is ERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    struct LpAwardCondition{
        uint lpHoldAmount;
        uint tokenHoldAmount;
    }

    string private name_ = "SHELL";
    string private symbol_ = "SHELL";
    uint256 private totalSupply_ = 10000 * 10 **18;

    uint256 public initFeeRate = 30;
    uint256 public mkFee = 5;
    uint256 public vcFee = 5;
    uint256 public nftFee= 5;
    uint256 public lpFee = 15;

    address public mkAddress = 0x4789ad53CA49505049f8E0df9055f0553847C445;
    address public vcAddress = 0x1835c57115622E21aDb6302E16c4ed7436E8339c;
    address public nftAddress = 0x1bbF2Edada9A2c7B094AbBCd6422ABFb28584FB5;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    
    uint256 public lpRewardPeriod = 60 * 60;
    uint256 public lpRewardSendCount= 150;
    LpAwardCondition public lpAwardCondition = LpAwardCondition(10 ** 17, 10 ** 17);

    FeeHelper public lpFeeHelper = new FeeHelper();
    mapping(uint256 => uint256) public todayBasePrices;

    mapping (address => bool) public isExcludedFromFees;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint public swapStartTime;

    struct Interest{
        uint256 index;
        uint256 period;
        uint256 lastSendTime;
        uint sendCount;
        IERC20  token;
        EnumerableSet.AddressSet tokenHolder;
    }
    address  fromAddress;
    address  toAddress;
    Interest internal lpInterest;

    constructor() ERC20(name_, symbol_)  {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDT);

        require(IUniswapV2Pair(uniswapV2Pair).token1() == address(this),"invalid lp address");

        excludeFromFees(owner(), true);
        excludeFromFees(mkAddress, true);
        excludeFromFees(vcAddress, true);
        excludeFromFees(nftAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(lpFeeHelper), true);

        lpInterest.token = IERC20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.period = lpRewardPeriod;
        lpInterest.sendCount = lpRewardSendCount;

        _cast(owner(), totalSupply_);
    }

    receive() external payable {}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setswapStartTime(uint _swapStartTime)external onlyOwner{
        swapStartTime = _swapStartTime;
    }

    function setMkAddress(address addr_) public onlyOwner {
        mkAddress = addr_;
    }

    function setVcAddress(address addr_) public onlyOwner {
        vcAddress = addr_;
    }

    function setNftAddress(address addr_) public onlyOwner {
        nftAddress = addr_;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(
            amount == 0 || 
            from == address(lpFeeHelper)
        ) { 
            super._transfer(from, to, amount); 
            return;
        }

        bool liquidityTx = isLiquidity(from,to);
        if( IERC20(uniswapV2Pair).totalSupply() > 0){
            recordTodayBasePrice();
        }
        
        bool takeFee = true;
        if(isExcludedFromFees[from] || isExcludedFromFees[to] || liquidityTx) {
            takeFee = false;
        }

        if(takeFee) {
            if( block.timestamp < swapStartTime && (from == uniswapV2Pair || to == uniswapV2Pair) ){
                require(false,"swap no start");
            }
            amount =  takeAllFee(from, to, amount); 
        }
        super._transfer(from, to, amount);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        
        if ( fromAddress != uniswapV2Pair && !isContract(fromAddress) ) {
            setShare(fromAddress);
        }
        if ( toAddress != uniswapV2Pair && !isContract(toAddress) ) {
            setShare(toAddress);
        }
        fromAddress = from;
        toAddress = to;

        if (
            takeFee &&
            from != address(this) 
            && lpInterest.lastSendTime + lpInterest.period < block.timestamp 
            && lpInterest.token.totalSupply() > 0 
        ) {
            lpInterest.lastSendTime = block.timestamp;
            processLpReward();
        }

    }

    function getTodayId() public view returns (uint256) {
        return block.timestamp.div(1 days).mul(1 days);
    }

    function recordTodayBasePrice() internal {
        uint256 todayId = getTodayId();
        if(todayBasePrices[todayId] == 0){
            uint256 price = getCurrentPrice();
            todayBasePrices[todayId] = price;
        }
    }

    function getCurrentPrice() public view returns(uint256){
        (uint r0,uint r1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        if( r0 > 0 && r1 > 0){
            if( address(this) == IUniswapV2Pair(uniswapV2Pair).token0()){
                return r1 * 10 ** 18 / r0;
            }else{
                return r0 * 10 ** 18 / r1;
            }
        }
        return 0;
    }

    function getBuyFeeRate() public view returns(uint256){
        uint256 price = getCurrentPrice();
        uint256 todayId = getTodayId();
        uint256 basePrice = todayBasePrices[todayId];

        if(price >= basePrice) return initFeeRate;

        uint256 rate = (basePrice - price).mul(100).div(basePrice);
        if( rate >= 40) return 0;
        if( rate >= 30) return 5;
        if( rate >= 20) return 10;
        if( rate >= 10) return 20;

        return initFeeRate;
    }

    function getSellFeeRate() public view returns(uint256){
        uint256 price = getCurrentPrice();
        uint256 todayId = getTodayId();
        uint256 basePrice = todayBasePrices[todayId];

        if(price >= basePrice) return initFeeRate;

        uint256 rate = (basePrice - price).mul(100).div(basePrice);
        if( rate >= 40) return 250;
        if( rate >= 30) return 200;
        if( rate >= 20) return 150;
        if( rate >= 10) return 100;

        return initFeeRate;
    }

    function getTransferFeeRate() public view returns(uint256){
        return initFeeRate;
    }

    function setShare(address account) private {
        if(lpInterest.tokenHolder.contains(account) ){
            if( !checkLpShare(account) ) {
                lpInterest.tokenHolder.remove(account);
            }
            return;
        }
        if(checkLpShare(account)){
            lpInterest.tokenHolder.add(account);
        }
    }

    function checkLpShare(address account) internal view returns(bool){
        uint supply = lpInterest.token.totalSupply();
        if(supply == 0) return false;

        uint lpAmount = lpInterest.token.balanceOf(account);

        (,uint r1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        
        return lpAmount * r1 / supply >= lpAwardCondition.lpHoldAmount 
                && balanceOf(account) >= lpAwardCondition.tokenHoldAmount;
  
    }

   function processLpReward() private {
        uint256 shareholderCount = lpInterest.tokenHolder.length();
        if (shareholderCount == 0) return;

        uint256 nowbanance = balanceOf(address(lpFeeHelper));
        if (nowbanance == 0) return;
        uint256 iterations = 0;
        uint index = lpInterest.index;
        uint sendedCount = 0;
        uint sendCountLimit = lpInterest.sendCount;

        uint ts = lpInterest.token.totalSupply();

        while (sendedCount < sendCountLimit && iterations < shareholderCount) {
            if (index >= shareholderCount) {
                index = 0;
            }

            address shareholder = lpInterest.tokenHolder.at(index);
            uint256 amount = nowbanance.mul(lpInterest.token.balanceOf(shareholder)).div(ts);

            if ( balanceOf(address(lpFeeHelper)) < amount ) break;

            if(amount > 0) lpFeeHelper.transferToken(address(this), shareholder, amount);

            sendedCount ++;
            iterations++;
            index ++;
        }

        lpInterest.index = index;
    }


    function takeAllFee(address from, address to, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 feeRate;
        if(from == uniswapV2Pair){
            feeRate = getBuyFeeRate();
        }else if(to == uniswapV2Pair){
            uint256 allowAmount = balanceOf(from).mul(99).div(100);
            if( amount > allowAmount){
                amount = allowAmount;
            }
            feeRate = getSellFeeRate();
        }else{
            feeRate = getTransferFeeRate();
        }

        if(feeRate > 0){
            uint256 feeAmount = amount.mul(feeRate).div(1000);

            uint256 lpFeeAmount = feeAmount.mul(lpFee).div(initFeeRate);
            if(lpFeeAmount > 0) super._transfer(from, address(lpFeeHelper), lpFeeAmount);

            uint256 nftAmount = feeAmount.mul(nftFee).div(initFeeRate);
            if(nftAmount > 0) super._transfer(from, nftAddress, nftAmount);

            uint256 vcAmount = feeAmount.mul(vcFee).div(initFeeRate);
            if(vcAmount > 0) super._transfer(from, vcAddress, vcAmount);

            uint256 mkAmount = feeAmount.sub(lpFeeAmount).sub(nftAmount).sub(vcAmount);
            if(mkAmount > 0) super._transfer(from, mkAddress, mkAmount);
            
            amountAfter = amount.sub(feeAmount);
        }

    }

    function isLiquidity(address from, address to) internal view returns(bool){
        if(from != uniswapV2Pair && to != uniswapV2Pair) return false;

        address token0 = IUniswapV2Pair(uniswapV2Pair).token0();
        (uint reserve0,,) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        uint balance0 = IERC20(token0).balanceOf(uniswapV2Pair);

        if(to == uniswapV2Pair){
            return balance0 > reserve0;
        }

        if(from == uniswapV2Pair){
            return balance0 < reserve0;
        }
        
        return false;
    }

    function isContract(address account) public view returns (bool) {
        return account.code.length > 0;
    }
    
}