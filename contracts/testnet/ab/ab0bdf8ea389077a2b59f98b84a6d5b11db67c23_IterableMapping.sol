/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
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

pragma solidity >=0.6.0 <0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

pragma solidity >=0.6.2;

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
// File: contracts/IUniswapV2Router02.sol

pragma solidity >=0.6.2;

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
// File: contracts/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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
// File: contracts/IterableMapping.sol

pragma solidity ^0.7.6;

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

pragma solidity ^0.7.6;
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

pragma solidity ^0.7.6;

interface IDividendPayingTokenOptional {
  function withdrawableDividendOf(address _owner) external view returns(uint256);
  function withdrawnDividendOf(address _owner) external view returns(uint256);
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}

pragma solidity ^0.7.6;

interface IDividendPayingToken {
  function dividendOf(address _owner) external view returns(uint256);
  function distributeDividends() external payable;
  function withdrawDividend() external;

  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount,
    address indexed tokenWithdrawn
  );
}

pragma solidity ^0.7.6;

library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
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

pragma solidity ^0.7.6;

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
pragma solidity ^0.7.6;
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
pragma solidity ^0.7.6;

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
pragma solidity ^0.7.6;
contract DividendPayingToken is ERC20, IDividendPayingToken, IDividendPayingTokenOptional {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;
  uint256 internal lastAmount;
  
  address public DividendToken = address(0);
  address public masterContract;

    modifier onlyMaster() {
            require(masterContract == msg.sender, "Ownable: caller is not the master contract");
            _;
    }
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  uint256 public totalDividendsDistributed;

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
    masterContract = msg.sender;
  }
  

  receive() external payable {
  }

  function updateMasterContract(address newAddress) public onlyMaster {
        masterContract = newAddress;
  }  
  function distributeDividends() public override payable onlyMaster {
    require(totalSupply() > 0);

    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);

      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }

  function distributeTokenDividends(uint256 amount) public onlyMaster{
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
    _withdrawDividendOfUser(msg.sender);
  }

  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);

        bool success = false;
        if(DividendToken == address(0)){
            (bool sent,) = user.call{value: _withdrawableDividend}("");
            success = sent;
            emit DividendWithdrawn(user, _withdrawableDividend, DividendToken);     
        }else{
            success = IERC20(DividendToken).transfer(user, _withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend, DividendToken);
        }

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
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

