/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
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
    function _mint(address account, uint256 amount) internal virtual {
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract LAEEBTToken is ERC20, Ownable {

    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    bool private swapping;
    address payable public  _marketingWalletAddress = payable(0xaC7da03F0bE4459dced76a359309fDBc6771fb7d); 
    address public rewardToken = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; 
    uint256 public swapTokensAtAmount; 

    uint deadFee = 0; 
    uint marketingFee = 100; 
    uint liquidityFee = 0;
    uint lpFee = 200;  
    uint liquidityDeadFee = 100;  
    uint commFee = 100; 
    uint8[3] public commFeeList = [50 , 30 , 20]; 


    uint256 public marketingFeeTokens;
    uint256 public marketingFeeBNB;
    uint256 public amountMarketingFeeTokens = 30000 * (10**18);
    mapping(address => address) public referrerByAddr; 
    mapping(address => address) public rereferrerByAddr; 

    uint256 public AmountLiquidityFee; 
    uint256 public AmountLPFee; 
    uint256 public AmountLPFeeDead = 3000 *(10**8); 

    uint256 public AmountDeadFee;  
    uint256 public AmountDeadBNB = (4 * (10 ** 18));  
    uint256 public AmountCountDeadBNB;  

    address [] public  lpHolderAddress;  
    address [] public lpLockAddress;     
    uint256 public lpSortCount = 100; 

    address public deadWallet=0x000000000000000000000000000000000000dEaD;
    uint256 public deadWalletAmount =  90000 * (10**18); 
    mapping(address => bool) public _isBlacklisted;

    uint256 public gasForProcessing;

    bool public swapAndLiquifyEnabled = true; 
    
    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) public automatedMarketMakerPairs;

    address private taxr;
    address private retaxr;  

    bool public isRaise = true;  
    uint256 public raiseAmount = 5000 * (10**18); 
    address [] public _raiseAddress;   
    mapping (address => uint) public raiseAddressList;

    address public commERC20;


    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
   
  

    constructor(
        string memory name_,
        string memory symbol_

    ) payable ERC20(name_, symbol_)  {

        uint256 totalSupply = 100000 * (10**18);   
        swapTokensAtAmount = 200 * (10**18);  

        gasForProcessing = 300000;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xB6BA90af76D139AB3170c7df0139636dB6120F7e);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair; 

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true); 

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(_marketingWalletAddress,true);
        
        _mint(owner(), totalSupply);
    }

    receive() external payable {}

    function pushLockAddress(address lock) public onlyOwner returns (bool) {
        lpLockAddress.push(lock);
        return true;
    }
    function delLockAddress() public onlyOwner returns (bool) {
        delete lpLockAddress;
        return true;
    }
    function dellpHolderAddress() public onlyOwner returns (bool) {
        delete lpHolderAddress;
        return true;
    }
    function updateUniswapV2Router(address newAddress) private onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) private onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) private onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    


    function blacklistAddress(address account, bool value) private onlyOwner{
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) private onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function isExcludedFromFees(address account) private view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setrewardToken(address _addr) private onlyOwner{
        rewardToken = _addr;
    }
    function setamountMarketingFeeTokens(uint256 _amount) private onlyOwner{
        amountMarketingFeeTokens = _amount;
    }
    function setMarketingWalletAddress(address payable _addr) public onlyOwner{
        _marketingWalletAddress = _addr;
    }

    function setcommERC20(address _addr) public onlyOwner{
        commERC20 = _addr;
    }

    
    function setRaiseAddress(address _addr) public onlyOwner returns (bool){
        if(isHaveRaiseAddress(_addr)){
            return false;
        } else {
            _raiseAddress.push(_addr);
            return true;
        }
    }
   
    function setRaiseAddressArray(address [] memory _addr)  public onlyOwner returns (uint256){
        uint256 ret = 0;
        for(uint i = 0; i<_addr.length; i++){
            if(!isHaveRaiseAddress(_addr[i])){
                _raiseAddress.push(_addr[i]);
                ret = ret.add(1);
            }   
        }
        return ret;
    }
    
    function isHaveRaiseAddress(address _addr) private view returns(bool){
        bool isreturn = false;
        for(uint8 i = 0; i < _raiseAddress.length; i++){
            if(_raiseAddress[i] == _addr){
                isreturn = true;
                break;
            }
        }
        return isreturn;
    }
    
    function NextRaiseDelRaiseAddress() public onlyOwner returns(bool) {
        for(uint i = 0; i < _raiseAddress.length; i++){
            raiseAddressList[_raiseAddress[i]] = 0 ;
        }
        delete _raiseAddress;
        return true;
    }
    
    function setRaiseAmount(uint256 _amount) public onlyOwner returns(bool){
        raiseAmount = _amount;
        return true;
    }
   
    function setRaise(bool _istrue) public onlyOwner returns(bool){
        isRaise = _istrue;
        return true;
    }

    function setCommAuthor(address _from, address _to) public {
        require(commERC20 == msg.sender,"Not ERC20 Address");
        if(referrerByAddr[_to] == address(0)){
            referrerByAddr[_to] = _from;
            rereferrerByAddr[_from] = _to;  
        } 
    }

    function setmarketingFee(uint256 _amount) private onlyOwner {
        marketingFee = _amount;
    }

    function setliquidityFee(uint256 _amount) private onlyOwner {
        liquidityFee = _amount;
    }

    function setlpFee(uint256 _amount) private onlyOwner {
        lpFee = _amount;
    }

    function setliquidityDeadFee(uint256 _amount) private onlyOwner {
        liquidityDeadFee = _amount;
    }

    function setcommFee(uint256 _amount) private onlyOwner {
        commFee = _amount;
    }

    function setAmountDeadBNB(uint256 _amount) public onlyOwner{
        AmountDeadBNB = _amount;
    }
    function setdeadWalletAmount(uint256 _amount) private onlyOwner{
        deadWalletAmount = _amount;
    }

    function setAmountLPFeeDead(uint256 _amount) private onlyOwner returns(bool){
        AmountLPFeeDead = _amount;
        return true;
    }
 
    function setlpSortCount(uint256 _amount) public onlyOwner returns(bool){
        lpSortCount = _amount;
        return true;
    }

    function getFee() private onlyOwner returns(bool){
        super._transfer(address(this), _marketingWalletAddress, balanceOf(address(this)));
        AmountLiquidityFee =0;
        AmountLPFee = 0;
        AmountDeadFee = 0;
        marketingFeeTokens = 0;
        return true;
    }
   
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');
       
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 deadBalance = balanceOf(deadWallet);
        if(deadBalance >= deadWalletAmount){
            super._transfer(from, to, amount);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;  
 
        if(automatedMarketMakerPairs[to]){   
            if(!isHaveLPHolderAddress(from)){
                lpHolderAddress.push(from);
        }}

        if(isRaise){
            if(automatedMarketMakerPairs[from]){
                if(!isHaveRaiseAddress(to)){ 
                    require(false," Not is the Raise Address ");
                }else{
                     if(raiseAddressList[to].add(amount) > raiseAmount){
                         require(false," The Raise Address Amount is Enough");
                    }
                }
                raiseAddressList[to] = raiseAddressList[to].add(amount);
            }  
        }


        if( canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            from != owner() &&
            to != owner() &&
            swapAndLiquifyEnabled
        ) 
        {
           
            swapping = true;


            if(address(this).balance >= AmountDeadBNB && AmountCountDeadBNB >= AmountDeadBNB){
                 swapETHForTokensToAddress(AmountDeadBNB,deadWallet);  
            }

            if(IERC20(rewardToken).balanceOf(address(this)) >= AmountLPFeeDead)
            {
                LPReward();
            }
             if(AmountLiquidityFee >= (30000 * (10**18))  &&  balanceOf(address(this)) >= AmountLiquidityFee ){
                 swapAndLiquify(AmountLiquidityFee);  
             }
             if(AmountDeadFee >= (100 * (10**18)) && balanceOf(address(this)) >= AmountDeadFee ){
                 swapTokensForEthXH(AmountDeadFee);  
             }

            if(AmountLPFee >= 100 * (10*18)  ){  
                   swapTokensForCake(AmountLPFee);
                   AmountLPFee = 0;
            }
     
            if(marketingFeeTokens >= amountMarketingFeeTokens && balanceOf(address(this)) >= amountMarketingFeeTokens ){
                swapTokensForEthYX(marketingFeeTokens);  
            }
            
            swapping = false;
        }

        
        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
           if(!automatedMarketMakerPairs[to]  && !automatedMarketMakerPairs[from]){  

                  super._transfer(from, _marketingWalletAddress, amount.mul(marketingFee).div(10000));   
                  super._transfer(from, to, amount.sub(amount.mul(marketingFee).div(10000)));
                  if(marketingFeeBNB >  0){
                      _marketingWalletAddress.transfer(marketingFeeBNB);
                  }
                  return;
            }

            uint256 [] memory feeslist = new uint256[](7);  
            feeslist[1] = 0;
            feeslist[2] = amount.mul(marketingFee).div(10000);
            feeslist[3] = amount.mul(liquidityFee).div(10000);
            feeslist[4] = amount.mul(lpFee).div(10000);
            feeslist[5] = amount.mul(liquidityDeadFee).div(10000);
            feeslist[6] = amount.mul(commFee).div(10000);   


            feeslist[0] = feeslist[1].add(feeslist[2]).add(feeslist[3]).add(feeslist[4]).add(feeslist[5]).add(feeslist[6]); 

            super._transfer(from, address(this), feeslist[3].add(feeslist[4]).add(feeslist[5]).add(feeslist[2])); 

            AmountLiquidityFee = AmountLiquidityFee.add(feeslist[3]);
            AmountLPFee = AmountLPFee.add(feeslist[4]);
            AmountDeadFee = AmountDeadFee.add(feeslist[5]);
            marketingFeeTokens = marketingFeeTokens.add(feeslist[2]);

            if(feeslist[6] > 0)  
            {
                 taxr = from;
                 retaxr =  from;
                if(from == uniswapV2Pair){
                    taxr = to;
                    retaxr = to;
                }
                for(uint8 i = 0; i < commFeeList.length; i++){
                    taxr = referrerByAddr[taxr];
                    retaxr = rereferrerByAddr[retaxr];
                    if(taxr == address(0)){
                        taxr = address(_marketingWalletAddress); 
                    }
                    if(retaxr == address(0)){
                        retaxr = address(_marketingWalletAddress);
                    }
                    super._transfer(from, address(taxr), feeslist[6].mul(commFeeList[i]).div(100).div(2));
                    super._transfer(from, address(retaxr), feeslist[6].mul(commFeeList[i]).div(100).div(2));
                }
            }
            amount = amount.sub(feeslist[0]);
        }
        super._transfer(from, to, amount);
    }
  
    function isHaveLPHolderAddress(address _addr) private view returns(bool){
        bool isreturn = false;
        for(uint8 i = 0; i < lpHolderAddress.length; i++){
            if(lpHolderAddress[i] == _addr){
                isreturn = true;
                break;
            }
        }
        return isreturn;
    }
    
    function LPReward() private returns(bool){
        uint totalReward = IERC20(rewardToken).balanceOf(address(this));
        uint256 lockLP = 0;
        for(uint8 i = 0;i < lpLockAddress.length; i ++){
            lockLP = lockLP.add(getLPTotal(lpLockAddress[i]));
        }
        uint256 LPTotalSupply = getLPTotalSupply() - lockLP;
        uint8 idocount = 0;
        address [] memory DXHolderAddress = SortLpHolderAddress(lpHolderAddress);
        for(uint256 i = 0; i < DXHolderAddress.length; i ++){
            bool isLock = false;
            for(uint8 j = 0; j < lpLockAddress.length; j ++){
                if(DXHolderAddress[i] == lpLockAddress[j]){
                    isLock = true;
                }
            }
            if(!isLock){
                uint256 amount = getLPTotal(DXHolderAddress[i]).mul(10**8);
                if(amount > 0){
                    uint256 bfb = amount.div(LPTotalSupply);
                    uint256 RewardAmount = totalReward.mul(bfb).div(10**8);
                    IERC20(rewardToken).transfer(DXHolderAddress[i], RewardAmount);
                    idocount ++;
                   
                    if(idocount >= lpSortCount){
                        break;
                    }
                }
            }
        }

        return true;
    }
   function SortLpHolderAddress(address [] memory lpAddress_) private view returns(address [] memory){
        address temp;
           for(uint8 i = 0;i < lpAddress_.length-1; i++){
                for(uint8 j = 0;j < lpAddress_.length-i-1; j++){
                    if( getLPTotal(lpAddress_[j]) < getLPTotal(lpAddress_[j+1]))
                    {
                        temp = lpAddress_[j];
                        lpAddress_[j] = lpAddress_[j+1];
                        lpAddress_[j+1] = temp;
                        
                    }
                }
            }
        return lpAddress_;
    }

   function getLPTotal(address _addr) private view returns (uint256) {
        return IUniswapV2Pair(uniswapV2Pair).balanceOf(_addr);
    }

    function getLPTotalSupply() private  view returns (uint256) {
        return IUniswapV2Pair(uniswapV2Pair).totalSupply();
    }

    function swapAndLiquify(uint256 tokens) private {
       
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

       
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        AmountLiquidityFee = AmountLiquidityFee - tokens;
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function swapTokensForEthXH(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenAmount); 
        uint256 newBalance = address(this).balance.sub(initialBalance);
        AmountCountDeadBNB = AmountCountDeadBNB.add(newBalance);
        AmountDeadFee = AmountDeadFee.sub(tokenAmount);
     }
    function swapTokensForEthYX(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenAmount); 
        uint256 newBalance = address(this).balance.sub(initialBalance);
        marketingFeeBNB = marketingFeeBNB.add(newBalance);
        marketingFeeTokens = marketingFeeTokens.sub(tokenAmount);
     }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }
        function swapETHForTokensToAddress(uint256 ethAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:ethAmount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function swapETHForTokens(uint256 ethAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:ethAmount}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
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
            address(0),
            block.timestamp
        );

    }

}