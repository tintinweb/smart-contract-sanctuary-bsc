/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: neuraless.com

pragma solidity 0.8.17;


interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    
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

    
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {
    
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    
    
    
    
    

    
    
    
    
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        
        _status = _ENTERED;

        _;

        
        
        _status = _NOT_ENTERED;
    }
}

library EnumerableSet {
    
    
    
    
    
    
    
    

    struct Set {
        
        bytes32[] _values;
        
        
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            
            
            
            

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                
                set._values[toDeleteIndex] = lastValue;
                
                set._indexes[lastValue] = valueIndex; 
            }

            
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
        return set._values[index];
    }

    
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        
        assembly {
            result := store
        }

        return result;
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

    
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        
        assembly {
            result := store
        }

        return result;
    }
}

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            
            
            
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

address payable constant ADDRESS_NULL = payable(address(0));

address payable constant ADDRESS_DEAD = payable(0x000000000000000000000000000000000000dEaD);

address constant ADDRESS_PANCAKE_ROUTER_TEST = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

address constant ADDRESS_PANCAKE_ROUTER_PROD = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

address constant WALLET_NULL = ADDRESS_NULL;

string constant ERROR_TAXRATE_OUT_OF_BOUNDS = "Tax rate must be between bounds.";

string constant ERROR_DISTRATES_MUST_NOT_EXCEED_100 = "Distribution values must not exceed 100%.";

string constant ERROR_DISTRATE_OUT_OF_BOUNDS = "Distribution rate must be between bounds.";

string constant ERROR_LENGTHS_MUST_MATCH = "Lenghts of given arrays must must match.";

string constant ERROR_DISTRIBUTION_COUNT_OVERFLOW = "The maximum count of distribution wallets exceeded.";

string constant ERROR_NOTRANSFER_FROM_NULL = "Cannot transfer from null.";

string constant ERROR_NOTRANSFER_TO_NULL = "Cannot transfer to null.";

string constant ERROR_TRANSFER_SAME_ADDRESS = "Same sender and receiver address.";

string constant ERROR_SELLER_LOCKED = "Seller is locked.";

string constant ERROR_BUYER_LOCKED = "Buyer is locked.";

string constant ERROR_TRANSFERRER_LOCKED = "Transferrer is locked.";

string constant ERROR_SALE_LIMIT_REACHED = "Sale limit reached.";

string constant ERROR_BUY_LIMIT_REACHED = "Buy limit reached.";

string constant ERROR_TRANSFER_EXCEEDS_BALANCE = "Transfer exceeds balance.";

string constant ERROR_BALANCE_LIMIT_REACHED = "Target balance limit reached.";

string constant ERROR_INVALID_TOKEN_STATE_EXEC = "Invalid Token State for this Operation.";

string constant ERROR_INVALID_TOKEN_STATE = "Invalid Token State.";

string constant ERROR_INVALID_TOKEN_TRANSITION = "State must not be entered again.";

string constant ERROR_MUTEX_ENTERED_TWICE = "Mutex entered multiple Times.";

string constant ERROR_REDUCTION_RATE_OUT_OF_BOUNDS = "Reduction Rate must be between 0 and 100.";

string constant ERROR_FALLBACK_MUST_NOT_TAKE_DATA = "Illegal use of Fallback function.";

abstract contract Mutex {
  mapping(uint8 => bool) internal _mutexMap;

  modifier mutex(uint8 id, bool requireCheck) {
    if (requireCheck) {
      require(_mutexMap[id] != true, ERROR_MUTEX_ENTERED_TWICE);
    }
    _mutexMap[id] = true;
    _;
    _mutexMap[id] = false;
  }

  function isInsideMutex(uint8 id) public view returns(bool) {
    return _mutexMap[id];
  }
}

uint8 constant STATE_LAUNCH = 0x01;

uint8 constant STATE_PRESALE = 0x02;

uint8 constant STATE_PUBLIC = 0x04;

uint8 constant STATE_MIGRATE = 0x64;

uint8 constant ALL_STATES = STATE_LAUNCH | STATE_PRESALE | STATE_PUBLIC | STATE_MIGRATE;

