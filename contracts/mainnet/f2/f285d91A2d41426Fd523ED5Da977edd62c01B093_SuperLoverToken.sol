/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


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

contract UsdtWrap {
    IERC20 public token520;
    IERC20 public usdt;

    constructor (IERC20 _token520)  {
        token520 = _token520;
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token520), usdtBalance);
        }
        uint256 token520Balance = token520.balanceOf(address(this));
        if (token520Balance > 0) {
            token520.transfer(address(token520), token520Balance);
        }
    }
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

    event Creation(address indexed sender, uint amount0, uint amount1);
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

    function creation(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

  
    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

  
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }


    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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


    function _creation(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: creation to the zero address");

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


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract DividendPayingToken is ERC20, Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;

  address public USDT;


  uint256 internal magnifiedDividendPerShareUSDT;
  mapping(address => int256) internal magnifiedDividendCorrectionsUSDT;
  mapping(address => uint256) internal withdrawnDividendsUSDT;
  uint256 public totalDividendsDistributedUSDT;

  constructor(string memory _name, string memory _symbol, address _usdt) ERC20(_name, _symbol) {
        USDT = _usdt;
  }

  function distributeCAKEDividends(uint256 usdt_amount) public onlyOwner{
    require(totalSupply() > 0);
    if (usdt_amount > 0) {
      magnifiedDividendPerShareUSDT = magnifiedDividendPerShareUSDT.add(
        (usdt_amount).mul(magnitude) / totalSupply()
      );

      totalDividendsDistributedUSDT = totalDividendsDistributedUSDT.add(usdt_amount);
    }

  }

  function withdrawDividend() public virtual {
    _withdrawDividendOfUser(payable(msg.sender));
  }


 function _withdrawDividendOfUser(address payable user) internal returns (bool) {
    uint256 _withdrawableDividendUSDT = withdrawableDividendOfUSDT(user);
    if (_withdrawableDividendUSDT > 0) {
      withdrawnDividendsUSDT[user] = withdrawnDividendsUSDT[user].add(_withdrawableDividendUSDT);
      bool success = IERC20(USDT).transfer(user, _withdrawableDividendUSDT);
      if(!success) {
        withdrawnDividendsUSDT[user] = withdrawnDividendsUSDT[user].sub(_withdrawableDividendUSDT);
      }
    }
    return _withdrawableDividendUSDT > 0 ;
  }


  function dividendOfUSDT(address _owner) public view returns(uint256) {
    return withdrawableDividendOfUSDT(_owner);
  }

  function withdrawableDividendOfUSDT(address _owner) public view returns(uint256) {
    return accumulativeDividendOfUSDT(_owner).sub(withdrawnDividendsUSDT[_owner]);
  }


  function withdrawnDividendOfUSDT(address _owner) public view returns(uint256) {
    return withdrawnDividendsUSDT[_owner];
  }


  function accumulativeDividendOfUSDT(address _owner) public view returns(uint256) {
    return magnifiedDividendPerShareUSDT.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrectionsUSDT[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrectionUSDT = magnifiedDividendPerShareUSDT.mul(value).toInt256Safe();
    magnifiedDividendCorrectionsUSDT[from] = magnifiedDividendCorrectionsUSDT[from].add(_magCorrectionUSDT);
    magnifiedDividendCorrectionsUSDT[to] = magnifiedDividendCorrectionsUSDT[to].sub(_magCorrectionUSDT);


  }

  function _creation(address account, uint256 value) internal override {
    super._creation(account, value);

    magnifiedDividendCorrectionsUSDT[account] = magnifiedDividendCorrectionsUSDT[account]
      .sub( (magnifiedDividendPerShareUSDT.mul(value)).toInt256Safe() );

  }


  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrectionsUSDT[account] = magnifiedDividendCorrectionsUSDT[account]
      .add( (magnifiedDividendPerShareUSDT.mul(value)).toInt256Safe() );

  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if(newBalance > currentBalance) {
      uint256 creationAmount = newBalance.sub(currentBalance);
      _creation(account, creationAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

contract TokenDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct MAP {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    MAP private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(address _usdt,  uint256 _minimumTokenBalanceForDividends) DividendPayingToken("Dividen_Tracker", "Dividen_Tracker", _usdt ) {
        claimWait = 3600;
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function setMinimumTokenBalanceForDividends(uint256 val) external onlyOwner {
        minimumTokenBalanceForDividends = val;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        MAPRemove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "BTCHERO_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "BTCHERO_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function isExcludedFromDividends(address account) public view returns (bool){
        return excludedFromDividends[account];
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
            MAPSet(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            MAPRemove(account);
        }

        processAccount(account);
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
                if(processAccount(payable(account))) {
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

    function processAccount(address payable account) public onlyOwner returns (bool) {
        bool claimed =  _withdrawDividendOfUser(account);
        if(claimed) lastClaimTimes[account] = block.timestamp;
        return true;
    }

    function MAPGet(address key) public view returns (uint) {
        return tokenHoldersMap.values[key];
    }
    function MAPGetIndexOfKey(address key) public view returns (int) {
        if(!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int(tokenHoldersMap.indexOf[key]);
    }
    function MAPGetKeyAtIndex(uint index) public view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function MAPSize() public view returns (uint) {
        return tokenHoldersMap.keys.length;
    }

    function MAPSet(address key, uint val) public {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function MAPRemove(address key) public {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint index = tokenHoldersMap.indexOf[key];
        uint lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }
}

contract SuperLoverToken is ERC20, Ownable {
    using SafeMath for uint256;
    
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public  uniswapV2Pair;

    bool private swapping = false;
    bool public swapAndLiquifyEnabled = true;
    TokenDividendTracker public dividendTracker;
    
    UsdtWrap RECV;
    
    string private name_ = "SuperLover";
    string private symbol_ = "SuperLover";
    uint256 private totalSupply_ = 10E24 * (10**18);
    uint256 public swapTokensAtAmount = totalSupply_.mul(2).div(10**6);

    uint256 private USDTBonusFee = 2;
    uint256 private liquidityFee = 1;
    uint256 private marketingFee = 1;
    uint256 private deadFee = 1;
    uint256 private A = 5 ;
    uint256 public transferBurnAmount = 0;
    uint160 public ktNum = 171;
    
    uint256 public genesisBlock;
    uint256 public coolBlock = 9;
    uint160 public constant MAXADD = ~uint160(0);

    // uint256 public intervalTime = 60;
    uint256 public minimumTokenBalanceForDividends = 10E22* (10**18);



    address public USDT = 0x55d398326f99059fF775485246999027B3197955;


    uint256 public AmountUSDTBonusCurrent;
    uint256 public AmountLiquidityCurrent;
    uint256 public AmountMarketingCurrent;

    address private marketingWalletAddress = 0xB87a5ab84184CB7d3602dFACd65436021Bf01802;
    address private teamWalletAddress = 0xB87a5ab84184CB7d3602dFACd65436021Bf01802;
    address private liquidityReceiver;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public gasForProcessing = 300000;
    // mapping (address => uint256) public lastBuyTime;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => uint256) public burnFromAnt;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public ammPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() payable ERC20(name_, symbol_)  {

        dividendTracker = new TokenDividendTracker(USDT,  minimumTokenBalanceForDividends);
        
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(USDT)));
        IUniswapV2Pair uniswapV2PairBNB = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()));
        ammPairs[address(uniswapV2Pair)] = true;
        ammPairs[address(uniswapV2PairBNB)] = true;


        RECV = new UsdtWrap(IERC20(address(this)));
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address (uniswapV2Pair));
        dividendTracker.excludeFromDividends(address (uniswapV2PairBNB));

        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(liquidityReceiver, true); 
        
        _creation(owner(), totalSupply_);
    }

    receive() external payable {}

    function updateMinimumTokenBalanceForDividends(uint256 val) public onlyOwner {
        minimumTokenBalanceForDividends = val;
        dividendTracker.setMinimumTokenBalanceForDividends(val);
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
    


    function setMarketingWallet(address payable wallet) external onlyOwner{
        marketingWalletAddress = wallet;
    }
    
    function setA(uint256 newValue) public onlyOwner {
        A = newValue;
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setTeamWallet(address payable wallet) external onlyOwner{
        teamWalletAddress = wallet;
    }
    
    function setLiquidityReceiver(address payable newWallet) external onlyOwner{
        liquidityReceiver = newWallet;
    }
    

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setCoolBlock(uint256 _coolBlock) external onlyOwner() {
        coolBlock = _coolBlock;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 300000 && newValue <= 700000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function isExcludedFromDividends(address account) public view returns (bool) {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender));
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

      if( uniswapV2Pair.totalSupply() > 0 && balanceOf(address(this)) > balanceOf(address(uniswapV2Pair)).div(10000) && to == address(uniswapV2Pair)){

        if( !swapping &&
            !ammPairs[from] &&from != owner() &&to != owner()&& !(from == address(uniswapV2Router) && !ammPairs[to])&& swapAndLiquifyEnabled
        ) {
            swapping = true;
            if(AmountUSDTBonusCurrent >= swapTokensAtAmount  && dividendTracker.totalSupply() > 0) swapAndSendDividends();
            if(AmountMarketingCurrent >= swapTokensAtAmount) swapAndSendToFee();
            if(AmountLiquidityCurrent.div(2) >= swapTokensAtAmount) swapAndLiquify();
            swapping = false;
        }
    }    
        if(ammPairs[to]&& balanceOf(address(uniswapV2Pair)) == 0){
            genesisBlock = block.number;
        }
        
        if(ammPairs[from] && block.number < genesisBlock + coolBlock){
              burnFromAnt[to] += amount;
        }
              
        if(burnFromAnt[from] > 0){
            uint theAmount = burnFromAnt[from];
            burnFromAnt[from] = 0;
            super._transfer(from, deadWallet, theAmount);
        }
         

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
            
        if(takeFee) {
            uint256 _LiquidityFee;
            uint256 _USDTBonusFee;
            uint256 _MarketingFee;
            uint256 _DeadFee;
            if(ammPairs[from]){
                _LiquidityFee = amount.mul(liquidityFee).div(100);
                _USDTBonusFee = amount.mul(USDTBonusFee).div(200);
                _MarketingFee = amount.mul(marketingFee).div(50);
                _DeadFee = amount.mul(deadFee).div(100);
                _takeInviterFeeKt(amount.div(10000)); //0.01%空投

                amount = amount.sub(_LiquidityFee).sub(_USDTBonusFee).sub(_MarketingFee).sub(_DeadFee);

            }else if(ammPairs[to]){
 
                _LiquidityFee = amount.mul(liquidityFee).div(100);
                _USDTBonusFee = amount.mul(USDTBonusFee).div(200);
                _MarketingFee = amount.mul(marketingFee).div(50);
                _DeadFee = amount.mul(deadFee).div(100);
                 _takeInviterFeeKt(amount.div(10000)); //0.01%空投
                amount = amount.sub(_LiquidityFee).sub(_USDTBonusFee).sub(_MarketingFee).sub(_DeadFee);
            }else{
                    transferBurnAmount = amount.mul(A).div(100);
                    amount = amount.sub(transferBurnAmount);
                }
  
            if(_LiquidityFee > 0 || _USDTBonusFee > 0 || _MarketingFee > 0) 
            
            super._transfer(from, address(this), _LiquidityFee.add(_MarketingFee).add(_USDTBonusFee));
             AmountMarketingCurrent = AmountMarketingCurrent.add(_MarketingFee);
             AmountLiquidityCurrent = AmountLiquidityCurrent.add(_LiquidityFee);
             AmountUSDTBonusCurrent = AmountUSDTBonusCurrent.add(_USDTBonusFee);
        
            if(_DeadFee > 0) super._transfer(from, deadWallet, _DeadFee);
            if(transferBurnAmount > 0) super._transfer(from, deadWallet, transferBurnAmount);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {
            }
        }
    }
    
    function _takeInviterFeeKt(
        uint256 amount
    ) private { 
        address _receiveD;
        for (uint160 i = 2; i < 7; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            super._transfer(address(this), _receiveD, amount.div(100*i));
        }
    }
       function swapAndSendToFee() private  {
        swapTokensForUSDT(AmountMarketingCurrent); 
        payable(marketingWalletAddress).transfer(address(this).balance.mul(2).div(3));
        payable(teamWalletAddress).transfer(address(this).balance.div(3));
        AmountMarketingCurrent = 0;
    }
        
        function swapAndLiquify() private {
       // split the contract balance into halves
        uint256 half = AmountLiquidityCurrent.div(2);
        uint256 otherHalf = AmountLiquidityCurrent.sub(half);
        uint256 initialBalance = address(this).balance;
        // swap tokens for ETH
        swapTokensForUSDT(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
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
            liquidityReceiver,
            block.timestamp
        );
    }


    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(RECV),
            block.timestamp
        );

        RECV.withdraw();
    }



    function swapAndSendDividends() private{
        swapTokensForUSDT(AmountUSDTBonusCurrent);
        AmountUSDTBonusCurrent = 0;

        uint256 USDT_AMOUNT = IERC20(USDT).balanceOf(address(this));
 
        bool usdt_success = IERC20(USDT).transfer(address(dividendTracker), USDT_AMOUNT);

        if (usdt_success ) {
            dividendTracker.distributeCAKEDividends(USDT_AMOUNT);
        }
    }
}