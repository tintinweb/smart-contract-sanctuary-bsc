/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IPancakeswapV2Pair {
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

interface IPancakeswapV2Factory {
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

library IterableMapping {
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

interface IBEP20 {

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

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


contract BEP20 is Context, IBEP20, IBEP20Metadata {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



interface DividendPayingTokenInterface {

function withdrawableDividendOf(address _owner) external view returns(uint256);

function withdrawnDividendOf(address _owner) external view returns(uint256);

function accumulativeDividendOf(address _owner) external view returns(uint256);

function dividendOf(address _owner) external view returns(uint256);

function distributeDividends() external payable;

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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


interface IPancakeswapV2Router01 {
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

interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
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

contract DividendPayingToken is DividendPayingTokenInterface, Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;
  // BUSD Contract address 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
  address public constant token = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
  
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  
  mapping (address => uint256) public holderBalance;
  uint256 public totalBalance;

  uint256 public totalDividendsDistributed;

  receive() external payable {
    distributeDividends();
  }

    
  function distributeDividends() public override payable {
    require(false, "Cannot send BNB directly to tracker as it is unrecoverable");
  }
  
  function distributeTokenDividends(uint256 amount) public onlyOwner {
    require(totalBalance > 0);

    if (amount > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (amount).mul(magnitude) / totalBalance
      );
      emit DividendsDistributed(msg.sender, amount);

      totalDividendsDistributed = totalDividendsDistributed.add(amount);
    }
  }

  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      bool success = IBEP20(token).transfer(user, _withdrawableDividend);

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
    return magnifiedDividendPerShare.mul(holderBalance[_owner]).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  function _increase(address account, uint256 value) internal {
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _reduce(address account, uint256 value) internal {
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = holderBalance[account];
    holderBalance[account] = newBalance;
    if(newBalance > currentBalance) {
      uint256 increaseAmount = newBalance.sub(currentBalance);
      _increase(account, increaseAmount);
      totalBalance += increaseAmount;
    } else if(newBalance < currentBalance) {
      uint256 reduceAmount = currentBalance.sub(newBalance);
      _reduce(account, reduceAmount);
      totalBalance -= reduceAmount;
    }
  }
}

contract GenesisTracer is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() {
    	claimWait = 1800;

        // Minimum amount tokens needed for dividends | Set number in tokens
        minimumTokenBalanceForDividends = 1 * 10**18;
    }

    function excludeFromDividends(address account) external onlyOwner {
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }
    
    function includeInDividends(address account) external onlyOwner {
    	require(excludedFromDividends[account]);
    	excludedFromDividends[account] = false;

    	emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 1800 && newClaimWait <= 86400, "GenesisTracer: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "GenesisTracer: Cannot update claimWait to same value");
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


contract AlphaGenesis is BEP20, Ownable {
    using SafeMath for uint256;

    IPancakeswapV2Router02 public immutable pancakeswapV2Router;
    address public immutable pancakeswapV2Pair;

    bool private swapping;

    GenesisTracer public genesisTracer;

    address public marketingWallet;
    address public communityWallet;
    address public liquidityWallet;

    uint256 public percForMarketing = 50;
    bool public buyBackEnabled = true;

    mapping(address => uint256) public walletSellDumpCircuitEndTime;
    mapping(address => uint256) public walletLastBuy;
    uint256 public constant dumpcircuitDuration = 1 days;
    
    // BUSD Contract Address 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    address public constant token = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    
    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    
    uint256 private liquidityActiveBlock = 0;
    uint256 private tradingActiveBlock = 0;
    
    bool public DumpCircuit = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool private transferDelayEnabled = true;
    
    address private presaleAddress;
    address private presaleRouterAddress;

    uint256 public feeDivisor = 100;
    
    uint256 public totalDumpCircuitSellFees;
    uint256 public rewardsDumpCircuitSellFee;
    uint256 public marketingDumpCircuitSellFee;
    uint256 public liquidityDumpCircuitSellFee;
    uint256 public communityDumpCircuitSellFee;

    uint256 public totalSellFees;
    uint256 public rewardsSellFee;
    uint256 public marketingSellFee;
    uint256 public liquiditySellFee;
    uint256 public communitySellFee;
    
    uint256 public totalBuyFees;
    uint256 public rewardsBuyFee;
    uint256 public marketingBuyFee;
    uint256 public liquidityBuyFee;
    uint256 public communityBuyFee;
    
    uint256 private tokensForRewards;
    uint256 private tokensForMarketing;
    uint256 private tokensForLiquidity;
    uint256 private tokensForCommunity;   

    uint256 public gasForProcessing = 400000;

    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludedMaxTransactionAmount(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event marketingWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event liquidityWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event communityWalletUpdated(address indexed newWallet, address indexed oldWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event IncludeInDividends(address indexed wallet);
    event ExcludeFromDividends(address indexed wallet);

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedGenesisTracer(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() BEP20("ACTV", "ACTV"){
        address newOwner = address(0xA5C6bC9aAbDD8fF5d012051ed542535A7cd10763);
    
        uint256 totalSupply = 75000000000000000000000000000000;
        // Maximum amount to transfer
        maxTransactionAmount = 10000000; 
        // Tokens for SwapAndLiquify
        swapTokensAtAmount = 10000;

        rewardsDumpCircuitSellFee = 12;
        marketingDumpCircuitSellFee = 10;
        liquidityDumpCircuitSellFee = 2;
        communityDumpCircuitSellFee = 6;
        totalDumpCircuitSellFees = rewardsDumpCircuitSellFee + marketingDumpCircuitSellFee + liquidityDumpCircuitSellFee + communityDumpCircuitSellFee;

        rewardsSellFee = 8;
        marketingSellFee = 4;
        liquiditySellFee = 2;
        communitySellFee = 2;
        totalSellFees = rewardsSellFee + marketingSellFee + liquiditySellFee + communitySellFee;
        
        rewardsBuyFee = 4;
        marketingBuyFee = 2;
        liquidityBuyFee = 2;
        communityBuyFee = 2;
        totalBuyFees = rewardsBuyFee + marketingBuyFee + liquidityBuyFee + communityBuyFee;
        
    	genesisTracer = new GenesisTracer();
    	// Marketing and BuyBack Wallet
    	marketingWallet = address(0xA5C6bC9aAbDD8fF5d012051ed542535A7cd10763);
        // Community Distribution Wallet
        communityWallet = address(0xA5C6bC9aAbDD8fF5d012051ed542535A7cd10763);
        // Liquidity Wallet
        liquidityWallet = address(0xA5C6bC9aAbDD8fF5d012051ed542535A7cd10763); 

        // Pancakeswap testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    	// Pancakeswap mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    	IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);


        address _pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());

        pancakeswapV2Router = _pancakeswapV2Router;
        pancakeswapV2Pair = _pancakeswapV2Pair;

        _setAutomatedMarketMakerPair(_pancakeswapV2Pair, true);

        genesisTracer.excludeFromDividends(address(genesisTracer));
        genesisTracer.excludeFromDividends(address(this));
        genesisTracer.excludeFromDividends(newOwner);
        genesisTracer.excludeFromDividends(address(_pancakeswapV2Router));
        genesisTracer.excludeFromDividends(address(0xdead));
        
        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTransaction(newOwner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(genesisTracer), true);
        excludeFromMaxTransaction(address(_pancakeswapV2Router), true);
        excludeFromMaxTransaction(address(0xdead), true);
        

        _createInitialSupply(address(newOwner), totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {

  	}

    function addPresaleAddressForExclusions(address _presaleAddress, address _presaleRouterAddress) external onlyOwner {
        presaleAddress = _presaleAddress;
        excludeFromFees(_presaleAddress, true);
        genesisTracer.excludeFromDividends(_presaleAddress);
        excludeFromMaxTransaction(_presaleAddress, true);
        presaleRouterAddress = _presaleRouterAddress;
        excludeFromFees(_presaleRouterAddress, true);
        genesisTracer.excludeFromDividends(_presaleRouterAddress);
        excludeFromMaxTransaction(_presaleRouterAddress, true);
    }
    
    function emergencyPresaleAddressUpdate(address _presaleAddress, address _presaleRouterAddress) external onlyOwner {
        presaleAddress = _presaleAddress;
        presaleRouterAddress = _presaleRouterAddress;
    }
    
    function disableTransferDelay() external onlyOwner returns (bool){
        transferDelayEnabled = false;
        return true;
    }

    // Exclude from the fees
    function excludeFromDividends(address account) external onlyOwner {
        genesisTracer.excludeFromDividends(account);
        emit ExcludeFromDividends(account);
    }

    // Exclude from GenesisTracer
    function includeInDividends(address account) external onlyOwner {
        genesisTracer.includeInDividends(account);
        emit IncludeInDividends(account);
    }

    // Change SwapAndLiquidy
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
  	    require(newAmount >= totalSupply() * 1 / 100000, ".");
  	    require(newAmount <= totalSupply() * 5 / 1000, ".");
  	    swapTokensAtAmount = newAmount;
  	    return true;
  	}
    
    // Triggered once when setup is completed | Enables trading to start
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
    }

    function updateMaxAmount(uint256 newNum) external onlyOwner {
        require(newNum > (totalSupply() * 5 / 1000)/1**18, "");
        maxTransactionAmount = newNum * (10**18);
    }
    
    function updateBuyFees(uint256 _marketingFee, uint256 _rewardsFee, uint256 _liquidityFee, uint256 _communityFee) external onlyOwner {
        marketingBuyFee = _marketingFee;
        rewardsBuyFee = _rewardsFee;
        liquidityBuyFee = _liquidityFee;
        communityBuyFee = _communityFee;
        totalBuyFees = marketingBuyFee + rewardsBuyFee + liquidityBuyFee + communityBuyFee;
        require(totalBuyFees <= 1500, "Keep below 15%");
    }
    
    function updateSellFees(uint256 _marketingFee, uint256 _rewardsFee, uint256 _liquidityFee, uint256 _communityFee) external onlyOwner {
        marketingSellFee = _marketingFee;
        rewardsSellFee = _rewardsFee;
        liquiditySellFee = _liquidityFee;
        communitySellFee = _communityFee;
        totalSellFees = marketingSellFee + rewardsSellFee + liquiditySellFee + communitySellFee;
        require(totalSellFees <= 2500, "Keep below 25%");
    }

     function updateDumpCircuitSellFees(uint256 _marketingFee, uint256 _rewardsFee, uint256 _liquidityFee, uint256 _communityFee) external onlyOwner {
        marketingDumpCircuitSellFee = _marketingFee;
        rewardsDumpCircuitSellFee = _rewardsFee;
        liquidityDumpCircuitSellFee = _liquidityFee;
        communityDumpCircuitSellFee = _communityFee;
        totalDumpCircuitSellFees = marketingDumpCircuitSellFee + rewardsDumpCircuitSellFee + liquidityDumpCircuitSellFee + communityDumpCircuitSellFee;
        require(totalDumpCircuitSellFees <= 3500, "Keep below 35%");
        require(totalDumpCircuitSellFees >= totalSellFees, "Can't go lower than Circuit limits");
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
        emit ExcludedMaxTransactionAmount(updAds, isEx);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function updateSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        excludeFromMaxTransaction(pair, value);
        
        if(value) {
            genesisTracer.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateMarketingWallet(address newMarketingWallet) external onlyOwner {
        require(newMarketingWallet != address(0), "cannot set to 0 address");
        excludeFromFees(newMarketingWallet, true);
        emit marketingWalletUpdated(newMarketingWallet, marketingWallet);
        marketingWallet = newMarketingWallet;
    }

    function updateLiquidityWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "cannot set to 0 address");
        excludeFromFees(newWallet, true);
        emit liquidityWalletUpdated(newWallet, liquidityWallet);
        liquidityWallet = newWallet;
    }

    function updateCommunityWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "cannot set to 0 address");
        excludeFromFees(newWallet, true);
        emit communityWalletUpdated(newWallet, communityWallet);
        communityWallet = newWallet;
    }
    
    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 600000, " gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        genesisTracer.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return genesisTracer.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return genesisTracer.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return genesisTracer.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return genesisTracer.holderBalance(account);
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
        return genesisTracer.getAccount(account);
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
    	return genesisTracer.getAccountAtIndex(index);
    }

	function processGenesisTracer(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = genesisTracer.process(gas);
		emit ProcessedGenesisTracer(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		genesisTracer.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return genesisTracer.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return genesisTracer.getNumberOfTokenHolders();
    }
    
    function getNumberOfDividends() external view returns(uint256) {
        return genesisTracer.totalBalance();
    }
    
    // Remove DumpCircuit
    function removeLimits() external onlyOwner returns (bool){
        DumpCircuit = false;
        transferDelayEnabled = false;
        return true;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        
         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        if(!tradingActive || tradingActiveBlock + 2 >= block.number){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active yet.");
        }
        
        if(DumpCircuit){
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping &&
                from != presaleAddress &&
                from != presaleRouterAddress
            ){

                  
                if (transferDelayEnabled){
                    if (to != owner() && to != address(pancakeswapV2Router) && to != address(pancakeswapV2Pair)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
                
                // Buying process
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                } 
                // Selling process
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
                }
            }
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( 
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

       
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        uint256 fees = 0;
        
        
        if(takeFee){
            // Selling process with DumpCircuit activated
            if (automatedMarketMakerPairs[to] && totalDumpCircuitSellFees > 0 && block.timestamp < walletSellDumpCircuitEndTime[from]){
                uint256 holderTax = getHolderDumpCircuitSellTax(from);
                fees = amount.mul(holderTax + totalSellFees).div(feeDivisor);
                tokensForRewards += fees * rewardsDumpCircuitSellFee / totalDumpCircuitSellFees;
                tokensForLiquidity += fees * liquidityDumpCircuitSellFee / totalDumpCircuitSellFees;
                tokensForMarketing += fees * marketingDumpCircuitSellFee / totalDumpCircuitSellFees;
                tokensForCommunity += fees * communityDumpCircuitSellFee / totalDumpCircuitSellFees;
            }
            // Selling process without DumpCircuit
            else if (automatedMarketMakerPairs[to] && totalSellFees > 0){
                fees = amount.mul(totalSellFees).div(feeDivisor);
                tokensForRewards += fees * rewardsSellFee / totalSellFees;
                tokensForLiquidity += fees * liquiditySellFee / totalSellFees;
                tokensForMarketing += fees * marketingSellFee / totalSellFees;
                tokensForCommunity += fees * communitySellFee / totalSellFees;
            }
            // Buying process without DumpCircuit
            else if(automatedMarketMakerPairs[from] && totalBuyFees > 0) {
        	    fees = amount.mul(totalBuyFees).div(feeDivisor);
        	    tokensForRewards += fees * rewardsBuyFee / totalBuyFees;
                tokensForLiquidity += fees * liquidityBuyFee / totalBuyFees;
                tokensForMarketing += fees * marketingBuyFee / totalBuyFees;
                tokensForCommunity += fees * communityBuyFee / totalBuyFees;
                // New DumpCircuit time in days
                uint256 holderBalance = balanceOf(to);
                if(walletSellDumpCircuitEndTime[to] == 0){
                    walletSellDumpCircuitEndTime[to] = block.timestamp + dumpcircuitDuration;
                } else {
                    // Only portion of the token amount is affected by the Circuit
                    walletSellDumpCircuitEndTime[to] = amount >= holderBalance ? block.timestamp + dumpcircuitDuration : walletSellDumpCircuitEndTime[to] + (dumpcircuitDuration * (amount*1**18/holderBalance))/1**18;
                    if(walletSellDumpCircuitEndTime[to] - dumpcircuitDuration > block.timestamp){
                        walletSellDumpCircuitEndTime[to] = block.timestamp + dumpcircuitDuration;
                    }
                }
                walletLastBuy[to] = block.timestamp;
            } else {
                // New DumpCircuit time
                uint256 holderBalance = balanceOf(to);
                if(walletSellDumpCircuitEndTime[to] == 0){
                    walletSellDumpCircuitEndTime[to] = block.timestamp + dumpcircuitDuration;
                } else {
                    // Only portion of the token amount is affected by the Circuit
                    walletSellDumpCircuitEndTime[to] = amount >= holderBalance ? block.timestamp + dumpcircuitDuration : walletSellDumpCircuitEndTime[to] + (dumpcircuitDuration * (amount*1**18/holderBalance))/1**18;
                    if(walletSellDumpCircuitEndTime[to] - dumpcircuitDuration > block.timestamp){
                        walletSellDumpCircuitEndTime[to] = block.timestamp + dumpcircuitDuration;
                    }
                }
                walletLastBuy[to] = block.timestamp;
            }
            
            if(fees > 0){    
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);

        try genesisTracer.setBalance(payable(from), balanceOf(from)) {} catch {}
        try genesisTracer.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try genesisTracer.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedGenesisTracer(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {}
        }
    }

    function swapBnbForRewardToken(uint256 bnbAmount) private {
        if(bnbAmount > 0){
            address[] memory path = new address[](2);
            path[0] = pancakeswapV2Router.WETH();
            path[1] = token;
            
            pancakeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function swapBnbForNativeToken(uint256 bnbAmount) private {
        if(bnbAmount > 0){
            address[] memory path = new address[](2);
            path[0] = pancakeswapV2Router.WETH();
            path[1] = address(this);
            
            pancakeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
                0,
                path,
                address(marketingWallet),
                block.timestamp
            );
        }
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {

        // Generate Pancakeswap pair -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        // Perform the swap
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
        
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
       
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

       
        pancakeswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(0xdead),
            block.timestamp
        );

    }

    function getHolderDumpCircuitSellTax(address wallet) public view returns (uint256){
        if(walletSellDumpCircuitEndTime[wallet] <= block.timestamp) { return 0;}
        uint256 dumpcircuitTax = totalDumpCircuitSellFees - totalSellFees;
        uint256 timeRemainingForDumpCircuit = walletSellDumpCircuitEndTime[wallet] - block.timestamp;
        uint256 walletDumpCircuitTax = (dumpcircuitTax*(timeRemainingForDumpCircuit*1**9/dumpcircuitDuration))/1**9;

        return walletDumpCircuitTax;
    }
    
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForRewards + tokensForCommunity;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        bool success;
        
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(contractBalance); 
        
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        
        uint256 ethForMarketing = ethBalance.mul(tokensForMarketing).div(totalTokensToSwap);
        uint256 ethForRewards = ethBalance.mul(tokensForRewards).div(totalTokensToSwap);
        uint256 ethForCommunity= ethBalance.mul(tokensForCommunity).div(totalTokensToSwap);
        uint256 ethForLiquidity = ethBalance.mul(tokensForLiquidity).div(totalTokensToSwap);
        
        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForRewards = 0;
        tokensForCommunity = 0;
        
        
        (success,) = address(communityWallet).call{value: ethForCommunity}("");
        (success,) = address(liquidityWallet).call{value: ethForLiquidity}("");
        
        swapBnbForRewardToken(ethForRewards);
        
        uint256 tokenBalance = IBEP20(token).balanceOf(address(this));
        success = IBEP20(token).transfer(address(genesisTracer), tokenBalance);
        
        if (success) {
            genesisTracer.distributeTokenDividends(tokenBalance);
            emit SendDividends(tokenBalance, ethForRewards);
        }

        if(buyBackEnabled){
            (success,) = address(marketingWallet).call{value: ethForMarketing * percForMarketing / 100}("");
            swapBnbForNativeToken(address(this).balance);
        } else {
            (success,) = address(marketingWallet).call{value: address(this).balance}("");
        }
    }

    function withdrawStuckBNB() external onlyOwner {
        (bool success,) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "failed to withdraw");
    }

    function marketingBuyBackSettings(bool _buyBackEnabled, uint256 _percForMarketing) external onlyOwner {
        require(_percForMarketing <= 100, "May not set value higher than 100");
        percForMarketing = _percForMarketing;
        buyBackEnabled = _buyBackEnabled;
    }
}