contract StateVerified {
  event StateChange(uint8 from, uint8 to);

  uint8 internal _state;

  modifier allowStates(uint8 states) {
    require(states & _state == _state, ERROR_INVALID_TOKEN_STATE_EXEC);
    _;
  }

  function setState(uint8 state) public virtual {
    
    require(ALL_STATES & state == state, ERROR_INVALID_TOKEN_STATE);

    
    
    require(!(state == STATE_LAUNCH && _state > STATE_LAUNCH), ERROR_INVALID_TOKEN_TRANSITION);
    require(!(state == STATE_PRESALE && _state > STATE_PRESALE), ERROR_INVALID_TOKEN_TRANSITION);

    emit StateChange(_state, state);
    _state = state;
  }

  function getState() public view returns (uint8) {
    return _state;
  }
}

enum RatesIndex {
  CIRCULATION,
  TAX_BUY,
  TAX_SALE,
  TAX_TRANSFER,
  SWAP,
  DIST_BURN,
  DIST_LIQUIDITY
}

abstract contract TaxableToken is
  ERC20,
  ERC20Burnable,
  Ownable,
  ReentrancyGuard,
  Mutex,
  StateVerified
{
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeMath for uint256;

  uint8 private constant MUTEX_SWAP = 0;

  uint256 private constant DISTRIBUTION_MULTIPLIER = 2**64;

  uint8 public constant BALANCE_LIMIT_PERCENTAGE = 3;
  uint8 public constant SALE_LIMIT_PERCENTAGE = 1;
  uint8 public constant BUY_LIMIT_PERCENTAGE = 1;

  uint256 private immutable amountSwapLimit;
  uint256 private immutable amountInitialSupply;

  IUniswapV2Router02 internal immutable router;

  address payable internal immutable walletThis;
  address payable internal immutable walletRouter;
  address payable internal immutable walletRouterPair;

  uint256 public claimedLiquidity = 0;

  uint256 public balanceLimit = 0;
  uint256 public saleLimit = 0;
  uint256 public buyLimit = 0;

  uint256 public saleLockDuration = 0;
  uint256 public buyLockDuration = 0;

  
  uint8[2] public taxBounds = [0, 25];
  uint8 public taxRateBuy = 10;
  uint8 public taxRateSale = 15;
  uint8 public taxRateTransfer = 10;

  
  uint8[2] public distBounds = [0, 50];
  uint8 public distRateBurn = 40;
  uint8 public distRateLiquidity = 20;
  uint8[] public distRates;
  address payable[] public distWallets;

  uint256 public totalPayouts;

  bool private _skipLengthCheck = false;

  EnumerableSet.AddressSet private _exclusionsTax;
  EnumerableSet.AddressSet private _exclusionsSaleLock;
  EnumerableSet.AddressSet private _exclusionsBuyLock;

  uint256 public totalAddedLiquidityETH = 0;

  bool public autoLiquidity = true;

  mapping(address => uint256) private _saleLock;
  mapping(address => uint256) private _buyLock;

  event ClaimedForLiquidity(address from, uint256 value);
  event Received(address sender);
  event SetAutoLiquidity(bool value);
  event SetRate(string identifier, uint8 value);
  event SwappedAndLiquidified(
    uint256 swapped,
    uint256 liquidity,
    uint256 amountBNB
  );
  event TaxedBuy(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TaxedSale(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TaxedTransfer(
    uint8 tax,
    address indexed from,
    address indexed to,
    uint value
  );
  event TokenCreated(address indexed owner, address indexed token);

  receive() external payable {
    emit Received(msg.sender);
  }

  fallback() external payable {
    
    require(msg.data.length == 0, ERROR_FALLBACK_MUST_NOT_TAKE_DATA);
  }

  
  constructor(
    string memory tokenname,
    string memory tokensymbol,
    uint256 supplyInitial,
    uint8[] memory _rates,
    uint8[] memory _distRates,
    address payable[] memory _distWallets,
    address swapRouter
  ) ERC20(tokenname, tokensymbol) {
    _mint(msg.sender, supplyInitial.mul(10**decimals()));

    taxRateBuy = _rates[uint(RatesIndex.TAX_BUY)];
    taxRateSale = _rates[uint(RatesIndex.TAX_SALE)];
    taxRateTransfer = _rates[uint(RatesIndex.TAX_TRANSFER)];
    distRateBurn = _rates[uint(RatesIndex.DIST_BURN)];
    distRateLiquidity = _rates[uint(RatesIndex.DIST_LIQUIDITY)];
    distRates = _distRates;
    distWallets = _distWallets;

    uint256 initialSupply = totalSupply();

    IUniswapV2Router02 r = IUniswapV2Router02(swapRouter);
    IUniswapV2Factory pcFactory = IUniswapV2Factory(r.factory());

    balanceLimit = initialSupply.mul(BALANCE_LIMIT_PERCENTAGE).div(10**2);
    saleLimit = initialSupply.mul(SALE_LIMIT_PERCENTAGE).div(10**2);
    buyLimit = initialSupply.mul(BUY_LIMIT_PERCENTAGE).div(10**2);

    
    amountInitialSupply = initialSupply;
    amountSwapLimit = amountInitialSupply
      .mul(_rates[uint(RatesIndex.SWAP)])
      .div(10**4);

    router = r;

    address wthis = payable(address(this));
    walletThis = payable(wthis);
    walletRouter = payable(address(r));
    walletRouterPair = payable(pcFactory.createPair(wthis, r.WETH()));

    _exclusionsTax.add(wthis);
    _exclusionsTax.add(owner());
    _exclusionsTax.add(msg.sender);
    _excludeTaxDistributionWallets();

    transfer(
      wthis,
      totalSupply().mul(_rates[uint(RatesIndex.CIRCULATION)]).div(10**2)
    );

    setState(STATE_LAUNCH);

    approve(walletRouter, totalSupply());

    emit TokenCreated(owner(), wthis);
  }

  

  

  
  function transferOwnership(address newOwner)
    public
    override
    onlyOwner
    allowStates(STATE_MIGRATE)
  {
    _exclusionsTax.remove(owner());
    _exclusionsTax.add(newOwner);
    super.transferOwnership(newOwner);
  }

  

  

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override allowStates(STATE_PRESALE | STATE_PUBLIC) {
    require(from != ADDRESS_NULL, ERROR_NOTRANSFER_FROM_NULL);
    require(to != ADDRESS_NULL, ERROR_NOTRANSFER_TO_NULL);
    require(balanceOf(from) >= amount, ERROR_TRANSFER_EXCEEDS_BALANCE);

    if (_isUntaxedTransfer(from, to) || _state == STATE_PRESALE) {
      _transferUntaxed(from, to, amount);
    } else {
      _transferTaxed(from, to, amount);
    }
  }

  
  function _transferTaxed(
    address from,
    address to,
    uint256 value
  ) internal {
    bool isSale = _isSale(to);
    bool isBuy = _isBuy(from);

    
    _checkLimits(from, to, value, isSale, isBuy);

    
    _handleTransferLocks(from, to, isSale, isBuy);

    uint8 taxRate = _getTargetTaxRate(from, to);

    if (isBuy) {
      emit TaxedBuy(taxRate, from, to, value);
    } else if (isSale) {
      emit TaxedSale(taxRate, from, to, value);
    } else {
      emit TaxedTransfer(taxRate, from, to, value);
    }

    if (
      (from != walletRouterPair) &&
      (autoLiquidity) &&
      (!isInsideMutex(MUTEX_SWAP)) &&
      isSale
    ) {
      _swapAndLiquify();
    }

    uint256 netAmount = value;
    uint256 taxAmount = 0;
    (netAmount, taxAmount) = _reduceAmount(netAmount, taxRate);

    _distributeTaxValues(from, taxAmount);

    super._transfer(from, to, netAmount);
  }

  function _checkLimits(
    address from,
    address to,
    uint256 value,
    bool isSale,
    bool isBuy
  ) internal view {
    uint256 toBalance = balanceOf(to);
    uint256 fromBalance = balanceOf(from);

    require(fromBalance >= value, ERROR_TRANSFER_EXCEEDS_BALANCE);

    if (isSale) {
      require(value <= saleLimit, ERROR_SALE_LIMIT_REACHED);
    } else if (isBuy) {
      require(value <= buyLimit, ERROR_BUY_LIMIT_REACHED);
      require(
        toBalance.add(value) <= balanceLimit,
        ERROR_BALANCE_LIMIT_REACHED
      );
    } else {
      
      require(
        toBalance.add(value) <= balanceLimit,
        ERROR_BALANCE_LIMIT_REACHED
      );
    }
  }

  function _handleTransferLocks(
    address from,
    address to,
    bool isSale,
    bool isBuy
  ) internal {
    if (isBuy) {
      
      if (buyLockDuration > 0 && !isExcludedFromBuyLock(to)) {
        require(_buyLock[to] <= block.timestamp, ERROR_BUYER_LOCKED);
        _buyLock[to] = block.timestamp.add(buyLockDuration);
      }
    } else {
      
      
      if (saleLockDuration > 0 && !isExcludedFromSaleLock(from)) {
        require(_saleLock[from] <= block.timestamp, ERROR_SELLER_LOCKED);

        
        if (isSale) {
          _saleLock[from] = block.timestamp.add(saleLockDuration);
        }
      }
    }
  }

  function _transferUntaxed(
    address from,
    address to,
    uint256 value
  ) internal {
    super._transfer(from, to, value);
  }

  
  function getInitialSupply() external view returns (uint256) {
    return amountInitialSupply;
  }

  function getCirculationAmount() public view returns (uint256) {
    return balanceOf(walletThis).sub(claimedLiquidity);
  }

  function getCirculationRate() public view returns (uint256) {
    return getCirculationAmount().mul(10**2).div(totalSupply());
  }

  function setSaleLockDuration(uint256 duration) public onlyOwner {
    saleLockDuration = duration;
  }

  function setBuyLockDuration(uint256 duration) public onlyOwner {
    buyLockDuration = duration;
  }

  
  function setAutoLiquidity(bool _autoLiquidity) external onlyOwner {
    autoLiquidity = _autoLiquidity;
    emit SetAutoLiquidity(autoLiquidity);
  }

  function claimLiquidity(uint256 value) external onlyOwner {
    super._transfer(_msgSender(), walletThis, value);
    claimedLiquidity = claimedLiquidity.add(value);
    emit ClaimedForLiquidity(_msgSender(), value);
  }

  function _swapAndLiquify() internal mutex(MUTEX_SWAP, true) {
    
    
    if (claimedLiquidity < amountSwapLimit || distRateLiquidity == 0) {
      return;
    }

    
    uint256 half4Liq = amountSwapLimit.div(2);
    uint256 half4BNB = amountSwapLimit.sub(half4Liq);

    
    uint256 initialBNBBalance = walletThis.balance;

    
    _swapTokenForETH(half4BNB);

    
    uint256 deltaBNB = (walletThis.balance.sub(initialBNBBalance));

    _addLiquidity(half4Liq, deltaBNB);

    claimedLiquidity = claimedLiquidity.sub(amountSwapLimit);

    emit SwappedAndLiquidified(half4BNB, half4Liq, deltaBNB);
  }

  
  function _swapTokenForETH(uint256 tokenAmount) internal {
    address[] memory path = new address[](2);
    path[0] = walletThis;
    path[1] = router.WETH();

    
    _approve(walletThis, walletRouter, tokenAmount);

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      walletThis,
      block.timestamp
    );
  }

  
  function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
    totalAddedLiquidityETH += ethAmount;

    
    _approve(walletThis, walletRouter, tokenAmount);

    
    router.addLiquidityETH{value: ethAmount}(
      walletThis,
      tokenAmount,
      0,
      0,
      walletThis,
      block.timestamp
    );
  }

  

  
  
  function setTaxRateBuy(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    
    require(
      value >= taxBounds[0] && (taxRateSale + value) <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateBuy = value;
    emit SetRate("TaxBuy", value);
  }

  
  function setTaxRateSale(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    
    require(
      value >= taxBounds[0] && (taxRateBuy + value) <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateSale = value;
    emit SetRate("TaxSale", value);
  }

  
  function setTaxRateTransfer(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= taxBounds[0] && value <= taxBounds[1],
      ERROR_TAXRATE_OUT_OF_BOUNDS
    );
    taxRateTransfer = value;
    emit SetRate("TaxTransfer", value);
  }

  
  function setDistRateBurn(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= distBounds[0] && value <= distBounds[1],
      ERROR_DISTRATE_OUT_OF_BOUNDS
    );
    distRateBurn = value;
    _requireDistRatesLimit();
    emit SetRate("DistBurn", value);
  }

  
  function setDistRateLiquidity(uint8 value)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(
      value >= distBounds[0] && value <= distBounds[1],
      ERROR_DISTRATE_OUT_OF_BOUNDS
    );
    distRateLiquidity = value;
    _requireDistRatesLimit();
    emit SetRate("DistLiquidity", value);
  }

  
  function setDistRates(uint8[] memory rates)
    public
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(rates.length <= 10, ERROR_DISTRIBUTION_COUNT_OVERFLOW);
    if (!_skipLengthCheck) {
      require(distWallets.length == rates.length, ERROR_LENGTHS_MUST_MATCH);
    }
    distRates = rates;
    _requireDistRatesLimit();
    for (uint8 i = 0; i < rates.length; i++) {
      emit SetRate("DistTeamWallet", rates[i]);
    }
  }

  function _requireDistRatesLimit() private view {
    
    uint16 total = 0;
    for (uint8 i = 0; i < distRates.length; i++) {
      total += distRates[i];
    }

    total += (distRateBurn + distRateLiquidity);

    require(total <= 100, ERROR_DISTRATES_MUST_NOT_EXCEED_100);
  }

  function getDistributedValue(address wallet) public view returns (uint256) {
    return allowance(walletThis, wallet);
  }

  
  function addTaxExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsTax.add(wallet);
  }

  function removeTaxExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsTax.remove(wallet);
  }

  function addSaleLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsSaleLock.add(wallet);
  }

  function removeSaleLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsSaleLock.remove(wallet);
  }

  function addBuyLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsBuyLock.add(wallet);
  }

  function removeBuyLockExcludedWallet(address wallet)
    external
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    _exclusionsBuyLock.remove(wallet);
  }

  function setTaxDistributionWallets(address payable[] memory wallets)
    public
    onlyOwner
    allowStates(STATE_PUBLIC)
  {
    require(wallets.length <= 10, ERROR_DISTRIBUTION_COUNT_OVERFLOW);
    if (!_skipLengthCheck) {
      require(distRates.length == wallets.length, ERROR_LENGTHS_MUST_MATCH);
    }
    _removeTaxDistributionWalletExclusions();
    distWallets = wallets;
    _excludeTaxDistributionWallets();
  }

  function setTaxDistributions(
    address payable[] memory wallets,
    uint8[] memory rates
  ) external onlyOwner allowStates(STATE_PUBLIC) {
    require(wallets.length == rates.length, ERROR_LENGTHS_MUST_MATCH);

    _skipLengthCheck = true;
    setTaxDistributionWallets(wallets);
    setDistRates(rates);
    _skipLengthCheck = false;
  }

  function getRouterWallet() public view returns (address) {
    return walletRouter;
  }

  function getRouterPairWallet() public view returns (address) {
    return walletRouterPair;
  }

  
  function setState(uint8 state) public override onlyOwner {
    super.setState(state);
  }

  

  
  function _isUntaxedTransfer(address from, address to)
    internal
    view
    returns (bool)
  {
    
    
    
    
    

    bool isExcluded = (isExcludedFromTax(from) || isExcludedFromTax(to));
    bool isLiquidityTx = ((to == walletRouterPair && from == walletRouter) ||
      (to == walletRouterPair && from == walletRouter));

    if (isExcluded || isLiquidityTx) {
      return true;
    }

    return false;
  }

  
  function isExcludedFromTax(address wallet) public view returns (bool) {
    return _exclusionsTax.contains(wallet);
  }

  function isExcludedFromBuyLock(address wallet) public view returns (bool) {
    return _exclusionsBuyLock.contains(wallet);
  }

  function isExcludedFromSaleLock(address wallet) public view returns (bool) {
    return _exclusionsSaleLock.contains(wallet);
  }

  function _isBuy(address from) internal view returns (bool) {
    return (from == walletRouterPair || from == walletRouter);
  }

  function _isSale(address to) internal view returns (bool) {
    return (to == walletRouterPair || to == walletRouter);
  }

  
  function _getTargetTaxRate(address from, address to)
    internal
    view
    returns (uint8)
  {
    require(from != to, ERROR_TRANSFER_SAME_ADDRESS);
    require(from != ADDRESS_NULL, ERROR_NOTRANSFER_FROM_NULL);
    require(to != ADDRESS_NULL, ERROR_NOTRANSFER_TO_NULL);

    uint8 state = getState();
    if (
      state == STATE_PRESALE || isExcludedFromTax(from) || isExcludedFromTax(to)
    ) {
      return 0;
    }

    if (_isBuy(from)) {
      return taxRateBuy;
    } else if (_isSale(to)) {
      return taxRateSale;
    } else {
      return taxRateTransfer;
    }
  }

  
  function _reduceAmount(uint256 amount, uint8 reductionRate)
    internal
    pure
    returns (uint256 reducedAmount, uint256 reductionAmount)
  {
    require(
      amount >= 0 && reductionRate >= 0 && reductionRate <= 100,
      ERROR_REDUCTION_RATE_OUT_OF_BOUNDS
    );

    if (reductionRate > 0) {
      reducedAmount = amount.mul(100 - reductionRate).div(100);
      reductionAmount = amount.sub(reducedAmount);
    } else {
      reducedAmount = amount;
      reductionAmount = 0;
    }
  }

  
  function _distributeTaxValues(address from, uint256 taxValue) internal {
    uint256 transferValue = taxValue;

    
    uint256 burnValue = 0;
    (, burnValue) = _reduceAmount(taxValue, distRateBurn);
    super._burn(from, burnValue);
    transferValue -= burnValue;

    
    uint256 liqValue = 0;
    (, liqValue) = _reduceAmount(taxValue, distRateLiquidity);
    _claimLiquidity(from, liqValue);
    transferValue -= liqValue;

    
    super._transfer(from, walletThis, transferValue);

    
    for (uint i = 0; i < distWallets.length; i++) {
      uint256 part = 0;
      (, part) = _reduceAmount(taxValue, distRates[i]);
      _approve(
        walletThis,
        distWallets[i],
        allowance(walletThis, distWallets[i]).add(part)
      );
    }
  }

  function _claimLiquidity(address from, uint256 value) internal {
    _transfer(from, walletThis, value);
    claimedLiquidity = claimedLiquidity.add(value);

    emit ClaimedForLiquidity(from, value);
  }

  function _excludeTaxDistributionWallets() internal {
    for (uint256 i = 0; i < distWallets.length; i++) {
      _exclusionsTax.add(distWallets[i]);
    }
  }

  function _removeTaxDistributionWalletExclusions() internal {
    for (uint256 i = 0; i < distWallets.length; i++) {
      _exclusionsTax.remove(distWallets[i]);
    }
  }

  
}