// Token Contract
pragma solidity ^0.7.6;
contract AVITA is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address public DividendToken = address(0);

    bool private swapping;

    AVITADividendTracker public dividendTracker;

    address public burnAddress;
    
    uint256 public maxBuyTransactionAmount = 50000000000000 * (10**18); // 5%
    uint256 public maxSellTransactionAmount = 50000000000000 * (10**18); // 5%
    uint256 public swapTokensAtAmount = 15000000 * (10**18);
    uint256 public _maxWalletToken = 50000000000000 * (10**18); // 5%

    mapping(address => uint256) public buycooldown;
    mapping(address => uint256) public sellcooldown;
    mapping(address => uint256) public firstsell;
    mapping(address => uint256) public sellnumber;
    address payable public DEV = 0x38b3f437e240fCfB6915BAa24dF56837Da50e54f;
    address payable public marketingAddress = 0x2edcB8DFC32d4C8ad0228aC6193cd23B63aac048;
    address payable public buybackAddress = 0x868ee5B8DF8dC4F31cB1ce7C0c4732F1695c451d;
    address public DEVTokenAddressForFee = address(this);
    address public marketingTokenAddressForFee = address(this);
    address public buybackTokenAddressForFee = address(this);
    // transfer fees
    uint256 public DEVFee = 0;
    uint256 public marketingFee = 0;
    uint256 public buybackFee = 0;
    uint256 public tokenRewardsFee = 0;
    uint256 public liquidityFee = 0;
    uint256 public burnFee = 0;
    uint256 public totalFees = tokenRewardsFee.add(liquidityFee).add(DEVFee).add(marketingFee).add(buybackFee).add(burnFee);
    // buy fees
    uint256 public buyDEVFee = 0; // development
    uint256 public buyMarketingFee = 2;  
    uint256 public buyBuybackFee = 0; 
    uint256 public buyTokenRewardsFee = 5; 
    uint256 public buyLiquidityFee = 2; 
    uint256 public buyBurnFee = 1; 
    uint256 public buyTotalFees = buyTokenRewardsFee.add(buyLiquidityFee).add(buyDEVFee).add(buyMarketingFee).add(buyBuybackFee).add(buyBurnFee);
    // sell fees
    uint256 public sellDEVFee = 2;
    uint256 public sellMarketingFee = 3;
    uint256 public sellBuybackFee = 0;
    uint256 public sellTokenRewardsFee = 5;
    uint256 public sellLiquidityFee = 4;
    uint256 public sellBurnFee = 1;
    uint256 public sellTotalFees = sellTokenRewardsFee.add(sellLiquidityFee).add(sellDEVFee).add(sellMarketingFee).add(sellBuybackFee).add(sellBurnFee);
    // fee tracker
    uint256 private previousDEVFee = DEVFee;
    uint256 private previousMarketingFee = marketingFee;
    uint256 private previousBuybackFee = buybackFee;
    uint256 private previousTokenRewardsFee = tokenRewardsFee;
    uint256 private previousLiquidityFee = liquidityFee;
    uint256 private previousBurnFee = burnFee;
    uint256 private previousTotalFees = totalFees;
    
    uint256 public processDividendTime;
    uint256 public dividendTime = 3600;
    
    bool public isTransferFeesDisabled = true;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    
    address public presaleAddress = address(0);

    // timestamp for when the token can be traded freely on PanackeSwap
    uint256 public tradingEnabledTimestamp = 1636408216;
    
    // exlcude from fees
    mapping (address => bool) private _isExcludedFromFees;

    // addresses that can make transfers before presale is over
    mapping (address => bool) private canTransferBeforeTradingIsEnabled;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateRouter(address indexed newAddress, address indexed oldAddress);event UpdatePair(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludedMaxSellTransactionAmount(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event BurnWalletUpdated(address indexed newBurnWallet, address indexed oldBurnWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
        uint256 tokensSwapped,
        uint256 amount
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    ); 

    constructor() ERC20("AVITA", "AVITA") {
        // LP burn address
        burnAddress = address(0xdead);
        uint256 _processDividendTime = block.timestamp;
        processDividendTime = _processDividendTime;

        dividendTracker = new AVITADividendTracker();
        //P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(owner());

        // exclude from paying fees
        excludeFromFees(burnAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);
        
        // enable owner and fixed-sale wallet to send tokens before presales are over
        canTransferBeforeTradingIsEnabled[owner()] = true;
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1 * 10**15 * (10**decimals())); // 1 Quadrillion Tokens
    }

    receive() external payable {

    }
    
    function swapAndLiquifyOwner(uint256 _tokens) external onlyOwner {
        swapAndLiquify(_tokens);
    }    
    
    function swapAndSendDividendsOwner(uint256 _tokens) external onlyOwner {
        swapAndSendDividends(_tokens);
    }
    function restoreFees() internal {
            DEVFee = previousDEVFee;
            marketingFee = previousMarketingFee;
            buybackFee = previousBuybackFee;
            tokenRewardsFee = previousTokenRewardsFee;
            liquidityFee = previousLiquidityFee;
            burnFee = previousBurnFee;
            totalFees = previousTotalFees;
    }       

    function updateSwapAtAmount(uint256 newAmountNoDecimials) external onlyOwner {
        swapTokensAtAmount = newAmountNoDecimials * (10**decimals());
    } 

    function updatedividendTime(uint256 _dividendTime) external onlyOwner {
        dividendTime = _dividendTime;
    }      
     
    
    function updateisTransferDisabled(bool _isTransferDisabled) external onlyOwner {
        isTransferFeesDisabled = _isTransferDisabled;
    }     

    function updateTradingEnabledTime (uint256 newTimeInEpoch) external onlyOwner {
        tradingEnabledTimestamp = newTimeInEpoch;
    }     

    function updateDEVAddress(address payable newAddress) external onlyOwner {
        _isExcludedFromFees[DEV] = false;
        DEV = newAddress;
        _isExcludedFromFees[newAddress] = true;
    }    

    function updateMarketingAddress(address payable newAddress) external onlyOwner {  
        _isExcludedFromFees[marketingAddress] = false;
        marketingAddress = newAddress;
        _isExcludedFromFees[newAddress] = true;
    }       

    function updateBuybackAddress(address payable newAddress) external onlyOwner {  
        _isExcludedFromFees[buybackAddress] = false;
        buybackAddress = newAddress;
        _isExcludedFromFees[newAddress] = true;
    }       

    function burnTokens(uint256 amountWithoutDecimals) external onlyOwner {
        uint256 sendAmount = amountWithoutDecimals * (10**decimals());
        super._transfer(address(this), burnAddress, sendAmount);
    }
    
    function updateFees(uint256 _tokenRewardsFee, uint256 _liquidityFee, uint256 _DEVFee, uint256 _marketingFee, uint256 _buybackFee, uint256 _burnFee) external onlyOwner {
        tokenRewardsFee = _tokenRewardsFee;
        liquidityFee = _liquidityFee;
        DEVFee = _DEVFee;
        marketingFee = _marketingFee;
        buybackFee = _buybackFee;
        burnFee = _burnFee;
        totalFees = _tokenRewardsFee.add(_liquidityFee).add(_DEVFee).add(_marketingFee).add(_buybackFee).add(_burnFee);
        previousDEVFee = _DEVFee;
        previousMarketingFee = _marketingFee;
        previousBuybackFee = _buybackFee;
        previousTokenRewardsFee = _tokenRewardsFee;
        previousLiquidityFee = _liquidityFee;
        previousBurnFee = _burnFee;
        previousTotalFees = _tokenRewardsFee.add(_liquidityFee).add(_DEVFee).add(_marketingFee).add(_buybackFee).add(_burnFee);
    }    
    
    function updateBuyFees(uint256 _tokenRewardsFee, uint256 _liquidityFee, uint256 _DEVFee, uint256 _marketingFee, uint256 _buybackFee, uint256 _burnFee) external onlyOwner {
        buyTokenRewardsFee = _tokenRewardsFee;
        buyLiquidityFee = _liquidityFee;
        buyDEVFee = _DEVFee;
        buyMarketingFee = _marketingFee;
        buyBuybackFee = _buybackFee;
        buyBurnFee = _burnFee;
        buyTotalFees = _tokenRewardsFee.add(_liquidityFee).add(_DEVFee).add(_marketingFee).add(_buybackFee).add(_burnFee);
    }    
    
    function updateSellFees(uint256 _tokenRewardsFee, uint256 _liquidityFee, uint256 _DEVFee, uint256 _marketingFee, uint256 _buybackFee, uint256 _burnFee) external onlyOwner {
        sellTokenRewardsFee = _tokenRewardsFee;
        sellLiquidityFee = _liquidityFee;
        sellDEVFee = _DEVFee;
        sellMarketingFee = _marketingFee;
        sellBuybackFee = _buybackFee;
        sellBurnFee = _burnFee;
        sellTotalFees = _tokenRewardsFee.add(_liquidityFee).add(_DEVFee).add(_marketingFee).add(_buybackFee).add(_burnFee);
    }

    function whitelistDxSale(address _presaleAddress, address _routerAddress) external onlyOwner {
        presaleAddress = _presaleAddress;
        canTransferBeforeTradingIsEnabled[presaleAddress] = true;
        dividendTracker.excludeFromDividends(_presaleAddress);
        excludeFromFees(_presaleAddress, true);

        canTransferBeforeTradingIsEnabled[_routerAddress] = true;
        dividendTracker.excludeFromDividends(_routerAddress);
        excludeFromFees(_routerAddress, true);
    }

    function updateDividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(dividendTracker), "AVITA: The dividend tracker already has that address");

        AVITADividendTracker newDividendTracker = AVITADividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "AVITA: The new dividend tracker must be owned by the AVITA token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateRouter(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "AVITA: The router already has that address");
        emit UpdateRouter(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }    
    
    function updatePair(address newAddress) external onlyOwner {
        require(newAddress != uniswapV2Pair , "AVITA: The pair already has that address");
        emit UpdatePair(newAddress, uniswapV2Pair);
        uniswapV2Pair = newAddress;
        _setAutomatedMarketMakerPair(newAddress,true);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }              

    function excludeFromDividends(address account) public onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }    

    function enableDividends(address account) public onlyOwner {
        dividendTracker.enableDividends(account);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "AVITA: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "AVITA: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "AVITA: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "AVITA: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }    
    

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    function swapAndLiquify(uint256 tokens) private  {
        uint256 DEVFeeFull;
        uint256 marketingFeeFull;
        uint256 buybackFeeFull;
        
        if(DEVFee != 0){
            DEVFeeFull = tokens.mul(DEVFee).div(100);
        }
        if(marketingFee != 0){
            marketingFeeFull = tokens.mul(marketingFee).div(100);
        }
        if(buybackFee != 0){
            buybackFeeFull = tokens.mul(buybackFee).div(100);
        }

        uint256 tokensAfterFee = tokens - DEVFeeFull - marketingFeeFull - buybackFeeFull;
        // split the contract balance into halves
        uint256 initHalf = tokens.div(2);
        uint256 half = tokensAfterFee.div(2);
        uint256 otherHalf = tokensAfterFee.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(initHalf); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 DEVFeeBalance;
        uint256 marketingFeeBalance;
        uint256 buybackFeeBalance;

        if(DEVFee != 0){
            DEVFeeBalance = newBalance.mul(DEVFee).div(100);
        }
        if(marketingFee != 0){
            marketingFeeBalance = newBalance.mul(marketingFee).div(100);
        }
        if(buybackFee != 0){
            buybackFeeBalance = newBalance.mul(buybackFee).div(100);
        }
        
        uint256 finalBalance = newBalance - DEVFeeBalance - marketingFeeBalance - buybackFeeBalance;
        uint256 finalHalf = otherHalf;

        if(DEVFeeBalance != 0){
        if(DEVTokenAddressForFee != address(0)){
            swapEthForTokens(DEVFeeBalance, DEVTokenAddressForFee, DEV);
        }else{
            (bool sent,) = DEV.call{value: DEVFeeBalance}("");
        }}

        if(marketingFeeBalance != 0){        
        if(marketingTokenAddressForFee != address(0)){
            swapEthForTokens(marketingFeeBalance, marketingTokenAddressForFee, marketingAddress);
        }else{
            (bool sent,) = marketingAddress.call{value: marketingFeeBalance}("");
        }}

        if(buybackFeeBalance != 0){        
        if(buybackTokenAddressForFee != address(0)){
            swapEthForTokens(buybackFeeBalance, buybackTokenAddressForFee, buybackAddress);
        }else{
            (bool sent,) = buybackAddress.call{value: buybackFeeBalance}("");
        }}

        // add liquidity to uniswap
        addLiquidity(finalHalf, finalBalance);
        emit SwapAndLiquify(half, finalBalance, otherHalf);
    }
    // modified to support BNB dividend
    function swapAndSendDividends(uint256 tokens) private {
        address payable diviTracker = address(dividendTracker);
        bool success = false;
        uint256 dividends;
        if(DividendToken != address(0)){
            swapTokensForTokens(tokens, address(this));
            dividends = IERC20(DividendToken).balanceOf(address(this));
            success = IERC20(DividendToken).transfer(address(dividendTracker), dividends);
        }else{
            uint256 initialBalance = address(this).balance;
            swapTokensForEth(tokens);
            uint256 newBalance = address(this).balance.sub(initialBalance);
            dividends = newBalance;
            (bool sent,) = diviTracker.call{value: newBalance}("");
            success = sent;
        }
        if (success) {
            dividendTracker.distributeTokenDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    } 
    function swapEthForTokens(uint256 ethAmount, address tokenAddress, address receiver) private {
        // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of ETH
            path,
            receiver,
            block.timestamp
        );
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
    function swapTokensForTokens(uint256 tokenAmount, address recipient) private {
       
        // generate the uniswap pair path of weth -> busd
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = DividendToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            recipient,
            block.timestamp
        );
        
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
       uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            burnAddress,
            block.timestamp
        );
        
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer to the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool buyOrSell = false;
        if (
            from != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            automatedMarketMakerPairs[from]
        ) {
            {
            require(
                amount <= maxBuyTransactionAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
            }

            previousDEVFee = DEVFee;
            previousMarketingFee = marketingFee;
            previousBuybackFee = buybackFee;
            previousTokenRewardsFee = tokenRewardsFee;
            previousLiquidityFee = liquidityFee;
            previousBurnFee = liquidityFee;
            previousTotalFees = totalFees;
            DEVFee = buyDEVFee;
            marketingFee = buyMarketingFee;
            buybackFee = buyBuybackFee;
            tokenRewardsFee = buyTokenRewardsFee;
            liquidityFee = buyLiquidityFee;
            burnFee = buyBurnFee;
            totalFees = buyTotalFees;
            buyOrSell = true;
        }
        
        
        bool tradingIsEnabled = getTradingIsEnabled();
        

        // only whitelisted addresses can make transfers after the fixed-sale has started
        // and before the public presale is over
        if(!tradingIsEnabled) {
            require(canTransferBeforeTradingIsEnabled[from], "AVITA: This account cannot send tokens until trading is enabled");
        }

        if( 
            from != owner() &&
            !swapping &&
            tradingIsEnabled &&
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
            from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            
            previousDEVFee = DEVFee;
            previousMarketingFee = marketingFee;
            previousBuybackFee = buybackFee;
            previousTokenRewardsFee = tokenRewardsFee;
            previousLiquidityFee = liquidityFee;
            previousBurnFee = burnFee;
            previousTotalFees = totalFees;
            DEVFee = sellDEVFee;
            marketingFee = sellMarketingFee;
            buybackFee = sellBuybackFee;
            tokenRewardsFee = sellTokenRewardsFee;
            liquidityFee = sellLiquidityFee;
            burnFee = sellBurnFee;
            totalFees = sellTotalFees;
            buyOrSell = true;
            
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(
            tradingIsEnabled && 
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != burnAddress &&
            to != burnAddress
        ) {
            swapping = true;
            // added to sell this amount set instead of just trigger
            //contractTokenBalance = swapTokensAtAmount;
            //uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokensAtAmount);
            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);

            swapping = false;
        }


        bool takeFee = tradingIsEnabled && !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || isTransferFeesDisabled) {
            takeFee = false;
        }

        if(takeFee || buyOrSell ) {
            if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
             // exclude fees from those excluded from fees in case of buy or sell
            }else{
            uint256 calcFee = totalFees - burnFee - DEVFee - marketingFee - buybackFee;
            uint256 feeAmount = amount.mul(calcFee).div(100);
            uint burnAmount = amount.mul(burnFee).div(100);
            uint DEVAmount = amount.mul(DEVFee).div(100);
            uint marketingAmount = amount.mul(marketingFee).div(100);
            uint buybackAmount = amount.mul(buybackFee).div(100);
            feeAmount = feeAmount - burnAmount - DEVAmount - marketingAmount - buybackAmount;
            super._transfer(from, address(this), feeAmount);
            super._transfer(from, DEV, DEVAmount);
            super._transfer(from, marketingAddress, marketingAmount);
            super._transfer(from, buybackAddress, buybackAmount);
            super._transfer(from, burnAddress, burnAmount);
            }
        }else{
            if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
             // exclude burn from those excluded from fees
            }else{
            uint burnAmount = amount.mul(burnFee).div(100);
            amount = amount.sub(burnAmount);
            super._transfer(from, burnAddress, burnAmount);
            }
        }
        

        super._transfer(from, to, amount);


        restoreFees();
        

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        bool canDividend = block.timestamp >= processDividendTime;

        if(!swapping && canDividend) {
            uint256 gas = gasForProcessing;
            processDividendTime += dividendTime;
            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {

            }
        }
    }
    
}

contract AVITADividendTracker is DividendPayingToken, Ownable {
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

    constructor() DividendPayingToken("AVITA_Dividend_Tracker", "AVITA_Dividend_Tracker") {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 1 * (10**18);

    }  
    
    function _transfer(address, address, uint256) internal pure override {
        require(false, "AVITA_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "AVITA_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main AVITA contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        //require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        //emit ExcludeFromDividends(account);
    }    

    function enableDividends(address account) external onlyOwner {
        //require(!excludedFromDividends[account]);
        excludedFromDividends[account] = false;
        //emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "AVITA_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "AVITA_Dividend_Tracker: Cannot update claimWait to same value");
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