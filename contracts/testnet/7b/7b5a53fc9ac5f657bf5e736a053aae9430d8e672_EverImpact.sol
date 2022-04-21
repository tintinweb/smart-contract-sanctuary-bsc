/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
 
interface IERC20 {
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDividendPayingToken {
  function dividendOf(address _owner) external view returns(uint256);
 
  function withdrawDividend() external;
 
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );
 
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}
 
interface IDividendPayingTokenOptional {
  function withdrawableDividendOf(address _owner) external view returns(uint256);
 
  function withdrawnDividendOf(address _owner) external view returns(uint256);
 
  function accumulativeDividendOf(address _owner) external view returns(uint256);
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
 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
 
    function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity); 
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity); 
    function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB); 
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountToken, uint amountETH); 
    function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountA, uint amountB); 
    function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountToken, uint amountETH); 
    function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
    function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
 
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH); 
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH); 
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable; 
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
 
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }
 
    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }
 
    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }
 
    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }
 
 
 
    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }
 
    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }
 
    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }
 
        delete map.inserted[key];
        delete map.values[key];
 
        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
 
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
 
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
 
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
 
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
 
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when multiplying INT256_MIN with -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));
 
    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }
 
  function div(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when dividing INT256_MIN by -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && (b > 0));
 
    return a / b;
  }
 
  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
 
    return a - b;
  }
 
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view virtual returns (address) {
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

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
 
    mapping (address => mapping (address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
 
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
 
    function name() public view virtual returns (string memory) {
        return _name;
    }
 
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
 
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        _beforeTokenTransfer(sender, recipient, amount);
 
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
 
        _beforeTokenTransfer(address(0), account, amount);
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
 
        _beforeTokenTransfer(account, address(0), amount);
 
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
 
contract EverImpact is ERC20, Ownable {
    using SafeMath for uint256;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    IWETH eth = IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
 
    address public token1DividendToken;
    address public token2DividendToken;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    bool private swapping;
    bool public swapEnabled = true;
    bool public token1DividendEnabled = true;
    bool public token2DividendEnabled = true;
    bool public transferFeeEnabled = false;
 
    Token1DividendTracker public token1DividendTracker;
    Token2DividendTracker public token2DividendTracker;
    
    uint256 public swapTokensAtAmount = 200 * 10**9 * 10**18;
 
    uint256 public liquidityFee = 1;
    uint256 public token1DividendRewardsFee = 1;
    uint256 public token2DividendRewardsFee = 1;
    uint256 public marketingFee = 1;
    uint256 public buybackFee = 1;
    uint256 public charityFee = 1;
    uint256 public buyFee = token1DividendRewardsFee.add(marketingFee).add(token2DividendRewardsFee).add(liquidityFee).add(buybackFee).add(charityFee);

    uint256 public liquidityFeeOnSell = 3;
    uint256 public token1DividendRewardsFeeOnSell = 3;
    uint256 public token2DividendRewardsFeeOnSell = 3;
    uint256 public marketingFeeOnSell = 3;
    uint256 public buybackFeeOnSell = 3;
    uint256 public charityFeeOnSell = 3;
    uint256 public sellFee = token1DividendRewardsFeeOnSell.add(marketingFeeOnSell).add(token2DividendRewardsFeeOnSell).add(liquidityFeeOnSell).add(buybackFeeOnSell).add(charityFeeOnSell);
    
    address public marketingWallet = 0x6ae0AC97B248e7959f9D6836B0a424Bd69E3b68b;
    address public buybackWallet   = 0x38396b0BCF0669ed0c385a08C1B3FbD455eB7EF6;
    address public charityWallet   = 0xE74E416925D703B5963b521705A460D88C41a513;

    uint256 public gasForProcessing = 600000;
 
    address public presaleAddress;

    // max wallet tools
    mapping(address => bool) private _isExcludedFromMaxWallet;
    bool private enableMaxWallet = true;
    uint256 private maxWalletRate = 10;

    // max transaction tools
    mapping(address => bool) private _isExcludedFromAntiWhale;
    bool private enableAntiwhale = true;
    uint256 private maxTransferAmountRate = 10;
    
    mapping (address => bool) private isExcludedFromFees;

    mapping (address => bool) public automatedMarketMakerPairs;

    event Updatetoken1DividendTracker(address indexed newAddress, address indexed oldAddress);
    event Updatetoken2DividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event token1DividendEnabledUpdated(bool enabled);
    event token2DividendEnabledUpdated(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
 
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );
 
    event SendDividends(
    	uint256 amount
    );
 
    event Processedtoken1DividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
 
    event Processedtoken2DividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
    
    address private _newOwner = 0xb31d2B1Cb48569a549CF65200292EFA8499C95ba;

    constructor() ERC20("Ever Impact", "EIT") {
    	token1DividendTracker = new Token1DividendTracker();
    	token2DividendTracker = new Token2DividendTracker();

    	token1DividendToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        token2DividendToken = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
 
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
 
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
 
        excludeFromDividend(address(token1DividendTracker), true);
        excludeFromDividend(address(token2DividendTracker), true);
        excludeFromDividend(address(this), true);
        excludeFromDividend(address(_uniswapV2Router), true);
        excludeFromDividend(deadAddress, true);

        // exclude from max wallet limit
        _isExcludedFromMaxWallet[_newOwner] = true;
        _isExcludedFromMaxWallet[address(0)] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxWallet[deadAddress] = true;

        // exclude from max transaction limit
        _isExcludedFromAntiWhale[_newOwner] = true;
        _isExcludedFromAntiWhale[address(0)] = true;
        _isExcludedFromAntiWhale[address(this)] = true;
        _isExcludedFromAntiWhale[deadAddress] = true;

 
        // exclude from paying fees or having max transaction amount
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);
        excludeFromFees(_newOwner, true);
 
        setAuthOnDividends(_newOwner);
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(_newOwner, 1e15 * (10**18));
      
    }
 
    receive() external payable {}

  	function whitelistPreSale(address _presaleAddress) external onlyOwner {
  	    presaleAddress = _presaleAddress;
        token1DividendTracker.excludeFromDividends(_presaleAddress, true);
        token2DividendTracker.excludeFromDividends(_presaleAddress, true);
        excludeFromFees(_presaleAddress, true);
  	}
 
  	function prepareForPartherOrExchangeListing(address _partnerOrExchangeAddress) external onlyOwner {
  	    token1DividendTracker.excludeFromDividends(_partnerOrExchangeAddress, true);
        token2DividendTracker.excludeFromDividends(_partnerOrExchangeAddress, true);
        excludeFromFees(_partnerOrExchangeAddress, true);
  	}

    function setEnabledTransferFee(bool enable) external onlyOwner {
        transferFeeEnabled = enable;
    }    

    // max wallet functions
    function maxWalletAmount() public view returns (uint256) {
        return totalSupply().mul(maxWalletRate).div(1000);
    }

    function setMaxWalletAmountRateDenominator1000(uint256 _val) public onlyOwner {
        require(_val >= 10, "Max wallet percentage cannot be lower than 1%");
        maxWalletRate = _val;
    }

    function setExcludeFromMaxWallet(address account, bool exclude) public onlyOwner {
        _isExcludedFromMaxWallet[account] = exclude;
    }

    function setEnableMaxWallet(bool _val) public onlyOwner {
        enableMaxWallet = _val;
    }

    function isExcludedFromMaxWallet(address account) public view returns(bool) {
        return _isExcludedFromMaxWallet[account];
    }

    // max transaction functions
    function isExcludedFromAntiWhale(address account) public view returns(bool) {
        return _isExcludedFromAntiWhale[account];
    }

    function setExcludedFromAntiWhale(address account, bool exclude) public onlyOwner {
          _isExcludedFromAntiWhale[account] = exclude;
    }

    function setEnableAntiwhale(bool _val) public onlyOwner {
        enableAntiwhale = _val;
    }
    
    function maxTransferAmount() public view returns (uint256) {
        return totalSupply().mul(maxTransferAmountRate).div(10000);
    }

    function setMaxTransferAmountRate(uint256 _maxTransferAmountRate) public onlyOwner {
        require(_maxTransferAmountRate >= 10, "Max Transaction limit cannot be lower than 0.1% of total supply"); 
        maxTransferAmountRate  = _maxTransferAmountRate;
    }
  
  	function updatetoken2DividendToken(address _newContract) external onlyOwner {
  	    token2DividendToken = _newContract;
  	    token2DividendTracker.setDividendTokenAddress(_newContract);
  	}
 
  	function updatetoken1DividendToken(address _newContract) external onlyOwner {
  	    token1DividendToken = _newContract;
  	    token1DividendTracker.setDividendTokenAddress(_newContract);
  	}
    
  	function updateMarketingWallet(address _newWallet) external onlyOwner {
  	    require(_newWallet != marketingWallet, "EverImpact: The marketing wallet is already this address");
  	    marketingWallet = _newWallet;
  	}
    
    function updateBuybackWallet(address _newWallet) external onlyOwner {
  	    require(_newWallet != buybackWallet, "EverImpact: The marketing wallet is already this address");
  	    buybackWallet = _newWallet;
  	}

    function updateCharityWallet(address _newWallet) external onlyOwner {
  	    require(_newWallet != charityWallet, "EverImpact: The marketing wallet is already this address");
  	    charityWallet = _newWallet;
  	}
 
  	function setSwapTokensAtAmount(uint256 _swapAmount) external onlyOwner {
  	    swapTokensAtAmount = _swapAmount;
  	}
 
    function setAuthOnDividends(address account) public onlyOwner{
        token1DividendTracker.setAuth(account);
        token2DividendTracker.setAuth(account);
    }
 
    function setSwapEnabled(bool _enabled) external onlyOwner {
        require(swapEnabled != _enabled, "Can't set flag to same status");
        swapEnabled = _enabled;
    }

    function updatetoken1DividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(token1DividendTracker), "EverImpact: The dividend tracker already has that address");
 
        Token1DividendTracker newtoken1DividendTracker = Token1DividendTracker(payable(newAddress));
 
        require(newtoken1DividendTracker.owner() == address(this), "EverImpact: The new dividend tracker must be owned by the EverImpact token contract");
 
        newtoken1DividendTracker.excludeFromDividends(address(newtoken1DividendTracker), true);
        newtoken1DividendTracker.excludeFromDividends(address(this), true);
        newtoken1DividendTracker.excludeFromDividends(address(uniswapV2Router), true);
        newtoken1DividendTracker.excludeFromDividends(address(deadAddress), true);
 
        emit Updatetoken1DividendTracker(newAddress, address(token1DividendTracker));
 
        token1DividendTracker = newtoken1DividendTracker;
    }
 
    function updatetoken2DividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(token2DividendTracker), "EverImpact: The dividend tracker already has that address");
 
       Token2DividendTracker newtoken2DividendTracker = Token2DividendTracker(payable(newAddress));
 
        require(newtoken2DividendTracker.owner() == address(this), "EverImpact: The new dividend tracker must be owned by the EverImpact token contract");
 
        newtoken2DividendTracker.excludeFromDividends(address(newtoken2DividendTracker), true);
        newtoken2DividendTracker.excludeFromDividends(address(this), true);
        newtoken2DividendTracker.excludeFromDividends(address(uniswapV2Router), true);
        newtoken2DividendTracker.excludeFromDividends(address(deadAddress), true);
 
        emit Updatetoken2DividendTracker(newAddress, address(token2DividendTracker));
 
        token2DividendTracker = newtoken2DividendTracker;
    }
 
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "EverImpact: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
 
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
 
        emit ExcludeFromFees(account, excluded);
    }
 
    function excludeFromDividend(address account, bool exclude) public onlyOwner {
        token1DividendTracker.excludeFromDividends(address(account), exclude);
        token2DividendTracker.excludeFromDividends(address(account), exclude);
    }
 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
 
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
 
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "EverImpact: The PanadaSwap pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        require(automatedMarketMakerPairs[pair] != value, "TestPlus: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
 
        if(value) {
            token1DividendTracker.excludeFromDividends(pair, true);
            token2DividendTracker.excludeFromDividends(pair, true);
        }
 
        emit SetAutomatedMarketMakerPair(pair, value);
    }
 
    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue != gasForProcessing, "EverImpact: Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
        emit GasForProcessingUpdated(newValue, gasForProcessing);
    }
 
    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
        token1DividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
        token2DividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }
 
    function updateClaimWait(uint256 claimWait) external onlyOwner {
        token1DividendTracker.updateClaimWait(claimWait);
        token2DividendTracker.updateClaimWait(claimWait);
    }
 
    function gettoken1ClaimWait() external view returns(uint256) {
        return token1DividendTracker.claimWait();
    }
 
    function gettoken2ClaimWait() external view returns(uint256) {
        return token2DividendTracker.claimWait();
    }
 
    function getTotaltoken1DividendsDistributed() external view returns (uint256) {
        return token1DividendTracker.totalDividendsDistributed();
    }
 
    function getTotaltoken2DividendsDistributed() external view returns (uint256) {
        return token2DividendTracker.totalDividendsDistributed();
    }
 
    function getIsExcludedFromFees(address account) public view returns(bool) {
        return isExcludedFromFees[account];
    }
 
    function withdrawabletoken1DividendOf(address account) external view returns(uint256) {
    	return token1DividendTracker.withdrawableDividendOf(account);
  	}
 
  	function withdrawabletoken2DividendOf(address account) external view returns(uint256) {
    	return token2DividendTracker.withdrawableDividendOf(account);
  	}
 
	function token1DividendTokenBalanceOf(address account) external view returns (uint256) {
		return token1DividendTracker.balanceOf(account);
	}
 
	function token2DividendTokenBalanceOf(address account) external view returns (uint256) {
		return token2DividendTracker.balanceOf(account);
	}
 
    function getAccounttoken1DividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return token1DividendTracker.getAccount(account);
    }
 
    function getAccounttoken2DividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return token2DividendTracker.getAccount(account);
    }
 
	function getAccounttoken1DividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return token1DividendTracker.getAccountAtIndex(index);
    }
 
    function getAccounttoken2DividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return token2DividendTracker.getAccountAtIndex(index);
    }
 
	function processDividendTracker(uint256 gas) external onlyOwner {
		(uint256 token1Iterations, uint256 token1Claims, uint256 token1LastProcessedIndex) = token1DividendTracker.process(gas);
		emit Processedtoken1DividendTracker(token1Iterations, token1Claims, token1LastProcessedIndex, false, gas, tx.origin);
 
		(uint256 token2Iterations, uint256 token2Claims, uint256 token2LastProcessedIndex) = token2DividendTracker.process(gas);
		emit Processedtoken2DividendTracker(token2Iterations, token2Claims, token2LastProcessedIndex, false, gas, tx.origin);
    }
 
    function claim() external {
		token1DividendTracker.processAccount(payable(msg.sender), false);
		token2DividendTracker.processAccount(payable(msg.sender), false);
    }
    
    function getLasttoken1DividendProcessedIndex() external view returns(uint256) {
    	return token1DividendTracker.getLastProcessedIndex();
    }
 
    function getLasttoken2DividendProcessedIndex() external view returns(uint256) {
    	return token2DividendTracker.getLastProcessedIndex();
    }
 
    function getNumberOftoken1DividendTokenHolders() external view returns(uint256) {
        return token1DividendTracker.getNumberOfTokenHolders();
    }
 
    function getNumberOftoken2DividendTokenHolders() external view returns(uint256) {
        return token2DividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        if (enableMaxWallet && maxWalletAmount() > 0) {
            if (
                _isExcludedFromMaxWallet[from] == false
                && _isExcludedFromMaxWallet[to] == false &&
                to != uniswapV2Pair
            ) {
                uint balance  = balanceOf(to);
                require(balance + amount <= maxWalletAmount(), "MaxWallet: Transfer amount exceeds the maxWalletAmount");
            }
        }

        if (enableAntiwhale && maxTransferAmount() > 0) {
            if (
                _isExcludedFromAntiWhale[from] == false
                && _isExcludedFromAntiWhale[to] == false
            ) {
                require(amount <= maxTransferAmount(), "AntiWhale: Transfer amount exceeds the maxTransferAmount");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
 
        if (!swapping && canSwap && from != uniswapV2Pair && swapEnabled) {
            swapping = true;
            
            uint256 liqTokensToAdd;
            if (liquidityFeeOnSell > 0) {
                liqTokensToAdd = contractTokenBalance.mul(liquidityFeeOnSell.div(2)).div(sellFee);
                contractTokenBalance -= liqTokensToAdd;
            }
            
            uint initBalance = address(this).balance;
            swapTokensForBNB(contractTokenBalance);
            uint finalBalance = address(this).balance.sub(initBalance);

            uint256 feeBUSD = buybackFeeOnSell.add(charityFeeOnSell).add(marketingFeeOnSell);
            uint256 feeBNB  = sellFee.sub(buybackFeeOnSell).sub(charityFeeOnSell).sub(marketingFeeOnSell).sub(liquidityFeeOnSell.div(2));

            uint256 busdBNB = finalBalance.mul(feeBUSD).div(sellFee.sub(liquidityFeeOnSell.div(2)));
            uint256 restBNB = finalBalance.sub(busdBNB);

            swapTokensForBUSD(busdBNB);
            uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));
            
            if (marketingFeeOnSell > 0) {
                uint256 marketingTokens = busdBalance.div(feeBUSD).mul(marketingFeeOnSell);
                IERC20(BUSD).transfer(marketingWallet, marketingTokens);
            }

            if(buybackFeeOnSell > 0) {
                uint256 buybackTokens = busdBalance.div(feeBUSD).mul(buybackFeeOnSell);
                IERC20(BUSD).transfer(buybackWallet, buybackTokens);
            }

            if(charityFeeOnSell > 0) {
                uint256 charityTokens = busdBalance.div(feeBUSD).mul(charityFeeOnSell);
                IERC20(BUSD).transfer(charityWallet, charityTokens);
            }

            if(liquidityFeeOnSell > 0) {
                uint256 liqTokens = restBNB.mul(liquidityFeeOnSell.div(2)).div(feeBNB);
                addLiquidity(liqTokensToAdd, liqTokens);
            }
 
            if (token1DividendEnabled && token1DividendRewardsFeeOnSell > 0) {
                uint256 token1Tokens = restBNB.div(feeBNB).mul(token1DividendRewardsFeeOnSell);
                swapAndSendtoken1Dividends(token1Tokens);
            }
 
            if (token2DividendEnabled && token2DividendRewardsFeeOnSell > 0) {
                uint256 token2Tokens = restBNB.div(feeBNB).mul(token2DividendRewardsFeeOnSell);
                swapAndSendtoken2Dividends(token2Tokens);
            }
 
                swapping = false;
        }
 
        bool takeFee = !swapping;

        if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(!transferFeeEnabled && from != uniswapV2Pair && to != uniswapV2Pair) {
            takeFee = false;
        }
 
        if(takeFee) {
            uint256 fees;
            if(from == uniswapV2Pair) {
        	    fees = amount.div(100).mul(buyFee);
            } else {
                fees = amount.div(100).mul(sellFee);
            }
        	amount = amount.sub(fees);
 
            super._transfer(from, address(this), fees);
        }
 
        super._transfer(from, to, amount);

        try token1DividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try token2DividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try token1DividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
        try token2DividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;
 
	    	try token1DividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit Processedtoken1DividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {
 
	    	}
 
	    	try token2DividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit Processedtoken2DividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {
 
	    	}
        }
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
 
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadAddress,
            block.timestamp
        );
    }
 
    function swapTokensForBNB(uint256 tokenAmount) private {
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

    function swapTokensForBUSD(uint256 _tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = BUSD;
 
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _tokenAmount}(
            0, // accept any amount of dividend token
            path,
            address(this),
            block.timestamp
        );
    }
 
    function swapTokensForDividendToken(uint256 _tokenAmount, address _recipient, address _dividendAddress) private {
        if(_dividendAddress != address(0)) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = _dividendAddress;
 

 
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _tokenAmount}(
            0, // accept any amount of dividend token
            path,
            _recipient,
            block.timestamp
        );
        } 
    }
 
    function swapAndSendtoken1Dividends(uint256 tokens) private {
        if (token1DividendToken != address(0)) {
          uint init = IERC20(token1DividendToken).balanceOf(address(this));
        swapTokensForDividendToken(tokens, address(this), token1DividendToken);
        uint256 token1Dividends = IERC20(token1DividendToken).balanceOf(address(this)) - init;
        transferDividends(token1DividendToken, address(token1DividendTracker), token1DividendTracker, token1Dividends);
        } else {
              (bool success,) = address(token1DividendTracker).call{value: tokens}("");
 
                if(success) {
                    emit SendDividends(tokens);
                }
        }
    }
 
    function swapAndSendtoken2Dividends(uint256 tokens) private {
        if (token2DividendToken != address(0)) {
              uint init = IERC20(token2DividendToken).balanceOf(address(this));
            swapTokensForDividendToken(tokens, address(this), token2DividendToken);
            uint256 token2Dividends = IERC20(token2DividendToken).balanceOf(address(this)) - init;

            transferDividends(token2DividendToken, address(token2DividendTracker), token2DividendTracker, token2Dividends);
        } else {
          
            (bool success,) = address(token2DividendTracker).call{value: tokens}("");
 
                if(success) {
                    emit SendDividends(tokens);
                }
        }
    }
 
    function transferDividends(address dividendToken, address dividendTracker, DividendPayingToken dividendPayingTracker, uint256 amount) private {
        bool success = IERC20(dividendToken).transfer(dividendTracker, amount);
 
        if (success) {
            dividendPayingTracker.distributeDividends(amount);
            emit SendDividends(amount);
        }
    }

    function burn(uint256 amount) external onlyOwner {
        _transfer(msg.sender, deadAddress, amount);
    }
}