uint256 constant SUPPLY_INITIAL = 100000000000;

uint8 constant TAX_RATE_BUY = 10;

uint8 constant TAX_RATE_SALE = 15;

uint8 constant TAX_RATE_TRANSFER = 10;

uint8 constant RATE_SWAP = 25;

uint8 constant DIST_RATE_BURN = 40;

uint8 constant DIST_RATE_LIQUIDITY = 20;

uint8 constant DIST_RATE_1 = 20;

uint8 constant DIST_RATE_2 = 10;

uint8 constant DIST_RATE_3 = 5;

uint8 constant DIST_RATE_4 = 5;

uint8 constant RATE_CIRCULATION = 30;

string constant TOKENNAME = "Neuraless";

string constant TOKENSYMBOL = "NRLS";

contract NRLS is TaxableToken {
  uint8[] private DIST_RATES = [DIST_RATE_1, DIST_RATE_2, DIST_RATE_3, DIST_RATE_4];
  uint8[] private RATES = [RATE_CIRCULATION, TAX_RATE_BUY, TAX_RATE_SALE, TAX_RATE_TRANSFER, RATE_SWAP, DIST_RATE_BURN, DIST_RATE_LIQUIDITY];

  
  address payable[] private DIST_WALLETS = [
    payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8)),
    payable(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)),
    payable(address(0x90F79bf6EB2c4f870365E785982E1f101E93b906)),
    payable(address(0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65))
  ];

  constructor()
    TaxableToken(
      TOKENNAME,
      TOKENSYMBOL,
      SUPPLY_INITIAL,
      RATES,
      DIST_RATES,
      DIST_WALLETS,
      ADDRESS_PANCAKE_ROUTER_PROD
    )
  {}
}

contract NRLSTestnet is TaxableToken {
  uint8[] private RATES = [RATE_CIRCULATION, TAX_RATE_BUY, TAX_RATE_SALE, TAX_RATE_TRANSFER, RATE_SWAP, DIST_RATE_BURN, DIST_RATE_LIQUIDITY];
  uint8[] private DIST_RATES = [DIST_RATE_1, DIST_RATE_2, DIST_RATE_3, DIST_RATE_4];

  address payable[] private DIST_WALLETS = [
    payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8)),
    payable(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)),
    payable(address(0x90F79bf6EB2c4f870365E785982E1f101E93b906)),
    payable(address(0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65))
  ];

  constructor()
    TaxableToken(
      TOKENNAME,
      TOKENSYMBOL,
      SUPPLY_INITIAL,
      RATES,
      DIST_RATES,
      DIST_WALLETS,
      ADDRESS_PANCAKE_ROUTER_TEST
    )
  {}
}