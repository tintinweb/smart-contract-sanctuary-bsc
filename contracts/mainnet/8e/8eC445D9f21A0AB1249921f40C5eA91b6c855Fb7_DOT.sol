/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

contract TokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    uint256 public minimumTokenBalanceForDividends;

    address public  uniswapV2Pair;
    
    uint256 public LPRewardLastSendTime;
    address public lpRewardToken;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
        minimumTokenBalanceForDividends = 10 * (10**18);
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    function setMinimumTokenBalanceForDividends(uint256 val)
        public
        onlyOwner
    {
        minimumTokenBalanceForDividends = val * (10**18);
    }

   
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
  
    function setShare(address shareholder,uint256 newBalance) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0){
                quitShare(shareholder);
                return; 
            }           
            if(newBalance < minimumTokenBalanceForDividends){
                quitShare(shareholder);
                return; 
            } 
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        if(newBalance < minimumTokenBalanceForDividends) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}


contract DOT is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    bool inSwapAndLiquify;

    uint256 public swapTokensAtAmount; 

    uint256 public deadFee = 3; 
    uint256 public buyLiquidityFee = 2;   
    uint256 public sellLiquidityFee = 5;   
    uint256 public buyInviteFee = 3;

    uint256 public AmountLiquidityFee;  
    uint256 public AmountLpRewardFee; 
 
    address public liquidityReceiveAddress;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public lpRewardToken = 0x55d398326f99059fF775485246999027B3197955; 

    address public _devAddress = 0x9Fc75335979e92B850500805319e6bE84EC75862;
	
	address public _devAddress2 = 0x82C11066a88C768d6098B6BE396bF8a7D9CB9361;

    mapping(address => address) public inviter;
    
    mapping (address => bool) private _isExcludedFromFees;
 
   TokenDividendTracker public dividendTracker;

   mapping(address => bool) public _isBlacklisted;
    
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;

    uint256 public minPeriod = 7200;
    
    uint256 distributorGas = 80000;

    uint256 public _maxTxAmount = 2000 * 10**18;
	
    uint256 public _sellMaxTxAmount = 2000 * 10**18;

    uint256 public _inviteTxAmount = 10 * 10**18;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndSendTo(
        uint256 tokensSwapped,
        uint256 amount,
        string to
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor() payable ERC20("Polkadot Union", "DOT") {
        uint256 totalSupply = 100000 * (10**18);
        swapTokensAtAmount = 50 * 10**18;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        liquidityReceiveAddress = owner();
        dividendTracker = new TokenDividendTracker(uniswapV2Pair, lpRewardToken);

       
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(dividendTracker), true);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(dividendTracker)] = true;

        _cast(owner(), totalSupply);
    }

    receive() external payable {}

   
    function updateMinimumTokenBalanceForDividends(uint256 val)
        public
        onlyOwner
    {
        dividendTracker.setMinimumTokenBalanceForDividends(val);
    }

    function dividendExempt(address account, bool excluded) public onlyOwner {
        isDividendExempt[account] = excluded;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    
    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }
    
    function setBuyLiquidityFee(uint256 val) public onlyOwner {
        buyLiquidityFee = val;
    }
     function setSellLiquidityFee(uint256 val) public onlyOwner {
        sellLiquidityFee = val;
    }
  
   function setDeadFee(uint256 val) public onlyOwner {
        deadFee = val;
    }
   
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }
    
    function setLiquidityReceiveAddress(address val) public onlyOwner {
        liquidityReceiveAddress = val;
    }

     function setMaxTxAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    function setSellMaxTxAmount(uint256 maxTxAmount) public onlyOwner {
        _sellMaxTxAmount = maxTxAmount;
    }

    function setinviteTxAmount(uint256 inviteAmount) public onlyOwner {
        _inviteTxAmount = inviteAmount;
    }

     function blacklistAddress(address account, bool value) public onlyOwner{
        _isBlacklisted[account] = value;
    }

    function setdevAddress(address val) public onlyOwner {
        _devAddress = val;
    }
	
    function setdevAddress2(address val) public onlyOwner {
        _devAddress2 = val;
    }
	
    function setlpRewardToken(address val) public onlyOwner {
        lpRewardToken = val;
        dividendTracker = new TokenDividendTracker(uniswapV2Pair, lpRewardToken);
        isDividendExempt[address(dividendTracker)] = true;
    }
    
    function resetLPRewardLastSendTime() public onlyOwner {
        dividendTracker.resetLPRewardLastSendTime();
    }

   
    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 70000 && newValue <= 350000, "distributorGas must be between 150,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) { super._transfer(from, to, 0); return;}
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if( canSwap &&
            !inSwapAndLiquify &&
            from != owner() &&
            to != owner()&&
            from != uniswapV2Pair
        ) {
            uint256 fee1s = swapTokensAtAmount.mul(4).div(10);
            uint256 fee2s = swapTokensAtAmount.sub(fee1s);
            swapAndLiquify(fee1s);
            swapLPRewardToken(fee2s);
        }

        bool takeFee = !inSwapAndLiquify;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if(from!=uniswapV2Pair && to!=uniswapV2Pair) {
            takeFee = false;
        }else{
            if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                if(from==uniswapV2Pair){
                    require(
                        amount <= _maxTxAmount,
                        "Transfer amount exceeds the maxTxAmount."
                    );
                }else{
                    require(
                        amount <= _sellMaxTxAmount,
                        "Transfer amount exceeds the maxTxAmount."
                    );
                }
            }
        }

        if(takeFee) {
            if(from == uniswapV2Pair){
               amount = takeBuyFee(from,to,amount);
            }else if(to == uniswapV2Pair && !inSwapAndLiquify){
                uint256 minHolderAmount = balanceOf(from).mul(90).div(100);
                if(amount > minHolderAmount){
                    amount = minHolderAmount;
                }
                amount = takeSellFee(from,to,amount);
            }
        }
        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        super._transfer(from, to, amount);

        if (shouldSetInviter) {
            inviter[to] = from;
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair )   try dividendTracker.setShare(fromAddress,balanceOf(fromAddress)) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) try dividendTracker.setShare(toAddress,balanceOf(toAddress)) {} catch {}
        fromAddress = from;
        toAddress = to;  

       if(!inSwapAndLiquify && 
            from != owner() &&
            to != owner() &&
            from !=address(this) &&
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try dividendTracker.process(distributorGas) {} catch {}    
        }
    }

    
    function takeBuyFee(address sender,address recipient,uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 DFee = amount.mul(deadFee).div(100);
        if(DFee > 0) super._transfer(sender, deadWallet, DFee);
        amountAfter = amountAfter.sub(DFee);

        uint256 LFee = amount.mul(buyLiquidityFee).div(100);
        AmountLiquidityFee += LFee;
        amountAfter = amountAfter.sub(LFee);

        uint256 YFee = amount.mul(buyInviteFee).div(100);
        amountAfter = amountAfter.sub(YFee);
        if(YFee > 0){
            address cur;
            if (sender == uniswapV2Pair) {
                cur = recipient;
            } else if (recipient == uniswapV2Pair) {
                cur = sender;
            }
            if (cur == address(0)) {
                return amountAfter;
            }
            uint256 reserveOutNum = 0;
            for (int256 i = 0; i < 3; i++) {
                uint256 rate;
                if (i == 0) {
                    rate = 1;
                } else if(i == 1){
                    rate = 1;
                }else{
                    rate = 1;
                }
                cur = inviter[cur];
                if (cur == address(0)) {
                    break;
                }
                if (balanceOf(cur)<_inviteTxAmount) {
                    break;
                }
                uint256 curTAmount = amount.div(100).mul(rate);
                reserveOutNum+=curTAmount;
                super._transfer(sender, cur, curTAmount);
            }
            uint256 sxNum = YFee.sub(reserveOutNum);
            if(sxNum>0){
                super._transfer(sender, _devAddress2, sxNum);
            }
        }
           
        super._transfer(sender, address(this), LFee);
    }

     function takeSellFee(address sender,address recipient,uint256 amount) private lockTheSwap returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 LFee = amount.mul(sellLiquidityFee).div(100);
        AmountLiquidityFee += LFee;
        amountAfter = amountAfter.sub(LFee);

        uint256 YFee = amount.mul(buyInviteFee).div(100);
        amountAfter = amountAfter.sub(YFee);
           
        super._transfer(sender, address(this), LFee.add(YFee));

        if(YFee > 0){
            swapTokensForEth(YFee);
            uint256 contractUSDTBalance =  address(this).balance;
            address cur;
            if (sender == uniswapV2Pair) {
                cur = recipient;
            } else if (recipient == uniswapV2Pair) {
                cur = sender;
            }
            if (cur == address(0)) {
                return amountAfter;
            }
            
            uint256 reserveOutNum = 0;
           for (int256 i = 0; i < 6; i++) {
                uint256 rate;
                if (i == 0) {
                    rate = 0;
                } else if(i == 1){
                    rate = 0;
                } else if(i == 2){
                    rate = 0;
                } else if(i == 3){
                    rate = 1;
                } else if(i == 4){
                    rate = 1;
                } else {
                    rate = 1;
                } 
                cur = inviter[cur];
                if (cur == address(0)) {
                    break;
                }
                if (balanceOf(cur)<_inviteTxAmount) {
                    break;
                }
                uint256 curTAmount = contractUSDTBalance.div(buyInviteFee).mul(rate);
                reserveOutNum+=curTAmount;
                (bool success,) = address(cur).call{value: curTAmount}("");
                if(success){}
            }
            uint256 sxNum = contractUSDTBalance.sub(reserveOutNum);
            if(sxNum>0){
                (bool success,) = address(_devAddress2).call{value: sxNum}("");
                if(success){}
            }
        }
        
    }
 
    function swapAndLiquify(uint256 tokens) private lockTheSwap{
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiveAddress,
            block.timestamp
        );

    }

    function swapLPRewardToken(uint256 tokenAmount) private lockTheSwap{
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = lpRewardToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(dividendTracker),
            block.timestamp
        );
    
    }
}