contract DividendPayingToken is ERC20, Ownable, IDividendPayingToken, IDividendPayingTokenOptional {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;
 
  uint256 constant internal magnitude = 2**128;
 
  uint256 internal magnifiedDividendPerShare;
  uint256 internal lastAmount;
 
  address public dividendToken;
 
 
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  mapping(address => bool) _isAuth;
 
  uint256 public totalDividendsDistributed;
 
  modifier onlyAuth() {
    require(_isAuth[msg.sender], "Auth: caller is not the authorized");
    _;
  }
 
  constructor(string memory _name, string memory _symbol, address _token) ERC20(_name, _symbol) {
    dividendToken = _token;
    _isAuth[msg.sender] = true;
  }
 
  function setAuth(address account) external onlyAuth{
      _isAuth[account] = true;
  }

    receive() payable external {
        if(dividendToken == address(0)) {
            distributeDividends(msg.value);
        }
    }
 
  function distributeDividends(uint256 amount) public onlyOwner {
    require(totalSupply() > 0);
 
    if (amount > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (amount).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, amount);
 
      totalDividendsDistributed = totalDividendsDistributed.add(amount);
    }
  }
 
  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }
 
  function setDividendTokenAddress(address newToken) external virtual onlyAuth{
      dividendToken = newToken;
  }
 
  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      if (address(dividendToken) != address(0)) {
        bool success = IERC20(dividendToken).transfer(user, _withdrawableDividend);
    
        if(!success) {
            withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
            return 0;
        }
      } else {
          (bool success,) = payable(user).call{value: _withdrawableDividend, gas: 5000}("");
          if (!success) {
              withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
              return 0;
          }
      }
 
      return _withdrawableDividend;
    }
 
    return 0;
  }
 
 
  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }
 
  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }
 
  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }
 
 
  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }
 
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);
 
    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }
 
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);
 
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }
 
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);
 
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }
 
  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);
 
    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

contract Token1DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;
 
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
 
    mapping (address => bool) public excludedFromDividends;
 
    mapping (address => uint256) public lastClaimTimes;
 
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
 
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
 
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
 
    constructor() DividendPayingToken("EverImpact_Token1_Dividend_Tracker", "EverImpact_Token1_Dividend_Tracker", 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7) {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 5000000000 * (10**18); //must hold 2000000+ tokens
    }

    function _transfer(address, address, uint256) pure internal override {
        require(false, "EverImpact_Token1_Dividend_Tracker: No transfers allowed");
    }
 
    function withdrawDividend() pure public override {
        require(false, "EverImpact_Token1_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main EverImpact contract.");
    }
 
    function setDividendTokenAddress(address newToken) external override onlyOwner {
      dividendToken = newToken;
    }
 
    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance * (10**18);
    }
 
    function excludeFromDividends(address account, bool exclude) external onlyOwner {
      if (exclude = true) {
            require(!excludedFromDividends[account]);
          excludedFromDividends[account] = true;
 
          _setBalance(account, 0);
          tokenHoldersMap.remove(account);
 
          emit ExcludeFromDividends(account);
        } else {
            require(excludedFromDividends[account]);
            excludedFromDividends[account] = false;
                if(balanceOf(account) >= minimumTokenBalanceForDividends) {
                _setBalance(account, balanceOf(account));
    		    tokenHoldersMap.set(account, balanceOf(account));
    	    }
        }
    }
 
    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "EverImpact_Token1_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "EverImpact_Token1_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
 
    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }
 
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
 
 
    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
 
        index = tokenHoldersMap.getIndexOfKey(account);
 
        iterationsUntilProcessed = -1;
 
        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;
 
 
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
 
 
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
 
        lastClaimTime = lastClaimTimes[account];
 
        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;
 
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }
 
    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
 
        address account = tokenHoldersMap.getKeyAtIndex(index);
 
        return getAccount(account);
    }
 
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}
 
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
 
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}
 
    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}
 
    	processAccount(account, true);
    }
 
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
 
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
 
    	uint256 _lastProcessedIndex = lastProcessedIndex;
 
    	uint256 gasUsed = 0;
 
    	uint256 gasLeft = gasleft();
 
    	uint256 iterations = 0;
    	uint256 claims = 0;
 
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;
 
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}
 
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
 
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}
 
    		iterations++;
 
    		uint256 newGasLeft = gasleft();
 
    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
 
    		gasLeft = newGasLeft;
    	}
 
    	lastProcessedIndex = _lastProcessedIndex;
 
    	return (iterations, claims, lastProcessedIndex);
    }
 
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
 
    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
 
    	return false;
    }
}
 
contract Token2DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;
 
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
 
    mapping (address => bool) public excludedFromDividends;
 
    mapping (address => uint256) public lastClaimTimes;
 
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
 
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
 
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
 
    constructor() DividendPayingToken("EverImpact_Token2_Dividend_Tracker", "EverImpact_Token2_Dividend_Tracker", 0x8a9424745056Eb399FD19a0EC26A14316684e274) {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 5000000000 * (10**18); //must hold 2000000+ tokens
    }
 
    function _transfer(address, address, uint256) pure internal override {
        require(false, "EverImpact_Token2_Dividend_Tracker: No transfers allowed");
    }
 
    function withdrawDividend() pure public override {
        require(false, "EverImpact_Token2_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main EverImpact contract.");
    }
 
    function setDividendTokenAddress(address newToken) external override onlyOwner {
      dividendToken = newToken;
    }
 
    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance * (10**18);
    }
 
    function excludeFromDividends(address account, bool exclude) external onlyOwner {
      if (exclude = true) {
            require(!excludedFromDividends[account]);
          excludedFromDividends[account] = true;
 
          _setBalance(account, 0);
          tokenHoldersMap.remove(account);
 
          emit ExcludeFromDividends(account);
        } else {
            require(excludedFromDividends[account]);
            excludedFromDividends[account] = false;
                if(balanceOf(account) >= minimumTokenBalanceForDividends) {
                _setBalance(account, balanceOf(account));
    		    tokenHoldersMap.set(account, balanceOf(account));
    	    }
        }
    }
 
    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "EverImpact_Token2_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "EverImpact_Token2_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
 
    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }
 
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
 
 
    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
 
        index = tokenHoldersMap.getIndexOfKey(account);
 
        iterationsUntilProcessed = -1;
 
        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;
 
 
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
 
 
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
 
        lastClaimTime = lastClaimTimes[account];
 
        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;
 
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }
 
    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
 
        address account = tokenHoldersMap.getKeyAtIndex(index);
 
        return getAccount(account);
    }
 
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}
 
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
 
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}
 
    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}
 
    	processAccount(account, true);
    }
 
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
 
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
 
    	uint256 _lastProcessedIndex = lastProcessedIndex;
 
    	uint256 gasUsed = 0;
 
    	uint256 gasLeft = gasleft();
 
    	uint256 iterations = 0;
    	uint256 claims = 0;
 
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;
 
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}
 
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
 
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}
 
    		iterations++;
 
    		uint256 newGasLeft = gasleft();
 
    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
 
    		gasLeft = newGasLeft;
    	}
 
    	lastProcessedIndex = _lastProcessedIndex;
 
    	return (iterations, claims, lastProcessedIndex);
    }
 
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
 
    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
 
    	return false;
    }
}